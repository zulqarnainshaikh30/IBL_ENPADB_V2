SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE Proc [dbo].[Country_Dropdown]
@Timekey Int
AS

--declare @Timekey int=25658
select 
CountryAlt_Key	
,CountryName
,'CountryNameList' as TableName
from DimCountry
where EffectiveFromTimeKey<=@Timekey and 	EffectiveToTimeKey>=@Timekey
order by CountryName
GO