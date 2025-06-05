SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


create Proc [dbo].[SchemeName_dropdown]
--@Timekey int 
--,@SchemeName Varchar(200)
as

--declare @SchemeName varchar(200)='SOCIAL INFRA REAL ESTATE'
Declare @Timekey int=null
set @Timekey =(Select Timekey from sysdatamatrix where CurrentStatus='C')

select 
SchemeAlt_Key	 as Code
,SchemeName  as ActivityDesc
,'CrisMacDesc' TableName
from DimScheme
where EffectiveFromTimeKey<=@Timekey and EffectiveToTimeKey>=@Timekey


GO