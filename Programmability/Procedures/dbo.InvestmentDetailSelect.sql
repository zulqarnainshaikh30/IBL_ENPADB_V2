SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--exec InvestmentDetailSelect @CustomerEntityId=601,@CustType=N'',@TimeKey=25999,@BranchCode=N'0',@OperationFlag=2
--go



--Sp_helptext InvestmentDetailSelect


-------------------------------------------------------------------------------------------------------------




---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>

--exec [InvestmentDetailSelect]  @CustomerEntityID =1001190 	,@TimeKey	=49999	,@BranchCode ='',@OperationFlag =16
-- =============================================
CREATE PROCEDURE [dbo].[InvestmentDetailSelect]

--DECLARE
													 @PanNo				varchar(10)			= ''
													,@IssuerID			Varchar (100)		= ''
													,@IssuerName		Varchar (100)		= 'RAM'
													,@InvID				Varchar (100)		= ''
													,@InstrTypeAlt_key	Varchar (100)		= ''
													,@ISIN				varchar (100)		= ''
													,@OperationFlag		INT					= 1
													,@IssuerEntityID	INT=0
													,@InvEntityID		INT=0
													,@TimeKey			INT=49999


AS
BEGIN
	SET NOCOUNT ON;
	--UPDATE CustomerBasicDetail SET CustType = 'Borrower' WHERE CustType IS NULL
	/*-- CREATE TABP TABLE FOR SELECT THE DATA*/
	IF OBJECT_ID('Tempdb..InvestmentDetailSelect') IS NOT NULL
		DROP TABLE #InvestmentDetailSelect
	CREATE TABLE #InvestmentDetailSelect
				(							
							EntityKey		              VARCHAR(100),
                            BranchCode                    VARCHAR(100),
                            InvEntityId                   VARCHAR(100),
                            IssuerEntityId                VARCHAR(100),                            
                            ISIN                          VARCHAR(100),
                            InstrTypeAlt_Key              VARCHAR(100),
                            InstrumenttypeName            VARCHAR(100),
                            InvestmentNature              VARCHAR(100),
                            InternalRating                VARCHAR(100),
                            InRatingDate                  VARCHAR(100),
                            InRatingExpiryDate            VARCHAR(100),
                            ExRating                      VARCHAR(100),
                            ExRatingAgency                VARCHAR(100),
                            ExRatingDate                  VARCHAR(100),
                            ExRatingExpiryDate            VARCHAR(100),
                            Sector                        VARCHAR(100),
                            Industry_AltKey               VARCHAR(100),
                            ListedStkExchange             VARCHAR(100),
                            ExposureType                  VARCHAR(100),
                            SecurityValue                 VARCHAR(100),
                            MaturityDt                    VARCHAR(100),
                            ReStructureDate               VARCHAR(100),
                            MortgageStatus                VARCHAR(100),
                            NHBStatus                     VARCHAR(100),
                            ResiPurpose                   VARCHAR(100),
                            AuthorisationStatus           VARCHAR(100),
                            EffectiveFromTimeKey          VARCHAR(100),
                            EffectiveToTimeKey            VARCHAR(100),
                            CreatedBy                     VARCHAR(100),
                            DateCreated                   VARCHAR(100),
                            ModifiedBy                    VARCHAR(100),
                            DateModified                  VARCHAR(100),
							ApprovedBy                    VARCHAR(100),
                            DateApproved                  VARCHAR(100),
							Holding_AltKey                VARCHAR(100),
							HoldingNature                 VARCHAR(100)          ,
							CurrencyAlt_Key               VARCHAR(100),
							CurrencyName                  VARCHAR(100),
                            CurrencyConvRate              VARCHAR(100),
                            BookType                      VARCHAR(100),
							BookValue                     VARCHAR(100),
                            BookValueINR                  VARCHAR(100),
                            MTMValue                          VARCHAR(100),
                            MTMValueINR                       VARCHAR(100),
                            EncumberedMTM                     VARCHAR(100),
                            AssetClass_AltKey                 VARCHAR(100),
							AssetClassName                    VARCHAR(100),
                            NPIDt                             VARCHAR(100),
							 DBTDate                          VARCHAR(100)
							,LatestBSDate                     VARCHAR(100)  
							,Interest_DividendDueDate         VARCHAR(100)         
							,Interest_DividendDueAmount       VARCHAR(100)
							,PartialRedumptionDueDate         VARCHAR(100)
							,PartialRedumptionSettledY_N      VARCHAR(100)
                            ,TotalProvison                    VARCHAR(100),
							IssuerID                          INT,
                            IssuerName                        VARCHAR(100),
                            IssuerAccpRating                  VARCHAR(100),
                            IssuerAccpRatingDt                VARCHAR(100),
                            IssuerRatingAgency                VARCHAR(100),
                            Ref_Txn_Sys_Cust_ID               VARCHAR(100),
                            Issuer_Category_Code              VARCHAR(100),
                            GrpEntityOfBank                   VARCHAR(100),
							IsMainTable						CHAR(1),
							CreateModifyBy					VARCHAR(100)

				)
	--select * from #InvestmentDetailSelect
			/*--DECLARE VARIABLE FOR SET THE MAKER CHECKER FLAG TABLE WISE--*/
			Print 1
			DECLARE   @InvestmentBasic CHAR(1)='N',@InvestmentFin CHAR(1)='N', @InvestmentIssuer Char(1)='N' 
					 ,@InvestmentBasicCrMod VARCHAR(20)='',@InvestmentFinCrMod VARCHAR(20)='', @InvestmentIssuerCrMod VARCHAR(20)=''

				SELECT TOP(1) @InvestmentBasic	='Y',  @InvestmentBasicCrMod	=ISNULL(C.ModifiedBy,C.CreatedBy) 
				FROM InvestmentBasicDetail_Mod  C
				INNER JOIN(
				              SELECT MAX(C.EntityKey)EntityKey FROM InvestmentBasicDetail_Mod C
							  WHERE (C.EffectiveFromTimeKey<=@TimeKey and C.EffectiveToTimeKey>=@TimeKey)
							        AND C.InvEntityID=@InvEntityID AND C.AuthorisationStatus IN('NP','MP','DP','RM')
									GROUP BY C.InvEntityId
						   )A   ON A.EntityKey=C.EntityKey
						        AND (C.EffectiveFromTimeKey<=@TimeKey and C.EffectiveToTimeKey>=@TimeKey)	
								AND (C.AuthorisationStatus IN('NP','MP','DP','RM'))	
								AND C.InvEntityId=@InvEntityID			
				

				SELECT TOP(1) @InvestmentFin	='Y',  @InvestmentFinCrMod	=ISNULL(C.ModifiedBy,C.CreatedBy) 
				FROM InvestmentFinancialDetail_Mod  C
				INNER JOIN(
				              SELECT MAX(C.EntityKey)EntityKey FROM InvestmentFinancialDetail_Mod C
							  WHERE (C.EffectiveFromTimeKey<=@TimeKey and C.EffectiveToTimeKey>=@TimeKey)
							        AND C.InvEntityID=@InvEntityID AND C.AuthorisationStatus IN('NP','MP','DP','RM')
									GROUP BY C.InvEntityId
						   )A   ON A.EntityKey=C.EntityKey
						        AND (C.EffectiveFromTimeKey<=@TimeKey and C.EffectiveToTimeKey>=@TimeKey)	
								AND (C.AuthorisationStatus IN('NP','MP','DP','RM'))	
								AND C.InvEntityId=@InvEntityID



				SELECT TOP(1) @InvestmentIssuer	='Y',  @InvestmentIssuer	=ISNULL(C.ModifiedBy,C.CreatedBy) FROM InvestmentIssuerDetail_Mod  C
				INNER JOIN(
				              SELECT MAX(C.EntityKey)EntityKey FROM InvestmentIssuerDetail_Mod C
							  WHERE (C.EffectiveFromTimeKey<=@TimeKey and C.EffectiveToTimeKey>=@TimeKey)
							        AND C.IssuerEntityID=@IssuerEntityID 
									AND C.AuthorisationStatus IN('NP','MP','DP','RM')
									GROUP BY C.IssuerEntityID
						   )A   ON A.EntityKey=C.EntityKey
						        AND (C.EffectiveFromTimeKey<=@TimeKey and C.EffectiveToTimeKey>=@TimeKey)	
								AND (C.AuthorisationStatus IN('NP','MP','DP','RM'))	
								AND C.IssuerEntityID=@IssuerEntityID


			

			 ----SELECT 	@CustComm,	@CustRel,	@CustNPA	,@CustOth	,@CustNonFin	,@CustFin  ,@CustBasic

		/*	CUSTOMER BASICDETAIL  */
				--SELECT * FROM #InvestmentDetailSelect
		Print 2
				IF @InvestmentBasic='N' OR @OperationFlag<>16	-- FROM MAIN TABLE
					BEGIN
					PRINT 1
						INSERT INTO #InvestmentDetailSelect (EntityKey,
                            BranchCode,
                            InvEntityId,
                            IssuerEntityId,                            
                            ISIN,
                            InstrTypeAlt_Key,
                            InstrumenttypeName,
                            InvestmentNature,
                            InternalRating,
                            InRatingDate,
                            InRatingExpiryDate,
                            ExRating,
                            ExRatingAgency,
                            ExRatingDate,
                            ExRatingExpiryDate,
                            Sector,
                            Industry_AltKey,
                            ListedStkExchange,
                            ExposureType,
                            SecurityValue,
                            MaturityDt,
                            ReStructureDate,
                            MortgageStatus,
                            NHBStatus,
                            ResiPurpose,
                            AuthorisationStatus,
                            EffectiveFromTimeKey,
                            EffectiveToTimeKey,
                            CreatedBy,
                            DateCreated,
                            ModifiedBy,
                            DateModified,
							ApprovedBy,
                            DateApproved)						
							select	
							A.EntityKey,
                            A.BranchCode,
                            A.InvEntityId,
                            A.IssuerEntityId,                            
                            A.ISIN,
                            A.InstrTypeAlt_Key,
                            A.InstrName,
                            A.InvestmentNature,
                            A.InternalRating,
                            A.InRatingDate,
                            A.InRatingExpiryDate,
                            A.ExRating,
                            A.ExRatingAgency,
                            A.ExRatingDate,
                            A.ExRatingExpiryDate,
                            A.Sector,
                            A.Industry_AltKey,
                            A.ListedStkExchange,
                            A.ExposureType,
                            A.SecurityValue,
                            A.MaturityDt,
                            A.ReStructureDate,
                            A.MortgageStatus,
                            A.NHBStatus,
                            A.ResiPurpose,
                            A.AuthorisationStatus,
                            A.EffectiveFromTimeKey,
                            A.EffectiveToTimeKey,
                            A.CreatedBy,
                            A.DateCreated,
                            A.ModifiedBy,
                            A.DateModified,
							A.ApprovedBy,
                            A.DateApproved
					 FROM	curdat.InvestmentBasicDetail A 
					 Left join DimIndustry H on A.Industry_AltKey=H.IndustryAlt_Key
					 Left join DimInstrumentType G on A.InstrTypeAlt_Key=G.InstrumentTypeAlt_Key	
						WHERE (A.EffectiveFromTimeKey<=@TimeKey and A.EffectiveToTimeKey>=@TimeKey) 
						AND A.issuerEntityID=@IssuerEntityID AND ISNULL(A.AuthorisationStatus,'A')='A' 
						 
					END
				IF @InvestmentBasic='Y' OR @OperationFlag=16-- FROM MOD TABLE
					BEGIN
					PRINT 1
						INSERT INTO #InvestmentDetailSelect ( EntityKey,
                            BranchCode,
                            InvEntityId,
                            IssuerEntityId,                            
                            ISIN,
                            InstrTypeAlt_Key,
                            InstrumenttypeName,
                            InvestmentNature,
                            InternalRating,
                            InRatingDate,
                            InRatingExpiryDate,
                            ExRating,
                            ExRatingAgency,
                            ExRatingDate,
                            ExRatingExpiryDate,
                            Sector,
                            Industry_AltKey,
                            ListedStkExchange,
                            ExposureType,
                            SecurityValue,
                            MaturityDt,
                            ReStructureDate,
                            MortgageStatus,
                            NHBStatus,
                            ResiPurpose,
                            AuthorisationStatus,
                            EffectiveFromTimeKey,
                            EffectiveToTimeKey,
                            CreatedBy,
                            DateCreated,
                            ModifiedBy,
                            DateModified,
							ApprovedBy,
                            DateApproved
						)   select	
							A.EntityKey,
                            A.BranchCode,
                            A.InvEntityId,
                            A.IssuerEntityId,                            
                            A.ISIN,
                            A.InstrTypeAlt_Key,
                            A.InstrName,
                            A.InvestmentNature,
                            A.InternalRating,
                            A.InRatingDate,
                            A.InRatingExpiryDate,
                            A.ExRating,
                            A.ExRatingAgency,
                            A.ExRatingDate,
                            A.ExRatingExpiryDate,
                            A.Sector,
                            A.Industry_AltKey,
                            A.ListedStkExchange,
                            A.ExposureType,
                            A.SecurityValue,
                            A.MaturityDt,
                            A.ReStructureDate,
                            A.MortgageStatus,
                            A.NHBStatus,
                            A.ResiPurpose,
                            A.AuthorisationStatus,
                            A.EffectiveFromTimeKey,
                            A.EffectiveToTimeKey,
                            A.CreatedBy,
                            A.DateCreated,
                            A.ModifiedBy,
                            A.DateModified,
							A.ApprovedBy,
                            A.DateApproved
						 FROM InvestmentbasicDetail_Mod A 					 					 
					 Left join DimIndustry H on A.Industry_AltKey=H.IndustryAlt_Key
					 Left join DimInstrumentType G on A.InstrTypeAlt_Key=G.InstrumentTypeAlt_Key										 
						INNER JOIN(
				              SELECT MAX(C.Entitykey)Entitykey 
							  FROM InvestmentBasicDetail_Mod C
							  WHERE (C.EffectiveFromTimeKey<=@TimeKey 
							  and C.EffectiveToTimeKey>=@TimeKey)
							        AND C.InvEntityID=@InvEntityID 
									AND C.AuthorisationStatus IN('NP','MP','DP','RM')									 	
									GROUP BY C.InvEntityId )Z
						     ON z.EntityKey=A.EntityKey
						        AND (A.EffectiveFromTimeKey<=@TimeKey and A.EffectiveToTimeKey>=@TimeKey)	
								AND (A.AuthorisationStatus IN('NP','MP','DP','RM'))	
								AND A.InvEntityID=@InvEntityID
                         -- LEFT JOIN DIMSOURCEDB DS ON C.SourceSystemAlt_Key=DS.SourceAlt_Key --Sachin
						  AND A.EffectiveFromTimeKey<=@TimeKey and A.EffectiveToTimeKey>=@TimeKey  --Sachin 
						--LEFT JOIN dbo.DimMiscSuit M   ON (M.EffectiveFromTimeKey<=@TimeKey and M.EffectiveToTimeKey>=@TimeKey) AND M.LegalMiscSuitAlt_Key=C.NonCustTypeAlt_Key
						--LEFT JOIN dbo.DimLegalNatureOfActivity N ON (N.EffectiveFromTimeKey<=@TimeKey and N.EffectiveToTimeKey>=@TimeKey) 
						--AND N.LegalNatureOfActivityAlt_Key=C.ServProviderAlt_Key			
					 					
					END
				--SELECT * FROM #InvestmentDetailSelect
		/*	Investment FINANCIAL DETAIL */
		Print 3
				IF @InvestmentFin='N' OR @OperationFlag<>16 -- FROM MAIN TABLE
					BEGIN
					PRINT 22222
						UPDATE T 
						SET	T.Holding_AltKey	=P.ParameterAlt_Key,
							T.HoldingNature		=A.HoldingNature,
							T.CurrencyAlt_Key	=A.CurrencyAlt_Key,
							T.CurrencyName      =Q.CurrencyName,
                            T.CurrencyConvRate	=A.CurrencyConvRate,
                            T.BookType	        =A.BookType,
							T.BookValue     	=A.BookValue,
                            T.BookValueINR      =A.BookValueINR,
                            T.MTMValue          =A.MTMValue,
                            T.MTMValueINR       =A.MTMValueINR,
                            T.EncumberedMTM     =A.EncumberedMTM,
                            T.AssetClass_AltKey =A.AssetClass_AltKey,
							T.AssetClassName    =R.AssetClassName,
                            T.NPIDt             =A.NPIDt,
							 T.DBTDate          =A.DBTDate
							,T.LatestBSDate     =A.LatestBSDate
							,T.Interest_DividendDueDate =A.Interest_DividendDueDate
							,T.Interest_DividendDueAmount =A.Interest_DividendDueAmount
							,T.PartialRedumptionDueDate =A.PartialRedumptionDueDate
							,T.PartialRedumptionSettledY_N =A.PartialRedumptionSettledY_N
                            ,T.TotalProvison =A.TotalProvison
							,T.AuthorisationStatus=A.AuthorisationStatus							
						FROM		#InvestmentDetailSelect T
						INNER JOIN	curdat.InvestmentFinancialDetail A
						ON		(A.EffectiveFromTimeKey<=@TimeKey and A.EffectiveToTimeKey>=@TimeKey)
						AND T.InvEntityId=A.InvEntityId						
						AND		ISNULL(A.AuthorisationStatus,'A')='A'
					LEFT JOIN DimParameter P on A.HoldingNature = P.ParameterName	
					LEFT JOIN DimCurrency Q  on A.CurrencyAlt_Key = Q.CurrencyAlt_Key	
					LEFT JOIN DimAssetClass R on A.AssetClass_AltKey = R.AssetClassAlt_Key						
					END

					
				IF @InvestmentFin='Y' OR @OperationFlag=16-- FROM MOD TABLE
					BEGIN
					PRINT 23333
						UPDATE T 
						SET		T.Holding_AltKey	=	P.ParameterAlt_Key,
								T.HoldingNature		=	A.HoldingNature,
							T.CurrencyAlt_Key	=		A.CurrencyAlt_Key,
							T.CurrencyName      =		Q.CurrencyName,
                            T.CurrencyConvRate	=		A.CurrencyConvRate,
                            T.BookType	=				A.BookType,
							T.BookValue	=				A.BookValue,
                            T.BookValueINR  =			A.BookValueINR,
                            T.MTMValue  =				A.MTMValue,
                            T.MTMValueINR =				A.MTMValueINR,
                            T.EncumberedMTM  =			A.EncumberedMTM,
                            T.AssetClass_AltKey =		A.AssetClass_AltKey,
							T.AssetClassName    =		R.AssetClassName,
                            T.NPIDt =					A.NPIDt,
                            T.TotalProvison =			A.TotalProvison,
							T.AuthorisationStatus=		A.AuthorisationStatus
						
						FROM #InvestmentDetailSelect T
						INNER JOIN (
						               SELECT		A.InvEntityId,A.HoldingNature,A.CurrencyAlt_Key,A.CurrencyConvRate,A.BookType,A.BookValue,A.BookValueINR,
													A.MTMValue,A.MTMValueINR,A.EncumberedMTM,A.AssetClass_AltKey,A.NPIDt,A.TotalProvison,A.AuthorisationStatus
									   FROM			InvestmentFinancialDetail_Mod A
									   INNER JOIN	(
														 SELECT MAX(A.EntityKey) EntityKey 
														 FROM InvestmentFinancialDetail_Mod A
														 WHERE (A.EffectiveFromTimeKey<=@TimeKey and A.EffectiveToTimeKey>=@TimeKey)
														 AND  A.AuthorisationStatus in('NP','MP','DP','RM')
														 AND A.InvEntityId=@InvEntityID														 
														 GROUP BY  A.InvEntityId
													)C   
										   ON	A.EntityKey=C.EntityKey
									       AND (A.EffectiveFromTimeKey<=@TimeKey and A.EffectiveToTimeKey>=@TimeKey)
										   AND A.AuthorisationStatus IN('NP','MP','DP','RM')
										   AND A.InvEntityId=@InvEntityID									
								)A   
						ON			T.InvEntityId=A.InvEntityId
						LEFT JOIN DimParameter P on A.HoldingNature = P.ParameterName	
					LEFT JOIN DimCurrency Q  on A.CurrencyAlt_Key = Q.CurrencyAlt_Key	
					LEFT JOIN DimAssetClass R on A.AssetClass_AltKey = R.AssetClassAlt_Key			
						   
		
					END
		

		
		

		/*	Issuer DETAIL */
		Print 3
				IF @InvestmentFin='N' OR @OperationFlag<>16 -- FROM MAIN TABLE
					BEGIN
					PRINT 22222
						UPDATE T 
						SET	T.IssuerID =A.IssuerID,
                            T.IssuerName =A.IssuerName,
                            T.IssuerAccpRating =A.IssuerAccpRating,
                            T.IssuerAccpRatingDt =A.IssuerAccpRatingDt,
                            T.IssuerRatingAgency =A.IssuerRatingAgency,
                            T.Ref_Txn_Sys_Cust_ID =A.Ref_Txn_Sys_Cust_ID,
                            T.Issuer_Category_Code =A.Issuer_Category_Code,
                            T.GrpEntityOfBank =A.GrpEntityOfBank,
							T.AuthorisationStatus=A.AuthorisationStatus							
						FROM		#InvestmentDetailSelect T
						INNER JOIN	curdat.InvestmentIssuerDetail A
						ON		(A.EffectiveFromTimeKey<=@TimeKey and A.EffectiveToTimeKey>=@TimeKey)
						AND T.IssuerEntityId=A.IssuerEntityId					
						AND		ISNULL(A.AuthorisationStatus,'A')='A'
					END
				IF @InvestmentFin='Y' OR @OperationFlag=16-- FROM MOD TABLE
					BEGIN
					PRINT 23333
						UPDATE T 
						SET	T.IssuerID =A.IssuerID,
                            T.IssuerName =A.IssuerName,
                            T.IssuerAccpRating =A.IssuerAccpRating,
                            T.IssuerAccpRatingDt =A.IssuerAccpRatingDt,
                            T.IssuerRatingAgency =A.IssuerRatingAgency,
                            T.Ref_Txn_Sys_Cust_ID =A.Ref_Txn_Sys_Cust_ID,
                            T.Issuer_Category_Code =A.Issuer_Category_Code,
                            T.GrpEntityOfBank =A.GrpEntityOfBank,
							T.AuthorisationStatus=A.AuthorisationStatus
						
						FROM #InvestmentDetailSelect T
						INNER JOIN (
						               SELECT		A.IssuerEntityId,
													A.IssuerID,
													A.IssuerName,
													A.IssuerAccpRating,
													A.IssuerAccpRatingDt,
													A.IssuerRatingAgency,
													A.Ref_Txn_Sys_Cust_ID,
													A.Issuer_Category_Code,
													A.GrpEntityOfBank,
													A.AuthorisationStatus 
									   FROM			InvestmentIssuerDetail_Mod A
									   INNER JOIN	(
														 SELECT MAX(A.EntityKey) EntityKey 
														 FROM InvestmentIssuerDetail_Mod A
														 WHERE (A.EffectiveFromTimeKey<=@TimeKey and A.EffectiveToTimeKey>=@TimeKey)
														 AND  A.AuthorisationStatus in('NP','MP','DP','RM')
														 AND A.IssuerEntityId=@IssuerEntityID
														 GROUP BY  A.IssuerEntityId
													)C   
										   ON	A.EntityKey=C.EntityKey
									       AND (A.EffectiveFromTimeKey<=@TimeKey and A.EffectiveToTimeKey>=@TimeKey)
										   AND A.AuthorisationStatus IN('NP','MP','DP','RM')
										   AND A.IssuerEntityId=@IssuerEntityId									
								)A   
						ON			T.IssuerEntityId=A.IssuerEntityId
								
						   
		
					END
		
		


                Print 8
				IF 'Y' IN (@InvestmentBasic,@InvestmentFin,@InvestmentIssuer)
					BEGIN
							DECLARE @CreateModifyBy VARCHAR(20)
							SELECT @CreateModifyBy =CrModBy FROM(SELECT @iNVESTMENTBasicCrMod AS CrModBy UNION SELECT @iNVESTMENTFinCrMod AS CrModBy UNION SELECT  @iNVESTMENTissuerCrMod AS CrModBy ) A WHERE ISNULL(CrModBy,'')<>''
							
							UPDATE  #InvestmentDetailSelect  SET IsMainTable='N', CreateModifyBy=@CreateModifyBy
					END	
						
				select * from #InvestmentDetailSelect
					
				Declare @FromTimekey int,@ToTimekey int,@FromDate varchar(10),@ToDate varchar(10)
		
				Select @FromTimekey=Max(TimeKey)
				from 
				(
					Select Max(EffectiveFromTimeKey) as TimeKey from curdat.InvestmentBasicDetail where InvEntityId=@InvEntityId
					UNION
					Select Max(EffectiveFromTimeKey) as TimeKey from curdat.InvestmentFinancialDetail  where InvEntityId=@InvEntityId
					UNION
					Select Max(EffectiveFromTimeKey) as TimeKey from curdat.InvestmentIssuerDetail where IssuerEntityId=@IssuerEntityId
				)K
				Select @ToTimeKey=Timekey from SysDataMatrix where CurrentStatus='C'
				--Select @FromTimekey
				--select @ToTimeKey
				Select @FromDate=CAST(date as date) from SysDayMatrix where TimeKey=@FromTimekey
				Select @ToDate=CAST(date as date) from SysDayMatrix where TimeKey=@ToTimeKey

			--	if(@OperationFlag = 2)
			--select @FromDate,@ToDate

			--if exists(select EffectiveFromTimekey from #InvestmentDetailSelect )
				
				BEGIN
				Select 
				TimeKey
				,Convert(varchar(10),[Date],103) as [AvailableDate]
				,@FromDate as MinDate
				,@ToDate as MaxDate
				from SysDayMatrix
				where TimeKey Between @FromTimeKey AND @ToTimeKey

				END
				if exists(select EffectiveFromTimekey from #InvestmentDetailSelect )
				BEGIN

				 
				--Select @FromDate=CAST(date as date) from SysDayMatrix where TimeKey=(select EffectiveFromTimekey from #InvestmentDetailSelect)
				--Select TimeKey
				--,Convert(varchar(10),[Date],103) as [AvailableDate]
				--,@FromDate as MinDate
				--,@ToDate as MaxDate
				--from SysDayMatrix SD
				--inner join #InvestmentDetailSelect c
			 --  on C.EffectiveFromTimeKey= SD.TimeKey
			 -- select @FromDate
			 Select @FromDate=CAST(date as date) from SysDayMatrix where TimeKey=(select MAX(EffectiveFromTimekey) from #InvestmentDetailSelect)
			
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
	


--	exec InvestmentDetailSelect @CustomerEntityId=1001884,@CustType=N'BORROWER',@TimeKey=24583,@BranchCode=N'0',@OperationFlag=2
GO