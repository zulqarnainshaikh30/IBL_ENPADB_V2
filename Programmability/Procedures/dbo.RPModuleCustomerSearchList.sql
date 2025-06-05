SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



--USE RBL_MISDB_U
--RPModuleCustomerSearchList 1,'22797577'
CREATE PROC [dbo].[RPModuleCustomerSearchList]
--Declare
													
													--@PageNo         INT         = 1, 
													--@PageSize       INT         = 10, 
													@OperationFlag  INT         = 2
													,@CustomerID Varchar(20)='82000159'
													,@MenuID  INT  =14569
AS
     
	 BEGIN

SET NOCOUNT ON;
Declare @TimeKey as Int
	SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')

Declare @Authlevel InT
Declare @RecordCountLender Int=0 
 
select @Authlevel=AuthLevel from SysCRisMacMenu  
 where MenuId=@MenuID	
 --select * from 	SysCRisMacMenu where menucaption like '%Product%'				

BEGIN TRY

/*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */

			IF(@OperationFlag not in (16,17,20))
             BEGIN
			 IF OBJECT_ID('TempDB..#temp') IS NOT NULL DROP TABLE  #temp;
			 IF OBJECT_ID('TempDB..#temp1') IS NOT NULL DROP TABLE  #temp1;
			 IF OBJECT_ID('TempDB..#temp3') IS NOT NULL DROP TABLE  #temp3;
			 IF OBJECT_ID('TempDB..#temp4') IS NOT NULL DROP TABLE  #temp4;
			 IF OBJECT_ID('TempDB..#temp21') IS NOT NULL DROP TABLE  #temp21;
			 IF OBJECT_ID('TempDB..#temp2') IS NOT NULL DROP TABLE  #temp2;
	
                 
				 PRINT  'SachinTest'
                 SELECT		--A.PAN_No	,	
						A.UCIC_ID	,			
						A.CustomerID	,		
						A.CustomerName,			
						A.BankingArrangementAlt_Key ,
						A.BorrowerDefaultDate ,
						A.BorroweDefaultStatus,
						A.LeadBankAlt_Key ,
						
						A.DefaultStatusAlt_Key ,
						A.ExposureBucketAlt_Key ,
						A.ReferenceDate ,
						A.ReviewExpiryDate ,
						A.RP_ApprovalDate ,
						A.RPNatureAlt_Key ,
						A.If_Other ,
						A.RP_ExpiryDate ,
						A.RP_ImplDate ,
						A.RP_ImplStatusAlt_Key ,
						A.RP_failed ,
						A.Revised_RP_Expiry_Date, 
						A.RevisedRPDeadline_Altkey,
						A.Actual_Impl_Date ,
						A.RP_OutOfDateAllBanksDeadline ,
						
						A.RBLExposure,
						A.AssetClassAlt_Key ,
						A.RiskReviewExpiryDate, 
						A.NameOf1stReportingBanklenderAlt_Key2 ,
						A.NameOf1stReportingBanklenderAlt_Key,
						A.ICAStatusAlt_Key, 
						A.ReasonnotsigningICA	,	
						 A.ICAExecutionDate  ,
						
						A.IBCFillingDate ,
						A.IBCAddmissionDate ,
						A.IsActive,
						A.InDefaultDate,
						--A.RBLExposure,
							A.AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified,
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate
							,A.ChangeField
                 INTO #temp
                 FROM 
                 (
                     SELECT 
							
						--PAN_No		
						UCIC_ID				
						,A.CustomerID			
						,CustomerName			
						,BankingArrangementAlt_Key 
						,BorrowerDefaultDate 
						,Convert(Varchar(20),'') as BorroweDefaultStatus
						, LeadBankAlt_Key
						
						,DefaultStatusAlt_Key 
						,ExposureBucketAlt_Key 
						,Case When ExposureBucketAlt_Key=1 AND Convert(Date,'2019-06-07' )>Convert(Date,BorrowerDefaultDate) Then Convert(Varchar(10),'2019-06-07',103)
						When ExposureBucketAlt_Key=1 AND Convert(Date,'2019-06-07' )<Convert(Date,BorrowerDefaultDate) Then   Convert(Varchar(10),BorrowerDefaultDate ,103) 
						 When ExposureBucketAlt_Key=2 AND Convert(Date,'2020-01-01' )>Convert(Date,BorrowerDefaultDate) Then Convert(Varchar(10),'2019-06-07',103)   
						  When ExposureBucketAlt_Key=2 AND Convert(Date,'2020-01-01' )>Convert(Date,BorrowerDefaultDate) Then Convert(Varchar(10),BorrowerDefaultDate ,103) END 
						  ReferenceDate
						 -- Select * from DimExposureBucket

						,ReviewExpiryDate 
						,RP_ApprovalDate 
						,RPNatureAlt_Key 
						,If_Other 
						,RP_ExpiryDate 
						,RP_ImplDate 
						,RP_ImplStatusAlt_Key 
						,RP_failed 
						,Revised_RP_Expiry_Date 
						,RevisedRPDeadline_Altkey
						,Actual_Impl_Date 
						,RP_OutOfDateAllBanksDeadline 
						,IsBankExposure as RBLExposure
						,AssetClassAlt_Key 
						,RiskReviewExpiryDate 
						,B.ReportingLenderAlt_Key as NameOf1stReportingBanklenderAlt_Key2
						,Convert(Varchar(80),'') as NameOf1stReportingBanklenderAlt_Key
						,ICAStatusAlt_Key 
						,ReasonnotsigningICA			
						,ICAExecutionDate 
						,IBCFillingDate 
						,IBCAddmissionDate 
						,IsActive
						,B.InDefaultDate
						--,RBLExposure
							,isnull(A.AuthorisationStatus, 'A') AuthorisationStatus 
                            ,A.EffectiveFromTimeKey
                            ,A.EffectiveToTimeKey
                            ,A.CreatedBy
                            ,A.DateCreated 
                            ,A.ApprovedBy 
                            ,A.DateApproved
                            ,A.ModifiedBy
                            ,A.DateModified
							,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
							,'' as ChangeField
                     FROM RP_Portfolio_Details A
					 LEFT JOIN RP_Lender_Details B ON --A.EntityKey=B.RPDetailsActiveCustomer_EntityKey
					                                   A.CustomerID=B.CustomerID
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           --AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
						   AND A.CustomerID=@CustomerID
						   --AND B.InDefaultDate IN( Select Min(InDefaultDate) from RP_Lender_Details
						   --Where CustomerID=@CustomerID)
                     UNION
                     SELECT 						--PAN_No		
						UCIC_ID				
						,A.CustomerID			
						,CustomerName			
						,BankingArrangementAlt_Key 
						,BorrowerDefaultDate 
						,Convert(Varchar(20),'') as BorroweDefaultStatus
						,LeadBankAlt_Key
						 
						,DefaultStatusAlt_Key 
						,ExposureBucketAlt_Key 
							,Case When ExposureBucketAlt_Key=1 AND Convert(Date,'2019-06-07' )>Convert(Date,BorrowerDefaultDate) Then Convert(Varchar(10),'2019-06-07',103)
						When ExposureBucketAlt_Key=1 AND Convert(Date,'2019-06-07' )<Convert(Date,BorrowerDefaultDate) Then   Convert(Varchar(10),BorrowerDefaultDate ,103) 
						 When ExposureBucketAlt_Key=2 AND Convert(Date,'2020-01-01' )>Convert(Date,BorrowerDefaultDate) Then Convert(Varchar(10),'2019-06-07',103)   
						  When ExposureBucketAlt_Key=2 AND Convert(Date,'2020-01-01' )>Convert(Date,BorrowerDefaultDate) Then Convert(Varchar(10),BorrowerDefaultDate ,103) 
						  END ReferenceDate 
				
						,ReviewExpiryDate 
						,RP_ApprovalDate 
						,RPNatureAlt_Key 
						,If_Other 
						,RP_ExpiryDate 
						,RP_ImplDate 
						,RP_ImplStatusAlt_Key 
						,RP_failed 
						,Revised_RP_Expiry_Date 
						,RevisedRPDeadline_Altkey
						,Actual_Impl_Date 
						,RP_OutOfDateAllBanksDeadline 
						,IsBankExposure as RBLExposure
						,AssetClassAlt_Key 
						,RiskReviewExpiryDate 
						,B.ReportingLenderAlt_Key as NameOf1stReportingBanklenderAlt_Key2
						,Convert(Varchar(80),'') as NameOf1stReportingBanklenderAlt_Key
						,ICAStatusAlt_Key 
						,ReasonnotsigningICA			
						,ICAExecutionDate 
						,IBCFillingDate 
						,IBCAddmissionDate 
						,IsActive
						,B.InDefaultDate
						--,RBLExposure
							,isnull(A.AuthorisationStatus, 'A') AuthorisationStatus 
                            ,A.EffectiveFromTimeKey
                            ,A.EffectiveToTimeKey
                            ,A.CreatedBy
                            ,A.DateCreated 
                            ,A.ApprovedBy 
                            ,A.DateApproved
     ,A.ModifiedBy
    ,A.DateModified
							,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
							,A.ChangeField
                     FROM RP_Portfolio_Details_Mod A
					  LEFT JOIN RP_Lender_Details B ON A.CustomerID=B.CustomerID
					
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                 AND A.EffectiveToTimeKey >= @TimeKey
						     AND A.CustomerID=@CustomerID
							  -- AND B.InDefaultDate IN( Select Min(InDefaultDate) from RP_Lender_Details
						   --Where CustomerID=@CustomerID)
                           --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                           AND A.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
     FROM RP_Portfolio_Details_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                              -- AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')
                         GROUP BY EntityKey
                     )
                 ) A 
                      
                 
                 GROUP BY 
				 
				--A.PAN_No	,	
						A.UCIC_ID	,			
						A.CustomerID	,		
						A.CustomerName,			
						A.BankingArrangementAlt_Key ,
						A.BorrowerDefaultDate ,
						A.BorroweDefaultStatus,
						A.LeadBankAlt_Key ,
						
						A.DefaultStatusAlt_Key ,
						A.ExposureBucketAlt_Key ,
						A.ReferenceDate ,
						A.ReviewExpiryDate ,
						A.RP_ApprovalDate ,
						A.RPNatureAlt_Key ,
						A.If_Other ,
						A.RP_ExpiryDate ,
						A.RP_ImplDate ,
						A.RP_ImplStatusAlt_Key ,
						A.RP_failed ,
						A.Revised_RP_Expiry_Date, 
						A.RevisedRPDeadline_Altkey ,
						A.Actual_Impl_Date ,
						A.RP_OutOfDateAllBanksDeadline ,
						A.RBLExposure,
						A.AssetClassAlt_Key ,
						A.RiskReviewExpiryDate, 
						A.NameOf1stReportingBanklenderAlt_Key2 ,
						A.NameOf1stReportingBanklenderAlt_Key,
						A.ICAStatusAlt_Key, 
						A.ReasonnotsigningICA	,		
						A.ICAExecutionDate ,
						A.IBCFillingDate ,
						A.IBCAddmissionDate ,
					    A.IsActive,
					    A.InDefaultDate,
						--A.RBLExposure,
					    A.AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
 A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified,
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate
						   ,A.ChangeField
                 SELECT * into #temp21
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY CustomerID ) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'RPModule' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp A
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
                 --      AND RowNumber <= (@PageNo * @PageSize);


				  --Select '#temp21',* from #temp21
				 

				 Select @RecordCountLender=Count(*) from RP_Lender_Details
						   Where CustomerID=@CustomerID

				IF OBJECT_ID('temp31') IS NOT NULL  
					  BEGIN  
					   DROP TABLE temp31  
	
					  END

					--  Select '#temp21', * from #temp21

				 IF @RecordCountLender>0
				 BEGIN
				 --Drop Table IF Exists #temp1
				      Select * into temp31 from #temp21 A
					  WHERE A.InDefaultDate IN( Select min(InDefaultDate) from RP_Lender_Details
						   Where CustomerID=@CustomerID)
						  
				 END

				  IF @RecordCountLender<=0
				 BEGIN
				      Select * into temp31 from #temp21
					    
					  
				 END
				 
				 --Select 'temp31', * from temp31
				 Select * into #temp1 from temp31
		
		      
				 Select Distinct CustomerID into #temp2 from #temp1
				 --Select '#temp2', * from #temp2

				  Select X.CustomerID,Case when X.Less>0 Then 1 Else 2 END as DefaultStatus Into #temp4
				  from
				 (
				 Select CustomerID,Count(Case when DefaultStatus='in defualt' Then 1 END) as Less  from RP_Lender_Details
				 Where CustomerID In(Select CustomerID from #temp2)
				 Group By CustomerID
				
				 ) AS X

				 --Select '#temp4', * from #temp4
				 Select MIN(InDefaultDate) InDefaultDate,CustomerID into #temp3 from RP_Lender_Details
				 Where CustomerID In(Select CustomerID from #temp2)
				 Group By CustomerID
				 Order By CustomerID

				  --Select '#temp3', * from #temp3
				   
				 Update A
				 SET A.BorrowerDefaultDate=B.InDefaultDate
				 From #temp1 A
				 INNER JOIN #temp3 B On A.CustomerID=B.CustomerID

				     --Select '##temp1',* from #temp1

				 --Select '#temp2', * from #temp2

				 	 --Select '#temp1', * from #temp1
				  Update A
				 SET ReferenceDate=Case  When ExposureBucketAlt_Key=1 AND BorrowerDefaultDate IS NOT NULL Then Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01'))
				        When ExposureBucketAlt_Key=3 AND BorrowerDefaultDate IS NOT NULL AND Convert(Date,'2019-06-07' )<Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01')) Then Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01'))
						When ExposureBucketAlt_Key=3 AND BorrowerDefaultDate IS NOT NULL AND Convert(Date,'2019-06-07' )>Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01')) Then   Convert(Date,'2019-06-07' )
						 When ExposureBucketAlt_Key=2 AND BorrowerDefaultDate IS NOT NULL AND Convert(Date,'2020-01-01' )<Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01')) Then Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01')) 
						  When ExposureBucketAlt_Key=2 AND BorrowerDefaultDate IS NOT NULL AND Convert(Date,'2020-01-01' )>Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01')) Then Convert(Date,'2020-01-01' ) 
						  ELSE NULL
						  END
				

				 From #temp1 A
				 Where A.CustomerID In(Select CustomerID from #temp2)

				 Update A
				 SET ReferenceDate=Case  When ExposureBucketAlt_Key=1  Then Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01'))
				                          When ExposureBucketAlt_Key=3 AND Convert(Date,ISNULL(ReferenceDate,'1900-01-01') )>=Convert(Date,ISNULL (BorrowerDefaultDate,'1900-01-01'))  Then Convert (Date,ISNULL(ReferenceDate,'1900-01-01')) 
				                          When ExposureBucketAlt_Key=3 AND Convert(Date,ISNULL(ReferenceDate,'1900-01-01') )<Convert(Date,ISNULL  (BorrowerDefaultDate,'1900-01-01'))   Then   Convert(Date,BorrowerDefaultDate )
										   When ExposureBucketAlt_Key=2 AND Convert(Date,ISNULL(ReferenceDate,'1900-01-01') )>=Convert(Date,ISNULL  (BorrowerDefaultDate,'1900-01-01'))   Then Convert(Date,ISNULL(ReferenceDate,'1900-01-01'))              
										When ExposureBucketAlt_Key=2 AND Convert(Date,ISNULL(ReferenceDate,'1900-01-01') )<Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01')) Then   Convert(Date,BorrowerDefaultDate ) 
										 ELSE NULL
						                  END			  
										
						              	 From #temp1 A
				 Where A.CustomerID In(Select CustomerID from #temp2)                                                                                  
										

						                                                                                         
										
						  
				

			

				 Update A
				 SET ReferenceDate=Case When ReferenceDate='1900-01-01'		Then NULL ELSE ReferenceDate END	
				 From #temp1 A
				 Where A.CustomerID In(Select CustomerID from #temp2)

				  --Select '##temp1',* from #temp1

				 Update A
				 SET ReviewExpiryDate=Case When  Convert(Date,ReferenceDate )>Convert(Date,'2020-03-01') AND Convert(Date,ReferenceDate )<Convert(Date,'2020-08-31') Then DATEADD(Day,214,ReferenceDate)
				                            ELSE  DATEADD(Day,30,ReferenceDate)END
				

				 From #temp1 A
				 Where A.CustomerID In(Select CustomerID from #temp2)
				 --Select '#temp1', * from #temp1

				 Update A
				 SET A.BorroweDefaultStatus=B.DefaultStatus
				 From #temp1 A
				 INNER JOIN #temp4 B On A.CustomerID=B.CustomerID

				 Update A
				 SET A.BorroweDefaultStatus=Case When A.BorroweDefaultStatus=1 Then 'In Default'
				                                When A.BorroweDefaultStatus=2 Then 'Out Of Default' END
				 From #temp1 A
				  Where A.CustomerID In(Select CustomerID from #temp2)

                       --Select '##temp1',* from #temp1                                				                                

				  --Select BorroweDefaultStatus,'#temp1', * from #temp1
				  --  Select DefaultStatus,'#temp4', * from #temp4

				 Declare @RecordCount Int=0 

				 	 --Select '#temp1',* from #temp1

				 Select @RecordCount=Count(*) from #temp1

					  IF @RecordCount<=0
						BEGIN
						Print 'SachinRecordCount_0'
						   
								Select distinct A.CustomerId CustomerID
							   ,A.CustomerName
							   ,A.UCIF_ID as UCIC_ID
							   --,NULL as ExposureBucketAlt_Key
							   ,'RPModule' as TableName
					 
					    
						 from Curdat.CustomerBasicDetail  A
						 Left Join Curdat.AdvCustRelationship B On A.CustomerId =B.RefCustomerId
  
						  Where A.EffectiveFromTimeKey <= @Timekey
							   AND A.EffectiveToTimeKey >= @Timekey
				
							  AND  (A.CustomerID=@CustomerId)
					    
					 
                   
				     END

					 IF @RecordCount>0
						BEGIN
						Print 'SachinRecordCount'
					

						 Update A
						 SET A.UCIC_ID=B.UCIF_ID,
						 A.CustomerName=B.CustomerName
						 From #temp1 A
						 INNER JOIN Curdat.CustomerBasicDetail B
						 ON A.CustomerID=B.CustomerID

						 Update A
						 SET A.NameOf1stReportingBanklenderAlt_Key=B.BankName
						 --select *
						 From #temp1 A
						 INNER JOIN DimBankRP B
						 ON A.NameOf1stReportingBanklenderAlt_Key2=B.BankRPAlt_Key


						  

						 	 Select  --A.PAN_No	,	
						A.UCIC_ID	,			
						A.CustomerID	,		
						A.CustomerName,			
						A.BankingArrangementAlt_Key ,
						Convert(Varchar(25),A.BorrowerDefaultDate,103) BorrowerDefaultDate ,
						A.BorroweDefaultStatus,
						A.LeadBankAlt_Key ,
						
						A.DefaultStatusAlt_Key ,
						A.ExposureBucketAlt_Key ,
						Convert(Varchar(25),Convert(Date,A.ReferenceDate),103) ReferenceDate ,
						Convert(Varchar(25),A.ReviewExpiryDate,103) ReviewExpiryDate  ,
						Convert(Varchar(25),A.RP_ApprovalDate,103) RP_ApprovalDate  ,
						--A.RP_ApprovalDate ,
						A.RPNatureAlt_Key ,
						A.If_Other ,
						Convert(Varchar(25),Convert(Date,A.RP_ExpiryDate),103) RP_ExpiryDate,
						Convert(Varchar(25),Convert(Date,A.RP_ImplDate),103) RP_ImplDate ,
						A.RP_ImplStatusAlt_Key ,
						A.RP_failed ,
						Convert(Varchar(25),Convert(Date,A.Revised_RP_Expiry_Date),103) Revised_RP_Expiry_Date, 
						A.RevisedRPDeadline_Altkey StatusonRevisedRPDeadline,
						Convert(Varchar(25),Convert(Date,A.Actual_Impl_Date),103) Actual_Impl_Date ,
						Convert(Varchar(25),Convert(Date,A.RP_OutOfDateAllBanksDeadline),103) RP_OutOfDateAllBanksDeadline ,
						A.RBLExposure,
						A.AssetClassAlt_Key ,
						Convert(Varchar(25),Convert(Date,A.RiskReviewExpiryDate),103) RiskReviewExpiryDate, 
						A.NameOf1stReportingBanklenderAlt_Key2 ,
						A.NameOf1stReportingBanklenderAlt_Key,
						A.ICAStatusAlt_Key, 
						A.ReasonnotsigningICA	,		
						Convert(Varchar(25),A.ICAExecutionDate,103) ICAExecutionDate  ,
						Convert(Varchar(25),Convert(Date,A.IBCFillingDate),103) IBCFillingDate ,
						Convert(Varchar(25),Convert(Date,A.IBCAddmissionDate),103) IBCAddmissionDate ,
						A.IsActive,
						--A.RBLExposure,
							A.AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
         A.DateModified,
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate,
							A.ChangeField,
							TableName from #temp1 A
							Where ISNULL(A.IsActive,'N')='Y'
						END
						---select * from #temp1
				
             END;
             ELSE

			 /*  IT IS Used For GRID Search which are Pending for Authorization    */
			 IF (@OperationFlag in(16,17))

             BEGIN
			 IF OBJECT_ID('TempDB..#temp16') IS NOT NULL   DROP TABLE #temp16;
  
			 IF OBJECT_ID('TempDB..#temp8') IS NOT NULL DROP TABLE  #temp8;
			 IF OBJECT_ID('TempDB..#temp5') IS NOT NULL DROP TABLE  #temp5;
			 IF OBJECT_ID('TempDB..#temp6') IS NOT NULL DROP TABLE  #temp6;
			 IF OBJECT_ID('TempDB..#temp7') IS NOT NULL DROP TABLE  #temp7;
			 IF OBJECT_ID('TempDB..#temp25') IS NOT NULL DROP TABLE  #temp25;

                 SELECT  		--A.PAN_No	,	
						A.UCIC_ID	,			
						A.CustomerID	,		
						A.CustomerName,			
						A.BankingArrangementAlt_Key ,
						A.BorrowerDefaultDate ,
						A.BorroweDefaultStatus,
						A.LeadBankAlt_Key ,
						A.DefaultStatusAlt_Key ,
						A.ExposureBucketAlt_Key ,
						A.ReferenceDate ,
						A.ReviewExpiryDate ,
						A.RP_ApprovalDate ,
						A.RPNatureAlt_Key ,
						A.If_Other ,
						A.RP_ExpiryDate ,
						A.RP_ImplDate ,
						A.RP_ImplStatusAlt_Key ,
						A.RP_failed ,
						A.Revised_RP_Expiry_Date, 
						StatusonRevisedRPDeadline,
						A.Actual_Impl_Date ,
						A.RP_OutOfDateAllBanksDeadline ,
						A.RBLExposure,
						A.AssetClassAlt_Key ,
						A.RiskReviewExpiryDate, 
						A.NameOf1stReportingBanklenderAlt_Key2 ,
						A.NameOf1stReportingBanklenderAlt_Key,
						A.ICAStatusAlt_Key, 
						A.ReasonnotsigningICA	,		
						A.ICAExecutionDate ,
						A.IBCFillingDate ,
						A.IBCAddmissionDate ,
							A.IsActive,
							A.InDefaultDate,
						--A.RBLExposure,
							A.AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
            A.DateModified,
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate
							,A.ChangeField
                 INTO #temp16
                 FROM 
                 (
                     SELECT 				 					--	PAN_No		
						UCIC_ID				
						,A.CustomerID			
						,CustomerName			
						,BankingArrangementAlt_Key 
						,BorrowerDefaultDate 
						,Convert(Varchar(20),'') as BorroweDefaultStatus
						, LeadBankAlt_Key 
						,DefaultStatusAlt_Key 
						,ExposureBucketAlt_Key 
							,Case When ExposureBucketAlt_Key=1 AND Convert(Date,'2019-06-07' )>Convert(Date,BorrowerDefaultDate) Then Convert(Varchar(10),'2019-06-07',103)
						When ExposureBucketAlt_Key=1 AND Convert(Date,'2019-06-07' )<Convert(Date,BorrowerDefaultDate) Then   Convert(Varchar(10),BorrowerDefaultDate ,103) 
						 When ExposureBucketAlt_Key=2 AND Convert(Date,'2020-01-01' )>Convert(Date,BorrowerDefaultDate) Then Convert(Varchar(10),'2019-06-07',103)   
						  When ExposureBucketAlt_Key=2 AND Convert(Date,'2020-01-01' )>Convert(Date,BorrowerDefaultDate) Then Convert(Varchar(10),BorrowerDefaultDate ,103) END ReferenceDate 
						,ReviewExpiryDate 
						,RP_ApprovalDate 
						,RPNatureAlt_Key 
						,If_Other 
						,RP_ExpiryDate 
						,RP_ImplDate 
						,RP_ImplStatusAlt_Key 
						,RP_failed 
						,Revised_RP_Expiry_Date 
						,A.RevisedRPDeadline_Altkey  StatusonRevisedRPDeadline
						,Actual_Impl_Date 
						,RP_OutOfDateAllBanksDeadline 
						,IsBankExposure as RBLExposure
						,AssetClassAlt_Key 
						,RiskReviewExpiryDate 
						,B.ReportingLenderAlt_Key as NameOf1stReportingBanklenderAlt_Key2
                        ,Convert(Varchar(80),'') as NameOf1stReportingBanklenderAlt_Key 
						,ICAStatusAlt_Key 
						,ReasonnotsigningICA			
						,ICAExecutionDate 
						,IBCFillingDate 
						,IBCAddmissionDate 
						,	IsActive
						,B.InDefaultDate
						--,RBLExposure
							,isnull(A.AuthorisationStatus, 'A') AuthorisationStatus 
                            ,A.EffectiveFromTimeKey
                            ,A.EffectiveToTimeKey
                            ,A.CreatedBy
                            ,A.DateCreated 
                ,A.ApprovedBy 
                            ,A.DateApproved
                            ,A.ModifiedBy
                            ,A.DateModified
							,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
							,A.ChangeField
                     FROM RP_Portfolio_Details_Mod A
					  LEFT JOIN RP_Lender_Details B ON A.EntityKey=B.RPDetailsActiveCustomer_EntityKey
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
						     AND A.CustomerID=@CustomerID
                           --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                           AND A.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM RP_Portfolio_Details_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')
							    GROUP BY EntityKey
             )
                 ) A 
                      
                 
                 GROUP BY 
				 
				 	--A.PAN_No	,	
						A.UCIC_ID	,			
						A.CustomerID	,		
						A.CustomerName,			
						A.BankingArrangementAlt_Key ,
						A.BorrowerDefaultDate ,
						A.BorroweDefaultStatus,
						A.LeadBankAlt_Key ,
						A.DefaultStatusAlt_Key ,
						A.ExposureBucketAlt_Key ,
						A.ReferenceDate ,
						A.ReviewExpiryDate ,
						A.RP_ApprovalDate ,
						A.RPNatureAlt_Key ,
						A.If_Other ,
						A.RP_ExpiryDate ,
						A.RP_ImplDate ,
						A.RP_ImplStatusAlt_Key ,
						A.RP_failed ,
						A.Revised_RP_Expiry_Date, 
						StatusonRevisedRPDeadline,
						A.Actual_Impl_Date ,
						A.RP_OutOfDateAllBanksDeadline ,
						A.RBLExposure,
						A.AssetClassAlt_Key ,
						A.RiskReviewExpiryDate, 
						A.NameOf1stReportingBanklenderAlt_Key2 ,
						A.NameOf1stReportingBanklenderAlt_Key,
						A.ICAStatusAlt_Key, 
						A.ReasonnotsigningICA	,		
						A.ICAExecutionDate ,
						A.IBCFillingDate ,
						A.IBCAddmissionDate ,
							A.IsActive,
							A.InDefaultDate,
						--A.RBLExposure,
							A.AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                        A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified,
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate
							,A.ChangeField
                 SELECT * Into #temp25
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY CustomerID ) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'RPModule' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp16 A
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
                         --  AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner
    --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
                 --      AND RowNumber <= (@PageNo * @PageSize)

				 --Declare @RecordCountLender Int=0 
				 

				 Select @RecordCountLender=Count(*) from RP_Lender_Details
						   Where CustomerID=@CustomerID

				IF OBJECT_ID('temp31') IS NOT NULL  
					  BEGIN  
					   DROP TABLE temp31  
	
					  END

				 IF @RecordCountLender>0
				 BEGIN
				     --Drop Table IF Exists #temp1
				      Select * into temp31 from #temp25 A
					  WHERE A.InDefaultDate IN( Select min(InDefaultDate) from RP_Lender_Details
						   Where CustomerID=@CustomerID)
						  
				 END

				  IF @RecordCountLender<=0
				 BEGIN
				      Select * into temp31 from #temp25
					   
					  
				 END
				 

				 Select * into #temp5 from temp31

				 Select Distinct CustomerID into #temp6 from #temp5
				 --Select '#temp2', * from #temp2

				  Select X.CustomerID,Case when X.Less>0 Then 1 Else 2 END as DefaultStatus Into #temp7
				  from
				 (
				 Select CustomerID,Count(Case when DefaultStatus='in defualt' Then 1 END) as Less  from RP_Lender_Details
				 Where CustomerID In(Select CustomerID from #temp6)
				 Group By CustomerID
				
				 ) AS X


				 Select Min(InDefaultDate) InDefaultDate,CustomerID into #temp8 from RP_Lender_Details
				 Where CustomerID In(Select CustomerID from #temp6)
				 Group By CustomerID
				 Order By CustomerID

				 Update A
				 SET A.BorrowerDefaultDate=B.InDefaultDate
				 From #temp5 A
				 INNER JOIN #temp8 B On A.CustomerID=B.CustomerID

				  Update A
				 SET A.BorroweDefaultStatus=Case When A.BorroweDefaultStatus=1 Then 'In Default'
				                                When A.BorroweDefaultStatus=2 Then 'Out Of Default' END
				 From #temp1 A
				  Where A.CustomerID In(Select CustomerID from #temp2)

				 
				  Update A
				 SET ReferenceDate=Case  When ExposureBucketAlt_Key=1  Then Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01'))
				       When ExposureBucketAlt_Key=3 AND Convert(Date,'2019-06-07' )>Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01')) Then Convert(Varchar(10),'2019-06-07',103)
						When ExposureBucketAlt_Key=3 AND Convert(Date,'2019-06-07' )<Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01')) Then   Convert(Varchar(10),BorrowerDefaultDate ,103) 
						 When ExposureBucketAlt_Key=2 AND Convert(Date,'2020-01-01' )>Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01')) Then Convert(Varchar(10),'2019-06-07',103)   
						  When ExposureBucketAlt_Key=2 AND Convert(Date,'2020-01-01' )<Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01')) Then Convert(Varchar(10),BorrowerDefaultDate ,103) END
				

				 From #temp5 A
				 Where A.CustomerID In(Select CustomerID from #temp6)

				 
			   Update A
				 SET ReferenceDate=Case  When ExposureBucketAlt_Key=1  Then Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01')) 
				     When ExposureBucketAlt_Key=3 AND Convert(Date,ISNULL(ReferenceDate,'1900-01-01') )>=Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01')) Then Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01'))
						When ExposureBucketAlt_Key=3 AND Convert(Date,ISNULL(ReferenceDate,'1900-01-01') )<Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01')) Then   Convert(Date,ReferenceDate )
						 When ExposureBucketAlt_Key=2 AND Convert(Date,ISNULL(ReferenceDate,'1900-01-01') )>=Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01')) Then Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01'))  
						  When ExposureBucketAlt_Key=2 AND Convert(Date,ISNULL(ReferenceDate,'1900-01-01') )<Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01')) Then   Convert(Date,ReferenceDate ) END
				

				 From #temp5 A
				 Where A.CustomerID In(Select CustomerID from #temp6)


				 Update A
				 SET ReferenceDate=Case When ReferenceDate='1900-01-01'		Then NULL ELSE ReferenceDate END	
				 From #temp5 A
				 Where A.CustomerID In(Select CustomerID from #temp6)
				 

				 Update A
				 SET ReviewExpiryDate=Case When  Convert(Date,ReferenceDate )>Convert(Date,'2020-03-01') AND Convert(Date,ReferenceDate )<Convert(Date,'2020-08-31') Then DATEADD(Day,214,ReferenceDate)
				                            ELSE  DATEADD(Day,30,ReferenceDate)END
				

				 From #temp5 A
				 Where A.CustomerID In(Select CustomerID from #temp6)


				
				 Update A
				 SET A.BorroweDefaultStatus=B.DefaultStatus
				 From #temp5 A
				 INNER JOIN #temp7 B On A.CustomerID=B.CustomerID

				 Update A
						 SET A.UCIC_ID=B.UCIF_ID,
						 A.CustomerName=B.CustomerName
						 From #temp5 A
						 INNER JOIN Curdat.CustomerBasicDetail B
						 ON A.CustomerID=B.CustomerID

						 Update A
						 SET A.NameOf1stReportingBanklenderAlt_Key=B.BankName
						 
						 From #temp5 A
						 INNER JOIN DimBankRP B
						 ON A.NameOf1stReportingBanklenderAlt_Key2=B.BankRPAlt_Key

						 	 Select  --A.PAN_No	,	
						A.UCIC_ID	,			
						A.CustomerID	,		
						A.CustomerName,			
						A.BankingArrangementAlt_Key ,
						Convert(Varchar(25),A.BorrowerDefaultDate,103) BorrowerDefaultDate ,
						A.BorroweDefaultStatus,
						A.LeadBankAlt_Key ,
						
						A.DefaultStatusAlt_Key ,
						A.ExposureBucketAlt_Key ,
						Convert(Varchar(25),Convert(Date,A.ReferenceDate),103) ReferenceDate ,
						Convert(Varchar(25),A.ReviewExpiryDate,103) ReviewExpiryDate  ,

						Convert(Varchar(25),A.RP_ApprovalDate,103) RP_ApprovalDate  ,
						A.RPNatureAlt_Key ,
						A.If_Other ,
						Convert(Varchar(25),Convert(Date,A.RP_ExpiryDate),103) RP_ExpiryDate,
						Convert(Varchar(25),Convert(Date,A.RP_ImplDate),103) RP_ImplDate ,
						A.RP_ImplStatusAlt_Key ,
						A.RP_failed ,
					    Convert(Varchar(25),Convert(Date,A.Revised_RP_Expiry_Date),103) Revised_RP_Expiry_Date, 
						StatusonRevisedRPDeadline,
						Convert(Varchar(25),Convert(Date,A.Actual_Impl_Date),103) Actual_Impl_Date ,
						Convert(Varchar(25),Convert(Date,A.RP_OutOfDateAllBanksDeadline),103) RP_OutOfDateAllBanksDeadline ,
						A.RBLExposure,
						A.RBLExposure,
						A.AssetClassAlt_Key ,
						Convert(Varchar(25),Convert(Date,A.RiskReviewExpiryDate),103) RiskReviewExpiryDate, 
						A.NameOf1stReportingBanklenderAlt_Key2 ,
						A.NameOf1stReportingBanklenderAlt_Key,
						A.ICAStatusAlt_Key, 
						A.ReasonnotsigningICA	,		
						Convert(Varchar(25),A.ICAExecutionDate,103) ICAExecutionDate  ,
						Convert(Varchar(25),Convert(Date,A.IBCFillingDate),103) IBCFillingDate ,
						Convert(Varchar(25),Convert(Date,A.IBCAddmissionDate),103) IBCAddmissionDate ,
						A.IsActive,
						--A.RBLExposure,
							A.AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
        A.CreatedBy, 
                A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified,
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate,
							A.ChangeField,
							TableName from #temp5 A
							Where ISNULL(A.IsActive,'N')='Y'

   END;

   Else

   IF (@OperationFlag =20)
             BEGIN
			 IF OBJECT_ID('TempDB..#temp20') IS NOT NULL
			 DROP TABLE #temp20;
			 IF OBJECT_ID('TempDB..#temp29') IS NOT NULL
			  DROP TABLE #temp29;
                
                 SELECT  		--A.PAN_No	,	
						A.UCIC_ID	,			
						A.CustomerID	,		
						A.CustomerName,			
						A.BankingArrangementAlt_Key ,
						A.BorrowerDefaultDate ,
						A.BorroweDefaultStatus,
						A.LeadBankAlt_Key ,
						A.DefaultStatusAlt_Key ,
						A.ExposureBucketAlt_Key ,
						A.ReferenceDate ,
						A.ReviewExpiryDate ,
						A.RP_ApprovalDate ,
						A.RPNatureAlt_Key ,
						A.If_Other ,
						A.RP_ExpiryDate ,
						A.RP_ImplDate ,
						A.RP_ImplStatusAlt_Key ,
						A.RP_failed ,
						A.Revised_RP_Expiry_Date, 
						A.RevisedRPDeadline_Altkey,
						A.Actual_Impl_Date ,
						A.RP_OutOfDateAllBanksDeadline ,
						A.RBLExposure,
						A.AssetClassAlt_Key ,
						A.RiskReviewExpiryDate, 
						A.NameOf1stReportingBanklenderAlt_Key2 ,
						A.NameOf1stReportingBanklenderAlt_Key,
						A.ICAStatusAlt_Key, 
						A.ReasonnotsigningICA	,		
						A.ICAExecutionDate ,
						A.IBCFillingDate ,
						A.IBCAddmissionDate ,
							A.IsActive,
							A.InDefaultDate,
						--A.RBLExposure,
							A.AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
    A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
           A.ModifiedBy, 
                            A.DateModified,
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate
							,A.ChangeField
                 INTO #temp20
                 FROM 
                 (
                     SELECT 				 					--	PAN_No		
						UCIC_ID				
						,A.CustomerID			
						,CustomerName			
						,BankingArrangementAlt_Key 
						,BorrowerDefaultDate 
						,Convert(Varchar(20),'') as BorroweDefaultStatus
						, LeadBankAlt_Key 
						,DefaultStatusAlt_Key 
						,ExposureBucketAlt_Key 
							,Case When ExposureBucketAlt_Key=1 AND Convert(Date,'2019-06-07' )>Convert(Date,BorrowerDefaultDate) Then Convert(Varchar(10),'2019-06-07',103)
						When ExposureBucketAlt_Key=1 AND Convert(Date,'2019-06-07' )<Convert(Date,BorrowerDefaultDate) Then   Convert(Varchar(10),BorrowerDefaultDate ,103) 
						 When ExposureBucketAlt_Key=2 AND Convert(Date,'2020-01-01' )>Convert(Date,BorrowerDefaultDate) Then Convert(Varchar(10),'2019-06-07',103)   
						  When ExposureBucketAlt_Key=2 AND Convert(Date,'2020-01-01' )>Convert(Date,BorrowerDefaultDate) Then Convert(Varchar(10),BorrowerDefaultDate ,103) END ReferenceDate 
						,ReviewExpiryDate 
						,RP_ApprovalDate 
						,RPNatureAlt_Key 
						,If_Other 
						,RP_ExpiryDate 
						,RP_ImplDate 
						,RP_ImplStatusAlt_Key 
						,RP_failed 
						,Revised_RP_Expiry_Date 
						,RevisedRPDeadline_Altkey
						,Actual_Impl_Date 
						,RP_OutOfDateAllBanksDeadline 
						,IsBankExposure RBLExposure
						,AssetClassAlt_Key 
						,RiskReviewExpiryDate 
						,B.ReportingLenderAlt_Key as NameOf1stReportingBanklenderAlt_Key2
						,Convert(Varchar(80),'') as NameOf1stReportingBanklenderAlt_Key 
						,ICAStatusAlt_Key 
						,ReasonnotsigningICA			
						,ICAExecutionDate 
						,IBCFillingDate 
						,IBCAddmissionDate 
							,IsActive
							,B.InDefaultDate
						--,RBLExposure
							,isnull(A.AuthorisationStatus, 'A') AuthorisationStatus 
                            ,A.EffectiveFromTimeKey
                            ,A.EffectiveToTimeKey
          ,A.CreatedBy
 ,A.DateCreated 
                           ,A.ApprovedBy 
                            ,A.DateApproved
                            ,A.ModifiedBy
                            ,A.DateModified
							,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
							,A.ChangeField
                     FROM RP_Portfolio_Details_Mod A
					 LEFT JOIN RP_Lender_Details B ON A.EntityKey=B.RPDetailsActiveCustomer_EntityKey
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
             AND A.EffectiveToTimeKey >= @TimeKey
						     AND A.CustomerID=@CustomerID
                           --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                           AND A.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                   FROM RP_Portfolio_Details_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                              -- AND ISNULL(AuthorisationStatus, 'A') IN('1A')
							    GROUP BY EntityKey
                     )
                 ) A 
                      
                 
                 GROUP BY 
				 
				 	--A.PAN_No	,	
						A.UCIC_ID	,			
						A.CustomerID	,		
						A.CustomerName,			
						A.BankingArrangementAlt_Key ,
						A.BorrowerDefaultDate ,
						A.BorroweDefaultStatus,
						A.LeadBankAlt_Key ,
						A.DefaultStatusAlt_Key ,
						A.ExposureBucketAlt_Key ,
						A.ReferenceDate ,
						A.ReviewExpiryDate ,
						A.RP_ApprovalDate ,
						A.RPNatureAlt_Key ,
						A.If_Other ,
						A.RP_ExpiryDate ,
						A.RP_ImplDate ,
						A.RP_ImplStatusAlt_Key ,
						A.RP_failed ,
						A.Revised_RP_Expiry_Date, 
						A.RevisedRPDeadline_Altkey,
						A.Actual_Impl_Date ,
						A.RP_OutOfDateAllBanksDeadline ,
						A.RBLExposure,
						A.AssetClassAlt_Key ,
						A.RiskReviewExpiryDate, 
						A.NameOf1stReportingBanklenderAlt_Key2 ,
						A.NameOf1stReportingBanklenderAlt_Key,
						A.ICAStatusAlt_Key, 
						A.ReasonnotsigningICA	,		
						A.ICAExecutionDate ,
						A.IBCFillingDate ,
						A.IBCAddmissionDate ,
							A.IsActive,
							A.InDefaultDate,
						--A.RBLExposure,
							A.AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified,
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate
							,A.ChangeField
                 SELECT * Into #temp29
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY CustomerID) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'RPModule' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp20 A
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
                 --      AND RowNumber <= (@PageNo * @PageSize)

				  --Declare @RecordCountLender Int=0 
				 

				 Select @RecordCountLender=Count(*) from RP_Lender_Details
						   Where CustomerID=@CustomerID

				IF OBJECT_ID('temp31') IS NOT NULL  
					  BEGIN  
					   DROP TABLE temp31  
	
					  END

				 IF @RecordCountLender>0
				 BEGIN
				     --Drop Table IF Exists #temp1
				      Select * into temp31 from #temp29 A
					  WHERE A.InDefaultDate IN( Select min(InDefaultDate) from RP_Lender_Details
						   Where CustomerID=@CustomerID)
						  
				 END

				  IF @RecordCountLender<=0
				 BEGIN
				      Select * into temp31 from #temp29
					    
					  
				 END
				 

				 Select * into #temp9 from temp31

				 Select Distinct CustomerID into #temp10 from #temp9
				 --Select '#temp2', * from #temp2

				  Select X.CustomerID,Case when X.Less>0 Then 1 Else 2 END as DefaultStatus Into #temp11
				  from
				 (
				 Select CustomerID,Count(Case when DefaultStatus='in defualt' Then 1 END) as Less  from RP_Lender_Details
				 Where CustomerID In(Select CustomerID from #temp10)
				 Group By CustomerID
				
				 ) AS X


				 Select Min(InDefaultDate) InDefaultDate,CustomerID into #temp12 from RP_Lender_Details
				 Where CustomerID In(Select CustomerID from #temp10)
				 Group By CustomerID
				 Order By CustomerID

				 Update A
				 SET A.BorrowerDefaultDate=B.InDefaultDate
				 From #temp9 A
				 INNER JOIN #temp12 B On A.CustomerID=B.CustomerID

				   Update A
				 SET ReferenceDate= Case  When ExposureBucketAlt_Key=1  Then Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01'))
				    When ExposureBucketAlt_Key=1 AND Convert(Date,'2019-06-07' )>Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01')) Then Convert(Varchar(10),'2019-06-07',103)
						When ExposureBucketAlt_Key=1 AND Convert(Date,'2019-06-07' )<Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01')) Then   Convert(Varchar(10),BorrowerDefaultDate ,103) 
						 When ExposureBucketAlt_Key=2 AND Convert(Date,'2020-01-01' )>Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01')) Then Convert(Varchar(10),'2019-06-07',103)  
						  When ExposureBucketAlt_Key=2 AND Convert(Date,'2020-01-01' )<Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01')) Then Convert(Varchar(10),BorrowerDefaultDate ,103) END
				

				 From #temp9 A
				 Where A.CustomerID In(Select CustomerID from #temp10)

		         Update A
				 SET ReferenceDate=Case   When ExposureBucketAlt_Key=1  Then Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01'))
				   When ExposureBucketAlt_Key=3 AND Convert(Date,ISNULL(ReferenceDate,'1900-01-01') )>=Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01')) Then Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01'))
						When ExposureBucketAlt_Key=3 AND Convert(Date,ISNULL(ReferenceDate,'1900-01-01') )<Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01')) Then   Convert(Date,ReferenceDate )
						 When ExposureBucketAlt_Key=2 AND Convert(Date,ISNULL(ReferenceDate,'1900-01-01') )>=Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01')) Then Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01'))  
						  When ExposureBucketAlt_Key=2 AND Convert(Date,ISNULL(ReferenceDate,'1900-01-01') )<Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01')) Then   Convert(Date,ReferenceDate ) END
				

				 From #temp9 A
				 Where A.CustomerID In(Select CustomerID from #temp10)

				  Update A
				 SET ReferenceDate=Case When ReferenceDate='1900-01-01'		Then NULL ELSE ReferenceDate END	
				 From #temp9 A
				 Where A.CustomerID In(Select CustomerID from #temp10)

				 Update A
				 SET ReviewExpiryDate=Case When  Convert(Date,ReferenceDate )>Convert(Date,'2020-03-01') AND Convert(Date,ReferenceDate )<Convert(Date,'2020-08-31') Then DATEADD(Day,214,ReferenceDate)
				                            ELSE  DATEADD(Day,30,ReferenceDate)END
				

				 From #temp9 A
				 Where A.CustomerID In(Select CustomerID from #temp10)

				 Update A
				 SET A.BorroweDefaultStatus=B.DefaultStatus
				 From #temp9 A
				 INNER JOIN #temp11 B On A.CustomerID=B.CustomerID


				  Update A
				 SET A.BorroweDefaultStatus=Case When A.BorroweDefaultStatus=1 Then 'In Default'
				                                When A.BorroweDefaultStatus=2 Then 'Out Of Default' END
				 From #temp1 A
				  Where A.CustomerID In(Select CustomerID from #temp2)

				 Update A
						 SET A.UCIC_ID=B.UCIF_ID,
						 A.CustomerName=B.CustomerName
						 From #temp9 A
						 INNER JOIN Curdat.CustomerBasicDetail B
						 ON A.CustomerID=B.CustomerID

						 Update A
						 SET A.NameOf1stReportingBanklenderAlt_Key=B.BankName
						 
						 From #temp9 A
						 INNER JOIN DimBankRP B
						 ON A.NameOf1stReportingBanklenderAlt_Key2=B.BankRPAlt_Key

						 	 Select -- A.PAN_No	,	
						A.UCIC_ID	,			
						A.CustomerID	,		
						A.CustomerName,			
						A.BankingArrangementAlt_Key ,
						Convert(Varchar(25),A.BorrowerDefaultDate,103) BorrowerDefaultDate ,
						A.BorroweDefaultStatus,
						A.LeadBankAlt_Key ,
						
						A.DefaultStatusAlt_Key ,
						A.ExposureBucketAlt_Key ,
						Convert(Varchar(25),Convert(Date,A.ReferenceDate),103) ReferenceDate ,
						Convert(Varchar(25),A.ReviewExpiryDate,103) ReviewExpiryDate  ,

					    Convert(Varchar(25),A.RP_ApprovalDate,103) RP_ApprovalDate  ,
						A.RPNatureAlt_Key ,
						A.If_Other ,
						Convert(Varchar(25),Convert(Date,A.RP_ExpiryDate),103) RP_ExpiryDate,
						Convert(Varchar(25),Convert(Date,A.RP_ImplDate),103) RP_ImplDate ,
						A.RP_ImplStatusAlt_Key ,
						A.RP_failed ,
						Convert(Varchar(25),Convert(Date,A.Revised_RP_Expiry_Date),103) Revised_RP_Expiry_Date, 
						A.RevisedRPDeadline_Altkey,
						Convert(Varchar(25),Convert(Date,A.Actual_Impl_Date),103) Actual_Impl_Date ,
						Convert(Varchar(25),Convert(Date,A.RP_OutOfDateAllBanksDeadline),103) RP_OutOfDateAllBanksDeadline ,
						A.RBLExposure,
						A.AssetClassAlt_Key ,
						Convert(Varchar(25),Convert(Date,A.RiskReviewExpiryDate),103) RiskReviewExpiryDate,  
						A.NameOf1stReportingBanklenderAlt_Key2 ,
						A.NameOf1stReportingBanklenderAlt_Key,
						A.ICAStatusAlt_Key, 
						A.ReasonnotsigningICA	,		
					    Convert(Varchar(25),A.ICAExecutionDate,103) ICAExecutionDate  ,
						Convert(Varchar(25),Convert(Date,A.IBCFillingDate),103) IBCFillingDate ,
						Convert(Varchar(25),Convert(Date,A.IBCAddmissionDate),103) IBCAddmissionDate ,
						A.IsActive,
						--A.RBLExposure,
							A.AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
              A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                         A.DateModified,
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate,
							A.ChangeField,
							TableName from #temp9 A
							Where ISNULL(A.IsActive,'N')='Y'

   END;


   END TRY
	BEGIN CATCH
	
	INSERT INTO dbo.Error_Log
				SELECT ERROR_LINE() as ErrorLine,ERROR_MESSAGE()ErrorMessage,ERROR_NUMBER()ErrorNumber
				,ERROR_PROCEDURE()ErrorProcedure,ERROR_SEVERITY()ErrorSeverity,ERROR_STATE()ErrorState
				,GETDATE()

	SELECT ERROR_MESSAGE()
	--RETURN -1
   
	END CATCH


  
  
    END;


GO