﻿SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/*=====================================
AUTHER : TRILOKI KHANNA
CREATE DATE : 27-11-2019
MODIFY DATE : 27-11-2019
DESCRIPTION :Govt Guar Appropriation
EXEC pro.GovtGuarAppropriation   @TIMEKEY=25140
====================================*/
CREATE PROCEDURE [PRO].[GovtGuarAppropriation]
@TimeKey INT
with recompile
AS
BEGIN
SET NOCOUNT ON
BEGIN TRY
  
/*-----UPDATE AppGovGur =0 --------------------------*/
UPDATE  A SET A.AppGovGur =0 FROM PRO.ACCOUNTCAL A INNER JOIN PRO.CustomerCal B
ON A.CustomerEntityID=B.CustomerEntityID
WHERE B.FlgProcessing='N'
	

IF OBJECT_ID('TEMPDB..#TEMPTABLEAppGovGur') IS NOT NULL
  DROP TABLE #TEMPTABLEAppGovGur


SELECT A.AccountEntityID,(CASE WHEN SUM(A.NetBalance) OVER (PARTITION BY A.CustomerEntityId) > 0 
	               THEN  (A.GovtGtyAmt * (A.NetBalance / SUM(A.NetBalance) OVER (PARTITION BY A.CustomerEntityId)))
				 END) GovGur INTO #TEMPTABLEAppGovGur
FROM PRO.AccountCal  A
WHERE A.FacilityType IN('BP','BD')  AND  ISNULL(A.GovtGtyAmt,0) > 0



UPDATE A SET A.AppGovGur=B.GovGur
FROM PRO.ACCOUNTCAL A INNER JOIN #TEMPTABLEAppGovGur B ON A.AccountEntityID=B.AccountEntityID
WHERE  A.FacilityType IN('BP','BD')


UPDATE A SET A.AppGovGur=GovtGtyAmt
FROM PRO.ACCOUNTCAL A 
WHERE  NOT (A.FacilityType IN('BP','BD'))
	  
UPDATE PRO.ACLRUNNINGPROCESSSTATUS 
	SET COMPLETED='Y',ERRORDATE=NULL,ERRORDESCRIPTION=NULL,COUNT=ISNULL(COUNT,0)+1
	WHERE RUNNINGPROCESSNAME='GovtGuarAppropriation'

	DROP TABLE #TEMPTABLEAppGovGur

	-----------------Added for DashBoard 04-03-2021
--Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='ASSET CLASSIFICATION'

END TRY
BEGIN  CATCH

	UPDATE PRO.ACLRUNNINGPROCESSSTATUS 
	SET COMPLETED='N',ERRORDATE=GETDATE(),ERRORDESCRIPTION=ERROR_MESSAGE(),COUNT=ISNULL(COUNT,0)+1
	WHERE RUNNINGPROCESSNAME='GovtGuarAppropriation'
END CATCH	

SET NOCOUNT OFF
			  
END         










GO