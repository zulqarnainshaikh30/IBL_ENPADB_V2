SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO




/*
CREATE BY		:	Baijayanti
CREATE DATE	    :	07-04-2021
DISCRIPTION		:   Src to stage - Src ys-wise ETL Detail
*/

create PROC [dbo].[Rpt-002]  
  @UserName AS VARCHAR(20)
 ,@MisLocation AS VARCHAR(20)
 ,@CustFacility AS VARCHAR(10)
 ,@TimeKey AS INT
AS 

--DECLARE 
-- @UserName AS VARCHAR(20)='D2K'	
--,@MisLocation AS VARCHAR(20)=''
--,@CustFacility AS VARCHAR(10)=3
--,@TimeKey AS INT=26030


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

DECLARE @CurDate DATE=(SELECT [DATE] FROM SysDayMatrix WHERE TimeKey=@TimeKey)



SELECT  
SourceSystemName                         AS [Source System Name],
PA.TableName                             AS TableName,
CONVERT(VARCHAR(15),ExecutionStartTime,103) + ' ' + CONVERT(VARCHAR(15),ExecutionStartTime,108)                    AS ExecutionStartTime,
CONVERT(VARCHAR(15),ExecutionEndTime,103) + ' ' + CONVERT(VARCHAR(15),ExecutionEndTime,108)                        AS ExecutionEndTime,
TimeDuration_Sec                         AS TimeDuration_Sec,
CASE WHEN ExecutionStatus=1
     THEN 'Completed'
	 ELSE 'Running'
	 END                                 AS ExecutionStatus


FROM AUSFB_STGDB..Package_AUDIT		PA			
INNER JOIN AUSFB_STGDB..ETLSolutionParameterforReport   ETLSPR  ON ETLSPR.TargetTableName=PA.TableName
                                                                    AND ETLSPR.EffectiveFromTimeKey<=@TimeKey	
														            AND ETLSPR.EffectiveToTimeKey>=@TimeKey

WHERE Execution_date=@CurDate AND PackageName='SourceToStageDB_All'

OPTION(RECOMPILE)








GO