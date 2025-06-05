SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROC [dbo].[UserDetailMasterDownload]

---Exec [dbo].[CollateralDropDown]
  
AS
  BEGIN

  Declare @TimeKey as Int 

	Set @TimeKey = (Select Timekey from SysDataMatrix where CurrentStatus='C')
		
	


		--Select ParameterAlt_Key
		--,ParameterName
		--,'TaggingLevel' as Tablename 
		--from DimParameter where DimParameterName='DimRatingType'
		--and ParameterName not in ('Guarantor')
		--And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		--order by ParameterName Desc

		select ParameterAlt_Key ,
			 ParameterName 
			 ,'DimUserDesignation' as TableName
			 from DimParameter
			 where DimParameterName	= 'DimUserDesignation' and
			 EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey 
			 Order By ParameterAlt_Key
			  
		
	   

		--Select ParameterAlt_Key
		--,ParameterName
		--,'DimImplementationStatus' as Tablename 
		
		--from DimParameter where DimParameterName='ImplementationStatus'
		--and EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		--Order By ParameterAlt_Key

		  Select UserRoleAlt_Key
		,RoleDescription
		,'DimUserRole' as Tablename 
		
		from DimUserRole where 
		 EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		Order By UserRoleAlt_Key

		--  Select ParameterAlt_Key
		--,ParameterName
		--,'DimRBLExposure' as Tablename 
		
		--from DimParameter where DimParameterName='DimYesNo'
		--and EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		--Order By ParameterAlt_Key

		Select DeptGroupId
		,DeptGroupCode
		,'DimUserDeptGroup' as Tablename 
		
		from DimUserDeptGroup where 
		 EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		Order By DeptGroupId

	

	

END


GO