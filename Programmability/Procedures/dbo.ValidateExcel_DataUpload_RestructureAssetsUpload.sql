SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[ValidateExcel_DataUpload_RestructureAssetsUpload]  
@MenuID INT=10,  
@UserLoginId  VARCHAR(20)='fnachecker',  
@Timekey INT=49999
,@filepath VARCHAR(MAX) ='IBPCUPLOAD.xlsx'  
WITH RECOMPILE  
AS  
  

  
BEGIN

BEGIN TRY  

     
	 SET DATEFORMAT DMY


 Set  @Timekey=(select CAST(B.timekey as int)from SysDataMatrix A
                    Inner Join SysDayMatrix B ON A.TimeKey=B.TimeKey
                       where A.CurrentStatus='C')

Declare @SysDate date
Set @SysDate =(Select Cast(Date  as date) from SysDayMatrix where TimeKey=@timekey) 

  PRINT @Timekey  
  
    
  
  DECLARE @FilePathUpload	VARCHAR(100)

			SET @FilePathUpload=@UserLoginId+'_'+@filepath
	PRINT '@FilePathUpload'
	PRINT @FilePathUpload

	IF EXISTS(SELECT 1 FROM dbo.MasterUploadData    where FileNames=@filepath )
	BEGIN
		Delete from dbo.MasterUploadData    where FileNames=@filepath  
		print @@rowcount
	END


IF (@MenuID=24714)	
BEGIN

  -----------------SELECT * FROM RestructuredAssetsUpload_stg
	  -- IF OBJECT_ID('tempdb..RestructureAssets') IS NOT NULL  
	  IF OBJECT_ID('RestructureAssets') IS NOT NULL  
	  BEGIN  
	  Print ' DROP TABLE RestructureAssets  '
	   DROP TABLE RestructureAssets  
	
	  END
	  
  IF NOT (EXISTS (SELECT 1 FROM RestructuredAssetsUpload_stg where filname=@FilePathUpload))
  ----update RestructuredAssetsUpload_stg set filname='2ndlvlchecker_RestructuredAssetsUpload.xlsx'
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
 	   into RestructureAssets 
	   from RestructuredAssetsUpload_stg 
	   WHERE filname=@FilePathUpload

  
END



  ------------------------------------------------------------------------------  

	UPDATE RestructureAssets
	SET  
        ErrorMessage='There is no data in excel. Kindly check and upload again' 
		,ErrorinColumn='SrNo,AccountID,BankingRelationship,InvocationDate, DateofRestructuring,RestructuringApprovingAuth,
		      TypeofRestructuring,AssetClassatRstrctr,NPADate,NPAIdentificationDate,PrinRpymntStartDate,InttRpymntStartDate,DPDasonDateofRestructure,
			  OSasonDateofRstrctr,POSasonDateofRstrctr,DFVProvisionRs'    
		,Srnooferroneousrows=''
 FROM RestructureAssets V  
 WHERE ISNULL(SrNo,'')=''
AND ISNULL(AccountID,'')=''
AND ISNULL(BankingRelationship,'')=''
AND ISNULL(InvocationDate,'')=''
AND ISNULL(DateofRestructuring,'')=''
AND ISNULL(RestructuringApprovingAuth,'')=''
AND ISNULL(TypeofRestructuring,'')=''
AND ISNULL(AssetClassatRstrctr,'')=''
AND ISNULL(NPADate,'')=''
And Isnull(NPAIdentificationDate,'')=''   -----New
AND ISNULL(PrinRpymntStartDate,'')=''
AND ISNULL(InttRpymntStartDate,'')=''
AND isnull(DPDasonDateofRestructure,'')=''-----New
AND ISNULL(OSasonDateofRstrctr,'')=''
AND ISNULL(POSasonDateofRstrctr,'')=''
AND ISNULL(DFVProvisionRs,'')=''

	UPDATE RestructureAssets
	SET  
        ErrorMessage='There is no data in excel other than SrNo column. Kindly check and upload again' 
		,ErrorinColumn='AccountID,BankingRelationship,InvocationDate, DateofRestructuring,RestructuringApprovingAuth,
		      TypeofRestructuring,AssetClassatRstrctr,NPADate,NPAIdentificationDate,PrinRpymntStartDate,InttRpymntStartDate,DPDasonDateofRestructure,
			  OSasonDateofRstrctr,POSasonDateofRstrctr,DFVProvisionRs'    
		,Srnooferroneousrows=''
 FROM RestructureAssets V  
 WHERE ISNULL(SrNo,'')<>''
AND ISNULL(AccountID,'')=''
AND ISNULL(BankingRelationship,'')=''
AND ISNULL(InvocationDate,'')=''
AND ISNULL(DateofRestructuring,'')=''
AND ISNULL(RestructuringApprovingAuth,'')=''
AND ISNULL(TypeofRestructuring,'')=''
AND ISNULL(AssetClassatRstrctr,'')=''
AND ISNULL(NPADate,'')=''
And Isnull(NPAIdentificationDate,'')=''   -----New
AND ISNULL(PrinRpymntStartDate,'')=''
AND ISNULL(InttRpymntStartDate,'')=''
AND isnull(DPDasonDateofRestructure,'')=''-----New
AND ISNULL(OSasonDateofRstrctr,'')=''
AND ISNULL(POSasonDateofRstrctr,'')=''
AND ISNULL(DFVProvisionRs,'')=''

--AND ISNULL(RestructureFacility,'')=''--
--AND ISNULL(RevisedBusinessSeg,'')='' --
--AND ISNULL(DisbursementDate,'')=''--
--AND ISNULL(ReferenceDate,'')=''--
--AND ISNULL(DateofConversionintoEquity,'')=''--
--AND ISNULL(NPAQuarter,'')=''--
--AND ISNULL(CovidMoratoriamMSME,'')=''--
--AND ISNULL(CovidOTRCategory,'')=''--
--AND ISNULL(DateofIstDefaultonCRILIC,'')=''--
--AND ISNULL(ReportingBank,'')=''--
--AND ISNULL(DateofSigningICA,'')=''--
--AND ISNULL(InvestmentGrade,'')=''--
--AND ISNULL(CreditProvisionRs,'')=''--
--AND ISNULL(MTMProvisionRs,'')=''--


  IF EXISTS(SELECT 1 FROM RestructureAssets WHERE ISNULL(ErrorMessage,'')<>'')
  BEGIN
  PRINT 'NO DATA'
  GOTO ERRORDATA;
  END

----------------  --------        SRNo      --------------

     UPDATE RestructureAssets
	    SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'SrNo cannot be blank . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'SrNo cannot be blank . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' ELSE   ErrorinColumn +','+SPACE(1)+'SrNo' END   
		,Srnooferroneousrows=V.SrNo								  
         FROM RestructureAssets V  
         WHERE ISNULL(SrNo,'')='' or ISNULL(SrNo,'0')='0'

-------
Declare @DuplicateCnt Int=0
    SELECT @DuplicateCnt=Count(1)
FROM RestructureAssets
GROUP BY  SrNo
HAVING COUNT(SrNo) >1;

IF (@DuplicateCnt>0)

 UPDATE RestructureAssets
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Duplicate SrNo, kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Duplicate SrNo, kindly check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' ELSE   ErrorinColumn +','+SPACE(1)+'SrNo' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM RestructureAssets V  
   Where ISNULL(SrNo,'') In(  
   SELECT SrNo
	FROM RestructureAssets
	GROUP BY  SrNo
	HAVING COUNT(SrNo) >1

)

--------
  UPDATE RestructureAssets
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid SrNo, kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid SrNo, kindly check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' ELSE   ErrorinColumn +','+SPACE(1)+'SrNo' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM RestructureAssets V  
  WHERE (ISNUMERIC(SrNo)=0 AND ISNULL(SrNo,'')<>'') OR 
 ISNUMERIC(SrNo) LIKE '%^[0-9]%'
---------
 UPDATE RestructureAssets
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Special characters not allowed, kindly remove and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Special characters not allowed, kindly remove and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' ELSE   ErrorinColumn +','+SPACE(1)+'SrNo' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM RestructureAssets V  
   WHERE ISNULL(SrNo,'') LIKE'%[,!@#$%^&*()_-+=/]%- \ / _'
---------


--------------      -----------------AccountID -----------      ----------
  UPDATE RestructureAssets
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Account ID cannot be blank.  Please check the values and upload again'     
					ELSE ErrorMessage+','+SPACE(1)+'Account ID cannot be blank.  Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Account ID' ELSE ErrorinColumn +','+SPACE(1)+  'Account ID' END  
		,Srnooferroneousrows=V.SRNO


FROM RestructureAssets V  
 WHERE ISNULL(AccountID,'')='' 

 ----------
  UPDATE RestructureAssets
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid Account ID found. Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid Account ID found. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Account ID' ELSE ErrorinColumn +','+SPACE(1)+  'Account ID' END  
		,Srnooferroneousrows=V.SRNO
  
		FROM RestructureAssets V  
 WHERE ISNULL(V.AccountID,'')<>''
 AND V.AccountID NOT IN(SELECT CustomerACID FROM [CurDat].[AdvAcBasicDetail] 
								WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey)


------------

 IF OBJECT_ID('TEMPDB..#DUB2') IS NOT NULL
 DROP TABLE #DUB2

 SELECT * INTO #DUB2 FROM(
 SELECT *,ROW_NUMBER() OVER(PARTITION BY AccountID ORDER BY AccountID ) as rw  FROM RestructureAssets
 )X
 WHERE rw>1

 Print 'A9'
 UPDATE V
	SET  
        ErrorMessage=CASE WHEN ISNULL(V.ErrorMessage,'')='' THEN  'Duplicate Account ID found. Please check the values and upload again'     
						ELSE V.ErrorMessage+','+SPACE(1)+'Duplicate Account ID found. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(V.ErrorinColumn,'')='' THEN 'Account ID' ELSE V.ErrorinColumn +','+SPACE(1)+  'Account ID' END  
		,Srnooferroneousrows=V.SRNO
  
		FROM RestructureAssets V 
		INNer JOIN #DUB2 D ON D.AccountID=V.AccountID

---------
UPDATE RestructureAssets
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Account ID are pending for authorization'     
						ELSE ErrorMessage+','+SPACE(1)+'Account ID are pending for authorization'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Account ID' ELSE ErrorinColumn +','+SPACE(1)+  'Account ID' END  
		,Srnooferroneousrows=V.SRNO
  
		FROM RestructureAssets V  
 WHERE ISNULL(V.AccountID,'')<>''
 AND V.AccountID  IN (SELECT AccountID FROM RestructureAsset_Upload_Mod
								WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
								AND AuthorisationStatus in ('NP','MP','1A','FM')
						 )

--------------
--------------     -------------- BankingRelationship -----------      ---------------

  UPDATE RestructureAssets
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Banking Relationship cannot be blank . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Banking Relationship cannot be blank . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Banking Relationship' ELSE   ErrorinColumn +','+SPACE(1)+'Banking Relationship' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM RestructureAssets V  
 WHERE ISNULL(BankingRelationship,'')=''

 ------
   UPDATE RestructureAssets
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid Banking Relationship.  Please check the values 
		With Sole Banking OR Multiple Banking OR Consortium OR Consortium-WC OR Consortium-TL OR WC-MBA OR TL-MBA and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid Banking Relationship.  Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Banking Relationship' ELSE   ErrorinColumn +','+SPACE(1)+'Banking Relationship' END       
		,Srnooferroneousrows=V.SrNo 

   FROM RestructureAssets V  
   WHERE BankingRelationship  NOT in  ('Sole Banking' , 'Multiple Banking','Consortium','Consortium-WC','Consortium-TL','WC-MBA','TL-MBA')


------------     ------------      InvocationDate                -----------------

UPDATE RestructureAssets
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'InvocationDate Can not be Blank . Please enter the InvocationDate and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'InvocationDate Can not be Blank. Please enter the InvocationDate and upload again'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'InvocationDate' ELSE   ErrorinColumn +','+SPACE(1)+'InvocationDate' END      
		,Srnooferroneousrows=V.SrNo
		  

 FROM RestructureAssets V  
 WHERE ISNULL(InvocationDate,'')='' 


 UPDATE RestructureAssets
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid Input. Please enter the date in format ‘dd-mm-yyyy’'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid Input. Please enter the date in format ‘dd-mm-yyyy’'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'InvocationDate' ELSE   ErrorinColumn +','+SPACE(1)+'InvocationDate' END      
		,Srnooferroneousrows=V.SrNo
	  

 FROM RestructureAssets V  
 WHERE ISNULL(InvocationDate,'')<>'' AND ISDATE(InvocationDate)=0



 ------
   UPDATE RestructureAssets
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid InvocationDate fotmat. Please enter the date in format ‘dd-mm-yyyy’'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid InvocationDate fotmat. Please enter the date in format ‘dd-mm-yyyy’'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'InvocationDate' ELSE   ErrorinColumn +','+SPACE(1)+'InvocationDate' END      
		,Srnooferroneousrows=V.SrNo	  
 FROM RestructureAssets V  
 WHERE ISNULL(InvocationDate,'')<>'' AND ISDATE(InvocationDate)<>0 and InvocationDate not like '[0-3][0-9]/[0-1][0-9]/[0-2][0-9][0-9][0-9]'


    UPDATE RestructureAssets
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'InvocationDate shoud not be greater than SystemDate.'     
						ELSE ErrorMessage+','+SPACE(1)+ 'InvocationDate shoud not be greater than SystemDate’'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'InvocationDate' ELSE   ErrorinColumn +','+SPACE(1)+'InvocationDate' END      
		,Srnooferroneousrows=V.SrNo	  
 FROM RestructureAssets V  
 WHERE ISNULL(InvocationDate,'')<>'' AND 
     Case When ISDATE(InvocationDate)<>0 Then  case  When cast(InvocationDate as date)>Cast(@SysDate as Date) then 1 END End in (1)


--------------     --------- DateofRestructuring---------
Print 'DateofRestructuring1'
 UPDATE RestructureAssets
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'DateofRestructuring Can not be Blank . Please enter the InvocationDate and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'DateofRestructuring Can not be Blank . Please enter the InvocationDate and upload again'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'DateofRestructuring' ELSE   ErrorinColumn +','+SPACE(1)+'DateofRestructuring' END      
		,Srnooferroneousrows=V.SrNo	  

 FROM RestructureAssets V  
 WHERE ISNULL(DateofRestructuring,'')='' 


 Print 'DateofRestructuring2'
UPDATE RestructureAssets
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid  Data. Please enter the date in format ‘dd-mm-yyyy’'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid  Data. Please enter the date in format ‘dd-mm-yyyy’'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'DateofRestructuring' ELSE   ErrorinColumn +','+SPACE(1)+'DateofRestructuring' END      
		,Srnooferroneousrows=V.SrNo
	  

 FROM RestructureAssets V  
 WHERE ISNULL(DateofRestructuring,'')<>'' AND ISDATE(DateofRestructuring)<>1


 ----
    UPDATE RestructureAssets
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid DateofRestructuring fotmat. Please enter the date in format ‘dd-mm-yyyy’'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid DateofRestructuring fotmat. Please enter the date in format ‘dd-mm-yyyy’'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'DateofRestructuring' ELSE   ErrorinColumn +','+SPACE(1)+'DateofRestructuring' END      
		,Srnooferroneousrows=V.SrNo	  
 FROM RestructureAssets V  
 WHERE ISNULL(DateofRestructuring,'')<>'' AND ISDATE(DateofRestructuring)<>0 and DateofRestructuring not like '[0-3][0-9]/[0-1][0-9]/[0-2][0-9][0-9][0-9]'

-------
    UPDATE RestructureAssets
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'DateofRestructuring Should be equal to  System Date. '     
						ELSE ErrorMessage+','+SPACE(1)+ 'DateofRestructuring Should  be equal to System Date.'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'InvocationDate' ELSE   ErrorinColumn +','+SPACE(1)+'InvocationDate' END      
		,Srnooferroneousrows=V.SrNo	  
 FROM RestructureAssets V  
 WHERE ISNULL(DateofRestructuring,'')<>'' AND 
    ( Case When ISDATE(DateofRestructuring)<>0 Then  
	                                            case  When cast(DateofRestructuring as date)<>Cast(@SysDate as Date) then 1 Else 0 END End) in (1)


-----------    -----------			RestructuringApprovingAuth									-----------


 UPDATE RestructureAssets
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'For Restructuring Approving Auth column, special characters -  /\ are allowed. Kindly check and try again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'For Restructuring Approving Auth, special characters -  /\ are allowed. Kindly check and try again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Restructuring Approving Auth' ELSE ErrorinColumn +','+SPACE(1)+  'Restructuring Approving Auth' END  
		,Srnooferroneousrows=V.SrNo
 FROM RestructureAssets V  
 WHERE  ISNULL(RestructuringApprovingAuth,'') LIKE'%[!@#$%^&*(),_+=]%' 



  UPDATE RestructureAssets
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Length of  Restructuring Approving Auth column shoud not greater than 250,  Kindly check and try again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Length of  Restructuring Approving Auth column shoud not greater than 250,  Kindly check and try again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Restructuring Approving Auth' ELSE ErrorinColumn +','+SPACE(1)+  'Restructuring Approving Auth' END  
		,Srnooferroneousrows=V.SrNo
 FROM RestructureAssets V  
 WHERE  ISNULL(RestructuringApprovingAuth,'') <>'' And  Len(RestructuringApprovingAuth)>250



 --------    -------------/*validations on Type of Restructuring*/
    
  
  UPDATE RestructureAssets
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Type of Restructuring cannot be blank . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Type of Restructuring cannot be blank . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Type of Restructuring' ELSE   ErrorinColumn +','+SPACE(1)+'Type of Restructuring' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM RestructureAssets V  
 WHERE ISNULL(TypeofRestructuring,'')=''


----------

  UPDATE RestructureAssets
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Length of Type of Restructuring Shoud not be greater than 50 . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Length of Type of Restructuring Shoud not be greater than 50  . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Type of Restructuring' ELSE   ErrorinColumn +','+SPACE(1)+'Type of Restructuring' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM RestructureAssets V  
 WHERE ISNULL(TypeofRestructuring,'')<>'' and Len(TypeofRestructuring)>50


------------
 IF OBJECT_ID(N'tempdb..#TypeofRestructuring') IS NOT NULL
	--IF OBJECT_ID('MocSourceData') IS NOT NULL  
	  BEGIN  
	   DROP TABLE #TypeofRestructuring  
	
	  END

 Declare @ValidReasonnt_1 int=0	

SELECT * into #TypeofRestructuring  FROM(
 SELECT ROW_NUMBER() OVER(PARTITION BY TypeofRestructuring  ORDER BY  TypeofRestructuring ) 
 ROW ,TypeofRestructuring FROM RestructureAssets
)X
 WHERE ROW=1


   SELECT  @ValidReasonnt_1=COUNT(*) FROM #TypeofRestructuring A

 Left JOIN
 (select ParameterAlt_Key,
			 ParameterName 
			 ,'TypeofRestructuring' as TableName
			 from DimParameter
			 where EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey and
			  DimParameterName='TypeofRestructuring') B
 ON  A.TypeofRestructuring=B.ParameterName
 Where B.ParameterName IS NULL


   IF @ValidReasonnt_1>0
     BEGIN
	         UPDATE RestructureAssets  
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid value in column ‘RestructureFacility ’. Kindly enter the values as mentioned in the ‘DimParameter’ master and upload again.'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid value in column ‘RestructureFacility’. Kindly enter the values as mentioned in the ‘DimParameter’ master and upload again. '     END  
        ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'RestructureFacility' ELSE   ErrorinColumn +','+SPACE(1)+'RestructureFacility' END     
		,Srnooferroneousrows=V.SrNo

		 FROM RestructureAssets V  
 WHERE ISNULL(TypeofRestructuring,'')<>''
 AND  V.TypeofRestructuring IN(
			 SELECT A.TypeofRestructuring FROM #TypeofRestructuring A
						 Left JOIN
						 (select ParameterAlt_Key,
									 ParameterName 
									 ,'TypeofRestructuring' as TableName
									 from DimParameter
									 where --EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey and
									  DimParameterName	= 'TypeofRestructuring'
									  
									  ) B
						 ON  A.TypeofRestructuring=B.ParameterName
						 Where B.ParameterName IS NULL
				 )

	 END


--------------     -------------/// Asset Class at Rstrctr  ////-------------

UPDATE RestructureAssets
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'AssetClassatRstrctr Can not be Blank . Please enter the AssetClassatRstrctr and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'AssetClassatRstrctr Can not be Blank. Please enter the AssetClassatRstrctr and upload again'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'AssetClassatRstrctr' ELSE   ErrorinColumn +','+SPACE(1)+'AssetClassatRstrctr' END      
		,Srnooferroneousrows=V.SrNo
		  

 FROM RestructureAssets V  
 WHERE ISNULL(AssetClassatRstrctr,'')='' 
--------
 UPDATE RestructureAssets
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Length of AssetClassatRstrctr can not be greater than 15 character . Please enter the  and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Length of AssetClassatRstrctr can not be greater than 15 character. Please enter the AssetClassatRstrctr and upload again'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'AssetClassatRstrctr' ELSE   ErrorinColumn +','+SPACE(1)+'AssetClassatRstrctr' END      
		,Srnooferroneousrows=V.SrNo
		  
 FROM RestructureAssets V  
 WHERE ISNULL(AssetClassatRstrctr,'')<>''  AND Len(AssetClassatRstrctr)>15
 --------

  IF OBJECT_ID(N'tempdb..#AssetClassatRstrctr') IS NOT NULL
	--IF OBJECT_ID('MocSourceData') IS NOT NULL  
	  BEGIN  
	   DROP TABLE #AssetClassatRstrctr  
	
	  END

 Declare @ValidReasonnt_2 int=0	

SELECT * into #AssetClassatRstrctr  FROM(
 SELECT ROW_NUMBER() OVER(PARTITION BY AssetClassatRstrctr  ORDER BY  AssetClassatRstrctr ) 
 ROW ,AssetClassatRstrctr FROM RestructureAssets
)X
 WHERE ROW=1


   SELECT  @ValidReasonnt_2=COUNT(*) FROM #AssetClassatRstrctr A

 Left JOIN
 (select AssetClassName
			 
			 from DimAssetClass
			 where EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey 
			 ) B
 ON  A.AssetClassatRstrctr=B.AssetClassName
 Where B.AssetClassName IS NULL


   IF @ValidReasonnt_2>0
     BEGIN
	         UPDATE RestructureAssets  
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid value in column ‘AssetClassatRstrctr ’. Kindly enter the values as mentioned in the ‘DimAssetClass’ master and upload again.'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid value in column ‘AssetClassatRstrctr’. Kindly enter the values as mentioned in the ‘DimAssetClass’ master and upload again. '     END  
        ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'AssetClassatRstrctr' ELSE   ErrorinColumn +','+SPACE(1)+'AssetClassatRstrctr' END     
		,Srnooferroneousrows=V.SrNo

		 FROM RestructureAssets V  
 WHERE ISNULL(AssetClassatRstrctr,'')<>''
 AND  V.AssetClassatRstrctr IN(
			 SELECT A.AssetClassatRstrctr FROM #AssetClassatRstrctr A
						 Left JOIN
						 (select AssetClassName
		
									 from DimAssetClass
									 where EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey 
									  ) B
						 ON  A.AssetClassatRstrctr=B.AssetClassName
						 Where B.AssetClassName IS NULL
				 )

	 END
--------        -----------       //  NPADate  //  -------

UPDATE RestructureAssets
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid data. Please enter the date in format ‘dd-mm-yyyy’'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid data. Please enter the date in format ‘dd-mm-yyyy’'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'NPADate' ELSE   ErrorinColumn +','+SPACE(1)+'NPADate' END      
		,Srnooferroneousrows=V.SrNo
	  

 FROM RestructureAssets V  
 WHERE ISNULL(NPADate,'')<>'' AND ISDATE(NPADate)=0

-------
 UPDATE RestructureAssets
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid date Format. Please enter the date in format ‘dd-mm-yyyy’'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid date Format. Please enter the date in format ‘dd-mm-yyyy’'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'NPADate' ELSE   ErrorinColumn +','+SPACE(1)+'NPADate' END      
		,Srnooferroneousrows=V.SrNo
	  

 FROM RestructureAssets V  
 WHERE ISNULL(NPADate,'')<>'' AND ISDATE(NPADate)=1 And NPADate Not like '[0-3][0-9]/[0-1][0-9]/[0-2][0-9][0-9][0-9]'




  UPDATE RestructureAssets
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Please Enter NPA date if AssetClassatRstrctr is other than STANDARD. Please enter the date in format ‘dd-mm-yyyy’'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Please Enter NPA date if AssetClassatRstrctr is other than STANDARD. Please enter the date in format ‘dd-mm-yyyy’'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'NPADate' ELSE   ErrorinColumn +','+SPACE(1)+'NPADate' END      
		,Srnooferroneousrows=V.SrNo
	  

 FROM RestructureAssets V  
 WHERE ISNULL(NPADate,'')<>'' AND isnull(AssetClassatRstrctr,'')='STANDARD'




     UPDATE RestructureAssets
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Date of NPA Should Be Lower Than Date of System'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Date of NPA Should Be Lower Than Date of System'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'NPADate' ELSE   ErrorinColumn +','+SPACE(1)+'NPADate' END      
		,Srnooferroneousrows=V.SrNo	  
 FROM RestructureAssets V  
 WHERE ISNULL(NPADate,'')<>'' AND 
    ( Case When ISDATE(NPADate)<>0 Then  
	                                            case  When cast(NPADate as date)>Cast(@SysDate as Date) then 1 Else 0 END End) in (1)


 ----------------------------------NPAIdentificationDate

 
UPDATE RestructureAssets
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid data of NPAIdentificationDate. Please enter the date in format ‘dd-mm-yyyy’'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid data of NPAIdentificationDate. Please enter the date in format ‘dd-mm-yyyy’'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'NPAIdentificationDate' ELSE   ErrorinColumn +','+SPACE(1)+'NPAIdentificationDate' END      
		,Srnooferroneousrows=V.SrNo
	  

 FROM RestructureAssets V  
 WHERE ISNULL(NPAIdentificationDate,'')<>'' AND ISDATE(NPAIdentificationDate)=0

-------
 UPDATE RestructureAssets
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid date Format. Please enter the date in format ‘dd-mm-yyyy’'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid date Format. Please enter the date in format ‘dd-mm-yyyy’'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'NPAIdentificationDate' ELSE   ErrorinColumn +','+SPACE(1)+'NPAIdentificationDate' END      
		,Srnooferroneousrows=V.SrNo
	  

 FROM RestructureAssets V  
 WHERE ISNULL(NPAIdentificationDate,'')<>'' AND ISDATE(NPAIdentificationDate)=1 And NPAIdentificationDate Not like '[0-3][0-9]/[0-1][0-9]/[0-2][0-9][0-9][0-9]'


  UPDATE RestructureAssets
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Please Enter NPA date if NPAIdentificationDate is other than STANDARD. Please enter the date in format ‘dd-mm-yyyy’'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Please Enter NPA date if NPAIdentificationDate is other than STANDARD. Please enter the date in format ‘dd-mm-yyyy’'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'NPADate' ELSE   ErrorinColumn +','+SPACE(1)+'NPADate' END      
		,Srnooferroneousrows=V.SrNo
	  

 FROM RestructureAssets V  
 WHERE ISNULL(NPAIdentificationDate,'')='' AND isnull(AssetClassatRstrctr,'')<>'STANDARD'


 ------
     UPDATE RestructureAssets
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'NPAIdentificationDate Should Be Lower Than Date of System'     
						ELSE ErrorMessage+','+SPACE(1)+ 'NPAIdentificationDate Should Be Lower Than Date of System'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'NPAIdentificationDate' ELSE   ErrorinColumn +','+SPACE(1)+'NPAIdentificationDate' END      
		,Srnooferroneousrows=V.SrNo	  
 FROM RestructureAssets V  
 WHERE ISNULL(NPAIdentificationDate,'')<>'' AND 
    ( Case When ISDATE(NPAIdentificationDate)<>0 Then  
	                                            case  When cast(NPAIdentificationDate as date)>Cast(@SysDate as Date) then 1 Else 0 END End) in (1)

 -----------------      ---//      PrinRpymntStartDate   // -------------------
 Print 'PrinRpymntStartDate1'
 UPDATE RestructureAssets
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'PrinRpymntStartDate Can not be Blank . Please enter the PrinRpymntStartDate and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'PrinRpymntStartDate Can not be Blank. Please enter the PrinRpymntStartDate and upload again'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'PrinRpymntStartDate' ELSE   ErrorinColumn +','+SPACE(1)+'PrinRpymntStartDate' END      
		,Srnooferroneousrows=V.SrNo
		  

 FROM RestructureAssets V  
 WHERE ISNULL(PrinRpymntStartDate,'')='' 

 --------
  Print 'PrinRpymntStartDate2'
 UPDATE RestructureAssets
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid data for PrinRpymntStartDate . Please enter the date in format ‘dd-mm-yyyy’'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid date for PrinRpymntStartDate. Please enter the date in format ‘dd-mm-yyyy’'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'PrinRpymntStartDate' ELSE   ErrorinColumn +','+SPACE(1)+'PrinRpymntStartDate' END      
		,Srnooferroneousrows=V.SrNo
	  

 FROM RestructureAssets V  
 WHERE ISNULL(PrinRpymntStartDate,'')<>'' AND ISDATE(PrinRpymntStartDate)=0

 ------
  Print 'PrinRpymntStartDate3'
  UPDATE RestructureAssets
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid date Format. Please enter the date in format ‘dd-mm-yyyy’'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid date Format. Please enter the date in format ‘dd-mm-yyyy’'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'PrinRpymntStartDate' ELSE   ErrorinColumn +','+SPACE(1)+'PrinRpymntStartDate' END      
		,Srnooferroneousrows=V.SrNo
	  

 FROM RestructureAssets V  
 WHERE ISNULL(PrinRpymntStartDate,'')<>'' AND ISDATE(PrinRpymntStartDate)=1 And PrinRpymntStartDate Not like '[0-3][0-9]/[0-1][0-9]/[0-2][0-9][0-9][0-9]'


 ------
  Print 'PrinRpymntStartDate4'
  UPDATE RestructureAssets
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid data.PrinRpymntStartDate should not older than DateofRestructuring'     --Changed on 22/01/2024
						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid Data.PrinRpymntStartDate should not older than DateofRestructuring'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'PrinRpymntStartDate' ELSE   ErrorinColumn +','+SPACE(1)+'PrinRpymntStartDate' END      
		,Srnooferroneousrows=V.SrNo
	  

 FROM RestructureAssets V  
  WHERE (Case When ISDATE(PrinRpymntStartDate)=1 and Isdate(DateofRestructuring)=1 Then 
                          Case When Cast(PrinRpymntStartDate as date)<Cast(DateofRestructuring as Date) Then 1 
                                Else 0 END END) in(1)




--------      -=--------       //   InttRpymntStartDate    //   --------------------- 
 Print 'InttRpymntStartDate1'
UPDATE RestructureAssets
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'InttRpymntStartDate Can not be Blank . Please enter the InttRpymntStartDate and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'InttRpymntStartDate Can not be Blank. Please enter the InttRpymntStartDate and upload again'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'InttRpymntStartDate' ELSE   ErrorinColumn +','+SPACE(1)+'InttRpymntStartDate' END      
		,Srnooferroneousrows=V.SrNo
		  

 FROM RestructureAssets V  
  WHERE ISNULL(InttRpymntStartDate,'')='' 
--------
 Print 'InttRpymntStartDate2'
  UPDATE RestructureAssets
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid data. Please enter the InttRpymntStartDate Correctly'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid data. Please enter the InttRpymntStartDate Correctly'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'InttRpymntStartDate' ELSE   ErrorinColumn +','+SPACE(1)+'InttRpymntStartDate' 

END      
		,Srnooferroneousrows=V.SrNo
	  

 FROM RestructureAssets V  
 WHERE ISNULL(InttRpymntStartDate,'')<>'' AND ISDATE(InttRpymntStartDate)=0

 ---------
  Print 'InttRpymntStartDate3'
  UPDATE RestructureAssets
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid date Format. Please enter the InttRpymntStartDate in format ‘dd-mm-yyyy’'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid date Format. Please enter the InttRpymntStartDate in format ‘dd-mm-yyyy’'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'InttRpymntStartDate' ELSE   ErrorinColumn +','+SPACE(1)+'InttRpymntStartDate' END      
		,Srnooferroneousrows=V.SrNo
	  

 FROM RestructureAssets V  
 WHERE ISNULL(InttRpymntStartDate,'')<>'' AND ISDATE(InttRpymntStartDate)=1 And InttRpymntStartDate Not like '[0-3][0-9]/[0-1][0-9]/[0-2][0-9][0-9][0-9]'

 -------
  Print 'InttRpymntStartDate4'
 --  UPDATE RestructureAssets
	--SET  
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid data.InttRpymntStartDate should not less than NPA Date'     
	--					ELSE ErrorMessage+','+SPACE(1)+ 'Invalid Data.InttRpymntStartDate should not less than NPA Date'      END
	--	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'InttRpymntStartDate' ELSE   ErrorinColumn +','+SPACE(1)+'InttRpymntStartDate' END      
	--	,Srnooferroneousrows=V.SrNo
	  

 --FROM RestructureAssets V  
 -- WHERE (Case When ISDATE(InttRpymntStartDate)=1 and isdate(NPADate)=1 Then 
 --                         Case When Cast(InttRpymntStartDate as date)<Cast(NPADate as Date) Then 1 
 --                               Else 0 END END) in(1)

   Print 'InttRpymntStartDate4'
   UPDATE RestructureAssets
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid data.InttRpymntStartDate should not older than DateofRestructuring'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid Data.InttRpymntStartDate should not older than DateofRestructuring'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'InttRpymntStartDate' ELSE   ErrorinColumn +','+SPACE(1)+'InttRpymntStartDate' END      
		,Srnooferroneousrows=V.SrNo
	  

 FROM RestructureAssets V  
  WHERE (Case When ISDATE(InttRpymntStartDate)=1 and isdate(DateofRestructuring)=1 Then 
                          Case When Cast(InttRpymntStartDate as date)<Cast(DateofRestructuring as Date) Then 1 
                                Else 0 END END) in(1)                                                                               --Changed on 22/01/2024





-----------			------------       //	 DPDasonDateofRestructure		//	----------

Print 'DPDasonDateofRestructure1'
UPDATE RestructureAssets
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'DPDasonDateofRestructure Can not be Blank . Please enter the DPDasonDateofRestructure and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'DPDasonDateofRestructure Can not be Blank. Please enter the DPDasonDateofRestructure and upload again'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'DPDasonDateofRestructure' ELSE   ErrorinColumn +','+SPACE(1)+'DPDasonDateofRestructure' END      
		,Srnooferroneousrows=V.SrNo
		  

 FROM RestructureAssets V  
  WHERE ISNULL(DPDasonDateofRestructure,'')='' 

  -----

    UPDATE RestructureAssets
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'DPDasonDateofRestructure is Numeric fild, kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'DPDasonDateofRestructure is Numeric fild, kindly check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'DPDasonDateofRestructure' ELSE   ErrorinColumn +','+SPACE(1)+'DPDasonDateofRestructure' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM RestructureAssets V  
  WHERE (ISNUMERIC(DPDasonDateofRestructure)=0 AND ISNULL(DPDasonDateofRestructure,'')<>'') OR 
 ISNUMERIC(DPDasonDateofRestructure) LIKE '%^[0-9]%'



     UPDATE RestructureAssets
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'DPDasonDateofRestructure should not be a floating value because it is a numerical file. kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'DPDasonDateofRestructure should not be a floating value because it is a numerical file, kindly check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'DPDasonDateofRestructure' ELSE   ErrorinColumn +','+SPACE(1)+'DPDasonDateofRestructure' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM RestructureAssets V  
  WHERE (ISNUMERIC(DPDasonDateofRestructure)=0 AND ISNULL(DPDasonDateofRestructure,'')<>'') 
   Or CHARINDEX('.',DPDasonDateofRestructure)<>0
  






--------   -------------    //   OSasonDateofRstrctr   //  ---------   

Print 'OSasonDateofRstrct1'
UPDATE RestructureAssets
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'OSasonDateofRstrctr Can not be Blank . Please enter the ‘OSasonDateofRstrctr’ and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'OSasonDateofRstrctr Can not be Blank . Please enter the ‘OSasonDateofRstrctr’ and upload again'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'OSasonDateofRstrctr' ELSE   ErrorinColumn +','+SPACE(1)+'OSasonDateofRstrctr' END      
		,Srnooferroneousrows=V.SrNo
	  

 FROM RestructureAssets V  
 WHERE ISNULL(OSasonDateofRstrctr,'')='' 

----------
Print 'OSasonDateofRstrct2'
    UPDATE RestructureAssets
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'OSasonDateofRstrctr is Numeric fild, kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'OSasonDateofRstrctr is Numeric fild, kindly check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'OSasonDateofRstrctr' ELSE   ErrorinColumn +','+SPACE(1)+'OSasonDateofRstrctr' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM RestructureAssets V  
  WHERE (ISNUMERIC(OSasonDateofRstrctr)=0 AND ISNULL(OSasonDateofRstrctr,'')<>'') OR 
 ISNUMERIC(OSasonDateofRstrctr) LIKE '%^[0-9]%'


--------
Print 'OSasonDateofRstrct3'

  UPDATE RestructureAssets
	SET  
        ErrorMessage= CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid OSasonDateofRstrctr. Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid OSasonDateofRstrctr. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'OSasonDateofRstrctr' ELSE ErrorinColumn +','+SPACE(1)+  'OSasonDateofRstrctr' END  
		,Srnooferroneousrows=V.OSasonDateofRstrctr

 FROM RestructureAssets V  
WHERE ISNULL(OSasonDateofRstrctr,'')<>''
AND (CHARINDEX('.',ISNULL(OSasonDateofRstrctr,''))>0 
AND Len(Right(ISNULL(OSasonDateofRstrctr,''),Len(ISNULL(OSasonDateofRstrctr,''))-CHARINDEX('.',ISNULL(OSasonDateofRstrctr,''))))<>2)



--------   -------------        //     POSasonDateofRstrctr   //---------

Print 'POSasonDateofRstrctr1'
UPDATE RestructureAssets
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'POSasonDateofRstrctr Can not be Blank . Please enter the ‘POSasonDateofRstrctr’ and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'POSasonDateofRstrctr Can not be Blank . Please enter the ‘POSasonDateofRstrctr’ and upload again'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'POSasonDateofRstrctr' ELSE   ErrorinColumn +','+SPACE(1)+'POSasonDateofRstrctr' END      
		,Srnooferroneousrows=V.SrNo
	  

 FROM RestructureAssets V  
 WHERE ISNULL(POSasonDateofRstrctr,'')='' 

----------
Print 'POSasonDateofRstrctr2'
    UPDATE RestructureAssets
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'POSasonDateofRstrctr is Numeric fild, kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'POSasonDateofRstrctr is Numeric fild, kindly check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'POSasonDateofRstrctr' ELSE   ErrorinColumn +','+SPACE(1)+'POSasonDateofRstrctr' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM RestructureAssets V  
  WHERE (ISNUMERIC(POSasonDateofRstrctr)=0 AND ISNULL(POSasonDateofRstrctr,'')<>'') OR 
 ISNUMERIC(POSasonDateofRstrctr) LIKE '%^[0-9]%'

 ---------
 Print 'POSasonDateofRstrctr3'
  UPDATE RestructureAssets
	SET  
        ErrorMessage= CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid POSasonDateofRstrctr. Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid POSasonDateofRstrctr. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'POSasonDateofRstrctr' ELSE ErrorinColumn +','+SPACE(1)+  'POSasonDateofRstrctr' END  
		,Srnooferroneousrows=V.SrNo

 FROM RestructureAssets V  
WHERE ISNULL(POSasonDateofRstrctr,'')<>''
AND (CHARINDEX('.',ISNULL(POSasonDateofRstrctr,''))>0 
AND Len(Right(ISNULL(POSasonDateofRstrctr,''),Len(ISNULL(POSasonDateofRstrctr,''))-CHARINDEX('.',ISNULL(POSasonDateofRstrctr,''))))<>2)


-------  ---------   //      DFVProvisionRs   //  ----------

Print 'DFVProvisionRs1'
    UPDATE RestructureAssets
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'DFVProvisionRs is Numeric fild, kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'DFVProvisionRs is Numeric fild, kindly check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'DFVProvisionRs' ELSE   ErrorinColumn +','+SPACE(1)+'DFVProvisionRs' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM RestructureAssets V  
  WHERE (ISNUMERIC(DFVProvisionRs)=0 AND ISNULL(DFVProvisionRs,'')<>'') OR 
 ISNUMERIC(DFVProvisionRs) LIKE '%^[0-9]%'

 ---------
 Print 'DFVProvisionRs2'
  UPDATE RestructureAssets
	SET  
        ErrorMessage= CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid DFVProvisionRs. Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid DFVProvisionRs. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'DFVProvisionRs' ELSE ErrorinColumn +','+SPACE(1)+  'DFVProvisionRs' END  
		,Srnooferroneousrows=V.SrNo

 FROM RestructureAssets V  
WHERE ISNULL(DFVProvisionRs,'')<>''
AND (CHARINDEX('.',ISNULL(DFVProvisionRs,''))>0 
AND Len(Right(ISNULL(DFVProvisionRs,''),Len(ISNULL(DFVProvisionRs,''))-CHARINDEX('.',ISNULL(DFVProvisionRs,''))))<>2)







 Print '123'
 goto valid

  END


	
   ErrorData:  
   print 'no'  

		SELECT *,'Data'TableName
		FROM dbo.MasterUploadData WHERE FileNames=@filepath 
		return

   valid:
		IF NOT EXISTS(Select 1 from  RestructuredAssetsUpload_stg WHERE filname=@FilePathUpload)
		BEGIN
		PRINT 'NO ERRORS'
			
			Insert into dbo.MasterUploadData
			(SR_No,ColumnName,ErrorData,ErrorType,FileNames,Flag) 
			SELECT '' SRNO , '' ColumnName,'' ErrorData,'' ErrorType,@filepath,'SUCCESS' 
			
		END
		ELSE
		BEGIN
			PRINT 'VALIDATION ERRORS'
			print @filepath
			Insert into dbo.MasterUploadData
			(SR_No,ColumnName,ErrorData,ErrorType,FileNames,Srnooferroneousrows,Flag) 
			SELECT SrNo,ErrorinColumn,ErrorMessage,ErrorinColumn,@filepath,Srnooferroneousrows,'SUCCESS' 
			FROM RestructureAssets 
			
			goto final;
		END

		

  IF EXISTS (SELECT 1 FROM  dbo.MasterUploadData   WHERE FileNames=@filepath AND  ISNULL(ERRORDATA,'')<>'')     -- added for delete Upload status while error while uploading data.  

       BEGIN  
       
        delete from UploadStatus where FileNames=@filepath  
       END  


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

		 IF EXISTS(SELECT 1 FROM RestructuredAssetsUpload_stg WHERE filname=@FilePathUpload)
		 BEGIN
		 DELETE FROM RestructuredAssetsUpload_stg
		 WHERE filname=@FilePathUpload

		 PRINT 1

		 PRINT 'ROWS DELETED FROM DBO.RestructuredAssetsUpload_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
		 END

	END
	ELSE
	      BEGIN
	      PRINT ' DATA is valid and  PRESENT'
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

	----SELECT * FROM RestructureAssets

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

	IF EXISTS(SELECT 1 FROM RestructuredAssetsUpload_stg WHERE filname=@FilePathUpload)
		 BEGIN
		 DELETE FROM RestructuredAssetsUpload_stg
		 WHERE filname=@FilePathUpload

		 PRINT 'ROWS DELETED FROM DBO.RestructuredAssetsUpload_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
		 END

END CATCH

END

GO