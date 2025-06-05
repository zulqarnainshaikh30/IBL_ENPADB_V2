SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO





--Select * from AccountLevelMOC_Mod

--Where AccountID='133'

-- exec AccountLevelSearchList @AccountID=N'130',@OperationFlag=2


--[AccountLevelSearchList]

-- exec AccountLevelSearchList @AccountID=N'00283GLN500166',@OperationFlag=2

      --Main Screen Select 
--exec AccountLevelSearchList @AccountID=N'809002647561',@OperationFlag=2
--go
 

 -- exec AccountLevelSearchList @AccountID=N'130',@OperationFlag=16

CREATE PROC [dbo].[CalypsoAccountLevelSearchList]

--Declare

												

												--@PageNo         INT         = 1, 

													--@PageSize       INT         = 10, 

							

													

													--@PageNo         INT         = 1, 

													--@PageSize       INT         = 10, 

													@OperationFlag  INT  = 1      ,

													@AccountID	varchar(30)	= ''	,

													@TimeKey INT                =25992

AS

    --25999 

	 BEGIN



SET NOCOUNT ON;



 --Declare @Timekey INT

 --SET @Timekey =(Select TimeKey from SysDataMatrix where CurrentStatus='C') 



 -- SET @Timekey =(Select LastMonthDateKey from SysDayMatrix where Timekey=@Timekey) 

 
	SET @Timekey =(Select Timekey from SysDataMatrix Where MOC_Initialised='Y' AND ISNULL(MOC_Frozen,'N')='N') 



	PRINT '@Timekey'

	PRINT @Timekey

	--SET @Timekey=25992

Declare @CreatedBy Varchar(50)

Declare @DateCreated Date

Declare @ModifiedBy Varchar(50)

Declare @DateModified Date

Declare @ApprovedBy Varchar(50)

Declare @DateApproved Date

Declare @AuthorisationStatus Varchar(5)	
DEclare @MOCReason Varchar(500)
Declare @MocSource VARCHAR(50)

Declare @ApprovedByFirstLevel	varchar(100)
Declare @DateApprovedFirstLevel	date
Declare @MOC_ExpireDate date
DECLARE @MOC_TYPEFLAG varchar(4)
DECLARE @AccountEntityID INT

SET @AccountEntityID =(SELECT InvEntityId FROM InvestmentBasicDetail WHERE  InvID=@AccountID
                         AND  EffectiveFromTimeKey<=@Timekey and EffectiveToTimeKey>=@Timekey 
						 UNION
						 SELECT DerivativeEntityid FROM curdat.DerivativeDetail WHERE  DerivativeRefNo=@AccountID
                         AND  EffectiveFromTimeKey<=@Timekey and EffectiveToTimeKey>=@Timekey 
						 )


IF @OperationFlag NOT IN (16,20)

BEGIN
	SELECT  

	@CreatedBy=CreatedBy,@MocReason=MocReason,

	@DateCreated=DateCreated,@ModifiedBy=ModifyBy,@DateModified=DateModified,@ApprovedBy=ApprovedBy,@DateApproved=DateApproved,

	@AuthorisationStatus=AuthorisationStatus	,@MocSource=MOCSource
	,@ApprovedByFirstLevel=ApprovedByFirstLevel,@DateApprovedFirstLevel=DateApprovedFirstLevel,
	@MOC_TYPEFLAG=MOC_TYPEFLAG

	FROM CalypsoAccountLevelMOC_Mod 
	
	where AuthorisationStatus in('MP','1A','A') AND AccountEntityID=@AccountEntityID

	AND  EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey
	and accountid=@AccountID 

	
	END

		if @OperationFlag  = '16'

	BEGIN

	SELECT  

	@CreatedBy=CreatedBy,@MocReason=MocReason,

	@DateCreated=DateCreated,@ModifiedBy=ModifyBy,@DateModified=DateModified,@ApprovedBy=ApprovedBy,@DateApproved=DateApproved,

	@AuthorisationStatus=AuthorisationStatus	,@MocSource=MOCSource
	,@ApprovedByFirstLevel=ApprovedByFirstLevel,@DateApprovedFirstLevel=DateApprovedFirstLevel
	,@MOC_TYPEFLAG=MOC_TYPEFLAG

	FROM CalypsoAccountLevelMOC_Mod 

	where AuthorisationStatus in('MP') AND  AccountEntityID=@AccountEntityID

	AND  EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey
	and accountid=@AccountID 
	--AND SCREENFLAG <> ('U')

	END

	if @OperationFlag  = '20'

	BEGIN

	SELECT  

	@CreatedBy=CreatedBy,@MocReason=MocReason,

	@DateCreated=DateCreated,@ModifiedBy=ModifyBy,@DateModified=DateModified,@ApprovedBy=ApprovedBy,@DateApproved=DateApproved,

	@AuthorisationStatus=AuthorisationStatus	,@MocSource=MOCSource
	,@ApprovedByFirstLevel=ApprovedByFirstLevel,@DateApprovedFirstLevel=DateApprovedFirstLevel
	,@MOC_TYPEFLAG=MOC_TYPEFLAG

	FROM CalypsoAccountLevelMOC_Mod 

	where AuthorisationStatus in('1A') AND  AccountEntityID=@AccountEntityID

	AND  EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey

	--AND SCREENFLAG <> ('U')
	and accountid=@AccountID  
	END

	

	PRINT '@AuthorisationStatus'

	PRINT @AuthorisationStatus



BEGIN TRY

/*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */





Declare @DateOfData	 as Date

	Set @DateOfData= (Select ExtDate from SysDataMatrix Where TimeKey=@TimeKey)

 

DROP TABLE IF EXISTS #ACCOUNT_PREMOC

PRINT 'AKSHAY2'

Select * 
INTO  #ACCOUNT_PREMOC 
from(
SELECT A.InvEntityId,A.InvID as AccountID,
A.RefIssuerID CustomerID
,'' FacilityType
,H.IssuerName as CustomerName
,0 as DFVAmt
,B.BookValue
,Interest_DividendDueAmount as InterestReceivable
,0 as AdditionalProvisionAbsolute
,'' as FLGFITL, c.StatusType as FraudAccountFlag,c.StatusDate as FraudDate,
	E.StatusType as TwoFlag,E.StatusDate as TwoDate,
@MocReason as MOCReason_1
	,H.UcifId as UCICID
	,@AuthorisationStatus as AuthorisationStatus,@CreatedBy as CreatedBy,
	@DateCreated as DateCreated,@ModifiedBy as ModifiedBy,
	@DateModified as DateModified,@ApprovedBy as ApprovedBy,
	@DateApproved as DateApproved
	,@MocSource  AS MOCSource
	,@ApprovedByFirstLevel as ApprovedByFirstLevel,
	@DateApprovedFirstLevel as DateApprovedFirstLevel
	,B.Interest_DividendDueAmount as POS
	,F.SourceName,0 as MOCReason	
 FROM          InvestmentBasicDetail A
 INNER join    InvestmentFinancialDetail B
 on            a.InvEntityid=b.InvEntityid 
 and			b.EffectiveFromTimeKey <=@TimeKey and b.EffectiveToTimeKey >=@TimeKey
 INNER JOIN    InvestmentIssuerDetail H
 ON            A.RefIssuerID=H.IssuerID   and H.EffectiveFromTimeKey <=@TimeKey and H.EffectiveToTimeKey >=@TimeKey
 left join  (select  CustomerID,ACID,StatusType,StatusDate from  ExceptionFinalStatusType
where StatusType='Fraud Committed'
  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) c
  on   a.InvID=c.ACID
  left join (select  CustomerID,ACID,StatusType,StatusDate from  ExceptionFinalStatusType
where StatusType='Restructure'
  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) D
  on   a.InvID=D.ACID
    left join (select  CustomerID,ACID,StatusType,StatusDate from  ExceptionFinalStatusType
where StatusType='TWO'
  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) E
 
  on   a.InvID=E.ACID

   Left Join DIMSOURCEDB F ON H.SourceAlt_KEy=F.SourceAlt_Key
 
where  A.InvEntityid=@AccountEntityID
and A.EffectiveFromTimeKey <=@TimeKey and A.EffectiveToTimeKey >=@TimeKey and a.InvId=@AccountID 
UNION
SELECT A.DerivativeEntityid,A.DerivativeRefNo as AccountID,
		A.CustomerId CustomerID
		,'' FacilityType
		,A.CustomerName
		,0 as DFVAmt
		,ISNULL((case when MTMIncomeAmt < 0 then 0 else MTMIncomeAmt end),0.00) as MTMValue
		,DueAmtReceivable as InterestReceivable
		,0 as AdditionalProvisionAbsolute
		,'' as FLGFITL, c.StatusType as FraudAccountFlag,c.StatusDate as FraudDate,
		E.StatusType as TwoFlag,E.StatusDate as TwoDate,
		@MocReason as MOCReason_1
		,A.UCIC_ID as UCICID
		,@AuthorisationStatus as AuthorisationStatus,@CreatedBy as CreatedBy,
		@DateCreated as DateCreated,@ModifiedBy as ModifiedBy,
		@DateModified as DateModified,@ApprovedBy as ApprovedBy,
		@DateApproved as DateApproved
		,@MocSource  AS MOCSource
		,@ApprovedByFirstLevel as ApprovedByFirstLevel,
		@DateApprovedFirstLevel as DateApprovedFirstLevel
		--,TwoFlag,TwoDate
		,A.POS as POS
		,A.SourceSystem
		,0 as MOCReason	
 FROM          curdat.DerivativeDetail A
 
 left join  (select  CustomerID,ACID,StatusType,StatusDate from  ExceptionFinalStatusType
where StatusType='Fraud Committed'
  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) c
  on   a.CustomerACID=c.ACID
  left join (select  CustomerID,ACID,StatusType,StatusDate from  ExceptionFinalStatusType
where StatusType='Restructure'
  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) D
  on   a.CustomerACID=D.ACID
    left join (select  CustomerID,ACID,StatusType,StatusDate from  ExceptionFinalStatusType
where StatusType='TWO'
  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) E
 
  on   a.CustomerACID=E.ACID 
where  A.DerivativeEntityID=@AccountEntityID
and A.EffectiveFromTimeKey <=@TimeKey and A.EffectiveToTimeKey >=@TimeKey
and A.DerivativeRefNo=@AccountID 

) X 


Update A
SET A.MOCReason=ISNULL(B.ParameterAlt_Key,0)
From #ACCOUNT_PREMOC A
Left JOIN 
(select ParameterAlt_Key ,
			 ParameterName 
			 ,'MOCReason' as TableName
			 from DimParameter
			 where 
			 EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey and
			  DimParameterName	= 'DimMOCReason') B
			  ON A.MOCReason_1 =B.ParameterName

----POST 



--Select '#ACCOUNT_PREMOC',* from #ACCOUNT_PREMOC



DROP TABLE IF EXISTS #ACCOUNT_POSTMOC



PRINT 'SWAPNA'

    SELECT AccountEntityID,AccountID as AccountID, 
	POS as POS  ,
	InterestReceivable as InterestReceivable,
	--RestructureFlag,RestructureDate,
	FITLFlag as FLGFITL,DFVAmount,

	AdditionalProvisionAbsolute,FraudAccountFlag as FraudAccountFlag,FraudDate,
	--RestructureFlag,RestructureDate,
	FlgTwo as TwoFlag,TwoDate as TwoDate,
	MocReason as MOCReason,TwoAmount,
	BookValue,Convert(Varchar(20),SMADate,103) as SMADate, SMASubAssetClassValue,
	Convert(Varchar(50),'') as UCICID,
	@AuthorisationStatus as AuthorisationStatus,
	@CreatedBy as CreatedBy,
	BookValue as BookValue_POS,
	Convert(Varchar(20),SMADate,103) as SMADate_POS, 
	SMASubAssetClassValue as SMASubAssetClassValue_POS,
	@DateCreated as DateCreated,@ModifiedBy as ModifiedBy,
	@DateModified as DateModified,@ApprovedBy as ApprovedBy,@DateApproved as DateApproved
	,@MocSource  AS MOCSource
	,@ApprovedByFirstLevel as ApprovedByFirstLevel,@DateApprovedFirstLevel as DateApprovedFirstLevel
	--,TwoFlag,TwoDate
	
	,'ACCT' MOC_TYPEFLAG

	INTO #ACCOUNT_POSTMOC

	FROM CalypsoAccountLevelMOC_Mod 

	--where AuthorisationStatus = CASE WHEN @OperationFlag =20 THEN '1A' ELSE 'MP' END
	where AuthorisationStatus in ('1A','MP','NP')
	AND  EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey AND AccountEntityID=@AccountEntityID
	--AND SCREENFLAG not in (CASE WHEN @OperationFlag in (16,20) THEN 'U' END)
	and AccountID=@accountid

IF NOT EXISTS(SELECT 1 FROM #ACCOUNT_POSTMOC WHERE  AccountEntityID=@AccountEntityID)

BEGIN
    INSERT  INTO  #ACCOUNT_POSTMOC

	 SELECT			B.InvEntityId,
					b.RefInvID as AccountID, 
					PrincOutStd as POS  ,
					unserviedint as InterestReceivable,
					FlgFITL as FLGFITL,A.DFVAmt,
					AddlProvAbs,FlgFraud as FraudAccountFlag,FraudDate,
					TwoFlag,TwoDate,a.BookValue, Convert(Varchar(20),SMADate,103) as SMADate, SMASubAssetClassValue,
					A.MOC_Reason as MOCReason,TwoAmount,
					Convert(Varchar(50),'') as UCICID,@AuthorisationStatus as AuthorisationStatus,@CreatedBy as CreatedBy,
					A.BookValue as BookValue_POS,Convert(Varchar(20),SMADate,103) as SMADate_POS, SMASubAssetClassValue as SMASubAssetClassValue_POS,
					@DateCreated as DateCreated,@ModifiedBy as ModifiedBy,@DateModified as DateModified,@ApprovedBy as ApprovedBy,@DateApproved as DateApproved
					,@MocSource  AS MOCSource
					,@ApprovedByFirstLevel as ApprovedByFirstLevel,@DateApprovedFirstLevel as DateApprovedFirstLevel				
					,'ACCT' MOC_TYPEFLAG
		FROM		CALYPSOINVMOC_CHANGEDETAILS A
		INNER JOIN	InvestmentFinancialDetail B
		ON			A.AccountEntityID=B.InvEntityId AND B.EffectiveFromTimeKey<=@TimeKey and B.EffectiveToTimeKey>=@TimeKey
		where		A.EffectiveFromTimeKey<=@TimeKey and A.EffectiveToTimeKey>=@TimeKey AND A.AccountEntityID=@AccountEntityID
		and			b.RefInvID=@AccountID 
		UNION

		
	 SELECT			B.DerivativeEntityID,
					b.DerivativeRefNo as AccountID, 
					POS as POS  ,
					unserviedint as InterestReceivable,
					FlgFITL as FLGFITL,A.DFVAmt,
					AddlProvAbs,FlgFraud as FraudAccountFlag,FraudDate,
					TwoFlag,TwoDate,BookValue, Convert(Varchar(20),SMADate,103) as SMADate, SMASubAssetClassValue,
					A.MOC_Reason as MOCReason,TwoAmount,
					Convert(Varchar(50),'') as UCICID,@AuthorisationStatus as AuthorisationStatus,@CreatedBy as CreatedBy,
					BookValue as BookValue_POS,Convert(Varchar(20),SMADate,103) as SMADate_POS, SMASubAssetClassValue as SMASubAssetClassValue_POS,
					@DateCreated as DateCreated,@ModifiedBy as ModifiedBy,@DateModified as DateModified,@ApprovedBy as ApprovedBy,@DateApproved as DateApproved
					,@MocSource  AS MOCSource
					,@ApprovedByFirstLevel as ApprovedByFirstLevel,@DateApprovedFirstLevel as DateApprovedFirstLevel				
					,'ACCT' MOC_TYPEFLAG
		FROM		CALYPSODervMOC_CHANGEDETAILS A
		INNER JOIN	curdat.DerivativeDetail B
		ON			A.AccountEntityID=B.DerivativeEntityID AND B.EffectiveFromTimeKey<=@TimeKey and B.EffectiveToTimeKey>=@TimeKey
		where		A.EffectiveFromTimeKey<=@TimeKey and A.EffectiveToTimeKey>=@TimeKey AND A.AccountEntityID=@AccountEntityID
		and b.DerivativeRefNo=@accountid 
END


	



BEGIN

			



         SELECT	
				A.AccountID
				,A.FacilityType
				,A.CustomerID
				,A.CustomerName				
				,A.UCICID
				,A.InterestReceivable				
				,(case when A.FLGFITL  IS NULL 
				       then 'No' 
					   when  A.FLGFITL='Y'
					   THEN 'Yes'
					   When  A.FLGFITL='N'
					  THEN 'No'					   
					    end)  FITLFlag

				,A.DFVAmt as DFVAmount

				,(case when A.FraudAccountFlag  IS NULL 
				       then 'No' 
					   when  A.FraudAccountFlag='Y'
					   THEN 'Yes'
					   When  A.FraudAccountFlag='N'
					   THEN 'No'					   
					    end)  FraudAccountFlag

				,Convert(Varchar(10),A.FraudDate,103) as FraudDate				
				,(case when A.TwoFlag  IS NULL 
				       then 'No' 
					   when  A.TwoFlag='Y'
					   THEN 'Yes'
					   When  A.TwoFlag='N'
					   THEN 'No'
					   
					    end)  TwoFlag
				,Convert(Varchar(10),A.TwoDate,103) as RePossessionDate
				,A.BookValue
				,A.MOCReason
				,A.MOCReason_1
				
				,A.MOCSource
			     ,A.AdditionalProvisionAbsolute
				 ,A.SourceName
		

				,B.FLGFITL			as FITLFlag_POS

				--,NULL				as FITLFlag_POS1

				,B.DFVAmount			as DFVAmount_POS
          	,B.FraudAccountFlag		as FraudAccountFlag_POS

				--,NULL                           as FraudAccountFlag_POS1

				, Convert(Varchar(10),B.FraudDate ,103)                   as FraudDate_POS
				
				,B.POS                     as POS_POS   ----new add 
				,B.InterestReceivable          as InterestReceivable_POS --new add
				,B.TwoFlag as TwoFlag_POS
				,Convert(Varchar(10),B.TwoDate ,103)   as TwoDate_POS
				,B.TwoAmount as TwoAmount_POS
				,b.BookValue_POS, Convert(Varchar(20),b.SMADate,103) as SMADate, b.SMASubAssetClassValue
				-- ,B.RestructureFlag 	as RestructureFlag_POS
				-- , Convert(Varchar(10),B.RestructureDate,103) 		as RestructureDate_POS
				,B.AuthorisationStatus
				,B.AdditionalProvisionAbsolute  AddlProvisionPer_POS
                  ,@Timekey as EffectiveFromTimeKey

                ,49999 as EffectiveToTimeKey

                ,A.CreatedBy
				,B.BookValue as BookValue_POS,Convert(Varchar(20),SMADate,103) as SMADate_POS, SMASubAssetClassValue as SMASubAssetClassValue_POS,

 A.DateCreated 

                ,A.ApprovedBy 

                ,A.DateApproved

         ,A.ModifiedBy 

                ,A.DateModified

				,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy

				,IsNull(A.DateModified,A.DateCreated)as CrModDate

				,ISNULL(A.ApprovedByFirstLevel,A.CreatedBy) as CrAppBy

				,ISNULL(A.DateApprovedFirstLevel,A.DateCreated) as CrAppDate

				,ISNULL(A.ApprovedByFirstLevel,A.ModifiedBy) as ModAppBy

				,ISNULL(A.DateApprovedFirstLevel,A.DateModified) as ModAppDate
				,B.AuthorisationStatus
	            ,B.ApprovedByFirstLevel
			
			    --,Convert(Varchar(10),MOC_ExpireDate,103)MOC_ExpireDate
				,'ACCT' AS MOC_TYPEFLAG
    , B.FraudDate as FraudDate_POS
	, 'Account' as TableName

FROM #ACCOUNT_PREMOC A

	LEFT JOIN #ACCOUNT_POSTMOC B

		on A.AccountID =b.AccountID
    






             END;



--END







PRINT 'Nitin'	



   IF OBJECT_ID('tempdb..#MOCAuthorisation') IS NOT NULL  

	  BEGIN  

	   DROP TABLE #MOCAuthorisation  

	  END





	  Select *,CAST('' AS varchar(MAX)) ErrorMessage,CAST('' AS varchar(MAX)) ErrorinColumn,CAST('' AS varchar(MAX)) Srnooferroneousrows

 	   into #MOCAuthorisation 

	   from CalypsoAccountLevelMOC_Mod A

	   	Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey

		and AccountID=@AccountID  and AccountID is not null

		   AND A.EntityKey IN

                     (

                         SELECT MAX(EntityKey)

                         FROM CalypsoAccountLevelMOC_Mod

WHERE EffectiveFromTimeKey <= @TimeKey

  AND EffectiveToTimeKey >= @TimeKey

         AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')

                         GROUP BY AccountID

                     )				



				

					

	   --Select ' #MOCAuthorisation',* from  #MOCAuthorisation

	   --where abc=1



	  UPDATE #MOCAuthorisation

	SET  

        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'You cannot perform MOC, Record is pending for authorization for this Account ID. Kindly authorize or Reject the record through Individual investment/derivative MOC – Authorization’ menu'     

						ELSE ErrorMessage+','+SPACE(1)+'You cannot perform MOC, Record is pending for authorization for this Account ID. Kindly authorize or Reject the record through ‘Individual investment/derivative MOC – Authorization’ menu'     END

		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'AccountID' ELSE   ErrorinColumn +','+SPACE(1)+'AccountID' END   

	

		FROM #MOCAuthorisation V  

  WHERE V.AuthorisationStatus in('NP','MP','DP','1A')

  AND AccountID=@AccountID

  AND @operationflag not in(16,17,20)



 



  UPDATE #MOCAuthorisation

	SET  

       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'You cannot perform MOC, Record is pending for authorization for this Customer ID. Kindly authorize or Reject the record through ‘Customer Level NPA MOC – Authorization’ menu'     

						ELSE ErrorMessage+','+SPACE(1)+'You cannot perform MOC, Record is pending for authorization for this Customer ID. Kindly authorize or Reject the record through ‘Customer Level NPA MOC – Authorization’ menu'     END

		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'CustomerID' ELSE   ErrorinColumn +','+SPACE(1)+'CustomerID' END   

		

		FROM CalypsoAccountLevelMOC_Mod V 

		inner join InvestmentBasicDetail X On V.AccountEntityID=X.InvEntityId

		Inner Join #MOCAuthorisation Z On X.INVID=Z.AccountID

		

  WHERE X.AuthorisationStatus in('NP','MP','DP','1A')

  AND @operationflag not in(16,17,20)  AND Z.AccountID=@AccountID

  


  UPDATE #MOCAuthorisation

	SET  

       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'You cannot perform MOC, Record is pending for authorization for this Customer ID. Kindly authorize or Reject the record through ‘Customer Level NPA MOC – Authorization’ menu'     

						ELSE ErrorMessage+','+SPACE(1)+'You cannot perform MOC, Record is pending for authorization for this Customer ID. Kindly authorize or Reject the record through ‘Customer Level NPA MOC – Authorization’ menu'     END

		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'CustomerID' ELSE   ErrorinColumn +','+SPACE(1)+'CustomerID' END   

		

		FROM CalypsoAccountLevelMOC_Mod V 

		inner join curdat.DerivativeDetail X On V.AccountEntityID=X.DerivativeEntityID

		Inner Join #MOCAuthorisation Z On X.DerivativeRefNo=Z.AccountID

		

  WHERE X.AuthorisationStatus in('NP','MP','DP','1A')

  AND @operationflag not in(16,17,20)  AND Z.AccountID=@AccountID


  IF EXISTS(SELECT 1 FROM #MOCAuthorisation WHERE AccountID=@AccountID --AND ISNULL(ERRORDATA,'')<>''

		) 

	BEGIN

	PRINT 'ERROR'

	if(@operationflag not in(16,17,20))

	begin

		SELECT distinct ErrorMessage

		ErrorinColumn,'Validation'TableName

		FROM #MOCAuthorisation

		END





END



   

   END TRY

	BEGIN CATCH

	

	INSERT INTO dbo.Error_Log

				SELECT ERROR_LINE() as ErrorLine,ERROR_MESSAGE()ErrorMessage,ERROR_NUMBER()ErrorNumber

				,ERROR_PROCEDURE()ErrorProcedure,ERROR_SEVERITY()ErrorSeverity,ERROR_STATE()ErrorState

				,GETDATE()



	SELECT ERROR_MESSAGE()

	--RETURN -1

   

	END CATCH




  

  

    END;


GO