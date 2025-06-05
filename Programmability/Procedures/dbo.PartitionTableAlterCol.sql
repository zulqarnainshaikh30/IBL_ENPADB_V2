SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


/* This SP is usedfor in case column alter/add in a table that should be add/alter in all partition ab/tables*/

CREATE   PROC [dbo].[PartitionTableAlterCol]
	 @ObjectName varchar(256)='AdvAcBasicDetail'
	,@TSQLCommand varchar(max)='Alter Table Curdat.AdvAcBasicDetail ADD customeracid varchar(30)'
AS
			DECLARE @SQL varchar(max)=''
			,@SchemaName varchar(20)
		
	
	DECLARE @PartitionFreq  varchar(3)
			,@DB_Name VARCHAR(50)
			,@TableSuffix varchar(100)
			,@ViewSchema	  varchar (20)
			,@PartitionViewName varchar (50)
			,@StartYear int=0 /*---amar added for partition view prepare only after table added year */
		SET @DB_Name =(SELECT DB_NAME())

		SELECT @PartitionFreq=PartitionFreq,@SchemaName=PartitionTbaleSchema, @ViewSchema=ViewSchema,@PartitionViewName =PartitionViewName 
				,@StartYear=StartYear
		FROM DimPartitionTable WHERE PartitionTbaleName=@ObjectName
			IF ISNULL(@StartYear,0)=0 SET @StartYear=2020
		
		set @TSQLCommand=REPLACE(@TSQLCommand,'Alter Table','')
		set @TSQLCommand=REPLACE(@TSQLCommand,@SchemaName+'.'+@ObjectName,'')
	
		
				
		IF @PartitionFreq='MLY'		SET @TableSuffix='Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec'

		IF @PartitionFreq='QLY'		SET @TableSuffix='Q1,Q2,Q3,Q4'

				/*filtering list of database to use in view for the particular table*/				
				DROP TABLE IF EXISTS #DBNAME
				SELECT Name, 1 iD,RIGHT(NAME,4) YRS INTO #DBNAME FROM SYS.databases 
				WHERE NAME LIKE @DB_NAME+'%' AND LEN(NAME)=LEN(@DB_NAME)+5 AND NAME<>@DB_NAME

				DROP TABLE IF EXISTS #DB_LIST 
				CREATE TABLE #DB_LIST (DbName varchar(50), ID TinyInt)
				INSERT INTO #DB_LIST
				SELECT Name, 1 iD FROM #DBNAME WHERE YRS BETWEEN @StartYear AND 2099  /*1999 AND 2099 */ /*---amar added for partition view prepare only after table added year */
		
		SET @SQL= ' USE '+ @DB_Name+ CHAR(13)+' '
				
			
		SELECT @SQL=CHAR(13)+ STRING_AGG(QRY,'')
		FROM(
					--SELECT ' ALTER TABLE '+DbName+'.'+@SchemaName+'.'+@ObjectName+'_'+RIGHT(DbName,4)+'_'+VALUE +@TSQLCommand  QRY FROM #DB_LIST A
					SELECT ' ALTER TABLE '+DbName+'.DBO.'+@ObjectName+'_'+RIGHT(DbName,4)+'_'+VALUE +@TSQLCommand  QRY FROM #DB_LIST A
					INNER JOIN  
							(SELECT 1 ID, value FROM STRING_SPLIT(@TableSuffix,',')  
							)  B
					ON A.ID=B.ID
			) A
		--SELECT @SQL
		--print 2
		---print @SQL
		EXEC(@SQL)
		
		set @SQL='exec sp_refreshview '''+ @ViewSchema+'.'+@PartitionViewName+''''
		print @SQL
		exec (@SQL)




GO