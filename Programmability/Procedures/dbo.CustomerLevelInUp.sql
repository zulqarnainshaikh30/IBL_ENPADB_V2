SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



CREATE PROC [dbo].[CustomerLevelInUp]

--Declare
						@CustomerID					varchar(30)=''
					   ,@CustomerName				varchar(100)=''
					   ,@AssetClassAlt_Key			int=0
					   ,@NPADate					Varchar(20)=NULL
					   ,@SecurityValue				varchar(50)=''
					   ,@AdditionalProvision		Decimal(18,2)=''
					   --,@FraudAccountFlagAlt_Key	Int=0
					   --,@FraudDate					Date
					   ,@MocTypeAlt_Key				Int=0
					   ,@MOCReason					Varchar(100)=''
					   ,@MOCSourceAltkey			Int=0
					   ,@ScreenFlag					varchar(1)='S'
						
						---------D2k System Common Columns		--
						,@Remark					VARCHAR(500)	= ''
						--,@MenuID					SMALLINT		= 0  change to Int
						,@MenuID                    Int=0
						,@OperationFlag				TINYINT			= 0
						,@AuthMode					CHAR(1)			= 'N'
						,@EffectiveFromTimeKey		INT		= 0
						,@EffectiveToTimeKey		INT		= 0
						,@TimeKey					INT		= 0
						,@CrModApBy					VARCHAR(20)		=''
						,@ScreenEntityId			INT				=null
						,@Result					INT				=0 OUTPUT
						,@CustomerNPAMOC_ChangeFields varchar(50)	=''
						
						
AS
BEGIN
		SET NOCOUNT ON;
		PRINT 1

		SET DATEFORMAT DMY

				DECLARE @Parameter1 varchar(max) = (select 'CustomerID|' + ISNULL(@CustomerID,' ') + '}'+ 'CustomerName|' + isnull(@CustomerName,' ')
	+ '}'+ 'AssetClassAlt_Key_Pos|'+convert(varchar,isnull(@AssetClassAlt_Key,''))+ '}'+ 'NPADate_Pos|'+isnull(@NPADate,'')+ '}'+ 'SecurityValue_Pos|'+isnull(@SecurityValue,'')
	+ '}'+ 'AdditionalProvision_Pos|'+convert(varchar,isnull(@AdditionalProvision,'0'))+ '} '+'MOCTypeAlt_Key|'+convert(varchar,isnull(@MocTypeAlt_Key,''))+ '}'+ 'MOCReason|'+isnull(@MOCReason,'')
	+ '}'+ 'MOCSourceAltKey|'+convert(varchar,isnull(@MOCSourceAltkey,'')))

		
	--DECLARE		@Result					INT				=0 
	exec SecurityCheckDataValidation 126 ,@Parameter1,@Result OUTPUT
				
	IF @Result = -1
	return -1



	set @NPADate = case when (@NPADate='' or  @NPADate='01/01/1900') then null else @NPADate end

		DECLARE 
						@AuthorisationStatus		varchar(5)			= NULL 
						,@CreatedBy					VARCHAR(20)		= NULL
						,@DateCreated				SMALLDATETIME	= NULL
						,@ModifiedBy				VARCHAR(20)		= NULL
						,@DateModified				SMALLDATETIME	= NULL
						,@ApprovedBy				VARCHAR(20)		= NULL
						,@DateApproved				SMALLDATETIME	= NULL
						,@ErrorHandle				int				= 0
						,@ExEntityKey				int				= 0  
						
------------Added for Rejection Screen  29/06/2020   ----------

		DECLARE			@Uniq_EntryID			int	= 0
						,@RejectedBY			Varchar(50)	= NULL
						,@RemarkBy				Varchar(50)	= NULL
						,@RejectRemark			Varchar(200) = NULL
						,@ScreenName			Varchar(200) = NULL
						,@ApprovedByFirstLevel      VARCHAR(20)     =NULL
                        ,@DateApprovedFirstLevel    SMALLDATETIME     =NULL
						,@MOCType_Flag              varchar(4)      =null
						,@MOC_DATE                  VARCHAR(20)     =NULL

				SET @ScreenName = 'CustomerLevel'

	-------------------------------------------------------------
	
 --SET @Timekey =(Select TimeKey from SysDataMatrix where CurrentStatus='C') 

 -- SET @Timekey =(Select LastMonthDateKey from SysDayMatrix where Timekey=@Timekey) 

 
SET @Timekey =(Select Timekey from SysDataMatrix Where MOC_Initialised='Y' AND ISNULL(MOC_Frozen,'N')='N') 
--SET @Timekey =(Select Timekey from SysDataMatrix Where MOC_Initialised='Y' AND ISNULL(MOC_Frozen,'N')='N') 
    SET @MOC_Date =(Select cast(ExtDate as date) from SysDataMatrix where Timekey=@TimeKey)
  
 SET @EffectiveFromTimeKey  = @TimeKey

	SET @EffectiveToTimeKey = 49999

		Declare @MocStatus Varchar(100)=''
		
Select @MocStatus=MocStatus 
 from MOCMonitorStatus
Where EntityKey in(Select Max(EntityKey) From MOCMonitorStatus)

IF(@MocStatus='InProgress')
  Begin
     SET @Result=5
	RETURN @Result
  End

	Declare @CustomerEntityID int
	Select  @CustomerEntityID= CustomerEntityID from customerbasicdetail
	                          where CustomerId=@CustomerId 
							  and   EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey


							  	
	IF EXISTS(SELECT 1 FROM MOC_ChangeDetails WHERE (EffectiveFromTimeKey=@TimeKey AND EffectiveToTimeKey=@TimeKey) 
										AND CustomerEntityID=@CustomerEntityID AND MOCType_Flag='ACCT' AND MOCProcessed='N')

		  Begin
     SET @Result=6
	RETURN @Result
  End

	set @SecurityValue=case when @SecurityValue='' then NULL else @SecurityValue end



		declare @MocTypeDesc varchar(20)
						--select @MocTypeDesc =MOCTypeName from DimMOCType where MOCTypeAlt_Key=@MocTypeAlt_Key
						-- AND EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey
                         select @MocTypeDesc =ParameterName from dimparameter 
						   where Dimparametername= 'MocType' 
                                          and ParameterAlt_Key=@MocTypeAlt_Key
                                         AND EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey


	Declare @MOCReason_1 varchar(200)
      set @MOCReason_1 = (Select ParameterName from DimParameter where DimParameterName like '%MOCReason%'
	                                               and   EffectiveFromTimeKey<=@TimeKey 
												   AND EffectiveToTimeKey>=@TimeKey
												   and ParameterAlt_Key=@MOCReason )

	--SET @BankRPAlt_Key = (Select ISNULL(Max(BankRPAlt_Key),0)+1 from DimBankRP)
	PRINT 'A'

	DECLARE @AppAvail CHAR
			SET @AppAvail = (Select ParameterValue FROM SysSolutionParameter WHERE Parameter_Key=6)
					IF(@AppAvail='N')                         
			BEGIN
				SET @Result=-11
				RETURN @Result
			END

	
	BEGIN TRY
	BEGIN TRANSACTION	
	-----
	
	PRINT 3	
		--np- new,  mp - modified, dp - delete, fm - further modifief, A- AUTHORISED , 'RM' - REMARK 
	IF @OperationFlag =1 AND @AuthMode ='Y' -- ADD
		BEGIN
				     PRINT 'Add'
					 SET @CreatedBy =@CrModApBy 
					 SET @DateCreated = GETDATE()
					 SET @AuthorisationStatus='NP'

					

					 GOTO MOCcustomerDateMaster_Insert
					MOCcustomerDateMaster_Insert_Add:
			END


			ELSE IF(@OperationFlag = 2 OR @OperationFlag = 3) AND @AuthMode = 'Y' --EDIT AND DELETE
			BEGIN
				Print 4
				SET @CreatedBy= @CrModApBy
				SET @DateCreated = GETDATE()
				Set @Modifiedby=@CrModApBy   
				Set @DateModified =GETDATE() 

					PRINT 5

					IF @OperationFlag = 2
						BEGIN
							PRINT 'Edit'
							SET @AuthorisationStatus ='MP'
							
						END

					ELSE
						BEGIN
							PRINT 'DELETE'
							SET @AuthorisationStatus ='DP'
							
						END

						---FIND CREATED BY FROM MAIN TABLE
					SELECT  @CreatedBy		= CreatedBy
							,@DateCreated	= DateCreated 
					
					FROM MOC_ChangeDetails 
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND  CustomerEntityID =@CustomerEntityID AND MOCType_Flag='CUST'

				---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE
				IF ISNULL(@CreatedBy,'')=''
				BEGIN
					PRINT 'NOT AVAILABLE IN MAIN'
					SELECT  @CreatedBy		= CreatedBy
							,@DateCreated	= DateCreated 
					FROM CustomerLevelMOC_Mod 
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND  CustomerEntityID =@CustomerEntityID
							AND AuthorisationStatus IN('NP','MP','A','RM')
															
				END
				ELSE ---IF DATA IS AVAILABLE IN MAIN TABLE
					BEGIN
					       Print 'AVAILABLE IN MAIN'
						----UPDATE FLAG IN MAIN TABLES AS MP
						UPDATE MOC_ChangeDetails
							SET AuthorisationStatus=@AuthorisationStatus
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND  CustomerEntityID =@CustomerEntityID AND MOCType_Flag='CUST'

					END

					--UPDATE NP,MP  STATUS 
					IF @OperationFlag=2
					BEGIN	

						UPDATE CustomerLevelMOC_Mod
							SET AuthorisationStatus='FM'
							,ModifiedBy=@Modifiedby
							,DateModified=@DateModified
							,EffectiveToTimeKey=@TimeKey-1
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND  CustomerEntityID =@CustomerEntityID
								AND AuthorisationStatus IN('NP','MP','RM')

								UPDATE CustomerLevelMOC_Mod
							SET EffectiveToTimeKey=@TimeKey-1
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND  CustomerEntityID =@CustomerEntityID
								AND AuthorisationStatus IN('A')
					END

					GOTO MOCcustomerDateMaster_Insert
					MOCcustomerDateMaster_Insert_Edit_Delete:
				END

		ELSE IF @OperationFlag =3 AND @AuthMode ='N'
		BEGIN
		-- DELETE WITHOUT MAKER CHECKER
											
						SET @Modifiedby   = @CrModApBy 
						SET @DateModified = GETDATE() 

						UPDATE CustomerLevelMOC_Mod SET
									ModifiedBy =@Modifiedby 
									,DateModified =@DateModified 
									,EffectiveToTimeKey =@EffectiveFromTimeKey-1
								WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) 
								AND  CustomerEntityID =@CustomerEntityID
				

		end


-------------------------------------------------------


--start 20042021
ELSE IF @OperationFlag=21 AND @AuthMode ='Y' 
		BEGIN
				SET @ApprovedBy	   = @CrModApBy 
				SET @DateApproved  = GETDATE()

				UPDATE CustomerLevelMOC_Mod
					SET AuthorisationStatus='R'
					,ApprovedBy	 =@ApprovedBy
					,DateApproved=@DateApproved
					,EffectiveToTimeKey =@EffectiveFromTimeKey-1
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						AND   CustomerEntityID =@CustomerEntityID
						AND AuthorisationStatus in('NP','MP','DP','RM','1A')	

		IF EXISTS(SELECT 1 FROM MOC_ChangeDetails WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) 
		                                            AND   CustomerEntityID =@CustomerEntityID AND MOCType_Flag='CUST')
				BEGIN
					UPDATE MOC_ChangeDetails
						SET AuthorisationStatus='A'
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND  CustomerEntityID =@CustomerEntityID
							AND MOCType_Flag='CUST'
							AND AuthorisationStatus IN('MP','DP','RM') 	
				END
		END	


--till here
-------------------------------------------------------

	
	
	ELSE IF @OperationFlag=17 AND @AuthMode ='Y' 
		BEGIN
				SET @ApprovedBy	   = @CrModApBy 
				SET @DateApproved  = GETDATE()

				UPDATE CustomerLevelMOC_Mod
					SET AuthorisationStatus='R'
					,ApprovedByFirstLevel	 =@ApprovedBy
					,DateApprovedFirstLevel	=@DateApproved
					,EffectiveToTimeKey =@EffectiveFromTimeKey-1
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						AND  CustomerEntityID =@CustomerEntityID
						AND AuthorisationStatus in('NP','MP','DP','RM')	

---------------Added for Rejection Pop Up Screen  29/06/2020   ----------

		Print 'Sunil'

--		DECLARE @EntityKey as Int 
		--SELECT	@CreatedBy=CreatedBy,@DateCreated=DATECreated,@EntityKey=EntityKey
		--					 FROM MOCInitializeDetails_Mod 
		--						WHERE (EffectiveToTimeKey =@EffectiveFromTimeKey-1 )
		--							AND MOCInitializeDate=@MOCInitializeDate And ISNULL(AuthorisationStatus,'A')='R'
		
--	EXEC [AxisIntReversalDB].[RejectedEntryDtlsInsert]  @Uniq_EntryID = @EntityKey, @OperationFlag = @OperationFlag ,@AuthMode = @AuthMode ,@RejectedBY = @CrModApBy
--,@RemarkBy = @CreatedBy,@DateCreated=@DateCreated ,@RejectRemark = @Remark ,@ScreenName = @ScreenName
		

--------------------------------

				IF EXISTS(SELECT 1 FROM MOC_ChangeDetails WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey)
				AND  CustomerEntityID =@CustomerEntityID AND MOCType_Flag='CUST')
				BEGIN
					UPDATE MOC_ChangeDetails
						SET AuthorisationStatus='A'
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND  CustomerEntityID =@CustomerEntityID
							AND MOCType_Flag='CUST'
							AND AuthorisationStatus IN('MP','DP','RM') 	
				END
		END	

	ELSE IF @OperationFlag=18
	BEGIN
		PRINT 18
		SET @ApprovedBy=@CrModApBy
		SET @DateApproved=GETDATE()
		UPDATE CustomerLevelMOC_Mod
		SET AuthorisationStatus='RM'
		WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
		AND AuthorisationStatus IN('NP','MP','DP','RM')
		AND  CustomerEntityID =@CustomerEntityID

	END

	ELSE IF @OperationFlag=16

		BEGIN

		SET @ApprovedBy	   = @CrModApBy 
		SET @DateApproved  = GETDATE()

		UPDATE CustomerLevelMOC_Mod
						SET AuthorisationStatus ='1A'
							,ApprovedByFirstLevel	 =@ApprovedBy
					        ,DateApprovedFirstLevel	=@DateApproved
							WHERE   CustomerEntityID =@CustomerEntityID
							AND AuthorisationStatus in('NP','MP','DP','RM')



		END

	ELSE IF @OperationFlag=20 OR @AuthMode='N'
		BEGIN
			
			Print 'Authorise'
	-------set parameter for  maker checker disabled
			IF @AuthMode='N'
			BEGIN
				IF @OperationFlag=1
					BEGIN
						SET @CreatedBy =@CrModApBy
						SET @DateCreated =GETDATE()
					END
				ELSE
					BEGIN
						SET @ModifiedBy  =@CrModApBy
						SET @DateModified =GETDATE()
						SELECT	@CreatedBy=CreatedBy,@DateCreated=DATECreated
					 FROM MOC_ChangeDetails 
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey >=@TimeKey )
							AND   CustomerEntityID =@CustomerEntityID
					
					SET @ApprovedBy = @CrModApBy			
					SET @DateApproved=GETDATE()
					END
			END	
			
	---set parameters and UPDATE mod table in case maker checker enabled
			IF @AuthMode='Y'  
				BEGIN
				    Print 'B'
					DECLARE @DelStatus CHAR(2)=''-------------20042021
					DECLARE @CurrRecordFromTimeKey smallint=0

					Print 'C'
					SELECT @ExEntityKey= MAX(Entity_Key) FROM CustomerLevelMOC_Mod 
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
							AND  CustomerEntityID =@CustomerEntityID
							AND AuthorisationStatus IN('NP','MP','DP','RM','1A')	

					SELECT	@DelStatus=AuthorisationStatus,@CreatedBy=CreatedBy,@DateCreated=DATECreated
						,@ModifiedBy=ModifiedBy, @DateModified=DateModified,@ApprovedByFirstLevel=ApprovedByFirstLevel,@DateApprovedFirstLevel=DateApprovedFirstLevel
					 FROM CustomerLevelMOC_Mod
						WHERE Entity_Key=@ExEntityKey
					
					SET @ApprovedBy = @CrModApBy			
					SET @DateApproved=GETDATE()
				
					
					DECLARE @CurEntityKey INT=0

					--SELECT @ExEntityKey= MIN(Entity_Key) FROM CustomerLevelMOC_Mod 
					--	WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
					--		AND  CustomerEntityID =@CustomerEntityID
					--		AND AuthorisationStatus IN('NP','MP','DP','RM','1A')	
				
					SELECT	@CurrRecordFromTimeKey=EffectiveFromTimeKey 
						 FROM CustomerLevelMOC_Mod
							WHERE Entity_Key=@ExEntityKey

					UPDATE CustomerLevelMOC_Mod
						SET  EffectiveToTimeKey =@CurrRecordFromTimeKey-1
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
						AND  CustomerEntityID =@CustomerEntityID
						AND AuthorisationStatus='A'	

		-------DELETE RECORD AUTHORISE
					IF @DelStatus='DP' 
					BEGIN	
						UPDATE CustomerLevelMOC_Mod
						SET AuthorisationStatus ='A'
							,ApprovedBy=@ApprovedBy
							,DateApproved=@DateApproved
							,EffectiveToTimeKey =@EffectiveFromTimeKey -1
						WHERE   CustomerEntityID =@CustomerEntityID
							AND AuthorisationStatus in('NP','MP','DP','RM','1A')
						
						IF EXISTS(SELECT 1 FROM MOC_ChangeDetails WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
										AND   CustomerEntityID =@CustomerEntityID AND MOCType_Flag='CUST')
						BEGIN
								UPDATE MOC_ChangeDetails
									SET AuthorisationStatus ='A'
										,ModifiedBy=@ModifiedBy
										,DateModified=@DateModified
										,ApprovedBy=@ApprovedBy
										,DateApproved=@DateApproved
										,EffectiveToTimeKey =@EffectiveFromTimeKey-1
									WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
											AND  CustomerEntityID =@CustomerEntityID
											AND MOCType_Flag='CUST'

								
						END
					END -- END OF DELETE BLOCK

					ELSE  -- OTHER THAN DELETE STATUS
					BEGIN
							UPDATE CustomerLevelMOC_Mod
								SET AuthorisationStatus ='A'
									,ApprovedBy=@ApprovedBy
									,DateApproved=@DateApproved
								WHERE   CustomerEntityID =@CustomerEntityID			
									AND AuthorisationStatus in('NP','MP','RM','1A')

			

									
					END		
				END

		IF @DelStatus <>'DP' OR @AuthMode ='N'
				BEGIN
						
						DECLARE @IsAvailable CHAR(1)='N'
						,@IsSCD2 CHAR(1)='N'
								SET @AuthorisationStatus='A' 



						UPDATE MOC_ChangeDetails
									SET EffectiveToTimeKey =@EffectiveFromTimeKey-1,
									    AuthorisationStatus='A'
									WHERE (EffectiveFromTimeKey<@Timekey AND EffectiveToTimeKey >=@Timekey)
											AND  CustomerEntityID =@CustomerEntityID
											AND MOCType_Flag='CUST'

											
					

						IF EXISTS(SELECT 1 FROM MOC_ChangeDetails WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
									AND  CustomerEntityID =@CustomerEntityID AND MOCType_Flag='CUST')
							BEGIN
								SET @IsAvailable='Y'
								--SET @AuthorisationStatus='A'
                            END

                IF  @IsAvailable='Y'
				  BEGIN
						UPDATE   MOC_ChangeDetails
						SET
                                 MOCType_Flag            ='CUST'
                                , CustomerEntityID		 =@CustomerEntityID
                                , AssetClassAlt_Key		 =@AssetClassAlt_Key
                                , NPA_Date				 =@NPADate
                                , CurntQtrRv			 =@SecurityValue
                                --, MOC_ExpireDate		 =@MOC_ExpireDate
                                , MOC_Reason			 =@MOCReason_1
								, MOCTYPE                =@MocTypeDesc
                                , MOC_Date				 =@MOC_DATE
								--, AdditionalProvision    =@AdditionalProvision
								,AddlProvPer             =@AdditionalProvision
                                -- MOC_By					 =
                                , MOC_Source			 =@MOCSourceAltkey
                                , AuthorisationStatus	 =@AuthorisationStatus
                                , EffectiveFromTimeKey	 =@Timekey
                                , EffectiveToTimeKey	 =49999
                                , CreatedBy				 =@CrModApBy
                                , DateCreated			 =@DateCreated
                                , ModifiedBy			 =@ModifiedBy
                                , DateModified			 =@DateModified
                                , ApprovedByFirstLevel	 =@ApprovedByFirstLevel
                                , DateApprovedFirstLevel =@DateApprovedFirstLevel
                                , ApprovedBy			 =@ApprovedBy
                                , DateApproved			 =@DateApproved
								,MOCProcessed='N'

                     WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND EffectiveFromTimeKey=@EffectiveFromTimeKey AND      
												CustomerEntityID=@CustomerEntityID
												AND MOCType_Flag='CUST'
							END

									ELSE
										BEGIN
											SET @IsSCD2='Y'
										END
								

								IF @IsAvailable='N' OR @IsSCD2='Y'
									BEGIN
									INSERT INTO MOC_ChangeDetails
								(
                                         MOCType_Flag
                                        ,CustomerEntityID
                                        ,AssetClassAlt_Key
                                        ,NPA_Date
                                        ,CurntQtrRv
										--,AdditionalProvision
										,AddlProvPer
                                        --,MOC_ExpireDate
                                        ,MOC_Reason
                                        ,MOC_Date
                                        ,MOC_Source
                                        ,AuthorisationStatus
                                        ,EffectiveFromTimeKey
                                        ,EffectiveToTimeKey
                                        ,CreatedBy
                                        ,DateCreated
                                        ,ModifiedBy
                                        ,DateModified
                                        ,ApprovedByFirstLevel
                                        ,DateApprovedFirstLevel
                                        ,ApprovedBy
                                        ,DateApproved
										
										--,ScreenFlag
										,MOCProcessed
										,MOCTYPE
										
								)
					SELECT
					                      
                                         'CUST'
										,@CustomerEntityID
										,@AssetClassAlt_Key
										,@NPADate
										,@SecurityValue
										,@AdditionalProvision
										--,@MOC_ExpireDate
										,@MOCReason_1
										,@MOC_DATE
										,@MOCSourceAltkey
										,'A'
										,@TimeKey
										,49999
										,@CreatedBy
										,@DateCreated
										,@ModifiedBy
										,@DateModified
										,@ApprovedByFirstLevel
										,@DateApprovedFirstLevel
										,@CrModApBy
										,GETDATE()	
										,'N'
										--,'S'
										--,@MocTypeAlt_Key
										,@MocTypeDesc
										
									END


									IF @IsSCD2='Y' 
								BEGIN
								UPDATE MOC_ChangeDetails SET
										--EffectiveToTimeKey=@EffectiveFromTimeKey-1,
										AuthorisationStatus =CASE WHEN @AUTHMODE='Y' THEN  'A' ELSE NULL END
									WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) 
									          AND CustomerEntityID=@CustomerEntityID
											  AND MOCType_Flag='CUST'
											AND EffectiveFromTimekey<@EffectiveFromTimeKey
								END
							END

		IF @AUTHMODE='N'
			BEGIN
					SET @AuthorisationStatus='A'
					GOTO MOCcustomerDateMaster_Insert
					HistoryRecordInUp:
			END						



		END
PRINT 6
SET @ErrorHandle=1

MOCcustomerDateMaster_Insert:
IF @ErrorHandle=0
	BEGIN
			INSERT INTO CustomerLevelMOC_Mod  
											( 
												CustomerID
												,CustomerEntityID			
												,CustomerName		
												,AssetClassAlt_Key			
												,NPADate			
												,SecurityValue
												,AdditionalProvision
												,MOCReason
												,MOCSourceAltkey
												,MOCDate
												,MOCType
												,ScreenFlag		
												,AuthorisationStatus	
												,EffectiveFromTimeKey
												,EffectiveToTimeKey
												,CreatedBy
												,DateCreated
												,ModifiedBy
												,DateModified
												,ApprovedBy
												,DateApproved
												,ChangeField
												--,MOC_ExpireDate
												,MOCType_Flag									
											)
								VALUES
											( 
												 	@CustomerID	
													,@CustomerEntityID		
												   ,@CustomerName		
												   ,@AssetClassAlt_Key		
												   ,@NPADate			
												   ,@SecurityValue
												   ,@AdditionalProvision
												   ,@MOCReason_1	
												   ,@MOCSourceAltkey
												   ,@MOC_DATE
												  -- ,@MocTypeAlt_Key
												   ,@MocTypeDesc
												   ,@ScreenFlag		
												   ,@AuthorisationStatus
												   ,@EffectiveFromTimeKey
												   ,@EffectiveToTimeKey 
												   ,@CreatedBy
												   ,@DateCreated
												   ,@ModifiedBy 
												   ,@DateModified 
												   ,@ApprovedBy    
												   ,@DateApproved  
													,@CustomerNPAMOC_ChangeFields
													--,@MOC_ExpireDate
													,'CUST'
											)
											
			
							DECLARE @Parameter3 varchar(50)
	DECLARE @FinalParameter3 varchar(50)
	SET @Parameter3 = (select STUFF((	SELECT Distinct ',' +ChangeField
											from CustomerLevelMOC_Mod where   CustomerEntityID=@CustomerEntityID
											and ISNULL(AuthorisationStatus,'A')  in ( 'A','MP')
											 for XML PATH('')),1,1,'') )

											If OBJECT_ID('#AA') is not null
											drop table #AA

select DISTINCT VALUE 
into #AA 
from (
		SELECT 	CHARINDEX('|',VALUE) CHRIDX,VALUE
		FROM( SELECT VALUE FROM STRING_SPLIT(@Parameter3,',')
 ) A
 )X
 SET @FinalParameter3 = (select STUFF((	SELECT Distinct ',' + Value from #AA  for XML PATH('')),1,1,''))
 
							UPDATE		A
							set			a.ChangeField = @FinalParameter3							 																																	
							from		CustomerLevelMOC_Mod   A
							WHERE		(EffectiveFromTimeKey<=@tiMEKEY AND EffectiveToTimeKey>=@tiMEKEY) 
							and			  CustomerEntityID=@CustomerEntityID	
			
											

		         IF @OperationFlag =1 AND @AUTHMODE='Y'
					BEGIN
						PRINT 3
						GOTO MOCcustomerDateMaster_Insert_Add
					END
				ELSE IF (@OperationFlag =2 OR @OperationFlag =3)AND @AUTHMODE='Y'
					BEGIN
						GOTO MOCcustomerDateMaster_Insert_Edit_Delete
					END
					

				
	END

	
		
IF @OperationFlag IN (1,2,3,16,17,18,20,21) AND @AuthMode ='Y'
		BEGIN
					print 'log table'

					
				SET	@DateCreated     =Getdate()

					IF @OperationFlag IN(16,17,18,20,21) 
						BEGIN 
						       Print 'Authorised'
					
			
								EXEC LogDetailsInsertUpdate_Attendence -- MAINTAIN LOG TABLE
							    @BranchCode=''   ,  ----BranchCode
								@MenuID=@MenuID,
								@ReferenceID=@CustomerID ,-- ReferenceID ,
								@CreatedBy=NULL,
								@ApprovedBy=@CrModApBy, 
								@CreatedCheckedDt=@DateCreated,
								@Remark=@Remark,
								@ScreenEntityAlt_Key=16  ,---ScreenEntityId -- for FXT060 screen
								@Flag=@OperationFlag,
								@AuthMode=@AuthMode
						END
					ELSE
						BEGIN
						       Print 'UNAuthorised'
						    -- Declare
						     set @CreatedBy  =@CrModApBy
							 
							EXEC LogDetailsInsertUpdate_Attendence -- MAINTAIN LOG TABLE
								@BranchCode=''   ,  ----BranchCode
								@MenuID=@MenuID,
								@ReferenceID=@CustomerID ,-- ReferenceID ,
								@CreatedBy=@CrModApBy,
								@ApprovedBy=NULL, 						
								@CreatedCheckedDt=@DateCreated,
								@Remark=@Remark,
								@ScreenEntityAlt_Key=16  ,---ScreenEntityId -- for FXT060 screen
								@Flag=@OperationFlag,
								@AuthMode=@AuthMode
						END

		END



	-------------------
PRINT 7
		COMMIT TRANSACTION

	
		IF @OperationFlag =3
			BEGIN
				SET @Result=0
			END
		ELSE
			BEGIN
				SET @Result=1
			END
END TRY
BEGIN CATCH
	ROLLBACK TRAN

	INSERT INTO dbo.Error_Log
				SELECT ERROR_LINE() as ErrorLine,ERROR_MESSAGE()ErrorMessage,ERROR_NUMBER()ErrorNumber
				,ERROR_PROCEDURE()ErrorProcedure,ERROR_SEVERITY()ErrorSeverity,ERROR_STATE()ErrorState
				,GETDATE()

	SELECT ERROR_MESSAGE()
	RETURN -1
   
END CATCH
---------
END
GO