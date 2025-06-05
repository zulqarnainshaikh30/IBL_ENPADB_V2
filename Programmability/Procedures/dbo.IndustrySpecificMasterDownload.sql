SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
  
  
  
--CollateralMasterDownload  
CREATE PROC [dbo].[IndustrySpecificMasterDownload]  
As  
  
BEGIN  
  
Declare @TimeKey as Int  
 SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')  
  
 select SlNo,CIF,BSRActivityCode,ProvisionRate,'IndustrySpecificProvisionUpload' as TableName  
 from DimIndustrySpecific  
 where EffectiveFromTimeKey<=@TimeKey  
 AND EffectiveToTimeKey >=@TimeKey  
 order by Entity_Key  
  
 --select  ParameterAlt_Key  
 -- ,ParameterName  
 -- ,'SeniorityOfChargeMaster' as TableName   
 -- from DimParameter A where DimParameterName='DimSeniorityOfCharge'  
 -- AND A.EffectiveFromTimeKey<=@TimeKey  
 --AND A.EffectiveToTimeKey >=@TimeKey  
  
    
  
    
     
    
     
     
  
  
 END  
  
  
  
GO