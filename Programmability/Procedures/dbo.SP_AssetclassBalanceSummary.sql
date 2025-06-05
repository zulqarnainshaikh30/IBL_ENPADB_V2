SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--exec [dbo].[SP_AssetclassBalanceSummary] '11/24/2021'
CREATE PROCEDURE [dbo].[SP_AssetclassBalanceSummary]
@Date date
AS



Declare @Timekey int = (select Timekey from Automate_Advances where Date = @Date)

select 'Summary Report on Asset Classification as on (' + CONVERT(Varchar(20),cast(@Date as date)) + ')'

select @Date as DateofData,D.AssetClassAlt_Key,
C.SourceName,D.AssetClassShortName ,B.CustomerAcID,ISNULL(B.Balance,0)Balance, ISNULL(B.PrincOutStd,0)PrincOutStd
into #Account
from PRO.AccountCAL_Hist B  with (Nolock)
--ON A.CustomerEntityID = B.CustomerEntityID
LEFT JOIN DIMSOURCEDB C 
ON B.SourceAlt_Key = C.SourceAlt_Key	 and C.EffectiveToTimeKey = 49999
LEFT joiN DimAssetClass D  ON B.FinalAssetClassAlt_Key = D.AssetClassAlt_Key
WHERE  B.EffectiveFromTimeKey <= @Timekey and B.EffectiveToTimeKey >= @Timekey 


(select @Date as DateofData,9 as AssetClassAlt_Key,C.SourceName AS [Source System],'TWO' as AssetClass,
count(distinct B.CustomerAcID) as [Number of Accounts],
sum(ISNULL(B.Balance,0)) as [Balance Outstanding],
sum(ISNULL(B.PrincOutStd,0))  as [Principal Outstanding]
into #TWO
from  PRO.AccountCal_Hist B  with(nolock)
INNER JOIN Pro.Customercal_Hist A  with(nolock)
ON A.CustomerEntityID = B.CustomerEntityID
INNER JOIN DIMSOURCEDB C 
ON B.SourceAlt_Key = C.SourceAlt_Key	 and C.EffectiveToTimeKey = 49999
inner joiN DimAssetClass D  ON B.FinalAssetClassAlt_Key = D.AssetClassAlt_Key
WHERE  B.EffectiveFromTimeKey <= @Timekey and B.EffectiveToTimeKey >= @Timekey
AND		A.EffectiveFromTimeKey <= @Timekey and A.EffectiveToTimeKey >= @Timekey
AND		ISNULL(WriteoffAmount,0) != 0
group by C.SourceName)
UNION
select @Date,9,A.SourceName,'TWO',0,0,0
from DIMSOURCEDB A 
INNER JOIN 
(select distinct SourceAlt_Key from DIMSOURCEDB
Except
select distinct SourceAlt_Key from Pro.Accountcal_Hist where EffectiveFromTimekey <= @Timekey and EffectiveToTImekey >= @TImekey and ISNULL(WriteoffAmount,0) != 0  
)B 
 
ON A.SourceALt_Key = B.SourceAlt_Key

select distinct CustomerACID 
into #ACID from Pro.Accountcal_Hist 
where EffectiveFromTimekey <= @Timekey and EffectiveToTImekey >= @TImekey and ISNULL(WriteoffAmount,0) != 0

--------------Finacle--------




select DateofData,[Source System],AssetClass,[Number of Accounts],[Balance Outstanding]
,[Principal Outstanding]  from (
select  DateofData,AssetClassAlt_Key,
SourceName AS [Source System],AssetClassShortName as AssetClass,count(distinct CustomerAcID) as [Number of Accounts],sum(ISNULL(Balance,0)) as [Balance Outstanding],sum(ISNULL(PrincOutStd,0))  as [Principal Outstanding]
from #Account 
where SourceName = 'Finacle' 
and  CustomerACID not in (select * from #ACID)
group by SourceName,AssetClassShortName,AssetClassAlt_Key,DateofData
UNION
SELECT @Date,AssetClassAlt_Key,'Finacle',AssetClassShortName,0,0,0
FROM 
(
SELECT DISTINCT AssetClassAlt_key,AssetClassShortName FROM DimAssetClass 
WHERE EffectiveToTimeKey = 49999
EXCEPT
SELECT DISTINCT AssetClassAlt_key,AssetClassShortName 
FROM #Account
WHERE SourceName = 'Finacle' 
and  CustomerAcID not in (select * from #ACID)
)p
UNION
select * from #TWO where [Source System] = 'Finacle' 
UNION 
select DateofData,10 as AssetClassAlt_Key,SourceName AS [Source System],
'Total' as AssetClass,
count(distinct CustomerAcID) as [Number of Accounts],
sum(ISNULL(Balance,0)) as [Balance Outstanding],
sum(ISNULL(PrincOutStd,0))  as [Principal Outstanding]
from #Account
where SourceName= 'Finacle'  
Group by SourceName,DateofData
)P 
order by AssetClassAlt_Key


--------------Indus--------




select DateofData,[Source System],AssetClass,[Number of Accounts],[Balance Outstanding]
,[Principal Outstanding] from (
select  DateofData,AssetClassAlt_Key,
SourceName AS [Source System],AssetClassShortName as AssetClass,count(distinct CustomerAcID) as [Number of Accounts],sum(ISNULL(Balance,0)) as [Balance Outstanding],sum(ISNULL(PrincOutStd,0))  as [Principal Outstanding]
from #Account 
where SourceName = 'Indus' 
and  CustomerACID not in (select * from #ACID)
group by SourceName,AssetClassShortName,AssetClassAlt_Key,DateofData
UNION
SELECT @Date,AssetClassAlt_Key,'Indus',AssetClassShortName,0,0,0
FROM 
(
SELECT DISTINCT AssetClassAlt_key,AssetClassShortName FROM DimAssetClass 
WHERE EffectiveToTimeKey = 49999
EXCEPT
SELECT DISTINCT AssetClassAlt_key,AssetClassShortName 
FROM #Account
WHERE SourceName = 'Indus' 
and  CustomerAcID not in (select * from #ACID))p
UNION
select * from #TWO where [Source System] = 'Indus' 
UNION 
select DateofData,10 as AssetClassAlt_Key,SourceName AS [Source System],
'Total' as AssetClass,
count(distinct CustomerAcID) as [Number of Accounts],
sum(ISNULL(Balance,0)) as [Balance Outstanding],
sum(ISNULL(PrincOutStd,0))  as [Principal Outstanding]
from #Account
where SourceName= 'Indus'  
Group by SourceName,DateofData
)P 
order by AssetClassAlt_Key


--------------ECBF--------




select DateofData,[Source System],AssetClass,[Number of Accounts],[Balance Outstanding]
,[Principal Outstanding] from (
select  DateofData,AssetClassAlt_Key,
SourceName AS [Source System],AssetClassShortName as AssetClass,count(distinct CustomerAcID) as [Number of Accounts],sum(ISNULL(Balance,0)) as [Balance Outstanding],sum(ISNULL(PrincOutStd,0))  as [Principal Outstanding]
from #Account 
where SourceName = 'ECBF' 
and  CustomerACID not in (select * from #ACID)
group by SourceName,AssetClassShortName,AssetClassAlt_Key,DateofData
UNION
SELECT @Date,AssetClassAlt_Key,'ECBF',AssetClassShortName,0,0,0
FROM 
(
SELECT DISTINCT AssetClassAlt_key,AssetClassShortName FROM DimAssetClass 
WHERE EffectiveToTimeKey = 49999
EXCEPT

SELECT DISTINCT AssetClassAlt_key,AssetClassShortName 
FROM #Account
WHERE SourceName = 'ECBF' 
and  CustomerAcID not in (select * from #ACID))p
UNION
select * from #TWO where [Source System] = 'ECBF' 
UNION 
select DateofData,10 as AssetClassAlt_Key,SourceName AS [Source System],
'Total' as AssetClass,
count(distinct CustomerAcID) as [Number of Accounts],
sum(ISNULL(Balance,0)) as [Balance Outstanding],
sum(ISNULL(PrincOutStd,0))  as [Principal Outstanding]
from #Account
where SourceName= 'ECBF'  
Group by SourceName,DateofData
)P 
order by AssetClassAlt_Key


--------------Mifin--------




select DateofData,[Source System],AssetClass,[Number of Accounts],[Balance Outstanding]
,[Principal Outstanding] from (
select  DateofData,AssetClassAlt_Key,
SourceName AS [Source System],AssetClassShortName as AssetClass,count(distinct CustomerAcID) as [Number of Accounts],sum(ISNULL(Balance,0)) as [Balance Outstanding],sum(ISNULL(PrincOutStd,0))  as [Principal Outstanding]
from #Account 
where SourceName = 'Mifin' 
and  CustomerACID not in (select * from #ACID)
group by SourceName,AssetClassShortName,AssetClassAlt_Key,DateofData
UNION
SELECT @Date,AssetClassAlt_Key,'Mifin',AssetClassShortName,0,0,0
FROM 
(
SELECT DISTINCT AssetClassAlt_key,AssetClassShortName FROM DimAssetClass 
WHERE EffectiveToTimeKey = 49999
EXCEPT

SELECT DISTINCT AssetClassAlt_key,AssetClassShortName 
FROM #Account
WHERE SourceName = 'Mifin' 
and  CustomerAcID not in (select * from #ACID))p
UNION
select * from #TWO where [Source System] = 'Mifin' 
UNION 
select DateofData,10 as AssetClassAlt_Key,SourceName AS [Source System],
'Total' as AssetClass,
count(distinct CustomerAcID) as [Number of Accounts],
sum(ISNULL(Balance,0)) as [Balance Outstanding],
sum(ISNULL(PrincOutStd,0))  as [Principal Outstanding]
from #Account
where SourceName= 'Mifin'  
Group by SourceName,DateofData
)P 
order by AssetClassAlt_Key


--------------Ganaseva--------




select DateofData,[Source System],AssetClass,[Number of Accounts],[Balance Outstanding]
,[Principal Outstanding] from (
select  DateofData,AssetClassAlt_Key,
SourceName AS [Source System],AssetClassShortName as AssetClass,count(distinct CustomerAcID) as [Number of Accounts],sum(ISNULL(Balance,0)) as [Balance Outstanding],sum(ISNULL(PrincOutStd,0))  as [Principal Outstanding]
from #Account 
where SourceName = 'Ganaseva' 
and  CustomerACID not in (select * from #ACID)
group by SourceName,AssetClassShortName,AssetClassAlt_Key,DateofData
UNION
SELECT @Date,AssetClassAlt_Key,'Ganaseva',AssetClassShortName,0,0,0
FROM 
(
SELECT DISTINCT AssetClassAlt_key,AssetClassShortName FROM DimAssetClass 
WHERE EffectiveToTimeKey = 49999
EXCEPT

SELECT DISTINCT AssetClassAlt_key,AssetClassShortName 
FROM #Account
WHERE SourceName = 'Ganaseva' 
and  CustomerAcID not in (select * from #ACID))p
UNION
select * from #TWO where [Source System] = 'Ganaseva' 
UNION 
select DateofData,10 as AssetClassAlt_Key,SourceName AS [Source System],
'Total' as AssetClass,
count(distinct CustomerAcID) as [Number of Accounts],
sum(ISNULL(Balance,0)) as [Balance Outstanding],
sum(ISNULL(PrincOutStd,0))  as [Principal Outstanding]
from #Account
where SourceName= 'Ganaseva'  
Group by SourceName,DateofData
)P 
order by AssetClassAlt_Key


--------------Visionplus--------




select DateofData,[Source System],AssetClass,[Number of Accounts],[Balance Outstanding]
,[Principal Outstanding] from (
select  DateofData,AssetClassAlt_Key,
SourceName AS [Source System],AssetClassShortName as AssetClass,count(distinct CustomerAcID) as [Number of Accounts],sum(ISNULL(Balance,0)) as [Balance Outstanding],sum(ISNULL(PrincOutStd,0))  as [Principal Outstanding]
from #Account 
where SourceName = 'Visionplus' 
and  CustomerACID not in (select * from #ACID)
group by SourceName,AssetClassShortName,AssetClassAlt_Key,DateofData
UNION
SELECT @Date,AssetClassAlt_Key,'Visionplus',AssetClassShortName,0,0,0
FROM 
(
SELECT DISTINCT AssetClassAlt_key,AssetClassShortName FROM DimAssetClass 
WHERE EffectiveToTimeKey = 49999
EXCEPT

SELECT DISTINCT AssetClassAlt_key,AssetClassShortName 
FROM #Account
WHERE SourceName = 'VisionPlus' 
and  CustomerAcID not in (select * from #ACID))p
UNION
select * from #TWO where [Source System] = 'Visionplus' 
UNION 
select DateofData,10 as AssetClassAlt_Key,SourceName AS [Source System],
'Total' as AssetClass,
count(distinct CustomerAcID) as [Number of Accounts],
sum(ISNULL(Balance,0)) as [Balance Outstanding],
sum(ISNULL(PrincOutStd,0))  as [Principal Outstanding]
from #Account
where SourceName= 'Visionplus'  
Group by SourceName,DateofData
)P 
order by AssetClassAlt_Key


--------------Metagrid--------

select DateofData,[Source System],AssetClass,[Number of Accounts],[Balance Outstanding]
,[Principal Outstanding] from (
select  DateofData,AssetClassAlt_Key,
SourceName AS [Source System],AssetClassShortName as AssetClass,count(distinct CustomerAcID) as [Number of Accounts],sum(ISNULL(Balance,0)) as [Balance Outstanding],sum(ISNULL(PrincOutStd,0))  as [Principal Outstanding]
from #Account 
where SourceName = 'Metagrid' 
and  CustomerACID not in (select * from #ACID)
group by SourceName,AssetClassShortName,AssetClassAlt_Key,DateofData
UNION
SELECT @Date,AssetClassAlt_Key,'Metagrid',AssetClassShortName,0,0,0
FROM 
(
SELECT DISTINCT AssetClassAlt_key,AssetClassShortName FROM DimAssetClass 
WHERE EffectiveToTimeKey = 49999
EXCEPT

SELECT DISTINCT AssetClassAlt_key,AssetClassShortName 
FROM #Account
WHERE SourceName = 'MetaGRID' 
and  CustomerAcID not in (select * from #ACID))p
UNION
select * from #TWO where [Source System] = 'Metagrid' 
UNION 
select DateofData,10 as AssetClassAlt_Key,SourceName AS [Source System],
'Total' as AssetClass,
count(distinct CustomerAcID) as [Number of Accounts],
sum(ISNULL(Balance,0)) as [Balance Outstanding],
sum(ISNULL(PrincOutStd,0))  as [Principal Outstanding]
from #Account
where SourceName= 'Metagrid'  
Group by SourceName,DateofData
)P 
order by AssetClassAlt_Key


--------------ALL--------

select DateofData,'ALL' [Source System],AssetClass,[Number of Accounts],[Balance Outstanding]
,[Principal Outstanding] 
from (
select  DateofData,AssetClassAlt_Key,AssetClassShortName as AssetClass,count(distinct CustomerAcID) as [Number of Accounts],sum(ISNULL(Balance,0)) as [Balance Outstanding],sum(ISNULL(PrincOutStd,0))  as [Principal Outstanding]
from #Account 
where  CustomerACID not in (select * from #ACID)
group by AssetClassShortName,AssetClassAlt_Key,DateofData

		UNION
		SELECT @Date,AssetClassAlt_Key,
		AssetClassShortName,0,0,0
		FROM 
		(
		SELECT DISTINCT AssetClassAlt_key,AssetClassShortName FROM DimAssetClass 
		WHERE EffectiveToTimeKey = 49999
		EXCEPT
		
SELECT DISTINCT AssetClassAlt_key,AssetClassShortName 
FROM #Account
WHERE   CustomerAcID not in (select * from #ACID))p
		UNION
		select 
		DateofData,AssetClassAlt_Key,AssetClass,sum([Number of Accounts]),sum([Balance Outstanding]),sum([Principal Outstanding]) from #TWO group by DateofData,AssetClassAlt_Key,AssetClass
		UNION 
		select DateofData,10 as AssetClassAlt_Key,
		'Total' as AssetClass,
		count(distinct CustomerAcID) as [Number of Accounts],
		sum(ISNULL(Balance,0)) as [Balance Outstanding],
		sum(ISNULL(PrincOutStd,0))  as [Principal Outstanding]
		from #Account
		Group by DateofData
)P 
order by AssetClassAlt_Key




GO