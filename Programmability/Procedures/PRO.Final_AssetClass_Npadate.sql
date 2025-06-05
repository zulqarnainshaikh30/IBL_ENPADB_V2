SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/*=========================================
 AUTHER : TRILOKI KHANNA
 CREATE DATE : 27-11-2019
 MODIFY DATE : 07-04-2022
 DESCRIPTION :UPDATE FINAL ASSET CLASS AND MIN NPA DATE UPDATE CUSTOMER LEVEL AT ACCOUNT LEVEL
 EXEC [PRO].[Final_AssetClass_Npadate] 26479
=============================================*/
CREATE PROCEDURE [PRO].[Final_AssetClass_Npadate]
	@TIMEKEY INT, 
	@FlgPreErosion CHAR(1)='N'
with recompile
AS
BEGIN
      SET NOCOUNT ON
  BEGIN TRY
		
         --DECLARE @PANCARDFLAG CHAR(1)=(SELECT REFVALUE FROM PRO.REFPERIOD WHERE BUSINESSRULE='PANCARDNO' AND EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND EFFECTIVETOTIMEKEY>=@TIMEKEY)
		--DECLARE @AADHARCARDFLAG CHAR(1)=(SELECT REFVALUE FROM PRO.REFPERIOD WHERE BUSINESSRULE='AADHARCARD' AND EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND EFFECTIVETOTIMEKEY>=@TIMEKEY)
 --DECLARE @PANCARDFLAG CHAR(1)=(SELECT REFVALUE FROM PRO.REFPERIOD WHERE BUSINESSRULE='PANCARDNO' AND EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND EFFECTIVETOTIMEKEY>=@TIMEKEY)
		--DECLARE @AADHARCARDFLAG CHAR(1)=(SELECT REFVALUE FROM PRO.REFPERIOD WHERE BUSINESSRULE='AADHARCARD' AND EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND EFFECTIVETOTIMEKEY>=@TIMEKEY)
		DECLARE @PANCARDFLAG CHAR(1)=(SELECT 'Y' FROM solutionglobalparameter WHERE ParameterName='PAN Aadhar Dedup Integration' and  ParameterValueAlt_Key=1 AND EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND EFFECTIVETOTIMEKEY>=@TIMEKEY)
		DECLARE @AADHARCARDFLAG CHAR(1)=(SELECT 'Y' FROM solutionglobalparameter WHERE ParameterName='PAN Aadhar Dedup Integration' and  ParameterValueAlt_Key=1 AND EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND EFFECTIVETOTIMEKEY>=@TIMEKEY)
		DECLARE @Processingdate date = (Select Date from Automate_Advances where Ext_FLG = 'Y')
DECLARE @JointAccountFlag char(1)=(select RefValue from pro.RefPeriod where BusinessRule='Joint Account' and EffectiveFromTimeKey<=@TIMEKEY and EffectiveToTimeKey>=@TIMEKEY)
DECLARE @UCFICFlag char(1)=(select RefValue from pro.RefPeriod where BusinessRule='UCFIC' and EffectiveFromTimeKey<=@TIMEKEY and EffectiveToTimeKey>=@TIMEKEY)



/*---update FINALAssetClassAlt_Key  of those account which are not synk customer asset class key---------------------*/

-------------Added by Sudes/jayadev for ODFD perculation impact 19062024--


;WITH CTE_NPA_UCIFID AS 
(SELECT UcifEntityID FROM pro.ACCOUNTCAL 
WHERE FinalAssetClassAlt_Key>1
GROUP BY UcifEntityID)

UPDATE A SET A.ASSET_NORM='CONDI_STD'FROM pro.ACCOUNTCAL A 
INNER JOIN CTE_NPA_UCIFID B ON A.UcifEntityID=B.UcifEntityID 
INNER JOIN DimProduct P ON P.EffectiveFromTimeKey<=@TIMEKEY 
AND P.EffectiveToTimeKey>=@TIMEKEY AND P.ProductAlt_Key=A.ProductAlt_Key 
AND P.ProductGroup='ODFD' 
WHERE ASSET_NORM='ALWYS_STD'

------------------------------------------------------------------------------------------------------------


UPDATE B SET B.finalAssetClassAlt_Key=  CASE WHEN A.Asset_Norm<>'ALWYS_STD' THEN A.SysAssetClassAlt_Key 
ELSE (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='STD' 
AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY) END
FROM PRO.CustomerCal  A INNER JOIN PRO.AccountCal B ON A.RefCustomerID=B.RefCustomerID AND (ISNULL(A.FlgProcessing,'N')='N')
AND A.RefCustomerID IS NOT  NULL-- and ISNULL(B.WriteoffAmount,0) = 0
--------commented on 21062024 for include the two account 

/*---------------NPA DATE UPDATE CUSTOMER TO ACCOUNT LEVEL----------------------------------*/



UPDATE B SET B.FinalNpaDt=A.SYSNPA_DT FROM PRO.CUSTOMERCAL A 
INNER JOIN PRO.ACCOUNTCAL B  ON A.RefCustomerID=B.RefCustomerID
WHERE ISNULL(B.ASSET_NORM,'NORMAL')<>'ALWYS_STD' AND (ISNULL(A.FlgProcessing,'N')='N') 
and  isnull(A.SysNPA_Dt,'')<>isnull(b.FinalNpaDt,'') 
AND ISNULL(A.FlgDeg,'N')='Y'

UPDATE A SET A.FINALASSETCLASSALT_KEY=1,FINALNPADT=NULL, DEGREASON=NULL FROM PRO.ACCOUNTCAL  A WHERE ASSET_NORM='ALWYS_STD' --- AND FINALASSETCLASSALT_KEY>1S_STD'

/*------UPDATING DEG REASON  FOR ACCOUNT WHERE  NO DEFAULT IS THERE------ */

UPDATE B SET  B.DEGREASON=NULL FROM PRO.CUSTOMERCAL A INNER JOIN PRO.ACCOUNTCAL  B ON A.RefCustomerID=B.RefCustomerID
WHERE A.FLGDEG='Y' AND B.DEGREASON IS NULL AND B.ASSET_NORM <>'ALWYS_STD' AND (ISNULL(A.FlgProcessing,'N')='N')

UPDATE B SET  B.DEGREASON='PERCOLATION BY OTHER ACCOUNT' FROM PRO.CUSTOMERCAL A INNER JOIN PRO.ACCOUNTCAL  B ON A.RefCustomerID=B.RefCustomerID
WHERE A.FLGDEG='Y' AND B.DEGREASON IS NULL AND B.ASSET_NORM <>'ALWYS_STD' AND (ISNULL(A.FlgProcessing,'N')='N')

  UPDATE A SET DEGREASON=B.DEGREASON
  FROM PRO.ACCOUNTCAL A
INNER JOIN PRO.CUSTOMERCAL B
ON A.RefCustomerID=B.RefCustomerID
 WHERE A.DEGREASON='PERCOLATION BY OTHER ACCOUNT'

---------------------------------------------------------------------
--START OF MODIFICATION--HANDLING OF ACCOUNTS WITH FUTURE NPA DATE
---------------------------------------------------------------------


DECLARE @REF_DATE AS DATE = (SELECT Date FROM [dbo].Automate_Advances WHERE EXT_FLG='Y')
UPDATE PRO.CustomerCal SET SysNPA_Dt = @REF_DATE WHERE ISNULL(SysNPA_Dt,'1900-01-01') > @REF_DATE

UPDATE PRO.AccountCal SET FinalNpaDt = @REF_DATE WHERE ISNULL(FinalNpaDt,'1900-01-01') > @REF_DATE

UPDATE PRO.CustomerCal SET SysNPA_Dt = @REF_DATE WHERE SysNPA_Dt IS NULL AND SysAssetClassAlt_Key>1
UPDATE PRO.AccountCal SET FinalNpaDt = @REF_DATE WHERE FinalNpaDt IS NULL AND FinalAssetClassAlt_Key>1


/*------------------------------UPDATE UNIFORM ASSET CLASSIFICATION--------------------------------*/

 /* START PERCOLATION WORK -- 31082021 */
	


EXEC PRO.COBORROWER_DEG_UPG_MARKING @TIMEKEY,'I' /*CO-BORROWER DATA ISNERT*/
EXEC PRO.COBORROWER_DEG_UPG_MARKING @TIMEKEY,'D' /*CO-BORROWER DEGRADE MARKING*/



/* END OF PERCOLATION WORK */


	 UPDATE A SET 
	         A.FinalAssetClassAlt_Key=ISNULL(B.SysAssetClassAlt_Key,1)
		    ,A.FinalNpaDt=B.SysNPA_Dt
			FROM PRO.AccountCal A INNER   JOIN PRO.CustomerCal B 
			ON  A.RefCustomerID=B.RefCustomerID 
			--LEFT JOIN ExceptionFinalStatusType WO
			--	ON WO.EffectiveFromTimeKey<=@TIMEKEY AND WO.EffectiveToTimeKey>=@TIMEKEY
			--	AND WO.ACCOUNTENTITYID=A.AccountEntityID
			--	AND StatusType IN('TWO','WO')
			WHERE ISNULL(B.SysAssetClassAlt_Key,1)<>1 AND B.RefCustomerID<>'0'
                       -- AND  ISNULL(A.WriteOffAmount,0) = 0 
						--AND WO.ACCOUNTENTITYID IS NULL
	---------------------Added on 07062024 Ucic Level Percolation---------------------------

	UPDATE A SET 
	         A.FinalAssetClassAlt_Key=ISNULL(ABC.FinalAssetClassAlt_Key,1)
		    ,A.FinalNpaDt=ABC.FinalNpaDt
			from Pro.Accountcal A 
				INNER JOIN pro.CustomerCal B 
				ON A.RefCustomerID = B.RefCustomerID
				--LEFT JOIN	ExceptionFinalStatusType WO
				--ON		WO.EffectiveFromTimeKey<=@TIMEKEY AND WO.EffectiveToTimeKey>=@TIMEKEY
				--AND		WO.ACCOUNTENTITYID=A.AccountEntityID
				--AND		StatusType IN('TWO','WO')
				LEFT JOIN (select A.UcifEntityID,max(FinalAssetClassAlt_Key)FinalAssetClassAlt_Key
				,min(FinalNpaDt)FinalNpaDt
				from Pro.Accountcal A 
				INNER JOIN pro.CustomerCal B 
				ON A.RefCustomerID = B.RefCustomerID
				--LEFT JOIN	ExceptionFinalStatusType WO
				--ON		WO.EffectiveFromTimeKey<=@TIMEKEY AND WO.EffectiveToTimeKey>=@TIMEKEY
				--AND		WO.ACCOUNTENTITYID=A.AccountEntityID
				--AND		StatusType IN('TWO','WO')
				--WHERE	WO.AccountEntityId is NULL 
				group by A.UcifEntityID) ABC 
				ON A.UcifEntityID = ABC.UcifEntityID
				--WHERE	WO.AccountEntityId is NULL
		
	 
	 UPDATE A SET NPA_Reason=(B.DEGREASON + ISNULL(NPA_Reason,''))
	FROM PRO.AccountCal A 
	INNER JOIN PRO.CustomerCal B ON A.RefCustomerID =B.RefCustomerID
	WHERE (B.FlgProcessing='N')  AND (A.FLGDEG='N') AND B.DegReason IS NOT NULL AND A.FinalAssetClassAlt_Key>1 AND A.DegReason IS NULL

	
	---------------------------------To update Percolation NPA Reason 

	 

UPDATE B SET B.FinalNpaDt=A.SYSNPA_DT FROM PRO.CUSTOMERCAL A INNER JOIN PRO.ACCOUNTCAL B  ON A.RefCustomerID=B.RefCustomerID
WHERE ISNULL(B.ASSET_NORM,'NORMAL')<>'ALWYS_STD' AND (ISNULL(A.FlgProcessing,'N')='N') 
and  isnull(A.SysNPA_Dt,'')<>isnull(b.FinalNpaDt,'') 
AND ISNULL(A.FlgDeg,'N')='N'
AND A.RefCustomerID<>'0'

/*---------------UPDATE ASSET CLASS STD WHERE ASSET NORM ALWAYS STD---------------*/
update		Pro.ACCOUNTCAL
set			FinalNpaDt =FirstDtOfDisb,
            InitialNpaDt=case when InitialAssetClassAlt_Key >1 
			                  then FirstDtOfDisb else
							  InitialNpaDt end 
where	FinalNpaDt < FirstDtOfDisb 
and      isnull(FinalAssetClassAlt_Key,1) >1

select UCIFEntityid,min(FinalNpaDt) FinalNpaDt
into #NPADate
from Pro.ACCOUNTCAL  where FinalNpaDt is not NULL
group by UCIFEntityid


update		A
set			A.SysNPA_Dt  = B.FinalNpaDt
from		Pro.CustomerCAL A
INNER JOIN	#NPADate B 
ON			A.UcifEntityID = B.UcifEntityID
where		A.SysNPA_Dt<> B.FinalNpaDt




UPDATE A SET FinalAssetClassAlt_Key=1,FinalNpaDt=NULL, DEGREASON=NULL FROM PRO.AccountCal A WHERE A.ASSET_NORM ='ALWYS_STD'


	 ---UPDATE  MULTIPLE   DegReason IN PRO.CUSTOMERCAL TABLE-------

	 IF object_id('TEMPDB..#Data') is NOT NULL
     DROP TABLE #Data

	select distinct DegReason ,UcifEntityID  INTO #Data from PRO.AccountCal  WHERE DegReason IS NOT NULL AND FLGDEG='Y'



	--IF object_id('TEMPDB..#NPADegReason') is NOT NULL
	--DROP TABLE #NPADegReason
	--select UcifEntityID,STRING_AGG( DegReason,'')  DegReason 
	--into  #NPADegReason from #Data
	--group by UcifEntityID

	IF object_id('TEMPDB..#NPADegReason') is NOT NULL
	DROP TABLE #NPADegReason

		SELECT UcifEntityID,STUFF((SELECT ' ,' +DegReason  
				FROM #Data M1
		WHERE M2.UcifEntityID = M1.UcifEntityID
		FOR XML PATH('')),1,1,'')  AS DegReason
			into #NPADegReason
				FROM #Data M2
		GROUP BY UcifEntityID


	UPDATE A SET DegReason=B.DegReason  FROM PRO.CustomerCal A 
	INNER JOIN #NPADegReason B  ON A.UcifEntityID=B.UcifEntityID
	AND A.FlgDeg='Y'

	Update pro.CUSTOMERCAL set FlgUpg ='N' where SrcAssetClassAlt_Key =1 and SysAssetClassAlt_Key >1
	Update pro.CUSTOMERCAL set FlgDeg ='N' where SrcAssetClassAlt_Key >1 and SysAssetClassAlt_Key =1

	Update pro.AccountCal set FlgUpg ='N',UpgDate =null where InitialAssetClassAlt_Key  =1 and FinalAssetClassAlt_Key >1
	Update pro.AccountCal set FlgDeg ='N' where InitialAssetClassAlt_Key >1 and FinalAssetClassAlt_Key =1

		UPDATE A set DegReason='DEGRADE BY Overdue'
		from InvestmentFinancialDetail a
		where  A.EffectiveFromTimeKey <=@TIMEKEY AND A.EffectiveToTimeKey >=@TIMEKEY
		and FinalAssetClassAlt_Key>1
		and DegReason is null


		UPDATE A set DegReason='DEGRADE BY Overdue'
		from CurDat.DerivativeDetail a
		where  A.EffectiveFromTimeKey <=@TIMEKEY AND A.EffectiveToTimeKey >=@TIMEKEY
		and FinalAssetClassAlt_Key>1
		and DegReason is null


	UPDATE A SET A.DegReason= 'NPA DUE TO FRAUD MARKING'            
	FROM PRO.AccountCal A 
	where a.FlgFraud='Y' AND FinalAssetClassAlt_Key>1

	UPDATE A SET A.DegReason= 'NPA DUE TO RFA MARKING'            
	FROM PRO.AccountCal A 
	where a.RFA='Y' AND FinalAssetClassAlt_Key>1
	
	UPDATE A SET A.NPA_Reason= 'NPA DUE TO FRAUD MARKING'            
	FROM PRO.AccountCal A 
	where a.FlgFraud='Y' AND FinalAssetClassAlt_Key>1

	UPDATE A SET A.NPA_Reason= 'NPA DUE TO RFA MARKING'            
	FROM PRO.AccountCal A 
	where a.RFA='Y' AND FinalAssetClassAlt_Key>1

	
------update InvestmentFinancialDetail
------SET DBTDate = DATEADD(dd,365,NPIDt)
------where EffectiveFromTimeKey <= @Timekey and EffectiveToTimeKey >= @Timekey
------and DATEADD(dd,365,NPIDt) != DBTDate
	
------update curdat.DerivativeDetail
------SET DBTDate = DATEADD(dd,365,NPIDt)
------where EffectiveFromTimeKey <= @Timekey and EffectiveToTimeKey >= @Timekey
------and DATEADD(dd,365,NPIDt) != DBTDate

	IF @FlgPreErosion='N' -- WILL UPDATE COMPELTED FLAG WHEN THIS PROCESS WILL BE CALLED IN RELUGAR PROCESS - WHEN CALLING FROM [PRO].[Update_AssetClass] FLAG COMPLETED WILL BE REMAIN N
	BEGIN
		UPDATE PRO.ACLRUNNINGPROCESSSTATUS 
			SET COMPLETED='Y',ERRORDATE=NULL,ERRORDESCRIPTION=NULL,COUNT=ISNULL(COUNT,0)+1
			WHERE RUNNINGPROCESSNAME='Final_AssetClass_Npadate'
	END

   DROP TABLE #Data
   
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