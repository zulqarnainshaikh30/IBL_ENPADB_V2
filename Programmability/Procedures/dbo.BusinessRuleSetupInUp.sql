SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO




-- =============================================
-- Author:		<Author Triloki Kumar>
-- Create date: <Create Date 13/03/2020>
-- Description:	<Description  Business Rule Setup Inup >
-- =============================================
CREATE PROCEDURE [dbo].[BusinessRuleSetupInUp]
@BusinessRule_Alt_key		INT
--,@Territoryalt_key			INT
,@CatAlt_key				INT
,@UniqueID					INT
,@Businesscolalt_key		INT	
,@Scope						INT
,@Businesscolvalues1		VARCHAR(MAX)	
,@Businesscolvalues			VARCHAR(MAX)
,@UserId					VARCHAR(50)
,@OperationFlag				INT
,@D2kTimestamp				INT	OUTPUT
,@Result					INT OUTPUT
,@AuthMode					CHAR(1)			= 'Y'


,@Expression varchar(max)=''
,@FinalExpression VARCHAR(MAX)=''

AS
BEGIN
---------------Added by Poonam----------------
declare @unid int

set @Unid=(select isnull(max(UniqueID),0) from DimBusinessRuleSetup_MOD)
-----------------------------------------------f
	
	SET NOCOUNT ON;

	Declare @Timekey int, @EffectiveFromTimeKey	int, @EffectiveToTimeKey	int, @AuthorisationStatus		Varchar(2)	= NULL
						,@CreatedBy					VARCHAR(20)		= NULL
						,@DateCreated				SMALLDATETIME	= NULL
						,@ModifiedBy				VARCHAR(20)		= NULL
						,@DateModified				SMALLDATETIME	= NULL
						,@ApprovedBy				VARCHAR(20)		= NULL
						,@DateApproved				SMALLDATETIME	= NULL

	 SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C') 

 SET @EffectiveFromTimeKey  = @TimeKey

	SET @EffectiveToTimeKey = 49999


				DECLARE @BusinessCol VARCHAR(50)
				SELECT @BusinessCol=BusinessRuleColDesc FROM DimBusinessRuleCol WHERE EffectiveToTimeKey=49999 AND BusinessRuleColAlt_Key=@Businesscolalt_key
	

	IF OBJECT_ID('TEMPDB..#TEMP123')IS NOT NULL
				DROP TABLE #TEMP123
			
			SELECT * INTO #TEMP123 FROM SPLIT(@Businesscolvalues1,',')
		update #TEMP123
			set Items=ltrim(rtrim(Items))
			--select * from #TEMP123


			IF @OperationFlag=1
				BEGIN
					IF EXISTS (SELECT 1 FROM DimBusinessRuleSetup WHERE UniqueID=@UniqueID  
										AND CatAlt_key=@CatAlt_key AND EffectiveToTimeKey=49999 AND   ISNULL(AuthorisationStatus,'A') in('A')
					UNION
								SELECT  1 FROM DimBusinessRuleSetup_MOD  WHERE (EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey)
										AND UniqueID=@UniqueID  AND CatAlt_key=@CatAlt_key AND   ISNULL(AuthorisationStatus,'A') in('NP','MP','DP','RM')
								)
						BEGIN
							SET @Result=-6
							RETURN @Result
						END 
				
					ELSE
						BEGIN
							SELECT @UniqueID=MAX(UniqueID) FROM DimBusinessRuleSetup WHERE  CatAlt_key=@CatAlt_key AND EffectiveToTimeKey=49999
							select @BusinessRule_Alt_key=MAX(BusinessRule_Alt_key) FROM DimBusinessRuleSetup WHERE  CatAlt_key=@CatAlt_key AND EffectiveToTimeKey=49999
						END 
				END 

				/*
			 IF @BusinessCol='ProductCode'
					BEGIN		
								
				select * from #TEMP123
								
							IF EXISTS (SELECT 1 FROM #TEMP123 A
								LEFT JOIN DimGLProduct_AU B
									ON A.Items=B.ProductCode
									WHERE B.ProductCode IS NULL
								)	
								BEGIN
									SET @Result=-2
									RETURN @Result
								END 														
						END 
*/

			IF ISNULL(@UniqueID,0)=0
				BEGIN
					 SET @UniqueID=0
					
				END

			
			IF ISNULL(@BusinessRule_Alt_key,0)=0
				BEGIN
					select @BusinessRule_Alt_key=MAX(BusinessRule_Alt_key)+1 FROM DimBusinessRuleSetup
				END

				IF ISNULL(@BusinessRule_Alt_key,0)=0
				BEGIN
					set @BusinessRule_Alt_key=1
				END
/*
			 IF @BusinessCol='ProductCode'
				BEGIN
				 SELECT @Businesscolvalues1=STUFF(
                         (                             							 
							SELECT ','+CONVERT(VARCHAR(MAX),GLProductAlt_Key) FROM DimGLProduct WHERE ProductCode IN(SELECT ITEMS FROM #TEMP123)							
							 FOR XML PATH('')
                         ), 1, 1, '')
					END 
					*/

	BEGIN TRY
		BEGIN TRAN

		 IF @OperationFlag=16

		BEGIN
	 --   --SET @UserId=@UserId
		--PRINT '@UserId'
		--PRINT @UserId
		--PRINT '@UserId'
		--PRINT @UserId
		SET @ApprovedBy	   = @UserId 
		SET @DateApproved  = GETDATE()

		UPDATE DimBusinessRuleSetup_Mod
						SET AuthorisationStatus ='1A'
							,ApprovedBy=@UserId
							,DateApproved=@DateApproved
							WHERE --BusinessRule_Alt_key=@BusinessRule_Alt_key AND     -------------Changed on 29042021 
							CatAlt_key=@CatAlt_key
							AND AuthorisationStatus in('NP','MP','DP','RM')

		END
		ELSE

				IF (@OperationFlag=20)
					BEGIN
					print 'G'
					 SET @AuthorisationStatus='A'
					
					 Set @Modifiedby=@UserId   
					 Set @DateModified =GETDATE()
					 SET @ApprovedBy=@UserId
					 SET @DateApproved=GETDATE()

					 SELECT  @CreatedBy		= CreatedBy
							,@DateCreated	= DateCreated 
					FROM DimBusinessRuleSetup_Mod
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND CatAlt_key =@CatAlt_key
							 	AND AuthorisationStatus in('NP','MP','RM','1A')
 


          --               IF EXISTS(SELECT 1 FROM DimBusinessRuleSetup WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
										--AND EffectiveFromTimeKey=@TimeKey AND CatAlt_key =@CatAlt_key )
										--AND UniqueID=@UniqueID
							BEGIN
							 
											INSERT INTO DimBusinessRuleSetup
										(
											BusinessRule_Alt_key
											,CatAlt_key
											,UniqueID
											,Businesscolalt_key
											,Scope
											,Businesscolvalues1
											,Businesscolvalues
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
											BusinessRule_Alt_key
											,CatAlt_key
											,UniqueID
											,Businesscolalt_key
											,Scope
											,Businesscolvalues1
											,Businesscolvalues
											,'A' AuthorisationStatusAS
											,@Timekey
											,49999
											,@UserId CreatedBy
											,@DateCreated
											,@Modifiedby
											,@DateModified
											,NULL ApprovedBy
											,NULL DateApproved
											From DimBusinessRuleSetup_mod
									Where CatAlt_key=@CatAlt_key AND AuthorisationStatus in('1A') 
									AND  (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
									
								UPDATE DimBusinessRuleSetup_Mod
								SET EffectiveToTimeKey=EffectiveFromTimeKey-1
								WHERE CatAlt_key=@CatAlt_key				
									AND AuthorisationStatus in('A')	--AND UniqueID=@UniqueID

									UPDATE DimBusinessRuleSetup_Mod
								SET AuthorisationStatus ='A'
									,ApprovedBy=@ApprovedBy
									,DateApproved=@DateApproved
									
									--,EffectiveToTimeKey=EffectiveFromTimeKey-1
								WHERE CatAlt_key=@CatAlt_key				
									AND AuthorisationStatus in('1A')	--AND UniqueID=@UniqueID

										
								UPDATE DimBusinessRuleSetup
								SET EffectiveToTimeKey=EffectiveFromTimeKey-1
								WHERE CatAlt_key=@CatAlt_key				
									AND AuthorisationStatus in('MP')	

								UPDATE DimBusinessRuleSetup
								SET AuthorisationStatus ='A'
									,ApprovedBy=@ApprovedBy
									,DateApproved=@DateApproved
									
									--,EffectiveToTimeKey=EffectiveFromTimeKey-1
								WHERE CatAlt_key=@CatAlt_key				
									AND AuthorisationStatus in('MP','NP')		
							END
       
	                     
                      --   ELSE
						 
     --                    BEGIN
					--	INSERT INTO DimBusinessRuleSetup
					--		(
					--			BusinessRule_Alt_key
					--			,CatAlt_key
					--			,UniqueID
					--			,Businesscolalt_key
					--			,Scope
					--			,Businesscolvalues1
					--			,Businesscolvalues
					--			,AuthorisationStatus
					--			,EffectiveFromTimeKey
					--			,EffectiveToTimeKey
					--			,CreatedBy
					--			,DateCreated
					--			,ApprovedBy
					--			,DateApproved																
					--		)
					--		SELECT 
					--			BusinessRule_Alt_key
					--			,CatAlt_key
					--			,UniqueID
					--			,Businesscolalt_key
					--			,Scope
					--			,Businesscolvalues1
					--			,Businesscolvalues
					--			,'A' AuthorisationStatusAS
					--			,@Timekey
					--			,49999
					--	        ,@CreatedBy
					--			,@DateCreated
					--			,@UserId ApprovedBy
					--			,GETDATE() DateApproved
					--			From DimBusinessRuleSetup_mod
					--	Where CatAlt_key=@CatAlt_key AND AuthorisationStatus in('1A')
					--	AND  (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
									
        


					--UPDATE DimBusinessRuleSetup_mod
					--			SET AuthorisationStatus ='A'
					--				,ApprovedBy=@ApprovedBy
					--				,DateApproved=@DateApproved
					--				--,EffectiveToTimeKey=EffectiveFromTimeKey-1
					--			WHERE CatAlt_key=@CatAlt_key				
					--				AND AuthorisationStatus in('1A') 	--AND UniqueID=@UniqueID
        --      UPDATE DimBusinessRuleSetup_mod
								--SET 
								--	EffectiveToTimeKey=EffectiveFromTimeKey-1
								--WHERE CatAlt_key=@CatAlt_key				
								--	AND AuthorisationStatus in('A')
								--	AND UniqueID=@UniqueID

					--END
									--AND EntityKey IN
                     --(
              --    SELECT MAX(EntityKey)
                     --    FROM DimBusinessRuleSetup_mod
                     --    WHERE EffectiveFromTimeKey <= @TimeKey
                     --          AND EffectiveToTimeKey >= @TimeKey
                     --          AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')
                     --    GROUP BY CatAlt_key
                     --)

					 exec [dbo].[Provision_Update] @ProvisionAlt_Key=@CatAlt_key,@Expression=@Expression
					 ,@FinalExpression=@FinalExpression,@UserId=@UserId,@OperationFlag=@OperationFlag,@Result=@Result

					END 
					
					--BEGIN
					--print'R'
					--		UPDATE DimBusinessRuleSetup_mod
					--			SET AuthorisationStatus ='A'
					--				,ApprovedBy=@ApprovedBy
					--				,DateApproved=@DateApproved
					--			WHERE CatAlt_key=@CatAlt_key				
					--				AND AuthorisationStatus in('NP','MP','RM')
					--				AND EntityKey IN
     --      (
     --                    SELECT MAX(EntityKey)
     --                    FROM DimBusinessRuleSetup_mod
     --                    WHERE EffectiveFromTimeKey <= @TimeKey
     --                        AND EffectiveToTimeKey >= @TimeKey
     --                     AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')
     --                    GROUP BY CatAlt_key
     --                )
					--END	
-----------------------------------------------------
					--IF @OperationFlag=2
					--	BEGIN
							
					--		UPDATE DimBusinessRuleSetup
					--			SET Businesscolalt_key		=@Businesscolalt_key	
					--				,Scope					=@Scope
					--				,Businesscolvalues1		=@Businesscolvalues1
					--				,Businesscolvalues		=@Businesscolvalues
					--				,ModifiedBy				=@UserId
					--				,DateModified			=GETDATE()																			
					--			WHERE UniqueID=@UniqueID 
					--			AND BusinessRule_Alt_key=@BusinessRule_Alt_key
					--			AND Territoryalt_key=@Territoryalt_key 
					--			AND CatAlt_key=@CatAlt_key 
					--	END 


					IF @OperationFlag =3
						BEGIN
						print'8'
							--DELETE FROM DimBusinessRuleSetup								
							--	WHERE UniqueID=@UniqueID 
							--	AND BusinessRule_Alt_key=@BusinessRule_Alt_key
							--	AND Territoryalt_key=@Territoryalt_key 
							--	AND CatAlt_key=@CatAlt_key 


							SET @Modifiedby   = @UserId 
						SET @DateModified = GETDATE() 

						UPDATE DimBusinessRuleSetup SET
									ModifiedBy =@Modifiedby 
									,DateModified =@DateModified 
									,EffectiveToTimeKey =@TimeKey-1
								WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) 
								--AND  BusinessRule_Alt_key=@BusinessRule_Alt_key 
								AND CatAlt_key=@CatAlt_key


						END 
	------------------------------------------NEW ADD FIRST LVL AUTHT...----------------------
	ELSE IF @OperationFlag=21 AND @AuthMode ='Y' 
		BEGIN
				SET @ApprovedBy	   = @UserId 
				SET @DateApproved  = GETDATE()

				UPDATE DimBusinessRuleSetup_Mod
					SET AuthorisationStatus='R'
					,ApprovedBy	 =@ApprovedBy
					,DateApproved=@DateApproved
					,EffectiveToTimeKey =@EffectiveFromTimeKey-1
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						--AND   BusinessRule_Alt_key=@BusinessRule_Alt_key 
						AND CatAlt_key=@CatAlt_key
						AND AuthorisationStatus in('NP','MP','DP','RM','1A')	

		IF EXISTS(SELECT 1 FROM DimBusinessRuleSetup WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) 
		 --AND   BusinessRule_Alt_key=@BusinessRule_Alt_key 
													 AND CatAlt_key=@CatAlt_key)
				BEGIN
					UPDATE DimBusinessRuleSetup
						SET AuthorisationStatus='A'
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND  BusinessRule_Alt_key=@BusinessRule_Alt_key AND CatAlt_key=@CatAlt_key
							AND AuthorisationStatus IN('MP','DP','RM') 	
				END
		END	
		
	------------------------------------------------------------------------------

	IF @OperationFlag=17 
		BEGIN
		print'J'
				SET @ApprovedBy	   = @UserId 
				SET @DateApproved  = GETDATE()

				UPDATE DimBusinessRuleSetup_Mod
					SET AuthorisationStatus='R'
					,ApprovedBy	 =@ApprovedBy
					,DateApproved=@DateApproved
					,EffectiveToTimeKey =@EffectiveFromTimeKey-1
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						--AND  BusinessRule_Alt_key=@BusinessRule_Alt_key 
						AND CatAlt_key=@CatAlt_key
						AND AuthorisationStatus in('NP','MP','DP','RM')





		Print 'Sunil'
		--
				IF EXISTS(SELECT 1 FROM DimBusinessRuleSetup WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) 
				                   AND  BusinessRule_Alt_key=@BusinessRule_Alt_key  AND CatAlt_key=@CatAlt_key)
				BEGIN
				print'K'
					UPDATE DimBusinessRuleSetup
						SET AuthorisationStatus='A'
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							--AND  BusinessRule_Alt_key=@BusinessRule_Alt_key 
							AND CatAlt_key=@CatAlt_key
							AND AuthorisationStatus IN('MP','DP','RM') 	
				END
		END	




				IF @OperationFlag IN(1,2)
					BEGIN

					IF (@OperationFlag=1)
					BEGIN

					  PRINT 'Add'
					  	
					 SET @CreatedBy =@UserId 
					 SET @DateCreated = GETDATE()
					 SET @AuthorisationStatus='NP'
					
					 SET @BusinessRule_Alt_key = (Select ISNULL(Max(BusinessRule_Alt_key),0)+1 from 
												(Select BusinessRule_Alt_key from DimBusinessRuleSetup
												 UNION 
												 Select BusinessRule_Alt_key from DimBusinessRuleSetup_Mod
												)A)


					 END
					

					Else IF @OperationFlag = 2
						BEGIN
							PRINT 'Edit'
							SET @AuthorisationStatus ='MP'
							 Set @Modifiedby=@UserId   
				             Set @DateModified =GETDATE()
							--SET @CreatedBy= @UserId
							--SET @DateCreated = GETDATE()
							--Set @Modifiedby=@UserId   
							--Set @DateModified =GETDATE() 
							
						END
						
						---FIND CREATED BY FROM MAIN TABLE
						
							SELECT  @CreatedBy= CreatedBy
							,@DateCreated= DateCreated 
							FROM DimBusinessRuleSetup  
							WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							--AND BusinessRule_Alt_key =@Businesscolalt_key
							AND CatAlt_key=@CatAlt_key

					---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE
					IF ISNULL(@CreatedBy,'')=''
				       BEGIN
					   PRINT 'NOT AVAILABLE IN MAIN'
					   SELECT  @CreatedBy		= CreatedBy
							,@DateCreated	= DateCreated 
					   FROM DimBusinessRuleSetup_MOD 
					   WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							--AND Businesscolalt_key =@Businesscolalt_key
							AND CatAlt_key=@CatAlt_key
							AND AuthorisationStatus IN('NP','MP')
															
				       END

				ELSE ---IF DATA IS AVAILABLE IN MAIN TABLE
					BEGIN
					print'Sachin'
					       Print 'AVAILABLE IN MAIN'
						   Print '@CatAlt_key'
						  Print @CatAlt_key
						  Print '@UniqueID'
						   Print @UniqueID
						     Print '@AuthorisationStatus'
						       Print @AuthorisationStatus

						----UPDATE FLAG IN MAIN TABLES AS MP
						IF (@OperationFlag = 2)
						       Begin
									UPDATE DimBusinessRuleSetup
										SET AuthorisationStatus=@AuthorisationStatus
									WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
											--AND Businesscolalt_key =@Businesscolalt_key
											AND CatAlt_key=@CatAlt_key --and UniqueID=@UniqueID
                                End
					END
				

				    --UPDATE NP,MP  STATUS
				  IF @OperationFlag=2
						BEGIN

							--UPDATE DimBusinessRuleSetup_MOD 
							--	SET AuthorisationStatus=@AuthorisationStatus
							--	,ModifiedBy=@Modifiedby
							--	,DateModified=@DateModified
						
							--WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							--		--AND Businesscolalt_key =@Businesscolalt_key
							--		AND CatAlt_key=@CatAlt_key --and UniqueID=@UniqueID

								UPDATE DimBusinessRuleSetup
								SET AuthorisationStatus=@AuthorisationStatus
								,ModifiedBy=@Modifiedby
								,DateModified=@DateModified
							    
						
							WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
									--AND Businesscolalt_key =@Businesscolalt_key
							AND CatAlt_key=@CatAlt_key -- and UniqueID=@UniqueID

							--Select CatAlt_key, UniqueID into #tmp from DimBusinessRuleSetup_MOD
							--WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							--AND CatAlt_key=@CatAlt_key 		
							--Declare @CatAlt_key int,@UniqueID Int,@Count Int,@I Int
							--Select @Count=Count(*) from #tmp
							--SET @I=1
							--While(@I<=@Count)
							--Begin

							 --If (UniqueID=@UniqueID)
									INSERT INTO DimBusinessRuleSetup_MOD
										(
											BusinessRule_Alt_key
											,CatAlt_key
											,UniqueID
											,Businesscolalt_key
											,Scope
											,Businesscolvalues1
											,Businesscolvalues
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
											@BusinessRule_Alt_key
											,@CatAlt_key
											,@UniqueID
											,@Businesscolalt_key
											,@Scope
											,@Businesscolvalues1
											,@Businesscolvalues
											,@AuthorisationStatus
											,@Timekey
											,49999
											,@UserId CreatedBy
											,@DateCreated
											,@Modifiedby
											,@DateModified
											,NULL ApprovedBy
											,NULL DateApproved

											INSERT INTO DimBusinessRuleSetup_MOD
										(
											BusinessRule_Alt_key
											,CatAlt_key
											,UniqueID
											,Businesscolalt_key
											,Scope
											,Businesscolvalues1
											,Businesscolvalues
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
											BusinessRule_Alt_key
											,CatAlt_key
											,UniqueID
											,Businesscolalt_key
											,Scope
											,Businesscolvalues1
											,Businesscolvalues
											,'MP' AuthorisationStatusAS
											,@Timekey
											,49999
											,@UserId CreatedBy
											,@DateCreated
											,@Modifiedby
											,@DateModified
											,NULL ApprovedBy
											,NULL DateApproved
											From DimBusinessRuleSetup_mod
									Where CatAlt_key=@CatAlt_key AND AuthorisationStatus in('A') AND UniqueID<>@UniqueID
									AND  (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
					     END
						 IF @OperationFlag=1
							BEGIN
					 --print'Start'
								INSERT INTO DimBusinessRuleSetup_MOD
									(
										BusinessRule_Alt_key
										,CatAlt_key
										,UniqueID
										,Businesscolalt_key
										,Scope
										,Businesscolvalues1
										,Businesscolvalues
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
										@BusinessRule_Alt_key
										,@CatAlt_key
										,@Unid+1
										,@Businesscolalt_key
										,@Scope
										,@Businesscolvalues1
										,@Businesscolvalues
										,@AuthorisationStatus
										,@Timekey
										,49999
										,@UserId CreatedBy
										,@DateCreated
										,@Modifiedby
										,@DateModified
										,NULL ApprovedBy
										,NULL DateApproved	
							END
					END 

		COMMIT TRAN

		

			--SELECT @D2kTimestamp =CAST(D2kTimestamp AS INT) FROM DimBusinessRuleSetup								
			--					WHERE UniqueID=@UniqueID 
			--					AND BusinessRule_Alt_key=@BusinessRule_Alt_key
			--					AND Territoryalt_key=@Territoryalt_key 
			--					AND CatAlt_key=@CatAlt_key 

			SET @Result=1 
	END TRY

	BEGIN CATCH
		
		ROLLBACK TRAN
		SET @Result=-1
			RETURN @Result
	END CATCH









END

















































GO