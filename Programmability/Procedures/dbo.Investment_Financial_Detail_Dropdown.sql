SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[Investment_Financial_Detail_Dropdown]


as
 

 Begin
 Declare @TimeKey as int
 set @TimeKey = (Select Timekey from sysdatamatrix where CurrentStatus='C')
 select ParameterAlt_Key,ParameterName,'HoldingNature' from dimparameter where dimparametername ='dimportfoliotype' and EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
 select CurrencyAlt_Key,CurrencyName,'Currency' TableName from dimcurrency where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
 select CurrencyAlt_Key,CurrencyName,'CurrencyConvRate' TableName from DimCurCovRate where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
 select AssetClassAlt_Key,AssetClassName,'AssetClass' TableName from dimassetclass where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
 select parameteralt_key,parametername,'PartialRedumtionSettledY/N' TableName from dimparameter where DimParameterName='DIMYN' And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey

 End
GO