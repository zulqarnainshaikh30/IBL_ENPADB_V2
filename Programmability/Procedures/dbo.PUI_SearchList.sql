SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROC [dbo].[PUI_SearchList]
--Declare
													
													--@PageNo         INT         = 1, 
													--@PageSize       INT         = 10, 
													@OperationFlag  INT         = 2,
													@MenuID	INT=20
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
                 SELECT		 A.CustomerID
                            ,A.UCIFID
        					,A.AccountID
        					,A.AccountEntityID
                            ,A.CustomerName
                            ,A.ProjectCategoryAlt_Key
							,A.ProjectCategoryDesc
                            ,A.ProjectSubCategoryAlt_key
							,A.ProjectCategorySubTypeDesc
							,A.ProjectSubCatDescription
                            ,A.ProjectOwnerShipAlt_Key
							,A.ProjectOwnerShipDesc
                            ,A.ProjectAuthorityAlt_key
							,A.ProjectAuthorityDesc
                            ,A.OriginalDCCO
                            ,A.OriginalProjectCost
                            ,A.OriginalDebt
                            ,A.Debt_EquityRatio
							,A.AuthorisationStatus 
                            ,A.EffectiveFromTimeKey 
                            ,A.EffectiveToTimeKey
                            ,A.CreatedBy 
                            ,A.DateCreated 
                            ,A.ApprovedBy 
                            ,A.DateApproved
                            ,A.ModifiedBy 
                            ,A.DateModified
							,A.CrModBy
							,A.CrModDate
							,A.CrAppBy
							,A.CrAppDate
							,A.ModAppBy
							,A.ModAppDate
                 INTO #temp
                 FROM 
                 (
                     SELECT 
							 A.CustomerID
                            ,A.UCIFID
        					,A.AccountID
        					,A.AccountEntityID
                            ,A.CustomerName
                            ,A.ProjectCategoryAlt_Key
							--,PC.ProjectCategoryDescription  ProjectCategoryDesc
							,case when A.ProjectCategoryAlt_Key=1 then 'CRE / CRE-RH'
							      when A.ProjectCategoryAlt_Key=2 then 'Infra'
								  when A.ProjectCategoryAlt_Key=3 then 'Non-Infra'
								  ELSE '' END AS  ProjectCategoryDesc
							       
							       
                            ,A.ProjectSubCategoryAlt_key

							,PCS.ProjectCategorySubTypeDescription  ProjectCategorySubTypeDesc
							,A.ProjectSubCatDescription
							,A.ProjectOwnerShipAlt_Key
                            , case when ProjectOwnerShipAlt_Key =1 then 'Private' 
							       when   ProjectOwnerShipAlt_Key=2 then 'Public'
								   when    ProjectOwnerShipAlt_Key=3 then 'Public-Private' 
								   else '' end as      ProjectOwnerShipDesc
                            ,A.ProjectAuthorityAlt_key
							,case when ProjectAuthorityAlt_key=1 then 'NA'
							      when ProjectAuthorityAlt_key=2 then 'NHAI'
								  when ProjectAuthorityAlt_key=3 then 'HUDCO'
								  when ProjectAuthorityAlt_key=4 then 'Others'
								  else '' end as ProjectAuthorityDesc
                            ,convert(varchar(20),A.OriginalDCCO,103) OriginalDCCO
                            ,A.OriginalProjectCost
                            ,A.OriginalDebt
                            ,A.Debt_EquityRatio
							,isnull(A.AuthorisationStatus, 'A') AuthorisationStatus
                            ,A.EffectiveFromTimeKey 
                            ,A.EffectiveToTimeKey 
                            ,A.CreatedBy 
                            ,A.DateCreated
                            ,A.ApprovedBy 
                            ,A.DateApproved 
                            ,A.ModifiedBy 
                            ,A.DateModified
							,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.FirstLevelApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.FirstLevelDateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.FirstLevelApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.FirstLevelDateApproved,A.DateModified) as ModAppDate
                     FROM AdvAcPUIDetailMain A
					  inner join ProjectCategory PC     on PC.ProjectCategoryAltKey=A.ProjectCategoryAlt_Key
                                                       
										                and PC.EffectiveFromTimeKey<=@Timekey and PC.EffectiveToTimeKey>=@Timekey
                      LEFT join ProjectCategorySubType PCS   on PCS.ProjectCategorySubTypeAltKey=A.ProjectSubCategoryAlt_key
                                                             AND PC.ProjectCategoryAltKey=PCS.ProjectCategoryTypeAltKey
											                 and PCS.EffectiveFromTimeKey<=@Timekey and PCS.EffectiveToTimeKey>=@Timekey
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
                     UNION
                     SELECT  A.CustomerID
                            ,A.UCIFID
        					,A.AccountID
        					,A.AccountEntityID
                            ,A.CustomerName
                             ,A.ProjectCategoryAlt_Key
							,case when A.ProjectCategoryAlt_Key=1 then 'CRE / CRE-RH'
							      when A.ProjectCategoryAlt_Key=2 then 'Infra'
								  when A.ProjectCategoryAlt_Key=3 then 'Non-Infra'
								  ELSE '' END AS  ProjectCategoryDesc
                            ,A.ProjectSubCategoryAlt_key
							,PCS.ProjectCategorySubTypeDescription  ProjectCategorySubTypeDesc
							,A.ProjectSubCatDescription
							,A.ProjectOwnerShipAlt_Key
                            , case when ProjectOwnerShipAlt_Key =1 then 'Private' 
							       when   ProjectOwnerShipAlt_Key=2 then 'Public'
								   when    ProjectOwnerShipAlt_Key=3 then 'Public-Private' 
								   else '' end as      ProjectOwnerShipDesc
                            ,A.ProjectAuthorityAlt_key
							,case when ProjectAuthorityAlt_key=1 then 'NA'
							      when ProjectAuthorityAlt_key=2 then 'NHAI'
								  when ProjectAuthorityAlt_key=3 then 'HUDCO'
								  when ProjectAuthorityAlt_key=4 then 'Others'
								  else '' end as ProjectAuthorityDesc
                            ,convert(varchar(20),A.OriginalDCCO,103) OriginalDCCO
                            ,A.OriginalProjectCost
                            ,A.OriginalDebt
                            ,A.Debt_EquityRatio,
							isnull(A.AuthorisationStatus, 'A') AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified
							--,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							--,IsNull(A.DateModified,A.DateCreated)as CrModDate
							--,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							--,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							--,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							--,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
							,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.FirstLevelApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.FirstLevelDateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.FirstLevelApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.FirstLevelDateApproved,A.DateModified) as ModAppDate
                     FROM AdvAcPUIDetailMain_Mod A
					   inner join ProjectCategory PC     on PC.ProjectCategoryAltKey=A.ProjectCategoryAlt_Key
                                                       
										                and PC.EffectiveFromTimeKey<=@Timekey and PC.EffectiveToTimeKey>=@Timekey
                      LEFT join ProjectCategorySubType PCS   on PCS.ProjectCategorySubTypeAltKey=A.ProjectSubCategoryAlt_key
                                                             AND PC.ProjectCategoryAltKey=PCS.ProjectCategoryTypeAltKey
											                 and PCS.EffectiveFromTimeKey<=@Timekey and PCS.EffectiveToTimeKey>=@Timekey
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                           AND A.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                       FROM AdvAcPUIDetailMain_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')
                         GROUP BY EntityKey
                     )
                 ) A 
                      
                 
                 GROUP BY   A.CustomerID
                            ,A.UCIFID
        					,A.AccountID
        					,A.AccountEntityID
                            ,A.CustomerName
                            ,A.ProjectCategoryAlt_Key
							,A.ProjectCategoryDesc
                            ,A.ProjectSubCategoryAlt_key
							,A.ProjectCategorySubTypeDesc
							,A.ProjectSubCatDescription
                            ,A.ProjectOwnerShipAlt_Key
							,A.ProjectOwnerShipDesc
                            ,A.ProjectAuthorityAlt_key
							,A.ProjectAuthorityDesc
                            ,A.OriginalDCCO
                            ,A.OriginalProjectCost
                            ,A.OriginalDebt
                            ,A.Debt_EquityRatio,
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
							A.ModAppDate,
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate;

                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY ProjectCategoryAlt_Key) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'PUI' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp A
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner
             
             END;
             ELSE

			 /*  IT IS Used For GRID Search which are Pending for Authorization    */
			 IF (@OperationFlag in(16,17))

             BEGIN
			 IF OBJECT_ID('TempDB..#temp16') IS NOT NULL
                 DROP TABLE #temp16;
                 SELECT   A.CustomerID
                            ,A.UCIFID
        					,A.AccountID
        					,A.AccountEntityID
                            ,A.CustomerName
                            ,A.ProjectCategoryAlt_Key
							,A.ProjectCategoryDesc
                            ,A.ProjectSubCategoryAlt_key
							,A.ProjectCategorySubTypeDesc
							,A.ProjectSubCatDescription
                            ,A.ProjectOwnerShipAlt_Key
							,A.ProjectOwnerShipDesc
                            ,A.ProjectAuthorityAlt_key
							,A.ProjectAuthorityDesc
                            ,A.OriginalDCCO
                            ,A.OriginalProjectCost
                            ,A.OriginalDebt
                            ,A.Debt_EquityRatio,
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
                     SELECT  A.CustomerID
                            ,A.UCIFID
        					,A.AccountID
        					,A.AccountEntityID
                            ,A.CustomerName
                             ,A.ProjectCategoryAlt_Key
							,case when A.ProjectCategoryAlt_Key=1 then 'CRE / CRE-RH'
							      when A.ProjectCategoryAlt_Key=2 then 'Infra'
								  when A.ProjectCategoryAlt_Key=3 then 'Non-Infra'
								  ELSE '' END AS  ProjectCategoryDesc
                            ,A.ProjectSubCategoryAlt_key
							,PCS.ProjectCategorySubTypeDescription  ProjectCategorySubTypeDesc
							,A.ProjectSubCatDescription
							,A.ProjectOwnerShipAlt_Key
                            , case when ProjectOwnerShipAlt_Key =1 then 'Private' 
							       when   ProjectOwnerShipAlt_Key=2 then 'Public'
								   when    ProjectOwnerShipAlt_Key=3 then 'Public-Private' 
								   else '' end as      ProjectOwnerShipDesc
                            ,A.ProjectAuthorityAlt_key
							,case when ProjectAuthorityAlt_key=1 then 'NA'
							      when ProjectAuthorityAlt_key=2 then 'NHAI'
								  when ProjectAuthorityAlt_key=3 then 'HUDCO'
								  when ProjectAuthorityAlt_key=4 then 'Others'
								  else '' end as ProjectAuthorityDesc
                            ,convert(varchar(20),A.OriginalDCCO,103) OriginalDCCO
                            ,A.OriginalProjectCost
                            ,A.OriginalDebt
                            ,A.Debt_EquityRatio,
							isnull(A.AuthorisationStatus, 'A') AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified
							--,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							--,IsNull(A.DateModified,A.DateCreated)as CrModDate
							--,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							--,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							--,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							--,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
							,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.FirstLevelApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.FirstLevelDateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.FirstLevelApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.FirstLevelDateApproved,A.DateModified) as ModAppDate
                     FROM AdvAcPUIDetailMain_Mod A
					   inner join ProjectCategory PC     on PC.ProjectCategoryAltKey=A.ProjectCategoryAlt_Key
                                                       
										                and PC.EffectiveFromTimeKey<=@Timekey and PC.EffectiveToTimeKey>=@Timekey
                      LEFT join ProjectCategorySubType PCS   on PCS.ProjectCategorySubTypeAltKey=A.ProjectSubCategoryAlt_key
                                                             AND PC.ProjectCategoryAltKey=PCS.ProjectCategoryTypeAltKey
											                 and PCS.EffectiveFromTimeKey<=@Timekey and PCS.EffectiveToTimeKey>=@Timekey
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                           AND A.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM AdvAcPUIDetailMain_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(A.AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')
							    GROUP BY EntityKey
                     )
                 ) A 
                      
                 
                 GROUP BY   A.CustomerID
                            ,A.UCIFID
        					,A.AccountID
        					,A.AccountEntityID
                            ,A.CustomerName
                            ,A.ProjectCategoryAlt_Key
							,A.ProjectCategoryDesc
                            ,A.ProjectSubCategoryAlt_key
							,A.ProjectCategorySubTypeDesc
							,A.ProjectSubCatDescription
                            ,A.ProjectOwnerShipAlt_Key
							,A.ProjectOwnerShipDesc
                            ,A.ProjectAuthorityAlt_key
							,A.ProjectAuthorityDesc
                            ,A.OriginalDCCO
                            ,A.OriginalProjectCost
                            ,A.OriginalDebt
                            ,A.Debt_EquityRatio,
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
                     SELECT ROW_NUMBER() OVER(ORDER BY ProjectCategoryAlt_Key) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'PUI' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp16 A
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
                 SELECT   A.CustomerID
                            ,A.UCIFID
        					,A.AccountID
        					,A.AccountEntityID
                            ,A.CustomerName
                            ,A.ProjectCategoryAlt_Key
							,A.ProjectCategoryDesc
                            ,A.ProjectSubCategoryAlt_key
							,A.ProjectCategorySubTypeDesc
							,A.ProjectSubCatDescription
                            ,A.ProjectOwnerShipAlt_Key
							,A.ProjectOwnerShipDesc
                            ,A.ProjectAuthorityAlt_key
							,A.ProjectAuthorityDesc
                            ,A.OriginalDCCO
                            ,A.OriginalProjectCost
                            ,A.OriginalDebt
                            ,A.Debt_EquityRatio,
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
                     SELECT  A.CustomerID
                            ,A.UCIFID
        					,A.AccountID
        					,A.AccountEntityID
                            ,A.CustomerName
                             ,A.ProjectCategoryAlt_Key
							,case when A.ProjectCategoryAlt_Key=1 then 'CRE / CRE-RH'
							      when A.ProjectCategoryAlt_Key=2 then 'Infra'
								  when A.ProjectCategoryAlt_Key=3 then 'Non-Infra'
								  ELSE '' END AS  ProjectCategoryDesc
                            ,A.ProjectSubCategoryAlt_key
							,PCS.ProjectCategorySubTypeDescription  ProjectCategorySubTypeDesc
							,A.ProjectSubCatDescription
							,A.ProjectOwnerShipAlt_Key
                            , case when ProjectOwnerShipAlt_Key =1 then 'Private' 
							       when   ProjectOwnerShipAlt_Key=2 then 'Public'
								   when    ProjectOwnerShipAlt_Key=3 then 'Public-Private' 
								   else '' end as      ProjectOwnerShipDesc
                            ,A.ProjectAuthorityAlt_key
							,case when ProjectAuthorityAlt_key=1 then 'NA'
							      when ProjectAuthorityAlt_key=2 then 'NHAI'
								  when ProjectAuthorityAlt_key=3 then 'HUDCO'
								  when ProjectAuthorityAlt_key=4 then 'Others'
								  else '' end as ProjectAuthorityDesc
                            ,convert(varchar(20),A.OriginalDCCO,103) OriginalDCCO
                            ,A.OriginalProjectCost
                            ,A.OriginalDebt
                            ,A.Debt_EquityRatio,
							A.AuthorisationStatus AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified
							--,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							--,IsNull(A.DateModified,A.DateCreated)as CrModDate
							--,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							--,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							--,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							--,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
							,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.FirstLevelApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.FirstLevelDateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.FirstLevelApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.FirstLevelDateApproved,A.DateModified) as ModAppDate
                     FROM AdvAcPUIDetailMain_Mod A
					   inner join ProjectCategory PC     on PC.ProjectCategoryAltKey=A.ProjectCategoryAlt_Key
                                                       
										                and PC.EffectiveFromTimeKey<=@Timekey and PC.EffectiveToTimeKey>=@Timekey
                      LEFT join ProjectCategorySubType PCS   on PCS.ProjectCategorySubTypeAltKey=A.ProjectSubCategoryAlt_key
                                                             AND PC.ProjectCategoryAltKey=PCS.ProjectCategoryTypeAltKey
											                 and PCS.EffectiveFromTimeKey<=@Timekey and PCS.EffectiveToTimeKey>=@Timekey
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           AND ISNULL(A.AuthorisationStatus, 'A') IN('1A')
                           AND A.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM AdvAcPUIDetailMain_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND AuthorisationStatus IN('1A')
                         GROUP BY EntityKey
                     )
                 ) A 
                      
                 
                 GROUP BY   A.CustomerID
                            ,A.UCIFID
        					,A.AccountID
        					,A.AccountEntityID
                            ,A.CustomerName
                            ,A.ProjectCategoryAlt_Key
							,A.ProjectCategoryDesc
                            ,A.ProjectSubCategoryAlt_key
							,A.ProjectCategorySubTypeDesc
							,A.ProjectSubCatDescription
                            ,A.ProjectOwnerShipAlt_Key
							,A.ProjectOwnerShipDesc
                            ,A.ProjectAuthorityAlt_key
							,A.ProjectAuthorityDesc
                            ,A.OriginalDCCO
                            ,A.OriginalProjectCost
                            ,A.OriginalDebt
                            ,A.Debt_EquityRatio,
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
                     SELECT ROW_NUMBER() OVER(ORDER BY ProjectCategoryAlt_Key) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'PUI' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp20 A
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

	select *,'PUICreateProjectStatus' AS tableName from MetaScreenFieldDetail where ScreenName='CreateProjectStatusPUI'
  
  
    END;


GO