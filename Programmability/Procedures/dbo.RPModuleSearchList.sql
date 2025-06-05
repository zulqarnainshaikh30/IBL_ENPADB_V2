SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


--[RPModuleSearchList] 16
CREATE PROC [dbo].[RPModuleSearchList]
--Declare
													
													--@PageNo         INT         = 1, 
													--@PageSize       INT         = 10, 
													@OperationFlag  INT         = 16
													
													,@MenuID  INT  =14569
AS
     
	 BEGIN

SET NOCOUNT ON;
Declare @TimeKey as Int
	SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')

Declare @Authlevel InT
 
select @Authlevel=AuthLevel from SysCRisMacMenu  
 where MenuId=@MenuID	
 --select * from 	SysCRisMacMenu where menucaption like '%Product%'				
 SET DATEFORMAT DMY
BEGIN TRY

/*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */

			IF(@OperationFlag not in (16,17,20))
             BEGIN
			 IF OBJECT_ID('TempDB..#temp') IS NOT NULL DROP TABLE  #temp;
			 IF OBJECT_ID('TempDB..#temp1') IS NOT NULL DROP TABLE  #temp1;
			 IF OBJECT_ID('TempDB..#temp3') IS NOT NULL DROP TABLE  #temp3;
			 IF OBJECT_ID('TempDB..#temp3') IS NOT NULL DROP TABLE  #temp4;
                 
				 PRINT  'SachinTest'
                 SELECT	A.PAN_No	,	
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
						A.RevisedRPDeadline_Altkey,
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
							A.changefield
							,A.BucketName
							
                 INTO #temp
                 FROM 
                 (
                     SELECT 
							
						PAN_No		
						,UCIC_ID				
						,A.CustomerID			
						,CustomerName			
						,BankingArrangementAlt_Key 
						,BorrowerDefaultDate 
						,Convert(Varchar(20),'') as BorroweDefaultStatus
						,LeadBankAlt_Key 
						,DefaultStatusAlt_Key 
						,A.ExposureBucketAlt_Key 
						,
					
				 Case When A.ExposureBucketAlt_Key=1 AND Convert(Date,'2019-06-07' )>Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01')) Then Convert(Varchar(10),'2019-06-07',103)
						When A.ExposureBucketAlt_Key=1 AND Convert(Date,'2019-06-07' )<Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01')) Then   Convert(Varchar(10),BorrowerDefaultDate ,103) 
						 When A.ExposureBucketAlt_Key=2 AND Convert(Date,'2020-01-01' )>Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01')) Then Convert(Varchar(10),'2019-06-07',103)   
						  When A.ExposureBucketAlt_Key=2 AND Convert(Date,'2020-01-01' )>Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01')) Then Convert(Varchar(10),BorrowerDefaultDate ,103) END
						  
						  ReferenceDate

						,ReviewExpiryDate 
						,Convert(Varchar(10),Convert(Date,RP_ApprovalDate),103) RP_ApprovalDate
						,RPNatureAlt_Key 
						,If_Other 
						,RP_ExpiryDate 
						,RP_ImplDate 
						,RP_ImplStatusAlt_Key 
						,RP_failed 
						,Convert(Date,Revised_RP_Expiry_Date ) Revised_RP_Expiry_Date
						,Convert(Date,Actual_Impl_Date) Actual_Impl_Date
						,Convert(Date,RP_OutOfDateAllBanksDeadline) RP_OutOfDateAllBanksDeadline
						,IsBankExposure as RBLExposure
						,AssetClassAlt_Key 
						,RiskReviewExpiryDate 
						,NameOf1stReportingBanklenderAlt_Key as NameOf1stReportingBanklenderAlt_Key2
						,Convert(Varchar(80),'') as NameOf1stReportingBanklenderAlt_Key
						,ICAStatusAlt_Key 
						,ReasonnotsigningICA			
						,ICAExecutionDate 
						,IBCFillingDate 
						,IBCAddmissionDate 
						,A.IsActive
						,RevisedRPDeadline_Altkey
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
							,'' as changefield
							,C.BucketName
                    FROM RP_Portfolio_Details A
					  LEFT JOIN RP_Lender_Details B ON A.EntityKey=B.RPDetailsActiveCustomer_EntityKey
					   left Join  dimexposurebucket c ON c.ExposureBucketAlt_Key=A.ExposureBucketAlt_Key
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
						   
						   
                     UNION
                     SELECT 						PAN_No		
						,UCIC_ID				
						,A.CustomerID			
						,CustomerName			
						,BankingArrangementAlt_Key 
						,BorrowerDefaultDate 
						,Convert(Varchar(10),'') as BorroweDefaultStatus
						,LeadBankAlt_Key 
						,DefaultStatusAlt_Key 
						,A.ExposureBucketAlt_Key 
							,Case When A.ExposureBucketAlt_Key=1 AND Convert(Date,'2019-06-07' )>Convert(Date,BorrowerDefaultDate) Then Convert(Varchar(10),'2019-06-07',103)
						When A.ExposureBucketAlt_Key=1 AND Convert(Date,'2019-06-07' )<Convert(Date,BorrowerDefaultDate) Then   Convert(Varchar(10),BorrowerDefaultDate ,103) 
						 When A.ExposureBucketAlt_Key=2 AND Convert(Date,'2020-01-01' )>Convert(Date,BorrowerDefaultDate) Then Convert(Varchar(10),'2019-06-07',103)   
						  When A.ExposureBucketAlt_Key=2 AND Convert(Date,'2020-01-01' )>Convert(Date,BorrowerDefaultDate) Then Convert(Varchar(10),BorrowerDefaultDate ,103) END ReferenceDate 
				
						,ReviewExpiryDate 
						,Convert(Varchar(10),Convert(Date,RP_ApprovalDate),103) as  RP_ApprovalDate
						,RPNatureAlt_Key 
						,If_Other 
						,RP_ExpiryDate 
						,RP_ImplDate 
						,RP_ImplStatusAlt_Key 
						,RP_failed 
						,Convert(Date,Revised_RP_Expiry_Date ) Revised_RP_Expiry_Date
						,Convert(Date,Actual_Impl_Date) Actual_Impl_Date
						,Convert(Date,RP_OutOfDateAllBanksDeadline) RP_OutOfDateAllBanksDeadline
						,IsBankExposure as RBLExposure
						,AssetClassAlt_Key 
						,RiskReviewExpiryDate 
						,NameOf1stReportingBanklenderAlt_Key as NameOf1stReportingBanklenderAlt_Key2
						,Convert(Varchar(80),'') as NameOf1stReportingBanklenderAlt_Key
						,ICAStatusAlt_Key 
						,ReasonnotsigningICA			
						,ICAExecutionDate 
						,IBCFillingDate 
						,IBCAddmissionDate 
						,A.IsActive
						,RevisedRPDeadline_Altkey
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
								,A.changefields
								,C.BucketName
                     FROM RP_Portfolio_Details_Mod A
					 LEFT JOIN RP_Lender_Details B ON A.EntityKey=B.RPDetailsActiveCustomer_EntityKey
					 left Join  dimexposurebucket c ON c.ExposureBucketAlt_Key=A.ExposureBucketAlt_Key
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
						     
                           --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                           AND A.EntityKey IN
                     (
 SELECT MAX(EntityKey)
           FROM RP_Portfolio_Details_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')
                         GROUP BY EntityKey
                     )
                 ) A 
                      
                 
                 GROUP BY 
				 
				A.PAN_No	,	
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
						A.RevisedRPDeadline_Altkey,
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
								A.changefield
								,A.BucketName
                 SELECT * into #temp1
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

				 


				 Select Distinct CustomerID into #temp2 from #temp1
				 --Select '#temp2', * from #temp2

				  Select X.CustomerID,Case when X.Less>0 Then 'in defualt' Else 'out of defualt' END as DefaultStatus Into #temp4
				  from
				 (
				 Select CustomerID,Count(Case when DefaultStatus='in defualt' Then 1 END) as Less  from RP_Lender_Details
				 Where CustomerID In(Select CustomerID from #temp2)
				 Group By CustomerID
				
				 ) AS X


				 Select Min(InDefaultDate) InDefaultDate,CustomerID into #temp3 from RP_Lender_Details
				 Where CustomerID In(Select CustomerID from #temp2)
				 Group By CustomerID
				 Order By CustomerID

				 Update A
				 SET A.BorrowerDefaultDate=B.InDefaultDate
				 From #temp1 A
				 INNER JOIN #temp3 B On A.CustomerID=B.CustomerID

				 Update A
				 SET ReferenceDate=Case When ExposureBucketAlt_Key=1  Then Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01'))
				         When ExposureBucketAlt_Key=3 AND Convert(Date,'2019-06-07' )>Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01')) Then Convert(Varchar(10),'2019-06-07',103)
						When ExposureBucketAlt_Key=3 AND Convert(Date,'2019-06-07' )<Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01')) Then   Convert(Varchar(10),BorrowerDefaultDate ,103) 
						 When ExposureBucketAlt_Key=2 AND Convert(Date,'2020-01-01' )>Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01')) Then Convert(Varchar(10),'2019-06-07',103)   
						  When ExposureBucketAlt_Key=2 AND Convert(Date,'2020-01-01' )>Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01')) Then Convert(Varchar(10),BorrowerDefaultDate ,103) END
				

				 From #temp1 A
				 Where A.CustomerID In(Select CustomerID from #temp2)

				 Update A
				 SET A.BorroweDefaultStatus=B.DefaultStatus
				 From #temp1 A
				 INNER JOIN #temp4 B On A.CustomerID=B.CustomerID

				 
                        Update A
						 SET A.NameOf1stReportingBanklenderAlt_Key=B.BankName
						 
						 From #temp1 A
						 INNER JOIN DimBankRp B
						 ON A.NameOf1stReportingBanklenderAlt_Key2=B.BankRPAlt_Key

				  Select  A.PAN_No	,	
						A.UCIC_ID	,			
						A.CustomerID	,		
						A.CustomerName,			
						A.BankingArrangementAlt_Key ,
						Convert(Varchar(10),Convert(Date,A.BorrowerDefaultDate),103) BorrowerDefaultDate ,
						A.BorroweDefaultStatus,
						A.LeadBankAlt_Key ,
						A.DefaultStatusAlt_Key ,
						A.ExposureBucketAlt_Key ,
						--Convert(Varchar(10),Convert(Date,A.ReferenceDate),103) ReferenceDate,
						case when ISNULL(A.ReferenceDate,'1900-01-01')='1900-01-01' then NULL else convert(varchar(10),cast(A.ReferenceDate as date),103) end ReferenceDate, 
						Convert(Varchar(10),Convert(Date,A.ReviewExpiryDate),103)  ReviewExpiryDate ,
						--Convert(Varchar(10),Convert(Date,A.RP_ApprovalDate),103) as RP_ApprovalDate  ,
						RP_ApprovalDate,
						A.RPNatureAlt_Key ,
						A.If_Other ,
						Convert(Varchar(10),A.RP_ExpiryDate,103) RP_ExpiryDate ,
						Convert(Varchar(10),A.RP_ImplDate,103) RP_ImplDate  ,
						A.RP_ImplStatusAlt_Key ,
						A.RP_failed ,
							Revised_RP_Expiry_Date, 
						Actual_Impl_Date ,
						RP_OutOfDateAllBanksDeadline ,
						--Convert(Varchar(10),Convert(Date,A.Revised_RP_Expiry_Date),103) as Revised_RP_Expiry_Date, 
						--Convert(Varchar(10),Convert(Date,A.Actual_Impl_Date),103) Actual_Impl_Date ,
						--Convert(Varchar(10),Convert(Date,RP_OutOfDateAllBanksDeadline),103)  as RP_OutOfDateAllBanksDeadline ,
						A.RBLExposure,
						A.AssetClassAlt_Key ,
						Convert(Varchar(10),A.RiskReviewExpiryDate,103) RiskReviewExpiryDate ,  
						A.NameOf1stReportingBanklenderAlt_Key ,
						A.ICAStatusAlt_Key, 
						A.ReasonnotsigningICA	,		
						Convert(Varchar(10),A.ICAExecutionDate,103) as ICAExecutionDate ,
						Convert(Varchar(10),A.IBCFillingDate,103) IBCFillingDate ,
						Convert(Varchar(10),A.IBCAddmissionDate,103) IBCAddmissionDate ,
						A.IsActive,
						A.RevisedRPDeadline_Altkey,
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
							A.ModAppDate,'RPModule' TableName 
							,A.BucketName as IsBankExposure
							from #temp1 A
							Where ISNULL(A.IsActive,'N') ='Y'

				 --Select  * from #temp1
				
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
			

			 PRINT 'Sac16'
                 SELECT  		A.PAN_No	,	
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
						A.RevisedRPDeadline_Altkey,
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
							A.ApprovedByFirstLevel,
							A.DateApprovedFirstLevel,
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate,
								A.changefield
								,A.BucketName

                 INTO #temp16
                 FROM 
                 (
                     SELECT 				 						PAN_No		
						,UCIC_ID				
						,A.CustomerID			
						,CustomerName			
						,BankingArrangementAlt_Key 
						,BorrowerDefaultDate 
						,Convert(Varchar(20),'') as BorroweDefaultStatus
						,LeadBankAlt_Key 
						,DefaultStatusAlt_Key 
						,A.ExposureBucketAlt_Key 
						,Case When A.ExposureBucketAlt_Key=3 
						          AND Convert(Date,'2019-06-07' )>Convert(Date,BorrowerDefaultDate) 
							  Then Convert(Varchar(10),'2019-06-07',103)
						      When A.ExposureBucketAlt_Key=3 
						            AND Convert(Date,'2019-06-07' )<Convert(Date,BorrowerDefaultDate) 
							  Then   Convert(Varchar(10),BorrowerDefaultDate ,103) 
						      When A.ExposureBucketAlt_Key=2
							        AND Convert(Date,'2020-01-01' )>Convert(Date,BorrowerDefaultDate) 
							  Then Convert(Varchar(10),'2019-06-07',103)   
						      When A.ExposureBucketAlt_Key=2 
							        AND Convert(Date,'2020-01-01' )>Convert(Date,BorrowerDefaultDate)
							  Then Convert(Varchar(10),BorrowerDefaultDate ,103) END ReferenceDate 
						,ReviewExpiryDate 
						,Convert(Varchar(10),Convert(Date,RP_ApprovalDate),103) as RP_ApprovalDate 
						,RPNatureAlt_Key 
						,If_Other 
						,RP_ExpiryDate 
						,RP_ImplDate 
						,RP_ImplStatusAlt_Key 
						,RP_failed 
						,Convert(Varchar(10),Convert(Date,Revised_RP_Expiry_Date),103) AS  Revised_RP_Expiry_Date 
						,Convert(Varchar(10),Convert(Date,Actual_Impl_Date),103) AS Actual_Impl_Date 
						,Convert(Varchar(10),Convert(Date,RP_OutOfDateAllBanksDeadline),103) AS RP_OutOfDateAllBanksDeadline 
						,IsBankExposure as RBLExposure
						,AssetClassAlt_Key 
						,RiskReviewExpiryDate 
						,NameOf1stReportingBanklenderAlt_Key as NameOf1stReportingBanklenderAlt_Key2
                        ,Convert(Varchar(80),'') as NameOf1stReportingBanklenderAlt_Key
						,ICAStatusAlt_Key 
						,ReasonnotsigningICA			
						,Convert(Varchar(10),ICAExecutionDate,103) ICAExecutionDate
						,IBCFillingDate 
						,IBCAddmissionDate 
						,A.IsActive
						,RevisedRPDeadline_Altkey
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
							,A.ApprovedByFirstLevel
							,A.DateApprovedFirstLevel
							,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
								,A.changefield
								,c.BucketName
                     FROM RP_Portfolio_Details_Mod A
					 LEFT JOIN RP_Lender_Details B ON A.EntityKey=B.RPDetailsActiveCustomer_EntityKey
					 left join DimExposureBucket C ON C.ExposureBucketAlt_Key=A.ExposureBucketAlt_Key
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
						     
                           --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                           AND A.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM RP_Portfolio_Details_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')
							    GROUP BY EntityKey
                     )
                 ) A 
                      
                 
                 GROUP BY 
				 
				 	A.PAN_No	,	
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
						A.RevisedRPDeadline_Altkey,
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
							A.ApprovedByFirstLevel,
							A.DateApprovedFirstLevel,
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate,
								A.changefield
								,A.BucketName
                 SELECT * Into #temp5
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
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
--      AND RowNumber <= (@PageNo * @PageSize)


				 Select Distinct CustomerID into #temp6 from #temp5
				 --Select '#temp2', * from #temp2

				  Select X.CustomerID,Case when X.Less>0 Then 'in defualt' Else 'out of defualt' END as DefaultStatus Into #temp7
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

				


				 --Select max(InDefaultDate) InDefaultDate,CustomerID into #temp8 from RP_Lender_Details
				 --Where CustomerID In(Select CustomerID from #temp6)
				 --Group By CustomerID
				 --Order By CustomerID

				 Update A
				 SET A.BorrowerDefaultDate=B.InDefaultDate
				 From #temp5 A
				 INNER JOIN #temp8 B On A.CustomerID=B.CustomerID

				
				 Update A
				SET ReferenceDate=Case  When ExposureBucketAlt_Key=1 
				                        Then Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01'))
				    When ExposureBucketAlt_Key=3 
					     AND Convert(Date,'2019-06-07' )< Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01')) 
					Then Convert(Varchar(10),BorrowerDefaultDate ,103)
					When ExposureBucketAlt_Key=3 
					AND Convert(Date,'2019-06-07' )>Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01')) 
					Then     Convert(Varchar(10),'2019-06-07',103)
		            When ExposureBucketAlt_Key=2 
					AND Convert(Date,'2020-01-01' )<Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01')) 
					Then Convert(Varchar(10),'2019-06-07',103)   
				    When ExposureBucketAlt_Key=2 
					AND Convert(Date,'2020-01-01' )>Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01'))
					 Then Convert(Varchar(10),BorrowerDefaultDate ,103) END	

				 From #temp5 A
				 Where A.CustomerID In(Select CustomerID from #temp6)


				 --Update A
				 --SET ReferenceDate=Case When ExposureBucketAlt_Key=3 AND Convert(Date,'2019-06-07' )>Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01')) Then Convert(Varchar(10),'2019-06-07',103)
					--	When ExposureBucketAlt_Key=3 AND Convert(Date,'2019-06-07' )<Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01')) Then   Convert(Varchar(10),BorrowerDefaultDate ,103) 
					--	 When ExposureBucketAlt_Key=2 AND Convert(Date,'2020-01-01' )>Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01')) Then Convert(Varchar(10),'2019-06-07',103)   
					--	  When ExposureBucketAlt_Key=2 AND Convert(Date,'2020-01-01' )>Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01')) Then Convert(Varchar(10),BorrowerDefaultDate ,103) END
				

				 --From #temp1 A
				 --Where A.CustomerID In(Select CustomerID from #temp2)



				
				 Update A
				 SET A.BorroweDefaultStatus=B.DefaultStatus
				 From #temp5 A
				 INNER JOIN #temp7 B On A.CustomerID=B.CustomerID
				 
                         Update A
						 SET A.NameOf1stReportingBanklenderAlt_Key=B.BankName
						 
						 From #temp5 A
						 INNER JOIN DimBankRP B
						 ON A.NameOf1stReportingBanklenderAlt_Key2=B.BankRPAlt_Key

				 Select  	A.PAN_No	,	
						A.UCIC_ID	,			
						A.CustomerID	,		
						A.CustomerName,			
						A.BankingArrangementAlt_Key ,
						Convert(Varchar(10),Convert(Date,A.BorrowerDefaultDate),103) BorrowerDefaultDate ,
						A.BorroweDefaultStatus,
						A.LeadBankAlt_Key ,
						A.DefaultStatusAlt_Key ,
						A.ExposureBucketAlt_Key ,
						--Convert(Varchar(10),Convert(Date,A.ReferenceDate),103) ReferenceDate,
						case when ISNULL(A.ReferenceDate,'1900-01-01')='1900-01-01' then NULL else convert(varchar(10),cast(A.ReferenceDate as date),103) end ReferenceDate, 
						Convert(Varchar(10),A.ReviewExpiryDate,103)  ReviewExpiryDate ,
						
						RP_ApprovalDate,
						A.RPNatureAlt_Key ,
						A.If_Other ,
						Convert(Varchar(10),A.RP_ExpiryDate,103) RP_ExpiryDate ,
						Convert(Varchar(10),A.RP_ImplDate,103) RP_ImplDate  ,
						A.RP_ImplStatusAlt_Key ,
						A.RP_failed ,
						Revised_RP_Expiry_Date, 
						Actual_Impl_Date ,
						RP_OutOfDateAllBanksDeadline ,
						--Convert(Varchar(10),Convert(Date,A.Revised_RP_Expiry_Date),103) as Revised_RP_Expiry_Date, 
						--Convert(Varchar(10),Convert(Date,A.Actual_Impl_Date),103) Actual_Impl_Date ,
						--Convert(Varchar(10),Convert(Date,RP_OutOfDateAllBanksDeadline),103)  as RP_OutOfDateAllBanksDeadline ,
						A.RBLExposure,
						A.AssetClassAlt_Key ,
						Convert(Varchar(10),A.RiskReviewExpiryDate,103) RiskReviewExpiryDate , 
						A.NameOf1stReportingBanklenderAlt_Key ,
						A.ICAStatusAlt_Key, 
						A.ReasonnotsigningICA	,		
						Convert(Varchar(10),A.ICAExecutionDate,103) as ICAExecutionDate ,
						Convert(Varchar(10),A.IBCFillingDate,103) IBCFillingDate ,
						Convert(Varchar(10),A.IBCAddmissionDate,103) IBCAddmissionDate ,
						A.IsActive,
						A.RevisedRPDeadline_Altkey,
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
							A.ApprovedByFirstLevel,
							A.DateApprovedFirstLevel,
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate,'RPModule' TableName
							,A.BucketName as IsBankExposure from #temp5 A
									--Where ISNULL(A.IsActive,'N') ='Y'
   END;

   Else

IF (@OperationFlag =20)
             BEGIN
			  IF OBJECT_ID('TempDB..#temp9') IS NOT NULL DROP TABLE  #temp9;
			 IF OBJECT_ID('TempDB..#temp10') IS NOT NULL DROP TABLE  #temp10;
			  IF OBJECT_ID('TempDB..#temp11') IS NOT NULL DROP TABLE  #temp11;
			   IF OBJECT_ID('TempDB..#temp12') IS NOT NULL DROP TABLE  #temp12;
			 IF OBJECT_ID('TempDB..#temp20') IS NOT NULL
                 DROP TABLE #temp20;
                 SELECT  		A.PAN_No	,	
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
						A.RevisedRPDeadline_Altkey,
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
							A.ApprovedByFirstLevel,
							A.DateApprovedFirstLevel,
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate,
								A.changefields
								,A.BucketName

                 INTO #temp20
                 FROM 
                 (
                     SELECT 	PAN_No		
						,UCIC_ID				
						,A.CustomerID			
						,CustomerName			
						,BankingArrangementAlt_Key 
						,BorrowerDefaultDate 
						,Convert(Varchar(20),'') as BorroweDefaultStatus
						,LeadBankAlt_Key 
						,DefaultStatusAlt_Key 
						,A.ExposureBucketAlt_Key 
							--,Case When ExposureBucketAlt_Key  =2 
							--         AND Convert(Date,'2019-06-07' )>Convert(Date,BorrowerDefaultDate) 
							--      Then Convert(Varchar(10),'2019-06-07',103)
						 --         When ExposureBucketAlt_Key=1 
						 --                AND Convert(Date,'2019-06-07' )<Convert(Date,BorrowerDefaultDate) 
						 --         Then   Convert(Varchar(10),BorrowerDefaultDate ,103) 
						 --         When ExposureBucketAlt_Key=2 
							--	         AND Convert(Date,'2020-01-01' )>Convert(Date,BorrowerDefaultDate) 
							--	  Then Convert(Varchar(10),'2019-06-07',103)   
						 --         When ExposureBucketAlt_Key=2 
						 --                AND Convert(Date,'2020-01-01' )>Convert(Date,BorrowerDefaultDate) 
						 --         Then Convert(Varchar(10),BorrowerDefaultDate ,103) 
							--	  END ReferenceDate 
							,Case When A.ExposureBucketAlt_Key=3 
						          AND Convert(Date,'2019-06-07' )<Convert(Date,BorrowerDefaultDate) 
							  Then Convert(Varchar(10),'2019-06-07',103)
						      When A.ExposureBucketAlt_Key=3 
						            AND Convert(Date,'2019-06-07' )>Convert(Date,BorrowerDefaultDate) 
							  Then   Convert(Varchar(10),BorrowerDefaultDate ,103) 
						      When A.ExposureBucketAlt_Key=2
							        AND Convert(Date,'2020-01-01' )<Convert(Date,BorrowerDefaultDate) 
							  Then Convert(Varchar(10),'2019-06-07',103)   
						      When A.ExposureBucketAlt_Key=2 
							        AND Convert(Date,'2020-01-01' )>Convert(Date,BorrowerDefaultDate)
							  Then Convert(Varchar(10),BorrowerDefaultDate ,103) END ReferenceDate 
						,ReviewExpiryDate 
						,Convert(Date,RP_ApprovalDate) RP_ApprovalDate 
						,RPNatureAlt_Key 
						,If_Other 
						,RP_ExpiryDate 
						,RP_ImplDate 
						,RP_ImplStatusAlt_Key 
						,RP_failed 
						,Convert(Date,Revised_RP_Expiry_Date ) Revised_RP_Expiry_Date 
						,Convert(Date,Actual_Impl_Date) Actual_Impl_Date 
						,Convert(Date,RP_OutOfDateAllBanksDeadline) RP_OutOfDateAllBanksDeadline 
						,IsBankExposure RBLExposure
						,AssetClassAlt_Key 
						,RiskReviewExpiryDate 
						,NameOf1stReportingBanklenderAlt_Key as NameOf1stReportingBanklenderAlt_Key2
                         ,Convert(Varchar(80),'') as NameOf1stReportingBanklenderAlt_Key
						,ICAStatusAlt_Key 
						,ReasonnotsigningICA			
						,ICAExecutionDate 
						,IBCFillingDate 
						,IBCAddmissionDate 
						,A.IsActive
						,RevisedRPDeadline_Altkey
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
							,A.ApprovedByFirstLevel
							,A.DateApprovedFirstLevel
							,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
								,A.changefields
								,C.BucketName
                     FROM RP_Portfolio_Details_Mod A
					 LEFT JOIN RP_Lender_Details B ON A.EntityKey=B.RPDetailsActiveCustomer_EntityKey
					 Left join DimExposureBucket C ON C.ExposureBucketAlt_Key=A.ExposureBucketAlt_Key
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
						    
                           --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                           AND A.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM RP_Portfolio_Details_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
          AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('1A')
							    GROUP BY EntityKey
                     )
                 ) A 
                      
                 
                 GROUP BY 
				 
				 	A.PAN_No	,	
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
						A.RevisedRPDeadline_Altkey,
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
							A.ApprovedByFirstLevel,
							A.DateApprovedFirstLevel,
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate,
								A.changefields
								,A.BucketName
                 SELECT * Into #temp9
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
                      ) AS DataPointOwner
                 ) AS DataPointOwner
                 
				 Select Distinct CustomerID into #temp10 from #temp9
				 --Select '#temp2', * from #temp2

				  Select X.CustomerID
				  ,Case when X.Less>0 Then 'in defualt' Else 'out of defualt' END as DefaultStatus Into #temp11
				  from
				 (
				 Select CustomerID,Count(Case when DefaultStatus='in defualt' Then 1 END) as Less  
				 from RP_Lender_Details
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
				SET ReferenceDate=Case  When ExposureBucketAlt_Key=1 
				                        Then Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01'))
				    When ExposureBucketAlt_Key=3 
					     AND Convert(Date,'2019-06-07' )> Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01')) 
					Then Convert(Varchar(10),BorrowerDefaultDate ,103)
					When ExposureBucketAlt_Key=3 
					AND Convert(Date,'2019-06-07' )<Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01')) 
					Then     Convert(Varchar(10),'2019-06-07',103)
		            When ExposureBucketAlt_Key=2 
					AND Convert(Date,'2020-01-01' )>Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01')) 
					Then Convert(Varchar(10),'2019-06-07',103)   
				    When ExposureBucketAlt_Key=2 
					AND Convert(Date,'2020-01-01' )<Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01'))
					 Then Convert(Varchar(10),BorrowerDefaultDate ,103) END
				--SET ReferenceDate=Case When ExposureBucketAlt_Key=1  Then Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01'))
				--         When ExposureBucketAlt_Key=3 AND Convert(Date,'2019-06-07' )>Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01')) Then Convert(Varchar(10),'2019-06-07',103)
				--		When ExposureBucketAlt_Key=3 AND Convert(Date,'2019-06-07' )<Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01')) Then   Convert(Varchar(10),BorrowerDefaultDate ,103) 
				--		 When ExposureBucketAlt_Key=2 AND Convert(Date,'2020-01-01' )>Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01')) Then Convert(Varchar(10),'2019-06-07',103)   
				--		  When ExposureBucketAlt_Key=2 AND Convert(Date,'2020-01-01' )>Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01')) Then Convert(Varchar(10),BorrowerDefaultDate ,103) END
				

				 From #temp9 A
				 Where A.CustomerID In(Select CustomerID from #temp10)
				 --select * from #temp9
				 
				 --Update A
				 --SET ReferenceDate=Case When ExposureBucketAlt_Key=3 AND Convert(Date,'2019-06-07' )>Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01')) Then Convert(Varchar(10),BorrowerDefaultDate ,103)
					--	When ExposureBucketAlt_Key=3 AND Convert(Date,'2019-06-07' )<Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01')) Then     Convert(Varchar(10),'2019-06-07',103)
					--	 When ExposureBucketAlt_Key=2 AND Convert(Date,'2020-01-01' )>Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01')) Then Convert(Varchar(10),'2019-06-07',103)   
					--	  When ExposureBucketAlt_Key=2 AND Convert(Date,'2020-01-01' )>Convert(Date,ISNULL(BorrowerDefaultDate,'1900-01-01')) Then Convert(Varchar(10),BorrowerDefaultDate ,103) END
								

				 --From #temp5 A
				 --Where A.CustomerID In(Select CustomerID from #temp6)

				 Update A
				 SET A.BorroweDefaultStatus=B.DefaultStatus
				 From #temp9 A
				 INNER JOIN #temp11 B On A.CustomerID=B.CustomerID

				 --Select '#temp9',* from #temp9

                        Update A
						 SET A.NameOf1stReportingBanklenderAlt_Key=B.BankName
						 
						 From #temp9 A
						 INNER JOIN DimBankRP B
						 ON A.NameOf1stReportingBanklenderAlt_Key2=B.BankRPAlt_Key
SET DATEFORMAT DMY
				 Select  A.PAN_No	,	
						A.UCIC_ID	,			
						A.CustomerID	,		
						A.CustomerName,			
						A.BankingArrangementAlt_Key ,
						Convert(Varchar(10),Convert(Date,A.BorrowerDefaultDate),103) BorrowerDefaultDate ,
						A.BorroweDefaultStatus,
						A.LeadBankAlt_Key ,
						A.DefaultStatusAlt_Key ,
						A.ExposureBucketAlt_Key ,
						--Convert(Varchar(10),Convert(Date,A.ReferenceDate),103) ReferenceDate,
						--Convert(Varchar(10),Convert(Date,A.ReviewExpiryDate),103)  ReviewExpiryDate ,
						--Convert(Varchar(10),Convert(Date,A.RP_ApprovalDate),103) as RP_ApprovalDate  ,
						--Convert(Varchar(10),Convert(Date,A.ReferenceDate),103) ReferenceDate,
						case when ISNULL(A.ReferenceDate,'1900-01-01')='1900-01-01' then NULL else convert(varchar(10),cast(A.ReferenceDate as date),103) end ReferenceDate, 
						Convert(Varchar(10),A.ReviewExpiryDate,103)  ReviewExpiryDate ,
						Convert(Varchar(10),A.RP_ApprovalDate,103) RP_ApprovalDate,
						--RP_ApprovalDate,
						A.RPNatureAlt_Key ,
						A.If_Other ,
						Convert(Varchar(10),A.RP_ExpiryDate,103) RP_ExpiryDate ,
						Convert(Varchar(10),A.RP_ImplDate,103) RP_ImplDate  ,
						A.RP_ImplStatusAlt_Key ,
						A.RP_failed ,
						
						Convert(Varchar(10),Convert(Date,A.Revised_RP_Expiry_Date),103) as Revised_RP_Expiry_Date, 
						Convert(Varchar(10),Convert(Date,A.Actual_Impl_Date),103) Actual_Impl_Date ,
						Convert(Varchar(10),Convert(Date,RP_OutOfDateAllBanksDeadline),103)  as RP_OutOfDateAllBanksDeadline ,
						A.RBLExposure,
						A.AssetClassAlt_Key ,
						Convert(Varchar(10),A.RiskReviewExpiryDate,103) RiskReviewExpiryDate , 
						A.NameOf1stReportingBanklenderAlt_Key ,
						A.ICAStatusAlt_Key, 
						A.ReasonnotsigningICA	,		
						Convert(Varchar(10),A.ICAExecutionDate,103) as ICAExecutionDate ,
						Convert(Varchar(10),A.IBCFillingDate,103) IBCFillingDate ,
						Convert(Varchar(10),A.IBCAddmissionDate,103) IBCAddmissionDate ,
						A.IsActive,
						A.RevisedRPDeadline_Altkey,
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
							A.ApprovedByFirstLevel,
							A.DateApprovedFirstLevel,
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate,'RPModule' TableName
							,A.BucketName as IsBankExposure from #temp9 A
							--Where ISNULL(A.IsActive,'N') ='Y'
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