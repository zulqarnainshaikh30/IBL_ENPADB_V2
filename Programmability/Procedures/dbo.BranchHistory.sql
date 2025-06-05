SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROC [dbo].[BranchHistory]

						@Code Int

AS
	BEGIN

			Select	A.BranchAlt_Key,
					'BranchHistory' as TableName,
					A.BranchCode,
					A.BranchName,
					A.Add_1 as Address1,
					A.Add_2 as Address2,
					A.Add_3 as Address3,
					B.DistrictAlt_Key,
					B.DistrictName,
					C.StateAlt_Key,
					C.StateName,
					A.PinCode,
					D.CountryAlt_Key,
					D.CountryName
					,A.CreatedBy 
					,Convert(Varchar(20),A.DateCreated,103) DateCreated
					,A.ApprovedBy 
					,Convert(Varchar(20),A.DateApproved,103) DateApproved
					,A.ModifiedBy 
					,Convert(Varchar(20),A.DateModified,103) DateModified
					FROM DimBranch A
					Inner join DimGeography B
					 ON A.BranchDistrictAlt_Key=B.DistrictAlt_Key
					Inner join DimState C
					On A.BranchStateAlt_Key=C.StateAlt_Key
					Inner Join DimCountry D
					On A.CountryAlt_Key=D.CountryAlt_Key
					Where A.BranchCode=@Code

	END
GO