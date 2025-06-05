SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
/****** Object:  StoredProcedure [dbo].[SearchLatestCollateralID]    Script Date: 9/24/2021 8:20:04 PM ******/
--DROP PROCEDURE [dbo].[SearchLatestCollateralID]
--GO
--/****** Object:  StoredProcedure [dbo].[SearchLatestCollateralID]    Script Date: 9/24/2021 8:20:04 PM ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO
CREATE PROC [dbo].[SearchLatestCollateralID]
AS

Declare @CollateralID varchar(30)
 
    select @CollateralID=Convert(Int,CollateralID)+1 from

	(

	Select Distinct CollateralID from DBO.AdvSecurityDetail_Mod

	where  SecurityEntityID In (Select  Max(SecurityEntityID) from dbo.AdvSecurityDetail_Mod)

	)X

	select @CollateralID
GO