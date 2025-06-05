SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO




--Select Timekey from SysDayMatrix where Cast([Date] as date)=Cast(Getdate() as date)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--UserParameterParameterisedMasterData 16
--USE YES_MISDB
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Create PROC [dbo].[UserParameterParameterisedMasterData]
--Declare
													
													
														
													  @OperationFlag  INT         = 20
													 ,@MenuID  INT  =14551

AS
----select AuthLevel,* from SysCRisMacMenu where Menuid=14551 Caption like '%Product%'
--update SysCRisMacMenu set AuthLevel=2 where Menuid=14551
     
	BEGIN 

SET NOCOUNT ON;
Declare @TimeKey AS INT
	Select @TimeKey= Timekey from SysDayMatrix where Cast([Date] as date)=Cast(Getdate() as date)


 
 				

BEGIN TRY
/*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */

			IF(@OperationFlag not in (16,17,20))
             BEGIN
			  PRINT 'SachinTest'
			 IF OBJECT_ID('TempDB..#temp') IS NOT NULL
                 DROP TABLE  #temp;
                 SELECT			A.ShortNameEnum,
								A.ParameterType,
								A.ParameterValue,
								A.SeqNo,
								A.MinValue,
								A.MaxValue,
							
							A.AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifyBy, 
                            A.DateModified,
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate,
							A.IsMainTable,
							A.CreatedModifiedBy
                 INTO #temp
                 FROM 
                 (
                     SELECT 
							  
						   DISTINCT 
							U.ShortNameEnum,
								U.ParameterType,
								U.ParameterValue,
								U.SeqNo,
								U.MinValue,
								U.MaxValue,
						   --,'QuickSearchTable' as TableName
						
							isnull(U.AuthorisationStatus, 'A') AuthorisationStatus, 
                            U.EffectiveFromTimeKey, 
                            U.EffectiveToTimeKey, 
                            U.CreatedBy, 
                            U.DateCreated, 
                            U.ApprovedBy, 
                            U.DateApproved, 
                            U.ModifyBy, 
                            U.DateModified
							,IsNull(U.ModifyBy,U.CreatedBy)as CrModBy
							,IsNull(U.DateModified,U.DateCreated)as CrModDate
							,ISNULL(U.ApprovedBy,U.CreatedBy) as CrAppBy
							,ISNULL(U.DateApproved,U.DateCreated) as CrAppDate
							,ISNULL(U.ApprovedBy,U.ModifyBy) as ModAppBy
							,ISNULL(U.DateApproved,U.DateModified) as ModAppDate
								,'N' AS IsMainTable
				          ,  CASE WHEN ISNULL(U.ModifyBy,'')='' THEN U.CreatedBy ELSE U.ModifyBy END  AS CreatedModifiedBy
							--select *
                     from DimUserParameters U

				
					 WHERE 
					 U.EffectiveFromTimeKey <= @TimeKey
                           AND U.EffectiveToTimeKey >= @TimeKey
						   --AND ShortNameEnum in('NONUSE','UNLOGON')
                           AND ISNULL(U.AuthorisationStatus, 'A') = 'A'
						          AND U.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM DimUserParameters
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
							  
                               AND ISNULL(AuthorisationStatus, 'A') IN('A')
                         GROUP BY ShortNameEnum
                     )

                     UNION
                    SELECT 
							  
						   DISTINCT 
							U.ShortNameEnum,
								U.ParameterType,
								U.ParameterValue,
								U.SeqNo,
								U.MinValue,
								U.MaxValue,
						   --,'QuickSearchTable' as TableName
						
							isnull(U.AuthorisationStatus, 'A') AuthorisationStatus, 
                            U.EffectiveFromTimeKey, 
                            U.EffectiveToTimeKey, 
                            U.CreatedBy, 
                            U.DateCreated, 
                            U.ApprovedBy, 
                            U.DateApproved, 
                            U.ModifyBy, 
                            U.DateModified
							,IsNull(U.ModifyBy,U.CreatedBy)as CrModBy
							,IsNull(U.DateModified,U.DateCreated)as CrModDate
						     ,ISNULL(U.ApprovedBy,U.ApprovedByFirstLevel) as CrAppBy
							,ISNULL(U.DateApproved,U.DateApprovedFirstLevel) as CrAppDate
							,ISNULL(U.ApprovedBy,U.ModifyBy) as ModAppBy
							,ISNULL(U.DateApproved,U.DateModified) as ModAppDate
							,'N' AS IsMainTable
				          ,  CASE WHEN ISNULL(U.ModifyBy,'')='' THEN U.CreatedBy ELSE U.ModifyBy END  AS CreatedModifiedBy
							--select *
                     from DimUserParameters_Mod U

				
					 WHERE 
					 U.EffectiveFromTimeKey <= @TimeKey
                           AND U.EffectiveToTimeKey >= @TimeKey
						   --AND ShortNameEnum in('NONUSE','UNLOGON')
                                  
					     

                                  AND ISNULL(U.AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')
                           AND U.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM DimUserParameters_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
				
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')
                         GROUP BY ShortNameEnum
                     )
                 ) A 
                      
                 
                 GROUP BY A.ShortNameEnum,
								A.ParameterType,
								A.ParameterValue,
								A.SeqNo,
								A.MinValue,
								A.MaxValue,
							
							A.AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifyBy, 
                            A.DateModified,
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate,
							A.IsMainTable,
							A.CreatedModifiedBy

                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY ShortNameEnum) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'UserPolicyTable' TableName, 
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

				 SELECT 'Sac' as qw1,CtrlName
					,FldName
					,FldCaption
					,FldDataType
					,FldLength
					,ErrorCheck
					,DataSeq
					,CriticalErrorType
					,MsgFlag
					,MsgDescription
					,ReportFieldNo
					,ScreenFieldNo
					,ViableForSCD2

					  from metaUserFieldDetail WHERE FrmName ='frmUserPolicy' 

					  SELECT MsgDescription , 
		ParameterType,
		ParameterValue,
		MinValue,
		MaxValue,
		IsMainTable,
		CreatedModifiedBy,
		--,SeqNo
		'HO' UserLocation,
		dimUser.AuthorisationStatus ,
                            dimUser.EffectiveFromTimeKey, 
                            dimUser.EffectiveToTimeKey, 
                            dimUser.CreatedBy, 
                            dimUser.DateCreated, 
                            dimUser.ApprovedBy, 
                            dimUser.DateApproved, 
                            dimUser.ModifyBy, 
                            dimUser.DateModified,
							dimUser.CrModBy,
							dimUser.CrModDate,
							dimUser.CrAppBy,
							dimUser.CrAppDate,
							dimUser.ModAppBy,
							dimUser.ModAppDate,
							dimUser.IsMainTable,
							dimUser.CreatedModifiedBy

		FROM metaUserFieldDetail  meta
		INNER JOIN #temp dimUser
		ON meta.FldCaption = dimUser.ShortNameEnum
		--left join DimUserInfo D
		--ON D.UserLoginID=dimuser.CreatedModifiedBy
		WHERE FrmName ='frmUserPolicy' 
		AND (dimUser.EffectiveFromTimeKey <=@TimeKey AND dimUser.EffectiveToTimekey>=@TimeKey) 
		--AND SeqNo IN (1,6)
		GROUP BY
		MsgDescription , 
		ParameterType,
		ParameterValue,
		MinValue,
		MaxValue,
		IsMainTable,
		CreatedModifiedBy,
		SeqNo,
		dimUser.AuthorisationStatus ,
                            dimUser.EffectiveFromTimeKey, 
                            dimUser.EffectiveToTimeKey, 
                            dimUser.CreatedBy, 
                            dimUser.DateCreated, 
                            dimUser.ApprovedBy, 
                            dimUser.DateApproved, 
                            dimUser.ModifyBy, 
                            dimUser.DateModified,
							dimUser.CrModBy,
							dimUser.CrModDate,
							dimUser.CrAppBy,
							dimUser.CrAppDate,
							dimUser.ModAppBy,
							dimUser.ModAppDate,
							dimUser.IsMainTable,
							dimUser.CreatedModifiedBy
		ORDER BY SeqNo
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
                 --      AND RowNumber <= (@PageNo * @PageSize);
             END;
             ELSE

			 /*  IT IS Used For GRID Search which are Pending for Authorization    */
			 IF(@OperationFlag  in (16,17))

             BEGIN
			 IF OBJECT_ID('TempDB..#temp16') IS NOT NULL
                 DROP TABLE #temp16;
				 PRINT 'Sac16'
                  SELECT			A.ShortNameEnum,
								A.ParameterType,
								A.ParameterValue,
								A.SeqNo,
								A.MinValue,
								A.MaxValue,
							
							A.AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifyBy, 
                            A.DateModified,
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate,
							A.IsMainTable,
							A.CreatedModifiedBy
                 INTO #temp16
                 FROM 
                 (
                     SELECT 
							  
						   DISTINCT 
							U.ShortNameEnum,
								U.ParameterType,
								U.ParameterValue,
								U.SeqNo,
								U.MinValue,
								U.MaxValue,
						   --,'QuickSearchTable' as TableName
						
							isnull(U.AuthorisationStatus, 'A') AuthorisationStatus, 
                       U.EffectiveFromTimeKey, 
                            U.EffectiveToTimeKey, 
                            U.CreatedBy, 
                            U.DateCreated, 
                            U.ApprovedBy, 
                            U.DateApproved, 
                            U.ModifyBy, 
                            U.DateModified
							,IsNull(U.ModifyBy,U.CreatedBy)as CrModBy
							,IsNull(U.DateModified,U.DateCreated)as CrModDate
							,ISNULL(U.ApprovedBy,U.CreatedBy) as CrAppBy
							,ISNULL(U.DateApproved,U.DateCreated) as CrAppDate
							,ISNULL(U.ApprovedBy,U.ModifyBy) as ModAppBy
							,ISNULL(U.DateApproved,U.DateModified) as ModAppDate
								,'N' AS IsMainTable
				          ,  CASE WHEN ISNULL(U.ModifyBy,'')='' THEN U.CreatedBy ELSE U.ModifyBy END  AS CreatedModifiedBy
							--select *
                     from DimUserParameters U

				
					 WHERE 
					 U.EffectiveFromTimeKey <= @TimeKey
                           AND U.EffectiveToTimeKey >= @TimeKey
						   --AND ShortNameEnum in('NONUSE','UNLOGON')
                           AND ISNULL(U.AuthorisationStatus, 'A') = 'A'
						          AND U.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM DimUserParameters
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
							  
                               AND ISNULL(AuthorisationStatus, 'A') IN('A')
                         GROUP BY ShortNameEnum
                     )

                     UNION
                    SELECT 
							  
						   DISTINCT 
							U.ShortNameEnum,
								U.ParameterType,
								U.ParameterValue,
								U.SeqNo,
								U.MinValue,
								U.MaxValue,
						   --,'QuickSearchTable' as TableName
						
							isnull(U.AuthorisationStatus, 'A') AuthorisationStatus, 
                            U.EffectiveFromTimeKey, 
                            U.EffectiveToTimeKey, 
                            U.CreatedBy, 
                            U.DateCreated, 
                            U.ApprovedBy, 
                            U.DateApproved, 
                            U.ModifyBy, 
                            U.DateModified
							,IsNull(U.ModifyBy,U.CreatedBy)as CrModBy
							,IsNull(U.DateModified,U.DateCreated)as CrModDate
							   ,ISNULL(U.ApprovedBy,U.ApprovedByFirstLevel) as CrAppBy
							,ISNULL(U.DateApproved,U.DateApprovedFirstLevel) as CrAppDate
							,ISNULL(U.ApprovedBy,U.ModifyBy) as ModAppBy
							,ISNULL(U.DateApproved,U.DateModified) as ModAppDate
							,'N' AS IsMainTable
				          ,  CASE WHEN ISNULL(U.ModifyBy,'')='' THEN U.CreatedBy ELSE U.ModifyBy END  AS CreatedModifiedBy
							--select *
                     from DimUserParameters_Mod U

				
					 WHERE 
					 U.EffectiveFromTimeKey <= @TimeKey
                           AND U.EffectiveToTimeKey >= @TimeKey
						   --AND ShortNameEnum in('NONUSE','UNLOGON')
                                  
					     

                                  AND ISNULL(U.AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')
                           AND U.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM DimUserParameters_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
				
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')
                         GROUP BY ShortNameEnum
                     )
                 ) A 
                      
                 
                 GROUP BY A.ShortNameEnum,
								A.ParameterType,
								A.ParameterValue,
								A.SeqNo,
								A.MinValue,
								A.MaxValue,
							
							A.AuthorisationStatus, 
          A.EffectiveFromTimeKey, 
              A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifyBy, 
                            A.DateModified,
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate,
							A.IsMainTable,
							A.CreatedModifiedBy

                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY ShortNameEnum) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'UserPolicyTable' TableName, 
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

				  SELECT CtrlName
					,FldName
					,FldCaption
					,FldDataType
					,FldLength
					,ErrorCheck
					,DataSeq
					,CriticalErrorType
					,MsgFlag
					,MsgDescription
					,ReportFieldNo
					,ScreenFieldNo
					,ViableForSCD2

					  from metaUserFieldDetail WHERE FrmName ='frmUserPolicy' 

					  SELECT  MsgDescription , 
		ParameterType,
		ParameterValue,
		MinValue,
		MaxValue,
		IsMainTable,
		CreatedModifiedBy,
		--,SeqNo
		'HO' UserLocation,
		dimUser.AuthorisationStatus ,
                            dimUser.EffectiveFromTimeKey, 
                            dimUser.EffectiveToTimeKey, 
                            dimUser.CreatedBy, 
                            dimUser.DateCreated, 
                            dimUser.ApprovedBy, 
                            dimUser.DateApproved, 
                            dimUser.ModifyBy, 
                            dimUser.DateModified,
							dimUser.CrModBy,
							dimUser.CrModDate,
							dimUser.CrAppBy,
							dimUser.CrAppDate,
							dimUser.ModAppBy,
							dimUser.ModAppDate,
							dimUser.IsMainTable,
							dimUser.CreatedModifiedBy

		FROM metaUserFieldDetail  meta
		INNER JOIN #temp16 dimUser
		ON meta.FldCaption = dimUser.ShortNameEnum
		--left join DimUserInfo D
		--ON D.UserLoginID=dimuser.CreatedModifiedBy
		WHERE FrmName ='frmUserPolicy' 
		AND (dimUser.EffectiveFromTimeKey <=@TimeKey AND dimUser.EffectiveToTimekey>=@TimeKey) 
		--AND SeqNo IN (1,6)
		GROUP BY
		MsgDescription , 
		ParameterType,
		ParameterValue,
		MinValue,
		MaxValue,
		IsMainTable,
		CreatedModifiedBy,
		SeqNo,
		dimUser.AuthorisationStatus ,
                            dimUser.EffectiveFromTimeKey, 
                            dimUser.EffectiveToTimeKey, 
                            dimUser.CreatedBy, 
                            dimUser.DateCreated, 
                            dimUser.ApprovedBy, 
                            dimUser.DateApproved, 
                            dimUser.ModifyBy, 
                            dimUser.DateModified,
							dimUser.CrModBy,
							dimUser.CrModDate,
							dimUser.CrAppBy,
							dimUser.CrAppDate,
							dimUser.ModAppBy,
							dimUser.ModAppDate,
							dimUser.IsMainTable,
							dimUser.CreatedModifiedBy
		ORDER BY SeqNo
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
                 --      AND RowNumber <= (@PageNo * @PageSize)

   END;

   IF(@OperationFlag  in (20))

             BEGIN
			 IF OBJECT_ID('TempDB..#temp20') IS NOT NULL
                 DROP TABLE #temp20;
                 SELECT			A.ShortNameEnum,
								A.ParameterType,
								A.ParameterValue,
								A.SeqNo,
								A.MinValue,
								A.MaxValue,
							
							A.AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifyBy, 
                            A.DateModified,
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate,
							A.IsMainTable,
							A.CreatedModifiedBy
                 INTO #temp20
                 FROM 
                 (
                     SELECT 
							  
						   DISTINCT 
							U.ShortNameEnum,
								U.ParameterType,
								U.ParameterValue,
								U.SeqNo,
								U.MinValue,
								U.MaxValue,
						   --,'QuickSearchTable' as TableName
						
							isnull(U.AuthorisationStatus, 'A') AuthorisationStatus, 
                            U.EffectiveFromTimeKey, 
                            U.EffectiveToTimeKey, 
                            U.CreatedBy, 
                            U.DateCreated, 
                            U.ApprovedBy, 
                            U.DateApproved, 
                            U.ModifyBy, 
                            U.DateModified
							,IsNull(U.ModifyBy,U.CreatedBy)as CrModBy
							,IsNull(U.DateModified,U.DateCreated)as CrModDate
							,ISNULL(U.ApprovedBy,U.CreatedBy) as CrAppBy
							,ISNULL(U.DateApproved,U.DateCreated) as CrAppDate
							,ISNULL(U.ApprovedBy,U.ModifyBy) as ModAppBy
							,ISNULL(U.DateApproved,U.DateModified) as ModAppDate
								,'N' AS IsMainTable
				          ,  CASE WHEN ISNULL(U.ModifyBy,'')='' THEN U.CreatedBy ELSE U.ModifyBy END  AS CreatedModifiedBy
							--select *
                     from DimUserParameters U

				
					 WHERE 
					 U.EffectiveFromTimeKey <= @TimeKey
                           AND U.EffectiveToTimeKey >= @TimeKey
						   --AND ShortNameEnum in('NONUSE','UNLOGON')
                           AND ISNULL(U.AuthorisationStatus, 'A') = 'A'
						          AND U.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM DimUserParameters
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
							  
                               AND ISNULL(AuthorisationStatus, 'A') IN('A')
                         GROUP BY ShortNameEnum
                     )

                     UNION
                    SELECT 
							  
						   DISTINCT 
							U.ShortNameEnum,
								U.ParameterType,
								U.ParameterValue,
								U.SeqNo,
								U.MinValue,
								U.MaxValue,
						   --,'QuickSearchTable' as TableName
						
							isnull(U.AuthorisationStatus, 'A') AuthorisationStatus, 
                            U.EffectiveFromTimeKey, 
                            U.EffectiveToTimeKey, 
                            U.CreatedBy, 
                            U.DateCreated, 
                            U.ApprovedBy, 
                            U.DateApproved, 
                            U.ModifyBy, 
                            U.DateModified
							,IsNull(U.ModifyBy,U.CreatedBy)as CrModBy
							,IsNull(U.DateModified,U.DateCreated)as CrModDate
						   ,ISNULL(U.ApprovedBy,U.ApprovedByFirstLevel) as CrAppBy
							,ISNULL(U.DateApproved,U.DateApprovedFirstLevel) as CrAppDate
							,ISNULL(U.ApprovedBy,U.ModifyBy) as ModAppBy
							,ISNULL(U.DateApproved,U.DateModified) as ModAppDate
							,'N' AS IsMainTable
				          ,  CASE WHEN ISNULL(U.ModifyBy,'')='' THEN U.CreatedBy ELSE U.ModifyBy END  AS CreatedModifiedBy
							--select *
                     from DimUserParameters_Mod U

				
					 WHERE 
					 U.EffectiveFromTimeKey <= @TimeKey
                           AND U.EffectiveToTimeKey >= @TimeKey
						   --AND ShortNameEnum in('NONUSE','UNLOGON')
                                  
					     

                                  AND ISNULL(U.AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')
                           AND U.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM DimUserParameters_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
				
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')
                         GROUP BY ShortNameEnum
                     )
                 ) A 
                      
                 
                 GROUP BY A.ShortNameEnum,
								A.ParameterType,
								A.ParameterValue,
								A.SeqNo,
								A.MinValue,
								A.MaxValue,
							
							A.AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifyBy, 
                            A.DateModified,
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate,
							A.IsMainTable,
							A.CreatedModifiedBy

                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY ShortNameEnum) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'UserPolicyTable' TableName, 
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

				 
				  SELECT CtrlName
					,FldName
					,FldCaption
					,FldDataType
					,FldLength
					,ErrorCheck
					,DataSeq
					,CriticalErrorType
					,MsgFlag
					,MsgDescription
					,ReportFieldNo
					,ScreenFieldNo
					,ViableForSCD2

					  from metaUserFieldDetail WHERE FrmName ='frmUserPolicy' 

					  SELECT  MsgDescription , 
		ParameterType,
		ParameterValue,
		MinValue,
		MaxValue,
		IsMainTable,
		CreatedModifiedBy,
		--,SeqNo
		'HO' UserLocation,
		dimUser.AuthorisationStatus ,
                            dimUser.EffectiveFromTimeKey, 
                            dimUser.EffectiveToTimeKey, 
                            dimUser.CreatedBy, 
                            dimUser.DateCreated, 
                            dimUser.ApprovedBy, 
                            dimUser.DateApproved, 
                            dimUser.ModifyBy, 
                            dimUser.DateModified,
							dimUser.CrModBy,
							dimUser.CrModDate,
							dimUser.CrAppBy,
							dimUser.CrAppDate,
							dimUser.ModAppBy,
							dimUser.ModAppDate,
							dimUser.IsMainTable,
							dimUser.CreatedModifiedBy
		FROM metaUserFieldDetail  meta
		INNER JOIN #temp20 dimUser
		ON meta.FldCaption = dimUser.ShortNameEnum
		--left join DimUserInfo D
		--ON D.UserLoginID=dimuser.CreatedModifiedBy
		WHERE FrmName ='frmUserPolicy' 
		AND (dimUser.EffectiveFromTimeKey <=@TimeKey AND dimUser.EffectiveToTimekey>=@TimeKey) 
		--AND SeqNo IN (1,6)
		GROUP BY
		MsgDescription  ,
		ParameterType,
		ParameterValue,
		MinValue,
		MaxValue,
		IsMainTable,
		CreatedModifiedBy,
		SeqNo,
		dimUser.AuthorisationStatus ,
                            dimUser.EffectiveFromTimeKey, 
                            dimUser.EffectiveToTimeKey, 
                            dimUser.CreatedBy, 
                            dimUser.DateCreated, 
                            dimUser.ApprovedBy, 
                            dimUser.DateApproved, 
                            dimUser.ModifyBy, 
                            dimUser.DateModified,
							dimUser.CrModBy,
							dimUser.CrModDate,
							dimUser.CrAppBy,
							dimUser.CrAppDate,
							dimUser.ModAppBy,
							dimUser.ModAppDate,
							dimUser.IsMainTable,
							dimUser.CreatedModifiedBy
		ORDER BY SeqNo
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


  
  
    END;

GO