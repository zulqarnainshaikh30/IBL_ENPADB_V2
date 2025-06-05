SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[SecurityCheckDataValidation]
	 @MenuID int = ''
	,@Parameter varchar(max) = ''
	,@Result INT	=0 OUTPUT

AS
BEGIN


print @Parameter
--Drop Table #final

--;with T( Cols) as
--(
--  select @Parameter

--),
----first split all comma separated into different rows
--CTE2 AS 
--(
--    SELECT 
--    CAST(N'<H><r>' + replace(Replace(Vals.a.value('.', 'NVARCHAR(50)'),
--        ' ','|'), '|', '</r><r>') + '</r></H>' as XML) Cols
--    FROM
--    (
--    SELECT *,CAST (N'<H><r>' + Replace(cols,',','</r><r>') + 
--        '</r></H>' AS XML) AS [vals]
--    FROM T) d
--    CROSS APPLY d.[vals].nodes('/H/r') Vals(a)
--)

----IF EXISTS(select * from #final)
----Drop Table #final;

--drop table if exists #final

---- split all ' ' demilited values now
--SELECT distinct  Vals.a.value('(/H/r)[1]', 'VARCHAR(100)') AS ColumnName,
--Vals.a.value('(/H/r)[2]', 'VARCHAR(100)') AS ColumnValue
--into #final
--FROM
--(
--SELECT *
--FROM CTE2) d
--CROSS APPLY d.[cols].nodes('/H/r') Vals(a)

SELECT 	CHARINDEX('|',VALUE) CHRIDX,VALUE, CAST('' AS VARCHAR(100)) CtrlName,CAST('' AS VARCHAR(500)) CtrlValue
	into #cte_string_split
 FROM( SELECT VALUE FROM STRING_SPLIT(@Parameter,'}')) A



update  #cte_string_split set CtrlName=left(value,CHRIDX-1)
update  #cte_string_split set CtrlValue=right(value,len(value)- CHRIDX)



IF (select count(1) from MetaScreenFieldDetail A
INNER JOIN #cte_string_split B ON A.CtrlName = B.CtrlName
where MenuID = @MenuID and IsMandatory = 'Y'
and (B.CtrlValue ='NULL' or b.CtrlValue = '')
	) > 0 
BEGIN
SET @Result=-1
RETURN @Result
--PRINT -1
END
ELSE 
BEGIN 
SET @Result=1
RETURN @Result 
--PRINT 1
END

END
--CASE WHEN 

--THEN 
--RETURN -1 
--ELSE
--END



GO