SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROC [dbo].[CollateralSecurityMasterSearchList]
--Declare											--@PageNo         INT         = 1, 
													--@PageSize       INT         = 10, 
													@OperationFlag  INT         = 2
													,@MenuID  INT  =14557
AS
     
	 BEGIN

SET NOCOUNT ON;
Declare @TimeKey as Int
	SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')
	
	Declare @Authlevel InT
 
select @Authlevel=AuthLevel from SysCRisMacMenu  
 where MenuId=@MenuID
  --select * from 	SysCRisMacMenu where menucaption like '%Collate%'				

BEGIN TRY

/*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */

			IF(@OperationFlag not in (16,17,20))

             BEGIN
			 IF OBJECT_ID('TempDB..#temp') IS NOT NULL
                 DROP TABLE  #temp;
                 SELECT		A.CollateralSubTypeAltKey
							,A.CollateralTypeAltKey 
							--,A.CollateralSubTypeID  
							,A.CollateralSubTypeID
							,A.CollateralSubTypeDescription,
							SrcSecurityCode,
							Valid,
							A.SourceName,
							A.SourceAlt_Key,
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
							,A.changefields
							,a.CollateralSubType           ---Newly added by kapil as Vivek Sharma Requirement on 10/01/2024
                 INTO #temp
                 FROM 
                 (
                     SELECT CollateralSubTypeAltKey
							,CollateralTypeAltKey
							--,CollateralSubTypeID
							,CollateralSubType  As CollateralSubTypeID 
							,CollateralSubTypeDescription,
							SrcSecurityCode,
							CASE WHEN Valid = 'Y' THEN 'Yes' ELSE  'No' END Valid,
							B.SourceName,
							B.SourceAlt_Key,
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
							,'' as Changefields
							,a.SrcSecurityName       As CollateralSubType      ---Newly added by kapil as Vivek Sharma Requirement on 10/01/2024
                     FROM DimCollateralSubType A
					 Inner join DIMSOURCEDB B
					 ON A.SourceAlt_Key=B.SourceAlt_Key
					 AND B.EffectiveFromTimeKey<=@Timekey And B.EffectiveToTimeKey>=@TimeKey
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
                     UNION
                     SELECT CollateralSubTypeAltKey
							,CollateralTypeAltKey  
							--,CollateralSubTypeID 
							,CollateralSubType   As CollateralSubTypeID
							,CollateralSubTypeDescription,
							SrcSecurityCode,
							CASE WHEN Valid = 'Y' THEN 'Yes' ELSE  'No' END Valid,
							B.SourceName,
							B.SourceAlt_Key,
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
							,a.Changefields
							,a.SrcSecurityName      As CollateralSubType         ---Newly added by kapil as Vivek Sharma Requirement on 10/01/2024
                     FROM DimCollateralSubType_Mod A
					 Inner join DIMSOURCEDB B
					 ON A.SourceAlt_Key=B.SourceAlt_Key
					 AND B.EffectiveFromTimeKey<=@Timekey And B.EffectiveToTimeKey>=@TimeKey
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                           AND A.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM DimCollateralSubType_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')
                         GROUP BY CollateralSubTypeAltKey
                     )
                 ) A 
                      
                 
                 GROUP BY	A.CollateralSubTypeAltKey
							,A.CollateralTypeAltKey
							,A.CollateralSubTypeID
							,A.CollateralSubType
							,A.CollateralSubTypeDescription,
							SrcSecurityCode,
							Valid,
							A.SourceName,
							A.SourceAlt_Key,
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
							A.changefields
						   --,a.SrcSecurityName  ---Newly added by kapil as Vivek Sharma Requirement on 10/01/2024
                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY CollateralSubTypeAltKey) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'CollateralSecurityMaster' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp A
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner order by 1 desc
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
                 --      AND RowNumber <= (@PageNo * @PageSize);
             END;
             ELSE

			 /*  IT IS Used For GRID Search which are Pending for Authorization    */
			 IF(@OperationFlag in (16,17))


             BEGIN
			 IF OBJECT_ID('TempDB..#temp16') IS NOT NULL
                 DROP TABLE #temp16;
                 SELECT		A.CollateralSubTypeAltKey
							,A.CollateralTypeAltKey
							--,A.CollateralSubTypeID
							,A. CollateralSubTypeID
							,A.CollateralSubTypeDescription,
							SrcSecurityCode,
							Valid,
							A.SourceName,
							A.SourceAlt_Key,
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
							A.changefields
							,a.CollateralSubType     ---Newly added by kapil as Vivek Sharma Requirement on 10/01/2024
                 INTO #temp16
                 FROM 
                 (
                     SELECT CollateralSubTypeAltKey
							,CollateralTypeAltKey
							--,CollateralSubTypeID
							,CollateralSubType As CollateralSubTypeID
							,CollateralSubTypeDescription,
							SrcSecurityCode,
							CASE WHEN Valid = 'Y' THEN 'Yes' ELSE  'No' END Valid,
							B.SourceName,
							B.SourceAlt_Key,
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
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate,
							A.changefields
						   ,a.SrcSecurityName   As CollateralSubType                 ---Newly added by kapil as Vivek Sharma Requirement on 10/01/2024
                     FROM DimCollateralSubType_Mod A
					 Inner join DIMSOURCEDB B
					 ON A.SourceAlt_Key=B.SourceAlt_Key
					 AND B.EffectiveFromTimeKey<=@Timekey And B.EffectiveToTimeKey>=@TimeKey
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                           AND A.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM DimCollateralSubType_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')
                         GROUP BY CollateralSubTypeAltKey
                     )
                 ) A 
                      
                 
                 GROUP BY   A.CollateralSubTypeAltKey
							,A.CollateralTypeAltKey
							,A.CollateralSubTypeID
							,A.CollateralSubType
							,A.CollateralSubTypeDescription,
							SrcSecurityCode,
							Valid,
							A.SourceName,
							A.SourceAlt_Key,
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
							A.changefields
						 --  ,a.SrcSecurityName
                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY CollateralSubTypeAltKey) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'CollateralSecurityMaster' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp16 A
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner order by 1 Desc
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
                 --      AND RowNumber <= (@PageNo * @PageSize)

   END;

   ELSE
    IF(@OperationFlag in (20))


             BEGIN
			 IF OBJECT_ID('TempDB..#temp20') IS NOT NULL
                 DROP TABLE #temp20;
                 SELECT		A.CollateralSubTypeAltKey
							,A.CollateralTypeAltKey
							--,A.CollateralSubTypeID
							,A.CollateralSubTypeID
							,A.CollateralSubTypeDescription,
							SrcSecurityCode,
							Valid,
							A.SourceName,
							A.SourceAlt_Key,
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
							A.changefields
							,a.CollateralSubType                     ---Newly added by kapil as Vivek Sharma Requirement on 10/01/2024
                 INTO #temp20
                 FROM 
                 (
                     SELECT CollateralSubTypeAltKey
							,CollateralTypeAltKey
							--,CollateralSubTypeID
							,CollateralSubType As CollateralSubTypeID
							,CollateralSubTypeDescription,
							SrcSecurityCode,
							CASE WHEN Valid = 'Y' THEN 'Yes' ELSE  'No' END Valid,
							B.SourceName,
							B.SourceAlt_Key,
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
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate,
							A.changefields
							,a.SrcSecurityName  As CollateralSubType          ---Newly added by kapil as Vivek Sharma Requirement on 10/01/2024
                     FROM DimCollateralSubType_Mod A
					 Inner join DIMSOURCEDB B
					 ON A.SourceAlt_Key=B.SourceAlt_Key
					 AND B.EffectiveFromTimeKey<=@Timekey And B.EffectiveToTimeKey>=@TimeKey
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                           AND A.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM DimCollateralSubType_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               --AND ISNULL(AuthorisationStatus, 'A') IN('1A')
							    AND (case when @AuthLevel =2  AND ISNULL(AuthorisationStatus, 'A') IN('1A')
										THEN 1 
							           when @AuthLevel =1 AND ISNULL(AuthorisationStatus,'A') IN ('NP','MP','DP')
										THEN 1
										ELSE 0									
										END
									)=1
                         GROUP BY CollateralSubTypeAltKey
                     )
                 ) A 
                      
                 
                 GROUP BY   A.CollateralSubTypeAltKey
							,A.CollateralTypeAltKey
							,A.CollateralSubTypeID
							,A.CollateralSubType
							,A.CollateralSubTypeDescription,
							SrcSecurityCode,
							Valid,
							A.SourceName,
							A.SourceAlt_Key,
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
							A.changefields
							--,a.SrcSecurityName        ---Newly added by kapil as Vivek Sharma Requirement on 10/01/2024
                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY CollateralSubTypeAltKey) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'CollateralSecurityMaster' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp20 A
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner order by 1 desc
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
                 --      AND RowNumber <= (@PageNo * @PageSize)
   END

   END TRY
	BEGIN CATCH
	
	INSERT INTO dbo.Error_Log
				SELECT ERROR_LINE() as ErrorLine,ERROR_MESSAGE()ErrorMessage,ERROR_NUMBER()ErrorNumber
				,ERROR_PROCEDURE()ErrorProcedure,ERROR_SEVERITY()ErrorSeverity,ERROR_STATE()ErrorState
				,GETDATE()

	SELECT ERROR_MESSAGE()
	--RETURN -1
   
	END CATCH


  
  

  	SELECT *, 'DimCollateralMaster' AS TableName FROM MetaScreenFieldDetail WHERE ScreenName='Collateral Master' and  MenuId=14557
    END;
GO