SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Amar>
-- ALTER  date: <09/01/2012>
-- Description:	< selecting Master records for Parameterised_CommonMasterData>
-- =============================================


create PROCEDURE [dbo].[ParameterisedCommonMasterData] 
        @XMLMasterName AS VARCHAR(50)
AS

--DECLARE @XMLMasterName AS VARCHAR(50)='DimDepartment'
BEGIN
	PRINT 1
	PRINT @XMLMasterName

	DECLARE @Schema VARCHAR(10)

	
	 
	IF EXISTS(SELECT 1 FROM MetaParameterisedMasterTable WHERE XMLTableName=@XMLMasterName) 	
		BEGIN
			PRINT 2

			DECLARE @TableName VARCHAR(50)=''
					,@ColumnName VARCHAR(2000)=''
					,@InnerJoin VARCHAR(500)='' --- edited by shailesh on 20/07/2015 as inner join is used for metacerdescription is more than 200 char
					,@WhereCond VARCHAR(500)=''
					,@GroupBy VARCHAR(200)=''
					,@OrderBy VARCHAR(100)=''
					,@StrSql AS VARCHAR(MAX)=''

			SELECT @TableName=TableName 
					,@ColumnName= ColumnSelect 
					,@InnerJoin= InnerJoin 
					,@WhereCond=ISNULL(WhereCondition,'') 
					,@GroupBy=ISNULL(GroupBy,'')
					,@OrderBy=OrderBy
				FROM MetaParameterisedMasterTable 
				WHERE XMLTableName=@XMLMasterName
			
		SELECT  @Schema=SCHEMA_NAME(SCHEMA_ID)+'.'  FROM SYS.OBJECTS WHERE name=@TableName---- AND SCHEMA_NAME(SCHEMA_ID) in('DBO')----by dipti

			PRINT '@Schema'
			PRINT @Schema
			if isnull(@Schema,'')='' set @Schema=''



			PRINT '@TableName '+@TableName
			print '@ColumnName'+@ColumnName
			print '@InnerJoin'+@InnerJoin
			print '@WhereCond'+@WhereCond
			print '@OrderBy'+@OrderBy

			PRINT 11
			SET @StrSql='SELECT distinct '''+@XMLMasterName+ '''TableName,' +@ColumnName + ' FROM ' +@Schema+ @TableName
			
				     +' '+ISNULL(@InnerJoin,'')     			
						+' '+ISNULL(@WhereCond,'') 
					----	+ ' '+ISNULL(@GroupBy,'')
						+' '+ISNULL(@OrderBy,'')
		PRINT 12
			PRINT @StrSql
			PRINT 13
			EXECUTE (@StrSql) 
		END
END





GO