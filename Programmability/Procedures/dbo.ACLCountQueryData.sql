SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[ACLCountQueryData]
AS
select convert(Date,Process_date,105)Date,SourceName,AssetClassName,count(distinct CustomerAcid)Count 
from ACL_NPA_DATA A
INNER JOIN DimAssetClassMapping B 
ON A.FinalAssetClassAlt_Key = B.AssetClassAlt_Key
where convert(Date,Process_date,105) in ('10/26/2021','10/29/2021','11/10/2021')
group by convert(Date,Process_date,105),SourceName,AssetClassName
order by convert(Date,Process_date,105),SourceName,AssetClassName
GO