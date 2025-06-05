SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
Create proc [dbo].[SP_HostSystem_selectDataforVisionPLus]
as

BEGIN

Declare @Date date = (select dateadd(Day,-1,Date)  from Automate_advances where Ext_flg = 'Y')

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