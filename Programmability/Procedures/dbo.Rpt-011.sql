SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



/*
CREATE BY		:	Baijayanti
CREATE DATE	    :	05-04-2021
DISCRIPTION		:   Slippage Reports - Assignment of NPA Date
*/

 create PROC [dbo].[Rpt-011]  
  @UserName AS VARCHAR(20)
 ,@MisLocation AS VARCHAR(20)
 ,@CustFacility AS VARCHAR(10)
 ,@From AS VARCHAR(20)
 ,@To   AS VARCHAR(20)
 ,@Cost FLOAT
AS 

--DECLARE 
-- @UserName AS VARCHAR(20)='D2K'	
--,@MisLocation AS VARCHAR(20)=''
--,@CustFacility AS VARCHAR(10)=3
--,@From AS VARCHAR(20)='01/01/2021'
--,@To   AS VARCHAR(20)='31/03/2021'
--,@Cost FLOAT=1

SET NOCOUNT ON ;  

DECLARE @Flag AS CHAR(5)            
DECLARE @Department AS VARCHAR(10)            
DECLARE @AuthenFlag AS CHAR(5)            
DECLARE @Code AS VARCHAR(10)            
            
SET @AuthenFlag = (SELECT dbo.AuthenticationFlag())            
SET @Flag = (SELECT dbo.ADflag())            
 IF @Flag='Y'             
 BEGIN            
   SET @Department = (LEFT(@MisLocation,2))            
   SET @Code = (RIGHT(@MisLocation,3))            
 END            
            
 ELSE IF @Flag='SQL'            
 BEGIN            
   IF @AuthenFlag = 'Y'            
    BEGIN            
     SET @Department = (SELECT TOP(1)UserLocation FROM DimUserInfo WHERE UserLoginID = @UserName	AND EffectiveToTimeKey=49999)            
     SET @Code = (SELECT TOP(1)UserLocationCode FROM DimUserInfo WHERE UserLoginID = @UserName		AND EffectiveToTimeKey=49999)        
    END            
                
   ELSE IF @AuthenFlag = 'N'            
       BEGIN            
     SET @Department = 'RO'            
     SET @Code       = '07'            
       END            
 END    
   

DECLARE @BankCode INT
	SET @BankCode=(SELECT BankAlt_Key FROM SysReportformat)

DECLARE	@From1		DATE=(SELECT Rdate FROM dbo.DateConvert(@From))
DECLARE @to1		DATE=(SELECT Rdate FROM dbo.DateConvert(@to))

DECLARE @TimeKey INT=(SELECT TimeKey FROM SysDayMatrix WHERE DATE=@to1)


-------NEW DATE LOGIC ADDED AS PER MAIL	-	17-12-2018


DECLARE @FromTimeKey AS INT= (SELECT TimeKey FROM SysDayMatrix WHERE DATE=@From1)
DECLARE @ToTimeKey AS INT=(SELECT TimeKey FROM SysDayMatrix WHERE DATE=@to1)


----------------------------------------------ToTimeKey DATA------------------------------------------

IF(OBJECT_ID('tempdb..#CURRENTDATA') IS NOT NULL)
DROP TABLE #CURRENTDATA

SELECT  
        SourceName,
		CBD.UCIF_ID,
		CustomerId,
		CustomerName,
		ACBD.CustomerACID,
		DAC.AssetClassShortNameEnum,
		DAC.AssetClassAlt_Key,
		CONVERT(VARCHAR(20),ACFD.NPADt,103)           AS NPADt,
		CONVERT(VARCHAR(20),OverDueSinceDt,103)       AS OverDueSinceDt,
		ACNPAD.NPA_Reason,
		ISNULL(ACBAL.Balance,0)                       AS Balance

INTO  #CURRENTDATA

FROM AdvAcBasicDetail	ACBD				


INNER JOIN CustomerBasicDetail	CBD				ON	CBD.CustomerEntityId=ACBD.CustomerEntityId
												    AND CBD.EffectiveFromTimeKey<=@ToTimeKey 
													AND CBD.EffectiveToTimeKey>=@ToTimeKey
												    AND ACBD.EffectiveFromTimeKey<=@ToTimeKey 
													AND ACBD.EffectiveToTimeKey>=@ToTimeKey

INNER JOIN AdvAcBalanceDetail  ACBAL            ON ACBAL.AccountEntityId=ACBD.AccountEntityId
												   AND ACBAL.EffectiveFromTimeKey<=@ToTimeKey 
												   AND ACBAL.EffectiveToTimeKey>=@ToTimeKey

INNER JOIN AdvAcFinancialDetail	ACFD			ON ACBAL.AccountEntityId=ACFD.AccountEntityId
												   AND ACFD.EffectiveFromTimeKey<=@ToTimeKey 
												   AND ACFD.EffectiveToTimeKey>=@ToTimeKey

LEFT JOIN AdvCustNPADetail ACNPAD               ON ACBD.CustomerEntityId=ACNPAD.CustomerEntityId
                                                    AND ACNPAD.EffectiveFromTimeKey<=@ToTimeKey 
												    AND ACNPAD.EffectiveToTimeKey>=@ToTimeKey

INNER JOIN DimAssetClass DAC					ON DAC.AssetClassAlt_Key=ACBAL.AssetClassAlt_Key
												   AND DAC.EffectiveFromTimeKey<=@ToTimeKey 
												   AND DAC.EffectiveToTimeKey>=@ToTimeKey

INNER JOIN DimSourceDB DSDB					    ON DSDB.SourceAlt_Key=ACBD.SourceAlt_Key
												   AND DSDB.EffectiveFromTimeKey<=@ToTimeKey 
												   AND DSDB.EffectiveToTimeKey>=@ToTimeKey


WHERE ISNULL(DAC.AssetClassShortNameEnum,'')  NOT IN ('STD','NA')


OPTION(RECOMPILE)



-----------------------------------------FROM TIMEKEY-----------------------------------------------------

IF(OBJECT_ID('tempdb..#PREVIOUSDATA') IS NOT NULL)
DROP TABLE #PREVIOUSDATA

SELECT

        SourceName,
		CBD.UCIF_ID,
		CustomerId,
		CustomerName,
		ACBD.CustomerACID,
		DAC.AssetClassShortNameEnum,
		DAC.AssetClassAlt_Key,
		CONVERT(VARCHAR(20),ACFD.NPADt,103)           AS NPADt,
		CONVERT(VARCHAR(20),OverDueSinceDt,103)       AS OverDueSinceDt,
		ACNPAD.NPA_Reason,
		ISNULL(ACBAL.Balance,0)                       AS Balance

INTO  #PREVIOUSDATA

FROM AdvAcBasicDetail	ACBD				

INNER JOIN CustomerBasicDetail	CBD				ON	CBD.CustomerEntityId=ACBD.CustomerEntityId
												    AND CBD.EffectiveFromTimeKey<=@FromTimeKey 
													AND CBD.EffectiveToTimeKey>=@FromTimeKey
												    AND ACBD.EffectiveFromTimeKey<=@FromTimeKey 
													AND ACBD.EffectiveToTimeKey>=@FromTimeKey

INNER JOIN AdvAcBalanceDetail  ACBAL            ON ACBAL.AccountEntityId=ACBD.AccountEntityId
												   AND ACBAL.EffectiveFromTimeKey<=@FromTimeKey 
												   AND ACBAL.EffectiveToTimeKey>=@FromTimeKey

INNER JOIN AdvAcFinancialDetail	ACFD			ON ACBAL.AccountEntityId=ACFD.AccountEntityId
												   AND ACFD.EffectiveFromTimeKey<=@FromTimeKey 
												   AND ACFD.EffectiveToTimeKey>=@FromTimeKey

LEFT JOIN AdvCustNPADetail ACNPAD               ON ACBD.CustomerEntityId=ACNPAD.CustomerEntityId
                                                    AND ACNPAD.EffectiveFromTimeKey<=@FromTimeKey 
												    AND ACNPAD.EffectiveToTimeKey>=@FromTimeKey

INNER JOIN DimAssetClass DAC					ON DAC.AssetClassAlt_Key=ACBAL.AssetClassAlt_Key
												   AND DAC.EffectiveFromTimeKey<=@FromTimeKey 
												   AND DAC.EffectiveToTimeKey>=@FromTimeKey

INNER JOIN DimSourceDB DSDB					   ON DSDB.SourceAlt_Key=ACBD.SourceAlt_Key
												   AND DSDB.EffectiveFromTimeKey<=@FromTimeKey 
												   AND DSDB.EffectiveToTimeKey>=@FromTimeKey


WHERE ISNULL(DAC.AssetClassShortNameEnum,'')  IN ('STD','NA')

OPTION(RECOMPILE)



IF(OBJECT_ID('tempdb..#DATA') IS NOT NULL)
DROP TABLE #DATA

SELECT DATA.*,0 SRNO  INTO #DATA FROM 

(

SELECT 
SourceName,
UCIF_ID,
CustomerId,
CustomerName,
CustomerACID,
AssetClassShortNameEnum,
AssetClassAlt_Key,
NPADt,
OverDueSinceDt,
NPA_Reason,
Balance,
'C' FLAG
FROM #CURRENTDATA

UNION ALL

SELECT 
SourceName,
UCIF_ID,
CustomerId,
CustomerName,
CustomerACID,
AssetClassShortNameEnum,
AssetClassAlt_Key,
NPADt,
OverDueSinceDt,
NPA_Reason,
Balance,
'P' FLAG
FROM #PREVIOUSDATA

)DATA

UPDATE DATA SET DATA.SRNO=D.SRNO
FROM #DATA DATA
INNER JOIN
			(SELECT ROW_NUMBER() OVER (PARTITION BY CustomerACID ORDER BY RIGHT(FLAG,1)DESC) SRNO,CustomerACID,FLAG FROM #DATA
			) D ON D.CustomerACID=DATA.CustomerACID AND D.FLAG =DATA.FLAG

OPTION(RECOMPILE)	
CREATE NONCLUSTERED INDEX INX_BranchCode1 ON #DATA(CustomerACID)
INCLUDE	(SourceName,UCIF_ID,CustomerId,CustomerName,Balance,AssetClassAlt_Key,AssetClassShortNameEnum,NPADt,OverDueSinceDt,NPA_Reason,FLAG)





IF(OBJECT_ID('tempdb..#TOPROCESS') IS NOT NULL)
DROP TABLE #TOPROCESS


IF(OBJECT_ID('tempdb..#MainData') IS NOT NULL)
DROP TABLE #MainData

SELECT  
SourceName,
UCIF_ID,
CustomerId,
CustomerName,
D.CustomerACID,
AssetClassAlt_Key,
NPADt,
OverDueSinceDt,
NPA_Reason,
Balance,
ASSET.Asset_PREV,
ASSET.Asset_CURR,
AssetClassShortNameEnum ,
 FLAG

INTO #TOPROCESS

FROM #DATA D
INNER JOIN(
SELECT  CustomerACID,ISNULL([C],'NA') Asset_CURR,ISNULL([P],'NA') Asset_PREV
				FROM 
				(		SELECT CustomerACID ,AssetClassShortNameEnum ,FLAG 
						FROM #DATA
						
				) Pvt
				PIVOT       
				(
				MAX(AssetClassShortNameEnum) FOR FLAG IN ([C],[P])
				) P
       WHERE (ISNULL([P],'NA') IN('STD','NA'))

	   ) ASSET ON ASSET.CustomerACID=D.CustomerACID 

WHERE D.SRNO=1
 AND CASE WHEN Asset_CURR IN ('STD','NA') AND Asset_PREV IN('STD','NA')
          THEN 0
		  ELSE 1 END=1



	BEGIN
	 SELECT * INTO #MainData FROM (
		SELECT 	
		    SourceName,
			UCIF_ID,
			CustomerId, 
			CustomerName,
			CustomerACID,
			Balance,
			Asset_CURR AS AssetClassShortNameEnum ,
			Asset_PREV,
            NPADt,
			NPA_Reason,
			OverDueSinceDt
		FROM #TOPROCESS P  
		 
		)DA		
		OPTION(RECOMPILE)						
	END
---------------------------------------------------------------

SELECT

DISTINCT 

SourceName,
UCIF_ID,
CustomerId, 
CustomerName,
Data.CustomerACID,
NPADt,
NPA_Reason,
Data.OverDueSinceDt,
ISNULL(Data.Balance,0)/@Cost               AS Balance,
Data.AssetClassShortNameEnum

FROM #MainData Data                 
									      
OPTION(RECOMPILE)


DROP TABLE #DATA,#PREVIOUSDATA,#CURRENTDATA,#TOPROCESS,#MainData


GO