SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create PROC [dbo].[ProvisionHistory]

						@ProvisionName varchar(255)

AS
	BEGIN

	Declare @TimeKey as Int
	SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')


			Select	
					'ProvisionHistory' as TableName,
					A.ProvisionAlt_Key as Code,
					A.BankCategoryID,
					A.ProvisionName as AssetCategory,
					B.ParameterName as CategoryType,
					A.CategoryTypeAlt_Key,
					A.ProvisionSecured  as [ProvisionPrcntRBINorms],
					A.AdditionalBanksProvision,
					A.AdditionalprovisionRBINORMS  as [AdditionalProvisionPrcntBankNorms],
					CreatedBy, 
					Convert(Varchar(20),DateCreated,103) DateCreated,
					ApprovedBy, 
					Convert(Varchar(20),DateApproved,103) DateApproved,
					ModifiedBy, 
					Convert(Varchar(20),DateModified,103) DateModified,
					convert(varchar(20),S1.date ,103) as EffectiveFromDate,
					convert(varchar(20),S2.date ,103) as EffectiveToDate 

					FROM DimProvision_SegStd A
					inner join sysdaymatrix S1 ON S1.Timekey=A.EffectiveFromTimekey
					inner join sysdaymatrix S2 ON S2.Timekey=A.EffectiveToTimekey

					Inner Join (Select ParameterAlt_Key,ParameterName,'CategoryType' as Tablename 
					from DimParameter where DimParameterName='Category Type'
					And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)B
					ON A.CategoryTypeAlt_Key=B.ParameterAlt_Key
					Where ProvisionName=@ProvisionName

	END
GO