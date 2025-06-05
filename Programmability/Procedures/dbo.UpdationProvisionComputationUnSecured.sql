SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
/*=================================          
AUTHER : SANJEEV KUMAR SHARMA          
CREATE DATE : 07-03-2017          
MODIFY DATE : 07-03-2017          
DESCRIPTION: UpdationProvisionComputationUnSecured          
--EXEC  [dbo].[UpdationProvisionComputationUnSecured] @TimeKey =1                                     
                      
===============================================*/          
CREATE PROCEDURE [dbo].[UpdationProvisionComputationUnSecured]                                      
@TimeKey int                        
AS                        
  BEGIN                        
   SET NOCOUNT ON;                        
                        
 BEGIN TRY                        
                        
--------------------------------------------<Provision Compuatation on UnSecured Portion>---------------------------------------                        
                
                   
 Update A                         
 set UnSecuredAmt = 0                         
   , ProvUnsecured = 0                         
 FROM DBO.AccountCal A                         
 INNER JOIN DimProvision_seg DP ON A.ProvisionAlt_Key = DP.ProvisionAlt_Key                         
  
                         
                        
 UPDATE A                         
 SET A.UnSecuredAmt  =     
                CASE WHEN  (((ISNULL(A.NETBALANCE,0)- ISNULL(A.SecuredAmt,0))))>0            
                THEN (((ISNULL(A.NETBALANCE,0)- ISNULL(A.SecuredAmt,0)))) ELSE 0 END            
                           
              
                          
    ,A.ProvUnsecured = ((ISNULL(A.NetBalance,0)-(ISNULL(A.SecuredAmt,0))) *(ISNULL(B.ProvisionUnSecured,0)/100))                
                
       					  
						                
 FROM DBO.ACCOUNTCAL A                        
 INNER JOIN DimProvision_seg B ON A.ProvisionAlt_Key = B.ProvisionAlt_Key                                    
 INNER JOIN DimAssetClass   C ON C.AssetClassAlt_Key=A.FinalAssetClassAlt_Key
                              
							  AND (c.EffectiveFromTimeKey<=@TimeKey and c.EffectiveToTimeKey>=@TimeKey)      
 
 UPDATE ADVACCAL SET PROVUNSECURED=0 WHERE PROVUNSECURED<0            
                 
 END TRY                        
                        
 BEGIN CATCH                        
          SELECT ERROR_MESSAGE() [ERROR MESSAGE]                        
 END CATCH                        
                        
END 
GO