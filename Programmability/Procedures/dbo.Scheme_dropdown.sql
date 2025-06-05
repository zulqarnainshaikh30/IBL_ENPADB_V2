SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


create Proc [dbo].[Scheme_dropdown]
@Timekey int 
,@SchemeName Varchar(200)
as

--declare @Timekey int, @SchemeName varchar(200)='IRDP(MI)'
set @Timekey =(Select Timekey from sysdatamatrix where CurrentStatus='C')

select 
SchemeAlt_Key	 as code,
SchemeName  as SchemeDesc

from DimScheme
where SchemeName=@SchemeName
and EffectiveFromTimeKey<=@Timekey and EffectiveToTimeKey>=@Timekey

GO