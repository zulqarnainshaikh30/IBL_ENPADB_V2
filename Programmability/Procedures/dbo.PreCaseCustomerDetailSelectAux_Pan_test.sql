SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create PROC [dbo].[PreCaseCustomerDetailSelectAux_Pan_test]
--DECLARE
	@CustomerID			varchar(30)='170007152', 
	@CustomerName		varchar(80)='',
	@BranchCode			varchar(10)='',
	@BranchName			varchar(50)='',
	@CustomerAcID		varchar(30)='',
	@DefendentName		varchar(80)='',
	@CaseNo				varchar(30)='',
	@UCICID				varchar(30)='',
	@SourceSystem		varchar(30)='',
	----
	@TimeKey			int=25703,
	@UserLoginID		varchar(10)='tf572',
	@Mode				TINYINT=0 ,
	@CustType			VARCHAR(20)='BORROWER',
	@Pan				Varchar(10)='',
	@Result				SMALLINT=0 --OUTPUT

AS

DECLARE @LocatationCode VARCHAR(10)='', @Location char(2)='HO', @CustomerEntityID INT=0

IF OBJECT_ID('TEMPDB..#CustomerEntityId')IS NOT NULL
	DROP TABLE #CustomerEntityId

	 CREATE TABLE #CustomerEntityId	
	 (
		CustomerEntityId	INT
		,ID					TINYINT DEFAULT 0
	 )

	IF ISNULL(@CustomerID,'')<>'' 
		BEGIN
				--SELECT 'TRI'
				INSERT  INTO #CustomerEntityId (CustomerEntityId)

				SELECT CustomerEntityID FROM curdat.CustomerBasicDetail 
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
				AND ISNULL(AuthorisationStatus,'A')='A' 
				AND CustomerID=@CustomerID
				UNION
				SELECT CustomerEntityID FROM CustomerBasicDetail_MOD 
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
				AND AuthorisationStatus IN ('NP','MP','DP','RM')
				AND CustomerID=@CustomerID
				
				
				IF NOT EXISTS (SELECT 1 FROM #CustomerEntityId WHERE 1=1)
					BEGIN
							SET @Result=-1      /* If customer Id does not exists*/
							--RETURN @Result
					END
		END

	IF ISNULL(@CustomerName,'')<>''
		BEGIN
				INSERT  INTO #CustomerEntityId (CustomerEntityId)
				SELECT CustomerEntityId FROM curdat.CustomerBasicDetail
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
				AND ISNULL(AuthorisationStatus,'A')='A'	
				AND CustomerName LIKE '%'+@CustomerName+'%' 

				--IF (SELECT COUNT(CustomerEntityId) FROM #CustomerEntityId)>100
				--	BEGIN
				--			SET @Result=-3  /* If customer DATA IS MORE THAN 100*/
				--			RETURN @Result
				--	END
		
		END
		
	DECLARE
	@CntCust INT=(SELECT COUNT(*)FROM #CustomerEntityId )
		
	IF OBJECT_ID('Tempdb..#CustAcData') IS NOT NULL
			DROP TABLE #CustAcData

		CREATE TABLE #CustAcData
			(
				 CustomerEntityID	INT
				,AuthorisationStatus VARCHAR(20)
			)		

	IF ISNULL(@CustomerAcID,'')<>''
			BEGIN

					INSERT INTO #CustAcData

					SELECT CustomerEntityID, AuthorisationStatus FROM curdat.AdvAcBasicDetail	ABD	
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
					AND ABD.CustomerEntityId=CASE WHEN @CustomerEntityID>0 THEN @CustomerEntityID ELSE ABD.CustomerEntityId END
					AND CustomerAcID=@CustomerAcID AND ISNULL(AuthorisationStatus,'A')='A'		
					GROUP BY CustomerEntityID,AuthorisationStatus

					UNION 

					SELECT A.CustomerEntityID,A.AuthorisationStatus FROM AdvAcBasicDetail_Mod A  
					INNER JOIN(SELECT MAX(Ac_Key)Ac_Key FROM AdvAcBasicDetail_Mod A
					           WHERE (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
							        AND A.CustomerACID=@CustomerAcID
									AND AuthorisationStatus IN ('NP','MP','DP','RM')
									GROUP BY A.CustomerACID 
								)P  
							ON P.Ac_Key=A.Ac_Key 
							AND (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
							AND A.CustomerEntityId=CASE WHEN @CustomerEntityID>0 THEN @CustomerEntityID ELSE A.CustomerEntityId END

					IF NOT EXISTS (SELECT 1 FROM #CustAcData WHERE 1=1)
						BEGIN
								SET @Result=-2 /* aCCOUNT ID DOES NOT EXISTS*/
								--RETURN @Result
						
						END			

			END

			
	IF OBJECT_ID('Tempdb..#CustDefData') IS NOT NULL
				DROP TABLE #CustDefData

			CREATE TABLE #CustDefData
				(
					CustomerEntityID	INT
					,AuthorisationStatus VARCHAR(20)
				)

	IF ISNULL(@DefendentName,'')<>''
			BEGIN
					INSERT INTO #CustDefData

					SELECT AAR.CustomerEntityID, AAR.AuthorisationStatus FROM curdat.AdvAcRelations AAR
						INNER JOIN AdvCustRelationship ACR
							ON  (AAR.EffectiveFromTimeKey<=@TimeKey AND AAR.EffectiveToTimeKey>=@TimeKey)
							AND (ACR.EffectiveFromTimeKey<=@TimeKey AND ACR.EffectiveToTimeKey>=@TimeKey)
							AND ACR.RelationEntityId=AAR.RelationEntityId
							AND AAR.RelationTypeAlt_Key in(17,60) -- joint borrower,guarantor
							AND Name LIKE '%'+@DefendentName+'%'	
							AND ISNULL(AAR.AuthorisationStatus,'A')='A'
							GROUP BY AAR.CustomerEntityID,AAR.AuthorisationStatus			
					UNION  
					SELECT AAR.CustomerEntityID, AAR.AuthorisationStatus FROM AdvAcRelations_Mod AAR
						INNER JOIN AdvCustRelationship_Mod ACR
							ON  (AAR.EffectiveFromTimeKey<=@TimeKey AND AAR.EffectiveToTimeKey>=@TimeKey)
							AND (ACR.EffectiveFromTimeKey<=@TimeKey AND ACR.EffectiveToTimeKey>=@TimeKey)
							AND ACR.RelationEntityId=AAR.RelationEntityId
							AND AAR.RelationTypeAlt_Key in(17,60) -- joint borrower,guarantor
							AND Name LIKE '%'+@DefendentName+'%'	
							AND AAR.AuthorisationStatus IN('NP','MP','DP')	
							GROUP BY AAR.CustomerEntityID,AAR.AuthorisationStatus			

	
					UNION   
					SELECT AAR.CustomerEntityID, AAR.AuthorisationStatus FROM curdat.AdvAcRelations AAR
						INNER JOIN curdat.AdvCustRelationship   ACR ON (ACR.EffectiveFromTimeKey<=@TimeKey AND ACR.EffectiveToTimeKey>=@TimeKey)
																	AND ACR.RelationEntityId=AAR.RelationEntityId
																	AND ACR.Name Like '%'+@DefendentName+'%'
																	AND ISNULL(ACR.AuthorisationStatus,'A')='A'
						INNER JOIN AdvCustCommunicationDetail COMM
							ON  (AAR.EffectiveFromTimeKey<=@TimeKey AND AAR.EffectiveToTimeKey>=@TimeKey)
							AND (COMM.EffectiveFromTimeKey<=@TimeKey AND COMM.EffectiveToTimeKey>=@TimeKey)
							AND COMM.RelationEntityId=AAR.RelationEntityId
							AND AAR.RelationTypeAlt_Key in(17,60) -- joint borrower,guarantor
							AND ISNULL(AAR.AuthorisationStatus,'A')='A'
							GROUP BY AAR.CustomerEntityID, AAR.AuthorisationStatus			
					UNION  
					SELECT AAR.CustomerEntityID, AAR.AuthorisationStatus FROM curdat.AdvAcRelations AAR
					INNER JOIN curdat.AdvCustRelationship   ACR ON (ACR.EffectiveFromTimeKey<=@TimeKey AND ACR.EffectiveToTimeKey>=@TimeKey)
																	AND ACR.RelationEntityId=AAR.RelationEntityId
																	AND ACR.Name Like '%'+@DefendentName+'%'
																	AND ISNULL(ACR.AuthorisationStatus,'A')='A'
						INNER JOIN AdvCustCommunicationDetail_Mod COMM
							ON  (AAR.EffectiveFromTimeKey<=@TimeKey AND AAR.EffectiveToTimeKey>=@TimeKey)
							AND (COMM.EffectiveFromTimeKey<=@TimeKey AND COMM.EffectiveToTimeKey>=@TimeKey)
							AND COMM.RelationEntityId=AAR.RelationEntityId
							AND AAR.RelationTypeAlt_Key in(17,60) -- joint borrower,guarantor
							AND AAR.AuthorisationStatus IN('NP','MP','DP')	
							GROUP BY AAR.CustomerEntityID, AAR.AuthorisationStatus
							
					IF NOT EXISTS (SELECT 1 FROM #CustDefData WHERE 1=1)
						BEGIN
								SET @Result=-3 /* Defendant doesnot exists*/
								--RETURN @Result
						END					
							
					--IF (SELECT COUNT(CustomerEntityId) FROM #CustDefData)>1000
					--BEGIN
					--		SET @Result=-4  /* If customer defendant DATA IS MORE THAN 100*/
					--		RETURN @Result
					--END
							
			END	

		
	IF OBJECT_ID('Tempdb..#CustBrData') IS NOT NULL
	DROP TABLE #CustBrData

	CREATE TABLE #CustBrData
	(
		CustomerEntityID	INT
		,BranchCode VARCHAR(10)
	)

	IF EXISTS (SELECT 1 FROM #CustomerEntityId WHERE 1=1 ) 
		BEGIN
				PRINT 'P1'
					
					INSERT INTO #CustBrData
					SELECT   ABD. CustomerEntityID
							, BranchCode 
					FROM 
					curdat.AdvAcBasicDetail ABD
					INNER JOIN #CustomerEntityId  C
						ON  (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
					AND ISNULL(ABD.AuthorisationStatus,'A')='A'	
					AND  C.CustomerEntityId = ABD.CustomerEntityId
					AND ABD.CustomerACID=CASE WHEN @CustomerAcID<>'' THEN @CustomerAcID ELSE ABD.CustomerACID END 
					 AND ABD.BranchCode=CASE WHEN @BranchCode<>'' THEN @BranchCode ELSE ABD.BranchCode END
					-- AND @CustType IN ('BORROWER','WRITTENOFF') --COMMENT BY HAMID ON 17 MAY 2018
					 GROUP BY ABD.CustomerEntityID,BranchCode
			


					--SELECT CustomerEntityID, BranchCode FROM AdvAcBasicDetail		ABD	WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) --AND BranchCode=@BranchCode
					-- AND ISNULL(AuthorisationStatus,'A')='A'		
					-- AND ABD.CustomerEntityId IN (SELECT CustomerEntityId FROM #CustomerEntityId GROUP BY CustomerEntityId)
					-- AND ABD.CustomerACID=CASE WHEN @CustomerAcID<>'' THEN @CustomerAcID ELSE ABD.CustomerACID END 
					-- AND ABD.BranchCode=CASE WHEN @BranchCode<>'' THEN @BranchCode ELSE ABD.BranchCode END
					-- AND @CustType IN ('BORROWER','WRITTENOFF')
					-- GROUP BY CustomerEntityID,BranchCode

					UNION 

				SELECT A.CustomerEntityID,A.BranchCode FROM AdvAcBasicDetail_Mod A  
						INNER JOIN(SELECT MAX(Ac_Key)Ac_Key FROM AdvAcBasicDetail_Mod A
						           WHERE (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
										AND A.CustomerEntityId IN (SELECT CustomerEntityId FROM #CustomerEntityId GROUP BY CustomerEntityId)
								        AND A.CustomerACID=CASE WHEN @CustomerAcID<>'' THEN @CustomerAcID ELSE A.CustomerACID END
										AND A.BranchCode=CASE WHEN @BranchCode<>'' THEN @BranchCode ELSE A.BranchCode END
										--AND @CustType IN ('BORROWER','WRITTENOFF') --COMMENT BY HAMID ON 17 MAY 2018
										AND AuthorisationStatus IN ('NP','MP','DP','RM')
										GROUP BY A.CustomerACID 
									)P  ON P.Ac_Key=A.Ac_Key AND (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)

				GROUP BY A.CustomerEntityID,A.BranchCode								

					UNION 

				SELECT CustomerEntityID,ParentBranchCode  FROM curdat.CustomerBasicDetail	CBD	WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
					 AND ISNULL(AuthorisationStatus,'A')='A'		
					 AND CBD.CustomerEntityId IN (SELECT CustomerEntityId FROM #CustomerEntityId GROUP BY CustomerEntityId)
					 AND CBD.ParentBranchCode=CASE WHEN @BranchCode<>'' THEN @BranchCode ELSE CBD.ParentBranchCode END	
					 AND @CustType='OTHERS'	
					 GROUP BY CustomerEntityID,ParentBranchCode																----FOR OTHER 

					UNION 

				SELECT A.CustomerEntityID,A.ParentBranchCode FROM CustomerBasicDetail_Mod A  
						INNER JOIN(SELECT MAX(Customer_Key)Customer_Key FROM CustomerBasicDetail_Mod A
						           WHERE (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
								        AND A.CustomerEntityId IN (SELECT CustomerEntityId FROM #CustomerEntityId GROUP BY CustomerEntityId)
										AND A.ParentBranchCode=CASE WHEN @BranchCode<>'' THEN @BranchCode ELSE A.ParentBranchCode END	
										AND AuthorisationStatus IN ('NP','MP','DP','RM')
										AND @CustType='OTHERS'	GROUP BY A.CustomerId 
									)P  ON P.Customer_Key=A.Customer_Key 
									AND (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)

					GROUP BY A.CustomerEntityID,A.ParentBranchCode															---FOR OTHER				

			--SELECT * FROM #CustBrData
		END

	ELSE IF  EXISTS (SELECT 1 FROM #CustDefData WHERE 1=1 ) 
		BEGIN
					PRINT 'Def'
					INSERT INTO #CustBrData

					SELECT CustomerEntityID, BranchCode FROM curdat.AdvAcBasicDetail		ABD	WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) --AND BranchCode=@BranchCode
					 AND ISNULL(AuthorisationStatus,'A')='A'		
					 AND ABD.CustomerEntityId IN (SELECT CustomerEntityId FROM #CustDefData GROUP BY CustomerEntityId)
					 AND ABD.CustomerACID=CASE WHEN @CustomerAcID<>'' THEN @CustomerAcID ELSE ABD.CustomerACID END 
					 AND ABD.BranchCode=CASE WHEN @BranchCode<>'' THEN @BranchCode ELSE ABD.BranchCode END
					 --AND @CustType IN ('BORROWER','WRITTENOFF') --COMMENT BY HAMID ON 17 MAY 2018
					 GROUP BY CustomerEntityID,BranchCode

					UNION 

				SELECT A.CustomerEntityID,A.BranchCode FROM AdvAcBasicDetail_Mod A  
						INNER JOIN(SELECT MAX(Ac_Key)Ac_Key FROM AdvAcBasicDetail_Mod A
						           WHERE (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
										AND A.CustomerEntityId IN (SELECT CustomerEntityId FROM #CustDefData GROUP BY CustomerEntityId)
								        AND A.CustomerACID=CASE WHEN @CustomerAcID<>'' THEN @CustomerAcID ELSE A.CustomerACID END
										AND A.BranchCode=CASE WHEN @BranchCode<>'' THEN @BranchCode ELSE A.BranchCode END
										--AND @CustType IN ('BORROWER','WRITTENOFF') --COMMENT BY HAMID ON 17 MAY 2018
										AND AuthorisationStatus IN ('NP','MP','DP','RM')
										GROUP BY A.CustomerACID 
									)P  ON P.Ac_Key=A.Ac_Key AND (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)

				GROUP BY A.CustomerEntityID,A.BranchCode								

					UNION 

				SELECT CustomerEntityID,ParentBranchCode  FROM curdat.CustomerBasicDetail	CBD	WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
					 AND ISNULL(AuthorisationStatus,'A')='A'		
					 AND CBD.CustomerEntityId IN (SELECT CustomerEntityId FROM #CustDefData GROUP BY CustomerEntityId)
					 AND CBD.ParentBranchCode=CASE WHEN @BranchCode<>'' THEN @BranchCode ELSE CBD.ParentBranchCode END	
					 AND @CustType='OTHERS'	
					 GROUP BY CustomerEntityID,ParentBranchCode																----FOR OTHER 

					UNION 

				SELECT A.CustomerEntityID,A.ParentBranchCode FROM CustomerBasicDetail_Mod A  
						INNER JOIN(SELECT MAX(Customer_Key)Customer_Key FROM CustomerBasicDetail_Mod A
						           WHERE (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
								        AND A.CustomerEntityId IN (SELECT CustomerEntityId FROM #CustDefData GROUP BY CustomerEntityId)
										AND A.ParentBranchCode=CASE WHEN @BranchCode<>'' THEN @BranchCode ELSE A.ParentBranchCode END	
										AND AuthorisationStatus IN ('NP','MP','DP','RM')
										AND @CustType='OTHERS'	GROUP BY A.CustomerId 
									)P  ON P.Customer_Key=A.Customer_Key 
									AND (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)

					GROUP BY A.CustomerEntityID,A.ParentBranchCode															---FOR OTHER				


		END		

	ELSE
		 BEGIN
			    PRINT 'ELSE'
				INSERT INTO #CustBrData

					SELECT CustomerEntityID, BranchCode FROM curdat.AdvAcBasicDetail		ABD	WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) --AND BranchCode=@BranchCode
					 AND ISNULL(AuthorisationStatus,'A')='A'		
					 AND CustomerEntityId=CASE WHEN @CustomerEntityID>0 THEN @CustomerEntityID ELSE CustomerEntityId END
					 AND ABD.CustomerACID=CASE WHEN @CustomerAcID<>'' THEN @CustomerAcID ELSE ABD.CustomerACID END 
					 AND ABD.BranchCode=CASE WHEN @BranchCode<>'' THEN @BranchCode ELSE ABD.BranchCode END
					 --AND @CustType IN ('BORROWER','WRITTENOFF') --COMMENT BY HAMID ON 17 MAY 2018
					 GROUP BY CustomerEntityID,BranchCode

					UNION 

				SELECT A.CustomerEntityID,A.BranchCode FROM AdvAcBasicDetail_Mod A  
						INNER JOIN(SELECT MAX(Ac_Key)Ac_Key FROM AdvAcBasicDetail_Mod A
						           WHERE (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
										AND A.CustomerEntityId=CASE WHEN @CustomerEntityID>0 THEN @CustomerEntityID ELSE A.CustomerEntityId END
								        AND A.CustomerACID=CASE WHEN @CustomerAcID<>'' THEN @CustomerAcID ELSE A.CustomerACID END
										AND A.BranchCode=CASE WHEN @BranchCode<>'' THEN @BranchCode ELSE A.BranchCode END
										--AND @CustType IN ('BORROWER','WRITTENOFF') --COMMENT BY HAMID ON 17 MAY 2018
										AND AuthorisationStatus IN ('NP','MP','DP','RM')
										GROUP BY A.CustomerACID 
									)P  ON P.Ac_Key=A.Ac_Key AND (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)

				GROUP BY A.CustomerEntityID,A.BranchCode								

					UNION 

				SELECT CustomerEntityID,ParentBranchCode  FROM curdat.CustomerBasicDetail	CBD	WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
					 AND ISNULL(AuthorisationStatus,'A')='A'		
					 AND CBD.CustomerId=CASE WHEN @CustomerId<>'' THEN @CustomerId ELSE CBD.CustomerId END
					 AND CBD.ParentBranchCode=CASE WHEN @BranchCode<>'' THEN @BranchCode ELSE CBD.ParentBranchCode END	
					 AND @CustType='OTHERS'	
					 GROUP BY CustomerEntityID,ParentBranchCode																----FOR OTHER 

					UNION 

				SELECT A.CustomerEntityID,A.ParentBranchCode FROM CustomerBasicDetail_Mod A  
						INNER JOIN(SELECT MAX(Customer_Key)Customer_Key FROM CustomerBasicDetail_Mod A
						           WHERE (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
								        AND A.CustomerId=CASE WHEN @CustomerId<>'' THEN @CustomerId ELSE A.CustomerId END
										AND A.ParentBranchCode=CASE WHEN @BranchCode<>'' THEN @BranchCode ELSE A.ParentBranchCode END	
										AND AuthorisationStatus IN ('NP','MP','DP','RM')
										AND @CustType='OTHERS'	GROUP BY A.CustomerId 
									)P  ON P.Customer_Key=A.Customer_Key 
									AND (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)

					GROUP BY A.CustomerEntityID,A.ParentBranchCode	
		 
		 END 



IF OBJECT_ID('Tempdb..#PreCaseCustData') IS NOT NULL
DROP TABLE #PreCaseCustData

CREATE TABLE #PreCaseCustData
	(
		 CustomerEntityID	INT
		 ,SourceSystem		VARCHAR(20)
		 ,Ucif_ID		VARCHAR(20)
		,CustomerID		VARCHAR(20)
		,CustomerName	VARCHAR(80)
		,CustomerSinceDt	VARCHAR(10)
		,NPADt			VARCHAR(10)
		,BranchCode		VARCHAR(10)
		,BranchName		VARCHAR(50)
		,CurrentStage	VARCHAR(30)
		,NextStage		VARCHAR(30)
		
		,CurrStageMenuId INT
		,NxtStageMenuId  INT
		,CurrStageAuthMode VARCHAR(1)
		,NxtStageAuthMode VARCHAR(1)
		,CurrStageNonAllowOp VARCHAR(3)
		,NxtStageNonAllowOp VARCHAR(3)

		,AuthorisationStatus VARCHAR(20)
		
	)	
	
			print '1 PRE'
			PRINT @CustomerID
			--SELECT * FROM #CustBrData
			--SELECT * FROM #CustAcData

		
			INSERT INTO #PreCaseCustData
						(
							CustomerEntityId		--1
							,SourceSystem		
							,Ucif_ID		
							,CustomerID				--2
							,CustomerName			--3
							,CustomerSinceDt
							,NPADt
							,BranchCode				--4
							,BranchName				--5
							,CurrentStage			--6
							,NextStage				--7

							,CurrStageMenuId
							,NxtStageMenuId
							,CurrStageAuthMode
							,NxtStageAuthMode
							,CurrStageNonAllowOp
							,NxtStageNonAllowOp
						    ,AuthorisationStatus
													
						)
					SELECT 
							CBD.CustomerEntityId,	--1
							S.SourceName as SourceSystem,
							CBD.UCIF_ID,
							CBD.CustomerID,			--2
							CBD.Customername,		--3
							CONVERT(VARCHAR(10),CBD.CustomerSinceDt,103)CustomerSinceDt,
							CONVERT(VARCHAR(10),NPA.NPADt,103)NPADt, 
							BR.BranchCode,			--4
							BR.BranchName,			--5
							ISNULL(DS1.ParameterName,'Customer') ParameterName,		--6
							--CASE WHEN CBD.CustType='OTHERS' THEN NULL ELSE  DS2.ParameterName END      ---7
								DS2.ParameterName	
						   ,MCur.MenuId AS CurrStageMenuId
						   --,CASE WHEN CBD.CustType='OTHERS' THEN NULL ELSE MNxt.MenuId END AS NxtStageMenuId
						   ,MNxt.MenuId  AS NxtStageMenuId
						   ,MCur.EnableMakerChecker AS CurrStageAuthMode
						   ,MNxt.EnableMakerChecker AS NxtStageAuthMode
						   ,MCur.NonAllowOperation AS CurrStageNonAllowOp
						   ,MNxt.NonAllowOperation AS NxtStageNonAllowOp			

						,CASE WHEN T.AuthorisationStatus IN('NP','MP','DP') THEN T.AuthorisationStatus ELSE CBD.AuthorisationStatus  END AuthorisationStatus
				         FROM 
							(
								SELECT 
								--CustomerEntityId,CustomerId,D2kCustomerid,ParentBranchCode,CustomerName,CustomerInitial,CustomerSinceDt,ConsentObtained,ConstitutionAlt_Key
								--,OccupationAlt_Key,ReligionAlt_Key,CasteAlt_Key,FarmerCatAlt_Key,GaurdianSalutationAlt_Key,GaurdianName,GuardianType,CustSalutationAlt_Key
								--,MaritalStatusAlt_Key,DegUpgFlag,ProcessingFlag,MOCLock,MoveNpaDt,AssetClass,BIITransactionCode,D2K_REF_NO,CustomerNameBackup,ScrCrErrorBackup
								--,ScrCrError,ReferenceAcNo,CustCRM_RatingAlt_Key,CustCRM_RatingDt,AuthorisationStatus,EffectiveFromTimeKey,EffectiveToTimeKey,CreatedBy,DateCreated
								--,ModifiedBy,DateModified,ApprovedBy,DateApproved,FLAG,MocStatus,MocDate,BaselProcessing,MocTypeAlt_Key,CommonMocTypeAlt_Key,LandHolding
								--,ScrCrErrorSeq,CustType,ServProviderAlt_Key,NonCustTypeAlt_Key,Remark,CUSTOMER_KEY

								Customer_Key,CustomerEntityId,CustomerId,D2kCustomerid,UCIF_ID,UcifEntityID,ParentBranchCode,CustomerName,CustomerInitial,CustomerSinceDt
								,ConstitutionAlt_Key,OccupationAlt_Key,ReligionAlt_Key,CasteAlt_Key,FarmerCatAlt_Key,GaurdianSalutationAlt_Key,GaurdianName,GuardianType
								,CustSalutationAlt_Key,MaritalStatusAlt_Key,AssetClass,BIITransactionCode,D2K_REF_NO,ScrCrError,ReferenceAcNo,CustCRM_RatingAlt_Key
								,CustCRM_RatingDt,AuthorisationStatus,EffectiveFromTimeKey,EffectiveToTimeKey,CreatedBy,DateCreated,ModifiedBy,DateModified,ApprovedBy
								,DateApproved,D2Ktimestamp,FLAG,MocStatus,MocDate,MocTypeAlt_Key,CommonMocTypeAlt_Key,LandHolding,ScrCrErrorSeq,Remark,SourceSystemAlt_Key


								 FROM CURDAT.CUSTOMERBASICDETAIL 
									WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
									AND ISNULL(AuthorisationStatus,'A')='A'

								UNION 
									SELECT 
								--	CustomerEntityId,CustomerId,D2kCustomerid,ParentBranchCode,CustomerName,CustomerInitial,CustomerSinceDt,ConsentObtained,ConstitutionAlt_Key
								--,OccupationAlt_Key,ReligionAlt_Key,CasteAlt_Key,FarmerCatAlt_Key,GaurdianSalutationAlt_Key,GaurdianName,GuardianType,CustSalutationAlt_Key
								--,MaritalStatusAlt_Key,DegUpgFlag,ProcessingFlag,MOCLock,MoveNpaDt,AssetClass,BIITransactionCode,D2K_REF_NO,CustomerNameBackup,ScrCrErrorBackup
								--,ScrCrError,ReferenceAcNo,CustCRM_RatingAlt_Key,CustCRM_RatingDt,AuthorisationStatus,EffectiveFromTimeKey,EffectiveToTimeKey,CreatedBy,DateCreated
								--,ModifiedBy,DateModified,ApprovedBy,DateApproved,FLAG,MocStatus,MocDate,BaselProcessing,MocTypeAlt_Key,CommonMocTypeAlt_Key,LandHolding
								--,ScrCrErrorSeq,CustType,ServProviderAlt_Key,NonCustTypeAlt_Key,Remark,CUSTOMER_KEY

								Customer_Key,CustomerEntityId,CustomerId,D2kCustomerid,UCIF_ID,UcifEntityID,ParentBranchCode,CustomerName,CustomerInitial,CustomerSinceDt
								,ConstitutionAlt_Key,OccupationAlt_Key,ReligionAlt_Key,CasteAlt_Key,FarmerCatAlt_Key,GaurdianSalutationAlt_Key,GaurdianName,GuardianType
								,CustSalutationAlt_Key,MaritalStatusAlt_Key,AssetClass,BIITransactionCode,D2K_REF_NO,ScrCrError,ReferenceAcNo,CustCRM_RatingAlt_Key
								,CustCRM_RatingDt,AuthorisationStatus,EffectiveFromTimeKey,EffectiveToTimeKey,CreatedBy,DateCreated,ModifiedBy,DateModified,ApprovedBy
								,DateApproved,D2Ktimestamp,FLAG,MocStatus,MocDate,MocTypeAlt_Key,CommonMocTypeAlt_Key,LandHolding,ScrCrErrorSeq,Remark,SourceSystemAlt_Key
									
									 FROM CUSTOMERBASICDETAIL_MOD 
									WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
									AND AuthorisationStatus IN('NP','MP','DP')
									AND Customer_Key IN(SELECT MAX(Customer_Key) FROM CUSTOMERBASICDETAIL_MOD 
									WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
									AND AuthorisationStatus IN('NP','MP','DP') GROUP BY CustomerId)
							)CBD
						 
				     

					LEFT JOIN CURDAT.AdvCustFinancialDetail CFD
							ON (CFD.EffectiveFromTimeKey<=@TimeKey AND CFD.EffectiveToTimeKey>=@TimeKey)
							AND CBD.CustomerEntityId=CFD.CustomerEntityId

					LEFT JOIN #CustBrData CBR
							ON CBR.CustomerEntityId=CBD.CustomerEntityId

					LEFT JOIN DimBranch BR
							ON (BR.EffectiveFromTimeKey<=@TimeKey AND BR.EffectiveToTimeKey>=@TimeKey)
							AND BR.BranchCode=CBR.BranchCode

					LEFT JOIN DimSourceDB S ON S.SourceAlt_Key=CBD.SourceSystemAlt_Key
					AND S.EffectiveFromTimeKey<=@TimeKey AND S.EffectiveToTimeKey>=@TimeKey
					--INNER JOIN CustPreCaseDataStage STG
					--		ON CBD.CustomerEntityId=STG.CustomerEntityId
					LEFT JOIN CustPreCaseDataStage STG
							ON CBD.CustomerEntityId=STG.CustomerEntityId

					LEFT JOIN DimParameter DS1
							ON (DS1.EffectiveFromTimeKey<=@TimeKey AND DS1.EffectiveToTimeKey>=@TimeKey)
							AND DS1.ParameterAlt_Key=STG.CurrentStageAlt_Key
							AND DS1.DimParameterName='DimCustPreCaseDataStage'
					LEFT JOIN DimParameter DS2
							ON (DS2.EffectiveFromTimeKey<=@TimeKey AND DS2.EffectiveToTimeKey>=@TimeKey)
							AND DS2.ParameterAlt_Key=STG.NextStageAlt_Key
							AND DS2.DimParameterName='DimCustPreCaseDataStage'
					LEFT JOIN #CustAcData T
							ON T.CustomerEntityID=CBD.CustomerEntityID
					LEFT JOIN #CustDefData D
							ON D.CustomerEntityID=CBD.CustomerEntityID
					LEFT JOIN syscrismacmenu MCur
					       --ON MCur.MenuCaption=DS1.ParameterName
						   ON MCur.MENUID=DS1.ParameterShortName
					 LEFT JOIN syscrismacmenu MNxt	
						 ---ON MNxt.MenuCaption=DS2.ParameterName	
						 ON MCur.MENUID=DS2.ParameterShortName	
					LEFT JOIN CURDAT.AdvCustNPAdetail NPA	 
					ON (NPA.EffectiveFromTimeKey<=@TimeKey AND NPA.EffectiveToTimeKey>=@TimeKey)
							AND CBD.CustomerEntityId=NPA.CustomerEntityId	

					WHERE (CBD.EffectiveFromTimeKey<=@TimeKey AND CBD.EffectiveToTimeKey>=@TimeKey)
						  ----AND ISNULL(CBD.AuthorisationStatus,'A')='A'
						  --AND CBD.CustType=@CustType  -- CFD
						  AND (CustomerID= CASE WHEN @CustomerID<>'' then @CustomerID else CustomerID END)
						  AND (CustomerName LIKE  CASE WHEN @CustomerName<>'' THEN '%'+@CustomerName+'%' ELSE CustomerName END)
						  AND (ISNULL(BR.BranchCode,'') =  CASE WHEN @BranchCode<>'' then @BranchCode ELSE ISNULL(BR.BranchCode,'') END)
						  AND (ISNULL(BranchName,'') LIKE  CASE WHEN @BranchName<>'' THEN '%'+@BranchName+'%' ELSE ISNULL(BranchName,'') END)
						  AND (ISNULL(T.CustomerEntityID,0)= case when @CustomerAcid<>'' THEN CBD.CustomerEntityId ELSE ISNULL(T.CustomerEntityID,0) END)
						  AND (ISNULL(D.CustomerEntityID,0)= case when @DefendentName<>'' THEN CBD.CustomerEntityId ELSE ISNULL(D.CustomerEntityID,0) END)
						  AND (UCIF_ID= CASE WHEN @UCICID<>'' then @UCICID else UCIF_ID END)
			
				PRINT @@ROWCOUNT
INSERT INTO #PreCaseCustData
						(
							CustomerEntityId		--1
							,CustomerID				--2
							,CustomerName			--3
							,CustomerSinceDt
							,NPADt
							,BranchCode				--4
							,BranchName				--5
							,CurrentStage			--6
							,NextStage				--7

							,CurrStageMenuId
							,NxtStageMenuId
							,CurrStageAuthMode
							,NxtStageAuthMode
							,CurrStageNonAllowOp
							,NxtStageNonAllowOp
							,AuthorisationStatus
						

						)
					SELECT 
							CBD.CustomerEntityId,	--1
							CBD.CustomerID,			--2
							CBD.Customername,		--3
							CONVERT(VARCHAR(10),CBD.CustomerSinceDt,103)CustomerSinceDt,
							CONVERT(VARCHAR(10),NPA.NPADt,103)NPADt,
							
							CBR.BranchCode,			--4
							BR.BranchName,			--5
							ISNULL(DS1.ParameterName,'Customer'),		--6
							--CASE WHEN CBD.CustType='OTHERS' THEN NULL ELSE  DS2.ParameterName END,		--7
							DS2.ParameterName,

						    MCur.MenuId AS CurrStageMenuId
						   --,CASE WHEN CBD.CustType='OTHERS' THEN NULL ELSE MNxt.MenuId END AS NxtStageMenuId
						   ,MNxt.MenuId  AS NxtStageMenuId
						   ,MCur.EnableMakerChecker AS CurrStageAuthMode
						   ,MNxt.EnableMakerChecker AS NxtStageAuthMode
						   ,MCur.NonAllowOperation AS CurrStageNonAllowOp
						   ,MNxt.NonAllowOperation AS NxtStageNonAllowOp
						 
						  ,CASE WHEN T.AuthorisationStatus IN('NP','MP','DP') THEN T.AuthorisationStatus ELSE CBD.AuthorisationStatus  END AuthorisationStatus
				           FROM CustomerBasicDetail_Mod CBD
							INNER JOIN (
											select max(Customer_Key)Customer_Key , CustomerEntityId from CustomerBasicDetail_Mod group by CustomerEntityId
									 )A    on cbd.CustomerEntityId=A.CustomerEntityId
							 and cbd.Customer_Key=A.Customer_Key  						
							
					LEFT JOIN CurDat.AdvCustFinancialDetail CFD
							ON (CFD.EffectiveFromTimeKey<=@TimeKey AND CFD.EffectiveToTimeKey>=@TimeKey)
							AND CBD.CustomerEntityId=CFD.CustomerEntityId

					LEFT JOIN #CustBrData CBR
							ON CBR.CustomerEntityId=CBD.CustomerEntityId

					LEFT JOIN DimBranch BR
							ON (BR.EffectiveFromTimeKey<=@TimeKey AND BR.EffectiveToTimeKey>=@TimeKey)
							AND BR.BranchCode=CBR.BranchCode

					INNER JOIN CustPreCaseDataStage STG
							ON CBD.CustomerEntityId=STG.CustomerEntityId

					LEFT JOIN DimParameter DS1
							ON (DS1.EffectiveFromTimeKey<=@TimeKey AND DS1.EffectiveToTimeKey>=@TimeKey)
							AND DS1.ParameterAlt_Key=STG.CurrentStageAlt_Key
							AND DS1.DimParameterName='DimCustPreCaseDataStage'
					LEFT JOIN DimParameter DS2
							ON (DS2.EffectiveFromTimeKey<=@TimeKey AND DS2.EffectiveToTimeKey>=@TimeKey)
							AND DS2.ParameterAlt_Key=STG.NextStageAlt_Key
							AND DS2.DimParameterName='DimCustPreCaseDataStage'
					LEFT JOIN #CustAcData T
							ON T.CustomerEntityID=CBD.CustomerEntityID
					LEFT JOIN #CustDefData D
							ON D.CustomerEntityID=CBD.CustomerEntityID
					LEFT JOIN syscrismacmenu MCur
					       --ON MCur.MenuCaption=DS1.ParameterName
						   ON MCur.MENUID=DS1.ParameterShortName
					 LEFT JOIN syscrismacmenu MNxt	
						 --ON MNxt.MenuCaption=DS2.ParameterName
						 ON MCur.MENUID=DS2.ParameterShortName
					LEFT JOIN AdvCustNPAdetail_Mod NPA	 
					ON (NPA.EffectiveFromTimeKey<=@TimeKey AND NPA.EffectiveToTimeKey>=@TimeKey)
							AND CBD.CustomerEntityId=NPA.CustomerEntityId			

					 WHERE 
							(CBD.EffectiveFromTimeKey<=@TimeKey AND CBD.EffectiveToTimeKey>=@TimeKey)	
						 AND CBD.AuthorisationStatus IN('NP','MP','DP')	
						 --AND CBD.CustType=@CustType  -- CFD
						AND	(CustomerID= CASE WHEN @CustomerID<>'' then @CustomerID else CustomerID END)
						AND	(CustomerName LIKE  CASE WHEN @CustomerName<>'' THEN '%'+@CustomerName+'%' ELSE CustomerName END)
						AND (ISNULL(BR.BranchCode,'') =  CASE WHEN @BranchCode<>'' then @BranchCode ELSE ISNULL(BR.BranchCode,'') END)
						AND (ISNULL(BranchName,'') LIKE  CASE WHEN @BranchName<>'' THEN '%'+@BranchName+'%' ELSE ISNULL(BranchName,'') END)
						AND (ISNULL(T.CustomerEntityID,0)= case when @CustomerAcid<>'' THEN CBD.CustomerEntityId ELSE ISNULL(T.CustomerEntityID,0) END)
						AND (ISNULL(D.CustomerEntityID,0)= case when @DefendentName<>'' THEN CBD.CustomerEntityId ELSE ISNULL(D.CustomerEntityID,0) END)
						AND (UCIF_ID= CASE WHEN @UCICID<>'' then @UCICID else UCIF_ID END)

						
						print 1111

			

UPDATE A
				SET A.AuthorisationStatus= C.AuthorisationStatus
				FROM #PreCaseCustData A
				INNER JOIN(
				SELECT A.AuthorisationStatus,A.Customer_Key,A.CustomerEntityId  FROM CustomerBasicDetail_Mod A
				INNER JOIN(SELECT MAX(A.Customer_Key)Customer_Key FROM CustomerBasicDetail_Mod A
				            WHERE (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
							     AND A.AuthorisationStatus IN ('NP','MP','DP','RM')
								 GROUP BY A.CustomerEntityId
						
				               ) B  ON B.Customer_Key=A.Customer_Key AND 
							   (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)

						  ) C  ON 	C.CustomerEntityId=A.CustomerEntityId


				UPDATE A
				SET A.AuthorisationStatus= C.AuthorisationStatus
				FROM #PreCaseCustData A
				INNER JOIN(
				SELECT A.AuthorisationStatus,A.EntityKey,A.CustomerEntityId  FROM AdvCustFinancialDetail_Mod A
				INNER JOIN(SELECT MAX(A.EntityKey)EntityKey FROM AdvCustFinancialDetail_Mod A
				            WHERE (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
							     AND A.AuthorisationStatus IN ('NP','MP','DP','RM')
								 GROUP BY A.CustomerEntityId
						
				               ) B  ON B.EntityKey=A.EntityKey AND 
							   (A.EffectiveFromTimeKey<=@TIMEKEY AND A.EffectiveToTimeKey>=@TIMEKEY)

						  ) C  ON 	C.CustomerEntityId=A.CustomerEntityId



				UPDATE A
				SET A.AuthorisationStatus= C.AuthorisationStatus
				FROM #PreCaseCustData A
				INNER JOIN(
				SELECT A.AuthorisationStatus,A.EntityKey,A.CustomerEntityId  FROM AdvCustNPAdetail_Mod A
				INNER JOIN(SELECT MAX(A.EntityKey)EntityKey FROM AdvCustNPAdetail_Mod A
				            WHERE (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
							     AND A.AuthorisationStatus IN ('NP','MP','DP','RM')
								 GROUP BY A.CustomerEntityId
						
				               ) B  ON B.EntityKey=A.EntityKey AND 
							   (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)

						  ) C  ON 	C.CustomerEntityId=A.CustomerEntityId


				UPDATE A
				SET A.AuthorisationStatus= C.AuthorisationStatus
				FROM #PreCaseCustData A
				INNER JOIN(
				SELECT A.AuthorisationStatus,A.EntityKey,A.CustomerEntityId  FROM AdvCustOtherDetail_Mod A
				INNER JOIN(SELECT MAX(A.EntityKey)EntityKey FROM AdvCustOtherDetail_Mod A
				            WHERE (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
							     AND A.AuthorisationStatus IN ('NP','MP','DP','RM')
								 GROUP BY A.CustomerEntityId
						
				               ) B  ON B.EntityKey=A.EntityKey AND 
							   (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)

						  ) C  ON 	C.CustomerEntityId=A.CustomerEntityId
					

				UPDATE A
				SET A.AuthorisationStatus= C.AuthorisationStatus
				FROM #PreCaseCustData A
				INNER JOIN(
				SELECT A.AuthorisationStatus,A.EntityKey,A.CustomerEntityId  FROM AdvCustRelationship_Mod A
				INNER JOIN(SELECT MAX(A.EntityKey)EntityKey FROM AdvCustRelationship_Mod A
				            WHERE (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
							     AND A.AuthorisationStatus IN ('NP','MP','DP','RM')
								 GROUP BY A.CustomerEntityId
						
				               ) B  ON B.EntityKey=A.EntityKey AND 
							   (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)

						  ) C  ON 	C.CustomerEntityId=A.CustomerEntityId

					
				UPDATE A
				SET A.AuthorisationStatus= C.AuthorisationStatus
				FROM #PreCaseCustData A
				INNER JOIN(
				SELECT A.AuthorisationStatus,A.EntityKey,A.CustomerEntityId  FROM AdvCustCommunicationDetail_Mod A
				INNER JOIN(SELECT MAX(A.EntityKey)EntityKey FROM AdvCustCommunicationDetail_Mod A
				            WHERE (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
							     AND A.AuthorisationStatus IN ('NP','MP','DP','RM')
								 GROUP BY A.CustomerEntityId
						
				               ) B  ON B.EntityKey=A.EntityKey AND 
							   (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)

						  ) C  ON 	C.CustomerEntityId=A.CustomerEntityId



				UPDATE A
				SET A.AuthorisationStatus= C.AuthorisationStatus
				FROM #PreCaseCustData A
				INNER JOIN(
				SELECT A.AuthorisationStatus,A.Ac_Key,A.CustomerEntityId  FROM AdvAcBasicDetail_mod A
				INNER JOIN(SELECT MAX(A.Ac_Key)Ac_Key FROM AdvAcBasicDetail_mod A
				            WHERE (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
							     AND A.AuthorisationStatus IN ('NP','MP','DP','RM')
								 GROUP BY A.AccountEntityId
						
				               ) B  ON B.Ac_Key=A.Ac_Key AND 
							   (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)

						  ) C  ON 	C.CustomerEntityId=A.CustomerEntityId
				

			 UPDATE A
				SET A.AuthorisationStatus= C.AuthorisationStatus
				FROM #PreCaseCustData A
				INNER JOIN(
							SELECT D.AuthorisationStatus,A.Ac_Key,A.AccountEntityId,A.CustomerEntityId  FROM AdvAcBasicDetail_mod A
							INNER JOIN(SELECT MAX(A.Ac_Key)Ac_Key FROM AdvAcBasicDetail_mod A
								WHERE (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
							     AND A.AuthorisationStatus IN ('NP','MP','DP','RM')
								 GROUP BY A.AccountEntityId
						
									 ) B  ON B.Ac_Key=A.Ac_Key AND 
									 (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
                   
							  INNER JOIN (
					
											 SELECT A.AuthorisationStatus,A.EntityKey,A.AccountEntityId  FROM AdvAcBalanceDetail_mod A
											  INNER JOIN(SELECT MAX(A.EntityKey)EntityKey FROM AdvAcBalanceDetail_mod A
											 WHERE (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
											 AND A.AuthorisationStatus IN ('NP','MP','DP','RM')
												 GROUP BY A.AccountEntityId
						
															 ) B  ON B.EntityKey=A.EntityKey AND 
														 (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
								
											 )D   ON D.AccountEntityId=A.AccountEntityId	
									
						 ) C  ON 	C.CustomerEntityId=A.CustomerEntityId



						 
			 UPDATE A
				SET A.AuthorisationStatus= C.AuthorisationStatus
				FROM #PreCaseCustData A
				INNER JOIN(
							SELECT D.AuthorisationStatus,A.Ac_Key,A.AccountEntityId,A.CustomerEntityId  FROM AdvAcBasicDetail_mod A
							INNER JOIN(SELECT MAX(A.Ac_Key)Ac_Key FROM AdvAcBasicDetail_mod A
								WHERE (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
							     AND A.AuthorisationStatus IN ('NP','MP','DP','RM')
								 GROUP BY A.AccountEntityId
						
									 ) B  ON B.Ac_Key=A.Ac_Key AND 
									 (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
                   
							  INNER JOIN (
					
											 SELECT A.AuthorisationStatus,A.EntityKey,A.AccountEntityId  FROM AdvAcCaseWiseBalanceDetails_Mod A
											  INNER JOIN(SELECT MAX(A.EntityKey)EntityKey FROM AdvAcCaseWiseBalanceDetails_Mod A
											 WHERE (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
											 AND A.AuthorisationStatus IN ('NP','MP','DP','RM')
												 GROUP BY A.AccountEntityId
						
															 ) B  ON B.EntityKey=A.EntityKey AND 
														 (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
								
											 )D   ON D.AccountEntityId=A.AccountEntityId	
									
						 ) C  ON 	C.CustomerEntityId=A.CustomerEntityId



						 					 
			 UPDATE A
				SET A.AuthorisationStatus= C.AuthorisationStatus
				FROM #PreCaseCustData A
				INNER JOIN(
							SELECT D.AuthorisationStatus,A.Ac_Key,A.AccountEntityId,A.CustomerEntityId  FROM AdvAcBasicDetail_mod A
							INNER JOIN(SELECT MAX(A.Ac_Key)Ac_Key FROM AdvAcBasicDetail_mod A
								WHERE (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
							     AND A.AuthorisationStatus IN ('NP','MP','DP','RM')
								 GROUP BY A.AccountEntityId
						
									 ) B  ON B.Ac_Key=A.Ac_Key AND 
									 (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
                   
							  INNER JOIN (
					
											 SELECT A.AuthorisationStatus,A.EntityKey,A.AccountEntityId  FROM AdvAcFinancialDetail_Mod A
											  INNER JOIN(SELECT MAX(A.EntityKey)EntityKey FROM AdvAcFinancialDetail_Mod A
											 WHERE (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
											 AND A.AuthorisationStatus IN ('NP','MP','DP','RM')
												 GROUP BY A.AccountEntityId
						
															 ) B  ON B.EntityKey=A.EntityKey AND 
														 (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
								
											 )D   ON D.AccountEntityId=A.AccountEntityId	
									
						 ) C  ON 	C.CustomerEntityId=A.CustomerEntityId



						 					 					 
			 UPDATE A
				SET A.AuthorisationStatus= C.AuthorisationStatus
				FROM #PreCaseCustData A
				INNER JOIN(
							SELECT D.AuthorisationStatus,A.Ac_Key,A.AccountEntityId,A.CustomerEntityId  FROM AdvAcBasicDetail_mod A
							INNER JOIN(SELECT MAX(A.Ac_Key)Ac_Key FROM AdvAcBasicDetail_mod A
								WHERE (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
							     AND A.AuthorisationStatus IN ('NP','MP','DP','RM')
								 GROUP BY A.AccountEntityId
						
									 ) B  ON B.Ac_Key=A.Ac_Key AND 
									 (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
                   
							  INNER JOIN (
					
											 SELECT A.AuthorisationStatus,A.EntityKey,A.AccountEntityId  FROM AdvAcOtherBalanceDetail_Mod A
											  INNER JOIN(SELECT MAX(A.EntityKey)EntityKey FROM AdvAcOtherBalanceDetail_Mod A
											 WHERE (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
											 AND A.AuthorisationStatus IN ('NP','MP','DP','RM')
												 GROUP BY A.AccountEntityId
						
															 ) B  ON B.EntityKey=A.EntityKey AND 
														 (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
								
											 )D   ON D.AccountEntityId=A.AccountEntityId	
									
						 ) C  ON 	C.CustomerEntityId=A.CustomerEntityId


				 UPDATE A
				SET A.AuthorisationStatus= C.AuthorisationStatus
				FROM #PreCaseCustData A
				INNER JOIN(
							SELECT D.AuthorisationStatus,A.Ac_Key,A.AccountEntityId,A.CustomerEntityId  FROM AdvAcBasicDetail_mod A
							INNER JOIN(SELECT MAX(A.Ac_Key)Ac_Key FROM AdvAcBasicDetail_mod A
								WHERE (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
							     AND A.AuthorisationStatus IN ('NP','MP','DP','RM')
								 GROUP BY A.AccountEntityId
						
									 ) B  ON B.Ac_Key=A.Ac_Key AND 
									 (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
                   
							  INNER JOIN (
					
											 SELECT A.AuthorisationStatus,A.EntityKey,A.AccountEntityId  FROM AdvAcOtherDetail_Mod A
											  INNER JOIN(SELECT MAX(A.EntityKey)EntityKey FROM AdvAcOtherDetail_Mod A
											 WHERE (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
											 AND A.AuthorisationStatus IN ('NP','MP','DP','RM')
												 GROUP BY A.AccountEntityId
						
															 ) B  ON B.EntityKey=A.EntityKey AND 
														 (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
								
											 )D   ON D.AccountEntityId=A.AccountEntityId	
									
						 ) C  ON 	C.CustomerEntityId=A.CustomerEntityId




				UPDATE A
				SET A.AuthorisationStatus= C.AuthorisationStatus
				FROM #PreCaseCustData A
				INNER JOIN(
							SELECT D.AuthorisationStatus,A.Ac_Key,A.AccountEntityId,A.CustomerEntityId  FROM AdvAcBasicDetail_mod A
							INNER JOIN(SELECT MAX(A.Ac_Key)Ac_Key FROM AdvAcBasicDetail_mod A
								WHERE (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
							     AND A.AuthorisationStatus IN ('NP','MP','DP','RM')
								 GROUP BY A.AccountEntityId
						
									 ) B  ON B.Ac_Key=A.Ac_Key AND 
									 (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
                   
							  INNER JOIN (
					
											 SELECT A.AuthorisationStatus,A.EntityKey,A.AccountEntityId  FROM AdvFacBillDetail_Mod A
											  INNER JOIN(SELECT MAX(A.EntityKey)EntityKey FROM AdvFacBillDetail_Mod A
											 WHERE (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
											 AND A.AuthorisationStatus IN ('NP','MP','DP','RM')
												 GROUP BY A.AccountEntityId
						
															 ) B  ON B.EntityKey=A.EntityKey AND 
														 (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
								
											 )D   ON D.AccountEntityId=A.AccountEntityId	
									
						 ) C  ON 	C.CustomerEntityId=A.CustomerEntityId



				UPDATE A
				SET A.AuthorisationStatus= C.AuthorisationStatus
				FROM #PreCaseCustData A
				INNER JOIN(
							SELECT D.AuthorisationStatus,A.Ac_Key,A.AccountEntityId,A.CustomerEntityId  FROM AdvAcBasicDetail_mod A
							INNER JOIN(SELECT MAX(A.Ac_Key)Ac_Key FROM AdvAcBasicDetail_mod A
								WHERE (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
							     AND A.AuthorisationStatus IN ('NP','MP','DP','RM')
								 GROUP BY A.AccountEntityId
						
									 ) B  ON B.Ac_Key=A.Ac_Key AND 
									 (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
                   
							  INNER JOIN (
					
											 SELECT A.AuthorisationStatus,A.EntityKey,A.AccountEntityId  FROM AdvFacCCDetail_mod A
											  INNER JOIN(SELECT MAX(A.EntityKey)EntityKey FROM AdvFacCCDetail_mod A
											 WHERE (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
											 AND A.AuthorisationStatus IN ('NP','MP','DP','RM')
												 GROUP BY A.AccountEntityId
						
															 ) B  ON B.EntityKey=A.EntityKey AND 
														 (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
								
											 )D   ON D.AccountEntityId=A.AccountEntityId	
									
						 ) C  ON 	C.CustomerEntityId=A.CustomerEntityId



				UPDATE A
				SET A.AuthorisationStatus= C.AuthorisationStatus
				FROM #PreCaseCustData A
				INNER JOIN(
							SELECT D.AuthorisationStatus,A.Ac_Key,A.AccountEntityId,A.CustomerEntityId  FROM AdvAcBasicDetail_mod A
							INNER JOIN(SELECT MAX(A.Ac_Key)Ac_Key FROM AdvAcBasicDetail_mod A
								WHERE (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
							     AND A.AuthorisationStatus IN ('NP','MP','DP','RM')
								 GROUP BY A.AccountEntityId
						
									 ) B  ON B.Ac_Key=A.Ac_Key AND 
									 (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
                   
							  INNER JOIN (
					
											 SELECT A.AuthorisationStatus,A.EntityKey,A.AccountEntityId  FROM AdvFacDLDetail_Mod A
											  INNER JOIN(SELECT MAX(A.EntityKey)EntityKey FROM AdvFacDLDetail_Mod A
											 WHERE (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
											 AND A.AuthorisationStatus IN ('NP','MP','DP','RM')
												 GROUP BY A.AccountEntityId
						
															 ) B  ON B.EntityKey=A.EntityKey AND 
														 (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
								
											 )D   ON D.AccountEntityId=A.AccountEntityId	
									
						 ) C  ON 	C.CustomerEntityId=A.CustomerEntityId



						 
				UPDATE A
				SET A.AuthorisationStatus= C.AuthorisationStatus
				FROM #PreCaseCustData A
				INNER JOIN(
							SELECT D.AuthorisationStatus,A.Ac_Key,A.AccountEntityId,A.CustomerEntityId  FROM AdvAcBasicDetail_mod A
							INNER JOIN(SELECT MAX(A.Ac_Key)Ac_Key FROM AdvAcBasicDetail_mod A
								WHERE (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
							     AND A.AuthorisationStatus IN ('NP','MP','DP','RM')
								 GROUP BY A.AccountEntityId
						
									 ) B  ON B.Ac_Key=A.Ac_Key AND 
									 (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
                   
							  INNER JOIN (
					
											 SELECT A.AuthorisationStatus,A.EntityKey,A.AccountEntityId  FROM AdvFacNFDetail_mod A
											  INNER JOIN(SELECT MAX(A.EntityKey)EntityKey FROM AdvFacNFDetail_mod A
											 WHERE (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
											 AND A.AuthorisationStatus IN ('NP','MP','DP','RM')
												 GROUP BY A.AccountEntityId
						
															 ) B  ON B.EntityKey=A.EntityKey AND 
														 (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
								
											 )D   ON D.AccountEntityId=A.AccountEntityId	
									
						 ) C  ON 	C.CustomerEntityId=A.CustomerEntityId




				UPDATE A
				SET A.AuthorisationStatus= C.AuthorisationStatus
				FROM #PreCaseCustData A
				INNER JOIN(
							SELECT D.AuthorisationStatus,A.Ac_Key,A.AccountEntityId,A.CustomerEntityId  FROM AdvAcBasicDetail_mod A
							INNER JOIN(SELECT MAX(A.Ac_Key)Ac_Key FROM AdvAcBasicDetail_mod A
								WHERE (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
							     AND A.AuthorisationStatus IN ('NP','MP','DP','RM')
								 GROUP BY A.AccountEntityId
						
									 ) B  ON B.Ac_Key=A.Ac_Key AND 
									 (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
                   
							  INNER JOIN (
					
											 SELECT A.AuthorisationStatus,A.EntityKey,A.AccountEntityId  FROM AdvFacPCDetail_Mod A
											  INNER JOIN(SELECT MAX(A.EntityKey)EntityKey FROM AdvFacPCDetail_Mod A
											 WHERE (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
											 AND A.AuthorisationStatus IN ('NP','MP','DP','RM')
												 GROUP BY A.AccountEntityId
						
															 ) B  ON B.EntityKey=A.EntityKey AND 
														 (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
								
											 )D   ON D.AccountEntityId=A.AccountEntityId	
									
						 ) C  ON 	C.CustomerEntityId=A.CustomerEntityId


    

				UPDATE A
				SET A.AuthorisationStatus= C.AuthorisationStatus
				FROM #PreCaseCustData A
				INNER JOIN(
				SELECT A.AuthorisationStatus,A.EntityKey,A.CustomerEntityId  FROM AdvSecurityVehicleDetails_Mod A
				INNER JOIN(SELECT MAX(A.EntityKey)EntityKey FROM AdvSecurityVehicleDetails_Mod A
				            WHERE (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
							     AND A.AuthorisationStatus IN ('NP','MP','DP','RM')
								 GROUP BY A.CustomerEntityId
						
				               ) B  ON B.EntityKey=A.EntityKey AND 
							   (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)

						  ) C  ON 	C.CustomerEntityId=A.CustomerEntityId


				--UPDATE A
				--SET A.AuthorisationStatus= C.AuthorisationStatus
				--FROM #PreCaseCustData A
				--INNER JOIN(
				--SELECT A.AuthorisationStatus,A.EntityKey,A.CustomerEntityId  FROM AdvSecurityValueDetail_Mod A
				--INNER JOIN(SELECT MAX(A.EntityKey)EntityKey FROM AdvSecurityValueDetail_Mod A
				--            WHERE (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
				--			     AND A.AuthorisationStatus IN ('NP','MP','DP','RM')
				--				 GROUP BY A.CustomerEntityId
						
				--               ) B  ON B.EntityKey=A.EntityKey AND 
				--			   (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)

				--		  ) C  ON 	C.CustomerEntityId=A.CustomerEntityId


				
				UPDATE A
				SET A.AuthorisationStatus= C.AuthorisationStatus
				FROM #PreCaseCustData A
				INNER JOIN(
				SELECT A.AuthorisationStatus,A.EntityKey,A.CustomerEntityId  FROM AdvSecuritiesPropertyDetails_MOD A
				INNER JOIN(SELECT MAX(A.EntityKey)EntityKey FROM AdvSecuritiesPropertyDetails_MOD A
				            WHERE (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
							     AND A.AuthorisationStatus IN ('NP','MP','DP','RM')
								 GROUP BY A.CustomerEntityId
						
				               ) B  ON B.EntityKey=A.EntityKey AND 
							   (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)

						  ) C  ON 	C.CustomerEntityId=A.CustomerEntityId





				UPDATE A
				SET A.AuthorisationStatus= C.AuthorisationStatus
				FROM #PreCaseCustData A
				INNER JOIN(
				SELECT A.AuthorisationStatus,A.EntityKey,A.CustomerEntityId  FROM AdvAcRelations_Mod A
				INNER JOIN(SELECT MAX(A.EntityKey)EntityKey FROM AdvAcRelations_Mod A
				            WHERE (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
							     AND A.AuthorisationStatus IN ('NP','MP','DP','RM')
								 GROUP BY A.RelationEntityId
						
				               ) B  ON B.EntityKey=A.EntityKey AND 
							   (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)

						  ) C  ON 	C.CustomerEntityId=A.CustomerEntityId

		
				IF @BranchCode=''
					BEGIN
						UPDATE  T
								SET  T.BranchCode= CASE WHEN T.BranchCode IS NULL THEN  a.BranchCode ELSE T.BranchCode END
								   ,T.BranchName=DB.BranchName
							FROM  #PreCaseCustData T
								INNER JOIN (

											SELECT A.CustomerEntityID, A.BranchCode FROM curdat.AdvAcBasicDetail a
												INNER JOIN #PreCaseCustData T
													ON A.CustomerEntityId=T.CustomerEntityID
													OR A.BranchCode=T.BranchCode
												WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND ISNULL(A.AuthorisationStatus,'A')='A'	
													GROUP BY A.CustomerEntityID, A.BranchCode
											UNION


										SELECT A.CustomerEntityID,A.BranchCode FROM AdvAcBasicDetail_Mod A  
										INNER JOIN(SELECT MAX(Ac_Key)Ac_Key FROM AdvAcBasicDetail_Mod A
												   WHERE (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
														AND A.CustomerACID=@CustomerAcID
														AND AuthorisationStatus IN ('NP','MP','DP','RM')
														GROUP BY A.CustomerACID 
													)P  ON P.Ac_Key=A.Ac_Key AND (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
											INNER JOIN #PreCaseCustData T
													ON A.CustomerEntityId=T.CustomerEntityID
													OR A.BranchCode=T.BranchCode
										
											) A 
											ON A.CustomerEntityId=T.CustomerEntityID

										INNER JOIN DimBranch  DB ON 
												(DB.EffectiveFromTimeKey<=@TimeKey AND DB.EffectiveToTimeKey>=@TimeKey)
												AND DB.BranchCode=CASE WHEN T.BranchCode IS NULL THEN  a.BranchCode ELSE T.BranchCode END

						END


SELECT @Location=ISNULL(UserLocation,''),@LocatationCode=ISNULL(UserLocationCode,'') FROM DimUserInfo  WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
	AND  UserLoginID=@UserLoginID

	IF OBJECT_ID('Tempdb..#TempBrData') IS NOT NULL 
		DROP TABLE #TempBrData

	CREATE TABLE #TempBrData (BranchCode VARCHAR(10))

	INSERT INTO #TempBrData
	SELECT BranchCode from DimBranch A
	WHERE (EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey)
	AND @LocatationCode= CASE WHEN @Location='HO' THEN @LocatationCode 
							  WHEN @Location='ZO' THEN cast(A.BranchZoneAlt_Key		 AS  VARCHAR(100))
							  WHEN @Location='RO' THEN cast(A.BranchRegionAlt_Key	 AS  VARCHAR(100))
							  WHEN @Location='BO' THEN cast(A.BranchCode			 AS  VARCHAR(100))
						  END


--*******************************************************************************************************************
--FOR MOC FREEZE Branch Not come in Select Clause For Moc Timekey 
--Added By Hamid On 31 MAY 2018
--*******************************************************************************************************************
DROP TABLE IF EXISTS #BRANCH
CREATE TABLE #BRANCH(BranchCode VARCHAR(20))
IF EXISTS (SELECT 1 FROM SysDataMatrix WHERE Prev_Qtr_key = @Timekey )
BEGIN
	INSERT INTO #BRANCH
	SELECT BranchCode FROM FactBranch_Moc WHERE TimeKey = @Timekey AND ISNULL(ZO_MOC_Frozen,'N')='Y'
END

--*******************************************************************************************************************
SELECT a.*,ISNULL(IsCaseFiled,'N')  IsCaseFiled FROM 	#PreCaseCustData A
					LEFT JOIN (SELECT CustomerEntityId,'Y' IsCaseFiled FROM  SysDataUpdationStatus  GROUP BY CustomerEntityId)
								t ON a.CustomerEntityID=t.CustomerEntityId
				WHERE A.BranchCode IS NULL		
				AND NOT EXISTS (SELECT B.BranchCode FROM #BRANCH  B WHERE A.BranchCode =B.BranchCode )		
	UNION 

SELECT a.*,ISNULL(IsCaseFiled,'N')  IsCaseFiled FROM 	#PreCaseCustData A

	LEFT JOIN (SELECT CustomerEntityId,'Y' IsCaseFiled FROM  SysDataUpdationStatus  GROUP BY CustomerEntityId)
				t ON a.CustomerEntityID=t.CustomerEntityId
	LEFT JOIN #TempBrData  BR  ON  BR.BranchCode=A.BranchCode	
									
	WHERE ISNULL(A.BranchCode,'')=CASE WHEN @BranchCode<>'' THEN @BranchCode ELSE A.BranchCode END
			AND  A.BranchCode IS NOT NULL
			AND (ISNULL(A.BranchName,'') =  CASE WHEN @BranchName<>'' THEN @BranchName ELSE ISNULL(A.BranchName,'') END)
			AND NOT EXISTS (SELECT B.BranchCode FROM #BRANCH  B WHERE A.BranchCode =B.BranchCode )	


	

	


					







GO