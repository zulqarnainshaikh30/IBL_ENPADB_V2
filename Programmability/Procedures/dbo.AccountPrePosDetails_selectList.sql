SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE Procedure [dbo].[AccountPrePosDetails_selectList]
 @AccountId varchar(max)=NULL,
 @OperationFlag  INT         = 2
 AS
 Begin

 SET NOCOUNT ON;

 Declare @Timekey INT
 SET @Timekey =(Select TimeKey from SysDataMatrix where CurrentStatus='C') 

  SET @Timekey =(Select LastMonthDateKey from SysDayMatrix where Timekey=@Timekey) 

  --Select @Timekey

--Declare @MOCType Varchar(50)
--Declare @MocTypeAlt_Key Int
--Declare @MOCSourceAltkey Int
Declare @CreatedBy Varchar(50)
Declare @DateCreated Date
Declare @ModifiedBy Varchar(50)
Declare @DateModified Date
Declare @ApprovedBy Varchar(50)
Declare @DateApproved Date
Declare @AuthorisationStatus Varchar(5)

SELECT  
	@CreatedBy=CreatedBy,
	@DateCreated=DateCreated,@ModifiedBy=ModifyBy,@DateModified=DateModified,@ApprovedBy=ApprovedBy,@DateApproved=DateApproved,
	@AuthorisationStatus=AuthorisationStatus
	FROM AccountLevelMOC_Mod 
	where AuthorisationStatus in('MP','1A','A') AND AccountID=@AccountId
	AND  EffectiveFromTimeKey=@TimeKey and EffectiveToTimeKey=@TimeKey 
	
	PRINT @TimeKey
	PRINT '@AuthorisationStatus'
	PRINT @AuthorisationStatus
BEGIN TRY
	---PRE MOC

	Declare @DateOfData	 as DateTime
	Set @DateOfData= (Select CAST(B.Date as Date)Date1 from SysDataMatrix A
Inner Join SysDayMatrix B ON A.TimeKey=B.TimeKey
 where A.CurrentStatus='C')
 
DROP TABLE IF EXISTS #ACCOUNT_PREMOC

Select * INTO  #ACCOUNT_PREMOC from(
SELECT AccountEntityId,CustomerACID as AccountID,Balance,InttServiced,FLGFITL,DFVAmt,RePossession,RepossessionDate,Sarfaesi,AddlProvision,FlgMoc,
	UCIF_ID as UCICID,@AuthorisationStatus as AuthorisationStatus,@CreatedBy as CreatedBy,
	@DateCreated as DateCreated,@ModifiedBy as ModifiedBy,@DateModified as DateModified,@ApprovedBy as ApprovedBy,@DateApproved as DateApproved

	
	
FROM   [PreMoc].[AccountCal] where EffectiveFromTimeKey=@TimeKey and EffectiveToTimeKey=@TimeKey 
AND  CustomerAcID=@AccountId
UNION all
SELECT AccountEntityId,CustomerACID as AccountID,Balance,InttServiced,FLGFITL,DFVAmt,RePossession,RepossessionDate,Sarfaesi,AddlProvision,FlgMoc,

	UCIF_ID as UCICID,@AuthorisationStatus as AuthorisationStatus,@CreatedBy as CreatedBy,
	@DateCreated as DateCreated,@ModifiedBy as ModifiedBy,@DateModified as DateModified,@ApprovedBy as ApprovedBy,@DateApproved as DateApproved
	
FROM   [Pro].[ACCOUNTCAL_HIST] where EffectiveFromTimeKey=@TimeKey 
AND EffectiveToTimeKey=@TimeKey and isnull(FlgMoc,'N')='N'
AND    CustomerAcID=@AccountId
) X 

----POST 

--Select '#CUST_PREMOC',* from #CUST_PREMOC

DROP TABLE IF EXISTS #ACCOUNT_POSTMOC


    SELECT AccountEntityId,AccountID as AccountID,POS as Balance,InterestReceivable,DFVAmount,RePossessionFlag,RepossessionDate,SarfaesiFlag,'' asFlgMoc,
	'' as UCICID,@AuthorisationStatus as AuthorisationStatus,@CreatedBy as CreatedBy,
	@DateCreated as DateCreated,@ModifiedBy as ModifiedBy,@DateModified as DateModified,@ApprovedBy as ApprovedBy,@DateApproved as DateApproved
	

	INTO #ACCOUNT_POSTMOC
	FROM AccountLevelMOC_Mod 
	where AuthorisationStatus = CASE WHEN @OperationFlag =20 THEN '1A' ELSE 'MP' END
	AND  EffectiveFromTimeKey=@TimeKey and EffectiveToTimeKey=@TimeKey AND AccountID=@AccountId


	

IF NOT EXISTS(SELECT 1 FROM #ACCOUNT_POSTMOC WHERE AccountID=@AccountId)
BEGIN
	INSERT  INTO  #ACCOUNT_POSTMOC
	SELECT AccountEntityId,CustomerACID as AccountID,Balance,InttServiced,FLGFITL,DFVAmt,RePossession,RepossessionDate,Sarfaesi,AddlProvision,FlgMoc,
	UCIF_ID as UCICID,@AuthorisationStatus as AuthorisationStatus,@CreatedBy as CreatedBy,
	@DateCreated as DateCreated,@ModifiedBy as ModifiedBy,@DateModified as DateModified,@ApprovedBy as ApprovedBy,@DateApproved as DateApproved
	
	FROM   [Pro].[ACCOUNTCAL_HIST]
	WHERE EffectiveFromTimeKey=@TimeKey and EffectiveToTimeKey=@TimeKey and isnull(FlgMoc,'N')='Y'
	AND CustomerACID=@AccountId
END
	--Select '#CUST_POSTMOC',* from #CUST_POSTMOC

	SELECT 

				 A.CustomerACID as AccountID
				,'' as FacilityType--A.FacilityType
				,A.Balance as Balance --A.POS
				,A.InterestReceivable
				,'' as CustomerID
				,'' as CustomerName
				,'' as UCIC
				,'' as Segment
				,'' as BalanceOSPOS
				,'' as BalanceOSInterestReceivable --A.
				,1 as RestructureFlagAlt_Key --A.RestructureFlagAlt_Key
				,'' as RestructureFlag --B.ParameterName as RestructureFlag
				,'' as RestructureDate --A.RestructureDate
				,'' as FITLFlagAlt_Key  --A.FITLFlagAlt_Key
				,'' as FITLFlag --C.ParameterName as FITLFlag
				,A.DFVAmount
				,B.Balance AS Balance_POS
				,B.InterestReceivable As InterestReceivable_POS
				,B.DFVAmount As DFVAmount_POS
				,'' as RePossessionFlagAlt_Key --A.RePossessionFlagAlt_Key
				,'' as RePossessionFlag
				,'' as 'RePossessionDate'
				,'' as InherentWeaknessFlagAlt_Key --A.InherentWeaknessFlagAlt_Key
				,'' as InherentWeaknessFlag
				,'' as 'InherentWeaknessDate'
				,'' as SARFAESIFlagAlt_Key --A.SARFAESIFlagAlt_Key
				,'' as SARFAESIFlag
				,'' as 'SARFAESIDate'
				,'' as UnusualBounceFlagAlt_Key --A.UnusualBounceFlagAlt_Key
				,'' as UnusualBounceFlag
				,'' as 'UnusualBounceDate'
				,'' AS UnclearedEffectsFlagAlt_Key --A.UnclearedEffectsFlagAlt_Key
				,'' as UnclearedEffectsFlag
				,'' as 'UnclearedEffectsDate'
				,'' as AdditionalProvisionCustomerlevel --A.AdditionalProvisionCustomerlevel
				,'' as AdditionalProvisionAbsolute --A.AdditionalProvisionAbsolute
				,'' as MOCReason --A.MOCReason
				,'' as FraudAccountFlagAlt_Key-- A.FraudAccountFlagAlt_Key
				,'' As  FraudAccountFlag	
				,'' AS FraudDate
				,Isnull(A.AuthorisationStatus,'A') as  AuthorisationStatus
                ,@TimeKey as EffectiveFromTimeKey --A.EffectiveFromTimeKey
                ,@TimeKey as EffectiveToTimeKey -- A.EffectiveToTimeKey
                ,A.CreatedBy
                ,A.DateCreated
                ,A.ApprovedBy 
                ,A.DateApproved 
                ,A.ModifiedBy
                ,A.DateModified
				,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
				,IsNull(A.DateModified,A.DateCreated)as CrModDate
				FROM #Account_PREMOC A
	                  LEFT JOIN #Account_POSTMOC B ON A.AccountID=B.AccountID

						Inner Join (Select ParameterAlt_Key,ParameterName,'FITLFlag' as Tablename 
						from DimParameter where DimParameterName='DimYN'
						And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)C
						ON C.ParameterAlt_Key=A.FITLFlagAlt_Key

						Inner Join (Select ParameterAlt_Key,ParameterName,'RePossessionFlag' as Tablename 
						from DimParameter where DimParameterName='DimYN'
						And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)D
						ON D.ParameterAlt_Key=A.RePossessionFlagAlt_Key

						left join (select CustomerID,StatusType,StatusDate, 'RePossessionDate' as TableName
						from ExceptionFinalStatusType where StatusType like '%Reposse%'
						AND EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) I
						ON A.CustomerID=I.CustomerID

						Inner Join (Select ParameterAlt_Key,ParameterName,'InherentWeaknessFlag' as Tablename 
						from DimParameter where DimParameterName='DimYN'
						And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)E
						ON E.ParameterAlt_Key=A.InherentWeaknessFlagAlt_Key

						left join (select CustomerID,StatusType,StatusDate, 'InherentWeaknessDate' as TableName
						from ExceptionFinalStatusType where StatusType like '%Inherent%'
						AND EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) J
						ON A.CustomerID=J.CustomerID

						Inner Join (Select ParameterAlt_Key,ParameterName,'SARFAESIFlag' as Tablename 
						from DimParameter where DimParameterName='DimYN'
						And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)F
						ON F.ParameterAlt_Key=A.SARFAESIFlagAlt_Key

						left join (select CustomerID,StatusType,StatusDate, 'SARFAESIDate' as TableName
						from ExceptionFinalStatusType where StatusType like '%SARFAESI%'
						AND EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) K
						ON A.CustomerID=K.CustomerID

						Inner Join (Select ParameterAlt_Key,ParameterName,'UnusualBounceFlag' as Tablename 
						from DimParameter where DimParameterName='DimYN'
						And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)G
						ON G.ParameterAlt_Key=A.UnusualBounceFlagAlt_Key

						left join (select CustomerID,StatusType,StatusDate, 'UnusualBounceDate' as TableName
						from ExceptionFinalStatusType where StatusType like '%Unusual%'
						AND EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) L
						ON A.CustomerID=L.CustomerID

						Inner Join (Select ParameterAlt_Key,ParameterName,'UnclearedEffectsFlag' as Tablename 
						from DimParameter where DimParameterName='DimYN'
						And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)H
						ON H.ParameterAlt_Key=A.UnclearedEffectsFlagAlt_Key

						left join (select CustomerID,StatusType,StatusDate, 'UnclearedEffectsDate' as TableName
						from ExceptionFinalStatusType where StatusType like '%Uncleared%'
						AND EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) M
						ON A.CustomerID=M.CustomerID

						left JOIN (	SELECT CustomerID,
												STATUSTYPE, 
												STATUSDATE 
										FROM ExceptionFinalStatusType 
										WHERE STATUSTYPE like'%FRAUD%'
										AND EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
									) X
									ON A.CustomerID=X.CustomerID

									inner join (select ParameterAlt_Key,ParameterName,'Fraud' as TableName
									from DimParameter where DimParameterName = 'DimYN'
									AND EffectiveFromTimeKey <=@TimeKey and EffectiveToTimeKey>=@TimeKey)W
									ON W.ParameterAlt_Key=A.FraudAccountFlagAlt_Key
						Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
						AND A.Accountid=@AccountID

--select 
--EFT.ACID As AccountID,CBD.CustomerName,CBD.CustomerId
--,case when ACBAL.MocStatus='Y' then ACBAL.Balance end  AS 'BalanceOSPOS'
------,case when PREACBAL.MocStatus='Y' then PREACBAL.Balance end  AS 'post_Balance o/s POS'
--,case when ACBAL.MocStatus='Y' then ACBAL.InterestReceivable end  AS 'BalanceosIntt.Receivable'
------,case when PREACBAL.MocStatus='Y' then ACBAL.InterestReceivable end  AS 'Post_Balance o/s Intt.Receivable'
------,ACBAL.InterestReceivable AS 'Balance o/s Intt.Receivable'
--,'Y' AS 'RestructureFlag'
--,NULL AS 'RestructureDate'
--,ACAL.FlgFITL AS 'FITLFlag'
--,ACAL.DFVAmt AS 'DFVAmt'
--,CASE WHEN EFT.StatusType='Repossesed' THEN 'Repossesed' END  AS 'RePossessionFlag'
--,CASE WHEN EFT.StatusType='Repossesed'  THEN StatusDate  END AS 'RePossessionDate'
--,CASE WHEN EFT.StatusType='Inherent Weakness' THEN 'Inherent Weakness'  END AS 'Inherent Weakness Flag'
--,CASE WHEN EFT.StatusType='Inherent Weakness'  THEN StatusDate  END AS 'Inherent Weakness Date'

--,CASE WHEN EFT.StatusType='SARFAESI' THEN 'SARFAESI'  END AS 'SARFAESI Flag'
--,CASE WHEN EFT.StatusType='SARFAESI'  THEN StatusDate ELSE '' END  AS 'SARFAESI Date'

--,CASE WHEN EFT.StatusType='Unusual Bounce' THEN 'Unusual Bounce' ELSE '' END AS 'Unusual Bounce Flag'
--,CASE WHEN EFT.StatusType='Unusual Bounce'  THEN CAST(StatusDate AS Date) ELSE '' END  AS 'Unusual Bounce Date'

--,CASE WHEN EFT.StatusType='Uncleared Effect' THEN 'Uncleared Effect' ELSE '' END AS 'Uncleared Effect Flag'
--,CASE WHEN EFT.StatusType='Uncleared Effect'  THEN CAST(StatusDate AS Date) ELSE '' END  AS 'Uncleared Effect Date'

--,NULL AS 'AdditionalProvisionCustomerLevel'
--,NULL AS 'AdditionalProvisionAbsolute'
--,NULL AS 'MOCReason'


--From [CurDat].AdvAcBasicDetail ACBD
--INNER join [CurDat].AdvAcBalanceDetail ACBAL ON ACBAL.AccountEntityId= ACBD.AccountEntityId
--                                    and ACBD.EffectiveFromTimeKey<=@Timekey and ACBD.EffectiveToTimeKey>=@Timekey
--									and ACBAL.EffectiveFromTimeKey<=@Timekey and ACBAL.EffectiveToTimeKey>=@Timekey
----INNER join premoc.AdvAcBalanceDetail PREACBAL ON PREACBAL.AccountEntityId= ACBD.AccountEntityId
----                                    and PREACBAL.EffectiveFromTimeKey<=@Timekey and PREACBAL.EffectiveToTimeKey>=@Timekey
--left JOIN [CurDat].CustomerBasicDetail CBD ON CBD.CustomerEntityId=ACBD.CustomerEntityId
--                                    and CBD.EffectiveFromTimeKey<=@Timekey and CBD.EffectiveToTimeKey>=@Timekey
--left JOIN ExceptionalDegrationDetail ED ON ED.CustomerID=CBD.CustomerId
--                                     and ED.EffectiveFromTimeKey<=@Timekey and ED.EffectiveToTimeKey>=@Timekey
--left JOIN ExceptionFinalStatusType EFT ON EFT.ACID=ACBD.CustomerACID
--                                  and EFT.EffectiveFromTimeKey<=@Timekey and EFT.EffectiveToTimeKey>=@Timekey
--left JOIN PRO.ACCOUNTCAL  ACAL  ON CBD.CustomerID=ACAL.RefCustomerID
--WHERE EFT.ACID=@AccountId

Union

SELECT 

				 A.AccountID
				,A.FacilityType
				,A.POS
				,A.InterestReceivable
				,A.CustomerID
				,A.CustomerName
				,A.UCIC
				,A.Segment
				,A.BalanceOSPOS
				,A.BalanceOSInterestReceivable
				,A.RestructureFlagAlt_Key
				,B.ParameterName as RestructureFlag
				,A.RestructureDate
				,A.FITLFlagAlt_Key
				,C.ParameterName as FITLFlag
				,A.DFVAmount
				,A.RePossessionFlagAlt_Key
				,D.ParameterName as RePossessionFlag
				,Case when A.RePossessionFlagAlt_Key=1 then Convert(varchar(20),I.StatusDate,103) else NULL END as 'RePossessionDate'
				,A.InherentWeaknessFlagAlt_Key
				,E.ParameterName as InherentWeaknessFlag
				,case when A.InherentWeaknessFlagAlt_Key=1 then convert(varchar(20),J.StatusDate,103) else NULL END as 'InherentWeaknessDate'
				,A.SARFAESIFlagAlt_Key
				,F.ParameterName as SARFAESIFlag
				,Case when A.SARFAESIFlagAlt_Key=1 then Convert(varchar(20),K.StatusDate,103) else NULL END as 'SARFAESIDate'
				,A.UnusualBounceFlagAlt_Key
				,G.ParameterName as UnusualBounceFlag
				,Case When A.UnusualBounceFlagAlt_Key=1 then convert(varchar(20),L.StatusDate,103) Else NULL END as 'UnusualBounceDate'
				,A.UnclearedEffectsFlagAlt_Key
				,H.ParameterName as UnclearedEffectsFlag
				,case when A.UnclearedEffectsFlagAlt_Key=1 then convert(varchar(20),M.Statusdate,103) else NULL END as 'UnclearedEffectsDate'
				,A.AdditionalProvisionCustomerlevel
				,A.AdditionalProvisionAbsolute
				,A.MOCReason
				,A.FraudAccountFlagAlt_Key
				,W.ParameterName as FraudAccountFlag	
				,convert(varchar(20),X.STATUSDATE,103) FraudDate
				,Isnull(A.AuthorisationStatus,'A') as  AuthorisationStatus
                ,A.EffectiveFromTimeKey
                ,A.EffectiveToTimeKey
                ,A.CreatedBy
                ,A.DateCreated
                ,A.ApprovedBy 
                ,A.DateApproved 
                ,A.ModifyBy
                ,A.DateModified
				,IsNull(A.ModifyBy,A.CreatedBy)as CrModBy
				,IsNull(A.DateModified,A.DateCreated)as CrModDate
				FROM AccountLevelMOC A
						Inner Join (Select ParameterAlt_Key,ParameterName,'RestructureFlag' as Tablename 
						from DimParameter where DimParameterName='DimYN'
						And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)B
						ON B.ParameterAlt_Key=A.RestructureFlagAlt_Key

						Inner Join (Select ParameterAlt_Key,ParameterName,'FITLFlag' as Tablename 
						from DimParameter where DimParameterName='DimYN'
						And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)C
						ON C.ParameterAlt_Key=A.FITLFlagAlt_Key

						Inner Join (Select ParameterAlt_Key,ParameterName,'RePossessionFlag' as Tablename 
						from DimParameter where DimParameterName='DimYN'
						And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)D
						ON D.ParameterAlt_Key=A.RePossessionFlagAlt_Key

						left join (select CustomerID,StatusType,StatusDate, 'RePossessionDate' as TableName
						from ExceptionFinalStatusType where StatusType like '%Reposse%'
						AND EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) I
						ON A.CustomerID=I.CustomerID

						Inner Join (Select ParameterAlt_Key,ParameterName,'InherentWeaknessFlag' as Tablename 
						from DimParameter where DimParameterName='DimYN'
						And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)E
						ON E.ParameterAlt_Key=A.InherentWeaknessFlagAlt_Key

						left join (select CustomerID,StatusType,StatusDate, 'InherentWeaknessDate' as TableName
						from ExceptionFinalStatusType where StatusType like '%Inherent%'
						AND EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) J
						ON A.CustomerID=J.CustomerID

						Inner Join (Select ParameterAlt_Key,ParameterName,'SARFAESIFlag' as Tablename 
						from DimParameter where DimParameterName='DimYN'
						And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)F
						ON F.ParameterAlt_Key=A.SARFAESIFlagAlt_Key

						left join (select CustomerID,StatusType,StatusDate, 'SARFAESIDate' as TableName
						from ExceptionFinalStatusType where StatusType like '%SARFAESI%'
						AND EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) K
						ON A.CustomerID=K.CustomerID

						Inner Join (Select ParameterAlt_Key,ParameterName,'UnusualBounceFlag' as Tablename 
						from DimParameter where DimParameterName='DimYN'
						And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)G
						ON G.ParameterAlt_Key=A.UnusualBounceFlagAlt_Key

						left join (select CustomerID,StatusType,StatusDate, 'UnusualBounceDate' as TableName
						from ExceptionFinalStatusType where StatusType like '%Unusual%'
						AND EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) L
						ON A.CustomerID=L.CustomerID

						Inner Join (Select ParameterAlt_Key,ParameterName,'UnclearedEffectsFlag' as Tablename 
						from DimParameter where DimParameterName='DimYN'
						And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)H
						ON H.ParameterAlt_Key=A.UnclearedEffectsFlagAlt_Key

						left join (select CustomerID,StatusType,StatusDate, 'UnclearedEffectsDate' as TableName
						from ExceptionFinalStatusType where StatusType like '%Uncleared%'
						AND EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) M
						ON A.CustomerID=M.CustomerID

						left JOIN (	SELECT CustomerID,
												STATUSTYPE, 
												STATUSDATE 
										FROM ExceptionFinalStatusType 
										WHERE STATUSTYPE like'%FRAUD%'
										AND EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
									) X
									ON A.CustomerID=X.CustomerID

									inner join (select ParameterAlt_Key,ParameterName,'Fraud' as TableName
									from DimParameter where DimParameterName = 'DimYN'
									AND EffectiveFromTimeKey <=@TimeKey and EffectiveToTimeKey>=@TimeKey)W
									ON W.ParameterAlt_Key=A.FraudAccountFlagAlt_Key
						Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
						AND A.Accountid=@AccountID


--select 

--EFT.ACID As AccountID,CBD.CustomerName,CBD.CustomerId
--,case when ACBAL.MocStatus='N' then ACBAL.Balance end  AS 'BalanceOSPOS'
----,case when PREACBAL.MocStatus='Y' then PREACBAL.Balance end  AS 'post_Balance o/s POS'
--,case when ACBAL.MocStatus='N' then ACBAL.IntReverseAmt end  AS 'BalanceosIntt.Receivable'  --InterestReceivable column not available
----,case when PREACBAL.MocStatus='Y' then ACBAL.InterestReceivable end  AS 'Post_Balance o/s Intt.Receivable'
----,ACBAL.InterestReceivable AS 'Balance o/s Intt.Receivable'
--,'Y' AS 'RestructureFlag'
--,NULL AS 'RestructureDate'
--,ACAL.FlgFITL AS 'FITLFlag'
--,ACAL.DFVAmt AS 'DFVAmt'
--,CASE WHEN EFT.StatusType='Repossesed' THEN 'Repossesed' END  AS 'RePossessionFlag'
--,CASE WHEN EFT.StatusType='Repossesed'  THEN StatusDate  END AS 'RePossessionDate'
--,CASE WHEN EFT.StatusType='Inherent Weakness' THEN 'Inherent Weakness'  END AS 'Inherent Weakness Flag'
--,CASE WHEN EFT.StatusType='Inherent Weakness'  THEN StatusDate  END AS 'Inherent Weakness Date'

--,CASE WHEN EFT.StatusType='SARFAESI' THEN 'SARFAESI'  END AS 'SARFAESI Flag'
--,CASE WHEN EFT.StatusType='SARFAESI'  THEN StatusDate ELSE '' END  AS 'SARFAESI Date'

--,CASE WHEN EFT.StatusType='Unusual Bounce' THEN 'Unusual Bounce' ELSE '' END AS 'Unusual Bounce Flag'
--,CASE WHEN EFT.StatusType='Unusual Bounce'  THEN CAST(StatusDate AS Date) ELSE '' END  AS 'Unusual Bounce Date'

--,CASE WHEN EFT.StatusType='Uncleared Effect' THEN 'Uncleared Effect' ELSE '' END AS 'Uncleared Effect Flag'
--,CASE WHEN EFT.StatusType='Uncleared Effect'  THEN CAST(StatusDate AS Date) ELSE '' END  AS 'Uncleared Effect Date'

--,NULL AS 'AdditionalProvisionCustomerLevel'
--,NULL AS 'AdditionalProvisionAbsolute'
--,NULL AS 'MOCReason'


--From [CurDat].AdvAcBasicDetail ACBD

--INNER join [CurDat].AdvAcBalanceDetail ACBAL ON ACBAL.AccountEntityId= ACBD.AccountEntityId
--                                    and ACBD.EffectiveFromTimeKey<=@Timekey and ACBD.EffectiveToTimeKey>=@Timekey
--									and ACBAL.EffectiveFromTimeKey<=@Timekey and ACBAL.EffectiveToTimeKey>=@Timekey
----INNER join premoc.AdvAcBalanceDetail PREACBAL ON PREACBAL.AccountEntityId= ACBD.AccountEntityId
----                                    and PREACBAL.EffectiveFromTimeKey<=@Timekey and PREACBAL.EffectiveToTimeKey>=@Timekey
--left JOIN [CurDat].CustomerBasicDetail CBD ON CBD.CustomerEntityId=ACBD.CustomerEntityId
--                                    and CBD.EffectiveFromTimeKey<=@Timekey and CBD.EffectiveToTimeKey>=@Timekey
--left JOIN ExceptionalDegrationDetail ED ON ED.CustomerID=CBD.CustomerId
--                                     and ED.EffectiveFromTimeKey<=@Timekey and ED.EffectiveToTimeKey>=@Timekey
--left JOIN ExceptionFinalStatusType EFT ON EFT.ACID=ACBD.CustomerACID
--                                  and EFT.EffectiveFromTimeKey<=@Timekey and EFT.EffectiveToTimeKey>=@Timekey
--left JOIN PRO.ACCOUNTCAL  ACAL  ON CBD.CustomerID=ACAL.RefCustomerID
--WHERE EFT.ACID=@AccountId

END TRY
	BEGIN CATCH
	
	INSERT INTO dbo.Error_Log
				SELECT ERROR_LINE() as ErrorLine,ERROR_MESSAGE()ErrorMessage,ERROR_NUMBER()ErrorNumber
				,ERROR_PROCEDURE()ErrorProcedure,ERROR_SEVERITY()ErrorSeverity,ERROR_STATE()ErrorState
				,GETDATE()

	SELECT ERROR_MESSAGE()
	--RETURN -1
   
	END CATCH
END



GO