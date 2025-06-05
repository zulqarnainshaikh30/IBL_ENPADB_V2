SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE  [dbo].[IBPCPoolStageDataInUp]
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

			Set @Timekey=(select CAST(B.timekey as int)from SysDataMatrix A
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
		
IF (@MenuId=1458)
BEGIN


	IF (@OperationFlag=1)

	BEGIN

		IF NOT (EXISTS (SELECT 1 FROM IBPCPoolDetail_stg  where filname=@FilePathUpload))

							BEGIN
									 --Rollback tran
									SET @Result=-8

								RETURN @Result
							END
			
                   Print 'Sachin'

		IF EXISTS(SELECT 1 FROM IBPCPoolDetail_stg WHERE FILNAME=@FilePathUpload)
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
		   ,'IBPC Pool Upload'
		   ,@EffectiveFromTimeKey
		   ,@EffectiveToTimeKey
		   ,@UserLoginID
		   ,GETDATE()


			   PRINT @@ROWCOUNT

		   DECLARE @ExcelUploadId INT
	       SET 	@ExcelUploadId=(SELECT MAX(UniqueUploadID) FROM  ExcelUploadHistory)
		
			Insert into UploadStatus (FileNames,UploadedBy,UploadDateTime,UploadType)
	       	Values(@filepath,@UserLoginID ,GETDATE(),'IBPC Pool Upload')

		INSERT INTO IBPCPoolDetail_MOD
		(
			SrNo
			,UploadID
			,SummaryID
			,PoolID
			,PoolName
			,CustomerID
			,AccountID
			,POS
			,InterestReceivable
			,AuthorisationStatus	
			,EffectiveFromTimeKey	
			,EffectiveToTimeKey	
			,CreatedBy	
			,DateCreated
			,IBPCExposureAmt
			,OSBalance
			,IBPCExposureinRs
			,DateofIBPCreckoning
			,DateofIBPCmarking
			,MaturityDate
			,Action	
			,PoolType
		)
		/* 
		SELECT
			SrNo
			,@ExcelUploadId
			,SummaryID
			,PoolID
			,PoolName
			,CustomerID
			,AccountID
			,PrincipalOutstandinginRs
			,InterestReceivableinRs
			,'NP'	
			,@Timekey
			,49999	
			,@UserLoginID	
			,GETDATE()
			,IBPCExposureinRs
			,OSBalanceinRs
			 ,IBPCExposureinRs
			,DateofIBPCreckoning
			,DateofIBPCmarking
			,MaturityDate
		FROM IBPCPoolDetail_stg
		where FilName=@FilePathUpload

		*/

		SELECT
			SrNo
			,@ExcelUploadId
			,SummaryID
			,PoolID
			,PoolName
			,B.CustomerID
			,AccountID
			,ISNULL(AB.PrincipalBalance,0) PrincipalOutstandinginRs
			,ISNULL(AB.InterestReceivable,0) InterestReceivableinRs
			,'NP'	
			,@Timekey
			,49999	
			,@UserLoginID	
			,GETDATE()
			,IBPCExposureinRs
			,ISNULL(AB.Balance,0) OSBalanceinRs
			 ,IBPCExposureinRs
			,NULL DateofIBPCreckoning
			,DateofIBPCmarking
			,MaturityDate
			,Action
			,PoolType
		FROM IBPCPoolDetail_stg AP
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
		AND         FilName=@FilePathUpload  

		Declare @SummaryId int
		Set @SummaryId=IsNull((Select Max(SummaryId) from IBPCPoolSummary_Mod),0)

		INSERT INTO IBPCPoolSummary_mod    -----Previously IBPCPoolSummary_Stg 30/12/2023 by kapil
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

			,AuthorisationStatus	  ----Newly added by kapil 30/12/2023
			,EffectiveFromTimeKey	  ----Newly added by kapil 30/12/2023
			,EffectiveToTimeKey	      ----Newly added by kapil 30/12/2023
			,CreatedBy	              ----Newly added by kapil 30/12/2023
			,DateCreated              ----Newly added by kapil 30/12/2023
			

		)

		/*
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

		*/

		SELECT
			@ExcelUploadId
			,@SummaryId+Row_Number() over(Order by PoolID)
			,PoolID
			,PoolName
			,PoolType
			--,SUM(ISNULL(AB.PrincipalBalance,0)+ISNULL(AB.InterestReceivable,0))
			,SUM(ISNULL(AB.Balance,0))
			,Count(AccountID)
			,SUM(ISNULL(Cast(IBPCExposureinRs as Decimal(16,2)),0))
			,NULL 
			,Convert (date,DateofIBPCmarking,103) ---Previously it was DateofIBPCmarking  changed on 29/12/2023
			,Convert(date,MaturityDate ,103)     ---- Previously it was MaturityDate changed on 29/12/2023
			,Sum(IsNull(AB.PrincipalBalance ,0))
			,Sum(IsNull(AB.InterestReceivable ,0))

			,'NP'                    ----Newly added by kapil 30/12/2023
			,@Timekey				 ----Newly added by kapil 30/12/2023
			,49999					 ----Newly added by kapil 30/12/2023
			,@UserLoginID            ----Newly added by kapil 30/12/2023
			,GETDATE()				 ----Newly added by kapil 30/12/2023

		FROM IBPCPoolDetail_stg AP
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
		AND FilName=@FilePathUpload
		Group by PoolID,PoolName,PoolType,DateofIBPCmarking,MaturityDate


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
	IF OBJECT_ID('TempDB..#IBPC_Upload') Is Not Null
	Drop Table #IBPC_Upload

	Create TAble #IBPC_Upload
	(
	AccountID Varchar(30), FieldName Varchar(50),SrNo Varchar(Max))

	Insert Into #IBPC_Upload(AccountID,FieldName)
	 Select AccountID, 'PoolID' FieldName from IBPCPoolDetail_stg Where isnull(PoolID,'')<>'' 
	UNION ALL
	Select AccountID, 'PoolName' FieldName from IBPCPoolDetail_stg Where isnull(PoolName,'')<>'' 
	UNION ALL
	Select AccountID, 'PoolType' FieldName from IBPCPoolDetail_stg Where isnull(PoolType,'')<>''
	UNION ALL
	--Select AccountID, 'PrincipalOutstandinginRs' FieldName from IBPCPoolDetail_stg Where isnull(PrincipalOutstandinginRs,'')<>'' 
	--UNION ALL
	--Select AccountID, 'InterestReceivableinRs' FieldName from IBPCPoolDetail_stg Where isnull(InterestReceivableinRs,'')<>'' 
	--UNION ALL
	--Select AccountID, 'OSBalanceinRs' FieldName from IBPCPoolDetail_stg Where isnull(OSBalanceinRs,'')<>'' 
	--UNION ALL
	Select AccountID, 'IBPCExposureinRs' FieldName from IBPCPoolDetail_stg Where isnull(IBPCExposureinRs,'')<>'' 
	UNION ALL
	--Select AccountID, 'DateofIBPCreckoning' FieldName from IBPCPoolDetail_stg Where isnull(DateofIBPCreckoning,'')<>'' 
	--UNION ALL
	Select AccountID, 'DateofIBPCmarking' FieldName from IBPCPoolDetail_stg Where isnull(DateofIBPCmarking,'')<>'' 
	UNION ALL
	Select AccountID, 'MaturityDate' FieldName from IBPCPoolDetail_stg Where isnull(MaturityDate,'')<>'' 
	UNION ALL
	Select AccountID, 'Action' FieldName from IBPCPoolDetail_stg Where isnull(Action,'')<>'' 
	--UNION ALL
	--Select AccountNumber, 'TotalAmtSacrifice' FieldName from OTSUpload_stg Where isnull(TotalAmtSacrifice,'')<>''
	--UNION ALL
	--Select AccountNumber, 'SettlementFailure' FieldName from IBPCPoolDetail_stg Where isnull(SettlementFailure,'')<>'' 
	--UNION ALL
	--Select AccountNumber, 'Action' FieldName from IBPCPoolDetail_stg Where isnull(Action,'')<>'' 
	----UNION ALL
	----Select Account_ID, 'Actual_Write_Off_Date' FieldName from OTSUpload_stg Where isnull(Actual_Write_Off_Date,'')<>'' 
	--UNION ALL
	--Select AccountNumber, 'Accountclosuredateinsystem' FieldName from OTSUpload_stg Where isnull(Accountclosuredateinsystem,'')<>'' 
		
		
		--print 'nanda3'

	--select *
	Update B set B.SrNo=A.ScreenFieldNo
	from MetaScreenFieldDetail A
	Inner Join #IBPC_Upload B ON A.CtrlName=B.FieldName
	Where A.MenuId=@MenuId And A.IsVisible='Y'


		print 'nanda4'
	
				 IF OBJECT_ID('TEMPDB..#NEWTRANCHE')  IS NOT NULL
					DROP TABLE #NEWTRANCHE

					SELECT * INTO #NEWTRANCHE FROM(
					SELECT 
						 SS.AccountID,
						STUFF((SELECT ',' + US.SrNo 
							FROM #IBPC_Upload US
							WHERE US.AccountID = SS.AccountID
							FOR XML PATH('')), 1, 1, '') [REPORTIDSLIST]
						FROM IBPCPoolDetail_stg SS 
						GROUP BY SS.AccountID
						)B
						ORDER BY 1

						--Select * from #NEWTRANCHE

					--SELECT * 
					UPDATE A SET A.ChangeFields=B.REPORTIDSLIST
					FROM DBO.IBPCPoolDetail_MOD A
					INNER JOIN #NEWTRANCHE B ON A.AccountID=B.AccountID
					WHERE  A.EFFECTIVEFROMTIMEKEY<=@TimeKey AND A.EFFECTIVETOTIMEKEY>=@TimeKey
					And A.UploadID=@ExcelUploadId





		PRINT @@ROWCOUNT
		
		---DELETE FROM STAGING DATA
		-- DELETE FROM IBPCPoolDetail_stg
	   -- WHERE filname=@FilePathUpload

		 ----RETURN @ExcelUploadId

END
		   ----DECLARE @UniqueUploadID INT
	--SET 	@UniqueUploadID=(SELECT MAX(UniqueUploadID) FROM  ExcelUploadHistory)
	END


----------------------01042021-------------

IF (@OperationFlag=16)----AUTHORIZE

	BEGIN
		
		UPDATE 
			IBPCPoolDetail_MOD 
			SET 
			AuthorisationStatus	='1A'
			,ApprovedByFirstLevel=@UserLoginID
			,DateApprovedFirstLevel=getdate()			
			WHERE UploadId=@UniqueUploadID
			
			UPDATE 
			IBPCPoolSummary_MOD 
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
		   AND UploadType='IBPC Pool Upload'
	END

--------------------------------------------

	IF (@OperationFlag=20)----AUTHORIZE

	BEGIN
		
		UPDATE 
			IBPCPoolDetail_MOD 
			SET 
			AuthorisationStatus	='A'
			,ApprovedBy	=@UserLoginID
			,DateApproved	=GETDATE()
			
			WHERE UploadId=@UniqueUploadID

			UPDATE 
			IBPCPoolSummary_MOD 
			SET 
			AuthorisationStatus	='A'
			,ApprovedBy	=@UserLoginID
			,DateApproved	=GETDATE()
			
			WHERE UploadId=@UniqueUploadID

			-----maintain history
			Update  A
			Set A.EffectiveToTimeKey=A.EffectiveFromTimeKey-1
			from IBPCPoolDetail A
			inner join IBPCPoolDetail_MOD B
			ON A.AccountID=B.AccountID
			AND B.EffectiveFromTimeKey <=@Timekey
			AND B.EffectiveToTimeKey >=@Timekey
			Where B.UploadId=@UniqueUploadID
			AND A.EffectiveToTimeKey >=49999

			INSERT INTO IBPCPoolDetail(SummaryID
						,PoolID
						,PoolName
						,CustomerID
						,AccountID
						,POS
						,InterestReceivable
						,AuthorisationStatus
						,EffectiveFromTimeKey
						,EffectiveToTimeKey
						,CreatedBy
						,DateCreated
						,ModifyBy
						,DateModified
						,ApprovedBy
						,DateApproved
						,IBPCExposureAmt
						,OSBalance
						,Action
						--,IBPCExposureinRs
						--,DateofIBPCreckoning
						,DateofIBPCmarking
						,MaturityDate
						,PoolType
						)
			SELECT SummaryID
					,PoolID
					,PoolName
					,CustomerID
					,AccountID
					,POS
					,InterestReceivable
					,AuthorisationStatus
					,@Timekey,49999
					,CreatedBy
					,DateCreated
					,ModifyBy
					,DateModified
					,@UserLoginID
					,Getdate()
					,IBPCExposureAmt
					,OSBalance
					,Action
					--,IBPCExposureinRs
					--,DateofIBPCreckoning
					,DateofIBPCmarking
					,MaturityDate
					,PoolType
			FROM IBPCPoolDetail_MOD A
			WHERE  A.UploadId=@UniqueUploadID 
			and EffectiveToTimeKey>=@Timekey
			And A.Action in('A')

			INSERT INTO IBPCPoolSummary(
					SummaryID
					,PoolID
					,PoolName
					,PoolType
					,BalanceOutstanding
					,IBPCExposureAmt
					,IBPCReckoningDate
					,IBPCMarkingDate
					,MaturityDate
					,NoOfAccount
					,AuthorisationStatus
						,EffectiveFromTimeKey
						,EffectiveToTimeKey
						,CreatedBy
						,DateCreated
						,ModifyBy
						,DateModified
						,ApprovedBy
						,DateApproved
						,TotalPosBalance
						,TotalInttReceivable
						)
			SELECT SummaryID
					,PoolID
					,PoolName
					,PoolType
					,BalanceOutstanding
					,IBPCExposureAmt
					,IBPCReckoningDate
					,IBPCMarkingDate
					,MaturityDate
					,NoOfAccount
					,AuthorisationStatus
					,@Timekey,49999
					,CreatedBy
					,DateCreated
					,ModifyBy
					,DateModified
					,@UserLoginID
					,Getdate()
					,TotalPosBalance
					,TotalInttReceivable
			FROM IBPCPoolSummary_Mod A
			WHERE  A.UploadId=@UniqueUploadID and EffectiveToTimeKey>=@Timekey


			-----------------Insert into Final Tables ----------
			/*
			Update  A
			Set A.EffectiveToTimeKey=A.EffectiveFromTimeKey-1
			from IBPCFinalPoolDetail A
			inner join IBPCPoolDetail_MOD B
			ON A.AccountID=B.AccountID
			AND B.EffectiveFromTimeKey <=@Timekey
			AND B.EffectiveToTimeKey >=@Timekey
			Where B.UploadId=@UniqueUploadID
			AND A.EffectiveToTimeKey >=49999
			*/

			Update  A
			Set A.EffectiveToTimeKey=A.EffectiveFromTimeKey-1
			,A.IBPCOutDate=Case When B.Action='R' then GETDATE() else null End
			,A.FlagAlt_Key=Case When B.Action='R' then 'N' Else A.FlagAlt_Key End
			from IBPCFinalPoolDetail A
			inner join IBPCPoolDetail_MOD B
			ON A.AccountID=B.AccountID
			AND B.EffectiveFromTimeKey <=@Timekey
			AND B.EffectiveToTimeKey >=@Timekey
			Where B.UploadId=@UniqueUploadID
			AND A.EffectiveToTimeKey >=49999
			And B.Action in('A','R')

			Insert into IBPCFinalPoolDetail
			(
			SummaryID
			,PoolID
			,PoolName
			,CustomerID
			,AccountID
			,POS
			,InterestReceivable
			,AuthorisationStatus
			,EffectiveFromTimeKey
			,EffectiveToTimeKey
			,CreatedBy
			,DateCreated
			,ModifyBy
			,DateModified
			,ApprovedBy
			,DateApproved
			,ExposureAmount
			,IBPCInDate 
			,AccountBalance --- new add
			,SourceAlt_Key
			,FlagAlt_Key
			,PoolType
			,MaturityDate
			,IBPCMarkingDate
			,CustomerName
			)
			SELECT SummaryID
					,PoolID
					,PoolName
					,C.CustomerID
					,AccountID
					,POS
					,InterestReceivable
					,A.AuthorisationStatus
					,@Timekey,49999
					,A.CreatedBy
					,A.DateCreated
					,ModifyBy
					,A.DateModified
					,@UserLoginID
					,Getdate()
					,IBPCExposureAmt
					,GETDATE() -- new add 
					,OSBalance
					,B.SourceAlt_Key
					,Case when A.action='A' Then 'Y' Else 'N' End
					,A.PoolType
					,A.MaturityDate
					,DateofIBPCmarking
					,C.CustomerName
			FROM IBPCPoolDetail_MOD A
			Inner Join CurDat.AdvAcBasicDetail B ON A.AccountID=B.CustomerACID
			ANd B.EffectiveFromTimeKey<=@Timekey ANd B.EffectiveToTimeKey>=@Timekey
			Inner Join CurDat.CustomerBasicDetail C ON B.customerEntityId=C.CustomerEntityId
			ANd C.EffectiveFromTimeKey<=@Timekey ANd C.EffectiveToTimeKey>=@Timekey
			WHERE  A.UploadId=@UniqueUploadID and A.EffectiveToTimeKey>=@Timekey
			ANd A.Action in('A')

			---Summary Final -----------

			Insert into IBPCFinalPoolSummary
			(
			SummaryID
			,PoolID
			,PoolName
			,PoolType
			,BalanceOutstanding
			,IBPCExposureAmt
			,IBPCReckoningDate
			,IBPCMarkingDate
			,MaturityDate
			,NoOfAccount
			,AuthorisationStatus
			,EffectiveFromTimeKey
			,EffectiveToTimeKey
			,CreatedBy
			,DateCreated
			,ModifyBy
			,DateModified
			,ApprovedBy
			,DateApproved
			,TotalPosBalance
			,TotalInttReceivable
			)
			SELECT SummaryID
					,PoolID
					,PoolName
					,PoolType
					,BalanceOutstanding
					,IBPCExposureAmt
					,IBPCReckoningDate
					,IBPCMarkingDate
					,MaturityDate
					,NoOfAccount
					,AuthorisationStatus
					,@Timekey,49999
					,CreatedBy
					,DateCreated
					,ModifyBy
					,DateModified
					,@UserLoginID
					,Getdate()
					,TotalPosBalance
					,TotalInttReceivable
			FROM IBPCPoolSummary_Mod A
			WHERE  A.UploadId=@UniqueUploadID and EffectiveToTimeKey>=@Timekey



/*--------------------Adding Flag To AdvAcOtherDetail------------Sunil 21-03-2021--------*/ 

IF OBJECT_ID('TempDB..#IBPCNew') Is Not NUll
Drop Table #IBPCNew

Select A.RefSystemAcId,A.SplFlag into #IBPCNew FROM DBO.AdvAcOtherDetail A
     INNER JOIN IBPCPoolDetail_MOD B ON A.RefSystemAcId=B.AccountID
			WHERE  B.UploadId=@UniqueUploadID and B.EffectiveToTimeKey>=@Timekey
			AND A.EffectiveToTimeKey=49999 And A.SplFlag Like '%IBPC%'


  UPDATE A
	SET  
        A.SplFlag=CASE WHEN ISNULL(A.SplFlag,'')='' THEN 'IBPC'     
						ELSE A.SplFlag+','+'IBPC'     END
		   
  FROM DBO.AdvAcOtherDetail A
   --INNER JOIN #Temp V  ON A.AccountEntityId=V.AccountEntityId
  INNER JOIN IBPCPoolDetail_MOD B ON A.RefSystemAcId=B.AccountID
			WHERE  B.UploadId=@UniqueUploadID and B.EffectiveToTimeKey>=@Timekey
			AND A.EffectiveToTimeKey=49999
			AND Not Exists (Select 1 from #IBPCNew N Where N.RefSystemAcId=A.RefSystemAcId)




			--------------------------
			--1
			--select *from ExceptionFinalStatusType
			--select * from AdvAcOtherDetail
			--select * from IBPCFinalPoolDetail 

			--alter table IBPCFinalPoolDetail
			--add IBPCOutDate date,IBPCInDate Date
			 --update 


-------------------------------------------

			UPDATE A
			SET 
			A.POS=ROUND(B.POS,2)
			--,a.ModifyBy=@UserLoginID
			--,a.DateModified=GETDATE()
			FROM IBPCPoolDetail A
			INNER JOIN IBPCPoolDetail_MOD  B ON (A.EffectiveFromTimeKey<=@Timekey AND A.EffectiveToTimeKey>=@Timekey)
																AND  (B.EffectiveFromTimeKey<=@Timekey AND B.EffectiveToTimeKey>=@Timekey)	
																AND A.AccountID=B.AccountID

				WHERE B.AuthorisationStatus='A'
				AND B.UploadId=@UniqueUploadID

				UPDATE
				ExcelUploadHistory
				SET AuthorisationStatus='A',ApprovedBy=@UserLoginID,DateApproved=GETDATE()
				WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
				AND UniqueUploadID=@UniqueUploadID
				AND UploadType='IBPC Pool Upload'

				


	END


	IF (@OperationFlag=17)----REJECT

	BEGIN
		
		UPDATE 
			IBPCPoolDetail_MOD 
			SET 
			AuthorisationStatus	='R'
			,EffectiveToTimeKey=@Timekey-1
			,ApprovedByFirstLevel	=@UserLoginID
			,DateApprovedFirstLevel	=GETDATE()
			
			WHERE UploadId=@UniqueUploadID
			AND AuthorisationStatus='NP'

			UPDATE 
			IBPCPoolSummary_MOD 
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
				AND UploadType='IBPC Pool Upload'



	END

IF (@OperationFlag=21)----REJECT

	BEGIN
		
		UPDATE 
			IBPCPoolDetail_MOD 
			SET 
			AuthorisationStatus	='R'
			,EffectiveToTimeKey=@Timekey-1
			,ApprovedBy	=@UserLoginID
			,DateApproved	=GETDATE()
			
			WHERE UploadId=@UniqueUploadID
			AND AuthorisationStatus in('NP','1A')

			UPDATE 
			IBPCPoolSummary_MOD 
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
				AND UploadType='IBPC Pool Upload'



	END


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
		SET @Result=CASE WHEN  @OperationFlag=1 AND @MenuId=1458 THEN @ExcelUploadId 
					ELSE 1 END

		
		 Update UploadStatus Set InsertionOfData='Y',InsertionCompletedOn=GETDATE() where FileNames=@filepath

		IF EXISTS(SELECT 1 FROM IBPCPoolDetail_stg WHERE filname=@FilePathUpload)
		 BEGIN
				 DELETE FROM IBPCPoolDetail_stg
			 WHERE filname=@FilePathUpload

			 PRINT 'ROWS DELETED FROM IBPCPoolDetail_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
		END
		 

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