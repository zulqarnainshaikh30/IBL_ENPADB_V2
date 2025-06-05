SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/*==================================      
AUTHER : SANJEEV KUMAR SHARMA      
CREATE DATE : 25-03-2017      
MODIFY DATE : 25-03-2017      
DESCRIPTION : UPDATE  USER ASSET CLASS AND TXN ASSET CLASS AND SYSTEMASSETCLASS      
--EXEC [PRO].[UpdateAssetClassForProvision]    @Timekey=4463      
==========================================*/      
CREATE PROCEDURE [PRO].[UpdateAssetClassForProvision]      
@Timekey INT      
AS      
BEGIN      
BEGIN TRY      
/*----------******UPDATING CUSTOMERASSET_CLASS TO ALL ACCOUNTS OF the CUSTOMER     
                  FOR PROVISION  COMPUTATION AT ACCOUNT LEVEL****----------------------*/      
UPDATE B      
SET   b.InitialAssetClassAlt_Key=a.SrcAssetClassAlt_Key
      ,b.FinalAssetClassAlt_Key=a.SrcAssetClassAlt_Key      
         
FROM pro.CustomerCal A INNER JOIN pro.AccountCal B       
ON A.CustomerEntityID=B.CustomerEntityID      
      
END TRY       
BEGIN CATCH      
 SELECT 'ERROR PROCEDURE :'+ERROR_PROCEDURE()+'ERROR MESSAGE :'+ERROR_MESSAGE()      
END CATCH      
      
END 

GO