SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



/*
CREATE BY		:	Baijayanti
CREATE DATE	    :	08-04-2021
DISCRIPTION		:   ACL Process Summary
*/

create PROC [dbo].[Rpt-006]  
  @UserName AS VARCHAR(20)
 ,@MisLocation AS VARCHAR(20)
 ,@CustFacility AS VARCHAR(10)
 ,@TimeKey AS INT
AS 

--DECLARE 
-- @UserName AS VARCHAR(20)='D2K'	
--,@MisLocation AS VARCHAR(20)=''
--,@CustFacility AS VARCHAR(10)=3
--,@TimeKey AS INT=25811


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

IF(OBJECT_ID('tempdb..#DATA') IS NOT NULL)
DROP TABLE #DATA


SELECT  
CASE WHEN [Description]= 'InsertDataforAssetClassficationAUSFB'		         THEN 'Data Preparation Process'
	 WHEN [Description]= 'Reference_Period_Calculation'		      			 THEN 'Flags Initialisation Process'
	 WHEN [Description]= 'DPD_Calculation'		                      		 THEN 'Default Computation Process'
	 WHEN [Description]= 'Marking_InMonthMark_Customer_Account_level'		 THEN 'A/C Level Degradation Process'
	 WHEN [Description]= 'Marking_FlgDeg_Degreason'		          			 THEN 'NPA Date Assignment Process'
	 WHEN [Description]= 'MaxDPD_ReferencePeriod_Calculation'		  		 THEN 'Security Erosion Process & NPA Ageing Process'
	 WHEN [Description]= 'NPA_Date_Calculation'		              			 THEN 'Customer Level NPA marking & NPA Date Assignment Process'
	 WHEN [Description]= 'Update_AssetClass'		                  		 THEN 'NPA Ageing Process'
	 WHEN [Description]= 'NPA_Erosion_Aging'	                  			 THEN 'Cross Portfolio Percolation Process'
	 WHEN [Description]= 'Final_AssetClass_Npadate'		          			 THEN 'Upgradation Process'
	 WHEN [Description]= 'Upgrade_Customer_Account'		          			 THEN 'Asset Class Validation Process through Control Scrips'
	 WHEN [Description]= 'SMA_MARKING'		                          		 THEN 'Provision Computation Process (RBI Norms)'
	 WHEN [Description]= 'Marking_FlgPNPA'		                      		 THEN 'Provision Computation Process (Bank Norms)'
	 WHEN [Description]= 'Marking_NPA_Reason_NPAAccount'      	             THEN 'Manual Confirmation (Daily MOC)'
	 WHEN [Description] IN('UpdateProvisionKey_AccountWise','UpdateNetBalance_AccountWise','GovtGuarAppropriation','SecurityAppropriation',
	                       'UpdateUsedRV','ProvisionComputationSecured','GovtGurCoverAmount','UpdationProvisionComputationUnSecured','UpdationTotalProvision')
     THEN 'Provision Processing'
	 WHEN [Description] IN('Reverse Feed Data Preparation Process','Data Updation to Main Tables')
	 THEN 'Reverse Feed Data Preparation Process'
	 WHEN [Description]='InsertDataIntoHistTable'                            THEN 'InsertDataIntoHistTable'
	 ELSE [Description]
	 END                                                      AS ProcessName,
StartTime                                                     AS ExecutionStartTime,
EndTime                                                       AS ExecutionEndTime,
TimeTaken_Sec                                                 AS TimeDuration_Sec,
Mode                                                          AS ExecutionStatus                           
INTO #DATA
FROM Pro.ProcessMonitor		

WHERE TimeKey=@TimeKey

OPTION(RECOMPILE)

----------------------Final Selection-----------
 
SELECT 
ProcessName,
MIN(ExecutionStartTime)                                           AS ExecutionStartTime,
MAX(ExecutionEndTime)                                             AS ExecutionEndTime,
DATEDIFF(SS,MIN(ExecutionStartTime),MAX(ExecutionEndTime))        AS TimeDuration_Sec,
ExecutionStatus
FROM #DATA

GROUP BY ProcessName,ExecutionStatus

ORDER BY ExecutionStartTime

OPTION(RECOMPILE)

DROP TABLE #DATA



GO