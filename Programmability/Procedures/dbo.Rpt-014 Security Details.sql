SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



/*
CREATE BY		:	Baijayanti
CREATE DATE	    :	18-08-2022
DISCRIPTION		:   Security Erosion Report
*/

 Create PROC [dbo].[Rpt-014 Security Details]  
  @TimeKey AS INT
 
AS 

--DECLARE 
-- @TimeKey AS INT=26694
 
 
 SELECT
AccountEntityId,
ASVD.ValuationDate,
ASVD.ValuationExpiryDate
,SecurityType 
FROM AdvSecurityDetail  ASD
INNER JOIN AdvSecurityValueDetail  ASVD      ON  ASD.SecurityEntityID=ASVD.SecurityEntityID              
                                                 AND  ASD.EffectiveFromTimeKey<=@TimeKey AND  ASD.EffectiveToTimeKey>=@TimeKey
												 AND  ASVD.EffectiveFromTimeKey<=@TimeKey AND  ASVD.EffectiveToTimeKey>=@TimeKey 

OPTION(RECOMPILE)
GO