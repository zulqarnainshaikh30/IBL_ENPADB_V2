SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[Investment_Basic_Detail_Dropdown]


as

Begin
Declare @TimeKey as int
set @TimeKey = (Select Timekey from sysdatamatrix where CurrentStatus='C')


select InstrumentTypeAlt_Key,InstrumentTypeName,'InstrumentType' from DimInstrumentType where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey

select CurrencyAlt_Key,CurrencyName,'Currency' TableName from dimcurrency where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
select parameteralt_key,parametername,'investmentNature' TableName from dimparameter where dimParameterName='diminstrumentnature' And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
select SubSectorAlt_Key,SubSectorName,'Sector' TableName from DimSubSector where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
select IndustryAlt_Key,IndustryName,'Industry' TableName from dimindustry where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
select ParameterAlt_Key,ParameterName,'ExposureType' TableName from dimparameter where dimparametername='dimexposuretype' and EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey

End
GO