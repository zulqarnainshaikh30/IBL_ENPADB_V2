SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[ValidateExcel_DataUpload_Prov_Category]  
@MenuID INT=10,  
@UserLoginId  VARCHAR(20)='fnachecker',  
@Timekey INT=49999
,@filepath VARCHAR(MAX) ='ProvCategory.xlsx'  
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
 
 Select   @Timekey=Max(Timekey) from sysDayMatrix where Cast(date as Date)=cast(getdate() as Date)

  PRINT @Timekey  
  
 
  ----declare @UserLoginId  VARCHAR(20)='fnachecker' ,@filepath VARCHAR(MAX) ='ProvCategory.xlsx' 
  DECLARE @FilePathUpload	VARCHAR(100)

			SET @FilePathUpload=@UserLoginId+'_'+@filepath
	PRINT '@FilePathUpload'
	PRINT @FilePathUpload

	IF EXISTS(SELECT 1 FROM dbo.MasterUploadData    where FileNames=@filepath )
	BEGIN
		Delete from dbo.MasterUploadData    where FileNames=@filepath  
		print @@rowcount
	END


IF (@MenuID=1468)	
BEGIN


	  -- IF OBJECT_ID('tempdb..UploadProCategory') IS NOT NULL  
	  IF OBJECT_ID('UploadProCategory') IS NOT NULL  
	  BEGIN  
	   DROP TABLE UploadProCategory  
	
	  END
	  
  IF NOT (EXISTS (SELECT 1 FROM categorydetails_stg where FilName=@FilePathUpload))

BEGIN
print 'NO DATA'
			Insert into dbo.MasterUploadData
			(SR_No,ColumnName,ErrorData,ErrorType,FileNames,Flag) 
			SELECT 0 SRNO , '' ColumnName,'' ErrorData,'' ErrorType,@filepath,'SUCCESS' 
			--SELECT 0 SRNO , '' ColumnName,'' ErrorData,'' ErrorType,@filepath,'SUCCESS' 

			goto errordata
    
END

ELSE
BEGIN
PRINT 'DATA PRESENT'
	   Select *,CAST('' AS varchar(MAX)) ErrorMessage,CAST('' AS varchar(MAX)) ErrorinColumn,CAST('' AS varchar(MAX)) Srnooferroneousrows
 	   into UploadProCategory 
	   from categorydetails_stg 
	   WHERE FilName=@FilePathUpload

	  
END
  ------------------------------------------------------------------------------  
    ----SELECT * FROM UploadProCategory
	--SrNo	Territory	ACID	InterestReversalAmount	filname
	UPDATE UploadProCategory
	SET  
        ErrorMessage='There is no data in excel. Kindly check and upload again' 
		,ErrorinColumn='SlNo,ACID,CustomerID,CategoryID,Action'    
		,Srnooferroneousrows=''
 FROM UploadProCategory V  
 WHERE ISNULL(SlNo,'')=''
  AND ISNULL(ACID,'')=''
  AND ISNULL(CustomerID,'')=''
  AND ISNULL(CategoryID,'')=''
  AND ISNULL(Action,'')=''

 
-- ISNULL(PoolID,'')=''
--AND ISNULL(PoolName,'')=''
--AND ISNULL(PoolType,'')=''
--AND ISNULL(AccountID,'')=''
--AND ISNULL(CustomerID,'')=''
--AND ISNULL(PrincipalOutstandinginRs,'')=''
--AND ISNULL(InterestReceivableinRs,'')=''
--AND ISNULL(OSBalanceinRs,'')=''
--AND ISNULL(IBPCExposureinRs,'')=''
--AND ISNULL(DateofIBPCreckoning,'')=''
--AND ISNULL(DateofIBPCmarking,'')=''
--AND ISNULL(MaturityDate,'')=''

  IF EXISTS(SELECT 1 FROM UploadProCategory WHERE ISNULL(ErrorMessage,'')<>'')
  BEGIN
  PRINT 'ACID'
  GOTO ERRORDATA;
  END
-------------------------------------


 -----validations on Srno
 
	 UPDATE UploadProCategory
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 
		
		'Sr. No. cannot be blank.  Please check the values and upload again' 
		ELSE ErrorMessage+','+SPACE(1)+ 'Sr. No. cannot be blank.  Please check the values and upload again'
		END
		,ErrorinColumn='SRNO'    
		,Srnooferroneousrows=''
	FROM UploadProCategory V  
	WHERE ISNULL(v.SlNo,'')=''  

 --UPDATE UploadProCategory
	--SET  
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid Sr. No.  Please check the values and upload again'     
	--							  ELSE ErrorMessage+','+SPACE(1)+ 'Invalid Sr. No.  Please check the values and upload again'      END
	--	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SRNO' ELSE ErrorinColumn +','+SPACE(1)+  'SRNO' END     
	--	,Srnooferroneousrows=SlNo
		
 --FROM UploadProCategory V  
 --WHERE ISNULL(v.SlNo,'')=0   OR ISNULL(v.SlNo,'')<0

 Print 123
 UPDATE UploadProCategory
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid Sr. No.  Please check the values and upload again'     
								  ELSE ErrorMessage+','+SPACE(1)+ 'Invalid Sr. No.  Please check the values and upload again'      END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SRNO' ELSE ErrorinColumn +','+SPACE(1)+  'SRNO' END     
		,Srnooferroneousrows=SlNo
		
 FROM UploadProCategory V  
 WHERE ISNUMERIC(v.SlNo)=0  
  
  
  IF OBJECT_ID('TEMPDB..#R2') IS NOT NULL
  DROP TABLE #R2

  SELECT * INTO #R2 FROM(
  SELECT *,ROW_NUMBER() OVER(PARTITION BY SlNO ORDER BY SlNO)ROW
   FROM UploadProCategory
   )A
   WHERE ROW>1

 PRINT 'DUB'  


  UPDATE UploadProCategory
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Following sr. no. are repeated' 
					ELSE ErrorMessage+','+SPACE(1)+     'Following sr. no. are repeated' END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SRNO' ELSE ErrorinColumn +','+SPACE(1)+  'SRNO' END     
		,Srnooferroneousrows=V.SlNo
								--STUFF((SELECT DISTINCT ','+SRNO 
								--FROM #UploadNewAccount
								--FOR XML PATH ('')
								--),1,1,'')
         
		
 FROM UploadProCategory V  
	WHERE  V.Slno IN(SELECT distinct Slno FROM #R2 )
----------------------------------
  
  /*validations on ACID*/
  
  UPDATE UploadProCategory
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'ACID cannot be blank . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'ACID cannot be blank . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'ACID' ELSE   ErrorinColumn +','+SPACE(1)+'ACID' END   
		,Srnooferroneousrows=V.SlNo
								
   
   FROM UploadProCategory V  
 WHERE ISNULL(ACID,'')=''

 
 
  UPDATE UploadProCategory
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid ACID.  Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid ACID.  Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'ACID' ELSE   ErrorinColumn +','+SPACE(1)+'ACID' END       
		,Srnooferroneousrows=V.SlNo

   FROM UploadProCategory V  
 WHERE ISNULL(ACID,'')<>''
 AND LEN(ACID)>16

   UPDATE UploadProCategory
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid Account ID found. Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid Account ID found. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Account ID' ELSE ErrorinColumn +','+SPACE(1)+  'Account ID' END  
		,Srnooferroneousrows=V.SlNo
  --select *
		FROM UploadProCategory V  
 WHERE ISNULL(V.ACID,'')<>''
 AND V.ACID NOT IN(SELECT CustomerACID FROM [CurDat].[AdvAcBasicDetail] 
								WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey)



 IF OBJECT_ID('TEMPDB..#DUB2') IS NOT NULL
 DROP TABLE #DUB2

 SELECT * INTO #DUB2 FROM(
 SELECT *,ROW_NUMBER() OVER(PARTITION BY ACID ORDER BY ACID ) as rw  FROM UploadProCategory
 )X
 WHERE rw>1

 --Select * from #DUB2
 UPDATE V
	SET  
        ErrorMessage=CASE WHEN ISNULL(V.ErrorMessage,'')='' THEN  'Duplicate Account ID found. Please check the values and upload again'     
						ELSE V.ErrorMessage+','+SPACE(1)+'Duplicate Account ID found. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(V.ErrorinColumn,'')='' THEN 'Account ID' ELSE V.ErrorinColumn +','+SPACE(1)+  'Account ID' END  
		,Srnooferroneousrows=V.SlNo
  
		FROM UploadProCategory V 
		INNer JOIN #DUB2 D ON D.ACID=V.ACID


		UPDATE UploadProCategory
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Account ID are pending for authorization'     
						ELSE ErrorMessage+','+SPACE(1)+'Account ID are pending for authorization'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Account ID' ELSE ErrorinColumn +','+SPACE(1)+  'Account ID' END  
		,Srnooferroneousrows=V.SlNo
  
		FROM UploadProCategory V  
 WHERE ISNULL(V.ACID,'')<>''
 AND (V.ACID  IN (SELECT ACID FROM AcCatUploadHistory_Mod
								WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
								AND AuthorisationStatus in ('NP','MP','1A','FM','A')
						 ) OR
						 V.ACID  IN (SELECT ACID FROM AcCatUploadHistory
								WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
								AND AuthorisationStatus in ('NP','MP','1A','FM','A')
						 )
						 )

 
  /*validations on CustomerID*/
  
  UPDATE UploadProCategory
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'CustomerID cannot be blank . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'CustomerID cannot be blank . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'CustomerID' ELSE   ErrorinColumn +','+SPACE(1)+'CustomerID' END   
		,Srnooferroneousrows=V.SlNo
								
   
   FROM UploadProCategory V  
 WHERE ISNULL(CustomerID,'')=''

 
 
  UPDATE UploadProCategory
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid CustomerID.  Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid CustomerID.  Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'CustomerID' ELSE   ErrorinColumn +','+SPACE(1)+'CustomerID' END       
		,Srnooferroneousrows=V.SlNo

   FROM UploadProCategory V  
 WHERE ISNULL(CustomerID,'')<>''
 --AND LEN(CustomerID)>16
  --AND V.CustomerID NOT IN(SELECT CustomerID FROM [CurDat].[CustomerBasicDetail] 
		--						WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey)

AND V.CustomerID NOT IN(SELECT RefCustomerId FROM [CurDat].[AdvAcBasicDetail] A
                                                 Inner Join UploadProCategory V on A.CustomerACID=V.ACID
								WHERE A.EffectiveFromTimeKey<=@Timekey AND A.EffectiveToTimeKey>=@Timekey
								)
 /*validations on CategoryID  Sac*/

  
  UPDATE UploadProCategory
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid values in ‘CategoryID’. Kindly check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid values in ‘CategoryID’. Kindly check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'CategoryID' ELSE   ErrorinColumn +','+SPACE(1)+'CategoryID' END       
		,Srnooferroneousrows=V.SlNo


   FROM UploadProCategory V  
  WHERE (ISNUMERIC(CategoryID)=0 AND ISNULL(CategoryID,'')<>'') OR 
 ISNUMERIC(CategoryID) LIKE '%^[0-9]%'

 IF OBJECT_ID('TEMPDB..#EXISTDATA')IS NOT NULL
				DROP TABLE #EXISTDATA
				Declare @ProvisionPercent decimal(10,0)
								SELECT A.ACID
								, MAX(D.Provisionsecured)ProvisionPercent						
								--,d.provisionname
								 INTO #EXISTDATA
								 FROM categorydetails_stg A
								--INNER JOIN AdvAcBasicDetail B
								--			on B.CustomerAcId=A.acid
									INNER JOIN DimProvision_SegStd D
											ON (case when isnumeric(A.CategoryID)=1 then A.CategoryID else 0 end)=D.BankCategoryID  
											group by A.ACID 
----select * from AcCatUploadHistory
 IF OBJECT_ID('TEMPDB..#EXISTDATA1')IS NOT NULL
				DROP TABLE #EXISTDATA1
					Select B.acid into #EXISTDATA1 from(																
	SELECT A.ACID  , MAX(D.Provisionsecured)ProvisionPercent	 
	 FROM AcCatUploadHistory A 
	inner join  DimProvision_SegStd D ON (case when isnumeric(A.CategoryID)=1 then A.CategoryID else 0 end)=D.BankCategoryID 
	    group by A.ACID
	)b inner join  #EXISTDATA E on b.ACID=E.ACID
	Where b.ProvisionPercent>E.ProvisionPercent 
	  
  UPDATE U
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Category ID is Lowest . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'CategoryID is Lowest. Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'CategoryID' ELSE   ErrorinColumn +','+SPACE(1)+'CategoryID' END   
		,Srnooferroneousrows=U.SlNo from UploadProCategory U inner join #EXISTDATA1  E on U.ACID=E.ACID
		Where U.Action='A'
								
  
  --select * from DimProvision_SegStd
	
  
  UPDATE UploadProCategory
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'CategoryID cannot be blank . Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'CategoryID cannot be blank . Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'CategoryID' ELSE   ErrorinColumn +','+SPACE(1)+'CategoryID' END   
		,Srnooferroneousrows=V.SlNo
								
   
   FROM UploadProCategory V  
 WHERE ISNULL(CategoryID,'')=''

 
 
  UPDATE UploadProCategory
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid CategoryID.  Please check the values and upload again' 
						ELSE ErrorMessage+','+SPACE(1)+'Invalid CategoryID.  Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'CategoryID' ELSE   ErrorinColumn +','+SPACE(1)+'CategoryID' END       
		,Srnooferroneousrows=V.SlNo

   FROM UploadProCategory V  
 WHERE ISNULL(CategoryID,'')<>''
 AND LEN(CategoryID)>16

 
  UPDATE UploadProCategory
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid CategoryID.  Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid CategoryID.  Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'CategoryID' ELSE   ErrorinColumn +','+SPACE(1)+'CategoryID' END       
		,Srnooferroneousrows=V.SlNo
--select *
   FROM UploadProCategory V  
   --Inner Join DimProvision_SegStd A ON A.BankCategoryID=V.CategoryID
 WHERE V.CategoryID  not in (select BankCategoryID  from DimProvision_SegStd A where A.BankCategoryID=(CASE WHEN ISNUMERIC(V.CategoryID)=1 THEN V.CategoryID ELSE 0 END) And A.EffectiveToTimeKey=49999)
 
 
 
  UPDATE UploadProCategory
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Account has Already Same CategoryID.  Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Account has Already Same CategoryID.  Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'CategoryID' ELSE   ErrorinColumn +','+SPACE(1)+'CategoryID' END       
		,Srnooferroneousrows=V.SlNo
--select *
   FROM UploadProCategory V  
   --Inner Join DimProvision_SegStd A ON A.BankCategoryID=V.CategoryID
 --WHERE V.CategoryID  not in (select BankCategoryID  from DimProvision_SegStd A where A.BankCategoryID=V.CategoryID And A.EffectiveToTimeKey=49999)
 Where EXISTS(				                
					SELECT  1 FROM AcCatUploadHistory A WHERE A.CategoryID=(case when isnumeric(V.CategoryID)=1 then V.CategoryID else 0 end) And A.ACID=V.ACID And A.EffectiveToTimeKey=49999 AND ISNULL(A.AuthorisationStatus,'A')='A' 
					UNION
					SELECT  1 FROM AcCatUploadHistory_Mod B WHERE B.CategoryID=(case when isnumeric(V.CategoryID)=1 then V.CategoryID else 0 end) And B.ACID=V.ACID And B.EffectiveToTimeKey=49999 
															AND   ISNULL(B.AuthorisationStatus,'A') in('NP','MP','DP','RM') 
				) And V.Action='A'
 
 
 
  UPDATE UploadProCategory
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Account has Not Marked in CategoryID.  Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Account has Not Marked in CategoryID.  Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'CategoryID' ELSE   ErrorinColumn +','+SPACE(1)+'CategoryID' END       
		,Srnooferroneousrows=V.SlNo
--select *
   FROM UploadProCategory V  
   --Inner Join DimProvision_SegStd A ON A.BankCategoryID=V.CategoryID
 --WHERE V.CategoryID  not in (select BankCategoryID  from DimProvision_SegStd A where A.BankCategoryID=V.CategoryID And A.EffectiveToTimeKey=49999)
 Where Not EXISTS(				                
					SELECT  1 FROM AcCatUploadHistory A WHERE A.CategoryID=(case when isnumeric(V.CategoryID)=1 then V.CategoryID else 0 end) And A.ACID=V.ACID And A.EffectiveToTimeKey=49999 AND ISNULL(A.AuthorisationStatus,'A')='A' 
					UNION
					SELECT  1 FROM AcCatUploadHistory_Mod B WHERE B.CategoryID=(case when isnumeric(V.CategoryID)=1 then V.CategoryID else 0 end) And B.ACID=V.ACID And B.EffectiveToTimeKey=49999 
															AND   ISNULL(B.AuthorisationStatus,'A') in('NP','MP','DP','RM') 
				) And V.Action='R'
 



 /*validations on Action*/
 
  UPDATE UploadProCategory
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid Action.  Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Invalid Action.  Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Action' ELSE   ErrorinColumn +','+SPACE(1)+'Action' END       
		,Srnooferroneousrows=V.SlNo

   FROM UploadProCategory V  
 WHERE  V.Action  NOT IN( 'A','R')
 AND LEN(Action)=1


 UPDATE UploadProCategory
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Action cannot be blank it Should be (A OR R) .  Please check the values and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Action cannot be blank it Should be (A OR R).  Please check the values and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Action' ELSE   ErrorinColumn +','+SPACE(1)+'Action' END       
		,Srnooferroneousrows=V.SLNO

   
   FROM UploadProCategory V

 WHERE ISNULL(Action,'')='' 

  ---------------------------------------Sudesh Gambhira 03082022 add below validation -----
 
 UPDATE UploadProCategory
 
        	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'This Action is Already Marked on this Account.  Please check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'This Action is Already Marked on this Account.  Please check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Action' ELSE   ErrorinColumn +','+SPACE(1)+'Action' END       
		,Srnooferroneousrows=V.SlNo
 FROM UploadProCategory V  
 WHERE Action in  ('A')
 And  exists (Select 1 FRom AcCatUploadHistory A where A.ACID=V.ACID  And A.EffectiveToTimeKey=49999
	-- And AuthorisationStatus In ('A'))
	and isnull(AuthorisationStatus,'A')='A')


	  
   UPDATE UploadProCategory
	SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Account is not Marked with Action A, for performing Acion R.  Please check and upload again'     
						ELSE ErrorMessage+','+SPACE(1)+'Account is not Marked with Action A, for performing Acion R.  Please check and upload again'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Action' ELSE   ErrorinColumn +','+SPACE(1)+'Action' END       
		,Srnooferroneousrows=V.SlNo
FROM UploadProCategory V  
 WHERE Action in  ('R')
 And not exists (Select 1 FRom AcCatUploadHistory A where A.ACID=V.ACID  And A.EffectiveToTimeKey=49999
	 And AuthorisationStatus In ('A','R'))

---------------------------------------------
 --IF OBJECT_ID('TEMPDB..#DUB2') IS NOT NULL
 --DROP TABLE #DUB2

 --SELECT * INTO #DUB2 FROM(
 --SELECT *,ROW_NUMBER() OVER(PARTITION BY ACID ORDER BY ACID ) ROW FROM UploadProCategory
 --)X
 --WHERE ROW>1



 Print '123'
 goto valid

  END
	
   ErrorData:  
  -- print 'no'  

		SELECT *,'Data'TableName
		FROM dbo.MasterUploadData WHERE FileNames=@filepath 
		return

   valid:
		IF NOT EXISTS(Select 1 from  categorydetails_stg WHERE FilName=@FilePathUpload)
		BEGIN
		PRINT 'NO ERRORS'
			
			Insert into dbo.MasterUploadData
			(SR_No,ColumnName,ErrorData,ErrorType,FileNames,Flag) 
			SELECT '' SRNO , '' ColumnName,'' ErrorData,'' ErrorType,@filepath,'SUCCESS' 
			
		END
		ELSE
		BEGIN
			PRINT 'VALIDATION ERRORS'
			insert into dbo.MasterUploadData
			--(SR_No,ColumnName,ErrorData,ErrorType,FileNames,Srnooferroneousrows,Flag) 
			(ColumnName,ErrorData,ErrorType,FileNames,Srnooferroneousrows,Flag) 
			SELECT --SlNo,
			ErrorinColumn,ErrorMessage,ErrorinColumn,@filepath,Srnooferroneousrows,'SUCCESS' 
			FROM UploadProCategory 

			PRINT 'VALIDATION ERRORS1'
			goto final
		END

		

  IF EXISTS (SELECT 1 FROM  dbo.MasterUploadData   WHERE FileNames=@filepath AND  ISNULL(ERRORDATA,'')<>'') 
   -- added for delete Upload status while error while uploading data.  
   BEGIN  
   Print 'Delete Upload status'
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
  Print 'UpdaTE Upload status'
    Update UploadStatus Set ValidationOfData='Y',ValidationOfDataCompletedOn=GetDate()   
    where FileNames=@filepath  
  
   END  


  final:
  Print 'vj'
  pRINT @filepath
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

		 IF EXISTS(SELECT 1 FROM categorydetails_stg WHERE FilName=@FilePathUpload)
		 BEGIN
		 DELETE FROM categorydetails_stg
		 WHERE FilName=@FilePathUpload
		 
		 PRINT 1

		 PRINT 'ROWS DELETED FROM DBO.AcCatUploadHistory_Stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
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

	----SELECT * FROM UploadProCategory

	print 'p'

   
END  TRY
  
  BEGIN CATCH
	

	INSERT INTO dbo.Error_Log
				SELECT ERROR_LINE() as ErrorLine,ERROR_MESSAGE()ErrorMessage,ERROR_NUMBER()ErrorNumber
				,ERROR_PROCEDURE()ErrorProcedure,ERROR_SEVERITY()ErrorSeverity,ERROR_STATE()ErrorState
				,GETDATE()

END CATCH

END

GO