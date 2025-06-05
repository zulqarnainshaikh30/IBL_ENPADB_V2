﻿SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetaDynamicInUpMain]
	@BaseColumnValue varchar(50)='0'
	,@ParentColumnValue varchar(50)='0'
	,@TabID int=0
	,@ColumnName VARCHAR(MAX) ='|Advocate|JuniorAdvocate|ProfEntityId|ProfParentEntityId|ConstitutionAlt_Key|SalutationAlt_Key|ProfessionalName|RegistrationNo|BarCouncilStateAlt_key|Qualification|CategoryAlt_Key|WealthTaxActRegNo|PANNo|AccountNo|IFSCCode|BankBranchCode|BankBranchName|GuardianName|ReligionAlt_Key|CasteAlt_Key|WorkAreaCity|MobileNo|Email|ContactPerName|ContactPerMobileNo|EmpRefNo|EmpanelmentNo|EmpanellingAuthorityAlt_key|RefNoforreimbursofBill|RenewalRefNo|DepanelmentRefNo|DepanalmentReasonAlt_key|AdvocateStatus|Address'
	,@DataValue VARCHAR (MAX) ='|151|20|dasd|asd|1321546464|54654564|654654654|564564|564fdsdf|dfsdf|8087879797|jhasdhkasd@fasd.com'
	,@DataValueAuth VARCHAR (MAX)
	,@EffectiveFromTimeKey INT=3500
	,@EffectiveToTimeKey INT=9999
	,@CreateModifyApprovedBy VARCHAR(20) ='D2KAMAR'
	,@OperationFlag INT=1
	,@TimeKey INT=9999
	,@AuthMode char(2)= 'Y'                                        
	,@MenuID INT=6669
	,@Remark varchar(200)=NULL
	,@ChangeFields varchar(200)=NULL
	,@D2Ktimestamp INT =0 OUTPUT
	,@Result INT =0 OUTPUT

AS 


SET DATEFORMAT DMY
 
BEGIN
	
		SET @DataValue=replace(@DataValue,'&','_AND_')
		IF @AuthMode IN('S','H','A')
			SET @AuthMode='Y'
			/*DECLARE LOCAL VARIABLES*/
		DECLARE
			
			 @ColName VARCHAR(max) 
			,@DataVal VARCHAR(max) 
			,@ColName_DataVal varchar(MAX)
			,@SourceTableName varchar(50)
			,@BranchCode VARCHAR(20)=''
		
	print 'Begin1'
			IF @OperationFlag=1 SET @BaseColumnValue=0
	
			DECLARE  @TabApplicable BIT=0
			SELECT @TabApplicable=1  FROM MetaDynamicScreenField WHERE MenuId= @MenuId AND isnull(ParentcontrolID,0)>0 AND ValidCode='Y'
	
			IF @TabApplicable=1 and @TabId=0
				BEGIN
					SELECT @TabId=MIN(ParentcontrolID)  FROM MetaDynamicScreenField WHERE MenuId= @MenuId AND isnull(ParentcontrolID,0)>0 AND ValidCode='Y'
				END
print 'Begin12'
	/*base work for data preparing */		
	
			IF OBJECT_ID('Tempdb..##TmpData') IS NOT NULL
				DROP TABLE ##TmpData
						
			/*	PREPARE	TEMP TABLE WITH SPLIT OF PIPE "|" SEPERATED COLUMNS AND DATA VALUE */
			SELECT DENSE_RANK() OVER (PARTITION BY  c.SourceTable ORDER BY c.SourceTable) as TableSeq, c.SourceTable, A.ControlName,b.DataVal 
						,BaseColumnType
				INTO ##TmpData
				
				FROM(
						SELECT ROW_NUMBER() OVER (ORDER BY  (select 1)) as ColSeq, Split.a.value('.', 'VARCHAR(8000)') AS ControlName  
							FROM  (SELECT 
									CAST ('<M>' + REPLACE(@ColumnName, '|', '</M><M>') + '</M>' AS XML) AS ControlName
								) AS A CROSS APPLY ControlName.nodes ('/M') AS Split(a) 

					) A
				INNER JOIN (
							SELECT ROW_NUMBER() OVER (ORDER BY  (select 1)) as DataSeq, Split.a.value('.', 'VARCHAR(8000)') AS DataVal  
							FROM  (SELECT 
									CAST ('<M>' + REPLACE(@DataValue, '|', '</M><M>') + '</M>' AS XML) AS DataVal
								) AS A CROSS APPLY DataVal.nodes ('/M') AS Split(a) 
						) b
						ON A.ColSeq=b.DataSeq
				LEFT JOIN MetaDynamicScreenField c
						on a.ControlName=c.ControlName
				where  c.MenuId=@MenuID
						AND ISNULL(C.ParentcontrolID,0)= CASE WHEN @TabID > 0 THEN @TabID ELSE ISNULL(C.ParentcontrolID,0) END
						AND ValidCode='Y'
				
			
	

		/* WORK FOR PREPARE UNIQUE TABLE LIST USING IN THE MENUID */
		IF OBJECT_ID('Tempdb..##TmpSrcTable') IS NOT NULL
			DROP TABLE ##TmpSrcTable

		CREATE TABLE ##TmpSrcTable
			(RowId TINYINT ,SourceTable varchar(50))

		/* FIND AND INSERT MAIN TABLE */
		INSERT INTO ##TmpSrcTable
		SELECT 1, SourceTable 
		FROM MetaDynamicScreenField A
		INNER JOIN
			(SELECT MIN(ControlID) ControlID	FROM MetaDynamicScreenField  
					WHERE MenuID=@MenuID AND  BaseColumnType='BASE' 
					AND ISNULL(ParentcontrolID,0)= CASE WHEN @TabID > 0 THEN @TabID ELSE ISNULL(ParentcontrolID,0) END
					AND ValidCode='Y'
				 ) B
				ON A.ControlID=B.ControlID
				AND A.MenuID=@MenuID
				AND ISNULL(ParentcontrolID,0)= CASE WHEN @TabID > 0 THEN @TabID ELSE ISNULL(ParentcontrolID,0) END
				AND ValidCode='Y'


		/* FIND AND INSERT OTHER TABLES */
		INSERT INTO ##TmpSrcTable
		SELECT 1+ROW_NUMBER() OVER (ORDER BY SourceTable),SourceTable  
		FROM ##TmpData WHERE SourceTable NOT IN (SELECT SourceTable FROM ##TmpSrcTable)
			GROUP BY SourceTable

		/* DELETE RECORDS FOR SOURCE TABLE COLUM IS NULL*/
		DELETE ##TmpSrcTable WHERE SourceTable IS NULL

		
		/*	LOOP FIR MULTIPLI TABLE INSERT	*/		
	--select * from ##TmpSrcTable
		DECLARE @RowId TINYINT=1
		WHILE @RowId<=(SELECT COUNT(1) FROM ##TmpSrcTable)
			BEGIN		
				SELECT  @SourceTableName = SourceTable FROM ##TmpSrcTable WHERE RowId=@RowId
				
				/*PREPARING DATA FOR INSERT/UPDATE	*/
				
				/*merging of columns using in the table find in loop*/
				SELECT @ColName= STUFF((SELECT ',' +ControlName 
					FROM ##TmpData M1
						WHERE SourceTable=@SourceTableName
					FOR XML PATH('')),1,1,'')   
					FROM ##TmpData M2
			
				/*merging of data value  using in the table find in loop*/
				SELECT @DataVal = STUFF((SELECT ',''' +DataVal +''''
					FROM ##TmpData M1
						WHERE SourceTable= @SourceTableName
					FOR XML PATH('')),1,1,'')   
					FROM ##TmpData M2

				--SELECT * FROM ##TmpData		

				--SELECT @DataVal,@ColName
				
		

				/*merging of Columns with data value  using in the table find in loop*/
				IF @OperationFlag=2
					BEGIN
						SELECT @ColName_DataVal = STUFF((SELECT ',' +ControlName +'='''+ DataVal+''''
								FROM ##TmpData M1
									WHERE SourceTable= @SourceTableName
								FOR XML PATH('')),1,1,'')   
								FROM ##TmpData M2
					END
			
	
			/* Finding and Prepareing the Base column as Parent for Other Associated tables*/
			IF EXISTS (	SELECT  1 from MetaDynamicScreenField where MenuId=@MenuID 
							AND ISNULL(ParentcontrolID,0)= CASE WHEN @TabID > 0 THEN @TabID ELSE ISNULL(ParentcontrolID,0) END
							AND BaseColumnType='PARENT' AND SourceTable=@SourceTableName
							AND ValidCode='Y'
						)
					BEGIN
						IF ISNULL(@ParentColumnValue,'0')='0' 
							SET @ParentColumnValue=@BaseColumnValue
					END
				
			/*Calling of Insert Update SP for refelecting the data in Main/Mod tables*/
			/* Will be call for each table usig for screen*/
			--select @ColName_DataVal
			
			EXEC [MetaDynamicInUp]
					 @ColName 
					,@DataVal
					,@DataValueAuth
					,@ColName_DataVal
					,@BaseColumnValue
					,@ParentColumnValue
					,@SourceTableName
					,@EffectiveFromTimeKey 
					,@EffectiveToTimeKey 
					,@CreateModifyApprovedBy 
					,@OperationFlag 
					,@TimeKey
					,@AuthMode 
					,@MenuID 
					,@TabID 
					,@Remark 
					,@ChangeFields
					,@D2Ktimestamp 
					,@Result OUTPUT
					PRINT 'Completed'
						
				IF @Result=-1 RETURN @Result
				SET @BaseColumnValue=@Result
				SET @RowId=@RowId+1


	END
END
GO