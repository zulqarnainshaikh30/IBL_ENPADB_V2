SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROC [dbo].[SchemeHistory]

						@Code varchar(10)

AS
	BEGIN

			Select	 SchemeMappingAlt_Key,
					'SchemeHistory' as TableName
					,SchemeName 
					,SchemeAlt_Key
					,SrcsysSchemecode
					,SrcsysSchemeName
					,CreatedBy 
					,Convert(Varchar(20),DateCreated,103) DateCreated
					,ApprovedBy 
					,Convert(Varchar(20),DateApproved,103) DateApproved
					,ModifiedBy 
					,Convert(Varchar(20),DateModifie,103) DateModified
					FROM DimSchemeMapping 
				   Where SrcSysSchemeCode=@Code

	END
GO