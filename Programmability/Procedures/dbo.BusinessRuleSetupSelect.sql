SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:		<Author Triloki Kumar>
-- Create date: <Create Date 13/03/2020>
-- Description:	<Description Business rule setup details select>
-- =============================================
CREATE PROCEDURE [dbo].[BusinessRuleSetupSelect]

@CatAlt_key				INT
,@UserId					Varchar(50)
,@OperationFlag INT
 ,@MenuID  INT  =14613
AS

--declare 
----@Territoryalt_key			INT,
--@CatAlt_key				INT=101
--,@UserId					Varchar(50)='FnaChecker'
--,@OperationFlag INT='20'

Declare @Authlevel InT
 
select @Authlevel=AuthLevel from SysCRisMacMenu  
 where MenuId=@MenuID	

 --select * from SysCRisMacMenu where MenuCaption like '%Business%'


BEGIN
	
	SET NOCOUNT ON;
					IF(@OperationFlag in(16,17))

			BEGIN
   
			IF OBJECT_ID('TEMPDB..#PRODUCTCODE') IS NOT NULL
				DROP TABLE #PRODUCTCODE
				
				SELECT A.UniqueID,Businesscolvalues1 INTO #PRODUCTCODE 
				FROM DimBusinessRuleSetup A
					INNER JOIN DimBusinessRuleCol B
						ON A.Businesscolalt_key=B.BusinessRuleColAlt_Key
					WHERE B.BusinessRuleColDesc='PRODUCTCODE'
					AND A.CatAlt_key=@CatAlt_key
				
				IF OBJECT_ID('TEMPDB..#SplitValue1')IS NOT NULL
					DROP TABLE #SplitValue1	
					SELECT UniqueID, Split.a.value('.', 'VARCHAR(8000)') AS Businesscolvalues1  into #SplitValue1
							FROM  (SELECT 
									CAST ('<M>' + REPLACE(Businesscolvalues1, ',', '</M><M>') + '</M>' AS XML) AS Businesscolvalues1,UniqueID
									from #PRODUCTCODE
								) AS A CROSS APPLY Businesscolvalues1.nodes ('/M') AS Split(a) 

				IF OBJECT_ID('TEMPDB..#TempValue')	IS NOT NULL
					DROP TABLE #TempValue	
		
				SELECT A.UniqueID,B.ProductCode into #TempValue FROM #SplitValue1 A
					INNER JOIN DimGLProduct B
						ON A.Businesscolvalues1=B.GLProductAlt_Key


				IF OBJECT_ID('TEMPDB..#FinalTable1') IS NOT NULL
					DROP TABLE #FinalTable1
					SELECT STUFF(
                         (
                             
							SELECT DISTINCT ','+ProductCode
							from #TempValue a  
							where a.uniqueid=b.uniqueid
							--group by uniqueid
							 FOR XML PATH('')
						 ), 1, 1, '')ProductCode
						 ,b.uniqueid
						INTO #FinalTable1
						from #TempValue b
						group by b.uniqueid


				 

				SELECT 				
				A.BusinessRule_Alt_key
				,A.UniqueID
				,A.Businesscolalt_key
				,B.BusinessRuleColDesc
				,A.Scope SelectScopeAlt_Key
				,C.ParameterName
				,A.Businesscolvalues1  Businesscolvalues1
				,CASE WHEN D.UniqueID IS NOT NULL THEN D.ProductCode ELSE  A.Businesscolvalues1 END Businesscolvalues1_Display
				,A.Businesscolvalues 
				,A.Businesscolvalues ColumnValuesSecAlt_Key
				,A.Businesscolvalues1 + CASE WHEN ISNULL(A.Businesscolvalues, '')<>'' THEN '|' + A.Businesscolvalues ELSE '' END AS BusinesscolvaluesPipe
				--,CASE WHEN D.UniqueID IS NOT NULL THEN D.ProductCode ELSE  A.Businesscolvalues1 END + CASE WHEN ISNULL(A.Businesscolvalues, '')<>'' THEN '|' + A.Businesscolvalues ELSE '' END AS BusinesscolvaluesPipe
				,isnull(A.AuthorisationStatus, 'A') AuthorisationStatus
				,A.CreatedBy
				,convert(varchar(20),A.DateCreated) DateCreated
				,A.ApprovedBy
				,convert(varchar(20),A.DateApproved) DateApproved
				,A.ModifiedBy
				,convert(varchar(20),A.DateModified) DateModified

				,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
							,'BusinessGridData'  AS TableName
			 FROM DIMBusinessRuleSetup_Mod A
				INNER JOIN DimBusinessRuleCol B
					ON A.Businesscolalt_key=B.BusinessRuleColAlt_Key
				INNER JOIN DimParameter C
					ON C.ParameterAlt_Key=A.Scope
					AND C.DimParameterName='DimScopeType'
				LEFT JOIN #FinalTable1 D
					ON D.UniqueID=A.UniqueID
				WHERE 
				--A.Territoryalt_key=@Territoryalt_key
				--AND 
				A.CatAlt_key=@CatAlt_key
				AND A.EntityKey IN
				(
                         SELECT MAX(EntityKey)
           FROM DIMBusinessRuleSetup_Mod
                         WHERE EffectiveFromTimeKey <= 49999
                               AND EffectiveToTimeKey >= 49999
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')
                         GROUP BY BusinessRule_Alt_key
                     )
				order by A.UniqueID
		END


IF(@OperationFlag not in(16,17,20))

			BEGIN
			 print 'go'

			 
			IF EXISTS(SELECT 1 FROM DimProvision_SegStd_Mod where BankCategoryID=@CatAlt_key
			 AND AuthorisationStatus in ('NP','MP'))
			BEGIN
			print'00'
			DECLARE @Result int

			SET @Result=1 
			
			END
			ELSE 
			Begin
			SET @Result=0 
			END
			SELECT @Result as Result
			
   
			IF OBJECT_ID('TEMPDB..#PRODUCTCODE16') IS NOT NULL
				DROP TABLE #PRODUCTCODE16
				
				SELECT A.UniqueID,Businesscolvalues1 INTO #PRODUCTCODE16 
				FROM DimBusinessRuleSetup A
					INNER JOIN DimBusinessRuleCol B
						ON A.Businesscolalt_key=B.BusinessRuleColAlt_Key
					WHERE B.BusinessRuleColDesc='PRODUCTCODE'
					AND A.CatAlt_key=@CatAlt_key
				
				IF OBJECT_ID('TEMPDB..#SplitValue16')IS NOT NULL
					DROP TABLE #SplitValue16	
					SELECT UniqueID, Split.a.value('.', 'VARCHAR(8000)') AS Businesscolvalues1  into #SplitValue16
							FROM  (SELECT 
									CAST ('<M>' + REPLACE(Businesscolvalues1, ',', '</M><M>') + '</M>' AS XML) AS Businesscolvalues1,UniqueID
									from #PRODUCTCODE16
								) AS A CROSS APPLY Businesscolvalues1.nodes ('/M') AS Split(a) 

				IF OBJECT_ID('TEMPDB..#TempValue16')	IS NOT NULL
					DROP TABLE #TempValue16
		
				SELECT A.UniqueID,B.ProductCode into #TempValue16 FROM #SplitValue16 A
					INNER JOIN DimGLProduct B
						ON A.Businesscolvalues1=B.GLProductAlt_Key


				IF OBJECT_ID('TEMPDB..#FinalTable16') IS NOT NULL
					DROP TABLE #FinalTable16
					SELECT STUFF(
                         (
                             
							SELECT DISTINCT ','+ProductCode
							from #TempValue16 a  
							where a.uniqueid=b.uniqueid
							--group by uniqueid
							 FOR XML PATH('')
						 ), 1, 1, '')ProductCode
						 ,b.uniqueid
						INTO #FinalTable16
						from #TempValue16 b
						group by b.uniqueid


				 

			 SELECT 				
				A.BusinessRule_Alt_key
				,A.UniqueID
				,A.Businesscolalt_key
				,B.BusinessRuleColDesc
				,A.Scope SelectScopeAlt_Key
				,C.ParameterName
				,A.Businesscolvalues1  Businesscolvalues1
				,CASE WHEN D.UniqueID IS NOT NULL THEN D.ProductCode ELSE  A.Businesscolvalues1 END Businesscolvalues1_Display
				,A.Businesscolvalues 
				,A.Businesscolvalues ColumnValuesSecAlt_Key
				,A.Businesscolvalues1 + CASE WHEN ISNULL(A.Businesscolvalues, '')<>'' THEN '|' + A.Businesscolvalues ELSE '' END AS BusinesscolvaluesPipe
				--,CASE WHEN D.UniqueID IS NOT NULL THEN D.ProductCode ELSE  A.Businesscolvalues1 END + CASE WHEN ISNULL(A.Businesscolvalues, '')<>'' THEN '|' + A.Businesscolvalues ELSE '' END AS BusinesscolvaluesPipe
				,isnull(A.AuthorisationStatus, 'A') AuthorisationStatus
				,A.CreatedBy
				,convert(varchar(20),A.DateCreated) DateCreated
				,A.ApprovedBy
				,convert(varchar(20),A.DateApproved) DateApproved
				,A.ModifiedBy
				,convert(varchar(20),A.DateModified) DateModified

				,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
				,'BusinessGridData'  AS TableName
			 FROM DIMBusinessRuleSetup A
				INNER JOIN DimBusinessRuleCol B
					ON A.Businesscolalt_key=B.BusinessRuleColAlt_Key
				INNER JOIN DimParameter C
					ON C.ParameterAlt_Key=A.Scope
					AND C.DimParameterName='DimScopeType'
				LEFT JOIN #FinalTable16 D
					ON D.UniqueID=A.UniqueID
				WHERE 
				--A.Territoryalt_key=@Territoryalt_key
				--AND 
				A.CatAlt_key=@CatAlt_key
				AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
				--order by a.UniqueID

				UNION

				SELECT 				
				A.BusinessRule_Alt_key
				,A.UniqueID
				,A.Businesscolalt_key
				,B.BusinessRuleColDesc
				,A.Scope SelectScopeAlt_Key
				,C.ParameterName
				,A.Businesscolvalues1  Businesscolvalues1
				,CASE WHEN D.UniqueID IS NOT NULL THEN D.ProductCode ELSE  A.Businesscolvalues1 END Businesscolvalues1_Display
				,A.Businesscolvalues 
				,A.Businesscolvalues ColumnValuesSecAlt_Key
				,A.Businesscolvalues1 + CASE WHEN ISNULL(A.Businesscolvalues, '')<>'' THEN '|' + A.Businesscolvalues ELSE '' END AS BusinesscolvaluesPipe
				--,CASE WHEN D.UniqueID IS NOT NULL THEN D.ProductCode ELSE  A.Businesscolvalues1 END + CASE WHEN ISNULL(A.Businesscolvalues, '')<>'' THEN '|' + A.Businesscolvalues ELSE '' END AS BusinesscolvaluesPipe
				,isnull(A.AuthorisationStatus, 'A') AuthorisationStatus
				,A.CreatedBy
				,convert(varchar(20),A.DateCreated) DateCreated
				,A.ApprovedBy
				,convert(varchar(20),A.DateApproved) DateApproved
				,A.ModifiedBy
				,convert(varchar(20),A.DateModified) DateModified

				,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
							,'BusinessGridData'  AS TableName
			 FROM DIMBusinessRuleSetup_Mod A
				INNER JOIN DimBusinessRuleCol B
					ON A.Businesscolalt_key=B.BusinessRuleColAlt_Key
				INNER JOIN DimParameter C
					ON C.ParameterAlt_Key=A.Scope
					AND C.DimParameterName='DimScopeType'
				LEFT JOIN #FinalTable16 D
					ON D.UniqueID=A.UniqueID
				WHERE 
				--A.Territoryalt_key=@Territoryalt_key
				--AND 
				A.CatAlt_key=@CatAlt_key
				AND A.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM DIMBusinessRuleSetup_Mod
                         WHERE EffectiveFromTimeKey <= 49999
                               AND EffectiveToTimeKey >= 49999
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')
                         GROUP BY BusinessRule_Alt_key
                     )
				order by a.UniqueID
		END


				SELECT Expression,SystemFinalExpression,UserFinalExpression, 'ExpressionSelect' TableName FROM DimProvision_SegStd_Mod WHERE 
				--ProvisionAlt_Key=@CatAlt_key AND EffectiveToTimeKey=49999
				BankCategoryID=@CatAlt_key AND EffectiveToTimeKey=49999
				AND isnull(Expression,'')<>''
         
END;


IF(@OperationFlag in(20))

			BEGIN
IF OBJECT_ID('TEMPDB..#PRODUCTCODE20') IS NOT NULL
				DROP TABLE #PRODUCTCODE20
				
				SELECT A.UniqueID,Businesscolvalues1 INTO #PRODUCTCODE20 
				FROM DimBusinessRuleSetup A
					INNER JOIN DimBusinessRuleCol B
						ON A.Businesscolalt_key=B.BusinessRuleColAlt_Key
					WHERE B.BusinessRuleColDesc='PRODUCTCODE'
					AND A.CatAlt_key=@CatAlt_key
				
				IF OBJECT_ID('TEMPDB..#SplitValue20')IS NOT NULL
					DROP TABLE #SplitValue20	
					SELECT UniqueID, Split.a.value('.', 'VARCHAR(8000)') AS Businesscolvalues1  into #SplitValue20
							FROM  (SELECT 
									CAST ('<M>' + REPLACE(Businesscolvalues1, ',', '</M><M>') + '</M>' AS XML) AS Businesscolvalues1,UniqueID
									from #PRODUCTCODE20
								) AS A CROSS APPLY Businesscolvalues1.nodes ('/M') AS Split(a) 

				IF OBJECT_ID('TEMPDB..#TempValue20')	IS NOT NULL
					DROP TABLE #TempValue20
		
				SELECT A.UniqueID,B.ProductCode into #TempValue20 FROM #SplitValue20 A
					INNER JOIN DimGLProduct B
						ON A.Businesscolvalues1=B.GLProductAlt_Key


				IF OBJECT_ID('TEMPDB..#FinalTable20') IS NOT NULL
					DROP TABLE #FinalTable20
					SELECT STUFF(
                    (
                             
							SELECT DISTINCT ','+ProductCode
							from #TempValue20 a  
							where a.uniqueid=b.uniqueid
							--group by uniqueid
							 FOR XML PATH('')
						 ), 1, 1, '')ProductCode
						 ,b.uniqueid
						INTO #FinalTable20
						from #TempValue20 b
						group by b.uniqueid
--print 'AA'
				SELECT 				
				A.BusinessRule_Alt_key
				,A.UniqueID
				,A.Businesscolalt_key
				,B.BusinessRuleColDesc
				,A.Scope SelectScopeAlt_Key
				,C.ParameterName
				,A.Businesscolvalues1  Businesscolvalues1
				,CASE WHEN D.UniqueID IS NOT NULL THEN D.ProductCode ELSE  A.Businesscolvalues1 END Businesscolvalues1_Display
				,A.Businesscolvalues 
				,A.Businesscolvalues ColumnValuesSecAlt_Key
				,A.Businesscolvalues1 + CASE WHEN ISNULL(A.Businesscolvalues, '')<>'' THEN '|' + A.Businesscolvalues ELSE '' END AS BusinesscolvaluesPipe
				--,CASE WHEN D.UniqueID IS NOT NULL THEN D.ProductCode ELSE  A.Businesscolvalues1 END + CASE WHEN ISNULL(A.Businesscolvalues, '')<>'' THEN '|' + A.Businesscolvalues ELSE '' END AS BusinesscolvaluesPipe
				,isnull(A.AuthorisationStatus, 'A') AuthorisationStatus
				,A.CreatedBy
				,convert(varchar(20),A.DateCreated) DateCreated
				,A.ApprovedBy
				,convert(varchar(20),A.DateApproved) DateApproved
				,A.ModifiedBy
				,convert(varchar(20),A.DateModified) DateModified

				,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate

							,'BusinessGridData'  AS TableName
			 FROM DIMBusinessRuleSetup_Mod A
				INNER JOIN DimBusinessRuleCol B
					ON A.Businesscolalt_key=B.BusinessRuleColAlt_Key
				INNER JOIN DimParameter C
					ON C.ParameterAlt_Key=A.Scope
					AND C.DimParameterName='DimScopeType'
				LEFT JOIN #FinalTable20 D
					ON D.UniqueID=A.UniqueID
				WHERE 
				--A.Territoryalt_key=@Territoryalt_key
				--AND 
				A.CatAlt_key=@CatAlt_key
				AND A.EntityKey IN
				(
                         SELECT MAX(EntityKey)
                         FROM DIMBusinessRuleSetup_Mod
                         WHERE EffectiveFromTimeKey <= 49999
                               AND EffectiveToTimeKey >= 49999
                               --AND ISNULL(AuthorisationStatus, 'A') IN('1A')
							    AND (case when @AuthLevel =2  AND ISNULL(AuthorisationStatus, 'A') IN('1A')
										THEN 1 
							           when @AuthLevel =1 AND ISNULL(AuthorisationStatus,'A') IN ('NP','MP','DP')
										THEN 1
										ELSE 0									
										END
									)=1
                         GROUP BY BusinessRule_Alt_key
                     )
				order by A.UniqueID
		END

	


GO