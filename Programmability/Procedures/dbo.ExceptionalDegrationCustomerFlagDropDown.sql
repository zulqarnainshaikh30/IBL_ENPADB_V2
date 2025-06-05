SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROC [dbo].[ExceptionalDegrationCustomerFlagDropDown]

AS
	BEGIN

Declare @Timekey Int,@CustomerACID  varchar (50)
Set @Timekey =(Select TimeKey from SysDataMatrix where CurrentStatus='C')

BEGIN

		Select		[ParameterAlt_Key]
					,ParameterName
					,'DegrationFlag' as TableName,*
		from		DimParameter A
		where		[DimParameterName] = 'UploadFLagType'
		AND			ParameterAlt_Key iN ('1','9','12','20')
		--AND			ParameterAlt_Key iN ('1')--,'Restructure','Benami Loans','Sub Lending','Absconding','IBPC','Securitization','PUI','SaletoARC','SMA-0','RP (Resolution Plan)')
		and			A.EffectiveFromTimeKey<=@Timekey
		and			A.EffectiveToTimeKey>=@Timekey

		Exec [SourceSystemDropDown]
END				

	END
GO