SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author Triloki Kumar>
-- Create date: <Create Date 09/03/2020>
-- Description:	<Description Business Rule master select>
-- =============================================
CREATE PROCEDURE [dbo].[GLMasterSelect]
	
AS
BEGIN
	
	SET NOCOUNT ON;
	

		 --select 
			--GLProductAlt_Key as GLProductAlt_Key
			--,ProductName+' ('+CONVERT(varchar(20),ProductCode)+'/ '+CONVERT(varchar(20),GLProductAlt_Key)+')' as [Description]
			--,ProductCode as ProductCode
			--,'GL_Select' TableName
		 -- from DimGLProduct

		 
		 select 
			GLProductAlt_Key as GLProductAlt_Key
			,ProductName as [Description]
			,ProductCode as ProductCode
			,'GL_Select' TableName
		  from DimGLProduct_AU
		  Where EffectiveFromTimeKey<=49999 and EffectiveToTimeKey>=49999
		  order by EntityKey desc

--GL_Key
-- DateCreated
--ModifiedBy
--DateModified
--EntityKey 

END
select top 5 * from DimGLProduct_AU
GO