SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROC [dbo].[SMAValueDropDown]
				

As

	BEGIN

	Declare @TimeKey as Int 

	Set @TimeKey = (Select Timekey from SysDataMatrix where CurrentStatus='C')

		BEGIN TRY
		--Select '' as Parameter_Key,'' as ParameterAlt_Key,'-Select-' as ParameterName,'ValueList' TableName
		--union
		Select 
		Parameter_Key
		,ParameterAlt_Key
		,ParameterName
		,'ValueList' TableName
		from DimParameter 
		Where EffectiveFromTimeKey<=@TimeKey
		And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Holidays'

		Select 
		Parameter_Key
		,ParameterAlt_Key
		,ParameterName
		,'ValueList1' TableName
		from DimParameter 
		Where EffectiveFromTimeKey<=@TimeKey
		And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Holidays'

		Select 
		Parameter_Key
		,ParameterAlt_Key
		,ParameterName
		,'ValueList2' TableName
		from DimParameter 
		Where EffectiveFromTimeKey<=@TimeKey
		And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Holidays'

		Select 
		Parameter_Key
		,ParameterAlt_Key
		,ParameterName
		,'ValueList3' TableName
		from DimParameter 
		Where EffectiveFromTimeKey<=@TimeKey
		And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Holidays'

		Select 
		Parameter_Key
		,ParameterAlt_Key
		,ParameterName
		,'ValueList4' TableName
		from DimParameter 
		Where EffectiveFromTimeKey<=@TimeKey
		And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Holidays'

		Select 
		Parameter_Key
		,ParameterAlt_Key
		,ParameterName
		,'ValueList5' TableName
		from DimParameter 
		Where EffectiveFromTimeKey<=@TimeKey
		And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Holidays'

		Select 
		Parameter_Key
		,ParameterAlt_Key
		,ParameterName
		,'ValueList6' TableName
		from DimParameter 
		Where EffectiveFromTimeKey<=@TimeKey
		And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Holidays'

		Select 
		Parameter_Key
		,ParameterAlt_Key
		,ParameterName
		,'ValueList7' TableName
		from DimParameter 
		Where EffectiveFromTimeKey<=@TimeKey
		And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Holidays'

		Select 
		Parameter_Key
		,ParameterAlt_Key
		,ParameterName
		,'ValueList8' TableName
		from DimParameter 
		Where EffectiveFromTimeKey<=@TimeKey
		And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Holidays'

		Select 
		Parameter_Key
		,ParameterAlt_Key
		,ParameterName
		,'ValueList9' TableName
		from DimParameter 
		Where EffectiveFromTimeKey<=@TimeKey
		And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Holidays'

		Select 
		Parameter_Key
		,ParameterAlt_Key
		,ParameterName
		,'ValueList10' TableName
		from DimParameter 
		Where EffectiveFromTimeKey<=@TimeKey
		And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Holidays'

		Select 
		Parameter_Key
		,ParameterAlt_Key
		,ParameterName
		,'ValueList11' TableName
		from DimParameter 
		Where EffectiveFromTimeKey<=@TimeKey
		And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Holidays'

		Select 
		Parameter_Key
		,ParameterAlt_Key
		,ParameterName
		,'ValueList12' TableName
		from DimParameter 
		Where EffectiveFromTimeKey<=@TimeKey
		And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Holidays'

		Select 
		Parameter_Key
		,ParameterAlt_Key
		,ParameterName
		,'ValueList13' TableName
		from DimParameter 
		Where EffectiveFromTimeKey<=@TimeKey
		And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Holidays'
		 

END TRY
	BEGIN CATCH
	
	INSERT INTO dbo.Error_Log
				SELECT ERROR_LINE() as ErrorLine,ERROR_MESSAGE()ErrorMessage,ERROR_NUMBER()ErrorNumber
				,ERROR_PROCEDURE()ErrorProcedure,ERROR_SEVERITY()ErrorSeverity,ERROR_STATE()ErrorState
				,GETDATE()

	SELECT ERROR_MESSAGE()
	--RETURN -1
   
	END CATCH
       
END
GO