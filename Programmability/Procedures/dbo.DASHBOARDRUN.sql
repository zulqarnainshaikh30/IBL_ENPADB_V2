SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROC [dbo].[DASHBOARDRUN]

@Flag as Int

AS

BEGIN

IF (@Flag=1)

BEGIN

		IF EXISTS(				                
					SELECT  1 FROM ENBD_MISDB.DBO.BANDAUDITSTATUS 
					WHERE StartDate=CAST(getdate() as Date) and BandName in ('SourceToStage','StageToTemp','TempToMain')
					 
				)	
				BEGIN
				   PRINT 2
				   

				   UPDATE ENBD_MISDB.DBO.BANDAUDITSTATUS
				   SET BandStatus='In Progress' 
				   Where BandStatus='Failed'

					EXEC msdb.dbo.sp_start_job N'ETLDataExtraction' ;  

				END

				ELSE

				BEGIN

			Update ENBD_MISDB.DBO.BANDAUDITSTATUS 
			Set StartDate=GETDATE()
			,CompletedCount=0,BandStatus='Pending' 
			Where BandName in ('SourceToStage','StageToTemp','TempToMain')

			Update BANDAUDITSTATUS Set StartDate=GETDATE(),CompletedCount=0,BandStatus='Not Started' 
			Where BandName in ('ASSET CLASSIFICATION')
			
			Update ENBD_MISDB.DBO.BANDAUDITSTATUS set BandStatus='Started' where BandName='SourceToStage'
			
			Update ENBD_MISDB.DBO.BANDAUDITSTATUS set BandStatus='In Progress' where BandName='SourceToStage'

			EXEC msdb.dbo.sp_start_job N'ETLDataExtraction' ;  

			END


END


IF (@Flag=2)

BEGIN

		IF EXISTS(				                
					SELECT  1 FROM BANDAUDITSTATUS WHERE StartDate=CAST(getdate() as Date) and BandName in ('ASSET CLASSIFICATION')
					 
				)	
				BEGIN
				   PRINT 2

				   Update BANDAUDITSTATUS Set StartDate=GETDATE(),CompletedCount=1,BandStatus='Pending' Where BandName in ('ASSET CLASSIFICATION')
			
			Update BANDAUDITSTATUS set BandStatus='Started' where BandName='ASSET CLASSIFICATION'
			
			Update BANDAUDITSTATUS set BandStatus='In Progress' where BandName='ASSET CLASSIFICATION'

					--EXEC msdb.dbo.sp_start_job N'ENBD_Extraction' ;  
					update PRO.AclRunningProcessStatus set Completed='N' WHERE id>1
						EXEC msdb.dbo.sp_start_job N'ETLDataExtraction'

						Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='ASSET CLASSIFICATION'

						Update BANDAUDITSTATUS set BandStatus='Completed' where BandName='ASSET CLASSIFICATION' and TotalCount=CompletedCount


				END

				ELSE

				BEGIN

			Update BANDAUDITSTATUS Set StartDate=GETDATE(),CompletedCount=1,BandStatus='Pending' Where BandName in ('ASSET CLASSIFICATION')
			
			Update BANDAUDITSTATUS set BandStatus='Started' where BandName='ASSET CLASSIFICATION'
			
			Update BANDAUDITSTATUS set BandStatus='In Progress' where BandName='ASSET CLASSIFICATION'

			--EXEC msdb.dbo.sp_start_job N'ENBD_Extraction' ;  

			update PRO.AclRunningProcessStatus set Completed='N' WHERE id>1
						EXEC msdb.dbo.sp_start_job N'ETLDataExtraction'

						Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='ASSET CLASSIFICATION'

						Update BANDAUDITSTATUS set BandStatus='Completed' where BandName='ASSET CLASSIFICATION' and TotalCount=CompletedCount

			END


END



-----------------------------------------
/*
DELETE FROM ENBD_STGDB.dbo.Package_AUDIT WHERE Execution_date=CAST(GETDATE() As Date)

DELETE FROM pro.ProcessMonitor WHERE CAST(StartTime as Date)=CAST(GETDATE() As Date)
--------------------------

Insert into ENBD_STGDB.dbo.Package_AUDIT(Execution_date,DataBaseName,PackageName,TableName,ExecutionStartTime,ExecutionStatus)
Select GETDATE(),'ENBD_STGDB','SourceToStageDB','Customer',GETDATE(),0
UNION ALL
Select GETDATE(),'ENBD_STGDB','SourceToStageDB','Account1',GETDATE(),0
UNION ALL
Select GETDATE(),'ENBD_STGDB','SourceToStageDB','Account2',GETDATE(),0

WAITFOR DELAY '00:00:30'

Update ENBD_STGDB.dbo.Package_AUDIT set ExecutionEndTime=GETDATE(),ExecutionStatus=1
Where TableName='Customer' 

Update ENBD_STGDB.dbo.Package_AUDIT set TimeDuration_Sec=DateDiff(ss,ExecutionStartTime,ExecutionEndTime)
Where TableName='Customer' 

Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='SourceToStage'

WAITFOR DELAY '00:00:30'

Update ENBD_STGDB.dbo.Package_AUDIT set ExecutionEndTime=GETDATE(),ExecutionStatus=1
Where TableName='Account1' 

Update ENBD_STGDB.dbo.Package_AUDIT set TimeDuration_Sec=DateDiff(ss,ExecutionStartTime,ExecutionEndTime)
Where TableName='Account1' 

Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='SourceToStage'

WAITFOR DELAY '00:00:30'

Update ENBD_STGDB.dbo.Package_AUDIT set ExecutionEndTime=GETDATE(),ExecutionStatus=1
Where TableName='Account2' 

Update ENBD_STGDB.dbo.Package_AUDIT set TimeDuration_Sec=DateDiff(ss,ExecutionStartTime,ExecutionEndTime)
Where TableName='Account2' 

Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='SourceToStage'

Update BANDAUDITSTATUS set BandStatus='Completed' where BandName='SourceToStage' and TotalCount=CompletedCount

-------------------

Update BANDAUDITSTATUS set BandStatus='In Progress' where BandName='StageToTemp'

Insert into ENBD_STGDB.dbo.Package_AUDIT(Execution_date,DataBaseName,PackageName,TableName,ExecutionStartTime,ExecutionStatus)
Select GETDATE(),'ENBD_TEMPDB','StageToTempDB','TempAdvAcBasicDetail',GETDATE(),0

WAITFOR DELAY '00:00:30'

Update ENBD_STGDB.dbo.Package_AUDIT set ExecutionEndTime=GETDATE(),ExecutionStatus=1
Where TableName='TempAdvAcBasicDetail' 

Update ENBD_STGDB.dbo.Package_AUDIT set TimeDuration_Sec=DateDiff(ss,ExecutionStartTime,ExecutionEndTime)
Where TableName='TempAdvAcBasicDetail' 

Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='StageToTemp'


Insert into ENBD_STGDB.dbo.Package_AUDIT(Execution_date,DataBaseName,PackageName,TableName,ExecutionStartTime,ExecutionStatus)
Select GETDATE(),'ENBD_TEMPDB','StageToTempDB','TempCustomerBasicDetail',GETDATE(),0

WAITFOR DELAY '00:00:30'

Update ENBD_STGDB.dbo.Package_AUDIT set ExecutionEndTime=GETDATE(),ExecutionStatus=1
Where TableName='TempCustomerBasicDetail' 

Update ENBD_STGDB.dbo.Package_AUDIT set TimeDuration_Sec=DateDiff(ss,ExecutionStartTime,ExecutionEndTime)
Where TableName='TempCustomerBasicDetail' 

Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='StageToTemp'


Insert into ENBD_STGDB.dbo.Package_AUDIT(Execution_date,DataBaseName,PackageName,TableName,ExecutionStartTime,ExecutionStatus)
Select GETDATE(),'ENBD_TEMPDB','StageToTempDB','TempAdvAcBalanceDetail',GETDATE(),0

WAITFOR DELAY '00:00:30'

Update ENBD_STGDB.dbo.Package_AUDIT set ExecutionEndTime=GETDATE(),ExecutionStatus=1
Where TableName='TempAdvAcBalanceDetail' 

Update ENBD_STGDB.dbo.Package_AUDIT set TimeDuration_Sec=DateDiff(ss,ExecutionStartTime,ExecutionEndTime)
Where TableName='TempAdvAcBalanceDetail' 

Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='StageToTemp'

Update BANDAUDITSTATUS set BandStatus='Completed' where BandName='StageToTemp' and TotalCount=CompletedCount

----------------------------------


Update BANDAUDITSTATUS set BandStatus='In Progress' where BandName='TempToMain'

Insert into ENBD_STGDB.dbo.Package_AUDIT(Execution_date,DataBaseName,PackageName,TableName,ExecutionStartTime,ExecutionStatus)
Select GETDATE(),'ENBD_TEMPDB','TempToMainDB','AdvAcBasicDetail',GETDATE(),0

WAITFOR DELAY '00:00:30'

Update ENBD_STGDB.dbo.Package_AUDIT set ExecutionEndTime=GETDATE(),ExecutionStatus=1
Where TableName='AdvAcBasicDetail' 

Update ENBD_STGDB.dbo.Package_AUDIT set TimeDuration_Sec=DateDiff(ss,ExecutionStartTime,ExecutionEndTime)
Where TableName='AdvAcBasicDetail' 

Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='TempToMain'


Insert into ENBD_STGDB.dbo.Package_AUDIT(Execution_date,DataBaseName,PackageName,TableName,ExecutionStartTime,ExecutionStatus)
Select GETDATE(),'ENBD_TEMPDB','TempToMainDB','CustomerBasicDetail',GETDATE(),0

WAITFOR DELAY '00:00:30'

Update ENBD_STGDB.dbo.Package_AUDIT set ExecutionEndTime=GETDATE(),ExecutionStatus=1
Where TableName='CustomerBasicDetail' 

Update ENBD_STGDB.dbo.Package_AUDIT set TimeDuration_Sec=DateDiff(ss,ExecutionStartTime,ExecutionEndTime)
Where TableName='CustomerBasicDetail' 

Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='TempToMain'


Insert into ENBD_STGDB.dbo.Package_AUDIT(Execution_date,DataBaseName,PackageName,TableName,ExecutionStartTime,ExecutionStatus)
Select GETDATE(),'ENBD_TEMPDB','TempToMainDB','AdvAcBalanceDetail',GETDATE(),0

WAITFOR DELAY '00:00:30'

Update ENBD_STGDB.dbo.Package_AUDIT set ExecutionEndTime=GETDATE(),ExecutionStatus=1
Where TableName='AdvAcBalanceDetail' 

Update ENBD_STGDB.dbo.Package_AUDIT set TimeDuration_Sec=DateDiff(ss,ExecutionStartTime,ExecutionEndTime)
Where TableName='AdvAcBalanceDetail' 

Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='TempToMain'

Update BANDAUDITSTATUS set BandStatus='Completed' where BandName='TempToMain' and TotalCount=CompletedCount

----------------------------------



----------------------------------


Update BANDAUDITSTATUS set BandStatus='In Progress' where BandName='ACL Degradation'

INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'Reference_Period_Calculation','RUNNING',GETDATE(),NULL,25864,1

WAITFOR DELAY '00:00:30'


UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE  TIMEKEY=25864 AND DESCRIPTION='REFERENCE_PERIOD_CALCULATION'


Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='ACL Degradation'


INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'DPD_Calculation','RUNNING',GETDATE(),NULL,25864,1

WAITFOR DELAY '00:00:30'

UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE TIMEKEY=25864 AND DESCRIPTION='DPD_Calculation'


Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='ACL Degradation'


INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'NPA_Date_Calculation','RUNNING',GETDATE(),NULL,25864,1

WAITFOR DELAY '00:00:30'

UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE  TIMEKEY=25864 AND DESCRIPTION='NPA_Date_Calculation'


Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='ACL Degradation'

Update BANDAUDITSTATUS set BandStatus='Completed' where BandName='ACL Degradation' and TotalCount=CompletedCount

----------------------------------


Update BANDAUDITSTATUS set BandStatus='In Progress' where BandName='ACL Upgradation'

INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'Upgrade_Customer_Account','RUNNING',GETDATE(),NULL,25864,1

WAITFOR DELAY '00:00:30'


UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE TIMEKEY=25864 AND DESCRIPTION='Upgrade_Customer_Account'



Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='ACL Upgradation'


Update BANDAUDITSTATUS set BandStatus='Completed' where BandName='ACL Upgradation' and TotalCount=CompletedCount

----------------------------------
*/
END

GO