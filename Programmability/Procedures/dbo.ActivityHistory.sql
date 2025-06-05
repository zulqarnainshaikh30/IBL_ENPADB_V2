SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROC [dbo].[ActivityHistory]

						@Code varchar(50)

AS
	BEGIN

			Select	A.ActivityMappingAlt_Key, 
					A.ActivityName ,
					A.ActivityAlt_Key,
					S.SourceAlt_Key,
					A.SrcsysActivitycode,
					A.SrcsysActivityName,
					A.CreatedBy, 
					'ActivityHistory' AS TableName,
					Convert(Varchar(20),A.DateCreated,103) DateCreated,
					A.ApprovedBy, 
					Convert(Varchar(20),A.DateApproved,103) DateApproved,
					A.ModifiedBy, 
					Convert(Varchar(20),A.DateModifie,103) DateModified
					FROM DimActivityMapping A
				   Inner JOIN DIMsourceDB S 
				   ON S.sourceAlt_Key=A.SourceAlt_Key
				   Where A.SrcSysActivityCode=@Code

	END
GO