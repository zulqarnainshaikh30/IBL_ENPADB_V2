﻿SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
 
------ ====================================================================================================================
------ Author:			<Amar>
------ Create Date:		<30-11-2014>
------ Loading Master Data for Common Master Screen>
------ ====================================================================================================================
------- [MetaDynamicScreenSelectData]  @MenuId =6668, @TimeKey =24534, @Mode =2, @BaseColumnValue  = 1

CREATE PROCEDURE [dbo].[MetaDynamicScreenSelectData]
--declare
	 @MenuId			INT=610,
	 @TimeKey			INT=24860,
	 @Mode				TINYINT=2,
	 @BaseColumnValue	VARCHAR(50) = 1,
	 @ParentColumnValue VARCHAR(50) = NULL,
	 @TabId				INT=0
 AS 
BEGIN
	/*DECLARATION OF LOCAN VARIABLES FOR FURTHER USE*/
	DECLARE @SQL VARCHAR(MAX),
			@TableName varchar(500),
			@TableWithSchema varchar(50),
			@TableWithSchema_Mod varchar(50),
			@Schema varchar(5),
			@BaseColumn varchar(50),
			@EntityKey VARCHAR(50),
			@ChangeFields VARCHAR(200),
			@ParentColumn varchar(50)=''
	IF @Mode=1 SET @BaseColumnValue=0
	
	-----
	if (@MenuId = 629 or @MenuId =621 or @MenuId = 624 or @MenuId=11905 or @Menuid=11925 or @Menuid=671 or @MenuId=607 or @MenuId=622 or @MenuId=623 or @MenuId=11926)

	
	BEGIN

	select @TimeKey=TimeKey from SysDayMatrix where Cast(GETDATE() as date)=Cast([Date] as date)

	END
	/*START FOR CREATE THE TEMP TABLE FOR SELECT THE DATA*/

		/*FIND THE TABLES USED IN MENU FOR GET THE COLUMN LIST TO CREATE TEMP TABLE  */
		SET @TableName=(SELECT ','+ SourceTable 
		FROM MetaDynamicScreenField WHERE MenuID=@MenuId 
			AND ISNULL(ParentcontrolID,0)= CASE WHEN @TabId > 0 THEN @TabId ELSE ISNULL(ParentcontrolID,0) END 
			AND SkipColumnInQuery='N' AND ValidCode='Y'
		GROUP BY SourceTable
		FOR XML PATH(''))

		print @TableName
	
		/*REMOVE COMM FROM DFIRST POSITION*/
		SET @TableName=RIGHT(@TableName,LEN(@TableName)-1)

		/*FIND THE LIST OF COLUMNS USED IN ABOBE @TableName  VARIABLES FOR FIND THE COLUMNS AND KEEP IN TEMP TABLE*/
		IF  OBJECT_ID('Tempdb..#TmmpQry') IS NOT NULL
			DROP TABLE #TmmpQry

		CREATE TABLE #TmmpQry ( ColDtl VARCHAR(100))
		
	
		INSERT INTO #TmmpQry

		SELECT  distinct A.NAME +  ' '+ B.NAME+ ''+
							(CASE 
								WHEN B.NAME IN ('VARCHAR','NVARCHAR','CHAR') 
									THEN  +'('+cast(A.max_length as varchar(4))+')'
								WHEN B.NAME IN ('decimal','numeric') 
									THEN  +'('+cast(A.precision as varchar(4))+','+CAST(A.scale as varchar(2))+')'
								ELSE '' END
							)
								AS ColDtl
			
				FROM SYS.COLUMNS  A
					INNER JOIN SYS.types B ON B.system_type_id=A.system_type_id
					INNER JOIN MetaDynamicScreenField C
							ON (C.ControlName=A.name)
							AND C.MenuID=@MenuId 
							AND SkipColumnInQuery='N'  AND ValidCode='Y'
						INNER JOIN SYS.objects D
							ON D.object_id=A.object_id
							AND SCHEMA_NAME(D.SCHEMA_ID) NOT IN ('LEGALVW')
				WHERE OBJECT_NAME(A.OBJECT_iD) 
						IN (SELECT SourceTable 
									FROM MetaDynamicScreenField WHERE MenuID=@MenuId 
										AND ISNULL(ParentcontrolID,0)= CASE WHEN @TabId > 0 THEN @TabId ELSE ISNULL(ParentcontrolID,0) END 
										AND SkipColumnInQuery='N' AND ValidCode='Y'
									GROUP BY SourceTable
							)
					AND  ISNULL(ParentcontrolID,0)= CASE WHEN @TabId > 0 THEN @TabId ELSE ISNULL(ParentcontrolID,0) END 
					AND A.NAME NOT IN('EntityKey','D2Ktimestamp' ,'AuthorisationStatus','EffectiveFromTimeKey','EffectiveToTimeKey','CreatedBy','DateCreated','ModifiedBy','DateModified','ApprovedBy')
					AND B.name <>'sysname'

         
		--SELECT * FROM #TmmpQry

		PRINT 2222222222
		DECLARE @ColName VARCHAR(MAX)
		/*MERGED ALL THE COLUMNS WITH COMMA(,) SEPARATED FOR FURTHER USE*/	
		SELECT @ColName=STUFF((SELECT ','+ColDtl 
						FROM #TmmpQry M1
							--where M1.MasterTable=M2.MasterTable
						FOR XML PATH('')),1,1,'')   
				FROM #TmmpQry M2
        PRINT 'VVVVVVVVVVVVV'
		PRINT @ColName

		/*CREATE TEMP TABLE FOR INSERT THE OUTPUT FOR SELECT DATA*/
			IF  OBJECT_ID('Tempdb..#TmpSelData') IS NOT NULL
				DROP TABLE #TmpSelData

		SET @ColName=REPLACE(@ColName,'(-1)','(MAX)')

		CREATE TABLE  #TmpSelData (EntityKey INT)
			SET @SQL= 'ALTER TABLE #TmpSelData ADD '+@ColName 	
		EXEC (@SQL)

		ALTER TABLE #TmpSelData ADD AuthorisationStatus varchar(2), IsMainTable cHAR(1),CreatedModifiedBy VARCHAR(20),ChangeFields  VARCHAR(200), D2Ktimestamp INT,EffectiveFromTimekey int
	/*END OF CREATE TEMP TABLE FOR SELECT THE DATA*/
	--select * from #TmpSelData
		/* FIND THE FLAG FOR TAB USING IN SCREEN OR NOT*/
	DECLARE  @TabApplicable BIT=0
	SELECT @TabApplicable=1  FROM MetaDynamicScreenField WHERE MenuId= @MenuId AND isnull(ParentcontrolID,0)>0
	IF @TabApplicable=1 and @TabId=0
		BEGIN
			SELECT @TabId=MIN(ParentcontrolID)  FROM MetaDynamicScreenField WHERE MenuId= @MenuId AND isnull(ParentcontrolID,0)>0 AND ValidCode='Y'
		END


	/* FIND THE BASE COLUMN AND PARENT COLUMN */
	SELECT @TableName =SourceTable from  MetaDynamicScreenField where MenuId=@MenuID GROUP BY SourceTable
	SELECT @BaseColumn = ControlName from MetaDynamicScreenField where MenuId=@MenuID  AND ValidCode='Y'
			AND ISNULL(ParentcontrolID,0)= CASE WHEN @TabId > 0 THEN @TabId ELSE ISNULL(ParentcontrolID,0) END 
			AND BaseColumnType='BASE'
	SELECT  @ParentColumn= SourceColumn from MetaDynamicScreenField where MenuId=@MenuID  AND ValidCode='Y'
			AND ISNULL(ParentcontrolID,0)= CASE WHEN @TabId > 0 THEN @TabId ELSE ISNULL(ParentcontrolID,0) END 
			AND BaseColumnType='PARENT'

					
	/* FIND THE TABLE NAME WITH SCHEMA*/
	SELECT @TableWithSchema=SCHEMA_NAME(SCHEMA_ID)+'.'+@TableName , @Schema=SCHEMA_NAME(SCHEMA_ID)+'.'  FROM SYS.OBJECTS WHERE name=@TableName
	PRINT 'TableName' +@TableName
	SELECT @EntityKey=NAME FROM SYS.columns WHERE OBJECT_NAME(OBJECT_ID)=@TableName AND IS_identity=1
	PRINT 'EntityKey'
	PRINT 'EntityKey'+@EntityKey


	/* CREATE TEMP TABLE FOR MAIN DATA SELECT*/
		IF OBJECT_ID('Tempdb..#TmpDataSelect') IS NOT NULL
			DROP TABLE #TmpDataSelect
	

	/* CREATE TEMP TABLE MAINTAIN THE ISAINTABLE, AUTH STATUS AND CREATED_MODIFIED BY */
		IF  OBJECT_ID('Tempdb..#TmpAuthStatus') IS NOT NULL
			DROP TABLE #TmpAuthStatus
		CREATE TABLE #TmpAuthStatus (IsMainTable CHAR(1), AuthorisationStatus VARCHAR(2), CreatedModifiedBy VARCHAR(20))
		
	/* CREATE TEMP TABLE KEEP THE UNIQUE SOURCE TABLE */
		IF OBJECT_ID('Tempdb..#TmpSrcTable') IS NOT NULL
			DROP TABLE #TmpSrcTable

		CREATE TABLE #TmpSrcTable
			(RowId TINYINT ,SourceTable varchar(50))

	/* FIRST INSERTING BASE TABLE ON FIRST (1) SEQUENCE */
	--INSERT INTO #TmpSrcTable
		--SELECT 1, SourceTable FROM MetaDynamicScreenField 
		--WHERE MenuID=@MenuId AND BaseColumnType='BASE'
		--		AND ISNULL(ParentcontrolID,0)= CASE WHEN @TabId > 0 THEN @TabId ELSE ISNULL(ParentcontrolID,0) END 


	INSERT INTO #TmpSrcTable
		SELECT 1, SourceTable 
		FROM MetaDynamicScreenField A
		INNER JOIN
			(SELECT MIN(ControlID) ControlID	FROM MetaDynamicScreenField  
					WHERE MenuID=@MenuID AND  BaseColumnType='BASE' 
					AND ISNULL(ParentcontrolID,0)= CASE WHEN @TabID > 0 THEN @TabID ELSE ISNULL(ParentcontrolID,0) END
					AND ValidCode='Y'
				 ) B
				ON A.ControlID=B.ControlID
				AND SkipColumnInQuery='N' AND ValidCode='Y'
			WHERE MenuID=@MenuID AND  BaseColumnType='BASE' 
				AND ISNULL(ParentcontrolID,0)= CASE WHEN @TabID > 0 THEN @TabID ELSE ISNULL(ParentcontrolID,0) END
				AND ValidCode='Y'
		--INSERT INTO #TmpSrcTable
		--SELECT 1+ROW_NUMBER() OVER (ORDER BY SourceTable),SourceTable  
		--FROM #TmmpQry WHERE SourceTable NOT IN (SELECT SourceTable FROM #TmpSrcTable)
		--	GROUP BY SourceTable

		--SELECT * FROM #TmpSrcTable

			
	/* INSERT UNIQUE SOURCE TABLE FOR LOOPING PURPOSE*/
		INSERT INTO #TmpSrcTable
		SELECT 1+ROW_NUMBER() OVER (ORDER BY SourceTable),SourceTable  
		FROM MetaDynamicScreenField WHERE SourceTable NOT IN (SELECT SourceTable FROM #TmpSrcTable)
			AND MenuID=@MenuId 
			AND ISNULL(ParentcontrolID,0)= CASE WHEN @TabId > 0 THEN @TabId ELSE ISNULL(ParentcontrolID,0) END 
			AND SkipColumnInQuery='N' AND ValidCode='Y'
		GROUP BY SourceTable
		
		--INSERT INTO #TmpSrcTable
		--SELECT 1+ROW_NUMBER() OVER (ORDER BY SourceTable),SourceTable  
		--FROM #TmmpQry WHERE SourceTable NOT IN (SELECT SourceTable FROM #TmpSrcTable)
		--	GROUP BY SourceTable
		DECLARE @OrgParentColumnVal VARCHAR(50)
		SET @OrgParentColumnVal = @ParentColumnValue

		DELETE  #TmpSrcTable WHERE SourceTable IS NULL

		/* STARTING OF LOOP FOR FOR PREPARING THE SELECT DATA*/
		 DELETE FROM #TmpSrcTable WHERE ISNULL(SourceTable,'') =''
		
		DECLARE @RowId TINYINT=1
		WHILE @RowId<=(SELECT COUNT(1) FROM #TmpSrcTable)
			BEGIN		

					set @ParentColumnValue= @OrgParentColumnVal
					SELECT @TableName=SourceTable from #TmpSrcTable WHERE RowId=@RowId
					SELECT @EntityKey=NAME FROM SYS.columns WHERE OBJECT_NAME(OBJECT_ID)=@TableName AND IS_identity=1

					SELECT @TableWithSchema=SCHEMA_NAME(SCHEMA_ID)+'.'+@TableName , @Schema=SCHEMA_NAME(SCHEMA_ID)+'.'  FROM SYS.OBJECTS WHERE name=@TableName
					SELECT @TableWithSchema_Mod=SCHEMA_NAME(SCHEMA_ID)+'.'+@TableName+'_Mod' , @Schema=SCHEMA_NAME(SCHEMA_ID)+'.'  FROM SYS.OBJECTS WHERE name=@TableName+'_Mod'

					TRUNCATE TABLE #TmmpQry

					INSERT INTO #TmmpQry

					SELECT distinct A.NAME  ColDtl
					FROM SYS.COLUMNS  A
						INNER JOIN SYS.types B ON B.system_type_id=A.system_type_id
						INNER JOIN MetaDynamicScreenField C
								ON A.name=C.ControlName
								AND C.MENUID=@MenuId
								AND ISNULL(ParentcontrolID,0)= CASE WHEN @TabId > 0 THEN @TabId ELSE ISNULL(ParentcontrolID,0) END 
								AND SkipColumnInQuery='N' AND ValidCode='Y'
		
					WHERE OBJECT_NAME(OBJECT_ID) =@TableName
						AND A.NAME NOT IN('D2Ktimestamp')
					

					--SELECT * FROM #TmmpQry
						--PRINT 1235468
					--SELECT @ColName
					IF NOT EXISTS(SELECT 1 FROM #TmmpQry WHERE ColDtl=@ParentColumn)
						BEGIN
						    PRINT 5555555555
							SET @ParentColumnValue='0'
						END

					IF @RowId=1
						BEGIN
						
							SELECT  @ColName=STUFF((
									SELECT  ' ,' +ColDtl
										FROM #TmmpQry  A1
											WHERE ColDtl<>@ParentColumn --AND ColDtl<>@BaseColumn --changes 19 jun 2017
									FOR XML PATH('')),1,1,'')  
								FROM #TmmpQry A2

   
						
						END					
					ELSE
						BEGIN
							PRINT 88888888
							set @ColName=''
							SELECT  @ColName=STUFF((
									SELECT  ' ,A.' +ColDtl +'=B.'+ColDtl
										FROM #TmmpQry  A1
											WHERE ColDtl<>@ParentColumn AND ColDtl<>@BaseColumn
									FOR XML PATH('')),1,1,'')  
								FROM #TmmpQry A2
							
						END
					Print 'edcrfv'
					--PRINT @ColName + 'ColName'
					SET @ColName=RIGHT(@ColName,LEN(@ColName)-1)
					--PRINT @ColName +'RIGHT'	
					IF @RowId=1
						BEGIN
						
							SET @SQL='INSERT INTO  #TmpSelData('+ @ColName +', AuthorisationStatus,IsMainTable,  CreatedModifiedBy, ChangeFields, D2Ktimestamp,EffectiveFromTimekey,EntityKey)'

							SET @ColName='A.'+@ColName

							

							--IF @Mode<>16 
							--	BEGIN			
								
									
										
										SET @SQL=@SQL+ ' SELECT '+ @ColName +', AuthorisationStatus,''Y'' AS IsMainTable, ISNULL(ModifiedBy,CreatedBy) AS CreatedModifiedBy, '''' ChangeFields, CAST(D2Ktimestamp AS INT) D2Ktimestamp ,EffectiveFromTimekey,A.EntityKey FROM  '+@TableWithSchema +' A ' 
										SET @SQL=@SQL+' WHERE (EffectiveFromTimeKey<='+cast(@TimeKey AS VARCHAR(5)) +' AND EffectiveToTimeKey>=' +CAST(@TimeKey AS VARCHAR(5))+')'
										SET @SQL=@SQL+ CASE WHEN @ParentColumnValue<>'0' THEN ' AND '+ @ParentColumn +'= ' +@ParentColumnValue ELSE '' END
	
										SET @SQL=@SQL+' AND '+@BaseColumn+'='+@BaseColumnValue+' AND ISNULL(AuthorisationStatus,''A'')=''A'''									

										SET  @SQL=@SQL+ ' UNION '

										print 'MainTable'+@SQL
								   END
									print 'ModTable1'
									PRINT @TableWithSchema_Mod
									SET @SQL=@SQL+ ' SELECT '+ @ColName +', AuthorisationStatus,''N'' AS IsMainTable, ISNULL(ModifiedBy,CreatedBy) AS CreatedModifiedBy, ChangeFields ,CAST(D2Ktimestamp AS INT) D2Ktimestamp,EffectiveFromTimekey,A.EntityKey FROM  '+@TableWithSchema_Mod+' A' 
									PRINT 'ModTable2'+@SQL  
									PRINT @EntityKey
									SET @SQL=@SQL+' INNER JOIN (SELECT MAX('+@EntityKey+') AS '+@EntityKey +' FROM ' +@TableWithSchema_Mod+' B WHERE ' + CASE WHEN @ParentColumnValue<>'0' THEN  @ParentColumn +'= ' +@ParentColumnValue +' AND '  ELSE ' ' END  +@BaseColumn+'='''+@BaseColumnValue+''' AND B.AuthorisationStatus IN(''NP'',''MP'',''DP'')) B ON A.'+@EntityKey +' = B.'+@EntityKey
									PRINT 'ModTable3'+@SQL
									SET @SQL=@SQL+' WHERE (EffectiveFromTimeKey<='+cast(@TimeKey AS VARCHAR(5)) +' AND EffectiveToTimeKey>=' +CAST(@TimeKey AS VARCHAR(5))+')'
									PRINT 'ModTable4'+@SQL
									SET @SQL=@SQL+ CASE WHEN @ParentColumnValue<>'0' THEN ' AND '+ @ParentColumn +'= ' +@ParentColumnValue ELSE '' END
									PRINT 'ModTable5'+@SQL
									SET @SQL=@SQL+' AND '+@BaseColumn+'='''+@BaseColumnValue+''' AND AuthorisationStatus IN (''NP'',''MP'',''DP'')'
									PRINT 'ModTable6'+@SQL							

									
							      EXEC (@SQL)
								 
							  --END
										Print 'edcrfv123'	
					   -- ELSE					  
						  --  BEGIN									 
								--	PRINT '99999999'
								--	SET @SQL='UPDATE A SET '+@ColName
								--	+' FROM #TmpSelData A '
								--	+' INNER JOIN '+ @TableWithSchema+ ' B ON (EffectiveFromTimeKey<='+cast(@TimeKey AS VARCHAR(5)) +' AND EffectiveToTimeKey>=' +CAST(@TimeKey AS VARCHAR(5))+')'
								--	+  CASE WHEN @ParentColumn<>'' THEN ' AND B.'+ @ParentColumn +'= ' +@ParentColumnValue ELSE '' END
								--	+' AND A.'+@BaseColumn+'=B.'+@BaseColumn
								--	+' AND ISNULL(B.AuthorisationStatus,''A'') =''A'''
								--	print 'A1'+@SQL
								--	EXEC (@SQL)

								--	SET @SQL='UPDATE A SET '+@ColName
								--	+' FROM #TmpSelData A '
								--	+' INNER JOIN '+ @TableWithSchema_Mod+' B ON (EffectiveFromTimeKey<='+cast(@TimeKey AS VARCHAR(5)) +' AND EffectiveToTimeKey>=' +CAST(@TimeKey AS VARCHAR(5))+')'
								--	+' INNER JOIN (SELECT MAX('+@EntityKey+') AS '+@EntityKey +' FROM ' +@TableWithSchema_Mod+' B WHERE ' 
								--	+  CASE WHEN @ParentColumnValue<>'0' THEN  @ParentColumn +'= ' +@ParentColumnValue ELSE '' END  
								--	+  case when @ParentColumnValue<>'0' then ' AND ' else '' end +  @BaseColumn+'='+@BaseColumnValue+ ' AND B.AuthorisationStatus IN(''NP'',''MP'',''DP'')) C ON B.'+@EntityKey +' = C.'+@EntityKey
								--	+  CASE WHEN @ParentColumnValue<>'0' THEN ' AND A.'+ @ParentColumn +'= B.' +@ParentColumn ELSE '' END
								--	+' AND A.'+@BaseColumn+'=B.'+@BaseColumn
							
							
							 --   EXEC (@SQL)
						  --END
								
									INSERT INTO #TmpAuthStatus
									SELECT  IsMainTable,AuthorisationStatus,CreatedModifiedBy FROM #TmpSelData 

									--IF  @RowId>1
									--	BEGIN
									--		SET @SQL='INSERT INTO  #TmpSelData('+ @ColName +
													
									--	END
			
									SET @RowId=@RowId+1
											
					END
					print 'reema21'
				SELECT @ChangeFields=ChangeFields FROM #TmpSelData

				IF NOT EXISTS(SELECT 1 FROM #TmmpQry WHERE ColDtl LIKE 'CaseEntityID%')			
					BEGIN
						ALTER TABLE #TmpSelData ADD CaseEntityID INT
						
					END
				UPDATE #TmpSelData set CaseEntityID=@ParentColumnValue where isnull(CaseEntityID,0)=0

				IF NOT EXISTS(SELECT 1 FROM #TmmpQry WHERE ColDtl LIKE 'BranchCode%')			
					BEGIN
						ALTER TABLE #TmpSelData ADD BranchCode varchar(10)
					END

				declare @BrCode VARCHAR(10)
				
				
				
			IF EXISTS(SELECT 1 FROM  #TmpAuthStatus WHERE IsMainTable='N')
				BEGIN
					UPDATE T 
						SET IsMainTable='N'
						,AuthorisationStatus=(SELECT top(1) AuthorisationStatus FROM #TmpAuthStatus)
						,CreatedModifiedBy=(SELECT top(1) CreatedModifiedBy FROM #TmpAuthStatus)
					FROM #TmpSelData T
				END 
				

			DECLARE @CreatedModifiedBy varchar(50),	@UserLocation	varchar(5),	@UserLocationCode varchar(10)
			SELECT @CreatedModifiedBy = CreatedModifiedBy FROM #TmpSelData 
			print 'reema2134'
			/*FIND CHANGE FIELDS*/
			DECLARE
			@SQL1 NVARCHAR(MAX)
			print 'change1234'
			SET @SQL1 =' SELECT @ChangeFields=ChangeFields
			 FROM '+@TableWithSchema_Mod+'

						WHERE '+@EntityKey+'=(SELECT MAX('+@EntityKey+') AS '+@EntityKey+' FROM '+@TableWithSchema_Mod+' WHERE (EffectiveFromTimeKey<='+CAST(@TimeKey as varchar(6))+' AND EffectiveToTimeKey>='+CAST(@TimeKey as varchar(6))+') 
												   AND ISNULL(AuthorisationStatus,''A'')=''A''
													AND  '+@BaseColumn+'='+@BaseColumnValue+'	
													
						)'					 
						 
			--SET @SQL1=@SQL1+'AND'+CASE WHEN @ParentColumnValue<>'0' THEN ' AND '+ @ParentColumn +'= ' +@ParentColumnValue ELSE '' END				

			--SELECT @SQL1
			EXECUTE sp_executesql @SQL1,N'@ChangeFields varchar(max) output',@ChangeFields OUTPUT

			select @ChangeFields

			--ADDED ON 22 FEB 2018 BY HAMID
			UPDATE #TmpSelData
			SET AuthorisationStatus = 'A'
			WHERE ISNULL(AuthorisationStatus,'')=''

			--ADDED ON 23 FEB 2018 BY HAMID 
			---FOR REMOVING A SPACE
			UPDATE #TmpSelData
			SET AuthorisationStatus = LTRIM(RTRIM(AuthorisationStatus))


			

			IF @MenuId =610
			BEGIN

				SELECT 'SelectData' TableName,	@UserLocation CreatedModifiedByLoc, @UserLocationCode CreatedModifiedByLocCode
				, EntityKey, ApprovalDate, BLOTP_Date, ClubEntityId, ClubName, CurrentStatusAlt_Key, DormantInLast, LaunchDate
				,'JAMMU & KASHMIR' AS [StateName]
				, Dl.District_Code as District,
				--,DL.LocationName LocationAlt_key,
			--	DL.DISTRICT District,
				--SUB_DISTRICT as Taluka,
				Dl.Sub_District_Code as Taluka,DL.LocationAlt_key as LocationAlt_key
				,A.NABARD_Code, A.Revived, A.RevivedDate,A.AuthorisationStatus, A.IsMainTable, 
				A.CreatedModifiedBy, A.ChangeFields, A.D2Ktimestamp, A.CaseEntityID, A.BranchCode
				 FROM #TmpSelData A --WHERE MENUID=@MenuId
				 LEFT JOIN DimLocation DL
				 ON (DL.EffectiveFromTimeKey <= @TimeKey AND DL.EffectiveToTimeKey >= @TimeKey)
				 AND DL.LocationAlt_key = A.LocationAlt_key

				 DECLARE  @DistrictCode VARCHAR(8), @Taluka VARCHAR(8)
				 SELECT   @DistrictCode	= DL.DISTRICT_CODE
				         ,@Taluka		=SUB_DISTRICT_CODE
				 FROM #TmpSelData A --WHERE MENUID=@MenuId
				 LEFT JOIN DimLocation DL
				 ON (DL.EffectiveFromTimeKey <= @TimeKey AND DL.EffectiveToTimeKey >= @TimeKey)
				 AND DL.LocationAlt_key = A.LocationAlt_key
				 

	
				select 
				--'TalukaDataFetch' TableName,
				Distinct(Sub_District_Code) as Code,Sub_District as Description
				 from 
				 DimLocation
				 where 
				 District_Code=@DistrictCode and Sub_District Is NOT NULL


				 	select 
					--'VillageDataFetch' TableName,
				LocationCode as Code ,LocationName As Description
				 from 
				 DimLocation 
				 where Sub_District_Code=@Taluka and LocationCode Is NOT NULL

	


			END


			IF @MenuId = 605
			BEGIN
				
					PRINT '605'

					
					SELECT 'SelectData' TableName,	@UserLocation CreatedModifiedByLoc, @UserLocationCode CreatedModifiedByLocCode
					, A.EntityKey, A.BusiCorresEntityId, A.BusiCorresVillEntityId
					,Dl.District_Code as District
					,Dl.Sub_District_Code as Taluka
					, DL.LocationAlt_key as LocationAlt_Key
					--, A.LocationAlt_Key
					, A.Population, A.AuthorisationStatus
					, A.IsMainTable, A.CreatedModifiedBy, A.ChangeFields, A.D2Ktimestamp, A.CaseEntityID, A.BranchCode
					FROM #TmpSelData A--WHERE MENUID=@MenuId
						LEFT JOIN DimLocation DL
							ON (DL.EffectiveFromTimeKey <= @TimeKey AND DL.EffectiveToTimeKey >= @TimeKey)
							AND DL.LocationAlt_key = A.LocationAlt_key
			END

			ELSE IF @MenuId = 613
			BEGIN
				SELECT 'SelectData' TableName,	@UserLocation CreatedModifiedByLoc, @UserLocationCode CreatedModifiedByLocCode, * 
				, 'JAMMU & KASHMIR' AS [State]
				FROM #TmpSelData --WHERE MENUID=@MenuId
			END

			ELSE IF @MenuId = 614
			BEGIN
				SELECT 'SelectData' TableName,	@UserLocation CreatedModifiedByLoc, @UserLocationCode CreatedModifiedByLocCode
				,A.EntityKey,	A.AcHolderNo,	A.CampConductedByAlt_Key,	A.CampDate,	A.CampTypeAlt_Key,	A.CampTypeOthers,	A.FinLitCampEntityId
				,	A.FinLitEntityId,	A.FLC_BranchCode
				,Dl.District_Code as District
				,Dl.Sub_District_Code as Taluka
				,	A.LocationAlt_Key
				,'JAMMU & KASHMIR' AS [State]
				,	A.OpenAcAfterCamp, 	A.ParticipantsNo,
					A.Remarks,	A.StakeHolderAlt_Key,	A.StakeHolderOthers,	A.TargetGroupAlt_Key,	
					A.TargetGroupOthers
					,	A.UserLocation
					,	A.UserLocationCode
					,CASE WHEN A.UserLocation = 'HO' THEN 'Head Office'  --HO 
						  WHEN A.UserLocation = 'ZO' THEN 
							 (
								SELECT BranchZone 
								FROM DimBranch BR 
								WHERE EffectiveFromTimeKey <= @TimeKey
									AND EffectiveToTimeKey >= @TimeKey 
									AND BR.BranchZoneAlt_Key = A.UserLocationCode
								GROUP BY BranchZone
							 )		--ZO
						   WHEN A.UserLocation = 'RO' THEN 
						   (
								SELECT BranchRegion
								FROM DimBranch BR 
								WHERE EffectiveFromTimeKey <= @TimeKey
									AND EffectiveToTimeKey >= @TimeKey 
									AND BR.BranchRegionAlt_Key = A.UserLocationCode
								GROUP BY BranchRegion
						   )
						   WHEN A.UserLocation = 'BO' THEN 
						   (
								SELECT BranchName
								FROM DimBranch BR 
								WHERE EffectiveFromTimeKey <= @TimeKey
									AND EffectiveToTimeKey >= @TimeKey 
									AND BR.BranchCode = A.UserLocationCode
								GROUP BY BranchName
						   )
					 END AS UserLocationName
					,	A.AuthorisationStatus,	A.IsMainTable
					,	A.CreatedModifiedBy,	A.ChangeFields,	A.D2Ktimestamp,	A.CaseEntityID,	A.BranchCode
					
				--, A.* 
				FROM #TmpSelData A--WHERE MENUID=@MenuId
				LEFT JOIN DimLocation DL
							ON (DL.EffectiveFromTimeKey <= @TimeKey AND DL.EffectiveToTimeKey >= @TimeKey)
							AND DL.LocationAlt_key = A.LocationAlt_key
			END 
			
			ELSE IF @MenuId = 901
			BEGIN
				
					PRINT '901'

					
					SELECT 'SelectData' TableName,	A.EntityKey	,A.Currency	,A.DataExtractionMode	,A.DateFormat	,A.monetaryItemType		,A.NegativeDecimal	,A.OutputFileName	,A.ReportEntityId	,A.ReportId	,A.ReportName	,A.reporttype	,A.SequenceType	,
					--RIGHT(A.TaxonomyPath, CHARINDEX('\', REVERSE(A.TaxonomyPath)) - 1)	TaxonomyPath	,
					A.TaxonomyPath --AS 'TaxonomyPathPath',
					,A.Output_HTML
					,A.Output_Pdf
					,A.Output_Text
					,A.Output_Excel
					,A.AuthorisationStatus	,A.IsMainTable	,A.CreatedModifiedBy	,A.ChangeFields	,A.D2Ktimestamp	,A.CaseEntityID	,A.BranchCode	,CASE WHEN A.MultiCurrencyAllow=1 THEN '1' ELSE '0' END AS MultiCurrencyAllow
					FROM #TmpSelData A
			END
			ELSE IF @MenuId = 906
			BEGIN
				
					PRINT '901'

					
					SELECT 'SelectData' TableName
					
					,A.EntityKey	
					,A.DimensionName	
					,A.DimensionNameDomainMember	
					,A.DimensionNameDomainMemberSequence	
					,A.DimensionNameSequence	
					,A.DimentionEntityId	
					,A.HyperCubeId	
					,A.ReportId	
					,CASE WHEN A.SortingAllow=1 then '1' else '0' END AS SortingAllow
					,A.AuthorisationStatus	
					,A.IsMainTable	
					,A.CreatedModifiedBy	
					,A.ChangeFields	
					,A.D2Ktimestamp	
					,A.CaseEntityID	
					,A.BranchCode
					FROM #TmpSelData A
			END 
			else if @MenuId= 621
			BEGIN
			----declare @Entitykey int 
			select @EntityKey = max(Entitykey) from #TmpSelData --where EntityKey =@EntityKey
			----select * from #TmpSelData A --where EntityKey=@EntityKey

			SELECT 'SelectData' TableName,	@UserLocation CreatedModifiedByLoc, @UserLocationCode CreatedModifiedByLocCode,EffectiveFromTimeKey,* 
			FROM #TmpSelData where EntityKey = @EntityKey
			END
			ELSE
			BEGIN

				PRINT 'Else'


		--select * from #TmpSelData
				SELECT 'SelectData' TableName,	@UserLocation CreatedModifiedByLoc, @UserLocationCode CreatedModifiedByLocCode,EffectiveFromTimeKey,EntityKey,* FROM #TmpSelData --WHERE MENUID=@MenuId
			END
			SELECT 'ChangeFields' TableName,  ChngFld ControlId  FROM 
					(SELECT Split.a.value('.', 'VARCHAR(100)') AS ChngFld  
						FROM  (SELECT  CAST ('<M>' + REPLACE(@ChangeFields, ',', '</M><M>') + '</M>' AS XML) AS ChngFld 
				
							) AS A CROSS APPLY ChngFld.nodes ('/M') AS Split(a) )A
	
	
	if(@MenuId= 629)
	BEGIN
	Declare @FraudDetail_FromDT date='', @FraudInvolvementDetail_FromDT date='' ,@IsReject Char(1)

select @FraudDetail_FromDT=EffectiveFromDate from FraudDetail where (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
 AND FraudEntityId=@ParentColumnValue AND ISNULL(AuthorisationStatus,'A')='A'

select @FraudInvolvementDetail_FromDT=EffectiveFromDate from FraudInvolvementDetail where 
(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  AND FraudEntityId=@ParentColumnValue 
and FraudInnvolveEntityID=@BaseColumnValue AND ISNULL(AuthorisationStatus,'A') IN('MP','DP')

IF ISNULL(@FraudInvolvementDetail_FromDT,'')=''
	BEGIN

		SET @IsReject='Y'
	END

ELSE IF @FraudInvolvementDetail_FromDT<@FraudDetail_FromDT
	BEGIN
		SET @IsReject='N'
	END 
ELSE 
	BEGIN
		SET @IsReject='Y'
	END

	SELECT @IsReject IsReject,@FraudDetail_FromDT EffectivefromDate,'IsRejectData' TableName
	END
--	if(@MenuId= 624)
--	BEGIN
	
--	Declare @AssociateDetail_FromDT date='', @AssociateInvolvementDetail_FromDT date='' ,@IsRejectChild Char(1)

--select @AssociateDetail_FromDT=EffectiveFromDate from AssociateDtl_MOD where (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
-- AND AssociateEntityId=@ParentColumnValue AND ISNULL(AuthorisationStatus,'A')='A'

--select @AssociateInvolvementDetail_FromDT=EffectiveFromDate from FraudDirectorsAssociateDt where (EffectiveFromTimeKey<=@TimeKey
-- AND EffectiveToTimeKey>=@TimeKey)  AND AssociateEntityId=@ParentColumnValue and FraudDirectorAssociateEntityID=@BaseColumnValue AND ISNULL(AuthorisationStatus,'A') IN('MP','DP')

--IF ISNULL(@AssociateInvolvementDetail_FromDT,'')=''
--	BEGIN

--		SET @IsRejectChild='Y'
--	END

--ELSE IF @AssociateInvolvementDetail_FromDT<@AssociateDetail_FromDT
--	BEGIN
--		SET @IsRejectChild='N'
--	END 
--ELSE 
--	BEGIN
--		SET @IsRejectChild='Y'
--	END

--	SELECT @IsRejectChild IsReject,@AssociateDetail_FromDT EffectivefromDate,'IsRejectData' TableName
--	END
END



if(@MenuId = 622)
BEGIN
		Declare  @FraudRecoveryDetail_FromDT date='' --,@IsReject Char(1)

select @FraudDetail_FromDT=EffectiveFromDate from FraudDetail where (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
 AND FraudEntityId=@ParentColumnValue AND ISNULL(AuthorisationStatus,'A')='A'

select @FraudRecoveryDetail_FromDT=EffectiveFromDate from FraudRecoveryDetail where (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
AND FraudEntityId=@ParentColumnValue AND ISNULL(AuthorisationStatus,'A') IN('MP','DP')

IF ISNULL(@FraudRecoveryDetail_FromDT,'')=''
	BEGIN

		SET @IsReject='Y'
	END

ELSE IF @FraudRecoveryDetail_FromDT<@FraudDetail_FromDT
	BEGIN
		SET @IsReject='N'
	END 
ELSE 
	BEGIN
		SET @IsReject='Y'
	END

	SELECT @IsReject IsReject,@FraudDetail_FromDT,'IsRejectData' TableName
	END


	if(@MenuId=11926)
	BEGIN
	
		Declare  @FraudDirectorsDtl_FromDT date='' --,@IsReject Char(1)

select @FraudDetail_FromDT=EffectiveFromDate from FraudDetail where (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  AND FraudEntityId=@ParentColumnValue AND ISNULL(AuthorisationStatus,'A')='A'

select @FraudDirectorsDtl_FromDT=EffectiveFromDate from FraudDirectorsDtl where (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
AND FraudEntityId=@ParentColumnValue AND ISNULL(AuthorisationStatus,'A') IN('MP','DP')

IF ISNULL(@FraudDirectorsDtl_FromDT,'')=''
	BEGIN

		SET @IsReject='Y'
	END

ELSE IF @FraudDirectorsDtl_FromDT<@FraudDetail_FromDT
	BEGIN
		SET @IsReject='N'
	END 
ELSE 
	BEGIN
		SET @IsReject='Y'
	END

	SELECT @IsReject IsReject,@FraudDetail_FromDT,'IsRejectData' TableName

	END

	if(@MenuId=624)
	BEGIN
	
		Declare  @FraudAssociateDtl_FromDT date='' --,@IsReject Char(1)

select distinct @FraudDetail_FromDT=EffectiveFromDate from FraudInvolvementDetail where (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
AND FraudInnvolveEntityID=@ParentColumnValue AND ISNULL(AuthorisationStatus,'A')='A'

select distinct @FraudAssociateDtl_FromDT=EffectiveFromDate from AssociateDtl where (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
AND FraudInnvolveEntityID=@ParentColumnValue and AssociateEntityId=@BaseColumnValue AND ISNULL(AuthorisationStatus,'A') IN('MP','DP')

IF ISNULL(@FraudAssociateDtl_FromDT,'')=''
	BEGIN

		SET @IsReject='Y'
	END

ELSE IF @FraudAssociateDtl_FromDT<@FraudDetail_FromDT
	BEGIN
		SET @IsReject='N'
	END 
ELSE 
	BEGIN
		SET @IsReject='Y'
	END

	SELECT @IsReject IsReject,@FraudDetail_FromDT,'IsRejectData' TableName

	END

		if(@MenuId=11905)
	BEGIN
	
		Declare  @FraudSecurityValueDetail_FromDT date='' --,@IsReject Char(1)

select @FraudDetail_FromDT=EffectiveFromDate from FraudInvolvementDetail where (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
AND FraudInnvolveEntityID=@ParentColumnValue AND ISNULL(AuthorisationStatus,'A')='A'

select @FraudSecurityValueDetail_FromDT=EffectiveFromDate from FraudSecurityValueDetail where (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
AND FraudInnvolveEntityID=@ParentColumnValue AND ISNULL(AuthorisationStatus,'A') IN('MP','DP')

IF ISNULL(@FraudSecurityValueDetail_FromDT,'')=''
	BEGIN

		SET @IsReject='Y'
	END

ELSE IF @FraudSecurityValueDetail_FromDT<@FraudDetail_FromDT
	BEGIN
		SET @IsReject='N'
	END 
ELSE 
	BEGIN
		SET @IsReject='Y'
	END

	SELECT @IsReject IsReject,@FraudDetail_FromDT,'IsRejectData' TableName

	END

	if(@MenuId=11925)
	BEGIN
	
		Declare  @FraudDirectorsAssociateDt_FromDT date='' --,@IsReject Char(1)

select @FraudDetail_FromDT=EffectiveFromDate from AssociateDtl where (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
AND AssociateEntityId=@ParentColumnValue AND ISNULL(AuthorisationStatus,'A')='A'

select @FraudSecurityValueDetail_FromDT=EffectiveFromDate from FraudDirectorsAssociateDt where (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
AND AssociateEntityId=@ParentColumnValue AND ISNULL(AuthorisationStatus,'A') IN('MP','DP')

IF ISNULL(@FraudSecurityValueDetail_FromDT,'')=''
	BEGIN

		SET @IsReject='Y'
	END

ELSE IF @FraudSecurityValueDetail_FromDT<@FraudDetail_FromDT
	BEGIN
		SET @IsReject='N'
	END 
ELSE 
	BEGIN
		SET @IsReject='Y'
	END

	SELECT @IsReject IsReject,@FraudDetail_FromDT,'IsRejectData' TableName

	END


--	if(@MenuId=607)
--	BEGIN
	
--		--Declare  @FraudAssociateDtl_FromDT date='' --,@IsReject Char(1)
--		Declare  @CrimeCaseRecovery_FromDT date=''
----select distinct @FraudDetail_FromDT=EffectiveFromDate from FraudInvolvementDetail where (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
--select distinct @CrimeDetail_FromDT=EffectiveFromDate from CrimeDetails where (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
--AND CrimeEntityId=@ParentColumnValue AND ISNULL(AuthorisationStatus,'A')='A'

--select distinct @FraudAssociateDtl_FromDT=EffectiveFromDate from AssociateDtl where (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
--AND FraudInnvolveEntityID=@ParentColumnValue and AssociateEntityId=@BaseColumnValue AND ISNULL(AuthorisationStatus,'A') IN('MP','DP')

--IF ISNULL(@FraudAssociateDtl_FromDT,'')=''
--	BEGIN

--		SET @IsReject='Y'
--	END

--ELSE IF @FraudAssociateDtl_FromDT<@FraudDetail_FromDT
--	BEGIN
--		SET @IsReject='N'
--	END 
--ELSE 
--	BEGIN
--		SET @IsReject='Y'
--	END

--	SELECT @IsReject IsReject,@FraudDetail_FromDT,'IsRejectData' TableName

--	END

	--if(@MenuId= 629)

	if(@MenuId= 671)
	BEGIN
	Declare @CrimeDetail_FromDT date='', @CrimerRecoveryDetails_FromDT date='' --,@IsReject Char(1)

select @CrimeDetail_FromDT=EffectiveFromDate from CrimeDetails where (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
 AND CrimeEntityId=@ParentColumnValue AND ISNULL(AuthorisationStatus,'A')='A'

select @CrimerRecoveryDetails_FromDT=EffectiveFromDate from CrimerRecoveryDetails where 
(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  AND CrimeEntityId=@ParentColumnValue 
and CrimeRecEntityId=@BaseColumnValue AND ISNULL(AuthorisationStatus,'A') IN('MP','DP')

IF ISNULL(@CrimerRecoveryDetails_FromDT,'')=''
	BEGIN

		SET @IsReject='Y'
	END

ELSE IF (@CrimerRecoveryDetails_FromDT < @CrimeDetail_FromDT)
	BEGIN
		SET @IsReject='N'
	END 
ELSE 
	BEGIN
		SET @IsReject='Y'
	END

	SELECT @IsReject IsReject,@CrimeDetail_FromDT,'IsRejectData' TableName
	END

--END
GO