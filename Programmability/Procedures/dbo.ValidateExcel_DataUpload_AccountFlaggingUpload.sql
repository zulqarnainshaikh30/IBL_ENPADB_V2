SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[ValidateExcel_DataUpload_AccountFlaggingUpload]  
--Declare
@MenuID INT=1470,  
@UserLoginId  VARCHAR(20)='lvl2admin',  
@Timekey INT=26959
,@filepath VARCHAR(MAX) ='ExceptionDegUpload (2).xlsx'  
,@UploadTypeParameterAlt_Key Int=1
WITH RECOMPILE  
AS   

  
BEGIN

BEGIN TRY  
	 SET DATEFORMAT DMY

 
 Select   @Timekey=Max(Timekey) from sysDayMatrix where Cast(date as Date)=cast(getdate() as Date)

  PRINT @Timekey  
 print 'swapna20'
  
  DECLARE @FilePathUpload VARCHAR(100)

			SET @FilePathUpload=@UserLoginId+'_'+@filepath
	        PRINT '@FilePathUpload'
	        PRINT @FilePathUpload

	IF EXISTS(SELECT 1 FROM dbo.MasterUploadData    where FileNames=@filepath )
	BEGIN
		Delete from dbo.MasterUploadData where FileNames=@filepath  
		print @@rowcount
	END

print 'swapna21'
IF (@MenuID=1470)	
BEGIN  

	    IF OBJECT_ID('TwoAc') IS NOT NULL  
	  BEGIN  
	   DROP TABLE TwoAc  
	
	  END
	  print 'swapna22' 

IF NOT (EXISTS (SELECT 1 FROM AccountFlagging_Stg where filname=@FilePathUpload))

BEGIN
print 'NO DATA'
			Insert into dbo.MasterUploadData
			(SR_No,ColumnName,ErrorData,ErrorType,FileNames,Flag)  
			SELECT 0 SRNO , '' ColumnName,'No Record found' ErrorData,'No Record found' ErrorType,@filepath,'SUCCESS' 

			goto errordata 
END  
---------------------------
ELSE
BEGIN  
PRINT 'DATA PRESENT'
	   Select *,CAST('' AS varchar(MAX)) ErrorMessage,CAST('' AS varchar(MAX)) ErrorinColumn,CAST('' AS varchar(MAX)) Srnooferroneousrows
 	   into TwoAc 
	   from AccountFlagging_Stg 
	   WHERE filname=@FilePathUpload --select * from AccountFlagging_Stg
END



	--SrNo	Territory	ACID	InterestReversalAmount	filname
print 'swapna24'

UPDATE TwoAc
SET  
 ErrorMessage='There is no data in excel. Kindly check and upload again' 
,ErrorinColumn='ACID,Amount,Date,Action'    
,Srnooferroneousrows=''
 FROM TwoAc V  
 WHERE ISNULL(ACID,'')='' 
 AND ISNULL(Amount,'')='' 
 AND ISNULL(Date,'')='' 
 AND ISNULL(Action,'')='' 


   print 'swapna25'
  IF EXISTS(SELECT 1 FROM TwoAc WHERE ISNULL(ErrorMessage,'')<>'')
  BEGIN
  PRINT 'NO DATA'
  GOTO ErrorData;
  END 

   UPDATE TwoAc
	SET  
        ErrorMessage=   CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'SlNo cannot be blank . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'SlNo cannot be blank . Please check the values and upload again'     END
		,ErrorinColumn= CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SlNo' ELSE   ErrorinColumn +','+SPACE(1)+'SlNo' END   
		,Srnooferroneousrows=V.SrNo  
   
 FROM TwoAc V  
 WHERE ISNULL(SrNo,'')='' or ISNULL(SrNo,'0')='0'




  



  UPDATE TwoAc
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'SlNo cannot be greater than 16 character . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'SlNo cannot be greater than 16 character . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SlNo' ELSE   ErrorinColumn +','+SPACE(1)+'SlNo' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM TwoAc V  
WHERE Len(SrNo)>16

  UPDATE TwoAc
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid Sl. No., kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid Sl. No., kindly check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SlNo' ELSE   ErrorinColumn +','+SPACE(1)+'SlNo' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM TwoAc V  
  WHERE (ISNUMERIC(SrNo)=0 AND ISNULL(SrNo,'')<>'') OR 
 ISNUMERIC(SrNo) LIKE '%^[0-9]%'


 UPDATE TwoAc
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Special characters not allowed, kindly remove and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Special characters not allowed, kindly remove and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SlNo' ELSE   ErrorinColumn +','+SPACE(1)+'SlNo' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM TwoAc V  
   WHERE ISNULL(SrNo,'') LIKE'%[,!@#$%^&*()_-+=/]%- \ / _'

   --
   Declare @DuplicateCnt int=0
  SELECT @DuplicateCnt=Count(1)
FROM TwoAc
GROUP BY  SrNo
HAVING COUNT(SrNo) >1;

IF (@DuplicateCnt>0)

 UPDATE TwoAc
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Duplicate Sl. No., kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Duplicate Sl. No., kindly check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SlNo' ELSE   ErrorinColumn +','+SPACE(1)+'SlNo' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM TwoAc V  
   Where ISNULL(SrNo,'') In(  
   SELECT SrNo
	FROM TwoAc
	GROUP BY  SrNo
	HAVING COUNT(SrNo) >1

)


 ------------------------------------------------
 /*VALIDATIONS ON AccountID */  --LIne [261-346]

  UPDATE TwoAc
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'The column ‘Account ID’ is mandatory. Kindly check and upload again'     
					ELSE ErrorMessage+','+SPACE(1)+'The column ‘Account ID’ is mandatory. Kindly check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Account ID' ELSE ErrorinColumn +','+SPACE(1)+  'Account ID' END  
		,Srnooferroneousrows=V.SrNo


FROM TwoAc V  
 WHERE ISNULL(ACID,'')='' 
 

-- ----SELECT * FROM UploadAccMOCPool
  
  UPDATE TwoAc
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid Account ID found. Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid Account ID found. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Account ID' ELSE ErrorinColumn +','+SPACE(1)+  'Account ID' END  
		,Srnooferroneousrows=V.SrNo
  
		FROM TwoAc V  
 WHERE ISNULL(V.ACID,'')<>''
 AND V.ACID NOT IN(SELECT CustomerACID FROM AdvAcBasicDetail
								WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
						 )


 IF OBJECT_ID('TEMPDB..#DUB2') IS NOT NULL
 DROP TABLE #DUB2

 SELECT * INTO #DUB2 FROM(
 SELECT *,ROW_NUMBER() OVER(PARTITION BY ACID ORDER BY ACID ) as rw  FROM TwoAc
 )X
 WHERE rw>1


 --Select * from TwoAc

 UPDATE V
	SET  
        ErrorMessage=CASE WHEN ISNULL(V.ErrorMessage,'')='' THEN  'Duplicate Account ID found. Please check the values and upload again'     
						ELSE V.ErrorMessage+','+SPACE(1)+'Duplicate Account ID found. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(V.ErrorinColumn,'')='' THEN 'Account ID' ELSE V.ErrorinColumn +','+SPACE(1)+  'Account ID' END  
		,Srnooferroneousrows=V.SrNo
  
		FROM TwoAc V 
		INNer JOIN #DUB2 D ON D.ACID=V.ACID

						
---------------------Authorization for Screen Same acc ID --------------------------

UPDATE TwoAc
	SET  

  ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Record is pending for authorization for this Account ID. Kindly authorize or Reject the record through ExceptionalDegradation upload screen'     

						ELSE ErrorMessage+','+SPACE(1)+'Record is pending for authorization for this Account ID. Kindly authorize or Reject the record through ExceptionalDegradation upload screen'     END

		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Account ID' ELSE ErrorinColumn +','+SPACE(1)+  'Account ID' END  
		,Srnooferroneousrows=V.SrNo
  
		FROM TwoAc V  
 WHERE ISNULL(V.ACID,'')<>''
 AND V.ACID  IN (SELECT Distinct ACID FROM AccountFlaggingDetails_Mod
								WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
								AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A') --and ISNULL(Screenflag,'') <> 'U'
						 )
---------------------------------------------------------------------------Upload for same account ID--------------
UPDATE TwoAc
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Record is pending for authorization for this Account ID. Kindly authorize or Reject the record through Exception Degradation Assets menu'     
						ELSE ErrorMessage+','+SPACE(1)+'Record is pending for authorization for this Account ID. Kindly authorize or Reject the record through Exception Degradation Assets menu'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'ACID' ELSE ErrorinColumn +','+SPACE(1)+  'ACID' END  
		,Srnooferroneousrows=V.SrNo
  
		FROM TwoAc V  
 WHERE ISNULL(V.ACID,'')<>''
 AND V.ACID  IN (SELECT Distinct AccountID FROM ExceptionalDegrationDetail_Mod
								WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
								AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A') --and ISNULL(Screenflag,'') = 'U'
						 )

---------------------------------------
---------------------------------------------- Line [348 to 419]
 /*validations on Date*/



   UPDATE TwoAc
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid date format. Please enter the valid date,its not a date ’'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid date format. Please enter the valid date,its not a date’'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Date' ELSE   ErrorinColumn +','+SPACE(1)+'Date' END   
		,Srnooferroneousrows=V.SrNo

  FROM TwoAc V  
 WHERE ISNULL(Date,'')<>''and isdate(Date)=0  

 
 UPDATE TwoAc
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid date format. Please enter the date in format ‘dd/mm/yyyy’'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid date format. Please enter the date in format ‘dd/mm/yyyy’'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Date' ELSE   ErrorinColumn +','+SPACE(1)+'Date' END   
		,Srnooferroneousrows=V.SrNo

  FROM TwoAc V  
 WHERE isdate(Date) = 1  AND  [Date] not Like '[0-3][0-9]/[0-1][0-9]/[1-2][0-9][0-9][0-9]'
  
  
  UPDATE TwoAc
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'DATE cannot be blank . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'DATE cannot be blank . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Date' ELSE   ErrorinColumn +','+SPACE(1)+'Date' END   
		,Srnooferroneousrows=V.SrNo

   FROM TwoAc V  
 WHERE ISNULL(Date,'')=''





 print 'Swapna'
  SET DATEFORMAT DMY

   UPDATE TwoAc
	SET  

        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'It should not be the current date and the future date. Kindly verify and upload.'     

						ELSE ErrorMessage+','+SPACE(1)+ 'It should not be the current date and the future date. Kindly verify and upload.'     END

		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Date' ELSE   ErrorinColumn +','+SPACE(1)+'Date' END   
		,Srnooferroneousrows=V.SrNo

   
 FROM TwoAc V  
 WHERE ISNULL(Date,'')<>'' and  isdate(V.Date)=1
 and (convert(Date, date)) >= convert(Date, getdate())
 --and ISNULL(convert(varchar(10), date,103),'') > convert(varchar(10), getdate(),103)
--------------------------------------------------------------


/*------SrNo Validation----Vinit---*/
  UPDATE TwoAc
	SET  
     ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Sr. No. Can not be blank'     
						ELSE ErrorMessage+','+SPACE(1)+'Sr. No. Can not be blank'     
				  END
	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' 
						ELSE ErrorinColumn +','+SPACE(1)+  'SrNo' 
				   END   
 FROM TwoAc V  
 WHERE ISNULL(V.SrNo,'')=''



-- ----SELECT * FROM TwoAc
  /*------Account ID Validation----Pranay 22-03-2021---*/
--  UPDATE TwoAc
--	SET  
--     ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid Account ID found. Please check the values and upload again'     
--						ELSE ErrorMessage+','+SPACE(1)+'Invalid Account ID found. Please check the values and upload again'     
--				  END
--	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'ACID' 
--						ELSE ErrorinColumn +','+SPACE(1)+  'ACID' 
--				   END  
--	,Srnooferroneousrows=V.SrNo
----							--STUFF((SELECT ','+SRNO 
----							--FROM TwoAc A
----							--WHERE A.SrNo IN(SELECT V.SrNo FROM TwoAc V
----							-- WHERE ISNULL(V.ACID,'')<>''
----							--		AND V.ACID NOT IN(SELECT SystemAcid FROM AxisIntReversalDB.IntReversalDataDetails 
----							--										WHERE -----EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
----							--										Timekey=@Timekey
----							--		))
----							--FOR XML PATH ('')
----							--),1,1,'')   
-- FROM TwoAc V  
-- WHERE ISNULL(V.ACID,'')<>''
-- AND V.ACID NOT IN(SELECT CustomerACID FROM [CurDat].[AdvAcBasicDetail]  WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey)

-- UPDATE TwoAc
--	SET  
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Account ID can not be blank. Please check the values and upload again'     
--						ELSE ErrorMessage+','+SPACE(1)+'Account ID can not be blank. Please check the values and upload again'     END
--		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'ACID' ELSE ErrorinColumn +','+SPACE(1)+  'ACID' END  
--		,Srnooferroneousrows=V.SrNo
----								--STUFF((SELECT ','+SRNO 
----								--FROM TwoAc A
----								--WHERE A.SrNo IN(SELECT V.SrNo FROM TwoAc V
----								-- WHERE ISNULL(V.ACID,'')<>''
----								--		AND V.ACID NOT IN(SELECT SystemAcid FROM AxisIntReversalDB.IntReversalDataDetails 
----								--										WHERE -----EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
----								--										Timekey=@Timekey
----								--		))
----								--FOR XML PATH ('')
----								--),1,1,'')   
--		FROM TwoAc V  
-- WHERE ISNULL(V.ACID,'')=''

 
 UPDATE TwoAc
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' 
						  THEN  'Sr No can not be blank. Please check the values and upload again'     
					 ELSE ErrorMessage+','+SPACE(1)+'Sr No can not be blank. Please check the values and upload again'     
					 END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' 
					        THEN 'SrNo' 
					ELSE ErrorinColumn +','+SPACE(1)+  'SrNo' 
					END  
		,Srnooferroneousrows=V.SrNo
					 --STUFF((SELECT ','+SRNO 
					 --FROM TwoAc A
					 --WHERE A.SrNo IN(SELECT V.SrNo FROM TwoAc V
					 -- WHERE ISNULL(V.ACID,'')<>''
					 --		AND V.ACID NOT IN(SELECT SystemAcid FROM AxisIntReversalDB.IntReversalDataDetails 
					 --										WHERE -----EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
					 --										Timekey=@Timekey
					 --		))
					 --FOR XML PATH ('')
					 --),1,1,'')   
		FROM TwoAc V  
 WHERE ISNULL(V.SRNO,'')=''

 ---------------Updated By Vinit-----------------------------

  UPDATE TwoAc
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' 
						  THEN  'Sr No should not accept Alpha-Numeric Values. Please check the values and upload again'     
					 ELSE ErrorMessage+','+SPACE(1)+'Sr No should not accept Alpha-Numeric Values. Please check the values and upload again'      
					 END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' 
					        THEN 'SrNo' 
					ELSE ErrorinColumn +','+SPACE(1)+  'SrNo' 
					END  
		,Srnooferroneousrows=V.SrNo
					 --STUFF((SELECT ','+SRNO 
					 --FROM TwoAc A
					 --WHERE A.SrNo IN(SELECT V.SrNo FROM TwoAc V
					 -- WHERE ISNULL(V.ACID,'')<>''
					 --		AND V.ACID NOT IN(SELECT SystemAcid FROM AxisIntReversalDB.IntReversalDataDetails 
					 --										WHERE -----EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
					 --										Timekey=@Timekey
					 --		))
					 --FOR XML PATH ('')
					 --),1,1,'')   
		FROM TwoAc V  
 WHERE ISNULL(V.SRNO,'') like '%[0-9]%' AND ISNULL(V.SRNO,'') like '%[A-Z]%'

 ------------------------------------------------------------


 -----------------UPdated By VInit------------------------------------------------------------------------
 UPDATE TwoAc
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' 
						  THEN  'Sr No can not be special chrecter. Please check the values and upload again'     
					 ELSE ErrorMessage+','+SPACE(1)+'Sr No can not be special chrecter. Please check the values and upload again'     
					 END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' 
					        THEN 'SrNo' 
					ELSE ErrorinColumn +','+SPACE(1)+  'SrNo' 
					END  
		,Srnooferroneousrows=V.SrNo
					 --STUFF((SELECT ','+SRNO 
					 --FROM TwoAc A
					 --WHERE A.SrNo IN(SELECT V.SrNo FROM TwoAc V
					 -- WHERE ISNULL(V.ACID,'')<>''
					 --		AND V.ACID NOT IN(SELECT SystemAcid FROM AxisIntReversalDB.IntReversalDataDetails 
					 --										WHERE -----EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
					 --										Timekey=@Timekey
					 --		))
					 --FOR XML PATH ('')
					 --),1,1,'')   
		FROM TwoAc V  
-- WHERE ISNULL(V.SRNO,'') like '%[,!@#$%^&*()_-+=/]%- \ / _'
 WHERE ISNULL(V.SRNO,'') like '%[,!@#$%^&*()_-+=/]%- \ / _%'

 ---------------------------------------------------------------------------------------------
 -----------------Updated By VInit------------------------------------------------------------------------
 UPDATE TwoAc
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' 
						  THEN  'Sr No can not be special chrecter. Please check the values and upload again'     
					 ELSE ErrorMessage+','+SPACE(1)+'Sr No can not be special chrecter. Please check the values and upload again'     
					 END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' 
					        THEN 'SrNo' 
					ELSE ErrorinColumn +','+SPACE(1)+  'SrNo' 
					END  
		,Srnooferroneousrows=V.SrNo
					 --STUFF((SELECT ','+SRNO 
					 --FROM TwoAc A
					 --WHERE A.SrNo IN(SELECT V.SrNo FROM TwoAc V
					 -- WHERE ISNULL(V.ACID,'')<>''
					 --		AND V.ACID NOT IN(SELECT SystemAcid FROM AxisIntReversalDB.IntReversalDataDetails 
					 --										WHERE -----EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
					 --										Timekey=@Timekey
					 --		))
					 --FOR XML PATH ('')
					 --),1,1,'')   
		FROM TwoAc V  
-- WHERE ISNULL(V.SRNO,'') like '%[,!@#$%^&*()_-+=/]%- \ / _'
 WHERE ISNULL(V.SRNO,'') like  '%[^a-zA-Z0-9_]%'

 ---------------------------------------------------------------------------------------------





 -------------------
 UPDATE TwoAc
	SET  
        ErrorMessage='Sr No can not be blank. Please check the values and upload again'    
		,ErrorinColumn= 'SrNo'  
		,Srnooferroneousrows=V.SrNo 
		FROM TwoAc V  
 WHERE  V.SRNO=''

 -- UPDATE TwoAc
	--SET  
 --       ErrorMessage='Sr No can not be A'    
	--	,ErrorinColumn= 'SrNo'  
	--	,Srnooferroneousrows=V.SrNo 
	--	FROM TwoAc V  
 --WHERE  V.SRNO='A'
 --------------------


 
 ----
  UPDATE TwoAc
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Account ID cantains special character(s). Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Account ID cantains special character(s). Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'ACID' ELSE ErrorinColumn +','+SPACE(1)+  'ACID' END  
		,Srnooferroneousrows=V.SrNo
--								--STUFF((SELECT ','+SRNO 
--								--FROM TwoAc A
--								--WHERE A.SrNo IN(SELECT V.SrNo FROM TwoAc V
--								-- WHERE ISNULL(V.ACID,'')<>''
--								--		AND V.ACID NOT IN(SELECT SystemAcid FROM AxisIntReversalDB.IntReversalDataDetails 
--								--										WHERE -----EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
--								--										Timekey=@Timekey
--								--		))
--								--FOR XML PATH ('')
--								--),1,1,'')   
		FROM TwoAc V  
 WHERE ISNULL(V.ACID,'')  LIKE '%[^a-zA-Z0-9_]%'



 --DROP TABLE if exists #DUB3 
 --SELECT * INTO #DUB3 FROM(
 --SELECT *,ROW_NUMBER() OVER(PARTITION BY ACID ORDER BY ACID ) ROW FROM TwoAc
 --)X
 --WHERE ROW>1
   
 --  UPDATE TwoAc
	--SET  
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Duplicate records found.AccountID are repeated.  Please check the values and upload again'     
	--					ELSE ErrorMessage+','+SPACE(1)+ 'Duplicate records found. AccountID are repeated.  Please check the values and upload again'     END
	--	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'ACID' ELSE   ErrorinColumn +','+SPACE(1)+'ACID' END     
	--	,Srnooferroneousrows=V.SrNo

 --FROM TwoAc V  
 --WHERE ISNULL(ACID,'')<>''
 --AND ACID IN(SELECT ACID FROM #DUB2) 

 --   UPDATE TwoAc
	--SET  
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Account is already marked .AccountID are repeated.  Please check the values and upload again'     
	--					ELSE ErrorMessage+','+SPACE(1)+ 'Account is already marked. AccountID are repeated.  Please check the values and upload again'     END
	--	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'ACID' ELSE   ErrorinColumn +','+SPACE(1)+'ACID' END     
	--	,Srnooferroneousrows=V.SrNo
	----	STUFF((SELECT ','+SRNO 
	----							FROM #UploadNewAccount A
	----							WHERE A.SrNo IN(SELECT V.SrNo FROM #UploadNewAccount V  
 ----WHERE ISNULL(ACID,'')<>'' AND ISNULL(TERRITORY,'')<>''
 ------AND SRNO IN(SELECT Srno FROM #DUB2))
 ----AND ACID IN(SELECT ACID FROM #DUB2 GROUP BY ACID))

	----							FOR XML PATH ('')
	----							),1,1,'')   

 --FROM TwoAc V  
 --WHERE ISNULL(ACID,'')<>''
 --AND [Action]='Y'
 --AND ACID IN (select acid from ExceptionFinalStatusType
	--		  where AuthorisationStatus='A'
	--		  AND EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey) 
  
  /*validations on Amount*/
  
  UPDATE TwoAc
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'AMOUNT cannot be blank . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'AMOUNT cannot be blank . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Amount' ELSE   ErrorinColumn +','+SPACE(1)+'Amount' END   
		,Srnooferroneousrows=V.SrNo

   FROM TwoAc V  
 WHERE ISNULL(Amount,'')=''and @UploadTypeParameterAlt_Key=1 --and ISNUMERIC(V.Amount)=0 

 UPDATE TwoAc
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Amount is not appropriate other than TWO . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Amount is not appropriate other than TWO. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Amount' ELSE   ErrorinColumn +','+SPACE(1)+'Amount' END   
		,Srnooferroneousrows=V.SrNo

   FROM TwoAc V  
 WHERE ISNULL(Amount,'')<>''and @UploadTypeParameterAlt_Key<>1 
 
  UPDATE TwoAc
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'AMOUNT require numeric Values . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'AMOUNT require numeric Values . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Amount' ELSE   ErrorinColumn +','+SPACE(1)+'Amount' END   
		,Srnooferroneousrows=V.SrNo

   FROM TwoAc V  
 WHERE ISNULL(Amount,'')<>'' AND ISNUMERIC(Amount)=0   

   UPDATE TwoAc
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'AMOUNT Should be greater than  0 . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'AMOUNT Should be greater than  0 . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Amount' ELSE   ErrorinColumn +','+SPACE(1)+'Amount' END   
		,Srnooferroneousrows=V.SrNo
								--STUFF((SELECT ','+SRNO 
								--FROM TwoAc A
								--WHERE A.SrNo IN(SELECT V.SrNo  FROM TwoAc V  
								--WHERE ISNULL(SOLID,'')='')
								--FOR XML PATH ('')
								--),1,1,'')
   
   FROM TwoAc V  
 WHERE ISNULL(Amount,'')<>'' AND ISNUMERIC(Amount)=1 
 and isnull(Amount,0) <= 0  
 ----------------------------------------------
 /*validations on Date*/
  
 -- UPDATE TwoAc
	--SET  
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'DATE cannot be blank . Please check the values and upload again'     
	--					ELSE ErrorMessage+','+SPACE(1)+'DATE cannot be blank . Please check the values and upload again'     END
	--	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Date' ELSE   ErrorinColumn +','+SPACE(1)+'Date' END   
	--	,Srnooferroneousrows=V.SrNo
	--							--STUFF((SELECT ','+SRNO   -- DATE cannot be blank . Please check the values and upload again
	--							--FROM TwoAc A
	--							--WHERE A.SrNo IN(SELECT V.SrNo  FROM TwoAc V  
	--							--WHERE ISNULL(SOLID,'')='')
	--							--FOR XML PATH ('')
	--							--),1,1,'') 
 --  FROM TwoAc V  
 --WHERE ISNULL(Date,'')=''

 --------------Updated By Vinit---------------------
 --/*validations on Sr No*/
  
 -- UPDATE TwoAc
	--SET  
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'DATE cannot be blank . Please check the values and upload again'     
	--					ELSE ErrorMessage+','+SPACE(1)+'DATE cannot be blank . Please check the values and upload again'     END
	--	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Date' ELSE   ErrorinColumn +','+SPACE(1)+'Date' END   
	--	,Srnooferroneousrows=V.SrNo
	--							--STUFF((SELECT ','+SRNO   -- DATE cannot be blank . Please check the values and upload again
	--							--FROM TwoAc A
	--							--WHERE A.SrNo IN(SELECT V.SrNo  FROM TwoAc V  
	--							--WHERE ISNULL(SOLID,'')='')
	--							--FOR XML PATH ('')
	--							--),1,1,'') 
 --  FROM TwoAc V  
 --WHERE ISNULL(SrNo,'')=''

-- ----------VALIDATION DATE FORMATE DYM------------------

--  UPDATE TwoAc
--	SET  
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid date format. Please enter the date in format ‘dd/mm/yyyy’'     
--						ELSE ErrorMessage+','+SPACE(1)+'Invalid date format. Please enter the date in format ‘dd/mm/yyyy’'     END
--		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Date' ELSE   ErrorinColumn +','+SPACE(1)+'Date' END   
--		,Srnooferroneousrows=V.SrNo

--  FROM TwoAc V  
-- WHERE ISNULL(Date,'')<>''and isdate(Date)=0  
-- print 'Swapna' 

-- ----------Update By Vinit VALIDATION DATE FORMATE DYM------------------ 
--  UPDATE TwoAc
--	SET  
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid date format. Please enter the date in format ‘dd/mm/yyyy’'     
--						ELSE ErrorMessage+','+SPACE(1)+'Invalid date format. Please enter the date in format ‘dd/mm/yyyy’'     END
--		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Date' ELSE   ErrorinColumn +','+SPACE(1)+'Date' END   
--		,Srnooferroneousrows=V.SrNo 
--  FROM TwoAc V  
---- WHERE ISNULL(Date,'')<>''and isdate(Date)=0  
--where  [date] not like '%/%' or [date]  like '%[A-Z]%' 
-- print 'Swapna'  
  --------------------------working due to set dateformat dmy------------------

 --  UPDATE TwoAc
	--SET  
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Should not be Future date. Please Check and upload'     
	--					ELSE ErrorMessage+','+SPACE(1)+'Should not be Future date. Please Check and upload'     END
	--	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Date' ELSE   ErrorinColumn +','+SPACE(1)+'Date' END   
	--	,Srnooferroneousrows=V.SrNo
	--							--STUFF((SELECT ','+SRNO   -- DATE cannot be blank . Please check the values and upload again
	--							--FROM TwoAc A
	--							--WHERE A.SrNo IN(SELECT V.SrNo  FROM TwoAc V  
	--							--WHERE ISNULL(SOLID,'')='')
	--							--FOR XML PATH ('')
	--							--),1,1,'') 
 --FROM TwoAc V  
 --WHERE ISNULL(Date,'')<>'' and  isdate(Date)=1
 --and (convert(Date, date)) > convert(Date, getdate())
 ----and ISNULL(convert(varchar(10), date,103),'') > convert(varchar(10), getdate(),103) 

 ----------------------------------------------
 /*------------------validations on Action Flag -------Pranay 22-03-2021-----------------*/
  
  UPDATE TwoAc
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Please enter (Y or N) value in Action column. Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Please enter (Y or N) value in Action column. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Action' ELSE   ErrorinColumn +','+SPACE(1)+'Action' END   
		,Srnooferroneousrows=V.SrNo
								--STUFF((SELECT ','+SRNO 
								--FROM TwoAc A
								--WHERE A.SrNo IN(SELECT V.SrNo  FROM TwoAc V  
								--WHERE ISNULL(SOLID,'')='')
								--FOR XML PATH ('')
								--),1,1,'') 
   FROM TwoAc V  
 WHERE v.Action NOT IN ('Y','N') 

/*------------------validations on Action Flag -------02-04-2021-----------------*/
--------Comment By Vinit---------------------  
 -- DEclare @ParameterName as Varchar(100)
 --Set @ParameterName = (select ParameterName from DimParameter where DimParameterName ='uploadflagtype' and EffectiveToTimeKey=49999 and ParameterAlt_Key=@UploadTypeParameterAlt_Key)
  
 -- UPDATE TwoAc
	--SET  
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Account is not marked to the selected flag. You can only add the marked flag for this account.'     
	--					ELSE ErrorMessage+','+SPACE(1)+'Account is not marked to the selected flag. You can only add the marked flag for this account.'     END
	--	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Action' ELSE   ErrorinColumn +','+SPACE(1)+'Action' END   
	--	,Srnooferroneousrows=V.SrNo
	--							--STUFF((SELECT ','+SRNO 
	--							--FROM TwoAc A
	--							--WHERE A.SrNo IN(SELECT V.SrNo  FROM TwoAc V  
	--							--WHERE ISNULL(SOLID,'')='')
	--							--FOR XML PATH ('')
	--							--),1,1,'')
   
 --  FROM TwoAc V  
 --   WHERE v.Action IN ('N')
	--And Not exists (Select 1 FRom ExceptionFinalStatusType A where A.ACID=V.ACID And A.StatusType=@ParameterName And A.EffectiveToTimeKey=49999)
  
  ------------------------------------------------------------------
 
 -- UPDATE TwoAc
	--SET  
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Account with selected flag is already pending for authorization. Please check the values and upload again.'     
	--					ELSE ErrorMessage+','+SPACE(1)+'Account with selected flag is already pending for authorization. Please check the values and upload again.'     END
	--	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Account' ELSE   ErrorinColumn +','+SPACE(1)+'Account' END   
	--	,Srnooferroneousrows=V.SrNo

   
 --  FROM TwoAc V  
 --   WHERE v.Action IN ('N','Y')
	--And  exists (Select 1 FRom AccountFlaggingDetails_Mod A where A.ACID=V.ACID And A.UploadTypeParameterAlt_Key=@UploadTypeParameterAlt_Key And A.EffectiveToTimeKey=49999 And AuthorisationStatus In ('NP','MP'))
	 
-----------------------
 
  UPDATE TwoAc
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Account with selected flag is already pending for authorization. Please check the values and upload again.'     
						ELSE ErrorMessage+','+SPACE(1)+'Account with selected flag is already pending for authorization. Please check the values and upload again.'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Account' ELSE   ErrorinColumn +','+SPACE(1)+'Account' END   
		,Srnooferroneousrows=V.SrNo

   FROM TwoAc V  
    WHERE v.Action IN ('N','Y')
	And  exists (Select 1 FRom ExceptionalDegrationDetail_Mod A where A.AccountID=V.ACID And A.FlagAlt_Key=@UploadTypeParameterAlt_Key And A.EffectiveToTimeKey=49999 And AuthorisationStatus In ('NP','MP'))
 
-----------------------
 Print '123'
 goto valid


  END
	
   ErrorData:  
   print 'no'  

		SELECT *,'Data'TableName
		FROM dbo.MasterUploadData WHERE FileNames=@filepath 
		return

   valid:
   print 'Check'
		IF NOT EXISTS(Select 1 from  AccountFlagging_Stg WHERE filname=@FilePathUpload)
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
			FROM TwoAc 

			goto final
		END 


  IF EXISTS (SELECT 1 FROM  dbo.MasterUploadData   WHERE FileNames=@filepath AND  ISNULL(ERRORDATA,'')<>'') 

   BEGIN  
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

	
		ORDER BY SR_No 

		 IF EXISTS(SELECT 1 FROM AccountFlagging_Stg WHERE filname=@FilePathUpload)
		 BEGIN

		DELETE FROM AccountFlagging_Stg  WHERE filname=@FilePathUpload
		 PRINT 'ROWS DELETED FROM DBO.AccountFlagging_Stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
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

	----SELECT * FROM TwoAc

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
				SELECT 
				ERROR_LINE() as ErrorLine,
				ERROR_MESSAGE()ErrorMessage,
				ERROR_NUMBER()ErrorNumber,
				ERROR_PROCEDURE()ErrorProcedure,
				ERROR_SEVERITY()ErrorSeverity,
				ERROR_STATE()ErrorState,
				GETDATE()

	IF EXISTS(SELECT 1 FROM AccountFlagging_Stg WHERE filname=@FilePathUpload)
		 BEGIN
		 DELETE FROM AccountFlagging_Stg
		 WHERE filname=@FilePathUpload

		 PRINT 'ROWS DELETED FROM DBO.AccountFlagging_Stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
		 END

END CATCH

END
  


GO