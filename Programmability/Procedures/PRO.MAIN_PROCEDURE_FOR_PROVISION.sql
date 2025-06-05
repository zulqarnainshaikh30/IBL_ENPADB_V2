SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
/*============================================================
	AUTHER : SANJEEV KUMAR SHARMA
	CREATE DATE : 21-11-2017
	MODIFY DATE : 21-11-2017
	DESCRIPTION : MAIN PROCESS FOR ASSET CLASSFIFCATION
	EXEC [PRO].[MAIN_PROCEDURE_FOR_PROVISION]  24864
=============================================================*/
CREATE PROCEDURE [PRO].[MAIN_PROCEDURE_FOR_PROVISION]
@TIMEKEY INT
AS
BEGIN

/*--------------------PROCESS START FOR PROVISION--------------------------------------*/

DECLARE @SetID INT =(SELECT ISNULL(MAX(ISNULL(SETID,0)),0)+1 FROM [PRO].[ProcessMonitor] WHERE TimeKey=@TIMEKEY )

IF EXISTS (SELECT 1 FROM [PRO].[ProcessMonitor] WHERE TimeKey=@TIMEKEY)
BEGIN
 
 DELETE FROM [PRO].[ProcessMonitor] WHERE TIMEKEY=@TIMEKEY

END

/*-------------Getting DPD AccountWise NPADAYS-------------------------------------------------------*/
INSERT INTO [PRO].[ProcessMonitor](UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'Getting_DPD_AccountWise_NPADAYS','RUNNING',GETDATE(),NULL,@TIMEKEY,@SetID

EXEC [PRO].[Getting_DPD_AccountWise_NPADAYS]  @TIMEKEY=@TIMEKEY

UPDATE [PRO].[ProcessMonitor] SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE TIMEKEY=@TIMEKEY AND DESCRIPTION='Getting_DPD_AccountWise_NPADAYS'


/*-------------Update ProvisionKey AccountWise------------------------------------------------------------------*/
INSERT INTO [PRO].[ProcessMonitor](UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'UpdateProvisionKey_AccountWise','RUNNING',GETDATE(),NULL,@TIMEKEY,@SetID

EXEC [PRO].[UpdateProvisionKey_AccountWise] @TIMEKEY=@TIMEKEY

UPDATE [PRO].[ProcessMonitor] SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE TIMEKEY=@TIMEKEY AND DESCRIPTION='UpdateProvisionKey_AccountWise'


/*-------------Update NetBalance AccountWise------------------------------------------------------------*/

INSERT INTO [PRO].[ProcessMonitor](UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'UpdateNetBalance_AccountWise','RUNNING',GETDATE(),NULL,@TIMEKEY,@SetID

EXEC [PRO].[UpdateNetBalance_AccountWise] @TIMEKEY=@TIMEKEY

UPDATE [PRO].[ProcessMonitor] SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE TIMEKEY=@TIMEKEY AND DESCRIPTION='UpdateNetBalance_AccountWise'

/*------------ Security Appropriation------------------------------------------------------------*/

INSERT INTO [PRO].[ProcessMonitor](UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'SecurityAppropriation','RUNNING',GETDATE(),NULL,@TIMEKEY,@SetID

EXEC [pro].[SecurityAppropriation] @TIMEKEY=@TIMEKEY

UPDATE [PRO].[ProcessMonitor] SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE TIMEKEY=@TIMEKEY AND DESCRIPTION='SecurityAppropriation'

/*-------------Provision Computation Secured-------------------------------------------------------------------------------------*/
INSERT INTO [PRO].[ProcessMonitor](UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'ProvisionComputationSecured','RUNNING',GETDATE(),NULL,@TIMEKEY,@SetID

EXEC [PRO].[ProvisionComputationSecured]  @TIMEKEY=@TIMEKEY

UPDATE [PRO].[ProcessMonitor] SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE TIMEKEY=@TIMEKEY AND DESCRIPTION='ProvisionComputationSecured'

/*-------------Updation Provision Computation UnSecured -------------------------------------------------------------------------------------*/
INSERT INTO [PRO].[ProcessMonitor](UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'UpdationProvisionComputationUnSecured','RUNNING',GETDATE(),NULL,@TIMEKEY,@SetID

EXEC [PRO].[UpdationProvisionComputationUnSecured] @TIMEKEY=@TIMEKEY

UPDATE [PRO].[ProcessMonitor] SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE TIMEKEY=@TIMEKEY AND DESCRIPTION='UpdationProvisionComputationUnSecured'

/*----------------------------Updation Total Provision-------------------------------------------------------------------------------------*/
INSERT INTO [PRO].[ProcessMonitor](UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'UpdationTotalProvision','RUNNING',GETDATE(),NULL,@TIMEKEY,@SetID

EXEC [PRO].[UpdationTotalProvision] @TIMEKEY=@TIMEKEY

UPDATE [PRO].[PROCESSMONITOR] SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE TIMEKEY=@TIMEKEY AND DESCRIPTION='UpdationTotalProvision'

/*----------------------------MARKING OF FLG PROCESS-------------------------------------------------------------------------------------*/
INSERT INTO [PRO].[ProcessMonitor](UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'MarkingFlgProcessing','RUNNING',GETDATE(),NULL,@TIMEKEY,@SetID

EXEC [PRO].[MarkingFlgProcessing] @TIMEKEY=@TIMEKEY

UPDATE [PRO].[PROCESSMONITOR] SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE TIMEKEY=@TIMEKEY AND DESCRIPTION='MarkingFlgProcessing'

/*-------------------------------------------------PROCESS END FOR PROVISION----------------------------------------------------------------*/
END




GO