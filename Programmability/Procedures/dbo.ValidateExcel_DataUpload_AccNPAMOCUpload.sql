SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

 
CREATE PROCEDURE [dbo].[ValidateExcel_DataUpload_AccNPAMOCUpload]  
@MenuID INT=10,  
@UserLoginId  VARCHAR(20)='fnachecker',  
@Timekey INT=49999
,@filepath VARCHAR(MAX) ='AccountMOCUpload.xlsx'  
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
 
  -- SET @Timekey =(Select TimeKey from SysDataMatrix where CurrentStatus='C') 

  --SET @Timekey =(Select LastMonthDateKey from SysDayMatrix where Timekey=@Timekey)   
  SET @Timekey =(
  
  Select Timekey from SysDataMatrix Where MOC_Initialised='Y' AND ISNULL(MOC_Frozen,'N')='N'
  
  )
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


IF (@MenuID=24715)	
BEGIN

	  -- IF OBJECT_ID('tempdb..UploadAccMOCPool') IS NOT NULL  
	  IF OBJECT_ID('UploadAccMOCPool') IS NOT NULL  
	  BEGIN  
	   DROP TABLE UploadAccMOCPool  
	
	  END
	  
	  
  IF NOT (EXISTS (SELECT 1 FROM [AccountLvlMOCDetails_stg] where filname=@FilePathUpload))
 

BEGIN
print 'NO DATA1'
			Insert into dbo.MasterUploadData
			(SR_No,ColumnName,ErrorData,ErrorType,FileNames,Flag) 
			SELECT 0 SlNo , '' ColumnName,'No Record found' ErrorData,'No Record found' ErrorType,@filepath,'SUCCESS' 
			--SELECT 0 SlNo , '' ColumnName,'' ErrorData,'' ErrorType,@filepath,'SUCCESS' 

			goto errordata
    
END

ELSE
BEGIN
PRINT 'DATA PRESENT'
	   Select *, cast(''  as varchar(max))as SourceAlt_Key  ,CAST('' AS varchar(MAX)) ErrorMessage,CAST('' AS varchar(MAX)) ErrorinColumn,CAST('' AS varchar(MAX)) Srnooferroneousrows
 	   into UploadAccMOCPool 
	   from AccountLvlMOCDetails_stg 
	   WHERE filname=@FilePathUpload
	   
	   update A
	   set A.SourceAlt_Key = isnull( cast(B.SourceAlt_Key as varchar),'')
	   from UploadAccMOCPool A
	   INNER JOIN DIMSOURCEDB B 
	   ON A.SourceSystem = B.SourceName
	 
END		

--Sl. No.	Account ID	Additional Provision - Absolute in Rs.	Additional Provision %	Source System	MOC Type	MOC Source	MOC Reason	MOC Reason Remark

  ------------------------------------------------------------------------------  

	UPDATE UploadAccMOCPool
	SET  
        ErrorMessage='There is no data in excel. Kindly check and upload again' 
		,ErrorinColumn='SlNo,Account ID,POS,Interest Receivable,Balances,Dates'    
		,Srnooferroneousrows=''
 FROM [UploadAccMOCPool] V  
 WHERE ISNULL(SlNo,'')=''
AND ISNULL(AccountID,'')=''
AND ISNULL(AdditionalProvisionAbsoluteinRs,'')=''
AND Isnull(AdditionalProvision,'')=''
AND isnull(MOCType,'')=''
AND ISNULL(MOCSource,'')=''
AND ISNULL(MOCReason,'')='' 
And Isnull(SourceSystem,'')=''
ANd Isnull(MOCReasonRemark,'')=''        --Adde by kapil  on 28/11/2023



UPDATE UploadAccMOCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Sr No is present and remaining  excel file is blank. Please check and Upload again.'     
						ELSE ErrorMessage+','+SPACE(1)+'Sr No is present and remaining  excel file is blank. Please check and Upload again.'     END
	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Excel Vaildate ' ELSE   ErrorinColumn +','+SPACE(1)+'Excel Vaildate' END   
		,Srnooferroneousrows=''
	
   FROM [UploadAccMOCPool] V  
 WHERE ISNULL(SlNo,'')<>''
AND ISNULL(AccountID,'')=''
AND ISNULL(AdditionalProvisionAbsoluteinRs,'')=''
AND Isnull(AdditionalProvision,'')=''
AND isnull(MOCType,'')=''
AND ISNULL(MOCSource,'')=''
AND ISNULL(MOCReason,'')=''
And Isnull(SourceSystem,'')=''
ANd Isnull(MOCReasonRemark,'')=''        --Adde by kapil  on 28/11/2023


 IF EXISTS(SELECT 1 FROM UploadAccMOCPool WHERE ISNULL(ErrorMessage,'')<>'')
  BEGIN
  PRINT 'NO DATA'
  GOTO ERRORDATA;
  END


/*validations on SourceSystem*/
   UPDATE UploadAccMOCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Account ID not existing with Source System; Please check and upload again.'     
						ELSE ErrorMessage+','+SPACE(1)+'Account ID not existing with Source System; Please check and upload again.'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SourceSystem/AccountID' ELSE   ErrorinColumn +','+SPACE(1)+'SourceSystem/AccountID' END   
		,Srnooferroneousrows=V.AccountID	
   FROM UploadAccMOCPool V  
     Left join DIMSOURCEDB db on
           Db.SourceName=V.SourceSystem
   left JOIN AdvAcbasicdetail B 
   ON Db.SourceAlt_key = B.SourceAlt_Key 
   and V.AccountId = B.CustomerAcID
   AND B.EffectiveFromTimeKey<=@Timekey AND B.EffectiveToTimeKey>=@Timekey
 WHERE (ISNULL(Db.SourceName,'')='' 
 OR ISNULL(B.CustomerAcID,'')='')





  UPDATE UploadAccMOCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'SourceSystem Can not be Blank . Please enter the SourceSystem and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'SourceSystem Can not be Blank. Please enter the SourceSystem and upload again'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SourceSystem' ELSE   ErrorinColumn +','+SPACE(1)+'SourceSystem' END      
		,Srnooferroneousrows=V.SlNo


 FROM UploadAccMOCPool V  
 WHERE ISNULL(SourceSystem,'')='' 
   /*validations on SlNo*/
  
 Declare @DuplicateCnt int=0
   UPDATE UploadAccMOCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'SlNo cannot be blank . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'SlNo cannot be blank . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SlNo' ELSE   ErrorinColumn +','+SPACE(1)+'SlNo' END   
		,Srnooferroneousrows=V.SlNo
								
   
   FROM UploadAccMOCPool V  
 WHERE ISNULL(SlNo,'')='' or ISNULL(SlNo,'0')='0'


  UPDATE UploadAccMOCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'SlNo cannot be greater than 16 character . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'SlNo cannot be greater than 16 character . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SlNo' ELSE   ErrorinColumn +','+SPACE(1)+'SlNo' END   
		,Srnooferroneousrows=V.SlNo
								
   
   FROM UploadAccMOCPool V  
WHERE Len(SlNo)>16

  UPDATE UploadAccMOCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid Sl. No., kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid Sl. No., kindly check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SlNo' ELSE   ErrorinColumn +','+SPACE(1)+'SlNo' END   
		,Srnooferroneousrows=V.SlNo
								
   
   FROM UploadAccMOCPool V  
  WHERE (ISNUMERIC(SlNo)=0 AND ISNULL(SlNo,'')<>'') OR 
 ISNUMERIC(SlNo) LIKE '%^[0-9]%'

 UPDATE UploadAccMOCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Special characters not allowed, kindly remove and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Special characters not allowed, kindly remove and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SlNo' ELSE   ErrorinColumn +','+SPACE(1)+'SlNo' END   
		,Srnooferroneousrows=V.SlNo
								
   
   FROM UploadAccMOCPool V  
   WHERE ISNULL(SlNo,'') LIKE'%[,!@#$%^&*()_-+=/]%- \ / _'

   --
  SELECT @DuplicateCnt=Count(1)
FROM UploadAccMOCPool
GROUP BY  SlNo
HAVING COUNT(SlNo) >1;

IF (@DuplicateCnt>0)

 UPDATE UploadAccMOCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Duplicate Sl. No., kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Duplicate Sl. No., kindly check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SlNo' ELSE   ErrorinColumn +','+SPACE(1)+'SlNo' END   
		,Srnooferroneousrows=V.SlNo
								
   
   FROM UploadAccMOCPool V  
   Where ISNULL(SlNo,'') In(  
   SELECT SlNo
	FROM UploadAccMOCPool
	GROUP BY  SlNo
	HAVING COUNT(SlNo) >1

)

/*VALIDATIONS ON AccountID */

  UPDATE UploadAccMOCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'The column ‘Account ID’ is mandatory. Kindly check and upload again'     
					ELSE ErrorMessage+','+SPACE(1)+'The column ‘Account ID’ is mandatory. Kindly check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Account ID' ELSE ErrorinColumn +','+SPACE(1)+  'Account ID' END  
		,Srnooferroneousrows=V.SlNo
--								----STUFF((SELECT ','+SlNo 
--								----FROM UploadAccMOCPool A
--								----WHERE A.SlNo IN(SELECT V.SlNo FROM UploadAccMOCPool V  
--								----				WHERE ISNULL(ACID,'')='' )
--								----FOR XML PATH ('')
--								----),1,1,'')   

FROM UploadAccMOCPool V  
 WHERE ISNULL(AccountID,'')='' 
 

-- ----SELECT * FROM UploadAccMOCPool
  
  UPDATE UploadAccMOCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid Account ID found. Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid Account ID found. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Account ID' ELSE ErrorinColumn +','+SPACE(1)+  'Account ID' END  
		,Srnooferroneousrows=V.SlNo
  
		FROM UploadAccMOCPool V  
 WHERE ISNULL(V.AccountID,'')<>''
 AND V.AccountID NOT IN(SELECT CustomerACID FROM AdvAcBasicDetail
								WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
						 )


 IF OBJECT_ID('TEMPDB..#DUB2') IS NOT NULL
 DROP TABLE #DUB2

 SELECT * INTO #DUB2 FROM(
 SELECT *,ROW_NUMBER() OVER(PARTITION BY AccountID ORDER BY AccountID ) as rw  FROM UploadAccMOCPool
 )X
 WHERE rw>1


 UPDATE V
	SET  
        ErrorMessage=CASE WHEN ISNULL(V.ErrorMessage,'')='' THEN  'Duplicate Account ID found. Please check the values and upload again'     
						ELSE V.ErrorMessage+','+SPACE(1)+'Duplicate Account ID found. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(V.ErrorinColumn,'')='' THEN 'Account ID' ELSE V.ErrorinColumn +','+SPACE(1)+  'Account ID' END  
		,Srnooferroneousrows=V.SlNo
  
		FROM UploadAccMOCPool V 
		INNer JOIN #DUB2 D ON D.AccountID=V.AccountID



		---------------------Authorization for Screen Same acc ID --------------------------

UPDATE UploadAccMOCPool
	SET  
  ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'You cannot perform MOC, Record is pending for authorization for this Account ID. Kindly authorize or Reject the record through ‘Account Level NPA MOC – Authorization’ menu'     
						ELSE ErrorMessage+','+SPACE(1)+'You cannot perform MOC, Record is pending for authorization for this Account ID. Kindly authorize or Reject the record through ‘Account Level NPA MOC – Authorization’ menu'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Account ID' ELSE ErrorinColumn +','+SPACE(1)+  'Account ID' END  
		,Srnooferroneousrows=V.SlNo
  
		FROM UploadAccMOCPool V  
 WHERE ISNULL(V.AccountID,'')<>''
 AND V.AccountID  IN (SELECT Distinct AccountID FROM AccountlevelMOC_MOD
								WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
								AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A') and ISNULL(Screenflag,'') <> 'U'
						 )
---------------------------------------------------------------------------Upload for same account ID--------------
UPDATE UploadAccMOCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'You cannot perform MOC, Record is pending for authorization for this Account ID. Kindly authorize or Reject the record through ‘Account Level NPA MOC Upload– Authorization’ menu'     
						ELSE ErrorMessage+','+SPACE(1)+'You cannot perform MOC, Record is pending for authorization for this Account ID. Kindly authorize or Reject the record through ‘Account Level NPA MOC Upload– Authorization’ menu'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Account ID' ELSE ErrorinColumn +','+SPACE(1)+  'Account ID' END  
		,Srnooferroneousrows=V.SlNo
  
		FROM UploadAccMOCPool V  
 WHERE ISNULL(V.AccountID,'')<>''
 AND V.AccountID  IN (SELECT Distinct AccountID FROM AccountlevelMOC_MOD
								WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
								AND AuthorisationStatus in ('NP','MP','1A','FM') and ISNULL(Screenflag,'') = 'U'
						 )

---------------------------------------


------------------------------MOC_Reason_Remark------------------
 --------------------Newly added by kapil on 28/11/2023------------------------------------------------


  UPDATE UploadAccMOCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'MOCReasonRemark Can not be Blank for MOCReason is equal to Other. Please enter the MOCReasonRemark and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'MOCReasonRemark Can not be Blank for MOCReason is equal to Other. Please enter the MOCReasonRemark and upload again'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'MOCReasonRemark' ELSE   ErrorinColumn +','+SPACE(1)+'MOCReasonRemark' END      
		,Srnooferroneousrows=V.MOCReasonRemark

 FROM UploadAccMOCPool V  
 WHERE ISNULL(Rtrim(Ltrim(v.MOCReasonRemark)),'')=''  
 and isnull(Rtrim(trim(v.MOCReason)),'') ='Other' 

   UPDATE UploadAccMOCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'MOCReasonRemark  cannot be greater than 150 characters for MOCReason is equal to Other.'     
						ELSE ErrorMessage+','+SPACE(1)+ 'MOCReasonRemark  cannot be greater than 150 characters for MOCReason is equal to Other.'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'MOCReasonRemark' ELSE   ErrorinColumn +','+SPACE(1)+'MOCReasonRemark' END      
		,Srnooferroneousrows=V.MOCReasonRemark

 FROM UploadAccMOCPool V  
 WHERE ISNULL(Rtrim(Ltrim(v.MOCReasonRemark)),'')<>''  
 and isnull(Rtrim(trim(v.MOCReason)),'') ='Other' 
 And LEN(v.MOCReasonRemark)>150



   UPDATE UploadAccMOCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'MOCReasonRemark is blank for MOCReason  is not equal to Other.'     
						ELSE ErrorMessage+','+SPACE(1)+ 'MOCReasonRemark is blank for MOCReason is not equal to Other.'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'MOCReasonRemark' ELSE   ErrorinColumn +','+SPACE(1)+'MOCReasonRemark' END      
		,Srnooferroneousrows=V.MOCReasonRemark

 FROM UploadAccMOCPool V  
 WHERE ISNULL(Rtrim(Ltrim(v.MOCReasonRemark)),'')<>'' 
 and isnull(Rtrim(trim(v.MOCReason)),'') <>'Other' 

 -----------------------------------------------------------Above Newly added by kapil on 28/11/2023----------------------------



 -----------------------------/*validations on Additional Provision - Absolute in Rs. */
 UPDATE UploadAccMOCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid AdditionalProvisionAbsoluteinRs. Please check the values and upload again'     
					ELSE ErrorMessage+','+SPACE(1)+'Invalid AdditionalProvisionAbsoluteinRs. Please check the values and upload again'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'AdditionalProvisionAbsoluteinRs' ELSE ErrorinColumn +','+SPACE(1)+  'AdditionalProvisionAbsoluteinRs' END  
		,Srnooferroneousrows=V.AdditionalProvisionAbsoluteinRs


 FROM UploadAccMOCPool V  
 WHERE (ISNUMERIC(AdditionalProvisionAbsoluteinRs)=0 AND ISNULL(AdditionalProvisionAbsoluteinRs,'')<>'') OR 
 ISNUMERIC(AdditionalProvisionAbsoluteinRs) LIKE '%^[0-9]%'

 PRINT 'INVALID' 

 UPDATE UploadAccMOCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid AdditionalProvisionAbsoluteinRs doesnot allowed Special Charactor. Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid AdditionalProvisionAbsoluteinRs doesnot allowed Special Charactor. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'AdditionalProvisionAbsoluteinRs' ELSE ErrorinColumn +','+SPACE(1)+  'AdditionalProvisionAbsoluteinRs' END  
		,Srnooferroneousrows=V.AdditionalProvisionAbsoluteinRs


 FROM UploadAccMOCPool V  
 WHERE ISNULL(AdditionalProvisionAbsoluteinRs,'') LIKE'%[,!@#$%^&*()_-+=/]%'

  UPDATE UploadAccMOCPool
	SET  
        ErrorMessage= CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid AdditionalProvisionAbsoluteinRs. Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid AdditionalProvisionAbsoluteinRs. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'AdditionalProvisionAbsoluteinRs' ELSE ErrorinColumn +','+SPACE(1)+  'AdditionalProvisionAbsoluteinRs' END  
		,Srnooferroneousrows=V.AdditionalProvisionAbsoluteinRs

 FROM UploadAccMOCPool V  
WHERE ISNULL(AdditionalProvisionAbsoluteinRs,'')<>''
AND (CHARINDEX('.',ISNULL(AdditionalProvisionAbsoluteinRs,''))>0 
AND Len(Right(ISNULL(AdditionalProvisionAbsoluteinRs,''),Len(ISNULL(AdditionalProvisionAbsoluteinRs,''))-CHARINDEX('.',ISNULL(AdditionalProvisionAbsoluteinRs,''))))<>2)

---------------------------------MOC Source---------------------------

 

 UPDATE UploadAccMOCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid value in column ‘MOC Source’. Kindly enter the values as mentioned in the ‘MOC Source’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid value in column ‘MOC Source’. Kindly enter the values as mentioned in the ‘MOC Source’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'MOCSource' ELSE   ErrorinColumn +','+SPACE(1)+'MOCSource' END      
		,Srnooferroneousrows=V.MOCSource


 FROM UploadAccMOCPool V  
 left JOIN  DimMOCType a 
 on v.MOCSOURCE = A.MOCTypeName
 WHERE A.MOCTypeName is NULL



 -----------------------------------
 -----------------------------------MOC Reason-------------------------

 
  Declare @ValidReasonnt int=0

	
	IF OBJECT_ID(N'tempdb..#MocReasonDataM') IS NOT NULL
	--IF OBJECT_ID('MocSourceData') IS NOT NULL  
	  BEGIN  
	   DROP TABLE #MocReasonDataM  
	
	  END

	  --Select * from #MocReasonDataM

SELECT * into #MocReasonDataM  FROM(
 SELECT ROW_NUMBER() OVER(PARTITION BY MOCReason  ORDER BY  MOCReason ) 
 ROW ,MOCReason FROM UploadAccMOCPool
)X
 WHERE ROW=1


   SELECT  @ValidReasonnt=COUNT(*) FROM #MocReasonDataM A

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
	         UPDATE UploadAccMOCPool 
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid value in column ‘MOC Source’. Kindly enter the values as mentioned in the ‘MOC Source’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid value in column ‘MOC Source’. Kindly enter the values as mentioned in the ‘MOC Source’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'     END  
        ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'MOCSOURCE' ELSE   ErrorinColumn +','+SPACE(1)+'MOCSOURCE' END     
		,Srnooferroneousrows=V.MOCSOURCE

		 FROM UploadAccMOCPool V  
 WHERE ISNULL(MOCReason,'')<>''
 AND  V.MOCReason IN(
			 SELECT A.MOCReason FROM #MocReasonDataM A
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

	IF OBJECT_ID(N'tempdb..#MocReasonDataM') IS NOT NULL 
	  BEGIN  
	   DROP TABLE #MocReasonDataM  	
	  END
 
 UPDATE UploadAccMOCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'MOC Reason Can not be Blank . Please enter the MOC Reason and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'MOC Reason Can not be Blank. Please enter the MOC Reason and upload again'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'MOCReason' ELSE   ErrorinColumn +','+SPACE(1)+'MOCReason' END      
		,Srnooferroneousrows=V.SlNo


 FROM UploadAccMOCPool V  
 WHERE ISNULL(MOCReason,'')='' 

 
 UPDATE UploadAccMOCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'MOC reason cannot be greater than 500 characters'     
						ELSE ErrorMessage+','+SPACE(1)+ 'MOC reason cannot be greater than 500 characters'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'MOCReason' ELSE   ErrorinColumn +','+SPACE(1)+'MOCReason' END      
		,Srnooferroneousrows=V.SlNo


 FROM UploadAccMOCPool V  
 WHERE LEN(MOCReason)>500
 
  UPDATE UploadAccMOCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'For MOC reason column, special characters - , /\ are allowed. Kindly check and try again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'For MOC reason column, special characters - , /\ are allowed. Kindly check and try again'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'MOCReason' ELSE   ErrorinColumn +','+SPACE(1)+'MOCReason' END      
		,Srnooferroneousrows=V.SlNo


 FROM UploadAccMOCPool V  
 WHERE LEN(MOCReason) LIKE '%[!@#$%^&*()_+=]%'




 --------------------
 -----------------MOCType---------------------


	  UPDATE UploadAccMOCPool
	SET  
        ErrorMessage =CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'MOCType is mandatory . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'MOCType is mandatory . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'MOCType' ELSE   ErrorinColumn +','+SPACE(1)+'MOCType' END   
		,Srnooferroneousrows=V.SlNo							  
   FROM UploadAccMOCPool V  
  WHERE ISNULL(MOCType,'')=''

  UPDATE UploadAccMOCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'MOC Type column will only accept value – Auto or Manual. '     
						ELSE ErrorMessage+','+SPACE(1)+'MOC Type column will only accept value – Auto or Manual. '     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'MOCType' ELSE   ErrorinColumn +','+SPACE(1)+'MOCType' END   
		,Srnooferroneousrows=V.SlNo
							
   
   FROM UploadAccMOCPool V  
 WHERE ISNULL(v.MOCType,'') NOT IN('Auto','Manual')




 -----------------MOCType---------------------


	--  UPDATE UploadAccMOCPool
	--SET  
 --       ErrorMessage =CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'MOCType is mandatory . Please check the values and upload again'     
	--					ELSE ErrorMessage+','+SPACE(1)+'MOCType is mandatory . Please check the values and upload again'     END
	--	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'MOCType' ELSE   ErrorinColumn +','+SPACE(1)+'MOCType' END   
	--	,Srnooferroneousrows=V.SlNo							  
 --  FROM UploadAccMOCPool V  
 -- WHERE ISNULL(MOCType,'')=''

 -- UPDATE UploadAccMOCPool
	--SET  
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'MOC Type column will only accept value – Auto or Manual. Kindly check and upload again'     
	--					ELSE ErrorMessage+','+SPACE(1)+'MOC Type column will only accept value – Auto or Manual. Kindly check and upload again'     END
	--	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'MOCType' ELSE   ErrorinColumn +','+SPACE(1)+'MOCType' END   
	--	,Srnooferroneousrows=V.SlNo
							
   
 --  FROM UploadAccMOCPool V  
 --WHERE ISNULL(v.MOCType,'') NOT IN('Auto','Manual')

 -----------------------------------------------------------------------------



-- ---------------------------------AdditionalProvision------------

--------------Additional Provision%-----------------
 
--AND (CHARINDEX('.',ISNULL(AdditionalProvision,''))>0  AND Len(Right(ISNULL(AdditionalProvision,''),Len(ISNULL(AdditionalProvision,''))-CHARINDEX('.',ISNULL(AdditionalProvision,''))))<>2)


  UPDATE UploadAccMOCPool
	SET  
        ErrorMessage= CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid values in ‘Additional Provision %’. Additional Provision % greater than zero and less than or equal to 100.'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid values in ‘Additional Provision %’. Additional Provision % greater than zero and less than or equal to 100.'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Additional Provision%' ELSE ErrorinColumn +','+SPACE(1)+  'Additional Provision%' END  
		,Srnooferroneousrows=V.SlNo
--							

 FROM UploadAccMOCPool V  
 WHERE ISNULL([AdditionalProvision],'')<>''
 AND Convert(Decimal(5,2),ISNULL(AdditionalProvision,'0'))>100

UPDATE UploadAccMOCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid values in ‘Additional Provision %’. Kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid values in ‘Additional Provision %’. Kindly check and upload again '    END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Additional Provision%' ELSE   ErrorinColumn +','+SPACE(1)+'Additional Provision%' END   
		,Srnooferroneousrows=V.SlNo
								
   
   FROM UploadAccMOCPool V  
   WHERE (ISNUMERIC(AdditionalProvision)=0 AND ISNULL(AdditionalProvision,'')<>'') OR 
 ISNUMERIC(AdditionalProvision) LIKE '%^[0-9]%'


 UPDATE UploadAccMOCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid values in ‘Additional Provision ’. Kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid values in ‘Additional Provision ’. Kindly check and upload again '    END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Additional Provision' ELSE   ErrorinColumn +','+SPACE(1)+'Additional Provision' END   
		,Srnooferroneousrows=V.SlNo
								
   
   FROM UploadAccMOCPool V  
   WHERE (CHARINDEX('.',AdditionalProvision))>0


--Select * from UploadAccMOCPool

    UPDATE UploadAccMOCPool                                                                   ---------- newly adde by kapi as per Vivek discussion on date 01/03/2024
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Upload either ‘Additional Provision’ or ‘AdditionalProvisionAbsoluteinRs’, Kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Upload either ‘Additional Provision’ or ‘AdditionalProvisionAbsoluteinRs’, Kindly check and upload again'    END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Additional Provision,AdditionalProvisionAbsoluteinRs' ELSE   ErrorinColumn +','+SPACE(1)+'Additional Provision,AdditionalProvisionAbsoluteinRs' END   
		,Srnooferroneousrows=V.SlNo
								
   
   FROM UploadAccMOCPool V  
   WHERE isnull(AdditionalProvision,'')<>'' and isnull(AdditionalProvisionAbsoluteinRs,'')<>''


 -----------------------------------------------------------------














 
 Print '123'
 goto valid

  END
	
   ErrorData:  
   print 'no'  

		SELECT *,'Data'TableName
		FROM dbo.MasterUploadData WHERE FileNames=@filepath 
		return

   valid:
		IF NOT EXISTS(Select 1 from  AccountLvlMOCDetails_stg WHERE filname=@FilePathUpload)
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
			FROM UploadAccMOCPool


			
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
		 IF EXISTS(SELECT 1 FROM AccountLvlMOCDetails_stg WHERE filname=@FilePathUpload)
		 BEGIN
		 Print 'Delete stage table'
		 DELETE FROM AccountLvlMOCDetails_stg
		 WHERE filname=@FilePathUpload
		 
		 PRINT 1

		 PRINT 'ROWS DELETED FROM DBO.AccountLvlMOCDetails_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
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

	--print 'p'
 -- ----to delete file if it has errors
	--	if exists(Select  1 from dbo.MasterUploadData where FileNames=@filepath and ISNULL(ErrorData,'')<>'')
	--	begin
	--	print 'ppp'
	--	 IF EXISTS(SELECT 1 FROM CustlevelNPAMOCDetails_stg WHERE filname=@FilePathUpload)
	--	 BEGIN
	--	 print '123'
	--	 DELETE FROM CustlevelNPAMOCDetails_stg
	--	 WHERE filname=@FilePathUpload

	--	 PRINT 'ROWS DELETED FROM DBO.CustlevelNPAMOCDetails_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
	--	 END
	--	 END

   
END  TRY
  
  BEGIN CATCH
	

	INSERT INTO dbo.Error_Log
				SELECT ERROR_LINE() as ErrorLine,ERROR_MESSAGE()ErrorMessage,ERROR_NUMBER()ErrorNumber
				,ERROR_PROCEDURE()ErrorProcedure,ERROR_SEVERITY()ErrorSeverity,ERROR_STATE()ErrorState
				,GETDATE()

	IF EXISTS(SELECT 1 FROM AccountLvlMOCDetails_stg WHERE filname=@FilePathUpload)
		 BEGIN
		 DELETE FROM AccountLvlMOCDetails_stg WHERE filname=@FilePathUpload
		 

		 PRINT 'ROWS DELETED FROM DBO.CustlevelNPAMOCDetails_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
		 END

END CATCH

END
GO