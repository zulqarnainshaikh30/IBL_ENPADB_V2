SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO




  
/*  
--==================================================================================================================
-Created By    :- Shubham Jain  
-Creation Date :- 06/05/2010  
-Modified By   :-MNS
-Modified Date :-21/06/2013
-Description   :- This is used to fecth Data for Select Report output Type Parameter 
--==================================================================================================================
*/  
  
CREATE Proc [dbo].[Rpt-SysReportoutputType]  
@ReportType AS Varchar(10)  
AS  
  

  ----Declare 
  ----@ReportType AS Varchar(10)=6

IF (@ReportType IN (1,5)  )
BEGIN  
			SELECT 'Summary' AS CustFacilityLabel, '3'  AS CustFacilityValue  
END    
  
	IF (@ReportType IN (2))  
  
		BEGIN  
					SELECT 'Customer Wise' AS CustFacilityLabel, '1'  AS CustFacilityValue  
					UNION ALL  
					SELECT 'Facility Wise' AS CustFacilityLabel, '2'  AS CustFacilityValue  
					UNION ALL         
					SELECT 'Summary'       AS CustFacilityLabel, '3'  AS CustFacilityValue  


		END  


		IF (@ReportType IN (6))  
  
		BEGIN  
					SELECT 'Customer Wise' AS CustFacilityLabel, '1'  AS CustFacilityValue  
					
		END  



		IF (@ReportType =3)  
  
			BEGIN  
					SELECT 'Summary'      AS CustFacilityLabel, '3'   AS CustFacilityValue  
			END  

			IF (@ReportType =9)  
						BEGIN  
									SELECT 'Summary'      AS CustFacilityLabel, '9'     AS CustFacilityValue  
						END



GO