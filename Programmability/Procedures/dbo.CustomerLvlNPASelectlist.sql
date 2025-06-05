SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO




--CustomerLvlNPASelectlist '68'
-- exec CustomerLvlNPASelectlist @CustomerID=N'65'
--go
CREATE PROC [dbo].[CustomerLvlNPASelectlist]
--declare
@CustomerID	varchar(20)		='9987888'

AS
     
	 BEGIN

SET NOCOUNT ON;
Declare @TimeKey as Int

 --SET @Timekey =(Select TimeKey from SysDataMatrix where CurrentStatus='C') 

 -- SET @Timekey =(Select LastMonthDateKey from SysDayMatrix where Timekey=@Timekey) 

  
 SET @Timekey =(Select Timekey from SysDataMatrix Where MOC_Initialised='Y' AND ISNULL(MOC_Frozen,'N')='N') 


SELECT  A.CustomerID ,A.CustomerName,B.AssetClassName as AssetClass , Convert(Varchar(10),A.NPADate ,103) as NPADate,
A.AdditionalProvision,A.SecurityValue,D.MOCTypeName as MOCSource,
C.ParameterName as MOCType,
A.MOCReason,Convert(Varchar(10),A.MOCDate ,103) as MOCDate,--A.MOCBy,
A.CreatedBy as MOCBy,
a.DateCreated,
A.ApprovedByFirstLevel as [Level1ApprovedBy]
,a.DateApprovedFirstLevel as [Level1ApprovedDate]
,A.ApprovedBy  as [Level2ApprovedBy]
,A.DateApproved AS [Level2ApprovedDate]
FROM CustomerLevelMOC_Mod A 
Left JOIN DimAssetClass B ON  A.AssetClassAlt_Key=B.AssetClassAlt_Key 
--AND  A.EffectiveFromTimeKey=@TimeKey and A.EffectiveToTimeKey=@TimeKey 
Left JOIN DimMOCType D ON  A.MOCSourceAltkey=D.MOCTypeAlt_Key

	LEFT Join (
				Select  EffectiveFromTimeKey,EffectiveToTimeKey,ParameterAlt_Key,ParameterName,'MOCType' as Tablename 
				from DimParameter where DimParameterName='MOCType'
				And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)C
ON C.ParameterName=A.MOCType
Where A.CUSTOMERID=@CustomerID and A.AuthorisationStatus in('A') And A.EffectiveFromTimeKey=@TimeKey

END


--Select MOCSourceAltKey,MOCTypeAlt_Key,* from CustomerLevelpreMOC  --where customerid='9987888'

--select MOCSourceAltKey,MOCTypeAlt_Key,* from CustomerLevelPostMOC where customerid='9987888'
--select * from ADVACBASICDETAIL
--select * from dimassetclass
--update CustomerLevelpreMOC set MOCSourceAltKey=1 where customerid='9987888'
--update ADVACBASICDETAIL
--set EffectiveToTimeKey=49999



























GO