SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE Proc [dbo].[StatusReport_CountWise]

as

Begin

Declare @TimeKey AS INT =(Select TimeKey from Automate_Advances where EXT_FLG='Y')
Declare @Date AS Date =(Select Date from Automate_Advances where Timekey=@TimeKey)
	
	--Declare @TimeKey AS INT =26298

update StatusReport 
set Upgrade_ACL=Null,Upgrade_RF =Null,Upgrade_Status=Null,Degrade_ACL=Null,
	Degrade_RF=Null,Degrade_Status=Null

IF OBJECT_ID('tempdb..#temp') is not null
Drop table #temp

select      b.SourceAlt_Key,a.SourceName,count(*) CNT 
into        #temp
--select		b.SourceAlt_Key,a.SourceName,count(*)
from		ACL_UPG_DATA a
inner join  DIMSOURCEDB b
on          a.SourceName=b.SourceName
where		CONVERT(DATE,Process_Date,105) in (@Date)
group by	b.SourceAlt_Key,a.SourceName


update a
set  a.Upgrade_ACL=case when b.CNT is null then 0 else  b.CNT end
from StatusReport a
inner join    #temp b
on            a.SourceAlt_Key=b.SourceAlt_Key

update StatusReport
set Upgrade_ACL=0
where Upgrade_ACL is null

Exec StatusReport_CountWise_Upgrade


IF OBJECT_ID('tempdb..#temp3') is not null
Drop table #temp3

select      b.SourceAlt_Key,a.SourceName,count(*) CNT 
into        #temp3
--select count(*),SourceName 
from ACL_NPA_DATA a
inner join      DIMSOURCEDB b
on              a.SourceName=b.SourceName
where CONVERT(DATE,Process_Date,105) in (@Date)
and InitialAssetClass='std' and FialAssetClass<>'std'
group by b.SourceAlt_Key,a.SourceName

update a
set  a.Degrade_ACL=case when b.CNT is null then 0 else  b.CNT end
from StatusReport a
inner join    #temp3 b
on            a.SourceAlt_Key=b.SourceAlt_Key

update StatusReport
set Degrade_ACL=0
where Degrade_ACL is null

Exec StatusReport_CountWise_Degrade

Exec StatusReport_CountWise_ACLCount

Exec StatusReport_CountWise_ACL_RF_Count

select * from StatusReport
order by SourceAlt_Key


END
GO