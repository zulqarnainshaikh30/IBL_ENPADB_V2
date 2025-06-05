SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

 

 

 

 

/*=====================================

AUTHER : TRILOKI KHANNA

alter DATE : 27-11-2019

MODIFY DATE : 27-11-2019

DESCRIPTION : SMA MARKING

EXEC PRO.SMA_MARKING  @TIMEKEY=26997

====================================*/

CREATE PROCEDURE [PRO].[SMA_MARKING]

@TIMEKEY INT

WITH RECOMPILE

AS

BEGIN

    SET NOCOUNT ON

    BEGIN TRY

               

DECLARE @ProcessDate DATE=(SELECT DATE FROM SYSDAYMATRIX WHERE TIMEKEY=@TIMEKEY)

Declare @vEffectiveto INT Set @vEffectiveto= (select Timekey-1  FROM [dbo].Automate_Advances WHERE EXT_FLG='Y')

 

DECLARE @SMA0LowerValue INT =         (SELECT TOP 1 DPD_LowerValue FROM  DimSMAClassMaster where SrcSysClassCode='SMA0' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)

DECLARE @SMA0HigherValue INT =         (SELECT TOP 1 DPD_HigherValue FROM DimSMAClassMaster where SrcSysClassCode='SMA0' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)

DECLARE @SMA1LowerValue INT =         (SELECT TOP 1 DPD_LowerValue FROM DimSMAClassMaster where SrcSysClassCode='SMA1' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)

DECLARE @SMA1HigherValue INT =         (SELECT TOP 1 DPD_HigherValue FROM DimSMAClassMaster where SrcSysClassCode='SMA1' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)

DECLARE @SMA2LowerValue INT =         (SELECT TOP 1 DPD_LowerValue FROM DimSMAClassMaster where SrcSysClassCode='SMA2' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)

DECLARE @SMA2HigherValue INT =         (SELECT TOP 1 DPD_HigherValue FROM DimSMAClassMaster where SrcSysClassCode='SMA2' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)

 

 

 

IF OBJECT_ID('TEMPDB..#DPD') IS NOT NULL

                DROP TABLE  #DPD

 

select AccountEntityID,UcifEntityID,CustomerEntityID,CustomerAcID,

RefCustomerID,SourceSystemCustomerID,UCIF_ID,IntNotServicedDt,LastCrDate,ContiExcessDt,OverDueSinceDt,ReviewDueDt,StockStDt,

RefPeriodIntService,RefPeriodNoCredit,RefPeriodOverDrawn,RefPeriodOverdue,RefPeriodReview,RefPeriodStkStatement,

 

0 AS DPD_IntService,

0 AS DPD_NoCredit,

DPD_Overdrawn,

DPD_Overdue,

0 AS DPD_Renewal,

0 AS DPD_StockStmt,

0 AS DPD_MAX

INTO #DPD

from  PRO.AccountCal  a

WHERE  isnull(A.DPD_Overdrawn,0)>30   OR  Isnull(A.DPD_Overdue,0)>0

AND ISNULL(A.FacilityType,'') NOT IN ('LC','BG','NF')

 

update a set DPD_Overdue=0

from #DPD a

inner join PRO.AccountCal b

on a.AccountEntityID=b.AccountEntityID

where b.FacilityType='CC'

 

----/*--------------IF ANY DPD IS NEGATIVE THEN ZERO---------------------------------*/

 

UPDATE #DPD SET DPD_IntService=0 WHERE isnull(DPD_IntService,0)<0

UPDATE #DPD SET DPD_NoCredit=0 WHERE isnull(DPD_NoCredit,0)<0

UPDATE #DPD SET DPD_Overdrawn=0 WHERE isnull(DPD_Overdrawn,0)<0

UPDATE #DPD SET DPD_Overdue=0 WHERE isnull(DPD_Overdue,0)<0

UPDATE #DPD SET DPD_Renewal=0 WHERE isnull(DPD_Renewal,0)<0

UPDATE #DPD SET DPD_StockStmt=0 WHERE isnull(DPD_StockStmt,0)<0

 

 

 

----/* CALCULATE MAX DPD */

 

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

                                FROM #DPD A

                                                WHERE (

                                                          isnull(DPD_IntService,0)>=isnull(RefPeriodIntService,0)

                   OR isnull(DPD_NoCredit,0)>=isnull(RefPeriodNoCredit,0)

                                                                   OR isnull(DPD_Overdrawn,0)>=isnull(RefPeriodOverDrawn,0)

                                                                   OR isnull(DPD_Overdue,0)>=isnull(RefPeriodOverdue,0)

                                                                   OR isnull(DPD_Renewal,0)>=isnull(RefPeriodReview,0)

                   OR isnull(DPD_StockStmt,0)>=isnull(RefPeriodStkStatement,0)

                                                      )

                                                    

                                                               

 

----         /*--------------INTIAL MAX DPD 0 FOR RE PROCESSING DATA-------------------------*/

 

                                UPDATE A SET A.DPD_Max=0

                                FROM #DPD A

                                  

 

 

----                         /*----------------FIND MAX DPD---------------------------------------*/

 

                                UPDATE   A SET A.DPD_Max= (CASE    WHEN (isnull(A.DPD_IntService,0)>=isnull(A.DPD_NoCredit,0) AND isnull(A.DPD_IntService,0)>=isnull(A.DPD_Overdrawn,0) AND    isnull(A.DPD_IntService,0)>=isnull(A.DPD_Overdue,0) AND  isnull(A.DPD_IntService,0)>=isnull(A.DPD_Renewal,0) AND isnull(A.DPD_IntService,0)>=isnull(A.DPD_StockStmt,0)) THEN isnull(A.DPD_IntService,0)

                                                                                                                                                                   WHEN (isnull(A.DPD_NoCredit,0)>=isnull(A.DPD_IntService,0) AND isnull(A.DPD_NoCredit,0)>=  isnull(A.DPD_Overdrawn,0) AND    isnull(A.DPD_NoCredit,0)>=isnull(A.DPD_Overdue,0) AND    isnull(A.DPD_NoCredit,0)>=  isnull(A.DPD_Renewal,0) AND isnull(A.DPD_NoCredit,0)>=isnull(A.DPD_StockStmt,0)) THEN   isnull(A.DPD_NoCredit ,0)

                                                                                                                                                                   WHEN (isnull(A.DPD_Overdrawn,0)>=isnull(A.DPD_NoCredit,0)  AND isnull(A.DPD_Overdrawn,0)>= isnull(A.DPD_IntService,0)  AND  isnull(A.DPD_Overdrawn,0)>=isnull(A.DPD_Overdue,0) AND   isnull(A.DPD_Overdrawn,0)>= isnull(A.DPD_Renewal,0) AND isnull(A.DPD_Overdrawn,0)>=isnull(A.DPD_StockStmt,0)) THEN  isnull(A.DPD_Overdrawn,0)

                                                                                                                                                                   WHEN (isnull(A.DPD_Renewal,0)>=isnull(A.DPD_NoCredit,0)    AND isnull(A.DPD_Renewal,0)>=   isnull(A.DPD_IntService,0)  AND  isnull(A.DPD_Renewal,0)>=isnull(A.DPD_Overdrawn,0)  AND  isnull(A.DPD_Renewal,0)>=   isnull(A.DPD_Overdue,0)  AND isnull(A.DPD_Renewal,0) >=isnull(A.DPD_StockStmt ,0)) THEN isnull(A.DPD_Renewal,0)

                                                                                                                                                                   WHEN (isnull(A.DPD_Overdue,0)>=isnull(A.DPD_NoCredit,0)    AND isnull(A.DPD_Overdue,0)>=   isnull(A.DPD_IntService,0)  AND  isnull(A.DPD_Overdue,0)>=isnull(A.DPD_Overdrawn,0)  AND  isnull(A.DPD_Overdue,0)>=   isnull(A.DPD_Renewal,0)  AND isnull(A.DPD_Overdue ,0)>=isnull(A.DPD_StockStmt ,0))  THEN   isnull(A.DPD_Overdue,0)

                                                                                                                                                                   ELSE isnull(A.DPD_StockStmt,0) END)

                                                 

                                FROM  #DPD a

                                WHERE  isnull(A.DPD_Overdrawn,0)>0   OR  Isnull(A.DPD_Overdue,0)>0

 

 

UPDATE A SET A.SMA_CLASS=NULL

             ,A.SMA_REASON=NULL

                                     ,A.SMA_DT=NULL

                                     ,A.FLGSMA=NULL

FROM PRO.ACCOUNTCAL A

 

 

UPDATE A SET A.SMA_CLASS=

   (CASE  WHEN dpd.DPD_Max  BETWEEN @SMA0LowerValue AND @SMA0HigherValue  THEN 'SMA_0'

                      WHEN dpd.DPD_Max  BETWEEN @SMA1LowerValue AND @SMA1HigherValue  THEN 'SMA_1'

                                  WHEN dpd.DPD_Max  BETWEEN @SMA2LowerValue AND @SMA2HigherValue  THEN 'SMA_2'

                                  WHEN dpd.DPD_Max >@SMA2HigherValue THEN 'SMA_2'

                                  ELSE NULL

                                  END)

,A.SMA_REASON= (CASE

                                                                                 WHEN A.FACILITYTYPE IN ('CC','OD') AND ISNULL(DPD.DPD_INTSERVICE,0)=ISNULL(dpd.DPD_MAX,0) THEN 'DEGRADE BY INT NOT SERVICED'

                                                                                WHEN A.FACILITYTYPE IN ('CC','OD') AND ISNULL(DPD.DPD_NOCREDIT,0)=ISNULL(dpd.DPD_MAX,0) THEN 'DEGRADE BY NO CREDIT'

                                                                                WHEN A.FACILITYTYPE IN ('TL','DL','BP','BD','PC') AND ISNULL(dpd.DPD_OVERDUE,0)=ISNULL(dpd.DPD_MAX,0) THEN  'DEGRADE BY OVERDUE'

                                                                                WHEN A.FACILITYTYPE IN ('CC','OD') AND ISNULL(dpd.DPD_OVERDRAWN,0)=ISNULL(dpd.DPD_MAX,0) THEN 'DEGRADE BY CONTI EXCESS'

                                                                                WHEN A.FACILITYTYPE IN ('CC','OD') AND ISNULL(DPD.DPD_STOCKSTMT,0)=ISNULL(dpd.DPD_MAX,0) THEN 'DEGRADE BY STOCK STATEMENT'

                                                                                WHEN A.FACILITYTYPE IN ('CC','OD') AND ISNULL(DPD.DPD_RENEWAL,0)=ISNULL(dpd.DPD_MAX,0) THEN 'DEGRADE BY REVIEW DUE DATE'

                                                                  ELSE 'OTHER'

                                                                                END)

,A.SMA_DT=   DATEADD(DAY, -dpd.DPD_MAX + 1 ,@ProcessDate)

,A.FLGSMA='Y'

,a.DPD_SMA=dpd.DPD_MAX

FROM PRO.ACCOUNTCAL A INNER JOIN PRO.CUSTOMERCAL B ON A.CustomerEntityID=B.CustomerEntityID

INNER JOIN AdvAcBasicDetail ABD

                  ON A.AccountEntityID=ABD.AccountEntityId

                  AND (ABD.EffectiveFromTimeKey<=@TIMEKEY AND ABD.EffectiveToTimeKey>=@TIMEKEY)

                                  AND ABD.ReferencePeriod in(61,91,90)              

                INNER JOIN #DPD dpd on dpd.AccountEntityId=a.AccountEntityId

                WHERE ISNULL(B.FLGPROCESSING,'N')='N' AND ISNULL(FINALASSETCLASSALT_KEY,1)=1

--AND ISNULL(A.BALANCE,0)>0

 and A.ASSET_NORM<>'ALWYS_STD'

AND ( isnull(dpd.DPD_Overdrawn,0)>=0  OR isnull(dpd.DPD_Overdue,0)>=0 )

AND ISNULL(DPD.DPD_MAX,0)>0

 

UPDATE A SET A.SMA_CLASS=

   (CASE  WHEN dpd.DPD_MAX  BETWEEN 276 AND 305  THEN 'SMA_0'

                      WHEN dpd.DPD_MAX  BETWEEN 306 AND 335  THEN 'SMA_1'

                                  WHEN dpd.DPD_MAX  BETWEEN 336 AND 365  THEN 'SMA_2'

                                  WHEN dpd.DPD_MAX >366 THEN 'SMA_2'

                                  ELSE NULL

                                  END)

 

                                                ,A.SMA_REASON= (CASE

                                                                                 WHEN A.FACILITYTYPE IN ('CC','OD') AND ISNULL(DPD.DPD_INTSERVICE,0)=ISNULL(DPD.DPD_MAX,0) THEN 'DEGRADE BY INT NOT SERVICED'

                                                                                WHEN A.FACILITYTYPE IN ('CC','OD') AND ISNULL(DPD.DPD_NOCREDIT,0)=ISNULL(DPD.DPD_MAX,0) THEN 'DEGRADE BY NO CREDIT'

                                                                                WHEN A.FACILITYTYPE IN ('TL','DL','BP','BD','PC') AND ISNULL(DPD.DPD_OVERDUE,0)=ISNULL(dpd.DPD_MAX,0) THEN  'DEGRADE BY OVERDUE'

                                                                                WHEN A.FACILITYTYPE IN ('CC','OD') AND ISNULL(DPD.DPD_OVERDRAWN,0)=ISNULL(DPD.DPD_MAX,0) THEN 'DEGRADE BY CONTI EXCESS'

                                                                                WHEN A.FACILITYTYPE IN ('CC','OD') AND ISNULL(DPD.DPD_STOCKSTMT,0)=ISNULL(DPD.DPD_MAX,0) THEN 'DEGRADE BY STOCK STATEMENT'

                                                                                WHEN A.FACILITYTYPE IN ('CC','OD') AND ISNULL(DPD.DPD_RENEWAL,0)=ISNULL(DPD.DPD_MAX,0) THEN 'DEGRADE BY REVIEW DUE DATE'

                                                                               

                                                                  ELSE 'OTHER'

                                                                                END)

                                                ,A.SMA_DT=   DATEADD(DAY, -dpd.DPD_MAX+1 ,@PROCESSDATE)

                                                ,A.FLGSMA='Y'

                                                ,a.DPD_SMA=dpd.DPD_MAX                                                       

FROM PRO.ACCOUNTCAL A INNER JOIN PRO.CUSTOMERCAL B ON A.CustomerEntityID=B.CustomerEntityID

INNER JOIN AdvAcBasicDetail ABD

                  ON A.AccountEntityID=ABD.AccountEntityId

                  AND (ABD.EffectiveFromTimeKey<=@TIMEKEY AND ABD.EffectiveToTimeKey>=@TIMEKEY)

                  AND ABD.ReferencePeriod in(366,365)

                  INNER JOIN #DPD DPD on dpd.AccountEntityId=a.AccountEntityId

                WHERE ISNULL(B.FLGPROCESSING,'N')='N' AND ISNULL(FINALASSETCLASSALT_KEY,1)=1

   --AND ISNULL(A.BALANCE,0)>0

   and A.ASSET_NORM<>'ALWYS_STD'

AND ( isnull(DPD.DPD_Overdrawn,0)>=0  OR isnull(DPD.DPD_Overdue,0)>=0 )

AND ISNULL(DPD.DPD_MAX,0)>275

 

 

/*------SMA MARKING FOR CUSTOMER LEVEL-------------------------*/

 

UPDATE A SET A.FLGSMA=NULL

             ,A.SMA_CLASS_KEY=NULL

                                     ,A.SMA_DT=NULL

                                   FROM PRO.CUSTOMERCAL A

 

UPDATE A SET A.FLGSMA='Y'

FROM PRO.CUSTOMERCAL A INNER JOIN PRO.ACCOUNTCAL B ON A.CustomerEntityID =B.CustomerEntityID

WHERE B.FLGSMA='Y'

 

 

IF OBJECT_ID('TEMPDB..#TEMPTABLE_SMACLASS') IS NOT NULL

   DROP TABLE #TEMPTABLE_SMACLASS

 

SELECT A.CustomerEntityID,MAX(CASE WHEN SMA_CLASS='SMA_0' THEN  1

                             WHEN SMA_CLASS='SMA_1' THEN  2

                                                                                                                WHEN SMA_CLASS='SMA_2' THEN  3 ELSE 0 END ) MAXSMA_CLASS

                                                                                                                ,MIN(A.SMA_Dt) AS SMA_Dt

                               

INTO #TEMPTABLE_SMACLASS

FROM PRO.ACCOUNTCAL A INNER JOIN PRO.CUSTOMERCAL B

ON A.CustomerEntityID=B.CustomerEntityID AND  B.FLGSMA='Y'

GROUP BY A.CustomerEntityID

 

UPDATE A SET A.SMA_CLASS_KEY=B.MAXSMA_CLASS,A.SMA_DT=B.SMA_Dt

FROM PRO.CUSTOMERCAL A  INNER JOIN  #TEMPTABLE_SMACLASS B ON A.CustomerEntityID=B.CustomerEntityID

WHERE A.FLGSMA='Y'

 

 

 

UPDATE A SET A.FLGSMA='Y'

FROM PRO.CUSTOMERCAL A INNER JOIN PRO.ACCOUNTCAL B ON A.UCIF_ID =B.UCIF_ID

WHERE B.FLGSMA='Y'

 

 

IF OBJECT_ID('TEMPDB..#TEMPTABLE_SMACLASSUcif') IS NOT NULL

   DROP TABLE #TEMPTABLE_SMACLASSUcif

 

SELECT A.UCIF_ID,MAX(CASE WHEN SMA_CLASS='SMA_0' THEN  1

                          WHEN SMA_CLASS='SMA_1' THEN  2

                          WHEN SMA_CLASS='SMA_2' THEN  3 ELSE 0 END ) MAXSMA_CLASS

                  ,MIN(A.SMA_Dt) AS SMA_Dt

                              

INTO #TEMPTABLE_SMACLASSUcif

FROM PRO.ACCOUNTCAL A INNER JOIN PRO.CUSTOMERCAL B

ON A.UCIF_ID=B.UCIF_ID AND  B.FLGSMA='Y'

GROUP BY A.UCIF_ID

 

UPDATE A SET A.SMA_CLASS_KEY=B.MAXSMA_CLASS,A.SMA_DT=B.SMA_Dt

FROM PRO.CUSTOMERCAL A  INNER JOIN  #TEMPTABLE_SMACLASSUcif B ON A.UCIF_ID=B.UCIF_ID

WHERE A.FLGSMA='Y'

 

------Start SMA Calculation 13/04/2022 Added By Triloki Khanna------

 

IF OBJECT_ID('TEMPDB..#CTE_PERCSMA') IS NOT NULL

    DROP TABLE #CTE_PERCSMA

 

                SELECT * INTO

                                #CTE_PERCSMA

                FROM

                                (                              /* ADVANCE DATA */

                                                SELECT UCIF_ID,MAX(ISNULL(SMA_Class_Key,1)) SMA_Class_Key ,MIN(SMA_Dt) SMA_Dt

                                                ,'PERCOLATION BY LOAN UCIFID ' + A.UCIF_ID PercType,'SMA_0' AS SMA_CLASS

                                                FROM PRO.CUSTOMERCAL A WHERE ( UCIF_ID IS NOT NULL and UCIF_ID<>'0' ) AND  FlgSMA='Y'

                                                GROUP BY  UCIF_ID

                                                --UNION

                                                --/* INVESTMENT DATA */

                                                --SELECT UcifId UCIF_ID,MAX(CASE WHEN A.SMA_CLASS='SMA_0' THEN  1

                                                --                                                                                                                   WHEN A.SMA_CLASS='SMA_1' THEN  2

                                                --                                                                                                                   WHEN A.SMA_CLASS='SMA_2' THEN  3

                                                --                                                                                                                   ELSE 0 END ) SMA_CLASS_KEY  ,MIN(A.SMA_Dt) SMA_Dt

                                                --,'PERCOLATION BY INVESTMENT UCIFID '+ C.UcifId PercType,'SMA_0' AS SMA_CLASS

                                                --FROM InvestmentFinancialDetail A

                                                --                INNER JOIN InvestmentBasicDetail B

                                                --                                ON A.InvEntityId =B.InvEntityId

                                                --                                AND A.EffectiveFromTimeKey <=@TIMEKEY AND A.EffectiveToTimeKey >=@TIMEKEY

                                                --                                AND B.EffectiveFromTimeKey <=@TIMEKEY AND B.EffectiveToTimeKey >=@TIMEKEY

                                                --                INNER JOIN InvestmentIssuerDetail C

                                                --                                ON C.IssuerEntityId=B.IssuerEntityId

                                                --                                AND C.EffectiveFromTimeKey <=@TIMEKEY AND C.EffectiveToTimeKey >=@TIMEKEY

                                                --WHERE  A.FlgSMA='Y'

                                                --GROUP BY  UcifId

                                               

                                )A

 

                                UPDATE #CTE_PERCSMA SET SMA_CLASS='SMA_0' WHERE SMA_CLASS_KEY=1

                                UPDATE #CTE_PERCSMA SET SMA_CLASS='SMA_1' WHERE SMA_CLASS_KEY=2

                                UPDATE #CTE_PERCSMA SET SMA_CLASS='SMA_2' WHERE SMA_CLASS_KEY=3

 

                               

 

IF OBJECT_ID('TEMPDB..#CTE_PERCSMAAccountwise') IS NOT NULL

    DROP TABLE #CTE_PERCSMAAccountwise

                                SELECT CustomerAcID,SMA_Reason,PercType,a.UCIF_ID,SMA_Dt,SMA_CLASS

                                into #CTE_PERCSMAAccountwise

                                FROM (

                                select   aCCOUNTeNTITYID,b.CustomerAcID, SMA_Reason,b.DPD_Max,PercType + b.CustomerAcID as PercType,a.UCIF_ID,A.SMA_Dt,A.SMA_CLASS

                                from #CTE_PERCSMA a

                                inner join pro.ACCOUNTCAL b

                                on a.UCIF_ID=b.UCIF_ID

                                and a.SMA_CLASS=b.SMA_Class

                                and a.SMA_Dt=b.SMA_Dt

                                --and SMA_Reason not like '%per%'

                                and PercType like '%LOAN%'

                                ) a

                                inner join (select   a.UCIF_ID ,MIN(aCCOUNTeNTITYID)aCCOUNTeNTITYID

                                from #CTE_PERCSMA a

                                inner join pro.ACCOUNTCAL b

                                on a.UCIF_ID=b.UCIF_ID

                                and a.SMA_CLASS=b.SMA_Class

                                and a.SMA_Dt=b.SMA_Dt

                                --and SMA_Reason not like '%per%'

                                and PercType like '%LOAN%'

                                GROUP BY A.UCIF_ID

                                ) b on a.aCCOUNTeNTITYID = b.aCCOUNTeNTITYID

                --UNION

                --                SELECT IssuerId,SMA_Reason,PercType,a.UCIF_ID,SMA_Dt,SMA_CLASS

                --                FROM (

                --                select   C.IssuerEntityId,b.RefIssuerID as IssuerId, SMA_Reason,PercType + b.RefIssuerID as PercType,a.UCIF_ID,A.SMA_Dt,A.SMA_CLASS

                --                from #CTE_PERCSMA a

                --                INNER JOIN InvestmentIssuerDetail C

                --                                                                ON C.UcifId=A.UCIF_ID

                --                                                                AND C.EffectiveFromTimeKey <=@TIMEKEY AND C.EffectiveToTimeKey >=@TIMEKEY

                --                                                INNER JOIN InvestmentBasicDetail B

                --                                                                ON C.IssuerEntityId =B.IssuerEntityId

                --                                                                AND C.EffectiveFromTimeKey <=@TIMEKEY AND C.EffectiveToTimeKey >=@TIMEKEY

                --                                                                AND B.EffectiveFromTimeKey <=@TIMEKEY AND B.EffectiveToTimeKey >=@TIMEKEY

                --                                                INNER JOIN InvestmentFinancialDetail D

                --                                                ON D.InvEntityId =B.InvEntityId

                --                                                                AND D.EffectiveFromTimeKey <=@TIMEKEY AND D.EffectiveToTimeKey >=@TIMEKEY

                --                                                                AND B.EffectiveFromTimeKey <=@TIMEKEY AND B.EffectiveToTimeKey >=@TIMEKEY

                --                and a.SMA_CLASS=D.SMA_Class

                --                and a.SMA_Dt=D.SMA_Dt

                --                --and SMA_Reason not like '%per%'

                --                and PercType like '%INVESTMENT%'

                                --) a

                                --inner join (select                             a.UCIF_ID ,MIN(c.IssuerEntityId)IssuerEntityId

                                --                                                                                                from #CTE_PERCSMA a

                                --                                                                                                INNER JOIN InvestmentIssuerDetail C

                                --                                                ON C.UcifId=A.UCIF_ID

                                --                                                AND C.EffectiveFromTimeKey <=@TIMEKEY AND C.EffectiveToTimeKey >=@TIMEKEY

                                --                                INNER JOIN InvestmentBasicDetail B

                                --                                                ON C.IssuerEntityId =B.IssuerEntityId

                                --                                                AND C.EffectiveFromTimeKey <=@TIMEKEY AND C.EffectiveToTimeKey >=@TIMEKEY

                                --                                                AND B.EffectiveFromTimeKey <=@TIMEKEY AND B.EffectiveToTimeKey >=@TIMEKEY

                                --                                INNER JOIN InvestmentFinancialDetail D

                                --                                ON D.InvEntityId =B.InvEntityId

                                --                                                AND D.EffectiveFromTimeKey <=@TIMEKEY AND D.EffectiveToTimeKey >=@TIMEKEY

                                --                                                AND B.EffectiveFromTimeKey <=@TIMEKEY AND B.EffectiveToTimeKey >=@TIMEKEY

                                --and a.SMA_CLASS=D.SMA_Class

                                --and a.SMA_Dt=D.SMA_Dt

                                ----and SMA_Reason not like '%per%'

                                --and PercType like '%INVESTMENT%'

                                --GROUP BY A.UCIF_ID

                                --) b on a.IssuerEntityId = b.IssuerEntityId

               

 

                                UPDATE B

                                SET 

                                SMA_Dt=A.SMA_Dt                ,FlgSMA='Y',CustMoveDescription=A.SMA_CLASS,SMA_Class_Key=A.SMA_Class_Key

                                FROM #CTE_PERCSMA A

                                INNER JOIN PRO.customercal B

                                ON A.UCIF_ID=B.UCIF_ID

 

                                --UPDATE B

                                --SET  SMA_Dt=A.SMA_Dt,FlgSMA='Y'     ,SMA_CLASS=A.SMA_CLASS,SMA_Reason=PercType

                                --FROM #CTE_PERCSMAAccountwise A

                                --INNER JOIN PRO.ACCOUNTCAL B

                                --ON A.UCIF_ID=B.UCIF_ID

                                --WHERE ISNULL(B.FlgSMA,'N')='N'

 

                                --UPDATE B

                                --SET 

                                --SMA_Dt=A.SMA_Dt,FlgSMA='Y',SMA_CLASS=A.SMA_CLASS

                                --FROM #CTE_PERCSMA A

                                --INNER JOIN InvestmentIssuerDetail B

                                --ON A.UCIF_ID=B.UcifId

                                --WHERE B.EffectiveFromTimeKey<=@TIMEKEY AND B.EffectiveToTimeKey>=@TIMEKEY

 

--             UPDATE A SET SMA_Dt=A.SMA_Dt,FlgSMA='Y'   ,SMA_CLASS=A.SMA_CLASS,SMA_Reason=PercType

--FROM InvestmentFinancialDetail A

--INNER JOIN InvestmentBasicDetail B

--ON A.InvEntityId =B.InvEntityId

--AND A.EffectiveFromTimeKey <=@TIMEKEY AND A.EffectiveToTimeKey >=@TIMEKEY

--AND B.EffectiveFromTimeKey <=@TIMEKEY AND B.EffectiveToTimeKey >=@TIMEKEY

--INNER JOIN InvestmentIssuerDetail C  ON C.IssuerEntityId=B.IssuerEntityId

--AND C.EffectiveFromTimeKey <=@TIMEKEY AND C.EffectiveToTimeKey >=@TIMEKEY

--INNER JOIN #CTE_PERCSMAAccountwise D ON D.UCIF_ID=C.UcifId                       

--WHERE ISNULL(A.FlgSMA,'N')='N'

               

 

 

 

 

IF EXISTS(SELECT 1 FROM PRO.SMA_MOVEMENT_HISTORY WHERE TIMEKEY=@TIMEKEY)

BEGIN

  DELETE FROM PRO.SMA_MOVEMENT_HISTORY WHERE TIMEKEY=@TIMEKEY

END

 

 

IF OBJECT_ID('TEMPDB..#SMACLASS') IS NOT NULL

   DROP TABLE #SMACLASS

 

SELECT A.CustomerAcID,ISNULL(A.SMA_CLASS,CHOOSE(B.SMA_CLASS_KEY,'SMA_0','SMA_1','SMA_2'))  SMA_CLASS INTO #SMACLASS

FROM PRO.ACCOUNTCAL A INNER JOIN PRO.CUSTOMERCAL B ON A.REFCUSTOMERID=B.REFCUSTOMERID

AND A.CUSTOMERENTITYID=B.CUSTOMERENTITYID AND A.FLGSMA='Y'

WHERE B.FLGSMA='Y'

--AND  ISNULL(A.BALANCE,0)>0

AND ISNULL(B.SYSASSETCLASSALT_KEY,1)=1

 

UPDATE #SMACLASS SET SMA_CLASS=(CASE WHEN SMA_CLASS='SMA_0' THEN 1

                                                                                WHEN SMA_CLASS='SMA_1' THEN 2

                                                                                WHEN SMA_CLASS='SMA_2' THEN 3 ELSE SMA_CLASS END)

 

INSERT INTO PRO.SMA_MOVEMENT_HISTORY (TIMEKEY,CustomerAcID,PREVSTATUS,CURRENTSTATUS)

SELECT @TIMEKEY,B.CustomerAcID,A.SMA_CLASS,B.SMA_CLASS

FROM PRO.PREVSMASTATUS A  RIGHT OUTER JOIN  #SMACLASS B

ON A.CustomerAcID=B.CustomerAcID

WHERE B.SMA_CLASS IS NOT NULL AND ISNULL(A.SMA_CLASS,'')<>ISNULL(B.SMA_CLASS,'')

 

TRUNCATE TABLE PRO.PREVSMASTATUS

 

INSERT INTO PRO.PREVSMASTATUS

SELECT @TIMEKEY,CustomerAcID,SMA_CLASS

FROM #SMACLASS

 

   UPDATE PRO.CUSTOMERCAL SET CustMoveDescription='STD' WHERE SYSASSETCLASSALT_KEY=1

   UPDATE PRO.CUSTOMERCAL SET CustMoveDescription='SUB' WHERE SYSASSETCLASSALT_KEY=2

   UPDATE PRO.CUSTOMERCAL SET CustMoveDescription='DB1' WHERE SYSASSETCLASSALT_KEY=3

   UPDATE PRO.CUSTOMERCAL SET CustMoveDescription='DB2' WHERE SYSASSETCLASSALT_KEY=4

   UPDATE PRO.CUSTOMERCAL SET CustMoveDescription='DB3' WHERE SYSASSETCLASSALT_KEY=5

   UPDATE PRO.CUSTOMERCAL SET CustMoveDescription='LOS' WHERE SYSASSETCLASSALT_KEY=6

   UPDATE PRO.CUSTOMERCAL SET CustMoveDescription='SMA_0' WHERE SMA_CLASS_KEY=1

   UPDATE PRO.CUSTOMERCAL SET CustMoveDescription='SMA_1' WHERE SMA_CLASS_KEY=2

   UPDATE PRO.CUSTOMERCAL SET CustMoveDescription='SMA_2' WHERE SMA_CLASS_KEY=3

 

   UPDATE PRO.AccountCal SET SMA_CLASS='STD' WHERE FinalAssetClassAlt_Key=1 AND  SMA_CLASS is NULL

   UPDATE PRO.AccountCal SET SMA_CLASS='SUB' WHERE FinalAssetClassAlt_Key=2 AND  SMA_CLASS is NULL

   UPDATE PRO.AccountCal SET SMA_CLASS='DB1' WHERE FinalAssetClassAlt_Key=3  AND  SMA_CLASS is NULL

   UPDATE PRO.AccountCal SET SMA_CLASS='DB2' WHERE FinalAssetClassAlt_Key=4  AND  SMA_CLASS is NULL

   UPDATE PRO.AccountCal SET SMA_CLASS='DB3' WHERE FinalAssetClassAlt_Key=5  AND  SMA_CLASS is NULL

   UPDATE PRO.AccountCal SET SMA_CLASS='LOS' WHERE FinalAssetClassAlt_Key=6 AND  SMA_CLASS is NULL

 

  

  if EXISTS  ( select  1  from PRO.ACCOUNT_MOVEMENT_HISTORY where  [EffectiveFromTimeKey]= @Timekey)

                  begin

                                print 'NO NEDD TO INSERT DATA'

                  end

else

begin

                IF OBJECT_ID ('TEMPDB..#ACCOUNT_MOVEMENT_HISTORY') IS NOT NULL

                DROP TABLE #ACCOUNT_MOVEMENT_HISTORY

 

 

create TABLE #ACCOUNT_MOVEMENT_HISTORY (

                [UCIF_ID] [varchar](50) NULL,

                [RefCustomerID] [varchar](50) NULL,

                [SourceSystemCustomerID] [varchar](50) NULL,

                [CustomerAcID] [varchar](225) NULL,

                [FinalAssetClassAlt_Key] [int] NULL,

                [FinalNpaDt] [date] NULL,

                [EffectiveFromTimeKey] [int] NULL,

                [EffectiveToTimeKey] [int] NULL,

                [MovementFromStatus] [varchar](10) NULL,

                [MovementToStatus]   [varchar](10) NULL,

                [TotOsAcc] DECIMAL(18,2),

                MovementFromDate date,  

                MovementToDate           date     

 

                )

 

                INSERT INTO       #ACCOUNT_MOVEMENT_HISTORY

                                                (

                                                                                UCIF_ID,

                                                                                RefCustomerID,

                                                                                SourceSystemCustomerID,

                                                                                CustomerAcID,

                                                                                FinalAssetClassAlt_Key,

                                                                                FinalNpaDt,

                                                                                EffectiveFromTimeKey,

                                                                                EffectiveToTimeKey,

                                                                                MovementFromStatus,

                                                                                MovementToStatus,

                                                                                TotOsAcc,

                                                                                MovementFromDate , 

                                                                                MovementToDate          

                                    )

                                SELECT

                                                   UCIF_ID,

                                                   RefCustomerID,

                                                   SourceSystemCustomerID,

                                                   CustomerAcID,

                                                   FinalAssetClassAlt_Key,

                                                   FinalNpaDt,

                                                   EffectiveFromTimeKey,

                                                   49999 AS  EffectiveToTimeKey

                                                   ,SMA_CLASS AS MovementFromStatus

                                                   ,SMA_CLASS AS MovementToStatus

                                                   ,ISNULL(Balance,0) as TotOsAcc,

                                                               @ProcessDate MovementFromDate ,   

                                                                '2086-11-21' MovementToDate

  

     FROM  PRO.ACCOUNTCAL

   

  

  INSERT  INTO  PRO.ACCOUNT_MOVEMENT_HISTORY

 

  (

                                                                                UCIF_ID,

                                                                                RefCustomerID,

                                                                                SourceSystemCustomerID,

                                                                                CustomerAcID,

                                                                                FinalAssetClassAlt_Key,

                                                                                FinalNpaDt,

                                                                                EffectiveFromTimeKey,

                                                                                EffectiveToTimeKey,

                                                                                MovementFromStatus,

                                                                                MovementToStatus

                                                                                ,TotOsAcc

                                                                               ,MovementFromDate   

                                                                                ,MovementToDate        

 

  )

                                SELECT

                   A.UCIF_ID,

                                                                                A.RefCustomerID,

                                                                                A.SourceSystemCustomerID,

                                                                                A.CustomerAcID,

                                                                                A.FinalAssetClassAlt_Key,

                                                                                A.FinalNpaDt,

                                                                                A.EffectiveFromTimeKey,

                                                                                A.EffectiveToTimeKey,

                                                                                ISNULL(B.MovementTOStatus,A.MovementFromStatus),

                                                                                A.MovementToStatus,

                                                                                ISNULL(A.TotOsAcc,0) AS TotOsAcc

                                                                               ,A.MovementFromDate 

                                                                                ,A.MovementToDate    

 

                                                                FROM #ACCOUNT_MOVEMENT_HISTORY A

                                                                                LEFT JOIN PRO.ACCOUNT_MOVEMENT_HISTORY B ON A.CustomerAcID=B.CustomerAcID

                                                                                AND B.EFFECTIVETOTimekey=49999

 

                                                                WHERE 

                                                       (CASE WHEN  B.CustomerAcID IS NULL THEN 1

                                                                                                WHEN B.CustomerAcID IS NOT NULL AND  A.MOVEMENTFROMSTATUS<>B.MOVEMENTTOSTATUS THEN 1 END )=1

 

                UPDATE AA

                                                SET

                                                 EffectiveToTimeKey = @vEffectiveto

                                                ,MovementToDate=DATEADD(DD,-1,@ProcessDate)

                FROM PRO.ACCOUNT_MOVEMENT_HISTORY AA

                                LEFT JOIN #ACCOUNT_MOVEMENT_HISTORY B ON  AA.CustomerAcID=B.CustomerAcID AND B.EffectiveToTimeKey =49999

                                WHERE AA.EffectiveToTimeKey = 49999

                                and B.CustomerAcID is null

 

 

   UPDATE AA

                SET

                                 EffectiveToTimeKey = @vEffectiveto

                                ,MovementToDate=DATEADD(DD,-1,@ProcessDate)

                FROM PRO.ACCOUNT_MOVEMENT_HISTORY AA

                WHERE AA.EffectiveToTimeKey = 49999 AND AA.EffectiveFROMTimeKey<@TIMEKEY

                AND  EXISTS (SELECT 1 FROM #ACCOUNT_MOVEMENT_HISTORY BB

                                                                                WHERE AA.CustomerAcID=BB.CustomerAcID

                                                                                AND BB.EffectiveToTimeKey =49999

                                                                               

                                                                                AND AA.MOVEMENTTOSTATUS<>BB.MOVEMENTTOSTATUS

                                                                )

 

   ---- -- COMMENTED ON 13102021 FOR OPTIMISE - TABIKNG TME TO UPDATE

 

  --------UPDATE A SET MovementFromDate=B.DATE

  --------  FROM PRO.ACCOUNT_MOVEMENT_HISTORY  A

  -------- inner join sysdaymatrix B on A.EffectiveFromTimeKey=B.TimeKey

 

  -------- UPDATE A SET MovementToDate=B.DATE

  --------  FROM PRO.ACCOUNT_MOVEMENT_HISTORY  A

  -------- inner join sysdaymatrix B on A.EffectiveToTimeKey=B.TimeKey

 

   END

 

  if EXISTS  ( select  1  from PRO.CUSTOMER_MOVEMENT_HISTORY where  [EffectiveFromTimeKey]= @Timekey)

                  begin

                                print 'NO NEDD TO INSERT DATA'

                  end

else

begin

                IF OBJECT_ID ('TEMPDB..#Customer_MOVEMENT_HISTORY') IS NOT NULL

                DROP TABLE #Customer_MOVEMENT_HISTORY

 

 

create TABLE #Customer_MOVEMENT_HISTORY (

                [UCIF_ID] [varchar](50) NULL,

                [RefCustomerID] [varchar](50) NULL,

                [SourceSystemCustomerID] [varchar](50) NULL,

                [CustomerName] [varchar](225) NULL,

                [SysAssetClassAlt_Key] [int] NULL,

                [SysNPA_Dt] [date] NULL,

                [EffectiveFromTimeKey] [int] NULL,

                [EffectiveToTimeKey] [int] NULL,

                [MovementFromStatus] [varchar](10) NULL,

                [MovementToStatus]   [varchar](10) NULL,

                [TotOsCust] decimal(18,2)

               ,MovementFromDate   DATE  -- ADDED  ON 13102021 FOR OPTIMISE - TABIKNG TME TO UPDATE

                ,MovementToDate                         DATE -- ADDED  ON 13102021 FOR OPTIMISE - TABIKNG TME TO UPDATE

 

                )

 

 

                INSERT INTO       #Customer_MOVEMENT_HISTORY

                                                (

                                                                                UCIF_ID,

                                                                                RefCustomerID,

                                                                                SourceSystemCustomerID,

                                                                                CustomerName,

                                                                                SysAssetClassAlt_Key,

                                                                                SysNPA_Dt,

                                                                                EffectiveFromTimeKey,

                                                                                EffectiveToTimeKey,

                                                                                MovementFromStatus,

                                                                                MovementToStatus,

                                                                                totOsCust

                                                                               ,MovementFromDate   -- ADDED  ON 13102021 FOR OPTIMISE - TABIKNG TME TO UPDATE

                                                                                ,MovementToDate         -- ADDED  ON 13102021 FOR OPTIMISE - TABIKNG TME TO UPDATE

                                    )

                                                SELECT

                                                   UCIF_ID,

                                                   RefCustomerID,

                                                   SourceSystemCustomerID,

                                                   CustomerName,

                                                   SysAssetClassAlt_Key,

                                                   SysNPA_Dt,

                                                   EffectiveFromTimeKey,

                                                   49999 AS  EffectiveToTimeKey

                                                   ,CustMoveDescription AS MovementFromStatus

                                                   ,CustMoveDescription AS MovementToStatus

                                                   ,ISNULL(TotOsCust,0) AS TotOsCust

                                                               ,@ProcessDate MovementFromDate   -- ADDED  ON 13102021 FOR OPTIMISE - TABIKNG TME TO UPDATE

                                                                ,'2086-11-21' MovementToDate -- ADDED  ON 13102021 FOR OPTIMISE - TABIKNG TME TO UPDATE

 

 

     FROM  PRO.CustomerCal

   

  

  INSERT  INTO  PRO.CUSTOMER_MOVEMENT_HISTORY

 

  (

                                                                                UCIF_ID,

                                                                                RefCustomerID,

                                                                                SourceSystemCustomerID,

                                                                                CustomerName,

                                                                                SysAssetClassAlt_Key,

                                                                                SysNPA_Dt,

                                                                                EffectiveFromTimeKey,

                                                                                EffectiveToTimeKey,

                                                                                MovementFromStatus,

                                                                                MovementToStatus,

                                                                                TotOsCust

                                                                               ,MovementFromDate   -- ADDED  ON 13102021 FOR OPTIMISE - TABIKNG TME TO UPDATE

                                                                                ,MovementToDate         -- ADDED  ON 13102021 FOR OPTIMISE - TABIKNG TME TO UPDATE

 

  )

  SELECT

 

                   A.UCIF_ID,

                                                                                A.RefCustomerID,

                                                                                A.SourceSystemCustomerID,

                                                                                A.CustomerName,

                                                                                A.SysAssetClassAlt_Key,

                                                                                A.SysNPA_Dt,

                                                                                A.EffectiveFromTimeKey,

                                                                                A.EffectiveToTimeKey,

                                                                                ISNULL(B.MovementTOStatus,A.MovementFromStatus),

                                                                                A.MovementToStatus,

                                                                                ISNULL(A.TotOsCust,0) AS TotOsCust

                                                                               ,A.MovementFromDate   -- ADDED  ON 13102021 FOR OPTIMISE - TABIKNG TME TO UPDATE

                                                                                ,A.MovementToDate     -- ADDED  ON 13102021 FOR OPTIMISE - TABIKNG TME TO UPDATE

 

 

                                                                                FROM #Customer_MOVEMENT_HISTORY A

                                                                                LEFT JOIN PRO.CUSTOMER_MOVEMENT_HISTORY B ON A.SourceSystemCustomerID=B.SourceSystemCustomerID

                                                                                AND B.EFFECTIVETOTimekey=49999

 

WHERE 

                                                       (CASE WHEN  B.SourceSystemCustomerID IS NULL THEN 1

                                                                                                WHEN B.SourceSystemCustomerID IS NOT NULL AND  A.MOVEMENTFROMSTATUS<>B.MOVEMENTTOSTATUS THEN 1 END )=1

 

UPDATE AA

SET

                                EffectiveToTimeKey = @vEffectiveto

                                ,MovementToDate=DATEADD(DD,-1,@ProcessDate) -- ADDED  ON 13102021 FOR OPTIMISE - TABIKNG TME TO UPDATE

FROM PRO.CUSTOMER_MOVEMENT_HISTORY AA

LEFT JOIN #Customer_MOVEMENT_HISTORY B ON  AA.SourceSystemCustomerID=B.SourceSystemCustomerID AND B.EffectiveToTimeKey =49999

WHERE AA.EffectiveToTimeKey = 49999

and B.SourceSystemCustomerID is null

 

 

   UPDATE AA

SET

 EffectiveToTimeKey = @vEffectiveto

,MovementToDate=DATEADD(DD,-1,@ProcessDate) -- ADDED  ON 13102021 FOR OPTIMISE - TABIKNG TME TO UPDATE

 

FROM PRO.CUSTOMER_MOVEMENT_HISTORY AA

WHERE AA.EffectiveToTimeKey = 49999 AND AA.EffectiveFROMTimeKey<@TIMEKEY

AND  EXISTS (SELECT 1 FROM #Customer_MOVEMENT_HISTORY BB

 

                                                                WHERE AA.SourceSystemCustomerID=BB.SourceSystemCustomerID

                                                                AND BB.EffectiveToTimeKey =49999

                                                                --AND AA.MOVEMENTFROMSTATUS<>BB.MOVEMENTTOSTATUS

                                                                AND AA.MOVEMENTTOSTATUS<>BB.MOVEMENTTOSTATUS

                                                                )

 

  ---- -- COMMENTED  ON 13102021 FOR OPTIMISE - TABIKNG TME TO UPDATE

 

  ------UPDATE A SET MovementFromDate=B.DATE

  ------  FROM PRO.Customer_MOVEMENT_HISTORY  A

  ------ inner join sysdaymatrix B on A.EffectiveFromTimeKey=B.TimeKey

 

  ------ UPDATE A SET MovementToDate=B.DATE

  ------  FROM PRO.Customer_MOVEMENT_HISTORY  A

  ------ inner join sysdaymatrix B on A.EffectiveToTimeKey=B.TimeKey

 

 

   end

 

 

 

UPDATE PRO.ACLRUNNINGPROCESSSTATUS

SET COMPLETED='Y',ERRORDATE=NULL,ERRORDESCRIPTION=NULL,COUNT=ISNULL(COUNT,0)+1

WHERE RUNNINGPROCESSNAME='SMA_MARKING'

 

   

                -----------------Added for DashBoard 04-03-2021

Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='ASSET CLASSIFICATION'

 

END TRY

BEGIN  CATCH

 

 

     DROP TABLE #TEMPTABLE_SMACLASS

                DROP TABLE #SMACLASS

                DROP TABLE #ACCOUNT_MOVEMENT_HISTORY

                DROP TABLE #Customer_MOVEMENT_HISTORY

 

UPDATE PRO.ACLRUNNINGPROCESSSTATUS

SET COMPLETED='N',ERRORDATE=GETDATE(),ERRORDESCRIPTION=ERROR_MESSAGE(),COUNT=ISNULL(COUNT,0)+1

WHERE RUNNINGPROCESSNAME='SMA_MARKING'

 

END CATCH

SET NOCOUNT OFF

END

 

GO