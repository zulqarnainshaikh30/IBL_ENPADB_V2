SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



CREATE PROC [dbo].[SysCurrentTimeKey] 
      
AS 
SET DATEFORMAT DMY      
BEGIN        

DECLARE @TIMEKEY INT
SET @TIMEKEY=(SELECT a.TimeKey FROM SysDayMatrix a INNER join SysDataMatrix b
		on a.Date=b.MonthFirstDate
		where b.CurrentStatus='C'
		)

	SELECT         
		CONVERT(Char,DataEffectiveFromDate ,103) AS MonthFirstDate        
		,CONVERT(Char,DataEffectiveToDate,103) AS MonthLastDate        
		,CONVERT(Char,'01/01/1950',103) AS StartDate        
		--,@TIMEKEY AS TimeKey       
		,MonthName        
		,CASE WHEN
			 MONTH(DataEffectiveToDate)<=9 THEN 
			 '0'+CAST(month(DataEffectiveToDate) AS VARCHAR)
			 ELSE
			 CAST(month(DataEffectiveToDate) AS VARCHAR)
			 END+cast(Year(DataEffectiveToDate) AS VARCHAR)  AS MonthYear    
		,[Year]        
		,Prev_Month_Key AS PrvTimeKey  
		,CurrentStatus      
		,@TIMEKEY  AS EffectiveFromTimeKey
		,'49999' AS EffectiveToTimeKey
		,DataEffectiveToDate
		,CONVERT(varchar(11),GETDATE(),103) AS CurrentDate
		,B.TimeKey AS TimeKey
		,A.MonthName+' ('+CONVERT(VARCHAR(10),A.MonthFirstDate,103)+' - '+CONVERT(VARCHAR(10),A.MonthLastDate,103)+')' FreezeDate
	FROM SysDataMatrix A
		INNER JOIN SysDayMatrix B
			on a.MonthLastDate=b.Date        
	WHERE  CurrentStatus = 'C'       

--	BEGIN    
--    SELECT TimeKey AS EffectiveFromTimeKey,  
--     '9999' AS EffectiveToTimeKey  
-- FROM SysDayMatrix   
-- WHERE Date = (Select MonthFirstDate from SysDataMatrix  
-- WHERE CurrentStatus = 'C'  )  
   
--END  
	 
     
END






GO