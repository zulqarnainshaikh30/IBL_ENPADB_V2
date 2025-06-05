SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


--EXEC [PRO].[SecurityAppropriation_IBL]27303
CREATE PROCEDURE [PRO].[SecurityAppropriation_IBL](@TimeKey Smallint)
WITH RECOMPILE
AS
/****************** SECURITY APPROPRIATION *********************/

/* 1- CUSTOMER LEVEL APPROPRIATION */

		/* 1.1 CREATE TABLE FOR CUSTOMER LEVEL SECURITY */
DECLARE @ProcessingDate DATE = (SELECT DATE FROM SYSDAYMATRIX WHERE TimeKey=@TimeKey)

BEGIN TRY
DELETE IBL_ENPA_STGDB.[dbo].[Procedure_Audit] 
WHERE [SP_Name]='SecurityAppropriation' AND [EXT_DATE]=@ProcessingDate AND ISNULL([Audit_Flg],0)=0

INSERT INTO IBL_ENPA_STGDB.[dbo].[Procedure_Audit]
           ([EXT_DATE] ,[Timekey] ,[SP_Name],Start_Date_Time )
SELECT @ProcessingDate,@TimeKey,'SecurityAppropriation',GETDATE()
BEGIN TRAN

IF OBJECT_ID('tempdb..#Temp') IS NOT NULL
DROP TABLE #Temp

CREATE TABLE #Temp(NCIF_ID VARCHAR(100),CustomerId VARCHAR(50),CollateralID VARCHAR(100),CustomerExposer DECIMAL(30,5),CollTotal DECIMAL(30,5),CollWiseCustExposure  DECIMAL(30,5),
AppPER  DECIMAL(10,5),AppSecurity DECIMAL(30,5))

INSERT INTO #Temp(NCIF_ID,CustomerId,CollateralID,CollTotal)
SELECT A.RefCustomer_CIF,C.RefCustomerId,A.CollateralID ,B.CurrentValue
FROM Curdat.AdvSecurityDetail  A
INNER JOIN Curdat.AdvSecurityValueDetail  B ON  A.EffectiveFromTimeKey<=@TimeKey
                                            AND A.EffectiveToTimeKey>=@TimeKey
                                            AND B.EffectiveFromTimeKey<=@TimeKey
                                            AND B.EffectiveToTimeKey>=@TimeKey
											AND A.SecurityEntityID=B.SecurityEntityID
INNER JOIN PRO.ACCOUNTCAL C ON  C.EffectiveFromTimeKey=@TimeKey
                                   AND A.RefSystemAcId=C.CustomerACID
                                   AND A.RefCustomerId=C.REFCustomerId
								   AND A.RefCustomer_CIF=C.UCIF_ID
WHERE A.CollateralID IN(SELECT DISTINCT CollateralID 
FROM Curdat.AdvSecurityDetail 
WHERE EffectiveFromTimeKey<=@TimeKey
AND EffectiveToTimeKey>=@TimeKey)
AND ISNULL(B.ValuationExpiryDate,'1900-01-01')>=@ProcessingDate
AND C.FlgSecured='Y'
---AND C.IsFunded='Y'
AND ISNULL(B.CurrentValue,0)>0
GROUP BY A.RefCustomer_CIF,C.RefCustomerId,A.CollateralID,B.CurrentValue

CREATE NONCLUSTERED INDEX #Temp_IX ON #Temp(NCIF_ID,CustomerId)

UPDATE B SET CustomerExposer=NetBalance
FROM  
(SELECT UCIF_ID NCIF_Id,RefCustomerID,SUM(NetBalance)  NetBalance
	FROM PRO.ACCOUNTCAL A
	WHERE A.RefCustomerID IN(SELECT DISTINCT CustomerId FROM #TEMP)
	AND EffectiveFromTimeKey<=@TimeKey
	AND EffectiveToTimeKey>=@TimeKey
	AND FlgSecured='Y'
	----AND IsFunded='Y'
GROUP BY  UCIF_ID,RefCustomerID)A
INNER JOIN #Temp B ON A.RefCustomerID=B.CustomerId
                   AND A.NCIF_Id=B.NCIF_ID

UPDATE B SET CollWiseCustExposure=A.CustomerExposer
FROM
(SELECT CollateralID,SUM(CustomerExposer)  CustomerExposer
FROM #Temp
GROUP BY CollateralID) A 
INNER JOIN #Temp B ON A.CollateralID=B.CollateralID

UPDATE #Temp SET AppPER=(CustomerExposer/CollWiseCustExposure)*100
WHERE CollWiseCustExposure>0

UPDATE #Temp SET AppSecurity=(CollTotal*AppPER)/100

IF OBJECT_ID('tempdb..#AccTemp') IS NOT NULL
DROP TABLE #AccTemp

CREATE TABLE #AccTemp(NCIF_ID VARCHAR(100),CustomerId VARCHAR(50),CollateralID VARCHAR(100),CustomerExposer DECIMAL(30,5),CollTotal DECIMAL(30,5),CollWiseCustExposure  DECIMAL(30,5),
AppPER  DECIMAL(10,5),AppSecurity DECIMAL(30,5),CustomerAcID VARCHAR(50),AccountPOS DECIMAL(30,5),AccountSecPer  DECIMAL(10,5),AccountAppSecurity DECIMAL(30,5))

insert into #AccTemp(NCIF_ID,CustomerId,CollateralID,CustomerExposer,CollTotal,CollWiseCustExposure,AppPER,AppSecurity,CustomerAcID,AccountPOS)
SELECT DISTINCT A.NCIF_ID,A.CustomerId,A.CollateralID,A.CustomerExposer,A.CollTotal,A.CollWiseCustExposure,A.AppPER,A.AppSecurity,B.CustomerAcID,B.NetBalance
FROM #Temp A
INNER JOIN PRO.ACCOUNTCAL B  ON a.NCIF_ID=b.UCIF_ID
								   and a.CustomerId=b.RefCustomerID
WHERE  b.FlgSecured='Y'
--AND b.IsFunded='Y'
AND B.NetBalance>0

CREATE NONCLUSTERED INDEX #AccTemp_IX ON #AccTemp(NCIF_ID,CustomerId,CustomerACID) INCLUDE(AccountAppSecurity)

UPDATE #AccTemp SET AccountSecPer=(AccountPOS/CustomerExposer)*100
WHERE CustomerExposer>0

UPDATE #AccTemp SET AccountAppSecurity=(AccountSecPer*AppSecurity)/100


update A SET A.SecurityValue=b.AccountAppSecurity,
		            SecuredAmt=CASE WHEN ISNULL(AccountAppSecurity,0)>0
					                     THEN (CASE WHEN ISNULL(B.AccountAppSecurity,0)>ISNULL(A.PrincOutStd,0) 
					                     THEN ISNULL(A.PrincOutStd,0) 
								    ELSE ISNULL(B.AccountAppSecurity,0) 
							   END)
							   ELSE 0
							   END,
                    UnSecuredAmt=(CASE WHEN ISNULL(AccountAppSecurity,0)>0
					                       THEN (CASE WHEN ISNULL(B.AccountAppSecurity,0)>ISNULL(A.PrincOutStd,0) 
					                                       THEN 0 
								                      ELSE ISNULL(A.PrincOutStd,0)-ISNULL(B.AccountAppSecurity,0) 
							                       END)
                                       ELSE A.PrincOutStd
								  END)	    
		FROM PRO.ACCOUNTCAL A
		LEFT JOIN (SELECT NCIF_ID,CustomerId,CustomerACID,SUM(AccountAppSecurity) AccountAppSecurity
		             FROM #AccTemp
					GROUP BY NCIF_ID,CustomerId,CustomerACID) b ON B.NCIF_ID =a.UCIF_ID
							                                   AND B.CustomerId=A.RefCustomerID
							                                   AND B.CustomerACID=A.CustomerACID
       WHERE A.EffectiveFromTimeKey<=@TimeKey
		 AND A.EffectiveToTimeKey>=@TimeKey 

INSERT INTO dbo.SecurityDistribution(AsOnDate,NCIF_ID,CustomerId,CollateralID,CustomerExposer,CollTotal,CollWiseCustExposure,
AppPER,AppSecurity,CustomerAcID,AccountPOS,AccountSecPer,AccountAppSecurity)
SELECT @ProcessingDate,NCIF_ID,CustomerId,CollateralID,CustomerExposer,CollTotal,CollWiseCustExposure,
AppPER,AppSecurity,CustomerAcID,AccountPOS,AccountSecPer,AccountAppSecurity
FROM #AccTemp

--UPDATE Audit Flag

UPDATE PRO.ACLRUNNINGPROCESSSTATUS 
SET COMPLETED='Y',ERRORDATE=NULL,ERRORDESCRIPTION=NULL,COUNT=ISNULL(COUNT,0)+1
WHERE RUNNINGPROCESSNAME='SecurityAppropriation'


COMMIT TRAN
UPDATE IBL_ENPA_STGDB.[dbo].[Procedure_Audit] SET End_Date_Time=GETDATE(),[Audit_Flg]=1 
WHERE [SP_Name]='SecurityAppropriation' AND [EXT_DATE]=@ProcessingDate AND ISNULL([Audit_Flg],0)=0
END TRY
BEGIN CATCH
 DECLARE
   @ErMessage NVARCHAR(2048),
   @ErSeverity INT,
   @ErState INT
 
 SELECT  @ErMessage = ERROR_MESSAGE(),
   @ErSeverity = ERROR_SEVERITY(),
   @ErState = ERROR_STATE()

UPDATE IBL_ENPA_STGDB.[dbo].[Procedure_Audit] SET ERROR_MESSAGE=@ErMessage 
WHERE [SP_Name]='SecurityAppropriation' AND [EXT_DATE]=@ProcessingDate AND ISNULL([Audit_Flg],0)=0
 
 RAISERROR (@ErMessage,
             @ErSeverity,
             @ErState )

ROLLBACK TRAN
END CATCH


GO