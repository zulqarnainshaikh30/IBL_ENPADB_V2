SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROCEDURE  [dbo].[ColletralOtherOwnerUploadInUp]
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
	--@Authlevel varchar(5)

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

			Set @Timekey=(
			select CAST(B.timekey as int)from SysDataMatrix A
			Inner Join SysDayMatrix B ON A.TimeKey=B.TimeKey
			 where A.CurrentStatus='C'
			 )

	PRINT @TIMEKEY

	SET @EffectiveFromTimeKey=@TimeKey
	SET @EffectiveToTimeKey=49999


	DECLARE @FilePathUpload	VARCHAR(100)
				   SET @FilePathUpload=@UserLoginId+'_'+@filepath
					PRINT '@FilePathUpload'
					PRINT @FilePathUpload


		BEGIN TRY

		--BEGIN TRAN
		
IF (@MenuId=24703)
BEGIN


	IF (@OperationFlag=1)

	BEGIN

		IF NOT (EXISTS (SELECT 1 FROM CollateralOthOwnerDetails_stg  where filname=@FilePathUpload))

							BEGIN
									 --Rollback tran
									SET @Result=-8

								RETURN @Result
							END
			
                   Print 'Sachin'

		IF EXISTS(SELECT 1 FROM CollateralOthOwnerDetails_stg WHERE filname=@FilePathUpload)
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
		   ,'Colletral OthOwner Upload'
		   ,@EffectiveFromTimeKey
		   ,@EffectiveToTimeKey
		   ,@UserLoginID
		   ,GETDATE()


			   PRINT @@ROWCOUNT

		   DECLARE @ExcelUploadId INT
	SET 	@ExcelUploadId=(SELECT MAX(UniqueUploadID) FROM  ExcelUploadHistory)
		
			Insert into UploadStatus (FileNames,UploadedBy,UploadDateTime,UploadType)
		Values(@filepath,@UserLoginID ,GETDATE(),'Colletral OthOwner Upload')

		INSERT INTO [CollateralOthOwnerDetails_MOD]
		(
			SrNo,
			UploadID,
			SystemCollateralID,
			CustomeroftheBank,
			CustomerID,
			OtherOwnerName,
			OtherOwnerRelationship,
			Ifrelativeentervalue,
			AddressType,
			AddressCategory,
			AddressLine1,
			AddressLine2,
			AddressLine3,
			City,
			PinCode,
			Country,
			District,
			StdCodeO,
			PhoneNoO,
			StdCodeR,
			PhoneNoR,
			MobileNo,
			CreatedBy,
			DateCreated,
			AuthorisationStatus,
			EffectiveFromTimeKey,
			EffectiveToTimeKey
			
		)
		
		
		SELECT
		SrNo,
		@ExcelUploadId,
		SystemCollateralID,
		CustomeroftheBank,
		CustomerID,
		OtherOwnerName,
		OtherOwnerRelationship,
		Ifrelativeentervalue,
		AddressType,
		AddressCategory,
		AddressLine1,
		AddressLine2,
		AddressLine3,
		City,
		PinCode,
		Country,
		District,
		StdCodeO,
		PhoneNoO,
		StdCodeR,
		PhoneNoR,
		MobileNo,
		@UserLoginID,
		GETDATE(),
			'NP',
			@Timekey,
			49999	
		FROM CollateralOthOwnerDetails_stg
		where filname=@FilePathUpload
		

		--Declare @SummaryId int
		--Set @SummaryId=IsNull((Select Max(SummaryId) from IBPCPoolSummary_Mod),0)

		--INSERT INTO IBPCPoolSummary_stg
		--(
		--	UploadID
		--	,SummaryID
		--	,PoolID
		--	,PoolName
		--	,PoolType
		--	,BalanceOutstanding
		--	,NoOfAccount
		--	,IBPCExposureAmt
		--	,IBPCReckoningDate
		--	,IBPCMarkingDate
		--	,MaturityDate
		--	,TotalPosBalance
		--	,TotalInttReceivable
		--)

		--SELECT
		--	@ExcelUploadId
		--	,@SummaryId+Row_Number() over(Order by PoolID)
		--	,PoolID
		--	,PoolName
		--	,PoolType
		--	,Sum(IsNull(Cast(PrincipalOutstandinginRs as decimal(16,2)),0)+IsNull(Cast(InterestReceivableinRs as Decimal(16,2)),0))
		--	,Count(PoolID)
		--	,SUM(ISNULL(Cast(IBPCExposureinRs as Decimal(16,2)),0))
		--	,DateofIBPCreckoning
		--	,DateofIBPCmarking
		--	,MaturityDate
		--	,Sum(IsNull(Cast(PrincipalOutstandinginRs as decimal(16,2)),0))
		--	,Sum(IsNull(Cast(InterestReceivableinRs as Decimal(16,2)),0))
		--FROM IBPCPoolDetail_stg
		--where FilName=@FilePathUpload
		--Group by PoolID,PoolName,PoolType,DateofIBPCreckoning,DateofIBPCmarking,MaturityDate

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
		 DELETE FROM CollateralOthOwnerDetails_stg
		 WHERE filname=@FilePathUpload

		 ----RETURN @ExcelUploadId

END
		   ----DECLARE @UniqueUploadID INT
	--SET 	@UniqueUploadID=(SELECT MAX(UniqueUploadID) FROM  ExcelUploadHistory)
	END


----------------------01042021-------------

IF (@OperationFlag=16)----AUTHORIZE

	BEGIN
		
		UPDATE 
			CollateralOthOwnerDetails_MOD 
			SET 
			AuthorisationStatus	='1A'
			,ApprovedBy	=@UserLoginID
			,DateApproved	=GETDATE()
			
			WHERE UploadID=@UniqueUploadID

			UPDATE 
			CollateralOthOwnerDetails_MOD 
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
		   AND UploadType='Colletral OthOwner Upload'
	END

--------------------------------------------

	IF (@OperationFlag=20)----AUTHORIZE

	BEGIN
		
		UPDATE 
			CollateralOthOwnerDetails_MOD 
			SET 
			AuthorisationStatus	='A'
			,ApprovedBy	=@UserLoginID
			,DateApproved	=GETDATE()
			
			WHERE UploadId=@UniqueUploadID

			UPDATE 
			CollateralOthOwnerDetails_MOD 
			SET 
			AuthorisationStatus	='A'
			,ApprovedBy	=@UserLoginID
			,DateApproved	=GETDATE()
			
			WHERE UploadId=@UniqueUploadID

			

			INSERT INTO [CollateralOtherOwner]
		(
			CollateralID,
			CustomeroftheBankAlt_Key,
			CustomerID,
			OtherOwnerName,
			OtherOwnerRelationshipAlt_Key,
			IfRelationselectAlt_Key,
			AddressType,
			
			AddressLine1,
			AddressLine2,
			AddressLine3,
			City,
			PinCode,
			Country,
			District,
			STDCodeO,
		    PhoneNumberO,
			STDCodeR,
			PhoneNumberR,
			MobileNO,
			AuthorisationStatus,
			EffectiveFromTimeKey,
			EffectiveToTimeKey,
			CreatedBy,
			DateCreated,
			ModifiedBy,
			DateModified,
			ApprovedBy,
			DateApproved
		    
		     																					
						
		)
			SELECT SystemCollateralID as CollateralID,
				Case When CustomeroftheBank='Y' Then 1
					         Else 0
				     END as CustomeroftheBankAlt_Key
					   
					 ,A.CustomerID
                    ,A.OtherOwnerName
					,B.CollateralOwnerTypeAltKey
					,1 as IfRelationselectAlt_Key
					,A.AddressType
					,AddressLine1
					,AddressLine2
					,AddressLine3
					,City
			        ,PinCode
			        ,Country
					,District
                   ,StdCodeO
					,PhoneNoO
					,StdCodeR
                    ,PhoneNoR
                    ,MobileNo
					,A.AuthorisationStatus
					,@Timekey
					,49999
					,A.CreatedBy
					,A.DateCreated
					,A.ModifiedBy
					,A.DateModified
					,@UserLoginID
					,Getdate()
					
					
			FROM CollateralOthOwnerDetails_MOD A
			LEFT JOIN DimCollateralOwnerType B ON   A.OtherOwnerRelationship=B.CollOwnerDescription
 
			

			WHERE  A.UploadId=@UniqueUploadID and A.EffectiveToTimeKey>=@Timekey

			--INSERT INTO CollateralValueDetails(
			--		 CollateralValueatSanctioninRs,
			--		 CollateralValueasonNPAdateinRs,
			--		 CollateralValueatthetimeoflastreviewinRs,
			--		 ValuationDate,
			--		 LatestCollateralValueinRs,
			--		 ExpiryBusinessRule
			--		 ,AuthorisationStatus
			--		,EffectiveFromTimeKey
			--		,EffectiveToTimeKey
			--		,CreatedBy
			--		,DateCreated
			--		,ModifiedBy
			--		,DateModified
			--		,ApprovedBy
			--		,DateApproved
					
						
			--			)
			--SELECT 
			         

			--		CollateralValueSanctionRs,
			--		CollateralValueNPADateRs,
			--		CollateralValueLastReviewRs,
			--		ValuationDate	,
	  --              CurrentCollateralValueRs,
			--		ExpiryBusinessRule
			--		,AuthorisationStatus
			--		,@Timekey,49999
			--		,CreatedBy
			--		,DateCreated
			--		,ModifiedBy
			--		,DateModified
			--		,@UserLoginID
			--		,Getdate()
   --                FROM CollateralOthOwnerDetails_MOD A
			--WHERE  A.UploadId=@UniqueUploadID and EffectiveToTimeKey>=@Timekey


					
					
					
			


			-----------------Insert into Final Tables ----------


			
			-----Summary Final -----------




/*--------------------Adding Flag To AdvAcOtherDetail------------Sunil 21-03-2021--------*/ 




 -- UPDATE A
	--SET  
 --       A.SplFlag=CASE WHEN ISNULL(A.SplFlag,'')='' THEN 'IBPC'     
	--					ELSE A.SplFlag+','+'IBPC'     END
		   
 -- FROM DBO.AdvAcOtherDetail A
 --  --INNER JOIN #Temp V  ON A.AccountEntityId=V.AccountEntityId
 -- INNER JOIN CollateralOthOwnerDetails_MOD B ON A.OldCollateralID=B.OldCollateralID
	--		WHERE  B.UploadId=@UniqueUploadID and B.EffectiveToTimeKey>=@Timekey
	--		AND A.EffectiveToTimeKey=49999




			--------------------------
			--1
			--select *from ExceptionFinalStatusType
			--select * from AdvAcOtherDetail
			--select * from IBPCFinalPoolDetail 

			--alter table IBPCFinalPoolDetail
			--add IBPCOutDate date,IBPCInDate Date
			 --update 


-------------------------------------------

	--		UPDATE A
	--		SET 
	----A.POS=ROUND(B.POS,2),
	--		a.ModifiedBy=@UserLoginID
	--		,a.DateModified=GETDATE()
	--		FROM CollateralMgmt A
	--		INNER JOIN CollateralOthOwnerDetails_MOD
 -- B ON (A.EffectiveFromTimeKey<=@Timekey AND A.EffectiveToTimeKey>=@Timekey)
	--															AND  (B.EffectiveFromTimeKey<=@Timekey AND B.EffectiveToTimeKey>=@Timekey)	
	--															AND A.OldCollateralID=B.OldCollateralID


				--WHERE B.AuthorisationStatus='A'
				--AND B.UploadId=@UniqueUploadID

				UPDATE
				ExcelUploadHistory
				SET AuthorisationStatus='A',ApprovedBy=@UserLoginID,DateApproved=GETDATE()
				WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
				AND UniqueUploadID=@UniqueUploadID
				AND UploadType='Colletral OthOwner Upload'

				


	END


	IF (@OperationFlag=17)----REJECT

	BEGIN
		
		UPDATE 
			CollateralOthOwnerDetails_MOD 
			SET 
			AuthorisationStatus	='R'
			,ApprovedBy	=@UserLoginID
			,DateApproved	=GETDATE()
			
			WHERE UploadId=@UniqueUploadID
			AND AuthorisationStatus='NP'

			UPDATE 
			CollateralOthOwnerDetails_MOD 
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
				AND UploadType='Colletral OthOwner Upload'



	END

IF (@OperationFlag=21)----REJECT

	BEGIN
		
		UPDATE 
			CollateralOthOwnerDetails_MOD 
			SET 
			AuthorisationStatus	='R'
			,ApprovedBy	=@UserLoginID
			,DateApproved	=GETDATE()
			
			WHERE UploadId=@UniqueUploadID
			AND AuthorisationStatus in('NP','1A')

			UPDATE 
			CollateralOthOwnerDetails_MOD 
			SET 
			AuthorisationStatus	='R'
			,ApprovedBy	=@UserLoginID
			,DateApproved	=GETDATE()
			
			WHERE UploadId=@UniqueUploadID
			AND AuthorisationStatus in('NP','1A')
			----SELECT * FROM IBPCPoolDetail

			UPDATE
				ExcelUploadHistory
				SET AuthorisationStatus='R',ApprovedBy=@UserLoginID,DateApproved=GETDATE()
				WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
				AND UniqueUploadID=@UniqueUploadID
				AND UploadType='Colletral OthOwner Upload'



	END


END


	--COMMIT TRAN
		---SET @Result=CASE WHEN  @OperationFlag=1 THEN @UniqueUploadID ELSE 1 END
		SET @Result=CASE WHEN  @OperationFlag=1 AND @MenuId=24703 THEN @ExcelUploadId 
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