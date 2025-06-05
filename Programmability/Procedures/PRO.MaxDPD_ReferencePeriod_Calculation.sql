SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

 

/*=========================================================

AUTHER : TRILOKI KHANNA

alter DATE : 27-11-2019

MODIFY DATE : 27-11-2019

DESCRIPTION : CALCULATED MAX DPD AND REGARD OF REFERENCE PERIOD ON  MAX DPD

--EXEC [Pro].[MaxDPD_ReferencePeriod_Calculation] 25140

==============================================================*/

CREATE PROCEDURE [PRO].[MaxDPD_ReferencePeriod_Calculation]

@TIMEKEY INT

with recompile

AS

BEGIN

     SET NOCOUNT ON;

     BEGIN TRY

                DECLARE @ProcessDate DATE=(SELECT DATE FROM SYSDAYMATRIX WHERE TimeKey=@TIMEKEY)

 

                IF OBJECT_ID('TEMPDB..#TEMPTABLE') IS NOT NULL

                    DROP TABLE #TEMPTABLE

 

                SELECT A.CustomerAcID

                                                ,CASE WHEN  isnull(A.DPD_IntService,0)>=isnull(A.RefPeriodIntService,0)                              THEN A.DPD_IntService  ELSE 0   END DPD_IntService, 

                                                 CASE WHEN  isnull(A.DPD_NoCredit,0)>=isnull(A.RefPeriodNoCredit,0)                                  THEN A.DPD_NoCredit    ELSE 0   END DPD_NoCredit, 

                                                 CASE WHEN  isnull(A.DPD_Overdrawn,0)>=isnull(A.RefPeriodOverDrawn              ,0)               THEN A.DPD_Overdrawn   ELSE 0   END DPD_Overdrawn, 

                                                 CASE WHEN  isnull(A.DPD_Overdue,0)>=isnull(A.RefPeriodOverdue         ,0)                               THEN A.DPD_Overdue     ELSE 0   END DPD_Overdue ,

                                                 CASE WHEN  isnull(A.DPD_Renewal,0)>=isnull(A.RefPeriodReview           ,0)                                           THEN A.DPD_Renewal     ELSE 0   END  DPD_Renewal ,

                                                CASE WHEN  isnull(A.DPD_StockStmt,0)>=isnull(A.RefPeriodStkStatement,0)       THEN A.DPD_StockStmt   ELSE 0   END DPD_StockStmt 

                                                 INTO #TEMPTABLE

                                                  FROM PRO.ACCOUNTCAL A inner join pro.CustomerCal B on A.SourceSystemCustomerID=B.SourceSystemCustomerID

                                                WHERE (

                                                          isnull(DPD_IntService,0)>=isnull(RefPeriodIntService,0)

                   OR isnull(DPD_NoCredit,0)>=isnull(RefPeriodNoCredit,0)

                                                                   OR isnull(DPD_Overdrawn,0)>=isnull(RefPeriodOverDrawn,0)

                                                                   OR isnull(DPD_Overdue,0)>=isnull(RefPeriodOverdue,0)

                                                                   OR isnull(DPD_Renewal,0)>=isnull(RefPeriodReview,0)

                   OR isnull(DPD_StockStmt,0)>=isnull(RefPeriodStkStatement,0)

                                                      )

                                                    

                                               

 

/*--------------INTIAL MAX DPD 0 FOR RE PROCESSING DATA-------------------------*/

 

UPDATE A SET A.DPD_Max=0

FROM PRO.ACCOUNTCAL A

 

 

 

/*----------------FIND MAX DPD---------------------------------------*/

 

UPDATE   A SET A.DPD_Max= (CASE    WHEN (isnull(A.DPD_IntService,0)>=isnull(A.DPD_NoCredit,0) AND isnull(A.DPD_IntService,0)>=isnull(A.DPD_Overdrawn,0) AND    isnull(A.DPD_IntService,0)>=isnull(A.DPD_Overdue,0) AND  isnull(A.DPD_IntService,0)>=isnull(A.DPD_Renewal,0) AND isnull(A.DPD_IntService,0)>=isnull(A.DPD_StockStmt,0)) THEN isnull(A.DPD_IntService,0)

                                   WHEN (isnull(A.DPD_NoCredit,0)>=isnull(A.DPD_IntService,0) AND isnull(A.DPD_NoCredit,0)>=  isnull(A.DPD_Overdrawn,0) AND    isnull(A.DPD_NoCredit,0)>=isnull(A.DPD_Overdue,0) AND    isnull(A.DPD_NoCredit,0)>=  isnull(A.DPD_Renewal,0) AND isnull(A.DPD_NoCredit,0)>=isnull(A.DPD_StockStmt,0)) THEN   isnull(A.DPD_NoCredit ,0)

                                                                                                                                   WHEN (isnull(A.DPD_Overdrawn,0)>=isnull(A.DPD_NoCredit,0)  AND isnull(A.DPD_Overdrawn,0)>= isnull(A.DPD_IntService,0)  AND  isnull(A.DPD_Overdrawn,0)>=isnull(A.DPD_Overdue,0) AND   isnull(A.DPD_Overdrawn,0)>= isnull(A.DPD_Renewal,0) AND isnull(A.DPD_Overdrawn,0)>=isnull(A.DPD_StockStmt,0)) THEN  isnull(A.DPD_Overdrawn,0)

                                                                                                                                   WHEN (isnull(A.DPD_Renewal,0)>=isnull(A.DPD_NoCredit,0)    AND isnull(A.DPD_Renewal,0)>=   isnull(A.DPD_IntService,0)  AND  isnull(A.DPD_Renewal,0)>=isnull(A.DPD_Overdrawn,0)  AND  isnull(A.DPD_Renewal,0)>=   isnull(A.DPD_Overdue,0)  AND isnull(A.DPD_Renewal,0) >=isnull(A.DPD_StockStmt ,0)) THEN isnull(A.DPD_Renewal,0)

                                               WHEN (isnull(A.DPD_Overdue,0)>=isnull(A.DPD_NoCredit,0)    AND isnull(A.DPD_Overdue,0)>=   isnull(A.DPD_IntService,0)  AND  isnull(A.DPD_Overdue,0)>=isnull(A.DPD_Overdrawn,0)  AND  isnull(A.DPD_Overdue,0)>=   isnull(A.DPD_Renewal,0)  AND isnull(A.DPD_Overdue ,0)>=isnull(A.DPD_StockStmt ,0))  THEN   isnull(A.DPD_Overdue,0)

                                                                                                                                   ELSE isnull(A.DPD_StockStmt,0) END)

                                                 

FROM  PRO.AccountCal a

INNER JOIN PRO.CUSTOMERCAL C ON C.SourceSystemCustomerID=a.SourceSystemCustomerID

WHERE  (isnull(C.FlgProcessing,'N')='N')

AND

(isnull(A.DPD_IntService,0)>0   OR isnull(A.DPD_Overdrawn,0)>0   OR  Isnull(A.DPD_Overdue,0)>0             OR isnull(A.DPD_Renewal,0) >0 OR

isnull(A.DPD_StockStmt,0)>0 OR isnull(DPD_NoCredit,0)>0)

 

/*----------------DPD_FinMaxType ---------------------------------------*/

 

UPDATE   a SET a.DPD_FinMaxType= (CASE   WHEN (isnull(A.DPD_IntService,0)>= isnull(A.DPD_NoCredit,0)   AND isnull(A.DPD_IntService,0)>= isnull(A.DPD_Overdrawn,0)   AND  isnull(A.DPD_IntService,0)>= isnull(A.DPD_Overdue,0)                AND isnull(A.DPD_IntService,0)>= isnull(A.DPD_Renewal,0) AND isnull(A.DPD_IntService,0)>=isnull(A.DPD_StockStmt,0)) THEN 'RefPeriodIntService'

                                                                                                                                                                WHEN (isnull(A.DPD_NoCredit,0)>=   isnull(A.DPD_IntService,0) AND isnull(A.DPD_NoCredit,0)>=   isnull(A.DPD_Overdrawn,0)   AND  isnull(A.DPD_NoCredit,0)>=   isnull(A.DPD_Overdue,0)   AND isnull(A.DPD_NoCredit,0)>=  isnull(A.DPD_Renewal,0) AND  isnull(A.DPD_NoCredit,0)>=isnull(A.DPD_StockStmt,0)) THEN 'RefPeriodNoCredit'

                                                                                                                                                                WHEN (isnull(A.DPD_Overdrawn,0)>=  isnull(A.DPD_NoCredit,0)   AND isnull(A.DPD_Overdrawn,0)>=  isnull(A.DPD_IntService,0)  AND  isnull(A.DPD_Overdrawn,0)>=  isnull(A.DPD_Overdue,0)               AND isnull(A.DPD_Overdrawn,0)>= isnull(A.DPD_Renewal,0) AND  isnull(A.DPD_Overdrawn,0)>=isnull(A.DPD_StockStmt,0)) THEN 'RefPeriodOverDrawn'

                                                                                                                                                                WHEN (isnull(A.DPD_Renewal,0)>=    isnull(A.DPD_NoCredit,0)   AND isnull(A.DPD_Renewal,0)>=    isnull(A.DPD_IntService,0)  AND  isnull(A.DPD_Renewal,0)>=    isnull(A.DPD_Overdrawn,0)  AND isnull(A.DPD_Renewal,0)>= isnull(A.DPD_Overdue,0)  AND   isnull(A.DPD_Renewal,0) >=isnull(A.DPD_StockStmt ,0)) THEN 'RefPeriodReview'

                                                                                                                                                                WHEN (isnull(A.DPD_Overdue,0)>=    isnull(A.DPD_NoCredit,0)   AND isnull(A.DPD_Overdue,0)>=    isnull(A.DPD_IntService,0)  AND  isnull(A.DPD_Overdue,0)>=    isnull(A.DPD_Overdrawn,0)  AND isnull(A.DPD_Overdue,0)>=isnull(A.DPD_Renewal,0)  AND    isnull(A.DPD_Overdue,0) >=isnull(A.DPD_StockStmt,0) )  THEN 'RefPeriodOverdue'

                                                                                                                                   ELSE 'RefPeriodStkStatement' END)

                                                 

FROM  PRO.AccountCal a

INNER JOIN PRO.CUSTOMERCAL C ON C.SourceSystemCustomerID=a.SourceSystemCustomerID

WHERE

(

    ISNULL(A.DPD_INTSERVICE,0)>0  

 OR ISNULL(A.DPD_OVERDRAWN,0)>0  

 OR ISNULL(A.DPD_OVERDUE,0)>0          

 OR ISNULL(A.DPD_RENEWAL,0) >0

 OR ISNULL(A.DPD_STOCKSTMT,0)>0

 OR ISNULL(DPD_NOCREDIT,0)>0

)

-----------------------------Devolvement DPD Update cases-------------------

               

IF OBJECT_ID('TEMPDB..#DevolvedData') IS NOT NULL

   DROP TABLE #DevolvedData

Select RefCustomerID,customeracid,AcOpenDt,OverDueSinceDt,DPD_Overdue, DPD_Max

INTO #DevolvedData

from pro.ACCOUNTCAL

where ProductCode in( '202','203','204','235','237','248')

 

IF OBJECT_ID('TEMPDB..#CCODData') IS NOT NULL

   DROP TABLE #CCODData

Select RefCustomerID, MAX(DPD_Max) AS DPD_Max

INTO #CCODData

from pro.ACCOUNTCAL

where FacilityType IN('CC','OD') AND DPD_Max>0 AND ProductCode  in ( '101','104','111','126','145','146','195')

GROUP BY RefCustomerID

 

UPDATE C SET DPD_Max=A.DPD_Max,DPD_Overdue=A.DPD_Max,OverDueSinceDt=DATEADD(DAY,-A.DPD_Max+1,@ProcessDate)

FROM #CCODData A

INNER JOIN #DevolvedData B ON A.RefCustomerID=B.RefCustomerID

INNER JOIN PRO.ACCOUNTCAL C ON B.CustomerAcID=C.CustomerAcID

WHERE A.DPD_Max>C.DPD_Max

 

 

 

update A Set A.OverDueSinceDt = (CASE WHEN ISNULL(A.OverDueSinceDt,'1900-01-01') > ISNULL(B.OverDueSinceDt,'1900-01-01') THEN B.OverDueSinceDt ELSE A.OverDueSinceDt END)

from pro.ACCOUNTCAL A

INNER JOIN Pro.AccountCal_Hist B ON A.CustomerAcID = B.CustomerAcID

where A.ProductCode in ( '202','203','204','235','237','248')

and A.EffectiveFromTimeKey <= @Timekey and A.EffectiveToTimeKey >= @TIMEkey

and B.EffectiveFromTimeKey <= @Timekey - 1

and B.EffectiveToTimeKey >= @Timekey  - 1

--and ISNULL(A.Overduesincedt,'1900-01-01') <>  ISNULL(B.Overduesincedt,'1900-01-01')

 

 

UPDATE A SET  A.DPD_Overdue=0,a.DPD_Max=0

FROM PRO.AccountCal A

where ProductCode in( '202','203','204','235','237','248')

 

UPDATE A SET  A.DPD_Overdue =   (CASE WHEN  A.OverDueSinceDt IS NOT NULL   THEN  DATEDIFF(DAY,A.OverDueSinceDt,  @ProcessDate)+(CASE WHEN SourceAlt_Key=6 THEN 0 ELSE 1 END )  ELSE 0 END)

                                                ,A.DPD_Max =   (CASE WHEN  A.OverDueSinceDt IS NOT NULL   THEN  DATEDIFF(DAY,A.OverDueSinceDt,  @ProcessDate)+(CASE WHEN SourceAlt_Key=6 THEN 0 ELSE 1 END )  ELSE 0 END)

                               

FROM PRO.AccountCal A

where ProductCode in( '202','203','204','235','237','248')

 

 

 

 

               

/*-------Update REFPeriodMax---------------------------*/

 

 

IF OBJECT_ID('TEMPDB..#TEMPTABLE2') IS NOT NULL

   DROP TABLE #TEMPTABLE2

 

select A.CustomerAcID ,CASE  WHEN (isnull(A.DPD_IntService,0)>=isnull(A.DPD_NoCredit,0) AND isnull(A.DPD_IntService,0)>=isnull(A.DPD_Overdrawn,0) AND isnull(A.DPD_IntService,0)>=isnull(A.DPD_Overdue,0) AND isnull(A.DPD_IntService,0)>=isnull(A.DPD_Renewal,0) AND isnull(A.DPD_IntService,0)>=isnull(A.DPD_StockStmt,0))

                  THEN isnull(RefPeriodIntService,0)

                                                               

                                                                WHEN (isnull(A.DPD_NoCredit,0)>=isnull(A.DPD_IntService,0) AND isnull(A.DPD_NoCredit,0)>=isnull(A.DPD_Overdrawn,0) AND isnull(A.DPD_NoCredit,0)>=isnull(A.DPD_Overdue,0) AND isnull(A.DPD_NoCredit,0)>=isnull(A.DPD_Renewal,0) AND isnull(A.DPD_NoCredit,0)>=isnull(A.DPD_StockStmt,0))

                                                                   THEN isnull(RefPeriodNoCredit,0)

                                                               

                                                                WHEN (isnull(A.DPD_Overdrawn,0)>=isnull(A.DPD_NoCredit,0)  AND isnull(A.DPD_Overdrawn,0)>= isnull(A.DPD_IntService,0) AND  isnull(A.DPD_Overdrawn,0)>=isnull(A.DPD_Overdue,0) AND isnull(A.DPD_Overdrawn,0)>=isnull(A.DPD_Renewal,0) AND isnull(A.DPD_Overdrawn,0)>=isnull(A.DPD_StockStmt,0))

                                                                   THEN isnull(RefPeriodOverDrawn,0)

                                                               

                                                                WHEN (isnull(A.DPD_Renewal,0)>=isnull(A.DPD_NoCredit ,0) AND isnull(A.DPD_Renewal,0)>= isnull(A.DPD_IntService ,0) AND  isnull(A.DPD_Renewal,0)>=isnull(A.DPD_Overdrawn,0)  AND   isnull(A.DPD_Renewal,0)>=isnull(A.DPD_Overdue,0)  AND isnull(A.DPD_Renewal,0) >=isnull(A.DPD_StockStmt ,0))

                                                                   THEN isnull(RefPeriodReview,0)

                                                               

                                                                WHEN (isnull(A.DPD_Overdue,0)>=isnull(A.DPD_NoCredit ,0) AND isnull(A.DPD_Overdue,0)>= isnull(A.DPD_IntService ,0) AND  isnull(A.DPD_Overdue,0)>=isnull(A.DPD_Overdrawn,0)  AND   isnull(A.DPD_Overdue,0)>=isnull(A.DPD_Renewal,0)  AND isnull(A.DPD_Overdue,0) >=isnull(A.DPD_StockStmt,0) )

                                                        THEN isnull(RefPeriodOverdue,0)

                                                               

                                                                ELSE isnull(RefPeriodStkStatement,0)

                                                               

                                                                END AS REFPERIOD

 

INTO #TEMPTABLE2    FROM #TEMPTABLE A         INNER JOIN  PRO.ACCOUNTCAL B   ON A.CustomerAcID=B.CustomerAcID 

INNER JOIN PRO.CUSTOMERCAL C ON C.SourceSystemCustomerID=B.SourceSystemCustomerID

WHERE (isnull(C.FLGPROCESSING,'N')='N')

 

 

/*------- INTIAL REFPERIODMAX 0 FOR RE-PROCESSING----- */

 

UPDATE  B SET  B.REFPERIODMAX=0

FROM #TEMPTABLE2 A INNER JOIN PRO.ACCOUNTCAL B ON A.CustomerAcID=B.CustomerAcID

INNER JOIN PRO.CUSTOMERCAL C ON C.SourceSystemCustomerID=B.SourceSystemCustomerID

WHERE (isnull(C.FLGPROCESSING,'N')='N')

 

 

 

/*----CALCULATE REFPERIODMAX  REGARDING MAX DPD--------------*/

 

UPDATE  B SET  B.REFPERIODMAX=A.REFPERIOD

FROM #TEMPTABLE2 A INNER JOIN PRO.ACCOUNTCAL B ON A.CustomerAcID=B.CustomerAcID

INNER JOIN PRO.CUSTOMERCAL C ON C.SourceSystemCustomerID=B.SourceSystemCustomerID

WHERE (isnull(C.FLGPROCESSING,'N')='N')

/*---FOR HANDING NULL REFERENCE PERIOD ----------------------*/

 

UPDATE A SET A.REFPeriodMax=isnull(A.RefPeriodOverdue,0)

 FROM PRO.AccountCal A

WHERE isnull(FlgDeg,'N')='Y' AND ISNULL(InitialAssetClassAlt_Key,1)=1 AND Balance>0   AND ISNULL(REFPeriodMax,0)=0

AND ISNULL(DPD_Max,0)<ISNULL(RefPeriodOverdue,0) AND FacilityType IN('TL','DL','BP','BD','PC')

 

UPDATE A SET A.REFPeriodMax=isnull(A.RefPeriodIntService,0)

FROM PRO.AccountCal A

WHERE isnull(FlgDeg,'N')='Y' AND ISNULL(InitialAssetClassAlt_Key,1)=1 AND Balance>0

AND ISNULL(DPD_Max,0)<ISNULL(RefPeriodIntService,0) AND FacilityType IN('CC','OD') AND  ISNULL(REFPeriodMax,0)=0

 

 

----Added By Triloki 10/06/2021  But if ALL DPD ZERO than REFPeriodMax is null---

 

update pro.accountcal set REFPeriodMax=RefPeriodNoCredit  where REFPeriodMax is null  and DPD_FinMaxType='RefPeriodNoCredit'

update pro.accountcal set REFPeriodMax=RefPeriodOverdue  where REFPeriodMax is null  and DPD_FinMaxType='RefPeriodOverdue'

update pro.accountcal set REFPeriodMax=RefPeriodOverDrawn  where REFPeriodMax is null  and DPD_FinMaxType='RefPeriodOverDrawn'

update pro.accountcal set REFPeriodMax=RefPeriodStkStatement  where REFPeriodMax is null  and DPD_FinMaxType='RefPeriodStkStatement'

update pro.accountcal set REFPeriodMax=RefPeriodReview  where REFPeriodMax is null  and DPD_FinMaxType='RefPeriodReview'

 

UPDATE PRO.ACLRUNNINGPROCESSSTATUS

                SET COMPLETED='Y',ERRORDATE=NULL,ERRORDESCRIPTION=NULL,COUNT=ISNULL(COUNT,0)+1

                WHERE RUNNINGPROCESSNAME='MaxDPD_ReferencePeriod_Calculation'

 

 

                DROP TABLE #TEMPTABLE

                DROP TABLE #TEMPTABLE2

 

-----------------Added for DashBoard 04-03-2021

--Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='ASSET CLASSIFICATION'

 

END TRY

BEGIN  CATCH

 

                UPDATE PRO.ACLRUNNINGPROCESSSTATUS

                SET COMPLETED='N',ERRORDATE=GETDATE(),ERRORDESCRIPTION=ERROR_MESSAGE(),COUNT=ISNULL(COUNT,0)+1

                WHERE RUNNINGPROCESSNAME='MaxDPD_ReferencePeriod_Calculation'

END CATCH

 

SET NOCOUNT OFF;

 

END

 

 

 

 

 

 

 

 

 

 

GO