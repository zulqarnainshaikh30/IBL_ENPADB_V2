SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE Proc [dbo].[YN_DropDown_PUI]
  AS

  Declare @TimeKey as Int
SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')

  select ParameterAlt_Key,
  	ParameterName ,
	'ChangeinProjectScope' TableName
  
   from dimparameter
    where dimparametername like '%DIMYN%'
	and EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey

	 select ParameterAlt_Key,
  	ParameterName ,
	'CourtCaseArbitration' TableName
  
   from dimparameter
    where dimparametername like '%DIMYN%'
	and EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey

	 select ParameterAlt_Key,
  	ParameterName ,
	'CIO' TableName
  
   from dimparameter
    where dimparametername like '%DIMYN%'
	and EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey

		 select ParameterAlt_Key,
  	ParameterName ,
	'CostOverrun' TableName
  
   from dimparameter
    where dimparametername like '%DIMYN%'
	and EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey


	select ParameterAlt_Key,
  	ParameterName ,
	'TakeOutFinance' TableName
  
   from dimparameter
    where dimparametername like '%DIMYN%'
	and EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey

	select ParameterAlt_Key,
  	ParameterName ,
	'Restructuring' TableName
  
   from dimparameter
    where dimparametername like '%DIMYN%'
	and EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey

	select ParameterAlt_Key,
  	ParameterName ,
	'AssetclassinSellersbook' TableName
  
   from dimparameter
    where dimparametername like '%Assetclass%'
	and EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey
GO