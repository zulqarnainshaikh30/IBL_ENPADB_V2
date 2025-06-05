SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROC [dbo].[CollateralOwnerAddressSearchList]
--Declare
--Exec [dbo].[CollateralOwnerAddressSearchList] @OperationFlag =1,@CollateralID='234'
													
													--@PageNo         INT         = 1, 
													--@PageSize       INT         = 10, 
													@OperationFlag  INT         = 1,
													@CollateralID varchar(30)='' ---Adding One more Parameter
AS

     
	 BEGIN

SET NOCOUNT ON;
Declare @TimeKey as Int
	SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')
					

BEGIN TRY

/*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */

			IF(@OperationFlag not in ( 16,17))
             BEGIN
			 IF OBJECT_ID('TempDB..#temp') IS NOT NULL
                 DROP TABLE  #temp;
                 SELECT		A.CollateralID
							,A.AddressType
							,A.Company Category
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
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
                     --      AND A.Entity_Key IN
                     --(
                     --    SELECT MAX(Entity_Key)
                     --    FROM CollateralOtherOwner
                     --    WHERE EffectiveFromTimeKey <= @TimeKey
                     --          AND EffectiveToTimeKey >= @TimeKey
                     --          AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')
                     --    GROUP BY CollateralID
                     --)
                 ) A 
                      
                 
                 GROUP BY	A.CollateralID
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
                         FROM #temp A where CollateralID= @CollateralID And A.AddressType IS NOT NULL
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