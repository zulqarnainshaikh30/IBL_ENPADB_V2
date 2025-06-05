SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--USE [UTKS_MISDB]
--GO
--/****** Object:  StoredProcedure [dbo].[Rpt-058]    Script Date: 14-11-2024 10:30:47 ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO



CREATE PROCEDURE [dbo].[NPA_MOVEMENT_REPORT] 
			@TimeKey AS INT
			,@Cost	AS	FLOAT
 
AS



--DECLARE 
--      @TimeKey AS INT=(select TimeKey from SYSDAYMATRIX where date='20/MARCH/2025') 
--	  ,@Cost	AS	FLOAT=1
	   
--DECLARE @FinYearDateKey INT = 27211--(SELECT LastFinYearKey+1 FROM sysdaymatrix WHERE timekey=@TimeKey)

DECLARE @FinYearDateKey INT =  27453----(SELECT LastFinYearKey+1 FROM sysdaymatrix WHERE timekey=@TimeKey)

DECLARE @FinYearDate date= (SELECT date FROM sysdaymatrix WHERE timekey=@FinYearDateKey)

DECLARE @CurDate date =(SELECT date FROM sysdaymatrix WHERE timekey=@TimeKey)
--DECLARE @PerDayDateKey AS INT=@TimeKey-1

--SELECT @FinYearDate,@FinYearDateKey,@CurDate
--SELECT * FROM sysdaymatrix WHERE timekey=26960,26937

 
	  IF (OBJECT_ID('tempdb..#AccountCal_Hist') IS NOT NULL)
		DROP TABLE #AccountCal_Hist

		SELECT DISTINCT EffectiveFromTimeKey,EffectiveToTimeKey,CustomerAcID,FinalNpaDt,InitialNpaDt,AccountStatus,FinalAssetClassAlt_Key 
				,InitialAssetClassAlt_Key,PrincOutStd,TotalProvision,Balance,FlgUpg,UpgDate

		INTO #AccountCal_Hist FROM PRO.AccountCal_Hist A --WHERE      A.EffectiveFromTimeKey<=@TimeKey-1 AND A.EffectiveToTimeKey>=@FinYearDateKey

-----------------------NPAPeriod----------------
--- addition	--------- during period

	  IF (OBJECT_ID('tempdb..#NPAPeriodCust') IS NOT NULL)
		DROP TABLE #NPAPeriodCust

		SELECT DISTINCT CustomerAcID, SDM.TimeKey
			INTO #NPAPeriodCust

		FROM #AccountCal_Hist A	 
	

		INNER JOIN SYSDATAMATRIX	SDM		ON SDM.ExtDate=A.FinalNpaDt
											AND    	FinalNpaDt BETWEEN @FinYearDate AND  @CurDate
		
		WHERE  A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@FinYearDateKey
									 AND FinalAssetClassAlt_Key>1  AND AccountStatus NOT LIKE '%W%' 
			--SELECT DISTINCT  * FROM #NPAPeriodCust
	  IF (OBJECT_ID('tempdb..#NPAPeriodBAL') IS NOT NULL)
		DROP TABLE #NPAPeriodBAL

		SELECT DISTINCT A.CustomerAcID

				,CASE WHEN A.FinalAssetClassAlt_Key=2 
					THEN ISNULL (PrincOutStd,0) END AS SUB_PrincOutStd

				,CASE WHEN A.FinalAssetClassAlt_Key IN (3,4,5)
					THEN ISNULL (PrincOutStd,0) END AS DUB_PrincOutStd

				,CASE WHEN A.FinalAssetClassAlt_Key=6
					THEN ISNULL (PrincOutStd,0) END AS LOSS_PrincOutStd

				,CASE WHEN A.FinalAssetClassAlt_Key=2 
					THEN ISNULL (TotalProvision,0) END AS SUB_PROVStd

				,CASE WHEN A.FinalAssetClassAlt_Key IN (3,4,5)
					THEN ISNULL (TotalProvision,0) END AS DUB_PROVStd

				,CASE WHEN A.FinalAssetClassAlt_Key=6
					THEN ISNULL (TotalProvision,0) END AS LOSS_PROVStd
				
				--,TotalProvision
		
		INTO #NPAPeriodBAL
		FROM #AccountCal_Hist A

		INNER JOIN #NPAPeriodCust NPA		ON NPA.CUSTOMERACID=A.CustomerAcID
										   AND  A.EffectiveFromTimeKey<=TimeKey 
										   AND A.EffectiveToTimeKey>=TimeKey
										   AND FinalAssetClassAlt_Key>1 
										   AND AccountStatus NOT LIKE '%W%' 
--SELECT * FROM #NPAPeriodBAL
	  IF (OBJECT_ID('tempdb..#NPAPeriod') IS NOT NULL)
		DROP TABLE #NPAPeriod

	SELECT DISTINCT  
	
	CASE WHEN A.PrincOutStd>NPA.SUB_PrincOutStd AND A.FinalAssetClassAlt_Key=2
			THEN A.PrincOutStd-NPA.SUB_PrincOutStd END AS NPAPeriodADSUB_PrincOutStd

	,CASE WHEN A.PrincOutStd>NPA.DUB_PrincOutStd AND A.FinalAssetClassAlt_Key IN (3,4,5)
			THEN A.PrincOutStd-NPA.DUB_PrincOutStd END AS NPAPeriodADUB_PrincOutStd

	,CASE WHEN A.PrincOutStd>NPA.LOSS_PrincOutStd AND A.FinalAssetClassAlt_Key=6
			THEN A.PrincOutStd-NPA.LOSS_PrincOutStd END AS NPAPeriodADLOSS_PrincOutStd
------------
	,CASE WHEN A.TotalProvision>NPA.SUB_PROVStd AND A.FinalAssetClassAlt_Key=2
			THEN A.TotalProvision-NPA.SUB_PROVStd END AS NPAPRDADDSUB_PROV

	,CASE WHEN A.TotalProvision>NPA.DUB_PROVStd AND A.FinalAssetClassAlt_Key IN (3,4,5)
			THEN A.TotalProvision-NPA.DUB_PROVStd END AS NPAPRDADDDUB_PROV

	,CASE WHEN A.TotalProvision>NPA.LOSS_PROVStd AND A.FinalAssetClassAlt_Key=6
			THEN A.TotalProvision-NPA.LOSS_PROVStd END AS NPAPRDADDLOSS_PROV
------------
	,CASE WHEN A.PrincOutStd<NPA.SUB_PrincOutStd AND A.FinalAssetClassAlt_Key=2
			THEN NPA.LOSS_PrincOutStd-A.PrincOutStd END AS NPAPRDRECSUB_POS

	,CASE WHEN A.PrincOutStd<NPA.DUB_PrincOutStd AND A.FinalAssetClassAlt_Key IN (3,4,5)
			THEN NPA.LOSS_PrincOutStd-A.PrincOutStd END AS NPAPRDRECDUB_POS

	,CASE WHEN A.PrincOutStd<NPA.LOSS_PrincOutStd AND A.FinalAssetClassAlt_Key=6
			THEN NPA.LOSS_PrincOutStd-A.PrincOutStd END AS NPAPRDRECLOSS_POS
---------

	,CASE WHEN A.TotalProvision<NPA.SUB_PROVStd AND A.FinalAssetClassAlt_Key=2
			THEN NPA.SUB_PROVStd-A.TotalProvision END AS NPAPRDRECSUB_PROV

	,CASE WHEN A.TotalProvision<NPA.DUB_PROVStd AND A.FinalAssetClassAlt_Key IN (3,4,5)
			THEN NPA.DUB_PROVStd-A.TotalProvision END AS NPAPRDRECDUB_PROV

	,CASE WHEN A.TotalProvision<NPA.LOSS_PROVStd AND A.FinalAssetClassAlt_Key=6
			THEN NPA.LOSS_PROVStd-A.TotalProvision END AS NPAPRDRECLOSS_PROV
 
	 INTO #NPAPeriod
		FROM #AccountCal_Hist A

		INNER JOIN #NPAPeriodBAL NPA		ON NPA.CUSTOMERACID=A.CustomerAcID
										   AND  A.EffectiveFromTimeKey<=@TimeKey 
										   AND A.EffectiveToTimeKey>=@TimeKey
										   AND FinalAssetClassAlt_Key>1 
										   AND AccountStatus NOT LIKE '%W%' 

--SELECT  DISTINCT  NPAPeriodADSUB_PrincOutStd,NPAPeriodADUB_PrincOutStd,NPAPeriodADLOSS_PrincOutStd FROM #NPAPeriod

DECLARE @NPAPeriodADSUB_PrincOutStd   AS DECIMAL(20,2)  =(SELECT SUM(NPAPeriodADSUB_PrincOutStd)  FROM #NPAPeriod)
DECLARE @NPAPeriodADUB_PrincOutStd    AS DECIMAL(20,2)  =(SELECT SUM(NPAPeriodADUB_PrincOutStd) FROM #NPAPeriod)
DECLARE @NPAPeriodADLOSS_PrincOutStd  AS DECIMAL(20,2)  =(SELECT SUM(NPAPeriodADLOSS_PrincOutStd)  FROM #NPAPeriod)
-----
DECLARE @NPAPRDADDSUB_PROV AS DECIMAL(20,2)  =(SELECT SUM(NPAPRDADDSUB_PROV) FROM #NPAPeriod)
DECLARE @NPAPRDADDDUB_PROV AS DECIMAL(20,2)  =(SELECT SUM(NPAPRDADDDUB_PROV) FROM #NPAPeriod)
DECLARE @NPAPRDADDLOSS_PROV AS DECIMAL(20,2)  =(SELECT SUM(NPAPRDADDLOSS_PROV) FROM #NPAPeriod)
-----
DECLARE @NPAPRDRECSUB_POS  AS DECIMAL(20,2)  =(SELECT SUM(NPAPRDRECSUB_POS) FROM #NPAPeriod)
DECLARE @NPAPRDRECDUB_POS AS DECIMAL(20,2)  =(SELECT SUM(NPAPRDRECDUB_POS) FROM #NPAPeriod)
DECLARE @NPAPRDRECLOSS_POS AS DECIMAL(20,2)  =(SELECT SUM(NPAPRDRECLOSS_POS) FROM #NPAPeriod)
-----
DECLARE @NPAPRDRECSUB_PROV  AS DECIMAL(20,2)  =(SELECT SUM(NPAPRDRECSUB_PROV) FROM #NPAPeriod)
DECLARE @NPAPRDRECDUB_PROV AS DECIMAL(20,2)  =(SELECT SUM(NPAPRDRECDUB_PROV) FROM #NPAPeriod)
DECLARE @NPAPRDRECLOSS_PROV AS DECIMAL(20,2)  =(SELECT SUM(NPAPRDRECLOSS_PROV) FROM #NPAPeriod)
--
-------------=============-----------
-------OpeningClossing--- addition

	  IF (OBJECT_ID('tempdb..#OpeningClossing') IS NOT NULL)
		DROP TABLE #OpeningClossing
SELECT    
	CASE WHEN A.PrincOutStd>NPA.PrincOutStd
			THEN A.PrincOutStd-NPA.PrincOutStd END AS  OpeningClossingPOS

	,CASE WHEN A.PrincOutStd>NPA.PrincOutStd AND A.FinalAssetClassAlt_Key=2
			THEN A.PrincOutStd-NPA.PrincOutStd END AS  SUB_OpeningClossingPOS

	,CASE WHEN A.PrincOutStd>NPA.PrincOutStd AND A.FinalAssetClassAlt_Key IN (3,4,5)
			THEN A.PrincOutStd-NPA.PrincOutStd END AS  DUB_OpeningClossingPOS 

	,CASE WHEN A.PrincOutStd>NPA.PrincOutStd AND A.FinalAssetClassAlt_Key =6
			THEN A.PrincOutStd-NPA.PrincOutStd END AS  LOS_OpeningClossingPOS
--------
	,CASE WHEN A.TotalProvision>NPA.TotalProvision   
			THEN A.TotalProvision-NPA.TotalProvision END AS OpeningClossingPROV 

	,CASE WHEN A.TotalProvision>NPA.TotalProvision AND A.FinalAssetClassAlt_Key=2
			THEN A.TotalProvision-NPA.TotalProvision END AS SUB_OpeningClossingPROV

	,CASE WHEN A.TotalProvision>NPA.TotalProvision AND A.FinalAssetClassAlt_Key IN (3,4,5)
			THEN A.TotalProvision-NPA.TotalProvision END AS DUB_OpeningClossingPROV

	,CASE WHEN A.TotalProvision>NPA.TotalProvision AND A.FinalAssetClassAlt_Key=6
			THEN A.TotalProvision-NPA.TotalProvision END AS LOS_OpeningClossingPROV
			
--------

	,CASE WHEN A.PrincOutStd<NPA.PrincOutStd AND A.FlgUpg<>'U'
			THEN NPA.PrincOutStd-A.PrincOutStd END AS   OpeningClossingRECPOS

	,CASE WHEN A.PrincOutStd<NPA.PrincOutStd AND A.FlgUpg<>'U' AND A.FinalAssetClassAlt_Key=2
			THEN NPA.PrincOutStd-A.PrincOutStd END AS  SUB_OpeningClossingRECPOS

	,CASE WHEN A.PrincOutStd<NPA.PrincOutStd AND A.FlgUpg<>'U' AND A.FinalAssetClassAlt_Key IN (3,4,5)
			THEN NPA.PrincOutStd-A.PrincOutStd END AS  DUB_OpeningClossingRECPOS

	,CASE WHEN A.PrincOutStd<NPA.PrincOutStd AND A.FlgUpg<>'U' AND A.FinalAssetClassAlt_Key =6
			THEN NPA.PrincOutStd-A.PrincOutStd END AS  LOS_OpeningClossingRECPOS

	--------------

	,CASE WHEN A.TotalProvision<NPA.TotalProvision AND A.FlgUpg<>'U'
			THEN NPA.TotalProvision-A.TotalProvision END AS  ExcessProvision1

	,CASE WHEN A.TotalProvision<NPA.TotalProvision AND A.FlgUpg<>'U' AND A.FinalAssetClassAlt_Key=2
			THEN NPA.TotalProvision-A.TotalProvision END AS  SUB_ExcessProvision1

	,CASE WHEN A.TotalProvision<NPA.TotalProvision AND A.FlgUpg<>'U' AND A.FinalAssetClassAlt_Key IN (3,4,5)
			THEN NPA.TotalProvision-A.TotalProvision END AS  DUB_ExcessProvision1

	,CASE WHEN A.TotalProvision<NPA.TotalProvision AND A.FlgUpg<>'U' AND A.FinalAssetClassAlt_Key =6
			THEN NPA.TotalProvision-A.TotalProvision END AS  LOS_ExcessProvision1

	--,CASE WHEN A.TotalProvision>NPA.ProvisonAmt
	--		THEN A.TotalProvision-NPA.ProvisonAmt END AS OpeningClossingPROV

INTO #OpeningClossing

			FROM #AccountCal_Hist A

		
		INNER JOIN #AccountCal_Hist NPA		ON NPA.CustomerAcID=A.CustomerAcID
											AND NPA.FinalAssetClassAlt_Key>1 
											AND  NPA.EffectiveFromTimeKey<=@FinYearDateKey 
										   AND NPA.EffectiveToTimeKey>=@FinYearDateKey
										   AND  A.EffectiveFromTimeKey<=@TimeKey 
										   AND A.EffectiveToTimeKey>=@TimeKey
										   AND A.FinalAssetClassAlt_Key>1 
										   AND NPA.AccountStatus NOT LIKE '%W%' 
										   AND A.AccountStatus NOT LIKE '%W%' 

DECLARE @OpeningClossingPOS			DECIMAL(20,2)	=(SELECT SUM(OpeningClossingPOS)  FROM #OpeningClossing)
DECLARE @SUB_OpeningClossingPOS		DECIMAL(20,2)	=(SELECT SUM(SUB_OpeningClossingPOS) FROM #OpeningClossing)
DECLARE @DUB_OpeningClossingPOS		DECIMAL(20,2)	=(SELECT SUM(DUB_OpeningClossingPOS)  FROM #OpeningClossing)
DECLARE @LOS_OpeningClossingPOS	    DECIMAL(20,2)	=(SELECT SUM(LOS_OpeningClossingPOS)       FROM #OpeningClossing)
--select @OpeningClossingPOS


DECLARE @OpeningClossingPROV	   DECIMAL(20,2)	=(SELECT SUM(OpeningClossingPROV)  FROM #OpeningClossing)
DECLARE @SUB_OpeningClossingPROV   DECIMAL(20,2)	=(SELECT SUM(SUB_OpeningClossingPROV) FROM #OpeningClossing)
DECLARE @DUB_OpeningClossingPROV   DECIMAL(20,2)	=(SELECT SUM(DUB_OpeningClossingPROV)  FROM #OpeningClossing)
DECLARE @LOS_OpeningClossingPROV   DECIMAL(20,2)	=(SELECT SUM(LOS_OpeningClossingPROV)       FROM #OpeningClossing)
-----
DECLARE @OpeningClossingPOSREC			DECIMAL(20,2)	=(SELECT SUM(OpeningClossingRECPOS)  FROM #OpeningClossing)
DECLARE @SUB_OpeningClossingPOSREC		DECIMAL(20,2)	=(SELECT SUM(SUB_OpeningClossingRECPOS) FROM #OpeningClossing)
DECLARE @DUB_OpeningClossingPOSREC		DECIMAL(20,2)	=(SELECT SUM(DUB_OpeningClossingRECPOS)  FROM #OpeningClossing)
DECLARE @LOS_OpeningClossingPOSREC	    DECIMAL(20,2)	=(SELECT SUM(LOS_OpeningClossingRECPOS)       FROM #OpeningClossing)

DECLARE @ExcessProvision1	    DECIMAL(20,2)	=(SELECT SUM(ExcessProvision1)  FROM #OpeningClossing)
DECLARE @SUB_ExcessProvision1   DECIMAL(20,2)	=(SELECT SUM(SUB_ExcessProvision1) FROM #OpeningClossing)
DECLARE @DUB_ExcessProvision1   DECIMAL(20,2)	=(SELECT SUM(DUB_ExcessProvision1)  FROM #OpeningClossing)
DECLARE @LOS_ExcessProvision1   DECIMAL(20,2)	=(SELECT SUM(LOS_ExcessProvision1)       FROM #OpeningClossing)


--------------=============-----------
	  IF (OBJECT_ID('tempdb..#LMSCLOSSED') IS NOT NULL)
		DROP TABLE #LMSCLOSSED

SELECT  STG.CustomerAcID,PrincOutStd

			,CASE WHEN B.FinalAssetClassAlt_Key=2 
				THEN ISNULL(PrincOutStd ,0) END AS SUB_PrincOutStd

			,CASE WHEN B.FinalAssetClassAlt_Key  IN (3,4,5)
				THEN ISNULL(PrincOutStd ,0) END AS DUB_PrincOutStd

			,CASE WHEN B.FinalAssetClassAlt_Key=5 
				THEN ISNULL(PrincOutStd ,0) END AS LOS_PrincOutStd
		,TotalProvision		AS ExcessProvision5

		,CASE WHEN B.FinalAssetClassAlt_Key=2 
				THEN ISNULL(TotalProvision ,0) END AS SUB_ExcessProvision5

			,CASE WHEN B.FinalAssetClassAlt_Key  IN (3,4,5)
				THEN ISNULL(TotalProvision ,0) END AS DUB_ExcessProvision5

			,CASE WHEN B.FinalAssetClassAlt_Key=5 
				THEN ISNULL(TotalProvision ,0) END AS LOS_ExcessProvision5


INTO #LMSCLOSSED

from UTKS_STGDB..LMS_ACCOUNT_STG	STG

INNER JOIN SYSDATAMATRIX SDM	ON SDM.ExtDate=AccountClosedDate
								AND AccountClosedFlag='Y' 
								AND AccountClosedDate BETWEEN @FinYearDate AND @CurDate

INNER JOIN #AccountCal_Hist B		ON B.CUSTOMERACID=STG.CustomerAcID
												AND  B.EffectiveFromTimeKey<= TimeKey-1
												AND B.EffectiveToTimeKey>= TimeKey-1
												AND FinalAssetClassAlt_Key>1 
												AND AccountStatus NOT LIKE '%W%' 

DECLARE @LMSCLOSSEDPOS AS DECIMAL(20,2)=( SELECT SUM(PrincOutStd) FROM #LMSCLOSSED)
DECLARE @LMSxcProvision5 AS DECIMAL(20,2)=( SELECT SUM(ExcessProvision5) FROM #LMSCLOSSED)

DECLARE @LMSSUB_POS AS DECIMAL(20,2)=( SELECT SUM(SUB_PrincOutStd) FROM #LMSCLOSSED)
DECLARE @LMSDUB_POS AS DECIMAL(20,2)=( SELECT SUM(DUB_PrincOutStd) FROM #LMSCLOSSED)
DECLARE @LMSLOS_POS AS DECIMAL(20,2)=( SELECT SUM(LOS_PrincOutStd) FROM #LMSCLOSSED)

---

DECLARE @LMSSUB_ExcessPROV5 AS DECIMAL(20,2)=( SELECT SUM(SUB_ExcessProvision5) FROM #LMSCLOSSED)
DECLARE @LMSDUB_ExcessPROV5 AS DECIMAL(20,2)=( SELECT SUM(DUB_ExcessProvision5) FROM #LMSCLOSSED)
DECLARE @LMSLOS_ExcessPROV5 AS DECIMAL(20,2)=( SELECT SUM(LOS_ExcessProvision5) FROM #LMSCLOSSED)

	  IF (OBJECT_ID('tempdb..#BRNETCLOSSED') IS NOT NULL)
		DROP TABLE #BRNETCLOSSED

SELECT  STG.CustomerAcID,PrincOutStd

			,CASE WHEN B.FinalAssetClassAlt_Key=2 
				THEN ISNULL(PrincOutStd ,0) END AS SUB_PrincOutStd

			,CASE WHEN B.FinalAssetClassAlt_Key  IN (3,4,5)
				THEN ISNULL(PrincOutStd ,0) END AS DUB_PrincOutStd

			,CASE WHEN B.FinalAssetClassAlt_Key=5 
				THEN ISNULL(PrincOutStd ,0) END AS LOS_PrincOutStd
		,TotalProvision		AS ExcessProvision5

		,CASE WHEN B.FinalAssetClassAlt_Key=2 
				THEN ISNULL(TotalProvision ,0) END AS SUB_ExcessProvision5

			,CASE WHEN B.FinalAssetClassAlt_Key  IN (3,4,5)
				THEN ISNULL(TotalProvision ,0) END AS DUB_ExcessProvision5

			,CASE WHEN B.FinalAssetClassAlt_Key=5 
				THEN ISNULL(TotalProvision ,0) END AS LOS_ExcessProvision5

INTO #BRNETCLOSSED

from UTKS_STGDB..BRNET_ACCOUNT_STG	STG

INNER JOIN SYSDATAMATRIX SDM	ON SDM.ExtDate=AccountClosedDate
								AND AccountClosedFlag='Y' 
								AND AccountClosedDate BETWEEN @FinYearDate AND @CurDate

INNER JOIN #AccountCal_Hist B		ON B.CUSTOMERACID=STG.CustomerAcID
												AND  B.EffectiveFromTimeKey<= TimeKey-1
												AND B.EffectiveToTimeKey>= TimeKey-1
												AND FinalAssetClassAlt_Key>1 
												AND AccountStatus NOT LIKE '%W%' 

DECLARE @BRNETCLOSSED DECIMAL (20,2)=(SELECT SUM(PrincOutStd) FROM #BRNETCLOSSED)
DECLARE @BRNETExcProvision5 DECIMAL (20,2)=(SELECT SUM(ExcessProvision5) FROM #BRNETCLOSSED)

DECLARE @BRNETSUB_POS AS DECIMAL(20,2)=( SELECT SUM(SUB_PrincOutStd) FROM #BRNETCLOSSED)
DECLARE @BRNETDUB_POS AS DECIMAL(20,2)=( SELECT SUM(DUB_PrincOutStd) FROM #BRNETCLOSSED)
DECLARE @BRNETLOS_POS AS DECIMAL(20,2)=( SELECT SUM(LOS_PrincOutStd) FROM #BRNETCLOSSED)

-----

DECLARE @BRNETSUB_ExcessPROV5 AS DECIMAL(20,2)=( SELECT SUM(SUB_ExcessProvision5) FROM #BRNETCLOSSED)
DECLARE @BRNETDUB_ExcessPROV5 AS DECIMAL(20,2)=( SELECT SUM(DUB_ExcessProvision5) FROM #BRNETCLOSSED)
DECLARE @BRNETLOS_ExcessPROV5 AS DECIMAL(20,2)=( SELECT SUM(LOS_ExcessProvision5) FROM #BRNETCLOSSED)

------------------#NPAPeriodUpGradations

  IF (OBJECT_ID('tempdb..#UpGradedAcc') IS NOT NULL)
		DROP TABLE #UpGradedAcc

		SELECT DISTINCT CustomerAcID, SDM.TimeKey
			INTO #UpGradedAcc

		FROM #AccountCal_Hist A	 
	

		INNER JOIN SYSDATAMATRIX	SDM		ON SDM.ExtDate=A.UpgDate
											AND A.FlgUpg='U' AND AccountStatus NOT LIKE '%W%'  
									    	AND UpgDate between @FinYearDate and @CurDate  	 
		
		WHERE  A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@FinYearDateKey
									 --AND FinalAssetClassAlt_Key>1  

--select * from #UpGradedAcc
 IF (OBJECT_ID('tempdb..#UpGradedPeriodBAL') IS NOT NULL)
		DROP TABLE #UpGradedPeriodBAL

	--SELECT SUM(SUB_PrincOutStd),SUM(DUB_PrincOutStd),SUM(LOS_PrincOutStd) ,SUM (PrincOutStd)A
	--FROM (	
	SELECT DISTINCT A.CustomerAcID,ISNULL(PrincOutStd,0)	 AS PrincOutStd

			,CASE WHEN A.FinalAssetClassAlt_Key=2 
				THEN ISNULL(PrincOutStd ,0) END AS SUB_PrincOutStd

			,CASE WHEN A.FinalAssetClassAlt_Key  IN (3,4,5)
				THEN ISNULL(PrincOutStd ,0) END AS DUB_PrincOutStd

			,CASE WHEN A.FinalAssetClassAlt_Key=6 
				THEN ISNULL(PrincOutStd ,0) END AS LOS_PrincOutStd

		,TotalProvision		AS ExcessProvision3

		,CASE WHEN A.FinalAssetClassAlt_Key=2 
				THEN ISNULL(TotalProvision ,0) END AS SUB_ExcessProvision3

			,CASE WHEN A.FinalAssetClassAlt_Key  IN (3,4,5)
				THEN ISNULL(TotalProvision ,0) END AS DUB_ExcessProvision3

			,CASE WHEN A.FinalAssetClassAlt_Key=6 
				THEN ISNULL(TotalProvision ,0) END AS LOS_ExcessProvision3
		
		INTO #UpGradedPeriodBAL

FROM #AccountCal_Hist A

		INNER JOIN #UpGradedAcc UPG		ON UPG.CUSTOMERACID=A.CustomerAcID
										   AND  A.EffectiveFromTimeKey<=TimeKey-1
										   AND A.EffectiveToTimeKey>=TimeKey-1
										   AND FinalAssetClassAlt_Key>1 
										   --)A

DECLARE @UPGPeriodPOS DECIMAL (20,2)=(SELECT SUM(PrincOutStd) FROM #UpGradedPeriodBAL)
----SELECT @UPGPeriodPOS


DECLARE @UPGPERIOD_SUB_POS DECIMAL (20,2)=(SELECT SUM(SUB_PrincOutStd) FROM #UpGradedPeriodBAL)
DECLARE @UPGPERIOD_DUB_POS DECIMAL (20,2)=(SELECT SUM(DUB_PrincOutStd) FROM #UpGradedPeriodBAL)
DECLARE @UPGPERIOD_LOS_POS DECIMAL (20,2)=(SELECT SUM(LOS_PrincOutStd) FROM #UpGradedPeriodBAL)

DECLARE @UPGPeriodExcessProvision3 DECIMAL (20,2)=(SELECT SUM(ExcessProvision3) FROM #UpGradedPeriodBAL)

DECLARE @UPGPRDSUB_ExcessProvision3 DECIMAL (20,2)=(SELECT SUM(SUB_ExcessProvision3) FROM #UpGradedPeriodBAL)
DECLARE @UPGPRDDUB_ExcessProvision3 DECIMAL (20,2)=(SELECT SUM(DUB_ExcessProvision3) FROM #UpGradedPeriodBAL)
DECLARE @UPGPRDLOS_ExcessProvision3 DECIMAL (20,2)=(SELECT SUM(LOS_ExcessProvision3) FROM #UpGradedPeriodBAL)
  IF (OBJECT_ID('tempdb..#UpGradedOpenAcc') IS NOT NULL)
		DROP TABLE #UpGradedOpenAcc

		SELECT DISTINCT A.CustomerAcID, SDM.TimeKey
			INTO #UpGradedOpenAcc

		FROM #AccountCal_Hist A	 
	

		INNER JOIN SYSDATAMATRIX	SDM		ON SDM.ExtDate=A.UpgDate
											AND A.FlgUpg='U' AND AccountStatus NOT LIKE '%W%'  
									    	AND UpgDate between @FinYearDate and @CurDate 

				INNER JOIN #AccountCal_Hist NPA		ON NPA.CustomerAcID=A.CustomerAcID
											AND NPA.FinalAssetClassAlt_Key>1 
											AND  NPA.EffectiveFromTimeKey<=@FinYearDateKey 
										   AND NPA.EffectiveToTimeKey>=@FinYearDateKey
										   AND  A.EffectiveFromTimeKey<=@TimeKey 
										   AND A.EffectiveToTimeKey>=@TimeKey
										   AND A.FinalAssetClassAlt_Key>1 
		
		WHERE  A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@FinYearDateKey
		

	 IF (OBJECT_ID('tempdb..#UpGradedOpenBAL') IS NOT NULL)
		DROP TABLE #UpGradedOpenBAL

		SELECT DISTINCT A.CustomerAcID,PrincOutStd

		,CASE WHEN A.FinalAssetClassAlt_Key=2 
				THEN ISNULL(PrincOutStd ,0) END AS SUB_PrincOutStd

			,CASE WHEN A.FinalAssetClassAlt_Key  IN (3,4,5)
				THEN ISNULL(PrincOutStd ,0) END AS DUB_PrincOutStd

			,CASE WHEN A.FinalAssetClassAlt_Key=5 
				THEN ISNULL(PrincOutStd ,0) END AS LOS_PrincOutStd
-------------

			,CASE WHEN A.FinalAssetClassAlt_Key=2 
				THEN ISNULL(TotalProvision ,0) END AS SUB_ExcessProvision2

			,CASE WHEN A.FinalAssetClassAlt_Key  IN (3,4,5)
				THEN ISNULL(TotalProvision ,0) END AS DUB_ExcessProvision2

			,CASE WHEN A.FinalAssetClassAlt_Key=5 
				THEN ISNULL(TotalProvision ,0) END AS LOS_ExcessProvision2


		,TotalProvision	AS ExcessProvision2
		
		INTO #UpGradedOpenBAL

		FROM #AccountCal_Hist A

		INNER JOIN #UpGradedOpenAcc UPG		ON UPG.CUSTOMERACID=A.CustomerAcID
										   AND  A.EffectiveFromTimeKey<=TimeKey-1
										   AND A.EffectiveToTimeKey>=TimeKey-1

DECLARE @UPDOpeningPOS DECIMAL (20,2) = (SELECT SUM(PrincOutStd) FROM #UpGradedOpenBAL)
DECLARE @ExcessProvision2 DECIMAL (20,2) = (SELECT SUM(ExcessProvision2) FROM #UpGradedOpenBAL)

DECLARE @UPDOpening_SUB_POS DECIMAL (20,2) = (SELECT SUM(SUB_PrincOutStd) FROM #UpGradedOpenBAL)
DECLARE @UPDOpening_DUB_POS DECIMAL (20,2) = (SELECT SUM(DUB_PrincOutStd) FROM #UpGradedOpenBAL)
DECLARE @UPDOpening_LOS_POS DECIMAL (20,2) = (SELECT SUM(LOS_PrincOutStd) FROM #UpGradedOpenBAL) 

DECLARE @UPGPRDSUB_ExcessProvision2 DECIMAL (20,2)=(SELECT SUM(SUB_ExcessProvision2) FROM #UpGradedOpenBAL)
DECLARE @UPGPRDDUB_ExcessProvision2 DECIMAL (20,2)=(SELECT SUM(DUB_ExcessProvision2) FROM #UpGradedOpenBAL)
DECLARE @UPGPRDLOS_ExcessProvision2 DECIMAL (20,2)=(SELECT SUM(LOS_ExcessProvision2) FROM #UpGradedOpenBAL)

--IF (OBJECT_ID('tempdb..#UpGrad,') IS NOT NULL)
--		DROP TABLE #UpGraded

--	SELECT DISTINCT  
	
--	CASE WHEN A.PrincOutStd>NPA.PrincOutStd
--			THEN A.PrincOutStd-NPA.PrincOutStd END AS NPAPeriodPOS
			 
 
--	 --INTO #UpGraded
--		FROM #AccountCal_Hist A

--		INNER JOIN #UpGradedBAL NPA		ON NPA.CUSTOMERACID=A.CustomerAcID
--										   AND  A.EffectiveFromTimeKey<=@TimeKey 
--										   AND A.EffectiveToTimeKey>=@TimeKey
---------=============--------------

 IF (OBJECT_ID('tempdb..#UpGDuring') IS NOT NULL)
		DROP TABLE #UpGDuring

		SELECT DISTINCT B.CustomerAcID, B.PrincOutStd

		,CASE WHEN B.FinalAssetClassAlt_Key=2 
				THEN ISNULL(B.PrincOutStd ,0) END AS SUB_PrincOutStd

			,CASE WHEN B.FinalAssetClassAlt_Key  IN (3,4,5)
				THEN ISNULL(B.PrincOutStd ,0) END AS DUB_PrincOutStd

			,CASE WHEN B.FinalAssetClassAlt_Key=5 
				THEN ISNULL(B.PrincOutStd ,0) END AS LOS_PrincOutStd

			INTO #UpGDuring

		FROM #AccountCal_Hist  NPA	 
	
		
				INNER JOIN #AccountCal_Hist A		ON NPA.CustomerAcID=A.CustomerAcID
											 
											AND  NPA.EffectiveFromTimeKey<=@FinYearDateKey 
										   AND NPA.EffectiveToTimeKey>=@FinYearDateKey
										   AND  A.EffectiveFromTimeKey<=@TimeKey 
										   AND A.EffectiveToTimeKey>=@TimeKey
										     


										   AND A.FlgUpg='U' AND A.AccountStatus NOT LIKE '%W%'  
									      AND A.UpgDate between @FinYearDate and @CurDate 

		INNER JOIN SYSDATAMATRIX	SDM		ON SDM.ExtDate=A.UpgDate
											 	 
		INNER JOIN #AccountCal_Hist B		ON B.CUSTOMERACID=A.CustomerAcID
												AND  A.EffectiveFromTimeKey<= TimeKey-1
												AND A.EffectiveToTimeKey>= TimeKey-1


 DECLARE @UPGAsON DECIMAL (20,2)= (SELECT SUM(PrincOutStd) FROM #UpGDuring)

 
 DECLARE @UPGSUB_AsON DECIMAL (20,2)= (SELECT SUM(SUB_PrincOutStd) FROM #UpGDuring)
 DECLARE @UPGDUB_AsON DECIMAL (20,2)= (SELECT SUM(DUB_PrincOutStd) FROM #UpGDuring)
 DECLARE @UPGLOS_AsON DECIMAL (20,2)= (SELECT SUM(LOS_PrincOutStd) FROM #UpGDuring)
 ------------==========-----------

  --SELECT @OpeningClossingRECPOS,@NPAPeriodRECPOS,@BRNETCLOSSED ,@LMSCLOSSEDPOS,@UPDOpeningPOS,@ExcessProvision2,@UPGAsON
  IF (OBJECT_ID('tempdb..#WriteOffAcc') IS NOT NULL)
		DROP TABLE #WriteOffAcc

		SELECT DISTINCT CustomerAcID, SDM.TimeKey
			INTO #WriteOffAcc

		FROM #AccountCal_Hist A	 
	
	inner JOIN ExceptionFinalStatusType B           ON B.ACID=A.CustomerAcID
                                              AND A.EffectiveFromTimeKey<=@TimeKey
									          AND A.EffectiveToTimeKey>=@FinYearDateKey
											  AND B.EffectiveFromTimeKey<=@TimeKey 
											  AND B.EffectiveToTimeKey>=@FinYearDateKey
											  AND FinalAssetClassAlt_Key>1 
											  AND AccountStatus LIKE '%W%'  
									    	  AND StatusDate BETWEEN @FinYearDate AND @CurDate  

		INNER JOIN SYSDATAMATRIX	SDM		   ON SDM.ExtDate=B.StatusDate
											
									 --AND FinalAssetClassAlt_Key>1  


 IF (OBJECT_ID('tempdb..#WriteOffPeriodBAL') IS NOT NULL)
		DROP TABLE #WriteOffPeriodBAL

		SELECT DISTINCT A.CustomerAcID
		
		----,PrincOutStd 

		----	,CASE WHEN A.FinalAssetClassAlt_Key=2 
		----		THEN ISNULL(PrincOutStd ,0) END AS SUB_PrincOutStd

		----	,CASE WHEN A.FinalAssetClassAlt_Key  IN (3,4,5)
		----		THEN ISNULL(PrincOutStd ,0) END AS DUB_PrincOutStd

		----	,CASE WHEN A.FinalAssetClassAlt_Key=5 
		----		THEN ISNULL(PrincOutStd ,0) END AS LOS_PrincOutStd

		,TotalProvision		AS ExcessProvision6

		,CASE WHEN A.FinalAssetClassAlt_Key=2 
				THEN ISNULL(TotalProvision ,0) END AS SUB_ExcessProvision6

			,CASE WHEN A.FinalAssetClassAlt_Key  IN (3,4,5)
				THEN ISNULL(TotalProvision ,0) END AS DUB_ExcessProvision6

			,CASE WHEN A.FinalAssetClassAlt_Key=6
				THEN ISNULL(TotalProvision ,0) END AS LOS_ExcessProvision6
		
		INTO #WriteOffPeriodBAL

FROM #AccountCal_Hist A

		INNER JOIN #WriteOffAcc UPG		ON UPG.CUSTOMERACID=A.CustomerAcID
										   AND  A.EffectiveFromTimeKey<=TimeKey-1
										   AND A.EffectiveToTimeKey>=TimeKey-1
										   --AND FinalAssetClassAlt_Key>1 

 DECLARE @ExcessProvision6 DECIMAL (20,2)= (SELECT SUM(ExcessProvision6) FROM #WriteOffPeriodBAL)

 
 DECLARE @SUB_ExcessProvision6 DECIMAL (20,2)= (SELECT SUM(SUB_ExcessProvision6) FROM #WriteOffPeriodBAL)
 DECLARE @DUB_ExcessProvision6 DECIMAL (20,2)= (SELECT SUM(DUB_ExcessProvision6) FROM #WriteOffPeriodBAL)
 DECLARE @LOS_ExcessProvision6 DECIMAL (20,2)= (SELECT SUM(LOS_ExcessProvision6) FROM #WriteOffPeriodBAL)


 IF (OBJECT_ID('tempdb..#LMSSTGDB') IS NOT NULL)
		DROP TABLE #LMSSTGDB

Select 
--CASE WHEN A.FlgUpg='U' AND AccountStatus NOT LIKE '%W%'  
--					AND UpgDate between @FinYearDate and @CurDate
--				THEN ISNULL (TotalProvision,0)				
--				END		AS LMS_CLOSED

CASE WHEN  AccountStatus NOT LIKE '%W%'  
					AND FinalNpaDt between @FinYearDate and @CurDate
				THEN ISNULL (TotalProvision,0)				
				END		AS LMS_CLOSED

			INTO #LMSSTGDB
from UTKS_STGDB..LMS_ACCOUNT_STG	STG

INNER JOIN #AccountCal_Hist A	ON A.CustomerAcID=STG.CustomerAcID
									--AND A.SourceSystem=STG.SourceSystem
									
                                     AND A.EffectiveFromTimeKey<=@TimeKey
									 AND A.EffectiveToTimeKey>=@FinYearDateKey
									 AND FinalAssetClassAlt_Key>1  
									 --AND A.CustomerAcID NOT IN (SELECT AccountID FROM SaleToArc 
										--		WHERE IS_ARC_TAGGED='Y'AND EffectiveFromTimeKey<=@TIMEKEY and  EffectiveToTimeKey>=@TIMEKEY)

WHERE AccountClosedFlag='Y' AND AccountClosedDate BETWEEN @FinYearDate AND @CurDate

----select * from #LMSSTGDB
 IF (OBJECT_ID('tempdb..#BRNETSTGDB') IS NOT NULL)
		DROP TABLE #BRNETSTGDB

Select 
--CASE WHEN A.FlgUpg='U' AND AccountStatus NOT LIKE '%W%'  
--					AND UpgDate between @FinYearDate and @CurDate
--				THEN ISNULL (TotalProvision,0)				
--				END		AS BRNET_CLOSED

CASE WHEN FinalAssetClassAlt_Key>1 AND AccountStatus NOT LIKE '%W%'  
					AND FinalNpaDt between @FinYearDate and @CurDate
				THEN ISNULL (TotalProvision,0)				
				END		AS BRNET_CLOSED

			INTO #BRNETSTGDB
from UTKS_STGDB..BRNET_ACCOUNT_STG STG
INNER JOIN #AccountCal_Hist A				ON A.CustomerAcID=STG.CustomerAcID

                                              AND A.EffectiveFromTimeKey<=@TimeKey
									          AND A.EffectiveToTimeKey>=@FinYearDateKey
											   AND FinalAssetClassAlt_Key>1 
											 --  AND A.CustomerAcID NOT IN (SELECT AccountID FROM SaleToArc 
												--WHERE IS_ARC_TAGGED='Y'AND EffectiveFromTimeKey<=@TIMEKEY and  EffectiveToTimeKey>=@TIMEKEY)

 WHERE AccountClosedFlag='Y' AND AccountClosedDate BETWEEN @FinYearDate AND @CurDate



 DECLARE  @BRNET_LMS_CLOSED DECIMAL(20,2)=((SELECT SUM(ISNULL(BRNET_CLOSED,0)) FROM #BRNETSTGDB )+(SELECT SUM(ISNULL(LMS_CLOSED,0)) FROM #LMSSTGDB ))
 --SELECT @BRNET_LMS_CLOSED
 --select * from #BRNETSTGDB

  IF (OBJECT_ID('tempdb..#WriteOffPeriod') IS NOT NULL)
		DROP TABLE #WriteOffPeriod

 select CASE WHEN AccountStatus LIKE '%W%' and StatusDate between '2024-04-01' and @CurDate
				THEN ISNULL (PrincOutStd,0)				
				END							AS	[Write-Offs-Period]

	into #WriteOffPeriod
FROM #AccountCal_Hist B
inner JOIN ExceptionFinalStatusType A           ON A.ACID=B.CustomerAcID
                                              AND A.EffectiveFromTimeKey<=@TimeKey
									          AND A.EffectiveToTimeKey>=@TimeKey
											 -- AND B.CustomerAcID NOT IN (SELECT AccountID FROM SaleToArc 
												--WHERE IS_ARC_TAGGED='Y'AND EffectiveFromTimeKey<=@TIMEKEY and  EffectiveToTimeKey>=@TIMEKEY)

                                              WHERE B.EffectiveFromTimeKey<=@TimeKey
									          AND B.EffectiveToTimeKey>=@TimeKey
											  --AND B.CustomerAcID NOT IN (SELECT AccountID FROM SaleToArc WHERE IS_ARC_TAGGED='Y')

 DECLARE  @WriteOffsPeriod  DECIMAL(20,2)=(SELECT SUM(ISNULL([Write-Offs-Period],0)) FROM #WriteOffPeriod )
 ----select @WriteOffsPeriod
 ----select SUM(ISNULL(@OpeningClossingPOS,0)+ISNULL(@NPAPeriodADSUB_PrincOutStd,0)+ISNULL(@NPAPeriodADUB_PrincOutStd,0)+ISNULL(@NPAPeriodADLOSS_PrincOutStd,0))
 ----,(ISNULL(@OpeningClossingPOS,0)+ISNULL(@NPAPeriodADSUB_PrincOutStd,0)+ISNULL(@NPAPeriodADUB_PrincOutStd,0)+ISNULL(@NPAPeriodADLOSS_PrincOutStd,0))



 IF (OBJECT_ID('tempdb..#MAIN') IS NOT NULL)
		DROP TABLE #MAIN

 SELECT   
			 --SUM(ISNULL([Total Outstanding],0))		AS  [Total Outstanding]
			 SUM(ISNULL([Total Outstanding],0))	AS [Total Outstanding]
			,SUM(ISNULL([Opening balance A],0))		AS	[Opening balance A]
			,SUM(ISNULL([Opening balance B],0))		AS	[Opening balance B]
			,SUM(ISNULL([Opening balance C],0))		AS	[Opening balance C]

	,SUM(ISNULL([Opening balance A],0))+SUM(ISNULL([Opening balance B],0))
	+SUM(ISNULL([Opening balance C],0))											AS	[Total Non-performing Advances]
	--,SUM(ISNULL([Total Outstanding],00))+SUM(ISNULL([Opening balance A],0))
	,SUM(ISNULL([Total Outstanding],0))+SUM(ISNULL([Opening balance A],0))
	+SUM(ISNULL([Opening balance B],0))+SUM(ISNULL([Opening balance C],0)	)	AS 	[Opening balance Total]

			--,CASE WHEN SUM(ISNULL(FNPrincOutStd,0))<=SUM(ISNULL(CURPrincOutStd,0)) 
			--	 THEN  SUM(ISNULL(CURPrincOutStd,0))-SUM(ISNULL(FNPrincOutStd,0))
			--	 ELSE 0
			--	 END						AS	[Additions during the year]

			,(ISNULL(@OpeningClossingPOS,0)+ISNULL(@NPAPeriodADSUB_PrincOutStd,0)+ISNULL(@NPAPeriodADUB_PrincOutStd,0)+ISNULL(@NPAPeriodADLOSS_PrincOutStd,0))	AS	[Additions during the year]

			,SUM(ISNULL(@NPAPeriodADSUB_PrincOutStd,0))	+ SUM(ISNULL(@SUB_OpeningClossingPOS,0))			 AS	[Additions during the year 1]
		    ,SUM(ISNULL(@NPAPeriodADUB_PrincOutStd,0))	+ SUM(ISNULL(@DUB_OpeningClossingPOS,0))			 AS	[Additions during the year 2]
		    ,SUM(ISNULL(@NPAPeriodADLOSS_PrincOutStd,0))+ SUM(ISNULL(@LOS_OpeningClossingPOS,0))			 AS	[Additions during the year 3] 

			
	--	 ,(((SUM(ISNULL([Opening balance A],0))+SUM(ISNULL([Opening balance B],0))
	--+SUM(ISNULL([Opening balance C],0))	+SUM(ISNULL([Additions during the year],0)))-((1030319487.02+SUM([Write-Offs]))+(207259228.49+SUM([Up_gradations]))))
	---(SUM([Closing balance F])+SUM([Closing balance G])+SUM([Closing balance H])))
	--AS	[Recoveries] 
	,SUM(ISNULL(@OpeningClossingPOSREC,0)+ISNULL(@NPAPRDRECSUB_POS,0)+ISNULL(@NPAPRDRECDUB_POS,0)+ISNULL(@NPAPRDRECLOSS_POS,0)+ISNULL(@BRNETCLOSSED,0) +ISNULL(@LMSCLOSSEDPOS,0) ) AS	[Recoveries] 


  
			--,SUM(ISNULL(Up_gradations,0))				AS	Up_gradations
			--,sum(ISNULL(@UPDOpeningPOS,0)+ISNULL(@UPGPeriodPOS,0))	AS	Up_gradations
			, ISNULL(@UPGPeriodPOS,0)					AS	Up_gradations

			,SUM(ISNULL([Write-Offs],0))				AS	[Write-Offs]
			 

			,SUM(ISNULL([Opening Provision NPA M],0))		AS [Opening Provision NPA M],	
			 SUM(ISNULL([Opening Provision NPA N],0))		AS [Opening Provision NPA N],
			 SUM(ISNULL([Opening Provision NPA O],0))		AS [Opening Provision NPA O], 

			 SUM(ISNULL([Closing Provision NPA S],0))		AS [Closing Provision NPA S], 
			 SUM(ISNULL([Closing Provision NPA R],0))		AS [Closing Provision NPA R], 
			 SUM(ISNULL([Closing Provision NPA T],0))		AS [Closing Provision NPA T],

			 -------------Closing balance ASSET CLASS WISE
			 isnull(@SUB_OpeningClossingPOSREC,0)						AS	[Recoveries1]

			,ISNULL(@DUB_OpeningClossingPOSREC,0)						AS	[Recoveries2]

			,ISNULL(@LOS_OpeningClossingPOSREC,0)						AS	[Recoveries3]
				 
			,SUM(ISNULL([Up_gradations1],0))				AS [Up_gradations1]
			,SUM(ISNULL([Write-Offs1],0))					AS [Write-Offs1]
			,SUM(ISNULL([Up_gradations2],0))				AS [Up_gradations2]
			,SUM(ISNULL([Write-Offs2],0))					AS [Write-Offs2]
			,SUM(ISNULL([Up_gradations3],0))				AS [Up_gradations3]
			,SUM(ISNULL([Write-Offs3],0))					AS [Write-Offs3]
			--,SUM(ISNULL([Write-Offs Opening Balance],0))	AS [Write-Offs Opening Balance]
			--,7645300000.00		AS [Write-Offs Opening Balance]
			,SUM(ISNULL([Write-Offs Opening Balance],0))	AS [Write-Offs Opening Balance]
			,SUM(ISNULL([Write-Offs Closing Balance],0))	AS [Write-Offs Closing Balance]

			--,CASE WHEN 7645300000.00<SUM(ISNULL([Write-Offs Closing Balance],0))
			--	  THEN SUM(ISNULL([Write-Offs Closing Balance],0))-7645300000.00
			--	  ELSE 0				
			--	  END									AS [Opening Closing Write-Offs]

			,CASE WHEN SUM(ISNULL([Write-Offs Opening Balance],0))<SUM(ISNULL([Write-Offs Closing Balance],0))
				  THEN SUM(ISNULL([Write-Offs Closing Balance],0))-7645300000.00
				  ELSE 0				
				  END									AS [Opening Closing Write-Offs]

			,SUM(ISNULL([Closing balance F],0))					AS	[Closing balance F]
			,SUM(ISNULL([Closing balance G],0))					AS	[Closing balance G]
			,SUM(ISNULL([Closing balance H],0))					AS	[Closing balance H]

			,CASE WHEN SUM(ISNULL([Opening Provision],0))<SUM(ISNULL([Closing Provision],0))
				  THEN SUM(ISNULL([Closing Provision],0))-SUM(ISNULL([Opening Provision],0))
				  ELSE 0				
				  END									AS [Opening Closing Provision]
				
			,CASE WHEN SUM(ISNULL([During Period Provision],0))<SUM(ISNULL([As On Provision],0))
				  THEN SUM(ISNULL([As On Provision],0))-SUM(ISNULL([During Period Provision],0))
				  ELSE 0				
				  END									AS 	 [During & As On Provision]

		,CASE WHEN (SUM([Write-Offs])) >SUM(ISNULL(@WriteOffsPeriod,0))
				  THEN SUM(ISNULL(@WriteOffsPeriod,0))-(SUM([Write-Offs]))
				  ELSE 0				
				  END									AS WriteOffsPeriod

		 ,ISNULL(@OpeningClossingPROV,0)+(ISNULL(@NPAPRDADDSUB_PROV ,0)+ISNULL(@NPAPRDADDDUB_PROV,0)+ISNULL(@NPAPRDADDLOSS_PROV,0))		AS Addition_PROV
		 ,ISNULL(@SUB_OpeningClossingPROV,0)+ISNULL(@NPAPRDADDSUB_PROV ,0)		AS Addition_PROV1
		 ,ISNULL(@DUB_OpeningClossingPROV,0)+ISNULL(@NPAPRDADDDUB_PROV	,0)	AS Addition_PROV2
		 ,ISNULL(@LOS_OpeningClossingPROV,0)+ISNULL(@NPAPRDADDLOSS_PROV,0)		AS Addition_PROV3

		 ,ISNULL(@ExcessProvision1,0)+ISNULL(@BRNETExcProvision5,0)+ISNULL(@LMSxcProvision5,0)+ISNULL(@UPGPeriodExcessProvision3,0)+ISNULL(@ExcessProvision2,0)  AS [Excess Provision]

		 ,ISNULL(@SUB_ExcessProvision1,0)+ISNULL(@BRNETSUB_ExcessPROV5,0)+ISNULL(@LMSSUB_ExcessPROV5,0)+ISNULL(@UPGPRDSUB_ExcessProvision3,0)+ISNULL(@UPGPRDSUB_ExcessProvision2,0)  AS [Excess Provision1]
		 ,ISNULL(@DUB_ExcessProvision1,0)+ISNULL(@BRNETDUB_ExcessPROV5,0)+ISNULL(@LMSDUB_ExcessPROV5,0)+ISNULL(@UPGPRDDUB_ExcessProvision3,0)+ISNULL(@UPGPRDDUB_ExcessProvision2,0)  AS [Excess Provision2]
		 ,ISNULL(@LOS_ExcessProvision1,0)+ISNULL(@BRNETLOS_ExcessPROV5,0)+ISNULL(@LMSLOS_ExcessPROV5,0)+ISNULL(@UPGPRDLOS_ExcessProvision3,0)+ISNULL(@UPGPRDLOS_ExcessProvision2,0)  AS [Excess Provision3]
--,(1030319487.02+SUM([Write-Offs])) AS WriteOffsPeriod2
INTO #MAIN FROM (
--SELECT [During & As On Provision],[Opening Closing Provision] FROM #MAIN
----(
----IF @FinYearDateKey<=26754

----BEGIN

 --Select 
	--		--CASE WHEN Assetcode in ('A0','S0','S1','S2','S3')
	--		-- THEN Outstanding 
	--		-- END							AS	[Total Outstanding],
	--		 162117000000 	AS	[Total Outstanding],

	--	CASE WHEN Assetcode in ('B0','B1','B2','B3')
	--		 THEN Outstanding 
	--		 END							AS	[Opening balance A],

	--	CASE WHEN Assetcode in ('C1','C3','C2')
	--		 THEN Outstanding 
	--		 END							AS	[Opening balance B],

	--	CASE WHEN Assetcode in ('D0')
	--		 THEN Outstanding
	--		 END							AS	[Opening balance C]

	--	,ISNULL (Outstanding,0)				AS  FNPrincOutStd

	--	,CASE WHEN Assetcode in ('B0','B1','B2','B3')
	--		 THEN ISNULL (Outstanding,0)				
	--		 END							AS  FNPrincOutStd1

	--	,CASE WHEN  Assetcode in ('C1','C3','C2')
	--		 THEN  ISNULL (Outstanding,0)				
	--		 END							AS  FNPrincOutStd2

	--	,CASE WHEN Assetcode in ('D0')
	--		 THEN  ISNULL (Outstanding,0)				
	--		 END							AS  FNPrincOutStd3


	--	,0									AS  CURPrincOutStd1
	--	,0									AS  CURPrincOutStd
	--	,0									AS  CURPrincOutStd2
	--	,0									AS  CURPrincOutStd3

	--	,0									AS [Up_gradations]

	--	,0									AS	[Write-Offs]
	--	,0									AS  [Up_gradations1]
	--	,0									AS	[Write-Offs1]
	--	,0									AS  [Up_gradations2]
	--	,0									AS	[Write-Offs2]
	--	,0									AS  [Up_gradations3]
	--	,0									AS	[Write-Offs3],

	--	CASE WHEN Assetcode in ('B0','B1','B2','B3','C1','C3','C2','D0')
	--		 THEN ProvisonAmt 
	--		 END							AS	[Opening Provision],

	--	CASE WHEN Assetcode in ('B0','B1','B2','B3')
	--		 THEN ProvisonAmt 
	--		 END							AS	[Opening Provision NPA M],

	--	CASE WHEN Assetcode in ('C1','C3','C2')
	--		 THEN ProvisonAmt
	--		 END							AS	[Opening Provision NPA N],

	--	CASE WHEN Assetcode in ('D0') 
	--		 THEN ProvisonAmt 
	--		 END							AS	[Opening Provision NPA O],

	--	0									AS	[Closing Provision],

	--	0									AS	[Closing Provision NPA R],

	--	0									AS	[Closing Provision NPA S],

	--	0									AS	[Closing Provision NPA T]

	--	--,CASE WHEN AccountStatus LIKE 'W' 
	--	--		THEN ISNULL (ProvisonAmt,0)				
	--	--		END							AS	[Write-Offs Opening Balance]

	--	,0									AS	[Write-Offs Opening Balance]

	--	,0									AS	[Write-Offs Closing Balance]
			 
	--	,0						AS	[Closing balance F]

	--	,0						AS	[Closing balance G]

	--	,0						AS	[Closing balance H]
		
	--	,0		AS	[Additions during the year]
	--	,0		AS	[Additions during the year 1]
	--	,0		AS	[Additions during the year 2]
	--	,0		AS	[Additions during the year 3]
	--	,0		AS	[During Period Provision]
	--	,0		AS	[As On Provision]
	--		 FROM NPAReportData 

	 Select 
			--CASE WHEN Assetcode in ('A0','S0','S1','S2','S3')
			-- THEN Outstanding 
			-- END							AS	[Total Outstanding],

		CASE WHEN B.FinalAssetClassAlt_Key =1 AND AccountStatus NOT LIKE '%W%'
			 THEN ISNULL (BALANCE,0) 
			 END							AS	[Total Outstanding],

		CASE WHEN B.FinalAssetClassAlt_Key =2 AND AccountStatus NOT LIKE '%W%'
			 THEN PrincOutStd 
			 END							AS	[Opening balance A],

		CASE WHEN B.FinalAssetClassAlt_Key IN (3,4,5) AND AccountStatus NOT LIKE '%W%'
			 THEN PrincOutStd 
			 END							AS	[Opening balance B],

		CASE WHEN B.FinalAssetClassAlt_Key =6 AND AccountStatus NOT LIKE '%W%'
			 THEN ISNULL (PrincOutStd,0)
			 END							AS	[Opening balance C]

		,ISNULL (PrincOutStd,0)				AS  FNPrincOutStd

		,CASE WHEN B.FinalAssetClassAlt_Key =2 AND AccountStatus NOT LIKE '%W%'
			 THEN ISNULL (PrincOutStd,0)				
			 END							AS  FNPrincOutStd1

		,CASE WHEN  B.FinalAssetClassAlt_Key IN (3,4,5) AND AccountStatus NOT LIKE '%W%'
			 THEN  ISNULL (PrincOutStd,0)				
			 END							AS  FNPrincOutStd2

		,CASE WHEN B.FinalAssetClassAlt_Key =6  AND AccountStatus NOT LIKE '%W%'
			 THEN  ISNULL (PrincOutStd,0)				
			 END							AS  FNPrincOutStd3


		,0									AS  CURPrincOutStd1
		,0									AS  CURPrincOutStd
		,0									AS  CURPrincOutStd2
		,0									AS  CURPrincOutStd3

		,0									AS [Up_gradations]

		,0									AS	[Write-Offs]
		,0									AS  [Up_gradations1]
		,0									AS	[Write-Offs1]
		,0									AS  [Up_gradations2]
		,0									AS	[Write-Offs2]
		,0									AS  [Up_gradations3]
		,0									AS	[Write-Offs3],

		TotalProvision							AS	[Opening Provision],

		CASE WHEN B.FinalAssetClassAlt_Key =2  AND AccountStatus NOT LIKE '%W%'
			 THEN TotalProvision 
			 END							AS	[Opening Provision NPA M],

		CASE WHEN B.FinalAssetClassAlt_Key IN (3,4,5)  AND AccountStatus NOT LIKE '%W%'
			 THEN TotalProvision
			 END							AS	[Opening Provision NPA N],

		CASE WHEN  B.FinalAssetClassAlt_Key =5  AND AccountStatus NOT LIKE '%W%'
			 THEN TotalProvision 
			 END							AS	[Opening Provision NPA O],

		0									AS	[Closing Provision],
		 

		--,CASE WHEN AccountStatus LIKE 'W' 
		--		THEN ISNULL (ProvisonAmt,0)				
		--		END							AS	[Write-Offs Opening Balance]

		CASE WHEN AccountStatus LIKE '%W%' 
				THEN ISNULL (PrincOutStd,0)				
				END										AS	[Write-Offs Opening Balance]

		,0									AS	[Write-Offs Closing Balance]
			 
		,0						AS	[Closing balance F]

		,0						AS	[Closing balance G]

		,0						AS	[Closing balance H]
		
		,0		AS	[Additions during the year]
		,0		AS	[Additions during the year 1]
		,0		AS	[Additions during the year 2]
		,0		AS	[Additions during the year 3]
		,0		AS	[During Period Provision]
		,0		AS	[As On Provision]

		,0				AS	[Closing Provision NPA R]
		,0				AS	[Closing Provision NPA S]
		,0				AS	[Closing Provision NPA T]

 FROM  #AccountCal_Hist B    WHERE B.EffectiveFromTimeKey<=@FinYearDateKey
									          AND B.EffectiveToTimeKey>=@FinYearDateKey

	------	DROP TABLE #CURRENT
	UNION ALL
SELECT   

		0									AS	[Opening balance Total]

		,0									AS	[Opening balance A]

		,0									AS	[Opening balance B]

		,0									AS	[Opening balance C]

		,0									AS	FNPrincOutStd
		,0									AS	FNPrincOutStd1
		,0									AS	FNPrincOutStd2
		,0									AS	FNPrincOutStd3

		,ISNULL (PrincOutStd,0)				AS  CURPrincOutStd

		,CASE WHEN B.FinalAssetClassAlt_Key =2  AND AccountStatus NOT LIKE '%W%'
			 THEN  ISNULL (PrincOutStd,0)				
			 END							AS  CURPrincOutStd1

		,CASE WHEN B.FinalAssetClassAlt_Key IN (3,4,5)  AND AccountStatus NOT LIKE '%W%'
			 THEN  ISNULL (PrincOutStd,0)				
			 END							AS  CURPrincOutStd2

		,CASE WHEN B.FinalAssetClassAlt_Key=6  AND AccountStatus NOT LIKE '%W%'
			 THEN  ISNULL (PrincOutStd,0)				
			 END							AS  CURPrincOutStd3

		,0									AS [Up_gradations]

		,0									AS	[Write-Offs]


		,0									AS [Up_gradations1]
		,0									AS	[Write-Offs1]
		,0									AS [Up_gradations2]
		,0									AS	[Write-Offs2]
		,0									AS [Up_gradations3]
		,0									AS	[Write-Offs3],

		 0									AS	[Opening Provision],
		 0									AS	[Opening Provision NPA M],
		 0									AS	[Opening Provision NPA N],
		 0									AS	[Opening Provision NPA O],

		 CASE WHEN B.FinalAssetClassAlt_Key IN (2,3,4,5,6) AND AccountStatus NOT  LIKE '%W%' 
			 THEN B.TotalProvision 
			 END							AS	[Closing Provision]
			  

		,0									AS	[Write-Offs Opening Balance]
		,CASE WHEN AccountStatus LIKE '%W%' 
				THEN ISNULL (PrincOutStd,0)				
				END							AS	[Write-Offs Closing Balance]

		,CASE WHEN B.FinalAssetClassAlt_Key=2 AND AccountStatus NOT  LIKE '%W%' 
				THEN ISNULL (PrincOutStd,0)
				END							AS	[Closing balance F]

		,CASE WHEN B.FinalAssetClassAlt_Key IN (3,4,5) AND AccountStatus NOT  LIKE '%W%' 
				THEN ISNULL (PrincOutStd,0)
				END							AS	[Closing balance G]

		,CASE WHEN B.FinalAssetClassAlt_Key=6 AND AccountStatus NOT  LIKE '%W%' 
				THEN ISNULL (PrincOutStd,0)
				END							AS	[Closing balance H]

		,0			AS	[Additions during the year]
		,0			AS	[Additions during the year 1]
		,0			AS	[Additions during the year 2]
		,0			AS	[Additions during the year 3] 
		,0			AS	[During Period Provision]

		,CASE WHEN B.FinalAssetClassAlt_Key IN (2,3,4,5,6) AND AccountStatus NOT  LIKE '%W%' AND FinalNpaDt BETWEEN '2024-04-01' AND  @CurDate
			 THEN B.TotalProvision 
			 END							AS	[As On Provision]

		,CASE WHEN B.FinalAssetClassAlt_Key IN (3,4,5) AND AccountStatus NOT  LIKE '%W%' 
			 THEN B.TotalProvision 
			 END							AS	[Closing Provision NPA R],

		CASE WHEN B.FinalAssetClassAlt_Key=2 AND AccountStatus NOT  LIKE '%W%' 
			 THEN B.TotalProvision 
			 END							AS	[Closing Provision NPA S],

		CASE WHEN B.FinalAssetClassAlt_Key=6 AND AccountStatus NOT  LIKE '%W%' 
			 THEN B.TotalProvision 
			 END							AS	[Closing Provision NPA T]
	 
--INTO #CURRENT

FROM #AccountCal_Hist B
--INNER JOIN  PRO.CUSTOMERCAL_Hist A          ON A.CustomerEntityID=B.CustomerEntityID
--                                              AND A.EffectiveFromTimeKey<=@TimeKey
--									          AND A.EffectiveToTimeKey>=@TimeKey
                                              WHERE B.EffectiveFromTimeKey<=@TimeKey
									          AND B.EffectiveToTimeKey>=@TimeKey
											 -- AND B.CustomerAcID NOT IN (SELECT AccountID FROM SaleToArc 
												--WHERE IS_ARC_TAGGED='Y'AND EffectiveFromTimeKey<=@TIMEKEY and  EffectiveToTimeKey>=@TIMEKEY)
	UNION ALL
SELECT   

		0									AS	[Opening balance Total]

		,0									AS	[Opening balance A]

		,0									AS	[Opening balance B]

		,0									AS	[Opening balance C]

		,0									AS	FNPrincOutStd
		,0									AS	FNPrincOutStd1
		,0									AS	FNPrincOutStd2
		,0									AS	FNPrincOutStd3

		,0									AS  CURPrincOutStd
		,0									AS  CURPrincOutStd1
		,0									AS  CURPrincOutStd2
		,0									AS  CURPrincOutStd3

		,0							AS [Up_gradations]
		
		,CASE WHEN AccountStatus LIKE '%W%' and StatusDate between '2024-07-01' and @CurDate
				THEN ISNULL (PrincOutStd,0)				
				END							AS	[Write-Offs]

		,0							AS [Up_gradations1]
		
		,CASE WHEN AccountStatus LIKE '%W%' AND B.FinalAssetClassAlt_Key=2 and StatusDate between '2024-04-01' and @CurDate
				THEN ISNULL (PrincOutStd,0)				
				END							AS	[Write-Offs1]

		,0							AS [Up_gradations2]
		
		,CASE WHEN AccountStatus LIKE '%W%' AND B.FinalAssetClassAlt_Key IN (3,4,5) and StatusDate between '2024-04-01' and @CurDate
				THEN ISNULL (PrincOutStd,0)				
				END							AS	[Write-Offs2]

		,0							AS [Up_gradations3]
		
		,CASE WHEN AccountStatus LIKE '%W%' AND B.FinalAssetClassAlt_Key=6 and StatusDate between '2024-04-01' and @CurDate
				THEN ISNULL (PrincOutStd,0)				
				END							AS	[Write-Offs3],
		 0									AS	[Opening Provision],
		 0									AS	[Opening Provision NPA M],
		 0									AS	[Opening Provision NPA N],
		 0									AS	[Opening Provision NPA O],
		 
		0									AS	[Closing Provision] 

		,0									AS	[Write-Offs Opening Balance]
		,0									AS	[Write-Offs Closing Balance]

		,0						AS	[Closing balance F]

		,0						AS	[Closing balance G]

		,0						AS	[Closing balance H]
		,0		AS	[Additions during the year]

		,0 AS	[Additions during the year 1]
		,0 AS	[Additions during the year 2]
		,0 AS	[Additions during the year 3] 

		,CASE WHEN B.FinalAssetClassAlt_Key IN (2,3,4,5,6) AND AccountStatus NOT  LIKE '%W%' AND FinalNpaDt BETWEEN '2024-04-01' AND  @CurDate
			 THEN B.TotalProvision 
			 END							AS	[During Period Provision]

		,0		AS	[As On Provision]
		,0				AS	[Closing Provision NPA R]
		,0				AS	[Closing Provision NPA S]
		,0				AS	[Closing Provision NPA T]
 
FROM #AccountCal_Hist B
left JOIN ExceptionFinalStatusType A           ON A.ACID=B.CustomerAcID
                                              AND A.EffectiveFromTimeKey<=@TimeKey
									          AND A.EffectiveToTimeKey>=@FinYearDateKey
                                              WHERE B.EffectiveFromTimeKey<=@TimeKey
									          AND B.EffectiveToTimeKey>=@FinYearDateKey
											 -- AND B.CustomerAcID NOT IN (SELECT AccountID FROM SaleToArc 
												--WHERE IS_ARC_TAGGED='Y'AND EffectiveFromTimeKey<=@TIMEKEY and  EffectiveToTimeKey>=@TIMEKEY)

	UNION ALL
SELECT   

		0									AS	[Opening balance Total]

		,0									AS	[Opening balance A]

		,0									AS	[Opening balance B]

		,0									AS	[Opening balance C]

		,0									AS	FNPrincOutStd
		,0									AS	FNPrincOutStd1
		,0									AS	FNPrincOutStd2
		,0									AS	FNPrincOutStd3

		,0									AS  CURPrincOutStd
		,0									AS  CURPrincOutStd1
		,0									AS  CURPrincOutStd2
		,0									AS  CURPrincOutStd3

		,CASE WHEN B.FlgUpg='U' AND AccountStatus NOT LIKE '%W%'  
					AND UpgDate between '2024-07-01' and @CurDate
				THEN ISNULL (PrincOutStd,0)				
				END							AS [Up_gradations]
		
		,0						AS	[Write-Offs]

		,CASE WHEN B.FlgUpg='U' AND B.InitialAssetClassAlt_Key=2 AND AccountStatus NOT LIKE '%W%'  
					AND UpgDate between '2024-04-01' and @CurDate
				THEN ISNULL (PrincOutStd,0)				
				END							AS [Up_gradations1]
		
		,0						AS	[Write-Offs1]

		,CASE WHEN B.FlgUpg='U' AND B.InitialAssetClassAlt_Key IN (3,4,5) AND AccountStatus NOT LIKE '%W%'  
					AND UpgDate between '2024-04-01' and @CurDate
				THEN ISNULL (PrincOutStd,0)				
				END							AS [Up_gradations2]
		
		,0							AS	[Write-Offs2]

		,CASE WHEN B.FlgUpg='U' AND B.InitialAssetClassAlt_Key=6 AND AccountStatus NOT LIKE '%W%'  
					AND UpgDate between '2024-04-01' and @CurDate
				THEN ISNULL (PrincOutStd,0)				
				END							AS [Up_gradations3]
		
		,0						AS	[Write-Offs3],

		 0									AS	[Opening Provision],
		 0									AS	[Opening Provision NPA M],
		 0									AS	[Opening Provision NPA N],
		 0									AS	[Opening Provision NPA O],
		 
		0									AS	[Closing Provision] 

		,0									AS	[Write-Offs Opening Balance]
		,0									AS	[Write-Offs Closing Balance]

		,0						AS	[Closing balance F]

		,0						AS	[Closing balance G]

		,0						AS	[Closing balance H]
		,0			AS	[Additions during the year]
		,0 AS	[Additions during the year 1]
		,0 AS	[Additions during the year 2]
		,0 AS	[Additions during the year 3] 
		
		,0		AS	[During Period Provision]
		,0		AS	[As On Provision]
		,0				AS	[Closing Provision NPA R]
		,0				AS	[Closing Provision NPA S]
		,0				AS	[Closing Provision NPA T]
 
FROM #AccountCal_Hist B
--left JOIN ExceptionFinalStatusType A           ON A.ACID=B.CustomerAcID
--                                              AND A.EffectiveFromTimeKey<=@TimeKey
--									          AND A.EffectiveToTimeKey>=@FinYearDateKey
                                              WHERE B.EffectiveFromTimeKey<=@TimeKey
									          AND B.EffectiveToTimeKey>=@FinYearDateKey
											 -- AND B.CustomerAcID NOT IN (SELECT AccountID FROM SaleToArc 
												--WHERE IS_ARC_TAGGED='Y'AND EffectiveFromTimeKey<=@TIMEKEY and  EffectiveToTimeKey>=@TIMEKEY)

	UNION ALL
SELECT   

		0									AS	[Opening balance Total]

		,0									AS	[Opening balance A]

		,0									AS	[Opening balance B]

		,0									AS	[Opening balance C]

		,0									AS	FNPrincOutStd
		,0									AS	FNPrincOutStd1
		,0									AS	FNPrincOutStd2
		,0									AS	FNPrincOutStd3

		,0									AS  CURPrincOutStd
		,0									AS  CURPrincOutStd1
		,0									AS  CURPrincOutStd2
		,0									AS  CURPrincOutStd3

		,0						AS [Up_gradations]
		
		,0						AS	[Write-Offs]

		,0						AS [Up_gradations1]
		
		,0						AS	[Write-Offs1]

		,0							AS [Up_gradations2]
		
		,0							AS	[Write-Offs2]

		,0						AS [Up_gradations3]
		
		,0						AS	[Write-Offs3],

		 0									AS	[Opening Provision],
		 0									AS	[Opening Provision NPA M],
		 0									AS	[Opening Provision NPA N],
		 0									AS	[Opening Provision NPA O],
		 
		0									AS	[Closing Provision] 

		,0									AS	[Write-Offs Opening Balance]
		,0									AS	[Write-Offs Closing Balance]

		,0						AS	[Closing balance F]

		,0						AS	[Closing balance G]

		,0						AS	[Closing balance H]

		,CASE WHEN FinalNpaDt	>= '2024-04-01' AND AccountStatus NOT LIKE '%W%'  
			THEN  ISNULL(PrincOutStd,0)	END			AS	[Additions during the year]

		,CASE WHEN FinalNpaDt	>= '2024-04-01' AND AccountStatus NOT LIKE '%W%'  AND B.FinalAssetClassAlt_Key=2
			THEN  ISNULL(PrincOutStd,0)	END AS	[Additions during the year 1]

		,CASE WHEN FinalNpaDt	>= '2024-04-01' AND AccountStatus NOT LIKE '%W%'  AND B.FinalAssetClassAlt_Key IN (3,4,5)
			THEN  ISNULL(PrincOutStd,0)	END AS	[Additions during the year 2]

		,CASE WHEN FinalNpaDt	>= '2024-04-01' AND AccountStatus NOT LIKE '%W%'  AND B.FinalAssetClassAlt_Key=6
			THEN  ISNULL(PrincOutStd,0)	END AS	[Additions during the year 3]
			
		,0		AS	[During Period Provision]
		,0		AS	[As On Provision]
		,0				AS	[Closing Provision NPA R]
		,0				AS	[Closing Provision NPA S]
		,0				AS	[Closing Provision NPA T]
 
FROM #AccountCal_Hist B
--left JOIN ExceptionFinalStatusType A           ON A.ACID=B.CustomerAcID
--                                              AND A.EffectiveFromTimeKey<=@TimeKey
--									          AND A.EffectiveToTimeKey>=@FinYearDateKey
                                              WHERE B.EffectiveFromTimeKey<=@TimeKey
									          AND B.EffectiveToTimeKey>=@FinYearDateKey
											 -- AND B.CustomerAcID NOT IN (SELECT AccountID FROM SaleToArc 
												--WHERE IS_ARC_TAGGED='Y'AND EffectiveFromTimeKey<=@TIMEKEY and  EffectiveToTimeKey>=@TIMEKEY)
 )A


 --  (Up_gradations+Recoveries+[Write-Offs]+1030319487.02+207259228.49)/@Cost		AS [Reductions during the year]

	SELECT (Up_gradations+Recoveries+[Write-Offs])/@Cost		AS [Reductions during the year]

		 --(([Additions during the year]+162117000000)-(Up_gradations+Recoveries+[Write-Offs]+34444069))/@Cost		AS [Closing balance]
		 , ((([Additions during the year])+([Total Non-performing Advances]))-(Up_gradations+Recoveries+[Write-Offs]))/@Cost	AS [Closing balance]




		--,((([Additions during the year 1])+([Opening balance A]))-(Up_gradations1+Recoveries1+[Write-Offs1]))	AS	[Closing balance F]
		--,((([Additions during the year 2])+([Opening balance B]))-(Up_gradations2+Recoveries2+[Write-Offs2]))	AS	[Closing balance G]
		--,((([Additions during the year 3])+([Opening balance C]))-(Up_gradations3+Recoveries3+[Write-Offs3]))	AS	[Closing balance H]

			,[Closing balance F]/@Cost	  AS	[Closing balance F]
			,[Closing balance G]/@Cost	  AS	[Closing balance G]
			,[Closing balance H]/@Cost	  AS	[Closing balance H]


		--,CASE WHEN [Write-Offs Opening Balance]>=[Write-Offs Closing Balance]
		--		THEN  ([Write-Offs Closing Balance]-[Write-Offs Opening Balance])/@Cost
		--		ELSE 0								END			AS [Add Write-Offs]
		 
		
		 ,[Total Outstanding]/@COST			AS	[Total Outstanding]
		 ,[Opening balance A]/@COST			AS	[Opening balance A]
		 ,[Opening balance B]/@COST			AS	[Opening balance B]
		 ,[Opening balance C]/@COST			AS	[Opening balance C]
		 ,([Opening balance Total])/@Cost			AS	[Opening balance Total]
		 ,[Total Non-performing Advances]/@Cost		AS	[Total Non-performing Advances]
		 ,[Additions during the year 1]/@Cost		AS	[Additions during the year 1]
		 ,[Additions during the year]/@Cost			AS	[Additions during the year]
		 ,[Additions during the year 2]/@Cost		AS	[Additions during the year 2]	
		 ,[Additions during the year 3]/@Cost		AS	[Additions during the year 3]
		 ----,(203173971.5+[Up_gradations])/@Cost						AS	Up_gradations
		 --,(207259228.49+[Up_gradations])/@Cost		AS	Up_gradations

		  ,Up_gradations /@Cost					AS	Up_gradations

		 ,[Recoveries]/@Cost				 		AS	[Recoveries]
		 --,(1030319487.02+[Write-Offs])/@Cost	   	AS	[Write-Offs]--,[Write-Offs]
		 ,([Write-Offs])/@Cost	   					AS	[Write-Offs]
		 ,[Opening Provision NPA M]/@COST			AS	[Opening Provision NPA M]
		 ,[Opening Provision NPA N]/@COST			AS	[Opening Provision NPA N]
		 ,[Opening Provision NPA O]/@COST			AS	[Opening Provision NPA O]

		 ,[Closing Provision NPA R]/@COST			AS	[Closing Provision NPA S]
		 ,[Closing Provision NPA S]/@COST			AS	[Closing Provision NPA R]
		 ,[Closing Provision NPA T]/@COST			AS	[Closing Provision NPA T]

		 --,(Up_gradations1+Recoveries1+[Write-Offs1]) AS	[Closing Provision NPA S]
		 --,(Up_gradations2+Recoveries2+[Write-Offs2]) AS	[Closing Provision NPA R]
		 --,(Up_gradations3+Recoveries3+[Write-Offs3]) AS	[Closing Provision NPA T]

		 ,[Recoveries2]/@COST						AS	[Recoveries2]
		 ,[Recoveries1]/@COST						AS	[Recoveries1]
		 ,[Recoveries3]/@COST						AS	[Recoveries3]

		 --,[Up_gradations1]/@COST							AS	[Up_gradations1]
		 ,(ISNULL(@UPDOpening_SUB_POS,0)+ISNULL(@UPGSUB_AsON,0)	)/@COST							AS	[Up_gradations1]
		 ,[Write-Offs1]/@COST								AS	[Write-Offs1]

		 --,[Up_gradations2]/@COST							AS	[Up_gradations2]
		 ,(ISNULL(@UPDOpening_DUB_POS,0)+ISNULL(@UPGDUB_AsON,0)	)/@COST							AS	[Up_gradations2]

		 ,[Write-Offs2]/@COST								AS	[Write-Offs2]

		 --,[Up_gradations3]/@COST							AS	[Up_gradations3]
		 ,(ISNULL(@UPDOpening_LOS_POS,0)+ISNULL(@UPGDUB_AsON,0)	)/@COST							AS	[Up_gradations3]

		 ,[Write-Offs3]/@COST								AS	[Write-Offs3]
		 ----,7645300000.00/@COST								AS	[Write-Offs Opening Balance]
		 --,9929560985.00/@COST								AS	[Write-Offs Opening Balance]
		 ,[Write-Offs Opening Balance]	/@COST				AS [Write-Offs Opening Balance]
		 ,[Write-Offs Closing Balance]/@COST				AS	[Write-Offs Closing Balance]

		  
		 ,(WriteOffsPeriod+[Opening Closing Write-Offs])/@COST								AS WriteOffsPeriod
		 
		 --,[Opening Closing Write-Offs],WriteOffsPeriod
		 --, ([During & As On Provision]+[Opening Closing Provision]+ISNULL(@BRNET_LMS_CLOSED,0))/@Cost		AS [Excess Provision]
		 , Addition_PROV/@COST	AS Addition_PROV

		 --, (([Opening Provision NPA M]+Addition_PROV1)-([Excess Provision1]))/@COST		AS [Closing Provision NPA R]
		 --, (([Opening Provision NPA N]+Addition_PROV2)-([Excess Provision2]))/@COST		AS [Closing Provision NPA S]
		 --, (([Opening Provision NPA O]+Addition_PROV3)-([Excess Provision3]))/@COST		AS [Closing Provision NPA T]

		 , ((([Opening Provision NPA M]+[Opening Provision NPA N]+[Opening Provision NPA O])+Addition_PROV)-([Excess Provision]))/@COST		AS [Closing Provision NPA]


		 , [Excess Provision]/@COST		AS [Excess Provision]

		 

		  
		FROM   #MAIN
	
GO