SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO








CREATE procedure [PRO].[InsertDataINTOHIST_TABLE_OPT_MOC]
@TIMEKEY int
WITH RECOMPILE
AS
BEGIN

		    UPDATE PRO.CustomerCal SET IsChanged =NULL
			UPDATE PRO.ACCOUNTCAL SET IsChanged =NULL

	
			SELECT A.*, CAST(0 AS BIGINT) EntityKeyNew  INTO #CustomerCal_Moc 
			FROM PRO.CustomerCal_Hist A
				INNER JOIN PRO.CUSTOMERCAL B
					ON A.CustomerEntityID=B.CustomerEntityID
					AND A.EffectiveFromTimeKey<=@TIMEKEY AND A.EffectiveToTimeKey>=@TIMEKEY

			/* EXPIRE RECORDS ARE LIVE FROM PREV EFFECTIVEFROTIMEKEY TO MOC OT GRATER THAN MOC TIMKEY*/
			UPDATE A
				SET A.EffectiveToTimeKey=case when a.EffectiveFromTimeKey<@TIMEKEY  then  @TIMEKEY-1 else @TIMEKEY end
			FROM PRO.CustomerCal_Hist A
				INNER JOIN PRO.CUSTOMERCAL B
					ON A.CustomerEntityID=B.CustomerEntityID
					AND A.EffectiveFromTimeKey<=@TIMEKEY AND A.EffectiveToTimeKey>=@TIMEKEY


			/* UPADTE DATA AVAILABLE ON SAME TMEKEY */
			UPDATE O
				SET
					 BranchCode=T.BranchCode
					,UCIF_ID=T.UCIF_ID
					,UcifEntityID=T.UcifEntityID
					,ParentCustomerID=T.ParentCustomerID
					,RefCustomerID=T.RefCustomerID
					,SourceSystemCustomerID=T.SourceSystemCustomerID
					,CustomerName=T.CustomerName
					,CustSegmentCode=T.CustSegmentCode
					,ConstitutionAlt_Key=T.ConstitutionAlt_Key
					,PANNO=T.PANNO
					,AadharCardNO=T.AadharCardNO
					,SrcAssetClassAlt_Key=T.SrcAssetClassAlt_Key
					,SysAssetClassAlt_Key=T.SysAssetClassAlt_Key
					,SplCatg1Alt_Key=T.SplCatg1Alt_Key
					,SplCatg2Alt_Key=T.SplCatg2Alt_Key
					,SplCatg3Alt_Key=T.SplCatg3Alt_Key
					,SplCatg4Alt_Key=T.SplCatg4Alt_Key
					,SMA_Class_Key=T.SMA_Class_Key
					,PNPA_Class_Key=T.PNPA_Class_Key
					,PrvQtrRV=T.PrvQtrRV
					,CurntQtrRv=T.CurntQtrRv
					,TotProvision=T.TotProvision
					,BankTotProvision=T.BankTotProvision
					,RBITotProvision=T.RBITotProvision
					,SrcNPA_Dt=T.SrcNPA_Dt
					,SysNPA_Dt=T.SysNPA_Dt
					,DbtDt=T.DbtDt
					,DbtDt2=T.DbtDt2
					,DbtDt3=T.DbtDt3
					,LossDt=T.LossDt
					,MOC_Dt=T.MOC_Dt
					,ErosionDt=T.ErosionDt
					,SMA_Dt=T.SMA_Dt
					,PNPA_Dt=T.PNPA_Dt
					,Asset_Norm=T.Asset_Norm
					,FlgDeg=T.FlgDeg
					,FlgUpg=T.FlgUpg
					,FlgMoc=T.FlgMoc
					,FlgSMA=T.FlgSMA
					,FlgProcessing=T.FlgProcessing
					,FlgErosion=T.FlgErosion
					,FlgPNPA=T.FlgPNPA
					,FlgPercolation=T.FlgPercolation
					,FlgInMonth=T.FlgInMonth
					,FlgDirtyRow=T.FlgDirtyRow
					,DegDate=T.DegDate
					,CommonMocTypeAlt_Key=T.CommonMocTypeAlt_Key
					,InMonthMark=T.InMonthMark
					,MocStatusMark=T.MocStatusMark
					,SourceAlt_Key=T.SourceAlt_Key
					,BankAssetClass=T.BankAssetClass
					,Cust_Expo=T.Cust_Expo
					,MOCReason=T.MOCReason
					,AddlProvisionPer=T.AddlProvisionPer
					,FraudDt=T.FraudDt
					,FraudAmount=T.FraudAmount
					,DegReason=T.DegReason
					,CustMoveDescription=T.CustMoveDescription
					,TotOsCust=T.TotOsCust
					,MOCTYPE=T.MOCTYPE
			FROM [PRO].[CustomerCal_Hist] O
				INNER JOIN PRO.CustomerCal T 
					ON O.CustomerEntityId=T.CustomerEntityId 
				WHERE O.EffectiveFromTimeKey=@TimeKey AND O.EffectiveToTimeKey=@TIMEKEY
							


		/* INSERT DATA FOR MOC TIMEKEY - THOSE RECORDS ARE NOT PRESENT ON MIC TIMKEY AFTER EXPIRE */
		/*  New Customers Ac Key ID Update  */
		DECLARE @EntityKeyCust BIGINT=0 
		SELECT @EntityKeyCust=MAX(EntityKey) FROM  [PRO].[CustomerCal_Hist]
		IF @EntityKeyCust IS NULL  
		BEGIN
			SET @EntityKeyCust=0
		END

		UPDATE TEMP 
		SET TEMP.EntityKeyNew=ACCT.EntityKeyNew
		 FROM PRO.CustomerCal TEMP
		INNER JOIN (SELECT CustomerEntityId,(@EntityKeyCust + ROW_NUMBER()OVER(ORDER BY (SELECT 1))) EntityKeyNew
					FROM PRO.CustomerCal ---Where IsChanged in ('C','N')
					)ACCT ON TEMP.CustomerEntityId=ACCT.CustomerEntityId
		--WHERE Temp.IsChanged in ('C','N')

			UPDATE T
			SET  t.IsChanged='Y'
			FROM PRO.CustomerCal T
			LEFT JOIN PRO.CustomerCal_Hist B
					ON B.EffectiveFromTimeKey=@TIMEKEY AND B.EffectiveToTimeKey=@TIMEKEY
					AND B.CustomerEntityId =T.CustomerEntityId
			WHERE B.CustomerEntityId IS NULL
		/***************************************************************************************************************/

			INSERT INTO [PRO].[CustomerCal_Hist]
				(
					 EntityKey
					,BranchCode
					,UCIF_ID
					,UcifEntityID
					,CustomerEntityID
					,ParentCustomerID
					,RefCustomerID
					,SourceSystemCustomerID
					,CustomerName
					,CustSegmentCode
					,ConstitutionAlt_Key
					,PANNO
					,AadharCardNO
					,SrcAssetClassAlt_Key
					,SysAssetClassAlt_Key
					,SplCatg1Alt_Key
					,SplCatg2Alt_Key
					,SplCatg3Alt_Key
					,SplCatg4Alt_Key
					,SMA_Class_Key
					,PNPA_Class_Key
					,PrvQtrRV
					,CurntQtrRv
					,TotProvision
					,BankTotProvision
					,RBITotProvision
					,SrcNPA_Dt
					,SysNPA_Dt
					,DbtDt
					,DbtDt2
					,DbtDt3
					,LossDt
					,MOC_Dt
					,ErosionDt
					,SMA_Dt
					,PNPA_Dt
					,Asset_Norm
					,FlgDeg
					,FlgUpg
					,FlgMoc
					,FlgSMA
					,FlgProcessing
					,FlgErosion
					,FlgPNPA
					,FlgPercolation
					,FlgInMonth
					,FlgDirtyRow
					,DegDate
					,EffectiveFromTimeKey
					,EffectiveToTimeKey
					,CommonMocTypeAlt_Key
					,InMonthMark
					,MocStatusMark
					,SourceAlt_Key
					,BankAssetClass
					,Cust_Expo
					,MOCReason
					,AddlProvisionPer
					,FraudDt
					,FraudAmount
					,DegReason
					,CustMoveDescription
					,TotOsCust
					,MOCTYPE					
				)
				SELECT  
					T.EntityKeyNew
					,T.BranchCode
					,T.UCIF_ID
					,T.UcifEntityID
					,T.CustomerEntityID
					,T.ParentCustomerID
					,T.RefCustomerID
					,T.SourceSystemCustomerID
					,T.CustomerName
					,T.CustSegmentCode
					,T.ConstitutionAlt_Key
					,T.PANNO
					,T.AadharCardNO
					,T.SrcAssetClassAlt_Key
					,T.SysAssetClassAlt_Key
					,T.SplCatg1Alt_Key
					,T.SplCatg2Alt_Key
					,T.SplCatg3Alt_Key
					,T.SplCatg4Alt_Key
					,T.SMA_Class_Key
					,T.PNPA_Class_Key
					,T.PrvQtrRV
					,T.CurntQtrRv
					,T.TotProvision
					,T.BankTotProvision
					,T.RBITotProvision
					,T.SrcNPA_Dt
					,T.SysNPA_Dt
					,T.DbtDt
					,T.DbtDt2
					,T.DbtDt3
					,T.LossDt
					,T.MOC_Dt
					,T.ErosionDt
					,T.SMA_Dt
					,T.PNPA_Dt
					,T.Asset_Norm
					,T.FlgDeg
					,T.FlgUpg
					,T.FlgMoc
					,T.FlgSMA
					,T.FlgProcessing
					,T.FlgErosion
					,T.FlgPNPA
					,T.FlgPercolation
					,T.FlgInMonth
					,T.FlgDirtyRow
					,T.DegDate
					,@TIMEKEY EffectiveFromTimeKey
					,@TIMEKEY EffectiveToTimeKey
					,t.CommonMocTypeAlt_Key
					,t.InMonthMark
					,t.MocStatusMark
					,t.SourceAlt_Key
					,t.BankAssetClass
					,t.Cust_Expo
					,t.MOCReason
					,t.AddlProvisionPer
					,t.FraudDt
					,t.FraudAmount
					,t.DegReason
					,t.CustMoveDescription
					,t.TotOsCust
					,t.MOCTYPE
				FROM PRO.CustomerCal T 
					where t.IsChanged='Y'
					

	/* INSERT RECORD FOR  LIVE AFTE MOC TIMEKEY - IN THIS CASE EFFECTIVEFROMTIMEKEY WILL BE @TIMEKEY+1 AND EFFECTIVETOTIMEKEY WIL BE RMAIL SAME */
		/*  New Customers Ac Key ID Update  */
		DECLARE @EntityKeyCust1 BIGINT=0 
		SELECT @EntityKeyCust1=MAX(EntityKey) FROM  [PRO].[CustomerCal_Hist]
		IF @EntityKeyCust IS NULL  
		BEGIN
			SET @EntityKeyCust1=0
		END

		UPDATE TEMP 
		SET TEMP.EntityKeyNew=ACCT.EntityKeyNew
		 FROM #CustomerCal_Moc TEMP
		INNER JOIN (SELECT CustomerEntityId,(@EntityKeyCust1 + ROW_NUMBER()OVER(ORDER BY (SELECT 1))) EntityKeyNew
					FROM #CustomerCal_Moc ---Where IsChanged in ('C','N')
					)ACCT ON TEMP.CustomerEntityId=ACCT.CustomerEntityId
		--WHERE Temp.IsChanged in ('C','N')

			INSERT INTO [PRO].[CustomerCal_Hist]
				(
					EntityKey
					,BranchCode
					,UCIF_ID
					,UcifEntityID
					,CustomerEntityID
					,ParentCustomerID
					,RefCustomerID
					,SourceSystemCustomerID
					,CustomerName
					,CustSegmentCode
					,ConstitutionAlt_Key
					,PANNO
					,AadharCardNO
					,SrcAssetClassAlt_Key
					,SysAssetClassAlt_Key
					,SplCatg1Alt_Key
					,SplCatg2Alt_Key
					,SplCatg3Alt_Key
					,SplCatg4Alt_Key
					,SMA_Class_Key
					,PNPA_Class_Key
					,PrvQtrRV
					,CurntQtrRv
					,TotProvision
					,BankTotProvision
					,RBITotProvision
					,SrcNPA_Dt
					,SysNPA_Dt
					,DbtDt
					,DbtDt2
					,DbtDt3
					,LossDt
					,MOC_Dt
					,ErosionDt
					,SMA_Dt
					,PNPA_Dt
					,Asset_Norm
					,FlgDeg
					,FlgUpg
					,FlgMoc
					,FlgSMA
					,FlgProcessing
					,FlgErosion
					,FlgPNPA
					,FlgPercolation
					,FlgInMonth
					,FlgDirtyRow
					,DegDate
					,EffectiveFromTimeKey
					,EffectiveToTimeKey
					,CommonMocTypeAlt_Key
					,InMonthMark
					,MocStatusMark
					,SourceAlt_Key
					,BankAssetClass
					,Cust_Expo
					,MOCReason
					,AddlProvisionPer
					,FraudDt
					,FraudAmount
					,DegReason
					,CustMoveDescription
					,TotOsCust
					,MOCTYPE
					--,ChangeFld
					--,ScreenFlag
				)
				SELECT  
					T.EntityKeyNew
					,T.BranchCode
					,T.UCIF_ID
					,T.UcifEntityID
					,T.CustomerEntityID
					,T.ParentCustomerID
					,T.RefCustomerID
					,T.SourceSystemCustomerID
					,T.CustomerName
					,T.CustSegmentCode
					,T.ConstitutionAlt_Key
					,T.PANNO
					,T.AadharCardNO
					,T.SrcAssetClassAlt_Key
					,T.SysAssetClassAlt_Key
					,T.SplCatg1Alt_Key
					,T.SplCatg2Alt_Key
					,T.SplCatg3Alt_Key
					,T.SplCatg4Alt_Key
					,T.SMA_Class_Key
					,T.PNPA_Class_Key
					,T.PrvQtrRV
					,T.CurntQtrRv
					,T.TotProvision
					,T.BankTotProvision
					,T.RBITotProvision
					,T.SrcNPA_Dt
					,T.SysNPA_Dt
					,T.DbtDt
					,T.DbtDt2
					,T.DbtDt3
					,T.LossDt
					,T.MOC_Dt
					,T.ErosionDt
					,T.SMA_Dt
					,T.PNPA_Dt
					,T.Asset_Norm
					,T.FlgDeg
					,T.FlgUpg
					,T.FlgMoc
					,T.FlgSMA
					,T.FlgProcessing
					,T.FlgErosion
					,T.FlgPNPA
					,T.FlgPercolation
					,T.FlgInMonth
					,T.FlgDirtyRow
					,T.DegDate
					,@TIMEKEY+1 EffectiveFromTimeKey
					,T.EffectiveToTimeKey
					,T.CommonMocTypeAlt_Key
					,T.InMonthMark
					,T.MocStatusMark
					,T.SourceAlt_Key
					,T.BankAssetClass
					,T.Cust_Expo
					,T.MOCReason
					,T.AddlProvisionPer
					,T.FraudDt
					,T.FraudAmount
					,T.DegReason
					,T.CustMoveDescription
					,T.TotOsCust
					,T.MOCTYPE
					--,NULL ChangeFld
					--,null ScreenFlag
				FROM #CustomerCal_Moc T 
					WHERE EffectiveToTimeKey>@TIMEKEY



/* ACCOUNT - MOC */
		select A.*, CAST(0 AS BIGINT) EntityKeyNew  INTO #AccountCal_Moc 
			FROM PRO.AccountCal_Hist A
				INNER JOIN PRO.AccountCal B
					ON A.AccountEntityID=B.AccountEntityID
					AND A.EffectiveFromTimeKey<=@TIMEKEY AND A.EffectiveToTimeKey>=@TIMEKEY

			/* EXPIRE RECORDS ARE LIVE FROM PREV EFFECTIVEFROTIMEKEY TO MOC OT GRATER THAN MOC TIMKEY*/
			UPDATE A
				SET A.EffectiveToTimeKey=case when a.EffectiveFromTimeKey <@TIMEKEY then @TIMEKEY -1 else @TIMEKEY end
			FROM PRO.AccountCal_Hist A
				INNER JOIN PRO.AccountCal B
					ON A.AccountEntityID=B.AccountEntityID
					AND A.EffectiveFromTimeKey<=@TIMEKEY AND A.EffectiveToTimeKey>=@TIMEKEY


			/* UPADTE DAT AVAILABLE ON SAME TMEKEY */
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
			FROM [PRO].[AccountCal_Hist] O
				INNER JOIN PRO.ACCOUNTCAL T 
					ON O.AccountEntityID=T.AccountEntityID 
				WHERE O.EffectiveFromTimeKey=@TimeKey AND O.EffectiveToTimeKey=@TIMEKEY
							


		/* INSERT DATA FOR MOC TIMEKEY - THOSE RECORDS ARE NOT PRESENT ON MIC TIMKEY AFTER EXPIRE */
		/*  New Customers Ac Key ID Update  */
		DECLARE @EntityKeyAcct BIGINT=0 
		SELECT @EntityKeyAcct=MAX(EntityKey) FROM  [PRO].[ACCOUNTCal_Hist]
		IF @EntityKeyAcct IS NULL  
		BEGIN
			SET @EntityKeyAcct=0
		END

		UPDATE TEMP 
		SET TEMP.EntityKeyNew=ACCT.EntityKeyNew
		 FROM PRO.ACCOUNTCAL TEMP
		INNER JOIN (SELECT AccountEntityID,(@EntityKeyAcct + ROW_NUMBER()OVER(ORDER BY (SELECT 1))) EntityKeyNew
						FROM PRO.ACCOUNTCAL ---Where IsChanged in ('C','N')
					)ACCT ON TEMP.AccountEntityID=ACCT.AccountEntityID
		--WHERE Temp.IsChanged in ('C','N')


			UPDATE T
			SET  t.IsChanged='Y'
			FROM PRO.ACCOUNTCAL T
			LEFT JOIN PRO.AccountCal_Hist B
					ON B.EffectiveFromTimeKey=@TIMEKEY AND B.EffectiveToTimeKey=@TIMEKEY
					AND B.AccountEntityID =T.AccountEntityID
			WHERE B.AccountEntityID IS NULL


		/***************************************************************************************************************/

				INSERT INTO pro.AccountCal_Hist 
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
					 T.EntityKeyNew
					,T.AccountEntityID
					,T.UcifEntityID
					,T.CustomerEntityID
					,T.CustomerAcID
					,T.RefCustomerID
					,T.SourceSystemCustomerID
					,T.UCIF_ID
					,T.BranchCode
					,T.FacilityType
					,T.AcOpenDt
					,T.FirstDtOfDisb
					,T.ProductAlt_Key
					,T.SchemeAlt_key
					,T.SubSectorAlt_Key
					,T.SplCatg1Alt_Key
					,T.SplCatg2Alt_Key
					,T.SplCatg3Alt_Key
					,T.SplCatg4Alt_Key
					,T.SourceAlt_Key
					,T.ActSegmentCode
					,T.InttRate
					,T.Balance
					,T.BalanceInCrncy
					,T.CurrencyAlt_Key
					,T.DrawingPower
					,T.CurrentLimit
					,T.CurrentLimitDt
					,T.ContiExcessDt
					,T.StockStDt
					,T.DebitSinceDt
					,T.LastCrDate
					,T.InttServiced
					,T.IntNotServicedDt
					,T.OverdueAmt
					,T.OverDueSinceDt
					,T.ReviewDueDt
					,T.SecurityValue
					,T.DFVAmt
					,T.GovtGtyAmt
					,T.CoverGovGur
					,T.WriteOffAmount
					,T.UnAdjSubSidy
					,T.CreditsinceDt
					,T.DegReason
					,T.Asset_Norm
					,T.REFPeriodMax
					,T.RefPeriodOverdue
					,T.RefPeriodOverDrawn
					,T.RefPeriodNoCredit
					,T.RefPeriodIntService
					,T.RefPeriodStkStatement
					,T.RefPeriodReview
					,T.NetBalance
					,T.ApprRV
					,T.SecuredAmt
					,T.UnSecuredAmt
					,T.ProvDFV
					,T.Provsecured
					,T.ProvUnsecured
					,T.ProvCoverGovGur
					,T.AddlProvision
					,T.TotalProvision
					,T.BankProvsecured
					,T.BankProvUnsecured
					,T.BankTotalProvision
					,T.RBIProvsecured
					,T.RBIProvUnsecured
					,T.RBITotalProvision
					,T.InitialNpaDt
					,T.FinalNpaDt
					,T.SMA_Dt
					,T.UpgDate
					,T.InitialAssetClassAlt_Key
					,T.FinalAssetClassAlt_Key
					,T.ProvisionAlt_Key
					,T.PNPA_Reason
					,T.SMA_Class
					,T.SMA_Reason
					,T.FlgMoc
					,T.MOC_Dt
					,T.CommonMocTypeAlt_Key
					,T.FlgDeg
					,T.FlgDirtyRow
					,T.FlgInMonth
					,T.FlgSMA
					,T.FlgPNPA
					,T.FlgUpg
					,T.FlgFITL
					,T.FlgAbinitio
					,T.NPA_Days
					,T.RefPeriodOverdueUPG
					,T.RefPeriodOverDrawnUPG
					,T.RefPeriodNoCreditUPG
					,T.RefPeriodIntServiceUPG
					,T.RefPeriodStkStatementUPG
					,T.RefPeriodReviewUPG
					,@TimeKey EffectiveFromTimeKey
					,@TimeKey  EffectiveToTimeKey
					,T.AppGovGur
					,T.UsedRV
					,T.ComputedClaim
					,T.UPG_RELAX_MSME
					,T.DEG_RELAX_MSME
					,T.PNPA_DATE
					,T.NPA_Reason
					,T.PnpaAssetClassAlt_key
					,T.DisbAmount
					,T.PrincOutStd
					,T.PrincOverdue
					,T.PrincOverdueSinceDt
					,T.IntOverdue
					,T.IntOverdueSinceDt
					,T.OtherOverdue
					,T.OtherOverdueSinceDt
					,T.RelationshipNumber
					,T.AccountFlag
					,T.CommercialFlag_AltKey
					,T.Liability
					,T.CD
					,T.AccountStatus
					,T.AccountBlkCode1
					,T.AccountBlkCode2
					,T.ExposureType
					,T.Mtm_Value
					,T.BankAssetClass
					,T.NpaType
					,T.SecApp
					,T.BorrowerTypeID
					,T.LineCode
					,T.ProvPerSecured
					,T.ProvPerUnSecured
					,T.MOCReason
					,T.AddlProvisionPer
					,T.FlgINFRA
					,T.RepossessionDate
					,T.DerecognisedInterest1
					,T.DerecognisedInterest2
					,T.ProductCode
					,T.FlgLCBG
					,T.unserviedint
					,T.PreQtrCredit
					,T.PrvQtrInt
					,T.CurQtrCredit
					,T.CurQtrInt
					,T.OriginalBranchcode
					,T.AdvanceRecovery
					,T.NotionalInttAmt
					,T.PrvAssetClassAlt_Key
					,T.MOCTYPE
					,T.FlgSecured
					,T.RePossession
					,T.RCPending
					,T.PaymentPending
					,T.WheelCase
					,T.CustomerLevelMaxPer
					,T.FinalProvisionPer
					,T.IsIBPC
					,T.IsSecuritised
					,T.RFA
					,T.IsNonCooperative
					,T.Sarfaesi
					,T.WeakAccount
					,T.PUI
					,T.FlgFraud
					,T.FlgRestructure
					,T.RestructureDate
					,T.SarfaesiDate
					,T.FlgUnusualBounce
					,T.UnusualBounceDate
					,T.FlgUnClearedEffect
					,T.UnClearedEffectDate
					,T.FraudDate
					,T.WeakAccountDate
				--select SUM(BALANCE)/10000000,  count(1)
				FROM PRO.ACCOUNTCAL T
				 WHERE T.ISCHANGED='Y'


	/* INSERT RECORD FOR  LIVE AFTE MOC TIMEKEY - IN THIS CASE EFFECTIVEFROMTIMEKEY WILL BE @TIMEKEY+1 AND EFFECTIVETOTIMEKEY WIL BE RMAIL SAME */
		/*  New Customers Ac Key ID Update  */
		DECLARE @EntityKeyAcct1 BIGINT=0 
		SELECT @EntityKeyAcct1=MAX(EntityKey) FROM  [PRO].[AccountCal_Hist]
		IF @EntityKeyAcct1 IS NULL  
		BEGIN
			SET @EntityKeyAcct1=0
		END

		UPDATE TEMP 
		SET TEMP.EntityKeyNew=ACCT.EntityKeyNew
		 FROM #AccountCal_Moc TEMP
		INNER JOIN (SELECT AccountEntityID,(@EntityKeyAcct1 + ROW_NUMBER()OVER(ORDER BY (SELECT 1))) EntityKeyNew
					FROM #AccountCal_Moc ---Where IsChanged in ('C','N')
					)ACCT ON TEMP.AccountEntityID=ACCT.AccountEntityID
		--WHERE Temp.IsChanged in ('C','N')

		
		

		INSERT INTO [PRO].[AccountCal_Hist]
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
					,ScreenFlag
					,ChangeField
				)
				SELECT  
					 T.EntityKeyNew
					,T.AccountEntityID
					,T.UcifEntityID
					,T.CustomerEntityID
					,T.CustomerAcID
					,T.RefCustomerID
					,T.SourceSystemCustomerID
					,T.UCIF_ID
					,T.BranchCode
					,T.FacilityType
					,T.AcOpenDt
					,T.FirstDtOfDisb
					,T.ProductAlt_Key
					,T.SchemeAlt_key
					,T.SubSectorAlt_Key
					,T.SplCatg1Alt_Key
					,T.SplCatg2Alt_Key
					,T.SplCatg3Alt_Key
					,T.SplCatg4Alt_Key
					,T.SourceAlt_Key
					,T.ActSegmentCode
					,T.InttRate
					,T.Balance
					,T.BalanceInCrncy
					,T.CurrencyAlt_Key
					,T.DrawingPower
					,T.CurrentLimit
					,T.CurrentLimitDt
					,T.ContiExcessDt
					,T.StockStDt
					,T.DebitSinceDt
					,T.LastCrDate
					,T.InttServiced
					,T.IntNotServicedDt
					,T.OverdueAmt
					,T.OverDueSinceDt
					,T.ReviewDueDt
					,T.SecurityValue
					,T.DFVAmt
					,T.GovtGtyAmt
					,T.CoverGovGur
					,T.WriteOffAmount
					,T.UnAdjSubSidy
					,T.CreditsinceDt
					,T.DegReason
					,T.Asset_Norm
					,T.REFPeriodMax
					,T.RefPeriodOverdue
					,T.RefPeriodOverDrawn
					,T.RefPeriodNoCredit
					,T.RefPeriodIntService
					,T.RefPeriodStkStatement
					,T.RefPeriodReview
					,T.NetBalance
					,T.ApprRV
					,T.SecuredAmt
					,T.UnSecuredAmt
					,T.ProvDFV
					,T.Provsecured
					,T.ProvUnsecured
					,T.ProvCoverGovGur
					,T.AddlProvision
					,T.TotalProvision
					,T.BankProvsecured
					,T.BankProvUnsecured
					,T.BankTotalProvision
					,T.RBIProvsecured
					,T.RBIProvUnsecured
					,T.RBITotalProvision
					,T.InitialNpaDt
					,T.FinalNpaDt
					,T.SMA_Dt
					,T.UpgDate
					,T.InitialAssetClassAlt_Key
					,T.FinalAssetClassAlt_Key
					,T.ProvisionAlt_Key
					,T.PNPA_Reason
					,T.SMA_Class
					,T.SMA_Reason
					,T.FlgMoc
					,T.MOC_Dt
					,T.CommonMocTypeAlt_Key
					,T.FlgDeg
					,T.FlgDirtyRow
					,T.FlgInMonth
					,T.FlgSMA
					,T.FlgPNPA
					,T.FlgUpg
					,T.FlgFITL
					,T.FlgAbinitio
					,T.NPA_Days
					,T.RefPeriodOverdueUPG
					,T.RefPeriodOverDrawnUPG
					,T.RefPeriodNoCreditUPG
					,T.RefPeriodIntServiceUPG
					,T.RefPeriodStkStatementUPG
					,T.RefPeriodReviewUPG
					,@TimeKey+1 EffectiveFromTimeKey
					,EffectiveToTimeKey
					,T.AppGovGur
					,T.UsedRV
					,T.ComputedClaim
					,T.UPG_RELAX_MSME
					,T.DEG_RELAX_MSME
					,T.PNPA_DATE
					,T.NPA_Reason
					,T.PnpaAssetClassAlt_key
					,T.DisbAmount
					,T.PrincOutStd
					,T.PrincOverdue
					,T.PrincOverdueSinceDt
					,T.IntOverdue
					,T.IntOverdueSinceDt
					,T.OtherOverdue
					,T.OtherOverdueSinceDt
					,T.RelationshipNumber
					,T.AccountFlag
					,T.CommercialFlag_AltKey
					,T.Liability
					,T.CD
					,T.AccountStatus
					,T.AccountBlkCode1
					,T.AccountBlkCode2
					,T.ExposureType
					,T.Mtm_Value
					,T.BankAssetClass
					,T.NpaType
					,T.SecApp
					,T.BorrowerTypeID
					,T.LineCode
					,T.ProvPerSecured
					,T.ProvPerUnSecured
					,T.MOCReason
					,T.AddlProvisionPer
					,T.FlgINFRA
					,T.RepossessionDate
					,T.DerecognisedInterest1
					,T.DerecognisedInterest2
					,T.ProductCode
					,T.FlgLCBG
					,T.unserviedint
					,T.PreQtrCredit
					,T.PrvQtrInt
					,T.CurQtrCredit
					,T.CurQtrInt
					,T.OriginalBranchcode
					,T.AdvanceRecovery
					,T.NotionalInttAmt
					,T.PrvAssetClassAlt_Key
					,T.MOCTYPE
					,T.FlgSecured
					,T.RePossession
					,T.RCPending
					,T.PaymentPending
					,T.WheelCase
					,T.CustomerLevelMaxPer
					,T.FinalProvisionPer
					,T.IsIBPC
					,T.IsSecuritised
					,T.RFA
					,T.IsNonCooperative
					,T.Sarfaesi
					,T.WeakAccount
					,T.PUI
					,T.FlgFraud
					,T.FlgRestructure
					,T.RestructureDate
					,T.SarfaesiDate
					,T.FlgUnusualBounce
					,T.UnusualBounceDate
					,T.FlgUnClearedEffect
					,T.UnClearedEffectDate
					,T.FraudDate
					,T.WeakAccountDate
					,null ScreenFlag
					,null ChangeField
				FROM #AccountCal_Moc T 
					WHERE EffectiveToTimeKey>@TIMEKEY

UPDATE PRO.ACLRUNNINGPROCESSSTATUS 
	SET COMPLETED='Y',ERRORDATE=NULL,ERRORDESCRIPTION=NULL,COUNT=ISNULL(COUNT,0)+1
	WHERE RUNNINGPROCESSNAME='InsertDataIntoHistTable' 
END




GO