SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [ETL_MAIN].[AcDailyTxnDetail_Main]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Declare @Date Date = (select Date from Automate_Advances where EXT_FLG = 'Y')
    
	Declare @vEffectiveto INT Set @vEffectiveto= (select Timekey-1 from UTKS_MISDB.DBO.AUTOMATE_ADVANCES where EXT_FLG='Y')

	
	/*  New Customers Account Entity ID Update  */
DECLARE @ENTITYKEY INT=0 
SELECT @ENTITYKEY=MAX(ENTITYKEY) FROM  UTKS_MISDB.[dbo].[AcDailyTxnDetail] 
IF @ENTITYKEY IS NULL  
BEGIN
SET @ENTITYKEY=0
END
 
UPDATE TEMP 
SET TEMP.ENTITYKEY=ACCT.ENTITYKEY
 FROM UTKS_TEMPDB.DBO.[TempAcDailyTxnDetail] TEMP
INNER JOIN (SELECT CustomerAcID,TxnRefNo,TxnDate,TxnsUBType,Particular,(@ENTITYKEY + ROW_NUMBER()OVER(ORDER BY (SELECT 1))) ENTITYKEY
			FROM UTKS_TEMPDB.DBO.[TempAcDailyTxnDetail]
			WHERE ENTITYKEY=0 OR ENTITYKEY IS NULL)ACCT ON TEMP.CustomerAcID=ACCT.CustomerAcID
			AND TEMP.TxnDate=ACCT.TxnDate AND TEMP.TxnsUBType=ACCT.TxnsUBType AND ISNULL(TEMP.Particular,'AA')=ISNULL(ACCT.Particular,'AA')
			AND TEMP.TxnRefNo = ACCT.TxnRefNo

			--update UTKS_TEMPDB.DBO.TempACDailyTXNDetail set ENTITYKEY = 70597 where ENTITYKEY is NULL
			
INSERT INTO dbo.AcDailyTxnDetail
(ENTITYKEY
,Branchcode
,CustomerID
,CustomerAcID
,AccountEntityId
,TxnDate
,TxnType
,TxnSubType
,TxnTime
,CurrencyAlt_Key
,CurrencyConvRate
,TxnAmount
,TxnAmountInCurrency
,ExtDate
,TxnRefNo
,TxnValueDate
,MnemonicCode
,Particular
,AuthorisationStatus
,CreatedBy
,DateCreated
,ModifiedBy
,DateModified
,ApprovedBy
,DateApproved
,D2Ktimestamp
,Remark
,TrueCredit
,IsProcessed
,Balance)
		   

SELECT 
		ENTITYKEY
,Branchcode
,CustomerID
,CustomerAcID
,AccountEntityId
,TxnDate
,TxnType
,TxnSubType
,TxnTime
,CurrencyAlt_Key
,CurrencyConvRate
,TxnAmount
,TxnAmountInCurrency
,ExtDate
,TxnRefNo
,TxnValueDate
,MnemonicCode
,Particular
,AuthorisationStatus
,CreatedBy
,DateCreated
,ModifiedBy
,DateModified
,ApprovedBy
,DateApproved
,GETDATE() D2Ktimestamp
,Remark
,TrueCredit
,IsProcessed
,Balance	
FROM UTKS_TEMPDB.[dbo].[TempAcDailyTxnDetail] A
where cast(TxnDate as date) < '10/23/2023'
--Declare @srNo as int = 1

--IF @SrNo = 1

--BEGIN
--Update UTKS_STGDB.dbo.PACKAGE_AUDIT SET ExecutionStatus = -1 where Tablename = 'AcDailyTxnDetail' and PackageName = 'TempToMainDB' 
--and Execution_Date = cast(GETDATE() as date)

--Update BANDAUDITSTATUS set BandStatus = 'Failed' where BandName in ('TempToMain')

-- RAISERROR('Cannot Insert',50,20)

--END

END

GO