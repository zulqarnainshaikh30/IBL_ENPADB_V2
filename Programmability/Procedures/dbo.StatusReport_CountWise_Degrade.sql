SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE proc [dbo].[StatusReport_CountWise_Degrade]
as
BEGIN

	Declare @TimeKey AS INT =(Select TimeKey from Automate_Advances where EXT_FLG='Y')
	
		 IF OBJECT_ID('tempdb..#temp2') is not null
		Drop table #temp2

        create table  #temp2
			(
				SourceAlt_Key int,
				SourceName varchar(100),
				CNT INT
			)

		--------------Finacle
		--Select  'FinacleDegrade' AS TableName, AccountID +'|'+ 
		--Case When ISNULL(A.NPADate,'1900-01-01')<ISNULL(C.AcOpenDt,'1900-01-01') Then  Convert(Varchar(10),C.AcOpenDt,105)  Else
		--  Convert(Varchar(10),NPADate,105) End  as DataUtility 
		  	INSERT INTO #temp2
	     select a.SourceAlt_Key,a.SourceSystemName,count(*) cnt
		  from ReverseFeedData A								--- As per Bank Revised mail on 05-01-2022  
		Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
		And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
		Inner JOIN Pro.AccountCal_Hist C ON A.AccountID=C.CustomerAcID
		And C.EffectiveFromTimekey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey
		 where B.SourceName='Finacle'
		 And A.AssetSubClass<>'STD'
		 AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
		 group by a.SourceAlt_Key,a.SourceSystemName


	    --------------Ganaseva
		 --Select 'GanasevaDegrade' AS TableName, AccountID +'|'+'1'+'|'+Convert(Varchar(10),NPADate,103)+'|'+'19718'+'|'+'19718' as DataUtility 
		  	INSERT INTO #temp2
	     select a.SourceAlt_Key,a.SourceSystemName,count(*) cnt
		 from ReverseFeedData A
		Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
		And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
		 where B.SourceName='Ganaseva'
		 And A.AssetSubClass<>'STD'
		 AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
		  group by a.SourceAlt_Key,a.SourceSystemName

		 ----------------VisionPlus
	  	INSERT INTO #temp2
	     select a.SourceAlt_Key,a.SourceSystemName,count(*) cnt
		 from ReverseFeedData A
		Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
		And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
		 where B.SourceName='VisionPlus'
		 And A.AssetSubClass<>'STD'
		 AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
		  group by a.SourceAlt_Key,a.SourceSystemName


	     --------------mifin
		--Select AccountID ,'NPA',SubString(Replace(convert(varchar(20),NPADate,106),' ','-'),1,7) + Right(Year(Replace(convert(varchar(20),NPADate,106),' ','-')),2) 
		INSERT INTO #temp2
	    select a.SourceAlt_Key,a.SourceSystemName,count(*) cnt
		from ReverseFeedData A
		Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
		And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
		 where B.SourceName='MiFin'
		 And A.AssetSubClass<>'STD'
		 AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
		  group by a.SourceAlt_Key,a.SourceSystemName

	     --------------Indus
		--Select AccountID ,'NPA',SubString(Replace(convert(varchar(20),NPADate,106),' ','-'),1,7) + Right(Year(Replace(convert(varchar(20),NPADate,106),' ','-')),2) from ReverseFeedData A
		--Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
		--And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
		-- where B.SourceName='MiFin'
		-- And A.AssetSubClass<>'STD'
		-- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
		--Select AccountID as 'Loan Account Number' ,'SBSTD' as MAIN_STATUS_OF_ACCOUNT,'SBSTD' as SUB_STATUS_OF_ACCOUNT,'CN01' as REASON_CODE,Replace(convert(varchar(20),NPADate,106),' ','-') as 'Value Date' 
		    INSERT INTO #temp2
	        select a.SourceAlt_Key,a.SourceSystemName,count(*) cnt
		    from ReverseFeedData A
			Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
			And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
			 where B.SourceName='Indus'
			 And A.AssetSubClass<>'STD'
			 AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
			 group by a.SourceAlt_Key,a.SourceSystemName

	     --------------ECBF

		 /*

			Select 
			SrNo,ProductType,ClientName,ClientCustId,SystemClassification,SystemSubClassification,DPD,UserClassification
			,UserSubClassification,ValueDate,CurrentDate from ( Select ROW_NUMBER()Over(Order By ClientCustId)as SrNo,
			ProductType,ClientName, ClientCustId,SystemClassification,SystemSubClassification
			, DPD, UserClassification, UserSubClassification, ValueDate, CurrentDate
			from (
			Select A.ProductName ProductType,A.CustomerName ClientName,A.CustomerID as ClientCustId,E.AssetClassGroup as SystemClassification,E.SrcSysClassCode as SystemSubClassification
			,A.DPD as DPD,'NPA' as UserClassification,'SBSTD' as UserSubClassification,Convert(Varchar(10),A.NPADate,105) as ValueDate,Convert(Varchar(10),A.DateofData,105)as CurrentDate
			  from ReverseFeedData A
			Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
			And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
			Inner JOIN DimAssetClass E ON A.AssetSubClass=E.SrcSysClassCode
			And E.EffectiveFromTimekey<=@TimeKey AND E.EffectiveToTimeKey>=@TimeKey
			 where B.SourceName='ECBF'
			 And A.AssetSubClass<>'STD'
			 AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
			 Group By 
			 A.ProductName ,A.CustomerName ,A.CustomerID ,E.AssetClassGroup ,E.SrcSysClassCode 
			,A.DPD  ,Convert(Varchar(10),A.NPADate,105),Convert(Varchar(10),A.DateofData,105)
			)A
			)T

		*/

		
		--Select 
		--SrNo,ProductType,ClientName,ClientCustId,SystemClassification,SystemSubClassification,DPD,UserClassification
		--,UserSubClassification,NpaDate,CurrentDate
		
		-- from (
		--Select 
		--ROW_NUMBER()Over(Order By ClientCustId)as SrNo,
		--ProductType,ClientName, ClientCustId,SystemClassification,SystemSubClassification
		--, DPD, UserClassification, UserSubClassification, NpaDate, CurrentDate
		
		--from (
		--Select A.ProductName ProductType,A.CustomerName ClientName,A.CustomerID as ClientCustId,E.AssetClassGroup as SystemClassification,
		--Case When E.SrcSysClassCode='SS' then 'DBT01' When E.SrcSysClassCode='D1' then 'DBT01'  When E.SrcSysClassCode='D2' then 'DBT02' 
		--When E.SrcSysClassCode='D3' then 'DBT03' When E.SrcSysClassCode='L1' then 'LOSS' Else E.SrcSysClassCode End as SystemSubClassification
		--,A.DPD as DPD,'NPA' as UserClassification,'SBSTD' as UserSubClassification,Convert(Varchar(10),A.NPADate,105) as NpaDate,Convert(Varchar(10),A.DateofData,105)as CurrentDate
		INSERT INTO #temp2
	    select a.SourceAlt_Key,a.SourceSystemName,count(*) cnt
		from ReverseFeedData A
		Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
		And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
		Inner JOIN DimAssetClass E ON A.AssetSubClass=E.SrcSysClassCode
		And E.EffectiveFromTimekey<=@TimeKey AND E.EffectiveToTimeKey>=@TimeKey
		 where B.SourceName='ECBF'
		 And A.AssetSubClass<>'STD'
		 AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
		 group by a.SourceAlt_Key,a.SourceSystemName
		-- A.ProductName ,A.CustomerName ,A.CustomerID ,E.AssetClassGroup ,E.SrcSysClassCode 
		--,A.DPD  ,Convert(Varchar(10),A.NPADate,105),Convert(Varchar(10),A.DateofData,105)
		--)A
		--)T



	   ---------MetaGrid
		--Select A.CustomerID as 'CIF ID' ,A.UCIF_ID as 'UCIC',NULL As 'Asset Classification',Replace(convert(varchar(20),NpaDate,105),'-','') as 'ENPA_D2K_NPA_DATE' 
		    INSERT INTO #temp2
	        select a.SourceAlt_Key,a.SourceSystemName,count(*) cnt
			from ReverseFeedData A
			Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
			And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
			 where B.SourceName='MetaGrid'
			 And A.AssetSubClass<>'STD'
			 AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
			 group by a.SourceAlt_Key,a.SourceSystemName

	   ---------Calypso
		
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


INSERT INTO #temp2
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
AND A.FinalAssetClassAlt_Key<>1 And  A.InitialAssetAlt_key=1

update		  a
set           a.Degrade_RF=case when b.CNT is null then 0 else  b.CNT end
			 -- a.Upgrade_Status= case when isnull(a.Upgrade_ACL,0)=isnull(a.Upgrade_RF,0) then 'True' else 'False' END
from		  StatusReport a
inner join    #temp2 b
on            a.SourceAlt_Key=b.SourceAlt_Key

update StatusReport
set Degrade_RF=0
where Degrade_RF is null

update StatusReport
set    Degrade_Status= case when isnull(Degrade_ACL,0)=isnull(Degrade_RF,0) then 'True' else 'False' END


END



GO