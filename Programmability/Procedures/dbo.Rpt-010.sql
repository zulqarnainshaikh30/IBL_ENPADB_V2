SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



/*

DISCRIPTION		:   Deviation Identification Report

*/

 create PROC [dbo].[Rpt-010]  
  @UserName AS VARCHAR(20)
 ,@MisLocation AS VARCHAR(20)
 ,@CustFacility AS VARCHAR(10)
 ,@TimeKey AS INT
 ,@Cost FLOAT
AS 

--DECLARE 
-- @UserName AS VARCHAR(20)='D2K'	
--,@MisLocation AS VARCHAR(20)=''
--,@CustFacility AS VARCHAR(10)=3
--,@TimeKey AS INT=26023
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



SELECT 
DSDB.SourceName 
,CBD.UCIF_ID
,CBD.CustomerId
,CBD.CustomerName
,ACBD.CustomerACID 
,DAC.AssetClassGroup 
,CASE WHEN DAC.AssetClassGroup='NPA'
      THEN DAC.AssetClassShortNameEnum
	  END                                   AS AssetClass_Sub
,CONVERT(VARCHAR(20),ACFIN.NpaDt,103)       AS NPADt 
,CONVERT(VARCHAR(20),OverDueSinceDt,103)    AS OverDueSinceDt 
,ACNPAD.NPA_Reason
,SUM(ISNULL(ACBAL.Balance,0))/@Cost         AS Balance

FROM AdvAcBasicDetail ACBD 
  

INNER JOIN CustomerBasicDetail CBD               ON ACBD.CustomerEntityId=CBD.CustomerEntityId
                                                    AND CBD.EffectiveFromTimeKey<=@TimeKey 
													AND CBD.EffectiveToTimeKey>=@TimeKey
                                                    AND ACBD.EffectiveFromTimeKey<=@TimeKey 
													AND ACBD.EffectiveToTimeKey>=@TimeKey

INNER JOIN AdvAcBalanceDetail ACBAL              ON ACBD.AccountEntityId=ACBAL.AccountEntityId
                                                    AND ACBAL.EffectiveFromTimeKey<=@TimeKey 
													AND ACBAL.EffectiveToTimeKey>=@TimeKey

LEFT JOIN AdvAcFinancialDetail ACFIN             ON ACBD.AccountEntityId=ACFIN.AccountEntityId
                                                    AND ACFIN.EffectiveFromTimeKey<=@TimeKey 
												    AND ACFIN.EffectiveToTimeKey>=@TimeKey

LEFT JOIN AdvCustNPADetail ACNPAD                ON ACBD.CustomerEntityId=ACNPAD.CustomerEntityId
                                                    AND ACNPAD.EffectiveFromTimeKey<=@TimeKey 
												    AND ACNPAD.EffectiveToTimeKey>=@TimeKey
												 
INNER JOIN DimAssetClass DAC                     ON ACBAL.AssetClassAlt_Key=DAC.AssetClassAlt_Key
                                                    AND DAC.EffectiveFromTimeKey<=@TimeKey 
												    AND DAC.EffectiveToTimeKey>=@TimeKey
												 
INNER JOIN DimSourceDB DSDB                      ON ACBD.SourceAlt_key=DSDB.SourceAlt_key
                                                    AND DSDB.EffectiveFromTimeKey<=@TimeKey 
												    AND DSDB.EffectiveToTimeKey>=@TimeKey

GROUP BY

DSDB.SourceName 
,CBD.CustomerId
,CBD.CustomerName
,ACBD.CustomerACID 
,DAC.AssetClassShortNameEnum 
,ACFIN.NpaDt
,OverDueSinceDt
,DAC.AssetClassGroup
,ACNPAD.NPA_Reason
,CBD.UCIF_ID

OPTION(RECOMPILE)
GO