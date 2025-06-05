SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROC [dbo].[SubSectorHistory]

						@Code VARCHAR(50)

AS
	BEGIN

			Select	A.SubSectorMappingAlt_Key,
					B.SourceName,
					A.SrcSysSubSectorCode,
					A.SrcSysSubSectorName,
					A.SubSectorName,
					A.SubSectorAlt_key,
					A.CreatedBy,
					'SubSectorHistory' as TableName, 
					Convert(Varchar(20),A.DateCreated,103) DateCreated,
					A.ApprovedBy, 
					Convert(Varchar(20),A.DateApproved,103) DateApproved,
					A.ModifiedBy, 
					Convert(Varchar(20),A.DateModified,103) DateModified
					FROM DimSubSectorMappingMaster A
					Inner join DIMSOURCEDB B
					ON A.SourceAlt_Key=B.SourceAlt_Key
					Where A.SrcSysSubSectorCode=@Code

	END
GO