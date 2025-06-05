SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/*=========================================

AUTHER : TRILOKI KHANNA
alter DATE : 27-11-2019
MODIFY DATE : 27-11-2019
DESCRIPTION : UPDATE  SysAssetClassAlt_Key  NPA Erosion Aging
--EXEC [PRO].[NPA_Erosion_Aging] @TIMEKEY=26306
=============================================*/
CREATE PROCEDURE [PRO].[NPA_Erosion_Aging]
@TIMEKEY INT
--WITH RECOMPILE
AS
BEGIN
  SET NOCOUNT ON
   BEGIN TRY

DECLARE @PROCESSDATE DATE =(SELECT DATE FROM SysDayMatrix WHERE TimeKey=@TIMEKEY)
 
                                DECLARE @MoveToDB1 DECIMAL(5,2) =(SELECT cast(RefValue/100.00 as decimal(5,2))FROM DIMSECURITYEROSIONMASTER where BusinessRule='Sub-Standard to Doubtful 1' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
                                DECLARE @MoveToLoss DECIMAL(5,2)=(SELECT cast(RefValue/100.00 as decimal(5,2)) FROM DIMSECURITYEROSIONMASTER where BusinessRule='Direct Loss' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
 
                                IF OBJECT_ID('TEMPDB..#CTE_CustomerWiseBalance') IS NOT NULL
                                   DROP TABLE #CTE_CustomerWiseBalance

                                SELECT A.RefCustomerID,SUM(ISNULL(A.PrincOutStd,0)) NetBalance INTO #CTE_CustomerWiseBalance
                                FROM PRO.ACCOUNTCAL A INNER JOIN PRO.CUSTOMERCAL B ON A.RefCustomerID=B.RefCustomerID
                                WHERE   ( b.SysAssetClassAlt_Key NOT IN (select AssetClassAlt_Key
												from DimAssetClass where AssetClassShortName ='STD' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY )
												AND SecApp='S'  --AND ISNULL(B.FlgDeg,'N')<>'Y'
										)
									AND (ISNULL(B.FlgProcessing,'N')='N')
									and ISNULL(A.PrincOutStd,0)>0
                                GROUP BY A.RefCustomerID

                                                /*----INTIAL LEVEL LossDt FlgErosion,ErosionDt NULL ------*/
                                                UPDATE B SET   B.FlgErosion='N',B.ErosionDt=NULL  FROM PRO.CustomerCal B
                                                --------/*---UPDATING ASSET CLASS ON DUE TO EROSION OF SECURITY AND DBTDT AND LOSS DT DUE TO EROSION */
                                UPDATE  B SET 
											B.SysAssetClassAlt_Key=
                                                                (CASE WHEN  ISNULL(B.CurntQtrRv,0)< (ISNULL(C.NetBalance,0) *@MoveToLoss) AND D.AssetClassShortName<>'LOS' THEN   (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='LOS' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
                                                                                WHEN  ISNULL(B.CurntQtrRv,0) <(ISNULL(B.PrvQtrRV,0) *@MoveToDB1) AND (ISNULL(C.NetBalance,0)>= ISNULL(B.CurntQtrRv,0)) AND  D.AssetClassShortName IN('SUB')  THEN   (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='DB1' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
                                                                                ELSE B.SysAssetClassAlt_Key
                                                                END)

											,B.LossDt=CASE WHEN  ISNULL(B.CurntQtrRv,0)< (ISNULL(C.NetBalance,0) *@MoveToLoss) AND D.AssetClassShortName<>'LOS' THEN @PROCESSDATE
                                                                ELSE LossDt  END

                                            ,B.DbtDt= CASE  WHEN  ISNULL(B.CurntQtrRv,0) <(ISNULL(B.PrvQtrRV,0) *@MoveToDB1) AND (ISNULL(C.NetBalance,0)>= ISNULL(B.CurntQtrRv,0))AND
                                                                                                D.AssetClassShortName IN('SUB')   THEN @PROCESSDATE ELSE DbtDt END -- Change 08/06/2018

                                            ,B.FlgErosion=  CASE WHEN  ISNULL(B.CurntQtrRv,0)< (ISNULL(C.NetBalance,0) *@MoveToLoss) AND D.AssetClassShortName<>'LOS' THEN  'Y'
                                                                                WHEN    ISNULL(B.CurntQtrRv,0) <(ISNULL(B.PrvQtrRV,0) *@MoveToDB1) AND (ISNULL(C.NetBalance,0)>= ISNULL(B.CurntQtrRv,0))
                                                                                            AND  D.AssetClassShortName IN('SUB')  THEN  'Y'
                                                                                ELSE 'N'
                                                                END

                                            ,B.ErosionDt=(CASE WHEN  ISNULL(B.CurntQtrRv,0)< (ISNULL(C.NetBalance,0) *@MoveToLoss) AND D.AssetClassShortName<>'LOS' 
																		THEN  @PROCESSDATE
                                                              WHEN  ISNULL(B.CurntQtrRv,0) <(ISNULL(B.PrvQtrRV,0) *@MoveToDB1) AND (ISNULL(C.NetBalance,0)>= ISNULL(B.CurntQtrRv,0))
																				AND  D.AssetClassShortName IN('SUB')  
																		THEN  @PROCESSDATE
																ELSE B.ErosionDt
                                                           END)
                                FROM  PRO.AccountCal A INNER JOIN PRO.CustomerCal B ON A.RefCustomerID=B.RefCustomerID
                                INNER JOIN #CTE_CustomerWiseBalance C ON C.RefCustomerID=B.RefCustomerID
                                INNER JOIN DimAssetClass D ON D.AssetClassAlt_Key=B.SysAssetClassAlt_Key AND (D.EffectiveFromTimeKey<=@TIMEKEY AND D.EffectiveToTimeKey>=@TIMEKEY)
                                WHERE ISNULL(A.PrincOutStd,0)>0  AND D.AssetClassShortName<>'STD'  AND (ISNULL(B.FlgProcessing,'N')='N')


/*-------------------UPDATING ASSET CLASS DUE TO AGING--------*/


/*---CALCULATE SysAssetClassAlt_Key,DbtDt ------------------ */
		DECLARE @SubSTD SMALLINT=(SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortNameEnum='SUB' AND EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
		DECLARE @DB1    SMALLINT=(SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortNameEnum='DB1' AND EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
		DECLARE @DB2    SMALLINT=(SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortNameEnum='DB2' AND EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
		DECLARE @DB3    SMALLINT=(SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortNameEnum='DB3' AND EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)

		DECLARE @SUB_Year INT =(SELECT RefValue FROM PRO.RefPeriod WHERE BusinessRule='SUB_Year' AND EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
		DECLARE @DB1_Year INT =(SELECT RefValue FROM PRO.RefPeriod WHERE BusinessRule='DB1_Year' AND EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
		DECLARE @DB2_Year INT =(SELECT RefValue FROM PRO.RefPeriod WHERE BusinessRule='DB2_Year' AND EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)

	UPDATE A SET  
		SysAssetClassAlt_Key=CASE WHEN DbtDT is not null and  IBL_ENPA_DB.[dbo].[GetLeapYearDate] (SysNPA_Dt,@DB1_Year) > @PROCESSDATE
										AND SysAssetClassAlt_Key<=2
									then @DB1
								when DbtDT is not null and  IBL_ENPA_DB.[dbo].[GetLeapYearDate] (DbtDT,(@DB1_Year+@DB2_Year)) > @PROCESSDATE 
										AND SysAssetClassAlt_Key<=3
									then @DB2
								when DbtDT is not null and  IBL_ENPA_DB.[dbo].[GetLeapYearDate] (DbtDT,(@DB1_Year+@DB2_Year)) <= @PROCESSDATE 
										AND SysAssetClassAlt_Key<=4
									then @DB3 
								END
		,DbtDt=	CASE WHEN DbtDt IS NOT NULL AND
								IBL_ENPA_DB.[dbo].[GetLeapYearDate] (SysNPA_Dt,@DB1_Year)<=@PROCESSDATE
						then IBL_ENPA_DB.[dbo].[GetLeapYearDate] (SysNPA_Dt,@DB1_Year)
				ELSE DbtDt END						
		from pro.CUSTOMERCAL A
			WHERE SysAssetClassAlt_Key IN(2,3,4) --FOR SUB,DB1,DB2
					AND ISNULL(A.FlgDeg,'N')<>'Y' 
					AND ISNULL(A.FlgErosion,'N')<>'Y'
					 AND SysNPA_Dt IS NOT NULL
	OPTION(RECOMPILE)

 
------------------------------------

 

UPDATE PRO.ACLRUNNINGPROCESSSTATUS

                SET COMPLETED='Y',ERRORDATE=NULL,ERRORDESCRIPTION=NULL,COUNT=ISNULL(COUNT,0)+1

                WHERE RUNNINGPROCESSNAME='NPA_Erosion_Aging'

 

               

 

                -----------------Added for DashBoard 04-03-2021

--Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='ASSET CLASSIFICATION'

 

END TRY

BEGIN  CATCH

 

                UPDATE PRO.ACLRUNNINGPROCESSSTATUS

                SET COMPLETED='N',ERRORDATE=GETDATE(),ERRORDESCRIPTION=ERROR_MESSAGE(),COUNT=ISNULL(COUNT,0)+1

                WHERE RUNNINGPROCESSNAME='NPA_Erosion_Aging'

END CATCH

 

 

SET NOCOUNT OFF

END

 

 

 

 

 

 

 

 

 

 

 

 

 

GO