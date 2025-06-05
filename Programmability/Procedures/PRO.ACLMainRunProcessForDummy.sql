SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO







CREATE PROC [PRO].[ACLMainRunProcessForDummy]
@Date as Varchar(20)
,@Result as Int = 0 OutPut
As


BEGIN

SET DATEFORMAT DMY

Declare @TimeKey as Int =(Select TimeKey from sysdaymatrix 
where Cast(Date as Date)=Case when ISNULL(@Date,'')='' Then '2020-09-30' Else Cast(@Date as Date) End)
DECLARE @ProcessingDate DATE=(SELECT DATE FROM SYSDAYMATRIX WHERE TIMEKEY=@TIMEKEY)

DECLARE @PROCESSMONTH DATE =(select date from SysDayMatrix where TimeKey=@TIMEKEY)

DECLARE  @6MnthBackTimeKey SmallInt,@6MonthBackDate Date
		SET @6MonthBackDate = DATEADD(M,-6,@ProcessingDate)
----------------

Update [dbo].Automate_Advances set EXT_FLG='N' WHERE EXT_FLG='Y'

Update [dbo].Automate_Advances set EXT_FLG='Y' WHERE Cast(Date as Date)=Cast(@Date as Date)

Update pro.ACCOUNTCAL set EffectiveFromTimeKey=@TimeKey , EffectiveToTimekey=@TimeKey

Update pro.CustomerCal set EffectiveFromTimeKey=@TimeKey , EffectiveToTimekey=@TimeKey
Update pro.CustomerCal set IsChanged='N'
Update pro.ACCOUNTCAL set IsChanged='N'

------------

update PRO.AclRunningProcessStatus set Completed='N',COUNT=0,ERRORDESCRIPTION=NULL , ERRORDATE=NULL WHERE id>1


UPDATE PRO.CUSTOMERCAL SET ASSET_NORM='NORMAL'

UPDATE PRO.ACCOUNTCAL SET ASSET_NORM='NORMAL'

UPDATE PRO.ACCOUNTCAL SET UpgDate=NULL

update a set Asset_Norm='ALWYS_STD'
FROM PRO.ACCOUNTCAL A 
INNER JOIN DimProduct B  ON A.ProductAlt_Key=B.ProductAlt_Key 
where B.AssetClass='ALWYS_STD'
AND  (B.EffectiveFromTimeKey<=@TIMEKEY and B.EffectiveToTimeKey>=@TIMEKEY)

update a set Asset_Norm='CONDI_STD'
FROM PRO.ACCOUNTCAL A 
INNER JOIN DimProduct B  ON A.ProductAlt_Key=B.ProductAlt_Key 
where B.AssetClass='CONDI_STD'
AND  (B.EffectiveFromTimeKey<=@TIMEKEY and B.EffectiveToTimeKey>=@TIMEKEY)




UPDATE A SET ReferencePeriod=91
FROM CURDAT.ADVACBASICDETAIL A 
INNER JOIN DimProduct B  ON A.ProductAlt_Key=B.ProductAlt_Key 
where NPANorms  LIKE '%91%' AND (B.EffectiveFromTimeKey<=@TIMEKEY and B.EffectiveToTimeKey>=@TIMEKEY)

UPDATE A SET ReferencePeriod=61
FROM CURDAT.ADVACBASICDETAIL A 
INNER JOIN DimProduct B  ON A.ProductAlt_Key=B.ProductAlt_Key 
where NPANorms  LIKE '%61%' AND (B.EffectiveFromTimeKey<=@TIMEKEY and B.EffectiveToTimeKey>=@TIMEKEY)

UPDATE A SET ReferencePeriod=366
FROM CURDAT.ADVACBASICDETAIL A 
INNER JOIN DimProduct B  ON A.ProductAlt_Key=B.ProductAlt_Key 
where NPANorms  LIKE '%366%' AND (B.EffectiveFromTimeKey<=@TIMEKEY and B.EffectiveToTimeKey>=@TIMEKEY)

UPDATE A SET ReferencePeriod=91
FROM CURDAT.ADVACBASICDETAIL A 
WHERE ISNULL(ReferencePeriod,0)=0


UPDATE A SET A.Asset_Norm='ALWYS_NPA'
            ,A.FinalAssetClassAlt_Key=2
			,A.FinalNpaDt=CASE WHEN FinalNpaDt is NULL then @PROCESSINGDATE else  FinalNpaDt end
			,A.NPA_Reason='NPA DUE TO Inherent Weakness Account'
			,A.WeakAccount='Y'
			FROM PRO.AccountCal A 
where  A.WeakAccount='Y' and FinalAssetClassAlt_Key=1


UPDATE A SET A.Asset_Norm='ALWYS_NPA'
            --,A.FinalAssetClassAlt_Key=2
			--,A.FinalNpaDt=CASE WHEN FinalNpaDt is NULL then @PROCESSINGDATE else  FinalNpaDt end
			,A.NPA_Reason='NPA DUE TO Inherent Weakness Account'
			,A.WeakAccount='Y'
			FROM PRO.AccountCal A 
where  A.WeakAccount='Y' and FinalAssetClassAlt_Key>1

update a set SysAssetClassAlt_Key=b.FinalAssetClassAlt_Key,SysNPA_Dt=b.FinalNpaDt,a.DegReason=b.NPA_Reason,a.Asset_Norm=b.Asset_Norm
FROM pro.customercal a
inner join PRO.AccountCal b
on a.CustomerEntityID=b.CustomerEntityID
where b.WeakAccount='Y' 

UPDATE A SET A.Asset_Norm='ALWYS_NPA'
            ,A.FinalAssetClassAlt_Key=2
			,A.FinalNpaDt=CASE WHEN FinalNpaDt is NULL then @PROCESSINGDATE else  FinalNpaDt end
			,A.NPA_Reason='NPA DUE TO SARFAESI  Account'
			FROM PRO.AccountCal A 
where  A.Sarfaesi ='Y' AND FinalAssetClassAlt_Key=1


UPDATE A SET A.Asset_Norm='ALWYS_NPA'
          --  ,A.FinalAssetClassAlt_Key=2
			--,A.FinalNpaDt=CASE WHEN FinalNpaDt is NULL then @PROCESSINGDATE else  FinalNpaDt end
			,A.NPA_Reason='NPA DUE TO SARFAESI  Account'
			FROM PRO.AccountCal A 
where  A.Sarfaesi ='Y' AND FinalAssetClassAlt_Key>1

update a set SysAssetClassAlt_Key=b.FinalAssetClassAlt_Key,SysNPA_Dt=b.FinalNpaDt,a.DegReason=b.NPA_Reason,a.Asset_Norm=b.Asset_Norm
FROM pro.customercal a
inner join PRO.AccountCal b
on a.CustomerEntityID=b.CustomerEntityID
where b.Sarfaesi='Y' 

UPDATE A SET A.Asset_Norm='ALWYS_NPA'
            ,A.FinalAssetClassAlt_Key=2
			,A.FinalNpaDt=CASE WHEN REPOSSESSIONDATE is NULL then @PROCESSINGDATE else  REPOSSESSIONDATE end
			,A.NPA_Reason='NPA DUE TO RePossession  Account'
			FROM PRO.AccountCal A 
where  A.RePossession ='Y' AND FinalAssetClassAlt_Key=1


UPDATE A SET A.Asset_Norm='ALWYS_NPA'
           -- ,A.FinalAssetClassAlt_Key=2
			--,A.FinalNpaDt=CASE WHEN REPOSSESSIONDATE is NULL then @PROCESSINGDATE else  REPOSSESSIONDATE end
			,A.NPA_Reason='NPA DUE TO RePossession  Account'
			FROM PRO.AccountCal A 
where  A.RePossession ='Y' AND FinalAssetClassAlt_Key>1


update a set SysAssetClassAlt_Key=b.FinalAssetClassAlt_Key,SysNPA_Dt=b.FinalNpaDt,a.DegReason=b.NPA_Reason,a.Asset_Norm=b.Asset_Norm
FROM pro.customercal a
inner join PRO.AccountCal b
on a.CustomerEntityID=b.CustomerEntityID
where b.RePossession='Y' 

UPDATE A SET A.Asset_Norm='ALWYS_NPA'
            ,A.FinalAssetClassAlt_Key=6
			,A.FinalNpaDt=CASE WHEN FraudDt is NOT NULL then FraudDt  else  @PROCESSINGDATE end
			,A.NPA_Reason='NPA DUE TO FRAUD MARKING'
			FROM PRO.AccountCal A 
			INNER JOIN PRO.CUSTOMERCAL B
			ON A.RefCustomerID=B.RefCustomerID
where  A.SplCatg1Alt_Key=870

UPDATE A SET A.Asset_Norm='ALWYS_NPA'
            ,A.FinalAssetClassAlt_Key=6
			,A.FinalNpaDt=CASE WHEN FraudDt is NOT NULL then FraudDt  else  @PROCESSINGDATE end
			,A.NPA_Reason='NPA DUE TO FRAUD MARKING'
			,A.SplCatg1Alt_Key=870
			FROM PRO.AccountCal A 
			INNER JOIN PRO.CUSTOMERCAL B
			ON A.RefCustomerID=B.RefCustomerID
where  B.SplCatg1Alt_Key=870

update a set SysAssetClassAlt_Key=b.FinalAssetClassAlt_Key,SysNPA_Dt=b.FinalNpaDt,a.DegReason=b.NPA_Reason,a.Asset_Norm=b.Asset_Norm
FROM pro.customercal a
inner join PRO.AccountCal b
on a.CustomerEntityID=b.CustomerEntityID
where B.SplCatg1Alt_Key=870

UPDATE A SET A.Asset_Norm='ALWYS_NPA'
            ,A.FinalAssetClassAlt_Key=6
			,A.FinalNpaDt=CASE WHEN FinalNpaDt is NULL then @PROCESSINGDATE else  FinalNpaDt end
			,A.NPA_Reason='NPA DUE TO WRITEOFF MARKING'
			FROM PRO.AccountCal A 
			INNER JOIN PRO.CUSTOMERCAL B
			ON A.RefCustomerID=B.RefCustomerID
where  A.WriteOffAmount>0

UPDATE A SET A.Asset_Norm='ALWYS_NPA'
            ,A.FinalAssetClassAlt_Key=6
			,A.FinalNpaDt=CASE WHEN FinalNpaDt is NULL then @PROCESSINGDATE else  FinalNpaDt end
			,A.NPA_Reason='NPA DUE TO WRITEOFF MARKING'
			FROM PRO.AccountCal A 
			INNER JOIN PRO.CUSTOMERCAL B
			ON A.RefCustomerID=B.RefCustomerID
where  A.WriteOffAmount>0



update a set SysAssetClassAlt_Key=b.FinalAssetClassAlt_Key,SysNPA_Dt=b.FinalNpaDt,a.DegReason=b.NPA_Reason,a.Asset_Norm=b.Asset_Norm
FROM pro.customercal a
inner join PRO.AccountCal b
on a.CustomerEntityID=b.CustomerEntityID
where B.WriteOffAmount>0



UPDATE A SET A.Asset_Norm='ALWYS_NPA'
           	,A.FinalAssetClassAlt_Key=6
			,A.FinalNpaDt=CASE WHEN FinalNpaDt is NULL then @PROCESSINGDATE else  FinalNpaDt end
			,A.NPA_Reason='NPA DUE TO RFA MARKING'
			,RFA='Y'
		FROM PRO.AccountCal A 
where A.RFA='Y' AND  A.FinalNpaDt <@6MonthBackDate

UPDATE C SET C.Asset_Norm='ALWYS_NPA'
           	,C.SYSASSETCLASSALT_KEY=6
			,C.SYSNPA_DT=CASE WHEN SYSNPA_DT is NULL then @PROCESSINGDATE else  SYSNPA_DT end
			,C.DEGREASON='NPA DUE TO RFA MARKING'
			FROM PRO.CUSTOMERCAL c
inner join PRO.AccountCal b on c.RefCustomerID=b.RefCustomerID
where B.RFA='Y' AND  C.SYSNPA_DT <@6MonthBackDate


UPDATE B SET SecApp='S'
FROM PRO.CustomerCal  A 
INNER JOIN PRO.AccountCal B ON
A.CustomerEntityID=B.CustomerEntityID
WHERE ISNULL(CurntQtrRv,0)>0

UPDATE B SET FlgSecured='D'
FROM PRO.CustomerCal  A 
INNER JOIN PRO.AccountCal B ON
A.CustomerEntityID=B.CustomerEntityID
WHERE ISNULL(CurntQtrRv,0)>0

update pro.ACCOUNTCAL set FlgSecured='D'
from pro.ACCOUNTCAL
where securityvalue>0


         
UPDATE 	  PRO.ACCOUNTCAL set NETBALANCE= BALANCE   
    
;WITH CTE(REFCUSTOMERID,TOTOSFUNDED)                    
AS                    
(                    
SELECT B.REFCUSTOMERID,SUM(ISNULL(A.BALANCE,0)) TOTOSFUNDED
 FROM  PRO.ACCOUNTCAL A    INNER JOIN PRO.CUSTOMERCAL B ON A.CUSTOMERENTITYID=B.CUSTOMERENTITYID    
                          
WHERE A.BALANCE>0  AND b.CurntQtrRv>0 
              
GROUP BY B.REFCUSTOMERID                  
)                                          
            
UPDATE D SET D.                                    
SecurityValue=CASE WHEN  ((D.NETBALANCE/A.TOTOSFUNDED)*b.CurntQtrRv)>D.NETBALANCE THEN D.NETBALANCE       
ELSE ((D.NETBALANCE/A.TOTOSFUNDED)*b.CurntQtrRv) END                                        
from CTE A inner join PRO.CustomerCal B on A.REFCUSTOMERID=B.REFCUSTOMERID                             
                  
INNER JOIN   pro.AccountCal D on D.RefCustomerID=B.RefCustomerID                  
WHERE b.CurntQtrRv>0

UPDATE PRO.ACCOUNTCAL set InttServiced='Y',INTNOTSERVICEDDT=NULL


UPDATE A SET A.InttServiced='N'
            ,A.INTNOTSERVICEDDT= DATEADD(DAY,-91,@PROCESSINGDATE)
FROM PRO.ACCOUNTCAL A 
INNER JOIN DimProduct C  ON A.ProductAlt_Key=C.ProductAlt_Key 
WHERE ISNULL(A.Balance,0)>0  AND ISNULL(A.CurQtrCredit,0)<ISNULL(A.CurQtrInt,0) 
AND  A.FacilityType IN('CC','OD')
AND (DATEADD(DAY,90,A.FirstDtOfDisb)<@PROCESSINGDATE AND A.FirstDtOfDisb IS NOT NULL AND Asset_Norm<>'ALWYS_STD' )
AND C.EffectiveFromTimeKey<=@timekey AND C.EffectiveToTimeKey>=@timekey
AND isnull(C.ProductSubGroup,'N') NOT in('Agri Busi','Agri TL','KCC')

UPDATE A SET A.InttServiced='N',INTNOTSERVICEDDT=NULL
FROM PRO.ACCOUNTCAL A 
INNER JOIN DimProduct C  ON A.ProductAlt_Key=C.ProductAlt_Key 
WHERE   A.FacilityType IN('CC','OD')
AND (DATEADD(DAY,90,A.DebitSinceDt)>@PROCESSINGDATE AND A.DebitSinceDt IS NOT NULL AND Asset_Norm<>'ALWYS_STD' )
AND C.EffectiveFromTimeKey<=@timekey AND C.EffectiveToTimeKey>=@timekey
AND isnull(C.ProductSubGroup,'N') NOT in('Agri Busi','Agri TL','KCC')
AND InttServiced='N'



UPDATE A SET A.InttServiced='N'
            ,A.INTNOTSERVICEDDT= DATEADD(DAY,-366,@PROCESSINGDATE)
FROM PRO.ACCOUNTCAL A 
INNER JOIN DimProduct C  ON A.ProductAlt_Key=C.ProductAlt_Key 
WHERE ISNULL(A.Balance,0)>0  AND ISNULL(A.CurQtrCredit,0)<ISNULL(A.CurQtrInt,0) 
--AND  FacilityType IN('CC','OD')
AND DATEADD(DAY,90,A.FirstDtOfDisb)<@PROCESSINGDATE AND A.FirstDtOfDisb IS NOT NULL AND Asset_Norm<>'ALWYS_STD' 
--AND DATEADD(DAY,90,A.DebitSinceDt)<@PROCESSINGDATE AND A.DebitSinceDt IS NOT NULL AND Asset_Norm<>'ALWYS_STD' 
AND C.EffectiveFromTimeKey<=@timekey AND C.EffectiveToTimeKey>=@timekey
AND isnull(C.ProductSubGroup,'N')  in('Agri Busi','Agri TL','KCC')




EXEC   PRO.Reference_Period_Calculation @TimeKey=@TimeKey
EXEC   PRO.DPD_Calculation @TimeKey=@TimeKey
EXEC   PRO.Marking_InMonthMark_Customer_Account_level @TimeKey=@TimeKey
EXEC   PRO.Marking_FlgDeg_Degreason @TimeKey=@TimeKey
EXEC   PRO.MaxDPD_ReferencePeriod_Calculation @TimeKey=@TimeKey
EXEC   PRO.NPA_Date_Calculation @TimeKey=@TimeKey
EXEC   PRO.Update_AssetClass @TimeKey=@TimeKey
EXEC   PRO.NPA_Erosion_Aging @TimeKey=@TimeKey
EXEC   PRO.Final_AssetClass_Npadate @TimeKey=@TimeKey
EXEC   PRO.Upgrade_Customer_Account @TimeKey=@TimeKey
EXEC   PRO.SMA_MARKING @TimeKey=@TimeKey
EXEC   PRO.Marking_FlgPNPA @TimeKey=@TimeKey
EXEC   PRO.[Marking_NPA_Reason_NPAAccount] @TimeKey=@TimeKey
EXEC   PRO.UpdateProvisionKey_AccountWise @TimeKey=@TimeKey
EXEC   PRO.UpdateNetBalance_AccountWise @TimeKey=@TimeKey
EXEC   PRO.[GovtGuarAppropriation] @TimeKey=@TimeKey
EXEC   PRO.[SecurityAppropriation] @TimeKey=@TimeKey
EXEC   PRO.[UpdateUsedRV] @TimeKey=@TimeKey
EXEC   PRO.[ProvisionComputationSecured] @TimeKey=@TimeKey
EXEC   PRO.GovtGurCoverAmount @TimeKey=@TimeKey
EXEC   PRO.UpdationProvisionComputationUnSecured @TimeKey=@TimeKey
EXEC   PRO.UpdationTotalProvision @TimeKey=@TimeKey


Set @Result = 1

RETURN @Result

END

GO