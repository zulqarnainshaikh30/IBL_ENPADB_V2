SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[SP_FinalAssetclasscountquery]
AS
BEGIN
	  		--------------Finacle
			
			Select Convert(Varchar(10),DateofData,105)DateofData,SourceSystemName,COUNT(*)AssetClassCount 
			from(
			Select 'FinacleAssetClassification' AS TableName, SourceSystemName,DateofData,A.CustomerID+'|'+A.UCIF_ID +'|'+ E.AssetClassShortNameEnum+'|'+E.AssetClassName+'|'+ Convert(Varchar(10),DateofData,105) +'|'+ ISNULL(Convert(Varchar(10),A.NPADate,105),'')  as DataUtility from ReverseFeedData A
			Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
			Inner JOIN DimAssetClass E ON A.AssetSubClass=E.SrcSysClassCode
			 where B.SourceName='Finacle'
			 

			 UNION

			 Select 'FinacleAssetClassification' AS TableName,SourceName,MonthLastDate, A.RefCustomerID+'|'+A.UCIF_ID +'|'+ E.AssetClassShortNameEnum+'|'+E.AssetClassName+'|'+ Convert(Varchar(10),MonthLastDate,105) +'|'+ ISNULL(Convert(Varchar(10),A.FinalNpaDt,105),'')  as DataUtility 
			 from Pro.AccountCal_hist A
			Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
			Inner JOIN DimAssetClass E ON A.FinalAssetClassAlt_Key=E.AssetClassAlt_Key
			inner join SysDataMatrix F ON a.EffectiveFromTimeKey = F.TimeKey
			 where B.SourceName='Finacle'
			 And A.InitialAssetClassAlt_Key>1 And A.FinalAssetClassAlt_Key>1 ANd A.InitialAssetClassAlt_Key<>A.FinalAssetClassAlt_Key
			 )A Group By DateofData,SourceSystemName 

			 UNION
	  		--------------Indus
			
			Select Convert(Varchar(10),DateofData,105)DateofData,SourceSystemName,COUNT(*)IndusAssetcount 
			from(
			Select 'IndusAssetClassification' AS TableName, SourceSystemName,DateofData,A.CustomerID+'|'+A.UCIF_ID +'|'+ E.AssetClassShortNameEnum+'|'+E.AssetClassName+'|'+ Convert(Varchar(10),DateofData,105) +'|'+ ISNULL(Convert(Varchar(10),A.NPADate,105),'')  as DataUtility from ReverseFeedData A
			Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
			Inner JOIN DimAssetClass E ON A.AssetSubClass=E.SrcSysClassCode
			 where B.SourceName='Indus'
			 

			 UNION

			 Select 'IndusAssetClassification' AS TableName,SourceName,MonthLastDate, A.RefCustomerID+'|'+A.UCIF_ID +'|'+ E.AssetClassShortNameEnum+'|'+E.AssetClassName+'|'+ Convert(Varchar(10),MonthLastDate,105) +'|'+ ISNULL(Convert(Varchar(10),A.FinalNpaDt,105),'')  as DataUtility 
			 from Pro.AccountCal_hist A
			Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
			Inner JOIN DimAssetClass E ON A.FinalAssetClassAlt_Key=E.AssetClassAlt_Key
			inner join SysDataMatrix F ON a.EffectiveFromTimeKey = F.TimeKey
			 where B.SourceName='Indus'
			 And A.InitialAssetClassAlt_Key>1 And A.FinalAssetClassAlt_Key>1 ANd A.InitialAssetClassAlt_Key<>A.FinalAssetClassAlt_Key
			 )A Group By DateofData,SourceSystemName 

			 UNION
	  		--------------MiFiN
			
			Select Convert(Varchar(10),DateofData,105)DateofData,SourceSystemName,COUNT(*)MiFinAssetcount 
			from(
			Select 'MiFinAssetClassification' AS TableName, SourceSystemName,DateofData,A.CustomerID+'|'+A.UCIF_ID +'|'+ E.AssetClassShortNameEnum+'|'+E.AssetClassName+'|'+ Convert(Varchar(10),DateofData,105) +'|'+ ISNULL(Convert(Varchar(10),A.NPADate,105),'')  as DataUtility from ReverseFeedData A
			Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
			Inner JOIN DimAssetClass E ON A.AssetSubClass=E.SrcSysClassCode
			 where B.SourceName='MiFin'
			 

			 UNION

			 Select 'MiFinAssetClassification' AS TableName,SourceName,MonthLastDate, A.RefCustomerID+'|'+A.UCIF_ID +'|'+ E.AssetClassShortNameEnum+'|'+E.AssetClassName+'|'+ Convert(Varchar(10),MonthLastDate,105) +'|'+ ISNULL(Convert(Varchar(10),A.FinalNpaDt,105),'')  as DataUtility 
			 from Pro.AccountCal_hist A
			Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
			Inner JOIN DimAssetClass E ON A.FinalAssetClassAlt_Key=E.AssetClassAlt_Key
			inner join SysDataMatrix F ON a.EffectiveFromTimeKey = F.TimeKey
			 where B.SourceName='MiFin'
			 And A.InitialAssetClassAlt_Key>1 And A.FinalAssetClassAlt_Key>1 ANd A.InitialAssetClassAlt_Key<>A.FinalAssetClassAlt_Key
			 )A Group By DateofData,SourceSystemName 

			 UNION
	  		--------------VisionPlus
			
			Select Convert(Varchar(10),DateofData,105)DateofData,SourceSystemName,COUNT(*)VisionPlusAssetcount 
			from(
			Select 'VisionPlusAssetClassification' AS TableName, SourceSystemName,DateofData,A.CustomerID+'|'+A.UCIF_ID +'|'+ E.AssetClassShortNameEnum+'|'+E.AssetClassName+'|'+ Convert(Varchar(10),DateofData,105) +'|'+ ISNULL(Convert(Varchar(10),A.NPADate,105),'')  as DataUtility from ReverseFeedData A
			Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
			Inner JOIN DimAssetClass E ON A.AssetSubClass=E.SrcSysClassCode
			 where B.SourceName='VisionPlus'
			 

			 UNION

			 Select 'VisionPlusAssetClassification' AS TableName,SourceName,MonthLastDate, A.RefCustomerID+'|'+A.UCIF_ID +'|'+ E.AssetClassShortNameEnum+'|'+E.AssetClassName+'|'+ Convert(Varchar(10),MonthLastDate,105) +'|'+ ISNULL(Convert(Varchar(10),A.FinalNpaDt,105),'')  as DataUtility 
			 from Pro.AccountCal_hist A
			Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
			Inner JOIN DimAssetClass E ON A.FinalAssetClassAlt_Key=E.AssetClassAlt_Key
			inner join SysDataMatrix F ON a.EffectiveFromTimeKey = F.TimeKey
			 where B.SourceName='VisionPlus'
			 And A.InitialAssetClassAlt_Key>1 And A.FinalAssetClassAlt_Key>1 ANd A.InitialAssetClassAlt_Key<>A.FinalAssetClassAlt_Key
			 )A Group By DateofData,SourceSystemName 

			 UNION
	  		--------------Ganaseva
			
			Select Convert(Varchar(10),DateofData,105)DateofData,SourceSystemName,COUNT(*)IndusAssetcount 
			from(
			Select 'GanasevaAssetClassification' AS TableName, SourceSystemName,DateofData,A.CustomerID+'|'+A.UCIF_ID +'|'+ E.AssetClassShortNameEnum+'|'+E.AssetClassName+'|'+ Convert(Varchar(10),DateofData,105) +'|'+ ISNULL(Convert(Varchar(10),A.NPADate,105),'')  as DataUtility from ReverseFeedData A
			Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
			Inner JOIN DimAssetClass E ON A.AssetSubClass=E.SrcSysClassCode
			 where B.SourceName='Ganaseva'
			 

			 UNION

			 Select 'GanasevaAssetClassification' AS TableName,SourceName,MonthLastDate, A.RefCustomerID+'|'+A.UCIF_ID +'|'+ E.AssetClassShortNameEnum+'|'+E.AssetClassName+'|'+ Convert(Varchar(10),MonthLastDate,105) +'|'+ ISNULL(Convert(Varchar(10),A.FinalNpaDt,105),'')  as DataUtility 
			 from Pro.AccountCal_hist A
			Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
			Inner JOIN DimAssetClass E ON A.FinalAssetClassAlt_Key=E.AssetClassAlt_Key
			inner join SysDataMatrix F ON a.EffectiveFromTimeKey = F.TimeKey
			 where B.SourceName='Ganaseva'
			 And A.InitialAssetClassAlt_Key>1 And A.FinalAssetClassAlt_Key>1 ANd A.InitialAssetClassAlt_Key<>A.FinalAssetClassAlt_Key
			 )A Group By DateofData,SourceSystemName 

			 UNION
	  		--------------ECBF
			
			Select Convert(Varchar(10),DateofData,105)DateofData,SourceSystemName,COUNT(*)ECBFAssetcount 
			from(
			Select 'ECBFAssetClassification' AS TableName, SourceSystemName,DateofData,A.CustomerID+'|'+A.UCIF_ID +'|'+ E.AssetClassShortNameEnum+'|'+E.AssetClassName+'|'+ Convert(Varchar(10),DateofData,105) +'|'+ ISNULL(Convert(Varchar(10),A.NPADate,105),'')  as DataUtility from ReverseFeedData A
			Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
			Inner JOIN DimAssetClass E ON A.AssetSubClass=E.SrcSysClassCode
			 where B.SourceName='ECBF'
			 

			 UNION

			 Select 'ECBFAssetClassification' AS TableName,SourceName,MonthLastDate, A.RefCustomerID+'|'+A.UCIF_ID +'|'+ E.AssetClassShortNameEnum+'|'+E.AssetClassName+'|'+ Convert(Varchar(10),MonthLastDate,105) +'|'+ ISNULL(Convert(Varchar(10),A.FinalNpaDt,105),'')  as DataUtility 
			 from Pro.AccountCal_hist A
			Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
			Inner JOIN DimAssetClass E ON A.FinalAssetClassAlt_Key=E.AssetClassAlt_Key
			inner join SysDataMatrix F ON a.EffectiveFromTimeKey = F.TimeKey
			 where B.SourceName='ECBF'
			 And A.InitialAssetClassAlt_Key>1 And A.FinalAssetClassAlt_Key>1 ANd A.InitialAssetClassAlt_Key<>A.FinalAssetClassAlt_Key
			 )A Group By DateofData,SourceSystemName Order by DateofData,SourceSystemName

			 select Dateofdata,SourceSystemName,count(1)DegradeCount
from ReverseFeedData wHERE ASSETCLASS > 1
group by Dateofdata,SourceSystemName
ORDER BY Dateofdata,SourceSystemName

select Dateofdata,SourceSystemName,count(1)UpgradeCount
from ReverseFeedData wHERE ASSETCLASS = 1
group by Dateofdata,SourceSystemName
ORDER BY Dateofdata,SourceSystemName

			 END
GO