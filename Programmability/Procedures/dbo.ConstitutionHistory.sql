SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROC [dbo].[ConstitutionHistory]

						@SrcSysConstitutionCode VARCHAR(10)

AS
	BEGIN

			Select	A.ConstitutionMappingAlt_key,
					B.SourceName,
					A.SrcSysConstitutionCode as BankCode,
					A.SrcSysConstitutionName as BankDescription,
					A.ConstitutionAlt_Key as Code,
					A.ConstitutionName as ConDescription,
					A.CreatedBy, 
					Convert(Varchar(20),A.DateCreated,103) DateCreated,
					A.ApprovedBy, 
					Convert(Varchar(20),A.DateApproved,103) DateApproved,
					A.ModifiedBy, 
					Convert(Varchar(20),A.DateModifie,103) DateModified
					FROM DimConstitutionMapping A
					Inner Join DIMSOURCEDB B
					ON A.SourceAlt_Key=B.SourceAlt_Key
					Where SrcSysConstitutionCode=@SrcSysConstitutionCode

	END
GO