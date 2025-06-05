SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--exec FacilityDetailSelect @CustomerEntityID=601,@AccountEntityID=101,@FacilityType=N'TL',@TimeKey=25999,@BranchCode=N'101',@OperationFlag=2,@AccountFlag=N'F'
--go


--sp_helptext FacilityDetailSelect

--------------------------------------------------------------------------------------------------------


--Text
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

 -- =============================================
CREATE PROCEDURE [dbo].[FacilityDetailSelect]
	 @CustomerEntityID INT=0
	,@AccountEntityID INT=0
	,@FacilityType varchar(10)=''
	,@TimeKey	INT=0
	,@BranchCode VARCHAR(10)=''
	,@OperationFlag TINYINT=0
	,@AccountFlag varchar(2)=''
 
 
-- Declare
--     @CustomerEntityID INT=1001556
--	,@AccountEntityID INT=679
--	,@FacilityType varchar(10)='AB'
--	,@TimeKey	INT=24570
--	,@BranchCode VARCHAR(10)='0110'
--	,@OperationFlag TINYINT=2
--	,@AccountFlag varchar(2)='F'

AS 

BEGIN

	SET NOCOUNT ON;

	Declare @LastQtrTimekey int = (select LastQtrDateKey from SYSDAYMATRIX where Timekey = @Timekey)
			
	IF (@OperationFlag=2)		
			BEGIN
										Select 
										A.CustomerAcId
										,Convert(Varchar(20),A.AccountOpenDate,103) AcOpenDt
										,I.SchemeType SchemeType
										,I.ProductName SchemeProductCode
										,A.SegmentCode ACSegmentCode
										,A.FacilityType
										,C.InttRate Rateofinterest
										,A.FlgSecured SecuredStatus
										--,A.AssetClass AssetClassNorm
										,A.ReferencePeriod AssetClassNorm
										,isnull(J.AssetClassName,'STANDARD') AS AssetClassCode
										,Convert(Varchar(20),C.NpaDt,103) NPADate
										,Convert(Varchar(20),ac.SMA_Dt ,103) SMADate 
										,ac.SMA_Class SMAStatus
										,K.SubSectorName Sector
										,L.ActivityName PurposeofAdvance
										,A.CurrentLimit
										,Convert(varchar(20),A.CurrentLimitDt,103) CurrentLimitDate
										,Convert(varchar(20),A.DtofFirstDisb,103) FirstDateofDisbursement
										,B.Balance BalanceosINR
										,B.PrincipalBalance POS
										,B.InterestReceivable  InterestReceivable
										,B.UnAppliedIntAmount InterestAccrued
										,C.DrawingPower
										,G.AdhocAmt
										,Convert(Varchar(20),G.AdhocDt,103) AdhocDate
										,COnvert(varchar(20),G.AdhocExpiryDate,103) AdhocExpiryDate
										,convert(varchar(20),AC.IntNotServicedDt,103) IntNotServicedDate
										,Convert(Varchar(20),AC.DebitSinceDt,103) DebitSinceDate
										,Convert(Varchar(20),B.LastCrDt,103) LastCreditDate
										,Convert(Varchar(20),G.ContExcsSinceDt,103) ContiExcessDate
										,AC.CurQtrCredit CurQtrCredit
										,AC.CurQtrInt CurQtrInt
										,Convert(Varchar(20),AC.StockStDt,103) StockStatementDt
										--,NULL StockStatemenFrequency
										,Convert(varchar(20),C.Ac_ReviewDt,103) ReviewRenewalDueDate
										,B.OverduePrincipal PrincipalOverdueAmt
										,Convert(varchar(20),B.OverduePrincipalDt,103) PrincipalOverDueSinceDt
										,B.Overdueinterest InterestOverdueAmt
										,convert(varchar(20),B.OverdueIntDt,103) InterestOverDueSinceDt
										,F.CorporateUCIC_ID CorporateUCICID
										,F.CorporateCustomerID CorporateCustomerID
										,F.Liability
										,F.MinimumAmountDue
										,F.CD CycleDue
										,F.Bucket
										,F.DPD
										--,NULL AccountCategory
										--,NULL STDProvisionCategory
										--,Convert(varchar(20),E.WriteOffDt,103) DateofTWO
										,Convert(varchar(20),EFST_T.StatusDate,103) DateofTWO
										--,E.WriteOffAmt WriteOffAmt_HO
										,EFST_T.Amount WriteOffAmt_HO
										--,N.SplFlag FraudCommitted 
										,case when EFST.StatusType is null then 'No' else 'Yes' end FraudCommitted
										--,D.FMRDate FraudDate
										,Convert(varchar(20),EFST.StatusDate,103) FraudDate
										--,O.SplFlag IBPCExposure
										--,P.SplFlag SecurtisedExposure
										--,Q.SplFlag AbInitio
										--,R.SplFlag PUIMarked
										 ,case when pui.AccountEntityId is null then 'No' else 'Yes' end PUIMarked
										--,NULL RFAMarked
										--,S.SplFlag NonCooperative
										--,T.SplFlag Repossesion
										--,U.SplFlag Sarfaesi
										--,V.SplFlag Inherentweakness
										--,W.SplFlag RCPendingFlag
										--,M.ExitCDRFlg RestructureFlag
										,case when M.AccountEntityId is null then 'No' else 'Yes' end RestructureFlag
										--, Case When AD.StatusType ='TWO' Then AD.StatusDate Else '' END  [TWO Date]
										,Convert(varchar(20),EFST_T.StatusDate,103)  [TWO Date]
									    --, Case When AD.StatusType ='TWO' Then ISNULL(AD.Amount,0)  Else 0.00 END  [TWO Amount]
										,EFST_T.Amount as [TWO Amount]
                                       -- , AD.StatusDate AS [Fraud Date] --Sachin
									    --,EFST.StatusDate AS [Fraud Date] --PRASHANT
										--,IB.ExposureAmount AS [IBPC Exposure Amount] --Sachin
										--,SF.ExposureAmount AS [Securtised Exposure Amount] --Sachin
										--,N.SplFlag AS [Fraud Committed] --Sachin
										--,case when EFST.StatusType is null then 'No' else 'Yes' end [Fraud Committed] --PRASHANT
										--,Q.SplFlag AS [Ab-Initio] --Sachin
										--,R.SplFlag AS [PUI Marked] --Sachin
										--,case when pui.AccountEntityId is null then 'No' else 'Yes' end [PUI Marked]
										--,RF.SplFlag AS [RFA Marked] --Sachin
										,Case when RFA.RefCustomerACID is not null Then 'Yes' Else 'No'  END RFAFlag
									--	,RFA.RFA_DateReportingByBank as RFADate
								    	,Convert(varchar(20),RFA.RFA_DateReportingByBank,103) as RFADAte
										,B.UnAppliedIntAmount as UnAppliedIntAmount
										,Case When ACH.FinalAssetClassAlt_Key=1 Then ACH.SMA_Class Else J.AssetClassShortNameEnum  ENd as AssetSubClass
										,ACH.TotalProvision as ProvisionAmount
										,AC.DPD_Max as DPDMax
										, 0.00 OtherOverdue
										, 0.00 TotalOverdue
										, 0.00 SecurityValuePreviousQuarter
										, 0.00 SecurityValueCurrentQuarter
										, '1900-01-01' SecurityDate
										From CurDat.AdvAcBasicDetail A
										LEFT JOIN CurDat.AdvAcBalanceDetail B ON A.AccountEntityId=B.AccountEntityId
										AND B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey
										
										LEFT JOIN CurDat.AdvAcFinancialDetail C ON C.AccountEntityId=A.AccountEntityId
										AND C.EffectiveFromTimeKey<=@TimeKey And C.EffectiveToTimeKey>=@TimeKey
										LEFT JOIN CurDat.AdvCustOtherDetail D ON D.CustomerEntityId=A.CustomerEntityId
										AND D.EffectiveFromTimeKey<=@TimeKey And D.EffectiveToTimeKey>=@TimeKey
										LEFT JOIN CurDat.AdvAcWODetail E ON E.AccountEntityId=A.AccountEntityId
										AND E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey
										LEFT JOIN CurDat.AdvFacCreditCardDetail F ON F.AccountEntityId=A.AccountEntityId
										AND F.EffectiveFromTimeKey<=@TimeKey And F.EffectiveToTimeKey>=@TimeKey
										LEFT JOIN Curdat.ADVFACCCDETAIL G ON G.AccountEntityId=A.AccountEntityId
										AND G.EffectiveFromTimeKey<=@TimeKey And G.EffectiveToTimeKey>=@TimeKey
										LEFT JOIN Curdat.AdvFacDLDetail H ON H.AccountEntityId=A.AccountEntityId
										AND H.EffectiveFromTimeKey<=@TimeKey And H.EffectiveToTimeKey>=@TimeKey
										LEFT JOIN DimProduct I ON I.ProductAlt_Key=A.ProductAlt_Key
										AND I.EffectiveFromTimeKey<=@TimeKey And I.EffectiveToTimeKey>=@TimeKey
										LEFT JOIN DimAssetClass J ON J.AssetClassAlt_Key=B.AssetClassAlt_Key
										AND J.EffectiveFromTimeKey<=@TimeKey And j.EffectiveToTimeKey>=@TimeKey
										LEFT JOIN DimSubSector k ON k.SubSectorAlt_Key=A.SubSectorAlt_Key
										AND K.EffectiveFromTimeKey<=@TimeKey And K.EffectiveToTimeKey>=@TimeKey
										LEFT JOIN DimActivity l ON l.ActivityAlt_Key=A.ActivityAlt_Key
										AND l.EffectiveFromTimeKey<=@TimeKey And l.EffectiveToTimeKey>=@TimeKey
										LEFT JOIN Curdat.AdvAcRestructureDetail M ON M.AccountEntityId=A.AccountEntityId
										AND M.EffectiveFromTimeKey<=@TimeKey And M.EffectiveToTimeKey>=@TimeKey
										LEFT JOIN ExceptionFinalStatusType AD ON A.CustomerACID=AD.ACID  --Sachin
										AND AD.EffectiveFromTimeKey<=@TimeKey And AD.EffectiveToTimeKey>=@TimeKey									
										left join AdvAcPUIDetailMain pui on pui.AccountEntityId=a.AccountEntityId
										and pui.EffectiveFromTimeKey<=@TimeKey and pui.EffectiveToTimeKey>=@TimeKey
										LEFT JOIN PRO.ACCOUNTCAL AC ON AC.AccountEntityId=A.AccountEntityId
										AND AC.EffectiveFromTimeKey<=@TimeKey And AC.EffectiveToTimeKey>=@TimeKey
										 left join  (select  CustomerID,ACID,StatusType,StatusDate from  ExceptionFinalStatusType
														where StatusType='Fraud Committed'
														And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) EFST
														 on   a.CustomerACID=EFST.ACID
										 left join (select  CustomerID,ACID,StatusType,StatusDate,Amount from  ExceptionFinalStatusType
													where StatusType='TWO'
												    And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) EFST_T
													on   a.CustomerACID=EFST_T.ACID
										--left join (select  * from  Fraud_Details
										--			where RFA_DateReportingByBank is not null
										--		    And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) RFA
										--			on   a.CustomerACID=RFA.RefCustomerACID


										left join Fraud_Details rfa on rfa.effectiveFromTimeKey<=@TimeKey And rfa.EffectiveToTimeKey>=@TimeKey
										and  a.CustomerACID=RFA.RefCustomerACID

										LEFT JOIN PRO.AccountCal_Hist ACH ON ACH.AccountEntityId=A.AccountEntityId
										AND ACH.EffectiveFromTimeKey<=@TimeKey And ACH.EffectiveToTimeKey>=@TimeKey

										LEFT JOIN PRO.AccountCal_Hist ACZ ON ACZ.AccountEntityId=A.AccountEntityId
										AND ACZ.EffectiveFromTimeKey<=@LastQtrTimekey And ACZ.EffectiveToTimeKey>=@LastQtrTimekey

										Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
										AND A.AccountEntityId=@AccountEntityId
										AND A.FacilityType=@FacilityType
										AND A.CustomerEntityId=@CustomerEntityId
										AND A.BranchCode=@BranchCode

								END
				
END
GO