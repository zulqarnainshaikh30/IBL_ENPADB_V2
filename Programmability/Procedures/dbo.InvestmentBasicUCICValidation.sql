SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
/****** Object:  StoredProcedure [dbo].[InvestmentBasicUCICValidation]    Script Date: 9/24/2021 8:20:04 PM ******/
--DROP PROCEDURE [dbo].[InvestmentBasicUCICValidation]
--GO
--/****** Object:  StoredProcedure [dbo].[InvestmentBasicUCICValidation]    Script Date: 9/24/2021 8:20:04 PM ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO

  
  CREATE PROCEDURE [dbo].[InvestmentBasicUCICValidation]

	@UCICID		varchar(200) = ''
	,@Timekey		INT = 0
	,@Result		INT=0 OUTPUT
  AS
  BEGIN
  Set @Timekey=(
			select CAST(B.timekey as int)from SysDataMatrix A
			Inner Join SysDayMatrix B ON A.TimeKey=B.TimeKey
			 where A.CurrentStatus='C'
			 )

  IF EXISTS(				                
					SELECT		1 
					FROM		Curdat.CustomerBasicDetail
					WHERE		UCIF_ID=@UCICID AND ISNULL(AuthorisationStatus,'A')='A' 
					and			EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey
					UNION
					SELECT		1
					FROM		DBO.CustomerBasicDetail_Mod  V
					WHERE		UCIF_ID=@UCICID 
					and			EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey
					AND			ISNULL(AuthorisationStatus,'A') in('NP','MP','DP','RM') 

				)	
				BEGIN
			SELECT '1' CODE, 'Data Exist' Status
		END
		ELSE
		BEGIN
			SELECT '0' CODE, 'Data Not Exist' Status
		END 

		END
GO