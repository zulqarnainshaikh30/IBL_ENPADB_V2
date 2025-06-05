SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

create Proc [dbo].[InstrumentType_dropdown]
@Timekey int 
,@InstrumentTypeName Varchar(200)
as

--declare @Timekey int, @InstrumentTypeName varchar(200)='IRDP(MI)'
set @Timekey =(Select Timekey from sysdatamatrix where CurrentStatus='C')

select 
InstrumentTypeAlt_Key	 as code,
InstrumentTypeName  as InstrumentTypeDesc

from DimInstrumentType
where InstrumentTypeName=@InstrumentTypeName
and EffectiveFromTimeKey<=@Timekey and EffectiveToTimeKey>=@Timekey


GO