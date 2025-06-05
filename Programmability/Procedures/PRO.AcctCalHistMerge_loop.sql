SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

------ =============================================
------ Author:		<Author,,Name>
------ Create date: <Create Date,,>
------ Description:	<Description,,>
------ =============================================
----/*   ADD NEW OLUMN
----	ALTER TABLE PRO.PUI_CAL ADD IsChanged CHAR(1)
----	ALTER TABLE PRO.ADVACRESTRUCTURECAL ADD IsChanged CHAR(1)
----	ALTER TABLE PRO.ACCOUNTCAL ADD IsChanged CHAR(1)
----	ALTER TABLE PRO.CUSTOMERCAL ADD IsChanged CHAR(1)
----*/
-----exec [PRO].[AcctCalHistMerge_loop] @date1='2021-07-11', @date2='2021-07-31'

CREATE PROCEDURE [PRO].[AcctCalHistMerge_loop]
---- Add the parameters for the stored procedure here
	@date1 date=''
	,@date2 date =''
	
AS
BEGIN

   declare @VEFFECTIVETO int, @TimeKey int
   DROP TABLE IF EXISTS #TIMEKEY
   select Timekey, DATE,ROW_NUMBER() OVER (ORDER By TIMEKEY) ROWID
   INTO #TIMEKEY
   FROM sysdaymatrix 
   where date between @date1 and @date2

   DECLARE @RowCnt smallint=(select max(rowid) from #timekey )
		   ,@RowNo smallint=1

/*  CUSTOMER DATA MERGE */
WHILE @RowNo<=@RowCnt
BEGIN
	  SELECT @Timekey=Timekey,@VEFFECTIVETO=Timekey-1  from #timekey where ROWID=@RowNo

		SELECT @Timekey=Timekey,@VEFFECTIVETO=Timekey-1  from #timekey where ROWID=@RowNo

	/*  ACCOUNT DATA MERGE */

		DROP TABLE IF EXISTS #acdata
		SELECT *,'N' IsChanged,cast(0 as bigint) EntityKeyNew into #acdata from pro.AccountCal_Hist where EffectiveFromTimeKey =@TimeKey
		IF 1=1
		BEGIN


			UPDATE T
				SET T.IsChanged='E'
			FROM [PRO].[AccountCal_Hist_new] AS O
			INNER JOIN #acdata AS T
				ON O.AccountEntityID=T.AccountEntityID
				AND O.EffectiveToTimeKey=49999

			UPDATE T 
				SET T.IsChanged='C'
			FROM [PRO].[AccountCal_Hist_new] AS O
			INNER JOIN #acdata AS T
				ON O.AccountEntityID=T.AccountEntityID
				AND O.EffectiveToTimeKey=49999
			WHERE (  
					   ISNULL(O.UcifEntityID,0)<>ISNULL(T.UcifEntityID,0)
					OR ISNULL(O.CustomerEntityID,0)<>ISNULL(T.CustomerEntityID,0)
					OR ISNULL(O.CustomerAcID,'')<>ISNULL(T.CustomerAcID,'')
					OR ISNULL(O.RefCustomerID,'')<>ISNULL(T.RefCustomerID,'')
					OR ISNULL(O.SourceSystemCustomerID,'')<>ISNULL(T.SourceSystemCustomerID,'')
					OR ISNULL(O.UCIF_ID,'')<>ISNULL(T.UCIF_ID,'')
					OR ISNULL(O.BranchCode,'')<>ISNULL(T.BranchCode,'')
					OR ISNULL(O.FacilityType,'')<>ISNULL(T.FacilityType,'')
					OR ISNULL(O.AcOpenDt,'1900-01-01')<>ISNULL(T.AcOpenDt,'1900-01-01')
					OR ISNULL(O.FirstDtOfDisb,'1900-01-01')<>ISNULL(T.FirstDtOfDisb,'1900-01-01')
					OR ISNULL(O.ProductAlt_Key,0)<>ISNULL(T.ProductAlt_Key,0)
					OR ISNULL(O.SchemeAlt_key,0)<>ISNULL(T.SchemeAlt_key,0)
					OR ISNULL(O.SubSectorAlt_Key,0)<>ISNULL(T.SubSectorAlt_Key,0)
					OR ISNULL(O.SplCatg1Alt_Key,0)<>ISNULL(T.SplCatg1Alt_Key,0)
					OR ISNULL(O.SplCatg2Alt_Key,0)<>ISNULL(T.SplCatg2Alt_Key,0)
					OR ISNULL(O.SplCatg3Alt_Key,0)<>ISNULL(T.SplCatg3Alt_Key,0)
					OR ISNULL(O.SplCatg4Alt_Key,0)<>ISNULL(T.SplCatg4Alt_Key,0)
					OR ISNULL(O.SourceAlt_Key,0)<>ISNULL(T.SourceAlt_Key,0)
					OR ISNULL(O.ActSegmentCode,'')<>ISNULL(T.ActSegmentCode,'')
					OR ISNULL(O.InttRate,0)<>ISNULL(T.InttRate,0)
					OR ISNULL(O.Balance,0)<>ISNULL(T.Balance,0)
					OR ISNULL(O.BalanceInCrncy,0)<>ISNULL(T.BalanceInCrncy,0)
					OR ISNULL(O.CurrencyAlt_Key,0)<>ISNULL(T.CurrencyAlt_Key,0)
					OR ISNULL(O.DrawingPower,0)<>ISNULL(T.DrawingPower,0)
					OR ISNULL(O.CurrentLimit,0)<>ISNULL(T.CurrentLimit,0)
					OR ISNULL(O.CurrentLimitDt,'1900-01-01')<>ISNULL(T.CurrentLimitDt,'1900-01-01')
					OR ISNULL(O.ContiExcessDt,'1900-01-01')<>ISNULL(T.ContiExcessDt,'1900-01-01')
					OR ISNULL(O.StockStDt,'1900-01-01')<>ISNULL(T.StockStDt,'1900-01-01')
					OR ISNULL(O.DebitSinceDt,'1900-01-01')<>ISNULL(T.DebitSinceDt,'1900-01-01')
					OR ISNULL(O.LastCrDate,'1900-01-01')<>ISNULL(T.LastCrDate,'1900-01-01')
					OR ISNULL(O.InttServiced,'')<>ISNULL(T.InttServiced,'')
					OR ISNULL(O.IntNotServicedDt,'1900-01-01')<>ISNULL(T.IntNotServicedDt,'1900-01-01')
					OR ISNULL(O.OverdueAmt,0)<>ISNULL(T.OverdueAmt,0)
					OR ISNULL(O.OverDueSinceDt,'1900-01-01')<>ISNULL(T.OverDueSinceDt,'1900-01-01')
					OR ISNULL(O.ReviewDueDt,'1900-01-01')<>ISNULL(T.ReviewDueDt,'1900-01-01')
					OR ISNULL(O.SecurityValue,0)<>ISNULL(T.SecurityValue,0)
					OR ISNULL(O.DFVAmt,0)<>ISNULL(T.DFVAmt,0)
					OR ISNULL(O.GovtGtyAmt,0)<>ISNULL(T.GovtGtyAmt,0)
					OR ISNULL(O.CoverGovGur,0)<>ISNULL(T.CoverGovGur,0)
					OR ISNULL(O.WriteOffAmount,0)<>ISNULL(T.WriteOffAmount,0)
					OR ISNULL(O.UnAdjSubSidy,0)<>ISNULL(T.UnAdjSubSidy,0)
					OR ISNULL(O.CreditsinceDt,'1900-01-01')<>ISNULL(T.CreditsinceDt,'1900-01-01')
					OR ISNULL(O.DegReason,'')<>ISNULL(T.DegReason,'')
					OR ISNULL(O.Asset_Norm,'')<>ISNULL(T.Asset_Norm,'')
					OR ISNULL(O.REFPeriodMax,0)<>ISNULL(T.REFPeriodMax,0)
					OR ISNULL(O.RefPeriodOverdue,0)<>ISNULL(T.RefPeriodOverdue,0)
					OR ISNULL(O.RefPeriodOverDrawn,0)<>ISNULL(T.RefPeriodOverDrawn,0)
					OR ISNULL(O.RefPeriodNoCredit,0)<>ISNULL(T.RefPeriodNoCredit,0)
					OR ISNULL(O.RefPeriodIntService,0)<>ISNULL(T.RefPeriodIntService,0)
					OR ISNULL(O.RefPeriodStkStatement,0)<>ISNULL(T.RefPeriodStkStatement,0)
					OR ISNULL(O.RefPeriodReview,0)<>ISNULL(T.RefPeriodReview,0)
					OR ISNULL(O.NetBalance,0)<>ISNULL(T.NetBalance,0)
					OR ISNULL(O.ApprRV,0)<>ISNULL(T.ApprRV,0)
					OR ISNULL(O.SecuredAmt,0)<>ISNULL(T.SecuredAmt,0)
					OR ISNULL(O.UnSecuredAmt,0)<>ISNULL(T.UnSecuredAmt,0)
					OR ISNULL(O.ProvDFV,0)<>ISNULL(T.ProvDFV,0)
					OR ISNULL(O.Provsecured,0)<>ISNULL(T.Provsecured,0)
					OR ISNULL(O.ProvUnsecured,0)<>ISNULL(T.ProvUnsecured,0)
					OR ISNULL(O.ProvCoverGovGur,0)<>ISNULL(T.ProvCoverGovGur,0)
					OR ISNULL(O.AddlProvision,0)<>ISNULL(T.AddlProvision,0)
					OR ISNULL(O.TotalProvision,0)<>ISNULL(T.TotalProvision,0)
					OR ISNULL(O.BankProvsecured,0)<>ISNULL(T.BankProvsecured,0)
					OR ISNULL(O.BankProvUnsecured,0)<>ISNULL(T.BankProvUnsecured,0)
					OR ISNULL(O.BankTotalProvision,0)<>ISNULL(T.BankTotalProvision,0)
					OR ISNULL(O.RBIProvsecured,0)<>ISNULL(T.RBIProvsecured,0)
					OR ISNULL(O.RBIProvUnsecured,0)<>ISNULL(T.RBIProvUnsecured,0)
					OR ISNULL(O.RBITotalProvision,0)<>ISNULL(T.RBITotalProvision,0)
					OR ISNULL(O.InitialNpaDt,'1900-01-01')<>ISNULL(T.InitialNpaDt,'1900-01-01')
					OR ISNULL(O.FinalNpaDt,'1900-01-01')<>ISNULL(T.FinalNpaDt,'1900-01-01')
					OR ISNULL(O.SMA_Dt,'1900-01-01')<>ISNULL(T.SMA_Dt,'1900-01-01')
					OR ISNULL(O.UpgDate,'1900-01-01')<>ISNULL(T.UpgDate,'1900-01-01')
					OR ISNULL(O.InitialAssetClassAlt_Key,0)<>ISNULL(T.InitialAssetClassAlt_Key,0)
					OR ISNULL(O.FinalAssetClassAlt_Key,0)<>ISNULL(T.FinalAssetClassAlt_Key,0)
					OR ISNULL(O.ProvisionAlt_Key,0)<>ISNULL(T.ProvisionAlt_Key,0)
					OR ISNULL(O.PNPA_Reason,'')<>ISNULL(T.PNPA_Reason,'')
					OR ISNULL(O.SMA_Class,'')<>ISNULL(T.SMA_Class,'')
					OR ISNULL(O.SMA_Reason,'')<>ISNULL(T.SMA_Reason,'')
					OR ISNULL(O.FlgMoc,'')<>ISNULL(T.FlgMoc,'')
					OR ISNULL(O.MOC_Dt,'1900-01-01')<>ISNULL(T.MOC_Dt,'1900-01-01')
					OR ISNULL(O.CommonMocTypeAlt_Key,0)<>ISNULL(T.CommonMocTypeAlt_Key,0)
					OR ISNULL(O.FlgDeg,'')<>ISNULL(T.FlgDeg,'')
					OR ISNULL(O.FlgDirtyRow,'')<>ISNULL(T.FlgDirtyRow,'')
					OR ISNULL(O.FlgInMonth,'')<>ISNULL(T.FlgInMonth,'')
					OR ISNULL(O.FlgSMA,'')<>ISNULL(T.FlgSMA,'')
					OR ISNULL(O.FlgPNPA,'')<>ISNULL(T.FlgPNPA,'')
					OR ISNULL(O.FlgUpg,'')<>ISNULL(T.FlgUpg,'')
					OR ISNULL(O.FlgFITL,'')<>ISNULL(T.FlgFITL,'')
					OR ISNULL(O.FlgAbinitio,'')<>ISNULL(T.FlgAbinitio,'')
					OR ISNULL(O.NPA_Days,0)<>ISNULL(T.NPA_Days,0)
					OR ISNULL(O.RefPeriodOverdueUPG,0)<>ISNULL(T.RefPeriodOverdueUPG,0)
					OR ISNULL(O.RefPeriodOverDrawnUPG,0)<>ISNULL(T.RefPeriodOverDrawnUPG,0)
					OR ISNULL(O.RefPeriodNoCreditUPG,0)<>ISNULL(T.RefPeriodNoCreditUPG,0)
					OR ISNULL(O.RefPeriodIntServiceUPG,0)<>ISNULL(T.RefPeriodIntServiceUPG,0)
					OR ISNULL(O.RefPeriodStkStatementUPG,0)<>ISNULL(T.RefPeriodStkStatementUPG,0)
					OR ISNULL(O.RefPeriodReviewUPG,0)<>ISNULL(T.RefPeriodReviewUPG,0)
					OR ISNULL(O.AppGovGur,0)<>ISNULL(T.AppGovGur,0)
					OR ISNULL(O.UsedRV,0)<>ISNULL(T.UsedRV,0)
					OR ISNULL(O.ComputedClaim,0)<>ISNULL(T.ComputedClaim,0)
					OR ISNULL(O.UPG_RELAX_MSME,'')<>ISNULL(T.UPG_RELAX_MSME,'')
					OR ISNULL(O.DEG_RELAX_MSME,'')<>ISNULL(T.DEG_RELAX_MSME,'')
					OR ISNULL(O.PNPA_DATE,'1900-01-01')<>ISNULL(T.PNPA_DATE,'1900-01-01')
					OR ISNULL(O.NPA_Reason,'')<>ISNULL(T.NPA_Reason,'')
					OR ISNULL(O.PnpaAssetClassAlt_key,0)<>ISNULL(T.PnpaAssetClassAlt_key,0)
					OR ISNULL(O.DisbAmount,0)<>ISNULL(T.DisbAmount,0)
					OR ISNULL(O.PrincOutStd,0)<>ISNULL(T.PrincOutStd,0)
					OR ISNULL(O.PrincOverdue,0)<>ISNULL(T.PrincOverdue,0)
					OR ISNULL(O.PrincOverdueSinceDt,'1900-01-01')<>ISNULL(T.PrincOverdueSinceDt,'1900-01-01')
					OR ISNULL(O.IntOverdue,0)<>ISNULL(T.IntOverdue,0)
					OR ISNULL(O.IntOverdueSinceDt,'1900-01-01')<>ISNULL(T.IntOverdueSinceDt,'1900-01-01')
					OR ISNULL(O.OtherOverdue,0)<>ISNULL(T.OtherOverdue,0)
					OR ISNULL(O.OtherOverdueSinceDt,'1900-01-01')<>ISNULL(T.OtherOverdueSinceDt,'1900-01-01')
					OR ISNULL(O.RelationshipNumber,'')<>ISNULL(T.RelationshipNumber,'')
					OR ISNULL(O.AccountFlag,'')<>ISNULL(T.AccountFlag,'')
					OR ISNULL(O.CommercialFlag_AltKey,0)<>ISNULL(T.CommercialFlag_AltKey,0)
					OR ISNULL(O.Liability,'')<>ISNULL(T.Liability,'')
					OR ISNULL(O.CD,'')<>ISNULL(T.CD,'')
					OR ISNULL(O.AccountStatus,'')<>ISNULL(T.AccountStatus,'')
					OR ISNULL(O.AccountBlkCode1,'')<>ISNULL(T.AccountBlkCode1,'')
					OR ISNULL(O.AccountBlkCode2,'')<>ISNULL(T.AccountBlkCode2,'')
					OR ISNULL(O.ExposureType,'')<>ISNULL(T.ExposureType,'')
					OR ISNULL(O.Mtm_Value,0)<>ISNULL(T.Mtm_Value,0)
					OR ISNULL(O.BankAssetClass,'')<>ISNULL(T.BankAssetClass,'')
					OR ISNULL(O.NpaType,'')<>ISNULL(T.NpaType,'')
					OR ISNULL(O.SecApp,'')<>ISNULL(T.SecApp,'')
					OR ISNULL(O.BorrowerTypeID,0)<>ISNULL(T.BorrowerTypeID,0)
					OR ISNULL(O.LineCode,'')<>ISNULL(T.LineCode,'')
					OR ISNULL(O.ProvPerSecured,0)<>ISNULL(T.ProvPerSecured,0)
					OR ISNULL(O.ProvPerUnSecured,0)<>ISNULL(T.ProvPerUnSecured,0)
					OR ISNULL(O.MOCReason,'')<>ISNULL(T.MOCReason,'')
					OR ISNULL(O.AddlProvisionPer,0)<>ISNULL(T.AddlProvisionPer,0)
					OR ISNULL(O.FlgINFRA,'')<>ISNULL(T.FlgINFRA,'')
					OR ISNULL(O.RepossessionDate,'1900-01-01')<>ISNULL(T.RepossessionDate,'1900-01-01')
					OR ISNULL(O.DerecognisedInterest1,0)<>ISNULL(T.DerecognisedInterest1,0)
					OR ISNULL(O.DerecognisedInterest2,0)<>ISNULL(T.DerecognisedInterest2,0)
					OR ISNULL(O.ProductCode,'')<>ISNULL(T.ProductCode,'')
					OR ISNULL(O.FlgLCBG,'')<>ISNULL(T.FlgLCBG,'')
					OR ISNULL(O.unserviedint,0)<>ISNULL(T.unserviedint,0)
					OR ISNULL(O.PreQtrCredit,0)<>ISNULL(T.PreQtrCredit,0)
					OR ISNULL(O.PrvQtrInt,0)<>ISNULL(T.PrvQtrInt,0)
					OR ISNULL(O.CurQtrCredit,0)<>ISNULL(T.CurQtrCredit,0)
					OR ISNULL(O.CurQtrInt,0)<>ISNULL(T.CurQtrInt,0)
					OR ISNULL(O.OriginalBranchcode,'')<>ISNULL(T.OriginalBranchcode,'')
					OR ISNULL(O.AdvanceRecovery,0)<>ISNULL(T.AdvanceRecovery,0)
					OR ISNULL(O.NotionalInttAmt,0)<>ISNULL(T.NotionalInttAmt,0)
					OR ISNULL(O.PrvAssetClassAlt_Key,0)<>ISNULL(T.PrvAssetClassAlt_Key,0)
					OR ISNULL(O.MOCTYPE,'')<>ISNULL(T.MOCTYPE,'')
					OR ISNULL(O.FlgSecured,'')<>ISNULL(T.FlgSecured,'')
					OR ISNULL(O.RePossession,'')<>ISNULL(T.RePossession,'')
					OR ISNULL(O.RCPending,'')<>ISNULL(T.RCPending,'')
					OR ISNULL(O.PaymentPending,'')<>ISNULL(T.PaymentPending,'')
					OR ISNULL(O.WheelCase,'')<>ISNULL(T.WheelCase,'')
					OR ISNULL(O.CustomerLevelMaxPer,0)<>ISNULL(T.CustomerLevelMaxPer,0)
					OR ISNULL(O.FinalProvisionPer,0)<>ISNULL(T.FinalProvisionPer,0)
					OR ISNULL(O.IsIBPC,'')<>ISNULL(T.IsIBPC,'')
					OR ISNULL(O.IsSecuritised,'')<>ISNULL(T.IsSecuritised,'')
					OR ISNULL(O.RFA,'')<>ISNULL(T.RFA,'')
					OR ISNULL(O.IsNonCooperative,'')<>ISNULL(T.IsNonCooperative,'')
					OR ISNULL(O.Sarfaesi,'')<>ISNULL(T.Sarfaesi,'')
					OR ISNULL(O.WeakAccount,'')<>ISNULL(T.WeakAccount,'')
					OR ISNULL(O.PUI,'')<>ISNULL(T.PUI,'')
					OR ISNULL(O.FlgFraud,'')<>ISNULL(T.FlgFraud,'')
					OR ISNULL(O.FlgRestructure,'')<>ISNULL(T.FlgRestructure,'')
					OR ISNULL(O.RestructureDate,'1900-01-01')<>ISNULL(T.RestructureDate,'1900-01-01')
					OR ISNULL(O.SarfaesiDate,'1900-01-01')<>ISNULL(T.SarfaesiDate,'1900-01-01')
					OR ISNULL(O.FlgUnusualBounce,'')<>ISNULL(T.FlgUnusualBounce,'')
					OR ISNULL(O.UnusualBounceDate,'1900-01-01')<>ISNULL(T.UnusualBounceDate,'1900-01-01')
					OR ISNULL(O.FlgUnClearedEffect,'')<>ISNULL(T.FlgUnClearedEffect,'')
					OR ISNULL(O.UnClearedEffectDate,'1900-01-01')<>ISNULL(T.UnClearedEffectDate,'1900-01-01')
					OR ISNULL(O.FraudDate,'1900-01-01')<>ISNULL(T.FraudDate,'1900-01-01')
					OR ISNULL(O.WeakAccountDate,'1900-01-01')<>ISNULL(T.WeakAccountDate,'1900-01-01')
				)

			UPDATE A SET 
				A.IsChanged='U'
			from #acdata A
			INNER JOIN [PRO].[AccountCal_Hist_new] B 
			ON B.AccountEntityID=A.AccountEntityID 
			Where B.EffectiveFromTimeKey= @TimeKey
				and A.IsChanged='C'

			----------For Changes Records
			UPDATE b SET 
				b.EffectiveToTimeKey=@VEFFECTIVETO
			from #acdata A
				INNER JOIN [PRO].[AccountCal_Hist_new] B 
				ON B.AccountEntityID=A.AccountEntityID 
				AND B.EffectiveToTimeKey=49999	
			Where B.EffectiveFromTimeKey<@TimeKey
				and A.IsChanged='C'
		
			UPDATE O
				SET
					UcifEntityID=T.UcifEntityID
					,CustomerEntityID=T.CustomerEntityID
					,CustomerAcID=T.CustomerAcID
					,RefCustomerID=T.RefCustomerID
					,SourceSystemCustomerID=T.SourceSystemCustomerID
					,UCIF_ID=T.UCIF_ID
					,BranchCode=T.BranchCode
					,FacilityType=T.FacilityType
					,AcOpenDt=T.AcOpenDt
					,FirstDtOfDisb=T.FirstDtOfDisb
					,ProductAlt_Key=T.ProductAlt_Key
					,SchemeAlt_key=T.SchemeAlt_key
					,SubSectorAlt_Key=T.SubSectorAlt_Key
					,SplCatg1Alt_Key=T.SplCatg1Alt_Key
					,SplCatg2Alt_Key=T.SplCatg2Alt_Key
					,SplCatg3Alt_Key=T.SplCatg3Alt_Key
					,SplCatg4Alt_Key=T.SplCatg4Alt_Key
					,SourceAlt_Key=T.SourceAlt_Key
					,ActSegmentCode=T.ActSegmentCode
					,InttRate=T.InttRate
					,Balance=T.Balance
					,BalanceInCrncy=T.BalanceInCrncy
					,CurrencyAlt_Key=T.CurrencyAlt_Key
					,DrawingPower=T.DrawingPower
					,CurrentLimit=T.CurrentLimit
					,CurrentLimitDt=T.CurrentLimitDt
					,ContiExcessDt=T.ContiExcessDt
					,StockStDt=T.StockStDt
					,DebitSinceDt=T.DebitSinceDt
					,LastCrDate=T.LastCrDate
					,InttServiced=T.InttServiced
					,IntNotServicedDt=T.IntNotServicedDt
					,OverdueAmt=T.OverdueAmt
					,OverDueSinceDt=T.OverDueSinceDt
					,ReviewDueDt=T.ReviewDueDt
					,SecurityValue=T.SecurityValue
					,DFVAmt=T.DFVAmt
					,GovtGtyAmt=T.GovtGtyAmt
					,CoverGovGur=T.CoverGovGur
					,WriteOffAmount=T.WriteOffAmount
					,UnAdjSubSidy=T.UnAdjSubSidy
					,CreditsinceDt=T.CreditsinceDt
					,DegReason=T.DegReason
					,Asset_Norm=T.Asset_Norm
					,REFPeriodMax=T.REFPeriodMax
					,RefPeriodOverdue=T.RefPeriodOverdue
					,RefPeriodOverDrawn=T.RefPeriodOverDrawn
					,RefPeriodNoCredit=T.RefPeriodNoCredit
					,RefPeriodIntService=T.RefPeriodIntService
					,RefPeriodStkStatement=T.RefPeriodStkStatement
					,RefPeriodReview=T.RefPeriodReview
					,NetBalance=T.NetBalance
					,ApprRV=T.ApprRV
					,SecuredAmt=T.SecuredAmt
					,UnSecuredAmt=T.UnSecuredAmt
					,ProvDFV=T.ProvDFV
					,Provsecured=T.Provsecured
					,ProvUnsecured=T.ProvUnsecured
					,ProvCoverGovGur=T.ProvCoverGovGur
					,AddlProvision=T.AddlProvision
					,TotalProvision=T.TotalProvision
					,BankProvsecured=T.BankProvsecured
					,BankProvUnsecured=T.BankProvUnsecured
					,BankTotalProvision=T.BankTotalProvision
					,RBIProvsecured=T.RBIProvsecured
					,RBIProvUnsecured=T.RBIProvUnsecured
					,RBITotalProvision=T.RBITotalProvision
					,InitialNpaDt=T.InitialNpaDt
					,FinalNpaDt=T.FinalNpaDt
					,SMA_Dt=T.SMA_Dt
					,UpgDate=T.UpgDate
					,InitialAssetClassAlt_Key=T.InitialAssetClassAlt_Key
					,FinalAssetClassAlt_Key=T.FinalAssetClassAlt_Key
					,ProvisionAlt_Key=T.ProvisionAlt_Key
					,PNPA_Reason=T.PNPA_Reason
					,SMA_Class=T.SMA_Class
					,SMA_Reason=T.SMA_Reason
					,FlgMoc=T.FlgMoc
					,MOC_Dt=T.MOC_Dt
					,CommonMocTypeAlt_Key=T.CommonMocTypeAlt_Key
					,FlgDeg=T.FlgDeg
					,FlgDirtyRow=T.FlgDirtyRow
					,FlgInMonth=T.FlgInMonth
					,FlgSMA=T.FlgSMA
					,FlgPNPA=T.FlgPNPA
					,FlgUpg=T.FlgUpg
					,FlgFITL=T.FlgFITL
					,FlgAbinitio=T.FlgAbinitio
					,NPA_Days=T.NPA_Days
					,RefPeriodOverdueUPG=T.RefPeriodOverdueUPG
					,RefPeriodOverDrawnUPG=T.RefPeriodOverDrawnUPG
					,RefPeriodNoCreditUPG=T.RefPeriodNoCreditUPG
					,RefPeriodIntServiceUPG=T.RefPeriodIntServiceUPG
					,RefPeriodStkStatementUPG=T.RefPeriodStkStatementUPG
					,RefPeriodReviewUPG=T.RefPeriodReviewUPG
					,AppGovGur=T.AppGovGur
					,UsedRV=T.UsedRV
					,ComputedClaim=T.ComputedClaim
					,UPG_RELAX_MSME=T.UPG_RELAX_MSME
					,DEG_RELAX_MSME=T.DEG_RELAX_MSME
					,PNPA_DATE=T.PNPA_DATE
					,NPA_Reason=T.NPA_Reason
					,PnpaAssetClassAlt_key=T.PnpaAssetClassAlt_key
					,DisbAmount=T.DisbAmount
					,PrincOutStd=T.PrincOutStd
					,PrincOverdue=T.PrincOverdue
					,PrincOverdueSinceDt=T.PrincOverdueSinceDt
					,IntOverdue=T.IntOverdue
					,IntOverdueSinceDt=T.IntOverdueSinceDt
					,OtherOverdue=T.OtherOverdue
					,OtherOverdueSinceDt=T.OtherOverdueSinceDt
					,RelationshipNumber=T.RelationshipNumber
					,AccountFlag=T.AccountFlag
					,CommercialFlag_AltKey=T.CommercialFlag_AltKey
					,Liability=T.Liability
					,CD=T.CD
					,AccountStatus=T.AccountStatus
					,AccountBlkCode1=T.AccountBlkCode1
					,AccountBlkCode2=T.AccountBlkCode2
					,ExposureType=T.ExposureType
					,Mtm_Value=T.Mtm_Value
					,BankAssetClass=T.BankAssetClass
					,NpaType=T.NpaType
					,SecApp=T.SecApp
					,BorrowerTypeID=T.BorrowerTypeID
					,LineCode=T.LineCode
					,ProvPerSecured=T.ProvPerSecured
					,ProvPerUnSecured=T.ProvPerUnSecured
					,MOCReason=T.MOCReason
					,AddlProvisionPer=T.AddlProvisionPer
					,FlgINFRA=T.FlgINFRA
					,RepossessionDate=T.RepossessionDate
					,DerecognisedInterest1=T.DerecognisedInterest1
					,DerecognisedInterest2=T.DerecognisedInterest2
					,ProductCode=T.ProductCode
					,FlgLCBG=T.FlgLCBG
					,unserviedint=T.unserviedint
					,PreQtrCredit=T.PreQtrCredit
					,PrvQtrInt=T.PrvQtrInt
					,CurQtrCredit=T.CurQtrCredit
					,CurQtrInt=T.CurQtrInt
					,OriginalBranchcode=T.OriginalBranchcode
					,AdvanceRecovery=T.AdvanceRecovery
					,NotionalInttAmt=T.NotionalInttAmt
					,PrvAssetClassAlt_Key=T.PrvAssetClassAlt_Key
					,MOCTYPE=T.MOCTYPE
					,FlgSecured=T.FlgSecured
					,RePossession=T.RePossession
					,RCPending=T.RCPending
					,PaymentPending=T.PaymentPending
					,WheelCase=T.WheelCase
					,CustomerLevelMaxPer=T.CustomerLevelMaxPer
					,FinalProvisionPer=T.FinalProvisionPer
					,IsIBPC=T.IsIBPC
					,IsSecuritised=T.IsSecuritised
					,RFA=T.RFA
					,IsNonCooperative=T.IsNonCooperative
					,Sarfaesi=T.Sarfaesi
					,WeakAccount=T.WeakAccount
					,PUI=T.PUI
					,FlgFraud=T.FlgFraud
					,FlgRestructure=T.FlgRestructure
					,RestructureDate=T.RestructureDate
					,SarfaesiDate=T.SarfaesiDate
					,FlgUnusualBounce=T.FlgUnusualBounce
					,UnusualBounceDate=T.UnusualBounceDate
					,FlgUnClearedEffect=T.FlgUnClearedEffect
					,UnClearedEffectDate=T.UnClearedEffectDate
					,FraudDate=T.FraudDate
					,WeakAccountDate=T.WeakAccountDate
			FROM [PRO].[AccountCal_Hist_new] O
				INNER JOIN #acdata T 
					ON O.AccountEntityID=T.AccountEntityID 
				WHERE O.EffectiveFromTimeKey=@TimeKey
					AND T.IsChanged='U'

		----------------------------------------------------------------------------------------------------------------------------------------------

		UPDATE AA
		SET 
			EffectiveToTimeKey = @VEFFECTIVETO
		FROM pro.AccountCal_Hist_new AA
		WHERE AA.EffectiveToTimeKey = 49999
		AND NOT EXISTS (SELECT 1 FROM #acdata BB
							WHERE AA.AccountEntityID=BB.AccountEntityID 
						)

		/*  New Customers Ac Key ID Update  */
		DECLARE @EntityKeyAc BIGINT=0 
		SELECT @EntityKeyAc=MAX(EntityKey) FROM  [PRO].[AccountCal_Hist_new]
		IF @EntityKeyAc IS NULL  
		BEGIN
			SET @EntityKeyAc=0
		END

		UPDATE TEMP 
		SET TEMP.EntityKeyNew=ACCT.EntityKeyNew
		 FROM #acdata TEMP
		INNER JOIN (SELECT AccountEntityId,(@EntityKeyAc + ROW_NUMBER()OVER(ORDER BY (SELECT 1))) EntityKeyNew
					FROM #acdata Where IsChanged in ('C','N')
					)ACCT ON TEMP.AccountEntityId=ACCT.AccountEntityId
		WHERE Temp.IsChanged in ('C','N')

		/***************************************************************************************************************/

				INSERT INTO pro.AccountCal_Hist_new
				(
					EntityKey
					,AccountEntityID
					,UcifEntityID
					,CustomerEntityID
					,CustomerAcID
					,RefCustomerID
					,SourceSystemCustomerID
					,UCIF_ID
					,BranchCode
					,FacilityType
					,AcOpenDt
					,FirstDtOfDisb
					,ProductAlt_Key
					,SchemeAlt_key
					,SubSectorAlt_Key
					,SplCatg1Alt_Key
					,SplCatg2Alt_Key
					,SplCatg3Alt_Key
					,SplCatg4Alt_Key
					,SourceAlt_Key
					,ActSegmentCode
					,InttRate
					,Balance
					,BalanceInCrncy
					,CurrencyAlt_Key
					,DrawingPower
					,CurrentLimit
					,CurrentLimitDt
					,ContiExcessDt
					,StockStDt
					,DebitSinceDt
					,LastCrDate
					,InttServiced
					,IntNotServicedDt
					,OverdueAmt
					,OverDueSinceDt
					,ReviewDueDt
					,SecurityValue
					,DFVAmt
					,GovtGtyAmt
					,CoverGovGur
					,WriteOffAmount
					,UnAdjSubSidy
					,CreditsinceDt
					,DegReason
					,Asset_Norm
					,REFPeriodMax
					,RefPeriodOverdue
					,RefPeriodOverDrawn
					,RefPeriodNoCredit
					,RefPeriodIntService
					,RefPeriodStkStatement
					,RefPeriodReview
					,NetBalance
					,ApprRV
					,SecuredAmt
					,UnSecuredAmt
					,ProvDFV
					,Provsecured
					,ProvUnsecured
					,ProvCoverGovGur
					,AddlProvision
					,TotalProvision
					,BankProvsecured
					,BankProvUnsecured
					,BankTotalProvision
					,RBIProvsecured
					,RBIProvUnsecured
					,RBITotalProvision
					,InitialNpaDt
					,FinalNpaDt
					,SMA_Dt
					,UpgDate
					,InitialAssetClassAlt_Key
					,FinalAssetClassAlt_Key
					,ProvisionAlt_Key
					,PNPA_Reason
					,SMA_Class
					,SMA_Reason
					,FlgMoc
					,MOC_Dt
					,CommonMocTypeAlt_Key
					,FlgDeg
					,FlgDirtyRow
					,FlgInMonth
					,FlgSMA
					,FlgPNPA
					,FlgUpg
					,FlgFITL
					,FlgAbinitio
					,NPA_Days
					,RefPeriodOverdueUPG
					,RefPeriodOverDrawnUPG
					,RefPeriodNoCreditUPG
					,RefPeriodIntServiceUPG
					,RefPeriodStkStatementUPG
					,RefPeriodReviewUPG
					,EffectiveFromTimeKey
					,EffectiveToTimeKey
					,AppGovGur
					,UsedRV
					,ComputedClaim
					,UPG_RELAX_MSME
					,DEG_RELAX_MSME
					,PNPA_DATE
					,NPA_Reason
					,PnpaAssetClassAlt_key
					,DisbAmount
					,PrincOutStd
					,PrincOverdue
					,PrincOverdueSinceDt
					,IntOverdue
					,IntOverdueSinceDt
					,OtherOverdue
					,OtherOverdueSinceDt
					,RelationshipNumber
					,AccountFlag
					,CommercialFlag_AltKey
					,Liability
					,CD
					,AccountStatus
					,AccountBlkCode1
					,AccountBlkCode2
					,ExposureType
					,Mtm_Value
					,BankAssetClass
					,NpaType
					,SecApp
					,BorrowerTypeID
					,LineCode
					,ProvPerSecured
					,ProvPerUnSecured
					,MOCReason
					,AddlProvisionPer
					,FlgINFRA
					,RepossessionDate
					,DerecognisedInterest1
					,DerecognisedInterest2
					,ProductCode
					,FlgLCBG
					,unserviedint
					,PreQtrCredit
					,PrvQtrInt
					,CurQtrCredit
					,CurQtrInt
					,OriginalBranchcode
					,AdvanceRecovery
					,NotionalInttAmt
					,PrvAssetClassAlt_Key
					,MOCTYPE
					,FlgSecured
					,RePossession
					,RCPending
					,PaymentPending
					,WheelCase
					,CustomerLevelMaxPer
					,FinalProvisionPer
					,IsIBPC
					,IsSecuritised
					,RFA
					,IsNonCooperative
					,Sarfaesi
					,WeakAccount
					,PUI
					,FlgFraud
					,FlgRestructure
					,RestructureDate
					,SarfaesiDate
					,FlgUnusualBounce
					,UnusualBounceDate
					,FlgUnClearedEffect
					,UnClearedEffectDate
					,FraudDate
					,WeakAccountDate
				)
				SELECT  
					EntityKeyNew
					,AccountEntityID
					,UcifEntityID
					,CustomerEntityID
					,CustomerAcID
					,RefCustomerID
					,SourceSystemCustomerID
					,UCIF_ID
					,BranchCode
					,FacilityType
					,AcOpenDt
					,FirstDtOfDisb
					,ProductAlt_Key
					,SchemeAlt_key
					,SubSectorAlt_Key
					,SplCatg1Alt_Key
					,SplCatg2Alt_Key
					,SplCatg3Alt_Key
					,SplCatg4Alt_Key
					,SourceAlt_Key
					,ActSegmentCode
					,InttRate
					,Balance
					,BalanceInCrncy
					,CurrencyAlt_Key
					,DrawingPower
					,CurrentLimit
					,CurrentLimitDt
					,ContiExcessDt
					,StockStDt
					,DebitSinceDt
					,LastCrDate
					,InttServiced
					,IntNotServicedDt
					,OverdueAmt
					,OverDueSinceDt
					,ReviewDueDt
					,SecurityValue
					,DFVAmt
					,GovtGtyAmt
					,CoverGovGur
					,WriteOffAmount
					,UnAdjSubSidy
					,CreditsinceDt
					,DegReason
					,Asset_Norm
					,REFPeriodMax
					,RefPeriodOverdue
					,RefPeriodOverDrawn
					,RefPeriodNoCredit
					,RefPeriodIntService
					,RefPeriodStkStatement
					,RefPeriodReview
					,NetBalance
					,ApprRV
					,SecuredAmt
					,UnSecuredAmt
					,ProvDFV
					,Provsecured
					,ProvUnsecured
					,ProvCoverGovGur
					,AddlProvision
					,TotalProvision
					,BankProvsecured
					,BankProvUnsecured
					,BankTotalProvision
					,RBIProvsecured
					,RBIProvUnsecured
					,RBITotalProvision
					,InitialNpaDt
					,FinalNpaDt
					,SMA_Dt
					,UpgDate
					,InitialAssetClassAlt_Key
					,FinalAssetClassAlt_Key
					,ProvisionAlt_Key
					,PNPA_Reason
					,SMA_Class
					,SMA_Reason
					,FlgMoc
					,MOC_Dt
					,CommonMocTypeAlt_Key
					,FlgDeg
					,FlgDirtyRow
					,FlgInMonth
					,FlgSMA
					,FlgPNPA
					,FlgUpg
					,FlgFITL
					,FlgAbinitio
					,NPA_Days
					,RefPeriodOverdueUPG
					,RefPeriodOverDrawnUPG
					,RefPeriodNoCreditUPG
					,RefPeriodIntServiceUPG
					,RefPeriodStkStatementUPG
					,RefPeriodReviewUPG
					,@TimeKey EffectiveFromTimeKey
					,49999 EffectiveToTimeKey
					,AppGovGur
					,UsedRV
					,ComputedClaim
					,UPG_RELAX_MSME
					,DEG_RELAX_MSME
					,PNPA_DATE
					,NPA_Reason
					,PnpaAssetClassAlt_key
					,DisbAmount
					,PrincOutStd
					,PrincOverdue
					,PrincOverdueSinceDt
					,IntOverdue
					,IntOverdueSinceDt
					,OtherOverdue
					,OtherOverdueSinceDt
					,RelationshipNumber
					,AccountFlag
					,CommercialFlag_AltKey
					,Liability
					,CD
					,AccountStatus
					,AccountBlkCode1
					,AccountBlkCode2
					,ExposureType
					,Mtm_Value
					,BankAssetClass
					,NpaType
					,SecApp
					,BorrowerTypeID
					,LineCode
					,ProvPerSecured
					,ProvPerUnSecured
					,MOCReason
					,AddlProvisionPer
					,FlgINFRA
					,RepossessionDate
					,DerecognisedInterest1
					,DerecognisedInterest2
					,ProductCode
					,FlgLCBG
					,unserviedint
					,PreQtrCredit
					,PrvQtrInt
					,CurQtrCredit
					,CurQtrInt
					,OriginalBranchcode
					,AdvanceRecovery
					,NotionalInttAmt
					,PrvAssetClassAlt_Key
					,MOCTYPE
					,FlgSecured
					,RePossession
					,RCPending
					,PaymentPending
					,WheelCase
					,CustomerLevelMaxPer
					,FinalProvisionPer
					,IsIBPC
					,IsSecuritised
					,RFA
					,IsNonCooperative
					,Sarfaesi
					,WeakAccount
					,PUI
					,FlgFraud
					,FlgRestructure
					,RestructureDate
					,SarfaesiDate
					,FlgUnusualBounce
					,UnusualBounceDate
					,FlgUnClearedEffect
					,UnClearedEffectDate
					,FraudDate
					,WeakAccountDate
				--select SUM(BALANCE)/10000000,  count(1)
				FROM #acdata T Where ISNULL(T.IsChanged,'N') IN ('C','N')
			

				;WITH CTE_Reccount
					AS(	select  @timekey timekey,count(1)NoofAcs_Opt,SUM(BALANCE) Balance_Opt 
							from pro.AccountCal_Hist_new
							where EffectiveFromTimeKey<=@timekey and EffectiveToTimeKey >=@timekey
					  )
					UPDATE  A
						set a.NoofAcs_Opt=b.NoofAcs_Opt
							,a.Balance_Opt=b.Balance_Opt
							,a.Balance_Diff=a.Balance-b.Balance_Opt
							,a.NoofAcs_Diff=a.NoofAcs_Current-b.NoofAcs_Opt
					from  ACCAHIST_TIMEKEY_REC_COUNT a
						inner join CTE_Reccount b
								on a.timekey =b.timekey
		END
		/*  END OF ACCOUNT DATA MERGE */
		SET @RowNo =@RowNo +1
	END
end

GO