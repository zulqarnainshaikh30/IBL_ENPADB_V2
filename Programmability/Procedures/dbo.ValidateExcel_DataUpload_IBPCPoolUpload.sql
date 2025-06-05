SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[ValidateExcel_DataUpload_IBPCPoolUpload]  
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
 --Set  @Timekey=(select CAST(B.timekey as int)from SysDataMatrix A Inner Join SysDayMatrix B ON A.TimeKey=B.TimeKey where A.CurrentStatus='C')
set @Timekey =(select timekey from SysDataMatrix where 	 CurrentStatus='C')			  
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
		Delete from dbo.MasterUploadData where FileNames=@filepath  
		print @@rowcount
   END 
IF (@MenuID=1458)	
BEGIN


	  -- IF OBJECT_ID('tempdb..UploadIBPCPool') IS NOT NULL  
	  IF OBJECT_ID('UploadIBPCPool') IS NOT NULL  
	  BEGIN  
	   DROP TABLE UploadIBPCPool  
	
	  END
	  
  IF NOT (EXISTS (SELECT * FROM IBPCPoolDetail_stg where filname=@FilePathUpload))

BEGIN
print 'NO DATA'
			Insert into dbo.MasterUploadData
			(SR_No,ColumnName,ErrorData,ErrorType,FileNames,Flag) 
			SELECT 0 SRNO , 
			'' ColumnName,
			'No Record found' ErrorData,
			'No Record found' ErrorType,
			@filepath,
			'SUCCESS' 
		   --SELECT 0 SRNO , '' ColumnName,'' ErrorData,'' ErrorType,@filepath,'SUCCESS'  
			goto errordata 
END 
ELSE
BEGIN
PRINT 'DATA PRESENT'
	   Select *,CAST('' AS varchar(MAX)) ErrorMessage, CAST('' AS varchar(MAX)) ErrorinColumn,CAST('' AS varchar(MAX)) Srnooferroneousrows 
	   into UploadIBPCPool 
	   from IBPCPoolDetail_stg 
	   WHERE filname=@FilePathUpload 
END
------------------------------------------------------------------------------  
----SELECT * FROM UploadIBPCPool
--SrNo	Territory	ACID	InterestReversalAmount	filname
	UPDATE UploadIBPCPool
	SET  
        ErrorMessage='There is no data in excel. Kindly check and upload again' 
		,ErrorinColumn='Pool ID,Pool Name,Account ID,IBPCExposure,Action,Dates'    
		,Srnooferroneousrows=''
 FROM UploadIBPCPool V  
 WHERE ISNULL(PoolID,'')=''
AND ISNULL(PoolName,'')=''
AND ISNULL(PoolType,'')=''
AND ISNULL(AccountID,'')='' 
AND ISNULL(IBPCExposureinRs,'')='' 
AND ISNULL(DateofIBPCmarking,'')=''
AND ISNULL(MaturityDate,'')=''
AND ISNULL(Action,'')=''
AND ISNULL(SrNo,'')='' 




	UPDATE UploadIBPCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Sr No is present and remaining  excel file is blank. Please check and Upload again.' 
		                                             ELSE ErrorMessage+','+SPACE(1)+'Sr No is present and remaining  excel file is blank. Please check and Upload again.'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Excel Vaildate ' ELSE   ErrorinColumn +','+SPACE(1)+'Excel Vaildate' END   
		,Srnooferroneousrows=''
 FROM UploadIBPCPool V  
 WHERE 
 ISNULL(PoolID,'')=''
AND ISNULL(PoolName,'')=''
AND ISNULL(PoolType,'')=''
AND ISNULL(AccountID,'')='' 
AND ISNULL(IBPCExposureinRs,'')='' 
AND ISNULL(DateofIBPCmarking,'')=''
AND ISNULL(MaturityDate,'')=''
AND ISNULL(Action,'')=''
AND ISNULL(SrNo,'')<>'' 

------------UPDATED BY VINIT Pool Id SPecial CHarecter------------

UPDATE UploadIBPCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Pool ID Should Not Allowed Special Charecter' ELSE ErrorMessage+','+SPACE(1)+'Pool ID Should Not Allowed Special Charecter'END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN  'Pool ID'    ELSE  ErrorinColumn +','+SPACE(1)+'Pool ID' END
		,Srnooferroneousrows=v.SrNo
 FROM UploadIBPCPool V  
 WHERE ISNULL(PoolID,'')  LIKE '%[,!@#$%^&*()_-+=/]%'
----------------------------------------------------
------------UPDATED BY VINIT Pool Id Length------------ 

UPDATE UploadIBPCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Pool ID Should Not be greter than 20 character' ELSE ErrorMessage+','+SPACE(1)+'Pool ID Should Not be greter than 20 character'END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Pool ID'    ELSE  ErrorinColumn +','+SPACE(1)+'Pool ID' END
		,Srnooferroneousrows=v.SrNo
 FROM UploadIBPCPool V  
 WHERE  len(PoolID) >20
----------------------------------------------------
------------UPDATED BY VINIT Pool NAME Length------------ 

UPDATE UploadIBPCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Pool NAME Should Not Allowed Special Charecter'  ELSE ErrorMessage+','+SPACE(1) + 'Pool NAME Should Not Allowed Special Charecter' END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THen 'Pool NAME'     ELSE  ErrorinColumn +','+SPACE(1)+'Pool NAME' END
		,Srnooferroneousrows=v.SrNo
 FROM UploadIBPCPool V  
 WHERE  isnull(PoolName,'') LIKE '%[,!@#$%^&*()_-+=/]%'
----------------------------------------------------

------------UPDATED BY VINIT Pool NAME Alfa Numberical------------ 

UPDATE UploadIBPCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' Then 'Pool NAME Should Not Allowed Alfa Numberical Values'  ELSE ErrorMessage+','+SPACE(1) + 'Pool NAME Should Not Allowed Alfa Numberical Values' END
		,ErrorinColumn=   CASE WHEN ISNULL(ErrorinColumn,'')='' THen 'Pool NAME'     ELSE  ErrorinColumn +','+SPACE(1)+'Pool NAME' END
		,Srnooferroneousrows=v.SrNo
 FROM UploadIBPCPool V  
 WHERE  PoolName LIKE '%[0-9]%'
----------------------------------------------------------------------

------------UPDATED BY VINIT Pool Type Blank------------ 

UPDATE UploadIBPCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' Then 'Pool Type Should Not Be Blank'   ELSE ErrorMessage+','+SPACE(1) + 'Pool Type Should Not Be Blank' END
		,ErrorinColumn= CASE WHEN ISNULL(ErrorinColumn,'')='' THen 'Pool Type'     ELSE  ErrorinColumn +','+SPACE(1)+'Pool Type' END 
		,Srnooferroneousrows=v.SrNo
 FROM UploadIBPCPool V  
 WHERE  ISNULL(PoolType,'')=''
----------------------------------------------------------------------

------------UPDATED BY VINIT Pool Type With Risk Or Without Risk------------ 

--UPDATE UploadIBPCPool
--	SET  
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' Then 'Pool Type Should Not Be With Risk Or Without Risk' ELSE ErrorMessage+','+SPACE(1) +'Pool Type Should Not Be With Risk Or Without Risk' END
--		,ErrorinColumn=  CASE WHEN ISNULL(ErrorinColumn,'')='' THen 'Pool Type'     ELSE  ErrorinColumn +','+SPACE(1)+'Pool Type' END 
--		,Srnooferroneousrows=v.SrNo
-- FROM UploadIBPCPool V  
-- WHERE  ISNULL(PoolType,'') not in ('With Risk','Without Risk')
----------------------------------------------------------------------

------------UPDATED BY VINIT IBPC Exposure in Rs Alfa Numberical------------ 

--UPDATE UploadIBPCPool
--	SET  
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' Then 'IBPC Exposure in Rs Should Not Be Alfa Numberical'  ELSE ErrorMessage+','+SPACE(1) + 'IBPC Exposure in Rs Should Not Be Alfa Numberical' END
--		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THen 'IBPC Exposure'     ELSE  ErrorinColumn +','+SPACE(1)+'IBPC Exposure' END 
--		,Srnooferroneousrows=v.SrNo
-- FROM UploadIBPCPool V  
-- WHERE  ISNULL(IBPCExposureinRs,'') like '%[A-Z]%' 
----------------------------------------------------------------------


   UPDATE UploadIBPCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'SrNo cannot be blank . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'SrNo cannot be blank . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' ELSE   ErrorinColumn +','+SPACE(1)+'SrNo' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadIBPCPool V  
 WHERE ISNULL(SrNo,'')='' or ISNULL(SrNo,'0')='0'







  
--WHERE ISNULL(V.SrNo,'')=''
-- ----AND ISNULL(Territory,'')=''
-- AND ISNULL(AccountID,'')=''
-- AND ISNULL(PoolID,'')=''
-- AND ISNULL(filname,'')=''

  IF EXISTS(SELECT 1 FROM UploadIBPCPool WHERE ISNULL(ErrorMessage,'')<>'')
  BEGIN
  PRINT 'NO DATA'
  GOTO valid---- changed by kapil previous it was ERRORDATA;
  END

 -------------------------------------------------------------------------/*validations on Sl. No.*/ -------------------------------------------------------------------------
  
 --  UPDATE UploadIBPCPool
	--SET  
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Special characters not allowed, kindly remove and upload again'     
	--					ELSE ErrorMessage+','+SPACE(1)+'Special characters not allowed, kindly remove and upload again'     END
	--	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' ELSE   ErrorinColumn +','+SPACE(1)+'SrNo' END   
	--	,Srnooferroneousrows=V.SrNo 
   
 --  FROM UploadIBPCPool V  
 --WHERE  isnull(PoolID,'')  LIKE'%[,!@#$%^&*()_-+=/]%- \ / _'
 ------------------------------------------------------------------------
  
--   UPDATE UploadIBPCPool
--	SET  
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Special characters not allowed, kindly remove and upload again'     
--						ELSE ErrorMessage+','+SPACE(1)+'Special characters not allowed, kindly remove and upload again'     END
--		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' ELSE   ErrorinColumn +','+SPACE(1)+'SrNo' END   
--		,Srnooferroneousrows=V.SrNo 
   
--   FROM UploadIBPCPool V  
---- WHERE ISNULL(SrNo,'')='' or ISNULL(SrNo,'0')='0'
-- WHERE PoolName LIKE '%[,!@#$%^&*()_-+=/]%'
 ------------------------------------------------------------------------


  UPDATE UploadIBPCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'SrNo cannot be greater than 16 character . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'SrNo cannot be greater than 16 character . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' ELSE   ErrorinColumn +','+SPACE(1)+'SrNo' END   
		,Srnooferroneousrows=V.SrNo
								   
   FROM UploadIBPCPool V  
 WHERE Len(SrNo)>16

 ----------

  UPDATE UploadIBPCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid Sl. No., kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid Sl. No., kindly check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' ELSE   ErrorinColumn +','+SPACE(1)+'SrNo' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadIBPCPool V  
  WHERE (ISNUMERIC(SrNo)=0 AND ISNULL(SrNo,'')<>'') OR 
 ISNUMERIC(SrNo) LIKE '%^[0-9]%'

  ----------

 UPDATE UploadIBPCPool
	SET  
  ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Special characters not allowed, kindly remove and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Special characters not allowed, kindly remove and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' ELSE   ErrorinColumn +','+SPACE(1)+'SrNo' END   
		,Srnooferroneousrows=V.SrNo
								
   
   FROM UploadIBPCPool V  
   WHERE ISNULL(SrNo,'') LIKE'%[,!@#$%^&*()_-+=/]%'
    --WHERE ISNULL(SrNo,'') LIKE'%@%'

 ----------

  Declare @DuplicateCnt int=0
  SELECT @DuplicateCnt=Count(1)
FROM UploadIBPCPool
GROUP BY  SrNo
HAVING COUNT(SrNo) >1;

IF (@DuplicateCnt>0)

 UPDATE		UploadIBPCPool
SET			ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Duplicate Sl. No., kindly check and upload again'     
						 ELSE ErrorMessage+','+SPACE(1)+'Duplicate Sl. No., kindly check and upload again'     END
			,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' ELSE   ErrorinColumn +','+SPACE(1)+'SrNo' END   
			,Srnooferroneousrows=V.SrNo			
   FROM		UploadIBPCPool V  
   Where	ISNULL(SrNo,'') In(  
								   SELECT SrNo
									FROM UploadIBPCPool a
									GROUP BY  SrNo
									HAVING COUNT(SrNo) >1
							   )

							   
----------------------------------------------
  
  
 
--------------Added on 29/04/2022


 --------------------------------------- /*validations on Action*/----------------------

  
  UPDATE UploadIBPCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Action cannot be blank . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Action cannot be blank . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Action' ELSE   ErrorinColumn +','+SPACE(1)+'Action' END   
		,Srnooferroneousrows=V.SrNo

   
   FROM UploadIBPCPool V  
 WHERE ISNULL(Action,'')=''
 --select * from UploadIBPCPool where PoolType  in  ('With Risk' , 'With out Risk')
 
  UPDATE UploadIBPCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid Action.  Please check the values A or R  and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid Action.  Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Action' ELSE   ErrorinColumn +','+SPACE(1)+'Action' END       
		,Srnooferroneousrows=V.SrNo

   
   FROM UploadIBPCPool V  
 WHERE Action  NOT in  ('A' , 'R')

 ----------- Condition for Account Already Marked with Action--- Akshay 02082022

   UPDATE UploadIBPCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'This Action is Already Marked on this Account.  Please check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'This Action is Already Marked on this Account.  Please check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Action' ELSE   ErrorinColumn +','+SPACE(1)+'Action' END       
		,Srnooferroneousrows=V.SrNo

   
   FROM UploadIBPCPool V  
 WHERE Action in  ('A')
 And  exists (Select 1 FRom IBPCFinalPoolDetail A where A.AccountID=V.AccountID  And A.EffectiveToTimeKey=49999
	 And AuthorisationStatus In ('A'))



	 
   UPDATE UploadIBPCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Account is not Marked with Action A, for performig Acion R.  Please check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'This Action is Already Marked on this Account.  Please check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Action' ELSE   ErrorinColumn +','+SPACE(1)+'Action' END       
		,Srnooferroneousrows=V.SrNo

 
FROM UploadIBPCPool V  
 WHERE Action in  ('R')
 And not exists (Select 1 FRom IBPCFinalPoolDetail A where A.AccountID=V.AccountID  And A.EffectiveToTimeKey=49999
	 And AuthorisationStatus In ('A','R'))



  ---------------------------------------------

  
  ----------------------------/*validations on POOLID*/
  
  UPDATE UploadIBPCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'POOLID cannot be blank . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'POOLID cannot be blank . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'POOLID' ELSE   ErrorinColumn +','+SPACE(1)+'PoolID' END   
		,Srnooferroneousrows=V.SrNo

   
   FROM UploadIBPCPool V  
 WHERE ISNULL(PoolID,'')=''


  


 
  UPDATE UploadIBPCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid PoolID.  Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid PoolID.  Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'PoolID' ELSE   ErrorinColumn +','+SPACE(1)+'PoolID' END       
		,Srnooferroneousrows=V.SrNo

   
   FROM UploadIBPCPool V  
 WHERE ISNULL(PoolID,'')<>''
 AND LEN(PoolID)>20


---------------------------22042021-----------------
---uncomment by vinit
 --IF OBJECT_ID('TEMPDB..#DupPool') IS NOT NULL
 --DROP TABLE #DupPool

 --SELECT * INTO #DupPool FROM(
 --SELECT *,ROW_NUMBER() OVER(PARTITION BY PoolID ORDER BY PoolID ) as rw  FROM UploadIBPCPool
 --)X
 --WHERE rw>1


 --UPDATE V
	--SET  
 --       ErrorMessage=CASE WHEN ISNULL(V.ErrorMessage,'')='' THEN  'Duplicate Pool ID found. Please check the values and upload again'     
	--					ELSE V.ErrorMessage+','+SPACE(1)+'Duplicate Pool ID found. Please check the values and upload again'     END
	--	,ErrorinColumn=CASE WHEN ISNULL(V.ErrorinColumn,'')='' THEN 'PoolID' ELSE V.ErrorinColumn +','+SPACE(1)+  'PoolID' END  
	--	,Srnooferroneousrows=V.SRNO
  
	--	FROM UploadIBPCPool V 
	--	INNer JOIN #DupPool D ON D.PoolID=V.PoolID

--------------------------------------------------------------
 /*-------------------PoolName-Validation------------------------- */ -- changes done on 19-03-21 Pranay 
 Declare @PoolNameCnt int=0,@PoolType int=0
 --DROP TABLE IF EXISTS PoolNameData
  IF OBJECT_ID('PoolNameData') IS NOT NULL  
	  BEGIN  
	   DROP TABLE PoolNameData  
	
	  END

 SELECT * into PoolNameData  FROM(
 SELECT ROW_NUMBER() OVER(PARTITION BY PoolID  ORDER BY  PoolID ) 
 ROW ,PoolID,PoolName,AccountID FROM UploadIBPCPool
 )X
 WHERE ROW=1

 select * from PoolNameData
 SELECT @PoolNameCnt=COUNT(*) FROM PoolNameData a
 INNER JOIN UploadIBPCPool b
 ON a.PoolID=b.PoolID 
 WHERE a.PoolName<>b.PoolName

 IF @PoolNameCnt>0
 BEGIN
  PRINT 'PoolName ERROR'
   UPDATE UploadIBPCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Different PoolID of same combination of PoolName is Available. Please check the values and upload again' END    
						--ELSE ErrorMessage+','+SPACE(1)+ 'Different PoolID of same combination of PoolName and PoolType is Available. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'PoolName' ELSE   ErrorinColumn +','+SPACE(1)+'PoolName' END     
		,Srnooferroneousrows=V.SrNo


 FROM UploadIBPCPool V  
 WHERE ISNULL(PoolID,'')<>''
 AND  AccountID IN(
				 SELECT DISTINCT B.AccountID from PoolNameData a
				 INNER JOIN UploadIBPCPool b
				 on a.PoolID=b.PoolID 
				 where a.PoolName<>b.PoolName
				 )

 END

 -------------PoolType----------------------------------

--DROP TABLE IF EXISTS PoolTypeData
 IF OBJECT_ID('PoolTypeData') IS NOT NULL  
	  BEGIN  
	   DROP TABLE PoolTypeData  
	
	  END

  SELECT * into PoolTypeData  FROM(
 SELECT ROW_NUMBER() OVER(PARTITION BY PoolID  ORDER BY  PoolID ) 
 ROW ,PoolID,PoolType,AccountID FROM UploadIBPCPool
 )X
 WHERE ROW=1


 select @PoolType=COUNT(*) from PoolTypeData a
 INNER JOIN UploadIBPCPool b
 on a.PoolID=b.PoolID 
 where a.PoolType<>b.PoolType

  IF @PoolType>0
 BEGIN
  PRINT 'PoolType ERROR'

  UPDATE UploadIBPCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Different PoolID of same combination of PoolType is Available. Please check the values and upload again'   
						ELSE ErrorMessage+','+SPACE(1)+ 'Different PoolID of same combination of  PoolType is Available. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'PoolType' ELSE   ErrorinColumn +','+SPACE(1)+'PoolType' END     
		,Srnooferroneousrows=V.SrNo


 FROM UploadIBPCPool V  
 WHERE ISNULL(PoolID,'')<>''
 AND AccountID IN(
				 SELECT DISTINCT B.AccountID from PoolTypeData a
				 INNER JOIN UploadIBPCPool b
				 on a.PoolID=b.PoolID 
				 where a.PoolType<>b.PoolType
				 )
 END

 /*Same PoolName present in Multiple poolID*/ -- pRANAY 20-03-21

Declare @PoolNameCnt1 int=0
 --DROP TABLE IF EXISTS PoolNameData1
 IF OBJECT_ID('PoolNameData1') IS NOT NULL  
	  BEGIN  
	   DROP TABLE PoolNameData1  
	
	  END

 SELECT * into PoolNameData1  
 FROM(SELECT ROW_NUMBER() OVER(PARTITION BY PoolID  ORDER BY  PoolID ) ROW,
			PoolID,PoolName,AccountID FROM UploadIBPCPool
	 )X
 WHERE ROW=1


 SELECT @PoolNameCnt1=COUNT(*)
  FROM PoolNameData1 a
 inner JOIN UploadIBPCPool b
 ON a.PoolName=b.PoolName 
 WHERE a.PoolID<>b.PoolID

 IF @PoolNameCnt1>0
 BEGIN
  PRINT 'Same PoolName present in Multiple poolID'
   UPDATE UploadIBPCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Same PoolName present in Multiple poolID. Please check the values and upload again'    
						ELSE ErrorMessage+','+SPACE(1)+ 'Same PoolName present in Multiple poolID. Please check the values and upload again. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'PoolName' ELSE   ErrorinColumn +','+SPACE(1)+'PoolName' END     
		,Srnooferroneousrows=V.SrNo


 FROM UploadIBPCPool V  
 WHERE ISNULL(PoolID,'')<>''
 AND  AccountID IN(
				 SELECT DISTINCT A.AccountID from PoolNameData1 a
				 INNER JOIN UploadIBPCPool b
				 ON a.PoolName=b.PoolName 
				WHERE a.PoolID<>b.PoolID
				 )

 END


 /*
 UPDATE UploadIBPCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Different PoolID of same combination of PoolName and PoolType is Available. Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Different PoolID of same combination of PoolName and PoolType is Available. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'PoolID' ELSE   ErrorinColumn +','+SPACE(1)+'PoolID' END     
		,Srnooferroneousrows=V.SrNo
	--	STUFF((SELECT ','+SRNO 
	--							FROM #UploadNewAccount A
	--							WHERE A.SrNo IN(SELECT V.SrNo FROM #UploadNewAccount V  
 --WHERE ISNULL(ACID,'')<>'' AND ISNULL(TERRITORY,'')<>''
 ----AND SRNO IN(SELECT Srno FROM #DUB2))
 --AND ACID IN(SELECT ACID FROM #DUB2 GROUP BY ACID))

	--							FOR XML PATH ('')
	--							),1,1,'')   

 FROM UploadIBPCPool V  
 WHERE ISNULL(PoolID,'')<>''
 AND PoolID IN(SELECT PoolID FROM #PoolID GROUP BY PoolID)
 */
 ----------------------------------------------
 /*validations on PoolName*/
  
  UPDATE UploadIBPCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'PoolName cannot be blank . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'PoolName cannot be blank . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'PoolName' ELSE   ErrorinColumn +','+SPACE(1)+'PoolName' END   
		,Srnooferroneousrows=V.SrNo

   
   FROM UploadIBPCPool V  
 WHERE ISNULL(PoolName,'')=''


  


 
  UPDATE UploadIBPCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid PoolName above 20 character.  Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid PoolName.  Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'PoolName' ELSE   ErrorinColumn +','+SPACE(1)+'PoolName' END       
		,Srnooferroneousrows=V.SrNo

   
   FROM UploadIBPCPool V  
 WHERE ISNULL(PoolName,'')<>''
 AND LEN(PoolName)>20

 --/*  New Changes in Pool Name  */
 --IF OBJECT_ID('TEMPDB..#PoolName') IS NOT NULL
 --DROP TABLE #PoolName

 --SELECT * INTO #PoolName FROM(
 --SELECT *,ROW_NUMBER() OVER(PARTITION BY PoolID,PoolType ORDER BY  PoolID,PoolType ) ROW FROM UploadIBPCPool
 --)X
 --WHERE ROW>1

 --UPDATE UploadIBPCPool
	--SET  
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'PoolID of same combination of PoolName and PoolType is Available. Please check the values and upload again'     
	--					ELSE ErrorMessage+','+SPACE(1)+ 'PoolID of same combination of PoolName and PoolType is Available. Please check the values and upload again'     END
	--	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'PoolName' ELSE   ErrorinColumn +','+SPACE(1)+'PoolName' END     
	--	,Srnooferroneousrows=V.SrNo
	----	STUFF((SELECT ','+SRNO 
	----							FROM #UploadNewAccount A
	----							WHERE A.SrNo IN(SELECT V.SrNo FROM #UploadNewAccount V  
 ----WHERE ISNULL(ACID,'')<>'' AND ISNULL(TERRITORY,'')<>''
 ------AND SRNO IN(SELECT Srno FROM #DUB2))
 ----AND ACID IN(SELECT ACID FROM #DUB2 GROUP BY ACID))

	----							FOR XML PATH ('')
	----							),1,1,'')   

 --FROM UploadIBPCPool V  
 --WHERE ISNULL(PoolID,'')<>''
 --AND PoolID IN(SELECT PoolID FROM #PoolName GROUP BY PoolID)



 ------------------------------------------------------
 /*validations on PoolType*/
  
  UPDATE UploadIBPCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'PoolType cannot be blank . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'PoolType cannot be blank . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'PoolType' ELSE   ErrorinColumn +','+SPACE(1)+'PoolType' END   
		,Srnooferroneousrows=V.SrNo

   
   FROM UploadIBPCPool V  
 WHERE ISNULL(PoolType,'')=''
 --select * from UploadIBPCPool where PoolType  in  ('With Risk' , 'With out Risk')
  
  UPDATE UploadIBPCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid PoolType.  Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid PoolType.  Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'PoolType' ELSE   ErrorinColumn +','+SPACE(1)+'PoolType' END       
		,Srnooferroneousrows=V.SrNo

   
   FROM UploadIBPCPool V  
 WHERE ISNULL(PoolType,'')<>''
 AND LEN(PoolType)>20

  UPDATE UploadIBPCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid PoolType. Please check the values, With Risk Sharing or Without Risk Sharing  and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid PoolType.  Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'PoolType' ELSE   ErrorinColumn +','+SPACE(1)+'PoolType' END       
		,Srnooferroneousrows=V.SrNo

   
   FROM UploadIBPCPool V  
 WHERE isnull(PoolType,'')  NOT in  ('With Risk Sharing' , 'Without Risk Sharing')

 --/*  New Changes in Pool Type  */
 --IF OBJECT_ID('TEMPDB..#PoolType') IS NOT NULL
 --DROP TABLE #PoolType

 --SELECT * INTO #PoolType FROM(
 --SELECT *,ROW_NUMBER() OVER(PARTITION BY PoolID,PoolName ORDER BY  PoolID,PoolName ) ROW FROM UploadIBPCPool
 --)X
 --WHERE ROW>1

 --UPDATE UploadIBPCPool
	--SET  
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'PoolID of same combination of PoolName and PoolType is Available. Please check the values and upload again'     
	--					ELSE ErrorMessage+','+SPACE(1)+ 'PoolID of same combination of PoolName and PoolType is Available. Please check the values and upload again'     END
	--	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'PoolType' ELSE   ErrorinColumn +','+SPACE(1)+'PoolType' END     
	--	,Srnooferroneousrows=V.SrNo
	----	STUFF((SELECT ','+SRNO 
	----							FROM #UploadNewAccount A
	----							WHERE A.SrNo IN(SELECT V.SrNo FROM #UploadNewAccount V  
 ----WHERE ISNULL(ACID,'')<>'' AND ISNULL(TERRITORY,'')<>''
 ------AND SRNO IN(SELECT Srno FROM #DUB2))
 ----AND ACID IN(SELECT ACID FROM #DUB2 GROUP BY ACID))

	----							FOR XML PATH ('')
	----							),1,1,'')   

 --FROM UploadIBPCPool V  
 --WHERE ISNULL(PoolID,'')<>''
 --AND PoolID IN(SELECT PoolID FROM #PoolType GROUP BY PoolID)



 ------------------------------------------------

/*VALIDATIONS ON AccountID */

  UPDATE UploadIBPCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Account ID cannot be blank.  Please check the values and upload again'     
					ELSE ErrorMessage+','+SPACE(1)+'Account ID cannot be blank.  Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Account ID' ELSE ErrorinColumn +','+SPACE(1)+  'Account ID' END  
		,Srnooferroneousrows=V.SRNO


FROM UploadIBPCPool V  
 WHERE ISNULL(AccountID,'')='' 
 

-- ----SELECT * FROM UploadIBPCPool
  
  UPDATE UploadIBPCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid Account ID found. Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid Account ID found. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Account ID' ELSE ErrorinColumn +','+SPACE(1)+  'Account ID' END  
		,Srnooferroneousrows=V.SRNO
  
		FROM UploadIBPCPool V  
 WHERE ISNULL(V.AccountID,'')<>''
 AND V.AccountID NOT IN(SELECT CustomerACID FROM [CurDat].[AdvAcBasicDetail] 
								WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
						 )



  UPDATE UploadIBPCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid Account ID found. Please Select STD Account and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid Account ID found. Please  Select STD Account and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Account ID' ELSE ErrorinColumn +','+SPACE(1)+  'Account ID' END  
		,Srnooferroneousrows=V.SRNO
  
		FROM UploadIBPCPool V  
 WHERE ISNULL(V.AccountID,'')<>''
 AND V.AccountID NOT IN(SELECT CustomerACID FROM [CurDat].[AdvAcBasicDetail] A
								Inner Join CurDat.AdvAcBalanceDetail B ON A.AccountEntityId=B.AccountEntityId
								And B.EffectiveFromTimeKey<=@Timekey AND B.EffectiveToTimeKey>=@Timekey
								WHERE A.EffectiveFromTimeKey<=@Timekey AND A.EffectiveToTimeKey>=@Timekey
								And B.AssetClassAlt_Key=1
						 ) 

 IF OBJECT_ID('TEMPDB..#DUB2') IS NOT NULL
 DROP TABLE #DUB2

 SELECT * INTO #DUB2 FROM(
 SELECT *,ROW_NUMBER() OVER(PARTITION BY AccountID ORDER BY AccountID ) as rw  FROM UploadIBPCPool
 )X
 WHERE rw>1


 UPDATE V
	SET  
        ErrorMessage=CASE WHEN ISNULL(V.ErrorMessage,'')='' THEN  'Duplicate Account ID found. Please check the values and upload again'     
						ELSE V.ErrorMessage+','+SPACE(1)+'Duplicate Account ID found. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(V.ErrorinColumn,'')='' THEN 'Account ID' ELSE V.ErrorinColumn +','+SPACE(1)+  'Account ID' END  
		,Srnooferroneousrows=V.SRNO
  
		FROM UploadIBPCPool V 
		INNer JOIN #DUB2 D ON D.AccountID=V.AccountID

						
---------------------25042021 Added by Poonam/Anuj--------------------------

UPDATE UploadIBPCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Account ID are pending for authorization'     
						ELSE ErrorMessage+','+SPACE(1)+'Account ID are pending for authorization'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Account ID' ELSE ErrorinColumn +','+SPACE(1)+  'Account ID' END  
		,Srnooferroneousrows=V.SRNO
 FROM UploadIBPCPool V  
 WHERE ISNULL(V.AccountID,'')<>''
 AND V.AccountID  IN (SELECT AccountID FROM IBPCPoolDetail_MOD
								WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
								AND AuthorisationStatus in ('NP','MP','1A','FM')
						UNION
						SELECT AccountID FROM IBPCACFlaggingDetail_Mod
								WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
								AND AuthorisationStatus in ('NP','MP','1A','FM')

						 )
---------------------------------------------------------------------------




 /*  
   UPDATE 

	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Duplicate records found.AccountID are repeated.  Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Duplicate records found. AccountID are repeated.  Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'AccountID' ELSE   ErrorinColumn +','+SPACE(1)+'AccountID' END     
		,Srnooferroneousrows=V.SrNo
	--	STUFF((SELECT ','+SRNO 
	--							FROM #UploadNewAccount A
	--							WHERE A.SrNo IN(SELECT V.SrNo FROM #UploadNewAccount V  
 --WHERE ISNULL(ACID,'')<>'' AND ISNULL(TERRITORY,'')<>''
 ----AND SRNO IN(SELECT Srno FROM #DUB2))
 --AND ACID IN(SELECT ACID FROM #DUB2 GROUP BY ACID))

	--							FOR XML PATH ('')
	--							),1,1,'')   

 FROM UploadIBPCPool V  
 WHERE ISNULL(AccountID,'')<>''
 AND AccountID IN(SELECT AccountID FROM #DUB2 GROUP BY AccountID)
 */

 ----------------------------------------------
 /*   Commented on 29/04/2022 as columns are removed
 
/*VALIDATIONS ON CustomerID */

  UPDATE UploadIBPCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'CustomerID cannot be blank.  Please check the values and upload again'     
					ELSE ErrorMessage+','+SPACE(1)+'CustomerID cannot be blank.  Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'CustomerID' ELSE ErrorinColumn +','+SPACE(1)+  'CustomerID' END  
		,Srnooferroneousrows=V.SRNO
--								----STUFF((SELECT ','+SRNO 
--								----FROM UploadIBPCPool A
--								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadIBPCPool V  
--								----				WHERE ISNULL(ACID,'')='' )
--								----FOR XML PATH ('')
--								----),1,1,'')   

FROM UploadIBPCPool V  
 WHERE ISNULL(CustomerID,'')='' 
 

-- ----SELECT * FROM UploadIBPCPool
  
  UPDATE UploadIBPCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid CustomerID found. Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid CustomerID found. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'CustomerID' ELSE ErrorinColumn +','+SPACE(1)+  'CustomerID' END  
		,Srnooferroneousrows=V.SRNO
--								--STUFF((SELECT ','+SRNO 
--								--FROM UploadIBPCPool A
--								--WHERE A.SrNo IN(SELECT V.SrNo FROM UploadIBPCPool V
--								-- WHERE ISNULL(V.ACID,'')<>''
--								--		AND V.ACID NOT IN(SELECT SystemAcid FROM AxisIntReversalDB.IntReversalDataDetails 
--								--										WHERE -----EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
--								--										Timekey=@Timekey
--								--		))
--								--FOR XML PATH ('')
--								--),1,1,'')   
		FROM UploadIBPCPool V  
		--inner join curdat.AdvAcBasicDetail A on A.CustomerACID=V.AccountID
		--                                and A.EffectiveFromTimeKey<=@Timekey AND A.EffectiveToTimeKey>=@Timekey
 WHERE ISNULL(V.CustomerID,'')<>''
 AND V.CustomerID NOT IN(SELECT RefCustomerId FROM [CurDat].[AdvAcBasicDetail] A
                                         Inner Join UploadIBPCPool V on A.CustomerACID=V.AccountID
								WHERE A.EffectiveFromTimeKey<=@Timekey AND A.EffectiveToTimeKey>=@Timekey
						 )

 --AND V.CustomerID NOT IN(SELECT CustomerID FROM [CurDat].[CustomerBasicDetail] 
                                         
	--							WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
	--					 )


 ----------------------------------------------


---- ----SELECT * FROM UploadIBPCPool
   


/*validations on PrincipalOutstandinginRs */

 UPDATE UploadIBPCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'PrincipalOutstandinginRs cannot be blank. Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'PrincipalOutstandinginRs cannot be blank. Please check the values and upload again'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'PrincipalOutstandinginRs' ELSE ErrorinColumn +','+SPACE(1)+  'PrincipalOutstandinginRs' END  
		,Srnooferroneousrows=V.SRNO
--								----STUFF((SELECT ','+SRNO 
--								----FROM UploadIBPCPool A
--								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadIBPCPool V
--								----WHERE ISNULL(InterestReversalAmount,'')='')
--								----FOR XML PATH ('')
--								----),1,1,'')   

 FROM UploadIBPCPool V  
 WHERE ISNULL(PrincipalOutstandinginRs,'')=''

 UPDATE UploadIBPCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid PrincipalOutstandinginRs. Please check the values and upload again'     
					ELSE ErrorMessage+','+SPACE(1)+'Invalid PrincipalOutstandinginRs. Please check the values and upload again'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'PrincipalOutstandinginRs' ELSE ErrorinColumn +','+SPACE(1)+  'PrincipalOutstandinginRs' END  
		,Srnooferroneousrows=V.SRNO
--								--STUFF((SELECT ','+SRNO 
--								--FROM UploadIBPCPool A
--								--WHERE A.SrNo IN(SELECT V.SrNo FROM UploadIBPCPool V
--								--WHERE (ISNUMERIC(InterestReversalAmount)=0 AND ISNULL(InterestReversalAmount,'')<>'') OR 
--								--ISNUMERIC(InterestReversalAmount) LIKE '%^[0-9]%'
--								--)
--								--FOR XML PATH ('')
--								--),1,1,'')   

 FROM UploadIBPCPool V  
 WHERE (ISNUMERIC(PrincipalOutstandinginRs)=0 AND ISNULL(PrincipalOutstandinginRs,'')<>'') OR 
 ISNUMERIC(PrincipalOutstandinginRs) LIKE '%^[0-9]%'
 PRINT 'INVALID' 

 UPDATE UploadIBPCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid PrincipalOutstandinginRs. Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid PrincipalOutstandinginRs. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'PrincipalOutstandinginRs' ELSE ErrorinColumn +','+SPACE(1)+  'PrincipalOutstandinginRs' END  
		,Srnooferroneousrows=V.SRNO
--								----STUFF((SELECT ','+SRNO 
--								----FROM UploadIBPCPool A
--								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadIBPCPool V
--								---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
--								----)
--								----FOR XML PATH ('')
--								----),1,1,'')   

 FROM UploadIBPCPool V  
 WHERE ISNULL(PrincipalOutstandinginRs,'') LIKE'%[,!@#$%^&*()_-+=/]%'

  UPDATE UploadIBPCPool
	SET  
        ErrorMessage= CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid PrincipalOutstandinginRs. Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid PrincipalOutstandinginRs. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'PrincipalOutstandinginRs' ELSE ErrorinColumn +','+SPACE(1)+  'PrincipalOutstandinginRs' END  
		,Srnooferroneousrows=V.SRNO
--								----STUFF((SELECT ','+SRNO 
--								----FROM UploadIBPCPool A
--								----WHERE A.SrNo IN(SELECT SRNO FROM UploadIBPCPool WHERE ISNULL(InterestReversalAmount,'')<>''
--								---- AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
--								---- )
--								----FOR XML PATH ('')
--								----),1,1,'')   

 FROM UploadIBPCPool V  
 WHERE ISNULL(PrincipalOutstandinginRs,'')<>''
 --AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
 AND TRY_CONVERT(DECIMAL(25,2),ISNULL(PrincipalOutstandinginRs,0)) <0

 -----------------------------------------------------------------
 

/*validations on InterestReceivableinRs */

 UPDATE UploadIBPCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'InterestReceivableinRs cannot be blank. Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'InterestReceivableinRs cannot be blank. Please check the values and upload again'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'InterestReceivableinRs' ELSE ErrorinColumn +','+SPACE(1)+  'InterestReceivableinRs' END  
		,Srnooferroneousrows=V.SRNO
--								----STUFF((SELECT ','+SRNO 
--								----FROM UploadIBPCPool A
--								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadIBPCPool V
--								----WHERE ISNULL(InterestReversalAmount,'')='')
--								----FOR XML PATH ('')
--								----),1,1,'')   

 FROM UploadIBPCPool V  
 WHERE ISNULL(InterestReceivableinRs,'')=''

 UPDATE UploadIBPCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid InterestReceivableinRs. Please check the values and upload again'     
					ELSE ErrorMessage+','+SPACE(1)+'Invalid InterestReceivableinRs. Please check the values and upload again'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'InterestReceivableinRs' ELSE ErrorinColumn +','+SPACE(1)+  'InterestReceivableinRs' END  
		,Srnooferroneousrows=V.SRNO
--								--STUFF((SELECT ','+SRNO 
--								--FROM UploadIBPCPool A
--								--WHERE A.SrNo IN(SELECT V.SrNo FROM UploadIBPCPool V
--								--WHERE (ISNUMERIC(InterestReversalAmount)=0 AND ISNULL(InterestReversalAmount,'')<>'') OR 
--								--ISNUMERIC(InterestReversalAmount) LIKE '%^[0-9]%'
--								--)
--								--FOR XML PATH ('')
--								--),1,1,'')   

 FROM UploadIBPCPool V  
 WHERE (ISNUMERIC(InterestReceivableinRs)=0 AND ISNULL(InterestReceivableinRs,'')<>'') OR 
 ISNUMERIC(InterestReceivableinRs) LIKE '%^[0-9]%'
 PRINT 'INVALID' 

 UPDATE UploadIBPCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid InterestReceivableinRs. Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid InterestReceivableinRs. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'InterestReceivableinRs' ELSE ErrorinColumn +','+SPACE(1)+  'InterestReceivableinRs' END  
		,Srnooferroneousrows=V.SRNO
--								----STUFF((SELECT ','+SRNO 
--								----FROM UploadIBPCPool A
--								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadIBPCPool V
--								---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
--								----)
--								----FOR XML PATH ('')
--								----),1,1,'')   

 FROM UploadIBPCPool V  
 WHERE ISNULL(InterestReceivableinRs,'') LIKE'%[,!@#$%^&*()_-+=/]%'

  UPDATE UploadIBPCPool
	SET  
        ErrorMessage= CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid InterestReceivableinRs. Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid InterestReceivableinRs. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'InterestReceivableinRs' ELSE ErrorinColumn +','+SPACE(1)+  'InterestReceivableinRs' END  
		,Srnooferroneousrows=V.SRNO
--								----STUFF((SELECT ','+SRNO 
--								----FROM UploadIBPCPool A
--								----WHERE A.SrNo IN(SELECT SRNO FROM UploadIBPCPool WHERE ISNULL(InterestReversalAmount,'')<>''
--								---- AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
--								---- )
--								----FOR XML PATH ('')
--								----),1,1,'')   

 FROM UploadIBPCPool V  
 WHERE ISNULL(InterestReceivableinRs,'')<>''
 --AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
 AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReceivableinRs,0)) <0

 -----------------------------------------------------------------
 

/*validations on OSBalanceinRs */

 UPDATE UploadIBPCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'OSBalanceinRs cannot be blank. Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'OSBalanceinRs cannot be blank. Please check the values and upload again'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'OSBalanceinRs' ELSE ErrorinColumn +','+SPACE(1)+  'OSBalanceinRs' END  
		,Srnooferroneousrows=V.SRNO
--								----STUFF((SELECT ','+SRNO 
--								----FROM UploadIBPCPool A
--								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadIBPCPool V
--								----WHERE ISNULL(InterestReversalAmount,'')='')
--								----FOR XML PATH ('')
--								----),1,1,'')   

 FROM UploadIBPCPool V  
 WHERE ISNULL(OSBalanceinRs,'')=''

 UPDATE UploadIBPCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid OSBalanceinRs. Please check the values and upload again'     
					ELSE ErrorMessage+','+SPACE(1)+'Invalid OSBalanceinRs. Please check the values and upload again'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'OSBalanceinRs' ELSE ErrorinColumn +','+SPACE(1)+  'OSBalanceinRs' END  
		,Srnooferroneousrows=V.SRNO
--								--STUFF((SELECT ','+SRNO 
--								--FROM UploadIBPCPool A
--								--WHERE A.SrNo IN(SELECT V.SrNo FROM UploadIBPCPool V
--								--WHERE (ISNUMERIC(InterestReversalAmount)=0 AND ISNULL(InterestReversalAmount,'')<>'') OR 
--								--ISNUMERIC(InterestReversalAmount) LIKE '%^[0-9]%'
--								--)
--								--FOR XML PATH ('')
--								--),1,1,'')   

 FROM UploadIBPCPool V  
 WHERE (ISNUMERIC(OSBalanceinRs)=0 AND ISNULL(OSBalanceinRs,'')<>'') OR 
 ISNUMERIC(OSBalanceinRs) LIKE '%^[0-9]%'
 PRINT 'INVALID' 

 UPDATE UploadIBPCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid OSBalanceinRs. Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid OSBalanceinRs. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'OSBalanceinRs' ELSE ErrorinColumn +','+SPACE(1)+  'OSBalanceinRs' END  
		,Srnooferroneousrows=V.SRNO
--								----STUFF((SELECT ','+SRNO 
--								----FROM UploadIBPCPool A
--								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadIBPCPool V
--								---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
--								----)
--								----FOR XML PATH ('')
--								----),1,1,'')   

 FROM UploadIBPCPool V  
 WHERE ISNULL(OSBalanceinRs,'') LIKE'%[,!@#$%^&*()_-+=/]%'

  UPDATE UploadIBPCPool
	SET  
        ErrorMessage= CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid OSBalanceinRs. Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid OSBalanceinRs. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'OSBalanceinRs' ELSE ErrorinColumn +','+SPACE(1)+  'OSBalanceinRs' END  
		,Srnooferroneousrows=V.SRNO
--								----STUFF((SELECT ','+SRNO 
--								----FROM UploadIBPCPool A
--								----WHERE A.SrNo IN(SELECT SRNO FROM UploadIBPCPool WHERE ISNULL(InterestReversalAmount,'')<>''
--								---- AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
--								---- )
--								----FOR XML PATH ('')
--								----),1,1,'')   

 FROM UploadIBPCPool V  
 WHERE ISNULL(OSBalanceinRs,'')<>''
 --AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
 AND TRY_CONVERT(DECIMAL(25,2),ISNULL(OSBalanceinRs,0)) <0

 -----------------------------------------------------------------

 */

/*validations on IBPCExposureinRs */

 UPDATE UploadIBPCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'IBPCExposureinRs cannot be blank. Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'IBPCExposureinRs cannot be blank. Please check the values and upload again'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'IBPCExposureinRs' ELSE ErrorinColumn +','+SPACE(1)+  'IBPCExposureinRs' END  
		,Srnooferroneousrows=V.SRNO
--								----STUFF((SELECT ','+SRNO 
--								----FROM UploadIBPCPool A
--								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadIBPCPool V
--								----WHERE ISNULL(InterestReversalAmount,'')='')
--								----FOR XML PATH ('')
--								----),1,1,'')   

 FROM UploadIBPCPool V  
 WHERE ISNULL(IBPCExposureinRs,'')=''

 UPDATE UploadIBPCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid IBPCExposureinRs. is not a Zero or Should Not Be Alfa Numberical, Please check the values and upload again'     
					ELSE ErrorMessage+','+SPACE(1)+'Invalid IBPCExposureinRs. is not a Zero or  Should Not Be Alfa Numberical Please check the values and upload again'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'IBPCExposureinRs' ELSE ErrorinColumn +','+SPACE(1)+  'IBPCExposureinRs' END  
		,Srnooferroneousrows=V.SRNO
--								--STUFF((SELECT ','+SRNO 
--								--FROM UploadIBPCPool A
--								--WHERE A.SrNo IN(SELECT V.SrNo FROM UploadIBPCPool V
--								--WHERE (ISNUMERIC(InterestReversalAmount)=0 AND ISNULL(InterestReversalAmount,'')<>'') OR 
--								--ISNUMERIC(InterestReversalAmount) LIKE '%^[0-9]%'
--								--)
--								--FOR XML PATH ('')
--								--),1,1,'')   

 FROM UploadIBPCPool V  
 WHERE ISNUMERIC(IBPCExposureinRs)=0 AND isnull(IBPCExposureinRs,'') not LIKE '%[A-Z a-z]%'

 PRINT 'INVALID' 

 UPDATE UploadIBPCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid IBPCExposureinRs can not allow Special charactor. Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid IBPCExposureinRs can not allow Special charactor. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'IBPCExposureinRs' ELSE ErrorinColumn +','+SPACE(1)+  'IBPCExposureinRs' END  
		,Srnooferroneousrows=V.SRNO
--								----STUFF((SELECT ','+SRNO 
--								----FROM UploadIBPCPool A
--								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadIBPCPool V
--								---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
--								----)
--								----FOR XML PATH ('')
--								----),1,1,'')   

 FROM UploadIBPCPool V  
 WHERE ISNULL(IBPCExposureinRs,'') LIKE'%[,!@#$%^&*()_-+=/]%'

  UPDATE UploadIBPCPool
	SET  
        ErrorMessage= CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid IBPCExposureinRs. Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid IBPCExposureinRs. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'IBPCExposureinRs' ELSE ErrorinColumn +','+SPACE(1)+  'IBPCExposureinRs' END  
		,Srnooferroneousrows=V.SRNO
--								----STUFF((SELECT ','+SRNO 
--								----FROM UploadIBPCPool A
--								----WHERE A.SrNo IN(SELECT SRNO FROM UploadIBPCPool WHERE ISNULL(InterestReversalAmount,'')<>''
--								---- AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
--								---- )
--								----FOR XML PATH ('')
--								----),1,1,'')   

 FROM UploadIBPCPool V  
 WHERE ISNULL(IBPCExposureinRs,'')<>''
 --AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
 AND TRY_CONVERT(DECIMAL(25,2),ISNULL(IBPCExposureinRs,0)) <0


  UPDATE UploadIBPCPool
	SET  
        ErrorMessage= CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'IBPC Exposure value should be less than Balance outstanding . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'IBPC Exposure value should be less than Balance outstanding . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'IBPCExposureinRs' ELSE ErrorinColumn +','+SPACE(1)+  'IBPCExposureinRs' END  
		,Srnooferroneousrows=V.SRNO
 

 FROM UploadIBPCPool V  
 LEFT JOIN AdvAcBalanceDetail B ON V.AccountID = B.RefSystemAcId
 and B.EffectiveFromTimeKey <= @Timekey and B.EffectiveToTimeKey >= @Timekey
 WHERE ISNULL(IBPCExposureinRs,'')<>''
 --AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
 AND (TRY_CONVERT(DECIMAL(25,2),ISNULL(IBPCExposureinRs,0)) <0
 OR TRY_CONVERT(DECIMAL(25,2),ISNULL(IBPCExposureinRs,0)) > Balance)
 
 -----------------------------------------------------------------
 /* Commented on 29/04/2022 as column is removed
 /*validations on DateofIBPCreckoning */

 UPDATE UploadIBPCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'DateofIBPCreckoning Can not be Blank . Please enter the DateofIBPCreckoning and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'DateofIBPCreckoning Can not be Blank. Please enter the DateofIBPCreckoning and upload again'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'DateofIBPCreckoning' ELSE   ErrorinColumn +','+SPACE(1)+'DateofIBPCreckoning' END      
		,Srnooferroneousrows=V.SrNo
		--STUFF((SELECT ','+SRNO 
		--						FROM #UploadNewAccount A
		--						WHERE A.SrNo IN(SELECT V.SrNo  FROM #UploadNewAccount V  
		--										WHERE ISNULL(AssetClass,'')<>'' AND ISNULL(AssetClass,'')<>'STD' and  ISNULL(NPADate,'')=''
		--										)
		--						FOR XML PATH ('')
		--						),1,1,'')   

 FROM UploadIBPCPool V  
 WHERE ISNULL(DateofIBPCreckoning,'')='' 


UPDATE UploadIBPCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'DateofIBPCreckoning' ELSE   ErrorinColumn +','+SPACE(1)+'DateofIBPCreckoning' END      
		,Srnooferroneousrows=V.SrNo
  

 FROM UploadIBPCPool V  
 WHERE ISNULL(DateofIBPCreckoning,'')<>'' AND ISDATE(DateofIBPCreckoning)=0


 
--UPDATE UploadIBPCPool
--	SET  
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'DateofIBPCreckoning Can not be Greater than Other Two. Please enter the Correct Date'     
--						ELSE ErrorMessage+','+SPACE(1)+ 'DateofIBPCreckoning Can not be Greater than Other Two. Please enter the Correct Date'      END
--		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'DateofIBPCreckoning' ELSE   ErrorinColumn +','+SPACE(1)+'DateofIBPCreckoning' END      
--		,Srnooferroneousrows=V.SrNo
--		--STUFF((SELECT ','+SRNO 
--		--						FROM #UploadNewAccount A
--		--						WHERE A.SrNo IN(SELECT V.SrNo  FROM #UploadNewAccount V  
--		--										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))

--		--										)
--		--						FOR XML PATH ('')
--		--						),1,1,'')   

-- FROM UploadIBPCPool V  
-- WHERE ISNULL(DateofIBPCreckoning,'')<>'' AND (Cast(DateofIBPCreckoning as date)>Cast(DateofIBPCmarking as Date) OR Cast(DateofIBPCreckoning as Date)>Cast(MaturityDate as Date))


*/
 --------------------------------------

 
 ---------------------------------/*validations on DateofIBPCmarking */

 UPDATE UploadIBPCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'DateofIBPCmarking Can not be Blank or it is not a Date . Please enter the DateofIBPCmarking and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'DateofIBPCmarking Can not be Blank or it is not a Date. Please enter the DateofIBPCmarking and upload again'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'DateofIBPCmarking' ELSE   ErrorinColumn +','+SPACE(1)+'DateofIBPCmarking' END      
		,Srnooferroneousrows=V.SrNo


 FROM UploadIBPCPool V  
 WHERE ISNULL(DateofIBPCmarking,'')=''  or ISDATE(DateofIBPCmarking)=0


UPDATE UploadIBPCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid date format. Please enter the date in format ‘dd/mm/yyyy’'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid date format. Please enter the date in format ‘dd/mm/yyyy’'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'DateofIBPCmarking' ELSE   ErrorinColumn +','+SPACE(1)+'DateofIBPCmarking' END      
		,Srnooferroneousrows=V.SrNo

 FROM UploadIBPCPool V  
 WHERE  ISDATE(DateofIBPCmarking)=1 and DateofIBPCmarking not like '[0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]%'

 ----------------------Below changes done by Akshay Rathod 03082022------- As per dicussed IBPC Marking date should be <= current date


 UPDATE UploadIBPCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'IBPC marking date should be less than equal to current date. Please check and upload again’'     
						ELSE ErrorMessage+','+SPACE(1)+ 'IBPC marking date should be less than equal to current date. Please check and upload again’'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'DateofIBPCmarking' ELSE   ErrorinColumn +','+SPACE(1)+'DateofIBPCmarking' END      
		,Srnooferroneousrows=V.SrNo


 FROM UploadIBPCPool V  

  WHERE (Case When ISDATE(DateofIBPCmarking)=1 Then Case When Cast(DateofIBPCmarking as date)>Cast(GETDATE() as Date) Then 1 Else 0 END END)=1


 
--UPDATE UploadIBPCPool
--	SET  
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'DateofIBPCreckoning Can not be Greater than Other Maturity and not less to DateofIBPCreckoning. Please enter the Correct Date'     
--						ELSE ErrorMessage+','+SPACE(1)+ 'DateofIBPCreckoning Can not be Greater than Other Maturity and not less to DateofIBPCreckoning. Please enter the Correct Date'      END
--		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'DateofIBPCreckoning' ELSE   ErrorinColumn +','+SPACE(1)+'DateofIBPCreckoning' END      
--		,Srnooferroneousrows=V.SrNo
--		--STUFF((SELECT ','+SRNO 
--		--						FROM #UploadNewAccount A
--		--						WHERE A.SrNo IN(SELECT V.SrNo  FROM #UploadNewAccount V  
--		--										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))

--		--										)
--		--						FOR XML PATH ('')
--		--						),1,1,'')   

-- FROM UploadIBPCPool V  
-- WHERE ISNULL(DateofIBPCmarking,'')<>'' AND (Cast(DateofIBPCmarking as date)<Cast(DateofIBPCreckoning as Date) OR Cast(DateofIBPCmarking as Date)>Cast(MaturityDate as Date))



 --------------------------------------

 
 /*validations on MaturityDate */
 ---------------------------------------------Maturity Date-------------------------------------------------
 UPDATE UploadIBPCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'MaturityDate Can not be Blank . Please enter the MaturityDate and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'MaturityDate Can not be Blank. Please enter the MaturityDate and upload again'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'MaturityDate' ELSE   ErrorinColumn +','+SPACE(1)+'MaturityDate' END      
		,Srnooferroneousrows=V.SrNo
 

 FROM UploadIBPCPool V  
 WHERE ISNULL(MaturityDate,'')='' 


UPDATE UploadIBPCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'MaturityDate' ELSE   ErrorinColumn +','+SPACE(1)+'MaturityDate' END      
		,Srnooferroneousrows=V.SrNo


 FROM UploadIBPCPool V  
 WHERE ISNULL(MaturityDate,'')<>'' AND ISDATE(MaturityDate)=0

 --------------------------------Below logic Implemnted Akshay 03082022 as per discussion 
 UPDATE UploadIBPCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'MaturityDate should be Greater than system date. Please check and enter the date’'     
						ELSE ErrorMessage+','+SPACE(1)+ 'MaturityDate should be Greater than system date. Please check and enter the date’'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'MaturityDate' ELSE   ErrorinColumn +','+SPACE(1)+'MaturityDate' END      
		,Srnooferroneousrows=V.SrNo
 

 FROM UploadIBPCPool V  
 --WHERE ISNULL(MaturityDate,'')<>'' AND ISDATE(MaturityDate)=0

 WHERE (Case When ISDATE(MaturityDate)=1 Then Case When Cast(MaturityDate as date)<Cast(GETDATE() as Date) Then 1 Else 0 END END)=1

 ----------------------------------
 /*         ----- Commented on 21-05-2021  on advice of shishir sir
 ----------------For Flag Checking in main table

 
UPDATE UploadIBPCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Already IBPC Flag is present. Please Check the Account'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Already IBPC Flag is present. Please Check the Account'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'AccountID' ELSE   ErrorinColumn +','+SPACE(1)+'AccountID' END      
		,Srnooferroneousrows=V.SrNo


 FROM UploadIBPCPool V  
 Inner Join Dbo.AdvAcOtherDetail A ON V.AccountID=A.RefSystemAcId And A.EffectiveToTimeKey=49999
 WHERE A.SplFlag like '%IBPC%'

 */
 
--UPDATE UploadIBPCPool
--	SET  
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'MaturityDate Can not be Less than Other Two. Please enter the Correct Date'     
--						ELSE ErrorMessage+','+SPACE(1)+ 'MaturityDate Can not be Less than Other Two. Please enter the Correct Date'      END
--		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'MaturityDate' ELSE   ErrorinColumn +','+SPACE(1)+'MaturityDate' END      
--		,Srnooferroneousrows=V.SrNo
--		--STUFF((SELECT ','+SRNO 
--		--						FROM #UploadNewAccount A
--		--						WHERE A.SrNo IN(SELECT V.SrNo  FROM #UploadNewAccount V  
--		--										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))

--		--										)
--		--						FOR XML PATH ('')
--		--						),1,1,'')   

-- FROM UploadIBPCPool V  
-- WHERE ISNULL(MaturityDate,'')<>'' AND (Cast(MaturityDate as date)<Cast(DateofIBPCreckoning as Date) OR Cast(MaturityDate as Date)<Cast(DateofIBPCmarking as Date))




 --------------------------------------

 /*  Validations on MisMatch DateofIBPCreckoning  */
 --IF OBJECT_ID('TEMPDB..#Date1') IS NOT NULL
 --DROP TABLE #Date1

 --SELECT * INTO #Date1 FROM(
 --SELECT *,ROW_NUMBER() OVER(PARTITION BY PoolID,DateofIBPCreckoning ORDER BY  PoolID,DateofIBPCreckoning ) ROW FROM UploadIBPCPool
 --)X
 --WHERE ROW>1
 /*
 -------------------DateofIBPCreckoning-------------------------- Pranay 20-03-21
 DECLARE @DateofIBPCreckoningCnt INT=0
 --DROP TABLE IF EXISTS DateofIBPCreckoningData
 IF OBJECT_ID('DateofIBPCreckoningData') IS NOT NULL  
	  BEGIN  
	   DROP TABLE DateofIBPCreckoningData  
	
	  END

 SELECT * INTO DateofIBPCreckoningData  FROM(
 SELECT ROW_NUMBER() OVER(PARTITION BY PoolID  ORDER BY  PoolID ) 
 ROW ,PoolID,DateofIBPCreckoning,AccountID FROM UploadIBPCPool
 )X
 WHERE ROW=1


 SELECT @DateofIBPCreckoningCnt=COUNT(*) 
 FROM DateofIBPCreckoningData a
 INNER JOIN UploadIBPCPool b
 ON a.PoolID=b.PoolID 
 WHERE a.DateofIBPCreckoning<>b.DateofIBPCreckoning

 IF @DateofIBPCreckoningCnt>0
 BEGIN
	PRINT 'DateofIBPCreckoning ERROR'

	UPDATE UploadIBPCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'PoolID found different Dates of DateofIBPCreckoning. Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'PoolID found different Dates of DateofIBPCreckoning. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'DateofIBPCreckoning' ELSE   ErrorinColumn +','+SPACE(1)+'DateofIBPCreckoning' END     
		,Srnooferroneousrows=V.SrNo
	--	STUFF((SELECT ','+SRNO 
	--							FROM #UploadNewAccount A
	--							WHERE A.SrNo IN(SELECT V.SrNo FROM #UploadNewAccount V  
 --WHERE ISNULL(ACID,'')<>'' AND ISNULL(TERRITORY,'')<>''
 ----AND SRNO IN(SELECT Srno FROM #DUB2))
 --AND ACID IN(SELECT ACID FROM #DUB2 GROUP BY ACID))

	--							FOR XML PATH ('')
	--							),1,1,'')   

 FROM UploadIBPCPool V  
 WHERE ISNULL(PoolID,'')<>''
 AND  AccountID IN(
				 SELECT DISTINCT B.AccountID from DateofIBPCreckoningData a
				 INNER JOIN UploadIBPCPool  b
				 on a.PoolID=b.PoolID 
				 where a.DateofIBPCreckoning<>b.DateofIBPCreckoning
				 )

 END
 */
 /*
 UPDATE UploadIBPCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'PoolID found different Dates of DateofIBPCreckoning. Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'PoolID found different Dates of DateofIBPCreckoning. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'DateofIBPCreckoning' ELSE   ErrorinColumn +','+SPACE(1)+'DateofIBPCreckoning' END     
		,Srnooferroneousrows=V.SrNo
	--	STUFF((SELECT ','+SRNO 
	--							FROM #UploadNewAccount A
	--							WHERE A.SrNo IN(SELECT V.SrNo FROM #UploadNewAccount V  
 --WHERE ISNULL(ACID,'')<>'' AND ISNULL(TERRITORY,'')<>''
 ----AND SRNO IN(SELECT Srno FROM #DUB2))
 --AND ACID IN(SELECT ACID FROM #DUB2 GROUP BY ACID))

	--							FOR XML PATH ('')
	--							),1,1,'')   

 FROM UploadIBPCPool V  
 WHERE ISNULL(PoolID,'')<>''
 AND PoolID IN(SELECT PoolID FROM #Date1 GROUP BY PoolID)
 */
 ---------------------------------
 
 /*  Validations on MisMatch DateofIBPCmarking  */ ---- Pranay 20-03-21
 --IF OBJECT_ID('TEMPDB..#Date2') IS NOT NULL
 --DROP TABLE #Date2

 --SELECT * INTO #Date2 FROM(
 --SELECT *,ROW_NUMBER() OVER(PARTITION BY PoolID,DateofIBPCmarking ORDER BY  PoolID,DateofIBPCmarking ) ROW FROM UploadIBPCPool
 --)X
 --WHERE ROW>1

 -------------------DateofIBPCmarking--------------------------Pranay 20-03-21
 DECLARE @DateofIBPCmarkingCnt INT=0
 --DROP TABLE IF EXISTS DateofIBPCmarkingData
 IF OBJECT_ID('DateofIBPCmarkingData') IS NOT NULL  
	  BEGIN  
	   DROP TABLE DateofIBPCmarkingData  
	
	  END

 SELECT * INTO DateofIBPCmarkingData  FROM(
 SELECT ROW_NUMBER() OVER(PARTITION BY PoolID  ORDER BY  PoolID ) 
 ROW ,PoolID,DateofIBPCmarking FROM UploadIBPCPool
 )X
 WHERE ROW=1


 SELECT @DateofIBPCmarkingCnt=COUNT(*) 
 FROM DateofIBPCmarkingData a
 INNER JOIN UploadIBPCPool b
 ON a.PoolID=b.PoolID 
 WHERE a.DateofIBPCmarking<>b.DateofIBPCmarking

 IF @DateofIBPCmarkingCnt>0
 BEGIN
	PRINT 'DateofIBPCmarking ERROR'

	UPDATE UploadIBPCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'PoolID found different Dates of DateofIBPCmarking. Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'PoolID found different Dates of DateofIBPCmarking. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'DateofIBPCmarking' ELSE   ErrorinColumn +','+SPACE(1)+'DateofIBPCmarking' END     
		,Srnooferroneousrows=V.SrNo
	--	STUFF((SELECT ','+SRNO 
	--							FROM #UploadNewAccount A
	--							WHERE A.SrNo IN(SELECT V.SrNo FROM #UploadNewAccount V  
 --WHERE ISNULL(ACID,'')<>'' AND ISNULL(TERRITORY,'')<>''
 ----AND SRNO IN(SELECT Srno FROM #DUB2))
 --AND ACID IN(SELECT ACID FROM #DUB2 GROUP BY ACID))

	--							FOR XML PATH ('')
	--							),1,1,'')   

 FROM UploadIBPCPool V  
 WHERE ISNULL(PoolID,'')<>''
 AND  AccountID IN(
				 SELECT DISTINCT B.AccountID from DateofIBPCmarkingData a
				 INNER JOIN UploadIBPCPool b
				 on a.PoolID=b.PoolID 
				 where a.DateofIBPCmarking<>b.DateofIBPCmarking
				 )
 END

 ---------------------------------
 Print '345'
 /*  Validations on MisMatch MaturityDate  */

 --IF OBJECT_ID('TEMPDB..#Date3') IS NOT NULL
 --DROP TABLE #Date3

 --SELECT * INTO #Date3 FROM(
 --SELECT *,ROW_NUMBER() OVER(PARTITION BY PoolID,DateofIBPCmarking ORDER BY  PoolID,DateofIBPCmarking ) ROW FROM UploadIBPCPool
 --)X
 --WHERE ROW>1

 -------------------@MaturityDate--------------------------Pranay 20-03-2021
 DECLARE @MaturityDateCnt int=0
 --DROP TABLE IF EXISTS MaturityDateData
 IF OBJECT_ID('MaturityDateData') IS NOT NULL  
	  BEGIN  
	   DROP TABLE MaturityDateData  
	
	  END

 SELECT * into MaturityDateData  FROM(
 SELECT ROW_NUMBER() OVER(PARTITION BY PoolID  ORDER BY  PoolID ) 
 ROW ,PoolID,MaturityDate FROM UploadIBPCPool
 )X
 WHERE ROW=1


 SELECT @MaturityDateCnt=COUNT(*) 
 FROM MaturityDateData a
 INNER JOIN UploadIBPCPool b
 ON a.PoolID=b.PoolID 
 WHERE a.MaturityDate<>b.MaturityDate

 IF @MaturityDateCnt>0
 BEGIN
  PRINT 'MaturityDate ERROR'

  UPDATE UploadIBPCPool
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'PoolID found different Dates of MaturityDate. Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+ 'PoolID found different Dates of MaturityDate. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'MaturityDate' ELSE   ErrorinColumn +','+SPACE(1)+'MaturityDate' END     
		,Srnooferroneousrows=V.SrNo
	--	STUFF((SELECT ','+SRNO 
	--							FROM #UploadNewAccount A
	--							WHERE A.SrNo IN(SELECT V.SrNo FROM #UploadNewAccount V  
 --WHERE ISNULL(ACID,'')<>'' AND ISNULL(TERRITORY,'')<>''
 ----AND SRNO IN(SELECT Srno FROM #DUB2))
 --AND ACID IN(SELECT ACID FROM #DUB2 GROUP BY ACID))

	--							FOR XML PATH ('')
	--							),1,1,'')   

 FROM UploadIBPCPool V  
 WHERE ISNULL(PoolID,'')<>''
 AND  AccountID IN(
				 SELECT DISTINCT B.AccountID from MaturityDateData a
				 INNER JOIN UploadIBPCPool b
				 on a.PoolID=b.PoolID 
				 where a.MaturityDate<>b.MaturityDate
				 )



 END

 
 
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
		IF NOT EXISTS(Select 1 from  IBPCPoolDetail_stg WHERE filname=@FilePathUpload)
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
			FROM UploadIBPCPool 


			
		--	----SELECT * FROM UploadIBPCPool 

		--	--ORDER BY ErrorMessage,UploadIBPCPool.ErrorinColumn DESC
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

		 IF EXISTS(SELECT 1 FROM IBPCPoolDetail_stg WHERE filname=@FilePathUpload)
		 BEGIN
		DELETE FROM IBPCPoolDetail_stg
		 WHERE filname=@FilePathUpload

		 PRINT 1

		 PRINT 'ROWS DELETED FROM DBO.IBPCPoolDetail_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
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

	----SELECT * FROM UploadIBPCPool

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