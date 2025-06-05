SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROC [dbo].[ProductHistory]

						@ProductCode varchar(10)

AS
	BEGIN

			Select	ProductAlt_Key,
					ProductCode ,
					ProductName,
					CreatedBy, 
					'ProductHistory' AS TableName,
					Convert(Varchar(20),DateCreated,103) DateCreated,
					ApprovedBy, 
					Convert(Varchar(20),DateApproved,103) DateApproved,
					ModifiedBy, 
					Convert(Varchar(20),DateModifie,103) DateModified
					FROM DimProduct 
					Where ProductCode=@ProductCode

	END
GO