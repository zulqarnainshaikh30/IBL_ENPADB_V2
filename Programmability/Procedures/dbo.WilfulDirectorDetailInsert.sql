SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROC [dbo].[WilfulDirectorDetailInsert]

@DirectorName				Varchar(100)		=null,
@PAN						varchar(10)			=null,
@DIN						Numeric(8,2)		=null,
@DirectorTypeAlt_Key		int					=0

,@AuthorisationStatus		varchar(5)			=NULL
,@EffectiveFromTimeKey		INT					= 0
,@EffectiveToTimeKey		INT					= 0
,@CreatedBy					VARCHAR(20)			= NULL
,@DateCreated				SMALLDATETIME		= NULL
,@ModifiedBy				VARCHAR(20)			= NULL
,@DateModified				SMALLDATETIME		= NULL
,@ApprovedBy				VARCHAR(20)			= NULL
,@DateApproved				SMALLDATETIME		= NULL

,@Remark					VARCHAR(500)		= ''
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

				--SET @ScreenName = 'Collateral'

	-------------------------------------------------------------

 SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C') 

 SET @EffectiveFromTimeKey  = @TimeKey

	SET @EffectiveToTimeKey = 49999




--AS
if(@OperationFlag in (1,16))
		BEGIN

		insert into WilfulDirectorDetailOtherOwner
					(
						
						DirectorName,
						PAN,
						DIN,
						DirectorTypeAlt_Key,
						AuthorisationStatus,
						EffectiveFromTimeKey,
						EffectiveToTimeKey,
						CreatedBy,
						DateCreated,
						ModifiedBy,
						DateModified,
						ApprovedBy,
						DateApproved 						

						)
				select	@DirectorName,		
						@PAN	,			
						@DIN,				
						@DirectorTypeAlt_Key,
						@AuthorisationStatus
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