SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE Proc [dbo].[IndustryName_dropdown]
--@Timekey int 
--,@IndustryName Varchar(200)
as

--declare @Timekey int,@IndustryName varchar(200)='COAL MINING'
Declare @Timekey as Int
set @Timekey =(Select Timekey from sysdatamatrix where CurrentStatus='C')

select 
IndustryAlt_Key	 as code
,IndustryName  as IndustryDesc
,'CrisMacDesc' TableName
from DimIndustry
where EffectiveFromTimeKey<=@Timekey and EffectiveToTimeKey>=@Timekey



GO