SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROC [dbo].[UserParametersInsertUpdate]



--Declare
						 @CreatedBy AS varchar(20)=NULL
						,@CreatedDate as Varchar(10)        = null
						,@NONUSE AS INT=0
						,@PWDCHNG AS INT=0
						,@PWDLEN AS INT=0
						,@PWDNUM AS INT=0
						,@PWDREUSE AS INT=0
						,@UNLOGON AS INT=0
						,@USERIDALP AS INT=0
						,@USERIDLEN AS INT=0
						,@USERIDLENMAX AS INT=0
						,@PWDLENMAX AS INT=0
						,@PWDALPHAMIN AS INT=0
						,@USERSHOMAX AS INT=0
						,@USERSROMAX AS INT=0
						,@USERSBOMAX AS INT=0
						
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
						@AuthorisationStatus		varchar(5)			= NULL 
						--,@CreatedBy					VARCHAR(20)		= NULL
						,@DateCreated				SMALLDATETIME	= NULL
						,@ModifyBy				VARCHAR(20)		= NULL
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

				SET @ScreenName = 'GLProductCodeMaster'

	-------------------------------------------------------------
	--SET @CreatedDate=NULL
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

Declare @CurrentLoginDate Date--- added by shailesh naik on 10/06/2014
--SET @AuthMode=CASE WHEN @AuthMode in('S','H','A') THEN 'Y' else 'N' END
Select @CurrentLoginDate= CurrentLoginDate from DimUserInfo where (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey >=@TimeKey) AND UserLoginID=@CreatedBy
				


					--IF Object_id('Tempdb..#Temp') Is Not Null
					--Drop Table #Temp

					--IF Object_id('Tempdb..#final') Is Not Null
					--Drop Table #final

					--Create table #Temp
					--(ProductCode Varchar(20)
					--,SourceAlt_Key Varchar(20)
					--,ProductDescription Varchar(500)
					--)

	
					--Insert into #Temp values(@ProductCode,@SourceAlt_Key,@ProductDescription)

					--Select A.Businesscolvalues1 as SourceAlt_Key,ProductCode,ProductDescription  into #final From (
					--SELECT ProductCode,ProductDescription,Split.a.value('.', 'VARCHAR(8000)') AS Businesscolvalues1  
					--							FROM  (SELECT 
					--											CAST ('<M>' + REPLACE(SourceAlt_Key, ',', '</M><M>') + '</M>' AS XML) AS Businesscolvalues1,
					--											ProductCode,ProductDescription
					--											from #Temp
					--									) AS A CROSS APPLY Businesscolvalues1.nodes ('/M') AS Split(a)
						
					--)A 

					--ALTER TABLE #FINAL ADD UserLoginID INT

	----IF @OperationFlag=1  --- add
	----BEGIN
	----PRINT 1
	----	-----CHECK DUPLICATE
	----	IF EXISTS(				                
	----				SELECT  1 FROM DimUserParameters WHERE  ShortNameEnum IN('NONUSE','UNLOGON')
	----				--AND SourceAlt_Key in(Select * from Split(@SourceAlt_Key,','))
	----				AND ISNULL(AuthorisationStatus,'A')='A' and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey
	----				UNION
	----				SELECT  1 FROM DimUserParameters_Mod  WHERE (EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey)
	----														AND  ShortNameEnum IN('NONUSE','UNLOGON')
	----														--AND SourceAlt_Key in(Select * from Split(@SourceAlt_Key,','))
	----														AND   ISNULL(AuthorisationStatus,'A') in('NP','MP','DP','RM') 
	----			)	
	----			BEGIN
	----			   PRINT 2
	----				SET @Result=-4
	----				RETURN @Result -- USER ALEADY EXISTS
	----			END
	----	ELSE
	----		BEGIN
	----		   PRINT 3

	----				 SET @UserLoginID = (Select ISNULL(Max(UserLoginID),0)+1 from 
	----											(Select UserLoginID from DimUserParameters
	----											 UNION 
	----											 Select UserLoginID from DimUserParameters_Mod
	----											)A)





	----		END
	
	----END
	

	IF @OperationFlag=2 
	BEGIN

	PRINT 1

		--UPDATE TEMP 
		--SET TEMP.ShortNameEnum IN('NONUSE','UNLOGON')
		--	FROM #final TEMP

	END
	--select * from #final
	--select * from TEMP
	
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

					 ----SET @UserLoginID = (Select ISNULL(Max(UserLoginID),0)+1 from 
						----						(Select UserLoginID from DimUserParameters
						----						 UNION 
						----						 Select UserLoginID from DimUserParameters_Mod
						----						)A)

					 GOTO GLCodeMaster_Insert
					GLCodeMaster_Insert_Add:
			END


			ELSE IF(@OperationFlag = 2 OR @OperationFlag = 3) AND @AuthMode = 'Y' --EDIT AND DELETE
			BEGIN
				Print 4
				SET @CreatedBy= @CrModApBy
				SET @DateCreated = GETDATE()
				Set @ModifyBy=@CrModApBy   
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
					SELECT Top 1 @CreatedBy		= CreatedBy
							,@DateCreated	= DateCreated 
					FROM DimUserParameters  
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND ShortNameEnum IN('NONUSE','UNLOGON')

				---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE
				IF ISNULL(@CreatedBy,'')=''
				BEGIN
					PRINT 'NOT AVAILABLE IN MAIN'
					SELECT Top 1  @CreatedBy		= CreatedBy
							,@DateCreated	= DateCreated 
					FROM DimUserParameters_Mod 
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND  ShortNameEnum IN('NONUSE','UNLOGON')
							AND AuthorisationStatus IN('NP','MP','A','RM')
															
				END
				ELSE ---IF DATA IS AVAILABLE IN MAIN TABLE
					BEGIN
					       Print 'AVAILABLE IN MAIN'
						----UPDATE FLAG IN MAIN TABLES AS MP
						UPDATE DimUserParameters
							SET AuthorisationStatus=@AuthorisationStatus
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND  ShortNameEnum IN('NONUSE','UNLOGON')

					END

					--UPDATE NP,MP  STATUS 
					IF @OperationFlag=2
					BEGIN	

						UPDATE DimUserParameters_Mod
							SET AuthorisationStatus='FM'
							,ModifyBy=@ModifyBy
							,DateModified=@DateModified
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND  ShortNameEnum IN('NONUSE','UNLOGON')
								AND AuthorisationStatus IN('NP','MP','RM')
					END

					GOTO GLCodeMaster_Insert
					GLCodeMaster_Insert_Edit_Delete:
				END

		ELSE IF @OperationFlag =3 AND @AuthMode ='N'
		BEGIN
		-- DELETE WITHOUT MAKER CHECKER
											
						SET @ModifyBy   = @CrModApBy 
						SET @DateModified = GETDATE() 

						UPDATE DimUserParameters SET
									ModifyBy =@ModifyBy 
									,DateModified =@DateModified 
									,EffectiveToTimeKey =@EffectiveFromTimeKey-1
								WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) AND ShortNameEnum IN('NONUSE','UNLOGON')
				

		end

		----------------------------------NEW ADD FIRST LVL AUTH------------------
		ELSE IF @OperationFlag=21 AND @AuthMode ='Y' 
		BEGIN
				SET @ApprovedBy	   = @CrModApBy 
				SET @DateApproved  = GETDATE()

				UPDATE DimUserParameters_Mod
					SET AuthorisationStatus='R'
					,ApprovedBy	 =@ApprovedBy
					,DateApproved=@DateApproved
					,EffectiveToTimeKey =@EffectiveFromTimeKey-1
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						AND   ShortNameEnum IN('NONUSE','UNLOGON')
						AND AuthorisationStatus in('NP','MP','DP','RM','1A')	

		
				IF EXISTS(SELECT 1 FROM DimUserParameters WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) AND ShortNameEnum IN('NONUSE','UNLOGON'))
				BEGIN
					UPDATE DimUserParameters
						SET AuthorisationStatus='A'
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND   ShortNameEnum IN('NONUSE','UNLOGON')
							AND AuthorisationStatus IN('MP','DP','RM') 	
				END
		END	


		-------------------------------------------------------------------------
	
	
	ELSE IF @OperationFlag=17 AND @AuthMode ='Y' 
		BEGIN
				SET @ApprovedBy	   = @CrModApBy 
				SET @DateApproved  = GETDATE()

				UPDATE DimUserParameters_Mod
					SET AuthorisationStatus='R'
					,ApprovedByFirstLevel=@ApprovedBy
					,DateApprovedFirstLevel=@DateApproved
					,EffectiveToTimeKey =@EffectiveFromTimeKey-1
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND   ShortNameEnum IN('NONUSE','UNLOGON')
						AND AuthorisationStatus in('NP','MP','DP','RM')	

---------------Added for Rejection Pop Up Screen  29/06/2020   ----------

		Print 'Sunil'

--		DECLARE @EntityKey as Int 
		--SELECT	@CreatedBy=CreatedBy,@DateCreated=DATECreated,@EntityKey=EntityKey
		--					 FROM DimGL_Mod 
		--						WHERE (EffectiveToTimeKey =@EffectiveFromTimeKey-1 )
		--							AND GLAlt_Key=@GLAlt_Key And ISNULL(AuthorisationStatus,'A')='R'
		
--	EXEC [AxisIntReversalDB].[RejectedEntryDtlsInsert]  @Uniq_EntryID = @EntityKey, @OperationFlag = @OperationFlag ,@AuthMode = @AuthMode ,@RejectedBY = @CrModApBy
--,@RemarkBy = @CreatedBy,@DateCreated=@DateCreated ,@RejectRemark = @Remark ,@ScreenName = @ScreenName
		

--------------------------------

				IF EXISTS(SELECT 1 FROM DimUserParameters WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) AND ShortNameEnum IN('NONUSE','UNLOGON'))
				BEGIN
					UPDATE DimUserParameters
						SET AuthorisationStatus='A'
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND   ShortNameEnum IN('NONUSE','UNLOGON')
							AND AuthorisationStatus IN('MP','DP','RM') 	
				END
		END	

	ELSE IF @OperationFlag=18
	BEGIN
		PRINT 18
		SET @ApprovedBy=@CrModApBy
		SET @DateApproved=GETDATE()
		UPDATE DimUserParameters_Mod
		SET AuthorisationStatus='RM'
		WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
		AND AuthorisationStatus IN('NP','MP','DP','RM')
		AND ShortNameEnum IN('NONUSE','UNLOGON')

	END

	--------NEW ADD------------------
	--ELSE IF @OperationFlag=16

	--	BEGIN

	--	SET @ApprovedBy	   = @CrModApBy 
	--	SET @DateApproved  = GETDATE()

	--	UPDATE DimUserParameters_Mod
	--					SET AuthorisationStatus ='1A'
	--						,ApprovedBy=@ApprovedBy
	--						,DateApproved=@DateApproved
	--						WHERE ShortNameEnum IN('NONUSE','UNLOGON')
	--						AND AuthorisationStatus in('NP','MP','DP','RM')

	--	END

	------------------------------
	--------NEW ADD------------------
	ELSE IF @OperationFlag=16

		BEGIN
		

		PRINT 'Sachin16'

		SET @ApprovedBy	   = @CrModApBy 
		SET @DateApproved  = GETDATE()

		UPDATE DimUserParameters_mod
						SET AuthorisationStatus ='1A'
							,ApprovedByFirstLevel=@ApprovedBy
							,DateApprovedFirstLevel=@DateApproved
							WHERE
							 AuthorisationStatus in('NP','MP','DP','RM')
							 
							 

							--WHERE UserLoginID=@CreatedBy
							--AND AuthorisationStatus in('NP','MP','DP','RM')

		END

	------------------------------
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
						SET @ModifyBy  =@CrModApBy
						SET @DateModified =GETDATE()
						SELECT	@CreatedBy=CreatedBy,@DateCreated=DATECreated
					 FROM DimUserParameters 
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey >=@TimeKey )
							AND ShortNameEnum IN('NONUSE','UNLOGON')
					
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
					SELECT @ExEntityKey= MAX(EntityKey) FROM DimUserParameters_Mod 
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
							AND ShortNameEnum IN('NONUSE','UNLOGON')
							AND AuthorisationStatus IN('NP','MP','DP','RM','1A')	

					SELECT	@DelStatus=AuthorisationStatus,@CreatedBy=CreatedBy,@DateCreated=DATECreated
						,@ModifyBy=ModifyBy, @DateModified=DateModified
					 FROM DimUserParameters_Mod
						WHERE EntityKey=@ExEntityKey
					
					SET @ApprovedBy = @CrModApBy			
					SET @DateApproved=GETDATE()
				
					
					DECLARE @CurEntityKey INT=0

					SELECT @ExEntityKey= MIN(EntityKey) FROM DimUserParameters_Mod 
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
							AND ShortNameEnum IN('NONUSE','UNLOGON')
							AND AuthorisationStatus IN('NP','MP','DP','RM','1A')	
				
					SELECT	@CurrRecordFromTimeKey=EffectiveFromTimeKey 
						 FROM DimUserParameters_Mod
							WHERE EntityKey=@ExEntityKey

					UPDATE DimUserParameters_Mod
						SET  EffectiveToTimeKey =@CurrRecordFromTimeKey-1
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
						AND ShortNameEnum IN('NONUSE','UNLOGON')
						AND AuthorisationStatus='A'	

		-------DELETE RECORD AUTHORISE
					IF @DelStatus='DP' 
					BEGIN	
						UPDATE DimUserParameters_Mod
						SET AuthorisationStatus ='A'
							,ApprovedBy=@ApprovedBy
							,DateApproved=@DateApproved
							,EffectiveToTimeKey =@EffectiveFromTimeKey -1
						WHERE ShortNameEnum IN('NONUSE','UNLOGON')
							AND AuthorisationStatus in('NP','MP','DP','RM','1A')
						
						IF EXISTS(SELECT 1 FROM DimUserParameters WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
										AND ShortNameEnum IN('NONUSE','UNLOGON'))
						BEGIN
								UPDATE DimUserParameters
									SET AuthorisationStatus ='A'
										,ModifyBy=@ModifyBy
										,DateModified=@DateModified
										,ApprovedBy=@ApprovedBy
										,DateApproved=@DateApproved
										,EffectiveToTimeKey =@EffectiveFromTimeKey-1
									WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
											AND ShortNameEnum IN('NONUSE','UNLOGON')

								
						END
					END -- END OF DELETE BLOCK

					ELSE  -- OTHER THAN DELETE STATUS
					BEGIN
							UPDATE DimUserParameters_Mod
								SET AuthorisationStatus ='1A'
									,ApprovedBy=@ApprovedBy
									,DateApproved=@DateApproved
								WHERE ShortNameEnum IN('NONUSE','UNLOGON')				
									AND AuthorisationStatus in('NP','MP','RM','1A')

			

									
					END		
				END



		IF @DelStatus <>'DP' OR @AuthMode ='N'
				BEGIN
						DECLARE @IsAvailable CHAR(1)='N'
						,@IsSCD2 CHAR(1)='N'
								SET @AuthorisationStatus='A' --changedby siddhant 5/7/2020

								-----------------------------new addby anuj /Jayadev 26052021 ----
								-- SET @UserLoginID = (Select ISNULL(Max(UserLoginID),0)+1 from 
								--				(Select UserLoginID from DimUserParameters
								--				 UNION 
								--				 Select UserLoginID from DimUserParameters_Mod
								--				)A)

								----------------------------------------------


						IF EXISTS(SELECT 1 FROM DimUserParameters WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
									 AND ShortNameEnum IN('NONUSE','UNLOGON'))
							BEGIN
								SET @IsAvailable='Y'
								--SET @AuthorisationStatus='A'


								IF EXISTS(SELECT Distinct 1 FROM DimUserParameters WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND ShortNameEnum IN('NONUSE','UNLOGON'))

												--AND EffectiveFromTimeKey=@EffectiveFromTimeKey 
									BEGIN
											PRINT 'BBBB'
										UPDATE A SET
												
													A.ShortNameEnum=B.ShortNameEnum,
								                    A.ParameterType=B.ParameterType,
								                   A.ParameterValue= b.ParameterValue,
								
								                      A.MinValue=B.MinValue,
								                    A.MaxValue= B.MaxValue,
												ApprovedBy				= CASE WHEN @AuthMode ='Y' THEN @ApprovedBy ELSE NULL END,
												DateApproved			= CASE WHEN @AuthMode ='Y' THEN @DateApproved ELSE NULL END,
												AuthorisationStatus	= CASE WHEN @AuthMode ='Y' THEN  'A' ELSE NULL END
												
												From DimUserParameters A
												INNER JOIN DimUserParameters_Mod B ON A.SeqNo=B.SeqNo
											 WHERE (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey) 
												AND B.ShortNameEnum IN('NONUSE','UNLOGON')
												  AND B.EntityKey IN
											 (
												 SELECT MAX(EntityKey)
												 FROM DimUserParameters_Mod
												 WHERE EffectiveFromTimeKey <= @TimeKey
													   AND EffectiveToTimeKey >= @TimeKey
				
													   AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')
												 GROUP BY ShortNameEnum
											 )

								UPDATE DimUserParameters_Mod
								SET AuthorisationStatus ='A'
									,ApprovedBy=@ApprovedBy
									,DateApproved=@DateApproved
								WHERE ShortNameEnum IN('NONUSE','UNLOGON')				
									AND AuthorisationStatus in('NP','MP','RM','1A')

									END	

									ELSE
										BEGIN
											SET @IsSCD2='Y'
										END
								END
								--select @IsAvailable,@IsSCD2

								IF @IsAvailable='N' OR @IsSCD2='Y'
									BEGIN

									--Alter TAble DimUserParameters
									--ADD Remark Varchar(max) Null
									
			INSERT INTO DimUserParameters         
					(
						ShortNameEnum,
								ParameterType,
								ParameterValue,
								SeqNo,
								MinValue,
								MaxValue,
								AuthorisationStatus,
								
								EffectiveFromTimeKey,
								EffectiveToTimeKey,
								DateCreated,
								CreatedBy,
								ModifyBy,
								DateModified
								--Remark
						)        
				SELECT		
						ShortNameEnum,
								ParameterType,
								ParameterValue,
								SeqNo,
								MinValue,
								MaxValue,
								AuthorisationStatus,
							
								EffectiveFromTimeKey,
								EffectiveToTimeKey,

								CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifyBy ELSE NULL END,
								CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified ELSE NULL END,
								CASE WHEN @AuthMode='Y' THEN @ApprovedBy    ELSE NULL END,
								CASE WHEN @AuthMode='Y' THEN @DateApproved  ELSE NULL  END
								--Remark
					
					FROM DimUserParameters_mod 
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND ShortNameEnum IN('NONUSE','UNLOGON')

					UPDATE DimUserParameters
						SET EffectiveToTimeKey=@EffectiveFromTimeKey -1
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						AND EffectiveFromTimeKey<@EffectiveFromTimeKey 
						AND ShortNameEnum IN('NONUSE','UNLOGON')

													
										
												
										
									END


									IF @IsSCD2='Y' 
								BEGIN
								UPDATE DimUserParameters SET
										EffectiveToTimeKey=@EffectiveFromTimeKey-1
										,AuthorisationStatus =CASE WHEN @AUTHMODE='Y' THEN  'A' ELSE NULL END
									WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) AND ShortNameEnum IN('NONUSE','UNLOGON')
											AND EffectiveFromTimekey<@EffectiveFromTimeKey
								END
							END

		IF @AUTHMODE='N'
			BEGIN
					SET @AuthorisationStatus='A'
					GOTO GLCodeMaster_Insert
					HistoryRecordInUp:
			END						



		END 

PRINT 6
SET @ErrorHandle=1

GLCodeMaster_Insert:
IF @ErrorHandle=0
	BEGIN

IF OBJECT_ID('Tempdb..##temp1') IS NOT NULL
						DROP TABLE ##temp1
						create table ##temp1 

						(
							NONUSE	 		 INT	
							,PWDCHNG			 INT  
							,PWDLEN			 INT	
							,PWDNUM			  INT	
							,PWDREUSE		 INT	
							,UNLOGON			 INT	
							,USERIDALP		 INT	
							,USERIDLEN		 INT	
							,USERIDLENMAX	 INT  
							,PWDLENMAX		 INT	
							,PWDALPHAMIN		 INT	
							,USERSHOMAX		 INT	
							,USERSROMAX		 INT	
							,USERSBOMAX		 INT	
						
						
						)
			

INSERT	
INTO 
##temp1
(
NONUSE	 	
,PWDCHNG		
,PWDLEN		
,PWDNUM		
,PWDREUSE	
,UNLOGON		
,USERIDALP	
,USERIDLEN	
,USERIDLENMAX
,PWDLENMAX	
,PWDALPHAMIN	
,USERSHOMAX	
,USERSROMAX	
,USERSBOMAX	

)

(	select
 @NONUSE	 	
,@PWDCHNG		
,@PWDLEN		
,@PWDNUM		
,@PWDREUSE		
,@UNLOGON		
,@USERIDALP		
,@USERIDLEN		
,@USERIDLENMAX	
,@PWDLENMAX		
,@PWDALPHAMIN		
,@USERSHOMAX	
,@USERSROMAX	
,@USERSBOMAX	
) 

 IF OBJECT_ID('Tempdb..##temp2') IS NOT NULL
						DROP TABLE ##temp2
select *	INTO ##temp2
 FROM (
SELECT * FROM (
  SELECT * FROM ##temp1) T
  UNPIVOT ( ParameterValue FOR ParameterName IN (NONUSE,PWDCHNG,PWDLEN,PWDNUM,PWDREUSE,UNLOGON,USERIDALP,USERIDLEN,USERIDLENMAX,PWDLENMAX,PWDALPHAMIN,
  USERSHOMAX,USERSROMAX,USERSBOMAX))P)A


  --PRINT 
  SET DATEFORMAT DMY

 PRINT '@CreatedDate'
 PRINT @CreatedDate


							  INSERT INTO DimUserParameters_mod 
							   (
    
								ShortNameEnum,
								ParameterType,
								ParameterValue,
								SeqNo,
								MinValue,
								MaxValue,
								AuthorisationStatus,
								DateCreated,
								CreatedBy,
								EffectiveFromTimeKey,
								EffectiveToTimeKey,
								ModifyBy,
								DateModified,
								Remark


								 )
	
									SELECT 
       
									ShortNameEnum
									,ParameterType
									,B.ParameterValue
									,SeqNo
									,MinValue
									,MaxValue
									,@AuthorisationStatus
									,Convert(datetime,@CreatedDate) DateCreated
								,@CreatedBy
								
								,@EffectiveFromTimeKey
		                         ,@EffectiveToTimeKey	
								,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifyBy ELSE NULL END
								,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified ELSE NULL END
								,@Remark
								

								from DimUserParameters A

		LEFT JOIN ##temp2 B
		ON B.ParameterName=A.ShortNameEnum
		where   A.EffectiveFromTimeKey<= @TimeKey AND A.EffectiveToTimeKey>= @TimeKey
		AND 	 ShortNameEnum IN('NONUSE','UNLOGON')
												
													
												 
						
	
													
										
	
	

		         IF @OperationFlag =1 AND @AUTHMODE='Y'
					BEGIN
						PRINT 3
						GOTO GLCodeMaster_Insert_Add
					END
				ELSE IF (@OperationFlag =2 OR @OperationFlag =3)AND @AUTHMODE='Y'
					BEGIN
						GOTO GLCodeMaster_Insert_Edit_Delete
					END
					

				
	END



		



	-------------------
PRINT 7
		COMMIT TRANSACTION

		--SELECT @D2Ktimestamp=CAST(D2Ktimestamp AS INT) FROM DimGL WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) 
		--															AND GLAlt_Key=@GLAlt_Key

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