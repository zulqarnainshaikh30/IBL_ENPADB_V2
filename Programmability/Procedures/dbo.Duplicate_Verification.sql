SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE Procedure [dbo].[Duplicate_Verification]
	@UserId varchar(20) =''
	,@TimeKey INT = 49999
	,@CheckFor varchar(30)='MobileNo'
	,@Value	varchar(30)=''
	,@NextValue varchar(300)=''
	,@ThirdValue varchar(300)=''
	,@FourthValue varchar(300)=''
	,@BranchCode VARCHAR(MAX) = 0
	,@BaseColumnValue varchar(30)=''
	,@ParentColumnValue  varchar(30)=''
	,@HyperCubeId INT=''
	,@CustomerACID INT = ''
	
As

--DECLARE 
--@UserId varchar(20) =''
--	,@TimeKey INT = 49999
--	,@CheckFor varchar(30)='ContactpersonName'
--	,@Value	varchar(30)='ada213'
--	,@NextValue varchar(300)=''
--	,@ThirdValue varchar(300)=''
--	,@FourthValue varchar(300)=''
--	,@BranchCode VARCHAR(MAX) = 'sh123'
--	,@BaseColumnValue varchar(30)='72'
--	,@ParentColumnValue  varchar(30)=''
--	,@HyperCubeId INT=''
--	,@CustomerACID INT = ''
BEGIN
 --   Select @TimeKey=Case when ISNULL(@TimeKey,0)=0 THEN TimeKey else @TimeKey end
	--from SysDayMatrix where cast(GetDate() as date)=cast([date] as date)

	--Select @Timekey=Max(Timekey) from SysProcessingCycle
	-- where Extracted='Y' and ProcessType='Full' --and PreMOC_CycleFrozenDate IS NULL

	print @TimeKey
	IF(@CheckFor = 'MobileNo')
	BEGIN
		if EXISTS(SELECT  1 FROM DimUserInfo WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										--AND MobileNo LIKE'%'+@Value+'%' AND UserLoginID<>isnull(@UserId,'')
										--AND MobileNo = @Value AND UserLoginID<>isnull(@UserId,'')
										and ISNULL(MobileNo,'')<>''
										AND SUBSTRING(MobileNo,1,10)=@Value
										AND ISNULL( AuthorisationStatus,'A' ) ='A'
					UNION
					SELECT  1 FROM DimUserInfo_Mod WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										--AND MobileNo LIKE'%'+@Value+'%' AND UserLoginID<>isnull(@UserId,'')
										--AND MobileNo = @Value AND UserLoginID<>isnull(@UserId,'')
										and ISNULL(MobileNo,'')<>''
										AND SUBSTRING(MobileNo,1,10)=@Value
										AND AuthorisationStatus in('NP','MP','DP','RM')

				 )
		BEGIN
			SELECT '1' CODE, 'Data Exist' Status
		END
		ELSE
		BEGIN
			SELECT '0' CODE, 'Data Not Exist' Status
		END
	END

	ELSE IF(@CheckFor = 'ExtensionNo') --alter table dimuserinfo alter column Extension varchar(30)
	BEGIN
		if EXISTS(SELECT  1 FROM DimUserInfo WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										--AND MobileNo LIKE'%'+@Value+'%' AND UserLoginID<>isnull(@UserId,'')
										--AND (SUBSTRING(ISNULL(MobileNo,''),12,LEN(ISNULL(MobileNo,''))) LIKE CASE WHEN @Value <> '' Then '%' + @Value +'%' ELSE SUBSTRING(ISNULL(MobileNo,''),12,LEN(ISNULL(MobileNo,''))) END ) AND UserLoginID<>isnull(@UserId,'')
									--	and SUBSTRING(ISNULL(Extension,''),12,LEN(ISNULL(Extension,'')))=@Value
										--AND MobileNo = @Value AND UserLoginID<>isnull(@UserId,'')
										AND ISNULL( AuthorisationStatus,'A' ) ='A'
							UNION 
										SELECT  1 FROM DimUserInfo_Mod WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										--AND MobileNo LIKE'%'+@Value+'%' AND UserLoginID<>isnull(@UserId,'')
										--AND (SUBSTRING(ISNULL(MobileNo,''),12,LEN(ISNULL(MobileNo,''))) LIKE CASE WHEN @Value <> '' Then '%' + @Value +'%' ELSE SUBSTRING(ISNULL(MobileNo,''),12,LEN(ISNULL(MobileNo,''))) END ) AND UserLoginID<>isnull(@UserId,'')
										--and SUBSTRING(ISNULL(Extension,''),12,LEN(ISNULL(Extension,'')))=@Value
										--AND MobileNo = @Value AND UserLoginID<>isnull(@UserId,'')
										AND AuthorisationStatus in('NP','MP','DP','RM') 
				 )
		BEGIN
			SELECT '1' CODE, 'Data Exist' Status
		END
		ELSE
		BEGIN
			SELECT '0' CODE, 'Data Not Exist' Status
		END
	END

	ELSE IF(@CheckFor = 'UserId')
	BEGIN
		if EXISTS(SELECT  1 FROM DimUserInfo WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										AND UserLoginID = @Value --AND UserLoginID<>isnull(@UserId,'')
										AND ISNULL( AuthorisationStatus,'A' ) ='A'
					UNION
					SELECT  1 FROM DimUserInfo_Mod WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										AND UserLoginID = @Value --AND UserLoginID<>isnull(@UserId,'')
										AND AuthorisationStatus in('NP','MP','DP','RM') 
				 )
		BEGIN
			SELECT '1' CODE, 'Data Exist' Status
		END
		ELSE
		BEGIN
			SELECT '0' CODE, 'Data Not Exist' Status
		END
	END 
	ELSE IF(@CheckFor = 'EmailId')
	BEGIN
		IF OBJECT_ID('Tempdb..#Email') IS NOT NULL
									DROP TABLE #Email
								SELECT Email_ID 
								INTO #Email
								FROM 
								(
								SELECT Split.a.value('.', 'VARCHAR(8000)') AS Email_ID 
								FROM  (SELECT 
									CAST ('<M>' + REPLACE(Email_ID, ',', '</M><M>') + '</M>' AS XML) AS Email
									from DimUserInfo		
									WHERE EffectiveFromTimeKey  <= @Timekey 
									AND EffectiveToTimeKey		>= @Timekey
									AND ISNULL(Email_ID,'')<>''
									AND UserLoginID <> @UserId		
									) 
								AS A
								CROSS APPLY Email.nodes ('/M') AS Split(a)
								)B WHERE ISNULL(Email_ID,'')<>''

		IF EXISTS	(SELECT * FROM #Email WHERE Email_ID = @Value)
		BEGIN
			SELECT '1' CODE, 'Data Exist' Status
		END
		ELSE
		BEGIN
			SELECT '0' CODE, 'Data Not Exist' Status
		END
	END
	--ELSE IF(@CheckFor = 'GLCode')
	--BEGIN
	--PRINT 'IN GL CODE'
	--	IF EXISTS( SELECT  1 FROM DimGL WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND
	--								GLCode=@Value AND   GLAlt_Key<>isnull(@BaseColumnValue,'') )
	--								AND ISNULL( AuthorisationStatus,'A' ) ='A'
	--				 UNION
	--				 SELECT  1 FROM DimGL_Mod WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND
	--								GLCode=@Value AND  GLAlt_Key<>isnull(@BaseColumnValue,'') )
	--								AND AuthorisationStatus in('NP','MP','DP','RM')
	--			)
	--	BEGIN
	--		SELECT '1' CODE, 'Data Exist' Status
	--	END
	--	ELSE
	--	BEGIN
	--		SELECT '0' CODE, 'Data Not Exist' Status
	--	END
	--END

		ELSE IF(@CheckFor = 'ChildBSCode')
	BEGIN
	PRINT 'ChildBSCode'
		IF EXISTS( SELECT  1 FROM BS.DimBSCodeStructure WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND
									BS_Code=@Value  AND ISNULL( AuthorisationStatus,'A' ) ='A')
					 UNION
					 SELECT  1 FROM BS.DimBSCodeStructure_Mod WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND
									BS_Code=@Value  AND AuthorisationStatus in('NP','MP','DP','RM'))
				)
		BEGIN
			SELECT '1' CODE, 'Data Exist' Status
		END
		ELSE
		BEGIN
			SELECT '0' CODE, 'Data Not Exist' Status
		END
	END



	ELSE IF(@CheckFor = 'CAFirmName')
	BEGIN
		if EXISTS(SELECT  1 FROM Bs.DimAuditors WHERE 
									 (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND CAFirmName=@Value 
									 AND  CAFirmAlt_Key <> isnull(@BaseColumnValue,'') AND ISNULL( AuthorisationStatus,'A' ) ='A'
									 )
					UNION 
					SELECT  1 FROM Bs.DimAuditors_Mod WHERE 
									 (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND
		 CAFirmName=@Value AND CAFirmAlt_Key <> isnull(@BaseColumnValue,''))
				AND AuthorisationStatus in('NP','MP','DP','RM'))
		BEGIN
			SELECT '1' CODE, 'Data Exist' Status
		END
		ELSE
		BEGIN
			SELECT '0' CODE, 'Data Not Exist' Status
		END
	END




	--ELSE IF(@CheckFor = 'GLName')
	--BEGIN
	--PRINT 'IN GL Name'
	----IF EXISTS( SELECT  1 FROM DimGL WHERE (--EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND
	----								GLName=@Value AND   GLAlt_Key<>isnull(@BaseColumnValue,'') )
	----				 UNION
	----				 SELECT  1 FROM DimGL_Mod WHERE (--EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND
	----								GLName=@Value AND   GLAlt_Key<>isnull(@BaseColumnValue,'') )
	----			)

	----				BEGIN
	----		SELECT '1' CODE, 'Data Exist' Status
	----	END
	----	ELSE
	----	BEGIN
	----		SELECT '0' CODE, 'Data Not Exist' Status
	----	END


	--	IF EXISTS( SELECT  1 FROM DimGL WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND
	--	 GLName=@Value AND GLAlt_Key<>isnull(@BaseColumnValue,'') AND ISNULL( AuthorisationStatus,'A' ) ='A')
	--	 UNION 
	--				SELECT  1 FROM DimGL_Mod WHERE 
	--								 (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND
	--	 GLName=@Value AND GLAlt_Key<>isnull(@BaseColumnValue,'')) AND AuthorisationStatus in('NP','MP','DP','RM'))
				
	--	BEGIN
	--		SELECT '1' CODE, 'Data Exist' Status
	--	END
	--	ELSE
	--	BEGIN
	--		SELECT '0' CODE, 'Data Not Exist' Status
	--	END
	--END
	ELSE IF(@CheckFor = 'OffeceAcCd')
	BEGIN
	PRINT 'IN OffeceAcCd'
	

		 IF EXISTS( SELECT  1 FROM BS.DimOfficeAccount WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND
		 OffeceAcCd=@Value AND OfficeAccountAlt_key<>isnull(@BaseColumnValue,'') AND ISNULL( AuthorisationStatus,'A' ) ='A')
		 UNION 
					SELECT  1 FROM BS.DimOfficeAccount_Mod WHERE 
									 (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND
		 OffeceAcCd=@Value AND OfficeAccountAlt_key<>isnull(@BaseColumnValue,'')) AND AuthorisationStatus in('NP','MP','DP','RM'))



		BEGIN
			SELECT '1' CODE, 'Data Exist' Status
		END
		ELSE
		BEGIN
			SELECT '0' CODE, 'Data Not Exist' Status
		END
	END
	ELSE IF(@CheckFor = 'OfficeAccountDescription')
	BEGIN
	PRINT 'IN OfficeAccountDescription'
	

		  IF EXISTS( SELECT  1 FROM BS.DimOfficeAccount WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND
		 OfficeAccountDescription=@Value AND OfficeAccountAlt_key<>isnull(@BaseColumnValue,'') AND ISNULL( AuthorisationStatus,'A' ) ='A')
		 UNION 
					SELECT  1 FROM BS.DimOfficeAccount_Mod WHERE 
									 (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND
		 OfficeAccountDescription=@Value AND OfficeAccountAlt_key<>isnull(@BaseColumnValue,'')) AND AuthorisationStatus in('NP','MP','DP','RM'))


		BEGIN
			SELECT '1' CODE, 'Data Exist' Status
		END
		ELSE
		BEGIN
			SELECT '0' CODE, 'Data Not Exist' Status
		END
	END
	ELSE IF(@CheckFor = 'AccountNoBorrLiabilitiesStmt')
	BEGIN
			--select * from BorrLiabilitiesStmt
		IF EXISTS(SELECT  1 FROM BorrLiabilitiesStmt WHERE 	(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										AND AccountNo LIKE''+@Value+'' AND EntityID<>isnull(@BaseColumnValue,'')
										AND ISNULL( AuthorisationStatus,'A' ) ='A'
					UNION
					SELECT  1 FROM BorrLiabilitiesStmt_Mod WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										AND AccountNo LIKE''+@Value+'' AND EntityID<>isnull(@BaseColumnValue,'')
										AND AuthorisationStatus in('NP','MP','DP','RM')
				 )
		BEGIN
			SELECT '1' CODE, 'Data Exist' Status
		END
		ELSE
		BEGIN
			SELECT '0' CODE, 'Data Not Exist' Status
		END
	END
	ELSE IF(@CheckFor = 'MobileNoFinLiteracyCenter')
	BEGIN
		IF EXISTS(SELECT  1 FROM FinLiteracyCenter WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										AND MobileNo LIKE'%'+@Value+'%' AND FinLitEntityId<>isnull(@BaseColumnValue,'')
										AND ISNULL( AuthorisationStatus,'A' ) ='A'
					UNION
					SELECT  1 FROM FinLiteracyCenter_Mod WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										AND MobileNo LIKE'%'+@Value+'%' AND FinLitEntityId<>isnull(@BaseColumnValue,'')
										AND AuthorisationStatus in('NP','MP','DP','RM')
				 )
		BEGIN
			SELECT '1' CODE, 'Data Exist' Status
		END
		ELSE
		BEGIN
			SELECT '0' CODE, 'Data Not Exist' Status
		END
	END
	ELSE IF(@CheckFor = 'EmailFinLiteracyCenter')
		BEGIN
		IF EXISTS(SELECT  1 FROM FinLiteracyCenter WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										AND Email LIKE''+@Value+'' AND FinLitEntityId<>isnull(@BaseColumnValue,'')
										AND ISNULL( AuthorisationStatus,'A' ) ='A'
					UNION
					SELECT  1 FROM FinLiteracyCenter_Mod WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										AND Email LIKE''+@Value+'' AND FinLitEntityId<>isnull(@BaseColumnValue,'')
										AND AuthorisationStatus in('NP','MP','DP','RM')
				 )
		BEGIN
			SELECT '1' CODE, 'Data Exist' Status
		END
		ELSE
		BEGIN
			SELECT '0' CODE, 'Data Not Exist' Status
		END
	END
	ELSE IF(@CheckFor = 'FLC_CodeFinLiteracyCenter')
		BEGIN
		IF EXISTS(SELECT  1 FROM FinLiteracyCenter WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										AND FLC_Code LIKE''+@Value+'' AND FinLitEntityId<>isnull(@BaseColumnValue,'')
										AND ISNULL( AuthorisationStatus,'A' ) ='A'
					UNION
					SELECT  1 FROM FinLiteracyCenter_Mod WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										AND FLC_Code LIKE''+@Value+'' AND FinLitEntityId<>isnull(@BaseColumnValue,'')
										AND AuthorisationStatus in('NP','MP','DP','RM')
				 )
		BEGIN
			SELECT '1' CODE, 'Data Exist' Status
		END
		ELSE
		BEGIN
			SELECT '0' CODE, 'Data Not Exist' Status
		END
	END

		ELSE IF(@CheckFor = 'NABARD_Code')
		BEGIN
		IF EXISTS(SELECT  1 FROM FarmersClubDtls WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										AND NABARD_Code LIKE''+@Value+'' AND ClubEntityId<>isnull(@BaseColumnValue,'')
										AND ISNULL( AuthorisationStatus,'A' ) ='A'
					UNION
					SELECT  1 FROM FarmersClubDtls_Mod WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										AND NABARD_Code LIKE''+@Value+'' AND ClubEntityId<>isnull(@BaseColumnValue,'')
										AND AuthorisationStatus in('NP','MP','DP','RM')
				 )
		BEGIN
			SELECT '1' CODE, 'Data Exist' Status
		END
		ELSE
		BEGIN
			SELECT '0' CODE, 'Data Not Exist' Status
		END
	END

	ELSE IF(@CheckFor = 'Designation_Profile')
		BEGIN
		IF EXISTS(SELECT  1 FROM [dbo].[TopManagementProfile] WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										AND DesignationAlt_Key =1 AND MgmtProfileEntityId<>isnull(@BaseColumnValue,'')
										AND ISNULL( AuthorisationStatus,'A' ) ='A'
					UNION
					SELECT  1 FROM [dbo].[TopManagementProfile_Mod] WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										AND DesignationAlt_Key =1  AND MgmtProfileEntityId<>isnull(@BaseColumnValue,'')
										AND AuthorisationStatus in('NP','MP','DP','RM')
				 )
		BEGIN
			SELECT '1' CODE, 'Data Exist' Status
		END
		ELSE
		BEGIN
			SELECT '0' CODE, 'Data Not Exist' Status
		END
	END

	ELSE IF(@CheckFor = 'Email_Profile')
		BEGIN
		IF EXISTS(SELECT  1 FROM [dbo].[TopManagementProfile] WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										AND Email LIKE''+@Value+'' AND MgmtProfileEntityId<>isnull(@BaseColumnValue,'')
										AND ISNULL( AuthorisationStatus,'A' ) ='A'
					UNION
					SELECT  1 FROM [dbo].[TopManagementProfile_Mod] WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										AND Email LIKE''+@Value+'' AND MgmtProfileEntityId<>isnull(@BaseColumnValue,'')
										AND AuthorisationStatus in('NP','MP','DP','RM')
				 )
		BEGIN
			SELECT '1' CODE, 'Data Exist' Status
		END
		ELSE
		BEGIN
			SELECT '0' CODE, 'Data Not Exist' Status
		END
	END

	
	ELSE IF(@CheckFor = 'EmailId_Board')
		BEGIN
		IF EXISTS(SELECT  1 FROM [dbo].[BoardMemberstProfile] WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										AND Email LIKE''+@Value+'' AND MemProfileEntityId<>isnull(@BaseColumnValue,'')
										AND ISNULL( AuthorisationStatus,'A' ) ='A'
					UNION
					SELECT  1 FROM [dbo].[BoardMemberstProfile_Mod] WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										AND Email LIKE''+@Value+'' AND MemProfileEntityId<>isnull(@BaseColumnValue,'')
										AND AuthorisationStatus in('NP','MP','DP','RM')
				 )
		BEGIN
			SELECT '1' CODE, 'Data Exist' Status
		END
		ELSE
		BEGIN
			SELECT '0' CODE, 'Data Not Exist' Status
		END
	END










	ELSE IF(@CheckFor = 'MobileNo_Board')
		BEGIN
		IF EXISTS(SELECT  1 FROM [dbo].[BoardMemberstProfile] WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										AND MobileNo LIKE'%'+@Value+'%' AND MemProfileEntityId<>isnull(@BaseColumnValue,'')
										AND ISNULL( AuthorisationStatus,'A' ) ='A'
					UNION
					SELECT  1 FROM [dbo].[BoardMemberstProfile_Mod] WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										AND MobileNo LIKE'%'+@Value+'%' AND MemProfileEntityId<>isnull(@BaseColumnValue,'')
										AND AuthorisationStatus in('NP','MP','DP','RM')
				 )
		BEGIN
			SELECT '1' CODE, 'Data Exist' Status
		END
		ELSE
		BEGIN
			SELECT '0' CODE, 'Data Not Exist' Status
		END
	END




	ELSE IF(@CheckFor = 'Date')
		BEGIN
		IF EXISTS(SELECT  1 FROM [dbo].[CrimeDetails] WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										 --AND CrimeEntityId<>isnull(@BaseColumnValue,'')
										 AND CONVERT(VARCHAR(10),OccurrenceDateTime,103) = @Value
										AND BranchCode = @BranchCode
									    
										AND ISNULL( AuthorisationStatus,'A' ) ='A'
					UNION
					SELECT  1 FROM [dbo].[CrimeDetails_Mod] WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										--AND CrimeEntityId<>isnull(@BaseColumnValue,'')
										AND CONVERT(VARCHAR(10),OccurrenceDateTime,103) = @Value
										AND BranchCode = @BranchCode
										AND AuthorisationStatus in('NP','MP','DP','RM')

				 )
		BEGIN
			SELECT '1' CODE, 'Data Exist' Status
		END
		ELSE
		BEGIN
			SELECT '0' CODE, 'Data Not Exist' Status
		END
	END





	
	ELSE IF(@CheckFor = 'IssuerID')
		BEGIN
		IF EXISTS(SELECT  1 FROM [dbo].[InvestmentIssuerDetail] WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										 AND IssuerEntityID<>ISNULL(@BaseColumnValue,'')
										 AND IssuerID = @Value
										-- AND BranchCode = @BranchCode
									    
										AND ISNULL( AuthorisationStatus,'A' ) ='A'
					UNION
					SELECT  1 FROM [dbo].[InvestmentIssuerDetail_Mod] WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										AND IssuerEntityID<>isnull(@BaseColumnValue,'')
										AND IssuerID = @Value
										--AND BranchCode = @BranchCode
										AND AuthorisationStatus in('NP','MP','DP','RM')

				 )
		BEGIN
			SELECT '1' CODE, 'Data Exist' Status
		END
		ELSE
		BEGIN
			SELECT '0' CODE, 'Data Not Exist' Status
		END
	END

	
		ELSE IF(@CheckFor = 'FMS_Nuumber')
		BEGIN
		IF EXISTS(SELECT  1 FROM [dbo].[FraudDetail] WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										 AND FraudEntityId<>isnull(@BaseColumnValue,'')
										 --AND FMS_Nuumber = @Value
										-- AND BranchCode = @BranchCode
									    
										AND ISNULL( AuthorisationStatus,'A' ) ='A'
					UNION
					SELECT  1 FROM [dbo].[FraudDetail_Mod] WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										AND FraudEntityId<>isnull(@BaseColumnValue,'')
										--AND FMS_Nuumber = @Value
										--AND BranchCode = @BranchCode
										AND AuthorisationStatus in('NP','MP','DP','RM')

				 )

		
		BEGIN
			SELECT '1' CODE, 'Data Exist' Status
		END
		ELSE
		BEGIN
			SELECT '0' CODE, 'Data Not Exist' Status
		END
END

ELSE IF(@CheckFor = 'LCBGNo')
	BEGIN
		IF EXISTS(SELECT  1 FROM [dbo].[AdvFacNFDetail] WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										 --AND FraudEntityId<>isnull(@BaseColumnValue,'')
										 AND LCBGNo = @Value
										-- AND BranchCode = @BranchCode
									    
										AND ISNULL( AuthorisationStatus,'A' ) ='A'
					UNION
					SELECT  1 FROM [dbo].[AdvFacNFDetail_Mod] WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										--AND FraudEntityId<>isnull(@BaseColumnValue,'')
										AND LCBGNo = @Value
										--AND BranchCode = @BranchCode
										AND AuthorisationStatus in('NP','MP','DP','RM')

				 )

		
		BEGIN
			SELECT '1' CODE, 'Data Exist' Status
		END
		ELSE
		BEGIN
			SELECT '0' CODE, 'Data Not Exist' Status
		END
END


		ELSE IF(@CheckFor = 'IssuerName')
		BEGIN
		IF EXISTS(SELECT  1 FROM [dbo].[InvestmentIssuerDetail] WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										 AND IssuerEntityID<>isnull(@BaseColumnValue,'')
										 AND IssuerName = @Value
										 AND BranchCode = @BranchCode
									    
										AND ISNULL( AuthorisationStatus,'A' ) ='A'
					UNION
					SELECT  1 FROM [dbo].[InvestmentIssuerDetail_Mod] WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										AND IssuerEntityID<>isnull(@BaseColumnValue,'')
										AND IssuerName = @Value
										AND BranchCode = @BranchCode
										AND AuthorisationStatus in('NP','MP','DP','RM')

				 )

		
		BEGIN
			SELECT '1' CODE, 'Data Exist' Status
		END
		ELSE
		BEGIN
			SELECT '0' CODE, 'Data Not Exist' Status
		END
END
		
		ELSE IF(@CheckFor = 'ReportId')
		BEGIN
		IF EXISTS(SELECT  1 FROM xbrl.DimXBRL_Properties WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
									
										 AND ReportId = @Value
									    
										--AND ISNULL( AuthorisationStatus,'A' ) ='A'
					UNION
					SELECT  1 FROM xbrl.DimXBRL_Properties_mod WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
									AND AuthorisationStatus in('NP','MP','DP','RM')
										AND ReportId = @Value

				 )

		
		BEGIN
			SELECT '1' CODE, 'Data Exist' Status
		END
		ELSE
		BEGIN
			SELECT '0' CODE, 'Data Not Exist' Status
		END

	END
	
	ELSE IF(@CheckFor = 'MobileNo_Profile')
		BEGIN
		IF EXISTS(SELECT  1 FROM [dbo].[TopManagementProfile] WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										AND MobileNo LIKE'%'+@Value+'%' AND MgmtProfileEntityId<>isnull(@BaseColumnValue,'')
										AND ISNULL( AuthorisationStatus,'A' ) ='A'
					UNION
					SELECT  1 FROM [dbo].[TopManagementProfile_Mod] WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										AND MobileNo LIKE'%'+@Value+'%' AND MgmtProfileEntityId<>isnull(@BaseColumnValue,'')

				 )
		BEGIN
			SELECT '1' CODE, 'Data Exist' Status
		END
		ELSE
		BEGIN
			SELECT '0' CODE, 'Data Not Exist' Status
		END
	END

	
	ELSE IF(@CheckFor = 'SuitRefNo')
		BEGIN
		IF EXISTS(SELECT  1 FROM [dbo].[AdvCustStressedAssetDetail] WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										AND SuitRefNo LIKE'%'+@Value+'%' AND LitigationEntityId<>isnull(@BaseColumnValue,'')
										AND ISNULL( AuthorisationStatus,'A' ) ='A'
					UNION
					SELECT  1 FROM [dbo].[AdvCustStressedAssetDetail_Mod] WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										AND SuitRefNo LIKE'%'+@Value+'%' AND LitigationEntityId<>isnull(@BaseColumnValue,'')

				 )
		BEGIN
			SELECT '1' CODE, 'Data Exist' Status
		END
		ELSE
		BEGIN
			SELECT '0' CODE, 'Data Not Exist' Status
		END
	END



		ELSE IF(@CheckFor = 'MobileNo_Application')
		BEGIN
		IF EXISTS(SELECT  1 FROM [dbo].[Inward] WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										AND MobileNo LIKE'%'+@Value+'%' AND InwardNo<>isnull(@BaseColumnValue,'')
										AND ISNULL( AuthorisationStatus,'A' ) ='A'
					UNION
					SELECT  1 FROM [dbo].[Inward_Mod] WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										AND MobileNo LIKE'%'+@Value+'%' AND InwardNo<>isnull(@BaseColumnValue,'')

				 )
		BEGIN
			SELECT '1' CODE, 'Data Exist' Status
		END
		ELSE
		BEGIN
			SELECT '0' CODE, 'Data Not Exist' Status
		END
	END







	ELSE IF(@CheckFor = 'CustomerId')
	BEGIN
	PRINT 'Customer ID'
		IF EXISTS( SELECT  1 FROM SHG_DirectMembersDetail WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND
									CustomerId=@Value 
									AND   SHGEntityId<>isnull(@BaseColumnValue,'') )
									AND ISNULL( AuthorisationStatus,'A' ) ='A'
					 UNION
					 SELECT  1 FROM SHG_DirectMembersDetail_Mod WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND
									CustomerId=@Value 
									AND  SHGEntityId<>isnull(@BaseColumnValue,'') )
									AND AuthorisationStatus in('NP','MP','DP','RM')
				)
		BEGIN
			SELECT '1' CODE, 'Data Exist' Status
		END
		ELSE
		BEGIN
			SELECT '0' CODE, 'Data Not Exist' Status
		END
	END

ELSE IF(@CheckFor = 'BGCustomerId')
	BEGIN
		IF EXISTS(SELECT  1 FROM [dbo].[AdvNFAcBasicDetail] WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										 --AND FraudEntityId<>isnull(@BaseColumnValue,'')
										 AND CustomerId = @Value
										-- AND BranchCode = @BranchCode
									    
										AND ISNULL( AuthorisationStatus,'A' ) ='A'
					UNION
					SELECT  1 FROM [dbo].[AdvNFAcBasicDetail_mod] WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										--AND FraudEntityId<>isnull(@BaseColumnValue,'')
										AND CustomerId = @Value
										--AND BranchCode = @BranchCode
										AND AuthorisationStatus in('NP','MP','DP','RM')

				 )

		
		BEGIN
			SELECT '1' CODE, 'Data Exist' Status
		END
		ELSE
		BEGIN
			SELECT '0' CODE, 'Data Not Exist' Status
		END
END

	ELSE IF(@CheckFor = 'SheetName')
		BEGIN
		IF EXISTS(SELECT  1 FROM [dbo].[ExcelUtility_DataMapping] WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										  AND ReportEntityId=@BaseColumnValue
										 AND SheetName=@Value
									
									    
										AND ISNULL( AuthorisationStatus,'A' ) ='A'
					UNION
					SELECT  1 FROM [dbo].[ExcelUtility_DataMapping_Mod] WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										 AND ReportEntityId=@BaseColumnValue
										AND SheetName=@Value
										AND AuthorisationStatus in('NP','MP','DP','RM')

				 )
		BEGIN
			SELECT '1' CODE, 'Data Exist' Status
		END
		ELSE
		BEGIN
			SELECT '0' CODE, 'Data Not Exist' Status
		END
	END

	ELSE IF(@CheckFor = 'BusinessSegEnumartion')
		BEGIN
		IF EXISTS(SELECT  1 FROM [dbo].[DimTargetMaster] WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										 -- AND TargetAlt_Key=@BaseColumnValue
										 AND BusinessSegEnumartion=@Value
									
									    
										AND ISNULL( AuthorisationStatus,'A' ) ='A'
					UNION
					SELECT  1 FROM [dbo].[DimTargetMaster_Mod] WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										--   AND TargetAlt_Key=@BaseColumnValue
										AND BusinessSegEnumartion=@Value
										AND AuthorisationStatus in('NP','MP','DP','RM')

				 )
		BEGIN
			SELECT '1' CODE, 'Data Exist' Status
		END
		ELSE
		BEGIN
			SELECT '0' CODE, 'Data Not Exist' Status
		END
	END







	ELSE IF(@CheckFor = 'BGOriginalLimitRefNo')
		BEGIN
		DECLARE @AccountId INT
		SELECT @AccountId = MAX(CustomerACID) FROM 
		(
		SELECT  MAX(CustomerACID) CustomerACID FROM [dbo].[AdvNFAcBasicDetail] WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										  AND BranchCode = @BranchCode
										 AND OriginalLimitRefNo=@Value
										  --AND AccountEntityId=@BaseColumnValue
										 --and CustomerACID = @CustomerACID
										AND ISNULL( AuthorisationStatus,'A' ) ='A'
		UNION 
		SELECT  MAX(CustomerACID) CustomerACID FROM [dbo].[AdvNFAcBasicDetail_mod] WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										AND BranchCode = @BranchCode
										AND OriginalLimitRefNo=@Value
										--AND AccountEntityId=@BaseColumnValue
										 --and CustomerACID = @CustomerACID
										AND AuthorisationStatus in('NP','MP','DP','RM')

		) A
		
		IF EXISTS(SELECT  1 FROM [dbo].[AdvNFAcBasicDetail] WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										  AND BranchCode = @BranchCode
										 AND OriginalLimitRefNo=@Value
										  --AND AccountEntityId=@BaseColumnValue
										 --and CustomerACID = @CustomerACID
										 --AND @CustomerACID = @AccountId
										AND ISNULL( AuthorisationStatus,'A' ) ='A'
					UNION
					SELECT  1 FROM [dbo].[AdvNFAcBasicDetail_mod] WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										AND BranchCode = @BranchCode
										AND OriginalLimitRefNo=@Value
										
										--AND AccountEntityId=@BaseColumnValue
										 --and CustomerACID = @CustomerACID
										AND AuthorisationStatus in('NP','MP','DP','RM')

				 )
		BEGIN
			
			SELECT	CASE WHEN @CustomerACID = @AccountId THEN '0' ELSE  '1' END CODE,
					CASE WHEN @CustomerACID = @AccountId THEN 'Data Not Exist' ELSE 'Data Exist' END Status
		END
		ELSE
		BEGIN
			SELECT '0' CODE, 'Data Not Exist' Status
		END
	END

	--commented by Mohsin	
	ELSE IF(@CheckFor = 'BranchCode')
		BEGIN
		IF EXISTS(SELECT  1 FROM [dbo].[DimBranch] WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										  AND BranchCode=@Value
										 --AND BusinessSegEnumartion=@Value
									
									    
										AND ISNULL( AuthorisationStatus,'A' ) ='A'
					UNION
					SELECT  1 FROM [dbo].[DimBranch_Mod] WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 	
										AND BranchCode=@Value									
										--   AND TargetAlt_Key=@BaseColumnValue
										--AND BusinessSegEnumartion=@Value
										AND AuthorisationStatus in('NP','MP','DP','RM')

				 )
		BEGIN
			SELECT '1' CODE, 'Data Exist' Status
		END
		ELSE
		BEGIN
			SELECT '0' CODE, 'Data Not Exist' Status
		END
	END
	ELSE IF(@CheckFor = 'BranchName')
		BEGIN
		IF EXISTS(SELECT  1 FROM [dbo].[DimBranch] WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										  AND BranchName=@Value
										 --AND BusinessSegEnumartion=@Value
									
									    
										AND ISNULL( AuthorisationStatus,'A' ) ='A'
					UNION
					SELECT  1 FROM [dbo].[DimBranch_Mod] WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 	
										AND BranchName=@Value									
										--   AND TargetAlt_Key=@BaseColumnValue
										--AND BusinessSegEnumartion=@Value
										AND AuthorisationStatus in('NP','MP','DP','RM')

				 )
		BEGIN
			SELECT '1' CODE, 'Data Exist' Status
		END
		ELSE
		BEGIN
			SELECT '0' CODE, 'Data Not Exist' Status
		END
	END
	ELSE IF(@CheckFor = 'GLCode')
		BEGIN
		IF EXISTS(SELECT  1 FROM [dbo].[DimGL] WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										  --AND TerritoryAlt_Key = @NextValue
										 AND GLAlt_Key=@Value
									
									    
										AND ISNULL( AuthorisationStatus,'A' ) ='A'
					UNION
					SELECT  1 FROM [dbo].[DimGL_Mod] WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
									  --AND TerritoryAlt_Key = @NextValue
										 AND GLAlt_Key=@Value
									
										AND AuthorisationStatus in('NP','MP','DP','RM')

				 )
		BEGIN
			SELECT '1' CODE, 'Data Exist' Status
		END
		ELSE
		BEGIN
			SELECT '0' CODE, 'Data Not Exist' Status
		END
	END
	ELSE IF(@CheckFor = 'GLName')
		BEGIN
		IF EXISTS(SELECT  1 FROM [dbo].[DimGL] WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										  --AND TerritoryAlt_Key = @NextValue
										 AND GLName=@Value
									
									    
										AND ISNULL( AuthorisationStatus,'A' ) ='A'
					UNION
					SELECT  1 FROM [dbo].[DimGL_Mod] WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
									  --AND TerritoryAlt_Key = @NextValue
										 AND GLName=@Value
									
										AND AuthorisationStatus in('NP','MP','DP','RM')

				 )
		BEGIN
			SELECT '1' CODE, 'Data Exist' Status
		END
		ELSE
		BEGIN
			SELECT '0' CODE, 'Data Not Exist' Status
		END
	END
	ELSE IF(@CheckFor = 'BACID')
		BEGIN
		IF EXISTS(SELECT  1 FROM [dbo].[DimOfficeAccountBACID] WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										  AND TerritoryAlt_Key = @NextValue
										  AND CurrencyAlt_Key = @ThirdValue
										  AND BACID=@Value
									
									    
										AND ISNULL( AuthorisationStatus,'A' ) ='A'
					UNION
					SELECT  1 FROM [dbo].[DimOfficeAccountBACID_mod] WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										 AND TerritoryAlt_Key = @NextValue
										 AND CurrencyAlt_Key = @ThirdValue
										 AND BACID=@Value
									
										AND AuthorisationStatus in('NP','MP','DP','RM')

				 )
		BEGIN
			SELECT '1' CODE, 'Data Exist' Status
		END
		ELSE
		BEGIN
			SELECT '0' CODE, 'Data Not Exist' Status
		END
	END
	ELSE IF(@CheckFor = 'DepartmentCode')
		BEGIN
		IF EXISTS(SELECT  1 FROM [dbo].[DimDepartment] WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										  AND DepartmentCode=@Value
										AND ISNULL( AuthorisationStatus,'A' ) ='A'
					UNION
					SELECT  1 FROM [dbo].[DimDepartment_Mod] WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 	
										AND DepartmentCode=@Value									
										AND AuthorisationStatus in('NP','MP','DP','RM')

				 )
		BEGIN
			SELECT '1' CODE, 'Data Exist' Status
		END
		ELSE
		BEGIN
			SELECT '0' CODE, 'Data Not Exist' Status
		END
	END
	ELSE IF(@CheckFor = 'DepartmentShortName')
		BEGIN
		IF EXISTS(SELECT  1 FROM [dbo].[DimDepartment] WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										  AND DepartmentShortName=@Value
										AND ISNULL( AuthorisationStatus,'A' ) ='A'
					UNION
					SELECT  1 FROM [dbo].[DimDepartment_Mod] WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 	
										AND DepartmentShortName=@Value									
										AND AuthorisationStatus in('NP','MP','DP','RM')

				 )
		BEGIN
			SELECT '1' CODE, 'Data Exist' Status
		END
		ELSE
		BEGIN
			SELECT '0' CODE, 'Data Not Exist' Status
		END
	END
	ELSE IF(@CheckFor = 'BACIDDept')
		BEGIN
		IF EXISTS(SELECT  1 FROM [dbo].[DimDepartmentBACID] WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										  AND TerritoryAlt_Key = @NextValue
										  AND BACID = @ThirdValue
										  AND BranchCode = @FourthValue
										  AND DepartmentAlt_Key=@Value
											
									    
										AND ISNULL( AuthorisationStatus,'A' ) ='A'
					UNION
					SELECT  1 FROM [dbo].[DimDepartmentBACID_mod] WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										 AND TerritoryAlt_Key = @NextValue
										 AND BACID = @ThirdValue
										 AND BranchCode = @FourthValue
										 AND DepartmentAlt_Key=@Value
									
										AND AuthorisationStatus in('NP','MP','DP','RM')

				 )
		BEGIN
			SELECT '1' CODE, 'Data Exist' Status
		END
		ELSE
		BEGIN
			SELECT '0' CODE, 'Data Not Exist' Status
		END
	END

	ELSE IF(@CheckFor = 'ContactPersonid')
		BEGIN
		IF EXISTS(SELECT  1 FROM [dbo].[DimDepartmentContactPersonsAgeing] WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										 AND DepartmentAlt_Key = @NextValue
										 AND ContactPersonid=@Value
										 AND ISNULL( AuthorisationStatus,'A' ) ='A'
					UNION
					SELECT  1 FROM [dbo].[DimDepartmentContactPersonsAgeing_Mod] WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										 AND DepartmentAlt_Key = @NextValue
										 AND ContactPersonid=@Value
										 AND AuthorisationStatus in('NP','MP','DP','RM')

				 )
		BEGIN
			SELECT '1' CODE, 'Data Exist' Status
		END
		ELSE
		BEGIN
			SELECT '0' CODE, 'Data Not Exist' Status
		END
	END

	ELSE IF(@CheckFor = 'ContactpersonName')
		BEGIN
		IF EXISTS(SELECT  1 FROM [dbo].[DimBranchContactPerson] WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										 AND BranchCode = @BranchCode
										 AND ContactpersonName=@Value
										 AND ISNULL( AuthorisationStatus,'A' ) ='A'
					UNION
					SELECT  1 FROM [dbo].[DimBranchContactPerson_Mod] WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										 AND BranchCode = @BranchCode
										 AND ContactpersonName=@Value
										 AND AuthorisationStatus in('NP','MP','DP','RM')

				 )
		BEGIN
			SELECT '1' CODE, 'Data Exist' Status
		END
		ELSE
		BEGIN
			SELECT '0' CODE, 'Data Not Exist' Status
		END
	END

	ELSE IF(@CheckFor = 'EmployeeID')
		BEGIN
		IF EXISTS(SELECT  1 FROM [dbo].[DimBranchContactPerson] WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										 AND BranchCode = @BranchCode
										 AND EmployeeID=@Value
										 AND ISNULL( AuthorisationStatus,'A' ) ='A'
					UNION
					SELECT  1 FROM [dbo].[DimBranchContactPerson_Mod] WHERE 
										(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 										
										 AND BranchCode = @BranchCode
										 AND EmployeeID=@Value
										 AND AuthorisationStatus in('NP','MP','DP','RM')

				 )
		BEGIN
			SELECT '1' CODE, 'Data Exist' Status
		END
		ELSE
		BEGIN
			SELECT '0' CODE, 'Data Not Exist' Status
		END
	END
END


GO