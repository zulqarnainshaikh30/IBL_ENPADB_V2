SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



/*
CREATE BY		:	Baijayanti
CREATE DATE	    :	27-04-2021
DISCRIPTION		:   Unserviced Intt Movement Format
*/

 create PROC [dbo].[Rpt-017]  
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
--,@TimeKey AS INT=25999
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

DECLARE @PerQtrKey INT=(SELECT LastQtrDateKey FROM SysDayMatrix WHERE TimeKey=@TimeKey)



---------------------------------------------Final Selection---------------------------


SELECT 
CONVERT(VARCHAR(20),UnservicedInterestProcessDate,103)                       AS Created_Date,
USIM.CustomerAcid,
DACI.AssetClassGroup                                                         AS I_AssetClassGroup,
CONVERT(VARCHAR(20),NPADt,103)                                               AS NPADt,
ISNULL(InitialProvision,0)/@Cost                                             AS Opening_Gross_NPA,
ISNULL(InitialUnservicedInterest,0)/@Cost                                    AS InitialUnservicedInterest,
ISNULL(ExistingProvision_Addition,0)/@Cost                                   AS ExistingProvision_Addition,
ISNULL(FreshProvision_Addition,0)/@Cost                                      AS FreshProvision_Addition,
ISNULL(ReductionDuetoUpgradeUnservicedInterest,0)/@Cost                      AS ReductionDuetoUpgradeUnservicedInterest,
ISNULL(ReductionDuetoRecovery_ExistingUnservicedInterest,0)/@Cost            AS ReductionDuetoRecovery_ExistingUnservicedInterest,
0                                                                            AS Write_Off,
ISNULL(ReductionUnservicedInterestDuetoWrite_Off,0)/@Cost                    AS ReductionUnservicedInterestDuetoWrite_Off,
0                                                                            AS SaletoARC,
ISNULL(ReductionUnservicedInterestDuetoRecovery_Arcs,0)/@Cost                AS ReductionUnservicedInterestDuetoRecovery_Arcs,
DACF.AssetClassGroup                                                         AS F_AssetClassGroup,
ISNULL(FinalUnservicedInterest,0)/@Cost                                      AS FinalUnservicedInterest,
USIM.MovementNature,
''                                                                           AS CCheck



FROM UnservicedInterestMovement USIM
 
LEFT JOIN AdvAcFinancialDetail ACFD        ON ACFD.RefSystemAcId=USIM.CustomerACID
										       AND ACFD.EffectiveFromTimeKey<=@TimeKey 
										       AND ACFD.EffectiveToTimeKey>=@TimeKey

LEFT JOIN ProvisionMovement PM             ON PM.CustomerACID=USIM.CustomerACID
                                              AND PM.Timekey=@TimeKey

INNER JOIN DimAssetClass DACI              ON USIM.InitialAssetClassAlt_Key=DACI.AssetClassAlt_Key
                                              AND DACI.EffectiveFromTimeKey<=@TimeKey 
											  AND DACI.EffectiveToTimeKey>=@TimeKey

INNER JOIN DimAssetClass DACF              ON USIM.FinalAssetClassAlt_Key=DACF.AssetClassAlt_Key
                                              AND DACF.EffectiveFromTimeKey<=@TimeKey 
											  AND DACF.EffectiveToTimeKey>=@TimeKey

WHERE USIM.Timekey=@TimeKey


OPTION(RECOMPILE)

GO