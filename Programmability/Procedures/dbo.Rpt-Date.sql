SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


--=======================================================
--Created By   :-LIPSA
--Created Date :-07/05/2022
--=======================================================
CREATE PROCEDURE [dbo].[Rpt-Date]
@Year INT
,@Month Varchar(20)


AS
BEGIN

--DECLARE 
--@Year INT='2022',
--@Month Varchar(20)='March'




    SELECT Convert(Varchar(20),DATE,103) DateLabel
	       ,SDM.TimeKey DateValue
    FROM  SysDayMatrix SDM  
	
    WHERE SDM.TimeKey<=(SELECT TimeKey FROM   SysDataMatrix Where CurrentStatus='C')
	      AND YEAR(SDM.DATE)=@Year
		  AND DATENAME(MM,SDM.DATE)=@Month

Order by SDM.Date DESC 
END
GO