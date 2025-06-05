SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

 

 

/*=========================================

AUTHER : TRILOKI KHANNA

alter DATE : 27-11-2019

MODIFY DATE : 27-11-2019

DESCRIPTION : MARKING OF FLGDEG AND DEG REASON

 --EXEC [Pro].[Marking_FlgDeg_Degreason] @TIMEKEY=26929

=============================================*/

CREATE PROCEDURE [PRO].[Marking_FlgDeg_Degreason]

@TIMEKEY INT

AS

BEGIN

  SET NOCOUNT ON

   BEGIN TRY

DECLARE @ProcessDate DATE=(SELECT DATE FROM SYSDAYMATRIX WHERE TimeKey=@TIMEKEY)

 

/*---------------INTIAL LEVEL FLG DEG SET N------------------------------------------*/

 

UPDATE A SET A.FLGDEG='N'

FROM PRO.AccountCal A

 

/*---------------UPDATE DEG FLAG AT CUSTOMER LEVEL------------------------------------*/

 

UPDATE B SET B.FlgDeg='N' FROM   PRO.CustomerCal B

 

/*---------------UPDATE DEG FLAG AT ACCOUNT LEVEL-----------------------------------------*/

UPDATE A SET A.FLGDEG  =(CASE			WHEN  (ISNULL(A.Balance,0)>0 and ISNULL(A.DPD_INTSERVICE,0)>=A.REFPERIODINTSERVICE)  THEN 'Y'

                                          WHEN  (ISNULL(A.Balance,0)>0 and  ISNULL(A.DPD_OVERDRAWN,0)>=A.REFPERIODOVERDRAWN)    THEN 'Y'

                                          WHEN  (ISNULL(A.Balance,0)>0 and  ISNULL(A.DPD_NOCREDIT,0)>=A.REFPERIODNOCREDIT)     THEN 'Y'

                            WHEN   (ISNULL(A.Balance,0)>0 and ISNULL(A.DPD_OVERDUE,0) >=A.REFPERIODOVERDUE)       THEN 'Y'

                            WHEN   ISNULL(A.DPD_STOCKSTMT,0)>=A.REFPERIODSTKSTATEMENT THEN 'Y'

                                          WHEN   ISNULL(A.DPD_RENEWAL,0)>=A.REFPERIODREVIEW         THEN 'Y'

                                    ELSE 'N'  END)

FROM PRO.ACCOUNTCAL A   INNER JOIN PRO.CustomerCal B ON A.RefCustomerID =B.RefCustomerID

WHERE  (a.FinalAssetClassAlt_Key IN(SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortNameEnum IN('STD') and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY))

AND (ISNULL(A.Asset_Norm,'NORMAL')<>'ALWYS_STD')

AND (B.FlgProcessing='N')

AND ISNULL(InMonthMark,'N')='Y'

AND ISNULL(B.FlgMoc,'N')='N'

--AND ISNULL(A.Balance,0)>0

AND ISNULL(A.FacilityType,'') NOT IN ('LC','BG','NF')
 

UPDATE A SET A.FLGDEG='Y'

FROM PRO.ACCOUNTCAL A 

WHERE InttServiced='N' and FinalAssetClassAlt_Key=1

AND ISNULL(A.FacilityType,'') not IN ('LC','BG','NF')
and IntNotServicedDt is  not null -- amar added on 26042024


 

UPDATE pro.ACCOUNTCAL SET FLGDEG='N'
from pro.ACCOUNTCAL

where FLGDEG='Y'

--and FacilityType='TL'

and
(isnull(IntOverdue,0)=0
and
isnull(PrincOverdue,0)=0
and
isnull(OtherOverdue,0)=0
and
isnull(OverdueAmt,0)=0
and 
isnull(balance,0)=0
)
and(ISNULL(DPD_RENEWAL,0)<=REFPERIODREVIEW and ISNULL(DPD_STOCKSTMT,0)<=REFPERIODSTKSTATEMENT)


 

/* ------------------------UPDATE DEG FLAG AT CUSTOMER LEVEL----------------------------------*/

 

UPDATE B SET B.FlgDeg='Y' FROM PRO.ACCOUNTCAL A INNER JOIN  PRO.CustomerCal B

ON A.RefCustomerID=B.RefCustomerID

WHERE A.FlgDeg='Y' AND (B.FlgProcessing='N')

 

/*---------------------ASSIGNE DEG REASON------------------------------------------------------*/

 

 

UPDATE A SET A.DegReason= (CASE WHEN ISNULL(A.DegReason,'') <> '' THEN ISNULL(A.DegReason,'')+',DEGRADE BY INT NOT SERVICED'   ELSE 'DEGRADE BY INT NOT SERVICED' END)

FROM PRO.AccountCal A INNER JOIN PRO.CustomerCal B ON A.RefCustomerID =B.RefCustomerID

WHERE (B.FlgProcessing='N')  AND (A.FLGDEG='Y' AND (A.DPD_INTSERVICE>=A.REFPERIODINTSERVICE OR A.InttServiced='N'))

UPDATE A SET A.DegReason= (CASE WHEN ISNULL(A.DegReason,'') <> '' THEN ISNULL(A.DegReason,'')+',DEGRADE BY CONTI EXCESS'   ELSE 'DEGRADE BY CONTI EXCESS' END)

FROM PRO.AccountCal A INNER JOIN PRO.CustomerCal B ON A.RefCustomerID =B.RefCustomerID

WHERE (B.FlgProcessing='N')  AND (A.FLGDEG='Y' AND A.DPD_OVERDRAWN>=A.REFPERIODOVERDRAWN)

 

UPDATE A SET DegReason= (CASE WHEN ISNULL(A.DegReason,'') <> '' THEN ISNULL(A.DegReason,'')+',DEGRADE BY NO CREDIT'   ELSE 'DEGRADE BY NO CREDIT' END) 

FROM PRO.AccountCal A INNER JOIN PRO.CustomerCal B ON A.RefCustomerID =B.RefCustomerID

WHERE (B.FlgProcessing='N')  AND (A.FLGDEG='Y' AND A.DPD_NOCREDIT>=A.REFPERIODNOCREDIT )

 

UPDATE A SET DegReason= (CASE WHEN ISNULL(A.DegReason,'') <> '' THEN ISNULL(A.DegReason,'')+',DEGRADE BY STOCK STATEMENT'   ELSE 'DEGRADE BY STOCK STATEMENT' END)   

FROM PRO.AccountCal A INNER JOIN PRO.CustomerCal B ON A.RefCustomerID =B.RefCustomerID

WHERE (B.FlgProcessing='N')  AND (A.FLGDEG='Y' AND A.DPD_STOCKSTMT>=A.REFPERIODSTKSTATEMENT)

 

UPDATE A SET A.DEGREASON= (CASE WHEN ISNULL(A.DegReason,'') <> '' THEN ISNULL(A.DegReason,'')+',DEGRADE BY REVIEW DUE DATE'   ELSE 'DEGRADE BY REVIEW DUE DATE' END)   

FROM PRO.AccountCal A INNER JOIN PRO.CustomerCal B ON A.RefCustomerID =B.RefCustomerID

WHERE (B.FlgProcessing='N')  AND (A.FLGDEG='Y' AND A.DPD_RENEWAL>=A.REFPERIODREVIEW)

 

UPDATE A SET A.DegReason= (CASE WHEN ISNULL(A.DegReason,'') <> '' THEN ISNULL(A.DegReason,'')+',DEGRADE BY OVERDUE'   ELSE 'DEGRADE BY OVERDUE' END)            

FROM PRO.AccountCal A INNER JOIN PRO.CustomerCal B ON A.RefCustomerID =B.RefCustomerID

WHERE (B.FlgProcessing='N')  AND (A.FLGDEG='Y' AND A.DPD_OVERDUE >=A.REFPERIODOVERDUE)

 

UPDATE A SET DegReason=B.DegReason

FROM PRO.AccountCal A INNER JOIN PRO.CustomerCal B ON A.SourceSystemCustomerID =B.SourceSystemCustomerID

WHERE (B.FlgProcessing='N')  AND (A.FLGDEG='N')AND B.DegReason IS NOT NULL AND A.FinalAssetClassAlt_Key>1 AND A.DegReason IS NULL

 

      UPDATE PRO.ACLRUNNINGPROCESSSTATUS

      SET COMPLETED='Y',ERRORDATE=NULL,ERRORDESCRIPTION=NULL,COUNT=ISNULL(COUNT,0)+1

      WHERE RUNNINGPROCESSNAME='Marking_FlgDeg_Degreason'

 

      -----------------Added for DashBoard 04-03-2021

Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='ASSET CLASSIFICATION'

 

END TRY

BEGIN  CATCH

 

      UPDATE PRO.ACLRUNNINGPROCESSSTATUS

      SET COMPLETED='N',ERRORDATE=GETDATE(),ERRORDESCRIPTION=ERROR_MESSAGE(),COUNT=ISNULL(COUNT,0)+1

      WHERE RUNNINGPROCESSNAME='Marking_FlgDeg_Degreason'

 

END CATCH

SET NOCOUNT OFF

END

 

 

GO