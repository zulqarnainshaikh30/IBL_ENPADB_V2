SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[NPAOpenDatelogic]
AS
BEGIN

select CustomerAcid,iNITIALASSETCLASSaLT_KEY,fINALASSETCLASSALT_KEY,MonthFirstDate as Date
 from pro.Accountcal_hist A INNER JOIN Sysdatamatrix b on A.EffectivefromTimekey = b.Timekey 
 where CustomerAcid in ('909000187280','909000187192')
 order by EffectivefromTimeKey
 
 
 SELECT distinct DateofData,RefCustomerId as customerID,CustomerAcid as AccountNo,AcOpenDt,finalnpadt,NPADate as ReverseFeednpadate
  FROM  pro.Accountcal A 
 INNER JOIN REVERSEFEEDDATA B 
 ON A.CustomerAcid = B.Accountid 
 where
  customeracid in ('809002870846','809002242735','809002100530','809002876909', '809002932575','809002927991') --in  (809002870846)('909000125271','909000126270','909000125800','909000126100','909000124759','909000126526')
 and cast(AcOpenDt as date) > cast(NPADate as date) 
 
 select SourceAlt_Key,RefCustomerId as customerID,CustomerAcid as AccountNo,AcOpenDt,
 finalnpadt,EffectiveFromTimeKey,EffectiveToTimekey ,initialassetclassalt_key,finalassetclassalt_key
 from [pro].Accountcal 
 where cast(AcOpenDt as date) > cast(finalnpadt as date)  and SourceAlt_Key  = 1
 and Effectivefromtimekey > 26128 and customeracid in ('909000125271','909000126270','909000125800','909000126100','909000124759','909000126526')
 --and dateofdata='2021-07-15'  customeracid in ('809002987735','809002965382','809002964903')
 
 END
GO