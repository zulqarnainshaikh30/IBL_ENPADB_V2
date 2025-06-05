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
 
CREATE PROC [dbo].[AccountLevelSearchList]

--Declare

												

												--@PageNo         INT         = 1, 

													--@PageSize       INT         = 10, 

							

													

													--@PageNo         INT         = 1, 

													--@PageSize       INT         = 10, 

													@OperationFlag  INT        ,

													@AccountID	varchar(30)		,

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

SET @AccountEntityID =(SELECT AccountEntityId FROM AdvAcBasicDetail WHERE  CustomerACID=@AccountID 
                         AND  EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey )

IF @OperationFlag NOT IN (16,20)

BEGIN
	SELECT  

	@CreatedBy=CreatedBy,@MocReason=MocReason,

	@DateCreated=DateCreated,@ModifiedBy=ModifyBy,@DateModified=DateModified,@ApprovedBy=ApprovedBy,@DateApproved=DateApproved,

	@AuthorisationStatus=AuthorisationStatus	,@MocSource=MOCSource
	,@ApprovedByFirstLevel=ApprovedByFirstLevel,@DateApprovedFirstLevel=DateApprovedFirstLevel,
	@MOC_TYPEFLAG=MOC_TYPEFLAG

	FROM AccountLevelMOC_Mod 
	
	where AuthorisationStatus in('MP','1A','A') AND AccountEntityID=@AccountEntityID

	AND  EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey

	--AND  Entitykey in (select max(Entitykey) FROM AccountLevelMOC_Mod 

	--where AuthorisationStatus in('MP','1A','A') AND AccountID=@AccountId

	--AND  EffectiveFromTimeKey=@Timekey and EffectiveToTimeKey=@Timekey )
	
	END

		if @OperationFlag  = '16'

	BEGIN

	SELECT  

	@CreatedBy=CreatedBy,@MocReason=MocReason,

	@DateCreated=DateCreated,@ModifiedBy=ModifyBy,@DateModified=DateModified,@ApprovedBy=ApprovedBy,@DateApproved=DateApproved,

	@AuthorisationStatus=AuthorisationStatus	,@MocSource=MOCSource
	,@ApprovedByFirstLevel=ApprovedByFirstLevel,@DateApprovedFirstLevel=DateApprovedFirstLevel
	,@MOC_TYPEFLAG=MOC_TYPEFLAG

	FROM AccountLevelMOC_Mod 

	where AuthorisationStatus in('MP') AND  AccountEntityID=@AccountEntityID

	AND  EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey

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

	FROM AccountLevelMOC_Mod 

	where AuthorisationStatus in('1A') AND  AccountEntityID=@AccountEntityID

	AND  EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey

	--AND SCREENFLAG <> ('U')

	END

	

	PRINT '@AuthorisationStatus'

	PRINT @AuthorisationStatus



BEGIN TRY

/*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */





Declare @DateOfData	 as Date

	Set @DateOfData= (Select ExtDate from SysDataMatrix Where TimeKey=@TimeKey)

 

DROP TABLE IF EXISTS #ACCOUNT_PREMOC

PRINT 'AKSHAY2'

Select * INTO  #ACCOUNT_PREMOC from(

SELECT A.AccountEntityId,A.CustomerACID as AccountID,
A.RefCustomerId CustomerID
,A.FacilityType
,H.CustomerName
--,CustomerEntityID as CustomerEntityID
--,POS as Balance
,B.DFVAmt
,InterestReceivable as InterestReceivable
,0 as AdditionalProvisionAbsolute
--,FlgRestructure as RestructureFlag,RestructureDate
,'' as FLGFITL, c.StatusType as FraudAccountFlag,c.StatusDate as FraudDate,

	--D.StatusType as RestructureFlag,D.StatusDate as RestructureDate,
	E.StatusType as TwoFlag,E.StatusDate as TwoDate,
	

--,FlgMoc
@MocReason as MOCReason_1

	,H.UCIF_ID as UCICID
	,@AuthorisationStatus as AuthorisationStatus,@CreatedBy as CreatedBy,

	@DateCreated as DateCreated,@ModifiedBy as ModifiedBy,@DateModified as DateModified,@ApprovedBy as ApprovedBy,@DateApproved as DateApproved
	,@MocSource  AS MOCSource
	,@ApprovedByFirstLevel as ApprovedByFirstLevel,@DateApprovedFirstLevel as DateApprovedFirstLevel
	--,TwoFlag,TwoDate
	,B.PrincipalBalance as POS
	,F.SourceName,0 as MOCReason
	

 FROM          AdvAcBasicDetail A
 INNER join    AdvAcBalanceDetail B
 on            a.AccountEntityId=b.AccountEntityId 
 and b.EffectiveFromTimeKey <=@TimeKey and b.EffectiveToTimeKey >=@TimeKey
 INNER JOIN    CustomerBasicDetail H
 ON            A.RefCustomerId=H.CustomerId   and H.EffectiveFromTimeKey <=@TimeKey and H.EffectiveToTimeKey >=@TimeKey
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

   Left Join DIMSOURCEDB F ON A.SourceAlt_Key=F.SourceAlt_Key
   
  

--AND  A.EffectiveFromTimeKey<=@TimeKey and A.EffectiveToTimeKey>=@TimeKey 
where  A.AccountEntityId=@AccountEntityID
and A.EffectiveFromTimeKey <=@TimeKey and A.EffectiveToTimeKey >=@TimeKey


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

	Convert(Varchar(50),'') as UCICID,@AuthorisationStatus as AuthorisationStatus,@CreatedBy as CreatedBy,

	@DateCreated as DateCreated,@ModifiedBy as ModifiedBy,@DateModified as DateModified,@ApprovedBy as ApprovedBy,@DateApproved as DateApproved
	,@MocSource  AS MOCSource
	,@ApprovedByFirstLevel as ApprovedByFirstLevel,@DateApprovedFirstLevel as DateApprovedFirstLevel
	--,TwoFlag,TwoDate
	
	,'ACCT' MOC_TYPEFLAG

	INTO #ACCOUNT_POSTMOC

	FROM AccountLevelMOC_Mod 

	--where AuthorisationStatus = CASE WHEN @OperationFlag =20 THEN '1A' ELSE 'MP' END
	where AuthorisationStatus in ('1A','MP','NP')
	AND  EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey AND AccountEntityID=@AccountEntityID
	--AND SCREENFLAG not in (CASE WHEN @OperationFlag in (16,20) THEN 'U' END)


IF NOT EXISTS(SELECT 1 FROM #ACCOUNT_POSTMOC WHERE  AccountEntityID=@AccountEntityID)

BEGIN
    INSERT  INTO  #ACCOUNT_POSTMOC

	 SELECT B.AccountEntityID,b.RefSystemAcId as AccountID, 
	PrincOutStd as POS  ,
	unserviedint as InterestReceivable,
	--RestructureFlag,RestructureDate,
	FlgFITL as FLGFITL,A.DFVAmt,

	AddlProvAbs,FlgFraud as FraudAccountFlag,FraudDate,
	--FlgRestructure,RestructureDate,
	TwoFlag,TwoDate,
	MOC_Reason as MOCReason,TwoAmount,

	Convert(Varchar(50),'') as UCICID,@AuthorisationStatus as AuthorisationStatus,@CreatedBy as CreatedBy,

	@DateCreated as DateCreated,@ModifiedBy as ModifiedBy,@DateModified as DateModified,@ApprovedBy as ApprovedBy,@DateApproved as DateApproved
	,@MocSource  AS MOCSource
	,@ApprovedByFirstLevel as ApprovedByFirstLevel,@DateApprovedFirstLevel as DateApprovedFirstLevel
	--,TwoFlag,TwoDate
	
	,'ACCT' MOC_TYPEFLAG
	 FROM MOC_ChangeDetails A
		INNER JOIN AdvAcBalanceDetail B
		ON         A.AccountEntityID=B.AccountEntityID AND B.EffectiveFromTimeKey<=@TimeKey and B.EffectiveToTimeKey>=@TimeKey
		where A.EffectiveFromTimeKey<=@TimeKey and A.EffectiveToTimeKey>=@TimeKey AND A.AccountEntityID=@AccountEntityID

END


	

	--Drop Table  ACCOUNT_POSTMOC_HIST 

--IF NOT EXISTS(SELECT 1 FROM #ACCOUNT_POSTMOC WHERE AccountID=@AccountId)

--BEGIN



--	INSERT  INTO  #ACCOUNT_POSTMOC

--	SELECT AccountEntityId,CustomerACID as AccountID,CustomerEntityID as CustomerEntityID,Balance,unserviedint as InterestReceivable,FlgRestructure as RestructureFlag,RestructureDate,FLGFITL,DFVAmt,RePossession as RePossessionFlag,

--    RepossessionDate,WeakAccount as WeakAccountFlag,WeakAccountDate,Sarfaesi as SarfaesiFlag,SarfaesiDate,FlgUnusualBounce as UnusualBounceflag,UnusualBounceDate,FlgUnClearedEffect as UnClearedEffectFlag,

--    UnClearedEffectDate,AddlProvision as AdditionalProvisionAbsolute,FlgFraud as FraudAccountFlag,FraudDate,BenamiLoansFlag,MarkBenamiDate,SubLendingFlag,
--	MarkSubLendingDate,AbscondingFlag,MarkAbscondingDate,
--	FlgMoc,@MocReason as MOCReason,



--	UCIF_ID as UCICID,@AuthorisationStatus as AuthorisationStatus,@CreatedBy as CreatedBy,

--	@DateCreated as DateCreated,@ModifiedBy as ModifiedBy,@DateModified as DateModified,@ApprovedBy as ApprovedBy,@DateApproved as DateApproved
--	,@MocSource  AS MOCSource
--	,@ApprovedByFirstLevel as ApprovedByFirstLevel,@DateApprovedFirstLevel as DateApprovedFirstLevel
--	,TwoFlag,TwoDate,PrincOutStd
	

--	FROM   [Pro].[ACCOUNTCAL_HIST]

--	WHERE EffectiveFromTimeKey=@TimeKey and EffectiveToTimeKey=@TimeKey and isnull(FlgMoc,'N')='Y'

--	AND CustomerACID=@AccountId 
	
--	--and  ISNULL(ScreenFlag,'')<>'U'

--END

	--Select '#ACCOUNT_POSTMOC' ,* from #ACCOUNT_POSTMOC





BEGIN

			



         SELECT	

				A.AccountID

				,A.FacilityType
				,A.CustomerID
				--,A.Balance as POS
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
				--,(case when A.RestructureFlag  IS NULL 
				--       then 'No' 
				--	   when  A.RestructureFlag='Y'
				--	   THEN 'Yes'
				--	   When  A.RestructureFlag='N'
				--	   THEN 'No'
					   
				--	    end)  RestructureFlag
				--,Convert(Varchar(10),A.RestructureDate,103) as RestructureDate
				,(case when A.TwoFlag  IS NULL 
				       then 'No' 
					   when  A.TwoFlag='Y'
					   THEN 'Yes'
					   When  A.TwoFlag='N'
					   THEN 'No'
					   
					    end)  TwoFlag
				,Convert(Varchar(10),A.TwoDate,103) as RePossessionDate
				
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
				-- ,B.RestructureFlag 	as RestructureFlag_POS
				-- , Convert(Varchar(10),B.RestructureDate,103) 		as RestructureDate_POS
				,B.AuthorisationStatus
				,B.AdditionalProvisionAbsolute  AddlProvisionPer_POS
                  ,@Timekey as EffectiveFromTimeKey

                ,49999 as EffectiveToTimeKey

                ,A.CreatedBy

 ,A.DateCreated 

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
    --LEFT JOIN  [Pro].[CustomerCal_Hist] C ON A.AccountID =C.

	   --AND  c.EffectiveFromTimeKey<=@TimeKey and c.EffectiveToTimeKey>=@TimeKey 

	--LEFT Join (

	--					Select ParameterShortNameEnum as ParameterAlt_Key,ParameterName,'SARFAESIFlag' as Tablename 

	--					from DimParameter where DimParameterName='DimYesNo'

	--					And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)F

	--					ON F.ParameterAlt_Key=A.SARFAESIFlag



	--	LEFT join (select ACID,StatusType,StatusDate, 'SARFAESIDate' as TableName

	--					from ExceptionFinalStatusType where StatusType like '%SARFAESI%'

	--					AND EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) K

	--					ON A.AccountID=K.ACID	

						

	--	LEFT Join (

	--					Select ParameterShortNameEnum as ParameterAlt_Key,ParameterName,'FITLFlag' as Tablename 

	--					from DimParameter where DimParameterName='DimYesNo'

	--					And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)C

	--					ON C.ParameterAlt_Key=A.FLGFITL



	--	LEFT Join (Select ParameterShortNameEnum as ParameterAlt_Key,ParameterName,'RePossessionFlag' as Tablename 

	--					from DimParameter where DimParameterName='DimYesNo'

	--					And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)D

	--					ON D.ParameterAlt_Key=A.RePossessionFlag









             END;



--END







PRINT 'Nitin'	



   IF OBJECT_ID('tempdb..#MOCAuthorisation') IS NOT NULL  

	  BEGIN  

	   DROP TABLE #MOCAuthorisation  

	  END





	  Select *,CAST('' AS varchar(MAX)) ErrorMessage,CAST('' AS varchar(MAX)) ErrorinColumn,CAST('' AS varchar(MAX)) Srnooferroneousrows

 	   into #MOCAuthorisation 

	   from AccountLevelMOC_Mod A

	   	Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey

		and AccountID=@AccountID  and AccountID is not null

		   AND A.EntityKey IN

                     (

                         SELECT MAX(EntityKey)

                         FROM AccountLevelMOC_Mod

WHERE EffectiveFromTimeKey <= @TimeKey

  AND EffectiveToTimeKey >= @TimeKey

         AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')

                         GROUP BY AccountID

                     )				



				

					

	   --Select ' #MOCAuthorisation',* from  #MOCAuthorisation

	   --where abc=1



	  UPDATE #MOCAuthorisation

	SET  

        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'You cannot perform MOC, Record is pending for authorization for this Account ID. Kindly authorize or Reject the record through ‘Account Level NPA MOC – Authorization’ menu'     

						ELSE ErrorMessage+','+SPACE(1)+'You cannot perform MOC, Record is pending for authorization for this Account ID. Kindly authorize or Reject the record through ‘Accout Level NPZ MOC – Authorization’ menu'     END

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

		

		FROM CustomerLevelMOC_Mod V 

		inner join AdvAcBasicDetail X On V.CustomerEntityId=X.CustomerEntityId

		Inner Join #MOCAuthorisation Z On X.CustomerACID=Z.AccountID

		

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