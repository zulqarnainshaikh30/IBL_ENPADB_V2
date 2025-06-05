SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



CREATE PROC [dbo].[CustomerAccountMOC]
 
	 --DECLARE 
	-- @XMLDocument          XML='<DataSet>
	--<AuditMOC>
	--<MOC_TYPE> A</MOC_TYPE>
	--<CustomerId>002686851</CustomerId>
	--<ConstitutionAlt_Key>199</ConstitutionAlt_Key>
	--<CustomerAcId>3008020450000044</CustomerAcId>
	--<SchemeAlt_Key>2</SchemeAlt_Key>
	--<PreMocBalance>20000</PreMocBalance>
	--<InterestReversalChg>5000</InterestReversalChg>
	--<LoanProcessChg>10000</LoanProcessChg>
	--<ServiceTax>100</ServiceTax>
	--<InttSubvention>120</InttSubvention>
	--<OtherMocAmt>250</OtherMocAmt>
	--<FinalSecurityValue>150000</FinalSecurityValue>
	--<FinalSubsidyAmt>5000</FinalSubsidyAmt>
	--<PreMocAssetClassification>1</PreMocAssetClassification>
	--<PostMocAssetClassification>2</PostMocAssetClassification>
	--<PostMoc_NPAdt>''01/05/2016''</PostMoc_NPAdt>
	--<PostMoc_NPAdt>''01/05/2017''</PostMoc_NPAdt>
	--<Remark>A</Remark>
	--<ROWNO>1</ROWNO>
	--</AuditMOC></DataSet>' 
	--,@Remark				Varchar(1000)
	--,@MenuID				INT
	--,@OperationFlag			SMALLINT
	--,@AuthMode				CHAR(2)	
	--,@EffectiveFromTimeKey	INT
	--,@EffectiveToTimeKey	INT
	   @TimeKey				INT
	  ,@CrModApBy				VARCHAR(20)='MOCUPLOAD'
	--,@D2Ktimestamp	        TIMESTAMP     =0 OUTPUT 
	 ,@Result                INT   =0 OUTPUT
	--,@ErrorMsg				Varchar(max)='' OUTPUT
	--WITH RECOMPILE
AS

SET DATEFORMAT dmy


--TRUNCATE TABLE Sample_Data
--INSERT INTO Sample_Data
--SELECT * FROM #Sample_Data



--if NOT exists (SELECT *FROM   INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = N'MocCustomerDataUpload' 
--  AND  COLUMN_NAME = 'CustomerEntityID')
--ALTER TABLE dataupload.MocCustomerDataUpload ADD CustomerEntityID INT

--if NOT exists (SELECT *FROM   INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = N'MocAccountDataUpload'  
-- AND  COLUMN_NAME = 'CustomerEntityID')
--ALTER TABLE dataupload.MocAccountDataUpload	 ADD CustomerEntityID INT

--if NOT exists (SELECT *FROM   INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = N'MocAccountDataUpload'  
-- AND  COLUMN_NAME = 'AccountEntityid')
--ALTER TABLE dataupload.MocAccountDataUpload	 ADD AccountEntityid INT


DECLARE @PROCESSINGDATE DATE=(SELECT DATE FROM SYSDAYMATRIX WHERE TIMEKEY=@TIMEKEY)
DECLARE @SetID INT =(SELECT ISNULL(MAX(ISNULL(SETID,0)),0)+1 FROM [PRO].[ProcessMonitor] WHERE TimeKey=@TIMEKEY )
 SET @TIMEKEY= (SELECT TIMEKEY FROM SYSDAYMATRIX WHERE TIMEKEY=@TIMEKEY)

DECLARE @MocTimeKey INT = @Timekey
		



SELECT A.CustomerEntityId,A.AccountEntityid
		,ISNULL(BB.MOCAssetClassification,CL.AssetClassShortNameEnum) MOCAssetClassification
		,ISNULL(BB.NPADATE,NPADT) NPADATE
		,AmountofWriteOff,ISNULL(A.Balance,C.Balance) Balance, UnservInterestAmt,
			A.AdditionalProvision,	AdditionalProvisionAmount 
	INTO #CUST_AC_MOC
FROM dataupload.MocAccountDataUpload A
	LEFT JOIN  dataupload.MocCustomerDataUpload BB
		ON A.CustomerEntityID =BB.CustomerEntityID
	INNER JOIN dbo.AdvAcBalanceDetail C
		ON C.AccountEntityId=A.AccountEntityId
		AND (C.EffectiveFromTimeKey<=@MocTimeKey AND C.EffectiveToTimeKey>=@MocTimeKey)
	INNER JOIN DimAssetClass CL
		ON CL.AssetClassAlt_Key=C.AssetClassAlt_Key
		AND (CL.EffectiveFromTimeKey<=@MocTimeKey AND CL.EffectiveToTimeKey>=@MocTimeKey)
	INNER JOIN AdvAcFinancialDetail D
		ON D.AccountEntityId=A.AccountEntityId
		AND (D.EffectiveFromTimeKey<=@MocTimeKey AND D.EffectiveToTimeKey>=@MocTimeKey)

INSERT INTO #CUST_AC_MOC
SELECT A.CustomerEntityId,B.AccountEntityid,A.MOCAssetClassification,A.NPADATE, 0 AmountofWriteOff,C. Balance, c.UnAppliedIntAmount  UnservInterestAmt,	0 AdditionalProvision,	AdditionalProv AdditionalProvisionAmount 
FROM dataupload.MocCustomerDataUpload A
	INNER JOIN AdvAcBasicDetail B
		ON A.CustomerEntityID=B.CustomerEntityId
		AND (B.EffectiveFromTimeKey<=@MocTimeKey AND B.EffectiveToTimeKey>=@MocTimeKey)
	INNER JOIN dbo.AdvAcBalanceDetail C
		ON C.AccountEntityId=B.AccountEntityId
		AND (C.EffectiveFromTimeKey<=@MocTimeKey AND C.EffectiveToTimeKey>=@MocTimeKey)
	INNER JOIN AdvAcFinancialDetail D
		ON D.AccountEntityId=B.AccountEntityId
		AND (D.EffectiveFromTimeKey<=@MocTimeKey AND D.EffectiveToTimeKey>=@MocTimeKey)
	LEFT JOIN #CUST_AC_MOC E
		ON E.AccountEntityid=B.AccountEntityid
	WHERE E.AccountEntityid IS NULL


INSERT INTO #CUST_AC_MOC
SELECT A.CustomerEntityId,B.AccountEntityid,CL.AssetClassShortNameEnum MOCAssetClassification
		,D.NpaDt NPADATE, 0 AmountofWriteOff,C. Balance, C.UnAppliedIntAmount  UnservInterestAmt
		,	0 AdditionalProvision,	AdditionalProv AdditionalProvisionAmount 
 FROM (SELECT CustomerEntityId FROM dataupload.MocAccountDataUpload
		GROUP BY CustomerEntityId
	  ) A
	INNER JOIN AdvAcBasicDetail B
		ON A.CustomerEntityID=B.CustomerEntityId
		AND (B.EffectiveFromTimeKey<=@MocTimeKey AND B.EffectiveToTimeKey>=@MocTimeKey)
	INNER JOIN dbo.AdvAcBalanceDetail C
		ON C.AccountEntityId=B.AccountEntityId
		AND (C.EffectiveFromTimeKey<=@MocTimeKey AND C.EffectiveToTimeKey>=@MocTimeKey)
	INNER JOIN DimAssetClass CL
		ON CL.AssetClassAlt_Key=C.AssetClassAlt_Key
		AND (CL.EffectiveFromTimeKey<=@MocTimeKey AND CL.EffectiveToTimeKey>=@MocTimeKey)

	INNER JOIN AdvAcFinancialDetail D
		ON D.AccountEntityId=B.AccountEntityId
		AND (D.EffectiveFromTimeKey<=@MocTimeKey AND D.EffectiveToTimeKey>=@MocTimeKey)
	LEFT JOIN #CUST_AC_MOC E
		ON E.AccountEntityid=B.AccountEntityid
	WHERE E.AccountEntityid IS NULL


	
BEGIN TRY
 BEGIN TRAN 

 

DROP TABLE IF EXISTS #CustNpa
SELECT  A.CustomerEntityId, CustomerId, 
         CASE WHEN ISNULL(A.MOCAssetClassification,'')<>'' THEN  A.MOCAssetClassification  ELSE ACL.AssetClassShortName 
		 END AS PostMocAssetClassification
      --  , MOCAssetClassification PostMocAssetClassification	
		,CASE WHEN ISNULL(A.NPADate,'')<>'' THEN  A.NPADate  ELSE B.NPADt END AS PostMoc_NPAdt,
		NULL PostMoc_DBtdt
		,CASE WHEN ACL1.AssetClassAlt_Key IS NULL THEN ACL.AssetClassAlt_Key ELSE ACL1.AssetClassAlt_Key END AS  PostMocAssetClassAlt_key
		INTO #CustNpa
	FROM dataupload.MocCustomerDataUpload A
	LEFT JOIN AdvCustNPAdetail B
		ON A.CustomerEntityID=b.CustomerEntityID
		AND (b.EffectiveFromTimeKey<=@MocTimeKey and b.EffectiveToTimeKey>=@MocTimeKey)
	left join DimAssetClass ACL ON	  B.Cust_AssetClassAlt_Key= ACL.AssetClassAlt_Key
		AND (ACL.EffectiveFromTimeKey<=@MocTimeKey and ACL.EffectiveToTimeKey>=@MocTimeKey)
	left join DimAssetClass ACL1 ON	  A.MOCAssetClassification= ACL1.AssetClassShortName
		AND (ACL1.EffectiveFromTimeKey<=@MocTimeKey and ACL1.EffectiveToTimeKey>=@MocTimeKey)
WHERE (CASE WHEN MOCAssetClassification='' THEN ACL.AssetClassShortName ELSE MOCAssetClassification END <>ISNULL(ACL.AssetClassShortName,'STD'))

UPDATE #CustNpa SET PostMoc_NPAdt=NULL WHERE PostMocAssetClassification='STD'


DROP TABLE IF EXISTS #Npadt
SELECT CustomerEntityId, MAX(PostMocAssetClassAlt_key)PostMocAssetClassAlt_key
, CAST(NULL AS VARCHAR(10))PostMoc_NPAdt
, CAST(NULL AS VARCHAR(10))PostMoc_DBtdt
INTO #Npadt
FROM #CustNpa
GROUP BY CustomerEntityId


UPDATE N
SET		PostMoc_NPAdt	= CASE WHEN ISNULL(C.PostMoc_NPAdt,'')<>''  THEN C.PostMoc_NPAdt ELSE NULL END
		,PostMoc_DBtdt	= CASE WHEN ISNULL(C.PostMoc_DBtdt,'')<>'' THEN C.PostMoc_DBtdt ELSE NULL END
 FROM #Npadt N
INNER JOIN #CustNpa C
	ON N.CustomerEntityId = C.CustomerEntityId
	AND N.PostMocAssetClassAlt_key = C.PostMocAssetClassAlt_key

UPDATE A
	SET A.PostMoc_NPAdt=B.PostMoc_NPAdt
		,A.PostMoc_DBtdt=B.PostMoc_DBtdt
		,A.PostMocAssetClassAlt_key=B.PostMocAssetClassAlt_key
FROM #CustNpa A
	INNER JOIN  #Npadt B
	ON A.CustomerEntityId=B.CustomerEntityId




PRINT 'START MOC FOR ADVCUSTNPADETAIL'
IF OBJECT_ID('Tempdb..#TmpCustNPA') IS NOT NULL
				DROP TABLE #TmpCustNPA	
			

			SELECT NPA.* 
				INTO #TmpCustNPA
			FROM AdvCustNPADetail NPA
				INNER JOIN (SELECT CustomerEntityId FROM #Npadt
									WHERE  CustomerEntityId IS NOT NULL
									----AND ISNULL(PreMocAssetClassification,'')<>ISNULL(PostMocAssetClassification,'')
								GROUP BY CustomerEntityId
							) T
					ON (NPA.CustomerEntityId=T.CustomerEntityId)
					AND (NPA.EffectiveFromTimeKey<=@MocTimeKey AND NPA.EffectiveToTimeKey>=@MocTimeKey)

		PRINT CAST(@@ROWCOUNT AS VARCHAR(20))+'Row In Temp Table For ADVCUSTNPADETAIL'
		print 'TEST'

--return
		PRINT 'Expire Data'
				UPDATE NPA SET
						NPA.EffectiveToTimeKey =@TimeKey -1 
					FROM AdvCustNPAdetail NPA
						INNER JOIN #TmpCustNPA T						
							ON NPA.CustomerEntityId=T.CustomerEntityId
							AND (NPA.EffectiveFromTimeKey<=@MocTimeKey AND NPA.EffectiveToTimeKey>=@MocTimeKey)
						WHERE NPA.EffectiveFromTimeKey<@MocTimeKey 


				DELETE NPA
				FROM AdvCustNPAdetail NPA
					INNER JOIN #TmpCustNPA T						
						ON NPA.CustomerEntityId=T.CustomerEntityId
						AND (NPA.EffectiveFromTimeKey<=@MocTimeKey AND NPA.EffectiveToTimeKey>=@MocTimeKey)
					WHERE NPA.EffectiveFromTimeKey=@MocTimeKey AND NPA.EffectiveToTimeKey>=@MocTimeKey


				PRINT CAST(@@ROWCOUNT AS VARCHAR(20))+'Row In Expire From ADVCUSTNPADETAIL'
						PRINT 'INSERT INTO PREMOC.NPA DETAIL '



	--select * from #TmpCustNPA
			INSERT INTO PreMoc.AdvCustNPADetail
						(
							CustomerEntityId     
							,Cust_AssetClassAlt_Key
							,NPADt                
							,LastInttChargedDt    
							,DbtDt                
							,LosDt                
							,DefaultReason1Alt_Key
							,DefaultReason2Alt_Key
							,StaffAccountability  
							,LastIntBooked        
							,RefCustomerID        
							,AuthorisationStatus  
							,EffectiveFromTimeKey 
							,EffectiveToTimeKey   
							,CreatedBy            
							,DateCreated          
							,ModifiedBy           
							,DateModified         
							,ApprovedBy           
							,DateApproved         						      
							,MocStatus            
							,MocDate              
							,MocTypeAlt_Key 
							----,WillfulDefault
							----,WillfulDefaultReasonAlt_Key
							----,WillfulRemark
							----,WillfulDefaultDate
							,NPA_Reason      
						)
				SELECT 
							npa.CustomerEntityId     
							,npa.Cust_AssetClassAlt_Key
							,npa.NPADt                
							,npa.LastInttChargedDt    
							,npa.DbtDt                
							,npa.LosDt                
							,npa.DefaultReason1Alt_Key
							,npa.DefaultReason2Alt_Key
							,npa.StaffAccountability  
							,npa.LastIntBooked        
							,npa.RefCustomerID        
							,npa.AuthorisationStatus  
							,@MocTimeKey EffectiveFromTimeKey 
							,@MocTimeKey EffectiveToTimeKey   
							,npa.CreatedBy            
							,npa.DateCreated          
							,npa.ModifiedBy           
							,npa.DateModified         
							,npa.ApprovedBy           
							,npa.DateApproved         						      
							,'Y' MocStatus            
							,GETDATE() MocDate              
							,210 MocTypeAlt_Key  
							----,NPA.WillfulDefault
							----,NPA.WillfulDefaultReasonAlt_Key
							----,NPA.WillfulRemark
							----,NPA.WillfulDefaultDate
							,NPA.NPA_Reason   
					FROM #TmpCustNPA NPA
						LEFT JOIN PreMoc.AdvCustNPADetail T				
							ON(T.EffectiveFromTimeKey<=@MocTimeKey AND T.EffectiveToTimeKey>=@MocTimeKey)
							AND T.CustomerEntityId=NPA.CustomerEntityId
					WHERE T.CustomerEntityId IS NULL

				PRINT CAST(@@ROWCOUNT AS VARCHAR(5))+' Row Inserted in Premoc.AdvCustNPADetail'

print 'TEST2'
			PRINT 'UPDATE RECORD FOR SAME TIME KEY'
				 UPDATE NPA SET
		       	 NPA.EffectiveToTimeKey =@MocTimeKey
						,NPA.EffectiveFromTimeKey =@MocTimeKey
						,Cust_AssetClassAlt_Key =  DM.AssetClassAlt_Key
						,NPADt= Convert(date,PostMoc_NPAdt,103)      
						--,DbtDt=   ISNULL(SD.PostMoc_DBtdt,DbtDt)
						,DbtDt = CASE WHEN PostMocAssetClassAlt_key = 6 THEN NULL ELSE ISNULL(SD.PostMoc_DBtdt,DbtDt) END
						,LosDt   =CASE WHEN PostMocAssetClassAlt_key = 6 THEN SD.PostMoc_DBtdt ELSE LosDt END
						--,CreatedBy=@CrModApBy
						--,DateCreated=GETDATE()
						,ModifiedBy=@CrModApBy
						,DateModified=getdate()
						,MocStatus= 'Y'               
						,MocDate= GetDate()                
						,MocTypeAlt_Key= 210    
				FROM AdvCustNPAdetail NPA
						INNER JOIN #Npadt	 SD						
								ON NPA.CustomerEntityId = SD.CustomerEntityId
								
						INNER JOIN DimAssetClass DM						
								ON (DM.EffectiveFromTimeKey<=@MocTimeKey AND DM.EffectiveToTimeKey>=@MocTimeKey)
								AND SD.PostMocAssetClassAlt_key=DM.AssetClassAlt_Key
								AND DM.AssetClassShortName<>'STD'      
						WHERE NPA.EffectiveFromTimeKey=@MocTimeKey AND NPA.EffectiveToTimeKey=@MocTimeKey
						
						PRINT CAST(@@ROWCOUNT AS VARCHAR(5))+' Row UPdate  IN AdvCustNPADetail'

						PRINT 'INSERT IN NPA FOR CURRENT TIME KEY'

						PRINT '11'

			INSERT INTO AdvCustNPADetail 
						(
							CustomerEntityId      
							,Cust_AssetClassAlt_Key
							,NPADt                 
							,LastInttChargedDt     
							,DbtDt                 
							,LosDt                 
							,DefaultReason1Alt_Key 
							,DefaultReason2Alt_Key 
							,StaffAccountability   
							,LastIntBooked         
							,RefCustomerID         
							,AuthorisationStatus   
							,EffectiveFromTimeKey  
							,EffectiveToTimeKey    
							,CreatedBy             
							,DateCreated           
							,ModifiedBy            
							,DateModified          
							,ApprovedBy            
							,DateApproved          
							--,D2Ktimestamp          
							,MocStatus             
							,MocDate               
							,MocTypeAlt_Key  
							----,WillfulDefault
							----,WillfulDefaultReasonAlt_Key
							----,WillfulRemark
							----,WillfulDefaultDate
							,NPA_Reason      
						)
				--declare @MocTimeKey int =4383						
					SELECT 
							NPA.CustomerEntityId      
							,DM.AssetClassAlt_Key
							,ISNULL(Convert(date,PostMoc_NPAdt,103),NPA.NPADt)     
							,NPA.LastInttChargedDt     
							--,ISNULL(SD.PostMoc_DBtdt,DbtDt)
							--,npa.LosDt
							, CASE WHEN PostMocAssetClassAlt_key = 6 THEN NULL ELSE ISNULL(SD.PostMoc_DBtdt,DbtDt) END
							, CASE WHEN PostMocAssetClassAlt_key = 6 THEN SD.PostMoc_DBtdt ELSE LosDt END
							,NPA.DefaultReason1Alt_Key 
							,NPA.DefaultReason2Alt_Key 
							,NPA.StaffAccountability   
							,NPA.LastIntBooked         
							,NPA.RefCustomerID         
							,NPA.AuthorisationStatus   
							,@MocTimeKey  EffectiveFromTimeKey  
							,@MocTimeKey  EffectiveToTimeKey    
							,@CrModApBy            
							,GETDATE()         
							,NPA.ModifiedBy            
							--,@CrModApBy
							,NPA.DateModified          
							,NPA.ApprovedBy            
							,NPA.DateApproved          
							--,NPA.D2Ktimestamp          
							,'Y'  MocStatus             
							,GetDate() MocDate               
							,210 MocTypeAlt_Key  
							----,NPA.WillfulDefault
							----,NPA.WillfulDefaultReasonAlt_Key
							----,NPA.WillfulRemark
							----,NPA.WillfulDefaultDate
							,NPA.NPA_Reason    
					FROM #TmpCustNPA NPA
						INNER JOIN  #Npadt SD						
								ON NPA.CustomerEntityId = SD.CustomerEntityId
								  
						INNER JOIN DimAssetClass DM						
								ON (DM.EffectiveFromTimeKey<=@MocTimeKey AND DM.EffectiveToTimeKey>=@MocTimeKey)
								AND SD.PostMocAssetClassAlt_key=DM.AssetClassAlt_Key 
								AND DM.AssetClassShortName<>'STD'     
						WHERE NOT(NPA.EffectiveFromTimeKey=@MocTimeKey AND NPA.EffectiveToTimeKey=@MocTimeKey)

					PRINT CAST(@@ROWCOUNT AS VARCHAR(5))+'INSERT IN NPA FOR CURRENT TIME KEY'
					PRINT '12'

		PRINT 'INSERT IN NPA FOR LIVE'
			INSERT INTO AdvCustNPADetail
					(
						CustomerEntityId     
						,Cust_AssetClassAlt_Key
						,NPADt                
						,LastInttChargedDt    
						,DbtDt                
						,LosDt                
						,DefaultReason1Alt_Key
						,DefaultReason2Alt_Key
						,StaffAccountability  
						,LastIntBooked        
						,RefCustomerID        
						,AuthorisationStatus  
						,EffectiveFromTimeKey 
						,EffectiveToTimeKey   
						,CreatedBy            
						,DateCreated          
						,ModifiedBy           
						,DateModified         
						,ApprovedBy           
						,DateApproved         
						--,D2Ktimestamp         
						,MocStatus            
						,MocDate              
						,MocTypeAlt_Key 
						----,WillfulDefault
						----,WillfulDefaultReasonAlt_Key
						----,WillfulRemark
						----,WillfulDefaultDate
						,NPA_Reason     
					)
				select 
									
					NPA.CustomerEntityId     
					,NPA.Cust_AssetClassAlt_Key
					,NPA.NPADt
					,NPA.LastInttChargedDt    
					,NPA.DbtDt                
					,NPA.LosDt                
					,NPA.DefaultReason1Alt_Key
					,NPA.DefaultReason2Alt_Key
					,NPA.StaffAccountability  
					,NPA.LastIntBooked        
					,NPA.RefCustomerID        
					,NPA.AuthorisationStatus  
					,@MocTimeKey+1  EffectiveFromTimeKey 
					,NPA.EffectiveToTimeKey   
					,NPA.CreatedBy            
					,NPA.DateCreated          
					,NPA.ModifiedBy           
					--,@CrModApBy
					,NPA.DateModified         
					,NPA.ApprovedBy           
					,NPA.DateApproved         
					--,NPA.D2Ktimestamp         
					,MocStatus            
					,MocDate              
					,MocTypeAlt_Key 
					----,NPA.WillfulDefault
					----,NPA.WillfulDefaultReasonAlt_Key
					----,NPA.WillfulRemark
					----,NPA.WillfulDefaultDate
					,NPA.NPA_Reason    
			FROM #TmpCustNPA NPA
				WHERE NPA.EffectiveToTimeKey>@MocTimeKey

			
			PRINT CAST(@@ROWCOUNT AS VARCHAR(5))+'INSERT IN NPA FOR LIVE'
			PRINT 'UPDATE SOURCE TABLE FOR NPA DETAIL'




			

			INSERT INTO AdvCustNPAdetail
					 (
					 CustomerEntityId
					,Cust_AssetClassAlt_Key
					,NPADt
					,LastInttChargedDt
					,DbtDt
					,LosDt
					,DefaultReason1Alt_Key
					,DefaultReason2Alt_Key
					,StaffAccountability
					,LastIntBooked
					,RefCustomerID
					,AuthorisationStatus
					,EffectiveFromTimeKey
					,EffectiveToTimeKey
					,CreatedBy
					,DateCreated
					,ModifiedBy
					,DateModified
					,ApprovedBy
					,DateApproved
					,MocStatus
					,MocDate
					,MocTypeAlt_Key
					--,WillfulDefault
					--,WillfulDefaultReasonAlt_Key
					--,WillfulRemark
					--,WillfulDefaultDate
					,NPA_Reason
					 )
					 select 
					 B.CustomerEntityId
					,C.AssetClassAlt_Key
					---,CONVERT(DATE, A.PostMoc_NPAdt,103)
					,A.PostMoc_NPAdt
					,NULL LastInttChargedDt
					,a.PostMoc_DBtdt DbtDt
					,LosDt
					,NULL DefaultReason1Alt_Key
					,NULL DefaultReason2Alt_Key
					,NULL StaffAccountability
					,NULL LastIntBooked
					,B.CustomerID
					,NULL AuthorisationStatus
					,@MocTimeKey EffectiveFromTimeKey
					,@MocTimeKey EffectiveToTimeKey
					,@CrModApBy CreatedBy
					, GETDATE() DateCreated
					,NULL ModifiedBy
					,NULL DateModified
					,NULL ApprovedBy
					,NULL DateApproved
					,'Y' MocStatus
					,GETDATE() MocDate
					,210 MocTypeAlt_Key
					----,NULL WillfulDefault
					----,NULL WillfulDefaultReasonAlt_Key
					----,NULL WillfulRemark
					----,NULL WillfulDefaultDate
					,NULL NPA_Reason
				 FROM #Npadt A  
				 INNER JOIN CustomerBasicDetail B ON A.CustomerEntityId=B.CustomerEntityId
					 AND B.EffectiveFromTimeKey<=@MocTimeKey AND B.EffectiveToTimeKey>=@MocTimeKey
					 INNER JOIN DimAssetClass C ON C.AssetClassAlt_Key=ISNULL(A.PostMocAssetClassAlt_key,'')
					 AND C.EffectiveFromTimeKey<=@MocTimeKey AND C.EffectiveToTimeKey>=@MocTimeKey
					 left outer join AdvCustNPAdetail d on D.CustomerEntitYID=b.CustomerEntitYID
							and (d.EffectiveFromTimeKey<=@MocTimeKey AND D.EFFECTIVETOTIMEKEY>=@MocTimeKey)
				WHERE ISNULL(A.PostMocAssetClassAlt_key,'')>1 --AND ISNULL(POSTMOCASSETCLASSIFICATION,'')<>'STD'
					and d.CustomerEntitYID is null

	
		/*	END MOC FOR ADVCUSTFINANCIALDETAIL*/



/*	START MOC FOR BALANCE DETAIL*/
		
			IF OBJECT_ID('Tempdb..#TmpAcBalance') IS NOT NULL
			DROP TABLE #TmpAcBalance
			
			SELECT AABD.* 
				INTO #TmpAcBalance
			FROM dbo.AdvAcBalanceDetail AABD
			 INNER JOIN AdvAcBasicDetail ABD
					ON ABD.EffectiveFromTimeKey<=@MocTimeKey AND ABD.EffectiveToTimeKey>=@MocTimeKey
					AND (AABD.EffectiveFromTimeKey<=@MocTimeKey AND AABD.EffectiveToTimeKey>=@MocTimeKey)
					AND AABD.AccountEntityId=ABD.AccountEntityId
				INNER JOIN #CUST_AC_MOC T
					ON (ABD.AccountEntityId=T.AccountEntityId)
					
				
				PRINT 'Expire data'

				UPDATE AABD SET
					AABD.EffectiveToTimeKey =@MocTimeKey -1 
				FROM dbo.AdvAcBalanceDetail AABD
					INNER JOIN #TmpAcBalance T						
						ON AABD.AccountEntityId=T.AccountEntityId
						AND (AABD.EffectiveFromTimeKey<=@MocTimeKey AND AABD.EffectiveToTimeKey>=@MocTimeKey)
					WHERE AABD.EffectiveFromTimeKey<@MocTimeKey
		
				DELETE AABD
				FROM dbo.AdvAcBalanceDetail AABD
					INNER JOIN #TmpAcBalance T						
						ON AABD.AccountEntityId=T.AccountEntityId
						AND (AABD.EffectiveFromTimeKey<=@MocTimeKey AND AABD.EffectiveToTimeKey>=@MocTimeKey)
					WHERE AABD.EffectiveFromTimeKey=@MocTimeKey AND AABD.EffectiveToTimeKey>=@MocTimeKey
		
		PRINT 'Insert data in Premoc.Balance '
	
				INSERT INTO PREMOC.AdvAcBalanceDetail
							(
							
								AccountEntityId
								,AssetClassAlt_Key
								,BalanceInCurrency
								,Balance
								,SignBalance
								,LastCrDt
								,OverDue
								,TotalProv
								----,DirectBalance
								----,InDirectBalance
								----,LastCrAmt
								,RefCustomerId
								,RefSystemAcId
								,AuthorisationStatus
								,EffectiveFromTimeKey
								,EffectiveToTimeKey
								,OverDueSinceDt
								,MocStatus
								,MocDate
								,MocTypeAlt_Key
								,Old_OverDueSinceDt
								,Old_OverDue
								,ORG_TotalProv
								,IntReverseAmt
								,PS_Balance
								,NPS_Balance
								,DateCreated
								,ModifiedBy
								,DateModified
								,ApprovedBy
								,DateApproved
								,CreatedBy
								----,PS_NPS_FLAG
								,OverduePrincipal
								,Overdueinterest
								,AdvanceRecovery
								,NotionalInttAmt
								,PrincipalBalance
							)

						SELECT
								 T.AccountEntityId
								,T.AssetClassAlt_Key
								,T.BalanceInCurrency
								,T.Balance
								,T.SignBalance
								,T.LastCrDt
								,T.OverDue
								,T.TotalProv
								----,T.DirectBalance
								----,T.InDirectBalance
								----,T.LastCrAmt
								,T.RefCustomerId
								,T.RefSystemAcId
								,T.AuthorisationStatus
								,@MocTimeKey EffectiveFromTimeKey
								,@MocTimeKey EffectiveToTimeKey
								,T.OverDueSinceDt
								,'Y' MocStatus            
								,GETDATE() MocDate   
								,T.MocTypeAlt_Key
								,T.Old_OverDueSinceDt
								,T.Old_OverDue
								,T.ORG_TotalProv
								,T.IntReverseAmt
								,T.PS_Balance
								,T.NPS_Balance
								,T.DateCreated
								,T.ModifiedBy
								,T.DateModified
								,T.ApprovedBy
								,T.DateApproved
								,T.CreatedBy
								----,T.PS_NPS_FLAG
								,T.OverduePrincipal
								,T.Overdueinterest
								,T.AdvanceRecovery
								,T.NotionalInttAmt
								,T.PrincipalBalance
					
						 FROM #TmpAcBalance T
						LEFT JOIN PreMoc.AdvAcBalanceDetail PRE
								ON (PRE.EffectiveFromTimeKey<=@MocTimeKey AND PRE.EffectiveToTimeKey>=@MocTimeKey)
								AND PRE.AccountEntityId=T.AccountEntityId --AND PRE.AccountEntityId IS NULL
							WHERE PRE.AccountEntityId IS NULL


					PRINT 'UPDATE RECORED FOR CURRENT TIME KEY'

					UPDATE AABD SET
						---- AABD.EffectiveFromTimeKey=@MocTimeKey
						----,AABD.EffectiveToTimeKey =@MocTimeKey
						ModifiedBy=@CrModApBy
						,DateModified=getdate()
						, MocStatus='Y'
						,MocDate=GetDate() 
						,MocTypeAlt_Key=210 
						,AABD.AssetClassAlt_Key=DM.AssetClassAlt_Key
						--,AABD.BalanceInCurrency=((ISNULL(AABD.Balance,0)+ISNULL(LoanProcessChg,0)	+ISNULL(ServiceTax,0)+ISNULL(InttSubvention,0)+ISNULL(OtherMocAmt,0)-ISNULL(InterestReversalChg,0))) 
						--,AABD.Balance=((ISNULL(AABD.Balance,0)+ISNULL(LoanProcessChg,0)	+ISNULL(ServiceTax,0)+ISNULL(InttSubvention,0) +ISNULL(OtherMocAmt,0)-ISNULL(InterestReversalChg,0)))
						,AABD.BalanceInCurrency=T.balance
						,AABD.Balance=T.balance
						--,AABD.PS_Balance=CASE WHEN  PS_NPS_FLAG ='PS' THEN ((ISNULL(AABD.Balance,0)+ISNULL(LoanProcessChg,0)	+ISNULL(ServiceTax,0)+ISNULL(InttSubvention,0)+ISNULL(OtherMocAmt,0)-ISNULL(InterestReversalChg,0))) ELSE AABD.PS_Balance END
						--,AABD.NPS_Balance= CASE WHEN  PS_NPS_FLAG ='NPS' THEN((ISNULL(AABD.Balance,0)+ISNULL(LoanProcessChg,0)	+ISNULL(ServiceTax,0)+ISNULL(InttSubvention,0)+ISNULL(OtherMocAmt,0)-ISNULL(InterestReversalChg,0))) ELSE AABD.NPS_Balance END
						----,AABD.PS_Balance=CASE WHEN  PS_NPS_FLAG ='PS' THEN ((ISNULL(T.Balance,0))) ELSE AABD.PS_Balance END
						----,AABD.NPS_Balance= CASE WHEN  PS_NPS_FLAG ='NPS' THEN((ISNULL(T.Balance,0))) ELSE AABD.NPS_Balance END
						,AABD.PS_Balance=CASE WHEN  PS_Balance >0 THEN ((ISNULL(T.Balance,0))) ELSE AABD.PS_Balance END
						,AABD.NPS_Balance= CASE WHEN  NPS_Balance>0 THEN((ISNULL(T.Balance,0))) ELSE AABD.NPS_Balance END
			
			----select 1
				 FROM dbo.AdvAcBalanceDetail AABD
					INNER JOIN #CUST_AC_MOC T						
						ON AABD.AccountEntityId=T.AccountEntityId
						AND (AABD.EffectiveFromTimeKey<=@MocTimeKey AND AABD.EffectiveToTimeKey>=@MocTimeKey)
					LEFT JOIN DimAssetClass DM 
						ON (DM.EffectiveFromTimeKey<=@MocTimeKey AND DM.EffectiveToTimeKey>=@MocTimeKey)
						AND T.MOCAssetClassification=DM.AssetClassShortNameEnum
					WHERE AABD.EffectiveFromTimeKey=@MocTimeKey AND AABD.EffectiveToTimeKey=@MocTimeKey
			
					PRINT 'Insert data for Current TimeKey'	 
			
				INSERT INTO AdvAcBalanceDetail
							(
								AccountEntityId
								,AssetClassAlt_Key
								,BalanceInCurrency
								,Balance
								,SignBalance
								,LastCrDt
								,OverDue
								,TotalProv
								----,DirectBalance
								----,InDirectBalance
								----,LastCrAmt
								,RefCustomerId
								,RefSystemAcId
								,AuthorisationStatus
								,EffectiveFromTimeKey
								,EffectiveToTimeKey
								,OverDueSinceDt
								,MocStatus
								,MocDate
								,MocTypeAlt_Key
								,Old_OverDueSinceDt
								,Old_OverDue
								,ORG_TotalProv
								,IntReverseAmt
								,PS_Balance
								,NPS_Balance
								,DateCreated
								,ModifiedBy
								,DateModified
								,ApprovedBy
								,DateApproved
								,CreatedBy
								----,PS_NPS_FLAG
								,OverduePrincipal
								,Overdueinterest
								,AdvanceRecovery
								,NotionalInttAmt
								,PrincipalBalance
							)
						SELECT 
								A.AccountEntityId
								,C.AssetClassAlt_Key
								--,CASE WHEN SD.AccountEntityId IS NULL THEN A.BalanceInCurrency ELSE ((ISNULL(A.Balance,0)+ISNULL(LoanProcessChg,0)	+ISNULL(ServiceTax,0)+ISNULL(InttSubvention,0)+ISNULL(OtherMocAmt,0)-ISNULL(InterestReversalChg,0)))  END
								--,CASE WHEN SD.AccountEntityId IS NULL THEN A.Balance ELSE ((ISNULL(A.Balance,0)+ISNULL(LoanProcessChg,0)	+ISNULL(ServiceTax,0)+ISNULL(InttSubvention,0)+ISNULL(OtherMocAmt,0)-ISNULL(InterestReversalChg,0)))  END
								,CASE WHEN SD.AccountEntityId IS NULL THEN A.BalanceInCurrency ELSE ((ISNULL(SD.Balance,0)))  END
								,CASE WHEN SD.AccountEntityId IS NULL THEN A.Balance ELSE ((ISNULL(SD.Balance,0)))  END
								,A.SignBalance
								,A.LastCrDt
								,A.OverDue
								,A.TotalProv
								----,A.DirectBalance
								----,A.InDirectBalance
								----,A.LastCrAmt
								,A.RefCustomerId
								,A.RefSystemAcId
								,A.AuthorisationStatus
								,@MocTimeKey AS EffectiveFromTimeKey
								,@MocTimeKey AS EffectiveToTimeKey
								,A.OverDueSinceDt
								,'Y' MocStatus
								,GETDATE() MocDate
								,210 MocTypeAlt_Key
								,A.Old_OverDueSinceDt
								,A.Old_OverDue
								,A.ORG_TotalProv
								,A.IntReverseAmt
								--,((ISNULL(A.Balance,0)+ISNULL(LoanProcessChg,0)	+ISNULL(ServiceTax,0)+ISNULL(InttSubvention,0)-ISNULL(InterestReversalChg,0))) 
								--,((ISNULL(A.Balance,0)+ISNULL(LoanProcessChg,0)	+ISNULL(ServiceTax,0)+ISNULL(InttSubvention,0)-ISNULL(InterestReversalChg,0)))
								----,CASE WHEN  A.PS_NPS_FLAG ='PS' THEN  ((ISNULL(SD.Balance,0)))	ELSE A.PS_Balance END PS_Balance
								----,CASE WHEN  A.PS_NPS_FLAG ='NPS' THEN   ((ISNULL(SD.Balance,0)))   ELSE  A.NPS_Balance END NPS_Balance
								,CASE WHEN  A.PS_Balance >0 THEN  ((ISNULL(SD.Balance,0)))	ELSE A.PS_Balance END PS_Balance
								,CASE WHEN  A.NPS_Balance>0 THEN   ((ISNULL(SD.Balance,0)))   ELSE  A.NPS_Balance END NPS_Balance
								,GETDATE() DateCreated
								,A.ModifiedBy
								,A.DateModified
								,A.ApprovedBy
								,A.DateApproved
								,@CrModApBy CreatedBy
								----,A.PS_NPS_FLAG
								,A.OverduePrincipal
								,A.Overdueinterest
								,A.AdvanceRecovery
								,A.NotionalInttAmt
								,A.PrincipalBalance
					FROM #TmpAcBalance A
						LEFT JOIN #CUST_AC_MOC SD
							ON A.AccountEntityId=SD.AccountEntityId
							--AND ISNULL((ISNULL(SD.PreMocBalance,0)+ISNULL(LoanProcessChg,0)	+ISNULL(ServiceTax,0)+ISNULL(InttSubvention,0)+ISNULL(OtherMocAmt,0)-ISNULL(InterestReversalChg,0)),0)<>0
								--AND  (CASE WHEN ISNULL(SD.PreMocBalance,0)>0  AND (ISNULL((ISNULL(SD.PreMocBalance,0)+ISNULL(LoanProcessChg,0)	+ISNULL(ServiceTax,0)+ISNULL(InttSubvention,0)+ISNULL(OtherMocAmt,0)-ISNULL(InterestReversalChg,0)),0)<>0)
								--						THEN 1
								--				 WHEN ISNULL(SD.PreMocBalance,0)=0 THEN 1		
								--			END)=1
								--AND SD

						LEFT JOIN DimAssetClass c on c.AssetClassShortNameEnum=sd.MOCAssetClassification
							AND c.EffectiveFromTimeKey<=@MocTimeKey and c.EffectiveToTimeKey>=@MocTimeKey 
							LEFT JOIN AdvAcBalanceDetail	 O
								ON A.AccountEntityId=O.AccountEntityId	
								 AND (o.EffectiveFromTimeKey=@MocTimeKey AND o.EffectiveToTimeKey=@MocTimeKey)												
					WHERE (A.EffectiveFromTimeKey<=@MocTimeKey AND A.EffectiveToTimeKey>=@MocTimeKey)
						--AND NOT (o.EffectiveFromTimeKey=@MocTimeKey AND o.EffectiveToTimeKey=@MocTimeKey)
							AND O.AccountEntityId IS NULL	
			
					PRINT 'Insert data for live TimeKey'
		
						INSERT INTO AdvAcBalanceDetail
									(
										AccountEntityId
										,AssetClassAlt_Key
										,BalanceInCurrency
										,Balance
										,SignBalance
										,LastCrDt
										,OverDue
										,TotalProv
										----,DirectBalance
										----,InDirectBalance
										----,LastCrAmt
										,RefCustomerId
										,RefSystemAcId
										,AuthorisationStatus
										,EffectiveFromTimeKey
										, EffectiveToTimeKey
										,OverDueSinceDt
										,MocStatus
										,MocDate
										,MocTypeAlt_Key
										,Old_OverDueSinceDt
										,Old_OverDue
										,ORG_TotalProv
										,IntReverseAmt
										,PS_Balance
										,NPS_Balance
										,DateCreated
										,ModifiedBy
										,DateModified
										,ApprovedBy
										,DateApproved
										,CreatedBy
										----,PS_NPS_FLAG
										,OverduePrincipal
										,Overdueinterest
										,AdvanceRecovery
										,NotionalInttAmt
										,PrincipalBalance
									)
												
								
												
								SELECT 
										 T.AccountEntityId
										,T.AssetClassAlt_Key
										,T.BalanceInCurrency
										,T.Balance
										,T.SignBalance
										,T.LastCrDt
										,T.OverDue
										,T.TotalProv
										----,T.DirectBalance
										----,T.InDirectBalance
										----,T.LastCrAmt
										,T.RefCustomerId
										,T.RefSystemAcId
										,T.AuthorisationStatus
										,@MocTimeKey+1
										,T.EffectiveToTimeKey
										,T.OverDueSinceDt
										,T.MocStatus
										,T.MocDate
										,T.MocTypeAlt_Key
										,T.Old_OverDueSinceDt
										,T.Old_OverDue
										,T.ORG_TotalProv
										,T.IntReverseAmt
										,T.PS_Balance
										,T.NPS_Balance
										,T.DateCreated
										,T.ModifiedBy
										,T.DateModified
										,T.ApprovedBy
										,T.DateApproved
										,T.CreatedBy
										----,T.PS_NPS_FLAG
										,T.OverduePrincipal
										,T.Overdueinterest
										,T.AdvanceRecovery
										,T.NotionalInttAmt
										,T.PrincipalBalance
							FROM #TmpAcBalance T
							WHERE T.EffectiveToTimeKey>@MocTimeKey

							UPDATE A
								SET A.EffectiveToTimeKey=@MocTimeKey-1
							FROM dbo.AdvAcBalanceDetail A
							 INNER JOIN DataUpload.MocAccountDataUpload  C
								ON C.AccountEntityId=A.AccountEntityId
							 WHERE ISNULL(C.AmountofWriteOff,0)>0		
								AND ((A.EffectiveFromTimeKey<=@MocTimeKey AND A.EffectiveToTimeKey>=@MocTimeKey)
									 OR a.EffectiveFromTimeKey>=@MocTimeKey
									)



			/*************************************************************************************************
				 FOR UPDATING A ASSET CLASS IN AdvAcBalance Detail
		*************************************************************************************************/						
		--DROP TABLE IF EXISTS #AssetClassBalance

	
		--SELECT ABD.CustomerEntityId
		--	, MAX(BAL.AssetClassAlt_Key)AssetClassAlt_Key
		--	INTO #AssetClassBalance
		--FROM AdvAcBalanceDetail BAL
		--INNER JOIN AdvAcBasicDetail ABD
		--	ON  ABD.EffectiveFromTimeKey <= @Timekey AND ABD.EffectiveToTimeKey >= @Timekey
		--	AND ABD.AccountEntityId = BAL.AccountEntityId
		--INNER JOIN #TmpCustNPA S
		--	ON  BAL.EffectiveFromTimeKey <= @Timekey AND BAL.EffectiveToTimeKey >= @Timekey
		--	AND S.CustomerEntityId = ABD.CustomerEntityId

		--GROUP BY ABD.CustomerEntityId
		
		UPDATE BAL
		SET AssetClassAlt_Key = A.Cust_AssetClassAlt_Key
		FROM dbo.AdvAcBalanceDetail BAL

		INNER JOIN AdvAcBasicDetail ABD
			ON  ABD.EffectiveFromTimeKey <= @MocTimeKey AND ABD.EffectiveToTimeKey >= @MocTimeKey
			AND BAL.EffectiveFromTimeKey = @MocTimeKey AND BAL.EffectiveToTimeKey = @MocTimeKey
			AND ABD.AccountEntityId = BAL.AccountEntityId

		INNER JOIN AdvCustNPAdetail  A
			ON A.CustomerEntityId = ABD.CustomerEntityId
			AND( A.EffectiveFromTimeKey = @MocTimeKey AND A.EffectiveToTimeKey = @MocTimeKey)
			

		UPDATE BAL
		SET TotalProv = A.TotalProvision
		FROM dbo.AdvAcBalanceDetail BAL

		INNER JOIN  [PRO].[AccountCal]  A
			ON A.AccountEntityId = bal.AccountEntityId
			AND( A.EffectiveFromTimeKey = @MocTimeKey AND A.EffectiveToTimeKey = @MocTimeKey)
			AND( BAL.EffectiveFromTimeKey = @MocTimeKey AND BAL.EffectiveToTimeKey = @MocTimeKey)


			UPDATE BAL
		SET AssetClassAlt_Key = A.FinalAssetClassAlt_Key
		FROM dbo.AdvAcBalanceDetail BAL
		INNER JOIN  [PRO].[AccountCal]  A
			ON A.AccountEntityId = bal.AccountEntityId
			AND( A.EffectiveFromTimeKey = @MocTimeKey AND A.EffectiveToTimeKey = @MocTimeKey)
			AND( BAL.EffectiveFromTimeKey = @MocTimeKey AND BAL.EffectiveToTimeKey = @MocTimeKey)

/********************************************/
/*	ADVACBASIC DETAIL*/		
--	IF OBJECT_ID('Tempdb..#AccountBasic') IS NOT NULL
--				DROP TABLE #AccountBasic	
			

--			SELECT abd.* ,T.SchemeAlt_Key SchemeAlt_Key_Moc
--				INTO #AccountBasic
--			FROM AdvAcBasicDetail abd
--				INNER JOIN (SELECT CustomerAcId,SchemeAlt_Key FROM dataupload.MocAccountDataUpload
--									WHERE  CustomerId IS NOT NULL	
--									AND ISNULL(SchemeAlt_Key,0)<>0																	
--								GROUP BY CustomerAcId,SchemeAlt_Key
--							) T
--					ON (abd.CustomerACID=T.CustomerACID)
--					AND (abd.EffectiveFromTimeKey<=@MocTimeKey AND abd.EffectiveToTimeKey>=@MocTimeKey)
--					--AND isnull(abd.SchemeAlt_Key,0)<>isnull(T.SchemeAlt_Key,0)
--					--and isnull(T.SchemeAlt_Key,0)<>0


--print 'TEST'

--return
--------	PRINT 'Expire Data'
--------			UPDATE abd SET
--------					abd.EffectiveToTimeKey =@MocTimeKey -1 
--------				FROM AdvAcBasicDetail abd
--------					 INNER JOIN #CUST_AC_MOC T
--------						ON abd.AccountEntityId=T.AccountEntityId
--------						AND (abd.EffectiveFromTimeKey<=@MocTimeKey AND abd.EffectiveToTimeKey>=@MocTimeKey)
--------					WHERE abd.EffectiveFromTimeKey<@MocTimeKey

--------			DELETE abd 
--------				FROM AdvAcBasicDetail abd
--------								  INNER JOIN #CUST_AC_MOC T
--------						ON abd.AccountEntityId=T.AccountEntityId
--------						AND (abd.EffectiveFromTimeKey<=@MocTimeKey AND abd.EffectiveToTimeKey>=@MocTimeKey)
--------					WHERE abd.EffectiveFromTimeKey=@MocTimeKey AND abd.EffectiveToTimeKey>=@MocTimeKey
					 
--------			INSERT INTO PreMoc.AdvAcBasicDetail
--------						(
						
--------							BranchCode
--------							,AccountEntityId
--------							,CustomerEntityId
--------							,SystemACID
--------							,CustomerACID
--------							,GLAlt_Key
--------							,ProductAlt_Key
--------							,GLProductAlt_Key
--------							,FacilityType
--------							,SectorAlt_Key
--------							,SubSectorAlt_Key
--------							,ActivityAlt_Key
--------							,IndustryAlt_Key
--------							,SchemeAlt_Key
--------							,DistrictAlt_Key
--------							,AreaAlt_Key
--------							,VillageAlt_Key
--------							,StateAlt_Key
--------							,CurrencyAlt_Key
--------							,OriginalSanctionAuthAlt_Key
--------							,OriginalLimitRefNo
--------							,OriginalLimit
--------							,OriginalLimitDt
--------							,DtofFirstDisb
--------							----,EmpCode
--------							,FlagReliefWavier
--------							,UnderLineActivityAlt_Key
--------							,MicroCredit
--------							,segmentcode
--------							,ScrCrError
--------							,AdjDt
--------							,AdjReasonAlt_Key
--------							,MarginType
--------							,Pref_InttRate
--------							,CurrentLimitRefNo
--------							----,ProcessingFeeApplicable
--------							----,ProcessingFeeAmt
--------							----,ProcessingFeeRecoveryAmt
--------							,GuaranteeCoverAlt_Key
--------							,AccountName
--------							----,ReferencePeriod
--------							,AssetClass
--------							----,D2K_REF_NO
--------							----,InttAppFreq
--------							,JointAccount
--------							,LastDisbDt
--------							,ScrCrErrorBackup
--------							,AccountOpenDate
--------							,Ac_LADDt
--------							,Ac_DocumentDt
--------							,CurrentLimit
--------							,InttTypeAlt_Key
--------							,InttRateLoadFactor
--------							,Margin
--------							----,TwentyPointReference
--------							----,BSR1bCode
--------							,CurrentLimitDt
--------							,Ac_DueDt
--------							,DrawingPowerAlt_Key
--------							,RefCustomerId
--------							----,D2KACID
--------							,AuthorisationStatus
--------							,EffectiveFromTimeKey
--------							,EffectiveToTimeKey
--------							,CreatedBy
--------							,DateCreated
--------							,ModifiedBy
--------							,DateModified
--------							,ApprovedBy
--------							,DateApproved							
--------							,MocStatus
--------							,MocDate
--------							,MocTypeAlt_Key
--------							--,AcCategegoryAlt_Key
--------							,OriginalSanctionAuthLevelAlt_Key
--------							,AcTypeAlt_Key
--------							,AcCategoryAlt_Key
--------							,ScrCrErrorSeq
--------							,SourceAlt_Key
--------							,LoanSeries
--------							,LoanRefNo
--------							,SecuritizationCode
--------							,Full_Disb
--------							,OriginalBranchcode
--------						)
--------				SELECT 
--------							abd.BranchCode
--------							,abd.AccountEntityId
--------							,abd.CustomerEntityId
--------							,abd.SystemACID
--------							,abd.CustomerACID
--------							,abd.GLAlt_Key
--------							,abd.ProductAlt_Key
--------							,abd.GLProductAlt_Key
--------							,abd.FacilityType
--------							,abd.SectorAlt_Key
--------							,abd.SubSectorAlt_Key
--------							,abd.ActivityAlt_Key
--------							,abd.IndustryAlt_Key
--------							,abd.SchemeAlt_Key
--------							,abd.DistrictAlt_Key
--------							,abd.AreaAlt_Key
--------							,abd.VillageAlt_Key
--------							,abd.StateAlt_Key
--------							,abd.CurrencyAlt_Key
--------							,abd.OriginalSanctionAuthAlt_Key
--------							,abd.OriginalLimitRefNo
--------							,abd.OriginalLimit
--------							,abd.OriginalLimitDt
--------							,abd.DtofFirstDisb
--------							----,abd.EmpCode
--------							,abd.FlagReliefWavier
--------							,abd.UnderLineActivityAlt_Key
--------							,abd.MicroCredit
--------							,abd.segmentcode
--------							,abd.ScrCrError
--------							,abd.AdjDt
--------							,abd.AdjReasonAlt_Key
--------							,abd.MarginType
--------							,abd.Pref_InttRate
--------							,abd.CurrentLimitRefNo
--------							----,abd.ProcessingFeeApplicable
--------							----,abd.ProcessingFeeAmt
--------							----,abd.ProcessingFeeRecoveryAmt
--------							,abd.GuaranteeCoverAlt_Key
--------							,abd.AccountName
--------							----,abd.ReferencePeriod
--------							,abd.AssetClass
--------							----,abd.D2K_REF_NO
--------							----,abd.InttAppFreq
--------							,abd.JointAccount
--------							,abd.LastDisbDt
--------							,abd.ScrCrErrorBackup
--------							,abd.AccountOpenDate
--------							,abd.Ac_LADDt
--------							,abd.Ac_DocumentDt
--------							,abd.CurrentLimit
--------							,abd.InttTypeAlt_Key
--------							,abd.InttRateLoadFactor
--------							,abd.Margin
--------							----,abd.TwentyPointReference
--------							----,abd.BSR1bCode
--------							,abd.CurrentLimitDt
--------							,abd.Ac_DueDt
--------							,abd.DrawingPowerAlt_Key
--------							,abd.RefCustomerId
--------							----,abd.D2KACID
--------							,abd.AuthorisationStatus
--------							,@MocTimeKey EffectiveFromTimeKey
--------							,@MocTimeKey EffectiveToTimeKey
--------							,abd.CreatedBy
--------							,abd.DateCreated
--------							,abd.ModifiedBy
--------							,abd.DateModified
--------							,abd.ApprovedBy
--------							,abd.DateApproved							
--------							,'Y' MocStatus            
--------							,GETDATE() MocDate   
--------							,abd.MocTypeAlt_Key
--------							--,abd.AcCategoryAlt_Key
--------							,abd.OriginalSanctionAuthLevelAlt_Key
--------							,abd.AcTypeAlt_Key
--------							,abd.AcCategoryAlt_Key
--------							,abd.ScrCrErrorSeq
--------							,abd.SourceAlt_Key
--------							,abd.LoanSeries
--------							,abd.LoanRefNo
--------							,ABD.SecuritizationCode
--------							,ABD.Full_Disb
--------							,ABD.OriginalBranchcode
--------					FROM AdvAcBasicDetail abd
--------						INNER JOIN #CUST_AC_MOC b
--------							on abd.AccountEntityId=b.AccountEntityid
--------							and abd.EffectiveFromTimeKey<=@MocTimeKey and abd.EffectiveToTimeKey>=@MocTimeKey
--------							and isnull(b.AmountofWriteOff,0)>0
--------						LEFT JOIN PreMoc.AdvAcBasicDetail T				
--------							ON(T.EffectiveFromTimeKey<=@MocTimeKey AND T.EffectiveToTimeKey>=@MocTimeKey)
--------							AND T.CustomerACID=abd.CustomerACID
--------					WHERE T.CustomerEntityId IS NULL

					
--------print 'TEST2111'
--------			PRINT 'UPDATE RECORD FOR SAME TIME KEY'
--------				 UPDATE abd SET
--------		       			abd.EffectiveToTimeKey =@MocTimeKey
--------						,abd.EffectiveFromTimeKey =@MocTimeKey												
--------						,MocStatus= 'Y'               
--------						,MocDate= GetDate()                
--------						,MocTypeAlt_Key= 210   
--------						,abd.SchemeAlt_Key=abd.SchemeAlt_Key--a.SchemeAlt_Key_Moc 
--------						,ModifiedBy=@CrModApBy
--------						,DateModified=getdate()
--------				FROM AdvAcBasicDetail abd
--------						INNER JOIN  #CUST_AC_MOC A
--------							ON (ABD.EffectiveFromTimeKey<=@MocTimeKey AND ABD.EffectiveToTimeKey>=@MocTimeKey)
--------							AND ABD.AccountEntityId = A.AccountEntityId																				   
--------						WHERE ABD.EffectiveFromTimeKey=@MocTimeKey AND ABD.EffectiveToTimeKey=@MocTimeKey



--------			PRINT 'INSERT IN ACCOUNT FOR CURRENT TIME KEY'

--------			INSERT INTO AdvAcBasicDetail 
--------						(
--------							BranchCode
--------							,AccountEntityId
--------							,CustomerEntityId
--------							,SystemACID
--------							,CustomerACID
--------							,GLAlt_Key
--------							,ProductAlt_Key
--------							,GLProductAlt_Key
--------							,FacilityType
--------							,SectorAlt_Key
--------							,SubSectorAlt_Key
--------							,ActivityAlt_Key
--------							,IndustryAlt_Key
--------							,SchemeAlt_Key
--------							,DistrictAlt_Key
--------							,AreaAlt_Key
--------							,VillageAlt_Key
--------							,StateAlt_Key
--------							,CurrencyAlt_Key
--------							,OriginalSanctionAuthAlt_Key
--------							,OriginalLimitRefNo
--------							,OriginalLimit
--------							,OriginalLimitDt
--------							,Pref_InttRate
--------							,CurrentLimitRefNo
--------							----,ProcessingFeeApplicable
--------							----,ProcessingFeeAmt
--------							----,ProcessingFeeRecoveryAmt
--------							,GuaranteeCoverAlt_Key
--------							,AccountName
--------							----,ReferencePeriod
--------							,AssetClass
--------							----,D2K_REF_NO
--------							----,InttAppFreq
--------							,JointAccount
--------							,LastDisbDt
--------							,ScrCrErrorBackup
--------							,AccountOpenDate
--------							,Ac_LADDt
--------							,Ac_DocumentDt
--------							,CurrentLimit
--------							,InttTypeAlt_Key
--------							,InttRateLoadFactor
--------							,Margin
--------							----,TwentyPointReference
--------							----,BSR1bCode
--------							,CurrentLimitDt
--------							,Ac_DueDt
--------							,DrawingPowerAlt_Key
--------							,RefCustomerId
--------							----,D2KACID
--------							,AuthorisationStatus
--------							,EffectiveFromTimeKey
--------							,EffectiveToTimeKey
--------							,CreatedBy
--------							,DateCreated
--------							,ModifiedBy
--------							,DateModified
--------							,ApprovedBy
--------							,DateApproved							
--------							,MocStatus
--------							,MocDate
--------							,MocTypeAlt_Key
--------							,IsLAD
--------							,FacilitiesNo
--------							,FincaleBasedIndustryAlt_key
--------							,AcCategoryAlt_Key
--------							,OriginalSanctionAuthLevelAlt_Key
--------							,AcTypeAlt_Key
--------							,ScrCrErrorSeq
--------							,D2k_OLDAscromID
--------							,BSRUNID
--------							,AdditionalProv
--------							,ProjectCost
--------							,DtofFirstDisb
--------							----,EmpCode
--------							,FlagReliefWavier
--------							,UnderLineActivityAlt_Key
--------							,MicroCredit
--------							,segmentcode
--------							,ScrCrError
--------							,AdjDt
--------							,AdjReasonAlt_Key
--------							,MarginType
--------							,AclattestDevelopment
--------							,SourceAlt_Key
--------							,LoanSeries
--------							,LoanRefNo
--------							,SecuritizationCode
--------							,Full_Disb
--------							,OriginalBranchcode
--------						)
--------					--declare @MocTimeKey int =4383						
--------					SELECT 
--------							BranchCode
--------							,AccountEntityId
--------							,CustomerEntityId
--------							,SystemACID
--------							,abd.CustomerACID
--------							,GLAlt_Key
--------							,ProductAlt_Key
--------							,GLProductAlt_Key
--------							,FacilityType
--------							,SectorAlt_Key
--------							,SubSectorAlt_Key
--------							,ActivityAlt_Key
--------							,IndustryAlt_Key
--------							,ABD.SchemeAlt_Key_Moc
--------							,DistrictAlt_Key
--------							,AreaAlt_Key
--------							,VillageAlt_Key
--------							,StateAlt_Key
--------							,CurrencyAlt_Key
--------							,OriginalSanctionAuthAlt_Key
--------							,OriginalLimitRefNo
--------							,OriginalLimit
--------							,OriginalLimitDt
--------							,Pref_InttRate
--------							,CurrentLimitRefNo
--------							----,ProcessingFeeApplicable
--------							----,ProcessingFeeAmt
--------							----,ProcessingFeeRecoveryAmt
--------							,GuaranteeCoverAlt_Key
--------							,AccountName
--------							----,ReferencePeriod
--------							,AssetClass
--------							----,D2K_REF_NO
--------							----,InttAppFreq
--------							,JointAccount
--------							,LastDisbDt
--------							,ScrCrErrorBackup
--------							,AccountOpenDate
--------							,Ac_LADDt
--------							,Ac_DocumentDt
--------							,CurrentLimit
--------							,InttTypeAlt_Key
--------							,InttRateLoadFactor
--------							,Margin
--------							----,TwentyPointReference
--------							----,BSR1bCode
--------							,CurrentLimitDt
--------							,Ac_DueDt
--------							,DrawingPowerAlt_Key
--------							,RefCustomerId
--------							----,D2KACID
--------							,AuthorisationStatus
--------							,@MocTimeKey EffectiveFromTimeKey
--------							,@MocTimeKey EffectiveToTimeKey
--------							,@CrModApBy CreatedBy
--------							,GETDATE() DateCreated
--------							,ModifiedBy
--------							,DateModified
--------							,ApprovedBy
--------							,DateApproved							
--------							,'Y' MocStatus
--------							,GETDATE() MocDate
--------							,210 MocTypeAlt_Key
--------							,IsLAD
--------							,FacilitiesNo
--------							,FincaleBasedIndustryAlt_key
--------							,AcCategoryAlt_Key
--------							,OriginalSanctionAuthLevelAlt_Key
--------							,AcTypeAlt_Key
--------							,ScrCrErrorSeq
--------							,D2k_OLDAscromID
--------							,BSRUNID
--------							,AdditionalProv
--------							,ProjectCost
--------							,DtofFirstDisb
--------							----,EmpCode
--------							,FlagReliefWavier
--------							,UnderLineActivityAlt_Key
--------							,MicroCredit
--------							,segmentcode
--------							,ScrCrError
--------							,AdjDt
--------							,AdjReasonAlt_Key
--------							,MarginType
--------							,AclattestDevelopment
--------							,SourceAlt_Key
--------							,LoanSeries
--------							,LoanRefNo
--------							,SecuritizationCode
--------							,Full_Disb
--------							,OriginalBranchcode
--------					FROM #CUST_AC_MOC abd
--------						where (ABD.EffectiveFromTimeKey<=@MocTimeKey AND ABD.EffectiveToTimeKey>=@MocTimeKey)
--------						and NOT(EffectiveFromTimeKey=@MocTimeKey AND EffectiveToTimeKey=@MocTimeKey)
					


--------		PRINT 'INSERT IN ACCOUNT FOR LIVE'
--------				INSERT INTO AdvAcBasicDetail 
--------						(
--------							BranchCode
--------							,AccountEntityId
--------							,CustomerEntityId
--------							,SystemACID
--------							,CustomerACID
--------							,GLAlt_Key
--------							,ProductAlt_Key
--------							,GLProductAlt_Key
--------							,FacilityType
--------							,SectorAlt_Key
--------							,SubSectorAlt_Key
--------							,ActivityAlt_Key
--------							,IndustryAlt_Key
--------							,SchemeAlt_Key
--------							,DistrictAlt_Key
--------							,AreaAlt_Key
--------							,VillageAlt_Key
--------							,StateAlt_Key
--------							,CurrencyAlt_Key
--------							,OriginalSanctionAuthAlt_Key
--------							,OriginalLimitRefNo
--------							,OriginalLimit
--------							,OriginalLimitDt
--------							,Pref_InttRate
--------							,CurrentLimitRefNo
--------							----,ProcessingFeeApplicable
--------							----,ProcessingFeeAmt
--------							----,ProcessingFeeRecoveryAmt
--------							,GuaranteeCoverAlt_Key
--------							,AccountName
--------							----,ReferencePeriod
--------							,AssetClass
--------							----,D2K_REF_NO
--------							----,InttAppFreq
--------							,JointAccount
--------							,LastDisbDt
--------							,ScrCrErrorBackup
--------							,AccountOpenDate
--------							,Ac_LADDt
--------							,Ac_DocumentDt
--------							,CurrentLimit
--------							,InttTypeAlt_Key
--------							,InttRateLoadFactor
--------							,Margin
--------							----,TwentyPointReference
--------							----,BSR1bCode
--------							,CurrentLimitDt
--------							,Ac_DueDt
--------							,DrawingPowerAlt_Key
--------							,RefCustomerId
--------							----,D2KACID
--------							,AuthorisationStatus
--------							,EffectiveFromTimeKey
--------							,EffectiveToTimeKey
--------							,CreatedBy
--------							,DateCreated
--------							,ModifiedBy
--------							,DateModified
--------							,ApprovedBy
--------							,DateApproved							
--------							,MocStatus
--------							,MocDate
--------							,MocTypeAlt_Key
--------							,IsLAD
--------							,FacilitiesNo
--------							,FincaleBasedIndustryAlt_key
--------							,AcCategoryAlt_Key
--------							,OriginalSanctionAuthLevelAlt_Key
--------							,AcTypeAlt_Key
--------							,ScrCrErrorSeq
--------							,D2k_OLDAscromID
--------							,BSRUNID
--------							,AdditionalProv
--------							,ProjectCost
--------							,DtofFirstDisb
--------							----,EmpCode
--------							,FlagReliefWavier
--------							,UnderLineActivityAlt_Key
--------							,MicroCredit
--------							,segmentcode
--------							,ScrCrError
--------							,AdjDt
--------							,AdjReasonAlt_Key
--------							,MarginType
--------							,AclattestDevelopment
--------							,SourceAlt_Key
--------							,LoanSeries
--------							,LoanRefNo
--------							,SecuritizationCode
--------							,Full_Disb
--------							,OriginalBranchcode
--------						)
--------				--declare @MocTimeKey int =4383						
--------					SELECT 
--------							BranchCode
--------							,AccountEntityId
--------							,CustomerEntityId
--------							,SystemACID
--------							,CustomerACID
--------							,GLAlt_Key
--------							,ProductAlt_Key
--------							,GLProductAlt_Key
--------							,FacilityType
--------							,SectorAlt_Key
--------							,SubSectorAlt_Key
--------							,ActivityAlt_Key
--------							,IndustryAlt_Key
--------							,SchemeAlt_Key
--------							,DistrictAlt_Key
--------							,AreaAlt_Key
--------							,VillageAlt_Key
--------							,StateAlt_Key
--------							,CurrencyAlt_Key
--------							,OriginalSanctionAuthAlt_Key
--------							,OriginalLimitRefNo
--------							,OriginalLimit
--------							,OriginalLimitDt
--------							,Pref_InttRate
--------							,CurrentLimitRefNo
--------							----,ProcessingFeeApplicable
--------							----,ProcessingFeeAmt
--------							----,ProcessingFeeRecoveryAmt
--------							,GuaranteeCoverAlt_Key
--------							,AccountName
--------							----,ReferencePeriod
--------							,AssetClass
--------							----,D2K_REF_NO
--------							----,InttAppFreq
--------							,JointAccount
--------							,LastDisbDt
--------							,ScrCrErrorBackup
--------							,AccountOpenDate
--------							,Ac_LADDt
--------							,Ac_DocumentDt
--------							,CurrentLimit
--------							,InttTypeAlt_Key
--------							,InttRateLoadFactor
--------							,Margin
--------							----,TwentyPointReference
--------							----,BSR1bCode
--------							,CurrentLimitDt
--------							,Ac_DueDt
--------							,DrawingPowerAlt_Key
--------							,RefCustomerId
--------							----,D2KACID
--------							,AuthorisationStatus
--------							,@MocTimeKey+1 EffectiveFromTimeKey
--------							,EffectiveToTimeKey
--------							,CreatedBy
--------							,DateCreated
--------							,ModifiedBy
--------							,DateModified
--------							,ApprovedBy
--------							,DateApproved							
--------							,MocStatus
--------							,MocDate
--------							,MocTypeAlt_Key
--------							,IsLAD
--------							,FacilitiesNo
--------							,FincaleBasedIndustryAlt_key
--------							,AcCategoryAlt_Key
--------							,OriginalSanctionAuthLevelAlt_Key
--------							,AcTypeAlt_Key
--------							,ScrCrErrorSeq
--------							,D2k_OLDAscromID
--------							,BSRUNID
--------							,AdditionalProv
--------							,ProjectCost
--------							,DtofFirstDisb
--------							----,EmpCode
--------							,FlagReliefWavier
--------							,UnderLineActivityAlt_Key
--------							,MicroCredit
--------							,segmentcode
--------							,ScrCrError
--------							,AdjDt
--------							,AdjReasonAlt_Key
--------							,MarginType
--------							,AclattestDevelopment
--------							,SourceAlt_Key
--------							,LoanSeries
--------							,LoanRefNo
--------							,SecuritizationCode
--------							,Full_Disb
--------							,OriginalBranchcode
--------					FROM #CUST_AC_MOC
--------				WHERE EffectiveToTimeKey>@MocTimeKey


--------				UPDATE A
--------					SET A.EffectiveToTimeKey=@MocTimeKey-1
--------				FROM ADVACBASICDETAIL A
--------					INNER JOIN DataUpload.MocAccountDataUpload C
--------						ON C.AccountEntityId=a.AccountEntityId
--------					WHERE ISNULL(C.AmountofWriteOff,0)>0		
--------						AND ((A.EffectiveFromTimeKey<=@MocTimeKey AND A.EffectiveToTimeKey>=@MocTimeKey)
--------								OR (a.EffectiveFromTimeKey>=@MocTimeKey)
--------							)

/* CUSTOMERBASIC DETAIL*/		
/*		
 IF OBJECT_ID('Tempdb..#CustomerBasic') IS NOT NULL
				DROP TABLE #CustomerBasic	
			

			SELECT cbd.* 
				INTO #CustomerBasic
			FROM CustomerBasicDetail cbd
				INNER JOIN (SELECT CustomerId,ConstitutionAlt_Key FROM sample_data
									WHERE  CustomerId IS NOT NULL
									AND  (ISNULL(ConstitutionAlt_Key,0)<>0)																		
								GROUP BY CustomerId,ConstitutionAlt_Key
							) T
					ON (cbd.CustomerId=T.CustomerId)
					AND (cbd.EffectiveFromTimeKey<=@MocTimeKey AND cbd.EffectiveToTimeKey>=@MocTimeKey)
					AND ISNULL(CBD.ConstitutionAlt_Key,0)<>ISNULL(T.ConstitutionAlt_Key,0)
					and ISNULL(T.ConstitutionAlt_Key,0)<>0


print 'TEST'

--return
	PRINT 'Expire Data'
			UPDATE CBD SET
					CBD.EffectiveToTimeKey =@MocTimeKey -1 
				FROM CustomerBasicDetail CBD
					--INNER JOIN sample_data T		--COMMENTED BY HAMID ON 24 NOV 2018				
					 INNER JOIN #CustomerBasic T
						ON CBD.CustomerId=T.CustomerId
						AND (CBD.EffectiveFromTimeKey<=@MocTimeKey AND CBD.EffectiveToTimeKey>=@MocTimeKey)
					WHERE CBD.EffectiveFromTimeKey<@MocTimeKey

			DELETE CBD 
				FROM CustomerBasicDetail CBD
					--INNER JOIN sample_data T		--COMMENTED BY HAMID ON 24 NOV 2018				
					 INNER JOIN #CustomerBasic T
						ON CBD.CustomerId=T.CustomerId
						AND (CBD.EffectiveFromTimeKey<=@MocTimeKey AND CBD.EffectiveToTimeKey>=@MocTimeKey)
					WHERE  CBD.EffectiveFromTimeKey=@MocTimeKey AND CBD.EffectiveToTimeKey>=@MocTimeKey
							

--select * from #CustomerBasic
			INSERT INTO PreMoc.CustomerBasicDetail
					(
					CustomerEntityId
					,CustomerId
					,D2kCustomerid
					,ParentBranchCode
					,CustomerName
					,CustomerInitial
					,CustomerSinceDt
					,ConsentObtained
					,ConstitutionAlt_Key
					,OccupationAlt_Key
					,ReligionAlt_Key
					,CasteAlt_Key
					,FarmerCatAlt_Key
					,GaurdianSalutationAlt_Key
					,GaurdianName
					,GuardianType
					,CustSalutationAlt_Key
					,MaritalStatusAlt_Key
					,DegUpgFlag
					,ProcessingFlag
					,MOCLock
					,MoveNpaDt
					,AssetClass
					,BIITransactionCode
					,D2K_REF_NO
					,CustomerNameBackup
					,ScrCrErrorBackup
					,ScrCrError
					,ReferenceAcNo
					,CustCRM_RatingAlt_Key
					,CustCRM_RatingDt
					,AuthorisationStatus
					,EffectiveFromTimeKey
					,EffectiveToTimeKey
					,CreatedBy
					,DateCreated
					,ModifiedBy
					,DateModified
					,ApprovedBy
					,DateApproved					
					,FLAG
					,MocStatus
					,MocDate
					,BaselProcessing
					,MocTypeAlt_Key
					,CommonMocTypeAlt_Key
					,LandHolding
					,ScrCrErrorSeq
					,CustType
					,ServProviderAlt_Key
					,NonCustTypeAlt_Key
					,Remark
					)
				select
					cbd.CustomerEntityId
					,cbd.CustomerId
					,cbd.D2kCustomerid
					,cbd.ParentBranchCode
					,cbd.CustomerName
					,cbd.CustomerInitial
					,cbd.CustomerSinceDt
					,cbd.ConsentObtained
					,cbd.ConstitutionAlt_Key
					,cbd.OccupationAlt_Key
					,cbd.ReligionAlt_Key
					,cbd.CasteAlt_Key
					,cbd.FarmerCatAlt_Key
					,cbd.GaurdianSalutationAlt_Key
					,cbd.GaurdianName
					,cbd.GuardianType
					,cbd.CustSalutationAlt_Key
					,cbd.MaritalStatusAlt_Key
					,cbd.DegUpgFlag
					,cbd.ProcessingFlag
					,cbd.MOCLock
					,cbd.MoveNpaDt
					,cbd.AssetClass
					,cbd.BIITransactionCode
					,cbd.D2K_REF_NO
					,cbd.CustomerNameBackup
					,cbd.ScrCrErrorBackup
					,cbd.ScrCrError
					,cbd.ReferenceAcNo
					,cbd.CustCRM_RatingAlt_Key
					,cbd.CustCRM_RatingDt
					,cbd.AuthorisationStatus
					,@MocTimeKey EffectiveFromTimeKey
					,@MocTimeKey EffectiveToTimeKey
					,@CrModApBy CreatedBy
					,GETDATE() DateCreated
					,cbd.ModifiedBy
					,cbd.DateModified
					,cbd.ApprovedBy
					,cbd.DateApproved					
					,cbd.FLAG
					,'Y' MocStatus            
					,GETDATE() MocDate   
					,cbd.BaselProcessing
					,cbd.MocTypeAlt_Key
					,cbd.CommonMocTypeAlt_Key
					,cbd.LandHolding
					,cbd.ScrCrErrorSeq
					,cbd.CustType
					,cbd.ServProviderAlt_Key
					,cbd.NonCustTypeAlt_Key
					,cbd.Remark
					FROM #CustomerBasic CBD
						LEFT JOIN PreMoc.CustomerBasicDetail T				
							ON(T.EffectiveFromTimeKey<=@MocTimeKey AND T.EffectiveToTimeKey>=@MocTimeKey)
							AND T.CustomerId=CBD.CustomerId
					WHERE T.CustomerEntityId IS NULL

print 'TEST2'
			PRINT 'UPDATE RECORD FOR SAME TIME KEY'
				 UPDATE CBD SET
		       			CBD.EffectiveToTimeKey =@MocTimeKey
						,CBD.EffectiveFromTimeKey =@MocTimeKey												
						,MocStatus= 'Y'               
						,MocDate= GetDate()                
						,MocTypeAlt_Key= 210   
						,CBD.ConstitutionAlt_Key=SD.ConstitutionAlt_Key 
						,ModifiedBy=@CrModApBy
						,DateModified=getdate()
				FROM CustomerBasicDetail CBD
						INNER JOIN 
								(SELECT CustomerId,ConstitutionAlt_Key FROM sample_data
										WHERE ISNULL(ConstitutionAlt_Key,0)<>0
										GROUP BY CustomerId,ConstitutionAlt_Key
									)SD							
								ON CBD.CustomerId = SD.CustomerId																				   
						WHERE (CBD.EffectiveFromTimeKey=@MocTimeKey AND CBD.EffectiveToTimeKey=@MocTimeKey)


						PRINT 'INSERT IN CustomerBasicDetail FOR CURRENT TIME KEY'
			INSERT INTO CustomerBasicDetail 
						(
							CustomerEntityId
							,CustomerId
							,D2kCustomerid
							,ParentBranchCode
							,CustomerName
							,CustomerInitial
							,CustomerSinceDt
							,ConsentObtained
							,ConstitutionAlt_Key
							,OccupationAlt_Key
							,ReligionAlt_Key
							,CasteAlt_Key
							,FarmerCatAlt_Key
							,GaurdianSalutationAlt_Key
							,GaurdianName
							,GuardianType
							,CustSalutationAlt_Key
							,MaritalStatusAlt_Key
							,DegUpgFlag
							,ProcessingFlag
							,MOCLock
							,MoveNpaDt
							,AssetClass
							,BIITransactionCode
							,D2K_REF_NO
							,CustomerNameBackup
							,ScrCrErrorBackup
							,ScrCrError
							,ReferenceAcNo
							,CustCRM_RatingAlt_Key
							,CustCRM_RatingDt
							,AuthorisationStatus
							,EffectiveFromTimeKey
							,EffectiveToTimeKey
							,CreatedBy
							,DateCreated
							,ModifiedBy
							,DateModified
							,ApprovedBy
							,DateApproved							
							,FLAG
							,MocStatus
							,MocDate
							,BaselProcessing
							,MocTypeAlt_Key
							,CommonMocTypeAlt_Key
							,LandHolding
							,ScrCrErrorSeq
							,CustType
							,ServProviderAlt_Key
							,NonCustTypeAlt_Key
							,Remark
						)
				--declare @MocTimeKey int =4383						
					SELECT 
							CustomerEntityId
							,SD.CustomerId
							,D2kCustomerid
							,ParentBranchCode
							,CustomerName
							,CustomerInitial
							,CustomerSinceDt
							,ConsentObtained
							,SD.ConstitutionAlt_Key
							,OccupationAlt_Key
							,ReligionAlt_Key
							,CasteAlt_Key
							,FarmerCatAlt_Key
							,GaurdianSalutationAlt_Key
							,GaurdianName
							,GuardianType
							,CustSalutationAlt_Key
							,MaritalStatusAlt_Key
							,DegUpgFlag
							,ProcessingFlag
							,MOCLock
							,MoveNpaDt
							,AssetClass
							,BIITransactionCode
							,D2K_REF_NO
							,CustomerNameBackup
							,ScrCrErrorBackup
							,ScrCrError
							,ReferenceAcNo
							,CustCRM_RatingAlt_Key
							,CustCRM_RatingDt
							,AuthorisationStatus
							,@MocTimeKey EffectiveFromTimeKey
							,@MocTimeKey EffectiveToTimeKey
							,@CrModApBy CreatedBy
							,GETDATE() DateCreated
							,ModifiedBy
							,DateModified
							,ApprovedBy
							,DateApproved							
							,FLAG
							,'Y' MocStatus
							,GETDATE() MocDate
							,BaselProcessing
							,210 MocTypeAlt_Key
							,CommonMocTypeAlt_Key
							,LandHolding
							,ScrCrErrorSeq
							,CustType
							,ServProviderAlt_Key
							,NonCustTypeAlt_Key
							,Remark  
					FROM #CustomerBasic CBD
						INNER JOIN  
								(SELECT CustomerId,ConstitutionAlt_Key FROM sample_data
												WHERE ISNULL(ConstitutionAlt_Key,0)<>0
												GROUP BY CustomerId,ConstitutionAlt_Key
								)SD						
								ON CBD.CustomerId = SD.CustomerId								  						  
						WHERE NOT(CBD.EffectiveFromTimeKey=@MocTimeKey AND CBD.EffectiveToTimeKey=@MocTimeKey)
					


		PRINT 'INSERT IN CustomerBasicDetail FOR LIVE'
			INSERT INTO CustomerBasicDetail 
						(
							CustomerEntityId
							,CustomerId
							,D2kCustomerid
							,ParentBranchCode
							,CustomerName
							,CustomerInitial
							,CustomerSinceDt
							,ConsentObtained
							,ConstitutionAlt_Key
							,OccupationAlt_Key
							,ReligionAlt_Key
							,CasteAlt_Key
							,FarmerCatAlt_Key
							,GaurdianSalutationAlt_Key
							,GaurdianName
							,GuardianType
							,CustSalutationAlt_Key
							,MaritalStatusAlt_Key
							,DegUpgFlag
							,ProcessingFlag
							,MOCLock
							,MoveNpaDt
							,AssetClass
							,BIITransactionCode
							,D2K_REF_NO
							,CustomerNameBackup
							,ScrCrErrorBackup
							,ScrCrError
							,ReferenceAcNo
							,CustCRM_RatingAlt_Key
							,CustCRM_RatingDt
							,AuthorisationStatus
							,EffectiveFromTimeKey
							,EffectiveToTimeKey
							,CreatedBy
							,DateCreated
							,ModifiedBy
							,DateModified
							,ApprovedBy
							,DateApproved							
							,FLAG
							,MocStatus
							,MocDate
							,BaselProcessing
							,MocTypeAlt_Key
							,CommonMocTypeAlt_Key
							,LandHolding
							,ScrCrErrorSeq
							,CustType
							,ServProviderAlt_Key
							,NonCustTypeAlt_Key
							,Remark
						)
				--declare @MocTimeKey int =4383						
					SELECT 
							CustomerEntityId
							,CBD.CustomerId
							,D2kCustomerid
							,ParentBranchCode
							,CustomerName
							,CustomerInitial
							,CustomerSinceDt
							,ConsentObtained
							,CBD.ConstitutionAlt_Key
							,OccupationAlt_Key
							,ReligionAlt_Key
							,CasteAlt_Key
							,FarmerCatAlt_Key
							,GaurdianSalutationAlt_Key
							,GaurdianName
							,GuardianType
							,CustSalutationAlt_Key
							,MaritalStatusAlt_Key
							,DegUpgFlag
							,ProcessingFlag
							,MOCLock
							,MoveNpaDt
							,AssetClass
							,BIITransactionCode
							,D2K_REF_NO
							,CustomerNameBackup
							,ScrCrErrorBackup
							,ScrCrError
							,ReferenceAcNo
							,CustCRM_RatingAlt_Key
							,CustCRM_RatingDt
							,AuthorisationStatus
							,@MocTimeKey+1 EffectiveFromTimeKey
							,EffectiveToTimeKey
							,CreatedBy
							,DateCreated
							,ModifiedBy
							,DateModified
							,ApprovedBy
							,DateApproved							
							,FLAG
							,MocStatus
							,MocDate
							,BaselProcessing
							,MocTypeAlt_Key
							,CommonMocTypeAlt_Key
							,LandHolding
							,ScrCrErrorSeq
							,CustType
							,ServProviderAlt_Key
							,NonCustTypeAlt_Key
							,Remark  
					FROM #CustomerBasic CBD
				WHERE CBD.EffectiveToTimeKey>@MocTimeKey

*/

/*   ADVCUSTFINANCIAL DETAIL */


DROP TABLE IF EXISTS #TempCustBalance_New
SELECT	  ABD.CustomerEntityId 
		, ABD.BranchCode
		, SUM(ISNULL(BAL.Balance,0))Balance
		, MAX(BAL.AssetClassAlt_Key) AssetClassAlt_Key
INTO #TempCustBalance_New
FROM dbo.AdvAcBalanceDetail BAL WITH(NOLOCK) 
--INNER JOIN Sample_Data S
--	ON BAL.EffectiveFromTimeKey = @MocTimeKey AND BAL.EffectiveToTimeKey = @MocTimeKey
--	AND S.AccountEntityId = BAL.AccountEntityId
INNER JOIN AdvAcBasicDetail  ABD
	ON ABD.EffectiveFromTimeKey <= @MocTimeKey AND ABD.EffectiveToTimeKey >= @MocTimeKey
	AND BAL.EffectiveFromTimeKey = @MocTimeKey AND BAL.EffectiveToTimeKey = @MocTimeKey
	AND ABD.AccountEntityId = BAL.AccountEntityId
GROUP BY ABD.CustomerEntityId, ABD.BranchCode


DROP TABLE IF EXISTS #AdvCustFinancialDetail_ORG
SELECT F.* INTO #AdvCustFinancialDetail_ORG
FROM AdvCustFinancialDetail  F
INNER JOIN #TempCustBalance_New N
	ON F.EffectiveFromTimeKey <= @MocTimeKey AND EffectiveToTimeKey >= @MocTimeKey
	AND N.CustomerEntityId = F.CustomerEntityId
	AND N.BranchCode = F.BranchCode

			UPDATE ACFD SET
					ACFD.EffectiveToTimeKey =@MocTimeKey -1 
				FROM AdvCustFinancialDetail ACFD
					INNER JOIN #TempCustBalance_New T						
						ON ACFD.CustomerEntityId=T.CustomerEntityId
						AND ACFD.BranchCode = T.BranchCode
						AND (ACFD.EffectiveFromTimeKey<=@MocTimeKey AND ACFD.EffectiveToTimeKey>=@MocTimeKey)
					WHERE ACFD.EffectiveFromTimeKey<@MocTimeKey
		
				
				DELETE ACFD
				FROM AdvCustFinancialDetail ACFD
					INNER JOIN #TempCustBalance_New T						
						ON ACFD.CustomerEntityId=T.CustomerEntityId
						AND ACFD.BranchCode = T.BranchCode
						AND (ACFD.EffectiveFromTimeKey<=@MocTimeKey AND ACFD.EffectiveToTimeKey>=@MocTimeKey)
					WHERE ACFD.EffectiveFromTimeKey=@MocTimeKey AND ACFD.EffectiveToTimeKey>=@MocTimeKey
		

				INSERT INTO PREMOC.AdvCustFinancialDetail
							(
							
								CustomerEntityId
								,BranchCode
								,TotLimitFunded
								,TotLimitNF
								,TotOsFunded
								,TotOsNF
								,TotOverDue
								,TotCadu
								,TotCad
								,Cust_AssetClassAlt_Key
								,TotProvision
								,TotAdditionalProvision
								,TotGenericAddlProvision
								,TotUnappliedInt
								,EntityClosureDate
								,EntityClosureReasonAlt_Key
								,Old_Cust_AssetClassAlt_Key
								,RefCustomerId
								,AuthorisationStatus
								,EffectiveFromTimeKey
								,EffectiveToTimeKey
								,CreatedBy
								,DateCreated
								,ModifiedBy
								,DateModified
								,ApprovedBy
								,DateApproved
								,MocStatus
								,MocDate
								,MocTypeAlt_Key
							)

						SELECT
								 T.CustomerEntityId
								,T.BranchCode
								,T.TotLimitFunded
								,T.TotLimitNF
								,T.TotOsFunded
								,T.TotOsNF
								,T.TotOverDue
								,T.TotCadu
								,T.TotCad
								,T.Cust_AssetClassAlt_Key
								,T.TotProvision
								,T.TotAdditionalProvision
								,T.TotGenericAddlProvision
								,T.TotUnappliedInt
								,T.EntityClosureDate
								,T.EntityClosureReasonAlt_Key
								,T.Old_Cust_AssetClassAlt_Key
								,T.RefCustomerId
								,T.AuthorisationStatus
								,@MocTimeKey EffectiveFromTimeKey
								,@MocTimeKey EffectiveToTimeKey
								,T.CreatedBy
								,T.DateCreated
								,T.ModifiedBy
								,T.DateModified
								,T.ApprovedBy
								,T.DateApproved
								,'Y' MocStatus            
								,GETDATE() MocDate   
								,T.MocTypeAlt_Key
					
						 FROM #AdvCustFinancialDetail_ORG T
						 INNER JOIN #TempCustBalance_New N
							ON T.EffectiveFromTimeKey <= @MocTimeKey AND T.EffectiveToTimeKey >= @MocTimeKey
							AND T.CustomerEntityId = N.CustomerEntityId
							AND T.BranchCode = N.BranchCode
						LEFT JOIN PreMoc.AdvCustFinancialDetail PRE
								ON (PRE.EffectiveFromTimeKey<=@MocTimeKey AND PRE.EffectiveToTimeKey>=@MocTimeKey)
								AND PRE.CustomerEntityId=T.CustomerEntityId
								AND PRE.BranchCode = T.BranchCode
							WHERE PRE.CustomerEntityId IS NULL

		PRINT 'UPDATE RECORED FOR CURRENT TIME KEY'

					UPDATE ACFD SET
						 ACFD.EffectiveFromTimeKey=@MocTimeKey
						,ACFD.EffectiveToTimeKey =@MocTimeKey
						,CreatedBy=@CrModApBy
						,ModifiedBy=@CrModApBy
						,DateModified=getdate()
						,MocDate=GetDate() 
						,MocTypeAlt_Key=210 
						,ACFD.Cust_AssetClassAlt_Key=T.AssetClassAlt_Key
						,ACFD.TotOsFunded=T.Balance
			
			
				 FROM AdvCustFinancialDetail ACFD
					INNER JOIN #TempCustBalance_New T						
						ON ACFD.CustomerEntityId=T.CustomerEntityId
						AND ACFD.BranchCode = T.BranchCode
						AND (ACFD.EffectiveFromTimeKey<=@MocTimeKey AND ACFD.EffectiveToTimeKey>=@MocTimeKey)
					WHERE ACFD.EffectiveFromTimeKey=@MocTimeKey AND ACFD.EffectiveToTimeKey=@MocTimeKey		
		 

		PRINT 'Insert data for Current TimeKey'	 
			
							INSERT INTO AdvCustFinancialDetail
										(
											CustomerEntityId
											,BranchCode
											,TotLimitFunded
											,TotLimitNF
											,TotOsFunded
											,TotOsNF
											,TotOverDue
											,TotCadu
											,TotCad
											,Cust_AssetClassAlt_Key
											,TotProvision
											,TotAdditionalProvision
											,TotGenericAddlProvision
											,TotUnappliedInt
											,EntityClosureDate
											,EntityClosureReasonAlt_Key
											,Old_Cust_AssetClassAlt_Key
											,RefCustomerId
											,AuthorisationStatus
											,EffectiveFromTimeKey
											,EffectiveToTimeKey
											,CreatedBy
											,DateCreated
											,ModifiedBy
											,DateModified
											,ApprovedBy
											,DateApproved
											,MocStatus
											,MocDate
											,MocTypeAlt_Key
										)
													
									
															
									SELECT 

									         A.CustomerEntityId
											,A.BranchCode
											,TotLimitFunded
											,TotLimitNF
											,ISNULL(A.Balance,0) TotOsFunded
											,TotOsNF
											,TotOverDue
											,TotCadu
											,TotCad
											,A.AssetClassAlt_Key Cust_AssetClassAlt_Key
											,TotProvision
											,TotAdditionalProvision
											,TotGenericAddlProvision
											,TotUnappliedInt
											,EntityClosureDate
											,EntityClosureReasonAlt_Key
											,O.Cust_AssetClassAlt_Key
											,RefCustomerId
											,AuthorisationStatus
											,@MocTimeKey EffectiveFromTimeKey
											,@MocTimeKey EffectiveToTimeKey
											,CreatedBy
											,DateCreated
											,ModifiedBy
											,DateModified
											,ApprovedBy
											,DateApproved
											,'Y' MocStatus            
											,GETDATE() MocDate   
											,MocTypeAlt_Key
								FROM #TempCustBalance_New A
									 LEFT JOIN  AdvCustFinancialDetail O
									ON A.CustomerEntityId = O.CustomerEntityId
									AND A.BranchCode = O.BranchCode
									AND (O.EffectiveFromTimeKey=@MocTimeKey AND O.EffectiveToTimeKey=@MocTimeKey)
								WHERE O.CustomerEntityId IS NULL


PRINT 'Insert data for live TimeKey'
		
						INSERT INTO AdvCustFinancialDetail
									(
										CustomerEntityId
											,BranchCode
											,TotLimitFunded
											,TotLimitNF
											,TotOsFunded
											,TotOsNF
											,TotOverDue
											,TotCadu
											,TotCad
											,Cust_AssetClassAlt_Key
											,TotProvision
											,TotAdditionalProvision
											,TotGenericAddlProvision
											,TotUnappliedInt
											,EntityClosureDate
											,EntityClosureReasonAlt_Key
											,Old_Cust_AssetClassAlt_Key
											,RefCustomerId
											,AuthorisationStatus
											,EffectiveFromTimeKey
											,EffectiveToTimeKey
											,CreatedBy
											,DateCreated
											,ModifiedBy
											,DateModified
											,ApprovedBy
											,DateApproved
											,MocStatus
											,MocDate
											,MocTypeAlt_Key
									)
												
								
												
								SELECT 
										   T.CustomerEntityId
											,T.BranchCode
											,ISNULL(T.TotLimitFunded,0)
											,TotLimitNF
											,TotOsFunded
											,TotOsNF
											,TotOverDue
											,TotCadu
											,TotCad
											,Cust_AssetClassAlt_Key
											,TotProvision
											,TotAdditionalProvision
											,TotGenericAddlProvision
											,TotUnappliedInt
											,EntityClosureDate
											,EntityClosureReasonAlt_Key
											,T.Cust_AssetClassAlt_Key
											,RefCustomerId
											,AuthorisationStatus
											,@MocTimeKey +1 EffectiveFromTimeKey
											,EffectiveToTimeKey
											,CreatedBy
											,DateCreated
											,ModifiedBy
											,DateModified
											,ApprovedBy
											,DateApproved
											,MocStatus
											,MocDate
											,MocTypeAlt_Key
							FROM #AdvCustFinancialDetail_ORG T
							WHERE T.EffectiveToTimeKey>@MocTimeKey			

	PRINT 'EXcelUpload_SecurityValueDetail finish'

/****************************************************/
/*	ADVACFINANCIALDETAIL TABLE	*/
	
	DROP TABLE IF EXISTS #AdvAcFinancialDetail_ORG
	SELECT F.*
	INTO #AdvAcFinancialDetail_ORG
	FROM AdvAcFinancialDetail F
	INNER JOIN AdvAcBasicDetail B
			ON (F.EffectiveFromTimeKey<=@MocTimeKey AND F.EffectiveToTimeKey>=@MocTimeKey)
			AND (B.EffectiveFromTimeKey<=@MocTimeKey AND B.EffectiveToTimeKey>=@MocTimeKey)
			AND F.AccountEntityId=B.AccountEntityId
	INNER JOIN (SELECT CustomerEntityID,MIN(cast(ISNULL(NPADATE,'1900-01-01') aS DATE)) PostMoc_NPAdt 
				from  #CUST_AC_MOC
				 GROUP BY CustomerEntityID) C
			ON C.CustomerEntityID=B.CustomerEntityID			
		--AND F.AccountEntityId = S.AccountEntityId
		WHERE ISNULL(F.NpaDt,'1900-01-01') <> PostMoc_NPAdt 


	DROP TABLE IF EXISTS #AdvAcFinancialDetail_New
	SELECT O.AccountEntityId, ISNULL(S.PostMoc_NPAdt,'1900-01-01')NpaDt
		INTO #AdvAcFinancialDetail_New
	FROM #AdvAcFinancialDetail_ORG O
	INNER JOIN AdvAcBasicDetail B
			ON (O.EffectiveFromTimeKey<=@MocTimeKey AND O.EffectiveToTimeKey>=@MocTimeKey)
			AND (B.EffectiveFromTimeKey<=@MocTimeKey AND B.EffectiveToTimeKey>=@MocTimeKey)
			AND O.AccountEntityId=B.AccountEntityId	
		INNER JOIN (SELECT CustomerEntityID,MIN(cast(ISNULL(NPADATE,'1900-01-01') aS DATE)) PostMoc_NPAdt 
				from  #CUST_AC_MOC S
				 GROUP BY CustomerEntityID)  S
			ON S.CustomerEntityID = B.CustomerEntityID

		UPDATE ACFD SET
					ACFD.EffectiveToTimeKey =@MocTimeKey -1 
				FROM AdvAcFinancialDetail ACFD
					INNER JOIN #AdvAcFinancialDetail_New T						
						ON ACFD.AccountEntityId=T.AccountEntityId
						
						AND (ACFD.EffectiveFromTimeKey<=@MocTimeKey AND ACFD.EffectiveToTimeKey>=@MocTimeKey)
					WHERE ACFD.EffectiveFromTimeKey<@MocTimeKey


			DELETE ACFD 
					FROM AdvAcFinancialDetail ACFD
						INNER JOIN #AdvAcFinancialDetail_New T						
							ON ACFD.AccountEntityId=T.AccountEntityId
							AND (ACFD.EffectiveFromTimeKey<=@MocTimeKey AND ACFD.EffectiveToTimeKey>=@MocTimeKey)
						WHERE ACFD.EffectiveFromTimeKey=@MocTimeKey AND ACFD.EffectiveToTimeKey>=@MocTimeKey

			INSERT INTO PREMOC.AdvAcFinancialDetail
							(
								 AccountEntityId
								,Ac_LastReviewDueDt
								,Ac_ReviewTypeAlt_key
								,Ac_ReviewDt
								,Ac_ReviewAuthAlt_Key
								,Ac_NextReviewDueDt
								,DrawingPower
								,InttRate
								----,IrregularType
								----,IrregularityDt
								,NpaDt
								,BookDebts
								,UnDrawnAmt
								----,TotalDI
								----,UnAppliedIntt
								----,LegalExp
								,UnAdjSubSidy
								,LastInttRealiseDt
								,MocStatus
								,MOCReason
								----,WriteOffAmt_HO
								----,InterestRateCodeAlt_Key
								----,WriteOffDt
								----,OD_Dt
								,LimitDisbursed
								----,WriteOffAmt_BR
								,RefCustomerId
								,RefSystemAcId
								,AuthorisationStatus
								,EffectiveFromTimeKey
								,EffectiveToTimeKey
								,CreatedBy
								,DateCreated
								,ModifiedBy
								,DateModified
								,ApprovedBy
								,DateApproved
								
								,MocDate
								,MocTypeAlt_Key
								,CropDuration
								,Ac_ReviewAuthLevelAlt_Key
							)

						SELECT
								 T.AccountEntityId
								,T.Ac_LastReviewDueDt
								,T.Ac_ReviewTypeAlt_key
								,T.Ac_ReviewDt
								,T.Ac_ReviewAuthAlt_Key
								,T.Ac_NextReviewDueDt
								,T.DrawingPower
								,T.InttRate
								----,T.IrregularType
								----,T.IrregularityDt
								,T.NpaDt
								,T.BookDebts
								,T.UnDrawnAmt
								----,T.TotalDI
								----,T.UnAppliedIntt
								----,T.LegalExp
								,T.UnAdjSubSidy
								,T.LastInttRealiseDt
								,'Y' MocStatus
								,T.MOCReason
								----,T.WriteOffAmt_HO
								----,T.InterestRateCodeAlt_Key
								----,T.WriteOffDt
								----,T.OD_Dt
								,T.LimitDisbursed
								----,T.WriteOffAmt_BR
								,T.RefCustomerId
								,T.RefSystemAcId
								,T.AuthorisationStatus
								,@MocTimeKey EffectiveFromTimeKey
								,@MocTimeKey EffectiveToTimeKey
								,T.CreatedBy
								,T.DateCreated
								,T.ModifiedBy
								,T.DateModified
								,T.ApprovedBy
								,T.DateApproved
								,GETDATE() MocDate
								,T.MocTypeAlt_Key
								,T.CropDuration
								,T.Ac_ReviewAuthLevelAlt_Key
					
						 FROM #AdvAcFinancialDetail_ORG T
						 INNER JOIN #AdvAcFinancialDetail_New N
							ON T.EffectiveFromTimeKey <= @MocTimeKey AND T.EffectiveToTimeKey >= @MocTimeKey
							AND T.AccountEntityId = N.AccountEntityId
							LEFT JOIN PREMOC.AdvAcFinancialDetail PRE
								ON (PRE.EffectiveFromTimeKey<=@MocTimeKey AND PRE.EffectiveToTimeKey>=@MocTimeKey)
								AND PRE.AccountEntityId=T.AccountEntityId

							WHERE PRE.AccountEntityId IS NULL

PRINT 'UPDATE RECORED FOR CURRENT TIME KEY'

					UPDATE ACFD SET
						 ACFD.EffectiveFromTimeKey=@MocTimeKey
						,ACFD.EffectiveToTimeKey =@MocTimeKey
						,ModifiedBy=@CrModApBy
						,DateModified=getdate()
						, MocStatus='Y'
						,MocDate=GetDate() 
						,MocTypeAlt_Key=210 
						,ACFD.NpaDt=T.NpaDt
			
				 FROM AdvAcFinancialDetail ACFD
					INNER JOIN #AdvAcFinancialDetail_New T						
						ON ACFD.AccountEntityId = T.AccountEntityId
						AND (ACFD.EffectiveFromTimeKey<=@MocTimeKey AND ACFD.EffectiveToTimeKey>=@MocTimeKey)
					WHERE ACFD.EffectiveFromTimeKey=@MocTimeKey AND ACFD.EffectiveToTimeKey=@MocTimeKey		
		 

		PRINT 'Insert data for Current TimeKey'	 
			
							INSERT INTO AdvAcFinancialDetail
										(
											AccountEntityId
											,Ac_LastReviewDueDt
											,Ac_ReviewTypeAlt_key
											,Ac_ReviewDt
											,Ac_ReviewAuthAlt_Key
											,Ac_NextReviewDueDt
											,DrawingPower
											,InttRate
											----,IrregularType
											----,IrregularityDt
											,NpaDt
											,BookDebts
											,UnDrawnAmt
											----,TotalDI
											----,UnAppliedIntt
											----,LegalExp
											,UnAdjSubSidy
											,LastInttRealiseDt
											,MocStatus
											,MOCReason
											----,WriteOffAmt_HO
											----,InterestRateCodeAlt_Key
											----,WriteOffDt
											----,OD_Dt
											,LimitDisbursed
											----,WriteOffAmt_BR
											,RefCustomerId
											,RefSystemAcId
											,AuthorisationStatus
											,EffectiveFromTimeKey
											,EffectiveToTimeKey
											,CreatedBy
											,DateCreated
											,ModifiedBy
											,DateModified
											,ApprovedBy
											,DateApproved
											,MocDate
											,MocTypeAlt_Key
											,CropDuration
											,Ac_ReviewAuthLevelAlt_Key
										)
													
									
															
									SELECT	 A.AccountEntityId
											,Ac_LastReviewDueDt
											,Ac_ReviewTypeAlt_key
											,Ac_ReviewDt
											,Ac_ReviewAuthAlt_Key
											,Ac_NextReviewDueDt
											,DrawingPower
											,InttRate
											----,IrregularType
											----,IrregularityDt
											,A.NpaDt
											,BookDebts
											,UnDrawnAmt
											----,TotalDI
											----,UnAppliedIntt
											----,LegalExp
											,UnAdjSubSidy
											,LastInttRealiseDt
											,'Y' MocStatus
											,MOCReason
											----,WriteOffAmt_HO
											----,InterestRateCodeAlt_Key
											----,WriteOffDt
											----,OD_Dt
											,LimitDisbursed
											----,WriteOffAmt_BR
											,RefCustomerId
											,RefSystemAcId
											,AuthorisationStatus
											,@MocTimeKey	EffectiveFromTimeKey
											,@MocTimeKey	EffectiveToTimeKey
											,CreatedBy
											,DateCreated
											,ModifiedBy
											,DateModified
											,ApprovedBy
											,DateApproved
											,GETDATE() MocDate
											,MocTypeAlt_Key
											,CropDuration
											,Ac_ReviewAuthLevelAlt_Key
									FROM #AdvAcFinancialDetail_New A
										LEFT JOIN AdvAcFinancialDetail O
											ON A.AccountEntityId = O.AccountEntityId
											and (O.EffectiveFromTimeKey=@MocTimeKey AND O.EffectiveToTimeKey=@MocTimeKey)
								WHERE o.AccountEntityId IS NULL


						PRINT 'Insert data for live TimeKey'
		
						INSERT INTO AdvAcFinancialDetail
									(
										AccountEntityId
											,Ac_LastReviewDueDt
											,Ac_ReviewTypeAlt_key
											,Ac_ReviewDt
											,Ac_ReviewAuthAlt_Key
											,Ac_NextReviewDueDt
											,DrawingPower
											,InttRate
											----,IrregularType
											----,IrregularityDt
											,NpaDt
											,BookDebts
											,UnDrawnAmt
											----,TotalDI
											----,UnAppliedIntt
											----,LegalExp
											,UnAdjSubSidy
											,LastInttRealiseDt
											,MocStatus
											,MOCReason
											----,WriteOffAmt_HO
											----,InterestRateCodeAlt_Key
											----,WriteOffDt
											----,OD_Dt
											,LimitDisbursed
											----,WriteOffAmt_BR
											,RefCustomerId
											,RefSystemAcId
											,AuthorisationStatus
											,EffectiveFromTimeKey
											,EffectiveToTimeKey
											,CreatedBy
											,DateCreated
											,ModifiedBy
											,DateModified
											,ApprovedBy
											,DateApproved
											,MocDate
											,MocTypeAlt_Key
											,CropDuration
											,Ac_ReviewAuthLevelAlt_Key
									)
												
								
												
								SELECT 
										   AccountEntityId
											,Ac_LastReviewDueDt
											,Ac_ReviewTypeAlt_key
											,Ac_ReviewDt
											,Ac_ReviewAuthAlt_Key
											,Ac_NextReviewDueDt
											,DrawingPower
											,InttRate
											--,IrregularType
											----,IrregularityDt
											,NpaDt
											,BookDebts
											,UnDrawnAmt
											----,TotalDI
											----,UnAppliedIntt
											----,LegalExp
											,UnAdjSubSidy
											,LastInttRealiseDt
											,MocStatus
											,MOCReason
											----,WriteOffAmt_HO
											----,InterestRateCodeAlt_Key
											----,WriteOffDt
											----,OD_Dt
											,LimitDisbursed
											----,WriteOffAmt_BR
											,RefCustomerId
											,RefSystemAcId
											,AuthorisationStatus
											,@MocTimeKey +1  EffectiveFromTimeKey
											,EffectiveToTimeKey
											,CreatedBy
											,DateCreated
											,ModifiedBy
											,DateModified
											,ApprovedBy
											,DateApproved
											,MocDate
											,MocTypeAlt_Key
											,CropDuration
											,Ac_ReviewAuthLevelAlt_Key
							FROM #AdvAcFinancialDetail_ORG T
							WHERE T.EffectiveToTimeKey>@MocTimeKey	

							UPDATE A
								SET A.EffectiveToTimeKey=@MocTimeKey-1
							FROM AdvAcFinancialDetail A
							 INNER JOIN DataUpload.MocAccountDataUpload C
								ON C.AccountEntityId=A.AccountEntityId
							 WHERE ISNULL(C.AmountofWriteOff,0)>0		
								AND ((A.EffectiveFromTimeKey<=@MocTimeKey AND A.EffectiveToTimeKey>=@MocTimeKey)
									 OR a.EffectiveFromTimeKey>=@MocTimeKey
									)

			SET @Result=1
				
				COMMIT TRAN
				Return @Result
END TRY 

BEGIN CATCH
	ROLLBACK TRAN
	SELECT ERROR_LINE(),ERROR_MESSAGE()
	SET @Result=-1
	RETURN @Result
END CATCH
		        












GO