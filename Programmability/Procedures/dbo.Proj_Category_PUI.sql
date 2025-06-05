SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE proc [dbo].[Proj_Category_PUI]
--@ProjectId INT
as

Declare @TimeKey as Int
SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')
--Declare @ProjectId int=1
select 
ProjectCategoryDescription
,ProjectCategoryAltKey
,'ProjectCategory'  TableName

 from ProjectCategory PC
 where PC.EffectiveFromTimeKey<=@Timekey And PC.EffectiveToTimeKey>=@Timekey
  --And ProjectCategoryAltKey=@ProjectId

--Project Authority Dropdown
  select ParameterAlt_Key	,ParameterName
,'ProjectAuthority' TableName
 from Dimparameter D
 where dimparametername='ProjectAuthority'
  and D.EffectiveFromTimeKey<=@Timekey And D.EffectiveToTimeKey>=@Timekey

  -- Project Ownership
  select ParameterAlt_Key	,ParameterName
,'ProjectOwnership' TableName
 from Dimparameter D
 where dimparametername='ProjectOwnership'
  and D.EffectiveFromTimeKey<=@Timekey And D.EffectiveToTimeKey>=@Timekey

  --Yes NO
  select ParameterAlt_Key,
  	ParameterName ,
	'ChangeinProjectScope' TableName
  
   from dimparameter
    where dimparametername = 'DIMYN'
	and EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey

	 select ParameterAlt_Key,
  	ParameterName ,
	'CourtCaseArbitration' TableName
  
   from dimparameter
    where dimparametername = 'DIMYN'
	and EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey

	 select ParameterAlt_Key,
  	ParameterName ,
	'CIO' TableName
  
   from dimparameter
    where dimparametername = 'DIMYN'
	and EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey

		 select ParameterAlt_Key,
  	ParameterName ,
	'CostOverrun' TableName
  
   from dimparameter
    where dimparametername = 'DIMYN'
	and EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey


	select ParameterAlt_Key,
  	ParameterName ,
	'TakeOutFinance' TableName
  
   from dimparameter
    where dimparametername = 'DIMYN'
	and EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey

	select ParameterAlt_Key,
  	ParameterName ,
	'Restructuring' TableName
  
   from dimparameter
    where dimparametername = 'DIMYN'
	and EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey

	select ParameterAlt_Key,
  	ParameterName ,
	'AssetclassinSellersbook' TableName
  
   from dimparameter
    where dimparametername like '%Assetclass%'
	and EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey

	select ParameterAlt_Key,
  	ParameterName ,
	'InitialExtenstion' TableName
  
   from dimparameter
    where dimparametername ='DimYN'
	and EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey

	select ParameterAlt_Key,
  	ParameterName ,
	'ExtnReason_BCP' TableName
  
   from dimparameter
    where dimparametername ='DimYN'
	and EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey

 select AssetClassAlt_Key,
  	AssetClassName ,
	'AssetClass' TableName
   from DimAssetClass
   where EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey
GO