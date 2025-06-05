SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROC [dbo].[CollateralOwnerSearchList]
--Declare
													
													--@PageNo         INT         = 1, 
													--@PageSize       INT         = 10, 
													@OperationFlag  INT         = 1,
													@CollateralID  varchar(30)	= ''
AS
     
	 BEGIN

SET NOCOUNT ON;
Declare @TimeKey as Int
	SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')
					

BEGIN TRY

/*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */

			IF(@OperationFlag not in ( 17))
             BEGIN
			 IF OBJECT_ID('TempDB..#temp') IS NOT NULL
                 DROP TABLE  #temp;
                 SELECT		A.CollateralID
							,A.CustomeroftheBankAlt_Key
							,A.CustomeroftheBank 
							,A.AccountID
							,A.CustomerID
							,A.OtherOwnerName
							,A.PAN
							,A.OtherOwnerRelationshipAlt_Key
							,A.CollOwnerDescription
							,A.IfRelationselectAlt_Key
							,A. IfRelationselect
							,A.AddressType
							,A.Company
							,A.AddressLine1
							,A.AddressLine2
							,A.AddressLine3
							,A.City
							,A.PinCode
							,A.Country
							,A.State
							,A.District
							,A.STDCodeO
							,A.PhoneNumberO
							,A.STDCodeR
							,A.PhoneNumberR
							,A.FaxNumber
							,A.MobileNO
							,A.AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified
                 INTO #temp
                 FROM 
                 (
                     SELECT 
							A.CollateralID
							,A.CustomeroftheBankAlt_Key
							,B.ParameterName as CustomeroftheBank 
							,A.AccountID
							,A.CustomerID
							,A.OtherOwnerName
							,A.PAN
							,A.OtherOwnerRelationshipAlt_Key
							,G.CollOwnerDescription
							,A.IfRelationselectAlt_Key
							,B.ParameterName as IfRelationselect
							,A.AddressType
							,A.Company
							,A.AddressLine1
							,A.AddressLine2
							,A.AddressLine3
							,A.City
							,A.PinCode
							,A.Country
							,A.State
							,A.District
							,A.STDCodeO
							,A.PhoneNumberO
							,A.STDCodeR
							,A.PhoneNumberR
							,A.FaxNumber
							,A.MobileNO
							,isnull(A.AuthorisationStatus, 'A') AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified
                     FROM CollateralOtherOwner A
					 Left Join (Select ParameterAlt_Key,ParameterName,'CustomeroftheBank' as Tablename 
						  from DimParameter where DimParameterName='DimYesNo'
						  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)B
						  ON A.CustomeroftheBankAlt_Key=B.ParameterAlt_Key
						  Left Join (Select ParameterAlt_Key,ParameterName,'Relation' as Tablename 
						  from DimParameter where DimParameterName='Relation'
						  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)C
						  ON A.IfRelationselectAlt_Key=C.ParameterAlt_Key
						  Left join DimCollateralOwnerType G
						  ON A.OtherOwnerRelationshipAlt_Key=G.CollateralOwnerTypeAltKey
						  AND CollOwnerDescription not in ('Primary Customer','Proprietor')
						  And G.EffectiveFromTimeKey<=@Timekey And G.EffectiveToTimeKey>=@TimeKey

					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
						   AND A.OtherOwnerRelationshipAlt_Key IS NOT NULL
                           --AND A.Entity_Key IN
                     --(
                     --    SELECT MAX(Entity_Key)
                     --    FROM CollateralOtherOwner
                     --    WHERE EffectiveFromTimeKey <= @TimeKey
                     --          AND EffectiveToTimeKey >= @TimeKey
                     --          AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')
                     --    GROUP BY CollateralID
                     --)
                 ) A 
                      
                 
                 GROUP BY A.CollateralID
							,A.CustomeroftheBankAlt_Key
							,A.CustomeroftheBank 
							,A.AccountID
							,A.CustomerID
							,A.OtherOwnerName
							,A.PAN
							,A.OtherOwnerRelationshipAlt_Key
							,A.CollOwnerDescription
							,A.IfRelationselectAlt_Key
							,A.IfRelationselect
							,A.AddressType
							,A.Company
							,A.AddressLine1
							,A.AddressLine2
							,A.AddressLine3
							,A.City
							,A.PinCode
							,A.Country
							,A.State
							,A.District
							,A.STDCodeO
							,A.PhoneNumberO
							,A.STDCodeR
							,A.PhoneNumberR
							,A.FaxNumber
							,A.MobileNO
							,A.AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified;

                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY CollateralID) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'Collateral' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp A where A.CollateralID=@CollateralID
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
                 --      AND RowNumber <= (@PageNo * @PageSize);
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