SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--declare @p26 int
--set @p26=NULL
--exec [dbo].[CollateralMgmtInUp] @AccountID=N'',@UCICID=N'',@CustomerID=N'9987888',@CustomerName=N'Akash Kumar',@TaggingAlt_Key=1,@DistributionAlt_Key=2,@CollateralID=N'2',
--@CollateralTypeAlt_Key=2,@CollateralSubTypeAlt_Key=37,@CollateralOwnerTypeAlt_Key=1,@CollateralOwnerShipTypeAlt_Key=1,@ChargeTypeAlt_Key=3,@ChargeNatureAlt_Key=22,@ShareAvailabletoBankAlt_Key=2,
--@CollateralShareamount=100,@TotalCollateralvalueatcustomerlevel=2000,@MenuID=14610,@CrModApBy=N'fnachecker',@Remark=N'',@OperationFlag=16,@AuthMode=N'Y',@TimeKey=25999,@EffectiveFromTimeKey=N'25999',
--@EffectiveToTimeKey=49999,@ScreenEntityId=NULL,@Result=@p26 output
--select @p26
--go

--------------------------------------------------------------------------------------------------------------------




---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


CREATE PROC [dbo].[CollateralOwnerAddressInsert]

@CollateralID	int	=0
,@AddressType	varchar(200)=''
,@Category	varchar(200)=''
,@AddressLine1	varchar(200)=''
,@AddressLine2	varchar(200)=''
,@AddressLine3	varchar(200)=''
,@City	varchar(200)=''
,@PinCode	varchar(6)=''
,@Country	varchar(100)=''
,@State	varchar(100)=''
,@District	varchar	(100)=''
,@STDCodeO	varchar	(100)=''
,@PhoneNumberO	varchar(10)=''
,@STDCodeR	varchar(100)=''
,@PhoneNumberR	varchar(10)=''
,@FaxNumber	varchar(30)=''
,@MobileNO	varchar(15)=''
,@AuthorisationStatus		varchar(5)			=NULL
,@EffectiveFromTimeKey		INT		= 0
,@EffectiveToTimeKey		INT		= 0
,@CreatedBy					VARCHAR(20)		= NULL
,@DateCreated				SMALLDATETIME	= NULL
,@ModifiedBy				VARCHAR(20)		= NULL
,@DateModified				SMALLDATETIME	= NULL
,@ApprovedBy				VARCHAR(20)		= NULL
,@DateApproved				SMALLDATETIME	= NULL

,@Remark					VARCHAR(500)	= ''
						--,@MenuID					SMALLINT		= 0  change to Int
						,@MenuID                    Int=0
						,@OperationFlag				TINYINT			= 0
						,@AuthMode					CHAR(1)			= 'N'
						--,@EffectiveFromTimeKey		INT		= 0
						--,@EffectiveToTimeKey		INT		= 0
						,@TimeKey					INT		= 0
						,@CrModApBy					VARCHAR(20)		=''
						,@ScreenEntityId			INT				=null
						,@Result					INT				=0 OUTPUT
						
						
AS
BEGIN
	
		DECLARE 
						@ErrorHandle				int				= 0
						,@ExEntityKey				int				= 0  
						
------------Added for Rejection Screen  29/06/2020   ----------

		--DECLARE			
						,@Uniq_EntryID			int	= 0
						,@RejectedBY			Varchar(50)	= NULL
						,@RemarkBy				Varchar(50)	= NULL
						,@RejectRemark			Varchar(200) = NULL
						,@ScreenName			Varchar(200) = NULL
						,@CollateralOwnerShipTypeAlt_Key Int
				--SET @ScreenName = 'Collateral'

	-------------------------------------------------------------

 SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C') 

 SET @EffectiveFromTimeKey  = @TimeKey

	SET @EffectiveToTimeKey = 49999




--AS
if(@OperationFlag in (1,2))
		BEGIN

		insert into CollateralOtherOwner
					(
						CollateralID
						,AddressType
						,Company
						,AddressLine1
						,AddressLine2
						,AddressLine3
						,City
						,PinCode
						,Country
						,State
						,District
						,STDCodeO
						,PhoneNumberO
						,STDCodeR
						,PhoneNumberR
						,FaxNumber
						,MobileNO
						,AuthorisationStatus
						,EffectiveFromTimeKey
						,EffectiveToTimeKey
						,CreatedBy
						,DateCreated
						,ModifiedBy
						,DateModified
						,ApprovedBy
						,DateApproved
						)
				select 
				
						@CollateralID								
						,@AddressType
						,@Category
						,@AddressLine1
						,@AddressLine2
						,@AddressLine3
						,@City
						,@PinCode
						,@Country
						,@State
						,@District
						,@STDCodeO
						,@PhoneNumberO
						,@STDCodeR
						,@PhoneNumberR
						,@FaxNumber
						,@MobileNO
						,@AuthorisationStatus
						,@EffectiveFromTimeKey	
						,@EffectiveToTimeKey	
						,@CreatedBy				
						,@DateCreated			
						,@ModifiedBy			
						,@DateModified			
						,@ApprovedBy			
						,@DateApproved	
						

						--Logic For Solo
				

		END

		BEGIN
				SET @Result=0
			END

			BEGIN
				SET @Result=1
			END
END
GO