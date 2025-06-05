SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROCEDURE  [dbo].[BuyOutStageDataInUp]
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

		IF NOT (EXISTS (SELECT 1 FROM BuyoutDetails_stg  where filname=@FilePathUpload))

							BEGIN
									 --Rollback tran
									SET @Result=-8

								RETURN @Result
							END
			


		IF EXISTS(SELECT * FROM BuyoutDetails_stg WHERE FILNAME=@FilePathUpload)
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

		   PRINT @@ROWCOUNT

		   DECLARE @ExcelUploadId INT
	SET 	@ExcelUploadId=(SELECT MAX(UniqueUploadID) FROM  ExcelUploadHistory)
		
			Insert into UploadStatus (FileNames,UploadedBy,UploadDateTime,UploadType)
		Values(@filepath,@UserLoginID ,GETDATE(),'Buyout Upload')

		--alter table BuyoutDetails_Mod
		--Add Action char(1)

	

		INSERT INTO BuyoutDetails_Mod
		(
			 SlNo
			,UploadID
			,SummaryID
			,CIFId
			,ENBDAcNo
			,BuyoutPartyLoanNo
			,PartnerDPD 
			,PartnerDPDAsOnDate
			,PartnerAssetClass
			,PartnerNPADate
			,AuthorisationStatus	
			,EffectiveFromTimeKey	
			,EffectiveToTimeKey	
			,CreatedBy	
			,DateCreated
			--,Action

		)

		SELECT
			 SlNo
			,@ExcelUploadId
			,SummaryID
			,CIFId
			 ,UTKSACNo --,ENBDAcNo
			,BuyoutPartyLoanNo
			,PartnerDPD 
			,PartnerDPDAsOnDate
			,PartnerAssetClass
			,PartnerNPADate
			,'NP'	
			,@Timekey
			,49999	
			,@UserLoginID	
			,GETDATE()
			--,Action
			
			 
		FROM BuyoutDetails_stg
		where FilName=@FilePathUpload 



	
		Declare @SummaryId int
		Set @SummaryId=IsNull((Select Max(SummaryId) from BuyoutSummary_Mod),0)


		print 'nanda123'
		---------------------------------------------------------ChangeField Logic---------------------
		----select * from AccountLvlMOCDetails_stg
	IF OBJECT_ID('TempDB..#Buyout_Upload') Is Not Null
	Drop Table #Buyout_Upload

	Create TAble #Buyout_Upload
	(
	CIFId Varchar(30), FieldName Varchar(50),SrNo Varchar(Max))

	Insert Into #Buyout_Upload(CIFId,FieldName)
	-- Select SummaryID, 'AUNo' FieldName from BuyoutDetails_stg Where isnull(AUNo,'')<>'' 
	--UNION ALL
	Select CIFId, /*'ENBDAcNo'*/ 'UTKSAcNo' FieldName from BuyoutDetails_stg Where isnull(UTKSAcNo,'')<>'' 
	UNION ALL
	Select CIFId, 'BuyoutPartyLoanNo' FieldName from BuyoutDetails_stg Where isnull(BuyoutPartyLoanNo,'')<>''
	UNION ALL
	Select CIFId, 'PartnerDPD' FieldName from BuyoutDetails_stg Where isnull(PartnerDPD,'')<>'' 
	UNION ALL
	Select CIFId, 'PartnerDPDAsOnDate' FieldName from BuyoutDetails_stg Where isnull(PartnerDPDAsOnDate,'')<>'' 
	UNION ALL
	Select CIFId, 'PartnerAssetClass' FieldName from BuyoutDetails_stg Where isnull(PartnerAssetClass,'')<>'' 
	UNION ALL
	Select CIFId, 'PartnerNPADate' FieldName from BuyoutDetails_stg Where isnull(PartnerNPADate,'')<>''
		
		
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
						 SS.CIFId,
						STUFF((SELECT ',' + US.SrNo 
							FROM #Buyout_Upload US
							WHERE US.CIFId = SS.CIFId
							FOR XML PATH('')), 1, 1, '') [REPORTIDSLIST]
						FROM BuyoutDetails_stg SS 
						GROUP BY SS.CIFId
						)B
						ORDER BY 1

						--Select * from #NEWTRANCHE

					--SELECT * 
					UPDATE A SET A.ChangeFields=B.REPORTIDSLIST
					FROM DBO.BuyoutDetails_Mod A
					INNER JOIN #NEWTRANCHE B ON A.CIFId=B.CIFId
					WHERE  A.EFFECTIVEFROMTIMEKEY<=@TimeKey AND A.EFFECTIVETOTIMEKEY>=@TimeKey
					And A.UploadID=@ExcelUploadId


print 'nanda1234'
		

		PRINT @@ROWCOUNT
		
		---DELETE FROM STAGING DATA
		 DELETE FROM BuyoutDetails_stg
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
			BuyoutDetails_Mod 
			SET 
			AuthorisationStatus	='1A'
			,ApprovedByFirstLevel=@UserLoginID
			,DateApprovedFirstLevel=getdate()	
			
			WHERE UploadId=@UniqueUploadID

			UPDATE 
			BuyoutSummary_Mod 
			SET 
			AuthorisationStatus	='1A'
			,ApprovedByFirstLevel=@UserLoginID
			,DateApprovedFirstLevel=getdate()	
			
			WHERE UploadId=@UniqueUploadID

			
		   UPDATE 
		   ExcelUploadHistory
		   SET AuthorisationStatus='1A'
		   ,ApprovedByFirstLevel=@UserLoginID
			,DateApprovedFirstLevel=getdate()	
		   where UniqueUploadID=@UniqueUploadID
		   and UploadType='Buyout Upload'
	END

--------------------------------------------

	IF (@OperationFlag=20)----AUTHORIZE

	BEGIN
		
		UPDATE 
			BuyoutDetails_Mod 
			SET 
			AuthorisationStatus	='A'
			,ApprovedBy	=@UserLoginID
			,DateApproved	=GETDATE()
			
			WHERE UploadId=@UniqueUploadID

			UPDATE 
			BuyoutSummary_Mod 
			SET 
			AuthorisationStatus	='A'
			,ApprovedBy	=@UserLoginID
			,DateApproved	=GETDATE()
			
			WHERE UploadId=@UniqueUploadID

--select * from BuyoutDetails_Mod

		----------------New add  for Action 03112022--------------- 
		--	Update  A
		--	Set A.EffectiveToTimeKey=A.EffectiveFromTimeKey-1
		--	from BuyoutDetails_MOD A
			
		--	Where A.UploadId=@UniqueUploadID
		--	And a.AuthorisationStatus in('A','R')
		--	AND A.EffectiveToTimeKey >=49999

-------------------------------------------------------------
--------------New add  for Action --------------- 



			Update  A
			Set A.EffectiveToTimeKey=A.EffectiveFromTimeKey-1
			from BuyoutDetails A
			inner join BuyoutDetails_Mod B
			ON A.BuyoutPartyLoanNo=B.BuyoutPartyLoanNo
			AND B.EffectiveFromTimeKey <=@Timekey
			AND B.EffectiveToTimeKey >=@Timekey
			Where B.UploadId=@UniqueUploadID
			And B.AuthorisationStatus in('A','R')
			AND A.EffectiveToTimeKey >=49999
-----------------------------------------------------------
			-----maintain history
			--alter table BuyoutDetails
			--add Action char(1)
			

			INSERT INTO BuyoutDetails
			(SummaryID
						,SlNo
						,CIFId
			,ENBDAcNo
			,BuyoutPartyLoanNo
			,PartnerDPD 
			,PartnerDPDAsOnDate
			,PartnerAssetClass
			,PartnerNPADate
						,AuthorisationStatus
						,EffectiveFromTimeKey
						,EffectiveToTimeKey
						,CreatedBy
						,DateCreated
						,ModifyBy
						,DateModified
						,ApprovedBy
						,DateApproved
						--,Action
						)
			SELECT SummaryID
					,SlNo
					,CIFId
			,ENBDAcNo
			,BuyoutPartyLoanNo
			,PartnerDPD 
			,PartnerDPDAsOnDate
			,PartnerAssetClass
			,PartnerNPADate
					,AuthorisationStatus
					,@Timekey,
					49999
					,CreatedBy
					,DateCreated
					,ModifyBy
					,DateModified
					,@UserLoginID
					,Getdate()
					--,Action
			FROM BuyoutDetails_Mod A
			WHERE  A.UploadId=@UniqueUploadID and  EffectiveToTimeKey>=@Timekey
			and A.AuthorisationStatus  in ('A')
----select * from BuyoutSummary
----			--Alter Table BuyoutSummary
----			--add Action Char(1)

----			Update  A
----			Set A.EffectiveToTimeKey=A.EffectiveFromTimeKey-1
----			from BuyoutSummary A
----			inner join BuyoutDetails_Mod B
----			ON A.AccountID=B.AccountID
----			AND B.EffectiveFromTimeKey <=@Timekey
----			AND B.EffectiveToTimeKey >=@Timekey
----			Where B.UploadId=@UniqueUploadID
----			AND A.EffectiveToTimeKey >=49999
----			And B.Action in('A','R')
                
				

			INSERT INTO BuyoutSummary(
					SummaryID
					,CIFId
			,ENBDAcNo
			,BuyoutPartyLoanNo
			,PartnerDPD 
			,PartnerDPDAsOnDate
			,PartnerAssetClass
			,PartnerNPADate
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
					,CIFId
			,ENBDAcNo
			,BuyoutPartyLoanNo
			,PartnerDPD 
			,PartnerDPDAsOnDate
			,PartnerAssetClass
			,PartnerNPADate
					,AuthorisationStatus
					,@Timekey,49999
					,CreatedBy
					,DateCreated
					,ModifyBy
					,DateModified
					,@UserLoginID
					,Getdate()
					FROM BuyoutSummary_Mod A
			WHERE  A.UploadId=@UniqueUploadID and EffectiveToTimeKey>=@Timekey





			---------------Insert into Final Tables ----------
		---- updated on 02/01/2024  by nikhil------
			Update  A
			Set A.EffectiveToTimeKey=A.EffectiveFromTimeKey-1
			from BuyoutDetails_MOD A
			
			Where A.UploadId=@UniqueUploadID
			And a.AuthorisationStatus in('A','R')
			AND A.EffectiveToTimeKey >=49999
       ------------------------------------------------------------

			Update  A
			Set A.EffectiveToTimeKey=A.EffectiveFromTimeKey-1
			from BuyoutFinalDetails A
			inner join BuyoutDetails_Mod B
			ON A.BuyoutPartyLoanNo=B.BuyoutPartyLoanNo
			AND B.EffectiveFromTimeKey <=@Timekey
			AND B.EffectiveToTimeKey >=@Timekey
			Where B.UploadId=@UniqueUploadID
			AND A.EffectiveToTimeKey >=49999
			And B.AuthorisationStatus  in('A','R')

			----alter table BuyoutFinalDetails
			----add Action char(1)

			Insert into BuyoutFinalDetails
			(
			SummaryID
			,SlNo
			,CIFId
			,ENBDAcNo
			,BuyoutPartyLoanNo
			,PartnerDPD 
			,PartnerDPDAsOnDate
			,PartnerAssetClass
			,PartnerNPADate
			,AuthorisationStatus
			,EffectiveFromTimeKey
			,EffectiveToTimeKey
			,CreatedBy
			,DateCreated
			,ModifyBy
			,DateModified
			,ApprovedBy
			,DateApproved
			--,Action
			)
			SELECT SummaryID
					,SlNo
					,CIFId
			,ENBDAcNo
			,BuyoutPartyLoanNo
			,PartnerDPD 
			,PartnerDPDAsOnDate
			,PartnerAssetClass
			,PartnerNPADate
					,AuthorisationStatus
					,@Timekey,49999
					,CreatedBy
					,DateCreated
					,ModifyBy
					,DateModified
					,@UserLoginID
					,Getdate()
					--,Action
			FROM BuyoutDetails_Mod A
			WHERE  A.UploadId=@UniqueUploadID and EffectiveToTimeKey<=@Timekey
			--and EffectiveToTimeKey>=@Timekey
			AND A.AuthorisationStatus  IN ('A')

			---Summary Final -----------

			Insert into BuyoutFinalSummary
			(
			SummaryID
			,CIFId
			,ENBDAcNo
			,BuyoutPartyLoanNo
			,PartnerDPD 
			,PartnerDPDAsOnDate
			,PartnerAssetClass
			,PartnerNPADate
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
					,CIFId
			,ENBDAcNo
			,BuyoutPartyLoanNo
			,PartnerDPD 
			,PartnerDPDAsOnDate
			,PartnerAssetClass
			,PartnerNPADate
					,AuthorisationStatus
					,@Timekey,49999
					,CreatedBy
					,DateCreated
					,ModifyBy
					,DateModified
					,@UserLoginID
					,Getdate()
					FROM BuyoutSummary_Mod A
			WHERE  A.UploadId=@UniqueUploadID and EffectiveToTimeKey>=@Timekey

--------------------------------------------- COMMENTED 01112022---------------------
/*--------------------Adding Flag To AdvAcOtherDetail------------Pranay 21-03-2021--------*/ 

--  UPDATE A
--	SET  
--        A.SplFlag=CASE WHEN ISNULL(A.SplFlag,'')='' THEN 'Buyout'     
--						ELSE A.SplFlag+','+'Buyout'     END
		   
--   FROM DBO.AdvAcOtherDetail A
--   --INNER JOIN #Temp V  ON A.AccountEntityId=V.AccountEntityId
--  INNER JOIN BuyoutDetails_Mod B ON A.RefSystemAcId=B.BuyoutPartyLoanNo
--			WHERE  B.UploadId=@UniqueUploadID and B.EffectiveToTimeKey>=@Timekey
--			AND A.EffectiveToTimeKey=49999

-------------------Remove ACTION R
-- UPDATE A
--	SET  
--        A.SplFlag=REPLACE(A.SplFlag,',Buyout','') 
					
		   
--   FROM DBO.AdvAcOtherDetail A
--   --INNER JOIN #Temp V  ON A.AccountEntityId=V.AccountEntityId
--  INNER JOIN BuyoutDetails_Mod B ON A.RefSystemAcId=B.BuyoutPartyLoanNo
--			WHERE  B.UploadId=@UniqueUploadID and B.EffectiveToTimeKey>=@Timekey
--			AND A.EffectiveToTimeKey=49999
--			And B.Action='R'
----------------------------------------------------------------------

--			UPDATE A
--			SET 
--			A.PrincipalOutstanding=ROUND(B.PrincipalOutstanding,2)
--			,a.ModifyBy=@UserLoginID
--			,a.DateModified=GETDATE()
--			FROM BuyoutDetails A
--			INNER JOIN BuyoutDetails_Mod B ON (A.EffectiveFromTimeKey<=@Timekey AND A.EffectiveToTimeKey>=@Timekey)
--																AND  (B.EffectiveFromTimeKey<=@Timekey AND B.EffectiveToTimeKey>=@Timekey)	
--																AND A.BuyoutPartyLoanNo=B.BuyoutPartyLoanNo

--				WHERE B.AuthorisationStatus='A'
--				AND B.UploadId=@UniqueUploadID

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
			BuyoutDetails_Mod 
			SET 
			AuthorisationStatus	='R'
			,ApprovedByFirstLevel	=@UserLoginID
			,DateApprovedFirstLevel	=GETDATE()
			
			WHERE UploadId=@UniqueUploadID
			AND AuthorisationStatus='NP'

			UPDATE 
			BuyoutSummary_Mod 
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
			BuyoutDetails_Mod 
			SET 
			AuthorisationStatus	='R'
			,ApprovedBy	=@UserLoginID
			,DateApproved	=GETDATE()
			
			WHERE UploadId=@UniqueUploadID
			AND AuthorisationStatus in ('NP','1A')

			UPDATE 
			BuyoutSummary_Mod 
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