SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

 

/*=========================================

AUTHER : TRILOKI KHANNA
alter DATE : 27-11-2019
MODIFY DATE : 27-11-2019
DESCRIPTION : CALCULATED NPA DATE
 --EXEC [PRO].[NPA_DATE_CALCULATION]  @TIMEKEY=25841
=============================================*/
CREATE PROCEDURE [PRO].[NPA_Date_Calculation]
@TIMEKEY INT
with recompile
AS
BEGIN
    SET NOCOUNT ON
   BEGIN TRY
 
DECLARE @INTTSERNORM VARCHAR(50)=(SELECT REFVALUE FROM PRO.REFPERIOD WHERE BUSINESSRULE='RECOVERYADJUSTMENT' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)  --'PROGRESSIVE'
DECLARE @ProcessDate DATE=(SELECT DATE FROM SysDayMatrix WHERE TimeKey=@TIMEKEY)

UPDATE   PRO.AccountCal SET InitialNpaDt=NULL WHERE (InitialNpaDt='1900-01-01'  OR InitialNpaDt='01/01/1900')
UPDATE   PRO.AccountCal SET FinalNpaDt=NULL   WHERE FinalNpaDt='1900-01-01'  OR FinalNpaDt='01/01/1900'

UPDATE   PRO.AccountCal SET InitialNpaDt=NULL,FinalNpaDt=NULL
FROM PRO.ACCOUNTCAL A INNER JOIN PRO.CustomerCal B ON A.REFCUSTOMERID=B.REFCUSTOMERID
WHERE (ISNULL(B.FlgProcessing,'N')='N' AND ISNULL(A.FLGDEG,'N')='Y')

/*------------CALCULATE NpaDt -------------------------------------*/

IF OBJECT_ID('TEMPDB..#TEMPTABLEDPD') IS NOT NULL
          DROP TABLE #TEMPTABLEDPD

       SELECT A.CustomerAcID
                  ,CASE WHEN  isnull(A.DPD_IntService,0)>=isnull(A.RefPeriodIntService,0)       THEN A.DPD_IntService  ELSE 0   END DPD_IntService, 
                   CASE WHEN  isnull(A.DPD_NoCredit,0)>=isnull(A.RefPeriodNoCredit,0)                 THEN A.DPD_NoCredit    ELSE 0   END DPD_NoCredit, 
                   CASE WHEN  isnull(A.DPD_Overdrawn,0)>=isnull(A.RefPeriodOverDrawn      ,0)       THEN A.DPD_Overdrawn   ELSE 0   END DPD_Overdrawn, 
                   CASE WHEN  isnull(A.DPD_Overdue,0)>=isnull(A.RefPeriodOverdue    ,0)             THEN A.DPD_Overdue     ELSE 0   END DPD_Overdue ,
                   CASE WHEN  isnull(A.DPD_Renewal,0)>=isnull(A.RefPeriodReview     ,0)               THEN A.DPD_Renewal     ELSE 0   END  DPD_Renewal ,
                   CASE WHEN  isnull(A.DPD_StockStmt,0)>=isnull(A.RefPeriodStkStatement,0)       THEN A.DPD_StockStmt   ELSE 0   END DPD_StockStmt 
                   INTO #TEMPTABLEDPD
             FROM PRO.ACCOUNTCAL A
                   WHERE (
                  				isnull(DPD_IntService,0)>=isnull(RefPeriodIntService,0)
							OR isnull(DPD_NoCredit,0)>=isnull(RefPeriodNoCredit,0)
                        	OR isnull(DPD_Overdrawn,0)>=isnull(RefPeriodOverDrawn,0)
                        	OR isnull(DPD_Overdue,0)>=isnull(RefPeriodOverdue,0)
                        	OR isnull(DPD_Renewal,0)>=isnull(RefPeriodReview,0)
							OR isnull(DPD_StockStmt,0)>=isnull(RefPeriodStkStatement,0)
                        )


IF OBJECT_ID('TEMPDB..#TEMPTABLENPA') IS NOT NULL
DROP TABLE #TEMPTABLENPA

select A.CustomerAcID ,CASE  WHEN (isnull(A.DPD_IntService,0)>=isnull(A.DPD_NoCredit,0) AND isnull(A.DPD_IntService,0)>=isnull(A.DPD_Overdrawn,0) AND isnull(A.DPD_IntService,0)>=isnull(A.DPD_Overdue,0) AND isnull(A.DPD_IntService,0)>=isnull(A.DPD_Renewal,0) AND isnull(A.DPD_IntService,0)>=isnull(A.DPD_StockStmt,0))
									THEN isnull(a.DPD_IntService,0)

							WHEN (isnull(A.DPD_NoCredit,0)>=isnull(A.DPD_IntService,0) AND isnull(A.DPD_NoCredit,0)>=isnull(A.DPD_Overdrawn,0) AND isnull(A.DPD_NoCredit,0)>=isnull(A.DPD_Overdue,0) AND isnull(A.DPD_NoCredit,0)>=isnull(A.DPD_Renewal,0) AND isnull(A.DPD_NoCredit,0)>=isnull(A.DPD_StockStmt,0))
      								THEN isnull(a.DPD_NoCredit,0)

							WHEN (isnull(A.DPD_Overdrawn,0)>=isnull(A.DPD_NoCredit,0)  AND isnull(A.DPD_Overdrawn,0)>= isnull(A.DPD_IntService,0) AND  isnull(A.DPD_Overdrawn,0)>=isnull(A.DPD_Overdue,0) AND isnull(A.DPD_Overdrawn,0)>=isnull(A.DPD_Renewal,0) AND isnull(A.DPD_Overdrawn,0)>=isnull(A.DPD_StockStmt,0))
      								THEN isnull(a.DPD_Overdrawn,0)

							WHEN (isnull(A.DPD_Renewal,0)>=isnull(A.DPD_NoCredit ,0) AND isnull(A.DPD_Renewal,0)>= isnull(A.DPD_IntService ,0) AND  isnull(A.DPD_Renewal,0)>=isnull(A.DPD_Overdrawn,0)  AND   isnull(A.DPD_Renewal,0)>=isnull(A.DPD_Overdue,0)  AND isnull(A.DPD_Renewal,0) >=isnull(A.DPD_StockStmt ,0))
      								THEN isnull(a.DPD_Renewal,0)

							WHEN (isnull(A.DPD_Overdue,0)>=isnull(A.DPD_NoCredit ,0) AND isnull(A.DPD_Overdue,0)>= isnull(A.DPD_IntService ,0) AND  isnull(A.DPD_Overdue,0)>=isnull(A.DPD_Overdrawn,0)  AND   isnull(A.DPD_Overdue,0)>=isnull(A.DPD_Renewal,0)  AND isnull(A.DPD_Overdue,0) >=isnull(A.DPD_StockStmt,0) )
      								THEN isnull(a.DPD_Overdue,0)
						ELSE isnull(a.DPD_StockStmt,0)
					END AS REFPERIODNPA
				INTO #TEMPTABLENPA    
		FROM #TEMPTABLEDPD A       
		INNER JOIN  PRO.ACCOUNTCAL B   ON A.CustomerAcID=B.CustomerAcID 

		UPDATE  A  SET FinalNpaDt= DATEADD(DAY,ISNULL(REFPERIODMAX,0),DATEADD(DAY,-ISNULL(REFPERIODNPA,0),@ProcessDate))
		FROM PRO.ACCOUNTCAL A INNER JOIN #TEMPTABLENPA B ON A.CustomerAcID=B.CustomerAcID
		WHERE  ISNULL(A.FLGDEG,'N')='Y'

		UPDATE   A SET  A.FINALNPADT=@ProcessDate 
		FROM PRO.ACCOUNTCAL A  INNER JOIN PRO.CUSTOMERCAL B ON A.REFCUSTOMERID =B.REFCUSTOMERID
		WHERE A.ASSET_NORM='ALWYS_NPA' AND  isnull(a.FLGDEG,'N')='Y'

		UPDATE   A SET  A.FINALNPADT=@ProcessDate 
		FROM PRO.ACCOUNTCAL A  INNER JOIN PRO.CUSTOMERCAL B ON A.REFCUSTOMERID =B.REFCUSTOMERID
		WHERE A.FINALNPADT is null AND  isnull(a.FLGDEG,'N')='Y'

		/* EXCEPTIONAL UPDATE FORO NPA DATE FOR EXISTING NPA ACCOUNT  */
 
		DECLARE @NaturalCalamity	INT=(SELECT ParameterAlt_Key FROM   DimParameter WHERE EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY AND DimParameterName='TypeofRestructuring' AND ParameterName='Natural Calamity')
		DECLARE @DCCO				INT=(SELECT ParameterAlt_Key FROM   DimParameter WHERE EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY AND DimParameterName='TypeofRestructuring' AND ParameterName='DCCO')
		DECLARE @Others_COMGT		INT=(SELECT ParameterAlt_Key FROM   DimParameter WHERE EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY AND DimParameterName='TypeofRestructuring' AND ParameterName='Others_COMGT')
	
		UPDATE NI
				SET	FinalNpaDt=RES.RestructureDt
					,FlgDeg='Y'
					,FinalAssetClassAlt_Key=2
					,DegReason=  'Degrade Due to Restructure Account'
		FROM PRO.ACCOUNTCAL NI 
		INNER JOIN [CurDat].AdvAcRestructureDetail RES ON NI.EffectiveFromTimeKey<=@TimeKey 
											 AND NI.EffectiveToTimeKey>=@TimeKey 
											 AND RES.EffectiveFromTimeKey<=@TimeKey 
											 AND RES.EffectiveToTimeKey>=@TimeKey 
											 AND NI.REFCustomerId=RES.RefCustomerId
											 AND NI.CustomerACID=RES.RefSystemAcId
		WHERE FlgRestructure='Y'
			AND FinalAssetClassAlt_Key=1
			AND ISNULL(RES.RestructureTypeAlt_Key,0) NOT IN (@NaturalCalamity,@DCCO,@Others_COMGT) 
			AND ISNULL(RestructureDt,'1900-01-01')>'2021-12-31'

		/* NEW RESTRUCTURE ACCOUNT EXISTING NPA - IF RESTRYCTURE DATE IS NCIF_NPA_Date THEN RESTRYCTURE DATE WILL BE MARKED AS NCIF_NPA_Date */
		UPDATE NI
					SET	FinalNpaDt=RES.RestructureDt
			FROM PRO.ACCOUNTCAL NI 
			INNER JOIN [CurDat].AdvAcRestructureDetail RES 
					ON NI.EffectiveFromTimeKey<=@TimeKey AND NI.EffectiveToTimeKey>=@TimeKey 
					AND RES.EffectiveFromTimeKey<=@TimeKey AND RES.EffectiveToTimeKey>=@TimeKey 
					AND NI.REFCustomerId=RES.RefCustomerId AND NI.CustomerACID=RES.RefSystemAcId
			WHERE FlgRestructure='Y'
				AND FinalAssetClassAlt_Key>1 
				AND ISNULL(RES.RestructureDt,'2099-01-01')<FinalNpaDt
		/*END OF RFESTR WORK */



/*------MIN NPA DATE CUSTOMER LEVEL ---------------------*/

 

UPDATE A SET A.SysNPA_Dt=C.FinalNpaDt,
             A.FlgDeg='Y'
	FROM PRO.CustomerCal A INNER JOIN
		(
      		  SELECT A.REFCUSTOMERID,MIN(A.FinalNpaDt) FinalNpaDt  FROM PRO.AccountCal  A
      		  INNER JOIN PRO.CustomerCal B ON A.REFCUSTOMERID=B.REFCUSTOMERID
      		  WHERE ISNULL(A.FlgDeg,'N')='Y' AND ISNULL(B.FlgProcessing,'N')='N'
      		  GROUP BY A.REFCUSTOMERID
		) C ON A.REFCUSTOMERID=C.REFCUSTOMERID
	AND (ISNULL(A.FlgProcessing,'N')='N')

/*-----UPDATE Initial LEVEL InitialNpaDt IS SET NULL FOR Fresh Npa Accounts---------*/

	UPDATE A SET A.FINALNPADT=B.SysNPA_Dt
	FROM  PRO.ACCOUNTCAL A INNER JOIN  PRO.CustomerCal  B ON A.REFCUSTOMERID=B.REFCUSTOMERID
	WHERE ISNULL(A.ASSET_NORM,'NORMAL')<>'ALWYS_STD' AND ISNULL(A.FlgDeg,'N')='Y' AND ISNULL(B.FlgProcessing,'N')='N'


          UPDATE PRO.ACLRUNNINGPROCESSSTATUS
            SET COMPLETED='Y',ERRORDATE=NULL,ERRORDESCRIPTION=NULL,COUNT=ISNULL(COUNT,0)+1
            WHERE RUNNINGPROCESSNAME='NPA_Date_Calculation'

END TRY

BEGIN  CATCH

         UPDATE PRO.ACLRUNNINGPROCESSSTATUS
         SET COMPLETED='N',ERRORDATE=GETDATE(),ERRORDESCRIPTION=ERROR_MESSAGE(),COUNT=ISNULL(COUNT,0)+1
         WHERE RUNNINGPROCESSNAME='NPA_Date_Calculation'
END CATCH

SET NOCOUNT OFF

END

 

 

GO