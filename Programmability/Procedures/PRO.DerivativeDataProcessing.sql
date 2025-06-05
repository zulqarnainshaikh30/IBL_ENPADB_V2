SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



----/*=========================================
---- AUTHER : TRILOKI KHANNA
---- CREATE DATE : 27-11-2019
---- MODIFY DATE : 07-04-2022
---- DESCRIPTION : UPDATE DerivativeDataProcessing
---- EXEC [PRO].[DerivativeDataProcessing] @TIMEKEY=26465
----=============================================*/


CREATE PROCEDURE [PRO].[DerivativeDataProcessing]
@TIMEKEY INT
WITH RECOMPILE

AS
BEGIN
  SET NOCOUNT ON
   BEGIN TRY

 
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
DECLARE @RefPeriodOverdueDerivative INT =	(SELECT TOP 1 REFVALUE FROM PRO.refperiod where BusinessRule='RefPeriodOverdueDerivative' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
DECLARE @RefPeriodOverdueDerivativeRepo INT =	(SELECT TOP 1 REFVALUE FROM PRO.refperiod where BusinessRule='RefPeriodOverdueDerivativeRepo' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)


UPDATE [CurDat].[DerivativeDetail] SET DPD=0 WHERE EffectiveFromTimeKey<=@timekey AND EffectiveToTimeKey>=@timekey
AND ISNULL(DPD,0)=0


UPDATE A SET DPD_DivOverdue=0,DPD=0, DPD_CouponOverDue=0,FLGDEG='N', FLGUPG='N',DEGREASON=NULL, UPGDATE=NULL
FROM [CurDat].[DerivativeDetail] A
WHERE A.EffectiveFromTimeKey<=@timekey AND A.EffectiveToTimeKey>=@timekey


/*UPDATE PREVIOUS DAY STATUS AS INITIAL STATUS FOR CURRENT DAY */

UPDATE A SET 
		 InitialAssetAlt_Key=B.FinalAssetClassAlt_Key
		,InitialNPIDt =B.NPIDt
		,A.NPIDt =B.NPIDt
		,DBTDate=B.DBTDate
		,FinalAssetClassAlt_Key=B.FinalAssetClassAlt_Key
FROM CURDAT.[DerivativeDetail] A
	INNER JOIN CURDAT.[DerivativeDetail] B
		ON A.UCIC_ID =B.UCIC_ID
		AND A.EffectiveFromTimeKey<=@timekey AND A.EffectiveToTimeKey>=@timekey
		AND B.EffectiveFromTimeKey<=@timekey-1 AND B.EffectiveToTimeKey>=@timekey-1

		update A set AssetClass_AltKey = 1 
		 FROM CURDAT.[DerivativeDetail] A
		 where AssetClass_AltKey IS NULL
		 and A.EffectiveFromTimeKey<=@timekey AND A.EffectiveToTimeKey>=@timekey

		 update A set InitialAssetAlt_Key = 1 
		 FROM CURDAT.[DerivativeDetail] A
		 where InitialAssetAlt_Key IS NULL
		 and A.EffectiveFromTimeKey<=@timekey AND A.EffectiveToTimeKey>=@timekey

		update A set FinalAssetClassAlt_Key = 1 
		 FROM CURDAT.[DerivativeDetail] A
		 where FinalAssetClassAlt_Key IS NULL
		 and A.EffectiveFromTimeKey<=@timekey AND A.EffectiveToTimeKey>=@timekey


UPDATE A SET DPD_DivOverdue=(CASE WHEN  OverDueSinceDt IS NOT NULL   
      THEN   DATEDIFF(DAY,OverDueSinceDt,@PROCESSDATE)+1       ELSE 0 END)

FROM [CurDat].[DerivativeDetail] A
	WHERE A.EffectiveFromTimeKey<=@timekey AND A.EffectiveToTimeKey>=@timekey
      and A.InstrumentName IN('FXForward','FXSwap','FXFlexiForward','Swap','SwapCrossCurrency','FXOption','StructuredFlows.Loan','Repo.RR','TREPS')
	  and a.OverDueSinceDt is not null

UPDATE A SET DPD_CouponOverDue=(CASE WHEN  CouponOverDueSinceDt IS NOT NULL   
      THEN   DATEDIFF(DAY,CouponOverDueSinceDt,@PROCESSDATE)+1       ELSE 0 END)

FROM [CurDat].[DerivativeDetail] A
	WHERE A.EffectiveFromTimeKey<=@timekey AND A.EffectiveToTimeKey>=@timekey
      and A.CouponOverDueSinceDt is not null


	  
;WITH Derivative_DPD
AS(
		SELECT DerivativeEntityID,DPD_DivOverdue DPD 
		FROM curdat.DerivativeDetail 
			WHERE ISNULL(DPD_DivOverdue,0)>0 and EffectiveFromTimeKey<=@timekey AND EffectiveToTimeKey>=@timekey
		UNION ALL 
		SELECT DerivativeEntityID,DPD_CouponOverDue	  DPD FROM curdat.DerivativeDetail 
			WHERE ISNULL(DPD_CouponOverDue,0)>0   and EffectiveFromTimeKey<=@timekey AND EffectiveToTimeKey>=@timekey

) 


UPDATE B
	SET B.DPD=A.DPD_Derivative
FROM  (SELECT DerivativeEntityID, MAX(DPD) DPD_Derivative FROM Derivative_DPD 
		GROUP BY DerivativeEntityID
		)a 
	INNER JOIN curdat.DerivativeDetail B
		ON A.DerivativeEntityID =B.DerivativeEntityID
		where  EffectiveFromTimeKey<=@timekey AND EffectiveToTimeKey>=@timekey


 UPDATE [CurDat].[DerivativeDetail]  SET DPD_DivOverdue=0 WHERE DPD_DivOverdue<0
 AND EffectiveFromTimeKey<=@timekey AND EffectiveToTimeKey>=@timekey 

  UPDATE [CurDat].[DerivativeDetail]  SET DPD_CouponOverDue=0 WHERE DPD_CouponOverDue<0
 AND EffectiveFromTimeKey<=@timekey AND EffectiveToTimeKey>=@timekey 

 UPDATE [CurDat].[DerivativeDetail]  SET DPD=0 WHERE DPD<0
 AND EffectiveFromTimeKey<=@timekey AND EffectiveToTimeKey>=@timekey 

 

UPDATE A SET FLGDEG ='Y'
		,DEGREASON='DEGRADE BY Derivative Overdue' 
FROM [CurDat].[DerivativeDetail] A
WHERE A.EffectiveFromTimeKey<=@timekey AND A.EffectiveToTimeKey>=@timekey
	AND DPD>=@RefPeriodOverdueDerivative AND A.InstrumentName IN('TREPS','FXForward','FXSwap','FXFlexiForward','Swap','SwapCrossCurrency','FXOption')
	AND A.FinalAssetClassAlt_Key=1
	AND isnull(DPD_DivOverdue,0)>=@RefPeriodOverdueDerivative 
	
	UPDATE A SET FLGDEG ='Y'
		,DEGREASON='DEGRADE BY CouponOverDueSinceDt' 
FROM [CurDat].[DerivativeDetail] A
WHERE A.EffectiveFromTimeKey<=@timekey AND A.EffectiveToTimeKey>=@timekey
	AND DPD>=@RefPeriodOverdueDerivative AND A.InstrumentName IN('TREPS','FXForward','FXSwap','FXFlexiForward','Swap','SwapCrossCurrency','FXOption')
	AND A.FinalAssetClassAlt_Key=1	
	AND isnull(DPD_CouponOverDue,0)>=@RefPeriodOverdueDerivative

UPDATE A SET FLGDEG ='Y'
		,DEGREASON='DEGRADE BY Derivative Overdue,DEGRADE BY CouponOverDueSinceDt' 
FROM [CurDat].[DerivativeDetail] A
WHERE A.EffectiveFromTimeKey<=@timekey AND A.EffectiveToTimeKey>=@timekey
	AND DPD>=@RefPeriodOverdueDerivative AND A.InstrumentName IN('TREPS','FXForward','FXSwap','FXFlexiForward','Swap','SwapCrossCurrency','FXOption')
	AND A.FinalAssetClassAlt_Key=1
	AND  (isnull(DPD_CouponOverDue,0)>=@RefPeriodOverdueDerivative and isnull(DPD_DivOverdue,0)>=@RefPeriodOverdueDerivative)

	-------------------------------------Derivative Loan -------------



UPDATE A SET FLGDEG ='Y'
		,DEGREASON='DEGRADE BY Derivative Overdue' 
FROM [CurDat].[DerivativeDetail] A
WHERE A.EffectiveFromTimeKey<=@timekey AND A.EffectiveToTimeKey>=@timekey
	AND DPD>=@RefPeriodOverdueDerivativeRepo AND A.InstrumentName IN('StructuredFlows.Loan','Repo.RR')
	AND A.FinalAssetClassAlt_Key=1
	AND isnull(DPD_DivOverdue,0)>=@RefPeriodOverdueDerivativeRepo 
	
	UPDATE A SET FLGDEG ='Y'
		,DEGREASON='DEGRADE BY CouponOverDueSinceDt' 
FROM [CurDat].[DerivativeDetail] A
WHERE A.EffectiveFromTimeKey<=@timekey AND A.EffectiveToTimeKey>=@timekey
	AND DPD>=@RefPeriodOverdueDerivativeRepo AND A.InstrumentName IN('StructuredFlows.Loan','Repo.RR')
	AND A.FinalAssetClassAlt_Key=1	
	AND isnull(DPD_CouponOverDue,0)>=@RefPeriodOverdueDerivativeRepo

UPDATE A SET FLGDEG ='Y'
		,DEGREASON='DEGRADE BY Derivative Overdue,DEGRADE BY CouponOverDueSinceDt' 
FROM [CurDat].[DerivativeDetail] A
WHERE A.EffectiveFromTimeKey<=@timekey AND A.EffectiveToTimeKey>=@timekey
	AND DPD>=@RefPeriodOverdueDerivativeRepo AND A.InstrumentName IN('StructuredFlows.Loan','Repo.RR')
	AND A.FinalAssetClassAlt_Key=1
	AND  (isnull(DPD_CouponOverDue,0)>=@RefPeriodOverdueDerivativeRepo and isnull(DPD_DivOverdue,0)>=@RefPeriodOverdueDerivativeRepo)



/*---------------UPDATE DEG FLAG AT ACCOUNT LEVEL---------------*/

/*------------Calculate NpaDt -------------------------------------*/

UPDATE  A  SET NPIDt= DATEADD(DAY,ISNULL(@RefPeriodOverdueDerivative,0),DATEADD(DAY,-ISNULL(DPD,0),@ProcessDate))
FROM [CurDat].[DerivativeDetail] A
WHERE A.EffectiveFromTimeKey<=@timekey AND A.EffectiveToTimeKey>=@timekey
AND ISNULL(A.FLGDEG,'N')='Y'    AND A.InstrumentName IN('TREPS','FXForward','FXSwap','FXFlexiForward','Swap','SwapCrossCurrency','FXOption')


UPDATE  A  SET NPIDt= DATEADD(DAY,ISNULL(@RefPeriodOverdueDerivativeRepo,0),DATEADD(DAY,-ISNULL(DPD,0),@ProcessDate))
FROM [CurDat].[DerivativeDetail] A
WHERE A.EffectiveFromTimeKey<=@timekey AND A.EffectiveToTimeKey>=@timekey
AND ISNULL(A.FLGDEG,'N')='Y'  AND A.InstrumentName IN ('StructuredFlows.Loan','Repo.RR')

UPDATE  A  SET NPIDt= @ProcessDate
FROM [CurDat].[DerivativeDetail] A
WHERE A.EffectiveFromTimeKey<=@timekey AND A.EffectiveToTimeKey>=@timekey
AND ISNULL(A.FLGDEG,'N')='Y' AND NPIDt IS NULL


UPDATE A SET A.FinalAssetClassAlt_Key= ( CASE  WHEN  DATEADD(DAY,@SUB_Days,A.NPIDt)>@ProcessDate   THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='SUB' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
										  WHEN  DATEADD(DAY,@SUB_Days,A.NPIDt)<=@ProcessDate AND  DATEADD(DAY,@SUB_Days+@DB1_Days,A.NPIDt)>@ProcessDate   THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='DB1' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
									      WHEN  DATEADD(DAY,@SUB_Days+@DB1_Days,A.NPIDt)<=@ProcessDate AND  DATEADD(DAY,@SUB_Days+@DB1_Days+@DB2_Days,A.NPIDt)>@ProcessDate THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='DB2' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
									       WHEN  DATEADD(DAY,(@DB1_Days+@SUB_Days+@DB2_Days),A.NPIDt)<=@ProcessDate  THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='DB3' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
									   END)
         
FROM [CurDat].[DerivativeDetail] A
WHERE A.EffectiveFromTimeKey<=@timekey AND A.EffectiveToTimeKey>=@timekey
AND  ISNULL(A.FlgDeg,'N')='Y'  



IF OBJECT_ID('TEMPDB..#TEMPMINASSETCLASS') IS NOT NULL
  DROP TABLE #TEMPMINASSETCLASS
  	
	SELECT UCIC_ID,MAX(ISNULL(FinalAssetClassAlt_Key,1)) FinalAssetClassAlt_Key
	,MIN(NPIDt) NPIDt 
	 INTO #TEMPMINASSETCLASS 
	FROM [CurDat].[DerivativeDetail] A
	WHERE A.EffectiveFromTimeKey<=@timekey AND A.EffectiveToTimeKey>=@timekey
	  AND  ISNULL(FinalAssetClassAlt_Key,1)>1
   GROUP BY UCIC_ID
  
   select distinct UCIC_ID,STUFF((SELECT  distinct  ', ' + B.DerivativeRefNo  
										from curdat.DerivativeDetail B 
										WHERE B.UCIC_ID = A.UCIC_ID  
										and EffectiveFromTimeKey <= @timekey and EffectiveToTimeKey >= @timekey
										AND  ISNULL(B.FinalAssetClassAlt_Key,1)>1 
										FOR XML PATH('')),1,1,'') DerivativeRefNo
	INTO #TEMPMINASSETCLASSReason
	FROM [CurDat].[DerivativeDetail] A
	WHERE A.EffectiveFromTimeKey<=@timekey AND A.EffectiveToTimeKey>=@timekey
	  AND  ISNULL(FinalAssetClassAlt_Key,1)>1 
   GROUP BY UCIC_ID



	 
	  UPDATE B SET FinalAssetClassAlt_Key=A.FinalAssetClassAlt_Key,NPIDt=A.NPIDt,DEGREASON='PERCOLATION BY DerivativeRefNo' + ' ' +C.DerivativeRefNo
	  FROM #TEMPMINASSETCLASS  A
	  LEFT JOIN #TEMPMINASSETCLASSReason C
	  ON A.UCIC_ID = C.UCIC_ID
		INNER JOIN  [CurDat].[DerivativeDetail] B
		ON B.EffectiveFromTimeKey<=@timekey AND B.EffectiveToTimeKey>=@timekey
			AND A.UCIC_ID=B.UCIC_ID
			AND B.FinalAssetClassAlt_Key=1


UPDATE A SET A.FinalAssetClassAlt_Key= ( CASE  WHEN  DATEADD(DAY,@SUB_Days,A.NPIDt)>@ProcessDate   THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='SUB' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
							  WHEN  DATEADD(DAY,@SUB_Days,A.NPIDt)<=@ProcessDate AND  DATEADD(DAY,@SUB_Days+@DB1_Days,A.NPIDt)>@ProcessDate   THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='DB1' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
						      WHEN  DATEADD(DAY,@SUB_Days+@DB1_Days,A.NPIDt)<=@ProcessDate AND  DATEADD(DAY,@SUB_Days+@DB1_Days+@DB2_Days,A.NPIDt)>@ProcessDate THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='DB2' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
						       WHEN  DATEADD(DAY,(@DB1_Days+@SUB_Days+@DB2_Days),A.NPIDt)<=@ProcessDate  THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='DB3' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
						   END)
         
FROM   [CurDat].[DerivativeDetail] A   
WHERE ISNULL(A.FlgDeg,'N')<>'Y'  
AND  A.EffectiveFromTimeKey<=@timekey and A.EffectiveToTimeKey>=@timekey AND FinalAssetClassAlt_Key>1 and A.Asset_Norm <> 'ALWYS_NPA'


UPDATE A SET FinalAssetClassAlt_Key=1, NPIDt =NULL
FROM   [CurDat].[DerivativeDetail] A   
WHERE ISNULL(FinalAssetClassAlt_Key,0)=0
and  A.EffectiveFromTimeKey<=@timekey and A.EffectiveToTimeKey>=@timekey

UPDATE A SET A.DBTDate= 
(CASE 
						    WHEN  DATEADD(DAY,@SUB_Days,A.NPIDt)<=@PROCESSDATE AND  DATEADD(DAY,@SUB_Days+@DB1_Days,A.NPIDt)>@PROCESSDATE  THEN DATEADD(DAY,@SUB_Days,A.NPIDt)
						    WHEN  DATEADD(DAY,@SUB_Days+@DB1_Days,A.NPIDt)<=@PROCESSDATE AND  DATEADD(DAY,@SUB_Days+@DB1_Days+@DB2_Days,A.NPIDt)>@PROCESSDATE THEN DATEADD(DAY,@SUB_Days,A.NPIDt)
							WHEN  DATEADD(DAY,(@DB1_Days+@SUB_Days+@DB2_Days),A.NPIDt)<=@PROCESSDATE THEN DATEADD(DAY,(@SUB_Days),A.NPIDt)
										   ELSE DBTDate 
									   END)
									    

	FROM curdat.DerivativeDetail  A
	WHERE FinalAssetClassAlt_Key in(3,4,5)
	AND DBTDate is null
	AND A.EffectiveFromTimeKey<=@timekey and A.EffectiveToTimeKey>=@timekey

----/*------------------UPGRAD CUSTOMER ACCOUNT------------------*/

UPDATE A SET FLGUPG='N'
FROM   [CurDat].[DerivativeDetail] A   
WHERE    A.EffectiveFromTimeKey<=@timekey and A.EffectiveToTimeKey>=@timekey 


IF OBJECT_ID('TEMPDB..#TEMPTABLE') IS NOT NULL
      DROP TABLE #TEMPTABLE

SELECT A.UCIC_ID,TOTALCOUNT  INTO #TEMPTABLE FROM 
(
SELECT A.UCIC_ID,COUNT(1) TOTALCOUNT  
FROM   [CurDat].[DerivativeDetail] A 
WHERE A.EffectiveFromTimeKey<=@timekey and A.EffectiveToTimeKey>=@timekey
GROUP BY A.UCIC_ID
)
A INNER JOIN 
(
SELECT B.UCIC_ID,COUNT(1) TOTALDPD_MAXCOUNT 
FROM   [CurDat].[DerivativeDetail] B
WHERE (ISNULL(B.DPD,0)<=0 )
   and ISNULL(FinalAssetClassAlt_Key,1) not in(1) and B.Asset_Norm <> 'ALWYS_NPA'
  AND B.EffectiveFromTimeKey<=@TimeKey and B.EffectiveToTimeKey>=@TimeKey
 GROUP BY B.UCIC_ID

) B ON A.UCIC_ID=B.UCIC_ID AND A.TOTALCOUNT=B.TOTALDPD_MAXCOUNT


----  /*------ UPGRADING CUSTOMER-----------*/
  
UPDATE A SET A.FlgUpg='U'
FROM   [CurDat].[DerivativeDetail] A INNER JOIN #TEMPTABLE B ON A.UCIC_ID=B.UCIC_ID
WHERE  A.EffectiveFromTimeKey<=@timekey and A.EffectiveToTimeKey>=@timekey



UPDATE A SET  A.UpgDate=@PROCESSDATE
             ,A.DegReason=NULL
			 ,A.FinalAssetClassAlt_Key=1
			 ,A.FlgDeg='N'
			 ,A.NPIDt=NULL
			 ,A.DBTDate=NULL
             ,A.FlgUpg='U'
			 FROM  [CurDat].[DerivativeDetail] A
WHERE  ISNULL(A.FlgUpg,'U')='U' 
AND A.EffectiveFromTimeKey<=@timekey and A.EffectiveToTimeKey>=@timekey


UPDATE PRO.ACLRUNNINGPROCESSSTATUS 
	SET COMPLETED='Y',ERRORDATE=NULL,ERRORDESCRIPTION=NULL,COUNT=ISNULL(COUNT,0)+1
	WHERE RUNNINGPROCESSNAME='DerivativeDataProcessing'

	
	--------------Added for DashBoard 04-03-2021
	Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='ASSET CLASSIFICATION'

	
	print @Timekey

	
END TRY
BEGIN  CATCH

	UPDATE PRO.ACLRUNNINGPROCESSSTATUS 
	SET COMPLETED='N',ERRORDATE=GETDATE(),ERRORDESCRIPTION=ERROR_MESSAGE(),COUNT=ISNULL(COUNT,0)+1
	WHERE RUNNINGPROCESSNAME='DerivativeDataProcessing'
END CATCH


SET NOCOUNT OFF
END

















GO