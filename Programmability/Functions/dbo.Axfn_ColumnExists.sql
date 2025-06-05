SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[Axfn_ColumnExists] (
	@TableName VARCHAR(100)
	,@ColumnName VARCHAR(100)
	)
RETURNS VARCHAR(100)
AS
BEGIN
	DECLARE @Result VARCHAR(100);

	IF EXISTS (
			SELECT 1
			FROM INFORMATION_SCHEMA.Columns
			WHERE TABLE_NAME = @TableName
				AND COLUMN_NAME = @ColumnName
			)
	BEGIN
		SET @Result = 'Already Exsits'
	END
	ELSE
	BEGIN
		SET @Result = 'Not Available, You can create now!'
	END

	RETURN (@Result)  
END

GO