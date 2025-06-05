SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--USE [YES_MISDB]
--GO
--/****** Object:  StoredProcedure [PRO].[COBORROWER_DEG_UPG_MARKING]    Script Date: 30-10-2023 14:37:11 ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO

--/*=========================================
-- AUTHER : AMAR YADAV
-- CREATE DATE : 23-10-2023
-- MODIFY DATE : 
-- DESCRIPTION :MARKING COBORROWER AS NPA
-- =============================================*/
----EXEC [PRO].[COBORROWER_DEG_UPG_MARKING] @TimeKey,'U'

CREATE PROC [PRO].[COBORROWER_DEG_UPG_MARKING] 
	@TimeKey INT=49999,
	@FLG_UPG_DEG CHAR(1)='U' ---------- D- FOR NPA MARKING, U FOR UPGRADE, I- FOR INSERT , H- FOR HIST
	WITH RECOMPILE
	AS

/*--
DECLARE  @TimeKey INT=26686, 
		@FLG_UPG_DEG CHAR(1)='U' 
*/

BEGIN
DECLARE @PROCESSDATE DATE =(SELECT DATE FROM SysDayMatrix WHERE TimeKey=@TimeKey)


IF @FLG_UPG_DEG='I'
	BEGIN
			TRUNCATE TABLE Pro.CoBorrowerDataCal 

			insert into Pro.CoBorrowerDataCal 
					(
						AsOnDate
						,SourceSystemName_PrimaryAccount
						,NCIFID_PrimaryAccount
						,CustomerId_PrimaryAccount
						,CustomerACID_PrimaryAccount
						,NCIFID_COBORROWER
						,Flag
					)

			SELECT		@PROCESSDATE AsOnDate
						,SourceSystemName_PrimaryAccount
						,NCIFID_PrimaryAccount
						,CustomerId_PrimaryAccount
						,CustomerACID_PrimaryAccount
						,NCIFID_COBORROWER
						,'S' Flag  /* COMING FROM SOURCE SYSTEM*/
			FROM CurDat.CoborrowberDetails
				WHERE  EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY

			/*MISSING ACCOUNT INSERT */

			DROP TABLE IF EXISTS #CoborrowberDetails_UCIF

			SELECT NCIFID_PrimaryAccount INTO #CoborrowberDetails_UCIF FROM Pro.CoBorrowerDataCal
			GROUP BY NCIFID_PrimaryAccount

			insert into Pro.CoBorrowerDataCal 
					(
						AsOnDate
						,SourceSystemName_PrimaryAccount
						,NCIFID_PrimaryAccount
						,CustomerId_PrimaryAccount
						,CustomerACID_PrimaryAccount
						,NCIFID_COBORROWER
						,Flag
					)

			SELECT		@PROCESSDATE
						,D.SourceName SourceSystemName_PrimaryAccount
						,B.UCIF_ID NCIFID_PrimaryAccount
						,B.RefCustomerID CustomerId_PrimaryAccount
						,B.CustomerAcID CustomerACID_PrimaryAccount 
						,NULL NCIFID_COBORROWER
						,'D' Flag /*INSERTED BY D2K*/
			 from #CoborrowberDetails_UCIF A INNER JOIN PRO.ACCOUNTCAL B ON A.NCIFID_PrimaryAccount=B.UCIF_ID
											INNER JOIN DimSourceDB D ON D.SourceAlt_Key=B.SourceAlt_Key
																		AND D.EffectiveFromTimeKey<=@TIMEKEY AND D.EffectiveToTimeKey>=@TIMEKEY
											LEFT JOIN Pro.CoBorrowerDataCal C ON A.NCIFID_PrimaryAccount=C.NCIFID_PrimaryAccount
																				AND B.CustomerAcID=C.CustomerACID_PrimaryAccount
											WHERE C.CustomerACID_PrimaryAccount IS NULL
												
			/*UPDATE D2K COLUMNS FROM HIST ON PREV TIMEKEY*/

			UPDATE A SET A.AcDegFlg=B.AcDegFlg
					,A.AcDegDate=B.AcDegDate
					,A.AcUpgFlg=B.AcUpgFlg
					,A.AcUpgDate=B.AcUpgDate
			 FROM Pro.CoBorrowerDataCal A INNER JOIN Pro.CoBorrowerDataCal_Hist B
										ON A.CustomerACID_PrimaryAccount=B.CustomerACID_PrimaryAccount
											AND B.EffectiveFromTimeKey=@TIMEKEY-1 AND B.EffectiveToTimeKey=@TIMEKEY-1


	END
IF @FLG_UPG_DEG='D'
	BEGIN
	--select  	* from pro.CoBorrowerDetails
	--select * from pro.accountcal

	/* PREPARING CO-BORROWER DATA FOR MARKING UPGRADE */---insert MainBorrower and CoBorrower data into temp table
		IF OBJECT_ID('TEMPDB..#CUST_SELF_NPA') IS NOT NULL
			DROP TABLE #CUST_SELF_NPA
			SELECT A.CustomerACID_PrimaryAccount,a.CustomerId_PrimaryAccount,A.NCIFID_PrimaryAccount
				INTO #CUST_SELF_NPA
			FROM Pro.CoBorrowerDataCal  A   
				INNER JOIN PRO.ACCOUNTCAL B 
				ON A.CustomerACID_PrimaryAccount =B.CustomerAcID
				WHERE ISNULL(FinalAssetClassAlt_Key,1)<>1
					AND	(ISNULL(B.DPD_INTSERVICE,0)>=B.REFPERIODINTSERVICE
							OR ISNULL(B.DPD_OVERDRAWN,0)>=B.REFPERIODOVERDRAWN  
							OR ISNULL(B.DPD_NOCREDIT,0)>=B.REFPERIODNOCREDIT
							OR ISNULL(B.DPD_OVERDUE,0) >=B.REFPERIODOVERDUE 
							OR ISNULL(B.DPD_STOCKSTMT,0)>=B.REFPERIODSTKSTATEMENT
							OR ISNULL(B.DPD_RENEWAL,0)>=B.REFPERIODREVIEW 
							OR ISNULL(B.Asset_Norm,'NORMAL')='ALWYS_NPA'
						)
					and  ISNULL(B.Asset_Norm,'NORMAL')<>'ALWYS_STD'
				GROUP BY  A.CustomerACID_PrimaryAccount,a.CustomerId_PrimaryAccount,A.NCIFID_PrimaryAccount

			/*UPDATE DEG DATE AND FLAG FOR THE CUSTOMERS UNDER NPA CRITERIA*/
				UPDATE A
					 SET A.AcDegDate=@PROCESSDATE
						,A.AcDegFlg='Y'
						,AcUpgFlg='N'
						,AcUpgDate=null
				FROM Pro.CoBorrowerDataCal A 
					INNER JOIN #CUST_SELF_NPA B
						ON A.CustomerACID_PrimaryAccount=B.CustomerACID_PrimaryAccount
					WHERE isnull(A.AcDegFlg,'N')='N'


			/* MARKING CO-BORROWER AS NPA - PRIMARY BORROWER AcDegDate WILL BE NPA DATE FOR COBORROWER AND ASSET CLASS WILL BE SUB */
					UPDATE AC SET 
						 AC.FinalAssetClassAlt_Key =2
						,AC.FinalNpaDt=PRI.AcDegDate
						,AC.DegReason='DRAGGED DUE TO PRIMARY BORROWER AC/No.' + pri.CustomerACID_PrimaryAccount ---CHANGE NPA REASON PRIMARY ACCOUNT INSTEAD OF CUSTOMER ID
					FROM PRO.CoBorrowerDataCal CBR 
					INNER JOIN Pro.CoBorrowerDataCal PRI
						on PRI.NCIFID_PrimaryAccount=CBR.NCIFID_COBORROWER
					INNER JOIN PRO.ACCOUNTCAL AC
						ON  PRI.CustomerACID_PrimaryAccount=AC.CustomerAcID
						AND AC.ASSET_NORM<>'ALWYS_STD'
					WHERE AC.FinalAssetClassAlt_Key=1
						AND PRI.AcDegDate IS NOT NULL


				/*CO-BORROWER MARKED AS NPA - PERCOLATION AT CUSTOMER LEVEL */
				SELECT UCIF_ID
					,MAX(ISNULL(SYSASSETCLASSALT_KEY,1)) SYSASSETCLASSALT_KEY
					,MIN(SYSNPA_DT) SYSNPA_DT 
				INTO #TempAssetClassSourceSysCustID
				FROM(
						SELECT  A.UCIF_ID,ISNULL(A.FinalAssetClassAlt_Key,1) as SYSASSETCLASSALT_KEY
							,A.FinalNpaDt as SYSNPA_DT 
						FROM PRO.ACCOUNTCAL A
							INNER JOIN Pro.CoBorrowerDataCal B 
								ON B.CustomerId_PrimaryAccount=A.RefCustomerID
							WHERE A.Asset_Norm<>'ALWYS_STD'
					) A
				GROUP BY A.UCIF_ID				

				UPDATE A SET A.SysAssetClassAlt_Key=B.SYSASSETCLASSALT_KEY
					,A.SysNPA_Dt=B.SYSNPA_DT  
				 FROM PRO.CustomerCal A 
					INNER JOIN #TempAssetClassSourceSysCustID B 
						ON A.UCIF_ID=B.UCIF_ID
				WHERE A.Asset_Norm<>'ALWYS_STD' 

					
				/* EXECUTING AGING PROCESS TO UPDATED ASSET CLASS AS PER NPA DATE*/
	
				DECLARE @SUB_Days INT =(SELECT RefValue FROM DIMNPAAGEINGMASTER WHERE BusinessRule='Sub-Standard to Doubtful 1' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
				DECLARE @DB1_Days INT =(SELECT RefValue FROM DIMNPAAGEINGMASTER WHERE BusinessRule='Doubtful 1 to Doubtful 2'   AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
				DECLARE @DB2_Days INT =(SELECT RefValue FROM DIMNPAAGEINGMASTER WHERE BusinessRule='Doubtful 2 to Doubtful 3'   AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)


			/*------INTIAL LEVEL  DBTDT IS SET TO NULL------*/

			/*---CALCULATE SysAssetClassAlt_Key,DbtDt ------------------ */
  
				UPDATE A SET A.SysAssetClassAlt_Key= (
                                CASE  WHEN  DATEADD(MONTH,@SUB_Days,A.SysNPA_Dt)>@PROCESSDATE   
											AND B.AssetClassShortNameEnum NOT IN('DB1','DB2','DB3') -- AMAR ADDED ON 24052023
										THEN	(SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='SUB' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
									WHEN  DATEADD(MONTH,@SUB_Days,A.SysNPA_Dt)<=@PROCESSDATE AND  DATEADD(MONTH,@SUB_Days+@DB1_Days,A.SysNPA_Dt)>@PROCESSDATE   
											AND B.AssetClassShortNameEnum NOT IN('DB2','DB3') -- ADDED ON 24052023
										THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='DB1' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
									WHEN  DATEADD(MONTH,@SUB_Days+@DB1_Days,A.SysNPA_Dt)<=@PROCESSDATE AND  DATEADD(MONTH,@SUB_Days+@DB1_Days+@DB2_Days,A.SysNPA_Dt)>@PROCESSDATE 
											AND B.AssetClassShortNameEnum NOT IN('DB3') -- ADDED ON 24052023
										THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='DB2' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
									WHEN  DATEADD(MONTH,(@DB1_Days+@SUB_Days+@DB2_Days),A.SysNPA_Dt)<=@PROCESSDATE  
										THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='DB3' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
									ELSE A.SysAssetClassAlt_Key
								END)
						,A.DBTDT= (CASE 
									    WHEN  DATEADD(MONTH,@SUB_Days,A.SysNPA_Dt)<=@PROCESSDATE AND  DATEADD(MONTH,@SUB_Days+@DB1_Days,A.SysNPA_Dt)>@PROCESSDATE  THEN DATEADD(MONTH,@SUB_Days,A.SysNPA_Dt)
									    --WHEN  DATEADD(DD,1,DATEADD(MONTH,@SUB_Days+@DB1_Days,A.SysNPA_Dt))<=@PROCESSDATE AND  DATEADD(MONTH,@SUB_Days+@DB1_Days+@DB2_Days,A.SysNPA_Dt)>@PROCESSDATE   THEN DATEADD(MONTH,@SUB_Days,A.SysNPA_Dt)     ----Changed on 21 Dec 2021 for Doubtful1 Case
										WHEN  DATEADD(MONTH,@SUB_Days+@DB1_Days,A.SysNPA_Dt)<=@PROCESSDATE AND  DATEADD(MONTH,@SUB_Days+@DB1_Days+@DB2_Days,A.SysNPA_Dt)>@PROCESSDATE   THEN DATEADD(MONTH,@SUB_Days,A.SysNPA_Dt)
									    WHEN  DATEADD(MONTH,(@DB1_Days+@SUB_Days+@DB2_Days),A.SysNPA_Dt)<=@PROCESSDATE THEN DATEADD(MONTH,(@SUB_Days),A.SysNPA_Dt)
										ELSE DBTDT 
									END)

					FROM PRO.CustomerCal A INNER JOIN DimAssetClass B  ON A.SysAssetClassAlt_Key =B.AssetClassAlt_Key AND  B.EffectiveFromTimeKey<=@TIMEKEY AND B.EffectiveToTimeKey>=@TIMEKEY
						INNER JOIN Pro.CoBorrowerDataCal c on c.CustomerId_PrimaryAccount=a.RefCustomerID
					WHERE B.AssetClassShortName NOT IN('STD','LOS')
						 ----AND ISNULL(A.FlgDeg,'N')<>'Y'  AND (ISNULL(A.FlgProcessing,'N')='N')
						 AND A.SYSNPA_DT IS NOT NULL  AND ISNULL(A.FlgErosion,'N')<>'Y'

	
					/* UCIF - PERCOLATION AT SIOURCESYSTEMCUSTOERID LEVEL*/
					IF OBJECT_ID('TEMPDB..#TempAssetClass_UcifEntityID') IS NOT NULL
						DROP TABLE #TempAssetClass_UcifEntityID

					SELECT UcifEntityID
						,MAX(ISNULL(SYSASSETCLASSALT_KEY,1)) SYSASSETCLASSALT_KEY
						,MIN(SYSNPA_DT) SYSNPA_DT 
						,MIN(DbtDt) DbtDt
					INTO #TempAssetClass_UcifEntityID
					FROM(
							SELECT  A.UcifEntityID, ISNULL(A.SYSASSETCLASSALT_KEY,1) as SYSASSETCLASSALT_KEY
								,A.SYSNPA_DT as SYSNPA_DT 
								,A.DbtDt as DbtDt
							FROM PRO.CUSTOMERCAL A
								INNER JOIN(select NCIFID_PrimaryAccount FROM Pro.CoBorrowerDataCal GROUP BY NCIFID_PrimaryAccount) B 
									ON B.NCIFID_PrimaryAccount=A.UCIF_ID
								WHERE A.Asset_Norm<>'ALWYS_STD' 
						) A
					GROUP BY A.UcifEntityID

					UPDATE A SET A.SysAssetClassAlt_Key=B.SYSASSETCLASSALT_KEY
						,A.SysNPA_Dt=B.SYSNPA_DT  
						,A.DbtDt=B.DbtDt
					 FROM PRO.CustomerCal A INNER JOIN #TempAssetClass_UcifEntityID B ON A.UcifEntityID=B.UcifEntityID
					WHERE A.Asset_Norm<>'ALWYS_STD' 
 
				/*UPDATE FINALASSETCLASS AT ACCOUNT LEVEL */
				UPDATE B SET b.FinalAssetClassAlt_Key=A.SYSASSETCLASSALT_KEY
						,b.FinalNpaDt=A.SYSNPA_DT  
						,B.NPA_Reason=A.DegReason
				 FROM PRO.CustomerCal A INNER JOIN PRO.AccountCal B ON A.RefCustomerID=B.RefCustomerID
				WHERE b.Asset_Norm<>'ALWYS_STD' 

	END
IF @FLG_UPG_DEG='U'
	BEGIN
				/*UPDATE FINALASSETCLASS AT ACCOUNT LEVEL */
				IF OBJECT_ID('TEMPDB..#TEMPTABLE_COBO') IS NOT NULL
				  DROP TABLE #TEMPTABLE_COBO
		
				CREATE TABLE #TEMPTABLE_COBO (AccountEntityID int,CustomerACID_PrimaryAccount VARCHAR(30))--,TOTALCOUNT INT)
				INSERT INTO #TEMPTABLE_COBO

				SELECT B.AccountEntityID,CustomerACID_PrimaryAccount FROM PRO.CUSTOMERCAL A
					INNER JOIN PRO.ACCOUNTCAL B ON A.UCIF_ID=B.UCIF_ID
					INNER JOIN Pro.CoBorrowerDataCal C ON C.CustomerACID_PrimaryAccount=B.CustomerAcID
				WHERE (B.DPD_INTSERVICE<=B.REFPERIODINTSERVICEUPG
						AND B.DPD_OVERDRAWN <=B.REFPERIODOVERDRAWNUPG
						AND B.DPD_OVERDUE<=B.REFPERIODOVERDUEUPG
						AND B.DPD_RENEWAL<=B.REFPERIODREVIEWUPG
						AND B.DPD_STOCKSTMT <=B.REFPERIODSTKSTATEMENTUPG)
						AND B.InitialAssetClassAlt_Key NOT IN(1)
						AND B.Asset_Norm NOT IN ('ALWYS_NPA','ALWYS_STD')
				GROUP BY B.AccountEntityID,CustomerACID_PrimaryAccount
				 
			--/*26102023--FIND THE CUSTOMER FOR UPGRADE- WHOSE EITHER NOT BREACHED THE NPA CRITERIA OR AFTER NPA CAME OUT IN UPGRADE CONDITIONs */
				UNION
				SELECT b.AccountEntityID,CustomerACID_PrimaryAccount ----,A.*
				FROM Pro.CoBorrowerDataCal a
					INNER JOIN PRO.ACCOUNTCAL B
						ON  A.CustomerACID_PrimaryAccount=b.CustomerAcID
						AND b.FinalAssetClassAlt_Key>1 AND A.AcDegDate IS NULL
				GROUP BY B.AccountEntityID,CustomerACID_PrimaryAccount


			/*26102023--UPDATE UPGRADE FLAG AT CUSTOMER LEVEL FROM   */
				UPDATE A SET A.AcUpgFlg='U'
							,A.ACUPGDATE=@PROCESSDATE
							,A.ACDEGFLG='N'
							,A.AcDegDate=NULL
				-- select *
				 FROM Pro.CoBorrowerDataCal a
					INNER JOIN #TEMPTABLE_COBO  b
						ON A.CustomerACID_PrimaryAccount=b.CustomerACID_PrimaryAccount
					WHERE ISNULL(A.AcUpgFlg,'N')='N'

		
				/* UPDATE UPGRADE FLAG AT CUSTOMER LEVEL FRO CO-BORROWER DATA*/
				UPDATE B SET b.FlgUpg='U'
				FROM Pro.CoBorrowerDataCal a
					INNER JOIN PRO.CustomerCal  B
						ON  A.CustomerId_PrimaryAccount=b.RefCustomerID
					WHERE ISNULL(B.FlgUpg,'N')='N' AND A.AcUpgFlg='U'

		
				/* FIND THE CUSTOMERS - UPGRADE D IN NORMAL PROCESS BUT NOT IN CO-BORROWER DATA */
				IF OBJECT_ID('TEMPDB..#CO_BORROWER_UPG_REVERT') IS NOT NULL
					DROP TABLE #CO_BORROWER_UPG_REVERT

				 SELECT  b.UcifEntityID
					into #CO_BORROWER_UPG_REVERT
				 FROM Pro.CoBorrowerDataCal a
					INNER JOIN PRO.CustomerCal  B
						ON  A.CustomerId_PrimaryAccount=b.RefCustomerID
					WHERE ISNULL(B.FlgUpg,'N')='U' AND ISNULL(A.AcUpgFlg,'N')='N'
		
	

				/* REVERT UPGRADE FLAG FOR UCIF ENTITYID */
				UPDATE B
					SET B.FlgUpg='N'
				FROM #CO_BORROWER_UPG_REVERT A
					INNER JOIN PRO.CUSTOMERCAL B
						ON A.UcifEntityID=B.UcifEntityID
					WHERE 	B.FlgUpg='U'	


				
		
	END
IF @FLG_UPG_DEG='H'
	BEGIN


	/* DELETE FROM HIST TABLE IS ALREADY CURRENT DATE DATA IS AVAILABLE IN THE SAME*/
	DELETE FROM PRO.CoBorrowerDataCal_Hist WHERE EFFECTIVEFROMTIMEKEY=@TimeKey AND EFFECTIVETOTIMEKEY=@TimeKey


	/* INSERTING DATA FROM CURRENT TO HIST TABLE */
		INSERT INTO PRO.CoBorrowerDataCal_Hist
				(AsOnDate
				,SourceSystemName_PrimaryAccount
				,NCIFID_PrimaryAccount
				,CustomerId_PrimaryAccount
				,CustomerACID_PrimaryAccount
				,NCIFID_COBORROWER
				,AcDegFlg
				,AcDegDate
				,AcUpgFlg
				,AcUpgDate
				,Flag
				,EFFECTIVEFROMTIMEKEY
				,EFFECTIVETOTIMEKEY
		) 
		SELECT 
				AsOnDate
				,SourceSystemName_PrimaryAccount
				,NCIFID_PrimaryAccount
				,CustomerId_PrimaryAccount
				,CustomerACID_PrimaryAccount
				,NCIFID_COBORROWER
				,AcDegFlg
				,AcDegDate
				,AcUpgFlg
				,AcUpgDate
				,Flag
				,@TimeKey EFFECTIVEFROMTIMEKEY
				,@TimeKey EFFECTIVETOTIMEKEY
		 FROM PRO.CoBorrowerDataCal

		
	END
			
END 
GO