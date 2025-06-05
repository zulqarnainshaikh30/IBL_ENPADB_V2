SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROC [dbo].[SecurityChargeHistory]

						@Code VARCHAR(50)

AS
	BEGIN

			Select	SecurityMappingAlt_Key,
			'SecurityChargeHistory' as TableName,
					SrcSysSecurityChargeTypeCode,
					SrcSysSecurityChargeTypeName,
					SecurityChargeTypeName,
					SecurityChargeTypeAlt_key,
					CreatedBy, 
					Convert(Varchar(20),DateCreated,103) DateCreated,
					ApprovedBy, 
					Convert(Varchar(20),DateApproved,103) DateApproved,
					ModifiedBy, 
					Convert(Varchar(20),DateModifie,103) DateModified
					FROM DimSecurityChargeTypeMapping
					Where SrcSysSecurityChargeTypeCode=@Code

	END
GO