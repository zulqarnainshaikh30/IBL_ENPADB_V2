SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
/****** Object:  StoredProcedure [dbo].[SourceSystemHistory]    Script Date: 25-02-2021 16:58:23 ******/

CREATE PROC [dbo].[SourceSystemHistory]

						@SourceAlt_Key Int

AS
	BEGIN

			Select SourceAlt_Key,
					SourceName as SourceSysName,
					CreatedBy, 
					Convert(Varchar(20),DateCreated,103) DateCreated,
					ApprovedBy, 
					Convert(Varchar(20),DateApproved,103) DateApproved,
					ModifiedBy, 
					Convert(Varchar(20),DateModified,103) DateModified
					FROM DIMSOURCEDB
					Where SourceAlt_Key=@SourceAlt_Key

	END
GO