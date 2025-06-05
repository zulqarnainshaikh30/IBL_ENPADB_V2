SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



/*================================================
	AUTHER : SUNIL NARSING
	CREATE DATE : 02-01-2020
	MODIFY DATE : 02-01-2020
	DESCRIPTION : UpdateARCSaleData
	
=============================================================*/

CREATE PROCEDURE [dbo].[UpdateARCSaleData]
--Declare
@CurrentMonthEndTIMEKEY INT --=25536
--,@NPAMOVE varchar(5)='M'             ------It comes from Table
,@MovementTypeFlag As Char(1)
AS
BEGIN


/*------------- Update ARCSale Data -----------------*/

Declare @ProcessDate As Date,@MonthStartDate As Date,@MonthEndDate As Date

Set @MonthStartDate=(select MonthFirstDate from SysDataMatrix where TimeKey=@CurrentMonthEndTIMEKEY)   --@TIMEKEY    --

Set @MonthEndDate=(select MonthLastDate from SysDataMatrix where Timekey=@CurrentMonthEndTIMEKEY)

Set @ProcessDate= (select Cast(Date as Date) from SysDayMatrix where Timekey=@CurrentMonthEndTIMEKEY)

IF EXISTS (SELECT 1 FROM NPAMovement WHERE TimeKey=@CurrentMonthEndTIMEKEY )
BEGIN

Update A Set A.ARCSaleFlag='Y'
			,A.ReductionDuetoRecovery_Arcs=(Case When A.InitialAssetClassAlt_Key<>1 Then
												(Case When A.InitialGNPABalance<B.NPAConsideration Then A.FinalGNPABalance
													--When A.FinalGNPABalance-B.NPAConsideration=0 Then A.FinalGNPABalance
													Else B.NPAConsideration End)
												When A.InitialAssetClassAlt_Key=1 Then B.NPAConsideration
											End)

			,A.FreshNPA_Addition=(Case When A.InitialAssetClassAlt_Key=1 Then (B.NPAConsideration+ISNULL(B.WriteOffAmount,0)) Else 0 End)
			,A.ReductionDuetoWrite_OffAmount=B.WriteOffAmount
			

--Select A.CustomerAcid,A.ReductionDuetoWrite_OffAmount,A.WritoffFlag,B.InttWriteOffAmount,A.FinalGNPABalance,A.ReductionDuetoRecovery_ExistingNPA 
from NPAMovement A
INNER JOIN (Select CustomerAcid,Sum(NPAConsideration)NPAConsideration,SUM(SaleConsideration)SaleConsideration,Sum(IntConsideration)IntConsideration
,Sum(WriteOffAmount)WriteOffAmount From [DataUpload].[ARCAccountsDataUpload] 
Where ARCDate Between @MonthStartDate and @MonthEndDate
Group By CustomerAcid)B ON A.CustomerAcid=B.CustomerAcID
--LEFT JOIN [DataUpload].[WriteOffAccountsDataUpload] C ON C.CustomerAcid=B.CustomerAcID
Where A.Timekey=@CurrentMonthEndTIMEKEY
And A.Movement_Flag=@MovementTypeFlag

--AND B.EffectiveFromTimeKey<=@CurrentMonthEndTIMEKEY AND B.EffectiveToTimeKey>=@CurrentMonthEndTIMEKEY


Update A Set A.ReductionDuetoRecovery_ExistingNPA=(Case When A.InitialAssetClassAlt_Key<>1 Then
													 (Case When A.InitialGNPABalance<(B.NPAConsideration +ISNULL(B.WriteOffAmount,0))
															Then A.ReductionDuetoRecovery_ExistingNPA-A.FinalGNPABalance
																Else A.ReductionDuetoRecovery_ExistingNPA-(B.NPAConsideration+ISNULL(B.WriteOffAmount,0)) 
														End)
														When A.InitialAssetClassAlt_Key=1 Then A.FreshNPA_Addition-(A.ReductionDuetoRecovery_Arcs+ISNULL(A.ReductionDuetoWrite_OffAmount,0))
													END)
			--,A.FinalUnservicedInterest=B.IntConsideration

--Select A.CustomerAcid,A.ReductionDuetoWrite_OffAmount,A.WritoffFlag,B.InttWriteOffAmount,A.FinalGNPABalance,A.ReductionDuetoRecovery_ExistingNPA 
from NPAMovement A
INNER JOIN [DataUpload].[ARCAccountsDataUpload] B ON A.CustomerAcid=B.CustomerAcID
LEFT JOIN [DataUpload].[WriteOffAccountsDataUpload] C ON C.CustomerAcid=B.CustomerAcID
Where A.Timekey=@CurrentMonthEndTIMEKEY
AND B.ARCDate Between @MonthStartDate and @MonthEndDate
And A.Movement_Flag=@MovementTypeFlag


/*---------------- Movement Nature --------------*/


Update A Set MoveMentNature =(Case When InitialAssetClassAlt_Key=1 And ARCSaleFlag='Y' AND ReductionDuetoWrite_OffAmount>0 AND ReductionDuetoRecovery_ExistingNPA=0 Then 'STD-ARCSale-WriteOff'
									When InitialAssetClassAlt_Key=1 And ARCSaleFlag='Y' AND ReductionDuetoWrite_OffAmount=0 AND ReductionDuetoRecovery_ExistingNPA>0 Then 'STD-ARCSale-Recovery'
									When InitialAssetClassAlt_Key=1 And ARCSaleFlag='Y' AND ReductionDuetoWrite_OffAmount>0 AND ReductionDuetoRecovery_ExistingNPA>0 Then 'STD-ARCSale-WriteOff-Recovery'
									When InitialAssetClassAlt_Key=1 And ARCSaleFlag='Y' Then 'STD-ARCSale'
									When InitialAssetClassAlt_Key<>1 And ARCSaleFlag='Y' AND ReductionDuetoWrite_OffAmount>0 AND ReductionDuetoRecovery_ExistingNPA=0 Then 'NPA-ARCSale-WriteOff'
									When InitialAssetClassAlt_Key<>1 And ARCSaleFlag='Y' AND ReductionDuetoWrite_OffAmount=0 AND ReductionDuetoRecovery_ExistingNPA>0 Then 'NPA-ARCSale-Recovery'
									When InitialAssetClassAlt_Key<>1 And ARCSaleFlag='Y' AND ReductionDuetoWrite_OffAmount>0 AND ReductionDuetoRecovery_ExistingNPA>0 Then 'NPA-ARCSale-WriteOff-Recovery'
									When InitialAssetClassAlt_Key<>1 And ARCSaleFlag='Y' Then 'NPA-ARCSale'
												END)
from NPAMovement A
INNER JOIN [DataUpload].[ARCAccountsDataUpload] B ON A.CustomerAcid=B.CustomerAcID
Where A.Timekey=@CurrentMonthEndTIMEKEY
AND B.ARCDate Between @MonthStartDate and @MonthEndDate
And A.Movement_Flag=@MovementTypeFlag
--AND B.EffectiveFromTimeKey<=@CurrentMonthEndTIMEKEY AND B.EffectiveToTimeKey>=@CurrentMonthEndTIMEKEY


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
from NPAMovement A
INNER JOIN [DataUpload].[ARCAccountsDataUpload] B ON A.CustomerAcid=B.CustomerAcID
Where A.Timekey=@CurrentMonthEndTIMEKEY
AND B.ARCDate Between @MonthStartDate and @MonthEndDate
And A.Movement_Flag=@MovementTypeFlag
--AND B.EffectiveFromTimeKey<=@CurrentMonthEndTIMEKEY AND B.EffectiveToTimeKey>=@CurrentMonthEndTIMEKEY


END

END
GO