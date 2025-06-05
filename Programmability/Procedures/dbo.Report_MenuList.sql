SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE Proc [dbo].[Report_MenuList]
as

Declare @TimeKey as Int
	SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')

select ReportID  as 'ReportNo'
,menucaption  As 'ReportName'
,'ReportList' as TableName

 from syscrismacmenu
where parentid=144 and menuid>24624--EffectiveFromTimeKey <= @TimeKey  AND EffectiveToTimeKey >= @TimeKey
 order by ReportID

 --select menucaption,Reportid from syscrismacmenu where parentid=144 and menuid>24624

GO