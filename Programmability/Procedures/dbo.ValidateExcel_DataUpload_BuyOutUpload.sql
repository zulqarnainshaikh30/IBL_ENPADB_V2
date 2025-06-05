SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[ValidateExcel_DataUpload_BuyOutUpload] 
@MenuID INT=1466,  
@UserLoginId  VARCHAR(20)='LVL2ADMIN',  
@Timekey INT=49999
,@filepath VARCHAR(MAX) ='BuyoutUpload (7).xlsx'  
WITH RECOMPILE  
AS  
  


--DECLARE  
  
--@MenuID INT=1466,  
--@UserLoginId varchar(20)=N'2ndlvlchecker',  
--@Timekey int=N'25999'
--,@filepath varchar(500)=N'BuyoutUpload (3).xlsx'  
  
BEGIN

BEGIN TRY  
--BEGIN TRAN  
  
--Declare @TimeKey int  
    --Update UploadStatus Set ValidationOfData='N' where FileNames=@filepath  
     
	 SET DATEFORMAT DMY

 --Select @Timekey=Max(Timekey) from dbo.SysProcessingCycle  
 -- where  ProcessType='Quarterly' ----and PreMOC_CycleFrozenDate IS NULL
 
 Set  @Timekey=(select CAST(B.timekey as int)from SysDataMatrix A
                    Inner Join SysDayMatrix B ON A.TimeKey=B.TimeKey
                       where A.CurrentStatus='C')

--Select   @Timekey=Max(Timekey) from sysDayMatrix where Cast(date as Date)=cast(getdate() as Date)

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


IF (@MenuID=1466)	
BEGIN


	  -- IF OBJECT_ID('tempdb..#UploadBuyout') IS NOT NULL  
	  --BEGIN  
	  -- DROP TABLE #UploadBuyout  
	
	  --END
	  IF OBJECT_ID('UploadBuyout') IS NOT NULL  
	  BEGIN
	    
		DROP TABLE  UploadBuyout
	
	  END
	  
  IF NOT (EXISTS (SELECT * FROM BuyoutDetails_stg where filname=@FilePathUpload))

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
 	   into UploadBuyout 
	   from BuyoutDetails_stg 
	   WHERE filname=@FilePathUpload
	   
	  
END
  ------------------------------------------------------------------------------  
  --select * from UploadBuyout
    ----SELECT * FROM UploadBuyout
	--SrNo	Territory	ACID	InterestReversalAmount	filname
	UPDATE UploadBuyout
	SET  
        ErrorMessage='There is no data in excel. Kindly check and upload again' 
		,ErrorinColumn=
		    'SlNo
		    ,CIFId
			,UTKSAcNo
			,BuyoutPartyLoanNo
			,PartnerDPD 
			,PartnerDPDAsOnDate
			,PartnerAssetClass
			,PartnerNPADate'
			   
		,Srnooferroneousrows=''
 FROM UploadBuyout V  
 WHERE ISNULL(SlNo,'')=''
AND ISNULL(CIFId,'')=''
AND ISNULL(UTKSAcNo,'')=''
AND ISNULL(BuyoutPartyLoanNo,'')=''
AND ISNULL(PartnerDPD,'')=''
AND ISNULL(PartnerDPDAsOnDate,'')=''
AND ISNULL(PartnerAssetClass,'')=''
AND ISNULL(PartnerNPADate,'')=''
--AND ISNULL(Action,'')=''


 ----------Validation on PartnerNPADate -----------Updated by chetan 

  UPDATE UploadBuyout
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Please Enter Valid Date Like DD/MM/YYYY format. Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Please Enter Valid Date Like DD/MM/YYYY format. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'PartnerNPADate' ELSE ErrorinColumn +','+SPACE(1)+  'PartnerNPADate' END  
		,Srnooferroneousrows=V.SlNo


 FROM UploadBuyout V  
 WHERE isdate(PartnerNPADate)=0 or isnull(PartnerNPADate,'')='' 

 
  UPDATE UploadBuyout
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'It is not a date or it should not be blank. Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'It is not a date or it should not be blank. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'PartnerNPADate' ELSE ErrorinColumn +','+SPACE(1)+  'PartnerNPADate' END  
		,Srnooferroneousrows=V.SlNo


 FROM UploadBuyout V  
 WHERE isdate(PartnerNPADate)=1 and PartnerNPADate  not LIKE '[0-3][0-9]/[0-1][0-9]/[1-2][0-9][0-9][0-9]%'  
 
 

  --------Validation on PartnerNPADate -----------Updated by Nikhil 



 -- UPDATE UploadBuyout
	--SET  
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'It is not a date or it should not be blank. Please check the values and upload again'     
	--					ELSE ErrorMessage+','+SPACE(1)+ 'It is not a date or it should not be blank. Please check the values and upload again'     END
	--	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'PartnerNPADate' ELSE ErrorinColumn +','+SPACE(1)+  'PartnerNPADate' END  
	--	,Srnooferroneousrows=V.SlNo


 --FROM UploadBuyout V  
 --WHERE isdate(PartnerNPADate)=1 and PartnerNPADate  not LIKE '[0-3][0-9]/[0]-1][0-2/[1-2][0-9][0-9][0-9]%'  


  ----------Validation on PartnerDPDAsOnDate -----------Updated by chetan 

 --   UPDATE UploadBuyout
	--SET  
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Please Enter Valid Date Like DD/MM/YYYY format. Please check the values and upload again'     
	--					ELSE ErrorMessage+','+SPACE(1)+ 'Please Enter Valid Date Like DD/MM/YYYY format. Please check the values and upload again'     END
	--	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'PartnerDPDAsOnDate' ELSE ErrorinColumn +','+SPACE(1)+  'PartnerDPDAsOnDate' END  
	--	,Srnooferroneousrows=V.SlNo


 --FROM UploadBuyout V  
 --WHERE isdate(PartnerDPDAsOnDate)=0 or isnull(PartnerNPADate,'')='' 

 
  ----------Validation on PartnerDPDAsOnDate -----------Updated by NIKHIL 

     UPDATE UploadBuyout
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Please Enter Valid Date Like DD/MM/YYYY format. Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Please Enter Valid Date Like DD/MM/YYYY format. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'PartnerDPDAsOnDate' ELSE ErrorinColumn +','+SPACE(1)+  'PartnerDPDAsOnDate' END  
		,Srnooferroneousrows=V.SlNo


 FROM UploadBuyout V  
 WHERE isdate(PartnerDPDAsOnDate)=0 or isnull(PartnerDPDAsOnDate,'')='' 

 

 -- UPDATE UploadBuyout
	--SET  
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'It is not a date or it should not be blank. Please check the values and upload again'     
	--					ELSE ErrorMessage+','+SPACE(1)+ 'It is not a date or it should not be blank. Please check the values and upload again'     END
	--	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'PartnerDPDAsOnDate' ELSE ErrorinColumn +','+SPACE(1)+  'PartnerDPDAsOnDate' END  
	--	,Srnooferroneousrows=V.SlNo


 --FROM UploadBuyout V  
 --WHERE isdate(PartnerDPDAsOnDate)=1 and PartnerNPADate not LIKE '[0-3][0-9]/[0-1][0-2]/[1-2][0-9][0-9][0-9]%'

  UPDATE UploadBuyout
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'It is not a date or it should not be blank. Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'It is not a date or it should not be blank. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'PartnerDPDAsOnDate' ELSE ErrorinColumn +','+SPACE(1)+  'PartnerDPDAsOnDate' END  
		,Srnooferroneousrows=V.SlNo


 FROM UploadBuyout V  
 WHERE isdate(PartnerDPDAsOnDate)=1 and PartnerDPDAsOnDate not LIKE '[0-3][0-9]/[0-1][0-2]/[1-2][0-9][0-9][0-9]%'


 ---PartnerDPDAsOnDate added validation by Nikhil



  IF EXISTS(SELECT 1 FROM UploadBuyout WHERE ISNULL(ErrorMessage,'')<>'')
  BEGIN
  PRINT 'NO DATA'
  GOTO valid;---ERRORDATA; -- Previous
  END



-----validations on Srno
	print 'Validation Error MSG'
	 UPDATE UploadBuyout
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 	'SlNo is mandatory. Kindly check and upload again' 
		                  ELSE ErrorMessage+','+SPACE(1)+ 'SlNo is mandatory. Kindly check and upload again'
		  END
		,ErrorinColumn='SlNo'    
		,Srnooferroneousrows=''
	FROM UploadBuyout V  
	WHERE ISNULL(v.SlNo,'')=''  
	 Print '1'

 UPDATE UploadBuyout
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid SlNo, kindly check and upload again'     
								  ELSE ErrorMessage+','+SPACE(1)+ 'Invalid SlNo, kindly check and upload again'  END
		,ErrorinColumn='SlNo'    
		,Srnooferroneousrows=SlNo
		
 FROM UploadBuyout V  
 WHERE ISNULL(v.SlNo,'')='0'  OR ISNUMERIC(v.SlNo)=0
  Print '2'
  
  IF OBJECT_ID('TEMPDB..#R') IS NOT NULL
  DROP TABLE #R

  SELECT * INTO #R FROM(
  SELECT *,ROW_NUMBER() OVER(PARTITION BY SlNo ORDER BY SlNo)RO
   FROM UploadBuyout
   )A
   WHERE RO>1

 PRINT 'DUB'  


  UPDATE UploadBuyout
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Duplicate SlNo, kindly check and upload again' 
					ELSE ErrorMessage+','+SPACE(1)+     'Duplicate SlNo, kindly check and upload again' END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SlNo' ELSE ErrorinColumn +','+SPACE(1)+  'SlNo' END
		,Srnooferroneousrows=SlNo
		
		
 FROM UploadBuyout V  
	WHERE  V.SlNo IN(SELECT SlNo FROM #R )
	Print '3'
/*validations on CIFId*/
  
  UPDATE UploadBuyout
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'CIFId cannot be blank . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'CIFId cannot be blank . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'CIFId' ELSE   ErrorinColumn +','+SPACE(1)+'CIFId' END   
		,Srnooferroneousrows=V.SlNo
							
   
   FROM UploadBuyout V  
 WHERE ISNULL(CIFId,'')=''


  


 
  UPDATE UploadBuyout
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid CIFId  Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid CIFId Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'CIFId' ELSE   ErrorinColumn +','+SPACE(1)+'CIFId' END       
		,Srnooferroneousrows=V.SlNo
	--	STUFF((SELECT ','+SlNo 
	--							FROM UploadBuyout A
	--							WHERE A.SlNo IN(SELECT V.SlNo FROM UploadBuyout V  
 --WHERE ISNULL(SOLID,'')<>''
 --AND  LEN(SOLID)>10)
	--							FOR XML PATH ('')
	--							),1,1,'')
   
   FROM UploadBuyout V  
 WHERE ISNULL(CIFId,'')<>''
 AND LEN(CIFId)>20

  UPDATE UploadBuyout
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid CIFId  Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid CIFId Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'CIFId' ELSE ErrorinColumn +','+SPACE(1)+  'CIFId' END  
		,Srnooferroneousrows=V.SlNo
--								----STUFF((SELECT ','+SRNO 
--								----FROM UploadBuyout A
--								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadBuyout V
--								---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
--								----)
--								----FOR XML PATH ('')
--								----),1,1,'')   

 FROM UploadBuyout V  
 WHERE ISNULL(CIFId,'') LIKE'%[,!@#$%^&*()+=]%'

 ------Alpha numeric CIFID-------Updated by Chetan 

   UPDATE UploadBuyout
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid CIFId  Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid CIFId Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'CIFId' ELSE ErrorinColumn +','+SPACE(1)+  'CIFId' END  
		,Srnooferroneousrows=V.SlNo

 FROM UploadBuyout V  
 WHERE ISNULL(CIFId,'')  LIKE'%[a-zA-Z]%'
  
 ----------------------------------------------
 /*validations on UTKSAcNo*/
  
  UPDATE UploadBuyout
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'UTKSAcNo cannot be blank . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'UTKSAcNo cannot be blank . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'UTKSAcNo' ELSE   ErrorinColumn +','+SPACE(1)+'UTKSAcNo' END   
		,Srnooferroneousrows=V.SlNo
								--STUFF((SELECT ','+SlNo 
								--FROM UploadBuyout A
								--WHERE A.SlNo IN(SELECT V.SlNo  FROM UploadBuyout V  
								--WHERE ISNULL(SOLID,'')='')
								--FOR XML PATH ('')
								--),1,1,'')
   
   FROM UploadBuyout V  
 WHERE ISNULL(UTKSAcNo,'')=''




  


 
  UPDATE UploadBuyout
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid UTKSAcNo.  Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid UTKSAcNo.  Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'UTKSAcNo' ELSE   ErrorinColumn +','+SPACE(1)+'UTKSAcNo' END       
		,Srnooferroneousrows=V.SlNo
	--	STUFF((SELECT ','+SlNo 
	--							FROM UploadBuyout A
	--							WHERE A.SlNo IN(SELECT V.SlNo FROM UploadBuyout V  
 --WHERE ISNULL(SOLID,'')<>''
 --AND  LEN(SOLID)>10)
	--							FOR XML PATH ('')
	--							),1,1,'')
   
   FROM UploadBuyout V  
 WHERE ISNULL(UTKSAcNo,'')<>''
 AND LEN(UTKSAcNo)>20

  UPDATE UploadBuyout
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid UTKSAcNo.  Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid UTKSAcNo.  Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'UTKSAcNo' ELSE ErrorinColumn +','+SPACE(1)+  'UTKSAcNo' END  
		,Srnooferroneousrows=V.SlNo
--								----STUFF((SELECT ','+SRNO 
--								----FROM UploadBuyout A
--								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadBuyout V
--								---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
--								----)
--								----FOR XML PATH ('')
--								----),1,1,'')   

 FROM UploadBuyout V  
 WHERE ISNULL(UTKSAcNo,'') LIKE'%[,!@#$%^&*()+=]%'

 --Alpha Numeric Value ---Updated by  chetan

  UPDATE UploadBuyout
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid UTKSAcNo.  Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid UTKSAcNo.  Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'UTKSAcNo' ELSE ErrorinColumn +','+SPACE(1)+  'UTKSAcNo' END  
		,Srnooferroneousrows=V.SlNo
--								----STUFF((SELECT ','+SRNO 
--								----FROM UploadBuyout A
--								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadBuyout V
--								---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
--								----)
--								----FOR XML PATH ('')
--								----),1,1,'')   

 FROM UploadBuyout V  
 WHERE ISNULL(UTKSAcNo,'') LIKE'%[a-zA-Z]%'


---------------------------------------------------
--/*VALIDATIONS ON Category */

--UPDATE UploadBuyout
--	SET  
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 
		
--		'Category is mandatory. Kindly check and upload again' 
--		ELSE 
--		case WHEN (v.Category = 'With Risk Sharing' OR v.Category = 'Without With Risk Sharing') then v.Category else 'Invalid value in Category. Kindly enter value ‘With Risk Sharing’ or ‘Without Risk Sharing’ and upload again' END END  
--		,ErrorinColumn='Category'    
--		,Srnooferroneousrows=''
--	FROM UploadBuyout v  
--	WHERE ISNULL(v.Category,'')=''  

------------------------------------------------------------------

--/* Commented on 14-05-2021 sunil on shishir advice  */

--UPDATE UploadBuyout
--	SET  
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid value in Category. Kindly enter value ‘With Risk Sharing’ or ‘Without Risk Sharing’ and upload again'     
--						ELSE ErrorMessage+','+SPACE(1)+'Invalid value in Category. Kindly enter value ‘With Risk Sharing’ or ‘Without Risk Sharing’ and upload again'     END
--		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Category' ELSE   ErrorinColumn +','+SPACE(1)+'Category' END       
--		,Srnooferroneousrows=V.SlNo
--	FROM UploadBuyout v  
--	WHERE ISNULL(v.Category,'')<>''  
--	And V.Category Not In ('With Risk Sharing','Without With Risk Sharing')


---------------Added on 18-05-2021 sunil on mohsin advice

--UPDATE UploadBuyout
--	SET  
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid value in Category. Kindly enter value ‘Agri’ or ‘Marginal’ or ‘Small’ and upload again'     
--						ELSE ErrorMessage+','+SPACE(1)+'Invalid value in Category. Kindly enter value ‘Agri’ or ‘Marginal’ or ‘Small’and upload again'     END
--		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Category' ELSE   ErrorinColumn +','+SPACE(1)+'Category' END       
--		,Srnooferroneousrows=V.SlNo
--	FROM UploadBuyout v  
--	WHERE ISNULL(v.Category,'')<>''  
--	And V.Category Not In ('Agri','Marginal','Small')



/*VALIDATIONS ON BuyoutPartyLoanNo */

  UPDATE UploadBuyout
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'BuyoutPartyLoanNo cannot be blank.  Please check the values and upload again'     
					ELSE ErrorMessage+','+SPACE(1)+'BuyoutPartyLoanNo cannot be blank.  Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'BuyoutPartyLoanNo' ELSE ErrorinColumn +','+SPACE(1)+  'BuyoutPartyLoanNo' END  
		,Srnooferroneousrows=V.SlNo
--								----STUFF((SELECT ','+SlNo 
--								----FROM UploadBuyout A
--								----WHERE A.SlNo IN(SELECT V.SlNo FROM UploadBuyout V  
--								----				WHERE ISNULL(ACID,'')='' )
--								----FOR XML PATH ('')
--								----),1,1,'')   

FROM UploadBuyout V  
 WHERE ISNULL(BuyoutPartyLoanNo,'')='' 
 
 ---Alpha Numeric----Updated by chetan 

 UPDATE UploadBuyout
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid BuyoutPartyLoanNo.  Please check the values and upload again'     
					ELSE ErrorMessage+','+SPACE(1)+'Invalid BuyoutPartyLoanNo.  Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'BuyoutPartyLoanNo' ELSE ErrorinColumn +','+SPACE(1)+  'BuyoutPartyLoanNo' END  
		,Srnooferroneousrows=V.SlNo


---special characters---Updated by chetan 

FROM UploadBuyout V  
 WHERE ISNULL(BuyoutPartyLoanNo,'') LIKE'%[a-zA-Z]%'

  UPDATE UploadBuyout
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid BuyoutPartyLoanNo.  Please check the values and upload again'     
					ELSE ErrorMessage+','+SPACE(1)+'Invalid BuyoutPartyLoanNo.  Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'BuyoutPartyLoanNo' ELSE ErrorinColumn +','+SPACE(1)+  'BuyoutPartyLoanNo' END  
		,Srnooferroneousrows=V.SlNo


FROM UploadBuyout V  
 WHERE ISNULL(BuyoutPartyLoanNo,'') LIKE'%[,!@#$%^&*()+=]%'



-- ----SELECT * FROM UploadBuyout
  
--  UPDATE UploadBuyout
--	SET  
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid BuyoutPartyLoanNo found. Please check the values and upload again'     
--						ELSE ErrorMessage+','+SPACE(1)+'Invalid BuyoutPartyLoanNo found. Please check the values and upload again'     END
--		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'BuyoutPartyLoanNo' ELSE ErrorinColumn +','+SPACE(1)+  'BuyoutPartyLoanNo' END  
--		,Srnooferroneousrows=V.SlNo
----								--STUFF((SELECT ','+SlNo 
----								--FROM UploadBuyout A
----								--WHERE A.SlNo IN(SELECT V.SlNo FROM UploadBuyout V
----								-- WHERE ISNULL(V.ACID,'')<>''
----								--		AND V.ACID NOT IN(SELECT SystemAcid FROM AxisIntReversalDB.IntReversalDataDetails 
----								--										WHERE -----EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
----								--										Timekey=@Timekey
----								--		))
----								--FOR XML PATH ('')
----								--),1,1,'')   
--		FROM UploadBuyout V  
-- WHERE ISNULL(V.BuyoutPartyLoanNo,'')<>''
-- AND V.BuyoutPartyLoanNo NOT IN(SELECT CustomerACID FROM [CurDat].[AdvAcBasicDetail] 
--								WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
--						 )


 IF OBJECT_ID('TEMPDB..#DUB2') IS NOT NULL
 DROP TABLE #DUB2

 SELECT * INTO #DUB2 FROM(
 SELECT *,ROW_NUMBER() OVER(PARTITION BY BuyoutPartyLoanNo ORDER BY BuyoutPartyLoanNo ) ROW FROM UploadBuyout
 )X
 WHERE ROW>1
   
   UPDATE UploadBuyout
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Duplicate records found.BuyoutPartyLoanNo are repeated.  Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Duplicate records found. BuyoutPartyLoanNo are repeated.  Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'BuyoutPartyLoanNo' ELSE   ErrorinColumn +','+SPACE(1)+'BuyoutPartyLoanNo' END     
		,Srnooferroneousrows=V.SlNo
	--	STUFF((SELECT ','+SRNO 
	--							FROM #UploadNewAccount A
	--							WHERE A.SrNo IN(SELECT V.SrNo FROM #UploadNewAccount V  
 --WHERE ISNULL(ACID,'')<>'' AND ISNULL(TERRITORY,'')<>''
 ----AND SRNO IN(SELECT Srno FROM #DUB2))
 --AND ACID IN(SELECT ACID FROM #DUB2 GROUP BY ACID))

	--							FOR XML PATH ('')
	--							),1,1,'')   

 FROM UploadBuyout V  
 WHERE ISNULL(BuyoutPartyLoanNo,'')<>''
 AND BuyoutPartyLoanNo IN(SELECT BuyoutPartyLoanNo FROM #DUB2 GROUP BY BuyoutPartyLoanNo)


 ---------------------------------------------------------------------
 /*validations on PartnerDPD */

 UPDATE UploadBuyout
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'PartnerDPD cannot be blank. Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'PartnerDPD cannot be blank. Please check the values and upload again'   END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'PartnerDPD' ELSE ErrorinColumn +','+SPACE(1)+  'PartnerDPD' END  
		,Srnooferroneousrows=V.SlNo
							

 FROM UploadBuyout V  
 WHERE ISNULL(PartnerDPD,'')=''

 UPDATE UploadBuyout
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid PartnerDPD. Please check the values and upload again'     
					ELSE ErrorMessage+','+SPACE(1)+'Invalid PartnerDPD. Please check the values and upload again'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'PartnerDPD' ELSE ErrorinColumn +','+SPACE(1)+  'PartnerDPD' END  
		,Srnooferroneousrows=V.SlNo
 

 FROM UploadBuyout V  
 WHERE (ISNUMERIC(PartnerDPD)=0 AND ISNULL(PartnerDPD,'')<>'') OR 
 (ISNUMERIC(PartnerDPD) LIKE '%^[0-9]%'  and ISNULL(PartnerDPD,'') LIKE'%[,!@#$%^&*()_-+=/]%')

 ------------validation for Asset class --- Updated by Nikhil

 PRINT 'INVALID' 

-- UPDATE UploadBuyout
--	SET  
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid PartnerDPD. Please check the values and upload again'     
--						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid PartnerDPD. Please check the values and upload again'     END
--		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'PartnerDPD' ELSE ErrorinColumn +','+SPACE(1)+  'PartnerDPD' END  
--		,Srnooferroneousrows=V.SlNo
----								----STUFF((SELECT ','+SRNO 
----								----FROM UploadBuyout A
----								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadBuyout V
----								---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
----								----)
----								----FOR XML PATH ('')
----								----),1,1,'')   

-- FROM UploadBuyout V  
-- WHERE ISNULL(PartnerDPD,'') LIKE'%[,!@#$%^&*()_-+=/]%'

 -------------validation for Asset class --- Updated by chetan

    UPDATE UploadBuyout
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid PartnerAssetClass  Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid PartnerAssetClass Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'PartnerAssetClass' ELSE ErrorinColumn +','+SPACE(1)+  'PartnerAssetClass' END  
		,Srnooferroneousrows=V.SlNo

 FROM UploadBuyout V  
 WHERE ISNULL(PartnerAssetClass,'')  not LIKE'%[a-zA-Z]%'


 
  ----------Validation on Partner DPD as on Date -----------Updated by chetan 

 -- UPDATE UploadBuyout
	--SET  
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid PartnerDPDAsOnDate. Please check the values and upload again'     
	--					ELSE ErrorMessage+','+SPACE(1)+ 'Invalid PartnerDPDAsOnDate. Please check the values and upload again'     END
	--	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'PartnerDPD' ELSE ErrorinColumn +','+SPACE(1)+  'PartnerDPD' END  
	--	,Srnooferroneousrows=V.SlNo
  

 --FROM UploadBuyout V  
 --WHERE ISNULL(PartnerDPDAsOnDate,'') not LIKE '[0-3] [0-9]/ [0-1] [1-2]/[1-2] [0-9] [0-9] [0-9]'


--  UPDATE UploadBuyout
--	SET  
--        ErrorMessage= CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid PartnerDPD. Please check the values and upload again'     
--						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid PartnerDPD. Please check the values and upload again'     END
--		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'PartnerDPD' ELSE ErrorinColumn +','+SPACE(1)+  'PartnerDPD' END  
--		,Srnooferroneousrows=V.SlNo
----								----STUFF((SELECT ','+SRNO 
----								----FROM UploadBuyout A
----								----WHERE A.SrNo IN(SELECT SRNO FROM UploadBuyout WHERE ISNULL(InterestReversalAmount,'')<>''
----								---- AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
----								---- )
----								----FOR XML PATH ('')
----								----),1,1,'')   

-- FROM UploadBuyout V  
-- WHERE ISNULL(PartnerDPD,'')<>''
-- --AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
-- --AND TRY_CONVERT(DECIMAL(25,2),ISNULL(Charges,0)) <0


 
----------------For Flag Checking in main table

 
UPDATE UploadBuyout
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Already Buyout Flag is present. Please Check the Account'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Already Buyout Flag is present. Please Check the Account'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'BuyoutPartyLoanNo' ELSE   ErrorinColumn +','+SPACE(1)+'BuyoutPartyLoanNo' END      
		,Srnooferroneousrows=''
		--STUFF((SELECT ','+SRNO 
		--						FROM #UploadNewAccount A
		--						WHERE A.SrNo IN(SELECT V.SrNo  FROM #UploadNewAccount V  
		--										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))

		--										)
		--						FOR XML PATH ('')
		--						),1,1,'')   

 FROM UploadBuyout V  
 Inner Join Dbo.AdvAcOtherDetail A ON V.BuyoutPartyLoanNo=A.RefSystemAcId And A.EffectiveToTimeKey=49999
 WHERE A.SplFlag like '%Buyout%'

--------Validations on action-------------		
 
-- UPDATE UploadBuyout
--	SET  
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Action cannot be blank it Should be (A OR R) .  Please check the values and upload again'     
--						ELSE ErrorMessage+','+SPACE(1)+'Action cannot be blank it Should be (A OR R).  Please check the values and upload again'     END
--		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Action' ELSE   ErrorinColumn +','+SPACE(1)+'Action' END       
--		,Srnooferroneousrows=V.SlNo

   
--   FROM UploadBuyout V  
-- --WHERE ISNULL(SecuritisationType,'')<>'' And SecuritisationType not in ('PTC - Pass Thru Certificate','DA - Direct Assignment')

-- WHERE ISNULL(Action,'')='' 			


-- UPDATE UploadBuyout
--	SET  
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid Action Should be (A OR R) .  Please check the values and upload again'     
--						ELSE ErrorMessage+','+SPACE(1)+'Invalid Action should be (A OR R).  Please check the values and upload again'     END
--		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Action' ELSE   ErrorinColumn +','+SPACE(1)+'Action' END       
--		,Srnooferroneousrows=V.SlNo

   
--   FROM UploadBuyout V  
-- --WHERE ISNULL(SecuritisationType,'')<>'' And SecuritisationType not in ('PTC - Pass Thru Certificate','DA - Direct Assignment')

-- WHERE ISNULL(Action,'')<>'' And Action not in ('A','R')	


 	 
--   UPDATE UploadBuyout 
--	SET  
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Account is not Marked with Action A, for performig Acion R.  Please check and upload again'     
--						ELSE ErrorMessage+','+SPACE(1)+'This Action is Already Marked on this Account.  Please check and upload again'     END
--		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Action' ELSE   ErrorinColumn +','+SPACE(1)+'Action' END       
--		,Srnooferroneousrows=v.SlNo

 
--FROM UploadBuyout V  
-- WHERE Action in  ('R')
-- And not exists (Select 1 FRom BuyoutFinalDetails A where A.CIFId=V.CIFId  And A.EffectiveToTimeKey=49999
--	 And AuthorisationStatus In ('A','R'))





---------------------------------------------------------------------------Upload for same account ID--------------
UPDATE UploadBuyout
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'CIFID Already present, please check and Upload'     
						ELSE ErrorMessage+','+SPACE(1)+'CIFID Already present, please check and Upload'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'CIFID' ELSE ErrorinColumn +','+SPACE(1)+  'CIFID' END  
		,Srnooferroneousrows=V.SlNo	
  
		FROM UploadBuyout V  
 WHERE ISNULL(V.CIFId,'')<>''
 AND V.CIFId  IN (SELECT Distinct CIFId FROM BuyoutDetails_Mod
								WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
								AND AuthorisationStatus in ('NP','MP','1A') 
						 )


 Print '123'
 goto valid

  END
	
   ErrorData:  
   print 'no'  

		SELECT *,'Data'TableName
		FROM dbo.MasterUploadData WHERE FileNames=@filepath 
		return

   valid:
		IF NOT EXISTS(Select 1 from  BuyoutDetails_stg WHERE filname=@FilePathUpload)
		BEGIN
		PRINT 'NO ERRORS'
			
			Insert into dbo.MasterUploadData
			(SR_No,ColumnName,ErrorData,ErrorType,FileNames,Flag) 
			SELECT '' SRNO , '' ColumnName,'' ErrorData,'' ErrorType,@filepath,'SUCCESS' 
			
		END
		ELSE
		BEGIN
			PRINT 'VALIDATION ERRORS1'
			Insert into dbo.MasterUploadData
			(SR_No,ColumnName,ErrorData,ErrorType,FileNames,Srnooferroneousrows,Flag) 
			SELECT SlNo,ErrorinColumn,ErrorMessage,ErrorinColumn,@filepath,Srnooferroneousrows,'SUCCESS' 
			FROM UploadBuyout 

			PRINT 'VALIDATION ERRORS'
			
		--	----SELECT * FROM UploadBuyout 

		--	--ORDER BY ErrorMessage,UploadBuyout.ErrorinColumn DESC
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
	Print 'Validation=Y'
    Update UploadStatus Set ValidationOfData='Y',ValidationOfDataCompletedOn=GetDate()   
    where FileNames=@filepath  
  
   END  


  final:
  Print 'ERR'
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

		 IF EXISTS(SELECT 1 FROM BuyoutDetails_stg WHERE filname=@FilePathUpload)
		 BEGIN
		 DELETE FROM BuyoutDetails_stg
		 WHERE filname=@FilePathUpload

		 PRINT 1

		 PRINT 'ROWS DELETED FROM DBO.BuyoutDetails_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
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

	----SELECT * FROM UploadBuyout

	print 'p'
  ------to delete file if it has errors
		--if exists(Select  1 from dbo.MasterUploadData where FileNames=@filepath and ISNULL(ErrorData,'')<>'')
		--begin
		--print 'ppp'
		-- IF EXISTS(SELECT 1 FROM BuyoutDetails_stg WHERE filname=@FilePathUpload)
		-- BEGIN
		-- print '123'
		-- DELETE FROM BuyoutDetails_stg
		-- WHERE filname=@FilePathUpload

		-- PRINT 'ROWS DELETED FROM DBO.BuyoutDetails_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
		-- END
		-- END

   
END  TRY
  
  BEGIN CATCH
	

	INSERT INTO dbo.Error_Log
				SELECT ERROR_LINE() as ErrorLine,ERROR_MESSAGE()ErrorMessage,ERROR_NUMBER()ErrorNumber
				,ERROR_PROCEDURE()ErrorProcedure,ERROR_SEVERITY()ErrorSeverity,ERROR_STATE()ErrorState
				,GETDATE()

	--IF EXISTS(SELECT 1 FROM BuyoutDetails_stg WHERE filname=@FilePathUpload)
	--	 BEGIN
	--	 DELETE FROM BuyoutDetails_stg
	--	 WHERE filname=@FilePathUpload

	--	 PRINT 'ROWS DELETED FROM DBO.BuyoutDetails_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
	--	 END

END CATCH

END
  
  select * from STD_ProvDetail
GO