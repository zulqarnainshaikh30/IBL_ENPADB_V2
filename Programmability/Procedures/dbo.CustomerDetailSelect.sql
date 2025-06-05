SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--exec CustomerDetailSelect @CustomerEntityId=601,@CustType=N'',@TimeKey=25999,@BranchCode=N'0',@OperationFlag=2
--go



--Sp_helptext CustomerDetailSelect


-------------------------------------------------------------------------------------------------------------




---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>

--exec [CustomerDetailSelect]  @CustomerEntityID =1001190 	,@TimeKey	=49999	,@BranchCode ='',@OperationFlag =16
-- =============================================
CREATE PROCEDURE [dbo].[CustomerDetailSelect]

--DECLARE
	 @CustomerEntityID INT=0
	,@TimeKey	INT=49999
	,@BranchCode VARCHAR(10)=''
	,@OperationFlag TINYINT=0
	,@CustType		varchar(20)=''

AS


BEGIN
	SET NOCOUNT ON;
	--UPDATE CustomerBasicDetail SET CustType = 'Borrower' WHERE CustType IS NULL
	/*-- CREATE TABP TABLE FOR SELECT THE DATA*/
	IF OBJECT_ID('Tempdb..CustomerDetailSelect') IS NOT NULL
		DROP TABLE #CustomerDetailSelect
print 'akshay'
	CREATE TABLE #CustomerDetailSelect
				(
								 --,BorrowerGroupAlt_key         INT
				  --,LEI							varchar(500)

					CustomerEntityId			INT,
					CustomerID					VARCHAR (20),
					UCIF_ID					VARCHAR (20),
					ConstitutionAlt_Key			VARCHAR(100),				--SMALLINT,
					CustSalutationAlt_Key		SMALLINT,
					CustomerName				VARCHAR(80),
					ParentBranchCode			VARCHAR(10),
					CustomerSinceDt				VARCHAR(10),
					ReligionAlt_Key				SMALLINT,
					CasteAlt_Key				SMALLINT,
					OccupationAlt_Key			SMALLINT,      
					CurrentAssetClassAlt_Key	VARCHAR(100),				--SMALLINT,	
					FCRA_YN                     CHAR,
					NPA_Date					VARCHAR(10),
					SMADate                     VARCHAR(10),
					SMAStatus                   VARCHAR(10),
					DbtDt						VARCHAR(10),
					IsPetitioner				CHAR(1),
					SplCatg1Alt_Key			    SMALLINT,
					SplCatg2Alt_Key			    SMALLINT,
					SplCatg3Alt_Key			    SMALLINT,
					SplCatg4Alt_Key			    SMALLINT,
					FarmerCatAlt_Key			SMALLINT,
							
					IsEmployee					CHAR(1),
					PAN							VARCHAR(10),
					VoterID						VARCHAR(30),				
					AadharNo					VARCHAR(30),				
					NPR_Id						VARCHAR(30),				
					PassportNo					VARCHAR(30),				
					PassportIssueDate			VARCHAR(10),				
					PassportExpDate				VARCHAR(10),				
					PassportIssueLocation		VARCHAR(50),				
					DL_No						VARCHAR(30),				
					DL_IssueDate				VARCHAR(10),				
					DL_ExpDate					VARCHAR(10),				
					DL_IssueLocation			VARCHAR(50),				
					RationCardNo				VARCHAR(30),				
					OtherIdType					VARCHAR(30),				
					OtherIdNo					VARCHAR(30),				
					TAN							VARCHAR(30),				
					TIN							VARCHAR(30),				
					DIN							VARCHAR(30),				
					CIN							VARCHAR(30),				
					RegistrationNo			    VARCHAR(30),
					PinCode						varchar(10),
					STD_Code_Res				varchar(10),
					PhoneNo_Res					varchar(26),
					STD_Code_Off				varchar(10),
					PhoneNo_Off					varchar(26),
					FaxNo						varchar(26),
					CityAlt_Key					smallint,
					CityName					varchar(60),
					DistrictAlt_Key				smallint,
					DistrictName				varchar(60),
					CountryAlt_Key				smallint,
					CountryName					varchar(60),
				------
					CreateModifyBy				VARCHAR(20),
					IsMainTable					CHAR(1),

				   StaffAccountability          CHAR(1),
				   WillfulDefault               CHAR(1),
				   WillfulDefaultReasonAlt_Key  smallint,
				   WillfulRemark                varchar(100),
				   LegalActionProposed          varchar(50),      ---PermiNatureID
				   UnderLitigation              CHAR(1),
				   --PermiNatureID			    smallint,  --Triloki Added 23/02/2017
				   BorrUnitFunct                varchar(50),
				   DtofClosure                  varchar(10),
				   NonCoopBorrower              char(1),
				   ArbiAgreement                char(1),
				   TransThroughUs               char(1),
				   CutBackArrangement           char(1),
				   BankingArrangement           varchar(2),
				   MemberBanksNo                smallint,
				   TotalConsortiumAmt           decimal(18,2),
 				   ROC_CFCReportDate            varchar(10),
				   ROC_ChargeFV                 Char(1),
				   ROC_ChargeFVDt               varchar(10),
				   ROC_ChargeRemark             varchar(1000),
				   ChargeFiledwithROCRemark2   varchar(1000),
				   ROC_Cover                     varchar(1),
				   ROCCoveredCertificateDate     varchar(10),
				   ChargeFiledWith varchar(2),
				   FiledDt varchar(10),
				   EmployeeID                   varchar(20),
				   EmployeeType                 SMALLINT,
				   Designation                  NVARCHAR(50),
				   Placeofposting               nvarchar(100),
				   LPersonalConDate             varchar(10),
				   LPersonalConDtls             varchar(100),
				   RecallNoticeDate             Varchar(10),
				   RecallNoticeModeID           varchar(20),
				   LegalAuditDate               Varchar(10),
				   IrregularityPending         varchar(2),
				   IrregularityRectiDate       Varchar(10),
				   FraudAccoStatus           char(1),
				   Add1                      Varchar(100),
				   Add2                      Varchar(100),
				   Add3                      varchar(100),
				   AddressTypeAlt_Key         int,
				   AddressCategoryAlt_Key    int,
				   MobileNo                  Varchar(10),
				   EmailId                   varchar(100),
				   GuardianType              Varchar(50),
				   GaurdianSalutationAlt_Key smallint,
				   GuardianName              varchar(50),
				   Userlocation				  varchar(50),
				   AuthorisationStatus          char(2)
				  ,CustType                    varchar(20)
				  ,ServProviderAlt_Key         SMALLINT
				  ,NonCustTypeAlt_Key          SMALLINT
				  ,GradeScaleAlt_Key			SMALLINT
				  ,Grade						varchar(10)
				  ,ServProvider					varchar(20)
				  ,NonCustType					VARCHAR(20)
				  ,WillfulDefaultDate			varchar(10)
				  ,FMRNO						varchar(50)
				  ,FMRDate                     varchar(10)
				  ,Remark					   varchar(100)	
				  --,DefaultReason1Alt_Key		smallint
				  --,DefaultReason2Alt_Key       smallint
				  ,NPA_Reason					varchar(1000)
				  ,FraudNatureRemark			varchar(1000)
				   ,BorrowerGroupAlt_key         INT
				  ,LEI							varchar(500)
				  ,RelationEntityId				INT
				  ,RelationADDEntityId				INT
				,EffectiveFromTimeKey            INT
				,AlwaysSTDNPAStatus				Varchar(20)
				,SourceSystemAlt_Key            Varchar(50)				
				,SecurityValue					int
				,LosDt                          VARCHAR(10)
				)
	--select * from #CustomerDetailSelect
			/*--DECLARE VARIABLE FOR SET THE MAKER CHECKER FLAG TABLE WISE--*/
			Print 1
			DECLARE   @CustBasic CHAR(1)='N',@CustFin CHAR(1)='N', @CustNonFin Char(1)='N', @CustOth char(1)='N', @CustNPA CHAR(1)='N', @CustRel char(1)='N',@CustComm char(1)='N',@Profession char(1)='N'
					 ,@CustBasicCrMod VARCHAR(20)='',@CustFinCrMod VARCHAR(20)='', @CustNonFinCrMod VARCHAR(20)='', @CustOthCrMod VARCHAR(20)='', @CustNPACrMod VARCHAR(20)='', @CustRelCrMod VARCHAR(20)='',@CustCommCrMod VARCHAR(20)='',@ProfessionalMod char(1)

				SELECT TOP(1) @CustBasic	='Y',  @CustBasicCrMod	=ISNULL(C.ModifiedBy,C.CreatedBy) FROM CustomerBasicDetail_Mod  C
				INNER JOIN(
				              SELECT MAX(C.Customer_Key)Customer_Key FROM CustomerBasicDetail_Mod C
							  WHERE (C.EffectiveFromTimeKey<=@TimeKey and C.EffectiveToTimeKey>=@TimeKey)
							        AND C.CustomerEntityID=@CustomerEntityID AND C.AuthorisationStatus IN('NP','MP','DP','RM')
									GROUP BY C.CustomerEntityId
						   )A   ON A.Customer_Key=C.Customer_Key
						        AND (C.EffectiveFromTimeKey<=@TimeKey and C.EffectiveToTimeKey>=@TimeKey)	
								AND (C.AuthorisationStatus IN('NP','MP','DP','RM'))	
								AND C.CustomerEntityId=@CustomerEntityID			
				

				SELECT TOP(1) @CustFin	='Y',  @CustFinCrMod	=ISNULL(C.ModifiedBy,C.CreatedBy) FROM AdvCustFinancialDetail_Mod  C
				INNER JOIN(
				              SELECT MAX(C.EntityKey)EntityKey FROM AdvCustFinancialDetail_Mod C
							  WHERE (C.EffectiveFromTimeKey<=@TimeKey and C.EffectiveToTimeKey>=@TimeKey)
							        AND C.CustomerEntityID=@CustomerEntityID AND C.AuthorisationStatus IN('NP','MP','DP','RM')
									GROUP BY C.CustomerEntityId
						   )A   ON A.EntityKey=C.EntityKey
						        AND (C.EffectiveFromTimeKey<=@TimeKey and C.EffectiveToTimeKey>=@TimeKey)	
								AND (C.AuthorisationStatus IN('NP','MP','DP','RM'))	
								AND C.CustomerEntityId=@CustomerEntityID

print 'akshay'

				SELECT TOP(1) @CustNonFin	='Y',  @CustNonFinCrMod	=ISNULL(C.ModifiedBy,C.CreatedBy) FROM AdvCustNonFinancialDetail_Mod  C
				INNER JOIN(
				              SELECT MAX(C.EntityKey)EntityKey FROM AdvCustNonFinancialDetail_Mod C
							  WHERE (C.EffectiveFromTimeKey<=@TimeKey and C.EffectiveToTimeKey>=@TimeKey)
							        AND C.CustomerEntityID=@CustomerEntityID AND C.AuthorisationStatus IN('NP','MP','DP','RM')
									GROUP BY C.CustomerEntityId
						   )A   ON A.EntityKey=C.EntityKey
						        AND (C.EffectiveFromTimeKey<=@TimeKey and C.EffectiveToTimeKey>=@TimeKey)	
								AND (C.AuthorisationStatus IN('NP','MP','DP','RM'))	
								AND C.CustomerEntityId=@CustomerEntityID


				SELECT TOP(1) @CustOth	='Y',  @CustOthCrMod	=ISNULL(C.ModifiedBy,C.CreatedBy) FROM AdvCustOtherDetail_Mod  C
				INNER JOIN(
				              SELECT MAX(C.EntityKey)EntityKey FROM AdvCustOtherDetail_Mod C
							  WHERE (C.EffectiveFromTimeKey<=@TimeKey and C.EffectiveToTimeKey>=@TimeKey)
							        AND C.CustomerEntityID=@CustomerEntityID AND C.AuthorisationStatus IN('NP','MP','DP','RM')
									GROUP BY C.CustomerEntityId
						   )A   ON A.EntityKey=C.EntityKey
						        AND (C.EffectiveFromTimeKey<=@TimeKey and C.EffectiveToTimeKey>=@TimeKey)	
								AND (C.AuthorisationStatus IN('NP','MP','DP','RM'))	
								AND C.CustomerEntityId=@CustomerEntityID

				SELECT TOP(1) @CustNPA	='Y',  @CustNPACrMod	=ISNULL(C.ModifiedBy,C.CreatedBy) FROM AdvCustNPADetail_Mod  C
				INNER JOIN(
				              SELECT MAX(C.EntityKey)EntityKey FROM AdvCustNPADetail_Mod C
							  WHERE (C.EffectiveFromTimeKey<=@TimeKey and C.EffectiveToTimeKey>=@TimeKey)
							        AND C.CustomerEntityID=@CustomerEntityID AND C.AuthorisationStatus IN('NP','MP','DP','RM')
									GROUP BY C.CustomerEntityId
						   )A   ON A.EntityKey=C.EntityKey
						        AND (C.EffectiveFromTimeKey<=@TimeKey and C.EffectiveToTimeKey>=@TimeKey)	
								AND (C.AuthorisationStatus IN('NP','MP','DP','RM'))	
								AND C.CustomerEntityId=@CustomerEntityID

				SELECT TOP(1) @CustRel	='Y',  @CustRelCrMod	=ISNULL(C.ModifiedBy,C.CreatedBy) FROM AdvCustRelationship_Mod  C
				INNER JOIN(
				              SELECT MAX(C.EntityKey)EntityKey FROM AdvCustRelationship_Mod C
							  WHERE (C.EffectiveFromTimeKey<=@TimeKey and C.EffectiveToTimeKey>=@TimeKey)
							        AND C.CustomerEntityID=@CustomerEntityID AND C.AuthorisationStatus IN('NP','MP','DP','RM')
									GROUP BY C.CustomerEntityId
						   )A   ON A.EntityKey=C.EntityKey
						        AND (C.EffectiveFromTimeKey<=@TimeKey and C.EffectiveToTimeKey>=@TimeKey)	
								AND (C.AuthorisationStatus IN('NP','MP','DP','RM'))	
								AND C.CustomerEntityId=@CustomerEntityID

				SELECT TOP(1) @CustComm	='Y',  @CustCommCrMod	=ISNULL(C.ModifiedBy,C.CreatedBy) FROM AdvCustCommunicationDetail_Mod  C
				INNER JOIN(
				              SELECT MAX(C.EntityKey)EntityKey FROM AdvCustCommunicationDetail_Mod C
							  WHERE (C.EffectiveFromTimeKey<=@TimeKey and C.EffectiveToTimeKey>=@TimeKey)
							        AND C.CustomerEntityID=@CustomerEntityID AND C.AuthorisationStatus IN('NP','MP','DP','RM')
									GROUP BY C.CustomerEntityId
						   )A   ON A.EntityKey=C.EntityKey
						        AND (C.EffectiveFromTimeKey<=@TimeKey and C.EffectiveToTimeKey>=@TimeKey)	
								AND (C.AuthorisationStatus IN('NP','MP','DP','RM'))	
								AND C.CustomerEntityId=@CustomerEntityId

			 ----SELECT 	@CustComm,	@CustRel,	@CustNPA	,@CustOth	,@CustNonFin	,@CustFin  ,@CustBasic

		/*	CUSTOMER BASICDETAIL  */
				--SELECT * FROM #CustomerDetailSelect
		Print 2
				IF @CustBasic='N' OR @OperationFlag<>16	-- FROM MAIN TABLE
					BEGIN
					PRINT 1
						INSERT INTO #CustomerDetailSelect ( CustomerEntityId, CustomerID,UCIF_ID, Remark,ConstitutionAlt_Key, CustSalutationAlt_Key, CustomerName, ParentBranchCode, 
						CustomerSinceDt, ReligionAlt_Key, CasteAlt_Key, OccupationAlt_Key,FarmerCatAlt_Key,CurrentAssetClassAlt_Key,AuthorisationStatus,AlwaysSTDNPAStatus,SourceSystemAlt_Key--Sachin
						,SMADate,SMAStatus,SecurityValue
						)
													
												SELECT C.CustomerEntityId, C.CustomerID,C.UCIF_ID,C.Remark,DC.ConstitutionName, C.CustSalutationAlt_Key, C.CustomerName, C.ParentBranchCode  --, CONVERT(VARCHAR(10),C.CustomerSinceDt,103)
												,CustomerSinceDt
												--, CONVERT(VARCHAR(10),C.CustomerSinceDt,103)
												,NULLIF(C.ReligionAlt_Key,97), NULLIF(C.CasteAlt_Key,97), NULLIF(C.OccupationAlt_Key,111)CustomerSinceDt
												,NULLIF(C.FarmerCatAlt_Key,97)
												--,ISNULL(C.AssetClass,1)
												,ISNULL(DA.AssetClassName,'STANDARD') AS CurrentAssetClassAlt_Key
												,C.AuthorisationStatus,C.AssetClass,DS.SourceName --Sachin
												,SMA_Dt,(CASE WHEN CustMoveDescription not like '%SMA%' THEN '' ELSE CustMoveDescription END),CurntQtrRv
						FROM CURDAT.CustomerBasicDetail C
						LEFT JOIN CURDAT.AdvCustNPADetail AC ON AC.CustomerEntityId=C.CustomerEntityId
						AND AC.EffectiveFromTimeKey<=@TimeKey and AC.EffectiveToTimeKey>=@TimeKey
						LEFT JOIN DIMCONSTITUTION DC ON DC.ConstitutionAlt_Key=C.ConstitutionAlt_Key
						AND DC.EffectiveFromTimeKey<=@TimeKey and DC.EffectiveToTimeKey>=@TimeKey
						LEFT JOIN DimAssetClass DA ON DA.AssetClassAlt_Key=AC.Cust_AssetClassAlt_Key
                        LEFT JOIN DIMSOURCEDB DS ON C.SourceSystemAlt_Key=DS.SourceAlt_Key       --Sachin  
						AND DS.EffectiveFromTimeKey<=@TimeKey and DS.EffectiveToTimeKey>=@TimeKey  --Sachin  
						LEFT JOIN Pro.Customercal_Hist CHist ON C.CustomerEntityId = CHist.CustomerEntityID
						AND CHist.EffectiveFromTimeKey<=@TimeKey and CHist.EffectiveToTimeKey>=@TimeKey 
						--LEFT JOIN dbo.DimMiscSuit M   ON (M.EffectiveFromTimeKey<=@TimeKey and M.EffectiveToTimeKey>=@TimeKey) AND M.LegalMiscSuitAlt_Key=C.NonCustTypeAlt_Key
						--LEFT JOIN dbo.DimLegalNatureOfActivity N ON (N.EffectiveFromTimeKey<=@TimeKey and N.EffectiveToTimeKey>=@TimeKey) AND N.LegalNatureOfActivityAlt_Key=C.ServProviderAlt_Key
						WHERE (C.EffectiveFromTimeKey<=@TimeKey and C.EffectiveToTimeKey>=@TimeKey) AND C.CustomerEntityID=@CustomerEntityID AND ISNULL(C.AuthorisationStatus,'A')='A' 						
					        
						
					END
					--SELECT * FROM #CustomerDetailSelect
					print 'akshay1'
				IF @CustBasic='Y' OR @OperationFlag=16-- FROM MOD TABLE
					BEGIN
					print 'akshay2'
					PRINT 1
						INSERT INTO #CustomerDetailSelect ( CustomerEntityId, CustomerID,UCIF_ID,Remark,ConstitutionAlt_Key, EffectiveFromTimeKey,CustSalutationAlt_Key, CustomerName, 
						ParentBranchCode, CustomerSinceDt, ReligionAlt_Key, CasteAlt_Key, OccupationAlt_Key, FarmerCatAlt_Key,CurrentAssetClassAlt_Key,GuardianType,
						GaurdianSalutationAlt_Key,AuthorisationStatus,AlwaysSTDNPAStatus, SourceSystemAlt_Key--Sachin,
						,SMADate,SMAStatus,SecurityValue
						--,CustType,ServProviderAlt_Key,NonCustTypeAlt_Key,ServProvider,NonCustType
						)
						                                  								
												SELECT		C.CustomerEntityId, C.CustomerID,C.UCIF_ID,C.Remark,DC.ConstitutionName,C.EffectiveFromTimeKey, C.CustSalutationAlt_Key, C.CustomerName, C.ParentBranchCode 
												--, CONVERT(VARCHAR(10),C.CustomerSinceDt,103)
												,CustomerSinceDt
												 ,NULLIF(C.ReligionAlt_Key,97), NULLIF(C.CasteAlt_Key,97),NULLIF(C.OccupationAlt_Key,111),NULLIF(C.FarmerCatAlt_Key,97),
												 --C.AssetClass
												 --DA.AssetClassName CurrentAssetClassAlt_Key
												 ISNULL(DA.AssetClassName,'STANDARD') AS CurrentAssetClassAlt_Key
												 ,C.GuardianType,C.GaurdianSalutationAlt_Key,C.AuthorisationStatus,C.AssetClass,DS.SourceName --Sachin
												 --,C.CustType,C.ServProviderAlt_Key,C.NonCustTypeAlt_Key,N.LegalNatureOfActivityName,M.LegalMiscSuitName
												     ,SMA_Dt,(CASE WHEN CustMoveDescription not like '%SMA%' THEN '' ELSE CustMoveDescription END),CurntQtrRv      
						FROM CustomerBasicDetail_Mod C
						LEFT JOIN CURDAT.AdvCustNPADetail AC ON AC.CustomerEntityId=C.CustomerEntityId
						AND AC.EffectiveFromTimeKey<=@TimeKey and AC.EffectiveToTimeKey>=@TimeKey
						LEFT JOIN DIMCONSTITUTION DC ON DC.ConstitutionAlt_Key=C.ConstitutionAlt_Key
						AND DC.EffectiveFromTimeKey<=@TimeKey and DC.EffectiveToTimeKey>=@TimeKey
						LEFT JOIN DimAssetClass DA ON DA.AssetClassAlt_Key=AC.Cust_AssetClassAlt_Key
						INNER JOIN(
				              SELECT MAX(C.Customer_Key)Customer_Key FROM CustomerBasicDetail_Mod C
							  WHERE (C.EffectiveFromTimeKey<=@TimeKey and C.EffectiveToTimeKey>=@TimeKey)
							        AND C.CustomerEntityID=@CustomerEntityID AND C.AuthorisationStatus IN('NP','MP','DP','RM')
									 --AND CustType=@CustType	
									GROUP BY C.CustomerEntityId
						   )A   ON A.Customer_Key=C.Customer_Key
						        AND (C.EffectiveFromTimeKey<=@TimeKey and C.EffectiveToTimeKey>=@TimeKey)	
								AND (C.AuthorisationStatus IN('NP','MP','DP','RM'))	
								AND C.CustomerEntityId=@CustomerEntityID	
                          LEFT JOIN DIMSOURCEDB DS ON C.SourceSystemAlt_Key=DS.SourceAlt_Key --Sachin
						  AND DS.EffectiveFromTimeKey<=@TimeKey and DS.EffectiveToTimeKey>=@TimeKey  --Sachin 
						  LEFT JOIN Pro.Customercal_Hist CHist ON C.CustomerEntityId = CHist.CustomerEntityID
						AND CHist.EffectiveFromTimeKey<=@TimeKey and CHist.EffectiveToTimeKey>=@TimeKey
						--LEFT JOIN dbo.DimMiscSuit M   ON (M.EffectiveFromTimeKey<=@TimeKey and M.EffectiveToTimeKey>=@TimeKey) AND M.LegalMiscSuitAlt_Key=C.NonCustTypeAlt_Key
						--LEFT JOIN dbo.DimLegalNatureOfActivity N ON (N.EffectiveFromTimeKey<=@TimeKey and N.EffectiveToTimeKey>=@TimeKey) 
						--AND N.LegalNatureOfActivityAlt_Key=C.ServProviderAlt_Key			
					 					
					END
				--SELECT * FROM #CustomerDetailSelect
		/*	CUST FINANCIAL DETAIL */
		Print 3
				IF @CustFin='N' OR @OperationFlag<>16 -- FROM MAIN TABLE
					BEGIN
					PRINT 22222
						UPDATE T SET 
							--T.CurrentAssetClassAlt_Key=C.Cust_AssetClassAlt_Key,
							
							T.Userlocation=DU.UserLocation
							,T.AuthorisationStatus=C.AuthorisationStatus
							
						FROM #CustomerDetailSelect T
							INNER JOIN curdat.AdvCustFinancialDetail C
								ON (C.EffectiveFromTimeKey<=@TimeKey and C.EffectiveToTimeKey>=@TimeKey)
								AND T.CustomerEntityId=C.CustomerEntityId
								AND BranchCode=@BranchCode
								AND ISNULL(C.AuthorisationStatus,'A')='A'
						LEFT JOIN  DimUserInfo  DU  ON DU.UserLoginID=@CustFinCrMod		
					END
				IF @CustFin='Y' OR @OperationFlag=16-- FROM MOD TABLE
					BEGIN
					PRINT 23333
						UPDATE T SET 
							--T.CurrentAssetClassAlt_Key=C.Cust_AssetClassAlt_Key,
							T.Userlocation=DU.UserLocation
							,T.AuthorisationStatus=C.AuthorisationStatus
						
						FROM #CustomerDetailSelect T
						INNER JOIN (
						               SELECT C.Cust_AssetClassAlt_Key,C.CustomerEntityId,C.AuthorisationStatus,C.CreatedBy,C.ModifiedBy FROM AdvCustFinancialDetail_Mod C
									   INNER JOIN(
									                 SELECT MAX(C.EntityKey) EntityKey FROM AdvCustFinancialDetail_Mod C
													 WHERE (C.EffectiveFromTimeKey<=@TimeKey and C.EffectiveToTimeKey>=@TimeKey)
													 AND  C.AuthorisationStatus in('NP','MP','DP','RM')
													 AND C.CustomerEntityId=@CustomerEntityID
													 AND C.BranchCode=@BranchCode
													 GROUP BY  C.CustomerEntityId
									   )A   ON A.EntityKey=C.EntityKey
									       AND (C.EffectiveFromTimeKey<=@TimeKey and C.EffectiveToTimeKey>=@TimeKey)
										   AND C.AuthorisationStatus IN('NP','MP','DP','RM')
										   AND C.CustomerEntityId=@CustomerEntityID
										   AND C.BranchCode=@BranchCode
						)C   ON T.CustomerEntityId=C.CustomerEntityId
						LEFT JOIN  DimUserInfo  DU  ON DU.UserLoginID=@CustFinCrMod		
						   
		
					END
		

		/* ProfessionalDetail */


		

		/*	CUST NPA DETAIL */
		Print 4
				IF @CustNPA='N' OR @OperationFlag<>16 -- FROM MAIN TABLE
					BEGIN
					   PRINT 22222222
						UPDATE T SET 
							--T.CurrentAssetClassAlt_Key=C.Cust_AssetClassAlt_Key,
							--T.FCRA_YN=C.FCRA_YN,
							
							T.NPA_Date=convert(varchar(10),C.NPADt,103),
							T.SMADate=convert(varchar(10),S.SMA_Dt,103),
					       T.SMAStatus=S.SMA_Class,
					 		
							T.DbtDt =isnull(convert(varchar(10),C.DbtDt,103),convert(varchar(10),C.Losdt,103))
							
					--T.DbtDt= ( CASE
					--      WHEN convert(varchar(10),C.LosDt,103) IS NULL THEN convert(varchar(10),C.DbtDt,103)
					--	  WHEN convert(varchar(10),C.DbtDt,103) IS NULL THEN convert(varchar(10),C.LosDt,103)
					--	  ELSE 
					--	  0
					--	  END )

							,T.StaffAccountability = C.StaffAccountability
							--T.WillfulDefault=C.WillfulDefault,
							--T.WillfulDefaultReasonAlt_Key=C.WillfulDefaultReasonAlt_Key,
							--T.WillfulRemark=C.WillfulRemark	,
							,T.Userlocation=DU.UserLocation
							,T.AuthorisationStatus=C.AuthorisationStatus
							--,T.WillfulDefaultDate=CONVERT(VARCHAR(10),C.WillfulDefaultDate,103)
							--,T.DefaultReason1Alt_Key=C.DefaultReason1Alt_Key
							--,T.DefaultReason2Alt_Key=C.DefaultReason2Alt_Key
							,T.NPA_Reason=C.NPA_Reason
							
						  --,T.LosDt =convert(varchar(10),C.LosDt,103)

					
									--select * from CURDAT.AdvCustNPAdetail	where CustomerEntityId=74458		
						FROM #CustomerDetailSelect T
							INNER JOIN CURDAT.AdvCustNPAdetail C
								ON (C.EffectiveFromTimeKey<=@TimeKey and C.EffectiveToTimeKey>=@TimeKey)
								AND T.CustomerEntityId=C.CustomerEntityId
								AND ISNULL(C.AuthorisationStatus,'A')='A'
								LEFT JOIN PRO.ACCOUNTCAL s ON s.CustomerEntityId=T.CustomerEntityId
										AND s.EffectiveFromTimeKey<=@TimeKey And s.EffectiveToTimeKey>=@TimeKey
       --                     left JOIN pro.accountcal_hist S
						 --  ON (s.EffectiveFromTimeKey<=@TimeKey and s.EffectiveToTimeKey>=@TimeKey)
							--AND s.CustomerEntityId=T.CustomerEntityId
								--AND ISNULL(s.AuthorisationStatus,'A')='A'

							LEFT JOIN DimUserInfo DU  ON DU.UserLoginID=@CustNPACrMod		
					END

					PRINT 77777
				IF @CustNPA='Y' OR @OperationFlag=16-- FROM MOD TABLE
					BEGIN
					
					   PRINT 2
						UPDATE T SET 
							--T.CurrentAssetClassAlt_Key=C.Cust_AssetClassAlt_Key,
							T.FCRA_YN=C.FCRA_YN,
							
							T.NPA_Date=convert(varchar(10),C.NPADt,103),
							T.SMADate=convert(varchar(10),S.SMA_Dt,103),
					     T.SMAStatus=S.SMA_Class,
							--T.DbtDt=convert(varchar(10),C.DbtDt,103),
							T.StaffAccountability=C.StaffAccountability,
							T.WillfulDefault=C.WillfulDefault,
							T.WillfulDefaultReasonAlt_Key=C.WillfulDefaultReasonAlt_Key,
							T.WillfulRemark=C.WillfulRemark,
							T.Userlocation=DU.UserLocation
						   ,T.AuthorisationStatus=C.AuthorisationStatus
						   ,T.WillfulDefaultDate=CONVERT(VARCHAR(10),C.WillfulDefaultDate,103)
						   --,T.DefaultReason1Alt_Key=C.DefaultReason1Alt_Key
						   --,T.DefaultReason2Alt_Key=C.DefaultReason2Alt_Key
						   ,T.NPA_Reason=C.NPA_Reason
						FROM #CustomerDetailSelect T
							
							--lefT JOIN pro.accountcal_hist S
							-- ON (s.EffectiveFromTimeKey<=@TimeKey and s.EffectiveToTimeKey>=@TimeKey)
							--	AND T.CustomerEntityId=s.CustomerEntityId

							LEFT JOIN PRO.ACCOUNTCAL s ON s.CustomerEntityId=T.CustomerEntityId
										AND s.EffectiveFromTimeKey<=@TimeKey And s.EffectiveToTimeKey>=@TimeKey
							
							INNER JOIN (
						               SELECT C.Cust_AssetClassAlt_Key,C.CustomerEntityId,C.NPADt
									   ,C.FCRA_YN --as FCRAlt_key
									   ,C.StaffAccountability,C.WillfulDefault,C.WillfulDefaultDate,
									    C.WillfulDefaultReasonAlt_Key,C.WillfulRemark,C.AuthorisationStatus,C.CreatedBy,C.ModifiedBy,NPA_Reason--C.DefaultReason1Alt_Key,C.DefaultReason2Alt_Key 
										FROM AdvCustNPADetail_Mod C
									   INNER JOIN(
									                 SELECT MAX(C.EntityKey) EntityKey FROM AdvCustNPADetail_Mod C
													 WHERE (C.EffectiveFromTimeKey<=@TimeKey and C.EffectiveToTimeKey>=@TimeKey)
													 AND  C.AuthorisationStatus in('NP','MP','DP','RM')
													 AND C.CustomerEntityId=@CustomerEntityID
													 GROUP BY  C.CustomerEntityId
									             )A   ON A.EntityKey=C.EntityKey
									                     AND (C.EffectiveFromTimeKey<=@TimeKey and C.EffectiveToTimeKey>=@TimeKey)
										                 AND C.AuthorisationStatus IN('NP','MP','DP','RM')
										                 AND C.CustomerEntityId=@CustomerEntityID
										
						                          )C   ON T.CustomerEntityId=C.CustomerEntityId

						LEFT JOIN  DimUserInfo DU ON DU.UserLoginID=@CustNPACrMod							
					END
	
		/*	CUST OTHER DETAIL */
		       Print 5
					IF @CustOth='N' OR @OperationFlag<>16 -- FROM MAIN TABLE
						BEGIN
						    PRINT 4444444444
							UPDATE T SET 
								 T.IsPetitioner			= C.IsPetitioner	 	
								,T.splCatg1Alt_Key		= C.SplCatg1Alt_Key					--SPL_CatgAlt_Key1	
								,T.splCatg2Alt_Key		= C.SplCatg2Alt_Key					--SPL_CatgAlt_Key2	
								,T.splCatg3Alt_Key		= C.SplCatg3Alt_Key					--SPL_CatgAlt_Key3	
								,T.splCatg4Alt_Key		= C.SplCatg4Alt_Key					--SPL_CatgAlt_Key4	
								,T.UnderLitigation	    = C.UnderLitigation
								,T.IsEmployee			= C.IsEmployee	
								,T.LegalActionProposed  =C.PermiNatureID
								,T.BorrUnitFunct        =C.BorrUnitFunct
								,T.DtofClosure          =Convert(varchar(10),C.DtofClosure,103)
								,T.NonCoopBorrower      =C.NonCoopBorrower
								,T.ArbiAgreement        =C.ArbiAgreement
								,T.TransThroughUs       =C.TransThroughUs
								,T.CutBackArrangement   =C.CutBackArrangement
								,T.BankingArrangement   =C.BankingArrangement
								,T.MemberBanksNo        =C.MemberBanksNo
								,T.TotalConsortiumAmt   =C.TotalConsortiumAmt
								,T.ROC_CFCReportDate    =Convert(Varchar(10),C.ROC_CFCReportDate,103)
              					,T.ROC_ChargeFV         =C.ROC_ChargeFV
								,T.ROC_ChargeFVDt       =Convert(Varchar(10),C.ROC_ChargeFVDt,103)
								,T.ROC_ChargeRemark     =C.ROC_ChargeRemark
								,T.ChargeFiledwithROCRemark2  =C.ROC_Securities
								,T.ROC_Cover              =C.ROC_Cover
								,T.ROCCoveredCertificateDate=CONVERT(VARCHAR(10),C.ROC_CoveredDt,103)
								,T.ChargeFiledWith =C.ChargeFiledWith
								,T.FiledDt=CONVERT(Varchar(20),C.FiledDt,103)
								,T.EmployeeID=C.EmployeeID
								,T.EmployeeType=C.EmployeeType
								,T.Designation=DG.DesignationName
								,T.Placeofposting=C.Placeofposting
								,T.LPersonalConDate=CONVERT(Varchar(10),C.LPersonalConDate,103)
								,T.LPersonalConDtls=C.LPersonalConDtls
								,T.RecallNoticeDate=Convert(Varchar(10),C.RecallNoticeDate,103)
								,T.RecallNoticeModeID=C.RecallNoticeModeID
								,T.LegalAuditDate=Convert(Varchar(10),C.LegalAuditDate,103)
								,T.IrregularityPending=C.IrregularityPending
								,T.IrregularityRectiDate =Convert(varchar(10),C.IrregularityRectiDate,103)
								,T.FraudAccoStatus=C.FraudAccoStatus
								,T.Userlocation=DU.UserLocation
								,T.AuthorisationStatus=C.AuthorisationStatus
								,T.GradeScaleAlt_Key=C.GradeScaleAlt_Key
								,T.Grade=DP.ParameterName
								,T.FMRNO=C.FMRNO	
							    ,T.FMRDate=CONVERT(VARCHAR(10),C.FMRDate,103)
								,T.FraudNatureRemark=C.FraudNatureRemark
								,T.BorrowerGroupAlt_key = C.GroupAlt_key
								--,T.LEI = C.LEI

							FROM #CustomerDetailSelect T
								INNER JOIN CURDAT.AdvCustOtherDetail C
									ON (C.EffectiveFromTimeKey<=@TimeKey and C.EffectiveToTimeKey>=@TimeKey)
									AND T.CustomerEntityId=C.CustomerEntityId AND C.CustomerEntityId=@CustomerEntityID
									AND ISNULL(C.AuthorisationStatus,'A')='A'
								LEFT JOIN  DimUserInfo  DU  ON DU.UserLoginID=@CustOthCrMod		
								LEFT JOIN DimParameter DP  ON DP.ParameterAlt_Key=C.GradeScaleAlt_Key AND DP.DimParameterName='DimGrade'
								LEFT JOIN DimDesignation DG ON (DG.EffectiveFromTimeKey<=@TimeKey AND DG.EffectiveToTimeKey>=@TimeKey) 
																AND DG.DesignationName=C.Designation

							
						END
                    Print 'abc'
					IF @CustOth='Y' OR @OperationFlag=16-- FROM MOD TABLE
						BEGIN
						   PRINT 4
							UPDATE T SET 
									 T.IsPetitioner			= C.IsPetitioner	 	
									,T.splCatg1Alt_Key		= C.SplCatg1Alt_Key	
									,T.splCatg2Alt_Key		= C.SplCatg2Alt_Key	
									,T.splCatg3Alt_Key		= C.SplCatg3Alt_Key	
									,T.splCatg4Alt_Key		= C.SplCatg4Alt_Key	
									,T.UnderLitigation	    = C.UnderLitigation
								    ,T.IsEmployee			= C.IsEmployee	
								    ,T.LegalActionProposed  =C.PermiNatureID
								    ,T.BorrUnitFunct        =C.BorrUnitFunct
								    ,T.DtofClosure          =Convert(varchar(10),C.DtofClosure,103)
								    ,T.NonCoopBorrower      =C.NonCoopBorrower
								    ,T.ArbiAgreement        =C.ArbiAgreement
								    ,T.TransThroughUs       =C.TransThroughUs
								    ,T.CutBackArrangement   =C.CutBackArrangement
								    ,T.BankingArrangement   =C.BankingArrangement
								    ,T.MemberBanksNo        =C.MemberBanksNo
								    ,T.TotalConsortiumAmt   =C.TotalConsortiumAmt
								    ,T.ROC_CFCReportDate    =Convert(Varchar(10),C.ROC_CFCReportDate,103)
              					    ,T.ROC_ChargeFV         =C.ROC_ChargeFV
								    ,T.ROC_ChargeFVDt       =Convert(Varchar(10),C.ROC_ChargeFVDt,103)
								    ,T.ROC_ChargeRemark     =C.ROC_ChargeRemark
								    ,T.ChargeFiledwithROCRemark2  =C.ROC_Securities
								    ,T.ROC_Cover              =C.ROC_Cover
								    ,T.ROCCoveredCertificateDate=Convert(Varchar(10),C.ROC_CoveredDt,103)
								    ,T.ChargeFiledWith =C.ChargeFiledWith
								    ,T.FiledDt=Convert(Varchar(20),C.FiledDt,103)
								    ,T.EmployeeID=C.EmployeeID
								    ,T.EmployeeType=C.EmployeeType
								    ,T.Designation=DG.DesignationName
								    ,T.Placeofposting=C.Placeofposting
								    ,T.LPersonalConDate=Convert(Varchar(10),C.LPersonalConDate,103)
								    ,T.LPersonalConDtls=C.LPersonalConDtls
								    ,T.RecallNoticeDate=Convert(Varchar(10),C.RecallNoticeDate,103)
								    ,T.RecallNoticeModeID=C.RecallNoticeModeID
								    ,T.LegalAuditDate=Convert(Varchar(10),C.LegalAuditDate,103)
								    ,T.IrregularityPending=C.IrregularityPending
								    ,T.IrregularityRectiDate =Convert(varchar(10),C.IrregularityRectiDate,103)
								    ,T.FraudAccoStatus=C.FraudAccoStatus
									,T.Userlocation=DU.UserLocation
									,T.AuthorisationStatus=C.AuthorisationStatus
									,T.GradeScaleAlt_Key=C.GradeScaleAlt_Key
									,T.Grade=DP.ParameterName
									,T.FMRNO=C.FMRNO	
									,T.FMRDate=CONVERT(VARCHAR(10),C.FMRDate,103)
									,T.FraudNatureRemark=C.FraudNatureRemark
									,T.BorrowerGroupAlt_key = C.BorrowerGroupAlt_key
						    		--,T.LEI = C.LEI

							
							FROM #CustomerDetailSelect T
								INNER JOIN (
						               SELECT C.CustomerEntityId,C.IsPetitioner,C.SplCatg1Alt_Key,C.SplCatg2Alt_Key,
									    C.SplCatg3Alt_Key,C.SplCatg4Alt_Key,C.UnderLitigation,C.IsEmployee,C.PermiNatureID,C.BorrUnitFunct,	
										C.DtofClosure,C.NonCoopBorrower,C.ArbiAgreement,C.TransThroughUs,C.CutBackArrangement,C.BankingArrangement,
										 C.MemberBanksNo,C.TotalConsortiumAmt,C.ROC_CFCReportDate,C.ROC_ChargeFV,
										 C.ROC_ChargeFVDt,C.ROC_ChargeRemark,C.ROC_Securities,C.ROC_Cover,C.ROC_CoveredDt,C.ChargeFiledWith,
										 C.FiledDt,C.EmployeeID,C.EmployeeType,C.Designation,C.Placeofposting,C.LPersonalConDate,C.LPersonalConDtls,
										 C.RecallNoticeDate,C.RecallNoticeModeID,C.LegalAuditDate,C.IrregularityPending,C.IrregularityRectiDate,C.FraudAccoStatus
										 ,C.AuthorisationStatus ,C.CreatedBy,C.ModifiedBy,C.GradeScaleAlt_Key,C.FMRNO,C.FMRDate,C.FraudNatureRemark,C.GroupAlt_Key BorrowerGroupAlt_Key FROM AdvCustOtherDetail_Mod C
									   INNER JOIN(
									                 SELECT MAX(C.EntityKey) EntityKey FROM AdvCustOtherDetail_Mod C
													 WHERE (C.EffectiveFromTimeKey<=@TimeKey and C.EffectiveToTimeKey>=@TimeKey)
													 AND  C.AuthorisationStatus in('NP','MP','DP','RM')
													 AND C.CustomerEntityId=@CustomerEntityID
													 GROUP BY  C.CustomerEntityId
									             )A   ON A.EntityKey=C.EntityKey
									                     AND (C.EffectiveFromTimeKey<=@TimeKey and C.EffectiveToTimeKey>=@TimeKey)
										                 AND C.AuthorisationStatus IN('NP','MP','DP','RM')
										                 AND C.CustomerEntityId=@CustomerEntityID
										
						                          )C   ON T.CustomerEntityId=C.CustomerEntityId

										LEFT JOIN  DimUserInfo  DU  ON DU.UserLoginID=@CustOthCrMod
										LEFT JOIN DimParameter DP  ON DP.ParameterAlt_Key=C.GradeScaleAlt_Key AND DP.DimParameterName='DimGrade'
										LEFT JOIN DimDesignation DG ON (DG.EffectiveFromTimeKey<=@TimeKey AND DG.EffectiveToTimeKey>=@TimeKey) 
																AND DG.DesignationName=C.Designation						

									Print 'PQR'
						END

		/*	CUST RELATIONSHIP DETAIL */
		Print 6
					IF @CustRel='N' OR @OperationFlag<>16 -- FROM MAIN TABLE
						BEGIN
						PRINT 5565
						--select * FROM #CustomerDetailSelect
							UPDATE T SET 
									 T.PAN						= C.PAN							
									,T.VoterID				    = C.VoterID						
									,T.AadharNo				    = C.AadhaarId					
									,T.NPR_Id					= C.NPR_Id						
									,T.PassportNo				= C.PassportNo					
									,T.PassportIssueDate		= convert(varchar(10),C.PassportIssueDt,103)			
									,T.PassportExpDate		    = convert(varchar(10),C.PassportExpiryDt,103)			
									,T.PassportIssueLocation	= C.PassportIssueLocation		
									,T.DL_No					= C.DL_No						
									,T.DL_IssueDate			    = convert(varchar(10),C.DL_IssueDate,103)			
									,T.DL_ExpDate				= convert(varchar(10),C.DL_ExpiryDate,103)			
									,T.DL_IssueLocation		    = C.DL_IssueLocation			
									,T.RationCardNo			    = C.RationCardNo				
									,T.OtherIdType			    = C.OtherIdType					
									,T.OtherIdNo		        = C.OtherID					
									,T.TAN					    = C.TAN							
									,T.TIN					    = C.TIN							
									,T.DIN					    = C.DIN							
									,T.CIN					    = C.CIN							
									,T.RegistrationNo			= C.RegistrationNo	
									,T.MobileNo                 =C.MobileNo
									,T.EmailID                  =C.Email
									,T.Userlocation				=DU.UserLocation
									,T.AuthorisationStatus=C.AuthorisationStatus
									,T.RelationEntityId			=C.RelationEntityId
									,T.LEI			=C.LEI
								
							FROM #CustomerDetailSelect T
								INNER JOIN CURDAT.AdvCustRelationship C
									ON (C.EffectiveFromTimeKey<=@TimeKey and C.EffectiveToTimeKey>=@TimeKey)
									AND T.CustomerEntityId=C.CustomerEntityId
									AND ISNULL(C.AuthorisationStatus,'A')='A'
							   LEFT JOIN  DimUserInfo  DU ON DU.UserLoginID=@CustRelCrMod			
						END
					IF @CustRel='Y' OR @OperationFlag=16-- FROM MOD TABLE
						BEGIN
						PRINT 5
							UPDATE T SET 
									PAN							= C.PAN							
									,VoterID					= C.VoterID						
									,AadharNo					= C.AadhaarId					
									,NPR_Id						= C.NPR_Id						
									,PassportNo					= C.PassportNo					
									,PassportIssueDate			= convert(varchar(10),C.PassportIssueDt,103)			
									,PassportExpDate			= convert(varchar(10),C.PassportExpiryDt,103)					
									,PassportIssueLocation		= C.PassportIssueLocation		
									,DL_No						= C.DL_No						
									,DL_IssueDate				= convert(varchar(10),C.DL_IssueDate,103)				
									,DL_ExpDate					= convert(varchar(10),C.DL_ExpiryDate,103)						
									,DL_IssueLocation			= C.DL_IssueLocation			
									,RationCardNo				= C.RationCardNo				
									,OtherIdType				= C.OtherIdType					
									,OtherIdNo					= C.OtherID					
									,TAN						= C.TAN							
									,TIN						= C.TIN							
									,DIN						= C.DIN							
									,CIN						= C.CIN							
									,RegistrationNo				= C.RegistrationNo	
									,T.MobileNo                 =C.MobileNo
									,T.EmailID                  =C.Email	
									,T.Userlocation				=DU.UserLocation	
									,T.AuthorisationStatus		=C.AuthorisationStatus
									,T.RelationEntityId			=C.RelationEntityId
									,T.LEI			=C.LEI
							FROM #CustomerDetailSelect T
								INNER JOIN (
						               SELECT C.CustomerEntityId,C.PAN,C.VoterID,C.AadhaarId,C.NPR_Id,C.PassportNo,C.PassportIssueDt,C.PassportIssueLocation,
									    C.DL_No,C.DL_IssueDate,C.DL_ExpiryDate,C.DL_IssueLocation,C.RationCardNo,C.OtherIdType,C.OtherID,C.PassportExpiryDt,
										C.TAN,C.TIN,C.DIN,C.CIN,C.RegistrationNo,C.MobileNo,C.Email,C.AuthorisationStatus,C.CreatedBy,C.ModifiedBy		
										,C.RelationEntityId,C.LEI
										FROM AdvCustRelationship_Mod C
									   INNER JOIN(
									                 SELECT MAX(C.EntityKey) EntityKey FROM AdvCustRelationship_Mod C
													 WHERE (C.EffectiveFromTimeKey<=@TimeKey and C.EffectiveToTimeKey>=@TimeKey)
													 AND  C.AuthorisationStatus in('NP','MP','DP','RM')
													 AND C.CustomerEntityId=@CustomerEntityID
													 GROUP BY  C.CustomerEntityId
									             )A   ON A.EntityKey=C.EntityKey
									                     AND (C.EffectiveFromTimeKey<=@TimeKey and C.EffectiveToTimeKey>=@TimeKey)
										                 AND C.AuthorisationStatus IN('NP','MP','DP','RM')
										                 AND C.CustomerEntityId=@CustomerEntityID
										
						                          )C   ON T.CustomerEntityId=C.CustomerEntityId
									  LEFT JOIN  DimUserInfo  DU ON DU.UserLoginID=@CustRelCrMod						
						END	

						/*	CUST Coomunication DETAIL */
						Print 7
					IF @CustComm='N' OR @OperationFlag<>16 -- FROM MAIN TABLE
						BEGIN
						PRINT 6
							UPDATE T SET 
								T. PinCode		   =C.PinCode	
								,T.STD_Code_Res		=C.STD_Code_Res
								,T.PhoneNo_Res		=C.PhoneNo_Res
								,T.STD_Code_Off		=C.STD_Code_Off
								,T.PhoneNo_Off		=C.PhoneNo_Off
								,T.FaxNo			=C.FaxNo
								,T.CityAlt_Key		=C.CityAlt_Key
								,T.CityName			=DC.CityName
								,T.DistrictAlt_Key	=C.DistrictAlt_Key
								,T.DistrictName		=DD.DistrictName
								,T.CountryAlt_Key	=C.CountryAlt_Key
								,T.CountryName		=DT.CountryName
								,T.Add1             =C.Add1          
								,T.Add2 			=C.Add2 
								,T.Add3             =C.Add3   
								,T.AddressTypeAlt_Key=C.AddressTypeAlt_Key
								,T.AddressCategoryAlt_Key=DA.AddressCategoryAlt_Key
								,T.Userlocation=DU.UserLocation
								,T.AuthorisationStatus=C.AuthorisationStatus
								,T.RelationADDEntityId= C.RelationADDEntityId


									
							FROM #CustomerDetailSelect T
								INNER JOIN CURDAT.AdvCustCommunicationDetail C
									ON (C.EffectiveFromTimeKey<=@TimeKey and C.EffectiveToTimeKey>=@TimeKey)
									AND T.CustomerEntityId=C.CustomerEntityId
									AND ISNULL(C.AuthorisationStatus,'A')='A'
									--LEFT JOIN DimCity DC
									--ON DC.CityAlt_Key=C.CityAlt_Key
									--LEFT JOIN Dimgeography DD
									--ON DD.DistrictAlt_Key=C.DistrictAlt_Key
									--LEFT JOIN DimCountry DT
									--ON DT.CountryAlt_Key=C.CountryAlt_Key
									--LEFT JOIN DimAddressCategory DA ON DA.AddressCategoryAlt_Key=C.AddressCategoryAlt_Key  Condition of EffectiveFromTimeKey and EffectiveToTimeKey Added Triloki 21/02/2017
									LEFT JOIN DimCity DC ON (DC.EffectiveFromTimeKey<=@TimeKey and DC.EffectiveToTimeKey>=@TimeKey)
									AND  DC.CityAlt_Key=C.CityAlt_Key
									LEFT JOIN Dimgeography DD ON (DD.EffectiveFromTimeKey<=@TimeKey and DD.EffectiveToTimeKey>=@TimeKey)
									AND  DD.DistrictAlt_Key=C.DistrictAlt_Key
									LEFT JOIN DimCountry DT ON (DT.EffectiveFromTimeKey<=@TimeKey and DT.EffectiveToTimeKey>=@TimeKey)
									AND  DT.CountryAlt_Key=C.CountryAlt_Key
									LEFT JOIN DimAddressCategory DA ON (DA.EffectiveFromTimeKey<=@TimeKey and DA.EffectiveToTimeKey>=@TimeKey)
								    AND  DA.AddressCategoryAlt_Key=C.AddressCategoryAlt_Key
								LEFT JOIN  DimUserInfo  DU ON DU.UserLoginID=@CustCommCrMod		

						END
					IF @CustComm='Y' OR @OperationFlag=16-- FROM MOD TABLE
						BEGIN
						PRINT 6
							UPDATE T SET 
								T.PinCode		=C.PinCode	
								,T.STD_Code_Res		=C.STD_Code_Res
								,T.PhoneNo_Res		=C.PhoneNo_Res
								,T.STD_Code_Off		=C.STD_Code_Off
								,T.PhoneNo_Off		=C.PhoneNo_Off
								,T.FaxNo			=C.FaxNo
								,T.CityAlt_Key		=C.CityAlt_Key
								,T.CityName			=DC.CityName
								,T.DistrictAlt_Key	=C.DistrictAlt_Key
								,T.DistrictName		=DD.DistrictName
								,T.CountryAlt_Key	=C.CountryAlt_Key
								,T.CountryName		=DT.CountryName	
								,T.Add1             =C.Add1          
								,T.Add2 			=C.Add2 
								,T.Add3             =C.Add3   
								,T.AddressTypeAlt_Key=C.AddressTypeAlt_Key
								,T.AddressCategoryAlt_Key=DA.AddressCategoryAlt_Key
								,T.Userlocation    =DU.UserLocation
							   ,T.AuthorisationStatus=C.AuthorisationStatus
							   ,T.RelationADDEntityId= C.RelationADDEntityId
							FROM #CustomerDetailSelect T
								INNER JOIN (
						               SELECT C.CustomerEntityId,C.PinCode,C.STD_Code_Res,C.PhoneNo_Res,C.STD_Code_Off,C.PhoneNo_Off,C.FaxNo,C.CityAlt_Key,
									    C.DistrictAlt_Key,C.CountryAlt_Key,C.Add1,C.Add2,C.Add3,C.AddressTypeAlt_Key,C.AddressCategoryAlt_Key
										,C.AuthorisationStatus,C.CreatedBy,C.ModifiedBy,C.RelationADDEntityId
										FROM AdvCustCommunicationDetail_Mod C
									   INNER JOIN(
									                 SELECT MAX(C.EntityKey) EntityKey FROM AdvCustCommunicationDetail_Mod C
													 WHERE (C.EffectiveFromTimeKey<=@TimeKey and C.EffectiveToTimeKey>=@TimeKey)
													 AND  C.AuthorisationStatus in('NP','MP','DP','RM')
													 AND C.CustomerEntityId=@CustomerEntityID
													 GROUP BY  C.CustomerEntityId
									             )A   ON A.EntityKey=C.EntityKey
									                     AND (C.EffectiveFromTimeKey<=@TimeKey and C.EffectiveToTimeKey>=@TimeKey)
										                 AND C.AuthorisationStatus IN('NP','MP','DP','RM')
										                 AND C.CustomerEntityId=@CustomerEntityID
										
						                    )C   ON T.CustomerEntityId=C.CustomerEntityId

									LEFT JOIN DimCity DC ON (DC.EffectiveFromTimeKey<=@TimeKey and DC.EffectiveToTimeKey>=@TimeKey)
									AND  DC.CityAlt_Key=C.CityAlt_Key
									LEFT JOIN Dimgeography DD ON (DD.EffectiveFromTimeKey<=@TimeKey and DD.EffectiveToTimeKey>=@TimeKey)
									AND  DD.DistrictAlt_Key=C.DistrictAlt_Key
									LEFT JOIN DimCountry DT ON (DT.EffectiveFromTimeKey<=@TimeKey and DT.EffectiveToTimeKey>=@TimeKey)
									AND  DT.CountryAlt_Key=C.CountryAlt_Key
									LEFT JOIN DimAddressCategory DA ON (DA.EffectiveFromTimeKey<=@TimeKey and DA.EffectiveToTimeKey>=@TimeKey)
								    AND  DA.AddressCategoryAlt_Key=C.AddressCategoryAlt_Key
							        LEFT JOIN DimUserInfo  DU ON DU.UserLoginID=@CustCommCrMod				
						END


                Print 8
				IF 'Y' IN (@CustBasic,@CustFin,@CustNonFin, @CustOth, @CustNPA, @CustRel, @CustComm)
					BEGIN
							DECLARE @CreateModifyBy VARCHAR(20)
							SELECT @CreateModifyBy =CrModBy FROM(SELECT @CustBasicCrMod AS CrModBy UNION SELECT @CustFinCrMod AS CrModBy UNION SELECT  @CustNonFinCrMod AS CrModBy UNION SELECT @CustOthCrMod AS CrModBy UNION SELECT @CustNPACrMod AS CrModBy 
							UNION SELECT @CustRelCrMod AS CrModBy UNION SELECT @CustCommCrMod AS CrModBy) A WHERE ISNULL(CrModBy,'')<>''
							
							UPDATE  #CustomerDetailSelect  SET IsMainTable='N', CreateModifyBy=@CreateModifyBy
					END	
						
				select A.*,B.SegmentCode CustomerSegmentCode from #CustomerDetailSelect A LEFT JOIN [UTKS_STGDB].dbo.CBS_CUSTOMER_STG B ON A.CustomerID = B.CustomerID ---[ENBD_STGDB].dbo.FINACLE_CUSTOMER_STG Previously 16/1/2024
					
				Declare @FromTimekey int,@ToTimekey int,@FromDate varchar(10),@ToDate varchar(10)
		
				Select @FromTimekey=Max(TimeKey)
				from 
				(
					Select Max(EffectiveFromTimeKey) as TimeKey from CustomerBasicDetail where CustomerEntityId=@CustomerEntityId
					UNION
					Select Max(EffectiveFromTimeKey) as TimeKey from AdvCustOtherDetail  where CustomerEntityId=@CustomerEntityId
					UNION
					Select Max(EffectiveFromTimeKey) as TimeKey from AdvCustCommunicationDetail where CustomerEntityId=@CustomerEntityId
				)K
				
				--Select @FromTimekey
				--select @ToTimeKey
				Select @FromDate=CAST(date as date) from SysDayMatrix where TimeKey=@FromTimekey
				Select @ToDate=CAST(date as date) from SysDayMatrix where TimeKey=@ToTimeKey

			--	if(@OperationFlag = 2)
			--select @FromDate,@ToDate

			--if exists(select EffectiveFromTimekey from #CustomerDetailSelect )
				
				BEGIN
				Select 

				TimeKey
				,Convert(varchar(10),[Date],103) as [AvailableDate]
				,@FromDate as MinDate
				,@ToDate as MaxDate
				from SysDayMatrix
				where TimeKey Between @FromTimeKey AND @ToTimeKey

				END
				if exists(select EffectiveFromTimekey from #CustomerDetailSelect )
				BEGIN

				 
				--Select @FromDate=CAST(date as date) from SysDayMatrix where TimeKey=(select EffectiveFromTimekey from #CustomerDetailSelect)
				--Select TimeKey
				--,Convert(varchar(10),[Date],103) as [AvailableDate]
				--,@FromDate as MinDate
				--,@ToDate as MaxDate
				--from SysDayMatrix SD
				--inner join #CustomerDetailSelect c
			 --  on C.EffectiveFromTimeKey= SD.TimeKey
			 -- select @FromDate
			 Select @FromDate=CAST(date as date) from SysDayMatrix where TimeKey=(select MAX(EffectiveFromTimekey) from #CustomerDetailSelect)
			-- select @FromDate
			 	Select  top 1

				TimeKey
				,Convert(varchar(10),[Date],103) as [AvailableDate]
				,@FromDate as MinDate
				,@ToDate as MaxDate,'DateData' TableName
				from SysDayMatrix
				where TimeKey Between @FromTimeKey AND @ToTimeKey

			

				END
				--else
				--BEGIN
				--Select 

				--TimeKey
				--,Convert(varchar(10),[Date],103) as [AvailableDate]
				--,@FromDate as MinDate
				--,@ToDate as MaxDate
				--from SysDayMatrix
				--where TimeKey Between @FromTimeKey AND @ToTimeKey

				--END


				END
	


--	exec CustomerDetailSelect @CustomerEntityId=1001884,@CustType=N'BORROWER',@TimeKey=24583,@BranchCode=N'0',@OperationFlag=2



	




GO