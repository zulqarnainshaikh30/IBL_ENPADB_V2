SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

Create PROC [dbo].[RPLenderMasterDownload]

---Exec [dbo].[CollateralDropDown]
  
AS
  BEGIN

  Declare @TimeKey as Int 

	Set @TimeKey = (Select Timekey from SysDataMatrix where CurrentStatus='C')

		Select BankName
		,'BankMaster' as Tablename 
		from DimBankRP
		Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		Order By BankRPAlt_Key


END
GO