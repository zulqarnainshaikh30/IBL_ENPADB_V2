SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE Proc [dbo].[GLProductFacilityDropDown]

AS

  BEGIN

Declare @Timekey as Int

Set @Timekey= (select Timekey from SysDataMatrix where currentstatus='C')

	BEGIN

	   Select 
		Parameter_Key
		,ParameterAlt_Key
		,ParameterName
		,'FacilityType' TableName
		
		 from DimParameter 
		Where EffectiveFromTimeKey<=@TimeKey
		And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='DimGLProduct'
	 END
	
	   SELECT *, 'GLProductMaster' AS TableName FROM MetaScreenFieldDetail WHERE ScreenName='Account  GL Code Master' and  MenuId=14569
END
GO