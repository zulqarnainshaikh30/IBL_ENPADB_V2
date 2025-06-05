SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[UploadMetaData]

AS
BEGIN

	SELECT ParameterName as ColumnName from DimParameter where DimParameterName='DimMOCUploadTemp' order by ParameterAlt_Key

END
GO