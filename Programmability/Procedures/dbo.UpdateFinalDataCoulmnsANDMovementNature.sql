SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



/*================================================
	AUTHER : SUNIL NARSING
	CREATE DATE : 02-01-2020
	MODIFY DATE : 02-01-2020
	DESCRIPTION : UpdateFinalDataCoulmnsANDMovementNature
	
=============================================================*/

CREATE PROCEDURE [dbo].[UpdateFinalDataCoulmnsANDMovementNature]
--Declare
@CurrentMonthEndTIMEKEY INT --=25536
--,@NPAMOVE varchar(5)='M'             ------It comes from Table
--,@PrevMonthEndTimekey AS Int =25475 
,@MovementTypeFlag As Char(1) 
AS
BEGIN

/*------------- Updating Current Month Closing Figures AND Movement Nature -----------------*/

Declare @ProcessDate As Date

--Set @CurrentMonthEndTIMEKEY= @TIMEKEY     --(select TimeKey from SysDayMatrix where date='2019-10-31')

--Set @PrevMonthEndTimekey=(select LastMonthDateKey from SysDayMatrix where Timekey=@CurrentMonthEndTIMEKEY)

Set @ProcessDate= (select Cast(Date as Date) from SysDayMatrix where Timekey=@CurrentMonthEndTIMEKEY)

IF EXISTS (SELECT 1 FROM NPAMovement WHERE TimeKey=@CurrentMonthEndTIMEKEY )
BEGIN

------------------ Update Final Data Coulmns -------------

Update A Set A.FinalAssetClassAlt_Key=(Case When B.AccountEntityID IS NULL THEN 0 ELSE B.FinalAssetClassAlt_Key END),
							 A.FinalNPABalance=(Case When B.AccountEntityID IS NULL THEN 0 
													When B.FinalAssetClassAlt_Key=1 THEN 0 
													ELSE ISNULL(B.Balance,0)  END),
							 A.FinalUnservicedInterest=(Case When B.AccountEntityID IS NULL THEN 0 
													When B.FinalAssetClassAlt_Key=1 THEN 0 
													ELSE ISNULL(B.unserviedint,0) END),
							 A.FinalProvision=(Case When B.AccountEntityID IS NULL THEN 0 
													When B.FinalAssetClassAlt_Key=1 THEN 0 
													ELSE ISNULL(B.TotalProvision,0) END)
From NPAMovement A 
LEFT JOIN PRO.AccountCal_Hist B ON A.AccountEntityID=B.AccountEntityID
And B.EffectiveFromTimeKey<=@CurrentMonthEndTIMEKEY AND B.EffectiveToTimeKey>=@CurrentMonthEndTIMEKEY
And B.FinalAssetClassAlt_Key <>7
Where A.TimeKey=@CurrentMonthEndTIMEKEY
And A.Movement_Flag=@MovementTypeFlag



---------------------------
Update A Set A.FinalUnservicedInterest =(Case When B.FacilityType='OD' Then FinalUnservicedInterest Else 0 End)
--Select *
From NPAMovement A 
INNER JOIN PRO.AccountCal_Hist B ON A.CustomerAcid=B.CustomerAcid
Where A.Timekey=@CurrentMonthEndTIMEKEY
And B.EffectiveFromTimeKey<=@CurrentMonthEndTIMEKEY And B.EffectiveToTimeKey>=@CurrentMonthEndTIMEKEY


/*-------------- Update Final GNPA Balance --------------------*/

Update NPAMovement 
Set FinalGNPABalance=FinalNPABalance-FinalUnservicedInterest							--(Case When FinalNPABalance-FinalUnservicedInterest<0 Then 0 Else FinalNPABalance-FinalUnservicedInterest End)
Where Timekey=@CurrentMonthEndTIMEKEY 
And Movement_Flag=@MovementTypeFlag

/*-------------- Update Final NNPA Balance --------------------*/

Update NPAMovement 
Set FinalNNPABalance=FinalGNPABalance-FinalProvision									--(Case When FinalGNPABalance-FinalProvision <0 Then 0 Else FinalGNPABalance-FinalProvision End)
Where Timekey=@CurrentMonthEndTIMEKEY
And Movement_Flag=@MovementTypeFlag

--------------- Update Movement Nature -----------------

Update NPAMovement Set MoveMentNature =(Case When InitialAssetClassAlt_Key=1 And FinalAssetClassAlt_Key=0 Then 'STD-Closed'
													When InitialAssetClassAlt_Key=1 And FinalAssetClassAlt_Key=1 Then 'STD-STD'
													When InitialAssetClassAlt_Key=1 And FinalAssetClassAlt_Key<>1 Then 'STD-NPA'
													When InitialAssetClassAlt_Key<>1 And FinalAssetClassAlt_Key=0 Then 'NPA-Closed'
													When InitialAssetClassAlt_Key<>1 And FinalAssetClassAlt_Key<>1 Then 'NPA-NPA'
													When InitialAssetClassAlt_Key<>1 And FinalAssetClassAlt_Key=1 Then 'NPA-STD'
													
													
												END)
Where TimeKey=@CurrentMonthEndTIMEKEY
And Movement_Flag=@MovementTypeFlag

END

END
GO