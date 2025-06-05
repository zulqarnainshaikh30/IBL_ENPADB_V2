SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [PRO].[InsertDataforAssetClassficationIBL_MOC]
 @TIMEKEY INT
AS
BEGIN

---declare @timekey int=26298

  DECLARE @ProcessingDate DATE=(SELECT DATE FROM SYSDAYMATRIX WHERE TIMEKEY=@TIMEKEY)

DECLARE @SetID INT =(SELECT ISNULL(MAX(ISNULL(SETID,0)),0)+1 FROM [PRO].[PROCESSMONITOR_MOC] WHERE TimeKey=@TIMEKEY )

 ----SET @TIMEKEY= (SELECT TIMEKEY FROM SYSDAYMATRIX WHERE TIMEKEY=@TIMEKEY)        

 
TRUNCATE TABLE PRO.CUSTOMERCAL

TRUNCATE TABLE PRO.ACCOUNTCAL


TRUNCATE TABLE PRO.AdvAcRestructureCal

TRUNCATE TABLE PRO.PUI_CAL

DROP TABLE IF EXISTS #Moc_Cust

            UPDATE A SET 
                  MOC_ExpireDate= CASE WHEN MOCTYPE='Manual' THEN '2099-01-01'
                                                ELSE @ProcessingDate END
            FROM MOC_ChangeDetails A
                  WHERE EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey >=@TIMEKEY
                  AND MOCType_Flag='CUST'

            DROP TABLE IF EXISTS #MOC_DATA
            
            SELECT UcifEntityID,  MAX(AssetClassAlt_Key) SysAssetClassAlt_Key, min(NPA_Date) SysNPA_Dt,MIN(MOC_ExpireDate) MOC_ExpireDate,'N' AssetClassChanged
                  INTO #MOC_DATA
              FROM MOC_ChangeDetails A
                  INNER JOIN CustomerBasicDetail cbd
                        ON a.EffectivefromTimeKey<=@TimeKey and a.EffectiveToTimeKey>=@TIMEKEY
                        and CBD.EffectivefromTimeKey<=@TimeKey and CBD.EffectiveToTimeKey>=@TIMEKEY
                        AND cbd.CustomerEntityId =A.CustomerEntityId
                  WHERE MOC_Date=@ProcessingDate
                  GROUP BY UcifEntityID

            DROP TABLE IF EXISTS #CUST_HIST
            SELECT B.UcifEntityID ,MAX(B.SysAssetClassAlt_Key) SysAssetClassAlt_Key, MIN(B.SysNPA_Dt) SysNPA_Dt
                  INTO #CUST_HIST
            FROM #MOC_DATA A
                  INNER JOIN PRO.CustomerCal_Hist B
                        ON B.EffectiveFromTimeKey<=@TIMEKEY AND B.EffectiveToTimeKey>=@TIMEKEY
                        AND A.UcifEntityID=B.UcifEntityID
            GROUP BY  B.UcifEntityID


            UPDATE A
                  SET A.SysAssetClassAlt_Key=CASE WHEN A.SysAssetClassAlt_Key IS NULL THEN B.SysAssetClassAlt_Key ELSE A.SysAssetClassAlt_Key END
                        ,A.SysNPA_Dt =CASE WHEN A.SysNPA_Dt IS NULL THEN B.SysNPA_Dt ELSE A.SysNPA_Dt END
            FROM #MOC_DATA A
                  INNER JOIN #CUST_HIST B
                        ON A.UcifEntityID=B.UcifEntityID

            

INSERT INTO PRO.CUSTOMERCAL
(
BranchCode
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
,RBITotProvision
,BankTotProvision
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
--,DateOfData
,CustMoveDescription
,TotOsCust
,MOCTYPE
)
SELECT 

 A.BranchCode
,A.UCIF_ID
,A.UcifEntityID
,A.CustomerEntityID
,A.ParentCustomerID
,A.RefCustomerID
,A.SourceSystemCustomerID
,A.CustomerName
,A.CustSegmentCode
,A.ConstitutionAlt_Key
,A.PANNO
,A.AadharCardNO
,A.SrcAssetClassAlt_Key
,A.SysAssetClassAlt_Key
,A.SplCatg1Alt_Key
,A.SplCatg2Alt_Key
,A.SplCatg3Alt_Key
,A.SplCatg4Alt_Key
,A.SMA_Class_Key
,A.PNPA_Class_Key
,A.PrvQtrRV
,A.CurntQtrRv
,0 TotProvision
,0 RBITotProvision
,0 BankTotProvision
,A.SrcNPA_Dt
,A.SysNPA_Dt
,A.DbtDt
,A.DbtDt2
,A.DbtDt3
,A.LossDt
,A.MOC_Dt
,A.ErosionDt
,A.SMA_Dt
,A.PNPA_Dt
,A.Asset_Norm
,A.FlgDeg
,A.FlgUpg
,'Y' FlgMoc
,A.FlgSMA
,A.FlgProcessing
,A.FlgErosion
,A.FlgPNPA
,A.FlgPercolation
,A.FlgInMonth
,A.FlgDirtyRow
,A.DegDate
,@TIMEKEY EffectiveFromTimeKey
,@TIMEKEY EffectiveToTimeKey
,A.CommonMocTypeAlt_Key
,A.InMonthMark
,A.MocStatusMark
,A.SourceAlt_Key
,A.BankAssetClass
,A.Cust_Expo
,A.MOCReason
,A.AddlProvisionPer
,A.FraudDt
,A.FraudAmount
,A.DegReason
--,A.DateOfData
,A.CustMoveDescription
,A.TotOsCust
,A.MOCTYPE
FROM PRO.CustomerCal_Hist  A
      INNER JOIN #MOC_DATA B
            ON A.UcifEntityID=B.UcifEntityID
      WHERE EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY



INSERT INTO PRO.ACCOUNTCAL
(
AccountEntityID
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
,PreQtrCredit
,PrvQtrInt
,CurQtrCredit
,CurQtrInt
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
--,DPD_IntService
--,DPD_NoCredit
--,DPD_Overdrawn
--,DPD_Overdue
--,DPD_Renewal
--,DPD_StockStmt
--,DPD_Max
--,DPD_FinMaxType
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
--,DPD_SMA
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
--,DPD_PrincOverdue
,IntOverdue
,IntOverdueSinceDt
--,DPD_IntOverdueSince
,OtherOverdue
,OtherOverdueSinceDt
--,DPD_OtherOverdueSince
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
--,DateOfData
,DerecognisedInterest1
,DerecognisedInterest2
,ProductCode
,FlgLCBG
,unserviedint
,AdvanceRecovery
,NotionalInttAmt
,OriginalBranchcode
,PrvAssetClassAlt_Key
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
,FlgRestructure
,RestructureDate
,WeakAccountDate
,SarfaesiDate
,FlgUnusualBounce
,UnusualBounceDate
,FlgUnClearedEffect
,UnClearedEffectDate
,FlgFraud
,FraudDate
)

SELECT 

 A.AccountEntityID
,A.UcifEntityID
,A.CustomerEntityID
,A.CustomerAcID
,A.RefCustomerID
,A.SourceSystemCustomerID
,A.UCIF_ID
,A.BranchCode
,A.FacilityType
,A.AcOpenDt
,A.FirstDtOfDisb
,A.ProductAlt_Key
,A.SchemeAlt_key
,A.SubSectorAlt_Key
,A.SplCatg1Alt_Key
,A.SplCatg2Alt_Key
,A.SplCatg3Alt_Key
,A.SplCatg4Alt_Key
,A.SourceAlt_Key
,A.ActSegmentCode
,A.InttRate
,A.Balance
,A.BalanceInCrncy
,A.CurrencyAlt_Key
,A.DrawingPower
,A.CurrentLimit
,A.CurrentLimitDt
,A.ContiExcessDt
,A.StockStDt
,A.DebitSinceDt
,A.LastCrDate
,A.PreQtrCredit
,A.PrvQtrInt
,A.CurQtrCredit
,A.CurQtrInt
,A.InttServiced
,A.IntNotServicedDt
,A.OverdueAmt
,A.OverDueSinceDt
,A.ReviewDueDt
,A.SecurityValue
,A.DFVAmt
,A.GovtGtyAmt
,A.CoverGovGur
,A.WriteOffAmount
,A.UnAdjSubSidy
,A.CreditsinceDt
--,A.DPD_IntService
--,A.DPD_NoCredit
--,A.DPD_Overdrawn
--,A.DPD_Overdue
--,A.DPD_Renewal
--,A.DPD_StockStmt
--,A.DPD_Max
--,A.DPD_FinMaxType
,A.DegReason
,A.Asset_Norm
,A.REFPeriodMax
,A.RefPeriodOverdue
,A.RefPeriodOverDrawn
,A.RefPeriodNoCredit
,A.RefPeriodIntService
,A.RefPeriodStkStatement
,A.RefPeriodReview
,A.NetBalance
,A.ApprRV
,A.SecuredAmt
,A.UnSecuredAmt
,A.ProvDFV
,0 Provsecured
,0 ProvUnsecured
,0 ProvCoverGovGur
,0 AddlProvision
,0 TotalProvision
,0 BankProvsecured
,0 BankProvUnsecured
,0 BankTotalProvision
,0 RBIProvsecured
,0 RBIProvUnsecured
,0 RBITotalProvision
,A.InitialNpaDt
,A.FinalNpaDt
,A.SMA_Dt
,A.UpgDate
,A.InitialAssetClassAlt_Key
,A.FinalAssetClassAlt_Key
,A.ProvisionAlt_Key
,A.PNPA_Reason
,A.SMA_Class
,A.SMA_Reason
,'Y'FlgMoc
,A.MOC_Dt
,A.CommonMocTypeAlt_Key
--,A.DPD_SMA
,A.FlgDeg
,A.FlgDirtyRow
,A.FlgInMonth
,A.FlgSMA
,A.FlgPNPA
,A.FlgUpg
,A.FlgFITL
,A.FlgAbinitio
,A.NPA_Days
,A.RefPeriodOverdueUPG
,A.RefPeriodOverDrawnUPG
,A.RefPeriodNoCreditUPG
,A.RefPeriodIntServiceUPG
,A.RefPeriodStkStatementUPG
,A.RefPeriodReviewUPG
,@TIMEKEY EffectiveFromTimeKey
,@TIMEKEY EffectiveToTimeKey
,A.AppGovGur
,A.UsedRV
,A.ComputedClaim
,A.UPG_RELAX_MSME
,A.DEG_RELAX_MSME
,A.PNPA_DATE
,A.NPA_Reason
,A.PnpaAssetClassAlt_key
,A.DisbAmount
,A.PrincOutStd
,A.PrincOverdue
,A.PrincOverdueSinceDt
--,A.DPD_PrincOverdue
,A.IntOverdue
,A.IntOverdueSinceDt
--,A.DPD_IntOverdueSince
,A.OtherOverdue
,A.OtherOverdueSinceDt
--,A.DPD_OtherOverdueSince
,A.RelationshipNumber
,A.AccountFlag
,A.CommercialFlag_AltKey
,A.Liability
,A.CD
,A.AccountStatus
,A.AccountBlkCode1
,A.AccountBlkCode2
,A.ExposureType
,A.Mtm_Value
,A.BankAssetClass
,A.NpaType
,A.SecApp
,A.BorrowerTypeID
,A.LineCode
,A.ProvPerSecured
,A.ProvPerUnSecured
,A.MOCReason
,A.AddlProvisionPer
,A.FlgINFRA
,A.RepossessionDate
--,A.DateOfData
,A.DerecognisedInterest1
,A.DerecognisedInterest2
,A.ProductCode
,A.FlgLCBG
,A.unserviedint
,A.AdvanceRecovery
,A.NotionalInttAmt
,A.OriginalBranchcode
,A.PrvAssetClassAlt_Key
,A.FlgSecured
,A.RePossession
,A.RCPending
,A.PaymentPending
,A.WheelCase
,A.CustomerLevelMaxPer
,A.FinalProvisionPer
,A.IsIBPC
,A.IsSecuritised
,A.RFA
,A.IsNonCooperative
,A.Sarfaesi
,A.WeakAccount
,A.PUI
,A.FlgRestructure
,A.RestructureDate
,A.WeakAccountDate
,A.SarfaesiDate
,A.FlgUnusualBounce
,A.UnusualBounceDate
,A.FlgUnClearedEffect
,A.UnClearedEffectDate
,A.FlgFraud
,A.FraudDate
FROM  PRO.AccountCal_Hist  A
      INNER JOIN #MOC_DATA B
            ON A.UcifEntityID=B.UcifEntityID
      WHERE EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY



/* UPDATE MOC DATA IN CUSOMER CAL AND ACCOUNTCAL */

/* UPDATE MOC DATA IN CUSOMER CAL AND ACCOUNTCAL */
UPDATE A
      SET  A.SysAssetClassAlt_Key=C.SysAssetClassAlt_Key
            ,A.SysNPA_Dt=CASE WHEN C.SysNPA_Dt IS NULL THEN a.SysNPA_Dt ELSE C.SysNPA_Dt END
            --,A.CurntQtrRv =CASE WHEN ISNULL(B.CurntQtrRv,0)=0 THEN A.CurntQtrRv ELSE B.CurntQtrRv END
            ,A.ASSET_NORM =CASE WHEN ISNULL(C.SysAssetClassAlt_Key,0)>1 AND ISNULL(A.SysAssetClassAlt_Key,0)=1 THEN 'ALWYS_NPA'
                                        WHEN ISNULL(C.SysAssetClassAlt_Key,0)=1 AND ISNULL(A.SysAssetClassAlt_Key,0)>1 THEN 'ALWYS_STD'
                                        WHEN (ISNULL(C.SysAssetClassAlt_Key,0)=0) OR (ISNULL(C.SysAssetClassAlt_Key,0)>1 AND ISNULL(A.SysAssetClassAlt_Key,0)>1) THEN 'NORMAL'
                                    END
            ,A.MOCTYPE=       CASE WHEN c.MOC_ExpireDate=@ProcessingDate then 'AUTO' ELSE 'MANUAL' END
            ,DEGREASON= CASE WHEN  ISNULL(c.SysAssetClassAlt_Key,0)>A.SysAssetClassAlt_Key 
                                          THEN  'NPA DUE TO MOC' END
            --,AddlProvisionPer=B.AddlProvPer
            ,FLGMOC='Y'                         
            --,MOC_Dt =B.MOC_Date         
            --,MOCReason =B.MOC_Reason
FROM PRO.CUSTOMERCAL A
      --INNER JOIN MOC_ChangeDetails B
      --    ON  B.EffectiveFromTimeKey<=@TIMEKEY AND B.EffectiveToTimeKey>=@TIMEKEY
      --    AND B.MOC_Date=@ProcessingDate
      --    and B.CustomerEntityId=A.CustomerEntityID
      --    AND MOCType_Flag='CUST'
      INNER JOIN #MOC_DATA C
            ON C.UcifEntityID =A.UcifEntityID


UPDATE A
      SET A.CurntQtrRv =CASE WHEN ISNULL(B.CurntQtrRv,0)=0 THEN A.CurntQtrRv ELSE B.CurntQtrRv END
            ,AddlProvisionPer=B.AddlProvPer
            ,MOC_Dt =B.MOC_Date           
            ,MOCReason =B.MOC_Reason
FROM PRO.CUSTOMERCAL A
      INNER JOIN MOC_ChangeDetails B
            ON  B.EffectiveFromTimeKey<=@TIMEKEY AND B.EffectiveToTimeKey>=@TIMEKEY
            AND B.MOC_Date=@ProcessingDate
            and B.CustomerEntityId=A.CustomerEntityID
            AND MOCType_Flag='CUST'
      INNER JOIN #MOC_DATA C
            ON C.UcifEntityID =A.UcifEntityID


UPDATE A
      SET   AddlProvisionPer              =CASE WHEN isnull(B.AddlProvPer,0)=0            THEN A.AddlProvisionPer       ELSE B.AddlProvPer                  END
             ,AddlProvision               =CASE WHEN isnull(B.AddlProvAbs,0)=0            THEN A.AddlProvision          ELSE B.AddlProvAbs                  END
---          ,PrincOutStd                 =CASE WHEN  ISNULL(B.PrincOutStd,0)  =0               THEN A.PrincOutStd                  ELSE B.PrincOutStd                  END
             ,PrincOutStd                 =CASE WHEN   b.PrincOutStd is null THEN A.PrincOutStd             ELSE B.PrincOutStd                  END
             --,UnserviedInt              =CASE WHEN ISNULL(B.UnServicedInt,0)=0                THEN A.UnserviedInt                 ELSE B.UnServicedInt          END
             ,FlgRestructure        =CASE WHEN ISNULL(B.FlgRestructure,'')=''       THEN A.FlgRestructure         ELSE B.FlgRestructure         END
             ,RestructureDate       =CASE WHEN B.RestructureDate   IS NULL          THEN A.RestructureDate        ELSE B.RestructureDate        END
             ,FlgFITL                     =CASE WHEN ISNULL(B.FlgFITL,'')=''                    THEN A.FlgFITL                      ELSE B.FlgFITL                      END
             ,DFVAmt                      =CASE WHEN ISNULL(B.DFVAmt,0)=0                             THEN A.DFVAmt                       ELSE B.DFVAmt                       END
             --,Repossession              =CASE WHEN ISNULL(B.Repossession,'')=''               THEN A.Repossession                 ELSE B.Repossession                 END
             --,RepossessionDate          =CASE WHEN B.RepossessionDate  IS NULL          THEN A.RepossessionDate       ELSE B.RepossessionDate       END
             --,WeakAccount               =CASE WHEN ISNULL(B.WeakAccount,'')=''                THEN A.WeakAccount                  ELSE B.WeakAccount                  END
             --,WeakAccountDate           =CASE WHEN B.WeakAccountDate   IS NULL          THEN A.WeakAccountDate        ELSE B.WeakAccountDate        END
             --,Sarfaesi                        =CASE WHEN ISNULL(B.Sarfaesi,'') =''                  THEN A.Sarfaesi                     ELSE B.Sarfaesi                     END
             --,SarfaesiDate              =CASE WHEN B.SarfaesiDate            IS NULL          THEN A.SarfaesiDate                 ELSE B.SarfaesiDate                 END
             --,FlgUnusualBounce          =CASE WHEN ISNULL(B.FlgUnusualBounce,'')=''           THEN A.FlgUnusualBounce       ELSE B.FlgUnusualBounce       END
             --,UnusualBounceDate         =CASE WHEN B.UnusualBounceDate       IS NULL          THEN A.UnusualBounceDate      ELSE B.UnusualBounceDate      END
             --,FlgUnClearedEffect  =CASE WHEN ISNULL(B.FlgUnClearedEffect,'')=''   THEN A.FlgUnClearedEffect     ELSE B.FlgUnClearedEffect     END
             --,UnClearedEffectDate =CASE WHEN B.UnClearedEffectDate IS NULL        THEN A.UnClearedEffectDate    ELSE B.UnClearedEffectDate    END
             ,FlgFraud                    =CASE WHEN ISNULL(B.FlgFraud,'')    =''               THEN A.FlgFraud                     ELSE B.FlgFraud                     END
             ,FraudDate                   =CASE WHEN B.FraudDate               IS NULL          THEN A.FraudDate              ELSE B.FraudDate              END
             --,BenamiLoansFlag           =CASE WHEN ISNULL(B.BenamiLoansFlag,'')   =''         THEN A.BenamiLoansFlag        ELSE B.BenamiLoansFlag        END
             --,MarkBenamiDate            =CASE WHEN B.MarkBenamiDate          IS NULL          THEN A.MarkBenamiDate         ELSE B.MarkBenamiDate         END
             --,SubLendingFlag            =CASE WHEN ISNULL(B.SubLendingFlag,'')=''       THEN A.SubLendingFlag         ELSE B.SubLendingFlag         END
             --,MarkSubLendingDate  =CASE WHEN B.MarkSubLendingDate      IS NULL          THEN A.MarkSubLendingDate     ELSE B.MarkSubLendingDate     END
             --,AbscondingFlag            =CASE WHEN ISNULL(B.AbscondingFlag,'') =''            THEN A.AbscondingFlag         ELSE B.AbscondingFlag         END
             --,MarkAbscondingDate  =CASE WHEN B.MarkAbscondingDate      IS NULL          THEN A.MarkAbscondingDate     ELSE B.MarkAbscondingDate     END
             --,TwoFlag                   =CASE WHEN ISNULL(B.TwoFlag,'')      IS NULL          THEN A.TwoFlag                      ELSE B.TwoFlag                      END
             --,TwoDate                   =CASE WHEN B.TwoDate                 IS NULL          THEN A.TwoDate                      ELSE B.TwoDate                      END
             ,MOCTYPE                     =CASE WHEN b.MOC_ExpireDate=@ProcessingDate           THEN 'AUTO'                         ELSE 'MANUAL' END
             ,FLGMOC='Y'
             ,MOC_Dt =B.MOC_Date          
             ,MOCReason =B.MOC_Reason
FROM PRO.ACCOUNTCAL A
      INNER JOIN MOC_ChangeDetails B
            ON  B.EffectiveFromTimeKey<=@TIMEKEY AND b.EffectiveToTimeKey>=@TIMEKEY
            AND B.Moc_Date=@ProcessingDate
            and B.AccountEntityid=A.AccountEntityid
            AND MOCType_Flag='ACCT'
      


      UPDATE A SET  
            --A.SYSASSETCLASSALT_KEY=B.SysAssetClassAlt_Key
            --,A.SYSNPA_DT=NULL
            A.DbtDt=NULL
            ,A.DbtDt2=NULL
            ,A.DbtDt3=NULL
            ,A.LossDt=NULL
            --,A.FLGMOC='Y'
            --,A.ASSET_NORM=CASE WHEN B.MocType='Manual' THEN  'ALWYS_STD' ELSE 'NORMAL'  END
            ---,A.MOCREASON=B.MOCREASON  --- NEED TO UPDATE IN MOC SCREEN SP
            ,DEGREASON='STD DUE TO MOC'
            ---,A.MOC_DT=B.DATECREATED  
            --,A.MOCTYPE=B.MOCTYPE  
       FROM PRO.CUSTOMERCAL A
            --INNER JOIN #Moc_Cust B ON A.UcifEntityID=B.UcifEntityID
            --INNER JOIN DimAssetClass C
            --          ON C.EffectiveFromTimeKey<=@TIMEKEY and c.EffectiveToTimeKey>=@TIMEKEY
            --          and c.AssetClassAlt_Key=b.PreMoc_SysAssetClassAlt_Key
            INNER JOIN DimAssetClass d
                        ON d.EffectiveFromTimeKey<=@TIMEKEY and d.EffectiveToTimeKey>=@TIMEKEY
                        and d.AssetClassAlt_Key=A.SysAssetClassAlt_Key
            WHERE ---C.AssetClassGroup='NPA' AND 
                  D.AssetClassGroup='STD'  AND A.Asset_Norm='ALWYS_STD'


      /* added on 29122021 as discussed 29122021 for update MOC npa date and reason for other moc effected customer/accounts */
      UPDATE pro.CUSTOMERCAL set MOC_Dt =@ProcessingDate WHERE  MOC_DT IS NULL
      UPDATE PRO.ACCOUNTCAL SET MOC_Dt =@ProcessingDate WHERE  MOC_DT IS NULL


      
      UPDATE A
            SET A.MOCReason=ltrim(rtrim(isnull(B.MOCReason,'')))+' CIF ID '+b.RefCustomerID
      FROM pro.CUSTOMERCAL a
            INNER JOIN pro.CUSTOMERCAL B
                  ON A.UcifEntityID=B.UcifEntityID
            WHERE ISNULL(A.MOCReason,'')=''
            AND ISNULL(B.MOCReason,'')<>''
      /* */

/* ACCOUNT LEVEL DATA UPDATE */           
      UPDATE A SET 
                   A.FinalAssetClassAlt_Key=B.SysAssetClassAlt_Key 
                  ,A.ASSET_NORM=B.ASSET_NORM
                  ,A.MOCTYPE=B.MOCTYPE  
                  ,A.FinalNpaDt=NULL
       FROM PRO.ACCOUNTCAL A
            INNER JOIN PRO.CustomerCal B ON A.CustomerEntityID=B.CustomerEntityID
            INNER JOIN DimAssetClass d
                        ON d.EffectiveFromTimeKey<=@TIMEKEY and d.EffectiveToTimeKey>=@TIMEKEY
                        AND D.AssetClassAlt_Key=b.SysAssetClassAlt_Key
            WHERE D.AssetClassGroup='STD' 

      UPDATE A SET 
                   A.FinalAssetClassAlt_Key=B.SysAssetClassAlt_Key 
                  ,A.ASSET_NORM=B.ASSET_NORM
                  ,A.MOCTYPE=B.MOCTYPE  
                  ,A.FinalNpaDt=b.SysNPA_Dt
       FROM PRO.ACCOUNTCAL A
            INNER JOIN PRO.CustomerCal B ON A.CustomerEntityID=B.CustomerEntityID
            INNER JOIN DimAssetClass d
                        ON d.EffectiveFromTimeKey<=@TIMEKEY and d.EffectiveToTimeKey>=@TIMEKEY
                        AND D.AssetClassAlt_Key=b.SysAssetClassAlt_Key
            WHERE D.AssetClassGroup<>'STD'            


      UPDATE  A SET DBTDT=@ProcessingDate FROM PRO.CUSTOMERCAL A  
      INNER JOIN DIMASSETCLASS DA       ON  DA.ASSETCLASSALT_KEY= A.SYSASSETCLASSALT_KEY AND
                                             DA.ASSETCLASSSHORTNAME IN ('DB1','DB2','DB3') AND  
                                             DA.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND
                                 DA.EFFECTIVETOTIMEKEY>=@TIMEKEY
      WHERE DBTDT IS NULL





/*  EXCEPTIONAL DEGRADATION START */
/*------------------UPDATE Repossessed ACCOUNT MARKING  IN PRO.ACCOUNTCAL------------------*/
INSERT INTO PRO.ProcessMonitor(USERID,DESCRIPTION,MODE,STARTTIME,ENDTIME,TIMEKEY,SETID) 
SELECT ORIGINAL_LOGIN(),'UPDATE Repossessed ACCOUNT MARKING  IN PRO.ACCOUNTCAL','RUNNING',GETDATE(),NULL,@TIMEKEY,@SETID


UPDATE A SET A.Asset_Norm='ALWYS_NPA'
            ,A.FinalAssetClassAlt_Key=2
                  ,A.FinalNpaDt=CASE WHEN REPOSSESSIONDATE is NULL then @PROCESSINGDATE else  REPOSSESSIONDATE end  --FinalNpaDt
                  ,A.NPA_Reason='NPA DUE TO Repossessed Account'
                  
            FROM PRO.AccountCal A 
            where A.RePossession='Y' and FinalAssetClassAlt_Key=1


UPDATE A SET A.Asset_Norm='ALWYS_NPA'
            ,A.NPA_Reason='NPA DUE TO Repossessed Account'
                  ,A.RePossession='Y'
                  FROM PRO.AccountCal A 
            where A.RePossession='Y' and  finalAssetClassAlt_Key>1


UPDATE PRO.ProcessMonitor SET ENDTIME=GETDATE() ,MODE='COMPLETE' 
WHERE IDENTITYKEY = (SELECT IDENT_CURRENT('PRO.ProcessMonitor')) AND  TIMEKEY=@TIMEKEY AND DESCRIPTION='UPDATE Repossessed ACCOUNT MARKING  IN PRO.ACCOUNTCAL'



/*------------------UPDATE Inherent Weakness  ACCOUNT MARKING  IN PRO.ACCOUNTCAL------------------*/
INSERT INTO PRO.ProcessMonitor(USERID,DESCRIPTION,MODE,STARTTIME,ENDTIME,TIMEKEY,SETID) 
SELECT ORIGINAL_LOGIN(),'UPDATE Inherent Weakness ACCOUNT MARKING  IN PRO.ACCOUNTCAL','RUNNING',GETDATE(),NULL,@TIMEKEY,@SETID

UPDATE A SET A.Asset_Norm='ALWYS_NPA'
            ,A.FinalAssetClassAlt_Key=2
                  ,A.FinalNpaDt=CASE WHEN FinalNpaDt is NULL then @PROCESSINGDATE else  FinalNpaDt end
                  ,A.NPA_Reason='NPA DUE TO Inherent Weakness Account'
                  
                  FROM PRO.AccountCal A 
            where A.WeakAccount='Y' and FinalAssetClassAlt_Key=1

UPDATE A SET A.Asset_Norm='ALWYS_NPA'
            ,A.NPA_Reason='NPA DUE TO Inherent Weakness Account'
                  ,A.WeakAccount='Y'
                  FROM PRO.AccountCal a
        where A.WeakAccount='Y' and FinalAssetClassAlt_Key>1


UPDATE PRO.ProcessMonitor SET ENDTIME=GETDATE() ,MODE='COMPLETE' 
WHERE IDENTITYKEY = (SELECT IDENT_CURRENT('PRO.ProcessMonitor')) AND  TIMEKEY=@TIMEKEY AND DESCRIPTION='UPDATE Inherent Weakness ACCOUNT MARKING  IN PRO.ACCOUNTCAL'



/*------------------UPDATE SARFAESI ACCOUNT MARKING IN PRO.ACCOUNTCAL------------------*/
INSERT INTO PRO.ProcessMonitor(USERID,DESCRIPTION,MODE,STARTTIME,ENDTIME,TIMEKEY,SETID) 
SELECT ORIGINAL_LOGIN(),'UPDATE SARFAESI ACCOUNT MARKING IN PRO.ACCOUNTCAL','RUNNING',GETDATE(),NULL,@TIMEKEY,@SETID


UPDATE A SET A.Asset_Norm='ALWYS_NPA'
            ,A.FinalAssetClassAlt_Key=2
                  ,A.FinalNpaDt=CASE WHEN FinalNpaDt is NULL then @PROCESSINGDATE else  FinalNpaDt end
                  ,A.NPA_Reason='NPA DUE TO SARFAESI  Account'
                  FROM PRO.AccountCal A 
            where Sarfaesi='Y' AND FinalAssetClassAlt_Key=1


UPDATE A SET A.Asset_Norm='ALWYS_NPA'
            ,A.NPA_Reason='NPA DUE TO Sarfaesi Account'
                  ,A.Sarfaesi='Y'
                  FROM PRO.AccountCal A 
where Sarfaesi='Y' and FinalAssetClassAlt_Key>1

UPDATE PRO.ProcessMonitor SET ENDTIME=GETDATE() ,MODE='COMPLETE' 
WHERE IDENTITYKEY = (SELECT IDENT_CURRENT('PRO.ProcessMonitor')) AND  TIMEKEY=@TIMEKEY AND DESCRIPTION='UPDATE SARFAESI ACCOUNT MARKING IN PRO.ACCOUNTCAL'


UPDATE PRO.ProcessMonitor SET ENDTIME=GETDATE() ,MODE='COMPLETE' 
WHERE IDENTITYKEY = (SELECT IDENT_CURRENT('PRO.ProcessMonitor')) AND  TIMEKEY=@TIMEKEY AND DESCRIPTION='UPDATE Written-Off Accounts MARKING IN PRO.ACCOUNTCAL'


/*------------------UPDATE FRAUD ACCOUNT MARKING  IN PRO.ACCOUNTCAL------------------*/
INSERT INTO PRO.ProcessMonitor(USERID,DESCRIPTION,MODE,STARTTIME,ENDTIME,TIMEKEY,SETID) 
SELECT ORIGINAL_LOGIN(),'UPDATE FRAUD ACCOUNT MARKING  IN PRO.ACCOUNTCAL','RUNNING',GETDATE(),NULL,@TIMEKEY,@SETID

      UPDATE A SET A.Asset_Norm='ALWYS_NPA'
                        ,A.SplCatg4Alt_Key=870
                        ,A.FinalAssetClassAlt_Key=6
                        ,A.FinalNpaDt=CASE WHEN FinalNpaDt is NULL then @PROCESSINGDATE else  FinalNpaDt end
                        ,A.NPA_Reason='NPA DUE TO FRAUD MARKING'
      FROM PRO.AccountCal A  WHERE FlgFraud='Y'
      
UPDATE PRO.ProcessMonitor SET ENDTIME=GETDATE() ,MODE='COMPLETE' 
WHERE IDENTITYKEY = (SELECT IDENT_CURRENT('PRO.ProcessMonitor')) AND  TIMEKEY=@TIMEKEY AND DESCRIPTION='UPDATE FRAUD ACCOUNT MARKING  IN PRO.ACCOUNTCAL'

-----------------------
INSERT INTO PRO.ProcessMonitor(USERID,DESCRIPTION,MODE,STARTTIME,ENDTIME,TIMEKEY,SETID) 
SELECT ORIGINAL_LOGIN(),'UPDATE EXCEPTIONAL DEGRADATION MARKING IN PRO.CUSTOMERCAL','RUNNING',GETDATE(),NULL,@TIMEKEY,@SETID

      update a set SysAssetClassAlt_Key=b.FinalAssetClassAlt_Key,SysNPA_Dt=b.FinalNpaDt,a.DegReason=b.NPA_Reason,a.Asset_Norm=b.Asset_Norm
      FROM pro.customercal a
      inner join PRO.AccountCal b
      on a.CustomerEntityID=b.CustomerEntityID
      where b.WeakAccount='Y' OR Sarfaesi='Y' OR RePossession='Y' OR FlgFraud='Y' 


UPDATE PRO.ProcessMonitor SET ENDTIME=GETDATE() ,MODE='COMPLETE' 
WHERE IDENTITYKEY = (SELECT IDENT_CURRENT('PRO.ProcessMonitor')) AND  TIMEKEY=@TIMEKEY AND DESCRIPTION='UPDATE EXCEPTIONAL DEGRADATION MARKING IN PRO.CUSTOMERCAL'

/* EXCETIONAL DEGRADATION END */


      
UPDATE A SET A.AddlProvisionPer=B.AddlProvisionPer
   FROM PRO.AccountCal A
 INNER JOIN PRO.CUSTOMERCAL B
 ON A.CustomerEntityID=B.CustomerEntityID
      WHERE  ISNULL(B.AddlProvisionPer,0)>0




DELETE FROM SecurityDetails WHERE TIMEKEY =@TIMEKEY          
 
 
INSERT INTO SecurityDetails          
(          
REFCustomerId,          
TotalSecurity,          
TIMEKEY          
)          
SELECT           
REFCustomerId,          
SUM(ISNULL(CurntQtrRv,0))TotalSecurity,          
@TIMEKEY TIMEKEY          
from PRO.CUSTOMERCAL a

 where  ISNULL(CurntQtrRv,0)>0                  
GROUP BY REFCUSTOMERID            
                                
----------      /*TempTableForSecurity  being create */                      
                                 
IF OBJECT_ID('SECURITYDETAIL') IS NOT NULL                      
TRUNCATE  TABLE SECURITYDETAIL                      
      
INSERT INTO  SECURITYDETAIL 
SELECT REFCustomerId,SUM(ISNULL(TOTALSECURITY,0)) AS TOTALSECURITY 

FROM SECURITYDETAILS                       
WHERE TIMEKEY =@TIMEKEY                     
GROUP BY REFCustomerId                      
                     
                                                  
UPDATE  PRO.ACCOUNTCAL SET ApprRV=0                            
                      
                     
;WITH CTE(REFCUSTOMERID,TOTOSFUNDED)                    
AS                    
(                    
SELECT B.REFCUSTOMERID,SUM(ISNULL(A.NETBALANCE,0)) TOTOSFUNDED FROM  PRO.ACCOUNTCAL A    INNER JOIN PRO.CUSTOMERCAL B
 ON A.CUSTOMERENTITYID=B.CUSTOMERENTITYID                                 
WHERE A.NETBALANCE>0  
AND A.FlgAbinitio<>'Y'
AND A.FinalAssetClassAlt_Key<>6
AND A.FlgSecured='D'     
GROUP BY B.REFCUSTOMERID                  
)                                          
            
UPDATE D SET D.ApprRV=((D.NETBALANCE/A.TOTOSFUNDED)*C.TOTALSECURITY)
--CASE WHEN  ((D.NETBALANCE/A.TOTOSFUNDED)*C.TOTALSECURITY)>D.NETBALANCE THEN D.NETBALANCE       
--ELSE ((D.NETBALANCE/A.TOTOSFUNDED)*C.TOTALSECURITY) END                                           
from CTE A inner join PRO.CustomerCal B on A.REFCUSTOMERID=B.REFCUSTOMERID                             
inner join SecurityDetail C on C.REFCustomerId=B.REFCUSTOMERID                    
INNER JOIN   pro.AccountCal D on D.RefCustomerID=B.RefCustomerID                  
WHERE c.TotalSecurity>0
AND D.FlgAbinitio<>'Y'
AND D.FinalAssetClassAlt_Key<>6
AND D.FlgSecured='D'


UPDATE A SET ApprRV=NETBALANCE FROM pro.AccountCal  A
WHERE A.FlgAbinitio<>'Y'
AND A.FinalAssetClassAlt_Key<>6
AND A.FlgSecured='S'



 update pro.accountcal set FinalNpaDt=InitialNpaDt where FinalAssetClassAlt_Key>1 and FinalNpaDt is null
update pro.CustomerCal set SysNPA_Dt=SrcNPA_Dt where SysAssetClassAlt_Key>1 and SysNPA_Dt is null

update pro.accountcal set FinalNpaDt=InitialNpaDt where FinalAssetClassAlt_Key>1 and FinalNpaDt is null
update pro.CustomerCal set SysNPA_Dt=NULL where SysAssetClassAlt_Key=1 and SysNPA_Dt is NOT null
update pro.CustomerCal set SrcNPA_Dt=NULL where SrcAssetClassAlt_Key=1 and SrcNPA_Dt is NOT null
      
update pro.AccountCal set FinalNpaDt=NULL where FinalAssetClassAlt_Key=1 and FinalNpaDt    is NOT null
update pro.AccountCal set InitialNpaDt=NULL where InitialAssetClassAlt_Key=1 and InitialNpaDt is NOT null 

--DROP TABLE #Moc_Cust
/* investment (calaypso) */

/* and derivative MOC work */

--SELECT * INTO PreMoc.DerivativeDetail from CurDat.DerivativeDetail where 1=2
      INSERT INTO PreMoc.InvestmentfinancialDetail
      (EntityKey,                              ---Newly adde by kapil on 15/02/2024
             InvEntityId
            ,RefInvID
            ,HoldingNature
            ,CurrencyAlt_Key
            ,CurrencyConvRate
            ,BookType
            ,BookValue
            ,BookValueINR
            ,MTMValue
            ,MTMValueINR
            ,EncumberedMTM
            ,AssetClass_AltKey
            ,NPIDt
            ,TotalProvison
            ,AuthorisationStatus
            ,EffectiveFromTimeKey
            ,EffectiveToTimeKey
            ,CreatedBy
            ,DateCreated
            ,ModifiedBy
            ,DateModified
            ,ApprovedBy
            ,DateApproved
            ,DBTDate
            ,LatestBSDate
            ,Interest_DividendDueDate
            ,Interest_DividendDueAmount
            ,PartialRedumptionDueDate
            ,PartialRedumptionSettledY_N
            ,FLGDEG
            ,DEGREASON
            ,DPD
            ,FLGUPG
            ,UpgDate
            ,PROVISIONALT_KEY
            ,InitialAssetAlt_Key
            ,InitialNPIDt
            ,RefIssuerID
            ,DPD_Maturity
            ,DPD_DivOverdue
            ,FinalAssetClassAlt_Key
            ,PartialRedumptionDPD
            ,Asset_Norm
            ,ISIN
            ,AssetClass
            ,GL_Code
            ,GL_Description
            ,OVERDUE_AMOUNT
            ,FlgSMA
            ,SMA_Dt
            ,SMA_Class
            ,SMA_Reason
         ,AddlProvision
         ,AddlProvisionPer
         ,MocBy
         ,MOC_Date
         ,FlgMoc
         ,MOC_Reason
 
      )
SELECT       ROW_NUMBER() OVER (PARTITION BY A.InvEntityId,A.EffectiveFromTimekey,A.EffectiveToTimekey ORDER BY A.InvEntityId,A.EffectiveFromTimekey,A.EffectiveToTimekey), ---Newly adde by kapil on 15/02/2024
            A.InvEntityId
            ,A.RefInvID
            ,A.HoldingNature
            ,A.CurrencyAlt_Key
            ,A.CurrencyConvRate
            ,A.BookType
            ,A.BookValue
            ,A.BookValueINR
            ,A.MTMValue
            ,A.MTMValueINR
            ,A.EncumberedMTM
            ,A.AssetClass_AltKey
            ,A.NPIDt
            ,A.TotalProvison
            ,A.AuthorisationStatus
            ,A.EffectiveFromTimeKey
            ,A.EffectiveToTimeKey
            ,A.CreatedBy
            ,A.DateCreated
            ,A.ModifiedBy
            ,A.DateModified
            ,A.ApprovedBy
            ,A.DateApproved
            ,A.DBTDate
            ,A.LatestBSDate
            ,A.Interest_DividendDueDate
            ,A.Interest_DividendDueAmount
            ,A.PartialRedumptionDueDate
            ,A.PartialRedumptionSettledY_N
            ,A.FLGDEG
            ,A.DEGREASON
            ,A.DPD
            ,A.FLGUPG
            ,A.UpgDate
            ,A.PROVISIONALT_KEY
            ,A.InitialAssetAlt_Key
            ,A.InitialNPIDt
            ,A.RefIssuerID
            ,A.DPD_Maturity
            ,A.DPD_DivOverdue
            ,A.FinalAssetClassAlt_Key
            ,A.PartialRedumptionDPD
            ,A.Asset_Norm
            ,A.ISIN
            ,A.AssetClass
            ,A.GL_Code
            ,A.GL_Description
            ,A.OVERDUE_AMOUNT
            ,A.FlgSMA
            ,A.SMA_Dt
            ,A.SMA_Class
            ,A.SMA_Reason
         ,A.AddlProvision
         ,A.AddlProvisionPer
         ,A.MocBy
         ,A.MOC_Date
         ,A.FlgMoc
         ,A.MOC_Reason

      FROM CURDAT.InvestmentFinancialDetail A
            INNER JOIN CURDAT.InvestmentBasicDetail INB
                  on a.InvEntityId=inb.InvEntityId
                  and a.EffectiveFromTimeKey<=@TIMEKEY and A.EffectiveToTimeKey>=@TIMEKEY
                  and INB.EffectiveFromTimeKey<=@TIMEKEY and inb.EffectiveToTimeKey>=@TIMEKEY
            INNER JOIN CURDAT.InvestmentIssuerDetail ISR
                  on ISR.IssuerEntityId=INB.IssuerEntityId
                  and ISR.EffectiveFromTimeKey<=@TIMEKEY and ISR.EffectiveToTimeKey>=@TIMEKEY
            INNER JOIN CalypsoInvMOC_ChangeDetails aa
                              on isr.UcifId=case when MOCType_Flag='CUST' THEN AA.UCICID ELSE isr.UcifId END
                              AND A.InvEntityId=case when MOCType_Flag='CUST' THEN A.InvEntityId ELSE AA.AccountEntityID END
                  and AA.EffectiveFromTimeKey<=@TIMEKEY and AA.EffectiveToTimeKey>=@TIMEKEY
            LEFT JOIN PreMoc.InvestmentFinancialDetail b
                  on a.InvEntityId=b.InvEntityId
                  and b.EffectiveFromTimeKey<=@TIMEKEY and b.EffectiveToTimeKey>=@TIMEKEY
            where b.InvEntityId is null

Select  * from CalypsoInvMOC_ChangeDetails
            update a
            set A.FinalAssetClassAlt_Key=AA.AssetClassAlt_Key
                    ,A.NPIDt=AA.NPA_Date 
                    ,A.AddlProvisionPer=AA.AddlProvPer
                    ,A.MocBy=AA.MOC_By
                    ,A.MOC_dATE=AA.MOC_Date
                    ,A.FlgMoc='Y'
                    ,A.MOC_Reason=aa.MOC_Reason
            FROM CURDAT.InvestmentFinancialDetail A
            INNER JOIN CURDAT.InvestmentBasicDetail INB
                  on a.InvEntityId=inb.InvEntityId
                  and a.EffectiveFromTimeKey<=@TIMEKEY and A.EffectiveToTimeKey>=@TIMEKEY
                  and INB.EffectiveFromTimeKey<=@TIMEKEY and inb.EffectiveToTimeKey>=@TIMEKEY
            INNER JOIN CURDAT.InvestmentIssuerDetail ISR
                  on ISR.IssuerEntityId=INB.IssuerEntityId
                  and ISR.EffectiveFromTimeKey<=@TIMEKEY and ISR.EffectiveToTimeKey>=@TIMEKEY
            INNER JOIN CalypsoInvMOC_ChangeDetails aa
                  on (isnull(ISR.UcifId,'')=CASE WHEN AA.MOCType_Flag='CUST' THEN isnull(AA.UCICID,'') ELSE ISNULL(ISR.UcifId,'') END)
                  AND (a.InvEntityId=CASE WHEN AA.MOCType_Flag='ACCT' THEN AA.AccountEntityID ELSE a.InvEntityId END)
                  and AA.EffectiveFromTimeKey<=@TIMEKEY and AA.EffectiveToTimeKey>=@TIMEKEY
      

            update a
            set A.MTMValue=aa.PrincOutStd  --- NNED TO MENTION COLUMNS FRO UPDATE FROM CHANGE DETAIL TO MAIN TABLE      
                  ,a.AddlProvision=aa.AddlProvAbs     
                    ,A.MocBy=AA.MOC_By
                    ,A.Moc_Date=AA.MOC_Date
                    ,A.FlgMoc='Y'
                    ,A.MOC_Reason=aa.MOC_Reason
                    ,A.SMA_Dt=AA.SMADate
                    ,A.SMA_Class=AA.SMASubAssetClassValue
                  ---  ,A.SMA_Reason=AA.MOC_Reason---- Updated By Akshay Rathod SMA Reason should not be MOC Reason
                   
FROM CURDAT.InvestmentFinancialDetail A
            INNER JOIN CURDAT.InvestmentBasicDetail INB
                  on a.InvEntityId=inb.InvEntityId
                  and a.EffectiveFromTimeKey<=@TIMEKEY and A.EffectiveToTimeKey>=@TIMEKEY
                  and INB.EffectiveFromTimeKey<=@TIMEKEY and inb.EffectiveToTimeKey>=@TIMEKEY
            INNER JOIN CURDAT.InvestmentIssuerDetail ISR
                  on ISR.IssuerEntityId=INB.IssuerEntityId
                  and ISR.EffectiveFromTimeKey<=@TIMEKEY and ISR.EffectiveToTimeKey>=@TIMEKEY
            INNER JOIN CalypsoInvMOC_ChangeDetails aa
                              on INB.InvEntityid=AA.AccountEntityID
                  and AA.EffectiveFromTimeKey<=@TIMEKEY and AA.EffectiveToTimeKey>=@TIMEKEY
            where aa.MOCType_Flag='ACCT'

/* derrivative */

insert into PreMoc.DerivativeDetail
      (
            DerivativeEntityID
            ,CustomerACID
            ,CustomerID
            ,CustomerName
            ,DerivativeRefNo
            ,Duedate
            ,DueAmt
            ,OsAmt
            ,POS
            ,AuthorisationStatus
            ,EffectiveFromTimeKey
            ,EffectiveToTimeKey
            ,CreatedBy
            ,DateCreated
            ,ModifiedBy
            ,DateModified
            ,ApprovedBy
            ,DateApproved
            ,DateofData
            ,SourceSystem
            ,BranchCode
            ,UCIC_ID
            ,FLGDEG
            ,DEGREASON
            ,DPD
            ,FLGUPG
            ,UpgDate
            ,DBTDate
            ,PROVISIONALT_KEY
            ,InitialAssetAlt_Key
            ,InitialNPIDt
            ,DPD_DivOverdue
            ,FinalAssetClassAlt_Key
            ,NPIDt
            ,AssetClass_AltKey
            ,TotalProvison
            ,InstrumentName
            ,OverDueSinceDt
            ,DueAmtReceivable
            ,MTMIncomeAmt
            ,CouponDate
            ,CouponAmt
            ,CouponOverDueSinceDt
            ,OverdueCouponAmt
            ,DPD_CouponOverDue
            ,ChangeFields
            ,AddlProvision
            ,AddlProvisionPer
            ,MocBy
            ,MOC_Date
            ,FlgMoc
            ,MOC_Reason
            ,FlgSMA           
            ,SMA_Dt           
            ,SMA_Class
            ,SMA_Reason
)
SELECT      A.DerivativeEntityID
            ,A.CustomerACID
            ,A.CustomerID
            ,A.CustomerName
            ,A.DerivativeRefNo
            ,A.Duedate
            ,A.DueAmt
            ,A.OsAmt
            ,A.POS
            ,A.AuthorisationStatus
            ,A.EffectiveFromTimeKey
            ,A.EffectiveToTimeKey
            ,A.CreatedBy
            ,A.DateCreated
            ,A.ModifiedBy
            ,A.DateModified
            ,A.ApprovedBy
            ,A.DateApproved
            ,A.DateofData
            ,A.SourceSystem
            ,A.BranchCode
            ,A.UCIC_ID
            ,A.FLGDEG
            ,A.DEGREASON
            ,A.DPD
            ,A.FLGUPG
            ,A.UpgDate
            ,A.DBTDate
            ,A.PROVISIONALT_KEY
            ,A.InitialAssetAlt_Key
            ,A.InitialNPIDt
            ,A.DPD_DivOverdue
            ,A.FinalAssetClassAlt_Key
            ,A.NPIDt
            ,A.AssetClass_AltKey
            ,A.TotalProvison
            ,A.InstrumentName
            ,A.OverDueSinceDt
            ,A.DueAmtReceivable
            ,A.MTMIncomeAmt
            ,A.CouponDate
            ,A.CouponAmt
            ,A.CouponOverDueSinceDt
            ,A.OverdueCouponAmt
            ,A.DPD_CouponOverDue
            ,A.ChangeFields
            ,A.AddlProvision
            ,A.AddlProvisionPer
            ,A.MocBy
            ,A.MOC_Date
            ,A.FlgMoc
            ,A.MOC_Reason
            ,A.FlgSMA         
            ,A.SMA_Dt         
            ,A.SMA_Class
            ,A.SMA_Reason
      FROM CURDAT.DerivativeDetail A
                  INNER JOIN CalypsoDervMOC_ChangeDetails aa
                              on (isnull(A.UCIC_ID,'')=CASE WHEN AA.MOCType_Flag='CUST' THEN isnull(AA.UCICID,'') ELSE ISNULL(A.UCIC_ID,'') END)
                              AND (a.DerivativeEntityID=CASE WHEN AA.MOCType_Flag='ACCT' THEN AA.AccountEntityID ELSE a.DerivativeEntityID END)
                             and AA.EffectiveFromTimeKey<=@TIMEKEY and AA.EffectiveToTimeKey>=@TIMEKEY
                              and A.EffectiveFromTimeKey<=@TIMEKEY and A.EffectiveToTimeKey>=@TIMEKEY
                  LEFT JOIN PreMoc.DerivativeDetail b
                        on a.DerivativeEntityID=b.DerivativeEntityID
                        and b.EffectiveFromTimeKey<=@TIMEKEY and b.EffectiveToTimeKey>=@TIMEKEY
            where b.DerivativeEntityID is null

            UPDATE A
            SET A.FinalAssetClassAlt_Key=AA.AssetClassAlt_Key
                    ,A.NPIDt=AA.NPA_Date
                    ,A.AddlProvisionPer=aa.AddlProvPer
                    ,A.MocBy=AA.MOC_By
                    ,A.MOC_dATE=AA.MOC_Date
                    ,A.FlgMoc='Y'
                    ,A.MOC_Reason=aa.MOC_Reason
					,A.Degreason = CASE WHEN AA.AssetClassAlt_Key > 1 THEN CASE WHEN  ISNULL(A.Degreason,'') <> '' THEN ISNULL(A.Degreason,'') + 'NPA DUE TO MOC' ELSE 'NPA DUE TO MOC' END END
            FROM CURDAT.DerivativeDetail A
            INNER JOIN CalypsoDervMOC_ChangeDetails aa
                              on A.UCIC_ID=AA.UCICID
                  and AA.EffectiveFromTimeKey<=@Timekey and AA.EffectiveToTimeKey>=@Timekey
                  and a.EffectiveFromTimeKey<=@Timekey and A.EffectiveToTimeKey>=@Timekey
            where aa.MOCType_Flag='CUST'

            update a
            set A.MTMIncomeAmt=aa.BookValue  --- NNED TO MENTION COLUMNS FRO UPDATE FROM CHANGE DETAIL TO MAIN TABLE    
                  ,A.POS=AA.PrincOutStd
                  ,AddlProvision=aa.AddlProvAbs
                  ,A.MocBy=AA.MOC_By
                  ,A.MOC_dATE=AA.MOC_Date
                  ,A.FlgMoc='Y'
                  ,A.MOC_Reason=aa.MOC_Reason
                  ,A.SMA_Dt=AA.SMADate
                  ,A.SMA_Class=AA.SMASubAssetClassValue
                  ,A.SMA_Reason=AA.MOC_Reason
					,A.Degreason = CASE WHEN AA.AssetClassAlt_Key > 1 THEN CASE WHEN  ISNULL(A.Degreason,'') <> '' THEN ISNULL(A.Degreason,'') + 'NPA DUE TO MOC' ELSE 'NPA DUE TO MOC' END END
            FROM CURDAT.DerivativeDetail A
            INNER JOIN CalypsoDervMOC_ChangeDetails aa
                              on A.DerivativeEntityID=AA.AccountEntityID
                  and AA.EffectiveFromTimeKey<=@Timekey and AA.EffectiveToTimeKey>=@Timekey
                  and a.EffectiveFromTimeKey<=@Timekey and A.EffectiveToTimeKey>=@Timekey
            where aa.MOCType_Flag='ACCT'
/* end of Investment and derivative MOC work */




/* MERGING DATA FOR ALL SOURCES FOR FIND LOWEST ASSET CLASS AND MIN NPA DATE */
      
      IF OBJECT_ID('TEMPDB..#CTE_PERC') IS NOT NULL
    DROP TABLE #CTE_PERC

      SELECT * INTO 
            #CTE_PERC
      FROM
            (           /* ADVANCE DATA */
                  SELECT UCIF_ID,CustomerAcID,MAX(ISNULL(FinalAssetClassAlt_Key,1)) SYSASSETCLASSALT_KEY ,MIN(FinalNpaDt) SYSNPA_DT
                  ,'ADV' PercType
                  FROM PRO.ACCOUNTCAL A WHERE ( UCIF_ID IS NOT NULL and UCIF_ID<>'0' ) 
                  AND  ISNULL(FinalAssetClassAlt_Key,1)<>1 and (DPD_NoCredit > 89
                                                                                          OR DPD_Overdrawn > 0 
                                                                                          OR DPD_Overdue > 0
                                                                                          OR DPD_Renewal > 180
                                                                                          OR DPD_StockStmt > 89
                                                                                          OR InttServiced = 'N'
                                                                                          OR Asset_Norm = 'ALWYS_NPA') 
                  GROUP BY  UCIF_ID,CustomerAcID
                  UNION
                  /* INVESTMENT DATA */
                  SELECT UcifId UCIF_ID,RefInvID,MAX(ISNULL(FinalAssetClassAlt_Key,1)) SYSASSETCLASSALT_KEY ,MIN(NPIDt) SYSNPA_DT
                  ,'INV' PercType
                  FROM InvestmentFinancialDetail A 
                        INNER JOIN InvestmentBasicDetail B
                              ON A.InvEntityId =B.InvEntityId
                              AND A.EffectiveFromTimeKey <=@TIMEKEY AND A.EffectiveToTimeKey >=@TIMEKEY
                              AND B.EffectiveFromTimeKey <=@TIMEKEY AND B.EffectiveToTimeKey >=@TIMEKEY
                        INNER JOIN InvestmentIssuerDetail C
                              ON C.IssuerEntityId=B.IssuerEntityId
                              AND C.EffectiveFromTimeKey <=@TIMEKEY AND C.EffectiveToTimeKey >=@TIMEKEY
                  WHERE ISNULL(FinalAssetClassAlt_Key,1)<>1   and DPD > 0 
                  GROUP BY  UcifId,RefInvID
                  /* DERIVATIVE DATA */
                  UNION 
                        SELECT UCIC_ID,CustomerACID,MAX(ISNULL(FinalAssetClassAlt_Key,1)) SYSASSETCLASSALT_KEY ,MIN(NPIDt) SYSNPA_DT
                        ,'DER' PercType
                  FROM CurDat.DerivativeDetail A 
                        WHERE  A.EffectiveFromTimeKey <=@TIMEKEY AND A.EffectiveToTimeKey >=@TIMEKEY
                              AND ISNULL(FinalAssetClassAlt_Key,1)<>1 and DPD > 0 
                  GROUP BY  UCIC_ID,CustomerACID
            )A

      /*  FIND LOWEST ASSET CLASS AND IN NPA DATE IN AALL SOURCES */
      IF OBJECT_ID('TEMPDB..#TEMPTABLE_UCFIC1') IS NOT NULL
    DROP TABLE #TEMPTABLE_UCFIC1

      SELECT UCIF_ID,CustomerACID, MAX(SYSASSETCLASSALT_KEY) SYSASSETCLASSALT_KEY, MIN(SYSNPA_DT)SYSNPA_DT
                  ,'XXX' PercType
            INTO #TEMPTABLE_UCFIC1 
      FROM #CTE_PERC
            GROUP BY UCIF_ID,CustomerACID

      UPDATE A
            SET A.PercType=B.PercType 
      FROM #TEMPTABLE_UCFIC1 A
            INNER JOIN #CTE_PERC B
                  ON A.UCIF_ID =B.UCIF_ID
                  AND A.SYSASSETCLASSALT_KEY =B.SYSASSETCLASSALT_KEY 
                  


      /*  UPDATE LOWEST ASSET CLASS AND MIN NPA DATE IN - ADVANCE DATA */
      UPDATE A SET SysAssetClassAlt_Key=B.SYSASSETCLASSALT_KEY
                        ,A.SysNPA_Dt=B.SYSNPA_DT
                        ,A.DegReason=CASE WHEN A.SysAssetClassAlt_Key =1 AND B.SYSASSETCLASSALT_KEY >1 
                                                THEN  
                                                      CASE WHEN B.PercType ='INV' THEN    'PERCOLATION BY INVESTMENT INVID '  + B.CustomerACID 
                                                                              WHEN B.PercType ='DER' THEN   'PERCOLATION BY DERIVATIVE ACCOUNTID '  + B.CustomerACID    
                                                            ELSE A.DegReason
                                                      END 
                                                ELSE  A.DegReason
                                          END                     
      FROM PRO.CUSTOMERCAL A
            INNER JOIN (select A.UCIF_ID,A.PercType,A.SYSASSETCLASSALT_KEY,A.SYSNPA_DT
            ,(CASE WHEN A.PercType = 'ADV' THEN STUFF((SELECT ', ' + B.CustomerACID
                                                            from #TEMPTABLE_UCFIC1 B 
                                                            WHERE B.PercType = 'ADV' and B.UCIF_ID = A.UCIF_ID
                                                            ORDER BY CustomerACID
                                                            FOR XML PATH('')),1,1,'')
                        WHEN  A.PercType = 'INV' THEN STUFF((SELECT ', ' + B.CustomerACID
                                                            from #TEMPTABLE_UCFIC1 B 
                                                            WHERE B.PercType = 'INV' and B.UCIF_ID = A.UCIF_ID
                                                            ORDER BY CustomerACID
                                                            FOR XML PATH('')),1,1,'')
                        WHEN  A.PercType = 'DER' THEN STUFF((SELECT ', ' + B.CustomerACID
                                                            from #TEMPTABLE_UCFIC1 B 
                                                            WHERE B.PercType = 'DER' and B.UCIF_ID = A.UCIF_ID
                                                            ORDER BY CustomerACID
                                                            FOR XML PATH('')),1,1,'')
                                                            END) CustomerACID

                                                      FROM #TEMPTABLE_UCFIC1 A
                                                      
                                                      GROUP BY A.UCIF_ID,A.PercType,A.SYSASSETCLASSALT_KEY,A.SYSNPA_DT) B ON A.UCIF_ID =B.UCIF_ID


      /* UPDATE INVESTMENT DATA - LOWEST ASSET CLASS AND MIN NPA DATE */
      UPDATE A SET A.FinalAssetClassAlt_Key=D.SYSASSETCLASSALT_KEY
                   ,A.NPIDt=D.SYSNPA_DT  
                        ,A.DegReason=CASE WHEN A.FinalAssetClassAlt_Key =1 AND D.SYSASSETCLASSALT_KEY >1 
                                                THEN  
                                                      CASE WHEN D.PercType ='ADV' THEN    'PERCOLATION BY LOAN ACCOUNTID ' + D.CustomerACID 
                                                             WHEN D.PercType ='DER' THEN  'PERCOLATION BY DERIVATIVE ACCOUNTID '  + D.CustomerACID    
                                                            ELSE A.DegReason
                                                      END 
                                                ELSE  A.DegReason
                                          END
       FROM InvestmentFinancialDetail A 
                        INNER JOIN InvestmentBasicDetail B
                              ON A.InvEntityId =B.InvEntityId
                              AND A.EffectiveFromTimeKey <=@TIMEKEY AND A.EffectiveToTimeKey >=@TIMEKEY
                              AND B.EffectiveFromTimeKey <=@TIMEKEY AND B.EffectiveToTimeKey >=@TIMEKEY
                        INNER JOIN InvestmentIssuerDetail C
                              ON C.IssuerEntityId=B.IssuerEntityId
                              AND C.EffectiveFromTimeKey <=@TIMEKEY AND C.EffectiveToTimeKey >=@TIMEKEY
                        INNER JOIN (select A.UCIF_ID,A.PercType,A.SYSASSETCLASSALT_KEY,A.SYSNPA_DT
            ,(CASE WHEN A.PercType = 'ADV' THEN STUFF((SELECT ', ' + B.CustomerACID
                                                            from #TEMPTABLE_UCFIC1 B 
                                                            WHERE B.PercType = 'ADV' and B.UCIF_ID = A.UCIF_ID
                                                            ORDER BY CustomerACID
                                                            FOR XML PATH('')),1,1,'')
                        WHEN  A.PercType = 'INV' THEN STUFF((SELECT ', ' + B.CustomerACID
                                                            from #TEMPTABLE_UCFIC1 B 
                                                            WHERE B.PercType = 'INV' and B.UCIF_ID = A.UCIF_ID
                                                            ORDER BY CustomerACID
                                                            FOR XML PATH('')),1,1,'')
                        WHEN  A.PercType = 'DER' THEN STUFF((SELECT ', ' + B.CustomerACID
                                                            from #TEMPTABLE_UCFIC1 B 
                                                            WHERE B.PercType = 'DER' and B.UCIF_ID = A.UCIF_ID
                                                            ORDER BY CustomerACID
                                                            FOR XML PATH('')),1,1,'')
                                                            END) CustomerACID

                                                      FROM #TEMPTABLE_UCFIC1 A
                                                      
                                                      GROUP BY A.UCIF_ID,A.PercType,A.SYSASSETCLASSALT_KEY,A.SYSNPA_DT) D ON D.UCIF_ID =C.UcifId

      /*  UPDATE   LOWEST ASSET CLASS AND MIN NPA DATE IN -  DERIVATIVE DATA */
      UPDATE A SET FinalAssetClassAlt_Key=B.SYSASSETCLASSALT_KEY
                        ,A.NPIDt=SYSNPA_DT
                        ,A.DegReason=CASE WHEN A.FinalAssetClassAlt_Key =1 AND B.SYSASSETCLASSALT_KEY >1 
                                                THEN  
                                                      CASE WHEN B.PercType ='ADV' THEN 'PERCOLATION BY LOAN ACCOUNTID ' + B.CustomerACID 
                                                             WHEN B.PercType ='INV' THEN 'PERCOLATION BY INVESTMENT INVID ' + B.CustomerACID    
                                                            ELSE A.DegReason
                                                      END 
                                                ELSE  A.DegReason
                                          END
      FROM CurDat.DerivativeDetail A
            INNER JOIN (select A.UCIF_ID,A.PercType,A.SYSASSETCLASSALT_KEY,A.SYSNPA_DT
                              ,(CASE WHEN A.PercType = 'ADV' THEN STUFF((SELECT ', ' + B.CustomerACID
                                                            from #TEMPTABLE_UCFIC1 B 
                                                            WHERE B.PercType = 'ADV' and B.UCIF_ID = A.UCIF_ID
                                                            ORDER BY CustomerACID
                                                            FOR XML PATH('')),1,1,'')
                              WHEN  A.PercType = 'INV' THEN STUFF((SELECT ', ' + B.CustomerACID
                                                            from #TEMPTABLE_UCFIC1 B 
                                                            WHERE B.PercType = 'INV' and B.UCIF_ID = A.UCIF_ID
                                                            ORDER BY CustomerACID
                                                            FOR XML PATH('')),1,1,'')
                              WHEN  A.PercType = 'DER' THEN STUFF((SELECT ', ' + B.CustomerACID
                                                            from #TEMPTABLE_UCFIC1 B 
                                                            WHERE B.PercType = 'DER' and B.UCIF_ID = A.UCIF_ID
                                                            ORDER BY CustomerACID
                                                            FOR XML PATH('')),1,1,'')
                                                            END) CustomerACID
                                                      FROM #TEMPTABLE_UCFIC1 A                                                      
                                                      GROUP BY A.UCIF_ID,A.PercType,A.SYSASSETCLASSALT_KEY,A.SYSNPA_DT) B ON A.UCIC_ID =B.UCIF_ID
            AND A.EffectiveFromTimeKey<=@TIMEKEY AND A.EffectiveToTimeKey>=@TIMEKEY

            
      --DROP TABLE IF EXISTS #CTE_PERC


            update A SET FLGUPG='N',UPGDATE=NULL
            FROM CurDat.DerivativeDetail A
            where  A.EffectiveFromTimeKey<=@TIMEKEY AND A.EffectiveToTimeKey>=@TIMEKEY
             and FinalAssetClassAlt_Key>1

             update A SET AssetClass_AltKey=FinalAssetClassAlt_Key
             FROM CurDat.DerivativeDetail A
            where  A.EffectiveFromTimeKey<=@TIMEKEY AND A.EffectiveToTimeKey>=@TIMEKEY
             and FinalAssetClassAlt_Key>1

             update A SET AssetClass_AltKey=FinalAssetClassAlt_Key
             FROM DBO.InvestmentFinancialDetail A
            where  A.EffectiveFromTimeKey<=@TIMEKEY AND A.EffectiveToTimeKey>=@TIMEKEY
             and FinalAssetClassAlt_Key>1

             update A SET FLGUPG='N',UPGDATE=NULL
            FROM InvestmentFinancialDetail A
            where  A.EffectiveFromTimeKey<=@TIMEKEY AND A.EffectiveToTimeKey>=@TIMEKEY
             and FinalAssetClassAlt_Key>1


      DROP TABLE IF EXISTS #TEMPTABLE_UCFIC1

      /* INVESTMENT AND DERVATIVE PROVISION CALCULATION */
      EXEC [PRO].[InvestmentDerivativeProvisionCal] @TIMEKEY


Update A
SET MOCProcessed='Y'
FROM CalypsoInvMOC_ChangeDetails A
Where EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey >=@TIMEKEY 
AND MOCPROCESSED='N'


Update A
SET MOCProcessed='Y'
FROM CalypsoDervMOC_ChangeDetails A
Where EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey >=@TIMEKEY 
AND MOCPROCESSED='N'

/* END OF PERCOLATION WORK */


end
GO