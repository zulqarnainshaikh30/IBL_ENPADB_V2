SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROC [dbo].[ValuationSourceDropDown]
@CollateralID Varchar(30)='',
@CollateralTypeAlt_Key INT=0
AS
	BEGIN

Declare @Timekey Int
Set @Timekey =(Select TimeKey from SysDataMatrix where CurrentStatus='C')

IF @CollateralID=''
BEGIN
	Select @CollateralTypeAlt_Key=CollateralSubTypeAlt_Key from Curdat.AdvSecurityDetail
	Where CollateralID=@CollateralID

	If @CollateralTypeAlt_Key=0 

	BEGIN
		Select @CollateralTypeAlt_Key=CollateralSubTypeAlt_Key from dbo.AdvSecurityDetail_MOD
	Where CollateralID=@CollateralID
	END
END

BEGIN

		Select ValueExpirationAltKey as SecuritySubTypeAlt_Key
		,Documents as ParameterName
		,ExpirationPeriod as PeriodInMonth
		,'ValuationSource' TableName
		from DimValueExpiration
		where EffectiveFromTimeKey<=@Timekey
		AND EffectiveToTimeKey>=@Timekey AND SecurityTypeAlt_Key=@CollateralTypeAlt_Key


		Select A.[SecurityTypeAlt_Key] AS CollateralType_AltKey ,B.CollateralTypeDescription as CollateralType,
A.SecuritySubTypeAlt_Key as SecuritySubTypeAlt_Key, C.CollateralSubTypeDescription AS ParameterName,A.[ExpirationPeriod] As PeriodInMonth,
	'ValuationSourceData' TableName
From [DimValueExpiration] A INNER JOIN DimCollateralType B ON A.[SecurityTypeAlt_Key]= B.CollateralTypeAltKey
INNER JOIN DimCollateralSubType C ON A.SecurityTypeAlt_Key=C.CollateralTypeAltKey

END				

	END
GO