SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROC [dbo].[RestructureMasterSearchList]

--Declare

													

													--@PageNo         INT         = 1, 

													--@PageSize       INT         = 10, 

													@OperationFlag  INT         = 1

AS

     

	 BEGIN

	 set dateformat dmy

SET NOCOUNT ON;

Declare @TimeKey as Int

	SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')

					
--25999


BEGIN TRY





IF Object_Id ('TempDB..#Previous') Is Not Null

Drop Table #Previous







/*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */

print 'NANDA'

			IF(@OperationFlag not in ( 16,17,20))

             BEGIN

			 IF OBJECT_ID('TempDB..#temp') IS NOT NULL

                 DROP TABLE  #temp;

                 SELECT	distinct	A.AccountEntityId

								,A.SystemACID

								,A.SourceName

								,A.CustomerId

								,A.CustomerName

								,A.UCIF_ID

								,A.CurrencyAlt_Key

								,A.CurrencyName

								,A.AccountOpenDate

								,A.SchemeType

								,A.Productcode

								,A.ProductDescription

								,A.segmentcode

								,A.SegmentDescription

								,A.RevisedBusinessSegment

								,A.BankingRelationTypeAlt_Key

								,A.[BankingRelationship]

								,A.SanctionLimit

								,A.SanctionLimitDt

								--,A.AssetClassAlt_Key

								,A.PreRestructureAssetClassAlt_Key

								,A.AssetClassName

								,A.NpaDt

							    ,A.DtofFirstDisb

								,A.RestructureTypeAlt_Key

								,A.RestructureType

								,A.RestructureCatgAlt_Key

								,A.RestructureFacility

								,A.PreRestrucDefaultDate

							    ,A.PreAssetClassName

							    ,A.PreRestrucNPA_Date

								,A.PostAssetClassName

								--,A.Npa_Qtr

								,A.RestructureDt

								,A.RestructureProposalDt

								,A.RestructureAmt

								,A.RestructureApprovingAuthority

							    ,A.RestructureApprovalDt

								,A.POS_RepayStartDate

								,A.RestructurePOS 

								,A.IntRepayStartDate

							--	,A.RefDate

								,A.InvocationDate

								--,A.EquityConversionYN

							    ,A.ConversionDate

								,A.Is_COVID_Morat

								,A.Covid_Morit

							    ,A.parameterAlt_Key

								,A.COVID_OTR_Catg

								,A.ReportingBank

								,A.ICA_SignDate

								,A.Is_InvestmentGrade

								--,A.StatusofSpecificPeriod

								,A.[Status_Current_Quarter]

								,A.[Status_previous_Quarter]

								,A.[Status_of_MoniroringPeriod]

								--,A.[Status_of_Specified_Period]

								,A.CreditProvision

							    ,A.DFVProvision

							    ,A.MTMProvision

								,A.TotalProv

								,A.[Percentage]

								,A.TotalProvisionPrevious

								,A.AuthorisationStatus, 

								A.EffectiveFromTimeKey, 

								A.EffectiveToTimeKey, 

								A.CreatedBy, 

								A.DateCreated, 

								A.ApprovedBy, 

								A.DateApproved, 

								A.ModifiedBy, 

								A.DateModified,

								A.CRILIC_Fst_DefaultDate

								,A.Status_of_MoniroringPeriodAlt_Key

								,A.StatusofSpecificPeriod As Status_of_Specified_PeriodAlt_Key

							--	,A.RevisedBusSegAlt_Key

								,A.CrModBy

								,A.CrModDate

								,A.CrAppBy

								,A.CrAppDate

								,A.ModAppBy

								,A.ModAppDate

								,A.PreRestructureNPA_Prov

                             
                                ,A.EquityConversionYN

                            ,A.EquityConversionYNName

							,A.CrntQtrAssetClass

							,A.PrevQtrAssetClass

							,A.MonitoringPeriodStatus

							,A.PrevQtrTotalProvision

							,A.AcBuSegmentDescription
							,A.changeFields
                 INTO #temp

                 FROM 

                 (

                     SELECT distinct

							A.AccountEntityId

								,B.SystemACID

								,C.SourceName

								,D.CustomerId

								,D.CustomerName

								,D.UCIF_ID

								,H.CurrencyCode CurrencyAlt_Key

								,H.CurrencyName

								--,Convert(Date,B.AccountOpenDate,103)AccountOpenDate
								,case when ISNULL(B.AccountOpenDate,'1900-01-01')='1900-01-01' then NULL else convert(varchar(10),cast(B.AccountOpenDate as date),103) end  AccountOpenDate 
								--,convert(varchar(10),cast(AccountOpenDate as date),103) AccountOpenDate

								,B.FacilityType as SchemeType

								,G.ProductCode AS  Productcode

								,G.ProductName AS  ProductDescription

								,B.segmentcode

								--,P.SegmentDescription SegmentDescription

							--	,W.EWS_SegmentName AS SegmentDescription
							    ,DBS.AcBuSegmentDescription AS SegmentDescription

								,DBS.AcBuSegmentDescription As RevisedBusinessSegment

								,A.BankingRelationTypeAlt_Key

								,M.ParameterName 'BankingRelationship'

								,B.CurrentLimit as SanctionLimit

								--,Convert(Date,B.CurrentLimitDt,103) as SanctionLimitDt

								--,convert(varchar(10),cast(B.CurrentLimitDt as date),103) SanctionLimitDt
								,case when ISNULL(B.CurrentLimitDt,'1900-01-01')='1900-01-01' then NULL else convert(varchar(10),cast(B.CurrentLimitDt as date),103) end SanctionLimitDt
								--,E.AssetClassAlt_Key -----------chk

								,A.PreRestructureAssetClassAlt_Key

								,J.AssetClassName

								--,convert(varchar(10),F.NpaDt,103) NpaDt
								,case when ISNULL(F.NpaDt,'1900-01-01')='1900-01-01' then NULL else convert(varchar(10),cast(F.NpaDt as date),103) end NpaDt 
							    --,Convert(Date,B.DtofFirstDisb,103)DtofFirstDisb

								--,convert(varchar(10),cast(B.DtofFirstDisb as date),103) DtofFirstDisb
								,case when ISNULL(B.DtofFirstDisb,'1900-01-01')='1900-01-01' then NULL else convert(varchar(10),cast(B.DtofFirstDisb as date),103) end DtofFirstDisb 
								--,convert(varchar(10),cast(A.DisbursementDate as date),103) DtofFirstDisb
								,A.RestructureTypeAlt_Key

								,k.ParameterName AS RestructureType

								,A.RestructureCatgAlt_Key

								,L.ParameterName AS RestructureFacility

								--,Convert(Date,A.PreRestrucDefaultDate,103)PreRestrucDefaultDate

								--,convert(varchar(10),cast(A.PreRestrucDefaultDate as date),103) PreRestrucDefaultDate
								,case when ISNULL(A.PreRestrucDefaultDate,'1900-01-01')='1900-01-01' then NULL else convert(varchar(10),cast(A.PreRestrucDefaultDate as date),103) end PreRestrucDefaultDate 
							    ,Q.AssetClassName PreAssetClassName

							    --,Convert(Date,Y.NPADt,103)PreRestrucNPA_Date

								--,convert(varchar(10),cast(Y.NPADt as date),103) PreRestrucNPA_Date
								,case when ISNULL(Y.NPADt,'1900-01-01')='1900-01-01' then NULL else convert(varchar(10),cast(Y.NPADt as date),103) end PreRestrucNPA_Date 

								,R.AssetClassName PostAssetClassName

								--,A.Npa_Qtr

								--,Convert(Date,A.RestructureDt,103)RestructureDt

								--,convert(varchar(10),cast(A.RestructureDt as date),103) RestructureDt
								,case when ISNULL(A.RestructureDt,'1900-01-01')='1900-01-01' then NULL else convert(varchar(10),cast(A.RestructureDt as date),103) end RestructureDt 
								--,Convert(Date,A.RestructureProposalDt,103)RestructureProposalDt

								--,convert(varchar(10),cast(A.RestructureProposalDt as date),103) RestructureProposalDt
								,case when ISNULL(A.RestructureProposalDt,'1900-01-01')='1900-01-01' then NULL else convert(varchar(10),cast(A.RestructureProposalDt as date),103) end RestructureProposalDt
								,A.RestructureAmt

								,A.RestructureApprovingAuthority

							    --,Convert(Date,A.RestructureApprovalDt,103)RestructureApprovalDt

								--,convert(varchar(10),cast(A.RestructureApprovalDt as date),103) RestructureApprovalDt
								,case when ISNULL(A.RestructureApprovalDt,'1900-01-01')='1900-01-01' then NULL else convert(varchar(10),cast(A.RestructureApprovalDt as date),103) end RestructureApprovalDt
								--,Convert(Date,A.PrincRepayStartDate,103) POS_RepayStartDate

								--,convert(varchar(10),cast(A.PrincRepayStartDate as date),103) POS_RepayStartDate
								,case when ISNULL(A.PrincRepayStartDate,'1900-01-01')='1900-01-01' then NULL else convert(varchar(10),cast(A.PrincRepayStartDate as date),103) end POS_RepayStartDate
								,A.RestructurePOS 

								--,Convert(Date,A.IntRepayStartDate,103)IntRepayStartDate

								--,convert(varchar(10),cast(A.InttRepayStartDate as date),103) IntRepayStartDate
								 ,case when ISNULL(A.InttRepayStartDate,'1900-01-01')='1900-01-01' then NULL else convert(varchar(10),cast(A.InttRepayStartDate as date),103) end IntRepayStartDate
								--,Convert(Date,A.RefDate,103)RefDate

							--	,convert(varchar(10),cast(A.RefDate as date),103) RefDate

								--,Convert(Date,A.InvocationDate,103)InvocationDate

								--,convert(varchar(10),cast(A.InvocationDate as date),103) InvocationDate
								,case when ISNULL(A.InvocationDate,'1900-01-01')='1900-01-01' then NULL else convert(varchar(10),cast(A.InvocationDate as date),103) end InvocationDate
								--,A.EquityConversionYN

							    --,Convert(Date,A.ConversionDate,103)ConversionDate
								,case when ISNULL(A.ConversionDate,'1900-01-01')='1900-01-01' then NULL else convert(varchar(10),cast(A.ConversionDate as date),103) end  ConversionDate 
								--,convert(varchar(10),cast(A.ConversionDate as date),103) ConversionDate

								,S.ParameterAlt_Key as Is_COVID_Morat

								,S.ParameterName Covid_Morit

							    ,N.parameterAlt_Key

								,N.ParameterName as COVID_OTR_Catg

								,A.FstDefaultReportingBank ReportingBank

								--,Convert(Date,A.ICA_SignDate,103) ICA_SignDate

								--,convert(varchar(10),cast(A.ICA_SignDate as date),103) ICA_SignDate
								,case when ISNULL(A.ICA_SignDate,'1900-01-01')='1900-01-01' then NULL else convert(varchar(10),cast(A.ICA_SignDate as date),103) end ICA_SignDate 
								,A.InvestmentGrade as Is_InvestmentGrade

								--,P.[Status_Current_Quarter]
								,A.StatusofSpecificPeriod
								--,P.[Status_previous_Quarter]

								--,P.[Status_of_MoniroringPeriod]

								--,P.[Status_of_Specified_Period]

								--,P.TotalProvisionPrevious

								,O.PrevQtrTotalProvision as TotalProvisionPrevious

								,X.AssetClassName as Status_Current_Quarter

								,T.AssetClassName as Status_previous_Quarter

								,U.ParameterName as Status_of_MoniroringPeriod

								--,V.ParameterName as Status_of_Specified_Period

								,A.CreditProvision

							    ,A.DFVProvision

							    ,A.MTMProvision

								,E.TotalProv

								,Round((E.TotalProv/E.Balance)*100,2) as [Percentage]

								--,Convert(Date,A.CRILIC_Fst_DefaultDate,103)CRILIC_Fst_DefaultDate

								--,convert(varchar(10),cast(A.CRILIC_Fst_DefaultDate as date),103) CRILIC_Fst_DefaultDate
								,case when ISNULL(A.CRILIC_Fst_DefaultDate,'1900-01-01')='1900-01-01' then NULL else convert(varchar(10),cast(A.CRILIC_Fst_DefaultDate as date),103) end CRILIC_Fst_DefaultDate
								,isnull(A.AuthorisationStatus, 'A') AuthorisationStatus, 

								A.EffectiveFromTimeKey, 

								A.EffectiveToTimeKey, 

								A.CreatedBy, 

								Convert(Varchar(20),A.DateCreated,103)DateCreated, 

								A.ApprovedBy, 

								Convert(Date,A.DateApproved,103)DateApproved, 

								A.ModifiedBy, 

								Convert(Date,A.DateModified,103)DateModified

								--,P.Status_of_MoniroringPeriodAlt_Key

								--,P.Status_of_Specified_PeriodAlt_Key

								,O.MonitoringPeriodStatus AS Status_of_MoniroringPeriodAlt_Key

								,A.StatusofSpecificPeriod As Status_of_Specified_PeriodAlt_Key

								--,A.RevisedBusSegAlt_Key

								,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy

							,IsNull(A.DateModified,A.DateCreated)as CrModDate

							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy

							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate

							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy

							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate

							,A.PreRestructureNPA_Prov

							,A.EquityConversionYN

                            ,YY.ParameterName as EquityConversionYNName

							,o.CrntQtrAssetClass

							,o.PrevQtrAssetClass

							,o.MonitoringPeriodStatus

							,o.PrevQtrTotalProvision

							,DBS.AcBuSegmentDescription
							,'' as changefields

					 FROM		 [CURDAT].[AdvAcRestructureDetail] A

					 INNER JOIN  [DBO].[AdvAcBasicDetail] B ON B.AccountEntityId =A.AccountEntityId

					 AND B.EffectiveFromTimeKey<=@TimeKey and B.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN  [dbo].[DIMSOURCEDB] C ON C.SourceAlt_Key = B.SourceAlt_Key

					 AND C.EffectiveFromTimeKey<=@TimeKey and C.EffectiveToTimeKey>=@TimeKey

					 INNER JOIN  [DBO].[CustomerBasicDetail] D ON D.CustomerId= A.RefCustomerId

					 AND D.EffectiveFromTimeKey<=@TimeKey and D.EffectiveToTimeKey>=@TimeKey

					 INNER JOIN  [DBO].[AdvAcBalanceDetail] E ON E.AccountEntityId= A.AccountEntityId

					 AND E.EffectiveFromTimeKey<=@TimeKey and E.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN  [DBO].[AdvCustNPADetail] Y  ON Y.RefCustomerID= A.RefCustomerId

					 AND Y.EffectiveFromTimeKey<=@TimeKey and Y.EffectiveToTimeKey>=@TimeKey

					 INNER JOIN  [DBO].[AdvAcFinancialDetail] F ON F.AccountEntityId= A.AccountEntityId

					 AND F.EffectiveFromTimeKey<=@TimeKey and F.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN [PRO].[AdvAcRestructureCal] O ON O.AccountEntityId=B.AccountEntityId

					 AND O.EffectiveFromTimeKey<=@TimeKey and O.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN  [dbo].[DimProduct] G ON G.ProductAlt_Key = B.ProductAlt_Key

					 AND G.EffectiveFromTimeKey<=@TimeKey and G.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN  [dbo].[DimCurrency] H ON H.CurrencyAlt_Key = B.CurrencyAlt_Key

					 AND H.EffectiveFromTimeKey<=@TimeKey and H.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN  [dbo].[DimAssetClass] J ON J.AssetClassAlt_Key =  A.PreRestructureAssetClassAlt_Key 

					 AND J.EffectiveFromTimeKey<=@TimeKey and J.EffectiveToTimeKey>=@TimeKey 

					 LEFT JOIN  [dbo].[DimAssetClass] Q ON Q.AssetClassAlt_Key = Y.Cust_AssetClassAlt_Key 

					 AND Q.EffectiveFromTimeKey<=@TimeKey and Q.EffectiveToTimeKey>=@TimeKey 

					 LEFT JOIN  [dbo].[DimAssetClass] R ON R.AssetClassAlt_Key = A.PostRestrucAssetClass 

					 AND R.EffectiveFromTimeKey<=@TimeKey and R.EffectiveToTimeKey>=@TimeKey     

					 LEFT JOIN  [dbo].[DimParameter] K ON k.ParameterAlt_Key = A.RestructureTypeAlt_Key AND k.DimParameterName='TypeofRestructuring'

					 AND K.EffectiveFromTimeKey<=@TimeKey and K.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN  [dbo].[DimParameter] L ON L.ParameterAlt_Key = A.RestructureCatgAlt_Key AND L.DimParameterName='RestructureFacility'

					 AND L.EffectiveFromTimeKey<=@TimeKey and L.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN  [dbo].[DimParameter] M ON M.ParameterAlt_Key = A.BankingRelationTypeAlt_Key AND M.DimParameterName='BankingRelationship'

					 AND M.EffectiveFromTimeKey<=@TimeKey and M.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN  [dbo].[DimParameter] N ON N.ParameterAlt_Key = A.COVID_OTR_CatgAlt_Key AND N.DimParameterName='Covid - OTR Category'

					 AND N.EffectiveFromTimeKey<=@TimeKey and N.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN  [dbo].[DimAssetClass] X ON X.AssetClassAlt_Key = O.CrntQtrAssetClass 

					 AND X.EffectiveFromTimeKey<=@TimeKey and X.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN  [dbo].[DimAssetClass] T ON T.AssetClassAlt_Key = O.PrevQtrAssetClass 

					 AND T.EffectiveFromTimeKey<=@TimeKey and T.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN  [dbo].[DimParameter] U ON U.ParameterAlt_Key = O.MonitoringPeriodStatus AND U.DimParameterName='StatusofMonitoringPeriod'

					 AND U.EffectiveFromTimeKey<=@TimeKey and U.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN  [dbo].[DimParameter] V ON V.ParameterAlt_Key = O.SpecifiedPeriodStatus AND V.DimParameterName='StatusofSpecificPeriod'

					 AND V.EffectiveFromTimeKey<=@TimeKey and V.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN  [dbo].[DimSegment] W ON W.EWS_SegmentAlt_Key =  B.segmentcode

					 AND W.EffectiveFromTimeKey<=@TimeKey and W.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN  DimAcBuSegment DBS on  B.segmentcode = DBS.AcBuSegmentCode

					 AND DBS.EffectiveFromTimeKey<=@TimeKey and DBS.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN (Select ParameterAlt_Key,ParameterName,'CovidMoratorium' As TableName

					  from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey And DimParameterName='DimYesNoNA')

		 S ON S.ParameterAlt_Key=A.FlgMorat
		 LEFT JOIN (Select ParameterAlt_Key,ParameterName,'InvestmentGrade' As TableName

					  from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey And DimParameterName='DimYesNoNA')
					  Z ON Z.ParameterName=A.InvestmentGrade

					  LEFT JOIN (	Select 		
									ParameterAlt_Key
									,ParameterName
									,'EquityConversionYN' As TableName									
									 from DimParameter 
									Where EffectiveFromTimeKey<=@TimeKey
									And EffectiveToTimeKey>=@TimeKey
									And DimParameterName='DimYesNo')YY ON YY.ParameterAlt_Key = A.EquityConversionYN


					 --LEFT JOIN #Previous P ON P.AccountEntityId=A.AccountEntityId

					 WHERE A.EffectiveFromTimeKey <= @TimeKey

                           AND A.EffectiveToTimeKey >= @TimeKey

                           AND ISNULL(A.AuthorisationStatus, 'A') = 'A'

                     UNION

                     SELECT distinct

							A.AccountEntityId

								,B.SystemACID

								,C.SourceName

								,D.CustomerId

								,D.CustomerName

								,D.UCIF_ID

								,H.CurrencyCode CurrencyAlt_Key

								,H.CurrencyName

									--,Convert(Date,B.AccountOpenDate,103)AccountOpenDate

								,case when ISNULL(B.AccountOpenDate,'1900-01-01')='1900-01-01' then NULL else convert(varchar(10),cast(B.AccountOpenDate as date),103) end  AccountOpenDate 

								,B.FacilityType as SchemeType

								,G.ProductCode AS  Productcode

								,G.ProductName AS  ProductDescription

								,B.segmentcode

								--,P.SegmentDescription SegmentDescription

								--,W.EWS_SegmentName AS SegmentDescription
								,DBS.AcBuSegmentDescription AS SegmentDescription

										,DBS.AcBuSegmentDescription As RevisedBusinessSegment

								,A.BankingRelationTypeAlt_Key

								,M.ParameterName 'BankingRelationship'

								,B.CurrentLimit as SanctionLimit

								--,Convert(Date,B.CurrentLimitDt,103) as SanctionLimitDt

								,case when ISNULL(B.CurrentLimitDt,'1900-01-01')='1900-01-01' then NULL else convert(varchar(10),cast(B.CurrentLimitDt as date),103) end SanctionLimitDt

								--,E.AssetClassAlt_Key -----------chk

								,A.PreRestructureAssetClassAlt_Key

								,J.AssetClassName

							,case when ISNULL(F.NpaDt,'1900-01-01')='1900-01-01' then NULL else convert(varchar(10),cast(F.NpaDt as date),103) end NpaDt 
							    --,Convert(Date,B.DtofFirstDisb,103)DtofFirstDisb

								--,convert(varchar(10),cast(B.DtofFirstDisb as date),103) DtofFirstDisb
								,case when ISNULL(B.DtofFirstDisb,'1900-01-01')='1900-01-01' then NULL else convert(varchar(10),cast(B.DtofFirstDisb as date),103) end DtofFirstDisb 
								--,convert(varchar(10),cast(A.DisbursementDate as date),103) DtofFirstDisb
								,A.RestructureTypeAlt_Key

								,k.ParameterName AS RestructureType

								,A.RestructureCatgAlt_Key

								,L.ParameterName AS RestructureFacility

									--,convert(varchar(10),cast(A.PreRestrucDefaultDate as date),103) PreRestrucDefaultDate
								,case when ISNULL(A.PreRestrucDefaultDate,'1900-01-01')='1900-01-01' then NULL else convert(varchar(10),cast(A.PreRestrucDefaultDate as date),103) end PreRestrucDefaultDate 
							    ,Q.AssetClassName PreAssetClassName

							    --,Convert(Date,Y.NPADt,103)PreRestrucNPA_Date

								--,convert(varchar(10),cast(Y.NPADt as date),103) PreRestrucNPA_Date
								,case when ISNULL(Y.NPADt,'1900-01-01')='1900-01-01' then NULL else convert(varchar(10),cast(Y.NPADt as date),103) end PreRestrucNPA_Date 

								,R.AssetClassName PostAssetClassName

							--	,A.Npa_Qtr
															--,convert(varchar(10),cast(A.RestructureDt as date),103) RestructureDt
								,case when ISNULL(A.RestructureDt,'1900-01-01')='1900-01-01' then NULL else convert(varchar(10),cast(A.RestructureDt as date),103) end RestructureDt 
								--,Convert(Date,A.RestructureProposalDt,103)RestructureProposalDt

								--,convert(varchar(10),cast(A.RestructureProposalDt as date),103) RestructureProposalDt
								,case when ISNULL(A.RestructureProposalDt,'1900-01-01')='1900-01-01' then NULL else convert(varchar(10),cast(A.RestructureProposalDt as date),103) end RestructureProposalDt
								,A.RestructureAmt

								,A.RestructureApprovingAuthority

							    --,Convert(Date,A.RestructureApprovalDt,103)RestructureApprovalDt

								,case when ISNULL(A.RestructureApprovalDt,'1900-01-01')='1900-01-01' then NULL else convert(varchar(10),cast(A.RestructureApprovalDt as date),103) end RestructureApprovalDt

								--,Convert(Date,A.PrincRepayStartDate,103) POS_RepayStartDate

								,case when ISNULL(A.PrincRepayStartDate,'1900-01-01')='1900-01-01' then NULL else convert(varchar(10),cast(A.PrincRepayStartDate as date),103) end POS_RepayStartDate

								,A.RestructurePOS 

								--,Convert(Date,A.IntRepayStartDate,103)IntRepayStartDate

								 ,case when ISNULL(A.InttRepayStartDate,'1900-01-01')='1900-01-01' then NULL else convert(varchar(10),cast(A.InttRepayStartDate as date),103) end IntRepayStartDate

								--,Convert(Date,A.RefDate,103)RefDate

								--,convert(varchar(10),cast(A.RefDate as date),103) RefDate

								--,Convert(Date,A.InvocationDate,103)InvocationDate

								,case when ISNULL(A.InvocationDate,'1900-01-01')='1900-01-01' then NULL else convert(varchar(10),cast(A.InvocationDate as date),103) end InvocationDate

								--,A.EquityConversionYN

							    --,Convert(Date,A.ConversionDate,103)ConversionDate
								,case when ISNULL(A.ConversionDate,'1900-01-01')='1900-01-01' then NULL else convert(varchar(10),cast(A.ConversionDate as date),103) end  ConversionDate 
								--,convert(varchar(10),cast(A.ConversionDate as date),103) ConversionDate

								,S.ParameterAlt_Key as Is_COVID_Morat

								,S.ParameterName Covid_Morit

							    ,N.parameterAlt_Key

								,N.ParameterName as COVID_OTR_Catg

								,A.FstDefaultReportingBank ReportingBank

								--,Convert(Date,A.ICA_SignDate,103) ICA_SignDate

								,case when ISNULL(A.ICA_SignDate,'1900-01-01')='1900-01-01' then NULL else convert(varchar(10),cast(A.ICA_SignDate as date),103) end ICA_SignDate 

								, A.InvestmentGrade as Is_InvestmentGrade
								,A.StatusofSpecificPeriod
								--,P.[Status_Current_Quarter]

								--,P.[Status_previous_Quarter]

								--,P.[Status_of_MoniroringPeriod]

								--,P.[Status_of_Specified_Period]

								--,P.TotalProvisionPrevious

								,O.PrevQtrTotalProvision as TotalProvisionPrevious

								,X.AssetClassName as Status_Current_Quarter

								,T.AssetClassName as Status_previous_Quarter

								,U.ParameterName as Status_of_MoniroringPeriod

								--,V.ParameterName as Status_of_Specified_Period

								,A.CreditProvision

							    ,A.DFVProvision

							    ,A.MTMProvision

								,E.TotalProv

								,Round((E.TotalProv/E.Balance)*100,2) as [Percentage]

								--,Convert(Date,A.CRILIC_Fst_DefaultDate,103)CRILIC_Fst_DefaultDate

								,case when ISNULL(A.CRILIC_Fst_DefaultDate,'1900-01-01')='1900-01-01' then NULL else convert(varchar(10),cast(A.CRILIC_Fst_DefaultDate as date),103) end CRILIC_Fst_DefaultDate

								,isnull(A.AuthorisationStatus, 'A') AuthorisationStatus, 

								A.EffectiveFromTimeKey, 

								A.EffectiveToTimeKey, 

								A.CreatedBy, 

								Convert(Varchar(20),A.DateCreated,103)DateCreated, 

								A.ApprovedBy, 

								Convert(Date,A.DateApproved,103)DateApproved, 

								A.ModifiedBy, 

								Convert(Date,A.DateModified,103)DateModified

								--,P.Status_of_MoniroringPeriodAlt_Key

								--,P.Status_of_Specified_PeriodAlt_Key

								,O.MonitoringPeriodStatus AS Status_of_MoniroringPeriodAlt_Key

								,A.StatusofSpecificPeriod As Status_of_Specified_PeriodAlt_Key

								--,A.RevisedBusSegAlt_Key

								,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy

							,IsNull(A.DateModified,A.DateCreated)as CrModDate

							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy

							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate

							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy

							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate

							,A.PreRestructureNPA_Prov

                               ,A.EquityConversionYN

                            ,YY.ParameterName as EquityConversionYNName

							,o.CrntQtrAssetClass

							,o.PrevQtrAssetClass

							,o.MonitoringPeriodStatus

							,o.PrevQtrTotalProvision

							,DBS.AcBuSegmentDescription
							,A.changeFields
							
					 FROM		 [DBO].[AdvAcRestructureDetail_Mod] A

					 INNER JOIN  [DBO].[AdvAcBasicDetail] B ON B.AccountEntityId =A.AccountEntityId

					 AND B.EffectiveFromTimeKey<=@TimeKey and B.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN  [dbo].[DIMSOURCEDB] C ON C.SourceAlt_Key = B.SourceAlt_Key

					 AND C.EffectiveFromTimeKey<=@TimeKey and C.EffectiveToTimeKey>=@TimeKey

					 INNER JOIN  [DBO].[CustomerBasicDetail] D ON D.CustomerId= A.RefCustomerId

					 AND D.EffectiveFromTimeKey<=@TimeKey and D.EffectiveToTimeKey>=@TimeKey

					 INNER JOIN  [DBO].[AdvAcBalanceDetail] E ON E.AccountEntityId= A.AccountEntityId

					 AND E.EffectiveFromTimeKey<=@TimeKey and E.EffectiveToTimeKey>=@TimeKey

					 INNER JOIN  [DBO].[AdvAcFinancialDetail] F ON F.AccountEntityId= A.AccountEntityId

					 AND F.EffectiveFromTimeKey<=@TimeKey and F.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN [PRO].[AdvAcRestructureCal] O ON O.AccountEntityId=B.AccountEntityId

					 AND O.EffectiveFromTimeKey<=@TimeKey and O.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN  [DBO].[AdvCustNPADetail] Y  ON Y.RefCustomerID= A.RefCustomerId

					 AND Y.EffectiveFromTimeKey<=@TimeKey and Y.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN  [dbo].[DimProduct] G ON G.ProductAlt_Key = B.ProductAlt_Key

					 AND G.EffectiveFromTimeKey<=@TimeKey and G.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN  [dbo].[DimCurrency] H ON H.CurrencyAlt_Key = B.CurrencyAlt_Key

					 AND H.EffectiveFromTimeKey<=@TimeKey and H.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN  [dbo].[DimAssetClass] J ON J.AssetClassAlt_Key =  A.PreRestructureAssetClassAlt_Key

					 AND J.EffectiveFromTimeKey<=@TimeKey and J.EffectiveToTimeKey>=@TimeKey 

					 LEFT JOIN  [dbo].[DimAssetClass] Q ON Q.AssetClassAlt_Key = Y.Cust_AssetClassAlt_Key 

					 AND Q.EffectiveFromTimeKey<=@TimeKey and Q.EffectiveToTimeKey>=@TimeKey 

					 LEFT JOIN  [dbo].[DimAssetClass] R ON R.AssetClassAlt_Key = A.PostRestrucAssetClass 

					 AND R.EffectiveFromTimeKey<=@TimeKey and R.EffectiveToTimeKey>=@TimeKey     

					 LEFT JOIN  [dbo].[DimParameter] K ON k.ParameterAlt_Key = A.RestructureTypeAlt_Key AND k.DimParameterName='TypeofRestructuring'

					 AND K.EffectiveFromTimeKey<=@TimeKey and K.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN  [dbo].[DimParameter] L ON L.ParameterAlt_Key = A.RestructureCatgAlt_Key AND L.DimParameterName='RestructureFacility'

					 AND L.EffectiveFromTimeKey<=@TimeKey and L.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN  [dbo].[DimParameter] M ON M.ParameterAlt_Key = A.BankingRelationTypeAlt_Key AND M.DimParameterName='BankingRelationship'

					 AND M.EffectiveFromTimeKey<=@TimeKey and M.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN  [dbo].[DimParameter] N ON N.ParameterAlt_Key = A.COVID_OTR_CatgAlt_Key AND N.DimParameterName='Covid - OTR Category'

					 AND N.EffectiveFromTimeKey<=@TimeKey and N.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN  [dbo].[DimAssetClass] X ON X.AssetClassAlt_Key = O.CrntQtrAssetClass 

					 AND X.EffectiveFromTimeKey<=@TimeKey and X.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN  [dbo].[DimAssetClass] T ON T.AssetClassAlt_Key = O.PrevQtrAssetClass 

					 AND T.EffectiveFromTimeKey<=@TimeKey and T.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN  [dbo].[DimParameter] U ON U.ParameterAlt_Key = O.MonitoringPeriodStatus AND U.DimParameterName='StatusofMonitoringPeriod'

					 AND U.EffectiveFromTimeKey<=@TimeKey and U.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN  [dbo].[DimParameter] V ON V.ParameterAlt_Key = O.SpecifiedPeriodStatus AND V.DimParameterName='StatusofSpecificPeriod'

					 AND V.EffectiveFromTimeKey<=@TimeKey and V.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN  [dbo].[DimSegment] W ON W.EWS_SegmentAlt_Key =  B.segmentcode

					 AND W.EffectiveFromTimeKey<=@TimeKey and W.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN  DimAcBuSegment DBS on  B.segmentcode = DBS.AcBuSegmentCode

					 AND DBS.EffectiveFromTimeKey<=@TimeKey and DBS.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN (Select ParameterAlt_Key,ParameterName,'CovidMoratorium' As TableName

		 from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey And DimParameterName='DimYesNoNA')S ON S.ParameterAlt_Key=A.FlgMorat

					 --LEFT JOIN #Previous P ON P.AccountEntityId=A.AccountEntityId
		LEFT JOIN (Select ParameterAlt_Key,ParameterName,'InvestmentGrade' As TableName

					  from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey And DimParameterName='DimYesNoNA')
					  Z ON Z.ParameterName=A.InvestmentGrade

					  LEFT JOIN (	Select 		
									ParameterAlt_Key
									,ParameterName
									,'EquityConversionYN' As TableName									
									 from DimParameter 
									Where EffectiveFromTimeKey<=@TimeKey
									And EffectiveToTimeKey>=@TimeKey
									And DimParameterName='DimYesNo')YY ON YY.ParameterAlt_Key = A.EquityConversionYN
					 WHERE A.EffectiveFromTimeKey <= @TimeKey

                           AND A.EffectiveToTimeKey >= @TimeKey

                           --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')

                           AND A.EntityKey IN

                     (

                         SELECT MAX(EntityKey)

                         FROM [DBO].[AdvAcRestructureDetail_Mod]

                         WHERE EffectiveFromTimeKey <= @TimeKey

                               AND EffectiveToTimeKey >= @TimeKey

                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')

                         GROUP BY AccountEntityId

                     )

                 ) A 

                      

                 

                 GROUP BY A.AccountEntityId

								,A.SystemACID

								,A.SourceName

								,A.CustomerId

								,A.CustomerName

								,A.UCIF_ID

								,A.CurrencyAlt_Key

								,A.CurrencyName

								,A.AccountOpenDate

								,A.SchemeType

								,A.Productcode

								,A.ProductDescription

								,A.segmentcode

								,A.SegmentDescription

								,A.RevisedBusinessSegment

								,A.BankingRelationTypeAlt_Key

								,A.[BankingRelationship]

								,A.SanctionLimit

								,A.SanctionLimitDt

								--,A.AssetClassAlt_Key

								,A.PreRestructureAssetClassAlt_Key

								,A.AssetClassName

								,A.NpaDt

							    ,A.DtofFirstDisb

								,A.RestructureTypeAlt_Key

								,A.RestructureType

								,A.RestructureCatgAlt_Key

								,A.RestructureFacility

								,A.PreRestrucDefaultDate

							    ,A.PreAssetClassName

							    ,A.PreRestrucNPA_Date

								,A.PostAssetClassName

								--,A.Npa_Qtr

								,A.RestructureDt

								,A.RestructureProposalDt

								,A.RestructureAmt

								,A.RestructureApprovingAuthority

							    ,A.RestructureApprovalDt

								,A.POS_RepayStartDate

								,A.RestructurePOS 

								,A.IntRepayStartDate

								--,A.RefDate

								,A.InvocationDate

								,A.EquityConversionYN

							    ,A.ConversionDate

								,A.Is_COVID_Morat

								,A.Covid_Morit

							    ,A.parameterAlt_Key

								,A.COVID_OTR_Catg

								,A.ReportingBank

								,A.ICA_SignDate

								,A.Is_InvestmentGrade
								,A.StatusofSpecificPeriod
								,A.[Status_Current_Quarter]

								,A.[Status_previous_Quarter]

								,A.[Status_of_MoniroringPeriod]

								--,A.[Status_of_Specified_Period]

								,A.CreditProvision

							    ,A.DFVProvision

							    ,A.MTMProvision

								,A.TotalProv

								,A.[Percentage]

								,A.TotalProvisionPrevious

								,A.AuthorisationStatus, 

								A.EffectiveFromTimeKey, 

								A.EffectiveToTimeKey, 

								A.CreatedBy, 

								A.DateCreated, 

								A.ApprovedBy, 

								A.DateApproved, 

								A.ModifiedBy, 

								A.DateModified,

								A.CRILIC_Fst_DefaultDate

								,A.Status_of_MoniroringPeriodAlt_Key

								,A.Status_of_Specified_PeriodAlt_Key

								--,A.RevisedBusSegAlt_Key

								,A.CrModBy

								,A.CrModDate

								,A.CrAppBy

								,A.CrAppDate

								,A.ModAppBy

								,A.ModAppDate

								,A.PreRestructureNPA_Prov

                               ,A.EquityConversionYN

                            ,EquityConversionYNName

							,A.CrntQtrAssetClass

							,A.PrevQtrAssetClass

							,A.MonitoringPeriodStatus

							,A.PrevQtrTotalProvision

							,A.AcBuSegmentDescription
							,A.changeFields;



                 SELECT *

                 FROM

                 (

                     SELECT ROW_NUMBER() OVER(ORDER BY AccountEntityId) AS RowNumber, 

                            COUNT(*) OVER() AS TotalCount, 

                        'RestructureMaster' TableName, 

                            *

                     FROM

                     (

                         SELECT *

                         FROM #temp A

                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'

                     ) AS DataPointOwner

                 ) AS DataPointOwner

                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1

                 --      AND RowNumber <= (@PageNo * @PageSize);

             END;

             ELSE


print 'NANDA1'

			 /*  IT IS Used For GRID Search which are Pending for Authorization    */

			 IF (@OperationFlag in (16,17))



             BEGIN

			 IF OBJECT_ID('TempDB..#temp16') IS NOT NULL

                 DROP TABLE #temp16;

                 SELECT distinct A.AccountEntityId

								,A.SystemACID

								,A.SourceName

								,A.CustomerId

								,A.CustomerName

								,A.UCIF_ID

								,A.CurrencyAlt_Key

								,A.CurrencyName

								,A.AccountOpenDate

								,A.SchemeType

								,A.Productcode

								,A.ProductDescription

								,A.segmentcode

								,A.SegmentDescription

								,A.RevisedBusinessSegment

								,A.BankingRelationTypeAlt_Key

								,A.[BankingRelationship]

								,A.SanctionLimit

								,A.SanctionLimitDt

								--,A.AssetClassAlt_Key

								,A.PreRestructureAssetClassAlt_Key

								,A.AssetClassName

								,A.NpaDt

							    ,A.DtofFirstDisb

								,A.RestructureTypeAlt_Key

								,A.RestructureType

								,A.RestructureCatgAlt_Key

								,A.RestructureFacility

								,A.PreRestrucDefaultDate

							    ,A.PreAssetClassName

							    ,A.PreRestrucNPA_Date

								,A.PostAssetClassName

								--,A.Npa_Qtr

								,A.RestructureDt

								,A.RestructureProposalDt

								,A.RestructureAmt

								,A.RestructureApprovingAuthority

							    ,A.RestructureApprovalDt

								,A.POS_RepayStartDate

								,A.RestructurePOS 

								,A.IntRepayStartDate

								--,A.RefDate

								,A.InvocationDate

								--,A.EquityConversionYN

							    ,A.ConversionDate

								,A.Is_COVID_Morat

								,A.Covid_Morit

							    ,A.parameterAlt_Key

								,A.COVID_OTR_Catg

								,A.ReportingBank

								,A.ICA_SignDate

								,A.Is_InvestmentGrade
								,A.StatusofSpecificPeriod
								,A.[Status_Current_Quarter]

								,A.[Status_previous_Quarter]

								,A.[Status_of_MoniroringPeriod]

								--,A.[Status_of_Specified_Period]

								,A.CreditProvision

							    ,A.DFVProvision

							    ,A.MTMProvision

								,A.TotalProv

								,A.[Percentage]

								,A.TotalProvisionPrevious

								,A.AuthorisationStatus, 

								A.EffectiveFromTimeKey, 

								A.EffectiveToTimeKey, 

								A.CreatedBy, 

								A.DateCreated, 

								A.ApprovedBy, 

								A.DateApproved, 

								A.ModifiedBy, 

								A.DateModified,

								A.CRILIC_Fst_DefaultDate

								,A.Status_of_MoniroringPeriodAlt_Key

								,A.StatusofSpecificPeriod As Status_of_Specified_PeriodAlt_Key

							--	,A.RevisedBusSegAlt_Key

								,A.CrModBy

								,A.CrModDate

								,A.CrAppBy

								,A.CrAppDate

								,A.ModAppBy

								,A.ModAppDate

								,A.PreRestructureNPA_Prov

                               
                                ,A.EquityConversionYN

                            ,A.EquityConversionYNName

									,A.CrntQtrAssetClass

							,A.PrevQtrAssetClass

							,A.MonitoringPeriodStatus

							,A.PrevQtrTotalProvision

							,A.AcBuSegmentDescription
							,A.changeFields

                 INTO #temp16

                 FROM 

                 (

                     SELECT 

							A.AccountEntityId

								,B.SystemACID

								,C.SourceName

								,D.CustomerId

								,D.CustomerName

								,D.UCIF_ID

								,H.CurrencyCode CurrencyAlt_Key

								,H.CurrencyName

									--,Convert(Date,B.AccountOpenDate,103)AccountOpenDate

								,case when ISNULL(B.AccountOpenDate,'1900-01-01')='1900-01-01' then NULL else convert(varchar(10),cast(B.AccountOpenDate as date),103) end  AccountOpenDate 

								,B.FacilityType as SchemeType

								,G.ProductCode AS  Productcode

								,G.ProductName AS  ProductDescription

								,B.segmentcode

								--,P.SegmentDescription SegmentDescription

								--,W.EWS_SegmentName AS SegmentDescription
								,DBS.AcBuSegmentDescription AS SegmentDescription

										,DBS.AcBuSegmentDescription As RevisedBusinessSegment

								,A.BankingRelationTypeAlt_Key

								,M.ParameterName 'BankingRelationship'

								,B.CurrentLimit as SanctionLimit

								--,Convert(Date,B.CurrentLimitDt,103) as SanctionLimitDt

								,case when ISNULL(B.CurrentLimitDt,'1900-01-01')='1900-01-01' then NULL else convert(varchar(10),cast(B.CurrentLimitDt as date),103) end SanctionLimitDt

								--,E.AssetClassAlt_Key -----------chk

								,A.PreRestructureAssetClassAlt_Key

								,J.AssetClassName

								,case when ISNULL(F.NpaDt,'1900-01-01')='1900-01-01' then NULL else convert(varchar(10),cast(F.NpaDt as date),103) end NpaDt 

							    --,Convert(Date,B.DtofFirstDisb,103)DtofFirstDisb

								,case when ISNULL(B.DtofFirstDisb,'1900-01-01')='1900-01-01' then NULL else convert(varchar(10),cast(B.DtofFirstDisb as date),103) end DtofFirstDisb 

								,A.RestructureTypeAlt_Key

								,k.ParameterName AS RestructureType

								,A.RestructureCatgAlt_Key

								,L.ParameterName AS RestructureFacility

								--,Convert(Date,A.PreRestrucDefaultDate,103)PreRestrucDefaultDate

								,case when ISNULL(A.PreRestrucDefaultDate,'1900-01-01')='1900-01-01' then NULL else convert(varchar(10),cast(A.PreRestrucDefaultDate as date),103) end PreRestrucDefaultDate 

							    ,Q.AssetClassName PreAssetClassName

							    --,Convert(Date,Y.NPADt,103)PreRestrucNPA_Date

								,case when ISNULL(Y.NPADt,'1900-01-01')='1900-01-01' then NULL else convert(varchar(10),cast(Y.NPADt as date),103) end PreRestrucNPA_Date 

								,R.AssetClassName PostAssetClassName

								--,A.Npa_Qtr

								--,Convert(Date,A.RestructureDt,103)RestructureDt

								,case when ISNULL(A.RestructureDt,'1900-01-01')='1900-01-01' then NULL else convert(varchar(10),cast(A.RestructureDt as date),103) end RestructureDt 

								--,Convert(Date,A.RestructureProposalDt,103)RestructureProposalDt

								,case when ISNULL(A.RestructureProposalDt,'1900-01-01')='1900-01-01' then NULL else convert(varchar(10),cast(A.RestructureProposalDt as date),103) end RestructureProposalDt

								,A.RestructureAmt

								,A.RestructureApprovingAuthority

							    --,Convert(Date,A.RestructureApprovalDt,103)RestructureApprovalDt

								,case when ISNULL(A.RestructureApprovalDt,'1900-01-01')='1900-01-01' then NULL else convert(varchar(10),cast(A.RestructureApprovalDt as date),103) end RestructureApprovalDt

								--,Convert(Date,A.PrincRepayStartDate,103) POS_RepayStartDate

								,case when ISNULL(A.PrincRepayStartDate,'1900-01-01')='1900-01-01' then NULL else convert(varchar(10),cast(A.PrincRepayStartDate as date),103) end POS_RepayStartDate

								,A.RestructurePOS 

								--,Convert(Date,A.IntRepayStartDate,103)IntRepayStartDate

								 ,case when ISNULL(A.InttRepayStartDate,'1900-01-01')='1900-01-01' then NULL else convert(varchar(10),cast(A.InttRepayStartDate as date),103) end IntRepayStartDate

								--,Convert(Date,A.RefDate,103)RefDate

								--,convert(varchar(10),cast(A.RefDate as date),103) RefDate

								--,Convert(Date,A.InvocationDate,103)InvocationDate

								,case when ISNULL(A.InvocationDate,'1900-01-01')='1900-01-01' then NULL else convert(varchar(10),cast(A.InvocationDate as date),103) end InvocationDate

							--	,A.EquityConversionYN

							    --,Convert(Date,A.ConversionDate,103)ConversionDate

								--,convert(varchar(10),cast(A.ConversionDate as date),103) ConversionDate
								,case when ISNULL(A.ConversionDate,'1900-01-01')='1900-01-01' then NULL else convert(varchar(10),cast(A.ConversionDate as date),103) end  ConversionDate 
								,S.ParameterAlt_Key as Is_COVID_Morat

								,S.ParameterName Covid_Morit

							    ,N.parameterAlt_Key

								,N.ParameterName as COVID_OTR_Catg

								,A.FstDefaultReportingBank ReportingBank

								--,Convert(Date,A.ICA_SignDate,103) ICA_SignDate

								,case when ISNULL(A.ICA_SignDate,'1900-01-01')='1900-01-01' then NULL else convert(varchar(10),cast(A.ICA_SignDate as date),103) end ICA_SignDate 

								,A.InvestmentGrade as Is_InvestmentGrade
								,A.StatusofSpecificPeriod
								--,P.[Status_Current_Quarter]

								--,P.[Status_previous_Quarter]

								--,P.[Status_of_MoniroringPeriod]

								--,P.[Status_of_Specified_Period]

								--,P.TotalProvisionPrevious

								,O.PrevQtrTotalProvision as TotalProvisionPrevious

								,X.AssetClassName as Status_Current_Quarter

								,T.AssetClassName as Status_previous_Quarter

								,U.ParameterName as Status_of_MoniroringPeriod

								--,V.ParameterName as Status_of_Specified_Period

								,A.CreditProvision

							    ,A.DFVProvision

							    ,A.MTMProvision

								,E.TotalProv

								,Round((E.TotalProv/E.Balance)*100,2) as [Percentage]

								--,Convert(Date,A.CRILIC_Fst_DefaultDate,103)CRILIC_Fst_DefaultDate

								,case when ISNULL(A.CRILIC_Fst_DefaultDate,'1900-01-01')='1900-01-01' then NULL else convert(varchar(10),cast(A.CRILIC_Fst_DefaultDate as date),103) end CRILIC_Fst_DefaultDate

								,isnull(A.AuthorisationStatus, 'A') AuthorisationStatus, 

								A.EffectiveFromTimeKey, 

								A.EffectiveToTimeKey, 

								A.CreatedBy, 

								Convert(Varchar(20),A.DateCreated,103)DateCreated, 

								A.ApprovedBy, 

								Convert(Date,A.DateApproved,103)DateApproved, 

								A.ModifiedBy, 

								Convert(Date,A.DateModified,103)DateModified

								--,P.Status_of_MoniroringPeriodAlt_Key

								--,P.Status_of_Specified_PeriodAlt_Key

								,O.MonitoringPeriodStatus AS Status_of_MoniroringPeriodAlt_Key

								,A.StatusofSpecificPeriod As Status_of_Specified_PeriodAlt_Key

								--,A.RevisedBusSegAlt_Key

								,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy

							,IsNull(A.DateModified,A.DateCreated)as CrModDate

							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy

							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate

							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy

							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate

							,A.PreRestructureNPA_Prov

                            ,A.EquityConversionYN

                            ,YY.ParameterName as EquityConversionYNName

							,o.CrntQtrAssetClass

							,o.PrevQtrAssetClass

							,o.MonitoringPeriodStatus

							,o.PrevQtrTotalProvision

							,DBS.AcBuSegmentDescription
							,A.changeFields

					 FROM		 [dbo].[AdvAcRestructureDetail_Mod] A

					 INNER JOIN  [DBO].[AdvAcBasicDetail] B ON B.AccountEntityId =A.AccountEntityId

					 AND B.EffectiveFromTimeKey<=@TimeKey and B.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN  [dbo].[DIMSOURCEDB] C ON C.SourceAlt_Key = B.SourceAlt_Key

					 AND C.EffectiveFromTimeKey<=@TimeKey and C.EffectiveToTimeKey>=@TimeKey

					 INNER JOIN  [DBO].[CustomerBasicDetail] D ON D.CustomerId= A.RefCustomerId

					 AND D.EffectiveFromTimeKey<=@TimeKey and D.EffectiveToTimeKey>=@TimeKey

					 INNER JOIN  [DBO].[AdvAcBalanceDetail] E ON E.AccountEntityId= A.AccountEntityId

					 AND E.EffectiveFromTimeKey<=@TimeKey and E.EffectiveToTimeKey>=@TimeKey

					 INNER JOIN  [DBO].[AdvAcFinancialDetail] F ON F.AccountEntityId= A.AccountEntityId

					 AND F.EffectiveFromTimeKey<=@TimeKey and F.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN [PRO].[AdvAcRestructureCal] O ON O.AccountEntityId=B.AccountEntityId

					 AND O.EffectiveFromTimeKey<=@TimeKey and O.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN  [DBO].[AdvCustNPADetail] Y  ON Y.RefCustomerID= A.RefCustomerId

					 AND Y.EffectiveFromTimeKey<=@TimeKey and Y.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN  [dbo].[DimProduct] G ON G.ProductAlt_Key = B.ProductAlt_Key

					 AND G.EffectiveFromTimeKey<=@TimeKey and G.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN  [dbo].[DimCurrency] H ON H.CurrencyAlt_Key = B.CurrencyAlt_Key

					 AND H.EffectiveFromTimeKey<=@TimeKey and H.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN  [dbo].[DimAssetClass] J ON J.AssetClassAlt_Key =  A.PreRestructureAssetClassAlt_Key

					 AND J.EffectiveFromTimeKey<=@TimeKey and J.EffectiveToTimeKey>=@TimeKey 

					 LEFT JOIN  [dbo].[DimAssetClass] Q ON Q.AssetClassAlt_Key = Y.Cust_AssetClassAlt_Key 

					 AND Q.EffectiveFromTimeKey<=@TimeKey and Q.EffectiveToTimeKey>=@TimeKey 

					 LEFT JOIN  [dbo].[DimAssetClass] R ON R.AssetClassAlt_Key = A.PostRestrucAssetClass 

					 AND R.EffectiveFromTimeKey<=@TimeKey and R.EffectiveToTimeKey>=@TimeKey     

					 LEFT JOIN  [dbo].[DimParameter] K ON k.ParameterAlt_Key = A.RestructureTypeAlt_Key AND k.DimParameterName='TypeofRestructuring'

					 AND K.EffectiveFromTimeKey<=@TimeKey and K.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN  [dbo].[DimParameter] L ON L.ParameterAlt_Key = A.RestructureCatgAlt_Key AND L.DimParameterName='RestructureFacility'

					 AND L.EffectiveFromTimeKey<=@TimeKey and L.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN  [dbo].[DimParameter] M ON M.ParameterAlt_Key = A.BankingRelationTypeAlt_Key AND M.DimParameterName='BankingRelationship'

					 AND M.EffectiveFromTimeKey<=@TimeKey and M.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN  [dbo].[DimParameter] N ON N.ParameterAlt_Key = A.COVID_OTR_CatgAlt_Key AND N.DimParameterName='Covid - OTR Category'

					 AND N.EffectiveFromTimeKey<=@TimeKey and N.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN  [dbo].[DimAssetClass] X ON X.AssetClassAlt_Key = O.CrntQtrAssetClass 

					 AND X.EffectiveFromTimeKey<=@TimeKey and X.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN  [dbo].[DimAssetClass] T ON T.AssetClassAlt_Key = O.PrevQtrAssetClass 

					 AND T.EffectiveFromTimeKey<=@TimeKey and T.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN  [dbo].[DimParameter] U ON U.ParameterAlt_Key = O.MonitoringPeriodStatus AND U.DimParameterName='StatusofMonitoringPeriod'

					 AND U.EffectiveFromTimeKey<=@TimeKey and U.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN  [dbo].[DimParameter] V ON V.ParameterAlt_Key = O.SpecifiedPeriodStatus AND V.DimParameterName='StatusofSpecificPeriod'

					 AND V.EffectiveFromTimeKey<=@TimeKey and V.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN  [dbo].[DimSegment] W ON W.EWS_SegmentAlt_Key =  B.segmentcode

					 AND W.EffectiveFromTimeKey<=@TimeKey and W.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN DimAcBuSegment DBS on  B.segmentcode = DBS.AcBuSegmentCode

					 AND DBS.EffectiveFromTimeKey<=@TimeKey and DBS.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN (Select ParameterAlt_Key,ParameterName,'CovidMoratorium' As TableName

		 from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey And DimParameterName='DimYesNoNA')S ON S.ParameterAlt_Key=A.FlgMorat

					 --LEFT JOIN #Previous P ON P.AccountEntityId=A.AccountEntityId
LEFT JOIN (Select ParameterAlt_Key,ParameterName,'InvestmentGrade' As TableName

					  from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey And DimParameterName='DimYesNoNA')
					  Z ON Z.ParameterName=A.InvestmentGrade

					  LEFT JOIN (	Select 		
									ParameterAlt_Key
									,ParameterName
									,'EquityConversionYN' As TableName									
									 from DimParameter 
									Where EffectiveFromTimeKey<=@TimeKey
									And EffectiveToTimeKey>=@TimeKey
									And DimParameterName='DimYesNo')YY ON YY.ParameterAlt_Key = A.EquityConversionYN

					 WHERE A.EffectiveFromTimeKey <= @TimeKey

                           AND A.EffectiveToTimeKey >= @TimeKey

                           --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')

                           AND A.EntityKey IN

                     (

                         SELECT MAX(EntityKey)

                         FROM [dbo].[AdvAcRestructureDetail_Mod]

                         WHERE EffectiveFromTimeKey <= @TimeKey

                               AND EffectiveToTimeKey >= @TimeKey

                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')

                         GROUP BY AccountEntityId

                     )

                 ) A 

                      

                 

                 GROUP BY A.AccountEntityId

								,A.SystemACID

								,A.SourceName

								,A.CustomerId

								,A.CustomerName

								,A.UCIF_ID

								,A.CurrencyAlt_Key

								,A.CurrencyName

								,A.AccountOpenDate

								,A.SchemeType

								,A.Productcode

								,A.ProductDescription

								,A.segmentcode

								,A.SegmentDescription

								,A.RevisedBusinessSegment

								,A.BankingRelationTypeAlt_Key

								,A.[BankingRelationship]

								,A.SanctionLimit

								,A.SanctionLimitDt

								--,A.AssetClassAlt_Key

								,A.PreRestructureAssetClassAlt_Key

								,A.AssetClassName

								,A.NpaDt

							    ,A.DtofFirstDisb

								,A.RestructureTypeAlt_Key

								,A.RestructureType

								,A.RestructureCatgAlt_Key

								,A.RestructureFacility

								,A.PreRestrucDefaultDate

							    ,A.PreAssetClassName

							    ,A.PreRestrucNPA_Date

								,A.PostAssetClassName

								--,A.Npa_Qtr

								,A.RestructureDt

								,A.RestructureProposalDt

								,A.RestructureAmt

								,A.RestructureApprovingAuthority

							    ,A.RestructureApprovalDt

								,A.POS_RepayStartDate

								,A.RestructurePOS 

								,A.IntRepayStartDate

								--,A.RefDate

								,A.InvocationDate

								--,A.EquityConversionYN

							    ,A.ConversionDate

								,A.Is_COVID_Morat

								,A.Covid_Morit

							    ,A.parameterAlt_Key

								,A.COVID_OTR_Catg

								,A.ReportingBank

								,A.ICA_SignDate

								,A.Is_InvestmentGrade

								,A.StatusofSpecificPeriod

								,A.[Status_Current_Quarter]

								,A.[Status_previous_Quarter]

								,A.[Status_of_MoniroringPeriod]

								--,A.[Status_of_Specified_Period]

								,A.CreditProvision

							    ,A.DFVProvision

							    ,A.MTMProvision

								,A.TotalProv

								,A.[Percentage]

								,A.TotalProvisionPrevious

								,A.AuthorisationStatus, 

								A.EffectiveFromTimeKey, 

								A.EffectiveToTimeKey, 

								A.CreatedBy, 

								A.DateCreated, 

								A.ApprovedBy, 

								A.DateApproved, 

								A.ModifiedBy, 

								A.DateModified,

								A.CRILIC_Fst_DefaultDate

								,A.Status_of_MoniroringPeriodAlt_Key

								,A.Status_of_Specified_PeriodAlt_Key

								--,A.RevisedBusSegAlt_Key

								,A.CrModBy

								,A.CrModDate

								,A.CrAppBy

								,A.CrAppDate

								,A.ModAppBy

								,A.ModAppDate

								,A.PreRestructureNPA_Prov

                                ,A.EquityConversionYN

                            ,A.EquityConversionYNName
									,A.CrntQtrAssetClass

							,A.PrevQtrAssetClass

							,A.MonitoringPeriodStatus

							,A.PrevQtrTotalProvision

							,A.AcBuSegmentDescription
							,A.changeFields;



                 SELECT *

                 FROM

                 (

                     SELECT ROW_NUMBER() OVER(ORDER BY AccountEntityId) AS RowNumber, 

                            COUNT(*) OVER() AS TotalCount, 

                            'RestructureMaster' TableName, 

                            *

     FROM

                     (

                         SELECT *

                         FROM #temp16 A

                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'

                     ) AS DataPointOwner

                 ) AS DataPointOwner

                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1

                 --      AND RowNumber <= (@PageNo * @PageSize)



   END;





   Else



   IF (@OperationFlag in(20))

             BEGIN

			 IF OBJECT_ID('TempDB..#temp20') IS NOT NULL

                 DROP TABLE #temp20;

                 SELECT A.AccountEntityId

								,A.SystemACID

								,A.SourceName

								,A.CustomerId

								,A.CustomerName

								,A.UCIF_ID

								,A.CurrencyAlt_Key

								,A.CurrencyName

								,A.AccountOpenDate

								,A.SchemeType

								,A.Productcode

								,A.ProductDescription

								,A.segmentcode

								,A.SegmentDescription

								,A.RevisedBusinessSegment

								,A.BankingRelationTypeAlt_Key

								,A.[BankingRelationship]

								,A.SanctionLimit

								,A.SanctionLimitDt

								--,A.AssetClassAlt_Key

								,A.PreRestructureAssetClassAlt_Key

								,A.AssetClassName

								,A.NpaDt

							    ,A.DtofFirstDisb

								,A.RestructureTypeAlt_Key

								,A.RestructureType

								,A.RestructureCatgAlt_Key

								,A.RestructureFacility

								,A.PreRestrucDefaultDate

							    ,A.PreAssetClassName

							    ,A.PreRestrucNPA_Date

								,A.PostAssetClassName

								--,A.Npa_Qtr

								,A.RestructureDt

								,A.RestructureProposalDt

								,A.RestructureAmt

								,A.RestructureApprovingAuthority

							    ,A.RestructureApprovalDt

								,A.POS_RepayStartDate

								,A.RestructurePOS 

								,A.IntRepayStartDate

							--	,A.RefDate

								,A.InvocationDate

								--,A.EquityConversionYN

							    ,A.ConversionDate

								,A.Is_COVID_Morat

								,A.Covid_Morit

							    ,A.parameterAlt_Key

								,A.COVID_OTR_Catg

								,A.ReportingBank

								,A.ICA_SignDate

								,A.Is_InvestmentGrade 

								,A.StatusofSpecificPeriod

								,A.[Status_Current_Quarter]

								,A.[Status_previous_Quarter]

								,A.[Status_of_MoniroringPeriod]

								--,A.[Status_of_Specified_Period]

								,A.CreditProvision

							    ,A.DFVProvision

							    ,A.MTMProvision

								,A.TotalProv

								,A.[Percentage]

								,A.TotalProvisionPrevious

								,A.AuthorisationStatus, 

								A.EffectiveFromTimeKey, 

								A.EffectiveToTimeKey, 

								A.CreatedBy, 

								A.DateCreated, 

								A.ApprovedBy, 

								A.DateApproved, 

								A.ModifiedBy, 

								A.DateModified,

								A.CRILIC_Fst_DefaultDate

								,A.Status_of_MoniroringPeriodAlt_Key

								,A.StatusofSpecificPeriod As Status_of_Specified_PeriodAlt_Key

								--,A.RevisedBusSegAlt_Key

								,A.CrModBy

								,A.CrModDate

								,A.CrAppBy

								,A.CrAppDate

								,A.ModAppBy

								,A.ModAppDate

								,A.PreRestructureNPA_Prov

                                
                                ,A.EquityConversionYN

                            ,A.EquityConversionYNName

									,A.CrntQtrAssetClass

							,A.PrevQtrAssetClass

							,A.MonitoringPeriodStatus

							,A.PrevQtrTotalProvision

							,A.AcBuSegmentDescription
							,A.changeFields

                 INTO #temp20

                 FROM 

                 (

                     SELECT 

							A.AccountEntityId

								,B.SystemACID

								,C.SourceName

								,D.CustomerId

								,D.CustomerName

								,D.UCIF_ID

								,H.CurrencyCode CurrencyAlt_Key

								,H.CurrencyName

									--,Convert(Date,B.AccountOpenDate,103)AccountOpenDate

								,case when ISNULL(B.AccountOpenDate,'1900-01-01')='1900-01-01' then NULL else convert(varchar(10),cast(B.AccountOpenDate as date),103) end  AccountOpenDate 

								,B.FacilityType as SchemeType

								,G.ProductCode AS  Productcode

								,G.ProductName AS  ProductDescription

								,B.segmentcode

								--,P.SegmentDescription SegmentDescription

								--,W.EWS_SegmentName AS SegmentDescription
								,DBS.AcBuSegmentDescription AS SegmentDescription

										,DBS.AcBuSegmentDescription As RevisedBusinessSegment

								,A.BankingRelationTypeAlt_Key

								,M.ParameterName 'BankingRelationship'

								,B.CurrentLimit as SanctionLimit

								--,Convert(Date,B.CurrentLimitDt,103) as SanctionLimitDt

								,case when ISNULL(B.CurrentLimitDt,'1900-01-01')='1900-01-01' then NULL else convert(varchar(10),cast(B.CurrentLimitDt as date),103) end SanctionLimitDt

								--,E.AssetClassAlt_Key -----------chk

								,A.PreRestructureAssetClassAlt_Key



								,J.AssetClassName

							  ,case when ISNULL(F.NpaDt,'1900-01-01')='1900-01-01' then NULL else convert(varchar(10),cast(F.NpaDt as date),103) end NpaDt 

							    --,Convert(Date,B.DtofFirstDisb,103)DtofFirstDisb

								,case when ISNULL(B.DtofFirstDisb,'1900-01-01')='1900-01-01' then NULL else convert(varchar(10),cast(B.DtofFirstDisb as date),103) end DtofFirstDisb 

								,A.RestructureTypeAlt_Key

								,k.ParameterName AS RestructureType

								,A.RestructureCatgAlt_Key

								,L.ParameterName AS RestructureFacility

								--,Convert(Date,A.PreRestrucDefaultDate,103)PreRestrucDefaultDate

								,case when ISNULL(A.PreRestrucDefaultDate,'1900-01-01')='1900-01-01' then NULL else convert(varchar(10),cast(A.PreRestrucDefaultDate as date),103) end PreRestrucDefaultDate 

							    ,Q.AssetClassName PreAssetClassName

							    --,Convert(Date,Y.NPADt,103)PreRestrucNPA_Date

								,case when ISNULL(Y.NPADt,'1900-01-01')='1900-01-01' then NULL else convert(varchar(10),cast(Y.NPADt as date),103) end PreRestrucNPA_Date 

								,R.AssetClassName PostAssetClassName

								--,A.Npa_Qtr

								--,Convert(Date,A.RestructureDt,103)RestructureDt

								,case when ISNULL(A.RestructureDt,'1900-01-01')='1900-01-01' then NULL else convert(varchar(10),cast(A.RestructureDt as date),103) end RestructureDt 

								--,Convert(Date,A.RestructureProposalDt,103)RestructureProposalDt

								,case when ISNULL(A.RestructureProposalDt,'1900-01-01')='1900-01-01' then NULL else convert(varchar(10),cast(A.RestructureProposalDt as date),103) end RestructureProposalDt

								,A.RestructureAmt

								,A.RestructureApprovingAuthority
,case when ISNULL(A.RestructureApprovalDt,'1900-01-01')='1900-01-01' then NULL else convert(varchar(10),cast(A.RestructureApprovalDt as date),103) end RestructureApprovalDt
								--,Convert(Date,A.PrincRepayStartDate,103) POS_RepayStartDate

								--,convert(varchar(10),cast(A.PrincRepayStartDate as date),103) POS_RepayStartDate
								,case when ISNULL(A.PrincRepayStartDate,'1900-01-01')='1900-01-01' then NULL else convert(varchar(10),cast(A.PrincRepayStartDate as date),103) end POS_RepayStartDate
								,A.RestructurePOS 

								--,Convert(Date,A.IntRepayStartDate,103)IntRepayStartDate

								--,convert(varchar(10),cast(A.InttRepayStartDate as date),103) IntRepayStartDate
								 ,case when ISNULL(A.InttRepayStartDate,'1900-01-01')='1900-01-01' then NULL else convert(varchar(10),cast(A.InttRepayStartDate as date),103) end IntRepayStartDate
								--,Convert(Date,A.RefDate,103)RefDate

							--	,convert(varchar(10),cast(A.RefDate as date),103) RefDate

								--,Convert(Date,A.InvocationDate,103)InvocationDate

								--,convert(varchar(10),cast(A.InvocationDate as date),103) InvocationDate
								,case when ISNULL(A.InvocationDate,'1900-01-01')='1900-01-01' then NULL else convert(varchar(10),cast(A.InvocationDate as date),103) end InvocationDate
								--,A.EquityConversionYN

							    --,Convert(Date,A.ConversionDate,103)ConversionDate
								,case when ISNULL(A.ConversionDate,'1900-01-01')='1900-01-01' then NULL else convert(varchar(10),cast(A.ConversionDate as date),103) end  ConversionDate 
								--,convert(varchar(10),cast(A.ConversionDate as date),103) ConversionDate

								,S.ParameterAlt_Key as Is_COVID_Morat

								,S.ParameterName Covid_Morit

							    ,N.parameterAlt_Key

								,N.ParameterName as COVID_OTR_Catg

								,A.FstDefaultReportingBank ReportingBank

								--,Convert(Date,A.ICA_SignDate,103) ICA_SignDate

								,case when ISNULL(A.ICA_SignDate,'1900-01-01')='1900-01-01' then NULL else convert(varchar(10),cast(A.ICA_SignDate as date),103) end ICA_SignDate 

								,A.InvestmentGrade as Is_InvestmentGrade
								,A.StatusofSpecificPeriod
								--,P.[Status_Current_Quarter]

								--,P.[Status_previous_Quarter]

								--,P.[Status_of_MoniroringPeriod]

								--,P.[Status_of_Specified_Period]

								--,P.TotalProvisionPrevious

								,O.PrevQtrTotalProvision as TotalProvisionPrevious

								,X.AssetClassName as Status_Current_Quarter

								,T.AssetClassName as Status_previous_Quarter

								,U.ParameterName as Status_of_MoniroringPeriod

								,V.ParameterName as Status_of_Specified_Period

								,A.CreditProvision

							    ,A.DFVProvision

							    ,A.MTMProvision

								,E.TotalProv

								,Round((E.TotalProv/E.Balance)*100,2) as [Percentage]

								--,Convert(Date,A.CRILIC_Fst_DefaultDate,103)CRILIC_Fst_DefaultDate

								,case when ISNULL(A.CRILIC_Fst_DefaultDate,'1900-01-01')='1900-01-01' then NULL else convert(varchar(10),cast(A.CRILIC_Fst_DefaultDate as date),103) end CRILIC_Fst_DefaultDate

								--,isnull(A.AuthorisationStatus, 'A')

								,A. AuthorisationStatus, 

								A.EffectiveFromTimeKey, 

								A.EffectiveToTimeKey, 

								A.CreatedBy, 

								Convert(Varchar(20),A.DateCreated,103)DateCreated, 

								A.ApprovedBy, 

								Convert(Date,A.DateApproved,103)DateApproved, 

								A.ModifiedBy, 

								Convert(Date,A.DateModified,103)DateModified

								--,P.Status_of_MoniroringPeriodAlt_Key

								--,P.Status_of_Specified_PeriodAlt_Key

								,O.MonitoringPeriodStatus AS Status_of_MoniroringPeriodAlt_Key

								,A.StatusofSpecificPeriod As Status_of_Specified_PeriodAlt_Key

								--,A.RevisedBusSegAlt_Key

								,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy

							,IsNull(A.DateModified,A.DateCreated)as CrModDate

							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy

							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate

							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy

							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate

							,A.PreRestructureNPA_Prov

                            ,A.EquityConversionYN

                            ,YY.ParameterName as EquityConversionYNName

							,o.CrntQtrAssetClass

							,o.PrevQtrAssetClass

							,o.MonitoringPeriodStatus

							,o.PrevQtrTotalProvision

							,DBS.AcBuSegmentDescription
							,A.changeFields

					 FROM		 [dbo].[AdvAcRestructureDetail_Mod] A

					 INNER JOIN  [DBO].[AdvAcBasicDetail] B ON B.AccountEntityId =A.AccountEntityId

					 AND B.EffectiveFromTimeKey<=@TimeKey and B.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN  [dbo].[DIMSOURCEDB] C ON C.SourceAlt_Key = B.SourceAlt_Key

					 AND C.EffectiveFromTimeKey<=@TimeKey and C.EffectiveToTimeKey>=@TimeKey

					 INNER JOIN  [DBO].[CustomerBasicDetail] D ON D.CustomerId= A.RefCustomerId

					 AND D.EffectiveFromTimeKey<=@TimeKey and D.EffectiveToTimeKey>=@TimeKey

					 INNER JOIN  [DBO].[AdvAcBalanceDetail] E ON E.AccountEntityId= A.AccountEntityId

					 AND E.EffectiveFromTimeKey<=@TimeKey and E.EffectiveToTimeKey>=@TimeKey

					 INNER JOIN  [DBO].[AdvAcFinancialDetail] F ON F.AccountEntityId= A.AccountEntityId

					 AND F.EffectiveFromTimeKey<=@TimeKey and F.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN [PRO].[AdvAcRestructureCal] O ON O.AccountEntityId=B.AccountEntityId

					 AND O.EffectiveFromTimeKey<=@TimeKey and O.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN  [DBO].[AdvCustNPADetail] Y  ON Y.RefCustomerID= A.RefCustomerId

					 AND Y.EffectiveFromTimeKey<=@TimeKey and Y.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN  [dbo].[DimProduct] G ON G.ProductAlt_Key = B.ProductAlt_Key

					 AND G.EffectiveFromTimeKey<=@TimeKey and G.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN  [dbo].[DimCurrency] H ON H.CurrencyAlt_Key = B.CurrencyAlt_Key

					 AND H.EffectiveFromTimeKey<=@TimeKey and H.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN  [dbo].[DimAssetClass] J ON J.AssetClassAlt_Key = A.PreRestructureAssetClassAlt_Key

					 AND J.EffectiveFromTimeKey<=@TimeKey and J.EffectiveToTimeKey>=@TimeKey 

					 LEFT JOIN  [dbo].[DimAssetClass] Q ON Q.AssetClassAlt_Key = Y.Cust_AssetClassAlt_Key 

					 AND Q.EffectiveFromTimeKey<=@TimeKey and Q.EffectiveToTimeKey>=@TimeKey 

					 LEFT JOIN  [dbo].[DimAssetClass] R ON R.AssetClassAlt_Key = A.PostRestrucAssetClass 

					 AND R.EffectiveFromTimeKey<=@TimeKey and R.EffectiveToTimeKey>=@TimeKey     

					 LEFT JOIN  [dbo].[DimParameter] K ON k.ParameterAlt_Key = A.RestructureTypeAlt_Key AND k.DimParameterName='TypeofRestructuring'

					 AND K.EffectiveFromTimeKey<=@TimeKey and K.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN  [dbo].[DimParameter] L ON L.ParameterAlt_Key = A.RestructureCatgAlt_Key AND L.DimParameterName='RestructureFacility'

					 AND L.EffectiveFromTimeKey<=@TimeKey and L.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN  [dbo].[DimParameter] M ON M.ParameterAlt_Key = A.BankingRelationTypeAlt_Key AND M.DimParameterName='BankingRelationship'

					 AND M.EffectiveFromTimeKey<=@TimeKey and M.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN  [dbo].[DimParameter] N ON N.ParameterAlt_Key = A.COVID_OTR_CatgAlt_Key AND N.DimParameterName='Covid - OTR Category'

					 AND N.EffectiveFromTimeKey<=@TimeKey and N.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN  [dbo].[DimAssetClass] X ON X.AssetClassAlt_Key = O.CrntQtrAssetClass 

					 AND X.EffectiveFromTimeKey<=@TimeKey and X.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN  [dbo].[DimAssetClass] T ON T.AssetClassAlt_Key = O.PrevQtrAssetClass 

					 AND T.EffectiveFromTimeKey<=@TimeKey and T.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN  [dbo].[DimParameter] U ON U.ParameterAlt_Key = O.MonitoringPeriodStatus AND U.DimParameterName='StatusofMonitoringPeriod'

					 AND U.EffectiveFromTimeKey<=@TimeKey and U.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN  [dbo].[DimParameter] V ON V.ParameterAlt_Key = O.SpecifiedPeriodStatus AND V.DimParameterName='StatusofSpecificPeriod'

					 AND V.EffectiveFromTimeKey<=@TimeKey and V.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN  [dbo].[DimSegment] W ON W.EWS_SegmentAlt_Key =  B.segmentcode

					 AND W.EffectiveFromTimeKey<=@TimeKey and W.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN DimAcBuSegment DBS on  B.segmentcode = DBS.AcBuSegmentCode

					 AND DBS.EffectiveFromTimeKey<=@TimeKey and DBS.EffectiveToTimeKey>=@TimeKey

					 LEFT JOIN (Select ParameterAlt_Key,ParameterName,'CovidMoratorium' As TableName

		 from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey And DimParameterName='DimYesNoNA')S ON S.ParameterAlt_Key=A.FlgMorat

					 --LEFT JOIN #Previous P ON P.AccountEntityId=A.AccountEntityId
         LEFT JOIN (Select ParameterAlt_Key,ParameterName,'InvestmentGrade' As TableName

					  from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey And DimParameterName='DimYesNoNA')
					  Z ON Z.ParameterName=A.InvestmentGrade

					  LEFT JOIN (	Select 		
									ParameterAlt_Key
									,ParameterName
									,'EquityConversionYN' As TableName									
									 from DimParameter 
									Where EffectiveFromTimeKey<=@TimeKey
									And EffectiveToTimeKey>=@TimeKey
									And DimParameterName='DimYesNo')YY ON YY.ParameterAlt_Key = A.EquityConversionYN

					 WHERE A.EffectiveFromTimeKey <= @TimeKey

                           AND A.EffectiveToTimeKey >= @TimeKey

                           AND ISNULL(A.AuthorisationStatus, 'A') IN('1A')

                           AND A.EntityKey IN

                     (

                         SELECT MAX(EntityKey)

                         FROM [dbo].[AdvAcRestructureDetail_Mod]

                         WHERE EffectiveFromTimeKey <= @TimeKey

                               AND EffectiveToTimeKey >= @TimeKey

                               AND AuthorisationStatus IN('1A')

                         GROUP BY AccountEntityId

                     )

                 ) A 

                      

                 

                 GROUP BY A.AccountEntityId

								,A.SystemACID

								,A.SourceName

								,A.CustomerId

								,A.CustomerName

								,A.UCIF_ID

								,A.CurrencyAlt_Key

								,A.CurrencyName

								,A.AccountOpenDate

								,A.SchemeType

								,A.Productcode

								,A.ProductDescription

								,A.segmentcode

								,A.SegmentDescription

								,A.RevisedBusinessSegment

								,A.BankingRelationTypeAlt_Key

								,A.[BankingRelationship]

								,A.SanctionLimit

								,A.SanctionLimitDt

								--,A.AssetClassAlt_Key

								,A.PreRestructureAssetClassAlt_Key

								,A.AssetClassName

								,A.NpaDt

							    ,A.DtofFirstDisb

								,A.RestructureTypeAlt_Key

								,A.RestructureType

								,A.RestructureCatgAlt_Key

								,A.RestructureFacility

								,A.PreRestrucDefaultDate

							    ,A.PreAssetClassName

							    ,A.PreRestrucNPA_Date

								,A.PostAssetClassName

								--,A.Npa_Qtr

								,A.RestructureDt

								,A.RestructureProposalDt

								,A.RestructureAmt

								,A.RestructureApprovingAuthority

							    ,A.RestructureApprovalDt

								,A.POS_RepayStartDate

								,A.RestructurePOS 

								,A.IntRepayStartDate

								--,A.RefDate

								,A.InvocationDate

								--,A.EquityConversionYN

							    ,A.ConversionDate

								,A.Is_COVID_Morat

								,A.Covid_Morit

							    ,A.parameterAlt_Key

								,A.COVID_OTR_Catg

								,A.ReportingBank

								,A.ICA_SignDate

								,A.Is_InvestmentGrade

								,A.StatusofSpecificPeriod


								,A.[Status_Current_Quarter]

								,A.[Status_previous_Quarter]

								,A.[Status_of_MoniroringPeriod]

							--	,A.[Status_of_Specified_Period]

								,A.CreditProvision

							    ,A.DFVProvision

							    ,A.MTMProvision

								,A.TotalProv

								,A.[Percentage]

								,A.TotalProvisionPrevious

								,A.AuthorisationStatus, 

								A.EffectiveFromTimeKey, 

								A.EffectiveToTimeKey, 

								A.CreatedBy, 

								A.DateCreated, 

								A.ApprovedBy, 

								A.DateApproved, 

								A.ModifiedBy, 

								A.DateModified,

								A.CRILIC_Fst_DefaultDate

								,A.Status_of_MoniroringPeriodAlt_Key

								,A.Status_of_Specified_PeriodAlt_Key

								--,A.RevisedBusSegAlt_Key

								,A.CrModBy

								,A.CrModDate

								,A.CrAppBy

								,A.CrAppDate

								,A.ModAppBy

								,A.ModAppDate

								,A.PreRestructureNPA_Prov

                                ,A.EquityConversionYN

                            ,A.EquityConversionYNName

									,A.CrntQtrAssetClass

							,A.PrevQtrAssetClass

							,A.MonitoringPeriodStatus

							,A.PrevQtrTotalProvision

							,A.AcBuSegmentDescription

							,A.changeFields

                 SELECT *

                 FROM

                 (

                     SELECT ROW_NUMBER() OVER(ORDER BY AccountEntityId) AS RowNumber, 

                            COUNT(*) OVER() AS TotalCount, 

                            'RestructureMaster' TableName, 

     *

                     FROM

                     (

                         SELECT *

                         FROM #temp20 A

                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'

                     ) AS DataPointOwner

                 ) AS DataPointOwner

                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1

                 --      AND RowNumber <= (@PageNo * @PageSize)



   END;



   END TRY

	BEGIN CATCH

	

	INSERT INTO dbo.Error_Log

				SELECT ERROR_LINE() as ErrorLine,ERROR_MESSAGE()ErrorMessage,ERROR_NUMBER()ErrorNumber

				,ERROR_PROCEDURE()ErrorProcedure,ERROR_SEVERITY()ErrorSeverity,ERROR_STATE()ErrorState

				,GETDATE()



	SELECT ERROR_MESSAGE()

	--RETURN -1

   

	END CATCH



select *,'RestucturedAsset' AS tableName from MetaScreenFieldDetail where ScreenName='RestucturedAsset'

  

  

    END;



GO