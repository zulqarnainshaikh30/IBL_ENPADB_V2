SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
  
          
/*==============================          
AUTHER : SANJEEV KUMAR SHARMA          
CREATE DATE : 07-03-2017          
MODIFY DATE : 07-03-2017          
DESCRIPTION : UPDATE TOTAL PROVISION          
--EXEC [dbo].[UpdationTotalProvision] @TimeKey =1              
=========================================*/          
            
CREATE PROCEDURE [dbo].[UpdationTotalProvision]              
@TimeKey int                  
AS              
  BEGIN              
   SET NOCOUNT ON;              
              
 BEGIN TRY              


 UPDATE  DBO.AccountCal              
 SET TotalProvision = 0         
     
   UPDATE A SET A.DFVAMT  =(CASE WHEN ((ISNULL(A.Provsecured,0) + ISNULL(A.ProvUnsecured,0) +        
          (ISNULL(A.DFVAmt,0) ))) > A.NetBalance        
          THEN (A.NetBalance-(ISNULL(A.Provsecured,0) + ISNULL(A.ProvUnsecured,0)))      
          END)      
                
       FROm  DBO.AccountCal A      
             
              
 UPDATE A                   
 SET TotalProvision  =(ISNULL(A.Provsecured,0) + ISNULL(A.ProvUnsecured,0) +  (ISNULL(A.DFVAmt,0)) + (ISNULL(A.AddlProvision,0)) )                      
                           
 FROM  DBO.AccountCal    A             
           
   
UPDATE A SET TotalProv=B.TotalProvision

FROM dbo.AdvAcBalanceDetail A INNER JOIN DBO.AccountCal B ON A.AccountEntityId=B.AccountEntityID
AND (A.EffectiveFromTimeKey<=@TIMEKEY AND A.EffectiveToTimeKey>=@TIMEKEY)
               
              
 END TRY              
              
 BEGIN CATCH              
          SELECT ERROR_MESSAGE() [ERROR MESSAGE]              
 END CATCH              
              
END 

GO