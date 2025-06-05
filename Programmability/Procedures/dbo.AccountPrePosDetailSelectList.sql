SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO




CREATE Procedure [dbo].[AccountPrePosDetailSelectList]

					@AccountId varchar(max)=NULL
 AS
 Begin

 Declare @TimeKey as Int
	SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')

SELECT 

				 A.AccountID
				,Z.FacilityType
				,A.POS
				,A.InterestReceivable
				,Q.CustomerID
				,Q.CustomerName
				,Q.UCIF_Id as UCIC
				,Z.segmentcode as Segment
				,V.Balance as BalanceOSPOS
				,V.InterestReceivable as BalanceOSInterestReceivable
				,A.RestructureFlag as RestructureFlagAlt_Key
				--,B.ParameterName as RestructureFlag
				--,A.RestructureDate
				,A.FITLFlag as FITLFlagAlt_Key
				,C.ParameterName as FITLFlag
				,A.DFVAmount
				,A.RePossessionFlag as RePossessionFlagAlt_Key
				,D.ParameterName as RePossessionFlag
				,Case when A.RePossessionFlag='Y' then Convert(varchar(20),I.StatusDate,103) else NULL END as 'RePossessionDate'
				,A.InherentWeaknessFlag as InherentWeaknessFlagAlt_Key
				,E.ParameterName as InherentWeaknessFlag
				,case when A.InherentWeaknessFlag='Y' then convert(varchar(20),J.StatusDate,103) else NULL END as 'InherentWeaknessDate'
				,A.SARFAESIFlag as SARFAESIFlagAlt_Key
				,F.ParameterName as SARFAESIFlag
				,Case when A.SARFAESIFlag='Y' then Convert(varchar(20),K.StatusDate,103) else NULL END as 'SARFAESIDate'
				,A.UnusualBounceFlag as UnusualBounceFlagAlt_Key
				,G.ParameterName as UnusualBounceFlag
				,Case When A.UnusualBounceFlag='Y' then convert(varchar(20),L.StatusDate,103) Else NULL END as 'UnusualBounceDate'
				,A.UnclearedEffectsFlag as UnclearedEffectsFlagAlt_Key
				,H.ParameterName as UnclearedEffectsFlag
				,case when A.UnclearedEffectsFlag='Y' then convert(varchar(20),M.Statusdate,103) else NULL END as 'UnclearedEffectsDate'
				,A.AdditionalProvisionCustomerlevel
				,A.AdditionalProvisionAbsolute
				,A.MOCReason
				,A.FraudAccountFlag as FraudAccountFlagAlt_Key
				,W.ParameterName as FraudAccountFlag	
				,case when A.UnclearedEffectsFlag='Y' then convert(varchar(20),X.STATUSDATE,103) else NULL END as 'FraudDate'
				,A.MOCSource
				,A.ScreenFlag
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

						Inner Join AdvAcBasicDetail Z 
						ON A.AccountID=Z.CustomerACID
						And Z.EffectiveFromTimeKey<=@TimeKey And Z.EffectiveToTimeKey>=@TimeKey

						inner join CustomerBasicDetail Q
						ON Q.CustomerEntityId=Z.CustomerEntityID
						And Q.EffectiveFromTimeKey<=@TimeKey And Q.EffectiveToTimeKey>=@TimeKey

						inner join dbo.AdvAcBalanceDetail V
						ON A.AccountEntityId=V.AccountEntityId
						AND V.EffectiveFromTimeKey<=@Timekey AND V.EffectiveToTimeKey>=@Timekey


						Inner Join (Select ParameterShortNameEnum as ParameterAlt_Key,ParameterName,'RestructureFlag' as Tablename 
						from DimParameter where DimParameterName='DimYesNo'
						And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)B
						ON B.ParameterAlt_Key=A.RestructureFlag

						Inner Join (Select ParameterShortNameEnum as ParameterAlt_Key,ParameterName,'FITLFlag' as Tablename 
						from DimParameter where DimParameterName='DimYesNo'
						And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)C
						ON C.ParameterAlt_Key=A.FITLFlag

						Inner Join (Select ParameterShortNameEnum as ParameterAlt_Key,ParameterName,'RePossessionFlag' as Tablename 
						from DimParameter where DimParameterName='DimYesNo'
						And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)D
						ON D.ParameterAlt_Key=A.RePossessionFlag

						left join (select ACID,StatusType,StatusDate, 'RePossessionDate' as TableName
						from ExceptionFinalStatusType where StatusType like '%Reposse%'
						AND EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) I
						ON A.AccountId=I.ACID

						Inner Join (Select ParameterShortNameEnum as ParameterAlt_Key,ParameterName,'InherentWeaknessFlag' as Tablename 
						from DimParameter where DimParameterName='DimYesNo'
						And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)E
						ON E.ParameterAlt_Key=A.InherentWeaknessFlag

						left join (select ACID,StatusType,StatusDate, 'InherentWeaknessDate' as TableName
						from ExceptionFinalStatusType where StatusType like '%Inherent%'
						AND EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) J
						ON A.AccountId=J.ACID

						Inner Join (Select ParameterShortNameEnum as ParameterAlt_Key,ParameterName,'SARFAESIFlag' as Tablename 
						from DimParameter where DimParameterName='DimYesNo'
						And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)F
						ON F.ParameterAlt_Key=A.SARFAESIFlag

						left join (select ACID,StatusType,StatusDate, 'SARFAESIDate' as TableName
						from ExceptionFinalStatusType where StatusType like '%SARFAESI%'
						AND EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) K
						ON A.AccountID=K.ACID

						Inner Join (Select ParameterShortNameEnum as ParameterAlt_Key,ParameterName,'UnusualBounceFlag' as Tablename 
						from DimParameter where DimParameterName='DimYesNo'
						And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)G
						ON G.ParameterAlt_Key=A.UnusualBounceFlag

						left join (select ACID,StatusType,StatusDate, 'UnusualBounceDate' as TableName
						from ExceptionFinalStatusType where StatusType like '%Unusual%'
						AND EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) L
						ON A.AccountId=L.ACID

						Inner Join (Select ParameterShortNameEnum as ParameterAlt_Key,ParameterName,'UnclearedEffectsFlag' as Tablename 
						from DimParameter where DimParameterName='DimYesNo'
						And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)H
						ON H.ParameterAlt_Key=A.UnclearedEffectsFlag

						left join (select ACID,StatusType,StatusDate, 'UnclearedEffectsDate' as TableName
						from ExceptionFinalStatusType where StatusType like '%Uncleared%'
						AND EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) M
						ON A.AccountId=M.ACID

						left JOIN (	SELECT ACID,
												STATUSTYPE, 
												STATUSDATE 
										FROM ExceptionFinalStatusType 
										WHERE STATUSTYPE like'%FRAUD%'
										AND EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
									) X
									ON A.AccountId=X.ACID

									inner join (select ParameterShortNameEnum as ParameterAlt_Key,ParameterName,'Fraud' as TableName
									from DimParameter where DimParameterName = 'DimYesNo'
									AND EffectiveFromTimeKey <=@TimeKey and EffectiveToTimeKey>=@TimeKey)W
									ON W.ParameterAlt_Key=A.FraudAccountFlag
						Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
						AND A.Accountid=@AccountID


--select 
--EFT.ACID As AccountID,CBD.CustomerName,CBD.CustomerId
--,case when ACBAL.MocStatus='Y' then ACBAL.Balance end  AS 'BalanceOSPOS'
--,case when ACBAL.MocStatus='Y' then ACBAL.InterestReceivable end  AS 'Balance o/s Intt.Receivable'
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


--From [dbo].AdvAcBasicDetail ACBD
--INNER join [dbo].AdvAcBalanceDetail ACBAL ON ACBAL.AccountEntityId= ACBD.AccountEntityId
--                                    and ACBD.EffectiveFromTimeKey<=@Timekey and ACBD.EffectiveToTimeKey>=@Timekey
--									and ACBAL.EffectiveFromTimeKey<=@Timekey and ACBAL.EffectiveToTimeKey>=@Timekey
----INNER join premoc.AdvAcBalanceDetail PREACBAL ON PREACBAL.AccountEntityId= ACBD.AccountEntityId
----                                    and PREACBAL.EffectiveFromTimeKey<=@Timekey and PREACBAL.EffectiveToTimeKey>=@Timekey
--left JOIN [dbo].CustomerBasicDetail CBD ON CBD.CustomerEntityId=ACBD.CustomerEntityId
--                                    and CBD.EffectiveFromTimeKey<=@Timekey and CBD.EffectiveToTimeKey>=@Timekey
--left JOIN ExceptionalDegrationDetail ED ON ED.CustomerID=CBD.CustomerId
--                                     and ED.EffectiveFromTimeKey<=@Timekey and ED.EffectiveToTimeKey>=@Timekey
--left JOIN ExceptionFinalStatusType EFT ON EFT.CustomerID=ED.CustomerID
--                                  and EFT.EffectiveFromTimeKey<=@Timekey and EFT.EffectiveToTimeKey>=@Timekey
--INNER JOIN PRO.ACCOUNTCAL  ACAL  ON CBD.CustomerID=ACAL.RefCustomerID
--WHERE ACBD.CustomerACID=@AccountId

--Union


--select 

--EFT.ACID As AccountID,CBD.CustomerName,CBD.CustomerId
--,case when ACBAL.MocStatus='N' then ACBAL.Balance end  AS 'BalanceOSPOS'
--,case when ACBAL.MocStatus='N' then ACBAL.IntReverseAmt end  AS 'Balance o/s Intt.Receivable'  --InterestReceivable column not available
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


--From [dbo].AdvAcBasicDetail ACBD
--INNER join [dbo].AdvAcBalanceDetail ACBAL ON ACBAL.AccountEntityId= ACBD.AccountEntityId
--                                    and ACBD.EffectiveFromTimeKey<=@Timekey and ACBD.EffectiveToTimeKey>=@Timekey
--									and ACBAL.EffectiveFromTimeKey<=@Timekey and ACBAL.EffectiveToTimeKey>=@Timekey
----INNER join premoc.AdvAcBalanceDetail PREACBAL ON PREACBAL.AccountEntityId= ACBD.AccountEntityId
---- and PREACBAL.EffectiveFromTimeKey<=@Timekey and PREACBAL.EffectiveToTimeKey>=@Timekey
--left JOIN [dbo].CustomerBasicDetail CBD ON CBD.CustomerEntityId=ACBD.CustomerEntityId
--                                    and CBD.EffectiveFromTimeKey<=@Timekey and CBD.EffectiveToTimeKey>=@Timekey
--left JOIN ExceptionalDegrationDetail ED ON ED.CustomerID=CBD.CustomerId
--                                     and ED.EffectiveFromTimeKey<=@Timekey and ED.EffectiveToTimeKey>=@Timekey
--left JOIN ExceptionFinalStatusType EFT ON EFT.CustomerID=ED.CustomerID
--                                  and EFT.EffectiveFromTimeKey<=@Timekey and EFT.EffectiveToTimeKey>=@Timekey
--INNER JOIN PRO.ACCOUNTCAL  ACAL  ON CBD.CustomerID=ACAL.RefCustomerID
--WHERE ACBD.CustomerACID=@AccountId
END

GO