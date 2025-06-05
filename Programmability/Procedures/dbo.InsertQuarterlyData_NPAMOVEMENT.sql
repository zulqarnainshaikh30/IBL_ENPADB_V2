SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


/*================================================
	AUTHER : SUNIL NARSING
	CREATE DATE : 28-01-2020
	MODIFY DATE : 28-01-2020
	DESCRIPTION : InsertQuarterlyData_NPAMOVEMEN
	EXEC InsertQuarterlyData_NPAMOVEMENT '25567','Q'
=============================================================*/

CREATE PROCEDURE [dbo].[InsertQuarterlyData_NPAMOVEMENT]
--Declare
@CurrentMonthEndTIMEKEY INT   --=25506
,@MovementTypeFlag As Char(1)
AS
BEGIN

--Declare @CurrentMonthEndTIMEKEY as int =(select CurQtrDateKey from SysDayMatrix where TimeKey=25567)
Declare @LastQuartrMonthKey as int=(select LastQtrDateKey from SysDayMatrix where TimeKey=@CurrentMonthEndTIMEKEY)
Declare @QtrFrstMonthEndKey as int=(select TimeKey from SysDayMatrix 
									where TimeKey=(select LastMonthDateKey from SysDayMatrix
												where timekey =(select LastMonthDateKey from SysDayMatrix
																where TimeKey=@CurrentMonthEndTIMEKEY
																)
												) 
									)
--Select @QtrFrstMonthEndKey


IF Object_Id('Tempdb..#Temp1') IS NOT NULL
Drop table #Temp1

select CustomerAcid,min(timekey)mintimekey,max(timekey)maxtimekey into #Temp1 from NPAMovement where  timekey between @QtrFrstMonthEndKey and @CurrentMonthEndTIMEKEY 
AND Movement_Flag='M' ---- and CheckIn_Flag='N' 
Group by CustomerAcid


--Select * from #Temp1 order by 2,1

IF Object_Id('Tempdb..#NPAMovement_Q') IS NOT NULL
Drop table #NPAMovement_Q

Select * into #NPAMovement_Q from NPAMovement Where 1=2


Insert into #NPAMovement_Q
(NPAProcessingDate,Timekey,SourceAlt_Key,BranchCode,CustomerID,CustomerEntityID,CustomerAcid,AccountEntityID,CustomerName
,InitialAssetClassAlt_Key,InitialNPABalance,InitialUnservicedInterest,InitialGNPABalance,InitialProvision,InitialNNPABalance
,FinalAssetClassAlt_Key,FinalNPABalance,FinalUnservicedInterest,FinalGNPABalance,FinalProvision,FinalNNPABalance,Movement_Flag
)

Select 
NPAProcessingDate,Timekey,SourceAlt_Key,BranchCode,CustomerID,CustomerEntityID,CustomerAcid,AccountEntityID,CustomerName
,Max(InitialAssetClassAlt_Key)InitialAssetClassAlt_Key,SUM(InitialNPABalance)InitialNPABalance,SUM(InitialUnservicedInterest)InitialUnservicedInterest
,Sum(InitialGNPABalance)InitialGNPABalance,Sum(InitialProvision)InitialProvision,Sum(InitialNNPABalance)InitialNNPABalance
,Max(FinalAssetClassAlt_Key)FinalAssetClassAlt_Key,Sum(FinalNPABalance)FinalNPABalance,Sum(FinalUnservicedInterest)FinalUnservicedInterest
,Sum(FinalGNPABalance)FinalGNPABalance,Sum(FinalProvision)FinalProvision,Sum(FinalNNPABalance)FinalNNPABalance,Movement_Flag

 From (
select 
Cast(GETDATE() as date) NPAProcessingDate,@CurrentMonthEndTIMEKEY Timekey,SourceAlt_Key,BranchCode,CustomerID,CustomerEntityID,A.CustomerAcid,AccountEntityID,CustomerName
--,InitialAssetClassAlt_Key,InitialNPABalance,InitialUnservicedInterest,InitialGNPABalance,InitialProvision,InitialNNPABalance
,(Case When B.mintimekey=@QtrFrstMonthEndKey THEN  InitialAssetClassAlt_Key Else 1 End)InitialAssetClassAlt_Key
,(Case When B.mintimekey=@QtrFrstMonthEndKey THEN  InitialNPABalance Else 0 End) InitialNPABalance
,(Case When B.mintimekey=@QtrFrstMonthEndKey THEN  InitialUnservicedInterest Else 0 End) InitialUnservicedInterest
,(Case When B.mintimekey=@QtrFrstMonthEndKey THEN  InitialGNPABalance Else 0 End) InitialGNPABalance
,(Case When B.mintimekey=@QtrFrstMonthEndKey THEN  InitialProvision Else 0 End) InitialProvision
,(Case When B.mintimekey=@QtrFrstMonthEndKey THEN  InitialNNPABalance Else 0 End)InitialNNPABalance
,0 FinalAssetClassAlt_Key,0 FinalNPABalance,0 FinalUnservicedInterest,0 FinalGNPABalance,0 FinalProvision,0 FinalNNPABalance,@MovementTypeFlag As Movement_Flag 
 from NPAMovement A
Inner Join #Temp1 B ON A.CustomerAcid=B.CustomerAcid
AND A.Timekey=B.mintimekey
AND A.Movement_Flag='M'

union all

select 
Cast(GETDATE() as date) NPAProcessingDate,@CurrentMonthEndTIMEKEY Timekey,SourceAlt_Key,BranchCode,CustomerID,CustomerEntityID,A.CustomerAcid,AccountEntityID,CustomerName
,0 InitialAssetClassAlt_Key,0 InitialNPABalance,0 InitialUnservicedInterest,0 InitialGNPABalance,0 InitialProvision,0 InitialNNPABalance
,(Case When B.maxtimekey=@CurrentMonthEndTIMEKEY THEN  FinalAssetClassAlt_Key Else 0 End)FinalAssetClassAlt_Key
,(Case When B.maxtimekey=@CurrentMonthEndTIMEKEY THEN  FinalNPABalance Else 0 End) FinalNPABalance
,(Case When B.maxtimekey=@CurrentMonthEndTIMEKEY THEN  FinalUnservicedInterest Else 0 End) FinalUnservicedInterest
,(Case When B.maxtimekey=@CurrentMonthEndTIMEKEY THEN  FinalGNPABalance Else 0 End) FinalGNPABalance
,(Case When B.maxtimekey=@CurrentMonthEndTIMEKEY THEN  FinalProvision Else 0 End) FinalProvision
,(Case When B.maxtimekey=@CurrentMonthEndTIMEKEY THEN  FinalNNPABalance Else 0 End)FinalNNPABalance
,@MovementTypeFlag As Movement_Flag
 from NPAMovement A
Inner Join #Temp1 B ON A.CustomerAcid=B.CustomerAcid
AND A.Timekey=B.maxtimekey
And A.Movement_Flag='M'
)A
GROUP BY NPAProcessingDate,Timekey,SourceAlt_Key,BranchCode,CustomerID,CustomerEntityID,CustomerAcid,AccountEntityID,CustomerName,Movement_Flag


Update A Set
--Select customeracid,InitialAssetClassAlt_Key,FinalAssetClassAlt_Key,

MovementNature=(Case When InitialAssetClassAlt_Key=1 and FinalAssetClassAlt_Key=0 THEN 'STD-Closed'
		When InitialAssetClassAlt_Key=1 and FinalAssetClassAlt_Key=1 THEN 'STD-STD'
		When InitialAssetClassAlt_Key=1 and FinalAssetClassAlt_Key not in (0,1) THEN 'STD-NPA'
		When InitialAssetClassAlt_Key not in (0,1) and FinalAssetClassAlt_Key=0 THEN 'NPA-Closed'
		When InitialAssetClassAlt_Key not in (0,1) and FinalAssetClassAlt_Key=1 THEN 'NPA-STD'
		When InitialAssetClassAlt_Key not in (0,1) and FinalAssetClassAlt_Key not in (0,1) THEN 'NPA-NPA' END)
 from #NPAMovement_Q A 
 Where A.Timekey=@CurrentMonthEndTIMEKEY
 And A.Movement_Flag='Q'


update A Set 
A.MovementStatus=B.MovementStatus	
,A.NPAReason=B.NPAReason	
,A.WriteOffFlag=B.WriteOffFlag
,A.ARCSaleFlag=B.ARCSaleFlag	
,A.TransferOut_Flag=B.TransferOut_Flag	
,A.TransferOut_Balance=B.TransferOut_Balance
,A.TransferIn_Flag=B.TransferIn_Flag
,A.TransferIn_Balance=B.TransferIn_Balance

from #NPAMovement_Q A
Inner join 
 (
select A.*
 from NPAMovement A
Inner Join #Temp1 B ON A.CustomerAcid=B.CustomerAcid
AND A.Timekey=B.maxtimekey
And A.Movement_Flag='M'
AND A.MovementNature IN ('NPA-WriteOff','NPA-WriteOff-Recovery','NPA-TransferIn','NPA-TransferOut','NPA-ARCSale','NPA-ARCSale-WriteOff-Recovery')
)B ON A.CustomerAcid=B.CustomerAcid
Where A.Timekey=@CurrentMonthEndTIMEKEY
And A.Movement_Flag='Q'

--------------------------------------
IF Object_Id('Tempdb..#ArcWriteOff') IS NOT NULL
Drop table #ArcWriteOff

Select CustomerAcid,
SUM(ExistingNPA_Addition)ExistingNPA_Addition,SUM(FreshNPA_Addition)FreshNPA_Addition,SUM(ReductionDuetoUpgradeAmount)ReductionDuetoUpgradeAmount,
SUM(ReductionDuetoWrite_OffAmount)ReductionDuetoWrite_OffAmount,SUM(ReductionDuetoRecovery_ExistingNPA)ReductionDuetoRecovery_ExistingNPA,
SUM(ReductionDuetoRecovery_Arcs)ReductionDuetoRecovery_Arcs,SUM(TotalAddition_GNPA)TotalAddition_GNPA,SUM(TotalReduction_GNPA)TotalReduction_GNPA,
SUM(TotalAddition_Provision)TotalAddition_Provision,SUM(TotalReduction_Provision)TotalReduction_Provision,
SUM(TotalAddition_UnservicedInterest)TotalAddition_UnservicedInterest,SUM(TotalReduction_UnservicedInterest)TotalReduction_UnservicedInterest
into #ArcWriteOff
 from NPAMovement Where Timekey between @QtrFrstMonthEndKey and @CurrentMonthEndTIMEKEY
AND CustomerAcid in (select distinct A.CustomerAcid
 from NPAMovement A
Inner Join #Temp1 B ON A.CustomerAcid=B.CustomerAcid
AND A.Timekey=B.maxtimekey
And A.Movement_Flag='M'
AND A.MovementNature IN ('NPA-WriteOff','NPA-WriteOff-Recovery','NPA-TransferIn','NPA-TransferOut','NPA-ARCSale','NPA-ARCSale-WriteOff-Recovery'))
And Movement_Flag='M'
GROUP BY CustomerAcid

update A Set 
 A.ExistingNPA_Addition=B.ExistingNPA_Addition
,A.FreshNPA_Addition=B.FreshNPA_Addition	
,A.ReductionDuetoUpgradeAmount=B.ReductionDuetoUpgradeAmount
,A.ReductionDuetoWrite_OffAmount=B.ReductionDuetoWrite_OffAmount	
,A.ReductionDuetoRecovery_ExistingNPA=B.ReductionDuetoRecovery_ExistingNPA	
,A.ReductionDuetoRecovery_Arcs=B.ReductionDuetoRecovery_Arcs
,A.TotalAddition_GNPA=B.TotalAddition_GNPA
,A.TotalReduction_GNPA=B.TotalReduction_GNPA	
,A.TotalAddition_Provision=B.TotalAddition_Provision	
,A.TotalReduction_Provision=B.TotalReduction_Provision	
,A.TotalAddition_UnservicedInterest=B.TotalAddition_UnservicedInterest
,A.TotalReduction_UnservicedInterest=B.TotalReduction_UnservicedInterest
from #NPAMovement_Q A
Inner join #ArcWriteOff B ON A.CustomerAcid=B.CustomerAcid
Where A.Timekey=@CurrentMonthEndTIMEKEY
And A.Movement_Flag='Q'
-------------------------------

update A set 
--select 
A.MovementNature= (Case when SUBSTRING(MovementNature,1,3)='STD' AND TransferIn_Flag='Y' THEN 'STD-TransferIn'
		when SUBSTRING(MovementNature,1,3)='NPA' AND TransferIn_Flag='Y' THEN 'NPA-TransferIn'
		when SUBSTRING(MovementNature,1,3)='STD' AND TransferOut_Flag='Y' THEN 'STD-TransferOut'
		when SUBSTRING(MovementNature,1,3)='NPA' AND TransferOut_Flag='Y' THEN 'NPA-TransferOut'
		when SUBSTRING(MovementNature,1,3)='STD' AND WriteOffFlag='Y' THEN 'STD-'+MovementStatus
		when SUBSTRING(MovementNature,1,3)='NPA' AND WriteOffFlag='Y' THEN 'NPA-'+MovementStatus
		when SUBSTRING(MovementNature,1,3)='STD' AND ARCSaleFlag='Y' THEN 'STD-'+MovementStatus
		when SUBSTRING(MovementNature,1,3)='NPA' AND ARCSaleFlag='Y' THEN 'NPA-'+MovementStatus
		END)
from #NPAMovement_Q A where A.MovementStatus is not null
and A.Timekey=@CurrentMonthEndTIMEKEY
And A.Movement_Flag='Q'


----------------ALL STD-NPA -------------------

IF Object_Id('Tempdb..#ALLSTDNPA') IS NOT NULL
Drop table #ALLSTDNPA

Select CustomerAcid,
SUM(ExistingNPA_Addition)ExistingNPA_Addition,SUM(FreshNPA_Addition)FreshNPA_Addition,SUM(ReductionDuetoUpgradeAmount)ReductionDuetoUpgradeAmount,
SUM(ReductionDuetoWrite_OffAmount)ReductionDuetoWrite_OffAmount,SUM(ReductionDuetoRecovery_ExistingNPA)ReductionDuetoRecovery_ExistingNPA,
SUM(ReductionDuetoRecovery_Arcs)ReductionDuetoRecovery_Arcs,SUM(TotalAddition_GNPA)TotalAddition_GNPA,SUM(TotalReduction_GNPA)TotalReduction_GNPA,
SUM(TotalAddition_Provision)TotalAddition_Provision,SUM(TotalReduction_Provision)TotalReduction_Provision,
SUM(TotalAddition_UnservicedInterest)TotalAddition_UnservicedInterest,SUM(TotalReduction_UnservicedInterest)TotalReduction_UnservicedInterest
into #ALLSTDNPA
 from NPAMovement Where Timekey between @QtrFrstMonthEndKey and @CurrentMonthEndTIMEKEY
AND CustomerAcid Not In (Select CustomerAcid From #NPAMovement_Q Where MovementStatus IS NOT NULL)
And Movement_Flag='M'
GROUP BY CustomerAcid

Update A Set 
--Select * 
A.ExistingNPA_Addition=B.ExistingNPA_Addition
,A.FreshNPA_Addition=B.FreshNPA_Addition
,A.ReductionDuetoUpgradeAmount=B.ReductionDuetoUpgradeAmount
,A.ReductionDuetoWrite_OffAmount=B.ReductionDuetoWrite_OffAmount
,A.ReductionDuetoRecovery_ExistingNPA=B.ReductionDuetoRecovery_ExistingNPA
,A.ReductionDuetoRecovery_Arcs=B.ReductionDuetoRecovery_Arcs
,A.TotalAddition_GNPA=B.TotalAddition_GNPA
,A.TotalReduction_GNPA=B.TotalReduction_GNPA
,A.TotalAddition_Provision=B.TotalAddition_Provision
,A.TotalReduction_Provision=B.TotalReduction_Provision
,A.TotalAddition_UnservicedInterest=B.TotalAddition_UnservicedInterest
,A.TotalReduction_UnservicedInterest=B.TotalReduction_UnservicedInterest
from #NPAMovement_Q A
Inner Join #ALLSTDNPA B ON A.CustomerAcid=B.CustomerAcid
Where A.Timekey=@CurrentMonthEndTIMEKEY
And A.Movement_Flag='Q'



/*---------------------MovementStatus,NPAReason------------------------*/

Update A Set MovementStatus=(Case When MovementNature='STD-NPA' Then 'New NPA' 
												 When MovementNature='NPA-NPA' Then 'Old NPA' 
												 When MovementNature='NPA-STD' Then 'Upgrade' 
												 When MovementNature='NPA-WriteOff' Then 'WriteOff' 
												 When MovementNature='NPA-NPA_Retail' Then 'Old NPA' 
												 When MovementNature='NPA-OTSWriteOff' Then 'OTSWriteOff' 
												 When MovementNature='STD-OTSWriteOff' Then 'OTSWriteOff' 
												 When MovementNature='STD-ARCSale' Then 'ARC Sale' 
												 When MovementNature='NPA-ARCSale' Then 'ARC Sale' 
												 When MovementNature='STD-STD' Then 'Upgrade' 
												 When MovementNature='NPA-Closed' Then 'Closed'
												 When MovementNature='STD-WriteOff' Then 'WriteOff'
												 When MovementNature='STD-Closed' Then 'Closed'
												 When MovementNature='STD-WriteOff-Recovery' Then 'WriteOff-Recovery'
												 When MovementNature='NPA-WriteOff-Recovery' Then 'WriteOff-Recovery'
												 When MovementNature='STD-ARCSale-WriteOff' Then 'ARCSale-WriteOff'
												 When MovementNature='STD-ARCSale-Recovery' Then 'ARCSale-Recovery'
												 When MovementNature='STD-ARCSale-WriteOff-Recovery' Then 'ARCSale-WriteOff-Recovery'
												 When MovementNature='NPA-ARCSale-WriteOff' Then 'ARCSale-WriteOff'
												 When MovementNature='NPA-ARCSale-Recovery' Then 'ARCSale-Recovery'
												 When MovementNature='NPA-ARCSale-WriteOff-Recovery' Then 'ARCSale-WriteOff-Recovery'
												 When MovementNature='STD-TransferOut' Then 'STD TransferOut'
												 When MovementNature='NPA-TransferOut' Then 'NPA TransferOut'
												 When MovementNature='STD-TransferIn' Then 'STD TransferIn'
												 When MovementNature='NPA-TransferIn' Then 'NPA TransferIn' 
											End)
							,NPAReason =(Case When MovementNature='STD-NPA' Then 'Std to NPA'
												When MovementNature='NPA-NPA' Then 'NPA to NPA'
												When MovementNature='NPA-STD' Then 'NPA to STD'
												When MovementNature='NPA-WriteOff' Then 'NPA to WriteOff'
												When MovementNature='NPA-NPA_Retail' Then 'NPA to NPA_Retail'
												When MovementNature='NPA-OTSWriteOff' Then 'NPA to OTSWriteOff'
												When MovementNature='STD-OTSWriteOff' Then 'STD to OTSWriteOff'
												When MovementNature='STD-ARCSale' Then 'STD to ARCSale'
												When MovementNature='NPA-ARCSale' Then 'NPA to ARCSale'
												When MovementNature='STD-STD' Then 'STD to STD'
												When MovementNature='NPA-Closed' Then 'NPA to Closed'
												When MovementNature='STD-WriteOff' Then 'STD to WriteOff'
												When MovementNature='STD-Closed' Then 'STD to Closed'
												When MovementNature='STD-WriteOff-Recovery' Then 'STD WriteOff-Recovery'
												When MovementNature='NPA-WriteOff-Recovery' Then 'NPA WriteOff-Recovery'
												When MovementNature='STD-ARCSale-WriteOff' Then 'STD ARCSale-WriteOff'
												When MovementNature='STD-ARCSale-Recovery' Then 'STD ARCSale-Recovery'
												When MovementNature='STD-ARCSale-WriteOff-Recovery' Then 'STD ARCSale-WriteOff-Recovery'
												When MovementNature='NPA-ARCSale-WriteOff' Then 'NPA ARCSale-WriteOff'
												When MovementNature='NPA-ARCSale-Recovery' Then 'NPA ARCSale-Recovery'
												When MovementNature='NPA-ARCSale-WriteOff-Recovery' Then 'NPA ARCSale-WriteOff-Recovery'
												When MovementNature='STD-TransferOut' Then 'STD to TransferOut'
												When MovementNature='NPA-TransferOut' Then 'NPA to TransferOut'
												When MovementNature='STD-TransferIn' Then 'STD TransferIn'
												When MovementNature='NPA-TransferIn' Then 'NPA TransferIn' 
												 
										End)
from #NPAMovement_Q A
Where A.Timekey=@CurrentMonthEndTIMEKEY
AND A.MovementStatus IS NULL
And A.Movement_Flag='Q'



-------------------Delete Data From PROVISION MOVEMENT IF IT PRESENT ------------

IF EXISTS (SELECT 1 FROM NPAMovement WHERE TimeKey=@CurrentMonthEndTIMEKEY And Movement_Flag=@MovementTypeFlag)
BEGIN

Delete from NPAMovement where Timekey=@CurrentMonthEndTIMEKEY And Movement_Flag=@MovementTypeFlag

END
-------------------------------------------------------------

------------------------Insert into Main Table --------------------

Insert into NPAMovement
Select * from #NPAMovement_Q where Timekey=@CurrentMonthEndTIMEKEY

-----------------END---------------------------------------
END
GO