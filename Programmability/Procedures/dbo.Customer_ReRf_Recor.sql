SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Customer_ReRf_Recor]
AS 
BEGIN

begin tran
UPDATE ReverseFeedDataInsertSync_Customer
SET UpgradeDate=ProcessDate 
WHERE 
FinalAssetClassAlt_Key=1 AND
(UpgradeDate IS NULL OR
 UpgradeDate='1900-01-01' )

 UPDATE ReverseFeedDataInsertSync_Customer
SET UpgradeDate=Null 
WHERE 
FinalAssetClassAlt_Key>1



 commit
END

GO