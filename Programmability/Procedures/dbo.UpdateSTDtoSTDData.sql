SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



/*================================================
	AUTHER : SUNIL NARSING
	CREATE DATE : 02-01-2020
	MODIFY DATE : 02-01-2020
	DESCRIPTION : UpdateSTDtoSTDData
	
=============================================================*/

CREATE PROCEDURE [dbo].[UpdateSTDtoSTDData]
--Declare
@CurrentMonthEndTIMEKEY INT --=25536
--,@NPAMOVE varchar(5)='M'             ------It comes from Table
,@PrevMonthEndTimekey AS Int  --=25506
,@MovementTypeFlag As Char(1)
AS
BEGIN


/*------------- Update STD to STD Data -----------------*/

Declare @ProcessDate As Date,@MonthStartDate As Date,@MonthEndDate As Date

Set @MonthStartDate=(select MonthFirstDate from SysDataMatrix where TimeKey=@CurrentMonthEndTIMEKEY)   --@TIMEKEY    --

Set @MonthEndDate=(select MonthLastDate from SysDataMatrix where Timekey=@CurrentMonthEndTIMEKEY)

Set @ProcessDate= (select Cast(Date as Date) from SysDayMatrix where Timekey=@CurrentMonthEndTIMEKEY)

PRINT @ProcessDate

/*  FOR  NO NEED

IF EXISTS (SELECT 1 FROM NPAMovement WHERE TimeKey=@CurrentMonthEndTIMEKEY )
BEGIN

/* ------------------STD to STD Data ---------------------- */
Insert into NPAMovement(NPAProcessingDate,Timekey,SourceAlt_Key,CustomerID,CustomerEntityID,CustomerAcid,AccountEntityID
,InitialAssetClassAlt_Key,InitialNPABalance,InitialUnservicedInterest,InitialProvision,FinalAssetClassAlt_Key,FinalNPABalance,FinalUnservicedInterest,FinalProvision
,MovementNature)
Select 
Cast(GETDATE() as Date) as NPAProcessingdate,@CurrentMonthEndTIMEKEY as TimeKey,A.SourceAlt_Key,A.CustomerID,A.CustomerEntityID,A.CustomerAcID,A.AccountEntityID
,A.FinalAssetClassAlt_Key,0 as InitialNPABalance,0 as InitialUnservicedInterest,0 as InitialProvision,C.FinalAssetClassAlt_Key,0 Balance,0 UNSERVED_INTEREST,0 TotalProvision
,'STD-STD' as MovementNature
 from pro.AccountCal_Hist A
 Inner join pro.AccountCal_Hist C ON C.AccountEntityID=A.AccountEntityID
Inner join (
Select * From DailySmartJobData
Where AsonDate Between @MonthStartDate and @MonthEndDate)B ON A.CustomerAcid=B.FORACID
Where A.EffectiveFromTimeKey<=@PrevMonthEndTimekey
AND A.EffectiveToTimeKey>=@PrevMonthEndTimekey
AND C.EffectiveFromTimeKey<=@CurrentMonthEndTIMEKEY
AND C.EffectiveToTimeKey>=@CurrentMonthEndTIMEKEY
AND B.MAIN_CLASSIFICATION_USER=2
AND A.FinalAssetClassAlt_Key=1 
AND C.FinalAssetClassAlt_Key=1

-------Update CustomerName------

Update A SET A.CustomerName=B.CustomerName
FROM NPAMovement A
INNER JOIN PRO.CustomerCal_Hist B ON A.CustomerEntityID=B.CustomerEntityID
Where A.TimeKey=@CurrentMonthEndTIMEKEY
AND B.EffectiveFromTimeKey<=@CurrentMonthEndTIMEKEY AND B.EffectiveToTimeKey>=@CurrentMonthEndTIMEKEY
AND A.MovementNature='STD-STD'


/*-------------- Update Initial GNPA Balance --------------------*/

Update NPAMovement 
Set InitialGNPABalance= InitialNPABalance-InitialUnservicedInterest 
Where Timekey=@CurrentMonthEndTIMEKEY 
AND MovementNature='STD-STD'

/*-------------- Update Initial NNPA Balance --------------------*/

Update NPAMovement 
Set InitialNNPABalance= InitialGNPABalance-InitialProvision 
Where Timekey=@CurrentMonthEndTIMEKEY 
AND MovementNature='STD-STD'

/*-------------- Update Final GNPA Balance --------------------*/

Update NPAMovement 
Set FinalGNPABalance= FinalNPABalance-FinalUnservicedInterest 
Where Timekey=@CurrentMonthEndTIMEKEY 
AND MovementNature='STD-STD'

/*-------------- Update Final NNPA Balance --------------------*/

Update NPAMovement 
Set FinalNNPABalance= FinalGNPABalance-FinalProvision
Where Timekey=@CurrentMonthEndTIMEKEY
AND MovementNature='STD-STD'



/*------------ Update FreshNPA_Addition ------------------*/

Update A 
Set FreshNPA_Addition=(Case When CLR_BAL_AMT<0 Then CLR_BAL_AMT*-1 Else CLR_BAL_AMT End)
from NPAMovement A
INNER JOIN DailySmartJobData B ON A.CustomerAcid=B.FORACID
Where A.Timekey=@CurrentMonthEndTIMEKEY
AND B.AsonDate Between @MonthStartDate and @MonthEndDate

/*------------ ReductionDuetoUpgradeAmount ------------------*/

Update NPAMovement 
Set ReductionDuetoUpgradeAmount=(Case When CLR_BAL_AMT<0 Then CLR_BAL_AMT*-1 Else CLR_BAL_AMT End)
from NPAMovement A
INNER JOIN DailySmartJobData B ON A.CustomerAcid=B.FORACID
Where A.Timekey=@CurrentMonthEndTIMEKEY
AND B.AsonDate Between @MonthStartDate and @MonthEndDate


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
INNER JOIN DailySmartJobData B ON A.CustomerAcid=B.FORACID
Where A.Timekey=@CurrentMonthEndTIMEKEY
AND B.AsonDate Between @MonthStartDate and @MonthEndDate



END

*/

END
GO