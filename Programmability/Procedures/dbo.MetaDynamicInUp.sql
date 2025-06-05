﻿SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


-- ====================================================================================================================
-- Author:			<Amar>
-- Create Date:		<30-11-2014>
-- Loading Master Data for Common Master Screen>
-- ====================================================================================================================
CREATE PROCEDURE [dbo].[MetaDynamicInUp]
	@ColName VARCHAR(MAX) =''		
	,@DataVal  VARCHAR(MAX) =''	
	,@DataValAuth VARCHAR(MAX) =''
	,@ColName_DataVal VARCHAR(MAX)=''
	,@BaseColumnValue varchar(50)='0'
	,@ParentColumnValue varchar(50)='0'
	,@SourceTableName VARCHAR(59)
	,@EffectiveFromTimeKey INT=3500
	,@EffectiveToTimeKey INT=9999
	,@CreateModifyApprovedBy VARCHAR(20) ='D2KAMAR'
	,@OperationFlag INT=1
	,@TimeKey INT=9999
	,@AuthMode char(2)= 'Y'                                        
	,@MenuID INT=120
	,@TabID INT
	,@Remark VARCHAR(200)=NULL
	,@ChangeField VARCHAR(200)=NULL
	,@D2Ktimestamp INT =0 OUTPUT
	,@Result INT =1 OUTPUT

 AS 

 SET DATEFORMAT DMY
		
BEGIN
	DECLARE @AuthorisationStatus CHAR(2)=NULL			
			,@CreatedBy VARCHAR(20) =NULL
			,@DateCreated SMALLDATETIME=NULL
			,@Modifiedby VARCHAR(20) =NULL
			,@DateModified SMALLDATETIME=NULL
			,@ExEntityKey AS INT=0
			,@ErrorHandle int=0   
			,@TableWithSchema VARCHAR(50)
			,@TableWithSchema_Mod VARCHAR(50)

			,@SQL VARCHAR(MAX)=''		
			--,@SourceTableName VARCHAR(50)
			--,@BaseColumnValue VARCHAR(50)
			,@EntityKey  VARCHAR(50)
			,@ApprovedBy VARCHAR(20)
			,@TempSQL VARCHAR(MAX)=''	
			,@DateApproved SMALLDATETIME
			,@BaseColumn VARCHAR(50)
			,@ParentColumn VARCHAR(50)

			/* SET PARAMATER VALUE FOR USABLE*/
			--SET @DataVal=REPLACE(@DataVal,',',''',''')


		
			SET @DataVal=REPLACE(@DataVal,'''NULL''','NULL')
			--SET @DataVal=''''+@DataVal+''''
			SET @DataVal=REPLACE(@DataVal,'''''','NULL')
			SET @DataVal=REPLACE(@DataVal,'''null''','NULL')
			SET @DataVal=REPLACE(@DataVal,'''null','NULL')


			SET @ColName_DataVal=REPLACE(@ColName_DataVal,'''NULL''','NULL')
			--SET @DataVal=''''+@DataVal+''''
			SET @ColName_DataVal=REPLACE(@ColName_DataVal,'''''','NULL')
			SET @ColName_DataVal=REPLACE(@ColName_DataVal,'''null''','NULL')
			SET @ColName_DataVal=REPLACE(@ColName_DataVal,'''null','NULL')
		
			

			--SET @ColName_DataVal=@ColName_DataVal+''''
			--SET @ColName_DataVal=REPLACE(@ColName_DataVal,',',''',')

			--SET @ColName_DataVal=REPLACE(@ColName_DataVal,'=','=''')
			--SET @ColName_DataVal=REPLACE(@ColName_DataVal,'''NULL''','NULL')
			--SET @ColName_DataVal=REPLACE(@ColName_DataVal,'''''','NULL')
			--SET @ColName_DataVal=REPLACE(@ColName_DataVal,'''null''','NULL')
			--SET @ColName_DataVal=REPLACE(@ColName_DataVal,'''null','NULL')
			--SET @ColName_DataVal=REPLACE(@ColName_DataVal,'''NULL','NULL')



			SET @DataVal=REPLACE(@DataVal,'''y''','''Y''')	
			SET @DataVal=REPLACE(@DataVal,'''n''','''N''')	


			SET @DataVal=replace(@DataVal,'_AND_','&')
			print 'A1 '+@ColName_DataVal
			SET @ColName_DataVal=replace(@ColName_DataVal,'_AND_','&')
			print 'A2- '+@ColName_DataVal

		
		
		
			/* Generate Alt Key and Key Column Naame*/
			SELECT @EntityKey=NAME FROM SYS.columns WHERE OBJECT_NAME(OBJECT_ID)=@SourceTableName AND IS_identity=1

			/* FIND THE SCHEMA NAME FOR MASTER TABKE*/
			SELECT @TableWithSchema=SCHEMA_NAME(SCHEMA_ID)+'.'+@SourceTableName  FROM SYS.OBJECTS WHERE Name=@SourceTableName AND TYPE='U'
			SELECT @TableWithSchema_Mod =SCHEMA_NAME(SCHEMA_ID)+'.'+@SourceTableName+'_Mod'  FROM SYS.OBJECTS WHERE Name=@SourceTableName+'_Mod' AND TYPE='U'
			
	
				/* FIND THE TABLE NAME */
			SELECT  @BaseColumn= SourceColumn from MetaDynamicScreenField where MenuId=@MenuID 
				AND ISNULL(ParentcontrolID,0)= CASE WHEN @TabID > 0 THEN @TabID ELSE ISNULL(ParentcontrolID,0) END
				AND BaseColumnType='BASE' AND SourceTable=@SourceTableName AND ValidCode='Y'
			
			SELECT  @ParentColumn= SourceColumn from MetaDynamicScreenField where MenuId=@MenuID 
				AND ISNULL(ParentcontrolID,0)= CASE WHEN @TabID > 0 THEN @TabID ELSE ISNULL(ParentcontrolID,0) END
				AND BaseColumnType='PARENT' AND SourceTable=@SourceTableName AND ValidCode='Y'


			/* CREATE TEMP TABLE FOR INSERT DATA DYNAMICALLY */
			IF OBJECT_ID('Tempdb..#MasterInfo') IS NOT NULL
				DROP TABLE #MasterInfo
			CREATE TABLE #MasterInfo(CreatedBy VARCHAR(20), DateCreated DATETIME,ModifiedBy VARCHAR(20), DateModified DATETIME, 
									  DELSTATUS CHAR(2), EntityKey INT, AuthorisationStatus CHAR(2), EffectiveFromTimeKey INT)
		
			IF @ParentColumn IS NULL  SET @ParentColumn=''

		

	/* GENERATING BASE VALE IN ADD MODE FOR MAIN TABLE, FOR ASSOCIATE TABLES USE THAT BASE VALUE */
	IF @OperationFlag=1 AND @BaseColumnValue IN('0','') -- FOR FIND ALT_KEY DYNAMICALLY FROM TABLE 
		BEGIN
	
			TRUNCATE TABLE #MasterInfo

			/* FOR GENERATE CODE (ALT_KEY) */
			SELECT @SQL= ' SELECT MAX(CODE)+1 AS CODE FROM '
						+' (SELECT  MAX('+@BaseColumn+') AS CODE FROM '+@TableWithSchema 
						+' UNION SELECT  MAX('+@BaseColumn+') AS CODE FROM '+@TableWithSchema_Mod+') A'
		
			INSERT INTO #MasterInfo(EntityKey)
			EXEC (@SQL)
		
			SELECT @BaseColumnValue=EntityKey from #MasterInfo
			IF ISNULL(@BaseColumnValue,0)=0
				BEGIN
					SET @BaseColumnValue=1
				END
			--RETURN 1

			--select @BaseColumnValue as BaseColumnValue
		END



	/* <<<<<<<<<<< START OF TRANSACTIONS WITHIN ERROR HANDLING >>>>>>>>>>>	*/
	BEGIN TRY
	BEGIN TRANSACTION	


	
		-----
		/* OPERATTION MODE ADD AND MAKER CHECKER */
	IF @OperationFlag=1 AND @AuthMode ='Y'
		BEGIN
				SET @CreatedBy =@CreateModifyApprovedBy 

				SET @DateCreated = GETDATE()
				SET @AuthorisationStatus='NP'

				/* JUMP POINTER TO INSDERT DATA IN MOD TABLE*/
				GOTO CommonMaster_Insert
				CommonMaster_Insert_Add:
				
		END
	ELSE IF (@OperationFlag=2 OR @OperationFlag=3) AND @AuthMode ='Y'
		BEGIN
		
				
			SET @Modifiedby   = @CreateModifyApprovedBy 
			SET @DateModified = GETDATE() 
			
			IF @OperationFlag=2
				BEGIN
					SET @AuthorisationStatus='MP'
				END
			ELSE			
				BEGIN
					SET @AuthorisationStatus='DP'
				END

			/* FIND CREADED BY FROM MAIN TABLE	*/
			SET @SQL=''	
				
			SET @SQL='SELECT TOP(1) CreatedBy,DateCreated FROM '+@TableWithSchema + ' WHERE (EffectiveFromTimeKey<='+cast(@TimeKey AS VARCHAR(5)) +' AND EffectiveToTimeKey>=' +CAST(@TimeKey AS VARCHAR(5))+')'
			SET @SQL=@SQL+ CASE WHEN @ParentColumn<>'' THEN ' AND '+ @ParentColumn +'= ' +@ParentColumnValue ELSE '' END
			SET @SQL=@SQL+ ' AND ' + @BaseColumn+'='''+CAST(@BaseColumnValue AS VARCHAR(20))+''''	
			
			INSERT INTO #MasterInfo(CreatedBy,DateCreated)
			EXEC (@SQL)
			
			
			/* FIND CREADED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE	*/
			IF NOT EXISTS(SELECT 1 FROM #MasterInfo)
				BEGIN
					SET @SQL=REPLACE(@SQL,@TableWithSchema,@TableWithSchema_Mod)
					SET @SQL=@SQL + ' AND AuthorisationStatus in(''NP'',''MP'',''DP'')'
						
					TRUNCATE TABLE #MasterInfo
					INSERT INTO #MasterInfo(CreatedBy,DateCreated)
					
					EXEC (@SQL)
							
				END
				
			ELSE /*---IF DATA IS AVAILABLE IN MAIN TABLE		*/
				BEGIN
					/*--UPDATE FLAG IN MAIN TABLES AS MP	*/
					
					SET @SQL=''
					SET @SQL='UPDATE '+@TableWithSchema +' SET AuthorisationStatus='+''''+	@AuthorisationStatus +''''
					SET @SQL=@SQL+ ' WHERE (EffectiveFromTimeKey<='+cast(@TimeKey AS VARCHAR(5)) +' AND EffectiveToTimeKey>=' +CAST(@TimeKey AS VARCHAR(5))+')'
					SET @SQL=@SQL+ CASE WHEN @ParentColumn<>'' THEN ' AND '+ @ParentColumn +'= ' +@ParentColumnValue ELSE '' END
					SET @SQL=@SQL+ ' AND ' + @BaseColumn+'='''+CAST(@BaseColumnValue AS VARCHAR(20))+''''							
					
					EXEC (@SQL)
				END
			
			
			SELECT @CreatedBy=CreatedBy,@DateCreated=DateCreated FROM #MasterInfo
			
				
			/*UPDATE AUTHORISATIONSTATUS AS FM IN MOD TABLE IF RECORD IS ALREADY EXISTS*/
			IF @OperationFlag=2
				BEGIN	
					
					SET @SQL=''
					SET @SQL='UPDATE '+@TableWithSchema_Mod +' SET AuthorisationStatus=''FM'''
					SET @SQL=@SQL+ ', ModifiedBy='+''''+@Modifiedby+''''+ ', DateModified='+''''+cast(@DateModified as varchar(19))++''''
					SET @SQL=@SQL+ ' WHERE (EffectiveFromTimeKey<='+cast(@TimeKey AS VARCHAR(5)) +' AND EffectiveToTimeKey>=' +CAST(@TimeKey AS VARCHAR(5))+')'
					SET @SQL=@SQL+ CASE WHEN @ParentColumn<>'' THEN ' AND '+ @ParentColumn +'= ' +@ParentColumnValue ELSE '' END
					SET @SQL=@SQL+ ' AND ' + @BaseColumn+'='''+CAST(@BaseColumnValue AS VARCHAR(20))+''''							
					SET @SQL=@SQL +' AND AuthorisationStatus IN(''NP'',''MP'')'
					
					EXEC (@SQL)
				END

			/* JUMP POINTER TO INSDERT DATA IN MOD TABLE*/
			GOTO CommonMaster_Insert
			CommonMaster_Edit_Delete:

		END
			
	ELSE IF @OperationFlag =3 AND @AuthMode ='N'
		BEGIN

				/*-- DELETE RECORD IN CASE OF SCREEN IS RUNNING IN NON-MAKER CHECKER	*/
				SET @Modifiedby   = @CreateModifyApprovedBy 
				SET @DateModified = GETDATE() 

				SET @SQL=''
				SET @SQL='UPDATE '+@TableWithSchema + ' SET '
				SET @SQL=@SQL+ ' ModifiedBy='+''''+@Modifiedby+''''+ ', DateModified='+''''+cast(@DateModified as varchar(19))++''''
				SET @SQL=@SQL+ ' ,EffectiveToTimeKey='+CAST(@EffectiveFromTimeKey-1 AS VARCHAR(5))
				SET @SQL=@SQL+ ' WHERE (EffectiveFromTimeKey<='+cast(@TimeKey AS VARCHAR(5)) +' AND EffectiveToTimeKey>=' +CAST(@TimeKey AS VARCHAR(5))+')'
				SET @SQL=@SQL+ CASE WHEN @ParentColumn<>'' THEN ' AND '+ @ParentColumn +'= ' +@ParentColumnValue ELSE '' END
				SET @SQL=@SQL+ ' AND ' + @BaseColumn+'='''+CAST(@BaseColumnValue AS VARCHAR(20))+''''							
				EXEC (@SQL)

		END

	ELSE IF @OperationFlag=17 AND @AuthMode ='Y' 
		BEGIN
			/*  REJECT THE RECORD IN MAKER CHECKER */
				SET @ApprovedBy		= @CreateModifyApprovedBy 
				SET @DateApproved	= GETDATE()

				SET @SQL=''
				SET @SQL='UPDATE '+@TableWithSchema_Mod +' SET'
				SET @SQL=@SQL+ ' ApprovedBy='+''''+@ApprovedBy+''''+ ', DateApproved='+''''+cast(@DateApproved as varchar(19))+''''+', AuthorisationStatus=''R'''
				SET @SQL=@SQL+', EffectiveToTimeKey='+CAST(@EffectiveFromTimeKey-1 AS VARCHAR(5))
				SET @SQL=@SQL+'  WHERE (EffectiveFromTimeKey<='+cast(@TimeKey AS VARCHAR(5)) +' AND EffectiveToTimeKey>=' +CAST(@TimeKey AS VARCHAR(5))+')'
				SET @SQL=@SQL+ CASE WHEN @ParentColumn<>'' THEN ' AND '+ @ParentColumn +'= ' +@ParentColumnValue ELSE '' END
				SET @SQL=@SQL+ ' AND ' + @BaseColumn+'='''+CAST(@BaseColumnValue AS VARCHAR(20))+''''			
				SET @SQL=@SQL +' AND AuthorisationStatus in(''NP'',''MP'',''DP'')'				
				
				EXEC (@SQL)
					
			/*  MARK THE AUTHORISATION STATUS 'A' IN CASE OF REJECT THE RECORD*/
				SET @SQL=''
				SET @SQL='UPDATE '+@TableWithSchema +' SET'
				SET @SQL=@SQL+' AuthorisationStatus=''A'''
				SET @SQL=@SQL+'  WHERE (EffectiveFromTimeKey<='+cast(@TimeKey AS VARCHAR(5)) +' AND EffectiveToTimeKey>=' +CAST(@TimeKey AS VARCHAR(5))+')'
				SET @SQL=@SQL+ CASE WHEN @ParentColumn<>'' THEN ' AND '+ @ParentColumn +'= ' +@ParentColumnValue ELSE '' END
				SET @SQL=@SQL+ ' AND ' + @BaseColumn+'='''+CAST(@BaseColumnValue AS VARCHAR(20))+''''			
				SET @SQL=@SQL +' AND AuthorisationStatus in(''MP'',''DP'')'				
				EXEC (@SQL)
					
		END

	ELSE IF @OperationFlag=16 OR @AuthMode='N'
		BEGIN	
		
							
			/*  AUTHORISE DATA IN MAKER CHECKER MODE OR ADD/EDIT IN NON-MAKER CHECKER */
			IF @AuthMode='N'
				BEGIN
					
					IF @OperationFlag=1
						BEGIN
							SET @CreatedBy =@CreateModifyApprovedBy
							SET @DateCreated =GETDATE()
						END
					ELSE
						BEGIN
							
							SET @ModifiedBy  =@CreateModifyApprovedBy
							SET @DateModified =GETDATE()

							SET @SQL=''	
					
							/*-----FIND CREADED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE	*/
							SET @SQL='SELECT CreatedBy,DateCreated FROM '+@TableWithSchema + ' WHERE (EffectiveFromTimeKey<='+cast(@TimeKey AS VARCHAR(5)) +' AND EffectiveToTimeKey>=' +CAST(@TimeKey AS VARCHAR(5))+')'
							SET @SQL=@SQL+ CASE WHEN @ParentColumn<>'' THEN ' AND '+ @ParentColumn +'= ' +@ParentColumnValue ELSE '' END
							SET @SQL=@SQL+ 'AND ' + @BaseColumn+'='''+CAST(@BaseColumnValue AS VARCHAR(20))+''''	
							
							--PRINT 'OP 2'+@SQL


							TRUNCATE TABLE #MasterInfo
							INSERT INTO #MasterInfo(CreatedBy,DateCreated)
						
							EXEC (@SQL)
						
							/* UPDATING CREATEDBY AND DATECREATED FROM MOD OR MAIN TABLE AS RECORD IS AVAILABLE AS PER ABOVE SCRIPT */
							SELECT	@CreatedBy=CreatedBy,@DateCreated=DateCreated
							FROM #MasterInfo

							SET @ApprovedBy = @ApprovedBy			
							SET @DateApproved=GETDATE()
						END
				END
		
	-------------
			
			
			/*--SET PARAMETERS AND UPDATE MOD TABLEIN CASE MAKER CHECKER ENABLED	*/
			IF @AuthMode='Y'
				BEGIN
				
					DECLARE @DelStatus CHAR(2)
					DECLARE @CurrRecordFromTimeKey int=0

					SET @SQL='SELECT MAX('+@EntityKey+') EntityKey FROM '+@TableWithSchema_Mod + ' WHERE (EffectiveFromTimeKey<='+cast(@TimeKey AS VARCHAR(5)) +' AND EffectiveToTimeKey>=' +CAST(@TimeKey AS VARCHAR(5))+')'
					SET @SQL=@SQL+ CASE WHEN @ParentColumn<>'' THEN ' AND '+ @ParentColumn +'= ' +@ParentColumnValue ELSE '' END
					SET @SQL=@SQL+ 'AND ' + @BaseColumn+'='''+CAST(@BaseColumnValue AS VARCHAR(20))+''''	
					SET @SQL=@SQL +' AND AuthorisationStatus in(''NP'',''MP'',''DP'')'	

					TRUNCATE TABLE #MasterInfo

					INSERT INTO #MasterInfo(EntityKey)
					EXEC(@SQL)



					SELECT @ExEntityKey=EntityKey from #MasterInfo

					SET @SQL='SELECT AuthorisationStatus,CreatedBy,DateCreated,ModifiedBy, DateModified FROM '+@TableWithSchema_Mod + ' WHERE '+@EntityKey+'='+CAST(@ExEntityKey AS VARCHAR(10))


					TRUNCATE TABLE #MasterInfo
					INSERT INTO #MasterInfo(AuthorisationStatus,CreatedBy,DATECreated,ModifiedBy, DateModified)
					EXEC(@SQL)
					
					SELECT	@DelStatus=AuthorisationStatus,@CreatedBy=CreatedBy,@DateCreated=DateCreated,@ModifiedBy=ModifiedBy, @DateModified=DateModified FROM #MasterInfo
					
					
					SET @ApprovedBy = @CreateModifyApprovedBy			
					SET @DateApproved=GETDATE()
				
					DECLARE @CurEntityKey INT=0

					SET @SQL='SELECT MIN('+@EntityKey+') EntityKey FROM '+@TableWithSchema_Mod + ' WHERE (EffectiveFromTimeKey<='+cast(@TimeKey AS VARCHAR(5)) +' AND EffectiveToTimeKey>=' +CAST(@TimeKey AS VARCHAR(5))+')'
					SET @SQL=@SQL+ CASE WHEN @ParentColumn<>'' THEN ' AND '+ @ParentColumn +'= ' +@ParentColumnValue ELSE '' END
					SET @SQL=@SQL+ 'AND ' + @BaseColumn+'='''+CAST(@BaseColumnValue AS VARCHAR(20))+''''	
					SET @SQL=@SQL +' AND AuthorisationStatus in(''NP'',''MP'',''DP'')'	

					TRUNCATE TABLE #MasterInfo
					INSERT INTO #MasterInfo(EntityKey)
					EXEC(@SQL)


		
					DECLARE @MinEntityKey INT=0
					SELECT @MinEntityKey =EntityKey FROM #MasterInfo

					SET @SQL='SELECT EffectiveFromTimeKey FROM '+@TableWithSchema_Mod + ' WHERE '+@EntityKey+'='+CAST(@MinEntityKey AS VARCHAR(10))

					TRUNCATE TABLE #MasterInfo
					INSERT INTO #MasterInfo(EffectiveFromTimeKey)
					EXEC(@SQL)

					SELECT @CurrRecordFromTimeKey=EffectiveFromTimeKey FROM #MasterInfo
				
					SET @SQL=''
					SET @SQL='UPDATE '+@TableWithSchema_Mod +' SET'
					SET @SQL=@SQL+' EffectiveToTimeKey='+CAST(@EffectiveFromTimeKey-1 AS VARCHAR(5)) -- TEMPORARY USING CURRENT TIMEKEY 
					--SET @SQL=@SQL+' EffectiveToTimeKey='+CAST(@CurrRecordFromTimeKey-1 AS VARCHAR(5))

					SET @SQL=@SQL+'  WHERE (EffectiveFromTimeKey<='+cast(@TimeKey AS VARCHAR(5)) +' AND EffectiveToTimeKey>=' +CAST(@TimeKey AS VARCHAR(5))+')'
					SET @SQL=@SQL+ CASE WHEN @ParentColumn<>'' THEN ' AND '+ @ParentColumn +'= ' +@ParentColumnValue ELSE '' END
					SET @SQL=@SQL+ ' AND ' + @BaseColumnValue +'='''+CAST(@BaseColumnValue AS VARCHAR(20))+''''			
					SET @SQL=@SQL +' AND AuthorisationStatus=''A'''				
					
					
					EXEC (@SQL)
									
					IF @DelStatus='DP' 
						BEGIN	
								/* DELETE REORD AND AUTHORISE IN MAKER CHECKER */
								SET @SQL=''
								SET @SQL='UPDATE '+@TableWithSchema_Mod +' SET'
								SET @SQL=@SQL+' ApprovedBy='+''''+@ApprovedBy+''''+ ', DateApproved='+''''+CAST(@DateApproved AS VARCHAR(19))+''''+ ', AuthorisationStatus=''A'''
								SET @SQL=@SQL+', EffectiveToTimeKey='+CAST(@EffectiveFromTimeKey-1 AS VARCHAR(5))
								SET @SQL=@SQL+'  WHERE (EffectiveFromTimeKey<='+cast(@TimeKey AS VARCHAR(5)) +' AND EffectiveToTimeKey>=' +CAST(@TimeKey AS VARCHAR(5))+')'
								SET @SQL=@SQL+ CASE WHEN @ParentColumn<>'' THEN ' AND '+ @ParentColumn +'= ' +@ParentColumnValue ELSE '' END
								SET @SQL=@SQL+ ' AND ' + @BaseColumn+'='''+CAST(@BaseColumnValue AS VARCHAR(20))+''''			
								SET @SQL=@SQL +' AND AuthorisationStatus in(''NP'',''MP'',''DP'')'				
								
								EXEC (@SQL)
					
								SET @SQL=''
								SET @SQL='UPDATE '+@TableWithSchema +' SET'
								SET @SQL=@SQL+' ApprovedBy='+''''+@ApprovedBy+''''+ ', DateApproved='+''''+CAST(@DateApproved AS VARCHAR(19))+''''+ ', AuthorisationStatus=''A'''
								SET @SQL=@SQL+' ,ModifiedBy='+''''+@ModifiedBy+''''+ ', DateModified='+''''+CAST(@DateModified AS VARCHAR(19))+''''
								SET @SQL=@SQL+' ,EffectiveToTimeKey='+CAST(@EffectiveFromTimeKey-1 AS VARCHAR(5))
								SET @SQL=@SQL+'  WHERE (EffectiveFromTimeKey<='+cast(@TimeKey AS VARCHAR(5)) +' AND EffectiveToTimeKey>=' +CAST(@TimeKey AS VARCHAR(5))+')'
								SET @SQL=@SQL+ CASE WHEN @ParentColumn<>'' THEN ' AND '+ @ParentColumn +'= ' +@ParentColumnValue ELSE '' END
								SET @SQL=@SQL+ ' AND ' + @BaseColumn+'='''+CAST(@BaseColumnValue AS VARCHAR(20))+''''			
								EXEC (@SQL)

						END -- END OF DELETE BLOCK
			
					ELSE  -- OTHER THAN DELETE STATUS
						BEGIN
							
							SET @SQL=''
								SET @SQL='UPDATE '+@TableWithSchema_Mod +' SET'
								SET @SQL=@SQL+' ApprovedBy='+''''+@ApprovedBy+''''+ ', DateApproved='+''''+CAST(@DateApproved AS VARCHAR(19))+''''+ ', AuthorisationStatus=''A'''
								SET @SQL=@SQL+'  WHERE (EffectiveFromTimeKey<='+cast(@TimeKey AS VARCHAR(5)) +' AND EffectiveToTimeKey>=' +CAST(@TimeKey AS VARCHAR(5))+')'
								SET @SQL=@SQL+ CASE WHEN @ParentColumn<>'' THEN ' AND '+ @ParentColumn +'= ' +@ParentColumnValue ELSE '' END
								SET @SQL=@SQL+ ' AND ' +@BaseColumn+ '='''+CAST(@BaseColumnValue AS VARCHAR(20))+''''			
								SET @SQL=@SQL +' AND AuthorisationStatus in(''NP'',''MP'')'			
								EXEC (@SQL)

								print @SQL
						
						END			
				END
			
			

			IF ISNULL(@DelStatus,'') <>'DP' OR @AuthMode ='N'
				BEGIN
				print 'tri'
					DECLARE @IsAvailable CHAR(1)='N'
							,@IsSCD2 CHAR(1)='N'
						
					/* GENERATING QUERY FOR RECORD IS EXISTING OR NOT */
					SET @SQL='SELECT 1 EntityKey FROM '+@TableWithSchema + ' WHERE (EffectiveFromTimeKey<='+cast(@TimeKey AS VARCHAR(5)) +' AND EffectiveToTimeKey>=' +CAST(@TimeKey AS VARCHAR(5))+')'
					SET @SQL=@SQL+ CASE WHEN @ParentColumn<>'' THEN ' AND '+ @ParentColumn +'= ' +@ParentColumnValue ELSE '' END
					SET @SQL=@SQL+ 'AND ' + @BaseColumn+'='''+CAST(@BaseColumnValue AS VARCHAR(20))+''''
					TRUNCATE TABLE #MasterInfo					
					
					SELECT 'AB',@SQL
					INSERT INTO #MasterInfo(EntityKey)
				
				
					EXEC(@SQL)

					IF EXISTS(SELECT 1 FROM #MasterInfo)
						BEGIN
							
								/* GENERATING QUERY FOR RECORD IS EXISTING ON SAME TIMEKEY OR PREV. TIMEKEY */
								SET @IsAvailable='Y'
								SET @AuthorisationStatus='A'
								
								SET @SQL='SELECT 1 EntityKey FROM '+@TableWithSchema + ' WHERE (EffectiveFromTimeKey<='+cast(@TimeKey AS VARCHAR(5)) +' AND EffectiveToTimeKey>=' +CAST(@TimeKey AS VARCHAR(5))+')'
								SET @SQL=@SQL+ 'AND EffectiveFromTimeKey='+CAST(@EffectiveFromTimeKey AS VARCHAR(5))
								SET @SQL=@SQL+ CASE WHEN @ParentColumn<>'' THEN ' AND '+ @ParentColumn +'= ' +@ParentColumnValue ELSE '' END
								SET @SQL=@SQL+ 'AND ' + @BaseColumn+'='''+CAST(@BaseColumnValue AS VARCHAR(20))+''''	


								print @sql
								TRUNCATE TABLE #MasterInfo
								INSERT INTO #MasterInfo(EntityKey)
								EXEC(@SQL)
								select * from #MasterInfo

								print '12344556'
							IF EXISTS(SELECT 1 FROM #MasterInfo)
								BEGIN
									
									/* UPDATING RECORD IN CASE OF AVAILABLE ON SAME TIMEKEY*/
									SET @SQL='UPDATE '+	@TableWithSchema + ' SET '
									SET @SQL=@SQL+@ColName_DataVal
									SET @SQL=@SQL+',ModifiedBy ='+''''+ @ModifiedBy +''''
									SET @SQL=@SQL+',DateModified='+''''+ CAST(@DateModified AS VARCHAR(19))+''''
									SET @SQL=@SQL+',ApprovedBy=CASE WHEN '''+ @AUTHMODE+'''= ''Y'' THEN '+''''+ ISNULL(@ApprovedBy,'')+'''' + 'ELSE NULL END'
									SET @SQL=@SQL+',DateApproved =CASE WHEN '''+ @AUTHMODE+'''= ''Y'' THEN '+''''+CAST(@DateApproved AS VARCHAR(19))+''''+ 'ELSE NULL END'
									SET @SQL=@SQL+',AuthorisationStatus= CASE WHEN '''+ @AUTHMODE+'''= ''Y'' THEN ''A'' ELSE NULL END'
									SET @SQL=@SQL+' WHERE (EffectiveFromTimeKey<='+cast(@TimeKey AS VARCHAR(5)) +' AND EffectiveToTimeKey>=' +CAST(@TimeKey AS VARCHAR(5))+')'
									SET @SQL=@SQL+ CASE WHEN @ParentColumn<>'' THEN ' AND '+ @ParentColumn +'= ' +@ParentColumnValue ELSE '' END
									SET @SQL=@SQL+ 'AND ' + @BaseColumn+'='''+CAST(@BaseColumnValue AS VARCHAR(20))+''''	

									PRINT @SQL
									PRINT 'GGGGGGGGGG'
									EXEC (@SQL)
									SET @SQL='UPDATE '+	@TableWithSchema + ' SET AuthorisationStatus=''A'' WHERE  (EffectiveFromTimeKey<='+cast(@TimeKey AS VARCHAR(5)) +' AND EffectiveToTimeKey>=' +CAST(@TimeKey AS VARCHAR(5))+') AND ISNULL(AuthorisationStatus,''A'')=''A''AND ' + @BaseColumn+'='''+CAST(@BaseColumnValue AS VARCHAR(20))+''''	
									
									SELECT @SQL
									PRINT 'SSSSSSSSSSS'
									EXEC (@SQL)
									
									
								END	
							ELSE
								BEGIN
									SET @IsSCD2='Y'
								END
						END
						
					IF @IsAvailable='N' OR @IsSCD2='Y'
						BEGIN
						      PRINT 'AUTH'
						
							  PRINT @IsAvailable
							 
								/* INSERT DATA IN MAIN TABLE EITHER ADDING THE RECORD AND BEING SCD2*/
								print @BaseColumn
								
							
								SET @SQL=' INSERT INTO '+ @TableWithSchema +' ('+ @BaseColumn +','+ @ColName 
								SET @SQL=@SQL+ CASE WHEN @ParentColumn <>'' THEN ','+@ParentColumn ELSE '' END
								SET @SQL=@SQL+',AuthorisationStatus,EffectiveFromTimeKey,EffectiveToTimeKey,CreatedBy,DateCreated,ModifiedBy,DateModified,ApprovedBy,DateApproved)'
								
								SET @SQL=@SQL+' SELECT '+CAST(@BaseColumnValue AS VARCHAR(20))+','+@DataVal
								SET @SQL=@SQL+ CASE WHEN @ParentColumn <>'' THEN ','+@ParentColumnValue ELSE '' END
								SELECT @SQL
								SET @SQL=@SQL+CASE WHEN @AUTHMODE='Y' THEN ','''+ISNULL(@AuthorisationStatus,'NULL')+'''' ELSE ',NULL'  END
								SET @SQL=@SQL+','+''''+CAST(@EffectiveFromTimeKey AS VARCHAR(5))+''''
								SET @SQL=@SQL+','+''''+CAST(@EffectiveToTimeKey AS VARCHAR(5))+''''								
								SET @SQL=@SQL+','''+ISNULL(@CreatedBy,'')+''''+','''+CAST(ISNULL(@DateCreated,'NULL') AS VARCHAR(19))+''''
								SET @SQL=@SQL+CASE WHEN @IsAvailable='Y' THEN ','''+ISNULL(@ModifiedBy,'')+'''' ELSE ',NULL'  END
								SET @SQL=@SQL+CASE WHEN @IsAvailable='Y' THEN +','''+CAST(ISNULL(@DateModified,'') AS VARCHAR(19))+''''  ELSE ',NULL'  END
								SET @SQL=@SQL+CASE WHEN @AUTHMODE='Y' THEN ','''+ISNULL(@ApprovedBy,'')+'''' ELSE ',NULL'  END
								SET @SQL=@SQL+CASE WHEN @AUTHMODE='Y' THEN +','''+CAST(ISNULL(@DateApproved,'') AS VARCHAR(19))+'''' ELSE ',NULL'  END
								SET @SQL=REPLACE(@SQL,'''NULL''','NULL')
								PRINT 'AUTH '+@SQL
								SELECT @SQL
								EXEC (@SQL)

								SET @SQL='UPDATE '+	@TableWithSchema + ' SET AuthorisationStatus=null WHERE  (EffectiveFromTimeKey<='+cast(@TimeKey AS VARCHAR(5)) +' AND EffectiveToTimeKey>=' +CAST(@TimeKey AS VARCHAR(5))+')  and ISNULL(AuthorisationStatus,'''')=''NU''AND ' + @BaseColumn+'='''+CAST(@BaseColumnValue AS VARCHAR(20))+''''	
								EXEC (@SQL)

						END
						

					
					IF @IsSCD2='Y' 
						BEGIN
								/* EXPIRED THE RECORD IN MAIN TABLE FOR SCD2 */
								SET @SQL='UPDATE '+@TableWithSchema +' SET'
								SET @SQL=@SQL+' AuthorisationStatus=CASE WHEN '''+@AUTHMODE+'''=''Y'' THEN  ''A'' ELSE NULL END'
								SET @SQL=@SQL+', EffectiveToTimeKey='+CAST(@EffectiveFromTimeKey-1 AS VARCHAR(5))
								SET @SQL=@SQL+' WHERE (EffectiveFromTimeKey<='+cast(@TimeKey AS VARCHAR(5)) +' AND EffectiveToTimeKey>=' +CAST(@TimeKey AS VARCHAR(5))+')'
								SET @SQL=@SQL+' AND EffectiveFromTimeKey<'+CAST(@EffectiveFromTimeKey AS VARCHAR(5))
								SET @SQL=@SQL+ CASE WHEN @ParentColumn<>'' THEN ' AND '+ @ParentColumn +'= ' +@ParentColumnValue ELSE '' END
								SET @SQL=@SQL+' AND ' + @BaseColumn+'='''+CAST(@BaseColumnValue AS VARCHAR(20))+''''			
								
								EXEC (@SQL)
							print 'update'
							print @SQL

						END
				
				/*To be enable for maintain history	*/
					---GOTO CommonMaster_Insert
				END

			IF @AuthMode='N'
				BEGIN
						SET @AuthorisationStatus='A'
						GOTO CommonMaster_Insert
						HistoryRecordInsert:
				
				END		

			
						
		END 

		
-------------END---------- 
---------call log 

	IF @OperationFlag IN(1,2,3,16,17,18)
		BEGIN
			/* EXECUTING LOG ATTENDANCE PART IN BOTHE MAKER CHECKER OR NON-MAKER CHECKER MODE */	
			
				IF @OperationFlag=2 
					BEGIN 
						SET @CreatedBy=@ModifiedBy
					END
				IF @OperationFlag NOT IN(16,17) 
					BEGIN
						SET @ApprovedBy=NULL
					END
		
				SET @DateCreated= GETDATE()
		
				
				DECLARE @ReferenceID VARCHAR(10), @ScreenEntityId INT=0
					SET  @ReferenceID=CAST(@BaseColumnValue AS VARCHAR(20)) 
		
				
				SET @ScreenEntityId=@MenuID

				--PRINT 'INSERT LOG'
				/* CALLING OF LOG ATTANDENDE SP*/
	PRINT 'aaaUUUUUUUUUU'
				
				EXEC LogDetailsInsertUpdate_Attendence -- MAINTAIN LOG TABLE
					0,-- BranchCode 
					@MenuID,
					@ReferenceID,--  ,
					@CreatedBy,
					@ApprovedBy,-- @ApproveBy 
					@DateCreated,
					@Remark,
					@ScreenEntityId, -- for FXT060 screen
					@OperationFlag,
					@AuthMode 
						
			
		END	

	--INT 'END LOG'
--------------------------
	SET @ErrorHandle=1
	CommonMaster_Insert:
	IF @ErrorHandle=0
		BEGIN
				PRINT 'UUUUUUUUUU'
			
				/* INSERT DATA INTO MOD TABLE*/
			
				SET @SQL=' INSERT INTO '+ @TableWithSchema_Mod +' ('+@BaseColumn
				SET @SQL=@SQL+ CASE WHEN @ParentColumn <>'' THEN ','+@ParentColumn ELSE '' END
				SET @SQL=@SQL+','+ @ColName 
				SET @SQL=@SQL+',AuthorisationStatus,EffectiveFromTimeKey,EffectiveToTimeKey,CreatedBy,DateCreated,ModifiedBy,DateModified,ApprovedBy,DateApproved,ChangeFields)'
				SET @SQL=@SQL+' SELECT '+CAST(@BaseColumnValue AS VARCHAR(20))
				SET @SQL=@SQL+ CASE WHEN @ParentColumn <>'' THEN ','+@ParentColumnValue ELSE '' END
				SET @SQL=@SQL+','+ @DataVal
				SET @SQL=@SQL+','''+ISNULL(@AuthorisationStatus,'')+''''+','''+CAST(@EffectiveFromTimeKey AS VARCHAR(5))+''''+','''+CAST(@EffectiveToTimeKey AS VARCHAR(5))+'''' 
				SET @SQL=@SQL+','''+ISNULL(@CreatedBy,'')+''''+','''+CAST(ISNULL(@DateCreated,'') AS VARCHAR(19))+''''
			
				SET @SQL=@SQL+CASE WHEN @ModifiedBy<>'' THEN ','''+ISNULL(@ModifiedBy,'')+'''' ELSE ',NULL'  END
				SET @SQL=@SQL+CASE WHEN @ModifiedBy<>'' THEN +','''+CAST(ISNULL(@DateModified,'') AS VARCHAR(19))+''''  ELSE ',NULL'  END
				SET @SQL=@SQL+CASE WHEN @ApprovedBy<>'' THEN ','''+ISNULL(@ApprovedBy,'')+'''' ELSE ',NULL'  END
				SET @SQL=@SQL+CASE WHEN @ApprovedBy<>'' THEN +','''+CAST(ISNULL(@DateApproved,'') AS VARCHAR(19))+'''' ELSE ',NULL'  END
				SET @SQL=@SQL+CASE WHEN @ChangeField<>'' THEN +','''+CAST(ISNULL(@ChangeField,'') AS VARCHAR(19))+'''' ELSE ',NULL'  END
				SET @SQL=REPLACE(@SQL, '''NULL''','NULL')

				EXEC (@SQL)
				/* REALLOCATE THE POINTER TO THE POSITION FROM WHERE CALLED THIS BLOCK */
				IF @OperationFlag=1 AND @AuthMode='Y'
					BEGIN
						GOto CommonMaster_Insert_Add
					END
				ELSE IF (@OperationFlag=2 OR @OperationFlag=3) AND @AuthMode='Y'
					BEGIN		
						GOTO CommonMaster_Edit_Delete
					END

				ELSE IF @AuthMode='N'
					BEGIN
							GOTO HistoryRecordInsert
					END		

		END
	COMMIT TRANSACTION
	/* RETURN THE RESULT AFTER SAVING THE DATA */
	SET @Result=CAST(@BaseColumnValue AS int)
	RETURN @Result
	END TRY
	BEGIN CATCH
		/* ROLLING BACK TRANSACTION IN CASE OF ERRONR IN EXECUTION ABOVE SCRIPTS*/
		SELECT ERROR_MESSAGE()
		ROLLBACK TRANSACTION
		SET @Result= -1
		RETURN @Result
	END CATCH

	/*  END OF EXECUTION */
END


GO