SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- ============================================= 
--Exec [WilfulDefaulterDirectorDetailGrid] @OperationFlag = 1 
-- Author:    <FARAHNAAZ>  
-- Create date:   <1/04/2021>  
-- Description:   <Grid SP for [WilfulDefaulterDirectorDetailGrid]>
-- =============================================  
CREATE PROCEDURE [dbo].[WilfulDefaulterDirectorDetailGrid]

--Declare 
					--@DirectoreName			Varchar(100) ='',
					--@Pan					Varchar(10)='',
					--@Din					Numeric(8,2),
					--@DirectorType			varchar(50)=''
					@OperationFlag  INT         = 1
AS
     
	 BEGIN

SET NOCOUNT ON;
Declare @TimeKey as Int
	SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')


			
    Begin Try
		
	IF(@OperationFlag not in ( 16,17))
             BEGIN
			 IF OBJECT_ID('TempDB..#temp') IS NOT NULL
                 DROP TABLE  #temp;

			 
                 SELECT Z.Entity_Key,
						Z.DirectorName,
						Z.PAN,
						Z.DIN,
						Z.DirectorTypeAlt_Key,
						Z.AuthorisationStatus,
						Z.EffectiveFromTimeKey,
						Z.EffectiveToTimeKey,
						Z.CreatedBy,
						Z.DateCreated,
						Z.ModifiedBy,
						Z.DateModified,
						Z.ApprovedBy,
						Z.DateApproved 

						  INTO #temp
                 FROM 
                 (
                     SELECT 
						A.Entity_Key,
						A.DirectorName,
						A.PAN,
						A.DIN,
						A.DirectorTypeAlt_Key,
						B.ParameterName as DirectoryType,
						A.AuthorisationStatus,
						A.EffectiveFromTimeKey,
						A.EffectiveToTimeKey,
						A.CreatedBy,
						A.DateCreated,
						A.ModifiedBy,
						A.DateModified,
						A.ApprovedBy,
						A.DateApproved 

				From WilfulDirectorDetail A
				Inner Join (Select ParameterAlt_Key,ParameterName,'DirectorType' as Tablename 
						  from DimParameter where DimParameterName='DirectorType'
						  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)B
						  ON A.DirectorTypeAlt_Key=B.ParameterAlt_Key
				Union

					
                     SELECT 
						A.Entity_Key,
						A.DirectorName,
						A.PAN,
						A.DIN,
						A.DirectorTypeAlt_Key,
						B.ParameterName as DirectoryType,
						A.AuthorisationStatus,
						A.EffectiveFromTimeKey,
						A.EffectiveToTimeKey,
						A.CreatedBy,
						A.DateCreated,
						A.ModifiedBy,
						A.DateModified,
						A.ApprovedBy,
						A.DateApproved 
						
						FROM WilfulDirectorDetail_Mod A
						iNNER jOIN (Select ParameterAlt_Key,ParameterName,'DirectorType' as Tablename 
						  from DimParameter where DimParameterName='DirectorType'
						  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)B
						  ON A.DirectorTypeAlt_Key=B.ParameterAlt_Key

						  AND A.Entity_Key IN
                     (
                         SELECT MAX(Entity_Key)
                         FROM WilfulDirectorDetail_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')
                         GROUP BY DirectorName
                     )
					)   Z 

				 GROUP BY
							Z.Entity_Key,
							Z.DirectorName,
							Z.PAN,
							Z.DIN,
							Z.DirectorTypeAlt_Key,
							Z.AuthorisationStatus,
							Z.EffectiveFromTimeKey,
							Z.EffectiveToTimeKey,
							Z.CreatedBy,
							Z.DateCreated,
							Z.ModifiedBy,
							Z.DateModified,
							Z.ApprovedBy,
							Z.DateApproved 


				  SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY DirectorName) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'DirectorName' TableName, 
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
                 SELECT	
							P.Entity_Key,
							P.DirectorName,
							P.PAN,
							P.DIN,
							P.DirectorTypeAlt_Key,
							P.AuthorisationStatus,
							P.EffectiveFromTimeKey,
							P.EffectiveToTimeKey,
							P.CreatedBy,
							P.DateCreated,
							P.ModifiedBy,
							P.DateModified,
							P.ApprovedBy,
							P.DateApproved 

					 INTO #temp16
                 FROM 
                 (
                     SELECT		A.Entity_Key,
						A.DirectorName,
						A.PAN,
						A.DIN,
						A.DirectorTypeAlt_Key,
						B.ParameterName as DirectoryType,
						A.AuthorisationStatus,
						A.EffectiveFromTimeKey,
						A.EffectiveToTimeKey,
						A.CreatedBy,
						A.DateCreated,
						A.ModifiedBy,
						A.DateModified,
						A.ApprovedBy,
						A.DateApproved 

				From WilfulDirectorDetail A
				Inner Join (Select ParameterAlt_Key,ParameterName,'DirectorType' as Tablename 
						  from DimParameter where DimParameterName='DirectorType'
						  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)B
						  ON A.DirectorTypeAlt_Key=B.ParameterAlt_Key
				
							    AND A.Entity_Key IN
                     (
                         SELECT MAX(Entity_Key)
                         FROM WilfulDirectorDetail_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')
                         GROUP BY DirectorName
                     )
                 ) P

				 Group By P.Entity_Key,
							P.DirectorName,
							P.PAN,
							P.DIN,
							P.DirectorTypeAlt_Key,
							P.AuthorisationStatus,
							P.EffectiveFromTimeKey,
							P.EffectiveToTimeKey,
							P.CreatedBy,
							P.DateCreated,
							P.ModifiedBy,
							P.DateModified,
							P.ApprovedBy,
							P.DateApproved 

							 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY DirectorName) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'DirectorName' TableName, 
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
	

	--Select * from WilfulDirectorDetail_Mod
GO