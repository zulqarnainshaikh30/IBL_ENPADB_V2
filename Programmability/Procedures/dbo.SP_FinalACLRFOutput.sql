SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[SP_FinalACLRFOutput]
AS
BEGIN


Declare @Date date = (select Date from Automate_Advances where Ext_flg = 'Y')

Declare @Timekey int = (select Timekey from Automate_Advances where Ext_flg = 'Y')

-----------------------------------------ACL PROCESSING---------------
--DBCC shrinkfile (log,1024)
--------DBCC shrinkfile (log,1)
--------DBCC shrinkfile (log,1)
--------DBCC shrinkfile (log,1)
--------DBCC shrinkfile (log,1)

EXEC PRO.InsertDataforAssetClassficationRBL @Timekey

EXEC Pro.MAINPROECESSFORASSETCLASSFICATION

End
GO