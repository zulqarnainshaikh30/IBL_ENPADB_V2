SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO




--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE [dbo].[FraudInUP]



--exec [dbo].[FraudInUP] N'','','809000283277','1','0009','','1406','','','2079428','','10','10','1','11/22/2021','Y','11/22/2021','Indian Overseas Bank','11/22/2021','11/22/2021','11/22/2021','aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa','aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa','','','','','1,2,3,4'



--SELECT * FROm Fraud
--SELECT * FROm dbo.Fraud_Mod
--Declare	
						
						 @Entitykey						bigint  =0
						 ,@AccountEntityId				Varchar(20)			= ''
						,@CustomerEntityID				Varchar(30)				= ''
						,@RefCustomerACID				Varchar (30)	= ''						
						,@RefCustomerID					Varchar (30)	= ''						
						,@RFA_ReportingByBank			VarChar(5)    --------int = 0
						,@RFA_DateReportingByBank		VARCHAR(20)			= NULL
						,@RFA_OtherBankAltKey			int = 0
						,@RFA_OtherBankDate				VARCHAR(20)			= NULL
						,@FraudOccuranceDate			VARCHAR(20)			= NULL
						,@FraudDeclarationDate			VARCHAR(20)			= NULL
						,@FraudNature					VARCHAR(500)		= ''
						,@FraudArea						VARCHAR(500)		= ''
						,@CurrentAssetClassAltKey		int		= 0
						,@ProvPref						int					= 0								
						,@FraudAccounts_ChangeFields	Varchar (10)		=''
						,@CurrentNPA_Date					Varchar (20)		= NULL						
						,@ReasonforRFAClassification         Varchar(255) =''
						,@DateofRemovalofRFAClassification   VARCHAR(20)			= NULL
						,@ReasonforRemovalofRFAClassification Varchar(255)=''
						,@DateofRemovalofRFAClassificationReporting  VARCHAR(20) = NULL
						,@RFAReportedOtherBank      Varchar(2)=NULL
						,@NameofBank				Varchar(500)=NULL
						,@AssetClassAlt_KeyBeforeFruad   Int=0
						,@NPADateBeforeFraud   Varchar(20)=Null
						---------D2k System Common Columns		---------------------------------
						,@Remark					VARCHAR(500)	= ''
						--,@MenuID					SMALLINT		= 0  change to Int
						,@MenuID                    Int=0
						,@OperationFlag				TINYINT			= 0
						,@AuthMode					CHAR(1)			= 'N'
						,@Authlevel					VARCHAR(3)		= ''
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
			SET DATEFORMAT DMY	
	--		Select @RFA_DateReportingByBank

 --   set @RFA_DateReportingByBank =case when ( @RFA_DateReportingByBank='' or @RFA_DateReportingByBank<='01/01/1999' or @RFA_DateReportingByBank<='1999/01/01') then NULL ELSE @RFA_DateReportingByBank END 
	--set @RFA_OtherBankDate =case when ( @RFA_OtherBankDate='' or @RFA_OtherBankDate<='01/01/1999' or @RFA_OtherBankDate<='1999/01/01') then NULL 
	--ELSE @RFA_OtherBankDate END 
	--set @FraudOccuranceDate =case when ( @FraudOccuranceDate='' or @FraudOccuranceDate<='01/01/1999' or @FraudOccuranceDate<='1999/01/01') then NULL 
	--ELSE @FraudOccuranceDate END
	--set @FraudDeclarationDate =case when ( @FraudDeclarationDate='' or @FraudDeclarationDate<='01/01/1999' or @FraudDeclarationDate<='1999/01/01') then NULL 
	--ELSE @FraudDeclarationDate END
	--set @DateofRemovalofRFAClassification =case when ( @DateofRemovalofRFAClassification='' or @DateofRemovalofRFAClassification<='01/01/1999' or @DateofRemovalofRFAClassification<='1999/01/01') then NULL 
	--ELSE @DateofRemovalofRFAClassification END
	--set @DateofRemovalofRFAClassificationReporting =case when ( @DateofRemovalofRFAClassificationReporting='' or @DateofRemovalofRFAClassificationReporting<='01/01/1999' or @DateofRemovalofRFAClassificationReporting<='1999/01/01') then NULL 
	--ELSE @DateofRemovalofRFAClassificationReporting END

	--Select @RFA_DateReportingByBank
	
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
						,@ApprovedByFirstLevel		VARCHAR(20)		= NULL
						,@DateApprovedFirstLevel	SMALLDATETIME	= NULL
						
						-----------Added for Rejection Screen  29/06/2020   ----------

		DECLARE			@Uniq_EntryID			int	= 0
						,@RejectedBY			Varchar(50)	= NULL
						,@RemarkBy				Varchar(50)	= NULL
						,@RejectRemark			Varchar(200) = NULL
						,@ScreenName			Varchar(200) = NULL
						,@MOC_Initialized_Date  VARCHAR(20)=NULL
				SET @ScreenName = 'Fraud'


	-------------------------------------------------------------
	
 SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C') 

 SET @EffectiveFromTimeKey  = @TimeKey

	SET @EffectiveToTimeKey = 49999

	set  @AccountEntityID = (	CASE WHEN (select 1 from dbo.advacbasicdetail where CustomerACID=@RefCustomerACID
	                           AND  EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey) = 1
							   THEN
								(select AccountEntityID from dbo.advacbasicdetail where CustomerACID=@RefCustomerACID
	                           AND  EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey)
							   WHEN ( select 1 from dbo.AdvNFAcBasicDetail where CustomerACID=@RefCustomerACID
	                           AND  EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey) = 1
							   THEN
								(select AccountEntityID from dbo.AdvNFAcBasicDetail where CustomerACID=@RefCustomerACID
	                           AND  EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey)
							   WHEN (select 1 from dbo.InvestmentBasicDetail where InvID=@RefCustomerACID
	                           AND  EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey) = 1 
							   THEN (select InvEntityID from dbo.InvestmentBasicDetail where InvID=@RefCustomerACID
	                           AND  EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey) 
							   WHEN (select 1 from curdat.DerivativeDetail where DerivativeRefNo=@RefCustomerACID
	                           AND  EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey) = 1
							   THEN (select DerivativeEntityID from curdat.DerivativeDetail where DerivativeRefNo=@RefCustomerACID
	                           AND  EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey)
							   ELSE 0 END							   
							  )
	
	set  @CustomerEntityID = (CASE WHEN (select 1 from dbo.advacbasicdetail where CustomerACID=@RefCustomerACID
	                           AND  EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey) = 1
							   THEN
								(select CustomerEntityId from dbo.advacbasicdetail where CustomerACID=@RefCustomerACID
	                           AND  EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey)
							   WHEN ( select 1 from dbo.AdvNFAcBasicDetail where CustomerACID=@RefCustomerACID
	                           AND  EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey ) = 1
							   THEN
								(select CustomerEntityId from dbo.AdvNFAcBasicDetail where CustomerACID=@RefCustomerACID
	                           AND  EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey)
							   WHEN (select 1 from dbo.InvestmentBasicDetail where InvID=@RefCustomerACID
	                           AND  EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey) = 1 
							   THEN (select IssuerEntityId from dbo.InvestmentBasicDetail where InvID=@RefCustomerACID
	                           AND  EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey) 
							   WHEN (select 1 from curdat.DerivativeDetail where DerivativeRefNo=@RefCustomerACID
	                           AND  EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey) = 1
							   THEN (select CustomerEntityId from dbo.advacbasicdetail where CustomerACID=@RefCustomerACID
	                           AND  EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey)
							   ELSE 0 END)

	set  @RefCustomerid = (CASE WHEN (select 1 from dbo.advacbasicdetail where CustomerACID=@RefCustomerACID
	                           AND  EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey) = 1
							   THEN
								(select RefCustomerId from dbo.advacbasicdetail where CustomerACID=@RefCustomerACID
	                           AND  EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey)
							   WHEN ( select 1 from dbo.AdvNFAcBasicDetail where CustomerACID=@RefCustomerACID
	                           AND  EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey ) = 1
							   THEN
								(select RefCustomerId from dbo.AdvNFAcBasicDetail where CustomerACID=@RefCustomerACID
	                           AND  EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey)
							   WHEN (select 1 from dbo.InvestmentBasicDetail where InvID=@RefCustomerACID
	                           AND  EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey) = 1 
							   THEN (select RefIssuerID from dbo.InvestmentBasicDetail where InvID=@RefCustomerACID
	                           AND  EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey) 
							   WHEN (select 1 from curdat.DerivativeDetail where DerivativeRefNo=@RefCustomerACID
	                           AND  EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey) = 1
							   THEN (select CustomerID from curdat.DerivativeDetail where DerivativeRefNo=@RefCustomerACID
	                           AND  EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey)
							   ELSE 0 END)

Declare @AssetClassatFraudAltKey int
Declare @NPADtatFraud date

IF (select count(distinct AssetClassAtFraudAltKey) 
			from Fraud_Details_Mod where AccountEntityId=@AccountEntityID
	        AND  EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey
			And ISNULL(AuthorisationStatus,'A') in ('NP','MP','1A','A')
			) > 0 
			BEGIN
	
	set  @AssetClassatFraudAltKey = (	select DISTINCT AssetClassAtFraudAltKey from Fraud_Details_Mod where AccountEntityId=@AccountEntityID
										AND  EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey And ISNULL(AuthorisationStatus,'A') in ('NP','MP','1A','A')
									)

	
	set  @NPADtatFraud =		(		select DISTINCT NPA_DateAtFraud from Fraud_Details_Mod where AccountEntityId=@AccountEntityID
	                           AND  EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey And ISNULL(AuthorisationStatus,'A') in ('NP','MP','1A','A')
								)
								END
								ELSE
								BEGIN
								set  @AssetClassatFraudAltKey = (	
								(CASE WHEN (select	1 from	dbo.AdvCustNPADetail where	CustomerEntityId=@CustomerEntityID
									 AND EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey) = 1 
									 THEN (select Cust_AssetClassAlt_Key from	dbo.AdvCustNPADetail where	CustomerEntityId=@CustomerEntityID
									 AND EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey)
									WHEN (select 1 from dbo.InvestmentBasicDetail where IssuerEntityID =@CustomerEntityID
									AND  EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey) = 1 
									THEN (select FinalAssetClassAlt_Key from dbo.InvestmentFinancialDetail where RefInvID =@RefCustomerACID
									AND  EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey) 
									WHEN (select 1 from curdat.DerivativeDetail where DerivativeRefNo=@RefCustomerACID
									AND  EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey) = 1
									THEN (select FinalAssetClassAlt_Key from curdat.DerivativeDetail where CustomerACID=@RefCustomerACID
									AND  EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey)
									ELSE 0 END)
																)
	
								set  @NPADtatFraud =		(		
																	(CASE WHEN (select	1 from	dbo.AdvCustNPADetail where	CustomerEntityId=@CustomerEntityID
									 AND EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey) = 1 
									 THEN (select Npadt from	dbo.AdvCustNPADetail where	CustomerEntityId=@CustomerEntityID
									 AND EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey)
									WHEN (select 1 from dbo.InvestmentBasicDetail where IssuerEntityID =@CustomerEntityID
									AND  EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey) = 1 
									THEN (select NPIDt from dbo.InvestmentFinancialDetail where RefInvID =@RefCustomerACID
									AND  EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey) 
									WHEN (select 1 from curdat.DerivativeDetail where DerivativeRefNo=@RefCustomerACID
									AND  EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey) = 1
									THEN (select NPIDt from curdat.DerivativeDetail where CustomerACID=@RefCustomerACID
									AND  EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey)
									ELSE '' END)
															)
								END
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
					SELECT  1 FROM dbo.Fraud_Details WHERE RefCustomerACID=@RefCustomerACID AND ISNULL(AuthorisationStatus,'A')='A' 
					and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey
					UNION
					SELECT  1 FROM dbo.Fraud_Details_Mod  WHERE (EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey)
															 AND RefCustomerACID=@RefCustomerACID
															AND   ISNULL(AuthorisationStatus,'A') in('NP','MP','DP','RM','1A') 
				)	

				BEGIN
				   PRINT 2
					SET @Result=-4
					RETURN @Result -- USER ALEADY EXISTS
				END
		ELSE
		        
					BEGIN 
						--SELECT @AccountEntityID= NEXT VALUE FOR Seq_AccountEntityID
						--PRINT @AccountEntityID
						 SET @AccountEntityId = (Select ISNULL(Max(AccountEntityId),0)+1 from 
												(Select AccountEntityId from dbo.Fraud_Details
												 UNION 
												 Select AccountEntityId from dbo.Fraud_Details_Mod
												)A)

					END

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

					 --SET @AccountEntityID = (Select ISNULL(Max(AccountEntityID),0)+1 from 
						--						(Select AccountEntityID from dbo.Fraud_Details
						--						 UNION 
						--						 Select AccountEntityID from dbo.Fraud_Details_Mod
						--						)A)

					 GOTO Fraud_Details_Insert
					Fraud_Details_Insert_Add:
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
							,@AccountEntityID = AccountEntityID
					FROM dbo.Fraud_Details  
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND AccountEntityID =@AccountEntityID

				---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE
				IF ISNULL(@CreatedBy,'')=''
				BEGIN
					PRINT 'NOT AVAILABLE IN MAIN'
					SELECT  @CreatedBy		= CreatedBy
							,@DateCreated	= DateCreated 
					FROM dbo.Fraud_Details_Mod 
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND AccountEntityID =@AccountEntityID
							AND AuthorisationStatus IN('NP','MP','A','RM')
															
				END
				ELSE ---IF DATA IS AVAILABLE IN MAIN TABLE
					BEGIN
					       Print 'AVAILABLE IN MAIN'
						----UPDATE FLAG IN MAIN TABLES AS MP
						UPDATE dbo.Fraud_Details
							SET AuthorisationStatus=@AuthorisationStatus
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND AccountEntityID =@AccountEntityID

					END

					--UPDATE NP,MP  STATUS 
					IF @OperationFlag=2
					BEGIN	

						UPDATE dbo.Fraud_Details_Mod
							SET AuthorisationStatus='FM'
							,ModifiedBy=@Modifiedby
							,DateModified=@DateModified
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND AccountEntityID =@AccountEntityID
								AND AuthorisationStatus IN('NP','MP','RM')
					END

					GOTO Fraud_Details_Insert
					Fraud_Details_Insert_Edit_Delete:
				END

		ELSE IF @OperationFlag =3 AND @AuthMode ='N'
		BEGIN
		-- DELETE WITHOUT MAKER CHECKER
											
						SET @Modifiedby   = @CrModApBy 
						SET @DateModified = GETDATE() 

						UPDATE dbo.Fraud_Details SET
									ModifiedBy =@Modifiedby 
									,DateModified =@DateModified 
									,EffectiveToTimeKey =@EffectiveFromTimeKey-1
								WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey)
								 AND AccountEntityID=@AccountEntityID
				

		end


-------------------------------------------------------
--start 20042021
ELSE IF @OperationFlag=21 AND @AuthMode ='Y' 
		BEGIN
				SET @ApprovedBy	   = @CrModApBy 
				SET @DateApproved  = GETDATE()

				UPDATE dbo.Fraud_Details_Mod
					SET AuthorisationStatus='R'
					,ApprovedBy	 =@ApprovedBy
					,DateApproved=@DateApproved
					,EffectiveToTimeKey =@EffectiveFromTimeKey-1
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						AND RefCustomerACID =@RefCustomerACID
						AND AuthorisationStatus in('NP','MP','DP','RM','1A')	

		IF EXISTS(SELECT 1 FROM dbo.Fraud_Details WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) AND AccountEntityID=@AccountEntityID)
				BEGIN
					UPDATE dbo.Fraud_Details
						SET AuthorisationStatus='A'
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND RefCustomerACID =@RefCustomerACID
							AND AuthorisationStatus IN('MP','DP','RM') 	
				END
		END	


--till here
-------------------------------------------------------

	
	
	ELSE IF @OperationFlag=17 AND @AuthMode ='Y' 
		BEGIN
				SET @ApprovedBy	   = @CrModApBy 
				SET @DateApproved  = GETDATE()

				UPDATE dbo.Fraud_Details_Mod
					SET AuthorisationStatus='R'
					,FirstLevelApprovedBy	 =@ApprovedBy
					,FirstLevelDateApproved=@DateApproved
					,EffectiveToTimeKey =@EffectiveFromTimeKey-1
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						AND RefCustomerACID =@RefCustomerACID
						AND AuthorisationStatus in('NP','MP','DP','RM')	


--------------------------------

				IF EXISTS(SELECT 1 FROM dbo.Fraud_Details WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) AND AccountEntityID=@AccountEntityID)
				BEGIN
					UPDATE dbo.Fraud_Details
						SET AuthorisationStatus='A'
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND RefCustomerACID =@RefCustomerACID
							AND AuthorisationStatus IN('MP','DP','RM') 	
				END
		END	

	ELSE IF @OperationFlag=18
	BEGIN
		PRINT 18
		SET @ApprovedBy=@CrModApBy
		SET @DateApproved=GETDATE()
		UPDATE dbo.Fraud_Details_Mod
		SET AuthorisationStatus='RM'
		WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
		AND AuthorisationStatus IN('NP','MP','DP','RM')
		AND RefCustomerACID=@RefCustomerACID

	END

	ELSE IF @OperationFlag=16

		BEGIN

		SET @ApprovedBy	   = @CrModApBy 
		SET @DateApproved  = GETDATE()

		UPDATE dbo.Fraud_Details_Mod
						SET AuthorisationStatus ='1A'
							,FirstLevelApprovedBy=@ApprovedBy
							,FirstLevelDateApproved=@DateApproved
							WHERE RefCustomerACID=@RefCustomerACID
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
					 FROM dbo.Fraud_Details 
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey >=@TimeKey )
							AND RefCustomerACID=@RefCustomerACID
					
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
					SELECT @ExEntityKey= MAX(EntityKey) FROM dbo.Fraud_Details_Mod 
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
							AND RefCustomerACID=@RefCustomerACID
							AND AuthorisationStatus IN('NP','MP','DP','RM','1A')	

					SELECT	@DelStatus=AuthorisationStatus,@CreatedBy=CreatedBy,@DateCreated=DATECreated
						,@ModifiedBy=ModifiedBy, @DateModified=DateModified
						,@ApprovedByFirstLevel=FirstLevelApprovedBy,@DateApprovedFirstLevel=FirstLevelDateApproved
					 FROM dbo.Fraud_Details_Mod
						WHERE EntityKey=@ExEntityKey
					
					SET @ApprovedBy = @CrModApBy			
					SET @DateApproved=GETDATE()
				
					
					DECLARE @CurEntityKey INT=0

					SELECT @ExEntityKey= MIN(EntityKey) FROM dbo.Fraud_Details_Mod 
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
							AND RefCustomerACID=@RefCustomerACID
							AND AuthorisationStatus IN('NP','MP','DP','RM','1A')	
				
					SELECT	@CurrRecordFromTimeKey=EffectiveFromTimeKey 
						 FROM dbo.Fraud_Details_Mod
							WHERE EntityKey=@ExEntityKey

					UPDATE dbo.Fraud_Details_Mod
						SET  EffectiveToTimeKey =@CurrRecordFromTimeKey-1
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
						AND RefCustomerACID=@RefCustomerACID
						AND AuthorisationStatus='A'	
						----alter table dbo.Fraud_Details
						----alter column BranchCode varchar(30)
						----exec sp_refreshview 'InvestmentIssuerDetail'
		-------DELETE RECORD AUTHORISE
					IF @DelStatus='DP' 
					BEGIN	
						UPDATE dbo.Fraud_Details_Mod
						SET AuthorisationStatus ='A'
							,ApprovedBy=@ApprovedBy
							,DateApproved=@DateApproved
							,EffectiveToTimeKey =@EffectiveFromTimeKey -1
						WHERE RefCustomerACID=@RefCustomerACID
							AND AuthorisationStatus in('NP','MP','DP','RM','1A')
						
						IF EXISTS(SELECT 1 FROM dbo.Fraud_Details WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
										AND AccountEntityID=@AccountEntityID)
						BEGIN
								UPDATE dbo.Fraud_Details
									SET AuthorisationStatus ='A'
										,ModifiedBy=@ModifiedBy
										,DateModified=@DateModified
										,ApprovedBy=@ApprovedBy
										,DateApproved=@DateApproved
										,EffectiveToTimeKey =@EffectiveFromTimeKey-1
									WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
											AND RefCustomerACID=@RefCustomerACID

								
						END
					END -- END OF DELETE BLOCK

					ELSE  -- OTHER THAN DELETE STATUS
					BEGIN
							UPDATE dbo.Fraud_Details_Mod
								SET AuthorisationStatus ='A'
									,ApprovedBy=@ApprovedBy
									,DateApproved=@DateApproved
								WHERE RefCustomerACID=@RefCustomerACID				
									AND AuthorisationStatus in('NP','MP','RM','1A')

			

									
					END		
				END

		IF @DelStatus <>'DP' OR @AuthMode ='N'
				BEGIN
						
						DECLARE @IsAvailable CHAR(1)='N'
						,@IsSCD2 CHAR(1)='N'
								SET @AuthorisationStatus='A' --changedby siddhant 5/7/2020

						IF EXISTS(SELECT 1 FROM dbo.Fraud_Details WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
									 AND RefCustomerACID=@RefCustomerACID)
							BEGIN
								SET @IsAvailable='Y'
								--SET @AuthorisationStatus='A'


								IF EXISTS(SELECT 1 FROM dbo.Fraud_Details WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND EffectiveFromTimeKey=@TimeKey AND AccountEntityID=@AccountEntityID)
									BEGIN
											PRINT 'BBBB'
										UPDATE dbo.Fraud_Details 
										SET
												AccountEntityId				=	@AccountEntityId
												,CustomerEntityId			=	@CustomerEntityID
												,RefCustomerACID			=   @RefCustomerACID
												,RefCustomerID				=	@RefCustomerID												
												,RFA_ReportingByBank		=	@RFA_ReportingByBank
												,RFA_DateReportingByBank	=	@RFA_DateReportingByBank
												,RFA_OtherBankAltKey		=	@RFA_OtherBankAltKey
												,RFA_OtherBankDate			=	@RFA_OtherBankDate
												,FraudOccuranceDate			=	@FraudOccuranceDate
												,FraudDeclarationDate		=	@FraudDeclarationDate
												,FraudNature				=	@FraudNature
												,FraudArea					=	@FraudArea
												--,AssetClassAtFraud			=	@AssetClassatFraud
												--,NPA_DateAtFraud			=	@NPADtatFraud
												,AssetClassAlt_KeyBeforeFruad=@AssetClassAlt_KeyBeforeFruad
												,NPADateBeforeFraud			= Case when Isnull(@NPADateBeforeFraud,'')='' then Null Else Convert(Date,@NPADateBeforeFraud,105) End
												,CurrentAssetClassAltKey	=	@CurrentAssetClassAltKey
												,ProvPref					=	@ProvPref
												,ModifiedBy					=	@ModifiedBy
												,DateModified				=	@DateModified
												,ApprovedBy					=	CASE WHEN @AuthMode ='Y' THEN @ApprovedBy ELSE NULL END
												,DateApproved				=	CASE WHEN @AuthMode ='Y' THEN @DateApproved ELSE NULL END
												,AuthorisationStatus		=	CASE WHEN @AuthMode ='Y' THEN  'A' ELSE NULL END
												,FirstLevelApprovedBy			=@ApprovedByFirstLevel
												,FirstLevelDateApproved			=@DateApprovedFirstLevel
												,screenFlag						='S'
											    ,ReasonforRFAClassification      =@ReasonforRFAClassification      
												,DateofRemovalofRFAClassification  =@DateofRemovalofRFAClassification 
												,ReasonforRemovalofRFAClassification =@ReasonforRemovalofRFAClassification
												,DateofRemovalofRFAClassificationReporting=@DateofRemovalofRFAClassificationReporting
												,RFAReportedOtherBank=@RFAReportedOtherBank
												,NameofBank=@NameofBank
											 WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND EffectiveFromTimeKey=@EffectiveFromTimeKey AND RefCustomerACID=@RefCustomerACID
									END	

									ELSE
										BEGIN
											SET @IsSCD2='Y'
										END
								END

								IF @IsAvailable='N' OR @IsSCD2='Y'
									BEGIN
										INSERT INTO dbo.Fraud_Details
												(	
												AccountEntityId
												,CustomerEntityId												
												,RefCustomerACID
												,RefCustomerID
												,RFA_ReportingByBank
												,RFA_DateReportingByBank
												,RFA_OtherBankAltKey
												,RFA_OtherBankDate
												,FraudOccuranceDate
												,FraudDeclarationDate
												,FraudNature
												,FraudArea
												,AssetClassAtFraudAltKey
												,NPA_DateAtFraud
												,CurrentAssetClassAltKey
												,ProvPref
												,AuthorisationStatus
												,EffectiveFromTimeKey
												,EffectiveToTimeKey
												,CreatedBy
												,DateCreated
												,ModifiedBy
												,DateModified
												,ApprovedBy
												,DateApproved
												,FirstLevelApprovedBy
													,FirstLevelDateApproved													
													,screenFlag
													,ReasonforRFAClassification        
													,DateofRemovalofRFAClassification   
													,ReasonforRemovalofRFAClassification 
													,DateofRemovalofRFAClassificationReporting
													,RFAReportedOtherBank
													,NameofBank
													,AssetClassAlt_KeyBeforeFruad
													,NPADateBeforeFraud
												)

										SELECT		
												@AccountEntityId
												,@CustomerEntityId												
												,@RefCustomerACID
												,@RefCustomerID
												,@RFA_ReportingByBank
												--,case when @RFA_ReportingByBank='10' then 'N' Else 'Y' End
												,Case when ISNULL(@RFA_DateReportingByBank,'')='' then NULL Else Convert(Date,@RFA_DateReportingByBank,105) ENd
												--,@RFA_OtherBankAltKey
												,@RFA_OtherBankAltKey
												,Case when ISNULL(@RFA_OtherBankDate,'')='' then NULL Else Convert(Date,@RFA_OtherBankDate,105) End
												,Case when ISNULL(@FraudOccuranceDate,'')='' then NULL Else Convert(Date,@FraudOccuranceDate,105) End
												,Case when ISNULL(@FraudDeclarationDate,'')='' then NULL Else Convert(Date,@FraudDeclarationDate,105) End
												,@FraudNature
												,@FraudArea
												,@AssetClassAtFraudAltKey
												,Case when ISNULL(@CurrentNPA_Date,'')='' then NULL Else Convert(Date,@CurrentNPA_Date,105) End
												,@CurrentAssetClassAltKey
												,@ProvPref														
													,CASE WHEN @AUTHMODE= 'Y' THEN   @AuthorisationStatus ELSE NULL END
													,@EffectiveFromTimeKey
													,@EffectiveToTimeKey
													,@CreatedBy 
													,@DateCreated
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy  ELSE NULL END
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified  ELSE NULL END
													,CASE WHEN @AUTHMODE= 'Y' THEN    @ApprovedBy ELSE NULL END
													,CASE WHEN @AUTHMODE= 'Y' THEN    @DateApproved  ELSE NULL END
													,@ApprovedByFirstLevel
													,@DateApprovedFirstLevel
									                ,'S'
													,@ReasonforRFAClassification        
													,Case when ISNULL(@DateofRemovalofRFAClassification,'')='' then NULL Else Convert(Date,@DateofRemovalofRFAClassification,105) End
													,@ReasonforRemovalofRFAClassification 
													,Case when ISNULL(@DateofRemovalofRFAClassificationReporting,'')='' then NULL Else Convert(Date,@DateofRemovalofRFAClassificationReporting,105) ENd
													,@RFAReportedOtherBank
													,@NameofBank
													,@AssetClassAlt_KeyBeforeFruad
													,Case when Isnull(@NPADateBeforeFraud,'')='' then Null Else Convert(Date,@NPADateBeforeFraud,105) ENd





										
									END


									IF @IsSCD2='Y' 
								BEGIN
								UPDATE dbo.Fraud_Details SET
										EffectiveToTimeKey=@EffectiveFromTimeKey-1
										,AuthorisationStatus =CASE WHEN @AUTHMODE='Y' THEN  'A' ELSE NULL END
									WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) AND RefCustomerACID=@RefCustomerACID
											AND EffectiveFromTimekey<@EffectiveFromTimeKey
								END
							END

		IF @AUTHMODE='N'
			BEGIN
					SET @AuthorisationStatus='A'
					GOTO Fraud_Details_Insert
					HistoryRecordInUp:
			END						



		END 

PRINT 6
SET @ErrorHandle=1

Fraud_Details_Insert:
IF @ErrorHandle=0
	BEGIN

	--Select @RFA_DateReportingByBank

			INSERT INTO dbo.Fraud_Details_Mod  
											(	AccountEntityId
												,CustomerEntityId												
												,RefCustomerACID
												,RefCustomerID
												,RFA_ReportingByBank
												,RFA_DateReportingByBank
												,RFA_OtherBankAltKey
												,RFA_OtherBankDate
												,FraudOccuranceDate
												,FraudDeclarationDate
												,FraudNature
												,FraudArea
												,AssetClassAtFraudAltKey
												,NPA_DateAtFraud
												,CurrentAssetClassAltKey
												,ProvPref
												,AuthorisationStatus
												,EffectiveFromTimeKey
												,EffectiveToTimeKey
												,CreatedBy
												,DateCreated
												,ModifiedBy
												,DateModified
												,ApprovedBy
												,DateApproved
												,FirstLevelApprovedBy
												,FirstLevelDateApproved
												,FraudAccounts_ChangeFields
												,screenFlag		
												,ReasonforRFAClassification        
												,DateofRemovalofRFAClassification   
												,ReasonforRemovalofRFAClassification 
												,DateofRemovalofRFAClassificationReporting
												,RFAReportedOtherBank
												,NameofBank
												,AssetClassAlt_KeyBeforeFruad
												,NPADateBeforeFraud
											)
								VALUES
											(	@AccountEntityId
												,@CustomerEntityId												
												,@RefCustomerACID
												,@RefCustomerID
												,@RFA_ReportingByBank
												--,case when @RFA_ReportingByBank='10' THEN 'N' ELSE 'Y' END
												,Case when ISNULL(@RFA_DateReportingByBank,'')='' then NULL Else Convert(Date,@RFA_DateReportingByBank,105) End
												--,@RFA_OtherBankAltKey
												,@RFA_OtherBankAltKey
												,Case when ISNULL(@RFA_OtherBankDate,'')='' then NULL Else Convert(Date,@RFA_OtherBankDate,105) End
												,Case when ISNULL(@FraudOccuranceDate,'')='' then NULL Else Convert(Date,@FraudOccuranceDate,105) End
												,Case when ISNULL(@FraudDeclarationDate,'')='' then NULL Else Convert(Date,@FraudDeclarationDate,105) End
												,@FraudNature
												,@FraudArea
												,@AssetClassatFraudAltKey
												,Case when ISNULL(@CurrentNPA_Date,'')='' then NULL Else Convert(Date,@CurrentNPA_Date,105) ENd
												,@CurrentAssetClassAltKey
												,@ProvPref	
													,@AuthorisationStatus
													,@EffectiveFromTimeKey
													,@EffectiveToTimeKey 
													,@CreatedBy
													,@DateCreated
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy ELSE NULL END
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified ELSE NULL END
													,CASE WHEN @AuthMode='Y' THEN @ApprovedBy    ELSE NULL END
													,CASE WHEN @AuthMode='Y' THEN @DateApproved  ELSE NULL END
													,@ApprovedByFirstLevel
													,@DateApprovedFirstLevel
													,@FraudAccounts_ChangeFields
									                ,'S'
													,@ReasonforRFAClassification        
													,Case when ISNULL(@DateofRemovalofRFAClassification,'')='' then NULL Else Convert(Date,@DateofRemovalofRFAClassification,105) End
													,@ReasonforRemovalofRFAClassification 
													,Case when ISNULL(@DateofRemovalofRFAClassificationReporting,'')='' then NULL ELSE Convert(Date,@DateofRemovalofRFAClassificationReporting,105) END
													,@RFAReportedOtherBank
													,@NameofBank
													,@AssetClassAlt_KeyBeforeFruad
													,Case when Isnull(@NPADateBeforeFraud,'')='' then Null Else Convert(Date,@NPADateBeforeFraud,105) End
											)
	
		DECLARE @Parameter1 varchar(50)
	DECLARE @FinalParameter1 varchar(50)
	SET @Parameter1 = (select STUFF((	SELECT Distinct ',' +FraudAccounts_ChangeFields
											from Fraud_Details_Mod where  RefCustomerAcid=@RefCustomerACID
											and ISNULL(AuthorisationStatus,'A')  in ( 'A','MP')
											 for XML PATH('')),1,1,'') )

											If OBJECT_ID('#AA') is not null
											drop table #AA

select DISTINCT VALUE 
into #AA
from (
		SELECT 	CHARINDEX('|',VALUE) CHRIDX,VALUE
		FROM( SELECT VALUE FROM STRING_SPLIT(@Parameter1,',')
 ) A
 )X
 SET @FinalParameter1 = (select STUFF((	SELECT Distinct ',' + Value from #AA  for XML PATH('')),1,1,''))
 
							UPDATE		A
							set			a.FraudAccounts_ChangeFields = @FinalParameter1							 																																	
							from		Fraud_Details_Mod   A
							WHERE		(EffectiveFromTimeKey<=@tiMEKEY AND EffectiveToTimeKey>=@tiMEKEY) 
							and			 RefCustomerAcid=@RefCustomerACID	



	
	        IF @OperationFlag =1 AND @AUTHMODE='Y'
					BEGIN
						PRINT 3
						GOTO Fraud_Details_Insert_Add
					END
				ELSE IF (@OperationFlag =2 OR @OperationFlag =3)AND @AUTHMODE='Y'
					BEGIN
						GOTO Fraud_Details_Insert_Edit_Delete
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
								@ReferenceID=@RefCustomerACID ,-- ReferenceID ,
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
								@ReferenceID=@RefCustomerACID ,-- ReferenceID ,
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

--END
GO