SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO





CREATE PROCEDURE  [dbo].[BuyOutStageUploadDataInUpNew]
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
		
IF (@MenuId=1466)
BEGIN


	IF (@OperationFlag=1)

	BEGIN

		IF NOT (EXISTS (SELECT 1 FROM BuyoutUploadDetails_stg  where filname=@FilePathUpload))

							BEGIN
									 --Rollback tran
									SET @Result=-8

								RETURN @Result
							END
			


		IF EXISTS(SELECT 1 FROM BuyoutUploadDetails_stg WHERE filname=@FilePathUpload)
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
		   ,'Buyout Upload'
		   ,@EffectiveFromTimeKey
		   ,@EffectiveToTimeKey
		   ,@UserLoginID
		   ,GETDATE()

		   --PRINT @@ROWCOUNT

		   DECLARE @ExcelUploadId INT
	SET 	@ExcelUploadId=(SELECT MAX(UniqueUploadID) FROM  ExcelUploadHistory)
		
			Insert into UploadStatus (FileNames,UploadedBy,UploadDateTime,UploadType)
		Values(@filepath,@UserLoginID ,GETDATE(),'Buyout Upload')

	
	SET DATEFORMAT DMY

		INSERT INTO [BuyoutUploadDetails_Mod]
		(
			SlNo
			,UploadID
			,DateofData
			,ReportDate
			,CustomerAcID
			,SchemeCode
			,NPA_ClassSeller
			,NPA_DateSeller
			,DPD_Seller
			,PeakDPD
			,PeakDPD_Date
			,AuthorisationStatus	
			,EffectiveFromTimeKey	
			,EffectiveToTimeKey	
			,CreatedBy	
			,DateCreated
				
		)

		SELECT
			SlNo
			,@ExcelUploadId
			,NULL
			--,Case When ISNULL(ReportDate,'')<>'' Then Convert(Date,ReportDate) Else NULL END DateofData
			,Case When ISNULL(ReportDate,'')<>'' Then Convert(Date,ReportDate) Else NULL END ReportDate
			,AccountNo
			,SchemeCode
			,Case When ISNULL(NPAClassificationwithSeller,'')<>'' Then NPAClassificationwithSeller Else NULL END NPAClassificationwithSeller 
			,Case When ISNULL(DateofNPAwithSeller,'')<>'' Then Convert(Date,DateofNPAwithSeller) Else NULL END NPA_DateSeller
			,DPDwithSeller
			,Case When ISNULL(PeakDPDwithSeller,'')<>'' Then PeakDPDwithSeller Else NULL END PeakDPDwithSeller
			,Case When ISNULL(PeakDPDDate,'')<>'' Then Convert(Date,PeakDPDDate) Else NULL END PeakDPD_Date
			
			,'NP'	
			,@Timekey
			,49999	
			,@UserLoginID	
			,GETDATE()
			
			 
		FROM BuyoutUploadDetails_stg
		where filname=@FilePathUpload 


		
		

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

		
		---------------------------------------------------------ChangeField Logic---------------------
		----select * from AccountLvlMOCDetails_stg
	IF OBJECT_ID('TempDB..#Buyout_Upload') Is Not Null
	Drop Table #Buyout_Upload

	Create TAble #Buyout_Upload
	(
	AccountNo Varchar(30), FieldName Varchar(50),SrNo Varchar(Max))

	Insert Into #Buyout_Upload(AccountNo,FieldName)
	-- Select SummaryID, 'AUNo' FieldName from BuyoutUploadDetails_stg Where isnull(AUNo,'')<>'' 
	--UNION ALL
	--Select AccountNo, 'DateofData' FieldName from BuyoutUploadDetails_stg Where isnull(DateofData,'')<>'' 
	--UNION ALL
	Select AccountNo, 'ReportDate' FieldName from BuyoutUploadDetails_stg Where isnull(ReportDate,'')<>''
	UNION ALL
	Select AccountNo, 'SchemeCode' FieldName from BuyoutUploadDetails_stg Where isnull(SchemeCode,'')<>'' 
	UNION ALL
	Select AccountNo, 'NPAClassificationwithSeller' FieldName from BuyoutUploadDetails_stg Where isnull(NPAClassificationwithSeller,'')<>'' 
	UNION ALL

	Select AccountNo, 'DateofNPAwithSeller' FieldName from BuyoutUploadDetails_stg Where isnull(DateofNPAwithSeller,'')<>'' 
	UNION ALL
	Select AccountNo, 'DPDwithSeller' FieldName from BuyoutUploadDetails_stg Where isnull(DPDwithSeller,'')<>'' 
	UNION ALL
	Select AccountNo, 'PeakDPDwithSeller' FieldName from BuyoutUploadDetails_stg Where isnull(PeakDPDwithSeller,'')<>'' 
	UNION ALL
	Select AccountNo, 'PeakDPDDate' FieldName from BuyoutUploadDetails_stg Where isnull(PeakDPDDate,'')<>''
		
		
		print 'nanda3'

	--select *
	Update B set B.SrNo=A.ScreenFieldNo
	from MetaScreenFieldDetail A
	Inner Join #Buyout_Upload B ON A.CtrlName=B.FieldName
	Where A.MenuId=@MenuId And A.IsVisible='Y'


		print 'nanda4'
	
				 IF OBJECT_ID('TEMPDB..#NEWTRANCHE')  IS NOT NULL
					DROP TABLE #NEWTRANCHE

					SELECT * INTO #NEWTRANCHE FROM(
					SELECT 
						 SS.AccountNo,
						STUFF((SELECT ',' + US.SrNo 
							FROM #Buyout_Upload US
							WHERE US.AccountNo = SS.AccountNo
							FOR XML PATH('')), 1, 1, '') [REPORTIDSLIST]
						FROM BuyoutUploadDetails_stg SS 
						GROUP BY SS.AccountNo
						)B
						ORDER BY 1

						--Select * from #NEWTRANCHE
					

					--SELECT * 
					UPDATE A SET A.ChangeFields=B.REPORTIDSLIST
					FROM DBO.BuyoutUploadDetails_Mod A
					INNER JOIN #NEWTRANCHE B ON A.CustomerAcID=B.AccountNo
					WHERE  A.EFFECTIVEFROMTIMEKEY<=@TimeKey AND A.EFFECTIVETOTIMEKEY>=@TimeKey
					And A.UploadID=@ExcelUploadId
	
		
		---DELETE FROM STAGING DATA
		 DELETE FROM BuyoutUploadDetails_stg
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
			BuyoutUploadDetails_Mod 
			SET 
			AuthorisationStatus	='1A'
			,ApprovedByFirstLevel	=@UserLoginID
			,DateApprovedFirstLevel	=GETDATE()
			
			WHERE UploadId=@UniqueUploadID

		

			
		   UPDATE 
		   ExcelUploadHistory
		   SET AuthorisationStatus='1A'
		   ,ApprovedByFirstLevel	=@UserLoginID
		   ,DateApprovedFirstLevel	=GETDATE()
		   where UniqueUploadID=@UniqueUploadID
		   and UploadType='Buyout Upload'
	END

--------------------------------------------

	IF (@OperationFlag=20)----AUTHORIZE

	BEGIN
		
		UPDATE 
			BuyoutUploadDetails_Mod 
			SET 
			AuthorisationStatus	='A'
			,ApprovedBy	=@UserLoginID
			,DateApproved	=GETDATE()
			
			WHERE UploadId=@UniqueUploadID

		
			


			
			INSERT INTO [BuyoutUploadDetails]
		(
			SlNo
		
			,DateofData
			,ReportDate
			,CustomerAcID
			,SchemeCode
			,NPA_ClassSeller
			,NPA_DateSeller
			,DPD_Seller
			,PeakDPD
			,PeakDPD_Date
			,AuthorisationStatus	
			,EffectiveFromTimeKey	
			,EffectiveToTimeKey	
			,CreatedBy	
			,DateCreated
			,ApprovedBy
			,DateApproved
				
		)

		SELECT
			SlNo
			,NULL
			,Case When ISNULL(ReportDate,'')<>'' Then Convert(Date,ReportDate) Else NULL END ReportDate
			
			,CustomerAcID
			,SchemeCode
			, NPA_ClassSeller
			,Case When ISNULL(NPA_DateSeller,'')<>'' Then Convert(Date,NPA_DateSeller) Else NULL END NPA_DateSeller
			,DPD_Seller
			,PeakDPD
			,Case When ISNULL(PeakDPD_Date,'')<>'' Then Convert(Date,PeakDPD_Date) Else NULL END PeakDPD_Date
			
			,'A'	
			,@Timekey
			,49999	
			,CreatedBy	
			,DateCreated
			,@UserLoginID	
			,GETDATE()
			
			 
		FROM BuyoutUploadDetails_Mod A
	    WHERE  A.UploadId=@UniqueUploadID and A.EffectiveToTimeKey>=@Timekey

		--Case When ISNULL(NPA_ClassSeller,'') IN('','NULL') then NULL When ISNULL(NPA_ClassSeller,'')<>'' Then NPA_ClassSeller Else NULL END
			
---------------------------------------------
/*--------------------Adding Flag To AdvAcOtherDetail------------Pranay 21-03-2021--------*/ 

  

				UPDATE
				ExcelUploadHistory
				SET AuthorisationStatus='A',ApprovedBy=@UserLoginID,DateApproved=GETDATE()
				WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
				AND UniqueUploadID=@UniqueUploadID
				AND UploadType='Buyout Upload'

				


	END

	IF (@OperationFlag=17)----REJECT

	BEGIN
		
		UPDATE 
			BuyoutUploadDetails_Mod 
			SET 
			AuthorisationStatus	='R'
			,ApprovedByFirstLevel	=@UserLoginID
			,DateApprovedFirstLevel	=GETDATE()
			
			WHERE UploadId=@UniqueUploadID
			AND AuthorisationStatus='NP'

		
			----SELECT * FROM IBPCPoolDetail

			UPDATE
				ExcelUploadHistory
				SET AuthorisationStatus='R',ApprovedByFirstLevel=@UserLoginID,DateApprovedFirstLevel=GETDATE()
				WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
				AND UniqueUploadID=@UniqueUploadID
				AND UploadType='Buyout Upload'



	END
--------------------Two level Auth. Changes---------------

IF (@OperationFlag=21)----REJECT

	BEGIN
		
		UPDATE 
			BuyoutUploadDetails_Mod 
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
				AND UploadType='Buyout Upload'



	END
---------------------------------------------------------------------
END

IF @OperationFlag IN (1,2,3,16,17,18,20,21) AND @AuthMode ='Y'
		BEGIN
					print 'log table'

					declare @DateCreated datetime
				SET	@DateCreated     =Getdate()

				declare @ReferenceID1 varchar(max)
				set @ReferenceID1 = (case when @OperationFlag in (16,20,21) then @UniqueUploadID else @ExcelUploadId end)


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
		SET @Result=CASE WHEN  @OperationFlag=1 AND @MenuId=1466 THEN @ExcelUploadId 
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