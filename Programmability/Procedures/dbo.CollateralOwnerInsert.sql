SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


CREATE PROC [dbo].[CollateralOwnerInsert]

@CollateralID	int	=0
,@CustomeroftheBankAlt_Key	int=0
--,@AccountID	varchar(16)=''
,@CustomerID	varchar(50)=''
,@OtherOwnerName	varchar(50)=''
,@PAN	varchar(10)=''
,@OtherOwnerRelationshipAlt_Key	int=0
,@IfRelationselectAlt_Key	int=0
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
if(@OperationFlag in (1,16,2))
		BEGIN

		insert into CollateralOtherOwner
					(
						CollateralID
						,CustomeroftheBankAlt_Key
						--,AccountID
						,CustomerID
						,OtherOwnerName
						,PAN
						,OtherOwnerRelationshipAlt_Key
						,IfRelationselectAlt_Key
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
						,@CustomeroftheBankAlt_Key
						--,@AccountID
						,@CustomerID
						,@OtherOwnerName
						,@PAN
						,@OtherOwnerRelationshipAlt_Key
						,@IfRelationselectAlt_Key
						,@AuthorisationStatus
						,@EffectiveFromTimeKey	
						,@EffectiveToTimeKey	
						,@CreatedBy				
						,@DateCreated			
						,@ModifiedBy			
						,@DateModified			
						,@ApprovedBy			
						,@DateApproved		
						
               

		END

		BEGIN
				SET @Result=0
			END

			BEGIN
				SET @Result=1
			END
END



GO