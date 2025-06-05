SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROC [dbo].[ConstitutionDescriptionDropDown]

AS

	BEGIN

Declare @Timekey as Int

Set @Timekey= (select Timekey from SysDataMatrix where currentstatus='C')


BEGIN

		Select 
		ConstitutionAlt_Key as Code
		,ConstitutionName as ConstitutionDescription
		,'CrisMacDesc' TableName
		from Dimconstitution
		where EffectiveFromTimeKey<=@Timekey
		and EffectiveToTimeKey>=@Timekey

END

	END

	
GO