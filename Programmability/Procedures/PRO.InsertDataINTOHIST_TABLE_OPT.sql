SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO








CREATE procedure [PRO].[InsertDataINTOHIST_TABLE_OPT]
 @TIMEKEY int=26959
with recompile
as
begin try
begin
		IF EXISTS(SELECT 1 FROM PRO.AccountCal_Hist WHERE EffectiveFromTimeKey>@TIMEKEY)
			BEGIN
				 RAISERROR ('Data processed for wrong date, Please check....',16,1)
			END

	DECLARE @VEFFECTIVETO INT=@TIMEKEY-1
  
/* CUSTOMER CAL HIST MERGE */

  			UPDATE T
				SET T.IsChanged='E'
			FROM [PRO].[CustomerCal_Hist] AS O
			INNER JOIN PRO.CustomerCal AS T
				ON O.CustomerEntityId=T.CustomerEntityId
				AND O.EffectiveToTimeKey=49999

			UPDATE T 
				SET T.IsChanged='C'
			FROM [PRO].[CustomerCal_Hist] AS O
			INNER JOIN PRO.CustomerCal AS T
				ON O.CustomerEntityId=T.CustomerEntityId
				AND O.EffectiveToTimeKey=49999
				WHERE (     
						ISNULL(O.BranchCode,'')<>ISNULL(T.BranchCode,'')
					OR ISNULL(O.UCIF_ID,'')<>ISNULL(T.UCIF_ID,'')
					OR ISNULL(O.UcifEntityID,0)<>ISNULL(T.UcifEntityID,0)
					OR ISNULL(O.CustomerEntityID,0)<>ISNULL(T.CustomerEntityID,0)
					OR ISNULL(O.ParentCustomerID,'')<>ISNULL(T.ParentCustomerID,'')
					OR ISNULL(O.RefCustomerID,'')<>ISNULL(T.RefCustomerID,'')
					OR ISNULL(O.SourceSystemCustomerID,'')<>ISNULL(T.SourceSystemCustomerID,'')
					OR ISNULL(O.CustomerName,'')<>ISNULL(T.CustomerName,'')
					OR ISNULL(O.CustSegmentCode,'')<>ISNULL(T.CustSegmentCode,'')
					OR ISNULL(O.ConstitutionAlt_Key,0)<>ISNULL(T.ConstitutionAlt_Key,0)
					OR ISNULL(O.PANNO,'')<>ISNULL(T.PANNO,'')
					OR ISNULL(O.AadharCardNO,'')<>ISNULL(T.AadharCardNO,'')
					OR ISNULL(O.SrcAssetClassAlt_Key,0)<>ISNULL(T.SrcAssetClassAlt_Key,0)
					OR ISNULL(O.SysAssetClassAlt_Key,0)<>ISNULL(T.SysAssetClassAlt_Key,0)
					OR ISNULL(O.SplCatg1Alt_Key,0)<>ISNULL(T.SplCatg1Alt_Key,0)
					OR ISNULL(O.SplCatg2Alt_Key,0)<>ISNULL(T.SplCatg2Alt_Key,0)
					OR ISNULL(O.SplCatg3Alt_Key,0)<>ISNULL(T.SplCatg3Alt_Key,0)
					OR ISNULL(O.SplCatg4Alt_Key,0)<>ISNULL(T.SplCatg4Alt_Key,0)
					OR ISNULL(O.SMA_Class_Key,0)<>ISNULL(T.SMA_Class_Key,0)
					OR ISNULL(O.PNPA_Class_Key,0)<>ISNULL(T.PNPA_Class_Key,0)
					OR ISNULL(O.PrvQtrRV,0)<>ISNULL(T.PrvQtrRV,0)
					OR ISNULL(O.CurntQtrRv,0)<>ISNULL(T.CurntQtrRv,0)
					OR ISNULL(O.TotProvision,0)<>ISNULL(T.TotProvision,0)
					OR ISNULL(O.BankTotProvision,0)<>ISNULL(T.BankTotProvision,0)
					OR ISNULL(O.RBITotProvision,0)<>ISNULL(T.RBITotProvision,0)
					OR ISNULL(O.SrcNPA_Dt,'1900-01-01')<>ISNULL(T.SrcNPA_Dt,'1900-01-01')
					OR ISNULL(O.SysNPA_Dt,'1900-01-01')<>ISNULL(T.SysNPA_Dt,'1900-01-01')
					OR ISNULL(O.DbtDt,'1900-01-01')<>ISNULL(T.DbtDt,'1900-01-01')
					OR ISNULL(O.DbtDt2,'1900-01-01')<>ISNULL(T.DbtDt2,'1900-01-01')
					OR ISNULL(O.DbtDt3,'1900-01-01')<>ISNULL(T.DbtDt3,'1900-01-01')
					OR ISNULL(O.LossDt,'1900-01-01')<>ISNULL(T.LossDt,'1900-01-01')
					OR ISNULL(O.MOC_Dt,'1900-01-01')<>ISNULL(T.MOC_Dt,'1900-01-01')
					OR ISNULL(O.ErosionDt,'1900-01-01')<>ISNULL(T.ErosionDt,'1900-01-01')
					OR ISNULL(O.SMA_Dt,'1900-01-01')<>ISNULL(T.SMA_Dt,'1900-01-01')
					OR ISNULL(O.PNPA_Dt,'1900-01-01')<>ISNULL(T.PNPA_Dt,'1900-01-01')
					OR ISNULL(O.Asset_Norm,'')<>ISNULL(T.Asset_Norm,'')
					OR ISNULL(O.FlgDeg,'')<>ISNULL(T.FlgDeg,'')
					OR ISNULL(O.FlgUpg,'')<>ISNULL(T.FlgUpg,'')
					OR ISNULL(O.FlgMoc,'')<>ISNULL(T.FlgMoc,'')
					OR ISNULL(O.FlgSMA,'')<>ISNULL(T.FlgSMA,'')
					OR ISNULL(O.FlgProcessing,'')<>ISNULL(T.FlgProcessing,'')
					OR ISNULL(O.FlgErosion,'')<>ISNULL(T.FlgErosion,'')
					OR ISNULL(O.FlgPNPA,'')<>ISNULL(T.FlgPNPA,'')
					OR ISNULL(O.FlgPercolation,'')<>ISNULL(T.FlgPercolation,'')
					OR ISNULL(O.FlgInMonth,'')<>ISNULL(T.FlgInMonth,'')
					OR ISNULL(O.FlgDirtyRow,'')<>ISNULL(T.FlgDirtyRow,'')
					OR ISNULL(O.DegDate,'1900-01-01')<>ISNULL(T.DegDate,'1900-01-01')
					OR ISNULL(O.CommonMocTypeAlt_Key,0)<>ISNULL(T.CommonMocTypeAlt_Key,0)
					OR ISNULL(O.InMonthMark,'')<>ISNULL(T.InMonthMark,'')
					OR ISNULL(O.MocStatusMark,'')<>ISNULL(T.MocStatusMark,'')
					OR ISNULL(O.SourceAlt_Key,0)<>ISNULL(T.SourceAlt_Key,0)
					OR ISNULL(O.BankAssetClass,'')<>ISNULL(T.BankAssetClass,'')
					OR ISNULL(O.Cust_Expo,0)<>ISNULL(T.Cust_Expo,0)
					OR ISNULL(O.MOCReason,'')<>ISNULL(T.MOCReason,'')
					OR ISNULL(O.AddlProvisionPer,0)<>ISNULL(T.AddlProvisionPer,0)
					OR ISNULL(O.FraudDt,'1900-01-01')<>ISNULL(T.FraudDt,'1900-01-01')
					OR ISNULL(O.FraudAmount,0)<>ISNULL(T.FraudAmount,0)
					OR ISNULL(O.DegReason,'')<>ISNULL(T.DegReason,'')
					OR ISNULL(O.CustMoveDescription,'')<>ISNULL(T.CustMoveDescription,'')
					OR ISNULL(O.TotOsCust,0)<>ISNULL(T.TotOsCust,0)
					OR ISNULL(O.MOCTYPE,'')<>ISNULL(T.MOCTYPE,'')
				)

			UPDATE A SET 
				A.IsChanged='U'
			from PRO.CustomerCal A
			INNER JOIN [PRO].[CustomerCal_Hist] B 
			ON B.CustomerEntityId=A.CustomerEntityId 
			Where B.EffectiveFromTimeKey= @TimeKey
				and A.IsChanged='C'

			----------For Changes Records
			UPDATE b SET 
				b.EffectiveToTimeKey=@VEFFECTIVETO
			from PRO.CustomerCal A
				INNER JOIN [PRO].[CustomerCal_Hist] B 
				ON B.CustomerEntityId=A.CustomerEntityId 
				AND B.EffectiveToTimeKey=49999	
			Where B.EffectiveFromTimeKey<@TimeKey
				and A.IsChanged='C'
		
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
				WHERE O.EffectiveFromTimeKey=@TimeKey
					AND T.IsChanged='U'

		----------------------------------------------------------------------------------------------------------------------------------------------

		UPDATE AA
		SET 
			EffectiveToTimeKey = @VEFFECTIVETO
		FROM [PRO].[CustomerCal_Hist] AA
		WHERE AA.EffectiveToTimeKey = 49999
		AND NOT EXISTS (SELECT 1 FROM PRO.CustomerCal BB
							WHERE AA.CustomerEntityId=BB.CustomerEntityId 
						)

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
					FROM PRO.CustomerCal Where IsChanged in ('C','N')
					)ACCT ON TEMP.CustomerEntityId=ACCT.CustomerEntityId
		WHERE Temp.IsChanged in ('C','N')

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
					,ScreenFlag
					,MOCProcessed
				)
				SELECT  
					EntityKeyNew
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
					,49999 EffectiveToTimeKey
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
					,Null
					,Null
					
				FROM PRO.CustomerCal T Where ISNULL(T.IsChanged,'N') IN('C','N')



/* ACCOUNT CAL HIST MERGE */
			UPDATE T
				SET T.IsChanged='E'
			FROM [PRO].[AccountCal_Hist] AS O
			INNER JOIN PRO.ACCOUNTCAL AS T
				ON O.AccountEntityID=T.AccountEntityID
				AND O.EffectiveToTimeKey=49999

			UPDATE T 
				SET T.IsChanged='C'
			FROM [PRO].[AccountCal_Hist] AS O
			INNER JOIN PRO.ACCOUNTCAL AS T
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
			from PRO.ACCOUNTCAL A
			INNER JOIN [PRO].[AccountCal_Hist] B 
			ON B.AccountEntityID=A.AccountEntityID 
			Where B.EffectiveFromTimeKey= @TimeKey
				and A.IsChanged='C'

			----------For Changes Records
			UPDATE b SET 
				b.EffectiveToTimeKey=@VEFFECTIVETO
			from PRO.ACCOUNTCAL A
				INNER JOIN [PRO].[AccountCal_Hist] B 
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
			FROM [PRO].[AccountCal_Hist] O
				INNER JOIN PRO.ACCOUNTCAL T 
					ON O.AccountEntityID=T.AccountEntityID 
				WHERE O.EffectiveFromTimeKey=@TimeKey
					AND T.IsChanged='U'

		----------------------------------------------------------------------------------------------------------------------------------------------

		UPDATE AA
		SET 
			EffectiveToTimeKey = @VEFFECTIVETO
		FROM pro.AccountCal_Hist AA
		WHERE AA.EffectiveToTimeKey = 49999
		AND NOT EXISTS (SELECT 1 FROM PRO.ACCOUNTCAL BB
							WHERE AA.AccountEntityID=BB.AccountEntityID 
						)

		/*  New Customers Ac Key ID Update  */
		DECLARE @EntityKeyAc BIGINT=0 
		SELECT @EntityKeyAc=MAX(EntityKey) FROM  [PRO].[AccountCal_Hist]
		IF @EntityKeyAc IS NULL  
		BEGIN
			SET @EntityKeyAc=0
		END

		UPDATE TEMP 
		SET TEMP.EntityKeyNew=ACCT.EntityKeyNew
		 FROM PRO.ACCOUNTCAL TEMP
		INNER JOIN (SELECT AccountEntityId,(@EntityKeyAc + ROW_NUMBER()OVER(ORDER BY (SELECT 1))) EntityKeyNew
					FROM PRO.ACCOUNTCAL Where IsChanged in ('C','N')
					)ACCT ON TEMP.AccountEntityId=ACCT.AccountEntityId
		WHERE Temp.IsChanged in ('C','N')

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
				FROM PRO.ACCOUNTCAL T Where ISNULL(T.IsChanged,'N') IN ('C','N')


	/* MERGE DATA INTO MAIN ADVANCE TABLE */
	exec [PRO].CustAccountMerge



/* RESTRUCTURE WORK */
 			UPDATE T
				SET T.IsChanged='E'
			FROM [PRO].[AdvAcRestructureCal_Hist] AS O
			INNER JOIN PRO.AdvAcRestructureCal AS T
				ON O.AccountEntityId=T.AccountEntityId
				AND O.EffectiveToTimeKey=49999

			UPDATE T 
				SET T.IsChanged='C'
			FROM [PRO].[AdvAcRestructureCal_Hist] AS O
			INNER JOIN [PRO].[AdvAcRestructureCal] AS T
				ON O.AccountEntityId=T.AccountEntityId
				AND O.EffectiveToTimeKey=49999
				WHERE (     
					    ISNULL(O.AssetClassAlt_KeyOnInvocation,0)<>ISNULL(T.AssetClassAlt_KeyOnInvocation,0)
						OR ISNULL(O.PreRestructureAssetClassAlt_Key,0)<>ISNULL(T.PreRestructureAssetClassAlt_Key,0)
						OR ISNULL(O.PreRestructureNPA_Date,'1900-01-01')<>ISNULL(T.PreRestructureNPA_Date,'1900-01-01')
						OR ISNULL(O.ProvPerOnRestrucure,0)<>ISNULL(T.ProvPerOnRestrucure,0)
						OR ISNULL(O.RestructureTypeAlt_Key,0)<>ISNULL(T.RestructureTypeAlt_Key,0)
						OR ISNULL(O.COVID_OTR_CatgAlt_Key,0)<>ISNULL(T.COVID_OTR_CatgAlt_Key,0)
						OR ISNULL(O.RestructureDt,'1900-01-01')<>ISNULL(T.RestructureDt,'1900-01-01')
						OR ISNULL(O.SP_ExpiryDate,'1900-01-01')<>ISNULL(T.SP_ExpiryDate,'1900-01-01')
						OR ISNULL(O.DPD_AsOnRestructure,0)<>ISNULL(T.DPD_AsOnRestructure,0)
						OR ISNULL(O.RestructureFailureDate,'1900-01-01')<>ISNULL(T.RestructureFailureDate,'1900-01-01')
						OR ISNULL(O.DPD_Breach_Date,'1900-01-01')<>ISNULL(T.DPD_Breach_Date,'1900-01-01')
						OR ISNULL(O.ZeroDPD_Date,'1900-01-01')<>ISNULL(T.ZeroDPD_Date,'1900-01-01')
						OR ISNULL(O.SP_ExpiryExtendedDate,'1900-01-01')<>ISNULL(T.SP_ExpiryExtendedDate,'1900-01-01')
						OR ISNULL(O.CurrentPOS,0)<>ISNULL(T.CurrentPOS,0)
						OR ISNULL(O.CurrentTOS,0)<>ISNULL(T.CurrentTOS,0)
						OR ISNULL(O.RestructurePOS,0)<>ISNULL(T.RestructurePOS,0)
						OR ISNULL(O.Res_POS_to_CurrentPOS_Per,0)<>ISNULL(T.Res_POS_to_CurrentPOS_Per,0)
						OR ISNULL(O.CurrentDPD,0)<>ISNULL(T.CurrentDPD,0)
						OR ISNULL(O.TotalDPD,0)<>ISNULL(T.TotalDPD,0)
						OR ISNULL(O.VDPD,0)<>ISNULL(T.VDPD,0)
						OR ISNULL(O.AddlProvPer,0)<>ISNULL(T.AddlProvPer,0)
						OR ISNULL(O.ProvReleasePer,0)<>ISNULL(T.ProvReleasePer,0)
						OR ISNULL(O.AppliedNormalProvPer,0)<>ISNULL(T.AppliedNormalProvPer,0)
						OR ISNULL(O.FinalProvPer,0)<>ISNULL(T.FinalProvPer,0)
						OR ISNULL(O.PreDegProvPer,0)<>ISNULL(T.PreDegProvPer,0)
						OR ISNULL(O.UpgradeDate,'1900-01-01')<>ISNULL(T.UpgradeDate,'1900-01-01')
						OR ISNULL(O.SurvPeriodEndDate,'1900-01-01')<>ISNULL(T.SurvPeriodEndDate,'1900-01-01')
						OR ISNULL(O.DegDurSP_PeriodProvPer,0)<>ISNULL(T.DegDurSP_PeriodProvPer,0)
						OR ISNULL(O.NonFinDPD,0)<>ISNULL(T.NonFinDPD,0)
						OR ISNULL(O.InitialAssetClassAlt_Key,0)<>ISNULL(T.InitialAssetClassAlt_Key,0)
						OR ISNULL(O.FinalAssetClassAlt_Key,0)<>ISNULL(T.FinalAssetClassAlt_Key,0)
						OR ISNULL(O.RestructureProvision,0)<>ISNULL(T.RestructureProvision,0)
						OR ISNULL(O.SecuredProvision,0)<>ISNULL(T.SecuredProvision,0)
						OR ISNULL(O.UnSecuredProvision,0)<>ISNULL(T.UnSecuredProvision,0)
						OR ISNULL(O.FlgDeg,'')<>ISNULL(T.FlgDeg,'')
						OR ISNULL(O.FlgUpg,'')<>ISNULL(T.FlgUpg,'')
						OR ISNULL(O.DegDate,'1900-01-01')<>ISNULL(T.DegDate,'1900-01-01')
						OR ISNULL(O.RC_Pending,'')<>ISNULL(T.RC_Pending,'')
						OR ISNULL(O.FinalNpaDt,'1900-01-01')<>ISNULL(T.FinalNpaDt,'1900-01-01')
						OR ISNULL(O.RestructureStage,'')<>ISNULL(T.RestructureStage,'')
						OR ISNULL(O.DegReason,'')<>ISNULL(T.DegReason,'')
						OR ISNULL(O.InvestmentGrade,'')<>ISNULL(T.InvestmentGrade,'')
						OR ISNULL(O.PreRestructureNPA_Prov,0)<>ISNULL(T.PreRestructureNPA_Prov,0)
						OR ISNULL(O.FlgMorat,'')<>ISNULL(T.FlgMorat,'')
						OR ISNULL(O.POS_10PerPaidDate,'1900-01-01')<>ISNULL(T.POS_10PerPaidDate,'1900-01-01')
					)

			UPDATE A SET 
				A.IsChanged='U'
			FROM PRO.AdvAcRestructureCal A
			INNER JOIN [PRO].[AdvAcRestructureCal_Hist] B 
				ON B.AccountEntityId=A.AccountEntityId 
			WHERE B.EffectiveFromTimeKey= @TimeKey
				and A.IsChanged='C'

			----------For Changes Records
			UPDATE b SET 
				b.EffectiveToTimeKey=@VEFFECTIVETO
			from PRO.AdvAcRestructureCal A
				INNER JOIN [PRO].[AdvAcRestructureCal_Hist] B 
				ON B.AccountEntityId=A.AccountEntityId 
				AND B.EffectiveToTimeKey=49999	
			Where B.EffectiveFromTimeKey<@TimeKey
				and A.IsChanged='C'
		
			UPDATE O
				SET
						AssetClassAlt_KeyOnInvocation=T.AssetClassAlt_KeyOnInvocation
						,PreRestructureAssetClassAlt_Key=T.PreRestructureAssetClassAlt_Key
						,PreRestructureNPA_Date=T.PreRestructureNPA_Date
						,ProvPerOnRestrucure=T.ProvPerOnRestrucure
						,RestructureTypeAlt_Key=T.RestructureTypeAlt_Key
						,COVID_OTR_CatgAlt_Key=T.COVID_OTR_CatgAlt_Key
						,RestructureDt=T.RestructureDt
						,SP_ExpiryDate=T.SP_ExpiryDate
						,DPD_AsOnRestructure=T.DPD_AsOnRestructure
						,RestructureFailureDate=T.RestructureFailureDate
						,DPD_Breach_Date=T.DPD_Breach_Date
						,ZeroDPD_Date=T.ZeroDPD_Date
						,SP_ExpiryExtendedDate=T.SP_ExpiryExtendedDate
						,CurrentPOS=T.CurrentPOS
						,CurrentTOS=T.CurrentTOS
						,RestructurePOS=T.RestructurePOS
						,Res_POS_to_CurrentPOS_Per=T.Res_POS_to_CurrentPOS_Per
						,CurrentDPD=T.CurrentDPD
						,TotalDPD=T.TotalDPD
						,VDPD=T.VDPD
						,AddlProvPer=T.AddlProvPer
						,ProvReleasePer=T.ProvReleasePer
						,AppliedNormalProvPer=T.AppliedNormalProvPer
						,FinalProvPer=T.FinalProvPer
						,PreDegProvPer=T.PreDegProvPer
						,UpgradeDate=T.UpgradeDate
						,SurvPeriodEndDate=T.SurvPeriodEndDate
						,DegDurSP_PeriodProvPer=T.DegDurSP_PeriodProvPer
						,NonFinDPD=T.NonFinDPD
						,InitialAssetClassAlt_Key=T.InitialAssetClassAlt_Key
						,FinalAssetClassAlt_Key=T.FinalAssetClassAlt_Key
						,RestructureProvision=T.RestructureProvision
						,SecuredProvision=T.SecuredProvision
						,UnSecuredProvision=T.UnSecuredProvision
						,FlgDeg=T.FlgDeg
						,FlgUpg=T.FlgUpg
						,DegDate=T.DegDate
						,RC_Pending=T.RC_Pending
						,FinalNpaDt=T.FinalNpaDt
						,RestructureStage=T.RestructureStage
						,DegReason=T.DegReason
						,InvestmentGrade=T.InvestmentGrade
						,PreRestructureNPA_Prov=T.PreRestructureNPA_Prov
						,FlgMorat=T.FlgMorat
						,POS_10PerPaidDate=T.POS_10PerPaidDate
			FROM PRO.AdvAcRestructureCal_Hist O
				INNER JOIN PRO.AdvAcRestructureCal T 
					ON O.AccountEntityId=T.AccountEntityId 
				WHERE O.EffectiveFromTimeKey=@TimeKey
					AND T.IsChanged='U'

		----------------------------------------------------------------------------------------------------------------------------------------------

		UPDATE AA
		SET 
			EffectiveToTimeKey = @VEFFECTIVETO
		FROM PRO.AdvAcRestructureCal_Hist AA
		WHERE AA.EffectiveToTimeKey = 49999
		AND NOT EXISTS (SELECT 1 FROM PRO.AdvAcRestructureCal BB
							WHERE AA.AccountEntityId=BB.AccountEntityId 
						)

		----/*  New Customers Ac Key ID Update  */
		----DECLARE @EntityKeyRestr BIGINT=0 
		----SELECT @EntityKeyRestr=MAX(EntityKey) FROM  PRO.AdvAcRestructureCal_Hist
		----IF @EntityKeyRestr IS NULL  
		----BEGIN
		----	SET @EntityKeyCust=0
		----END

		----UPDATE TEMP 
		----SET TEMP.EntityKeyNew=ACCT.EntityKeyNew
		---- FROM PRO.AdvAcRestructureCal TEMP
		----INNER JOIN (SELECT AccountEntityId,(@EntityKeyRestr + ROW_NUMBER()OVER(ORDER BY (SELECT 1))) EntityKeyNew
		----			FROM PRO.AdvAcRestructureCal Where IsChanged in ('C','N')
		----			)ACCT ON TEMP.AccountEntityId=ACCT.AccountEntityId
		----WHERE Temp.IsChanged in ('C','N')

		/***************************************************************************************************************/

			INSERT INTO PRO.AdvAcRestructureCal_Hist
				(
					--EntityKey
					--,
					AccountEntityId
					,AssetClassAlt_KeyOnInvocation
					,PreRestructureAssetClassAlt_Key
					,PreRestructureNPA_Date
					,ProvPerOnRestrucure
					,RestructureTypeAlt_Key
					,COVID_OTR_CatgAlt_Key
					,RestructureDt
					,SP_ExpiryDate
					,DPD_AsOnRestructure
					,RestructureFailureDate
					,DPD_Breach_Date
					,ZeroDPD_Date
					,SP_ExpiryExtendedDate
					,CurrentPOS
					,CurrentTOS
					,RestructurePOS
					,Res_POS_to_CurrentPOS_Per
					,CurrentDPD
					,TotalDPD
					,VDPD
					,AddlProvPer
					,ProvReleasePer
					,AppliedNormalProvPer
					,FinalProvPer
					,PreDegProvPer
					,UpgradeDate
					,SurvPeriodEndDate
					--------,DegDurSP_PeriodProvPer
					,NonFinDPD
					,InitialAssetClassAlt_Key
					,FinalAssetClassAlt_Key
					,RestructureProvision
					,SecuredProvision
					,UnSecuredProvision
					,FlgDeg
					,FlgUpg
					,DegDate
					,RC_Pending
					,FinalNpaDt
					,RestructureStage
					,EffectiveFromTimeKey
					,EffectiveToTimeKey
					,FlgMorat
					,InvestmentGrade
					,POS_10PerPaidDate
					,RestructureFacilityTypeAlt_Key
				)
			SELECT
					--EntityKeyNew
					--,
					AccountEntityId
					,AssetClassAlt_KeyOnInvocation
					,PreRestructureAssetClassAlt_Key
					,PreRestructureNPA_Date
					,ProvPerOnRestrucure
					,RestructureTypeAlt_Key
					,COVID_OTR_CatgAlt_Key
					,RestructureDt
					,SP_ExpiryDate
					,DPD_AsOnRestructure
					,RestructureFailureDate
					,DPD_Breach_Date
					,ZeroDPD_Date
					,SP_ExpiryExtendedDate
					,CurrentPOS
					,CurrentTOS
					,RestructurePOS
					,Res_POS_to_CurrentPOS_Per
					,CurrentDPD
					,TotalDPD
					,VDPD
					,AddlProvPer
					,ProvReleasePer
					,AppliedNormalProvPer
					,FinalProvPer
					,PreDegProvPer
					,UpgradeDate
					,SurvPeriodEndDate
					--------,DegDurSP_PeriodProvPer
					,NonFinDPD
					,InitialAssetClassAlt_Key
					,FinalAssetClassAlt_Key
					,RestructureProvision
					,SecuredProvision
					,UnSecuredProvision
					,FlgDeg
					,FlgUpg
					,DegDate
					,RC_Pending
					,FinalNpaDt
					,RestructureStage
					,EffectiveFromTimeKey
					,EffectiveToTimeKey
					,FlgMorat
					,InvestmentGrade
					,POS_10PerPaidDate
					,RestructureFacilityTypeAlt_Key
				FROM PRO.AdvAcRestructureCal  T Where ISNULL(T.IsChanged,'N') IN('C','N')


	
	/* RESTRUCTURE DETAIL	*/
	
	drop table if exists #AdvAcRestructureDetail

	DECLARE @Procdate DATE=(SELECT DATE FROM SysDayMatrix WHERE TIMEKEY=@TIMEKEY)
	SELECT * ,'' IsChanged INTO #AdvAcRestructureDetail 
	FROM AdvAcRestructureDetail 
		WHERE EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY


		
	DECLARE @PrevTimeKey INT =(SELECT MAX(EffectiveFromTimeKey) FROM PRO.AdvAcRestructureCal_Hist WHERE EffectiveFromTimeKey <@TIMEKEY)

		--UPDATE A
		--	SET A.PreDegProvPer=ISNULL(B.AppliedNormalProvPer,0)+ISNULL(B.FinalProvPer,0)
		--	FROM #AdvAcRestructureDetail A
		--INNER JOIN PRO.AdvAcRestructureCal_Hist B
		--	ON A.AccountEntityId=B.AccountEntityID	
		--	AND (B.EffectiveFromTimeKey<=@PrevTimeKey AND B.EffectiveToTimeKey>=@PrevTimeKey)
		--INNER JOIN PRO.AdvAcRestructureCal C
		--	ON A.AccountEntityId=C.AccountEntityID	
		--	AND C.InitialAssetClassAlt_Key =1 AND C.FinalAssetClassAlt_Key >1

	/* 1- UPDATE DPD_30_90_Breach_Date IN RESTRCTURE CAL - IF ACCOUNT IS NPA AND DPD >90,   UPDATE ZERO_DPD_DATE =NULL, SP_ExpiryExtendedDate = NULL */ 
	/*COMMENTED BY ZAIN ON 20250407 AS STRUCTURE DIFFERENCE WAS IDENTIFIED*/
	--UPDATE a 
	--	SET  DPD_Breach_Date=b.DPD_Breach_Date
	--		,ZeroDPD_Date=b.ZeroDPD_Date
	--		,SP_ExpiryExtendedDate =b.SP_ExpiryExtendedDate 
	--		,A.RestructureStage=B.RestructureStage
	--		,A.POS_10PerPaidDate=b.POS_10PerPaidDate
	--		,A.SurvPeriodEndDate=b.SurvPeriodEndDate
	--		,A.UpgradeDate=b.UpgradeDate
	--from #AdvAcRestructureDetail a
	--	inner join pro.AdvAcRestructureCal b
	--		on a.AccountEntityId =b.AccountEntityID
	
	
	
	/* MERGE DATA IN ADVACRESTRUCTURE DETAIL-IN CASE OF EFFECTIVEFROMTIKE IS LESS THAN @TIMEKEY*/
	--UPDATE O SET O.EffectiveToTimeKey=@TIMEKEY-1,
	--	 O.DateModified=CONVERT(DATE,GETDATE(),103),
	--	 O.ModifiedBy='ACL-PROCESS'

	--FROM CURDAT.AdvAcRestructureDetail AS O
	--	INNER JOIN #AdvAcRestructureDetail AS T
	--		ON O.AccountEntityID=T.AccountEntityID
	--		AND O.EffectiveToTimeKey=49999
	--		AND T.EffectiveToTimeKey=49999
	--		AND O.EffectiveFromTimeKey <@TIMEKEY

	--	WHERE 
	--	(  
	--	   		 ISNULL(O.RestructureStage,'1990-01-01')			<> ISNULL(T.RestructureStage,'1990-01-01')
	--			OR ISNULL(O.ZeroDPD_Date,'1990-01-01')				<> ISNULL(T.ZeroDPD_Date,'1990-01-01')
	--			OR ISNULL(O.SP_ExpiryExtendedDate,'1990-01-01')		<> ISNULL(T.SP_ExpiryExtendedDate,'1990-01-01')
	--			OR ISNULL(O.DPD_Breach_Date,'1990-01-01')			<> ISNULL(T.DPD_Breach_Date,'1990-01-01')
	--			OR ISNULL(O.UpgradeDate,'1990-01-01')				<> ISNULL(T.UpgradeDate,'1990-01-01')
	--			OR ISNULL(O.POS_10PerPaidDate,'1990-01-01')			<> ISNULL(T.POS_10PerPaidDate,'1990-01-01')
	--			OR ISNULL(O.SurvPeriodEndDate,'1990-01-01')			<> ISNULL(T.SurvPeriodEndDate,'1990-01-01')
	--			OR ISNULL(O.RestructureStage,'')					<> ISNULL(T.RestructureStage,'')
	--			OR ISNULL(O.PreDegProvPer,0)						<> ISNULL(T.PreDegProvPer,0)				
	--	)

	--	/* UPODATE DATA FOR SAME TIMEKEY */
	--	UPDATE A
	--		SET A.RestructureStage =B.RestructureStage
	--			,A.ZeroDPD_Date=B.ZeroDPD_Date
	--			,A.SP_ExpiryExtendedDate=B.SP_ExpiryExtendedDate
	--			,A.DPD_Breach_Date=B.DPD_Breach_Date
	--			,A.UpgradeDate=B.UpgradeDate
	--			,A.SurvPeriodEndDate=B.SurvPeriodEndDate
	--			,A.POS_10PerPaidDate=B.POS_10PerPaidDate
	--			,A.PreDegProvPer=B.PreDegProvPer

	--	FROM  CURDAT.AdvAcRestructureDetail A
	--		INNER JOIN #AdvAcRestructureDetail B
	--			ON A.AccountEntityId =B.AccountEntityId
	--			AND A.EffectiveFromTimeKey<=@TIMEKEY AND A.EffectiveToTimeKey>=@TIMEKEY
	--			AND A.EffectiveFromTimeKey=@TIMEKEY

	--	----------For Changes Records
	--	UPDATE A SET A.IsChanged='C'
	--	----Select * 
	--	from #AdvAcRestructureDetail A
	--	INNER JOIN CurDat.AdvAcRestructureDetail B 
	--	ON B.AccountEntityId=A.AccountEntityId 
	--	Where B.EffectiveToTimeKey= @TIMEKEY -1
	--		AND B.ModifiedBy='ACL-PROCESS'



	--	/***************************************************************************************************************/

	--	INSERT INTO CurDat.AdvAcRestructureDetail
	--		(
	--			 AccountEntityId
	--			,RestructureTypeAlt_Key
	--			,RestructureProposalDt
	--			,RestructureDt
	--			,RestructureAmt
	--			,RestructureApprovalDt
	--			,RestructureSequenceRefNo
	--			,DiminutionAmount
	--			,RestructureByAlt_Key
	--			,RefCustomerId
	--			,RefSystemAcId
	--			,SDR_INVOKED
	--			,SDR_REFER_DATE
	--			,Remark
	--			,RestructureFacilityTypeAlt_Key
	--			,BankingRelationTypeAlt_Key
	--			,InvocationDate
	--			,AssetClassAlt_KeyOnInvocation
	--			,EquityConversionYN
	--			,ConversionDate
	--			,PrincRepayStartDate
	--			,InttRepayStartDate
	--			,PreRestructureAssetClassAlt_Key
	--			,PreRestructureNPA_Date
	--			,ProvPerOnRestrucure
	--			,COVID_OTR_CatgAlt_Key
	--			,RestructureApprovingAuthority
	--			,RestructreTOS
	--			,UnserviceInttAsOnRestructure
	--			,RestructurePOS
	--			,RestructureStage
	--			,RestructureStatus
	--			,DPD_AsOnRestructure
	--			,DPD_Breach_Date
	--			,ZeroDPD_Date
	--			,SurvPeriodEndDate
	--			,AuthorisationStatus
	--			,EffectiveFromTimeKey
	--			,EffectiveToTimeKey
	--			,CreatedBy
	--			,DateCreated
	--			,ModifiedBy
	--			,DateModified
	--			,ApprovedBy
	--			,DateApproved
	--			,RestructureFailureDate
	--			,UpgradeDate
	--			,PreDegProvPer
	--			,SP_ExpiryExtendedDate
	--			,FlgMorat
	--			,InvestmentGrade
	--			,POS_10PerPaidDate
	--		)
	--	SELECT  
	--		AccountEntityId
	--		,RestructureTypeAlt_Key
	--		,RestructureProposalDt
	--		,RestructureDt
	--		,RestructureAmt
	--		,RestructureApprovalDt
	--		,RestructureSequenceRefNo
	--		,DiminutionAmount
	--		,RestructureByAlt_Key
	--		,RefCustomerId
	--		,RefSystemAcId
	--		,SDR_INVOKED
	--		,SDR_REFER_DATE
	--		,Remark
	--		,RestructureFacilityTypeAlt_Key
	--		,BankingRelationTypeAlt_Key
	--		,InvocationDate
	--		,AssetClassAlt_KeyOnInvocation
	--		,EquityConversionYN
	--		,ConversionDate
	--		,PrincRepayStartDate
	--		,InttRepayStartDate
	--		,PreRestructureAssetClassAlt_Key
	--		,PreRestructureNPA_Date
	--		,ProvPerOnRestrucure
	--		,COVID_OTR_CatgAlt_Key
	--		,RestructureApprovingAuthority
	--		,RestructreTOS
	--		,UnserviceInttAsOnRestructure
	--		,RestructurePOS
	--		,RestructureStage
	--		,RestructureStatus
	--		,DPD_AsOnRestructure
	--		,DPD_Breach_Date
	--		,ZeroDPD_Date
	--		,SurvPeriodEndDate
	--		,AuthorisationStatus
	--		,@TIMEKEY EffectiveFromTimeKey
	--		,49999 EffectiveToTimeKey
	--		,CreatedBy
	--		,DateCreated
	--		,'ACL-PROCESS' ModifiedBy
	--		,GETDATE()    DateModified
	--		,ApprovedBy
	--		,DateApproved
	--		,RestructureFailureDate
	--		,UpgradeDate
	--		,PreDegProvPer
	--		,SP_ExpiryExtendedDate
	--		,FlgMorat
	--		,InvestmentGrade
	--		,POS_10PerPaidDate
	--	FROM #AdvAcRestructureDetail T Where ISNULL(T.IsChanged,'U') ='C'
		/*COMMENTED BY ZAIN ON 20250407 AS STRUCTURE DIFFERENCE WAS IDENTIFIED END */
/* END OF RESTR */


/*PIU WORK */


	DELETE PRO.PUI_CAL_HIST WHERE EffectiveFromTimeKey=@TIMEKEY and EffectiveToTimeKey=@TIMEKEY
	
	INSERT INTO PRO.PUI_CAL_HIST
			(
				CustomerEntityID
				,AccountEntityId
				,ProjectCategoryAlt_Key
				,ProjectSubCategoryAlt_key
				,DelayReasonChangeinOwnership
				,ProjectAuthorityAlt_key
				,OriginalDCCO
				,OriginalProjectCost
				,OriginalDebt
				,Debt_EquityRatio
				,ChangeinProjectScope
				,FreshOriginalDCCO
				,RevisedDCCO
				,CourtCaseArbitration
				,CIOReferenceDate
				,CIODCCO
				,TakeOutFinance
				,AssetClassSellerBookAlt_key
				,NPADateSellerBook
				,Restructuring
				,InitialExtension
				,BeyonControlofPromoters
				,DelayReasonOther
				,FLG_UPG
				,FLG_DEG
				,DEFAULT_REASON
				,ProjCategory
				,NPA_DATE
				,PUI_ProvPer
				,RestructureDate
				,ActualDCCO
				,ActualDCCO_Date
				,UpgradeDate
				,FinalAssetClassAlt_Key
				,DPD_Max
				,EffectiveFromTimeKey
				,EffectiveToTimeKey
			)
	SELECT		CustomerEntityID
				,AccountEntityId
				,ProjectCategoryAlt_Key
				,ProjectSubCategoryAlt_key
				,DelayReasonChangeinOwnership
				,ProjectAuthorityAlt_key
				,OriginalDCCO
				,OriginalProjectCost
				,OriginalDebt
				,Debt_EquityRatio
				,ChangeinProjectScope
				,FreshOriginalDCCO
				,RevisedDCCO
				,CourtCaseArbitration
				,CIOReferenceDate
				,CIODCCO
				,TakeOutFinance
				,AssetClassSellerBookAlt_key
				,NPADateSellerBook
				,Restructuring
				,InitialExtension
				,BeyonControlofPromoters
				,DelayReasonOther
				,FLG_UPG
				,FLG_DEG
				,DEFAULT_REASON
				,ProjCategory
				,NPA_DATE
				,PUI_ProvPer
				,RestructureDate
				,ActualDCCO
				,ActualDCCO_Date
				,UpgradeDate
				,FinalAssetClassAlt_Key
				,DPD_Max
				,EffectiveFromTimeKey
				,EffectiveToTimeKey
		FROM PRO.PUI_CAL


/* END OF PUI WORK */



UPDATE PRO.ACLRUNNINGPROCESSSTATUS 
	SET COMPLETED='Y',ERRORDATE=NULL,ERRORDESCRIPTION=NULL,COUNT=ISNULL(COUNT,0)+1
	WHERE RUNNINGPROCESSNAME='InsertDataIntoHistTable' 
end


END TRY
BEGIN  CATCH

		UPDATE PRO.ACLRUNNINGPROCESSSTATUS 
		SET COMPLETED='N',ERRORDATE=GETDATE(),ERRORDESCRIPTION=ERROR_MESSAGE(),COUNT=ISNULL(COUNT,0)+1
		WHERE RUNNINGPROCESSNAME='InsertDataIntoHistTable'

END CATCH

GO