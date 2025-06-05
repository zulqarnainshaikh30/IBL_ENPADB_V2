SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[ValidateExcel_DataUpload_RPDetailsUpload]
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


IF (@MenuID=24735)	
BEGIN


	  -- IF OBJECT_ID('tempdb..UploadDetailsUpload') IS NOT NULL  
	  IF OBJECT_ID('UploadDetailsUpload') IS NOT NULL  
	  BEGIN  
	   DROP TABLE UploadDetailsUpload  
	
	  END
	  
  IF NOT (EXISTS (SELECT * FROM RPDetailsUpload_stg where filname=@FilePathUpload))

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
 	   into UploadDetailsUpload
	   from RPDetailsUpload_stg 
	   WHERE filname=@FilePathUpload

	  
END


  ------------------------------------------------------------------------------  
   
	--SrNo	Territory	ACID	InterestReversalAmount	sheetname
	
	UPDATE UploadDetailsUpload
	SET  
        ErrorMessage='There is no data in excel. Kindly check and upload again' 
		,ErrorinColumn='CustomerID,ReportingBank_LenderCode,BankingArrangement,Nameofleadbank,ExposureBucket,ICAStatus'    
		,Srnooferroneousrows=''
 FROM UploadDetailsUpload V  
 WHERE ISNULL(CustomerID,'')=''
AND ISNULL([1stReportingBankLenderCode],'')=''
AND ISNULL(BankingArrangement,'')=''
AND ISNULL(Nameofleadbank,'')=''
AND ISNULL(Exposurebucket,'')=''
AND ISNULL(ReferenceDate,'')=''
AND ISNULL(ICAStatus,'')=''
  
--WHERE ISNULL(V.SrNo,'')=''
-- ----AND ISNULL(Territory,'')=''
-- AND ISNULL(AccountID,'')=''
-- AND ISNULL(PoolID,'')=''
-- AND ISNULL(sheetname,'')=''

  --IF EXISTS(SELECT 1 FROM UploadDetailsUpload WHERE ISNULL(ErrorMessage,'')<>'')
  --BEGIN
  --PRINT 'NO DATA'
  --GOTO ERRORDATA;
  --END

      /*validations on Sl. No.*/
 ------------------------------------------------------------
 PRINT 'Satart11'
  Declare @DuplicateCnt int=0
   UPDATE UploadDetailsUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'SrNo cannot be blank . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'SrNo cannot be blank . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' ELSE   ErrorinColumn +','+SPACE(1)+'SrNo' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadDetailsUpload V  
 WHERE ISNULL(SrNo,'')='' or ISNULL(SrNo,'0')='0'


  UPDATE UploadDetailsUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'SrNo cannot be greater than 16 character . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'SrNo cannot be greater than 16 character . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' ELSE   ErrorinColumn +','+SPACE(1)+'SrNo' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadDetailsUpload V  
 WHERE Len(SrNo)>16

  UPDATE UploadDetailsUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid Sl. No., kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid Sl. No., kindly check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' ELSE   ErrorinColumn +','+SPACE(1)+'SrNo' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadDetailsUpload V  
  WHERE (ISNUMERIC(SrNo)=0 AND ISNULL(SrNo,'')<>'') OR 
 ISNUMERIC(SrNo) LIKE '%^[0-9]%'

 UPDATE UploadDetailsUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Special characters not allowed, kindly remove and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Special characters not allowed, kindly remove and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' ELSE   ErrorinColumn +','+SPACE(1)+'SrNo' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadDetailsUpload V  
   WHERE ISNULL(SrNo,'') LIKE'%[,!@#$%^&*()_-+=/]%'

   --
  SELECT @DuplicateCnt=Count(1)
FROM UploadDetailsUpload
GROUP BY  SrNo
HAVING COUNT(SrNo) >1;

IF (@DuplicateCnt>0)

 UPDATE UploadDetailsUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Duplicate Sl. No., kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Duplicate Sl. No., kindly check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' ELSE   ErrorinColumn +','+SPACE(1)+'SrNo' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadDetailsUpload V  
   Where ISNULL(SrNo,'') In(  
   SELECT SrNo
	FROM UploadDetailsUpload
	GROUP BY  SrNo
	HAVING COUNT(SrNo) >1

)
----------------------------------------------------------------
  
  /*validations on Customer ID*/
   Declare @Count Int,@I Int,@Entity_Key Int
  Declare @TaggingLevel Varchar(100)=''
  Declare @CustomerID Varchar(100)=''
  Declare @AccountId Varchar(100)=''
 Declare @RelatedUCICCustomerIDAccountID Varchar(100)=''
  Declare @UCIC Varchar(100)=''

   Declare @DuplicateCustomerID int=0

  UPDATE UploadDetailsUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Customer ID cannot be blank . Please check the values and upload again.'     
						ELSE ErrorMessage+','+SPACE(1)+' Customer ID cannot be blank . Please check the values and upload again.n'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Customer ID' ELSE   ErrorinColumn +','+SPACE(1)+'Customer ID' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadDetailsUpload V 
 WHERE ISNULL(CustomerID,'')=''

   UPDATE UploadDetailsUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'You can not upload customer which is already active. Please check the values and upload again.'     
						ELSE ErrorMessage+','+SPACE(1)+' You can not upload customer which is already active. Please check the values and upload again.n'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Customer ID' ELSE   ErrorinColumn +','+SPACE(1)+'Customer ID' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadDetailsUpload V 
   INNER JOIN RP_Portfolio_Details B On V.CustomerID =B.CustomerID
 WHERE ISNULL(IsActive,'')='Y'

 SELECT @DuplicateCustomerID=Count(1)
FROM UploadDetailsUpload
GROUP BY  CustomerID
HAVING COUNT(CustomerID) >1;


IF (@DuplicateCustomerID>0)

BEGIN
 UPDATE		UploadDetailsUpload
SET			ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Duplicate CustomerID., kindly check and upload again'     
						 ELSE ErrorMessage+','+SPACE(1)+'Duplicate CustomerID, kindly check and upload again'     END
			,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'CustomerID' ELSE   ErrorinColumn +','+SPACE(1)+'CustomerID' END   
			,Srnooferroneousrows=V.SrNo			
   FROM		UploadDetailsUpload V  
   Where	ISNULL(CustomerID,'') In(  
								   SELECT CustomerID
									FROM UploadDetailsUpload a
									GROUP BY  CustomerID
									HAVING COUNT(CustomerID) >1
							   )
END

 IF OBJECT_ID('TempDB..#tmp') IS NOT NULL DROP TABLE #tmp; 
  
  Select  ROW_NUMBER() OVER(ORDER BY  CONVERT(INT,Entity_Key) ) RecentRownumber,Entity_Key,CustomerID 
  into #tmp from UploadDetailsUpload

  Select @Count=Count(*) from #tmp
  
   SET @I=1
   SET @Entity_Key=0
   SET @CustomerId=''
   SET @UCIC=''
   SET @AccountId=''
 While(@I<=@Count)
					BEGIN
					    Select @RelatedUCICCustomerIDAccountID =CustomerID,@Entity_Key=Entity_Key  from #tmp where RecentRownumber=@I 
							order By Entity_Key

							

							  If @TaggingLevel='Customer ID'
							  BEGIN
							    Print 'Sachin'
								 

							       Select @CustomerId=CustomerId from Curdat.CustomerBasicDetail 
								   where CustomerId=@RelatedUCICCustomerIDAccountID
								    

								  IF @CustomerId =''
								       Begin
										  
								    
								  
										   Update UploadDetailsUpload
										   SET   ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Customer ID is invalid. Kindly check the entered customer id'     
											 ELSE ErrorMessage+','+SPACE(1)+'Customer ID is invalid. Kindly check the entered customer id'      END
                                   ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Customer ID' ELSE   ErrorinColumn +','+SPACE(1)+'Customer ID' END 
										   Where Entity_Key=@Entity_Key
									END
							  END


--							  END

							    SET @I=@I+1
								SET @CustomerId=''
								SET @UCIC=''
								SET @AccountId=''
					END
----------------------------------------------------------------
/*validations on Lender Name*/

--UPDATE UploadDetailsUpload
--	SET  
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'ReportingBank_LenderCode cannot be blank . Please check the values and upload again.'     
--						ELSE ErrorMessage+','+SPACE(1)+' ReportingBank_LenderCode cannot be blank . Please check the values and upload again.n'     END
--		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'ReportingBank_LenderCode' ELSE   ErrorinColumn +','+SPACE(1)+'ReportingBank_LenderCode' END   
--		,Srnooferroneousrows=V.SrNo
								
   
--   FROM UploadDetailsUpload V  
-- WHERE ISNULL([1stReportingBankLenderCode],'')=''


-- Declare @LenderNameCnt int=0
-- IF OBJECT_ID('LenderNameData') IS NOT NULL  
--	  BEGIN  
--	   DROP TABLE LenderNameData  
	
--	  END

	  
-- SELECT * into LenderNameData  FROM(
-- SELECT ROW_NUMBER() OVER(PARTITION BY [1stReportingBankLenderCode]  ORDER BY  [1stReportingBankLenderCode] ) 
-- ROW ,[1stReportingBankLenderCode] FROM UploadDetailsUpload
-- )X
-- WHERE ROW=1

--  SELECT  @LenderNameCnt=COUNT(*) FROM LenderNameData A
-- Left JOIN DIMBANK B
-- ON  A.[1stReportingBankLenderCode]=B.BankName
-- Where B.BankName IS NULL

-- IF @LenderNameCnt>0

--BEGIN
 
--   UPDATE UploadDetailsUpload
--	SET  
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid value in column ‘ReportingBank_LenderCode’. Kindly enter the values as mentioned in the ‘Lender Name’ master and upload again. Click on ‘Download Master value’ to download the valid
 





--v





--alues for the
-- column'     
--						ELSE ErrorMessage+','+SPACE(1)+'Invalid value in column ‘ReportingBank_LenderCode’. Kindly enter the values as mentioned in the ‘Lender Name’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'   
  










--END  
--		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'ReportingBank_LenderCode' ELSE   ErrorinColumn +','+SPACE(1)+'ReportingBank_LenderCode' END     
--		,Srnooferroneousrows=V.SrNo
  

-- FROM UploadDetailsUpload V  
-- WHERE ISNULL([1stReportingBankLenderCode],'')<>''
-- AND  V.[1stReportingBankLenderCode] IN(
--				SELECT  A.[1stReportingBankLenderCode] FROM LenderNameData A
--				 Left JOIN DIMBANK B
--				 ON  A.[1stReportingBankLenderCode]=B.BankName
--				 Where B.BankName IS NULL
--				 )
-- END 


  UPDATE UploadDetailsUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'This CustomerID is already pending for Authorization. Please check the values and upload again.'     
						ELSE ErrorMessage+','+SPACE(1)+' This CustomerID is already pending for Authorization..Please check the values and upload again.'     END

		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'CustomerID' ELSE   ErrorinColumn +','+SPACE(1)+'CustomerID' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadDetailsUpload V  
  

 WHERE ISNULL(V.CustomerID,'')  IN(
  Select Distinct V.CustomerID FROM UploadDetailsUpload V  
   INNER JOIN RP_Portfolio_Upload_Mod B
  ON V.CustomerID =B.CustomerID  
   	WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
	And AuthorisationStatus in('NP','MP','FM','1A')
 )

 --And V.LenderName =B.LeadBankName
 ------------------------------------------------------------------------
 /*validations on BankingArrangement*/
 
UPDATE UploadDetailsUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'BankingArrangement cannot be blank . Please check the values and upload again.'     
						ELSE ErrorMessage+','+SPACE(1)+' BankingArrangement cannot be blank . Please check the values and upload again.n'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'BankingArrangement' ELSE   ErrorinColumn +','+SPACE(1)+'BankingArrangement' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadDetailsUpload V  
 WHERE ISNULL(BankingArrangement,'')=''


 Declare @BankingArrangementCnt int=0
 IF OBJECT_ID('BankingArrangementData') IS NOT NULL  
	  BEGIN  
	   DROP TABLE BankingArrangementData  
	
	  END

	  
 SELECT * into BankingArrangementData  FROM(
 SELECT ROW_NUMBER() OVER(PARTITION BY BankingArrangement  ORDER BY  BankingArrangement ) 
 ROW ,BankingArrangement FROM UploadDetailsUpload
 )X
 WHERE ROW=1

  SELECT  @BankingArrangementCnt=COUNT(*) FROM BankingArrangementData A
 Left JOIN DimBankingArrangement B
 ON  A.BankingArrangement=B.ArrangementDescription
 Where B.ArrangementDescription IS NULL

 IF @BankingArrangementCnt>0

BEGIN
 
   UPDATE UploadDetailsUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid value in column ‘BankingArrangement’. Kindly enter the values as mentioned in the ‘BankingArrangement’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid value in column ‘BankingArrangement’. Kindly enter the values as mentioned in the ‘BankingArrangement’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'    
END  




		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'BankingArrangement' ELSE   ErrorinColumn +','+SPACE(1)+'BankingArrangement' END     
		,Srnooferroneousrows=V.SrNo
  

 FROM UploadDetailsUpload V  
 WHERE ISNULL(BankingArrangement,'')<>''
 AND  V.BankingArrangement IN(
				SELECT  A.BankingArrangement FROM BankingArrangementData A
				 Left JOIN DimBankingArrangement B
				 ON  A.BankingArrangement=B.ArrangementDescription
				 Where B.ArrangementDescription IS NULL
				 )
 END 
 -------------------------------------------------------------------------------
 /*validations on Nameofleadbank*/

 UPDATE UploadDetailsUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Nameofleadbank cannot be blank . Please check the values and upload again.'     
						ELSE ErrorMessage+','+SPACE(1)+' Nameofleadbank cannot be blank . Please check the values and upload again.n'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Nameofleadbank' ELSE   ErrorinColumn +','+SPACE(1)+'Nameofleadbank' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadDetailsUpload V  
 WHERE ISNULL(BankingArrangement,'') IN('Consortium Banking') AND ISNULL(Nameofleadbank,'')=''


 Declare @NameofleadbankCnt int=0
 IF OBJECT_ID('NameofleadbankData') IS NOT NULL  
	  BEGIN  
	   DROP TABLE NameofleadbankData  
	
	  END

	  
 SELECT * into NameofleadbankData  FROM(
 SELECT ROW_NUMBER() OVER(PARTITION BY Nameofleadbank  ORDER BY  Nameofleadbank ) 
 ROW ,Nameofleadbank FROM UploadDetailsUpload
 )X
 WHERE ROW=1

  SELECT  @NameofleadbankCnt=COUNT(*) FROM NameofleadbankData A
 Left JOIN DimBankRP B
 ON  A.Nameofleadbank=B.BankName
 Where B.BankName IS NULL

 IF @NameofleadbankCnt>0

BEGIN
 
   UPDATE UploadDetailsUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid value in column ‘Lead BankName’. Kindly enter the values as mentioned in the ‘Lead BankName’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid value in column ‘Nameofleadbank’. Kindly enter the values as mentioned in the ‘Lead BankName’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'     END  
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Nameofleadbank' ELSE   ErrorinColumn +','+SPACE(1)+'Nameofleadbank' END     
		,Srnooferroneousrows=V.SrNo
  

 FROM UploadDetailsUpload V  
 WHERE ISNULL(Nameofleadbank,'')<>''
 AND  V.Nameofleadbank IN(
				SELECT  A.Nameofleadbank FROM NameofleadbankData A
						 Left JOIN DimBankRP B
						 ON  A.Nameofleadbank=B.BankName
						 Where B.BankName IS NULL
				 )
 END 
 ------------------------------------------------------------
 /*validations on Exposure Bucket*/

 UPDATE UploadDetailsUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Exposure Bucket cannot be blank . Please check the values and upload again.'     
						ELSE ErrorMessage+','+SPACE(1)+' Exposure Bucket cannot be blank . Please check the values and upload again.n'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Exposure Bucket' ELSE   ErrorinColumn +','+SPACE(1)+'Exposure Bucket' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadDetailsUpload V  
 WHERE ISNULL(ExposureBucket,'')=''


 Declare @ExposureBucketCnt int=0
 IF OBJECT_ID('ExposureBucketData') IS NOT NULL  
	  BEGIN  
	   DROP TABLE ExposureBucketData  
	
	  END

	  
 SELECT * into ExposureBucketData  FROM(
 SELECT ROW_NUMBER() OVER(PARTITION BY ExposureBucket  ORDER BY  ExposureBucket ) 
 ROW ,ExposureBucket FROM UploadDetailsUpload
 )X
 WHERE ROW=1

  SELECT  @ExposureBucketCnt=COUNT(*) FROM ExposureBucketData A
 Left JOIN DimExposureBucket B
 ON  A.ExposureBucket=B.BucketName
 Where B.BucketName IS NULL

 IF @ExposureBucketCnt>0

BEGIN
 
   UPDATE UploadDetailsUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid value in column ‘Exposure Bucket ’. Kindly enter the values as mentioned in the ‘Exposure Bucket ’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid value in column ‘Exposure Bucket ’. Kindly enter the values as mentioned in the ‘Exposure Bucket ’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'     END


,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Exposure Bucket ' ELSE   ErrorinColumn +','+SPACE(1)+'Exposure Bucket ' END     
		,Srnooferroneousrows=V.SrNo
  
 
 FROM UploadDetailsUpload V  
 WHERE ISNULL(ExposureBucket,'')<>''
 AND  V.ExposureBucket IN(
				  SELECT  A.ExposureBucket FROM ExposureBucketData A
					 Left JOIN DimExposureBucket B
					 ON  A.ExposureBucket=B.BucketName
					 Where B.BucketName IS NULL
				 )

				 

 END 
------------------------------------------------------------------------

--------------------------------------------------------------
-- /*validations on Borrower PAN*/
-- --Declare @Start Varchar(10)=''
-- --Declare @Middle Varchar(10)=''
-- --Declare @End Varchar(10)=''



-- UPDATE UploadDetailsUpload
--	SET  
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'BorrowerPAN cannot be blank . Please check the values and upload again.'     
--						ELSE ErrorMessage+','+SPACE(1)+' BorrowerPAN cannot be blank . Please check the values and upload again.n'     END
--		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'BorrowerPAN' ELSE   ErrorinColumn +','+SPACE(1)+'BorrowerPAN' END   
--		,Srnooferroneousrows=V.SrNo
								
   
--   FROM UploadDetailsUpload V  
-- WHERE ISNULL(BorrowerPAN,'')=''

--  UPDATE UploadDetailsUpload
--	SET  
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'BorrowerPAN cannot be greater than 10 Character . Please check the values and upload again.'     
--						ELSE ErrorMessage+','+SPACE(1)+'BorrowerPAN cannot be greater than 10 Character  . Please check the values and upload again.n'     END
--		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'BorrowerPAN' ELSE   ErrorinColumn +','+SPACE(1)+'BorrowerPAN' END   
--		,Srnooferroneousrows=V.SrNo
								
   
--   FROM UploadDetailsUpload V  
-- WHERE Len(ISNULL(BorrowerPAN,''))>10

-- --Select BorrowerPAN,SUBSTRING(ISNULL(BorrowerPAN,''),1,5),SUBSTRING(ISNULL(BorrowerPAN,''),6,4),SUBSTRING(ISNULL(BorrowerPAN,''),10,1),* from UploadDetailsUpload

--  UPDATE UploadDetailsUpload
--	SET  
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'PAN Number first five digit should be Character . Please check the values and upload again.'     
--						ELSE ErrorMessage+','+SPACE(1)+' PAN Number first five digit should be Character .  Please check the values and upload again.n'     END
--		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'BorrowerPAN' ELSE   ErrorinColumn +','+SPACE(1)+'BorrowerPAN' END   
--		,Srnooferroneousrows=V.SrNo
								

--   FROM UploadDetailsUpload V  
-- WHERE  ISNUMERIC(SUBSTRING(ISNULL(BorrowerPAN,''),1,5))=1

--   UPDATE UploadDetailsUpload
--	SET  
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'PAN Number Middle four digit should be Numeric . Please check the values and upload again.'     
--						ELSE ErrorMessage+','+SPACE(1)+' PAN Number Middle four digit should be Numeric Please check the values and upload again.n'     END
--		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'BorrowerPAN' ELSE   ErrorinColumn +','+SPACE(1)+'BorrowerPAN' END   
--		,Srnooferroneousrows=V.SrNo
								

--   FROM UploadDetailsUpload V  
-- WHERE ISNUMERIC(SUBSTRING(ISNULL(BorrowerPAN,''),6,4))=0

--  UPDATE UploadDetailsUpload
--	SET  
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'PAN Number Last  digit should be Character . Please check the values and upload again.'     
--						ELSE ErrorMessage+','+SPACE(1)+' PAN Number Last  digit should be Character . Please check the values and upload again.n'     END
--		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'BorrowerPAN' ELSE   ErrorinColumn +','+SPACE(1)+'BorrowerPAN' END   
--		,Srnooferroneousrows=V.SrNo
								

--   FROM UploadDetailsUpload V  
-- WHERE ISNUMERIC(SUBSTRING(ISNULL(BorrowerPAN,''),10,1))=1
 

------------------------------------------------------------------


/*validations on ICA Status*/
 
 --UPDATE UploadDetailsUpload
	--SET  
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'ICA Status cannot be blank . Please check the values and upload again.'     
	--					ELSE ErrorMessage+','+SPACE(1)+' ICA Status cannot be blank . Please check the values and upload again.n'     END
	--	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'ICA Status' ELSE   ErrorinColumn +','+SPACE(1)+'ICA Status' END   
	--	,Srnooferroneousrows=V.SrNo
								
   
 --  FROM UploadDetailsUpload V  
 --WHERE ISNULL(ICAStatus,'')=''


     UPDATE UploadDetailsUpload
	SET  
    ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'ICA Status is not Valid  . Please check the values and upload again.'     
						ELSE ErrorMessage+','+SPACE(1)+' ICA Status is not Valid . Please check the values and upload again.n'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'ICA Status' ELSE   ErrorinColumn +','+SPACE(1)+'ICA Status' END   
		,Srnooferroneousrows=V.SrNo
								
   --Select ICAStatus
   FROM UploadDetailsUpload V  
 WHERE ISNULL(ICAStatus,'') NOT IN('Executed','Not Executed','')  

 ------------------------------------------------------------------------

/*validations on Reason for not Signing ICA*/
 
 UPDATE UploadDetailsUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Reason for not Signing ICA cannot be blank . Please check the values and upload again.'     
						ELSE ErrorMessage+','+SPACE(1)+' Reason for not Signing ICA cannot be blank . Please check the values and upload again.n'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Reason for not Signing ICA' ELSE   ErrorinColumn +','+SPACE(1)+'Reason for not Signing ICA' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadDetailsUpload V  
 WHERE ISNULL(ReasonfornotsigningICA,'')='' AND  ISNULL(ICAStatus,'')  IN('Not Executed')
 
 ------------------------------------------------------------------------

/*validations on Reference Date*/
 --Set DateFormat DMY

 --UPDATE UploadDetailsUpload
	--SET  
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'ReferenceDate cannot be blank . Please check the values and upload again.'     
	--					ELSE ErrorMessage+','+SPACE(1)+' ReferenceDate cannot be blank . Please check the values and upload again.n'     END
	--	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'ReferenceDate' ELSE   ErrorinColumn +','+SPACE(1)+'ReferenceDate' END   
	--	,Srnooferroneousrows=V.SrNo
								
   
 --  FROM UploadDetailsUpload V  
 --WHERE ISNULL(ReferenceDate,'')='' 

  
 --UPDATE UploadDetailsUpload
	--SET  
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'ReferenceDate must be in ddmmyyyy format. Kindly check and upload again'     
	--					ELSE ErrorMessage+','+SPACE(1)+'ReferenceDate must be in ddmmyyyy format. Kindly check and upload again'     END
	--	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'RefrenceDate' ELSE   ErrorinColumn +','+SPACE(1)+'ReferenceDate' END       
	--	,Srnooferroneousrows=V.SrNo

   
 -- FROM UploadDetailsUpload V  
 --WHERE ISDATE(ReferenceDate)=0 AND ISNULL(ReferenceDate,'')<>'' 

  ------------------------------------------------------------------------

/*validations on ICA Execution Date*/

UPDATE UploadDetailsUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'ICA Execution Date cannot be blank . Please check the values and upload again.'     
						ELSE ErrorMessage+','+SPACE(1)+' ICA Execution Date cannot be blank . Please check the values and upload again.n'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'ICA Execution Date' ELSE   ErrorinColumn +','+SPACE(1)+'ICA Execution Date' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadDetailsUpload V  
 WHERE ISNULL(ICAExecutionDate,'')='' AND  ISNULL(ICAStatus,'')  IN('Executed')

 Set DateFormat DMY

  
 UPDATE UploadDetailsUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'ICA Execution Date must be in ddmmyyyy format. Kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'ICA Execution Date must be in ddmmyyyy format. Kindly check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'ICA Execution Date' ELSE   ErrorinColumn +','+SPACE(1)+'ICA Execution Date' END       
		,Srnooferroneousrows=V.SrNo

   
  FROM UploadDetailsUpload V  
 WHERE ISDATE(ReferenceDate)=0 AND ISNULL(ReferenceDate,'')<>'' 

 UPDATE UploadDetailsUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'ICA Execution Date can not be future date. Kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'ICA Execution Date can not be future date. Kindly check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'ICA Execution Date' ELSE   ErrorinColumn +','+SPACE(1)+'ICA Execution Date' END       
		,Srnooferroneousrows=V.SrNo

   
  FROM UploadDetailsUpload V  
  WHERE (Case When ISDATE(ICAExecutionDate)=1 Then Case When Cast(ICAExecutionDate as date)>Cast(GETDATE() as Date) Then 1 
                                     Else 0 END END) =1
 

 
  ------------------------------------------------------------------------

/*validations on Approved date of Nature RP*/


UPDATE UploadDetailsUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Approved date of Resolution Plan cannot be blank . Please check the values and upload again.'     
						ELSE ErrorMessage+','+SPACE(1)+' Approved date of Resolution Plan cannot be blank . Please check the values and upload again.n'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Approved date of Resolution Plan' ELSE   ErrorinColumn +','+SPACE(1)+'Approved date of Resolution Plan' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadDetailsUpload V  
 WHERE ISNULL(ApproveddateofResolutionPlan,'')=''

 Set DateFormat DMY

 Set DateFormat DMY

  
 UPDATE UploadDetailsUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Approved date of Resolution Plan must be in ddmmyyyy format. Kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Approved date of Resolution Plan must be in ddmmyyyy format. Kindly check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Approved date of Resolution Plan' ELSE   ErrorinColumn +','+SPACE(1)+'Approved date of Resolution Plan' END       
		,Srnooferroneousrows=V.SrNo

   
  FROM UploadDetailsUpload V  
 WHERE ISDATE(ApproveddateofResolutionPlan)=0 AND ISNULL(ApproveddateofResolutionPlan,'')<>'' 

   ------------------------------------------------------------------------

/*validations on Out of default date by all banks post initial RP deadline*/


UPDATE UploadDetailsUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Out of default date by all banks post initial RP deadline cannot be blank when Nature of RP is Rectification. Please check the values and upload again.'     
						ELSE ErrorMessage+','+SPACE(1)+' Out of default date by all banks post initial RP deadline cannot be blank when Nature of RP is Rectification . Please check the values and upload again.n'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Out of default date by all banks post initial RP deadline' ELSE   ErrorinColumn +','+SPACE(1)+'Out of default date by all banks post initial RP deadline' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadDetailsUpload V  
 WHERE ISNULL(OutofdefaultdateallbankspostinitialRPdeadline,'')='' AND ISNULL(NatureofRP,'')='Rectification'

 Set DateFormat DMY

 Set DateFormat DMY

  
 UPDATE UploadDetailsUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Out of default date by all banks post initial RP deadline must be in ddmmyyyy format. Kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Out of default date by all banks post initial RP deadline must be in ddmmyyyy format. Kindly check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Out of default date by all banks post initial RP deadline' ELSE   ErrorinColumn +','+SPACE(1)+'Out of default date by all banks post initial RP deadline' END       
		,Srnooferroneousrows=V.SrNo

   
  FROM UploadDetailsUpload V  
 WHERE ISDATE(ApproveddateofResolutionPlan)=0 AND ISNULL(ApproveddateofResolutionPlan,'')<>'' AND ISNULL(NatureofRP,'')='Rectification'



 ------------------------------------------------------------
 /*validations on RP Nature*/

 UPDATE UploadDetailsUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'RP Nature cannot be blank . Please check the values and upload again.'     
						ELSE ErrorMessage+','+SPACE(1)+' RP Nature cannot be blank . Please check the values and upload again.n'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'RP Nature' ELSE   ErrorinColumn +','+SPACE(1)+'RP Nature' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadDetailsUpload V  
 WHERE ISNULL(NatureofRP,'')=''


 Declare @NatureofRPCnt int=0
 IF OBJECT_ID('NatureofRPData') IS NOT NULL  
	  BEGIN  
	   DROP TABLE NatureofRPData  
	
	  END

	  
 SELECT * into NatureofRPData  FROM(
 SELECT ROW_NUMBER() OVER(PARTITION BY NatureofRP  ORDER BY  NatureofRP ) 
 ROW ,NatureofRP FROM UploadDetailsUpload
 )X
 WHERE ROW=1

  SELECT  @NatureofRPCnt=COUNT(*) FROM NatureofRPData A
 Left JOIN DimResolutionPlanNature B
 ON  A.NatureofRP=B.RPDescription
 Where B.RPDescription IS NULL

 IF @NatureofRPCnt>0

BEGIN
 
   UPDATE UploadDetailsUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid value in column ‘RP Nature ’. Kindly enter the values as mentioned in the ‘RP Nature’ master and upload again. Click on ‘Download Master value’ to download the valid values for theco










lumn'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid value in column ‘RP Nature ’. Kindly enter the values as mentioned in the ‘RP Nature ’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'     END


  
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'RP Nature ' ELSE   ErrorinColumn +','+SPACE(1)+'RP Nature ' END     
		,Srnooferroneousrows=V.SrNo
  

 FROM UploadDetailsUpload V  
 WHERE ISNULL(NatureofRP,'')<>''
 AND  V.NatureofRP IN(
				 SELECT  A.NatureofRP FROM NatureofRPData A
						 Left JOIN DimResolutionPlanNature B
						 ON  A.NatureofRP=B.RPDescription
						 Where B.RPDescription IS NULL
				 )
 END    
 
  ------------------------------------------------------------
 /*validations on If  "Other",  Nature of RP*/

 
UPDATE UploadDetailsUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'If  "Other",  Nature of RP cannot be blank . Please check the values and upload again.'     
						ELSE ErrorMessage+','+SPACE(1)+' If  "Other",  Nature of RP cannot be blank . Please check the values and upload again.n'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'If  "Other",  Nature of RP' ELSE   ErrorinColumn +','+SPACE(1)+'If  "Other",  Nature of RP' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadDetailsUpload V  
 WHERE ISNULL(IfOtherRPDescription,'')='' AND  ISNULL(NatureofRP,'')  IN('Other')

 UPDATE UploadDetailsUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'If  "Other",  Nature of RP cannot be Greater Than 500 characters . Please check the values and upload again.'     
						ELSE ErrorMessage+','+SPACE(1)+' If  "Other",  Nature of RP cannot be Greater Than 500 characters. Please check the values and upload again.'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'If  "Other",  Nature of RP' ELSE   ErrorinColumn +','+SPACE(1)+'If  "Other",  Nature of RP' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadDetailsUpload V  
 WHERE Len(ISNULL(IfOtherRPDescription,''))>500

  ------------------------------------------------------------
 /*validations on IBC Filing Date */

 UPDATE UploadDetailsUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'IBC Filing Date cannot be blank where RP Nature is IBC.  Please check the values and upload again.'     
						ELSE ErrorMessage+','+SPACE(1)+' IBC Filing Date cannot be blank where RP Nature is IBC. Please check the values and upload again.'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'IBC Filing Date' ELSE   ErrorinColumn +','+SPACE(1)+'IBC Filing Date' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadDetailsUpload V  
 WHERE ISNULL(NatureofRP,'')='IBC' AND ISNULL(IBCFilingDate,'')=''

  Set DateFormat DMY

  
 UPDATE UploadDetailsUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'IBC Filing Date must be in ddmmyyyy format. Kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'IBC Filing Date must be in ddmmyyyy format. Kindly check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'IBC Filing Date' ELSE   ErrorinColumn +','+SPACE(1)+'IBC Filing Date' END       
		,Srnooferroneousrows=V.SrNo

   
  FROM UploadDetailsUpload V  
 WHERE ISDATE(IBCFilingDate)=0 AND ISNULL(IBCFilingDate,'')<>'' 

 
  ------------------------------------------------------------
 /*validations on IBC Admission Date */

 UPDATE UploadDetailsUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'IBC Admission Date cannot be blank where RP Nature is IBC.  Please check the values and upload again.'     
						ELSE ErrorMessage+','+SPACE(1)+' IBC Admission Date cannot be blank where RP Nature is IBC. Please check the values and upload again.'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'IBC Admission Date' ELSE   ErrorinColumn +','+SPACE(1)+'IBC Admission Date' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadDetailsUpload V  
 WHERE ISNULL(NatureofRP,'')='IBC' AND ISNULL(IBCAdmissiondate,'')=''

  Set DateFormat DMY

  
 UPDATE UploadDetailsUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'IBC Admission Date must be in ddmmyyyy format. Kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'IBC Admission Date must be in ddmmyyyy format. Kindly check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'IBC Admission Date' ELSE   ErrorinColumn +','+SPACE(1)+'IBC Admission Date' END       
		,Srnooferroneousrows=V.SrNo

   
  FROM UploadDetailsUpload V  
 WHERE ISDATE(IBCAdmissiondate)=0 AND ISNULL(IBCAdmissiondate,'')<>'' 

   ------------------------------------------------------------
 /*validations on Actual RP  Impl Date*/

--Set DateFormat DMY

  
-- UPDATE UploadDetailsUpload
--	SET  
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Actual RP  Impl Date must be in ddmmyyyy format. Kindly check and upload again'     
--						ELSE ErrorMessage+','+SPACE(1)+'Actual RP  Impl Date must be in ddmmyyyy format. Kindly check and upload again'     END
--		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Actual RP  Impl Date' ELSE   ErrorinColumn +','+SPACE(1)+'Actual RP  Impl Date' END       
--		,Srnooferroneousrows=V.SrNo

   
--  FROM UploadDetailsUpload V  
-- WHERE ISDATE(ActualRPImplDate)=0 AND ISNULL(ActualRPImplDate,'')<>'' 

  ------------------------------------------------------------
 /*validations on Out of default date */

-- UPDATE UploadDetailsUpload
--	SET  
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Out of default date  cannot be blank . Please check the values and upload again.'     
--						ELSE ErrorMessage+','+SPACE(1)+' Out of default date  cannot be blank . Please check the values and upload again.n'     END
--		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Out of default date ' ELSE   ErrorinColumn +','+SPACE(1)+'Out of default date ' END   
--		,Srnooferroneousrows=V.SrNo
								
   
--   FROM UploadDetailsUpload V  
-- WHERE ISNULL(NatureofRP,'')='Rectification' AND ISNULL(OutofdefaultdateallbankspostinitialRPdeadline,'')=''

 
--Set DateFormat DMY

  
-- UPDATE UploadDetailsUpload
--	SET  
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Out of default date  must be in ddmmyyyy format. Kindly check and upload again'     
--						ELSE ErrorMessage+','+SPACE(1)+'Out of default date  must be in ddmmyyyy format. Kindly check and upload again'     END
--		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Out of default date' ELSE   ErrorinColumn +','+SPACE(1)+'Out of default date ' END       
--		,Srnooferroneousrows=V.SrNo

   
--  FROM UploadDetailsUpload V  
-- WHERE ISDATE(OutofdefaultdateallbankspostinitialRPdeadline)=0 AND ISNULL(OutofdefaultdateallbankspostinitialRPdeadline,'')<>'' 

   ------------------------------------------------------------
 /*validations on Status on revised RP deadline */

 UPDATE UploadDetailsUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Status on revised RP deadline cannot be blank . Please check the values and upload again.'     
						ELSE ErrorMessage+','+SPACE(1)+' Status on revised RP deadline cannot be blank . Please check the values and upload again.n'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Status on revised RP deadline ' ELSE   ErrorinColumn +','+SPACE(1)+'Status on revised RP deadline ' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadDetailsUpload V  
 WHERE ISNULL(NatureofRP,'')='Rectification' AND ISNULL(RevisedRPDeadline,'')=''

    ------------------------------------------------------------
 /*validations on Implementation */

 --UPDATE UploadDetailsUpload
	--SET  
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Implementation Status is not Valid . Please check the values and upload again.'     
	--					ELSE ErrorMessage+','+SPACE(1)+' Implementation Status deadline is not Valid . Please check the values and upload again.n'     END
	--	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Implementation Status' ELSE   ErrorinColumn +','+SPACE(1)+'Implementation Status ' END   
	--	,Srnooferroneousrows=V.SrNo
								
   
 --  FROM UploadDetailsUpload V  
 --WHERE ISNULL(ImplementationStatus,'') NOT IN('Implemented','Under Implementation','Not Implemented (RP failed)','Under review period ')
   ------------------------------------------------------
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
		IF NOT EXISTS(Select 1 from  RPDetailsUpload_stg WHERE filname=@FilePathUpload)
		BEGIN
		PRINT 'NO ERRORS'
			
			Insert into dbo.MasterUploadData
			(SR_No,ColumnName,ErrorData,ErrorType,FileNames,Flag) 
			SELECT '' SRNO , '' ColumnName,'' ErrorData,'' ErrorType,@filepath,'SUCCESS' 
			
		END
		ELSE
		BEGIN
			PRINT 'VALIDATION ERRORS'
			PRINT '@filepath'
			PRINT @filepath
			Insert into dbo.MasterUploadData
			(SR_No,ColumnName,ErrorData,ErrorType,FileNames,Srnooferroneousrows,Flag) 
			SELECT SrNo,ErrorinColumn,ErrorMessage,ErrorinColumn,@filepath,Srnooferroneousrows,'SUCCESS' 
			FROM UploadDetailsUpload 

			print 'Row Effected'

			print @@ROWCOUNT
			
		--	----SELECT * FROM UploadDetailsUpload 

		--	--ORDER BY ErrorMessage,UploadDetailsUpload.ErrorinColumn DESC
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
IF EXISTS(SELECT 1 FROM dbo.MasterUploadData WHERE FileNames=@filepath AND ISNULL(ERRORDATA,'')<>''
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

		 IF EXISTS(SELECT 1 FROM RPDetailsUpload_stg WHERE filname=@FilePathUpload)
		 BEGIN
		 --Print '1'
		 DELETE FROM RPDetailsUpload_stg
		 WHERE filname=@FilePathUpload

		 PRINT '2';

		 PRINT 'ROWS DELETED FROM DBO.RPDetailsUpload_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
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

	----SELECT * FROM UploadDetailsUpload

	print 'p'
  ------to delete file if it has errors
		--if exists(Select  1 from dbo.MasterUploadData where FileNames=@filepath and ISNULL(ErrorData,'')<>'')
		--begin
		--print 'ppp'
		-- IF EXISTS(SELECT 1 FROM IBPCPoolDetail_stg WHERE sheetname=@FilePathUpload)
		-- BEGIN
		-- print '123'
		-- DELETE FROM IBPCPoolDetail_stg
		-- WHERE sheetname=@FilePathUpload

		-- PRINT 'ROWS DELETED FROM DBO.IBPCPoolDetail_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
		-- END
		-- END

   
END  TRY 
  
  BEGIN CATCH  
	

	INSERT INTO dbo.Error_Log
				SELECT ERROR_LINE() as ErrorLine,ERROR_MESSAGE()ErrorMessage,ERROR_NUMBER()ErrorNumber
				,ERROR_PROCEDURE()ErrorProcedure,ERROR_SEVERITY()ErrorSeverity,ERROR_STATE()ErrorState
				,GETDATE()

	--IF EXISTS(SELECT 1 FROM IBPCPoolDetail_stg WHERE sheetname=@FilePathUpload)
	--	 BEGIN
	--	 DELETE FROM IBPCPoolDetail_stg
	--	 WHERE sheetname=@FilePathUpload

	--	 PRINT 'ROWS DELETED FROM DBO.IBPCPoolDetail_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
	--	 END

END CATCH 

END




GO