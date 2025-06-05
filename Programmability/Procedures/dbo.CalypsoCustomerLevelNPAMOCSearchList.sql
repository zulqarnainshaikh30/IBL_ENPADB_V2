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


---- exec CustomerLevelNPAMOCSearchList @UCICID=N'84',@OperationFlag=2

----go



--sp_helptext CustomerLevelNPAMOCSearchList



-------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



















--exec CustomerLevelNPAMOCSearchList @UCICID=N'82000002',@OperationFlag=2

--go







--SELECT Top 100 * FROM [PRO].[CustomerCal_Hist]	where RefCustomerID ='95'

--And EffectiveFromTimeKey=25992 AND EffectiveToTimeKey=25992


--Exec [CustomerLevelNPAMOCfH.MOCSourceAltKeySearchList] @OperationFlag =, @UCICID='161760505'		--Main screen select

--MOCSource

--MOCSourceAltKey

--exec CalypsoCustomerLevelNPAMOCSearchList @UCICID=N'82000010',@OperationFlag=2

CREATE PROC [dbo].[CalypsoCustomerLevelNPAMOCSearchList]

--Declare



@OperationFlag  INT         = 2,

@UCICID	varchar(20)		='82000004',

@TimeKey INT                =25841

AS

     

BEGIN



SET NOCOUNT ON;


 
	SET @Timekey =(Select Timekey from SysDataMatrix Where MOC_Initialised='Y' AND ISNULL(MOC_Frozen,'N')='N') 







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
SELECT  

	@MocReason=MocReason,@MOCSourceAltkey=MOCSourceAltkey,@CreatedBy=CreatedBy,

	@DateCreated=DateCreated,@ModifiedBy=ModifiedBy,@DateModified=DateModified,@ApprovedBy=ApprovedBy,@DateApproved=DateApproved,

	@AuthorisationStatus=AuthorisationStatus,@ApprovedByFirstLevel=ApprovedByFirstLevel,
	@DateApprovedFirstLevel=DateApprovedFirstLevel,@MOC_TYPEFLAG=MOCType_Flag

	FROM CalypsoCustomerLevelMOC_Mod 

	where AuthorisationStatus in('MP','NP','1A','A') AND UCIFID=@UCICID

	AND  EffectiveFromTimeKey<=@Timekey and EffectiveToTimeKey>=@Timekey 

	--AND  Entity_key in (select max(Entity_key) FROM CalypsoCustomerLevelMOC_Mod 

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

	FROM CalypsoCustomerLevelMOC_Mod 

	where AuthorisationStatus in('MP','NP') AND UCIFID=@UCICID

	AND  EffectiveFromTimeKey<=@Timekey and EffectiveToTimeKey>=@Timekey 

	--AND SCREENFLAG <> ('U')

	end

	if @OperationFlag = '20'
	--,@MOC_ExpireDate=MOC_ExpireDate
BEGIN

	SELECT  

	@MocReason=MocReason,@MOCSourceAltkey=MOCSourceAltkey,@CreatedBy=CreatedBy,

	@DateCreated=DateCreated,@ModifiedBy=ModifiedBy,@DateModified=DateModified,@ApprovedBy=ApprovedBy,@DateApproved=DateApproved,

	@AuthorisationStatus=AuthorisationStatus,@ApprovedByFirstLevel=ApprovedByFirstLevel,
	@DateApprovedFirstLevel=DateApprovedFirstLevel,@MOC_TYPEFLAG=MOCType_Flag

	FROM CalypsoCustomerLevelMOC_Mod 

	where AuthorisationStatus in('1A') AND UCIFID=@UCICID

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




SELECT	distinct	B.InvEntityId,B.RefIssuerID as CustomerID ,I.IssuerName as CustomerName ,
					b.InvID as AccountID,c.StatusDate as FraudDate,E.StatusDate as TwoDate, 
					Interest_DividendDueAmount as InterestReceivable,
					case when A.FinalAssetClassAlt_Key is null then 1 else A.FinalAssetClassAlt_Key end AssetClassAlt_Key,A.NPIDt as NPADate,V.security_value  SecurityValue,
					B.RefIssuerID as UCICID, 0 as AdditionalProvision,I.SourceAlt_key	
 FROM				InvestmentBasicDetail B
 INNER JOIN			InvestmentIssuerDetail I
 ON					B.RefIssuerID = I.IssuerID
 and				I.EffectiveFromTimeKey <= @timekey and I.EffectiveToTimeKey >= @Timekey
 INNER JOIN			InvestmentFinancialDetail A
 ON					A.RefInvID = B.InvID
 and				A.EffectiveFromTimeKey <= @timekey and A.EffectiveToTimeKey >= @Timekey
  left join		(select  CustomerID,ACID,StatusType,StatusDate from  ExceptionFinalStatusType
where			StatusType='Fraud Committed'
  And			EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) c
  on			b.InvID=c.ACID
  left join		(select  CustomerID,ACID,StatusType,StatusDate from  ExceptionFinalStatusType
where			StatusType='TWO'
  And			EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) E 
  on			b.InvID=E.ACID
LEFT JOIN		(select        B.UcifId UcifId,sum(a.SecurityValue) security_value
from			InvestmentBasicDetail a
INNER JOIN		InvestmentIssuerDetail B
 ON				a.RefIssuerID = B.IssuerID
where			a.EffectiveFromTimeKey<=@timekey and a.EffectiveToTimeKey>=@timekey 
and				B.UcifId=@UCICID   
group by		B.UcifId      
			) V
ON				B.InvID=V.UcifId
where			B.EffectiveFromTimeKey<=@TimeKey and B.EffectiveToTimeKey>=@TimeKey 
AND				I.UcifId=@UCICID

UNION

SELECT	distinct		B.DerivativeEntityID,B.CustomerID ,B.CustomerName,
                b.DerivativeRefNo as AccountID,c.StatusDate as FraudDate,E.StatusDate as TwoDate,
				DueAmtReceivable as InterestReceivable,
				case when B.FinalAssetClassAlt_Key is null then 1 else B.FinalAssetClassAlt_Key end AssetClassAlt_Key,B.NPIDt,V.security_value  SecurityValue,
				B.UCIC_ID as UCICID, 0 as AdditionalProvision	,DB.SourceAlt_Key
 FROM			curdat.DerivativeDetail B

 left join  (select  CustomerID,ACID,StatusType,StatusDate from  ExceptionFinalStatusType
where StatusType='Fraud Committed'
  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) c
  on   b.CustomerACID=c.ACID
  
    left join (select  CustomerID,ACID,StatusType,StatusDate from  ExceptionFinalStatusType
where StatusType='TWO'
  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) E
  on   b.CustomerACID=E.ACID 
LEFT JOIN		(select        a.UCIC_ID,0 security_value
from			curdat.DerivativeDetail a
where			a.EffectiveFromTimeKey<=@timekey and a.EffectiveToTimeKey>=@timekey 
and				a.UCIC_ID=@UCICID   
group by		a.UCIC_ID      
				) V
ON				B.CustomerId=V.UCIC_ID
LEFT JOIN		DIMSOURCEDB DB ON b.SourceSystem = DB.SourceName 
where			B.EffectiveFromTimeKey<=@TimeKey and B.EffectiveToTimeKey>=@TimeKey 
AND				B.UCIC_ID=@UCICID	
) X 






----POST 



--Select '#CUST_PREMOC',* from #CUST_PREMOC

PRINT 'jaydev'
DROP TABLE IF EXISTS #CUST_POSTMOC

	SELECT *
	INTO #CUST_POSTMOC
	FROM (	
    
		
	
	SELECT distinct  A.CustomerEntityID,B.RefIssuerID as CustomerID,C.IssuerName as CustomerName ,
	
	FinalAssetClassAlt_Key as AssetClassAlt_Key, A.NPADate,A.SecurityValue SecurityValue,
	A.BookValue,Convert(Varchar(20),A.SMADate,103) as SMADate, A.SMASubAssetClassValue,
		C.UcifId as UCICID, A.AdditionalProvision,
	@AuthorisationStatus as AuthorisationStatus,@MocReason as MOCReason_1,@MOCSourceAltkey as MOCSourceAltkey,@CreatedBy as CreatedBy,
	@DateCreated as DateCreated,@ModifiedBy as ModifiedBy,@DateModified as DateModified,@ApprovedBy as ApprovedBy,
	@DateApproved as DateApproved,@ApprovedByFirstLevel as ApprovedByFirstLevel,
	@DateApprovedFirstLevel as DateApprovedFirstLevel,@MOC_ExpireDate MOC_ExpireDate,@MOC_TYPEFLAG MOCType_Flag,MOCType,C.SourceAlt_key as SourceSystemAlt_Key1
	,Convert(Varchar(50),'Calypso') SourceName
	,0 as MOCReason
    FROM		CalypsoCustomerLevelMOC_Mod A
	INNER JOIN  InvestmentIssuerDetail C
	ON          a.UcifID=C.UcifId
	AND         C.EffectiveFromTimeKey<=@TimeKey and C.EffectiveToTimeKey>=@TimeKey 
	INNER JOIN  InvestmentBasicDetail B
	ON          c.IssuerEntityId=B.IssuerEntityId
	AND         B.EffectiveFromTimeKey<=@TimeKey and B.EffectiveToTimeKey>=@TimeKey 	
	INNER JOIN  InvestmentFinancialDetail D
	ON          B.InvEntityId=D.InvEntityId
	AND         D.EffectiveFromTimeKey<=@TimeKey and D.EffectiveToTimeKey>=@TimeKey 
	WHERE       A.EffectiveFromTimeKey<=@TimeKey and A.EffectiveToTimeKey>=@TimeKey 
	AND			 A.UcifID=@UCICID
	and         A.AuthorisationStatus in ('NP','MP','1A','A')

	UNION
	
	SELECT  distinct  A.CustomerEntityID,B.CustomerId ,B.CustomerName,AssetClassAlt_Key, A.NPADate,A.SecurityValue SecurityValue,
	A.BookValue,Convert(Varchar(20),A.SMADate,103) as SMADate, A.SMASubAssetClassValue,
		B.UCIC_ID as UCICID, A.AdditionalProvision,

	@AuthorisationStatus as AuthorisationStatus,@MocReason as MOCReason_1,@MOCSourceAltkey as MOCSourceAltkey,@CreatedBy as CreatedBy,

	@DateCreated as DateCreated,@ModifiedBy as ModifiedBy,@DateModified as DateModified,@ApprovedBy as ApprovedBy,

	@DateApproved as DateApproved,@ApprovedByFirstLevel as ApprovedByFirstLevel,
	@DateApprovedFirstLevel as DateApprovedFirstLevel,@MOC_ExpireDate MOC_ExpireDate,@MOC_TYPEFLAG MOCType_Flag,MOCType,C.SourceAlt_Key as SourceSystemAlt_Key1
	,Convert(Varchar(50),'Calypso') SourceName

	,0 as MOCReason
    FROM		CalypsoCustomerLevelMOC_Mod A
	INNER JOIN  Curdat.DerivativeDetail B
	ON          A.UCIFID=B.UCIC_ID
	AND         B.EffectiveFromTimeKey<=@TimeKey and B.EffectiveToTimeKey>=@TimeKey 
	INNER JOIN	DIMSOURCEDB C 
	ON			B.SourceSystem = C.SourceName
	WHERE       A.EffectiveFromTimeKey<=@TimeKey and A.EffectiveToTimeKey>=@TimeKey AND B.UCIC_ID=@UCICID
	and         A.AuthorisationStatus in ('NP','MP','1A','A')

	)P


	IF NOT EXISTS(SELECT 1 FROM #CUST_POSTMOC WHERE UCICID=@UCICID)

	BEGIN
	PRINT 'swapna'
	INSERT  INTO  #CUST_POSTMOC	

		

		SELECT distinct	B.IssuerEntityId,C.IssuerID,C.IssuerName,
		--d.RefInvID as AccountID,FraudDate,TwoDate,unserviedint as InterestReceivable,
		A.AssetClassAlt_Key,A.NPA_Date,A.CurntQtrRv  SecurityValue,
		            A.BookValue,Convert(Varchar(20),A.SMADate,103) as SMADate, A.SMASubAssetClassValue,
					C.UcifId as UCICID,AddlProvAbs as AdditionalProvision,@AuthorisationStatus as AuthorisationStatus,@MocReason as MOCReason_1,
					@MOCSourceAltkey as MOCSourceAltkey,@CreatedBy as CreatedBy,
					@DateCreated as DateCreated,@ModifiedBy as ModifiedBy,@DateModified as DateModified,@ApprovedBy as ApprovedBy,
					@DateApproved as DateApproved
					,@ApprovedByFirstLevel as ApprovedByFirstLevel,@DateApprovedFirstLevel as DateApprovedFirstLevel,
					@MOC_ExpireDate MOC_ExpireDate,@MOC_TYPEFLAG MOCType_Flag,MOCType,C.SourceAlt_key as SourceSystemAlt_Key1,Convert(Varchar(50),'Calypso') SourceName
					,0 as MOCReason
		FROM		CalypsoInvMOC_ChangeDetails A		
	INNER JOIN  InvestmentIssuerDetail C
	ON          a.UCICID=C.UcifId
	AND         C.EffectiveFromTimeKey<=@TimeKey and C.EffectiveToTimeKey>=@TimeKey 
	INNER JOIN  InvestmentBasicDetail B
	ON          c.IssuerEntityId=B.IssuerEntityId
	AND         B.EffectiveFromTimeKey<=@TimeKey and B.EffectiveToTimeKey>=@TimeKey 	
	INNER JOIN  InvestmentFinancialDetail D
	ON          B.InvEntityId=D.InvEntityId
	AND         D.EffectiveFromTimeKey<=@TimeKey and D.EffectiveToTimeKey>=@TimeKey 
		where		A.EffectiveFromTimeKey<=@TimeKey and A.EffectiveToTimeKey>=@TimeKey 
		AND			A.UCICID=@UCICID
		AND			MOCType_Flag='CUST'
		
		UNION

		SELECT distinct	B.DerivativeEntityID,B.CustomerId,B.CustomerName,
		--b.DerivativeRefNo as AccountID,FraudDate,TwoDate,unserviedint as InterestReceivable,
		A.AssetClassAlt_Key,A.NPA_Date,A.CurntQtrRv  SecurityValue,
					A.BookValue,Convert(Varchar(20),A.SMADate,103) as SMADate, A.SMASubAssetClassValue,
					B.UCIC_ID as UCICID,AddlProvAbs as AdditionalProvision,@AuthorisationStatus as AuthorisationStatus,@MocReason as MOCReason_1,
					@MOCSourceAltkey as MOCSourceAltkey,@CreatedBy as CreatedBy,
					@DateCreated as DateCreated,@ModifiedBy as ModifiedBy,@DateModified as DateModified,@ApprovedBy as ApprovedBy,
					@DateApproved as DateApproved
					,@ApprovedByFirstLevel as ApprovedByFirstLevel,@DateApprovedFirstLevel as DateApprovedFirstLevel,
					@MOC_ExpireDate MOC_ExpireDate,@MOC_TYPEFLAG MOCType_Flag,MOCType,C.SourceAlt_Key as SourceSystemAlt_Key1,Convert(Varchar(50),'Calypso') SourceName
					,0 as MOCReason
		FROM		CalypsoDervMOC_ChangeDetails A
		INNER JOIN	curdat.DerivativeDetail B
		ON			A.UCICID=B.UCIC_ID 
		AND			B.EffectiveFromTimeKey<=@TimeKey and B.EffectiveToTimeKey>=@TimeKey
		INNER JOIN	DIMSOURCEDB C
		ON			B.SourceSystem= C.SourceName
		AND			B.EffectiveFromTimeKey<=@TimeKey and B.EffectiveToTimeKey>=@TimeKey
		where		A.EffectiveFromTimeKey<=@TimeKey and A.EffectiveToTimeKey>=@TimeKey 
		AND			A.UCICID=@UCICID
		AND			MOCType_Flag='CUST'



END

	PRINT 'Sudesh'

	Update A
	SET A.SourceName=B.SourceName
	From #CUST_POSTMOC A
	INNER JOIN DIMSOURCEDB B
	ON A.SourceSystemAlt_Key1=B.SourceAlt_Key

	--Select '#CUST_POSTMOC',MOCReason_1, * from #CUST_POSTMOC


	Update A
SET A.MOCReason=ISNULL(B.ParameterAlt_Key,'')
From #CUST_POSTMOC A
Left JOIN 
(select ParameterAlt_Key ,
			 ParameterName 
			 ,'MOCReason' as TableName
			 from DimParameter
			 where 
			 EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey and
			  DimParameterName	= 'DimMOCReason') B
			  ON A.MOCReason_1 =B.ParameterName

SELECT distinct 



	a.CustomerID CustomerId
	
	,a.CustomerName
	,a.AccountID 
	,a.FraudDate
	,a.TwoDate
	,a.InterestReceivable

	,C.AssetClassName AssetClass	

	,a.NPADate NPADate

	,a.SecurityValue	
	,B.BookValue
	,Convert(Varchar(20),B.SMADate,103) as SMADate
	,B.SMASubAssetClassValue

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
	,B.MOCReason_1 

	--,B.MOCTypeAlt_Key                  

	--,Y.MOCTypeName as MOCSource

	,B.MOCSourceAltKey
	,case when B.MOCType='auto' then 1 else 2 end as MOCTypeAlt_Key

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
,(CASE WHEN DB.SourceName is not NULL Then DB.SourceName else DB1.SourceName END)SourceName
FROM #CUST_PREMOC A

	left JOIN #CUST_POSTMOC B

		on A.CustomerID =b.CustomerID

	LEFT JOIN DimAssetClass c

		ON C.AssetClassAlt_Key=a.AssetClassAlt_Key

		and c.EffectiveFromTimeKey<=@TimeKey and c.EffectiveToTimeKey>=@TimeKey 

	LEFT JOIN DimAssetClass d

		ON d.AssetClassAlt_Key=b.AssetClassAlt_Key

		and d.EffectiveFromTimeKey<=@TimeKey and d.EffectiveToTimeKey>=@TimeKey

			LEFT JOIN DimSOURCEDB dB

		ON dB.SourceAlt_Key=a.SourceAlt_key

		and db.EffectiveFromTimeKey<=@TimeKey and db.EffectiveToTimeKey>=@TimeKey

		LEFT JOIN DimSOURCEDB dB1

		ON dB1.SourceAlt_Key=b.SourceSystemAlt_Key1

		and db1.EffectiveFromTimeKey<=@TimeKey and db1.EffectiveToTimeKey>=@TimeKey
 



PRINT 'Priyali'	



   IF OBJECT_ID('tempdb..#MOCAuthorisation') IS NOT NULL  

	  BEGIN  

	   DROP TABLE #MOCAuthorisation  

	  END





	  Select *,CAST('' AS varchar(MAX)) ErrorMessage,CAST('' AS varchar(MAX)) ErrorinColumn,CAST('' AS varchar(MAX)) Srnooferroneousrows

 	   into #MOCAuthorisation 

	   from CalypsoCustomerLevelMOC_Mod A

	   	Where A.EffectiveFromTimeKey<=@Timekey And A.EffectiveToTimeKey>=@Timekey

		and UCIFID=@UCICID and UCIFID is not null

		   AND A.Entity_Key IN

                     (

                         SELECT MAX(Entity_Key)

                  FROM CalypsoCustomerLevelMOC_Mod

WHERE EffectiveFromTimeKey <= @Timekey

  AND EffectiveToTimeKey >= @Timekey

         AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')

                         GROUP BY UCIFID

                     )				



				

					

	   --Select ' #MOCAuthorisation',* from  #MOCAuthorisation

	   --where abc=1



	  UPDATE #MOCAuthorisation

	SET  

        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'You cannot perform MOC, Record is pending for authorization for this UCIC ID. Kindly authorize or Reject the record through UCIC MOC – Authorization’ menu'     

						ELSE ErrorMessage+','+SPACE(1)+'You cannot perform MOC, Record is pending for authorization for this UCIC ID. Kindly authorize or Reject the record through ‘UCIC MOC – Authorization’ menu'     END

		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'UCICID' ELSE   ErrorinColumn +','+SPACE(1)+'UCICID' END   

	

		FROM #MOCAuthorisation V  

  WHERE V.AuthorisationStatus in('NP','MP','DP','1A')

  AND UCIFID=@UCICID

  AND @operationflag not in(16,17,20)



 



  UPDATE #MOCAuthorisation

	SET  

       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'You cannot perform MOC, Record is pending for authorization for this Customer ID. Kindly authorize or Reject the record through ‘UCIC MOC – Authorization’ menu'     

						ELSE ErrorMessage+','+SPACE(1)+'You cannot perform MOC, Record is pending for authorization for this Customer ID. Kindly authorize or Reject the record through ‘UCIC MOC – Authorization’ menu'     END

		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'UCICID' ELSE   ErrorinColumn +','+SPACE(1)+'UCICID' END   

		

		FROM CalypsoCustomerLevelMOC_Mod V 

		inner join InvestmentIssuerDetail X On V.UcifID=X.UcifId

		Inner Join #MOCAuthorisation Z On X.UcifId=Z.UCIFID

		

  WHERE X.AuthorisationStatus in('NP','MP','DP','1A')

  AND @operationflag not in(16,17,20)  AND Z.UCIFID=@UCICID

  


  UPDATE #MOCAuthorisation

	SET  

       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'You cannot perform MOC, Record is pending for authorization for this UCIC ID. Kindly authorize or Reject the record through ‘UCIC MOC – Authorization’ menu'     

						ELSE ErrorMessage+','+SPACE(1)+'You cannot perform MOC, Record is pending for authorization for this UCIC ID. Kindly authorize or Reject the record through ‘UCIC MOC – Authorization’ menu'     END

		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'UCICID' ELSE   ErrorinColumn +','+SPACE(1)+'UCICID' END   

		

		FROM CalypsoCustomerLevelMOC_Mod V 

		inner join curdat.DerivativeDetail X On V.UCIFID=X.UCIC_ID

		Inner Join #MOCAuthorisation Z On X.UCIC_ID=Z.UCIFID

		

  WHERE X.AuthorisationStatus in('NP','MP','DP','1A')

  AND @operationflag not in(16,17,20)  AND Z.UCIFID=@UCICID


  IF EXISTS(SELECT 1 FROM #MOCAuthorisation WHERE UCIFID=@UCICID --AND ISNULL(ERRORDATA,'')<>''

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