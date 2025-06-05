SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--DECLARE
CREATE PROC [dbo].[InvestMentMainInsert]

						 @Entitykey						bigint  =0
						 ,@Remark						VARCHAR(500)	 =''
						,@MenuID						INT		 =0
						,@OperationFlag					TINYINT			 =0
						,@AuthMode						CHAR(1)			 ='N'
						,@IsMOC							CHAR(1)			 ='N'
						,@EffectiveFromTimeKey			INT				 =0
						,@EffectiveToTimeKey			INT				 =0
						,@TimeKey						INT				 =0
						,@CrModApBy						VARCHAR(20)		 ='d2k'
						,@D2Ktimestamp					INT				 =0   OUTPUT
						,@Result						INT				 =0   OUTPUT
						,@InvEntityId	int   =0
						,@InvID	Varchar (100)				= ''
						,@HoldingNature		char(3)				= '0'
						,@CurrencyAlt_Key	TINYINT				= 0
						,@CurrencyConvRate  decimal	(18,2)		=0.0
						,@BookType			varchar(25)			=''
						,@BookValue			decimal	(18,2)		=0.0
						,@BookValueINR		decimal	(18,2)		=0.0
						,@MTMValue			decimal	(18,2)		=0.0
						,@MTMValueINR		decimal	(18,2)		=0.0
						,@EncumberedMTM		decimal	(18,2)		=0.0
						,@AssetClass_AltKey	TINYINT				= 0
						,@NPIDt				VARCHAR(20)			= NULL
						,@DBTDate			VARCHAR(20)			= NULL
						,@LatestBSDate			VARCHAR(20)			= NULL
						,@Interest_DividendDueDate			VARCHAR(20)			= NULL
						,@Interest_DividendDueAmount		DECImAL(18,2) = 0.0
						,@PartialRedumptionDueDate			VARCHAR(20)			= NULL
						,@PartialRedumptionSettledY_N		char(1)  ='N'
						,@IssuerEntityID			int					= 0
						,@SourceAlt_key				int					= ''
						,@BranchCode				Varchar (100)		= ''
						,@UcifId					Varchar(16)			= ''
						,@IssuerID					Varchar(100)		= ''
						,@IssuerName				VarChar (100)		= ''
						,@Ref_Txn_Sys_Cust_ID		Varchar (16)		= ''
						,@PanNo						Varchar (10)		= ''
						,@Issuer_Category_Code		Char (3)			='N'
						,@GrpEntityOfBank			Char (1)			='N'						
						,@ISIN	varchar (100)				= ''
						,@InstrTypeAlt_key	TINYINT			= 0
						,@InstrName	Varchar (100)			= ''
						,@InvestmentNature	varchar (25)	= ''
						,@Sector	varchar (25)			= ''
						,@Industry_Altkey	TINYINT			= 0
						,@ExposureType	varchar (25)		= ''
						,@SecurityValue	decimal	(18,2)		=0.0
						,@MaturityDt	VARCHAR(20)			= NULL
						,@ReStructureDate	VARCHAR(20)			= NULL


---------ADD Changefields Column------Commented 26/05/2021
						,@Basic_ChangeFields						VARCHAR(250)=''			
						,@Financial_ChangeFields					VARCHAR(250)=''		
						,@Issuer_ChangeFields						VARCHAR(250)=''			


 		 -----------D2k System Common Columns			
			 ,@InvestmentBasicDetailsInUp							CHAR(1)='N'
			 ,@InvestmentFinancialDetailInUp 						CHAR(1)='N'
			 ,@InvestmentIssuerDetailINUP  							CHAR(1)='N'
			


 AS

 BEGIN

    SET NOCOUNT ON
    SET XACT_ABORT ON

 BEGIN TRY

--********************************************************************************

/*  update and set date paramter here */
IF @NPIDt=''
		BEGIN
			SET @NPIDt=NULL
		END	
IF @DBTDate=''
		BEGIN
			SET @DBTDate=NULL
			END	
IF @LatestBSDate=''
		BEGIN
			SET @LatestBSDate=NULL
			END	
IF @Interest_DividendDueDate=''
		BEGIN
			SET @Interest_DividendDueDate=NULL
			END	
IF @PartialRedumptionDueDate=''
		BEGIN
			SET @PartialRedumptionDueDate=NULL
		END	
		
IF @MaturityDt=''
		BEGIN
			SET @MaturityDt=NULL
		END	
IF @ReStructureDate=''
		BEGIN
			SET @ReStructureDate=NULL
		END	


-------------------
 BEGIN TRAN

   IF @InvestmentIssuerDetailINUP='Y'
			BEGIN			
           PRINT 1
           EXEC [dbo].[InvestmentIssuerDetailInUP]

						 @Entitykey					
						,@IssuerEntityID			
						,@SourceAlt_key				
						,@BranchCode				
						,@UcifId					
						,@IssuerID					
						,@IssuerName				
						,@Ref_Txn_Sys_Cust_ID		
						,@PanNo						
						,@Issuer_Category_Code		
						,@GrpEntityOfBank			                
					    ,@Remark					       
					    ,@MenuID					       
					    ,@OperationFlag				       
					    ,@AuthMode					       
					    ,@IsMOC						       
					    ,@EffectiveFromTimeKey		       
					    ,@EffectiveToTimeKey		       
					    ,@TimeKey					       
					    ,@CrModApBy					       
					    ,@D2Ktimestamp	 	       
					    ,@Result		      OUTPUT			       
		  END
				         
	IF @OperationFlag=1
		BEGIN

			SET @IssuerEntityId=@Result	
			select '1'	      

		END
	

	IF @OperationFlag<>1
		BEGIN
				SET @RESULT=@IssuerEntityId
		END			

		
  
   
   
     IF @InvestmentBasicDetailsInUp='Y'
			BEGIN			
           PRINT 2
		 EXEC   [InvestmentBasicDetailInUP]

		 				 @Entitykey					
						,@InvEntityId	
						,@IssuerEntityId	
						,@InvID	
						,@ISIN	
						,@InstrTypeAlt_key	
						,@InstrName	
						,@InvestmentNature	
						,@Sector	
						,@Industry_Altkey	
						,@ExposureType	
						,@SecurityValue	
						,@MaturityDt	
						,@ReStructureDate	 
						,@Remark					       
					    ,@MenuID					       
					    ,@OperationFlag				       
					    ,@AuthMode					       
					    ,@IsMOC						       
					    ,@EffectiveFromTimeKey		       
					    ,@EffectiveToTimeKey		       
					    ,@TimeKey					       
					    ,@CrModApBy					       
					    ,@D2Ktimestamp	 	       
					    ,@Result		      			       
		  				         
          END
		  	
IF @OperationFlag=1
		BEGIN

			SET @InvEntityId=@Result	
			select '1'	      

		END
	

	IF @OperationFlag<>1
		BEGIN
				SET @RESULT=@InvEntityId
		END			

		

		 IF		@InvestmentFinancialDetailInUp='Y'
		BEGIN		
        PRINT 3
		EXEC	[InvestmentFinancialDetailInUP]
						 
						 @Entitykey 
						,@InvEntityId	
						,@InvID	
						,@IssuerID
						,@HoldingNature		
						,@CurrencyAlt_Key	
						,@CurrencyConvRate  
						,@BookType			
						,@BookValue			
						,@BookValueINR		
						,@MTMValue			
						,@MTMValueINR		
						,@EncumberedMTM		
						,@AssetClass_AltKey	
						,@NPIDt				
						,@DBTDate			
						,@LatestBSDate			
						,@Interest_DividendDueDate			
						,@Interest_DividendDueAmount		
						,@PartialRedumptionDueDate			
						,@PartialRedumptionSettledY_N		   
					   ,@Remark					       
					   ,@MenuID					       
					   ,@OperationFlag				       
					   ,@AuthMode					       
					   ,@IsMOC						       
					   ,@EffectiveFromTimeKey		       
					   ,@EffectiveToTimeKey		       
					   ,@TimeKey					       
					   ,@CrModApBy					       
					   ,@D2Ktimestamp	 	       
					   ,@Result		      			       
		  					
						
		END

		
COMMIT TRANSACTION
    SET @D2Ktimestamp=1            					
END TRY
BEGIN CATCH
		PRINT ERROR_MESSAGE()
		ROLLBACK TRAN
				SET @Result=-1
				RETURN @Result

END CATCH

END
GO