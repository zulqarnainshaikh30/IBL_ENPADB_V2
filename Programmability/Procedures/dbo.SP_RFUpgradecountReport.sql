SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[SP_RFUpgradecountReport]
as

select	distinct DateofData,SourceSystemName as [Host System],count(1) count
into #AA
from	ReverseFeedData 
where AssetClass = 1
group by DateofData,SourceSystemName
order by DateofData,SourceSystemName

---------Degrade Report-------------------
SELECT DISTINCT
CONVERT(VARCHAR(20),SD.Date, 103)                  AS  [Process_date]
,SourceName as [Host System]
,count(1) count
into #BB
FROM 
PRO.AccountCal_Hist B 
INNER JOIN SYSDAYMATRIX SD ON B.EffectiveFromTimeKey=SD.TIMEKEY
INNER JOIN PRO.CustomerCal_Hist A ON A.EffectiveFromTimeKey=SD.TIMEKEY
                                     AND A.CustomerEntityID=B.CustomerEntityID

LEFT JOIN DIMSOURCEDB src        	ON B.SourceAlt_Key =src.SourceAlt_Key
                                       AND src.EffectiveToTimeKey=49999
	
LEFT JOIN DIMPRODUCT PD           	ON PD.PRODUCTALT_KEY=B.PRODUCTALT_KEY
                                       AND PD.EffectiveToTimeKey=49999

LEFT JOIN DimAssetClass A2	        ON A2.AssetClassAlt_Key=B.FinalAssetClassAlt_Key
                                       AND A2.EffectiveToTimeKey=49999

LEFT JOIN DimAcBuSegment S          ON B.ActSegmentCode=S.AcBuSegmentCode
                                       AND S.EffectiveToTimeKey=49999

LEFT JOIN DimBranch X               ON B.BranchCode = X.BranchCode
                                       AND X.EffectiveToTimeKey=49999

WHERE InitialAssetClassAlt_Key > 1 and FinalAssetClassAlt_Key = 1
AND cast(SD.Date as date) BETWEEN '07/01/2021' AND '11/01/2021'
group by CONVERT(VARCHAR(20),SD.Date, 103) ,SourceName
order by CONVERT(VARCHAR(20),SD.Date, 103) ,SourceName


select convert(Date,DateofData,105)Date,A.[Host System],A.count as UpgradeRFCount,B.count as UpgradeReportCount
,(CASE WHEN A.Count = B.Count THEN 'TRUE' ELSE 'FALSE' END) Status
from #AA A INNER JOIN   #BB B 
ON convert(Date,DateofData,105) = convert(Date,Process_date,105)  
and A.[Host System] = B.[Host System]

ORDER BY convert(Date,DateofData,105)
GO