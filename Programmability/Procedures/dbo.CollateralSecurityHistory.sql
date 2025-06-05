SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROC [dbo].[CollateralSecurityHistory]

						@Code VARCHAR(50)

AS
	BEGIN

			Select	 A.CollateralSubTypeAltKey
					,A.CollateralTypeAltKey
					,A.CollateralSubTypeID
					,A.CollateralSubType
					,A.CollateralSubTypeDescription
					,A.SrcSecurityCode
					,A.Valid
					,A.CreatedBy, 
					Convert(Varchar(20),A.DateCreated,103) DateCreated,
					A.ApprovedBy, 
					Convert(Varchar(20),A.DateApproved,103) DateApproved,
					A.ModifiedBy, 
					Convert(Varchar(20),A.DateModified,103) DateModified
					FROM DimCollateralSubType A
					Where A.SrcSecurityCode=@Code

	END
GO