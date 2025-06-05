SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROCEDURE  [dbo].[ACNPAMOCStageDataInUp]
	@Timekey INT,
	@UserLoginID VARCHAR(100),
	@OperationFlag INT,
	@MenuId INT,
	@AuthMode	CHAR(1),
	@filepath VARCHAR(MAX),
	@EffectiveFromTimeKey INT,
	@EffectiveToTimeKey	INT,
    @Result		INT=0 OUTPUT,
	@UniqueUploadID INT,
	@Authlevel varchar(5)

AS

--DECLARE @Timekey INT=24928,
--	@UserLoginID VARCHAR(100)='FNAOPERATOR',
--	@OperationFlag INT=1,
--	@MenuId INT=163,
--	@AuthMode	CHAR(1)='N',
--	@filepath VARCHAR(MAX)='',
--	@EffectiveFromTimeKey INT=24928,
--	@EffectiveToTimeKey	INT=49999,
--    @Result		INT=0 ,
--	@UniqueUploadID INT=41
BEGIN
SET DATEFORMAT DMY
	SET NOCOUNT ON;

   
   --DECLARE @Timekey INT
   --SET @Timekey=(SELECT MAX(TIMEKEY) FROM dbo.SysProcessingCycle
			--	WHERE ProcessType='Quarterly')

			--Set @Timekey=(select CAST(B.timekey as int)from SysDataMatrix A
			--Inner Join SysDayMatrix B ON A.TimeKey=B.TimeKey
			-- where A.CurrentStatus='C')
  --SET @Timekey =(Select TimeKey from SysDataMatrix where CurrentStatus='C') 

  --SET @Timekey =(Select LastMonthDateKey from SysDayMatrix where Timekey=@Timekey) 

  --DECLARE @LastMonthDate date = (select  LastMonthDate from SysDayMatrix where Timekey in (select  Timekey from sysdatamatrix where CurrentStatus = 'C'))


    DECLARE @MocDate date
  
	SET @Timekey =(Select Timekey from SysDataMatrix Where MOC_Initialised='Y' AND ISNULL(MOC_Frozen,'N')='N') 
	SET @MocDate =(Select ExtDate from SysDataMatrix Where MOC_Initialised='Y' AND ISNULL(MOC_Frozen,'N')='N')

	PRINT @TIMEKEY

	SET @EffectiveFromTimeKey=@TimeKey
	SET @EffectiveToTimeKey=49999


	DECLARE @FilePathUpload	VARCHAR(100)
				   SET @FilePathUpload=@UserLoginId+'_'+@filepath
					PRINT '@FilePathUpload'
					PRINT @FilePathUpload


		BEGIN TRY

		--BEGIN TRAN
		
IF (@MenuId=24715)
BEGIN


	IF (@OperationFlag=1)

	BEGIN

		IF NOT (EXISTS (SELECT 1 FROM AccountLvlMOCDetails_stg  where filname=@FilePathUpload))

							BEGIN
									 --Rollback tran
									SET @Result=-8

								RETURN @Result
							END
			
                   Print 'Sachin'
				   

		IF EXISTS(SELECT 1 FROM AccountLvlMOCDetails_stg WHERE filname=@FilePathUpload)
		BEGIN
		
		INSERT INTO ExcelUploadHistory
	(
		UploadedBy	
		,DateofUpload	
		,AuthorisationStatus	
		--,Action	
		,UploadType
		,EffectiveFromTimeKey	
		,EffectiveToTimeKey	
		,CreatedBy	
		,DateCreated	
		
	)

	SELECT @UserLoginID
		   ,GETDATE()
		   ,'NP'
		   --,'NP'
		   ,'Account MOC Upload'
		   ,@EffectiveFromTimeKey
		   ,@EffectiveToTimeKey
		   ,@UserLoginID
		   ,GETDATE()


			   PRINT @@ROWCOUNT
			   print 'Prashant'
		   DECLARE @ExcelUploadId INT
	SET 	@ExcelUploadId=(SELECT MAX(UniqueUploadID) FROM  ExcelUploadHistory)
		
			Insert into UploadStatus (FileNames,UploadedBy,UploadDateTime,UploadType)
		Values(@filepath,@UserLoginID ,GETDATE(),'Account MOC Upload')

		


		--INSERT INTO AccountMOCDetail_MOD
		--(
		--	 SrNo
		--	,UploadID
			
		--	,SlNo
		--	,AccountID
		--	,POSinRs
		--	,InterestReceivableinRs
		--	,AdditionalProvisionAbsoluteinRs
		--	,RestructureFlag
		--	,RestructureDat
		--	,FITLFlag
		--	,DFVAmount
		--	,RePossesssionFlag
		--	,RePossessionDate
		--	,InherentWeaknessFlag
		--	,InherentWeaknessDate
		--	,SARFAESIFlag
		--	,SARFAESIDate
		--	,UnusualBounceFlag
		--	,UnusualBounceDate
		--	,UnclearedEffectsFlag
		--	,UnclearedEffectsDate
		--	,FraudFlag
		--	,FraudDate
		--	,MOCSource
		--	,MOCReason
		--	,AuthorisationStatus	
		--	,EffectiveFromTimeKey	
		--	,EffectiveToTimeKey	
		--	,CreatedBy	
		--	,DateCreated
		--	,ScreenFlag
		--)
		 
		--SELECT
		--	 SlNo
		--	,@ExcelUploadId
			
		--	,SlNo
		--	,AccountID
		--	,POSinRs
		--	,InterestReceivableinRs
		--	,AdditionalProvisionAbsoluteinRs
		--	,RestructureFlagYN
		--	,RestructureDate	
		--	,FITLFlagYN
		--	,DFVAmount
		--	,RePossesssionFlagYN
		--	,RePossessionDate
		--	,InherentWeaknessFlag
		--	,InherentWeaknessDate
		--	,SARFAESIFlag
		--	,SARFAESIDate
		--	,UnusualBounceFlag
		--	,UnusualBounceDate
		--	,UnclearedEffectsFlag
		--	,UnclearedEffectsDate
		--	,FraudFlag
		--	,FraudDate
		--	,MOCSource
		--	,MOCReason
		--	,'NP'	
		--	,@Timekey
		--	,@TimeKey	
		--	,@UserLoginID	
		--	,GETDATE()	
		--	,'U'
		--FROM AccountLvlMOCDetails_stg
		--where filname=@FilePathUpload
		SET DATEFORMAT DMY
		
		

		INSERT INTO AccountLevelMOC_Mod
		(
			 SrNo
			,UploadID
			
			
			,AccountID
			--,POS
			--,InterestReceivable
			,AdditionalProvisionAbsolute
			--,RestructureFlag
   --         ,RestructureDate

			--,FITLFlag
			--,DFVAmount
			--,RePossessionFlag
			--,RePossessionDate
			--,InherentWeaknessFlag
			--,InherentWeaknessDate
			--,SARFAESIFlag
			--,SARFAESIDate
			--,UnusualBounceFlag
			--,UnusualBounceDate
			--,UnclearedEffectsFlag
			--,UnclearedEffectsDate
			--,FraudAccountFlag
			--,FraudDate
			,MOCSource
			,MOCReason
			,AuthorisationStatus	
			,EffectiveFromTimeKey	
			,EffectiveToTimeKey	
			,CreatedBy	
			,DateCreated
			,ScreenFlag
			,ChangeField
			--,FlgTwo
            --,TwoDate
            --,TwoAmount
			,MOCDate
			,MOC_TYPEFLAG
			,MOC_Reason_Remark                                   ---Added by kapil on 28/11/2023
			,AddlProvPer
			,MOCType
			
		)
		 
		SELECT
			 SlNo
			,@ExcelUploadId
			
		
			,AccountID
			--,POSinRs
			--,ISNULL(case when isnull(POSinRs,'')<>'' then CAST(ISNULL(CAST(POSinRs AS DECIMAL(16,2)),0) AS DECIMAL(30,2))   end,NULL) POSinRs
			--,InterestReceivableinRs
			--,ISNULL(case when isnull(InterestReceivableinRs,'')<>'' then CAST(ISNULL(CAST(InterestReceivableinRs AS DECIMAL(16,2)),0) AS DECIMAL(30,2))   end,NULL) InterestReceivableinRs
			--,AdditionalProvisionAbsoluteinRs
			,ISNULL(case when isnull(AdditionalProvisionAbsoluteinRs,'')<>'' then CAST(ISNULL(CAST(AdditionalProvisionAbsoluteinRs AS DECIMAL(16,2)),0) AS DECIMAL(30,2))   end,NULL)                                                               AdditionalProvisionAbsoluteinRs





			--,RestructureFlagYN
			--,Case When RestructureDate<>''	Then RestructureDate Else NULL END RestructureDate
			--,FITLFlagYN
			--,DFVAmount
			--,ISNULL(case when isnull(DFVAmount,'')<>'' then CAST(ISNULL(CAST(DFVAmount AS DECIMAL(16,2)),0) AS DECIMAL(30,2))   end,NULL)  DFVAmount
			--,RePossesssionFlagYN
			--,Case When RePossessionDate<>''	Then RePossessionDate Else NULL END RePossessionDate
			--,InherentWeaknessFlag
			--,Case When InherentWeaknessDate<>''	Then InherentWeaknessDate Else NULL END InherentWeaknessDate
			--,SARFAESIFlag
			--,Case When SARFAESIDate<>''	Then SARFAESIDate Else NULL END SARFAESIDate
			--,UnusualBounceFlag
			--,Case When UnusualBounceDate<>''	Then UnusualBounceDate Else NULL END UnusualBounceDate
			--,UnclearedEffectsFlag
			--,Case When UnclearedEffectsDate<>''	Then UnclearedEffectsDate Else NULL END UnclearedEffectsDate
			--,FraudFlag
			--,Case When FraudDate<>''	Then FraudDate Else NULL END FraudDate 
			,MOCSource
			,MOCReason
			,'NP'	
			,@Timekey
			,@EffectiveToTimeKey	
			,@UserLoginID	
			,GETDATE()	
			,'U'
			,NULL
			--,TwoFlag
			--,TwoDate
			--,Case When TwoDate<>''	Then TwoDate Else NULL END TwoDate
            --,cast(TwoAmount as DECIMAL(30,2))
			--,ISNULL(case when isnull(TwoAmount,'')<>'' then CAST(ISNULL(CAST(TwoAmount AS DECIMAL(16,2)),0) AS DECIMAL(30,2))   end,NULL)  TwoAmount
			--,@LastMonthDate
			,@MocDate
			,'ACCT'
			,MOCReasonRemark                                                  ---Added by kapil on 28/11/2023
			,ISNULL(case when isnull(AdditionalProvision,'')<>'' then CAST(ISNULL(CAST(AdditionalProvision AS DECIMAL(16,2)),0) AS DECIMAL(30,2))   end,NULL)    AdditionalProvision
			,MOCType
		FROM AccountLvlMOCDetails_stg A
 
		where filname=@FilePathUpload

		Update A
		SET A.AccountEntityID=B.AccountEntityID
		From AccountLevelMOC_Mod A
		INNER JOIN AdvAcBasicDetail B ON A.AccountID =B.CustomerAcID
		and B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
		Where A.UploadID=@ExcelUploadId

		---------------------------------------------------------ChangeField Logic---------------------
		----select * from AccountLvlMOCDetails_stg
	IF OBJECT_ID('TempDB..#AccountMocUpload') Is Not Null
	Drop Table #AccountMocUpload

	Create TAble #AccountMocUpload
	(
	AccountID Varchar(30), FieldName Varchar(50),SrNo Varchar(Max))

	Insert Into #AccountMocUpload(AccountID,FieldName)
	--Select AccountID, 'POSinRs' FieldName from AccountLvlMOCDetails_stg Where isnull(POSinRs,'')<>'' --Is not NULL
	--UNION ALL
	--Select AccountID, 'InterestReceivableinRs' FieldName from AccountLvlMOCDetails_stg Where isnull(InterestReceivableinRs,'')<>'' --InterestReceivableinRs Is not NULL
	--UNION ALL
	Select AccountID, 'AdditionalProvisionAbsoluteinRs' FieldName from AccountLvlMOCDetails_stg Where isnull(AdditionalProvisionAbsoluteinRs,'')<>'' --AdditionalProvisionAbsoluteinRs Is not NULL
	UNION ALL
	--Select AccountID, 'RestructureFlagYN' FieldName from AccountLvlMOCDetails_stg Where isnull(RestructureFlagYN,'')<>'' --RestructureFlagYN Is not NULL
	--UNION ALL
	--Select AccountID, 'RestructureDate' FieldName from AccountLvlMOCDetails_stg Where isnull(RestructureDate,'')<>'' --RestructureDate Is not NULL
	----UNION ALL
	--Select AccountID, 'FITLFlagYN' FieldName from AccountLvlMOCDetails_stg Where isnull(FITLFlagYN,'')<>'' --FITLFlagYN Is not NULL
	--UNION ALL
	--Select AccountID, 'DFVAmount' FieldName from AccountLvlMOCDetails_stg Where isnull(DFVAmount,'')<>'' --DFVAmount Is not NULL
	--UNION ALL
	--Select AccountID, 'RePossesssionFlagYN' FieldName from AccountLvlMOCDetails_stg Where isnull(RePossesssionFlagYN,'')<>'' --RePossesssionFlagYN Is not NULL
	--UNION ALL
	--Select AccountID, 'RePossessionDate' FieldName from AccountLvlMOCDetails_stg Where isnull(RePossessionDate,'')<>'' --RePossessionDate Is not NULL
	--UNION ALL
	--Select AccountID, 'InherentWeaknessFlag' FieldName from AccountLvlMOCDetails_stg Where isnull(InherentWeaknessFlag,'')<>'' --InherentWeaknessFlag Is not NULL
	--UNION ALL
	--Select AccountID, 'InherentWeaknessDate' FieldName from AccountLvlMOCDetails_stg Where isnull(InherentWeaknessDate,'')<>'' --InherentWeaknessDate Is not NULL
	--UNION ALL
	--Select AccountID, 'SARFAESIFlag' FieldName from AccountLvlMOCDetails_stg Where isnull(SARFAESIFlag,'')<>'' --SARFAESIFlag Is not NULL
	--UNION ALL
	--Select AccountID, 'SARFAESIDate' FieldName from AccountLvlMOCDetails_stg Where isnull(SARFAESIDate,'')<>'' --SARFAESIDate Is not NULL
	--UNION ALL
	--Select AccountID, 'UnusualBounceFlag' FieldName from AccountLvlMOCDetails_stg Where isnull(UnusualBounceFlag,'')<>'' --UnusualBounceFlag Is not NULL
	--UNION ALL
	--Select AccountID, 'UnusualBounceDate' FieldName from AccountLvlMOCDetails_stg Where isnull(UnusualBounceDate,'')<>'' --UnusualBounceDate Is not NULL
	--UNION ALL
	--Select AccountID, 'UnclearedEffectsFlag' FieldName from AccountLvlMOCDetails_stg Where isnull(UnclearedEffectsFlag,'')<>'' --UnclearedEffectsFlag Is not NULL
	--UNION ALL
	--Select AccountID, 'UnclearedEffectsDate' FieldName from AccountLvlMOCDetails_stg Where isnull(UnclearedEffectsDate,'')<>'' --UnclearedEffectsDate Is not NULL
	--UNION ALL
	--Select AccountID, 'FraudFlag' FieldName from AccountLvlMOCDetails_stg Where isnull(FraudFlag,'')<>'' --FraudFlag Is not NULL
	--UNION ALL
	--Select AccountID, 'FraudDate' FieldName from AccountLvlMOCDetails_stg Where isnull(FraudDate,'')<>'' --FraudDate Is not NULL
	--UNION ALL
	Select AccountID, 'MOCSource' FieldName from AccountLvlMOCDetails_stg Where isnull(MOCSource,'')<>'' --MOCSource Is not NULL
	UNION ALL
	Select AccountID, 'MOCReason' FieldName from AccountLvlMOCDetails_stg Where isnull(MOCReason,'')<>'' --MOCReason Is not NULL
	--UNION ALL
	--Select AccountID, 'TwoFlag' FieldName from AccountLvlMOCDetails_stg Where isnull(TwoFlag,'')<>'' --TwoFlag Is not NULL
	--UNION ALL
	--Select AccountID, 'TwoDate' FieldName from AccountLvlMOCDetails_stg Where isnull(TwoDate,'')<>'' --TwoDate Is not NULL
	--UNION ALL
	--Select AccountID, 'TwoAmount' FieldName from AccountLvlMOCDetails_stg Where isnull(TwoAmount,'')<>'' --TwoAmount Is not NULL

	--select *
	Update B set B.SrNo=A.ScreenFieldNo
	from MetaScreenFieldDetail A
	Inner Join #AccountMocUpload B ON A.CtrlName=B.FieldName
	Where A.MenuId=24715 And A.IsVisible='Y'


	
				 IF OBJECT_ID('TEMPDB..#NEWTRANCHE')  IS NOT NULL
					DROP TABLE #NEWTRANCHE

					SELECT * INTO #NEWTRANCHE FROM(
					SELECT 
						 SS.AccountID,
						STUFF((SELECT ',' + US.SrNo 
							FROM #AccountMocUpload US
							WHERE US.AccountID = SS.AccountID
							FOR XML PATH('')), 1, 1, '') [REPORTIDSLIST]
						FROM AccountLvlMOCDetails_stg SS 
						GROUP BY SS.AccountID
						)B
						ORDER BY 1

						--Select * from #NEWTRANCHE

					--SELECT * 
					UPDATE A SET A.ChangeField=B.REPORTIDSLIST
					FROM DBO.AccountLevelMOC_Mod A
					INNER JOIN #NEWTRANCHE B ON A.AccountID=B.AccountID
					WHERE  A.EFFECTIVEFROMTIMEKEY<=@TimeKey AND A.EFFECTIVETOTIMEKEY>=@TimeKey
					And A.UploadID=@ExcelUploadId


					


		-------------------------------------------------------------------------------------

		--Declare @SummaryId int
		--Set @SummaryId=IsNull((Select Max(SummaryId) from AccountMOCDetail_MOD),0)

			
		--INSERT INTO AccountMOCSummary_Mod
		--(
		--	 UploadID
		--	,SummaryID
		--	,PoolID
		--	,PoolName
		--	,PoolType
		--	,BalanceOutstanding
		--	,NoOfAccount
		--	,IBPCExposureAmt
		--	,IBPCReckoningDate
		--	,IBPCMarkingDate
		--	,MaturityDate
		--	,TotalPosBalance
		--	,TotalInttReceivable
		--)

		--SELECT
		--	@ExcelUploadId
		--	,@SummaryId+Row_Number() over(Order by PoolID)
		--	,PoolID
		--	,PoolName
		--	,PoolType
		--	,Sum(IsNull(Cast(PrincipalOutstandinginRs as decimal(16,2)),0)+IsNull(Cast(InterestReceivableinRs as Decimal(16,2)),0))
		--	,Count(PoolID)
		--	,SUM(ISNULL(Cast(IBPCExposureinRs as Decimal(16,2)),0))
		--	,DateofIBPCreckoning
		--	,DateofIBPCmarking
		--	,MaturityDate
		--	,Sum(IsNull(Cast(PrincipalOutstandinginRs as decimal(16,2)),0))
		--	,Sum(IsNull(Cast(InterestReceivableinRs as Decimal(16,2)),0))
		--FROM AccountLvlMOCDetails_stg
		--where filename=@FilePathUpload
		--Group by PoolID,PoolName,PoolType,DateofIBPCreckoning,DateofIBPCmarking,MaturityDate

		--INSERT INTO IBPCPoolSummary_Mod
		--(
		--	UploadID
		--	,SummaryID
		--	,PoolID
		--	,PoolName
		--	,BalanceOutstanding
		--	,NoOfAccount
		--	,AuthorisationStatus	
		--	,EffectiveFromTimeKey	
		--	,EffectiveToTimeKey	
		--	,CreatedBy	
		--	,DateCreated	
		--)

		--SELECT
		--	@ExcelUploadId
		--	,@SummaryId+Row_Number() over(Order by PoolID)
		--	,PoolID
		--	,PoolName
		--	,Sum(IsNull(POS,0)+IsNull(InterestReceivable,0))
		--	,Count(PoolID)
		--	,'NP'	
		--	,@Timekey
		--	,49999	
		--	,@UserLoginID	
		--	,GETDATE()
		--FROM IBPCPoolDetail_stg
		--where filename=@FilePathUpload
		--Group by PoolID,PoolName

		PRINT @@ROWCOUNT
		
		---DELETE FROM STAGING DATA

		 DELETE FROM AccountLvlMOCDetails_stg  -- kaps for test
		 WHERE filname=@FilePathUpload

		 ----RETURN @ExcelUploadId

END
		   ----DECLARE @UniqueUploadID INT
	--SET 	@UniqueUploadID=(SELECT MAX(UniqueUploadID) FROM  ExcelUploadHistory)
	END


----------------------01042021-------------

IF (@OperationFlag=16)----AUTHORIZE

	BEGIN
		
		UPDATE 
			AccountLevelMOC_Mod 
			SET 
			AuthorisationStatus	='1A'
			,ApprovedByFirstLevel	=@UserLoginID
			,DateApprovedFirstLevel	=GETDATE()
			
			WHERE UploadId=@UniqueUploadID
			
		   UPDATE 
		   ExcelUploadHistory
		   SET AuthorisationStatus='1A'
		   ,ApprovedByFirstLevel	=@UserLoginID
		   ,DateApprovedFirstLevel=Getdate()
		   ,ApprovedBy=@UserLoginID
		   
		   where UniqueUploadID=@UniqueUploadID
		   AND UploadType='Account MOC Upload'
	END

--------------------------------------------

	IF (@OperationFlag=20)----AUTHORIZE

	BEGIN

	
				
				BEGIN
		
		UPDATE 
			AccountLevelMOC_Mod 
			SET AuthorisationStatus	='A'
			,ApprovedBy	=@UserLoginID
			,DateApproved	=GETDATE()
			WHERE UploadId=@UniqueUploadID			

				UPDATE  A
						SET A.EffectiveToTimeKey=@Timekey-1
						from MOC_ChangeDetails A
						INNER JOIN AdvAcBasicDetail B
							ON A.AccountEntityID=B.AccountEntityId
								AND A.EffectiveFromTimeKey <=@Timekey AND A.EffectiveToTimeKey >=@Timekey
								AND B.EffectiveFromTimeKey <=@Timekey AND B.EffectiveToTimeKey >=@Timekey
						INNER JOIN AccountLevelMOC_Mod C
							ON B.AccountEntityId=C.AccountEntityID
							
								AND C.EffectiveFromTimeKey <=@Timekey AND C.EffectiveToTimeKey >=@Timekey
								AND C.AuthorisationStatus='A' AND UploadId=@UniqueUploadID
						WHERE A.EffectiveToTimeKey >=@Timekey
						AND A.AuthorisationStatus = 'A'
						AND A.MOCType_Flag='ACCT'
						AND UploadId=@UniqueUploadID


Print 'op 20'


		INSERT INTO MOC_ChangeDetails    
										   (   
											        
											 AccountEntityID  
											 ,CustomerEntityId
											 ,AddlProvAbs 
											 ,FlgFraud       
											 ,FraudDate  
											  --,FlgRestructure       
											  --,RestructureDate

											 ,PrincOutStd          
											 ,unserviedint       
											       
											 ,FLGFITL         
											 ,DFVAmt         
											
											 --,ScreenFlag 
											 ,MOC_Source                  
											,MOC_Date  
											,MOC_By     
											,AuthorisationStatus   
											,EffectiveFromTimeKey  
											,EffectiveToTimeKey  
											,CreatedBy  
											,DateCreated  
											,ModifiedBy  
											,DateModified  
											,ApprovedBy  
											,DateApproved  
              
											
											,MOCType_Flag
											,TwoFlag
											,TwoDate
											,ApprovedByFirstLevel
											,DateApprovedFirstLevel
											,MOC_Reason
											,MOC_Reason_Remark ---Added by kapil on 28/11/2023
											,AddlProvPer
										   )  
										Select  
          
											 B.AccountEntityID  
											 ,B.CustomerEntityId
											 ,A.AdditionalProvisionAbsolute
											  ,A.FraudAccountFlag       
											 ,A.FraudDate 
											 --,A.RestructureFlag
			         --                         , A.RestructureDate
											  

											 ,A.POS          
											 ,A.InterestReceivable      
											  ,A.FITLFlag         
											 ,A.DFVAmount    
											        
											-- ,A.ScreenFlag         
											 ,A.MOCSource                   
											   --,Convert(Varchar(20),GETDATE(),103)
											   ,A.MOCDate
											   ,A.CreatedBy    
											   ,A.AuthorisationStatus  
											   ,A.EffectiveFromTimeKey  
											   ,A.EffectiveToTimeKey   
											   ,A.CreatedBy  
											   ,A.DateCreated  
											   ,A.ModifyBy   
											   ,A.DateModified   
											   ,A.ApprovedBy     
											   ,A.DateApproved   
         										
											
											   ,'ACCT' MOCType_Flag
										       ,A.FlgTwo
											   ,A.TwoDate
											   ,a.ApprovedByFirstLevel
											   ,a.DateApprovedFirstLevel
											   ,MOCReason
											   ,A.MOC_Reason_Remark ------------------------Added by kapil on 28/11/2023
											   ,AddlProvPer
              FROM AccountLevelMOC_MOd A
			  inner join  AdvAcBasicDetail B
			  ON          A.AccountID=B.CustomerACID
			  AND         B.EffectiveFromTimeKey <=@Timekey AND B.EffectiveToTimeKey>=@Timekey
			WHERE        A.UploadId=@UniqueUploadID AND A.EffectiveFromTimeKey <=@Timekey AND A.EffectiveToTimeKey>=@Timekey
            AND        A.AuthorisationStatus = 'A'

				UPDATE
				ExcelUploadHistory
				SET AuthorisationStatus='A',ApprovedBy=@UserLoginID,DateApproved=GETDATE()
				WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
				AND UniqueUploadID=@UniqueUploadID
				AND UploadType='Account MOC Upload'	

				Print '2op 20'

					END
			


end


	IF (@OperationFlag=17)----REJECT

	BEGIN
		
		UPDATE 
			AccountLevelMOC_Mod 
			SET 
			AuthorisationStatus	='R'
			,ApprovedByFirstLevel	=@UserLoginID
			,DateApprovedFirstLevel	=GETDATE()
			
			WHERE UploadId=@UniqueUploadID
			AND AuthorisationStatus='NP'

		
			UPDATE
				ExcelUploadHistory
				SET AuthorisationStatus='R',ApprovedBy=@UserLoginID,DateApproved=GETDATE()
				WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
				AND UniqueUploadID=@UniqueUploadID
				AND UploadType='Account MOC Upload'



	END

IF (@OperationFlag=21)----REJECT

	BEGIN
		
		UPDATE 
			AccountLevelMOC_Mod 
			SET 
			AuthorisationStatus	='R'
			,ApprovedBy	=@UserLoginID
			,DateApproved	=GETDATE()
			WHERE UploadId=@UniqueUploadID
			AND AuthorisationStatus in('NP','1A')

			

			UPDATE
				ExcelUploadHistory
				SET AuthorisationStatus='R',ApprovedBy=@UserLoginID,DateApproved=GETDATE()
				WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
				AND UniqueUploadID=@UniqueUploadID
				AND UploadType='Account MOC Upload'



	END


END

IF @OperationFlag IN (1,2,3,16,17,18,20,21) AND @AuthMode ='Y'
		BEGIN
					print 'log table'

					declare @DateCreated datetime
				SET	@DateCreated     =Getdate()

				declare @ReferenceID1 varchar(max)
				set @ReferenceID1 = (case when @OperationFlag in (16,20,21) then @UniqueUploadID else @ExcelUploadId end)


					IF @OperationFlag IN(16,17,18,20,21) 
						BEGIN 
						       Print 'Authorised'
					
			
								EXEC LogDetailsInsertUpdate_Attendence -- MAINTAIN LOG TABLE
							    @BranchCode=''   ,  ----BranchCode
								@MenuID=@MenuID,
								@ReferenceID=@UniqueUploadID ,-- ReferenceID ,
								@CreatedBy=NULL,
								@ApprovedBy=@UserLoginID, 
								@CreatedCheckedDt=@DateCreated,
								@Remark=NULL,
								@ScreenEntityAlt_Key=16  ,---ScreenEntityId -- for FXT060 screen
								@Flag=@OperationFlag,
								@AuthMode=@AuthMode
						END
					ELSE
						BEGIN
						       Print 'UNAuthorised'
						    -- Declare
						    -- set @CreatedBy  =@UserLoginID
							 
							EXEC LogDetailsInsertUpdate_Attendence -- MAINTAIN LOG TABLE
								@BranchCode=''   ,  ----BranchCode
								@MenuID=@MenuID,
								@ReferenceID=@ExcelUploadId ,-- ReferenceID ,
								@CreatedBy=@UserLoginID,
								@ApprovedBy=NULL, 						
								@CreatedCheckedDt=@DateCreated,
								@Remark=NULL,
								@ScreenEntityAlt_Key=16  ,---ScreenEntityId -- for FXT060 screen
								@Flag=@OperationFlag,
								@AuthMode=@AuthMode
						END

		END

	--COMMIT TRAN
		---SET @Result=CASE WHEN  @OperationFlag=1 THEN @UniqueUploadID ELSE 1 END
		SET @Result=CASE WHEN  @OperationFlag=1 AND @MenuId=24715 THEN @ExcelUploadId 
					ELSE 1 END

		
		 Update UploadStatus Set InsertionOfData='Y',InsertionCompletedOn=GETDATE() where FileNames=@filepath

		 ---- IF EXISTS(SELECT 1 FROM IBPCPoolDetail_stg WHERE filEname=@FilePathUpload)
		 ----BEGIN
			--	 DELETE FROM IBPCPoolDetail_stg
			----	 WHERE filEname=@FilePathUpload

			----	 PRINT 'ROWS DELETED FROM IBPCPoolDetail_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
		 ----END
		 

		RETURN @Result
		------RETURN @UniqueUploadID
	END TRY
	BEGIN CATCH 
	   --ROLLBACK TRAN
	SELECT ERROR_MESSAGE(),ERROR_LINE()
	SET @Result=-1
	 Update UploadStatus Set InsertionOfData='Y',InsertionCompletedOn=GETDATE() where FileNames=@filepath
	RETURN -1
	END CATCH

END


GO