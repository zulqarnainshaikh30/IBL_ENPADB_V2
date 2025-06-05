SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[SP_Curqtrdata]
AS

select A.UCIF_ID,B.RefCustomerID as CustomerID,CustomerName,CustomerAcID,Balance,ISNULL(CurQtrInt,0)CurQtrInt,ISNULL(CurQtrCredit,0)CurQtrCredit,
ISNULL(CurQtrInt,0) - ISNULL(CurQtrCredit,0) as Difference,DebitSinceDt
from PRO.CUSTOMERCAL A INNER JOIN PRO.ACCOUNTCAL B 
ON A.CustomerEntityID = B.CustomerEntityID 
INNER JOIN DimProduct C ON B.ProductAlt_Key = C.ProductAlt_Key 
where SchemeType = 'ODA'
GO