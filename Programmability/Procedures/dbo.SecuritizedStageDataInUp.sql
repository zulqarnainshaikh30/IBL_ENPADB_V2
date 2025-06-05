SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



CREATE PROCEDURE  [dbo].[SecuritizedStageDataInUp]
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
--ColletralDetailUploadDataInUp

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
		
IF (@MenuId=1461)
BEGIN


	IF (@OperationFlag=1)

	BEGIN

		IF NOT (EXISTS (SELECT 1 FROM SecuritizedDetail_stg  where filname=@FilePathUpload))

							BEGIN
									 --Rollback tran
									SET @Result=-8

								RETURN @Result
							END
			
--Alter Table SecuritizedDetail_stg
--Add Action Char(1)
--alter Table ExcelUploadHistory
--add Action CHAR(1)

		IF EXISTS(SELECT 1 FROM SecuritizedDetail_stg WHERE FILNAME=@FilePathUpload)
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
		   ,'Securitized Upload'
		   ,@EffectiveFromTimeKey
		   ,@EffectiveToTimeKey
		   ,@UserLoginId
		   ,GETDATE()

		   PRINT @@ROWCOUNT

		   DECLARE @ExcelUploadId INT
	SET 	@ExcelUploadId=(SELECT MAX(UniqueUploadID) FROM  ExcelUploadHistory)
		
			Insert into UploadStatus (FileNames,UploadedBy,UploadDateTime,UploadType)
		Values(@filepath,@UserLoginID ,GETDATE(),'Securitized Upload')

		--Alter Table SecuritizedDetail_MOD
		--Add Action Char(1)

		
		INSERT INTO SecuritizedDetail_MOD
		(
			SrNo
			,UploadID
			,SummaryID
			,PoolID
			,PoolName
			,SecuritisationType
			,CustomerID
			,AccountID
			,POS
			,InterestReceivable
			,AuthorisationStatus	
			,EffectiveFromTimeKey	
			,EffectiveToTimeKey	
			,CreatedBy	
			,DateCreated
			,SecuritizedExposureAmt	
			,OSBalance
			,SecuritisationExposureinRs
			,DateofSecuritisationreckoning
			,DateofSecuritisationmarking
			,MaturityDate
			,Action
			,InterestAccruedinRs
		)

		SELECT
			SrNo
			,@ExcelUploadId
			,SummaryID
			,PoolID
			,PoolName
			--,SecuritisationType
			,PoolType
			,CustomerID
			,AccountID
			,ISNULL(AB.PrincipalBalance,0) PrincipalOutstandinginRs
			,ISNULL(AB.InterestReceivable,0) InterestReceivableinRs
			,'NP'	
			,@Timekey
			,49999	
			,@UserLoginID
			,GETDATE()
			,SecuritisationExposureinRs
			,AB.Balance OSBalanceinRs
			,SecuritisationExposureinRs
			,NULL DateofSecuritisationreckoning
			,DateofSecuritisationmarking
			,MaturityDate
			,Action
			,InterestAccruedinRs
		FROM SecuritizedDetail_stg AP
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


		Declare @SummaryId int
		Set @SummaryId=IsNull((Select Max(SummaryId) from SecuritizedSummary_Mod),0)

--Alter table  select * from SecuritizedSummary_stg
--add Action char(1)

print 'ANUJSummary'

PRINT @FilePathUpload
PRINT '@FilePathUpload'


		INSERT INTO SecuritizedSummary_stg
		(
			UploadID
			,SummaryID
			,PoolID
			,PoolName
			,SecuritisationType
			,POS
			,NoOfAccount
			,SecuritisationExposureAmt
			,SecuritisationReckoningDate
			,SecuritisationMarkingDate
			,MaturityDate
			,TotalPosBalance
			,TotalInttReceivable
			,Action
			,InterestAccruedinRs
		)

		SELECT
			@ExcelUploadId
			,@SummaryId+Row_Number() over(Order by PoolID)
			,PoolID
			,PoolName
			--,SecuritisationType
			,PoolType
			--,Sum(IsNull(Cast(PrincipalOutstandinginRs as decimal(16,2)),0)+IsNull(Cast(InterestReceivableinRs as Decimal(16,2)),0))
			,SUM(ISNULL(AB.Balance,0))
			,Count(PoolID)
			,SUM(ISNULL(Cast(SecuritisationExposureinRs as Decimal(16,2)),0))
			,Null DateofSecuritisationReckoning
			,DateofSecuritisationMarking
			,MaturityDate
			,Sum(IsNull(AB.PrincipalBalance ,0))
			,Sum(IsNull(AB.InterestReceivable ,0))
			,Action
			, Sum(IsNull(Cast(InterestAccruedinRs as Decimal(16,2)),0))
		FROM SecuritizedDetail_stg AP
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
		And  FilName=@FilePathUpload
		Group by PoolID,PoolName,PoolType,DateofSecuritisationMarking,MaturityDate,Action

		 
		----Alter Table SecuritizedSummary_stg
		----add InterestAccruedinRs decimal(16,2)
		---------------------------------------------------------ChangeField Logic---------------------
		----select * from AccountLvlMOCDetails_stg
	IF OBJECT_ID('TempDB..#Securitized_Upload') Is Not Null
	Drop Table #Securitized_Upload

	Create TAble #Securitized_Upload
	(
	AccountID Varchar(30), FieldName Varchar(50),SrNo Varchar(Max))

	Insert Into #Securitized_Upload(AccountID,FieldName)
	 Select AccountID, 'PoolID' FieldName from SecuritizedDetail_stg Where isnull(PoolID,'')<>'' 
	UNION ALL
	Select AccountID, 'PoolName' FieldName from SecuritizedDetail_stg Where isnull(PoolName,'')<>'' 
	UNION ALL
	Select AccountID, 'SecuritisationType' FieldName from SecuritizedDetail_stg Where isnull(PoolType,'')<>''
	UNION ALL
	--Select AccountID, 'CustomerID' FieldName from SecuritizedDetail_stg Where isnull(CustomerID,'')<>'' 
	--UNION ALL
	--Select AccountID, 'PrincipalOutstandinginRs' FieldName from SecuritizedDetail_stg Where isnull(PrincipalOutstandinginRs,'')<>'' 
	--UNION ALL
	--Select AccountID, 'InterestReceivableinRs' FieldName from SecuritizedDetail_stg Where isnull(InterestReceivableinRs,'')<>'' 
	--UNION ALL
	--Select AccountID, 'OSBalanceinRs' FieldName from SecuritizedDetail_stg Where isnull(OSBalanceinRs,'')<>'' 
	--UNION ALL
	Select AccountID, 'SecuritisationExposureinRs' FieldName from SecuritizedDetail_stg Where isnull(SecuritisationExposureinRs,'')<>'' 
	UNION ALL
	--Select AccountID, 'DateofSecuritisationreckoning' FieldName from SecuritizedDetail_stg Where isnull(DateofSecuritisationreckoning,'')<>'' 
	--UNION ALL
	Select AccountID, 'DateofSecuritisationmarking' FieldName from SecuritizedDetail_stg Where isnull(DateofSecuritisationmarking,'')<>'' 
	UNION ALL
	--Select AccountNumber, 'TotalAmtSacrifice' FieldName from SecuritizedDetail_stg Where isnull(TotalAmtSacrifice,'')<>''
	--UNION ALL
	Select AccountID, 'MaturityDate' FieldName from SecuritizedDetail_stg Where isnull(MaturityDate,'')<>'' 
	UNION ALL
	Select AccountID, 'Action' FieldName from SecuritizedDetail_stg Where isnull(Action,'')<>'' 
		UNION ALL
	Select AccountID, 'InterestAccruedinRs' FieldName from SecuritizedDetail_stg Where isnull(Action,'')<>'' 
	--UNION ALL
	--Select Account_ID, 'Actual_Write_Off_Date' FieldName from OTSUpload_stg Where isnull(Actual_Write_Off_Date,'')<>'' 
	--UNION ALL
	--Select AccountNumber, 'Accountclosuredateinsystem' FieldName from OTSUpload_stg Where isnull(Accountclosuredateinsystem,'')<>'' 
		
		
		print 'nanda3'

	--select *
	Update B set B.SrNo=A.ScreenFieldNo
	from MetaScreenFieldDetail A
	Inner Join #Securitized_Upload B ON A.CtrlName=B.FieldName
	Where A.MenuId=@MenuId And A.IsVisible='Y'


		print 'nanda4'
	
				 IF OBJECT_ID('TEMPDB..#NEWTRANCHE')  IS NOT NULL
					DROP TABLE #NEWTRANCHE

					SELECT * INTO #NEWTRANCHE FROM(
					SELECT 
						 SS.AccountID,
						STUFF((SELECT ',' + US.SrNo 
							FROM #Securitized_Upload US
							WHERE US.AccountID = SS.AccountID
							FOR XML PATH('')), 1, 1, '') [REPORTIDSLIST]
						FROM SecuritizedDetail_stg SS 
						GROUP BY SS.AccountID
						)B
						ORDER BY 1

						--Select * from #NEWTRANCHE

					--SELECT * 
					UPDATE A SET A.ChangeFields=B.REPORTIDSLIST
					FROM DBO.SecuritizedDetail_MOD A
					INNER JOIN #NEWTRANCHE B ON A.AccountID=B.AccountID
					WHERE  A.EFFECTIVEFROMTIMEKEY<=@TimeKey AND A.EFFECTIVETOTIMEKEY>=@TimeKey
					And A.UploadID=@ExcelUploadId






		PRINT @@ROWCOUNT
		
		---DELETE FROM STAGING DATA
		 DELETE FROM SecuritizedDetail_stg
		 WHERE filname=@FilePathUpload

--		 ----RETURN @ExcelUploadId

END
--		   ----DECLARE @UniqueUploadID INT
--	--SET 	@UniqueUploadID=(SELECT MAX(UniqueUploadID) FROM  ExcelUploadHistory)
	END

----------------Two level Auth. changes----------------------

IF (@OperationFlag=16)----AUTHORIZE

	BEGIN

		
		UPDATE 
			SecuritizedDetail_MOD 
			SET 
			AuthorisationStatus	='1A'
			,ApprovedByFirstLevel	=@UserLoginID
			,DateApprovedFirstLevel	=GETDATE()
			
			WHERE UploadId=@UniqueUploadID

			UPDATE 
			SecuritizedSummary_Mod 
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
		   AND UploadType='Securitized Upload'
	END

	IF (@OperationFlag=20)----AUTHORIZE

	BEGIN
		
		UPDATE 
			SecuritizedDetail_MOD 
			SET 
			AuthorisationStatus	='A'
			,ApprovedBy	=@UserLoginID
			,DateApproved	=GETDATE()
			
			WHERE UploadId=@UniqueUploadID

			UPDATE 
			SecuritizedSummary_Mod 
			SET 
			AuthorisationStatus	='A'
			,ApprovedBy	=@UserLoginID
			,DateApproved	=GETDATE()
			
			WHERE UploadId=@UniqueUploadID

			Update  A
			Set A.EffectiveToTimeKey=A.EffectiveFromTimeKey-1
			from SecuritizedDetail A
			inner join SecuritizedDetail_mod B
			ON A.AccountID=B.AccountID
			AND B.EffectiveFromTimeKey <=@Timekey
			AND B.EffectiveToTimeKey >=@Timekey
			Where B.UploadId=@UniqueUploadID
			And B.Action in('A','R')
			AND A.EffectiveToTimeKey >=49999

			  --alter Table SecuritizedDetail
			  --add Action char(1)
			  
			-----maintain history
			INSERT INTO SecuritizedDetail(SummaryID
						,PoolID
						,PoolName
						,SecuritisationType
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
						,SecuritizedExposureAmt
						,OSBalance
						,SecuritisationExposureinRs
						,DateofSecuritisationreckoning
						,DateofSecuritisationmarking
						,MaturityDate
						,Action
						,InterestAccruedinRs
						
						)
			SELECT SummaryID
					,PoolID
					,PoolName
					,SecuritisationType
					,CustomerID
					,AccountID
					,POS
					,InterestReceivable
					,AuthorisationStatus
					,@Timekey
					,49999
					,CreatedBy
					,DateCreated
					,ModifyBy
					,DateModified
					,@UserLoginID
					,Getdate()
					,SecuritizedExposureAmt
					,OSBalance
					,SecuritisationExposureinRs
					,DateofSecuritisationreckoning
					,DateofSecuritisationmarking
					,MaturityDate
					,Action
					,InterestAccruedinRs
					
			FROM SecuritizedDetail_MOD A
			WHERE  A.UploadId=@UniqueUploadID and EffectiveToTimeKey>=@Timekey
			And A.Action in('A')

			Update  A
			Set A.EffectiveToTimeKey=A.EffectiveFromTimeKey-1
			,A.scrOutDate=Case When B.Action='R' then GETDATE() else null End
			,A.FlagAlt_Key=Case When B.Action='R' then 'N' Else A.FlagAlt_Key End
			from SecuritizedFinalACDetail A
			inner join SecuritizedDetail_mod B
			ON A.AccountID=B.AccountID
			AND B.EffectiveFromTimeKey <=@Timekey
			AND B.EffectiveToTimeKey >=@Timekey
			Where B.UploadId=@UniqueUploadID
			AND A.EffectiveToTimeKey >=49999
			And B.Action in('A','R')
			/*
---new add
alter table SecuritizedFinalACDetail
add ScrOutDate date,ScrInDate Date


*/


			 INSERT INTO SecuritizedFinalACDetail  
          (   SummaryID
			,PoolID
			,PoolName
			,SecuritisationType
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
			,ScrInDate
			,AccountBalance--new added
			,SourceAlt_Key
			,FlagAlt_Key
			,PoolType
			,MaturityDate
			,SecMarkingDate
			,CustomerName
			,InterestAccruedinRs
  
            )  
			SELECT SummaryID
					,PoolID
					,PoolName
					,SecuritisationType
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
					,SecuritizedExposureAmt
					,GETDATE()
					,OSBalance
					,B.SourceAlt_Key
					,Case when A.action='A' Then 'Y' Else 'N' End
					,A.SecuritisationType
					,A.MaturityDate
					,DateofSecuritisationmarking
					,C.CustomerName
					,InterestAccruedinRs
			FROM SecuritizedDetail_MOD A
			Inner Join CurDat.AdvAcBasicDetail B ON A.AccountID=B.CustomerACID
			ANd B.EffectiveFromTimeKey<=@Timekey ANd B.EffectiveToTimeKey>=@Timekey
			Inner Join CurDat.CustomerBasicDetail C ON B.customerEntityId=C.CustomerEntityId
			ANd C.EffectiveFromTimeKey<=@Timekey ANd C.EffectiveToTimeKey>=@Timekey
			WHERE  A.UploadId=@UniqueUploadID and A.EffectiveToTimeKey>=@Timekey
			And A.Action in('A')

			Insert into SecuritizedFinalACSummary
			(
			SummaryID
			,PoolID
			,PoolName
			,SecuritisationType
			,POS
			,SecuritisationExposureAmt
			,SecuritisationReckoningDate
			,SecuritisationMarkingDate
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
			--,ScrInDate 
			)
			SELECT SummaryID
					,PoolID
					,PoolName
					,SecuritisationType
					,POS
					,SecuritisationExposureAmt
					,SecuritisationReckoningDate
					,SecuritisationMarkingDate
					,MaturityDate
					,NoOfAccount
					,AuthorisationStatus
					,@Timekey
					,49999
					,CreatedBy
					,DateCreated
					,ModifyBy
					,DateModified
					,@UserLoginID
					,Getdate()
					,TotalPosBalance
					,TotalInttReceivable
					--,GETDATE()
			FROM SecuritizedSummary_Mod A
			WHERE  A.UploadId=@UniqueUploadID and EffectiveToTimeKey>=@Timekey
            --And A.Action in('A')



			INSERT INTO SecuritizedSummary(
					SummaryID
					,PoolID
					,PoolName
					,SecuritisationType
					,POS
					,SecuritisationExposureAmt
					,SecuritisationReckoningDate
					,SecuritisationMarkingDate
					,DateofRemoval
					,NoOfAccount
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
					,PoolID
					,PoolName
					,SecuritisationType
					,POS         --,BalanceOutstanding
					,SecuritisationExposureAmt
					,SecuritisationReckoningDate
					,SecuritisationMarkingDate
					,MaturityDate
					,NoOfAccount
					,AuthorisationStatus
					,@Timekey
					,49999
					,CreatedBy
					,DateCreated
					,ModifyBy
					,DateModified
					,@UserLoginID
					,Getdate()
			FROM SecuritizedSummary_Mod A
			WHERE  A.UploadId=@UniqueUploadID and EffectiveToTimeKey>=@Timekey

			/*--------------------Adding Flag To AdvAcOtherDetail------------Pranay 21-03-2021--------*/ 


IF OBJECT_ID('TempDB..#SecuritizeNew') Is Not NUll
Drop Table #SecuritizeNew

Select A.RefSystemAcId,A.SplFlag into #SecuritizeNew FROM DBO.AdvAcOtherDetail A
     INNER JOIN SecuritizedDetail_MOD B ON A.RefSystemAcId=B.AccountID
			WHERE  B.UploadId=@UniqueUploadID and B.EffectiveToTimeKey>=@Timekey
			AND A.EffectiveToTimeKey=49999 And A.SplFlag Like '%Securitised%'

  UPDATE A
	SET  
        A.SplFlag=CASE WHEN ISNULL(A.SplFlag,'')='' THEN 'Securitised'     
						ELSE A.SplFlag+','+'Securitised'     END
		    
   FROM DBO.AdvAcOtherDetail A
   --INNER JOIN #Temp V  ON A.AccountEntityId=V.AccountEntityId
  INNER JOIN SecuritizedDetail_MOD B ON A.RefSystemAcId=B.AccountID
			WHERE  B.UploadId=@UniqueUploadID and B.EffectiveToTimeKey>=@Timekey
			AND A.EffectiveToTimeKey=49999
			AND Not Exists (Select 1 from #SecuritizeNew N Where N.RefSystemAcId=A.RefSystemAcId)
----remove flag when Action R

--select * from SecuritizedDetail_MOD where UploadId=2659
--select SplFlag,*   FROM DBO.AdvAcOtherDetail where RefSystemAcId='1711228115822651'


 UPDATE A
	SET  
        A.SplFlag=Replace(A.SplFlag,'Securitised','')    
						
	--select *	    
   FROM DBO.AdvAcOtherDetail A
   --INNER JOIN #Temp V  ON A.AccountEntityId=V.AccountEntityId
  INNER JOIN SecuritizedDetail_MOD B ON A.RefSystemAcId=B.AccountID
			WHERE  B.UploadId=@UniqueUploadID and B.EffectiveToTimeKey>=@Timekey
			AND A.EffectiveToTimeKey=49999
			And B.Action='R'
			--AND Not Exists (Select * from #SecuritizeNew1 N Where N.RefSystemAcId=A.RefSystemAcId)

-------------------------------------------

			UPDATE A
			SET 
			A.POS=ROUND(B.POS,2)
			--,a.ModifyBy=@UserLoginID
			--,a.DateModified=GETDATE()
			FROM SecuritizedDetail A
			INNER JOIN SecuritizedDetail_MOD  B ON (A.EffectiveFromTimeKey<=@Timekey AND A.EffectiveToTimeKey>=@Timekey)
																AND  (B.EffectiveFromTimeKey<=@Timekey AND B.EffectiveToTimeKey>=@Timekey)	
																AND A.AccountID=B.AccountID

				WHERE B.AuthorisationStatus='A'
				AND B.UploadId=@UniqueUploadID

				UPDATE
				ExcelUploadHistory
				SET AuthorisationStatus='A',ApprovedBy=@UserLoginID,DateApproved=GETDATE()
				WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
				AND UniqueUploadID=@UniqueUploadID
				AND UploadType='Securitized Upload'

				


	END

	IF (@OperationFlag=17)----REJECT

	BEGIN
		
		UPDATE 
			SecuritizedDetail_MOD 
			SET 
			AuthorisationStatus	='R'
			,ApprovedByFirstLevel	=@UserLoginID
			,DateApprovedFirstLevel	=GETDATE()
			,EffectiveToTimeKey =@EffectiveFromTimeKey-1 
			WHERE UploadId=@UniqueUploadID
			AND AuthorisationStatus='NP'

			UPDATE 
			SecuritizedSummary_Mod 
			SET 
			AuthorisationStatus	='R'
			,ApprovedBy	=@UserLoginID
			,DateApproved	=GETDATE()
		
			WHERE UploadId=@UniqueUploadID
			AND AuthorisationStatus='NP'
			
			UPDATE
				ExcelUploadHistory
				SET AuthorisationStatus='R',ApprovedBy=@UserLoginID,DateApproved=GETDATE()
				WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
				AND UniqueUploadID=@UniqueUploadID
				AND UploadType='Securitized Upload'
	END

			IF (@OperationFlag=21)----REJECT

	BEGIN
		
		UPDATE 
			SecuritizedDetail_MOD 
			SET 
			AuthorisationStatus	='R'
			,ApprovedBy	=@UserLoginID
			,DateApproved	=GETDATE()
			,EffectiveToTimeKey =@EffectiveFromTimeKey-1 			
			WHERE UploadId=@UniqueUploadID
			AND AuthorisationStatus in('NP','1A')

			UPDATE 
			SecuritizedSummary_Mod 
			SET 
			AuthorisationStatus	='R'
			,ApprovedBy	=@UserLoginID
			,DateApproved	=GETDATE()
			
			WHERE UploadId=@UniqueUploadID
			AND AuthorisationStatus in ('NP','1A')
--			----SELECT * FROM IBPCPoolDetail

			UPDATE
				ExcelUploadHistory
				SET AuthorisationStatus='R',ApprovedBy=@UserLoginID,DateApproved=GETDATE()
				WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
				AND UniqueUploadID=@UniqueUploadID
				AND UploadType='Securitized Upload'



	END


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
								@ReferenceID= @UniqueUploadID,-- ReferenceID ,
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
		SET @Result=CASE WHEN  @OperationFlag=1  AND @MenuId=1461 THEN @ExcelUploadId 
					ELSE 1 END

		
		 Update UploadStatus Set InsertionOfData='Y',InsertionCompletedOn=GETDATE() where FileNames=@filepath

--		 ---- IF EXISTS(SELECT 1 FROM SecuritizedDetail_stg WHERE filEname=@FilePathUpload)
--		 ----BEGIN
--			----	 DELETE FROM SecuritizedDetail_stg
--			----	 WHERE filEname=@FilePathUpload

--			----	 PRINT 'ROWS DELETED FROM SecuritizedDetail_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
--		 ----END
		 

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