SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROC [dbo].[SMAClassMaster_SearchList]
--Declare											--@PageNo         INT         = 1, 
													--@PageSize       INT         = 10, 
													@OperationFlag  INT         = 2
													,@MenuID  INT  =24745
AS
     
	 BEGIN

SET NOCOUNT ON;
Declare @TimeKey as Int
	SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')
					
Declare @Authlevel InT
 
select @Authlevel=AuthLevel from SysCRisMacMenu  
 where MenuId=@MenuID	
  --select * from 	SysCRisMacMenu where menucaption like '%Asset%'
BEGIN TRY

/*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */

			IF(@OperationFlag not in (16,17,20))

             BEGIN
			 IF OBJECT_ID('TempDB..#temp') IS NOT NULL
                 DROP TABLE  #temp;
                 SELECT		A.AssetClassMappingAlt_Key,	
							--A.SourceAlt_Key,			
							--A.SourceName,
							A.SrcSysClassCode,
							A.SrcSysClassName,
							A.AssetClassName,
							A.AssetClassAlt_Key,
							A.DPD_LowerValue,
							A.DPD_HigherValue,
							A.SrcSysGroup,
							A.AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModifie,
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate,
							A.Changefields,
							A.AuthorisationStatus_1
                 INTO #temp
                 FROM 
                 (
                     SELECT A.AssetClassMappingAlt_Key,	
						 --   B.SourceAlt_Key,				 
							--B.SourceName,
							A.SrcSysClassCode,
							A.SrcSysClassName,
							A.AssetClassName,
							A.AssetClassAlt_Key,
							A.DPD_LowerValue,
							A.DPD_HigherValue,
							A.SrcSysGroup,
							ltrim(rtrim(isnull(A.AuthorisationStatus,'A'))) AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModifie
							,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModifie,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModifie) as ModAppDate
							,'' as Changefields
							 ,CASE WHEN  ISNULL(A.AuthorisationStatus,'A')='A' THEN 'Authorized'
								  WHEN  ISNULL(A.AuthorisationStatus,'A')='R' THEN 'Rejected'
								  WHEN  ISNULL(A.AuthorisationStatus,'A')='1A' THEN '1Authorized'
								  WHEN  ISNULL(A.AuthorisationStatus,'A') IN ('NP','MP') THEN 'Pending Authorisation' ELSE NULL 
								  END AS AuthorisationStatus_1
                  --select * 
				  
				  FROM DimSMAClassMaster A
				  --INNER JOIN  dimassetclassmapping C on C.AssetClassAlt_Key=A.AssetClassAlt_Key
					 --inner join DIMSOURCEDB B
					 --ON C.SourceAlt_Key=B.SourceAlt_Key
					 --AND B.EffectiveFromTimeKey<=@Timekey And B.EffectiveToTimeKey>=@TimeKey
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           AND ISNULL(A.AuthorisationStatus,'A') = 'A'
                     UNION
                     SELECT A.AssetClassMappingAlt_Key,	
							--B.SourceAlt_Key,				
							--B.SourceName,
							A.SrcSysClassCode,
							A.SrcSysClassName,
							A.AssetClassName,
							A.AssetClassAlt_Key,
							A.DPD_LowerValue,
							A.DPD_HigherValue,
							A.SrcSysGroup,
					 		ltrim(rtrim(isnull(A.AuthorisationStatus, 'A'))) AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModifie
							,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModifie,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModifie) as ModAppDate
					       ,a.Changefields
						   , CASE WHEN  ISNULL(A.AuthorisationStatus,'A')='A' THEN 'Authorized'
								  WHEN  ISNULL(A.AuthorisationStatus,'A')='R' THEN 'Rejected'
								  WHEN  ISNULL(A.AuthorisationStatus,'A')='1A' THEN '1Authorized'
								  WHEN  ISNULL(A.AuthorisationStatus,'A') IN ('NP','MP') THEN 'Pending Authorisation' ELSE NULL 
								  END AS AuthorisationStatus_1
					--select *
                     FROM DimSMAClassMaster_Mod A
					 --INNER JOIN dimassetclassmapping C on C.AssetClassAlt_Key=A.AssetClassAlt_Key
					 --inner join DIMSOURCEDB B
					 --ON C.SourceAlt_Key=B.SourceAlt_Key
					 --AND B.EffectiveFromTimeKey<=@Timekey And B.EffectiveToTimeKey>=@TimeKey
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                           AND A.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM DimSMAClassMaster_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')
                         GROUP BY AssetClassMappingAlt_Key
                     )
                 ) A 
                      
                 
                 GROUP BY	A.AssetClassMappingAlt_Key,
							--A.SourceAlt_Key,
							--A.SourceName,
							A.SrcSysClassCode,
							A.SrcSysClassName,
							A.AssetClassName,
							A.AssetClassAlt_Key,
							A.DPD_LowerValue,
							A.DPD_HigherValue,
							A.SrcSysGroup,
				 			A.AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModifie,
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate,
							A.Changefields,
							A.AuthorisationStatus_1
							
                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY AssetClassMappingAlt_Key) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'SMAClassMaster' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp A
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner
				  ORDER BY AssetClassMappingAlt_Key,AssetClassAlt_Key
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
                 --      AND RowNumber <= (@PageNo * @PageSize);
             END;
             ELSE

			 /*  IT IS Used For GRID Search which are Pending for Authorization    */
			 IF(@OperationFlag in (16,17))


             BEGIN
			 IF OBJECT_ID('TempDB..#temp16') IS NOT NULL
                 DROP TABLE #temp16;
                 SELECT		A.AssetClassMappingAlt_Key,
				 'SMAGridList' AS TableName1,
							--A.SourceAlt_Key,
							--A.SourceName,
							A.SrcSysClassCode,
							A.SrcSysClassName,
							A.AssetClassName,
							A.AssetClassAlt_Key,
							A.DPD_LowerValue,
							A.DPD_HigherValue,
							A.SrcSysGroup,
							A.AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModifie,
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate,
							A.Changefields,
							AuthorisationStatus_1
                 INTO #temp16
                 FROM 
                 (
                     SELECT A.AssetClassMappingAlt_Key,
							'SMAGridList' AS TableName,
							--B.SourceAlt_Key,
							--B.SourceName,
							A.SrcSysClassCode,
							A.SrcSysClassName,
							A.AssetClassName,
							A.AssetClassAlt_Key,
							A.DPD_LowerValue,
							A.DPD_HigherValue,
							A.SrcSysGroup,
							ltrim(rtrim(isnull(A.AuthorisationStatus, 'A'))) AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModifie
							,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModifie,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModifie) as ModAppDate
								,a.Changefields
								, CASE WHEN  ISNULL(A.AuthorisationStatus,'A')='A' THEN 'Authorized'
								  WHEN  ISNULL(A.AuthorisationStatus,'A')='R' THEN 'Rejected'
								  WHEN  ISNULL(A.AuthorisationStatus,'A')='1A' THEN '1Authorized'
								  WHEN  ISNULL(A.AuthorisationStatus,'A') IN ('NP','MP') THEN 'Pending Authorisation' ELSE NULL 
								  END AS AuthorisationStatus_1
                     FROM DimSMAClassMaster_Mod A
					 -- INNER JOIN dimassetclassmapping C on C.AssetClassAlt_Key=A.AssetClassAlt_Key
					 --Inner join DIMSOURCEDB B

					 --ON C.SourceAlt_Key=B.SourceAlt_Key
					 --AND B.EffectiveFromTimeKey<=@Timekey And B.EffectiveToTimeKey>=@TimeKey
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                           AND A.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM DimSMAClassMaster_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')
                         GROUP BY AssetClassMappingAlt_Key
                     )
                 ) A 
                      
                 
                 GROUP BY   A.AssetClassMappingAlt_Key,
							--A.SourceAlt_Key,
							--A.SourceName,
							A.SrcSysClassCode,
							A.SrcSysClassName,
							A.AssetClassName,
							A.AssetClassAlt_Key,
							A.DPD_LowerValue,
							A.DPD_HigherValue,
							A.SrcSysGroup,
							A.AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModifie,
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate,
							A.Changefields,
							AuthorisationStatus_1
                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY AssetClassMappingAlt_Key) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'SMAClassMaster' TableName, 
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
				 ORDER BY AssetClassMappingAlt_Key,AssetClassAlt_Key
   END;

   ELSE
    IF(@OperationFlag in (20))


             BEGIN
			 IF OBJECT_ID('TempDB..#temp20') IS NOT NULL
                 DROP TABLE #temp20;
                 SELECT		A.AssetClassMappingAlt_Key,
				                'SMAGridList' AS TableName1,
							--A.SourceAlt_Key,
							--A.SourceName,
							A.SrcSysClassCode,
							A.SrcSysClassName,
							A.AssetClassName,
							A.AssetClassAlt_Key,
							A.DPD_LowerValue,
							A.DPD_HigherValue,
							A.SrcSysGroup,
							A.AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModifie,
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate,
							A.Changefields
							,A.AuthorisationStatus_1
                 INTO #temp20
                 FROM 
                 (
                     SELECT A.AssetClassMappingAlt_Key,
							'AssetGridList' AS TableName,
							--B.SourceAlt_Key,
							--B.SourceName,
							A.SrcSysClassCode,
							A.SrcSysClassName,
							A.AssetClassName,
							A.AssetClassAlt_Key,
							A.DPD_LowerValue,
							A.DPD_HigherValue,
							A.SrcSysGroup,
							ltrim(rtrim(isnull(A.AuthorisationStatus, 'A'))) AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModifie
							,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModifie,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModifie) as ModAppDate
							,a.Changefields
							, CASE WHEN  ISNULL(A.AuthorisationStatus,'A')='A' THEN 'Authorized'
								  WHEN  ISNULL(A.AuthorisationStatus,'A')='R' THEN 'Rejected'
								  WHEN  ISNULL(A.AuthorisationStatus,'A')='1A' THEN '1Authorized'
								  WHEN  ISNULL(A.AuthorisationStatus,'A') IN ('NP','MP') THEN 'Pending Authorisation' ELSE NULL 
								  END AS AuthorisationStatus_1
                     FROM DimSMAClassMaster_Mod A
					 --inner join dimassetclassmapping C on C.AssetClassAlt_Key=A.AssetClassAlt_Key
					 --Inner join DIMSOURCEDB B
					 --ON C.SourceAlt_Key=B.SourceAlt_Key
					 --AND B.EffectiveFromTimeKey<=@Timekey And B.EffectiveToTimeKey>=@TimeKey
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                           AND A.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM DimSMAClassMaster_Mod
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
                         GROUP BY AssetClassMappingAlt_Key
                     )
                 ) A 
                      
                 
                 GROUP BY   A.AssetClassMappingAlt_Key,
							--A.SourceAlt_Key,
							--A.SourceName,
							A.SrcSysClassCode,
							A.SrcSysClassName,
							A.AssetClassName,
							A.AssetClassAlt_Key,
							A.DPD_LowerValue,
							A.DPD_HigherValue,
							A.SrcSysGroup,
							A.AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModifie,
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate,
							A.Changefields,
							A.AuthorisationStatus_1

							ORDER BY A.SrcSysClassCode,A.AssetClassAlt_Key
                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY AssetClassMappingAlt_Key) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'SMAClassMaster' TableName, 
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
				  ORDER BY AssetClassMappingAlt_Key,AssetClassAlt_Key
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

	SELECT *, 'SMACLASSMaster' AS TableName FROM MetaScreenFieldDetail WHERE ScreenName='SMA Class Master' and  MenuId=24745
  
 
  
    END;
GO