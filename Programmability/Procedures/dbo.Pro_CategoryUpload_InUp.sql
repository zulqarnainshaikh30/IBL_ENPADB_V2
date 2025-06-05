SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE  [dbo].[Pro_CategoryUpload_InUp]
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

--DECLARE @Timekey INT=25999,
--	@UserLoginID VARCHAR(100)=N'fnachecker',
--	@OperationFlag INT=N'1',
--	@MenuId INT=N'1468',
--	@AuthMode	CHAR(1)=N'N',
--	@filepath VARCHAR(MAX)=N'ProvisionCategoryUpload (1).xlsx',
--	@EffectiveFromTimeKey INT=25999,
--	@EffectiveToTimeKey	INT=49999,
--    @Result		INT=0 ,
--	@UniqueUploadID INT=NULL
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

	----declare @UserLoginID VARCHAR(100)=N'fnachecker',@filepath VARCHAR(MAX)=N'ProvisionCategoryUpload (1).xlsx'
	DECLARE @FilePathUpload	VARCHAR(100)
				   SET @FilePathUpload=@UserLoginId+'_'+@filepath
					PRINT '@FilePathUpload'
					PRINT @FilePathUpload
					--fnachecker_ProvisionCategoryUpload (1).xlsx
		BEGIN TRY

		--BEGIN TRAN
		
IF (@MenuId=1468)
BEGIN

	IF (@OperationFlag=1)

	BEGIN
	--select * from categorydetails_stg filname

		IF NOT (EXISTS (SELECT 1 FROM categorydetails_stg  where filname=@FilePathUpload))
		
							BEGIN
                           --Rollback tran
									SET @Result=-8
									print 'an'
								print '123'
								RETURN @Result
						END

--select * from ExcelUploadHistory
		IF EXISTS(SELECT 1 FROM categorydetails_stg WHERE filname=@FilePathUpload)
		BEGIN
		print '321'
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
		   ,'Provision Category Upload'
		   ,@EffectiveFromTimeKey
		   ,@EffectiveToTimeKey
		   ,@UserLoginID
		   ,GETDATE()

		   PRINT @@ROWCOUNT

		   DECLARE @ExcelUploadId INT
	SET 	@ExcelUploadId=(SELECT MAX(UniqueUploadID) FROM  ExcelUploadHistory)
		
			Insert into UploadStatus (FileNames,UploadedBy,UploadDateTime,UploadType)
		Values(@filepath,@UserLoginID ,GETDATE(),'Provision Category Upload')
 Print 'A'
		INSERT INTO AcCatUploadHistory_mod
		(    
SlNo
,UPLOADID
,ACID
,CustomerID
,CategoryID
,Action
			,AuthorisationStatus	
			,EffectiveFromTimeKey	
			,EffectiveToTimeKey	
			,CreatedBy	
			,DateCreated
	

		)

		SELECT
			SlNo
			,@ExcelUploadId
			       
            ,ACID
            ,CustomerID
            ,CategoryID
            ,Action
			,'NP'	
			,@Timekey
			,49999	
			,@UserLoginID
			,GETDATE()
			
			 
		FROM categorydetails_stg
		where FilName=@FilePathUpload
		/*
--------------------------------------------------Max percent
IF OBJECT_ID('TEMPDB..#EXISTDATA')IS NOT NULL
				DROP TABLE #EXISTDATA
				Declare @ProvisionPercent decimal(10,0)
								SELECT A.ACID
								, @ProvisionPercent=MAX(D.Provisionsecured)ProvisionPercent						
								--,d.provisionname
								 INTO #EXISTDATA	 
								 FROM categorydetails_stg A
								--INNER JOIN AdvAcBasicDetail B
								--			on B.CustomerAcId=A.acid
									INNER JOIN DimProvision_SegStd D
											ON A.CategoryID=D.BankCategoryID   
											group by A.ACID 

											--update STD_ProvDetail


	--				Select A.ACID,@ProvisionPercent=(case when A.ProvisionPercent>E.ProvisionPercent  then 1 else 0 end )from(																	
	--SELECT A.ACID, MAX(D.Provisionsecured)ProvisionPercent	 FROM AcCatUploadHistory A --
	--inner join  DimProvision_SegStd D on A.CategoryID=D.BankCategoryID  group by A.ACID
	--)A inner join  #EXISTDATA E on A.ACID=E.ACID

	--IF (@ProvisionPercent =1)
	--Begin
	*/
	
	--End



		---------------------------------------------------------ChangeField Logic---------------------
		----select * from AccountLvlMOCDetails_stg
	IF OBJECT_ID('TempDB..#categorydetails_upload') Is Not Null
	Drop Table #categorydetails_upload

	Create TAble #categorydetails_upload
	(
	ACID Varchar(30), FieldName Varchar(50),SrNo Varchar(Max))

	Insert Into #categorydetails_upload(ACID,FieldName)
	 Select ACID, 'SrNo' FieldName from categorydetails_stg Where isnull(SlNo,'')<>'' 
	UNION ALL
	Select ACID, 'Amount' FieldName from categorydetails_stg Where isnull(CategoryID,'')<>'' 
	UNION ALL
	Select ACID, 'Action' FieldName from categorydetails_stg Where isnull(Action,'')<>'' 
	
		print 'nanda3'

	--select *
	Update B set B.SrNo=A.ScreenFieldNo
	from MetaScreenFieldDetail A
	Inner Join #categorydetails_upload B ON A.CtrlName=B.FieldName
	Where A.MenuId=@MenuId And A.IsVisible='Y'


		print 'nanda4'
	
				 IF OBJECT_ID('TEMPDB..#NEWTRANCHE1')  IS NOT NULL
					DROP TABLE #NEWTRANCHE1

					SELECT * INTO #NEWTRANCHE1 FROM(
					SELECT 
						 SS.ACID,
						STUFF((SELECT ',' + US.SrNo 
							FROM #categorydetails_upload US
							WHERE US.ACID = SS.ACID
							FOR XML PATH('')), 1, 1, '') [REPORTIDSLIST]
						FROM categorydetails_stg SS 
						GROUP BY SS.ACID
						)B
						ORDER BY 1

						--Select * from #NEWTRANCHE

					--SELECT * 
					UPDATE A SET A.ChangeFields=B.REPORTIDSLIST
					FROM DBO.AcCatUploadHistory_mod A
					INNER JOIN #NEWTRANCHE1 B ON A.ACID=B.ACID
					WHERE  A.EFFECTIVEFROMTIMEKEY<=@TimeKey AND A.EFFECTIVETOTIMEKEY>=@TimeKey
					And A.UploadID=@ExcelUploadId


				
--------------------------------------------------------------------------------------

		--select * from categorydetails_stg
		--select * from AcCatUploadHistory
		--select * from DimProvision_SegStd
		--select ProvisionAlt_Key,* from STD_ProvDetail
/*
		Declare @SummaryId int
		Set @SummaryId=IsNull((Select Max(SummaryId) from IBPCPoolSummary_Mod),0)

		INSERT INTO IBPCPoolSummary_stg
		(
			UploadID
			,SummaryID
			,PoolID
			,PoolName
			,PoolType
			,BalanceOutstanding
			,NoOfAccount
			,IBPCExposureAmt
			,IBPCReckoningDate
			,IBPCMarkingDate
			,MaturityDate
			,TotalPosBalance
			,TotalInttReceivable
		)

		SELECT
			@ExcelUploadId
			,@SummaryId+Row_Number() over(Order by PoolID)
			,PoolID
			,PoolName
			,PoolType
			,Sum(IsNull(Cast(PrincipalOutstandinginRs as decimal(16,2)),0)+IsNull(Cast(InterestReceivableinRs as Decimal(16,2)),0))
			,Count(PoolID)
			,SUM(ISNULL(Cast(IBPCExposureinRs as Decimal(16,2)),0))
			,DateofIBPCreckoning
			,DateofIBPCmarking
			,MaturityDate
			,Sum(IsNull(Cast(PrincipalOutstandinginRs as decimal(16,2)),0))
			,Sum(IsNull(Cast(InterestReceivableinRs as Decimal(16,2)),0))
		FROM IBPCPoolDetail_stg
		where FilName=@FilePathUpload
		Group by PoolID,PoolName,PoolType,DateofIBPCreckoning,DateofIBPCmarking,MaturityDate

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
*/
		PRINT @@ROWCOUNT
		
		---DELETE FROM STAGING DATA
		 DELETE FROM categorydetails_stg
		 WHERE FilName=@FilePathUpload

		 ----RETURN @ExcelUploadId

END
		   ----DECLARE @UniqueUploadID INT
	--SET 	@UniqueUploadID=(SELECT MAX(UniqueUploadID) FROM  ExcelUploadHistory)
	END
	
	IF (@OperationFlag=16)----AUTHORIZE

	BEGIN
		
		UPDATE 
			AcCatUploadHistory_MOD 
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
		   AND UploadType='Provision Category Upload'
	END

	IF (@OperationFlag=20)----AUTHORIZE

	BEGIN
		
		UPDATE 
			AcCatUploadHistory_MOD 
			SET 
			AuthorisationStatus	='A'
			,ApprovedBy	=@UserLoginID
			,DateApproved	=GETDATE()
			
			WHERE UploadId=@UniqueUploadID

			--UPDATE 
			--IBPCPoolSummary_MOD 
			--SET 
			--AuthorisationStatus	='A'
			--,ApprovedBy	=@UserLoginID
			--,DateApproved	=GETDATE()
			
			--WHERE UploadId=@UniqueUploadID
			--select * from AcCatUploadHistory
			-----maintain history

			--Select * 

			Update A Set A.FinalProv='N'
			from AcCatUploadHistory A
			Inner Join AcCatUploadHistory_MOD B ON A.ACID=B.ACID  And B.EffectiveToTimeKey=49999
			Where A.EffectiveToTimeKey=49999 and B.UploadId=@UniqueUploadID
			
			Update A Set A.EffectiveToTimeKey=@Timekey-1
			from AcCatUploadHistory A
			Inner Join AcCatUploadHistory_MOD B ON A.ACID=B.ACID And A.CategoryID=B.CategoryID And B.EffectiveToTimeKey=49999
			Where A.EffectiveToTimeKey=49999 and B.Action='R' And  B.UploadId=@UniqueUploadID

			Update A Set A.EffectiveToTimeKey=@Timekey-1
			from AcCatUploadHistory A
			Inner Join AcCatUploadHistory_MOD B ON A.ACID=B.ACID 
			AND B.EffectiveToTimeKey=49999
			Where A.EffectiveToTimeKey=49999 And  B.UploadId=@UniqueUploadID


			INSERT INTO AcCatUploadHistory
			            (SlNo
                        ,UPLOADID
                         ,ACID
                         ,CustomerID
                         ,CategoryID
                         ,Action
						,AuthorisationStatus
						,EffectiveFromTimeKey
						,EffectiveToTimeKey
						,CreatedBy
						,DateCreated
						,ModifyBy
						,DateModified
						,ApprovedBy
						,DateApproved
						,FinalProv
						)
			SELECT SlNo
                        ,@UniqueUploadID
                         ,ACID
   ,CustomerID
                         ,CategoryID
                         ,Action
						 ,AuthorisationStatus
					,@Timekey,49999
					,CreatedBy
					,DateCreated
					,ModifyBy
					,DateModified
					,@UserLoginID
					,Getdate()
					,'Y'
				
			FROM AcCatUploadHistory_MOD A
			WHERE  A.UploadId=@UniqueUploadID and EffectiveToTimeKey>=@Timekey



	/*		-------------------In Main Table -----------------------
			IF OBJECT_ID('TempDB..#STD') IS NOT NULL
			Drop Table #STD

			Select ACID,
			Case when A.ACID IS NULL Then 113 Else B.BankCategoryID End BankCategoryID,
			Case when A.ACID IS NULL Then 13 Else B.ProvisionAlt_Key End ProvisionAlt_Key,
			Case when A.ACID IS NULL Then .40 Else B.ProvisionSecured ENd ProvisionSecured
			into #STD
			from STD_ProvDetail S
			right Join AcCatUploadHistory_Mod A 
			ON S.CustomerAcId=A.ACID and A.EffectiveToTimeKey>=@Timekey And A.Action='A'
			Left Join DimProvision_SegStd B On A.CategoryID=B.BankCategoryID 
			and B.EffectiveToTimeKey>=@Timekey and B.EffectiveFromTimeKey<=@Timekey
			where A.EffectiveToTimeKey>=@Timekey AND A.EffectiveFromTimeKey<=@Timekey
			
			IF OBJECT_ID('TempDB..#STD1') IS NOT NULL
			Drop Table #STD1
			
			Select A.* into #STD1 from #STD A
			Inner Join (Select ACID,Max(ProvisionSecured)ProvisionSecured from #STD Group By ACID) B ON A.ACID=B.ACID And A.ProvisionSecured=B.ProvisionSecured

			--Select * 
			
			Update A set A.EffectiveToTimeKey=@Timekey-1
			from STD_ProvDetail A
			Inner Join #STD1 B ON A.CustomerAcId=B.ACID
			Where A.EffectiveToTimeKey=49999
*/

			Update A Set A.EffectiveToTimeKey=@Timekey-1
			from STD_ProvDetail A
			Inner Join AcCatUploadHistory_MOD B 
			ON A.CustomerAcId=B.ACID
			 And B.EffectiveToTimeKey>=@Timekey
			inner join DimProvision_SegStd C on B.CategoryID = C.BankCategoryID 
			and c.ProvisionAlt_Key=a.ProvisionAlt_Key
			Where A.EffectiveToTimeKey>=@Timekey and B.Action='R' And  B.UploadId=@UniqueUploadID

			Update A Set A.EffectiveToTimeKey=@Timekey-1
			from STD_ProvDetail A
			Inner Join AcCatUploadHistory_MOD B 
			ON A.CustomerAcId=B.ACID
			 And B.EffectiveToTimeKey>=@Timekey
			--inner join DimProvision_SegStd C on B.CategoryID = C.BankCategoryID 
			--and c.ProvisionAlt_Key=a.ProvisionAlt_Key
			Where A.EffectiveToTimeKey>=@Timekey And  B.UploadId=@UniqueUploadID


			Insert into STD_ProvDetail
			(
			CustomerID
			,CustomerAcId
			,CustomerEntityID
			,AccountEntityID
			,ProvisionAlt_Key
			,AuthorisationStatus
			,EffectiveFromTimeKey
			,EffectiveToTimeKey
			,CreatedBy
			,DateCreated
			,ApprovedBy
			,DateApproved
			)
		Select 

			 CustomerID
			,ACID
			,C.CustomerEntityId
			,C.AccountEntityId
			,B.ProvisionAlt_Key
			,A.AuthorisationStatus
			,@Timekey EffectiveFromTimeKey
			,49999 EffectiveToTimeKey
			,A.CreatedBy
			,A.DateCreated
			,A.ApprovedBy
			,A.DateApproved
			

			FROM AcCatUploadHistory_MOD A
			inner join AdvAcBasicDetail C
			on A.ACID=C.CustomerACID and C.EffectiveFromTimeKey<=@Timekey and C.EffectiveToTimeKey>=@Timekey
			inner join DimProvision_SegStd B
			on A.CategoryID=B.BankCategoryID and B.EffectiveFromTimeKey<=@Timekey and B.EffectiveToTimeKey>=@Timekey
			WHERE  A.UploadId=@UniqueUploadID and A.EffectiveToTimeKey>=@Timekey
			and A.Action<>'R'
			--From STD_ProvDetail A
			--RIGHT JOIN #STD1 B ON A.CustomerAcId=B.ACID
			--LEFT Join (Select Max(Entitykey)Entitykey,CustomerAcid from std_provdetail 
			--where EffectiveToTimeKey=@Timekey-1 Group By CustomerAcid)C ON A.CustomerAcid=C.CustomerAcid And A.Entitykey=C.Entitykey
			--Where A.EffectiveToTimeKey=@Timekey-1












----------------------------------------------------------------------------------------------------------


			UPDATE A
			SET 
			--A.POS=ROUND(B.POS,2)
			a.ModifyBy=B.ModifyBy
			,a.DateModified=B.DateModified
			FROM AcCatUploadHistory A
			INNER JOIN AcCatUploadHistory_MOD  B ON (A.EffectiveFromTimeKey<=@Timekey AND A.EffectiveToTimeKey>=@Timekey)
																AND  (B.EffectiveFromTimeKey<=@Timekey AND B.EffectiveToTimeKey>=@Timekey)	
																AND A.ACID=B.ACID

				WHERE B.AuthorisationStatus='A'
				AND B.UploadId=@UniqueUploadID

				UPDATE
				ExcelUploadHistory
				SET AuthorisationStatus='A',ApprovedBy=@UserLoginID,DateApproved=GETDATE()
				WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
				AND UniqueUploadID=@UniqueUploadID
				AND UploadType='Provision Category Upload'

				


	END
	-------------------------------------------------------------------


		IF (@OperationFlag=21)----REJECT

	BEGIN
		
		UPDATE 
			AcCatUploadHistory_MOD 
			SET 
			AuthorisationStatus	='R'
			,ApprovedBy	=@UserLoginID
			,DateApproved	=GETDATE()
			,EffectiveToTimeKey =@EffectiveFromTimeKey-1 --Sp
			WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey --SP
			and UploadId=@UniqueUploadID
			AND AuthorisationStatus in('NP','1A')

			--UPDATE 
			--IBPCPoolSummary_MOD 
			--SET 
			--AuthorisationStatus	='R'
			--,ApprovedBy	=@UserLoginID
			--,DateApproved	=GETDATE()
			
			--WHERE UploadId=@UniqueUploadID
			--AND AuthorisationStatus='NP'
			------SELECT * FROM IBPCPoolDetail

			UPDATE
				ExcelUploadHistory
				SET AuthorisationStatus='R',ApprovedBy=@UserLoginID,DateApproved=GETDATE()
				WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
				AND UniqueUploadID=@UniqueUploadID
				AND UploadType='Provision Category Upload'

	END

--------------------------------------------------------------------
	IF (@OperationFlag=17)----REJECT

	BEGIN
		


		UPDATE 
			AcCatUploadHistory_MOD 
			SET 
			AuthorisationStatus	='R'
			,ApprovedByFirstLevel	=@UserLoginID
			,DateApprovedFirstLevel	=GETDATE()
			,EffectiveToTimeKey =@EffectiveFromTimeKey-1 --Sp
			WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey --SP
			and UploadId=@UniqueUploadID
			AND AuthorisationStatus='NP'

			--UPDATE 
			--IBPCPoolSummary_MOD 
			--SET 
			--AuthorisationStatus	='R'
			--,ApprovedBy	=@UserLoginID
			--,DateApproved	=GETDATE()
			
			--WHERE UploadId=@UniqueUploadID
			--AND AuthorisationStatus='NP'
			------SELECT * FROM IBPCPoolDetail

			UPDATE
				ExcelUploadHistory
				SET AuthorisationStatus='R',	
				ApprovedByFirstLevel	=@UserLoginID
			,DateApprovedFirstLevel	=GETDATE()
				WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
				AND UniqueUploadID=@UniqueUploadID
				AND UploadType='Provision Category Upload'

	END


END


	--COMMIT TRAN
		---SET @Result=CASE WHEN  @OperationFlag=1 THEN @UniqueUploadID ELSE 1 END
		SET @Result=CASE WHEN  @OperationFlag=1 AND @MenuId=1468 THEN @ExcelUploadId 
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