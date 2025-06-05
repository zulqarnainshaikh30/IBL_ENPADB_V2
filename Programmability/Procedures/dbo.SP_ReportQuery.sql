SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


--exec [dbo].[SP_ReportQuery] '09/26/2021'
CREATE PROCEDURE [dbo].[SP_ReportQuery]
@Date date 
AS
begin


SELECT 'ACL_NPA_Data' TableName
select * from ACL_NPA_DATA where CONVERT(DATE,Process_Date,105) in (@Date)

SELECT 'ACL_UPG_Data' TableName
select * from ACL_UPG_DATA  
	 where CONVERT(DATE,Process_Date,105) in (@Date)

SELECT 'Investment_Data' TableName
select * from INVESTMENT_DATA  where CONVERT(DATE,Process_Date,105) 
in (@Date)

END
GO