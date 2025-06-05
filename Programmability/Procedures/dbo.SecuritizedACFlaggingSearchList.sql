SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROC [dbo].[SecuritizedACFlaggingSearchList]
--Declare
													
													--@PageNo         INT         = 1, 
													--@PageSize       INT         = 10, 
													@OperationFlag  INT         = 16
													,@MenuID  INT
AS
     
	 BEGIN

SET NOCOUNT ON;
Declare @TimeKey as Int
	--SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')
	SET @Timekey=(select CAST(B.timekey as int)from SysDataMatrix A
			Inner Join SysDayMatrix B ON A.TimeKey=B.TimeKey
			 where A.CurrentStatus='C')

			 			 
	Declare @Authlevel InT
 
select @Authlevel=AuthLevel from SysCRisMacMenu  
 where MenuId=@MenuID	

  print @menuID
					

BEGIN TRY




/*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */

			IF(@OperationFlag not in ( 16,17,20))
             BEGIN
			 IF OBJECT_ID('TempDB..#temp') IS NOT NULL
                 DROP TABLE  #temp;
                 SELECT		A.AccountFlagAlt_Key
							,A.SourceAlt_Key
							,A.SourceName
							,A.AccountID
							,A.CustomerID
							,A.CustomerName
							,A.FlagAlt_Key
							,A.PoolID
							,A.PoolName
							,A.AccountBalance
							,A.POS
							,A.InterestReceivable
							,A.ExposureAmount
							,A.poolType
							,A.MaturityDate
							,A.SecMarkingDate
							,A.SecuritizedOutDate,
							A.AuthorisationStatus,
							A.AuthorisationStatus_Name, 
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
							A.Changefields,
							A.InterestAccruedinRs
                 INTO #temp
                 FROM 
                 (
                     SELECT 
							A.AccountFlagAlt_Key
							,A.SourceAlt_Key
							,ds.SourceName
							,A.AccountID
							,A.CustomerID
							,A.CustomerName
							,A.FlagAlt_Key
							,A.PoolID
							,A.PoolName
							,A.AccountBalance
							,A.POS
							,A.InterestReceivable
							,A.ExposureAmount
							,A.PoolType
							,Case when isnull(A.MaturityDate,'')='' then Null else convert(Varchar(10),MaturityDate,103) ENd MaturityDate
							,Case when isnull(A.SecMarkingDate,'')='' then Null else convert(Varchar(10),SecMarkingDate,103) ENd SecMarkingDate
							,A.SecuritizedOutDate,
							isnull(A.AuthorisationStatus,'A') as AuthorisationStatus,
							Case When isnull(A.AuthorisationStatus,'A')='A' Then 'Authorized' Else 'Pending Authorisation' End as AuthorisationStatus_Name,  
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified,
							IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy,
							IsNull(A.DateModified,A.DateCreated)as CrModDate

							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
								,'' as Changefields
                       	,A.InterestAccruedinRs
                     FROM SecuritizedACFlaggingDetail A Inner join DIMSOURCEDB ds on ds.SourceAlt_Key=A.SourceAlt_Key
					 WHERE  A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           AND ISNULL(A.AuthorisationStatus,'A') ='A'
						   And Not exists(Select 1 from SecuritizedFinalACDetail B 
						    WHERE   ISNULL(B.AuthorisationStatus,'A') IN ('A')
						   AND B.AccountID=A.AccountID  AND B.FlagAlt_Key='N'
						   )

					UNION

					SELECT 
							 0 AccountFlagAlt_Key
							,1 as SourceAlt_Key
							,'Finacle' as SourceName
							,A.AccountID
							,A.CustomerID
							,B.CustomerName
							,(CASE WHEN Action = 'A' THEN 'Y' ELSE 'N' END) as FlagAlt_Key
							,A.PoolID
							,A.PoolName
							,A.OSBalance
							,A.POS
							,A.InterestReceivable
							,A.SecuritizedExposureAmt
							,A.SecuritisationType as PoolType
							,Case when isnull(A.MaturityDate,'')='' then Null else convert(Varchar(10),MaturityDate,103) ENd MaturityDate
							,Case when isnull(A.DateofSecuritisationmarking,'')='' then Null else convert(Varchar(10),DateofSecuritisationmarking,103) ENd SecMarkingDate
							,A.MaturityDate SecuritizedOutDate,
							isnull(A.AuthorisationStatus,'A') as AuthorisationStatus, 
							Case When isnull(A.AuthorisationStatus,'A')='A' Then 'Authorized' Else 'Pending Authorisation' End as AuthorisationStatus_Name, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifyBy, 
                            A.DateModified,
							IsNull(A.ModifyBy,A.CreatedBy)as CrModBy,
							IsNull(A.DateModified,A.DateCreated)as CrModDate

							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifyBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
								,'' as Changefields
                       	, InterestAccruedinRs
                     FROM SecuritizedDetail A
					 --Inner join DIMSOURCEDB ds on ds.SourceAlt_Key=A.SourceAlt_Key
					 INNER JOIN CustomerBasicDetail B ON A.CustomerID = B.CustomerID
					 and B.EffectiveFromTimekey <= @Timekey and B.EffectiveToTimekey >= @Timekey
					 WHERE  A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                     --      AND ISNULL(A.AuthorisationStatus,'A') ='A'
					 And Not exists(Select 1 from SecuritizedACFlaggingDetail_Mod B 
						    WHERE  B.EffectiveFromTimeKey <= @TimeKey
                           AND B.EffectiveToTimeKey >= @TimeKey
                           AND ISNULL(B.AuthorisationStatus,'A') IN ('NP', 'MP', 'DP', 'RM','1A')
						   AND B.AccountID=A.AccountID
						   )

                     UNION

                     SELECT A.AccountFlagAlt_Key
							,A.SourceAlt_Key
							,ds.SourceName
							,A.AccountID
							,A.CustomerID
							,A.CustomerName
							,A.FlagAlt_Key
							,A.PoolID
							,A.PoolName
							,A.AccountBalance
							,A.POS
							,A.InterestReceivable
							,A.ExposureAmount
							,A.PoolType
							,Case when isnull(A.MaturityDate,'')='' then Null else convert(Varchar(10),MaturityDate,103) ENd MaturityDate
							,Case when isnull(A.SecMarkingDate,'')='' then Null else convert(Varchar(10),SecMarkingDate,103) ENd SecMarkingDate
							,A.SecuritizedOutDate,
							isnull(A.AuthorisationStatus,'A') as AuthorisationStatus, 
							Case When isnull(A.AuthorisationStatus,'A')='A' Then 'Authorized' Else 'Pending Authorisation' End as AuthorisationStatus_Name, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified,
							IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy,
							IsNull(A.DateModified,A.DateCreated)as CrModDate

							,ISNULL(A.ApprovedByFirstLevel,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApprovedFirstLevel,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedByFirstLevel,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApprovedFirstLevel,A.DateModified) as ModAppDate
							,A.Changefields
							,A.InterestAccruedinRs
                     FROM	SecuritizedACFlaggingDetail_Mod A Inner join DIMSOURCEDB ds on ds.SourceAlt_Key=A.SourceAlt_Key
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
						   And Not exists(Select 1 from SecuritizedFinalACDetail B 
						    WHERE   ISNULL(B.AuthorisationStatus,'A') IN ('A')
						   AND B.AccountID=A.AccountID  AND B.FlagAlt_Key='N'
						   )
                           --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                           AND A.Entity_Key IN
                     (
                         SELECT MAX(Entity_Key)
                         FROM SecuritizedACFlaggingDetail_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')
                         GROUP BY AccountID
                     )
                 ) A 
                      
                 
                 GROUP BY A.AccountFlagAlt_Key
							,A.SourceAlt_Key
							,A.SourceName
							,A.AccountID
							,A.CustomerID
							,A.CustomerName
							,A.FlagAlt_Key
							,A.PoolID
							,A.PoolName
							,A.AccountBalance
							,A.POS
							,A.InterestReceivable
							,A.ExposureAmount
							,A.poolType
							,A.MaturityDate
							,A.SecMarkingDate
							,A.SecuritizedOutDate,
							A.AuthorisationStatus,
							A.AuthorisationStatus_Name, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified,
							A.crModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate,
							A.Changefields,
							A.InterestAccruedinRs
							

                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY AccountFlagAlt_Key) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'SecuritizedACFlaggingDetail' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp A
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
                 --      AND RowNumber <= (@PageNo * @PageSize);
             END;
             ELSE

			 /*  IT IS Used For GRID Search which are Pending for Authorization    */
			 IF (@OperationFlag in (16,17))

             BEGIN
			 IF OBJECT_ID('TempDB..#temp16') IS NOT NULL
                 DROP TABLE #temp16;
                 SELECT A.AccountFlagAlt_Key
							,A.SourceAlt_Key
							,A.SourceName
							,A.AccountID
							,A.CustomerID
							,A.CustomerName
							,A.FlagAlt_Key
							,A.PoolID
							,A.PoolName
							,A.AccountBalance
							,A.POS
							,A.InterestReceivable
							,A.ExposureAmount
							,A.poolType
							,A.MaturityDate
							,A.SecMarkingDate
							,A.SecuritizedOutDate,
							A.AuthorisationStatus, 
							A.AuthorisationStatus_Name,
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
							A.Changefields,
							A.InterestAccruedinRs
                 INTO #temp16
                 FROM 
                 (
                     SELECT A.AccountFlagAlt_Key
							,A.SourceAlt_Key
							,A.SourceName
							,A.AccountID
							,A.CustomerID
							,A.CustomerName
							,A.FlagAlt_Key
							,A.PoolID
							,A.PoolName
							,A.AccountBalance
							,A.POS
							,A.InterestReceivable
							,A.ExposureAmount
							,A.PoolType
							,Case when isnull(A.MaturityDate,'')='' then Null else convert(Varchar(10),MaturityDate,103) ENd MaturityDate
							,Case when isnull(A.SecMarkingDate,'')='' then Null else convert(Varchar(10),SecMarkingDate,103) ENd SecMarkingDate
							,A.SecuritizedOutDate,
							isnull(A.AuthorisationStatus,'A') AuthorisationStatus, 
							Case When isnull(A.AuthorisationStatus,'A')='A' Then 'Authorized' Else 'Pending Authorisation' End as AuthorisationStatus_Name,
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified,
							IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy,
							IsNull(A.DateModified,A.DateCreated)as CrModDate

							,ISNULL(A.ApprovedByFirstLevel,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApprovedFirstLevel,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedByFirstLevel,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApprovedFirstLevel,A.DateModified) as ModAppDate
							,A.Changefields
							,A.InterestAccruedinRs
                     FROM SecuritizedACFlaggingDetail_Mod A
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                           AND A.Entity_Key IN
                     (
                         SELECT MAX(Entity_Key)
                         FROM SecuritizedACFlaggingDetail_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus,'A') IN('NP', 'MP', 'DP', 'RM')
                         GROUP BY AccountID
                     )
                 ) A 
                      
                 
                 GROUP BY A.AccountFlagAlt_Key
							,A.SourceAlt_Key
							,A.SourceName
							,A.AccountID
							,A.CustomerID
							,A.CustomerName
							,A.FlagAlt_Key
							,A.PoolID
							,A.PoolName
							,A.AccountBalance
							,A.POS
							,A.InterestReceivable
							,A.ExposureAmount
							,A.poolType
							,A.MaturityDate
							,A.SecMarkingDate
							,A.SecuritizedOutDate,
							A.AuthorisationStatus,
							A.AuthorisationStatus_Name, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified,
							A.crModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate,
							A.Changefields,
							A.InterestAccruedinRs
                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY AccountFlagAlt_Key) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'SecuritizedACFlaggingDetail' TableName, 
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

   END

   ELSE
    IF (@OperationFlag in (20))

             BEGIN
			 IF OBJECT_ID('TempDB..#temp20') IS NOT NULL
                 DROP TABLE #temp20;
                 SELECT A.AccountFlagAlt_Key
							,A.SourceAlt_Key
							,A.SourceName
							,A.AccountID
							,A.CustomerID
							,A.CustomerName
							,A.FlagAlt_Key
							,A.PoolID
							,A.PoolName
							,A.AccountBalance
							,A.POS
							,A.InterestReceivable
							,A.ExposureAmount
							,A.poolType
							,A.MaturityDate
							,A.SecMarkingDate
							,A.SecuritizedOutDate,
							A.AuthorisationStatus,
							A.AuthorisationStatus_Name, 
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
							A.Changefields,
							A.InterestAccruedinRs
                 INTO #temp20
                 FROM 
                 (
                     SELECT A.AccountFlagAlt_Key
							,A.SourceAlt_Key
							,A.SourceName
							,A.AccountID
							,A.CustomerID
							,A.CustomerName
							,A.FlagAlt_Key
							,A.PoolID
							,A.PoolName
							,A.AccountBalance
							,A.POS
							,A.InterestReceivable
							,A.ExposureAmount
							,A.PoolType
							,Case when isnull(A.MaturityDate,'')='' then Null else convert(Varchar(10),MaturityDate,103) ENd MaturityDate
							,Case when isnull(A.SecMarkingDate,'')='' then Null else convert(Varchar(10),SecMarkingDate,103) ENd SecMarkingDate
							,A.SecuritizedOutDate,
							isnull(A.AuthorisationStatus,'A') AuthorisationStatus, 
							Case When isnull(A.AuthorisationStatus,'A')='A' Then 'Authorized' Else 'Pending Authorisation' End as AuthorisationStatus_Name,
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified,
							IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy,
							IsNull(A.DateModified,A.DateCreated)as CrModDate

							,ISNULL(A.ApprovedByFirstLevel,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApprovedFirstLevel,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedByFirstLevel,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApprovedFirstLevel,A.DateModified) as ModAppDate
							,A.Changefields
							,A.InterestAccruedinRs
                     FROM SecuritizedACFlaggingDetail_Mod A
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                           AND A.Entity_Key IN
                     (
                         SELECT MAX(Entity_Key)
                         FROM SecuritizedACFlaggingDetail_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus,'A') IN('1A')
							       ---  AND AuthorisationStatus IN('1A')
							AND (case when @AuthLevel =2  AND ISNULL(AuthorisationStatus, 'A') IN('1A')
										THEN 1 
							           when @AuthLevel =1 AND ISNULL(AuthorisationStatus,'A') IN ('NP','MP','DP')
										THEN 1
										ELSE 0									
										END
									)=1
                         GROUP BY AccountID
                     )
                 ) A 
                      
                 
                 GROUP BY A.AccountFlagAlt_Key
							,A.SourceAlt_Key
							,A.SourceName
							,A.AccountID
							,A.CustomerID
							,A.CustomerName
							,A.FlagAlt_Key
							,A.PoolID
							,A.PoolName
							,A.AccountBalance
							,A.POS
							,A.InterestReceivable
							,A.ExposureAmount
							,A.poolType
							,A.MaturityDate
							,A.SecMarkingDate
							,A.SecuritizedOutDate,
							A.AuthorisationStatus,
							A.AuthorisationStatus_Name, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified,
							A.crModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate,
							A.Changefields,
							A.InterestAccruedinRs
                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY AccountFlagAlt_Key) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'SecuritizedACFlaggingDetail' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp20 A
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner

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


  select *,'SecuritizedAssetMarking' AS tableName from MetaScreenFieldDetail where ScreenName='SecuritizedAssetMarking' 
  
    END;
GO