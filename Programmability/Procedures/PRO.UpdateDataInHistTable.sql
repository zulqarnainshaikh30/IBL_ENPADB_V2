SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

 

 

 

 

 

CREATE PROCEDURE [PRO].[UpdateDataInHistTable]

@TIMEKEY int

with recompile

as

begin

 

                                UPDATE A

                                                set A.AssetClassAlt_Key=B.SysAssetClassAlt_Key

                                                                ,A.NPA_Date =B.SysNPA_Dt

                                from MOC_ChangeDetails A

                                                INNER JOIN PRO.CustomerCal B

                                                                on B.EffectiveFromTimeKey<=@TIMEKEY and b.EffectiveToTimeKey >=@TIMEKEY

                                                                AND a.CustomerEntityID=b.CustomerEntityID

                                WHERE ISNULL(B.MOCTYPE,'') ='Manual'

 

 

                                UPDATE B SET

                                                                B.BranchCode  =             A.BranchCode

                                                                ,B.UCIF_ID          =             A.UCIF_ID

                                                                ,B.UcifEntityID   =             A.UcifEntityID

                                                                ,B.CustomerEntityID       =             A.CustomerEntityID

                                                                ,B.ParentCustomerID     =             A.ParentCustomerID

                                                                ,B.RefCustomerID            =             A.RefCustomerID

                                                                ,B.SourceSystemCustomerID      =             A.SourceSystemCustomerID

                                                                ,B.CustomerName           =             A.CustomerName

                                                                ,B.CustSegmentCode     =             A.CustSegmentCode

                                                                ,B.ConstitutionAlt_Key  =             A.ConstitutionAlt_Key

                                                                ,B.PANNO           =             A.PANNO

                                                                ,B.AadharCardNO            =             A.AadharCardNO

                                                                ,B.SrcAssetClassAlt_Key =             A.SrcAssetClassAlt_Key

                                                                ,B.SysAssetClassAlt_Key =             A.SysAssetClassAlt_Key

                                                                ,B.SplCatg1Alt_Key         =             A.SplCatg1Alt_Key

                                                                ,B.SplCatg2Alt_Key         =             A.SplCatg2Alt_Key

                                                                ,B.SplCatg3Alt_Key         =             A.SplCatg3Alt_Key

                                                                ,B.SplCatg4Alt_Key         =             A.SplCatg4Alt_Key

                                                                ,B.SMA_Class_Key           =             A.SMA_Class_Key

                                                                ,B.PNPA_Class_Key         =             A.PNPA_Class_Key

                                                                ,B.PrvQtrRV        =             A.PrvQtrRV

                                                                ,B.CurntQtrRv    =             A.CurntQtrRv

                                                                ,B.TotProvision =             A.TotProvision

                                                                ,B.RBITotProvision           =             A.RBITotProvision

                                                                ,B.BankTotProvision       =             A.BankTotProvision

                                                                ,B.SrcNPA_Dt    =             A.SrcNPA_Dt

                                                                ,B.SysNPA_Dt    =             A.SysNPA_Dt

                                                                ,B.DbtDt               =             A.DbtDt

                                                                ,B.DbtDt2            =             A.DbtDt2

                                                                ,B.DbtDt3            =             A.DbtDt3

                                                                ,B.LossDt             =             A.LossDt

                                                                ,B.MOC_Dt         =             A.MOC_Dt

                                                                ,B.ErosionDt       =             A.ErosionDt

                                                                ,B.SMA_Dt          =             A.SMA_Dt

                                                                ,B.PNPA_Dt        =             A.PNPA_Dt

                                                                ,B.Asset_Norm =             A.Asset_Norm

                                                                ,B.FlgDeg             =             A.FlgDeg

                                                                ,B.FlgUpg             =             A.FlgUpg

                                                                ,B.FlgMoc            =             A.FlgMoc

                                                                ,B.FlgSMA           =             A.FlgSMA

                                                                ,B.FlgProcessing               =             A.FlgProcessing

                                                                ,B.FlgErosion      =             A.FlgErosion

                                                                ,B.FlgPNPA         =             A.FlgPNPA

                                                                ,B.FlgPercolation              =             A.FlgPercolation

                                                                ,B.FlgInMonth   =             A.FlgInMonth

                                                                ,B.FlgDirtyRow  =             A.FlgDirtyRow

                                                                ,B.DegDate         =             A.DegDate

                                                                ,B.EffectiveFromTimeKey             =             A.EffectiveFromTimeKey

                                                                ,B.EffectiveToTimeKey   =             A.EffectiveToTimeKey

                                                                ,B.CommonMocTypeAlt_Key      =             A.CommonMocTypeAlt_Key

                                                                ,B.InMonthMark              =             A.InMonthMark

                                                                ,B.MocStatusMark          =             A.MocStatusMark

                                                                ,B.SourceAlt_Key             =             A.SourceAlt_Key

                                                                ,B.BankAssetClass           =             A.BankAssetClass

                                                                ,B.Cust_Expo     =             A.Cust_Expo

                                                                ,B.MOCReason =             A.MOCReason

                                                                ,B.AddlProvisionPer        =             A.AddlProvisionPer

                                                                ,B.FraudDt          =             A.FraudDt

                                                                ,B.FraudAmount              =             A.FraudAmount

                                                                ,B.DegReason    =             A.DegReason

                                                                --,B.DateOfData =             A.DateOfData

                                                                ,B.CustMoveDescription               =             A.CustMoveDescription

                                                                ,B.TotOsCust      =             A.TotOsCust

                                                                --,B.MOCTYPE   =             A.MOCTYPE

                                                               

                                                               

 

                                                                FROM PRO.CustomerCal  A

INNER JOIN pro.CustomerCal_HIST B

ON b.EffectiveFromTimeKey<=@TIMEKEY and b.EffectiveToTimeKey>=@TIMEKEY

AND a.CustomerEntityID=b.CustomerEntityID

 

 

                UPDATE B SET

                                                                B.AccountEntityID          =             A.AccountEntityID

                                                                ,B.UcifEntityID   =             A.UcifEntityID

                                                                ,B.CustomerEntityID       =             A.CustomerEntityID

                                                                ,B.CustomerAcID             =             A.CustomerAcID

                                                                ,B.RefCustomerID            =             A.RefCustomerID

                                                                ,B.SourceSystemCustomerID      =             A.SourceSystemCustomerID

                                                                ,B.UCIF_ID          =             A.UCIF_ID

                                                                ,B.BranchCode  =             A.BranchCode

                                                                ,B.FacilityType   =             A.FacilityType

                                                                ,B.AcOpenDt      =             A.AcOpenDt

                                                                ,B.FirstDtOfDisb =             A.FirstDtOfDisb

                                                                ,B.ProductAlt_Key           =             A.ProductAlt_Key

                                                                ,B.SchemeAlt_key           =             A.SchemeAlt_key

                                                                ,B.SubSectorAlt_Key       =             A.SubSectorAlt_Key

                                                                ,B.SplCatg1Alt_Key         =             A.SplCatg1Alt_Key

                                                                ,B.SplCatg2Alt_Key         =             A.SplCatg2Alt_Key

                                                                ,B.SplCatg3Alt_Key         =             A.SplCatg3Alt_Key

                                                                ,B.SplCatg4Alt_Key         =             A.SplCatg4Alt_Key

                                                                ,B.SourceAlt_Key             =             A.SourceAlt_Key

                                                                ,B.ActSegmentCode        =             A.ActSegmentCode

                                                                ,B.InttRate          =             A.InttRate

                                                                ,B.Balance           =             A.Balance

                                                                ,B.BalanceInCrncy            =             A.BalanceInCrncy

                                                                ,B.CurrencyAlt_Key         =             A.CurrencyAlt_Key

                                                                ,B.DrawingPower             =             A.DrawingPower

                                                                ,B.CurrentLimit =             A.CurrentLimit

                                                                ,B.CurrentLimitDt             =             A.CurrentLimitDt

                                                                ,B.ContiExcessDt              =             A.ContiExcessDt

                                                                ,B.StockStDt       =             A.StockStDt

                                                                ,B.DebitSinceDt =             A.DebitSinceDt

                                                                ,B.LastCrDate     =             A.LastCrDate

                                                                ,B.PreQtrCredit =             A.PreQtrCredit

                                                                ,B.PrvQtrInt        =             A.PrvQtrInt

                                                                ,B.CurQtrCredit =             A.CurQtrCredit

                                                                ,B.CurQtrInt       =             A.CurQtrInt

                                                                ,B.InttServiced  =             A.InttServiced

                                                                ,B.IntNotServicedDt        =             A.IntNotServicedDt

                                                                ,B.OverdueAmt =             A.OverdueAmt

                                                                ,B.OverDueSinceDt         =             A.OverDueSinceDt

                                                                ,B.ReviewDueDt               =             A.ReviewDueDt

                                                                ,B.SecurityValue               =             A.SecurityValue

                                                                ,B.DFVAmt          =             A.DFVAmt

                                                                ,B.GovtGtyAmt =             A.GovtGtyAmt

                                                                ,B.CoverGovGur =             A.CoverGovGur

                                                                ,B.WriteOffAmount        =             A.WriteOffAmount

                                                                ,B.UnAdjSubSidy              =             A.UnAdjSubSidy

                                                                ,B.CreditsinceDt               =             A.CreditsinceDt

                                                                --,B.DPD_IntService        =             A.DPD_IntService

                                                                --,B.DPD_NoCredit          =             A.DPD_NoCredit

                                                                --,B.DPD_Overdrawn      =             A.DPD_Overdrawn

                                                                --,B.DPD_Overdue           =             A.DPD_Overdue

                                                                --,B.DPD_Renewal           =             A.DPD_Renewal

                                                                --,B.DPD_StockStmt        =             A.DPD_StockStmt

                                                                --,B.DPD_Max   =             A.DPD_Max

                                                                --,B.DPD_FinMaxType    =             A.DPD_FinMaxType

                                                                ,B.DegReason    =             A.DegReason

                                                                ,B.Asset_Norm =             A.Asset_Norm

                                                                ,B.REFPeriodMax             =             A.REFPeriodMax

                                                                ,B.RefPeriodOverdue     =             A.RefPeriodOverdue

                                                                ,B.RefPeriodOverDrawn =             A.RefPeriodOverDrawn

                                                                ,B.RefPeriodNoCredit     =             A.RefPeriodNoCredit

                                                                ,B.RefPeriodIntService   =             A.RefPeriodIntService

                                                                ,B.RefPeriodStkStatement           =             A.RefPeriodStkStatement

                                                                ,B.RefPeriodReview        =             A.RefPeriodReview

                                                                ,B.NetBalance   =             A.NetBalance

                                                                ,B.ApprRV           =             A.ApprRV

                                                                ,B.SecuredAmt =             A.SecuredAmt

                                                                ,B.UnSecuredAmt            =             A.UnSecuredAmt

                                                                ,B.ProvDFV         =             A.ProvDFV

                                                                ,B.Provsecured =             A.Provsecured

                                                                ,B.ProvUnsecured           =             A.ProvUnsecured

                                                                ,B.ProvCoverGovGur      =             A.ProvCoverGovGur

                                                                ,B.AddlProvision               =             A.AddlProvision

                                                                ,B.TotalProvision              =             A.TotalProvision

                                                                ,B.BankProvsecured       =             A.BankProvsecured

                                                                ,B.BankProvUnsecured  =             A.BankProvUnsecured

                                                                ,B.BankTotalProvision    =             A.BankTotalProvision

                                                                ,B.RBIProvsecured           =             A.RBIProvsecured

                                                                ,B.RBIProvUnsecured     =             A.RBIProvUnsecured

                                                                ,B.RBITotalProvision       =             A.RBITotalProvision

                                                                ,B.InitialNpaDt   =             A.InitialNpaDt

                                                                ,B.FinalNpaDt    =             A.FinalNpaDt

                                                                ,B.SMA_Dt          =             A.SMA_Dt

                                                                ,B.UpgDate         =             A.UpgDate

                                                                ,B.InitialAssetClassAlt_Key           =             A.InitialAssetClassAlt_Key

                                                                ,B.FinalAssetClassAlt_Key             =             A.FinalAssetClassAlt_Key

                                                                ,B.ProvisionAlt_Key        =             A.ProvisionAlt_Key

                                                                ,B.PNPA_Reason              =             A.PNPA_Reason

                                                                ,B.SMA_Class    =             A.SMA_Class

                                                                ,B.SMA_Reason =             A.SMA_Reason

                                                                ,B.FlgMoc            =             A.FlgMoc

                                                                ,B.MOC_Dt         =             A.MOC_Dt

                                                                ,B.CommonMocTypeAlt_Key      =             A.CommonMocTypeAlt_Key

                                                                --,B.DPD_SMA   =             A.DPD_SMA

                                                                ,B.FlgDeg             =             A.FlgDeg

                                                                ,B.FlgDirtyRow  =             A.FlgDirtyRow

                                                                ,B.FlgInMonth   =             A.FlgInMonth

                                                                ,B.FlgSMA           =             A.FlgSMA

                                                                ,B.FlgPNPA         =             A.FlgPNPA

                                                                ,B.FlgUpg             =             A.FlgUpg

                                                                ,B.FlgFITL             =             A.FlgFITL

                                                                ,B.FlgAbinitio     =             A.FlgAbinitio

                                                                ,B.NPA_Days     =             A.NPA_Days

                                                                ,B.RefPeriodOverdueUPG            =             A.RefPeriodOverdueUPG

                                                                ,B.RefPeriodOverDrawnUPG       =             A.RefPeriodOverDrawnUPG

                                                                ,B.RefPeriodNoCreditUPG            =             A.RefPeriodNoCreditUPG

                                                                ,B.RefPeriodIntServiceUPG          =             A.RefPeriodIntServiceUPG

                                                                ,B.RefPeriodStkStatementUPG   =             A.RefPeriodStkStatementUPG

                                                                ,B.RefPeriodReviewUPG =             A.RefPeriodReviewUPG

                                                                ,B.EffectiveFromTimeKey             =             A.EffectiveFromTimeKey

                                                                ,B.EffectiveToTimeKey   =             A.EffectiveToTimeKey

                                                                ,B.AppGovGur   =             A.AppGovGur

                                                                ,B.UsedRV          =             A.UsedRV

                                                                ,B.ComputedClaim          =             A.ComputedClaim

                                                                ,B.UPG_RELAX_MSME   =             A.UPG_RELAX_MSME

                                                                ,B.DEG_RELAX_MSME   =             A.DEG_RELAX_MSME

                                                                ,B.PNPA_DATE  =             A.PNPA_DATE

                                                                ,B.NPA_Reason =             A.NPA_Reason

                                                                ,B.PnpaAssetClassAlt_key            =             A.PnpaAssetClassAlt_key

                                                                ,B.DisbAmount =             A.DisbAmount

                                                                ,B.PrincOutStd  =             A.PrincOutStd

                                                                ,B.PrincOverdue               =             A.PrincOverdue

                                                                ,B.PrincOverdueSinceDt =             A.PrincOverdueSinceDt

                                                                --,B.DPD_PrincOverdue =             A.DPD_PrincOverdue

                                                                ,B.IntOverdue   =             A.IntOverdue

                                                                ,B.IntOverdueSinceDt    =             A.IntOverdueSinceDt

                                                                --,B.DPD_IntOverdueSince           =             A.DPD_IntOverdueSince

                                                                ,B.OtherOverdue             =             A.OtherOverdue

                                                                ,B.OtherOverdueSinceDt              =             A.OtherOverdueSinceDt

                                                                --,B.DPD_OtherOverdueSince     =             A.DPD_OtherOverdueSince

                                                                ,B.RelationshipNumber =             A.RelationshipNumber

                                                                ,B.AccountFlag  =             A.AccountFlag

                                                                ,B.CommercialFlag_AltKey           =             A.CommercialFlag_AltKey

                                                                ,B.Liability            =             A.Liability

                                                                ,B.CD     =             A.CD

                                                                ,B.AccountStatus             =             A.AccountStatus

                                                                ,B.AccountBlkCode1       =             A.AccountBlkCode1

                                                                ,B.AccountBlkCode2       =             A.AccountBlkCode2

                                                                ,B.ExposureType              =             A.ExposureType

                                                                ,B.Mtm_Value  =             A.Mtm_Value

                                                                ,B.BankAssetClass           =             A.BankAssetClass

                                                                ,B.NpaType        =             A.NpaType

                                                                ,B.SecApp           =             A.SecApp

                                                                ,B.BorrowerTypeID         =             A.BorrowerTypeID

                                                                ,B.LineCode        =             A.LineCode

                                                                ,B.ProvPerSecured          =             A.ProvPerSecured

                                                                ,B.ProvPerUnSecured    =             A.ProvPerUnSecured

                                                                ,B.MOCReason =             A.MOCReason

                                                                ,B.AddlProvisionPer        =             A.AddlProvisionPer

                                                                ,B.FlgINFRA        =             A.FlgINFRA

                                                                ,B.RepossessionDate      =             A.RepossessionDate

                                                                --,B.DateOfData =             A.DateOfData

                                                                ,B.DerecognisedInterest1             =             A.DerecognisedInterest1

                                                                ,B.DerecognisedInterest2             =             A.DerecognisedInterest2

                                                                ,B.ProductCode =             A.ProductCode

                                                                ,B.FlgLCBG          =             A.FlgLCBG

                                                                ,B.unserviedint =             A.unserviedint

                                                                ,B.AdvanceRecovery       =             A.AdvanceRecovery

                                                                ,B.NotionalInttAmt         =             A.NotionalInttAmt

                                                                ,B.OriginalBranchcode=A.OriginalBranchcode

                                                                ,B.PrvAssetClassAlt_Key=A.PrvAssetClassAlt_Key

                                                                ,B.MOCTYPE=A.MOCTYPE

                                                                ,B.FlgSecured=A.FlgSecured

 

 

from pro.AccountCal A

                INNER JOIN pro.AccountCal_Hist B

                                ON b.EffectiveFromTimeKey<=@TIMEKEY and b.EffectiveToTimeKey>=@TIMEKEY

                                AND a.AccountEntityID=b.AccountEntityID

 ---------------------------Commented because in SBM it is not present-----------------------

--Update A

--SET MOCProcessed='Y'

--Select Moc,* FROM MOC_ChangeDetails A

--Where EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey >=@TIMEKEY

--AND MOCPROCESSED='N'
 -------------------------^^^^^^^^^--Commented because in SBM it is not present---^^^^^^^--------------------
 

 

                                --ALTER TABLE PRO.ACCOUNTCAL DROP COLUMN DPD_IntService

                                --ALTER TABLE PRO.ACCOUNTCAL DROP COLUMN DPD_NoCredit

                                --ALTER TABLE PRO.ACCOUNTCAL DROP COLUMN DPD_Overdrawn

                                --ALTER TABLE PRO.ACCOUNTCAL DROP COLUMN DPD_Overdue

                                --ALTER TABLE PRO.ACCOUNTCAL DROP COLUMN DPD_Renewal

                                --ALTER TABLE PRO.ACCOUNTCAL DROP COLUMN DPD_StockStmt

                                --ALTER TABLE PRO.ACCOUNTCAL DROP COLUMN DPD_Max 

                                --ALTER TABLE PRO.ACCOUNTCAL DROP COLUMN DPD_FinMaxType

                                --ALTER TABLE PRO.ACCOUNTCAL DROP COLUMN DPD_SMA 

                                --ALTER TABLE PRO.ACCOUNTCAL DROP COLUMN DPD_PrincOverdue

                                --ALTER TABLE PRO.ACCOUNTCAL DROP COLUMN DPD_IntOverdueSince

                                --ALTER TABLE PRO.ACCOUNTCAL DROP COLUMN DPD_OtherOverdueSince

 

end

 

 

 

 

GO