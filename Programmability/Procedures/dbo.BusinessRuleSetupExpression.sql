SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author  Triloki Kumar>
-- Create date: <Create Date 26/03/2020>
-- Description:	<Description Business setup rule  expression >
-- =============================================
CREATE PROCEDURE [dbo].[BusinessRuleSetupExpression]
@XmlData xml
,@BusinessRule_Alt_key		INT
,@Expression Varchar(max)
,@Userid	Varchar(30)
,@ResultString Varchar(max) output
,@Result	int output

AS
BEGIN
	
	SET NOCOUNT ON;


   IF OBJECT_ID('TEMPDB..##BusinessRuleSetupData')IS NOT NULL
			DROP TABLE ##BusinessRuleSetupData

			
				SELECT 
				c.value('./UniqueID[1]','int')UniqueID
				,c.value('./Businesscolalt_key[1]','int')Businesscolalt_key				
				,c.value('./Scope[1]','varchar(MAX)')Scope
				,c.value('./ParameterName[1]','varchar(MAX)')ParameterName
				,c.value('./Businesscolvalues1[1]','varchar(MAX)')Businesscolvalues1
				,c.value('./Businesscolvalues[1]','varchar(MAX)')Businesscolvalues2
				
				INTO ##BusinessRuleSetupData
				FROM @XmlData.nodes('/DataSet/FinalExpData') AS t(c)  --/DataSet/GridData

				--SELECT * FROM ##BusinessRuleSetupData
						

		IF OBJECT_ID('TEMPDB..#SplitValue')	IS NOT NULL
			DROP TABLE #SplitValue	
			SELECT UniqueID, Split.a.value('.', 'VARCHAR(8000)') AS Businesscolvalues1  into #SplitValue
							FROM  (SELECT 
									CAST ('<M>' + REPLACE(Businesscolvalues1, ',', '</M><M>') + '</M>' AS XML) AS Businesscolvalues1,UniqueID
									from ##BusinessRuleSetupData
								) AS A CROSS APPLY Businesscolvalues1.nodes ('/M') AS Split(a) 

						IF OBJECT_ID('TEMPDB..#Temp23')IS NOT NULL
							DROP TABLE #Temp23
							select UniqueID,''''+Businesscolvalues1+'''' as businesscolvalues1 into  #Temp23 from #SplitValue

					
				IF OBJECT_ID('TEMPDB..#FinalTable') IS NOT NULL
					DROP TABLE #FinalTable
					 SELECT STUFF(
                         (
                             
							SELECT ','+businesscolvalues1
							from #Temp23 a  
							where a.uniqueid=b.uniqueid
							--group by uniqueid
							 FOR XML PATH('')
                         ), 1, 1, '')businesscolvalues1
						 ,b.uniqueid
						INTO #FinalTable
						from #Temp23 b
						group by b.uniqueid


				UPDATE A
					SET A.Businesscolvalues1=B.Businesscolvalues1
				 FROM ##BusinessRuleSetupData A
					INNER JOIN #FinalTable B
						ON A.UniqueID=B.UniqueID

			SELECT A.UniqueID				
				,B.BusinessRuleColDesc+' '+CASE WHEN DP.ParameterName='LESSTHAN' THEN ' LESSTHAN ' +A.Businesscolvalues1
				WHEN DP.ParameterName='GreaterThan' THEN ' GreaterThan '+A.Businesscolvalues1
				WHEN DP.ParameterName='LessThanEqualTo' THEN ' LessThanEqualTo '+A.Businesscolvalues1
				WHEN DP.ParameterName='GreaterThanEqualTo' THEN ' GreaterThanEqualTo '+A.Businesscolvalues1
				WHEN DP.ParameterName='Between' THEN 'Between '+A.Businesscolvalues1+' AND '''+A.Businesscolvalues2+''''
				WHEN DP.ParameterName='In' THEN 'IN( '+A.Businesscolvalues1+')'
				WHEN DP.ParameterName='EqualTo' THEN '= '+A.Businesscolvalues1
				WHEN DP.ParameterName='Like' THEN '''%'''+A.Businesscolvalues1+'''%'''
				END FINALEXPRESSION
				,ROW_NUMBER()over(order by (select 1))row1
			INTO #TEMP1
				from ##BusinessRuleSetupData A
					INNER JOIN DimBusinessRuleCol B
						ON A.Businesscolalt_key=B.BusinessRuleColAlt_Key
					INNER JOIN DimParameter DP
						ON DP.ParameterName=A.ParameterName

select @Expression=REPLACE(@Expression,'(','( ')
	select @Expression=REPLACE(@Expression,')',' )')



	IF OBJECT_ID('TEMPDB..#temp2') IS NOT NULL
		DROP TABLE #temp2
	select * into #temp2 from split(@EXPRESSION,' ')

	
						IF OBJECT_ID('TEMPDB..#temp3') IS NOT NULL
		DROP TABLE #temp3
	create table #temp3
		(FinalExpression varchar(max))


			insert into #temp3
						 SELECT STUFF(
                         (
                             
							SELECT ' '+COALESCE(convert(varchar(MAX),B.finalexpression),a.Items) 
							from #temp2 a 
							left join #temp1 b 
							on a.items=convert(varchar(MAX),b.uniqueid) FOR XML PATH('')
                         ), 1, 1, '')finalexpression






				update #temp3
					set FinalExpression=REPLACE(FinalExpression,'LessThanEqualTo','<=')

					update #temp3
					set FinalExpression=REPLACE(FinalExpression,'GreaterThanEqualTo','>=')

				update #temp3
					set FinalExpression=REPLACE(FinalExpression,'LESSTHAN','<')

					update #temp3
					set FinalExpression=REPLACE(FinalExpression,'GreaterThan','>')

					UPDATE #temp3 
					SET  FinalExpression=REPLACE(FinalExpression,'TypeOfAdvance','ADVTYPE')

					UPDATE #temp3 
					SET  FinalExpression=REPLACE(FinalExpression,'Productcode','GLProductAlt_Key')

					UPDATE #temp3 
					SET  FinalExpression=REPLACE(FinalExpression,'GLCODE','GL_CODE')


				select @ResultString=FinalExpression from #temp3

				set @Result=1

END


GO