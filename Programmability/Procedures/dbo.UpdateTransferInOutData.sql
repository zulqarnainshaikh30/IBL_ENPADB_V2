SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



/*================================================
	AUTHER : SUNIL NARSING
	CREATE DATE : 02-01-2020
	MODIFY DATE : 02-01-2020
	DESCRIPTION : UpdateTransferInOutData
	
=============================================================*/

CREATE PROCEDURE [dbo].[UpdateTransferInOutData]
--Declare
@CurrentMonthEndTIMEKEY INT --=25536
--,@NPAMOVE varchar(5)='M'             ------It comes from Table
,@MovementTypeFlag As Char(1)
AS
BEGIN


/*------------- Update TransferOut Data -----------------*/

Declare @ProcessDate As Date,@MonthStartDate As Date,@MonthEndDate As Date

Set @MonthStartDate=(select MonthFirstDate from SysDataMatrix where TimeKey=@CurrentMonthEndTIMEKEY)   --@TIMEKEY    --

Set @MonthEndDate=(select MonthLastDate from SysDataMatrix where Timekey=@CurrentMonthEndTIMEKEY)

Set @ProcessDate= (select Cast(Date as Date) from SysDayMatrix where Timekey=@CurrentMonthEndTIMEKEY)

IF EXISTS (SELECT 1 FROM NPAMovement WHERE TimeKey=@CurrentMonthEndTIMEKEY )
BEGIN

Update A Set A.TransferOut_Flag='Y'
			,A.TransferOut_Balance=ReductionDuetoRecovery_ExistingNPA
			
--Select A.CustomerAcid,A.ReductionDuetoWrite_OffAmount,A.WritoffFlag,B.InttWriteOffAmount,A.FinalGNPABalance,A.ReductionDuetoRecovery_ExistingNPA 
from NPAMovement A
INNER JOIN (Select TransferOutCustomerAcID,TransferOutAssetClassification,TransferOutBalance,TransferOutUnserviced_Interest,TransferOutDate,TransferOutProvision From DataUpload.TransferInOutDataUpload
Where TransferOutDate Between @MonthStartDate and @MonthEndDate
Group By TransferOutCustomerAcID,TransferOutAssetClassification,TransferOutBalance,TransferOutUnserviced_Interest,TransferOutDate,TransferOutProvision ) B ON A.CustomerAcid=B.TransferOutCustomerAcID
Where A.Timekey=@CurrentMonthEndTIMEKEY
And A.Movement_Flag=@MovementTypeFlag


Update A Set A.ReductionDuetoRecovery_ExistingNPA=0
						
--Select A.CustomerAcid,A.ReductionDuetoWrite_OffAmount,A.WritoffFlag,B.InttWriteOffAmount,A.FinalGNPABalance,A.ReductionDuetoRecovery_ExistingNPA 
from NPAMovement A
INNER JOIN (Select TransferOutCustomerAcID,TransferOutAssetClassification,TransferOutBalance,TransferOutUnserviced_Interest,TransferOutDate,TransferOutProvision From DataUpload.TransferInOutDataUpload
Where TransferOutDate Between @MonthStartDate and @MonthEndDate
Group By TransferOutCustomerAcID,TransferOutAssetClassification,TransferOutBalance,TransferOutUnserviced_Interest,TransferOutDate,TransferOutProvision ) B ON A.CustomerAcid=B.TransferOutCustomerAcID
Where A.Timekey=@CurrentMonthEndTIMEKEY
And A.Movement_Flag=@MovementTypeFlag



/*---------------- Movement Nature --------------*/


Update A Set MoveMentNature =(Case When InitialAssetClassAlt_Key=1 And TransferOut_Flag='Y' Then 'STD-TransferOut'
									When InitialAssetClassAlt_Key<>1 And TransferOut_Flag='Y' Then 'NPA-TransferOut'
												END)
from NPAMovement A
INNER JOIN (Select TransferOutCustomerAcID,TransferOutAssetClassification,TransferOutBalance,TransferOutUnserviced_Interest,TransferOutDate,TransferOutProvision From DataUpload.TransferInOutDataUpload
Where TransferOutDate Between @MonthStartDate and @MonthEndDate
Group By TransferOutCustomerAcID,TransferOutAssetClassification,TransferOutBalance,TransferOutUnserviced_Interest,TransferOutDate,TransferOutProvision ) B ON A.CustomerAcid=B.TransferOutCustomerAcID
Where A.Timekey=@CurrentMonthEndTIMEKEY
And A.Movement_Flag=@MovementTypeFlag



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
INNER JOIN (Select TransferOutCustomerAcID,TransferOutAssetClassification,TransferOutBalance,TransferOutUnserviced_Interest,TransferOutDate,TransferOutProvision From DataUpload.TransferInOutDataUpload
Where TransferOutDate Between @MonthStartDate and @MonthEndDate
Group By TransferOutCustomerAcID,TransferOutAssetClassification,TransferOutBalance,TransferOutUnserviced_Interest,TransferOutDate,TransferOutProvision ) B ON A.CustomerAcid=B.TransferOutCustomerAcID
Where A.Timekey=@CurrentMonthEndTIMEKEY
And A.Movement_Flag=@MovementTypeFlag
/*--------------Transfer out completed --------------- */
/*

/* ------------------Transfer In Data ---------------------- */
Insert into NPAMovement(NPAProcessingDate,Timekey,SourceAlt_Key,CustomerID,CustomerEntityID,CustomerAcid,AccountEntityID
,InitialAssetClassAlt_Key,InitialNPABalance,InitialUnservicedInterest,InitialProvision,FinalAssetClassAlt_Key,FinalNPABalance,FinalUnservicedInterest,FinalProvision
,TransferIn_Flag,TransferIn_Balance)
Select 
Cast(GETDATE() as Date) as NPAProcessingdate,@CurrentMonthEndTIMEKEY as TimeKey,A.SourceAlt_Key,A.CustomerID,A.CustomerEntityID,B.TransferInCustomerAcID,A.AccountEntityID
,1 as InitialAssetClassAlt_Key,0 InitialNPABalance,0 InitialUnservicedInterest,0 InitialProvision,A.FinalAssetClassAlt_Key,A.Balance,ISNULL(A.UNSERVED_INTEREST,0)UNSERVED_INTEREST,ISNULL(A.TotalProvision,0)TotalProvision
,'Y' as TransferIn_Flag,B.TransferInBalance

 from pro.AccountCal_Hist A
Inner join (
Select 
TransferInCustomerAcID,TransferInAssetClassification,TransferInBalance,TransferInUnserviced_Interest,TransferInDate From DataUpload.TransferInOutDataUpload
Where TransferInDate Between @MonthStartDate and @MonthEndDate)B ON A.CustomerAcid=B.TransferInCustomerAcID
Where A.EffectiveFromTimeKey<=@CurrentMonthEndTIMEKEY
AND A.EffectiveToTimeKey>=@CurrentMonthEndTIMEKEY

-------Update CustomerName------

Update A SET A.CustomerName=B.CustomerName
FROM NPAMovement A
INNER JOIN PRO.CustomerCal_Hist B ON A.CustomerEntityID=B.CustomerEntityID
Where A.TimeKey=@CurrentMonthEndTIMEKEY
AND B.EffectiveFromTimeKey<=@CurrentMonthEndTIMEKEY AND B.EffectiveToTimeKey>=@CurrentMonthEndTIMEKEY
AND A.TransferIn_Flag='Y'

/*---------------- Movement Nature --------------*/

Update NPAMovement 
Set MovementNature= (Case When InitialAssetClassAlt_Key=1 And TransferIn_Flag='Y' Then 'STD-TransferIn'
									When InitialAssetClassAlt_Key<>1 And TransferIn_Flag='Y' Then 'NPA-TransferIn'
									End)
Where Timekey=@CurrentMonthEndTIMEKEY 
And TransferIn_Flag='Y'

/*-------------- Update Initial GNPA Balance --------------------*/

Update NPAMovement 
Set InitialGNPABalance= InitialNPABalance-InitialUnservicedInterest 
Where Timekey=@CurrentMonthEndTIMEKEY 
And TransferIn_Flag='Y'

/*-------------- Update Initial NNPA Balance --------------------*/

Update NPAMovement 
Set InitialNNPABalance= InitialGNPABalance-InitialProvision 
Where Timekey=@CurrentMonthEndTIMEKEY 
And TransferIn_Flag='Y'

/*-------------- Update Final GNPA Balance --------------------*/

Update NPAMovement 
Set FinalGNPABalance= FinalNPABalance-FinalUnservicedInterest 
Where Timekey=@CurrentMonthEndTIMEKEY 
And TransferIn_Flag='Y'

/*-------------- Update Final NNPA Balance --------------------*/

Update NPAMovement 
Set FinalNNPABalance= FinalGNPABalance-FinalProvision
Where Timekey=@CurrentMonthEndTIMEKEY
And TransferIn_Flag='Y'


/*------------ ExistingNPA_Addition ----------------------*/

Update NPAMovement 
Set ExistingNPA_Addition=(Case When MovementNature in ('NPA-TransferIn') AND FinalGNPABalance-TransferIn_Balance>0
									Then FinalGNPABalance-TransferIn_Balance
							--		(Case When FinalGNPABalance-InitialGNPABalance<0 Then 0
							--Else FinalGNPABalance-InitialGNPABalance End )
							Else 0 
							End)
Where Timekey=@CurrentMonthEndTIMEKEY
And TransferIn_Flag='Y'

/*------------ Update FreshNPA_Addition ------------------*/

Update NPAMovement 
Set FreshNPA_Addition=(Case When MovementNature in ('STD-TransferIn') AND FinalGNPABalance-TransferIn_Balance>0
						Then FinalGNPABalance-TransferIn_Balance
						Else 0 End)
Where Timekey=@CurrentMonthEndTIMEKEY 
And TransferIn_Flag='Y'

----/*------------ ReductionDuetoUpgradeAmount ------------------*/

----Update NPAMovement 
----Set ReductionDuetoUpgradeAmount=(Case When MovementNature in ('NPA-STD') AND InitialGNPABalance-FinalGNPABalance>0
----									Then InitialGNPABalance-FinalGNPABalance
----									--(Case When (InitialGNPABalance-FinalGNPABalance)<0 Then 0
----									--			Else InitialGNPABalance-FinalGNPABalance 
----									--		End) 
----									When MovementNature in ('STD-STD') Then
----											FreshNPA_Addition
----										Else 0
----								 End)
----Where Timekey=@CurrentMonthEndTIMEKEY 
----And TransferIn_Flag='Y'

----/*------------ ReductionDuetoRecovery_ExistingNPA ------------------*/

----Update NPAMovement 
----Set ReductionDuetoRecovery_ExistingNPA=(Case When MovementNature in ('NPA-NPA','NPA-WriteOff','NPA-OTSWriteOff','NPA-NPA_Retail','NPA-ARCSale','NPA-Closed')
----									AND InitialGNPABalance-FinalGNPABalance>0 Then InitialGNPABalance-FinalGNPABalance
----									--(Case When (InitialGNPABalance-FinalGNPABalance)<0 Then 0
----									--			Else InitialGNPABalance-FinalGNPABalance  
----									--		End) 
----											Else 0
----										End)
----Where Timekey=@CurrentMonthEndTIMEKEY 
----And TransferIn_Flag='Y'

/*------------ Update TotalReduction_GNPA,TotalReduction_Provision, TotalReduction_UnservicedInterest ------------------*/

Update NPAMovement Set TotalReduction_GNPA=(Case When TransferIn_Balance-FinalGNPABalance<0 Then 0 Else TransferIn_Balance-FinalGNPABalance End)
							,TotalReduction_Provision=(Case When InitialProvision-FinalProvision<0 Then 0 Else InitialProvision-FinalProvision End)
							,TotalReduction_UnservicedInterest=(Case When InitialUnservicedInterest-FinalUnservicedInterest<0 Then 0 Else InitialUnservicedInterest-FinalUnservicedInterest End)
Where Timekey=@CurrentMonthEndTIMEKEY 
And TransferIn_Flag='Y'

/*------------ Update TotalAddition_GNPA,TotalAddition_Provision TotalAddition_UnservicedInterest ------------------*/

Update NPAMovement Set TotalAddition_GNPA=(Case When FinalGNPABalance-TransferIn_Balance<0 Then 0 Else FinalGNPABalance-TransferIn_Balance End)
							,TotalAddition_Provision=(Case When FinalProvision-InitialProvision<0 Then 0 Else FinalProvision-InitialProvision End)
							,TotalAddition_UnservicedInterest=(Case When FinalUnservicedInterest-InitialUnservicedInterest<0 Then 0 Else FinalUnservicedInterest-InitialUnservicedInterest End)
Where Timekey=@CurrentMonthEndTIMEKEY 
And TransferIn_Flag='Y'


*/

/* ------------------Transfer In Data ---------------------- */


Update A Set A.TransferIn_Flag='Y'
			,A.TransferIn_Balance=B.TransferInBalance
			,A.InitialAssetClassAlt_Key=B.TransferInAssetClassification
			,A.InitialNPABalance=B.TransferInBalance
			,A.InitialUnservicedInterest=B.TransferInUnserviced_Interest
			,A.InitialProvision=B.TransferInProvision
			
--Select A.CustomerAcid,A.ReductionDuetoWrite_OffAmount,A.WritoffFlag,B.InttWriteOffAmount,A.FinalGNPABalance,A.ReductionDuetoRecovery_ExistingNPA 
from NPAMovement A
INNER JOIN (Select 
TransferInCustomerAcID,TransferInAssetClassification,TransferInBalance,TransferInUnserviced_Interest,TransferInDate,TransferInProvision From DataUpload.TransferInOutDataUpload
Where TransferInDate Between @MonthStartDate and @MonthEndDate ) B ON A.CustomerAcid=B.TransferInCustomerAcID
Where A.Timekey=@CurrentMonthEndTIMEKEY
And A.Movement_Flag=@MovementTypeFlag


--Update A Set A.FreshNPA_Addition=0
						
----Select A.CustomerAcid,A.ReductionDuetoWrite_OffAmount,A.WritoffFlag,B.InttWriteOffAmount,A.FinalGNPABalance,A.ReductionDuetoRecovery_ExistingNPA 
--from NPAMovement A
--INNER JOIN (Select 
--TransferInCustomerAcID,TransferInAssetClassification,TransferInBalance,TransferInUnserviced_Interest,TransferInDate,TransferInProvision From DataUpload.TransferInOutDataUpload
--Where TransferInDate Between @MonthStartDate and @MonthEndDate ) B ON A.CustomerAcid=B.TransferInCustomerAcID
--Where A.Timekey=@CurrentMonthEndTIMEKEY



/*---------------- Movement Nature --------------*/


Update A Set MoveMentNature =(Case When InitialAssetClassAlt_Key=1 And TransferIn_Flag='Y' Then 'STD-TransferIn'
									When InitialAssetClassAlt_Key<>1 And TransferIn_Flag='Y' Then 'NPA-TransferIn'
									End)
from NPAMovement A
INNER JOIN (Select 
TransferInCustomerAcID,TransferInAssetClassification,TransferInBalance,TransferInUnserviced_Interest,TransferInDate,TransferInProvision From DataUpload.TransferInOutDataUpload
Where TransferInDate Between @MonthStartDate and @MonthEndDate ) B ON A.CustomerAcid=B.TransferInCustomerAcID
Where A.Timekey=@CurrentMonthEndTIMEKEY
And A.Movement_Flag=@MovementTypeFlag


/*-------------- Update Initial GNPA Balance --------------------*/

Update NPAMovement 
Set InitialGNPABalance= InitialNPABalance-InitialUnservicedInterest 
Where Timekey=@CurrentMonthEndTIMEKEY 
And TransferIn_Flag='Y'
And Movement_Flag=@MovementTypeFlag

/*-------------- Update Initial NNPA Balance --------------------*/

Update NPAMovement 
Set InitialNNPABalance= InitialGNPABalance-InitialProvision 
Where Timekey=@CurrentMonthEndTIMEKEY 
And TransferIn_Flag='Y'
And Movement_Flag=@MovementTypeFlag

/*-------------- Update Final GNPA Balance --------------------*/

Update NPAMovement 
Set FinalGNPABalance= FinalNPABalance-FinalUnservicedInterest 
Where Timekey=@CurrentMonthEndTIMEKEY 
And TransferIn_Flag='Y'
And Movement_Flag=@MovementTypeFlag

/*-------------- Update Final NNPA Balance --------------------*/

Update NPAMovement 
Set FinalNNPABalance= FinalGNPABalance-FinalProvision
Where Timekey=@CurrentMonthEndTIMEKEY
And TransferIn_Flag='Y'
And Movement_Flag=@MovementTypeFlag


/*------------ ExistingNPA_Addition ----------------------*/

Update NPAMovement 
Set ExistingNPA_Addition=(Case When MovementNature in ('NPA-TransferIn') AND FinalGNPABalance-InitialGNPABalance>0
									Then FinalGNPABalance-InitialGNPABalance
							--		(Case When FinalGNPABalance-InitialGNPABalance<0 Then 0
							--Else FinalGNPABalance-InitialGNPABalance End )
							Else 0 
							End)
Where Timekey=@CurrentMonthEndTIMEKEY
And TransferIn_Flag='Y'
And Movement_Flag=@MovementTypeFlag

/*------------ Update FreshNPA_Addition ------------------*/

Update NPAMovement 
Set FreshNPA_Addition=(Case When MovementNature in ('STD-TransferIn') AND FinalGNPABalance-InitialGNPABalance>0
						Then FinalGNPABalance-InitialGNPABalance
						Else 0 End)
Where Timekey=@CurrentMonthEndTIMEKEY 
And TransferIn_Flag='Y'
And Movement_Flag=@MovementTypeFlag


/*------------ Update TotalReduction_GNPA,TotalReduction_Provision, TotalReduction_UnservicedInterest ------------------*/

Update NPAMovement Set TotalReduction_GNPA=(Case When TransferIn_Balance-FinalGNPABalance<0 Then 0 Else TransferIn_Balance-FinalGNPABalance End)
							,TotalReduction_Provision=(Case When InitialProvision-FinalProvision<0 Then 0 Else InitialProvision-FinalProvision End)
							,TotalReduction_UnservicedInterest=(Case When InitialUnservicedInterest-FinalUnservicedInterest<0 Then 0 Else InitialUnservicedInterest-FinalUnservicedInterest End)
Where Timekey=@CurrentMonthEndTIMEKEY 
And TransferIn_Flag='Y'
And Movement_Flag=@MovementTypeFlag

/*------------ Update TotalAddition_GNPA,TotalAddition_Provision TotalAddition_UnservicedInterest ------------------*/

Update NPAMovement Set TotalAddition_GNPA=(Case When FinalGNPABalance-InitialGNPABalance<0 Then 0 Else FinalGNPABalance-InitialGNPABalance End)
							,TotalAddition_Provision=(Case When FinalProvision-InitialProvision<0 Then 0 Else FinalProvision-InitialProvision End)
							,TotalAddition_UnservicedInterest=(Case When FinalUnservicedInterest-InitialUnservicedInterest<0 Then 0 Else FinalUnservicedInterest-InitialUnservicedInterest End)
Where Timekey=@CurrentMonthEndTIMEKEY 
And TransferIn_Flag='Y'
And Movement_Flag=@MovementTypeFlag


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
INNER JOIN DataUpload.TransferInOutDataUpload B ON A.CustomerAcid=B.TransferInCustomerAcID
Where A.Timekey=@CurrentMonthEndTIMEKEY
AND B.TransferInDate Between @MonthStartDate and @MonthEndDate
And A.TransferIn_Flag='Y'
And A.Movement_Flag=@MovementTypeFlag


END

END
GO