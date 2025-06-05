SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [ETL_MAIN].[AcDailyTxnDetail_Main_backup]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    
	Declare @vEffectiveto INT Set @vEffectiveto= (select Timekey-1 from ENBD_MISDB.DBO.AUTOMATE_ADVANCES where EXT_FLG='Y')


	/*  New Customers Account Entity ID Update  */
DECLARE @ENTITYKEY INT=0 
SELECT @ENTITYKEY=MAX(ENTITYKEY) FROM  ENBD_MISDB.[dbo].[AcDailyTxnDetail] 
IF @ENTITYKEY IS NULL  
BEGIN
SET @ENTITYKEY=0
END
 
UPDATE TEMP 
SET TEMP.ENTITYKEY=ACCT.ENTITYKEY
 FROM ENBD_TEMPDB.DBO.[TempAcDailyTxnDetail] TEMP
INNER JOIN (SELECT CustomerAcID,TxnDate,TxnRefNo,TxnType,Particular,(@ENTITYKEY + ROW_NUMBER()OVER(ORDER BY (SELECT 1))) ENTITYKEY
			FROM ENBD_TEMPDB.DBO.[TempAcDailyTxnDetail]
			WHERE ENTITYKEY=0 OR ENTITYKEY IS NULL)ACCT ON TEMP.CustomerAcID=ACCT.CustomerAcID
			AND TEMP.TxnDate=ACCT.TxnDate AND TEMP.TxnType=ACCT.TxnType AND TEMP.Particular=ACCT.Particular  AND TEMP.TxnRefNo=ACCT.TxnRefNo


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
FROM ENBD_TEMPDB.[dbo].[TempAcDailyTxnDetail] A


END
GO