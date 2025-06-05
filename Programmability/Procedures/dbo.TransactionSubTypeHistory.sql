SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROC [dbo].[TransactionSubTypeHistory]

						@Code VARCHAR(5)

AS
	BEGIN

			Select	A.Transaction_Sub_TypeAlt_Key,
					B.SourceName as Source_System_Name,
					B.SourceAlt_Key,
					A.Transaction_Sub_Type_Code,
					A.Transaction_Sub_Type_Description,
					A.CreatedBy, 
					'TransactionSubTypeHistory' AS TableName,
					Convert(Varchar(20),A.DateCreated,103) DateCreated,
					A.ApprovedBy, 
					Convert(Varchar(20),A.DateApproved,103) DateApproved,
					A.ModifiedBy, 
					Convert(Varchar(20),A.DateModified,103) DateModified
					FROM DimTransactionSubTypeMaster A
					Inner join DIMSOURCEDB B
					ON A.SourceAlt_Key=B.SourceAlt_Key
					Where A.Transaction_Sub_Type_Code=@Code

	END
GO