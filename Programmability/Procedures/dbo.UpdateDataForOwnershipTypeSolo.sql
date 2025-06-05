SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



CREATE Proc [dbo].[UpdateDataForOwnershipTypeSolo]
   @CollateralID INT
   ,@OperationFlag				TINYINT
   AS

   Declare @Timekey INT,@EffectiveFromTimeKey INT,@EffectiveToTimeKey INT,@CollateralOwnerShipTypeAlt_Key Int


   SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C') 

 SET @EffectiveFromTimeKey  = @TimeKey

	SET @EffectiveToTimeKey = 49999


IF(@OperationFlag in (16))
BEGIN
	Select @CollateralOwnerShipTypeAlt_Key=CollateralOwnerShipTypeAlt_Key from CollateralMgmt
				Where CollateralID=@CollateralID  and EffectiveFromTimeKey=@EffectiveFromTimeKey and EffectiveToTimeKey=@EffectiveToTimeKey

			    IF (@CollateralOwnerShipTypeAlt_Key=1)
				    BEGIN 
						Update CollateralOtherOwner
						SET EffectiveToTimeKey=EffectiveFromTimeKey-1
						Where   CollateralID=@CollateralID  and EffectiveFromTimeKey=@EffectiveFromTimeKey and EffectiveToTimeKey=@EffectiveToTimeKey
					END
END					

					



GO