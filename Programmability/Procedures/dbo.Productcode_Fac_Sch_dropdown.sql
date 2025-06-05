SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE Proc [dbo].[Productcode_Fac_Sch_dropdown]
AS

Declare @TimeKey INT =(Select TimeKey from SYSDATAMATRIX where CurrentStatus='C' )

Select ParameterAlt_Key,ParameterName ,'DimProductFacility' as TableName from 
		DimParameter  
		Where  DimParameterName='DimProductFacility'
		and ParameterAlt_Key in (1,2,3)
		and EffectiveFromTimeKey<@TimeKey and EffectiveToTimeKey>=@TimeKey

Select ParameterAlt_Key,ParameterName ,'DimSchemeType' as TableName,*
 from DimParameter  
		Where  DimParameterName='DimSchemeType' and ParameterAlt_Key in (1,2,3,4)
		and EffectiveFromTimeKey<@TimeKey and EffectiveToTimeKey>=@TimeKey
GO