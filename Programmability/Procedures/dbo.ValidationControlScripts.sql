SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO




CREATE PROCEDURE [dbo].[ValidationControlScripts]
  
AS 

BEGIN
  

DECLARE @TIMEKEY INT = (SELECT TIMEKEY FROM SysDataMatrix WHERE  CurrentStatus='C')
DECLARE @PROCESSINGDATE DATE=(SELECT DATE FROM SYSDAYMATRIX WHERE TIMEKEY=@TIMEKEY) 
DECLARE @ProcessDate DATE=(SELECT DATE FROM SYSDAYMATRIX WHERE TIMEKEY=@TIMEKEY-1) 
Declare @Cost   AS FLOAT=1
DECLARE @SUB_Days INT =(SELECT RefValue FROM PRO.refperiod WHERE BusinessRule='SUB_Days' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
DECLARE @DB1_Days INT =(SELECT RefValue FROM PRO.refperiod WHERE BusinessRule='DB1_Days' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
DECLARE @DB2_Days INT =(SELECT RefValue FROM PRO.refperiod WHERE BusinessRule='DB2_Days' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
DECLARE @MoveToDB1 DECIMAL(5,2) =(SELECT cast(RefValue/100.00 as decimal(5,2))FROM PRO.refperiod where BusinessRule='MoveToDB1' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
DECLARE @MoveToLoss DECIMAL(5,2)=(SELECT cast(RefValue/100.00 as decimal(5,2)) FROM PRO.refperiod where BusinessRule='MoveToLoss' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
DECLARE @SETID INT =(SELECT ISNULL(MAX(ISNULL(SETID,0)),0)+1 FROM [PRO].[PROCESSMONITOR] WHERE TIMEKEY=@TIMEKEY)

INSERT INTO PRO.PROCESSMONITOR(USERID,DESCRIPTION,MODE,STARTTIME,ENDTIME,TIMEKEY,SETID)
SELECT ORIGINAL_LOGIN(),'INSERT DATA FOR ValidationControlScripts','RUNNING',GETDATE(),NULL,@TIMEKEY,@SETID


--------------------1. Completeness of the data flowing in the ENPA system--------------------


--------------------2. Exceptional Standard Facilities 90--------------------

Delete from ControlScripts where ExceptionCode=2 and 
 ExceptionDescription='Exceptional Standard Facilities 90'  and EffectiveFromTimeKey=(select timekey from SysDataMatrix where CurrentStatus='C')

Insert into ControlScripts
(
UCIF_ID
,PANNO
,CustomerAcID
,RefCustomerID
,SourceSystemCustomerID
,CustomerName
,SourceName
,DPD_Max
,POS
,BalanceInCrncy
,Balance
,SysNPA_Dt
,FinalAssetClassName
,ExceptionCode
,ExceptionDescription
,EffectiveFromTimeKey
,EffectiveToTimeKey
)

SELECT  
CH.UCIF_ID
,CH.PanNO
,AH.CustomerAcID
,AH.RefCustomerID
,AH.SourceSystemCustomerID
,CH.CustomerName
,DB.SourceName
,AH.DPD_Max
,case  when ISNULL(AH.PrincOutStd,0)<0 then 0 else ISNULL(AH.PrincOutStd,0) end/@cost  AS POS
,case when ISNULL(AH.BalanceInCrncy,0)<0 then 0 else ISNULL (AH.BalanceInCrncy,0)end /@cost     AS BalanceInCrncy
,case when ISNULL(AH.Balance,0)<0 then 0 else  ISNULL(AH.Balance,0)end/@cost     AS Balance
,CONVERT(VARCHAR(20),CH.SysNPA_Dt,103)                AS SysNPA_Dt
,DA.AssetClassShortName                          AS FinalAssetClassName
,2 AS ExceptionCode
,'Exceptional Standard Facilities 90'  AS ExceptionDescription
,AH.EffectiveFromTimeKey
,AH.EffectiveToTimeKey
FROM PRO.CUSTOMERCAL CH
              
INNER JOIN PRO.ACCOUNTCAL      AH                  ON CH.SourceSystemCustomerID=AH.SourceSystemCustomerID AND
														  AH.EffectiveFromTimeKey<=@Timekey AND
														  AH.EffectiveToTimeKey>=@Timekey AND
														  CH.EffectiveFromTimeKey<=@Timekey AND
		                                                  CH.EffectiveToTimeKey>=@Timekey

INNER JOIN DimsourceDB  DB                             ON DB.SourceAlt_Key=AH.SourceAlt_Key AND
                                                           DB.EffectiveFromTimeKey<=@Timekey AND
													       DB.EffectiveToTimeKey>=@Timekey

INNER JOIN DimAssetClass DA                            ON  DA.AssetClassAlt_Key= AH.FinalAssetClassAlt_Key AND 
                                                           DA.EffectiveFromTimeKey<=@Timekey AND
													       DA.EffectiveToTimeKey>=@Timekey

INNER JOIN DimAssetClass                               ON  DimAssetClass.AssetClassAlt_Key= AH.InitialAssetClassAlt_Key AND 
                                                            DimAssetClass.EffectiveFromTimeKey<=@Timekey AND
													        DimAssetClass.EffectiveToTimeKey>=@Timekey

LEFT  JOIN DimProduct                                  ON DimProduct.ProductAlt_Key=AH.ProductAlt_Key AND 
                                                           DimProduct.EffectiveFromTimeKey<=@Timekey AND
													       DimProduct.EffectiveToTimeKey>=@Timekey

LEFT JOIN DimCurrency                                  ON  DimCurrency.CurrencyAlt_Key= AH.CurrencyAlt_Key	AND
			                                               DimCurrency.EffectiveFromTimeKey<=@Timekey AND
														   DimCurrency.EffectiveToTimeKey>=@Timekey
where DPD_Max>90
AND Ah.FinalAssetClassAlt_Key=1
and Ah.Asset_Norm<>'ALWYS_STD'
AND ISNULL(DimProduct.PRODUCTGROUP,'N')<>'KCC'

--------------------2. Exceptional Standard Facilities 90--------------------

--------------------2. Exceptional Standard Facilities 365--------------------


Delete from ControlScripts
where ExceptionCode=2 and ExceptionDescription='Exceptional Standard Facilities 365' 
and EffectiveFromTimeKey=(select timekey from SysDataMatrix where CurrentStatus='C')

Insert into ControlScripts
(
UCIF_ID
,PANNO
,CustomerAcID
,RefCustomerID
,SourceSystemCustomerID
,CustomerName
,SourceName
,DPD_Max
,POS
,BalanceInCrncy
,Balance
,SysNPA_Dt
,FinalAssetClassName
,ExceptionCode
,ExceptionDescription
,EffectiveFromTimeKey
,EffectiveToTimeKey
)

SELECT  
CH.UCIF_ID
,CH.PanNO
,AH.CustomerAcID
,AH.RefCustomerID
,AH.SourceSystemCustomerID
,CH.CustomerName
,DB.SourceName
,AH.DPD_Max
,case  when ISNULL(AH.PrincOutStd,0)<0 then 0 else ISNULL(AH.PrincOutStd,0) end/@cost  AS POS
,case when ISNULL(AH.BalanceInCrncy,0)<0 then 0 else ISNULL (AH.BalanceInCrncy,0)end /@cost     AS BalanceInCrncy
,case when ISNULL(AH.Balance,0)<0 then 0 else  ISNULL(AH.Balance,0)end/@cost     AS Balance
,CONVERT(VARCHAR(20),CH.SysNPA_Dt,103)                AS SysNPA_Dt
,DA.AssetClassShortName                          AS FinalAssetClassName
,2 AS ExceptionCode
,'Exceptional Standard Facilities 365'  AS ExceptionDescription
,AH.EffectiveFromTimeKey
,AH.EffectiveToTimeKey
FROM PRO.CUSTOMERCAL CH
              
INNER JOIN PRO.ACCOUNTCAL      AH                  ON CH.SourceSystemCustomerID=AH.SourceSystemCustomerID AND
														  AH.EffectiveFromTimeKey<=@Timekey AND
														  AH.EffectiveToTimeKey>=@Timekey AND
														  CH.EffectiveFromTimeKey<=@Timekey AND
		                                                  CH.EffectiveToTimeKey>=@Timekey

INNER JOIN DimsourceDB  DB                             ON DB.SourceAlt_Key=AH.SourceAlt_Key AND
                                                           DB.EffectiveFromTimeKey<=@Timekey AND
													       DB.EffectiveToTimeKey>=@Timekey

INNER JOIN DimAssetClass DA                            ON  DA.AssetClassAlt_Key= AH.FinalAssetClassAlt_Key AND 
                                                           DA.EffectiveFromTimeKey<=@Timekey AND
													       DA.EffectiveToTimeKey>=@Timekey

INNER JOIN DimAssetClass                               ON  DimAssetClass.AssetClassAlt_Key= AH.InitialAssetClassAlt_Key AND 
                                                            DimAssetClass.EffectiveFromTimeKey<=@Timekey AND
													        DimAssetClass.EffectiveToTimeKey>=@Timekey

LEFT  JOIN DimProduct                                  ON DimProduct.ProductAlt_Key=AH.ProductAlt_Key AND 
                                                           DimProduct.EffectiveFromTimeKey<=@Timekey AND
													       DimProduct.EffectiveToTimeKey>=@Timekey

LEFT JOIN DimCurrency                                  ON  DimCurrency.CurrencyAlt_Key= AH.CurrencyAlt_Key	AND
			                                               DimCurrency.EffectiveFromTimeKey<=@Timekey AND
														   DimCurrency.EffectiveToTimeKey>=@Timekey
where DPD_Max>365
AND Ah.FinalAssetClassAlt_Key=1
and Ah.Asset_Norm<>'ALWYS_STD'
AND ISNULL(DimProduct.PRODUCTGROUP,'N')='KCC'


--------------------2. Exceptional Standard Facilities 365--------------------


------------------3. Exceptional NPA Facilities------------------


Delete from ControlScripts
where ExceptionCode=3 
and EffectiveFromTimeKey=(select timekey from SysDataMatrix where CurrentStatus='C')

Insert into ControlScripts
(
UCIF_ID
,PANNO
,CustomerAcID
,RefCustomerID
,SourceSystemCustomerID
,CustomerName
,SourceName
,DPD_Max
,POS
,BalanceInCrncy
,Balance
,SysNPA_Dt
,FinalAssetClassName
,ExceptionCode
,ExceptionDescription
,EffectiveFromTimeKey
,EffectiveToTimeKey

)

SELECT  
CH.UCIF_ID
,CH.PanNO
,AH.CustomerAcID
,AH.RefCustomerID
,AH.SourceSystemCustomerID
,CH.CustomerName
,DB.SourceName
,AH.DPD_Max
,case when ISNULL(AH.PrincOutStd,0)<0 then 0 else ISNULL(AH.PrincOutStd,0) end/@cost  AS POS
,case when ISNULL(AH.BalanceInCrncy,0)<0 then 0 else ISNULL (AH.BalanceInCrncy,0)end /@cost     AS BalanceInCrncy
,case when ISNULL(AH.Balance,0)<0 then 0 else  ISNULL(AH.Balance,0)end/@cost     AS Balance
,CONVERT(VARCHAR(20),CH.SysNPA_Dt,103)                AS SysNPA_Dt
,DA.AssetClassShortName                          AS FinalAssetClassName
,3 AS ExceptionCode
,'Exceptional NPA Facilities'  AS ExceptionDescription
,AH.EffectiveFromTimeKey
,AH.EffectiveToTimeKey

FROM PRO.CUSTOMERCAL CH
              
INNER JOIN PRO.ACCOUNTCAL      AH                  ON CH.SourceSystemCustomerID=AH.SourceSystemCustomerID AND
														  AH.EffectiveFromTimeKey<=@Timekey AND
														  AH.EffectiveToTimeKey>=@Timekey AND
														  CH.EffectiveFromTimeKey<=@Timekey AND
		                                                  CH.EffectiveToTimeKey>=@Timekey

INNER JOIN DimsourceDB  DB                             ON DB.SourceAlt_Key=AH.SourceAlt_Key AND
                                                           DB.EffectiveFromTimeKey<=@Timekey AND
													       DB.EffectiveToTimeKey>=@Timekey

INNER JOIN DimAssetClass DA                            ON  DA.AssetClassAlt_Key= AH.FinalAssetClassAlt_Key AND 
                                                           DA.EffectiveFromTimeKey<=@Timekey AND
													       DA.EffectiveToTimeKey>=@Timekey

INNER JOIN DimAssetClass                               ON  DimAssetClass.AssetClassAlt_Key= AH.InitialAssetClassAlt_Key AND 
                                                            DimAssetClass.EffectiveFromTimeKey<=@Timekey AND
													        DimAssetClass.EffectiveToTimeKey>=@Timekey

LEFT  JOIN DimProduct                                  ON DimProduct.ProductAlt_Key=AH.ProductAlt_Key AND 
                                                           DimProduct.EffectiveFromTimeKey<=@Timekey AND
													       DimProduct.EffectiveToTimeKey>=@Timekey

LEFT JOIN DimCurrency                                  ON  DimCurrency.CurrencyAlt_Key= AH.CurrencyAlt_Key	AND
			                                               DimCurrency.EffectiveFromTimeKey<=@Timekey AND
														   DimCurrency.EffectiveToTimeKey>=@Timekey
where DPD_Max<=90
AND Ah.FinalAssetClassAlt_Key>1
and Ah.Asset_Norm<>'ALWYS_NPA' and AH.DegReason NOT LIKE '%Percolation%'

------------------3. Exceptional NPA Facilities------------------



------------------4. Fresh Slippages Not tagged as Sub Standard------------------ 


Delete from ControlScripts
where ExceptionCode=4 
and EffectiveFromTimeKey=(select timekey from SysDataMatrix where CurrentStatus='C')

Insert into ControlScripts
(
UCIF_ID
,PANNO
,CustomerAcID
,RefCustomerID
,SourceSystemCustomerID
,CustomerName
,SourceName
,DPD_Max
,POS
,BalanceInCrncy
,Balance
,SysNPA_Dt
,FinalAssetClassName
,ExceptionCode
,ExceptionDescription
,EffectiveFromTimeKey
,EffectiveToTimeKey

)

SELECT  
CH.UCIF_ID
,CH.PanNO
,AH.CustomerAcID
,AH.RefCustomerID
,AH.SourceSystemCustomerID
,CH.CustomerName
,DB.SourceName
,AH.DPD_Max
,case when ISNULL(AH.PrincOutStd,0)<0 then 0 else ISNULL(AH.PrincOutStd,0) end/@cost  AS POS
,case when ISNULL(AH.BalanceInCrncy,0)<0 then 0 else ISNULL (AH.BalanceInCrncy,0)end /@cost     AS BalanceInCrncy
,case when ISNULL(AH.Balance,0)<0 then 0 else  ISNULL(AH.Balance,0)end/@cost     AS Balance
,CONVERT(VARCHAR(20),CH.SysNPA_Dt,103)                AS SysNPA_Dt
,DA.AssetClassShortName                          AS FinalAssetClassName
,4 AS ExceptionCode
,'Fresh Slippages Not tagged as Sub Standard'  AS ExceptionDescription
,AH.EffectiveFromTimeKey
,AH.EffectiveToTimeKey
FROM PRO.CUSTOMERCAL CH
              
INNER JOIN PRO.ACCOUNTCAL      AH                  ON CH.SourceSystemCustomerID=AH.SourceSystemCustomerID AND
														  AH.EffectiveFromTimeKey<=@Timekey AND
														  AH.EffectiveToTimeKey>=@Timekey AND
														  CH.EffectiveFromTimeKey<=@Timekey AND
		                                                  CH.EffectiveToTimeKey>=@Timekey

INNER JOIN DimsourceDB  DB                             ON DB.SourceAlt_Key=AH.SourceAlt_Key AND
                                                           DB.EffectiveFromTimeKey<=@Timekey AND
													       DB.EffectiveToTimeKey>=@Timekey

INNER JOIN DimAssetClass DA                            ON  DA.AssetClassAlt_Key= AH.FinalAssetClassAlt_Key AND 
                                                           DA.EffectiveFromTimeKey<=@Timekey AND
													       DA.EffectiveToTimeKey>=@Timekey

INNER JOIN DimAssetClass                               ON  DimAssetClass.AssetClassAlt_Key= AH.InitialAssetClassAlt_Key AND 
                                                            DimAssetClass.EffectiveFromTimeKey<=@Timekey AND
													        DimAssetClass.EffectiveToTimeKey>=@Timekey

LEFT  JOIN DimProduct                                  ON DimProduct.ProductAlt_Key=AH.ProductAlt_Key AND 
                                                           DimProduct.EffectiveFromTimeKey<=@Timekey AND
													       DimProduct.EffectiveToTimeKey>=@Timekey

LEFT JOIN DimCurrency                                  ON  DimCurrency.CurrencyAlt_Key= AH.CurrencyAlt_Key	AND
			                                               DimCurrency.EffectiveFromTimeKey<=@Timekey AND
														   DimCurrency.EffectiveToTimeKey>=@Timekey
where CH.FlgDeg='Y'
AND AH.FinalAssetClassAlt_Key  IN (3,4,5,6)

------------------4. Fresh Slippages Not tagged as Sub Standard------------------ 

------------------------5. Exceptional aging of NPA facilities------------------


Delete from ControlScripts
where ExceptionCode=5 
and EffectiveFromTimeKey=(select timekey from SysDataMatrix where CurrentStatus='C')


Insert into ControlScripts
(
UCIF_ID
,PANNO
,CustomerAcID
,RefCustomerID
,SourceSystemCustomerID
,CustomerName
,SourceName
,DPD_Max
,POS
,BalanceInCrncy
,Balance
,SysNPA_Dt
,FinalAssetClassName
,ExceptionCode
,ExceptionDescription
,EffectiveFromTimeKey
,EffectiveToTimeKey

)


SELECT  
CH.UCIF_ID
,CH.PanNO
,AH.CustomerAcID
,AH.RefCustomerID
,AH.SourceSystemCustomerID
,CH.CustomerName
,DB.SourceName
,AH.DPD_Max
,case when ISNULL(AH.PrincOutStd,0)<0 then 0 else ISNULL(AH.PrincOutStd,0) end/@cost  AS POS
,case when ISNULL(AH.BalanceInCrncy,0)<0 then 0 else ISNULL (AH.BalanceInCrncy,0)end /@cost     AS BalanceInCrncy
,case when ISNULL(AH.Balance,0)<0 then 0 else  ISNULL(AH.Balance,0)end/@cost     AS Balance
,CONVERT(VARCHAR(20),CH.SysNPA_Dt,103)                AS SysNPA_Dt
,DA.AssetClassShortName                          AS FinalAssetClassName
,5 AS ExceptionCode
,'Exceptional aging of NPA facilities'  AS ExceptionDescription
,AH.EffectiveFromTimeKey
,AH.EffectiveToTimeKey
FROM PRO.CUSTOMERCAL CH
              
INNER JOIN PRO.ACCOUNTCAL      AH                  ON CH.SourceSystemCustomerID=AH.SourceSystemCustomerID AND
														  AH.EffectiveFromTimeKey<=@Timekey AND
														  AH.EffectiveToTimeKey>=@Timekey AND
														  CH.EffectiveFromTimeKey<=@Timekey AND
		                                                  CH.EffectiveToTimeKey>=@Timekey

INNER JOIN DimsourceDB  DB                             ON DB.SourceAlt_Key=AH.SourceAlt_Key AND
                                                           DB.EffectiveFromTimeKey<=@Timekey AND
													       DB.EffectiveToTimeKey>=@Timekey

INNER JOIN DimAssetClass DA                            ON  DA.AssetClassAlt_Key= AH.FinalAssetClassAlt_Key AND 
                                                           DA.EffectiveFromTimeKey<=@Timekey AND
													       DA.EffectiveToTimeKey>=@Timekey

INNER JOIN DimAssetClass                               ON  DimAssetClass.AssetClassAlt_Key= AH.InitialAssetClassAlt_Key AND 
                                                            DimAssetClass.EffectiveFromTimeKey<=@Timekey AND
													        DimAssetClass.EffectiveToTimeKey>=@Timekey

LEFT  JOIN DimProduct                                  ON DimProduct.ProductAlt_Key=AH.ProductAlt_Key AND 
                                                           DimProduct.EffectiveFromTimeKey<=@Timekey AND
													       DimProduct.EffectiveToTimeKey>=@Timekey

LEFT JOIN DimCurrency                                  ON  DimCurrency.CurrencyAlt_Key= AH.CurrencyAlt_Key	AND
			                                               DimCurrency.EffectiveFromTimeKey<=@Timekey AND
														   DimCurrency.EffectiveToTimeKey>=@Timekey

where  AH.FinalAssetClassAlt_Key  IN (2,3,4,5)
and ( 
SysAssetClassAlt_Key=2 and DATEDIFF(DAY,SysNPA_Dt,@PROCESSINGDATE)>365 
or(SysAssetClassAlt_Key=3 and DATEDIFF(DAY,SysNPA_Dt,@PROCESSINGDATE)<365 ) 
or(SysAssetClassAlt_Key=4 and DATEDIFF(DAY,SysNPA_Dt,@PROCESSINGDATE)<730 ) 
or(SysAssetClassAlt_Key=5 and DATEDIFF(DAY,SysNPA_Dt,@PROCESSINGDATE)<1460 ) 
)

------------------------5. Exceptional aging of NPA facilities------------------




------------------6. Customers having Multiple NPA date in different facilities across Customer ID & PAN------------------


Delete from ControlScripts
where ExceptionCode=6
and EffectiveFromTimeKey=(select timekey from SysDataMatrix where CurrentStatus='C')

IF OBJECT_ID('TEMPDB..#TempTableNpaCustomers') IS NOT NULL
  DROP TABLE #TempTableNpaCustomers

	SELECT UCIF_ID,RefCustomerID,SourceSystemCustomerID,PANNO,SysAssetClassAlt_Key,SysNPA_Dt
	 INTO #TempTableNpaCustomers FROM PRO.CUSTOMERCAL A
	  INNER JOIN DIMSOURCEDB  B ON B.SOURCEALT_KEY=A.SOURCEALT_KEY 
	  AND	A.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND A.EFFECTIVETOTIMEKEY>=@TIMEKEY
	   AND B.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND B.EFFECTIVETOTIMEKEY>=@TIMEKEY
	  WHERE  ISNULL(SYSASSETCLASSALT_KEY,1)<>1
	 GROUP BY  UCIF_ID,RefCustomerID,SourceSystemCustomerID,PANNO,SysAssetClassAlt_Key,SysNPA_Dt

IF OBJECT_ID('TEMPDB..#DuplicateNpaDt') IS NOT NULL
  DROP TABLE #DuplicateNpaDt

	 
select A.SourceSystemCustomerID 
Into #DuplicateNpaDt
from #TempTableNpaCustomers A
INNER JOIN #TempTableNpaCustomers B
ON A.SourceSystemCustomerID=B.SourceSystemCustomerID
AND A.SysNPA_Dt<>B.SysNPA_Dt
UNION
select A.SourceSystemCustomerID  from #TempTableNpaCustomers A
INNER JOIN #TempTableNpaCustomers B
ON A.PANNO=B.PANNO
AND A.SysNPA_Dt<>B.SysNPA_Dt
WHERE A.PANNO IS NOT NULL AND B.PANNO IS NOT NULL


Insert into ControlScripts
(
UCIF_ID
,PANNO
,CustomerAcID
,RefCustomerID
,SourceSystemCustomerID
,CustomerName
,SourceName
,DPD_Max
,POS
,BalanceInCrncy
,Balance
,SysNPA_Dt
,FinalAssetClassName
,ExceptionCode
,ExceptionDescription
,EffectiveFromTimeKey
,EffectiveToTimeKey

)


SELECT  
CH.UCIF_ID
,CH.PanNO
,AH.CustomerAcID
,AH.RefCustomerID
,AH.SourceSystemCustomerID
,CH.CustomerName
,DB.SourceName
,AH.DPD_Max
,case when ISNULL(AH.PrincOutStd,0)<0 then 0 else ISNULL(AH.PrincOutStd,0) end/@cost  AS POS
,case when ISNULL(AH.BalanceInCrncy,0)<0 then 0 else ISNULL (AH.BalanceInCrncy,0)end /@cost     AS BalanceInCrncy
,case when ISNULL(AH.Balance,0)<0 then 0 else  ISNULL(AH.Balance,0)end/@cost     AS Balance
,CONVERT(VARCHAR(20),CH.SysNPA_Dt,103)                AS SysNPA_Dt
,DA.AssetClassShortName                          AS FinalAssetClassName
,6 AS ExceptionCode
,'Customers having Multiple NPA date in different facilities across Customer ID & PAN'  AS ExceptionDescription
,AH.EffectiveFromTimeKey
,AH.EffectiveToTimeKey
FROM PRO.CUSTOMERCAL CH
              
INNER JOIN PRO.ACCOUNTCAL      AH                  ON CH.SourceSystemCustomerID=AH.SourceSystemCustomerID AND
														  AH.EffectiveFromTimeKey<=@Timekey AND
														  AH.EffectiveToTimeKey>=@Timekey AND
														  CH.EffectiveFromTimeKey<=@Timekey AND
		                                                  CH.EffectiveToTimeKey>=@Timekey

INNER JOIN DimsourceDB  DB                             ON DB.SourceAlt_Key=AH.SourceAlt_Key AND
                                                           DB.EffectiveFromTimeKey<=@Timekey AND
													       DB.EffectiveToTimeKey>=@Timekey

INNER JOIN DimAssetClass DA                            ON  DA.AssetClassAlt_Key= AH.FinalAssetClassAlt_Key AND 
                                                           DA.EffectiveFromTimeKey<=@Timekey AND
													       DA.EffectiveToTimeKey>=@Timekey

INNER JOIN DimAssetClass                               ON  DimAssetClass.AssetClassAlt_Key= AH.InitialAssetClassAlt_Key AND 
                                                            DimAssetClass.EffectiveFromTimeKey<=@Timekey AND
													        DimAssetClass.EffectiveToTimeKey>=@Timekey

inner join  #DuplicateNpaDt on #DuplicateNpaDt.SourceSystemCustomerID=CH.SourceSystemCustomerID 

LEFT  JOIN DimProduct                                  ON DimProduct.ProductAlt_Key=AH.ProductAlt_Key AND 
                                                           DimProduct.EffectiveFromTimeKey<=@Timekey AND
													       DimProduct.EffectiveToTimeKey>=@Timekey

LEFT JOIN DimCurrency                                  ON  DimCurrency.CurrencyAlt_Key= AH.CurrencyAlt_Key	AND
			                                               DimCurrency.EffectiveFromTimeKey<=@Timekey AND
														   DimCurrency.EffectiveToTimeKey>=@Timekey
where  AH.FinalAssetClassAlt_Key  IN (2,3,4,5,6)

------------------6. Customers having Multiple NPA date in different facilities across Customer ID & PAN------------------

------------------7. Customers having different asset class in different facilities across Customer ID & PAN------------------ 


Delete from ControlScripts
where ExceptionCode=7 
and EffectiveFromTimeKey=(select timekey from SysDataMatrix where CurrentStatus='C')

IF OBJECT_ID('TEMPDB..#TempTableCustomersAsset') IS NOT NULL
  DROP TABLE #TempTableCustomersAsset

	SELECT UCIF_ID,RefCustomerID,SourceSystemCustomerID,PANNO,SysAssetClassAlt_Key,SysNPA_Dt
	 INTO #TempTableCustomersAsset FROM PRO.CUSTOMERCAL A
	  INNER JOIN DIMSOURCEDB  B ON B.SOURCEALT_KEY=A.SOURCEALT_KEY 
	  AND A.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND A.EFFECTIVETOTIMEKEY>=@TIMEKEY
	   AND	B.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND B.EFFECTIVETOTIMEKEY>=@TIMEKEY
	 -- WHERE  ISNULL(SYSASSETCLASSALT_KEY,1)<>1
	 GROUP BY  UCIF_ID,RefCustomerID,SourceSystemCustomerID,PANNO,SysAssetClassAlt_Key,SysNPA_Dt

IF OBJECT_ID('TEMPDB..#DuplicateAssetClass') IS NOT NULL
  DROP TABLE #DuplicateAssetClass

select A.SourceSystemCustomerID 
Into #DuplicateAssetClass from #TempTableCustomersAsset A
INNER JOIN #TempTableCustomersAsset B
ON A.SourceSystemCustomerID=B.SourceSystemCustomerID
AND A.SysAssetClassAlt_Key<>B.SysAssetClassAlt_Key
union
select A.SourceSystemCustomerID from #TempTableCustomersAsset A
INNER JOIN #TempTableCustomersAsset B
ON A.PANNO=B.PANNO
AND A.SysAssetClassAlt_Key<>B.SysAssetClassAlt_Key
WHERE A.PANNO IS NOT NULL AND B.PANNO IS NOT NULL 

Insert into ControlScripts
(
UCIF_ID
,PANNO
,CustomerAcID
,RefCustomerID
,SourceSystemCustomerID
,CustomerName
,SourceName
,DPD_Max
,POS
,BalanceInCrncy
,Balance
,SysNPA_Dt
,FinalAssetClassName
,ExceptionCode
,ExceptionDescription
,EffectiveFromTimeKey
,EffectiveToTimeKey

)


SELECT  
CH.UCIF_ID
,CH.PanNO
,AH.CustomerAcID
,AH.RefCustomerID
,AH.SourceSystemCustomerID
,CH.CustomerName
,DB.SourceName
,AH.DPD_Max
,case when ISNULL(AH.PrincOutStd,0)<0 then 0 else ISNULL(AH.PrincOutStd,0) end/@cost  AS POS
,case when ISNULL(AH.BalanceInCrncy,0)<0 then 0 else ISNULL (AH.BalanceInCrncy,0)end /@cost     AS BalanceInCrncy
,case when ISNULL(AH.Balance,0)<0 then 0 else  ISNULL(AH.Balance,0)end/@cost     AS Balance
,CONVERT(VARCHAR(20),CH.SysNPA_Dt,103)                AS SysNPA_Dt
,DA.AssetClassShortName                          AS FinalAssetClassName
,7 AS ExceptionCode
,'Customers having different asset class in different facilities across Customer ID & PAN'  AS ExceptionDescription
,AH.EffectiveFromTimeKey
,AH.EffectiveToTimeKey
FROM PRO.CUSTOMERCAL CH
              
INNER JOIN PRO.ACCOUNTCAL     AH                  ON CH.SourceSystemCustomerID=AH.SourceSystemCustomerID AND
														  AH.EffectiveFromTimeKey<=@Timekey AND
														  AH.EffectiveToTimeKey>=@Timekey AND
														  CH.EffectiveFromTimeKey<=@Timekey AND
		                                                  CH.EffectiveToTimeKey>=@Timekey

INNER JOIN DimsourceDB  DB                             ON DB.SourceAlt_Key=AH.SourceAlt_Key AND
                                                           DB.EffectiveFromTimeKey<=@Timekey AND
													       DB.EffectiveToTimeKey>=@Timekey

INNER JOIN DimAssetClass DA                            ON  DA.AssetClassAlt_Key= AH.FinalAssetClassAlt_Key AND 
                                                           DA.EffectiveFromTimeKey<=@Timekey AND
													       DA.EffectiveToTimeKey>=@Timekey

INNER JOIN DimAssetClass                               ON  DimAssetClass.AssetClassAlt_Key= AH.InitialAssetClassAlt_Key AND 
                                                            DimAssetClass.EffectiveFromTimeKey<=@Timekey AND
													        DimAssetClass.EffectiveToTimeKey>=@Timekey
inner join  #DuplicateAssetClass on #DuplicateAssetClass.SourceSystemCustomerID=CH.SourceSystemCustomerID 

LEFT  JOIN DimProduct                                  ON DimProduct.ProductAlt_Key=AH.ProductAlt_Key AND 
                                                           DimProduct.EffectiveFromTimeKey<=@Timekey AND
													       DimProduct.EffectiveToTimeKey>=@Timekey

LEFT JOIN DimCurrency                                  ON  DimCurrency.CurrencyAlt_Key= AH.CurrencyAlt_Key	AND
			                                               DimCurrency.EffectiveFromTimeKey<=@Timekey AND
														   DimCurrency.EffectiveToTimeKey>=@Timekey
--where  AH.FinalAssetClassAlt_Key  IN (2)

------------------7. Customers having different asset class in different facilities across Customer ID & PAN------------------ 


------------------8. Customers appearing in slippage & upgradation on same date------------------

Delete from ControlScripts
where ExceptionCode=8 
and EffectiveFromTimeKey=(select timekey from SysDataMatrix where CurrentStatus='C')

IF OBJECT_ID('TEMPDB..#TempTableFreshSillapge') IS NOT NULL
  DROP TABLE #TempTableFreshSillapge

	SELECT UCIF_ID,RefCustomerID,SourceSystemCustomerID,CustomerAcID
	 INTO #TempTableFreshSillapge FROM PRO.AccountCal Ah
	  INNER JOIN DIMSOURCEDB  B ON B.SOURCEALT_KEY=Ah.SOURCEALT_KEY 
	  AND Ah.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND Ah.EFFECTIVETOTIMEKEY>=@TIMEKEY
	  AND B.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND B.EFFECTIVETOTIMEKEY>=@TIMEKEY
	  WHERE  Ah.FlgDeg='Y'
	 
	 IF OBJECT_ID('TEMPDB..#TempTableUpgrade') IS NOT NULL
		DROP TABLE #TempTableUpgrade

	SELECT UCIF_ID,RefCustomerID,SourceSystemCustomerID,CustomerAcID
	 INTO #TempTableUpgrade FROM PRO.AccountCal Ah
	  INNER JOIN DIMSOURCEDB  B ON B.SOURCEALT_KEY=Ah.SOURCEALT_KEY 
	  AND Ah.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND Ah.EFFECTIVETOTIMEKEY>=@TIMEKEY
	  AND B.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND B.EFFECTIVETOTIMEKEY>=@TIMEKEY
	  WHERE  Ah.FlgUpg='U'

	  IF OBJECT_ID('TEMPDB..#TempTableFreshSillapgeUpgrade') IS NOT NULL
		DROP TABLE #TempTableFreshSillapgeUpgrade

	  SELECT A.CustomerAcID INTO #TempTableFreshSillapgeUpgrade
	   FROM #TempTableFreshSillapge A
	  INNER JOIN #TempTableUpgrade B
	  ON A.CustomerAcID=B.CustomerAcID

	  
Insert into ControlScripts
(
UCIF_ID
,PANNO
,CustomerAcID
,RefCustomerID
,SourceSystemCustomerID
,CustomerName
,SourceName
,DPD_Max
,POS
,BalanceInCrncy
,Balance
,SysNPA_Dt
,FinalAssetClassName
,ExceptionCode
,ExceptionDescription
,EffectiveFromTimeKey
,EffectiveToTimeKey

)

SELECT  
CH.UCIF_ID
,CH.PanNO
,AH.CustomerAcID
,AH.RefCustomerID
,AH.SourceSystemCustomerID
,CH.CustomerName
,DB.SourceName
,AH.DPD_Max
,case when ISNULL(AH.PrincOutStd,0)<0 then 0 else ISNULL(AH.PrincOutStd,0) end/@cost  AS POS
,case when ISNULL(AH.BalanceInCrncy,0)<0 then 0 else ISNULL (AH.BalanceInCrncy,0)end /@cost     AS BalanceInCrncy
,case when ISNULL(AH.Balance,0)<0 then 0 else  ISNULL(AH.Balance,0)end/@cost     AS Balance
,CONVERT(VARCHAR(20),CH.SysNPA_Dt,103)                AS SysNPA_Dt
,DA.AssetClassShortName                          AS FinalAssetClassName
,8 AS ExceptionCode
,'Customers appearing in slippage & upgradation on same date'  AS ExceptionDescription
,AH.EffectiveFromTimeKey
,AH.EffectiveToTimeKey
FROM PRO.CUSTOMERCAL CH
              
INNER JOIN PRO.ACCOUNTCAL      AH                  ON CH.SourceSystemCustomerID=AH.SourceSystemCustomerID AND
														  AH.EffectiveFromTimeKey<=@Timekey AND
														  AH.EffectiveToTimeKey>=@Timekey AND
														  CH.EffectiveFromTimeKey<=@Timekey AND
		                                                  CH.EffectiveToTimeKey>=@Timekey
INNER JOIN #TempTableFreshSillapgeUpgrade SU ON SU.CustomerAcID=AH.CustomerAcID
INNER JOIN DimsourceDB  DB                             ON DB.SourceAlt_Key=AH.SourceAlt_Key AND
                                                           DB.EffectiveFromTimeKey<=@Timekey AND
													       DB.EffectiveToTimeKey>=@Timekey

INNER JOIN DimAssetClass DA                            ON  DA.AssetClassAlt_Key= AH.FinalAssetClassAlt_Key AND 
                                                           DA.EffectiveFromTimeKey<=@Timekey AND
													       DA.EffectiveToTimeKey>=@Timekey

INNER JOIN DimAssetClass                               ON  DimAssetClass.AssetClassAlt_Key= AH.InitialAssetClassAlt_Key AND 
                                                            DimAssetClass.EffectiveFromTimeKey<=@Timekey AND
													        DimAssetClass.EffectiveToTimeKey>=@Timekey

LEFT  JOIN DimProduct                                  ON DimProduct.ProductAlt_Key=AH.ProductAlt_Key AND 
                                                           DimProduct.EffectiveFromTimeKey<=@Timekey AND
													       DimProduct.EffectiveToTimeKey>=@Timekey

LEFT JOIN DimCurrency                                  ON  DimCurrency.CurrencyAlt_Key= AH.CurrencyAlt_Key	AND
			                                               DimCurrency.EffectiveFromTimeKey<=@Timekey AND
														   DimCurrency.EffectiveToTimeKey>=@Timekey

------------------8. Customers appearing in slippage & upgradation on same date------------------

------------------9. Customers slipped to NPA without having Debit Freeze Flag------------------


Delete from ControlScripts
where ExceptionCode=9 
and EffectiveFromTimeKey=(select timekey from SysDataMatrix where CurrentStatus='C')

Insert into ControlScripts
(
UCIF_ID
,PANNO
,CustomerAcID
,RefCustomerID
,SourceSystemCustomerID
,CustomerName
,SourceName
,DPD_Max
,POS
,BalanceInCrncy
,Balance
,SysNPA_Dt
,FinalAssetClassName
,ExceptionCode
,ExceptionDescription
,EffectiveFromTimeKey
,EffectiveToTimeKey

)

SELECT  
CH.UCIF_ID
,CH.PanNO
,AH.CustomerAcID
,AH.RefCustomerID
,AH.SourceSystemCustomerID
,CH.CustomerName
,DB.SourceName
,AH.DPD_Max
,case  when ISNULL(AH.PrincOutStd,0)<0 then 0 else ISNULL(AH.PrincOutStd,0) end/@cost  AS POS
,case when ISNULL(AH.BalanceInCrncy,0)<0 then 0 else ISNULL (AH.BalanceInCrncy,0)end /@cost     AS BalanceInCrncy
,case when ISNULL(AH.Balance,0)<0 then 0 else  ISNULL(AH.Balance,0)end/@cost     AS Balance
,CONVERT(VARCHAR(20),CH.SysNPA_Dt,103)                AS SysNPA_Dt
,DA.AssetClassShortName                          AS FinalAssetClassName
,9 AS ExceptionCode
,'Customers slipped to NPA without having Debit Freeze Flag.'  AS ExceptionDescription
,AH.EffectiveFromTimeKey
,AH.EffectiveToTimeKey
FROM PRO.CUSTOMERCAL CH
              
INNER JOIN PRO.ACCOUNTCAL     AH                  ON CH.SourceSystemCustomerID=AH.SourceSystemCustomerID AND
														  AH.EffectiveFromTimeKey<=@Timekey AND
														  AH.EffectiveToTimeKey>=@Timekey AND
														  CH.EffectiveFromTimeKey<=@Timekey AND
		                                                  CH.EffectiveToTimeKey>=@Timekey

INNER JOIN DimsourceDB  DB                             ON DB.SourceAlt_Key=AH.SourceAlt_Key AND
                                                           DB.EffectiveFromTimeKey<=@Timekey AND
													       DB.EffectiveToTimeKey>=@Timekey

INNER JOIN DimAssetClass DA                            ON  DA.AssetClassAlt_Key= AH.FinalAssetClassAlt_Key AND 
                                                           DA.EffectiveFromTimeKey<=@Timekey AND
													       DA.EffectiveToTimeKey>=@Timekey

INNER JOIN DimAssetClass                               ON  DimAssetClass.AssetClassAlt_Key= AH.InitialAssetClassAlt_Key AND 
                                                            DimAssetClass.EffectiveFromTimeKey<=@Timekey AND
													        DimAssetClass.EffectiveToTimeKey>=@Timekey

LEFT  JOIN DimProduct                                  ON DimProduct.ProductAlt_Key=AH.ProductAlt_Key AND 
                                                           DimProduct.EffectiveFromTimeKey<=@Timekey AND
													       DimProduct.EffectiveToTimeKey>=@Timekey

LEFT JOIN DimCurrency                                  ON  DimCurrency.CurrencyAlt_Key= AH.CurrencyAlt_Key	AND
			                                               DimCurrency.EffectiveFromTimeKey<=@Timekey AND
														   DimCurrency.EffectiveToTimeKey>=@Timekey
where CH.FlgDeg='Y'
AND AH.FinalAssetClassAlt_Key  IN (2,3,4,5,6)
and AH.DebitSinceDt IS NULL

------------------9. Customers slipped to NPA without having Debit Freeze Flag------------------

------------------10. Customers having different asset class in source system and CrisMac System------------------



Delete from ControlScripts
where ExceptionCode=10 
and EffectiveFromTimeKey=(select timekey from SysDataMatrix where CurrentStatus='C')


Insert into ControlScripts
(
UCIF_ID
,PANNO
,CustomerAcID
,RefCustomerID
,SourceSystemCustomerID
,CustomerName
,SourceName
,DPD_Max
,POS
,BalanceInCrncy
,Balance
,SysNPA_Dt
,FinalAssetClassName
,ExceptionCode
,ExceptionDescription
,EffectiveFromTimeKey
,EffectiveToTimeKey

)

SELECT  
CH.UCIF_ID
,CH.PanNO
,AH.CustomerAcID
,AH.RefCustomerID
,AH.SourceSystemCustomerID
,CH.CustomerName
,DB.SourceName
,AH.DPD_Max
,case  when ISNULL(AH.PrincOutStd,0)<0 then 0 else ISNULL(AH.PrincOutStd,0) end/@cost  AS POS
,case when ISNULL(AH.BalanceInCrncy,0)<0 then 0 else ISNULL (AH.BalanceInCrncy,0)end /@cost     AS BalanceInCrncy
,case when ISNULL(AH.Balance,0)<0 then 0 else  ISNULL(AH.Balance,0)end/@cost     AS Balance
,CONVERT(VARCHAR(20),CH.SysNPA_Dt,103)                AS SysNPA_Dt
,DA.AssetClassShortName                          AS FinalAssetClassName
,10 AS ExceptionCode
,'Customers having different asset class in source system and CrisMac System'  AS ExceptionDescription
,AH.EffectiveFromTimeKey
,AH.EffectiveToTimeKey
FROM PRO.CUSTOMERCAL CH
              
INNER JOIN PRO.ACCOUNTCAL      AH                  ON CH.SourceSystemCustomerID=AH.SourceSystemCustomerID AND
														  AH.EffectiveFromTimeKey<=@Timekey AND
														  AH.EffectiveToTimeKey>=@Timekey AND
														  CH.EffectiveFromTimeKey<=@Timekey AND
		                                                  CH.EffectiveToTimeKey>=@Timekey

INNER JOIN DimsourceDB  DB                             ON DB.SourceAlt_Key=AH.SourceAlt_Key AND
                                                           DB.EffectiveFromTimeKey<=@Timekey AND
													       DB.EffectiveToTimeKey>=@Timekey

INNER JOIN DimAssetClass DA                            ON  DA.AssetClassAlt_Key= AH.FinalAssetClassAlt_Key AND 
                                                           DA.EffectiveFromTimeKey<=@Timekey AND
													       DA.EffectiveToTimeKey>=@Timekey

INNER JOIN DimAssetClass                               ON  DimAssetClass.AssetClassAlt_Key= AH.InitialAssetClassAlt_Key AND 
                                                            DimAssetClass.EffectiveFromTimeKey<=@Timekey AND
													        DimAssetClass.EffectiveToTimeKey>=@Timekey

LEFT  JOIN DimProduct                                  ON DimProduct.ProductAlt_Key=AH.ProductAlt_Key AND 
                                                           DimProduct.EffectiveFromTimeKey<=@Timekey AND
													       DimProduct.EffectiveToTimeKey>=@Timekey

LEFT JOIN DimCurrency                                  ON  DimCurrency.CurrencyAlt_Key= AH.CurrencyAlt_Key	AND
			                                               DimCurrency.EffectiveFromTimeKey<=@Timekey AND
														   DimCurrency.EffectiveToTimeKey>=@Timekey
where (
AH.InitialAssetClassAlt_Key in(1) and AH.FinalAssetClassAlt_Key in(2,3,4,5,6)
or
AH.InitialAssetClassAlt_Key in(2,3,4,5,6) and AH.FinalAssetClassAlt_Key in(1)

)

------------------10. Customers having different asset class in source system and CrisMac System------------------

----------------------11. Exceptional variation in DPD reported from source system------------------


Delete from ControlScripts
where ExceptionCode=11
and EffectiveFromTimeKey=(select timekey from SysDataMatrix where CurrentStatus='C')



IF OBJECT_ID('TEMPDB..#TempTablePreviousDayDpdData') IS NOT NULL
  DROP TABLE #TempTablePreviousDayDpdData

select * into #TempTablePreviousDayDpdData from  PRO.AccountCal_Hist where EffectiveFromTimeKey=@TimeKey-1 and EffectiveToTimeKey=@TimeKey-1
alter Table #TempTablePreviousDayDpdData
add DPD_IntService int,DPD_NoCredit int,DPD_Overdrawn int,DPD_Overdue int,DPD_Renewal int,DPD_StockStmt int,DPD_MAX INT


/*---------- CALCULATED ALL DPD---------------------------------------------------------*/

UPDATE A SET  A.DPD_IntService = (CASE WHEN  A.IntNotServicedDt IS NOT NULL THEN DATEDIFF(DAY,A.IntNotServicedDt,@ProcessDate)+1  ELSE 0 END)			   
             ,A.DPD_NoCredit =  (CASE WHEN  A.LastCrDate IS NOT NULL      THEN DATEDIFF(DAY,A.LastCrDate,  @ProcessDate)  +1     ELSE 0 END)
			 ,A.DPD_Overdrawn=  (CASE WHEN   A.ContiExcessDt IS NOT NULL    THEN DATEDIFF(DAY,A.ContiExcessDt,  @ProcessDate) +1    ELSE 0 END)
			 ,A.DPD_Overdue =   (CASE WHEN  A.OverDueSinceDt IS NOT NULL   THEN  DATEDIFF(DAY,A.OverDueSinceDt,  @ProcessDate)+1   ELSE 0 END) 
			 ,A.DPD_Renewal =   (CASE WHEN  A.ReviewDueDt IS NOT NULL      THEN DATEDIFF(DAY,A.ReviewDueDt, @ProcessDate)   +1   ELSE 0 END)
			 ,A.DPD_StockStmt=  (CASE WHEN  A.StockStDt IS NOT NULL         THEN   DATEDIFF(DAY,A.StockStDt,@ProcessDate)  +1     ELSE 0 END)
FROM #TempTablePreviousDayDpdData A 



/*--------------IF ANY DPD IS NEGATIVE THEN ZERO---------------------------------*/

 UPDATE #TempTablePreviousDayDpdData SET DPD_IntService=0 WHERE isnull(DPD_IntService,0)<0
 UPDATE #TempTablePreviousDayDpdData SET DPD_NoCredit=0 WHERE isnull(DPD_NoCredit,0)<0
 UPDATE #TempTablePreviousDayDpdData SET DPD_Overdrawn=0 WHERE isnull(DPD_Overdrawn,0)<0
 UPDATE #TempTablePreviousDayDpdData SET DPD_Overdue=0 WHERE isnull(DPD_Overdue,0)<0
 UPDATE #TempTablePreviousDayDpdData SET DPD_Renewal=0 WHERE isnull(DPD_Renewal,0)<0
 UPDATE #TempTablePreviousDayDpdData SET DPD_StockStmt=0 WHERE isnull(DPD_StockStmt,0)<0

/*------------DPD IS ZERO FOR ALL ACCOUNT DUE TO LASTCRDATE ------------------------------------*/

UPDATE A SET DPD_NoCredit=0 FROM #TempTablePreviousDayDpdData A 



/* CALCULATE MAX DPD */

	 --IF OBJECT_ID('TEMPDB..#TEMPTABLE') IS NOT NULL
	 --   DROP TABLE #TEMPTABLE

	 --SELECT A.CustomerAcID
		--	,CASE WHEN  isnull(A.DPD_IntService,0)>=isnull(A.RefPeriodIntService,0)		THEN A.DPD_IntService  ELSE 0   END DPD_IntService,  
		--	 CASE WHEN  isnull(A.DPD_NoCredit,0)>=isnull(A.RefPeriodNoCredit,0)			THEN A.DPD_NoCredit    ELSE 0   END DPD_NoCredit,  
		--	 CASE WHEN  isnull(A.DPD_Overdrawn,0)>=isnull(A.RefPeriodOverDrawn	,0)	    THEN A.DPD_Overdrawn   ELSE 0   END DPD_Overdrawn,  
		--	 CASE WHEN  isnull(A.DPD_Overdue,0)>=isnull(A.RefPeriodOverdue	,0)		    THEN A.DPD_Overdue     ELSE 0   END DPD_Overdue , 
		--	 CASE WHEN  isnull(A.DPD_Renewal,0)>=isnull(A.RefPeriodReview	,0)			THEN A.DPD_Renewal     ELSE 0   END  DPD_Renewal ,
		--	 CASE WHEN  isnull(A.DPD_StockStmt,0)>=isnull(A.RefPeriodStkStatement,0)       THEN A.DPD_StockStmt   ELSE 0   END DPD_StockStmt  
		--	 INTO #TEMPTABLE
		--	 FROM #TempTablePreviousDayDpdData A 
		--	 WHERE ( 
		--	          isnull(DPD_IntService,0)>=isnull(RefPeriodIntService,0)
  --                 OR isnull(DPD_NoCredit,0)>=isnull(RefPeriodNoCredit,0)
		--		   OR isnull(DPD_Overdrawn,0)>=isnull(RefPeriodOverDrawn,0)
		--		   OR isnull(DPD_Overdue,0)>=isnull(RefPeriodOverdue,0)
		--		   OR isnull(DPD_Renewal,0)>=isnull(RefPeriodReview,0)
  --                 OR isnull(DPD_StockStmt,0)>=isnull(RefPeriodStkStatement,0)
		--	       )
			    
				

	/*--------------INTIAL MAX DPD 0 FOR RE PROCESSING DATA-------------------------*/

		UPDATE A SET A.DPD_Max=0
		 FROM #TempTablePreviousDayDpdData A 
		


		/*----------------FIND MAX DPD---------------------------------------*/

		UPDATE   A SET A.DPD_Max= (CASE    WHEN (isnull(A.DPD_IntService,0)>=isnull(A.DPD_NoCredit,0) AND isnull(A.DPD_IntService,0)>=isnull(A.DPD_Overdrawn,0) AND    isnull(A.DPD_IntService,0)>=isnull(A.DPD_Overdue,0) AND  isnull(A.DPD_IntService,0)>=isnull(A.DPD_Renewal,0) AND isnull(A.DPD_IntService,0)>=isnull(A.DPD_StockStmt,0)) THEN isnull(A.DPD_IntService,0)
										   WHEN (isnull(A.DPD_NoCredit,0)>=isnull(A.DPD_IntService,0) AND isnull(A.DPD_NoCredit,0)>=  isnull(A.DPD_Overdrawn,0) AND    isnull(A.DPD_NoCredit,0)>=isnull(A.DPD_Overdue,0) AND    isnull(A.DPD_NoCredit,0)>=  isnull(A.DPD_Renewal,0) AND isnull(A.DPD_NoCredit,0)>=isnull(A.DPD_StockStmt,0)) THEN   isnull(A.DPD_NoCredit ,0)
										   WHEN (isnull(A.DPD_Overdrawn,0)>=isnull(A.DPD_NoCredit,0)  AND isnull(A.DPD_Overdrawn,0)>= isnull(A.DPD_IntService,0)  AND  isnull(A.DPD_Overdrawn,0)>=isnull(A.DPD_Overdue,0) AND   isnull(A.DPD_Overdrawn,0)>= isnull(A.DPD_Renewal,0) AND isnull(A.DPD_Overdrawn,0)>=isnull(A.DPD_StockStmt,0)) THEN  isnull(A.DPD_Overdrawn,0)
										   WHEN (isnull(A.DPD_Renewal,0)>=isnull(A.DPD_NoCredit,0)    AND isnull(A.DPD_Renewal,0)>=   isnull(A.DPD_IntService,0)  AND  isnull(A.DPD_Renewal,0)>=isnull(A.DPD_Overdrawn,0)  AND  isnull(A.DPD_Renewal,0)>=   isnull(A.DPD_Overdue,0)  AND isnull(A.DPD_Renewal,0) >=isnull(A.DPD_StockStmt ,0)) THEN isnull(A.DPD_Renewal,0)
										   WHEN (isnull(A.DPD_Overdue,0)>=isnull(A.DPD_NoCredit,0)    AND isnull(A.DPD_Overdue,0)>=   isnull(A.DPD_IntService,0)  AND  isnull(A.DPD_Overdue,0)>=isnull(A.DPD_Overdrawn,0)  AND  isnull(A.DPD_Overdue,0)>=   isnull(A.DPD_Renewal,0)  AND isnull(A.DPD_Overdue ,0)>=isnull(A.DPD_StockStmt ,0))  THEN   isnull(A.DPD_Overdue,0)
										   ELSE isnull(A.DPD_StockStmt,0) END) 
			 
		FROM  #TempTablePreviousDayDpdData a 
		WHERE (isnull(A.DPD_IntService,0)>0   OR isnull(A.DPD_Overdrawn,0)>0   OR  Isnull(A.DPD_Overdue,0)>0	 OR isnull(A.DPD_Renewal,0) >0 OR
		isnull(A.DPD_StockStmt,0)>0 OR isnull(DPD_NoCredit,0)>0)

----IF OBJECT_ID('TEMPDB..#TempTablePreviousDayDpdData') IS NOT NULL
----  DROP TABLE #TempTablePreviousDayDpdData

----	SELECT UCIF_ID,RefCustomerID,SourceSystemCustomerID,CustomerAcID,DPD_Max
----	 INTO #TempTablePreviousDayDpdData FROM PRO.AccountCal_Hist Ah
----	  INNER JOIN DIMSOURCEDB  B ON B.SOURCEALT_KEY=Ah.SOURCEALT_KEY 
----	  AND Ah.EFFECTIVEFROMTIMEKEY=@TIMEKEY-1 AND Ah.EFFECTIVETOTIMEKEY=@TIMEKEY-1
----	  AND B.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND B.EFFECTIVETOTIMEKEY>=@TIMEKEY
----	  --WHERE  Ah.DPD_Max>0
	 
	 IF OBJECT_ID('TEMPDB..#TempTableCurrentDpdData') IS NOT NULL
		DROP TABLE #TempTableCurrentDpdData

	SELECT UCIF_ID,RefCustomerID,SourceSystemCustomerID,CustomerAcID,DPD_Max
	 INTO #TempTableCurrentDpdData FROM PRO.AccountCal Ah
	  INNER JOIN DIMSOURCEDB  B ON B.SOURCEALT_KEY=Ah.SOURCEALT_KEY 
	  AND Ah.EFFECTIVEFROMTIMEKEY=@TIMEKEY AND Ah.EFFECTIVETOTIMEKEY=@TIMEKEY
	  AND B.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND B.EFFECTIVETOTIMEKEY>=@TIMEKEY
	  --WHERE  Ah.DPD_Max>0


	 IF OBJECT_ID('TEMPDB..#TempTableDpdData') IS NOT NULL
		DROP TABLE #TempTableDpdData

	  SELECT A.CustomerAcID,A.DPD_Max AS DPD_MaxP ,B.DPD_Max  AS DPD_MaxC
	  INTO #TempTableDpdData
	   FROM #TempTablePreviousDayDpdData  A
	  INNER JOIN #TempTableCurrentDpdData B
	  ON A.CustomerAcID=B.CustomerAcID

	  
Insert into ControlScripts
(
UCIF_ID
,PANNO
,CustomerAcID
,RefCustomerID
,SourceSystemCustomerID
,CustomerName
,SourceName
,DPD_Max
,POS
,BalanceInCrncy
,Balance
,SysNPA_Dt
,FinalAssetClassName
,ExceptionCode
,ExceptionDescription
,DPDPreviousDay
,DPDCurrentDay
,EffectiveFromTimeKey
,EffectiveToTimeKey

)

SELECT  
CH.UCIF_ID
,CH.PanNO
,AH.CustomerAcID
,AH.RefCustomerID
,AH.SourceSystemCustomerID
,CH.CustomerName
,DB.SourceName
,AH.DPD_Max
,case    when ISNULL(AH.PrincOutStd,0)<0 then 0 else ISNULL(AH.PrincOutStd,0) end/@cost  AS POS
,case when ISNULL(AH.BalanceInCrncy,0)<0 then 0 else ISNULL (AH.BalanceInCrncy,0)end /@cost     AS BalanceInCrncy
,case when ISNULL(AH.Balance,0)<0 then 0 else  ISNULL(AH.Balance,0)end/@cost     AS Balance
,CONVERT(VARCHAR(20),CH.SysNPA_Dt,103)                AS SysNPA_Dt
,DA.AssetClassShortName                          AS FinalAssetClassName
,11 AS ExceptionCode
,'Exceptional variation in DPD reported from source system'  AS ExceptionDescription
,SU.DPD_MaxP
,SU.DPD_MaxC
,AH.EffectiveFromTimeKey
,AH.EffectiveToTimeKey
FROM PRO.CUSTOMERCAL CH
              
INNER JOIN PRO.ACCOUNTCAl      AH                  ON CH.SourceSystemCustomerID=AH.SourceSystemCustomerID AND
														  AH.EffectiveFromTimeKey<=@Timekey AND
														  AH.EffectiveToTimeKey>=@Timekey AND
														  CH.EffectiveFromTimeKey<=@Timekey AND
		                                                  CH.EffectiveToTimeKey>=@Timekey
INNER JOIN #TempTableDpdData SU ON SU.CustomerAcID=AH.CustomerAcID
INNER JOIN DimsourceDB  DB                             ON DB.SourceAlt_Key=AH.SourceAlt_Key AND
                                                           DB.EffectiveFromTimeKey<=@Timekey AND
													       DB.EffectiveToTimeKey>=@Timekey

INNER JOIN DimAssetClass DA                            ON  DA.AssetClassAlt_Key= AH.FinalAssetClassAlt_Key AND 
                                                           DA.EffectiveFromTimeKey<=@Timekey AND
													       DA.EffectiveToTimeKey>=@Timekey

INNER JOIN DimAssetClass                               ON  DimAssetClass.AssetClassAlt_Key= AH.InitialAssetClassAlt_Key AND 
                                                            DimAssetClass.EffectiveFromTimeKey<=@Timekey AND
													        DimAssetClass.EffectiveToTimeKey>=@Timekey

LEFT  JOIN DimProduct                                  ON DimProduct.ProductAlt_Key=AH.ProductAlt_Key AND 
                                                           DimProduct.EffectiveFromTimeKey<=@Timekey AND
													       DimProduct.EffectiveToTimeKey>=@Timekey

LEFT JOIN DimCurrency                                  ON  DimCurrency.CurrencyAlt_Key= AH.CurrencyAlt_Key	AND
			                                               DimCurrency.EffectiveFromTimeKey<=@Timekey AND
														   DimCurrency.EffectiveToTimeKey>=@Timekey
where (
     (isnull(SU.DPD_MaxC,0)-isnull(SU.DPD_Maxp,0)>1)
or (isnull(SU.DPD_MaxC,0)>0 and isnull(SU.DPD_Maxp,0)>0 and isnull(SU.DPD_MaxC,0)-isnull(SU.DPD_Maxp,0)=0)
or (isnull(SU.DPD_Maxp,0)=0 and isnull(SU.DPD_MaxC,0)>1) 
)

------------------11. Exceptional variation in DPD reported from source system------------------


------------------12. No Upward Movement in NPA categories------------------


Delete from ControlScripts
where ExceptionCode=12 
and EffectiveFromTimeKey=(select timekey from SysDataMatrix where CurrentStatus='C')


Insert into ControlScripts
(
UCIF_ID
,PANNO
,CustomerAcID
,RefCustomerID
,SourceSystemCustomerID
,CustomerName
,SourceName
,DPD_Max
,POS
,BalanceInCrncy
,Balance
,SysNPA_Dt
,FinalAssetClassName
,ExceptionCode
,ExceptionDescription
,EffectiveFromTimeKey
,EffectiveToTimeKey

)

SELECT  
CH.UCIF_ID
,CH.PanNO
,AH.CustomerAcID
,AH.RefCustomerID
,AH.SourceSystemCustomerID
,CH.CustomerName
,DB.SourceName
,AH.DPD_Max
,case  when ISNULL(AH.PrincOutStd,0)<0 then 0 else ISNULL(AH.PrincOutStd,0) end/@cost  AS POS
,case when ISNULL(AH.BalanceInCrncy,0)<0 then 0 else ISNULL (AH.BalanceInCrncy,0)end /@cost     AS BalanceInCrncy
,case when ISNULL(AH.Balance,0)<0 then 0 else  ISNULL(AH.Balance,0)end/@cost     AS Balance
,CONVERT(VARCHAR(20),CH.SysNPA_Dt,103)                AS SysNPA_Dt
,DA.AssetClassShortName                          AS FinalAssetClassName
,12 AS ExceptionCode
,'No Upward Movement in NPA categories'  AS ExceptionDescription
,AH.EffectiveFromTimeKey
,AH.EffectiveToTimeKey
FROM PRO.CUSTOMERCAL CH
              
INNER JOIN PRO.ACCOUNTCAL      AH                  ON CH.SourceSystemCustomerID=AH.SourceSystemCustomerID AND
														  AH.EffectiveFromTimeKey<=@Timekey AND
														  AH.EffectiveToTimeKey>=@Timekey AND
														  CH.EffectiveFromTimeKey<=@Timekey AND
		                                                  CH.EffectiveToTimeKey>=@Timekey

INNER JOIN DimsourceDB  DB                             ON DB.SourceAlt_Key=AH.SourceAlt_Key AND
                                                           DB.EffectiveFromTimeKey<=@Timekey AND
													       DB.EffectiveToTimeKey>=@Timekey

INNER JOIN DimAssetClass DA                            ON  DA.AssetClassAlt_Key= AH.FinalAssetClassAlt_Key AND 
                                                           DA.EffectiveFromTimeKey<=@Timekey AND
													       DA.EffectiveToTimeKey>=@Timekey

INNER JOIN DimAssetClass                               ON  DimAssetClass.AssetClassAlt_Key= AH.InitialAssetClassAlt_Key AND 
                                                            DimAssetClass.EffectiveFromTimeKey<=@Timekey AND
													        DimAssetClass.EffectiveToTimeKey>=@Timekey

LEFT  JOIN DimProduct                                  ON DimProduct.ProductAlt_Key=AH.ProductAlt_Key AND 
                                                           DimProduct.EffectiveFromTimeKey<=@Timekey AND
													       DimProduct.EffectiveToTimeKey>=@Timekey

LEFT JOIN DimCurrency                                  ON  DimCurrency.CurrencyAlt_Key= AH.CurrencyAlt_Key	AND
			                                               DimCurrency.EffectiveFromTimeKey<=@Timekey AND
														   DimCurrency.EffectiveToTimeKey>=@Timekey
where  ( AH.InitialAssetClassAlt_Key  IN (3,4,5,6) AND AH.FinalAssetClassAlt_Key  IN (2)
OR
AH.InitialAssetClassAlt_Key  IN (4,5,6) AND AH.FinalAssetClassAlt_Key  IN (2,3)
OR
AH.InitialAssetClassAlt_Key  IN (5,6) AND AH.FinalAssetClassAlt_Key  IN (2,3,4)
)

------------------12. No Upward Movement in NPA categories------------------

------------------14. Same UCICFCR customer id but having different PAN number------------------


Delete from ControlScripts
where ExceptionCode=14 
and EffectiveFromTimeKey=(select timekey from SysDataMatrix where CurrentStatus='C')

IF OBJECT_ID('TEMPDB..#TempTableAllCustomers') IS NOT NULL
  DROP TABLE #TempTableAllCustomers

	SELECT UCIF_ID,RefCustomerID,SourceSystemCustomerID,PANNO
	 INTO #TempTableAllCustomers FROM PRO.CUSTOMERCAL A
	  INNER JOIN DIMSOURCEDB  B ON B.SOURCEALT_KEY=A.SOURCEALT_KEY 
	  AND A.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND A.EFFECTIVETOTIMEKEY>=@TIMEKEY
	  AND B.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND B.EFFECTIVETOTIMEKEY>=@TIMEKEY
	  where a.PANNO<>''
	  GROUP BY  UCIF_ID,RefCustomerID,SourceSystemCustomerID,PANNO

IF OBJECT_ID('TEMPDB..#DuplicatePan') IS NOT NULL
  DROP TABLE #DuplicatePan

select A.SourceSystemCustomerID  
Into #DuplicatePan
from #TempTableAllCustomers A
INNER JOIN #TempTableAllCustomers B
ON A.SourceSystemCustomerID=B.SourceSystemCustomerID
AND A.PANNO<>B.PANNO
union
select A.SourceSystemCustomerID  from #TempTableAllCustomers A
INNER JOIN #TempTableAllCustomers B
ON A.UCIF_ID=B.UCIF_ID
AND A.PANNO<>B.PANNO



Insert into ControlScripts
(
UCIF_ID
,PANNO
,CustomerAcID
,RefCustomerID
,SourceSystemCustomerID
,CustomerName
,SourceName
,DPD_Max
,POS
,BalanceInCrncy
,Balance
,SysNPA_Dt
,FinalAssetClassName
,ExceptionCode
,ExceptionDescription
,EffectiveFromTimeKey
,EffectiveToTimeKey

)


SELECT  
CH.UCIF_ID
,CH.PanNO
,AH.CustomerAcID
,AH.RefCustomerID
,AH.SourceSystemCustomerID
,CH.CustomerName
,DB.SourceName
,AH.DPD_Max
,case  when ISNULL(AH.PrincOutStd,0)<0 then 0 else ISNULL(AH.PrincOutStd,0) end/@cost  AS POS
,case when ISNULL(AH.BalanceInCrncy,0)<0 then 0 else ISNULL (AH.BalanceInCrncy,0)end /@cost     AS BalanceInCrncy
,case when ISNULL(AH.Balance,0)<0 then 0 else  ISNULL(AH.Balance,0)end/@cost     AS Balance
,CONVERT(VARCHAR(20),CH.SysNPA_Dt,103)                AS SysNPA_Dt
,DA.AssetClassShortName                          AS FinalAssetClassName
,14 AS ExceptionCode
,'Same UCIC/FCR customer id but having different PAN number'  AS ExceptionDescription
,AH.EffectiveFromTimeKey
,AH.EffectiveToTimeKey

FROM PRO.CUSTOMERCAL CH
              
INNER JOIN PRO.ACCOUNTCAL      AH                  ON CH.SourceSystemCustomerID=AH.SourceSystemCustomerID AND
														  AH.EffectiveFromTimeKey<=@Timekey AND
														  AH.EffectiveToTimeKey>=@Timekey AND
														  CH.EffectiveFromTimeKey<=@Timekey AND
		                                                  CH.EffectiveToTimeKey>=@Timekey

INNER JOIN DimsourceDB  DB                             ON DB.SourceAlt_Key=AH.SourceAlt_Key AND
                                                           DB.EffectiveFromTimeKey<=@Timekey AND
													       DB.EffectiveToTimeKey>=@Timekey

INNER JOIN DimAssetClass DA                            ON  DA.AssetClassAlt_Key= AH.FinalAssetClassAlt_Key AND 
                                                           DA.EffectiveFromTimeKey<=@Timekey AND
													       DA.EffectiveToTimeKey>=@Timekey

inner join  #DuplicatePan on #DuplicatePan.SourceSystemCustomerID=CH.SourceSystemCustomerID

INNER JOIN DimAssetClass                               ON  DimAssetClass.AssetClassAlt_Key= AH.InitialAssetClassAlt_Key AND 
                                                            DimAssetClass.EffectiveFromTimeKey<=@Timekey AND
													        DimAssetClass.EffectiveToTimeKey>=@Timekey

LEFT  JOIN DimProduct                                  ON DimProduct.ProductAlt_Key=AH.ProductAlt_Key AND 
                                                           DimProduct.EffectiveFromTimeKey<=@Timekey AND
													       DimProduct.EffectiveToTimeKey>=@Timekey

LEFT JOIN DimCurrency                                  ON  DimCurrency.CurrencyAlt_Key= AH.CurrencyAlt_Key	AND
			                                               DimCurrency.EffectiveFromTimeKey<=@Timekey AND
														   DimCurrency.EffectiveToTimeKey>=@Timekey


------------------14. Same UCICFCR customer id but having different PAN number------------------


UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' 
WHERE IDENTITYKEY = (SELECT IDENT_CURRENT('PRO.PROCESSMONITOR'))
 AND  TIMEKEY=@TIMEKEY AND DESCRIPTION='INSERT DATA FOR ValidationControlScripts'

 END


GO