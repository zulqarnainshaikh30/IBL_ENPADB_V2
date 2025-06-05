SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE proc [dbo].[FinacleInsertQueryofAccountProvisionSecured]

AS
/*
Begin




Declare @TIMEKEY as Int =(Select Timekey from Automate_Advances where ext_flg='Y')
Declare @Date as Date =(Select Date from Automate_Advances where ext_flg='Y')

DECLARE @SETID INT =(SELECT ISNULL(MAX(ISNULL(SETID,0)),0)+1 
FROM [PRO].[ReverseFeed_ProcessMonitor] WHERE TIMEKEY=@TIMEKEY)

INSERT INTO PRO.ReverseFeed_ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'FinacleInsertQueryofAccountProvisionSecured','RUNNING',GETDATE(),NULL,@TIMEKEY,@SETID


---------------07-08-2021 --- provision change
/*
IF OBJECT_ID('TempDB..#ProvisionChange') Is Not Null
Drop Table #ProvisionChange

Select * into #ProvisionChange from (
Select A.AccountID  from ReverseFeedData A
Inner Join ReverseFeedData B ON A.AccountID=B.AccountID
And B.EffectiveFromTimeKey=@TIMEKEY-1
Where A.EffectiveFromTimeKey=@TIMEKEY
And A.SourceAlt_Key=1 And B.SourceAlt_Key=1
And A.TotalProvision<>B.TotalProvision
-------------Added on 23-08-2021
UNION
Select A.AccountID from ReverseFeedData A Where A.SourceAlt_Key=1 And A.EffectiveFromTimeKey=@TIMEKEY ANd A.TotalProvision>0
AND Not Exists (Select 1 from ReverseFeedData B Where B.EffectiveFromTimeKey=@TIMEKEY-1 And B.AccountID=A.AccountID
And A.SourceAlt_Key=B.SourceAlt_Key)

 UNION -- for New Accounts----24-08-2021-----
 select CustomerACID from curdat.AdvAcBasicDetail
where cast(AccountOpenDate as date) = @Date
and SourceAlt_Key=1

)A
*/

Truncate Table [dbo].[C_ACC_PROV_IRAC_TBL]

insert into [dbo].[C_ACC_PROV_IRAC_TBL]
Select 

--Convert(Varchar(10),DateofData,105) DATE_OF_DATA
DateofData
,SourceSystemName SOURCE_SYSTEM
,CustomerID CIF_ID
,A.AccountID FORACID
,BranchCode SOL_ID
,TotalProvision TOT_PROVISION
,Provsecured SEC_PROVISION
,ProvUnsecured UNSEC_PROVISION
,ProvCoverGovGur SYS_ADOC_PROVISION
,AddlProvision ADOC_USER_PROVISION
,'UJ01'BANK_ID
,NULL FREE_TEXT_1
,NULL FREE_TEXT_2

 from ReverseFeedData A

 ------------------Only For One Day Comment at the time of Month End

--Inner Join #ProvisionChange B ON A.AccountID=B.AccountID

 ----------------------------

 where A.SourceAlt_Key=1
 and A.EffectiveFromTimeKey<=@TIMEKEY and A.EffectiveToTimeKey >=@TIMEKEY

-------------------------
 
 UPDATE PRO.ReverseFeed_ProcessMonitor SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE IdentityKey = (SELECT IDENT_CURRENT('PRO.ReverseFeed_ProcessMonitor')) AND  TIMEKEY=@TIMEKEY AND DESCRIPTION='FinacleInsertQueryofAccountProvisionSecured'

 
 End
 */
GO