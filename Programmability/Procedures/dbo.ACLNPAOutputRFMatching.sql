SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--exec ACLNPAOutputRFMatching '01/02/2022'
CREATE PROCEDURE [dbo].[ACLNPAOutputRFMatching]
@Date date
As
------------------************************AssetClassification***************-------------------------------------
select 'Asset Classification Counts' as Title
---------------------ReversefeedDegradeCount--------------
select SourceName,count(Distinct CustomerID)RFCount
from (
select SourceName,CustomerID from ACL_NPA_DAta 
where convert(date,process_date,105) = @Date-- and SourceName = 'Finacle'
and InitialAssetClassAlt_Key = 1 and FinalAssetClassAlt_Key > 1
UNION
---------------------ReversefeedUpgradeCount--------------

select SourceName,CustomerID from ACL_UPG_DATA 
where convert(date,process_date,105) = @Date-- and SourceName = 'Finacle'
and InitialAssetClassAlt_Key > 1 and FinalAssetClassAlt_Key = 1
UNION
------------------AssetClassAltkeyorNPADateChangedCount--------------
select SourceName,CustomerID from ACL_NPA_DATA 
where convert(date,process_date,105) = @Date --and SourceName = 'Finacle'
and InitialAssetClassAlt_Key > 1 and FinalAssetClassAlt_Key > 1
ANd (InitialAssetClassAlt_Key<>FinalAssetClassAlt_Key OR InitialNpaDt<>FinalNpaDt)
)x
group by SourceName


--------------****************************Degrade*********************----------------
select 'Degrade Counts' as Title
---------------------ReversefeedDegradeCount--------------
select SourceName,count(Distinct CustomerAcid)RFCount
from (
select SourceName,CustomerAcid from ACL_NPA_DAta 
where convert(date,process_date,105) = @Date-- and SourceName = 'Finacle'
and InitialAssetClassAlt_Key = 1 and FinalAssetClassAlt_Key > 1
)X
group by SourceName
---------------------ReversefeedUpgradeCount--------------
select 'Upgrade Counts' as Title

select SourceName,count(Distinct CustomerAcid)RFCount
from (
select SourceName,CustomerAcid from ACL_UPG_DATA 
where convert(date,process_date,105) = @Date-- and SourceName = 'Finacle'
and InitialAssetClassAlt_Key > 1 and FinalAssetClassAlt_Key = 1
)Y
group by SourceName
GO