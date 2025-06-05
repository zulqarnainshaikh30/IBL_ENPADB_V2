SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROC [dbo].[RP_PortFolioAuthorizeSelect]

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
							,A.BankCode
							,Convert(Varchar(20),A.BorrowerDefaultDate,103) BorrowerDefaultDate
							,A.ExposureBucketName
							,A.BankingArrangementName
							,A.LeadBankName
							,A.DefaultStatus
							,Convert(Varchar(20),A.RP_ApprovalDate,103) RP_ApprovalDate
							,A.RPNatureName
							,A.If_Other
							,A.ImplementationStatus
							,Convert(Varchar(20),A.Actual_Impl_Date,103) Actual_Impl_Date
							,Convert(Varchar(20),A.RP_OutOfDateAllBanksDeadline,103) RP_OutOfDateAllBanksDeadline,
							isnull(A.AuthorisationStatus, 'A') AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            Convert(Varchar(20),A.DateCreated,103) DateCreated, 
                            A.ApprovedBy, 
                            Convert(Varchar(20),A.DateApproved,103) DateApproved ,
                            A.ModifiedBy, 
                            Convert(varchar(20),A.DateModified,103) DateModified
							,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
							,'AutomationRPUpload' TableName
                     FROM RP_Portfolio_Upload_Mod A
					 
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
							,A.BankCode
							,Convert(Varchar(20),A.BorrowerDefaultDate,103) BorrowerDefaultDate
							,A.ExposureBucketName
							,A.BankingArrangementName
							,A.LeadBankName
							,A.DefaultStatus
							,Convert(Varchar(20),A.RP_ApprovalDate,103) RP_ApprovalDate
							,A.RPNatureName
							,A.If_Other
							,A.ImplementationStatus
							,Convert(Varchar(20),A.Actual_Impl_Date,103) Actual_Impl_Date
							,Convert(Varchar(20),A.RP_OutOfDateAllBanksDeadline,103) RP_OutOfDateAllBanksDeadline,
							isnull(A.AuthorisationStatus, 'A') AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            Convert(Varchar(20),A.DateCreated,103) DateCreated, 
                            A.ApprovedBy, 
                            Convert(Varchar(20),A.DateApproved,103) DateApproved ,
                            A.ModifiedBy, 
                            Convert(varchar(20),A.DateModified,103) DateModified
							,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
							,'AutomationRPUpload' TableName
                     FROM RP_Portfolio_Upload_Mod A
					 
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
							,A.BankCode
							,Convert(Varchar(20),A.BorrowerDefaultDate,103) BorrowerDefaultDate
							,A.ExposureBucketName
							,A.BankingArrangementName
							,A.LeadBankName
							,A.DefaultStatus
							,Convert(Varchar(20),A.RP_ApprovalDate,103) RP_ApprovalDate
							,A.RPNatureName
							,A.If_Other
							,A.ImplementationStatus
							,Convert(Varchar(20),A.Actual_Impl_Date,103) Actual_Impl_Date
							,Convert(Varchar(20),A.RP_OutOfDateAllBanksDeadline,103) RP_OutOfDateAllBanksDeadline,
							--isnull(A.AuthorisationStatus, 'A') 
							A.AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            Convert(Varchar(20),A.DateCreated,103) DateCreated, 
                            A.ApprovedBy, 
                            Convert(Varchar(20),A.DateApproved,103) DateApproved ,
                            A.ModifiedBy, 
                            Convert(varchar(20),A.DateModified,103) DateModified
							,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
							,'AutomationRPUpload' TableName
                     FROM RP_Portfolio_Upload_Mod A
					 
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