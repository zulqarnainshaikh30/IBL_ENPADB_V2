SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



/*================================================
	AUTHER : SUNIL NARSING
	CREATE DATE : 02-01-2020
	MODIFY DATE : 02-01-2020
	DESCRIPTION : UpdateMovementData
	
=============================================================*/

CREATE PROCEDURE [dbo].[UpdateMovementData]
--Declare
@CurrentMonthEndTIMEKEY INT --=25536
--,@NPAMOVE varchar(5)='M' 
,@MovementTypeFlag As Char(1) 
AS
BEGIN

/*------------- Update Movement Data -----------------*/

Declare @ProcessDate As Date

--Set @CurrentMonthEndTIMEKEY= @TIMEKEY    --(select TimeKey from SysDayMatrix where date='2019-10-31')

--Set @PrevTimeKey=(select LastMonthDateKey from SysDayMatrix where Timekey=@CurrentMonthEndTIMEKEY)

Set @ProcessDate= (select Cast(Date as Date) from SysDayMatrix where Timekey=@CurrentMonthEndTIMEKEY)

IF EXISTS (SELECT 1 FROM NPAMovement WHERE TimeKey=@CurrentMonthEndTIMEKEY )
BEGIN

/*
/*-------------- Update Initial GNPA Balance --------------------*/

Update NPAMovement 
Set InitialGNPABalance=(Case When InitialNPABalance-InitialUnservicedInterest <0 Then 0 Else InitialNPABalance-InitialUnservicedInterest End)
Where Timekey=@CurrentMonthEndTIMEKEY 

/*-------------- Update Initial NNPA Balance --------------------*/

Update NPAMovement 
Set InitialNNPABalance=(Case When InitialGNPABalance-InitialProvision <0 Then 0 Else InitialGNPABalance-InitialProvision End)
Where Timekey=@CurrentMonthEndTIMEKEY 

/*-------------- Update Final GNPA Balance --------------------*/

Update NPAMovement 
Set FinalGNPABalance=(Case When FinalNPABalance-FinalUnservicedInterest<0 Then 0 Else FinalNPABalance-FinalUnservicedInterest End)
Where Timekey=@CurrentMonthEndTIMEKEY 

/*-------------- Update Final NNPA Balance --------------------*/

Update NPAMovement 
Set FinalNNPABalance=(Case When FinalGNPABalance-FinalProvision <0 Then 0 Else FinalGNPABalance-FinalProvision End)
Where Timekey=@CurrentMonthEndTIMEKEY

*/

/*------------ ExistingNPA_Addition ----------------------*/

Update NPAMovement 
Set ExistingNPA_Addition=(Case When MovementNature in ('NPA-NPA') AND FinalGNPABalance-InitialGNPABalance>0
									Then FinalGNPABalance-InitialGNPABalance
							--		(Case When FinalGNPABalance-InitialGNPABalance<0 Then 0
							--Else FinalGNPABalance-InitialGNPABalance End )
							Else 0 
							End)
Where Timekey=@CurrentMonthEndTIMEKEY
And Movement_Flag=@MovementTypeFlag


/*------------ Update FreshNPA_Addition ------------------*/

Update NPAMovement 
Set FreshNPA_Addition=(Case When MovementNature in ('STD-NPA','STD-OTSWriteOff','STD-ATCSale') AND FinalGNPABalance-InitialGNPABalance>0
						Then FinalGNPABalance-InitialGNPABalance
						--(Case When (FinalGNPABalance-InitialGNPABalance)<0 Then 0
						--		Else FinalGNPABalance-InitialGNPABalance End) 
								When MovementNature in ('STD-STD') Then ReductionDuetoRecovery_Arcs+ReductionDuetoWrite_OffAmount
								Else 0 End)
Where Timekey=@CurrentMonthEndTIMEKEY 
And Movement_Flag=@MovementTypeFlag

/*------------ ReductionDuetoUpgradeAmount ------------------*/

Update NPAMovement 
Set ReductionDuetoUpgradeAmount=(Case When MovementNature in ('NPA-STD') AND InitialGNPABalance-FinalGNPABalance>0
									Then InitialGNPABalance-FinalGNPABalance
									--(Case When (InitialGNPABalance-FinalGNPABalance)<0 Then 0
									--			Else InitialGNPABalance-FinalGNPABalance 
									--		End) 
									When MovementNature in ('STD-STD') Then
											FreshNPA_Addition
										Else 0
								 End)
Where Timekey=@CurrentMonthEndTIMEKEY
And Movement_Flag=@MovementTypeFlag 

/*------------ ReductionDuetoRecovery_ExistingNPA ------------------*/

Update NPAMovement 
Set ReductionDuetoRecovery_ExistingNPA=(Case When MovementNature in ('NPA-NPA','NPA-WriteOff','NPA-OTSWriteOff','NPA-NPA_Retail','NPA-ARCSale','NPA-Closed')
									AND InitialGNPABalance-FinalGNPABalance>0 Then InitialGNPABalance-FinalGNPABalance
									--(Case When (InitialGNPABalance-FinalGNPABalance)<0 Then 0
									--			Else InitialGNPABalance-FinalGNPABalance  
									--		End) 
											Else 0
										End)
Where Timekey=@CurrentMonthEndTIMEKEY 
And Movement_Flag=@MovementTypeFlag


/*------------ Update TotalReduction_GNPA,TotalReduction_Provision, TotalReduction_UnservicedInterest ------------------*/

Update NPAMovement Set TotalReduction_GNPA=(Case When InitialGNPABalance-FinalGNPABalance<0 Then 0 Else InitialGNPABalance-FinalGNPABalance End)
							,TotalReduction_Provision=(Case When InitialProvision-FinalProvision<0 Then 0 Else InitialProvision-FinalProvision End)
							,TotalReduction_UnservicedInterest=(Case When InitialUnservicedInterest-FinalUnservicedInterest<0 Then 0 Else InitialUnservicedInterest-FinalUnservicedInterest End)
Where Timekey=@CurrentMonthEndTIMEKEY 


/*------------ Update TotalAddition_GNPA,TotalAddition_Provision TotalAddition_UnservicedInterest ------------------*/

Update NPAMovement Set TotalAddition_GNPA=(Case When FinalGNPABalance-InitialGNPABalance<0 Then 0 Else FinalGNPABalance-InitialGNPABalance End)
							,TotalAddition_Provision=(Case When FinalProvision-InitialProvision<0 Then 0 Else FinalProvision-InitialProvision End)
							,TotalAddition_UnservicedInterest=(Case When FinalUnservicedInterest-InitialUnservicedInterest<0 Then 0 Else FinalUnservicedInterest-InitialUnservicedInterest End)
Where Timekey=@CurrentMonthEndTIMEKEY 
And Movement_Flag=@MovementTypeFlag

/*---------------------MovementStatus,NPAReason------------------------*/

Update NPAMovement Set MovementStatus=(Case When MovementNature='STD-NPA' Then 'New NPA' 
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
Where Timekey=@CurrentMonthEndTIMEKEY 
And Movement_Flag=@MovementTypeFlag

/*------------------------------End ------------------------------*/

END

END
GO