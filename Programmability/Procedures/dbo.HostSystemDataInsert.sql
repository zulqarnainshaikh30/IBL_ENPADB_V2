SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[HostSystemDataInsert]
--@Date date
AS
BEGIN

Declare @Date date = (select Date from Automate_advances where Ext_flg = 'Y')


--delete  from ENPA_Host_System_Status_tbl where Report_Date in(select date from Automate_advances where Ext_flg = 'Y')
INSERT into ENPA_Host_System_Status_tbl(
Account_No 
,Host_System_Name
,Report_Date
,Create_On
)
SELECT 
AccountID
,SourceSystemName
,Dateofdata 
,GETDATE()
from ReverseFeedData
where
cast(DateofData as date) in (@Date)	 
and AssetClass>1 
and SourceSystemName not in ('VisionPlus')


END
	

	
GO