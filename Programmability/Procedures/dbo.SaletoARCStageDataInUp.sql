SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE  [dbo].[SaletoARCStageDataInUp]
	@Timekey INT,
	@UserLoginID VARCHAR(100),
	@OperationFlag INT,
	@MenuId INT,
	@AuthMode	CHAR(1),
	@filepath VARCHAR(MAX),
	@EffectiveFromTimeKey INT,
	@EffectiveToTimeKey	INT,
    @Result		INT=0 OUTPUT,
	@UniqueUploadID INT 

AS

--DECLARE @Timekey INT=24928,
--	@UserLoginID VARCHAR(100)='FNAOPERATOR',
--	@OperationFlag INT=1,
--	@MenuId INT=163,
--	@AuthMode	CHAR(1)='N',
--	@filepath VARCHAR(MAX)='',
--	@EffectiveFromTimeKey INT=24928,
--	@EffectiveToTimeKey	INT=49999,
--    @Result		INT=0 ,
--	@UniqueUploadID INT=41
BEGIN
SET DATEFORMAT DMY
	SET NOCOUNT ON;

   
   --DECLARE @Timekey INT
   --SET @Timekey=(SELECT MAX(TIMEKEY) FROM dbo.SysProcessingCycle
			--	WHERE ProcessType='Quarterly')

			SET @Timekey=(select CAST(B.timekey as int)from SysDataMatrix A
			Inner Join SysDayMatrix B ON A.TimeKey=B.TimeKey
			 where A.CurrentStatus='C')

	PRINT @TIMEKEY

	SET @EffectiveFromTimeKey=@TimeKey
	SET @EffectiveToTimeKey=49999


	DECLARE @FilePathUpload	VARCHAR(100)
				   SET @FilePathUpload=@UserLoginId+'_'+@filepath
					PRINT '@FilePathUpload'
					PRINT @FilePathUpload


		BEGIN TRY

		--BEGIN TRAN
		
IF (@MenuId=1462)
BEGIN


	IF (@OperationFlag=1)

	BEGIN

		IF NOT (EXISTS (SELECT 1 FROM SaletoARC_Stg  where filname=@FilePathUpload))

							BEGIN
									 --Rollback tran
									SET @Result=-8

								RETURN @Result
							END
			


		IF EXISTS(SELECT 1 FROM SaletoARC_Stg WHERE FILNAME=@FilePathUpload)
		BEGIN
		
		INSERT INTO ExcelUploadHistory
	(
		UploadedBy	
		,DateofUpload	
		,AuthorisationStatus	
		--,Action	
		,UploadType
		,EffectiveFromTimeKey	
		,EffectiveToTimeKey	
		,CreatedBy	
		,DateCreated	
		
	)

	SELECT @UserLoginID
		   ,GETDATE()
		   ,'NP'
		   --,'NP'
		   ,'Sale to ARC Upload'
		   ,@EffectiveFromTimeKey
		   ,@EffectiveToTimeKey
		   ,@UserLoginID
		   ,GETDATE()

		   PRINT @@ROWCOUNT

		   DECLARE @ExcelUploadId INT
	SET 	@ExcelUploadId=(SELECT MAX(UniqueUploadID) FROM  ExcelUploadHistory)
		
			Insert into UploadStatus (FileNames,UploadedBy,UploadDateTime,UploadType)
		Values(@filepath,@UserLoginID ,GETDATE(),'Sale to ARC Upload')

		INSERT INTO SaletoARC_Mod
		(
			SrNo
			,UploadID
			,SourceSystem
			,CustomerID
			,CustomerName
			,AccountID
			,BalanceOutstanding
			,POS
			,InterestReceivable
			,DtofsaletoARC
			,DateofApproval
			,AmountSold
			--,PoolID
			--,PoolName
			,AuthorisationStatus	
			,EffectiveFromTimeKey	
			,EffectiveToTimeKey	
			,CreatedBy	
			,DateCreated
			,Action	
		)

		SELECT
			SrNo
			,@ExcelUploadId
			,ds.SourceName SourceSystem
			,B.CustomerId
			,B.CustomerName
			,AccountID
			,AB.Balance
			,AB.PrincipalBalance PrincipalOutstandinginRs
			,AB.Overdueinterest InterestReceivableinRs
			,DateOfSaletoARC
			,DateOfApproval
			,ExposuretoARCinRs
			--,PoolID
			--,PoolName
			,'NP'	
			,@Timekey
			,49999	
			,@UserLoginID	
			,GETDATE()
			,Action
			 
		FROM SaletoARC_Stg AP
		Inner Join [CurDat].[AdvAcBasicDetail] A ON A.CustomerACID=AP.AccountID
		Inner Join	[CurDat].[CustomerBasicDetail] B On A.[CustomerEntityId]=B.[CustomerEntityId]	
		Inner join DIMSOURCEDB ds on ds.SourceAlt_Key=A.SourceAlt_Key
		Inner join [CurDat].[AdvAcBalanceDetail] AB on AB.AccountEntityId=A.AccountEntityId
		and			AB.EffectiveFromTimeKey<=@Timekey
		and			AB.EffectiveToTimeKey>=@Timekey
		where		A.EffectiveFromTimeKey<=@Timekey
		and			A.EffectiveToTimeKey>=@Timekey
		and			B.EffectiveFromTimeKey<=@Timekey
		and			B.EffectiveToTimeKey>=@Timekey
		And FilName=@FilePathUpload

		Declare @SummaryId int
		Set @SummaryId=IsNull((Select Max(SummaryId) from SaletoARCSummary_Mod),0)

		INSERT INTO SaletoARCSummary_stg
		(
			UploadID
			,SummaryID
			,NoofAccounts
			,TotalPOSinRs
			,TotalInttReceivableinRs
			,TotaloutstandingBalanceinRs
			,ExposuretoARCinRs
			,DateOfSaletoARC
			,DateOfApproval
			,Action
		)

		SELECT
			@ExcelUploadId
			,@SummaryId --+Row_Number() over(Order by PoolID)
			,COUNT(B.CustomerId)
			,Sum(IsNull(AB.PrincipalBalance,0))
			,Sum(IsNull(AB.Overdueinterest,0))
			,Sum(IsNull(AB.Balance,0))
			,Sum(IsNull(Cast(ExposuretoARCinRs as Decimal(16,2)),0))
			,DateOfSaletoARC
			,DateOfApproval
			,Action
			--,Sum(IsNull(Cast(PrincipalOutstandinginRs as decimal(16,2)),0)+IsNull(Cast(InterestReceivableinRs as Decimal(16,2)),0))
			FROM SaletoARC_Stg AP
		Inner Join [CurDat].[AdvAcBasicDetail] A ON A.CustomerACID=AP.AccountID
		Inner Join	[CurDat].[CustomerBasicDetail] B On A.[CustomerEntityId]=B.[CustomerEntityId]	
		Inner join DIMSOURCEDB ds on ds.SourceAlt_Key=A.SourceAlt_Key
		Inner join [CurDat].[AdvAcBalanceDetail] AB on AB.AccountEntityId=A.AccountEntityId
		and			AB.EffectiveFromTimeKey<=@Timekey
		and			AB.EffectiveToTimeKey>=@Timekey
		where		A.EffectiveFromTimeKey<=@Timekey
		and			A.EffectiveToTimeKey>=@Timekey
		and			B.EffectiveFromTimeKey<=@Timekey
		and			B.EffectiveToTimeKey>=@Timekey
		ANd FilName=@FilePathUpload
		Group by DateOfSaletoARC,DateOfApproval,Action

		--where FilName=@FilePathUpload
		--Group by PoolID,PoolName

		--INSERT INTO IBPCPoolSummary_Mod
		--(
		--	UploadID
		--	,SummaryID
		--	,PoolID
		--	,PoolName
		--	,BalanceOutstanding
		--	,NoOfAccount
		--	,AuthorisationStatus	
		--	,EffectiveFromTimeKey	
		--	,EffectiveToTimeKey	
		--	,CreatedBy	
		--	,DateCreated	
		--)

		--SELECT
		--	@ExcelUploadId
		--	,@SummaryId+Row_Number() over(Order by PoolID)
		--	,PoolID
		--	,PoolName
		--	,Sum(IsNull(POS,0)+IsNull(InterestReceivable,0))
		--	,Count(PoolID)
		--	,'NP'	
		--	,@Timekey
		--	,49999	
		--	,@UserLoginID	
		--	,GETDATE()
		--FROM IBPCPoolDetail_stg
		--where FilName=@FilePathUpload
		--Group by PoolID,PoolName

		PRINT @@ROWCOUNT
		
		---DELETE FROM STAGING DATA
		 DELETE FROM SaletoARC_Stg
		 WHERE filname=@FilePathUpload

		 ----RETURN @ExcelUploadId

END
		   ----DECLARE @UniqueUploadID INT
	--SET 	@UniqueUploadID=(SELECT MAX(UniqueUploadID) FROM  ExcelUploadHistory)
	END


----------------------Two level Auth. Changes-------------

IF (@OperationFlag=16)----AUTHORIZE

	BEGIN
		
		UPDATE 
			SaletoARC_Mod 
			SET 
			AuthorisationStatus	='1A'
			,ApprovedByFirstLevel	=@UserLoginID
			,DateApprovedFirstLevel	=GETDATE()
			
			WHERE UploadId=@UniqueUploadID

			UPDATE 
			SaletoARCSummary_Mod 
			SET 
			AuthorisationStatus	='1A'
			,ApprovedBy	=@UserLoginID
			,DateApproved	=GETDATE()
			
			WHERE UploadId=@UniqueUploadID

			
		   UPDATE 
		   ExcelUploadHistory
		   SET AuthorisationStatus='1A'
		   ,ApprovedBy	=@UserLoginID
		   where UniqueUploadID=@UniqueUploadID
		   AND  UploadType='sale to ARC Upload'
	END

--------------------------------------------

	IF (@OperationFlag=20)----AUTHORIZE

	BEGIN
		
		UPDATE 
			SaletoARC_Mod 
			SET 
			AuthorisationStatus	='A'
			,ApprovedBy	=@UserLoginID
			,DateApproved	=GETDATE()
			
			WHERE UploadId=@UniqueUploadID

			UPDATE 
			SaletoARCSummary_Mod 
			SET 
			AuthorisationStatus	='A'
			,ApprovedBy	=@UserLoginID
			,DateApproved	=GETDATE()
			
			WHERE UploadId=@UniqueUploadID


			Update  A
			Set A.EffectiveToTimeKey=A.EffectiveFromTimeKey-1
			from SaletoARC A
			inner join SaletoARC_Mod B
			ON A.AccountID=B.AccountID
			AND B.EffectiveFromTimeKey <=@Timekey
			AND B.EffectiveToTimeKey >=@Timekey
			Where B.UploadId=@UniqueUploadID
			AND A.EffectiveToTimeKey >=49999

			-----maintain history
			INSERT INTO SaletoARC(
					SourceSystem
					,CustomerID
					,CustomerName
					,AccountID
					,BalanceOutstanding
					,POS
					,InterestReceivable
					,DtofsaletoARC
					,DateofApproval
					,AmountSold
					,PoolID
					,PoolName
					,AuthorisationStatus
					,EffectiveFromTimeKey
					,EffectiveToTimeKey
					,CreatedBy
					,DateCreated
					,ModifyBy
					,DateModified
					,ApprovedBy
					,DateApproved
					,Action)
			SELECT SourceSystem
					,CustomerID
					,CustomerName
					,AccountID
					,BalanceOutstanding
					,POS
					,InterestReceivable
					,DtofsaletoARC
					,DateofApproval
					,AmountSold
					,PoolID
					,PoolName
					,AuthorisationStatus
					,@Timekey,49999
					,CreatedBy
					,DateCreated
					,ModifyBy
					,DateModified
					,@UserLoginID
					,Getdate()
					,Action
			FROM SaletoARC_Mod A
			WHERE  A.UploadId=@UniqueUploadID and EffectiveToTimeKey>=@Timekey
			And A.Action in('A','R')
			

			INSERT INTO SaletoARCSummary(
					SummaryID
					,NoofAccounts
					,TotalPOSinRs
					,TotalInttReceivableinRs
					,TotaloutstandingBalanceinRs
					,ExposuretoARCinRs
					,DateOfSaletoARC
					,DateOfApproval
					,AuthorisationStatus
						,EffectiveFromTimeKey
						,EffectiveToTimeKey
						,CreatedBy
						,DateCreated
						,ModifyBy
						,DateModified
						,ApprovedBy
						,DateApproved)
			SELECT SummaryID
					,NoofAccounts
					,TotalPOSinRs
					,TotalInttReceivableinRs
					,TotaloutstandingBalanceinRs
					,ExposuretoARCinRs
					,DateOfSaletoARC
					,DateOfApproval
					,AuthorisationStatus
					,@Timekey,49999
					,CreatedBy
					,DateCreated
					,ModifyBy
					,DateModified
					,@UserLoginID
					,Getdate()
			FROM SaletoARCSummary_Mod A
			WHERE  A.UploadId=@UniqueUploadID and EffectiveToTimeKey>=@Timekey

			-------------------------------------------------------------

			Update  A
			Set A.EffectiveToTimeKey=A.EffectiveFromTimeKey-1
			,A.FlagAlt_Key=Case When B.Action='R' then 'N' Else A.FlagAlt_Key End

			from SaletoARCFinalACFlagging A
			inner join SaletoARC_Mod B
			ON A.AccountID=B.AccountID
			AND B.EffectiveFromTimeKey <=@Timekey
			AND B.EffectiveToTimeKey >=@Timekey
			Where B.UploadId=@UniqueUploadID
			AND A.EffectiveToTimeKey >=49999
			And B.Action in('A','R')

			--BEGIN  
          INSERT INTO SaletoARCFinalACFlagging  
          (    --Entity_Key  
              SourceAlt_Key
             ,SourceSystem  
             ,AccountID  
             ,CustomerID  
             ,CustomerName  
             ,FlagAlt_Key  
             ,AccountBalance  
             ,POS  
             ,InterestReceivable
			 ,ExposureAmount
              --,AuthorisationStatus  
			  --,Remark
			  ,AuthorisationStatus
              ,EffectiveFromTimeKey  
              ,EffectiveToTimeKey  
              ,CreatedBy  
              ,DateCreated  
              ,ModifyBy  
              ,DateModified  
              ,ApprovedBy  
              ,DateApproved  
             -- ,D2Ktimestamp 
			 ,DtofsaletoARC
			 ,DateofApproval 
            )  
  
       SELECT DS.SourceAlt_Key
				,SourceSystem
				 ,AccountID
					,CustomerID
					,CustomerName
					,Case When A.Action='A' Then 'Y' Else NULL End
					,BalanceOutstanding
					,POS
					,InterestReceivable
					,AmountSold
					,A.AuthorisationStatus
					,@Timekey
					,49999
					,A.CreatedBy
					,A.DateCreated
					,ModifyBy
					,A.DateModified
					,@UserLoginID
					,Getdate()
					,DtofsaletoARC
					,DateofApproval
			FROM SaletoARC_Mod A
			Left Join DIMSOURCEDB DS ON A.SourceSystem=DS.SourceName ANd DS.EffectiveToTimeKey=49999
			WHERE  A.UploadId=@UniqueUploadID and A.EffectiveToTimeKey>=@Timekey 
			ANd A.Action in('A')
         -- END  

		 ---Summary Final -----------

			Insert into SaletoARCFinalSummary
			(
			SummaryID
			,NoofAccounts
			,TotalPOSinRs
			,TotalInttReceivableinRs
			,TotaloutstandingBalanceinRs
			,ExposuretoARCinRs
			,DateOfSaletoARC
			,DateOfApproval
			,AuthorisationStatus
			,EffectiveFromTimeKey
			,EffectiveToTimeKey
			,CreatedBy
			,DateCreated
			,ModifyBy
			,DateModified
			,ApprovedBy
			,DateApproved
			
			)
			SELECT SummaryID
					,NoofAccounts
					,TotalPOSinRs
					,TotalInttReceivableinRs
					,TotaloutstandingBalanceinRs
					,ExposuretoARCinRs
					,DateOfSaletoARC
					,DateOfApproval
					,AuthorisationStatus
					,@Timekey,49999
					,CreatedBy
					,DateCreated
					,ModifyBy
					,DateModified
					,@UserLoginID
					,Getdate()
					
			FROM SaletoARCSummary_Mod A
			WHERE  A.UploadId=@UniqueUploadID and EffectiveToTimeKey>=@Timekey

---------------------------------------------
/*--------------------Adding Flag To AdvAcOtherDetail------------Pranay 21-03-2021--------*/ 

  UPDATE A
	SET  
        A.SplFlag=CASE WHEN ISNULL(A.SplFlag,'')='' THEN 'SaleArc'     
						ELSE A.SplFlag+','+'SaleArc'     END
		   
   FROM DBO.AdvAcOtherDetail A
   --INNER JOIN #Temp V  ON A.AccountEntityId=V.AccountEntityId
  INNER JOIN SaletoARC_Mod B ON A.RefSystemAcId=B.AccountID
			WHERE  B.UploadId=@UniqueUploadID and B.EffectiveToTimeKey>=@Timekey
			AND A.EffectiveToTimeKey=49999



			UPDATE A
			SET 
			A.POS=ROUND(B.POS,2)
			--,a.ModifyBy=@UserLoginID
			--,a.DateModified=GETDATE()
			FROM SaletoARC A
			INNER JOIN SaletoARC_Mod  B ON (A.EffectiveFromTimeKey<=@Timekey AND A.EffectiveToTimeKey>=@Timekey)
																AND  (B.EffectiveFromTimeKey<=@Timekey AND B.EffectiveToTimeKey>=@Timekey)	
																AND A.AccountID=B.AccountID

				WHERE B.AuthorisationStatus='A'
				AND B.UploadId=@UniqueUploadID

				UPDATE
				ExcelUploadHistory
				SET AuthorisationStatus='A',ApprovedBy=@UserLoginID,DateApproved=GETDATE()
				WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
				AND UniqueUploadID=@UniqueUploadID
				AND UploadType='sale to ARC Upload'

				


	END

	IF (@OperationFlag=17)----REJECT

	BEGIN
		
		UPDATE 
			SaletoARC_Mod 
			SET 
			AuthorisationStatus	='R'
			,ApprovedByFirstLevel	=@UserLoginID
			,DateApprovedFirstLevel	=GETDATE()
			,EffectiveToTimeKey=@Timekey-1
			WHERE UploadId=@UniqueUploadID
			AND AuthorisationStatus='NP'

			UPDATE 
			SaletoARCSummary_Mod 
			SET 
			AuthorisationStatus	='R'
			,ApprovedBy	=@UserLoginID
			,DateApproved	=GETDATE()
			
			WHERE UploadId=@UniqueUploadID
			AND AuthorisationStatus='NP'
			----SELECT * FROM IBPCPoolDetail

			UPDATE
				ExcelUploadHistory
				SET AuthorisationStatus='R',ApprovedBy=@UserLoginID,DateApproved=GETDATE()
				WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
				AND UniqueUploadID=@UniqueUploadID
				AND UploadType='Sale to ARC Upload'



	END

------------------------------Two level Auth. Changes---------------------

IF (@OperationFlag=21)----REJECT

	BEGIN
		
		UPDATE 
			SaletoARC_Mod 
			SET 
			AuthorisationStatus	='R'
			,ApprovedBy	=@UserLoginID
			,DateApproved	=GETDATE()
			,EffectiveToTimeKey=@Timekey-1
			WHERE UploadId=@UniqueUploadID
			AND AuthorisationStatus in('NP','1A')

			UPDATE 
			SaletoARCSummary_Mod 
			SET 
			AuthorisationStatus	='R'
			,ApprovedBy	=@UserLoginID
			,DateApproved	=GETDATE()
			
			WHERE UploadId=@UniqueUploadID
			AND AuthorisationStatus in ('NP','1A')
			----SELECT * FROM IBPCPoolDetail

			UPDATE
				ExcelUploadHistory
				SET AuthorisationStatus='R',ApprovedBy=@UserLoginID,DateApproved=GETDATE()
				WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
				AND UniqueUploadID=@UniqueUploadID
				AND UploadType='Sale to ARC Upload'



	END	
----------------------------------------------------------------------------
END

IF @OperationFlag IN (1,2,3,16,17,18,20,21) AND @AuthMode ='Y'
		BEGIN
					print 'log table'

					declare @DateCreated datetime
				SET	@DateCreated     =Getdate()

				--declare @ReferenceID1 varchar(max)
				--set @ReferenceID1 = (case when @OperationFlag in (16,20,21) then @UniqueUploadID else @ExcelUploadId end)


					IF @OperationFlag IN(16,17,18,20,21) 
						BEGIN 
						       Print 'Authorised'
					
			
								EXEC LogDetailsInsertUpdate_Attendence -- MAINTAIN LOG TABLE
							    @BranchCode=''   ,  ----BranchCode
								@MenuID=@MenuID,
								@ReferenceID=@UniqueUploadID ,-- ReferenceID ,
								@CreatedBy=NULL,
								@ApprovedBy=@UserLoginID, 
								@CreatedCheckedDt=@DateCreated,
								@Remark=NULL,
								@ScreenEntityAlt_Key=16  ,---ScreenEntityId -- for FXT060 screen
								@Flag=@OperationFlag,
								@AuthMode=@AuthMode
						END
					ELSE
						BEGIN
						       Print 'UNAuthorised'
						    -- Declare
						    -- set @CreatedBy  =@UserLoginID
							 
							EXEC LogDetailsInsertUpdate_Attendence -- MAINTAIN LOG TABLE
								@BranchCode=''   ,  ----BranchCode
								@MenuID=@MenuID,
								@ReferenceID=@ExcelUploadId ,-- ReferenceID ,
								@CreatedBy=@UserLoginID,
								@ApprovedBy=NULL, 						
								@CreatedCheckedDt=@DateCreated,
								@Remark=NULL,
								@ScreenEntityAlt_Key=16  ,---ScreenEntityId -- for FXT060 screen
								@Flag=@OperationFlag,
								@AuthMode=@AuthMode
						END

		END

	--COMMIT TRAN
		---SET @Result=CASE WHEN  @OperationFlag=1 THEN @UniqueUploadID ELSE 1 END
		SET @Result=CASE WHEN  @OperationFlag=1 AND @MenuId=1462 
		THEN @ExcelUploadId 
					ELSE 1 END

		
		 Update UploadStatus Set InsertionOfData='Y',InsertionCompletedOn=GETDATE() where FileNames=@filepath

		 ---- IF EXISTS(SELECT 1 FROM IBPCPoolDetail_stg WHERE filEname=@FilePathUpload)
		 ----BEGIN
			----	 DELETE FROM IBPCPoolDetail_stg
			----	 WHERE filEname=@FilePathUpload

			----	 PRINT 'ROWS DELETED FROM IBPCPoolDetail_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
		 ----END
		 

		RETURN @Result
		------RETURN @UniqueUploadID
	END TRY
	BEGIN CATCH 
	   --ROLLBACK TRAN
	SELECT ERROR_MESSAGE(),ERROR_LINE()
	SET @Result=-1
	 Update UploadStatus Set InsertionOfData='Y',InsertionCompletedOn=GETDATE() where FileNames=@filepath
	RETURN -1
	END CATCH

END

GO