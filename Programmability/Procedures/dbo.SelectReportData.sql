SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[SelectReportData]
--Declare 
    @ReportID int =24625 --11133
   
AS

begin 

--Select   DimReportFrequency.ReportFrequencyName as Frequency,TblReportDirectory.* from SysReportDirectory TblReportDirectory
--left JOIN DimReportFrequency on DimReportFrequency.ReportFrequencyAlt_Key=TblReportDirectory.ReportFrequency_Key
--where ReportMenuId=@ReportID
--order by Reportid
Print @ReportID
--Select 
----DimReportFrequency.ReportFrequencyName as Frequency
----,
--TblReportDirectory.ReportUrl,TblReportDirectory.ReportRdlFullName,TblReportDirectory.ReportRdlName
--from DynamicReportDirectory TblReportDirectory
----left JOIN DimReportFrequency on DimReportFrequency.ReportFrequencyAlt_Key=TblReportDirectory.ReportFrequency_Key
--where ReportMenuId=@ReportID
--AND TblReportDirectory.EffectiveToTimeKey=49999
--order by Reportid

Select   DimReportFrequency.ReportFrequencyName as Frequency,TblReportDirectory.* 
FROM SysReportDirectory TblReportDirectory
		LEFT JOIN DimReportFrequency 
		ON DimReportFrequency.ReportFrequencyAlt_Key=TblReportDirectory.ReportFrequency_Key
		where ReportMenuId=@ReportID
		order by Reportid

End


--select * from SysReportDirectory
--select * from DimReportFrequency
GO