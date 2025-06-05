SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

 

 

/*==========================   

AUTHER : TRILOKI KHANNA   

alter DATE : 27-11-2019   

MODIFY DATE : 27-11-2019   

DESCRIPTION : UPDATE NET BALANCE ACCOUNT WISE   

--EXEC [PRO].[UpdateNetBalance_AccountWise] @TimeKey=25410      

======================================================*/   

      
CREATE PROCEDURE [PRO].[UpdateNetBalance_AccountWise]       
 @TimeKey int
 with recompile      
AS
 BEGIN      
   SET NOCOUNT ON 
 BEGIN TRY       

		UPDATE A SET NetBalance = ISNULL(PrincOutStd,0)
			FROM PRO.AccountCal A      
			INNER JOIN DimAssetClass B ON B.AssetClassAlt_Key=isnull(A.FinalAssetClassAlt_Key,1)
					AND (B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey)
		WHERE  B.ASSETCLASSGROUP='NPA' AND Isnull(A.FacilityType,'') NOT IN ('LC','BG','NF')

		UPDATE A SET NetBalance =  0
			FROM PRO.AccountCal A      
			INNER JOIN DimAssetClass B ON B.AssetClassAlt_Key=isnull(A.FinalAssetClassAlt_Key,1)
					AND (B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey)
			INNER JOIN ExceptionFinalStatusType C ON C.ACID=A.CustomerAcID
					AND (C.EffectiveFromTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey)
		WHERE  B.ASSETCLASSGROUP='NPA' And C.StatusType IN('TWO','WO')
				AND isnull(A.FacilityType,'') NOT IN ('LC','BG','NF')
 

		UPDATE A SET NetBalance = ISNULL(Balance,0)
            FROM PRO.AccountCal A      
			INNER JOIN DimAssetClass B ON B.AssetClassAlt_Key=isnull(A.FinalAssetClassAlt_Key,1)
				   AND (B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey)
			WHERE  B.ASSETCLASSGROUP<>'NPA' AND Isnull(A.FacilityType,'') NOT IN ('LC','BG','NF')

 
---BELOW CODE SHIFTED TO NET BALANCE CALCULATION SP

		UPDATE A SET A.AddlProvision=(A.NetBalance * A.AddlProvisionPer)/100
		FROM PRO.AccountCal A
			WHERE  ISNULL(A.AddlProvisionPer,0)<>0
            ----- Start  Non Funded NET Amount Work-----
		IF OBJECT_ID('TEMPDB..#NFCCFAmount') IS NOT NULL
			DROP TABLE #NFCCFAmount
			SELECT CustomerAcID,(ISNULL(A.Balance,0)* ISNULL(B.ConvFactor,20))/100 as ConvFactorAmount
			into #NFCCFAmount
			FROM PRO.ACCOUNTCAL A
				INNER JOIN DimProduct B
					ON A.ProductAlt_Key=B.ProductAlt_Key
				WHERE ISNULL(A.Balance,0)>0
					AND (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
					AND (B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey)
					AND isnull(A.FacilityType,'') IN ('LC','BG','NF')

 

		UPDATE A SET NetBalance=B.ConvFactorAmount
		FROM PRO.ACCOUNTCAL A
		INNER JOIN #NFCCFAmount B
			ON A.CUSTOMERACID=B.CUSTOMERACID
                                -----End Non Funded NET Amount Work-----
                                /*  AS PER DISCUSSIONS WITH SHISHIR SIR ON 19102023 - HE WILL SEND DOCUMENT*/

    DECLARE @ProcessingDate DATE=(SELECT DATE FROM SYSDAYMATRIX WHERE TIMEKEY=@TIMEKEY)             

 

/* IBPC  */

		UPDATE A        
		SET  NetBalance = NetBalance-ISNULL(B.ExposureAmount,0)
		FROM PRO.AccountCal A 
		INNER JOIN IBPCFinalPoolDetail B
			ON B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
				AND A.CustomerAcID=B.AccountID
		WHERE PoolType='WITH RISK'

 
--/* SALE TO ARC  */

		UPDATE A        
		SET  NetBalance = 0
		FROM PRO.AccountCal A 
		INNER JOIN SaletoArcFinalACFlagging B
			ON B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
				AND A.CustomerAcID=B.AccountID
		WHERE B.DtofsaletoARC<@ProcessingDate

 

/* SECURITISATIONS */

        UPDATE A        
        SET  NetBalance = NetBalance-ISNULL(B.ExposureAmount,0)
        FROM PRO.AccountCal A 
        INNER JOIN SecuritizedFinalACDetail B
			ON B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
				AND A.CustomerAcID=B.AccountID
		WHERE poolType='DA'   -----------------As discussed with kandpal Sir
 

/*   END OF  IBPC, SALE TO ARC AND SECURITISATION  CHANGES*/

         UPDATE A        
         SET NetBalance = 0
         FROM PRO.AccountCal A  
		 where ISNULL(NetBalance,0)<0

		update pro.ACCOUNTCAL set UnserviedInt=isnull(CurQtrInt,0)-isnull(CurQtrCredit,0)
		where InitialAssetClassAlt_Key=1 and FinalAssetClassAlt_Key>1
			and isnull(CurQtrInt,0)>isnull(CurQtrCredit,0)

 
		update pro.ACCOUNTCAL set UnserviedInt=0
		where  FinalAssetClassAlt_Key=1

		update pro.ACCOUNTCAL set UnserviedInt=0  
		where ISNULL(UnserviedInt,0)<0
 
		UPDATE PRO.ACLRUNNINGPROCESSSTATUS
		SET COMPLETED='Y',ERRORDATE=NULL,ERRORDESCRIPTION=NULL,COUNT=ISNULL(COUNT,0)+1
	    WHERE RUNNINGPROCESSNAME='UpdateNetBalance_AccountWise'

             ----------------Added for DashBoard 04-03-2021

        Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 
		where BandName='ASSET CLASSIFICATION'

END TRY

BEGIN  CATCH
                UPDATE PRO.ACLRUNNINGPROCESSSTATUS
                SET COMPLETED='N',ERRORDATE=GETDATE(),ERRORDESCRIPTION=ERROR_MESSAGE(),COUNT=ISNULL(COUNT,0)+1
                WHERE RUNNINGPROCESSNAME='UpdateNetBalance_AccountWise'

END CATCH
        SET NOCOUNT OFF 
END

 

 

 

 

 

 

 

 

 

GO