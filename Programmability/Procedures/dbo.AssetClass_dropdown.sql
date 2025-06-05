SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

Create Proc [dbo].[AssetClass_dropdown]

AS

BEGIN

declare @Timekey int
--, @AssetClassName varchar(200)='STANDARD'
set @Timekey =(Select Timekey from sysdatamatrix where CurrentStatus='C')

select 
'AssetClassList' AS TableName,
AssetClassAlt_Key	 as code,
AssetClassName  as AssetClassDesc


from DimAssetClass
where 
--AssetClassName=@AssetClassName
 EffectiveFromTimeKey<=@Timekey and EffectiveToTimeKey>=@Timekey

END


GO