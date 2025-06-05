SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


CREATE PROC [dbo].[InterfaceAuthoLevelInsert]

@EntityId	int
,@NewAuthenticationLevelAlt_Key	int
,@NewAuthenticationLevel	varchar(5)
,@1stLevelApprovedBy	varchar(50)
,@2ndLevelApprovedBy	varchar(50)
,@AuthorisationStatus		varchar(5)=NULL
,@EffectiveFromTimeKey		INT		= 0
,@EffectiveToTimeKey		INT		= 0
,@CreatedBy					VARCHAR(20)		= NULL
,@DateCreated				SMALLDATETIME	= NULL
,@ModifiedBy				VARCHAR(20)		= NULL
,@DateModified				SMALLDATETIME	= NULL
,@ApprovedBy				VARCHAR(20)		= NULL
,@DateApproved				SMALLDATETIME	= NULL

	,@OperationFlag				TINYINT			= 0
	

				
						,@Result					INT				=0 OUTPUT
						
						
AS
BEGIN
--	SET NOCOUNT ON;
--		PRINT 1
	
--		SET DATEFORMAT DMY
	
		DECLARE 
						--@AuthorisationStatus		varchar(5)			= NULL 
						--,@CreatedBy					VARCHAR(20)		= NULL
						--,@DateCreated				SMALLDATETIME	= NULL
						--,@ModifiedBy				VARCHAR(20)		= NULL
						--,@DateModified				SMALLDATETIME	= NULL
						--,@ApprovedBy				VARCHAR(20)		= NULL
						--,@DateApproved				SMALLDATETIME	= NULL
						@ErrorHandle				int				= 0
						,@ExEntityKey				int				= 0  
						
------------Added for Rejection Screen  29/06/2020   ----------

		--DECLARE			
						,@Uniq_EntryID			int	= 0
						,@RejectedBY			Varchar(50)	= NULL
						,@RemarkBy				Varchar(50)	= NULL
						,@RejectRemark			Varchar(200) = NULL
						,@ScreenName			Varchar(200) = NULL
						,@Entity_Key            Int
						,@ValuationDateChar     Varchar(12)
					    ,@TimeKey	            Int
				--SET @ScreenName = 'Collateral'

	-------------------------------------------------------------

 SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C') 

 SET @EffectiveFromTimeKey  = @TimeKey

	SET @EffectiveToTimeKey = 49999






--AS
if (@OperationFlag =1)
		BEGIN
										INSERT INTO InterfaceAuthoLevel
												(
													 EntityId
													 ,NewAuthenticationLevelAlt_Key
													 ,NewAuthenticationLevel
													 ,[1stLevelApprovedBy]
													 ,[2ndLevelApprovedBy]			
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

										SELECT
													  @EntityId
													,@NewAuthenticationLevelAlt_Key
													,@NewAuthenticationLevel	
													,@1stLevelApprovedBy	
													,@2ndLevelApprovedBy		
													, @AuthorisationStatus
													,@EffectiveFromTimeKey
													,@EffectiveToTimeKey
													,@CreatedBy 
													,@DateCreated
													, @ModifiedBy  
													, @DateModified  
													,@ApprovedBy 
													, @DateApproved 

					

													
										
									END
		    BEGIN
				SET @Result=0
			END

			BEGIN
				SET @Result=1
			END
if (@OperationFlag =2)
		BEGIN

		   Select @Entity_Key=MAX(Entity_Key) from InterfaceAuthoLevel
		   Where NewAuthenticationLevelAlt_Key=@NewAuthenticationLevelAlt_Key 

		   Update InterfaceAuthoLevel
		   SET EffectiveFromTimeKey=@Timekey-1,
			EffectiveToTimeKey=@Timekey-1
            Where Entity_Key=@Entity_Key

			BEGIN
										INSERT INTO InterfaceAuthoLevel
												(
													 EntityId
													 ,NewAuthenticationLevelAlt_Key
													 ,NewAuthenticationLevel
													 ,[1stLevelApprovedBy]
													 ,[2ndLevelApprovedBy]			
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

									

										SELECT
													  @EntityId
													,@NewAuthenticationLevelAlt_Key
													,@NewAuthenticationLevel	
													,@1stLevelApprovedBy	
													,@2ndLevelApprovedBy		
													, @AuthorisationStatus
													,@EffectiveFromTimeKey
													,@EffectiveToTimeKey
													,@CreatedBy 
													,@DateCreated
													, @ModifiedBy  
													, @DateModified  
													,@ApprovedBy 
													, @DateApproved

					

													
										
									END			

		    BEGIN
				SET @Result=0
			END

			BEGIN
				SET @Result=1
			END
		END
END









GO