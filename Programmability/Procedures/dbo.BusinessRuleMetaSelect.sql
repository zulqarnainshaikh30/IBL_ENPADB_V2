SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author Triloki Kumar>
-- Create date: <Create Date 09/03/2020>
-- Description:	<Description Business Rule master select>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessRuleMetaSelect]
	
AS
BEGIN
	
	SET NOCOUNT ON;


		SELECT 
			BusinessRuleColAlt_Key
			,BusinessRuleColDesc
			,'BusinessRuleSelect' TableName
		 FROM DimBusinessRuleCol



		 --select 
			--GLProductAlt_Key as Code
			--,ProductName+' ('+CONVERT(varchar(20),ProductCode)+'/ '+CONVERT(varchar(20),GLProductAlt_Key)+')' as [Description]
			--,'GL_Select' TableName
		 -- from DimGLProduct

		 select 
			GLProductAlt_Key as Code
			,ProductName as [Description]
			,'GL_Select' TableName
		  from DimGLProduct_AU

		  --select * from DimParameter where DimParameterName='DimScopeType' and ParameterAlt_Key not in (8,3,4) 

		  select ParameterAlt_Key AS Code,ParameterName AS Description, 'DimSelectScope' as TableName from DimParameter
		  where DimParameterName='DimScopeType' and ParameterAlt_Key not in (8,3,4) 

		   select ParameterAlt_Key AS Code,ParameterName AS Description,'Product_AdvCode' TableName from DimParameter
		  where DimParameterName='DimScopeType' and ParameterAlt_Key in (6,7) 

		--Select
		--	TerritoryAlt_Key as Code
		--	,TerritoryName as [Description]
		--	,'DimTerritory' as TableName
		--	from DimTerritory
		--	where (EffectiveFromTimeKey<=49999 AND EffectiveToTimeKey>=49999)

		Select
			ParameterShortName as Code
			,ParameterName as [Description]
			,'DimIdentificationRule' as TableName
			from DimParameter
			where (EffectiveFromTimeKey<=49999 AND EffectiveToTimeKey>=49999)
			AND DimParameterName='DimIdentificationRule' 

END


GO