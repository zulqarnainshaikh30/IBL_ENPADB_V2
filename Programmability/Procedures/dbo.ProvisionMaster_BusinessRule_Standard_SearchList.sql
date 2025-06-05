SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
Create PROC [dbo].[ProvisionMaster_BusinessRule_Standard_SearchList] 
--Declare
													
													--@PageNo         INT         = 1, 
													--@PageSize       INT         = 10, 
													@OperationFlag  INT         = 20
AS
     
	 BEGIN

SET NOCOUNT ON;
Declare @TimeKey as Int
	SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')
					

BEGIN TRY

/*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */

			IF(@OperationFlag not in (16,17,20))
             BEGIN
			 IF OBJECT_ID('TempDB..#temp') IS NOT NULL
                 DROP TABLE  #temp;
                 SELECT		A.Code,
							A.BankCategoryID,
						    A.AssetCategory,
							A.CategoryType,
							A.CategoryTypeAlt_Key,
							A.[ProvisionPrcntRBINorms],
							A.AdditionalBanksProvision,
							A.[AdditionalProvisionPrcntBankNorms],  
							A.AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified,
							A.BusinessRuleAuthPending,
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate
							
                 INTO #temp
                 FROM 
                 (
                     SELECT 
							A.ProvisionAlt_Key as Code,
							A.BankCategoryID,
						    A.ProvisionName as AssetCategory,
							B.ParameterName as CategoryType,
							A.CategoryTypeAlt_Key,
							A.ProvisionSecured  as [ProvisionPrcntRBINorms],
							A.AdditionalBanksProvision,
							A.AdditionalprovisionRBINORMS  as [AdditionalProvisionPrcntBankNorms],
							isnull(A.AuthorisationStatus, 'A') AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified
							,(Case When D.AuthorisationStatus in ('NP','MP') THEN 1 else 0 END )as BusinessRuleAuthPending
							,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
							 
                --select * from  DimProvision_SegStd  
				FROM DimProvision_SegStd A
				Left join(select max(AuthorisationStatus)AuthorisationStatus,CatAlt_key from DIMBusinessRuleSetup_Mod 
				where AuthorisationStatus in ('NP','MP') And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
				group by CatAlt_key)D 
				on D.CatAlt_key=A.BankCategoryID
				Inner Join (Select ParameterAlt_Key,ParameterName,'CategoryType' as Tablename 
						  from DimParameter where DimParameterName='Category Type'
						   And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)B
						  ON A.CategoryTypeAlt_Key=B.ParameterAlt_Key
					 WHERE A.EffectiveFromTimeKey <= @TimeKey  AND A.EffectiveToTimeKey >= @TimeKey
                           AND ISNULL(A.AuthorisationStatus, 'A') = 'A' 
						    
						   --AND ProvisionName NOT IN  ('Sub Standard','Sub Standard Infrastructure'
						   --,'Sub Standard Ab initio Unsecured','Doubtful-I','Doubtful-II','Doubtful-III','Loss')  
						   
				  UNION
                     SELECT A.ProvisionAlt_Key as Code,
							A.BankCategoryID,
						    A.ProvisionName as AssetCategory,
							B.ParameterName as CategoryType,
							A.CategoryTypeAlt_Key,
							A.ProvisionSecured  as [ProvisionPrcntRBINorms],
							A.AdditionalBanksProvision,
							A.AdditionalprovisionRBINORMS  as [AdditionalProvisionPrcntBankNorms],
							isnull(A.AuthorisationStatus, 'A') AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified
							,(Case When D.AuthorisationStatus in ('NP','MP') THEN 1 else 0 END )as BusinessRuleAuthPending
							,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
							
                     FROM DimProvision_SegStd_Mod A
					 left join  (select max(AuthorisationStatus)AuthorisationStatus,CatAlt_key from DIMBusinessRuleSetup_Mod 
				where AuthorisationStatus in ('NP','MP') And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
				group by CatAlt_key) D on D.CatAlt_key=A.BankCategoryID
					 Inner Join (Select ParameterAlt_Key,ParameterName,'CategoryType' as Tablename 
						  from DimParameter where DimParameterName='Category Type'
						  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)B
						  ON A.CategoryTypeAlt_Key=B.ParameterAlt_Key
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey 
						   --and D.EffectiveFromTimeKey <= @TimeKey AND D.EffectiveToTimeKey >= @TimeKey
                         
                           AND A.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM DimProvision_SegStd_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')
                         GROUP BY ProvisionAlt_Key
                     )
                 ) A 
                      
                 
                 GROUP BY   A.Code,
							A.BankCategoryID,
						    A.AssetCategory,
							A.CategoryType,
							A.CategoryTypeAlt_Key,
							A.[ProvisionPrcntRBINorms],
							A.AdditionalBanksProvision,
							A.[AdditionalProvisionPrcntBankNorms],
							A.AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified,
							A.BusinessRuleAuthPending,
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate;

                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY Code) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'ProvisionMaster' TableName, 
                            *
                     FROM
                     (
                         SELECT *
						 --(Case When D.AuthorisationStatus in ('NP','MP') THEN 1 else 0 END )as result
                         FROM #temp A where CategoryTypeAlt_Key=1
						  --left join  DIMBusinessRuleSetup_Mod D on D.CatAlt_key=A.BankCategoryID
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
						-- where  D.EffectiveFromTimeKey <= @TimeKey AND D.EffectiveToTimeKey >= @TimeKey
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
                 --      AND RowNumber <= (@PageNo * @PageSize);

             END;
             ELSE

		
			 /*  IT IS Used For GRID Search which are Pending for Authorization    */

			 IF(@OperationFlag in (16,17))

             BEGIN
			 IF OBJECT_ID('TempDB..#temp16') IS NOT NULL
                 DROP TABLE #temp16;
                 SELECT     A.Code,
							A.BankCategoryID,
						    A.AssetCategory,
							A.CategoryType,
							A.CategoryTypeAlt_Key,
							A.[ProvisionPrcntRBINorms],
							A.AdditionalBanksProvision,
							A.[AdditionalProvisionPrcntBankNorms],
							A.AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified,
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate
							
                 INTO #temp16
                 FROM 
                 (
                     SELECT A.ProvisionAlt_Key as Code,
							A.BankCategoryID,
						    A.ProvisionName as AssetCategory,
							B.ParameterName as CategoryType,
							A.CategoryTypeAlt_Key,
							A.ProvisionSecured  as [ProvisionPrcntRBINorms],
							A.AdditionalBanksProvision,
							A.AdditionalprovisionRBINORMS  as [AdditionalProvisionPrcntBankNorms],
							isnull(A.AuthorisationStatus, 'A') AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified
							,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
							
                     FROM DimProvision_SegStd_Mod A
					 Inner Join (Select ParameterAlt_Key,ParameterName,'CategoryType' as Tablename 
						  from DimParameter where DimParameterName='Category Type'
						  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)B
						  ON A.CategoryTypeAlt_Key=B.ParameterAlt_Key
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           
                           AND A.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM DimProvision_SegStd_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')
                         GROUP BY ProvisionAlt_Key
                     )
                 ) A 
                      
                 
                 GROUP BY A.Code,
							A.BankCategoryID,
						    A.AssetCategory,
							A.CategoryType,
							A.CategoryTypeAlt_Key,
							A.[ProvisionPrcntRBINorms],
							A.AdditionalBanksProvision,
							A.[AdditionalProvisionPrcntBankNorms],
							A.AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified,
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate
							
                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY Code) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'ProvisionMaster' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp16 A  where CategoryTypeAlt_Key=1
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
                 --      AND RowNumber <= (@PageNo * @PageSize)

   END;

   Else

   IF (@OperationFlag =20)
             BEGIN
			 IF OBJECT_ID('TempDB..#temp20') IS NOT NULL
                 DROP TABLE #temp20;
                 SELECT A.Code,
							A.BankCategoryID,
						    A.AssetCategory,
							A.CategoryType,
							A.CategoryTypeAlt_Key,
							A.[ProvisionPrcntRBINorms],
							A.AdditionalBanksProvision,
							A.[AdditionalProvisionPrcntBankNorms],
							A.AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified,
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate
                 INTO #temp20
                 FROM 
                 (
                     SELECT A.ProvisionAlt_Key as Code,
							A.BankCategoryID,
						    A.ProvisionName as AssetCategory,
							B.ParameterName as CategoryType,
							A.CategoryTypeAlt_Key,
							A.ProvisionSecured  as [ProvisionPrcntRBINorms],
							A.AdditionalBanksProvision,
							A.AdditionalprovisionRBINORMS  as [AdditionalProvisionPrcntBankNorms],
							--isnull(A.AuthorisationStatus, 'A') 
							A.AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified
							,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate

                     FROM DimProvision_SegStd_Mod A
					 Inner Join (Select ParameterAlt_Key,ParameterName,'CategoryType' as Tablename 
						  from DimParameter where DimParameterName='Category Type'
						  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)B
						  ON A.CategoryTypeAlt_Key=B.ParameterAlt_Key
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
					       AND ISNULL(AuthorisationStatus, 'A') IN('1A')
                           AND A.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM DimProvision_SegStd_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND AuthorisationStatus IN('1A')
                         GROUP BY ProvisionAlt_Key
                     )
                 ) A 
                      
                 
                 GROUP BY A.Code,
							A.BankCategoryID,
						    A.AssetCategory,
							A.CategoryType,
							A.CategoryTypeAlt_Key,
							A.[ProvisionPrcntRBINorms],
							A.AdditionalBanksProvision,
							A.[AdditionalProvisionPrcntBankNorms],
							A.AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified,
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate
                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY Code) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'ProvisionMaster' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp20 A   where CategoryTypeAlt_Key=1
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
                 --      AND RowNumber <= (@PageNo * @PageSize)

   END;

   END TRY
	BEGIN CATCH
	
	INSERT INTO dbo.Error_Log
				SELECT ERROR_LINE() as ErrorLine,ERROR_MESSAGE()ErrorMessage,ERROR_NUMBER()ErrorNumber
				,ERROR_PROCEDURE()ErrorProcedure,ERROR_SEVERITY()ErrorSeverity,ERROR_STATE()ErrorState
				,GETDATE()

	SELECT ERROR_MESSAGE()
	--RETURN -1
   
	END CATCH


  
  
    END;
GO