SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[SECURITY_ALL_SOURCE_SYSTEM_INSERT_UPDATE]
AS
BEGIN
		SET DATEFORMAT DMY
		DECLARE @TimeKey INT = (SELECT TimeKey FROM SysDatamatrix WHERE CurrentStatus='C')
		DECLARE @EXT_DT date = (SELECT DATE FROM IBL_ENPA_DB_V2..SYSDATAMATRIX WHERE TIMEKEY=@TimeKey)
		DECLARE @Exec_Date DATE=(SELECT DATE FROM IBL_ENPA_DB_V2..SysDataMatrix WHERE CurrentStatus='C' )
		DECLARE @MaxSecID int=ISNULL((SELECT MAX(SecurityEntityID) FROM IBL_ENPA_DB.[CURDAT].AdvSecurityDetail),0) 
		DECLARE @SECURITY int=(SELECT isnull(COUNT(1),0) FROM IBL_ENPA_DB_V2.CURDAT.AdvSecurityValueDetail)
		DECLARE @MonthEndDate DATE=(SELECT EOMONTH(DATEADD(MONTH,-1,@Exec_Date)))
		
		
		
		/*INSERTING DATA IN AdvSecurityDetail FROM SECURITY_ALL_SOURCE_SYSTEM*/
		
		INSERT INTO IBL_ENPA_DB_V2.[CURDAT].AdvSecurityDetail
		(SecurityEntityID,CollateralType,SrcSystemAlt_Key,RefCustomer_CIF,RefCustomerId,RefSystemAcId,
		 CollateralID,EffectiveFromTimeKey,EffectiveToTimeKey,CreatedBy,DateCreated,COLL_DELINK_DATE)
		
		SELECT 0,SEC.Collateral_Type,A.SourceAlt_Key,SEC.SRC_CIF,SEC.CustomerID,SEC.AccountID,SEC.CollateralID,@TimeKey,@TimeKey,'SSIS USER',GETDATE(),SEC.COLL_DELINK_DATE
		FROM IBL_ENPA_STGDB_V2.[dbo].Security_All_Source_System SEC
		INNER JOIN IBL_ENPA_DB_V2.DBO.DimSourceDB A ON SEC.SourceSystem=A.SourceShortNameEnum
		LEFT JOIN IBL_ENPA_DB.[CURDAT].AdvSecurityDetail ASD ON  --ASD.EffectiveFromTimeKey<=@TimeKey
		                                                      --AND ASD.EffectiveToTimeKey>=@TimeKey
															  --AND SEC.AS_ON_DATE=@EXT_DT AND 
															  ASD.SrcSystemAlt_Key=A.SourceAlt_Key
		                                                      AND SEC.CollateralID=ASD.CollateralID
		                                                      AND ISNULL(SEC.CustomerID,'')=ISNULL(ASD.RefCustomer_CIF,'')
															  AND SEC.SRC_CIF=ASD.RefCustomerId
															  AND  SEC.AccountID=ASD.RefSystemAcId
		WHERE ASD.CollateralID IS NULL
		GROUP BY Collateral_Type,A.SourceAlt_Key,CustomerID,SRC_CIF,AccountID,SEC.CollateralID,SEC.COLL_DELINK_DATE
		
		/*END OF DATA INSERTING IN AdvSecurityDetail FROM SECURITY_ALL_SOURCE_SYSTEM*/
		
		/*INSERTING DATA IN AdvSecurityValueDetail FROM SECURITY_ALL_SOURCE_SYSTEM*/
		
		INSERT INTO IBL_ENPA_DB_V2.[CURDAT].AdvSecurityValueDetail(
		SecurityEntityID,Prev_ValuationDate,Prev_Value,ValuationDate,CurrentValue,ValuationExpiryDate,EffectiveFromTimeKey,EffectiveToTimeKey,CreatedBy,DateCreated)
		SELECT A.SecurityEntityID,NULL,NULL,SEC.COLL_VAL_DATE,SEC.COLL_AMT,SEC.COLL_EXPRY_DATE,@TimeKey,@TimeKey,'SSI USER',GETDATE()
		FROM 
		(SELECT SEC.COLL_ID,SEC.COLL_AMT,STG.Valuationdate COLL_VAL_DATE,STG.ValuationExpiryDate COLL_EXPRY_DATE
		 FROM 
		(SELECT COLL_ID,MIN(COLL_AMT) COLL_AMT
		 FROM IBL_ENPA_STGDB_V2.dbo.Finacle_Stg_Security
		 WHERE AS_ON_DATE=@EXT_DT
		 GROUP BY AS_ON_DATE/*,ACC_NO*/,COLL_ID) SEC
		 INNER JOIN IBL_ENPA_STGDB_V2.[dbo].Security_All_Source_System STG ON SEC.COLL_ID=STG.CollateralID
															  AND ISNULL(SEC.COLL_AMT,0)=ISNULL(STG.SecurityValue,0)
															  AND STG.DateofData=@EXT_DT
		GROUP BY SEC.COLL_ID,SEC.COLL_AMT,STG.Valuationdate,STG.ValuationExpiryDate) SEC
		INNER JOIN 
		(SELECT ASD.SecurityEntityID,ASD.CollateralID
		FROM IBL_ENPA_DB_V2.[CURDAT].AdvSecurityDetail ASD 
		LEFT JOIN  IBL_ENPA_DB_V2.[CURDAT].AdvSecurityValueDetail ASVD  ON ASVD.EffectiveFromTimeKey<=@TimeKey
																		AND ASVD.EffectiveToTimeKey>=@TimeKey 
															         /*AND ASD.EffectiveFromTimeKey<=@TimeKey
		                                                               AND ASD.EffectiveToTimeKey>=@TimeKey
																	   AND ASD.SrcSystemAlt_Key=@SrcSysAlt_Key*/
		                                                               AND ASVD.SecurityEntityID=ASD.SecurityEntityID
		WHERE ASVD.SecurityEntityID IS NULL
		--AND ASD.EffectiveFromTimeKey<=@TimeKey
		--AND ASD.EffectiveToTimeKey>=@TimeKey
		--AND ASD.SrcSystemAlt_Key=@SrcSysAlt_Key
		GROUP BY ASD.SecurityEntityID,ASD.CollateralID) A ON SEC.COLL_ID=A.CollateralID
		GROUP BY A.SecurityEntityID,SEC.COLL_VAL_DATE,SEC.COLL_AMT,SEC.COLL_EXPRY_DATE
		
		/*END OF DATA INSERTING IN AdvSecurityValueDetail FROM SECURITY_ALL_SOURCE_SYSTEM*/
		
		/*UPDATING IN AdvSecurityDetail FROM SECURITY_ALL_SOURCE_SYSTEM FOR COLLETERAL DELINK DATE*/
		
		UPDATE  ASD SET COLL_DELINK_DATE=SEC.COLL_DELINK_DATE
		 FROM IBL_ENPA_STGDB_V2.[dbo].Security_All_Source_System SEC
		INNER JOIN IBL_ENPA_DB_V2.[CURDAT].AdvSecurityDetail ASD ON  --ASD.EffectiveFromTimeKey<=@TimeKey
		                                                      --AND ASD.EffectiveToTimeKey>=@TimeKey
															  --AND SEC.AS_ON_DATE=@EXT_DT
															  --AND ASD.SrcSystemAlt_Key=@SrcSysAlt_Key AND
		                                                       SEC.CollateralID=ASD.CollateralID
		                                                      AND ISNULL(SEC.CustomerID,'')=ISNULL(ASD.RefCustomer_CIF,'')
															  AND SEC.SRC_CIF=ASD.RefCustomerId
															  AND  SEC.AccountID=ASD.RefSystemAcId
		---WHERE ASD.COLL_DELINK_DATE<>SEC.COLL_DELINK_DATE
		where  ISNULL(ASD.COLL_DELINK_DATE,'1900-01-01')<>ISNULL(SEC.COLL_DELINK_DATE,'1900-01-01') --05/09/2021
		
		 
		/*UPDATING SecurityEntityID ON THE BASIS OF PARAMETER "@MaxSecID" DECLARED IN THE BEGINNING OF THIS SP*/
		
		UPDATE ASD SET SecurityEntityID=B.SecurityEntityID
		FROM 
		(SELECT CollateralID,ROW_NUMBER() OVER (ORDER BY CollateralID)+@MaxSecID SecurityEntityID
		FROM 
		(SELECT CollateralID 
		FROM  IBL_ENPA_DB_V2.[CURDAT].AdvSecurityDetail 
		WHERE EffectiveFromTimeKey<=@TimeKey
		AND EffectiveToTimeKey>=@TimeKey
		--AND SrcSystemAlt_Key=@SrcSysAlt_Key
		AND SecurityEntityID=0
		GROUP BY CollateralID) A) B
		INNER JOIN IBL_ENPA_DB.[CURDAT].AdvSecurityDetail ASD ON B.CollateralID=ASD.CollateralID
		
		
		
		/*UPDATING CHANGE RECORDS FOR ADVSECURITYVALUEDETAIL FROM Security_All_Source_System*/
		UPDATE ASVD SET ValuationDate=SEC.Valuationdate
		              ,CurrentValue=ISNULL(SEC.SecurityValue,0)
					  ,ValuationExpiryDate=SEC.ValuationExpiryDate
					  ,Prev_Value=(CASE WHEN ISNULL(CurrentValue,0)<>ISNULL(SEC.SecurityValue,0) THEN ISNULL(CurrentValue,0) ELSE Prev_Value END)
					  ,Prev_ValuationDate=(CASE WHEN ISNULL(CurrentValue,0)<>ISNULL(SEC.SecurityValue,0) THEN ISNULL(SEC.Valuationdate,0) ELSE Prev_ValuationDate END)
					  ,ModifiedBy='SSIS USER'
					  ,DateModified=GETDATE()
		FROM IBL_ENPA_STGDB_V2.[dbo].Security_All_Source_System SEC
		INNER JOIN  IBL_ENPA_DB_V2.[CURDAT].AdvSecurityDetail ASD ON 
															ASD.EffectiveFromTimeKey<=@TimeKey
		                                                      AND ASD.EffectiveToTimeKey>=@TimeKey
		                                                      AND SEC.DateofData=@EXT_DT  AND 
		                                                      SEC.CollateralID=ASD.CollateralID
		                                                       AND ISNULL(SEC.CustomerID,'')=ISNULL(ASD.RefCustomer_CIF,'')
															   AND SEC.SRC_CIF=ASD.RefCustomerId
															   AND SEC.AccountID=ASD.RefSystemAcId 
															   --AND ASD.SrcSystemAlt_Key=@SrcSysAlt_Key
		INNER JOIN  IBL_ENPA_DB_V2.[CURDAT].AdvSecurityValueDetail ASVD  ON ASVD.EffectiveFromTimeKey<=@TimeKey
		                                                               AND ASVD.EffectiveToTimeKey>=@TimeKey
		                                                               AND ASVD.SecurityEntityID=ASD.SecurityEntityID
		WHERE ISNULL(ASVD.ValuationDate,'1900-01-01')<>ISNULL(SEC.Valuationdate,'1900-01-01')
		   OR ISNULL(CurrentValue,0)<>ISNULL(SEC.SecurityValue,0)
		   OR ISNULL(ASVD.ValuationExpiryDate,'1900-01-01')<>ISNULL(SEC.ValuationExpiryDate,'1900-01-01')
		
		
		
		/*UPDATING STOCK STATEMENT DATE AND DPD OF STOCK STATEMENT RECORDS FOR ADVSECURITYVALUEDETAIL FROM Security_All_Source_System*/
		UPDATE C 
		SET StockStatementDt=A.ValuationDate
		   --,DPD_StockStmt=ISNULL(DATEDIFF(DAY,ValuationDate,@EXT_DT)+1,0) NEED TO ADD IN IBL_ENPA_STGDB_V2.[dbo].[ACCOUNT_ALL_SOURCE_SYSTEM]
		FROM 
		(SELECT A.RefCustomer_CIF,A.RefSystemAcId,A.RefCustomerId,MIN(B.ValuationDate)  ValuationDate
		FROM IBL_ENPA_DB_V2.[CURDAT].AdvSecurityDetail A
		INNER JOIN IBL_ENPA_DB_V2.[CURDAT].AdvSecurityValueDetail B 
										ON --A.EffectiveFromTimeKey<=@TimeKey
		                                   --AND A.EffectiveToTimeKey>=@TimeKey
										   --AND B.EffectiveFromTimeKey<=@TimeKey
		                                   --AND B.EffectiveToTimeKey>=@TimeKey
										   --AND A.SrcSystemAlt_Key=@SrcSysAlt_Key AND
										    A.SecurityEntityID=B.SecurityEntityID
		WHERE CollateralType IN ('COLHBD','COLHST')
		AND A.COLL_DELINK_DATE IS NULL--ADDED ON 31-07-2021
		GROUP BY A.RefCustomer_CIF,A.RefSystemAcId,A.RefCustomerId) A
		INNER JOIN IBL_ENPA_STGDB_V2.[dbo].[ACCOUNT_ALL_SOURCE_SYSTEM] C
										ON --C.EffectiveFromTimeKey<=@TimeKey
		                                   --AND C.EffectiveToTimeKey>=@TimeKey AND
										    A.RefCustomer_CIF=C.UCIC_ID
										   AND A.RefCustomerId=C.CustomerId
										   AND A.RefSystemAcId=C.CustomerACID
										   --AND SrcSysAlt_Key=@SrcSysAlt_Key
END
GO