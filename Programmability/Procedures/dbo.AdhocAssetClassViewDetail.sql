SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO





CREATE proc  [dbo].[AdhocAssetClassViewDetail]



    @UCIF_ID varchar(max)=''



AS



   Begin



   Declare @TimeKey as Int

			 SET @Timekey =(Select TimeKey from SysDataMatrix where CurrentStatus='C') 



  --SET @Timekey =(Select LastMonthDateKey from SysDayMatrix where Timekey=@Timekey) 





   Select	 Distinct        UCIF_ID     

                    ,A.AssetClassAlt_Key

					,B.AssetClassName As AssetClass

					,Convert(Varchar(20),NPA_Date,103) as NPADate

					,L.ParameterName  AS MOCReason

					,Convert(Varchar(20),A.DateCreated,103) AS MOCDate

					,A.CreatedBy AS MOCBy

					,Convert(Varchar(20),FirstLevelDateApproved,103) AS Level1ApprovedDate

					,FirstLevelApprovedBy AS Level1ApprovedBy
					,Convert(Varchar(20),A.DateApproved,103) AS Level2ApprovedDate
					,A.ApprovedBy  AS Level2ApprovedBy
					,A.ModifyBy 
					,Convert(Varchar(20),A.DateModified,103) DateModified

					,A.AuthorisationStatus
					,aac.ParameterName as ChangeType --- newly added by kapil on 12/02/2024




	from dbo.AdhocACL_ChangeDetails_Mod A 

	

	LEFT JOIN  DimAssetClass B



		ON A.AssetClassAlt_Key=B.AssetClassAlt_Key

	LEFT Join (

						Select  ParameterAlt_Key,ParameterName,'ModeOfOperationMaster' as Tablename 
						from DimParameter where DimParameterName='DimMoRreason'
						And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)L
						ON L.ParameterAlt_Key=A.Reason

	Left Join  DimParameter  aac on  cast(aac. ParameterAlt_Key as varchar)=A.ChangeType and DimParameterName='MOCType' 
	                    And	 aac.EffectiveFromTimeKey<=@Timekey And aac.EffectiveToTimeKey>=@Timekey	             

				where 



							 A.EffectiveFromTimeKey<=@Timekey --And A.EffectiveToTimeKey>=@Timekey

							 and A.AuthorisationStatus='A'

							 and UCIF_ID=@UCIF_ID





end







GO