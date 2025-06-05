SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO




/*
declare @p11 int
set @p11=-1
exec [dbo].[CustNPAMOCStageDataInUp] @Authlevel=N'2',@TimeKey=25999,@UserLoginID=N'test_two',@OperationFlag=N'1',@MenuId=N'128',@AuthMode=N'Y',@filepath=N'CustlevelNPAMOCUpload.xlsx',@EffectiveFromTimeKey=25999,@EffectiveToTimeKey=49999,@UniqueUploadID=NU




LL,@Result=@p11 output
select @p11
go

*/
CREATE PROCEDURE  [dbo].[CustNPAMOCStageDataInUp]
	@Timekey INT,
	@UserLoginID VARCHAR(100),
	@OperationFlag INT,
	@MenuId INT,
	@AuthMode	CHAR(1),
	@filepath VARCHAR(MAX),
	@EffectiveFromTimeKey INT,
	@EffectiveToTimeKey	INT,
    @Result		INT=0 OUTPUT,
	@UniqueUploadID INT,
	@Authlevel varchar(5)

AS

--DECLARE @Timekey INT=25999,
--	@UserLoginID VARCHAR(100)='test_two',
--	@OperationFlag INT=1,
--	@MenuId INT=128,
--	@AuthMode	CHAR(1)='Y',
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

			--Set @Timekey=(select CAST(B.timekey as int)from SysDataMatrix A
			--Inner Join SysDayMatrix B ON A.TimeKey=B.TimeKey
			-- where A.CurrentStatus='C')

  --SET @Timekey =(Select TimeKey from SysDataMatrix where CurrentStatus='C') 

  --SET @Timekey =(Select LastMonthDateKey from SysDayMatrix where Timekey=@Timekey) 
  DECLARE @MocDate date
  
	SET @Timekey =(Select Timekey from SysDataMatrix Where MOC_Initialised='Y' AND ISNULL(MOC_Frozen,'N')='N') 
	SET @MocDate =(Select ExtDate from SysDataMatrix Where MOC_Initialised='Y' AND ISNULL(MOC_Frozen,'N')='N')

	PRINT @TIMEKEY

	SET @EffectiveFromTimeKey=@TimeKey
	SET @EffectiveToTimeKey=49999




	DECLARE @FilePathUpload	VARCHAR(100)
				   SET @FilePathUpload=@UserLoginId+'_'+@filepath
					PRINT '@FilePathUpload'
					PRINT @FilePathUpload


		BEGIN TRY

		--BEGIN TRAN
		
IF (@MenuId=128)
BEGIN


	IF (@OperationFlag=1)

	BEGIN

		IF NOT (EXISTS (SELECT * FROM CustlevelNPAMOCDetails_stg  where filname=@FilePathUpload))

							BEGIN
									 --Rollback tran
									SET @Result=-8

								RETURN @Result
							END
			
                   Print 'Sachin'

		IF EXISTS(SELECT 1 FROM CustlevelNPAMOCDetails_stg WHERE filname=@FilePathUpload)
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
		   ,'Customer MOC Upload'
		   ,@EffectiveFromTimeKey
		   ,@EffectiveToTimeKey
		   ,@UserLoginID
		   ,GETDATE()


			   PRINT @@ROWCOUNT

			      PRINT @@ROWCOUNT

		   DECLARE @ExcelUploadId INT
	SET 	@ExcelUploadId=(SELECT MAX(UniqueUploadID) FROM  ExcelUploadHistory)
		
			Insert into UploadStatus (FileNames,UploadedBy,UploadDateTime,UploadType)
		Values(@filepath,@UserLoginID ,GETDATE(),'Customer MOC Upload')

		Print 'Sachin111'

		      PRINT '@ExcelUploadId'
			  PRINT @ExcelUploadId


						  Update  A
						Set A.EffectiveToTimeKey=@Timekey-1
						from CustomerLevelMOC_MOD A
						inner join CustlevelNPAMOCDetails_stg B
						ON A.CustomerID=B.CustomerID
						AND A.EffectiveFromTimeKey <=@Timekey
						AND A.EffectiveToTimeKey >=@Timekey
						Where A.EffectiveToTimeKey >=@Timekey
						and A.AuthorisationStatus = 'A'
						
			  
					SET dateformat DMY
					INSERT INTO CustomerLevelMOC_MOD
		(
			 SrNo
			,UploadID
			--,SummaryID
			--,SlNo
			 ,CustomerID
			,AssetClass
			,AssetClassAlt_Key
			,NPADate
			,SecurityValue
			--,AdditionalProvision
			,MOCSource 
			,MOCSourceAltkey
			,MOCType
			,MOCTypeAlt_Key
			,MOCReason
			,AuthorisationStatus	
			,EffectiveFromTimeKey	
			,EffectiveToTimeKey	
			,CreatedBy	
			,DateCreated
			,ScreenFlag
			,ChangeField
			,MOCDate
			,MOCType_Flag
			,CustomerEntityID
		)
		 
		SELECT
			 SlNo
			,@ExcelUploadId
			--,SummaryID
			--,SlNo
			,A.CustomerID
			,A.AssetClass
			,B.AssetClassAlt_Key
			,Case When NPADate<>'' AND ISDATE(NPADate)=1 Then   Convert(date,NPADate) Else NULL END as NPADate
			--,ISNULL(case when isnull(SecurityValue,'0')<>'0' then CAST(ISNULL(CAST(SecurityValue AS INT),0) AS DECIMAL(30,2))   end,0) SecurityValue
			,Case When SecurityValue<>'' THEN CAST(ISNULL(CAST(SecurityValue AS DECIMAL(16,2)),0) AS DECIMAL(16,2)) ELSE NULL END SecurityValue
			--,Case When AdditionalProvision<>'' THEN CAST(ISNULL(CAST(AdditionalProvision AS DECIMAL(16,2)),0) AS DECIMAL(16,2)) ELSE NULL END AdditionalProvision
			--,ISNULL(case when isnull(AdditionalProvision,'0')<>'0' then CAST(ISNULL(CAST(AdditionalProvision AS INT),0) AS DECIMAL(30,2))   end,0) AdditionalProvision 
			,MOCSource
			,E.MOCTypeAlt_Key
			--,case when MOCType='Auto' then 1 else 2 END MOCType
			,MOCType
			,C.ParameterAlt_Key
			,f.ParameterName as MOCReason
			,'NP'	
			,@Timekey
			,@EffectiveToTimeKey	
			,@UserLoginID	
			,GETDATE()
			,'U'
			,NULL
			,Convert(Date,@MocDate)
			,'CUST'
			,H.CustomerEntityId
			--select * from pro.AccountCal_Hist

			--select * from MetaScreenFieldDetail   where menuid=128
			--select * from MetaScreenFieldDetail   where menuid=126
		FROM CustlevelNPAMOCDetails_stg A
		inner join customerbasicdetail H
		ON         A.CustomerID=H.CustomerId
		 and     H.EffectiveFromTimeKey<=@TimeKey AND H.EffectiveToTimeKey>=@TimeKey
		left join (select ParameterAlt_Key,ParameterName from DimParameter
				   where dimParameterName='DimMOCReason'
				   And	 EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey )f
		ON		  f.ParameterName=RTRIM(LTRIM(a.MOCReason))      
		Left Join DimAssetClass B ON A.AssetClass=B.AssetClassName 
		Left Join (Select	ParameterAlt_Key, ParameterName
					,'MOCType' as Tablename 
			from DimParameter where DimParameterName='MOCType'
							And	 EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey) C
				ON TRIM(A.MOCType)=TRIM(C.ParameterName)
		Left Join ( Select MOCTypeAlt_Key, MOCTypeName,
			       'MOCSource' as TableName
			 from dimmoctype
			 where EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey) E
			 
			 ON A.MOCSource=E.MOCTypeName
		where filname=@FilePathUpload


		--Update A
		--Set A.CustomerEntityID=B.CustomerEntityID
		--from CustomerLevelMOC_MOD A
		--	INNER JOIN CustomerBasicDetail B ON A.CustomerID =B.CustomerId
		--	Where UploadID=@ExcelUploadId


	
	
	IF OBJECT_ID('TempDB..#CustMocUpload') Is Not Null
	Drop Table #CustMocUpload

	Create TAble #CustMocUpload
	(
	CustomerID Varchar(30), FieldName Varchar(50),SrNo varchar(max))

	Insert Into #CustMocUpload(CustomerID,FieldName)
	Select CustomerID, 'AssetClass' FieldName from CustlevelNPAMOCDetails_stg Where isnull(AssetClass,'')<>'' 
	UNION ALL
	Select CustomerID, 'NPADate' FieldName from CustlevelNPAMOCDetails_stg Where isnull(NPADate,'')<>'' 
	UNION ALL
	Select CustomerID, 'SecurityValue' FieldName from CustlevelNPAMOCDetails_stg Where isnull(SecurityValue,'')<>''  --SecurityValue Is not NULL
	--UNION ALL
	--Select CustomerID, 'AdditionalProvision' FieldName from CustlevelNPAMOCDetails_stg Where isnull(AdditionalProvision,'')<>'' --AdditionalProvision Is not NULL

	--select * 
	Update B set B.SrNo=A.ScreenFieldNo
	from MetaScreenFieldDetail A
	Inner Join #CustMocUpload B ON A.CtrlName=B.FieldName
	Where A.MenuId=128 And A.IsVisible='Y'

----	-------------------
----	select * from #CustMocUpload
----	select CtrlName,* from MetaScreenFieldDetail A Where A.MenuId=128 And A.IsVisible='Y'
----	update MetaScreenFieldDetail 
----	set CtrlName='AdditionalProvision'
----	 Where MenuId=128 And IsVisible='Y' and entityKey=1406
----	 Asset Class
----NPA Date
----Security Value
----Additional Provision %

------select * into MetaScreenFieldDetail_21062021  from MetaScreenFieldDetail
----select * from MetaScreenFieldDetail_21062021 where menuid=128
----select * from MetaScreenFieldDetail where menuid=128
	---------------------


	
				 IF OBJECT_ID('TEMPDB..#NEWTRANCHE')  IS NOT NULL
					DROP TABLE #NEWTRANCHE

					SELECT * INTO #NEWTRANCHE FROM(
					SELECT 
						 SS.CustomerID,
						STUFF((SELECT ',' + US.SrNo 
							FROM #CustMocUpload US
							WHERE US.CustomerID = SS.CustomerID
							FOR XML PATH('')), 1, 1, '') [REPORTIDSLIST]
						FROM CustlevelNPAMOCDetails_stg SS 
						GROUP BY SS.CustomerID
						)B
						ORDER BY 1

						--Select * from #NEWTRANCHE

					--SELECT * 
					UPDATE A SET A.ChangeField=B.REPORTIDSLIST
					FROM DBO.CustomerLevelMOC_MOD A
					INNER JOIN #NEWTRANCHE B ON A.CustomerID=B.CustomerID
					WHERE  A.EFFECTIVEFROMTIMEKEY<=@TimeKey AND A.EFFECTIVETOTIMEKEY>=@TimeKey
					And A.UploadID=@ExcelUploadId
		PRINT @@ROWCOUNT
		
		---DELETE FROM STAGING DATA
		 DELETE FROM CustlevelNPAMOCDetails_stg
		 WHERE filname=@FilePathUpload

		 ----RETURN @ExcelUploadId

END
		   ----DECLARE @UniqueUploadID INT
	--SET 	@UniqueUploadID=(SELECT MAX(UniqueUploadID) FROM  ExcelUploadHistory)
	END


----------------------01042021-------------

IF (@OperationFlag=16)----AUTHORIZE

	BEGIN
		 
		      
		
				IF (@UserLoginID =(Select CreatedBy from CustomerLevelMOC_MOD 
				where AuthorisationStatus IN ('NP','MP') and UploadId=@UniqueUploadID
				and EffectiveToTimeKey >= 49999
				                      --AND CreatedBy in (select createdby from DimUserInfo where  IsChecker='N')  
									    Group By CreatedBy))
				BEGIN
								SET @Result=-1
								rollback tran
								RETURN @Result
								
				END

		UPDATE 
			CustomerLevelMOC_MOD 
			SET 
			AuthorisationStatus	='1A'
			,ApprovedByFirstLevel	=@UserLoginID
			,DateApprovedFirstLevel	=GETDATE()
			WHERE UploadId=@UniqueUploadID
			
		   UPDATE 
		   ExcelUploadHistory
		   SET AuthorisationStatus='1A'
		   ,ApprovedBy	=@UserLoginID
		   where UniqueUploadID=@UniqueUploadID
		   AND UploadType='Customer MOC Upload'
	END

--------------------------------------------

	IF (@OperationFlag=20)----AUTHORIZE

	BEGIN
	           --------------07-07-2021---------------IMPLEMENTED BY PRASHANT WITH DISCUSSION WITH AKSHAY FOR MAKER CHECKER BY PASS POINT ---------------
			-- IF @UserLoginID= (select UserLoginID from DimUserInfo where  IsChecker2='N' and UserLoginID=@UserLoginID )
			--   BEGIN
			--					SET @Result=-1
			--					ROLLBACK TRAN
			--					RETURN @Result
								
			--	END
          
			--ELSE BEGIN
			--	IF (@UserLoginID =(Select CreatedBy from CustomerLevelMOC_MOD where AuthorisationStatus IN ('1A') and UploadId=@UniqueUploadID 
			--	and EffectiveToTimeKey >= 49999 and CreatedBy = @UserLoginID
			--	                     --AND CreatedBy in (select createdby from DimUserInfo where  IsChecker2='N')
			--					   Group By CreatedBy))

			--	BEGIN
			--					SET @Result=-1
			--					ROLLBACK TRAN
			--					RETURN @Result
			--					--select * from AccountFlaggingDetails_Mod
			--	END
			--	ELSE
			--	BEGIN
			--		IF (@UserLoginID =(Select ApprovedBy from CustomerLevelMOC_MOD where AuthorisationStatus IN ('1A') and UploadId=@UniqueUploadID 
			--		and EffectiveToTimeKey >= 49999 and ApprovedBy = @UserLoginID
			--	                     --AND CreatedBy in (select createdby from DimUserInfo where  IsChecker2='N')
			--					   Group By ApprovedBy))

			--	BEGIN
			--					SET @Result=-1
			--					ROLLBACK TRAN
			--					RETURN @Result
			--					--select * from AccountFlaggingDetails_Mod
			--	END
			--	ELSE
			--	BEGIN

				  
				
		
		UPDATE 
			CustomerLevelMOC_MOD 
			SET 
			AuthorisationStatus	='A'
			,ApprovedBy	=@UserLoginID
			,DateApproved	=GETDATE()
			
			WHERE UploadId=@UniqueUploadID
										
						UPDATE  A
						SET A.EffectiveToTimeKey=@Timekey-1
						from MOC_ChangeDetails A
						INNER JOIN CustomerBasicDetail B
							ON A.CustomerEntityID=B.CustomerEntityId
								AND A.EffectiveFromTimeKey <=@Timekey AND A.EffectiveToTimeKey >=@Timekey
								AND B.EffectiveFromTimeKey <=@Timekey AND B.EffectiveToTimeKey >=@Timekey
						INNER JOIN CustomerLevelMOC_MOD C
							ON B.CustomerID=C.CustomerID
								AND C.EffectiveFromTimeKey <=@Timekey AND C.EffectiveToTimeKey >=@Timekey
								AND C.AuthorisationStatus='A' AND UploadId=@UniqueUploadID
						WHERE A.EffectiveToTimeKey >=@Timekey
						AND A.AuthorisationStatus = 'A'
						AND A.MOCType_Flag='CUST'
						AND UploadId=@UniqueUploadID


								UPDATE  A
						SET A.CustomerEntityID=B.CustomerEntityId
						from CustomerLevelMOC_MOD A
						INNER JOIN CustomerBasicDetail B
							ON A.CustomerID=B.CustomerID
								AND A.EffectiveFromTimeKey <=@Timekey AND A.EffectiveToTimeKey >=@Timekey
								AND B.EffectiveFromTimeKey <=@Timekey AND B.EffectiveToTimeKey >=@Timekey
                              WHERE  A.MOCType_Flag='CUST'
						AND UploadId=@UniqueUploadID
						

			INSERT INTO MOC_ChangeDetails
								(
                                         MOCType_Flag
                                        ,CustomerEntityID
                                        ,AssetClassAlt_Key
                                        ,NPA_Date
                                        ,CurntQtrRv
										--,AdditionalProvision
										,AddlProvPer
                                        --,MOC_ExpireDate
                                        ,MOC_Reason
                                        ,MOC_Date
                                        ,MOC_Source
                                        ,AuthorisationStatus
                                        ,EffectiveFromTimeKey
                                        ,EffectiveToTimeKey
                                        ,CreatedBy
                                        ,DateCreated
                                        ,ModifiedBy
                                        ,DateModified
                                        ,ApprovedByFirstLevel
                                        ,DateApprovedFirstLevel
                                        ,ApprovedBy
                                        ,DateApproved
										,MOCTYPE
										--,ScreenFlag

										
								)
					SELECT
					                      
                                         MOCType_Flag
										,A.CustomerEntityID
										,AssetClassAlt_Key
										,NPADate
										,SecurityValue
										,AdditionalProvision
										--,MOC_ExpireDate
										,MOCReason
										--,A.MOCDate
										,@MocDate
										,MOCSource
										,'A'
										,@TimeKey
										,49999
										,A.CreatedBy
										,A.DateCreated
										,A.ModifiedBy
										,A.DateModified
										,ApprovedByFirstLevel
										,DateApprovedFirstLevel
										,A.ApprovedBy
										,GETDATE()
										,MOCTYPE
										--,'U'
								FROM CustomerLevelMOC_Mod A
								
								WHERE  UploadId=@UniqueUploadID 
								AND A.EffectiveToTimeKey>=@Timekey
								AND A.AuthorisationStatus = 'A'



								

/*--------------------Adding Flag To AdvAcOtherDetail------------Sudesh 03-06-2021--------*/ 

--IF OBJECT_ID('TempDB..#IBPCNew') Is Not NUll
--Drop Table #IBPCNew

--Select A.RefCustomerId,A.SplFlag 
--into #IBPCNew                             --DBO.AdvAcOtherDetail
--FROM dbo.advcustotherdetail A               
--     INNER JOIN CustomerLevelMOC_MOD B 
--	 ON A.RefCustomerId=B.CustomerID
--			WHERE  B.UploadId=@UniqueUploadID 
--			and B.EffectiveToTimeKey>=@Timekey
--			AND A.EffectiveToTimeKey=49999 
--			And A.SplFlag Like '%IBPC%'


 -- UPDATE A
	--SET  
 --       A.SplFlag=	CASE WHEN ISNULL(A.SplFlag,'')='' THEN 'IBPC'     
	--				ELSE A.SplFlag+','+'IBPC' END
 -- FROM	dbo.advcustotherdetail A
 --  --INNER JOIN #Temp V  ON A.AccountEntityId=V.AccountEntityId
 -- INNER JOIN IBPCPoolDetail_MOD B ON A.RefCustomerId=B.CustomerID
	--		WHERE  B.UploadId=@UniqueUploadID and B.EffectiveToTimeKey>=@Timekey
	--		AND A.EffectiveToTimeKey=49999
	--		AND Not Exists (Select 1 from #IBPCNew N Where N.RefCustomerId=A.RefCustomerId)




-------------------------------------------

			--UPDATE A
			--SET 
			--A.POSinRs=ROUND(B.POSinRs,2)
			--,a.ModifyBy=@UserLoginID
			--,a.DateModified=GETDATE()
			--FROM CustomerLevelMOC A
			--INNER JOIN CustomerLevelMOC_MOD  B 
			--ON (A.EffectiveFromTimeKey<=@Timekey AND A.EffectiveToTimeKey>=@Timekey)
			--AND  (B.EffectiveFromTimeKey<=@Timekey AND B.EffectiveToTimeKey>=@Timekey)	
			--AND A.CustomerId=B.CustomerId

			--	WHERE B.AuthorisationStatus='A'
			--	AND B.UploadId=@UniqueUploadID

				UPDATE
				ExcelUploadHistory
				SET AuthorisationStatus='A',ApprovedBy=@UserLoginID,DateApproved=GETDATE()
				WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
				AND UniqueUploadID=@UniqueUploadID
				AND UploadType='Customer MOC Upload'
END
--				END
--END

--	END


	IF (@OperationFlag=17)----REJECT

	BEGIN
		
	          IF (@UserLoginID =(Select CreatedBy from CustomerLevelMOC_MOD where  UploadId=@UniqueUploadID Group By CreatedBy))
	          BEGIN
								SET @Result=-1

								RETURN @Result
	         END
			 ELSE BEGIN
		UPDATE 
			CustomerLevelMOC_MOD 
			SET 
			AuthorisationStatus	='R'
			,EffectiveToTimeKey=@Timekey-1
			,ApprovedByFirstLevel	=@UserLoginID
			,DateApprovedFirstLevel	=GETDATE()
			
			WHERE UploadId=@UniqueUploadID
			AND AuthorisationStatus='NP'

		
			UPDATE
				ExcelUploadHistory
				SET AuthorisationStatus='R',
				EffectiveToTimeKey=@Timekey-1,ApprovedBy=@UserLoginID,DateApproved=GETDATE()
				WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
				AND UniqueUploadID=@UniqueUploadID
				AND UploadType='Customer MOC Upload'
				END


	END

IF (@OperationFlag=21)----REJECT

	BEGIN

	    IF @UserLoginID= (select UserLoginID from DimUserInfo where  IsChecker2='N' and UserLoginID=@UserLoginID )
			   BEGIN
								SET @Result=-1
								ROLLBACK TRAN
								RETURN @Result
								
				END
          
			ELSE BEGIN
				IF (@UserLoginID =(Select CreatedBy from CustomerLevelMOC_MOD where AuthorisationStatus IN ('1A') and UploadId=@UniqueUploadID 
				and EffectiveToTimeKey = 49999 and CreatedBy = @UserLoginID
				                     --AND CreatedBy in (select createdby from DimUserInfo where  IsChecker2='N')
								   Group By CreatedBy))

				BEGIN
								SET @Result=-1
								ROLLBACK TRAN
								RETURN @Result
								--select * from AccountFlaggingDetails_Mod
				END
				ELSE
				BEGIN
					IF (@UserLoginID =(Select ApprovedBy from CustomerLevelMOC_MOD where AuthorisationStatus IN ('1A') and UploadId=@UniqueUploadID 
					and EffectiveToTimeKey = 49999 and ApprovedBy = @UserLoginID
				                     --AND CreatedBy in (select createdby from DimUserInfo where  IsChecker2='N')
								   Group By ApprovedBy))

				BEGIN
								SET @Result=-1
								ROLLBACK TRAN
								RETURN @Result
								--select * from AccountFlaggingDetails_Mod
				END
				ELSE
				BEGIN

		UPDATE 
			CustomerLevelMOC_MOD 
			SET 
			AuthorisationStatus	='R'
			,EffectiveToTimeKey=@Timekey-1
			,ApprovedBy	=@UserLoginID
			,DateApproved	=GETDATE()
			WHERE UploadId=@UniqueUploadID
			AND AuthorisationStatus in('NP','1A')

			

			UPDATE
				ExcelUploadHistory
				SET AuthorisationStatus='R',
				EffectiveToTimeKey=@Timekey-1,ApprovedBy=@UserLoginID,DateApproved=GETDATE()
				WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
				AND UniqueUploadID=@UniqueUploadID
				AND UploadType='Customer MOC Upload'
END

				END
	END


END
END

	--COMMIT TRAN
		---SET @Result=CASE WHEN  @OperationFlag=1 THEN @UniqueUploadID ELSE 1 END
		SET @Result=CASE WHEN  @OperationFlag=1 AND @MenuId=128 THEN @ExcelUploadId 
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