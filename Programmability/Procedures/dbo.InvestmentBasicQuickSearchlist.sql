SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROC [dbo].[InvestmentBasicQuickSearchlist]
--DeclareAMIT CONTINUE YOUR WORK
													 @IssuerID			Varchar (100)		= '10004'
													 ,@IssuerName		Varchar (100)		= ''
													 ,@InvID     Varchar (100)			 = ''
													 ,@InstrumentType   Varchar (100)       = ''
													 ,@ISIN             Varchar (100)       = ''
													--,@InvID				Varchar (100)		= ''
													--,@InstrTypeAlt_key	Varchar (100)		= ''
													--,@ISIN				varchar (100)		= ''
													 ,@OperationFlag		INT					= 1
AS
     
	 BEGIN

SET NOCOUNT ON;
Declare @TimeKey as Int
	SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')
					

BEGIN TRY

/*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */

			IF(@OperationFlag not in(16,20))
             BEGIN
			 IF OBJECT_ID('TempDB..#temp') IS NOT NULL
                 DROP TABLE  #temp;
                 SELECT		A.EntityKey,
							A.BranchCode,  
							A.SourceAlt_key,
							a.SourceName,   
							A.IssuerID,
				            A.IssuerName,
							A.InvID,
							A.ISIN,
                            A.InstrTypeAlt_Key,
                            A.InstrumentTypeName,
							A.InstrName,
							--A.Currency_AltKey,
				            --B.CurrencyName as Currency,
                            A.InvestmentNature,
                            A.Sector,
							A.Industry_AltKey,
                            A.Industry,
                            A.ExposureType,
                            A.SecurityValue,
                            CONVERT(varchar,A.MaturityDt,103)MaturityDt,
							CONVERT(varchar,A.ReStructureDate,103)ReStructureDate,
                                                  
				 ----------------------------------------------------------------------------
				            
                            A.AuthorisationStatus,
                            A.EffectiveFromTimeKey,
                            A.EffectiveToTimeKey,
								A.CreatedBy,
								A.DateCreated,
								A.ModifiedBy,
								A.DateModified,
								A.CrModBy,
							    A.CrModDate,
								A.ApprovedBy,
								A.DateApproved,
								A.changeFields
                 INTO #temp
                 FROM 
                 (
                     SELECT 
							 A.EntityKey,
							 b.BranchCode,
							 B.SourceAlt_key,
							 v.SourceName,
							 A.RefIssuerID as IssuerID,
				            B.IssuerName,
							 A.InvID,
							A.ISIN,
                           A.InstrTypeAlt_Key,
                            D.InstrumentTypeName,
                            A.InstrName,
							--A.Currency_AltKey,
				            --B.CurrencyName as Currency,
                            X.parameteralt_key as InvestmentNature,
                             Y.SubSectorAlt_Key as Sector,
							A.Industry_AltKey,
                            C.IndustryName as Industry,
                            Z.Parameteralt_key as ExposureType,
                            A.SecurityValue,
                            A.MaturityDt,
							A.ReStructureDate,                       
				 ----------------------------------------------------------------------------
				            
                            A.AuthorisationStatus,
                            A.EffectiveFromTimeKey,
                            A.EffectiveToTimeKey,
								A.CreatedBy,
								A.DateCreated,
								A.ModifiedBy,
								A.DateModified,
								IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy,
							IsNull(A.DateModified,A.DateCreated)as CrModDate,
								A.ApprovedBy,
								A.DateApproved
								,'' AS changeFields
                      FROM InvestmentBasicDetail A 
				  left join investmentissuerdetail B on A.RefIssuerID=B.IssuerID
				  left join diminstrumenttype D on A.InstrTypeAlt_Key=D.InstrumentTypeAlt_Key
				    left join (select parameteralt_key,parametername,'investmentNature' TableName 
				  from dimparameter where dimParameterName='diminstrumentnature' 
				  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)X 
				  ON A.InvestmentNature = X.parametername
				  LEFT JOIN (select SubSectorAlt_Key,SubSectorName,'Sector' TableName 
				  from DimSubSector where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)Y
				  ON A.Sector = Y.SubSectorName
				  LEFT JOIN (select ParameterAlt_Key,ParameterName,'ExposureType' TableName 
								from dimparameter where dimparametername='dimexposuretype' 
				  and EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)Z
				  ON A.ExposureType = Z.ParameterName
					Left join	DIMSOURCEDB v on b.SourceAlt_Key=v.SourceAlt_Key										 
					 left join	Dimindustry C on A.Industry_ALtKey = C.IndustryAlt_Key
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
						   AND ISNULL(b.AuthorisationStatus, 'A') = 'A'
                     UNION
                     SELECT  A.EntityKey,							
							 B.BranchCode,
							 B.SourceAlt_key,
							 v.SourceName,
							 A.RefIssuerID as IssuerID,
				            B.IssuerName,
							 A.InvID,
							A.ISIN,
                           A.InstrTypeAlt_Key,
                            D.InstrumentTypeName,
                            A.InstrName,
							--A.Currency_AltKey,
				            --B.CurrencyName as Currency,
                            X.parameteralt_key as InvestmentNature,
                           Y.SubSectorAlt_Key as Sector,
							A.Industry_AltKey,
                            C.IndustryName as Industry,
                            Z.Parameteralt_key as ExposureType,
                            A.SecurityValue,
                            A.MaturityDt,
							A.ReStructureDate,                       
                            A.AuthorisationStatus,
                            A.EffectiveFromTimeKey,
                            A.EffectiveToTimeKey,
								A.CreatedBy,
								A.DateCreated,
								A.ModifiedBy,
								A.DateModified,
								IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy,
							IsNull(A.DateModified,A.DateCreated)as CrModDate,
								A.ApprovedBy,
								A.DateApproved
								,a.changeFields
                     FROM InvestmentBasicDetail_mod A 
				  left join investmentissuerdetail_mod B on A.RefIssuerID=B.IssuerID
				  left join diminstrumenttype D on A.InstrTypeAlt_Key=D.InstrumentTypeAlt_Key
				  left join (	select parameteralt_key,parametername,'investmentNature' TableName 
								from dimparameter where dimParameterName='diminstrumentnature' 
								And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
								)X 
								ON A.InvestmentNature = X.parametername
				  LEFT JOIN (select SubSectorAlt_Key,SubSectorName,'Sector' TableName 
							from DimSubSector 
							where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
							)Y
				  ON A.Sector = Y.SubSectorName
				  LEFT JOIN (select ParameterAlt_Key,ParameterName,'ExposureType' TableName 
								from dimparameter where dimparametername='dimexposuretype' 
				  and EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)Z
				  ON A.ExposureType = Z.ParameterName
					Left join	DIMSOURCEDB V on b.SourceAlt_Key=V.SourceAlt_Key												 
					 left join	Dimindustry C on A.Industry_ALtKey = C.IndustryAlt_Key
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                           AND A.EntityKey IN
                     (
                        SELECT MAX(EntityKey)
                         FROM InvestmentBasicDetail_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(a.AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')	
							   AND ISNULL(b.AuthorisationStatus, 'A') = 'A'						  
                         GROUP BY EntityKey
                     )
                 ) A 
                      
                 
                 GROUP BY	A.EntityKey,
							A.BranchCode,  
							A.SourceAlt_key,
							a.SourceName,   
							A.IssuerID,
				            A.IssuerName,
							 A.InvID,
							A.ISIN,
                            A.InstrTypeAlt_Key,
                            A.InstrumentTypeName,
							A.InstrName,
							--A.Currency_AltKey,
				            --B.CurrencyName as Currency,
                            A.InvestmentNature,
                            A.Sector,
							A.Industry_AltKey,
                            A.Industry,
                            A.ExposureType,
                            A.SecurityValue,
                            A.MaturityDt,
							A.ReStructureDate,
                       
                            
				 ----------------------------------------------------------------------------
				            
                            A.AuthorisationStatus,
                            A.EffectiveFromTimeKey,
                            A.EffectiveToTimeKey,
								A.CreatedBy,
								A.DateCreated,
								A.ModifiedBy,
								A.DateModified,
								A.CrModBy,
							A.CrModDate,
								A.ApprovedBy,
								A.DateApproved,
								A.changeFields

                SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY Entitykey) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'InvestmentCodeMaster' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp A
                         WHERE   (ISNULL(InvID, '')				LIKE '%'+@InvID+'%'
                         AND ISNULL(IssuerID, '')				LIKE '%'+@IssuerID+'%'
						  AND ISNULL(IssuerName, '')			LIKE '%'+@IssuerName+'%'
						   AND ISNULL(InstrumentTypeName, '')	LIKE '%'+@InstrumentType+'%'
						    AND ISNULL(ISIN, '')				LIKE '%'+@ISIN+'%' 				
						   
							--OR(InvID	=@InvID)				
							--OR(InstrTypeAlt_key		=@InstrTypeAlt_key)	
							--OR(ISIN		=@ISIN)
							)
                     ) AS DataPointOwner
                 ) AS DataPointOwner
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
                 --      AND RowNumber <= (@PageNo * @PageSize);
             END;
             

			 /*  IT IS Used For GRID Search which are Pending for Authorization    */

			
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