SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



/*================================================
	AUTHER : SUNIL NARSING
	CREATE DATE : 02-01-2020
	MODIFY DATE : 02-01-2020
	DESCRIPTION : ValidationCheckNPAMovement
	
=============================================================*/

CREATE PROCEDURE [dbo].[ValidationCheckNPAMovement]
--Declare
@CurrentMonthEndTIMEKEY INT --=25536
--,@NPAMOVE varchar(5)='M'             ------It comes from Table
,@MovementTypeFlag As Char(1)
AS
BEGIN


/*------------- ValidationCheckNPAMovement -----------------*/

Declare @ProcessDate As Date,@MonthStartDate As Date,@MonthEndDate As Date

Set @MonthStartDate=(select MonthFirstDate from SysDataMatrix where TimeKey=@CurrentMonthEndTIMEKEY)   --@TIMEKEY    --

Set @MonthEndDate=(select MonthLastDate from SysDataMatrix where Timekey=@CurrentMonthEndTIMEKEY)

Set @ProcessDate= (select Cast(Date as Date) from SysDayMatrix where Timekey=@CurrentMonthEndTIMEKEY)

IF EXISTS (SELECT 1 FROM NPAMovement WHERE TimeKey=@CurrentMonthEndTIMEKEY )
BEGIN

Update A Set
--select AccountEntityId,MovementNature,

A.CheckIn_Flag= (Case When InitialNPABalance<0 Then 'Y'      ----------InitialNPABalance-------
						When InitialUnservicedInterest<0 Then 'Y'  ---InitialUnservicedInterest---
						When InitialUnservicedInterest>InitialNPABalance Then 'Y'  ---InitialUnservicedInterest > InitialNPABalance  ---
						When InitialGNPABalance<0 Then 'Y'		--------------------InitialGNPABalance ------------------
						When InitialProvision<0 Then 'Y'  ---InitialProvision---
						When InitialProvision>InitialGNPABalance Then 'Y'  --- InitialProvision > InitialGNPABalance  ---
						When InitialNNPABalance<0 Then 'Y'		--------------------InitialNNPABalance ------------------

						When FinalNPABalance<0 Then 'Y'      ----------FinalNPABalance-------
						When FinalUnservicedInterest<0 Then 'Y'  ---FinalUnservicedInterest---
						When FinalUnservicedInterest>FinalNPABalance Then 'Y'  ---FinalUnservicedInterest > FinalNPABalance  ---
						When FinalGNPABalance<0 Then 'Y'		--------------------FinalGNPABalance ------------------
						When FinalProvision<0 Then 'Y'  ---FinalProvision---
						When FinalProvision>FinalGNPABalance Then 'Y'  --- FinalProvision > FinalGNPABalance  ---
						When FinalNNPABalance<0 Then 'Y'		--------------------FinalNNPABalance ------------------

						When InitialGNPABalance-FinalGNPABalance>0 AND TotalAddition_GNPA <0 Then 'Y' --------TotalAddition_GNPA---------------
						When FinalGNPABalance-InitialGNPABalance>0 AND TotalReduction_GNPA <0 Then 'Y' --------TotalReduction_GNPA---------------
						When InitialUnservicedInterest-FinalUnservicedInterest>0 AND TotalAddition_UnservicedInterest <0 Then 'Y' --------TotalAddition_UnservicedInterest---------------
						When FinalUnservicedInterest-InitialUnservicedInterest>0 AND TotalReduction_UnservicedInterest <0 Then 'Y' --------TotalReduction_UnservicedInterest---------------
						When InitialProvision-FinalProvision>0 AND TotalAddition_Provision <0 Then 'Y' --------TotalAddition_Provision---------------
						When FinalProvision-InitialProvision>0 AND TotalReduction_Provision <0 Then 'Y' --------TotalReduction_Provision---------------

						------------ FreshNPA_Addition -------------
						When MovementNature in ('STD-ARCSale','STD-ARCSale-WriteOff','STD-NPA','STD-STD') AND FreshNPA_Addition<0 Then 'Y'
						When MovementNature Not in ('STD-ARCSale','STD-ARCSale-WriteOff','STD-NPA','STD-STD') AND FreshNPA_Addition<>0 Then 'Y'

						------------ ExistingNPA_Addition -------------
						When MovementNature in ('NPA-NPA') AND FinalGNPABalance-InitialGNPABalance>0 AND ExistingNPA_Addition<0 Then 'Y'
						--When MovementNature Not in ('NPA-NPA') AND ExistingNPA_Addition<>0 Then 'Y'
						When MovementNature in ('NPA-TransferIn') AND FinalGNPABalance-TransferIn_Balance>0 AND ExistingNPA_Addition<0 Then 'Y'
						When MovementNature Not in ('NPA-NPA','NPA-TransferIn') AND ExistingNPA_Addition<>0 Then 'Y'

						------------ ReductionDuetoUpgradeAmount -------------
						When MovementNature in ('NPA-STD','STD-STD')  AND ReductionDuetoUpgradeAmount<0 Then 'Y'
						When MovementNature Not in ('NPA-STD','STD-STD') AND ReductionDuetoUpgradeAmount<>0 Then 'Y'

						------------ ReductionDuetoRecovery_Arcs -------------
						When MovementNature in ('NPA-ARCSale') AND ReductionDuetoRecovery_Arcs>InitialGNPABalance Then 'Y'
						When MovementNature in ('STD-ARCSale','STD-ARCSale-WriteOff','NPA-ARCSale','NPA-ARCSale-Recovery'
												,'NPA-ARCSale-WriteOff','NPA-ARCSale-WriteOff-Recovery')  AND ReductionDuetoRecovery_Arcs<0 Then 'Y'
						When MovementNature Not in ('STD-ARCSale','STD-ARCSale-WriteOff','NPA-ARCSale','NPA-ARCSale-Recovery'
												,'NPA-ARCSale-WriteOff','NPA-ARCSale-WriteOff-Recovery') AND ReductionDuetoRecovery_Arcs<>0 Then 'Y'
						
						------------ ReductionDuetoWrite_OffAmount -------------
						When MovementNature in ('NPA-WriteOff') AND ReductionDuetoWrite_OffAmount>InitialGNPABalance Then 'Y'
						When MovementNature in ('STD-ARCSale-WriteOff','NPA-WriteOff-Recovery','NPA-ARCSale-WriteOff','NPA-ARCSale-WriteOff-Recovery','NPA-WriteOff')  
												AND ReductionDuetoWrite_OffAmount<0 Then 'Y'
						When MovementNature Not in ('STD-ARCSale-WriteOff','NPA-WriteOff-Recovery','NPA-ARCSale-WriteOff','NPA-ARCSale-WriteOff-Recovery','NPA-WriteOff') 
												AND ReductionDuetoWrite_OffAmount<>0 Then 'Y'
						
						------------ ReductionDuetoRecovery_ExistingNPA -------------
						When MovementNature in ('NPA-NPA','NPA-WriteOff-Recovery','NPA-ARCSale-Recovery','NPA-ARCSale-WriteOff-Recovery','NPA-Closed')  
												AND InitialGNPABalance-FinalGNPABalance>0 AND ReductionDuetoRecovery_ExistingNPA<0 Then 'Y'
						When MovementNature Not in ('NPA-NPA','NPA-WriteOff-Recovery','NPA-ARCSale-Recovery','NPA-ARCSale-WriteOff-Recovery','NPA-Closed') 
												AND ReductionDuetoRecovery_ExistingNPA<>0 Then 'Y'

						------------ NPA-TransferIn -------------
						When MovementNature in ('NPA-TransferIn')  AND TransferIn_Balance<0 Then 'Y'
						When MovementNature Not in ('NPA-TransferIn') AND TransferIn_Balance<>0 Then 'Y'

						------------ NPA-TransferOut -------------
						When MovementNature in ('NPA-TransferOut')  AND TransferOut_Balance<0 Then 'Y'
						When MovementNature Not in ('NPA-TransferOut') AND TransferOut_Balance<>0 Then 'Y'

						ELSE 'N'

					END),

A.CheckIn_Remark= (Case When InitialNPABalance<0 Then 'UnSuccesFull Due to -ve Balance InitialNPABalance'      ----------InitialNPABalance-------
						When InitialUnservicedInterest<0 Then 'UnSuccesFull Due to -ve Balance InitialUnservicedInterest'  ---InitialUnservicedInterest---
						When InitialUnservicedInterest>InitialNPABalance Then 'UnSuccesFull Due to More InitialUnservicedInterest than InitialNPABalance'  ---InitialUnservicedInterest > InitialNPABalance  ---
						When InitialGNPABalance<0 Then 'UnSuccesFull Due to -ve Balance InitialGNPABalance'		--------------------InitialGNPABalance ------------------
						When InitialProvision<0 Then 'UnSuccesFull Due to -ve Balance InitialProvision'  ---InitialProvision---
						When InitialProvision>InitialGNPABalance Then 'UnSuccesFull Due to More InitialProvision than InitialGNPABalance'  --- InitialProvision > InitialGNPABalance  ---
						When InitialNNPABalance<0 Then 'UnSuccesFull Due to -ve Balance InitialNNPABalance'		--------------------InitialNNPABalance ------------------

						When FinalNPABalance<0 Then 'UnSuccesFull Due to -ve Balance FinalNPABalance'      ----------FinalNPABalance-------
						When FinalUnservicedInterest<0 Then 'UnSuccesFull Due to -ve Balance FinalUnservicedInterest'  ---FinalUnservicedInterest---
						When FinalUnservicedInterest>FinalNPABalance Then 'UnSuccesFull Due to More FinalUnservicedInterest than FinalNPABalance'  ---FinalUnservicedInterest > FinalNPABalance  ---
						When FinalGNPABalance<0 Then 'UnSuccesFull Due to -ve Balance FinalGNPABalance'		--------------------FinalGNPABalance ------------------
						When FinalProvision<0 Then 'UnSuccesFull Due to -ve Balance FinalProvision'  ---FinalProvision---
						When FinalProvision>FinalGNPABalance Then 'UnSuccesFull Due to More FinalProvision than FinalGNPABalance'  --- FinalProvision > FinalGNPABalance  ---
						When FinalNNPABalance<0 Then 'UnSuccesFull Due to -ve Balance FinalNNPABalance'		--------------------FinalNNPABalance ------------------

						When InitialGNPABalance-FinalGNPABalance>0 AND TotalAddition_GNPA <0 Then 'UnSuccesFull Due to mismatch Balance TotalAddition_GNPA' --------TotalAddition_GNPA---------------
						When FinalGNPABalance-InitialGNPABalance>0 AND TotalReduction_GNPA <0 Then 'UnSuccesFull Due to mismatch Balance TotalReduction_GNPA' --------TotalReduction_GNPA---------------
						When InitialUnservicedInterest-FinalUnservicedInterest>0 AND TotalAddition_UnservicedInterest <0 Then 'UnSuccesFull Due to mismatch Balance TotalAddition_UnservicedInterest' --------TotalAddition_UnservicedInterest---------------
						When FinalUnservicedInterest-InitialUnservicedInterest>0 AND TotalReduction_UnservicedInterest <0 Then 'UnSuccesFull Due to mismatch Balance TotalReduction_UnservicedInterest' --------TotalReduction_UnservicedInterest---------------
						When InitialProvision-FinalProvision>0 AND TotalAddition_Provision <0 Then 'UnSuccesFull Due to mismatch Balance TotalAddition_Provision' --------TotalAddition_Provision---------------
						When FinalProvision-InitialProvision>0 AND TotalReduction_Provision <0 Then 'UnSuccesFull Due to mismatch Balance TotalReduction_Provision' --------TotalReduction_Provision---------------

						------------ FreshNPA_Addition -------------
						When MovementNature in ('STD-ARCSale','STD-ARCSale-WriteOff','STD-NPA','STD-STD') AND FreshNPA_Addition<0 Then 'UnSuccesFull Due to mismatch Balance FreshNPA_Addition'
						When MovementNature Not in ('STD-ARCSale','STD-ARCSale-WriteOff','STD-NPA','STD-STD') AND FreshNPA_Addition<>0 Then 'UnSuccesFull Due to Balance FreshNPA_Addition in Wrong Movement nature'
						
						------------ ExistingNPA_Addition -------------
						When MovementNature in ('NPA-NPA') AND FinalGNPABalance-InitialGNPABalance>0 AND ExistingNPA_Addition<0 Then 'UnSuccesFull Due to mismatch Balance ExistingNPA_Addition'
						--When MovementNature Not in ('NPA-NPA') AND ExistingNPA_Addition<>0 Then 'UnSuccesFull Due to Balance ExistingNPA_Addition in Wrong Movement nature'
						When MovementNature in ('NPA-TransferIn') AND FinalGNPABalance-TransferIn_Balance>0 AND ExistingNPA_Addition<0 Then 'UnSuccesFull Due to mismatch Balance ExistingNPA_Addition'
						When MovementNature Not in ('NPA-NPA','NPA-TransferIn') AND ExistingNPA_Addition<>0 Then 'UnSuccesFull Due to Balance ExistingNPA_Addition in Wrong Movement nature'

						------------ ReductionDuetoUpgradeAmount -------------
						When MovementNature in ('NPA-STD','STD-STD')  AND ReductionDuetoUpgradeAmount<0 Then 'UnSuccesFull Due to mismatch Balance ReductionDuetoUpgradeAmount'
						When MovementNature Not in ('NPA-STD','STD-STD') AND ReductionDuetoUpgradeAmount<>0 Then 'UnSuccesFull Due to Balance ReductionDuetoUpgradeAmount in Wrong Movement nature'

						------------ ReductionDuetoRecovery_Arcs -------------
						When MovementNature in ('NPA-ARCSale') AND ReductionDuetoRecovery_Arcs>InitialGNPABalance Then 'UnSuccesFull Due to More ARC Sale than GNPA Balance'
						When MovementNature in ('STD-ARCSale','STD-ARCSale-WriteOff','NPA-ARCSale','NPA-ARCSale-Recovery'
												,'NPA-ARCSale-WriteOff','NPA-ARCSale-WriteOff-Recovery')  AND ReductionDuetoRecovery_Arcs<0 Then 'UnSuccesFull Due to mismatch Balance ReductionDuetoRecovery_Arcs'
						When MovementNature Not in ('STD-ARCSale','STD-ARCSale-WriteOff','NPA-ARCSale','NPA-ARCSale-Recovery'
												,'NPA-ARCSale-WriteOff','NPA-ARCSale-WriteOff-Recovery') AND ReductionDuetoRecovery_Arcs<>0 Then 'UnSuccesFull Due to Balance ReductionDuetoRecovery_Arcs in Wrong Movement nature'
						
						------------ ReductionDuetoWrite_OffAmount -------------
						When MovementNature in ('NPA-WriteOff') AND ReductionDuetoWrite_OffAmount>InitialGNPABalance Then 'UnSuccesFull Due to More WriteOFF than GNPA Balance'
						When MovementNature in ('STD-ARCSale-WriteOff','NPA-WriteOff-Recovery','NPA-ARCSale-WriteOff','NPA-ARCSale-WriteOff-Recovery','NPA-WriteOff')  
												AND ReductionDuetoWrite_OffAmount<0 Then 'UnSuccesFull Due to mismatch Balance ReductionDuetoWrite_OffAmount'
						When MovementNature Not in ('STD-ARCSale-WriteOff','NPA-WriteOff-Recovery','NPA-ARCSale-WriteOff','NPA-ARCSale-WriteOff-Recovery','NPA-WriteOff') 
												AND ReductionDuetoWrite_OffAmount<>0 Then 'UnSuccesFull Due to Balance ReductionDuetoWrite_OffAmount in Wrong Movement nature'
						
						------------ ReductionDuetoRecovery_ExistingNPA -------------
						When MovementNature in ('NPA-NPA','NPA-WriteOff-Recovery','NPA-ARCSale-Recovery','NPA-ARCSale-WriteOff-Recovery','NPA-Closed')  
												AND InitialGNPABalance-FinalGNPABalance>0 AND ReductionDuetoRecovery_ExistingNPA<0 Then 'UnSuccesFull Due to mismatch Balance ReductionDuetoRecovery_ExistingNPA'
						When MovementNature Not in ('NPA-NPA','NPA-WriteOff-Recovery','NPA-ARCSale-Recovery','NPA-ARCSale-WriteOff-Recovery','NPA-Closed') 
												AND ReductionDuetoRecovery_ExistingNPA<>0 Then 'UnSuccesFull Due to Balance ReductionDuetoRecovery_ExistingNPA in Wrong Movement nature'

						------------ NPA-TransferIn -------------
						When MovementNature in ('NPA-TransferIn')  AND TransferIn_Balance<0 Then 'UnSuccesFull Due to mismatch Balance TransferIn_Balance'
						When MovementNature Not in ('NPA-TransferIn') AND TransferIn_Balance<>0 Then 'UnSuccesFull Due to Balance TransferIn_Balance in Wrong Movement nature'

						------------ NPA-TransferOut -------------
						When MovementNature in ('NPA-TransferOut')  AND TransferOut_Balance<0 Then 'UnSuccesFull Due to mismatch Balance TransferOut_Balance'
						When MovementNature Not in ('NPA-TransferOut') AND TransferOut_Balance<>0 Then 'UnSuccesFull Due to Balance TransferOut_Balance in Wrong Movement nature'

						ELSE 'SUCESSFULL NPA MOVEMENT'

					END) 	


 From NPAMovement A Where A.TimeKey=@CurrentMonthEndTIMEKEY
 And A.Movement_Flag=@MovementTypeFlag

 END

 END
GO