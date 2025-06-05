SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[SP_HostsystemstatusReport]
AS

Declare @TimeKey as Int =(Select Timekey from Automate_Advances where EXT_FLG='Y')
Declare @Date as Date =(Select Date from Automate_Advances where EXT_FLG='Y')


select @Date,DB.SourceName as Host_System_Name,ISNULL(NPA,0)NPA,ISNULL(STD,0)STD,ISNULL([CR & Zero Balances],0)[CR & Zero Balances],ISNULL(Closed,0)Closed,
(sum(ISNULL(NPA,0))+sum(ISNULL(STD,0)))[Total]
 from DimSourceDB DB
 LEFT JOIN (
select Report_Date,Host_System_Name,ISNULL(count(distinct Account_No),0)NPA 
from ENPA_Host_System_Status_Tbl A
Inner Join Reversefeeddata B 
On A.Account_No=B.AccountID
And cast(A.Report_Date as date)=cast(B.DateofData as date)
where 
--Host_System_Name = 'Finacle' and
 Main_Classification = 'NPA'
 And B.AssetClass > 1
 AND  cast(A.Report_Date as date) = @Date
group by Report_Date,Host_System_Name
)A ON A.Host_System_Name = DB.SourceName
LEFT JOIN (
select Report_Date,Host_System_Name,ISNULL(count(distinct Account_No),0)STD 
from ENPA_Host_System_Status_Tbl A
Inner Join Reversefeeddata B 
On A.Account_No=B.AccountID
And A.Report_Date=B.DateofData
INNER JOIN AdvAcBasicDetail C 
ON B.AccountID = C.CustomerACID 
and C.EffectiveToTimeKey = 49999
INNER JOIN AdvAcBalanceDetail D 
ON C.AccountEntityId = D.AccountEntityId
and D.EffectiveToTimeKey = 49999
where 
--Host_System_Name = 'Finacle' and
 Main_Classification = 'STD'
 AND ISNULL(D.SignBalance ,0) != 0
 AND Closed_Date is  NULL
 And B.AssetClass > 1
 AND  cast(A.Report_Date as date) = @Date
group by Report_Date,Host_System_Name)B 
ON  DB.SourceName = B.Host_System_Name
LEFT JOIN (
select Report_Date,Host_System_Name,
ISNULL(count(distinct Account_No),0)[CR & Zero Balances] 
from ENPA_Host_System_Status_Tbl A
Inner Join Reversefeeddata B 
On A.Account_No=B.AccountID
And A.Report_Date=B.DateofData
INNER JOIN AdvAcBasicDetail C 
ON B.AccountID = C.CustomerACID 
and C.EffectiveToTimeKey = 49999
INNER JOIN AdvAcBalanceDetail D 
ON C.AccountEntityId = D.AccountEntityId
and D.EffectiveToTimeKey = 49999
where 
--Host_System_Name = 'Finacle' and 
--Main_Classification is NULL
Main_Classification = 'STD'
 And
ISNULL(D.SignBalance ,0) = 0
And B.AssetClass > 1
And cast(A.Report_Date as date) = @Date
group by Report_Date,Host_System_Name)C on  DB.SourceName = C.Host_System_Name
LEFT JOIN (
select Report_Date,Host_System_Name,ISNULL(count(distinct Account_No),0)[Closed] 
from ENPA_Host_System_Status_Tbl A
Inner Join Reversefeeddata B 
On A.Account_No=B.AccountID
And A.Report_Date=B.DateofData
where	Main_Classification = 'STD' 
AND		Closed_Date is not NULL
And		B.AssetClass > 1
And cast(A.Report_Date as date) = @Date
group by Report_Date,Host_System_Name)D 
on  DB.SourceName = D.Host_System_Name
where DB.SourceName!= 'VisionPlus'
group by  DB.SourceName,NPA,STD,[CR & Zero Balances],Closed
GO