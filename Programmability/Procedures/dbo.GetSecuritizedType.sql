SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[GetSecuritizedType]
	
AS
BEGIN
		SET NOCOUNT ON;

    Declare @Timekey int
 Select @Timekey=Max(Timekey) from dbo.SysDayMatrix  
  where  Date=cast(getdate() as Date)
    PRINT @Timekey  

	Select 'SecuritizedType'as TableName, ParameterAlt_Key,ParameterName from DimParameter
	Where DimParameterName ='Securitized' and  EffectiveFromTimeKey <= @Timekey and EffectiveToTimeKey>=@Timekey


END


GO