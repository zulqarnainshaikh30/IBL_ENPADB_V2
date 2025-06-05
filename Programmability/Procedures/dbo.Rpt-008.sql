SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


/*
CREATE BY		:	Baijayanti
CREATE DATE	    :	09-04-2021
DISCRIPTION		:   Reconciliation Report - O/S Balance Validation
*/

 create PROC [dbo].[Rpt-008]  
  @UserName AS VARCHAR(20)
 ,@MisLocation AS VARCHAR(20)
 ,@CustFacility AS VARCHAR(10)
 ,@TimeKey AS INT
 ,@Cost    AS FLOAT
AS 

--DECLARE 
-- @UserName AS VARCHAR(20)='D2K'	
--,@MisLocation AS VARCHAR(20)=''
--,@CustFacility AS VARCHAR(10)=3
--,@TimeKey AS INT=26114  
--,@Cost    AS FLOAT=1


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

-----------------------------------------------
IF(OBJECT_ID('tempdb..#DATA') IS NOT NULL)
DROP TABLE #DATA


SELECT 

DP.ProductCode    
,CustomerACID   
,CASE WHEN DAC.AssetClassShortNameEnum='STD'  
	  THEN GLPAU.AssetGLCode_STD 
	  ELSE GLPAU.SuspendedAssetGLCode_NPA 
	  END                                                      AS 'Principal GL Code'  
			  									         
,SUM(ISNULL(ACBAL.PrincipalBalance,0))/@Cost                   AS 'Principal Amount'

,CASE WHEN DAC.AssetClassShortNameEnum='STD'
      THEN   GLPAU.InterestReceivableGLCode_STD 
	  ELSE   GLPAU.SuspendedInterestReceivableGLCode_NPA 
	  END                                                      AS  'Interest GL Number'

,SUM(ISNULL(ACBAL.InterestReceivable,0))/@Cost                 AS 'Interest Amount'


,SUM(ISNULL(ACBAL.Balance,0))/@Cost                            AS 'Gross Balance'

INTO #DATA
FROM AdvAcBasicDetail  ACBD
 
INNER JOIN dbo.AdvAcBalanceDetail  ACBAL    ON ACBD.AccountEntityId=ACBAL.AccountEntityId
                                               AND ACBD.EffectiveFromTimeKey<=@TimeKey	
											   AND ACBD.EffectiveToTimeKey>=@TimeKey
                                               AND ACBAL.EffectiveFromTimeKey<=@TimeKey	
											   AND ACBAL.EffectiveToTimeKey>=@TimeKey

INNER JOIN DimAssetClass DAC                ON DAC.AssetClassAlt_Key=ACBAL.AssetClassAlt_Key
                                               AND DAC.EffectiveFromTimeKey<=@TimeKey	
											   AND DAC.EffectiveToTimeKey>=@TimeKey

INNER JOIN DimProduct DP                    ON DP.ProductAlt_Key=ACBD.ProductAlt_Key
                                               AND DP.EffectiveFromTimeKey<=@TimeKey	
											   AND DP.EffectiveToTimeKey>=@TimeKey

INNER JOIN DimGLProduct_AU   GLPAU          ON GLPAU.ProductCode=DP.ProductCode
                                               AND GLPAU.EffectiveFromTimeKey<=@TimeKey	
											   AND GLPAU.EffectiveToTimeKey>=@TimeKey

GROUP BY

DP.ProductCode    
,CustomerACID  
,DAC.AssetClassShortNameEnum 
,GLPAU.AssetGLCode_STD 
,GLPAU.SuspendedAssetGLCode_NPA 
,GLPAU.InterestReceivableGLCode_STD 
,GLPAU.SuspendedInterestReceivableGLCode_NPA 

OPTION(RECOMPILE)

SELECT DENSE_RANK()OVER( ORDER BY ProductCode,[Principal GL Code])    AS RN,DENSE_RANK()OVER( ORDER BY ProductCode,[Interest GL Number])RN1,* 
FROM #DATA 

OPTION(RECOMPILE)

DROP TABLE #DATA



GO