SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



/*
CREATE BY		:	Baijayanti
CREATE DATE	    :	05-04-2021
DISCRIPTION		:   Sale to ARC
*/

 create PROC [dbo].[Rpt-020]  
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
DISTINCT 
CBD.CustomerId,
CBD.CustomerName,
ACBD.CustomerACID,
CONVERT(VARCHAR(20),DtofsaletoARC,103)      AS DtofsaletoARC,
CONVERT(VARCHAR(20),DateofApproval,103)     AS DateofApproval,
ISNULL(AmountSold,0)/@Cost                  AS AmountSold


FROM AdvAcBasicDetail	ACBD				


INNER JOIN CustomerBasicDetail	CBD				ON	CBD.CustomerEntityId=ACBD.CustomerEntityId
												    AND CBD.EffectiveFromTimeKey<=@TimeKey 
													AND CBD.EffectiveToTimeKey>=@TimeKey
												    AND ACBD.EffectiveFromTimeKey<=@TimeKey 
													AND ACBD.EffectiveToTimeKey>=@TimeKey

INNER JOIN SaletoARC  SARC                      ON SARC.AccountID=ACBD.CustomerACID
												   AND SARC.EffectiveFromTimeKey<=@TimeKey 
												   AND SARC.EffectiveToTimeKey>=@TimeKey



OPTION(RECOMPILE)




GO