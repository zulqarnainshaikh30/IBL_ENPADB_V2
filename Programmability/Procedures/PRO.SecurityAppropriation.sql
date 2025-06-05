SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/*=====================================
AUTHER : TRILOKI KHANNA
CREATE DATE : 27-11-2019
MODIFY DATE : 27-11-2019
DESCRIPTION : Security Appropriation MARKING
EXEC pro.SecurityAppropriation  @TIMEKEY=25410
====================================*/
CREATE PROCEDURE [PRO].[SecurityAppropriation]
@TimeKey INT 
WITH RECOMPILE
AS
  BEGIN
       SET  NOCOUNT ON
        BEGIN TRY
   
      
                      
  -----------======================Fetching Security Data from  Customer Table================-----------------                    
             
          
DELETE FROM SecurityDetails WHERE TIMEKEY =@TIMEKEY          
           
INSERT INTO SecurityDetails          
(          
REFCustomerId,          
TotalSecurity,          
TIMEKEY          
)          
SELECT           
REFCustomerId,          
SUM(ISNULL(CurntQtrRv,0))TotalSecurity,          
@TIMEKEY TIMEKEY          
FROM           
PRO.CUSTOMERCAL 
WHERE  ISNULL(CurntQtrRv,0)>0                  
GROUP BY REFCUSTOMERID            
                                
      /*TempTableForSecurity  being create */                      
                                 
IF OBJECT_ID('SECURITYDETAIL') IS NOT NULL                      
DROP  TABLE SECURITYDETAIL                      
                                 
SELECT REFCustomerId,SUM(ISNULL(TOTALSECURITY,0)) AS TOTALSECURITY INTO SECURITYDETAIL FROM SECURITYDETAILS                       
WHERE TIMEKEY =@TIMEKEY                     
GROUP BY REFCustomerId                      
                                                  
UPDATE  PRO.ACCOUNTCAL SET ApprRV=0                            

--------Security App For account security only for that Account--------
--UPDATE A set ApprRV=
--CASE WHEN  ((A.NETBALANCE/A.BALANCE)*A.SecurityValue)>A.NETBALANCE THEN A.NETBALANCE       
--ELSE ((A.NETBALANCE/A.BALANCE)*A.SecurityValue) END  from pro.AccountCal A  
--WHERE isnull(BALANCE,0)>0 and isnull(SecurityValue,0)>0                   
              
			  --------------AND isnull(SecurityValue,0)=0 THIS CODE IS COMMENTED ON 20062024 AS DISCUSS WITH JAYDEV/SUDESH
;WITH CTE(REFCUSTOMERID,TOTOSFUNDED)                    
AS                    
(                    
SELECT B.REFCUSTOMERID,SUM(ISNULL(A.NETBALANCE,0)) TOTOSFUNDED FROM  PRO.ACCOUNTCAL A    INNER JOIN PRO.CUSTOMERCAL B
 ON A.CUSTOMERENTITYID=B.CUSTOMERENTITYID                                 
WHERE A.NETBALANCE>0  
AND A.FlgAbinitio<>'Y'
AND A.FinalAssetClassAlt_Key<>6
AND A.FlgSecured='D'     
--AND isnull(SecurityValue,0)=0 
AND A.FacilityType NOT in('LC','BG','NF')
GROUP BY B.REFCUSTOMERID                  
)                                          
            
UPDATE D SET D.ApprRV=((D.NETBALANCE/A.TOTOSFUNDED)*C.TOTALSECURITY)                                       
from CTE A inner join PRO.CustomerCal B on A.REFCUSTOMERID=B.REFCUSTOMERID                             
inner join SecurityDetail C on C.REFCustomerId=B.REFCUSTOMERID                    
INNER JOIN   pro.AccountCal D on D.RefCustomerID=B.RefCustomerID                  
WHERE c.TotalSecurity>0
AND isnull(D.FlgAbinitio,'N')<>'Y'
AND D.FinalAssetClassAlt_Key<>6
AND D.FlgSecured='D'
--AND isnull(SecurityValue,0)=0 
AND D.FacilityType not  in('LC','BG','NF')
--UPDATE A SET ApprRV=NETBALANCE FROM pro.AccountCal  A
--WHERE A.FlgAbinitio<>'Y'
--AND A.FinalAssetClassAlt_Key<>6
--AND A.FlgSecured='S'


UPDATE PRO.ACLRUNNINGPROCESSSTATUS 
SET COMPLETED='Y',ERRORDATE=NULL,ERRORDESCRIPTION=NULL,COUNT=ISNULL(COUNT,0)+1
WHERE RUNNINGPROCESSNAME='SecurityAppropriation'

-----------------Added for DashBoard 04-03-2021
Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='ASSET CLASSIFICATION'

END TRY
BEGIN  CATCH

UPDATE PRO.ACLRUNNINGPROCESSSTATUS 
SET COMPLETED='N',ERRORDATE=GETDATE(),ERRORDESCRIPTION=ERROR_MESSAGE(),COUNT=ISNULL(COUNT,0)+1

WHERE RUNNINGPROCESSNAME='SecurityAppropriation'

END CATCH
   SET  NOCOUNT OFF
END












GO