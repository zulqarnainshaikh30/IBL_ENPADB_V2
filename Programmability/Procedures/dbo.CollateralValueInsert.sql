SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROC [dbo].[CollateralValueInsert]



@CollateralID								int=0		

,@CollateralValueatSanctioninRs				decimal(18,2)

,@CollateralValueasonNPAdateinRs			decimal(18,2)

,@CollateralValueatthetimeoflastreviewinRs	decimal(18,2)



,@ValuationDate								varchar(30)=''

,@LatestCollateralValueinRs					decimal(18,2)

,@ExpiryBusinessRule						varchar(30)=''

,@Periodinmonth								int=0

,@ValueExpirationDate						 varchar(30)=''

,@AuthorisationStatus		varchar(5)=NULL

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

						--,@Entity_Key            Int

						,@ValuationDateChar     Varchar(12)

				--SET @ScreenName = 'Collateral'



	-------------------------------------------------------------



 SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C') 



 SET @EffectiveFromTimeKey  = @TimeKey



	SET @EffectiveToTimeKey = 49999



SET @ValuationDateChar= Convert(Varchar(12),@ValuationDate,101) 

SET @ValuationDateChar=Substring(@ValuationDateChar,7,4) +'-'+Substring(@ValuationDateChar,4,2)+'-'+Substring(@ValuationDateChar,1,2)

SET @ValueExpirationDate= Convert(Varchar(12),@ValueExpirationDate,101)       
SET @ValueExpirationDate=Substring(@ValueExpirationDate,7,4) +'-'+Substring(@ValueExpirationDate,4,2)+'-'+Substring(@ValueExpirationDate,1,2) 
  



Declare @SecurityEntityID      bigint



--AS

if (@OperationFlag =1)

		BEGIN

		

		select @SecurityEntityID= MAX(ISNULL(SecurityEntityID,0)) from DBO.AdvSecurityValueDetail_MOD       
          
    IF (@SecurityEntityID IS NULL)      
      
      SET   @SecurityEntityID=1      
      
     ELSE       
         SET    @SecurityEntityID=@SecurityEntityID+1  

IF @OperationFlag=1 AND ISNULL(@CollateralID,'')=''

     BEGIN
		 Select @CollateralID=CollateralID from DBO.AdvSecurityDetail_MOD  
		Where SecurityEntityID IN(Select Max(SecurityEntityID) from DBO.AdvSecurityDetail_MOD)

     END
      
  PRINT '@CollateralID'      
  PRINT @CollateralID

  IF @ValuationDate<>''  
    BEGIN  

			insert into DBO.AdvSecurityValueDetail_MOD 

					(
					CollateralID
					--CollateralValueatthetimeoflastreviewinRs
					,SecurityEntityID
					,ValuationDate
					,CurrentValue
					,ValuationExpiryDate
					,ExpiryBusinessRule
					,Periodinmonth
					,EffectiveFromTimeKey
					,EffectiveToTimeKey
					 ,AuthorisationStatus 
					 ,ApprovedBy
					 ,DateApproved)

					 Select  @CollateralID

			         --@CollateralValueatthetimeoflastreviewinRs
					 ,@SecurityEntityID
					 ,@ValuationDateChar
					 ,@LatestCollateralValueinRs	
			         ,Convert(date,@ValueExpirationDate)	
					 ,@ExpiryBusinessRule						
					 ,@Periodinmonth
					 ,@EffectiveFromTimeKey	
			        ,@EffectiveToTimeKey	
			          ,'NP'        
					 ,@ApprovedBy         
					 ,GETDATE()

	Declare @collateralCount Int

		 SELECT @collateralCount=Count(*) FROM DBO.AdvSecurityValueDetail_MOD WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)   
            AND EffectiveFromTimeKey=@TimeKey AND CollateralID=@CollateralID

			PRINT '@collateralCount'
			PRINT @collateralCount
			IF @collateralCount>2
			   BEGIN
			     PRINT 'Sachin'  
				 Update DBO.AdvSecurityValueDetail_MOD   
				 SET EffectiveFromTimeKey=@Timekey-1,      
				 EffectiveToTimeKey=@Timekey-1
				 Where CollateralID=@CollateralID  
			      AND  SecurityEntityID IN(Select MIN(SecurityEntityID)
			      FROM DBO.AdvSecurityValueDetail_MOD  WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)   
				  AND EffectiveFromTimeKey=@TimeKey AND CollateralID=@CollateralID)

			   END	

			

		END

END

BEGIN

				SET @Result=0

			END



			BEGIN

				SET @Result=1

			END

if (@OperationFlag =17)

BEGIN
   Update DBO.AdvSecurityValueDetail_MOD      
     SET  EffectiveToTimeKey=@Timekey-1,  
   AuthorisationStatus='R'  
  
   Where CollateralID=@CollateralID   
   AND AuthorisationStatus in('NP','MP','1A')
END

if (@OperationFlag =21)

BEGIN
   Update DBO.AdvSecurityValueDetail_MOD      
     SET  EffectiveToTimeKey=@Timekey-1,  
   AuthorisationStatus='R'    
   Where CollateralID=@CollateralID   
   AND AuthorisationStatus in('NP','MP''1A')
END

if (@OperationFlag =2)      
  BEGIN      
  
 
  select @SecurityEntityID= MAX(ISNULL(SecurityEntityID,0)) from DBO.AdvSecurityValueDetail_MOD       
        
     --Select @Entity_Key=MAX(Entity_Key) from Curdat.AdvSecurityValueDetail      
     --Where CollateralID=@CollateralID      
      
     Update DBO.AdvSecurityValueDetail_MOD      
     SET EffectiveFromTimeKey=@Timekey-1,      
   EffectiveToTimeKey=@Timekey-1,  
   AuthorisationStatus='R'  
   Where CollateralID=@CollateralID   
   
    Update Curdat.AdvSecurityValueDetail     
     SET EffectiveFromTimeKey=@Timekey-1,      
   EffectiveToTimeKey=@Timekey-1,  
   AuthorisationStatus='R'  
   Where CollateralID=@CollateralID     
      
         
      
   IF (@SecurityEntityID IS NULL)      
      
      SET   @SecurityEntityID=1      
      
     ELSE       
         SET    @SecurityEntityID=@SecurityEntityID+1      
          
      PRINT '@SecurityEntityID'       
            
      PRINT @SecurityEntityID   
	  
	           
   --   PRINT '@ValuationDateChar' 
	  --PRINT @ValuationDateChar 

	  --   PRINT '@LatestCollateralValueinRs' 
	  --PRINT @LatestCollateralValueinRs 

	  --   PRINT '@ValueExpirationDate' 
	  --PRINT @ValueExpirationDate
            
      
   --SET DATEFORMAT DMY         
   insert into DBO.AdvSecurityValueDetail_MOD      
     (      
     CollateralID      
           
     ,SecurityEntityID      
     ,ValuationDate      
     ,CurrentValue      
     ,ValuationExpiryDate      
     ,ExpiryBusinessRule      
     ,Periodinmonth      
           
     ,EffectiveFromTimeKey      
     ,EffectiveToTimeKey      
      ,AuthorisationStatus        
    ,ApprovedBy      
     ,DateApproved)      
      
   Select   @CollateralID      
      
      ,@SecurityEntityID      
            ,@ValuationDateChar       
           ,@LatestCollateralValueinRs       
     ,Convert(date,@ValueExpirationDate)         
     ,@ExpiryBusinessRule            
,@Periodinmonth       
        
     ,@EffectiveFromTimeKey       
     ,@EffectiveToTimeKey       
      ,'MP'         
      ,@ApprovedBy        
      ,GETDATE()      
     
   Update Curdat.AdvSecurityValueDetail  
   SET AuthorisationStatus='MP'  
   Where (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
   AND CollateralID=@CollateralID  
  
      BEGIN      
    SET @Result=0      
   END      
      
   BEGIN      
    SET @Result=1      
   END      
  END 
							END
GO