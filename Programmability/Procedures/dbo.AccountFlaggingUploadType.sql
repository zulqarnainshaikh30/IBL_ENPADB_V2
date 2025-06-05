SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROC [dbo].[AccountFlaggingUploadType]



  

AS

  BEGIN



  Declare @TimeKey as Int 



	Set @TimeKey = (Select Timekey from SysDataMatrix where CurrentStatus='C')

		

	





		Select ParameterAlt_Key

		,ParameterName

		,'UploadType' as Tablename 

		from DimParameter where DimParameterName='UploadFLagType'

		and ParameterAlt_Key in (1,9,12,20)

		--and ParameterAlt_Key in (1) ----,9,12,20)

		And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey

	END
GO