SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetaDynamicSelectGrid]
--DECLARE
	 @MenuId Int=0,
	 @TimeKey INT=24848,
	 @Mode TINYINT=0,
	 @ParentColumnValue varchar(50)=NULL,	 
	 @TabId INT = 0,
	 @SearchCondition VARCHAR(500)='',
	 @SearchFrom VARCHAR(20)=N'Screen',
	 @UserLoginID VARCHAR(20) ='maheshs'
	 

 AS 
BEGIN
	PRINT 99999
	 SET  @SearchCondition= ISNULL(@SearchCondition,'')
	 


	--exec MetaDynamicSelectGrid @MenuId=6670,@TimeKey=49999,@Mode=N'2',@ParentColumnValue=3,@TabId=325
	DECLARE @SQL VARCHAR(MAX),
		@TableName varchar(500),
		@TableWithSchema varchar(50),
		@TableWithSchema_Mod varchar(50),
		@Schema varchar(5),
		@BaseColumn varchar(50),
		@EntityKey VARCHAR(50),
		@ChangeFields VARCHAR(200),
		@ParentColumn varchar(50)='',
		@ParentTable varchar(50),
		@IsScreenMenuId	CHAR(1)='N',
		@SelectColumns VARCHAR(MAX)

		--IF @SearchFrom = 'QuickAccess' AND @MenuId = 602
		--BEGIN
		--		SET @MenuId = 601
		--		SET @BaseColumn = @ParentColumn
		--		SET @ParentColumn = ''
		--END
	
		
	SET @ParentColumnValue = ISNULL(@ParentColumnValue,'0')
	SELECT @BaseColumn = ControlName FROM MetaDynamicScreenField where MenuId=@MenuId AND BaseColumnType='BASE' AND ISNULL(ParentcontrolID,0)= CASE WHEN @TabId > 0 THEN @TabId ELSE ISNULL(ParentcontrolID,0) END  
											AND ValidCode='Y'
		SELECT @IsScreenMenuId = 'Y' FROM MetaDynamicScreenField where MenuId=@MenuId AND ControlName='ScreenMenuId' AND ISNULL(ParentcontrolID,0)= CASE WHEN @TabId > 0 THEN @TabId ELSE ISNULL(ParentcontrolID,0) END 
								AND ValidCode='Y'
		
	SELECT @ParentColumn= SourceColumn,@ParentTable=SourceTable  from MetaDynamicScreenField where MenuId=@MenuId AND BaseColumnType='PARENT' 
				AND ISNULL(ParentcontrolID,0)= CASE WHEN @TabId > 0 THEN @TabId ELSE ISNULL(ParentcontrolID,0) END 
				AND ValidCode='Y'

				if(@MenuId = 621)
				BEGIN
				select @TimeKey = (select Timekey from sysdaymatrix where cast(date as date) = cast (GetDate() as date))
	             END
				 if(@MenuId = 607)
				BEGIN
				select @TimeKey = (select Timekey from sysdaymatrix where cast(date as date) = cast (GetDate() as date))
	             END
	--SELECT 	'BASECOLUMN',@BaseColumn		
	--SELECT 'ParentColumn',@ParentColumn	

	IF  OBJECT_ID('Tempdb..#TmmpQry') IS NOT NULL
			DROP TABLE #TmmpQry

	CREATE TABLE #TmmpQry ( SourceColumn varchar(50),SourceTable varchar(50),DataType varchar(50))
	
		PRINT @TabId
		INSERT INTO #TmmpQry (SourceColumn,SourceTable,DataType)
		SELECT DISTINCT c.SourceColumn, c.SourceTable ,
				B.NAME+ ''+
					(CASE 
						WHEN B.NAME IN ('VARCHAR','NVARCHAR','CHAR') 
							THEN  +'('+cast(A.max_length as varchar(4))+')'
						WHEN B.NAME IN ('decimal','numeric') 
							THEN  +'('+cast(A.precision as varchar(4))+','+CAST(A.scale as varchar(2))+')'
						ELSE '' END
					) AS Datatype
	FROM SYS.COLUMNS  A
		INNER JOIN SYS.types B 
			ON B.system_type_id=A.system_type_id
		INNER JOIN MetaDynamicScreenField C
			ON C.ControlName=A.name
		INNER JOIN MetaDynamicGrid D
			ON D.ControlId=C.ControlId
	WHERE MENUID=@MenuId
		AND ISNULL(C.ParentcontrolID,0)= CASE WHEN @TabId > 0 THEN @TabId ELSE ISNULL(C.ParentcontrolID,0) END 
		AND ValidCode='Y'
		--AND (OBJECT_NAME(OBJECT_ID) NOT LIKE 'Dim%' AND (OBJECT_NAME(OBJECT_ID) NOT LIKE '%_Mod'))
		AND (OBJECT_NAME(OBJECT_ID) NOT LIKE '%_Mod')
		AND ISNULL(c.SourceColumn,'')<>'' 
		AND  OBJECT_NAME(OBJECT_ID)<>'ResSelect' AND B.NAME<>'sysname'
		AND OBJECT_NAME(A.OBJECT_ID) IN(SELECT SourceTable FROM MetaDynamicScreenField  
											WHERE MENUID=@MenuId AND ISNULL(ParentcontrolID,0)= CASE WHEN @TabId > 0 THEN @TabId ELSE ISNULL(ParentcontrolID,0) END 
											AND SourceTable IS NOT NULL
											AND ValidCode='Y'
											GROUP BY SourceTable
						)


	
	  print '***********'


	  
	
		DECLARE @ColName VARCHAR(max)

		SELECT @ColName=STUFF((SELECT  ','+ m1.SourceColumn + ' ' +DataType
							FROM #TmmpQry m1
							FOR XML PATH('')),1,1,'')   
					FROM #TmmpQry M2
		
		SELECT @SelectColumns=STUFF((SELECT  ','+ m1.SourceColumn 
						FROM #TmmpQry m1
						FOR XML PATH('')),1,1,'')   
				FROM #TmmpQry M2

	
	PRINT @ColName +' Column name'
	IF  OBJECT_ID('Tempdb..#TmpGridSelect') IS NOT NULL
		DROP TABLE #TmpGridSelect

	--select * from #TmmpQry
	CREATE TABLE #TmpGridSelect (BaseColumn INT)


	SET @ColName = REPLACE(@ColName, 'VARCHAR(-1)', 'VARCHAR(MAX)')  --ADDED ON 18 APR 2018 BY HAMID FOR VARCHAR(-1)

	SET @SQL=' ALTER TABLE #TmpGridSelect ADD '+@ColName 
	PRINT @SQL
	EXEC (@SQL)

	print '***********2'
	--SELECT * FROM #TmpGridSelect

	ALTER TABLE #TmmpQry add IsMainTable char(1)

	UPDATE #TmmpQry SET IsMainTable= CASE WHEN SourceTable=@ParentTable THEN 'Y' ELSE 'N' END

	IF  OBJECT_ID('Tempdb..#TmpSrcTable') IS NOT NULL
		DROP TABLE #TmpSrcTable

	CREATE TABLE #TmpSrcTable (RowId TINYINT, SourceTable varchar(50))

	--SELECT * FROM #TmmpQry
	INSERT INTO #TmpSrcTable
	SELECT 1 , SourceTable FROM #TmmpQry WHERE IsMainTable='Y'

	DECLARE @RowId1 INT = (SELECT MAX(RowId) FROM #TmpSrcTable)
	INSERT INTO #TmpSrcTable
	SELECT ISNULL(@RowId1,0)+ROW_NUMBER() over (order by  SourceTable) AS RowId, SourceTable 
		FROM #TmmpQry WHERE IsMainTable='N'
		GROUP BY SourceTable

	--SELECT @BaseColumn,@ParentColumn
	--SELECT * FROM #TmpSrcTable
	--SELECT * FROM #TmmpQry
	
	DECLARE @RowId TINYINT=1
	
		WHILE @RowId<=(SELECT COUNT(1) FROM #TmpSrcTable)
			BEGIN		
					
					SELECT @TableName=SourceTable from #TmpSrcTable WHERE RowId=@RowId
				
					SELECT @EntityKey=NAME FROM SYS.columns WHERE OBJECT_NAME(OBJECT_ID)=@TableName AND IS_identity=1
					
					SELECT @TableWithSchema=SCHEMA_NAME(SCHEMA_ID)+'.'+@TableName , @Schema=SCHEMA_NAME(SCHEMA_ID)+'.'  FROM SYS.OBJECTS WHERE name=@TableName
					SELECT @TableWithSchema_Mod=SCHEMA_NAME(SCHEMA_ID)+'.'+@TableName+'_Mod' , @Schema=SCHEMA_NAME(SCHEMA_ID)+'.'  FROM SYS.OBJECTS WHERE name=@TableName+'_Mod'
					
					--PRINT @ColName
					
					PRINT @ParentColumn + ' ParentColumn'
					PRINT @BaseColumn+' BaseColumn'
					PRINT @TableName+' TableName'
					PRINT CAST(@RowId AS VARCHAR) + ' RowId'
					IF @RowId=1
						BEGIN
							SELECT  @ColName=
							STUFF((
									SELECT  ' ,' +SourceColumn
										FROM #TmmpQry  A1
											WHERE SourceColumn<>@ParentColumn AND SourceColumn<>@BaseColumn
											AND SourceTable=@TableName
									FOR XML PATH('')),1,1,'')  
								FROM #TmmpQry A2
						END					
					ELSE
						BEGIN
							SELECT  @ColName=STUFF((
									SELECT  ' ,A.' +SourceColumn +'=B.'+SourceColumn
										FROM #TmmpQry  A1
											WHERE SourceColumn<>@ParentColumn AND SourceColumn<>@BaseColumn
											AND SourceTable=@TableName
									FOR XML PATH('')),1,1,'')  
								FROM #TmmpQry A2
						END

					PRINT '1'

					SET @ColName=RIGHT(@ColName,LEN(@ColName)-1)
					
					IF @RowId=1
						BEGIN
							
							--SET @ColName=	@EntityKey+','+@ColName
							print 'A1'

							SET @SQL='INSERT INTO  #TmpGridSelect( BaseColumn,'+ @ColName +')'
							
							
							SET @ColName='A.'+@ColName

							IF @Mode<>16 
								BEGIN			
								
								   print @ParentColumn +' ParentColumn'
								   print @BaseColumn +'BaseColumn'
									SET @SQL=ISNULL(@SQL,'')+ ' SELECT A.'+@BaseColumn+', '+  @ColName +' FROM  '+@TableWithSchema +' A ' 
									SET @SQL=@SQL+' WHERE (EffectiveFromTimeKey<='+cast(@TimeKey AS VARCHAR(5)) +' AND EffectiveToTimeKey>=' +CAST(@TimeKey AS VARCHAR(5))+')'
									SET @SQL=@SQL+ CASE WHEN @ParentColumnValue<>'0' THEN ' AND '+ @ParentColumn +'= ' +@ParentColumnValue ELSE '' END
									----SET @SQL=@SQL+ CASE WHEN @ParentColumnValue<>'0' THEN  @BaseColumn +'= ' +@ParentColumn  ELSE ' ' END  
								--	SET @SQL=@SQL+ CASE WHEN @ParentColumnValue<>'0' THEN ' AND '+ @ParentColumn +'<>' +@BaseColumn ELSE '' END
									SET @SQL=@SQL+ CASE WHEN @IsScreenMenuId='Y' THEN ' AND ScreenMenuId='+ CAST(@MenuId AS VARCHAR(10))ELSE '' END
									
									SET @SQL=@SQL+' AND ISNULL(AuthorisationStatus,''A'')=''A'''
								
									/* ADDED QUICK SEARCH CONDITION*/
									IF @SearchCondition<>''
										BEGIN
											SET  @SQL=@SQL+ ' AND '+@SearchCondition
										END

									SET  @SQL=@SQL+ ' UNION '
									PRINT 'insert'+@SQL
									
								END
							
						
							SET @SQL=ISNULL(@SQL,'')+ ' SELECT A.'+ @BaseColumn+','+ @ColName +' FROM  '+@TableWithSchema_Mod+' A'   
							PRINT @SQL
							PRINT '11'
								
							SET @SQL=@SQL+' INNER JOIN (SELECT MAX('+@EntityKey+') AS '+@EntityKey + ','+@BaseColumn +' FROM ' +@TableWithSchema_Mod+' B WHERE ' 
															+ CASE WHEN @ParentColumnValue<>'0' THEN  @ParentColumn +'= ' +@ParentColumnValue  ELSE ' ' END  
															--+ CASE WHEN @ParentColumnValue<>'0' THEN  @BaseColumn +'= ' +@ParentColumn  ELSE ' ' END  
															--+ CASE WHEN @ParentColumnValue<>'0' THEN ' AND '+ @ParentColumn +'<>' +@BaseColumn ELSE '' END  TEMP
															+ CASE WHEN @IsScreenMenuId='Y' THEN ' AND B.ScreenMenuId='+ CAST(@MenuId AS VARCHAR(10)) ELSE '' END

															+CASE WHEN @ParentColumnValue<>'0' THEN ' AND ' ELSE ' ' END+ 'B.AuthorisationStatus IN(''NP'',''MP'',''DP'')'
															/* ADDED QUICK SEARCH CONDITION*/
															+ CASE WHEN @SearchCondition<>' ' THEN ' AND '+@SearchCondition ELSE  '' END

															+' GROUP BY B.'+@BaseColumn 
															+' ) B ON A. '
															+ @EntityKey +' = B.'+@EntityKey
							PRINT '11'+@SQL
							
						
							SET @SQL=@SQL+' WHERE (EffectiveFromTimeKey<='+cast(@TimeKey AS VARCHAR(5)) +' AND EffectiveToTimeKey>=' +CAST(@TimeKey AS VARCHAR(5))+')'
							SET @SQL=@SQL+ CASE WHEN @ParentColumnValue<>'0' THEN ' AND A.'+ @ParentColumn +'= ' +@ParentColumnValue ELSE '' END
							SET @SQL=@SQL+ CASE WHEN @IsScreenMenuId='Y' THEN ' AND ScreenMenuId='+ CAST(@MenuId AS VARCHAR(10)) ELSE '' END
							SET @SQL=@SQL+ ' AND AuthorisationStatus IN (''NP'',''MP'',''DP'')'
					
						
							/* ADDED QUICK SEARCH CONDITION*/
							IF @SearchCondition<>''
								BEGIN
									SET  @SQL=@SQL+ ' AND '+@SearchCondition
								END
				
							PRINT 'insert in temp 122'+ @SQL
									
							EXEC (@SQL)
							
						END
					ELSE
						BEGIN
							PRINT 'UPDATE'
						
							SET @SQL='UPDATE A SET '+@ColName
							+' FROM #TmpGridSelect A '
							+' INNER JOIN '+ @TableWithSchema+ ' B ON (EffectiveFromTimeKey<='+cast(@TimeKey AS VARCHAR(5)) +' AND EffectiveToTimeKey>=' +CAST(@TimeKey AS VARCHAR(5))+')'
							+' AND A.BaseColumn=B.'+@BaseColumn
							--+  CASE WHEN @ParentColumnValue<>'0' THEN ' AND '+ @ParentColumn +'= ' +@ParentColumnValue ELSE '' END
							+ CASE WHEN @IsScreenMenuId='Y' THEN ' AND ScreenMenuId='+ CAST(@MenuId AS VARCHAR(10)) ELSE '' END
							+' AND ISNULL(AuthorisationStatus,''A'')=''A'''
							/* ADDED QUICK SEARCH CONDITION*/
							IF @SearchCondition<>''
								BEGIN
									SET  @SQL=@SQL+ ' AND '+@SearchCondition
								END							
							EXEC (@SQL)

							SET @SQL='UPDATE A SET '+@ColName
							+' FROM #TmpGridSelect A '
							+' INNER JOIN '+ @TableWithSchema_Mod+' B ON (EffectiveFromTimeKey<='+CAST(@TimeKey AS VARCHAR(5)) +' AND EffectiveToTimeKey>=' +CAST(@TimeKey AS VARCHAR(5))+')'
							+' AND A.BaseColumn=B.'+@BaseColumn
							+ CASE WHEN @IsScreenMenuId='Y' THEN ' AND ScreenMenuId='+  CAST(@MenuId AS VARCHAR(10)) ELSE '' END

							SET @SQL=@SQL+' INNER JOIN (SELECT MAX('+@EntityKey+') AS '+@EntityKey + ',C.'+@BaseColumn +' FROM ' +@TableWithSchema_Mod+' C ' 
															+' INNER JOIN #TmpGridSelect D ON D.BaseColumn=C.'+@BaseColumn
															+' WHERE C.AuthorisationStatus IN(''NP'',''MP'',''DP'')'
															+ CASE WHEN @IsScreenMenuId='Y' THEN ' AND ScreenMenuId='+ CAST(@MenuId AS VARCHAR(10)) ELSE '' END
															+ CASE WHEN @SearchCondition<>' ' THEN ' AND '+@SearchCondition ELSE  '' END
															+' GROUP BY C.'+@BaseColumn 
															+' ) C ON C. '
															+ @EntityKey +' = B.'+@EntityKey
							SET @SQL=@SQL+' WHERE (EffectiveFromTimeKey<='+cast(@TimeKey AS VARCHAR(5)) +' AND EffectiveToTimeKey>=' +CAST(@TimeKey AS VARCHAR(5))+')'
							--SET @SQL=@SQL+ CASE WHEN @ParentColumnValue<>'0' THEN ' AND '+ @ParentColumn +'= ' +@ParentColumnValue ELSE '' END
							SET @SQL=@SQL+' AND AuthorisationStatus IN (''NP'',''MP'',''DP'')'							
							+ CASE WHEN @IsScreenMenuId='Y' THEN ' AND ScreenMenuId='+ CAST(@MenuId AS VARCHAR(10)) ELSE '' END
							/* ADDED QUICK SEARCH CONDITION*/
							IF @SearchCondition<>''
								BEGIN
									SET  @SQL=@SQL+ ' AND '+@SearchCondition
								END							
							PRINT 'abc'+ @SQL
						
								EXEC (@SQL)
							
						END					
				PRINT CAST(@RowId AS VARCHAR(10)) +'END RowId'
				SET @RowId=@RowId+1
				
			
			
			END
		

			DECLARE @UserLocation VARCHAR(10),@UserLocationCode VARCHAR(10) 
					
					SELECT @UserLocation= UserLocation 
					, @UserLocationCode = UserLocationCode
					FROM DimUserInfo
					WHERE EffectiveFromTimeKey <= @TimeKey
					AND EffectiveToTimeKey >= @TimeKey
					AND UserLoginID =  @UserLoginID

			IF @MenuId IN (607, 614,615, 621, 625, 627,640,641, 642, 643,1500,1501,1502,1503)  --641,642,643
			BEGIN
				DROP TABLE IF EXISTS  #BRANCH
				CREATE TABLE #BRANCH
				(
					BranchCode VARCHAR(10)
					,BranchName VARCHAR(50)
					,Code VARCHAR(10)
					,Description VARCHAR(50)
				)


				INSERT INTO #BRANCH 
				EXEC [UserWise_BranchCode] @UserLoginID

				DROP TABLE IF EXISTS  #BRANCHCD
				CREATE TABLE #BRANCHCD
				(
					BranchCode VARCHAR(10)
					,BranchName VARCHAR(50)
					,Code VARCHAR(10)
					,Description VARCHAR(50)
				)
										
				DROP TABLE IF EXISTS #BRANCHCODE
				CREATE TABLE #BRANCHCODE
				(
					UserLocation	VARCHAR(20)
					,UserLocationCode VARCHAR(20)
				)

										
										
				INSERT INTO #BRANCHCD 
				EXEC [UserWise_BranchCode] @UserLoginID
				
				IF @UserLocation ='ZO'
				BEGIN
					INSERT INTO #BRANCHCODE(UserLocation, UserLocationCode)
					SELECT @UserLocation UserLocation, @UserLocationCode UserLocationCode
					UNION
					SELECT 'RO',BranchRegionAlt_Key FROM DimBranch 
					WHERE  EffectiveToTimeKey = 49999
					AND BranchZoneAlt_Key = (CASE WHEN @UserLocation = 'ZO' THEN @UserLocationCode END)
					GROUP BY BranchRegionAlt_Key
					UNION
					SELECT 'BO', BranchCode FROM #BRANCHCD
				END
				ELSE IF @UserLocation ='RO'
				BEGIN
					INSERT INTO #BRANCHCODE(UserLocation, UserLocationCode)
					SELECT @UserLocation UserLocation, @UserLocationCode UserLocationCode
					UNION
					SELECT 'BO', BranchCode FROM #BRANCHCD
				END
				ELSE
				BEGIN
					INSERT INTO #BRANCHCODE(UserLocation, UserLocationCode)
					SELECT 'BO' UserLocation, BranchCode UserLocationCode FROM #BRANCHCD
				END
			END
		
			IF  @MenuId = 503
			BEGIN
				PRINT '503'
				SELECT 'GridData' TableName ,  A.BaseColumn,(GLCode+' - '+GLName) AS GLAlt_key , A.OfficeAccountCode, A.OfficeAccountDescription
				from #TmpGridSelect	A
				INNER  JOIN DimGL GL	ON  GL.EffectiveFromTimeKey <= @TimeKey
								AND GL.EffectiveToTimeKey   >= @TimeKey
								AND GL.GLAlt_Key                = A.GLAlt_key

			END
		

		ELSE IF @MenuId = 601
			BEGIN
				
				PRINT '613'
				SELECT 'GridData' TableName 
				, A.BaseColumn
			
				,A.ReportingOffice,
				A.ReportingOfficeCode
				 ,CONVERT(VARCHAR(10),A.AgitationFromDate,103) AgitationFromDate
				,A.AgitationToDesc
			
				FROM #TmpGridSelect	A
					--where A.EffectiveToTimeKey >= @TimeKey
						
						 
					
			END 



			ELSE  IF @MenuId = 602 AND @SearchFrom='QuickAccess'
			BEGIN
					

					PRINT @MenuId
					PRINT @SearchFrom
					DROP TABLE IF EXISTS  #BRANCH1
					CREATE TABLE #BRANCH1
					(
						BranchCode VARCHAR(10)
						,BranchName VARCHAR(50)
						,Code VARCHAR(10)
						,Description VARCHAR(50)
					)


					INSERT INTO #BRANCH1 
					EXEC [UserWise_BranchCode] @UserLoginID

					
					--SELECT @UserLocation, @Mode
					
					IF @Mode <>16
					BEGIN
						IF @UserLocation = 'HO'
						BEGIN
							print cast(@Mode as VARCHAR(2)) + ' Mode'
							
							
							SELECT 'GridData' TableName, M.AgitationEntityId BaseColumn 
							,ReportingOffice
								,ReportingOfficeCode
								,CONVERT(VARCHAR(10),AgitationFromDate,103)AgitationFromDate
								,CONVERT(VARCHAR(10),AgitationToDate,103)AgitationToDate
								,AgitationToDesc
								,AgitationNatureAlt_Key
								,AgitationNatureOthers
								,CauseAlt_Key
								,CauseOthers
								,StepsInitiatedContain
								,CONVERT(VARCHAR(10),AgitationClosureDate,103)AgitationClosureDate
								, 'Y' IsMainTable
							
							FROM AgitationBasicDtls  M
								WHERE  M.EffectiveFromTimeKey <= @TimeKey AND M.EffectiveToTimeKey >= @TimeKey
							
								AND ISNULL(M.AuthorisationStatus,'A')='A'
							
							UNION ALL

							
								SELECT 'GridData' TableName 
								,B.AgitationEntityId
								,ReportingOffice
								,ReportingOfficeCode
								,CONVERT(VARCHAR(10),AgitationFromDate,103)AgitationFromDate
								,CONVERT(VARCHAR(10),AgitationToDate,103)AgitationToDate
								,AgitationToDesc
								,AgitationNatureAlt_Key
								,AgitationNatureOthers
								,CauseAlt_Key
								,CauseOthers
								,StepsInitiatedContain
								,CONVERT(VARCHAR(10),AgitationClosureDate,103)AgitationClosureDate
								, 'N' IsMainTable
								FROM AgitationBasicDtls_Mod B
								INNER JOIN 
								(
									SELECT AgitationEntityId, MAX(EntityKey)EntityKey FROM AgitationBasicDtls_Mod
									WHERE EffectiveFromTimeKey <= @Timekey AND EffectiveToTimeKey >= @Timekey
									AND AuthorisationStatus IN('NP','MP','DP','RM')
									GROUP BY AgitationEntityId
								)C ON  B.EntityKey = C.EntityKey
							
						END
						ELSE 
						BEGIN

									
								
								SELECT 'GridData' TableName
										, AgitationEntityId AS  BaseColumn 
										,ReportingOffice
										,ReportingOfficeCode
										,CONVERT(VARCHAR(10),AgitationFromDate,103)AgitationFromDate
										,CONVERT(VARCHAR(10),AgitationToDate,103)AgitationToDate
										,AgitationToDesc
										,AgitationNatureAlt_Key
										,AgitationNatureOthers
										,CauseAlt_Key
										,CauseOthers
										,StepsInitiatedContain
										,CONVERT(VARCHAR(10),AgitationClosureDate,103)AgitationClosureDate
										, 'Y' IsMainTable
							FROM AgitationBasicDtls  M
							INNER JOIN #BRANCH1 BR
								ON M.ReportingOfficeCode = BR.BranchCode
								AND  M.EffectiveFromTimeKey <= @TimeKey AND M.EffectiveToTimeKey >= @TimeKey
								AND ISNULL(M.AuthorisationStatus,'A')='A'


									
									

							UNION 

								SELECT 'GridData' TableName 
								,B.AgitationEntityId BaseColumn
								,ReportingOffice
								,ReportingOfficeCode
								,CONVERT(VARCHAR(10),AgitationFromDate,103)AgitationFromDate
								,CONVERT(VARCHAR(10),AgitationToDate,103)AgitationToDate
								,AgitationToDesc
								,AgitationNatureAlt_Key
								,AgitationNatureOthers
								,CauseAlt_Key
								,CauseOthers
								,StepsInitiatedContain
								,CONVERT(VARCHAR(10),AgitationClosureDate,103)AgitationClosureDate
								,'N' IsMainTable
								FROM AgitationBasicDtls_Mod B
								INNER JOIN 
								(
									SELECT AgitationEntityId, MAX(EntityKey)EntityKey FROM AgitationBasicDtls_Mod
									WHERE EffectiveFromTimeKey <= @Timekey AND EffectiveToTimeKey >= @Timekey
									AND AuthorisationStatus IN('NP','MP','DP','RM')
									GROUP BY AgitationEntityId
								)C ON  B.EntityKey = C.EntityKey
							INNER JOIN #BRANCH1 BR
								ON B.ReportingOfficeCode = BR.BranchCode
						END
					END 
					ELSE 
					BEGIN
							
							PRINT CAST(@mode AS VARCHAR(2))+'mode' 
							PRINT @UserLocation +'UserLocation'
							IF @UserLocation ='HO'
							BEGIN
								
									

									SELECT 'GridData' TableName 
											,B.AgitationEntityId AS BaseColumn
											,B.ReportingOffice	
											,ReportingOfficeCode	
											,CONVERT(VARCHAR(10),AgitationFromDate,103)AgitationFromDate
											,CONVERT(VARCHAR(10),AgitationToDate,103)AgitationToDate	
											,AgitationToDesc	
											,AgitationNatureAlt_Key	
											,AgitationNatureOthers	
											,CauseAlt_Key	
											,CauseOthers	
											,StepsInitiatedContain	
											,CONVERT(VARCHAR(10),AgitationClosureDate,103)AgitationClosureDate	
											, 'Y' IsMainTable
									 FROM AgitationBasicDtls B
									INNER JOIN 
									(
										SELECT AgitationEntityId FROM AgitationOfficeInvolvDtls_Mod
										WHERE EffectiveFromTimeKey <=  @Timekey AND EffectiveToTimeKey >= @Timekey
										AND AuthorisationStatus IN('NP','MP','DP','RM')
										GROUP BY AgitationEntityId
									)C
									ON B.EffectiveFromTimeKey <= @Timekey AND B.EffectiveToTimeKey >= @Timekey
									AND B.AgitationEntityId = C.AgitationEntityId
								
								
							END
							ELSE 
							BEGIN
								
								SELECT 'GridData' TableName 
											,B.AgitationEntityId AS BaseColumn
											,B.ReportingOffice	
											,ReportingOfficeCode	
											,CONVERT(VARCHAR(10),AgitationFromDate,103)AgitationFromDate
											,CONVERT(VARCHAR(10),AgitationToDate,103)AgitationToDate	
											,AgitationToDesc	
											,AgitationNatureAlt_Key	
											,AgitationNatureOthers	
											,CauseAlt_Key	
											,CauseOthers	
											,StepsInitiatedContain	
											,CONVERT(VARCHAR(10),AgitationClosureDate,103)AgitationClosureDate	
											, 'Y' IsMainTable
									 FROM AgitationBasicDtls B
									INNER JOIN 
									(
										SELECT AgitationEntityId FROM AgitationOfficeInvolvDtls_Mod
										WHERE EffectiveFromTimeKey <=  @Timekey AND EffectiveToTimeKey >= @Timekey
										AND AuthorisationStatus IN('NP','MP','DP','RM')
										GROUP BY AgitationEntityId
									)C
										ON B.EffectiveFromTimeKey <= @Timekey AND B.EffectiveToTimeKey >= @Timekey
										AND B.AgitationEntityId = C.AgitationEntityId
									INNER JOIN #BRANCH1 BR
										ON B.ReportingOfficeCode = BR.BranchCode
							END
					END 


			END
			ELSE IF @MenuId = 602
			BEGIN
				PRINT '602'
				PRINT CAST(@Mode AS VARCHAR(2)) +' Mode'
				SELECT 'GridData' TableName 
						, A.BaseColumn
						, A.MandaysLostNo
						, A.OfficeInvolved
						, A.StaffInvolvedNo
						, CONVERT(VARCHAR(10), A.UpdateDate,103) UpdateDate
				FROM #TmpGridSelect	A	
			END 

			ELSE IF  @MenuId = 603
			BEGIN
					PRINT '603'

					
							

					SELECT 'GridData' TableName , A.BaseColumn
					, CONVERT(VARCHAR(10),A.BorrowingDate,103) AS BorrowingDate
					, CONVERT(VARCHAR(10),A.LiquidationDate,103) AS LiquidationDate					--, BF.Description AS BorrowingAlt_Key
					, ISNULL(BF.Description,'-') AS BorrowingAlt_Key								--, BO.Description AS FacilityType
					, ISNULL(BO.Description,'-') AS FacilityType									--, BT.Description AS BankTypeAlt_Key
					, ISNULL(BT.Description,'-') AS BankTypeAlt_Key
					--, A.* 
					FROM #TmpGridSelect	 A
					LEFT OUTER JOIN
					(	
						SELECT
						LoanTypeAlt_Key as Code,LoanTypeName as Description 
						FROM DimParameter DP
								INNER JOIN DimLoanType DLG
									ON(DLG.LoanTypeGroup=DP.ParameterName)

						WHERE LoanTypeSubGroup='Short Term Loan'

						UNION


						SELECT	LoanTypeAlt_Key as Code,LoanTypeName as Description 
						FROM DimParameter DP
							INNER JOIN DimLoanType DLG
								ON(DLG.LoanTypeGroup=DP.ParameterName)
						WHERE LoanTypeSubGroup='Schematic'
					)BT  --BANKTYPE

					ON A.BankTypeAlt_Key = BT.Code
					LEFT OUTER JOIN 
					(
						select 
						ParameterAlt_Key as Code ,ParameterName as Description
						from 
						DimParameter
						where DimParameterName='DimBorrowingTYPE'
					)BF --BorrowingFromAlt_Key
					ON 
					--A.FacilityType = BF.Code
					A.BorrowingAlt_Key = BF.Code

					LEFT OUTER JOIN

					(
							select LoanTypeAlt_Key,LoanTypeName as Description from 
							DimParameter DP
								INNER JOIN DimLoanType DLG
									ON(DLG.LoanTypeGroup=DP.ParameterName)
							where DP.ParameterName IN(select ParameterName from DimParameter where  ParameterAlt_Key=2 and DimParameterName='DimBorrowingTYPE')

							union

							select ROW_NUMBER() OVER(ORDER BY LoanTypeAlt_Key ) AS Code,LoanTypeSubGroup as Description from 
							DimParameter DP
							inner Join
							DimLoanType DLG
							ON(DLG.LoanTypeGroup=DP.ParameterName)
							where DP.ParameterName IN(select ParameterName from DimParameter where  ParameterAlt_Key=3 and DimParameterName='DimBorrowingTYPE')
							and LoanTypeAlt_Key IN(50,70)
					)BO --BorrowingFromOthers
					ON A.FacilityType = BO.LoanTypeAlt_Key



			END
			ELSE IF @MenuId = 604
			BEGIN
					IF @Mode = 16
					BEGIN
								SELECT 'GridData' TableName 
								,BCD.BusiCorresEntityId BaseColumn, CONS.ConstitutionName ConstitutionAlt_Key, Name 
								FROM BusinessCorrepondentDtls BCD
								INNER JOIN 
								(
									SELECT A.BusiCorresEntityId FROM BusinessCorresVillageDtl_Mod A
									INNER JOIN 
									(
										SELECT BusiCorresEntityId, BusiCorresVillEntityId,MAX(EntityKey) EntityKey FROM BusinessCorresVillageDtl_Mod
										WHERE EffectiveFromTimeKey <= @Timekey AND EffectiveToTimeKey >= @Timekey
										AND ISNULL(AuthorisationStatus,'A') IN ('NP','MP','DP','RM')
										GROUP BY BusiCorresEntityId, BusiCorresVillEntityId
									)B ON A.EntityKey = B.EntityKey
									GROUP BY A.BusiCorresEntityId
								)CVD  --BusinessCorresVillageDtl_Mod
								ON BCD.EffectiveFromTimeKey <= @Timekey AND BCD.EffectiveToTimeKey >= @Timekey
								AND BCD.BusiCorresEntityId = CVD.BusiCorresEntityId
								LEFT OUTER JOIN DimConstitution CONS
																ON (CONS.EffectiveFromTimeKey <= @TimeKey AND CONS.EffectiveToTimeKey >= @TimeKey)
																AND CONS.ConstitutionAlt_Key = BCD.ConstitutionAlt_Key


								UNION


								SELECT	'GridData' TableName 
													, A.BaseColumn
													, CONS.ConstitutionName  ConstitutionAlt_Key
													, A.Name
											FROM  #TmpGridSelect A

												LEFT OUTER JOIN DimConstitution CONS
													ON (CONS.EffectiveFromTimeKey <= @TimeKey AND CONS.EffectiveToTimeKey >= @TimeKey)
													AND CONS.ConstitutionAlt_Key = A.ConstitutionAlt_Key
								
					END
					ELSE 
					BEGIN
									SELECT	'GridData' TableName 
													, A.BaseColumn
													, CONS.ConstitutionName  ConstitutionAlt_Key
													, A.Name
											FROM  #TmpGridSelect A

												LEFT OUTER JOIN DimConstitution CONS
													ON (CONS.EffectiveFromTimeKey <= @TimeKey AND CONS.EffectiveToTimeKey >= @TimeKey)
													AND CONS.ConstitutionAlt_Key = A.ConstitutionAlt_Key
					END
			END 

			ELSE IF @MenuId = 605
			BEGIN
					
					IF @Mode =16
					BEGIN
					
					
							SELECT	'GridData' TableName 
									, A.BaseColumn
									, Loc.LocationName AS LocationAlt_Key 
									,DISTRICT AS District
									,SUB_DISTRICT AS Taluka
									, P.ParameterName AS [Population]
							FROM #TmpGridSelect	A

								LEFT  JOIN DimLocation LOC
										ON  (LOC.EffectiveFromTimeKey <= @TimeKey AND LOC.EffectiveToTimeKey >= @TimeKey)
										AND LOC.LocationAlt_Key = A.LocationAlt_Key

								LEFT  JOIN DimParameter P
										ON (P.EffectiveFromTimeKey <= @TimeKey AND P.EffectiveToTimeKey >= @TimeKey)
										AND P.DimParameterName = 'DimVillagePopulation'
										AND A.Population = CAST(P.ParameterAlt_Key AS BIGINT)
							
					END
					ELSE 
					BEGIN
								SELECT	'GridData' TableName 
										, A.BaseColumn
										, Loc.LocationName AS LocationAlt_Key 
										,DISTRICT AS District
										,SUB_DISTRICT AS Taluka
										, P.ParameterName AS [Population]
								FROM #TmpGridSelect	A
								
									LEFT  JOIN DimLocation LOC
											ON  (LOC.EffectiveFromTimeKey <= @TimeKey AND LOC.EffectiveToTimeKey >= @TimeKey)
											AND LOC.LocationAlt_Key = A.LocationAlt_Key
								
									LEFT  JOIN DimParameter P
											ON (P.EffectiveFromTimeKey <= @TimeKey AND P.EffectiveToTimeKey >= @TimeKey)
											AND P.DimParameterName = 'DimVillagePopulation'
											AND A.Population = CAST(P.ParameterAlt_Key AS BIGINT)
								
					END
			END
	

				ELSE IF @MenuId = 606
			BEGIN
					select 'GridData' TableName ,BaseColumn,Format([Date],'dd/MM/yyyy') [Date],GL_CashBal,
							'25030 - BALANCE WITH R.B.I' GL_Cash,
							'01021 - SLR (INVST GOVT SEC)' GL_SLR_Sec from #TmpGridSelect
							order by Date desc
				
			END

			ELSE IF @MenuId = 607 AND ISNULL(@SearchFrom,'')=''
			BEGIN
				EXEC CrimerRecoveryDetail @TimeKey, @Mode
			END

			ELSE IF @MenuId = 607
			BEGIN
					IF @Mode = 16
					BEGIN
						SELECT * FROM 
						(
						SELECT	
						'GridData' TableName
						-- 'TableName' GridData
								,P.CrimeEntityId BaseColumn
								, P.BranchCode+' - '+BR.BranchName BranchCode
								, ParameterName CrimeTypeAlt_Key
								, CONVERT(VARCHAR(10), OccurrenceDateTime, 103) OccurrenceDateTime
						
						FROM 
						CrimeDetails P
						INNER JOIN 
						( 
							SELECT CrimeEntityId--, CrimeRecEntityId, MAX(Entitykey) Entitykey 
							FROM CrimerRecoveryDetails_Mod
							WHERE EffectiveFromTimeKey <= @Timekey AND EffectiveToTimeKey >= @Timekey
							AND ISNULL(AuthorisationStatus,'A') IN ('NP','MP','DP','RM') 
							GROUP BY CrimeEntityId, CrimeRecEntityId
						)C ON P.EffectiveFromTimeKey <= @Timekey
							AND P.EffectiveToTimeKey >= @Timekey
							AND P.CrimeEntityId = C.CrimeEntityId
						LEFT OUTER JOIN  DimBranch BR
							ON (BR.EffectiveFromTimeKey <= @Timekey AND BR.EffectiveToTimeKey >= @Timekey)
							AND (BR.BranchCode = P.BranchCode)
						INNER  JOIN DimParameter PR
							ON PR.EffectiveFromTimeKey <=@TimeKey AND PR.EffectiveToTimeKey >= @TimeKey
																AND DimParameterName = 'DimCrime'
																	AND P.CrimeTypeAlt_Key  = PR.ParameterAlt_Key	
						INNER JOIN #BRANCH B
							ON P.BranchCode = B.BranchCode

						UNION 

						SELECT 'GridData' TableName , BaseColumn,BR.BranchCode +' - '+ BranchName AS BranchCode, P.ParameterName CrimeTypeAlt_Key,
						CONVERT(VARCHAR(10),OccurrenceDateTime,103)OccurrenceDateTime 
						FROM #TmpGridSelect	A
						INNER JOIN DimBranch BR 
							ON BR.EffectiveFromTimeKey <= @TimeKey AND BR.EffectiveToTimeKey >= @TimeKey
							AND BR.BranchCode = A.BranchCode
								INNER  JOIN DimParameter P
										ON P.EffectiveFromTimeKey <=@TimeKey AND P.EffectiveToTimeKey >= @TimeKey
										AND DimParameterName = 'DimCrime'
											AND A.CrimeTypeAlt_Key  = P.ParameterAlt_Key
						)A ORDER BY BaseColumn
					END 
					ELSE 
					BEGIN
						SELECT 'GridData' TableName , BaseColumn,BR.BranchCode +' - '+ BranchName AS BranchCode, P.ParameterName CrimeTypeAlt_Key,
						CONVERT(VARCHAR(10),OccurrenceDateTime,103)OccurrenceDateTime 
						FROM #TmpGridSelect	A
						INNER JOIN DimBranch BR 
							ON BR.EffectiveFromTimeKey <= @TimeKey AND BR.EffectiveToTimeKey >= @TimeKey
							AND BR.BranchCode = A.BranchCode
								INNER  JOIN DimParameter P
										ON P.EffectiveFromTimeKey <=@TimeKey AND P.EffectiveToTimeKey >= @TimeKey
										AND DimParameterName = 'DimCrime'
											AND A.CrimeTypeAlt_Key  = P.ParameterAlt_Key
					END
			END
			ELSE IF @MenuId = 608
			BEGIN
					PRINT '608'

					--EXEC tempdb..sp_help #TmpGridSelect
					IF @Mode = 16
					BEGIN
							SELECT 'GridData' TableName 
								,BCD.ComplaintEntityID BaseColumn, 
						        CONVERT(VARCHAR(10),BCD.ComplaintDate,103) ComplaintDate ,
								 CONVERT(VARCHAR(10),BCD.ComplaintRecDate,103) ComplaintRecDate,
								 BCD.StatusAlt_Key as StatusAlt_Key,
							    
									  CONVERT(VARCHAR(10),BCD.ClosureDate,103) ClosureDate
									  ,D.ParameterName AS  StatusAlt_Key,
									  BCD.Reason as Reason,
									   BCD.NoOfDays,
								 P.ParameterName AS OriginatedByAlt_Key
							FROM ComplaintDtl BCD
								INNER JOIN 
								(
									SELECT A.ComplaintEntityID FROM ComplaintProgressDtl_Mod A
									INNER JOIN 
									(
										SELECT ComplaintEntityID, ComplaintProgEntityID,MAX(EntityKey) EntityKey FROM ComplaintProgressDtl_Mod
										WHERE EffectiveFromTimeKey <= @Timekey AND EffectiveToTimeKey >= @Timekey
										AND ISNULL(AuthorisationStatus,'A') IN ('NP','MP','DP','RM')
										GROUP BY ComplaintEntityID, ComplaintProgEntityID
									)B ON A.EntityKey = B.EntityKey
									GROUP BY A.ComplaintEntityID
								)CVD 
									ON BCD.EffectiveFromTimeKey <= @Timekey AND BCD.EffectiveToTimeKey >= @Timekey
									AND BCD.ComplaintEntityID = CVD.ComplaintEntityID
								INNER  JOIN DimParameter P
									ON P.EffectiveFromTimeKey <=@TimeKey AND P.EffectiveToTimeKey >= @TimeKey
									AND DimParameterName = 'DimOriginatedBy'
										AND BCD.OriginatedByAlt_Key  = P.ParameterAlt_Key

										
								INNER  JOIN DimParameter D
								ON D.EffectiveFromTimeKey <=@TimeKey AND D.EffectiveToTimeKey >= @TimeKey
								AND D.DimParameterName = 'DimStatus'
								AND BCD.StatusAlt_Key  = D.ParameterAlt_Key

						UNION
						SELECT 'GridData' TableName 
								, A.BaseColumn,
								 CONVERT(VARCHAR(10),A.ComplaintDate,103) ComplaintDate ,
								 CONVERT(VARCHAR(10),BCD.ComplaintRecDate,103) ComplaintRecDate,
								 BCD.StatusAlt_Key as StatusAlt_Key,
							    
									  CONVERT(VARCHAR(10),BCD.ClosureDate,103) ClosureDate
									  ,D.ParameterName AS  StatusAlt_Key,
									  BCD.Reason as Reason,
									   A.NoOfDays,
								--, A.OriginatedByAlt_Key
								P.ParameterName AS  OriginatedByAlt_Key
						FROM #TmpGridSelect	A
						--select * from #TmpGridSelect
							INNER  JOIN DimParameter P
								ON P.EffectiveFromTimeKey <=@TimeKey AND P.EffectiveToTimeKey >= @TimeKey
								AND DimParameterName = 'DimOriginatedBy'
								AND A.OriginatedByAlt_Key  = P.ParameterAlt_Key

								
								INNER  JOIN DimParameter D
								ON D.EffectiveFromTimeKey <=@TimeKey AND D.EffectiveToTimeKey >= @TimeKey
								AND D.DimParameterName = 'DimStatus'
								AND A.StatusAlt_Key  = D.ParameterAlt_Key
					END
					ELSE 
					BEGIN
						SELECT 'GridData' TableName 
							, A.BaseColumn,
							 CONVERT(VARCHAR(10),A.ComplaintDate,103) ComplaintDate ,
							CONVERT(VARCHAR(10),A.ComplaintRecDate,103) ComplaintRecDate,
						
							 A.ComplaintBy as ComplaintBy
							,D.ParameterName AS  StatusAlt_Key,
						   CONVERT(VARCHAR(10),A.ClosureDate,103) ClosureDate

							  ,A.Reason as Reason,
							   A.NoOfDays
							,P.ParameterName AS  OriginatedByAlt_Key
						FROM #TmpGridSelect	A
							INNER  JOIN DimParameter P
								ON P.EffectiveFromTimeKey <=@TimeKey AND P.EffectiveToTimeKey >= @TimeKey
								AND DimParameterName = 'DimOriginatedBy'
								AND A.StatusAlt_Key  = P.ParameterAlt_Key
							
								INNER  JOIN DimParameter D
								ON D.EffectiveFromTimeKey <=@TimeKey AND D.EffectiveToTimeKey >= @TimeKey
								AND D.DimParameterName = 'DimStatus'
								AND A.StatusAlt_Key  = D.ParameterAlt_Key
					END
									
			END


			ELSE IF @MenuId = 609
			BEGIN
			    	SELECT 'GridData' TableName , 
				    A.BaseColumn , 
					CONVERT(VARCHAR(10),OriginDate,103) OriginDate 
					,CONVERT(VARCHAR(10),ReconcileDate,103) ReconcileDate 
					,CASE WHEN ISNULL(ReconcileDate,'')='' THEN 'Pending' ELSE 'Closed' END  AS Status
					-- A.OriginDate,
					,A. OriginDateRefNo
					  
			    	     from #TmpGridSelect A

				

			END


			
			ELSE IF @MenuId = 690
			BEGIN
			    	  SELECT 'GridData' TableName, 
				      A.BaseColumn, 				
					  A.Address,
                      --A.gender,
                      P.ParameterName    MemberTypeAlt_Key,
					    P.ParameterAlt_Key   MemberTypeAlt_Key,
                      A.MemberName
			    	     from #TmpGridSelect A
						-- select * from #TmpGridSelect
						 INNER  JOIN DimParameter P
								ON P.EffectiveFromTimeKey <=@TimeKey AND P.EffectiveToTimeKey >= @TimeKey
								AND DimParameterName = 'DimSHGMemberDetails'
								AND A.MemberTypeAlt_Key  = P.ParameterAlt_Key

							--	INNER  JOIN DimParameter DP
							--	ON DP.EffectiveFromTimeKey <=@TimeKey AND DP.EffectiveToTimeKey >= @TimeKey
							--	AND DimParameterName = 'DimGender'
							--	AND A.gender  = DP.ParameterAlt_Key

				

			END






			ELSE IF @MenuId = 610
			BEGIN
			
				SELECT 'GridData' TableName , A.BaseColumn--, Format(A.ApprovalDate,'dd-MM-yyyy') ApprovalDate
						,A.ClubName,-- Format(A.LaunchDate,'dd-MM-yyyy') LaunchDate, 
						Loc.LocationName AS LocationAlt_key
						,DISTRICT AS District
						,SUB_DISTRICT AS Taluka
						,A.NABARD_Code
						
				 FROM #TmpGridSelect	A
				LEFT JOIN DimLocation LOC	ON  LOC.EffectiveFromTimeKey <= @TimeKey
											AND LOC.EffectiveToTimeKey  >= @TimeKey
										  	AND A.LocationAlt_key = LOC.LocationAlt_Key

			END

				ELSE IF @MenuId = 901
			BEGIN
			
				SELECT 'GridData' TableName , A.BaseColumn--, Format(A.ApprovalDate,'dd-MM-yyyy') ApprovalDate
						,A.ReportId
						,A.ReportName
						,A.OutputFileName
						,P.ParameterName reporttype
						,CASE WHEN ISNULL(C.ClientId,'')='' THEN 0 ELSE C.ClientId END AS MasterTagData  
				 FROM #TmpGridSelect	A
				INNER  JOIN DimParameter P
								ON P.EffectiveFromTimeKey <=@TimeKey AND P.EffectiveToTimeKey >= @TimeKey
								AND DimParameterName = 'Dimreporttype'
								AND A.reporttype  = P.ParameterAlt_Key
				LEFT JOIN DimXBRL_MasterTagData C
				ON C.ReportId=A.ReportId

			END
					ELSE IF @MenuId = 903
			BEGIN
			
				SELECT 'GridData' TableName , A.BaseColumn--, Format(A.ApprovalDate,'dd-MM-yyyy') ApprovalDate
						,A.TagId
						,A.TagName
						,A.TagLabel
						,P.ContextPrefix  ContextRefId
						,A.DisplayFlag
						,A.DisplaySubFlag
						,A.Value
						,A.DataSourcePointName
						,A.SourceReferenceName
						,A.Validation
						,A.TagSequence
						,A.Currency
						,A.MonetaryValue
				 FROM #TmpGridSelect	A
				LEFT  JOIN xbrl.DimXBRL_Context P
								ON P.EffectiveFromTimeKey <=@TimeKey AND P.EffectiveToTimeKey >= @TimeKey
								AND CAST(P.ReportEntityId AS VARCHAR(10))=@ParentColumnValue
								AND A.ContextRefId  = P.ContextId
				

			END

			ELSE IF @MenuId = 611
			BEGIN
				
				
				SELECT 'GridData' TableName , A.BaseColumn, A.CCR_FDR_No,IM.ParameterName InstrumentTypeAlt_Key
				
						,A.InttRate, A.PrincipalAmt, A.SponsBankBranch+' - '+DM.BranchName as SponsBankBranch
						,CASE WHEN ISNULL(ClosureDate,'')='' THEN 'Pending' ELSE 'Closed' END  AS Status
						, CONVERT(VARCHAR(10),A.ClosureDate, 103) ClosureDate
						 FROM #TmpGridSelect	 A
						LEFT JOIN DimParameter IM	ON  (IM.EffectiveFromTimeKey <= @TimeKey AND IM.EffectiveToTimeKey >= @TimeKey)
													AND DimParameterName='DimInstrumentType'
													AND A.InstrumentTypeAlt_Key = IM.ParameterAlt_Key

						INNER JOIN DimBranch_JKB DM ON    (DM.EffectiveFromTimeKey <= @TimeKey AND DM.EffectiveToTimeKey >= @TimeKey)
						AND A.SponsBankBranch = DM.BranchCode

			END

			ELSE IF @MenuId = 613
			BEGIN
				PRINT '613'
				SELECT 'GridData' TableName 
				, A.BaseColumn
				, AR.AreaName AreaAlt_Key
				, A.CounsellorName, A.FLC_Code
				, CONVERT(VARCHAR(10),A.JoiningDate, 103) JoiningDate
				, CONVERT(VARCHAR(10),A.OpeningDate,103) OpeningDate
				, P.ParameterName AS PremisesAlt_Key
				FROM #TmpGridSelect	A
					INNER JOIN DimParameter P
						ON P.EffectiveFromTimeKey <= @TimeKey
						AND P.EffectiveToTimeKey >= @TimeKey
						AND P.DimParameterName = 'DimPremises'
						AND p.ParameterAlt_Key = A.PremisesAlt_Key
					INNER JOIN DimArea AR
						ON AR.EffectiveFromTimeKey <= @TimeKey 
						AND AR.EffectiveToTimeKey >= @TimeKey
						AND AR.AreaAlt_Key = A.AreaAlt_Key
			END 

			ELSE IF @MenuId = 614
			BEGIN
					

					PRINT '614'

				IF @UserLocation ='HO'	
				BEGIN
					SELECT 'GridData' TableName 
							, A.BaseColumn
							, P.ParameterName  CampConductedByAlt_Key
							, A.FinLitEntityId
							--,CASE WHEN Br.BranchCode <> NULL THEN Br.BranchCode+' - '+ BR.BranchName 
							, Br.BranchCode+' - '+ BR.BranchName AS FLC_BranchCode
							, CONVERT(VARCHAR(10),A.CampDate, 103) CampDate
							, A.Remarks
							, A.UserLocation
							, A.UserLocationCode
					FROM #TmpGridSelect	A
					INNER JOIN DimParameter  P
							ON  P.EffectiveFromTimeKey <= @TimeKey
							AND P.EffectiveToTimeKey >= @TimeKey
							AND P.DimParameterName = 'DimCampConductBy'
							AND P.ParameterAlt_Key = A.CampConductedByAlt_Key
					LEFT JOIN #BRANCH BR
							ON BR.BranchCode = A.FLC_BranchCode
				END	
				ELSE 
				BEGIN

					SELECT 'GridData' TableName 
							, A.BaseColumn
							, P.ParameterName  CampConductedByAlt_Key
							, A.FinLitEntityId
							--,CASE WHEN Br.BranchCode <> NULL THEN Br.BranchCode+' - '+ BR.BranchName 
							--	WHEN A.FinLitEntityId <> NULL THEN A.FinLitEntityId END AS FLC_BranchCode
							, Br.BranchCode+' - '+ BR.BranchName AS FLC_BranchCode
							, CONVERT(VARCHAR(10),A.CampDate, 103) CampDate
							, A.Remarks
							, A.UserLocation
							, A.UserLocationCode
					FROM #TmpGridSelect	A
					INNER JOIN DimParameter  P
							ON  P.EffectiveFromTimeKey <= @TimeKey
							AND P.EffectiveToTimeKey >= @TimeKey
							AND P.DimParameterName = 'DimCampConductBy'
							AND P.ParameterAlt_Key = A.CampConductedByAlt_Key
					INNER JOIN #BRANCH BR
							ON BR.BranchCode = A.FLC_BranchCode

					UNION   
					SELECT 'GridData' TableName 
					, A.BaseColumn
							, P.ParameterName  CampConductedByAlt_Key
							, A.FinLitEntityId
							--,CASE WHEN Br.BranchCode <> NULL THEN Br.BranchCode+' - '+ BR.BranchName 
							--	WHEN A.FinLitEntityId <> NULL THEN A.FinLitEntityId END AS FLC_BranchCode
							, NULL FLC_BranchCode
							, CONVERT(VARCHAR(10),A.CampDate, 103) CampDate
							, A.Remarks
							, A.UserLocation
							, A.UserLocationCode
					FROM #TmpGridSelect A
					INNER JOIN DimParameter  P
							ON  P.EffectiveFromTimeKey <= @TimeKey
							AND P.EffectiveToTimeKey >= @TimeKey
							AND P.DimParameterName = 'DimCampConductBy'
							AND P.ParameterAlt_Key = A.CampConductedByAlt_Key
					INNER JOIN #BRANCHCODE BR
						ON ISNULL(A.FinLitEntityId,'')<>''
						AND A.UserLocation = BR.UserLocation
						AND A.UserLocationCode = BR.UserLocationCode

					
				END
			END

			ELSE IF @MenuId = 1151
		  BEGIN
					set @SearchCondition = REPLACE(@SearchCondition,'and', ',')
			
					DROP TABLE IF EXISTS #value
					select LEFT(VALUE, CHARINDEX('=',value) -1) ColumnName , RTRIM( LTRIM(REPLACE(SUBSTRING(value, CHARINDEX('=',value), LEN(value)) ,'=','')))ColumnData
					INTO #value
					from string_split(@SearchCondition,',')
					
					
					
					DECLARE 
							 @Location				CHAR(2)		=NULL
							,@LocationCode			VARCHAR(10) =NULL
							,@MasterNameAlt_Key		INT			=NULL
							,@MasterAlt_Key			INT			=0
							,@FromDate				vARCHAR(10)
							,@toDate				VARCHAR(10)
							,@ShowThresholdViolation	CHAR(1) ='N'
							
					

					SELECT @Location = REPLACE(ColumnData,'''','') FROM #value
					WHERE ColumnName = 'Location ' 
					
					SELECT @LocationCode = REPLACE(ColumnData,'''','') FROM #value
					WHERE ColumnName = ' LocationCode ' 
					
					SELECT @MasterNameAlt_Key = REPLACE(ColumnData,'''','') FROM #value
					WHERE ColumnName = ' ThresholdName '
					
					SELECT @FromDate = REPLACE(ColumnData,'''','')  FROM #value
					WHERE ColumnName = ' FromDt '
					
					SELECT @ToDate = REPLACE(ColumnData,'''','')  FROM #value
					WHERE ColumnName = ' ToDt '

					SELECT @ShowThresholdViolation = REPLACE(ColumnData,'''','')  FROM #value
					WHERE ColumnName = ' ShowThresholdViolation '


					--SELECT @Location Location, @LocationCode LocationCode
					--		, @MasterNameAlt_Key MasterNameAlt_Key
					--		, @FromDate FromDate, @ToDate ToDate
					--		, @ShowThresholdViolation ShowThresholdViolation
			
				
					EXEC [ALERT].[Treshold_BasicDataComparison_Select] 
						@Location				 = @Location
						, @LocationCode			 = @LocationCode
						, @MasterNameAlt_Key	 = @MasterNameAlt_Key
						, @MasterAlt_Key		 = @MasterAlt_Key
						, @FromDate				 = @FromDate
						, @ToDate				 = @ToDate
						,@ShowThresholdViolation = @ShowThresholdViolation
		  END

			ELSE IF @MenuId = 615
			BEGIN
				PRINT 'MenuID'+CAST(@MenuId AS VARCHAR(3))
				PRINT 'usr'+@UserLocation
				IF @UserLocation ='HO'
				BEGIN
					SELECT 'GridData' TableName , * FROM #TmpGridSelect	
				END
				ELSE 
				BEGIN
					SELECT 'GridData' TableName
						,A.BaseColumn, A.ClerkTotal,	A.OfficeCode, A.OfficerTotal, A.SubStaffTotal,
						A.UserLocationCode  
						FROM #BRANCHCODE B
						INNER JOIN  #TmpGridSelect A
							ON A.OfficeCode = B.UserLocationCode

						
					--DROP TABLE IF EXISTS #BrWiseEmployeeData
					--SELECT A.*, ISNULL(M.ModifiedBy,M.CreatedBy) CrModby 
					--INTO #BrWiseEmployeeData
					--FROM 
					--(
					--	SELECT 'GridData' TableName
					--	,A.BaseColumn, A.ClerkTotal,	A.OfficeCode, A.OfficerTotal, A.SubStaffTotal,
					--	A.UserLocationCode  
					--	FROM #BRANCHCODE B
					--	INNER JOIN  #TmpGridSelect A
					--		ON A.OfficeCode = B.UserLocationCode
					--)A

					--INNER JOIN BrWiseEmployeeData M
					--	ON M.EffectiveFromTimeKey <= @TimeKey
					--	AND M.EffectiveToTimeKey >= @TimeKey
					--	AND A.BaseColumn = M.EmpDataEntityID

					
					--SELECT	 EMP.TableName	
					--		,EMP.BaseColumn	
					--		,EMP.ClerkTotal	
					--		,EMP.OfficeCode	
					--		,EMP.OfficerTotal	
					--		,EMP.SubStaffTotal	
					--		,EMP.UserLocationCode 
					--FROM #BrWiseEmployeeData EMP
					--INNER JOIN DimUserInfo USR
					--	ON USR.EffectiveFromTimeKey <= @TimeKey
					--	AND USR.EffectiveToTimeKey >= @TimeKey
					--	AND USR.UserLoginID = EMP.CrModby
					--	AND ISNULL(USR.UserLocationCode,'HO')<>'HO'

					
				END
			END


			ELSE IF @MenuId = 616
			BEGIN
				
				SELECT 'GridData' TableName , A.BaseColumn
				--, FORMAT(A.BirthDate, 'dd/MM/yyyy') BirthDate 
				, A.Name
				--, A.Qualification,A.MobileNo--,A.PresentInstututionAlt_Key
				--, P.ParameterName PresentInstututionAlt_Key
				FROM #TmpGridSelect	A
				--LEFT JOIN DimParameter P
				--	ON (P.EffectiveFromTimeKey <= @TimeKey AND P.EffectiveToTimeKey >= @TimeKey) 
				--	AND P.DimParameterName = 'DimBoardMemberInstitution'
				--	AND P.ParameterAlt_Key = A.PresentInstututionAlt_Key
			END

			ELSE IF @MenuId = 617
			BEGIN
				SELECT 'GridData' TableName , BaseColumn
				, CONVERT(VARCHAR(10),MeetingDate,103) MeetingDate 
				,P.ParameterName  MeetingRelatedAlt_Key 
				--,MeetingPurpose
				,MeetingPlace
				,MeetingNo
				FROM #TmpGridSelect A	
				LEFT OUTER JOIN  Dimparameter P
					ON (P.EffectiveFromTimeKey <= @TimeKey AND P.EffectiveToTimeKey >= @TimeKey)
					AND P.DimParameterName = 'DimMeeting'
					AND P.ParameterAlt_Key = A.MeetingRelatedAlt_Key
					where A.MeetingRelatedAlt_Key = 1
			END

			ELSE IF @MenuId = 619
			BEGIN
				SELECT 'GridData' TableName , BaseColumn
				, CONVERT(VARCHAR(10),MeetingDate,103) MeetingDate 
				,P.ParameterName  MeetingRelatedAlt_Key 
				,MeetingNo
				,MeetingPlace

				FROM #TmpGridSelect A	
				LEFT OUTER JOIN  Dimparameter P
					ON (P.EffectiveFromTimeKey <= @TimeKey AND P.EffectiveToTimeKey >= @TimeKey)
					AND P.DimParameterName = 'DimMeeting'
					AND P.ParameterAlt_Key = A.MeetingRelatedAlt_Key
					where A.MeetingRelatedAlt_Key = 2
			END

			ELSE IF @MenuId = 620
			BEGIN
				SELECT 'GridData' TableName , BaseColumn
				, CONVERT(VARCHAR(10),MeetingDate,103) MeetingDate 
				,P.ParameterName  MeetingRelatedAlt_Key 
				,MeetingNo
				,MeetingPlace

				FROM #TmpGridSelect A	
				LEFT OUTER JOIN  Dimparameter P
					ON (P.EffectiveFromTimeKey <= @TimeKey AND P.EffectiveToTimeKey >= @TimeKey)
					AND P.DimParameterName = 'DimMeeting'
					AND P.ParameterAlt_Key = A.MeetingRelatedAlt_Key
					where  A.MeetingRelatedAlt_Key = 3
			END


			ELSE IF @MenuId = 621
			BEGIN
			select @TimeKey = (select Timekey from sysdaymatrix where cast(date as date) = cast (GetDate() as date))
				IF @Mode = 16
				BEGIN
				--SELECT 'GridData' TableName , BaseColumn, CONVERT(VARCHAR(10),OccurenceDate,103) OccurenceDate,	
				--		OfficeInvolvedCode,	OfficeLocation, OfficeLocationCode, FMS_Number
				--		FROM #TmpGridSelect	
					IF @UserLocationCode = 'HO'
					BEGIN
					print 'reema'

					 IF OBJECT_ID('TEMPDB..#ScreenPending') IS NOT NULL
						DROP TABLE #ScreenPending
					SELECT * INTO #ScreenPending 
					from(
						SELECT 'GridData' TableName , BaseColumn, CONVERT(VARCHAR(10),OccurenceDate,103) OccurenceDate,	
						OfficeInvolvedCode,	OfficeLocation, OfficeLocationCode, FMS_Number
						,'FraudDetail' ScreenPending
						FROM #TmpGridSelect	T
						
						--UNION 
						  -----Authorizaton in Pending in FraudRecoveryDetail

						--SELECT 'GridData' TableName
						--,FraudEntityId BaseColumn
						--,NULL OccurenceDate
						--,NULL OfficeInvolvedCode,	NULL OfficeLocation, NULL OfficeLocationCode,NULL FMS_Number
						--FROM FraudDetail 
						--	where (EffectiveFromTimeKey <= @Timekey AND EffectiveToTimeKey >= @Timekey)
						--	AND ISNULL(AuthorisationStatus,'A') IN ('NP','MP','DP','RM')
						--print 'reema'
						UNION
						
						SELECT DISTINCT 'GridData' TableName , A.FraudEntityId BaseColumn
						--,FD.OccurenceDate OccurenceDate
						,CONVERT(VARCHAR(10),FD.OccurenceDate,103) OccurenceDate	
						,FD.OfficeInvolvedCode OfficeInvolvedCode
						,FD.OfficeLocation
						,FD.OfficeLocationCode
						,FD.FMS_Number
						,'FraudInvolvementDetail' ScreenPending
							FROM FraudInvolvementDetail_Mod A	
									inner join frauddetail FD
							on FD.FraudEntityId = A.fraudentityid						
							WHERE (A.EffectiveFromTimeKey <= @Timekey AND A.EffectiveToTimeKey >= @Timekey)
							AND(FD.EffectiveFromTimeKey <= @Timekey AND FD.EffectiveToTimeKey >= @Timekey)
							 AND ISNULL(A.AuthorisationStatus,'A') IN ('NP','MP','DP','RM')
							  AND ISNULL(FD.AuthorisationStatus,'A')='A'
							-- GROUP BY A.FraudEntityId
							

						UNION 
							SELECT DISTINCT 'GridData' TableName , B.FraudEntityId BaseColumn
							,CONVERT(VARCHAR(10),FD.OccurenceDate,103) OccurenceDate
							,FD.OfficeInvolvedCode
							,FD.OfficeLocation
							,FD.OfficeLocationCode
							,FD.FMS_Number
							,'Associatedtl' ScreenPending
							FROM Associatedtl_mod A
								INNER JOIN FraudInvolvementDetail B
									ON A.FraudInnvolveEntityID=B.FraudInnvolveEntityID
									inner join frauddetail FD
							on FD.FraudEntityId = B.fraudentityid
							WHERE (A.EffectiveFromTimeKey <= @Timekey AND A.EffectiveToTimeKey >= @Timekey)
							AND(B.EffectiveFromTimeKey <= @Timekey AND B.EffectiveToTimeKey >= @Timekey)
							AND(FD.EffectiveFromTimeKey <= @Timekey AND FD.EffectiveToTimeKey >= @Timekey)
							 AND ISNULL(A.AuthorisationStatus,'A') IN ('NP','MP','DP','RM')
							  AND ISNULL(B.AuthorisationStatus,'A')='A'
							   AND ISNULL(FD.AuthorisationStatus,'A')='A'
							--GROUP BY B.FraudEntityId

							UNION 
							SELECT DISTINCT 'GridData' TableName , B.FraudEntityId BaseColumn
							,CONVERT(VARCHAR(10),FD.OccurenceDate,103) OccurenceDate
							,FD.OfficeInvolvedCode
							,FD.OfficeLocation
							,FD.OfficeLocationCode
							,FD.FMS_Number
							,'Associatedtl' ScreenPending
							FROM FraudSecurityValueDetail_MOD A
								INNER JOIN FraudInvolvementDetail B
									ON A.FraudInnvolveEntityID=B.FraudInnvolveEntityID
									inner join frauddetail FD
							on FD.FraudEntityId = B.fraudentityid
							WHERE (A.EffectiveFromTimeKey <= @Timekey AND A.EffectiveToTimeKey >= @Timekey)
							AND(B.EffectiveFromTimeKey <= @Timekey AND B.EffectiveToTimeKey >= @Timekey)
							AND(FD.EffectiveFromTimeKey <= @Timekey AND FD.EffectiveToTimeKey >= @Timekey)
							 AND ISNULL(A.AuthorisationStatus,'A') IN ('NP','MP','DP','RM')
							  AND ISNULL(B.AuthorisationStatus,'A')='A'
							--GROUP BY B.FraudEntityId
						
							UNION 
							SELECT DISTINCT  'GridData' TableName , B.FraudEntityId BaseColumn
							,CONVERT(VARCHAR(10),FD.OccurenceDate,103) OccurenceDate
							,FD.OfficeInvolvedCode
							,FD.OfficeLocation
							,FD.OfficeLocationCode
							,FD.FMS_Number
							,'Associatedtl' ScreenPending
							FROM FraudDirectorsAssociateDt_MOD FDAD	
													
								inner join Associatedtl A
									on (FDAD.EffectiveFromTimeKey<=@TimeKey and FDAD.EffectiveToTimeKey>=@TimeKey)
									and FDAD.AssociateEntityId=a.AssociateEntityId
								INNER JOIN FraudInvolvementDetail B
									ON A.FraudInnvolveEntityID=B.FraudInnvolveEntityID
									inner join frauddetail FD
							on FD.FraudEntityId = B.fraudentityid
							WHERE (A.EffectiveFromTimeKey <= @Timekey AND A.EffectiveToTimeKey >= @Timekey)
							AND(B.EffectiveFromTimeKey <= @Timekey AND B.EffectiveToTimeKey >= @Timekey)
							AND(FD.EffectiveFromTimeKey <= @Timekey AND FD.EffectiveToTimeKey >= @Timekey)
							 AND ISNULL(FDAD.AuthorisationStatus,'A') IN ('NP','MP','DP','RM')
							 AND ISNULL(A.AuthorisationStatus,'A')='A'
							 AND ISNULL(B.AuthorisationStatus,'A')='A'
							 AND ISNULL(FD.AuthorisationStatus,'A')='A'
							--GROUP BY B.FraudEntityId

							UNION
						SELECT DISTINCT 'GridData' TableName , FD.FraudEntityId BaseColumn
						,CONVERT(VARCHAR(10),FD.OccurenceDate,103) OccurenceDate
						,FD.OfficeInvolvedCode
						,FD.OfficeLocation
						,FD.OfficeLocationCode
						,FD.FMS_Number
						,'FraudRecoveryDetail' ScreenPending
							FROM FraudRecoveryDetail_Mod A	
							inner join Frauddetail FD
							on FD.FraudEntityId = A.fraudentityid						
							WHERE (A.EffectiveFromTimeKey <= @Timekey AND A.EffectiveToTimeKey >= @Timekey)
							AND(FD.EffectiveFromTimeKey <= @Timekey AND FD.EffectiveToTimeKey >= @Timekey)
							 AND ISNULL(A.AuthorisationStatus,'A') IN ('NP','MP','DP','RM')
							  AND ISNULL(FD.AuthorisationStatus,'A')='A'
							-- GROUP BY A.FraudEntityId
							UNION
								SELECT DISTINCT 'GridData' TableName , FD.FraudEntityId BaseColumn
						,CONVERT(VARCHAR(10),FD.OccurenceDate,103) OccurenceDate
						,FD.OfficeInvolvedCode
						,FD.OfficeLocation
						,FD.OfficeLocationCode
						,FD.FMS_Number
						,'FraudStaffSideAction' ScreenPending
							FROM FraudStaffSideActionDetail_mod A	
							inner join Frauddetail FD
							on FD.FraudEntityId = A.fraudentityid						
							WHERE (A.EffectiveFromTimeKey <= @Timekey AND A.EffectiveToTimeKey >= @Timekey)
							AND(FD.EffectiveFromTimeKey <= @Timekey AND FD.EffectiveToTimeKey >= @Timekey)
							 AND ISNULL(A.AuthorisationStatus,'A') IN ('NP','MP','DP','RM')
							  AND ISNULL(FD.AuthorisationStatus,'A')='A'

							 UNION
						SELECT DISTINCT 'GridData' TableName , FD.FraudEntityId BaseColumn
						,CONVERT(VARCHAR(10),FD.OccurenceDate,103) OccurenceDate
						,FD.OfficeInvolvedCode
						,FD.OfficeLocation
						,FD.OfficeLocationCode
						,FD.FMS_Number
						,'FraudRecoveryDetail' ScreenPending
							FROM FraudDirectorsDtl_MOD A	
							inner join Frauddetail FD
							on FD.FraudEntityId = A.fraudentityid						
							WHERE (A.EffectiveFromTimeKey <= @Timekey AND A.EffectiveToTimeKey >= @Timekey)
							AND(FD.EffectiveFromTimeKey <= @Timekey AND FD.EffectiveToTimeKey >= @Timekey)
							 AND ISNULL(A.AuthorisationStatus,'A') IN ('NP','MP','DP','RM')
							  AND ISNULL(FD.AuthorisationStatus,'A')='A'
							-- GROUP BY FD.FraudEntityId
						
						)a


						
							SELECT TableName,BaseColumn	,OccurenceDate	,OfficeInvolvedCode	,OfficeLocation	,OfficeLocationCode	,FMS_Number
							,STUFF((SELECT  ','+ m1.ScreenPending 
							FROM #ScreenPending m1
							--group by BaseColumn
							WHERE M1.BASECOLUMN=M2.BASECOLUMN
							FOR XML PATH('')),1,1,'')ScreenPending
					FROM #ScreenPending M2
					GROUP BY TableName,BaseColumn	,OccurenceDate	,OfficeInvolvedCode	,OfficeLocation	,OfficeLocationCode	,FMS_Number

						
					
						--  UNION
						  
						--SELECT 'GridData' TableName
						--,A.FraudEntityId BaseColumn
						--,CONVERT(VARCHAR(10),OccurenceDate,103) OccurenceDate
						--,OfficeInvolvedCode,	OfficeLocation, OfficeLocationCode,FMS_Number
						--FROM FraudDetail A
						--INNER JOIN 
						--(
						--	SELECT FraudEntityId ,	FraudDirectorEntityID
						--	FROM FraudDirectorsDtl_MOD
						--	WHERE EffectiveFromTimeKey <= @Timekey AND EffectiveToTimeKey >= @Timekey
						--	 AND ISNULL(AuthorisationStatus,'A') IN ('NP','MP','DP','RM')
						--	 GROUP BY FraudEntityId,FraudDirectorEntityID
						--)B
						--	ON A.EffectiveFromTimeKey <= @Timekey  AND A.EffectiveToTimeKey >= @Timekey
						--	AND A.FraudEntityId = B.FraudEntityId

						--  UNION 
						--  -----Authorizaton in Pending in FraudRecoveryDetail

						--SELECT 'GridData' TableName
						--,A.FraudEntityId BaseColumn
						--,CONVERT(VARCHAR(10),OccurenceDate,103) OccurenceDate
						--,OfficeInvolvedCode,	OfficeLocation, OfficeLocationCode, FMS_Number
						--FROM FraudDetail A
						--INNER JOIN 
						--(
						--	SELECT FraudEntityId ,	FraudInnvolveEntityID
						--	FROM FraudInvolvementDetail_Mod
						--	WHERE EffectiveFromTimeKey <= @Timekey AND EffectiveToTimeKey >= @Timekey
						--	 AND ISNULL(AuthorisationStatus,'A') IN ('NP','MP','DP','RM')
						--	 GROUP BY FraudEntityId,	FraudInnvolveEntityID
							
						--	 union 
						--	 SELECT FraudInnvolveEntityID ,	AssociateEntityId
						--	FROM Associatedtl_mod
						--	WHERE EffectiveFromTimeKey <= @Timekey AND EffectiveToTimeKey >= @Timekey
						--	 AND ISNULL(AuthorisationStatus,'A') IN ('NP','MP','DP','RM')
						--	 and FraudInnvolveEntityID = FraudInnvolveEntityID
						--	 GROUP BY FraudInnvolveEntityID,	AssociateEntityId


						--	 SELECT AssociateEntityId ,	FraudDirectorAssociateEntityID
						--	FROM FraudDirectorsAssociateDt_MOD
						--	WHERE EffectiveFromTimeKey <= @Timekey AND EffectiveToTimeKey >= @Timekey
						--	 AND ISNULL(AuthorisationStatus,'A') IN ('NP','MP','DP','RM')
						--	 and AssociateEntityId =AssociateEntityId
						--)B
						--	ON A.EffectiveFromTimeKey <= @Timekey  AND A.EffectiveToTimeKey >= @Timekey
						--	AND A.FraudEntityId = B.FraudEntityId



					END
					ELSE 
					BEGIN
						SELECT 'GridData' TableName , BaseColumn, CONVERT(VARCHAR(10),OccurenceDate,103) OccurenceDate,	
						OfficeInvolvedCode,	OfficeLocation, OfficeLocationCode, FMS_Number
						FROM #TmpGridSelect	 A
						INNER JOIN #BRANCHCODE BR
							ON BR.UserLocationCode = A.OfficeLocationCode
							AND BR.UserLocation= A.OfficeLocation

						
						UNION 
						  -----Authorizaton in Pending in FraudRecoveryDetail

						SELECT 'GridData' TableName
						,A.FraudEntityId BaseColumn
						,CONVERT(VARCHAR(10),OccurenceDate,103) OccurenceDate
						,OfficeInvolvedCode,	OfficeLocation, OfficeLocationCode, FMS_Number
						FROM FraudDetail A
						INNER JOIN 
						(
							SELECT  FraudEntityId ,	RecoveryEntityId
							FROM FraudRecoveryDetail_Mod
							WHERE EffectiveFromTimeKey <= @Timekey AND EffectiveToTimeKey >= @Timekey
							 AND ISNULL(AuthorisationStatus,'A') IN ('NP','MP','DP','RM')
							 GROUP BY FraudEntityId,	RecoveryEntityId
						)B --on B.Entitykey = FraudRecoveryDetail_Mod.EntityKey
							on A.EffectiveFromTimeKey <= @Timekey  AND A.EffectiveToTimeKey >= @Timekey
							AND A.FraudEntityId = B.FraudEntityId
						INNER JOIN #BRANCHCODE BR
							ON BR.UserLocationCode = A.OfficeLocationCode
							AND BR.UserLocation= A.OfficeLocation

						  -----Authorizaton in Pending in FraudDirectorDtl
						  UNION
						  	SELECT 'GridData' TableName
						,A.FraudEntityId BaseColumn
						,CONVERT(VARCHAR(10),OccurenceDate,103) OccurenceDate
						,OfficeInvolvedCode,	OfficeLocation, OfficeLocationCode, FMS_Number
						FROM FraudDetail A
						INNER JOIN 
						(
							SELECT  FraudEntityId ,	FraudDirectorEntityID
							FROM FraudDirectorsDtl_mod
							WHERE EffectiveFromTimeKey <= @Timekey AND EffectiveToTimeKey >= @Timekey
							 AND ISNULL(AuthorisationStatus,'A') IN ('NP','MP','DP','RM')
							 GROUP BY FraudEntityId,	FraudDirectorEntityID
						)B --on B.Entitykey = FraudRecoveryDetail_Mod.EntityKey
							on A.EffectiveFromTimeKey <= @Timekey  AND A.EffectiveToTimeKey >= @Timekey
							AND A.FraudEntityId = B.FraudEntityId
						INNER JOIN #BRANCHCODE BR
							ON BR.UserLocationCode = A.OfficeLocationCode
							AND BR.UserLocation= A.OfficeLocation

						  UNION 
						  -----Authorizaton in Pending in FraudRecoveryDetail

						SELECT 'GridData' TableName
						,A.FraudEntityId BaseColumn
						,CONVERT(VARCHAR(10),OccurenceDate,103) OccurenceDate
						,OfficeInvolvedCode,	OfficeLocation, OfficeLocationCode, FMS_Number
						FROM FraudDetail A
						INNER JOIN 
						(
							SELECT FraudEntityId ,	FraudInnvolveEntityID
							FROM FraudInvolvementDetail_Mod
							WHERE EffectiveFromTimeKey <= @Timekey AND EffectiveToTimeKey >= @Timekey
							 AND ISNULL(AuthorisationStatus,'A') IN ('NP','MP','DP','RM')
							 GROUP BY FraudEntityId,	FraudInnvolveEntityID
						 )B-- on B.Entitykey = FraudInvolvementDetail_Mod.EntityKey
							on A.EffectiveFromTimeKey <= @Timekey  AND A.EffectiveToTimeKey >= @Timekey
							AND A.FraudEntityId = B.FraudEntityId
						INNER JOIN #BRANCHCODE BR
							ON BR.UserLocationCode = A.OfficeLocationCode
							AND BR.UserLocation= A.OfficeLocation
						
							
					END
				END
				ELSE 
				BEGIN
					IF @UserLocationCode = 'HO'
					BEGIN
						SELECT 'GridData' TableName , BaseColumn, CONVERT(VARCHAR(10),OccurenceDate,103) OccurenceDate,	
						OfficeInvolvedCode,	OfficeLocation, OfficeLocationCode, FMS_Number
						FROM #TmpGridSelect	



					END
					ELSE 
					BEGIN
						SELECT 'GridData' TableName , BaseColumn, CONVERT(VARCHAR(10),OccurenceDate,103) OccurenceDate,	
						OfficeInvolvedCode,	OfficeLocation, OfficeLocationCode, FMS_Number
						FROM #TmpGridSelect	 A
						INNER JOIN #BRANCHCODE BR
							ON BR.UserLocationCode = A.OfficeLocationCode
							AND BR.UserLocation= A.OfficeLocation

							
					END
				END

			END

			ELSE IF @MenuId = 622
			BEGIN
				PRINT '622'
				--SELECT 'GridData' TableName ,BaseColumn, CONVERT(VARCHAR(10),RecoveryDate,103) RecoveryDate, ParameterName AS	RecoverySourceAlt_Key
				--,	RecoveyAmount 
				--FROM #TmpGridSelect	 A
				--LEFT OUTER JOIN  Dimparameter P
				--	ON (P.EffectiveFromTimeKey <= @TimeKey AND P.EffectiveToTimeKey >= @TimeKey)
				--	AND P.DimParameterName = 'DimRecoverySrc'
				--	AND P.ParameterAlt_Key = A.RecoverySourceAlt_Key

				select @TimeKey = (select Timekey from sysdaymatrix where cast(date as date) = cast (GetDate() as date))

	IF @Mode=16
	BEGIN
	 Select

	'GridData' TableName , P.RecoveryEntityId as BaseColumn,CONVERT(VARCHAR(10),P.RecoveryDate,103) RecoveryDate, A.ParameterName AS	RecoverySourceAlt_Key,P.RecoveyAmount
				--FROM 
	 ,'N' as IsMainTable
	 ,P.CreatedBy
	 --,'DimCyberSecStatus' as TableName
	 from FraudRecoveryDetail_Mod P
	 inner join 
	 (
	  Select max(EntityKey) as entitykey,RecoveryEntityId from FraudRecoveryDetail_Mod
	  where (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) --AND ISNULL(ModifiedBy,CreatedBy) <> @UserLoginId
	 AND ISNULL(AuthorisationStatus,'A') IN ('NP','MP','DP')
	 --AND CyberSecStatusEntityId=@CyberSecStatusEntityId
	 group by RecoveryEntityId
	 ) K ON K.entitykey=p.EntityKey
	 LEFT OUTER JOIN  Dimparameter A
					ON (A.EffectiveFromTimeKey <= @TimeKey AND A.EffectiveToTimeKey >= @TimeKey)
					AND A.DimParameterName = 'DimRecoverySrc'
					AND A.ParameterAlt_Key = P.RecoverySourceAlt_Key
	 where (P.EffectiveFromTimeKey<=@TimeKey AND P.EffectiveToTimeKey>=@TimeKey) --AND ISNULL(ModifiedBy,CreatedBy) <> @UserLoginId
	 AND ISNULL(P.AuthorisationStatus,'A') IN ('NP','MP','DP') and P.FraudEntityId=@ParentColumnValue
	-- order by FraudInnvolveEntityID
	END
	ELSE 
	BEGIN
	   Select

	 'GridData' TableName , p.RecoveryEntityId as BaseColumn,CONVERT(VARCHAR(10),P.RecoveryDate,103) RecoveryDate, A.ParameterName AS	RecoverySourceAlt_Key,P.RecoveyAmount
				--FROM 
	 ,'N' as IsMainTable
	 ,P.CreatedBy
	 --,'DimCyberSecStatus' as TableName
	
	 --,'N' as IsMainTable
	-- ,P.CreatedBy
	 from FraudRecoveryDetail_Mod p
	 inner join 
	 (
	  Select max(c.EntityKey) as entitykey,c.RecoveryEntityId from FraudRecoveryDetail_Mod c
	  where (c.EffectiveFromTimeKey<=@TimeKey AND c.EffectiveToTimeKey>=@TimeKey) --AND ISNULL(ModifiedBy,CreatedBy) = @UserLoginId
	 AND ISNULL(c.AuthorisationStatus,'A') IN ('NP','MP','DP')
	 --AND CyberSecStatusEntityId=@CyberSecStatusEntityId
	 group by c.RecoveryEntityId
	 ) K ON K.entitykey=p.EntityKey
	 LEFT OUTER JOIN  Dimparameter A
					ON (A.EffectiveFromTimeKey <= @TimeKey AND A.EffectiveToTimeKey >= @TimeKey)
					AND A.DimParameterName = 'DimRecoverySrc'
					AND A.ParameterAlt_Key = P.RecoverySourceAlt_Key
	 where (P.EffectiveFromTimeKey<=@TimeKey AND p.EffectiveToTimeKey>=@TimeKey) --AND ISNULL(ModifiedBy,CreatedBy) = @UserLoginId
	 AND ISNULL(P.AuthorisationStatus,'A') IN ('NP','MP','DP') and P.FraudEntityId=@ParentColumnValue
	 UNION
	  Select

	  'GridData' TableName , A.RecoveryEntityId as BaseColumn,	CONVERT(VARCHAR(10),A.RecoveryDate,103) RecoveryDate, P.ParameterName AS	RecoverySourceAlt_Key,RecoveyAmount
				--FROM 
	 ,'Y' as IsMainTable
	 ,A.CreatedBy
	 --,'DimCyberSecStatus' as TableName
	 from FraudRecoveryDetail A
	 LEFT OUTER JOIN  Dimparameter P
					ON (P.EffectiveFromTimeKey <= @TimeKey AND P.EffectiveToTimeKey >= @TimeKey)
					AND P.DimParameterName = 'DimRecoverySrc'
					AND P.ParameterAlt_Key = A.RecoverySourceAlt_Key
	 where (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey) 
	 AND ISNULL(A.AuthorisationStatus,'A') ='A' and A.FraudEntityId=@ParentColumnValue
	-- order by A.FraudInnvolveEntityID
	END

			END

			--ELSE IF @MenuId = 623
			--BEGIN
			--	PRINT '623'
			--	--SELECT 'GridData' TableName , BaseColumn,	--AccountNo, 
			--	----ParameterName AS	InvolvePartyAlt_Key,
			--	--CustomerId CustomerId,DesignationAlt_Key
			--	----Customerid,
			--	--,InvolvePartyName
			--	--FROM #TmpGridSelect	 A
			--	--LEFT OUTER JOIN  Dimparameter P
			--	--	ON (P.EffectiveFromTimeKey <= @TimeKey AND P.EffectiveToTimeKey >= @TimeKey)
			--	--	AND P.DimParameterName = 'DimFraudInvParty'
			--	--	AND P.ParameterAlt_Key = A.InvolvePartyAlt_Key
			--	--WHERE P.ParameterAlt_Key =1
			--END
			ELSE IF @MenuId = 623
			BEGIN
				PRINT '623'
				--select * from #TmpGridSelect
				select @TimeKey = (select Timekey from sysdaymatrix where cast(date as date) = cast (GetDate() as date))
				
	IF @Mode=16
	BEGIN
	 Select

	'GridData' TableName , P.FraudStaffSideActionEntityID as BaseColumn,FI.CustomerId
	 --P.DesignationAlt_Key AS	DesignationAlt_Key
	 ,FI.FraudInnvolveEntityID,
	DD.DesignationName as DesignationName,
	FI.InvolvePartyName
	,FI.EmpCode
				--FROM 
	, 'N' as IsMainTable
	 ,P.CreatedBy
	 --,'DimCyberSecStatus' as TableName
	 from FraudStaffSideActionDetail_mod P
	 inner join 
	 (
	  Select max(EntityKey) as entitykey from FraudStaffSideActionDetail_mod
	  where (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) --AND ISNULL(ModifiedBy,CreatedBy) <> @UserLoginId
	--AND 
	 AND ISNULL(AuthorisationStatus,'A') IN ('NP','MP','DP')
	 --AND CyberSecStatusEntityId=@CyberSecStatusEntityId
	 group by FraudInnvolveEntityID
	 ) K ON K.entitykey=P.EntityKey
	 
					 Inner join FraudInvolvementDetail FI
					on FI.FraudInnvolveEntityID = P.FraudInnvolveEntityID
					left outer join DImDesignation DD
					on DD.DesignationAlt_Key = FI.DesignationAlt_Key
	
					LEFT OUTER JOIN  Dimparameter DP
					ON (DP.EffectiveFromTimeKey <= @TimeKey AND DP.EffectiveToTimeKey >= @TimeKey)
					AND DP.DimParameterName = 'DimFraudInvParty'
					AND DP.ParameterAlt_Key = FI.InvolvePartyAlt_Key
				
	 where (P.EffectiveFromTimeKey<=@TimeKey AND P.EffectiveToTimeKey>=@TimeKey) --AND ISNULL(ModifiedBy,CreatedBy) <> @UserLoginId
	 AND ISNULL(P.AuthorisationStatus,'A') IN ('NP','MP','DP') and P.FraudEntityId=@ParentColumnValue and FI.InvolvePartyAlt_Key =1
	-- order by FraudInnvolveEntityID
	END
	ELSE 
	BEGIN
	 --  Select

	 --'GridData' TableName , p.FraudInnvolveEntityID as BaseColumn,	p.CustomerId,-- p.DesignationAlt_Key AS	DesignationAlt_Key,
	 --DD.DesignationName as DesignationAlt_Key,
	 --p.InvolvePartyName				
	 --,'N' as IsMainTable
	 --,P.CreatedBy
	 
	 --from FraudInvolvementDetail p
	 --inner join 
	 --(
	 -- Select max(c.EntityKey) as entitykey,c.FraudInnvolveEntityID from FraudInvolvementDetail c
	 -- where (c.EffectiveFromTimeKey<=@TimeKey AND c.EffectiveToTimeKey>=@TimeKey) --AND ISNULL(ModifiedBy,CreatedBy) = @UserLoginId
	 --AND ISNULL(c.AuthorisationStatus,'A') IN ('NP','MP','DP')
	 --group by c.FraudInnvolveEntityID
	 --) K ON K.entitykey=p.EntityKey
	 
		--			left outer join DImDesignation DD
		--			on DD.DesignationAlt_Key = P.DesignationAlt_Key
		--					LEFT OUTER JOIN  Dimparameter A
		--			ON (A.EffectiveFromTimeKey <= @TimeKey AND A.EffectiveToTimeKey >= @TimeKey)
		--			AND A.DimParameterName = 'DimFraudInvParty'
		--			AND A.ParameterAlt_Key = P.InvolvePartyAlt_Key
		--		and P.InvolvePartyAlt_Key =1

		--		left outer join FraudStaffSideActionDetail_mod FS
		--		FS.FraudentityId = P.FraudentityId
	 --where (P.EffectiveFromTimeKey<=@TimeKey AND p.EffectiveToTimeKey>=@TimeKey) --AND ISNULL(ModifiedBy,CreatedBy) = @UserLoginId
	 --AND ISNULL(P.AuthorisationStatus,'A') IN ('NP','MP','DP') and P.FraudEntityId=@ParentColumnValue and P.InvolvePartyAlt_Key =1

	 IF NOT EXISTs 
	 ( select * from FraudStaffSideActionDetail_mod where FraudEntityId= @ParentColumnValue)
	 BEGIN
	 print 'staff1'
	 select
	 'GridData' TableName , FS.FraudStaffSideActionEntityID as BaseColumn,FI.FraudInnvolveEntityID,	FI.CustomerId,
	 -- p.DesignationAlt_Key AS	DesignationAlt_Key,
	 FI.EmpCode,
	 DD.DesignationName as DesignationName,
	 FI.InvolvePartyName				
	 ,'N' as IsMainTable
	 ,FI.CreatedBy

	 from FraudInvolvementDetail FI
	
left outer join FraudStaffSideActionDetail_mod FS
on FI.FraudInnvolveEntityID = FS.FraudInnvolveEntityID
left outer join DImDesignation DD
					on DD.DesignationAlt_Key = FI.DesignationAlt_Key
							LEFT OUTER JOIN  Dimparameter A
					ON (A.EffectiveFromTimeKey <= @TimeKey AND A.EffectiveToTimeKey >= @TimeKey)
					AND A.DimParameterName = 'DimFraudInvParty'
					AND A.ParameterAlt_Key = FI.InvolvePartyAlt_Key
 where (FI.EffectiveFromTimeKey<=@TimeKey AND FI.EffectiveToTimeKey>=@TimeKey) --AND ISNULL(ModifiedBy,CreatedBy) = @UserLoginId
	 AND ISNULL(FI.AuthorisationStatus,'A') IN ('A')
	  and FI.FraudEntityId=@ParentColumnValue and FI.InvolvePartyAlt_Key =1

	  END
	   select
	 'GridData' TableName , FS.FraudStaffSideActionEntityID as BaseColumn,FI.FraudInnvolveEntityID,	FI.CustomerId,
	 -- p.DesignationAlt_Key AS	DesignationAlt_Key,
	 DD.DesignationName as DesignationName,
	 FI.InvolvePartyName	
	  ,FI.EmpCode			
	 ,'N' as IsMainTable
	 ,FI.CreatedBy

	 from FraudInvolvementDetail FI
	
left outer join FraudStaffSideActionDetail_mod FS
on FI.FraudInnvolveEntityID = FS.FraudInnvolveEntityID
left outer join DImDesignation DD
					on DD.DesignationAlt_Key = FI.DesignationAlt_Key
							LEFT OUTER JOIN  Dimparameter A
					ON (A.EffectiveFromTimeKey <= @TimeKey AND A.EffectiveToTimeKey >= @TimeKey)
					AND A.DimParameterName = 'DimFraudInvParty'
					AND A.ParameterAlt_Key = FI.InvolvePartyAlt_Key
 where (FI.EffectiveFromTimeKey<=@TimeKey AND FI.EffectiveToTimeKey>=@TimeKey) --AND ISNULL(ModifiedBy,CreatedBy) = @UserLoginId
	 AND ISNULL(FI.AuthorisationStatus,'A') IN ('A')
	  and FI.FraudEntityId=@ParentColumnValue and FI.InvolvePartyAlt_Key =1 and FS.FraudStaffSideActionEntityID is NULL
	 UNION
	 --print 'staff2'
	  Select

	  'GridData' TableName , A.FraudStaffSideActionEntityID as BaseColumn,FI.FraudInnvolveEntityID,FI.CustomerId,-- A.DesignationAlt_Key AS	DesignationAlt_Key,
	  DD.DesignationName as DesignationName,
	 FI.InvolvePartyName
	  ,FI.EmpCode
				--FROM 
	 ,'Y' as IsMainTable
	 ,A.CreatedBy
	
	 from FraudStaffSideActionDetail A
	 left outer join FraudInvolvementDetail FI
	on FI.FraudInnvolveEntityID = A.FraudInnvolveEntityID
	
		left outer join DImDesignation DD
					on DD.DesignationAlt_Key = FI.DesignationAlt_Key
			LEFT OUTER JOIN  Dimparameter P
					ON (P.EffectiveFromTimeKey <= @TimeKey AND P.EffectiveToTimeKey >= @TimeKey)
					AND P.DimParameterName = 'DimFraudInvParty'
					AND P.ParameterAlt_Key = FI.InvolvePartyAlt_Key
				and P.ParameterAlt_Key =1
	 where (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey) 
	 AND ISNULL(A.AuthorisationStatus,'A') ='A' and A.FraudEntityId=@ParentColumnValue and FI.InvolvePartyAlt_Key =1
	-- order by A.FraudInnvolveEntityID
	UNION
	--print 'staff3'
	 Select

	 'GridData' TableName ,  P.FraudStaffSideActionEntityID as BaseColumn,FI.FraudInnvolveEntityID,FI.CustomerId,-- p.DesignationAlt_Key AS	DesignationAlt_Key,
	 DD.DesignationName as DesignationName,
	 FI.InvolvePartyName
	 ,FI.EmpCode				
	 ,'N' as IsMainTable
	 ,P.CreatedBy
	 
	 from FraudStaffSideActionDetail_mod p
	 inner join 
	 (
	  Select max(c.EntityKey) as entitykey,c.FraudInnvolveEntityID from FraudStaffSideActionDetail_mod c
	  where (c.EffectiveFromTimeKey<=@TimeKey AND c.EffectiveToTimeKey>=@TimeKey) --AND ISNULL(ModifiedBy,CreatedBy) = @UserLoginId
	 AND ISNULL(c.AuthorisationStatus,'A') IN ('NP','MP','DP')
	 group by c.FraudInnvolveEntityID
	 ) K ON K.entitykey=p.EntityKey
	 
					
					inner join FraudInvolvementDetail FI
	on FI.FraudInnvolveEntityID = P.FraudInnvolveEntityID
	left outer join DImDesignation DD
					on DD.DesignationAlt_Key = FI.DesignationAlt_Key
							LEFT OUTER JOIN  Dimparameter A
					ON (A.EffectiveFromTimeKey <= @TimeKey AND A.EffectiveToTimeKey >= @TimeKey)
					AND A.DimParameterName = 'DimFraudInvParty'
					AND A.ParameterAlt_Key = FI.InvolvePartyAlt_Key
				and FI.InvolvePartyAlt_Key =1
	 where (P.EffectiveFromTimeKey<=@TimeKey AND p.EffectiveToTimeKey>=@TimeKey) --AND ISNULL(ModifiedBy,CreatedBy) = @UserLoginId
	 AND ISNULL(P.AuthorisationStatus,'A') IN ('NP','MP','DP') and P.FraudEntityId=@ParentColumnValue and FI.InvolvePartyAlt_Key =1
	END

			END

			ELSE IF @MenuId = 1003
			BEGIN


				DROP TABLE IF EXISTS #Branch1003
				SELECT 'GridData' TableName
						,A.BranchCode
						,A.BranchName
						,A.BranchOpenDt
						--,A.BranchNatureAlt_Key
						,A.BranchRegionAlt_Key
						,A.BranchDistrictAlt_Key
						,ISNULL(DateModified,DateCreated) DateCreated
						,'N'IsMainTable 
				INTO #Branch1003
				FROM DImBranch_Mod A
				INNER JOIN 
				(
					SELECT BranchCode,MAX(Branch_Key) Branch_Key  
					FROM DImBranch_Mod
					WHERE EffectiveFromTimeKey <= @timekey AND 	EffectiveToTimeKey >= @Timekey
					AND AuthorisationStatus in('NP','MP','DP','RM')
					GROUP BY BranchCode
				)B
				ON A.Branch_Key = B.Branch_Key

				INSERT INTO #Branch1003
				SELECT	  'GridData' TableName
						, BranchCode
						,BranchName
						,BranchOpenDt
						--,BranchNatureAlt_Key
						,BranchRegionAlt_Key
						,BranchDistrictAlt_Key
						,ISNULL(DateModified,DateCreated)
						,'Y'IsMainTable
				FROM DImBranch
				WHERE EffectiveFromTimeKey <= @timekey AND 	EffectiveToTimeKey >= @Timekey
				AND ISNULL(AuthorisationStatus,'A')='A'


				
				-----*********RETRIEVING A DATA FROM BRANCH DETAIL 

				DROP TABLE IF EXISTS #DimBranchDetail
					SELECT 'GridData' TableName
						,A.BranchCode
						,ISNULL(DateModified,DateCreated) DateCreated
						,'N'IsMainTable 
				INTO #DimBranchDetail
				FROM DimBranchDetail_Mod A
				INNER JOIN 
				(
					SELECT BranchCode,MAX(EntityKey) EntityKey  
					FROM DimBranchDetail_Mod
					WHERE EffectiveFromTimeKey <= @timekey AND 	EffectiveToTimeKey >= @Timekey
					AND AuthorisationStatus in('NP','MP','DP','RM')
					GROUP BY BranchCode
				)B
				ON A.EntityKey = B.EntityKey



				INSERT INTO #DimBranchDetail
				SELECT	  'GridData' TableName
						, BranchCode
						,ISNULL(DateModified,DateCreated)
						,'Y'IsMainTable
				FROM DimBranchDetail
				WHERE EffectiveFromTimeKey <= @timekey AND 	EffectiveToTimeKey >= @Timekey
				AND ISNULL(AuthorisationStatus,'A')='A'

				UPDATE BR
				SET DateCreated = BRD.DateCreated
					,IsMainTable = BRD.IsMainTable
				FROM #Branch1003 BR
				INNER JOIN #DimBranchDetail BRD
					ON BR.BranchCode = BRD.BranchCode
					AND BRD.DateCreated > BR.DateCreated
				
				IF @SearchFrom = 'QuickAccess' AND ISNULL(@SearchCondition,'')=''
				BEGIN
					SET @SearchFrom = NULL
				END
				IF @SearchFrom = 'QuickAccess'
				BEGIN
					PRINT  'QuickAccess'
					DECLARE @SqlBranch VARCHAR(MAX)
					IF @Mode = 16
					BEGIN
					--select * from #Branch1003
						SET @SQL  = 'SELECT TableName,BranchCode, BranchName,CONVERT(VARCHAR(10),BranchOpenDt,103)BranchOpenDt  FROM #Branch1003
						WHERE IsMainTable = ''N'''


						SET @SQL =  @SQL + ' AND '+ @SearchCondition+ ' ORDER BY DateCreated DESC, BranchCode'
						
						EXEC(@SQL)
					END
					ELSE
					BEGIN
						SET @SQL  = 'SELECT TableName,BranchCode, BranchName,CONVERT(VARCHAR(10),BranchOpenDt,103)BranchOpenDt  FROM #Branch1003
						WHERE '


						SET @SQL =  @SQL +' '+ ISNULL(@SearchCondition,'')+' ORDER BY DateCreated DESC, BranchCode'
						
						EXEC(@SQL)
						
					END
					
				END
				ELSE 
				BEGIN
					
					IF @Mode =16
					BEGIN
					print 'reema1'
					--select * from #Branch1003
						SELECT TableName,BranchCode, BranchName,CONVERT(VARCHAR(10),
						BranchOpenDt,103)BranchOpenDt  FROM #Branch1003
						WHERE IsMainTable = 'N'
						ORDER BY DateCreated DESC, BranchCode
					END
					ELSE 
					BEGIN
						SELECT TableName,BranchCode, BranchName ,CONVERT(VARCHAR(10),
						BranchOpenDt,103)BranchOpenDt FROM #Branch1003
						ORDER BY DateCreated DESC, BranchCode
					END
				END
			END
			
			ELSE IF @MenuId = 629
			BEGIN
				PRINT '629'
				--select * from #TmpGridSelect
				select @TimeKey = (select Timekey from sysdaymatrix where cast(date as date) = cast (GetDate() as date))
				--select @TimeKey
				--SELECT 'GridData' TableName , FraudInnvolveEntityID as BaseColumn,	A.AccountNo, ParameterName AS	InvolvePartyAlt_Key,InvolvePartyName
				--FROM FraudInvolvementDetail_mod	 A
				--LEFT OUTER JOIN  Dimparameter P
				--	ON (P.EffectiveFromTimeKey <= @TimeKey AND P.EffectiveToTimeKey >= @TimeKey)
				--	AND P.DimParameterName = 'DimFraudInvParty'
				--	AND P.ParameterAlt_Key = A.InvolvePartyAlt_Key
					

					-- select @TimeKey=TimeKey from SysDayMatrix where Cast(GETDATE() as date)=Cast([Date] as date)
	IF @Mode=16
	BEGIN
	--IF OBJECT_ID('TEMPDB..#ScreenPending') IS NOT NULL
	--					DROP TABLE #ScreenPending
	--				SELECT * INTO #ScreenPending 
	--				from(
	 Select

	'GridData' TableName , P.FraudInnvolveEntityID as BaseColumn,	P.AccountNo, P.PerpetratorPAN,P.CustomerId, A.ParameterName AS	InvolvePartyAlt_Key,InvolvePartyName
				--FROM 
	 ,'N' as IsMainTable
	 ,P.CreatedBy
	 --,'DimCyberSecStatus' as TableName
	 from FraudInvolvementDetail_mod P
	 inner join 
	 (
	  Select max(EntityKey) as entitykey,FraudInnvolveEntityID from FraudInvolvementDetail_mod
	  where (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) --AND ISNULL(ModifiedBy,CreatedBy) <> @UserLoginId
	 AND ISNULL(AuthorisationStatus,'A') IN ('NP','MP','DP')
	 --AND CyberSecStatusEntityId=@CyberSecStatusEntityId
	 group by FraudInnvolveEntityID
	 ) K ON K.entitykey=p.EntityKey
	 LEFT OUTER JOIN  Dimparameter A
					ON (A.EffectiveFromTimeKey <= @TimeKey AND A.EffectiveToTimeKey >= @TimeKey)
					AND A.DimParameterName = 'DimFraudInvParty'
					AND A.ParameterAlt_Key = P.InvolvePartyAlt_Key
	 where (P.EffectiveFromTimeKey<=@TimeKey AND P.EffectiveToTimeKey>=@TimeKey) --AND ISNULL(ModifiedBy,CreatedBy) <> @UserLoginId
	 AND ISNULL(P.AuthorisationStatus,'A') IN ('NP','MP','DP') and P.FraudEntityId= @ParentColumnValue
	

UNION 
						  -----Authorizaton in Pending in FraudRecoveryDetail

						Select

	'GridData' TableName , B.FraudInnvolveEntityID as BaseColumn,	B.AccountNo, B.PerpetratorPAN,B.CustomerId, 
	C.ParameterName AS	InvolvePartyAlt_Key,InvolvePartyName
				--FROM 
	 ,'N' as IsMainTable
	 ,B.CreatedBy
	 --,'DimCyberSecStatus' as TableName
	-- from FraudInvolvementDetail P
	 FROM Associatedtl_mod A
								INNER JOIN FraudInvolvementDetail B
									ON A.FraudInnvolveEntityID=B.FraudInnvolveEntityID
									
							LEFT OUTER JOIN  Dimparameter C
					ON (C.EffectiveFromTimeKey <= @TimeKey AND C.EffectiveToTimeKey >= @TimeKey)
					AND C.DimParameterName = 'DimFraudInvParty'
					AND C.ParameterAlt_Key = B.InvolvePartyAlt_Key
							WHERE (A.EffectiveFromTimeKey <= @Timekey AND A.EffectiveToTimeKey >= @Timekey)
							AND(B.EffectiveFromTimeKey <= @Timekey AND B.EffectiveToTimeKey >= @Timekey)
							--AND(FD.EffectiveFromTimeKey <= @Timekey AND FD.EffectiveToTimeKey >= @Timekey)
							 AND ISNULL(A.AuthorisationStatus,'A') IN ('NP','MP','DP','RM')
							  AND ISNULL(B.AuthorisationStatus,'A')='A'
							   --AND ISNULL(FD.AuthorisationStatus,'A')='A
							    and B.FraudEntityId= @ParentColumnValue
UNION 
							SELECT DISTINCT 
							'GridData' TableName , B.FraudInnvolveEntityID as BaseColumn,	B.AccountNo, B.PerpetratorPAN,B.CustomerId, 
	C.ParameterName AS	InvolvePartyAlt_Key,InvolvePartyName
				--FROM 
	 ,'N' as IsMainTable
	 ,B.CreatedBy
							FROM FraudSecurityValueDetail_MOD A
								INNER JOIN FraudInvolvementDetail B
									ON A.FraudInnvolveEntityID=B.FraudInnvolveEntityID
									LEFT OUTER JOIN  Dimparameter C
					ON (C.EffectiveFromTimeKey <= @TimeKey AND C.EffectiveToTimeKey >= @TimeKey)
					AND C.DimParameterName = 'DimFraudInvParty'
					AND C.ParameterAlt_Key = B.InvolvePartyAlt_Key
							WHERE (A.EffectiveFromTimeKey <= @Timekey AND A.EffectiveToTimeKey >= @Timekey)
							AND(B.EffectiveFromTimeKey <= @Timekey AND B.EffectiveToTimeKey >= @Timekey)
							--AND(FD.EffectiveFromTimeKey <= @Timekey AND FD.EffectiveToTimeKey >= @Timekey)
							 AND ISNULL(A.AuthorisationStatus,'A') IN ('NP','MP','DP','RM')
							  AND ISNULL(B.AuthorisationStatus,'A')='A'
							   and B.FraudEntityId= @ParentColumnValue

UNION 
							SELECT DISTINCT 
							'GridData' TableName , B.FraudInnvolveEntityID as BaseColumn,	B.AccountNo, B.PerpetratorPAN,B.CustomerId, 
	D.ParameterName AS	InvolvePartyAlt_Key,InvolvePartyName
				--FROM 
	 ,'N' as IsMainTable
	 ,B.CreatedBy
							FROM FraudDirectorsAssociateDt_MOD A
							INNER JOIN AssociateDtl c
									ON A.AssociateEntityId=c.AssociateEntityId

								INNER JOIN FraudInvolvementDetail B
									ON B.FraudInnvolveEntityID=c.FraudInnvolveEntityID
									LEFT OUTER JOIN  Dimparameter D
					ON (D.EffectiveFromTimeKey <= @TimeKey AND D.EffectiveToTimeKey >= @TimeKey)
					AND D.DimParameterName = 'DimFraudInvParty'
					AND D.ParameterAlt_Key = B.InvolvePartyAlt_Key
							WHERE (A.EffectiveFromTimeKey <= @Timekey AND A.EffectiveToTimeKey >= @Timekey)
							AND(B.EffectiveFromTimeKey <= @Timekey AND B.EffectiveToTimeKey >= @Timekey)
							AND(c.EffectiveFromTimeKey <= @Timekey AND c.EffectiveToTimeKey >= @Timekey)
							--AND(FD.EffectiveFromTimeKey <= @Timekey AND FD.EffectiveToTimeKey >= @Timekey)
							 AND ISNULL(A.AuthorisationStatus,'A') IN ('NP','MP','DP','RM')
							  AND ISNULL(B.AuthorisationStatus,'A')='A'
							   AND ISNULL(c.AuthorisationStatus,'A')='A'
							    and B.FraudEntityId= @ParentColumnValue

	END
	ELSE 
	BEGIN
	   Select

	 'GridData' TableName , p.FraudInnvolveEntityID as BaseColumn,	P.AccountNo, P.PerpetratorPAN,P.CustomerId, A.ParameterName AS	InvolvePartyAlt_Key,InvolvePartyName
				--FROM 
	 ,'N' as IsMainTable
	 ,P.CreatedBy
	 --,'DimCyberSecStatus' as TableName
	
	 --,'N' as IsMainTable
	-- ,P.CreatedBy
	 from FraudInvolvementDetail_mod p
	 inner join 
	 (
	  Select max(c.EntityKey) as entitykey,c.FraudInnvolveEntityID from FraudInvolvementDetail_mod c
	  where (c.EffectiveFromTimeKey<=@TimeKey AND c.EffectiveToTimeKey>=@TimeKey) --AND ISNULL(ModifiedBy,CreatedBy) = @UserLoginId
	 AND ISNULL(c.AuthorisationStatus,'A') IN ('NP','MP','DP')
	 --AND CyberSecStatusEntityId=@CyberSecStatusEntityId
	 group by c.FraudInnvolveEntityID
	 ) K ON K.entitykey=p.EntityKey
	 LEFT OUTER JOIN  Dimparameter A
					ON (A.EffectiveFromTimeKey <= @TimeKey AND A.EffectiveToTimeKey >= @TimeKey)
					AND A.DimParameterName = 'DimFraudInvParty'
					AND A.ParameterAlt_Key = P.InvolvePartyAlt_Key
	 where (P.EffectiveFromTimeKey<=@TimeKey AND p.EffectiveToTimeKey>=@TimeKey) --AND ISNULL(ModifiedBy,CreatedBy) = @UserLoginId
	 AND ISNULL(P.AuthorisationStatus,'A') IN ('NP','MP','DP') and P.FraudEntityId= @ParentColumnValue
	 UNION
	  Select

	  'GridData' TableName , A.FraudInnvolveEntityID as BaseColumn,	A.AccountNo, A.PerpetratorPAN,A.CustomerId, P.ParameterName AS	InvolvePartyAlt_Key,InvolvePartyName
				--FROM 
	 ,'Y' as IsMainTable
	 ,A.CreatedBy
	 --,'DimCyberSecStatus' as TableName
	 from FraudInvolvementDetail A
	 LEFT OUTER JOIN  Dimparameter P
					ON (P.EffectiveFromTimeKey <= @TimeKey AND P.EffectiveToTimeKey >= @TimeKey)
					AND P.DimParameterName = 'DimFraudInvParty'
					AND P.ParameterAlt_Key = A.InvolvePartyAlt_Key
	 where (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey) 
	 AND ISNULL(A.AuthorisationStatus,'A') ='A' and A.FraudEntityId= @ParentColumnValue
	-- order by A.FraudInnvolveEntityID
	END

			END 

			ELSE IF @MenuId = 624
			BEGIN
				PRINT '624'
				--select * from #TmpGridSelect
				select @TimeKey = (select Timekey from sysdaymatrix where cast(date as date) = cast (GetDate() as date))
				--select @TimeKey
				--SELECT 'GridData' TableName , FraudInnvolveEntityID as BaseColumn,	A.AccountNo, ParameterName AS	InvolvePartyAlt_Key,InvolvePartyName
				--FROM FraudInvolvementDetail_mod	 A
				--LEFT OUTER JOIN  Dimparameter P
				--	ON (P.EffectiveFromTimeKey <= @TimeKey AND P.EffectiveToTimeKey >= @TimeKey)
				--	AND P.DimParameterName = 'DimFraudInvParty'
				--	AND P.ParameterAlt_Key = A.InvolvePartyAlt_Key
					

					-- select @TimeKey=TimeKey from SysDayMatrix where Cast(GETDATE() as date)=Cast([Date] as date)
	IF @Mode=16
	BEGIN
	 Select
	-- FraudInnvolveEntityID
	'GridData' TableName , P.AssociateEntityId as BaseColumn, P.Address, P.Name, P.PAN, P.RefCustomerId

				--FROM 
	 ,'N' as IsMainTable
	 ,P.CreatedBy
	 --,'DimCyberSecStatus' as TableName
	 from AssociateDtl_MOD P
	 inner join 
	 (
	  Select max(EntityKey) as entitykey,AssociateEntityId from AssociateDtl_MOD
	  where (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) --AND ISNULL(ModifiedBy,CreatedBy) <> @UserLoginId
	 AND ISNULL(AuthorisationStatus,'A') IN ('NP','MP','DP')
	 --AND CyberSecStatusEntityId=@CyberSecStatusEntityId
	 group by AssociateEntityId
	 ) K ON K.entitykey=p.EntityKey
	 --LEFT OUTER JOIN  Dimparameter A
		--			ON (A.EffectiveFromTimeKey <= @TimeKey AND A.EffectiveToTimeKey >= @TimeKey)
		--			--AND A.DimParameterName = 'DimFraudInvParty'
		--			--AND A.ParameterAlt_Key = P.InvolvePartyAlt_Key
	 where (P.EffectiveFromTimeKey<=@TimeKey AND P.EffectiveToTimeKey>=@TimeKey) --AND ISNULL(ModifiedBy,CreatedBy) <> @UserLoginId
	 AND ISNULL(P.AuthorisationStatus,'A') IN ('NP','MP','DP') and P.FraudInnvolveEntityID=@ParentColumnValue
	  
	-- order by FraudInnvolveEntityID
--	END
	  UNION 
						  -----Authorizaton in Pending in FraudRecoveryDetail
 Select
	-- FraudInnvolveEntityID
	'GridData' TableName , P.AssociateEntityId as BaseColumn, P.Address, P.Name, P.PAN, P.RefCustomerId

				--FROM 
	 ,'N' as IsMainTable
	 ,P.CreatedBy
	 from AssociateDtl P
						INNER JOIN 
						(
							SELECT AssociateEntityId,FraudDirectorAssociateEntityID
							FROM FraudDirectorsAssociateDt_mod
							WHERE EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey
							 AND ISNULL(AuthorisationStatus,'A') IN ('NP','MP','DP','RM')
							 GROUP BY FraudDirectorAssociateEntityID,AssociateEntityId
						)B
							ON P.EffectiveFromTimeKey <= @TimeKey  AND P.EffectiveToTimeKey >= @TimeKey
							AND P.AssociateEntityId = B.AssociateEntityId and P.FraudInnvolveEntityID=@ParentColumnValue
					--		LEFT OUTER JOIN  Dimparameter C
					--ON (C.EffectiveFromTimeKey <= @TimeKey AND C.EffectiveToTimeKey >= @TimeKey)
					--AND C.DimParameterName = 'DimFraudInvParty'
					--AND C.ParameterAlt_Key = P.InvolvePartyAlt_Key
					END
	ELSE 
	BEGIN
	   Select

	 'GridData' TableName , p.AssociateEntityId as BaseColumn,	p.Address, p.Name, p.PAN, p.RefCustomerId
				--FROM 
	 ,'N' as IsMainTable
	 ,P.CreatedBy
	 --,'DimCyberSecStatus' as TableName
	
	 --,'N' as IsMainTable
	-- ,P.CreatedBy
	 from AssociateDtl_MOD p
	 inner join 
	 (
	  Select max(c.EntityKey) as entitykey,c.AssociateEntityId from AssociateDtl_MOD c
	  where (c.EffectiveFromTimeKey<=@TimeKey AND c.EffectiveToTimeKey>=@TimeKey) --AND ISNULL(ModifiedBy,CreatedBy) = @UserLoginId
	 AND ISNULL(c.AuthorisationStatus,'A') IN ('NP','MP','DP')
	 --AND CyberSecStatusEntityId=@CyberSecStatusEntityId
	 group by c.AssociateEntityId
	 ) K ON K.entitykey=p.EntityKey
	 --LEFT OUTER JOIN  Dimparameter A
		--			ON (A.EffectiveFromTimeKey <= @TimeKey AND A.EffectiveToTimeKey >= @TimeKey)
		--			--AND A.DimParameterName = 'DimFraudInvParty'
		--			--AND A.ParameterAlt_Key = P.InvolvePartyAlt_Key
	 where (P.EffectiveFromTimeKey<=@TimeKey AND p.EffectiveToTimeKey>=@TimeKey) --AND ISNULL(ModifiedBy,CreatedBy) = @UserLoginId
	 AND ISNULL(P.AuthorisationStatus,'A') IN ('NP','MP','DP') and P.FraudInnvolveEntityID=@ParentColumnValue
	 UNION
	  Select

	  'GridData' TableName , A.AssociateEntityId as BaseColumn,	A.Address, A.Name, A.PAN, A.RefCustomerId
				--FROM 
	 ,'Y' as IsMainTable
	 ,A.CreatedBy
	 --,'DimCyberSecStatus' as TableName
	 from AssociateDtl A
	 --LEFT OUTER JOIN  Dimparameter P
		--			ON (P.EffectiveFromTimeKey <= @TimeKey AND P.EffectiveToTimeKey >= @TimeKey)
		--			--AND P.DimParameterName = 'DimFraudInvParty'
		--			--AND P.ParameterAlt_Key = A.InvolvePartyAlt_Key
	 where (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey) 
	 AND ISNULL(A.AuthorisationStatus,'A') ='A' and A.FraudInnvolveEntityID=@ParentColumnValue
	-- order by A.FraudInnvolveEntityID
	END

			END

			ELSE IF @MenuId = 11905
			BEGIN
				PRINT '11905'
				--select * from #TmpGridSelect
				select @TimeKey = (select Timekey from sysdaymatrix where cast(date as date) = cast (GetDate() as date))
				--select @TimeKey
				--SELECT 'GridData' TableName , FraudInnvolveEntityID as BaseColumn,	A.AccountNo, ParameterName AS	InvolvePartyAlt_Key,InvolvePartyName
				--FROM FraudInvolvementDetail_mod	 A
				--LEFT OUTER JOIN  Dimparameter P
				--	ON (P.EffectiveFromTimeKey <= @TimeKey AND P.EffectiveToTimeKey >= @TimeKey)
				--	AND P.DimParameterName = 'DimFraudInvParty'
				--	AND P.ParameterAlt_Key = A.InvolvePartyAlt_Key
					

					-- select @TimeKey=TimeKey from SysDayMatrix where Cast(GETDATE() as date)=Cast([Date] as date)
	IF @Mode=16
	BEGIN
	 Select
	-- FraudInnvolveEntityID
	'GridData' TableName , P.FraudSecurityEntityID as BaseColumn, P.CurrentValue, P.Remark, P.SecurityParticular, P.ValuationDt

				--FROM 
	 ,'N' as IsMainTable
	 ,P.CreatedBy
	 --,'DimCyberSecStatus' as TableName
	 from Fraudsecurityvaluedetail_mod P
	 inner join 
	 (
	  Select max(EntityKey) as entitykey,FraudSecurityEntityID from Fraudsecurityvaluedetail_mod
	  where (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) --AND ISNULL(ModifiedBy,CreatedBy) <> @UserLoginId
	 AND ISNULL(AuthorisationStatus,'A') IN ('NP','MP','DP')
	 --AND CyberSecStatusEntityId=@CyberSecStatusEntityId
	 group by FraudSecurityEntityID
	 ) K ON K.entitykey=p.EntityKey
	 --LEFT OUTER JOIN  Dimparameter A
		--			ON (A.EffectiveFromTimeKey <= @TimeKey AND A.EffectiveToTimeKey >= @TimeKey)
		--			--AND A.DimParameterName = 'DimFraudInvParty'
		--			--AND A.ParameterAlt_Key = P.InvolvePartyAlt_Key
	 where (P.EffectiveFromTimeKey<=@TimeKey AND P.EffectiveToTimeKey>=@TimeKey) --AND ISNULL(ModifiedBy,CreatedBy) <> @UserLoginId
	 AND ISNULL(P.AuthorisationStatus,'A') IN ('NP','MP','DP') and P.FraudInnvolveEntityID=@ParentColumnValue
	 order by FraudInnvolveEntityID
	END
	ELSE 
	BEGIN
	   Select

	 'GridData' TableName , p.FraudSecurityEntityID as BaseColumn, p.CurrentValue, p.Remark, p.SecurityParticular, p.ValuationDt
				--FROM 
	 ,'N' as IsMainTable
	 ,P.CreatedBy
	 --,'DimCyberSecStatus' as TableName
	
	 --,'N' as IsMainTable
	-- ,P.CreatedBy
	 from Fraudsecurityvaluedetail_mod p
	 inner join 
	 (
	  Select max(c.EntityKey) as entitykey,c.FraudSecurityEntityID from Fraudsecurityvaluedetail_mod c
	  where (c.EffectiveFromTimeKey<=@TimeKey AND c.EffectiveToTimeKey>=@TimeKey) --AND ISNULL(ModifiedBy,CreatedBy) = @UserLoginId
	 AND ISNULL(c.AuthorisationStatus,'A') IN ('NP','MP','DP')
	 --AND CyberSecStatusEntityId=@CyberSecStatusEntityId
	 group by c.FraudSecurityEntityID
	 ) K ON K.entitykey=p.EntityKey
	 --LEFT OUTER JOIN  Dimparameter A
		--			ON (A.EffectiveFromTimeKey <= @TimeKey AND A.EffectiveToTimeKey >= @TimeKey)
					--AND A.DimParameterName = 'DimFraudInvParty'
					--AND A.ParameterAlt_Key = P.InvolvePartyAlt_Key
	 where (P.EffectiveFromTimeKey<=@TimeKey AND p.EffectiveToTimeKey>=@TimeKey) --AND ISNULL(ModifiedBy,CreatedBy) = @UserLoginId
	 AND ISNULL(P.AuthorisationStatus,'A') IN ('NP','MP','DP') and P.FraudInnvolveEntityID=@ParentColumnValue
	 UNION
	  Select

	  'GridData' TableName , A.FraudSecurityEntityID as BaseColumn, A.CurrentValue, A.Remark, A.SecurityParticular, A.ValuationDt
				--FROM 
	 ,'Y' as IsMainTable
	 ,A.CreatedBy
	 --,'DimCyberSecStatus' as TableName
	 from Fraudsecurityvaluedetail A
	
	 where (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey) 
	 AND ISNULL(A.AuthorisationStatus,'A') ='A' and A.FraudInnvolveEntityID=@ParentColumnValue
	-- order by A.FraudInnvolveEntityID
	END

			END

			ELSE IF @MenuId = 11925
			BEGIN
				PRINT '11925'
				--select * from #TmpGridSelect
				select @TimeKey = (select Timekey from sysdaymatrix where cast(date as date) = cast (GetDate() as date))
				--select @TimeKey
				--SELECT 'GridData' TableName , FraudInnvolveEntityID as BaseColumn,	A.AccountNo, ParameterName AS	InvolvePartyAlt_Key,InvolvePartyName
				--FROM FraudInvolvementDetail_mod	 A
				--LEFT OUTER JOIN  Dimparameter P
				--	ON (P.EffectiveFromTimeKey <= @TimeKey AND P.EffectiveToTimeKey >= @TimeKey)
				--	AND P.DimParameterName = 'DimFraudInvParty'
				--	AND P.ParameterAlt_Key = A.InvolvePartyAlt_Key
					

					-- select @TimeKey=TimeKey from SysDayMatrix where Cast(GETDATE() as date)=Cast([Date] as date)
	IF @Mode=16
	BEGIN
	 Select
	-- FraudInnvolveEntityID
	'GridData' TableName , P.FraudDirectorAssociateEntityID as BaseColumn, P.Address, P.Name, P.RefCustomerId

				--FROM 
	 ,'N' as IsMainTable
	 ,P.CreatedBy
	 --,'DimCyberSecStatus' as TableName
	 from FraudDirectorsAssociateDt_MOD P
	 inner join 
	 (
	  Select max(EntityKey) as entitykey,FraudDirectorAssociateEntityID from FraudDirectorsAssociateDt_MOD
	  where (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) --AND ISNULL(ModifiedBy,CreatedBy) <> @UserLoginId
	 AND ISNULL(AuthorisationStatus,'A') IN ('NP','MP','DP')
	 --AND CyberSecStatusEntityId=@CyberSecStatusEntityId
	 group by FraudDirectorAssociateEntityID
	 ) K ON K.entitykey=p.EntityKey
	 --LEFT OUTER JOIN  Dimparameter A
		--			ON (A.EffectiveFromTimeKey <= @TimeKey AND A.EffectiveToTimeKey >= @TimeKey)
					--AND A.DimParameterName = 'DimFraudInvParty'
					--AND A.ParameterAlt_Key = P.InvolvePartyAlt_Key
	 where (P.EffectiveFromTimeKey<=@TimeKey AND P.EffectiveToTimeKey>=@TimeKey) --AND ISNULL(ModifiedBy,CreatedBy) <> @UserLoginId
	 AND ISNULL(P.AuthorisationStatus,'A') IN ('NP','MP','DP') and P.AssociateEntityId=@ParentColumnValue
	-- order by FraudInnvolveEntityID
	END
	ELSE 
	BEGIN
	   Select

	 'GridData' TableName ,  p.FraudDirectorAssociateEntityID as BaseColumn, p.Address, p.Name, p.RefCustomerId
				--FROM 
	 ,'N' as IsMainTable
	 ,P.CreatedBy
	 --,'DimCyberSecStatus' as TableName
	
	 --,'N' as IsMainTable
	-- ,P.CreatedBy
	 from FraudDirectorsAssociateDt_MOD p
	 inner join 
	 (
	  Select max(c.EntityKey) as entitykey,c.FraudDirectorAssociateEntityID from FraudDirectorsAssociateDt_MOD c
	  where (c.EffectiveFromTimeKey<=@TimeKey AND c.EffectiveToTimeKey>=@TimeKey) --AND ISNULL(ModifiedBy,CreatedBy) = @UserLoginId
	 AND ISNULL(c.AuthorisationStatus,'A') IN ('NP','MP','DP')
	 --AND CyberSecStatusEntityId=@CyberSecStatusEntityId
	 group by c.FraudDirectorAssociateEntityID
	 ) K ON K.entitykey=p.EntityKey
	 LEFT OUTER JOIN  Dimparameter A
					ON (A.EffectiveFromTimeKey <= @TimeKey AND A.EffectiveToTimeKey >= @TimeKey)
					--AND A.DimParameterName = 'DimFraudInvParty'
					--AND A.ParameterAlt_Key = P.InvolvePartyAlt_Key
	 where (P.EffectiveFromTimeKey<=@TimeKey AND p.EffectiveToTimeKey>=@TimeKey) --AND ISNULL(ModifiedBy,CreatedBy) = @UserLoginId
	 AND ISNULL(P.AuthorisationStatus,'A') IN ('NP','MP','DP') and P.AssociateEntityID=@ParentColumnValue
	 UNION
	  Select

	  'GridData' TableName , A.FraudDirectorAssociateEntityID as BaseColumn, A.Address, A.Name, A.RefCustomerId
				--FROM 
	 ,'Y' as IsMainTable
	 ,A.CreatedBy
	 --,'DimCyberSecStatus' as TableName
	 from FraudDirectorsAssociateDt A
	 LEFT OUTER JOIN  Dimparameter P
					ON (P.EffectiveFromTimeKey <= @TimeKey AND P.EffectiveToTimeKey >= @TimeKey)
					--AND P.DimParameterName = 'DimFraudInvParty'
					--AND P.ParameterAlt_Key = A.InvolvePartyAlt_Key
	 where (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey) 
	 AND ISNULL(A.AuthorisationStatus,'A') ='A' and A.AssociateEntityID=@ParentColumnValue
	-- order by A.FraudInnvolveEntityID
	END

			END

			ELSE IF @MenuId = 11926
			BEGIN
				PRINT '11926'
				--select * from #TmpGridSelect
				select @TimeKey = (select Timekey from sysdaymatrix where cast(date as date) = cast (GetDate() as date))
				
					

					-- select @TimeKey=TimeKey from SysDayMatrix where Cast(GETDATE() as date)=Cast([Date] as date)
	IF @Mode=16
	BEGIN
	 Select
	-- FraudInnvolveEntityID
	'GridData' TableName , P.FraudDirectorEntityID as BaseColumn, P.Address, P.Name, P.PAN

				--FROM 
	 ,'N' as IsMainTable
	 ,P.CreatedBy
	 --,'DimCyberSecStatus' as TableName
	 from FraudDirectorsDtl_MOD P
	 inner join 
	 (
	  Select max(EntityKey) as entitykey,FraudDirectorEntityID from FraudDirectorsDtl_MOD
	  where (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) --AND ISNULL(ModifiedBy,CreatedBy) <> @UserLoginId
	 AND ISNULL(AuthorisationStatus,'A') IN ('NP','MP','DP')
	 --AND CyberSecStatusEntityId=@CyberSecStatusEntityId
	 group by FraudDirectorEntityID
	 ) K ON K.entitykey=p.EntityKey
	 --LEFT OUTER JOIN  Dimparameter A
		--			ON (A.EffectiveFromTimeKey <= @TimeKey AND A.EffectiveToTimeKey >= @TimeKey)
					--AND A.DimParameterName = 'DimFraudInvParty'
					--AND A.ParameterAlt_Key = P.InvolvePartyAlt_Key
	 where (P.EffectiveFromTimeKey<=@TimeKey AND P.EffectiveToTimeKey>=@TimeKey) --AND ISNULL(ModifiedBy,CreatedBy) <> @UserLoginId
	 AND ISNULL(P.AuthorisationStatus,'A') IN ('NP','MP','DP') and P.FraudEntityId=@ParentColumnValue
	-- order by FraudInnvolveEntityID
	END
	ELSE 
	BEGIN
	   Select

	 'GridData' TableName ,  p.FraudDirectorEntityID as BaseColumn, p.Address, p.Name, p.PAN
				--FROM 
	 ,'N' as IsMainTable
	 ,P.CreatedBy
	 --,'DimCyberSecStatus' as TableName
	
	 --,'N' as IsMainTable
	-- ,P.CreatedBy
	 from FraudDirectorsDtl_MOD p
	 inner join 
	 (
	  Select max(c.EntityKey) as entitykey,c.FraudDirectorEntityID from FraudDirectorsDtl_MOD c
	  where (c.EffectiveFromTimeKey<=@TimeKey AND c.EffectiveToTimeKey>=@TimeKey) --AND ISNULL(ModifiedBy,CreatedBy) = @UserLoginId
	 AND ISNULL(c.AuthorisationStatus,'A') IN ('NP','MP','DP')
	 --AND CyberSecStatusEntityId=@CyberSecStatusEntityId
	 group by c.FraudDirectorEntityID
	 ) K ON K.entitykey=p.EntityKey
	 --LEFT OUTER JOIN  Dimparameter A
		--			ON (A.EffectiveFromTimeKey <= @TimeKey AND A.EffectiveToTimeKey >= @TimeKey)
					--AND A.DimParameterName = 'DimFraudInvParty'
					--AND A.ParameterAlt_Key = P.InvolvePartyAlt_Key
	 where (P.EffectiveFromTimeKey<=@TimeKey AND p.EffectiveToTimeKey>=@TimeKey) --AND ISNULL(ModifiedBy,CreatedBy) = @UserLoginId
	 AND ISNULL(P.AuthorisationStatus,'A') IN ('NP','MP','DP') and P.FraudEntityId=@ParentColumnValue
	 UNION
	  Select

	  'GridData' TableName , A.FraudDirectorEntityID as BaseColumn, A.Address, A.Name, A.PAN
				--FROM 
	 ,'Y' as IsMainTable
	 ,A.CreatedBy
	 --,'DimCyberSecStatus' as TableName
	 from FraudDirectorsDtl A
	 --LEFT OUTER JOIN  Dimparameter P
		--			ON (P.EffectiveFromTimeKey <= @TimeKey AND P.EffectiveToTimeKey >= @TimeKey)
					--AND P.DimParameterName = 'DimFraudInvParty'
					--AND P.ParameterAlt_Key = A.InvolvePartyAlt_Key
	 where (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
	 AND ISNULL(A.AuthorisationStatus,'A') ='A' and A.FraudEntityId=@ParentColumnValue
	-- order by A.FraudInnvolveEntityID
	END

			END

			--ELSE IF @MenuId = 671
			--BEGIN
			--	SELECT 'GridData' TableName , BaseColumn, RecoverAmt, P.Parametername StatusAlt_Key,Remarks, CONVERT(VARCHAR(10),StatusDate,103) StatusDate
			--	 FROM #TmpGridSelect 	A

			--	 		INNER  JOIN DimParameter P
			--						ON P.EffectiveFromTimeKey <=@TimeKey AND P.EffectiveToTimeKey >= @TimeKey
			--						AND DimParameterName = 'DimCrimeStatus'
			--							AND A.StatusAlt_Key  = P.ParameterAlt_Key



			--END

			ELSE IF @MenuId = 671
			BEGIN
				PRINT '671'
				--select * from #TmpGridSelect
				select @TimeKey = (select Timekey from sysdaymatrix where cast(date as date) = cast (GetDate() as date))
				--select @TimeKey
				--SELECT 'GridData' TableName , FraudInnvolveEntityID as BaseColumn,	A.AccountNo, ParameterName AS	InvolvePartyAlt_Key,InvolvePartyName
				--FROM FraudInvolvementDetail_mod	 A
				--LEFT OUTER JOIN  Dimparameter P
				--	ON (P.EffectiveFromTimeKey <= @TimeKey AND P.EffectiveToTimeKey >= @TimeKey)
				--	AND P.DimParameterName = 'DimFraudInvParty'
				--	AND P.ParameterAlt_Key = A.InvolvePartyAlt_Key
					

					-- select @TimeKey=TimeKey from SysDayMatrix where Cast(GETDATE() as date)=Cast([Date] as date)
	IF @Mode=16
	BEGIN
	 Select

	'GridData' TableName , P.CrimeRecEntityId as BaseColumn,	P.RecoverAmt, A.ParameterName AS StatusAlt_Key,P.Remarks,P.StatusDate
				--FROM 
	 ,'N' as IsMainTable
	 ,P.CreatedBy
	 --,'DimCyberSecStatus' as TableName
	 from CrimerRecoveryDetails_Mod P
	 inner join 
	 (
	  Select max(EntityKey) as entitykey,CrimeRecEntityId from CrimerRecoveryDetails_Mod
	  where (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) --AND ISNULL(ModifiedBy,CreatedBy) <> @UserLoginId
	 AND ISNULL(AuthorisationStatus,'A') IN ('NP','MP','DP')
	 --AND CyberSecStatusEntityId=@CyberSecStatusEntityId
	 group by CrimeRecEntityId
	 ) K ON K.entitykey=p.EntityKey
	 LEFT OUTER JOIN  Dimparameter A
					ON (A.EffectiveFromTimeKey <= @TimeKey AND A.EffectiveToTimeKey >= @TimeKey)
					AND A.DimParameterName = 'DimCrimeStatus'
					AND A.ParameterAlt_Key = P.StatusAlt_Key
	 where (P.EffectiveFromTimeKey<=@TimeKey AND P.EffectiveToTimeKey>=@TimeKey) --AND ISNULL(ModifiedBy,CreatedBy) <> @UserLoginId
	 AND ISNULL(P.AuthorisationStatus,'A') IN ('NP','MP','DP') and P.CrimeEntityId=@ParentColumnValue
	-- order by FraudInnvolveEntityID
	END
	ELSE 
	BEGIN
	   Select

	 'GridData' TableName , p.CrimeRecEntityId as BaseColumn,	p.RecoverAmt, A.ParameterName AS StatusAlt_Key,p.Remarks,p.StatusDate
				--FROM 
	 ,'N' as IsMainTable
	 ,P.CreatedBy
	 --,'DimCyberSecStatus' as TableName
	
	 --,'N' as IsMainTable
	-- ,P.CreatedBy
	 from CrimerRecoveryDetails_Mod p
	 inner join 
	 (
	  Select max(c.EntityKey) as entitykey,c.CrimeRecEntityId from CrimerRecoveryDetails_Mod c
	  where (c.EffectiveFromTimeKey<=@TimeKey AND c.EffectiveToTimeKey>=@TimeKey) --AND ISNULL(ModifiedBy,CreatedBy) = @UserLoginId
	 AND ISNULL(c.AuthorisationStatus,'A') IN ('NP','MP','DP')
	 --AND CyberSecStatusEntityId=@CyberSecStatusEntityId
	 group by c.CrimeRecEntityId
	 ) K ON K.entitykey=p.EntityKey
	 LEFT OUTER JOIN  Dimparameter A
					ON (A.EffectiveFromTimeKey <= @TimeKey AND A.EffectiveToTimeKey >= @TimeKey)
					AND A.DimParameterName = 'DimCrimeStatus'
					AND A.ParameterAlt_Key = P.StatusAlt_Key
	 where (P.EffectiveFromTimeKey<=@TimeKey AND p.EffectiveToTimeKey>=@TimeKey) --AND ISNULL(ModifiedBy,CreatedBy) = @UserLoginId
	 AND ISNULL(P.AuthorisationStatus,'A') IN ('NP','MP','DP') and P.CrimeEntityId=@ParentColumnValue
	 UNION
	  Select

	  'GridData' TableName , A.CrimeRecEntityId as BaseColumn,	A.RecoverAmt, P.ParameterName AS StatusAlt_Key,A.Remarks,A.StatusDate
				--FROM 
	 ,'Y' as IsMainTable
	 ,A.CreatedBy
	 --,'DimCyberSecStatus' as TableName
	 from CrimerRecoveryDetails A
	 LEFT OUTER JOIN  Dimparameter P
					ON (P.EffectiveFromTimeKey <= @TimeKey AND P.EffectiveToTimeKey >= @TimeKey)
					AND P.DimParameterName = 'DimCrimeStatus'
					AND P.ParameterAlt_Key = A.StatusAlt_Key
	 where (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey) 
	 AND ISNULL(A.AuthorisationStatus,'A') ='A' and A.CrimeEntityId=@ParentColumnValue
	-- order by A.FraudInnvolveEntityID
	END

			END

			ELSE IF @MenuId = 508
			BEGIN
						--PRINT '508'
						--ERE A.PlaceHolder IS NULL
							--INNER JOIN DImGl GL 		--SELECT * FROM 
						--(
						--SELECT 'GridData' TableName , A.BaseColumn,A.BS_Code,	A.BS_Logic,  	A.GL_Code
						--,	A.MappingType
						--	--,A.PlaceHolder --+'  -  '+b.OfficeAccountDescription PlaceHolder
						-- FROM #TmpGridSelect A -- WH							-- ADDED ON 20 FEB 2018
							--	ON CAST(GL.GL_Code AS varchar(20)) = A.GL_Code    -- ADDED ON 20 FEB 2018
						-- UNION ALL


						--SELECT	  TableName
						--		, BaseColumn
						--		, BS_Code
						--		, BS_Logic
						--		, GL_Code
						--		, MappingType
						--	--	, REPLACE(CONVERT(VARCHAR(50),A.PlaceHolder)+','+CONVERT(VARCHAR(50),OFC.OfficeAccountDescription),',','(')+')'  AS PlaceHolder
						--		--, REPLACE(A.PlaceHolder, A.PlaceHolder, OFC.OfficeAccountDescription) AS PlaceHolder
						--FROM 
						--(
						--SELECT  TableName
						--		,BaseColumn
						--		,BS_Code
						--		,BS_Logic
						--		,A.GL_Code
						--		,A.MappingType
						--		, Split.a.value('.','varchar(500)')AS PlaceHolder
						--		FROM(
						--				SELECT CAST ('<M>'+REPLACE(A.PlaceHolder,',','</M><M>')+'</M>' AS XML)AS PlaceHolder 
						--						,   'GridData' TableName
						--						, A.BaseColumn
						--						, A.BS_Code
						--						, A.BS_Logic
						--						,A.GL_Code
						--						, A.MappingType
						--				FROM  #TmpGridSelect A WHERE ISNULL(A.PlaceHolder,'')<>''
						--	)AS A CROSS APPLY PlaceHolder.nodes('/M') AS Split(a)
						--)A
						--INNER JOIN BS.DimOfficeAccount OFC 
						--	ON  OFC.EffectiveFromTimeKey <= @TimeKey AND OFC.EffectiveToTimeKey >= @TimeKey
						--	AND A.PlaceHolder = OFC.OfficeAccountCode

						--)B ORDER BY B.BaseColumn
						

						SELECT 'GridData' TableName , A.BaseColumn,A.BS_Code,P.ParameterName AS BS_Logic	--A.BS_Logic
						,  	A.GL_Code
						,	A.MappingType
							
						 FROM #TmpGridSelect A 
						 INNER JOIN DImParameter P
							ON P.EffectiveFromTimeKey <= @Timekey AND P.EffectiveToTimeKey >= @Timekey
							AND DimParameterName='DimBSLogic'
							AND A.BS_Logic = P.ParameterShortName
				
			END

			ELSE IF @MenuId = 625
			BEGIN
					PRINT '625'

					--select * from #TmpGridSelect
				SELECT 'GridData' TableName,
				--A.LitigationEntityId
				 BaseColumn,
			    A.BranchCode,
				
				A.BranchCode +' - '+DB.BranchName AS BranchName,
				 CBD.CustomerId +' - '+CBD.CustomerName AS CustomerEntityId,
				 CBD.CustomerId Code,
		  
				 CBD.CustomerName as Description,
				--  CBD.CustomerId 
				 LokAdalatNyalaya, --AssetClassName,
				
				 CONVERT(VARCHAR(10),SuitDt,103) SuitDt, SuitRefNo,
				AssetClassName,
				 CONVERT(VARCHAR(10),NPADt,103) AS NPADt,
				ParameterName AS SuitTypeAlt_Key 
				FROM #TmpGridSelect A

				LEFT OUTER JOIN DimParameter P
					ON (P.EffectiveFromTimeKey <= @TimeKey AND P.EffectiveToTimeKey >= @TimeKey)
					AND P.DimParameterName = 'DimSuitType'
					AND P.ParameterAlt_Key = A.SuitTypeAlt_Key

				INNER JOIN CustomerBasicDetail CBD
					ON (CBD.EffectiveFromTimeKey <= @TimeKey AND CBD.EffectiveToTimeKey >= @TimeKey)
					AND A.CustomerEntityId=CBD.CustomerEntityId

				LEFT OUTER JOIN AdvCustFinancialDetail CFD
					ON (CFD.EffectiveFromTimeKey <= @TimeKey AND CFD.EffectiveToTimeKey >= @TimeKey)
					AND CFD.CustomerEntityId = A.CustomerEntityId

				LEFT OUTER JOIN DimAssetClass DAC
					ON (DAC.EffectiveFromTimeKey <= @TimeKey AND DAC.EffectiveToTimeKey >= @TimeKey)
					AND DAC.AssetClassAlt_Key = CFD.Cust_AssetClassAlt_Key

				LEFT OUTER JOIN AdvCustNPAdetail NPA
					ON (NPA.EffectiveFromTimeKey <= @TimeKey AND NPA.EffectiveToTimeKey >= @TimeKey)
					AND NPA.CustomerEntityId = A.CustomerEntityId
				 
				INNER JOIN DIMBRANCH DB
				 ON CFD.BranchCode=DB.BranchCode

				
				INNER JOIN #BRANCH B						--ADDED ON 23 AUG 2018
							ON DB.BranchCode = B.BranchCode	--ADDED ON 23 AUG 2018

					
			END 

			ELSE IF @MenuId = 626
			BEGIN
				PRINT '626'

				ALTER TABLE #TmpGridSelect add [Action] VARCHAR(10)

				UPDATE #TmpGridSelect SET [Action] ='VIEW'
				
				UPDATE
				#TmpGridSelect
				SET [Action] = 'EDIT'
				WHERE BaseColumn =
				(SELECT MAX(BaseColumn) FROM #TmpGridSelect)

				SELECT 'GridData' TableName , A.BaseColumn,  L.LitigationStageName LitigationStatusAlt_Key,L.LitigationStageAlt_Key Code,L.LitigationStageName Description,
				CONVERT(VARCHAR(10),A.LitigationStatusDt ,103) LitigationStatusDt 
				,[Action]
			   FROM #TmpGridSelect	A
				LEFT OUTER JOIN DimLitigationStage  L
					ON (L.EffectiveFromTimeKey <= @TimeKey AND L.EffectiveToTimeKey >= @TimeKey)
					AND L.LitigationStageAlt_Key = A.LitigationStatusAlt_Key
			END 


			ELSE IF @MenuId = 802
				BEGIN
					PRINT '623'
					SELECT 'GridData' TableName ,A.BaseColumn BaseColumn,
					P.ParameterName DataSource,
			        A.SheetName,
			        A.SQL
					FROM #TmpGridSelect	 A
					INNER JOIN  Dimparameter P
						ON (P.EffectiveFromTimeKey <= @TimeKey AND P.EffectiveToTimeKey >= @TimeKey)
						
						AND (P.ParameterAlt_Key = A.DataSource) AND
						 P.DimParameterName = 'DimDataSource'
				END 








			ELSE IF @MenuId = 627 
			BEGIN
				PRINT '627'
				IF @Mode = 16
				BEGIN
					IF @UserLocation = 'HO'
					BEGIN
						SELECT 'GridData' TableName
								, P.InwardNo BaseColumn 
								, Add1
								, P.BranchCode+' - '+BR.BranchName AS BranchCode
								, CustomerName
								, CONVERT(VARCHAR(10), DateOfRecpt, 103) DateOfRecpt
						FROM Inward P
						INNER JOIN 
						(
							SELECT InwardNo 
							FROM InwardFacilitydetail_Mod
							WHERE EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey
							AND AuthorisationStatus IN  ('NP','MP','DP','RM')
							GROUP BY InwardNo
						)C
						ON P.InwardNo = C.InwardNo
						LEFT OUTER JOIN DimBranch BR
							ON (BR.EffectiveFromTimeKey <= @TimeKey AND BR.EffectiveToTimeKey >= @TimeKey)
							AND BR.BranchCode = P.BranchCode

						UNION 
						SELECT 'GridData' TableName , BaseColumn, Add1,  P.BranchCode+' - '+BR.BranchName AS BranchCode
						, CustomerName, CONVERT(VARCHAR(10),DateOfRecpt,103) DateOfRecpt
						FROM #TmpGridSelect	P
						LEFT OUTER JOIN DimBranch BR
							ON (BR.EffectiveFromTimeKey <= @TimeKey AND BR.EffectiveToTimeKey >= @TimeKey)
							AND BR.BranchCode = P.BranchCode
					END
					ELSE 
					BEGIN
						SELECT 'GridData' TableName
								, P.InwardNo BaseColumn 
								, Add1
								, P.BranchCode+' - '+BR.BranchName AS BranchCode
								, CustomerName
								, CONVERT(VARCHAR(10), DateOfRecpt, 103) DateOfRecpt
						FROM Inward P
						INNER JOIN 
						(
							SELECT InwardNo 
							FROM InwardFacilitydetail_Mod
							WHERE EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey
							AND AuthorisationStatus IN  ('NP','MP','DP','RM')
							GROUP BY InwardNo
						)C
						ON P.InwardNo = C.InwardNo
						LEFT OUTER JOIN DimBranch BR
							ON (BR.EffectiveFromTimeKey <= @TimeKey AND BR.EffectiveToTimeKey >= @TimeKey)
							AND BR.BranchCode = P.BranchCode

						UNION 
						SELECT 'GridData' TableName , BaseColumn, Add1,  P.BranchCode+' - '+BR.BranchName AS BranchCode
						, CustomerName, CONVERT(VARCHAR(10),DateOfRecpt,103) DateOfRecpt
						FROM #TmpGridSelect	P
						LEFT OUTER JOIN DimBranch BR
							ON (BR.EffectiveFromTimeKey <= @TimeKey AND BR.EffectiveToTimeKey >= @TimeKey)
							AND BR.BranchCode = P.BranchCode
						INNER JOIN #BRANCHCODE BR1						 --ADDED ON 31 MARCH 2018
								ON BR1.UserLocationCode = P.BranchCode   --ADDED ON 31 MARCH 2018
					END
				END
				ELSE 
				BEGIN
					
					IF @UserLocation = 'HO'
					BEGIN
						SELECT 'GridData' TableName , BaseColumn, Add1
								,P.BranchCode+' - '+BR.BranchName AS BranchCode
								, CustomerName
								, CONVERT(VARCHAR(10),DateOfRecpt,103) DateOfRecpt
						FROM #TmpGridSelect	P
						LEFT OUTER JOIN DimBranch BR
							ON (BR.EffectiveFromTimeKey <= @TimeKey AND BR.EffectiveToTimeKey >= @TimeKey)
							AND BR.BranchCode = P.BranchCode
					END

					ELSE 
					BEGIN
						SELECT 'GridData' TableName , BaseColumn, Add1
								,P.BranchCode+' - '+BR.BranchName AS BranchCode
								, CustomerName
								, CONVERT(VARCHAR(10),DateOfRecpt,103) DateOfRecpt
						FROM #TmpGridSelect	P
						LEFT OUTER JOIN DimBranch BR
							ON (BR.EffectiveFromTimeKey <= @TimeKey AND BR.EffectiveToTimeKey >= @TimeKey)
							AND BR.BranchCode = P.BranchCode
						INNER JOIN #BRANCHCODE BR1							   -- ADDED ON 31 MAR 2018
							ON BR1.UserLocationCode = P.BranchCode             -- ADDED ON 31 MAR 2018


					END 
				END 
			END 
			ELSE IF @MenuId = 628
			BEGIN
				PRINT '628'
				SELECT 'GridData' TableName ,A.BaseColumn BaseColumn,
				SS.SubSectorName SubSectorAlt_Key , 	ActivityGroup,	InwAmount
				FROM #TmpGridSelect	A
				INNER JOIN  DimSubSector SS
						
						on (SS.SubSectorAlt_Key = A.SubSectorAlt_Key) 
			END 

			--ELSE IF @MenuId = 632
			--BEGIN
			--	PRINT '632'
			--	IF @Mode = 16
			--	BEGIN
			--		SELECT 'GridData' TableName,* FROM #TmpGridSelect
			--		--SELECT 'GridData' TableName , BaseColumn,	IssuerID,	IssuerName FROM #TmpGridSelect	

			--		--UNION

			--		--SELECT 'GridData' TableName
			--		--		,A.IssuerEntityID
			--		--		,A.IssuerID
			--		--		,A.IssuerName
			--		-- FROM InvestmentIssuerDetail A
			--		--INNER JOIN 
			--		--(
			--		--SELECT IssuerEntityID FROM InvestmentExtRatingDetail_MOD 
			--		--WHERE EffectiveFromTimeKey <= @Timekey AND EffectiveToTimeKey >= @Timekey
			--		--	 AND   AuthorisationStatus in('NP','MP','DP','RM')
			--		--GROUP BY  IssuerEntityID
			--		--)B ON A.EffectiveFromTimeKey <= @Timekey AND A.EffectiveToTimeKey >= @Timekey
			--		--AND A.IssuerEntityID = B.IssuerEntityID

			--	END

			--	ELSE
			--	BEGIN
			--	SELECT 'GridData' TableName , * FROM #TmpGridSelect	
			--	END
			--END

			ELSE IF @MenuId = 657
			BEGIN
				PRINT '657'
				select TableName	,BaseColumn	,EstablishmentDate,case when num = 1 then 'Y' else 'N' END flag,	Add1,	PhoneNo1

 from 
				(
				SELECT top 15 'GridData' TableName ,A.BankEntityId BaseColumn
				,CONVERT(VARCHAR(10), EstablishmentDate,103) EstablishmentDate,
				Row_Number ()OVER (order by DateCreated desc) num
				,A.Add1,
				A.PhoneNo1
			
				FROM BankDetail_mod	A 		
				where EffectiveToTimeKey >= EffectiveFromTimeKey
				--order by DateCreated desc
				)A
			END 












			ELSE IF @MenuId = 633
			BEGIN
				PRINT '633'

				DROP TABLE IF EXISTS #RatingAgency				


				SELECT	'GridData' TableName 
						, BaseColumn
						, B.RatingAgencyName RatingAgencyAlt_Key
						, C.AgencyRating RatingAlt_Key 
				FROM #TmpGridSelect	A
				LEFT OUTER JOIN
				(
					SELECT R.RatingAgencyAlt_Key, RatingAgencyName 			
					FROM DimExtRatingAgency AG			
					INNER JOIN DimExtAgencyRating    R			
						ON AG.EffectiveFromTimeKey <= @TImekey AND AG.EffectiveToTimeKey >= @TImekey		
						AND R.EffectiveFromTimeKey <= @TImekey AND R.EffectiveToTimeKey >= @TImekey		
						AND AG.RatingAgencyAlt_Key = R.RatingAgencyAlt_Key		
						AND R.IncCategoryShortNameEnum ='INVESTMENT'		
					GROUP BY R.RatingAgencyAlt_Key, RatingAgencyName 			

				)B
					ON A.RatingAgencyAlt_Key = B.RatingAgencyAlt_Key

				LEFT OUTER JOIN 
				(
					SELECT   RatingAlt_Key			
							,RatingAgencyAlt_Key	
							,AgencyRating 	
					FROM DimExtAgencyRating 			
					WHERE EffectiveFromTimeKey <= @TImekey AND EffectiveToTimeKey >= @TImekey			
					AND IncCategoryShortNameEnum = 'INVESTMENT'					

				)C
					ON A.RatingAgencyAlt_Key = C.RatingAgencyAlt_Key
					AND A.RatingAlt_Key		 = C.RatingAlt_Key
				
			END


			--	ELSE IF @MenuId IN  (637)
			--BEGIN
			--	PRINT '637'
			----	EXEC [dbo].[InvestmentTxnDetailSelect] @MenuId, @Mode, @ParentColumnValue, @TimeKey
			--BEGIN
				
			--			SELECT 'GridData' TableName ,A.* FROM #TmpGridSelect A

			--			UNION 

			--			SELECT   'GridData' TableName,
			--			       A.InstrumentEntityID as BaseColumn
								
			--					,A.InstrName
			--					,A.RefInstrumentID
			--			FROM InvestmentBasicDetail A
			--			INNER JOIN
			--			(
			--				SELECT InstrumentEntityID 
			--				FROM InvestmentTxnDetail_MOD 
			--				WHERE EffectiveFromTimeKey <=  @Timekey AND EffectiveToTimeKey >= @Timekey
			--				AND  AuthorisationStatus in('NP','MP','DP','RM')
			--				GROUP BY InstrumentEntityID
			--			)B
			--			ON A.InstrumentEntityID = B.InstrumentEntityID
			--		END


			--END














			

			ELSE IF @MenuId = 634
			BEGIN
					

					PRINT '634'
					IF @Mode = 16
					BEGIN
					--select * from #TmpGridSelect
						SELECT 'GridData' TableName ,A.* FROM #TmpGridSelect A

						UNION 

						SELECT   'GridData' TableName,
						       A.InstrumentEntityID as BaseColumn
								--A.IssuerEntityID
								,A.InstrName
								,A.RefInstrumentID
						FROM InvestmentBasicDetail A
						INNER JOIN
						(
							SELECT InstrumentEntityID 
							FROM InvestmentTxnDetail_MOD 
							WHERE EffectiveFromTimeKey <=  @Timekey AND EffectiveToTimeKey >= @Timekey
							AND  AuthorisationStatus in('NP','MP','DP','RM')
							GROUP BY InstrumentEntityID
						)B
						ON A.InstrumentEntityID = B.InstrumentEntityID
					END

					ELSE 
					BEGIN

						SELECT 'GridData' TableName ,*FROM #TmpGridSelect A

					END
			END 

			--ELSE IF @MenuId = 636
			--BEGIN
			--	PRINT '636'
			--	SELECT 'GridData' TableName 
			--			, BaseColumn,CONVERT(VARCHAR(10), AcqDt, 103)AcqDt, ParameterName AS AcqModeAlt_Key
			--	FROM #TmpGridSelect A	
			--	LEFT OUTER JOIN DimParameter B
			--		ON B.EffectiveFromTimeKey <= @TimeKey AND B.EffectiveToTimeKey >= @TimeKey
			--		AND B.DimParameterName = 'DimAcquistionOfSecurity'
			--		AND A.AcqModeAlt_Key = B.ParameterAlt_Key
			--END 

			--ELSE IF @MenuId = 637
			--BEGIN
			--	PRINT '637'
			--	SELECT 'GridData' TableName 
			--			, BaseColumn,CONVERT(VARCHAR(10), AcqDt, 103)AcqDt, ParameterName AS AcqModeAlt_Key
			--	FROM #TmpGridSelect A	
			--	LEFT OUTER JOIN DimParameter B
			--		ON B.EffectiveFromTimeKey <= @TimeKey AND B.EffectiveToTimeKey >= @TimeKey
			--		AND B.DimParameterName = 'DimSaleSecurity'
			--		AND A.AcqModeAlt_Key = B.ParameterAlt_Key
			--END 
			ELSE IF @MenuId IN  (636, 637)
			BEGIN
				PRINT '636, 637'
				EXEC [dbo].[InvestmentTxnDetailSelect] @MenuId, @Mode, @ParentColumnValue, @TimeKey
			END

				ELSE IF @MenuId IN  (635)
			BEGIN
				PRINT '635'
				/*	SELECT 'GridData' TableName ,
					
					--InstrumentEntityID
                  -- A.InvestmentBalanceEntityID as
				   BaseColumn
                  , A.CurrCode
                   ,A.CurrConvRt
                   ,A.CurrPrice
                   ,A.TotalProvision        
				   ,Convert( varchar(10), A.CurrQtrdt,103) CurrQtrdt
				   ,A.Value
				   ,A.UnitHeld
				 
                 
					FROM #TmpGridSelect A
				--	order by DateCreated asc
				*/
				--EXEC InvestmentBalanceDetail_Sel @Timekey = @Timekey , @Mode = @Mode, @ParentColumnvale = @ParentColumnValue
			
			END

		


			ELSE IF @MenuId = 640
			BEGIN
					
						

						PRINT '6401'

						SELECT Top 20 'GridData' TableName
							,BaseColumn,   CBD.CustomerID   AS CustomerId
							
								,CBD.CustomerName
								,P.ParameterName SicknessCategoryAlt_Key
								,CONVERT(VARCHAR(10), SicknessDt,103) SicknessDt
								, V.ViabilityStatusName ViabilityStatusAlt_Key
						 FROM #TmpGridSelect  A
						INNER JOIN CustomerBasicDetail	CBD
							ON CBD.EffectiveFromTimeKey <= @TimeKey AND CBD.EffectiveToTimeKey >= @TimeKey
								AND A.CustomerId = CBD.CustomerId

						INNER JOIN DimBranch BR
							ON BR.EffectiveFromTimeKey <= @TimeKey AND BR.EffectiveToTimeKey >= @TimeKey
							AND BR.BranchCode = CBD.ParentBranchCode

						INNER JOIN #BRANCH B
							ON BR.BranchCode = B.BranchCode
						
						LEFT OUTER JOIN DimParameter P
								ON P.EffectiveFromTimeKey <= @Timekey AND P.EffectiveToTimeKey >= @Timekey
								AND DimParameterName= 'DimSicknessCategory'
								AND A.SicknessCategoryAlt_Key = P.ParameterAlt_Key
				
						LEFT OUTER JOIN DimViabilityStatus V
							ON V.EffectiveFromTimeKey <= @Timekey AND V.EffectiveToTimeKey >= @Timekey
							AND V.ViabilityStatusAlt_Key = A.ViabilityStatusAlt_Key
						--***************************************************************************

					--	UNION 

						--SELECT Top 20 'GridData' TableName
						--	,BaseColumn,   CBD.CustomerID   AS CustomerId
						--		,CBD.CustomerName
						--		,P.ParameterName SicknessCategoryAlt_Key
						--		,CONVERT(VARCHAR(10), SicknessDt,103) SicknessDt
						--		, V.ViabilityStatusName ViabilityStatusAlt_Key
						-- FROM #TmpGridSelect  A
						--INNER JOIN JKGB_MISDB..CASA_Detail 	CBD
						--	ON CBD.EffectiveFromTimeKey <= @TimeKey AND CBD.EffectiveToTimeKey >= @TimeKey
						--		AND A.CustomerId = CBD.CustomerId

						--INNER JOIN DimBranch BR
						--	ON BR.EffectiveFromTimeKey <= @TimeKey AND BR.EffectiveToTimeKey >= @TimeKey
						--	AND BR.BranchCode = CBD.Branchcode

						--INNER JOIN #BRANCH B
						--	ON BR.BranchCode = B.BranchCode
						
						--LEFT OUTER JOIN DimParameter P
						--		ON P.EffectiveFromTimeKey <= @Timekey AND P.EffectiveToTimeKey >= @Timekey
						--		AND DimParameterName= 'DimSicknessCategory'
						--		AND A.SicknessCategoryAlt_Key = P.ParameterAlt_Key
				
						--LEFT OUTER JOIN DimViabilityStatus V
						--	ON V.EffectiveFromTimeKey <= @Timekey AND V.EffectiveToTimeKey >= @Timekey
						--	AND V.ViabilityStatusAlt_Key = A.ViabilityStatusAlt_Key
			END

			ELSE IF @MenuId = 681
			BEGIN
						SELECT 'GridData' TableName
								, BaseColumn
								, Particulars
								, FORMAT(RemarkDate, 'dd/MM/yyyy') RemarkDate 
						FROM #TmpGridSelect	
				
			END
			ELSE IF @MenuId = 641
				BEGIN
				
						PRINT '641'
						SELECT Top 20 'GridData' TableName 
								, BaseColumn	, BR.BranchName AS  BranchCode,CustomerId,	
							
								CONVERT(VARCHAR(10),SHGFormationDt,103)SHGFormationDt
								,TotalMwmbers 
						FROM #TmpGridSelect	 A
						INNER JOIN DimBranch BR
							ON BR.EffectiveFromTimeKey <= @TimeKey AND BR.EffectiveToTimeKey >= @TimeKey
							AND BR.BranchCode = A.BranchCode
						INNER JOIN #BRANCH B
							ON BR.BranchCode = B.BranchCode
				END

			ELSE IF @MenuId = 642
				BEGIN
						--SELECT 'GridData' TableName , *  FROM #TmpGridSelect
					
							PRINT 'P642'


							DROP TABLE IF EXISTS #NfDettail
							CREATE TABLE #NfDettail
							(
								TableName					VARCHAR(20)
								,BranchCode					VARCHAR(10)
								,CustomerEntityId			INT	
								,AccountEntityId			INT
								,CustomerACID				VARCHAR(20)
								,CustomerId					VARCHAR(20)
								,CustomerName				VARCHAR(80)
								,OriginalLimitRefNo			VARCHAR(20)
								,OriginalLimitDt			VARCHAR(10)
								,OriginalLimit				DECIMAL(18,2)
								,LCBGNo						VARCHAR(20)				
								,ApplicationDt				VARCHAR(10)				
								,OriginDt					VARCHAR(10)
								,EffectiveDt				VARCHAR(10)
								,ExpiryDt					VARCHAR(10)
								,ClaimExpiryDt				VARCHAR(10)
								,ExtensionDt				VARCHAR(10)
								,BeneficiaryName			VARCHAR(50)
								,NatureAlt_Key				SMALLINT
								,PurposeAlt_Key				SMALLINT
								,LcBgAmt					DECIMAL(18,2)			
								,MarginAmt					DECIMAL(18,2)
								,MarginType					SMALLINT	
								,Commission					DECIMAL(16,2)
								,AdjDt						VARCHAR(10)
								,InvocationStatusAlt_Key	SMALLINT		
								,provision					DECIMAL(16,2)
								,MarginAccNo				VARCHAR(16)	
								,AuthorisationStatus		VARCHAR(2)
								,CreatedModifiedBy			VARCHAR(20)
								,D2Ktimestamp				VARCHAR(100)
								,ChangeFields				VARCHAR(100)
								,IsMainTable				CHAR(1)
							)
							
							INSERT INTO #NfDettail
							EXEC [dbo].[BG_AdvNFAcBasicDetail_AdvFacNFDetail_SELECT] @Timekey = @Timekey, @OperationFlag = @Mode

						
							


							SELECT  'GridData' TableName , --*
									A.BaseColumn
									,A.BranchCode+' - '+BR.BranchName AS BranchCode
									--,A.Code	
									--,A.Description
									,NF.CustomerACID	
									,NF.CustomerId	
									,CustomerEntityId
									,NF.CustomerName	
									,NF.AccountEntityId	
									,NF.OriginalLimitRefNo	
									,NF.OriginalLimit
									,CONVERT(VARCHAR(10),OriginalLimitDt,103) OriginalLimitDt
									,CONVERT(VARCHAR(10),A.AdjDt,103)AdjDt
									,A.LcBgAmt
									,A.LCBGNo
									,CONVERT(VARCHAR(10),A.OriginDt,103)OriginDt
									,NF.MarginAccNo
									--,CreatedModifiedBy
									--,UserLocation
									--,UserLocationCode
							FROM #TmpGridSelect A
							INNER JOIN #NfDettail NF
								ON A.BaseColumn = NF.AccountEntityId
								AND A.LCBGNo = NF.LCBGNo
							INNER JOIN #BRANCH B
							    ON A.BranchCode = B.BranchCode

							INNER JOIN DimBranch BR
								ON BR.EffectiveFromTimeKey <= @TimeKey AND BR.EffectiveToTimeKey >= @TimeKey
								AND BR.BranchCode = A.BranchCode
							
							INNER JOIN  DimUserInfo USR
								ON USR.EffectiveFromTimeKey <= @TimeKey AND USR.EffectiveToTimeKey >= @TimeKey
								AND USR.UserLoginID = NF.CreatedModifiedBy
							WHERE (CASE WHEN @UserLocation = 'HO' THEN 1 
										WHEN @UserLocation ='ZO' 
										AND ((UserLocation = 'ZO' AND UserLocationCode = @UserLocationCode)
											 OR UserLocation IN ('RO', 'BO'))
											THEN 1
										WHEN @UserLocation ='RO'
										AND ((UserLocation = 'RO' AND UserLocationCode = @UserLocationCode)
											OR UserLocation = 'BO')
											THEN 1
										WHEN @UserLocation = 'BO'
											AND (UserLocation = @UserLocation AND UserLocationCode = @UserLocationCode)
											THEN 1
										ELSE 0 END)=1


				END


				ELSE IF @MenuId = 643
				BEGIN
						PRINT '643'

						SELECT 'GridData' TableName 
								, BaseColumn
								,BusinessSeg 
								,BusinessSegEnumartion
								--,TargetTypeAlt_key
								,TRG.ParameterName	TargetTypeAlt_key
								--,TargetUnitAlt_key
								,UNIT.ParameterName	TargetUnitAlt_key
								,CASE WHEN ISNULL(CntApplicableYN,'N')='Y' THEN 'Yes' ELSE 'No' END	CntApplicableYN
								,CASE WHEN ISNULL(AmtApplicableYN,'N')='Y' THEN 'Yes' ELSE 'No' END	AmtApplicableYN
								--,SubTotalOf 
								,CASE WHEN ISNULL(SubTotalYN,'N')='Y' THEN 'Yes' ELSE 'No' END SubTotalYN
						FROM #TmpGridSelect	 A
						--INNER JOIN #BRANCH B
						--	ON BR.BranchCode = CBD.ParentBranchCode
						LEFT OUTER JOIN Dimparameter TRG
							ON TRG.EffectiveFromTimeKey <= @TimeKey
							AND TRG.EffectiveToTimeKey >= @Timekey
							AND TRG.DimParameterName = 'DimTargetMasterType'
							AND TRG.ParameterAlt_Key = A.TargetTypeAlt_key	

						LEFT OUTER JOIN Dimparameter UNIT
							ON UNIT.EffectiveFromTimeKey <= @TimeKey
							AND UNIT.EffectiveToTimeKey >= @Timekey
							AND UNIT.DimParameterName = 'DimTargetUnit'
							AND UNIT.ParameterAlt_Key = A.TargetUnitAlt_key	
							
										
				END

			ELSE IF @MenuId IN (460)
			    BEGIN
						PRINT '460'
				        SELECT 'GridData' TableName,A.BaseColumn,B.CountryName as [CountryAlt_Key],C.DistrictName as [DistrictAlt_Key] FROM #TmpGridSelect  A
						LEFT JOIN DimCountry B  ON (B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey)
													AND A.CountryAlt_Key=B.CountryAlt_Key

						LEFT JOIN DimGeography	C ON (C.EffectiveFromTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey)	
														AND C.DistrictAlt_Key=A.DistrictAlt_Key														
				END
			ELSE IF @MenuId=1000
			BEGIN
				PRINT '1000'
				SELECT 'GridData' TableName 
						,BaseColumn	
						,CONVERT(VARCHAR(10),ApplicationDt, 103) ApplicationDt
						,P.ParameterName BranchNatureAlt_key	
						,BranchOfficeName
				FROM #TmpGridSelect	A
				LEFT OUTER JOIN DimParameter P
					ON P.EffectiveFromTimeKey <= @TimeKey AND P.EffectiveToTimeKey >= @TimeKey
					AND P.DimParameterName = 'DimBranchLicenseNature'
					AND P.ParameterAlt_Key = A.BranchNatureAlt_key
			END 
			ELSE IF @MenuId=9003
				BEGIN
						SELECT 'GridData' TableName,OwnerEntityId BaseColumn,B.ParameterName OwnerTypeAlt_Key,
						A.OwnerTypeAlt_Key,
						A.AssetOwnerName AssetOwnerName 
						FROM AdvSecurityOwnerDetail A
						INNER JOIN DimParameter    B  ON (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
														AND (B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey)														
														AND B.ParameterAlt_Key=A.OwnerTypeAlt_Key
														AND B.DimParameterName='DimRelationEntitiesind'
						WHERE A.SecurityEntityID=@ParentColumnValue 
								 
				 END	

				--	ELSE IF @MenuId = 2000
				--		BEGIN
				--			SELECT 'GridData' TableName * FROM #TmpGridSelect  A
							
								
				--END 

			ELSE IF  @MenuId IN (9004)
				BEGIN
				PRINT 'IN MenuId 9004'
						SELECT 'GridData' TableName,
						A.BaseColumn,	A.Remarks, CONVERT(VARCHAR(10),A.ValuationDt,103) ValuationDt,
						A.ValueAmount,	A.ValuerEntityId,	A.ValuerName --A.*
						  FROM #TmpGridSelect  A
				END
			
			ELSE IF @MenuId=9012
				BEGIN
						SELECT distinct 'GridData' TableName,ActionEntityId BaseColumn
						,CONVERT(VARCHAR(10),DateOfActionTaken,103)DateOfActionTaken,ParticularsOfActionTaken 
						FROM legal.SecurityActionDtls 
						WHERE 	(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						AND SecurityEntityId=@ParentColumnValue 
						
				END
			ELSE IF @MenuId=3800
				BEGIN
						SELECT 'GridData' TableName,RecoveryNo BaseColumn,AmtRecover AmtRecover, RemittedGtyCorp RemittedGtyCorp,B.LegalSaleNonSaleName RecoverySourceAlt_Key,
						convert(varchar(10),RecoveryDt,103)RecoveryDt					
						FROM AdvAcFacilityRecoveryDtls A
						INNER JOIN [LEGAL].[DimLegalSaleNonSale]    B  ON B.[LegalSaleNonSaleAlt_Key]=A.RecoverySourceAlt_Key
						WHERE  (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
						AND A.AccountEntityID=@ParentColumnValue 
				 END
		
		ELSE IF @MenuId = 1500
			BEGIN
					PRINT '1500'

					--select * from #TmpGridSelect
				SELECT 'GridData' TableName,
				 BaseColumn,
				
				A.BranchCode +' - '+B.BranchName AS BranchCode,
				 CBD.CustomerId +' - '+CBD.CustomerName AS CustomerEntityId,
				 CBD.CustomerId Code
				
				FROM #TmpGridSelect A

				INNER JOIN CustomerBasicDetail CBD
					ON (CBD.EffectiveFromTimeKey <= @TimeKey AND CBD.EffectiveToTimeKey >= @TimeKey)
					AND A.CustomerEntityId=CBD.CustomerEntityId


				INNER JOIN #BRANCH B						--ADDED ON 23 AUG 2018
							ON A.BranchCode = B.BranchCode	--ADDED ON 23 AUG 2018

					
			END 

		ELSE IF @MenuId = 1501
		BEGIN
				PRINT '1501'

			--select * from #TmpGridSelect
			SELECT 'GridData' TableName,
			 BaseColumn,

			CONVERT(VARCHAR(10),AcReviewdt, 103) AcReviewdt,
			AmtrefferedtoACR,

			A.BranchCode +' - '+B.BranchName AS BranchCode,
			 CBD.CustomerId +' - '+CBD.CustomerName AS CustomerEntityId,
			 CBD.CustomerId Code
			
			FROM #TmpGridSelect A

			INNER JOIN CustomerBasicDetail CBD
				ON (CBD.EffectiveFromTimeKey <= @TimeKey AND CBD.EffectiveToTimeKey >= @TimeKey)
				AND A.CustomerEntityId=CBD.CustomerEntityId


			INNER JOIN #BRANCH B						--ADDED ON 23 AUG 2018
						ON A.BranchCode = B.BranchCode	--ADDED ON 23 AUG 2018

				
		END 

		ELSE IF @MenuId = 1502
		BEGIN
				PRINT '1502'

			--select * from #TmpGridSelect
			SELECT 'GridData' TableName,
			 BaseColumn
			 ,CONVERT(VARCHAR(10),MortageDt, 103) MortageDt
			 --,CONVERT(VARCHAR(10),Renewvaldt, 103) Renewvaldt

			,A.BranchCode +' - '+B.BranchName AS BranchCode,
			 CBD.CustomerId +' - '+CBD.CustomerName AS CustomerEntityId,
			 CBD.CustomerId Code
			
			FROM #TmpGridSelect A

			INNER JOIN CustomerBasicDetail CBD
				ON (CBD.EffectiveFromTimeKey <= @TimeKey AND CBD.EffectiveToTimeKey >= @TimeKey)
				AND A.CustomerEntityId=CBD.CustomerEntityId


			INNER JOIN #BRANCH B						--ADDED ON 23 AUG 2018
						ON A.BranchCode = B.BranchCode	--ADDED ON 23 AUG 2018

				
		END 
		ELSE IF @MenuId = 1503
		BEGIN
				PRINT '1503'

			--select * from #TmpGridSelect
			SELECT 'GridData' TableName,
			 BaseColumn
			 ,CONVERT(VARCHAR(10),PremiumDt, 103) PremiumDt
			--,CASE WHEN PremiumPaidBy_AltKey='1' THEN 'Borrower' ELSE 'Bank' END PremiumPaidBy_AltKey
			,TotalPremium

			,A.BranchCode +' - '+B.BranchName AS BranchCode,
			 CBD.CustomerId +' - '+CBD.CustomerName AS CustomerEntityId,
			 CBD.CustomerId Code
			
			FROM #TmpGridSelect A

			INNER JOIN CustomerBasicDetail CBD
				ON (CBD.EffectiveFromTimeKey <= @TimeKey AND CBD.EffectiveToTimeKey >= @TimeKey)
				AND A.CustomerEntityId=CBD.CustomerEntityId


			INNER JOIN #BRANCH B						--ADDED ON 23 AUG 2018
						ON A.BranchCode = B.BranchCode	--ADDED ON 23 AUG 2018

				
		END 

			ELSE IF @MenuId = 1505
			BEGIN
				SELECT 'GridData' TableName , BaseColumn
				,InsuranceCompany
				,PolicyNumber
				,CONVERT(VARCHAR(10),ComplaintReceivedDt,103) ComplaintReceivedDt
				,NameofLifeInsured

				FROM #TmpGridSelect A	
			END


		ELSE 

		BEGIN
			PRINT 'ELSE'
			SELECT 'GridData' TableName , * FROM #TmpGridSelect	
		END
			
END			
 
GO