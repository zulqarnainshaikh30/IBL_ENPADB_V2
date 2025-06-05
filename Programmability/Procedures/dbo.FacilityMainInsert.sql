SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROC [dbo].[FacilityMainInsert]

 @Remark						VARCHAR(500)	 =''
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

,@BranchCode					varchar(10)		 =''
,@ScreenEntityId				int				 =1
,@AccountEntityId				INT				 =0
,@ClaimCoverAmt					DECIMAL(18,2)	 =0
,@ClaimLodgedAmt				DECIMAL(18,2)	 =0
,@ClaimReceivedAmt				DECIMAL(18,2)    =0
--,@DICGC_ECGC_NHBClaimSettled	varchar(20)=''


 
,@AdvAcBasicDetail							CHAR(1)       ='N' 
,@AdvBalanceDetail							CHAR(1)       ='N'
,@AdvAcCaseWiseBalanceDetailInUp			CHAR(1)       ='N'
,@AdvAcFinancialInUp						CHAR(1)       ='N'
,@AdvAcOtherBalanceDetail					CHAR(1)       ='N'
,@AdvAcOtherDetailInUp						CHAR(1)       ='N'
,@AdvFacBillDetailInUp						CHAR(1)       ='N'
,@AdvFacCCDetailInUp						CHAR(1)       ='N'
,@AdvFacDLDetailInUp						CHAR(1)       ='N'
,@AdvFacNFDetailInUp						CHAR(1)       ='N'
,@AdvFacPCDetailInUp						CHAR(1)       ='N'

				
,@BlnSCD2ForAdvAcFinancialDetail	       CHAR(1)		='N'
,@Blnscd2foradvacotherdetail			   CHAR(1)		='N'
,@BlnSCD2ForBalanceDetail					char(1)     ='N'
,@BlnSCD2ForAdvAcBasicDetail				CHAR(1)		='N'
,@BlnSCD2ForAdvFacBillDetail                 CHAR(1)     ='N'
,@ScrCrErrorSeq								varchar(100) =''


,@AclattestDevelopment varchar(1000)=''
 ,@DICGC_ECGC_NHBClaimSettled	varchar(20)=''
 ,@LastSanctionAuthAlt_Key				    INT				=0---LastSanctionAuth
,@CustomerEntityId							Int			 =0
,@CustomerACID								Varchar(20)	 =''
,@RefCustomerId								varchar(50)     =''
,@FacilityType								varchar(50)     =''
,@InttTypeAlt_Key							INT        =0 --Interest type
,@InttRate									DECIMAL(18,2)				      =0.0      --InttRate
,@OriginalLimitDt							varchar(10)     =''  ---Originaldate
,@OriginalLimit								decimal(18,2)   =0   --OriginalFirstSanAmt
,@OriginalSanctionAuthAlt_Key				INT		 =0   ---Original Sanction Authority
,@OriginalLimitRefNo						varchar(25)       =''    ---OriginalLimitRefNo
,@OriginalSanctionAuthLevelAlt_Key			INT	     =0   --Sanction Authority Level
,@CurrentLimit								decimal(18,2)   =0.0---LastSanAmount
,@CurrentLimitDt							varchar(10)     =''---LastSanctionDate
,@CurrentLimitRefNo							varchar(25)       =''   --LastSanctionLimitRefNo 
,@Ac_ReviewAuthLevelAlt_Key					INT                      =0		---LastSanctionAuthorityLevel
--,@LastSanctionAuthAlt_Key				    INT				=0---LastSanctionAuth
,@GLAlt_Key									VARCHAR(20)=''   --GL_Code
,@GLProductAlt_Key							INT  	 =0    ----GLProductAlt_Key   
,@SectorAlt_Key								INT		 =0  ---Sector
,@ActivityAlt_Key							INT		 =0
,@SchemeAlt_Key								INT		 =0   --scheme
,@DtofFirstDisb								varchar(10)     =''  ----Disbrusmentdate
,@Ac_DocumentDt								varchar(10)     =''  -----Acknowledment debt date
,@TotalProv									decimal(18,2)			=0.0 --ProvAmt
,@RepayModeAlt_Key							INT   ---RepayMode
,@LastCrDt									varchar(10)        		=''  --Last Credit Date
,@WriteOffAmt_HO							decimal(18,2)
,@WriteOffDt								varchar(10) 
,@LastCrAmt									decimal(18,2)			=0.0--Last Credit Amount
,@ClaimPrincipal							DECIMAL(18,2)	  =0.0     ----LedgerBalance    
,@ClaimUnapplInt							DECIMAL(18,2)	  =0.0     ----UnappliedInt
,@ClaimExpenses								DECIMAL(18,2)   =0.0     ---LegalExpences
,@ClaimOther								DECIMAL(18,2)	  =0.0     ---other
,@ClaimTotal								DECIMAL(18,2)   =0.0     --Total
,@Principal									decimal(18,2)	 =0.0    --PrincipalLedgerBalance
,@UnapplInt									decimal(18,2)	 =0.0        --PrincipalUnappliedInterest
,@Expenses									decimal(18,2)	 =0.0         --PrincipalLegalExpenses
,@Other										decimal(18,2)	 =0.0     ---PrincipalOthers
,@Total										decimal(18,2)    =0.0     ----PrincipalTotal
,@MocTypeAlt_Key							INT=0
,@MOCReason									VARCHAR(10)=''
,@ScrCrError                                VARCHAR(10)=''
,@LimitDisbursed								 VARCHAR(10)=''

---------ADD Changefields Column------
,@Basic_ChangeFields						VARCHAR(250)=''
,@Balance_ChangeFields						VARCHAR(250)=''
,@CaseWiseBalance_ChangeFields				VARCHAR(250)=''
,@Financial_ChangeFields					VARCHAR(250)=''			
,@OtherBalance_ChangeFields					VARCHAR(250)=''		
,@Other_ChangeFields						VARCHAR(250)=''			
,@FacBill_ChangeFields						VARCHAR(250)=''			
,@FacCC_ChangeFields						VARCHAR(250)=''			
,@FacDL_ChangeFields						VARCHAR(250)=''			
,@FacNF_ChangeFields						VARCHAR(250)=''			
,@FacPC_ChangeFields						VARCHAR(250)=''

 


 AS
 BEGIN TRY

 DECLARE
 @ProductAlt_Key  INT
 ,@ProductCode   VARCHAR(20)
 ,@FacilitySubType VARCHAR(20)
 ,@GLAlt_Key1      INT
 ,@MocDate SMALLDATETIME

	IF @AdvBalanceDetail='Y'
	BEGIN
		SET @AdvAcOtherBalanceDetail='Y'
	END

	ELSE IF @AdvAcOtherBalanceDetail='Y'
	BEGIN
		SET @AdvBalanceDetail='Y'
	END

	 PRINT'Hi'

 SELECT @ProductCode=ProductCode ,@FacilitySubType=FacilitySubType FROM DIMGLPRODUCT WHERE GLProductAlt_Key=@GLProductAlt_Key 


 PRINT @FacilitySubType
 SELECT @ProductAlt_Key=ProductAlt_Key FROM DIMPRODUCT WHERE ProductCode=@ProductCode

 SET @GLAlt_Key=(SELECT GLAlt_Key FROM DimGL WHERE GLCode=CAST(@GLAlt_Key AS VARCHAR(10)))



 --********************************************************************************
 --			FOR MOC
 --***********************************************************************************
 IF @IsMOC='Y'
			BEGIN
			    --- for MOC Effective from TimeKey and Effective to time Key is Prev_Qtr_key e.g for 2922  2830
				PRINT 'ISMOC'
				SET @EffectiveFromTimeKey =@TimeKey 
				SET @EffectiveToTimeKey =@TimeKey 
				SET @MocDate =GETDATE()
			END

--********************************************************************************

 BEGIN TRAN

IF @AdvAcBasicDetail='Y' 
   BEGIN
           PRINT 1
		   PRINT 'A'
           EXEC [dbo].[AdvAcBasicDetailInUP]

		    @BranchCode                       
		   ,@AccountEntityId                  
		   ,@CustomerEntityId                 
		   ,''----@SystemACID                       
		   ,@CustomerACID                     
		   ,@GLAlt_Key                        
		   ,@ProductAlt_Key                   
		   ,@GLProductAlt_Key   ---For DlProductAltKey              
		   ,@FacilityType                     
		   ,@SectorAlt_Key                    
		   ,@SectorAlt_Key--0---@SubSectorAlt_Key                 
		   ,@ActivityAlt_Key                  
		   ,0----@IndustryAlt_Key                  
		   ,@SchemeAlt_Key                    
		   ,0---@DistrictAlt_Key                  
		   ,0---@AreaAlt_Key                      
		   ,0---@VillageAlt_Key                   
		   ,0---@StateAlt_Key                     
		   ,0---@CurrencyAlt_Key                  
		   ,@OriginalSanctionAuthAlt_Key      
		   ,@OriginalLimitRefNo               
		   ,@OriginalLimit                    
		   ,@OriginalLimitDt       
		   ,@AclattestDevelopment           
		   ,@DtofFirstDisb                    
		   ,''---@EmpCode                          
		   ,''---@FlagReliefWavier                 
		   ,0---@UnderLineActivityAlt_Key         
		   ,0---@MicroCredit                      
		   ,''---@segmentcode                      
		   ,''---@ScrCrError                       
		   ,''---@AdjDt                            
		   ,0---@AdjReasonAlt_Key                 
		   ,0---@MarginType                       
		   ,0---@Pref_InttRate                    
		   ,@CurrentLimitRefNo                
		   ,''--@ProcessingFeeApplicable          
		   ,0.0--@ProcessingFeeAmt                 
		   ,0.0--@ProcessingFeeRecoveryAmt         
		   ,0--@GuaranteeCoverAlt_Key            
		   ,''--@AccountName                      
		   ,0--@ReferencePeriod                  
		   ,''--@AssetClass                       
		   ,''--@D2K_REF_NO                       
		   ,''--@InttAppFreq                      
		   ,''--@JointAccount                     
		   ,''--@LastDisbDt                       
		   ,''--@ScrCrErrorBackup                 
		   ,''--@AccountOpenDate                  
		   ,''--@Ac_LADDt                         
		   ,@Ac_DocumentDt                    
		   ,@CurrentLimit                     
		   ,@InttTypeAlt_Key                  
		   ,0---@InttRateLoadFactor               
		   ,0---@Margin                           
		   ,''---@TwentyPointReference             
		   ,''---@BSR1bCode                        
		   ,@CurrentLimitDt                   
		   ,''---@Ac_DueDt                         
		   ,0--@DrawingPowerAlt_Key              
		   ,@RefCustomerId                    
		   ,''---@D2KACID                          
		   ,0--@IsLAD                            
		   ,0---@FacilitiesNo                     
		   ,0--@FincaleBasedIndustryAlt_key      
		   ,0--@AcCategoryAlt_Key                
		   ,@OriginalSanctionAuthLevelAlt_Key 
		   ,0--@AcTypeAlt_Key                    
		   ,@ScrCrErrorSeq                    
		   ,''---@D2k_OLDAscromID                  
		   ,''--@BSRUNID                          
		   ,0--@AdditionalProv                   
		   ,0--@ProjectCost                      
		   
		   
		   
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
		   ,@BlnSCD2ForAdvAcBasicDetail	
		   ,@Basic_ChangeFields   
		          
         
   END

PRINT 'A11'
 IF @OperationFlag=1
	BEGIN
			PRINT '111aaaaa'	
			SET @AccountEntityId=@Result

		    IF EXISTS(SELECT 1 FROM CustPreCaseDataStage WHERE CustomerEntityId=@CustomerEntityId)
			   BEGIN
			            							
						UPDATE CustPreCaseDataStage
						SET  CurrentStageAlt_Key=20
						    ,NextStageAlt_Key=30
						WHERE CustomerEntityId=@CustomerEntityId 
			   END

			/* WHEN ADDED NEW ACCOUNT THEN TRIGGER FOR RE-GENERATE STATUS NOTE REPORT*/
			EXEC StatusNoteTriggerInUp @CustomerEntityId
			PRINT '2222BBBBBB'	
	END	


IF @OperationFlag<>1
	BEGIN
		  SET @Result=@AccountEntityId
	END

IF @OperationFlag=17
	BEGIN
			        Print 'Reject'
	              
			
			 IF EXISTS(SELECT 1 FROM CustPreCaseDataStage WHERE CustomerEntityId=@CustomerEntityId)
				   BEGIN
				            
								
							UPDATE CustPreCaseDataStage
							SET  CurrentStageAlt_Key=10
							    ,NextStageAlt_Key=20
							WHERE CustomerEntityId=@CustomerEntityId and CurrentStageAlt_Key=20
				   END
              


	END			


IF @AdvBalanceDetail='Y' 
   BEGIN
         PRINT 'balance table '

		 EXEC   [AdvAcBalanceDetailInUP]

		 		 @AccountEntityId	         
		         ,0--@AssetClassAlt_Key	         
		         ,0---@BalanceInCurrency	         
		         ,0.0---@Balance	                 
		         ,0---@SignBalance	             
		         ,@LastCrDt	                 
		         ,0---@OverDue	                 
		         ,@TotalProv	                 
		         ,0---@DirectBalance	             
		         ,0---@InDirectBalance	         
		         ,@LastCrAmt	                 
		         ,@RefCustomerId	             
		         ,NULL---@RefSystemAcId	             
		         ,NULL---@OverDueSinceDt	         
		         ,@MocTypeAlt_Key	         
		         ,NULL---@Old_OverDueSinceDt	     
		         ,0---@Old_OverDue	             
		         ,0---@IntReverseAmt	             
		         ,0---@PS_Balance	             
		         ,0---@NPS_Balance				 
				 ,@IsMOC						
				 ,@EffectiveFromTimeKey		
				 ,@EffectiveToTimeKey		
				 ,@TimeKey					
				 ,@CrModApBy					
				 ,@D2Ktimestamp				
				 ,@Result					
				 ,@Remark					
				 ,@MenuID					
				 ,@OperationFlag				
				 ,@AuthMode					
				 ,@BlnSCD2ForBalanceDetail   
				 --,@Balance_ChangeFields	             
          
   END


 IF @AdvAcCaseWiseBalanceDetailInUp='Y'
  BEGIN
        PRINT 3
		EXEC DBO.AdvAcCaseWiseBalanceDetailInUp
		        @CustomerEntityID       
		       ,@AccountEntityID        
		       ,@ClaimPrincipal         
		       ,0.0---@ClaimPartialWO         
		       ,@ClaimUnapplInt         
		       ,0---@ClaimBookInt           
		       ,@ClaimExpenses          
		       ,@ClaimOther             
		       ,@ClaimTotal             
		          
		       ,@EffectiveFromTimeKey   
		       ,@EffectiveToTimeKey     
		       ,@CrModApBy              
		       ,@OperationFlag          
		       ,@D2Ktimestamp           
		       ,@Result                 
		       ,@AuthMode               
		       ,@MenuID                 
		       ,@Remark                 
		       ,@TimeKey 
			   --,@CaseWiseBalance_ChangeFields  
			                
  END

IF @AdvAcFinancialInUp='Y'
  BEGIN
          PRINT 4

		  
		  EXEC [AdvAcFinancialInUp]
		  
		  @AccountEntityId                                
		 ,NULL---@Ac_LastReviewDueDt                             
		 ,0--@Ac_ReviewTypeAlt_key                           
		 ,NULL--@Ac_ReviewDt                                    
		 ,@LastSanctionAuthAlt_Key----@Ac_ReviewAuthAlt_Key                           
		 ,NULL---@Ac_NextReviewDueDt                             
		 ,0.0---@DrawingPower                                   
		 ,@InttRate                                       
		 ,NULL--@IrregularType                                  
		 ,NULL---@IrregularityDt                                 
		 ,NULL--@NpaDt                                          
		 ,0.0--@BookDebts                                      
		 ,0.0--@UnDrawnAmt                                     
		 ,0.0---@TotalDI                                        
		 ,0.0---@UnAppliedIntt                                  
		 ,0.0---@LegalExp                                       
		 ,0.0---@UnAdjSubSidy                                   
		 ,NULL---@LastInttRealiseDt                              
		 ,@MOCReason                                      
		 ,@WriteOffAmt_HO                                 
		 ,0--@InterestRateCodeAlt_Key                        
		 ,@WriteOffDt                                     
		 ,NULL---@OD_Dt                                          
		 ,0.0 --@LimitDisbursed                                 
		 ,0.0---@WriteOffAmt_BR                                 
		 ,@RefCustomerId                                  
		 ,NULL---@RefSystemAcId                                  
		 ,@MocTypeAlt_Key                                 
		 ,0.0--@CropDuration                                   
		 ,@Ac_ReviewAuthLevelAlt_Key                      
		 ,@BlnSCD2ForAdvAcFinancialDetail	             
		 
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
		 --,@Financial_ChangeFields




		 				                     
					       			
  END

  
IF @AdvAcOtherBalanceDetail='Y'
  BEGIN
         PRINT 'Swap6'
		 EXEC [dbo].[AdvAcOtherBalanceDetailInUp] 
		  @CustomerEntityID	    
		 ,@AccountEntityID	    
		 ,@Principal	            
		 ,0---@PartialWO	            
		 ,@UnapplInt	            
		 ,0---@BookInt	            
		 ,@Expenses	            
		 ,@Other	                
		 ,@Total	                
		 
		 ,@EffectiveFromTimeKey	
		 ,@EffectiveToTimeKey	
		 ,@D2Ktimestamp	        
		 ,@TimeKey               
		 ,@OperationFlag         
		 ,@AuthMode              
		 ,@MenuID                
		 ,@Remark                
		 ,@BranchCode            
		 ,@ScreenEntityId        
		 ,@CrModApBy     
		 ,@Result        OUTPUT 
		 --,@OtherBalance_ChangeFields  
  END

IF @AdvAcOtherDetailInUp='Y'
 BEGIN
  PRINT 'Swap5'
	   EXEC DBO.AdvAcOtherDetailInUp
	       
        @ACCOUNTENTITYID            	 
	   ,0---@GOVGURAMT						 
	   ,0---@REFINANCEAGENCYALT_KEY		 
	   ,0---@REFINANCEAMOUNT				 
	   ,0--@BANKALT_KEY					 
	   ,0---@TRANSFERAMT					 
	   ,NULL---@PROJECTID						 
	   ,NULL---@CONSORTIUMID					 
	   ,NULL--@REFSYSTEMACID					 
	   ,NULL---@CONTINOUSEXCESSSECDT			 
	   ,NULL---@GOVGUREXPDT					 
	   ,@ISMOC							 
	   ,@EFFECTIVEFROMTIMEKEY			 
	   ,@EFFECTIVETOTIMEKEY             
	   ,0---@SPLCATG1ALT_KEY				 
	   ,0---@SPLCATG2ALT_KEY				 
	   ,0---@SPLCATG3ALT_KEY				 
	   ,0---@SPLCATG4ALT_KEY                	   
	   ,@REMARK					     
	   ,@MENUID					     
	   ,@OPERATIONFLAG				     
	   ,@AUTHMODE					     
	   ,@TIMEKEY					     
	   ,@CrModApBy					     
	   ,@D2KTIMESTAMP				     
	   ,@RESULT					     
	   ,@Blnscd2foradvacotherdetail     
	   ,@MOCTYPEALT_KEY	
	   --,@Other_ChangeFields			 

 END


IF @AdvFacCCDetailInUp='Y' AND @FacilitySubType IN ('OD','CC')
  BEGIN
  PRINT 'Swap4'
 EXEC [dbo].[AdvFacCCDetailInUp]
	    @AccountEntityId				
	   ,NULL--@AdhocDt						
	   ,0--@AdhocAmt						
	   ,NULL--@ContExcsSinceDt				
	   ,0---@MarginAmt						
	   ,0---@DerecognisedInterest1			
	   ,0---@DerecognisedInterest2			
	   ,0--@AdjReasonAlt_Key				
	   ,NULL---@EntityClosureDate				
	   ,0---@EntityClosureReasonAlt_Key	
	   ,NULL---@ClaimType						
	   ,@ClaimCoverAmt					
	   ,NULL---@ClaimLodgedDt					
	   ,@ClaimLodgedAmt				
	   ,NULL--@ClaimRecvDt					
	   ,@ClaimReceivedAmt				
	   ,0---@ClaimRate						
	   ,NULL---@RefSystemAcid					
	   ,NULL--@AdhocExpiryDate				
	   ,0---@AdhocPermittedAlt_key			
	   ,NULL--@AdhocAuth_ID					
	   ,0---@AdhocNormalInterest			
	   ,NULL---@DebitSinceDt					
	   ,NULL--@Acc_StkSmtFlag				
	   ,NULL--@ChangeFields					

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
	   ,@BranchCode					
	   ,@ScreenEntityId	
	  -- ,@FacCC_ChangeFields


  END
	   

	   
IF @AdvFacBillDetailInUp ='Y'AND @FacilitySubType='BP'
	BEGIN
	PRINT 'Swap3'
		Exec [AdvFacBillDetailInUp]
		 @AccountEntityId			
		,0---@D2KFacilityID				
		,NULL--@BillNo					
		,NULL---@BillDt					
		,0---@BillAmt					
		,NULL---@BillRefNo					
		,NULL---@BillPurDt					
		,0---@AdvAmount					
		,NULL--@BillDueDt					
		,NULL---@BillExtendedDueDt			
		,NULL---@CrystalisationDt			
		,NULL--@CommercialisationDt		
		,0--@BillNeNo					
		,NULL---@DraweeBankName			
		,NULL---@DraatureAlt_Key			
		,NULL---@BillAcceptanceDt			
		,0---@UsanceDays				
		,0---@DrawewerName				
		,NULL--@PayeeName					
		,NULL---@CollectingBankName		
		,NULL---@CollectingBranchPlace		
		,0---@InterestIncome			
		,0--@Commission				
		,0---@DiscountCharges			
		,0--@DelayedInt				
		,0--@MarginType				
		,0---@MarginAmt					
		,0--@CountryAlt_Key			
		,0--@BillOsReasonAlt_Key		
		,0--@CommodityAlt_Key			
		,NULL---@LcNo						
		,0---@LcAmt						
		,0---@LcIssuingBankAlt_Key		
		,NULL---@LcIssuingBank				
		,0---@CurrencyAlt_Key			
		,0.0---@Balance					
		,0--@BalanceInCurrency			
		,0---@Overdue					
		,0---@DerecognisedInterest1		
		,0---@DerecognisedInterest2		
		,0.0----@UnAppliedIntt				
		,0----@BillFacilityNo			
		,0.0---@CAD						
		,0.0---@CADU						
		,NULL----@OverDueSinceDt			
		,@TotalProv					
		,0----@AdditionalProv			
		,0---@GenericAddlProv			
		,0--@Secured					
		,0--@CoverGovGur				
		,0--@Unsecured					
		,0--@Provsecured				
		,0--@ProvUnsecured				
		,0--@ProvDicgc					
		,NULL---@npadt						
		,NULL---@ClaimType					
		,@ClaimCoverAmt				
		,NULL---@ClaimLodgedDt				
		,@ClaimLodgedAmt	-------DICGC/ECGC/NHBClaimEligible		
		,NULL---@ClaimRecvDt				
		,@ClaimReceivedAmt			
		,0---@ClaimRate					
		,@ScrCrError				
		,NULL---@RefSystemAcid				
		,NULL--@AdjDt						
		,0--@AdjReasonAlt_Key			
		,NULL--@EntityClosureDate			
		,0--@EntityClosureReasonAlt_Key
		,@MocTypeAlt_Key			
		,@ScrCrErrorSeq				
		,NULL--@ConsigmentExport			
		---------D2k System Common C
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
		,@BranchCode				
		,@ScreenEntityId	
		--,@FacBill_ChangeFields
		
	END	



IF @AdvFacDLDetailInUp = 'Y'AND @FacilitySubType IN ('DL','TL')
   BEGIN
  PRINT 'Swap2'
	   EXEC [AdvFacDLDetailInUp]
	   @AccountEntityId				
	   ,@Principal						
	   ,@RepayModeAlt_Key				
	   ,0---@NoOfInstall					
	   ,0--@InstallAmt					
	   ,NULL---@FstInstallDt					
	   ,NULL---@LastInstallDt					
	   ,0---@Tenure_Months					
	   ,0---@MarginAmt						
	   ,0--@CommodityAlt_Key				
	   ,0--@RephaseAlt_Key				
	   ,NULL--@RephaseDt						
	   ,NULL--@IntServiced					
	   ,0---@SuspendedInterest				
	   ,0---@DerecognisedInterest1			
	   ,0---@DerecognisedInterest2			
	   ,0--@AdjReasonAlt_Key				
	   ,NULL----@LcNo							
	   ,0----@LcAmt							
	   ,0--@LcIssuingBankAlt_Key			
	   ,0--@ResetFrequency				
	   ,NULL---@ResetDt						
	   ,0--@Moratorium					
	   ,NULL---@FirstInstallDtInt				
	   ,NULL---@ContExcsSinceDt				
	   ,0----@loanPeriod					
	   ,NULL---@ClaimType						
	   ,@ClaimCoverAmt					
	   ,NULL---@ClaimLodgedDt					
	   ,@ClaimLodgedAmt				
	   ,NULL---@ClaimRecvDt					
	   ,@ClaimReceivedAmt				
	   ,0---@ClaimRate						
	   ,NULL---@RefSystemAcid					
	   ,0.0----@UnAppliedIntt					
	   ,0---@NxtInstDay					
	   ,0---@PrplOvduAftrMth				
	   ,0---@PrplOvduAftrDay				
	   ,0---@InttOvduAftrDay				
	   ,0--@InttOvduAftrMth				
	   ,NULL---@PrinOvduEndMth				
	   ,NULL--@InttOvduEndMth				
	   ,@ScrCrErrorSeq					
	   ---------D2k System Common Colum

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
	   ,@BranchCode					
	   ,@ScreenEntityId		
	   --,@FacDL_ChangeFields		

   END

   IF @AdvFacPCDetailInUp = 'Y'AND @FacilitySubType='PC'
	BEGIN
	PRINT 'Swap1'
		EXEC [AdvFacPCDetailInUp] 
		@AccountEntityId				
		,NULL---@PCRefNo						
		,NULL---@PCAdvDt						
		,0---@PCAmt							
		,NULL---@PCDueDt						
		,0--@PCDurationDays				
		,NULL--@PCExtendedDueDt				
		,NULL---@ExtensionReason				
		,0--@CurrencyAlt_Key				
		,NULL--@LcNo							
		,0--@LcAmt							
		,NULL---@LcIssueDt						
		,NULL---@LcIssuingBank_FirmOrder		
		,0.0--@Balance						
		,0---@BalanceInCurrency				
		,0---@BalanceInUSD					
		,0---@Overdue						
		,0--@CommodityAlt_Key				
		,0--@CommodityValue				
		,0---@CommodityMarketValue			
		,NULL---@ShipmentDt					
		,NULL--@CommercialisationDt			
		,NULL----@EcgcPolicyNo					
		,0---@CAD							
		,0---@CADU							
		,NULL----@OverDueSinceDt				
		,@TotalProv						
		,0--@Secured						
		,0--@Unsecured						
		,0--@Provsecured					
		,0--@ProvUnsecured					
		,0--@ProvDicgc						
		,NULL--@npadt							
		,0--@CoverGovGur					
		,0--@DerecognisedInterest1			
		,0--@DerecognisedInterest2			
		,NULL---@ClaimType						
		,@ClaimCoverAmt					
		,NULL---@ClaimLodgedDt					
		,@ClaimLodgedAmt				
		,NULL---@ClaimRecvDt					
		,@ClaimReceivedAmt				
		,0---@ClaimRate						
		,NULL---@AdjDt							
		,NULL---@EntityClosureDate				
		,0---@EntityClosureReasonAlt_Key	
		,NULL----@RefSystemAcid					
		,0.0----@UnAppliedIntt					
		,NULL--@RBI_ExtnPermRefNo				
		,0--@LC_OrderAlt_Key				
		,0---@OrderLC_CurrencyAlt_Key		
		,0---@CountryAlt_Key				
		,0---@LcAmtInCurrenc				
		---------D2k System Common Colum
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
		,@BranchCode					
		,@ScreenEntityId
		--,@FacPC_ChangeFields				
	END

 IF @AdvFacNFDetailInUp = 'Y' AND @FacilityType IN('LC','BG')
   BEGIN
   PRINT 11
   PRINT 'Swap'
		EXEC[dbo].[AdvFacNFDetailInUp]

		@AccountEntityId				
		,0--@D2KFacilityID					
		,@GLAlt_key						
		,NULL--@Operative_Acid				
		,NULL--@LCBG_TYPE						
		,NULL--@LCBGNo						
		,0--@LcBgAmt						
		,NULL--@OriginDt						
		,NULL---@EffectiveDt					
		,NULL--@ExpiryDt						
		,NULL--@ExtensionDt					
		,0---@TypeAlt_Key					
		,0---@NatureAlt_Key					
		,NULL--@BeneficiaryType				
		,NULL--@BeneficiaryName				
		,0.0---@Balance						
		,0--@BalanceInCurrency				
		,0--@CurrencyAlt_Key				
		,0---@CountryAlt_Key				
		,NULL--@NegotiatingBank				
		,0--@MargINType					
		,0---@MarginAmt						
		,0---@PurposeAlt_Key				
		,NULL---@ShipmentDt					
		,NULL--@CoveredByBank					
		,0--@CoveredByBankAlt_Key			
		,NULL--@InvocationDt					
		,0--@Commission					
		,0--@BillReceived					
		,0---@BillsUnderCollAmt				
		,NULL---@FundedConversionDt			
		,NULL---@Datepaid						
		,NULL----@RecoveryDt					
		,NULL---@CounterGuar					
		,NULL--@CorresBankCode				
		,NULL--@CorresBrCode					
		,NULL--@ClaimDt						
		,0---@NFFacilityNo					
		,NULL---@Periodicity					
		,0---@CommissionDue					
		,NULL---@DueDateOfRecovery				
		,NULL--@CommOnDuedateYN				
		,NULL--@DelayReason					
		,NULL--@PresentPosition				
		,0---@AmmountRecovered				
		,@ScrCrError					
		,NULL---@AdjDt							
		,0---@AdjReasonAlt_Key				
		,NULL---@EntityClosureDate				
		,0---@EntityClosureReasonAlt_Key	
		,@RefCustomerId					
		,NULL----@RefSystemAcId					
		,NULL---@GovtGurantee					
		,0---@GovGurAmt						
		,@ScrCrErrorSeq					
		-----------D2k System Common Col	
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
		,@BranchCode					
		,@ScreenEntityId	
		--,@FacNF_ChangeFields
					
   END


   IF @OperationFlag IN(1,2,3,16,17,18) AND @AuthMode ='Y'
		BEGIN 
					print 'log table'
					DECLARE
				
					  @CreatedCheckedDt DATE=GETDATE()
				
					IF @OperationFlag IN(16,17,18) 
						BEGIN 
						PRINT 'SP1'
						PRINT @Remark
						     Declare
						      @ApprovedBy  varchar(100)=@CrModApBy
					

					
								EXEC LogDetailsInsertUpdate_Attendence -- MAINTAIN LOG TABLE
							    @BranchCode=@BranchCode   ,  ----BranchCode
								@MenuID=6675,
								@ReferenceID=@RefCustomerId ,-- ReferenceID ,
								@CreatedBy=NULL,
								@ApprovedBy=@CrModApBy, 
								@CreatedCheckedDt=@CreatedCheckedDt,
								@Remark=@Remark,
								--@ScreenEntityId=16  ,---ScreenEntityId -- for FXT060 screen
								@ScreenEntityAlt_Key=123,
								@Flag=@OperationFlag,
								@AuthMode=@AuthMode
						END
					ELSE
						BEGIN
						PRINT 'SP'
						PRINT @Remark
						     Declare
						      @CreatedBy  varchar(100)=@CrModApBy							
							 
							EXEC LogDetailsInsertUpdate_Attendence -- MAINTAIN LOG TABLE
								@BranchCode=@BranchCode,  ----BranchCode
								@MenuID=6675,
								@ReferenceID=@RefCustomerId ,-- ReferenceID ,
								@CreatedBy=@CreatedBy,
								@ApprovedBy=NULL, 
								@CreatedCheckedDt=@CreatedCheckedDt,
								@Remark=NULL,
								@ScreenEntityAlt_Key=123  ,---ScreenEntityId -- for FXT060 screen
								@Flag=@OperationFlag,
								@AuthMode=@AuthMode
						END

		END

			DECLARE @AuthorisationStatus  CHAR(2)
			IF @OperationFlag=1 SET @AuthorisationStatus='NP'
			IF @OperationFlag=2 SET @AuthorisationStatus='MP'
			IF @OperationFlag=3 SET @AuthorisationStatus='DP'
			IF @OperationFlag=16 SET @AuthorisationStatus='A'
			print 'saurabh1'
			--EXEC [SysDataUpdation_InUp]
			--			@BranchCode				=	@BranchCode		
			--			,@ID					=	@CustomerEntityId
			--			,@Name					=	''
			--			,@Type					=	''
			--			,@CaseNo				=	''
			--			,@CaseType				=	0
			--			,@CustomerACID			=	''	
			--			,@RecordType			=	'PreCase'	
			--			,@AuthorisationStatus	=	@AuthorisationStatus
			--			,@CrModBy				=	@CrModApBy
			--			,@MenuID				=	@MenuId
			--			,@ParentEntityID		=	@CustomerEntityId
			--			,@EntityID				=	@CustomerEntityId
			--			,@Remark				=	@Remark
			--			,@CustomerId			=	@RefCustomerId
			--			--,@IsStatusInsert		=	@IsStatusInsert
			--			 print 'saurabh2'
COMMIT TRANSACTION
    SET @D2Ktimestamp=1            					
   END TRY
BEGIN CATCH
		PRINT ERROR_MESSAGE()
		ROLLBACK TRAN
				SET @Result=-1
				RETURN @Result

END CATCH

GO