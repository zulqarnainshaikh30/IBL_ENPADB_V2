SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--select * from SYSdatamatrix where  currentstatus='C' -26479
--update SYSdatamatrix set currentstatus='U' where TimeKey =26479
--update SYSdatamatrix set currentstatus='C' where TimeKey =26936
/*================================================
AUTHER : TRILOKI KHANNA
CREATE DATE : 27-11-2019
MODIFY DATE :27-11-2019
DESCRIPTION : MAIN PROCESS FOR ASSET CLASSFIFCATION
--EXEC [PRO].[MAINPROECESSFORASSETCLASSFICATION]  @TIMEKEY=25841
=============================================================*/
CREATE PROCEDURE [PRO].[MAINPROECESSFORASSETCLASSFICATION] --26929
 --@TIMEKEY INT
 WITH RECOMPILE
AS
BEGIN
   SET NOCOUNT ON;
/*------------------PROCESS START FOR ASSET CLASSFICATION------------------*/
DECLARE @TIMEKEY INT = (SELECT TIMEKEY FROM [dbo].Automate_Advances where EXT_FLG='Y')
DECLARE @SetID INT =(SELECT ISNULL(MAX(SETID),0)+1 FROM PRO.ProcessMonitor WHERE TimeKey=@TIMEKEY)
DECLARE @PROCESSDAY VARCHAR(10)=DATENAME(WEEKDAY, (select date from SysDayMatrix where TimeKey=@TIMEKEY))
DECLARE @PROCESSMONTH DATE =(select date from SysDayMatrix where TimeKey=@TIMEKEY)

/*------------------InsertDataforAssetClassficationIBL------------------*/

PRINT 0
INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'InsertDataforAssetClassficationIBL','RUNNING',GETDATE(),NULL,@TIMEKEY,@SetID

EXEC [PRO].[InsertDataforAssetClassficationIBL] @TIMEKEY=@TIMEKEY

UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE IdentityKey = (SELECT IDENT_CURRENT('PRO.PROCESSMONITOR')) AND  TIMEKEY=@TIMEKEY AND DESCRIPTION='InsertDataforAssetClassficationIBL'


IF (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='InsertDataforAssetClassficationIBL')='N'    
BEGIN
  RETURN;
  END
  ELSE
  BEGIn
  --------------Added for DashBoard 
	Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='ASSET CLASSIFICATION'
	
END

/*------------------REFERENCE PERIOD CALCULATION------------------*/




Print 1
IF (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='InsertDataforAssetClassficationIBL')='Y'
AND (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='Reference_Period_Calculation')='N'    
BEGIN	

INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'Reference_Period_Calculation','RUNNING',GETDATE(),NULL,@TIMEKEY,@SetID

EXEC PRO.Reference_Period_Calculation  @TIMEKEY=@TIMEKEY

IF OBJECT_ID('PRO.ACCOUNTCAL_BKP','U') IS NOT NULL
   DROP TABLE PRO.ACCOUNTCAL_BKP

   select * into pro.accountcal_bkp from pro.accountcal


IF OBJECT_ID('PRO.CUSTOMERCAL_BKP','U') IS NOT NULL
   DROP TABLE PRO.CUSTOMERCAL_BKP

   select * into pro.CustomerCal_bkp from pro.CustomerCal

UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE IdentityKey = (SELECT IDENT_CURRENT('PRO.PROCESSMONITOR')) AND  TIMEKEY=@TIMEKEY AND DESCRIPTION='REFERENCE_PERIOD_CALCULATION'
END

IF (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='Reference_Period_Calculation')='N'    
BEGIN
  RETURN;
  END
  ELSE
  BEGIn
  --------------Added for DashBoard 04-03-2021
	Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='ASSET CLASSIFICATION'
	
END



IF (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='Reference_Period_Calculation')='Y'
AND (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='DPD_Calculation')='N'    
BEGIN

/*------------------DPD Calculation------------------*/
Print 2
INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'DPD_Calculation','RUNNING',GETDATE(),NULL,@TIMEKEY,@SetID

EXEC PRO.DPD_Calculation @TIMEKEY=@TIMEKEY

UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE IdentityKey = (SELECT IDENT_CURRENT('PRO.PROCESSMONITOR')) AND  TIMEKEY=@TIMEKEY AND DESCRIPTION='DPD_Calculation'
END

IF (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='DPD_Calculation')='N' 
BEGIN
  RETURN;
END
 ELSE
  BEGIn
  --------------Added for DashBoard 04-03-2021
	Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='ASSET CLASSIFICATION'
	
END

/*------------------Marking_InMonthMark_Customer_Account_level------------------*/
Print 3
IF (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='DPD_Calculation')='Y'
AND (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='Marking_InMonthMark_Customer_Account_level')='N'    
BEGIN

INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'Marking_InMonthMark_Customer_Account_level','RUNNING',GETDATE(),NULL,@TIMEKEY,@SetID

EXEC PRO.Marking_InMonthMark_Customer_Account_level @TIMEKEY=@TIMEKEY

UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE IdentityKey = (SELECT IDENT_CURRENT('PRO.PROCESSMONITOR')) AND  TIMEKEY=@TIMEKEY AND DESCRIPTION='Marking_InMonthMark_Customer_Account_level'
END

IF (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='Marking_InMonthMark_Customer_Account_level')='N'    
BEGIN
  RETURN;
END
 ELSE
  BEGIn
  --------------Added for DashBoard 04-03-2021
	Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='ASSET CLASSIFICATION'
	
END

IF (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='Marking_InMonthMark_Customer_Account_level')='Y'
AND (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='Marking_FlgDeg_Degreason')='N'    
BEGIN
/*------------------Marking FlgDeg Degreason------------------*/
Print 4
INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'Marking_FlgDeg_Degreason','RUNNING',GETDATE(),NULL,@TIMEKEY,@SetID

EXEC PRO.Marking_FlgDeg_Degreason @TIMEKEY=@TIMEKEY

UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE IdentityKey = (SELECT IDENT_CURRENT('PRO.PROCESSMONITOR')) AND  TIMEKEY=@TIMEKEY AND DESCRIPTION='Marking_FlgDeg_Degreason'
END

IF (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='Marking_FlgDeg_Degreason')='N'    
BEGIN
  RETURN;
END
 ELSE
  BEGIn
  --------------Added for DashBoard 04-03-2021
	Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='ASSET CLASSIFICATION'
	
END

IF (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='Marking_FlgDeg_Degreason')='Y'
AND (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='MaxDPD_ReferencePeriod_Calculation')='N'    
BEGIN

/*------------------MaxDPD REGARDING  ReferencePeriod Calculation------------------*/
Print 5
INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'MaxDPD_ReferencePeriod_Calculation','RUNNING',GETDATE(),NULL,@TIMEKEY,@SetID

EXEC PRO.MaxDPD_ReferencePeriod_Calculation @TIMEKEY=@TIMEKEY

UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE IdentityKey = (SELECT IDENT_CURRENT('PRO.PROCESSMONITOR')) AND  TIMEKEY=@TIMEKEY AND DESCRIPTION='MaxDPD_ReferencePeriod_Calculation'

END
IF (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='MaxDPD_ReferencePeriod_Calculation')='N'    
BEGIN
   RETURN
END
 ELSE
  BEGIn
  --------------Added for DashBoard 04-03-2021
	Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='ASSET CLASSIFICATION'
	
END
/*------------------NPA Date Calculation------------------*/
Print 6
IF (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='MaxDPD_ReferencePeriod_Calculation')='Y'
AND (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='NPA_Date_Calculation')='N'    
BEGIN
INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'NPA_Date_Calculation','RUNNING',GETDATE(),NULL,@TIMEKEY,@SetID

EXEC PRO.NPA_Date_Calculation  @TIMEKEY=@TIMEKEY

UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE IdentityKey = (SELECT IDENT_CURRENT('PRO.PROCESSMONITOR')) AND  TIMEKEY=@TIMEKEY AND DESCRIPTION='NPA_Date_Calculation'
END
IF (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='NPA_Date_Calculation')='N'    
BEGIN
   RETURN
END 
 ELSE
  BEGIn
  --------------Added for DashBoard 04-03-2021
	Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='ASSET CLASSIFICATION'
	
END
/*------------------Update AssetClass------------------*/
IF (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='NPA_Date_Calculation')='Y'
AND (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='Update_AssetClass')='N'    
BEGIN

Print 7
INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'Update_AssetClass','RUNNING',GETDATE(),NULL,@TIMEKEY,@SetID

EXEC PRO.Update_AssetClass @TIMEKEY=@TIMEKEY

UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE IdentityKey = (SELECT IDENT_CURRENT('PRO.PROCESSMONITOR')) AND  TIMEKEY=@TIMEKEY AND DESCRIPTION='Update_AssetClass'

END
IF (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='Update_AssetClass')='N' 
BEGIN
   RETURN;
END
 ELSE
  BEGIn
  --------------Added for DashBoard 04-03-2021
	Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='ASSET CLASSIFICATION'
	
END
/*------------------NPA Erosion Aging------------------*/
IF (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='Update_AssetClass')='Y'
AND (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='NPA_Erosion_Aging')='N'    
BEGIN
Print 8
INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'NPA_Erosion_Aging','RUNNING',GETDATE(),NULL,@TIMEKEY,@SetID

EXEC PRO.NPA_Erosion_Aging @TIMEKEY=@TIMEKEY

UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE IdentityKey = (SELECT IDENT_CURRENT('PRO.PROCESSMONITOR')) AND  TIMEKEY=@TIMEKEY AND DESCRIPTION='NPA_Erosion_Aging'
END
IF (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='NPA_Erosion_Aging')='N' 
BEGIN
   RETURN;
END
 ELSE
  BEGIn
  --------------Added for DashBoard 04-03-2021
	Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='ASSET CLASSIFICATION'
	
END

/*------------------Final AssetClass Npadate------------------*/
Print 9
IF (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='NPA_Erosion_Aging')='Y'
AND (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='Final_AssetClass_Npadate')='N'    
BEGIN

INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'Final_AssetClass_Npadate','RUNNING',GETDATE(),NULL,@TIMEKEY,@SetID

EXEC PRO.Final_AssetClass_Npadate @TIMEKEY=@TIMEKEY

UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE IdentityKey = (SELECT IDENT_CURRENT('PRO.PROCESSMONITOR')) AND  TIMEKEY=@TIMEKEY AND DESCRIPTION='Final_AssetClass_Npadate'
END 

IF (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='Final_AssetClass_Npadate')='N'  
BEGIN
   RETURN;
END 
ELSE
  BEGIn
  --------------Added for DashBoard 04-03-2021
	Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='ASSET CLASSIFICATION'
	
END
/*------------------UPGRAD CUSTOMER ACCOUNT------------------*/

IF (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='Final_AssetClass_Npadate')='Y'
AND (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='Upgrade_Customer_Account')='N'    
BEGIN
Print 10
INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'Upgrade_Customer_Account','RUNNING',GETDATE(),NULL,@TIMEKEY,@SetID

EXEC PRO.Upgrade_Customer_Account @TIMEKEY=@TIMEKEY



UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE IdentityKey = (SELECT IDENT_CURRENT('PRO.PROCESSMONITOR')) AND  TIMEKEY=@TIMEKEY AND DESCRIPTION='Upgrade_Customer_Account'
END
IF(SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='Upgrade_Customer_Account')='N'
BEGIN
   RETURN;
END
ELSE
  BEGIn
  --------------Added for DashBoard 04-03-2021
	Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='ASSET CLASSIFICATION'
	
END
/*------------------MARKING SMA------------------*/
Print 11
IF (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='Upgrade_Customer_Account')='Y'
AND (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='SMA_MARKING')='N'    
BEGIN


INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'SMA_MARKING','RUNNING',GETDATE(),NULL,@TIMEKEY,@SetID

EXEC PRO.SMA_MARKING @TIMEKEY=@TIMEKEY

UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE IdentityKey = (SELECT IDENT_CURRENT('PRO.PROCESSMONITOR')) AND  TIMEKEY=@TIMEKEY AND DESCRIPTION='SMA_MARKING'
END

IF (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='SMA_MARKING')='N'    
BEGIN
   RETURN;
END
ELSE
  BEGIn
  --------------Added for DashBoard 04-03-2021
	Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='ASSET CLASSIFICATION'
	
END
/*------------------MARKING Marking_FlgPNPA------------------*/

IF (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='SMA_MARKING')='Y'
AND (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='Marking_FlgPNPA')='N'    
BEGIN
Print 12
INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'Marking_FlgPNPA','RUNNING',GETDATE(),NULL,@TIMEKEY,@SetID

EXEC PRO.Marking_FlgPNPA @TIMEKEY=@TIMEKEY

UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE IdentityKey = (SELECT IDENT_CURRENT('PRO.PROCESSMONITOR')) AND  TIMEKEY=@TIMEKEY AND DESCRIPTION='Marking_FlgPNPA'
END

IF (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='Marking_FlgPNPA')='N' 
BEGIN
  RETURN;
END
ELSE
  BEGIn
  --------------Added for DashBoard 04-03-2021
	Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='ASSET CLASSIFICATION'
	
END


/*------------------Marking_NPA_Reason_NPAAccount------------------*/
Print 13
IF (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='Marking_FlgPNPA')='Y'
AND (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='Marking_NPA_Reason_NPAAccount')='N'    
BEGIN

INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'Marking_NPA_Reason_NPAAccount','RUNNING',GETDATE(),NULL,@TIMEKEY,@SetID

EXEC [PRO].[Marking_NPA_Reason_NPAAccount] @TIMEKEY=@TIMEKEY

UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE IdentityKey = (SELECT IDENT_CURRENT('PRO.PROCESSMONITOR')) AND  TIMEKEY=@TIMEKEY AND DESCRIPTION='Marking_NPA_Reason_NPAAccount'
END

IF (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='Marking_NPA_Reason_NPAAccount')='N' 
BEGIN
  RETURN;
END
ELSE
  BEGIn
  --------------Added for DashBoard 04-03-2021
	Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='ASSET CLASSIFICATION'
	
END



/*------------------Update ProvisionKey AccountLevel------------------*/
Print 14
IF (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='Marking_NPA_Reason_NPAAccount')='Y'
AND (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='UpdateProvisionKey_AccountWise')='N'    
BEGIN

INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'UpdateProvisionKey_AccountWise','RUNNING',GETDATE(),NULL,@TIMEKEY,@SetID

EXEC [PRO].[UPDATE_NPA_TYPE] @TIMEKEY=@TIMEKEY

EXEC PRO.UpdateProvisionKey_AccountWise @TIMEKEY=@TIMEKEY

UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE IdentityKey = (SELECT IDENT_CURRENT('PRO.PROCESSMONITOR')) AND  TIMEKEY=@TIMEKEY AND DESCRIPTION='UpdateProvisionKey_AccountWise'
END
IF (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='UpdateProvisionKey_AccountWise')='N'    
BEGIN
   RETURN;
END
ELSE
  BEGIn
  --------------Added for DashBoard 04-03-2021
	Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='ASSET CLASSIFICATION'
	
END

/*------------------UPDATE NET BALANCE AT ACCOUNT LEVEL------------------*/
Print 15
IF (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='UpdateProvisionKey_AccountWise')='Y'
AND (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='UpdateNetBalance_AccountWise')='N'    
BEGIN
INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'UpdateNetBalance_AccountWise','RUNNING',GETDATE(),NULL,@TIMEKEY,@SetID

EXEC  PRO.UpdateNetBalance_AccountWise @TIMEKEY=@TIMEKEY

UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE IdentityKey = (SELECT IDENT_CURRENT('PRO.PROCESSMONITOR')) AND  TIMEKEY=@TIMEKEY AND DESCRIPTION='UpdateNetBalance_AccountWise'
END

IF (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='UpdateNetBalance_AccountWise')='N'    
BEGIN
   RETURN
END 
ELSE
  BEGIn
  --------------Added for DashBoard 04-03-2021
	Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='ASSET CLASSIFICATION'
	
END

/*------------------UPDATE Govt Guar Appropriation AT ACCOUNT LEVEL------------------*/
Print 16
IF (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='UpdateNetBalance_AccountWise')='Y'
AND (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='GovtGuarAppropriation')='N'    
BEGIN

INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'GovtGuarAppropriation','RUNNING',GETDATE(),NULL,@TIMEKEY,@SetID

EXEC  PRO.[GovtGuarAppropriation] @TIMEKEY=@TIMEKEY

UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE IdentityKey = (SELECT IDENT_CURRENT('PRO.PROCESSMONITOR')) AND  TIMEKEY=@TIMEKEY AND DESCRIPTION='GovtGuarAppropriation'

END
IF (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='GovtGuarAppropriation')='N'    
BEGIN
   RETURN;
END 
ELSE
  BEGIn
  --------------Added for DashBoard 04-03-2021
	Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='ASSET CLASSIFICATION'
	
END

/*------------------UPDATE SecuritY AT ACCOUNT LEVEL------------------*/
Print 17
IF (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='GovtGuarAppropriation')='Y'
AND (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='SecurityAppropriation')='N'    
BEGIN
INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'SecurityAppropriation','RUNNING',GETDATE(),NULL,@TIMEKEY,@SetID

EXEC  [PRO].[SecurityAppropriation_IBL] @TIMEKEY=@TIMEKEY

UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE IdentityKey = (SELECT IDENT_CURRENT('PRO.PROCESSMONITOR')) AND  TIMEKEY=@TIMEKEY AND DESCRIPTION='SecurityAppropriation'
END
IF (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='SecurityAppropriation')='N'    
BEGIN
    RETURN;
END
ELSE
  BEGIn
  --------------Added for DashBoard 04-03-2021
	Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='ASSET CLASSIFICATION'
	
END
/*------------------UPDATE USED RV  AT ACCOUNT LEVEL------------------*/
Print 18
IF (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='SecurityAppropriation')='Y'
AND (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='UpdateUsedRV')='N'    
BEGIN
INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'UpdateUsedRV','RUNNING',GETDATE(),NULL,@TIMEKEY,@SetID

EXEC  PRO.[UpdateUsedRV] @TIMEKEY=@TIMEKEY

UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE IdentityKey = (SELECT IDENT_CURRENT('PRO.PROCESSMONITOR')) AND  TIMEKEY=@TIMEKEY AND DESCRIPTION='UpdateUsedRV'
END

IF (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='UpdateUsedRV')='N' 
BEGIN
   RETURN
END
ELSE
  BEGIn
  --------------Added for DashBoard 04-03-2021
	Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='ASSET CLASSIFICATION'
	
END

/*------------------UPDATE Provision Computation Secured AT ACCOUNT LEVEL------------------*/
Print 19
IF (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='UpdateUsedRV')='Y'
AND (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='ProvisionComputationSecured')='N'    
BEGIN
INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'ProvisionComputationSecured','RUNNING',GETDATE(),NULL,@TIMEKEY,@SetID

EXEC  PRO.[ProvisionComputationSecured] @TIMEKEY=@TIMEKEY

UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE IdentityKey = (SELECT IDENT_CURRENT('PRO.PROCESSMONITOR')) AND  TIMEKEY=@TIMEKEY AND DESCRIPTION='ProvisionComputationSecured'
END
IF (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='ProvisionComputationSecured')='N'
BEGIN
   RETURN
END 
ELSE
  BEGIn
  --------------Added for DashBoard 04-03-2021
	Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='ASSET CLASSIFICATION'
	
END
/*------------------UPDATE GovtGurCoverAmount AT ACCOUNT LEVEL------------------*/
Print 20
IF (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='ProvisionComputationSecured')='Y'
AND (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='GovtGurCoverAmount')='N'    
BEGIN

INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'GovtGurCoverAmount','RUNNING',GETDATE(),NULL,@TIMEKEY,@SetID

EXEC  PRO.GovtGurCoverAmount @TIMEKEY=@TIMEKEY

UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE IdentityKey = (SELECT IDENT_CURRENT('PRO.PROCESSMONITOR')) AND  TIMEKEY=@TIMEKEY AND DESCRIPTION='GovtGurCoverAmount'
END
IF  (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='GovtGurCoverAmount')='N' 
BEGIN
   RETURN
END 
ELSE
  BEGIn
  --------------Added for DashBoard 04-03-2021
	Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='ASSET CLASSIFICATION'
	
END

/*------------------UPDATE UpdationProvisionComputationUnSecured AT ACCOUNT LEVEL------------------*/
Print 21
IF (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='GovtGurCoverAmount')='Y'
AND (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='UpdationProvisionComputationUnSecured')='N'    
BEGIN

INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'UpdationProvisionComputationUnSecured','RUNNING',GETDATE(),NULL,@TIMEKEY,@SetID

EXEC  PRO.UpdationProvisionComputationUnSecured @TIMEKEY=@TIMEKEY

UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE IdentityKey = (SELECT IDENT_CURRENT('PRO.PROCESSMONITOR')) AND  TIMEKEY=@TIMEKEY AND DESCRIPTION='UpdationProvisionComputationUnSecured'
END
IF (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='UpdationProvisionComputationUnSecured')='N'    
BEGIN
   RETURN
END
ELSE
  BEGIn
  --------------Added for DashBoard 04-03-2021
	Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='ASSET CLASSIFICATION'
	
END

/*------------------UPDATE UpdationProvisionComputationUnSecured AT ACCOUNT LEVEL------------------*/
Print 22
IF (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='UpdationProvisionComputationUnSecured')='Y'
AND (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='UpdationTotalProvision')='N'    
BEGIN

INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'UpdationTotalProvision','RUNNING',GETDATE(),NULL,@TIMEKEY,@SetID

EXEC PRO.UpdationTotalProvision  @TIMEKEY=@TIMEKEY

UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE IdentityKey = (SELECT IDENT_CURRENT('PRO.PROCESSMONITOR')) AND  TIMEKEY=@TIMEKEY AND DESCRIPTION='UpdationTotalProvision'
END
IF (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='UpdationTotalProvision')='N'    
BEGIN
   RETURN 
END
ELSE
  BEGIn
  --------------Added for DashBoard 04-03-2021
	Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='ASSET CLASSIFICATION'
	
END

/*------------------INSERT DATA INTO HISTORY DATA------------------*/
Print 23
  IF (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='UpdationTotalProvision')='Y'
AND (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='InsertDataIntoHistTable')='N'    
BEGIN

INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'InsertDataIntoHistTable','RUNNING',GETDATE(),NULL,@TIMEKEY,@SetID

IF (@PROCESSMONTH = EOMONTH(@PROCESSMONTH))
BEGIN
EXEC PRO.InsertDataINTOHIST_TABLE_OPT  @TIMEKEY=@TIMEKEY
END


UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE IdentityKey = (SELECT IDENT_CURRENT('PRO.PROCESSMONITOR')) AND  TIMEKEY=@TIMEKEY AND DESCRIPTION='InsertDataIntoHistTable'
END
IF (SELECT Completed FROM PRO.AclRunningProcessStatus WHERE RunningProcessName='InsertDataIntoHistTable')='N'    
BEGIN
   RETURN 
END
ELSE
  BEGIn
  --------------Added for DashBoard 04-03-2021
	Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='ASSET CLASSIFICATION'
	
END


     SET NOCOUNT OFF;
	
END



GO