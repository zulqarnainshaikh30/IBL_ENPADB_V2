SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO






-- CustomerAssetClassChange '9987880000000001',2



CREATE Procedure [dbo].[CustomerAssetClassChange]

@CustomerId varchar(30),

@AssetClassChange Int

AS

Declare @Count Int,@I Int

Declare @AccountID Varchar(30)

Declare @Comments Varchar(max)

Declare @Comments1 Varchar(max)

Declare @RePossessionFlag Char(1),@InherentWeaknes Char(1),@SARFAESIFlag Char(1),@UnusualBounce Char(1),@UnclearedEffects Char(1)

Declare @InterestReceivable Decimal(18,2)



	Declare @Timekey INT

 SET @Timekey =(Select Timekey from SysDataMatrix Where MOC_Initialised='Y' AND ISNULL(MOC_Frozen,'N')='N') 

  -- Commented by Ravish 27th May 2021. Customer and Account MOC are independent. So removed the validation for checking Degradation flag
--IF (@AssetClassChange=1)

--BEGIN

-- IF OBJECT_ID('TempDB..#temp') IS NOT NULL   DROP TABLE  #temp;

               



--Select  ROW_NUMBER() OVER(ORDER BY CustomerAcID) as ID,A.CustomerAcID,A.FlgRestructure as RePossessionFlag,WeakAccount as InherentWeaknessFlag,Sarfaesi as SARFAESIFlag,

--FlgUnusualBounce as UnusualBounceFlag,FlgUnClearedEffect as UnclearedEffectsFlag

--INTO #temp

--FRom Pro.accountcal_Hist A

--Where A.RefCustomerID=@CustomerId

--		 AND A.EffectiveFromTimeKey <= @Timekey

--					   AND A.EffectiveToTimeKey >= @Timekey

					

	





--Select @Count=Count(*) from #temp

--SET @I=1

--SET @Comments1=''

--WHILE (@I<=@Count)



--BEGIN



--    Select @AccountID=CustomerAcID, @RePossessionFlag=RePossessionFlag,@InherentWeaknes=InherentWeaknessFlag,@SARFAESIFlag=SARFAESIFlag,@UnusualBounce=UnusualBounceFlag,@UnclearedEffects=UnclearedEffectsFlag

--	from #temp Where ID=@I

     

--	 IF(@RePossessionFlag='Y')

--	   BEGIN

--	     SET @Comments1=@Comments1+'Account'+ @AccountID+ ' is marked flag Re-possession,' 

--       END



--	 IF(@InherentWeaknes='Y')

--	   BEGIN

--	     SET @Comments1=@Comments1+'Account '+ @AccountID+ ' is marked flag Inherent Weakness,' 

--       END



--	 IF(@SARFAESIFlag='Y')

--	    BEGIN

--		  SET @Comments1=@Comments1+'Account '+ @AccountID+ ' is marked flag SARFAESI,' 

--		END



--	 IF(@UnusualBounce='Y')

--		BEGIN

--		  SET @Comments1=@Comments1+'Account '+ @AccountID+ ' is marked flag Unusual Bounce,' 

--		END



--	 IF(@UnclearedEffects='Y')

--		BEGIN

--		  SET @Comments1=@Comments1+'Account '+ @AccountID+ ' is marked flag Uncleared Effects,' 

--		END

--		SET @I=@I+1



		



--END

--Update CustomerLevelMOC

--SET NPADate=NULL

--Where CustomerID=@CustomerId

--IF (@Comments1<>'')

--SET @Comments1='You cannot mark the customer as Standard. 1 or more accounts are marked to various degradation flags '+@Comments1+ ' Kindly perform ‘Account level NPA MOC and unmark the mentioned account IDs from the flag'



--Select @Comments1

--END



IF (@AssetClassChange=2)

BEGIN

IF OBJECT_ID('TempDB..#temp1') IS NOT NULL   DROP TABLE  #temp1;

Select  ROW_NUMBER() OVER(ORDER BY AccountID) as ID,A.AccountID,A.InterestReceivable

INTO #temp1

FRom AccountLevelMOC A

Inner Join AdvAcBasicDetail F on A.AccountID=F.CustomerACID

inner join CustomerBasicDetail B

on B.CustomerEntityId=F.CustomerEntityID

Where B.CustomerID=@CustomerId









Select @Count=Count(*) from #temp1

SET @I=1

SET @Comments1=''

WHILE (@I<=@Count)

BEGIN 

       Select @AccountID=AccountID, @InterestReceivable=InterestReceivable from #temp1 Where ID=@I



	   IF (@InterestReceivable IS NOT NULL)

	      BEGIN

		   Update AccountLevelMOC

		   SET InterestReceivable=0,

		   MOCDate =GETDATE(),

		   MOCReason=' kindly enter ‘Customer level NPA MOC performed. Account changed from Standard to NPA',

		   MOCBy='System'

	        Where AccountID=@AccountID

		   

		  END

		  	SET @I=@I+1

END



END











GO