SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

 

 

 

/*=========================================

AUTHER : TRILOKI SHANKER KHANNA

alter DATE : 27-11-2019

MODIFY DATE : 27-09-2019

DESCRIPTION : MARKING OF FlgPNPA AND DEG REASON

EXEC [PRO].[Marking_FlgPNPA] 26281

=============================================*/

CREATE PROCEDURE [PRO].[Marking_FlgPNPA]

@TIMEKEY INT

with recompile

AS

BEGIN

   SET NOCOUNT ON

  BEGIN TRY

   

--declare @TIMEKEY int=26279

DECLARE @ProcessDate DATE= (SELECT DATE FROM SYSDAYMATRIX WHERE TIMEKEY=@TIMEKEY)

 

----DECLARE @PNPAProcessDate DATE  =(SELECT EOMONTH(DATE) FROM SYSDAYMATRIX WHERE CAST(DATE AS DATE) =@ProcessDate)--(SELECT DATE FROM SYSDAYMATRIX WHERE TIMEKEY=@TIMEKEY

DECLARE @PNPAProcessDate DATE  = DATEADD(DD,30,@ProcessDate) --APPLIED LOGIC OF 30DAYS ROLLING PERIOD AS ADVISED BY sITARAM sIR ON CALL AFTER DISCUSSED WITH sHARMA sIR AND aSHISH SIR

 

DECLARE @PNPA_DAYS INT =DATEDIFF(DAY,@PROCESSDATE,@PNPAProcessDate)

 

/*--------------------INTIAL LEVEL FlgPNPA SET N-------------------------------------------- */

 

 

UPDATE A SET A.FlgPNPA='N',PNPA_DATE=NULL,PnpaAssetClassAlt_key=NULL ,PNPA_Reason =NULL FROM PRO.AccountCal A 

UPDATE A SET A.FlgPNPA='N',PNPA_Dt=NULL, PNPA_Class_Key=NULL FROM PRO.CUSTOMERCAL A 

 

/*---------------UPDATE FlgPNPA FLAG AT ACCOUNT LEVEL----------------------------------------------------*/

UPDATE A SET A.FlgPNPA =(CASE   WHEN  ((A.DPD_INTSERVICE+@PNPA_DAYS)>=A.REFPERIODINTSERVICE)   THEN 'Y'

                                                                                                                                WHEN  ((A.DPD_NOCREDIT+@PNPA_DAYS)>  =A.REFPERIODNOCREDIT)       THEN 'Y'

                                                                                                                                WHEN  ((A.DPD_OVERDUE+@PNPA_DAYS) >  =A.REFPERIODOVERDUE)        THEN 'Y'

                                                                                                                                WHEN  ((A.DPD_STOCKSTMT+@PNPA_DAYS)> =A.REFPERIODSTKSTATEMENT)  THEN 'Y'

                                                                                                                                WHEN  ((A.DPD_RENEWAL+@PNPA_DAYS)>   =A.RefPeriodReview)          THEN 'Y'

                                                                                                                                WHEN  ((A.DPD_Overdrawn+@PNPA_DAYS)> =A.REFPERIODOVERDRAWN)          THEN 'Y'

                                                                                                                ELSE 'N'  END)

FROM PRO.ACCOUNTCAL A   INNER JOIN PRO.CustomerCal B ON A.RefCustomerID =B.RefCustomerID

WHERE  (a.FinalAssetClassAlt_Key IN(SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortNameEnum IN('STD') and EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY))

AND (ISNULL(A.Asset_Norm,'NORMAL')<>'ALWYS_STD')

AND (isnull(B.FlgProcessing,'N')='N')

AND ISNULL(A.FLGMOC,'N')<>'Y'

and isnull(A.BALANCE,0)>0

 

 

/*-------------------------ASSIGNE PNPA REASON-------------------------------------------------*/

                                               

UPDATE A SET A.PNPA_Reason= ISNULL(A.PNPA_Reason,'')+',DEGRADE BY INT NOT SERVICED'

             ,A.PNPA_DATE=DATEADD(DAY,-(A.DPD_INTSERVICE+@PNPA_DAYS-ISNULL(A.REFPERIODINTSERVICE,0)),@PNPAProcessDate)

FROM PRO.AccountCal A

 INNER JOIN AdvAcBasicDetail ABD

                  ON A.AccountEntityID=ABD.AccountEntityId

                  AND (ABD.EffectiveFromTimeKey<=@TIMEKEY AND ABD.EffectiveToTimeKey>=@TIMEKEY)

                  --AND ABD.ReferencePeriod=91

WHERE  (A.FlgPNPA='Y' AND ((A.DPD_INTSERVICE+@PNPA_DAYS)>=ISNULL(REFPERIODINTSERVICE,0)))

 

 

UPDATE A SET A.PNPA_Reason= ISNULL(A.PNPA_Reason,'')+', DEGRADE BY CONTI EXCESS'

           ,A.PNPA_DATE=DATEADD(DAY,-(A.DPD_OVERDRAWN+@PNPA_DAYS-ISNULL(REFPERIODOVERDRAWN,0)),@PNPAProcessDate)

FROM PRO.AccountCal A

 INNER JOIN AdvAcBasicDetail ABD

                  ON A.AccountEntityID=ABD.AccountEntityId

                  AND (ABD.EffectiveFromTimeKey<=@TIMEKEY AND ABD.EffectiveToTimeKey>=@TIMEKEY)

                WHERE (A.FlgPNPA='Y' AND ((A.DPD_OVERDRAWN+@PNPA_DAYS)>=ISNULL(REFPERIODOVERDRAWN,0)))

 

 

UPDATE A SET A.PNPA_Reason= ISNULL(A.PNPA_Reason,'')+', DEGRADE BY OVERDUE'   

      ,A.PNPA_DATE=DATEADD(DAY,-(A.DPD_OVERDUE +@PNPA_DAYS-ISNULL(RefPeriodOverdue,0) ),@PNPAProcessDate)         

FROM PRO.AccountCal A

 INNER JOIN AdvAcBasicDetail ABD

                  ON A.AccountEntityID=ABD.AccountEntityId

                  AND (ABD.EffectiveFromTimeKey<=@TIMEKEY AND ABD.EffectiveToTimeKey>=@TIMEKEY)

                WHERE  (A.FlgPNPA='Y' AND ((A.DPD_OVERDUE +@PNPA_DAYS)>=ISNULL(RefPeriodOverdue,0))) 

 

 

 

UPDATE A SET A.PNPA_Reason= 'DEGRADE BY DEBIT BALANCE'   

      ,A.PNPA_DATE=DATEADD(DAY,-(A.DPD_OVERDUE +@PNPA_DAYS-ISNULL(RefPeriodOverdue,0) ),@PNPAProcessDate)         

FROM PRO.AccountCal A

INNER JOIN AdvAcBasicDetail ABD

                  ON A.AccountEntityID=ABD.AccountEntityId

                  AND (ABD.EffectiveFromTimeKey<=@TIMEKEY AND ABD.EffectiveToTimeKey>=@TIMEKEY)

 

INNER JOIN DimProduct C ON  A.ProductAlt_Key=C.ProductAlt_Key AND (C.EffectiveFromTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey)

WHERE (A.FlgPNPA='Y' AND ((A.DPD_OVERDUE +@PNPA_DAYS)>=ISNULL(RefPeriodOverdue,0))) 

AND A.DebitSinceDt IS NOT NULL AND ISNULL(C.SrcSysProductCode,'N')='SAVING'

 

 

UPDATE A SET PNPA_Reason= ISNULL(A.PNPA_Reason,'')+', DEGRADE BY NO CREDIT'  

         ,A.PNPA_DATE=DATEADD(DAY,-(A.DPD_NOCREDIT+@PNPA_DAYS-ISNULL(RefPeriodNoCredit,0) ),@PNPAProcessDate)

FROM PRO.AccountCal A --INNER JOIN PRO.CustomerCal B ON A.CustomerEntityID =B.CustomerEntityID -- Modification DONE 03/09/2019 TRILOKI

INNER JOIN AdvAcBasicDetail ABD

                  ON A.AccountEntityID=ABD.AccountEntityId

                  AND (ABD.EffectiveFromTimeKey<=@TIMEKEY AND ABD.EffectiveToTimeKey>=@TIMEKEY)

                  WHERE   (A.FlgPNPA='Y' AND (A.DPD_NOCREDIT+@PNPA_DAYS)>=ISNULL(RefPeriodNoCredit,0))

 

 

 

UPDATE A SET PNPA_Reason= ISNULL(A.PNPA_Reason,'')+', DEGRADE BY STOCK STATEMENT'

            ,A.PNPA_DATE=DATEADD(DAY,-(A.DPD_STOCKSTMT+@PNPA_DAYS-ISNULL(RefPeriodStkStatement,0) ),@PNPAProcessDate)  

FROM PRO.AccountCal A ---INNER JOIN PRO.CustomerCal B ON A.CustomerEntityID =B.CustomerEntityID -- Modification DONE 03/09/2019 TRILOKI

INNER JOIN AdvAcBasicDetail ABD

                  ON A.AccountEntityID=ABD.AccountEntityId

                  AND (ABD.EffectiveFromTimeKey<=@TIMEKEY AND ABD.EffectiveToTimeKey>=@TIMEKEY)

                WHERE  (A.FlgPNPA='Y' AND (A.DPD_STOCKSTMT+@PNPA_DAYS)>=ISNULL(RefPeriodStkStatement,0)) 

 

 

UPDATE A SET A.PNPA_Reason= ISNULL(A.PNPA_Reason,'')+', DEGRADE BY REVIEW DUE DATE'  

,A.PNPA_DATE=DATEADD(DAY,-(A.DPD_RENEWAL+@PNPA_DAYS-ISNULL(RefPeriodReview,0) ),@PNPAPROCESSDATE)   

FROM PRO.AccountCal A

INNER JOIN AdvAcBasicDetail ABD

                  ON A.AccountEntityID=ABD.AccountEntityId

                  AND (ABD.EffectiveFromTimeKey<=@TIMEKEY AND ABD.EffectiveToTimeKey>=@TIMEKEY)

                  WHERE  (A.FlgPNPA='Y' AND (A.DPD_RENEWAL+@PNPA_DAYS)>=ISNULL(RefPeriodReview,0))

 

 

 

/*-------------------UPDATE PNPA FLAG AT CUSTOMER LEVEL------------------------------------------*/

UPDATE B SET B.FlgPNPA='Y' FROM PRO.ACCOUNTCAL A INNER JOIN  PRO.CustomerCal B

ON A.CustomerEntityID=B.CustomerEntityID

WHERE A.FlgPNPA='Y' AND (B.FlgProcessing='N')

 

 

IF OBJECT_ID('TEMPDB..#TEMPTABLEPNPA') IS NOT NULL

  DROP TABLE #TEMPTABLEPNPA

 

SELECT A.CustomerEntityID,MIN(A.PNPA_DATE) PNPA_DATE  

                 ,(SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='SUB' AND EffectiveFromTimeKey<=26279 AND EffectiveToTimeKey>=26279) PNPA_Class_Key

                INTO #TEMPTABLEPNPA  

FROM PRO.ACCOUNTCAL A

INNER JOIN PRO.CUSTOMERCAL B

ON A.CustomerEntityID=B.CustomerEntityID

WHERE B.FLGPNPA='Y' AND (B.FLGPROCESSING='N')

GROUP BY A.CustomerEntityID

 

UPDATE A SET A.PNPA_DT=B.PNPA_DATE

                                                ,A.FlgPNPA ='Y'

                                                ,a.PNPA_Class_Key=b.PNPA_Class_Key

FROM PRO.CUSTOMERCAL A

INNER JOIN #TEMPTABLEPNPA B

ON A.CustomerEntityID=B.CustomerEntityID

               

update a set

                                a.PNPA_DATE =b.PNPA_Dt

                                ,a.FlgPNPA ='Y'

                                ,a.PnpaAssetClassAlt_key=b.PNPA_Class_Key

from PRO.ACCOUNTCAL a

                inner join PRO.CUSTOMERCAL b

                                on a.CustomerEntityID =b.CustomerEntityID

                                AND (ISNULL(A.Asset_Norm,'NORMAL')<>'ALWYS_STD')

                                And b.FlgPNPA='Y'

 

UPDATE A

                SET a.PNPA_Reason='Link By AccountId' + ' ' + B.CustomerAcID

--SELECT A.PNPA_Reason,B.PNPA_Reason, * 

from pro.ACCOUNTCAL A

INNER JOIN  pro.ACCOUNTCAL B

                ON A.CustomerEntityID =B.CustomerEntityID

                AND A.FlgPNPA ='Y'  AND   A.FlgPNPA ='Y'

                                AND A.PNPA_Reason IS NULL AND B.PNPA_Reason IS NOT NULL

                AND (ISNULL(A.Asset_Norm,'NORMAL')<>'ALWYS_STD')

 

 

 

/*-------------------UPDATE PNPA FLAG AT UCIF LEVEL------------------------------------------*/

UPDATE B SET B.FlgPNPA='Y'

FROM PRO.ACCOUNTCAL A INNER JOIN  PRO.CustomerCal B

ON A.UcifEntityID=B.UcifEntityID

WHERE A.FlgPNPA='Y' AND (B.FlgProcessing='N')

 

IF OBJECT_ID('TEMPDB..#CTE_CUSTOMERWISEBALANCEPNPA') IS NOT NULL

  DROP TABLE #CTE_CUSTOMERWISEBALANCEPNPA

 

SELECT A.UcifEntityID,MIN(A.PNPA_DATE) PNPA_DATE  

                 ,(SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='SUB' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY) PNPA_Class_Key

                INTO #CTE_CUSTOMERWISEBALANCEPNPA  

FROM PRO.ACCOUNTCAL A

INNER JOIN PRO.CUSTOMERCAL B

ON A.UcifEntityID=B.UcifEntityID

WHERE B.FLGPNPA='Y' AND (B.FLGPROCESSING='N')

GROUP BY A.UcifEntityID

 

UPDATE A SET A.PNPA_DT=B.PNPA_DATE

                                                ,A.FlgPNPA ='Y'

                                                ,a.PNPA_Class_Key=b.PNPA_Class_Key

FROM PRO.CUSTOMERCAL A

INNER JOIN #CTE_CUSTOMERWISEBALANCEPNPA B

ON A.UcifEntityID=B.UcifEntityID

 

 

update a set

                                a.PNPA_DATE =b.PNPA_DATE

                                ,a.FlgPNPA ='Y'

                                ,a.PnpaAssetClassAlt_key=b.PNPA_Class_Key

from PRO.ACCOUNTCAL a

                inner join #CTE_CUSTOMERWISEBALANCEPNPA b

                                on a.UcifEntityID =b.UcifEntityID

                                AND (ISNULL(A.Asset_Norm,'NORMAL')<>'ALWYS_STD')

 

update A

                SET a.PNPA_Reason='PERCOLATION BY UCIF ' + ' ' + B.UCIF_ID

FROM PRO.ACCOUNTCAL a

                inner join PRO.ACCOUNTCAL b

                                on a.UcifEntityID =b.UcifEntityID

WHERE b.FlgPNPA='Y' AND A.FlgPNPA='Y'

                AND A.PNPA_Reason IS NULL AND B.PNPA_Reason IS NOT NULL

                AND (ISNULL(A.Asset_Norm,'NORMAL')<>'ALWYS_STD')

 

 

                UPDATE PRO.ACLRUNNINGPROCESSSTATUS

                SET COMPLETED='Y',ERRORDATE=NULL,ERRORDESCRIPTION=NULL,COUNT=ISNULL(COUNT,0)+1

                WHERE RUNNINGPROCESSNAME='Marking_FlgPNPA'

 

                DROP TABLE #TEMPTABLEPNPA

                DROP TABLE #CTE_CUSTOMERWISEBALANCEPNPA

 

                -----------------Added for DashBoard 04-03-2021

--Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='ASSET CLASSIFICATION'

 

END TRY

BEGIN  CATCH

                UPDATE PRO.ACLRUNNINGPROCESSSTATUS

                SET COMPLETED='N',ERRORDATE=GETDATE(),ERRORDESCRIPTION=ERROR_MESSAGE(),COUNT=ISNULL(COUNT,0)+1

                WHERE RUNNINGPROCESSNAME='Marking_FlgPNPA'

END CATCH

SET NOCOUNT OFF

END

 

 

 

 

 

 

 

 

 

 

 

 

 

GO