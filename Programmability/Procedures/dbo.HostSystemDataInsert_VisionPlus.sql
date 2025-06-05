SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[HostSystemDataInsert_VisionPlus]
--@Date date
AS
BEGIN

Declare @Date date = (select dateadd(Day,-1,Date)  from Automate_advances where Ext_flg = 'Y')

delete  from ENPA_Host_System_Status_tbl_VisionPlus 
where Report_Date =@Date and Host_System_Name  in ('VisionPlus')

INSERT into ENPA_Host_System_Status_tbl_VisionPlus(
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
and SourceSystemName  in ('VisionPlus')


END
	

	
GO