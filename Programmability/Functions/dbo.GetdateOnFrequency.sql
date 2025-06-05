SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
Create FUNCTION [dbo].[GetdateOnFrequency]
(
@TimeKey INT,
@Frequency varchar(50)
)
RETURNS 
@Result TABLE 
(
	MonthLastDate varchar(10),
	MonthFirstDate varchar(10)
)
AS

BEGIN
	Declare @MonthLastDate varchar(10)='',
			@MonthFirstDate varchar(10)=''
	IF @Frequency='MONTHLY'
	BEGIN
         SELECT @MonthLastDate=MonthLastDate,
				@MonthFirstDate=monthfirstdate
			--MAX(A.Timekey) AS Timekey
			 from sysdatamatrix A
			 INNER JOIN (SELECT TimeKey,Date from SysDayMatrix 
						 ) D
			 ON A.MonthLastDate=D.Date
			 where  currentstatus IN( 'U' ,'C') 
			 AND A.TimeKey=@TimeKey
			 Group By Year,MonthLastDate, monthfirstdate,Month
			 order by MonthLastDate desc
			
	END
	ELSE IF @Frequency='QUARTERLY'
	BEGIN
			--select 
			--	@MonthLastDate=MonthLastDate,
			--	@MonthFirstDate=monthfirstdate
			--	 from sysdatamatrix A
			--	 INNER JOIN 	(	 Select Cast(CurQtrDate as date) as [Date] from SysDayMatrix  Group by CurQtrDate )
			--		B ON A.MonthLastDate=B.Date 
			
			-- where currentstatus IN( 'U' ,'C') --AND Month_Key >= 2922 AND Month_Key <= 2922
			--  AND A.TimeKey=@TimeKey
			--  GROUP BY Year,MonthLastDate, monthfirstdate,Month,currentstatus
			-- order by MonthLastDate desc

	Select
	Distinct
		
		@MonthLastDate=B.MonthLastDate,
		@monthfirstdate=DATEADD(DAY,1,sysdatamatrix.MonthLastDate)
		 from sysdatamatrix 
		Inner join 
		(
		Select 
		Prev_Qtr_key,sysdatamatrix.MonthLastDate
		FROM sysdatamatrix
		Inner Join 
		(
		SELECT 
				MonthLastDate
				--monthfirstdate
					from sysdatamatrix A
					INNER JOIN 	(	 Select Cast(CurQtrDate as date) as [Date] from SysDayMatrix  Group by CurQtrDate )
							B ON A.MonthLastDate=B.Date 
				WHERE currentstatus IN( 'U' ,'C') --AND Month_Key >= 2922 AND Month_Key <= 2922
				AND A.TimeKey=@TimeKey
				GROUP BY Year,MonthLastDate,Month,currentstatus) A ON sysdatamatrix.MonthLastDate=A.MonthLastDate
				) B on sysdatamatrix.TimeKey=B.Prev_Qtr_key

	END
	ELSE IF @Frequency='YEARLY'
	BEGIN
		Select @MonthLastDate=LastDayOfYear,
		@monthfirstdate=StartOfYear
		FROM
		(
		Select
		Distinct
			CAST(DATEADD(yy, DATEDIFF(yy,0,MonthLastDate), 0) as Date) AS StartOfYear,
			CAST(DATEADD(yy, DATEDIFF(yy,0,MonthLastDate) + 1, -1) as Date) AS LastDayOfYear
			
		from sysdatamatrix where CurrentStatus in('C','U')  AND Timekey=@TimeKey )YearlyFrequncy
		
	END
	ELSE IF @Frequency='FINYEARLY'
	BEGIN
		SELECT  
		
		@monthfirstdate =CAST (CONVERT(DATE,DATEADD(Day,1,EOMONTH(DATEADD(MONTH,-12,MonthFirstDate),0)),103) AS VARCHAR(10))
		,@MonthLastDate=CONVERT(DATE,MonthLastDate,105)
		
		 FROM sysdatamatrix SDM INNER JOIN 
		(
			SELECT 
			Fiscal_Year_key AS FINKEY ,Year
			FROM sysdatamatrix WHERE  MONTH='MARCH' AND CurrentStatus in('C','U')
			GROUP BY Fiscal_Year_key,Year
		) D
		 ON SDM.TimeKey=D.FINKEY
		 WHERE TimeKey=@TimeKey

	END
	ELSE IF @Frequency='DAILY'
	BEGIN
		Select @MonthLastDate=CAST([DATE]  AS DATE) ,@monthfirstdate=CAST([DATE]-1 AS DATE) 
		FROM SysDayMatrix WHERE TIMEKEY=@TimeKey

	END

	ELSE IF @Frequency='WEEKLY'
	BEGIN

		SELECT @monthfirstdate=CAST([DATE]-6 AS DATE) ,@MonthLastDate=CAST([DATE] AS DATE)
		FROM SysDayMatrix
		
		 WHERE TIMEKEY=@TimeKey
		AND Datename like '%Friday%'

	END
	ELSE IF @Frequency='YEARLY_PERIOD' 
	BEGIN
		SELECT @MonthFirstDate=MonthFirstDate,@MonthLastDate= MonthLastDate FROM
		(
		    SELECT A.TimeKey as Code, CONVERT(VARCHAR(10),B.Date,103) as Description ,CASE WHEN MONTH(B.Date)<=9 THEN '0'+CAST(month(B.Date) as varchar) ELSE CAST(month(B.Date) as varchar) END+cast(Year(B.Date) as varchar)  as MonthYear,S.Month,A.TimeKey,S.Year,S.CurrentStatus 
			,CONVERT(DATE,DATEADD(Day,1,EOMONTH(DATEADD(MONTH,-12,B.DATE),0)),103)  MonthFirstDate,CONVERT(DATE,B.Date,103) as MonthLastDate
			
			from SysDayMatrix A
			  	
			INNER JOIN 	(	  SELECT MonthLastDate AS DATE FROM sysdatamatrix WHERE  MONTH IN ('SEPTEMBER','MARCH')  )
				B ON A.Date=B.Date 
			Inner Join sysdatamatrix S on A.Date=S.MonthLastDate AND S.CurrentStatus IN ('U','C')
			Group By A.TimeKey,B.Date,S.Month,S.Year,S.CurrentStatus
			--order by B.Date Desc
		) H WHERE H.TimeKey=@TimeKey
	END

	ELSE IF @Frequency='HALFYEARLY'
	BEGIN
		
	DECLARE @Prev_Qtr_key INT,@Prev_Qtr_key2 INT , @HalfYearStartdate varchar(10),@HalfYearEnddate varchar(10)
	
	SELECT @Prev_Qtr_key=Prev_Qtr_key,@HalfYearEnddate =MonthLastDate FROM sysdatamatrix WHERE CurrentStatus in('C','U')  AND Timekey=@TimeKey
	
	--SELECT @Prev_Qtr_key2=Prev_Qtr_key FROM sysdatamatrix WHERE CurrentStatus in('C','U')  AND Timekey=@Prev_Qtr_key
	
	--SELECT @HalfYearStartdate=MonthFirstDate FROM sysdatamatrix WHERE CurrentStatus in('C','U')  AND Timekey=@Prev_Qtr_key2
			
	Select
	Distinct
		
		--@MonthLastDate=B.MonthLastDate,
		@HalfYearStartdate=DATEADD(DAY,1,sysdatamatrix.MonthLastDate)
		 from sysdatamatrix 
		Inner join 
		(
		Select 
		Prev_Qtr_key,sysdatamatrix.MonthLastDate
		FROM sysdatamatrix
		Inner Join 
		(
		SELECT 
				MonthLastDate
				--monthfirstdate
					from sysdatamatrix A
					INNER JOIN 	(	 Select Cast(CurQtrDate as date) as [Date] from SysDayMatrix  Group by CurQtrDate )
							B ON A.MonthLastDate=B.Date 
				WHERE --currentstatus IN( 'U' ,'C') AND--AND Month_Key >= 2922 AND Month_Key <= 2922
				 A.TimeKey=@Prev_Qtr_key
				GROUP BY Year,MonthLastDate,Month,currentstatus) A ON sysdatamatrix.MonthLastDate=A.MonthLastDate
				) B on sysdatamatrix.TimeKey=B.Prev_Qtr_key
	
	
	
	 SET @MonthFirstDate=@HalfYearStartdate
	 SET @MonthLastDate=@HalfYearEnddate

	END

	ELSE IF @Frequency='HALFYEAR'
	BEGIN
		SELECT @MonthFirstDate=MonthFirstDate,@MonthLastDate= MonthLastDate FROM
		(
		    SELECT A.TimeKey as Code, CONVERT(VARCHAR(10),B.Date,103) as Description ,CASE WHEN MONTH(B.Date)<=9 THEN '0'+CAST(month(B.Date) as varchar) ELSE CAST(month(B.Date) as varchar) END+cast(Year(B.Date) as varchar)  as MonthYear,S.Month,A.TimeKey,S.Year,S.CurrentStatus 
			,CONVERT(DATE,DATEADD(Day,1,EOMONTH(DATEADD(MONTH,-6,B.DATE),0)),103)  MonthFirstDate,CONVERT(DATE,B.Date,103) as MonthLastDate
			
			from SysDayMatrix A
			  	
			INNER JOIN 	(	  SELECT MonthLastDate AS DATE FROM sysdatamatrix WHERE  MONTH IN ('JUNE','DECEMBER')  )
				B ON A.Date=B.Date 
			Inner Join sysdatamatrix S on A.Date=S.MonthLastDate AND S.CurrentStatus IN ('U','C')
			Group By A.TimeKey,B.Date,S.Month,S.Year,S.CurrentStatus
			--order by B.Date Desc
		) H WHERE H.TimeKey=@TimeKey

	END

	------ADDED BY SATHEESH 
	ELSE IF @Frequency='FORTNIGHTLY'
	BEGIN

	DECLARE @Sysdate AS DATE
	SELECT @Sysdate=DATE FROM SysDayMatrix WHERE TimeKey=@TimeKey

	
	SELECT @MonthFirstDate=CONVERT(DATE,MonthFirstDate,105),@MonthLastDate=CONVERT(DATE,MonthLastDate,105)
	FROM
	(
	SELECT 
	
	CASE WHEN CONVERT(VARCHAR(10),@Sysdate,105)=CONVERT(VARCHAR(10),DATEADD(Day,15,EOMONTH(DATEADD(MONTH,-1,MonthLastDate),0)),105) THEN  CONVERT(VARCHAR(10),A.MonthFirstDate,105)
	WHEN CONVERT(VARCHAR(10),@Sysdate,105)<>CONVERT(VARCHAR(10),DATEADD(Day,15,EOMONTH(DATEADD(MONTH,-1,MonthLastDate),0)),105) THEN  CONVERT(VARCHAR(10),DATEADD(Day,16,EOMONTH(DATEADD(MONTH,-1,@Sysdate),0)),105)
	END AS MonthFirstDate,
	
	CASE WHEN CONVERT(VARCHAR(10),@Sysdate,105)<>CONVERT(VARCHAR(10),A.MonthLastDate,105) THEN CONVERT(VARCHAR(10),@Sysdate,105)
	WHEN CONVERT(VARCHAR(10),@Sysdate,105)=CONVERT(VARCHAR(10),A.MonthLastDate,105) THEN CONVERT(VARCHAR(10),@Sysdate,105)
	END AS MonthLastDate 
	  
	FROM sysdatamatrix A RIGHT JOIN SysDayMatrix B 
	ON A.Fortnight_Key=@TimeKey AND A.Week_Key=B.LastWkDateKey
	WHERE A.currentstatus IN( 'U' ,'C') 
	GROUP BY A.MonthFirstDate,A.MonthLastDate)A

	
	END


	Insert Into @Result Values(@MonthLastDate,@MonthFirstDate)
	return	 
END






	
GO