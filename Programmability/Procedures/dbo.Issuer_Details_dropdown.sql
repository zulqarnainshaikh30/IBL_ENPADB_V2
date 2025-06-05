SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[Issuer_Details_dropdown]



as



Begin



Declare @TimeKey as int

set @TimeKey = (Select Timekey from sysdatamatrix where CurrentStatus='C')



select SourceAlt_key,Sourcename,'SourceSystemName' TableName from DIMSOURCEDB where effectivefromtimekey<=@TimeKey and effectivetotimekey>=@Timekey



select IssuerCategoryAlt_key,IssuerCategoryName,'IssuerCategoryCode' TableName from DIMISSUERCATEGORY where effectivefromtimekey<=@TimeKey and effectivetotimekey>=@Timekey



select ParameterShortNameEnum as ParameterAlt_Key,ParameterName,'GrpEntityOfBank' TableName from DimParameter where DimParameterName = 'DimYesNo' And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey



select InstrumentTypeAlt_Key,InstrumentTypeName,'InstrumentType' TableName from DimInstrumentType where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey



select CurrencyAlt_Key,CurrencyName,'Currency' TableName from dimcurrency where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey

select parameteralt_key,parametername,'investmentNature' TableName from dimparameter where dimParameterName='diminstrumentnature' And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey

select SubSectorAlt_Key,SubSectorName,'Sector' TableName from DimSubSector where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey

select IndustryAlt_Key,IndustryName,'Industry' TableName from dimindustry where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey

select ParameterAlt_Key,ParameterName,'ExposureType' TableName from dimparameter where dimparametername='dimexposuretype' and EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey

select ParameterAlt_Key,ParameterName,'HoldingNature' TableName from dimparameter where dimparametername ='dimportfoliotype' and EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey

select CurrencyAlt_Key,CurrencyName,'Currency' TableName from dimcurrency where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey

select CurrencyAlt_Key,CurrencyName,'CurrencyConvRate' TableName from DimCurCovRate where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey

select AssetClassAlt_Key,AssetClassName,'AssetClass' TableName from dimassetclass where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey

select parameteralt_key,parametername,'PartialRedumptionSettledY_N' TableName from dimparameter where DimParameterName='DIMYN' And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey

select BranchCode,BranchName

		,'DimBranch'  As TableName

		

		 from DimBranch

		 where EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey

select ParameterAlt_Key , ParameterName ,'BookType' TableName from DimParameter where DimParameterName='DimBookType' and effectivefromtimekey<=@Timekey and effectivetotimekey>=@Timekey

SELECT *, 'InvestmentIssuerDetail' AS TableName FROM MetaScreenFieldDetail WHERE ScreenName='InvestmentIssuerDetail'
and ctrlname!='PanNo'


SELECT *, 'InvestmentBasicDetail' AS TableName FROM MetaScreenFieldDetail WHERE ScreenName='InvestmentBasicDetail'



SELECT *, 'DerivativeDetail' AS TableName FROM MetaScreenFieldDetail WHERE ScreenName='DerivativeDetail'


SELECT *, 'InvestmentFinancialDetail' AS TableName FROM MetaScreenFieldDetail WHERE ScreenName='InvestmentFinancialDetail'

End

GO