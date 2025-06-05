SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



/*================================================
	AUTHER : SUNIL NARSING
	CREATE DATE : 02-01-2020
	MODIFY DATE : 02-01-2020
	DESCRIPTION : UpdateWriteOffData
	
=============================================================*/

CREATE PROCEDURE [dbo].[UpdateWriteOffData]
--Declare
@CurrentMonthEndTIMEKEY INT --=25536
--,@NPAMOVE varchar(5)='M'             ------It comes from Table
,@MovementTypeFlag As Char(1)
AS
BEGIN


/*------------- Update WriteOff Data -----------------*/

Declare @ProcessDate As Date,@MonthStartDate As Date,@MonthEndDate As Date

Set @MonthStartDate=(select MonthFirstDate from SysDataMatrix where TimeKey=@CurrentMonthEndTIMEKEY)   --@TIMEKEY    --

Set @MonthEndDate=(select MonthLastDate from SysDataMatrix where Timekey=@CurrentMonthEndTIMEKEY)

Set @ProcessDate= (select Cast(Date as Date) from SysDayMatrix where Timekey=@CurrentMonthEndTIMEKEY)

IF EXISTS (SELECT 1 FROM NPAMovement WHERE TimeKey=@CurrentMonthEndTIMEKEY )
BEGIN

Update A Set A.WriteOffFlag='Y'
			,A.ReductionDuetoWrite_OffAmount=(Case When A.InitialAssetClassAlt_Key<>1 Then
												(Case When A.InitialGNPABalance<B.WriteOffAmount Then A.FinalGNPABalance
													--When A.FinalGNPABalance-B.InttWriteOffAmount=0 Then A.FinalGNPABalance
													Else B.WriteOffAmount End)
												When A.InitialAssetClassAlt_Key=1 Then B.WriteOffAmount 
												END)
			,A.ReductionDuetoRecovery_ExistingNPA=(Case When A.InitialGNPABalance<B.WriteOffAmount Then A.ReductionDuetoRecovery_ExistingNPA-A.FinalGNPABalance
													Else A.ReductionDuetoRecovery_ExistingNPA-B.WriteOffAmount End)
			,A.FreshNPA_Addition=(Case When A.InitialAssetClassAlt_Key=1 Then B.WriteOffAmount Else 0 End)
--Select A.CustomerAcid,A.ReductionDuetoWrite_OffAmount,A.WritoffFlag,B.InttWriteOffAmount,A.FinalGNPABalance,A.ReductionDuetoRecovery_ExistingNPA 
from NPAMovement A
INNER JOIN PRO.AccountCal_Hist B ON A.CustomerAcid=B.CustomerAcID
AND B.EffectiveFromTimeKey<=@CurrentMonthEndTIMEKEY
AND B.EffectiveToTimeKey>=@CurrentMonthEndTIMEKEY
AND B.WriteOffAmount>0
--(Select CustomerAcid,Sum(InttWriteOffAmount)InttWriteOffAmount From [DataUpload].[WriteOffAccountsDataUpload]
--Where WriteOffDate Between @MonthStartDate and @MonthEndDate
--Group By CustomerAcid ) B ON A.CustomerAcid=B.CustomerAcID
Where A.Timekey=@CurrentMonthEndTIMEKEY
And A.Movement_Flag=@MovementTypeFlag

--AND B.EffectiveFromTimeKey<=@CurrentMonthEndTIMEKEY AND B.EffectiveToTimeKey>=@CurrentMonthEndTIMEKEY



/*---------------- Movement Nature --------------*/


Update A Set MoveMentNature =(Case When InitialAssetClassAlt_Key=1 And WriteOffFlag='Y' And ISNULL(ReductionDuetoRecovery_ExistingNPA,0)>0 Then 'STD-WriteOff-Recovery'
									When InitialAssetClassAlt_Key=1 And WriteOffFlag='Y' Then 'STD-WriteOff'
									When InitialAssetClassAlt_Key<>1 And WriteOffFlag='Y' And ISNULL(ReductionDuetoRecovery_ExistingNPA,0)>0 Then 'NPA-WriteOff-Recovery'
									When InitialAssetClassAlt_Key<>1 And WriteOffFlag='Y' Then 'NPA-WriteOff'
												END)
from NPAMovement A
--INNER JOIN [DataUpload].[WriteOffAccountsDataUpload] B ON A.CustomerAcid=B.CustomerAcID
Where A.Timekey=@CurrentMonthEndTIMEKEY
AND A.WriteOffFlag='Y'
And A.Movement_Flag=@MovementTypeFlag
--AND B.WriteOffDate Between @MonthStartDate and @MonthEndDate
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
--INNER JOIN [DataUpload].[WriteOffAccountsDataUpload] B ON A.CustomerAcid=B.CustomerAcID
Where A.Timekey=@CurrentMonthEndTIMEKEY
AND A.WriteOffFlag='Y'
And A.Movement_Flag=@MovementTypeFlag
--AND B.WriteOffDate Between @MonthStartDate and @MonthEndDate
--AND B.EffectiveFromTimeKey<=@CurrentMonthEndTIMEKEY AND B.EffectiveToTimeKey>=@CurrentMonthEndTIMEKEY


END

END
GO