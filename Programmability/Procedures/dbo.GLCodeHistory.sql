SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROC [dbo].[GLCodeHistory]

						@GLCode VARCHAR(20)

AS
	BEGIN

			Select GLAlt_Key,
					GLCode,
				    GLName as GLDescription,
					CreatedBy, 
					Convert(Varchar(20),DateCreated,103) DateCreated,
					ApprovedBy, 
					Convert(Varchar(20),DateApproved,103) DateApproved,
					ModifiedBy, 
					Convert(Varchar(20),DateModified,103) DateModified,
					'GLViewHistory' As TableName
					FROM DimGL
					Where GLCode=@GLCode

	END
GO