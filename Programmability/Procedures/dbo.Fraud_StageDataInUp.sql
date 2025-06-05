SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE  [dbo].[Fraud_StageDataInUp]
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

			--Set @Timekey=(select CAST(B.timekey as int)from SysDataMatrix A
			--Inner Join SysDayMatrix B ON A.TimeKey=B.TimeKey
			-- where A.CurrentStatus='C')
  SET @Timekey =(Select TimeKey from SysDataMatrix where CurrentStatus='C') 

  --SET @Timekey =(Select LastMonthDateKey from SysDayMatrix where Timekey=@Timekey) 

  
	--SET @Timekey =(Select Timekey from SysDataMatrix Where MOC_Initialised='Y' AND ISNULL(MOC_Frozen,'N')='N') 
	--DECLARE @MOC_Date Date
	--SET @MOC_Date=(select cast(ExtDate as date) from SysDataMatrix where TimeKey=@Timekey )

	PRINT @TIMEKEY

	SET @EffectiveFromTimeKey=@TimeKey
	SET @EffectiveToTimeKey=49999


	DECLARE @FilePathUpload	VARCHAR(100)
				   SET @FilePathUpload=@UserLoginId+'_'+@filepath
					PRINT '@FilePathUpload'
					PRINT @FilePathUpload


		BEGIN TRY

		--BEGIN TRAN
		
IF (@MenuId=24738)

BEGIN


	IF (@OperationFlag=1)

	BEGIN

		IF NOT (EXISTS (SELECT 1 FROM NPAFraudAccountUpload_stg  where filname=@FilePathUpload))

							BEGIN
									 --Rollback tran
									SET @Result=-8

								RETURN @Result
							END
			
                   Print 'Prashant'

		IF EXISTS(SELECT * FROM NPAFraudAccountUpload_stg WHERE filname=@FilePathUpload)
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
		   ,'Fraud Upload'
		   ,@EffectiveFromTimeKey
		   ,@EffectiveToTimeKey
		   ,@UserLoginID
		   ,GETDATE()


			   PRINT @@ROWCOUNT

		   DECLARE @ExcelUploadId INT
	SET 	@ExcelUploadId=(SELECT MAX(UniqueUploadID) FROM  ExcelUploadHistory)
		
			Insert into UploadStatus (FileNames,UploadedBy,UploadDateTime,UploadType)
		Values(@filepath,@UserLoginID ,GETDATE(),'Fraud Upload')

			  Update  A
						Set A.EffectiveToTimeKey=@Timekey-1
						from Fraud_Details_MOD A
						inner join NPAFraudAccountUpload_stg B
						ON A.RefCustomerACID=B.AccountNumber
						AND A.EffectiveFromTimeKey <=@Timekey
						AND A.EffectiveToTimeKey >=@Timekey
						Where A.EffectiveToTimeKey >=@Timekey
						and A.AuthorisationStatus = 'A'

		SET DATEFORMAT DMY

		
		
		INSERT INTO Fraud_Details_MOD
		(
			 SrNo
			,UploadID
			,RefCustomerACID
			,RFA_ReportingByBank
			,RFA_DateReportingByBank
			,RFA_OtherBankAltKey
			,RFA_OtherBankDate
			,FraudOccuranceDate
			,FraudDeclarationDate
			,FraudNature
			,FraudArea
			,NPA_DateAtFraud
			,AssetClassAtFraudAltKey
			,ProvPref
            ,AuthorisationStatus
            ,EffectiveFromTimeKey
            ,EffectiveToTimeKey
            ,CreatedBy
            ,DateCreated
            ,screenFlag
			,AccountEntityId
			,CustomerEntityId
			,RefCustomerID
		)
		 
		SELECT
			 SrNo
			,@ExcelUploadId
			,AccountNumber
			,D.ParameterAlt_Key
			,DateofRFAreportingbyBank
			,E.ParameterAlt_Key
			,case when DateofreportingRFAbyOtherBank in ('','1900-01-01') then null else DateofreportingRFAbyOtherBank end
			,case when DateofFraudoccurrence in ('','1900-01-01') then null else DateofFraudoccurrence end 
			,DateofFrauddeclarationbyRBL
			,NatureofFraud
			,AreasofOperations
			,(CASE	WHEN B.AccountEntityId is NOT NULL THEN NPA.Npadt
									WHEN BB.AccountEntityId is NOT NULL THEN NPA.Npadt 
									WHEN II.InvEntityId is NOT NULL THEN IK.NPIDT
									ELSE DV.NPIDT END)NPA_DateAtFraud
			,(CASE	WHEN B.AccountEntityId is NOT NULL THEN NPA.Cust_AssetClassAlt_Key
									WHEN BB.AccountEntityId is NOT NULL THEN NPA.Cust_AssetClassAlt_Key 
									WHEN II.InvEntityId is NOT NULL THEN IK.FinalAssetClassAlt_Key
									ELSE DV.FinalAssetClassAlt_Key END)AssetClassAtFraudAltKey
			,F.ParameterAlt_Key
            ,'NP'
            ,@Timekey
            ,49999
            ,@UserLoginID
            ,GETDATE() 
			,'U'	
			 ,(CASE	WHEN B.AccountEntityId is NOT NULL THEN B.AccountEntityId 
									WHEN BB.AccountEntityId is NOT NULL THEN BB.AccountEntityId 
									WHEN II.InvEntityId is NOT NULL THEN II.InvEntityId
									ELSE DV.DerivativeEntityID END)AccountEntityId
			,(CASE WHEN B.CustomerEntityId is NOT NULL THEN B.CustomerEntityId
							 WHEN BB.CustomerEntityId is NOT NULL THEN BB.CustomerEntityId
							 ELSE II.IssuerEntityId END)CustomerEntityId	
			,(CASE	WHEN B.RefCustomerID is NOT NULL THEN B.RefCustomerID
									WHEN BB.RefCustomerID is NOT NULL THEN B.RefCustomerID
									WHEN II.RefIssuerID is NOT NULL THEN II.RefIssuerID
									ELSE DV.CustomerID END) as RefCustomerID
		FROM NPAFraudAccountUpload_stg A
		LEFT JOIN   AdvAcBasicDetail B
	    ON          A.RefCustomerAcid=B.CustomerACID  
	    AND		  A.EffectiveFromTimeKey <= @TimeKey  AND A.EffectiveToTimeKey >= @TimeKey
	    LEFT JOIN   AdvNFAcBasicDetail BB
	    ON          A.RefCustomerAcid=BB.CustomerACID  AND A.EffectiveFromTimeKey <= @TimeKey 
	    AND		  BB.EffectiveFromTimeKey <= @TimeKey  AND BB.EffectiveToTimeKey >= @TimeKey
	    LEFT JOIN   AdvAcBalanceDetail J
	    ON          B.AccountEntityId = J.AccountEntityId  AND J.EffectiveFromTimeKey <= @TimeKey 
	    AND         J.EffectiveToTimeKey >= @TimeKey
	    LEFT JOIN	  ADvFACNFDetail JJ
	     ON          BB.AccountEntityId = JJ.AccountEntityId  AND JJ.EffectiveFromTimeKey <= @TimeKey 
	    AND         JJ.EffectiveToTimeKey >= @TimeKey
	     LEFT JOIN   InvestmentBasicDetail II
	    ON          A.RefCustomerAcid=II.InvID  
	    AND		  II.EffectiveFromTimeKey <= @TimeKey  AND II.EffectiveToTimeKey >= @TimeKey 
	     LEFT JOIN   InvestmentIssuerDetail IJ
	    ON          IJ.IssuerID=II.RefIssuerID  
	    AND		  IJ.EffectiveFromTimeKey <= @TimeKey  AND IJ.EffectiveToTimeKey >= @TimeKey 
	    LEFT JOIN		InvestmentFinancialDetail IK
	    ON			IK.RefInvID=II.InvID 
	    AND		  IK.EffectiveFromTimeKey <= @TimeKey  AND IK.EffectiveToTimeKey >= @TimeKey 
	    LEFT JOIN		curdat.DerivativeDetail DV
	    ON			A.RefCustomerAcid= DV.DerivativeRefNo
	    AND		  DV.EffectiveFromTimeKey <= @TimeKey  AND DV.EffectiveToTimeKey >= @TimeKey
		LEFT JOIN DBO.AdvCustNPADetail NPA on C.CustomerEntityId=NPA.CustomerEntityId
		AND NPA.EffectiveFromTimeKey<=@Timekey And NPA.EffectiveToTimeKey>=@Timekey
		LEFT JOIN 
			(Select ParameterAlt_Key
		,CASE WHEN ParameterName='NO' THEN 'N' else 'Y' END ParameterName
		,'RFA_Reported_By_Bank' as Tablename 
		from DimParameter where DimParameterName='DimYesNo'
		And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)D 
		ON A.RFAReportedbyBank = D.ParameterName
		LEFT JOIN (Select BankRPAlt_Key as ParameterAlt_Key
		,BankName as ParameterName
		,'Name_of_Other_Banks_Reporting_RFA' as Tablename 
		from DimBankRP where 
		 EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		 )E ON A.NameofotherBankreportingRFA = E.ParameterName
		LEFT JOIN  (
		 Select ParameterAlt_Key
		,ParameterName
		,'Provision_Proference' as Tablename 
		from DimParameter where DimParameterName='DimProvisionPreference'
		And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		)F ON A.Provisionpreference = F.ParameterName
					
		where filname=@FilePathUpload

		---------------------------------------------------------ChangeField Logic---------------------
		----select * from AccountLvlMOCDetails_stg
	IF OBJECT_ID('TempDB..#FraudUpload') Is Not Null
	Drop Table #FraudUpload

	Create TAble #FraudUpload
	(
	AccountNumber Varchar(30), FieldName Varchar(50),SrNo Varchar(Max))
	
	Insert Into #FraudUpload(AccountNumber,FieldName)
	 Select AccountNumber, 'RFAreportedbyBank' FieldName from NPAFraudAccountUpload_stg Where isnull(RFAreportedbyBank,'')<>'' 
	UNION ALL
	Select AccountNumber, 'DateofRFAreportingbyBank' FieldName from NPAFraudAccountUpload_stg Where isnull(DateofRFAreportingbyBank,'')<>'' 
	UNION ALL
	Select AccountNumber, 'NameofotherBankreportingRFA ' FieldName from NPAFraudAccountUpload_stg Where isnull(NameofotherBankreportingRFA,'')<>''
	UNION ALL
	Select AccountNumber, 'DateofreportingRFAbyOtherBank' FieldName from NPAFraudAccountUpload_stg Where isnull(DateofreportingRFAbyOtherBank,'')<>'' 
	UNION ALL
	Select AccountNumber, 'DateofFraudoccurrence' FieldName from NPAFraudAccountUpload_stg Where isnull(DateofFraudoccurrence,'')<>'' 
	UNION ALL
	Select AccountNumber, 'DateofFrauddeclarationbyRBL' FieldName from NPAFraudAccountUpload_stg Where isnull(DateofFrauddeclarationbyRBL,'')<>'' 
	UNION ALL
	Select AccountNumber, 'NatureofFraud' FieldName from NPAFraudAccountUpload_stg Where isnull(NatureofFraud,'')<>'' 
	UNION ALL
	Select AccountNumber, 'AreasofOperations' FieldName from NPAFraudAccountUpload_stg Where isnull(AreasofOperations,'')<>'' 
	UNION ALL
	Select AccountNumber, 'Provisionpreference' FieldName from NPAFraudAccountUpload_stg Where isnull(Provisionpreference,'')<>'' 


	--select *
	Update B set B.SrNo=A.ScreenFieldNo
	from MetaScreenFieldDetail A
	Inner Join #FraudUpload B ON A.CtrlName=B.FieldName
	Where A.MenuId=@Menuid And A.IsVisible='Y'
	

	

	
				 IF OBJECT_ID('TEMPDB..#NEWTRANCHE')  IS NOT NULL
					DROP TABLE #NEWTRANCHE

					SELECT * INTO #NEWTRANCHE FROM(
					SELECT 
						 SS.AccountNumber,
						STUFF((SELECT ',' + US.SrNo 
							FROM #FraudUpload US
							WHERE US.AccountNumber = SS.AccountNumber
							FOR XML PATH('')), 1, 1, '') [REPORTIDSLIST]
						FROM NPAFraudAccountUpload_stg SS 
						GROUP BY SS.AccountNumber
						)B
						ORDER BY 1

						--Select * from #NEWTRANCHE

					--SELECT * 
					UPDATE A SET A.FraudAccounts_ChangeFields=B.REPORTIDSLIST
					FROM DBO.Fraud_Details_MOD A
					INNER JOIN #NEWTRANCHE B ON A.RefCustomerACID=B.AccountNumber
					WHERE  A.EFFECTIVEFROMTIMEKEY<=@TimeKey AND A.EFFECTIVETOTIMEKEY>=@TimeKey
					And A.UploadID=@ExcelUploadId


				PRINT @@ROWCOUNT

				
		
		---DELETE FROM STAGING DATA

		 DELETE FROM NPAFraudAccountUpload_stg
		 WHERE filname=@FilePathUpload

		 ----RETURN @ExcelUploadId

END
		   ----DECLARE @UniqueUploadID INT
	--SET 	@UniqueUploadID=(SELECT MAX(UniqueUploadID) FROM  ExcelUploadHistory)
	END


----------------------01042021-------------

IF (@OperationFlag=16)----AUTHORIZE

	BEGIN

		    IF (@UserLoginID =(Select CreatedBy from Fraud_Details_MOD where  CreatedBy=@UserLoginID 
								and  UploadId=@UniqueUploadID
			                                  and AuthorisationStatus in ('NP','MP')
			                                  and  EffectiveToTimeKey=49999 Group By CreatedBy))
	          BEGIN
								SET @Result=-1
								ROLLBACK TRAN
								RETURN @Result
	         END
else
begin
		
		UPDATE 
			Fraud_Details_MOD 
			SET 
			AuthorisationStatus	='1A'
			,FirstLevelApprovedBy	=@UserLoginID
			,FirstLevelDateApproved	=GETDATE()
			
			WHERE UploadId=@UniqueUploadID and EffectiveToTimeKey = 49999 and AuthorisationStatus in ('NP','MP')
			
		   UPDATE 
		   ExcelUploadHistory
		   SET AuthorisationStatus='1A'
		   ,ApprovedByFirstLevel	=@UserLoginID
		   ,DateApprovedFirstLevel=GETDATE()
		   where UniqueUploadID=@UniqueUploadID
		   AND UploadType='Fraud Upload'
	END
	END
--------------------------------------------

	IF (@OperationFlag=20)----AUTHORIZE

	BEGIN

	 IF @UserLoginID= (select UserLoginID from DimUserInfo where  IsChecker2='N' and UserLoginID=@UserLoginID )
			   BEGIN
								SET @Result=-1
								ROLLBACK TRAN
								RETURN @Result
								
				END
          
		  ELSE BEGIN
				IF (@UserLoginID =(Select CreatedBy from Fraud_Details_MOD where AuthorisationStatus IN ('1A') and UploadId=@UniqueUploadID 
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
					IF (@UserLoginID =(Select ApprovedBy from Fraud_Details_MOD where AuthorisationStatus IN ('1A') and UploadId=@UniqueUploadID 
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
			Fraud_Details_MOD 
			SET AuthorisationStatus	='A'
			,ApprovedBy	=@UserLoginID
			,DateApproved	=GETDATE()
			WHERE UploadId=@UniqueUploadID			

		UPDATE  A
		SET A.EffectiveToTimeKey=@Timekey-1
		from Fraud_Details A
		LEFT JOIN   AdvAcBasicDetail B
	    ON          A.RefCustomerAcid=B.CustomerACID  
	    AND		  A.EffectiveFromTimeKey <= @TimeKey  AND A.EffectiveToTimeKey >= @TimeKey
	    LEFT JOIN   AdvNFAcBasicDetail BB
	    ON          A.RefCustomerAcid=BB.CustomerACID  AND A.EffectiveFromTimeKey <= @TimeKey 
	    AND		  BB.EffectiveFromTimeKey <= @TimeKey  AND BB.EffectiveToTimeKey >= @TimeKey
	    LEFT JOIN   AdvAcBalanceDetail J
	    ON          B.AccountEntityId = J.AccountEntityId  AND J.EffectiveFromTimeKey <= @TimeKey 
	    AND         J.EffectiveToTimeKey >= @TimeKey
	    LEFT JOIN	  ADvFACNFDetail JJ
	     ON          BB.AccountEntityId = JJ.AccountEntityId  AND JJ.EffectiveFromTimeKey <= @TimeKey 
	    AND         JJ.EffectiveToTimeKey >= @TimeKey
	     LEFT JOIN   InvestmentBasicDetail II
	    ON          A.RefCustomerAcid=II.InvID  
	    AND		  II.EffectiveFromTimeKey <= @TimeKey  AND II.EffectiveToTimeKey >= @TimeKey 
	     LEFT JOIN   InvestmentIssuerDetail IJ
	    ON          IJ.IssuerID=II.RefIssuerID  
	    AND		  IJ.EffectiveFromTimeKey <= @TimeKey  AND IJ.EffectiveToTimeKey >= @TimeKey 
	    LEFT JOIN		InvestmentFinancialDetail IK
	    ON			IK.RefInvID=II.InvID 
	    AND		  IK.EffectiveFromTimeKey <= @TimeKey  AND IK.EffectiveToTimeKey >= @TimeKey 
	    LEFT JOIN		curdat.DerivativeDetail DV
	    ON			A.RefCustomerAcid= DV.DerivativeRefNo
	    AND		  DV.EffectiveFromTimeKey <= @TimeKey  AND DV.EffectiveToTimeKey >= @TimeKey
		INNER JOIN Fraud_Details_MOD C
		ON B.AccountEntityId=C.AccountEntityID
		AND C.EffectiveFromTimeKey <=@Timekey AND C.EffectiveToTimeKey >=@Timekey
		AND C.AuthorisationStatus='A' AND C.UploadId=@UniqueUploadID
		WHERE A.EffectiveToTimeKey >=@Timekey
		AND A.AuthorisationStatus = 'A'
		AND A.UploadID=@UniqueUploadID





		INSERT INTO Fraud_Details    
										   (   
										   SrNo
											,UploadID
											  ,AccountEntityId
												,CustomerEntityId
												,RefCustomerACID
												,RefCustomerID
												,RFA_ReportingByBank
												,RFA_DateReportingByBank
												,RFA_OtherBankAltKey
												,RFA_OtherBankDate
												,FraudOccuranceDate
												,FraudDeclarationDate
												,FraudNature
												,FraudArea
												,CurrentAssetClassAltKey
												,ProvPref
												,NPA_DateAtFraud
												,AssetClassAtFraudAltKey
												  ,AuthorisationStatus
												  ,EffectiveFromTimeKey
												  ,EffectiveToTimeKey
												  ,CreatedBy
												  ,DateCreated
												  ,ModifiedBy
												  ,DateModified
												  ,ApprovedBy
												  ,DateApproved
												  ,FirstLevelApprovedBy
												  ,FirstLevelDateApproved
												  ,screenFlag
										   )  
										Select  
												SrNo
												,UploadID
											  ,(CASE	WHEN B.AccountEntityId is NOT NULL THEN B.AccountEntityId 
												WHEN BB.AccountEntityId is NOT NULL THEN BB.AccountEntityId 
												WHEN II.InvEntityId is NOT NULL THEN II.InvEntityId
												ELSE DV.DerivativeEntityID END)AccountEntityId
												,(CASE WHEN B.CustomerEntityId is NOT NULL THEN B.CustomerEntityId
												WHEN BB.CustomerEntityId is NOT NULL THEN BB.CustomerEntityId
												ELSE II.IssuerEntityId END)CustomerEntityId										
												,(CASE WHEN B.CustomerACID is NOT NULL THEN B.CustomerACID
												WHEN BB.CustomerACID is NOT NULL THEN BB.CustomerACID
												WHEN II.InvID is NOT NULL THEN II.InvID
												 ELSE DerivativeRefNo END) as RefCustomerACID
												,(CASE	WHEN B.RefCustomerID is NOT NULL THEN B.RefCustomerID
												WHEN BB.RefCustomerID is NOT NULL THEN B.RefCustomerID
												WHEN II.RefIssuerID is NOT NULL THEN II.RefIssuerID
												ELSE DV.CustomerID END) as RefCustomerID
												,RFA_ReportingByBank
												,RFA_DateReportingByBank
												,RFA_OtherBankAltKey
												,case when RFA_OtherBankDate in ('','1900-01-01') then null else RFA_OtherBankDate end
												,case when FraudOccuranceDate in ('','1900-01-01') then null else FraudOccuranceDate end
												,FraudDeclarationDate
												,FraudNature
												,FraudArea
												,CurrentAssetClassAltKey
												,ProvPref
												,NPA_DateAtFraud
												,AssetClassAtFraudAltKey
												,A.AuthorisationStatus
												,A.EffectiveFromTimeKey
												,A.EffectiveToTimeKey
												,A.CreatedBy
												,A.DateCreated
												,A.ModifiedBy
												,A.DateModified
												,A.ApprovedBy
												,A.DateApproved
												,FirstLevelApprovedBy
												,FirstLevelDateApproved
												,screenFlag
              FROM Fraud_Details_MOD A
			 LEFT JOIN   AdvAcBasicDetail B
	    ON          A.RefCustomerAcid=B.CustomerACID  
	    AND		  A.EffectiveFromTimeKey <= @TimeKey  AND A.EffectiveToTimeKey >= @TimeKey
	    LEFT JOIN   AdvNFAcBasicDetail BB
	    ON          A.RefCustomerAcid=BB.CustomerACID  AND A.EffectiveFromTimeKey <= @TimeKey 
	    AND		  BB.EffectiveFromTimeKey <= @TimeKey  AND BB.EffectiveToTimeKey >= @TimeKey
	    LEFT JOIN   AdvAcBalanceDetail J
	    ON          B.AccountEntityId = J.AccountEntityId  AND J.EffectiveFromTimeKey <= @TimeKey 
	    AND         J.EffectiveToTimeKey >= @TimeKey
	    LEFT JOIN	  ADvFACNFDetail JJ
	     ON          BB.AccountEntityId = JJ.AccountEntityId  AND JJ.EffectiveFromTimeKey <= @TimeKey 
	    AND         JJ.EffectiveToTimeKey >= @TimeKey
	     LEFT JOIN   InvestmentBasicDetail II
	    ON          A.RefCustomerAcid=II.InvID  
	    AND		  II.EffectiveFromTimeKey <= @TimeKey  AND II.EffectiveToTimeKey >= @TimeKey 
	     LEFT JOIN   InvestmentIssuerDetail IJ
	    ON          IJ.IssuerID=II.RefIssuerID  
	    AND		  IJ.EffectiveFromTimeKey <= @TimeKey  AND IJ.EffectiveToTimeKey >= @TimeKey 
	    LEFT JOIN		InvestmentFinancialDetail IK
	    ON			IK.RefInvID=II.InvID 
	    AND		  IK.EffectiveFromTimeKey <= @TimeKey  AND IK.EffectiveToTimeKey >= @TimeKey 
	    LEFT JOIN		curdat.DerivativeDetail DV
	    ON			A.RefCustomerAcid= DV.DerivativeRefNo
	    AND		  DV.EffectiveFromTimeKey <= @TimeKey  AND DV.EffectiveToTimeKey >= @TimeKey
			WHERE        A.UploadId=@UniqueUploadID AND A.EffectiveFromTimeKey <=@Timekey AND A.EffectiveToTimeKey>=@Timekey
            AND        A.AuthorisationStatus = 'A'

			PRINT 'BBBB'
										UPDATE Fraud_Details SET
												 AccountEntityId			    = (case when B.AccountEntityId            is null then a.AccountEntityId             else B.AccountEntityId              end)
												,CustomerEntityId		= (case when B.CustomerEntityId	   is null then a.CustomerEntityId	  else B.CustomerEntityId	  end)
												,RefCustomerACID			= (case when B.RefCustomerACID		   is null then a.RefCustomerACID		  else B.RefCustomerACID		  end)
												,RefCustomerID					= (case when B.RefCustomerID				   is null then a.RefCustomerID				  else B.RefCustomerID				  end)
												,RFA_ReportingByBank	= (case when B.RFA_ReportingByBank is null then a.RFA_ReportingByBank else B.RFA_ReportingByBank end)
												,RFA_DateReportingByBank		= (case when B.RFA_DateReportingByBank	   is null then a.RFA_DateReportingByBank	  else B.RFA_DateReportingByBank	  end)
												,RFA_OtherBankAltKey			= (case when B.RFA_OtherBankAltKey		   is null then a.RFA_OtherBankAltKey		  else B.RFA_OtherBankAltKey		  end)
												,RFA_OtherBankDate				= (case when B.RFA_OtherBankDate			   is null then a.RFA_OtherBankDate			  else B.RFA_OtherBankDate			  end)
												,FraudOccuranceDate		    	= (case when B.FraudOccuranceDate			   is null then a.FraudOccuranceDate			  else B.FraudOccuranceDate			  end)
												,FraudDeclarationDate			= (case when B.FraudDeclarationDate				   is null then a.FraudDeclarationDate		else B.FraudDeclarationDate				  end)
												,FraudNature					= (case when B.FraudNature			   is null then a.FraudNature			 else B.FraudNature			  	  end)
												,FraudArea	            = (case when B.FraudArea			   is null then a.FraudArea			  else B.FraudArea			  end)
												,CurrentAssetClassAltKey		= (case when B.CurrentAssetClassAltKey	is null then a.CurrentAssetClassAltKey			  else B.CurrentAssetClassAltKey			  end)
												,ProvPref			= (case when B.ProvPref		   is null then a.ProvPref		  else B.ProvPref		  end)
												,NPA_DateAtFraud			= (case when B.NPA_DateAtFraud		   is null then a.NPA_DateAtFraud		  else B.NPA_DateAtFraud		  end)
												,AssetClassAtFraudAltKey			= (case when B.AssetClassAtFraudAltKey	is null then a.AssetClassAtFraudAltKey	else B.AssetClassAtFraudAltKey		  end)
												,AuthorisationStatus			= (case when B.AuthorisationStatus		   is null then a.AuthorisationStatus		  else B.AuthorisationStatus		  end)
												,ModifiedBy						= (case when B.ModifiedBy				   is null then a.ModifiedBy				  else B.ModifiedBy				  	  end)
												,DateModified					= (case when B.DateModified				   is null then a.DateModified				  else B.DateModified				  end)
												,ApprovedBy						= (case when B.ApprovedBy 				   is null then a.ApprovedBy				  else B.ApprovedBy 				  end)
												,DateApproved					= (case when B.DateApproved 				   is null then a.DateApproved				  else B.DateApproved 				  end)											
												,screenFlag						= 'U'																								
                                               
											From Fraud_Details a
											 inner join Fraud_Details_Mod b 
											 on         a.RefCustomerAcid=b.RefCustomerAcid
											 And        a.EffectiveFromTimeKey<=@TimeKey AND a.EffectiveToTimeKey>=@TimeKey 
											 WHERE      b.EffectiveFromTimeKey<=@TimeKey AND b.EffectiveToTimeKey>=@TimeKey 
											 AND        b.RefCustomerAcid=b.RefCustomerAcid
											


				UPDATE
				ExcelUploadHistory
				SET AuthorisationStatus='A',ApprovedBy=@UserLoginID,DateApproved=GETDATE()
				WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
				AND UniqueUploadID=@UniqueUploadID
				AND UploadType='Fraud Upload'	

					END
			

END
END
end


	IF (@OperationFlag=17)----REJECT

	BEGIN

	 IF (@UserLoginID =(Select CreatedBy from Fraud_Details_MOD where  CreatedBy=@UserLoginID 
								and  UploadId=@UniqueUploadID
			                                  and AuthorisationStatus in ('NP','MP')
			                                  and  EffectiveToTimeKey=49999 Group By CreatedBy))
	          BEGIN
								SET @Result=-1
								ROLLBACK TRAN
								RETURN @Result
	         END
else
begin
		
		UPDATE 
			Fraud_Details_MOD 
			SET 
			AuthorisationStatus	='R'
			,ApprovedBy	=@UserLoginID
			,DateApproved	=GETDATE()
			,EffectiveToTimeKey=@Timekey-1
			WHERE UploadId=@UniqueUploadID
			AND AuthorisationStatus='NP'

		
			UPDATE
				ExcelUploadHistory
				SET AuthorisationStatus='R',ApprovedBy=@UserLoginID,DateApproved=GETDATE()
				,EffectiveToTimeKey=@Timekey-1
				WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
				AND UniqueUploadID=@UniqueUploadID
				AND UploadType='Fraud Upload'


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
				IF (@UserLoginID =(Select CreatedBy from Fraud_Details_MOD where AuthorisationStatus IN ('1A') and UploadId=@UniqueUploadID 
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
					IF (@UserLoginID =(Select ApprovedBy from Fraud_Details_MOD where AuthorisationStatus IN ('1A') and UploadId=@UniqueUploadID 
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
			Fraud_Details_MOD 
			SET 
			AuthorisationStatus	='R'
			,ApprovedBy	=@UserLoginID
			,DateApproved	=GETDATE()
			,EffectiveToTimeKey=@Timekey-1
			WHERE UploadId=@UniqueUploadID
			AND AuthorisationStatus in('NP','1A')

			

			UPDATE
				ExcelUploadHistory
				SET AuthorisationStatus='R',ApprovedBy=@UserLoginID,DateApproved=GETDATE()
				,EffectiveToTimeKey=@Timekey-1
				WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
				AND UniqueUploadID=@UniqueUploadID
				AND UploadType='Fraud Upload'

END
END
END


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
		SET @Result=CASE WHEN  @OperationFlag=1 AND @MenuId=24738 THEN @ExcelUploadId 
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