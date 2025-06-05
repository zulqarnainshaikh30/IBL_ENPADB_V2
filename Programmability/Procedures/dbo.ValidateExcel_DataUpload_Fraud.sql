SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[ValidateExcel_DataUpload_Fraud]  
@MenuID INT=24738,  
@UserLoginId  VARCHAR(20)='mcheck1',  
@Timekey INT=25999
,@filepath VARCHAR(MAX) ='NPAFraudAccount.xlsx'  
WITH RECOMPILE  
AS  
  
 

--DECLARE  
  
--@MenuID INT=24715,  
--@UserLoginId varchar(20)='lvl1admin',  
--@Timekey int=26085
--,@filepath varchar(500)='Fraud_AWupload (15).xlsx'  
  
BEGIN

BEGIN TRY  
--BEGIN TRAN  
  
--Declare @TimeKey int  
    --Update UploadStatus Set ValidationOfData='N' where FileNames=@filepath  
     
	 SET DATEFORMAT DMY

 --Select @Timekey=Max(Timekey) from dbo.SysProcessingCycle  
 -- where  ProcessType='Quarterly' ----and PreMOC_CycleFrozenDate IS NULL
 
   SET @Timekey =(Select TimeKey from SysDataMatrix where CurrentStatus='C') 

  --SET @Timekey =(Select LastMonthDateKey from SysDayMatrix where Timekey=@Timekey)   

  
  
	DECLARE @DateOfData date
	Set @DateOfData=(select cast(ExtDate as date) from SysDataMatrix where Timekey=@Timekey)
  
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


IF (@MenuID=24738)	
BEGIN

	  -- IF OBJECT_ID('tempdb..UploadAccMOCPool') IS NOT NULL  
	  IF OBJECT_ID('UploadFraudPool') IS NOT NULL  
	  BEGIN  
	   DROP TABLE UploadFraudPool  
	
	  END
	  
  IF NOT (EXISTS (SELECT 1 FROM NPAFraudAccountUpload_stg where filname=@FilePathUpload))
 
  --SELECT * FROM AccountLvlMOCDetails_stg

BEGIN
print 'NO DATA'
			Insert into dbo.MasterUploadData
			(SR_No,ColumnName,ErrorData,ErrorType,FileNames,Flag) 
			SELECT 0 SrNo , '' ColumnName,'No Record found' ErrorData,'No Record found' ErrorType,@filepath,'SUCCESS' 
			--SELECT 0 SrNo , '' ColumnName,'' ErrorData,'' ErrorType,@filepath,'SUCCESS' 

			goto errordata
    
END

ELSE
BEGIN

PRINT 'DATA PRESENT'
	   Select *,CAST('' AS varchar(MAX)) ErrorMessage,CAST('' AS varchar(MAX)) ErrorinColumn,CAST('' AS varchar(MAX)) Srnooferroneousrows
 	   into UploadFraudPool 
	   from NPAFraudAccountUpload_stg 
	   WHERE filname=@FilePathUpload

	   --select * from UploadFraudPool

	  
END		
  ------------------------------------------------------------------------------ 
  print 'Sudesh' 
    ----SELECT * FROM UploadAccMOCPool
	--SrNo	Territory	AccountNumber	InterestReversalAmount	filename
	UPDATE UploadFraudPool
	SET  
        ErrorMessage='There is no data in excel. Kindly check and upload again' 
		,ErrorinColumn='SrNo,Account ID,RFA Reported by Bank,Date of RFA Reporting by Bank,Name of Other Bank Reporting RFA
,Date of Reporting RFA by Other Bank,
		Date of Fraud Occurrence,Date of Fraud Declaration by RBL
,Nature of Fraud,Areas of Operations,Post Fraud Flagging Asset Class,Provision Preference'    
		,Srnooferroneousrows=''
 FROM UploadFraudPool V  
 WHERE ISNULL(SrNo,'')=''
AND ISNULL(AccountNumber,'')=''
AND ISNULL(RFAreportedbyBank,'')=''
AND ISNULL(DateofRFAreportingbyBank,'')=''
AND ISNULL(NameofotherBankreportingRFA,'')=''
AND ISNULL(DateofreportingRFAbyOtherBank,'')=''
AND ISNULL(DateofFraudoccurrence,'')=''
AND ISNULL(DateofFrauddeclarationbyRBL,'')=''
AND ISNULL(NatureofFraud,'')=''
AND ISNULL(AreasofOperations,'')=''
AND ISNULL(Provisionpreference,'')=''




print 'JAGRUTI'

--UPDATE UploadAccMOCPool
--	SET  
--        ErrorMessage= 'Sr No is present and remaining  excel file is blank. Please check and Upload again.'     
--	,ErrorinColumn='no value for MOC'  
--		,Srnooferroneousrows=''
	
--   FROM UploadAccMOCPool V  
-- WHERE 
-- ISNULL(SrNo,'')<>''

--AND ISNULL(POSinRs,'')=''
--AND ISNULL(InterestReceivableinRs,'')=''
----AND ISNULL(AdditionalProvisionAbsoluteinRs,'')=''
----AND ISNULL(RestructureFlagYN,'')=''
----AND ISNULL(RestructureDate,'')=''
--AND ISNULL(FITLFlagYN,'')=''
--AND ISNULL(DFVAmount,'')=''
----AND ISNULL(MOCAdditionalProvisionalExpiryDate,'')=''
--AND ISNULL(AdditionalProvision,'')=''
----AND ISNULL(RePossesssionFlagYN,'')=''
----AND ISNULL(RePossessionDate,'')=''
----AND ISNULL(InherentWeaknessFlag,'')=''
----AND ISNULL(InherentWeaknessDate,'')=''
----AND ISNULL(SARFAESIFlag,'')=''
----AND ISNULL(SARFAESIDate,'')=''
----AND ISNULL(UnusualBounceFlag,'')=''
----AND ISNULL(UnusualBounceDate,'')=''
----AND ISNULL(UnclearedEffectsFlag,'')=''
----AND ISNULL(UnclearedEffectsDate,'')=''
--AND ISNULL(FraudFlag,'')=''
--AND ISNULL(FraudDate,'')=''
----AND ISNULL(MOCSource,'')=''
----AND ISNULL(MOCReason,'')=''
  
----WHERE ISNULL(V.SrNo,'')=''
---- ----AND ISNULL(Territory,'')=''
---- AND ISNULL(AccountID,'')=''
---- AND ISNULL(PoolID,'')=''
---- AND ISNULL(filename,'')=''
print 'PRASHANT1'
  IF EXISTS(SELECT 1 FROM UploadFraudPool WHERE ISNULL(ErrorMessage,'')<>'')
  BEGIN
  PRINT 'NO DATA'
  GOTO ERRORDATA;
  END
   
print 'PRASHANT2'
  
  /*validations on SrNo*/
  
 Declare @DuplicateCnt int=0
   UPDATE UploadFraudPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'SrNo cannot be blank . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'SrNo cannot be blank . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' ELSE   ErrorinColumn +','+SPACE(1)+'SrNo' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadFraudPool V  
 WHERE ISNULL(v.SrNo,'')='' 

 --   UPDATE UploadAccMOCPool
	--SET  
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'SrNo cannot be blank . Please check the values and upload again'     
	--					ELSE ErrorMessage+','+SPACE(1)+'SrNo cannot be blank . Please check the values and upload again'     END
	--	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' ELSE   ErrorinColumn +','+SPACE(1)+'SrNo' END   
	--	,Srnooferroneousrows=V.SrNo
								
   
 --  FROM UploadAccMOCPool V  
 --WHERE (ISNULL(v.SrNo,'')<>'' or ISNULL(v.SrNo,0)=0)  -- OR ISNULL(v.SrNo,'')<0

  print 'PRASHANT3'
  UPDATE UploadFraudPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'SrNo cannot be greater than 16 character . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'SrNo cannot be greater than 16 character . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' ELSE   ErrorinColumn +','+SPACE(1)+'SrNo' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadFraudPool V  
 WHERE Len(SrNo)>16

 print 'PRASHANT4'



  UPDATE UploadFraudPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid Sl. No., kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid Sl. No., kindly check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' ELSE   ErrorinColumn +','+SPACE(1)+'SrNo' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadFraudPool V  
  WHERE --(ISNUMERIC(SrNo)=0 AND ISNULL(SrNo,'')<>'') OR 
 ISNUMERIC(SrNo) LIKE '%^[0-9]%'

 UPDATE UploadFraudPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Special characters not allowed, kindly remove and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Special characters not allowed, kindly remove and upload again'   END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' ELSE   ErrorinColumn +','+SPACE(1)+'SrNo' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadFraudPool V  
  -- WHERE ISNULL(SrNo,'') LIKE '%[,!@#$%^&*()_-+=/]%'
  WHERE ISNULL(SrNo,'') LIKE '%[^0-9a-zA-Z]%'
   --LIKE'%[,!@#$%^&*()_-+=/]%- \ / _%'
   --
  SELECT @DuplicateCnt=Count(1)
FROM UploadFraudPool
GROUP BY  SrNo
HAVING COUNT(SrNo) >1;

IF (@DuplicateCnt>0)

 UPDATE UploadFraudPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Duplicate Sl. No., kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Duplicate Sl. No., kindly check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' ELSE   ErrorinColumn +','+SPACE(1)+'SrNo' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadFraudPool V  
   Where ISNULL(SrNo,'') In(  
   SELECT SrNo
	FROM UploadFraudPool
	GROUP BY  SrNo
	HAVING COUNT(SrNo) >1

)


 ------------------------------------------------

/*VALIDATIONS ON AccountID */

UPDATE		UploadFraudPool
SET  
			ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'The column ‘Account ID’ is mandatory. Kindly check and upload again'     
			ELSE ErrorMessage+','+SPACE(1)+'The column ‘Account ID’ is mandatory. Kindly check and upload again'     END
			,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Account ID' ELSE ErrorinColumn +','+SPACE(1)+  'Account ID' END  
			,Srnooferroneousrows=V.SrNo 
FROM		UploadFraudPool V  
 WHERE		ISNULL(AccountNumber,'')='' 
 

 
  UPDATE	UploadFraudPool
  SET  
			ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid Account ID.  Please check the values and upload again'     
			ELSE ErrorMessage+','+SPACE(1)+'Invalid Account ID.  Please check the values and upload again'  END
			,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Account ID' ELSE ErrorinColumn +','+SPACE(1)+  'Account ID' END  
			,Srnooferroneousrows=V.SrNo
 FROM		UploadFraudPool V  
 WHERE		LEN(AccountNumber)>20

 
-- ----SELECT * FROM UploadAccMOCPool
  
  UPDATE UploadFraudPool
	SET  ErrorMessage=	CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid Account ID found. Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid Account ID found. Please check the values and upload again'     END
		,ErrorinColumn=	CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Account ID' ELSE ErrorinColumn +','+SPACE(1)+  'Account ID' END  
		,Srnooferroneousrows=V.SrNo
  
		FROM UploadFraudPool V  
 WHERE ISNULL(V.AccountNumber,'')<>''
 AND V.AccountNumber NOT IN(SELECT CustomerACID FROM AdvAcBasicDetail
								WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
								UNION
								SELECT CustomerACID FROM AdvNFAcBasicDetail
								WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
								UNION
								SELECT InvID FROM InvestmentBasicDetail
								WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
								UNION
								SELECT DerivativeRefNo FROM curdat.DerivativeDetail
								WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
						 )


 IF OBJECT_ID('TEMPDB..#DUB2') IS NOT NULL
 DROP TABLE #DUB2

 SELECT * INTO #DUB2 FROM(
 SELECT *,ROW_NUMBER() OVER(PARTITION BY AccountNumber ORDER BY AccountNumber ) as rw  FROM UploadFraudPool
 )X
 WHERE rw>1


 UPDATE V
	SET  
        ErrorMessage=CASE WHEN ISNULL(V.ErrorMessage,'')='' THEN  'Duplicate Account ID found. Please check the values and upload again'     
						ELSE V.ErrorMessage+','+SPACE(1)+'Duplicate Account ID found. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(V.ErrorinColumn,'')='' THEN 'Account ID' ELSE V.ErrorinColumn +','+SPACE(1)+  'Account ID' END  
		,Srnooferroneousrows=V.SrNo
		FROM UploadFraudPool V 
		INNer JOIN #DUB2 D ON D.AccountNumber=V.AccountNumber

						
---------------------Authorization for Screen Same acc ID --------------------------


UPDATE UploadFraudPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'You cannot perform Fraud, Record is pending for authorization for this Account ID. Kindly authorize or Reject the record through ‘Fraud Screen – Authorization’ menu'     
						ELSE ErrorMessage+','+SPACE(1)+'You cannot perform Fraud, Record is pending for authorization for this Account ID. Kindly authorize or Reject the record through ‘Fraud Screen – Authorization’ menu'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Account ID' ELSE ErrorinColumn +','+SPACE(1)+  'Account ID' END 
		,Srnooferroneousrows=V.SrNo
 
		FROM UploadFraudPool V  
 WHERE ISNULL(V.AccountNumber,'')<>''
 AND V.AccountNumber  IN (SELECT Distinct RefCustomerACID FROM Fraud_Details_Mod
								WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
								AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'DP', 'RM','1A') 
								and ISNULL(Screenflag,'') <> 'U'
						 )
---------------------------------------------------------------------------Upload for same account ID--------------
UPDATE UploadFraudPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'You cannot perform Fraud, Record is pending for authorization for this Account ID. Kindly authorize or Reject the record through ‘Fraud Screen Upload– Authorization’ menu'     
						ELSE ErrorMessage+','+SPACE(1)+'You cannot perform Fraud, Record is pending for authorization for this Account ID. Kindly authorize or Reject the record through ‘Fraud Screen Upload– Authorization’ menu'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Account ID' ELSE ErrorinColumn +','+SPACE(1)+  'Account ID' END  
		,Srnooferroneousrows=V.SrNo	
  
		FROM UploadFraudPool V  
 WHERE ISNULL(V.AccountNumber,'')<>''
 AND V.AccountNumber  IN (SELECT Distinct RefCustomerACID FROM Fraud_Details_Mod
								WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
								AND AuthorisationStatus in ('NP','MP','1A','FM') and ISNULL(Screenflag,'') = 'U'
						 )


-------------------------RFA Reported by Bank------------------------------------------------------


 UPDATE UploadFraudPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid value in column ‘RFA Reported by Bank(Y/N)’. Kindly enter ‘Y or N’ and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid value in column ‘RFA Reported by Bank(Y/N)’. Kindly enter ‘Y or N’ and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'RFA Reported by Bank' ELSE ErrorinColumn +','+SPACE(1)+  'RFA Reported by Bank' END  
		,Srnooferroneousrows=V.SrNo
		
 FROM UploadFraudPool V  
 WHERE ISNULL(RFAreportedbyBank,'') NOT IN('Y','N','')

 
------------------------Name of Other Bank Reporting RFA---------------------------------------------


 UPDATE UploadFraudPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid value in column ‘Name of Other Bank Reporting RFA’. Kindly upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid value in column ‘Name of Other Bank Reporting RFA’. Kindly upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Name of Other Bank Reporting RFA' ELSE ErrorinColumn +','+SPACE(1)+  'Name of Other Bank Reporting RFA' END  
		,Srnooferroneousrows=V.SrNo 
 FROM UploadFraudPool V  
 WHERE (ISNULL(NameofotherBankreportingRFA,'') NOT IN(select distinct BankName from DimBankRP) AND ISNULL(NameofotherBankreportingRFA,'') NOT IN (''))



 
-----------------------Provision Preference---------------------------------------------


 UPDATE UploadFraudPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Provision Preference is Mandatory. Kindly upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Provision Preference is Mandatory. Kindly upload againn'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Provision Preference' ELSE ErrorinColumn +','+SPACE(1)+  'Provision Preference' END  
		,Srnooferroneousrows=V.SrNo 
 FROM UploadFraudPool V  
 WHERE ISNULL(Provisionpreference,'') = '' 


 UPDATE UploadFraudPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid value in column ‘Provision Preference’. Kindly upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid value in column ‘Provision Preference’. Kindly upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Provision Preference' ELSE ErrorinColumn +','+SPACE(1)+  'Provision Preference' END  
		,Srnooferroneousrows=V.SrNo 
 FROM UploadFraudPool V  
 WHERE ISNULL(Provisionpreference,'') NOT IN(select distinct ParameterName from DimParameter where DimParameterName in ('DimProvisionPreference'))


/*VALIDATIONS Date of RFA Reporting by Bank */---------------------------------------


 SET DATEFORMAT DMY
UPDATE UploadFraudPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Date of RFA Reporting by Bank' ELSE   ErrorinColumn +','+SPACE(1)+'Date of RFA Reporting by Bank' END     
		,Srnooferroneousrows=V.SrNo	
 FROM UploadFraudPool V  
 WHERE ISNULL(DateofRFAreportingbyBank,'') <>'' AND ISDATE(DateofRFAreportingbyBank)=0
  

  UPDATE UploadFraudPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Date of RFA reporting by bank is mandatory when RFA reported by bank is Y.'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Date of RFA reporting by bank is mandatory when RFA reported by bank is Y.'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Date of RFA Reporting by Bank' ELSE   ErrorinColumn +','+SPACE(1)+'Date of RFA Reporting by Bank' END     
		,Srnooferroneousrows=V.SrNo	
 FROM UploadFraudPool V  
 WHERE ISNULL(RFAreportedbyBank,'')='Y' AND ISNULL(DateofRFAreportingbyBank,'')='' 

  Set DateFormat DMY
 UPDATE UploadFraudPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Date of RFA Reporting by Bank must be less than equal to current date. Kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Date of RFA Reporting by Bank must be less than equal to current date. Kindly check and upload again'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Date of RFA Reporting by Bank' ELSE   ErrorinColumn +','+SPACE(1)+'Date of RFA Reporting by Bank' END      
		,Srnooferroneousrows=V.SrNo	
 FROM UploadFraudPool V  
 WHERE (Case When ISDATE(DateofRFAreportingbyBank)=1 Then Case When Cast(DateofRFAreportingbyBank as date)>Cast(@DateOfData as Date)
                                                               Then 1 Else 0 END END)=1





															   
/*VALIDATIONS Date of Reporting RFA by Other Bank */---------------------------------------


 SET DATEFORMAT DMY
UPDATE UploadFraudPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Date of Reporting RFA by Other Bank' ELSE   ErrorinColumn +','+SPACE(1)+'Date of Reporting RFA by Other Bank' END     
		,Srnooferroneousrows=V.SrNo	
 FROM UploadFraudPool V  
 WHERE ISNULL(DateofreportingRFAbyOtherBank,'') <>'' AND ISDATE(DateofreportingRFAbyOtherBank)=0
  
   
  Set DateFormat DMY
 UPDATE UploadFraudPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Date of Reporting RFA by Other Bank must be less than equal to current date. Kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Date of Reporting RFA by Other Bank must be less than equal to current date. Kindly check and upload again'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Date of Reporting RFA by Other Bank' ELSE   ErrorinColumn +','+SPACE(1)+'Date of Reporting RFA by Other Bank' END      
		,Srnooferroneousrows=V.SrNo	
 FROM UploadFraudPool V  
 WHERE (Case When ISDATE(DateofreportingRFAbyOtherBank)=1 Then Case When Cast(DateofreportingRFAbyOtherBank as date)>Cast(@DateOfData as Date)
                                                               Then 1 Else 0 END END)=1








															   
															   
/*VALIDATIONS Date of Fraud Occurrence */---------------------------------------


 SET DATEFORMAT DMY
UPDATE UploadFraudPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Date of Fraud Occurrence' ELSE   ErrorinColumn +','+SPACE(1)+'Date of Fraud Occurrence' END     
		,Srnooferroneousrows=V.SrNo	
 FROM UploadFraudPool V  
 WHERE ISNULL(DateofFraudoccurrence,'') <>'' AND ISDATE(DateofFraudoccurrence)=0
  

  Set DateFormat DMY
 UPDATE UploadFraudPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Date of Fraud Occurrence must be less than equal to current date. Kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Date of Fraud Occurrence must be less than equal to current date. Kindly check and upload again'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Date of Fraud Occurrence' ELSE   ErrorinColumn +','+SPACE(1)+'Date of Fraud Occurrence' END      
		,Srnooferroneousrows=V.SrNo	
 FROM UploadFraudPool V  
 WHERE (Case When ISDATE(DateofFraudoccurrence)=1 Then Case When Cast(DateofFraudoccurrence as date)>Cast(@DateOfData as Date)
                                                               Then 1 Else 0 END END)=1

---------------------------------------



															   
															   
/*VALIDATIONS Date of Fraud Declaration by RBL
 */---------------------------------------


 SET DATEFORMAT DMY
UPDATE UploadFraudPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Date of Fraud Declaration by RBL' ELSE   ErrorinColumn +','+SPACE(1)+'Date of Fraud Declaration by RBL' END     
		,Srnooferroneousrows=V.SrNo	
 FROM UploadFraudPool V  
 WHERE ISNULL(DateofFrauddeclarationbyRBL,'') <>'' AND ISDATE(DateofFrauddeclarationbyRBL)=0
  

  Set DateFormat DMY
 UPDATE UploadFraudPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Date of Fraud Declaration by RBL must be less than equal to current date. Kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Date of Fraud Declaration by RBL must be less than equal to current date. Kindly check and upload again'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Date of Fraud Declaration by RBL' ELSE   ErrorinColumn +','+SPACE(1)+'Date of Fraud Declaration by RBL' END      
		,Srnooferroneousrows=V.SrNo	
 FROM UploadFraudPool V  
 WHERE (Case When ISDATE(DateofFrauddeclarationbyRBL)=1 Then Case When Cast(DateofFrauddeclarationbyRBL as date)>Cast(@DateOfData as Date)
                                                               Then 1 Else 0 END END)=1


															   


  UPDATE UploadFraudPool
	SET  
  ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'FraudDeclarationDate is mandatory . Please upload and confirm.'     
						ELSE ErrorMessage+','+SPACE(1)+ 'FraudDeclarationDate is mandatory . Please upload and confirm.'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'FraudDeclarationDate' ELSE   ErrorinColumn +','+SPACE(1)+'FraudDeclarationDate' END      
		,Srnooferroneousrows=V.SrNo
		--STUFF((SELECT ','+SrNo 
		--						FROM #UploadNewAccount A
		--						WHERE A.SrNo IN(SELECT V.SrNo  FROM #UploadNewAccount V  
		--										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))

		--										)
		--						FOR XML PATH ('')
		--						),1,1,'')   

 FROM UploadFraudPool V  
 WHERE  ISNULL(DateofFrauddeclarationbyRBL,'' )=''



 											   
															   
--/*VALIDATIONS Current NPA Date 
-- */---------------------------------------


-- SET DATEFORMAT DMY
--UPDATE UploadFraudPool
--	SET  
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'     
--						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'      END
--		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN ' Current NPA Date' ELSE   ErrorinColumn +','+SPACE(1)+' Current NPA Date' END     
--		,Srnooferroneousrows=V.SrNo	
-- FROM UploadFraudPool V  
-- WHERE ISNULL(CurrentNPA_Date,'') <>'' AND ISDATE(CurrentNPA_Date)=0
  

--  Set DateFormat DMY
-- UPDATE UploadFraudPool
--	SET  
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN ' Current NPA Date by RBL must be less than equal to current date. Kindly check and upload again'     
--						ELSE ErrorMessage+','+SPACE(1)+ ' Current NPA Date must be less than equal to current date. Kindly check and upload again'      END
--		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN ' Current NPA Date' ELSE   ErrorinColumn +','+SPACE(1)+' Current NPA Date' END      
--		,Srnooferroneousrows=V.SrNo	
-- FROM UploadFraudPool V  
-- WHERE (Case When ISDATE(CurrentNPA_Date)=1 Then Case When Cast(CurrentNPA_Date as date)>Cast(@DateOfData as Date)
--                                                               Then 1 Else 0 END END)=1


															   


--  UPDATE UploadFraudPool
--	SET  
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'CurrentNPA_Date is mandatory . Please upload and confirm.'     
--						ELSE ErrorMessage+','+SPACE(1)+ 'CurrentNPA_Date is mandatory . Please upload and confirm.'      END
--		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'CurrentNPA_Date' ELSE   ErrorinColumn +','+SPACE(1)+'CurrentNPA_Date' END      
--		,Srnooferroneousrows=V.SrNo
--		--STUFF((SELECT ','+SrNo 
--		--						FROM #UploadNewAccount A
--		--						WHERE A.SrNo IN(SELECT V.SrNo  FROM #UploadNewAccount V  
--		--										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))

--		--										)
--		--						FOR XML PATH ('')
--		--						),1,1,'')   

-- FROM UploadFraudPool V  
-- WHERE  ISNULL(CurrentNPA_Date,'' )=''

 
/*VALIDATIONS ON Nature of Fraud */

 UPDATE	UploadFraudPool
  SET  
			ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Nature of Fraud must be Mandatory.  Please check the values and upload again'     
			ELSE ErrorMessage+','+SPACE(1)+'Nature of Fraud must be Mandatory.  Please check the values and upload again'  END
			,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Nature of Fraud' ELSE ErrorinColumn +','+SPACE(1)+  'Nature of Fraud' END  
			,Srnooferroneousrows=V.SrNo
 FROM		UploadFraudPool V  
 WHERE		 ISNULL(NatureofFraud,'') = '' 

 
  UPDATE	UploadFraudPool
  SET  
			ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Nature of Fraud cant be more than 500 characters.  Please check the values and upload again'     
			ELSE ErrorMessage+','+SPACE(1)+'Nature of Fraud cant be more than 500 characters.  Please check the values and upload again'  END
			,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Nature of Fraud' ELSE ErrorinColumn +','+SPACE(1)+  'Nature of Fraud' END  
			,Srnooferroneousrows=V.SrNo
 FROM		UploadFraudPool V  
 WHERE		LEN(NatureofFraud)>500 

 

---------------------------------------

 
/*VALIDATIONS ON Areas of Operations */

 UPDATE	UploadFraudPool
  SET  
			ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Areas of Operations must be Mandatory.  Please check the values and upload again'     
			ELSE ErrorMessage+','+SPACE(1)+'Areas of Operations must be Mandatory.  Please check the values and upload again'  END
			,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Areas of Operations' ELSE ErrorinColumn +','+SPACE(1)+  'Areas of Operations' END  
			,Srnooferroneousrows=V.SrNo
 FROM		UploadFraudPool V  
 WHERE		ISNULL(AreasofOperations,'') = '' 
 
  UPDATE	UploadFraudPool
  SET  
			ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Areas of Operations cant be more than 500 characters.  Please check the values and upload again'     
			ELSE ErrorMessage+','+SPACE(1)+'Areas of Operations cant be more than 500 characters.  Please check the values and upload again'  END
			,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Areas of Operations' ELSE ErrorinColumn +','+SPACE(1)+  'Areas of Operations' END  
			,Srnooferroneousrows=V.SrNo
 FROM		UploadFraudPool V  
 WHERE		LEN(AreasofOperations)>500 

 
 
 
 Print '123'
 goto valid

  END
	
   ErrorData:  
   print 'no'  

		SELECT *,'Data'TableName
		FROM dbo.MasterUploadData WHERE FileNames=@filepath 
		return

   valid:
		IF NOT EXISTS(Select 1 from  NPAFraudAccountUpload_stg WHERE filname=@FilePathUpload)
		BEGIN
		PRINT 'NO ERRORS'
			
			Insert into dbo.MasterUploadData
			(SR_No,ColumnName,ErrorData,ErrorType,FileNames,Flag) 
			SELECT '' SrNo , '' ColumnName,'' ErrorData,'' ErrorType,@filepath,'SUCCESS' 
			
		END
		ELSE
		BEGIN
			PRINT 'VALIDATION ERRORS'
			Insert into dbo.MasterUploadData
			(SR_No,ColumnName,ErrorData,ErrorType,FileNames,Srnooferroneousrows,Flag) 
			SELECT SrNo,ErrorinColumn,ErrorMessage,ErrorinColumn,@filepath,Srnooferroneousrows,'SUCCESS' 
			FROM UploadFraudPool 


			
		--	----SELECT * FROM UploadAccMOCPool 

		--	--ORDER BY ErrorMessage,UploadAccMOCPool.ErrorinColumn DESC
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

		 IF EXISTS(SELECT 1 FROM NPAFraudAccountUpload_stg WHERE filname=@FilePathUpload)
		 BEGIN
		 DELETE FROM NPAFraudAccountUpload_stg
		 WHERE filname=@FilePathUpload

		 PRINT 1

		 PRINT 'ROWS DELETED FROM DBO.NPAFraudAccountUpload_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
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

	----SELECT * FROM UploadAccMOCPool

	print 'p'
  ------to delete file if it has errors
		--if exists(Select  1 from dbo.MasterUploadData where FileNames=@filepath and ISNULL(ErrorData,'')<>'')
		--begin
		--print 'ppp'
		-- IF EXISTS(SELECT 1 FROM AccountLvlMOCDetails_stg WHERE filename=@FilePathUpload)
		-- BEGIN
		-- print '123'
		 --DELETE FROM AccountLvlMOCDetails_stg
		 --WHERE filename=@FilePathUpload

		-- PRINT 'ROWS DELETED FROM DBO.AccountLvlMOCDetails_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
		-- END
		-- END

   
END  TRY
  
  BEGIN CATCH
	

	INSERT INTO dbo.Error_Log
				SELECT ERROR_LINE() as ErrorLine,ERROR_MESSAGE()ErrorMessage,ERROR_NUMBER()ErrorNumber
				,ERROR_PROCEDURE()ErrorProcedure,ERROR_SEVERITY()ErrorSeverity,ERROR_STATE()ErrorState
				,GETDATE()

	--IF EXISTS(SELECT 1 FROM AccountLvlMOCDetails_stg WHERE filename=@FilePathUpload)
	--	 BEGIN
	--	 DELETE FROM AccountLvlMOCDetails_stg
	--	 WHERE filename=@FilePathUpload

	--	 PRINT 'ROWS DELETED FROM DBO.AccountLvlMOCDetails_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
	--	 END

END CATCH

END


GO