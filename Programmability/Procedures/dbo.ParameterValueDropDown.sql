SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROC [dbo].[ParameterValueDropDown]


					@ParameterValue int=0

As

	BEGIN

	Declare @TimeKey as Int 

	Set @TimeKey = (Select Timekey from SysDataMatrix where CurrentStatus='C')

		BEGIN TRY

		If @ParameterValue in(1,2,13)

	BEGIN
				
		Select 
		Parameter_Key
		,ParameterAlt_Key
		,ParameterName
		,'ParameterValue' TableName
		from DimParameter 
		Where EffectiveFromTimeKey<=@TimeKey
		And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Frequency' 
	END

	If @ParameterValue in (3,5,14,22,23,24,25,26,27,28,29,30,31,32)

	BEGIN
		Select 
		Parameter_Key
		,ParameterAlt_Key
		,ParameterName
		,'ParameterValue' TableName
		from DimParameter 
		Where EffectiveFromTimeKey<=@TimeKey
		And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Holidays'
	END
		

   If  @ParameterValue in (4,10,11,12)
     BEGIN
		Select 
		Parameter_Key
		,ParameterAlt_Key
		,ParameterName
		,'ParameterValue' TableName
		from DimParameter 
		Where EffectiveFromTimeKey<=@TimeKey
		And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='System'
	END
	
	
	If @ParameterValue= 6
	  BEGIN
		Select 
		Parameter_Key
		,ParameterAlt_Key
		,ParameterName
		,'ParameterValue' TableName
		from DimParameter 
		Where EffectiveFromTimeKey<=@TimeKey
		And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Status'
	END
	
 If @parametervalue =15
   BEGIN
		Select 
		Parameter_Key
		,ParameterAlt_Key
		,ParameterName
		,'ParameterValue' TableName
		from DimParameter 
		Where EffectiveFromTimeKey<=@Timekey
		And EffectiveToTimeKey>=@Timekey
		And DimParameterName='Model'
	END

	
 If @parametervalue =7
   BEGIN
		Select 
		Parameter_Key
		,ParameterAlt_Key
		,ParameterName
		,'ParameterValue' TableName
		from DimParameter 
		Where EffectiveFromTimeKey<=@TimeKey
		And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='CumulativeDefinePeriod'
	END

	If @parametervalue =8
   BEGIN
		Select 
		Parameter_Key
		,ParameterAlt_Key
		,ParameterName
		,'ParameterValue' TableName
		from DimParameter 
		Where EffectiveFromTimeKey<=@TimeKey
		And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='CumulativeDefineDays'
	END

	If @parametervalue =9
   BEGIN
		Select 
		Parameter_Key
		,ParameterAlt_Key
		,ParameterName
		,'ParameterValue' TableName
		from DimParameter 
		Where EffectiveFromTimeKey<=@TimeKey
		And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='CumulativeDefineInterestServiced'
	END

	If @parametervalue =19
   BEGIN
		Select 
		Parameter_Key
		,ParameterAlt_Key
		,ParameterName
		,'ParameterValue' TableName
		from DimParameter 
		Where EffectiveFromTimeKey<=@Timekey
		And EffectiveToTimeKey>=@Timekey
		And DimParameterName='securityvalue'
	END
		  

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