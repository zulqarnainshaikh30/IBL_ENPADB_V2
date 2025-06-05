SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[DegUpgFinalcountQuery]
AS
BEGIN

------Main Table Degrade Count-----------

select DegDate,count(1)Count from [Pro].AccountCal_Hist A
INNER JOIN [Pro].CustomerCal_Hist B 
ON A.CustomerEntityID = B.CustomerEntityID 
and A.EffectiveFromTimeKey = B.EffectiveFromTimeKey
where FinalAssetClassAlt_Key > 1 
and InitialAssetClassAlt_Key = 1 
and DegDate  between '2021-07-01' and  '2021-07-31'
group by DegDate
order by DegDate


------Main Table Upgrade Count-----------
select UpgDate,count(1)Count from [Pro].AccountCal_Hist A
INNER JOIN [Pro].CustomerCal_Hist B 
ON A.CustomerEntityID = B.CustomerEntityID 
and A.EffectiveFromTimeKey = B.EffectiveFromTimeKey
where FinalAssetClassAlt_Key > 1 
and InitialAssetClassAlt_Key = 1 
and UpgDate  between '2021-07-01' and  '2021-07-31'
group by UpgDate
order by UpgDate

/*TEST BRACH*/

---------------------Degrade report
exec [dbo].[rpt-026] '01/08/2021','26/08/2021',1
---------------------Upgrade report

exec [dbo].[rpt-027] '01/08/2021','26/08/2021',1

END
GO