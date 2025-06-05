SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


/*================================================
	AUTHER : SUNIL NARSING
	CREATE DATE : 02-01-2020
	MODIFY DATE : 02-01-2020
	DESCRIPTION : MAIN_PROCEDURE_FOR_NPAMOVEMENT
	EXEC MAIN_PROCEDURE_FOR_NPAMOVEMENT '25506','M','25475','M'
=============================================================*/
--DECLARE @CurrentMonthEndTIMEKEY as Int=25506

CREATE PROCEDURE [dbo].[MAIN_PROCEDURE_FOR_NPAMOVEMENT]
--Declare
@CurrentMonthEndTIMEKEY INT  = 26479
,@NPAMOVE varchar(5)      ='M'             ------It comes from Table
,@PrevMonthEndTimekey AS Int  =26449       ----to set with query
,@MovementTypeFlag As Char(1) = 'M'
AS
BEGIN

--Set @NPAMOVE=(Select Status from NPAMasterCreationStatus)
--Set @PrevMonthEndTimekey=(Select LastMonthDateKey from SysDayMatrix where TimeKey=@CurrentMonthEndTIMEKEY)

DECLARE @SetID INT =(SELECT ISNULL(MAX(ISNULL(SETID,0)),0)+1 FROM [NPAProcessMonitor] WHERE TimeKey=@CurrentMonthEndTIMEKEY )

IF EXISTS (SELECT 1 FROM [NPAProcessMonitor] WHERE TimeKey=@CurrentMonthEndTIMEKEY)
BEGIN
 
 DELETE FROM [NPAProcessMonitor] WHERE TIMEKEY=@CurrentMonthEndTIMEKEY              ----to be modified as discussed 
 
END


-------------------Delete Data From NPA MOVEMENT IF IT PRESENT

IF EXISTS (SELECT 1 FROM NPAMovement WHERE TimeKey=@CurrentMonthEndTIMEKEY And Movement_Flag=@MovementTypeFlag)
BEGIN
 
 Delete from NPAMovement Where TimeKey = @CurrentMonthEndTIMEKEY And Movement_Flag=@MovementTypeFlag
 
END

IF (@MovementTypeFlag='M')

BEGIN

/*------------- InsertInitialDataColumnsForNPA -------------------------------------------------------*/
INSERT INTO [NPAProcessMonitor](UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'InsertInitialDataColumnsForNPA','RUNNING',GETDATE(),NULL,@CurrentMonthEndTIMEKEY,@SetID

EXEC [InsertInitialDataColumnsForNPA]  @CurrentMonthEndTIMEKEY=@CurrentMonthEndTIMEKEY,@NPAMOVE=@NPAMOVE,@PrevMonthEndTimekey=@PrevMonthEndTimekey,@MovementTypeFlag=@MovementTypeFlag

UPDATE [NPAProcessMonitor] SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE TIMEKEY=@CurrentMonthEndTIMEKEY AND DESCRIPTION='InsertInitialDataColumnsForNPA'

UPDATE [NPAProcessMonitor] SET TimeTaken_Min=Datediff(minute,ENDTIME,StartTime) WHERE TIMEKEY=@CurrentMonthEndTIMEKEY AND DESCRIPTION='InsertInitialDataColumnsForNPA'


/*------------- InsertInitialDataColumnsForSTD ------------------------------------------------------------------*/
INSERT INTO [NPAProcessMonitor](UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'InsertInitialDataColumnsForSTD','RUNNING',GETDATE(),NULL,@CurrentMonthEndTIMEKEY,@SetID

EXEC [InsertInitialDataColumnsForSTD] @CurrentMonthEndTIMEKEY=@CurrentMonthEndTIMEKEY,@NPAMOVE=@NPAMOVE,@PrevMonthEndTimekey=@PrevMonthEndTimekey,@MovementTypeFlag=@MovementTypeFlag

UPDATE [NPAProcessMonitor] SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE TIMEKEY=@CurrentMonthEndTIMEKEY AND DESCRIPTION='InsertInitialDataColumnsForSTD'

UPDATE [NPAProcessMonitor] SET TimeTaken_Min=Datediff(minute,ENDTIME,StartTime) WHERE TIMEKEY=@CurrentMonthEndTIMEKEY AND DESCRIPTION='InsertInitialDataColumnsForSTD'

/*------------- UpdateFinalDataCoulmnsANDMovementNature ------------------------------------------------------------*/
INSERT INTO [NPAProcessMonitor](UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'UpdateFinalDataCoulmnsANDMovementNature','RUNNING',GETDATE(),NULL,@CurrentMonthEndTIMEKEY,@SetID

EXEC [UpdateFinalDataCoulmnsANDMovementNature] @CurrentMonthEndTIMEKEY=@CurrentMonthEndTIMEKEY,@MovementTypeFlag=@MovementTypeFlag

UPDATE [NPAProcessMonitor] SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE TIMEKEY=@CurrentMonthEndTIMEKEY AND DESCRIPTION='UpdateFinalDataCoulmnsANDMovementNature'

UPDATE [NPAProcessMonitor] SET TimeTaken_Min=Datediff(minute,ENDTIME,StartTime) WHERE TIMEKEY=@CurrentMonthEndTIMEKEY AND DESCRIPTION='UpdateFinalDataCoulmnsANDMovementNature'

/*------------- UpdateMovementData ------------------------------------------------------------*/
INSERT INTO [NPAProcessMonitor](UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'UpdateMovementData','RUNNING',GETDATE(),NULL,@CurrentMonthEndTIMEKEY,@SetID

EXEC [UpdateMovementData] @CurrentMonthEndTIMEKEY=@CurrentMonthEndTIMEKEY,@MovementTypeFlag=@MovementTypeFlag

UPDATE [NPAProcessMonitor] SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE TIMEKEY=@CurrentMonthEndTIMEKEY AND DESCRIPTION='UpdateMovementData'

UPDATE [NPAProcessMonitor] SET TimeTaken_Min=Datediff(minute,ENDTIME,StartTime) WHERE TIMEKEY=@CurrentMonthEndTIMEKEY AND DESCRIPTION='UpdateMovementData'

/*------------- UpdateWriteOffData ------------------------------------------------------------*/
INSERT INTO [NPAProcessMonitor](UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'UpdateWriteOffData','RUNNING',GETDATE(),NULL,@CurrentMonthEndTIMEKEY,@SetID

EXEC [UpdateWriteOffData] @CurrentMonthEndTIMEKEY=@CurrentMonthEndTIMEKEY,@MovementTypeFlag=@MovementTypeFlag

UPDATE [NPAProcessMonitor] SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE TIMEKEY=@CurrentMonthEndTIMEKEY AND DESCRIPTION='UpdateWriteOffData'

UPDATE [NPAProcessMonitor] SET TimeTaken_Min=Datediff(minute,ENDTIME,StartTime) WHERE TIMEKEY=@CurrentMonthEndTIMEKEY AND DESCRIPTION='UpdateWriteOffData'

/*------------- UpdateARCSaleData ------------------------------------------------------------*/
--INSERT INTO [NPAProcessMonitor](UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
--SELECT ORIGINAL_LOGIN(),'UpdateARCSaleData','RUNNING',GETDATE(),NULL,@CurrentMonthEndTIMEKEY,@SetID

--EXEC [UpdateARCSaleData] @CurrentMonthEndTIMEKEY=@CurrentMonthEndTIMEKEY,@MovementTypeFlag=@MovementTypeFlag

--UPDATE [NPAProcessMonitor] SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE TIMEKEY=@CurrentMonthEndTIMEKEY AND DESCRIPTION='UpdateARCSaleData'

--UPDATE [NPAProcessMonitor] SET TimeTaken_Min=Datediff(minute,ENDTIME,StartTime) WHERE TIMEKEY=@CurrentMonthEndTIMEKEY AND DESCRIPTION='UpdateARCSaleData'

/*------------- UpdateTransferInOutData ------------------------------------------------------------*/
--INSERT INTO [NPAProcessMonitor](UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
--SELECT ORIGINAL_LOGIN(),'UpdateTransferInOutData','RUNNING',GETDATE(),NULL,@CurrentMonthEndTIMEKEY,@SetID

--EXEC [UpdateTransferInOutData] @CurrentMonthEndTIMEKEY=@CurrentMonthEndTIMEKEY,@MovementTypeFlag=@MovementTypeFlag

--UPDATE [NPAProcessMonitor] SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE TIMEKEY=@CurrentMonthEndTIMEKEY AND DESCRIPTION='UpdateTransferInOutData'

--UPDATE [NPAProcessMonitor] SET TimeTaken_Min=Datediff(minute,ENDTIME,StartTime) WHERE TIMEKEY=@CurrentMonthEndTIMEKEY AND DESCRIPTION='UpdateTransferInOutData'


/*------------- UpdateSTDtoSTDData ------------------------------------------------------------*/
INSERT INTO [NPAProcessMonitor](UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'UpdateSTDtoSTDData','RUNNING',GETDATE(),NULL,@CurrentMonthEndTIMEKEY,@SetID

EXEC [UpdateSTDtoSTDData] @CurrentMonthEndTIMEKEY=@CurrentMonthEndTIMEKEY,@PrevMonthEndTimekey=@PrevMonthEndTimekey,@MovementTypeFlag=@MovementTypeFlag

UPDATE [NPAProcessMonitor] SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE TIMEKEY=@CurrentMonthEndTIMEKEY AND DESCRIPTION='UpdateSTDtoSTDData'

UPDATE [NPAProcessMonitor] SET TimeTaken_Min=Datediff(minute,ENDTIME,StartTime) WHERE TIMEKEY=@CurrentMonthEndTIMEKEY AND DESCRIPTION='UpdateSTDtoSTDData'


/*------------- ValidationCheckNPAMovement ------------------------------------------------------------*/
INSERT INTO [NPAProcessMonitor](UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'ValidationCheckNPAMovement','RUNNING',GETDATE(),NULL,@CurrentMonthEndTIMEKEY,@SetID

EXEC [ValidationCheckNPAMovement] @CurrentMonthEndTIMEKEY=@CurrentMonthEndTIMEKEY,@MovementTypeFlag=@MovementTypeFlag

UPDATE [NPAProcessMonitor] SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE TIMEKEY=@CurrentMonthEndTIMEKEY AND DESCRIPTION='ValidationCheckNPAMovement'

UPDATE [NPAProcessMonitor] SET TimeTaken_Min=Datediff(minute,ENDTIME,StartTime) WHERE TIMEKEY=@CurrentMonthEndTIMEKEY AND DESCRIPTION='ValidationCheckNPAMovement'

END

ELSE 

BEGIN

/*------------- Quarterly Data Insert Query ------------------------------------------------------------*/
INSERT INTO [NPAProcessMonitor](UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'InsertQuarterlyData_NPAMOVEMENT','RUNNING',GETDATE(),NULL,@CurrentMonthEndTIMEKEY,@SetID

EXEC [InsertQuarterlyData_NPAMOVEMENT] @CurrentMonthEndTIMEKEY=@CurrentMonthEndTIMEKEY,@MovementTypeFlag=@MovementTypeFlag

UPDATE [NPAProcessMonitor] SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE TIMEKEY=@CurrentMonthEndTIMEKEY AND DESCRIPTION='InsertQuarterlyData_NPAMOVEMENT'

UPDATE [NPAProcessMonitor] SET TimeTaken_Min=Datediff(minute,ENDTIME,StartTime) WHERE TIMEKEY=@CurrentMonthEndTIMEKEY AND DESCRIPTION='InsertQuarterlyData_NPAMOVEMENT'

END


END
GO