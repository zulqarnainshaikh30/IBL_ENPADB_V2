SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--exec [dbo].[Fraud_QuickSearchlist] 1,24738,'',1,1000
CREATE PROC [dbo].[Fraud_QuickSearchlist]

--Declare
--@PageNo         INT         = 1, 
--@PageSize       INT         = 10, 
@OperationFlag  INT         = 1
,@MenuID  INT  = 24738
,@Account_id VARCHAR(30)='15681221'
	,@newPage SMALLINT =1     
,@pageSize INT = 10000
AS
     

     
	 BEGIN

SET NOCOUNT ON;
Declare @TimeKey as Int
	SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')
					
Declare @Authlevel InT
 
select @Authlevel=AuthLevel from SysCRisMacMenu  
 where MenuId=@MenuID
  --select * from 	SysCRisMacMenu where menucaption like '%Branch%'
BEGIN TRY

SET DATEFORMAT DMY

IF OBJECT_ID('TempDB..#CustNPADetail') is not null
Drop Table #CustNPADetail

Select A.RefCustomerID,A.Cust_AssetClassAlt_Key,A.NPADt Into #CustNPADetail from dbo.AdvCustNPADetail A
Inner Join (Select RefCustomerID,Min(EffectiveFromTimeKey)EffectiveFromTimeKey 
from AdvCustNPADetail Group By RefCustomerID) B ON A.RefCustomerID=B.RefCustomerID 
And A.EffectiveFromTimeKey=B.EffectiveFromTimeKey




/*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */
          IF (@Account_id ='' or (@Account_id is null)) 
		  Begin

		   IF(@OperationFlag not in (16,17,20))
             BEGIN
			 print 'Prashant'


			 IF OBJECT_ID('TempDB..#temp_Fraud') IS NOT NULL
                 DROP TABLE  #temp_Fraud;
                 SELECT		-- A.Account_ID
				            AccountEntityId
							,CustomerEntityId
							,RefCustomerACID
							,RefCustomerID
							,SourceName
							,BranchCode
							,BranchName
							,AcBuSegmentCode
							,AcBuSegmentDescription
							,UCIF_ID 							
							,CustomerName	
							,TOS				
							,POS
							,AssetClassAlt_KeyBeforeFruad
							,AssetClassAtFraud
							,NPADateAtFraud
							,RFA_ReportingByBank
							,RFA_DateReportingByBank
							,RFA_OtherBankAltKey
							,RFA_OtherBankDate
							,FraudOccuranceDate
							,FraudDeclarationDate
							,FraudNature
							,FraudArea
							,CurrentAssetClassName
							,CurrentAssetClassAltKey
							,CurrentNPA_Date
							,Provisionpreference
							,A.AuthorisationStatus
							,A.EffectiveFromTimeKey
							,A.EffectiveToTimeKey
							,A.CreatedBy
							,A.DateCreated
							,A.ModifiedBy
							,A.DateModified
							,A.ApprovedBy
							,A.DateApproved
							,A.ApprovedByFirstLevel
							,A.FirstLevelDateApproved 
							,A.ChangeFields
							,A.screenFlag
							 ,A.ReasonforRFAClassification 
							,A.DateofRemovalofRFAClassification 
							,A.ReasonforRemovalofRFAClassification 
							,A.DateofRemovalofRFAClassificationReporting 
							,A.RFAReportedOtherBank
							,A.NameofBank
							,A.CrModBy
							,A.CrModDate
							,A.CrAppBy
							,A.CrAppDate
							,A.ModAppBy
							,A.ModAppDate
							,A.AuthorisationStatus_1
							--,A.changeFields
                 INTO #temp_Fraud
                 FROM 
                 (
                     SELECT  --A.Account_ID
							 (CASE	WHEN B.AccountEntityId is NOT NULL THEN B.AccountEntityId 
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
							,(CASE WHEN C.SourceName is not NULL THen c.SourceName 
							 WHEN CC.SourceName is not NULL THen cC.SourceName 
							  WHEN CD.SourceName is not NULL THen cd.SourceName 
							  ELSE CE.SourceName END)SourceName
							  ,(CASE WHEN E.BranchCode is not NULL THen E.BranchCode 
							 WHEN EE.BranchCode is not NULL THen EE.BranchCode 
							  WHEN ED.BranchCode is not NULL THen ED.BranchCode
							  ELSE EC.BranchCode END)BranchCode							
							 ,(CASE WHEN E.BranchName is not NULL THen E.BranchName 
							 WHEN EE.BranchName is not NULL THen EE.BranchName 
							  WHEN ED.BranchName is not NULL THen ED.BranchName
							  ELSE EC.BranchName END)BranchName
							,(CASE WHEN F.AcBuSegmentCode is not NULL THEN F.AcBuSegmentCode ELSE F.AcBuSegmentCode END)AcBuSegmentCode
							,(CASE WHEN  F.AcBuSegmentDescription is not NULL THEN F.AcBuSegmentDescription ELSE F.AcBuSegmentDescription END)AcBuSegmentDescription
							,(CASE WHEN D.UCIF_ID is not NULL THen D.UCIF_ID 
							 WHEN BB.RefCustomerID is not NULL THen BB.RefCustomerID
							  WHEN IJ.UcifId is not NULL THen IJ.UcifId
							  ELSE DV.UCIC_ID END)UCIF_ID
							,(CASE WHEN D.CustomerName is NOT NULL THEN D.CustomerName
							WHEN BB.CustomerName is NOT NULL THEN BB.CustomerName
							WHEN IJ.IssuerName is NOT NULL THEN IJ.IssuerName
							 ELSE DV.CustomerName END) as CustomerName																
							,(CASE	WHEN J.Balance is not NULL THEN J.Balance
									WHEN JJ.Balance is not NULL THEN JJ.Balance
									WHEN IK.BookValueINR is not NULL THEN IK.BookValueINR
									ELSE DV.MTMIncomeAmt END) as TOS				
							,(CASE	WHEN J.PrincipalBalance is not NULL THEN J.PrincipalBalance
									WHEN JJ.Balance is not NULL THEN JJ.Balance
									WHEN IK.MTMValueINR is not NULL THEN IK.MTMValueINR
									ELSE DV.pos END) as POS
							,A.AssetClassAlt_KeyBeforeFruad as AssetClassAlt_KeyBeforeFruad
							,(case when S.AssetClassName is null then 'STANDARD' else S.AssetClassName end) as AssetClassAtFraud
							,(CASE WHEN cast(A.NPADateBeforeFraud as date) = '01/01/1900' THEN '' ELSE Convert(Varchar(10),A.NPADateBeforeFraud,103) END) as NPADateAtFraud
							,RFA_ReportingByBank
							--,(CASE WHEN cast(RFA_DateReportingByBank as date) = '01/01/1900' THEN '' ELSE cast(RFA_DateReportingByBank as date) END) RFA_DateReportingByBank
							,(CASE WHEN cast(RFA_DateReportingByBank as date) = '01/01/1900' THEN '' ELSE convert(varchar(10),RFA_DateReportingByBank,103) END) RFA_DateReportingByBank
							,RFA_OtherBankAltKey
							--,(CASE WHEN cast(RFA_OtherBankDate as date) = '01/01/1900' THEN '' ELSE cast(RFA_OtherBankDate as date) END) RFA_OtherBankDate
							,(CASE WHEN cast(RFA_OtherBankDate as date) = '01/01/1900' THEN '' ELSE convert(varchar(10),RFA_OtherBankDate,103) END) RFA_OtherBankDate
							--,(CASE WHEN cast(FraudOccuranceDate as date) = '01/01/1900' THEN '' ELSE cast(FraudOccuranceDate as date) END) FraudOccuranceDate
							,(CASE WHEN cast(FraudOccuranceDate as date) = '01/01/1900' THEN '' ELSE convert(varchar(10),FraudOccuranceDate,103) END) FraudOccuranceDate
							--,(CASE WHEN cast(FraudDeclarationDate as date) = '01/01/1900' THEN '' ELSE cast(FraudDeclarationDate as date) END)FraudDeclarationDate
							,(CASE WHEN cast(FraudDeclarationDate as date) = '01/01/1900' THEN '' ELSE convert(Varchar(10),FraudDeclarationDate,103) END)FraudDeclarationDate
							,FraudNature
							,FraudArea
							,(CASE	WHEN L.AssetClassName is not NULL THEN L.AssetClassName 
									WHEN LL.AssetClassName is not NULL THEN LL.AssetClassName
									WHEN LK.AssetClassName is not NULL THEN LK.AssetClassName
									ELSE LM.AssetClassName END) as CurrentAssetClassName
							,(CASE	WHEN H.Cust_AssetClassAlt_Key is not NULL THEN H.Cust_AssetClassAlt_Key
									WHEN HH.Cust_AssetClassAlt_Key is not NULL THEN HH.Cust_AssetClassAlt_Key
									WHEN IK.FinalAssetClassAlt_Key is not NULL THEN IK.FinalAssetClassAlt_Key
									ELSE DV.FinalAssetClassAlt_KEy 
								    END)  as CurrentAssetClassAltKey
							--,cast(H.NPADt as date) as CurrentNPA_Date
							,(CASE	WHEN convert(varchar(10),H.NPADt,103) is not NULL THEN convert(varchar(10),H.NPADt,103)
									WHEN convert(varchar(10),HH.NPADt,103) is not NULL THEN convert(varchar(10),HH.NPADt,103)
									WHEN convert(varchar(10),IK.NPIDt,103) is not NULL THEN convert(varchar(10),IK.NPIDt,103)
									ELSE convert(varchar(10),DV.NPIDt,103) END)as CurrentNPA_Date
							,ProvPref as Provisionpreference
							,(CASE WHEN A.AuthorisationStatus is not NULL THEN A.AuthorisationStatus ELSE NULL END)  AuthorisationStatus
							,A.EffectiveFromTimeKey
							,A.EffectiveToTimeKey
							,A.CreatedBy
							,A.DateCreated as DateCreated
							,A.ModifiedBy
							,A.DateModified
							,A.ApprovedBy
							,A.DateApproved
							,A.FirstLevelApprovedBy as ApprovedByFirstLevel
							,A.FirstLevelDateApproved 
							,NULL AS ChangeFields
							,A.screenFlag
							 ,A.ReasonforRFAClassification 
							--,cast(A.DateofRemovalofRFAClassification as date) as DateofRemovalofRFAClassification
							,convert(varchar(10),A.DateofRemovalofRFAClassification,103) as DateofRemovalofRFAClassification 
							,A.ReasonforRemovalofRFAClassification
							--,cast(A.DateofRemovalofRFAClassificationReporting as date) as DateofRemovalofRFAClassificationReporting 
							,convert(Varchar(10),A.DateofRemovalofRFAClassificationReporting,103) as DateofRemovalofRFAClassificationReporting 
							,A.RFAReportedOtherBank
							,A.NameofBank
					       ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy  
                           ,IsNull(A.DateModified,A.DateCreated)as CrModDate  
                           ,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy  
                           ,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate  
                           ,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy  
                           ,ISNULL(A.DateApproved,A.DateModified) as ModAppDate		
						   , CASE WHEN  ISNULL(A.AuthorisationStatus,'A')='A' THEN 'Authorized'
								  WHEN  ISNULL(A.AuthorisationStatus,'A')='R' THEN 'Rejected'
								  WHEN  ISNULL(A.AuthorisationStatus,'A')='1A' THEN '2nd Level Authorization Pending'
								  WHEN  ISNULL(A.AuthorisationStatus,'A') IN ('NP','MP') THEN '1st Level Authorization Pending' ELSE NULL END AS AuthorisationStatus_1									 
	                  FROM		  Fraud_Details A 
				      LEFT JOIN   AdvAcBasicDetail B
					  ON          A.RefCustomerAcid=B.CustomerACID  
					  AND			B.EffectiveFromTimeKey <= @TimeKey
								 AND B.EffectiveToTimeKey >= @TimeKey
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
					  LEFT JOIN	  DIMSOURCEDB C
					  ON          B.SourceAlt_Key=C.SourceAlt_Key 
					  AND         C.EffectiveFromTimeKey <= @TimeKey AND C.EffectiveToTimeKey >= @TimeKey
					 LEFT JOIN	  DIMSOURCEDB CC
					  ON          BB.SourceAlt_Key=CC.SourceAlt_Key 
					  AND         CC.EffectiveFromTimeKey <= @TimeKey AND CC.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMSOURCEDB CD
					  ON          IJ.SourceAlt_Key=CD.SourceAlt_Key 
					  AND         CD.EffectiveFromTimeKey <= @TimeKey AND CD.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMSOURCEDB CE
					  ON          DV.SourceSystem=CE.SourceName 
					  AND         CE.EffectiveFromTimeKey <= @TimeKey AND CE.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN   CustomerBasicDetail D
					  ON          D.CustomerId=B.RefCustomerId
					  AND         D.EffectiveFromTimeKey <= @TimeKey AND D.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN   DIMBRANCH E
					  ON          B.BranchCode=E.BranchCode
					  AND         E.EffectiveFromTimeKey <= @TimeKey AND E.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMBRANCH EE
					  ON          BB.BranchCode=EE.BranchCode 
					  AND         EE.EffectiveFromTimeKey <= @TimeKey AND EE.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMBRANCH ED
					  ON          IJ.BranchCode=ED.BranchCode 
					  AND         ED.EffectiveFromTimeKey <= @TimeKey AND ED.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMBRANCH EC
					  ON          DV.BranchCode=EC.BranchCode 
					  AND         EC.EffectiveFromTimeKey <= @TimeKey AND EC.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN  DimAcBuSegment  F
					  ON		  B.segmentcode=F.AcBuSegmentCode
					  AND         F.EffectiveFromTimeKey <= @TimeKey AND F.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN  DimAcBuSegment  FF
					  ON		  BB.segmentcode=FF.AcBuSegmentCode
					  AND         FF.EffectiveFromTimeKey <= @TimeKey AND FF.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN  DIMPRODUCT G
					  ON          B.ProductAlt_Key=G.ProductAlt_Key
					  AND         G.EffectiveFromTimeKey <= @TimeKey AND G.EffectiveToTimeKey >= @TimeKey
					  LEFT join  AdvCustNpaDetail H
					  ON          D.CustomerEntityId=H.CustomerEntityId
					  AND         H.EffectiveFromTimeKey <= @TimeKey AND H.EffectiveToTimeKey >= @TimeKey
					  LEFT join  AdvCustNpaDetail HH
					  ON          BB.CustomerEntityId=HH.CustomerEntityId
					  AND         HH.EffectiveFromTimeKey <= @TimeKey AND HH.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN  DIMASSETCLASS I
					  ON          A.AssetClassAtFraudAltKey=I.AssetClassAlt_Key
					  AND		I.EffectiveToTimeKey = 49999
					  LEFT JOIN  DIMASSETCLASS L
					  ON          H.Cust_AssetClassAlt_Key=L.AssetClassAlt_Key
					  AND         L.EffectiveToTimeKey = 49999
					   LEFT JOIN  DIMASSETCLASS LL
					  ON          HH.Cust_AssetClassAlt_Key=LL.AssetClassAlt_Key
					  AND         LL.EffectiveToTimeKey = 49999
					  LEFT JOIN  DIMASSETCLASS LK
					  ON          IK.FinalAssetClassAlt_key=LK.AssetClassAlt_Key
					  AND         LK.EffectiveToTimeKey = 49999
					  LEFT JOIN  DIMASSETCLASS LM
					  ON         DV.FinalAssetClassAlt_key=LM.AssetClassAlt_Key
					  AND         LM.EffectiveToTimeKey = 49999
					  Left join  #CustNPADetail Q
					  ON         Q.RefCustomerID=D.CustomerId
					  LEFT JOIN   DimAssetClass R
					  ON          Q.Cust_AssetClassAlt_Key=R.AssetClassAlt_Key
					  AND         R.EffectiveToTimeKey = 49999
					  LEFT JOIN   DimAssetClass S
					  ON          A.AssetClassAlt_KeyBeforeFruad=S.AssetClassAlt_Key
					  AND         S.EffectiveToTimeKey = 49999
					  WHERE			
								 ISNULL(A.AuthorisationStatus, 'A') = 'A'

                     UNION
					  SELECT 
                            --A.Account_ID
							(CASE	WHEN B.AccountEntityId is NOT NULL THEN B.AccountEntityId 
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
							,(CASE WHEN C.SourceName is not NULL THen c.SourceName 
							 WHEN CC.SourceName is not NULL THen cC.SourceName 
							  WHEN CD.SourceName is not NULL THen cd.SourceName 
							  ELSE CE.SourceName END)SourceName
							 ,(CASE WHEN E.BranchCode is not NULL THen E.BranchCode 
							 WHEN EE.BranchCode is not NULL THen EE.BranchCode 
							  WHEN ED.BranchCode is not NULL THen ED.BranchCode
							  ELSE EC.BranchCode END)BranchCode							
							 ,(CASE WHEN E.BranchName is not NULL THen E.BranchName 
							 WHEN EE.BranchName is not NULL THen EE.BranchName 
							  WHEN ED.BranchName is not NULL THen ED.BranchName
							  ELSE EC.BranchName END)BranchName
							,(CASE WHEN F.AcBuSegmentCode is not NULL THEN F.AcBuSegmentCode ELSE F.AcBuSegmentCode END)AcBuSegmentCode
							,(CASE WHEN  F.AcBuSegmentDescription is not NULL THEN F.AcBuSegmentDescription ELSE F.AcBuSegmentDescription END)AcBuSegmentDescription
							,(CASE WHEN D.UCIF_ID is not NULL THen D.UCIF_ID 
							 WHEN BB.RefCustomerID is not NULL THen BB.RefCustomerID
							  WHEN IJ.UcifId is not NULL THen IJ.UcifId
							  ELSE DV.UCIC_ID END)UCIF_ID 
							,(CASE WHEN D.CustomerName is NOT NULL THEN D.CustomerName
							WHEN BB.CustomerName is NOT NULL THEN BB.CustomerName
							WHEN IJ.IssuerName is NOT NULL THEN IJ.IssuerName
							 ELSE DV.CustomerName END) as CustomerName																
							,(CASE	WHEN J.Balance is not NULL THEN J.Balance
									WHEN JJ.Balance is not NULL THEN JJ.Balance
									WHEN IK.BookValueINR is not NULL THEN IK.BookValueINR
									ELSE DV.OsAmt END) as TOS				
							,(CASE	WHEN J.PrincipalBalance is not NULL THEN J.PrincipalBalance
									WHEN JJ.Balance is not NULL THEN JJ.Balance
									WHEN IK.MTMValueINR is not NULL THEN IK.MTMValueINR
									ELSE DV.pos END) as POS
							,A.AssetClassAlt_KeyBeforeFruad as AssetClassAlt_KeyBeforeFruad
							,(case when S.AssetClassName is null then 'STANDARD' else S.AssetClassName end) as AssetClassAtFraud
							--,(CASE WHEN cast(NPA_DateAtFraud as date) = '01/01/1900' THEN '' ELSE cast(NPA_DateAtFraud as date) END) as NPADateAtFraud
							,(CASE WHEN cast(A.NPADateBeforeFraud as date) = '01/01/1900' THEN '' ELSE Convert(Varchar(10),A.NPADateBeforeFraud,103) END) as NPADateAtFraud
							,RFA_ReportingByBank
							--,(CASE WHEN cast(RFA_DateReportingByBank as date) = '01/01/1900' THEN '' ELSE cast(RFA_DateReportingByBank as date) END) RFA_DateReportingByBank
							,(CASE WHEN cast(RFA_DateReportingByBank as date) = '01/01/1900' THEN '' ELSE convert(varchar(10),RFA_DateReportingByBank,103) END) RFA_DateReportingByBank
							,RFA_OtherBankAltKey
							--,(CASE WHEN cast(RFA_OtherBankDate as date) = '01/01/1900' THEN '' ELSE cast(RFA_OtherBankDate as date) END) RFA_OtherBankDate
							,(CASE WHEN cast(RFA_OtherBankDate as date) = '01/01/1900' THEN '' ELSE convert(varchar(10),RFA_OtherBankDate,103) END) RFA_OtherBankDate
							--,(CASE WHEN cast(FraudOccuranceDate as date) = '01/01/1900' THEN '' ELSE cast(FraudOccuranceDate as date) END) FraudOccuranceDate
							,(CASE WHEN cast(FraudOccuranceDate as date) = '01/01/1900' THEN '' ELSE convert(varchar(10),FraudOccuranceDate,103) END) FraudOccuranceDate
							--,(CASE WHEN cast(FraudDeclarationDate as date) = '01/01/1900' THEN '' ELSE cast(FraudDeclarationDate as date) END)FraudDeclarationDate
							,(CASE WHEN cast(FraudDeclarationDate as date) = '01/01/1900' THEN '' ELSE convert(Varchar(10),FraudDeclarationDate,103) END)FraudDeclarationDate
							,FraudNature
							,FraudArea
							,(CASE	WHEN L.AssetClassName is not NULL THEN L.AssetClassName 
									WHEN LL.AssetClassName is not NULL THEN LL.AssetClassName
									WHEN LK.AssetClassName is not NULL THEN LK.AssetClassName
									ELSE LM.AssetClassName END) as CurrentAssetClassName
							,(CASE	WHEN H.Cust_AssetClassAlt_Key is not NULL THEN H.Cust_AssetClassAlt_Key
									WHEN HH.Cust_AssetClassAlt_Key is not NULL THEN HH.Cust_AssetClassAlt_Key
									WHEN IK.FinalAssetClassAlt_Key is not NULL THEN IK.FinalAssetClassAlt_Key
									ELSE DV.FinalAssetClassAlt_KEy 
								    END)  as CurrentAssetClassAltKey
							--,cast(H.NPADt as date) as CurrentNPA_Date
							,(CASE	WHEN convert(varchar(10),H.NPADt,103) is not NULL THEN convert(varchar(10),H.NPADt,103)
									WHEN convert(varchar(10),HH.NPADt,103) is not NULL THEN convert(varchar(10),HH.NPADt,103)
									WHEN convert(varchar(10),IK.NPIDt,103) is not NULL THEN convert(varchar(10),IK.NPIDt,103)
									ELSE convert(varchar(10),DV.NPIDt,103) END)as CurrentNPA_Date
							,ProvPref as Provisionpreference
							,(CASE WHEN A.AuthorisationStatus is not NULL THEN A.AuthorisationStatus ELSE NULL END)  AuthorisationStatus
							,A.EffectiveFromTimeKey
							,A.EffectiveToTimeKey
							,A.CreatedBy
							,A.DateCreated as DateCreated
							,A.ModifiedBy
							,A.DateModified
							,A.ApprovedBy
							,A.DateApproved
							,A.FirstLevelApprovedBy as ApprovedByFirstLevel
							,A.FirstLevelDateApproved 
							,NULL AS ChangeFields
							,A.screenFlag
							 ,A.ReasonforRFAClassification 
							--,cast(A.DateofRemovalofRFAClassification as date) as DateofRemovalofRFAClassification
							,convert(varchar(10),A.DateofRemovalofRFAClassification,103) as DateofRemovalofRFAClassification 
							,A.ReasonforRemovalofRFAClassification
							--,cast(A.DateofRemovalofRFAClassificationReporting as date) as DateofRemovalofRFAClassificationReporting 
							,convert(Varchar(10),A.DateofRemovalofRFAClassificationReporting,103) as DateofRemovalofRFAClassificationReporting 
							,A.RFAReportedOtherBank
							,A.NameofBank
					       ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy  
                           ,IsNull(A.DateModified,A.DateCreated)as CrModDate  
                           ,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy  
                           ,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate  
                           ,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy  
                           ,ISNULL(A.DateApproved,A.DateModified) as ModAppDate		
						   , CASE WHEN  ISNULL(A.AuthorisationStatus,'A')='A' THEN 'Authorized'
								  WHEN  ISNULL(A.AuthorisationStatus,'A')='R' THEN 'Rejected'
								  WHEN  ISNULL(A.AuthorisationStatus,'A')='1A' THEN '2nd Level Authorization Pending'
								  WHEN  ISNULL(A.AuthorisationStatus,'A') IN ('NP','MP') THEN '1st Level Authorization Pending' ELSE NULL END AS AuthorisationStatus_1	
								  --,a.changeFields
	                  FROM Fraud_Details_Mod A 
				      LEFT JOIN   AdvAcBasicDetail B
					  ON          A.RefCustomerAcid=B.CustomerACID  
					  AND			B.EffectiveFromTimeKey <= @TimeKey
						   and B.EffectiveToTimeKey >= @TimeKey
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
					  LEFT JOIN  DIMSOURCEDB C
					  ON          B.SourceAlt_Key=C.SourceAlt_Key 
					  AND         C.EffectiveFromTimeKey <= @TimeKey AND C.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMSOURCEDB CC
					  ON          BB.SourceAlt_Key=CC.SourceAlt_Key 
					  AND         CC.EffectiveFromTimeKey <= @TimeKey AND CC.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMSOURCEDB CD
					  ON          IJ.SourceAlt_Key=CD.SourceAlt_Key 
					  AND         CD.EffectiveFromTimeKey <= @TimeKey AND CD.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMSOURCEDB CE
					  ON          DV.SourceSystem=CE.SourceName 
					  AND         CE.EffectiveFromTimeKey <= @TimeKey AND CE.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN  CustomerBasicDetail D
					  ON          D.CustomerId=B.RefCustomerId
					  AND         D.EffectiveFromTimeKey <= @TimeKey AND D.EffectiveToTimeKey >= @TimeKey
					 LEFT JOIN   DIMBRANCH E
					  ON          B.BranchCode=E.BranchCode
					  AND         E.EffectiveFromTimeKey <= @TimeKey AND E.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMBRANCH EE
					  ON          BB.BranchCode=EE.BranchCode 
					  AND         EE.EffectiveFromTimeKey <= @TimeKey AND EE.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMBRANCH ED
					  ON          IJ.BranchCode=ED.BranchCode 
					  AND         ED.EffectiveFromTimeKey <= @TimeKey AND ED.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMBRANCH EC
					  ON          DV.BranchCode=EC.BranchCode 
					  AND         EC.EffectiveFromTimeKey <= @TimeKey AND EC.EffectiveToTimeKey >= @TimeKey

					  LEFT JOIN  DimAcBuSegment  F
					  ON		  B.segmentcode=F.AcBuSegmentCode
					  AND         F.EffectiveFromTimeKey <= @TimeKey AND F.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN  DimAcBuSegment  FF
					  ON		  BB.segmentcode=FF.AcBuSegmentCode
					  AND         FF.EffectiveFromTimeKey <= @TimeKey AND FF.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN  DIMPRODUCT G
					  ON          B.ProductAlt_Key=G.ProductAlt_Key
					  AND         G.EffectiveFromTimeKey <= @TimeKey AND G.EffectiveToTimeKey >= @TimeKey
					  LEFT join  AdvCustNpaDetail H
					  ON          D.CustomerEntityId=H.CustomerEntityId
					  AND         H.EffectiveFromTimeKey <= @TimeKey AND H.EffectiveToTimeKey >= @TimeKey
					   LEFT join  AdvCustNpaDetail HH
					  ON          BB.CustomerEntityId=HH.CustomerEntityId
					  AND         HH.EffectiveFromTimeKey <= @TimeKey AND HH.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN  DIMASSETCLASS I
					  ON          A.AssetClassAtFraudAltKey=I.AssetClassAlt_Key
					  AND		I.EffectiveToTimeKey = 49999
					  LEFT JOIN  DIMASSETCLASS L
					  ON          H.Cust_AssetClassAlt_Key=L.AssetClassAlt_Key
					  AND         L.EffectiveToTimeKey = 49999
					    LEFT JOIN  DIMASSETCLASS LL
					  ON          HH.Cust_AssetClassAlt_Key=LL.AssetClassAlt_Key
					  AND         LL.EffectiveToTimeKey = 49999
					   LEFT JOIN  DIMASSETCLASS LK
					  ON          IK.FinalAssetClassAlt_key=LK.AssetClassAlt_Key
					  AND         LK.EffectiveToTimeKey = 49999
					  LEFT JOIN  DIMASSETCLASS LM
					  ON         DV.FinalAssetClassAlt_key=LM.AssetClassAlt_Key
					  AND         LM.EffectiveToTimeKey = 49999
					  Left join  #CustNPADetail Q
					  ON         Q.RefCustomerID=D.CustomerId
					  LEFT JOIN   DimAssetClass R
					  ON          Q.Cust_AssetClassAlt_Key=R.AssetClassAlt_Key
					  AND         R.EffectiveToTimeKey = 49999					  
					  LEFT JOIN   DimAssetClass S
					  ON          A.AssetClassAlt_KeyBeforeFruad=S.AssetClassAlt_Key
					  AND         S.EffectiveToTimeKey = 49999
                           WHERE 
						   -- AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
						     ISNULL(A.AuthorisationStatus, 'A') IN  ('NP', 'MP', 'DP', 'RM','1A')
                           AND A.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM Fraud_Details_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN ('NP', 'MP', 'DP','D1', 'RM','1A')
                         GROUP BY EntityKey
                     )
                 ) A 
                      
                 
                 GROUP BY   AccountEntityId
							,CustomerEntityId
							,RefCustomerACID
							,RefCustomerID
							,SourceName
							,BranchCode
							,BranchName
							,AcBuSegmentCode
							,AcBuSegmentDescription
							,UCIF_ID 							
							,CustomerName	
							,TOS				
							,POS
							,AssetClassAlt_KeyBeforeFruad
							,AssetClassAtFraud
							,NPADateAtFraud
							,RFA_ReportingByBank
							,RFA_DateReportingByBank
							,RFA_OtherBankAltKey
							,RFA_OtherBankDate
							,FraudOccuranceDate
							,FraudDeclarationDate
							,FraudNature
							,FraudArea
							,CurrentAssetClassName
							,CurrentAssetClassAltKey
							,CurrentNPA_Date
							,Provisionpreference
							,A.AuthorisationStatus
							,A.EffectiveFromTimeKey
							,A.EffectiveToTimeKey
							,A.CreatedBy
							,A.DateCreated
							,A.ModifiedBy
							,A.DateModified
							,A.ApprovedBy
							,A.DateApproved
							,ApprovedByFirstLevel
							,FirstLevelDateApproved 
							,A.ChangeFields
							,A.screenFlag
							 ,A.ReasonforRFAClassification 
							,A.DateofRemovalofRFAClassification 
							,A.ReasonforRemovalofRFAClassification 
							,A.DateofRemovalofRFAClassificationReporting 
							,A.RFAReportedOtherBank
							,A.NameofBank
							,A.CrModBy
							,A.CrModDate
							,A.CrAppBy
							,A.CrAppDate
							,A.ModAppBy
							,A.ModAppDate
							,A.AuthorisationStatus_1
							--A.changeFields

                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY RefCustomerACID) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'Fraud' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp_Fraud A
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner
				  Order By DataPointOwner.DateCreated Desc
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
                 --      AND RowNumber <= (@PageNo * @PageSize);
             END
			 
 

			 /*  IT IS Used For GRID Search which are Pending for Authorization    */

			 IF(@OperationFlag in (16,17))

             BEGIN
			 IF OBJECT_ID('TempDB..#temp16') IS NOT NULL
                 DROP TABLE #temp16;
print 'Prashant1'
                 SELECT		 AccountEntityId
							,CustomerEntityId
							,RefCustomerACID
							,RefCustomerID
							,SourceName
							,BranchCode
							,BranchName
							,AcBuSegmentCode
							,AcBuSegmentDescription
							,UCIF_ID 							
							,CustomerName	
							,TOS				
							,POS
							,AssetClassAlt_KeyBeforeFruad
							,AssetClassAtFraud
							,NPADateAtFraud
							,RFA_ReportingByBank
							,RFA_DateReportingByBank
							,RFA_OtherBankAltKey
							,RFA_OtherBankDate
							,FraudOccuranceDate
							,FraudDeclarationDate
							,FraudNature
							,FraudArea
							,CurrentAssetClassName
							,CurrentAssetClassAltKey
							,CurrentNPA_Date
							,Provisionpreference
							,A.AuthorisationStatus
							,A.EffectiveFromTimeKey
							,A.EffectiveToTimeKey
							,A.CreatedBy
							,A.DateCreated
							,A.ModifiedBy
							,A.DateModified
							,A.ApprovedBy
							,A.DateApproved
							,ApprovedByFirstLevel
							,FirstLevelDateApproved 
							,A.ChangeFields
							,A.screenFlag
							 ,A.ReasonforRFAClassification 
							,A.DateofRemovalofRFAClassification 
							,A.ReasonforRemovalofRFAClassification 
							,A.DateofRemovalofRFAClassificationReporting 
							,A.RFAReportedOtherBank
							,A.NameofBank
							,A.CrModBy
							,A.CrModDate
							,A.CrAppBy
							,A.CrAppDate
							,A.ModAppBy
							,A.ModAppDate
							,A.AuthorisationStatus_1
							--,A.changeFields
                 INTO #temp16
                 FROM 
                 (
                   SELECT 
                           --A.Account_ID
							 (CASE	WHEN B.AccountEntityId is NOT NULL THEN B.AccountEntityId 
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
							,(CASE WHEN C.SourceName is not NULL THen c.SourceName 
							 WHEN CC.SourceName is not NULL THen cC.SourceName 
							  WHEN CD.SourceName is not NULL THen cd.SourceName 
							  ELSE CE.SourceName END)SourceName
							,(CASE WHEN E.BranchCode is not NULL THen E.BranchCode 
							 WHEN EE.BranchCode is not NULL THen EE.BranchCode 
							  WHEN ED.BranchCode is not NULL THen ED.BranchCode
							  ELSE EC.BranchCode END)BranchCode							
							 ,(CASE WHEN E.BranchName is not NULL THen E.BranchName 
							 WHEN EE.BranchName is not NULL THen EE.BranchName 
							  WHEN ED.BranchName is not NULL THen ED.BranchName
							  ELSE EC.BranchName END)BranchName
							,(CASE WHEN F.AcBuSegmentCode is not NULL THEN F.AcBuSegmentCode ELSE F.AcBuSegmentCode END)AcBuSegmentCode
							,(CASE WHEN  F.AcBuSegmentDescription is not NULL THEN F.AcBuSegmentDescription ELSE F.AcBuSegmentDescription END)AcBuSegmentDescription
							,(CASE WHEN D.UCIF_ID is not NULL THen D.UCIF_ID 
							 WHEN BB.RefCustomerID is not NULL THen BB.RefCustomerID
							  WHEN IJ.UcifId is not NULL THen IJ.UcifId
							  ELSE DV.UCIC_ID END)UCIF_ID 
							,(CASE WHEN D.CustomerName is NOT NULL THEN D.CustomerName
							WHEN BB.CustomerName is NOT NULL THEN BB.CustomerName
							WHEN IJ.IssuerName is NOT NULL THEN IJ.IssuerName
							 ELSE DV.CustomerName END) as CustomerName																
							,(CASE	WHEN J.Balance is not NULL THEN J.Balance
									WHEN JJ.Balance is not NULL THEN JJ.Balance
									WHEN IK.BookValueINR is not NULL THEN IK.BookValueINR
									ELSE DV.OsAmt END) as TOS				
							,(CASE	WHEN J.PrincipalBalance is not NULL THEN J.PrincipalBalance
									WHEN JJ.Balance is not NULL THEN JJ.Balance
									WHEN IK.MTMValueINR is not NULL THEN IK.MTMValueINR
									ELSE DV.pos END) as POS
							,A.AssetClassAlt_KeyBeforeFruad as AssetClassAlt_KeyBeforeFruad
							,(case when S.AssetClassName is null then 'STANDARD' else S.AssetClassName end) as AssetClassAtFraud
							--,(CASE WHEN cast(NPA_DateAtFraud as date) = '01/01/1900' THEN '' ELSE cast(NPA_DateAtFraud as date) END) as NPADateAtFraud
							,(CASE WHEN cast(A.NPADateBeforeFraud as date) = '01/01/1900' THEN '' ELSE Convert(Varchar(10),A.NPADateBeforeFraud,103) END) as NPADateAtFraud
							,RFA_ReportingByBank
							--,(CASE WHEN cast(RFA_DateReportingByBank as date) = '01/01/1900' THEN '' ELSE cast(RFA_DateReportingByBank as date) END) RFA_DateReportingByBank
							,(CASE WHEN cast(RFA_DateReportingByBank as date) = '01/01/1900' THEN '' ELSE convert(varchar(10),RFA_DateReportingByBank,103) END) RFA_DateReportingByBank
							,RFA_OtherBankAltKey
							--,(CASE WHEN cast(RFA_OtherBankDate as date) = '01/01/1900' THEN '' ELSE cast(RFA_OtherBankDate as date) END) RFA_OtherBankDate
							,(CASE WHEN cast(RFA_OtherBankDate as date) = '01/01/1900' THEN '' ELSE convert(varchar(10),RFA_OtherBankDate,103) END) RFA_OtherBankDate
							--,(CASE WHEN cast(FraudOccuranceDate as date) = '01/01/1900' THEN '' ELSE cast(FraudOccuranceDate as date) END) FraudOccuranceDate
							,(CASE WHEN cast(FraudOccuranceDate as date) = '01/01/1900' THEN '' ELSE convert(varchar(10),FraudOccuranceDate,103) END) FraudOccuranceDate
							--,(CASE WHEN cast(FraudDeclarationDate as date) = '01/01/1900' THEN '' ELSE cast(FraudDeclarationDate as date) END)FraudDeclarationDate
							,(CASE WHEN cast(FraudDeclarationDate as date) = '01/01/1900' THEN '' ELSE convert(Varchar(10),FraudDeclarationDate,103) END)FraudDeclarationDate
							,FraudNature
							,FraudArea
							,(CASE	WHEN L.AssetClassName is not NULL THEN L.AssetClassName 
									WHEN LL.AssetClassName is not NULL THEN LL.AssetClassName
									WHEN LK.AssetClassName is not NULL THEN LK.AssetClassName
									ELSE LM.AssetClassName END) as CurrentAssetClassName
							,(CASE	WHEN H.Cust_AssetClassAlt_Key is not NULL THEN H.Cust_AssetClassAlt_Key
									WHEN HH.Cust_AssetClassAlt_Key is not NULL THEN HH.Cust_AssetClassAlt_Key
									WHEN IK.FinalAssetClassAlt_Key is not NULL THEN IK.FinalAssetClassAlt_Key
									ELSE DV.FinalAssetClassAlt_KEy 
								    END)  as CurrentAssetClassAltKey
							--,cast(H.NPADt as date) as CurrentNPA_Date
							,(CASE	WHEN convert(varchar(10),H.NPADt,103) is not NULL THEN convert(varchar(10),H.NPADt,103)
									WHEN convert(varchar(10),HH.NPADt,103) is not NULL THEN convert(varchar(10),HH.NPADt,103)
									WHEN convert(varchar(10),IK.NPIDt,103) is not NULL THEN convert(varchar(10),IK.NPIDt,103)
									ELSE convert(varchar(10),DV.NPIDt,103) END)as CurrentNPA_Date
							,ProvPref as Provisionpreference
							,(CASE WHEN A.AuthorisationStatus is not NULL THEN A.AuthorisationStatus ELSE NULL END)  AuthorisationStatus
							,A.EffectiveFromTimeKey
							,A.EffectiveToTimeKey
							,A.CreatedBy
							,A.DateCreated as DateCreated
							,A.ModifiedBy
							,A.DateModified
							,A.ApprovedBy
							,A.DateApproved
							,A.FirstLevelApprovedBy as ApprovedByFirstLevel
							,A.FirstLevelDateApproved 
							,NULL AS ChangeFields
							,A.screenFlag
							 ,A.ReasonforRFAClassification 
							--,cast(A.DateofRemovalofRFAClassification as date) as DateofRemovalofRFAClassification
							,convert(varchar(10),A.DateofRemovalofRFAClassification,103) as DateofRemovalofRFAClassification 
							,A.ReasonforRemovalofRFAClassification
							--,cast(A.DateofRemovalofRFAClassificationReporting as date) as DateofRemovalofRFAClassificationReporting 
							,convert(Varchar(10),A.DateofRemovalofRFAClassificationReporting,103) as DateofRemovalofRFAClassificationReporting 
							,A.RFAReportedOtherBank
							,A.NameofBank
					       ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy  
                           ,IsNull(A.DateModified,A.DateCreated)as CrModDate  
                           ,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy  
                           ,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate  
                           ,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy  
                           ,ISNULL(A.DateApproved,A.DateModified) as ModAppDate		
						   , CASE WHEN  ISNULL(A.AuthorisationStatus,'A')='A' THEN 'Authorized'
								  WHEN  ISNULL(A.AuthorisationStatus,'A')='R' THEN 'Rejected'
								  WHEN  ISNULL(A.AuthorisationStatus,'A')='1A' THEN '2nd Level Authorization Pending'
								  WHEN  ISNULL(A.AuthorisationStatus,'A') IN ('NP','MP') THEN '1st Level Authorization Pending' ELSE NULL END AS AuthorisationStatus_1		
								  --,a.changeFields
      --               FROM Fraud_AWO A
					 --WHERE A.EffectiveFromTimeKey <= @TimeKey
      --               AND A.EffectiveToTimeKey >= @TimeKey
      --               AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
	                  FROM Fraud_Details_Mod A 
				      LEFT JOIN   AdvAcBasicDetail B
					  ON          A.RefCustomerAcid=B.CustomerACID  
					  AND			B.EffectiveFromTimeKey <= @TimeKey
                      AND			B.EffectiveToTimeKey >= @TimeKey
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
					  LEFT JOIN  DIMSOURCEDB C
					  ON          B.SourceAlt_Key=C.SourceAlt_Key 
					  AND         C.EffectiveFromTimeKey <= @TimeKey AND C.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMSOURCEDB CC
					  ON          BB.SourceAlt_Key=CC.SourceAlt_Key 
					  AND         CC.EffectiveFromTimeKey <= @TimeKey AND CC.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMSOURCEDB CD
					  ON          IJ.SourceAlt_Key=CD.SourceAlt_Key 
					  AND         CD.EffectiveFromTimeKey <= @TimeKey AND CD.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMSOURCEDB CE
					  ON          DV.SourceSystem=CE.SourceName 
					  AND         CE.EffectiveFromTimeKey <= @TimeKey AND CE.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN  CustomerBasicDetail D
					  ON          D.CustomerId=B.RefCustomerId
					  AND         D.EffectiveFromTimeKey <= @TimeKey AND D.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN   DIMBRANCH E
					  ON          B.BranchCode=E.BranchCode
					  AND         E.EffectiveFromTimeKey <= @TimeKey AND E.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMBRANCH EE
					  ON          BB.BranchCode=EE.BranchCode 
					  AND         EE.EffectiveFromTimeKey <= @TimeKey AND EE.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMBRANCH ED
					  ON          IJ.BranchCode=ED.BranchCode 
					  AND         ED.EffectiveFromTimeKey <= @TimeKey AND ED.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMBRANCH EC
					  ON          DV.BranchCode=EC.BranchCode 
					  AND         EC.EffectiveFromTimeKey <= @TimeKey AND EC.EffectiveToTimeKey >= @TimeKey

					  LEFT JOIN  DimAcBuSegment  F
					  ON		  B.segmentcode=F.AcBuSegmentCode
					  AND         F.EffectiveFromTimeKey <= @TimeKey AND F.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN  DIMPRODUCT G
					  ON          B.ProductAlt_Key=G.ProductAlt_Key
					  AND         G.EffectiveFromTimeKey <= @TimeKey AND G.EffectiveToTimeKey >= @TimeKey
					  LEFT join  AdvCustNpaDetail H
					  ON          D.CustomerEntityId=H.CustomerEntityId
					  AND         H.EffectiveFromTimeKey <= @TimeKey AND H.EffectiveToTimeKey >= @TimeKey
					   LEFT join  AdvCustNpaDetail HH
					  ON          BB.CustomerEntityId=HH.CustomerEntityId
					  AND         HH.EffectiveFromTimeKey <= @TimeKey AND HH.EffectiveToTimeKey >= @TimeKey
					   LEFT JOIN  DIMASSETCLASS I
					  ON          A.AssetClassAtFraudAltKey=I.AssetClassAlt_Key
					  AND		I.EffectiveToTimeKey = 49999
					  LEFT JOIN  DIMASSETCLASS L
					  ON          H.Cust_AssetClassAlt_Key=L.AssetClassAlt_Key
					  AND         L.EffectiveToTimeKey = 49999
					    LEFT JOIN  DIMASSETCLASS LL
					  ON          HH.Cust_AssetClassAlt_Key=LL.AssetClassAlt_Key
					  AND         LL.EffectiveToTimeKey = 49999
					   LEFT JOIN  DIMASSETCLASS LK
					  ON          IK.FinalAssetClassAlt_key=LK.AssetClassAlt_Key
					  AND         LK.EffectiveToTimeKey = 49999
					  LEFT JOIN  DIMASSETCLASS LM
					  ON         DV.FinalAssetClassAlt_key=LM.AssetClassAlt_Key
					  AND         LM.EffectiveToTimeKey = 49999
					  Left join  #CustNPADetail Q
					  ON         Q.RefCustomerID=D.CustomerId

					  LEFT JOIN   DimAssetClass R
					  ON          Q.Cust_AssetClassAlt_Key=R.AssetClassAlt_Key
					  AND         R.EffectiveToTimeKey = 49999

					  LEFT JOIN   DimAssetClass S
					  ON          A.AssetClassAlt_KeyBeforeFruad=S.AssetClassAlt_Key
					  AND         S.EffectiveToTimeKey = 49999

					  WHERE 
						   -- AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
						     ISNULL(A.AuthorisationStatus, 'A') IN  ('NP', 'MP')
                             AND A.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM Fraud_Details_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN ('NP', 'MP', 'DP','D1', 'RM','1A')
                         GROUP BY EntityKey
                     )
                 ) A 
                      
                 
                 GROUP BY	 AccountEntityId
							,CustomerEntityId
							,RefCustomerACID
							,RefCustomerID
							,SourceName
							,BranchCode
							,BranchName
							,AcBuSegmentCode
							,AcBuSegmentDescription
							,UCIF_ID 							
							,CustomerName	
							,TOS				
							,POS
							,AssetClassAlt_KeyBeforeFruad
							,AssetClassAtFraud
							,NPADateAtFraud
							,RFA_ReportingByBank
							,RFA_DateReportingByBank
							,RFA_OtherBankAltKey
							,RFA_OtherBankDate
							,FraudOccuranceDate
							,FraudDeclarationDate
							,FraudNature
							,FraudArea
							,CurrentAssetClassName
							,CurrentAssetClassAltKey
							,CurrentNPA_Date
							,Provisionpreference
							,A.AuthorisationStatus
							,A.EffectiveFromTimeKey
							,A.EffectiveToTimeKey
							,A.CreatedBy
							,A.DateCreated
							,A.ModifiedBy
							,A.DateModified
							,A.ApprovedBy
							,A.DateApproved
							,ApprovedByFirstLevel
							,FirstLevelDateApproved 
							,A.ChangeFields
							,A.screenFlag
							 ,A.ReasonforRFAClassification 
							,A.DateofRemovalofRFAClassification 
							,A.ReasonforRemovalofRFAClassification 
							,A.DateofRemovalofRFAClassificationReporting 
							,A.RFAReportedOtherBank
							,A.NameofBank
							,A.CrModBy
							,A.CrModDate
							,A.CrAppBy
							,A.CrAppDate
							,A.ModAppBy
							,A.ModAppDate
							,A.AuthorisationStatus_1
							--,A.changeFields
                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY RefCustomerACID) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'Fraud' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp16 A
						 
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner
				  Order By DataPointOwner.DateCreated Desc
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
                 --      AND RowNumber <= (@PageNo * @PageSize)

   END;

   

    IF (@OperationFlag =20)
             BEGIN

    IF OBJECT_ID('TempDB..#temp20') IS NOT NULL
                 DROP TABLE #temp20;
	print 'Prashant2'
                 SELECT		AccountEntityId
							,CustomerEntityId
							,RefCustomerACID
							,RefCustomerID
							,SourceName
							,BranchCode
							,BranchName
							,AcBuSegmentCode
							,AcBuSegmentDescription
							,UCIF_ID 							
							,CustomerName	
							,TOS				
							,POS
							,AssetClassAlt_KeyBeforeFruad
							,AssetClassAtFraud
							,NPADateAtFraud
							,RFA_ReportingByBank
							,RFA_DateReportingByBank
							,RFA_OtherBankAltKey
							,RFA_OtherBankDate
							,FraudOccuranceDate
							,FraudDeclarationDate
							,FraudNature
							,FraudArea
							,CurrentAssetClassName
							,CurrentAssetClassAltKey
							,CurrentNPA_Date
							,Provisionpreference
							,A.AuthorisationStatus
							,A.EffectiveFromTimeKey
							,A.EffectiveToTimeKey
							,A.CreatedBy
							,A.DateCreated
							,A.ModifiedBy
							,A.DateModified
							,A.ApprovedBy
							,A.DateApproved
							,ApprovedByFirstLevel
							,FirstLevelDateApproved 
							,A.ChangeFields
							,A.screenFlag
							 ,A.ReasonforRFAClassification 
							,A.DateofRemovalofRFAClassification 
							,A.ReasonforRemovalofRFAClassification 
							,A.DateofRemovalofRFAClassificationReporting 
							,A.RFAReportedOtherBank
							,A.NameofBank
							,A.CrModBy
							,A.CrModDate
							,A.CrAppBy
							,A.CrAppDate
							,A.ModAppBy
							,A.ModAppDate
							,A.AuthorisationStatus_1
							--,A.changeFields
                 INTO #temp20
                 FROM 
                 (
                    SELECT 
                             --A.Account_ID
							(CASE	WHEN B.AccountEntityId is NOT NULL THEN B.AccountEntityId 
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
							,(CASE WHEN C.SourceName is not NULL THen c.SourceName 
							 WHEN CC.SourceName is not NULL THen cC.SourceName 
							  WHEN CD.SourceName is not NULL THen cd.SourceName 
							  ELSE CE.SourceName END)SourceName
							,(CASE WHEN E.BranchCode is not NULL THen E.BranchCode 
							 WHEN EE.BranchCode is not NULL THen EE.BranchCode 
							  WHEN ED.BranchCode is not NULL THen ED.BranchCode
							  ELSE EC.BranchCode END)BranchCode							
							 ,(CASE WHEN E.BranchName is not NULL THen E.BranchName 
							 WHEN EE.BranchName is not NULL THen EE.BranchName 
							  WHEN ED.BranchName is not NULL THen ED.BranchName
							  ELSE EC.BranchName END)BranchName
							,(CASE WHEN F.AcBuSegmentCode is not NULL THEN F.AcBuSegmentCode ELSE F.AcBuSegmentCode END)AcBuSegmentCode
							,(CASE WHEN  F.AcBuSegmentDescription is not NULL THEN F.AcBuSegmentDescription ELSE F.AcBuSegmentDescription END)AcBuSegmentDescription
							,(CASE WHEN D.UCIF_ID is not NULL THen D.UCIF_ID 
							 WHEN BB.RefCustomerID is not NULL THen BB.RefCustomerID
							  WHEN IJ.UcifId is not NULL THen IJ.UcifId
							  ELSE DV.UCIC_ID END)UCIF_ID 
							,(CASE WHEN D.CustomerName is NOT NULL THEN D.CustomerName
							WHEN BB.CustomerName is NOT NULL THEN BB.CustomerName
							WHEN IJ.IssuerName is NOT NULL THEN IJ.IssuerName
							 ELSE DV.CustomerName END) as CustomerName																
							,(CASE	WHEN J.Balance is not NULL THEN J.Balance
									WHEN JJ.Balance is not NULL THEN JJ.Balance
									WHEN IK.BookValueINR is not NULL THEN IK.BookValueINR
									ELSE DV.OsAmt END) as TOS				
							,(CASE	WHEN J.PrincipalBalance is not NULL THEN J.PrincipalBalance
									WHEN JJ.Balance is not NULL THEN JJ.Balance
									WHEN IK.MTMValueINR is not NULL THEN IK.MTMValueINR
									ELSE DV.pos END) as POS
							,A.AssetClassAlt_KeyBeforeFruad as AssetClassAlt_KeyBeforeFruad
							,(case when S.AssetClassName is null then 'STANDARD' else S.AssetClassName end) as AssetClassAtFraud
							--,(CASE WHEN cast(NPA_DateAtFraud as date) = '01/01/1900' THEN '' ELSE cast(NPA_DateAtFraud as date) END) as NPADateAtFraud
							,(CASE WHEN cast(A.NPADateBeforeFraud as date) = '01/01/1900' THEN '' ELSE Convert(Varchar(10),A.NPADateBeforeFraud,103) END) as NPADateAtFraud
							,RFA_ReportingByBank
							--,(CASE WHEN cast(RFA_DateReportingByBank as date) = '01/01/1900' THEN '' ELSE cast(RFA_DateReportingByBank as date) END) RFA_DateReportingByBank
							,(CASE WHEN cast(RFA_DateReportingByBank as date) = '01/01/1900' THEN '' ELSE convert(varchar(10),RFA_DateReportingByBank,103) END) RFA_DateReportingByBank
							,RFA_OtherBankAltKey
							--,(CASE WHEN cast(RFA_OtherBankDate as date) = '01/01/1900' THEN '' ELSE cast(RFA_OtherBankDate as date) END) RFA_OtherBankDate
							,(CASE WHEN cast(RFA_OtherBankDate as date) = '01/01/1900' THEN '' ELSE convert(varchar(10),RFA_OtherBankDate,103) END) RFA_OtherBankDate
							--,(CASE WHEN cast(FraudOccuranceDate as date) = '01/01/1900' THEN '' ELSE cast(FraudOccuranceDate as date) END) FraudOccuranceDate
							,(CASE WHEN cast(FraudOccuranceDate as date) = '01/01/1900' THEN '' ELSE convert(varchar(10),FraudOccuranceDate,103) END) FraudOccuranceDate
							--,(CASE WHEN cast(FraudDeclarationDate as date) = '01/01/1900' THEN '' ELSE cast(FraudDeclarationDate as date) END)FraudDeclarationDate
							,(CASE WHEN cast(FraudDeclarationDate as date) = '01/01/1900' THEN '' ELSE convert(Varchar(10),FraudDeclarationDate,103) END)FraudDeclarationDate
							,FraudNature
							,FraudArea
							,(CASE	WHEN L.AssetClassName is not NULL THEN L.AssetClassName 
									WHEN LL.AssetClassName is not NULL THEN LL.AssetClassName
									WHEN LK.AssetClassName is not NULL THEN LK.AssetClassName
									ELSE LM.AssetClassName END) as CurrentAssetClassName
							,(CASE	WHEN H.Cust_AssetClassAlt_Key is not NULL THEN H.Cust_AssetClassAlt_Key
									WHEN HH.Cust_AssetClassAlt_Key is not NULL THEN HH.Cust_AssetClassAlt_Key
									WHEN IK.FinalAssetClassAlt_Key is not NULL THEN IK.FinalAssetClassAlt_Key
									ELSE DV.FinalAssetClassAlt_KEy 
								    END)  as CurrentAssetClassAltKey
							--,cast(H.NPADt as date) as CurrentNPA_Date
							,(CASE	WHEN convert(varchar(10),H.NPADt,103) is not NULL THEN convert(varchar(10),H.NPADt,103)
									WHEN convert(varchar(10),HH.NPADt,103) is not NULL THEN convert(varchar(10),HH.NPADt,103)
									WHEN convert(varchar(10),IK.NPIDt,103) is not NULL THEN convert(varchar(10),IK.NPIDt,103)
									ELSE convert(varchar(10),DV.NPIDt,103) END)as CurrentNPA_Date
							,ProvPref as Provisionpreference
							,(CASE WHEN A.AuthorisationStatus is not NULL THEN A.AuthorisationStatus ELSE NULL END)  AuthorisationStatus
							,A.EffectiveFromTimeKey
							,A.EffectiveToTimeKey
							,A.CreatedBy
							,A.DateCreated as DateCreated
							,A.ModifiedBy
							,A.DateModified
							,A.ApprovedBy
							,A.DateApproved
							,A.FirstLevelApprovedBy as ApprovedByFirstLevel
							,A.FirstLevelDateApproved 
							,NULL AS ChangeFields
							,A.screenFlag
							 ,A.ReasonforRFAClassification 
							--,cast(A.DateofRemovalofRFAClassification as date) as DateofRemovalofRFAClassification
							,convert(varchar(10),A.DateofRemovalofRFAClassification,103) as DateofRemovalofRFAClassification 
							,A.ReasonforRemovalofRFAClassification
							--,cast(A.DateofRemovalofRFAClassificationReporting as date) as DateofRemovalofRFAClassificationReporting 
							,convert(Varchar(10),A.DateofRemovalofRFAClassificationReporting,103) as DateofRemovalofRFAClassificationReporting 
							,A.RFAReportedOtherBank
							,A.NameofBank
					       ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy  
                           ,IsNull(A.DateModified,A.DateCreated)as CrModDate  
                           ,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy  
                           ,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate  
                           ,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy  
                           ,ISNULL(A.DateApproved,A.DateModified) as ModAppDate		
						   , CASE WHEN  ISNULL(A.AuthorisationStatus,'A')='A' THEN 'Authorized'
								  WHEN  ISNULL(A.AuthorisationStatus,'A')='R' THEN 'Rejected'
								  WHEN  ISNULL(A.AuthorisationStatus,'A')='1A' THEN '2nd Level Authorization Pending'
								  WHEN  ISNULL(A.AuthorisationStatus,'A') IN ('NP','MP') THEN '1st Level Authorization Pending' ELSE NULL END AS AuthorisationStatus_1											 
	                  FROM Fraud_Details_Mod A 
				      LEFT JOIN   AdvAcBasicDetail B
					  ON          A.RefCustomerAcid=B.CustomerACID  
					  AND		B.EffectiveFromTimeKey <= @TimeKey
                           AND B.EffectiveToTimeKey >= @TimeKey                           
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
					  LEFT JOIN  DIMSOURCEDB C
					  ON          B.SourceAlt_Key=C.SourceAlt_Key 
					  AND         C.EffectiveFromTimeKey <= @TimeKey AND C.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMSOURCEDB CC
					  ON          BB.SourceAlt_Key=CC.SourceAlt_Key 
					  AND         CC.EffectiveFromTimeKey <= @TimeKey AND CC.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMSOURCEDB CD
					  ON          IJ.SourceAlt_Key=CD.SourceAlt_Key 
					  AND         CD.EffectiveFromTimeKey <= @TimeKey AND CD.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMSOURCEDB CE
					  ON          DV.SourceSystem=CE.SourceName 
					  AND         CE.EffectiveFromTimeKey <= @TimeKey AND CE.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN  CustomerBasicDetail D
					  ON          D.CustomerId=B.RefCustomerId
					  AND         D.EffectiveFromTimeKey <= @TimeKey AND D.EffectiveToTimeKey >= @TimeKey
					 LEFT JOIN   DIMBRANCH E
					  ON          B.BranchCode=E.BranchCode
					  AND         E.EffectiveFromTimeKey <= @TimeKey AND E.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMBRANCH EE
					  ON          BB.BranchCode=EE.BranchCode 
					  AND         EE.EffectiveFromTimeKey <= @TimeKey AND EE.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMBRANCH ED
					  ON          IJ.BranchCode=ED.BranchCode 
					  AND         ED.EffectiveFromTimeKey <= @TimeKey AND ED.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMBRANCH EC
					  ON          DV.BranchCode=EC.BranchCode 
					  AND         EC.EffectiveFromTimeKey <= @TimeKey AND EC.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN  DimAcBuSegment  F
					  ON		  B.segmentcode=F.AcBuSegmentCode
					  AND         F.EffectiveFromTimeKey <= @TimeKey AND F.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN  DimAcBuSegment  FF
					  ON		  BB.segmentcode=FF.AcBuSegmentCode
					  AND         FF.EffectiveFromTimeKey <= @TimeKey AND FF.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN  DIMPRODUCT G
					  ON          B.ProductAlt_Key=G.ProductAlt_Key
					  AND         G.EffectiveFromTimeKey <= @TimeKey AND G.EffectiveToTimeKey >= @TimeKey
					  LEFT join  AdvCustNpaDetail H
					  ON          D.CustomerEntityId=H.CustomerEntityId
					  AND         H.EffectiveFromTimeKey <= @TimeKey AND H.EffectiveToTimeKey >= @TimeKey
					   LEFT join  AdvCustNpaDetail HH
					  ON          BB.CustomerEntityId=HH.CustomerEntityId
					  AND         HH.EffectiveFromTimeKey <= @TimeKey AND HH.EffectiveToTimeKey >= @TimeKey
					   LEFT JOIN  DIMASSETCLASS I
					  ON          A.AssetClassAtFraudAltKey=I.AssetClassAlt_Key
					  AND		I.EffectiveToTimeKey = 49999
					  LEFT JOIN  DIMASSETCLASS L
					  ON          H.Cust_AssetClassAlt_Key=L.AssetClassAlt_Key
					  AND         L.EffectiveToTimeKey = 49999
					    LEFT JOIN  DIMASSETCLASS LL
					  ON          HH.Cust_AssetClassAlt_Key=LL.AssetClassAlt_Key
					  AND         LL.EffectiveToTimeKey = 49999
					   LEFT JOIN  DIMASSETCLASS LK
					  ON          IK.FinalAssetClassAlt_key=LK.AssetClassAlt_Key
					  AND         LK.EffectiveToTimeKey = 49999
					  LEFT JOIN  DIMASSETCLASS LM
					  ON         DV.FinalAssetClassAlt_key=LM.AssetClassAlt_Key
					  AND         LM.EffectiveToTimeKey = 49999
					  Left join  #CustNPADetail Q
					  ON         Q.RefCustomerID=D.CustomerId

					  LEFT JOIN   DimAssetClass R
					  ON          Q.Cust_AssetClassAlt_Key=R.AssetClassAlt_Key
					  AND         R.EffectiveToTimeKey = 49999

					  LEFT JOIN   DimAssetClass S
					  ON          A.AssetClassAlt_KeyBeforeFruad=S.AssetClassAlt_Key
					  AND         S.EffectiveToTimeKey = 49999

					  WHERE  ISNULL(A.AuthorisationStatus, 'A') IN('1A')
                           AND A.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM Fraud_Details_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               --AND ISNULL(A.AuthorisationStatus, 'A') IN('1A')
							    AND (case when @AuthLevel =2  AND ISNULL(AuthorisationStatus, 'A') IN('1A','D1')
										THEN 1 
							           when @AuthLevel =1 AND ISNULL(AuthorisationStatus,'A') IN ('NP','MP','DP')
										THEN 1
										ELSE 0									
										END
									)=1
                         GROUP BY EntityKey
                     )
                 ) A 
                      
                 
                 GROUP BY	 AccountEntityId
							,CustomerEntityId
							,RefCustomerACID
							,RefCustomerID
							,SourceName
							,BranchCode
							,BranchName
							,AcBuSegmentCode
							,AcBuSegmentDescription
							,UCIF_ID 							
							,CustomerName	
							,TOS				
							,POS
							,AssetClassAlt_KeyBeforeFruad
							,AssetClassAtFraud
							,NPADateAtFraud
							,RFA_ReportingByBank
							,RFA_DateReportingByBank
							,RFA_OtherBankAltKey
							,RFA_OtherBankDate
							,FraudOccuranceDate
							,FraudDeclarationDate
							,FraudNature
							,FraudArea
							,CurrentAssetClassName
							,CurrentAssetClassAltKey
							,CurrentNPA_Date
							,Provisionpreference
							,A.AuthorisationStatus
							,A.EffectiveFromTimeKey
							,A.EffectiveToTimeKey
							,A.CreatedBy
							,A.DateCreated
							,A.ModifiedBy
							,A.DateModified
							,A.ApprovedBy
							,A.DateApproved
							,ApprovedByFirstLevel
							,FirstLevelDateApproved 
							,A.ChangeFields
							,A.screenFlag
							 ,A.ReasonforRFAClassification 
							,A.DateofRemovalofRFAClassification 
							,A.ReasonforRemovalofRFAClassification 
							,A.DateofRemovalofRFAClassificationReporting 
							,A.RFAReportedOtherBank
							,A.NameofBank
							,A.CrModBy
							,A.CrModDate
							,A.CrAppBy
							,A.CrAppDate
							,A.ModAppBy
							,A.ModAppDate
							,A.AuthorisationStatus_1
							--,A.changeFields


                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY RefCustomerACID) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'Fraud' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp20 A
						 
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner
				  Order By DataPointOwner.DateCreated Desc
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
                 --      AND RowNumber <= (@PageNo * @PageSize)
  END
  END;

  ------------------------------------------------------------------------------------------------
  ELSE
  ------------------------------------------------------------
   BEGIN
        
		
		   IF(@OperationFlag not in (16,17,20))
             BEGIN
		  
			 IF OBJECT_ID('TempDB..#temp_Fraud1') IS NOT NULL
                 DROP TABLE  #temp_Fraud1;
			IF (select count(1) 
				from Fraud_Details_Mod 
				where RefCustomerACID=@Account_id
				AND EffectiveFromTimeKey <= @TimeKey
                 AND EffectiveToTimeKey >= @TimeKey) = 0
				 	 
				 BEGIN

				 PRINT 'Sachin'
			 SELECT		-- A.Account_ID
				           AccountEntityId
							,CustomerEntityId
							,RefCustomerACID
							,RefCustomerID
							,SourceName
							,BranchCode
							,BranchName
							,AcBuSegmentCode
							,AcBuSegmentDescription
							,UCIF_ID 							
							,CustomerName	
							,TOS				
							,POS
							,AssetClassAlt_KeyBeforeFruad
							,AssetClassAtFraud
							,NPADateAtFraud
							,RFA_ReportingByBank
							,RFA_DateReportingByBank
							,RFA_OtherBankAltKey
							,RFA_OtherBankDate
							,FraudOccuranceDate
							,FraudDeclarationDate
							,FraudNature
							,FraudArea
							,CurrentAssetClassName
							,CurrentAssetClassAltKey
							,CurrentNPA_Date
							,Provisionpreference
							,A.AuthorisationStatus
							,A.EffectiveFromTimeKey
							,A.EffectiveToTimeKey
							,A.CreatedBy
							,A.DateCreated
							,A.ModifiedBy
							,A.DateModified
							,A.ApprovedBy
							,A.DateApproved
							,ApprovedByFirstLevel
							,FirstLevelDateApproved 
							,A.ChangeFields
							,A.screenFlag
							,A.ReasonforRFAClassification 
							,A.DateofRemovalofRFAClassification 
							,A.ReasonforRemovalofRFAClassification 
							,A.DateofRemovalofRFAClassificationReporting 
							,A.RFAReportedOtherBank
							,A.NameofBank
							,A.CrModBy
							,A.CrModDate
							,A.CrAppBy
							,A.CrAppDate
							,A.ModAppBy
							,A.ModAppDate
							,A.AuthorisationStatus_1
						
							--,A.changeFields
                 INTO #temp_Fraud11
                 FROM 
                 (
					  SELECT 
                             --A.Account_ID
							(CASE	WHEN B.AccountEntityId is NOT NULL THEN B.AccountEntityId 
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
							,(CASE WHEN C.SourceName is not NULL THen c.SourceName 
							 WHEN CC.SourceName is not NULL THen cC.SourceName 
							  WHEN CD.SourceName is not NULL THen cd.SourceName 
							  ELSE CE.SourceName END)SourceName
							,(CASE WHEN E.BranchCode is not NULL THen E.BranchCode 
							 WHEN EE.BranchCode is not NULL THen EE.BranchCode 
							  WHEN ED.BranchCode is not NULL THen ED.BranchCode
							  ELSE EC.BranchCode END)BranchCode							
							 ,(CASE WHEN E.BranchName is not NULL THen E.BranchName 
							 WHEN EE.BranchName is not NULL THen EE.BranchName 
							  WHEN ED.BranchName is not NULL THen ED.BranchName
							  ELSE EC.BranchName END)BranchName
							,(CASE WHEN F.AcBuSegmentCode is not NULL THEN F.AcBuSegmentCode ELSE F.AcBuSegmentCode END)AcBuSegmentCode
							,(CASE WHEN  F.AcBuSegmentDescription is not NULL THEN F.AcBuSegmentDescription ELSE F.AcBuSegmentDescription END)AcBuSegmentDescription
							,(CASE WHEN D.UCIF_ID is not NULL THen D.UCIF_ID 
							 WHEN BB.RefCustomerID is not NULL THen BB.RefCustomerID
							  WHEN IJ.UcifId is not NULL THen IJ.UcifId
							  ELSE DV.UCIC_ID END)UCIF_ID 
							,(CASE WHEN D.CustomerName is NOT NULL THEN D.CustomerName
							WHEN BB.CustomerName is NOT NULL THEN BB.CustomerName
							WHEN IJ.IssuerName is NOT NULL THEN IJ.IssuerName
							 ELSE DV.CustomerName END) as CustomerName																
							,(CASE	WHEN J.Balance is not NULL THEN J.Balance
									WHEN JJ.Balance is not NULL THEN JJ.Balance
									WHEN IK.BookValueINR is not NULL THEN IK.BookValueINR
									ELSE DV.OsAmt END) as TOS				
							,(CASE	WHEN J.PrincipalBalance is not NULL THEN J.PrincipalBalance
									WHEN JJ.Balance is not NULL THEN JJ.Balance
									WHEN IK.MTMValueINR is not NULL THEN IK.MTMValueINR
									ELSE DV.pos END) as POS
							,A.AssetClassAlt_KeyBeforeFruad as AssetClassAlt_KeyBeforeFruad
							,(case when S.AssetClassName is null then 'STANDARD' else S.AssetClassName end) as AssetClassAtFraud
							--,(CASE WHEN cast(NPA_DateAtFraud as date) = '01/01/1900' THEN '' ELSE cast(NPA_DateAtFraud as date) END) as NPADateAtFraud
							,(CASE WHEN cast(A.NPADateBeforeFraud as date) = '01/01/1900' THEN '' ELSE Convert(Varchar(10),A.NPADateBeforeFraud,103) END) as NPADateAtFraud
							,RFA_ReportingByBank
							--,(CASE WHEN cast(RFA_DateReportingByBank as date) = '01/01/1900' THEN '' ELSE cast(RFA_DateReportingByBank as date) END) RFA_DateReportingByBank
							,(CASE WHEN cast(RFA_DateReportingByBank as date) = '01/01/1900' THEN '' ELSE convert(varchar(10),RFA_DateReportingByBank,103) END) RFA_DateReportingByBank
							,RFA_OtherBankAltKey
							--,(CASE WHEN cast(RFA_OtherBankDate as date) = '01/01/1900' THEN '' ELSE cast(RFA_OtherBankDate as date) END) RFA_OtherBankDate
							,(CASE WHEN cast(RFA_OtherBankDate as date) = '01/01/1900' THEN '' ELSE convert(varchar(10),RFA_OtherBankDate,103) END) RFA_OtherBankDate
							--,(CASE WHEN cast(FraudOccuranceDate as date) = '01/01/1900' THEN '' ELSE cast(FraudOccuranceDate as date) END) FraudOccuranceDate
							,(CASE WHEN cast(FraudOccuranceDate as date) = '01/01/1900' THEN '' ELSE convert(varchar(10),FraudOccuranceDate,103) END) FraudOccuranceDate
							--,(CASE WHEN cast(FraudDeclarationDate as date) = '01/01/1900' THEN '' ELSE cast(FraudDeclarationDate as date) END)FraudDeclarationDate
							,(CASE WHEN cast(FraudDeclarationDate as date) = '01/01/1900' THEN '' ELSE convert(Varchar(10),FraudDeclarationDate,103) END)FraudDeclarationDate
							,FraudNature
							,FraudArea
							,(CASE	WHEN L.AssetClassName is not NULL THEN L.AssetClassName 
									WHEN LL.AssetClassName is not NULL THEN LL.AssetClassName
									WHEN LK.AssetClassName is not NULL THEN LK.AssetClassName
									ELSE LM.AssetClassName END) as CurrentAssetClassName
							,(CASE	WHEN H.Cust_AssetClassAlt_Key is not NULL THEN H.Cust_AssetClassAlt_Key
									WHEN HH.Cust_AssetClassAlt_Key is not NULL THEN HH.Cust_AssetClassAlt_Key
									WHEN IK.FinalAssetClassAlt_Key is not NULL THEN IK.FinalAssetClassAlt_Key
									ELSE DV.FinalAssetClassAlt_KEy 
								    END)  as CurrentAssetClassAltKey
							--,cast(H.NPADt as date) as CurrentNPA_Date
							,(CASE	WHEN convert(varchar(10),H.NPADt,103) is not NULL THEN convert(varchar(10),H.NPADt,103)
									WHEN convert(varchar(10),HH.NPADt,103) is not NULL THEN convert(varchar(10),HH.NPADt,103)
									WHEN convert(varchar(10),IK.NPIDt,103) is not NULL THEN convert(varchar(10),IK.NPIDt,103)
									ELSE convert(varchar(10),DV.NPIDt,103) END)as CurrentNPA_Date
							,ProvPref as Provisionpreference
							,(CASE WHEN A.AuthorisationStatus is not NULL THEN A.AuthorisationStatus ELSE NULL END)  AuthorisationStatus
							,A.EffectiveFromTimeKey
							,A.EffectiveToTimeKey
							,A.CreatedBy
							,A.DateCreated as DateCreated
							,A.ModifiedBy
							,A.DateModified
							,A.ApprovedBy
							,A.DateApproved
							,A.FirstLevelApprovedBy as ApprovedByFirstLevel
							,A.FirstLevelDateApproved 
							,NULL AS ChangeFields
							,A.screenFlag
							 ,A.ReasonforRFAClassification 
							--,cast(A.DateofRemovalofRFAClassification as date) as DateofRemovalofRFAClassification
							,convert(varchar(10),A.DateofRemovalofRFAClassification,103) as DateofRemovalofRFAClassification 
							,A.ReasonforRemovalofRFAClassification
							--,cast(A.DateofRemovalofRFAClassificationReporting as date) as DateofRemovalofRFAClassificationReporting 
							,convert(Varchar(10),A.DateofRemovalofRFAClassificationReporting,103) as DateofRemovalofRFAClassificationReporting 
							,A.RFAReportedOtherBank
							,A.NameofBank
					       ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy  
                           ,IsNull(A.DateModified,A.DateCreated)as CrModDate  
                           ,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy  
                           ,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate  
                           ,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy  
                           ,ISNULL(A.DateApproved,A.DateModified) as ModAppDate		
						   , CASE WHEN  ISNULL(A.AuthorisationStatus,'A')='A' THEN 'Authorized'
								  WHEN  ISNULL(A.AuthorisationStatus,'A')='R' THEN 'Rejected'
								  WHEN  ISNULL(A.AuthorisationStatus,'A')='1A' THEN '2nd Level Authorization Pending'
								  WHEN  ISNULL(A.AuthorisationStatus,'A') IN ('NP','MP') THEN '1st Level Authorization Pending' ELSE NULL END AS AuthorisationStatus_1	
								  --,a.changeFields
      --               FROM Fraud_AWO A
					 --WHERE A.EffectiveFromTimeKey <= @TimeKey
      --               AND A.EffectiveToTimeKey >= @TimeKey
      --               AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
	                  FROM Fraud_Details_Mod A 
				       RIGHT JOIN   AdvAcBasicDetail B
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
					  LEFT JOIN  DIMSOURCEDB C
					  ON          B.SourceAlt_Key=C.SourceAlt_Key 
					  AND         C.EffectiveFromTimeKey <= @TimeKey AND C.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMSOURCEDB CC
					  ON          BB.SourceAlt_Key=CC.SourceAlt_Key 
					  AND         CC.EffectiveFromTimeKey <= @TimeKey AND CC.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMSOURCEDB CD
					  ON          IJ.SourceAlt_Key=CD.SourceAlt_Key 
					  AND         CD.EffectiveFromTimeKey <= @TimeKey AND CD.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMSOURCEDB CE
					  ON          DV.SourceSystem=CE.SourceName 
					  AND         CE.EffectiveFromTimeKey <= @TimeKey AND CE.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN  CustomerBasicDetail D
					  ON          D.CustomerId=B.RefCustomerId
					  AND         D.EffectiveFromTimeKey <= @TimeKey AND D.EffectiveToTimeKey >= @TimeKey
					 
					  LEFT JOIN   DIMBRANCH E
					  ON          B.BranchCode=E.BranchCode
					  AND         E.EffectiveFromTimeKey <= @TimeKey AND E.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMBRANCH EE
					  ON          BB.BranchCode=EE.BranchCode 
					  AND         EE.EffectiveFromTimeKey <= @TimeKey AND EE.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMBRANCH ED
					  ON          IJ.BranchCode=ED.BranchCode 
					  AND         ED.EffectiveFromTimeKey <= @TimeKey AND ED.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMBRANCH EC
					  ON          DV.BranchCode=EC.BranchCode 
					  AND         EC.EffectiveFromTimeKey <= @TimeKey AND EC.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN  DimAcBuSegment  F
					  ON		  B.segmentcode=F.AcBuSegmentCode
					  AND         F.EffectiveFromTimeKey <= @TimeKey AND F.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN  DimAcBuSegment  FF
					  ON		  BB.segmentcode=FF.AcBuSegmentCode
					  AND         FF.EffectiveFromTimeKey <= @TimeKey AND FF.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN  DIMPRODUCT G
					  ON          B.ProductAlt_Key=G.ProductAlt_Key
					  AND         G.EffectiveFromTimeKey <= @TimeKey AND G.EffectiveToTimeKey >= @TimeKey
					  LEFT join  AdvCustNpaDetail H
					  ON          D.CustomerEntityId=H.CustomerEntityId
					  AND         H.EffectiveFromTimeKey <= @TimeKey AND H.EffectiveToTimeKey >= @TimeKey
					   LEFT join  AdvCustNpaDetail HH
					  ON          BB.CustomerEntityId=HH.CustomerEntityId
					  AND         HH.EffectiveFromTimeKey <= @TimeKey AND HH.EffectiveToTimeKey >= @TimeKey
					   LEFT JOIN  DIMASSETCLASS I
					  ON          A.AssetClassAtFraudAltKey=I.AssetClassAlt_Key
					  AND		I.EffectiveToTimeKey = 49999
					  LEFT JOIN  DIMASSETCLASS L
					  ON          H.Cust_AssetClassAlt_Key=L.AssetClassAlt_Key
					  AND         L.EffectiveToTimeKey = 49999
					    LEFT JOIN  DIMASSETCLASS LL
					  ON          HH.Cust_AssetClassAlt_Key=LL.AssetClassAlt_Key
					  AND         LL.EffectiveToTimeKey = 49999
					   LEFT JOIN  DIMASSETCLASS LK
					  ON          IK.FinalAssetClassAlt_key=LK.AssetClassAlt_Key
					  AND         LK.EffectiveToTimeKey = 49999
					  LEFT JOIN  DIMASSETCLASS LM
					  ON         DV.FinalAssetClassAlt_key=LM.AssetClassAlt_Key
					  AND         LM.EffectiveToTimeKey = 49999
					  Left join  #CustNPADetail Q
					  ON         Q.RefCustomerID=D.CustomerId

					  LEFT JOIN   DimAssetClass R
					  ON          Q.Cust_AssetClassAlt_Key=R.AssetClassAlt_Key
					  AND         R.EffectiveToTimeKey = 49999

					  LEFT JOIN   DimAssetClass S
					  ON          A.AssetClassAlt_KeyBeforeFruad=S.AssetClassAlt_Key
					  AND         S.EffectiveToTimeKey = 49999

					  WHERE B.CustomerACID=@Account_id
					        AND B.EffectiveFromTimeKey <= @TimeKey
                           AND B.EffectiveToTimeKey >= @TimeKey
						   UNION
						    SELECT 
                             --A.Account_ID
							(CASE	WHEN B.AccountEntityId is NOT NULL THEN B.AccountEntityId 
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
									WHEN BB.RefCustomerID is NOT NULL THEN BB.RefCustomerID
									WHEN II.RefIssuerID is NOT NULL THEN II.RefIssuerID
									ELSE DV.CustomerID END) as RefCustomerID							
							,(CASE WHEN C.SourceName is not NULL THen c.SourceName 
							 WHEN CC.SourceName is not NULL THen cC.SourceName 
							  WHEN CD.SourceName is not NULL THen cd.SourceName 
							  ELSE CE.SourceName END)SourceName
							,(CASE WHEN E.BranchCode is not NULL THen E.BranchCode 
							 WHEN EE.BranchCode is not NULL THen EE.BranchCode 
							  WHEN ED.BranchCode is not NULL THen ED.BranchCode
							  ELSE EC.BranchCode END)BranchCode							
							 ,(CASE WHEN E.BranchName is not NULL THen E.BranchName 
							 WHEN EE.BranchName is not NULL THen EE.BranchName 
							  WHEN ED.BranchName is not NULL THen ED.BranchName
							  ELSE EC.BranchName END)BranchName
							,(CASE WHEN F.AcBuSegmentCode is not NULL THEN F.AcBuSegmentCode ELSE F.AcBuSegmentCode END)AcBuSegmentCode
							,(CASE WHEN  F.AcBuSegmentDescription is not NULL THEN F.AcBuSegmentDescription ELSE F.AcBuSegmentDescription END)AcBuSegmentDescription
							,(CASE WHEN D.UCIF_ID is not NULL THen D.UCIF_ID 
							 WHEN BB.RefCustomerID is not NULL THen BB.RefCustomerID
							  WHEN IJ.UcifId is not NULL THen IJ.UcifId
							  ELSE DV.UCIC_ID END)UCIF_ID 
							,(CASE WHEN D.CustomerName is NOT NULL THEN D.CustomerName
							WHEN BB.CustomerName is NOT NULL THEN BB.CustomerName
							WHEN IJ.IssuerName is NOT NULL THEN IJ.IssuerName
							 ELSE DV.CustomerName END) as CustomerName																
							,(CASE	WHEN J.Balance is not NULL THEN J.Balance
									WHEN JJ.Balance is not NULL THEN JJ.Balance
									WHEN IK.BookValueINR is not NULL THEN IK.BookValueINR
									ELSE DV.OsAmt END) as TOS				
							,(CASE	WHEN J.PrincipalBalance is not NULL THEN J.PrincipalBalance
									WHEN JJ.Balance is not NULL THEN JJ.Balance
									WHEN IK.MTMValueINR is not NULL THEN IK.MTMValueINR
									ELSE DV.pos END) as POS
							,A.AssetClassAlt_KeyBeforeFruad as AssetClassAlt_KeyBeforeFruad
							,(case when S.AssetClassName is null then 'STANDARD' else S.AssetClassName end) as AssetClassAtFraud
							--,(CASE WHEN cast(NPA_DateAtFraud as date) = '01/01/1900' THEN '' ELSE cast(NPA_DateAtFraud as date) END) as NPADateAtFraud
							,(CASE WHEN cast(A.NPADateBeforeFraud as date) = '01/01/1900' THEN '' ELSE Convert(Varchar(10),A.NPADateBeforeFraud,103) END) as NPADateAtFraud
							,RFA_ReportingByBank
							--,(CASE WHEN cast(RFA_DateReportingByBank as date) = '01/01/1900' THEN '' ELSE cast(RFA_DateReportingByBank as date) END) RFA_DateReportingByBank
							,(CASE WHEN cast(RFA_DateReportingByBank as date) = '01/01/1900' THEN '' ELSE convert(varchar(10),RFA_DateReportingByBank,103) END) RFA_DateReportingByBank
							,RFA_OtherBankAltKey
							--,(CASE WHEN cast(RFA_OtherBankDate as date) = '01/01/1900' THEN '' ELSE cast(RFA_OtherBankDate as date) END) RFA_OtherBankDate
							,(CASE WHEN cast(RFA_OtherBankDate as date) = '01/01/1900' THEN '' ELSE convert(varchar(10),RFA_OtherBankDate,103) END) RFA_OtherBankDate
							--,(CASE WHEN cast(FraudOccuranceDate as date) = '01/01/1900' THEN '' ELSE cast(FraudOccuranceDate as date) END) FraudOccuranceDate
							,(CASE WHEN cast(FraudOccuranceDate as date) = '01/01/1900' THEN '' ELSE convert(varchar(10),FraudOccuranceDate,103) END) FraudOccuranceDate
							--,(CASE WHEN cast(FraudDeclarationDate as date) = '01/01/1900' THEN '' ELSE cast(FraudDeclarationDate as date) END)FraudDeclarationDate
							,(CASE WHEN cast(FraudDeclarationDate as date) = '01/01/1900' THEN '' ELSE convert(Varchar(10),FraudDeclarationDate,103) END)FraudDeclarationDate
							,FraudNature
							,FraudArea
							,(CASE	WHEN L.AssetClassName is not NULL THEN L.AssetClassName 
									WHEN LL.AssetClassName is not NULL THEN LL.AssetClassName
									WHEN LK.AssetClassName is not NULL THEN LK.AssetClassName
									ELSE LM.AssetClassName END) as CurrentAssetClassName
							,(CASE	WHEN H.Cust_AssetClassAlt_Key is not NULL THEN H.Cust_AssetClassAlt_Key
									WHEN HH.Cust_AssetClassAlt_Key is not NULL THEN HH.Cust_AssetClassAlt_Key
									WHEN IK.FinalAssetClassAlt_Key is not NULL THEN IK.FinalAssetClassAlt_Key
									ELSE DV.FinalAssetClassAlt_KEy 
								    END)  as CurrentAssetClassAltKey
							--,cast(H.NPADt as date) as CurrentNPA_Date
							,(CASE	WHEN convert(varchar(10),H.NPADt,103) is not NULL THEN convert(varchar(10),H.NPADt,103)
									WHEN convert(varchar(10),HH.NPADt,103) is not NULL THEN convert(varchar(10),HH.NPADt,103)
									WHEN convert(varchar(10),IK.NPIDt,103) is not NULL THEN convert(varchar(10),IK.NPIDt,103)
									ELSE convert(varchar(10),DV.NPIDt,103) END)as CurrentNPA_Date
							,ProvPref as Provisionpreference
							,(CASE WHEN A.AuthorisationStatus is not NULL THEN A.AuthorisationStatus ELSE NULL END)  AuthorisationStatus
							,A.EffectiveFromTimeKey
							,A.EffectiveToTimeKey
							,A.CreatedBy
							,A.DateCreated as DateCreated
							,A.ModifiedBy
							,A.DateModified
							,A.ApprovedBy
							,A.DateApproved
							,A.FirstLevelApprovedBy as ApprovedByFirstLevel
							,A.FirstLevelDateApproved 
							,NULL AS ChangeFields
							,A.screenFlag
							 ,A.ReasonforRFAClassification 
							--,cast(A.DateofRemovalofRFAClassification as date) as DateofRemovalofRFAClassification
							,convert(varchar(10),A.DateofRemovalofRFAClassification,103) as DateofRemovalofRFAClassification 
							,A.ReasonforRemovalofRFAClassification
							--,cast(A.DateofRemovalofRFAClassificationReporting as date) as DateofRemovalofRFAClassificationReporting 
							,convert(Varchar(10),A.DateofRemovalofRFAClassificationReporting,103) as DateofRemovalofRFAClassificationReporting 
							,A.RFAReportedOtherBank
							,A.NameofBank
					       ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy  
                           ,IsNull(A.DateModified,A.DateCreated)as CrModDate  
                           ,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy  
                           ,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate  
                           ,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy  
                           ,ISNULL(A.DateApproved,A.DateModified) as ModAppDate		
						   , CASE WHEN  ISNULL(A.AuthorisationStatus,'A')='A' THEN 'Authorized'
								  WHEN  ISNULL(A.AuthorisationStatus,'A')='R' THEN 'Rejected'
								  WHEN  ISNULL(A.AuthorisationStatus,'A')='1A' THEN '2nd Level Authorization Pending'
								  WHEN  ISNULL(A.AuthorisationStatus,'A') IN ('NP','MP') THEN '1st Level Authorization Pending' ELSE NULL END AS AuthorisationStatus_1	
								  --,a.changeFields
      --               FROM Fraud_AWO A
					 --WHERE A.EffectiveFromTimeKey <= @TimeKey
      --               AND A.EffectiveToTimeKey >= @TimeKey
      --               AND ISNULL(A.AuthorisationStatus, 'A') = 'A'


	                  FROM Fraud_Details_Mod A 
				       LEFT JOIN   AdvAcBasicDetail B
					  ON          A.RefCustomerAcid=B.CustomerACID  
					  AND		  A.EffectiveFromTimeKey <= @TimeKey  AND A.EffectiveToTimeKey >= @TimeKey
					  RIGHT JOIN   AdvNFAcBasicDetail BB
					  ON          A.RefCustomerAcid=BB.CustomerACID  
					  AND		  BB.EffectiveFromTimeKey <= @TimeKey  AND BB.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN   AdvAcBalanceDetail J
					  ON          B.AccountEntityId = J.AccountEntityId  AND J.EffectiveFromTimeKey <= @TimeKey 
					  AND         J.EffectiveToTimeKey >= @TimeKey
					  RIGHT JOIN	  ADvFACNFDetail JJ
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
					  LEFT JOIN  DIMSOURCEDB C
					  ON          B.SourceAlt_Key=C.SourceAlt_Key 
					  AND         C.EffectiveFromTimeKey <= @TimeKey AND C.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMSOURCEDB CC
					  ON          BB.SourceAlt_Key=CC.SourceAlt_Key 
					  AND         CC.EffectiveFromTimeKey <= @TimeKey AND CC.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMSOURCEDB CD
					  ON          IJ.SourceAlt_Key=CD.SourceAlt_Key 
					  AND         CD.EffectiveFromTimeKey <= @TimeKey AND CD.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMSOURCEDB CE
					  ON          DV.SourceSystem=CE.SourceName 
					  AND         CE.EffectiveFromTimeKey <= @TimeKey AND CE.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN  CustomerBasicDetail D
					  ON          D.CustomerId=B.RefCustomerId
					  AND         D.EffectiveFromTimeKey <= @TimeKey AND D.EffectiveToTimeKey >= @TimeKey
					 
					  LEFT JOIN   DIMBRANCH E
					  ON          B.BranchCode=E.BranchCode
					  AND         E.EffectiveFromTimeKey <= @TimeKey AND E.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMBRANCH EE
					  ON          BB.BranchCode=EE.BranchCode 
					  AND         EE.EffectiveFromTimeKey <= @TimeKey AND EE.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMBRANCH ED
					  ON          IJ.BranchCode=ED.BranchCode 
					  AND         ED.EffectiveFromTimeKey <= @TimeKey AND ED.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMBRANCH EC
					  ON          DV.BranchCode=EC.BranchCode 
					  AND         EC.EffectiveFromTimeKey <= @TimeKey AND EC.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN  DimAcBuSegment  F
					  ON		  B.segmentcode=F.AcBuSegmentCode
					  AND         F.EffectiveFromTimeKey <= @TimeKey AND F.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN  DimAcBuSegment  FF
					  ON		  BB.segmentcode=FF.AcBuSegmentCode
					  AND         FF.EffectiveFromTimeKey <= @TimeKey AND FF.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN  DIMPRODUCT G
					  ON          B.ProductAlt_Key=G.ProductAlt_Key
					  AND         G.EffectiveFromTimeKey <= @TimeKey AND G.EffectiveToTimeKey >= @TimeKey
					  LEFT join  AdvCustNpaDetail H
					  ON          D.CustomerEntityId=H.CustomerEntityId
					  AND         H.EffectiveFromTimeKey <= @TimeKey AND H.EffectiveToTimeKey >= @TimeKey
					   LEFT join  AdvCustNpaDetail HH
					  ON          BB.CustomerEntityId=HH.CustomerEntityId
					  AND         HH.EffectiveFromTimeKey <= @TimeKey AND HH.EffectiveToTimeKey >= @TimeKey
					   LEFT JOIN  DIMASSETCLASS I
					  ON          A.AssetClassAtFraudAltKey=I.AssetClassAlt_Key
					  AND		I.EffectiveToTimeKey = 49999
					  LEFT JOIN  DIMASSETCLASS L
					  ON          H.Cust_AssetClassAlt_Key=L.AssetClassAlt_Key
					  AND         L.EffectiveToTimeKey = 49999
					    LEFT JOIN  DIMASSETCLASS LL
					  ON          HH.Cust_AssetClassAlt_Key=LL.AssetClassAlt_Key
					  AND         LL.EffectiveToTimeKey = 49999
					   LEFT JOIN  DIMASSETCLASS LK
					  ON          IK.FinalAssetClassAlt_key=LK.AssetClassAlt_Key
					  AND         LK.EffectiveToTimeKey = 49999
					  LEFT JOIN  DIMASSETCLASS LM
					  ON         DV.FinalAssetClassAlt_key=LM.AssetClassAlt_Key
					  AND         LM.EffectiveToTimeKey = 49999
					  Left join  #CustNPADetail Q
					  ON         Q.RefCustomerID=D.CustomerId

					  LEFT JOIN   DimAssetClass R
					  ON          Q.Cust_AssetClassAlt_Key=R.AssetClassAlt_Key
					  AND         R.EffectiveToTimeKey = 49999

					  LEFT JOIN   DimAssetClass S
					  ON          A.AssetClassAlt_KeyBeforeFruad=S.AssetClassAlt_Key
					  AND         S.EffectiveToTimeKey = 49999

					  WHERE BB.CustomerACID=@Account_id
					        AND BB.EffectiveFromTimeKey <= @TimeKey
                           AND BB.EffectiveToTimeKey >= @TimeKey

					UNION

					 SELECT 
                             --A.Account_ID
							(CASE	WHEN B.AccountEntityId is NOT NULL THEN B.AccountEntityId 
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
							,(CASE WHEN C.SourceName is not NULL THen c.SourceName 
							 WHEN CC.SourceName is not NULL THen cC.SourceName 
							  WHEN CD.SourceName is not NULL THen cd.SourceName 
							  ELSE CE.SourceName END)SourceName
							,(CASE WHEN E.BranchCode is not NULL THen E.BranchCode 
							 WHEN EE.BranchCode is not NULL THen EE.BranchCode 
							  WHEN ED.BranchCode is not NULL THen ED.BranchCode
							  ELSE EC.BranchCode END)BranchCode							
							 ,(CASE WHEN E.BranchName is not NULL THen E.BranchName 
							 WHEN EE.BranchName is not NULL THen EE.BranchName 
							  WHEN ED.BranchName is not NULL THen ED.BranchName
							  ELSE EC.BranchName END)BranchName
							,(CASE WHEN F.AcBuSegmentCode is not NULL THEN F.AcBuSegmentCode ELSE F.AcBuSegmentCode END)AcBuSegmentCode
							,(CASE WHEN  F.AcBuSegmentDescription is not NULL THEN F.AcBuSegmentDescription ELSE F.AcBuSegmentDescription END)AcBuSegmentDescription
							,(CASE WHEN D.UCIF_ID is not NULL THen D.UCIF_ID 
							 WHEN BB.RefCustomerID is not NULL THen BB.RefCustomerID
							  WHEN IJ.UcifId is not NULL THen IJ.UcifId
							  ELSE DV.UCIC_ID END)UCIF_ID 
							,(CASE WHEN D.CustomerName is NOT NULL THEN D.CustomerName
							WHEN BB.CustomerName is NOT NULL THEN BB.CustomerName
							WHEN IJ.IssuerName is NOT NULL THEN IJ.IssuerName
							 ELSE DV.CustomerName END) as CustomerName																
							,(CASE	WHEN J.Balance is not NULL THEN J.Balance
									WHEN JJ.Balance is not NULL THEN JJ.Balance
									WHEN IK.BookValueINR is not NULL THEN IK.BookValueINR
									ELSE DV.OsAmt END) as TOS				
							,(CASE	WHEN J.PrincipalBalance is not NULL THEN J.PrincipalBalance
									WHEN JJ.Balance is not NULL THEN JJ.Balance
									WHEN IK.MTMValueINR is not NULL THEN IK.MTMValueINR
									ELSE DV.pos END) as POS
							,A.AssetClassAlt_KeyBeforeFruad as AssetClassAlt_KeyBeforeFruad
							,(case when S.AssetClassName is null then 'STANDARD' else S.AssetClassName end) as AssetClassAtFraud
							--,(CASE WHEN cast(NPA_DateAtFraud as date) = '01/01/1900' THEN '' ELSE cast(NPA_DateAtFraud as date) END) as NPADateAtFraud
							,(CASE WHEN cast(A.NPADateBeforeFraud as date) = '01/01/1900' THEN '' ELSE Convert(Varchar(10),A.NPADateBeforeFraud,103) END) as NPADateAtFraud
							,RFA_ReportingByBank
							--,(CASE WHEN cast(RFA_DateReportingByBank as date) = '01/01/1900' THEN '' ELSE cast(RFA_DateReportingByBank as date) END) RFA_DateReportingByBank
							,(CASE WHEN cast(RFA_DateReportingByBank as date) = '01/01/1900' THEN '' ELSE convert(varchar(10),RFA_DateReportingByBank,103) END) RFA_DateReportingByBank
							,RFA_OtherBankAltKey
							--,(CASE WHEN cast(RFA_OtherBankDate as date) = '01/01/1900' THEN '' ELSE cast(RFA_OtherBankDate as date) END) RFA_OtherBankDate
							,(CASE WHEN cast(RFA_OtherBankDate as date) = '01/01/1900' THEN '' ELSE convert(varchar(10),RFA_OtherBankDate,103) END) RFA_OtherBankDate
							--,(CASE WHEN cast(FraudOccuranceDate as date) = '01/01/1900' THEN '' ELSE cast(FraudOccuranceDate as date) END) FraudOccuranceDate
							,(CASE WHEN cast(FraudOccuranceDate as date) = '01/01/1900' THEN '' ELSE convert(varchar(10),FraudOccuranceDate,103) END) FraudOccuranceDate
							--,(CASE WHEN cast(FraudDeclarationDate as date) = '01/01/1900' THEN '' ELSE cast(FraudDeclarationDate as date) END)FraudDeclarationDate
							,(CASE WHEN cast(FraudDeclarationDate as date) = '01/01/1900' THEN '' ELSE convert(Varchar(10),FraudDeclarationDate,103) END)FraudDeclarationDate
							,FraudNature
							,FraudArea
							,(CASE	WHEN L.AssetClassName is not NULL THEN L.AssetClassName 
									WHEN LL.AssetClassName is not NULL THEN LL.AssetClassName
									WHEN LK.AssetClassName is not NULL THEN LK.AssetClassName
									ELSE LM.AssetClassName END) as CurrentAssetClassName
							,(CASE	WHEN H.Cust_AssetClassAlt_Key is not NULL THEN H.Cust_AssetClassAlt_Key
									WHEN HH.Cust_AssetClassAlt_Key is not NULL THEN HH.Cust_AssetClassAlt_Key
									WHEN IK.FinalAssetClassAlt_Key is not NULL THEN IK.FinalAssetClassAlt_Key
									ELSE DV.FinalAssetClassAlt_KEy 
								    END)  as CurrentAssetClassAltKey
							--,cast(H.NPADt as date) as CurrentNPA_Date
							,(CASE	WHEN convert(varchar(10),H.NPADt,103) is not NULL THEN convert(varchar(10),H.NPADt,103)
									WHEN convert(varchar(10),HH.NPADt,103) is not NULL THEN convert(varchar(10),HH.NPADt,103)
									WHEN convert(varchar(10),IK.NPIDt,103) is not NULL THEN convert(varchar(10),IK.NPIDt,103)
									ELSE convert(varchar(10),DV.NPIDt,103) END)as CurrentNPA_Date
							,ProvPref as Provisionpreference
							,(CASE WHEN A.AuthorisationStatus is not NULL THEN A.AuthorisationStatus ELSE NULL END)  AuthorisationStatus
							,A.EffectiveFromTimeKey
							,A.EffectiveToTimeKey
							,A.CreatedBy
							,A.DateCreated as DateCreated
							,A.ModifiedBy
							,A.DateModified
							,A.ApprovedBy
							,A.DateApproved
							,A.FirstLevelApprovedBy as ApprovedByFirstLevel
							,A.FirstLevelDateApproved 
							,NULL AS ChangeFields
							,A.screenFlag
							 ,A.ReasonforRFAClassification 
							--,cast(A.DateofRemovalofRFAClassification as date) as DateofRemovalofRFAClassification
							,convert(varchar(10),A.DateofRemovalofRFAClassification,103) as DateofRemovalofRFAClassification 
							,A.ReasonforRemovalofRFAClassification
							--,cast(A.DateofRemovalofRFAClassificationReporting as date) as DateofRemovalofRFAClassificationReporting 
							,convert(Varchar(10),A.DateofRemovalofRFAClassificationReporting,103) as DateofRemovalofRFAClassificationReporting 
							,A.RFAReportedOtherBank
							,A.NameofBank
					       ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy  
                           ,IsNull(A.DateModified,A.DateCreated)as CrModDate  
                           ,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy  
                           ,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate  
                           ,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy  
                           ,ISNULL(A.DateApproved,A.DateModified) as ModAppDate		
						   , CASE WHEN  ISNULL(A.AuthorisationStatus,'A')='A' THEN 'Authorized'
								  WHEN  ISNULL(A.AuthorisationStatus,'A')='R' THEN 'Rejected'
								  WHEN  ISNULL(A.AuthorisationStatus,'A')='1A' THEN '2nd Level Authorization Pending'
								  WHEN  ISNULL(A.AuthorisationStatus,'A') IN ('NP','MP') THEN '1st Level Authorization Pending' ELSE NULL END AS AuthorisationStatus_1	
								 
	                  FROM Fraud_Details_Mod A 
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
					   RIGHT JOIN   InvestmentBasicDetail II
					  ON          A.RefCustomerAcid=II.InvID  
					  AND		  II.EffectiveFromTimeKey <= @TimeKey  AND II.EffectiveToTimeKey >= @TimeKey 
					   RIGHT JOIN   InvestmentIssuerDetail IJ
					  ON          IJ.IssuerID=II.RefIssuerID  
					  AND		  IJ.EffectiveFromTimeKey <= @TimeKey  AND IJ.EffectiveToTimeKey >= @TimeKey 
					  RIGHT JOIN		InvestmentFinancialDetail IK
					  ON			IK.RefInvID=II.InvID 
					  AND		  IK.EffectiveFromTimeKey <= @TimeKey  AND IK.EffectiveToTimeKey >= @TimeKey 
					  LEFT JOIN		curdat.DerivativeDetail DV
					  ON			A.RefCustomerAcid= DV.DerivativeRefNo
					  AND		  DV.EffectiveFromTimeKey <= @TimeKey  AND DV.EffectiveToTimeKey >= @TimeKey 
					  LEFT JOIN  DIMSOURCEDB C
					  ON          B.SourceAlt_Key=C.SourceAlt_Key 
					  AND         C.EffectiveFromTimeKey <= @TimeKey AND C.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMSOURCEDB CC
					  ON          BB.SourceAlt_Key=CC.SourceAlt_Key 
					  AND         CC.EffectiveFromTimeKey <= @TimeKey AND CC.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMSOURCEDB CD
					  ON          IJ.SourceAlt_Key=CD.SourceAlt_Key 
					  AND         CD.EffectiveFromTimeKey <= @TimeKey AND CD.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMSOURCEDB CE
					  ON          DV.SourceSystem=CE.SourceName 
					  AND         CE.EffectiveFromTimeKey <= @TimeKey AND CE.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN  CustomerBasicDetail D
					  ON          D.CustomerId=B.RefCustomerId
					  AND         D.EffectiveFromTimeKey <= @TimeKey AND D.EffectiveToTimeKey >= @TimeKey
					 
					 LEFT JOIN   DIMBRANCH E
					  ON          B.BranchCode=E.BranchCode
					  AND         E.EffectiveFromTimeKey <= @TimeKey AND E.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMBRANCH EE
					  ON          BB.BranchCode=EE.BranchCode 
					  AND         EE.EffectiveFromTimeKey <= @TimeKey AND EE.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMBRANCH ED
					  ON          IJ.BranchCode=ED.BranchCode 
					  AND         ED.EffectiveFromTimeKey <= @TimeKey AND ED.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMBRANCH EC
					  ON          DV.BranchCode=EC.BranchCode 
					  AND         EC.EffectiveFromTimeKey <= @TimeKey AND EC.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN  DimAcBuSegment  F
					  ON		  B.segmentcode=F.AcBuSegmentCode
					  AND         F.EffectiveFromTimeKey <= @TimeKey AND F.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN  DimAcBuSegment  FF
					  ON		  BB.segmentcode=FF.AcBuSegmentCode
					  AND         FF.EffectiveFromTimeKey <= @TimeKey AND FF.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN  DIMPRODUCT G
					  ON          B.ProductAlt_Key=G.ProductAlt_Key
					  AND         G.EffectiveFromTimeKey <= @TimeKey AND G.EffectiveToTimeKey >= @TimeKey
					  LEFT join  AdvCustNpaDetail H
					  ON          D.CustomerEntityId=H.CustomerEntityId
					  AND         H.EffectiveFromTimeKey <= @TimeKey AND H.EffectiveToTimeKey >= @TimeKey
					   LEFT join  AdvCustNpaDetail HH
					  ON          BB.CustomerEntityId=HH.CustomerEntityId
					  AND         HH.EffectiveFromTimeKey <= @TimeKey AND HH.EffectiveToTimeKey >= @TimeKey
					   LEFT JOIN  DIMASSETCLASS I
					  ON          A.AssetClassAtFraudAltKey=I.AssetClassAlt_Key
					  AND		I.EffectiveToTimeKey = 49999
					  LEFT JOIN  DIMASSETCLASS L
					  ON          H.Cust_AssetClassAlt_Key=L.AssetClassAlt_Key
					  AND         L.EffectiveToTimeKey = 49999
					    LEFT JOIN  DIMASSETCLASS LL
					  ON          HH.Cust_AssetClassAlt_Key=LL.AssetClassAlt_Key
					  AND         LL.EffectiveToTimeKey = 49999
					   LEFT JOIN  DIMASSETCLASS LK
					  ON          IK.FinalAssetClassAlt_key=LK.AssetClassAlt_Key
					  AND         LK.EffectiveToTimeKey = 49999
					  LEFT JOIN  DIMASSETCLASS LM
					  ON         DV.FinalAssetClassAlt_key=LM.AssetClassAlt_Key
					  AND         LM.EffectiveToTimeKey = 49999
					  Left join  #CustNPADetail Q
					  ON         Q.RefCustomerID=D.CustomerId

					  LEFT JOIN   DimAssetClass R
					  ON          Q.Cust_AssetClassAlt_Key=R.AssetClassAlt_Key
					  AND         R.EffectiveToTimeKey = 49999

					  LEFT JOIN   DimAssetClass S
					  ON          A.AssetClassAlt_KeyBeforeFruad=S.AssetClassAlt_Key
					  AND         S.EffectiveToTimeKey = 49999

					  WHERE II.InvID=@Account_id
					        AND II.EffectiveFromTimeKey <= @TimeKey
                           AND II.EffectiveToTimeKey >= @TimeKey

						   UNION

						   SELECT 
                             --A.Account_ID
							(CASE	WHEN B.AccountEntityId is NOT NULL THEN B.AccountEntityId 
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
							,(CASE WHEN C.SourceName is not NULL THen c.SourceName 
							 WHEN CC.SourceName is not NULL THen cC.SourceName 
							  WHEN CD.SourceName is not NULL THen cd.SourceName 
							  ELSE CE.SourceName END)SourceName
							,(CASE WHEN E.BranchCode is not NULL THen E.BranchCode 
							 WHEN EE.BranchCode is not NULL THen EE.BranchCode 
							  WHEN ED.BranchCode is not NULL THen ED.BranchCode
							  ELSE EC.BranchCode END)BranchCode							
							 ,(CASE WHEN E.BranchName is not NULL THen E.BranchName 
							 WHEN EE.BranchName is not NULL THen EE.BranchName 
							  WHEN ED.BranchName is not NULL THen ED.BranchName
							  ELSE EC.BranchName END)BranchName
							,(CASE WHEN F.AcBuSegmentCode is not NULL THEN F.AcBuSegmentCode ELSE F.AcBuSegmentCode END)AcBuSegmentCode
							,(CASE WHEN  F.AcBuSegmentDescription is not NULL THEN F.AcBuSegmentDescription ELSE F.AcBuSegmentDescription END)AcBuSegmentDescription
							,(CASE WHEN D.UCIF_ID is not NULL THen D.UCIF_ID 
							 WHEN BB.RefCustomerID is not NULL THen BB.RefCustomerID
							  WHEN IJ.UcifId is not NULL THen IJ.UcifId
							  ELSE DV.UCIC_ID END)UCIF_ID 
							,(CASE WHEN D.CustomerName is NOT NULL THEN D.CustomerName
							WHEN BB.CustomerName is NOT NULL THEN BB.CustomerName
							WHEN IJ.IssuerName is NOT NULL THEN IJ.IssuerName
							 ELSE DV.CustomerName END) as CustomerName																
							,(CASE	WHEN J.Balance is not NULL THEN J.Balance
									WHEN JJ.Balance is not NULL THEN JJ.Balance
									WHEN IK.BookValueINR is not NULL THEN IK.BookValueINR
									ELSE DV.OsAmt END) as TOS				
							,(CASE	WHEN J.PrincipalBalance is not NULL THEN J.PrincipalBalance
									WHEN JJ.Balance is not NULL THEN JJ.Balance
									WHEN IK.MTMValueINR is not NULL THEN IK.MTMValueINR
									ELSE DV.pos END) as POS
							,A.AssetClassAlt_KeyBeforeFruad as AssetClassAlt_KeyBeforeFruad
							,(case when S.AssetClassName is null then 'STANDARD' else S.AssetClassName end) as AssetClassAtFraud
							--,(CASE WHEN cast(NPA_DateAtFraud as date) = '01/01/1900' THEN '' ELSE cast(NPA_DateAtFraud as date) END) as NPADateAtFraud
							,(CASE WHEN cast(A.NPADateBeforeFraud as date) = '01/01/1900' THEN '' ELSE Convert(Varchar(10),A.NPADateBeforeFraud,103) END) as NPADateAtFraud
							,RFA_ReportingByBank
							--,(CASE WHEN cast(RFA_DateReportingByBank as date) = '01/01/1900' THEN '' ELSE cast(RFA_DateReportingByBank as date) END) RFA_DateReportingByBank
							,(CASE WHEN cast(RFA_DateReportingByBank as date) = '01/01/1900' THEN '' ELSE convert(varchar(10),RFA_DateReportingByBank,103) END) RFA_DateReportingByBank
							,RFA_OtherBankAltKey
							--,(CASE WHEN cast(RFA_OtherBankDate as date) = '01/01/1900' THEN '' ELSE cast(RFA_OtherBankDate as date) END) RFA_OtherBankDate
							,(CASE WHEN cast(RFA_OtherBankDate as date) = '01/01/1900' THEN '' ELSE convert(varchar(10),RFA_OtherBankDate,103) END) RFA_OtherBankDate
							--,(CASE WHEN cast(FraudOccuranceDate as date) = '01/01/1900' THEN '' ELSE cast(FraudOccuranceDate as date) END) FraudOccuranceDate
							,(CASE WHEN cast(FraudOccuranceDate as date) = '01/01/1900' THEN '' ELSE convert(varchar(10),FraudOccuranceDate,103) END) FraudOccuranceDate
							--,(CASE WHEN cast(FraudDeclarationDate as date) = '01/01/1900' THEN '' ELSE cast(FraudDeclarationDate as date) END)FraudDeclarationDate
							,(CASE WHEN cast(FraudDeclarationDate as date) = '01/01/1900' THEN '' ELSE convert(Varchar(10),FraudDeclarationDate,103) END)FraudDeclarationDate
							,FraudNature
							,FraudArea
							,(CASE	WHEN L.AssetClassName is not NULL THEN L.AssetClassName 
									WHEN LL.AssetClassName is not NULL THEN LL.AssetClassName
									WHEN LK.AssetClassName is not NULL THEN LK.AssetClassName
									ELSE LM.AssetClassName END) as CurrentAssetClassName
							,(CASE	WHEN H.Cust_AssetClassAlt_Key is not NULL THEN H.Cust_AssetClassAlt_Key
									WHEN HH.Cust_AssetClassAlt_Key is not NULL THEN HH.Cust_AssetClassAlt_Key
									WHEN IK.FinalAssetClassAlt_Key is not NULL THEN IK.FinalAssetClassAlt_Key
									ELSE DV.FinalAssetClassAlt_KEy 
								    END)  as CurrentAssetClassAltKey
							--,cast(H.NPADt as date) as CurrentNPA_Date
							,(CASE	WHEN convert(varchar(10),H.NPADt,103) is not NULL THEN convert(varchar(10),H.NPADt,103)
									WHEN convert(varchar(10),HH.NPADt,103) is not NULL THEN convert(varchar(10),HH.NPADt,103)
									WHEN convert(varchar(10),IK.NPIDt,103) is not NULL THEN convert(varchar(10),IK.NPIDt,103)
									ELSE convert(varchar(10),DV.NPIDt,103) END)as CurrentNPA_Date
							,ProvPref as Provisionpreference
							,(CASE WHEN A.AuthorisationStatus is not NULL THEN A.AuthorisationStatus ELSE NULL END)  AuthorisationStatus
							,A.EffectiveFromTimeKey
							,A.EffectiveToTimeKey
							,A.CreatedBy
							,A.DateCreated as DateCreated
							,A.ModifiedBy
							,A.DateModified
							,A.ApprovedBy
							,A.DateApproved
							,A.FirstLevelApprovedBy as ApprovedByFirstLevel
							,A.FirstLevelDateApproved 
							,NULL AS ChangeFields
							,A.screenFlag
							 ,A.ReasonforRFAClassification 
							--,cast(A.DateofRemovalofRFAClassification as date) as DateofRemovalofRFAClassification
							,convert(varchar(10),A.DateofRemovalofRFAClassification,103) as DateofRemovalofRFAClassification 
							,A.ReasonforRemovalofRFAClassification
							--,cast(A.DateofRemovalofRFAClassificationReporting as date) as DateofRemovalofRFAClassificationReporting 
							,convert(Varchar(10),A.DateofRemovalofRFAClassificationReporting,103) as DateofRemovalofRFAClassificationReporting 
							,A.RFAReportedOtherBank
							,A.NameofBank
					       ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy  
                           ,IsNull(A.DateModified,A.DateCreated)as CrModDate  
                           ,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy  
                           ,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate  
                           ,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy  
                           ,ISNULL(A.DateApproved,A.DateModified) as ModAppDate		
						   , CASE WHEN  ISNULL(A.AuthorisationStatus,'A')='A' THEN 'Authorized'
								  WHEN  ISNULL(A.AuthorisationStatus,'A')='R' THEN 'Rejected'
								  WHEN  ISNULL(A.AuthorisationStatus,'A')='1A' THEN '2nd Level Authorization Pending'
								  WHEN  ISNULL(A.AuthorisationStatus,'A') IN ('NP','MP') THEN '1st Level Authorization Pending' ELSE NULL END AS AuthorisationStatus_1	
								 
	                  FROM Fraud_Details_Mod A 
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
					  RIGHT JOIN		curdat.DerivativeDetail DV
					  ON			A.RefCustomerAcid= DV.DerivativeRefNo
					  AND		  DV.EffectiveFromTimeKey <= @TimeKey  AND DV.EffectiveToTimeKey >= @TimeKey 
					  LEFT JOIN  DIMSOURCEDB C
					  ON          B.SourceAlt_Key=C.SourceAlt_Key 
					  AND         C.EffectiveFromTimeKey <= @TimeKey AND C.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMSOURCEDB CC
					  ON          BB.SourceAlt_Key=CC.SourceAlt_Key 
					  AND         CC.EffectiveFromTimeKey <= @TimeKey AND CC.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMSOURCEDB CD
					  ON          IJ.SourceAlt_Key=CD.SourceAlt_Key 
					  AND         CD.EffectiveFromTimeKey <= @TimeKey AND CD.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMSOURCEDB CE
					  ON          DV.SourceSystem=CE.SourceName 
					  AND         CE.EffectiveFromTimeKey <= @TimeKey AND CE.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN  CustomerBasicDetail D
					  ON          D.CustomerId=B.RefCustomerId
					  AND         D.EffectiveFromTimeKey <= @TimeKey AND D.EffectiveToTimeKey >= @TimeKey
					 
					  LEFT JOIN   DIMBRANCH E
					  ON          B.BranchCode=E.BranchCode
					  AND         E.EffectiveFromTimeKey <= @TimeKey AND E.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMBRANCH EE
					  ON          BB.BranchCode=EE.BranchCode 
					  AND         EE.EffectiveFromTimeKey <= @TimeKey AND EE.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMBRANCH ED
					  ON          IJ.BranchCode=ED.BranchCode 
					  AND         ED.EffectiveFromTimeKey <= @TimeKey AND ED.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMBRANCH EC
					  ON          DV.BranchCode=EC.BranchCode 
					  AND         EC.EffectiveFromTimeKey <= @TimeKey AND EC.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN  DimAcBuSegment  F
					  ON		  B.segmentcode=F.AcBuSegmentCode
					  AND         F.EffectiveFromTimeKey <= @TimeKey AND F.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN  DimAcBuSegment  FF
					  ON		  BB.segmentcode=FF.AcBuSegmentCode
					  AND         FF.EffectiveFromTimeKey <= @TimeKey AND FF.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN  DIMPRODUCT G
					  ON          B.ProductAlt_Key=G.ProductAlt_Key
					  AND         G.EffectiveFromTimeKey <= @TimeKey AND G.EffectiveToTimeKey >= @TimeKey
					  LEFT join  AdvCustNpaDetail H
					  ON          D.CustomerEntityId=H.CustomerEntityId
					  AND         H.EffectiveFromTimeKey <= @TimeKey AND H.EffectiveToTimeKey >= @TimeKey
					   LEFT join  AdvCustNpaDetail HH
					  ON          BB.CustomerEntityId=HH.CustomerEntityId
					  AND         HH.EffectiveFromTimeKey <= @TimeKey AND HH.EffectiveToTimeKey >= @TimeKey
					   LEFT JOIN  DIMASSETCLASS I
					  ON          A.AssetClassAtFraudAltKey=I.AssetClassAlt_Key
					  AND		I.EffectiveToTimeKey = 49999
					  LEFT JOIN  DIMASSETCLASS L
					  ON          H.Cust_AssetClassAlt_Key=L.AssetClassAlt_Key
					  AND         L.EffectiveToTimeKey = 49999
					    LEFT JOIN  DIMASSETCLASS LL
					  ON          HH.Cust_AssetClassAlt_Key=LL.AssetClassAlt_Key
					  AND         LL.EffectiveToTimeKey = 49999
					   LEFT JOIN  DIMASSETCLASS LK
					  ON          IK.FinalAssetClassAlt_key=LK.AssetClassAlt_Key
					  AND         LK.EffectiveToTimeKey = 49999
					  LEFT JOIN  DIMASSETCLASS LM
					  ON         DV.FinalAssetClassAlt_key=LM.AssetClassAlt_Key
					  AND         LM.EffectiveToTimeKey = 49999
					  Left join  #CustNPADetail Q
					  ON         Q.RefCustomerID=D.CustomerId

					  LEFT JOIN   DimAssetClass R
					  ON          Q.Cust_AssetClassAlt_Key=R.AssetClassAlt_Key
					  AND         R.EffectiveToTimeKey = 49999

					  LEFT JOIN   DimAssetClass S
					  ON          A.AssetClassAlt_KeyBeforeFruad=S.AssetClassAlt_Key
					  AND         S.EffectiveToTimeKey = 49999

					  WHERE DV.DerivativeRefNo=@Account_id
					        AND DV.EffectiveFromTimeKey <= @TimeKey
                           AND DV.EffectiveToTimeKey >= @TimeKey
                 ) A 
                      
                 
                 GROUP BY   AccountEntityId
							,CustomerEntityId
							,RefCustomerACID
							,RefCustomerID
							,SourceName
							,BranchCode
							,BranchName
							,AcBuSegmentCode
							,AcBuSegmentDescription
							,UCIF_ID 							
							,CustomerName	
							,TOS				
							,POS
							,AssetClassAlt_KeyBeforeFruad
							,AssetClassAtFraud
							,NPADateAtFraud
							,RFA_ReportingByBank
							,RFA_DateReportingByBank
							,RFA_OtherBankAltKey
							,RFA_OtherBankDate
							,FraudOccuranceDate
							,FraudDeclarationDate
							,FraudNature
							,FraudArea
							,CurrentAssetClassName
							,CurrentAssetClassAltKey
							,CurrentNPA_Date
							,Provisionpreference
							,A.AuthorisationStatus
							,A.EffectiveFromTimeKey
							,A.EffectiveToTimeKey
							,A.CreatedBy
							,A.DateCreated
							,A.ModifiedBy
							,A.DateModified
							,A.ApprovedBy
							,A.DateApproved
							,ApprovedByFirstLevel
							,FirstLevelDateApproved 
							,A.ChangeFields
							,A.screenFlag
							,A.ReasonforRFAClassification 
							,A.DateofRemovalofRFAClassification 
							,A.ReasonforRemovalofRFAClassification 
							,A.DateofRemovalofRFAClassificationReporting 
							,A.RFAReportedOtherBank
							,A.NameofBank
							,A.CrModBy
							,A.CrModDate
							,A.CrAppBy
							,A.CrAppDate
							,A.ModAppBy
							,A.ModAppDate
							,A.AuthorisationStatus_1
							
							--A.changeFields

							  SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY RefCustomerACID) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'Fraud' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp_Fraud11 A
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner
				  Order By DataPointOwner.DateCreated Desc
							END

			ELSE 

			BEGIN
			PRINT 'Rasika'
                 SELECT		-- A.Account_ID
				           AccountEntityId
							,CustomerEntityId
							,RefCustomerACID
							,RefCustomerID
							,SourceName
							,BranchCode
							,BranchName
							,AcBuSegmentCode
							,AcBuSegmentDescription
							,UCIF_ID 							
							,CustomerName	
							,TOS				
							,POS
							,AssetClassAlt_KeyBeforeFruad
							,AssetClassAtFraud
							,NPADateAtFraud
							,RFA_ReportingByBank
							,RFA_DateReportingByBank
							,RFA_OtherBankAltKey
							,RFA_OtherBankDate
							,FraudOccuranceDate
							,FraudDeclarationDate
							,FraudNature
							,FraudArea
							,CurrentAssetClassName
							,CurrentAssetClassAltKey
							,CurrentNPA_Date
							,Provisionpreference
							,A.AuthorisationStatus
							,A.EffectiveFromTimeKey
							,A.EffectiveToTimeKey
							,A.CreatedBy
							,A.DateCreated
							,A.ModifiedBy
							,A.DateModified
							,A.ApprovedBy
							,A.DateApproved
							,ApprovedByFirstLevel
							,FirstLevelDateApproved 
							,A.ChangeFields
							,A.screenFlag
							,A.ReasonforRFAClassification 
							,A.DateofRemovalofRFAClassification 
							,A.ReasonforRemovalofRFAClassification 
							,A.DateofRemovalofRFAClassificationReporting 
							,A.RFAReportedOtherBank
							,A.NameofBank
							,A.CrModBy
							,A.CrModDate
							,A.CrAppBy
							,A.CrAppDate
							,A.ModAppBy
							,A.ModAppDate
							,A.AuthorisationStatus_1
							--,A.changeFields
                 INTO #temp_Fraud1
                 FROM 
                 (
                     SELECT  --A.Account_ID
					       --A.Account_ID
							 (CASE	WHEN B.AccountEntityId is NOT NULL THEN B.AccountEntityId 
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
							,(CASE WHEN C.SourceName is not NULL THen c.SourceName 
							 WHEN CC.SourceName is not NULL THen cC.SourceName 
							  WHEN CD.SourceName is not NULL THen cd.SourceName 
							  ELSE CE.SourceName END)SourceName
							,(CASE WHEN E.BranchCode is not NULL THen E.BranchCode 
							 WHEN EE.BranchCode is not NULL THen EE.BranchCode 
							  WHEN ED.BranchCode is not NULL THen ED.BranchCode
							  ELSE EC.BranchCode END)BranchCode							
							 ,(CASE WHEN E.BranchName is not NULL THen E.BranchName 
							 WHEN EE.BranchName is not NULL THen EE.BranchName 
							  WHEN ED.BranchName is not NULL THen ED.BranchName
							  ELSE EC.BranchName END)BranchName
							,(CASE WHEN F.AcBuSegmentCode is not NULL THEN F.AcBuSegmentCode ELSE F.AcBuSegmentCode END)AcBuSegmentCode
							,(CASE WHEN  F.AcBuSegmentDescription is not NULL THEN F.AcBuSegmentDescription ELSE F.AcBuSegmentDescription END)AcBuSegmentDescription
							,(CASE WHEN D.UCIF_ID is not NULL THen D.UCIF_ID 
							 WHEN BB.RefCustomerID is not NULL THen BB.RefCustomerID
							  WHEN IJ.UcifId is not NULL THen IJ.UcifId
							  ELSE DV.UCIC_ID END)UCIF_ID 
							,(CASE WHEN D.CustomerName is NOT NULL THEN D.CustomerName
							WHEN BB.CustomerName is NOT NULL THEN BB.CustomerName
							WHEN IJ.IssuerName is NOT NULL THEN IJ.IssuerName
							 ELSE DV.CustomerName END) as CustomerName																
							,(CASE	WHEN J.Balance is not NULL THEN J.Balance
									WHEN JJ.Balance is not NULL THEN JJ.Balance
									WHEN IK.BookValueINR is not NULL THEN IK.BookValueINR
									ELSE DV.OsAmt END) as TOS				
							,(CASE	WHEN J.PrincipalBalance is not NULL THEN J.PrincipalBalance
									WHEN JJ.Balance is not NULL THEN JJ.Balance
									WHEN IK.MTMValueINR is not NULL THEN IK.MTMValueINR
									ELSE DV.pos END) as POS
							,A.AssetClassAlt_KeyBeforeFruad as AssetClassAlt_KeyBeforeFruad
							,(case when S.AssetClassName is null then 'STANDARD' else S.AssetClassName end) as AssetClassAtFraud
							--,(CASE WHEN cast(NPA_DateAtFraud as date) = '01/01/1900' THEN '' ELSE cast(NPA_DateAtFraud as date) END) as NPADateAtFraud
							,(CASE WHEN cast(A.NPADateBeforeFraud as date) = '01/01/1900' THEN '' ELSE Convert(Varchar(10),A.NPADateBeforeFraud,103) END) as NPADateAtFraud
							,RFA_ReportingByBank
							--,(CASE WHEN cast(RFA_DateReportingByBank as date) = '01/01/1900' THEN '' ELSE cast(RFA_DateReportingByBank as date) END) RFA_DateReportingByBank
							,(CASE WHEN cast(RFA_DateReportingByBank as date) = '01/01/1900' THEN '' ELSE convert(varchar(10),RFA_DateReportingByBank,103) END) RFA_DateReportingByBank
							,RFA_OtherBankAltKey
							--,(CASE WHEN cast(RFA_OtherBankDate as date) = '01/01/1900' THEN '' ELSE cast(RFA_OtherBankDate as date) END) RFA_OtherBankDate
							,(CASE WHEN cast(RFA_OtherBankDate as date) = '01/01/1900' THEN '' ELSE convert(varchar(10),RFA_OtherBankDate,103) END) RFA_OtherBankDate
							--,(CASE WHEN cast(FraudOccuranceDate as date) = '01/01/1900' THEN '' ELSE cast(FraudOccuranceDate as date) END) FraudOccuranceDate
							,(CASE WHEN cast(FraudOccuranceDate as date) = '01/01/1900' THEN '' ELSE convert(varchar(10),FraudOccuranceDate,103) END) FraudOccuranceDate
							--,(CASE WHEN cast(FraudDeclarationDate as date) = '01/01/1900' THEN '' ELSE cast(FraudDeclarationDate as date) END)FraudDeclarationDate
							,(CASE WHEN cast(FraudDeclarationDate as date) = '01/01/1900' THEN '' ELSE convert(Varchar(10),FraudDeclarationDate,103) END)FraudDeclarationDate
							,FraudNature
							,FraudArea
							,(CASE	WHEN L.AssetClassName is not NULL THEN L.AssetClassName 
									WHEN LL.AssetClassName is not NULL THEN LL.AssetClassName
									WHEN LK.AssetClassName is not NULL THEN LK.AssetClassName
									ELSE LM.AssetClassName END) as CurrentAssetClassName
							,(CASE	WHEN H.Cust_AssetClassAlt_Key is not NULL THEN H.Cust_AssetClassAlt_Key
									WHEN HH.Cust_AssetClassAlt_Key is not NULL THEN HH.Cust_AssetClassAlt_Key
									WHEN IK.FinalAssetClassAlt_Key is not NULL THEN IK.FinalAssetClassAlt_Key
									ELSE DV.FinalAssetClassAlt_KEy 
								    END)  as CurrentAssetClassAltKey
							--,cast(H.NPADt as date) as CurrentNPA_Date
							,(CASE	WHEN convert(varchar(10),H.NPADt,103) is not NULL THEN convert(varchar(10),H.NPADt,103)
									WHEN convert(varchar(10),HH.NPADt,103) is not NULL THEN convert(varchar(10),HH.NPADt,103)
									WHEN convert(varchar(10),IK.NPIDt,103) is not NULL THEN convert(varchar(10),IK.NPIDt,103)
									ELSE convert(varchar(10),DV.NPIDt,103) END)as CurrentNPA_Date
							,ProvPref as Provisionpreference
							,(CASE WHEN A.AuthorisationStatus is not NULL THEN A.AuthorisationStatus ELSE NULL END)  AuthorisationStatus
							,A.EffectiveFromTimeKey
							,A.EffectiveToTimeKey
							,A.CreatedBy
							,A.DateCreated as DateCreated
							,A.ModifiedBy
							,A.DateModified
							,A.ApprovedBy
							,A.DateApproved
							,A.FirstLevelApprovedBy as ApprovedByFirstLevel
							,A.FirstLevelDateApproved 
							,NULL AS ChangeFields
							,A.screenFlag
							 ,A.ReasonforRFAClassification 
							--,cast(A.DateofRemovalofRFAClassification as date) as DateofRemovalofRFAClassification
							,convert(varchar(10),A.DateofRemovalofRFAClassification,103) as DateofRemovalofRFAClassification 
							,A.ReasonforRemovalofRFAClassification
							--,cast(A.DateofRemovalofRFAClassificationReporting as date) as DateofRemovalofRFAClassificationReporting 
							,convert(Varchar(10),A.DateofRemovalofRFAClassificationReporting,103) as DateofRemovalofRFAClassificationReporting 
							,A.RFAReportedOtherBank
							,A.NameofBank
					       ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy  
                           ,IsNull(A.DateModified,A.DateCreated)as CrModDate  
                           ,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy  
                           ,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate  
                           ,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy  
                           ,ISNULL(A.DateApproved,A.DateModified) as ModAppDate		
						   , CASE WHEN  ISNULL(A.AuthorisationStatus,'A')='A' THEN 'Authorized'
								  WHEN  ISNULL(A.AuthorisationStatus,'A')='R' THEN 'Rejected'
								  WHEN  ISNULL(A.AuthorisationStatus,'A')='1A' THEN '2nd Level Authorization Pending'
								  WHEN  ISNULL(A.AuthorisationStatus,'A') IN ('NP','MP') THEN '1st Level Authorization Pending' ELSE NULL END AS AuthorisationStatus_1	
								  --,a.changeFields
	                  FROM		Fraud_Details A 
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
					  LEFT JOIN  DIMSOURCEDB C
					  ON          B.SourceAlt_Key=C.SourceAlt_Key 
					  AND         C.EffectiveFromTimeKey <= @TimeKey AND C.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMSOURCEDB CC
					  ON          BB.SourceAlt_Key=CC.SourceAlt_Key 
					  AND         CC.EffectiveFromTimeKey <= @TimeKey AND CC.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMSOURCEDB CD
					  ON          IJ.SourceAlt_Key=CD.SourceAlt_Key 
					  AND         CD.EffectiveFromTimeKey <= @TimeKey AND CD.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMSOURCEDB CE
					  ON          DV.SourceSystem=CE.SourceName 
					  AND         CE.EffectiveFromTimeKey <= @TimeKey AND CE.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN  CustomerBasicDetail D
					  ON          D.CustomerId=B.RefCustomerId
					  AND         D.EffectiveFromTimeKey <= @TimeKey AND D.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN   DIMBRANCH E
					  ON          B.BranchCode=E.BranchCode
					  AND         E.EffectiveFromTimeKey <= @TimeKey AND E.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMBRANCH EE
					  ON          BB.BranchCode=EE.BranchCode 
					  AND         EE.EffectiveFromTimeKey <= @TimeKey AND EE.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMBRANCH ED
					  ON          IJ.BranchCode=ED.BranchCode 
					  AND         ED.EffectiveFromTimeKey <= @TimeKey AND ED.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMBRANCH EC
					  ON          DV.BranchCode=EC.BranchCode 
					  AND         EC.EffectiveFromTimeKey <= @TimeKey AND EC.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN  DimAcBuSegment  F
					  ON		  B.segmentcode=F.AcBuSegmentCode
					  AND         F.EffectiveFromTimeKey <= @TimeKey AND F.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN  DimAcBuSegment  FF
					  ON		  BB.segmentcode=FF.AcBuSegmentCode
					  AND         FF.EffectiveFromTimeKey <= @TimeKey AND FF.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN  DIMPRODUCT G
					  ON          B.ProductAlt_Key=G.ProductAlt_Key
					  AND         G.EffectiveFromTimeKey <= @TimeKey AND G.EffectiveToTimeKey >= @TimeKey
					  LEFT join  AdvCustNpaDetail H
					  ON          D.CustomerEntityId=H.CustomerEntityId
					  AND         H.EffectiveFromTimeKey <= @TimeKey AND H.EffectiveToTimeKey >= @TimeKey
					   LEFT join  AdvCustNpaDetail HH
					  ON          BB.CustomerEntityId=HH.CustomerEntityId
					  AND         HH.EffectiveFromTimeKey <= @TimeKey AND HH.EffectiveToTimeKey >= @TimeKey
					   LEFT JOIN  DIMASSETCLASS I
					  ON          A.AssetClassAtFraudAltKey=I.AssetClassAlt_Key
					  AND		I.EffectiveToTimeKey = 49999
					  LEFT JOIN  DIMASSETCLASS L
					  ON          H.Cust_AssetClassAlt_Key=L.AssetClassAlt_Key
					  AND         L.EffectiveToTimeKey = 49999
					    LEFT JOIN  DIMASSETCLASS LL
					  ON          HH.Cust_AssetClassAlt_Key=LL.AssetClassAlt_Key
					  AND         LL.EffectiveToTimeKey = 49999
					   LEFT JOIN  DIMASSETCLASS LK
					  ON          IK.FinalAssetClassAlt_key=LK.AssetClassAlt_Key
					  AND         LK.EffectiveToTimeKey = 49999
					  LEFT JOIN  DIMASSETCLASS LM
					  ON         DV.FinalAssetClassAlt_key=LM.AssetClassAlt_Key
					  AND         LM.EffectiveToTimeKey = 49999
					  Left join  #CustNPADetail Q
					  ON         Q.RefCustomerID=D.CustomerId

					  LEFT JOIN   DimAssetClass R
					  ON          Q.Cust_AssetClassAlt_Key=R.AssetClassAlt_Key
					  AND         R.EffectiveToTimeKey = 49999

					  LEFT JOIN   DimAssetClass S
					  ON          A.AssetClassAlt_KeyBeforeFruad=S.AssetClassAlt_Key
					  AND         S.EffectiveToTimeKey = 49999

					  WHERE B.CustomerACID=@Account_id
					        AND B.EffectiveFromTimeKey <= @TimeKey
                           AND B.EffectiveToTimeKey >= @TimeKey
						    AND ISNULL(A.AuthorisationStatus, 'A') = 'A'

                     UNION
					  SELECT 
                             --A.Account_ID
							 --A.Account_ID
							 (CASE	WHEN B.AccountEntityId is NOT NULL THEN B.AccountEntityId 
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
							,(CASE WHEN C.SourceName is not NULL THen c.SourceName 
							 WHEN CC.SourceName is not NULL THen cC.SourceName 
							  WHEN CD.SourceName is not NULL THen cd.SourceName 
							  ELSE CE.SourceName END)SourceName
							,(CASE WHEN E.BranchCode is not NULL THen E.BranchCode 
							 WHEN EE.BranchCode is not NULL THen EE.BranchCode 
							  WHEN ED.BranchCode is not NULL THen ED.BranchCode
							  ELSE EC.BranchCode END)BranchCode							
							 ,(CASE WHEN E.BranchName is not NULL THen E.BranchName 
							 WHEN EE.BranchName is not NULL THen EE.BranchName 
							  WHEN ED.BranchName is not NULL THen ED.BranchName
							  ELSE EC.BranchName END)BranchName
							,(CASE WHEN F.AcBuSegmentCode is not NULL THEN F.AcBuSegmentCode ELSE F.AcBuSegmentCode END)AcBuSegmentCode
							,(CASE WHEN  F.AcBuSegmentDescription is not NULL THEN F.AcBuSegmentDescription ELSE F.AcBuSegmentDescription END)AcBuSegmentDescription
							,(CASE WHEN D.UCIF_ID is not NULL THen D.UCIF_ID 
							 WHEN BB.RefCustomerID is not NULL THen BB.RefCustomerID
							  WHEN IJ.UcifId is not NULL THen IJ.UcifId
							  ELSE DV.UCIC_ID END)UCIF_ID 
							,(CASE WHEN D.CustomerName is NOT NULL THEN D.CustomerName
							WHEN BB.CustomerName is NOT NULL THEN BB.CustomerName
							WHEN IJ.IssuerName is NOT NULL THEN IJ.IssuerName
							 ELSE DV.CustomerName END) as CustomerName																
							,(CASE	WHEN J.Balance is not NULL THEN J.Balance
									WHEN JJ.Balance is not NULL THEN JJ.Balance
									WHEN IK.BookValueINR is not NULL THEN IK.BookValueINR
									ELSE DV.OsAmt END) as TOS				
							,(CASE	WHEN J.PrincipalBalance is not NULL THEN J.PrincipalBalance
									WHEN JJ.Balance is not NULL THEN JJ.Balance
									WHEN IK.MTMValueINR is not NULL THEN IK.MTMValueINR
									ELSE DV.pos END) as POS
							,A.AssetClassAlt_KeyBeforeFruad as AssetClassAlt_KeyBeforeFruad
							,(case when S.AssetClassName is null then 'STANDARD' else S.AssetClassName end) as AssetClassAtFraud
							--,(CASE WHEN cast(NPA_DateAtFraud as date) = '01/01/1900' THEN '' ELSE cast(NPA_DateAtFraud as date) END) as NPADateAtFraud
							,(CASE WHEN cast(A.NPADateBeforeFraud as date) = '01/01/1900' THEN '' ELSE Convert(Varchar(10),A.NPADateBeforeFraud,103) END) as NPADateAtFraud
							,RFA_ReportingByBank
							--,(CASE WHEN cast(RFA_DateReportingByBank as date) = '01/01/1900' THEN '' ELSE cast(RFA_DateReportingByBank as date) END) RFA_DateReportingByBank
							,(CASE WHEN cast(RFA_DateReportingByBank as date) = '01/01/1900' THEN '' ELSE convert(varchar(10),RFA_DateReportingByBank,103) END) RFA_DateReportingByBank
							,RFA_OtherBankAltKey
							--,(CASE WHEN cast(RFA_OtherBankDate as date) = '01/01/1900' THEN '' ELSE cast(RFA_OtherBankDate as date) END) RFA_OtherBankDate
							,(CASE WHEN cast(RFA_OtherBankDate as date) = '01/01/1900' THEN '' ELSE convert(varchar(10),RFA_OtherBankDate,103) END) RFA_OtherBankDate
							--,(CASE WHEN cast(FraudOccuranceDate as date) = '01/01/1900' THEN '' ELSE cast(FraudOccuranceDate as date) END) FraudOccuranceDate
							,(CASE WHEN cast(FraudOccuranceDate as date) = '01/01/1900' THEN '' ELSE convert(varchar(10),FraudOccuranceDate,103) END) FraudOccuranceDate
							--,(CASE WHEN cast(FraudDeclarationDate as date) = '01/01/1900' THEN '' ELSE cast(FraudDeclarationDate as date) END)FraudDeclarationDate
							,(CASE WHEN cast(FraudDeclarationDate as date) = '01/01/1900' THEN '' ELSE convert(Varchar(10),FraudDeclarationDate,103) END)FraudDeclarationDate
							,FraudNature
							,FraudArea
							,(CASE	WHEN L.AssetClassName is not NULL THEN L.AssetClassName 
									WHEN LL.AssetClassName is not NULL THEN LL.AssetClassName
									WHEN LK.AssetClassName is not NULL THEN LK.AssetClassName
									ELSE LM.AssetClassName END) as CurrentAssetClassName
							,(CASE	WHEN H.Cust_AssetClassAlt_Key is not NULL THEN H.Cust_AssetClassAlt_Key
									WHEN HH.Cust_AssetClassAlt_Key is not NULL THEN HH.Cust_AssetClassAlt_Key
									WHEN IK.FinalAssetClassAlt_Key is not NULL THEN IK.FinalAssetClassAlt_Key
									ELSE DV.FinalAssetClassAlt_KEy 
								    END)  as CurrentAssetClassAltKey
							--,cast(H.NPADt as date) as CurrentNPA_Date
							,(CASE	WHEN convert(varchar(10),H.NPADt,103) is not NULL THEN convert(varchar(10),H.NPADt,103)
									WHEN convert(varchar(10),HH.NPADt,103) is not NULL THEN convert(varchar(10),HH.NPADt,103)
									WHEN convert(varchar(10),IK.NPIDt,103) is not NULL THEN convert(varchar(10),IK.NPIDt,103)
									ELSE convert(varchar(10),DV.NPIDt,103) END)as CurrentNPA_Date
							,ProvPref as Provisionpreference
							,(CASE WHEN A.AuthorisationStatus is not NULL THEN A.AuthorisationStatus ELSE NULL END)  AuthorisationStatus
							,A.EffectiveFromTimeKey
							,A.EffectiveToTimeKey
							,A.CreatedBy
							,A.DateCreated as DateCreated
							,A.ModifiedBy
							,A.DateModified
							,A.ApprovedBy
							,A.DateApproved
							,A.FirstLevelApprovedBy as ApprovedByFirstLevel
							,A.FirstLevelDateApproved 
							,NULL AS ChangeFields
							,A.screenFlag
							 ,A.ReasonforRFAClassification 
							--,cast(A.DateofRemovalofRFAClassification as date) as DateofRemovalofRFAClassification
							,convert(varchar(10),A.DateofRemovalofRFAClassification,103) as DateofRemovalofRFAClassification 
							,A.ReasonforRemovalofRFAClassification
							--,cast(A.DateofRemovalofRFAClassificationReporting as date) as DateofRemovalofRFAClassificationReporting 
							,convert(Varchar(10),A.DateofRemovalofRFAClassificationReporting,103) as DateofRemovalofRFAClassificationReporting 
							,A.RFAReportedOtherBank
							,A.NameofBank
					       ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy  
                           ,IsNull(A.DateModified,A.DateCreated)as CrModDate  
                           ,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy  
                           ,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate  
                           ,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy  
                           ,ISNULL(A.DateApproved,A.DateModified) as ModAppDate		
						   , CASE WHEN  ISNULL(A.AuthorisationStatus,'A')='A' THEN 'Authorized'
								  WHEN  ISNULL(A.AuthorisationStatus,'A')='R' THEN 'Rejected'
								  WHEN  ISNULL(A.AuthorisationStatus,'A')='1A' THEN '2nd Level Authorization Pending'
								  WHEN  ISNULL(A.AuthorisationStatus,'A') IN ('NP','MP') THEN '1st Level Authorization Pending' ELSE NULL END AS AuthorisationStatus_1		
								  --,a.changeFields
      --               FROM Fraud_AWO A
					 --WHERE A.EffectiveFromTimeKey <= @TimeKey
      --               AND A.EffectiveToTimeKey >= @TimeKey
      --               AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
	                  FROM		  Fraud_Details_Mod A 
				      Right JOIN  AdvAcBasicDetail B
					  ON          A.RefCustomerAcid=B.CustomerACID  AND A.EffectiveFromTimeKey <= @TimeKey 
					  AND		A.EffectiveToTimeKey >= @TimeKey
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
					  LEFT JOIN  DIMSOURCEDB C
					  ON          B.SourceAlt_Key=C.SourceAlt_Key 
					  AND         C.EffectiveFromTimeKey <= @TimeKey AND C.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMSOURCEDB CC
					  ON          BB.SourceAlt_Key=CC.SourceAlt_Key 
					  AND         CC.EffectiveFromTimeKey <= @TimeKey AND CC.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMSOURCEDB CD
					  ON          IJ.SourceAlt_Key=CD.SourceAlt_Key 
					  AND         CD.EffectiveFromTimeKey <= @TimeKey AND CD.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMSOURCEDB CE
					  ON          DV.SourceSystem=CE.SourceName 
					  AND         CE.EffectiveFromTimeKey <= @TimeKey AND CE.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN  CustomerBasicDetail D
					  ON          D.CustomerId=B.RefCustomerId
					  AND         D.EffectiveFromTimeKey <= @TimeKey AND D.EffectiveToTimeKey >= @TimeKey
					    
					  LEFT JOIN   DIMBRANCH E
					  ON          B.BranchCode=E.BranchCode
					  AND         E.EffectiveFromTimeKey <= @TimeKey AND E.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMBRANCH EE
					  ON          BB.BranchCode=EE.BranchCode 
					  AND         EE.EffectiveFromTimeKey <= @TimeKey AND EE.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMBRANCH ED
					  ON          IJ.BranchCode=ED.BranchCode 
					  AND         ED.EffectiveFromTimeKey <= @TimeKey AND ED.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMBRANCH EC
					  ON          DV.BranchCode=EC.BranchCode 
					  AND         EC.EffectiveFromTimeKey <= @TimeKey AND EC.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN  DimAcBuSegment  F
					  ON		  B.segmentcode=F.AcBuSegmentCode
					  AND         F.EffectiveFromTimeKey <= @TimeKey AND F.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN  DimAcBuSegment  FF
					  ON		  BB.segmentcode=FF.AcBuSegmentCode
					  AND         FF.EffectiveFromTimeKey <= @TimeKey AND FF.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN  DIMPRODUCT G
					  ON          B.ProductAlt_Key=G.ProductAlt_Key
					  AND         G.EffectiveFromTimeKey <= @TimeKey AND G.EffectiveToTimeKey >= @TimeKey
					  LEFT join  AdvCustNpaDetail H
					  ON          D.CustomerEntityId=H.CustomerEntityId
					  AND         H.EffectiveFromTimeKey <= @TimeKey AND H.EffectiveToTimeKey >= @TimeKey
					   LEFT join  AdvCustNpaDetail HH
					  ON          BB.CustomerEntityId=HH.CustomerEntityId
					  AND         HH.EffectiveFromTimeKey <= @TimeKey AND HH.EffectiveToTimeKey >= @TimeKey
					   LEFT JOIN  DIMASSETCLASS I
					  ON          A.AssetClassAtFraudAltKey=I.AssetClassAlt_Key
					  AND		I.EffectiveToTimeKey = 49999
					  LEFT JOIN  DIMASSETCLASS L
					  ON          H.Cust_AssetClassAlt_Key=L.AssetClassAlt_Key
					  AND         L.EffectiveToTimeKey = 49999
					    LEFT JOIN  DIMASSETCLASS LL
					  ON          HH.Cust_AssetClassAlt_Key=LL.AssetClassAlt_Key
					  AND         LL.EffectiveToTimeKey = 49999
					   LEFT JOIN  DIMASSETCLASS LK
					  ON          IK.FinalAssetClassAlt_key=LK.AssetClassAlt_Key
					  AND         LK.EffectiveToTimeKey = 49999
					  LEFT JOIN  DIMASSETCLASS LM
					  ON         DV.FinalAssetClassAlt_key=LM.AssetClassAlt_Key
					  AND         LM.EffectiveToTimeKey = 49999
					  Left join  #CustNPADetail Q
					  ON         Q.RefCustomerID=D.CustomerId

					  LEFT JOIN   DimAssetClass R
					  ON          Q.Cust_AssetClassAlt_Key=R.AssetClassAlt_Key
					  AND         R.EffectiveToTimeKey = 49999

					  LEFT JOIN   DimAssetClass S
					  ON          A.AssetClassAlt_KeyBeforeFruad=S.AssetClassAlt_Key
					  AND         S.EffectiveToTimeKey = 49999

					  WHERE B.CustomerACID=@Account_id
					        AND B.EffectiveFromTimeKey <= @TimeKey
                           AND B.EffectiveToTimeKey >= @TimeKey
						   -- AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
						    AND ISNULL(B.AuthorisationStatus, 'A') IN  ('A')
                     --      AND A.EntityKey IN
                     --(
                     --    SELECT MAX(EntityKey)
                     --    FROM Fraud_Details_Mod
                     --    WHERE EffectiveFromTimeKey <= @TimeKey
                     --          AND EffectiveToTimeKey >= @TimeKey
                     --          AND ISNULL(AuthorisationStatus, 'A') IN ('NP', 'MP', 'DP','D1', 'RM','1A')
                     --    GROUP BY EntityKey
                     --)
                 ) A 
                      
                 
                 GROUP BY   AccountEntityId
							,CustomerEntityId
							,RefCustomerACID
							,RefCustomerID
							,SourceName
							,BranchCode
							,BranchName
							,AcBuSegmentCode
							,AcBuSegmentDescription
							,UCIF_ID 							
							,CustomerName	
							,TOS				
							,POS
							,AssetClassAlt_KeyBeforeFruad
							,AssetClassAtFraud
							,NPADateAtFraud
							,RFA_ReportingByBank
							,RFA_DateReportingByBank
							,RFA_OtherBankAltKey
							,RFA_OtherBankDate
							,FraudOccuranceDate
							,FraudDeclarationDate
							,FraudNature
							,FraudArea
							,CurrentAssetClassName
							,CurrentAssetClassAltKey
							,CurrentNPA_Date
							,Provisionpreference
							,A.AuthorisationStatus
							,A.EffectiveFromTimeKey
							,A.EffectiveToTimeKey
							,A.CreatedBy
							,A.DateCreated
							,A.ModifiedBy
							,A.DateModified
							,A.ApprovedBy
							,A.DateApproved
							,ApprovedByFirstLevel
							,FirstLevelDateApproved 
							,A.ChangeFields
							,A.screenFlag
							,A.ReasonforRFAClassification 
							,A.DateofRemovalofRFAClassification 
							,A.ReasonforRemovalofRFAClassification 
							,A.DateofRemovalofRFAClassificationReporting 
							,A.RFAReportedOtherBank
							,A.NameofBank
							,A.CrModBy
							,A.CrModDate
							,A.CrAppBy
							,A.CrAppDate
							,A.ModAppBy
							,A.ModAppDate
							,A.AuthorisationStatus_1
				            --,A.changeFields

                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY RefCustomerACID) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'Fraud' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp_Fraud1 A
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner
				  Order By DataPointOwner.DateCreated Desc
				  END
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
                 --      AND RowNumber <= (@PageNo * @PageSize);
             end
			 
 

			 /*  IT IS Used For GRID Search which are Pending for Authorization    */

			 IF(@OperationFlag in (16,17))

             BEGIN
			 IF OBJECT_ID('TempDB..#temp161') IS NOT NULL
                 DROP TABLE #temp161;
	print 'Prashant4'
                 SELECT		AccountEntityId
							,CustomerEntityId
							,RefCustomerACID
							,RefCustomerID
							,SourceName
							,BranchCode
							,BranchName
							,AcBuSegmentCode
							,AcBuSegmentDescription
							,UCIF_ID 							
							,CustomerName	
							,TOS				
							,POS
							,AssetClassAlt_KeyBeforeFruad
							,AssetClassAtFraud
							,NPADateAtFraud
							,RFA_ReportingByBank
							,RFA_DateReportingByBank
							,RFA_OtherBankAltKey
							,RFA_OtherBankDate
							,FraudOccuranceDate
							,FraudDeclarationDate
							,FraudNature
							,FraudArea
							,CurrentAssetClassName
							,CurrentAssetClassAltKey
							,CurrentNPA_Date
							,Provisionpreference
							,A.AuthorisationStatus
							,A.EffectiveFromTimeKey
							,A.EffectiveToTimeKey
							,A.CreatedBy
							,A.DateCreated
							,A.ModifiedBy
							,A.DateModified
							,A.ApprovedBy
							,A.DateApproved
							,ApprovedByFirstLevel
							,FirstLevelDateApproved 
							,A.ChangeFields
							,A.screenFlag
							,A.ReasonforRFAClassification 
							,A.DateofRemovalofRFAClassification 
							,A.ReasonforRemovalofRFAClassification 
							,A.DateofRemovalofRFAClassificationReporting 
							,A.RFAReportedOtherBank
							,A.NameofBank
							,A.CrModBy
							,A.CrModDate
							,A.CrAppBy
							,A.CrAppDate
							,A.ModAppBy
							,A.ModAppDate
							,A.AuthorisationStatus_1
							--,A.changeFields
                 INTO #temp161
                 FROM 
                 (
                   SELECT 
                            --A.Account_ID
							(CASE	WHEN B.AccountEntityId is NOT NULL THEN B.AccountEntityId 
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
							,(CASE WHEN C.SourceName is not NULL THen c.SourceName 
							 WHEN CC.SourceName is not NULL THen cC.SourceName 
							  WHEN CD.SourceName is not NULL THen cd.SourceName 
							  ELSE CE.SourceName END)SourceName
							,(CASE WHEN E.BranchCode is not NULL THen E.BranchCode 
							 WHEN EE.BranchCode is not NULL THen EE.BranchCode 
							  WHEN ED.BranchCode is not NULL THen ED.BranchCode
							  ELSE EC.BranchCode END)BranchCode							
							 ,(CASE WHEN E.BranchName is not NULL THen E.BranchName 
							 WHEN EE.BranchName is not NULL THen EE.BranchName 
							  WHEN ED.BranchName is not NULL THen ED.BranchName
							  ELSE EC.BranchName END)BranchName
							,(CASE WHEN F.AcBuSegmentCode is not NULL THEN F.AcBuSegmentCode ELSE F.AcBuSegmentCode END)AcBuSegmentCode
							,(CASE WHEN  F.AcBuSegmentDescription is not NULL THEN F.AcBuSegmentDescription ELSE F.AcBuSegmentDescription END)AcBuSegmentDescription
							,(CASE WHEN D.UCIF_ID is not NULL THen D.UCIF_ID 
							 WHEN BB.RefCustomerID is not NULL THen BB.RefCustomerID
							  WHEN IJ.UcifId is not NULL THen IJ.UcifId
							  ELSE DV.UCIC_ID END)UCIF_ID
							,(CASE WHEN D.CustomerName is NOT NULL THEN D.CustomerName
							WHEN BB.CustomerName is NOT NULL THEN BB.CustomerName
							WHEN IJ.IssuerName is NOT NULL THEN IJ.IssuerName
							 ELSE DV.CustomerName END) as CustomerName																
							,(CASE	WHEN J.Balance is not NULL THEN J.Balance
									WHEN JJ.Balance is not NULL THEN JJ.Balance
									WHEN IK.BookValueINR is not NULL THEN IK.BookValueINR
									ELSE DV.OsAmt END) as TOS				
							,(CASE	WHEN J.PrincipalBalance is not NULL THEN J.PrincipalBalance
									WHEN JJ.Balance is not NULL THEN JJ.Balance
									WHEN IK.MTMValueINR is not NULL THEN IK.MTMValueINR
									ELSE DV.pos END) as POS
							,A.AssetClassAlt_KeyBeforeFruad as AssetClassAlt_KeyBeforeFruad
							,(case when S.AssetClassName is null then 'STANDARD' else S.AssetClassName end) as AssetClassAtFraud
							--,(CASE WHEN cast(NPA_DateAtFraud as date) = '01/01/1900' THEN '' ELSE cast(NPA_DateAtFraud as date) END) as NPADateAtFraud
							,(CASE WHEN cast(A.NPADateBeforeFraud as date) = '01/01/1900' THEN '' ELSE Convert(Varchar(10),A.NPADateBeforeFraud,103) END) as NPADateAtFraud
							,RFA_ReportingByBank
							--,(CASE WHEN cast(RFA_DateReportingByBank as date) = '01/01/1900' THEN '' ELSE cast(RFA_DateReportingByBank as date) END) RFA_DateReportingByBank
							,(CASE WHEN cast(RFA_DateReportingByBank as date) = '01/01/1900' THEN '' ELSE convert(varchar(10),RFA_DateReportingByBank,103) END) RFA_DateReportingByBank
							,RFA_OtherBankAltKey
							--,(CASE WHEN cast(RFA_OtherBankDate as date) = '01/01/1900' THEN '' ELSE cast(RFA_OtherBankDate as date) END) RFA_OtherBankDate
							,(CASE WHEN cast(RFA_OtherBankDate as date) = '01/01/1900' THEN '' ELSE convert(varchar(10),RFA_OtherBankDate,103) END) RFA_OtherBankDate
							--,(CASE WHEN cast(FraudOccuranceDate as date) = '01/01/1900' THEN '' ELSE cast(FraudOccuranceDate as date) END) FraudOccuranceDate
							,(CASE WHEN cast(FraudOccuranceDate as date) = '01/01/1900' THEN '' ELSE convert(varchar(10),FraudOccuranceDate,103) END) FraudOccuranceDate
							--,(CASE WHEN cast(FraudDeclarationDate as date) = '01/01/1900' THEN '' ELSE cast(FraudDeclarationDate as date) END)FraudDeclarationDate
							,(CASE WHEN cast(FraudDeclarationDate as date) = '01/01/1900' THEN '' ELSE convert(Varchar(10),FraudDeclarationDate,103) END)FraudDeclarationDate
							,FraudNature
							,FraudArea
							,(CASE	WHEN L.AssetClassName is not NULL THEN L.AssetClassName 
									WHEN LL.AssetClassName is not NULL THEN LL.AssetClassName
									WHEN LK.AssetClassName is not NULL THEN LK.AssetClassName
									ELSE LM.AssetClassName END) as CurrentAssetClassName
							,(CASE	WHEN H.Cust_AssetClassAlt_Key is not NULL THEN H.Cust_AssetClassAlt_Key
									WHEN HH.Cust_AssetClassAlt_Key is not NULL THEN HH.Cust_AssetClassAlt_Key
									WHEN IK.FinalAssetClassAlt_Key is not NULL THEN IK.FinalAssetClassAlt_Key
									ELSE DV.FinalAssetClassAlt_KEy 
								    END)  as CurrentAssetClassAltKey
							--,cast(H.NPADt as date) as CurrentNPA_Date
							,(CASE	WHEN convert(varchar(10),H.NPADt,103) is not NULL THEN convert(varchar(10),H.NPADt,103)
									WHEN convert(varchar(10),HH.NPADt,103) is not NULL THEN convert(varchar(10),HH.NPADt,103)
									WHEN convert(varchar(10),IK.NPIDt,103) is not NULL THEN convert(varchar(10),IK.NPIDt,103)
									ELSE convert(varchar(10),DV.NPIDt,103) END)as CurrentNPA_Date
							,ProvPref as Provisionpreference
							,(CASE WHEN A.AuthorisationStatus is not NULL THEN A.AuthorisationStatus ELSE NULL END)  AuthorisationStatus
							,A.EffectiveFromTimeKey
							,A.EffectiveToTimeKey
							,A.CreatedBy
							,A.DateCreated as DateCreated
							,A.ModifiedBy
							,A.DateModified
							,A.ApprovedBy
							,A.DateApproved
							,A.FirstLevelApprovedBy as ApprovedByFirstLevel
							,A.FirstLevelDateApproved 
							,NULL AS ChangeFields
							,A.screenFlag
							 ,A.ReasonforRFAClassification 
							--,cast(A.DateofRemovalofRFAClassification as date) as DateofRemovalofRFAClassification
							,convert(varchar(10),A.DateofRemovalofRFAClassification,103) as DateofRemovalofRFAClassification 
							,A.ReasonforRemovalofRFAClassification
							--,cast(A.DateofRemovalofRFAClassificationReporting as date) as DateofRemovalofRFAClassificationReporting 
							,convert(Varchar(10),A.DateofRemovalofRFAClassificationReporting,103) as DateofRemovalofRFAClassificationReporting 
							,A.RFAReportedOtherBank
							,A.NameofBank
					       ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy  
                           ,IsNull(A.DateModified,A.DateCreated)as CrModDate  
                           ,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy  
                           ,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate  
                           ,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy  
                           ,ISNULL(A.DateApproved,A.DateModified) as ModAppDate		
						   , CASE WHEN  ISNULL(A.AuthorisationStatus,'A')='A' THEN 'Authorized'
								  WHEN  ISNULL(A.AuthorisationStatus,'A')='R' THEN 'Rejected'
								  WHEN  ISNULL(A.AuthorisationStatus,'A')='1A' THEN '2nd Level Authorization Pending'
								  WHEN  ISNULL(A.AuthorisationStatus,'A') IN ('NP','MP') THEN '1st Level Authorization Pending' ELSE NULL END AS AuthorisationStatus_1		
								  --,a.changeFields
      --               FROM Fraud_AWO A
					 --WHERE A.EffectiveFromTimeKey <= @TimeKey
      --               AND A.EffectiveToTimeKey >= @TimeKey
      --               AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
	                  FROM Fraud_Details_Mod A 
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
					  LEFT JOIN  DIMSOURCEDB C
					  ON          B.SourceAlt_Key=C.SourceAlt_Key 
					  AND         C.EffectiveFromTimeKey <= @TimeKey AND C.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMSOURCEDB CC
					  ON          BB.SourceAlt_Key=CC.SourceAlt_Key 
					  AND         CC.EffectiveFromTimeKey <= @TimeKey AND CC.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMSOURCEDB CD
					  ON          IJ.SourceAlt_Key=CD.SourceAlt_Key 
					  AND         CD.EffectiveFromTimeKey <= @TimeKey AND CD.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMSOURCEDB CE
					  ON          DV.SourceSystem=CE.SourceName 
					  AND         CE.EffectiveFromTimeKey <= @TimeKey AND CE.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN  CustomerBasicDetail D
					  ON          D.CustomerId=B.RefCustomerId
					  AND         D.EffectiveFromTimeKey <= @TimeKey AND D.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN   DIMBRANCH E
					  ON          B.BranchCode=E.BranchCode
					  AND         E.EffectiveFromTimeKey <= @TimeKey AND E.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMBRANCH EE
					  ON          BB.BranchCode=EE.BranchCode 
					  AND         EE.EffectiveFromTimeKey <= @TimeKey AND EE.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMBRANCH ED
					  ON          IJ.BranchCode=ED.BranchCode 
					  AND         ED.EffectiveFromTimeKey <= @TimeKey AND ED.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMBRANCH EC
					  ON          DV.BranchCode=EC.BranchCode 
					  AND         EC.EffectiveFromTimeKey <= @TimeKey AND EC.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN  DimAcBuSegment  F
					  ON		  B.segmentcode=F.AcBuSegmentCode
					  AND         F.EffectiveFromTimeKey <= @TimeKey AND F.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN  DimAcBuSegment  FF
					  ON		  BB.segmentcode=FF.AcBuSegmentCode
					  AND         FF.EffectiveFromTimeKey <= @TimeKey AND FF.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN  DIMPRODUCT G
					  ON          B.ProductAlt_Key=G.ProductAlt_Key
					  AND         G.EffectiveFromTimeKey <= @TimeKey AND G.EffectiveToTimeKey >= @TimeKey
					  LEFT join  AdvCustNpaDetail H
					  ON          D.CustomerEntityId=H.CustomerEntityId
					  AND         H.EffectiveFromTimeKey <= @TimeKey AND H.EffectiveToTimeKey >= @TimeKey
					   LEFT join  AdvCustNpaDetail HH
					  ON          BB.CustomerEntityId=HH.CustomerEntityId
					  AND         HH.EffectiveFromTimeKey <= @TimeKey AND HH.EffectiveToTimeKey >= @TimeKey
					   LEFT JOIN  DIMASSETCLASS I
					  ON          A.AssetClassAtFraudAltKey=I.AssetClassAlt_Key
					  AND		I.EffectiveToTimeKey = 49999
					  LEFT JOIN  DIMASSETCLASS L
					  ON          H.Cust_AssetClassAlt_Key=L.AssetClassAlt_Key
					  AND         L.EffectiveToTimeKey = 49999
					    LEFT JOIN  DIMASSETCLASS LL
					  ON          HH.Cust_AssetClassAlt_Key=LL.AssetClassAlt_Key
					  AND         LL.EffectiveToTimeKey = 49999
					   LEFT JOIN  DIMASSETCLASS LK
					  ON          IK.FinalAssetClassAlt_key=LK.AssetClassAlt_Key
					  AND         LK.EffectiveToTimeKey = 49999
					  LEFT JOIN  DIMASSETCLASS LM
					  ON         DV.FinalAssetClassAlt_key=LM.AssetClassAlt_Key
					  AND         LM.EffectiveToTimeKey = 49999
					  Left join  #CustNPADetail Q
					  ON         Q.RefCustomerID=D.CustomerId

					  LEFT JOIN   DimAssetClass R
					  ON          Q.Cust_AssetClassAlt_Key=R.AssetClassAlt_Key
					  AND         R.EffectiveToTimeKey = 49999

					  LEFT JOIN   DimAssetClass S
					  ON          A.AssetClassAlt_KeyBeforeFruad=S.AssetClassAlt_Key
					  AND         S.EffectiveToTimeKey = 49999

					  WHERE B.CustomerACID=@Account_id
					        AND B.EffectiveFromTimeKey <= @TimeKey
                           AND B.EffectiveToTimeKey >= @TimeKey
						   -- AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
						    AND ISNULL(A.AuthorisationStatus, 'A') IN  ('NP', 'MP')
                           AND A.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM Fraud_Details_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')
                         GROUP BY EntityKey
                     )
                 ) A 
                      
                 
                 GROUP BY	AccountEntityId
							,CustomerEntityId
							,RefCustomerACID
							,RefCustomerID
							,SourceName
							,BranchCode
							,BranchName
							,AcBuSegmentCode
							,AcBuSegmentDescription
							,UCIF_ID 							
							,CustomerName	
							,TOS				
							,POS
							,AssetClassAlt_KeyBeforeFruad
							,AssetClassAtFraud
							,NPADateAtFraud
							,RFA_ReportingByBank
							,RFA_DateReportingByBank
							,RFA_OtherBankAltKey
							,RFA_OtherBankDate
							,FraudOccuranceDate
							,FraudDeclarationDate
							,FraudNature
							,FraudArea
							,CurrentAssetClassName
							,CurrentAssetClassAltKey
							,CurrentNPA_Date
							,Provisionpreference
							,A.AuthorisationStatus
							,A.EffectiveFromTimeKey
							,A.EffectiveToTimeKey
							,A.CreatedBy
							,A.DateCreated
							,A.ModifiedBy
							,A.DateModified
							,A.ApprovedBy
							,A.DateApproved
							,ApprovedByFirstLevel
							,FirstLevelDateApproved 
							,A.ChangeFields
							,A.screenFlag
							,A.ReasonforRFAClassification 
							,A.DateofRemovalofRFAClassification 
							,A.ReasonforRemovalofRFAClassification 
							,A.DateofRemovalofRFAClassificationReporting 
							,A.RFAReportedOtherBank
							,A.NameofBank
							,A.CrModBy
							,A.CrModDate
							,A.CrAppBy
							,A.CrAppDate
							,A.ModAppBy
							,A.ModAppDate
							,A.AuthorisationStatus_1
							--,A.changeFields
                 SELECT *
                 FROM
   (
                     SELECT ROW_NUMBER() OVER(ORDER BY RefCustomerACID) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'Fraud' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp161 A
						 
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner
				  Order By DataPointOwner.DateCreated Desc
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
                 --      AND RowNumber <= (@PageNo * @PageSize)

   END;

   

    IF (@OperationFlag =20)
             BEGIN

    IF OBJECT_ID('TempDB..#temp201') IS NOT NULL
                 DROP TABLE #temp201;
	print 'Prashant5'
                 SELECT		AccountEntityId
							,CustomerEntityId
							,RefCustomerACID
							,RefCustomerID
							,SourceName
							,BranchCode
							,BranchName
							,AcBuSegmentCode
							,AcBuSegmentDescription
							,UCIF_ID 							
							,CustomerName	
							,TOS				
							,POS
							,AssetClassAlt_KeyBeforeFruad
							,AssetClassAtFraud
							,NPADateAtFraud
							,RFA_ReportingByBank
							,RFA_DateReportingByBank
							,RFA_OtherBankAltKey
							,RFA_OtherBankDate
							,FraudOccuranceDate
							,FraudDeclarationDate
							,FraudNature
							,FraudArea
							,CurrentAssetClassName
							,CurrentAssetClassAltKey
							,CurrentNPA_Date
							,Provisionpreference
							,A.AuthorisationStatus
							,A.EffectiveFromTimeKey
							,A.EffectiveToTimeKey
							,A.CreatedBy
							,A.DateCreated
							,A.ModifiedBy
							,A.DateModified
							,A.ApprovedBy
							,A.DateApproved
							,ApprovedByFirstLevel
							,FirstLevelDateApproved 
							,A.ChangeFields
							,A.screenFlag
							,A.ReasonforRFAClassification 
							,A.DateofRemovalofRFAClassification 
							,A.ReasonforRemovalofRFAClassification 
							,A.DateofRemovalofRFAClassificationReporting 
							,A.RFAReportedOtherBank
							,A.NameofBank
							,A.CrModBy
							,A.CrModDate
							,A.CrAppBy
							,A.CrAppDate
							,A.ModAppBy
							,A.ModAppDate
							,A.AuthorisationStatus_1
							--,A.changeFields
                 INTO #temp201
                 FROM 
                 (
                    SELECT 
                             --A.Account_ID
							 (CASE	WHEN B.AccountEntityId is NOT NULL THEN B.AccountEntityId 
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
							,(CASE WHEN C.SourceName is not NULL THen c.SourceName 
							 WHEN CC.SourceName is not NULL THen cC.SourceName 
							  WHEN CD.SourceName is not NULL THen cd.SourceName 
							  ELSE CE.SourceName END)SourceName
							,(CASE WHEN E.BranchCode is not NULL THen E.BranchCode 
							 WHEN EE.BranchCode is not NULL THen EE.BranchCode 
							  WHEN ED.BranchCode is not NULL THen ED.BranchCode
							  ELSE EC.BranchCode END)BranchCode							
							 ,(CASE WHEN E.BranchName is not NULL THen E.BranchName 
							 WHEN EE.BranchName is not NULL THen EE.BranchName 
							  WHEN ED.BranchName is not NULL THen ED.BranchName
							  ELSE EC.BranchName END)BranchName
							,(CASE WHEN F.AcBuSegmentCode is not NULL THEN F.AcBuSegmentCode ELSE F.AcBuSegmentCode END)AcBuSegmentCode
							,(CASE WHEN  F.AcBuSegmentDescription is not NULL THEN F.AcBuSegmentDescription ELSE F.AcBuSegmentDescription END)AcBuSegmentDescription
							,(CASE WHEN D.UCIF_ID is not NULL THen D.UCIF_ID 
							 WHEN BB.RefCustomerID is not NULL THen BB.RefCustomerID
							  WHEN IJ.UcifId is not NULL THen IJ.UcifId
							  ELSE DV.UCIC_ID END)UCIF_ID
							,(CASE WHEN D.CustomerName is NOT NULL THEN D.CustomerName
							WHEN BB.CustomerName is NOT NULL THEN BB.CustomerName
							WHEN IJ.IssuerName is NOT NULL THEN IJ.IssuerName
							 ELSE DV.CustomerName END) as CustomerName																
							,(CASE	WHEN J.Balance is not NULL THEN J.Balance
									WHEN JJ.Balance is not NULL THEN JJ.Balance
									WHEN IK.BookValueINR is not NULL THEN IK.BookValueINR
									ELSE DV.OsAmt END) as TOS				
							,(CASE	WHEN J.PrincipalBalance is not NULL THEN J.PrincipalBalance
									WHEN JJ.Balance is not NULL THEN JJ.Balance
									WHEN IK.MTMValueINR is not NULL THEN IK.MTMValueINR
									ELSE DV.pos END) as POS
							,A.AssetClassAlt_KeyBeforeFruad as AssetClassAlt_KeyBeforeFruad
							,(case when S.AssetClassName is null then 'STANDARD' else S.AssetClassName end) as AssetClassAtFraud
							--,(CASE WHEN cast(NPA_DateAtFraud as date) = '01/01/1900' THEN '' ELSE cast(NPA_DateAtFraud as date) END) as NPADateAtFraud
							,(CASE WHEN cast(A.NPADateBeforeFraud as date) = '01/01/1900' THEN '' ELSE Convert(Varchar(10),A.NPADateBeforeFraud,103) END) as NPADateAtFraud
							,RFA_ReportingByBank
							--,(CASE WHEN cast(RFA_DateReportingByBank as date) = '01/01/1900' THEN '' ELSE cast(RFA_DateReportingByBank as date) END) RFA_DateReportingByBank
							,(CASE WHEN cast(RFA_DateReportingByBank as date) = '01/01/1900' THEN '' ELSE convert(varchar(10),RFA_DateReportingByBank,103) END) RFA_DateReportingByBank
							,RFA_OtherBankAltKey
							--,(CASE WHEN cast(RFA_OtherBankDate as date) = '01/01/1900' THEN '' ELSE cast(RFA_OtherBankDate as date) END) RFA_OtherBankDate
							,(CASE WHEN cast(RFA_OtherBankDate as date) = '01/01/1900' THEN '' ELSE convert(varchar(10),RFA_OtherBankDate,103) END) RFA_OtherBankDate
							--,(CASE WHEN cast(FraudOccuranceDate as date) = '01/01/1900' THEN '' ELSE cast(FraudOccuranceDate as date) END) FraudOccuranceDate
							,(CASE WHEN cast(FraudOccuranceDate as date) = '01/01/1900' THEN '' ELSE convert(varchar(10),FraudOccuranceDate,103) END) FraudOccuranceDate
							--,(CASE WHEN cast(FraudDeclarationDate as date) = '01/01/1900' THEN '' ELSE cast(FraudDeclarationDate as date) END)FraudDeclarationDate
							,(CASE WHEN cast(FraudDeclarationDate as date) = '01/01/1900' THEN '' ELSE convert(Varchar(10),FraudDeclarationDate,103) END)FraudDeclarationDate
							,FraudNature
							,FraudArea
							,(CASE	WHEN L.AssetClassName is not NULL THEN L.AssetClassName 
									WHEN LL.AssetClassName is not NULL THEN LL.AssetClassName
									WHEN LK.AssetClassName is not NULL THEN LK.AssetClassName
									ELSE LM.AssetClassName END) as CurrentAssetClassName
							,(CASE	WHEN H.Cust_AssetClassAlt_Key is not NULL THEN H.Cust_AssetClassAlt_Key
									WHEN HH.Cust_AssetClassAlt_Key is not NULL THEN HH.Cust_AssetClassAlt_Key
									WHEN IK.FinalAssetClassAlt_Key is not NULL THEN IK.FinalAssetClassAlt_Key
									ELSE DV.FinalAssetClassAlt_KEy 
								    END)  as CurrentAssetClassAltKey
							--,cast(H.NPADt as date) as CurrentNPA_Date
							,(CASE	WHEN convert(varchar(10),H.NPADt,103) is not NULL THEN convert(varchar(10),H.NPADt,103)
									WHEN convert(varchar(10),HH.NPADt,103) is not NULL THEN convert(varchar(10),HH.NPADt,103)
									WHEN convert(varchar(10),IK.NPIDt,103) is not NULL THEN convert(varchar(10),IK.NPIDt,103)
									ELSE convert(varchar(10),DV.NPIDt,103) END)as CurrentNPA_Date
							,ProvPref as Provisionpreference
							,(CASE WHEN A.AuthorisationStatus is not NULL THEN A.AuthorisationStatus ELSE NULL END)  AuthorisationStatus
							,A.EffectiveFromTimeKey
							,A.EffectiveToTimeKey
							,A.CreatedBy
							,A.DateCreated as DateCreated
							,A.ModifiedBy
							,A.DateModified
							,A.ApprovedBy
							,A.DateApproved
							,A.FirstLevelApprovedBy as ApprovedByFirstLevel
							,A.FirstLevelDateApproved 
							,NULL AS ChangeFields
							,A.screenFlag
							 ,A.ReasonforRFAClassification 
							--,cast(A.DateofRemovalofRFAClassification as date) as DateofRemovalofRFAClassification
							,convert(varchar(10),A.DateofRemovalofRFAClassification,103) as DateofRemovalofRFAClassification 
							,A.ReasonforRemovalofRFAClassification
							--,cast(A.DateofRemovalofRFAClassificationReporting as date) as DateofRemovalofRFAClassificationReporting 
							,convert(Varchar(10),A.DateofRemovalofRFAClassificationReporting,103) as DateofRemovalofRFAClassificationReporting 
							,A.RFAReportedOtherBank
							,A.NameofBank
					       ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy  
                           ,IsNull(A.DateModified,A.DateCreated)as CrModDate  
                           ,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy  
                           ,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate  
                           ,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy  
                           ,ISNULL(A.DateApproved,A.DateModified) as ModAppDate		
						   , CASE WHEN  ISNULL(A.AuthorisationStatus,'A')='A' THEN 'Authorized'
								  WHEN  ISNULL(A.AuthorisationStatus,'A')='R' THEN 'Rejected'
								  WHEN  ISNULL(A.AuthorisationStatus,'A')='1A' THEN '2nd Level Authorization Pending'
								  WHEN  ISNULL(A.AuthorisationStatus,'A') IN ('NP','MP') THEN '1st Level Authorization Pending' ELSE NULL END AS AuthorisationStatus_1	
								  --,a.changeFields
      --               FROM Fraud_AWO A
					 --WHERE A.EffectiveFromTimeKey <= @TimeKey
      --               AND A.EffectiveToTimeKey >= @TimeKey
      --               AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
	                  FROM Fraud_Details_Mod A 
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
					  LEFT JOIN  DIMSOURCEDB C
					  ON          B.SourceAlt_Key=C.SourceAlt_Key 
					  AND         C.EffectiveFromTimeKey <= @TimeKey AND C.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMSOURCEDB CC
					  ON          BB.SourceAlt_Key=CC.SourceAlt_Key 
					  AND         CC.EffectiveFromTimeKey <= @TimeKey AND CC.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMSOURCEDB CD
					  ON          IJ.SourceAlt_Key=CD.SourceAlt_Key 
					  AND         CD.EffectiveFromTimeKey <= @TimeKey AND CD.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMSOURCEDB CE
					  ON          DV.SourceSystem=CE.SourceName 
					  AND         CE.EffectiveFromTimeKey <= @TimeKey AND CE.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN  CustomerBasicDetail D
					  ON          D.CustomerId=B.RefCustomerId
					  AND         D.EffectiveFromTimeKey <= @TimeKey AND D.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN   DIMBRANCH E
					  ON          B.BranchCode=E.BranchCode
					  AND         E.EffectiveFromTimeKey <= @TimeKey AND E.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMBRANCH EE
					  ON          BB.BranchCode=EE.BranchCode 
					  AND         EE.EffectiveFromTimeKey <= @TimeKey AND EE.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMBRANCH ED
					  ON          IJ.BranchCode=ED.BranchCode 
					  AND         ED.EffectiveFromTimeKey <= @TimeKey AND ED.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN	  DIMBRANCH EC
					  ON          DV.BranchCode=EC.BranchCode 
					  AND         EC.EffectiveFromTimeKey <= @TimeKey AND EC.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN  DimAcBuSegment  F
					  ON		  B.segmentcode=F.AcBuSegmentCode
					  AND         F.EffectiveFromTimeKey <= @TimeKey AND F.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN  DimAcBuSegment  FF
					  ON		  BB.segmentcode=FF.AcBuSegmentCode
					  AND         FF.EffectiveFromTimeKey <= @TimeKey AND FF.EffectiveToTimeKey >= @TimeKey
					  LEFT JOIN  DIMPRODUCT G
					  ON          B.ProductAlt_Key=G.ProductAlt_Key
					  AND         G.EffectiveFromTimeKey <= @TimeKey AND G.EffectiveToTimeKey >= @TimeKey
					  LEFT join  AdvCustNpaDetail H
					  ON          D.CustomerEntityId=H.CustomerEntityId
					  AND         H.EffectiveFromTimeKey <= @TimeKey AND H.EffectiveToTimeKey >= @TimeKey
					   LEFT join  AdvCustNpaDetail HH
					  ON          BB.CustomerEntityId=HH.CustomerEntityId
					  AND         HH.EffectiveFromTimeKey <= @TimeKey AND HH.EffectiveToTimeKey >= @TimeKey
					   LEFT JOIN  DIMASSETCLASS I
					  ON          A.AssetClassAtFraudAltKey=I.AssetClassAlt_Key
					  AND		I.EffectiveToTimeKey = 49999
					  LEFT JOIN  DIMASSETCLASS L
					  ON          H.Cust_AssetClassAlt_Key=L.AssetClassAlt_Key
					  AND         L.EffectiveToTimeKey = 49999
					    LEFT JOIN  DIMASSETCLASS LL
					  ON          HH.Cust_AssetClassAlt_Key=LL.AssetClassAlt_Key
					  AND         LL.EffectiveToTimeKey = 49999
					   LEFT JOIN  DIMASSETCLASS LK
					  ON          IK.FinalAssetClassAlt_key=LK.AssetClassAlt_Key
					  AND         LK.EffectiveToTimeKey = 49999
					  LEFT JOIN  DIMASSETCLASS LM
					  ON         DV.FinalAssetClassAlt_key=LM.AssetClassAlt_Key
					  AND         LM.EffectiveToTimeKey = 49999
					  Left join  #CustNPADetail Q
					  ON         Q.RefCustomerID=D.CustomerId

					  LEFT JOIN   DimAssetClass R
					  ON          Q.Cust_AssetClassAlt_Key=R.AssetClassAlt_Key
					  AND         R.EffectiveToTimeKey = 49999

					  LEFT JOIN   DimAssetClass S
					  ON          A.AssetClassAlt_KeyBeforeFruad=S.AssetClassAlt_Key
					  AND         S.EffectiveToTimeKey = 49999

					  WHERE B.CustomerACID=@Account_id
					        AND B.EffectiveFromTimeKey <= @TimeKey
                           AND B.EffectiveToTimeKey >= @TimeKey
                           AND ISNULL(A.AuthorisationStatus, 'A') IN('1A')
                           AND A.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM Fraud_Details_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               --AND ISNULL(A.AuthorisationStatus, 'A') IN('1A')
							    AND (case when @AuthLevel =2  AND ISNULL(AuthorisationStatus, 'A') IN('1A','D1')
										THEN 1 
							           when @AuthLevel =1 AND ISNULL(AuthorisationStatus,'A') IN ('NP','MP','DP')
										THEN 1
										ELSE 0									
										END
									)=1
                         GROUP BY EntityKey
                     )
                 ) A 
                      
                 
                 GROUP BY	AccountEntityId
							,CustomerEntityId
							,RefCustomerACID
							,RefCustomerID
							,SourceName
							,BranchCode
							,BranchName
							,AcBuSegmentCode
							,AcBuSegmentDescription
							,UCIF_ID 							
							,CustomerName	
							,TOS				
							,POS
							,AssetClassAlt_KeyBeforeFruad
							,AssetClassAtFraud
							,NPADateAtFraud
							,RFA_ReportingByBank
							,RFA_DateReportingByBank
							,RFA_OtherBankAltKey
							,RFA_OtherBankDate
							,FraudOccuranceDate
							,FraudDeclarationDate
							,FraudNature
							,FraudArea
							,CurrentAssetClassName
							,CurrentAssetClassAltKey
							,CurrentNPA_Date
							,Provisionpreference
							,A.AuthorisationStatus
							,A.EffectiveFromTimeKey
							,A.EffectiveToTimeKey
							,A.CreatedBy
							,A.DateCreated
							,A.ModifiedBy
							,A.DateModified
							,A.ApprovedBy
							,A.DateApproved
							,ApprovedByFirstLevel
							,FirstLevelDateApproved 
							,A.ChangeFields
							,A.screenFlag
							,A.ReasonforRFAClassification 
							,A.DateofRemovalofRFAClassification 
							,A.ReasonforRemovalofRFAClassification 
							,A.DateofRemovalofRFAClassificationReporting 
							,A.RFAReportedOtherBank
							,A.NameofBank
							,A.CrModBy
							,A.CrModDate
							,A.CrAppBy
							,A.CrAppDate
							,A.ModAppBy
							,A.ModAppDate
							,A.AuthorisationStatus_1
							--,A.changeFields
                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY RefCustomerACID) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'Fraud' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp201 A
						 
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner
				  Order By DataPointOwner.DateCreated Desc
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
                 --      AND RowNumber <= (@PageNo * @PageSize)
  END



   END


   END TRY
	BEGIN CATCH
	
	INSERT INTO dbo.Error_Log
				SELECT ERROR_LINE() as ErrorLine,ERROR_MESSAGE()ErrorMessage,ERROR_NUMBER()ErrorNumber
				,ERROR_PROCEDURE()ErrorProcedure,ERROR_SEVERITY()ErrorSeverity,ERROR_STATE()ErrorState
				,GETDATE()

	SELECT ERROR_MESSAGE()
	--RETURN -1
   
	END CATCH


  
  
    END;

GO