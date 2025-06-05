SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROC [dbo].[IndustryHistory]

						@Code varchar(50)

AS
	BEGIN

			Select	A.IndustryMappingAlt_Key, --as Code,
					 A.IndustryName ,--as IndustryName,
					 S.SourceAlt_Key
					,A.SrcsysIndustrycode
					,A.SrcsysIndustryName
					,A.IndustryAlt_Key
					,S.SourceName
					,A.CreatedBy
					,'IndustryHistory' AS TableName
					,Convert(Varchar(20),A.DateCreated,103) DateCreated
					,A.ApprovedBy
					,Convert(Varchar(20),A.DateApproved,103) DateApproved
					,A.ModifiedBy
					,Convert(Varchar(20),A.DateModifie,103) DateModified
					FROM DimIndustryMapping A
				   Inner JOIN DIMsourceDB S 
				   ON S.sourceAlt_Key=A.SourceAlt_Key
				   Where A.SrcSysIndustryCode=@Code

	END
GO