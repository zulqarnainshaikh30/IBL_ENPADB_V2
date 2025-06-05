SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROC [dbo].[RP_LenderAuthorizeSelect]

				@OperationFlag			INT        
				,@UserId				VARCHAR(30)
AS
     
	 BEGIN

SET NOCOUNT ON;
Declare @TimeKey as Int
	SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')
					

BEGIN TRY



			IF(@OperationFlag = 2)

			   BEGIN
			 
                     SELECT 
							A.CustomerEntityID
							,A.UCIC_ID
							,A.CustomerID
							,A.PAN_No
							,A.CustomerName
							,A.LenderName
							,(case when convert(DATE,A.InDefaultDate)='' then NULL else Convert(VARCHAR(20),InDefaultDate,103) End) InDefaultDate
							,(case when convert(DATE,A.OutOfDefaultDate)='' then NULL else Convert(VARCHAR(20),OutOfDefaultDate,103) End) OutOfDefaultDate,
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
							,'LenderDataUpload' TableName
                     FROM RP_Lender_Upload_Mod A
					 
					WHERE ISNULL(A.AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')
                         
                   
             END;



			IF(@OperationFlag = 16)

			   BEGIN
			 
                     SELECT 
							A.CustomerEntityID
							,A.UCIC_ID
							,A.CustomerID
							,A.PAN_No
							,A.CustomerName
							,A.LenderName
							,(case when convert(DATE,A.InDefaultDate)='' then NULL else Convert(VARCHAR(20),InDefaultDate,103) End) InDefaultDate
							,(case when convert(DATE,A.OutOfDefaultDate)='' then NULL else Convert(VARCHAR(20),OutOfDefaultDate,103) End) OutOfDefaultDate,
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
							,'LenderDataUpload' TableName
                     FROM RP_Lender_Upload_Mod A
					 
					WHERE ISNULL(A.AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM') and a.CreatedBy<>@UserId
                         
                   
             END;

			 IF(@OperationFlag = 20)

			   BEGIN
			 
                     SELECT 
							A.CustomerEntityID
							,A.UCIC_ID
							,A.CustomerID
							,A.PAN_No
							,A.CustomerName
							,A.LenderName
							,(case when convert(DATE,A.InDefaultDate)='' then NULL else Convert(VARCHAR(20),InDefaultDate,103) End) InDefaultDate
							,(case when convert(DATE,A.OutOfDefaultDate)='' then NULL else Convert(VARCHAR(20),OutOfDefaultDate,103) End) OutOfDefaultDate,
							--isnull(A.AuthorisationStatus, 'A') 
							A.AuthorisationStatus, 
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
							,'LenderDataUpload' TableName
                     FROM RP_Lender_Upload_Mod A
					 
					WHERE ISNULL(A.AuthorisationStatus, 'A') IN('1A') and a.CreatedBy<>@UserId
                         
                   
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

	END
GO