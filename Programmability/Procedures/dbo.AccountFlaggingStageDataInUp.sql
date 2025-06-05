SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE  [dbo].[AccountFlaggingStageDataInUp]
	@Timekey INT,
	@UserLoginID VARCHAR(100),
	@OperationFlag INT,
	@MenuId INT,
	@AuthMode	CHAR(1),
	@filepath VARCHAR(MAX),
	@EffectiveFromTimeKey INT,
	@EffectiveToTimeKey	INT,
    @Result		INT=0 OUTPUT,
	@UniqueUploadID INT ,
	@UploadTypeParameterAlt_Key Int
	--@ApprovedBy	 Varchar(30), 
	--@DateApproved  Datetime
	----@UploadType varchar(50)

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
		
IF (@MenuId=1470)
BEGIN


	IF (@OperationFlag=1)

	BEGIN

		IF NOT (EXISTS (SELECT 1 FROM AccountFlagging_Stg  where filname=@FilePathUpload))

							BEGIN
									 --Rollback tran
									SET @Result=-8

								RETURN @Result
							END
			


		IF EXISTS(SELECT 1 FROM AccountFlagging_Stg WHERE FILNAME=@FilePathUpload)
		BEGIN
		
		INSERT INTO ExcelUploadHistory  --select DateCreated,* from ExcelUploadHistory order by 1 desc
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
		   ,'Account Flagging Upload'
		   ,@EffectiveFromTimeKey
		   ,@EffectiveToTimeKey
		   ,@UserLoginID
		   ,GETDATE()

		   PRINT @@ROWCOUNT

		    DECLARE @ExcelUploadId INT
	        SET 	@ExcelUploadId=(SELECT MAX(UniqueUploadID) FROM  ExcelUploadHistory)
		
			Insert into UploadStatus (FileNames,UploadedBy,UploadDateTime,UploadType)
		    Values(@filepath,@UserLoginID ,GETDATE(),'Account Flagging Upload')

		INSERT INTO AccountFlaggingDetails_Mod
		(
			 UploadID
			,ACID
			,Amount
			,Date
			,Action
			--,UploadType
			,UploadTypeParameterAlt_Key
			,AuthorisationStatus	
			,EffectiveFromTimeKey	
			,EffectiveToTimeKey	
			,CreatedBy	
			,DateCreated
		)
		SELECT
			@ExcelUploadId
			,ACID
			,NULLIF(Amount,'')
			,Date
			,Action
			--,@UploadType
			,@UploadTypeParameterAlt_Key
			,'NP'	
			,@Timekey
			,49999	
			,@UserLoginID	
			,GETDATE() 
		FROM AccountFlagging_Stg 
		--A
		--Inner Join (Select ParameterAlt_Key,ParameterName,'UploadType' as Tablename 
		--				  from DimParameter where DimParameterName='UploadFLagType'
		--				  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)B
		--				  ON A.UploadTypeParameterAlt_Key=B.ParameterAlt_Key
		where FilName=@FilePathUpload
		--AND @UploadTypeParameterAlt_Key=1
		--and A.UploadTypeParameterAlt_Key=@UploadTypeParameterAlt_Key

		----Declare @SummaryId int
		----Set @SummaryId=IsNull((Select Max(SummaryId) from IBPCPoolSummary_Mod),0)

		----INSERT INTO IBPCPoolSummary_stg
		----(
		----	UploadID
		----	,SummaryID
		----	,PoolID
		----	,PoolName
		----	,PoolType
		----	,BalanceOutstanding
		----	,NoOfAccount
		----	,IBPCExposureAmt
		----	,IBPCReckoningDate
		----	,IBPCMarkingDate
		----	,MaturityDate
		----	,TotalPosBalance
		----	,TotalInttReceivable
		----)

		----SELECT
		----	@ExcelUploadId
		----	,@SummaryId+Row_Number() over(Order by PoolID)
		----	,PoolID
		----	,PoolName
		----	,PoolType
		----	,Sum(IsNull(Cast(PrincipalOutstandinginRs as decimal(16,2)),0)+IsNull(Cast(InterestReceivableinRs as Decimal(16,2)),0))
		----	,Count(PoolID)
		----	,SUM(ISNULL(Cast(IBPCExposureinRs as Decimal(16,2)),0))
		----	,DateofIBPCreckoning
		----	,DateofIBPCmarking
		----	,MaturityDate
		----	,Sum(IsNull(Cast(PrincipalOutstandinginRs as decimal(16,2)),0))
		----	,Sum(IsNull(Cast(InterestReceivableinRs as Decimal(16,2)),0))
		----FROM IBPCPoolDetail_stg
		----where FilName=@FilePathUpload
		----Group by PoolID,PoolName,PoolType,DateofIBPCreckoning,DateofIBPCmarking,MaturityDate

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
		 --DELETE FROM AccountFlagging_Stg
		 --WHERE filname=@FilePathUpload

		 ----RETURN @ExcelUploadId

END
		   ----DECLARE @UniqueUploadID INT
	--SET 	@UniqueUploadID=(SELECT MAX(UniqueUploadID) FROM  ExcelUploadHistory)
	END

----------------------Two level Auth. Changes-------------

IF (@OperationFlag=16)----AUTHORIZE

	BEGIN 
		    UPDATE 
			AccountFlaggingDetails_Mod 
			SET 
			AuthorisationStatus	='1A'
			,ApprovedByFirstLevel	=@UserLoginID
			,DateApprovedFirstLevel	=GETDATE() 
			WHERE UploadId=@UniqueUploadID
									
		   UPDATE 
		   ExcelUploadHistory
		   SET AuthorisationStatus='1A'
		   ,ApprovedByFirstLevel	=@UserLoginID
		   where UniqueUploadID=@UniqueUploadID
		   AND UploadType='Account Flagging Upload'
	END
--------------------------------------------

	IF (@OperationFlag=20)----AUTHORIZE

	BEGIN
		
		    UPDATE 
			AccountFlaggingDetails_Mod 
			SET 
			AuthorisationStatus	='A'
			,ApprovedBy	=@UserLoginID
			,DateApproved	=GETDATE() 
			WHERE UploadId=@UniqueUploadID

			UPDATE  A
						SET A.EffectiveToTimeKey=@Timekey-1
						from AccountFlaggingDetails A
						INNER JOIN AccountFlaggingDetails_Mod C
							ON A.ACID=C.ACID
								AND A.UploadTypeParameterAlt_Key=C.UploadTypeParameterAlt_Key
								AND C.EffectiveFromTimeKey <=@Timekey AND C.EffectiveToTimeKey >=@Timekey
								AND C.AuthorisationStatus='A' 
						WHERE A.EffectiveToTimeKey >=@Timekey
						AND A.AuthorisationStatus = 'A'
						AND UploadId=@UniqueUploadID
						And C.Action='Y'

 DEclare @StatusTypeName as Varchar(100)
 Set @StatusTypeName = (select ParameterName from DimParameter where DimParameterName ='uploadflagtype' and EffectiveToTimeKey=49999 
 and ParameterAlt_Key= (select distinct UploadTypeParameterAlt_Key from AccountFlaggingDetails_Mod where UploadId=@UniqueUploadID ))--and Action='N'))
						
			UPDATE  A
						SET A.EffectiveToTimeKey=@Timekey-1
						from ExceptionFinalStatusType A
						INNER JOIN AccountFlaggingDetails_Mod C
							ON A.ACID=C.ACID
								AND C.EffectiveFromTimeKey <=@Timekey AND C.EffectiveToTimeKey >=@Timekey
								AND C.AuthorisationStatus='A' 
						WHERE A.EffectiveToTimeKey >=@Timekey
						AND C.UploadId=@UniqueUploadID 
						And C.Action='Y'
						And A.StatusType=@StatusTypeName

			--UPDATE 
			--IBPCPoolSummary_MOD 
			--SET 
			--AuthorisationStatus	='A'
			--,ApprovedBy	=@UserLoginID
			--,DateApproved	=GETDATE()
			
			--WHERE UploadId=@UniqueUploadID

			-----maintain history

			--select DateCreated , DateApproved ,* from AccountFlaggingDetails where ACID='1376140000008968' order by 1 desc
			 --select DateCreated , DateApproved ,* from AccountFlaggingDetails_mod where ACID='1376140000008968' order by 1 desc

			INSERT INTO AccountFlaggingDetails(
						ACID
						,Amount
						,Date
						,Action
						--,UploadType
						,UploadTypeParameterAlt_Key
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
			SELECT 
					ACID
					,Amount
					,Date
					,Action
					--,@UploadType
					--,@UploadTypeParameterAlt_Key
					,UploadTypeParameterAlt_Key
					,AuthorisationStatus
					,@Timekey,49999
					,CreatedBy
					,DateCreated
					,ModifyBy
					,DateModified
					,@UserLoginID
					,Getdate()

					FROM AccountFlaggingDetails_Mod A
					WHERE  A.UploadId=@UniqueUploadID 
					AND Action='Y'
					and	EffectiveFromTimekey <= @Timekey
					and EffectiveToTimeKey>=@Timekey
			

			INSERT INTO ExceptionFinalStatusType(
						SourceAlt_Key
						,CustomerID
						,ACID
						,StatusType
						,StatusDate
						,Amount
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
			SELECT 
					B.SourceAlt_Key
					,B.RefCustomerId
					,ACID
					,H.ParameterName  
					,Date
					,Amount
					,A.AuthorisationStatus
					,@Timekey,49999
					,A.CreatedBy
					,A.DateCreated
					,ModifyBy
					,A.DateModified
					,@UserLoginID
					,Getdate()
					FROM AccountFlaggingDetails_Mod A
					inner join (
									select distinct SourceAlt_Key,RefCustomerId,
									CustomerACID,max(EffectiveToTimekey)Timekey 
									from dbo.advacbasicdetail 
									group by SourceAlt_Key,RefCustomerId,CustomerACID
								) B
					ON A.ACID=B.CustomerACID
					Inner Join (Select ParameterAlt_Key,ParameterName,'DimYesNo' as Tablename 
						  from DimParameter where DimParameterName='UploadFlagType'
						  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)H
						  ON H.ParameterAlt_Key=A.UploadTypeParameterAlt_Key
					--AND B.EffectiveFromTimeKey <= @timekey
					--AND B.EffectiveToTimeKey >= @Timekey
					WHERE  A.UploadId=@UniqueUploadID 
					And A.Action='Y'



/*Adding Flag ---------- 02-04-2021*/

IF OBJECT_ID('TempDB..#Flags') IS NOT NULL
Drop Table #Flags

Select A.ACID,B.SplCatShortNameEnum into #Flags  from AccountFlaggingDetails_Mod A
Inner Join (Select 
B.ParameterAlt_Key,A.SplCatShortNameEnum
 from DimAcSplCategory A
inner join DimParameter B on A.SplCatName=B.ParameterName and B.EffectiveToTimeKey=49999
where A.splcatgroup='SplFlags' And A.EffectiveToTimeKey=49999 And B.DimParameterName ='uploadflagtype'
)B On A.UploadTypeParameterAlt_Key=B.ParameterAlt_Key
WHERE  A.UploadId=@UniqueUploadID AND A.Action='Y'

--		Declare @variable Varchar(100)=''
		
--Set @variable=(Select Splcatshortnameenum from dimacsplcategory  where splcatgroup='splflags' and 
--SplCatName like (select ParameterName from dimparameter
--where dimparametername ='UploadFLagType' and ParameterAlt_Key=@UploadTypeParameterAlt_Key))

		  UPDATE A
			SET  
				A.SplFlag=CASE WHEN ISNULL(A.SplFlag,'')='' THEN B.SplCatShortNameEnum--'IBPC'     
								ELSE A.SplFlag+','+B.SplCatShortNameEnum END 
		   FROM DBO.AdvAcOtherDetail A
		   Inner Join #Flags B On A.RefSystemAcId=B.ACID
		   Where A.EffectiveToTimeKey=49999

---------------------

-----------Remove------------------------

-------

Update B Set B.EffectiveToTimeKey=@Timekey-1
FROM AccountFlaggingDetails_Mod A
					inner join AccountFlaggingDetails B
					ON A.ACID=B.ACID
					AND B.EffectiveFromTimeKey <= @timekey
					AND B.EffectiveToTimeKey >= @Timekey
					WHERE  A.UploadId=@UniqueUploadID 
					And A.Action='N'
					And B.UploadTypeParameterAlt_Key=A.UploadTypeParameterAlt_Key
					--AND A.UploadTypeParameterAlt_Key=@UploadTypeParameterAlt_Key


Update B Set B.EffectiveToTimeKey=@Timekey-1
FROM AccountFlaggingDetails_Mod A
					inner join ExceptionalDegrationDetail B
					ON A.ACID=B.AccountID
					AND B.EffectiveFromTimeKey <= @timekey
					AND B.EffectiveToTimeKey >= @Timekey
					WHERE  A.UploadId=@UniqueUploadID 
					And A.Action='N'
					AND B.FlagAlt_Key=A.UploadTypeParameterAlt_Key
					--And A.UploadTypeParameterAlt_Key=@UploadTypeParameterAlt_Key

  DEclare @ParameterName as Varchar(100)
 Set @ParameterName = (select ParameterName from DimParameter where DimParameterName ='uploadflagtype' and EffectiveToTimeKey=49999 
 and ParameterAlt_Key= (select distinct UploadTypeParameterAlt_Key from AccountFlaggingDetails_Mod where UploadId=@UniqueUploadID and Action='N'))

Update B Set B.EffectiveToTimeKey=@Timekey-1
FROM AccountFlaggingDetails_Mod A
					inner join ExceptionFinalStatusType B
					ON A.ACID=B.ACID
					AND B.EffectiveFromTimeKey <= @timekey
					AND B.EffectiveToTimeKey >= @Timekey
					WHERE  A.UploadId=@UniqueUploadID 
					And A.Action='N'
					--And A.UploadTypeParameterAlt_Key=@UploadTypeParameterAlt_Key
					And B.StatusType=@ParameterName



IF OBJECT_ID('TempDB..#Flags1') IS NOT NULL
Drop Table #Flags1

Select A.ACID,B.SplCatShortNameEnum into #Flags1  from AccountFlaggingDetails_Mod A
Inner Join (Select 
B.ParameterAlt_Key,A.SplCatShortNameEnum
 from DimAcSplCategory A
inner join DimParameter B on A.SplCatName=B.ParameterName and B.EffectiveToTimeKey=49999
where A.splcatgroup='SplFlags' And A.EffectiveToTimeKey=49999 And B.DimParameterName ='uploadflagtype'
)B On A.UploadTypeParameterAlt_Key=B.ParameterAlt_Key
WHERE  A.UploadId=@UniqueUploadID AND A.Action='N'


				IF OBJECT_ID('TempDB..#Temp') IS NOT NULL
				DROP TABLE #Temp

				Select A.AccountentityID,A.SplFlag into #Temp from Curdat.AdvAcOtherDetail A
				Inner Join #Flags1 B ON  A.RefSystemAcId=B.ACID
				where A.EffectiveToTimeKey=49999 


				--Select * from #Temp


				IF OBJECT_ID('TEMPDB..#SplitValue')  IS NOT NULL
				DROP TABLE #SplitValue        
				SELECT AccountentityID,Split.a.value('.', 'VARCHAR(8000)') AS Businesscolvalues1  into #SplitValue
											FROM  (SELECT 
															CAST ('<M>' + REPLACE(SplFlag, ',', '</M><M>') + '</M>' AS XML) AS Businesscolvalues1,
															AccountentityID
															from #Temp 
													) AS A CROSS APPLY Businesscolvalues1.nodes ('/M') AS Split(a)
						


				 --Select * from #SplitValue 

				 DELETE FROM #SplitValue WHERE Businesscolvalues1 In (Select distinct SplCatShortNameEnum from #Flags1)




				 IF OBJECT_ID('TEMPDB..#NEWTRANCHE')  IS NOT NULL
					DROP TABLE #NEWTRANCHE

					SELECT * INTO #NEWTRANCHE FROM(
					SELECT 
						 SS.AccountentityID,
						STUFF((SELECT ',' + US.BUSINESSCOLVALUES1 
							FROM #SPLITVALUE US
							WHERE US.AccountentityID = SS.AccountentityID
							FOR XML PATH('')), 1, 1, '') [REPORTIDSLIST]
						FROM #TEMP SS 
						GROUP BY SS.AccountentityID
						)B
						ORDER BY 1

						--Select * from #NEWTRANCHE

					--SELECT * 
					UPDATE A SET A.SplFlag=B.REPORTIDSLIST
					FROM DBO.AdvAcOtherDetail A
					INNER JOIN #NEWTRANCHE B ON A.AccountentityID=B.AccountentityID
					WHERE  A.EFFECTIVEFROMTIMEKEY<=@TimeKey AND A.EFFECTIVETOTIMEKEY>=@TimeKey




--------------------------------------------------

----			INSERT INTO IBPCPoolSummary(
----					SummaryID
----					,PoolID
----					,PoolName
----					,PoolType
----					,BalanceOutstanding
----					,IBPCExposureAmt
----					,IBPCReckoningDate
----					,IBPCMarkingDate
----					,MaturityDate
----					,NoOfAccount
----						,EffectiveFromTimeKey
----						,EffectiveToTimeKey
----						,CreatedBy
----						,DateCreated
----						,ModifyBy
----						,DateModified
----						,ApprovedBy
----						,DateApproved
----						,TotalPosBalance
----						,TotalInttReceivable
----						)
----			SELECT SummaryID
----					,PoolID
----					,PoolName
----					,PoolType
----					,BalanceOutstanding
----					,IBPCExposureAmt
----					,IBPCReckoningDate
----					,IBPCMarkingDate
----					,MaturityDate
----					,NoOfAccount
----					,@Timekey,49999
----					,CreatedBy
----					,DateCreated
----					,ModifyBy
----					,DateModified
----					,@UserLoginID
----					,Getdate()
----					,TotalPosBalance
----					,TotalInttReceivable
----			FROM IBPCPoolSummary_Mod A
----			WHERE  A.UploadId=@UniqueUploadID and EffectiveToTimeKey>=@Timekey


----			-----------------Insert into Final Tables ----------

----			Insert into IBPCFinalPoolDetail
----			(
----			SummaryID
----			,PoolID
----			,PoolName
----			,CustomerID
----			,AccountID
----			,POS
----			,InterestReceivable
----			,EffectiveFromTimeKey
----			,EffectiveToTimeKey
----			,CreatedBy
----			,DateCreated
----			,ModifyBy
----			,DateModified
----			,ApprovedBy
----			,DateApproved
----			,ExposureAmount
----			)
----			SELECT SummaryID
----					,PoolID
----					,PoolName
----					,CustomerID
----					,AccountID
----					,POS
----					,InterestReceivable
----					,@Timekey,49999
----					,CreatedBy
----					,DateCreated
----					,ModifyBy
----					,DateModified
----					,@UserLoginID
----					,Getdate()
----					,IBPCExposureAmt
----			FROM IBPCPoolDetail_MOD A
----			WHERE  A.UploadId=@UniqueUploadID and EffectiveToTimeKey>=@Timekey

----			---Summary Final -----------

----			Insert into IBPCFinalPoolSummary
----			(
----			SummaryID
----			,PoolID
----			,PoolName
----			,PoolType
----			,BalanceOutstanding
----			,IBPCExposureAmt
----			,IBPCReckoningDate
----			,IBPCMarkingDate
----			,MaturityDate
----			,NoOfAccount
----			,EffectiveFromTimeKey
----			,EffectiveToTimeKey
----			,CreatedBy
----			,DateCreated
----			,ModifyBy
----			,DateModified
----			,ApprovedBy
----			,DateApproved
----			,TotalPosBalance
----			,TotalInttReceivable
----			)
----			SELECT SummaryID
----					,PoolID
----					,PoolName
----					,PoolType
----					,BalanceOutstanding
----					,IBPCExposureAmt
----					,IBPCReckoningDate
----					,IBPCMarkingDate
----					,MaturityDate
----					,NoOfAccount
----					,@Timekey,49999
----					,CreatedBy
----					,DateCreated
----					,ModifyBy
----					,DateModified
----					,@UserLoginID
----					,Getdate()
----					,TotalPosBalance
----					,TotalInttReceivable
----			FROM IBPCPoolSummary_Mod A
----			WHERE  A.UploadId=@UniqueUploadID and EffectiveToTimeKey>=@Timekey

-------------------------------------------------

---------------------------Added on 20032021----------------------

			UPDATE  B
			SET
			EffectiveToTimeKey=@EffectiveFromTimeKey-1
			,AuthorisationStatus =CASE WHEN @AUTHMODE='Y' THEN  'A' ELSE NULL END  
			FROM AccountFlaggingDetails  B
			WHERE B.AuthorisationStatus='A'
			AND B.Action='N'
			AND  (B.EffectiveFromTimeKey<=@Timekey AND B.EffectiveToTimeKey>=@Timekey)
			--AND B.UploadId=@UniqueUploadID

------------------------------------------------------------------
 ------------------------- REDMINE TRACKER ID  : 66895 
			--UPDATE A
			--SET 
			----A.POS=ROUND(B.POS,2),
			--a.ModifyBy=@UserLoginID
			--,a.DateModified=GETDATE()
			--FROM AccountFlaggingDetails A
			--INNER JOIN AccountFlaggingDetails_Mod  B ON (A.EffectiveFromTimeKey<=@Timekey AND A.EffectiveToTimeKey>=@Timekey)
			--													AND  (B.EffectiveFromTimeKey<=@Timekey AND B.EffectiveToTimeKey>=@Timekey)	
			--													AND A.ACID=B.ACID

			--	WHERE B.AuthorisationStatus='A'
			--	AND B.UploadId=@UniqueUploadID

				UPDATE
				ExcelUploadHistory
				SET AuthorisationStatus='A',ApprovedBy=@UserLoginID,DateApproved=GETDATE()
				WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
				AND UniqueUploadID=@UniqueUploadID
				AND UploadType='Account Flagging Upload'

				


	END

	IF (@OperationFlag=17)----REJECT

	BEGIN 
		
		UPDATE 
			AccountFlaggingDetails_Mod 
			SET 
			AuthorisationStatus	='R',
			ApprovedBy	=@UserLoginID,
			DateApproved=GETDATE(),

			 ApprovedByFirstLevel 	=@UserLoginID,
			 DateApprovedFirstLevel	=Cast(GETDATE() as datetime)
			 ,EffectiveToTimeKey =@EffectiveFromTimeKey-1        ------Added by kapil on 08/02/2024
			
			WHERE UploadId=@UniqueUploadID
			AND  AuthorisationStatus in('NP','MP','DP','RM')	

			----UPDATE 
			----IBPCPoolSummary_MOD 
			----SET 
			----AuthorisationStatus	='R'
			----,ApprovedBy	=@UserLoginID
			----,DateApproved	=GETDATE()
			
			----WHERE UploadId=@UniqueUploadID
			----AND AuthorisationStatus='NP'
			----SELECT * FROM IBPCPoolDetail

			UPDATE
				ExcelUploadHistory
				SET AuthorisationStatus='R',ApprovedByFirstLevel=@UserLoginID,DateApprovedFirstLevel=GETDATE()
				,EffectiveToTimeKey =@EffectiveFromTimeKey-1             ------Added by kapil on 08/02/2024
				WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
				AND UniqueUploadID=@UniqueUploadID
				AND UploadType='Account Flagging Upload'



	END


-------------------------Two level Auth. Changes.-------------

IF (@OperationFlag=21)----REJECT

	BEGIN
		
		UPDATE 
			AccountFlaggingDetails_Mod 
			SET AuthorisationStatus	='R'
			,ApprovedBy	=@UserLoginID
			,DateApproved	=Cast(GETDATE() as datetime)	 
			,EffectiveToTimeKey =@EffectiveFromTimeKey-1        ------Added by kapil on 08/02/2024
			WHERE UploadId=@UniqueUploadID
			AND AuthorisationStatus in('NP','1A','MP','RM')

			----UPDATE 
			----IBPCPoolSummary_MOD 
			----SET 
			----AuthorisationStatus	='R'
			----,ApprovedBy	=@UserLoginID
			----,DateApproved	=GETDATE()
			
			----WHERE UploadId=@UniqueUploadID
			----AND AuthorisationStatus='NP'
			----SELECT * FROM IBPCPoolDetail

			UPDATE
				ExcelUploadHistory
				SET AuthorisationStatus='R',ApprovedBy=@UserLoginID,DateApproved=GETDATE()
				,EffectiveToTimeKey =@EffectiveFromTimeKey-1        ------Added by kapil on 08/02/2024
				WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
				AND UniqueUploadID=@UniqueUploadID
				AND UploadType='Account Flagging Upload'



	END

--------------------------------------------------------------
END
-------------------------------------Attendance Log----------------------------	
	IF @OperationFlag IN (1,2,3,16,17,18,20,21) AND @AuthMode ='Y'
		BEGIN
					print 'log table'

		          declare @DateCreated1 datetime
				SET	@DateCreated1     =Getdate()

				--declare @ReferenceID1 varchar(max)
				--set @ReferenceID1 = (case when @OperationFlag in (16,20,21) then @SourceAlt_Key else @SourceAlt_Key end)


					IF @OperationFlag IN(16,17,18,20,21) 
						BEGIN 
						       Print 'Authorised'
					
			
								EXEC LogDetailsInsertUpdate_Attendence -- MAINTAIN LOG TABLE
							    @BranchCode=''   ,  ----BranchCode
								@MenuID=@MenuID,
								@ReferenceID=@UniqueUploadID ,-- ReferenceID ,
								@CreatedBy=NULL,
								@ApprovedBy=@UserLoginID, 
								@CreatedCheckedDt=@DateCreated1,
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
								@ReferenceID=@UniqueUploadID ,-- ReferenceID ,
								@CreatedBy=@UserLoginID,
								@ApprovedBy=NULL, 						
								@CreatedCheckedDt=@DateCreated1,
								@Remark=NULL,
								@ScreenEntityAlt_Key=16  ,---ScreenEntityId -- for FXT060 screen
								@Flag=@OperationFlag,
								@AuthMode=@AuthMode
						END

		END
---------------------------------------------------------------------------------------


	--COMMIT TRAN
		---SET @Result=CASE WHEN  @OperationFlag=1 THEN @UniqueUploadID ELSE 1 END
		SET @Result=CASE WHEN  @OperationFlag=1 AND @MenuId=1470 THEN @ExcelUploadId 
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