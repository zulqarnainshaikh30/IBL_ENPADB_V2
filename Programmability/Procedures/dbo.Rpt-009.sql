SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



/*
CREATE BY		:	Baijayanti
CREATE DATE	    :	06-04-2021
DISCRIPTION		:   Asset Classification Accuracy Report
*/

 create PROC [dbo].[Rpt-009]  
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
TB.BranchCode,
CBD.UCIF_ID,
CBD.CustomerId,
CBD.CustomerName,
ACBD.CustomerACID,
AssetClassShortNameEnum,
CONVERT(VARCHAR(20),NPADt,103)      AS NPADt

FROM DimBranch TB
INNER JOIN AdvAcBasicDetail	ACBD		        ON	TB.BranchCode=ACBD.BranchCode
												    AND ACBD.EffectiveFromTimeKey<=@TimeKey 
													AND ACBD.EffectiveToTimeKey>=@TimeKey		
												    AND TB.EffectiveFromTimeKey<=@TimeKey 
													AND TB.EffectiveToTimeKey>=@TimeKey

INNER JOIN CustomerBasicDetail	CBD				ON	CBD.CustomerEntityId=ACBD.CustomerEntityId
												    AND CBD.EffectiveFromTimeKey<=@TimeKey 
													AND CBD.EffectiveToTimeKey>=@TimeKey

INNER JOIN AdvAcBalanceDetail  ACBAL            ON ACBAL.AccountEntityId=ACBD.AccountEntityId
												   AND ACBAL.EffectiveFromTimeKey<=@TimeKey 
												   AND ACBAL.EffectiveToTimeKey>=@TimeKey


INNER JOIN DimAssetClass  DAC                   ON ACBAL.AssetClassAlt_Key=DAC.AssetClassAlt_Key
												   AND DAC.EffectiveFromTimeKey<=@TimeKey 
												   AND DAC.EffectiveToTimeKey>=@TimeKey

LEFT JOIN AdvAcFinancialDetail  ACFD            ON ACFD.AccountEntityId=ACBD.AccountEntityId
												   AND ACFD.EffectiveFromTimeKey<=@TimeKey 
												   AND ACFD.EffectiveToTimeKey>=@TimeKey



OPTION(RECOMPILE)




GO