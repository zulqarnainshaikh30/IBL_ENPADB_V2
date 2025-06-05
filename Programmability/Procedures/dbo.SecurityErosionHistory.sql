SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROC [dbo].[SecurityErosionHistory]

						@BusinessRule VARCHAR(1000)

AS
	BEGIN

			Select	SecurityAlt_Key,
					BusinessRule,
					'SecurityErosionHistory' AS TableName,
					RefValue,
					CreatedBy, 
					Convert(Varchar(20),DateCreated,103) DateCreated,
					ApprovedBy, 
					Convert(Varchar(20),DateApproved,103) DateApproved,
					ModifiedBy, 
					Convert(Varchar(20),DateModified,103) DateModified
					FROM DimSecurityErosionMaster
					Where BusinessRule=@BusinessRule

	END
GO