SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE Proc [dbo].[InstrumentTypeName_dropdown]
--@Timekey int 
--,@InstrumentTypeName Varchar(200)
as

--declare @InstrumentTypeName varchar(200)='SOCIAL INFRA REAL ESTATE'
Declare @Timekey int=null
set @Timekey =(Select Timekey from sysdatamatrix where CurrentStatus='C')

select 
InstrumentTypeAlt_Key	 as Code
,InstrumentTypeName  as InstrumentDesc
,'CrisMacDesc' TableName
from DimInstrumentType
where EffectiveFromTimeKey<=@Timekey and EffectiveToTimeKey>=@Timekey



GO