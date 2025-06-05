SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROC [dbo].[GoldHistory]

						@KaretMasterAlt_Key Int

AS
	BEGIN

declare @ProcessDate Datetime
declare @ProcessDateold Datetime


Set @ProcessDate =(select DataEffectiveFromDate from SysDataMatrix where CurrentStatus='C')
--select @ProcessDate

SET @ProcessDateold=@ProcessDate-15
--select @ProcessDateold

		BEGIN

					Select	A.KaretMasterAlt_Key
					,A.KaretMasterValueName 
					,Convert(VARCHAR(20),A.KaretMasterValueDt,103) KaretMasterValueDt
					,A.KaretMasterValueAmt
					,A.SrcSysKaretValueCode
					,A.SrcSysKaretValueName
					,A.CreatedBy 
					,Convert(Varchar(20),A.DateCreated,103) DateCreated
					,A.ApprovedBy
					,Convert(Varchar(20),A.DateApproved,103) DateApproved
					,A.ModifiedBy 
					,Convert(Varchar(20),A.DateModifie,103) DateModified,
					convert(varchar(20),S1.date ,103) as EffectiveFromDate,
					convert(varchar(20),S2.date ,103) as EffectiveToDate 
					FROM DimKaretMaster_Mod A
					inner join sysdaymatrix S1 ON S1.Timekey=A.EffectiveFromTimekey
					inner join sysdaymatrix S2 ON S2.Timekey=A.EffectiveToTimekey

					Where A.KaretMasterAlt_Key=@KaretMasterAlt_Key
					AND ISNULL(A.AuthorisationStatus,'A')='A'
					And Convert(date,A.KaretMasterValueDt)>=  Convert(Date,@ProcessDateold) and Convert(date,A.KaretMasterValueDt)<=  Convert(Date,@ProcessDate)

		END

	END



GO