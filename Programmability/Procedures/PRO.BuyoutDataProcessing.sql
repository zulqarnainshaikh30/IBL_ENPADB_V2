SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/*=========================================
 AUTHER :Liyaqat
 CREATE DATE :2022-02-22
 MODIFY DATE :  
 DESCRIPTION :Buyout Data Processing for Flat File data
 EXEC [PRO].[BuyoutDataProcessing_New]
=============================================*/
CREATE PROCEDURE [PRO].[BuyoutDataProcessing]

AS
BEGIN
  SET NOCOUNT ON
   BEGIN TRY
DECLARE @TIMEKEY INT=(select Timekey from UTKS_STGDB..Automate_Advances where EXT_FLG='Y')     
DECLARE @PROCESSDATE DATE =(SELECT DATE FROM SysDayMatrix WHERE TimeKey=@TIMEKEY)
DECLARE @SUB_Days INT =(SELECT RefValue FROM PRO.refperiod WHERE BusinessRule='SUB_Days' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
DECLARE @DB1_Days INT =(SELECT RefValue FROM PRO.refperiod WHERE BusinessRule='DB1_Days' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
DECLARE @DB2_Days INT =(SELECT RefValue FROM PRO.refperiod WHERE BusinessRule='DB2_Days' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
DECLARE @MoveToDB1 DECIMAL(5,2) =(SELECT cast(RefValue/100.00 as decimal(5,2))FROM PRO.refperiod where BusinessRule='MoveToDB1' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
DECLARE @MoveToLoss DECIMAL(5,2)=(SELECT cast(RefValue/100.00 as decimal(5,2)) FROM PRO.refperiod where BusinessRule='MoveToLoss' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
DECLARE @SubStandard INT =	(SELECT PROVISIONALT_KEY FROM DIMPROVISION_SEG WHERE PROVISIONNAME='Sub Standard'	and segment='bank'								    AND EFFECTIVEFROMTIMEKEY <=@TIMEKEY AND EFFECTIVETOTIMEKEY >=@TIMEKEY)
DECLARE @DoubtfulI INT =	(SELECT PROVISIONALT_KEY FROM DIMPROVISION_SEG WHERE PROVISIONNAME='Doubtful-I'		and segment='bank'								    AND EFFECTIVEFROMTIMEKEY <=@TIMEKEY AND EFFECTIVETOTIMEKEY >=@TIMEKEY)
DECLARE @DoubtfulII INT =	(SELECT PROVISIONALT_KEY FROM DIMPROVISION_SEG WHERE PROVISIONNAME='Doubtful-II'	and segment='bank'									AND EFFECTIVEFROMTIMEKEY <=@TIMEKEY AND EFFECTIVETOTIMEKEY >=@TIMEKEY)
DECLARE @DoubtfulIII INT =	(SELECT PROVISIONALT_KEY FROM DIMPROVISION_SEG WHERE PROVISIONNAME='Doubtful-III'	and segment='bank'								    AND EFFECTIVEFROMTIMEKEY <=@TIMEKEY AND EFFECTIVETOTIMEKEY >=@TIMEKEY)
DECLARE @Loss INT =			(SELECT PROVISIONALT_KEY FROM DIMPROVISION_SEG WHERE PROVISIONNAME='Loss'			and segment='bank'								    AND EFFECTIVEFROMTIMEKEY <=@TIMEKEY AND EFFECTIVETOTIMEKEY >=@TIMEKEY)
																												
----------------------Added on 02-07-2021
--Declare @PrevTimeKey as Int =(Select LastMonthDateKey from SysDayMatrix where TimeKey=@TIMEKEY) --- for daily ACL Logic need to be added at Temp-Main

--Update BuyoutDetails_Final set EffectiveToTimeKey=@TIMEKEY-1 from BuyoutDetails_Final where EffectiveFromTimeKey=@PrevTimeKey


------------Update SecurityValue
--Update BuyoutDetails_Final set SecurityValue=PrincipalOutstanding ----Commented by Liyaqat
--Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey

------------Update AssetClass  ----Added by Liyaqat on 16/8/2021

UPDATE 	A	SET AssetClass='STD'	FROM BuyoutDetails_Final A	WHERE A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey and A.AssetClass	=	'STANDARD'
UPDATE 	A	SET AssetClass='STD'	FROM BuyoutDetails_Final A	WHERE A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey and A.AssetClass	=	'SMA-0'
UPDATE 	A	SET AssetClass='STD'	FROM BuyoutDetails_Final A	WHERE A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey and A.AssetClass	=	'SMA-1'
UPDATE 	A	SET AssetClass='STD'	FROM BuyoutDetails_Final A	WHERE A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey and A.AssetClass	=	'SMA-2'
UPDATE 	A	SET AssetClass='SUB'	FROM BuyoutDetails_Final A	WHERE A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey and A.AssetClass	=	'Sub Standard'
UPDATE 	A	SET AssetClass='DB1'	FROM BuyoutDetails_Final A	WHERE A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey and A.AssetClass	=	'Doubtful 1'
UPDATE 	A	SET AssetClass='DB2'	FROM BuyoutDetails_Final A	WHERE A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey and A.AssetClass	=	'Doubtful 2'
UPDATE 	A	SET AssetClass='DB3'	FROM BuyoutDetails_Final A	WHERE A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey and A.AssetClass	=	'Doubtful 3'
UPDATE 	A	SET AssetClass='LOS'	FROM BuyoutDetails_Final A	WHERE A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey and A.AssetClass	=	'Loss'


------------Update FinalAssetClassAlt_Key
Update A Set A.FinalAssetClassAlt_Key=B.AssetClassAlt_Key
from BuyoutDetails_Final A
Inner Join DimAssetClass B ON A.AssetClass=B.AssetClassShortNameEnum
And  B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey

-------Update FinalNpaDt    ---- this update won't work due to partition view -- Pranay 2023-04-05
--Update A set A.FinalNpaDt=B.FinalNpaDt,a.PrevProvPercentage=b.FinalProvPercentage
--from BuyoutDetails_Final A
--Inner Join BuyoutDetails_Final B ON A.BuyoutPartyLoanNo=B.BuyoutPartyLoanNo
--And  B.EffectiveToTimeKey=@TimeKey-1
--Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
--And A.FinalAssetClassAlt_Key>1

/******************below changes done by Pranay***2023-04-05*********************************/
DROP TABLE IF EXISTS ##BuyoutDetails_Final_Prev
SELECT * INTO ##BuyoutDetails_Final_Prev 
FROM BuyoutDetails_Final b
WHERE  B.EffectiveToTimeKey=@TimeKey-1

--select * from ##BuyoutDetails_Final_Prev

-------Update FinalNpaDt  
Update A set A.FinalNpaDt=B.FinalNpaDt,a.PrevProvPercentage=b.FinalProvPercentage
from BuyoutDetails_Final A
Inner Join ##BuyoutDetails_Final_Prev B ON A.BuyoutPartyLoanNo=B.BuyoutPartyLoanNo
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
And A.FinalAssetClassAlt_Key>1
/******************************************************/

Update A set 
--A.FinalNpaDt=DATEADD(DAY,ISNULL(90,0),DATEADD(DAY,-ISNULL(DPD,0),@ProcessDate)) --change made by lqt on 20230512
A.FinalNpaDt=A.NPADate 
from BuyoutDetails_Final A where A.FinalNpaDt is null And A.FinalAssetClassAlt_Key>1
And A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
 

/*---------------UPDATE DEG FLAG AT ACCOUNT LEVEL---------------*/
UPDATE A SET FLGDEG ='Y'
from  BuyoutDetails_Final A
where ISNULL(DPD,0)>90 
and A.EffectiveFromTimeKey<=@timekey and A.EffectiveToTimeKey>=@timekey
And A.FinalAssetClassAlt_Key=1  --ISNULL(DPD,0)>=90 changed on 2022-02-17


/*---------------ASSIGNE DEG REASON---------------*/
UPDATE A SET A.DEGREASON= 'DEGRADE BY DPD More Than 90 Days' 
from  BuyoutDetails_Final A
where ISNULL(DPD,0)>90
and A.EffectiveFromTimeKey<=@timekey and A.EffectiveToTimeKey>=@timekey
And A.FLGDEG ='Y'

/*---------------ASSIGNE NPA REASON---------------*/ ---Added by LQT on 20230914

----;with CTE_buy as
----( select BuyOutEntityID,BuyoutPartyLoanNo,FLGDEG,FLGUPG,DegReason,NPAReason,FinalNpaDt,FinalAssetClassAlt_Key,AssetClass from  BuyoutDetails_Final  
----where EffectiveFromTimeKey<=(@timekey-1) and  EffectiveToTimeKey>=(@timekey-1) and ISNULL(FinalAssetClassAlt_Key,1)<>1)

drop table if exists #DegNPAdata

select BuyOutEntityID,BuyoutPartyLoanNo,FLGDEG,FLGUPG,DegReason,NPAReason,FinalNpaDt,FinalAssetClassAlt_Key,AssetClass 
into #DegNPAdata from  BuyoutDetails_Final  
where EffectiveFromTimeKey<=(@timekey-1) and  EffectiveToTimeKey>=(@timekey-1) and ISNULL(FinalAssetClassAlt_Key,1)<>1

UPDATE A SET A.NPAReason= case when b.FLGDEG ='Y' then b.DEGREASON 
									else b.NPAReason end  
						, A.FinalAssetClassAlt_Key=b.FinalAssetClassAlt_Key	
						, A.AssetClass=b.AssetClass	
						, A.FinalNpaDt=b.FinalNpaDt
from  BuyoutDetails_Final A Join #DegNPAdata B on a.BuyoutPartyLoanNo=b.BuyoutPartyLoanNo
where A.EffectiveFromTimeKey<=@timekey and A.EffectiveToTimeKey>=@timekey
 
/*------------Calculate NpaDt -------------------------------------*/

UPDATE  A  SET FinalNpaDt= DATEADD(DAY,ISNULL(90,0),DATEADD(DAY,-ISNULL(DPD,0),@ProcessDate))
FROM BuyoutDetails_Final A 
WHERE ISNULL(A.FLGDEG,'N')='Y'
and A.EffectiveFromTimeKey<=@timekey and A.EffectiveToTimeKey>=@timekey

UPDATE A SET A.FinalAssetClassAlt_Key= ( CASE  WHEN  DATEADD(DAY,@SUB_Days,A.FinalNpaDt)>@ProcessDate   THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='SUB' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
										  WHEN  DATEADD(DAY,@SUB_Days,A.FinalNpaDt)<=@ProcessDate AND  DATEADD(DAY,@SUB_Days+@DB1_Days,A.FinalNpaDt)>@ProcessDate   THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='DB1' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
									      WHEN  DATEADD(DAY,@SUB_Days+@DB1_Days,A.FinalNpaDt)<=@ProcessDate AND  DATEADD(DAY,@SUB_Days+@DB1_Days+@DB2_Days,A.FinalNpaDt)>@ProcessDate THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='DB2' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
									       WHEN  DATEADD(DAY,(@DB1_Days+@SUB_Days+@DB2_Days),A.FinalNpaDt)<=@ProcessDate  THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='DB3' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
									   END)
         
FROM  BuyoutDetails_Final A   
WHERE ISNULL(A.FlgDeg,'N')='Y'  
and  A.EffectiveFromTimeKey<=@timekey and A.EffectiveToTimeKey>=@timekey


UPDATE A SET A.FinalAssetClassAlt_Key= ( CASE  WHEN  DATEADD(DAY,@SUB_Days,A.FinalNpaDt)>@ProcessDate   THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='SUB' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
										  WHEN  DATEADD(DAY,@SUB_Days,A.FinalNpaDt)<=@ProcessDate AND  DATEADD(DAY,@SUB_Days+@DB1_Days,A.FinalNpaDt)>@ProcessDate   THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='DB1' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
									      WHEN  DATEADD(DAY,@SUB_Days+@DB1_Days,A.FinalNpaDt)<=@ProcessDate AND  DATEADD(DAY,@SUB_Days+@DB1_Days+@DB2_Days,A.FinalNpaDt)>@ProcessDate THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='DB2' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
									       WHEN  DATEADD(DAY,(@DB1_Days+@SUB_Days+@DB2_Days),A.FinalNpaDt)<=@ProcessDate  THEN (SELECT AssetClassAlt_Key FROM DimAssetClass WHERE AssetClassShortName='DB3' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
									   END)
         
FROM  BuyoutDetails_Final A   
WHERE ISNULL(A.FlgDeg,'N')<>'Y'  
and  A.EffectiveFromTimeKey<=@timekey and A.EffectiveToTimeKey>=@timekey

UPDATE A SET FinalAssetClassAlt_Key=1
FROM  BuyoutDetails_Final A  
WHERE ISNULL(FinalAssetClassAlt_Key,0)=0
and  A.EffectiveFromTimeKey<=@timekey and A.EffectiveToTimeKey>=@timekey


UPDATE A SET AssetClass=AssetClassShortName
FROM BuyoutDetails_Final A
INNER JOIN DimAssetClass B
ON A.FinalAssetClassAlt_Key=B.AssetClassAlt_Key
WHERE  A.EffectiveFromTimeKey<=@timekey and A.EffectiveToTimeKey>=@timekey
AND  B.EffectiveFromTimeKey<=@timekey and B.EffectiveToTimeKey>=@timekey


---Condition Modified 13/07/2021 where FinalNpaDt is more than processing date---
update A SET  FinalNpaDt=@PROCESSDATE
FROM BuyoutDetails_Final A
WHERE  A.EffectiveFromTimeKey<=@timekey and A.EffectiveToTimeKey>=@timekey
AND FinalNpaDt>@PROCESSDATE
/*------------------UPGRAD CUSTOMER ACCOUNT------------------*/

UPDATE A SET FLGUPG='N'
FROM BuyoutDetails_Final A
WHERE    A.EffectiveFromTimeKey<=@timekey and A.EffectiveToTimeKey>=@timekey 


IF OBJECT_ID('TEMPDB..#TEMPTABLE') IS NOT NULL
      DROP TABLE #TEMPTABLE

SELECT A.BuyoutPartyLoanNo,TOTALCOUNT  INTO #TEMPTABLE FROM 
(
SELECT A.BuyoutPartyLoanNo,COUNT(1) TOTALCOUNT FROM 
BuyoutDetails_Final A
WHERE A.EffectiveFromTimeKey<=@timekey and A.EffectiveToTimeKey>=@timekey
GROUP BY A.BuyoutPartyLoanNo
)
A INNER JOIN 
(
SELECT B.BuyoutPartyLoanNo,COUNT(1) TOTALDPD_MAXCOUNT 
FROM BuyoutDetails_Final B
WHERE (ISNULL(B.DPD,0)<=0 )
   and B.FINALAssetClassAlt_Key not in(1)
  AND B.EffectiveFromTimeKey<=@timekey and B.EffectiveToTimeKey>=@timekey
  and NPAReason not like '%PERCOLATION BY%'
GROUP BY B.BuyoutPartyLoanNo

) B ON A.BuyoutPartyLoanNo=B.BuyoutPartyLoanNo AND A.TOTALCOUNT=B.TOTALDPD_MAXCOUNT


  /*------ UPGRADING CUSTOMER-----------*/
  
UPDATE A SET A.FlgUpg='U'
FROM BuyoutDetails_Final A INNER JOIN #TEMPTABLE B ON A.BuyoutPartyLoanNo=B.BuyoutPartyLoanNo
WHERE  A.EffectiveFromTimeKey<=@timekey and A.EffectiveToTimeKey>=@timekey


UPDATE A SET  A.UpgDate=@PROCESSDATE
             ,A.DegReason=NULL
			 ,A.FinalAssetClassAlt_Key=1
			 ,A.FlgDeg='N'
			 ,A.FinalNpaDt=null
             ,A.FlgUpg='U'
			 ,A.AssetClass='STD'
			 FROM BuyoutDetails_Final A
WHERE  ISNULL(A.FlgUpg,'U')='U' 
AND A.EffectiveFromTimeKey<=@timekey and A.EffectiveToTimeKey>=@timekey


/*----------------PROVISION ALT KEY ALL  ACCOUNTS--------------------------------*/

UPDATE A SET PROVISIONALT_KEY=0
from BuyoutDetails_Final  A
where  (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)

--UPDATE A SET A.ProvisionAlt_Key=
--                ( CASE WHEN C.AssetClassShortName='SUB' THEN  @SubStandard--15.0000/15.0000
--				      WHEN C.AssetClassShortName='DB1' THEN  @DoubtfulI--25.0000/25.0000
--					  WHEN C.AssetClassShortName='DB2' THEN  @DoubtfulII--40.0000/40.0000
--					  WHEN C.AssetClassShortName='DB3' THEN  @DoubtfulIII--100.0000/100.0000
--					  WHEN C.AssetClassShortName='LOS' THEN  @Loss--100.0000/100.0000
--					  ELSE 0
--					END)


 ---Condition Modified 13/07/2021 ---
 	/*  PREPARE NPA_DAYS FROM NPA DATE */
	DROP TABLE IF EXISTS #AC_NPA_DAYS
	SELECT BuyoutPartyLoanNo,DATEDIFF(DD,FinalNpaDt,@PROCESSDATE)+1 NPA_DAYS
		INTO  #AC_NPA_DAYS
	FROM BuyoutDetails_Final WHERE FinalAssetClassAlt_Key >1

	UPDATE A 
		SET A.ProvisionAlt_Key=P.ProvisionAlt_Key--A.FinalProvPercentage=D.ProvisionSecured
			,A.FinalProvPercentage=(CASE WHEN A.SecurityValue = 0 THEN P.ProvisionUnSecured
											ELSE P.ProvisionSecured  END)

	FROM BuyoutDetails_Final A
            INNER JOIN DimAssetClass C ON C.AssetClassAlt_Key=isnull(A.FINALASSETCLASSALT_KEY,1)
                    AND (C.EffectiveFromTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey)
            inner JOIN DimProvision_Seg   P
				on (P.EffectiveFromTimeKey<=@TimeKey AND P.EffectiveToTimeKey>=@TimeKey)
                    AND P.ProvisionShortNameEnum=C.AssetClassShortName
					AND P.Segment='BANK'
            INNER JOIN #AC_NPA_DAYS NP
                    ON NP.BuyoutPartyLoanNo=A.BuyoutPartyLoanNo
                    AND NP.NPA_DAYS  BETWEEN P.LowerDPD AND   P.UpperDPD
            WHERE  C.AssetClassGroup='NPA' 

--UPDATE A SET A.ProvisionAlt_Key=D.ProvisionAlt_Key,  --A.FinalProvPercentage=D.ProvisionSecured
--			A.FinalProvPercentage=(CASE WHEN A.SecurityValue = 0 THEN D.ProvisionUnSecured
--											ELSE D.ProvisionSecured  END)
--FROM BuyoutDetails_Final A 
--INNER JOIN DimAssetClass C ON C.AssetClassAlt_Key=isnull(A.FINALASSETCLASSALT_KEY,1) 
--     AND (C.EffectiveFromTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey)
--	 INNER JOIN DimProvision_Seg d
--		ON C.EffectiveFromTimeKey <=@timekey AND C.EffectiveToTimeKey>=@timekey
--		--AND A.DPD BETWEEN d.LowerDPD AND d.UpperDPD
--		--AND c.AssetClassShortName=d.Segment
--		AND c.AssetClassShortName=d.ProvisionShortNameEnum  ------Added on 30/10/2021
--WHERE A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey 
	-- C.ASSETCLASSGROUP='NPA'  AND
	--and d.ProvisionRule='DPD BASED'

  
 ---Condition Modified 13/07/2021 ---

 UPDATE A SET A.ProvisionAlt_Key=(SELECT  ProvisionAlt_Key FROM DimProvision_SegStd WHERE ProvisionName='Other' AND EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
 ,A.FinalProvPercentage=(SELECT  ProvisionSecured FROM DimProvision_SegStd WHERE ProvisionName='Other' AND EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
  FROM BuyoutDetails_Final A 
INNER JOIN DimAssetClass C ON C.AssetClassAlt_Key=isnull(A.FINALASSETCLASSALT_KEY,1) 
     AND (C.EffectiveFromTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey)
WHERE  C.ASSETCLASSGROUP='STD'  AND
 (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)

 
 -----Condition Modified 13/07/2021 ---

 --UPDATE A
	--	SET A.FinalProvPercentage=CAST(CASE WHEN  ISNULL(FinalProvPercentage,0)>ISNULL(PrevProvPercentage,0) 
	--								THEN ISNULL(FinalProvPercentage,0)
	--							ELSE 
	--								ISNULL(PrevProvPercentage,0)
	--							END  AS DECIMAL(5,2))
	--FROM BuyoutDetails_Final a
	--WHERE  FinalAssetClassAlt_Key>1
	-- AND A.EFFECTIVEFROMTIMEKEY<=@TimeKey     AND A.EFFECTIVETOTIMEKEY>=@TimeKey

 /*----------------NetBalance-------------------*/

 UPDATE A         
SET  
		NetBalance = ISNULL(PrincipalOutstanding,0)
FROM BuyoutDetails_Final A 
WHERE A.EffectiveFromTimeKey<=@timekey and A.EffectiveToTimeKey>=@timekey
and FinalAssetClassAlt_Key<>1

UPDATE A         
SET  
		NetBalance = ISNULL(PrincipalOutstanding,0)+ isnull(InterestOverdue,0)
FROM BuyoutDetails_Final A 
WHERE A.EffectiveFromTimeKey<=@timekey and A.EffectiveToTimeKey>=@timekey
and FinalAssetClassAlt_Key=1

 /*----------------ApprRV-------------------*/

 UPDATE A         
SET  
		SecurityValue = ISNULL(SecurityValue,0)
FROM BuyoutDetails_Final A 
WHERE A.EffectiveFromTimeKey<=@timekey and A.EffectiveToTimeKey>=@timekey

UPDATE A         
SET  
		ApprRV = ISNULL(SecurityValue,0)
FROM BuyoutDetails_Final A 
WHERE A.EffectiveFromTimeKey<=@timekey and A.EffectiveToTimeKey>=@timekey

/*----------------USEDRV-------------------*/

 UPDATE A SET A.USEDRV =0
 FROM BuyoutDetails_Final A 
 WHERE (A.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND A.EFFECTIVETOTIMEKEY>=@TIMEKEY)


 UPDATE A SET A.USEDRV =(CASE WHEN ISNULL(C.AssetClassShortNameEnum,'STD')='LOS' 
	                                      THEN 0  
	                                 WHEN ISNULL(A.ApprRV,0) >= A.netbalance 
						                  THEN A.netbalance 
							    ELSE ISNULL(A.ApprRV,0) 
						        END)
      
 FROM BuyoutDetails_Final A 
 INNER JOIN DIMASSETCLASS C ON C.AssetClassAlt_Key=isnull(A.FinalAssetClassAlt_Key,1)
                         AND (C.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND C.EFFECTIVETOTIMEKEY>=@TIMEKEY)
 WHERE (A.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND A.EFFECTIVETOTIMEKEY>=@TIMEKEY)


 


  UPDATE A  SET SECUREDAMT=0 ,PROVSECURED=0
 FROM BuyoutDetails_Final A 
 WHERE (A.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND A.EFFECTIVETOTIMEKEY>=@TIMEKEY)

 UPDATE A 
	SET SECUREDAMT=CASE WHEN ISNULL(B.ASSETCLASSSHORTNAMEENUM,'STD')='LOS' 
	                                          THEN 0
				                    ELSE ISNULL(A.USEDRV,0)
				                    END
	  
	--,PROVSECURED =(CASE WHEN ISNULL(B.ASSETCLASSSHORTNAMEENUM,'STD')='LOS' 
	--			                    THEN 0
	--					    ELSE (ISNULL(A.USEDRV,0) * CASE WHEN C.PROVISIONNAME='Corporate Common' 
	--						THEN ISNULL(C.PROVISIONSECURED,0) ELSE ISNULL(C.PROVISIONSECURED,0)/100 END)  
	--						 END)

	,PROVSECURED =(CASE WHEN ISNULL(B.ASSETCLASSSHORTNAMEENUM,'STD')='LOS' 
				                    THEN 0
						    ELSE (ISNULL(A.USEDRV,0) * CASE WHEN C.PROVISIONNAME='Corporate Common' 
							THEN ISNULL(A.FinalProvPercentage,0) ELSE ISNULL(A.FinalProvPercentage,0)/100 END)  
							 END)
							 
	FROM BuyoutDetails_Final A  
	INNER JOIN DIMASSETCLASS B ON B.EFFECTIVEFROMTIMEKEY<=@TIMEKEY
	                            AND B.EFFECTIVETOTIMEKEY>=@TIMEKEY      
	                            AND ISNULL(A.FINALASSETCLASSALT_KEY,1) =B.ASSETCLASSALT_KEY 
	INNER JOIN DIMPROVISION_SEG C ON C.EFFECTIVEFROMTIMEKEY<=@TIMEKEY
	                          AND C.EFFECTIVETOTIMEKEY>=@TIMEKEY      
	                          AND ISNULL(A.PROVISIONALT_KEY,1) = C.PROVISIONALT_KEY 

	WHERE  FinalAssetClassAlt_Key>1 AND A.EFFECTIVEFROMTIMEKEY<=@TIMEKEY     AND A.EFFECTIVETOTIMEKEY>=@TIMEKEY  

	UPDATE A 
	SET SECUREDAMT=CASE WHEN ISNULL(B.ASSETCLASSSHORTNAMEENUM,'STD')='LOS' 
	                                          THEN 0
				                    ELSE ISNULL(A.USEDRV,0)
				                    END
	  
		 , PROVSECURED =(CASE WHEN ISNULL(B.ASSETCLASSSHORTNAMEENUM,'STD')='LOS' 
				                    THEN 0
						    ELSE (ISNULL(A.USEDRV,0) * CASE WHEN C.PROVISIONNAME='Corporate Common' 
							THEN ISNULL(C.PROVISIONSECURED,0) ELSE ISNULL(C.PROVISIONSECURED,0)/100 END)  
							 END)


	FROM BuyoutDetails_Final A  
	INNER JOIN DIMASSETCLASS B ON B.EFFECTIVEFROMTIMEKEY<=@TIMEKEY
	                            AND B.EFFECTIVETOTIMEKEY>=@TIMEKEY      
	                            AND ISNULL(A.FINALASSETCLASSALT_KEY,1) =B.ASSETCLASSALT_KEY 
	INNER JOIN DimProvision_SegStd C ON C.EFFECTIVEFROMTIMEKEY<=@TIMEKEY
	                          AND C.EFFECTIVETOTIMEKEY>=@TIMEKEY      
	                          AND ISNULL(A.PROVISIONALT_KEY,1) = C.PROVISIONALT_KEY 
	WHERE  FinalAssetClassAlt_Key=1 AND A.EFFECTIVEFROMTIMEKEY<=@TIMEKEY     AND A.EFFECTIVETOTIMEKEY>=@TIMEKEY  
	AND C.ProvisionName='Other'


	UPDATE BuyoutDetails_Final  SET SECUREDAMT=0  WHERE ISNULL(SECUREDAMT,0)<=0 AND EFFECTIVEFROMTIMEKEY<=@TIMEKEY     AND EFFECTIVETOTIMEKEY>=@TIMEKEY  
	UPDATE BuyoutDetails_Final  SET PROVSECURED=0  WHERE ISNULL(PROVSECURED,0)<=0 AND EFFECTIVEFROMTIMEKEY<=@TIMEKEY     AND EFFECTIVETOTIMEKEY>=@TIMEKEY


	UPDATE A  SET PROVUNSECURED=0 
 FROM BuyoutDetails_Final A 
 WHERE (A.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND A.EFFECTIVETOTIMEKEY>=@TIMEKEY)

 UPDATE A 
		

		SET UNSECUREDAMT  = ( CASE WHEN  (ISNULL(A.NETBALANCE,0)-(ISNULL(A.SECUREDAMT,0)))>0 
		                        THEN   ((ISNULL(A.NETBALANCE,0)-(ISNULL(A.SECUREDAMT,0))))
				                  ELSE 0 END )


		,PROVUNSECURED =  (CASE WHEN (ISNULL(A.NETBALANCE,0)-(ISNULL(A.SECUREDAMT,0))) >0 THEN 
		                          (((ISNULL(A.NETBALANCE,0)-(ISNULL(A.SECUREDAMT,0)))) 
								  *  CASE WHEN D.PROVISIONNAME='Corporate Common' THEN ISNULL(D.PROVISIONUNSECURED,0) ELSE ISNULL( D.PROVISIONUNSECURED,0) /100 END)  ELSE 0 END)

		
	FROM  BuyoutDetails_Final A
	INNER JOIN DBO.DIMPROVISION_SEG D ON D.EFFECTIVEFROMTIMEKEY <= @TIMEKEY
	                                AND D.EFFECTIVETOTIMEKEY >= @TIMEKEY
	                                AND ISNULL(A.PROVISIONALT_KEY,1) = D.PROVISIONALT_KEY
	WHERE  FinalAssetClassAlt_Key>1 AND A.EFFECTIVEFROMTIMEKEY<=@TIMEKEY  AND  A.EFFECTIVETOTIMEKEY>=@TIMEKEY  


	UPDATE A 
		
		SET UNSECUREDAMT  = ( CASE WHEN  (ISNULL(A.NETBALANCE,0)-(ISNULL(A.SECUREDAMT,0)))>0 
		                        THEN   ((ISNULL(A.NETBALANCE,0)-(ISNULL(A.SECUREDAMT,0))))
				                  ELSE 0 END )

		

		,PROVUNSECURED =  (CASE WHEN (ISNULL(A.NETBALANCE,0)-(ISNULL(A.SECUREDAMT,0))) >0 THEN 
		                          (((ISNULL(A.NETBALANCE,0)-(ISNULL(A.SECUREDAMT,0)))) *  CASE WHEN D.PROVISIONNAME='Corporate Common' THEN ISNULL(D.PROVISIONUNSECURED,0) ELSE ISNULL( D.PROVISIONUNSECURED,0) /100 END)  ELSE 0 END)

		
							   					
	FROM  BuyoutDetails_Final A 
	INNER JOIN DBO.DimProvision_SegStd D ON D.EFFECTIVEFROMTIMEKEY <= @TIMEKEY
	                                AND D.EFFECTIVETOTIMEKEY >= @TIMEKEY
	                                AND ISNULL(A.PROVISIONALT_KEY,1) = D.PROVISIONALT_KEY
	WHERE FinalAssetClassAlt_Key=1
	AND D.ProvisionName='Other'
	AND A.EFFECTIVEFROMTIMEKEY<=@TIMEKEY  AND  A.EFFECTIVETOTIMEKEY>=@TIMEKEY  


  UPDATE BuyoutDetails_Final SET UNSECUREDAMT=0 WHERE ISNULL(UNSECUREDAMT,0)<=0 AND EFFECTIVEFROMTIMEKEY<=@TIMEKEY     AND EFFECTIVETOTIMEKEY>=@TIMEKEY  
  UPDATE BuyoutDetails_Final SET PROVUNSECURED=0 WHERE ISNULL(PROVUNSECURED,0)<=0 AND EFFECTIVEFROMTIMEKEY<=@TIMEKEY     AND EFFECTIVETOTIMEKEY>=@TIMEKEY  

  
 UPDATE  BuyoutDetails_Final              
 SET TOTALPROVISION = 0
 WHERE  EFFECTIVEFROMTIMEKEY<=@TIMEKEY     AND EFFECTIVETOTIMEKEY>=@TIMEKEY  
  
  UPDATE A      SET    TOTALPROVISION     =(ISNULL(A.PROVSECURED,0) + ISNULL(A.PROVUNSECURED,0)) 
	   FROM  BuyoutDetails_Final    A    
  WHERE  A.EFFECTIVEFROMTIMEKEY<=@TIMEKEY     AND A.EFFECTIVETOTIMEKEY>=@TIMEKEY           
 
 UPDATE BuyoutDetails_Final SET TOTALPROVISION=NetBalance 
 WHERE ISNULL(TOTALPROVISION,0)>NetBalance AND ISNULL(NetBalance,0)>0
 AND  EFFECTIVEFROMTIMEKEY<=@TIMEKEY     AND EFFECTIVETOTIMEKEY>=@TIMEKEY 


 /***********Added on 08/12/2021 by Liyaqat**************/
 
 UPDATE BuyoutDetails_Final SET AssetClass='SMA-0' 
 from BuyoutDetails_Final WHERE FinalAssetClassAlt_Key =1 AND DPD BETWEEN 1 AND 30 AND  EFFECTIVEFROMTIMEKEY<=@TIMEKEY     AND EFFECTIVETOTIMEKEY>=@TIMEKEY 
 UPDATE BuyoutDetails_Final SET AssetClass='SMA-1'
 from BuyoutDetails_Final WHERE FinalAssetClassAlt_Key =1 AND DPD BETWEEN 31 AND 60 AND  EFFECTIVEFROMTIMEKEY<=@TIMEKEY     AND EFFECTIVETOTIMEKEY>=@TIMEKEY 
 UPDATE BuyoutDetails_Final SET AssetClass='SMA-2'
 from BuyoutDetails_Final WHERE FinalAssetClassAlt_Key =1 AND DPD BETWEEN 61 AND 90 AND  EFFECTIVEFROMTIMEKEY<=@TIMEKEY     AND EFFECTIVETOTIMEKEY>=@TIMEKEY 

 OPTION(RECOMPILE)
 

UPDATE PRO.ACLRUNNINGPROCESSSTATUS 
	SET COMPLETED='Y',ERRORDATE=NULL,ERRORDESCRIPTION=NULL,COUNT=ISNULL(COUNT,0)+1
	WHERE RUNNINGPROCESSNAME='BuyoutDataProcessing'

	
	--------------Added for DashBoard 04-03-2021
	Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='ASSET CLASSIFICATION'

	

END TRY
BEGIN  CATCH

	UPDATE PRO.ACLRUNNINGPROCESSSTATUS 
	SET COMPLETED='N',ERRORDATE=GETDATE(),ERRORDESCRIPTION=ERROR_MESSAGE(),COUNT=ISNULL(COUNT,0)+1
	WHERE RUNNINGPROCESSNAME='BuyoutDataProcessing'
END CATCH

END
GO