SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROC [dbo].[InstrumentHistory]

						@Code varchar(200)

AS
	BEGIN

			Select	A.InstrumentTypeMappingAlt_Key
					,A.InstrumentTypeName 
					,A.InstrumentTypeAlt_Key
					,S.SourceAlt_Key
					,A.SrcsysInstrumentTypecode
					,A.SrcsysInstrumentTypeName 
					,A.CreatedBy 
					,Convert(Varchar(20),A.DateCreated,103) DateCreated
					,A.ApprovedBy
					,Convert(Varchar(20),A.DateApproved,103) DateApproved
					,A.ModifiedBy 
					,Convert(Varchar(20),A.DateModifie,103) DateModified
					FROM DimInstrumentTypeMapping A
					Inner JOIN DIMsourceDB S 
				  ON S.SourceAlt_Key=A.SourceAlt_Key
				   Where A.SrcSysInstrumentTypeCode=@Code

	END
GO