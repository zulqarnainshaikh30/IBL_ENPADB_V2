SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


----/*=========================================
---- AUTHER : TRILOKI KHANNA
---- CREATE DATE : 27-11-2019
---- MODIFY DATE : 27-11-2019
---- DESCRIPTION : UPDATE InvestmentDataProcessing
-----EXEC [PRO].[InvestmentDataProcessing] @TIMEKEY=26520
----=============================================*/


CREATE PROCEDURE [PRO].[InvestmentDataProcessing]
@TIMEKEY INT
WITH RECOMPILE
/*=========================================
-- AUTHOR : TRILOKI KHANNA
-- CREATE DATE : 09-04-2021
-- MODIFY DATE : 07-04-2022
-- DESCRIPTION : Test Case Cover in This SP
-----EXEC [PRO].[InvestmentDataProcessing] @TIMEKEY=26298
--=============================================*/
AS
BEGIN
  SET NOCOUNT ON
   BEGIN TRY
--DECLARE @TIMEKEY INT=26267
   

DECLARE @PROCESSDATE DATE =(SELECT DATE FROM SysDayMatrix WHERE TimeKey=@TIMEKEY)
DECLARE @SUB_Days INT =(SELECT RefValue FROM PRO.refperiod WHERE BusinessRule='SUB_Days' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
DECLARE @DB1_Days INT =(SELECT RefValue FROM PRO.refperiod WHERE BusinessRule='DB1_Days' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
DECLARE @DB2_Days INT =(SELECT RefValue FROM PRO.refperiod WHERE BusinessRule='DB2_Days' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
DECLARE @MoveToDB1 DECIMAL(5,2) =(SELECT cast(RefValue/100.00 as decimal(5,2))FROM PRO.refperiod where BusinessRule='MoveToDB1' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
DECLARE @MoveToLoss DECIMAL(5,2)=(SELECT cast(RefValue/100.00 as decimal(5,2)) FROM PRO.refperiod where BusinessRule='MoveToLoss' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
DECLARE @SubStandard INT =	(SELECT PROVISIONALT_KEY FROM DIMPROVISION_SEG WHERE segment='IRAC' and PROVISIONNAME='Sub Standard'									    AND EFFECTIVEFROMTIMEKEY <=@TIMEKEY AND EFFECTIVETOTIMEKEY >=@TIMEKEY)
DECLARE @DoubtfulI INT =	(SELECT PROVISIONALT_KEY FROM DIMPROVISION_SEG WHERE segment='IRAC' and PROVISIONNAME='Doubtful-I'										    AND EFFECTIVEFROMTIMEKEY <=@TIMEKEY AND EFFECTIVETOTIMEKEY >=@TIMEKEY)
DECLARE @DoubtfulII INT =	(SELECT PROVISIONALT_KEY FROM DIMPROVISION_SEG WHERE segment='IRAC' and PROVISIONNAME='Doubtful-II'										AND EFFECTIVEFROMTIMEKEY <=@TIMEKEY AND EFFECTIVETOTIMEKEY >=@TIMEKEY)
DECLARE @DoubtfulIII INT =	(SELECT PROVISIONALT_KEY FROM DIMPROVISION_SEG WHERE segment='IRAC' and  PROVISIONNAME='Doubtful-III'									    AND EFFECTIVEFROMTIMEKEY <=@TIMEKEY AND EFFECTIVETOTIMEKEY >=@TIMEKEY)
DECLARE @Loss INT =			(SELECT PROVISIONALT_KEY FROM DIMPROVISION_SEG WHERE segment='IRAC' and PROVISIONNAME='Loss'											    AND EFFECTIVEFROMTIMEKEY <=@TIMEKEY AND EFFECTIVETOTIMEKEY >=@TIMEKEY)

DECLARE @RefPeriodOverdueInvestment INT =	(SELECT TOP 1 REFVALUE FROM PRO.refperiod where BusinessRule='RefPeriodOverdueInvestment' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)

DECLARE @SMA0LowerValue INT =	(SELECT TOP 1 DPD_LowerValue FROM  DimSMAClassMaster where SrcSysClassCode='SMA0' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
DECLARE @SMA0HigherValue INT =	(SELECT TOP 1 DPD_HigherValue FROM DimSMAClassMaster where SrcSysClassCode='SMA0' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
DECLARE @SMA1LowerValue INT =	(SELECT TOP 1 DPD_LowerValue FROM DimSMAClassMaster where SrcSysClassCode='SMA1' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
DECLARE @SMA1HigherValue INT =	(SELECT TOP 1 DPD_HigherValue FROM DimSMAClassMaster where SrcSysClassCode='SMA1' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
DECLARE @SMA2LowerValue INT =	(SELECT TOP 1 DPD_LowerValue FROM DimSMAClassMaster where SrcSysClassCode='SMA2' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
DECLARE @SMA2HigherValue INT =	(SELECT TOP 1 DPD_HigherValue FROM DimSMAClassMaster where SrcSysClassCode='SMA2' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)


UPDATE InvestmentFinancialDetail SET DPD=0 WHERE EffectiveFromTimeKey<=@timekey AND EffectiveToTimeKey>=@timekey
AND ISNULL(DPD,0)=0


UPDATE A SET
	Asset_Norm='NORMAL'
FROM InvestmentFinancialDetail A 
	WHERE EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY
	AND ISNULL(Asset_Norm,'') not in ('ALWYS_STD','ALWYS_NPA')

UPDATE A SET DPD_DivOverdue=0,DPD_Maturity=0,DPD=0, FLGDEG='N', FLGUPG='N', UPGDATE=NULL
		,PartialRedumptionDPD=0
FROM CURDAT.InvestmentFinancialDetail A
WHERE A.EffectiveFromTimeKey<=@timekey AND A.EffectiveToTimeKey>=@timekey

/*UPDATE PREVISOU DAY STATUS AS INITIAL STATUS FOR CURRENT DAY */
UPDATE A SET 
		InitialAssetAlt_Key=B.FinalAssetClassAlt_Key
		,InitialNPIDt =B.NPIDt
		,A.NPIDt =B.NPIDt
		,DBTDate =B.DBTDate
		,FinalAssetClassAlt_Key=B.FinalAssetClassAlt_Key
FROM CURDAT.InvestmentFinancialDetail A
	INNER JOIN InvestmentFinancialDetail B
		ON A.RefIssuerID =B.RefIssuerID
		AND A.EffectiveFromTimeKey<=@timekey AND A.EffectiveToTimeKey>=@timekey
		AND B.EffectiveFromTimeKey<=@timekey-1 AND B.EffectiveToTimeKey>=@timekey-1


		
		update A set AssetClass_AltKey = 1 
		 FROM CURDAT.InvestmentFinancialDetail A
		 where AssetClass_AltKey IS NULL
		 and A.EffectiveFromTimeKey<=@timekey AND A.EffectiveToTimeKey>=@timekey

		update A set InitialAssetAlt_Key = 1 
		 FROM CURDAT.InvestmentFinancialDetail A
		 where InitialAssetAlt_Key IS NULL
		 and A.EffectiveFromTimeKey<=@timekey AND A.EffectiveToTimeKey>=@timekey

		update A set FinalAssetClassAlt_Key = 1 
		 FROM CURDAT.InvestmentFinancialDetail A
		 where FinalAssetClassAlt_Key IS NULL
		 and A.EffectiveFromTimeKey<=@timekey AND A.EffectiveToTimeKey>=@timekey



UPDATE B SET DPD_DivOverdue=(CASE WHEN  B.Interest_DividendDueDate IS NOT NULL   
      THEN   DATEDIFF(DAY,B.Interest_DividendDueDate,@PROCESSDATE) +1      ELSE 0 END)

FROM InvestmentBasicDetail A
inner join InvestmentIssuerDetail C ON A.IssuerEntityId=C.IssuerEntityId
AND C.EffectiveFromTimeKey <=@timekey AND C.EffectiveToTimeKey>=@timekey
inner join InvestmentFinancialDetail B on A.InvEntityId=B.InvEntityId
AND A.EffectiveFromTimeKey<=@timekey AND A.EffectiveToTimeKey>=@timekey
AND B.EffectiveFromTimeKey<=@timekey AND B.EffectiveToTimeKey>=@timekey
WHERE B.Interest_DividendDueDate IS NOT NULL


UPDATE B SET DPD_Maturity=(CASE WHEN  a.MaturityDt IS NOT NULL   
      THEN   DATEDIFF(DAY,a.MaturityDt,@PROCESSDATE) +1      ELSE 0 END)

FROM InvestmentBasicDetail A
inner join InvestmentIssuerDetail C ON A.IssuerEntityId=C.IssuerEntityId
AND C.EffectiveFromTimeKey <=@timekey AND C.EffectiveToTimeKey>=@timekey
inner join InvestmentFinancialDetail B on A.InvEntityId=B.InvEntityId
AND A.EffectiveFromTimeKey<=@timekey AND A.EffectiveToTimeKey>=@timekey
AND B.EffectiveFromTimeKey<=@timekey AND B.EffectiveToTimeKey>=@timekey
WHERE a.MaturityDt IS NOT  NULL 



UPDATE B SET PartialRedumptionDPD=(CASE WHEN  b.PartialRedumptionDueDate IS NOT NULL   
      THEN   DATEDIFF(DAY,B.PartialRedumptionDueDate,@PROCESSDATE)+1 ELSE 0 END)
FROM InvestmentBasicDetail A
	INNER JOIN InvestmentIssuerDetail C 
		ON A.IssuerEntityId=C.IssuerEntityId
		AND C.EffectiveFromTimeKey <=@timekey AND C.EffectiveToTimeKey>=@timekey
	INNER JOIN InvestmentFinancialDetail B 
		ON A.InvEntityId=B.InvEntityId
		AND A.EffectiveFromTimeKey<=@timekey AND A.EffectiveToTimeKey>=@timekey
		AND B.EffectiveFromTimeKey<=@timekey AND B.EffectiveToTimeKey>=@timekey
	WHERE b.PartialRedumptionDueDate IS NOT NULL 
	

UPDATE InvestmentFinancialDetail SET DegReason = NULL,DPD_DivOverdue=0 WHERE DPD_DivOverdue<0 AND EffectiveFromTimeKey <=@timekey AND EffectiveToTimeKey>=@timekey
UPDATE InvestmentFinancialDetail SET DPD_Maturity=0 WHERE DPD_Maturity<0 AND EffectiveFromTimeKey <=@timekey AND EffectiveToTimeKey>=@timekey
UPDATE InvestmentFinancialDetail SET PartialRedumptionDPD=0 WHERE PartialRedumptionDPD<0 AND EffectiveFromTimeKey <=@timekey AND EffectiveToTimeKey>=@timekey
UPDATE InvestmentFinancialDetail SET DPD=0 WHERE DPD<0 AND EffectiveFromTimeKey <=@timekey AND EffectiveToTimeKey>=@timekey


UPDATE B SET DPD=CASE WHEN ISNULL(DPD_DivOverdue,0)>=ISNULL(DPD_Maturity,0) and ISNULL(DPD_DivOverdue,0)>=ISNULL(PartialRedumptionDPD,0)
							THEN ISNULL(DPD_DivOverdue,0)
					  WHEN ISNULL(DPD_Maturity,0)>=ISNULL(DPD_DivOverdue,0) and ISNULL(DPD_Maturity,0)>=ISNULL(PartialRedumptionDPD,0)
							THEN ISNULL(DPD_Maturity,0)
						ELSE ISNULL(PartialRedumptionDPD,0) 
					END
FROM InvestmentBasicDetail A
inner join InvestmentIssuerDetail C ON A.IssuerEntityId=C.IssuerEntityId
AND C.EffectiveFromTimeKey <=@timekey AND C.EffectiveToTimeKey>=@timekey
inner join InvestmentFinancialDetail B on A.InvEntityId=B.InvEntityId
AND A.EffectiveFromTimeKey<=@timekey AND A.EffectiveToTimeKey>=@timekey
AND B.EffectiveFromTimeKey<=@timekey AND B.EffectiveToTimeKey>=@timekey


UPDATE B SET B.DPD=CASE WHEN ISNULL(DPD,0)<0 THEN 0 ELSE ISNULL(DPD,0) END
		,B.DPD_MATURITY=CASE WHEN ISNULL(DPD_MATURITY,0)<0 THEN 0 ELSE ISNULL(DPD_MATURITY,0) END
		,B.DPD_DivOverdue=CASE WHEN ISNULL(DPD_DivOverdue,0)<0 THEN 0 ELSE ISNULL(DPD_DivOverdue,0) END
FROM InvestmentBasicDetail A
inner join InvestmentIssuerDetail C ON A.IssuerEntityId=C.IssuerEntityId
AND C.EffectiveFromTimeKey <=@timekey AND C.EffectiveToTimeKey>=@timekey
inner join InvestmentFinancialDetail B on A.InvEntityId=B.InvEntityId
AND A.EffectiveFromTimeKey<=@timekey AND A.EffectiveToTimeKey>=@timekey
AND B.EffectiveFromTimeKey<=@timekey AND B.EffectiveToTimeKey>=@timekey
where ISNULL(DPD,0)<0 OR ISNULL(DPD_MATURITY,0)<0 OR ISNULL(DPD_DivOverdue,0)<0


UPDATE B SET FLGDEG ='Y'
FROM InvestmentBasicDetail A
inner join InvestmentIssuerDetail C ON A.IssuerEntityId=C.IssuerEntityId
AND C.EffectiveFromTimeKey <=@timekey AND C.EffectiveToTimeKey>=@timekey
inner join InvestmentFinancialDetail B on A.InvEntityId=B.InvEntityId
AND A.EffectiveFromTimeKey<=@timekey AND A.EffectiveToTimeKey>=@timekey
AND B.EffectiveFromTimeKey<=@timekey AND B.EffectiveToTimeKey>=@timekey
where DPD>=@RefPeriodOverdueInvestment AND Asset_Norm='NORMAL' AND FinalAssetClassAlt_Key =1
and A.InstrName not IN('Bond','BondMMDiscount')--@RefPeriodOverdueInvestment

-------------------------------First Time Deg Reason---

UPDATE B SET B.DEGREASON= 'DEGRADE BY Interest_DividendDueDate' 
FROM InvestmentBasicDetail A
inner join InvestmentIssuerDetail C ON A.IssuerEntityId=C.IssuerEntityId
AND C.EffectiveFromTimeKey <=@timekey AND C.EffectiveToTimeKey>=@timekey
inner join InvestmentFinancialDetail B on A.InvEntityId=B.InvEntityId
AND A.EffectiveFromTimeKey<=@timekey AND A.EffectiveToTimeKey>=@timekey
AND B.EffectiveFromTimeKey<=@timekey AND B.EffectiveToTimeKey>=@timekey
where B.Interest_DividendDueDate IS NOT NULL AND isnull(B.FinalAssetClassAlt_Key,1)=1
AND DPD_DivOverdue>=@RefPeriodOverdueInvestment AND FLGDEG ='Y'   --@RefPeriodOverdueInvestment
and A.InstrName not  IN('Bond','BondMMDiscount')

UPDATE B SET B.DEGREASON=ISNULL(DEGREASON,'')+','+'DEGRADE BY Maturity Date'
FROM InvestmentBasicDetail A
inner join InvestmentIssuerDetail C ON A.IssuerEntityId=C.IssuerEntityId
AND C.EffectiveFromTimeKey <=@timekey AND C.EffectiveToTimeKey>=@timekey
inner join InvestmentFinancialDetail B on A.InvEntityId=B.InvEntityId
AND A.EffectiveFromTimeKey<=@timekey AND A.EffectiveToTimeKey>=@timekey
AND B.EffectiveFromTimeKey<=@timekey AND B.EffectiveToTimeKey>=@timekey
where A.MaturityDt IS NOT NULL AND isnull(B.FinalAssetClassAlt_Key,1)=1
AND ISNULL(DPD_Maturity,0)>=@RefPeriodOverdueInvestment AND FLGDEG ='Y'--@RefPeriodOverdueInvestment
and A.InstrName not  IN('Bond','BondMMDiscount')

UPDATE B SET B.DEGREASON=ISNULL(DEGREASON,'')+','+'DEGRADE BY Partial Redumption Due Date'
FROM InvestmentBasicDetail A
inner join InvestmentIssuerDetail C ON A.IssuerEntityId=C.IssuerEntityId
AND C.EffectiveFromTimeKey <=@timekey AND C.EffectiveToTimeKey>=@timekey
inner join InvestmentFinancialDetail B on A.InvEntityId=B.InvEntityId
AND A.EffectiveFromTimeKey<=@timekey AND A.EffectiveToTimeKey>=@timekey
AND B.EffectiveFromTimeKey<=@timekey AND B.EffectiveToTimeKey>=@timekey
where B.PartialRedumptionDueDate IS NOT NULL AND isnull(B.FinalAssetClassAlt_Key,1)=1
AND ISNULL(PartialRedumptionDPD,0)>=@RefPeriodOverdueInvestment AND FLGDEG ='Y' --@RefPeriodOverdueInvestment
and A.InstrName not  IN('Bond','BondMMDiscount')

---------------------------Laster Stages Degreason---------------


UPDATE B SET B.DEGREASON= 'DEGRADE BY Interest_DividendDueDate' 
FROM InvestmentBasicDetail A
inner join InvestmentIssuerDetail C ON A.IssuerEntityId=C.IssuerEntityId
AND C.EffectiveFromTimeKey <=@timekey AND C.EffectiveToTimeKey>=@timekey
inner join InvestmentFinancialDetail B on A.InvEntityId=B.InvEntityId
AND A.EffectiveFromTimeKey<=@timekey AND A.EffectiveToTimeKey>=@timekey
AND B.EffectiveFromTimeKey<=@timekey AND B.EffectiveToTimeKey>=@timekey
where B.Interest_DividendDueDate IS NOT NULL AND isnull(B.FinalAssetClassAlt_Key,1)>1
AND DPD_DivOverdue>0 
and A.InstrName not  IN('Bond','BondMMDiscount')

UPDATE B SET B.DEGREASON=ISNULL(DEGREASON,'')+','+'DEGRADE BY Maturity Date'
FROM InvestmentBasicDetail A
inner join InvestmentIssuerDetail C ON A.IssuerEntityId=C.IssuerEntityId
AND C.EffectiveFromTimeKey <=@timekey AND C.EffectiveToTimeKey>=@timekey
inner join InvestmentFinancialDetail B on A.InvEntityId=B.InvEntityId
AND A.EffectiveFromTimeKey<=@timekey AND A.EffectiveToTimeKey>=@timekey
AND B.EffectiveFromTimeKey<=@timekey AND B.EffectiveToTimeKey>=@timekey
where A.MaturityDt IS NOT NULL AND isnull(B.FinalAssetClassAlt_Key,1)>1
AND ISNULL(DPD_Maturity,0)>0 
and A.InstrName not  IN('Bond','BondMMDiscount')

UPDATE B SET B.DEGREASON=ISNULL(DEGREASON,'')+','+'DEGRADE BY Partial Redumption Due Date'
FROM InvestmentBasicDetail A
inner join InvestmentIssuerDetail C ON A.IssuerEntityId=C.IssuerEntityId
AND C.EffectiveFromTimeKey <=@timekey AND C.EffectiveToTimeKey>=@timekey
inner join InvestmentFinancialDetail B on A.InvEntityId=B.InvEntityId
AND A.EffectiveFromTimeKey<=@timekey AND A.EffectiveToTimeKey>=@timekey
AND B.EffectiveFromTimeKey<=@timekey AND B.EffectiveToTimeKey>=@timekey
where B.PartialRedumptionDueDate IS NOT NULL AND isnull(B.FinalAssetClassAlt_Key,1)>1
AND ISNULL(PartialRedumptionDPD,0)>0 
and A.InstrName not  IN('Bond','BondMMDiscount')


/*------------Calculate NpaDt -------------------------------------*/

UPDATE  A  SET NPIDt= @ProcessDate
FROM InvestmentFinancialDetail A 
WHERE ISNULL(A.FLGDEG,'N')='Y'
and A.EffectiveFromTimeKey<=@timekey and A.EffectiveToTimeKey>=@timekey
and A.DEGREASON= 'DEGRADE BY MTMValue Less Than 1 Rs.' 

UPDATE  A  SET NPIDt= DATEADD(DAY,ISNULL(@RefPeriodOverdueInvestment,0),DATEADD(DAY,-ISNULL(DPD,0),@ProcessDate)) --@RefPeriodOverdueInvestment
FROM InvestmentFinancialDetail  A 
WHERE ISNULL(A.FLGDEG,'N')='Y'
and A.EffectiveFromTimeKey<=@timekey and A.EffectiveToTimeKey>=@timekey


UPDATE A SET A.FinalAssetClassAlt_Key= ( CASE  WHEN  DATEADD(DAY,@SUB_Days,A.NPIDt)>@ProcessDate   THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='SUB' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
										  WHEN  DATEADD(DAY,@SUB_Days,A.NPIDt)<=@ProcessDate AND  DATEADD(DAY,@SUB_Days+@DB1_Days,A.NPIDt)>@ProcessDate   THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='DB1' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
									      WHEN  DATEADD(DAY,@SUB_Days+@DB1_Days,A.NPIDt)<=@ProcessDate AND  DATEADD(DAY,@SUB_Days+@DB1_Days+@DB2_Days,A.NPIDt)>@ProcessDate THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='DB2' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
									       WHEN  DATEADD(DAY,(@DB1_Days+@SUB_Days+@DB2_Days),A.NPIDt)<=@ProcessDate  THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='DB3' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
									   END)
         
FROM  InvestmentFinancialDetail A   
WHERE ISNULL(A.FlgDeg,'N')='Y'  
AND  A.EffectiveFromTimeKey<=@timekey and A.EffectiveToTimeKey>=@timekey


UPDATE B SET
	Asset_Norm='ALWYS_STD',AssetClass_AltKey=1,FinalAssetClassAlt_Key=1,NPIDt=NULL,DEGREASON=NULL,FLGDEG=NULL
FROM InvestmentBasicDetail A
inner join InvestmentIssuerDetail C ON A.IssuerEntityId=C.IssuerEntityId
AND C.EffectiveFromTimeKey <=@timekey AND C.EffectiveToTimeKey>=@timekey
inner join InvestmentFinancialDetail B on A.InvEntityId=B.InvEntityId
AND A.EffectiveFromTimeKey<=@timekey AND A.EffectiveToTimeKey>=@timekey
AND B.EffectiveFromTimeKey<=@timekey AND B.EffectiveToTimeKey>=@timekey
and A.InstrName IN('Bond','BondMMDiscount')



	IF OBJECT_ID('TEMPDB..#TEMPMINASSETCLASS') IS NOT NULL
	  DROP TABLE #TEMPMINASSETCLASS
  	
	SELECT UcifId,MAX(ISNULL(FinalAssetClassAlt_Key,1)) FinalAssetClassAlt_Key
	,MIN(NPIDt) NPIDt 
	 INTO #TEMPMINASSETCLASS 
	 FROM  InvestmentFinancialDetail A
		INNER JOIN InvestmentBasicDetail B
			ON A.INVENTITYID=B.INVENTITYID
			AND B.EffectiveFromTimeKey<=@TimeKey and B.EffectiveToTimeKey>=@TimeKey
		inner join InvestmentIssuerDetail C ON B.IssuerEntityId=C.IssuerEntityId
			AND B.EffectiveFromTimeKey<=@TimeKey and B.EffectiveToTimeKey>=@TimeKey
	  WHERE  ISNULL(FinalAssetClassAlt_Key,1)>1
	  AND  A.EFFECTIVEFROMTIMEKEY<=@TimeKey AND A.EFFECTIVETOTIMEKEY>=@TimeKey
	  GROUP BY UcifId

	  IF OBJECT_ID('TEMPDB..#InvestmentFinancialDetail') IS NOT NULL
	  DROP TABLE #InvestmentFinancialDetail

	   select UCIFID,A.RefIssuerID,A.RefInvID,FinalAssetClassAlt_Key,InitialAssetAlt_Key,
	   InitialNPIDt,NPIDt,A.EffectiveFromTimeKey,A.EffectiveToTimeKey
	   into #InvestmentFinancialDetail
	   fROM  InvestmentFinancialDetail A
		INNER JOIN InvestmentBasicDetail B
		ON A.INVENTITYID=B.INVENTITYID
		AND B.EffectiveFromTimeKey<=@TimeKey and B.EffectiveToTimeKey>=@TimeKey
		inner join InvestmentIssuerDetail C ON B.IssuerEntityId=C.IssuerEntityId
		AND B.EffectiveFromTimeKey<=@TimeKey and B.EffectiveToTimeKey>=@TimeKey
		AND  ISNULL(A.FinalAssetClassAlt_Key,1)>1  

		  IF OBJECT_ID('TEMPDB..#TEMPMINASSETCLASSReason') IS NOT NULL
	  DROP TABLE #TEMPMINASSETCLASSReason
	  select distinct UCIFID,STUFF((SELECT  distinct  ', ' + B.RefInvID  
										from #InvestmentFinancialDetail B 
										WHERE B.UCIFID = A.UCIFID  
										and EffectiveFromTimeKey <= @timekey and EffectiveToTimeKey >= @timekey
										AND  ISNULL(B.FinalAssetClassAlt_Key,1)>1
										FOR XML PATH('')),1,1,'') RefInvID
	INTO #TEMPMINASSETCLASSReason
	FROM  #InvestmentFinancialDetail A
   GROUP BY UCIFID

	--- SELECT * FROM #TEMPMINASSETCLASS  
	 -- UPDATE D SET FinalAssetClassAlt_Key=A.FinalAssetClassAlt_Key,NPIDt=A.NPIDt
		--FROM #TEMPMINASSETCLASS  A
		--inner join InvestmentIssuerDetail B ON A.UcifId=B.UcifId
		--	AND B.EffectiveFromTimeKey<=@TimeKey and B.EffectiveToTimeKey>=@TimeKey
		--INNER JOIN InvestmentBasicDetail C
		--	ON B.IssuerEntityId=C.IssuerEntityId
		--	AND C.EffectiveFromTimeKey<=@TimeKey and C.EffectiveToTimeKey>=@TimeKey
	 -- INNER JOIN InvestmentFinancialDetail  D
		--	ON C.InvEntityId=D.InvEntityId
	 --  WHERE D.EFFECTIVEFROMTIMEKEY<=@TimeKey AND D.EFFECTIVETOTIMEKEY>=@TimeKey

	    UPDATE D SET D.FinalAssetClassAlt_Key=A.FinalAssetClassAlt_Key,D.NPIDt=A.NPIDt,
	  DEGREASON='PERCOLATION BY InvID' + ' ' +e.RefInvID
	  FROM #TEMPMINASSETCLASS  A
	  INNER JOIN #TEMPMINASSETCLASSReason E
	  ON A.UCIFID = E.UCIFID
		inner join InvestmentIssuerDetail B ON A.UcifId=B.UcifId
			AND B.EffectiveFromTimeKey<=@TimeKey and B.EffectiveToTimeKey>=@TimeKey
		INNER JOIN InvestmentBasicDetail C
			ON B.IssuerEntityId=C.IssuerEntityId
			AND C.EffectiveFromTimeKey<=@TimeKey and C.EffectiveToTimeKey>=@TimeKey
	  INNER JOIN InvestmentFinancialDetail  D
			ON C.InvEntityId=D.InvEntityId
	   WHERE D.EFFECTIVEFROMTIMEKEY<=@TimeKey AND D.EFFECTIVETOTIMEKEY>=@TimeKey
			AND (D.FinalAssetClassAlt_Key=1 or D.DPD = 0)


	 --   UPDATE D SET DEGREASON='PERCOLATION BY OWN INVESTMENT' + ' ' +A.UcifId
		--FROM #TEMPMINASSETCLASS  A
		--inner join InvestmentIssuerDetail B ON A.UcifId=B.UcifId
		--	AND B.EffectiveFromTimeKey<=@TimeKey and B.EffectiveToTimeKey>=@TimeKey
		--INNER JOIN InvestmentBasicDetail C
		--	ON B.IssuerEntityId=C.IssuerEntityId
		--	AND C.EffectiveFromTimeKey<=@TimeKey and C.EffectiveToTimeKey>=@TimeKey
	 -- INNER JOIN InvestmentFinancialDetail  D
		--	ON C.InvEntityId=D.InvEntityId
	 --  WHERE D.EFFECTIVEFROMTIMEKEY<=@TimeKey AND D.EFFECTIVETOTIMEKEY>=@TimeKey
	 --   and DEGREASON is null


UPDATE B SET
	Asset_Norm='ALWYS_STD',AssetClass_AltKey=1,FinalAssetClassAlt_Key=1,NPIDt=NULL,DEGREASON=NULL,FLGDEG=NULL
FROM InvestmentBasicDetail A
inner join InvestmentIssuerDetail C ON A.IssuerEntityId=C.IssuerEntityId
AND C.EffectiveFromTimeKey <=@timekey AND C.EffectiveToTimeKey>=@timekey
inner join InvestmentFinancialDetail B on A.InvEntityId=B.InvEntityId
AND A.EffectiveFromTimeKey<=@timekey AND A.EffectiveToTimeKey>=@timekey
AND B.EffectiveFromTimeKey<=@timekey AND B.EffectiveToTimeKey>=@timekey
and A.InstrName IN('Bond','BondMMDiscount')
    


UPDATE A SET A.FinalAssetClassAlt_Key= ( CASE  WHEN  DATEADD(DAY,@SUB_Days,A.NPIDt)>@ProcessDate   THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='SUB' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
							  WHEN  DATEADD(DAY,@SUB_Days,A.NPIDt)<=@ProcessDate AND  DATEADD(DAY,@SUB_Days+@DB1_Days,A.NPIDt)>@ProcessDate   THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='DB1' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
						      WHEN  DATEADD(DAY,@SUB_Days+@DB1_Days,A.NPIDt)<=@ProcessDate AND  DATEADD(DAY,@SUB_Days+@DB1_Days+@DB2_Days,A.NPIDt)>@ProcessDate THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='DB2' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
						       WHEN  DATEADD(DAY,(@DB1_Days+@SUB_Days+@DB2_Days),A.NPIDt)<=@ProcessDate  THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='DB3' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
						   END)
         
FROM  InvestmentFinancialDetail A   
WHERE ISNULL(A.FlgDeg,'N')<>'Y'   and A.Asset_Norm <> 'ALWYS_NPA'
AND  A.EffectiveFromTimeKey<=@timekey and A.EffectiveToTimeKey>=@timekey AND FinalAssetClassAlt_Key>1


UPDATE A SET FinalAssetClassAlt_Key=1
		,NPIDt=null	
FROM  InvestmentFinancialDetail A  
WHERE ISNULL(FinalAssetClassAlt_Key,0)=0
and  A.EffectiveFromTimeKey<=@timekey and A.EffectiveToTimeKey>=@timekey


UPDATE A SET FlgDeg='N'
FROM  InvestmentFinancialDetail A  
WHERE ISNULL(FinalAssetClassAlt_Key,0)>1 and ISNULL(InitialAssetAlt_Key,0)>1

-------------------------Changes by Sudesh 12082022-------

UPDATE A SET A.DBTDate= 
(CASE 
						    WHEN  DATEADD(DAY,@SUB_Days,A.NPIDt)<=@PROCESSDATE AND  DATEADD(DAY,@SUB_Days+@DB1_Days,A.NPIDt)>@PROCESSDATE  THEN DATEADD(DAY,@SUB_Days,A.NPIDt)
						    WHEN  DATEADD(DAY,@SUB_Days+@DB1_Days,A.NPIDt)<=@PROCESSDATE AND  DATEADD(DAY,@SUB_Days+@DB1_Days+@DB2_Days,A.NPIDt)>@PROCESSDATE THEN DATEADD(DAY,@SUB_Days,A.NPIDt)
							WHEN  DATEADD(DAY,(@DB1_Days+@SUB_Days+@DB2_Days),A.NPIDt)<=@PROCESSDATE THEN DATEADD(DAY,(@SUB_Days),A.NPIDt)
										   ELSE DBTDate 
									   END)
									    

	FROM InvestmentFinancialDetail  A
	WHERE FinalAssetClassAlt_Key in(3,4,5)
	AND DBTDate is null
	AND A.EffectiveFromTimeKey<=@timekey and A.EffectiveToTimeKey>=@timekey



------------Uncomment Below SMA logic As discuss over mail and call with bank and internal team 15062024--------------
----/*------------------UPGRAD CUSTOMER ACCOUNT------------------*/
UPDATE A SET FLGUPG='N'
FROM InvestmentFinancialDetail A
WHERE    A.EffectiveFromTimeKey<=@timekey and A.EffectiveToTimeKey>=@timekey 


IF OBJECT_ID('TEMPDB..#TEMPTABLE') IS NOT NULL
      DROP TABLE #TEMPTABLE

SELECT A.RefIssuerID,TOTALCOUNT  INTO #TEMPTABLE FROM 
(
SELECT A.RefIssuerID,COUNT(1) TOTALCOUNT FROM 
InvestmentFinancialDetail A
WHERE A.EffectiveFromTimeKey<=@timekey and A.EffectiveToTimeKey>=@timekey
GROUP BY A.RefIssuerID
)
A INNER JOIN 
(
SELECT B.RefIssuerID,COUNT(1) TOTALDPD_MAXCOUNT 
FROM InvestmentFinancialDetail B
WHERE (ISNULL(B.DPD,0)<=0 )
   and ISNULL(FinalAssetClassAlt_Key,1) not in(1) and B.Asset_Norm <> 'ALWYS_NPA'
  AND B.EffectiveFromTimeKey<=@TimeKey and B.EffectiveToTimeKey>=@TimeKey
 GROUP BY B.RefIssuerID
) B ON A.RefIssuerID=B.RefIssuerID AND A.TOTALCOUNT=B.TOTALDPD_MAXCOUNT


----  /*------ UPGRADING CUSTOMER-----------*/
  

UPDATE A SET A.FlgUpg='U'
FROM InvestmentFinancialDetail A 
INNER JOIN #TEMPTABLE B ON A.RefIssuerID=B.RefIssuerID
				INNER JOIN InvestmentBasicDetail Bb
					ON A.InvEntityId =bb.InvEntityId
					AND bb.EffectiveFromTimeKey <=@TIMEKEY AND bb.EffectiveToTimeKey >=@TIMEKEY
				INNER JOIN InvestmentIssuerDetail Cc
					ON Cc.IssuerEntityId=bb.IssuerEntityId
				AND Cc.EffectiveFromTimeKey <=@TIMEKEY AND Cc.EffectiveToTimeKey >=@TIMEKEY
	WHERE  A.EffectiveFromTimeKey<=@timekey and A.EffectiveToTimeKey>=@timekey
 AND ASSET_NORM='NORMAL'



UPDATE A SET  A.UpgDate=@PROCESSDATE
             ,A.DegReason=NULL
			 ,A.FinalAssetClassAlt_Key=1
			 ,A.FlgDeg='N'
			 ,A.NPIDt=null
			 ,A.DBTDate=null
             ,A.FlgUpg='U'
			 FROM InvestmentFinancialDetail A
WHERE  ISNULL(A.FlgUpg,'U')='U' 
AND A.EffectiveFromTimeKey<=@timekey and A.EffectiveToTimeKey>=@timekey

------Start SMA Calculation 13/04/2022 Added By Triloki Khanna------

 UPDATE A SET A.SMA_CLASS=NULL
              ,A.SMA_REASON=NULL
		       ,A.SMA_DT=NULL
		       ,A.FLGSMA='N'
 FROM InvestmentFinancialDetail A 
 WHERE A.EffectiveFromTimeKey<=@TIMEKEY AND A.EffectiveToTimeKey>=@TIMEKEY
 
 UPDATE A SET A.SMA_CLASS=NULL
		       ,A.SMA_DT=NULL
		       ,A.FLGSMA='N'
 FROM InvestmentIssuerDetail A 
 WHERE A.EffectiveFromTimeKey<=@TIMEKEY AND A.EffectiveToTimeKey>=@TIMEKEY
  
UPDATE A SET A.SMA_CLASS=
   (CASE  WHEN ISNULL(A.DPD,0)  BETWEEN @SMA0LowerValue AND @SMA0HigherValue  THEN 'SMA_0'
	      WHEN ISNULL(A.DPD,0)  BETWEEN @SMA1LowerValue AND @SMA1HigherValue  THEN 'SMA_1'
		  WHEN ISNULL(A.DPD,0)  BETWEEN @SMA2LowerValue AND @SMA2HigherValue  THEN 'SMA_2'
		  WHEN ISNULL(A.DPD,0) >@SMA2HigherValue THEN 'SMA_2'
		  ELSE NULL
		  END)
,A.SMA_REASON= (CASE 
					 WHEN ISNULL(A.DPD_DivOverdue,0)=ISNULL(A.DPD,0) THEN 'DEGRADE BY Interest_DividendDueDate'
					 WHEN ISNULL(A.DPD_Maturity,0)=ISNULL(A.DPD,0) THEN 'DEGRADE BY Maturity Date'
					 WHEN ISNULL(A.PartialRedumptionDPD,0)=ISNULL(A.DPD,0) THEN 'DEGRADE BY Partial Redumption Due Date'
							 
				  ELSE 'OTHER'
					END)
,A.SMA_DT=   DATEADD(DAY, -A.DPD + 1 ,@ProcessDate)
,A.FLGSMA='Y'
FROM InvestmentFinancialDetail A 
 WHERE A.EffectiveFromTimeKey<=@TIMEKEY AND A.EffectiveToTimeKey>=@TIMEKEY
 AND ISNULL(FINALASSETCLASSALT_KEY,1)=1
 AND ISNULL(A.DPD,0)>0 AND Asset_Norm='NORMAL'


IF OBJECT_ID('TEMPDB..#TEMPTABLE_SMACLASSUCIF_ID') IS NOT NULL
 DROP TABLE #TEMPTABLE_SMACLASSUCIF_ID

SELECT UcifId UCIF_ID,
MAX(CASE WHEN A.SMA_CLASS='SMA_0' THEN  1 
WHEN A.SMA_CLASS='SMA_1' THEN  2
WHEN A.SMA_CLASS='SMA_2' THEN  3 ELSE 0 END ) SMA_CLASS_KEY  ,MIN(A.SMA_Dt) SMA_Dt
,'INV' PercType,'SMA_0' AS SMA_CLASS
INTO #TEMPTABLE_SMACLASSUCIF_ID
FROM InvestmentFinancialDetail A 
INNER JOIN InvestmentBasicDetail B
ON A.InvEntityId =B.InvEntityId
AND A.EffectiveFromTimeKey <=@TIMEKEY AND A.EffectiveToTimeKey >=@TIMEKEY
AND B.EffectiveFromTimeKey <=@TIMEKEY AND B.EffectiveToTimeKey >=@TIMEKEY
INNER JOIN InvestmentIssuerDetail C
ON C.IssuerEntityId=B.IssuerEntityId
AND C.EffectiveFromTimeKey <=@TIMEKEY AND C.EffectiveToTimeKey >=@TIMEKEY
WHERE ISNULL(FinalAssetClassAlt_Key,1)=1 AND  A.FLGSMA='Y'
GROUP BY  UcifId

UPDATE #TEMPTABLE_SMACLASSUCIF_ID SET SMA_CLASS='SMA_0' WHERE SMA_CLASS_KEY=1
UPDATE #TEMPTABLE_SMACLASSUCIF_ID SET SMA_CLASS='SMA_1' WHERE SMA_CLASS_KEY=2
UPDATE #TEMPTABLE_SMACLASSUCIF_ID SET SMA_CLASS='SMA_2' WHERE SMA_CLASS_KEY=3


UPDATE B SET FlgSMA='Y',SMA_Dt=A.SMA_Dt,SMA_Class=A.SMA_CLASS
FROM #TEMPTABLE_SMACLASSUCIF_ID A 
INNER JOIN InvestmentIssuerDetail B
ON A.UCIF_ID=B.UcifId
WHERE B.EffectiveFromTimeKey<=@TIMEKEY AND B.EffectiveToTimeKey>=@TIMEKEY


------END SMA Calculation 13/04/2022 Added By Triloki Khanna------

UPDATE PRO.ACLRUNNINGPROCESSSTATUS 
	SET COMPLETED='Y',ERRORDATE=NULL,ERRORDESCRIPTION=NULL,COUNT=ISNULL(COUNT,0)+1
	WHERE RUNNINGPROCESSNAME='InvestmentDataProcessing'

	
	--------------Added for DashBoard 04-03-2021
	Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='ASSET CLASSIFICATION'

	
END TRY
BEGIN  CATCH

	UPDATE PRO.ACLRUNNINGPROCESSSTATUS 
	SET COMPLETED='N',ERRORDATE=GETDATE(),ERRORDESCRIPTION=ERROR_MESSAGE(),COUNT=ISNULL(COUNT,0)+1
	WHERE RUNNINGPROCESSNAME='InvestmentDataProcessing'
END CATCH


SET NOCOUNT OFF
END

















GO