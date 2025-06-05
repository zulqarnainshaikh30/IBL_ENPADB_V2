﻿SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--CollateralMasterDownload
CREATE PROC [dbo].[CollateralMasterDownload]
As

BEGIN

Declare @TimeKey as Int
	SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')

	select CollateralSubTypeDescription,'CollateralSubType' as TableName
	from DimCollateralSubType
	where EffectiveFromTimeKey<=@TimeKey
	AND EffectiveToTimeKey >=@TimeKey
	order by CollateralSubTypeAltKey

		select CollateralTypeDescription,'CollateralType' as TableName
	from DimCollateralType
	where EffectiveFromTimeKey<=@TimeKey
	AND EffectiveToTimeKey >=@TimeKey
	order by CollateralTypeAltKey

Select 
		CollChargeDescription,'ChargeType' as TableName from DimCollateralChargeType
		where EffectiveFromTimeKey<=@TimeKey
	     AND EffectiveToTimeKey >=@TimeKey

		  Select 
		   SecurityChargeTypeName,'ChargeNature' as TableName from DimSecurityChargeType
			where SecurityChargeTypeGroup='COLLATERAL' AND  EffectiveFromTimeKey<=@TimeKey
			AND EffectiveToTimeKey >=@TimeKey

		--	Select SeniorityChargeAltKey as ParameterAlt_Key
		--,SeniorityChargeDescription as ParameterName
		--,'SeniorityOfChargeMaster' as Tablename 
		--from DimSeniorityChargeMaster where
		-- EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
	
		--Select CurrencyAlt_Key,CurrencyName,'CurrencyTable'  as TableName 
		-- from DimCurrency
		--where EffectiveFromTimeKey<=@TimeKey
	 --    AND EffectiveToTimeKey >=@TimeKey
		-- and CurrencyCode in('INR','USD','GBP','Euro','Yen','Swiss Franc')

		-- Select  BankAlt_Key
		--,BankName
		--,'BankMaster' as TableName 
		--from DimBank A 
		--where	 A.EffectiveFromTimeKey<=@TimeKey
		--AND A.EffectiveToTimeKey >=@TimeKey

		-- Select SegmentAlt_Key
		--,SegmentName
		--,'SegmentMaster' as TableName 
		--from DimSegment 
		--where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey


			--Select  B.CollateralSubTypeDescription,
			--A.Documents ,A.ExpirationPeriod,'ExpiryBusinessRulee' as TableName from DimValueExpiration A
			--INNER JOIN DimCollateralSubType B ON A.SecuritySubTypeAlt_Key=B.CollateralSubTypeAltKey
			--where A.EffectiveFromTimeKey<=@TimeKey
			--AND A.EffectiveToTimeKey >=@TimeKey


		
			
		
			
			


	END

GO