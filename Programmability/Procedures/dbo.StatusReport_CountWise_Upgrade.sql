SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE proc [dbo].[StatusReport_CountWise_Upgrade]
as
Begin
Declare @TimeKey AS INT =(Select TimeKey from Automate_Advances where EXT_FLG='Y')
	 --Declare @TimeKey AS INT =26298

	 IF OBJECT_ID('tempdb..#temp1') is not null
		Drop table #temp1

create table  #temp1
(
SourceAlt_Key int,
SourceName varchar(100),
CNT INT
)


	--------------Finacle
	
	INSERT INTO #temp1
	--Select  'FinacleUpgrade' AS TableName, AccountID +'|'+Convert(Varchar(10),UpgradeDate,105) as DataUtility  
	select a.SourceAlt_Key,a.SourceSystemName,count(*) cnt from ReverseFeedData A
	Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
	And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
	 where B.SourceName='Finacle'
	 And A.AssetSubClass='STD'
	 AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
	 group by a.SourceAlt_Key,a.SourceSystemName


	 --------------Ganaseva
	--Select 'GanasevaUpgrade' AS TableName, AccountID +'|'+'0'+'|'+Convert(Varchar(10),UpgradeDate,103)+'|'+'19718'+'|'+'19718' as DataUtility
	INSERT INTO #temp1
	select a.SourceAlt_Key,a.SourceSystemName,count(*) cnt from ReverseFeedData A
	Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
	And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
	 where B.SourceName='Ganaseva'
	 And A.AssetSubClass='STD'
	 AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
	 group by a.SourceAlt_Key,a.SourceSystemName


	 ----------------VisionPlus
	 	INSERT INTO #temp1
	select a.SourceAlt_Key,a.SourceSystemName,count(*) cnt from ReverseFeedData A
	Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
	And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
	 where B.SourceName='VisionPlus'
	 And A.AssetSubClass='STD'
	 AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
	 group by a.SourceAlt_Key,a.SourceSystemName


	  --------------MiFin
	--Select AccountID ,'STD',SubString(Replace(convert(varchar(20),UpgradeDate,106),' ','-'),1,7) + Right(Year(Replace(convert(varchar(20),UpgradeDate,106),' ','-')),2) 
	INSERT INTO #temp1
	select a.SourceAlt_Key,a.SourceSystemName,count(*) cnt from ReverseFeedData A
	Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
	And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
	 where B.SourceName='MiFin'
	 And A.AssetSubClass='STD'
	 AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
	 group by a.SourceAlt_Key,a.SourceSystemName

		 --------------Indus

		--Select AccountID as 'Loan Account Number' ,'STD' as MAIN_STATUS_OF_ACCOUNT,'STD' as SUB_STATUS_OF_ACCOUNT,'CN01' as REASON_CODE,Replace(convert(varchar(20),UpgradeDate,106),' ','-') as 'Value Date' 
		
		INSERT INTO #temp1
		select a.SourceAlt_Key,a.SourceSystemName,count(*) cnt from ReverseFeedData A
		Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
		And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
		 where B.SourceName='Indus'
		 And A.AssetSubClass='STD'
		 AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
         group by a.SourceAlt_Key,a.SourceSystemName
	--------------ECBF
		
		/*
				Select 
		SrNo,ProductType,ClientName,ClientCustId,SystemClassification,SystemSubClassification,DPD,UserClassification
		,UserSubClassification,NpaDate,CurrentDate
		
		 from (
		Select 
		ROW_NUMBER()Over(Order By ClientCustId)as SrNo,
		ProductType,ClientName, ClientCustId,SystemClassification,SystemSubClassification
		, DPD, UserClassification, UserSubClassification, NpaDate, CurrentDate
		
		from (
		Select A.ProductName ProductType,A.CustomerName ClientName,A.CustomerID as ClientCustId,
		'NPA' as SystemClassification,'SBSTD' as SystemSubClassification
		,A.DPD as DPD, E.AssetClassGroup as UserClassification, 'DPD0' as UserSubClassification,Convert(Varchar(10),A.UpgradeDate,105) as NpaDate,Convert(Varchar(10),A.DateofData,105)as CurrentDate
		  from ReverseFeedData A
		Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
		And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
		Inner JOIN DimAssetClass E ON A.AssetSubClass=E.SrcSysClassCode
		And E.EffectiveFromTimekey<=@TimeKey AND E.EffectiveToTimeKey>=@TimeKey
		 where B.SourceName='ECBF'
		 And A.AssetSubClass='STD'
		 AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
		 Group By 
		 A.ProductName ,A.CustomerName ,A.CustomerID ,E.AssetClassGroup ,E.SrcSysClassCode 
		,A.DPD  ,Convert(Varchar(10),A.UpgradeDate,105),Convert(Varchar(10),A.DateofData,105)
		)A
		)T

		*/


		--Declare @TimeKey AS INT =(Select TimeKey from Automate_Advances where EXT_FLG='Y')
		--Select 
		--SrNo,ProductType,ClientName,ClientCustId,SystemClassification,SystemSubClassification,DPD,UserClassification
		--,UserSubClassification,NpaDate,CurrentDate
		
		-- from (
		--Select 
		--ROW_NUMBER()Over(Order By ClientCustId)as SrNo,
		--ProductType,ClientName, ClientCustId,SystemClassification,SystemSubClassification
		--, DPD, UserClassification, UserSubClassification, NpaDate, CurrentDate
		
		--from (
		--Select A.ProductName ProductType,A.CustomerName ClientName,A.CustomerID as ClientCustId,'NPA' as SystemClassification,'SBSTD' as SystemSubClassification
		--,A.DPD as DPD,E.AssetClassGroup as UserClassification,
		--(Case When A.DPD=0 Then 'DPD0' When A.DPD BETWEEN 1 AND 30 Then 'DPD30' When A.DPD BETWEEN 31 AND 60 Then 'DPD60' 
		--When A.DPD BETWEEN 61 AND 90 Then 'DPD90' When A.DPD BETWEEN 91 AND 180 Then 'DPD180' When A.DPD BETWEEN 181 AND 365 Then 'PD1YR' END )
		-- as UserSubClassification,Convert(Varchar(10),A.UpgradeDate,105) as NpaDate,Convert(Varchar(10),A.DateofData,105)as CurrentDate
		INSERT INTO #temp1
		select a.SourceAlt_Key,a.SourceSystemName,count(*) cnt  
		from ReverseFeedData A
		Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
		And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
		Inner JOIN DimAssetClass E ON A.AssetSubClass=E.SrcSysClassCode
		And E.EffectiveFromTimekey<=@TimeKey AND E.EffectiveToTimeKey>=@TimeKey
		--Inner Join Pro.CustomerCal C ON A.CustomerID=C.RefCustomerID
		 where B.SourceName='ECBF'
		 And A.AssetSubClass='STD'
		 AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
		 group by a.SourceAlt_Key,a.SourceSystemName
		-- Group By 
		-- A.ProductName ,A.CustomerName ,A.CustomerID ,E.AssetClassGroup ,E.SrcSysClassCode 
		--,A.DPD  ,Convert(Varchar(10),A.UpgradeDate,105),Convert(Varchar(10),A.DateofData,105)
		--)A
		--)T
		
		
		 --------------MetaGrid
		--Select A.CustomerID as 'CIF ID' ,A.UCIF_ID as 'UCIC',NULL as 'ENPA_D2K_NPA_DATE' 
		INSERT INTO #temp1
		select a.SourceAlt_Key,a.SourceSystemName,count(*) cnt
		from ReverseFeedData A
		Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
		And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
		 where B.SourceName='MetaGrid'
		 And A.AssetSubClass='STD'
		 AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
		  group by a.SourceAlt_Key,a.SourceSystemName

		 --------------Calypso
		
--Select 
--'AMEND' as [Action]
--,D.CP_EXTERNAL_REF as [External Reference]
--,D.COUNTERPARTY_SHORTNAME as [ShortName]
--,D.COUNTERPARTY_FULLNAME as [LongName]
--,D.COUNTERPARTY_COUNTRY as [Country]
--,D.CP_FINANCIAL as [Financial]
--,D.CP_PARENT  as [Parent]       
--,D.CP_HOLIDAY as [HolidayCode]
--,D.CP_COMMENT as [Comment]
--,D.COUNTERPARTY_ROLE1 as [Roles.Role]
--,D.COUNTERPARTY_ROLE2 as [Roles.Role]
--,D.COUNTERPARTY_ROLE3 as [Roles.Role]
--,D.COUNTERPARTY_ROLE4 as [Roles.Role]
--,D.COUNTERPARTY_ROLE5 as [Roles.Role]
--,D.CP_STATUS  as [Status]
--,'ALL' as [Attribute.Role]
--,'ALL'  as [Attribute.ProcessingOrg]
--,'CIF_Id' as [Attribute.AttributeName]
--,D.CIF_ID as [Attribute.AttributeValue]
--,'ALL' as [Attribute.Role]
--,'ALL' as [Attribute.ProcessingOrg]
--,'UCIC' as [Attribute.AttributeName]
--,D.ucic_id as [Attribute.AttributeValue]
--,'ALL' as [Attribute.Role]
--,'ALL' as [Attribute.ProcessingOrg]
--,'ENPA_D2K_NPA_DATE' as [Attribute.AttributeName]
--,Case When A.NPIDt is null then ISNULL(Cast(A.NPIDt as varchar(20)),'') else Convert(varchar(20),A.NPIDt,105) end  as [Attribute.AttributeValue]

INSERT INTO #temp1
select 7 as SourceAlt_Key,'Calypso' as SourceName,count(*)
 from dbo.InvestmentFinancialDetail A
Inner Join dbo.investmentbasicdetail B ON A.InvEntityId=B.InvEntityId
AND B.EffectiveFromTimeKey<=@Timekey And B.EffectiveToTimeKey>=@TimeKey
Inner Join dbo.InvestmentIssuerDetail C ON C.IssuerEntityId=B.IssuerEntityId
AND C.EffectiveFromTimeKey<=@Timekey And C.EffectiveToTimeKey>=@TimeKey
Inner Join ReverseFeedCalypso D ON D.issuerId=C.IssuerID
AND D.EffectiveFromTimeKey<=@Timekey And D.EffectiveToTimeKey>=@TimeKey
Inner Join DimAssetClass E ON A.FinalAssetClassAlt_Key=E.AssetClassAlt_Key
AND E.EffectiveFromTimeKey<=@Timekey And E.EffectiveToTimeKey>=@TimeKey
Where  A.EffectiveFromTimeKey<=@Timekey And A.EffectiveToTimeKey>=@TimeKey
AND A.FinalAssetClassAlt_Key=1 And  A.InitialAssetAlt_key<>1


--select * from #temp1

--select * 
update		  a
set           a.Upgrade_RF=case when b.CNT is null then 0 else  b.CNT end
			 -- a.Upgrade_Status= case when isnull(a.Upgrade_ACL,0)=isnull(a.Upgrade_RF,0) then 'True' else 'False' END
from		  StatusReport a
inner join    #temp1 b
on            a.SourceAlt_Key=b.SourceAlt_Key

update StatusReport
set Upgrade_RF=0
where Upgrade_RF is null

update StatusReport
set    Upgrade_Status= case when isnull(Upgrade_ACL,0)=isnull(Upgrade_RF,0) then 'True' else 'False' END


END

GO