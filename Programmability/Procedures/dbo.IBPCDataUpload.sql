SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
-- Author:		<shailesh naik>
-- Create date: <16 jan 2019 kikrant>
-- Description:	<RBI pan insert update>
-- =============================================
CREATE PROCEDURE [dbo].[IBPCDataUpload]
	@XMLDocument XML=N''  
,@ScreenName varchar(50) = 'IBPCDataUpload'
,@SheetNames varchar(max) = ''
,@DateOfData varchar(10)  = ''
,@EffectiveFromTimeKey	INT=0
,@EffectiveToTimeKey	INT=0
,@OperationFlag			INT=0
,@AuthMode				CHAR(1)='N'
,@CrModApBy				VARCHAR(50)=''
,@TimeKey				INT=24957
,@Result				INT=0 output
,@D2KTimeStamp			INT=0 output
,@Remark			   VARCHAR(200)=''
,@MenuId				INT = 118


AS


BEGIN
      DECLARE
	    @EntityId				INT
	   ,@CreatedBy				VARCHAR(50)
	   ,@DateCreated			DATETIME
	   ,@ModifiedBy				VARCHAR(50)
	   ,@DateModified			DATETIME
	   ,@ApprovedBy				VARCHAR(50)
	   ,@DateApproved			DATETIME
	   ,@AuthorisationStatus	CHAR(2)
	   ,@ErrorHandle			SMALLINT =0
	   ,@ExEntityKey			INT	    =0
	   ,@Data_Sequence			INT = 0

	 
	 --SET @EffectiveFromTimeKey=@TimeKey

IF OBJECT_ID('Tempdb..#MiscIBPC_Detail') IS NOT NULL
DROP TABLE #MiscIBPC_Detail



SELECT 
 C.value('./Soldto				[1]','VARCHAR(50)'	)ParticipatingBank
,C.value('./CustID				[1]','VARCHAR(20)'	)CustomerId
,C.value('./AccountNumber					[1]','VARCHAR(30)'	)CustomerACID
,C.value('./Segment				[1]','VARCHAR(100)'	)REMARK
,C.value('./Customer				[1]','VARCHAR(100)'	)CUSTOMERNAME
,C.value('./IBPCSep19					[1]','VARCHAR(30)'	) [IBPC_Amount]

INTO #MiscIBPC_Detail
--FROM @XMLDocument.nodes('/DataSet/BondsUploadEntry') AS t(c)
FROM @XMLDocument.nodes('/Root/Sheet1') AS t(c)
-----
Select * from #MiscIBPC_Detail

--select * from #BondsUploadEntry

print 'revert'

set @OperationFlag=1

Declare @checkDate int

select @checkDate = TimeKey from [dbo].[SysDayMatrix] where cast([Date] as Date) = cast(@DateOfData as date)
Print @checkDate
SET @EffectiveFromTimeKey=@checkDate
SET @EffectiveToTimeKey = @checkDate
BEGIN TRY


BEGIN TRAN

IF @OperationFlag=1 AND @AuthMode='Y'
	BEGIN
	         PRINT 2
	         PRINT 'op1'
			 SET @CreatedBy =@CrModApBy 
	         SET @DateCreated = GETDATE()
	         SET @AuthorisationStatus='NP'
	   
	   IF EXISTS (SELECT * FROM MiscIBPC_Detail WHERE EffectiveFromTimeKey<= @checkDate and EffectiveToTimeKey>=@checkDate)
			Delete from MiscIBPC_Detail where EffectiveFromTimeKey<= @checkDate and EffectiveToTimeKey>=@checkDate
			PRINT 'DELETE' 

	   GOTO BSCodeStructure_Insert
	        BSCodeStruct_Insert_Add:

	END	
	

SET @ErrorHandle=1

Print @ErrorHandle
BSCodeStructure_Insert:
PRINT 'A'
IF @ErrorHandle=0
								
  	BEGIN

				Print 'Insert into MiscIBPC_Detail_MOD'

									PRINT '@ErrorHandle'
									INSERT INTO MiscIBPC_Detail_MOD
											(
											BranchCode
											,IBPC_Nature
											--,IBPC_Type
											,CustomerId
											,CustomerName
											,SystemACID
											,CustomerACID
											,ParticipatingBank
											,CurrencyAlt_key
											,IBPC_AmountInCurrency
											,IBPC_Amount
											,Remark
											,AuthorisationStatus
											,EffectiveFromTimeKey
											,EffectiveToTimeKey
											,CreatedBy
											,DateCreated
											
											)
										SELECT
												 'HO'
												 ,'Sale'
												 ,CustomerId
												 ,CustomerName
												 ,CustomerACID
												 ,CustomerACID
												 ,ParticipatingBank
												 ,62 --CurrencyAlt_key
												 ,IBPC_Amount
												 ,IBPC_Amount
												 ,Remark
												 ,@AuthorisationStatus
												 ,@EffectiveFromTimeKey
												 ,@EffectiveToTimeKey
												 ,@CreatedBy
												 ,@DateCreated
												 
												
											FROM #MiscIBPC_Detail

								PRINT CAST(@@ROWCOUNT AS VARCHAR)+'INSERTED into mod'


								Print 'Insert into MiscIBPC_Detail'
								--Select *from MiscIBPC_Detail
									PRINT '@ErrorHandle'
									INSERT INTO MiscIBPC_Detail
											(
											BranchCode
											,IBPC_Nature
											--,IBPC_Type
											,CustomerId
											,CustomerName
											,SystemACID
											,CustomerACID
											,ParticipatingBank
											,CurrencyAlt_key
											,IBPC_AmountInCurrency
											,IBPC_Amount
											,Remark
											,AuthorisationStatus
											,EffectiveFromTimeKey
											,EffectiveToTimeKey
											,CreatedBy
											,DateCreated
											)
										SELECT
												 'HO'
												 ,'Sale'
												 ,CustomerId
												 ,CustomerName
												 ,CustomerACID
												 ,CustomerACID
												 ,ParticipatingBank
												 ,62 --CurrencyAlt_key
												 ,IBPC_Amount
												 ,IBPC_Amount
												 ,Remark
												 ,@AuthorisationStatus
												 ,@EffectiveFromTimeKey
												 ,@EffectiveToTimeKey
												 ,@CreatedBy
												 ,@DateCreated
												 
												
											FROM #MiscIBPC_Detail
											

								PRINT CAST(@@ROWCOUNT AS VARCHAR)+'INSERTED'
								

				IF @OperationFlag =1
					BEGIN
						PRINT 3
						GOTO BSCodeStruct_Insert_Add
					END


	END			
	

 COMMIT TRANSACTION

 IF @OperationFlag <>3

 BEGIN
			SET @D2Ktimestamp='090934'

			SET @RESULT=1
			RETURN  @RESULT
			--RETURN @D2Ktimestamp
END

ELSE

		BEGIN
				SET @Result=0
				RETURN  @RESULT
		END
		
 END TRY
    BEGIN CATCH
	    SELECT ERROR_MESSAGE() ERRORDESC,ERROR_LINE() as LineNum
		ROLLBACK TRAN
		SET @RESULT=-1
		RETURN @RESULT
			END  CATCH


END		

GO