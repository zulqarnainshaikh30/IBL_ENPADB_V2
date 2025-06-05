SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--USE [USFB_ENPADB]
--GO
--/****** Object:  StoredProcedure [dbo].[CustomerlevelAccountSearch]    Script Date: 18-11-2021 13:33:01 ******/
--DROP PROCEDURE [dbo].[CustomerlevelAccountSearch]
--GO
--/****** Object:  StoredProcedure [dbo].[CustomerlevelAccountSearch]    Script Date: 18-11-2021 13:33:01 ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO

CREATE PROC [dbo].[CustomerlevelAccountSearch]
	--declare		
				@CustomerID varchar(30)='62'

AS
	BEGIN
declare @Timekey int

SET @Timekey =(Select Timekey from SysDataMatrix Where MOC_Initialised='Y' AND ISNULL(MOC_Frozen,'N')='N') 

select A.CustomerACID as AccountId
	  ,A.FacilityType
	  ,null as Segment
	  ,C.Balance as BalancaOutstanding
	  --,D.POS as POS
	  --,A.unserviedint
	  ,C.InterestReceivable   unserviedint
	  --,A.TotalProvision as NPAProvision
	  ,C.TotalProv NPAProvision
 from  
 curdat.AdvAcBasicDetail A
LEFT JOIN curdat.AdvAcBalanceDetail C
ON   A.RefCustomerId=C.RefCustomerId
AND C.EffectiveFromTimeKey<=@Timekey
AND C.EffectiveToTimeKey>=@Timekey
Where A.EffectiveFromTimeKey<=@Timekey
AND A.EffectiveToTimeKey>=@Timekey
AND A.RefCustomerID=@CustomerID

END


GO