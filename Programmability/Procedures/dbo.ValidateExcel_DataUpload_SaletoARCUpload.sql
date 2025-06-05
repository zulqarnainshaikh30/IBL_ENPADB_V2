SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[ValidateExcel_DataUpload_SaletoARCUpload] 
@MenuID INT=10,  
@UserLoginId  VARCHAR(20)='FNASUPERADMIN',  
@Timekey INT=49999
,@filepath VARCHAR(MAX) ='SaletoARC.xlsx'  
WITH RECOMPILE  
AS  
  


--DECLARE  
  
--@MenuID INT=161,  
--@UserLoginId varchar(20)='FNASUPERADMIN',  
--@Timekey int=49999
--,@filepath varchar(500)='InterestReversalUpload (5).xlsx'  
  
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


--IF (@MenuID=14573)	
BEGIN


	  -- IF OBJECT_ID('tempdb..UploadSaletoARC') IS NOT NULL  
	  --BEGIN  
	  -- DROP TABLE UploadSaletoARC  
	
	  --END
	  --drop table if exists  UploadSaletoARC 
	   IF OBJECT_ID('UploadSaletoARC') IS NOT NULL  
		  BEGIN
	    
			DROP TABLE  UploadSaletoARC
	
		  END
	   
  IF NOT (EXISTS (SELECT * FROM SaletoARC_Stg where filname=@FilePathUpload))

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
 	   into UploadSaletoARC 
	   from SaletoARC_Stg 
	   WHERE filname=@FilePathUpload

	   UPDATE DateOfSaletoARC SET UploadID=1 FROM DateOfSaletoARC WHERE UploadID IS NULL
END
  ------------------------------------------------------------------------------  
    ----SELECT * FROM UploadSaletoARC
	--SrNo	Territory	ACID	InterestReversalAmount	filname
	UPDATE UploadSaletoARC
	SET  
        ErrorMessage='There is no data in excel. Kindly check and upload again' 
		,ErrorinColumn='SRNO,SourceSystem,CustomerID,CustomerName,AccountID,BalanceOSinRs,POS,InterestReceivableinRs,DateOfSaletoARC,DateofApproval,ExposuretoARCinRs'    
		,Srnooferroneousrows=''
 FROM UploadSaletoARC V  
 WHERE ISNULL(AccountID,'')=''
--AND ISNULL(CustomerID,'')=''
--AND ISNULL(PrincipalOutstandinginRs,'')=''
--AND ISNULL(InterestReceivableinRs,'')=''
--AND ISNULL(BalanceOSinRs,'')=''
AND ISNULL(ExposuretoARCinRs,'')=''
AND ISNULL(DateOfSaletoARC,'')=''
AND ISNULL(DateOfApproval,'')=''
AND ISNULL(Action,'')=''

-- WHERE ISNULL(V.SrNo,'')=''
-- ----AND ISNULL(Territory,'')=''
-- AND ISNULL(SourceSystem,'')=''
-- AND ISNULL(CustomerID,'')=''
-- AND ISNULL(CustomerName,'')=''
--AND ISNULL(AccountID,'')=''
-- AND ISNULL(BalanceOSinRs,'')=''
-- AND ISNULL(POS,'')=''
-- AND ISNULL(InterestReceivableinRs,'')=''
-- AND ISNULL(DateOfSaletoARC,'')=''
-- AND ISNULL(DateOfApproval,'')=''
-- AND ISNULL(ExposuretoARCinRs,'')=''
--  AND ISNULL(filname,'')=''
  
  IF EXISTS(SELECT 1 FROM UploadSaletoARC WHERE ISNULL(ErrorMessage,'')<>'')
  BEGIN
  PRINT 'NO DATA'
  GOTO ERRORDATA;
  END
  select * from UploadSaletoARC  
      /*validations on Sl. No.*/
 ------------------------------------------------------------

  Declare @DuplicateCnt int=0
   UPDATE UploadSaletoARC
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'SrNo cannot be blank . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'SrNo cannot be blank . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' ELSE   ErrorinColumn +','+SPACE(1)+'SrNo' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadSaletoARC V  
 WHERE ISNULL(SrNo,'')='' or ISNULL(SrNo,'0')='0'


  UPDATE UploadSaletoARC
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'SrNo cannot be greater than 16 character . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'SrNo cannot be greater than 16 character . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' ELSE   ErrorinColumn +','+SPACE(1)+'SrNo' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadSaletoARC V  
 WHERE Len(SrNo)>16

  UPDATE UploadSaletoARC
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid Sl. No., kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid Sl. No., kindly check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' ELSE   ErrorinColumn +','+SPACE(1)+'SrNo' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadSaletoARC V  
  WHERE (ISNUMERIC(SrNo)=0 AND ISNULL(SrNo,'')<>'') OR 
 ISNUMERIC(SrNo) LIKE '%^[0-9]%'

 UPDATE UploadSaletoARC
	SET  
  ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Special characters not allowed, kindly remove and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Special characters not allowed, kindly remove and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' ELSE   ErrorinColumn +','+SPACE(1)+'SrNo' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadSaletoARC V  
   WHERE ISNULL(SrNo,'') LIKE'%[,!@#$%^&*()_-+=/]%'

   --
  SELECT @DuplicateCnt=Count(1)
FROM UploadSaletoARC
GROUP BY  SrNo
HAVING COUNT(SrNo) >1;

IF (@DuplicateCnt>0)

 UPDATE		UploadSaletoARC
SET			ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Duplicate Sl. No., kindly check and upload again'     
						 ELSE ErrorMessage+','+SPACE(1)+'Duplicate Sl. No., kindly check and upload again'     END
			,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' ELSE   ErrorinColumn +','+SPACE(1)+'SrNo' END   
			,Srnooferroneousrows=V.SrNo			
   FROM		UploadSaletoARC V  
   Where	ISNULL(SrNo,'') In(  
								   SELECT SrNo
									FROM UploadSaletoARC a
									GROUP BY  SrNo
									HAVING COUNT(SrNo) >1
							   )

							   
----------------------------------------------
  
  
 
--------------Added on 29/04/2022


 ------------------------------------------------------
 /*validations on Action*/
  
  UPDATE UploadSaletoARC
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Action cannot be blank . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Action cannot be blank . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Action' ELSE   ErrorinColumn +','+SPACE(1)+'Action' END   
		,Srnooferroneousrows=V.SrNo
								--STUFF((SELECT ','+SRNO 
								--FROM UploadSaletoARC A
								--WHERE A.SrNo IN(SELECT V.SrNo  FROM UploadSaletoARC V  
								--WHERE ISNULL(SOLID,'')='')
								--FOR XML PATH ('')
								--),1,1,'')
   
   FROM UploadSaletoARC V  
 WHERE ISNULL(Action,'')=''
 --select * from UploadSaletoARC where PoolType  in  ('With Risk' , 'With out Risk')
 
  UPDATE UploadSaletoARC
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid Action.  Please check the values A or R  and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid Action.  Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Action' ELSE   ErrorinColumn +','+SPACE(1)+'Action' END       
		,Srnooferroneousrows=V.SrNo

   
   FROM UploadSaletoARC V  
 WHERE Action  NOT in  ('A','R' )

 ----------- Condition for Account Already Marked with Action--- Pravin 06082022

   UPDATE UploadSaletoARC
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'This Action is Already Marked on this Account.  Please check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'This Action is Already Marked on this Account.  Please check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Action' ELSE   ErrorinColumn +','+SPACE(1)+'Action' END       
		,Srnooferroneousrows=V.SrNo

   
   FROM UploadSaletoARC V  
 WHERE Action in  ('A')
 And  exists (Select 1 FRom SaletoARCFinalACFlagging A where A.AccountID=V.AccountID  And A.EffectiveToTimeKey=49999
	 And AuthorisationStatus In ('A'))



	 
   UPDATE UploadSaletoARC
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Account is not Marked with Action A, for performig Acion R.  Please check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'This Action is Already Marked on this Account.  Please check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Action' ELSE   ErrorinColumn +','+SPACE(1)+'Action' END       
		,Srnooferroneousrows=V.SrNo

 
FROM UploadSaletoARC V  
 WHERE Action in  ('R')
 And not exists (Select 1 FRom SaletoARCFinalACFlagging A where A.AccountID=V.AccountID  And A.EffectiveToTimeKey=49999
	 And AuthorisationStatus In ('A','R'))

	 UPDATE UploadSaletoARC						
	SET  					
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Record for AccountID  is pending for authorization in ‘Upload ID’ '+ Convert(Varchar(10),B.UploadId) +' kindly remove the record and upload again '     						
						ELSE ErrorMessage+','+SPACE(1)+'Record for AccountID  is pending for authorization in ‘Upload ID’ '+ Convert(Varchar(10),B.UploadId) +' kindly remove the record and upload again '     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'AccountID ' ELSE   ErrorinColumn +','+SPACE(1)+'AccountID ' END       				
		,Srnooferroneousrows=V.SrNo				
    FROM UploadSaletoARC V  						
   LEFT Join SaletoARC_Mod B ON V.AccountID=B.AccountID						
   --LEFT Join CollateralDetailUpload_Mod C ON V.AssetID=C.AssetID						
 WHERE	B.AuthorisationStatus In('NP','MP','FM','RM','1A') 					
 and (B.AccountID is not NULL)	

 
  ---------------------------------------------


 -----validations on Srno
 
--	 UPDATE UploadSaletoARC
--	SET  
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 
		
--	'Sr. No. cannot be blank.  Please check the values and upload again' 
--		ELSE ErrorMessage+','+SPACE(1)+ 'Sr. No. cannot be blank.  Please check the values and upload again'
--		END
--	,ErrorinColumn='SRNO'    
--	,Srnooferroneousrows=''
--	FROM UploadSaletoARC V  
--	WHERE ISNULL(v.SrNo,'')=''  

-- UPDATE UploadSaletoARC
--	SET  
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid Sr. No.  Please check the values and upload again'     
--								  ELSE ErrorMessage+','+SPACE(1)+ 'Invalid Sr. No.  Please check the values and upload again'      END
--		,ErrorinColumn='SRNO'    
--		,Srnooferroneousrows=SRNOSrNo,'')=0   OR ISNULL(v.SrNo,'')<0
  
  
--  IF OBJECT_ID('TEMPDB..#R') IS NOT NULL
--  DROP TABLE #R

--  SELECT * INTO #R FROM(
--  SELECT *,ROW_NUMBER() OVER(PARTITION BY SRNO ORDER BY SRNO)ROW
--   FROM UploadSaletoARC
--   )A
--   WHERE ROW>1

-- PRINT 'DUB'  


--  UPDATE UploadSaletoARC
--	SET  
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Following sr. no. are repeated' 
--					ELSE ErrorMessage+','+SPACE(1)+     'Following sr. no. are repeated' END
--		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SRNO' ELSE ErrorinColumn +','+SPACE(1)+  'SRNO' END
--		,Srnooferroneousrows=SRNO
----		--STUFF((SELECT DISTINCT ','+SRNO 
----		--						FROM UploadSaletoARC
----		--						FOR XML PATH ('')
----		--						),1,1,'')
         
		
-- FROM UploadSaletoARC V  
--	WHERE  V.Srno IN(SELECT SRNO FROM #R )

--  ---------VALIDATIONS ON ACID
  UPDATE UploadSaletoARC
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Account ID cannot be blank.  Please check the values and upload again'     
					ELSE ErrorMessage+','+SPACE(1)+'Account ID cannot be blank.  Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Account ID' ELSE ErrorinColumn +','+SPACE(1)+  'Account ID' END  
		,Srnooferroneousrows=V.SRNO
--								----STUFF((SELECT ','+SRNO 
--								----FROM UploadSaletoARC A
--								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadSaletoARC V  
--								----				WHERE ISNULL(ACID,'')='' )
--								----FOR XML PATH ('')
--								----),1,1,'')   

 FROM UploadSaletoARC V  
 WHERE ISNULL(AccountID,'')='' 

-- ----SELECT * FROM UploadSaletoARC
  
  UPDATE UploadSaletoARC
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid Account ID found. Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid Account ID found. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Account ID' ELSE ErrorinColumn +','+SPACE(1)+  'Account ID' END  
		,Srnooferroneousrows=V.SRNO
--								--STUFF((SELECT ','+SRNO 
--								--FROM UploadSaletoARC A
--								--WHERE A.SrNo IN(SELECT V.SrNo FROM UploadSaletoARC V
--								-- WHERE ISNULL(V.ACID,'')<>''
--								--		AND V.ACID NOT IN(SELECT SystemAcid FROM AxisIntReversalDB.IntReversalDataDetails 
--								--										WHERE -----EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
--								--										Timekey=@Timekey
--								--		))
--								--FOR XML PATH ('')
--								--),1,1,'')   
		FROM UploadSaletoARC V  
 WHERE ISNULL(V.AccountID,'')<>''
 AND V.AccountID NOT IN(SELECT CustomerACID FROM [CurDat].[AdvAcBasicDetail] 
								WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
 )

-- ----SELECT * FROM UploadSaletoARC
   
  print 'acid'
--  -------combination
--------	PRINT 'TerritoryAlt_Key'
   
  UPDATE UploadSaletoARC
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid Account ID found. Please check the values and upload again'     
					ELSE ErrorMessage+','+SPACE(1)+  'Invalid Account ID found. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Account ID' ELSE ErrorinColumn +','+SPACE(1)+  'Account ID' END  
		,Srnooferroneousrows=V.SRNO
--								----STUFF((SELECT ','+SRNO 
--								----FROM UploadSaletoARC A
--								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadSaletoARC V
--								----WHERE ISNULL(ACID,'') <>'' and LEN(ACID)>25 )
--								----FOR XML PATH ('')
--								----),1,1,'')   

 FROM UploadSaletoARC V  
 WHERE ISNULL(AccountID,'') <>'' and LEN(AccountID)>25 

-- -------------------------FOR DUPLICATE ACIDS
 IF OBJECT_ID('TEMPDB..#ACID_DUP') IS NOT NULL
 DROP TABLE #ACID_DUP

 SELECT * INTO #ACID_DUP FROM(
 SELECT *,ROW_NUMBER() OVER(PARTITION BY AccountID ORDER BY  AccountID)AS ROW FROM UploadSaletoARC
 )A
 WHERE ROW>1

 UPDATE UploadSaletoARC
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Duplicate records found. Account ID are repeated.  Please check the values and upload again'     
					ELSE ErrorMessage+','+SPACE(1)+  'Duplicate records found. Account ID are repeated.  Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Account ID' ELSE ErrorinColumn +','+SPACE(1)+  'Account ID' END  
		,Srnooferroneousrows=V.SRNO
--								----STUFF((SELECT ','+SRNO 
--								----FROM UploadSaletoARC A
--								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadSaletoARC V
--								----WHERE ISNULL(ACID,'') <>'' and ACID IN(SELECT ACID FROM #ACID_DUP))
--								----FOR XML PATH ('')
--								----),1,1,'')   

 FROM UploadSaletoARC V  
 WHERE ISNULL(AccountID,'') <>'' and AccountID IN(SELECT AccountID FROM #ACID_DUP)

-- --  ---------VALIDATIONS ON ACID
--  UPDATE UploadSaletoARC
--	SET  
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Account ID cannot be blank.  Please check the values and upload again'     
--					ELSE ErrorMessage+','+SPACE(1)+'Account ID cannot be blank.  Please check the values and upload again'     END
--		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Account ID' ELSE ErrorinColumn +','+SPACE(1)+  'Account ID' END  
--		,Srnooferroneousrows=V.SRNO
----								----STUFF((SELECT ','+SRNO 
----								----FROM UploadSaletoARC A
----								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadSaletoARC V  
----								----				WHERE ISNULL(ACID,'')='' )
----								----FOR XML PATH ('')
----								----),1,1,'')   

-- FROM UploadSaletoARC V  
-- WHERE ISNULL(AccountID,'')='' 

---- ----SELECT * FROM UploadSaletoARC
  
--  UPDATE UploadSaletoARC
--	SET  
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid Account ID found. Please check the values and upload again'     
--						ELSE ErrorMessage+','+SPACE(1)+'Invalid Account ID found. Please check the values and upload again'     END
--		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Account ID' ELSE ErrorinColumn +','+SPACE(1)+  'Account ID' END  
--		,Srnooferroneousrows=V.SRNO
----								--STUFF((SELECT ','+SRNO 
----								--FROM UploadSaletoARC A
----								--WHERE A.SrNo IN(SELECT V.SrNo FROM UploadSaletoARC V
----								-- WHERE ISNULL(V.ACID,'')<>''
----								--		AND V.ACID NOT IN(SELECT SystemAcid FROM AxisIntReversalDB.IntReversalDataDetails 
----								--										WHERE -----EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
----								--										Timekey=@Timekey
----								--		))
----								--FOR XML PATH ('')
----								--),1,1,'')   
--		FROM UploadSaletoARC V  
-- WHERE ISNULL(V.AccountID,'')<>''
-- AND V.AccountID NOT IN(SELECT CustomerACID FROM [CurDat].[AdvAcBasicDetail] 
--								WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
-- )

---- ----SELECT * FROM UploadSaletoARC
   
--  print 'acid'
----  -------combination
----------	PRINT 'TerritoryAlt_Key'
   
--  UPDATE UploadSaletoARC
--	SET  
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid Account ID found. Please check the values and upload again'     
--					ELSE ErrorMessage+','+SPACE(1)+  'Invalid Account ID found. Please check the values and upload again'     END
--		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Account ID' ELSE ErrorinColumn +','+SPACE(1)+  'Account ID' END  
--		,Srnooferroneousrows=V.SRNO
----								----STUFF((SELECT ','+SRNO 
----								----FROM UploadSaletoARC A
----								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadSaletoARC V
----								----WHERE ISNULL(ACID,'') <>'' and LEN(ACID)>25 )
----								----FOR XML PATH ('')
----								----),1,1,'')   

-- FROM UploadSaletoARC V  
-- WHERE ISNULL(AccountID,'') <>'' and LEN(AccountID)>25 

---- -------------------------FOR DUPLICATE CUSTOMERIDS
-- IF OBJECT_ID('TEMPDB..#CUSTOMER_DUP') IS NOT NULL
-- DROP TABLE #ACID_DUP

-- SELECT * INTO #CUSTOMER_DUP FROM(
-- SELECT *,ROW_NUMBER() OVER(PARTITION BY CUSTOMERID ORDER BY  CUSTOMERID)AS ROW FROM UploadSaletoARC
-- )A
-- WHERE ROW>1

-- UPDATE UploadSaletoARC
--	SET  
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Duplicate records found. Customer ID are repeated.  Please check the values and upload again'     
--					ELSE ErrorMessage+','+SPACE(1)+  'Duplicate records found. Customer ID are repeated.  Please check the values and upload again'     END
--		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Customer ID' ELSE ErrorinColumn +','+SPACE(1)+  'Customer ID' END  
--		,Srnooferroneousrows=V.SRNO
----								----STUFF((SELECT ','+SRNO 
----								----FROM UploadSaletoARC A
----								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadSaletoARC V
----								----WHERE ISNULL(ACID,'') <>'' and ACID IN(SELECT ACID FROM #ACID_DUP))
----								----FOR XML PATH ('')
----								----),1,1,'')   

-- FROM UploadSaletoARC V  
-- WHERE ISNULL(CustomerID,'') <>'' and CustomerID IN(SELECT CustomerID FROM #CUSTOMER_DUP)

/*   Commented due to columns Removed 04/05/2022

 --  ---------VALIDATIONS ON CustomerID
  UPDATE UploadSaletoARC
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Customer ID cannot be blank.  Please check the values and upload again'     
					ELSE ErrorMessage+','+SPACE(1)+'Customer ID cannot be blank.  Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Customer ID' ELSE ErrorinColumn +','+SPACE(1)+  'Customer ID' END  
		,Srnooferroneousrows=V.SRNO
--								----STUFF((SELECT ','+SRNO 
--								----FROM UploadSaletoARC A
--								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadSaletoARC V  
--								----				WHERE ISNULL(ACID,'')='' )
--								----FOR XML PATH ('')
--								----),1,1,'')   

 FROM UploadSaletoARC V  
 WHERE ISNULL(CustomerID,'')='' 

-- ----SELECT * FROM UploadSaletoARC
  
  UPDATE UploadSaletoARC
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid Customer ID found. Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid Customer ID found. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Customer ID' ELSE ErrorinColumn +','+SPACE(1)+  'Customer ID' END  
		,Srnooferroneousrows=V.SRNO
--								--STUFF((SELECT ','+SRNO 
--								--FROM UploadSaletoARC A
--								--WHERE A.SrNo IN(SELECT V.SrNo FROM UploadSaletoARC V
--								-- WHERE ISNULL(V.ACID,'')<>''
--								--		AND V.ACID NOT IN(SELECT SystemAcid FROM AxisIntReversalDB.IntReversalDataDetails 
--								--										WHERE -----EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
--								--										Timekey=@Timekey
--								--		))
--								--FOR XML PATH ('')
--								--),1,1,'')   
		FROM UploadSaletoARC V  
 WHERE ISNULL(V.CustomerID,'')<>''
  AND V.CustomerID NOT IN(SELECT RefCustomerId FROM [CurDat].[AdvAcBasicDetail] A
                                         Inner Join UploadSaletoARC V on A.CustomerACID=V.AccountID
								WHERE A.EffectiveFromTimeKey<=@Timekey AND A.EffectiveToTimeKey>=@Timekey
						 )
 --AND V.CustomerID NOT IN(SELECT CustomerID FROM [CurDat].[CustomerBasicDetail]
	--							WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
 --)

 print 'Customerid'
--  -------combination
--------	PRINT 'TerritoryAlt_Key'
   
  UPDATE UploadSaletoARC
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid Customer ID found. Please check the values and upload again'     
					ELSE ErrorMessage+','+SPACE(1)+  'Invalid Customer ID found. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Customer ID' ELSE ErrorinColumn +','+SPACE(1)+  'Customer ID' END  
		,Srnooferroneousrows=V.SRNO
--								----STUFF((SELECT ','+SRNO 
--								----FROM UploadSaletoARC A
--								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadSaletoARC V
--								----WHERE ISNULL(ACID,'') <>'' and LEN(ACID)>25 )
--								----FOR XML PATH ('')
--								----),1,1,'')   

 FROM UploadSaletoARC V  
 WHERE ISNULL(CustomerID,'') <>'' and LEN(CustomerID)>15

------ -------validations on Balance Outstanding
  UPDATE UploadSaletoARC
	SET   

       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Balance Outstanding cannot be blank. Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Balance Outstanding cannot be blank. Please check the values and upload again'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Balance Outstanding' ELSE ErrorinColumn +','+SPACE(1)+  'Balance Outstanding' END  
		,Srnooferroneousrows=V.SRNO
								----STUFF((SELECT ','+SRNO 
								----FROM UploadSaletoARC A
								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadSaletoARC V
								----WHERE ISNULL(InterestReversalAmount,'')='')
								----FOR XML PATH ('')
								----),1,1,'')   

 FROM UploadSaletoARC V  
 WHERE ISNULL(BalanceOSinRs,'')=''

 UPDATE UploadSaletoARC
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid Balance Outstanding. Please check the values and upload again'     
					ELSE ErrorMessage+','+SPACE(1)+'Invalid Int Balance Outstanding. Please check the values and upload again'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Balance Outstanding' ELSE ErrorinColumn +','+SPACE(1)+  'Balance Outstanding' END  
		,Srnooferroneousrows=V.SRNO
								--STUFF((SELECT ','+SRNO 
								--FROM UploadSaletoARC A
								--WHERE A.SrNo IN(SELECT V.SrNo FROM UploadSaletoARC V
								--WHERE (ISNUMERIC(InterestReversalAmount)=0 AND ISNULL(InterestReversalAmount,'')<>'') OR 
								--ISNUMERIC(InterestReversalAmount) LIKE '%^[0-9]%'
								--)
								--FOR XML PATH ('')
								--),1,1,'')   

 FROM UploadSaletoARC V  
 WHERE (ISNUMERIC(BalanceOSinRs)=0 AND ISNULL(BalanceOSinRs,'')<>'') OR 
 ISNUMERIC(BalanceOSinRs) LIKE '%^[0-9]%'
 PRINT 'INVALID' 

 UPDATE UploadSaletoARC
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid Balance Outstanding. Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid Balance Outstanding. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Balance Outstanding' ELSE ErrorinColumn +','+SPACE(1)+  'Balance Outstanding' END  
		,Srnooferroneousrows=V.SRNO
								----STUFF((SELECT ','+SRNO 
								----FROM UploadSaletoARC A
								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadSaletoARC V
								---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
								----)
								----FOR XML PATH ('')
								----),1,1,'')   

 FROM UploadSaletoARC V  
 WHERE ISNULL(BalanceOSinRs,'') LIKE'%[,!@#$%^&*()_-+=/]%'

  UPDATE UploadSaletoARC
	SET  
        ErrorMessage= CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid Balance Outstanding. Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid Balance Outstanding. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Balance Outstanding' ELSE ErrorinColumn +','+SPACE(1)+  'Exposure to Arc Outstanding' END  
		,Srnooferroneousrows=V.SRNO
								----STUFF((SELECT ','+SRNO 
								----FROM UploadSaletoARC A
								----WHERE A.SrNo IN(SELECT SRNO FROM UploadSaletoARC WHERE ISNULL(InterestReversalAmount,'')<>''
								---- AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
								---- )
								----FOR XML PATH ('')
								----),1,1,'')   

 FROM UploadSaletoARC V  
 WHERE ISNULL(BalanceOSinRs,'')<>''
 --AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
 AND TRY_CONVERT(DECIMAL(25,6),ISNULL(BalanceOSinRs,0)) <0

------ -------validations on Interest Receivable
  UPDATE UploadSaletoARC
	SET   

       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Interest Receivable cannot be blank. Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Interest Receivable cannot be blank. Please check the values and upload again'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Interest Receivable' ELSE ErrorinColumn +','+SPACE(1)+  'Interest Receivable' END  
		,Srnooferroneousrows=V.SRNO
								----STUFF((SELECT ','+SRNO 
								----FROM UploadSaletoARC A
								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadSaletoARC V
								----WHERE ISNULL(InterestReversalAmount,'')='')
								----FOR XML PATH ('')
								----),1,1,'')   

 FROM UploadSaletoARC V  
 WHERE ISNULL(InterestReceivableinRs,'')=''

 UPDATE UploadSaletoARC
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid Interest Receivable. Please check the values and upload again'     
					ELSE ErrorMessage+','+SPACE(1)+'Invalid Interest Receivable. Please check the values and upload again'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Interest Receivable' ELSE ErrorinColumn +','+SPACE(1)+  'Interest Receivable' END  
		,Srnooferroneousrows=V.SRNO
								--STUFF((SELECT ','+SRNO 
								--FROM UploadSaletoARC A
								--WHERE A.SrNo IN(SELECT V.SrNo FROM UploadSaletoARC V
								--WHERE (ISNUMERIC(InterestReversalAmount)=0 AND ISNULL(InterestReversalAmount,'')<>'') OR 
								--ISNUMERIC(InterestReversalAmount) LIKE '%^[0-9]%'
								--)
								--FOR XML PATH ('')
								--),1,1,'')   

 FROM UploadSaletoARC V  
 WHERE (ISNUMERIC(InterestReceivableinRs)=0 AND ISNULL(InterestReceivableinRs,'')<>'') OR 
 ISNUMERIC(InterestReceivableinRs) LIKE '%^[0-9]%'
 PRINT 'INVALID' 

 UPDATE UploadSaletoARC
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid Interest Receivable. Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid Interest Receivable. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Interest Receivable' ELSE ErrorinColumn +','+SPACE(1)+  'Interest Receivable' END  
		,Srnooferroneousrows=V.SRNO
								----STUFF((SELECT ','+SRNO 
								----FROM UploadSaletoARC A
								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadSaletoARC V
								---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
								----)
								----FOR XML PATH ('')
								----),1,1,'')   

 FROM UploadSaletoARC V  
 WHERE ISNULL(InterestReceivableinRs,'') LIKE'%[,!@#$%^&*()_-+=/]%'

  UPDATE UploadSaletoARC
	SET  
        ErrorMessage= CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid Interest Receivable. Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid Interest Receivable. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Interest Receivable' ELSE ErrorinColumn +','+SPACE(1)+  'Interest Receivable' END  
		,Srnooferroneousrows=V.SRNO
								----STUFF((SELECT ','+SRNO 
								----FROM UploadSaletoARC A
								----WHERE A.SrNo IN(SELECT SRNO FROM UploadSaletoARC WHERE ISNULL(InterestReversalAmount,'')<>''
								---- AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
								---- )
								----FOR XML PATH ('')
								----),1,1,'')   

 FROM UploadSaletoARC V  
 WHERE ISNULL(InterestReceivableinRs,'')<>''
 --AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
 AND TRY_CONVERT(DECIMAL(25,6),ISNULL(InterestReceivableinRs,0)) <0

 ------ -------validations on PrincipalOutstandinginRs
 UPDATE UploadSaletoARC
	SET   

       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'PrincipalOutstandinginRs cannot be blank. Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'PrincipalOutstandinginRs cannot be blank. Please check the values and upload again'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'PrincipalOutstandinginRs' ELSE ErrorinColumn +','+SPACE(1)+  'PrincipalOutstandinginRs' END  
		,Srnooferroneousrows=V.SRNO
								----STUFF((SELECT ','+SRNO 
								----FROM UploadSaletoARC A
								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadSaletoARC V
								----WHERE ISNULL(InterestReversalAmount,'')='')
								----FOR XML PATH ('')
								----),1,1,'')   

 FROM UploadSaletoARC V  
 WHERE ISNULL(PrincipalOutstandinginRs,'')=''

 UPDATE UploadSaletoARC
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid PrincipalOutstandinginRs. Please check the values and upload again'     
					ELSE ErrorMessage+','+SPACE(1)+'Invalid PrincipalOutstandinginRs. Please check the values and upload again'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'PrincipalOutstandinginRs' ELSE ErrorinColumn +','+SPACE(1)+  'PrincipalOutstandinginRs' END  
		,Srnooferroneousrows=V.SRNO
								--STUFF((SELECT ','+SRNO 
								--FROM UploadSaletoARC A
								--WHERE A.SrNo IN(SELECT V.SrNo FROM UploadSaletoARC V
								--WHERE (ISNUMERIC(InterestReversalAmount)=0 AND ISNULL(InterestReversalAmount,'')<>'') OR 
								--ISNUMERIC(InterestReversalAmount) LIKE '%^[0-9]%'
								--)
								--FOR XML PATH ('')
								--),1,1,'')   

 FROM UploadSaletoARC V  
 WHERE (ISNUMERIC(PrincipalOutstandinginRs)=0 AND ISNULL(PrincipalOutstandinginRs,'')<>'') OR 
 ISNUMERIC(PrincipalOutstandinginRs) LIKE '%^[0-9]%'
 PRINT 'INVALID' 

 UPDATE UploadSaletoARC
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid PrincipalOutstandinginRs. Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid PrincipalOutstandinginRs. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'PrincipalOutstandinginRs' ELSE ErrorinColumn +','+SPACE(1)+  'PrincipalOutstandinginRs' END  
		,Srnooferroneousrows=V.SRNO
								----STUFF((SELECT ','+SRNO 
								----FROM UploadSaletoARC A
								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadSaletoARC V
								---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
								----)
								----FOR XML PATH ('')
								----),1,1,'')   

 FROM UploadSaletoARC V  
 WHERE ISNULL(PrincipalOutstandinginRs,'') LIKE'%[,!@#$%^&*()_-+=/]%'

  UPDATE UploadSaletoARC
	SET  
        ErrorMessage= CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid PrincipalOutstandinginRs. Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid PrincipalOutstandinginRs. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'PrincipalOutstandinginRs' ELSE ErrorinColumn +','+SPACE(1)+  'PrincipalOutstandinginRs' END  
		,Srnooferroneousrows=V.SRNO
								----STUFF((SELECT ','+SRNO 
								----FROM UploadSaletoARC A
								----WHERE A.SrNo IN(SELECT SRNO FROM UploadSaletoARC WHERE ISNULL(InterestReversalAmount,'')<>''
								---- AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
								---- )
								----FOR XML PATH ('')
								----),1,1,'')   

 FROM UploadSaletoARC V  
 WHERE ISNULL(PrincipalOutstandinginRs,'')<>''
 --AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
 AND TRY_CONVERT(DECIMAL(25,6),ISNULL(PrincipalOutstandinginRs,0)) <0
 */
 ------ -------validations on Exposure to Arc
  UPDATE UploadSaletoARC
	SET   

       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Exposure to Arc cannot be blank. Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Exposure to Arc cannot be blank. Please check the values and upload again'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Exposure to Arc' ELSE ErrorinColumn +','+SPACE(1)+  'Exposure to Arc' END  
		,Srnooferroneousrows=V.SRNO
								----STUFF((SELECT ','+SRNO 
								----FROM UploadSaletoARC A
								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadSaletoARC V
								----WHERE ISNULL(InterestReversalAmount,'')='')
								----FOR XML PATH ('')
								----),1,1,'')   

 FROM UploadSaletoARC V  
 WHERE ISNULL(ExposuretoARCinRs,'')=''

 UPDATE UploadSaletoARC
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid Exposure to Arc. Please check the values and upload again'     
					ELSE ErrorMessage+','+SPACE(1)+'Invalid Exposure to Arc. Please check the values and upload again'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Exposure to Arc' ELSE ErrorinColumn +','+SPACE(1)+  'Exposure to Arc' END  
		,Srnooferroneousrows=V.SRNO
								--STUFF((SELECT ','+SRNO 
								--FROM UploadSaletoARC A
								--WHERE A.SrNo IN(SELECT V.SrNo FROM UploadSaletoARC V
								--WHERE (ISNUMERIC(InterestReversalAmount)=0 AND ISNULL(InterestReversalAmount,'')<>'') OR 
								--ISNUMERIC(InterestReversalAmount) LIKE '%^[0-9]%'
								--)
								--FOR XML PATH ('')
								--),1,1,'')   

 FROM UploadSaletoARC V  
 WHERE (ISNUMERIC(ExposuretoARCinRs)=0 AND ISNULL(ExposuretoARCinRs,'')<>'') OR 
 ISNUMERIC(ExposuretoARCinRs) LIKE '%^[0-9]%'
 PRINT 'INVALID' 

 UPDATE UploadSaletoARC
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid Exposure to Arc. Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid Exposure to Arc. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Exposure to Arc' ELSE ErrorinColumn +','+SPACE(1)+  'Exposure to Arc' END  
		,Srnooferroneousrows=V.SRNO
								----STUFF((SELECT ','+SRNO 
								----FROM UploadSaletoARC A
								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadSaletoARC V
								---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
								----)
								----FOR XML PATH ('')
								----),1,1,'')   

 FROM UploadSaletoARC V  
 WHERE ISNULL(ExposuretoARCinRs,'') LIKE'%[,!@#$%^&*()_-+=/]%'

  UPDATE UploadSaletoARC
	SET  
        ErrorMessage= CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid Exposure to Arc. Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid Exposure to Arc. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Exposure to Arc' ELSE ErrorinColumn +','+SPACE(1)+  'Exposure to Arc' END  
		,Srnooferroneousrows=V.SRNO
								----STUFF((SELECT ','+SRNO 
								----FROM UploadSaletoARC A
								----WHERE A.SrNo IN(SELECT SRNO FROM UploadSaletoARC WHERE ISNULL(InterestReversalAmount,'')<>''
								---- AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
								---- )
								----FOR XML PATH ('')
								----),1,1,'')   

 FROM UploadSaletoARC V  
 LEFT JOIN AdvAcBalanceDetail B ON V.AccountID = B.RefSystemAcId
 and B.EffectiveFromTimeKey <= @Timekey and B.EffectiveToTimeKey >= @Timekey
 WHERE ISNULL(ExposuretoARCinRs,'')<>''
 --AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
 AND  (TRY_CONVERT(DECIMAL(25,2),ISNULL(ExposuretoARCinRs,0)) <0
 OR TRY_CONVERT(DECIMAL(25,2),ISNULL(ExposuretoARCinRs,0)) > Balance)

 ----------------------For Flag checking in Main table 



 UPDATE UploadSaletoARC
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Account ID are pending for authorization'     
						ELSE ErrorMessage+','+SPACE(1)+'Account ID are pending for authorization'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Account ID' ELSE ErrorinColumn +','+SPACE(1)+  'Account ID' END  
		,Srnooferroneousrows=V.SrNo
 FROM UploadSaletoARC V  
 WHERE ISNULL(V.AccountID,'')<>''
 AND V.AccountID  IN (SELECT AccountID FROM SaletoARC_Mod
								WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
								AND AuthorisationStatus in ('NP','MP','1A','FM')
						UNION
						SELECT AccountID FROM SaletoARCACFlaggingDetail_MOD
								WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
								AND AuthorisationStatus in ('NP','MP','1A','FM')

						 )


 
UPDATE UploadSaletoARC
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Already SaletoArc Flag is present. Please Check the Account'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Already SaletoArc Flag is present. Please Check the Account'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'AccountID' ELSE   ErrorinColumn +','+SPACE(1)+'AccountID' END      
		,Srnooferroneousrows=V.SrNo
		--STUFF((SELECT ','+SRNO 
		--						FROM #UploadNewAccount A
		--						WHERE A.SrNo IN(SELECT V.SrNo  FROM #UploadNewAccount V  
		--										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))

		--										)
		--						FOR XML PATH ('')
		--						),1,1,'')   

 FROM UploadSaletoARC V  
 Inner Join Dbo.AdvAcOtherDetail A ON V.AccountID=A.RefSystemAcId And v.Action='A' AND A.EffectiveToTimeKey=49999
 WHERE A.SplFlag like '%SaleArc%'
----------- /*validations on DateOfSaletoARC */

 UPDATE UploadSaletoARC
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'DateOfSaletoARC Can not be Blank . Please enter the DateOfSaletoARC and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'DateOfSaletoARC Can not be Blank. Please enter the DateOfSaletoARC and upload again'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'DateOfSaletoARC' ELSE   ErrorinColumn +','+SPACE(1)+'DateOfSaletoARC' END      
		,Srnooferroneousrows=V.SrNo
		--STUFF((SELECT ','+SRNO 
		--						FROM #UploadNewAccount A
		--						WHERE A.SrNo IN(SELECT V.SrNo  FROM #UploadNewAccount V  
		--										WHERE ISNULL(AssetClass,'')<>'' AND ISNULL(AssetClass,'')<>'STD' and  ISNULL(NPADate,'')=''
		--										)
		--						FOR XML PATH ('')
		--						),1,1,'')   

 FROM UploadSaletoARC V  
 WHERE ISNULL(DateOfSaletoARC,'')='' 


UPDATE UploadSaletoARC
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'DateOfSaletoARC' ELSE   ErrorinColumn +','+SPACE(1)+'DateOfSaletoARC' END      
		,Srnooferroneousrows=V.SrNo
		--STUFF((SELECT ','+SRNO 
		--						FROM #UploadNewAccount A
		--						WHERE A.SrNo IN(SELECT V.SrNo  FROM #UploadNewAccount V  
		--										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))

		--										)
		--						FOR XML PATH ('')
		--						),1,1,'')   

 FROM UploadSaletoARC V  
 WHERE ISNULL(DateOfSaletoARC,'')<>'' AND ISDATE(DateOfSaletoARC)=0


 -------------Done by Sudesh 05082022-----------
 
 UPDATE UploadSaletoARC
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'DateOfSaletoARC should be less than equal to current date. Please check and upload again’'     
						ELSE ErrorMessage+','+SPACE(1)+ 'DateOfSaletoARC should be less than equal to current date. Please check and upload again’'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'DateOfSaletoARC' ELSE   ErrorinColumn +','+SPACE(1)+'DateOfSaletoARC' END      
		,Srnooferroneousrows=V.SrNo
		--STUFF((SELECT ','+SRNO 
		--						FROM #UploadNewAccount A
		--						WHERE A.SrNo IN(SELECT V.SrNo  FROM #UploadNewAccount V  
		--										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))

		--										)
		--						FOR XML PATH ('')
		--						),1,1,'')   

 FROM UploadSaletoARC V  
 ---WHERE ISNULL(DateofIBPCmarking,'')<>'' AND ISDATE(DateofIBPCmarking)=0

  WHERE (Case When ISDATE(DateOfSaletoARC)=1 Then Case When Cast(DateOfSaletoARC as date)>Cast(GETDATE() as Date) Then 1 Else 0 END END)=1

----------- /*validations on DateOfApproval 
UPDATE UploadSaletoARC
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'DateOfApproval Can not be Blank . Please enter the DateOfApproval and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'DateOfApproval Can not be Blank. Please enter the DateOfApproval and upload again'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'DateOfApproval' ELSE   ErrorinColumn +','+SPACE(1)+'DateOfApproval' END      
		,Srnooferroneousrows=V.SrNo
		--STUFF((SELECT ','+SRNO 
		--						FROM #UploadNewAccount A
		--						WHERE A.SrNo IN(SELECT V.SrNo  FROM #UploadNewAccount V  
		--										WHERE ISNULL(AssetClass,'')<>'' AND ISNULL(AssetClass,'')<>'STD' and  ISNULL(NPADate,'')=''
		--										)
		--						FOR XML PATH ('')
		--						),1,1,'')   

 FROM UploadSaletoARC V  
 WHERE ISNULL(DateOfApproval,'')='' 


UPDATE UploadSaletoARC
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'DateOfApproval' ELSE   ErrorinColumn +','+SPACE(1)+'DateOfApproval' END      
		,Srnooferroneousrows=V.SrNo
		--STUFF((SELECT ','+SRNO 
		--						FROM #UploadNewAccount A
		--						WHERE A.SrNo IN(SELECT V.SrNo  FROM #UploadNewAccount V  
		--										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))

		--										)
		--						FOR XML PATH ('')
		--						),1,1,'')   

 FROM UploadSaletoARC V  
 WHERE ISNULL(DateOfApproval,'')<>'' AND ISDATE(DateOfApproval)=0

 

 -------------Done by Sudesh 05082022-----------
 
 UPDATE UploadSaletoARC
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'DateOfApproval should be less than equal to current date. Please check and upload again’'     
						ELSE ErrorMessage+','+SPACE(1)+ 'DateOfApproval should be less than equal to current date. Please check and upload again’'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'DateOfApproval' ELSE   ErrorinColumn +','+SPACE(1)+'DateOfApproval' END      
		,Srnooferroneousrows=V.SrNo
		--STUFF((SELECT ','+SRNO 
		--						FROM #UploadNewAccount A
		--						WHERE A.SrNo IN(SELECT V.SrNo  FROM #UploadNewAccount V  
		--										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))

		--										)
		--						FOR XML PATH ('')
		--						),1,1,'')   

 FROM UploadSaletoARC V  
 ---WHERE ISNULL(DateofIBPCmarking,'')<>'' AND ISDATE(DateofIBPCmarking)=0

  WHERE (Case When ISDATE(DateOfApproval)=1 Then Case When Cast(DateOfApproval as date)>Cast(GETDATE() as Date) Then 1 Else 0 END END)=1

 ---------------------------------
 
 -------------------@DateOfApproval--------------------------Pranay 21-03-2021
 DECLARE @DateOfApprovalCnt int=0
 --DROP TABLE IF EXISTS DateOfApprovalData
 IF OBJECT_ID('DateOfApprovalData') IS NOT NULL  
	  BEGIN
	    
		DROP TABLE  DateOfApprovalData
	
	  END

 SELECT * into DateOfApprovalData  FROM(
 SELECT ROW_NUMBER() OVER(PARTITION BY UploadID  ORDER BY  UploadID ) 
 ROW ,UploadID,DateOfApproval FROM UploadSaletoARC
 )X
 WHERE ROW=1


 SELECT @DateOfApprovalCnt=COUNT(*) 
 FROM DateOfApprovalData a
 INNER JOIN UploadSaletoARC b
 ON a.UploadID=b.UploadID 
 WHERE a.DateOfApproval<>b.DateOfApproval

 IF @DateOfApprovalCnt>0
 BEGIN
  PRINT 'DateOfApproval ERROR'
  /*DateOfApproval Validation*/ --Pranay 20-03-2021
  UPDATE UploadSaletoARC
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'UploadID found different Dates of DateOfApproval. Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'UploadID found different Dates of DateOfApproval. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'DateOfApproval' ELSE   ErrorinColumn +','+SPACE(1)+'DateOfApproval' END     
		,Srnooferroneousrows=V.SrNo
	--	STUFF((SELECT ','+SRNO 
	--							FROM #UploadNewAccount A
	--							WHERE A.SrNo IN(SELECT V.SrNo FROM #UploadNewAccount V  
 --WHERE ISNULL(ACID,'')<>'' AND ISNULL(TERRITORY,'')<>''
 ----AND SRNO IN(SELECT Srno FROM #DUB2))
 --AND ACID IN(SELECT ACID FROM #DUB2 GROUP BY ACID))

	--							FOR XML PATH ('')
	--							),1,1,'')   

 FROM UploadSaletoARC V  
 WHERE ISNULL(UploadID,'')<>''
 AND  AccountID IN(
				 SELECT DISTINCT B.AccountID from DateOfApprovalData a
				 INNER JOIN UploadSaletoARC b
				 on a.UploadID=b.UploadID 
				 where a.DateOfApproval<>b.DateOfApproval
				 )


 END



 ----------------------------
 
 -------------------@DateOfSaletoARC--------------------------Pranay 21-03-2021
 DECLARE @DateOfSaletoARCCnt int=0
 --DROP TABLE IF EXISTS DateOfSaletoARCData
 IF OBJECT_ID('DateOfSaletoARCData') IS NOT NULL  
	  BEGIN
	    
		DROP TABLE  DateOfSaletoARCData
	
	  END

 SELECT * into DateOfSaletoARCData  FROM(
 SELECT ROW_NUMBER() OVER(PARTITION BY UploadID  ORDER BY  UploadID ) 
 ROW ,UploadID,DateOfSaletoARC FROM UploadSaletoARC
 )X
 WHERE ROW=1


 SELECT @DateOfSaletoARCCnt=COUNT(*) 
 FROM DateOfSaletoARCData a
 INNER JOIN UploadSaletoARC b
 ON a.UploadID=b.UploadID 
 WHERE a.DateOfSaletoARC<>b.DateOfSaletoARC

 IF @DateOfSaletoARCCnt>0
 BEGIN
  PRINT 'DateOfSaletoARC ERROR'
  /*DateOfSaletoARC Validation*/ --Pranay 20-03-2021
  UPDATE UploadSaletoARC
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'UploadID found different Dates of DateOfSaletoARC. Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'UploadID found different Dates of DateOfSaletoARC. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'DateOfSaletoARC' ELSE   ErrorinColumn +','+SPACE(1)+'DateOfSaletoARC' END     
		,Srnooferroneousrows=V.SrNo
	--	STUFF((SELECT ','+SRNO 
	--							FROM #UploadNewAccount A
	--							WHERE A.SrNo IN(SELECT V.SrNo FROM #UploadNewAccount V  
 --WHERE ISNULL(ACID,'')<>'' AND ISNULL(TERRITORY,'')<>''
 ----AND SRNO IN(SELECT Srno FROM #DUB2))
 --AND ACID IN(SELECT ACID FROM #DUB2 GROUP BY ACID))

	--							FOR XML PATH ('')
	--							),1,1,'')   

 FROM UploadSaletoARC V  
 WHERE ISNULL(UploadID,'')<>''
 AND  AccountID IN(
				 SELECT DISTINCT B.AccountID from DateOfSaletoARCData a
				 INNER JOIN UploadSaletoARC b
				 on a.UploadID=b.UploadID 
				 where a.DateOfSaletoARC<>b.DateOfSaletoARC
				 )


 END



 
 goto valid

  END
	
   ErrorData:  
   print 'no'  

		SELECT *,'Data'TableName
		FROM dbo.MasterUploadData WHERE FileNames=@filepath 
		return

   valid:
		IF NOT EXISTS(Select 1 from  SaletoARC_Stg WHERE filname=@FilePathUpload)
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
			FROM UploadSaletoARC 


			
		--	----SELECT * FROM UploadSaletoARC 

		--	--ORDER BY ErrorMessage,UploadSaletoARC.ErrorinColumn DESC
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

		 IF EXISTS(SELECT 1 FROM SaletoARC_Stg WHERE filname=@FilePathUpload)
		 BEGIN
		 DELETE FROM SaletoARC_Stg
		 WHERE filname=@FilePathUpload

		 PRINT 1

		 PRINT 'ROWS DELETED FROM DBO.SaletoARC_Stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
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

	----SELECT * FROM UploadSaletoARC

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

		-- ELSE IF EXISTS(SELECT 1 FROM [AxisIntReversalDB].IntAccruedData_stg WHERE filname=@FilePathUpload)
		-- BEGIN
		-- DELETE FROM [AxisIntReversalDB].IntAccruedData_stg
		-- WHERE filname=@FilePathUpload

		-- PRINT 'ROWS DELETED FROM DBO.[AxisIntReversalDB].IntAccruedData_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
		-- END

		-- ELSE IF EXISTS(SELECT 1 FROM [AxisIntReversalDB].AddNewAccountData_stg WHERE filname=@FilePathUpload)
		-- BEGIN
		-- DELETE FROM [AxisIntReversalDB].AddNewAccountData_stg
		-- WHERE filname=@FilePathUpload

		-- PRINT 'ROWS DELETED FROM DBO.[AxisIntReversalDB].AddNewAccountData_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
		-- END
		-- end

   
END  TRY
  
  BEGIN CATCH
	

	INSERT INTO dbo.Error_Log
				SELECT ERROR_LINE() as ErrorLine,ERROR_MESSAGE()ErrorMessage,ERROR_NUMBER()ErrorNumber
				,ERROR_PROCEDURE()ErrorProcedure,ERROR_SEVERITY()ErrorSeverity,ERROR_STATE()ErrorState
				,GETDATE()

	IF EXISTS(SELECT 1 FROM SaletoARC_Stg WHERE filname=@FilePathUpload)
		 BEGIN
		 DELETE FROM SaletoARC_Stg
		 WHERE filname=@FilePathUpload

		 PRINT 'ROWS DELETED FROM DBO.SaletoARC_Stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
		 END

END CATCH

END
  
GO