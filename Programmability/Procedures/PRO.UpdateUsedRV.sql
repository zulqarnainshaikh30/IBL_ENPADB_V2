SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

 

/*=====================================

AUTHER : TRILOKI KHANNA

alter DATE : 27-11-2019

MODIFY DATE : 27-11-2019

DESCRIPTION : Update Used RV

EXEC pro.UpdateUsedRV  @TIMEKEY=25410

====================================*/

CREATE PROCEDURE [PRO].[UpdateUsedRV]

@TimeKey INT

with recompile

AS

  BEGIN

     SET NOCOUNT ON

       BEGIN TRY

                   

 

 

 UPDATE A SET A.USEDRV =0

FROM PRO.ACCOUNTCAL A

 

 

UPDATE A SET A.USEDRV =(CASE WHEN ISNULL(C.AssetClassShortNameEnum,'STD')='LOS'

                                                      THEN 0 

                                                 WHEN ISNULL(A.ApprRV,0) >= A.netbalance

                                                                                                                  THEN A.netbalance

                                                                                                                    ELSE ISNULL(A.ApprRV,0)

                                                                                                        END)

     

 FROM PRO.ACCOUNTCAL A

  INNER JOIN DIMASSETCLASS C ON C.AssetClassAlt_Key=isnull(A.FinalAssetClassAlt_Key,1)

                         AND (C.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND C.EFFECTIVETOTIMEKEY>=@TIMEKEY)

 

 

                                                                                               

 

IF OBJECT_ID('SECURITYDETAILExcessSecurity') IS NOT NULL                     

DROP  TABLE SECURITYDETAILExcessSecurity

select

CustomerEntityID

,RefCustomerID

,SUM(isnull(ApprRV,0)-isnull(USEDRV,0)) as ExcessSecurity

INTO SECURITYDETAILExcessSecurity

FROM PRO.ACCOUNTCAL

WHERE isnull(SecurityValue,0) =0

AND isnull(ApprRV,0)>0

GROUP by CustomerEntityID,REFCUSTOMERID

 ORDER BY CustomerEntityID,REFCUSTOMERID

 

;WITH CTENF(REFCUSTOMERID,TOTOSNF)                   

AS                   

(                   

SELECT B.REFCUSTOMERID,SUM(ISNULL(A.NETBALANCE,0)) TOTOSNF FROM  PRO.ACCOUNTCAL A    INNER JOIN PRO.CUSTOMERCAL B

ON A.CUSTOMERENTITYID=B.CUSTOMERENTITYID                                

WHERE A.NETBALANCE>0 

AND A.FlgAbinitio<>'Y'

AND A.FinalAssetClassAlt_Key<>6

--AND A.FlgSecured='D'    

AND isnull(SecurityValue,0)=0 AND A.FacilityType  in('LC','BG','NF')

GROUP BY B.REFCUSTOMERID                 

)                                         

            

UPDATE D SET D.ApprRV=((D.NETBALANCE/A.TOTOSNF)*C.ExcessSecurity)                                      

from CTENF A inner join PRO.CustomerCal B on A.REFCUSTOMERID=B.REFCUSTOMERID                            

inner join SECURITYDETAILExcessSecurity C on C.REFCustomerId=B.REFCUSTOMERID                    

INNER JOIN   PRO.AccountCal D on D.RefCustomerID=B.RefCustomerID                 

WHERE c.ExcessSecurity>0

AND D.FlgAbinitio<>'Y'

AND D.FinalAssetClassAlt_Key<>6

--AND D.FlgSecured='D'

AND isnull(SecurityValue,0)=0 AND D.FacilityType  in('LC','BG','NF')

 

 

----------------------------------------Calculating UsedRV Again for All Accounts on purpose----------------

 

 

UPDATE A SET A.USEDRV =(CASE WHEN ISNULL(C.AssetClassShortNameEnum,'STD')='LOS'

                                                      THEN 0 

                                                 WHEN ISNULL(A.ApprRV,0) >= A.netbalance

                                                                                                                  THEN A.netbalance

                                                                                                                    ELSE ISNULL(A.ApprRV,0)

                                                                                                        END)

     

 FROM PRO.ACCOUNTCAL A

  INNER JOIN DIMASSETCLASS C ON C.AssetClassAlt_Key=isnull(A.FinalAssetClassAlt_Key,1)

                         AND (C.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND C.EFFECTIVETOTIMEKEY>=@TIMEKEY)

 

                                                                                                -------------------------------------------Total CustomerApprRV should matched with UsedRV-------------

 

DROP TABLE IF EXISTS #NONFUNDEDEDTYPE

 

select CustomerEntityID,'N' AS NONFUNDEDEDTYPE

into #NONFUNDEDEDTYPE

from Pro.ACCOUNTCAL where UsedRV > 0 and FacilityType not in ('LC','BG','NF')

 

update A set A.NONFUNDEDEDTYPE = 'Y'

from #NONFUNDEDEDTYPE A INNER JOIN Pro.Accountcal B ON A.CustomerEntityID = B.CustomerEntityID

where UsedRV > 0 and FacilityType  in ('LC','BG','NF')

 

update A set A.ApprRV = A.UsedRV

from Pro.ACCOUNTCAL A

INNER JOIN #NONFUNDEDEDTYPE B

ON A.CustomerEntityID = B.CustomerEntityID

where NONFUNDEDEDTYPE = 'Y' and UsedRV >  0

and A.FacilityType not in ('LC','BG','NF')

 

UPDATE PRO.ACLRUNNINGPROCESSSTATUS

                SET COMPLETED='Y',ERRORDATE=NULL,ERRORDESCRIPTION=NULL,COUNT=ISNULL(COUNT,0)+1

                WHERE RUNNINGPROCESSNAME='UpdateUsedRV'

 

                -----------------Added for DashBoard 04-03-2021

--Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='ASSET CLASSIFICATION'

 

END TRY

BEGIN  CATCH

 

                UPDATE PRO.ACLRUNNINGPROCESSSTATUS

                SET COMPLETED='N',ERRORDATE=GETDATE(),ERRORDESCRIPTION=ERROR_MESSAGE(),COUNT=ISNULL(COUNT,0)+1

                WHERE RUNNINGPROCESSNAME='UpdateUsedRV'

END CATCH

                                               

     SET NOCOUNT OFF

END

 

 

 

 

 

 

 

 

 

 

GO