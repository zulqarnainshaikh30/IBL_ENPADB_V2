SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO




--USE [USFB_ENPADB]
--GO
--/****** Object:  StoredProcedure [dbo].[CustomerLevelNPAMOCSearchList]    Script Date: 18-11-2021 13:33:01 ******/
--DROP PROCEDURE [dbo].[CustomerLevelNPAMOCSearchList]
--GO
--/****** Object:  StoredProcedure [dbo].[CustomerLevelNPAMOCSearchList]    Script Date: 18-11-2021 13:33:01 ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO


---- exec CustomerLevelNPAMOCSearchList @CustomerID=N'84',@OperationFlag=2

----go



--sp_helptext CustomerLevelNPAMOCSearchList



-------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



















--exec CustomerLevelNPAMOCSearchList @CustomerID=N'84',@OperationFlag=2

--go












--exec CustomerLevelNPAMOCSearchList @CustomerID=N'84',@OperationFlag=2

--go







--SELECT Top 100 * FROM [PRO].[CustomerCal_Hist]	where RefCustomerID ='95'

--And EffectiveFromTimeKey=25992 AND EffectiveToTimeKey=25992


--Exec [CustomerLevelNPAMOCfH.MOCSourceAltKeySearchList] @OperationFlag =, @CustomerID='161760505'		--Main screen select

--MOCSource

--MOCSourceAltKey

--exec CustomerLevelNPAMOCSearchList_Backup_14052021_1 @CustomerID=N'90',@OperationFlag=2

CREATE PROC [dbo].[CustomerLevelNPAMOCSearchList]

--Declare



@OperationFlag  INT         = 2,

@CustomerID	varchar(20)		='84',

@TimeKey INT                =25841

AS

     

BEGIN



SET NOCOUNT ON;

 --SET @Timekey =(Select TimeKey from SysDataMatrix where CurrentStatus='C') 



 -- SET @Timekey =(Select LastMonthDateKey from SysDayMatrix where Timekey=@Timekey) 

 
	SET @Timekey =(Select Timekey from SysDataMatrix Where MOC_Initialised='Y' AND ISNULL(MOC_Frozen,'N')='N') 



  --Select @Timekey




Declare @MOCSourceAltkey Int

Declare @CreatedBy Varchar(50)

Declare @DateCreated Date

Declare @ModifiedBy Varchar(50)

Declare @DateModified Date

Declare @ApprovedBy Varchar(50)

Declare @DateApproved Date

Declare @AuthorisationStatus Varchar(5)

Declare @MocReason Varchar(50)

Declare @ApprovedByFirstLevel	varchar(100)
Declare @DateApprovedFirstLevel	date
Declare @MOC_ExpireDate date
DECLARE @MOC_TYPEFLAG varchar(4)

IF @OperationFlag NOT IN (16,20)

BEGIN
--,@MOC_ExpireDate=MOC_ExpireDate
SELECT  Distinct 

	@MocReason=MocReason,@MOCSourceAltkey=MOCSourceAltkey,@CreatedBy=CreatedBy,

	@DateCreated=DateCreated,@ModifiedBy=ModifiedBy,@DateModified=DateModified,@ApprovedBy=ApprovedBy,@DateApproved=DateApproved,

	@AuthorisationStatus=AuthorisationStatus,@ApprovedByFirstLevel=ApprovedByFirstLevel,
	@DateApprovedFirstLevel=DateApprovedFirstLevel,@MOC_TYPEFLAG=MOCType_Flag

	FROM CustomerLevelMOC_Mod 

	where AuthorisationStatus in('MP','NP','1A','A') AND CUSTOMERID=@CustomerID

	AND  EffectiveFromTimeKey<=@Timekey and EffectiveToTimeKey>=@Timekey 

	--AND  Entity_key in (select max(Entity_key) FROM CustomerLevelMOC_Mod 

	--where AuthorisationStatus in('MP','1A','A') AND CUSTOMERID=@CustomerID

	--AND  EffectiveFromTimeKey=@Timekey and EffectiveToTimeKey=@Timekey )

	end

	if @OperationFlag  = '16'

	BEGIN
	--,@MOC_ExpireDate=MOC_ExpireDate
	SELECT  

	@MocReason=MocReason,@MOCSourceAltkey=MOCSourceAltkey,@CreatedBy=CreatedBy,

	@DateCreated=DateCreated,@ModifiedBy=ModifiedBy,@DateModified=DateModified,@ApprovedBy=ApprovedBy,@DateApproved=DateApproved,

	@AuthorisationStatus=AuthorisationStatus,@ApprovedByFirstLevel=ApprovedByFirstLevel,
	@DateApprovedFirstLevel=DateApprovedFirstLevel,@MOC_TYPEFLAG=MOCType_Flag

	FROM CustomerLevelMOC_Mod 

	where AuthorisationStatus in('MP','NP') AND CUSTOMERID=@CustomerID

	AND  EffectiveFromTimeKey<=@Timekey and EffectiveToTimeKey>=@Timekey 

	--AND SCREENFLAG <> ('U')

	end

	if @OperationFlag = '20'
	--,@MOC_ExpireDate=MOC_ExpireDate
BEGIN

	SELECT  Distinct

	@MocReason=MocReason,@MOCSourceAltkey=MOCSourceAltkey,@CreatedBy=CreatedBy,

	@DateCreated=DateCreated,@ModifiedBy=ModifiedBy,@DateModified=DateModified,@ApprovedBy=ApprovedBy,@DateApproved=DateApproved,

	@AuthorisationStatus=AuthorisationStatus,@ApprovedByFirstLevel=ApprovedByFirstLevel,
	@DateApprovedFirstLevel=DateApprovedFirstLevel,@MOC_TYPEFLAG=MOCType_Flag

	FROM CustomerLevelMOC_Mod 

	where AuthorisationStatus in('1A') AND CUSTOMERID=@CustomerID

	AND  EffectiveFromTimeKey<=@Timekey and EffectiveToTimeKey>=@Timekey 

	--AND SCREENFLAG <> ('U')

	end
	

	PRINT @TimeKey

	PRINT '@AuthorisationStatus'

	PRINT @AuthorisationStatus

BEGIN TRY

	---PRE MOC



	
	Declare @DateOfData	 as DateTime

	Set @DateOfData= (Select CAST(B.Date as Date)Date1 from SysDataMatrix A

Inner Join SysDayMatrix B ON A.TimeKey=B.TimeKey

 where A.CurrentStatus='C')

 

DROP TABLE IF EXISTS #CUST_PREMOC


PRINT 'Prashant'
Select * 

INTO  #CUST_PREMOC 

from(


SELECT  B.CustomerEntityId,B.CustomerID ,B.CustomerName,
case when A.Cust_AssetClassAlt_Key is null then 1 else A.Cust_AssetClassAlt_Key end AssetClassAlt_Key,A.NPADt,V.security_value  SecurityValue,

	B.UCIF_ID as UCICID, 0 as AdditionalProvision
	--,@AuthorisationStatus as AuthorisationStatus,@MocReason as MocReason,@MOCSourceAltkey as MOCSourceAltkey,@CreatedBy as CreatedBy,

	--@DateCreated as DateCreated,@ModifiedBy as ModifiedBy,@DateModified as DateModified,@ApprovedBy as ApprovedBy,@DateApproved as DateApproved
	--,@ApprovedByFirstLevel as ApprovedByFirstLevel,@DateApprovedFirstLevel as DateApprovedFirstLevel

 FROM  CustomerBasicDetail B
 left join  curdat.AdvCustNpaDetail A
		ON         A.CustomerEntityID=B.CustomerEntityId AND A.EffectiveFromTimeKey<=@TimeKey and A.EffectiveToTimeKey>=@TimeKey
LEFT JOIN (select        a.CustomerId,sum(c.CurrentValue) security_value
from          CustomerBasicDetail a
LEFT join    CurDat.AdvSecurityDetail b
on            a.CustomerEntityId=b.CustomerEntityId
and           b.EffectiveFromTimeKey<=@timekey and b.EffectiveToTimeKey>=@timekey 
LEFT join   curdat.AdvSecurityValueDetail c
on            b.SecurityEntityID=c.SecurityEntityID
and           c.EffectiveFromTimeKey<=@timekey and c.EffectiveToTimeKey>=@timekey 
where         a.EffectiveFromTimeKey<=@timekey and a.EffectiveToTimeKey>=@timekey 
and           a.CustomerId=@customerid   
group by      a.CustomerId
                                       ) V
ON            B.CustomerId=V.CustomerId
where B.EffectiveFromTimeKey<=@TimeKey and B.EffectiveToTimeKey>=@TimeKey AND  B.CustomerID=@CustomerID

		

) X 



----POST 

---Added By Mandeep to show MOCReason (21-03-2023)
SET @MocReason=(SELECT PARAMETERALT_KEY FROM DimParameter WHERE EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey and
			  DimParameterName	= 'DimMOCReason' and ParameterName=@MocReason)
--Select '#CUST_PREMOC',* from #CUST_PREMOC

PRINT 'jaydev'
DROP TABLE IF EXISTS #CUST_POSTMOC

	SELECT *
	INTO #CUST_POSTMOC
	FROM (
	--FROM CustomerLevelMOC_Mod 
	
	--where AuthorisationStatus = CASE WHEN @OperationFlag =20 THEN '1A' ELSE 'MP' END

	--AND  EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey AND CUSTOMERID=@CustomerID 

	--AND SCREENFLAG not in (CASE WHEN @OperationFlag in (16,20) THEN 'U' END)

	--SELECT   A.CustomerEntityID,CustomerID ,CustomerName,AssetClassAlt_Key, A.NPA_Date,A.CurntQtrRv SecurityValue,B.UCIF_ID as UCICID,

	--@AuthorisationStatus as AuthorisationStatus,@MocReason as MocReason,@MOCSourceAltkey as MOCSourceAltkey,@CreatedBy as CreatedBy,

	--@DateCreated as DateCreated,@ModifiedBy as ModifiedBy,@DateModified as DateModified,@ApprovedBy as ApprovedBy,

	--@DateApproved as DateApproved,@ApprovedByFirstLevel as ApprovedByFirstLevel,
	--@DateApprovedFirstLevel as DateApprovedFirstLevel,@MOC_ExpireDate MOC_ExpireDate,@MOC_TYPEFLAG MOCType_Flag
 --   FROM MOC_ChangeDetails A
	--INNER JOIN  CURDAT.CustomerBasicDetail B
	--ON          A.CustomerEntityID=B.CustomerEntityId
	--AND         B.EffectiveFromTimeKey<=@TimeKey and B.EffectiveToTimeKey>=@TimeKey 
	--WHERE       A.EffectiveFromTimeKey<=@TimeKey and A.EffectiveToTimeKey>=@TimeKey AND B.CUSTOMERID=@CustomerID 
	-- AND        A.AuthorisationStatus='A'

	--UNION
    
		SELECT   A.CustomerEntityID,B.CustomerId ,B.CustomerName,AssetClassAlt_Key, A.NPADate,A.SecurityValue SecurityValue,
		B.UCIF_ID as UCICID, A.AdditionalProvision,

	@AuthorisationStatus as AuthorisationStatus,@MocReason as MocReason,@MOCSourceAltkey as MOCSourceAltkey,@CreatedBy as CreatedBy,

	@DateCreated as DateCreated,@ModifiedBy as ModifiedBy,@DateModified as DateModified,@ApprovedBy as ApprovedBy,

	@DateApproved as DateApproved,@ApprovedByFirstLevel as ApprovedByFirstLevel,
	@DateApprovedFirstLevel as DateApprovedFirstLevel,@MOC_ExpireDate MOC_ExpireDate,@MOC_TYPEFLAG MOCType_Flag,case when MOCTYPE = 'Auto' then 1 else 2 end  MOCTypeAlt_Key
	--A.MOCType as MOCTypeAlt_Key commented By Mandeep
    FROM CustomerLevelMOC_Mod A
	INNER JOIN  CURDAT.CustomerBasicDetail B
	ON          A.CustomerEntityID=B.CustomerEntityId
	AND         B.EffectiveFromTimeKey<=@TimeKey and B.EffectiveToTimeKey>=@TimeKey 
	WHERE       A.EffectiveFromTimeKey<=@TimeKey and A.EffectiveToTimeKey>=@TimeKey AND B.CUSTOMERID=@CustomerID
	AND         A.AuthorisationStatus = CASE WHEN @OperationFlag =20 THEN '1A' ELSE 'MP' END
	)P



IF NOT EXISTS(SELECT 1 FROM #CUST_POSTMOC WHERE CUSTOMERID=@CustomerID)

BEGIN
PRINT 'swapna'
	INSERT  INTO  #CUST_POSTMOC

	--SELECT CustomerEntityId,RefCustomerID CustomerID,CustomerName,SysAssetClassAlt_Key AssetClassAlt_Key,SysNPA_Dt NPADate,CurntQtrRv  SecurityValue,

	--UCIF_ID as UCICID,ScreenFlag,@AuthorisationStatus as AuthorisationStatus,@MocReason as MocReason,@MOCSourceAltkey as MOCSourceAltkey,@CreatedBy as CreatedBy,

	--@DateCreated as DateCreated,@ModifiedBy as ModifiedBy,@DateModified as DateModified,@ApprovedBy as ApprovedBy,@DateApproved as DateApproved
	--,@ApprovedByFirstLevel as ApprovedByFirstLevel,@DateApprovedFirstLevel as DateApprovedFirstLevel
	--FROM   [Pro].[CustomerCal_Hist] 
--
	--WHERE EffectiveFromTimeKey=@TimeKey and EffectiveToTimeKey=@TimeKey and isnull(FlgMoc,'N')='Y'

	--AND RefCustomerID=@CustomerID 

		SELECT B.CustomerEntityId,B.CustomerId,B.CustomerName,A.AssetClassAlt_Key,A.NPA_Date,A.CurntQtrRv  SecurityValue,

	B.UCIF_ID as UCICID,AddlProvPer as AdditionalProvision,@AuthorisationStatus as AuthorisationStatus,@MocReason as MocReason,
	@MOCSourceAltkey as MOCSourceAltkey,@CreatedBy as CreatedBy,

	@DateCreated as DateCreated,@ModifiedBy as ModifiedBy,@DateModified as DateModified,@ApprovedBy as ApprovedBy,
	@DateApproved as DateApproved
	,@ApprovedByFirstLevel as ApprovedByFirstLevel,@DateApprovedFirstLevel as DateApprovedFirstLevel,
	@MOC_ExpireDate MOC_ExpireDate,@MOC_TYPEFLAG MOCType_Flag,case when MOCTYPE = 'Auto' then 1 else 2 end  MOCTypeAlt_Key
	 FROM MOC_ChangeDetails A
		INNER JOIN CURDAT.CustomerBasicDetail B
		ON         A.CustomerEntityID=B.CustomerEntityId AND B.EffectiveFromTimeKey<=@TimeKey and B.EffectiveToTimeKey>=@TimeKey
		where A.EffectiveFromTimeKey<=@TimeKey and A.EffectiveToTimeKey>=@TimeKey AND  B.CustomerID=@CustomerID
		AND MOCType_Flag='CUST'
--	and isnull(FlgMoc,'N')='Y'


END

	PRINT 'Sudesh'


SELECT 



	a.CustomerID CustomerId
	
	,a.CustomerName

	,C.AssetClassName AssetClass	

	,a.NPADt NPADate

	,a.SecurityValue	

	,a.AdditionalProvision

	,d.AssetClassName AssetClass_Pos	

	,B.NPADate	NPADate_Pos

	,B.SecurityValue SecurityValue_Pos	

	,B.AdditionalProvision AdditionalProvision_Pos

	,A.UCICID as UCICID

	,d.AssetClassAlt_Key as AssetClassAlt_Key_Pos

	--,NULL as FraudAccountFlag

	--,F.STATUSTYPE as FraudAccountFlag_Pos

	--,H.FraudAccountFlagAlt_Key AS FraudAccountFlagAlt_Key

	--,convert(varchar(20),F.STATUSDATE,103) FraudDate	

	--,H.FraudDate as FraudDate_Pos

	--,B.MOCType as MOCType

	,B.MOCReason

	--,B.MOCTypeAlt_Key                  

	--,Y.MOCTypeName as MOCSource

	,B.MOCSourceAltKey

	--,X.TotalOSBalance

	--,X.TotalInterestReversal

	--,X.TotalPrincOSBalance

	--,X.TotalInterestReceivabl

	--,X.TotalProvision

,IsNull(B.ModifiedBy,B.CreatedBy)as CrModBy
,IsNull(B.DateModified,B.DateCreated)as CrModDate
,ISNULL(B.ApprovedByFirstLevel,B.CreatedBy) as CrAppBy
,ISNULL(B.DateApprovedFirstLevel,B.DateCreated) as CrAppDate
,ISNULL(B.ApprovedByFirstLevel,B.ModifiedBy) as ModAppBy
,ISNULL(B.DateApprovedFirstLevel,B.DateModified) as ModAppDate		

	, B.ModifiedBy		

	,B.AuthorisationStatus
	,B.ApprovedByFirstLevel
	,B.DateApprovedFirstLevel

	,convert(varchar(20),@DateOfData,103) DateOfData
	--,B.MOC_ExpireDate
	,B.MOCType_Flag
	,B.MOCTypeAlt_Key
FROM #CUST_PREMOC A

	LEFT JOIN #CUST_POSTMOC B

		on A.CustomerID =b.CustomerID

	LEFT JOIN DimAssetClass c

		ON C.AssetClassAlt_Key=a.AssetClassAlt_Key

		and c.EffectiveFromTimeKey<=@TimeKey and c.EffectiveToTimeKey>=@TimeKey 

	LEFT JOIN DimAssetClass d

		ON d.AssetClassAlt_Key=b.AssetClassAlt_Key

		and d.EffectiveFromTimeKey<=@TimeKey and d.EffectiveToTimeKey>=@TimeKey
 
 --SELECT * FROM CURDAT.AdvAcBalanceDetail
	--left Join (	SELECT  RefCustomerId,

	--					EffectiveFromTimeKey,

	--											EffectiveToTimeKey ,

	--											SUM(T.Balance) As TotalOSBalance, 

	--											Sum(T.IntReverseAmt)as TotalInterestReversal,

	--											0 as TotalPrincOSBalance ,

	--											0 as TotalInterestReceivabl,

	--											Sum(T.TotalProv) as TotalProvision

	--										 --FROM PRO.AccountCal_Hist as T
	--										 FROM CURDAT.AdvAcBalanceDetail T
	--										 Where RefCustomerId=@CustomerID

	--										 AND EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey

	--										Group by T.RefCustomerId,T.EffectiveFromTimeKey,T.EffectiveToTimeKey 

	--								)	X

	--									On X.RefCustomerId=A.CustomerID




IF OBJECT_ID('tempdb..#MOCAuthorisation') IS NOT NULL  

BEGIN  

	DROP TABLE #MOCAuthorisation  

END





	  Select *,CAST('' AS varchar(MAX)) ErrorMessage,CAST('' AS varchar(MAX)) ErrorinColumn,
	    CAST('' AS varchar(MAX)) Srnooferroneousrows

 	   into #MOCAuthorisation 

	   from CustomerLevelMOC_mod A

	   where A.CustomerID=@CustomerID

	   AND A.EffectiveFromTimeKey<=@Timekey And A.EffectiveToTimeKey>=@Timekey

	   AND CustomerId is not null



	    AND A.Entity_Key IN

                     (

                         SELECT MAX(Entity_Key)

                         FROM CustomerLevelMOC_MOD

                         WHERE EffectiveFromTimeKey <= @TimeKey

                               AND EffectiveToTimeKey >= @TimeKey

                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')

                         GROUP BY CustomerID

                     )

	   --Select ' #MOCAuthorisation',* from  #MOCAuthorisation

	   --where abc=1



	  UPDATE #MOCAuthorisation

	SET  

        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'You cannot perform MOC, Record is pending for authorization for this Customer ID. Kindly authorize or Reject the record through ‘Customer Level MOC – Authorization’ menu'     

						ELSE ErrorMessage+','+SPACE(1)+'You cannot perform MOC, Record is pending for authorization for this Customer ID. Kindly authorize or Reject the record through ‘Customer Level MOC – Authorization’ menu'     END

		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'CustomerID' ELSE   ErrorinColumn +','+SPACE(1)+'CustomerID' END   

	    

		FROM #MOCAuthorisation V  

  WHERE V.AuthorisationStatus in('NP','MP','DP','1A')

  AND CustomerID=@CustomerID

  AND @Operationflag not in(16,17,20)







  UPDATE #MOCAuthorisation

	SET  

        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'You cannot perform MOC, Record is pending for authorization for an Account ID '+A.AccountId+' under this Customer ID. Kindly authorize or Reject the record through ‘Account Level MOC – Author




ization’ menu'     

						ELSE ErrorMessage+','+SPACE(1)+'You cannot perform MOC, Record is pending for authorization for an Account ID '+A.AccountId+' under this Customer ID. Kindly authorize or Reject the record through ‘Account Level MOC – Authorization’ menu'     END

		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'CustomerID' ELSE   ErrorinColumn +','+SPACE(1)+'CustomerID' END   

	 FRom AccountLevelMOC_mod A

INNER Join AdvAcBasicDetail F on A.AccountID=F.CustomerACID

INNER join CustomerBasicDetail B On F.CustomerEntityId=B.CustomerEntityId

INNER Join #MOCAuthorisation G ON F.RefCustomerId=G.CustomerID

  WHERE A.AuthorisationStatus in('NP','MP','DP','1A','FM')

  AND G.CustomerID=@CustomerID

  AND @Operationflag not in(16,17,20)







  IF EXISTS(SELECT 1 FROM #MOCAuthorisation WHERE Customerid=@CustomerID --AND ISNULL(ERRORDATA,'')<>''

		) 

	BEGIN

	PRINT 'ERROR'

	if(@operationflag not in(16,17,20))

	begin

		SELECT distinct ErrorMessage

		ErrorinColumn,'Validation'TableName

		FROM #MOCAuthorisation

		END



end



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

	





-------------------------------

--				ADVSECURITYDETAIL



--			select * from ADVSECURITYDETAIL --ExceptionFinalStatusType

--select * from AdvSecurityVALUEDetail 

-----AdvSecurityDetail

				
GO