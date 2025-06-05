SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[ValidateExcel_DataUpload_RPModuleLenderUpload]
@MenuID INT=10,  
@UserLoginId  VARCHAR(20)='fnachecker',  

@Timekey INT=49999
,@filepath VARCHAR(MAX) ='IBPCUPLOAD.xlsx'  
WITH RECOMPILE  
AS  
  
  --fnasuperadmin_IBPCUPLOAD.xlsx

--DECLARE  
  
--@MenuID INT=24734,  
--@UserLoginId varchar(20)='lvl1admin',  
--@Timekey int=25999
--,@filepath varchar(500)='RPLendersUpload (1).xlsx'  
  
BEGIN

BEGIN TRY  
--BEGIN TRAN  
  
--Declare @TimeKey int  
    --Update UploadStatus Set ValidationOfData='N' where FileNames=@filepath  
     
	 SET DATEFORMAT DMY

 --Select @Timekey=Max(Timekey) from dbo.SysProcessingCycle  
 -- where  ProcessType='Quarterly' ----and PreMOC_CycleFrozenDate IS NULL
 
 Select   @Timekey=Max(Timekey) from sysDayMatrix where Cast(date as Date)=cast(getdate() as Date)

  --Select   Max(Timekey) from sysDayMatrix where Cast(date as Date)=cast(getdate() as Date)

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


IF (@MenuID=24734)	
BEGIN


	  -- IF OBJECT_ID('tempdb..UploadRPModuleLender') IS NOT NULL  
	  IF OBJECT_ID('UploadRPModuleLender') IS NOT NULL  
	  BEGIN  
	   DROP TABLE UploadRPModuleLender  
	
	  END
	  
  IF NOT (EXISTS (SELECT * FROM RPModuleLender_stg where filname=@FilePathUpload))

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
 	   into UploadRPModuleLender 
	   from RPModuleLender_stg 
	   WHERE filname=@FilePathUpload

	  

	  
END


  ------------------------------------------------------------------------------  
   
	--SrNo	Territory	ACID	InterestReversalAmount	sheetname
	select * from UploadRPModuleLender
	UPDATE UploadRPModuleLender
	SET  
        ErrorMessage='There is no data in excel. Kindly check and upload again' 
		,ErrorinColumn='CollateralID,Tagging Level,DistributionLevel,CollateralType,CollateralOwnerType,Interest CollateralOwnershipType,Balances,Dates'    
		,Srnooferroneousrows=''
 FROM UploadRPModuleLender V  
 WHERE ISNULL(CustomerID,'')=''
AND ISNULL(LenderName,'')=''
AND ISNULL(InDefaultDate,'')=''
AND ISNULL(OutofDefaultDate,'')=''
  
--WHERE ISNULL(V.SrNo,'')=''
-- ----AND ISNULL(Territory,'')=''
-- AND ISNULL(AccountID,'')=''
-- AND ISNULL(PoolID,'')=''
-- AND ISNULL(sheetname,'')=''

  --IF EXISTS(SELECT 1 FROM UploadRPModuleLender WHERE ISNULL(ErrorMessage,'')<>'')
  --BEGIN
  --PRINT 'NO DATA'
  --GOTO ERRORDATA;
  --END

      /*validations on Sl. No.*/
 ------------------------------------------------------------
 PRINT 'Satart11'
  Declare @DuplicateCnt int=0
   UPDATE UploadRPModuleLender
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'SrNo cannot be blank . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'SrNo cannot be blank . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' ELSE   ErrorinColumn +','+SPACE(1)+'SrNo' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadRPModuleLender V  
 WHERE ISNULL(SrNo,'')='' or ISNULL(SrNo,'0')='0'


  UPDATE UploadRPModuleLender
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'SrNo cannot be greater than 16 character . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'SrNo cannot be greater than 16 character . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' ELSE   ErrorinColumn +','+SPACE(1)+'SrNo' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadRPModuleLender V  
 WHERE Len(SrNo)>16

  UPDATE UploadRPModuleLender
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid Sl. No., kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid Sl. No., kindly check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' ELSE   ErrorinColumn +','+SPACE(1)+'SrNo' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadRPModuleLender V  
  WHERE (ISNUMERIC(SrNo)=0 AND ISNULL(SrNo,'')<>'') OR 
 ISNUMERIC(SrNo) LIKE '%^[0-9]%'

 UPDATE UploadRPModuleLender
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Special characters not allowed, kindly remove and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Special characters not allowed, kindly remove and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' ELSE   ErrorinColumn +','+SPACE(1)+'SrNo' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadRPModuleLender V  
   WHERE ISNULL(SrNo,'') LIKE'%[,!@#$%^&*()_-+=/]%'

   --
  SELECT @DuplicateCnt=Count(1)
FROM UploadRPModuleLender
GROUP BY  SrNo
HAVING COUNT(SrNo) >1;

IF (@DuplicateCnt>0)

 UPDATE UploadRPModuleLender
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Duplicate Sl. No., kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Duplicate Sl. No., kindly check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' ELSE   ErrorinColumn +','+SPACE(1)+'SrNo' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadRPModuleLender V  
   Where ISNULL(SrNo,'') In(  
   SELECT SrNo
	FROM UploadRPModuleLender
	GROUP BY  SrNo
	HAVING COUNT(SrNo) >1

)

  
  /*validations on Customer ID*/
   Declare @Count Int,@I Int,@Entity_Key Int
  Declare @TaggingLevel Varchar(100)=''
  Declare @CustomerID Varchar(100)=''
  Declare @AccountId Varchar(100)=''
 Declare @RelatedUCICCustomerIDAccountID Varchar(100)=''
  Declare @UCIC Varchar(100)=''


  UPDATE UploadRPModuleLender
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Customer ID cannot be blank . Please check the values and upload again.'     
						ELSE ErrorMessage+','+SPACE(1)+' Customer ID cannot be blank . Please check the values and upload again.n'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Customer ID' ELSE   ErrorinColumn +','+SPACE(1)+'Customer IDl' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadRPModuleLender V  
 WHERE ISNULL(CustomerID,'')=''




   UPDATE UploadRPModuleLender
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'You can not Upload Lender where RP Details are not found . Please check the values and upload again.'     
						ELSE ErrorMessage+','+SPACE(1)+' You can not Upload Lender where RP Details are not found . Please check the values and upload again.'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Customer ID' ELSE   ErrorinColumn +','+SPACE(1)+'Customer IDl' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadRPModuleLender V  
  

 WHERE ISNULL(V.CustomerID,'') NOT IN(
 Select V.CustomerID FROM UploadRPModuleLender V  
   INNER JOIN RP_Portfolio_Details B ON V.CustomerID =B.CustomerID 

 WHERE ISNULL(B.IsActive,'N') ='Y' 
 )

  
 IF OBJECT_ID('TempDB..#tmp') IS NOT NULL DROP TABLE #tmp; 
  
  Select  ROW_NUMBER() OVER(ORDER BY  CONVERT(INT,SrNo) ) RecentRownumber,SrNo,CustomerID 
  into #tmp from UploadRPModuleLender

  Select @Count=Count(*) from #tmp
  
SET @I=1
  SET @Entity_Key=0
  SET @CustomerId=''
   SET @UCIC=''
   SET @AccountId=''
 While(@I<=@Count)
					BEGIN
					    Select @RelatedUCICCustomerIDAccountID =CustomerID,@Entity_Key=SrNo  from #tmp where RecentRownumber=@I 
							order By SrNo

							

							  If @TaggingLevel='Customer ID'
							  BEGIN
							    Print 'Sachin'
								 

							       Select @CustomerId=CustomerId from Curdat.CustomerBasicDetail 
								   where CustomerId=@RelatedUCICCustomerIDAccountID
								    

								  IF @CustomerId =''
								       Begin
										  
								    
								  
										   Update UploadRPModuleLender
										   SET   ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Customer ID is invalid. Kindly check the entered customer id'     
											 ELSE ErrorMessage+','+SPACE(1)+'Customer ID is invalid. Kindly check the entered customer id'      END
                                   ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Customer ID' ELSE   ErrorinColumn +','+SPACE(1)+'Customer ID' END 
										   Where SrNo=@Entity_Key
									END
							  END


--							  END

							    SET @I=@I+1
								SET @CustomerId=''
								SET @UCIC=''
								SET @AccountId=''
					END


----------------------------------------------------------------
/*validations on Lender Name And Customer ID*/

Drop Table If Exists #tmp11



Select Distinct V.CustomerID,C.BankName as LenderName ,B.InDefaultDate,B.OutOfDefaultDate Into #tmp11 FROM UploadRPModuleLender V  
   INNER JOIN RP_Lender_Details B ON V.CustomerID =B.CustomerID  
   INNER JOIN DimBankRP C ON B.ReportingLenderAlt_Key=C.BankRPAlt_Key

   --Select '#tmp11',* from #tmp11


   
  

  UPDATE UploadRPModuleLender
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'This CustomerId and LenderName are alreary present in Lender Table . Please check the values and upload again.'     
						ELSE ErrorMessage+','+SPACE(1)+' This CustomerId and LenderName are alreary present in Lender Table . Please check the values and upload again.'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'InDefaultDate/OutOfDefaultDate' ELSE   ErrorinColumn +','+SPACE(1)+'InDefaultDate/OutOfDefaultDate' END   
		,Srnooferroneousrows=V.SrNo

		
   FROM UploadRPModuleLender V 
   INNER JOIN #tmp11 B ON V.CustomerID =B.CustomerID AND V.LenderName=B.LenderName 
  

 WHERE B.InDefaultDate IS  NULL AND B.OutOfDefaultDate IS NOT NULL



 UPDATE UploadRPModuleLender
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'You can not provide InDefaultDate and OutOfDefaultDate simaltanously. Please check the values and upload again.'     
						ELSE ErrorMessage+','+SPACE(1)+ 'You can not provide InDefaultDate and OutOfDefaultDate simaltanously. Please check the values and upload again.'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'InDefaultDate/OutOfDefaultDate' ELSE   ErrorinColumn +','+SPACE(1)+'InDefaultDate/OutOfDefaultDate' END   
		,Srnooferroneousrows=V.SrNo

   FROM UploadRPModuleLender V 

 WHERE ISNULL(V.InDefaultDate,'')<>'' AND ISNULL(V.OutOfDefaultDate,'')<>''

 UPDATE UploadRPModuleLender
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'You need to provide Indefault date . Please check the values and upload again.'     
						ELSE ErrorMessage+','+SPACE(1)+ 'You need to provide Indefault date. Please check the values and upload again.'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'InDefaultDate/OutOfDefaultDate' ELSE   ErrorinColumn +','+SPACE(1)+'InDefaultDate/OutOfDefaultDate' END   
		,Srnooferroneousrows=V.SrNo

   FROM UploadRPModuleLender V 


 WHERE ISNULL(V.InDefaultDate,'')='' AND ISNULL(V.OutOfDefaultDate,'')=''

    UPDATE UploadRPModuleLender
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'You can not Upload Lender where CustomerID and Lender is already present with IndefaultDate. Please check the values and upload again.'     
						ELSE ErrorMessage+','+SPACE(1)+' You can not Upload Lender where CustomerID and Lender is already present with IndefaultDate.Please check the values and upload again.'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'InDefaultDate/OutOfDefaultDate' ELSE   ErrorinColumn +','+SPACE(1)+'InDefaultDate/OutOfDefaultDate' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadRPModuleLender V  
  

 WHERE ISNULL(V.CustomerID,'')  IN(
 Select Distinct V.CustomerID FROM UploadRPModuleLender V  
   INNER JOIN RPModuleLender_Mod B ON V.CustomerID =B.CustomerID And V.LenderName =B.LenderName
   	WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey) 
	And B.AuthorisationStatus in('NP','MP','FM','1A')
 )


    UPDATE UploadRPModuleLender
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'You can not Upload Lender where CustomerID and Lender is Not with IndefaultDate. Please check the values and upload again.'     
						ELSE ErrorMessage+','+SPACE(1)+' You can not Upload Lender where CustomerID and Lender Not present with IndefaultDate.Please check the values and upload again.'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'InDefaultDate/OutOfDefaultDate' ELSE   ErrorinColumn +','+SPACE(1)+'InDefaultDate/OutOfDefaultDate' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadRPModuleLender V  
  

 WHERE ISNULL(V.CustomerID,'') NOT IN(
 Select V.CustomerID FROM UploadRPModuleLender V  
   INNER JOIN RPModuleLender_Mod B ON V.CustomerID =B.CustomerID And V.LenderName =B.LenderName
   	WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
	And AuthorisationStatus in('NP','MP','FM','A','1A')
	) AND ISNULL(V.InDefaultDate,'')='' 

	-------------------------new add IndefaultDate is greater than Outof default date
	DROP TABLE IF Exists #MaxIndefaultdate 


	 
	select Max(cast(InDefaultDate as date)) InDefaultDate,CustomerID into #MaxIndefaultdate from RP_Lender_Details 
	Group By CustomerID
	                         --where CustomerID= @CustomerID   
							 --'22552793'

	--Select * from #MaxIndefaultdate

	--Select * from UploadRPModuleLender
							 




    UPDATE UploadRPModuleLender
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'IndefaultDate is greater than Outof default date. Please check the values and upload again.'     
						ELSE ErrorMessage+','+SPACE(1)+' IndefaultDate is greater than Outof default date.Please check the values and upload again.'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'OutOfDefaultDate' ELSE   ErrorinColumn +','+SPACE(1)+'OutOfDefaultDate' END   
		,Srnooferroneousrows=V.SrNo


   FROM UploadRPModuleLender V 
   INNER JOIN  #MaxIndefaultdate B ON V.CustomerID=B.CustomerID
   WHERE convert(varchar(10),ISNULL(cast(V.OutOfDefaultDate as date),''),121) <= cast(B.InDefaultDate as date) 
                                                                     
   	--AND ISNULL(V.InDefaultDate,'')<>'' 																   
   
  ---- select * from UploadRPModuleLender
  ------ update UploadRPModuleLender set OutOfDefaultDate='11/08/2021'
  ----  where CustomerID='22552793'

 --------------------------------------------------------
----------------------------------------------------------------
/*validations on Lender Name*/

UPDATE UploadRPModuleLender
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Lender Name cannot be blank . Please check the values and upload again.'     
						ELSE ErrorMessage+','+SPACE(1)+' Lender Name cannot be blank . Please check the values and upload again.n'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Lender Name' ELSE   ErrorinColumn +','+SPACE(1)+'Lender Name' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadRPModuleLender V  
 WHERE ISNULL(LenderName,'')=''


 Declare @LenderNameCnt int=0,@PoolType int=0
 IF OBJECT_ID('LenderNameData') IS NOT NULL  
	  BEGIN  
	   DROP TABLE LenderNameData  
	
	  END

	  
 SELECT * into LenderNameData  FROM(
 SELECT ROW_NUMBER() OVER(PARTITION BY LenderName  ORDER BY  LenderName ) 
 ROW ,LenderName FROM UploadRPModuleLender
 )X
 WHERE ROW=1

  SELECT  @LenderNameCnt=COUNT(*) FROM LenderNameData A
 Left JOIN DimBankRP B
 ON  A.LenderName=B.BankName
 Where B.BankName IS NULL

 IF @LenderNameCnt>0

BEGIN
 
   UPDATE UploadRPModuleLender
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid value in column ‘Lender Name’. Kindly enter the values 
		as mentioned in the ‘Lender Name’ master and upload again. Click on ‘Download Master value’ to download the 
		valid values for the column'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid value in column ‘Lender Name’. Kindly enter the values as mentioned in the ‘Lender Name’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'     END  
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Lender Name' ELSE   ErrorinColumn +','+SPACE(1)+'Lender Name' END     
		,Srnooferroneousrows=V.SrNo
  

 FROM UploadRPModuleLender V  
 WHERE ISNULL(LenderName,'')<>''
 AND  V.LenderName IN(
				SELECT  A.LenderName FROM LenderNameData A
				 Left JOIN DimBankRP B
				 ON  A.LenderName=B.BankName
				 Where B.BankName IS NULL
				 )
 END 
 ------------------------------------------------------------------------
 /*validations on InDefault Date*/
 
--UPDATE UploadRPModuleLender
--	SET  
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'InDefaultDate cannot be blank . Please check the values and upload again.'     
--						ELSE ErrorMessage+','+SPACE(1)+' InDefaultDate cannot be blank . Please check the values and upload again.n'     END
--		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'InDefaultDate' ELSE   ErrorinColumn +','+SPACE(1)+'InDefaultDate' END   
--		,Srnooferroneousrows=V.SrNo
								
   
-- FROM UploadRPModuleLender V  
-- WHERE ISNULL(InDefaultDate,'')=''


 --   SET DateFormat DMY
 --  UPDATE UploadRPModuleLender
	--SET  
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'InDefaultDate  is not Valid Date . Please check the values and upload again'     
	--					ELSE ErrorMessage+','+SPACE(1)+'InDefaultDate is not Valid Date . Please check the values and upload again'     END
	--	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'InDefaultDate' ELSE   ErrorinColumn +','+SPACE(1)+'InDefaultDate' END   
	--	,Srnooferroneousrows=V.SrNo
								
   
 --  FROM UploadRPModuleLender V  
 --  WHERE ISDATE(InDefaultDate)=0 AND ISNULL(InDefaultDate,'')=''
-------------------------------------------------------------------------------
 /*validations on Out of Default Date*/

 --UPDATE UploadRPModuleLender
	--SET  
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'OutDefaultDate cannot be blank . Please check the values and upload again.'     
	--					ELSE ErrorMessage+','+SPACE(1)+' OutDefaultDate cannot be blank . Please check the values and upload again.n'     END
	--	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'OutDefaultDate' ELSE   ErrorinColumn +','+SPACE(1)+'OutDefaultDate' END   
	--	,Srnooferroneousrows=V.SrNo
								
   
 --  FROM UploadRPModuleLender V  
 --WHERE ISNULL(OutofDefaultDate,'')=''


 --   SET DateFormat DMY
 --  UPDATE UploadRPModuleLender
	--SET  
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'OutDefaultDate  is not Valid Date . Please check the values and upload again'     
	--					ELSE ErrorMessage+','+SPACE(1)+'OutDefaultDate is not Valid Date . Please check the values and upload again'     END
	--	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'OutDefaultDate' ELSE   ErrorinColumn +','+SPACE(1)+'OutDefaultDate' END   
	--	,Srnooferroneousrows=V.SrNo
								
   
 --  FROM UploadRPModuleLender V  
 --  WHERE ISDATE(OutofDefaultDate)=0 AND ISNULL(OutofDefaultDate,'')=''
------------------------------------------------------------------------
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
		IF NOT EXISTS(Select 1 from  RPModuleLender_stg WHERE filname=@FilePathUpload)
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
			FROM UploadRPModuleLender 

			print 'Row Effected'

			print @@ROWCOUNT
			
		--	----SELECT * FROM UploadRPModuleLender 

		--	--ORDER BY ErrorMessage,UploadRPModuleLender.ErrorinColumn DESC
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

		 IF EXISTS(SELECT 1 FROM RPModuleLender_stg WHERE filname=@FilePathUpload)
		 BEGIN
		 Print '1'
		 DELETE FROM RPModuleLender_stg
		 WHERE filname=@FilePathUpload
		 
		 PRINT '2';

		 PRINT 'ROWS DELETED FROM DBO.RPModuleLender_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
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

	----SELECT * FROM UploadRPModuleLender

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