SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[ETL_DatavalidationafterRF]
AS

select 'Customercal Records'
select count(1) from Pro.CustomerCAL

select 'Accountcal Records'
select count(1) from Pro.ACcountcal

select 'ACL Degrade Records'
select SourceAlt_key,count(1) from Pro.AccountCAL where InitialAssetClassAlt_Key = 1 
and FinalAssetClassAlt_Key > 1 group by SourceAlt_Key

select 'ACL Upgrade Records'
select SourceAlt_key,count(1) from Pro.AccountCAL where InitialAssetClassAlt_Key > 1 
and FinalAssetClassAlt_Key = 1 group by SourceAlt_Key

select 'Reversefeed records'
select SourceAlt_Key,count(1)count from ReverseFeedData where cast(dateofData as date) in (select Date from Automate_Advances where Ext_flg = 'Y') group by SourceAlt_Key

--delete from [ENBD_STGDB].dbo.Package_Audit where cast(Execution_date as date) = cast(GETDATE() as date)
GO