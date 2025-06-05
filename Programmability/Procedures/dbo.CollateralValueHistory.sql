SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROC [dbo].[CollateralValueHistory]

AS

	BEGIN

select 
C.TaggingAlt_Key
,D.ParameterName as TaggingLevel
,C.AccountID
,C.CustomerID
,A.CollateralID
,CollateralValueatSanctioninRs
,CollateralValueasonNPAdateinRs
,CollateralValueatthetimeoflastreviewinRs
,ValuationSourceAlt_Key
,B.SourceName
,Convert(Varchar(20),ValuationDate,103) ValuationDate
,CurrentValue as LatestCollateralValueinRs
,ExpiryBusinessRule
,Periodinmonth
,Convert(Varchar(20),ValuationExpiryDate,103) ValueExpirationDate 
from Curdat.AdvSecurityValueDetail A
 inner join Curdat.AdvSecurityDetail E ON A.SecurityEntityID=E.SecurityEntityID
inner join DIMSOURCEDB b
on a.ValuationSourceAlt_Key=b.SourceAlt_Key
inner join CollateralMgmt c
on a.CollateralID=c.CollateralID
Inner Join (Select ParameterAlt_Key,ParameterName,'TaggingLevel' as Tablename 
			from DimParameter where DimParameterName='DimRatingType'
			and ParameterName not in ('Guarantor'))D
			ON C.TaggingAlt_Key=D.ParameterAlt_Key

END
GO