SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--sp_rename 'TransactionSubTypeMasterSearchList','TransactionSubTypeMasterSearchList_13052022'
CREATE PROC [dbo].[TransactionSubTypeMasterSearchList]
--Declare
													--@PageNo         INT         = 1, 
													--@PageSize       INT         = 10, 
													@OperationFlag  INT         = 16
													,@MenuID  INT  =14560
AS
     
	 BEGIN

SET NOCOUNT ON;
Declare @TimeKey as Int
	SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')
Declare @Authlevel InT
 
select @Authlevel=AuthLevel from SysCRisMacMenu  
 where MenuId=@MenuID	
 --select * from 	SysCRisMacMenu where menucaption like '%Trans%'					

BEGIN TRY

/*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */

			IF(@OperationFlag not in (16,17,20))

             BEGIN
			 IF OBJECT_ID('TempDB..#temp') IS NOT NULL
                 DROP TABLE  #temp;
                 SELECT 
							A.Transaction_Sub_TypeAlt_Key,
							A.Source_System_Name,
							A.TXNTYPE,-----new add
							A.SourceAlt_Key,
							A.Transaction_Sub_Type_Code,
							A.Transaction_Sub_Type_Description,
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
							,A.AuthorisationStatus_1
                 INTO #temp
                 FROM 
                 (
                     SELECT 
							A.Transaction_Sub_TypeAlt_Key,
							B.SourceName as Source_System_Name,
							A.TxnType,----new add
							B.SourceAlt_Key,
							A.Transaction_Sub_Type_Code,
							A.Transaction_Sub_Type_Description,
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
									, '' as changefields,
									--isnull(A.AuthorisationStatus, 'A') AuthorisationStatus, 
								 CASE WHEN  ISNULL(A.AuthorisationStatus,'A')='A' THEN 'Authorized'
								  WHEN  ISNULL(A.AuthorisationStatus,'A')='R' THEN 'Rejected'
								  WHEN  ISNULL(A.AuthorisationStatus,'A')='1A' THEN '1Authorized'
								  WHEN  ISNULL(A.AuthorisationStatus,'A') IN ('NP','MP') THEN 'Pending Authorisation' ELSE NULL 
								  END AS AuthorisationStatus_1
                     --select *
                     FROM DimTransactionSubTypeMaster A
					 Inner join DIMSOURCEDB B
					 ON A.SourceAlt_Key=B.SourceAlt_Key
					 AND B.EffectiveFromTimeKey<=@Timekey And B.EffectiveToTimeKey>=@TimeKey
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
                     UNION
                     SELECT A.Transaction_Sub_TypeAlt_Key,
							B.SourceName as Source_System_Name,
							A.TXNTYPE,
							B.SourceAlt_Key,
							A.Transaction_Sub_Type_Code,
							A.Transaction_Sub_Type_Description,
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
								,CASE WHEN  ISNULL(A.AuthorisationStatus,'A')='A' THEN 'Authorized'
								  WHEN  ISNULL(A.AuthorisationStatus,'A')='R' THEN 'Rejected'
								  WHEN  ISNULL(A.AuthorisationStatus,'A')='1A' THEN '1Authorized'
								  WHEN  ISNULL(A.AuthorisationStatus,'A') IN ('NP','MP') THEN 'Pending' ELSE NULL 
								  END AS AuthorisationStatus_1
                     FROM DimTransactionSubTypeMaster_Mod A
					 inner Join DIMSOURCEDB B
					 ON A.SourceAlt_Key=B.SourceAlt_Key
					 AND B.EffectiveFromTimeKey<=@Timekey And B.EffectiveToTimeKey>=@TimeKey
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                           AND A.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM DimTransactionSubTypeMaster_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')
                         GROUP BY Transaction_Sub_TypeAlt_Key
                     )
                 ) A 
                      
                 
                 GROUP BY A.Transaction_Sub_TypeAlt_Key,
							A.Source_System_Name,
							A.TXNTYPE,
							A.SourceAlt_Key,
							A.Transaction_Sub_Type_Code,
							A.Transaction_Sub_Type_Description,
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
							,A.AuthorisationStatus_1

                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY Transaction_Sub_TypeAlt_Key) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'TransactionSubTypeMaster' TableName, 
                            *,len(AuthorisationStatus) as AuthorisationStatuslen
                     FROM
                     (
                         SELECT *
                         FROM #temp A
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner
				   order by DateCreated desc  --updated by vinit
				 --order by DataPointOwner.AuthorisationStatuslen desc --Comment By Vinit
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
                 --      AND RowNumber <= (@PageNo * @PageSize);
             END;
             ELSE

			 /*  IT IS Used For GRID Search which are Pending for Authorization    */
			 IF(@OperationFlag in (16,17))


             BEGIN
			 IF OBJECT_ID('TempDB..#temp16') IS NOT NULL
                 DROP TABLE #temp16;
                 SELECT A.Transaction_Sub_TypeAlt_Key,
							A.Source_System_Name,
							A.TXNTYPE,
							A.SourceAlt_Key,
							A.Transaction_Sub_Type_Code,
							A.Transaction_Sub_Type_Description,
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
							,A.AuthorisationStatus_1
                 INTO #temp16
                 FROM 
                 (
                     SELECT A.Transaction_Sub_TypeAlt_Key,
							B.SourceName as Source_System_Name,
							A.TXNTYPE,
							B.SourceAlt_Key,
							A.Transaction_Sub_Type_Code,
							A.Transaction_Sub_Type_Description,
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
										,CASE WHEN  ISNULL(A.AuthorisationStatus,'A')='A' THEN 'Authorized'
								  WHEN  ISNULL(A.AuthorisationStatus,'A')='R' THEN 'Rejected'
								  WHEN  ISNULL(A.AuthorisationStatus,'A')='1A' THEN '1Authorized'
								  WHEN  ISNULL(A.AuthorisationStatus,'A') IN ('NP','MP') THEN 'Pending Authorisation' ELSE NULL 
								  END AS AuthorisationStatus_1
                     FROM DimTransactionSubTypeMaster_Mod A
					 inner Join DIMSOURCEDB B
					 ON A.SourceAlt_Key=B.SourceAlt_Key
					 AND B.EffectiveFromTimeKey<= @TimeKey AND B.EffectiveToTimeKey>=@TimeKey
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                           AND A.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM DimTransactionSubTypeMaster_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')
                         GROUP BY Transaction_Sub_TypeAlt_Key
                     )
                 ) A 
                      
                 
                 GROUP BY A.Transaction_Sub_TypeAlt_Key,
							A.Source_System_Name,
							A.TXNTYPE,
							A.SourceAlt_Key,
							A.Transaction_Sub_Type_Code,
							A.Transaction_Sub_Type_Description,
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
							,A.AuthorisationStatus_1
                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY Transaction_Sub_TypeAlt_Key) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'TransactionSubTypeMaster' TableName, 
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

   ELSE
    IF(@OperationFlag in (20))


             BEGIN
			 IF OBJECT_ID('TempDB..#temp20') IS NOT NULL
                 DROP TABLE #temp20;
                 SELECT A.Transaction_Sub_TypeAlt_Key,
							A.Source_System_Name,
							A.TXNTYPE,
							A.SourceAlt_Key,
							A.Transaction_Sub_Type_Code,
							A.Transaction_Sub_Type_Description,
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
							,A.AuthorisationStatus_1
                 INTO #temp20
                 FROM 
                 (
                     SELECT A.Transaction_Sub_TypeAlt_Key,
							B.SourceName as Source_System_Name,
							A.TXNTYPE,
							B.SourceAlt_Key,
							A.Transaction_Sub_Type_Code,
							A.Transaction_Sub_Type_Description,
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
										,CASE WHEN  ISNULL(A.AuthorisationStatus,'A')='A' THEN 'Authorized'
								  WHEN  ISNULL(A.AuthorisationStatus,'A')='R' THEN 'Rejected'
								  WHEN  ISNULL(A.AuthorisationStatus,'A')='1A' THEN '1Authorized'
								  WHEN  ISNULL(A.AuthorisationStatus,'A') IN ('NP','MP') THEN 'Pending Authorisation' ELSE NULL 
								  END AS AuthorisationStatus_1
                     FROM DimTransactionSubTypeMaster_Mod A
					 inner Join DIMSOURCEDB B
					 ON A.SourceAlt_Key=B.SourceAlt_Key
					 AND B.EffectiveFromTimeKey<= @TimeKey AND B.EffectiveToTimeKey>=@TimeKey
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                           AND A.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM DimTransactionSubTypeMaster_Mod
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
                         GROUP BY Transaction_Sub_TypeAlt_Key
                     )
                 ) A 
                      
                 
                 GROUP BY A.Transaction_Sub_TypeAlt_Key,
							A.Source_System_Name,
							A.TXNTYPE,
							A.SourceAlt_Key,
							A.Transaction_Sub_Type_Code,
							A.Transaction_Sub_Type_Description,
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
							,A.AuthorisationStatus_1
                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY Transaction_Sub_TypeAlt_Key) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'TransactionSubTypeMaster' TableName, 
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


  SELECT *, 'DimTransactionMaster' AS TableName FROM MetaScreenFieldDetail WHERE ScreenName='Transaction Sub Type Master' and  MenuId=14560
  
    END;
GO