SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

Create PROC [dbo].[SMAMasterInUp]

						 @SourceAlt_Key			INT	= 0
						,@CustomerACID			VARCHAR(16)=''
						,@CustomerId			VARCHAR(30) = ''
						,@CustomerName			VARCHAR(200)=''
						--,@ParameterNameAlt_Key	VARCHAR(20)=''
						,@ValueAlt_Key			VARCHAR(100)=''
						
						
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
						
						
AS
BEGIN
	SET NOCOUNT ON;
		PRINT 1
	
		SET DATEFORMAT DMY
	
		DECLARE 
						@AuthorisationStatus		VARCHAR(5)		= NULL 
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

				SET @ScreenName = 'SMAMaster'

	-------------------------------------------------------------

 SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C') 

 SET @EffectiveFromTimeKey  = @TimeKey

	SET @EffectiveToTimeKey = 49999

	--SET @BankRPAlt_Key = (Select ISNULL(Max(BankRPAlt_Key),0)+1 from DimBankRP)
												
	PRINT 'A'
	

			DECLARE @AppAvail CHAR
					SET @AppAvail = (Select ParameterValue FROM SysSolutionParameter WHERE Parameter_Key=6)
				IF(@AppAvail='N')                         
					BEGIN
						SET @Result=-11
						RETURN @Result
					END

				

	IF @OperationFlag=1  --- add
	BEGIN
	PRINT 1
		-----CHECK DUPLICATE
		IF EXISTS(				                
					SELECT  1 FROM DimSMA WHERE CustomerACID=@CustomerACID
					AND ISNULL(AuthorisationStatus,'A')='A' and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey
					UNION
					SELECT  1 FROM DimSMA_Mod  WHERE (EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey)
															AND CustomerACID=@CustomerACID
															AND   ISNULL(AuthorisationStatus,'A') in('NP','MP','DP','RM') 
				)	
				BEGIN
				   PRINT 2
					SET @Result=-4
					RETURN @Result -- USER ALEADY EXISTS
				END
		----ELSE
		----	BEGIN
		----	   PRINT 3
		----		SELECT @BankRPAlt_Key=NEXT VALUE FOR Seq_BankRPAlt_Key
		----		PRINT @BankRPAlt_Key
		----	END
		---------------------Added on 29/05/2020 for user allocation rights
		/*
		IF @AccessScopeAlt_Key in (1,2)
		BEGIN
		PRINT 'Sunil'

		IF EXISTS(				                
					SELECT  1 FROM DimUserinfo WHERE UserLoginID=@BankRPAlt_Key AND ISNULL(AuthorisationStatus,'A')='A' and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey
					And IsChecker='N'
				)	
				BEGIN
				   PRINT 2
					SET @Result=-6
					RETURN @Result -- USER SHOULD HAVE CHECKER RIGHTS 
				END
		END

		
		IF @AccessScopeAlt_Key in (3)
		BEGIN
		PRINT 'Sunil1'

		IF EXISTS(				                
					SELECT  1 FROM DimUserinfo WHERE UserLoginID=@BankRPAlt_Key AND ISNULL(AuthorisationStatus,'A')='A' and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey
					And IsChecker='Y'
				)	
				BEGIN
				   PRINT 2
					SET @Result=-8
					RETURN @Result -- USER SHOULD NOT HAVE CHECKER RIGHTS 
				END
		END
		*/
----------------------------------------
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

					 --SET @BankRPAlt_Key = (Select ISNULL(Max(BankRPAlt_Key),0)+1 from 
						--						(Select BankRPAlt_Key from DimBankRP
						--						 UNION 
						--						 Select BankRPAlt_Key from DimBankRP_Mod
						--						)A)

					 GOTO SMAMaster_Insert
					SMAMaster_Insert_Add:
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
					FROM DimSMA  
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND CustomerACID =@CustomerACID

				---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE
				IF ISNULL(@CreatedBy,'')=''
				BEGIN
					PRINT 'NOT AVAILABLE IN MAIN'
					SELECT  @CreatedBy		= CreatedBy
							,@DateCreated	= DateCreated 
					FROM DimSMA_Mod 
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND CustomerACID =@CustomerACID
							AND AuthorisationStatus IN('NP','MP','A','RM')
															
				END
				ELSE ---IF DATA IS AVAILABLE IN MAIN TABLE
					BEGIN
					       Print 'AVAILABLE IN MAIN'
						----UPDATE FLAG IN MAIN TABLES AS MP
						UPDATE DimSMA
							SET AuthorisationStatus=@AuthorisationStatus
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND CustomerACID =@CustomerACID

					END

					--UPDATE NP,MP  STATUS 
					IF @OperationFlag=2
					BEGIN	

						UPDATE DimSMA_Mod
							SET AuthorisationStatus='FM'
							,ModifiedBy=@Modifiedby
							,DateModified=@DateModified
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND CustomerACID =@CustomerACID
								AND AuthorisationStatus IN('NP','MP','RM')
					END

					GOTO SMAMaster_Insert
					SMAMaster_Insert_Edit_Delete:
				END

		ELSE IF @OperationFlag =3 AND @AuthMode ='N'
		BEGIN
		-- DELETE WITHOUT MAKER CHECKER
											
						SET @Modifiedby   = @CrModApBy 
						SET @DateModified = GETDATE() 

						UPDATE DimSMA SET
									ModifiedBy =@Modifiedby 
									,DateModified =@DateModified 
									,EffectiveToTimeKey =@EffectiveFromTimeKey-1
								WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) AND CustomerACID=@CustomerACID
				

		end
	-------------------------------------------------------
ELSE IF @OperationFlag=21 AND @AuthMode ='Y' 
		BEGIN
				SET @ApprovedBy	   = @CrModApBy 
				SET @DateApproved  = GETDATE()

				UPDATE DimSMA_Mod
					SET AuthorisationStatus='R'
					,ApprovedBy	 =@ApprovedBy
					,DateApproved=@DateApproved
					,EffectiveToTimeKey =@EffectiveFromTimeKey-1
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						AND CustomerACID =@CustomerACID
						AND AuthorisationStatus in('NP','MP','DP','RM','1A')	

		IF EXISTS(SELECT 1 FROM DimSMA WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) 
		                         AND CustomerACID =@CustomerACID)
				BEGIN
					UPDATE DimSMA
						SET AuthorisationStatus='A'
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND CustomerACID =@CustomerACID
							AND AuthorisationStatus IN('MP','DP','RM') 	
				END
		END	
-------------------------------------------------------

	
	ELSE IF @OperationFlag=17 AND @AuthMode ='Y' 
		BEGIN
				SET @ApprovedBy	   = @CrModApBy 
				SET @DateApproved  = GETDATE()

				UPDATE DimSMA_Mod
					SET AuthorisationStatus='R'
					,ApprovedBy	 =@ApprovedBy
					,DateApproved=@DateApproved
					,EffectiveToTimeKey =@EffectiveFromTimeKey-1
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						AND CustomerACID =@CustomerACID
						AND AuthorisationStatus in('NP','MP','DP','RM')	

---------------Added for Rejection Pop Up Screen  29/06/2020   ----------

		Print 'Sunil'

--		DECLARE @EntityKey as Int 
--		SELECT	@CreatedBy=CreatedBy,@DateCreated=DATECreated,@EntityKey=EntityKey
--							 FROM DimBankRP_Mod 
--								WHERE (EffectiveToTimeKey =@EffectiveFromTimeKey-1 )
--									AND BankRPAlt_Key=@BankRPAlt_Key And ISNULL(AuthorisationStatus,'A')='R'
		
--	EXEC [AxisIntReversalDB].[RejectedEntryDtlsInsert]  @Uniq_EntryID = @EntityKey, @OperationFlag = @OperationFlag ,@AuthMode = @AuthMode ,@RejectedBY = @CrModApBy
--,@RemarkBy = @CreatedBy,@DateCreated=@DateCreated ,@RejectRemark = @Remark ,@ScreenName = @ScreenName
		

--------------------------------

				IF EXISTS(SELECT 1 FROM DimSMA WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) AND CustomerACID=@CustomerACID)
				BEGIN
					UPDATE DimSMA
						SET AuthorisationStatus='A'
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND CustomerACID =@CustomerACID
							AND AuthorisationStatus IN('MP','DP','RM') 	
				END
		END	

	ELSE IF @OperationFlag=18
	BEGIN
		PRINT 18
		SET @ApprovedBy=@CrModApBy
		SET @DateApproved=GETDATE()
		UPDATE DimSMA_Mod
		SET AuthorisationStatus='RM'
		WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
		AND AuthorisationStatus IN('NP','MP','DP','RM')
		AND CustomerACID=@CustomerACID

	END
	--------------------------------------------------------------
	ELSE IF @OperationFlag=16

		BEGIN

		SET @ApprovedBy	   = @CrModApBy 
		SET @DateApproved  = GETDATE()

		UPDATE DimSMA_Mod
						SET AuthorisationStatus ='1A'
							,ApprovedBy=@ApprovedBy
							,DateApproved=@DateApproved
							WHERE CustomerACID=@CustomerACID
							AND AuthorisationStatus in('NP','MP','DP','RM')

		END
-----------------------------------------------------------------------------------------
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
					 FROM DimSMA 
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey >=@TimeKey )
							AND CustomerACID=@CustomerACID
					
					SET @ApprovedBy = @CrModApBy			
					SET @DateApproved=GETDATE()
					END
			END	
			
	---set parameters and UPDATE mod table in case maker checker enabled
			IF @AuthMode='Y'
				BEGIN
				    Print 'B'
					DECLARE @DelStatus CHAR(2)=''
					DECLARE @CurrRecordFromTimeKey smallint=0

					Print 'C'
					SELECT @ExEntityKey= MAX(EntityKey) FROM DimSMA_Mod 
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
							AND CustomerACID=@CustomerACID
							AND AuthorisationStatus IN('NP','MP','DP','RM','1A')	

					SELECT	@DelStatus=AuthorisationStatus,@CreatedBy=CreatedBy,@DateCreated=DATECreated
						,@ModifiedBy=ModifiedBy, @DateModified=DateModified
					 FROM DimSMA_Mod
						WHERE EntityKey=@ExEntityKey
					
					SET @ApprovedBy = @CrModApBy			
					SET @DateApproved=GETDATE()
				
					
					DECLARE @CurEntityKey INT=0

					SELECT @ExEntityKey= MIN(EntityKey) FROM DimSMA_Mod 
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
							AND CustomerACID=@CustomerACID
							AND AuthorisationStatus IN('NP','MP','DP','RM','1A')	
				
					SELECT	@CurrRecordFromTimeKey=EffectiveFromTimeKey 
						 FROM DimSMA_Mod
							WHERE EntityKey=@ExEntityKey

					UPDATE DimSMA_Mod
						SET  EffectiveToTimeKey =@CurrRecordFromTimeKey-1
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
						AND CustomerACID=@CustomerACID
						AND AuthorisationStatus='A'	



		-------DELETE RECORD AUTHORISE
					IF @DelStatus='DP' 
					BEGIN	
						UPDATE DimSMA_Mod
						SET AuthorisationStatus ='A'
							,ApprovedBy=@ApprovedBy
							,DateApproved=@DateApproved
							,EffectiveToTimeKey =@EffectiveFromTimeKey -1
						WHERE CustomerACID=@CustomerACID
							AND AuthorisationStatus in('NP','MP','DP','RM','1A')
						
						IF EXISTS(SELECT 1 FROM DimSMA WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
										AND CustomerACID=@CustomerACID)
						BEGIN
								UPDATE DimSMA
									SET AuthorisationStatus ='A'
										,ModifiedBy=@ModifiedBy
										,DateModified=@DateModified
										,ApprovedBy=@ApprovedBy
										,DateApproved=@DateApproved
										,EffectiveToTimeKey =@EffectiveFromTimeKey-1
									WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
											AND CustomerACID=@CustomerACID

								
						END
					END -- END OF DELETE BLOCK

					ELSE  -- OTHER THAN DELETE STATUS
					BEGIN
							UPDATE DimSMA_Mod
								SET AuthorisationStatus ='A'
									,ApprovedBy=@ApprovedBy
									,DateApproved=@DateApproved
								WHERE CustomerACID=@CustomerACID				
									AND AuthorisationStatus in('NP','MP','RM','1A')

									
					END		
				END



		IF @DelStatus <>'DP' OR @AuthMode ='N'
				BEGIN
						DECLARE @IsAvailable CHAR(1)='N'
						,@IsSCD2 CHAR(1)='N'
								SET @AuthorisationStatus='A' --changedby siddhant 5/7/2020

						IF EXISTS(SELECT 1 FROM DimSMA WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
									 AND CustomerACID=@CustomerACID)
							BEGIN
								SET @IsAvailable='Y'
								--SET @AuthorisationStatus='A'


								IF EXISTS(SELECT 1 FROM DimSMA WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND EffectiveFromTimeKey=@TimeKey AND CustomerACID=@CustomerACID)
									BEGIN
											PRINT 'BBBB'
										UPDATE DimSMA SET
												 SourceAlt_Key				= @SourceAlt_Key			
												,CustomerACID				= @CustomerACID			
												,CustomerId					= @CustomerId			
												,CustomerName				= @CustomerName			
												--,ParameterNameAlt_Key		= @ParameterNameAlt_Key	
												,ValueAlt_Key				= @ValueAlt_Key			
												,ModifiedBy					= @ModifiedBy
												,DateModified				= @DateModified
												,ApprovedBy					= CASE WHEN @AuthMode ='Y' THEN @ApprovedBy ELSE NULL END
												,DateApproved				= CASE WHEN @AuthMode ='Y' THEN @DateApproved ELSE NULL END
												,AuthorisationStatus		= CASE WHEN @AuthMode ='Y' THEN  'A' ELSE NULL END
												
											 WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND EffectiveFromTimeKey=@EffectiveFromTimeKey AND CustomerACID=@CustomerACID
									END	

									ELSE
										BEGIN
											SET @IsSCD2='Y'
										END
								END

								IF @IsAvailable='N' OR @IsSCD2='Y'
									BEGIN





										INSERT INTO DimSMA
												(
													 SourceAlt_Key			
													,CustomerACID			
													,CustomerId			
													,CustomerName			
													,ParameterNameAlt_Key	
													,ValueAlt_Key			
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
													--@SourceAlt_Key			
													--,@CustomerACID			
													--,@CustomerId			
													--,@CustomerName			
													----,@ParameterNameAlt_Key	
													--,@ValueAlt_Key			
													--,CASE WHEN @AUTHMODE= 'Y' THEN   @AuthorisationStatus ELSE NULL END
													--,@EffectiveFromTimeKey
													--,@EffectiveToTimeKey
													--,@CreatedBy 
													--,@DateCreated
													SourceAlt_Key			
													,CustomerACID			
													,CustomerId			
													,CustomerName			
													,ParameterNameAlt_Key	
													,ValueAlt_Key			
													,AuthorisationStatus
													,EffectiveFromTimeKey
													,EffectiveToTimeKey
													,CreatedBy 
													,DateCreated
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy  ELSE NULL END
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified  ELSE NULL END
													,CASE WHEN @AUTHMODE= 'Y' THEN    @ApprovedBy ELSE NULL END
													,CASE WHEN @AUTHMODE= 'Y' THEN    @DateApproved  ELSE NULL END
													From dimsma_mod
													WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND CustomerACID=@CustomerACID

	
---------------------------------------/*--------Adding Flag To AdvAcOtherDetail-------------------*/ 
--select * from DimSMA_Mod
--select *from IBPCPoolDetail_MOD

IF  Exists (Select 1 from dbo.AdvAcOtherDetail where EffectiveToTimeKey=49999 and RefSystemAcId=@CustomerACID and SplFlag not like '%SMA0%')

BEGIN
  UPDATE A
	SET  
        A.SplFlag=CASE WHEN ISNULL(A.SplFlag,'')='' THEN 'SMA0'     
						ELSE A.SplFlag+','+'SMA0'     END
		   
  FROM DBO.AdvAcOtherDetail A
   --INNER JOIN #Temp V  ON A.AccountEntityId=V.AccountEntityId
  INNER JOIN DimSMA_Mod B ON A.RefSystemAcId=B.CustomerACID
			WHERE  --B.UploadId=@UniqueUploadID and 
			B.EffectiveToTimeKey>=@Timekey
			AND A.EffectiveToTimeKey=49999
			AND B.EntityKey In (SELECT MAx(EntityKey) FROM DimSMA_Mod 
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
							AND CustomerACID=@CustomerACID
							AND AuthorisationStatus IN('NP','MP','A','1A')	
							)
END
-----------------------------------------------------------------------------------------------												
		
------------------REMOVE FLAG--------


IF  Exists (Select 1 from DimSMA where effectivetotimekey=49999 And CustomerACID=@CustomerACID
				and (Case when parameterNameAlt_key =1 and valuealt_key='1' then 1
						when parameterNameAlt_key =2 and valuealt_key='1' then 1
						when parameterNameAlt_key =3 and valuealt_key='2' then 1
						when parameterNameAlt_key =4 and valuealt_key='2' then 1
						when parameterNameAlt_key =5 and valuealt_key='2' then 1
						when parameterNameAlt_key =6 and valuealt_key='2' then 1
						when parameterNameAlt_key =7 and valuealt_key='2' then 1
						when parameterNameAlt_key =8 and valuealt_key='2' then 1
						when parameterNameAlt_key =9 and valuealt_key='2' then 1
						when parameterNameAlt_key =10 and valuealt_key='2' then 1
						when parameterNameAlt_key =11 and valuealt_key='2' then 1
						when parameterNameAlt_key =12 and valuealt_key='2' then 1
						when parameterNameAlt_key =13 and valuealt_key='2' then 1
						when parameterNameAlt_key =14 and valuealt_key='2' then 1
						
						End)=1
				)

BEGIN

				IF OBJECT_ID('TempDB..#Temp1') IS NOT NULL
				DROP TABLE #Temp1

				Select AccountentityID,SplFlag into #Temp1 from Curdat.AdvAcOtherDetail 
				where EffectiveToTimeKey=49999 AND RefSystemAcId=@CustomerACID AND splflag like '%SMA0%'


				--Select * from #Temp1


				IF OBJECT_ID('TEMPDB..#SplitValue')  IS NOT NULL
				DROP TABLE #SplitValue        
				SELECT AccountentityID,Split.a.value('.', 'VARCHAR(8000)') AS Businesscolvalues1  into #SplitValue
											FROM  (SELECT 
															CAST ('<M>' + REPLACE(SplFlag, ',', '</M><M>') + '</M>' AS XML) AS Businesscolvalues1,
															AccountentityID
															from #Temp1 
													) AS A CROSS APPLY Businesscolvalues1.nodes ('/M') AS Split(a)
						


				 --Select * from #SplitValue 

				 DELETE FROM #SplitValue WHERE Businesscolvalues1='SMA0'




				 IF OBJECT_ID('TEMPDB..#NEWTRANCHE')  IS NOT NULL
					DROP TABLE #NEWTRANCHE

					SELECT * INTO #NEWTRANCHE FROM(
					SELECT 
						 SS.AccountentityID,
						STUFF((SELECT ',' + US.BUSINESSCOLVALUES1 
							FROM #SPLITVALUE US
							WHERE US.AccountentityID = SS.AccountentityID
							FOR XML PATH('')), 1, 1, '') [REPORTIDSLIST]
						FROM #Temp1 SS 
						GROUP BY SS.AccountentityID
						)B
						ORDER BY 1

						--Select * from #NEWTRANCHE

					--SELECT * 
					UPDATE A SET A.SplFlag=B.REPORTIDSLIST
					FROM DBO.AdvAcOtherDetail A
					INNER JOIN #NEWTRANCHE B ON A.AccountentityID=B.AccountentityID
					WHERE  A.EFFECTIVEFROMTIMEKEY<=@TimeKey AND A.EFFECTIVETOTIMEKEY>=@TimeKey

END											
										
									END


									IF @IsSCD2='Y' 
								BEGIN
								UPDATE DimSMA SET
										EffectiveToTimeKey=@EffectiveFromTimeKey-1
										,AuthorisationStatus =CASE WHEN @AUTHMODE='Y' THEN  'A' ELSE NULL END
									WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) AND CustomerACID=@CustomerACID
											AND EffectiveFromTimekey<@EffectiveFromTimeKey
								END
							END

		IF @AUTHMODE='N'
			BEGIN
					SET @AuthorisationStatus='A'
					GOTO SMAMaster_Insert
					HistoryRecordInUp:
			END						



		END 

PRINT 6
SET @ErrorHandle=1

SMAMaster_Insert:
IF @ErrorHandle=0
	BEGIN

-----------------------------------------------------------
	IF Object_id('Tempdb..#Temp') Is Not Null
Drop Table #Temp

	IF Object_id('Tempdb..#final') Is Not Null
Drop Table #final

Create table #Temp
(CustomerId VARCHAR(30)
,ValueAlt_Key VARCHAR(100)
,CustomerName	VARCHAR(200)
)

Insert into #Temp values(@CustomerId,@ValueAlt_Key,@CustomerName)

Select A.Businesscolvalues1 as ValueAlt_Key,CustomerId,CustomerName into #final From (
SELECT CustomerId,CustomerName,Split.a.value('.', 'VARCHAR(8000)') AS Businesscolvalues1  
                            FROM  (SELECT 
                                            CAST ('<M>' + REPLACE(ValueAlt_Key, ',', '</M><M>') + '</M>' AS XML) AS Businesscolvalues1,
											CustomerId,CustomerName
											from #Temp
                                    ) AS A CROSS APPLY Businesscolvalues1.nodes ('/M') AS Split(a)
						
)A 
--select * from #temp

ALTER TABLE #FINAL ADD ParameterNameAlt_Key INT Identity(1,1)

--IF @OperationFlag=1 
--BEGIN

--UPDATE TEMP 
--SET TEMP.CustomerACID=ACCT.CustomerACID
-- FROM #final TEMP
--INNER JOIN (SELECT ValueAlt_Key,(@CustomerACID + ROW_NUMBER()OVER(ORDER BY (SELECT 1))) CustomerACID
--			FROM #final
--			WHERE  CustomerACID IS NULL)ACCT ON TEMP.ValueAlt_Key=ACCT.ValueAlt_Key
--END

--IF @OperationFlag=2 

--BEGIN

--UPDATE TEMP 
--SET TEMP.CustomerACID=@CustomerACID
-- FROM #final TEMP

--END



	--------------------------------------------------


			INSERT INTO DimSMA_Mod  
											( 
												 SourceAlt_Key			
												,CustomerACID			
												,CustomerId			
												,CustomerName			
												,ParameterNameAlt_Key	
												,ValueAlt_Key			
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
											 
													@SourceAlt_Key			
													,@CustomerACID			
													,CustomerId			
													,CustomerName			
													,ParameterNameAlt_Key	
													,ValueAlt_Key			
													,@AuthorisationStatus
													,@EffectiveFromTimeKey
													,@EffectiveToTimeKey 
													,@CreatedBy
													,@DateCreated
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy ELSE NULL END
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified ELSE NULL END
													,CASE WHEN @AuthMode='Y' THEN @ApprovedBy    ELSE NULL END
													,CASE WHEN @AuthMode='Y' THEN @DateApproved  ELSE NULL END

										from #final	
										
												
											
								--VALUES
								--			( 
								--					@SourceAlt_Key			
								--					,@CustomerACID			
								--					,@CustomerId			
								--					,@CustomerName			
								--					,@ParameterNameAlt_Key	
								--					,@ValueAlt_Key			
								--					,@AuthorisationStatus
								--					,@EffectiveFromTimeKey
								--					,@EffectiveToTimeKey 
								--					,@CreatedBy
								--					,@DateCreated
								--					,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy ELSE NULL END
								--					,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified ELSE NULL END
								--					,CASE WHEN @AuthMode='Y' THEN @ApprovedBy    ELSE NULL END
								--					,CASE WHEN @AuthMode='Y' THEN @DateApproved  ELSE NULL END
													
								--			)
	
	

		         IF @OperationFlag =1 AND @AUTHMODE='Y'
					BEGIN
						PRINT 3
						GOTO SMAMaster_Insert_Add
					END
				ELSE IF (@OperationFlag =2 OR @OperationFlag =3)AND @AUTHMODE='Y'
					BEGIN
						GOTO SMAMaster_Insert_Edit_Delete
					END
					

				
	END
-------------------------------------Attendance Log----------------------------	
	IF @OperationFlag IN (1,2,3,16,17,18,20,21) AND @AuthMode ='Y'
		BEGIN
					print 'log table'

		          declare @DateCreated1 datetime
				SET	@DateCreated1     =Getdate()

				--declare @ReferenceID1 varchar(max)
				--set @ReferenceID1 = (case when @OperationFlag in (16,20,21) then @SourceAlt_Key else @SourceAlt_Key end)


					IF @OperationFlag IN(16,17,18,20,21) 
						BEGIN 
						       Print 'Authorised'
					
			
								EXEC LogDetailsInsertUpdate_Attendence -- MAINTAIN LOG TABLE
							    @BranchCode=''   ,  ----BranchCode
								@MenuID=@MenuID,
								@ReferenceID=@CustomerACID ,-- ReferenceID ,
								@CreatedBy=NULL,
								@ApprovedBy=@CrModApBy, 
								@CreatedCheckedDt=@DateCreated1,
								@Remark=NULL,
								@ScreenEntityAlt_Key=16  ,---ScreenEntityId -- for FXT060 screen
								@Flag=@OperationFlag,
								@AuthMode=@AuthMode
						END
					ELSE
						BEGIN
						       Print 'UNAuthorised'
						    -- Declare
						    -- set @CreatedBy  =@UserLoginID
							 
							EXEC LogDetailsInsertUpdate_Attendence -- MAINTAIN LOG TABLE
								@BranchCode=''   ,  ----BranchCode
								@MenuID=@MenuID,
								@ReferenceID=@CustomerACID ,-- ReferenceID ,
								@CreatedBy=@CrModApBy,
								@ApprovedBy=NULL, 						
								@CreatedCheckedDt=@DateCreated1,
								@Remark=NULL,
								@ScreenEntityAlt_Key=16  ,---ScreenEntityId -- for FXT060 screen
								@Flag=@OperationFlag,
								@AuthMode=@AuthMode
						END

		END
---------------------------------------------------------------------------------------



	-------------------
PRINT 7
		COMMIT TRANSACTION

		--SELECT @D2Ktimestamp=CAST(D2Ktimestamp AS INT) FROM DimBankRP WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) 
		--															AND BankRPAlt_Key=@BankRPAlt_Key

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