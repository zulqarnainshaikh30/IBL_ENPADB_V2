SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--sp_rename 'ValidateExcel_DataUpload_StockStatementUpload','ValidateExcel_DataUpload_StockStatementUpload_20042022'

CREATE PROCEDURE [dbo].[ValidateExcel_DataUpload_StockStatementUpload]  
@MenuID INT=10,  
@UserLoginId  VARCHAR(20)='fnachecker',  
@Timekey INT=49999
,@filepath VARCHAR(MAX) ='IBPCUPLOAD.xlsx'  
WITH RECOMPILE  
AS  
  
  --fnasuperadmin_IBPCUPLOAD.xlsx
  --fnachecker_RestructuredAssetsUpload.xlsx
--DECLARE  
  
--@MenuID INT=24714,  
--@UserLoginId varchar(20)='fnachecker',  
--@Timekey int=49999
--,@filepath varchar(500)='RestructuredAssetsUpload.xlsx'  
  
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


IF (@MenuID=24742)	
BEGIN

	  -- IF OBJECT_ID('tempdb..StockStatementUpload') IS NOT NULL  
	  IF OBJECT_ID('StockStatementUpload') IS NOT NULL  
	  BEGIN  
	   DROP TABLE StockStatementUpload  
	   
	  END




  IF NOT (EXISTS (SELECT * FROM StockStatement_stg where filname=@FilePathUpload))

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
 	   into StockStatementUpload
	   from StockStatement_stg 
	   WHERE filname=@FilePathUpload

	  
END

  ------------------------------------------------------------------------------  
   
	--SrNo	Territory	ACID	InterestReversalAmount	filname
	
	UPDATE StockStatementUpload
	SET  
        ErrorMessage='There is no data in excel. Kindly check and upload again' 
		,ErrorinColumn='SrNo,Pool Name,Customer ID,Account ID,POS,Interest Receivable,Balances,Dates'    
		,Srnooferroneousrows=''
 FROM StockStatementUpload V  
 WHERE ISNULL(SrNo,'')=''
AND ISNULL(CIF,'')=''
--AND ISNULL(AccountID,'')=''
AND ISNULL(CustomerLimitSuffix,'')=''
AND ISNULL(StockStatementDate,'')=''






  
--WHERE ISNULL(V.SrNo,'')=''
-- ----AND ISNULL(Territory,'')=''
-- AND ISNULL(AccountID,'')=''
-- AND ISNULL(PoolID,'')=''
-- AND ISNULL(filname,'')=''

  IF EXISTS(SELECT 1 FROM StockStatementUpload WHERE ISNULL(ErrorMessage,'')<>'')
  BEGIN
  PRINT 'NO DATA'
  GOTO ERRORDATA;
  END

  /*validations on Sl. No.*/
 ------------------------------------------------------------

  Declare @DuplicateCnt int=0
   UPDATE StockStatementUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'SrNo cannot be blank . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'SrNo cannot be blank . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' ELSE   ErrorinColumn +','+SPACE(1)+'SrNo' END   
		,Srnooferroneousrows=V.SrNo
								
   --select *
   FROM StockStatementUpload V  
 WHERE ISNULL(SrNo,'')='' or ISNULL(SrNo,'0')='0'


  UPDATE StockStatementUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'SrNo cannot be greater than 16 character . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'SrNo cannot be greater than 16 character . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' ELSE   ErrorinColumn +','+SPACE(1)+'SrNo' END   
		,Srnooferroneousrows=V.SrNo
								
   --select *
   FROM StockStatementUpload V  
 WHERE Len(SrNo)>16

  UPDATE StockStatementUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid Sl. No., kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid Sl. No., kindly check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' ELSE   ErrorinColumn +','+SPACE(1)+'SrNo' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM StockStatementUpload V  
  WHERE (ISNUMERIC(SrNo)=0 AND ISNULL(SrNo,'')<>'') OR 
 ISNUMERIC(SrNo) LIKE '%^[0-9]%'

 UPDATE StockStatementUpload
	SET  
  ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Special characters not allowed, kindly remove and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Special characters not allowed, kindly remove and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' ELSE   ErrorinColumn +','+SPACE(1)+'SrNo' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM StockStatementUpload V  
   WHERE ISNULL(SrNo,'') LIKE'%[,!@#$%^&*()_-+=/]%'

   --
  SELECT @DuplicateCnt=Count(1)
FROM StockStatementUpload
GROUP BY  SrNo
HAVING COUNT(SrNo) >1;

IF (@DuplicateCnt>0)

 UPDATE		StockStatementUpload
SET			ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Duplicate Sl. No., kindly check and upload again'     
						 ELSE ErrorMessage+','+SPACE(1)+'Duplicate Sl. No., kindly check and upload again'     END
			,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' ELSE   ErrorinColumn +','+SPACE(1)+'SrNo' END   
			,Srnooferroneousrows=V.SrNo			
   FROM		StockStatementUpload V  
   Where	ISNULL(SrNo,'') In(  
								   SELECT SrNo
									FROM StockStatementUpload a
									GROUP BY  SrNo
									HAVING COUNT(SrNo) >1
							   )

							   
----------------------------------------------
 ----------------------------------------------
  
  /*validations on CIF*/


  ----------------------------------------------------

  Print 'A'
  
  UPDATE StockStatementUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'CIF cannot be blank . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'CIF cannot be blank . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'CIF' ELSE   ErrorinColumn +','+SPACE(1)+'CIF' END   
		,Srnooferroneousrows=V.SrNo
							
   
   FROM StockStatementUpload V  
 WHERE ISNULL(CIF,'')=''

 UPDATE StockStatementUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'CIF cannot be greater than 30 Character . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'CIF cannot be greater than 30 Character  . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'CIF' ELSE   ErrorinColumn +','+SPACE(1)+'CIF' END   
		,Srnooferroneousrows=V.SrNo
							
   
   FROM StockStatementUpload V  
 WHERE LEN(CIF)>30

 UPDATE StockStatementUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Special characters  are not allowed, kindly remove and try again'     
						ELSE ErrorMessage+','+SPACE(1)+'Special characters  are not allowed, kindly remove and try again'    END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'CIF' ELSE   ErrorinColumn +','+SPACE(1)+'CIF' END       
		,Srnooferroneousrows=V.SrNo

   
   FROM StockStatementUpload V  
  WHERE ISNULL(CIF,'')  like '%[-/_,!@#$%^&*()+=]%'

  UPDATE StockStatementUpload						
	SET  					
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Record for CIF  is pending for authorization in ‘Upload ID’ '+ Convert(Varchar(10),B.UploadId) +' kindly remove the record and upload again '     						
						ELSE ErrorMessage+','+SPACE(1)+'Record for CIF  is pending for authorization in ‘Upload ID’ '+ Convert(Varchar(10),B.UploadId) +' kindly remove the record and upload again '     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'CIF ' ELSE   ErrorinColumn +','+SPACE(1)+'CIF ' END       				
		,Srnooferroneousrows=V.SrNo				
     FROM StockStatementUpload V  						
   LEFT Join StockStatement_MOD B ON V.CIF=B.CIF AND V.CustomerLimitSuffix = B.CustomerLimitSuffix				
   --LEFT Join CollateralDetailUpload_Mod C ON V.AssetID=C.AssetID						
 WHERE	B.AuthorisationStatus In('NP','MP','FM','RM','1A') 					
 and (B.CIF is not NULL)		
 

--  -------------------------------For Accouhnt No

--   UPDATE StockStatementUpload
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

-- FROM StockStatementUpload V  
-- WHERE ISNULL(AccountID,'')='' 

   
--  UPDATE StockStatementUpload
--	SET  ErrorMessage=	CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid Account ID found. Please check the values and upload again'     
--						ELSE ErrorMessage+','+SPACE(1)+'Invalid Account ID found. Please check the values and upload again'     END
--		,ErrorinColumn=	CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Account ID' ELSE ErrorinColumn +','+SPACE(1)+  'Account ID' END  
--		,Srnooferroneousrows=V.SrNo
  
--		FROM StockStatementUpload V  
-- WHERE ISNULL(V.AccountID,'')<>''
-- AND V.AccountID NOT IN(SELECT CustomerACID FROM AdvAcBasicDetail
--								WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
--						 )
-- --  UPDATE StockStatementUpload
--	--SET  
-- --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'CIF is not Present In Database, kindly remove and try again'     
--	--					ELSE ErrorMessage+','+SPACE(1)+'CIF is not Present In Database, kindly remove and try again'    END
--	--	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'CIF' ELSE   ErrorinColumn +','+SPACE(1)+'CIF' END       
--	--	,Srnooferroneousrows=V.SrNo

   
-- --  FROM StockStatementUpload V  
-- -- WHERE ISNULL(CIF,'') NOT in (Select CIF From StockStatement Where EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@TimeKey  )

--  UPDATE StockStatementUpload
--	SET  
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'CIF is already pending for authorization. Please check the values and upload again.'     
--						ELSE ErrorMessage+','+SPACE(1)+'CIF is already pending for authorization. Please check the values and upload again.'     END
--		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'CIF' ELSE   ErrorinColumn +','+SPACE(1)+'CIF' END   
--		,Srnooferroneousrows=V.SrNo
--								--STUFF((SELECT ','+SRNO 
--								--FROM TwoAc A
--								--WHERE A.SrNo IN(SELECT V.SrNo  FROM TwoAc V  
--								--WHERE ISNULL(SOLID,'')='')
--								--FOR XML PATH ('')
--								--),1,1,'')
  
--   FROM StockStatementUpload V  
--    WHERE  exists (Select 1 FRom StockStatement_Mod A where A.CIF=V.CIF  And A.EffectiveToTimeKey=49999 And AuthorisationStatus In ('NP','MP','1A'))
   


  -------------------------------------------------------------------------
   ----------------------------------------------
  
  /*validations on Customer Limit Suffix*/

  UPDATE StockStatementUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Customer Limit Suffix cannot be blank . Please check the values and upload again.'     
						ELSE ErrorMessage+','+SPACE(1)+'Customer Limit Suffix cannot be blank . Please check the values and upload again.'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Customer Limit Suffix' ELSE   ErrorinColumn +','+SPACE(1)+'Customer Limit Suffix' END       
		,Srnooferroneousrows=V.SrNo

   
   FROM StockStatementUpload V  
 WHERE ISNULL(CustomerLimitSuffix,'')=''  

 UPDATE StockStatementUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Customer Limit Suffix cannot be greater than 30 Character . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Customer Limit Suffix cannot be greater than 30 Character  . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Customer Limit Suffix' ELSE   ErrorinColumn +','+SPACE(1)+'Customer Limit Suffix' END   
		,Srnooferroneousrows=V.SrNo
							
   
   FROM StockStatementUpload V  
 WHERE LEN(CustomerLimitSuffix)>30


  UPDATE StockStatementUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Special characters  are not allowed, kindly remove and try again'     
						ELSE ErrorMessage+','+SPACE(1)+'Special characters  are not allowed, kindly remove and try again'    END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Customer Limit Suffix' ELSE   ErrorinColumn +','+SPACE(1)+'Customer Limit Suffix' END       
		,Srnooferroneousrows=V.SrNo

   
   FROM StockStatementUpload V  
  WHERE ISNULL(CustomerLimitSuffix,'')  like '%[-/_,!@#$%^&*()+=]%'

  
  UPDATE StockStatementUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Customer Limit Suffix  must be alphanumeric, kindly remove and try again'     
						ELSE ErrorMessage+','+SPACE(1)+'Customer Limit Suffix  must be alphanumeric, kindly remove and try again'    END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Customer Limit Suffix' ELSE   ErrorinColumn +','+SPACE(1)+'Customer Limit Suffix' END       
		,Srnooferroneousrows=V.SrNo

   
   FROM StockStatementUpload V  
  WHERE ( Case WHEN 
  (ISNUMERIC(CustomerLimitSuffix)=0 AND ISNULL(CustomerLimitSuffix,'')<>'') OR 
 ISNUMERIC(CustomerLimitSuffix) LIKE '%^[0-9]%' THEN 1 ELSE 0 END)=0


 --    UPDATE StockStatementUpload
	--SET  
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Customer Limit Suffix is not Present In Database, kindly remove and try again'     
	--					ELSE ErrorMessage+','+SPACE(1)+'Customer Limit Suffix is not Present In Database, kindly remove and try again'    END
	--	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Customer Limit Suffix' ELSE   ErrorinColumn +','+SPACE(1)+'Customer Limit Suffix' END       
	--	,Srnooferroneousrows=V.SrNo

   
 --  FROM StockStatementUpload V  
 -- WHERE ISNULL(CustomerLimitSuffix,'') NOT in (Select CustomerLimitSuffix From StockStatement Where EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@TimeKey)
   


 ----------------------------------------------
  
  /*validations on Stock Statement Date*/

 UPDATE StockStatementUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Stock Statement Date cannot be blank . Please check the values and upload again.'     
						ELSE ErrorMessage+','+SPACE(1)+'Stock Statement Date cannot be blank . Please check the values and upload again.'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Stock Statement Date' ELSE   ErrorinColumn +','+SPACE(1)+'Stock Statement Date' END   
		,Srnooferroneousrows=V.SrNo
		--select *
  FROM StockStatementUpload V 
 WHERE ISNULL(StockStatementDate,'')=''

 
	SET DATEFORMAT DMY

	 UPDATE StockStatementUpload
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Stock Statement Date must be in dd/mm/yyyy format. Kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Stock Statement Date must be in dd/mm/yyyy format. Kindly check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Stock Statement Date' ELSE   ErrorinColumn +','+SPACE(1)+'Stock Statement Date' END       
		,Srnooferroneousrows=V.SrNo

   --select *
  FROM StockStatementUpload V  
 WHERE   ISDATE(StockStatementDate)=0 AND ISNULL(StockStatementDate,'')<>''
 
 -- UPDATE StockStatementUpload
	--SET  
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Stock Statement Date must be greater than system processing date. Kindly check and upload again'     
	--					ELSE ErrorMessage+','+SPACE(1)+'Stock Statement Date must be greater than system processing date. Kindly check and upload again'     END
	--	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Stock Statement Date' ELSE   ErrorinColumn +','+SPACE(1)+'Stock Statement Date' END       
	--	,Srnooferroneousrows=V.SrNo

 --  --select *
 -- FROM StockStatementUpload V  
 --WHERE  convert(date,ISNULL(StockStatementDate,'1900-01-01'),103) < (select cast(ExtDate as date) from SYSDATAMATRIX where CurrentStatus = 'C')

 -------------------------------------------------------

 /*VALIDATIONS ON AccountID */

--  UPDATE StockStatementUpload
--	SET  
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Account ID cannot be blank.  Please check the values and upload again'     
--					ELSE ErrorMessage+','+SPACE(1)+'Account ID cannot be blank.  Please check the values and upload again'     END
--		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Account ID' ELSE ErrorinColumn +','+SPACE(1)+  'Account ID' END  
--		,Srnooferroneousrows=V.SRNO
  

--FROM StockStatementUpload V  
-- WHERE ISNULL(AccountID,'')='' 

--    Declare @Count Int,@I Int,@Entity_Key Int
--   Declare @CustomerAcID Varchar(100)=''
--   Declare @CustomerAcIDFound Int=0
--     Declare @CustomerName Varchar(250)=''
--	  Declare @CustName Varchar(250)=''
--	  Declare @CustomerNameFound Int=0

--IF OBJECT_ID('TempDB..#tmp') IS NOT NULL DROP TABLE #tmp; 
  
--  Select  ROW_NUMBER() OVER(ORDER BY  CONVERT(INT,Entity_Key) ) RecentRownumber,Entity_Key,AccountID into #tmp from StockStatementUpload
                  
-- Select @Count=Count(*) from #tmp
  
--   SET @I=1
--   SET @Entity_Key=0
--     SET @CustomerAcID =0
--   SET @CustomerNameFound =0

--   SET @CustomerAcID=''
--     While(@I<=@Count)
--               BEGIN 
--			     Select @CustomerAcID =AccountID,@Entity_Key=Entity_Key  from #tmp where RecentRownumber=@I 
--							order By Entity_Key

--					  Select      @CustomerAcIDFound=Count(1)
--				from Curdat.AdvAcBasicDetail  A Where CustomerAcID=@CustomerAcID

--				IF @CustomerAcIDFound =0
--				    Begin
--				 Update StockStatementUpload
--										   SET   ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN ' AccountID is invalid. Kindly check the entered CustomerAcID'     
--											 ELSE ErrorMessage+','+SPACE(1)+' AccountID is invalid. Kindly check the entered CustomerAcID'      END
--											 ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'AccountID' ELSE   ErrorinColumn +','+SPACE(1)+'AccountID' END   
--										   Where Entity_Key=@Entity_Key
--					END

				
--					  SET @I=@I+1
--					  SET @CustomerAcID=''
								
								
--			   END

------------------------------------------------------------

  
 ---------------------------------


Print '123'
 goto valid

  END
	
   ErrorData:  
   print 'no'  

		SELECT *,'Data'TableName
		FROM dbo.MasterUploadData WHERE FileNames=@filepath 
		return

   valid:
		IF NOT EXISTS(Select 1 from  StockStatement_stg WHERE filname=@FilePathUpload)
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
			FROM StockStatementUpload 

			print 'Row Effected'

			print @@ROWCOUNT
			
		--	----SELECT * FROM BuyoutUploadDetail 

		--	--ORDER BY ErrorMessage,BuyoutUploadDetail.ErrorinColumn DESC
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

		 IF EXISTS(SELECT 1 FROM StockStatement_stg WHERE filname=@FilePathUpload)
		 BEGIN
		 Print 'Anuj1111'
		 PRINT '@FilePathUpload'
		 PRINT @FilePathUpload
		 DELETE FROM StockStatement_stg
		 WHERE filname=@FilePathUpload



		 PRINT '2';

		 PRINT 'ROWS DELETED FROM DBO.StockStatement_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
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

	----SELECT * FROM BuyoutUploadDetail

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

--select * from dbo.Error_Log order by errordatetime desc
GO