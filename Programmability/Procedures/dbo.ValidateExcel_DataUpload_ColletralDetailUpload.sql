SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[ValidateExcel_DataUpload_ColletralDetailUpload]
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
 
 Select   @Timekey= (select CAST(B.timekey as int)from SysDataMatrix A
                    Inner Join SysDayMatrix B ON A.TimeKey=B.TimeKey
                       where A.CurrentStatus='C')

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


IF (@MenuID=24736)	
BEGIN

	  -- IF OBJECT_ID('tempdb..UploadCollateralDetail') IS NOT NULL  
	  IF OBJECT_ID('UploadCollateralDetail') IS NOT NULL  
	  BEGIN  
	   DROP TABLE UploadCollateralDetail  
	   
	  END


	  



  IF NOT (EXISTS (SELECT * FROM CollateralStockStatementUpload_stg where filname=@FilePathUpload))

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
 	   into UploadCollateralDetail
	   from CollateralStockStatementUpload_stg 
	   WHERE filname=@FilePathUpload

	  
END

  ------------------------------------------------------------------------------  
   
	--SrNo	Territory	ACID	InterestReversalAmount	filname
	
	UPDATE UploadCollateralDetail
	SET  
        ErrorMessage='There is no data in excel. Kindly check and upload again' 
		,ErrorinColumn='UCIC,CustomerName,AssetID,LiabID,Segment,CRE,Balances,CollateralSubType,Nmae Of Security Provider,Seniority Charge,Security Status'
		,Srnooferroneousrows=''
 FROM UploadCollateralDetail V  
 WHERE ISNULL(AccountID,'')=''
 AND ISNULL(CollateralType,'')=''
AND ISNULL(CollateralSubType,'')=''
AND ISNULL(ChargeType,'')=''

AND ISNULL(ChargeNature,'')=''
AND ISNULL(ValuationDate,'')=''
AND ISNULL(CurrentCollateralValueinRs,'')=''

AND ISNULL(ExpiryBusinessRule,'')=''



  
--WHERE ISNULL(V.SrNo,'')=''
-- ----AND ISNULL(Territory,'')=''
-- AND ISNULL(AccountID,'')=''
-- AND ISNULL(PoolID,'')=''
-- AND ISNULL(filname,'')=''

  IF EXISTS(SELECT 1 FROM UploadCollateralDetail WHERE ISNULL(ErrorMessage,'')<>'')
  BEGIN
  PRINT 'NO DATA'
  GOTO ERRORDATA;
  END

      /*validations on Sl. No.*/
 ------------------------------------------------------------

  Declare @DuplicateCnt int=0
   UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'SrNo cannot be blank . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'SrNo cannot be blank . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' ELSE   ErrorinColumn +','+SPACE(1)+'SrNo' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadCollateralDetail V  
 WHERE ISNULL(SrNo,'')='' or ISNULL(SrNo,'0')='0'


  UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'SrNo cannot be greater than 16 character . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'SrNo cannot be greater than 16 character . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' ELSE   ErrorinColumn +','+SPACE(1)+'SrNo' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadCollateralDetail V  
 WHERE Len(SrNo)>16

  UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid Sl. No., kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid Sl. No., kindly check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' ELSE   ErrorinColumn +','+SPACE(1)+'SrNo' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadCollateralDetail V  
  WHERE (ISNUMERIC(SrNo)=0 AND ISNULL(SrNo,'')<>'') OR 
 ISNUMERIC(SrNo) LIKE '%^[0-9]%'

 UPDATE UploadCollateralDetail
	SET  
  ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Special characters not allowed, kindly remove and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Special characters not allowed, kindly remove and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' ELSE   ErrorinColumn +','+SPACE(1)+'SrNo' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadCollateralDetail V  
   WHERE ISNULL(SrNo,'') LIKE'%[,!@#$%^&*()_-+=/]%'

   --
  SELECT @DuplicateCnt=Count(1)
FROM UploadCollateralDetail
GROUP BY  SrNo
HAVING COUNT(SrNo) >1;

IF (@DuplicateCnt>0)

 UPDATE		UploadCollateralDetail
SET			ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Duplicate Sl. No., kindly check and upload again'     
						 ELSE ErrorMessage+','+SPACE(1)+'Duplicate Sl. No., kindly check and upload again'     END
			,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' ELSE   ErrorinColumn +','+SPACE(1)+'SrNo' END   
			,Srnooferroneousrows=V.SrNo			
   FROM		UploadCollateralDetail V  
   Where	ISNULL(SrNo,'') In(  
								   SELECT SrNo
									FROM UploadCollateralDetail a
									GROUP BY  SrNo
									HAVING COUNT(SrNo) >1
							   )

							   
----------------------------------------------
  

 
 ----------------------------------------------
  
  /*validations on Related UCIC / Customer ID / Account ID*/
  Declare @Count Int,@I Int,@Entity_Key Int
  Declare @TaggingLevel Varchar(100)=''
  Declare @AccountID Varchar(100)=''
  --Declare @AccountId Varchar(100)=''
  Declare @CustomerID Varchar(100)=''
  Declare @UCIC Varchar(100)=''
  UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Related Customer ID / Account ID cannot be blank . Please check the values and upload again.'     
						ELSE ErrorMessage+','+SPACE(1)+' Related  Customer ID / Account ID cannot be blank . Please check the values and upload again.n'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Related  Customer ID / Account ID' ELSE   ErrorinColumn +','+SPACE(1)+'Related  Customer ID / Account IDl' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadCollateralDetail V  
 WHERE ISNULL(AccountID,'')=''

 UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Related Customer ID / Account ID should be less than or equal to 16 character . Please check the values and upload again.'     
						ELSE ErrorMessage+','+SPACE(1)+' Related Customer ID / Account ID should be less than or equal to 16 character . Please check the values and upload again.n'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Related Customer ID / Account ID' ELSE   ErrorinColumn +','+SPACE(1)+'Related Customer ID / Account IDl' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadCollateralDetail V  
 WHERE Len(AccountID)>20

  UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Special characters - _ \ / are not allowed, kindly remove and try again'     
						ELSE ErrorMessage+','+SPACE(1)+'Special characters - _ \ / are not allowed, kindly remove and try again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Related Customer ID / Account ID' ELSE   ErrorinColumn +','+SPACE(1)+'Related Customer ID / Account IDl' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadCollateralDetail V  
 WHERE Len(AccountID) Like '%- \ / _%'

 	IF OBJECT_ID('TempDB..#tmp') IS NOT NULL DROP TABLE #tmp; 
  
  Select  ROW_NUMBER() OVER(ORDER BY  CONVERT(INT,Entity_Key) ) RecentRownumber,Entity_Key,AccountID,Convert(Varchar(1000),'') as ErrorMessage 
  into #tmp from UploadCollateralDetail

  Select @Count=Count(*) from #tmp
  
   SET @I=1
   SET @Entity_Key=0
   SET @CustomerId=''
   SET @UCIC=''
   SET @AccountId=''
 While(@I<=@Count)
					BEGIN
					    Select @AccountID =AccountID,@Entity_Key=Entity_Key  from #tmp where RecentRownumber=@I 
							order By Entity_Key

							

							       Select @AccountId=CustomerACID from Curdat.advacbasicdetail where CustomerACID=@AccountID
								   IF @AccountId =''
								     BEGIN
										   Update UploadCollateralDetail
										   SET   ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Account ID is invalid. Kindly check the entered Account id'     
											 ELSE ErrorMessage+','+SPACE(1)+'Account ID is invalid. Kindly check the entered Account id'      END
											,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Related  Customer ID / Account ID' ELSE   ErrorinColumn +','+SPACE(1)+'Related Customer ID / Account ID' END   
											Where Entity_Key=@Entity_Key
									END
							 

	--						  If @TaggingLevel='Customer ID'
	--						  BEGIN
	--						    Print 'Sachin'
								 

	--						       Select @CustomerId=CustomerId from customerbasicdetail where CustomerId=@AccountID
								    

	--							  IF @CustomerId =''
	--							       Begin
	--									   Print '@CustomerIdAf'
	--									   Print @CustomerId
								    
								  
	--									   Update UploadCollateralDetail
	--									   SET   ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Customer ID is invalid. Kindly check the entered customer id'     
	--										 ELSE ErrorMessage+','+SPACE(1)+'Customer ID is invalid. Kindly check the entered customer id'      END
 --,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Related Customer ID / Account ID' ELSE   ErrorinColumn +','+SPACE(1)+'Related Customer ID / Account ID' END 
	--									   Where Entity_Key=@Entity_Key
	--								END
	--						  END

--							   If @TaggingLevel='UCIC'
--							  BEGIN

--							       Select @UCIC=UCIF_ID from customerbasicdetail where UCIF_ID=@AccountID
--								   IF @UCIC =''
--								      Begin
--										   Update UploadCollateralDetail
--										   SET   ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN '	  UCIC is invalid. Kindly check the entered UCIC'     
--											 ELSE ErrorMessage+','+SPACE(1)+'	  UCIC is invalid. Kindly check the entered UCIC'      END
--,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Related UCIC / Customer ID / Account ID' ELSE   ErrorinColumn +','+SPACE(1)+'Related UCIC / Customer ID / Account ID' END 
--										   Where Entity_Key=@Entity_Key
--									End
--							  END

							    SET @I=@I+1
								SET @CustomerId=''
								SET @UCIC=''
								SET @AccountId=''
					END
 


 -------------------------------------------------------------------------

		
 -------------------------------------------------------------------------


----------------------------------------------
  
 -------------Collateral Sub Type---------------------------------
 Declare @CollateralSubTypeCnt int=0
 IF OBJECT_ID('CollateralSubTypeData') IS NOT NULL  
	  BEGIN  
	   DROP TABLE CollateralSubTypeData  
	
	  END

	  
 SELECT * into CollateralSubTypeData  FROM(
 SELECT ROW_NUMBER() OVER(PARTITION BY A.CollateralSubType  ORDER BY  A.CollateralSubType ) 
 ROW ,A.CollateralSubType,B.CollateralSubTypeAltKey FROM UploadCollateralDetail A
LEFT JOIN DimCollateralSubType B
 ON  A.CollateralSubType=B.CollateralSubTypeDescription
 )X
 WHERE ROW=1

 

  SELECT  @CollateralSubTypeCnt=COUNT(*) FROM CollateralSubTypeData A
 LEFT JOIN DimCollateralSubType B
 ON  A.CollateralSubType=B.CollateralSubTypeDescription
 Where B.CollateralSubTypeDescription IS NULL

 

UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Collateral Sub Type cannot be blank . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Collateral Sub Type cannot be blank . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Collateral Sub Type' ELSE   ErrorinColumn +','+SPACE(1)+'Collateral Sub Type' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadCollateralDetail V  
 WHERE ISNULL(CollateralSubType,'')=''


IF @CollateralSubTypeCnt>0

BEGIN
 
   UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid value in column ‘Collateral Sub Type’. Kindly enter the values as mentioned in the ‘Collateral Sub Type’ master and upload again. Click on ‘Download Master value’ to download the val
id values for the column'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid value in column ‘Collateral Sub Type’. Kindly enter the values as mentioned in the ‘Collateral Sub Type’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'  


END   
						--ELSE ErrorMessage+','+SPACE(1)+ 'Different PoolID of same combination of PoolName and PoolType is Available. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Collateral Sub Typ' ELSE   ErrorinColumn +','+SPACE(1)+'Collateral Sub Typ' END     
		,Srnooferroneousrows=V.SrNo
	--	STUFF((SELECT ','+SRNO 
	--							FROM #UploadNewAccount A
	--							WHERE A.SrNo IN(SELECT V.SrNo FROM #UploadNewAccount V  
 --WHERE ISNULL(ACID,'')<>'' AND ISNULL(TERRITORY,'')<>''
 ----AND SRNO IN(SELECT Srno FROM #DUB2))
 --AND ACID IN(SELECT ACID FROM #DUB2 GROUP BY ACID))

	--							FOR XML PATH ('')
	--							),1,1,'')   

 FROM UploadCollateralDetail V  
 WHERE ISNULL(CollateralSubType,'')<>''
 AND  V.CollateralSubType IN(
				SELECT  A.CollateralSubType FROM CollateralSubTypeData A
						 LEFT JOIN DimCollateralSubType B
						 ON  A.CollateralSubType=B.CollateralSubTypeDescription
						 Where B.CollateralSubTypeDescription IS NULL
				 )
 END 


 --BEGIN
 
 --  UPDATE UploadCollateralDetail
	--SET  
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid ‘Collateral Sub Type’ & ‘Collateral Type’ combination. Kindly enter the values as mentioned in the ‘Collateral Sub Type’ master & it’s ‘Collateral Type’ and upload again. Click on ‘Download Master value’ to download the valid values for the column'     
	--					ELSE ErrorMessage+','+SPACE(1)+'Invalid ‘Collateral Sub Type’ & ‘Collateral Type’ combination. Kindly enter the values as mentioned in the ‘Collateral Sub Type’ master & it’s ‘Collateral Type’ and upload again. Click on ‘Download Master value’ to download the valid values for the column'  END   
	--					--ELSE ErrorMessage+','+SPACE(1)+ 'Different PoolID of same combination of PoolName and PoolType is Available. Please check the values and upload again'     END
	--	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Collateral Sub Typ' ELSE   ErrorinColumn +','+SPACE(1)+'Collateral Sub Typ' END     
	--	,Srnooferroneousrows=V.SrNo
	----	STUFF((SELECT ','+SRNO 
	----							FROM #UploadNewAccount A
	----							WHERE A.SrNo IN(SELECT V.SrNo FROM #UploadNewAccount V  
 ----WHERE ISNULL(ACID,'')<>'' AND ISNULL(TERRITORY,'')<>''
 ------AND SRNO IN(SELECT Srno FROM #DUB2))
 ----AND ACID IN(SELECT ACID FROM #DUB2 GROUP BY ACID))

	----							FOR XML PATH ('')
	----							),1,1,'')   

 --FROM UploadCollateralDetail V  
 --WHERE ISNULL(CollateralSubType,'')<>''
 --AND  V.CollateralSubType IN(
	--			SELECT  A.CollateralSubType FROM CollateralSubTypeData A
	--			 LEFT JOIN DimCollateralType B
	--			 ON  A.CollateralSubTypeAltKey=B.CollateralTypeAltKey
	--			 Where B.CollateralTypeAltKey IS NULL
 
	--			 )
 --END 
 -------------------------------------------------------------------------

 ----------------------------------------------
    
 -------------Collateral  Type---------------------------------
 Declare @CollateralTypeCnt int=0
 IF OBJECT_ID('CollateralSubTypeData') IS NOT NULL  
	  BEGIN  
	   DROP TABLE CollateralTypeData  
	
	  END

	  
 SELECT * into CollateralTypeData  FROM(
 SELECT ROW_NUMBER() OVER(PARTITION BY A.CollateralSubType  ORDER BY  A.CollateralType ) 
 ROW ,A.CollateralType,B.CollateralTypeAltKey FROM UploadCollateralDetail A
LEFT JOIN DimCollateralType B
 ON  A.CollateralType=B.CollateralTypeDescription
 )X
 WHERE ROW=1

 

  SELECT  @CollateralSubTypeCnt=COUNT(*) FROM CollateralTypeData A
 LEFT JOIN DimCollateralType B
 ON  A.CollateralType=B.CollateralTypeDescription
 Where B.CollateralTypeDescription IS NULL

 

UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Collateral  Type cannot be blank . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Collateral  Type cannot be blank . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Collateral  Type' ELSE   ErrorinColumn +','+SPACE(1)+'Collateral  Type' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadCollateralDetail V  
 WHERE ISNULL(CollateralType,'')=''


IF @CollateralTypeCnt>0

BEGIN
 
   UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid value in column ‘Collateral  Type’. Kindly enter the values as mentioned in the ‘Collateral  Type’ master and upload again. Click on ‘Download Master value’ to download the vali






d values for the column'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid value in column ‘Collateral  Type’. Kindly enter the values as mentioned in the ‘Collateral  Type’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'  






END   
						--ELSE ErrorMessage+','+SPACE(1)+ 'Different PoolID of same combination of PoolName and PoolType is Available. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Collateral  Typ' ELSE   ErrorinColumn +','+SPACE(1)+'Collateral  Typ' END     
		,Srnooferroneousrows=V.SrNo
	--	STUFF((SELECT ','+SRNO 
	--							FROM #UploadNewAccount A
	--							WHERE A.SrNo IN(SELECT V.SrNo FROM #UploadNewAccount V  
 --WHERE ISNULL(ACID,'')<>'' AND ISNULL(TERRITORY,'')<>''
 ----AND SRNO IN(SELECT Srno FROM #DUB2))
 --AND ACID IN(SELECT ACID FROM #DUB2 GROUP BY ACID))

	--							FOR XML PATH ('')
	--							),1,1,'')   

 FROM UploadCollateralDetail V  
 WHERE ISNULL(CollateralType,'')<>''
 AND  V.CollateralType IN(
				SELECT  A.CollateralType FROM CollateralTypeData A
						 LEFT JOIN DimCollateralType B
						 ON  A.CollateralType=B.CollateralTypeDescription
						 Where B.CollateralTypeDescription IS NULL
				 )
 END 


 BEGIN
 
   UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid ‘Collateral Sub Type’ & ‘Collateral Type’ combination. Kindly enter the values as mentioned in the ‘Collateral Sub Type’ master & it’s ‘Collateral Type’ and upload again. Click on ‘Do










wnload Master value’ to download the valid values for the column'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid ‘Collateral Sub Type’ & ‘Collateral Type’ combination. Kindly enter the values as mentioned in the ‘Collateral Sub Type’ master & it’s ‘Collateral Type’ and upload again. Click on ‘Download Master value’ to do










wnload the valid values for the column'  END   
						--ELSE ErrorMessage+','+SPACE(1)+ 'Different PoolID of same combination of PoolName and PoolType is Available. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Collateral Sub Typ' ELSE   ErrorinColumn +','+SPACE(1)+'Collateral Sub Typ' END     
		,Srnooferroneousrows=V.SrNo
	--	STUFF((SELECT ','+SRNO 
	--							FROM #UploadNewAccount A
	--							WHERE A.SrNo IN(SELECT V.SrNo FROM #UploadNewAccount V  
 --WHERE ISNULL(ACID,'')<>'' AND ISNULL(TERRITORY,'')<>''
 ----AND SRNO IN(SELECT Srno FROM #DUB2))
 --AND ACID IN(SELECT ACID FROM #DUB2 GROUP BY ACID))

	--							FOR XML PATH ('')
	--							),1,1,'')   

 FROM UploadCollateralDetail V  
 WHERE ISNULL(CollateralType,'')<>''
 AND  V.CollateralType IN(
				SELECT  A.CollateralType FROM CollateralTypeData A
				 LEFT JOIN DimCollateralType B
				 ON  A.CollateralTypeAltKey=B.CollateralTypeAltKey
				 Where B.CollateralTypeAltKey IS NULL
 
				 )
 END 
----------------------------------------------

------------Charge Typee---------------------------------
 Declare @ChargeTypeCnt int=0
 IF OBJECT_ID('ChargeTypeData') IS NOT NULL  
	  BEGIN  
	   DROP TABLE ChargeTypeData  
	
	  END

	  
 SELECT * into ChargeTypeData  FROM(
 SELECT ROW_NUMBER() OVER(PARTITION BY ChargeType  ORDER BY  ChargeType ) 
 ROW ,ChargeType FROM UploadCollateralDetail
 )X
 WHERE ROW=1

 

  SELECT  @ChargeTypeCnt=COUNT(*) FROM ChargeTypeData A
 LEFT JOIN DimCollateralChargeType B
 ON  A.ChargeType=B.CollChargeDescription
 Where B.CollChargeDescription IS NULL

 

UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Charge Type cannot be blank . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Charge Type cannot be blank . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Charge Type' ELSE   ErrorinColumn +','+SPACE(1)+'Charge Type' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadCollateralDetail V  
 WHERE ISNULL(ChargeType,'')=''


   IF @ChargeTypeCnt>0

BEGIN
 
   UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid value in column ‘Charge Type’. Kindly enter the values as mentioned in the ‘Charge Type’ master and upload again. Click on ‘Download Master value’ to download the valid values for the
column'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid value in column ‘Charge Type’. Kindly enter the values as mentioned in the ‘Charge Type’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'     END
						--ELSE ErrorMessage+','+SPACE(1)+ 'Different PoolID of same combination of PoolName and PoolType is Available. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Charge Type' ELSE   ErrorinColumn +','+SPACE(1)+'Charge Type' END     
		,Srnooferroneousrows=V.SrNo
	--	STUFF((SELECT ','+SRNO 
	--							FROM #UploadNewAccount A
	--							WHERE A.SrNo IN(SELECT V.SrNo FROM #UploadNewAccount V  
 --WHERE ISNULL(ACID,'')<>'' AND ISNULL(TERRITORY,'')<>''
 ----AND SRNO IN(SELECT Srno FROM #DUB2))
 --AND ACID IN(SELECT ACID FROM #DUB2 GROUP BY ACID))

	--							FOR XML PATH ('')
	--							),1,1,'')   

 FROM UploadCollateralDetail V  
 WHERE ISNULL(ChargeType,'')<>''
 AND  V.ChargeType IN(
				  SELECT  A.ChargeType FROM ChargeTypeData A
					 LEFT JOIN DimCollateralChargeType B
					 ON  A.ChargeType=B.CollChargeDescription
					 Where B.CollChargeDescription IS NULL
				 )
 END 


---------------------25042021 Added by Poonam/Anuj--------------------------
------------Charge Nature---------------------------
 Declare @ChargeNatureCnt int=0
 IF OBJECT_ID('ChargeNatureData') IS NOT NULL  
	  BEGIN  
	   DROP TABLE ChargeNatureData  
	
	  END

	  
 SELECT * into ChargeNatureData  FROM(
 SELECT ROW_NUMBER() OVER(PARTITION BY ChargeNature  ORDER BY  ChargeNature ) 
 ROW ,ChargeNature FROM UploadCollateralDetail
 )X
 WHERE ROW=1

 

  SELECT  @ChargeTypeCnt=COUNT(*) FROM ChargeNatureData A
 LEFT JOIN DimSecurityChargeType B
 ON  A.ChargeNature=B.SecurityChargeTypeName
 Where B.SecurityChargeTypeName IS NULL

 

UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Charge Nature cannot be blank . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Charge Nature cannot be blank . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Charge Nature' ELSE   ErrorinColumn +','+SPACE(1)+'Charge Nature' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadCollateralDetail V  
 WHERE ISNULL(ChargeNature,'')=''


   IF @ChargeNatureCnt>0

BEGIN
 
   UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid value in column ‘Charge Nature’. Kindly enter the values as mentioned in the ‘Charge Nature’ master and upload again. Click on ‘Download Master value’ to download the valid values for
 the column'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid value in column ‘Charge Nature’. Kindly enter the values as mentioned in the ‘Charge Nature’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'     END
						--ELSE ErrorMessage+','+SPACE(1)+ 'Different PoolID of same combination of PoolName and PoolType is Available. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Charge Nature' ELSE   ErrorinColumn +','+SPACE(1)+'Charge Nature' END     
		,Srnooferroneousrows=V.SrNo
	--	STUFF((SELECT ','+SRNO 
	--							FROM #UploadNewAccount A
	--							WHERE A.SrNo IN(SELECT V.SrNo FROM #UploadNewAccount V  
 --WHERE ISNULL(ACID,'')<>'' AND ISNULL(TERRITORY,'')<>''
 ----AND SRNO IN(SELECT Srno FROM #DUB2))
 --AND ACID IN(SELECT ACID FROM #DUB2 GROUP BY ACID))

	--							FOR XML PATH ('')
	--							),1,1,'')   

 FROM UploadCollateralDetail V  
 WHERE ISNULL(ChargeNature,'')<>''
 AND  V.ChargeNature IN(
					SELECT  A.ChargeNature FROM ChargeNatureData A
					 LEFT JOIN DimSecurityChargeType B
					 ON  A.ChargeNature=B.SecurityChargeTypeName
					 Where B.SecurityChargeTypeName IS NULL
				 )
 END 

 --------------------------------------------
  
 

 
---------------------------------------------------

	 /*validations on ValuationSource/Expiry Business Rule		   */


	-- Declare @ValuationCnt Int=0
 --IF OBJECT_ID('ValuationSourceData') IS NOT NULL  
	--  BEGIN  
	--   DROP TABLE ValuationSourceData  
	
	--  END

	  
 --SELECT * into ValuationSourceData  FROM(
 --SELECT ROW_NUMBER() OVER(PARTITION BY A.ExpiryBusinessRule  ORDER BY  A.ExpiryBusinessRule ) 
 --ROW ,A.ExpiryBusinessRule,B.SecuritySubTypeAlt_Key,C.CollateralSubTypeDescription FROM UploadCollateralDetail A
 --LEFT JOIN DimValueExpiration B ON A.ExpiryBusinessRule=B.Documents
 --LEFT  JOIN DimCollateralSubType C ON A.CollateralSubType= C.CollateralSubTypeDescription
 --Where B.SecuritySubTypeAlt_Key=C.CollateralSubTypeAltKey
  
 
 --)X
 --WHERE ROW=1

 

 -- SELECT  @ValuationCnt=COUNT(*) FROM ValuationSourceData A
 
 ----Where A.CollateralSubTypeDescription IS NULL

 --PRINT '@ValuationCnt'
 --PRINT @ValuationCnt

--UPDATE UploadCollateralDetail
--	SET  
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'ValuationSource/Expiry Business Rule cannot be blank . Please check the values and upload again'     
--						ELSE ErrorMessage+','+SPACE(1)+'ValuationSource/Expiry Business Rule cannot be blank . Please check the values and upload again'     END
--		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'ValuationSource/Expiry Business Rule' ELSE   ErrorinColumn +','+SPACE(1)+'ValuationSource/Expiry Business Rule' END   
--		,Srnooferroneousrows=V.SrNo
								
   
--   FROM UploadCollateralDetail V  
-- WHERE ISNULL(ExpiryBusinessRule,'')=''


--IF @ValuationCnt=0

--BEGIN

-- PRINT 'Sachin'
--   UPDATE UploadCollateralDetail
--	SET  
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Entered ‘Basis of Valuation Source’ is not applicable for the entered ‘Sub type of Collateral’. Kindly enter the values as mentioned in the ‘Valuation Source’ master & it’s ‘Sub Type of Colla
--teral’ and upload again. Click on ‘Download Master value’ to download the valid values for the column'     
--						ELSE ErrorMessage+','+SPACE(1)+'Entered ‘Basis of Valuation Source’ is not applicable for the entered ‘Sub type of Collateral’. Kindly enter the values as mentioned in the ‘Valuation Source’ master & it’s ‘Sub Type of Collateral’ and upload again. C
--lick on ‘Download Master value’ to download the valid values for the column'  END   
--						--ELSE ErrorMessage+','+SPACE(1)+ 'Different PoolID of same combination of PoolName and PoolType is Available. Please check the values and upload again'     END
--		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'ValuationSource/Expiry Business Rule' ELSE   ErrorinColumn +','+SPACE(1)+'ValuationSource/Expiry Business Rule' END     
--		,Srnooferroneousrows=V.SrNo
 

-- FROM UploadCollateralDetail V  
-- WHERE ISNULL(ExpiryBusinessRule,'')<>''
-- --AND  V.ExpiryBusinessRule IN(
--	--			SELECT  A.ExpiryBusinessRule FROM ValuationSourceData A
				 
--	--			 Where A.CollateralSubTypeDescription IS NULL
--	--			 )
-- END 

 ---------------------------------------------------
  /*-------------------Current Collateral Value in Rs...-Validation------------------------- */ -- changes done on 19-03-21 Pranay 
  /*validations on Current Collateral Value in Rs.l*/
  
  UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Current Collateral Value in Rs. cannot be blank . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Current Collateral Value in Rs. cannot be blank . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Current Collateral Value in Rs..' ELSE   ErrorinColumn +','+SPACE(1)+'PoolID' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadCollateralDetail V  
   WHERE ISNULL(CurrentCollateralValueinRs,'')=''



  



  UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid values in ‘Current Collateral Value in Rs.’. Kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid values in ‘Current Collateral Value in Rs.’. Kindly check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Current Collateral Value in Rs..' ELSE   ErrorinColumn +','+SPACE(1)+'Current Collateral Value in Rs.' END       
		,Srnooferroneousrows=V.SrNo

   
   FROM UploadCollateralDetail V  
  WHERE (ISNUMERIC(CurrentCollateralValueinRs)=0 AND ISNULL(CurrentCollateralValueinRs,'')<>'') OR 
 ISNUMERIC(CurrentCollateralValueinRs) LIKE '%^[0-9]%'

 -----------------------------------------------------------------------------------
   ---------------------------------------------------

	 /*validations on Date of Valuation		   */
    
	Set DateFormat DMY
	 UPDATE UploadCollateralDetail
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Date of Valuation must be in ddmmyyyy format. Kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Date of Valuation must be in ddmmyyyy format. Kindly check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Date of Valuation' ELSE   ErrorinColumn +','+SPACE(1)+'Date of Valuation' END       
		,Srnooferroneousrows=V.SrNo

   
  FROM UploadCollateralDetail V  
WHERE  
  ISDATE(ValuationDate)=0 AND ISNULL(ValuationDate,'')<>'' 
  --AND ISNULL(CollateralSubType,'') NOT in('Corporate Guarantee','Personal Guarantee')
	

	-- UPDATE UploadCollateralDetail
	--SET  
 --      ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Date of Valuation	 cannot be blank or greater than 25 Character. Please check the values and upload again.'     
	--					ELSE ErrorMessage+','+SPACE(1)+'Date of Valuation	l cannot be blank or greater than 25 Character. Please check the values and upload again.'     END
	--	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Date of Valuation ' ELSE   ErrorinColumn +','+SPACE(1)+'Date of Valuation		 ' END   
	--	,Srnooferroneousrows=V.SrNo
								
   
 --  FROM UploadCollateralDetail V  
 --WHERE ISNULL(ValuationDate,'')='' AND ISNULL(CollateralSubType,'') NOT in('Corporate Guarantee','Personal Guarantee')


--UPDATE UploadCollateralDetail
--	SET  
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Valuation date must be less than equal to Current Date. Kindly check and upload again'     
--						ELSE ErrorMessage+','+SPACE(1)+'Valuation date must be less than equal to Current Date. Kindly check and upload again'     END
--		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Date of Valuation' ELSE   ErrorinColumn +','+SPACE(1)+'Date 
--of Valuation	' END       
--		,Srnooferroneousrows=V.SrNo


--  FROM UploadCollateralDetail V  
--WHERE (Case When ISDATE(ValuationDate)=0 Then 2
--  When ISDATE(ValuationDate)=1 AND Convert(date,ValuationDate)<=Convert(date,Getdate())     Then 1
--       Else 0 END)=0 
	   
	   --AND ISNULL(CollateralSubType,'') NOT in('Corporate Guarantee','Personal Guarantee')



	    ---------------------------------------------------


	    ---------------------------------------------------
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
		IF NOT EXISTS(Select 1 from  CollateralStockStatementUpload_stg WHERE filname=@FilePathUpload)
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
			FROM UploadCollateralDetail 

			print 'Row Effected'

			print @@ROWCOUNT
			
		--	----SELECT * FROM UploadCollateralDetail 

		--	--ORDER BY ErrorMessage,UploadCollateralDetail.ErrorinColumn DESC
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
	
		ORDER BY CONVERT(INT,SR_No)

		 IF EXISTS(SELECT 1 FROM CollateralStockStatementUpload_stg WHERE filname=@FilePathUpload)
		 BEGIN
		 Print '1'
		 --DELETE FROM CollateralStockStatementUpload_stg
		 --WHERE filname=@FilePathUpload


		 PRINT '2';

		 PRINT 'ROWS DELETED FROM DBO.CollateralStockStatementUpload_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
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

	----SELECT * FROM UploadCollateralDetail

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