SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[dwhcount]
as
begin

Declare @Date date = (select distinct Date_of_data from [DWH_STG].dwh.account_data_finacle)

truncate table [DWH_STG].dbo.dwhControlTable

INSERT into [DWH_STG].dbo.dwhControlTable 

select distinct count(1)SourceCount,'FINACLE CUSTOMERS'SourceSystem 
 from [DWH_STG].dwh.customer_data_finacle
UNION
select distinct count(1)SourceCount,'INDUS CUSTOMERS'SourceSystem from [DWH_STG].dwh.customer_data
UNION
select distinct count(1),'VISIONPLUS CUSTOMERS' from [DWH_STG].dwh.customer_data_visionplus
UNION
select distinct count(1),'ECBF CUSTOMERS' from [DWH_STG].dwh.customer_data_ecbf
UNION
select distinct count(1),'GANASEVA CUSTOMERS' from [DWH_STG].dwh.customer_data_ganaseva
UNION
select distinct count(1),'MIFIN CUSTOMERS' from [DWH_STG].dwh.customer_data_mifin
UNION
select distinct count(1),'FINACLE ACCOUNTS' from [DWH_STG].dwh.account_data_finacle
UNION
select distinct count(1),'INDUS ACCOUNTS' from [DWH_STG].dwh.accounts_data
UNION
select distinct count(1),'VISIONPLUS ACCOUNTS' from [DWH_STG].dwh.account_data_visionplus
UNION
select distinct count(1),'ECBF ACCOUNTS' from [DWH_STG].dwh.accounts_data_ecbf
UNION
select distinct count(1),'GANASEVA ACCOUNTS' from [DWH_STG].dwh.account_data_ganaseva
--select distinct count(1)'MIFIN CUSTOMER' from [DWH_STG].dwh.accounts_data_mifin
UNION
select distinct count(1),'MIFIN ACCOUNTS' from [DWH_STG].dwh.accounts_data_mifin
UNION
select distinct COUNT(1),'FINACLE SECURITY' FROM [DWH_STG].DWH.collateral_type_master_finacle
UNION
select distinct COUNT(1),'ECBF SECURITY' FROM [DWH_STG].DWH.security_data_ecbf
UNION
select distinct COUNT(1),'INDUS SECURITY' FROM [DWH_STG].DWH.SECURITY_SOURCESYSTEM02
UNION
select distinct COUNT(1),'MIFIN SECURITY' FROM [DWH_STG].DWH.SECURITY_SOURCESYSTEM04
UNION
select distinct COUNT(1),'FINACLE TRANSACTION' FROM [DWH_STG].DWH.transaction_data_finacle
UNION
select distinct COUNT(1),'FINACLE BILL' FROM [DWH_STG].DWH.bills_data_stg_fin
UNION
select distinct COUNT(1),'FINACLE PC' FROM [DWH_STG].DWH.pca_data
UNION
select distinct COUNT(1),'Calypso - INVESTIMENTBASICDETAIL'FROM [DWH_STG].dwh.InvestmentBasicDetail
UNION
select distinct COUNT(1),'Calypso -INVESTIMENTFINANCIALDETAIL'FROM [DWH_STG].dwh.InvestmentFinancialDetails
UNION
select distinct COUNT(1),'Calypso -INVESTIMENTISSUERDETAIL'FROM [DWH_STG].dwh.InvestmentIssuerDetail
UNION
select distinct COUNT(1),'Calypso - Derivative'FROM [DWH_STG].dwh.Derivative_Cancelled
UNION
select distinct COUNT(1),'GOLDMASTER'FROM [DWH_STG].dwh.MIFINGOLDMASTER

ORDER BY SourceSystem

--select
--('Data Successful as on ' + CONVERT(varchar(20),@Date) ) [Status]
--select * from dwhControlTable
IF (select 1 from [DWH_STG].dbo.dwhControlTable 
where SourceCount = 0 and SourceSystem != 'Calypso - Derivative') = 1 
BEGIN  
select ('FAILED') [Status]

select STUFF(	(select','+SourceSystem 
				from [DWH_STG].dbo.dwhControlTable t2
				where t1.Sourcecount = t2.Sourcecount
				and SourceCount = 0 
				and SourceSystem != 'Calypso - Derivative'
				FOR XML path('')),1,1,'')
as [Data Templates] 
from [DWH_STG].dbo.dwhControlTable t1
where SourceCount = 0 
and SourceSystem != 'Calypso - Derivative'
group by SourceCount
select SourceSystem as [Data Templates],SourceCount as [Data Counts] from [DWH_STG].dbo.dwhControlTable 
END
ELSE
BEGIN 
select
('SUCCESS') [Status]
select '' as [Data Templates] 
select SourceSystem as [Data Templates],SourceCount as [Data Counts] from [DWH_STG].dbo.dwhControlTable
END






END



 

GO