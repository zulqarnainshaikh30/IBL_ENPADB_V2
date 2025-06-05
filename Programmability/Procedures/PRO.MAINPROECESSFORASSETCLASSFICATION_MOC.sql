SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


--select * from MOC_ChangeDetails 

---EXEC  [PRO].[MAINPROECESSFORASSETCLASSFICATION_MOC] 26933, 'Y'

CREATE PROCEDURE [PRO].[MAINPROECESSFORASSETCLASSFICATION_MOC]
@TIMEKEY INT=26629--moc time key
,@Result INT=0 OUTPUT
AS
BEGIN


DECLARE @ISMoc CHAR(1)= 'Y'
DECLARE @SetID INT=1
IF EXISTS( SELECT 1 FROM SysDataMatrix  where ISNULL(MOC_Initialised,'N')='Y' AND ISNULL(MOC_Frozen,'N')='N')
BEGIN 
SELECT @TIMEKEY=TimeKey FROM SysDataMatrix  where  ISNULL(MOC_Initialised,'N')='Y' AND ISNULL(MOC_Frozen,'N')='N'
END
ELSE
BEGIN
SELECT 'There is no MOC Initialised Date available for MOC Process'
RETURN -1
END
BEGIN TRY

/*------------------InsertDataforAssetClassficationENBD_MOC------------------*/
INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'InsertDataforAssetClassficationENBD_MOC','RUNNING',GETDATE(),NULL,@TIMEKEY,@SetID

INSERT INTO dbo.MOCMonitorStatus(UserID,MocMainSP,MocStatus,MocSubSP,MocStatusSub,TimeKey)
SELECT ORIGINAL_LOGIN(),'MAINPROECESSFORASSETCLASSFICATION_MOC','InProgress','InsertDataforAssetClassficationENBD_MOC','InProgress',@TIMEKEY

EXEC [PRO].[InsertDataforAssetClassficationENBD_MOC] @TIMEKEY

UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE TIMEKEY=@TIMEKEY AND DESCRIPTION='InsertDataforAssetClassficationENBD_MOC'

UPDATE dbo.MOCMonitorStatus SET MocStatusSub='Completed' WHERE TIMEKEY=@TIMEKEY AND MocSubSP='InsertDataforAssetClassficationENBD_MOC'

/*------------------DPD Calculation------------------*/

INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'DPD_Calculation_MOC','RUNNING',GETDATE(),NULL,@TIMEKEY,@SetID

UPDATE dbo.MOCMonitorStatus SET MocStatusSub='InProgress',MocSubSP='DPD_Calculation_MOC' WHERE TIMEKEY=@TIMEKEY 

EXEC PRO.DPD_Calculation @TIMEKEY=@TIMEKEY

UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE IdentityKey = (SELECT IDENT_CURRENT('PRO.PROCESSMONITOR')) AND  TIMEKEY=@TIMEKEY AND DESCRIPTION='DPD_Calculation_MOC'

UPDATE dbo.MOCMonitorStatus SET MocStatusSub='Completed',MocSubSP='DPD_Calculation_MOC' WHERE TIMEKEY=@TIMEKEY 

/*------------------MaxDPD REGARDING  ReferencePeriod Calculation------------------*/

INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'MaxDPD_ReferencePeriod_Calculation_MOC','RUNNING',GETDATE(),NULL,@TIMEKEY,@SetID

UPDATE dbo.MOCMonitorStatus SET MocStatusSub='InProgress',MocSubSP='MaxDPD_ReferencePeriod_Calculation_MOC' 
WHERE TIMEKEY=@TIMEKEY 


EXEC PRO.MaxDPD_ReferencePeriod_Calculation @TIMEKEY=@TIMEKEY

UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE IdentityKey = (SELECT IDENT_CURRENT('PRO.PROCESSMONITOR')) AND  TIMEKEY=@TIMEKEY AND DESCRIPTION='MaxDPD_ReferencePeriod_Calculation_MOC'



UPDATE dbo.MOCMonitorStatus SET MocStatusSub='Completed',MocSubSP='MaxDPD_ReferencePeriod_Calculation_MOC' 
WHERE TIMEKEY=@TIMEKEY 


INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'SMA_MARKING_MOC','RUNNING',GETDATE(),NULL,@TIMEKEY,@SetID

UPDATE dbo.MOCMonitorStatus SET MocStatusSub='InProgress',MocSubSP='SMA_MARKING_MOC' 
WHERE TIMEKEY=@TIMEKEY 

EXEC [PRO].SMA_MARKING @TIMEKEY

UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE TIMEKEY=@TIMEKEY AND DESCRIPTION='SMA_MARKING_MOC'


UPDATE dbo.MOCMonitorStatus SET MocStatusSub='Completed',MocSubSP='SMA_MARKING_MOC' 
WHERE TIMEKEY=@TIMEKEY 

INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'UpdateProvisionKey_AccountWise_MOC','RUNNING',GETDATE(),NULL,@TIMEKEY,@SetID

UPDATE dbo.MOCMonitorStatus SET MocStatusSub='InProgress',MocSubSP='UpdateProvisionKey_AccountWise_MOC' 
WHERE TIMEKEY=@TIMEKEY 


EXEC PRO.UpdateProvisionKey_AccountWise @TIMEKEY=@TIMEKEY

UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE TIMEKEY=@TIMEKEY AND DESCRIPTION='UpdateProvisionKey_AccountWise_MOC'

UPDATE dbo.MOCMonitorStatus SET MocStatusSub='Completed',MocSubSP='UpdateProvisionKey_AccountWise_MOC' 
WHERE TIMEKEY=@TIMEKEY 


/*------------------UpdateNetBalance_AccountWise------------------*/
INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'UpdateNetBalance_AccountWise_MOC','RUNNING',GETDATE(),NULL,@TIMEKEY,@SetID


UPDATE dbo.MOCMonitorStatus SET MocStatusSub='InProgress',MocSubSP='UpdateNetBalance_AccountWise_MOC' 
WHERE TIMEKEY=@TIMEKEY 




EXEC  PRO.UpdateNetBalance_AccountWise @TIMEKEY=@TIMEKEY

UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE TIMEKEY=@TIMEKEY AND DESCRIPTION='UpdateNetBalance_AccountWise_MOC'


UPDATE dbo.MOCMonitorStatus SET MocStatusSub='Completed',MocSubSP='UpdateNetBalance_AccountWise_MOC' 
WHERE TIMEKEY=@TIMEKEY 


/*------------------GovtGuarAppropriation------------------*/
INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'GovtGuarAppropriation_MOC','RUNNING',GETDATE(),NULL,@TIMEKEY,@SetID

UPDATE dbo.MOCMonitorStatus SET MocStatusSub='InProgress',MocSubSP='GovtGuarAppropriation_MOC' 
WHERE TIMEKEY=@TIMEKEY 



EXEC  PRO.[GovtGuarAppropriation] @TIMEKEY=@TIMEKEY

UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE TIMEKEY=@TIMEKEY AND DESCRIPTION='GovtGuarAppropriation_MOC'

UPDATE dbo.MOCMonitorStatus SET MocStatusSub='Completed',MocSubSP='GovtGuarAppropriation_MOC' 
WHERE TIMEKEY=@TIMEKEY 


/*------------------SecurityAppropriation------------------*/
INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'SecurityAppropriation_MOC','RUNNING',GETDATE(),NULL,@TIMEKEY,@SetID

UPDATE dbo.MOCMonitorStatus SET MocStatusSub='InProgress',MocSubSP='SecurityAppropriation_MOC' 
WHERE TIMEKEY=@TIMEKEY 


EXEC  PRO.[SecurityAppropriation] @TIMEKEY=@TIMEKEY

UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE TIMEKEY=@TIMEKEY AND DESCRIPTION='SecurityAppropriation_MOC'

UPDATE dbo.MOCMonitorStatus SET MocStatusSub='Completed',MocSubSP='SecurityAppropriation_MOC' 
WHERE TIMEKEY=@TIMEKEY 


/*------------------UpdateUsedRV_MOC------------------*/
INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'UpdateUsedRV_MOC','RUNNING',GETDATE(),NULL,@TIMEKEY,@SetID

UPDATE dbo.MOCMonitorStatus SET MocStatusSub='InProgress',MocSubSP='UpdateUsedRV_MOC' 
WHERE TIMEKEY=@TIMEKEY 



EXEC  PRO.[UpdateUsedRV] @TIMEKEY=@TIMEKEY

UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE TIMEKEY=@TIMEKEY AND DESCRIPTION='UpdateUsedRV_MOC'

UPDATE dbo.MOCMonitorStatus SET MocStatusSub='Completed',MocSubSP='UpdateUsedRV_MOC' 
WHERE TIMEKEY=@TIMEKEY 


/*------------------ProvisionComputationSecured------------------*/
INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'ProvisionComputationSecured_MOC','RUNNING',GETDATE(),NULL,@TIMEKEY,@SetID


UPDATE dbo.MOCMonitorStatus SET MocStatusSub='InProgress',MocSubSP='ProvisionComputationSecured_MOC' 
WHERE TIMEKEY=@TIMEKEY 


EXEC  PRO.[ProvisionComputationSecured] @TIMEKEY=@TIMEKEY

UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE TIMEKEY=@TIMEKEY AND DESCRIPTION='ProvisionComputationSecured_MOC'

UPDATE dbo.MOCMonitorStatus SET MocStatusSub='Completed',MocSubSP='ProvisionComputationSecured_MOC' 
WHERE TIMEKEY=@TIMEKEY 


/*------------------GovtGurCoverAmount------------------*/
INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'GovtGurCoverAmount_MOC','RUNNING',GETDATE(),NULL,@TIMEKEY,@SetID

UPDATE dbo.MOCMonitorStatus SET MocStatusSub='InProgress',MocSubSP='GovtGurCoverAmount_MOC' 
WHERE TIMEKEY=@TIMEKEY 




EXEC  PRO.GovtGurCoverAmount @TIMEKEY=@TIMEKEY

UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE TIMEKEY=@TIMEKEY AND DESCRIPTION='GovtGurCoverAmount_MOC'

UPDATE dbo.MOCMonitorStatus SET MocStatusSub='Completed',MocSubSP='GovtGurCoverAmount_MOC' 
WHERE TIMEKEY=@TIMEKEY 


/*------------------UpdationProvisionComputationUnSecured------------------*/
INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'UpdationProvisionComputationUnSecured_MOC','RUNNING',GETDATE(),NULL,@TIMEKEY,@SetID

UPDATE dbo.MOCMonitorStatus SET MocStatusSub='InProgress',MocSubSP='UpdationProvisionComputationUnSecured_MOC' 
WHERE TIMEKEY=@TIMEKEY 


EXEC  PRO.UpdationProvisionComputationUnSecured @TIMEKEY=@TIMEKEY

UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE TIMEKEY=@TIMEKEY AND DESCRIPTION='UpdationProvisionComputationUnSecured_MOC'

UPDATE dbo.MOCMonitorStatus SET MocStatusSub='Completed',MocSubSP='UpdationProvisionComputationUnSecured_MOC' 
WHERE TIMEKEY=@TIMEKEY 


/*------------------UpdationTotalProvision------------------*/
INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'UpdationTotalProvision_MOC','RUNNING',GETDATE(),NULL,@TIMEKEY,@SetID

UPDATE dbo.MOCMonitorStatus SET MocStatusSub='InProgress',MocSubSP='UpdationTotalProvision_MOC' 
WHERE TIMEKEY=@TIMEKEY 



EXEC PRO.UpdationTotalProvision  @TIMEKEY=@TIMEKEY

UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE TIMEKEY=@TIMEKEY AND DESCRIPTION='UpdationTotalProvision_MOC'


UPDATE dbo.MOCMonitorStatus SET MocStatusSub='Completed',MocSubSP='UpdationTotalProvision_MOC' 
WHERE TIMEKEY=@TIMEKEY 


/*------------------DataShiftingintoArchiveandPremocTable_MOC------------------*/
INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'DataShiftingintoArchiveandPremocTable_MOC','RUNNING',GETDATE(),NULL,@TIMEKEY,@SetID

UPDATE dbo.MOCMonitorStatus SET MocStatusSub='InProgress',MocSubSP='DataShiftingintoArchiveandPremocTable_MOC' 
WHERE TIMEKEY=@TIMEKEY



EXEC [Pro].[DataShiftingintoArchiveandPremocTable] @TIMEKEY

UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE TIMEKEY=@TIMEKEY AND DESCRIPTION='DataShiftingintoArchiveandPremocTable_MOC'

UPDATE dbo.MOCMonitorStatus SET MocStatusSub='Completed',MocSubSP='DataShiftingintoArchiveandPremocTable_MOC' 
WHERE TIMEKEY=@TIMEKEY


/*------------------PRO.UpdateDataInHistTable------------------*/
INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
SELECT ORIGINAL_LOGIN(),'UpdateDataInHistTable','RUNNING',GETDATE(),NULL,@TIMEKEY,@SetID

UPDATE dbo.MOCMonitorStatus SET MocStatusSub='InProgress',MocSubSP='UpdateDataInHistTable' 
WHERE TIMEKEY=@TIMEKEY 


EXEC PRO.UpdateDataInHistTable @TIMEKEY=@TIMEKEY

UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE TIMEKEY=@TIMEKEY AND DESCRIPTION='UpdateDataInHistTable'

UPDATE dbo.MOCMonitorStatus SET MocStatusSub='Completed',MocStatus='Completed' WHERE TIMEKEY=@TIMEKEY 


--/*------------------Cust_AccCal_Merge_Moc------------------*/
--INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
--SELECT ORIGINAL_LOGIN(),'Cust_AccCal_Merge_Moc','RUNNING',GETDATE(),NULL,@TIMEKEY,@SetID

--EXEC [PRO].[Cust_AccCal_Merge_Moc] @TIMEKEY=@TIMEKEY

--UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE TIMEKEY=@TIMEKEY AND DESCRIPTION='Cust_AccCal_Merge_Moc'

--/*------------------CustomerAccountMOC------------------*/
--INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
--SELECT ORIGINAL_LOGIN(),'CustomerAccountMOC','RUNNING',GETDATE(),NULL,@TIMEKEY,@SetID

----EXEC [dbo].[CustomerAccountMOC] @TIMEKEY=@TIMEKEY

--UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE TIMEKEY=@TIMEKEY AND DESCRIPTION='CustomerAccountMOC'
----SELECT 1/0
set @Result= 1
return
END TRY
BEGIN CATCH
set @Result= -1

select ERROR_MESSAGE(),ERROR_PROCEDURE()
return
END CATCH


END


GO