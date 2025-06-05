SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[ValidateExcel_DataUpload_IndustrySpecificUpload] 
@MenuID INT=24750,  
@UserLoginId  VARCHAR(20)='lvl1admin',  
@Timekey INT=49999
,@filepath VARCHAR(MAX) ='IndustrySpecificProvisionUpload (15).xlsx'  
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


IF (@MenuID=24750)	
BEGIN


	  -- IF OBJECT_ID('tempdb..#UploadIndustrySpecific') IS NOT NULL  
	  --BEGIN  
	  -- DROP TABLE #UploadIndustrySpecific  
	
	  --END
	  IF OBJECT_ID('UploadIndustrySpecific') IS NOT NULL  
	  BEGIN
	    
		DROP TABLE  UploadIndustrySpecific
	
	  END
	  
  IF NOT (EXISTS (SELECT * FROM DimIndustrySpecific_stg where filname=@FilePathUpload))

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
 	   into UploadIndustrySpecific 
	   from DimIndustrySpecific_stg 
	   WHERE filname=@FilePathUpload
	 
	  
END
  ------------------------------------------------------------------------------  
  --select * from DimIndustrySpecific_stg
    ----SELECT * FROM UploadIndustrySpecific
	--SrNo	Territory	ACID	InterestReversalAmount	filname
	UPDATE UploadIndustrySpecific
	SET  
        ErrorMessage='There is no data in excel. Kindly check and upload again' 
		,ErrorinColumn='SlNo,CIF,BSRActivityCode,ProvisionRate'    
		,Srnooferroneousrows=''
 FROM UploadIndustrySpecific V  
 WHERE ISNULL(SlNo,'')=''
AND ISNULL(CIF,0)=0
AND ISNULL(BSRActivityCode,0)=0
AND ISNULL(ProvisionRate,0.00)=0.00

  IF EXISTS(SELECT 1 FROM UploadIndustrySpecific WHERE ISNULL(ErrorMessage,'')<>'')
  BEGIN
  PRINT 'NO DATA'
  GOTO ERRORDATA;
  END



-----validations on Srno
	print 'Validation Error MSG'
	 UPDATE UploadIndustrySpecific
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 	'SlNo is mandatory. Kindly check and upload again' 
		                  ELSE ErrorMessage+','+SPACE(1)+ 'SlNo is mandatory. Kindly check and upload again'
		  END
		,ErrorinColumn='SRNO'    
		,Srnooferroneousrows=''
	FROM UploadIndustrySpecific V  
	WHERE ISNULL(v.SlNo,'')=''  
	 Print '1'

 UPDATE UploadIndustrySpecific
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid SlNo, kindly check and upload again'     
								  ELSE ErrorMessage+','+SPACE(1)+ 'Invalid SlNo, kindly check and upload again'      END
		,ErrorinColumn='SRNO'    
		,Srnooferroneousrows=SlNo
		
 FROM UploadIndustrySpecific V  
 WHERE ISNULL(v.SlNo,'')='0'  OR ISNUMERIC(v.SlNo)=0
  Print '2'
  
  IF OBJECT_ID('TEMPDB..#R') IS NOT NULL
  DROP TABLE #R

  SELECT * INTO #R FROM(
  SELECT *,ROW_NUMBER() OVER(PARTITION BY SlNo ORDER BY SlNo)ROW
   FROM UploadIndustrySpecific
   )A
   WHERE ROW>1

 PRINT 'DUB'  


  UPDATE UploadIndustrySpecific
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Duplicate SlNo, kindly check and upload again' 
					ELSE ErrorMessage+','+SPACE(1)+     'Duplicate SlNo, kindly check and upload again' END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SlNo' ELSE ErrorinColumn +','+SPACE(1)+  'SlNo' END
		,Srnooferroneousrows=SlNo
		--STUFF((SELECT DISTINCT ','+SlNo 
		--						FROM UploadIndustrySpecific
		--						FOR XML PATH ('')
		--						),1,1,'')
         
		
 FROM UploadIndustrySpecific V  
	WHERE  V.SlNo IN(SELECT SlNo FROM #R )
	Print '3'


/*validations on CIF*/
  
  UPDATE UploadIndustrySpecific
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'CIF cannot be blank . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'CIF cannot be blank . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'CIF' ELSE   ErrorinColumn +','+SPACE(1)+'CIF' END   
		,Srnooferroneousrows=V.SlNo
								--STUFF((SELECT ','+SlNo 
								--FROM UploadIndustrySpecific A
								--WHERE A.SlNo IN(SELECT V.SlNo  FROM UploadIndustrySpecific V  
								--WHERE ISNULL(SOLID,'')='')
								--FOR XML PATH ('')
								--),1,1,'')
   
   FROM UploadIndustrySpecific V  
 WHERE ISNULL(CIF,'')=''


  


 
  UPDATE UploadIndustrySpecific
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'CIF value should be numeric.  Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'CIF value should be numeric.  Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'CIF' ELSE   ErrorinColumn +','+SPACE(1)+'CIF' END       
		,Srnooferroneousrows=V.SlNo
   
   FROM UploadIndustrySpecific V  
 WHERE ISNULL(CIF,'') LIKE '%^[0-9]%'

  
  
  UPDATE UploadIndustrySpecific
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'CIF value should be available in CrisMac ENPA System.  Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'CIF value should be available in CrisMac ENPA System.  Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'CIF' ELSE   ErrorinColumn +','+SPACE(1)+'CIF' END       
		,Srnooferroneousrows=V.SlNo
	--	STUFF((SELECT ','+SlNo 
	--							FROM UploadIndustrySpecific A
	--							WHERE A.SlNo IN(SELECT V.SlNo FROM UploadIndustrySpecific V  
 --WHERE ISNULL(SOLID,'')<>''
 --AND  LEN(SOLID)>10)
	--							FOR XML PATH ('')
	--							),1,1,'')
   
   FROM UploadIndustrySpecific V  
 WHERE ISNULL(CIF,'') not in (select CustomerID from CustomerBasicDetail where EffectiveFromtimekey <= @Timekey and EffectiveToTimekey >= @Timekey)

 --------------------------------------------Validation on BSRActivityCode------------------------

 
  UPDATE UploadIndustrySpecific
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'BSRActivityCode cannot be blank . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'BSRActivityCode cannot be blank . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'BSRActivityCode' ELSE   ErrorinColumn +','+SPACE(1)+'BSRActivityCode' END   
		,Srnooferroneousrows=V.SlNo
								--STUFF((SELECT ','+SlNo 
								--FROM UploadIndustrySpecific A
								--WHERE A.SlNo IN(SELECT V.SlNo  FROM UploadIndustrySpecific V  
								--WHERE ISNULL(SOLID,'')='')
								--FOR XML PATH ('')
								--),1,1,'')
   
   FROM UploadIndustrySpecific V  
 WHERE ISNULL(BSRActivityCode,'')=''


  


 
  UPDATE UploadIndustrySpecific
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'BSRActivityCode value should be numeric.  Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'BSRActivityCode value should be numeric.  Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'BSRActivityCode' ELSE   ErrorinColumn +','+SPACE(1)+'BSRActivityCode' END       
		,Srnooferroneousrows=V.SlNo	
   
   FROM UploadIndustrySpecific V  
 WHERE ISNULL(BSRActivityCode,'') LIKE '%^[0-9]%'

  
  
  UPDATE UploadIndustrySpecific
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'BSRActivityCode value should be available in CrisMac ENPA System.  Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'BSRActivityCode value should be available in CrisMac ENPA System.  Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'BSRActivityCode' ELSE   ErrorinColumn +','+SPACE(1)+'BSRActivityCode' END       
		,Srnooferroneousrows=V.SlNo
	--	STUFF((SELECT ','+SlNo 
	--							FROM UploadIndustrySpecific A
	--							WHERE A.SlNo IN(SELECT V.SlNo FROM UploadIndustrySpecific V  
 --WHERE ISNULL(SOLID,'')<>''
 --AND  LEN(SOLID)>10)
	--							FOR XML PATH ('')
	--							),1,1,'')
   
   FROM UploadIndustrySpecific V  
 WHERE ISNULL(BSRActivityCode,'') not in (select BSR_ActivityCode from DimBSRActivityMaster where EffectiveFromtimekey <= @Timekey and EffectiveToTimekey >= @Timekey)

 UPDATE UploadIndustrySpecific		 				
	SET  					
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Record for CIF is for authorization in ‘Upload ID’ '+ Convert(Varchar(10),B.UploadId) +' kindly remove the record and upload again '     						
						ELSE ErrorMessage+','+SPACE(1)+'Record for CIF  is pending for authorization in ‘Upload ID’ '+ Convert(Varchar(10),B.UploadId) +' kindly remove the record and upload again '     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'CIF ' ELSE   ErrorinColumn +','+SPACE(1)+'CIF ' END       				
		,Srnooferroneousrows=V.SlNo				
  FROM UploadIndustrySpecific V  						
   LEFT Join DimIndustrySpecific_Mod B ON V.CIF=B.CIF		and V.BSRActivityCode = B.BSRActivityCode				
   --LEFT Join CollateralDetailUpload_Mod C ON V.AssetID=C.AssetID						
 WHERE	B.AuthorisationStatus In('NP','MP','FM','RM','1A') 					
 and (B.CIF is not NULL)
 ----------------------------Validations on Provision %

 
  
  UPDATE UploadIndustrySpecific
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'ProvisionRate value should be between 0 and 100.  Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'ProvisionRate value should be between 0 and 100.  Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'ProvisionRate' ELSE   ErrorinColumn +','+SPACE(1)+'ProvisionRate' END       
		,Srnooferroneousrows=V.SlNo
	--	STUFF((SELECT ','+SlNo 
	--							FROM UploadIndustrySpecific A
	--							WHERE A.SlNo IN(SELECT V.SlNo FROM UploadIndustrySpecific V  
 --WHERE ISNULL(SOLID,'')<>''
 --AND  LEN(SOLID)>10)
	--							FOR XML PATH ('')
	--							),1,1,'')
   
   FROM UploadIndustrySpecific V  
 WHERE (ISNULL(ProvisionRate,0.00) < 0 OR ISNULL(ProvisionRate,0.00) > 100)


 Print '123'
 goto valid

  END
	
   ErrorData:  
   print 'no'  

		SELECT *,'Data'TableName
		FROM dbo.MasterUploadData WHERE FileNames=@filepath 
		return

   valid:
		IF NOT EXISTS(Select 1 from  DimIndustrySpecific_stg WHERE filname=@FilePathUpload)
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
			FROM UploadIndustrySpecific 

			PRINT 'VALIDATION ERRORS'
			
		--	----SELECT * FROM UploadIndustrySpecific 

		--	--ORDER BY ErrorMessage,UploadIndustrySpecific.ErrorinColumn DESC
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

		 IF EXISTS(SELECT 1 FROM DimIndustrySpecific_stg WHERE filname=@FilePathUpload)
		 BEGIN
		 DELETE FROM DimIndustrySpecific_stg
		 WHERE filname=@FilePathUpload

		 --PRINT 1

		 --PRINT 'ROWS DELETED FROM DBO.DimIndustrySpecific_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
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

	----SELECT * FROM UploadIndustrySpecific

	print 'p'
  ------to delete file if it has errors
		--if exists(Select  1 from dbo.MasterUploadData where FileNames=@filepath and ISNULL(ErrorData,'')<>'')
		--begin
		--print 'ppp'
		 --IF EXISTS(SELECT 1 FROM DimIndustrySpecific_stg WHERE filname=@FilePathUpload)
		 --BEGIN
		 --print '123'
		 --DELETE FROM DimIndustrySpecific_stg
		 --WHERE filname=@FilePathUpload
		 --END
		-- PRINT 'ROWS DELETED FROM DBO.DimIndustrySpecific_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
		-- END
		-- END

   
END  TRY
  
  BEGIN CATCH
	

	INSERT INTO dbo.Error_Log
				SELECT ERROR_LINE() as ErrorLine,ERROR_MESSAGE()ErrorMessage,ERROR_NUMBER()ErrorNumber
				,ERROR_PROCEDURE()ErrorProcedure,ERROR_SEVERITY()ErrorSeverity,ERROR_STATE()ErrorState
				,GETDATE()

	--IF EXISTS(SELECT 1 FROM DimIndustrySpecific_stg WHERE filname=@FilePathUpload)
	--	 BEGIN
	--	 DELETE FROM DimIndustrySpecific_stg
	--	 WHERE filname=@FilePathUpload

	--	 PRINT 'ROWS DELETED FROM DBO.DimIndustrySpecific_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
	--	 END

END CATCH

END
GO