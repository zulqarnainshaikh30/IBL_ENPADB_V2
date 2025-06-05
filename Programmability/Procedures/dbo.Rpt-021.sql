SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



/*
CREATE BY		:	Baijayanti
CREATE DATE	    :	26-05-2021
DISCRIPTION		:   SMA Movement- Summary Report
*/

 create PROC [dbo].[Rpt-021]  
  @UserName AS VARCHAR(20)
 ,@MisLocation AS VARCHAR(20)
 ,@CustFacility AS VARCHAR(10)
 ,@FromDate   AS VARCHAR(15)
 ,@ToDate     AS VARCHAR(15)
 ,@Cost   AS FLOAT

AS 

--DECLARE 
-- @UserName AS VARCHAR(20)='D2K'	
--,@MisLocation AS VARCHAR(20)=''
--,@CustFacility AS VARCHAR(10)=3
--,@FromDate   AS VARCHAR(15)='30/09/2020'
--,@ToDate     AS VARCHAR(15)='21/11/2086'
--,@Cost   AS FLOAT=1


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

DECLARE	@From1		DATE=(SELECT Rdate FROM dbo.DateConvert(@FromDate))
DECLARE @To1		DATE=(SELECT Rdate FROM dbo.DateConvert(@ToDate))


SELECT  

------------------Movement of account from Normal to SMA-0--------------

ISNULL(SUM(CASE WHEN  MovementFromStatus='STD' AND  MovementToStatus='SMA_0'
         THEN  1
	     ELSE  0
	     END),0)                             AS Normal_SMA0_Ac,

ISNULL(SUM(CASE WHEN  MovementFromStatus='STD' AND  MovementToStatus='SMA_0'
         THEN  ISNULL(TotOsAcc,0)
	     ELSE  0
	     END),0)/@Cost                       AS Normal_SMA0_Amt,

----------------Movement of account from SMA-0 to Normal--------------

ISNULL(SUM(CASE WHEN  MovementFromStatus='SMA_0' AND  MovementToStatus='STD'
         THEN  1
	     ELSE  0
	     END),0)                             AS SMA0_Normal_Ac,

ISNULL(SUM(CASE WHEN  MovementFromStatus='SMA_0' AND  MovementToStatus='STD'
         THEN  ISNULL(TotOsAcc,0)
	     ELSE  0
	     END),0)/@Cost                       AS SMA0_Normal_Amt,

----------------Movement of account from SMA-0 to SMA-1--------------

ISNULL(SUM(CASE WHEN  MovementFromStatus='SMA_0' AND  MovementToStatus='SMA_1'
         THEN  1
	     ELSE  0
	     END),0)                             AS SMA0_SMA1_Ac,

ISNULL(SUM(CASE WHEN  MovementFromStatus='SMA_0' AND  MovementToStatus='SMA_1'
         THEN  ISNULL(TotOsAcc,0)
	     ELSE  0
	     END),0)/@Cost                       AS SMA0_SMA1_Amt,

----------------Movement of account from SMA-1 to Normal-----------------------------------

ISNULL(SUM(CASE WHEN  MovementFromStatus='SMA_1' AND  MovementToStatus='STD'
         THEN  1
	     ELSE  0
	     END),0)                             AS SMA1_Normal_Ac,

ISNULL(SUM(CASE WHEN  MovementFromStatus='SMA_1' AND  MovementToStatus='STD'
         THEN  ISNULL(TotOsAcc,0)
	     ELSE  0
	     END),0)/@Cost                       AS SMA1_Normal_Amt,

----------------Movement of account from SMA-1 to SMA-0-------------------------

ISNULL(SUM(CASE WHEN  MovementFromStatus='SMA_1' AND  MovementToStatus='SMA_0'
         THEN  1
	     ELSE  0
	     END),0)                             AS SMA1_SMA0_Ac,

ISNULL(SUM(CASE WHEN  MovementFromStatus='SMA_1' AND  MovementToStatus='SMA_0'
         THEN  ISNULL(TotOsAcc,0)
	     ELSE  0
	     END),0)/@Cost                       AS SMA1_SMA0_Amt,

----------------Movement of account from SMA-1 to SMA-2--------------------

ISNULL(SUM(CASE WHEN  MovementFromStatus='SMA_1' AND  MovementToStatus='SMA_2'
         THEN  1
	     ELSE  0
	     END),0)                             AS SMA1_SMA2_Ac,

ISNULL(SUM(CASE WHEN  MovementFromStatus='SMA_1' AND  MovementToStatus='SMA_2'
         THEN  ISNULL(TotOsAcc,0)
	     ELSE  0
	     END),0)/@Cost                       AS SMA1_SMA2_Amt,

----------------Movement of account from SMA-2 to SMA-1--------------

ISNULL(SUM(CASE WHEN  MovementFromStatus='SMA_2' AND  MovementToStatus='SMA_1'
         THEN  1
	     ELSE  0
	     END),0)                             AS SMA2_SMA1_Ac,

ISNULL(SUM(CASE WHEN  MovementFromStatus='SMA_2' AND  MovementToStatus='SMA_1'
         THEN  ISNULL(TotOsAcc,0)
	     ELSE  0
	     END),0)/@Cost                       AS SMA2_SMA1_Amt,

----------------Movement of account from SMA-2 to SMA-0-----------------

ISNULL(SUM(CASE WHEN  MovementFromStatus='SMA_2' AND  MovementToStatus='SMA_0'
         THEN  1
	     ELSE  0
	     END),0)                             AS SMA2_SMA0_Ac,

ISNULL(SUM(CASE WHEN  MovementFromStatus='SMA_2' AND  MovementToStatus='SMA_0'
         THEN  ISNULL(TotOsAcc,0)
	     ELSE  0
	     END),0)/@Cost                       AS SMA2_SMA0_Amt,

---------------Movement of account from SMA-2 to Normal------------------

ISNULL(SUM(CASE WHEN  MovementFromStatus='SMA_2' AND  MovementToStatus='STD'
         THEN  1
	     ELSE  0
	     END),0)                             AS SMA2_Normal_Ac,

ISNULL(SUM(CASE WHEN  MovementFromStatus='SMA_2' AND  MovementToStatus='STD'
         THEN  ISNULL(TotOsAcc,0)
	     ELSE  0
	     END),0)/@Cost                       AS SMA2_Normal_Amt,

---------------Movement of account from SMA-2 to NPA-----------------

ISNULL(SUM(CASE WHEN  MovementFromStatus='SMA_2' AND  MovementToStatus IN('SUB','DB1','DB2','DB3','LOS')
         THEN  1
	     ELSE  0
	     END),0)                             AS SMA2_NPA_Ac,

ISNULL(SUM(CASE WHEN  MovementFromStatus='SMA_2' AND  MovementToStatus IN('SUB','DB1','DB2','DB3','LOS')
         THEN  ISNULL(TotOsAcc,0)
	     ELSE  0
	     END),0)/@Cost                       AS SMA2_NPA_Amt



FROM Pro.ACCOUNT_MOVEMENT_HISTORY

WHERE @From1=MovementFromDate  AND @To1=MovementToDate      

OPTION(RECOMPILE)






GO