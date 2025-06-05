SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[SP_InsertExceptionFinalStatusTypeETL]
AS


Declare @Timekey int = (select Timekey from Automate_Advances where Ext_flg = 'Y')

Declare @Date date = (select Date from Automate_Advances where Ext_flg = 'Y')

Delete from ExceptionFinalStatusType where EffectiveFromTimeKey <= @Timekey  and EffectiveToTimeKey >= @Timekey and IS_ETL = 'Y'

INSERT INTO ExceptionFinalStatusType(SourceAlt_Key,CustomerID,ACID,StatusType,StatusDate,Amount,EffectiveFromTimeKey,EffectiveToTimeKey,IS_ETL)
select B.SourceAlt_Key,A.CustomerID,A.CustomerAcID,'TWO',TWODate,TWOAmount
,@Timekey,49999,'Y'
from UTKS_STGDB.dbo.LMS_ACCOUNT_STG A INNER JOIN DIMSOURCEDB B 
ON A.SourceSystem = B.SourceName and b.EffectiveFromTimeKey <= @Timekey and B.EffectiveToTimeKey >= @Timekey
where SubAssetClassCode like '%W%'
GO