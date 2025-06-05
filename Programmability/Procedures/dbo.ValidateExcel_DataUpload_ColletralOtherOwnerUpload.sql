SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[ValidateExcel_DataUpload_ColletralOtherOwnerUpload]
@MenuID INT=10,  
@UserLoginId  VARCHAR(20)='fnachecker',  
@Timekey INT=49999
,@filepath VARCHAR(MAX) ='IBPCUPLOAD.xlsx'  
WITH RECOMPILE  
AS  
  
  --fnasuperadmin_IBPCUPLOAD.xlsx

--DECLARE  
  
--@MenuID INT=1458,  
--@UserLoginId varchar(20)='FNASUPERADMIN',  
--@Timekey int=49999
--,@filepath varchar(500)='fnasuperadmin_IBPCUPLOAD.xlsx'  
  
BEGIN

BEGIN TRY  
--BEGIN TRAN  
  
--Declare @TimeKey int  
    --Update UploadStatus Set ValidationOfData='N' where FileNames=@filepath  
     
	 SET DATEFORMAT DMY

 --Select @Timekey=Max(Timekey) from dbo.SysProcessingCycle  
 -- where  ProcessType='Quarterly' ----and PreMOC_CycleFrozenDate IS NULL
 
 Select   @Timekey=Max(Timekey) from sysDayMatrix where Cast(date as Date)=cast(getdate() as Date)

  PRINT @Timekey  
  
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


IF (@MenuID=24703)	
BEGIN


	  -- IF OBJECT_ID('tempdb..UploadOtherOwnerDetail') IS NOT NULL  
	  IF OBJECT_ID('UploadOtherOwnerDetail') IS NOT NULL  
	  BEGIN  
	   DROP TABLE UploadOtherOwnerDetail  
	
	  END
	  
  IF NOT (EXISTS (SELECT * FROM CollateralOthOwnerDetails_stg where filname=@FilePathUpload))

BEGIN
print 'NO DATA'
			Insert into dbo.MasterUploadData
			(SR_No,ColumnName,ErrorData,ErrorType,FileNames,Flag) 
			SELECT 0 SRNO , '' ColumnName,'No Record found' ErrorData,'No Record found' ErrorType,@filepath,'SUCCESS' 
			--SELECT 0 SRNO , '' ColumnName,'' ErrorData,'' ErrorType,@filepath,'SUCCESS' 

			goto errordata
    
END

ELSE
BEGIN
PRINT 'DATA PRESENT'
	   Select *,CAST('' AS varchar(MAX)) ErrorMessage,CAST('' AS varchar(MAX)) ErrorinColumn,CAST('' AS varchar(MAX)) Srnooferroneousrows
 	   into UploadOtherOwnerDetail 
	   from CollateralOthOwnerDetails_stg 
	   WHERE filname=@FilePathUpload

	  
END


  ------------------------------------------------------------------------------  
   
	--SrNo	Territory	ACID	InterestReversalAmount	filname
	
	UPDATE UploadOtherOwnerDetail
	SET  
        ErrorMessage='There is no data in excel. Kindly check and upload again' 
		,ErrorinColumn='CollateralID,Customer of theBank,Customer ID,Other Owner Name,Other Owner Relationship,Address Type,Balances,Dates'    
		,Srnooferroneousrows=''
 FROM UploadOtherOwnerDetail V  
 WHERE ISNULL(SystemCollateralID,'')=''
AND ISNULL(CustomeroftheBank,'')=''
AND ISNULL(CustomerID,'')=''
AND ISNULL(OtherOwnerName,'')=''
AND ISNULL(OtherOwnerRelationship,'')=''
AND ISNULL(Ifrelativeentervalue,'')=''
AND ISNULL(AddressType,'')=''
AND ISNULL(AddressCategory,'')=''
AND ISNULL(AddressLine1,'')=''
AND ISNULL(AddressLine2,'')=''
AND ISNULL(AddressLine3,'')=''
AND ISNULL(City,'')=''
AND ISNULL(PinCode,'')=''
AND ISNULL(Country,'')=''
AND ISNULL(District,'')=''
AND ISNULL(StdCodeO,'')=''
AND ISNULL(PhoneNoO,'')=''
AND ISNULL(StdCodeR,'')=''
AND ISNULL(PhoneNoR,'')=''
AND ISNULL(MobileNo,'')=''
AND ISNULL(StdCodeO,'')=''

  
--WHERE ISNULL(V.SrNo,'')=''
-- ----AND ISNULL(Territory,'')=''
-- AND ISNULL(AccountID,'')=''
-- AND ISNULL(PoolID,'')=''
-- AND ISNULL(filname,'')=''

  IF EXISTS(SELECT 1 FROM UploadOtherOwnerDetail WHERE ISNULL(ErrorMessage,'')<>'')
  BEGIN
  PRINT 'NO DATA'
  GOTO ERRORDATA;
  END

    /*validations on Sl. No.*/
 ------------------------------------------------------------

  Declare @DuplicateCnt int=0
   UPDATE UploadOtherOwnerDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'SrNo cannot be blank . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'SrNo cannot be blank . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' ELSE   ErrorinColumn +','+SPACE(1)+'SrNo' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadOtherOwnerDetail V  
 WHERE ISNULL(SrNo,'')=''

  UPDATE UploadOtherOwnerDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid Sl. No., kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid Sl. No., kindly check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' ELSE   ErrorinColumn +','+SPACE(1)+'SrNo' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadOtherOwnerDetail V  
  WHERE (ISNUMERIC(SrNo)=0 AND ISNULL(SrNo,'')<>'') OR 
 ISNUMERIC(SrNo) LIKE '%^[0-9]%'

 UPDATE UploadOtherOwnerDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Special characters not allowed, kindly remove and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Special characters not allowed, kindly remove and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' ELSE   ErrorinColumn +','+SPACE(1)+'SrNo' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadOtherOwnerDetail V  
   WHERE ISNULL(SrNo,'') LIKE'%[,!@#$%^&*()_-+=/]%'

   --
  SELECT @DuplicateCnt=Count(1)
FROM UploadOtherOwnerDetail
GROUP BY  SrNo
HAVING COUNT(SrNo) >1;

IF (@DuplicateCnt>0)

 UPDATE UploadOtherOwnerDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Duplicate Sl. No., kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Duplicate Sl. No., kindly check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' ELSE   ErrorinColumn +','+SPACE(1)+'SrNo' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadOtherOwnerDetail V  
   Where ISNULL(SrNo,'') In(  
   SELECT SrNo
	FROM UploadOtherOwnerDetail
	GROUP BY  SrNo
	HAVING COUNT(SrNo) >1

)
 -----------------------------------------------------------
  /*validations on System CollateralID*/
 ------------------------------------------------------------
  Declare @SystemCollateralIDCnt int=0,@SystemCollateralIDMgmtCnt int=0
 IF OBJECT_ID('SystemCollateralIDData') IS NOT NULL  
	  BEGIN  
	   DROP TABLE SystemCollateralIDData  
	
	  END

SELECT * into SystemCollateralIDData  FROM(
 SELECT ROW_NUMBER() OVER(PARTITION BY SystemCollateralID  ORDER BY  SystemCollateralID ) 
 ROW ,SystemCollateralID FROM UploadOtherOwnerDetail
 )X
 WHERE ROW=1

  SELECT  @SystemCollateralIDCnt=Count(*) FROM UploadOtherOwnerDetail A
 LEFT JOIN CollateralMgmt B
 ON  A.SystemCollateralID=B.CollateralID
 Where B.CollateralID IS NULL

 SELECT  @SystemCollateralIDMgmtCnt=Count(*) FROM UploadOtherOwnerDetail A
 LEFT JOIN CollateralMgmt_Mod B
 ON  A.SystemCollateralID=B.CollateralID
 Where B.CollateralID IS NULL
  
  IF    (@SystemCollateralIDCnt>0 OR @SystemCollateralIDMgmtCnt>0)
  BEGIN
  UPDATE UploadOtherOwnerDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'System Collateral ID cannot be blank . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'System Collateral ID cannot be blank . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'System CollateralID' ELSE   ErrorinColumn +','+SPACE(1)+'System CollateralID' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadOtherOwnerDetail V  
 WHERE ISNULL(SystemCollateralID,'')=''
 AND  V.SystemCollateralID IN(
				 SELECT  A.SystemCollateralID FROM UploadOtherOwnerDetail A
					 LEFT JOIN CollateralMgmt B
					 ON  A.SystemCollateralID=B.CollateralID
					 Where B.CollateralID IS NULL
				 )


UPDATE UploadOtherOwnerDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'System Collateral ID cannot be blank . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'System Collateral ID cannot be blank . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'System CollateralID' ELSE   ErrorinColumn +','+SPACE(1)+'System CollateralID' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadOtherOwnerDetail V  
 WHERE ISNULL(SystemCollateralID,'')=''
 AND  V.SystemCollateralID IN(
				 SELECT  A.SystemCollateralID FROM UploadOtherOwnerDetail A
					 LEFT JOIN CollateralMgmt_Mod B
					 ON  A.SystemCollateralID=B.CollateralID
					 Where B.CollateralID IS NULL
				 )
END

  -------------------------------------------------------------------

   /*validations on Customer of the Bank*/
 ------------------------------------------------------------
 
  UPDATE UploadOtherOwnerDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'SrNo cannot be blank . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'SrNo cannot be blank . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Customer of the Bank' ELSE   ErrorinColumn +','+SPACE(1)+'Customer of the Bank' END       
		,Srnooferroneousrows=V.SrNo

   
   FROM UploadOtherOwnerDetail V  
 WHERE ISNULL(CustomeroftheBank,'')=''

 UPDATE UploadOtherOwnerDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'SrNo cannot be blank . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'SrNo cannot be blank . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Customer of the Bank' ELSE   ErrorinColumn +','+SPACE(1)+'Customer of the Bank' END       
		,Srnooferroneousrows=V.SrNo

   
   FROM UploadOtherOwnerDetail V  
 WHERE ISNULL(CustomeroftheBank,'') NOT IN('Y','N')

 ------------------------------------------------------
 
   /*validations on Customer ID */
 ------------------------------------------------------------

 Declare @CustomerID INT=0
  IF OBJECT_ID('CustomerIDData') IS NOT NULL  
	  BEGIN  
	   DROP TABLE CustomerIDData  
	
	  END

SELECT * into CustomerIDData  FROM(
 SELECT ROW_NUMBER() OVER(PARTITION BY CustomerID  ORDER BY  CustomerID ) 
 ROW ,CustomerID FROM UploadOtherOwnerDetail
 )X
 WHERE ROW=1


 select @CustomerID=COUNT(*) from CustomerIDData a
 INNER JOIN customerbasicdetail b
 on a.CustomerID=b.CustomerID 
 where  b.CustomerID  IS NULL

  UPDATE UploadOtherOwnerDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Customer ID is blank. Kindly update and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Customer ID is blank. Kindly update and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Customer ID' ELSE   ErrorinColumn +','+SPACE(1)+'Customer ID' END       
		,Srnooferroneousrows=V.SrNo

   
   FROM UploadOtherOwnerDetail V  
 WHERE ISNULL(CustomerID,'')='' 

 UPDATE UploadOtherOwnerDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Special characters - _ \ / are allowed, kindly remove and try again'     
						ELSE ErrorMessage+','+SPACE(1)+'Special characters - _ \ / are allowed, kindly remove and try again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Customer ID' ELSE   ErrorinColumn +','+SPACE(1)+'Customer ID' END       
		,Srnooferroneousrows=V.SrNo

   
   FROM UploadOtherOwnerDetail V  
 WHERE ISNULL(AddressLine1,'') LIKE'%- \ / _%'

  UPDATE UploadOtherOwnerDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Customer ID is mandatory, since other owner is customer of the Bank. Kindly update and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Customer ID is mandatory, since other owner is customer of the Bank. Kindly update and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Customer ID' ELSE   ErrorinColumn +','+SPACE(1)+'Customer ID' END       
		,Srnooferroneousrows=V.SrNo

   
   FROM UploadOtherOwnerDetail V  
 WHERE ISNULL(CustomerID,'')='' AND  ISNULL(CustomeroftheBank,'') ='Y'



  IF    @CustomerID>0

  UPDATE UploadOtherOwnerDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Customer ID is invalid. Kindly check the entered customer id'     
						ELSE ErrorMessage+','+SPACE(1)+'Customer ID is invalid. Kindly check the entered customer id'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Customer IDD' ELSE   ErrorinColumn +','+SPACE(1)+'Customer ID' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadOtherOwnerDetail V  
 WHERE ISNULL(CustomerID,'')<>''
 AND  V.CustomerID IN(
				 select a.CustomerID from CustomerIDData a
						 INNER JOIN customerbasicdetail b
						 on a.CustomerID=b.CustomerID 
						 where  b.CustomerID  IS NULL)

-----------------------------------------------------------------------------
   /*validations on Other Owner name */
 ------------------------------------------------------------
 
 UPDATE UploadOtherOwnerDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Other Owner name cannot be blank . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Other Owner name cannot be blank . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Other Owner name' ELSE   ErrorinColumn +','+SPACE(1)+'Other Owner name' END       
		,Srnooferroneousrows=V.SrNo

   
   FROM UploadOtherOwnerDetail V  
 WHERE ISNULL(OtherOwnerName,'')='' 

 UPDATE UploadOtherOwnerDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Other Owner name cannot be more than 100 Character . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Other Owner name cannot be more than 100 Character . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Other Owner name' ELSE   ErrorinColumn +','+SPACE(1)+'Other Owner name' END       
		,Srnooferroneousrows=V.SrNo

   
   FROM UploadOtherOwnerDetail V  
 WHERE Len(OtherOwnerName)>100

 UPDATE UploadOtherOwnerDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Customer of the Bank’. In case otherwise, display error message “Other Owner Name is mandatory, since other owner is not a customer of the Bank. Kindly update and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Customer of the Bank’. In case otherwise, display error message “Other Owner Name is mandatory, since other owner is not a customer of the Bank. Kindly update and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Other Owner name' ELSE   ErrorinColumn +','+SPACE(1)+'Other Owner name' END       
		,Srnooferroneousrows=V.SrNo

   
   FROM UploadOtherOwnerDetail V  
 WHERE ISNULL(CustomerID,'')='' AND  ISNULL(CustomeroftheBank,'') ='N'

 ------------------------------------------------------------------------------
    /*validations on Other Owner Relationship */
 ------------------------------------------------------------
 Declare @CollateralOwnerType int=0
 IF OBJECT_ID('OtherOwnerRelationshipData') IS NOT NULL  
	  BEGIN  
	   DROP TABLE OtherOwnerRelationshipData  
	
	  END

	  
 SELECT * into OtherOwnerRelationshipData  FROM(
 SELECT ROW_NUMBER() OVER(PARTITION BY OtherOwnerRelationship  ORDER BY  OtherOwnerRelationship ) 
 ROW ,OtherOwnerRelationship FROM UploadOtherOwnerDetail
 )X
 WHERE ROW=1

 

  SELECT  @CollateralOwnerType=COUNT(*) FROM OtherOwnerRelationshipData A
 LEFT JOIN DimCollateralOwnerType B
 ON   A.OtherOwnerRelationship=B.CollOwnerDescription
 Where B.CollOwnerDescription IS NULL

 UPDATE UploadOtherOwnerDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Other Owner Relationship cannot be blank . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Other Owner Relationship cannot be blank . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Other Owner Relationship' ELSE   ErrorinColumn +','+SPACE(1)+'Other Owner Relationship' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadOtherOwnerDetail V  
 WHERE ISNULL(OtherOwnerRelationship,'')=''


   IF @CollateralOwnerType>0

BEGIN
 
   UPDATE UploadOtherOwnerDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid value in column ‘Other Owner Relationship’. Kindly enter the values as mentioned in the ‘Other Owner Relationship’ master and upload again. Click on ‘Download Master value’ to downloa


d the valid values for the column'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid value in column ‘Other Owner Relationship’. Kindly enter the values as mentioned in the ‘Other Owner Relationship’ master and upload again. Click on ‘Download Master value’ to download the valid values for the




 column'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Other Owner Relationship' ELSE   ErrorinColumn +','+SPACE(1)+'Other Owner Relationshipe' END     
		,Srnooferroneousrows=V.SrNo
	--	STUFF((SELECT ','+SRNO 
	--							FROM #UploadNewAccount A
	--							WHERE A.SrNo IN(SELECT V.SrNo FROM #UploadNewAccount V  
 --WHERE ISNULL(ACID,'')<>'' AND ISNULL(TERRITORY,'')<>''
 ----AND SRNO IN(SELECT Srno FROM #DUB2))
 --AND ACID IN(SELECT ACID FROM #DUB2 GROUP BY ACID))

	--							FOR XML PATH ('')
	--							),1,1,'')   

 FROM UploadOtherOwnerDetail V  
 WHERE ISNULL(OtherOwnerRelationship,'')<>''
 AND  V.OtherOwnerRelationship IN(
				 SELECT  A.OtherOwnerRelationship FROM OtherOwnerRelationshipData A
					 LEFT JOIN DimCollateralOwnerType B
					 ON  A.OtherOwnerRelationship=B.CollOwnerDescription
					 Where B.CollOwnerDescription IS NULL
				 )
 END 
 -------------------------------------------------------------

     /*validations on If Relative, enter value */
 ------------------------------------------------------------
   UPDATE UploadOtherOwnerDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'If Relative, enter value is Invalid . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'If Relative, enter value is Invalid . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Relative, enter value' ELSE   ErrorinColumn +','+SPACE(1)+'Relative, enter value' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadOtherOwnerDetail V  
 WHERE ISNULL(Ifrelativeentervalue,'')=''

  UPDATE UploadOtherOwnerDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'If Relative, enter value is Invalid . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'If Relative, enter value is Invalid . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Relative, enter value' ELSE   ErrorinColumn +','+SPACE(1)+'Relative, enter value' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadOtherOwnerDetail V  
 WHERE LEN(Ifrelativeentervalue)>100

  UPDATE UploadOtherOwnerDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN '’If Relative, enter value’ is mandatory, since value ‘Relative’ is entered in column ‘Other Owner Relationship’. Kindly update and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'’If Relative, enter value’ is mandatory, since value ‘Relative’ is entered in column ‘Other Owner Relationship’. Kindly update and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Relative, enter value' ELSE   ErrorinColumn +','+SPACE(1)+'Relative, enter value' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadOtherOwnerDetail V  
 WHERE ISNULL(OtherOwnerRelationship,'')='Relative'  AND ISNULL(Ifrelativeentervalue,'')=''

 ----------------------------------------------------------------------
      /*validations on Address Type */
 ------------------------------------------------------------
 --UPDATE UploadOtherOwnerDetail
	--SET  
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Address Type is blank . Please check the values and upload again'     
	--					ELSE ErrorMessage+','+SPACE(1)+'Address Type is blank . Please check the values and upload again'     END
	--	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Address Type' ELSE   ErrorinColumn +','+SPACE(1)+'Address Type' END   
	--	,Srnooferroneousrows=V.SrNo
								
   
 --  FROM UploadOtherOwnerDetail V  
 --WHERE ISNULL(AddressType,'')=''

 UPDATE UploadOtherOwnerDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Address Type is Invalid . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Address Type is Invalid . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Address Type' ELSE   ErrorinColumn +','+SPACE(1)+'Address Type' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadOtherOwnerDetail V  
 WHERE LEN(AddressType)>200

  UPDATE UploadOtherOwnerDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid value in column ‘Address Type’. Kindly enter ‘Owned Leased or Rent’ and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid value in column ‘Address Type’. Kindly enter ‘Owned Leased or Rent’ and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Address Type' ELSE   ErrorinColumn +','+SPACE(1)+'Address Type' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadOtherOwnerDetail V  
 WHERE   ISNULL(AddressType,'') NOT IN('Owned', 'Leased', 'Rent','')
 ------------------------------------------------------------------------------
       /*validations on Address Category */
 ------------------------------------------------------------
 Declare @AddressCategoryCnt int=0
 IF OBJECT_ID('AddressCategoryData') IS NOT NULL  
	  BEGIN  
	   DROP TABLE AddressCategoryData  
	
	  END

	  
 SELECT * into AddressCategoryData  FROM(
 SELECT ROW_NUMBER() OVER(PARTITION BY AddressCategory  ORDER BY  AddressCategory ) 
 ROW ,AddressCategory FROM UploadOtherOwnerDetail
 )X
 WHERE ROW=1

 

  SELECT  @AddressCategoryCnt=COUNT(*) FROM AddressCategoryData A
 LEFT JOIN DimAddressCategory B
 ON  A.AddressCategory=B.AddressCategoryName
 Where B.AddressCategoryName IS NULL

 

UPDATE UploadOtherOwnerDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Address Category cannot be blank . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Address Category cannot be blank . Please check the values and upload again'    END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Address Category' ELSE   ErrorinColumn +','+SPACE(1)+'Address Category' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadOtherOwnerDetail V  
 WHERE ISNULL(AddressCategory,'')=''

 --Check
   IF @AddressCategoryCnt>0

BEGIN
 
   UPDATE UploadOtherOwnerDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid value in column ‘Address Category’. Kindly enter the values as mentioned in the ‘Address Category’ master and upload again. Click on ‘Download Master value’ to download the valid valu
es for the column'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid value in column ‘Address Category’. Kindly enter the values as mentioned in the ‘Address Category’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'  




   END   
						--ELSE ErrorMessage+','+SPACE(1)+ 'Different PoolID of same combination of PoolName and PoolType is Available. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Address Category' ELSE   ErrorinColumn +','+SPACE(1)+'Address Category' END     
		,Srnooferroneousrows=V.SrNo
	

 FROM UploadOtherOwnerDetail V  
 WHERE ISNULL(AddressType,'')<>''
 AND  V.AddressType IN(
				SELECT  A.AddressCategory FROM AddressCategoryData A
					 LEFT JOIN DimAddressCategory B
					 ON  A.AddressCategory=B.AddressCategoryName
					 Where B.AddressCategoryName IS NULL
				 )
 END 

 -----------------------------------------------
        /*validations on Address Line 1 */
 ------------------------------------------------------------
 UPDATE UploadOtherOwnerDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Address Line 1 cannot be blank . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Address Line 1 cannot be blank . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Address Line 1' ELSE   ErrorinColumn +','+SPACE(1)+'Address Line 1' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadOtherOwnerDetail V  
 WHERE ISNULL(AddressLine1,'')=''

  UPDATE UploadOtherOwnerDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Address Line 1 is Invalid . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Address Line 1 is Invalid . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Address Line 1' ELSE   ErrorinColumn +','+SPACE(1)+'Address Line 1' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadOtherOwnerDetail V  
 WHERE Len(AddressLine1)>500

 UPDATE UploadOtherOwnerDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Special characters - _ \ / are allowed, kindly remove and try again'     
						ELSE ErrorMessage+','+SPACE(1)+'Special characters - _ \ / are allowed, kindly remove and try againn'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Address Line 1' ELSE   ErrorinColumn +','+SPACE(1)+'Address Line 1' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadOtherOwnerDetail V  

 WHERE ISNULL(AddressLine1,'') LIKE'%- \ / _%'
 ----------------------------------------------------------------

        /*validations on Address Line 2 */
 ------------------------------------------------------------
 UPDATE UploadOtherOwnerDetail
	SET  
 ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Address Line 2 cannot be blank . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Address Line 2 cannot be blank . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Address Line 2' ELSE   ErrorinColumn +','+SPACE(1)+'Address Line 2' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadOtherOwnerDetail V  
 WHERE ISNULL(AddressLine2,'')=''

  UPDATE UploadOtherOwnerDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Address Line 2 is Invalid . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Address Line 2 is Invalid . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Address Line 2' ELSE   ErrorinColumn +','+SPACE(1)+'Address Line 2' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadOtherOwnerDetail V  
 WHERE Len(AddressLine2)>500

 UPDATE UploadOtherOwnerDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Special characters - _ \ / are allowed, kindly remove and try again'     
						ELSE ErrorMessage+','+SPACE(1)+'Special characters - _ \ / are allowed, kindly remove and try again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Address Line 2' ELSE   ErrorinColumn +','+SPACE(1)+'Address Line 2' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadOtherOwnerDetail V  

 WHERE ISNULL(AddressLine2,'') LIKE'%- \ / _%'

 -----------------------------------------------------------------------------

        /*validations on Address Line 3 */
 ------------------------------------------------------------
 UPDATE UploadOtherOwnerDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Address Line 3 cannot be blank . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Address Line 3 cannot be blank . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Address Line 3' ELSE   ErrorinColumn +','+SPACE(1)+'Address Line 3' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadOtherOwnerDetail V  
 WHERE ISNULL(AddressLine3,'')=''

 UPDATE UploadOtherOwnerDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Address Line 3 is Invalid . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Address Line 3 is Invalid . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Address Line 3' ELSE   ErrorinColumn +','+SPACE(1)+'Address Line 3' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadOtherOwnerDetail V  
 WHERE Len(AddressLine3)>500

 UPDATE UploadOtherOwnerDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Special characters - _ \ / are allowed, kindly remove and try again'     
						ELSE ErrorMessage+','+SPACE(1)+'Special characters - _ \ / are allowed, kindly remove and try again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Address Line 3' ELSE   ErrorinColumn +','+SPACE(1)+'Address Line 3' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadOtherOwnerDetail V  

 WHERE ISNULL(AddressLine3,'') LIKE'%- \ / _%'

 -----------------------------------------------------------------------------
       /*validations on City */
 ------------------------------------------------------------
 UPDATE UploadOtherOwnerDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'City cannot be blank . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'City cannot be blank . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'City' ELSE   ErrorinColumn +','+SPACE(1)+'City' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadOtherOwnerDetail V  
 WHERE ISNULL(City,'')=''

 UPDATE UploadOtherOwnerDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'City is Invalid . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'City is Invalid . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'City' ELSE   ErrorinColumn +','+SPACE(1)+'City' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadOtherOwnerDetail V  
 WHERE Len(City)>50

 UPDATE UploadOtherOwnerDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Special characters - _ \ / are allowed, kindly remove and try again'     
						ELSE ErrorMessage+','+SPACE(1)+'Special characters - _ \ / are allowed, kindly remove and try again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'City' ELSE   ErrorinColumn +','+SPACE(1)+'City' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadOtherOwnerDetail V  

 WHERE ISNULL(City,'') LIKE'%- \ / _%'

 -----------------------------------------------------------------------------

       /*validations on PinCode */
 ------------------------------------------------------------
 UPDATE UploadOtherOwnerDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'PinCode cannot be blank . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'PinCode cannot be blank . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'PinCode' ELSE   ErrorinColumn +','+SPACE(1)+'PinCode' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadOtherOwnerDetail V  
 WHERE ISNULL([PinCode],'')=''

 UPDATE UploadOtherOwnerDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'PinCode is Invalid . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'PinCode is Invalid . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'PinCode' ELSE   ErrorinColumn +','+SPACE(1)+'PinCode' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadOtherOwnerDetail V  
  WHERE (ISNUMERIC([PinCode])=0 AND ISNULL([PinCode],'')<>'') OR 
 ISNUMERIC([PinCode]) LIKE '%^[0-9]%'

 UPDATE UploadOtherOwnerDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN '‘Invalid Pincode, please check and upload again’'     
						ELSE ErrorMessage+','+SPACE(1)+'‘Invalid Pincode, please check and upload again’'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'PinCode' ELSE   ErrorinColumn +','+SPACE(1)+'PinCode' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadOtherOwnerDetail V  

 WHERE LEN([PinCode])>6 AND CHARINDEX('.',[PinCode])>0

 -----------------------------------------------------------------------------

 
       /*validations on Country  */
 ------------------------------------------------------------
 UPDATE UploadOtherOwnerDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Country  cannot be blank . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Country  cannot be blank . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Country ' ELSE   ErrorinColumn +','+SPACE(1)+'Country ' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadOtherOwnerDetail V  
 WHERE ISNULL(Country,'')=''

 UPDATE UploadOtherOwnerDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Country  is Invalid . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Country  is Invalid . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Country ' ELSE   ErrorinColumn +','+SPACE(1)+'Country ' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadOtherOwnerDetail V  
  WHERE LEN(Country)>100

 UPDATE UploadOtherOwnerDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Special characters - _ \ / are allowed, kindly remove and try again'     
						ELSE ErrorMessage+','+SPACE(1)+'Special characters - _ \ / are allowed, kindly remove and try again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Country' ELSE   ErrorinColumn +','+SPACE(1)+'Country' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadOtherOwnerDetail V  

   WHERE ISNULL(Country,'') LIKE'%- \ / _%'

 -----------------------------------------------------------------------------
       /*validations on District  */
 ------------------------------------------------------------
 UPDATE UploadOtherOwnerDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'District  cannot be blank . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'District  cannot be blank . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'District ' ELSE   ErrorinColumn +','+SPACE(1)+'District ' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadOtherOwnerDetail V  
 WHERE ISNULL(District,'')=''

 UPDATE UploadOtherOwnerDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'District  is Invalid . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'District  is Invalid . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'District ' ELSE   ErrorinColumn +','+SPACE(1)+'District ' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadOtherOwnerDetail V  
  WHERE LEN(District)>100

 UPDATE UploadOtherOwnerDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Special characters - _ \ / are allowed, kindly remove and try again'     
						ELSE ErrorMessage+','+SPACE(1)+'Special characters - _ \ / are allowed, kindly remove and try again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Country' ELSE   ErrorinColumn +','+SPACE(1)+'Country' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadOtherOwnerDetail V  

   WHERE ISNULL(District,'') LIKE'%- \ / _%'

 -----------------------------------------------------------------------------
     /*validations on Std Code (O)  */
 ------------------------------------------------------------
 --UPDATE UploadOtherOwnerDetail
	--SET  
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Std Code (O)  cannot be blank . Please check the values and upload again'     
	--					ELSE ErrorMessage+','+SPACE(1)+'Std Code (O)  cannot be blank . Please check the values and upload again'     END
	--	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Std Code (O) ' ELSE   ErrorinColumn +','+SPACE(1)+'Std Code (O) ' END   
	--	,Srnooferroneousrows=V.SrNo
								
   
 --  FROM UploadOtherOwnerDetail V  
 --WHERE ISNULL(StdCodeO,'')=''

 UPDATE UploadOtherOwnerDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid STD CODE (O), please check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid STD CODE (O), please check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Std Code (O) ' ELSE   ErrorinColumn +','+SPACE(1)+'Std Code (O) ' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadOtherOwnerDetail V  
   WHERE (ISNUMERIC(StdCodeO)=0 AND ISNULL(StdCodeO,'')<>'')  
 --AND ISNUMERIC(StdCodeO) LIKE '%^[0-9]%'

 UPDATE UploadOtherOwnerDetail
	SET  
      ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid STD CODE (O), please check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid STD CODE (O), please check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Std Code (O)' ELSE   ErrorinColumn +','+SPACE(1)+'Std Code (O)' END   
		,Srnooferroneousrows=V.SrNo
								
 
   FROM UploadOtherOwnerDetail V  

   WHERE (Len(StdCodeO)<3  AND ISNULL(StdCodeO,'')<>'')

 -----------------------------------------------------------------------------

     /*validations on Phone No (O)  */
 ------------------------------------------------------------
 --UPDATE UploadOtherOwnerDetail
	--SET  
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Phone No (O)  cannot be blank . Please check the values and upload again'     
	--					ELSE ErrorMessage+','+SPACE(1)+'Phone No (O)  cannot be blank . Please check the values and upload again'     END
	--	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Phone No (O) ' ELSE   ErrorinColumn +','+SPACE(1)+'Phone No (O) ' END   
	--	,Srnooferroneousrows=V.SrNo
								
   
 --  FROM UploadOtherOwnerDetail V  
 --WHERE ISNULL(PhoneNoO,'')=''

 UPDATE UploadOtherOwnerDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid Phone No (O), please check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid Phone No (O), please check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Phone No (O) ' ELSE   ErrorinColumn +','+SPACE(1)+'Phone No (O) ' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadOtherOwnerDetail V  
   WHERE (ISNUMERIC(PhoneNoO)=0 AND ISNULL(PhoneNoO,'')<>'')  
 --AND ISNUMERIC(PhoneNoO) LIKE '%^[0-9]%'

 UPDATE UploadOtherOwnerDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid STD CODE (O), please check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid STD CODE (O), please check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Std Code (O)' ELSE   ErrorinColumn +','+SPACE(1)+'Std Code (O)' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadOtherOwnerDetail V  

   WHERE (Len(PhoneNoO)<10 AND ISNULL(PhoneNoO,'')<>'')

 -----------------------------------------------------------------------------
    /*validations on Std Code (R)  */
 ------------------------------------------------------------
 --UPDATE UploadOtherOwnerDetail
	--SET  
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Std Code (R)  cannot be blank . Please check the values and upload again'     
	--					ELSE ErrorMessage+','+SPACE(1)+'Std Code (R)  cannot be blank . Please check the values and upload again'     END
	--	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Std Code (R) ' ELSE   ErrorinColumn +','+SPACE(1)+'Std Code (R) ' END   
	--	,Srnooferroneousrows=V.SrNo
								
   
 --  FROM UploadOtherOwnerDetail V  
 --WHERE ISNULL(StdCodeR,'')=''

 UPDATE UploadOtherOwnerDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid Std Code (R), please check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid Std Code (R), please check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Std Code (R) ' ELSE   ErrorinColumn +','+SPACE(1)+'Std Code (R) ' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadOtherOwnerDetail V  
   WHERE (ISNUMERIC(StdCodeR)=0 AND ISNULL(StdCodeR,'')<>'')  
 -- AND ISNUMERIC(StdCodeR) LIKE '%^[0-9]%'

 UPDATE UploadOtherOwnerDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid Std Code (R), please check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid Std Code (R), please check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Std Code (R)' ELSE   ErrorinColumn +','+SPACE(1)+'Std Code (R)' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadOtherOwnerDetail V  

   WHERE (Len(StdCodeR)<3 AND ISNULL(StdCodeR,'')<>'')

 -----------------------------------------------------------------------------
     /*validations on Phone No (R)  */
 ------------------------------------------------------------
 --UPDATE UploadOtherOwnerDetail
	--SET  
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Phone No (R) cannot be blank . Please check the values and upload again'     
	--					ELSE ErrorMessage+','+SPACE(1)+'Phone No (R)  cannot be blank . Please check the values and upload again'     END
	--	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Phone No (R) ' ELSE   ErrorinColumn +','+SPACE(1)+'Phone No (R) ' END   
	--	,Srnooferroneousrows=V.SrNo
								
   
 --  FROM UploadOtherOwnerDetail V  
 --WHERE ISNULL(PhoneNoR,'')=''

 UPDATE UploadOtherOwnerDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid Phone No (R), please check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid Phone No (R), please check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Phone No (R) ' ELSE   ErrorinColumn +','+SPACE(1)+'Phone No (R) ' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadOtherOwnerDetail V  
   WHERE (ISNUMERIC(PhoneNoR)=0 AND ISNULL(PhoneNoR,'')<>'')  
 --AND ISNUMERIC(PhoneNoR) LIKE '%^[0-9]%'

 UPDATE UploadOtherOwnerDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid Phone No (R), please check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid Phone No (R), please check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Phone No (R)' ELSE   ErrorinColumn +','+SPACE(1)+'Phone No (R)' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadOtherOwnerDetail V  

   WHERE (Len(PhoneNoR)<10 AND ISNULL(PhoneNoR,'')<>'')

 -----------------------------------------------------------------------------
   /*validations on Mobile No.  */
 ------------------------------------------------------------
 UPDATE UploadOtherOwnerDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Mobile No. cannot be blank . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Mobile No.  cannot be blank . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Mobile No. ' ELSE   ErrorinColumn +','+SPACE(1)+'Mobile No. ' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadOtherOwnerDetail V  
 WHERE ISNULL(MobileNo,'')=''

 UPDATE UploadOtherOwnerDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid Mobile No., please check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid Mobile No., please check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Mobile No. ' ELSE   ErrorinColumn +','+SPACE(1)+'Mobile No. ' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadOtherOwnerDetail V  
   WHERE (ISNUMERIC(MobileNo)=0 AND ISNULL(MobileNo,'')<>'')  
 -- AND ISNUMERIC(MobileNo) LIKE '%^[0-9]%'

 UPDATE UploadOtherOwnerDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid Mobile No., please check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid Mobile No., please check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Mobile No.' ELSE   ErrorinColumn +','+SPACE(1)+'Mobile No.' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadOtherOwnerDetail V  

   WHERE (Len(MobileNo)<10 AND ISNULL(MobileNo,'')<>'')

 -----------------------------------------------------------------------------
 ---------------------------------------------------
 Print '123'
 goto valid

  END
	
   ErrorData:  
   print 'no'  

		SELECT *,'Data'TableName
		FROM dbo.MasterUploadData WHERE FileNames=@filepath 
		return

   valid:
		IF NOT EXISTS(Select 1 from  CollateralOthOwnerDetails_stg WHERE filname=@FilePathUpload)
		BEGIN
		PRINT 'NO ERRORS'
			
			Insert into dbo.MasterUploadData
			(SR_No,ColumnName,ErrorData,ErrorType,FileNames,Flag) 
			SELECT '' SRNO , '' ColumnName,'' ErrorData,'' ErrorType,@filepath,'SUCCESS' 
			
		END
		ELSE
		BEGIN
			PRINT 'VALIDATION ERRORS'
			Insert into dbo.MasterUploadData
			(SR_No,ColumnName,ErrorData,ErrorType,FileNames,Srnooferroneousrows,Flag) 
			SELECT SrNo,ErrorinColumn,ErrorMessage,ErrorinColumn,@filepath,Srnooferroneousrows,'SUCCESS' 
			FROM UploadOtherOwnerDetail 

			
			
		--	----SELECT * FROM UploadOtherOwnerDetail 

		--	--ORDER BY ErrorMessage,UploadOtherOwnerDetail.ErrorinColumn DESC
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
IF EXISTS(SELECT 1 FROM dbo.MasterUploadData WHERE FileNames=@filepath AND ISNULL(ERRORDATA,'')<>'' AND  ISNULL(ERRORDATA,'')<>'No Record found'
		) 
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

		 IF EXISTS(SELECT 1 FROM CollateralOthOwnerDetails_stg WHERE filname=@FilePathUpload)
		 BEGIN
		 PRINT '1'
		 DELETE FROM CollateralOthOwnerDetails_stg
		 WHERE filname=@FilePathUpload

		 PRINT '2'

		 PRINT 'ROWS DELETED FROM DBO.CollateralOthOwnerDetails_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
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

	----SELECT * FROM UploadOtherOwnerDetail

	print 'p'
  ------to delete file if it has errors
		--if exists(Select  1 from dbo.MasterUploadData where FileNames=@filepath and ISNULL(ErrorData,'')<>'')
		--begin
		--print 'ppp'
		-- IF EXISTS(SELECT 1 FROM IBPCPoolDetail_stg WHERE filname=@FilePathUpload)
		-- BEGIN
		-- print '123'
		-- DELETE FROM IBPCPoolDetail_stg
		-- WHERE filname=@FilePathUpload

		-- PRINT 'ROWS DELETED FROM DBO.IBPCPoolDetail_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
		-- END
		-- END

   
END  TRY 
  
  BEGIN CATCH  
	

	INSERT INTO dbo.Error_Log
				SELECT ERROR_LINE() as ErrorLine,ERROR_MESSAGE()ErrorMessage,ERROR_NUMBER()ErrorNumber
				,ERROR_PROCEDURE()ErrorProcedure,ERROR_SEVERITY()ErrorSeverity,ERROR_STATE()ErrorState
				,GETDATE()

	--IF EXISTS(SELECT 1 FROM IBPCPoolDetail_stg WHERE filname=@FilePathUpload)
	--	 BEGIN
	--	 DELETE FROM IBPCPoolDetail_stg
	--	 WHERE filname=@FilePathUpload

	--	 PRINT 'ROWS DELETED FROM DBO.IBPCPoolDetail_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
	--	 END

END CATCH 

END
GO