SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
/*==================================        
AUTHER : SANJEEV KUMAR SHARMA        
CREATE DATE : 06-03-2017        
MODIFY DATE : 06-03-2017        
DESCRIPTION : Update WriteOffAmt AccountWise       
--EXEC [dbo].[UpdateWriteOffAmt_AccountWise] @TimeKey=4445     
================================================*/        
CREATE PROCEDURE [dbo].[UpdateWriteOffAmt_AccountWise]          
@TimeKey int          
AS          
 BEGIN          
          
 BEGIN TRY          
          
--Update DBO.AccountCal Set NetBalance = 0          
          
UPDATE A           
--SET WriteOffAmount = isnull(A.Balance,0)           
SET WriteOffAmount = isnull(A.WriteOffAmount,0)      
FROM DBO.AccountCal A                
--WHERE A.WriteOff_Flag = 'Y'          

          
 END TRY          
          
 BEGIN CATCH          
          SELECT ERROR_MESSAGE() [ERROR MESSAGE]          
 END CATCH          
          
END          
          
GO