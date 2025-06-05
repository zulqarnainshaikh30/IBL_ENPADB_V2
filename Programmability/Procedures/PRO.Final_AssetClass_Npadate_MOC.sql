SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/*=========================================
 AUTHER : TRILOKI KHANNA
 CREATE DATE : 27-11-2019
 MODIFY DATE : 27-11-2019
 DESCRIPTION :UPDATE FINAL ASSET CLASS AND MIN NPA DATE UPDATE CUSTOMER LEVEL AT ACCOUNT LEVEL
 EXEC [PRO].[Final_AssetClass_Npadate] 25233
=============================================*/
CREATE PROCEDURE [PRO].[Final_AssetClass_Npadate_MOC]
@TIMEKEY INT with recompile
AS
BEGIN
      SET NOCOUNT ON
  BEGIN TRY
 
         --DECLARE @PANCARDFLAG CHAR(1)=(SELECT REFVALUE FROM PRO.REFPERIOD WHERE BUSINESSRULE='PANCARDNO' AND EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND EFFECTIVETOTIMEKEY>=@TIMEKEY)
		--DECLARE @AADHARCARDFLAG CHAR(1)=(SELECT REFVALUE FROM PRO.REFPERIOD WHERE BUSINESSRULE='AADHARCARD' AND EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND EFFECTIVETOTIMEKEY>=@TIMEKEY)
		DECLARE @PANCARDFLAG CHAR(1)=(SELECT 'Y' FROM solutionglobalparameter WHERE ParameterName='PAN Aadhar Dedup Integration' and  ParameterValueAlt_Key=1 AND EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND EFFECTIVETOTIMEKEY>=@TIMEKEY)
		DECLARE @AADHARCARDFLAG CHAR(1)=(SELECT 'Y' FROM solutionglobalparameter WHERE ParameterName='PAN Aadhar Dedup Integration' and  ParameterValueAlt_Key=1 AND EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND EFFECTIVETOTIMEKEY>=@TIMEKEY)

DECLARE @JointAccountFlag char(1)=(select RefValue from pro.RefPeriod where BusinessRule='Joint Account' and EffectiveFromTimeKey<=@TIMEKEY and EffectiveToTimeKey>=@TIMEKEY)
DECLARE @UCFICFlag char(1)=(select RefValue from pro.RefPeriod where BusinessRule='UCFIC' and EffectiveFromTimeKey<=@TIMEKEY and EffectiveToTimeKey>=@TIMEKEY)


UPDATE  B SET B.finalAssetClassAlt_Key=1
FROM PRO.CustomerCal  A INNER JOIN PRO.AccountCal B ON A.SourceSystemCustomerID=B.SourceSystemCustomerID AND (A.FlgProcessing='N')
 WHERE A.Asset_Norm='ALWYS_STD'

/*---update FINALAssetClassAlt_Key  of those account which are not synk customer asset class key---------------------*/

UPDATE B SET B.finalAssetClassAlt_Key=  CASE WHEN A.Asset_Norm<>'ALWYS_STD' THEN A.SysAssetClassAlt_Key 
ELSE (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='STD' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY) END
FROM PRO.CustomerCal  A INNER JOIN PRO.AccountCal B ON A.RefCustomerID=B.RefCustomerID AND (ISNULL(A.FlgProcessing,'N')='N')
AND A.RefCustomerID IS NOT  NULL

UPDATE B SET B.finalAssetClassAlt_Key=  CASE WHEN A.Asset_Norm<>'ALWYS_STD' THEN A.SysAssetClassAlt_Key 
ELSE (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='STD' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY) END
FROM PRO.CustomerCal  A INNER JOIN PRO.AccountCal B ON A.SourceSystemCustomerID=B.SourceSystemCustomerID AND (ISNULL(A.FlgProcessing,'N')='N')
where A.SysAssetClassAlt_Key<>B.FinalAssetClassAlt_Key AND B.RefCustomerID is null 



/*---------------NPA DATE UPDATE CUSTOMER TO ACCOUNT LEVEL----------------------------------*/



UPDATE B SET B.FinalNpaDt=A.SYSNPA_DT FROM PRO.CUSTOMERCAL A INNER JOIN PRO.ACCOUNTCAL B  ON A.SourceSystemCustomerID=B.SourceSystemCustomerID
WHERE ISNULL(B.ASSET_NORM,'NORMAL')<>'ALWYS_STD' AND (ISNULL(A.FlgProcessing,'N')='N') 
and  isnull(A.SysNPA_Dt,'')<>isnull(b.FinalNpaDt,'') 
AND ISNULL(A.FlgDeg,'N')='Y'


UPDATE A SET A.FINALASSETCLASSALT_KEY=1,FINALNPADT=NULL FROM PRO.ACCOUNTCAL  A WHERE ASSET_NORM='ALWYS_STD' AND FINALASSETCLASSALT_KEY>1


--UPDATE A SET InitialAssetClassAlt_Key=1,FinalAssetClassAlt_Key=1,InitialNpaDt=NULL,FinalNpaDt=NULL, DEGREASON=NULL FROM PRO.AccountCal A WHERE A.ASSET_NORM ='ALWYS_STD'

/*------UPDATING DEG REASON  FOR ACCOUNT WHERE  NO DEFAULT IS THERE------ */

UPDATE B SET  B.DEGREASON=NULL FROM PRO.CUSTOMERCAL A INNER JOIN PRO.ACCOUNTCAL  B ON A.SourceSystemCustomerID=B.SourceSystemCustomerID
WHERE A.FLGDEG='Y' AND B.DEGREASON IS NULL AND B.ASSET_NORM <>'ALWYS_STD' AND (ISNULL(A.FlgProcessing,'N')='N')

UPDATE B SET  B.DEGREASON='PERCOLATION BY OTHER ACCOUNT' FROM PRO.CUSTOMERCAL A INNER JOIN PRO.ACCOUNTCAL  B ON A.SourceSystemCustomerID=B.SourceSystemCustomerID
WHERE A.FLGDEG='Y' AND B.DEGREASON IS NULL AND B.ASSET_NORM <>'ALWYS_STD' AND (ISNULL(A.FlgProcessing,'N')='N')

	 
 UPDATE A SET DEGREASON=B.DEGREASON
  FROM PRO.ACCOUNTCAL A
INNER JOIN PRO.CUSTOMERCAL B
ON A.SOURCESYSTEMCUSTOMERID=B.SOURCESYSTEMCUSTOMERID
 WHERE A.DEGREASON='PERCOLATION BY OTHER ACCOUNT'

---------------------------------------------------------------------
--START OF MODIFICATION--HANDLING OF ACCOUNTS WITH FUTURE NPA DATE
---------------------------------------------------------------------


DECLARE @REF_DATE AS DATE = (SELECT Date FROM [dbo].Automate_Advances WHERE EXT_FLG='Y')
UPDATE PRO.CustomerCal SET SysNPA_Dt = @REF_DATE WHERE ISNULL(SysNPA_Dt,'1900-01-01') > @REF_DATE

UPDATE PRO.AccountCal SET FinalNpaDt = @REF_DATE WHERE ISNULL(FinalNpaDt,'1900-01-01') > @REF_DATE

UPDATE PRO.CustomerCal SET SysNPA_Dt = @REF_DATE WHERE SysNPA_Dt IS NULL AND SysAssetClassAlt_Key>1
UPDATE PRO.AccountCal SET FinalNpaDt = @REF_DATE WHERE FinalNpaDt IS NULL AND FinalAssetClassAlt_Key>1



		/* MERGING DATA FOR ALL SOURCES FOR FIND LOWEST ASSET CLASS AND MIN NPA DATE */
	
	IF OBJECT_ID('TEMPDB..#CTE_PERC') IS NOT NULL
    DROP TABLE #CTE_PERC

	SELECT * INTO 
		#CTE_PERC
	FROM
		(		/* ADVANCE DATA */
			SELECT UCIF_ID,MAX(ISNULL(SYSASSETCLASSALT_KEY,1)) SYSASSETCLASSALT_KEY ,MIN(SYSNPA_DT) SYSNPA_DT
			,'ADV' PercType
			FROM PRO.CUSTOMERCAL A WHERE ( UCIF_ID IS NOT NULL and UCIF_ID<>'0' ) AND  ISNULL(SYSASSETCLASSALT_KEY,1)<>1
			GROUP BY  UCIF_ID
			
		)A

	/*  FIND LOWEST ASSET CLASS AND IN NPA DATE IN AALL SOURCES */
	IF OBJECT_ID('TEMPDB..#TEMPTABLE_UCFIC1') IS NOT NULL
    DROP TABLE #TEMPTABLE_UCFIC1

	SELECT UCIF_ID, MAX(SYSASSETCLASSALT_KEY) SYSASSETCLASSALT_KEY, MIN(SYSNPA_DT)SYSNPA_DT
			,'XXX' PercType
		INTO #TEMPTABLE_UCFIC1 
	FROM #CTE_PERC
		GROUP BY UCIF_ID

	UPDATE A
		SET A.PercType=B.PercType 
	FROM #TEMPTABLE_UCFIC1 A
		INNER JOIN #CTE_PERC B
			ON A.UCIF_ID =B.UCIF_ID
			AND A.SYSASSETCLASSALT_KEY =B.SYSASSETCLASSALT_KEY 
			

	DROP TABLE IF EXISTS #CTE_PERC

	/*  UPDATE LOWEST ASSET CLASS AND MIN NPA DATE IN - ADVANCE DATA */
	UPDATE A SET SysAssetClassAlt_Key=B.SYSASSETCLASSALT_KEY
				,A.SysNPA_Dt=B.SYSNPA_DT
				,A.DegReason=CASE WHEN A.SysAssetClassAlt_Key =1 AND B.SYSASSETCLASSALT_KEY >1 
								THEN  
									CASE WHEN B.PercType ='INV' THEN	'PERCOLATION BY INVESTMENT UCIFID '  + B.UCIF_ID 
										 WHEN B.PercType ='DER' THEN	'PERCOLATION BY DERIVATIVE UCIFID '  + B.UCIF_ID  	
										ELSE A.DegReason
									END 
								ELSE  A.DegReason
							END
	FROM PRO.CUSTOMERCAL A
		INNER JOIN #TEMPTABLE_UCFIC1 B ON A.UCIF_ID =B.UCIF_ID

	DROP TABLE IF EXISTS #TEMPTABLE_UCFIC1


/* END OF PERCOLATION WORK */


	 UPDATE A SET 
	         A.FinalAssetClassAlt_Key=ISNULL(B.SysAssetClassAlt_Key,1)
		    ,A.FinalNpaDt=B.SysNPA_Dt
			FROM PRO.AccountCal A INNER   JOIN PRO.CustomerCal B 
			ON  A.RefCustomerID=B.RefCustomerID AND A.SourceSystemCustomerID=B.SourceSystemCustomerID 
			WHERE ISNULL(B.SysAssetClassAlt_Key,1)<>1 AND B.RefCustomerID<>'0'

	UPDATE A SET 
	         A.FinalAssetClassAlt_Key=ISNULL(B.SysAssetClassAlt_Key,1)
		    ,A.FinalNpaDt=B.SysNPA_Dt
			FROM PRO.AccountCal A INNER   JOIN PRO.CustomerCal B 
			ON  A.SourceSystemCustomerID=B.SourceSystemCustomerID 
			WHERE ISNULL(B.SysAssetClassAlt_Key,1)<>1

	UPDATE A SET 
	         A.FinalAssetClassAlt_Key=ISNULL(B.SysAssetClassAlt_Key,1)
		    ,A.FinalNpaDt=B.SysNPA_Dt
			FROM PRO.AccountCal A INNER   JOIN PRO.CustomerCal B 
			ON  A.UcifEntityID=B.UcifEntityID 
			WHERE ISNULL(B.SysAssetClassAlt_Key,1)<>1
		
	 
	 UPDATE A SET DEGREASON=B.DEGREASON
	FROM PRO.AccountCal A INNER JOIN PRO.CustomerCal B ON A.SourceSystemCustomerID =B.SourceSystemCustomerID
	WHERE (B.FlgProcessing='N')  AND (A.FLGDEG='N') AND B.DegReason IS NOT NULL AND A.FinalAssetClassAlt_Key>1 AND A.DegReason IS NULL


	 UPDATE A SET DEGREASON=B.DEGREASON
	FROM PRO.AccountCal A INNER JOIN PRO.CustomerCal B ON A.SourceSystemCustomerID =B.SourceSystemCustomerID
	WHERE (B.FlgProcessing='N')  AND (A.FLGDEG='N') AND B.DegReason IS NOT NULL AND A.FinalAssetClassAlt_Key>1
	 AND A.DegReason IS NULL


UPDATE B SET B.FinalNpaDt=A.SYSNPA_DT FROM PRO.CUSTOMERCAL A INNER JOIN PRO.ACCOUNTCAL B  ON A.SourceSystemCustomerID=B.SourceSystemCustomerID
WHERE ISNULL(B.ASSET_NORM,'NORMAL')<>'ALWYS_STD' AND (ISNULL(A.FlgProcessing,'N')='N') 
and  isnull(A.SysNPA_Dt,'')<>isnull(b.FinalNpaDt,'') 
AND ISNULL(A.FlgDeg,'N')='N'
AND A.RefCustomerID<>'0'

/*---------------UPDATE ASSET CLASS STD WHERE ASSET NORM ALWAYS STD---------------*/




--UPDATE A SET InitialAssetClassAlt_Key=1,FinalAssetClassAlt_Key=1,InitialNpaDt=NULL,FinalNpaDt=NULL, DEGREASON=NULL FROM PRO.AccountCal A WHERE A.ASSET_NORM ='ALWYS_STD'

	 ---UPDATE  MULTIPLE   DegReason IN PRO.CUSTOMERCAL TABLE-------

	 IF object_id('TEMPDB..#Data') is NOT NULL
     DROP TABLE #Data

select distinct DegReason ,SourceSystemCustomerID  INTO #Data from PRO.AccountCal  WHERE DegReason IS NOT NULL AND FLGDEG='Y'


IF object_id('TEMPDB..#DD') is NOT NULL
DROP TABLE #DD

Select SourceSystemCustomerID ,DegReason ,ROW_NUMBER()OVER(PARTITION by SourceSystemCustomerID order by SourceSystemCustomerID) AS RN  INTO #DD  FROM #Data


IF object_id('TEMPDB..#NPADegReason') is NOT NULL
DROP TABLE #NPADegReason

SELECT SourceSystemCustomerID ,DegReason INTO #NPADegReason FROM
(
Select SourceSystemCustomerID,([1] +ISNULL(' ,'+[2],'') +ISNULL(' ,' + [3],'')   +ISNULL(' ,' + [4],'')  +ISNULL(' ,' + [5],'')  +ISNULL(' ,' + [6],'')
+ISNULL(' ,' + [7],'')  +ISNULL(' ,' + [8],'')  +ISNULL(' ,' + [9],'')  +ISNULL(' ,' + [10],'')  +ISNULL(' ,' + [11],'')  +ISNULL(' ,' + [12],'')
+ISNULL(' ,' + [13],'')  +ISNULL(' ,' + [14],'')  +ISNULL(' ,' + [15],'')  +ISNULL(' ,' + [16],'')  +ISNULL(' ,' + [17],'')) AS DegReason
FROM(
Select SourceSystemCustomerID, DegReason,  RN FROM #DD  )a 
PIVOT 
(
MAX(DegReason)  FOR RN IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17])
) S
) A


UPDATE A SET DegReason=B.DegReason  FROM PRO.CustomerCal A INNER JOIN #NPADegReason B  ON A.SourceSystemCustomerID=B.SourceSystemCustomerID
AND A.FlgDeg='Y'


	Update pro.CUSTOMERCAL set FlgUpg ='N' where SrcAssetClassAlt_Key =1 and SysAssetClassAlt_Key >1
	Update pro.CUSTOMERCAL set FlgDeg ='N' where SrcAssetClassAlt_Key >1 and SysAssetClassAlt_Key =1

	Update pro.AccountCal set FlgUpg ='N',UpgDate =null where InitialAssetClassAlt_Key  =1 and FinalAssetClassAlt_Key >1
	Update pro.AccountCal set FlgDeg ='N' where InitialAssetClassAlt_Key >1 and FinalAssetClassAlt_Key =1



UPDATE PRO.ACLRUNNINGPROCESSSTATUS 
	SET COMPLETED='Y',ERRORDATE=NULL,ERRORDESCRIPTION=NULL,COUNT=ISNULL(COUNT,0)+1
	WHERE RUNNINGPROCESSNAME='Final_AssetClass_Npadate'

   DROP TABLE #Data
   DROP TABLE #DD
   DROP TABLE #NPADegReason

   -----------------Added for DashBoard 04-03-2021
Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='ASSET CLASSIFICATION'
 
END TRY
BEGIN  CATCH
	
	UPDATE PRO.ACLRUNNINGPROCESSSTATUS 
	SET COMPLETED='N',ERRORDATE=GETDATE(),ERRORDESCRIPTION=ERROR_MESSAGE(),COUNT=ISNULL(COUNT,0)+1
	WHERE RUNNINGPROCESSNAME='Final_AssetClass_Npadate'
END CATCH
SET NOCOUNT OFF
END












GO