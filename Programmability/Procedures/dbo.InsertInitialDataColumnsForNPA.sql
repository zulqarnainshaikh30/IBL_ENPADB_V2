SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



/*================================================
	AUTHER : SUNIL NARSING
	CREATE DATE : 02-01-2020
	MODIFY DATE : 02-01-2020
	DESCRIPTION : InsertInitialDataColumnsForNPA
	
=============================================================*/

CREATE PROCEDURE [dbo].[InsertInitialDataColumnsForNPA]

--Declare 
@CurrentMonthEndTIMEKEY INT --=25536
,@NPAMOVE as Varchar(5) --='M'
,@PrevMonthEndTimekey AS Int --=25506       ----to set with query
,@MovementTypeFlag As Char(1)
AS
BEGIN

/*------------- Insert Initial Data Coulmns For NPA  -----------------*/

Declare @ProcessDate As Date

---Set @CurrentMonthEndTIMEKEY= @CurrentMonthEndTIMEKEY       --(select TimeKey from SysDayMatrix where date='2019-10-31')

--Set @PrevMonthEndTimekey=(select LastMonthDateKey from SysDayMatrix where Timekey=@CurrentMonthEndTIMEKEY)

Set @ProcessDate= GETDATE()---(select Cast(Date as Date) from SysDayMatrix where Timekey=@CurrentMonthEndTIMEKEY)

--Select @PrevMonthEndTimekey,@CurrentMonthEndTIMEKEY,@ProcessDate


IF (@NPAMOVE<>'M' )
BEGIN

INSERT INTO NPAMovement
 (
 NPAProcessingDate,Timekey,SourceAlt_Key,BranchCode,CustomerID,CustomerEntityID,CustomerAcid,AccountEntityID,CustomerName,
 InitialAssetClassAlt_Key,InitialNPABalance,InitialUnservicedInterest,InitialProvision,Movement_Flag
 )
 
 Select @ProcessDate As  NPAProcessingDate
 ,@CurrentMonthEndTIMEKEY As TimeKey
 ,A.SourceAlt_Key As SourceAlt_Key
 ,A.BranchCode As BranchCode
 ,A.CustomerID As CustomerID
 ,A.CustomerEntityID AS CustomerEntityID
 ,A.CustomerAcid As CustomerAcid
 ,A.AccountEntityID As AccountEntityID
 ,A.CustomerName As CustomerName
 ,A.FinalAssetClassAlt_Key As InitialAssetClassAlt_Key
 ,A.FinalNPABalance As InitialNPABalance
 ,A.FinalUnservicedInterest As InitialUnservicedInterest
 ,A.FinalProvision As InitialProvision
 ,@MovementTypeFlag As Movement_Flag

 From NPAMovement A
  Where A.TimeKey=@PrevMonthEndTimekey 
  AND A.FinalAssetClassAlt_Key Not In (0,1,7)
  END
ELSE
	BEGIN
INSERT INTO NPAMovement
 (
 NPAProcessingDate,Timekey,SourceAlt_Key,BranchCode,CustomerID,CustomerEntityID,CustomerAcid,AccountEntityID,/*CustomerName,*/
 InitialAssetClassAlt_Key,InitialNPABalance,InitialUnservicedInterest,InitialProvision,Movement_Flag
 )

 Select @ProcessDate As  NPAProcessingDate
 ,@CurrentMonthEndTIMEKEY As TimeKey
 ,A.SourceAlt_Key As SourceAlt_Key
 ,A.BranchCode As BranchCode
 ,A.RefCustomerID As CustomerID
 ,A.CustomerEntityID AS CustomerEntityID
 ,A.CustomerAcid As CustomerAcid
 ,A.AccountEntityID As AccountEntityID
 --,A.CustomerName As CustomerName
 ,A.FinalAssetClassAlt_Key As InitialAssetClassAlt_Key
 ,A.Balance As InitialNPABalance
 ,ISNULL(A.unserviedint,0) As InitialUnservicedInterest
 ,A.TotalProvision As InitialProvision
 ,@MovementTypeFlag As Movement_Flag

 From PRO.AccountCal_Hist A
  Where A.EffectiveFromTimeKey<=@PrevMonthEndTimekey AND A.EffectiveToTimeKey>=@PrevMonthEndTimekey
  AND A.FinalAssetClassAlt_Key<>1 AND A.FinalAssetClassAlt_Key<>7
  END

  -----------------Data Insert for Accounts are not present in Previous But Open in NPA for Current and marked transferin flag as 'U'-----

  INSERT INTO NPAMovement
 (
 NPAProcessingDate,Timekey,SourceAlt_Key,BranchCode,CustomerID,CustomerEntityID,CustomerAcid,AccountEntityID,/*CustomerName,*/
 InitialAssetClassAlt_Key,InitialNPABalance,InitialUnservicedInterest,InitialProvision,TransferIn_Flag,Movement_Flag
 )
 Select @ProcessDate As  NPAProcessingDate
 ,@CurrentMonthEndTIMEKEY As TimeKey
 ,A.SourceAlt_Key As SourceAlt_Key
 ,A.BranchCode As BranchCode
 ,A.RefCustomerID As CustomerID
 ,A.CustomerEntityID AS CustomerEntityID
 ,A.CustomerAcid As CustomerAcid
 ,A.AccountEntityID As AccountEntityID
 --,A.CustomerName As CustomerName
 ,1 As InitialAssetClassAlt_Key
 ,0 As InitialNPABalance
 ,0 As InitialUnservicedInterest
 ,0 As InitialProvision
 ,'U' As TransferIn_Flag
 ,@MovementTypeFlag As Movement_Flag

 From PRO.AccountCal_Hist A
Left Join PRO.AccountCal_Hist B ON A.CustomerAcID=B.CustomerAcID
and B.EffectiveFromTimeKey<=@PrevMonthEndTimekey and B.EffectiveToTimeKey>=@PrevMonthEndTimekey
where A.EffectiveFromTimeKey<=@CurrentMonthEndTIMEKEY and A.EffectiveToTimeKey>=@CurrentMonthEndTIMEKEY
AND A.FinalAssetClassAlt_Key not in (1,7) AND B.CustomerAcID IS NULL


---------------------------
Update A Set A.InitialUnservicedInterest =(Case When B.FacilityType='OD' Then InitialUnservicedInterest Else 0 End)
--Select *
From NPAMovement A 
INNER JOIN PRO.AccountCal_Hist B ON A.CustomerAcid=B.CustomerAcid
Where A.Timekey=@CurrentMonthEndTIMEKEY
And B.EffectiveFromTimeKey<=@PrevMonthEndTimekey And B.EffectiveToTimeKey>=@PrevMonthEndTimekey

/*-------------- Update Initial GNPA Balance --------------------*/

Update NPAMovement 
Set InitialGNPABalance=	InitialNPABalance-InitialUnservicedInterest					--(Case When InitialNPABalance-InitialUnservicedInterest <0 Then 0 Else InitialNPABalance-InitialUnservicedInterest End)
Where Timekey=@CurrentMonthEndTIMEKEY 
AND InitialAssetClassAlt_Key<>1
And Movement_Flag=@MovementTypeFlag

/*-------------- Update Initial NNPA Balance --------------------*/

Update NPAMovement 
Set InitialNNPABalance=	InitialGNPABalance-InitialProvision							--(Case When InitialGNPABalance-InitialProvision <0 Then 0 Else InitialGNPABalance-InitialProvision End)
Where Timekey=@CurrentMonthEndTIMEKEY 
AND InitialAssetClassAlt_Key<>1
And Movement_Flag=@MovementTypeFlag

-------Update CustomerName------

Update A SET A.CustomerName=B.CustomerName
FROM NPAMovement A
INNER JOIN PRO.CustomerCal_Hist B ON A.CustomerEntityID=B.CustomerEntityID
Where A.TimeKey=@CurrentMonthEndTIMEKEY
AND B.EffectiveFromTimeKey<=@PrevMonthEndTimekey AND B.EffectiveToTimeKey>=@PrevMonthEndTimekey
And A.Movement_Flag=@MovementTypeFlag
END
GO