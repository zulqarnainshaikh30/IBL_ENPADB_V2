SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[ValidateExcel_DataUpload_CustMocUpload]  
@MenuID INT=10,  
@UserLoginId  VARCHAR(20)='fnachecker',  
@Timekey INT=49999
,@filepath VARCHAR(MAX) ='IBPCUPLOAD.xlsx'  
WITH RECOMPILE  
AS  
  
  --fnasuperadmin_IBPCUPLOAD.xlsx

--DECLARE  
  
--@MenuID INT=128,  
--@UserLoginId varchar(20)='test_two',  
--@Timekey int=49999
--,@filepath varchar(500)='CustlevelNPAMOCUpload.xlsx'  
  
BEGIN

BEGIN TRY  
--BEGIN TRAN  
  
--Declare @TimeKey int  
    --Update UploadStatus Set ValidationOfData='N' where FileNames=@filepath  
     
	 SET DATEFORMAT DMY

 --Select @Timekey=Max(Timekey) from dbo.SysProcessingCycle  
 -- where  ProcessType='Quarterly' ----and PreMOC_CycleFrozenDate IS NULL
 

  --SET @Timekey =(Select TimeKey from SysDataMatrix where CurrentStatus='C') 

  --SET @Timekey =(Select LastMonthDateKey from SysDayMatrix where Timekey=@Timekey)  

  SET @Timekey =(Select Timekey from SysDataMatrix Where MOC_Initialised='Y' AND ISNULL(MOC_Frozen,'N')='N')   
  
 --  DECLARE @DepartmentId SMALLINT ,@DepartmentCode varchar(100)  
 --SELECT  @DepartmentId= DepartmentId FROM dbo.DimUserInfo   
 --WHERE EffectiveFromTimeKey <= @Timekey AND EffectiveToTimeKey >= @Timekey  
 --AND UserLoginID = @UserLoginId  
 --PRINT @DepartmentId  
 --PRINT @DepartmentCode  
  
    
  
 --SELECT @DepartmentCode=DepartmentCode FROM AxisIntReversalDB.DimDepartment   
 --    WHERE EffectiveFromTimeKey <= @Timekey AND EffectiveToTimeKey >= @Timekey   
 --    --AND DepartmentCode IN ('BBOG','FNA')  
 --    AND DepartmentAlt_Key = @DepartmentId  
  
 --    print @DepartmentCode  
     --Select @DepartmentCode=REPLACE('',@DepartmentCode,'_')  
     
       
  
   
  
  DECLARE @FilePathUpload	VARCHAR(100)

			SET @FilePathUpload=@UserLoginId+'_'+@filepath
	PRINT '@FilePathUpload'
	PRINT @FilePathUpload

	IF EXISTS(SELECT 1 FROM dbo.MasterUploadData    where FileNames=@filepath )
	BEGIN
		Delete from dbo.MasterUploadData    where FileNames=@filepath  
		print @@rowcount
	END


IF (@MenuID=128)	
BEGIN


	  -- IF OBJE[dbo].[ValidateExcel_DataUpload_CustMocUpload_05042024]CT_ID('tempdb..UploadCustMocUpload') IS NOT NULL  
	  IF OBJECT_ID('UploadCustMocUpload') IS NOT NULL  
	  BEGIN  
	   DROP TABLE UploadCustMocUpload  
	
	  END

	--  Select * from UploadCustMocUpload
	  
  IF NOT (EXISTS (SELECT 1 FROM CustlevelNPAMOCDetails_stg where filname=@FilePathUpload))

BEGIN
print 'NO DATA'
			Insert into dbo.MasterUploadData
			(SR_No,ColumnName,ErrorData,ErrorType,FileNames,Flag) 
			SELECT 0 SlNo , '' ColumnName,'No Record found' ErrorData,'No Record found' ErrorType,@filepath,'SUCCESS' 
			--SELECT 0 SlNo , '' ColumnName,'' ErrorData,'' ErrorType,@filepath,'SUCCESS' 

			goto errordata
    
END

ELSE
BEGIN
PRINT 'DATA PRESENT'
	   Select *,CAST('' AS varchar(MAX)) ErrorMessage,CAST('' AS varchar(MAX)) ErrorinColumn,CAST('' AS varchar(MAX)) Srnooferroneousrows
 	   into UploadCustMocUpload
	   from CustlevelNPAMOCDetails_stg 
	   WHERE filname=@FilePathUpload 

	   update A
	   set A.SourceAlt_Key = isnull(B.SourceAlt_Key,'')
	   from UploadCustMocUpload A
	   INNER JOIN DIMSOURCEDB B 
	   ON A.SourceSystem = B.SourceName

	  
END
  ------------------------------------------------------------------------------  
    ----SELECT * FROM UploadCustMocUpload
	--SlNo	Territory	ACID	InterestReversalAmount	filename
	UPDATE UploadCustMocUpload
	SET  
        ErrorMessage='There is no data in excel. Kindly check and upload again' 
		,ErrorinColumn='Sl.No.,Customer ID,AssetClass,NPADate,SecurityValue,AdditionalProvision%,MOCSource,MOCType,MOCReason'    
		,Srnooferroneousrows=''
 FROM UploadCustMocUpload V  
 WHERE ISNULL(SlNo,'')=''
AND ISNULL(CustomerID,'')=''
AND ISNULL(AssetClass,'')=''
AND ISNULL(NPADate,'')=''
AND ISNULL(SecurityValue,'')=''
--AND ISNULL([AdditionalProvision],'')=''             -----------------Kapil on date 24/01/2024
AND ISNULL(MOCSource,'')=''
AND ISNULL(MOCType,'')=''
AND ISNULL(MOCReason,'')=''
  
--WHERE ISNULL(V.SlNo,'')=''
-- ----AND ISNULL(Territory,'')=''
-- AND ISNULL(AccountID,'')=''
-- AND ISNULL(PoolID,'')=''
-- AND ISNULL(filename,'')=''
UPDATE UploadCustMocUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Sr No is present and remaining  excel file is blank. Please check and Upload again.'     
						ELSE ErrorMessage+','+SPACE(1)+'Sr No is present and remaining  excel file is blank. Please check and Upload again.'     END
	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Excel Vaildate ' ELSE   ErrorinColumn +','+SPACE(1)+'Excel Vaildate' END   
		,Srnooferroneousrows=''
	
   FROM UploadCustMocUpload V  
 WHERE 
-- ISNULL(SlNo,'')=''
--AND ISNULL(CustomerID,'')=''
	ISNULL(AssetClass,'')=''
AND ISNULL(NPADate,'')=''
AND ISNULL(SecurityValue,'')=''
--AND ISNULL([AdditionalProvision],'')=''

  IF EXISTS(SELECT 1 FROM UploadCustMocUpload WHERE ISNULL(ErrorMessage,'')<>'')
  BEGIN
  PRINT 'NO DATA'
  GOTO ERRORDATA;
  END

  
   UPDATE UploadCustMocUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Customer ID not existing with Source System; Please check and upload again.'     
						ELSE ErrorMessage+','+SPACE(1)+'Customer ID not existing with Source System; Please check and upload again.'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SourceSystem/CustomerID' ELSE   ErrorinColumn +','+SPACE(1)+'SourceSystem/CustomerID' END   
		,Srnooferroneousrows=V.CustomerID		
   FROM UploadCustMocUpload V  
   left JOIN customerBasicDetail B 
   ON V.SourceAlt_key = B.SourceSystemAlt_Key    and
  V.CustomerID = B.CustomerID
 WHERE (ISNULL(B.SourceSystemAlt_Key,'')='' 
 OR ISNULL(B.CustomerID,'')='')


 
 Print 'SourceSystem'
 UPDATE UploadCustMocUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Source System column is mandatory. Kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Source System column is mandatory. Kindly check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SourceSystem' ELSE   ErrorinColumn +','+SPACE(1)+'SourceSystem' END   
		,Srnooferroneousrows=V.SlNo

FROM UploadCustMocUpload V  
 WHERE ISNULL(SourceSystem,'')=''


      /*validations on Sl. No.*/
 ------------------------------------------------------------

  Declare @DuplicateCnt int=0
   UPDATE UploadCustMocUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'SlNo cannot be blank . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'SlNo cannot be blank . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SlNo' ELSE   ErrorinColumn +','+SPACE(1)+'SlNo' END   
		,Srnooferroneousrows=V.SlNo
								
   
   FROM UploadCustMocUpload V  
 WHERE ISNULL(SlNo,'')='' or ISNULL(SlNo,'0')='0'


  UPDATE UploadCustMocUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'SlNo cannot be greater than 16 character . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'SlNo cannot be greater than 16 character . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SlNo' ELSE   ErrorinColumn +','+SPACE(1)+'SlNo' END   
		,Srnooferroneousrows=V.SlNo
								
   
   FROM UploadCustMocUpload V  
 WHERE Len(SlNo)>16

  UPDATE UploadCustMocUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid Sl. No., kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid Sl. No., kindly check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SlNo' ELSE   ErrorinColumn +','+SPACE(1)+'SlNo' END   
		,Srnooferroneousrows=V.SlNo
								
   
   FROM UploadCustMocUpload V  
  WHERE (ISNUMERIC(SlNo)=0 AND ISNULL(SlNo,'')<>'') OR 
 ISNUMERIC(SlNo) LIKE '%^[0-9]%'

 UPDATE UploadCustMocUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Special characters not allowed, kindly remove and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Special characters not allowed, kindly remove and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SlNo' ELSE   ErrorinColumn +','+SPACE(1)+'SlNo' END   
		,Srnooferroneousrows=V.SlNo
								
   
   FROM UploadCustMocUpload V  
   WHERE ISNULL(SlNo,'') LIKE'%[,!@#$%^&*()_-+=/]%- \ / _'

   --
  SELECT @DuplicateCnt=Count(1)
FROM UploadCustMocUpload
GROUP BY  SlNo
HAVING COUNT(SlNo) >1;

IF (@DuplicateCnt>0)

 UPDATE UploadCustMocUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Duplicate Sl. No., kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Duplicate Sl. No., kindly check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SlNo' ELSE   ErrorinColumn +','+SPACE(1)+'SlNo' END   
		,Srnooferroneousrows=V.SlNo
								
   
   FROM UploadCustMocUpload V  
   Where ISNULL(SlNo,'') In(  
   SELECT SlNo
	FROM UploadCustMocUpload
	GROUP BY  SlNo
	HAVING COUNT(SlNo) >1

)
----------------------------------------------





 


    /*VALIDATIONS ON CustomerID */
 ------------------------------------------------------------
  Declare @Count Int,@I Int,@Entity_Key Int
   Declare @RefCustomerID Varchar(100)=''
   Declare @CustomerIDFound Int=0
   Declare @DuplicateCustomerCnt INT=0
  UPDATE UploadCustMocUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'The column ‘Customer ID’ is mandatory. Kindly check and upload again'     
					ELSE ErrorMessage+','+SPACE(1)+'The column ‘Customer ID’ is mandatory. Kindly check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'CustomerID' ELSE ErrorinColumn +','+SPACE(1)+  'CustomerID' END  
		,Srnooferroneousrows=V.SlNo
--								----STUFF((SELECT ','+SlNo 
--								----FROM UploadCustMocUpload A
--								----WHERE A.SlNo IN(SELECT V.SlNo FROM UploadCustMocUpload V  
--								----				WHERE ISNULL(ACID,'')='' )
--								----FOR XML PATH ('')
--								----),1,1,'')   

FROM UploadCustMocUpload V  
 WHERE ISNULL([CustomerID],'')=''
 

 -------

  UPDATE UploadCustMocUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Special characters - \ / _. are allowed , Kindly remove and upload again '     
						ELSE ErrorMessage+','+SPACE(1)+'Special characters - \ / _. are allowed , Kindly remove and upload again '    END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'CustomerId' ELSE   ErrorinColumn +','+SPACE(1)+'CustomerId' END   
		,Srnooferroneousrows=V.SlNo
								
   
  FROM UploadCustMocUpload V  
 WHERE ISNULL(CustomerId,'') LIKE'%[,!@#$%^&*()+=]%'





 ----------------------------------------Newly added by kapil on 08/02/2023
   
  UPDATE UploadCustMocUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid Customer  ID found. Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid Customer ID found. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Customer ID' ELSE ErrorinColumn +','+SPACE(1)+  'Customer ID' END  
		,Srnooferroneousrows=V.SlNo
  
		FROM UploadCustMocUpload V  
 WHERE ISNULL(V.CustomerId,'')<>''
 AND V.CustomerID NOT IN(SELECT CustomerId FROM CustomerBasicDetail
								WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
						 )


 IF OBJECT_ID('TEMPDB..#DUB2') IS NOT NULL
 DROP TABLE #DUB2

 SELECT * INTO #DUB2 FROM(
 SELECT *,ROW_NUMBER() OVER(PARTITION BY CustomerId ORDER BY CustomerId ) as rw  FROM UploadCustMocUpload
 )X
 WHERE rw>1


 UPDATE V
	SET  
        ErrorMessage=CASE WHEN ISNULL(V.ErrorMessage,'')='' THEN  'Duplicate Customer ID found. Please check the values and upload again'     
						ELSE V.ErrorMessage+','+SPACE(1)+'Duplicate Customer ID found. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(V.ErrorinColumn,'')='' THEN 'Account ID' ELSE V.ErrorinColumn +','+SPACE(1)+  'Account ID' END  
		,Srnooferroneousrows=V.SlNo
  
		FROM UploadCustMocUpload V 
		INNer JOIN #DUB2 D ON D.CustomerID=V.CustomerID




---------------------VVVVVVVVVVVVV-----commeted by kapil on 08/02/2023

-- IF OBJECT_ID('TempDB..#tmp') IS NOT NULL 
-- DROP TABLE #tmp; 
  
--  Select  ROW_NUMBER() OVER(ORDER BY  CONVERT(INT,Entity_Key) ) RecentRownumber,Entity_Key,CustomerID  into #tmp from UploadCustMocUpload
                  
-- Select @Count=Count(*) from #tmp
  
--   SET @I=1
--   SET @Entity_Key=0

--   SET @RefCustomerID=''
--     While(@I<=@Count)
--               BEGIN 
--			      Select @RefCustomerID =CustomerID,@Entity_Key=Entity_Key  from #tmp where RecentRownumber=@I 
--							order By Entity_Key

--					  Select      @CustomerIDFound=Count(1)
--				from CustomerBasicDetail  A Where  CustomerID =@RefCustomerID
--				and EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey

--				IF @CustomerIDFound =0
--				    Begin
--				       Update UploadCustMocUpload
--										   SET   ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN ' Customer ID is invalid. Kindly check the entered  Customer ID '     
--											 ELSE ErrorMessage+','+SPACE(1)+' Customer ID is invalid. Kindly check the entered  Customer ID '      END
--											 ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Customer ID' ELSE   ErrorinColumn +','+SPACE(1)+'Customer ID' END   
--										   Where Entity_Key=@Entity_Key
--					END
--					  SET @I=@I+1
--					   SET @RefCustomerID=''
								
								
--			   END

--  SELECT @DuplicateCustomerCnt=Count(1)
--FROM UploadCustMocUpload
--GROUP BY  CustomerID
--HAVING COUNT(CustomerID) >1;

--IF (@DuplicateCustomerCnt>1)

--BEGIN
-- UPDATE UploadCustMocUpload
--	SET  
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Duplicate Customer ID., kindly check and upload again'     
--						ELSE ErrorMessage+','+SPACE(1)+'Duplicate Customer ID., kindly check and upload again'     END
--		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Customer ID' ELSE   ErrorinColumn +','+SPACE(1)+'Customer ID' END   
--		,Srnooferroneousrows=V.SlNo
								
   
--   FROM UploadCustMocUpload V  
--   Where ISNULL(CustomerID,'') In(  
--   SELECT CustomerID
--	FROM UploadCustMocUpload
--	GROUP BY  CustomerID
--	HAVING COUNT(CustomerID) >1
--	)
--END
-- ----SELECT * FROM UploadCustMocUpload
 -----------------------------------^^^^^^^^^^^^^^------------- commeted by kapil on 08/02/2023


 UPDATE UploadCustMocUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'You cannot perform MOC, Record is pending for authorization for this Customer ID. Kindly authorize or Reject the record through ‘Customer Level MOC – Authorization’ menu'     
						ELSE ErrorMessage+','+SPACE(1)+'You cannot perform MOC, Record is pending for authorization for this Customer ID. Kindly authorize or Reject the record through ‘Customer Level MOC – Authorization’ menu'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'CustomerID' ELSE ErrorinColumn +','+SPACE(1)+  'CustomerId' END  
		,Srnooferroneousrows=V.SlNo
  
		FROM UploadCustMocUpload V  
 WHERE ISNULL(V.CustomerId,'')<>''
 AND V.CustomerId  IN (SELECT Distinct CustomerId FROM CustomerLevelMOC_Mod A
								  WHERE EffectiveFromTimeKey <= @TimeKey

                               AND EffectiveToTimeKey >= @TimeKey AND  ISNULL(ScreenFlag,'')<>'U'

                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A'))

                  

						


	UPDATE UploadCustMocUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'You cannot perform MOC, Record is pending for authorization for this Customer ID. Kindly authorize or Reject the record through ‘Customer Level MOC Upload – Authorization’ menu'     
						ELSE ErrorMessage+','+SPACE(1)+'You cannot perform MOC, Record is pending for authorization for this Customer ID. Kindly authorize or Reject the record through ‘Customer Level MOC Upload – Authorization’ menu'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'CustomerID' ELSE ErrorinColumn +','+SPACE(1)+  'CustomerID' END  
		,Srnooferroneousrows=V.SlNo
  
		FROM UploadCustMocUpload V  
 WHERE ISNULL(V.CustomerId,'')<>''
 AND V.CustomerId  IN (SELECT Distinct CustomerId FROM CustomerLevelMOC_Mod A
								  WHERE EffectiveFromTimeKey <= @TimeKey

                               AND EffectiveToTimeKey >= @TimeKey AND   ISNULL(ScreenFlag,'')='U'

                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A'))


--UPDATE UploadCustMocUpload
--	SET  
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'You cannot perform MOC, Record is pending for authorization for an Account ID' + CONVERT(VARCHAR(30),Y.CustomerAcID)+ ' under this Customer ID. Kindly authorize or Reject the record through ‘Account Level MOC Upload – Authorization’ menuu'     
--						ELSE ErrorMessage+','+SPACE(1)+'You cannot perform MOC, Record is pending for authorization for an Account ID' + CONVERT(VARCHAR(30),Y.CustomerAcID)+ ' under this Customer ID. Kindly authorize or Reject the record through ‘Account Level MOC Upload– Authorization’ menuu'     END
--		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'CustomerID' ELSE ErrorinColumn +','+SPACE(1)+  'CustomerID' END  
--		,Srnooferroneousrows=V.SlNo
  
--		FROM UploadCustMocUpload V  
--		INNER Join PRO.CustomerCal_Hist Z On V.CustomerID=Z.RefCustomerID
--	    INNER Join PRO.AccountCal_Hist Y on Y.CustomerEntityID=Z.CustomerEntityID
--		WHERE ISNULL(V.CustomerId,'')<>''
-- AND V.CustomerId  IN (
 
-- Select F.RefCustomerID from AccountLevelMOC_mod A
--  INNER Join PRO.AccountCal_Hist F on A.AccountID=F.CustomerACID

--INNER join PRO.CustomerCal_Hist B On F.CustomerEntityId=B.CustomerEntityID

--Where A.EntityKey in   (

--                         SELECT MAX(EntityKey)

--                         FROM AccountLevelMOC_mod

--                         WHERE EffectiveFromTimeKey <= @TimeKey

--                               AND EffectiveToTimeKey >= @TimeKey

--                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')
--							    And MOCSource<>'U'
--                         GROUP BY AccountID

--                     ))



 ----------------------------------------------
 --IF OBJECT_ID('TEMPDB..#DupCustomerid') IS NOT NULL
 --DROP TABLE #DupCustomerid

 --SELECT * INTO #DupCustomerid FROM(
 --SELECT *,ROW_NUMBER() OVER(PARTITION BY SlNo ORDER BY Customerid ) as rw  FROM UploadCustMocUpload
 --)X
 --WHERE rw>1


 --UPDATE V
	--SET  
 --       ErrorMessage=CASE WHEN ISNULL(V.ErrorMessage,'')='' THEN  'Duplicate Customerid found. Kindly check and upload again'     
	--					ELSE V.ErrorMessage+','+SPACE(1)+'Duplicate Customerid found. Kindly check and upload again'     END
	--	,ErrorinColumn=CASE WHEN ISNULL(V.ErrorinColumn,'')='' THEN 'Customerid' ELSE V.ErrorinColumn +','+SPACE(1)+  'Customerid' END  
	--	,Srnooferroneousrows=V.SlNo
  
	--	FROM UploadCustMocUpload V 
	--	INNer JOIN #DupCustomerid D ON D.DupCustomerid=V.DupCustomerid

---- ----SELECT * FROM UploadCustMocUpload
   


-- comment due to forchange field 21062021 as discuused with Jaydev/Akshay/Anuj
 

/*validations on AssetClass */



 UPDATE UploadCustMocUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'The column AssetClass  is mandatory. Kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'The column AssetClass  is mandatory. Kindly check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'AssetClass' ELSE   ErrorinColumn +','+SPACE(1)+'AssetClass' END       
		,Srnooferroneousrows=V.SlNo
	
   
   FROM UploadCustMocUpload V  
 WHERE ISNULL(AssetClass,'')=''
 --AND LEN(AssetClass)>16

 UPDATE UploadCustMocUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid Asset Class or gretaer than 16 character,  Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid Asset Class or gretaer than 16 character,  Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'AssetClass' ELSE   ErrorinColumn +','+SPACE(1)+'AssetClass' END       
		,Srnooferroneousrows=V.SlNo
	
   
   FROM UploadCustMocUpload V  
 WHERE ISNULL(AssetClass,'')<>''
 AND LEN(AssetClass)>16



  UPDATE UploadCustMocUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Special characters - \ / _. are allowed , Kindly remove and upload again '     
						ELSE ErrorMessage+','+SPACE(1)+'Special characters - \ / _. are allowed , Kindly remove and upload again '    END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'AssetClass' ELSE   ErrorinColumn +','+SPACE(1)+'AssetClass' END   
		,Srnooferroneousrows=V.SlNo
								
   
   FROM UploadCustMocUpload V  
 WHERE ISNULL(AssetClass,'') LIKE'%[,!@#$%^&*()+=]%'


    Declare @DuplicateAssetClassInt int=0

	

	IF OBJECT_ID('AssetClassData') IS NOT NULL  
	  BEGIN  
	   DROP TABLE AssetClassData  
	
	  END

	  IF OBJECT_ID('AssetClassValidationData') IS NOT NULL  
	  BEGIN  
	   DROP TABLE AssetClassValidationData  
	
	  END
	 
SELECT * into AssetClassValidationData  FROM(
 SELECT ROW_NUMBER() OVER(PARTITION BY B.CustomerID  ORDER BY  B.CustomerID ) 
 ROW ,B.CustomerID,
 C.AssetClassName as AssetClassOrg,B.AssetClass as AssetClassUpload from PRO.CustomerCal_Hist A
INNER JOIN UploadCustMocUpload B ON A.RefCustomerID=B.CustomerID
INNER JOIN DimAssetClass C ON A.SysAssetClassAlt_Key=C.AssetClassAlt_Key
)X
 WHERE ROW=1
 

SELECT * into AssetClassData  FROM(
 SELECT ROW_NUMBER() OVER(PARTITION BY AssetClass  ORDER BY  AssetClass ) 
 ROW ,AssetClass FROM UploadCustMocUpload
)X
 WHERE ROW=1

  SELECT  @DuplicateAssetClassInt=COUNT(*) FROM AssetClassData A
 Left JOIN DimAssetClass B
 ON  A.AssetClass=B.AssetClassName
 Where B.AssetClassName IS NULL


     IF @DuplicateAssetClassInt>0

	    BEGIN
		      UPDATE UploadCustMocUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid value in column ‘Asset Class’. Kindly enter the values as mentioned in the ‘Asset Class’ master and upload again. Click on ‘Download Master value’ to download the valid values for the
 column'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid value in column ‘Asset Class’. Kindly enter the values as mentioned in the ‘Asset Class’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'     END  
        ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Asset Class' ELSE   ErrorinColumn +','+SPACE(1)+'Asset Class' END     
		,Srnooferroneousrows=V.SlNo
		 FROM UploadCustMocUpload V  
 WHERE ISNULL(AssetClass,'')<>''
 AND  V.AssetClass IN(
				
						  SELECT   A.AssetClass FROM AssetClassData A
						 Left JOIN DimAssetClass B
						 ON  A.AssetClass=B.AssetClassName
						 Where B.AssetClassName IS NULL


				 )
		END

		
 -- UPDATE UploadCustMocUpload
	--SET  
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'You have AssetClass STANDARD and You can change it only SUB-STANDARD. '     
	--					ELSE ErrorMessage+','+SPACE(1)+'You have AssetClass STANDARD and You can change it only SUB-STANDARD '    END
	--	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'AssetClass' ELSE   ErrorinColumn +','+SPACE(1)+'AssetClass' END   
	--	,Srnooferroneousrows=V.SlNo
								
   
 --  FROM UploadCustMocUpload V 
   
 --WHERE V.CustomerID IN(Select B.CustomerID
	--		  FROM AssetClassValidationData B					
	--		    WHERE (Case When ISNULL(B.AssetClassOrg,'') ='STANDARD' AND ISNULL(B.AssetClassUpload,'') NOT IN('SUB-STANDARD','','STANDARD') Then 1
 --              Else 0 END)=1)
			

	--   UPDATE UploadCustMocUpload
	--SET  
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'You have AssetClass SUB-STANDARD and You can change it only STANDARD,DOUBTFUL I,LOS '     
	--					ELSE ErrorMessage+','+SPACE(1)+'You have AssetClass SUB-STANDARD and You can change it only STANDARD,DOUBTFUL I,LOS. '    END
	--	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'AssetClass' ELSE   ErrorinColumn +','+SPACE(1)+'AssetClass' END   
	--	,Srnooferroneousrows=V.SlNo
								
 --   FROM UploadCustMocUpload V 
 -- WHERE V.CustomerID IN(Select B.CustomerID
	--		  FROM AssetClassValidationData B					
	--		    WHERE (Case When ISNULL(AssetClassOrg,'') ='SUB-STANDARD' AND ISNULL(AssetClassUpload,'') NOT IN('STANDARD','DOUBTFUL I','LOS','SUB-STANDARD') Then 1
	--				 Else 0 END)=1
	--				 )

					 
 --------------NPADATE-----------------------
 Set DateFormat DMY

 UPDATE UploadCustMocUpload 
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'NPADATE' ELSE   ErrorinColumn +','+SPACE(1)+'NPADATE' END      
		,Srnooferroneousrows=V.SlNo
		  

 FROM UploadCustMocUpload V  
 WHERE    ISDATE(NPADATE)=0  AND  ISNULL(NPADATE,'')<>'' 
 
 


 UPDATE UploadCustMocUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'NPA Date is mandatory since ‘Asset class’ is set as NPA. Kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'NPA Date is mandatory since ‘Asset class’ is set as NPA. Kindly check and upload again'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'NPADATE' ELSE   ErrorinColumn +','+SPACE(1)+'NPADATE' END      
		,Srnooferroneousrows=V.SlNo
		  

 FROM UploadCustMocUpload V  
 WHERE ISNULL(AssetClass,'') IN('NPA') AND (NPADATE)=''


  UPDATE UploadCustMocUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'NPA Date must be blank since ‘Asset class’ is STD. Kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'NPA Date must be blank since ‘Asset class’ is STD. Kindly check and upload again'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'NPADATE' ELSE   ErrorinColumn +','+SPACE(1)+'NPADATE' END      
		,Srnooferroneousrows=V.SlNo
		  

 FROM UploadCustMocUpload V  
 WHERE (ISNULL(AssetClass,'') IN('STANDARD') or ISNULL(AssetClass,'') IS NULL) AND (NPADATE)<>''

 Set DateFormat DMY
 UPDATE UploadCustMocUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'NPA date must be less than equal to current date. Kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'NPA date must be less than equal to current date. Kindly check and upload again'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'NPADATE' ELSE   ErrorinColumn +','+SPACE(1)+'NPADATE' END      
		,Srnooferroneousrows=V.SlNo
		

 FROM UploadCustMocUpload V  
 WHERE (Case When ISDATE(NPADATE)=1 Then Case When Cast(NPADATE as date)>Cast(GETDATE() as Date) Then 1 Else 0 END END)=1
 
 

   UPDATE UploadCustMocUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'NPA Date is mandatory  since ‘Asset class’ is not STANDARD. Kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'NPA Date is mandatory  since ‘Asset class’ is not STANDARD. Kindly check and upload again'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'NPADATE' ELSE   ErrorinColumn +','+SPACE(1)+'NPADATE' END      
		,Srnooferroneousrows=V.SlNo
		  

 FROM UploadCustMocUpload V  
 WHERE (ISNULL(AssetClass,'') NOT IN('STANDARD','') ) AND (NPADATE)=''


  


 --------------security value----------------

 UPDATE UploadCustMocUpload
	SET  
        ErrorMessage= CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid Security value Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid Security value Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Security value' ELSE ErrorinColumn +','+SPACE(1)+  'Security value' END  
		,Srnooferroneousrows=V.SlNo
--						
 FROM UploadCustMocUpload V  
 WHERE ISNULL(Securityvalue,'')<>''
AND (CHARINDEX('.',ISNULL(Securityvalue,''))>0  AND Len(Right(ISNULL(Securityvalue,''),Len(ISNULL(Securityvalue,''))-CHARINDEX('.',ISNULL(Securityvalue,''))))<>2)





  UPDATE UploadCustMocUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid value in ‘Security Value’ column. Kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid value in ‘Security Value’ column. Kindly check and upload again '    END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SecurityValue' ELSE   ErrorinColumn +','+SPACE(1)+'SecurityValue' END   
		,Srnooferroneousrows=V.SlNo
								
   
   FROM UploadCustMocUpload V  
   WHERE (ISNUMERIC(Securityvalue)=0 AND ISNULL(Securityvalue,'')<>'') OR 
 ISNUMERIC(Securityvalue) LIKE '%^[0-9]%'




 --------------Additional Provision%-----------------
 
-- UPDATE UploadCustMocUpload
--	SET  
--        ErrorMessage= CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid Security value Please check the values and upload again'     
--						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid Security value Please check the values and upload again'     END
--		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Security value' ELSE ErrorinColumn +','+SPACE(1)+  'Security value' END  
--		,Srnooferroneousrows=V.SlNo
----						
-- FROM UploadCustMocUpload V  
-- WHERE ISNULL(Securityvalue,'')<>''
--AND (CHARINDEX('.',ISNULL(AdditionalProvision,''))>0  AND Len(Right(ISNULL(AdditionalProvision,''),Len(ISNULL(AdditionalProvision,''))-CHARINDEX('.',ISNULL(AdditionalProvision,''))))<>2)


--  UPDATE UploadCustMocUpload
--	SET  
--        ErrorMessage= CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid values in ‘Additional Provision %’. Kindly check and upload again'     
--						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid values in ‘Additional Provision %’. Kindly check and upload again'     END
--		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Additional Provision%' ELSE ErrorinColumn +','+SPACE(1)+  'Additional Provision%' END  
--		,Srnooferroneousrows=V.SlNo
----							

-- FROM UploadCustMocUpload V  
-- WHERE ISNULL([AdditionalProvision],'')<>''
-- AND Convert(Decimal(5,2),ISNULL(AdditionalProvision,'0'))>100

--UPDATE UploadCustMocUpload
--	SET  
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid values in ‘Additional Provision %’. Kindly check and upload again'     
--						ELSE ErrorMessage+','+SPACE(1)+'Invalid values in ‘Additional Provision %’. Kindly check and upload again '    END
--		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Additional Provision%' ELSE   ErrorinColumn +','+SPACE(1)+'Additional Provision%' END   
--		,Srnooferroneousrows=V.SlNo
								
   
--   FROM UploadCustMocUpload V  
--   WHERE (ISNUMERIC(AdditionalProvision)=0 AND ISNULL(AdditionalProvision,'')<>'') OR 
-- ISNUMERIC(AdditionalProvision) LIKE '%^[0-9]%'


-- UPDATE UploadCustMocUpload
--	SET  
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid values in ‘Additional Provision ’. Kindly check and upload again'     
--						ELSE ErrorMessage+','+SPACE(1)+'Invalid values in ‘Additional Provision ’. Kindly check and upload again '    END
--		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Additional Provision' ELSE   ErrorinColumn +','+SPACE(1)+'Additional Provision' END   
--		,Srnooferroneousrows=V.SlNo
								
   
--   FROM UploadCustMocUpload V  
--   WHERE (CHARINDEX('.',AdditionalProvision))>0


 -----------------------------------------------------------------

 


 -------------MOCSource--------------------
   Declare @ValidSourceInt int=0

	

	IF OBJECT_ID('MocSourceData') IS NOT NULL  
	  BEGIN  
	   DROP TABLE MocSourceData  
	
	  END

SELECT * into MocSourceData  FROM(
 SELECT ROW_NUMBER() OVER(PARTITION BY MOCSOURCE  ORDER BY  MOCSOURCE ) 
 ROW ,MOCSOURCE FROM UploadCustMocUpload
)X
 WHERE ROW=1


   SELECT  @ValidSourceInt=COUNT(*) FROM MocSourceData A
 Left JOIN DimMOCType B
 ON  A.MOCSOURCE=B.MOCTypeName
 AND   EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey
Where B.MOCTypeName IS NULL

   IF @ValidSourceInt>0

     BEGIN
	         UPDATE UploadCustMocUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid value in column ‘MOC Source’. Kindly enter the values as mentioned in the ‘MOC Source’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid value in column ‘MOC Source’. Kindly enter the values as mentioned in the ‘MOC Source’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'     END  
        ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'MOCSOURCE' ELSE   ErrorinColumn +','+SPACE(1)+'MOCSOURCE' END     
		,Srnooferroneousrows=V.SlNo
		 FROM UploadCustMocUpload V  
 WHERE ISNULL(MOCSOURCE,'')<>''
 AND  V.MOCSOURCE IN(
				SELECT  A.MOCSOURCE FROM MocSourceData A
					 Left JOIN DimMOCType B
					 ON  A.MOCSOURCE=B.MOCTypeName
	                 AND   EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey

					 Where B.MOCTypeName IS NULL
				 )

	 END


	 UPDATE UploadCustMocUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'MOC source can not be blank,  Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'MOC source can not be blank,  Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'MOCSOURCE' ELSE   ErrorinColumn +','+SPACE(1)+'MOCSOURCE' END       
		,Srnooferroneousrows=V.SlNo
	
   
   FROM UploadCustMocUpload V  
 WHERE ISNULL(MOCSOURCE,'')=''
 
 

---------------MOCType---------------------
Print 'MOCType'

	  UPDATE UploadCustMocUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'MOCType is mandatory . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'MOCType is mandatory . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'MOCType' ELSE   ErrorinColumn +','+SPACE(1)+'MOCType' END   
		,Srnooferroneousrows=V.SlNo
							
   
   FROM UploadCustMocUpload V  
 WHERE ISNULL(MOCType,'')=''

 UPDATE UploadCustMocUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'MOC Type column will only accept value – Auto or Manual. Kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'MOC Type column will only accept value – Auto or Manual. Kindly check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'MOCType' ELSE   ErrorinColumn +','+SPACE(1)+'MOCType' END   
		,Srnooferroneousrows=V.SlNo
							
   
   FROM UploadCustMocUpload V  
 WHERE ISNULL(MOCType,'') NOT IN('Auto','Manual')



 ----------------MOCReason---------------------

 Print 'MOCReason'
 UPDATE UploadCustMocUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'MOC Reason column is mandatory. Kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'MOC Reason column is mandatory. Kindly check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'MOCReason' ELSE   ErrorinColumn +','+SPACE(1)+'MOCReason' END   
		,Srnooferroneousrows=V.SlNo
								--STUFF((SELECT ','+SlNo 
								--FROM UploadCustMocUpload A
								--WHERE A.SlNo IN(SELECT V.SlNo  FROM UploadCustMocUpload V  
								--WHERE ISNULL(SOLID,'')='')
								--FOR XML PATH ('')
								--),1,1,'')
   
FROM UploadCustMocUpload V  
 WHERE ISNULL(MOCReason,'')=''


 UPDATE UploadCustMocUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'MOC reason cannot be greater than 500 characters'     
						ELSE ErrorMessage+','+SPACE(1)+ 'MOC reason cannot be greater than 500 characters'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'MOCReason' ELSE   ErrorinColumn +','+SPACE(1)+'MOCReason' END      
		,Srnooferroneousrows=V.SlNo
		--STUFF((SELECT ','+SlNo 
		--						FROM #UploadNewAccount A
		--						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
		--										WHERE ISNULL(AssetClass,'')<>'' AND ISNULL(AssetClass,'')<>'STD' and  ISNULL(NPADate,'')=''
		--										)
		--						FOR XML PATH ('')
		--						),1,1,'')   

 FROM UploadCustMocUpload V  
 WHERE LEN(MOCReason)>500



 UPDATE UploadCustMocUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'For MOC reason column, special characters - , /\ are allowed. Kindly check and try again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'For MOC reason column, special characters - , /\ are allowed. Kindly check and try again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'MOC reason' ELSE ErrorinColumn +','+SPACE(1)+  'MOC reason' END  
		,Srnooferroneousrows=V.SlNo
--								----STUFF((SELECT ','+SlNo 
--								----FROM UploadCustMocUpload A
--								----WHERE A.SlNo IN(SELECT V.SlNo FROM UploadCustMocUpload V
--								---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
--								----)
--								----FOR XML PATH ('')
--								----),1,1,'')   

 FROM UploadCustMocUpload V  
 WHERE ISNULL(MOCReason,'') LIKE'%[!@#$%^&*()_+=]%'


 Print 'a1'
 -----------------------------------------------------------------
 /*validations on MOC Reason */

  Declare @ValidReasonnt int=0

	

	IF OBJECT_ID('MocSourceData') IS NOT NULL  
	  BEGIN  
	   DROP TABLE MocReasonData  
	
	  END

	  --Select * from MocReasonData

SELECT * into MocReasonData  FROM(
 SELECT ROW_NUMBER() OVER(PARTITION BY MOCReason  ORDER BY  MOCReason ) 
 ROW ,MOCReason FROM UploadCustMocUpload
)X
 WHERE ROW=1


   SELECT  @ValidReasonnt=COUNT(*) FROM MocReasonData A
 Left JOIN
 (select ParameterAlt_Key,
			 ParameterName 
			 ,'MOCReason' as TableName
			 from DimParameter
			 where EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey and
			  DimParameterName	= 'DimMOCReason') B
 ON  A.MOCReason=B.ParameterName
 Where B.ParameterName IS NULL
 --AND   A.EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey

   IF @ValidReasonnt>0

     BEGIN
	         UPDATE UploadCustMocUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid value in column ‘MOC Reason’. Kindly enter the values as mentioned in the ‘MOC Reason’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid value in column ‘MOC Reason’. Kindly enter the values as mentioned in the ‘MOC Source’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'     END  
        ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'MOCReason' ELSE   ErrorinColumn +','+SPACE(1)+'MOCReason' END     
		,Srnooferroneousrows=V.SlNo
		 FROM UploadCustMocUpload V  
 WHERE ISNULL(MOCReason,'')<>''
 AND  V.MOCReason IN(
			 SELECT A.MOCReason FROM MocReasonData A
						 Left JOIN
						 (select ParameterAlt_Key,
									 ParameterName 
									 ,'MOCReason' as TableName
									 from DimParameter
									 where EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey and
									  DimParameterName	= 'DimMOCReason'
									  
									  ) B
						 ON  A.MOCReason=B.ParameterName
						 Where B.ParameterName IS NULL
					 --AND   EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey
				 )

	 END


	Print'2a'

 ----------------------------------

 ----------------------------------------------
  
  /*validations on SourceSystem*/
--    Declare @DuplicateSourceSystemDataInt int=0

	

--	IF OBJECT_ID('SourceSystemData') IS NOT NULL  
--	  BEGIN  
--	   DROP TABLE SourceSystemData 
	
--	  END

--	   SELECT * into SourceSystemData  FROM(
-- SELECT ROW_NUMBER() OVER(PARTITION BY SourceSystem  ORDER BY  SourceSystem ) 
-- ROW ,SourceSystem FROM UploadCustMocUpload
--)X
-- WHERE ROW=1

 
--  SELECT  @DuplicateSourceSystemDataInt=COUNT(*) FROM UploadCustMocUpload A
-- Left JOIN DIMSOURCEDB B
-- ON  A.SourceSystem=B.SourceName
-- Where B.SourceName IS NULL

--    IF @DuplicateSourceSystemDataInt>0

--	BEGIN
--	       UPDATE UploadCustMocUpload
--	SET  
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid value in column ‘SourceSystem’. Kindly enter the values as mentioned in the ‘Segment’ master and upload again. Click on ‘Download Master value’ to download the valid values for theco
--lumn'     
--						ELSE ErrorMessage+','+SPACE(1)+'Invalid value in column ‘SourceSystem’. Kindly enter the values as mentioned in the ‘Segment’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'     END  
--        ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SourceSystem' ELSE   ErrorinColumn +','+SPACE(1)+'SourceSystem' END     
--		,Srnooferroneousrows=V.SlNo
--		 FROM UploadCustMocUpload V  
-- WHERE ISNULL(SourceSystem,'')<>''
-- AND  V.SourceSystem IN(
--                     SELECT  A.SourceSystem FROM UploadCustMocUpload A
--					 Left JOIN DIMSOURCEDB B
--					 ON  A.SourceSystem=B.SourceName
--					 Where B.SourceName IS NULL
--                 )
			

				 
--	END
------------------------------------------------------

 Print '123'
 goto valid

  END
	
   ErrorData:  
   print 'no'  

		SELECT *,'Data'TableName
		FROM dbo.MasterUploadData WHERE FileNames=@filepath 
		return

   valid:
		IF NOT EXISTS(Select 1 from  CustlevelNPAMOCDetails_stg WHERE filname=@FilePathUpload)
		BEGIN
		PRINT 'NO ERRORS'
			
			Insert into dbo.MasterUploadData
			(SR_No,ColumnName,ErrorData,ErrorType,FileNames,Flag) 
			SELECT '' SlNo , '' ColumnName,'' ErrorData,'' ErrorType,@filepath,'SUCCESS' 
			
		END
		ELSE
		BEGIN
			PRINT 'VALIDATION ERRORS'
			Insert into dbo.MasterUploadData
			(SR_No,ColumnName,ErrorData,ErrorType,FileNames,Srnooferroneousrows,Flag) 
			SELECT SlNo,ErrorinColumn,ErrorMessage,ErrorinColumn,@filepath,Srnooferroneousrows,'SUCCESS' 
			FROM UploadCustMocUpload 


			
		--	----SELECT * FROM UploadCustMocUpload 

		--	--ORDER BY ErrorMessage,UploadCustMocUpload.ErrorinColumn DESC
			goto final
		END

		

  IF EXISTS (SELECT 1 FROM  dbo.MasterUploadData   WHERE FileNames=@filepath AND  ISNULL(ERRORDATA,'')<>'') 
   -- added for delete Upload status while error while uploading data.  
   BEGIN  
   --SELECT * FROM #OAOLdbo.MasterUploadData
    delete from UploadStatus where FileNames=@filepath  
   END  
  --ELSE IF EXISTS (SELECT 1 FROM  UploadStatus where ISNULL(InsertionOfData,'')='' and FileNames=@filepath and UploadedBy=@UserLoginId)  -- added validated condition successfully, delete filename from Upload status  
  --  BEGIN  
  --  print 'RC'  
  --   delete from UploadStatus where FileNames=@filepath  
  --  END    --commented in [OAProvision].[GetStatusOfUpload] SP for checkin 'InsertionOfData' Flag  
  ELSE  
   BEGIN   
  
    Update UploadStatus Set ValidationOfData='Y',ValidationOfDataCompletedOn=GetDate()   
    where FileNames=@filepath  
  
   END  


  final:
IF EXISTS(SELECT 1 FROM dbo.MasterUploadData WHERE FileNames=@filepath AND ISNULL(ERRORDATA,'')<>'') 
	BEGIN
	PRINT 'ERROR'
		SELECT SR_No
				,ColumnName
				,ErrorData
				,ErrorType
				,FileNames
				,Flag
				,Srnooferroneousrows,'Validation'TableName
		FROM dbo.MasterUploadData
		WHERE FileNames=@filepath
		--(SELECT *,ROW_NUMBER() OVER(PARTITION BY ColumnName,ErrorData,ErrorType,FileNames ORDER BY ColumnName,ErrorData,ErrorType,FileNames )AS ROW 
		--FROM  dbo.MasterUploadData    )a 
		--WHERE A.ROW=1
		--AND FileNames=@filepath
		--AND ISNULL(ERRORDATA,'')<>''
	
		ORDER BY SR_No 
		 IF EXISTS(SELECT 1 FROM CustlevelNPAMOCDetails_stg WHERE filname=@FilePathUpload)
		 BEGIN
		 DELETE FROM CustlevelNPAMOCDetails_stg
		 WHERE filname=@FilePathUpload
		 
		 PRINT 1

		 PRINT 'ROWS DELETED FROM DBO.CustlevelNPAMOCDetails_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
		 END

	END
	ELSE
	BEGIN
	PRINT ' DATA NOT PRESENT'
		--SELECT *,'Data'TableName
		--FROM dbo.MasterUploadData WHERE FileNames=@filepath 
		--ORDER BY ErrorData DESC
		SELECT SR_No,ColumnName,ErrorData,ErrorType,FileNames,Flag,Srnooferroneousrows,'Data'TableName 
		FROM
		(
			SELECT *,ROW_NUMBER() OVER(PARTITION BY ColumnName,ErrorData,ErrorType,FileNames,Flag,Srnooferroneousrows
			ORDER BY ColumnName,ErrorData,ErrorType,FileNames,Flag,Srnooferroneousrows)AS ROW 
			FROM  dbo.MasterUploadData    
		)a 
		WHERE A.ROW=1
		AND FileNames=@filepath

	END

	----SELECT * FROM UploadCustMocUpload

	print 'p'

   
END  TRY
  
  BEGIN CATCH
	

	INSERT INTO dbo.Error_Log
				SELECT ERROR_LINE() as ErrorLine,ERROR_MESSAGE()ErrorMessage,ERROR_NUMBER()ErrorNumber
				,ERROR_PROCEDURE()ErrorProcedure,ERROR_SEVERITY()ErrorSeverity,ERROR_STATE()ErrorState
				,GETDATE()

	IF EXISTS(SELECT 1 FROM CustlevelNPAMOCDetails_stg WHERE filname=@FilePathUpload)
		 BEGIN
		 DELETE FROM CustlevelNPAMOCDetails_stg
		 WHERE filname=@FilePathUpload

		 PRINT 'ROWS DELETED FROM DBO.CustlevelNPAMOCDetails_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
		 END

END CATCH

END
  





GO