SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

 

/*=====================================

AUTHER : TRILOKI KHANNA

alter DATE : 27-11-2019

MODIFY DATE : 27-11-2019

DESCRIPTION : Updation Provision Computation UnSecured

EXEC pro.UpdationProvisionComputationUnSecured  @TIMEKEY=25410

====================================*/

 

CREATE PROCEDURE [PRO].[UpdationProvisionComputationUnSecured]

@TimeKey INT

with recompile

AS

BEGIN

   SET NOCOUNT ON

BEGIN TRY

 

                UPDATE PRO.ACCOUNTCAL  SET PROVUNSECURED=0 ,BANKPROVUNSECURED=0,RBIPROVUNSECURED=0

                UPDATE A

                                SET UNSECUREDAMT  = ( CASE WHEN  (ISNULL(A.NETBALANCE,0)-(ISNULL(A.SECUREDAMT,0)+ISNULL(A.COVERGOVGUR,0)))>0

                                                        THEN   ((ISNULL(A.NETBALANCE,0)-(ISNULL(A.SECUREDAMT,0)+ISNULL(A.COVERGOVGUR,0))))

                                                                                  ELSE 0 END )

                                ,PROVUNSECURED =  (CASE WHEN (ISNULL(A.NETBALANCE,0)-(ISNULL(A.SECUREDAMT,0)+ISNULL(A.COVERGOVGUR,0))) >0 
														THEN
																(
																	(
																		(ISNULL(A.NETBALANCE,0)-(ISNULL(A.SECUREDAMT,0)+ISNULL(A.COVERGOVGUR,0)))
																	) * 
																	ISNULL(PR.UNSECURED_PERCENTAGE,ISNULL(D.PROVISIONUNSECURED,0))
																		/100 
																)  
														ELSE 0 
														END)

                                ,BANKPROVUNSECURED =  (CASE WHEN (ISNULL(A.NETBALANCE,0)-(ISNULL(A.SECUREDAMT,0)+ISNULL(A.COVERGOVGUR,0))) >0 THEN

                                                       (((ISNULL(A.NETBALANCE,0)-(ISNULL(A.SECUREDAMT,0)+ISNULL(A.COVERGOVGUR,0)))) *  CASE WHEN D.PROVISIONNAME='Corporate Common' THEN ISNULL(A.ProvPerUnSecured,0) ELSE ISNULL(PR.UNSECURED_PERCENTAGE,ISNULL(D.PROVISIONUNSECURED,0))/100 END) ELSE 0 END)          

                                ,RBIPROVUNSECURED =  (CASE WHEN (ISNULL(A.NETBALANCE,0)-(ISNULL(A.SECUREDAMT,0)+ISNULL(A.COVERGOVGUR,0))) >0 THEN

                                                       (((ISNULL(A.NETBALANCE,0)-(ISNULL(A.SECUREDAMT,0)+ISNULL(A.COVERGOVGUR,0)))) * ISNULL(PR.UNSECURED_PERCENTAGE,ISNULL(D.RBIPROVISIONUNSECURED,0))/100) ELSE 0 END)                                                                                                

                FROM  PRO.ACCOUNTCAL A
                INNER JOIN DBO.DIMPROVISION_SEG D ON D.EFFECTIVEFROMTIMEKEY <= @TIMEKEY
                                                AND D.EFFECTIVETOTIMEKEY >= @TIMEKEY
												AND ISNULL(A.PROVISIONALT_KEY,1) = D.PROVISIONALT_KEY
				LEFT JOIN CURDAT.PROVISION_REDUCTION PR ON A.CustomerAcID=PR.CustomerACID
													AND PR.EFFECTIVEFROMTIMEKEY<=@TIMEKEY
													AND PR.EFFECTIVETOTIMEKEY>=@TIMEKEY      
                WHERE FINALASSETCLASSALT_KEY>1

 

                UPDATE A
                                SET UNSECUREDAMT  = ( CASE WHEN  (ISNULL(A.NETBALANCE,0)-(ISNULL(A.SECUREDAMT,0)+ISNULL(A.COVERGOVGUR,0)))>0

                                                        THEN   ((ISNULL(A.NETBALANCE,0)-(ISNULL(A.SECUREDAMT,0)+ISNULL(A.COVERGOVGUR,0))))

                                                                                  ELSE 0 END )
                                ,PROVUNSECURED =  (CASE WHEN (ISNULL(A.NETBALANCE,0)-(ISNULL(A.SECUREDAMT,0)+ISNULL(A.COVERGOVGUR,0))) >0 THEN

                                                          (((ISNULL(A.NETBALANCE,0)-(ISNULL(A.SECUREDAMT,0)+ISNULL(A.COVERGOVGUR,0)))) *  CASE WHEN D.PROVISIONNAME='Corporate Common' THEN ISNULL(A.ProvPerUnSecured,0) ELSE ISNULL( D.PROVISIONUNSECURED,0) /100 END)  ELSE 0 END)
                                ,BANKPROVUNSECURED =  (CASE WHEN (ISNULL(A.NETBALANCE,0)-(ISNULL(A.SECUREDAMT,0)+ISNULL(A.COVERGOVGUR,0))) >0 THEN

                                                       (((ISNULL(A.NETBALANCE,0)-(ISNULL(A.SECUREDAMT,0)+ISNULL(A.COVERGOVGUR,0)))) *  CASE WHEN D.PROVISIONNAME='Corporate Common' THEN ISNULL(A.ProvPerUnSecured,0) ELSE ISNULL(D.PROVISIONUNSECURED,0)/100 END) ELSE 0 END)          

                                ,RBIPROVUNSECURED =  (CASE WHEN (ISNULL(A.NETBALANCE,0)-(ISNULL(A.SECUREDAMT,0)+ISNULL(A.COVERGOVGUR,0))) >0 THEN

                                                       (((ISNULL(A.NETBALANCE,0)-(ISNULL(A.SECUREDAMT,0)+ISNULL(A.COVERGOVGUR,0)))) * ISNULL(D.RBIPROVISIONUNSECURED,0)/100) ELSE 0 END)                                                                                                
                FROM  PRO.ACCOUNTCAL A
                INNER JOIN DBO.DimProvision_SegStd D ON D.EFFECTIVEFROMTIMEKEY <= @TIMEKEY
                                                AND D.EFFECTIVETOTIMEKEY >= @TIMEKEY
                                                AND ISNULL(A.PROVISIONALT_KEY,1) = D.PROVISIONALT_KEY
                WHERE FinalAssetClassAlt_Key=1

 

 

--------update PRO.ACCOUNTCAL set SecuredAmt=NetBalance from PRO.ACCOUNTCAL

--------where FinalAssetClassAlt_Key=1

--------and isnull(SecurityValue,0)>0

--------and (isnull(SecuredAmt,0)=0)

--------and SecurityValue>NetBalance

 

--------update PRO.ACCOUNTCAL set SecuredAmt=NetBalance from PRO.ACCOUNTCAL

--------where FinalAssetClassAlt_Key=1

--------and isnull(NetBalance,0)>0 and isnull(SecurityValue,0)>0 and isnull(SecuredAmt,0)=0

--------and isnull(SecurityValue,0)>=isnull(NetBalance,0)

 

 

--------update PRO.ACCOUNTCAL set SecuredAmt=SecurityValue from PRO.ACCOUNTCAL

--------where FinalAssetClassAlt_Key=1

--------and isnull(NetBalance,0)>0 and isnull(SecurityValue,0)>0 and isnull(SecuredAmt,0)=0

--------and isnull(SecurityValue,0)<=isnull(NetBalance,0)

 

 

 

--------update PRO.ACCOUNTCAL set UnSecuredAmt=NetBalance-(SecuredAmt+UnSecuredAmt)

-------- from PRO.ACCOUNTCAL

--------where FinalAssetClassAlt_Key=1

--------and isnull(NetBalance,0)>0 and isnull(NetBalance,0)-(isnull(SecuredAmt,0)+isnull(UnSecuredAmt,0))<>0

 

 

   UPDATE PRO.ACCOUNTCAL SET UNSECUREDAMT=0 WHERE ISNULL(UNSECUREDAMT,0)<=0

   UPDATE PRO.ACCOUNTCAL SET PROVUNSECURED=0 WHERE ISNULL(PROVUNSECURED,0)<=0

   UPDATE PRO.ACCOUNTCAL SET BANKPROVUNSECURED=0 WHERE ISNULL(BANKPROVUNSECURED,0)<=0

   UPDATE PRO.ACCOUNTCAL SET RBIPROVUNSECURED=0 WHERE ISNULL(RBIPROVUNSECURED,0)<=0

 

   -----------------Added for DashBoard 04-03-2021

--Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='ASSET CLASSIFICATION'

 

UPDATE PRO.ACLRUNNINGPROCESSSTATUS

                SET COMPLETED='Y',ERRORDATE=NULL,ERRORDESCRIPTION=NULL,COUNT=ISNULL(COUNT,0)+1

                WHERE RUNNINGPROCESSNAME='UpdationProvisionComputationUnSecured'

 

END TRY

BEGIN  CATCH

 

                UPDATE PRO.ACLRUNNINGPROCESSSTATUS

                SET COMPLETED='N',ERRORDATE=GETDATE(),ERRORDESCRIPTION=ERROR_MESSAGE(),COUNT=ISNULL(COUNT,0)+1

                WHERE RUNNINGPROCESSNAME='UpdationProvisionComputationUnSecured'

END CATCH

  SET NOCOUNT OFF

END

 

 

 

 

 

 

 

 

 

 

GO