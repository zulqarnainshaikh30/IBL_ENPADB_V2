SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--sp_rename 'RestructureMasterViewList','RestructureMasterViewList_30042022'
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[RestructureMasterViewList] 
--declare
	--@OperationFlag  INT         = 1
   --,
   @RefSystemAcId  VARCHAR(30)			= ''
AS
     
	 BEGIN

SET NOCOUNT ON;
Declare @TimeKey as Int
	SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')

--IF Object_Id ('TempDB..#Previous') Is Not Null
--Drop Table #Previous

--Select AccountEntityId,'SUB-STANDARD' as NPA_QTR,
--		'SUB-STANDARD' as 'Status_Current_Quarter'
--							,'SUB-STANDARD' as 'Status_previous Quarter'
--							,'Under Monitoring Period' as 'Status of MoniroringPeriod'
--							,'Under Specified Period' as 'Status of Specified Period'
--							,150000 as TotalProvisionPrevious

--							into #Previous

-- from dbo.AdvAcBasicDetail where AccountEntityId=202

--Select *

--							into #Previous

-- from (
 
--Select AccountEntityId,'Corporate Loan' as SegmentDescription,'SUB-STANDARD' as 'Status_Current_Quarter','SUB-STANDARD' as 'Status_previous_Quarter'
--,1 as 'Status_of_MoniroringPeriodAlt_Key',1 as 'Status_of_Specified_PeriodAlt_Key','Under Monitoring Period' as 'Status_of_MoniroringPeriod','Under Specified Period' as 'Status_of_Specified_Period'
--,0 as TotalProvisionPrevious

-- from dbo.AdvAcBasicDetail where AccountEntityId=202

-- UNION ALL

 
--Select AccountEntityId,'Corporate Loan' as SegmentDescription,'DOUBTFUL I' as 'Status_Current_Quarter','DOUBTFUL I' as 'Status_previous_Quarter'
--,1 as 'Status_of_MoniroringPeriodAlt_Key',1 as 'Status_of_Specified_PeriodAlt_Key','Under Monitoring Period' as 'Status_of_MoniroringPeriod','Under Specified Period' as 'Status_of_Specified_Period'
--,0 as TotalProvisionPrevious

-- from dbo.AdvAcBasicDetail where AccountEntityId=101

-- UNION ALL

 
--Select AccountEntityId,'Corporate Loan' as SegmentDescription,'DOUBTFUL II' as 'Status_Current_Quarter','DOUBTFUL II' as 'Status_previous_Quarter'
--,1 as 'Status_of_MoniroringPeriodAlt_Key',1 as 'Status_of_Specified_PeriodAlt_Key','Under Monitoring Period' as 'Status_of_MoniroringPeriod','Under Specified Period' as 'Status_of_Specified_Period'
--,0 as TotalProvisionPrevious

-- from dbo.AdvAcBasicDetail where AccountEntityId=102

-- UNION ALL

 
--Select AccountEntityId,'Professional Loan - MSE' as SegmentDescription,'SUB-STANDARD' as 'Status_Current_Quarter','SUB-STANDARD' as 'Status_previous_Quarter'
--,1 as 'Status_of_MoniroringPeriodAlt_Key',1 as 'Status_of_Specified_PeriodAlt_Key','Under Monitoring Period' as 'Status_of_MoniroringPeriod','Under Specified Period' as 'Status_of_Specified_Period'
--,0 as TotalProvisionPrevious

-- from dbo.AdvAcBasicDetail where AccountEntityId=103

-- UNION ALL

 
--Select AccountEntityId,'Professional Loan - MSE' as SegmentDescription,'SUB-STANDARD' as 'Status_Current_Quarter','SUB-STANDARD' as 'Status_previous_Quarter'
--,1 as 'Status_of_MoniroringPeriodAlt_Key',1 as 'Status_of_Specified_PeriodAlt_Key','Under Monitoring Period' as 'Status_of_MoniroringPeriod','Under Specified Period' as 'Status_of_Specified_Period'
--,0 as TotalProvisionPreviousA.RefSystemAcId=@RefSystemAcId

-- from dbo.AdvAcBasicDetail where AccountEntityId=104
--)A
-----------------------------------------------------------JAYADEV-08052021------------------------------------------------------------------------------------------------
--Declare @TimeKey as Int
--set @TimeKey = 49999
--Declare @RefSystemAcId  VARCHAR(30)
--set @RefSystemAcId = '9987880000000001'
IF  EXISTS(SELECT * FROM [CurDat].[AdvAcRestructureDetail] A WHERE (A.EffectiveFromTimeKey<=@Timekey AND A.EffectiveToTimeKey>=@Timekey) 
												AND A.RefSystemAcId=@RefSystemAcId
												 AND ISNULL(A.AuthorisationStatus, 'A') = 'A')
												
BEGIN
IF OBJECT_ID('TempDB..#temp') IS NOT NULL
				 BEGIN
                 DROP TABLE  #temp;
				 END
                SELECT		A.AccountEntityId
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
								--,A.RevisedBusinessSegment
								,A.BankingRelationTypeAlt_Key
								,A.[BankingRelationship]
								,A.SanctionLimit
								,A.SanctionLimitDt
								,A.AssetClassAlt_Key
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
								--,A.IsEquityCoversion
							    ,A.ConversionDate
								,A.Is_COVID_Morat

								,A.Covid_Morit
							    ,A.parameterAlt_Key
								,A.COVID_OTR_Catg

								,A.ReportingBank
								,A.ICA_SignDate
								,A.InvestmentGrade
								,A.[Status_Current_Quarter]
								,A.[Status_previous_Quarter]
								,A.[Status_of_MoniroringPeriod]
								,A.[Status_of_Specified_Period]
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
							,A.CrntQtrAssetClass
							,A.PrevQtrAssetClass
							,A.MonitoringPeriodStatus
							,A.PrevQtrTotalProvision
							,A.AcBuSegmentDescription
                 INTO #temp
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
								,Convert(Date,B.AccountOpenDate,103)AccountOpenDate
								,B.FacilityType as SchemeType
								,G.ProductCode AS  Productcode
								,G.ProductName AS  ProductDescription
								,B.segmentcode
								--,P.SegmentDescription SegmentDescription
								,DBS.AcBuSegmentDescription AS SegmentDescription
								--,A.RevisedBusinessSegment
								,A.BankingRelationTypeAlt_Key
								,M.ParameterName 'BankingRelationship'
								,B.CurrentLimit as SanctionLimit
								,Convert(Date,B.CurrentLimitDt,103) as SanctionLimitDt
								,E.AssetClassAlt_Key
								,J.AssetClassName
								,F.NpaDt
							    ,Convert(Date,B.DtofFirstDisb,103)DtofFirstDisb
								,A.RestructureTypeAlt_Key
								,k.ParameterName AS RestructureType
								,A.RestructureCatgAlt_Key
								,L.ParameterName AS RestructureFacility
								,Convert(Date,A.PreRestrucDefaultDate,103)PreRestrucDefaultDate
							    ,Q.AssetClassName PreAssetClassName
							    ,Convert(Date,Y.NPADt,103)PreRestrucNPA_Date
								,R.AssetClassName PostAssetClassName
								--,A.Npa_Qtr
								,Convert(Date,A.RestructureDt,103)RestructureDt
								,Convert(Date,A.RestructureProposalDt,103)RestructureProposalDt
								,A.RestructureAmt
								,A.RestructureApprovingAuthority
							    ,Convert(Date,A.RestructureApprovalDt,103)RestructureApprovalDt
								,Convert(Date,A.PrincRepayStartDate,103) POS_RepayStartDate
								,A.RestructurePOS 
								,Convert(Date,A.InttRepayStartDate,103)IntRepayStartDate
							--	,Convert(Date,A.RefDate,103)RefDate
								,Convert(Date,A.InvocationDate,103)InvocationDate
								--,A.IsEquityCoversion
							    ,Convert(Date,A.ConversionDate,103)ConversionDate
								,S.ParameterAlt_Key as Is_COVID_Morat
								,S.ParameterName Covid_Morit
							    ,N.parameterAlt_Key
								,N.ParameterName as COVID_OTR_Catg
								,A.FstDefaultReportingBank ReportingBank
								,Convert(Date,A.ICA_SignDate,103) ICA_SignDate
								,A.InvestmentGrade								
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
								,Convert(Date,A.CRILIC_Fst_DefaultDate,103)CRILIC_Fst_DefaultDate
								,isnull(A.AuthorisationStatus, 'A') AuthorisationStatus, 
								A.EffectiveFromTimeKey, 
								A.EffectiveToTimeKey, 
								A.CreatedBy, 
								Convert(Varchar(20),A.DateCreated,105)DateCreated, 
								A.ApprovedBy, 
								Convert(Date,A.DateApproved,103)DateApproved, 
								A.ModifiedBy, 
								Convert(Date,A.DateModified,103)DateModified
								--,P.Status_of_MoniroringPeriodAlt_Key
								--,P.Status_of_Specified_PeriodAlt_Key
								,O.MonitoringPeriodStatus AS Status_of_MoniroringPeriodAlt_Key
								,O.SpecifiedPeriodStatus AS Status_of_Specified_PeriodAlt_Key
								--,A.RevisedBusSegAlt_Key
								,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
							,A.PreRestructureNPA_Prov
                            ,A.EquityConversionYN
							,o.CrntQtrAssetClass
							,o.PrevQtrAssetClass
							,o.MonitoringPeriodStatus
							,o.PrevQtrTotalProvision
							,DBS.AcBuRevisedSegmentCode as AcBuSegmentDescription
					 FROM [CurDat].[AdvAcRestructureDetail] A
					 INNER JOIN  DBO.[AdvAcBasicDetail] B ON B.AccountEntityId =A.AccountEntityId
					 AND B.EffectiveFromTimeKey<=@TimeKey and B.EffectiveToTimeKey>=@TimeKey
					 LEFT join DimAcBuSegment DBS on  B.segmentcode = DBS.AcBuSegmentCode
					 AND DBS.EffectiveFromTimeKey<=@TimeKey and DBS.EffectiveToTimeKey>=@TimeKey
					 LEFT JOIN  [dbo].[DIMSOURCEDB] C ON C.SourceAlt_Key = B.SourceAlt_Key
					 AND C.EffectiveFromTimeKey<=@TimeKey and C.EffectiveToTimeKey>=@TimeKey
					 INNER JOIN  [CurDat].[CustomerBasicDetail] D ON D.CustomerId= A.RefCustomerId
					 AND D.EffectiveFromTimeKey<=@TimeKey and D.EffectiveToTimeKey>=@TimeKey
					 INNER JOIN  [CurDat].[AdvAcBalanceDetail] E ON E.AccountEntityId= A.AccountEntityId
					 AND E.EffectiveFromTimeKey<=@TimeKey and E.EffectiveToTimeKey>=@TimeKey
					 INNER JOIN  [CurDat].[AdvAcFinancialDetail] F ON F.AccountEntityId= A.AccountEntityId
					 AND F.EffectiveFromTimeKey<=@TimeKey and F.EffectiveToTimeKey>=@TimeKey
					 LEFT JOIN [PRO].[AdvAcRestructureCal] O ON O.AccountEntityId=B.AccountEntityId
					 AND O.EffectiveFromTimeKey<=@TimeKey and O.EffectiveToTimeKey>=@TimeKey
					 LEFT JOIN  [CurDat].[AdvCustNPADetail] Y  ON Y.RefCustomerID= A.RefCustomerId
					 AND Y.EffectiveFromTimeKey<=@TimeKey and Y.EffectiveToTimeKey>=@TimeKey
					 LEFT JOIN  [dbo].[DimProduct] G ON G.ProductAlt_Key = B.ProductAlt_Key
					 AND G.EffectiveFromTimeKey<=@TimeKey and G.EffectiveToTimeKey>=@TimeKey
					 LEFT JOIN  [dbo].[DimCurrency] H ON H.CurrencyAlt_Key = B.CurrencyAlt_Key
					 AND H.EffectiveFromTimeKey<=@TimeKey and H.EffectiveToTimeKey>=@TimeKey
					 LEFT JOIN  [dbo].[DimAssetClass] J ON J.AssetClassAlt_Key = E.AssetClassAlt_Key 
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
					 --LEFT JOIN  [dbo].[DimSegment] W ON W.EWS_SegmentAlt_Key =  B.segmentcode
					 --AND W.EffectiveFromTimeKey<=@TimeKey and W.EffectiveToTimeKey>=@TimeKey
					 LEFT JOIN (Select ParameterAlt_Key,ParameterName,'CovidMoratorium' As TableName
		              from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey 
					                               And DimParameterName='DimYesNoNA')S ON S.ParameterAlt_Key=A.FlgMorat
					 --LEFT JOIN #Previous P ON P.AccountEntityId=A.AccountEntityId
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
						   --AND A.RefSystemAcId=@RefSystemAcId
						   AND A.RefSystemAcId=@RefSystemAcId )A
					SELECT 
					(SELECT ROW_NUMBER() OVER(ORDER BY AccountEntityId) AS RowNumber), 
                            COUNT(*) OVER() AS TotalCount, 
                            'RestructureMaster' TableName, 
							*
					FROM #temp
END

ELSE

IF  EXISTS(SELECT * FROM [DBO].[AdvAcRestructureDetail_Mod] WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey) 
												AND RefSystemAcId=@RefSystemAcId)
BEGIN
IF OBJECT_ID('TempDB..#temp1') IS NOT NULL
				 BEGIN
                 DROP TABLE  #temp1;
				 END

				 PRINT 'AKshy'
                 SELECT		A.AccountEntityId
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
								--,A.RevisedBusinessSegment
								,A.BankingRelationTypeAlt_Key
								,A.[BankingRelationship]
								,A.SanctionLimit
								,A.SanctionLimitDt
								,A.AssetClassAlt_Key
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
								--,A.IsEquityCoversion
							    ,A.ConversionDate
								,A.Is_COVID_Morat
								,A.Covid_Morit
							    ,A.parameterAlt_Key
								,A.COVID_OTR_Catg
								,A.ReportingBank
								,A.ICA_SignDate
								,A.InvestmentGrade
								,A.[Status_Current_Quarter]
								,A.[Status_previous_Quarter]
								,A.[Status_of_MoniroringPeriod]
								,A.[Status_of_Specified_Period]
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
										,A.CrntQtrAssetClass
							,A.PrevQtrAssetClass
							,A.MonitoringPeriodStatus
							,A.PrevQtrTotalProvision
							,A.AcBuSegmentDescription as AcBuSegmentDescription

                 INTO #temp1
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
								,Convert(Date,B.AccountOpenDate,103)AccountOpenDate
								,B.FacilityType as SchemeType
								,G.ProductCode AS  Productcode
								,G.ProductName AS  ProductDescription
								,B.segmentcode
								--,P.SegmentDescription SegmentDescription
								,DBS.AcBuSegmentDescription AS SegmentDescription
								--,A.RevisedBusinessSegment
								,A.BankingRelationTypeAlt_Key
								,M.ParameterName 'BankingRelationship'
								,B.CurrentLimit as SanctionLimit
								,Convert(Date,B.CurrentLimitDt,103) as SanctionLimitDt
								,E.AssetClassAlt_Key
								,J.AssetClassName
								,F.NpaDt
							    ,Convert(Date,B.DtofFirstDisb,103)DtofFirstDisb
								,A.RestructureTypeAlt_Key
								,k.ParameterName AS RestructureType
								,A.RestructureCatgAlt_Key
								,L.ParameterName AS RestructureFacility
								,Convert(Date,A.PreRestrucDefaultDate,103)PreRestrucDefaultDate
							    ,Q.AssetClassName PreAssetClassName
							    ,Convert(Date,Y.NPADt,103)PreRestrucNPA_Date
								,R.AssetClassName PostAssetClassName
								--,A.Npa_Qtr
								,Convert(Date,A.RestructureDt,103)RestructureDt
								,Convert(Date,A.RestructureProposalDt,103)RestructureProposalDt
								,A.RestructureAmt
								,A.RestructureApprovingAuthority
							    ,Convert(Date,A.RestructureApprovalDt,103)RestructureApprovalDt
								,Convert(Date,A.PrincRepayStartDate,103) POS_RepayStartDate
								,A.RestructurePOS 
								,Convert(Date,A.InttRepayStartDate,103)IntRepayStartDate
								--,Convert(Date,A.RefDate,103)RefDate
								,Convert(Date,A.InvocationDate,103)InvocationDate
								--,A.IsEquityCoversion
							    ,Convert(Date,A.ConversionDate,103)ConversionDate
								,S.ParameterAlt_Key as Is_COVID_Morat
								,S.ParameterName Covid_Morit
							    ,N.parameterAlt_Key
								,N.ParameterName as COVID_OTR_Catg
								,A.FstDefaultReportingBank ReportingBank
								,Convert(Date,A.ICA_SignDate,103) ICA_SignDate
								,A.InvestmentGrade
								--,P.[Status_Current_Quarter]
								--,P.[Status_previous_Quarter]
								--,P.[Status_of_MoniroringPeriod]
								--,P.[Status_of_Specified_Period]
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
								--,P.TotalProvisionPrevious
								,Convert(Date,A.CRILIC_Fst_DefaultDate,103)CRILIC_Fst_DefaultDate
								,isnull(A.AuthorisationStatus, 'A') AuthorisationStatus, 
								A.EffectiveFromTimeKey, 
								A.EffectiveToTimeKey, 
								A.CreatedBy, 
								Convert(Varchar(20),A.DateCreated,105)DateCreated, 
								A.ApprovedBy, 
								Convert(Date,A.DateApproved,103)DateApproved, 
								A.ModifiedBy, 
								Convert(Date,A.DateModified,103)DateModified
								--,P.Status_of_MoniroringPeriodAlt_Key
								--,P.Status_of_Specified_PeriodAlt_Key
								,O.MonitoringPeriodStatus AS Status_of_MoniroringPeriodAlt_Key
								,O.SpecifiedPeriodStatus AS Status_of_Specified_PeriodAlt_Key
								--,A.RevisedBusSegAlt_Key
								,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
							,A.PreRestructureNPA_Prov
                            ,A.EquityConversionYN
							,o.CrntQtrAssetClass
							,o.PrevQtrAssetClass
							,o.MonitoringPeriodStatus
							,o.PrevQtrTotalProvision
							,DBS.AcBuRevisedSegmentCode as AcBuSegmentDescription
					 FROM		 [DBO].[AdvAcRestructureDetail_Mod] A
					 INNER JOIN  DBO.[AdvAcBasicDetail] B ON B.AccountEntityId =A.AccountEntityId
					 AND B.EffectiveFromTimeKey<=@TimeKey and B.EffectiveToTimeKey>=@TimeKey
					 LEFT join DimAcBuSegment DBS on  B.segmentcode = DBS.AcBuSegmentCode
					 AND DBS.EffectiveFromTimeKey<=@TimeKey and DBS.EffectiveToTimeKey>=@TimeKey
					 LEFT JOIN  [dbo].[DIMSOURCEDB] C ON C.SourceAlt_Key = B.SourceAlt_Key
					 AND C.EffectiveFromTimeKey<=@TimeKey and C.EffectiveToTimeKey>=@TimeKey
					 INNER JOIN  [CurDat].[CustomerBasicDetail] D ON D.CustomerId= A.RefCustomerId
					 AND D.EffectiveFromTimeKey<=@TimeKey and D.EffectiveToTimeKey>=@TimeKey
					 INNER JOIN  [CurDat].[AdvAcBalanceDetail] E ON E.AccountEntityId= A.AccountEntityId
					 AND E.EffectiveFromTimeKey<=@TimeKey and E.EffectiveToTimeKey>=@TimeKey
					 INNER JOIN  [CurDat].[AdvAcFinancialDetail] F ON F.AccountEntityId= A.AccountEntityId
					 AND F.EffectiveFromTimeKey<=@TimeKey and F.EffectiveToTimeKey>=@TimeKey
					 LEFT JOIN [PRO].[AdvAcRestructureCal] O ON O.AccountEntityId=B.AccountEntityId
					 AND O.EffectiveFromTimeKey<=@TimeKey and O.EffectiveToTimeKey>=@TimeKey
					 LEFT JOIN  [CurDat].[AdvCustNPADetail] Y  ON Y.RefCustomerID= A.RefCustomerId
					 AND Y.EffectiveFromTimeKey<=@TimeKey and Y.EffectiveToTimeKey>=@TimeKey
					 LEFT JOIN  [dbo].[DimProduct] G ON G.ProductAlt_Key = B.ProductAlt_Key
					 AND G.EffectiveFromTimeKey<=@TimeKey and G.EffectiveToTimeKey>=@TimeKey
					 LEFT JOIN  [dbo].[DimCurrency] H ON H.CurrencyAlt_Key = B.CurrencyAlt_Key
					 AND H.EffectiveFromTimeKey<=@TimeKey and H.EffectiveToTimeKey>=@TimeKey
					 LEFT JOIN  [dbo].[DimAssetClass] J ON J.AssetClassAlt_Key = E.AssetClassAlt_Key 
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
					 --LEFT JOIN  [dbo].[DimSegment] W ON W.EWS_SegmentAlt_Key =  B.segmentcode
					 --AND W.EffectiveFromTimeKey<=@TimeKey and W.EffectiveToTimeKey>=@TimeKey
					 LEFT JOIN (Select ParameterAlt_Key,ParameterName,'CovidMoratorium' As TableName
		 from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey And DimParameterName='DimYesNoNA')S ON S.ParameterAlt_Key=A.FlgMorat
					---- LEFT JOIN #Previous P ON P.AccountEntityId=A.AccountEntityId
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
						   AND A.RefSystemAcId=@RefSystemAcId
                           --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                           AND A.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM [dbo].[AdvAcRestructureDetail_Mod]
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
								--,A.RevisedBusinessSegment
								,A.BankingRelationTypeAlt_Key
								,A.[BankingRelationship]
								,A.SanctionLimit
								,A.SanctionLimitDt
								,A.AssetClassAlt_Key
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
								--,A.IsEquityCoversion
							    ,A.ConversionDate
								,A.Is_COVID_Morat

								,A.Covid_Morit
							    ,A.parameterAlt_Key
								,A.COVID_OTR_Catg

								,A.ReportingBank
								,A.ICA_SignDate
								,A.InvestmentGrade
								,A.[Status_Current_Quarter]
								,A.[Status_previous_Quarter]
								,A.[Status_of_MoniroringPeriod]
								,A.[Status_of_Specified_Period]
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
							,A.CrntQtrAssetClass
							,A.PrevQtrAssetClass
							,A.MonitoringPeriodStatus
							,A.PrevQtrTotalProvision
							,A.AcBuSegmentDescription;


                 SELECT 
                     --(SELECT ROW_NUMBER() OVER(ORDER BY AccountEntityId) AS RowNumber), 
                     --       COUNT(*) OVER() AS TotalCount, 
                            'RestructureMasterMod' TableName, 
                            *
                     FROM #temp1            
END
-----------------------------------------------JAYADEV END-----------------------------------------------------------------------------------------------------------------
ELSE
--Declare @TimeKey as Int
--set @TimeKey = 49999
--Declare @RefSystemAcId  VARCHAR(30)
--set @RefSystemAcId = '9987880000000001'
BEGIN
IF OBJECT_ID('TempDB..#temp2') IS NOT NULL
				 BEGIN
                 DROP TABLE  #temp2;
				 END
				 PRINT 'Sachin11'
                 SELECT			 A.AccountEntityId
								,A.SystemACID
								,A.SourceName 
								,A.CustomerId 
								,A.CustomerName 
								,A.UCIF_ID 
								,A.CurrencyName
								,A.AccountOpenDate
								,A.SchemeType
								,A.Productcode
								,A.ProductDescription
								,A.segmentcode
								,A.SegmentDescription
								,A.SanctionLimit
								,A.SanctionLimitDt
								,A.AssetClassName
								,A.AssetClassAlt_Key
								,A.NpaDt
								,A.TotalProv
								,A.Percentage
								,A.TotalProvisionPrevious
								,A.Status_Current_Quarter
								,A.Status_previous_Quarter
								,A.Status_of_MoniroringPeriod
								,A.Status_of_Specified_Period
							,A.CrntQtrAssetClass
							,A.PrevQtrAssetClass
							,A.MonitoringPeriodStatus
							,A.PrevQtrTotalProvision
							,A.AcBuSegmentDescription
							,A.DtofFirstDisb
								
				 INTO #temp2
                 FROM 
                 (      
				        SELECT 	
								 B.AccountEntityId						
								,B.SystemACID
								,C.SourceName  ---
								,D.CustomerId  --
								,D.CustomerName  --
								,D.UCIF_ID  --
								,H.CurrencyName
								,B.AccountOpenDate
								,B.FacilityType as SchemeType
								,B.ProductAlt_Key AS  Productcode
								,G.ProductName AS  ProductDescription
								,B.segmentcode
								,DBS.AcBuSegmentDescription AS SegmentDescription
								,B.CurrentLimit as SanctionLimit
								,B.CurrentLimitDt as SanctionLimitDt
								,J.AssetClassName
								,J.AssetClassAlt_Key
								,F.NpaDt
								,E.TotalProv
								,Round(E.TotalProv/E.Balance,2)*100 as [Percentage]
								--,P.TotalProvisionPrevious
								--,P.[Status_Current_Quarter]
								--,P.[Status_previous_Quarter]
								--,P.[Status_of_MoniroringPeriod]
								--,P.[Status_of_Specified_Period]
								,O.PrevQtrTotalProvision as TotalProvisionPrevious
								,S.AssetClassName as Status_Current_Quarter
								,T.AssetClassName as Status_previous_Quarter
								,U.ParameterName as Status_of_MoniroringPeriod
								,V.ParameterName as Status_of_Specified_Period
								--,Q.AssetClassName PreAssetClassName
								--,R.AssetClassName PostAssetClassName
								--,A.PreRestrucDefaultDate
								--,A.PreRestrucNPA_Date
						  --      ,isnull(A.AuthorisationStatus, 'A') AuthorisationStatus, 
								--A.EffectiveFromTimeKey, 
								--A.EffectiveToTimeKey, 
								--A.CreatedBy, 
								--A.DateCreated, 
								--A.ApprovedBy, 
								--A.DateApproved, 
								--A.ModifiedBy, 
								--A.DateModified
							,o.CrntQtrAssetClass
							,o.PrevQtrAssetClass
							,o.MonitoringPeriodStatus
							,o.PrevQtrTotalProvision
							,DBS.AcBuRevisedSegmentCode as AcBuSegmentDescription
							,Convert(Date,B.DtofFirstDisb,103)DtofFirstDisb
					 FROM		 
					 --[CurDat].[AdvAcRestructureDetail] A
					 --INNER JOIN  
					 dbo.[AdvAcBasicDetail] B 
					 --ON B.AccountEntityId =A.AccountEntityId
					 --AND B.EffectiveFromTimeKey<=@TimeKey and B.EffectiveToTimeKey>=@TimeKey
					 LEFT join DimAcBuSegment DBS on  B.segmentcode = DBS.AcBuSegmentCode
					 AND DBS.EffectiveFromTimeKey<=@TimeKey and DBS.EffectiveToTimeKey>=@TimeKey
					 LEFT JOIN  [dbo].[DIMSOURCEDB] C ON C.SourceAlt_Key = B.SourceAlt_Key
					 AND C.EffectiveFromTimeKey<=@TimeKey and C.EffectiveToTimeKey>=@TimeKey
					 INNER JOIN  [dbo].[CustomerBasicDetail] D ON D.CustomerId= B.RefCustomerId
					 AND D.EffectiveFromTimeKey<=@TimeKey and D.EffectiveToTimeKey>=@TimeKey
					 INNER JOIN  [dbo].[AdvAcBalanceDetail] E ON E.AccountEntityId= B.AccountEntityId
					 AND E.EffectiveFromTimeKey<=@TimeKey and E.EffectiveToTimeKey>=@TimeKey
					 INNER JOIN  [DBO].[AdvAcFinancialDetail] F ON F.AccountEntityId= B.AccountEntityId
					 AND F.EffectiveFromTimeKey<=@TimeKey and F.EffectiveToTimeKey>=@TimeKey
					 LEFT JOIN [PRO].[AdvAcRestructureCal] O ON O.AccountEntityId=B.AccountEntityId
					 AND O.EffectiveFromTimeKey<=@TimeKey and O.EffectiveToTimeKey>=@TimeKey
					 LEFT JOIN  [dbo].[AdvCustNPADetail] Y  ON Y.RefCustomerID= D.CustomerId
					 AND Y.EffectiveFromTimeKey<=@TimeKey and Y.EffectiveToTimeKey>=@TimeKey
					 LEFT JOIN  [dbo].[DimProduct] G ON G.ProductAlt_Key = B.ProductAlt_Key
					 AND G.EffectiveFromTimeKey<=@TimeKey and G.EffectiveToTimeKey>=@TimeKey
					 LEFT JOIN  [dbo].[DimCurrency] H ON H.CurrencyAlt_Key = B.CurrencyAlt_Key
					 AND H.EffectiveFromTimeKey<=@TimeKey and H.EffectiveToTimeKey>=@TimeKey
					 LEFT JOIN  [dbo].[DimAssetClass] J ON J.AssetClassAlt_Key = E.AssetClassAlt_Key 
					 AND J.EffectiveFromTimeKey<=@TimeKey and J.EffectiveToTimeKey>=@TimeKey 
					 LEFT JOIN  [dbo].[DimAssetClass] S ON S.AssetClassAlt_Key = O.CrntQtrAssetClass 
					 AND S.EffectiveFromTimeKey<=@TimeKey and S.EffectiveToTimeKey>=@TimeKey
					 LEFT JOIN  [dbo].[DimAssetClass] T ON T.AssetClassAlt_Key = O.PrevQtrAssetClass 
					 AND T.EffectiveFromTimeKey<=@TimeKey and T.EffectiveToTimeKey>=@TimeKey
					 LEFT JOIN  [dbo].[DimParameter] U ON U.ParameterAlt_Key = O.MonitoringPeriodStatus AND U.DimParameterName='StatusofMonitoringPeriod'
					 AND U.EffectiveFromTimeKey<=@TimeKey and U.EffectiveToTimeKey>=@TimeKey
					 LEFT JOIN  [dbo].[DimParameter] V ON V.ParameterAlt_Key = O.SpecifiedPeriodStatus AND V.DimParameterName='StatusofSpecificPeriod'
					 AND V.EffectiveFromTimeKey<=@TimeKey and V.EffectiveToTimeKey>=@TimeKey
					 --LEFT JOIN  [dbo].[DimSegment] W ON W.EWS_SegmentAlt_Key =  B.segmentcode
					 --AND W.EffectiveFromTimeKey<=@TimeKey and W.EffectiveToTimeKey>=@TimeKey
					 LEFT JOIN  [dbo].[DimAssetClass] Q ON Q.AssetClassAlt_Key = Y.Cust_AssetClassAlt_Key 
					 AND Q.EffectiveFromTimeKey<=@TimeKey and Q.EffectiveToTimeKey>=@TimeKey  
					 --INNER JOIN  [dbo].[DimAssetClass] R ON R.AssetClassAlt_Key = A.PostRestrucAssetClass 
					 --AND R.EffectiveFromTimeKey<=@TimeKey and R.EffectiveToTimeKey>=@TimeKey     
					 --INNER JOIN  [dbo].[DimParameter] K ON k.ParameterAlt_Key = A.RestructureTypeAlt_Key AND k.DimParameterName='TypeofRestructuring'
					 --AND K.EffectiveFromTimeKey<=@TimeKey and K.EffectiveToTimeKey>=@TimeKey
					 --INNER JOIN  [dbo].[DimParameter] L ON L.ParameterAlt_Key = A.RestructureCatgAlt_Key AND L.DimParameterName='RestructureFacility'
					 --AND L.EffectiveFromTimeKey<=@TimeKey and L.EffectiveToTimeKey>=@TimeKey
					 --INNER JOIN  [dbo].[DimParameter] M ON M.ParameterAlt_Key = A.BankingRelationTypeAlt_Key AND M.DimParameterName='BankingRelationship'
					 --AND M.EffectiveFromTimeKey<=@TimeKey and M.EffectiveToTimeKey>=@TimeKey
					 --INNER JOIN  [dbo].[DimParameter] N ON N.ParameterAlt_Key = A.COVID_OTR_CatgAlt_Key AND N.DimParameterName='Covid - OTR Category'
					 --AND N.EffectiveFromTimeKey<=@TimeKey and N.EffectiveToTimeKey>=@TimeKey
					 --LEFT JOIN #Previous P ON P.AccountEntityId=B.AccountEntityId
					 WHERE B.EffectiveFromTimeKey <= @TimeKey
                           AND B.EffectiveToTimeKey >= @TimeKey
                           --AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
						   AND B.SystemAcId= @RefSystemAcId)A
					GROUP BY    A.AccountEntityId
								,A.SystemACID
								,A.SourceName 
								,A.CustomerId 
								,A.CustomerName 
								,A.UCIF_ID 
								,A.CurrencyName
								,A.AccountOpenDate
								,A.SchemeType
								,A.Productcode
								,A.ProductDescription
								,A.segmentcode
								,A.SegmentDescription
								,A.SanctionLimit
								,A.SanctionLimitDt
								,A.AssetClassName
								,A.AssetClassAlt_Key
								,A.NpaDt
								,A.TotalProv
								,A.Percentage
								,A.TotalProvisionPrevious
								,A.Status_Current_Quarter
								,A.Status_previous_Quarter
								,A.Status_of_MoniroringPeriod
								,A.Status_of_Specified_Period
							,A.CrntQtrAssetClass
							,A.PrevQtrAssetClass
							,A.MonitoringPeriodStatus
							,A.PrevQtrTotalProvision
							,A.AcBuSegmentDescription
							,A.DtofFirstDisb;

					SELECT 
                     (SELECT ROW_NUMBER() OVER(ORDER BY AccountEntityId) AS RowNumber), 
                            COUNT(*) OVER() AS TotalCount, 
                            'CustomerDetail' TableName, 
                            *
                     FROM #temp2 

END
END

GO