SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

 

/*=========================================

AUTHER : TRILOKI KHANNA

alter DATE : 27-11-2019

MODIFY DATE : 27-11-2019

DESCRIPTION : UPDATE PROVISION ALT KEY AT ARCCOUNT LEVEL

EXEC [PRO].[UpdateProvisionKey_AccountWise]  @TimeKey=26959

==============================================*/

CREATE PROCEDURE [PRO].[UpdateProvisionKey_AccountWise]

@TimeKey INT

WITH RECOMPILE

AS

BEGIN

    SET NOCOUNT ON

BEGIN TRY

DECLARE @EXTDATE AS DATE

SELECT @EXTDATE  = DATE FROM SYSDAYMATRIX  WHERE TIMEKEY=@TimeKey

 

DECLARE @SubStandardInfrastructure INT =	(SELECT PROVISIONALT_KEY FROM DIMPROVISION_SEG WHERE SEGMENT='IRAC' AND PROVISIONNAME='Sub Standard Infrastructure'                                                                                          AND EFFECTIVEFROMTIMEKEY <=@TIMEKEY AND EFFECTIVETOTIMEKEY >=@TIMEKEY)
DECLARE @SubStandardAbinitioUnsecured INT = (SELECT PROVISIONALT_KEY FROM DIMPROVISION_SEG WHERE SEGMENT='IRAC' AND PROVISIONNAME='Sub Standard Ab initio Unsecured'                                                                  AND EFFECTIVEFROMTIMEKEY <=@TIMEKEY AND EFFECTIVETOTIMEKEY >=@TIMEKEY)
Declare @SUBSTDWillFullDft6TO12MONTH AS INT=(SELECT ProvisionAlt_Key FROM dimprovision_seg WHERE EffectiveFromTimeKey < = @TimeKey and EffectiveToTimeKey >= @TimeKey and ProvisionShortNameEnum = 'SUB_WillFULLDFT')
Declare @SUBSTDAbinitioWillFullDft6TO12MONTH AS INT=(SELECT ProvisionAlt_Key FROM dimprovision_seg WHERE EffectiveFromTimeKey < = @TimeKey and EffectiveToTimeKey >= @TimeKey and ProvisionShortNameEnum = 'SUB_AbinitioWillFULLDFT')
Declare @DB1WillFullDft AS INT=(SELECT ProvisionAlt_Key FROM dimprovision_seg WHERE EffectiveFromTimeKey < = @TimeKey and EffectiveToTimeKey >= @TimeKey and ProvisionShortNameEnum = 'DB1_WillFULLDFT')
Declare @DB2WillFullDft AS INT=(SELECT ProvisionAlt_Key FROM dimprovision_seg WHERE EffectiveFromTimeKey < = @TimeKey and EffectiveToTimeKey >= @TimeKey and ProvisionShortNameEnum = 'DB2_WillFULLDFT')

DECLARE @FINCAA smallint=(SELECT ProvisionAlt_Key FROM DimProvision_Seg WHERE ProvisionShortNameEnum='FINCAA' and EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey)
DECLARE @FIN890 smallint=(SELECT ProvisionAlt_Key FROM DimProvision_Seg WHERE ProvisionShortNameEnum='FIN890' and EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey)
DECLARE @FITL smallint=(SELECT ProvisionAlt_Key FROM DIMPROVISION_SEG WHERE ProvisionShortNameEnum='FITL' and EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey)


/* RESET PROVISION ALTKEY */
	UPDATE PRO.ACCOUNTCAL SET PROVISIONALT_KEY=0

/*ExceptionFinalStatusType CONTAINS MFI PARAMETER DETAILS*/
/* UPADTE PROVISION ALT KEY AS PER IRAC NORMS */
	UPDATE A SET A.ProvisionAlt_Key=P.ProvisionAlt_Key
	FROM PRO.ACCOUNTCAL A
		INNER JOIN DimAssetClass C ON C.AssetClassAlt_Key=isnull(A.FINALASSETCLASSALT_KEY,1)  
			AND (C.EffectiveFromTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey)
		INNER JOIN DIMPROVISION_SEG P
			ON (P.EffectiveFromTimeKey<=@TimeKey AND P.EffectiveToTimeKey>=@TimeKey)
			AND P.ProvisionShortNameEnum=C.AssetClassShortName
			AND P.Segment='IRAC'
	WHERE  C.ASSETCLASSGROUP='NPA'

	/*----------------PROVISION ALT KEY ALL NPA ACCOUNTS FOR EXCEPTIONS--------------------------------*/
	UPDATE A SET A.PROVISIONALT_KEY=@SubStandardAbinitioUnsecured
			 FROM PRO.ACCOUNTCAL A
	INNER JOIN DimAssetClass C ON C.AssetClassAlt_Key=isnull(A.FINALASSETCLASSALT_KEY,1)
		 AND (C.EffectiveFromTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey)
	WHERE  C.ASSETCLASSGROUP='NPA'
                AND C.AssetClassShortName  IN('SUB')
                AND A.FlgAbinitio='Y'

	/*PROVISION ALT KEY FOR FITL, FACILITY TYPE CAA &  ProductCode in ('OD890','OD896')*/
	UPDATE A SET A.PROVISIONALT_KEY=CASE WHEN FlgFITL='Y' THEN @FITL
										 WHEN SchemeType ='CAA' THEN  @FINCAA
										 WHEN A.ProductCode in ('OD890','OD896') THEN @FIN890
									END
			 FROM PRO.ACCOUNTCAL A
				INNER JOIN DimProduct P
					ON (P.EffectiveFromTimeKey<=@TimeKey AND P.EffectiveToTimeKey>=@TimeKey)
					AND P.ProductAlt_Key=A.ProductAlt_Key
					AND (P.SchemeType ='CAA' OR A.ProductCode in ('OD890','OD896') OR FlgFITL='Y')
			WHERE FinalAssetClassAlt_Key>1

	/* UPDATE PROVISION ALT KEY AS PER BANK'S PROVISION NORMS*/

	/*  PREPARE NPA_DAYS FROM NPA DATE */
	DROP TABLE IF EXISTS #AC_NPA_MONTH
	SELECT AccountEntityID,dbo.FullMonthsSeparation(@EXTDATE, FINALNPADT) NPA_MONTH
		INTO  #AC_NPA_MONTH
	FROM PRO.ACCOUNTCAL WHERE FinalAssetClassAlt_Key >1

	UPDATE A ----PROVISION POLICY Other than VISION PLUS, GAN SEVA, pt Smart */
		SET A.ProvisionAlt_Key=P.ProvisionAlt_Key
	FROM PRO.AccountCal A
            INNER JOIN DimAssetClass C ON C.AssetClassAlt_Key=isnull(A.FINALASSETCLASSALT_KEY,1)
                    AND (C.EffectiveFromTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey)
            inner JOIN DimProvision_Seg   P
				on (P.EffectiveFromTimeKey<=@TimeKey AND P.EffectiveToTimeKey>=@TimeKey)
                    AND P.ProvisionShortNameEnum=C.AssetClassShortName
					AND P.Segment='BANK' AND ProvisionName='ALL SOOURCE'
            INNER JOIN #AC_NPA_MONTH NP
                    ON NP.AccountEntityID=A.AccountEntityID
                    AND NP.NPA_MONTH  BETWEEN P.LowerDPD AND   P.UpperDPD
			INNER JOIN DimProduct DP ON DP.ProductAlt_Key=A.ProductAlt_Key
					AND DP.BankProvPolicyApply='Y'
					AND DP.EffectiveFromTimeKey<=@TimeKey AND DP.EffectiveToTimeKey>=@TimeKey
            INNER JOIN DIMSOURCEDB SRC
					ON SRC.EffectiveFromTimeKey<=@TimeKey AND SRC.EffectiveToTimeKey>=@TimeKey
					AND SRC.SourceAlt_Key=A.SourceAlt_Key
					AND ISNULL(SRC.SourceShortNameEnum,'') NOT IN('VISION PLUS','Gan Seva','PT Smart')
			WHERE  C.AssetClassGroup='NPA' 

	UPDATE A ----PROVISION POLICY FOR VISION PLUS, GAN SEVA, pt Smart */
		SET A.ProvisionAlt_Key=P.ProvisionAlt_Key
	FROM PRO.AccountCal A
            INNER JOIN DimAssetClass C ON C.AssetClassAlt_Key=isnull(A.FINALASSETCLASSALT_KEY,1)
                    AND (C.EffectiveFromTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey)
            inner JOIN DimProvision_Seg   P
				on (P.EffectiveFromTimeKey<=@TimeKey AND P.EffectiveToTimeKey>=@TimeKey)
                    AND P.ProvisionShortNameEnum=C.AssetClassShortName
					AND P.Segment='BANK' AND ProvisionName in ('VISION PLUS','Ganaseva','PT Smart')
            INNER JOIN #AC_NPA_MONTH NP
                    ON NP.AccountEntityID=A.AccountEntityID
                    AND NP.NPA_MONTH  BETWEEN P.LowerDPD AND   P.UpperDPD
            INNER JOIN DIMSOURCEDB SRC
					ON SRC.EffectiveFromTimeKey<=@TimeKey AND SRC.EffectiveToTimeKey>=@TimeKey
					AND SRC.SourceAlt_Key=A.SourceAlt_Key
					AND SRC.SourceShortNameEnum=P.ProvisionName
					AND ISNULL(SRC.SourceShortNameEnum,'') IN ('VISION PLUS','Gan Seva','PT Smart')
			WHERE  C.AssetClassGroup='NPA' 



	----/*---WillfulDefault update provision alt_key in account cal table ---------------------*/
		update a set a.ProvisionAlt_Key= (case when  isnull(A.FlgAbinitio,'N')='Y' then @SUBSTDAbinitioWillFullDft6TO12MONTH
                                      else  @SUBSTDWillFullDft6TO12MONTH end)
				from PRO.ACCOUNTCAL A
		INNER JOIN ExceptionFinalStatusType B ON B.CustomerID=A.RefCustomerID
		inner join DimAssetClass c on c.AssetClassAlt_Key=a.FinalAssetClassAlt_Key
					and c.EffectiveFromTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey
		where C.AssetClassShortName='SUB' AND isnull(A.FlgFITL,'N')<>'Y'
			and FinalNpaDt between dateadd(month,-12,@EXTDATE) and dateadd(month,-6,@EXTDATE)  and B.StatusType='Wilful Default'


		----/*--------WillfulDefault update provision alt_key in account cal table--------------------------*/
		update a set a.ProvisionAlt_Key=@DB1WillFullDft
		from PRO.ACCOUNTCAL A
		INNER JOIN ExceptionFinalStatusType B ON B.CustomerID=A.RefCustomerID
		inner join DimAssetClass c on c.AssetClassAlt_Key=a.FinalAssetClassAlt_Key
		   and c.EffectiveFromTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey
		where C.AssetClassShortName='DB1' AND isnull(A.FlgFITL,'N')<>'Y' and   B.StatusType='Wilful Default'
 
		----/*-------WillfulDefault update provision alt_key in account cal table--------------------------*/
		UPDATE A SET A.PROVISIONALT_KEY=@DB2WILLFULLDFT
		FROM PRO.ACCOUNTCAL A
		INNER JOIN ExceptionFinalStatusType B ON B.CustomerID=A.RefCustomerID
		inner join DimAssetClass c on c.AssetClassAlt_Key=a.FinalAssetClassAlt_Key
		   and c.EffectiveFromTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey
		where C.AssetClassShortName='DB2' AND isnull(A.FlgFITL,'N')<>'Y' and  B.StatusType='Wilful Default'

/* UPDATE PROVISION ALT KEY FOR STD ACCOUNTS*/

	UPDATE A SET A.ProvisionAlt_Key=C.ProvisionAlt_Key
	FROM PRO.ACCOUNTCAL A
	INNER JOIN DimProduct B ON A.ProductAlt_Key = B.ProductAlt_Key
	AND B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
	INNER JOIN DimProvision_SegStd C ON ISNULL(B.STDProvCATCode,113) = C.BankCategoryID
	and C.EffectiveFromTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey
	--AND (B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey)
	WHERE  A.FinalAssetClassAlt_Key = 1


	UPDATE PRO.ACLRUNNINGPROCESSSTATUS
	SET COMPLETED='Y',ERRORDATE=NULL,ERRORDESCRIPTION=NULL,COUNT=ISNULL(COUNT,0)+1
	WHERE RUNNINGPROCESSNAME='UpdateProvisionKey_AccountWise'

	-----------------Added for DashBoard 04-03-2021
		--Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='ASSET CLASSIFICATION'

 

END TRY

BEGIN  CATCH

               

UPDATE PRO.ACLRUNNINGPROCESSSTATUS

SET COMPLETED='N',ERRORDATE=GETDATE(),ERRORDESCRIPTION=ERROR_MESSAGE(),COUNT=ISNULL(COUNT,0)+1

WHERE RUNNINGPROCESSNAME='UpdateProvisionKey_AccountWise'

 

END CATCH

   SET NOCOUNT OFF

END

 

 

 

GO