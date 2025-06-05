SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE procedure [dbo].[EmailAlerts_Configuration]        
AS      
Begin    

SELECT *, 'Configuration' AS TableName FROM DimAlertsConfiguration
SELECT *, 'Recipient' AS TableName FROM AlertRecipient
select  convert(varchar,date, 105) as tdate from Automate_Advances where Ext_flg ='Y';
--select  convert(varchar,date, 105) as tdate from Automate_Advances where date=convert(varchar,'2021-12-31', 105) ;

--------new changes for DWH mail alert-----------11-01-2022------Prashant-------

Declare @Date date = (select distinct Date_of_data from DWH_STG.dwh.account_data_finacle)

select convert(varchar,@Date, 105) as DWH_Date


Declare @Date1 date = (select  dateadd(Day,-1,Date)  as VisionPlusDate from Automate_Advances where Ext_flg ='Y')
select convert(varchar,@Date1, 105) as VisionPlusDate

END
---select * from SysDayMatrix where date='2021-12-31'---26296

---select * from Automate_Advances where Ext_flg ='Y'


GO