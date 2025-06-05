SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[GetIBPCPoolType]
	
AS
BEGIN
		SET NOCOUNT ON;

    Declare @Timekey int
 Select @Timekey=Max(Timekey) from dbo.SysDayMatrix  
  where  Date=cast(getdate() as Date)
    PRINT @Timekey  

	Select 'DimPoolType'as TableName, ParameterAlt_Key,ParameterName from DimParameter
	Where DimParameterName ='IBPCPoolSummary' and EffectiveToTimeKey>=@Timekey


END
GO