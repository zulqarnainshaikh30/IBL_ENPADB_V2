SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROC [dbo].[DimBranch_MasterSearchList] 
--Declare
--@PageNo         INT         = 1, 
--@PageSize       INT         = 10, 
 @OperationFlag  INT         = 16
,@MenuID  INT  =14553
AS
BEGIN

SET NOCOUNT ON;
Declare @TimeKey as Int
	SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C') --26959
					
Declare @Authlevel InT 
	select @Authlevel=AuthLevel from SysCRisMacMenu  where MenuId=@MenuID
  --select * from 	SysCRisMacMenu where menucaption like '%Branch%'
BEGIN TRY

/*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */

IF(@OperationFlag not in (16,17,20))
 BEGIN
 IF OBJECT_ID('TempDB..#temp') IS NOT NULL
 DROP TABLE  #temp;
    SELECT		
	A.BranchAlt_Key,
    A.BranchCode,
    A.BranchName,
    A.Address1,
    A.Address2,
    A.Address3,
    A.DistrictAlt_Key,
    A.DistrictName,
    A.StateAlt_Key,
    A.StateName,
    A.PinCode,
    A.CountryAlt_Key,
    A.CountryName,
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
    A.Changefields INTO #temp
    FROM 
     (
     SELECT 
	 A.BranchAlt_Key,
     A.BranchCode,
     A.BranchName,
     A.Add_1 as Address1,
     A.Add_2 as Address2,
     A.Add_3 as Address3,
     B.DistrictAlt_Key,
     A.BranchDistrictName  as DistrictName,   ----     Previously B.DistrictName Changed by kapil 01/01/2024
     C.StateAlt_Key,
     A.BranchStateName  As StateName,         ---Previously  C.StateName Changed by kapil 01/01/2024
     A.PinCode,
     D.CountryAlt_Key,
     D.CountryName,
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
	,A.Changefields 
	FROM DimBranch A left join DimGeography B
	ON A.BranchDistrictAlt_Key=B.DistrictAlt_Key 
	AND B.EffectiveFromTimeKey <= @TimeKey AND B.EffectiveToTimeKey >= @TimeKey 
	left join DimState C
	On A.BranchStateAlt_Key=C.StateAlt_Key AND C.EffectiveFromTimeKey <= @TimeKey AND C.EffectiveToTimeKey >= @TimeKey
	left Join DimCountry D
	On A.CountryAlt_Key=D.CountryAlt_Key AND D.EffectiveFromTimeKey <= @TimeKey  AND D.EffectiveToTimeKey >= @TimeKey
	WHERE A.EffectiveFromTimeKey <= @TimeKey  AND A.EffectiveToTimeKey >= @TimeKey AND ISNULL(A.AuthorisationStatus, 'A') = 'A'

                     UNION
                     SELECT A.BranchAlt_Key,
							A.BranchCode,
							A.BranchName,
							A.Add_1 as Address1,
							A.Add_2 as Address2,
							A.Add_3 as Address3,
							B.DistrictAlt_Key,
							A.BranchDistrictName  as DistrictName,       --b.DistrictName,
							C.StateAlt_Key,
							A.BranchStateName  as StateName,         --  C.StateName,
							A.PinCode,
							D.CountryAlt_Key,
							D.CountryName,
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
       ,ISNULL(A.ApprovedByFirstLevel,A.CreatedBy) as CrAppBy  
       ,ISNULL(A.DateApprovedFirstLevel,A.DateCreated) as CrAppDate  
       ,ISNULL(A.ApprovedByFirstLevel,A.ModifiedBy) as ModAppBy  
       ,ISNULL(A.DateApprovedFirstLevel,A.DateModified) as ModAppDate
							,A.Changefields
                     FROM DimBranch_Mod A
					 left join DimGeography B
					 ON A.BranchDistrictAlt_Key=B.DistrictAlt_Key
					AND B.EffectiveFromTimeKey <= @TimeKey AND B.EffectiveToTimeKey >= @TimeKey
					left join DimState C
					On A.BranchStateAlt_Key=C.StateAlt_Key
					AND C.EffectiveFromTimeKey <= @TimeKey AND C.EffectiveToTimeKey >= @TimeKey
					left Join DimCountry D
					On A.CountryAlt_Key=D.CountryAlt_Key
					AND D.EffectiveFromTimeKey <= @TimeKey  AND D.EffectiveToTimeKey >= @TimeKey
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                           AND A.Branch_Key IN
                     (
                         SELECT MAX(Branch_Key)
                         FROM DimBranch_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP','D1', 'RM','1A')
                         GROUP BY BranchAlt_Key
                     )
                 ) A 
                      
                 
                 GROUP BY   A.BranchAlt_Key,
							A.BranchCode,
							A.BranchName,
							A.Address1,
							A.Address2,
							A.Address3,
							A.DistrictAlt_Key,
							 A.DistrictName,
							A.StateAlt_Key,
							A.StateName,
							A.PinCode,
							A.CountryAlt_Key,
							A.CountryName,
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
							A.Changefields;

                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY BranchAlt_Key) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'BranchMaster' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp A
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner
				  Order By DataPointOwner.DateCreated Desc
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
                 --      AND RowNumber <= (@PageNo * @PageSize);
             END;
             ELSE

			 /*  IT IS Used For GRID Search which are Pending for Authorization    */

			 IF(@OperationFlag in (16,17))

             BEGIN
			 IF OBJECT_ID('TempDB..#temp16') IS NOT NULL
                 DROP TABLE #temp16;
                 SELECT		A.BranchAlt_Key,
							A.BranchCode,
							A.BranchName,
							A.Address1,
							A.Address2,
							A.Address3,
							A.DistrictAlt_Key,
							A.DistrictName,
							A.StateAlt_Key,
							A.StateName,
							A.PinCode,
							A.CountryAlt_Key,
							A.CountryName,
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
							A.Changefields
                 INTO #temp16
                 FROM 
                 (
                     SELECT A.BranchAlt_Key,
							A.BranchCode,
							A.BranchName,
							A.Add_1 as Address1,
							A.Add_2 as Address2,
							A.Add_3 as Address3,
							B.DistrictAlt_Key,
							B.DistrictName,
							C.StateAlt_Key,
							C.StateName,
							A.PinCode,
							D.CountryAlt_Key,
							D.CountryName,
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
       ,ISNULL(A.ApprovedByFirstLevel,A.CreatedBy) as CrAppBy  
       ,ISNULL(A.DateApprovedFirstLevel,A.DateCreated) as CrAppDate  
       ,ISNULL(A.ApprovedByFirstLevel,A.ModifiedBy) as ModAppBy  
       ,ISNULL(A.DateApprovedFirstLevel,A.DateModified) as ModAppDate
							,A.Changefields
                     FROM DimBranch_Mod A
					 left join DimGeography B
					 ON A.BranchDistrictAlt_Key=B.DistrictAlt_Key
					AND B.EffectiveFromTimeKey <= @TimeKey AND B.EffectiveToTimeKey >= @TimeKey
					left join DimState C
					On A.BranchStateAlt_Key=C.StateAlt_Key
					AND C.EffectiveFromTimeKey <= @TimeKey AND C.EffectiveToTimeKey >= @TimeKey
					left Join DimCountry D
					On A.CountryAlt_Key=D.CountryAlt_Key
					AND D.EffectiveFromTimeKey <= @TimeKey  AND D.EffectiveToTimeKey >= @TimeKey
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                           AND A.Branch_Key IN
                     (
                         SELECT MAX(Branch_Key)
                         FROM DimBranch_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')
                         GROUP BY BranchAlt_Key
                     )
                 ) A 
                      
                 
                 GROUP BY	A.BranchAlt_Key,
							A.BranchCode,
							A.BranchName,
							A.Address1,
							A.Address2,
							A.Address3,
							A.DistrictAlt_Key,
							A.DistrictName,
							A.StateAlt_Key,
							A.StateName,
							A.PinCode,
							A.CountryAlt_Key,
							A.CountryName,
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
							A.Changefields
                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY BranchAlt_Key) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'BranchMaster' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp16 A
						 
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner
				  Order By DataPointOwner.DateCreated Desc
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
                 --      AND RowNumber <= (@PageNo * @PageSize)

   END;

   ELSE

    IF (@OperationFlag =20)
             BEGIN

    IF OBJECT_ID('TempDB..#temp20') IS NOT NULL
                 DROP TABLE #temp20;
                 SELECT		A.BranchAlt_Key,
							A.BranchCode,
							A.BranchName,
							A.Address1,
							A.Address2,
							A.Address3,
							A.DistrictAlt_Key,
							A.DistrictName,
							A.StateAlt_Key,
							A.StateName,
							A.PinCode,
							A.CountryAlt_Key,
							A.CountryName,
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
							A.Changefields
                 INTO #temp20
                 FROM 
                 (
                     SELECT A.BranchAlt_Key,
							A.BranchCode,
							A.BranchName,
							A.Add_1 as Address1,
							A.Add_2 as Address2,
							A.Add_3 as Address3,
							B.DistrictAlt_Key,
							B.DistrictName,
							C.StateAlt_Key,
							C.StateName,
							A.PinCode,
							D.CountryAlt_Key,
							D.CountryName,
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
							----,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							--,ISNULL(A.ApprovedByFirstLevel,A.CreatedBy) as CrAppBy
							--,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							--,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							--,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
							 ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy  
       ,IsNull(A.DateModified,A.DateCreated)as CrModDate  
       ,ISNULL(A.ApprovedByFirstLevel,A.CreatedBy) as CrAppBy  
       ,ISNULL(A.DateApprovedFirstLevel,A.DateCreated) as CrAppDate  
       ,ISNULL(A.ApprovedByFirstLevel,A.ModifiedBy) as ModAppBy  
       ,ISNULL(A.DateApprovedFirstLevel,A.DateModified) as ModAppDate
							,A.Changefields
                     FROM DimBranch_Mod A
					 left join DimGeography B
					 ON A.BranchDistrictAlt_Key=B.DistrictAlt_Key
					AND B.EffectiveFromTimeKey <= @TimeKey AND B.EffectiveToTimeKey >= @TimeKey
					left join DimState C
					On A.BranchStateAlt_Key=C.StateAlt_Key
					AND C.EffectiveFromTimeKey <= @TimeKey AND C.EffectiveToTimeKey >= @TimeKey
					left Join DimCountry D
					On A.CountryAlt_Key=D.CountryAlt_Key
					AND D.EffectiveFromTimeKey <= @TimeKey  AND D.EffectiveToTimeKey >= @TimeKey
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           --AND ISNULL(A.AuthorisationStatus, 'A') IN('1A')
                           AND A.Branch_Key IN
                     (
                         SELECT MAX(Branch_Key)
                         FROM DimBranch_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               --AND ISNULL(A.AuthorisationStatus, 'A') IN('1A')
							    AND (case when @AuthLevel =2  AND ISNULL(AuthorisationStatus, 'A') IN('1A','D1')
										THEN 1 
							           when @AuthLevel =1 AND ISNULL(AuthorisationStatus,'A') IN ('NP','MP','DP')
										THEN 1
										ELSE 0									
										END
									)=1
                         GROUP BY BranchAlt_Key
                     )
                 ) A 
                      
                 
                 GROUP BY	A.BranchAlt_Key,
							A.BranchCode,
							A.BranchName,
							A.Address1,
							A.Address2,
							A.Address3,
							A.DistrictAlt_Key,
							A.DistrictName,
							A.StateAlt_Key,
							A.StateName,
							A.PinCode,
							A.CountryAlt_Key,
							A.CountryName,
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
							A.Changefields
                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY BranchAlt_Key) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'BranchMaster' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp20 A
						 
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner
				  Order By DataPointOwner.DateCreated Desc
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


    exec [dbo].[GetBranchMasterMeta]
  --exec GetBranchMasterMeta
  
    END;
GO