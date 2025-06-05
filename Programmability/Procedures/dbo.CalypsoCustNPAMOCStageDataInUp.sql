SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO





/*
declare @p11 int
set @p11=-1
exec [dbo].[CustNPAMOCStageDataInUp] @Authlevel=N'2',@TimeKey=25999,@UserLoginID=N'test_two',@OperationFlag=N'1',@MenuId=N'27766 ',@AuthMode=N'Y',@filepath=N'CustlevelNPAMOCUpload.xlsx',@EffectiveFromTimeKey=25999,@EffectiveToTimeKey=49999,@UniqueUploadID=NU




LL,@Result=@p11 output
select @p11
go

*/
CREATE PROCEDURE  [dbo].[CalypsoCustNPAMOCStageDataInUp]
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
--	@MenuId INT=27766 ,
--	@AuthMode	CHAR(1)='Y',
--	@filepath VARCHAR(MAX)='',
--	@EffectiveFromTimeKey INT=24928,
--	@EffectiveToTimeKey	INT=49999,
--    @Result		INT=0 ,
--	@UniqueUploadID INT=41

BEGIN
SET DATEFORMAT DMY
	SET NOCOUNT ON;

	-------------VVVVVVVVVVVVV--------Comented on by kapil 08/02/2024

	--	IF EXISTS(SELECT 1 FROM ACLProcessInProgressStatus WHERE Status='RUNNING' AND StatusFlag='N' AND TimeKey in (select max(Timekey) from ACLProcessInProgressStatus))
	
	--BEGIN
	--	PRINT 'ACL Process is In Progress'
	----IF EXISTS(SELECT 1 FROM ACLProcessInProgressStatus WHERE Status='COMPLETED' AND StatusFlag='Y' AND TimeKey in (select max(Timekey) from ACLProcessInProgressStatus) )
	----BEGIN
	----	PRINT 'ACL Process Completed'
	--END

	--ELSE 

	--BEGIN
	---^^^^^^^^--  --Comented on by kapil 08/02/2024

   
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

			Declare @MocStatus Varchar(100)=''

Select @MocStatus=MocStatus 
 from CalypsoMOCMonitorStatus
Where EntityKey in(Select Max(EntityKey) From CalypsoMOCMonitorStatus)

IF(@MocStatus='InProgress')
  Begin
     SET @Result=5
	RETURN @Result
  End


	DECLARE @FilePathUpload	VARCHAR(100)
				   SET @FilePathUpload=@UserLoginId+'_'+@filepath
					PRINT '@FilePathUpload'
					PRINT @FilePathUpload


		BEGIN TRY

		--BEGIN TRAN
		
IF (@MenuId=24747)
BEGIN


	IF (@OperationFlag=1)

	BEGIN

		IF NOT (EXISTS (SELECT * FROM CalypsoCustlevelNPAMOCDetails_stg  where filname=@FilePathUpload))

							BEGIN
									 --Rollback tran
									SET @Result=-8

								RETURN @Result
							END
			
                   Print 'Sachin'

		IF EXISTS(SELECT 1 FROM CalypsoCustlevelNPAMOCDetails_stg WHERE filname=@FilePathUpload)
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
		   ,'Calypso Customer MOC Upload'
		   ,@EffectiveFromTimeKey
		   ,@EffectiveToTimeKey
		   ,@UserLoginID
		   ,GETDATE()


			   PRINT @@ROWCOUNT

			      PRINT @@ROWCOUNT

		   DECLARE @ExcelUploadId INT
	SET 	@ExcelUploadId=(SELECT MAX(UniqueUploadID) FROM  ExcelUploadHistory)
		
			Insert into UploadStatus (FileNames,UploadedBy,UploadDateTime,UploadType)
		Values(@filepath,@UserLoginID ,GETDATE(),'Calypso Customer MOC Upload')

		Print 'Sachin111'

		      PRINT '@ExcelUploadId'
			  PRINT @ExcelUploadId


						--  Update  A
						--Set A.EffectiveToTimeKey=@Timekey-1
						--from CalypsoCustomerLevelMOC_MOD A
						--inner join CalypsoCustlevelNPAMOCDetails_stg B
						--ON A.UCICID=B.UCICID
						--AND A.EffectiveFromTimeKey <=@Timekey
						--AND A.EffectiveToTimeKey >=@Timekey
						--Where A.EffectiveToTimeKey >=@Timekey
						--and A.AuthorisationStatus = 'A'
						
			  
					SET dateformat DMY
					INSERT INTO CalypsoCustomerLevelMOC_MOD
		(
			 SrNo
			,UploadID
			--,SummaryID
			--,SlNo
			 ,UCIFID
			,AssetClass
			,AssetClassAlt_Key
			,NPADate
			--,SecurityValue
			,AdditionalProvision
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
			,CustomerID
			,CustomerName
		)
		 
		SELECT
			 SlNo
			,@ExcelUploadId
			--,SummaryID
			--,SlNo
			,A.UCICID
			,A.AssetClass
			,B.AssetClassAlt_Key
			,Case When NPIDate<>'' AND ISDATE(NPIDate)=1 Then   Convert(date,NPIDate) Else NULL END as NPIDate
			--,ISNULL(case when isnull(SecurityValue,'0')<>'0' then CAST(ISNULL(CAST(SecurityValue AS INT),0) AS DECIMAL(30,2))   end,0) SecurityValue
			--,Case When SecurityValue<>'' THEN CAST(ISNULL(CAST(SecurityValue AS DECIMAL(16,2)),0) AS DECIMAL(16,2)) ELSE NULL END SecurityValue
			,Case When AdditionalProvision<>'' THEN CAST(ISNULL(CAST(AdditionalProvision AS DECIMAL(16,2)),0) AS DECIMAL(16,2)) ELSE NULL END AdditionalProvision
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
			,H.IssuerEntityId
			,H.IssuerID
			,H.IssuerName			
		FROM CalypsoCustlevelNPAMOCDetails_stg A
		INNER join InvestmentIssuerDetail H
		ON         A.UCICID=H.UcifId				
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
				ON A.MOCType =C.ParameterName
		Left Join ( Select MOCTypeAlt_Key, MOCTypeName,
			       'MOCSource' as TableName
			 from dimmoctype
			 where EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey) E
			 ON A.MOCSource=E.MOCTypeName
		where filname=@FilePathUpload

		UNION

		SELECT
			 SlNo
			,@ExcelUploadId
			--,SummaryID
			--,SlNo
			,A.UCICID
			,A.AssetClass
			,B.AssetClassAlt_Key
			,Case When NPIDate<>'' AND ISDATE(NPIDate)=1 Then   Convert(date,NPIDate) Else NULL END as NPIDate
			--,ISNULL(case when isnull(SecurityValue,'0')<>'0' then CAST(ISNULL(CAST(SecurityValue AS INT),0) AS DECIMAL(30,2))   end,0) SecurityValue
			--,Case When SecurityValue<>'' THEN CAST(ISNULL(CAST(SecurityValue AS DECIMAL(16,2)),0) AS DECIMAL(16,2)) ELSE NULL END SecurityValue
			,Case When AdditionalProvision<>'' THEN CAST(ISNULL(CAST(AdditionalProvision AS DECIMAL(16,2)),0) AS DECIMAL(16,2)) ELSE NULL END AdditionalProvision
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
			,0
			,CustomerID
			,CustomerName
			--select * from pro.AccountCal_Hist

			--select * from MetaScreenFieldDetail   where menuid=27766 
			--select * from MetaScreenFieldDetail   where menuid=126
		FROM CalypsoCustlevelNPAMOCDetails_stg A		
		INNER join curdat.DerivativeDetail X
		ON         A.UCICID=X.UCIC_ID
		and     X.EffectiveFromTimeKey<=@TimeKey AND X.EffectiveToTimeKey>=@TimeKey
		left join (select ParameterAlt_Key,ParameterName from DimParameter
				   where dimParameterName='DimMOCReason'
				   And	 EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey )f
		ON		  f.ParameterName=RTRIM(LTRIM(a.MOCReason))      
		Left Join DimAssetClass B ON A.AssetClass=B.AssetClassName 
		Left Join (Select	ParameterAlt_Key, ParameterName
					,'MOCType' as Tablename 
			from DimParameter where DimParameterName='MOCType'
							And	 EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey) C
				ON A.MOCType= C.ParameterName
		Left Join ( Select MOCTypeAlt_Key, MOCTypeName,
			       'MOCSource' as TableName
			 from dimmoctype
			 where EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey) E
			 
			 ON A.MOCSource=E.MOCTypeName
		where filname=@FilePathUpload


		--Update A
		--Set A.CustomerEntityID=B.CustomerEntityID
		--from CalypsoCustomerLevelMOC_MOD A
		--	INNER JOIN CustomerBasicDetail B ON A.UCICID =B.UCICID
		--	Where UploadID=@ExcelUploadId


	
	
	IF OBJECT_ID('TempDB..#CustMocUpload') Is Not Null
	Drop Table #CustMocUpload

	Create TAble #CustMocUpload
	(
	UCICID Varchar(30), FieldName Varchar(50),SrNo varchar(max))

	Insert Into #CustMocUpload(UCICID,FieldName)
	Select UCICID, 'AssetClass' FieldName from CalypsoCustlevelNPAMOCDetails_stg Where isnull(AssetClass,'')<>'' 
	UNION ALL
	Select UCICID, 'NPIDate' FieldName from CalypsoCustlevelNPAMOCDetails_stg Where isnull(NPIDate,'')<>'' 
	UNION ALL
	Select UCICID, 'AdditionalProvision' FieldName from CalypsoCustlevelNPAMOCDetails_stg Where isnull(AdditionalProvision,'')<>'' --AdditionalProvision Is not NULL

	--select * 
	Update B set B.SrNo=A.ScreenFieldNo
	from MetaScreenFieldDetail A
	Inner Join #CustMocUpload B ON A.CtrlName=B.FieldName
	Where A.MenuId=27766  And A.IsVisible='Y'

----	-------------------
----	select * from #CustMocUpload
----	select CtrlName,* from MetaScreenFieldDetail A Where A.MenuId=27766  And A.IsVisible='Y'
----	update MetaScreenFieldDetail 
----	set CtrlName='AdditionalProvision'
----	 Where MenuId=27766  And IsVisible='Y' and entityKey=1406
----	 Asset Class
----NPA Date
----Security Value
----Additional Provision %

------select * into MetaScreenFieldDetail_21062021  from MetaScreenFieldDetail
----select * from MetaScreenFieldDetail_21062021 where menuid=27766 
----select * from MetaScreenFieldDetail where menuid=27766 
	---------------------


	
				 IF OBJECT_ID('TEMPDB..#NEWTRANCHE')  IS NOT NULL
					DROP TABLE #NEWTRANCHE
					
					SELECT * INTO #NEWTRANCHE FROM(
					SELECT 
						 SS.UCICID,
						STUFF((SELECT ',' + US.SrNo 
							FROM #CustMocUpload US
							WHERE US.UCICID = SS.UCICID
							FOR XML PATH('')), 1, 1, '') [REPORTIDSLIST]
						FROM CalypsoCustlevelNPAMOCDetails_stg SS 
						GROUP BY SS.UCICID
						)B
						ORDER BY 1

						--Select * from #NEWTRANCHE

					--SELECT * 
					UPDATE A SET A.ChangeField=B.REPORTIDSLIST
					FROM DBO.CalypsoCustomerLevelMOC_MOD A
					INNER JOIN #NEWTRANCHE B ON A.UCIFid=B.UCICID
					WHERE  A.EFFECTIVEFROMTIMEKEY<=@TimeKey AND A.EFFECTIVETOTIMEKEY>=@TimeKey
					And A.UploadID=@ExcelUploadId
		
		PRINT @@ROWCOUNT
		
		-----DELETE FROM STAGING DATA
		 DELETE FROM CalypsoCustlevelNPAMOCDetails_stg
		 WHERE filname=@FilePathUpload

		 ----RETURN @ExcelUploadId

END
		   ----DECLARE @UniqueUploadID INT
	--SET 	@UniqueUploadID=(SELECT MAX(UniqueUploadID) FROM  ExcelUploadHistory)
	END


----------------------01042021-------------

IF (@OperationFlag=16)----AUTHORIZE

	BEGIN
		 
		      

		
				IF (@UserLoginID =(Select distinct CreatedBy from CalypsoCustomerLevelMOC_MOD 
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
			CalypsoCustomerLevelMOC_MOD 
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
		   AND UploadType='Calypso Customer MOC Upload'
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
			--	IF (@UserLoginID =(Select CreatedBy from CalypsoCustomerLevelMOC_MOD where AuthorisationStatus IN ('1A') and UploadId=@UniqueUploadID 
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
			--		IF (@UserLoginID =(Select ApprovedBy from CalypsoCustomerLevelMOC_MOD where AuthorisationStatus IN ('1A') and UploadId=@UniqueUploadID 
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

			IF (@UserLoginID =(Select distinct CreatedBy from CalypsoCustomerLevelMOC_MOD 
				where AuthorisationStatus IN ('NP','MP','1A') and UploadId=@UniqueUploadID
				and EffectiveToTimeKey >= 49999
				                      --AND CreatedBy in (select createdby from DimUserInfo where  IsChecker='N')  
									    Group By CreatedBy))
				BEGIN
								SET @Result=-1
								rollback tran
								RETURN @Result
								
				END	  
				
		
		UPDATE 
			CalypsoCustomerLevelMOC_MOD 
			SET 
			AuthorisationStatus	='A'
			,ApprovedBy	=@UserLoginID
			,DateApproved	=GETDATE()
			
			WHERE UploadId=@UniqueUploadID
							
							
							IF EXISTS (select 1 
							from CalypsoInvMOC_ChangeDetails A
						INNER JOIN InvestmentBasicDetail B
							ON A.CustomerEntityID=B.IssuerEntityID
								AND A.EffectiveFromTimeKey <=@Timekey AND A.EffectiveToTimeKey >=@Timekey
								AND B.EffectiveFromTimeKey <=@Timekey AND B.EffectiveToTimeKey >=@Timekey
						INNER JOIN CalypsoCustomerLevelMOC_MOD C
							ON B.IssuerEntityid=C.CustomerEntityid
								AND C.EffectiveFromTimeKey <=@Timekey AND C.EffectiveToTimeKey >=@Timekey
								AND ISNULL(C.AuthorisationStatus,'A')='A' AND UploadId=@UniqueUploadID
						WHERE A.EffectiveToTimeKey >=@Timekey
						AND ISNULL(A.AuthorisationStatus,'A') = 'A'
						AND A.MOCType_Flag='CUST'
						AND UploadId=@UniqueUploadID)

						BEGIN
									
						UPDATE  A
						SET A.EffectiveToTimeKey=@Timekey-1
						from CalypsoInvMOC_ChangeDetails A
						INNER JOIN InvestmentBasicDetail B
							ON A.CustomerEntityID=B.IssuerEntityID
								AND A.EffectiveFromTimeKey <=@Timekey AND A.EffectiveToTimeKey >=@Timekey
								AND B.EffectiveFromTimeKey <=@Timekey AND B.EffectiveToTimeKey >=@Timekey
						INNER JOIN CalypsoCustomerLevelMOC_MOD C
							ON B.IssuerEntityid=C.CustomerEntityid
								AND C.EffectiveFromTimeKey <=@Timekey AND C.EffectiveToTimeKey >=@Timekey
								AND ISNULL(C.AuthorisationStatus,'A')='A' AND UploadId=@UniqueUploadID
						WHERE A.EffectiveToTimeKey >=@Timekey
						AND ISNULL(A.AuthorisationStatus,'A') = 'A'
						AND A.MOCType_Flag='CUST'
						AND UploadId=@UniqueUploadID

					

						END



						ELSE

						BEGIN

						UPDATE  A
						SET A.EffectiveToTimeKey=@Timekey-1
						from CalypsoDervMOC_ChangeDetails A
						INNER JOIN curdat.DerivativeDetail B
							ON A.UCICID=B.UCIC_ID
								AND A.EffectiveFromTimeKey <=@Timekey AND A.EffectiveToTimeKey >=@Timekey
								AND B.EffectiveFromTimeKey <=@Timekey AND B.EffectiveToTimeKey >=@Timekey
						INNER JOIN CalypsoCustomerLevelMOC_MOD C
							ON B.UCIC_ID=C.UCIFID
								AND C.EffectiveFromTimeKey <=@Timekey AND C.EffectiveToTimeKey >=@Timekey
								AND ISNULL(C.AuthorisationStatus,'A')='A' AND UploadId=@UniqueUploadID
						WHERE A.EffectiveToTimeKey >=@Timekey
						AND ISNULL(A.AuthorisationStatus,'A') = 'A'
						AND A.MOCType_Flag='CUST'
						AND UploadId=@UniqueUploadID

					
								
						END

						--UPDATE  A
						--SET A.CustomerEntityID=B.IssuerEntityId
						--from CalypsoCustomerLevelMOC_MOD A
						--INNER JOIN InvestmenTIssuerDetail B
						--	ON A.UCIFID=B.UCIfID
						--		AND A.EffectiveFromTimeKey <=@Timekey AND A.EffectiveToTimeKey >=@Timekey
						--		AND B.EffectiveFromTimeKey <=@Timekey AND B.EffectiveToTimeKey >=@Timekey
      --                        WHERE  A.MOCType_Flag='CUST'
						--AND UploadId=@UniqueUploadID

			

										INSERT INTO CalypsoInvMOC_ChangeDetails
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
										,MOCProcessed
										,UCICID
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
										,'N'
										,A.UcifID
								FROM CalypsoCustomerLevelMOC_MOD A
								INNER JOIN InvestmentIssuerDetail B ON A.UcifID = B.UCIFID AND a.CUSTOMERID = B.ISSUERID
								and B.EffectiveFromTimeKey <= @Timekey and B.EffectiveToTimeKey >= @Timekey
								WHERE  UploadId=@UniqueUploadID 
								AND A.EffectiveFromTimeKey<=@Timekey
								AND A.EffectiveToTimeKey>=@Timekey
								AND A.AuthorisationStatus = 'A'

									INSERT INTO CalypsoDervMOC_ChangeDetails
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
										,MOCProcessed
										,UCICID
										
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
										,'N'
										,UCIfID
								FROM CalypsoCustomerLevelMOC_MOD A
								INNER JOIN curdat.DerivativeDetail B 
								ON A.UcifID = B.UCIC_ID and B.CustomerID = A.CustomerID
								and B.EffectiveFromTimeKey <= @Timekey and B.EffectiveToTimeKey >= @Timekey
								WHERE  UploadId=@UniqueUploadID 
								AND A.EffectiveFromTimeKey<=@Timekey
								AND A.EffectiveToTimeKey>=@Timekey
								AND A.AuthorisationStatus = 'A'


/*--------------------Adding Flag To AdvAcOtherDetail------------Sudesh 03-06-2021--------*/ 

--IF OBJECT_ID('TempDB..#IBPCNew') Is Not NUll
--Drop Table #IBPCNew

--Select A.RefUCICID,A.SplFlag 
--into #IBPCNew                             --DBO.AdvAcOtherDetail
--FROM dbo.advcustotherdetail A               
--     INNER JOIN CalypsoCustomerLevelMOC_MOD B 
--	 ON A.RefUCICID=B.UCICID
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
 -- INNER JOIN IBPCPoolDetail_MOD B ON A.RefUCICID=B.UCICID
	--		WHERE  B.UploadId=@UniqueUploadID and B.EffectiveToTimeKey>=@Timekey
	--		AND A.EffectiveToTimeKey=49999
	--		AND Not Exists (Select 1 from #IBPCNew N Where N.RefUCICID=A.RefUCICID)




-------------------------------------------

			--UPDATE A
			--SET 
			--A.POSinRs=ROUND(B.POSinRs,2)
			--,a.ModifyBy=@UserLoginID
			--,a.DateModified=GETDATE()
			--FROM CustomerLevelMOC A
			--INNER JOIN CalypsoCustomerLevelMOC_MOD  B 
			--ON (A.EffectiveFromTimeKey<=@Timekey AND A.EffectiveToTimeKey>=@Timekey)
			--AND  (B.EffectiveFromTimeKey<=@Timekey AND B.EffectiveToTimeKey>=@Timekey)	
			--AND A.UCICID=B.UCICID

			--	WHERE B.AuthorisationStatus='A'
			--	AND B.UploadId=@UniqueUploadID

				UPDATE
				ExcelUploadHistory
				SET AuthorisationStatus='A',ApprovedBy=@UserLoginID,DateApproved=GETDATE()
				WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
				AND UniqueUploadID=@UniqueUploadID
				AND UploadType='Calypso Customer MOC Upload'
END
--				END
--END

--	END


	IF (@OperationFlag=17)----REJECT

	BEGIN
		
	          IF (@UserLoginID =(Select distinct CreatedBy from CalypsoCustomerLevelMOC_MOD where  UploadId=@UniqueUploadID Group By CreatedBy))
	          BEGIN
								SET @Result=-1

								RETURN @Result
	         END
			 ELSE BEGIN
		UPDATE 
			CalypsoCustomerLevelMOC_MOD 
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
				AND UploadType='Calypso Customer MOC Upload'
				END


	END

IF (@OperationFlag=21)----REJECT

	BEGIN

	    IF @UserLoginID= (select UserLoginID from DimUserInfo where  IsChecker2='N' and UserLoginID=@UserLoginID and EffectiveToTimeKey=49999)
			   BEGIN
								SET @Result=-1
								ROLLBACK TRAN
								RETURN @Result
								
				END
          
			ELSE BEGIN
				IF (@UserLoginID =(Select distinct CreatedBy from CalypsoCustomerLevelMOC_MOD where AuthorisationStatus IN ('1A') and UploadId=@UniqueUploadID 
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
					IF (@UserLoginID =(Select distinct  ApprovedBy from CalypsoCustomerLevelMOC_MOD where AuthorisationStatus IN ('1A') and UploadId=@UniqueUploadID 
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
			CalypsoCustomerLevelMOC_MOD 
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
				AND UploadType='Calypso Customer MOC Upload'
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
	END


END
END

	--COMMIT TRAN
		---SET @Result=CASE WHEN  @OperationFlag=1 THEN @UniqueUploadID ELSE 1 END
		SET @Result=CASE WHEN  @OperationFlag=1 AND @MenuId=24747  THEN @ExcelUploadId 
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
--END  --Comented on by kapil 08/02/2024



GO