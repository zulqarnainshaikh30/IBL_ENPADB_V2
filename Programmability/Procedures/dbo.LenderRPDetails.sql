SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

  --[LenderRPDetails] '22715142'


CREATE PROCEDURE  [dbo].[LenderRPDetails]
--declare
@CustomerID Varchar(20)='22120366'	

AS

IF OBJECT_ID('tempdb..#A ')IS NOT NULL Drop tablE #A

Select  row_number()over ( partition by BankName order by BankName ) sr,
A.CustomerID,B.BankName as LenderName
,A.InDefaultDate,A.OutOfDefaultDate
    ,CASE When ISNull([Status],'')='O' Then 'Open' 
           When ISNull([Status],'')='C' Then 'Closed' END Status
		  ,'LenderDetailsGrid' as TableName 
		  --,ReportingLenderAlt_Key,BankRPAlt_Key
		  --into #A
		  from RP_Lender_Details A
INNER JOIN DimBankRP B On A.ReportingLenderAlt_Key=B.BankRPAlt_Key
WHERE A.CustomerID=@CustomerID 

--select CustomerID,LenderName,InDefaultDate,OutOfDefaultDate,Status,TableName from #A where Sr=2
--select * from #A where Sr=1
--select distinct LenderName,* from #A

-- alter Table #A
-- add LenderName varchar(100)
-- update #A
-- set LenderName=B.BankName
-- FROM  RP_Lender_Details A
--INNER JOIN DimBankRP B On A.ReportingLenderAlt_Key=B.BankRPAlt_Key
--where  A.CustomerID=@CustomerID
--select * from #A


 IF OBJECT_ID('TempDB..#temp') IS NOT NULL DROP TABLE  #temp;
  IF OBJECT_ID('TempDB..#temp3') IS NOT NULL DROP TABLE  #temp3;

Select --A.PAN_No,
A.CustomerID ,A.CustomerName,A.ReferenceDate,  ReviewExpiryDate,Convert(Varchar(10),RP_ApprovalDate,103) ApproveDateResolution
,Convert(Varchar(10),RP_ImplDate,103) ResolutionPlanImpDate,IsBankExposure,CASE When ISNull([IsActive],'')='Y' Then 'Active' 
 When ISNull([IsActive],'')='N' Then 'No' END Status,'RPDetailsGrid' as TableName,BorrowerDefaultDate,ExposureBucketAlt_Key into #temp from RP_Portfolio_Details A
Where 
 CustomerID=@CustomerID

  Select Min(InDefaultDate) InDefaultDate,CustomerID into #temp3 from RP_Lender_Details
				
				 Group By CustomerID
				 Order By CustomerID

				  --Select '#temp3', * from #temp3
				   
				 Update A
				 SET A.BorrowerDefaultDate=B.InDefaultDate
				 From #temp A
				 INNER JOIN #temp3 B On A.CustomerID=B.CustomerID
			

 --Select '#temp',* from #temp

  Update A
				 SET ReferenceDate=Case When ExposureBucketAlt_Key=3 AND Convert(Date,'2019-06-07' )>Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01')) Then Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01'))
						When ExposureBucketAlt_Key=3 AND Convert(Date,'2019-06-07' )<Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01')) Then   Convert(Date,'2019-06-07' )
						 When ExposureBucketAlt_Key=2 AND Convert(Date,'2020-01-01' )>Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01')) Then Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01')) 
						  When ExposureBucketAlt_Key=2 AND Convert(Date,'2020-01-01' )<Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01')) Then Convert(Date,'2020-01-01' ) END
				

				 From #temp A
		

				 Update A
				 SET ReferenceDate=Case When ExposureBucketAlt_Key=3 AND Convert(Date,ISNULL(ReferenceDate,'1900-01-01') )>=Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01')) Then Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01'))
						When ExposureBucketAlt_Key=3 AND Convert(Date,ISNULL(ReferenceDate,'1900-01-01') )<Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01')) Then   Convert(Date,ReferenceDate )
						 When ExposureBucketAlt_Key=2 AND Convert(Date,ISNULL(ReferenceDate,'1900-01-01') )>=Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01')) Then Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01'))  
						  When ExposureBucketAlt_Key=2 AND Convert(Date,ISNULL(ReferenceDate,'1900-01-01') )<Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01')) Then   Convert(Date,ReferenceDate ) END
				

				 From #temp A
			
				

				 Update A
				 SET ReferenceDate=Case When ReferenceDate='1900-01-01'		Then NULL ELSE ReferenceDate END	
				 From #temp A
			

				 Update A
				 SET ReviewExpiryDate=Case When  Convert(Date,ReferenceDate )>Convert(Date,'2020-03-01') AND Convert(Date,ReferenceDate )<Convert(Date,'2020-08-31') Then DATEADD(Day,214,ReferenceDate)
				                            ELSE  DATEADD(Day,30,ReferenceDate)END
				

				 From #temp A
				
				 --Select '#temp1', * from #temp1

				 Select --A.PAN_No,
				 A.CustomerID ,A.CustomerName,Convert(Varchar(10),A.ReferenceDate,103) ReferenceDate, Convert(Varchar(10),ReviewExpiryDate,103) RevewPeriodDeadline,Convert(Varchar(10),ApproveDateResolution,103) ApproveDateResolution
,Convert(Varchar(10),ResolutionPlanImpDate,103) ResolutionPlanImpDate,IsBankExposure, [Status],'RPDetailsGrid' as TableName from #temp A
			


GO