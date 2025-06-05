SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--exec CollateralMgmtSearchList @operationFlag=1,@newPage=1,@pageSize=50








--CollateralMgmtSearchList 1






CREATE PROC [dbo].[CollateralMgmtSearchList]
--Declare
													
													--@PageNo         INT         = 1, 
													--@PageSize       INT         = 10, 
													@OperationFlag  INT         = 20
													,@UCIF_ID Varchar(50)=''
													,@CustomerID1 Varchar(16)=''
												    ,@AccountID Varchar(16)=''
													
													,@Collateral Varchar(30)=''
													 ,@newPage SMALLINT =1     
													,@pageSize INT = 30000   
 
												--	,@CustomerID Varchar(30)
AS
     
	 BEGIN
	 --Declare @OperationFlag  INT

	 --Set @OperationFlag=1
SET NOCOUNT ON;
Declare @TimeKey as Int

DECLARE @PageFrom INT, @PageTo INT   
  
SET @PageFrom = (@pageSize*@newPage)-(@pageSize) +1  
SET @PageTo = @pageSize*@newPage  


Declare @LatestColletralSum Decimal(18,2),@LatestColletral1 Decimal(18,2)
Declare @Count Int,@I Int,@RowNumber Int,@CollateralID Varchar(30)

Declare @LatestColletralCount Int
Declare @CustomerID Varchar(30),@CustomerIDPre Varchar(30)

SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')


------------------Added on 03-04-2021 -----------------------------


IF OBJECT_ID('TempDB..#Tag1') IS NOT NULL Drop Table #Tag1


IF OBJECT_ID('TempDB..#temp101') IS NOT NULL Drop Table #temp101

Select 1 as TaggingAlt_Key,A.RefCustomerId as CustomerID,A.CollateralID,D.TotalCollateralValue into #Tag1 from Curdat.AdvSecurityDetail A
Inner Join (Select ParameterAlt_Key,ParameterName,'TaggingLevel' as Tablename 
						  from DimParameter where DimParameterName='DimRatingType'
						  and ParameterName not in ('Guarantor')
						  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)B
						  ON A.TaggingAlt_Key=B.ParameterAlt_Key
						  And A.TaggingAlt_Key=1
Inner Join (
Select A.RefCustomerId as CustomerID,Sum(C.CurrentValue)TotalCollateralValue from Curdat.AdvSecurityDetail A
Inner Join Curdat.AdvSecurityValueDetail C ON C.CollateralID=A.CollateralID
And C.EffectiveFromTimeKey<=@Timekey  and C.EffectiveToTimeKey>=@Timekey
Where A.EffectiveFromTimeKey<=@Timekey  and A.EffectiveToTimeKey>=@Timekey
Group By A.RefCustomerId)D ON D.CustomerID=A.RefCustomerId
Where A.EffectiveFromTimeKey<=@Timekey  and A.EffectiveToTimeKey>=@Timekey


IF OBJECT_ID('TempDB..#Tag2') IS NOT NULL
Drop Table #Tag2

Select 2 as TaggingAlt_Key,A.RefSystemAcId as AccountID,A.CollateralID,D.TotalCollateralValue into #Tag2 from Curdat.AdvSecurityDetail A
Inner Join (Select ParameterAlt_Key,ParameterName,'TaggingLevel' as Tablename 
						  from DimParameter where DimParameterName='DimRatingType'
						  and ParameterName not in ('Guarantor')
						  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)B
						  ON A.TaggingAlt_Key=B.ParameterAlt_Key
						  And A.TaggingAlt_Key=2
Inner Join (
Select A.RefSystemAcId as AccountID,Sum(C.CurrentValue)TotalCollateralValue from Curdat.AdvSecurityDetail A
Inner Join Curdat.AdvSecurityValueDetail C ON C.CollateralID=A.CollateralID
And C.EffectiveFromTimeKey<=@Timekey  and C.EffectiveToTimeKey>=@Timekey
Where A.EffectiveFromTimeKey<=@Timekey  and A.EffectiveToTimeKey>=@Timekey
Group By A.RefSystemAcId)D ON D.AccountID=A.RefSystemAcId
Where A.EffectiveFromTimeKey<=@Timekey  and A.EffectiveToTimeKey>=@Timekey
-------------------------------------------------


BEGIN TRY

/*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */

			IF(@OperationFlag not in ( 16,17,20))
   BEGIN
			 IF OBJECT_ID('TempDB..#temp') IS NOT NULL DROP TABLE  #temp;
			 IF OBJECT_ID('TempDB..#temp101') IS NOT NULL DROP TABLE  #temp101;
             IF OBJECT_ID('TempDB..#temp103') IS NOT NULL DROP TABLE  #temp103;   
			 IF OBJECT_ID('TempDB..#temp104') IS NOT NULL DROP TABLE  #temp104;  
			 IF OBJECT_ID('TempDB..#temp105') IS NOT NULL DROP TABLE  #temp105; 
			 IF OBJECT_ID('TempDB..#temp1061') IS NOT NULL DROP TABLE #temp1061;
			 IF OBJECT_ID('TempDB..#temp1021') IS NOT NULL DROP TABLE #temp1021;
			 IF OBJECT_ID('TempDB..#temp181') IS NOT NULL DROP TABLE #temp181;
			 IF OBJECT_ID('TempDB..#temp182') IS NOT NULL DROP TABLE #temp182;
			 IF OBJECT_ID('TempDB..#temp186') IS NOT NULL DROP TABLE #temp186;
			  IF OBJECT_ID('TempDB..#temp187') IS NOT NULL DROP TABLE #temp187;
			 IF OBJECT_ID('TempDB..#temp188') IS NOT NULL DROP TABLE #temp188;
                 SELECT		
							A.AccountID
							,A.UCICID
							,A.CustomerID
							,A.CustomerName
							,A.TaggingAlt_Key
							,A.TaggingLevel
							,A.DistributionAlt_Key
							,A.DistributionModel
							,A.CollateralID
							,A.CollateralCode
							,A.CollateralTypeAlt_Key
							,A.CollateralTypeDescription
							,A.CollateralSubTypeAlt_Key
							,A.CollateralSubTypeDescription
							,A.CollateralOwnerTypeAlt_Key
							,A.CollOwnerDescription
							,A.CollateralOwnerShipTypeAlt_Key
							,A. CollateralOwnershipType
							,A.ChargeTypeAlt_Key

							,A.CollChargeDescription
							,A.ChargeNatureAlt_Key
							,A.SecurityChargeTypeName
							,A.ShareAvailabletoBankAlt_Key
							,A.ShareAvailabletoBank
							,A.CollateralShareamount
							,A.TotalCollateralvalueatcustomerlevel
							,A.OldCollateralID
							--,A.TotCollateralsUCICCustAcc
							,A.IfPercentagevalue_or_Absolutevalue

							,A.AuthorisationStatus
						    ,A.CollateralValueatSanctioninRs  
							,A.CollateralValueasonNPAdateinRs,
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
							 A.ModAppByFirst,
							A.ModAppDateFirst
                 INTO #temp
                 FROM 
                 (
                     SELECT 
							
							A.RefSystemAcId as AccountID
							,A.UCICID
							,A.RefCustomerId as CustomerID
							,A.CustomerName
							,A.TaggingAlt_Key
							,B.ParameterName as TaggingLevel
							,A.DistributionAlt_Key
							,C.ParameterName as DistributionModel
							,A.CollateralID
							,A.CollateralCode
							,A.SecurityAlt_Key as CollateralTypeAlt_Key
							,E.CollateralTypeDescription
							,A.CollateralSubTypeAlt_Key
							,F.CollateralSubTypeDescription
							,A.OwnerTypeAlt_Key as CollateralOwnerTypeAlt_Key
							,G.CollOwnerDescription
							,A.CollateralOwnerShipTypeAlt_Key
							,H.ParameterName as CollateralOwnershipType
							,A.SecurityChargeTypeAlt_Key as ChargeTypeAlt_Key
							,I.CollChargeDescription
							,A.ChargeNatureAlt_Key
							,J.SecurityChargeTypeName
							,A.ShareAvailabletoBankAlt_Key
							,D.ParameterName as ShareAvailabletoBank
							,A.CollateralShareamount
							,(Case When A.TaggingAlt_Key=1 Then T1.TotalCollateralValue
									When A.TaggingAlt_Key=2 Then T2.TotalCollateralValue End)TotalCollateralvalueatcustomerlevel
						   ,A.Security_RefNo as OldCollateralID
							,A.IfPercentagevalue_or_Absolutevalue							
							,isnull(A.AuthorisationStatus, 'A') AuthorisationStatus
							,A.CollateralValueatSanctioninRs  
							,A.CollateralValueasonNPAdateinRs 
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
							,ISNULL(A.ApprovedByFirstLevel,A.CreatedBy) as ModAppByFirst
							,ISNULL(A.DateApprovedFirstLevel,A.DateCreated) as ModAppDateFirst
                     FROM Curdat.AdvSecurityDetail A
					 Inner Join (Select ParameterAlt_Key,ParameterName,'TaggingLevel' as Tablename 
						  from DimParameter where DimParameterName='DimRatingType'
						  and ParameterName not in ('Guarantor')
						  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)B
						  ON A.TaggingAlt_Key=B.ParameterAlt_Key
						  Inner Join (Select ParameterAlt_Key,ParameterName,'DistributionModel' as Tablename 
						  from DimParameter where DimParameterName='Collateral'
						  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)C
						  ON A.DistributionAlt_Key=C.ParameterAlt_Key
						  Inner Join (Select ParameterAlt_Key,ParameterName,'ShareAvailabletoBank' as Tablename 
						  from DimParameter where DimParameterName='CollateralBank'
						  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)D
						  ON A.ShareAvailabletoBankAlt_Key=D.ParameterAlt_Key
						  inner join DimCollateralType E
						  ON A.SecurityAlt_Key=E.CollateralTypeAltKey
						  AND E.EffectiveFromTimeKey<=@Timekey And E.EffectiveToTimeKey>=@TimeKey
						  inner join DimCollateralSubType F
						  ON A.CollateralSubTypeAlt_Key=F.CollateralSubTypeAltKey 
						  And F.EffectiveFromTimeKey<=@Timekey And F.EffectiveToTimeKey>=@TimeKey
						  Inner join DimCollateralOwnerType G
						  ON A.OwnerTypeAlt_Key=G.CollateralOwnerTypeAltKey
						  And G.EffectiveFromTimeKey<=@Timekey And G.EffectiveToTimeKey>=@TimeKey
						  Inner Join (Select ParameterAlt_Key,ParameterName,'CollateralOwnershipType' as Tablename 
						  from DimParameter where DimParameterName='CollateralOwnershipType'
						  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)H
						  ON A.CollateralOwnerShipTypeAlt_Key=H.ParameterAlt_Key
						  Inner join DimCollateralChargeType I
						  ON A.SecurityChargeTypeAlt_Key=I.CollateralChargeTypeAltKey
						  And I.EffectiveFromTimeKey<=@Timekey And I.EffectiveToTimeKey>=@TimeKey
						  Inner Join DimSecurityChargeType J
						  On A.ChargeNatureAlt_Key=J.SecurityChargeTypeAlt_Key
						  And J.EffectiveFromTimeKey<=@Timekey And J.EffectiveToTimeKey>=@TimeKey
						  AND SecurityChargeTypeGroup='COLLATERAL'
						  Left Join #Tag1 T1 ON T1.CollateralID=A.CollateralID
						  Left Join #Tag2 T2 ON T2.CollateralID=A.CollateralID
						 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
                     UNION
                     SELECT 
							A.RefSystemAcId as AccountID
							,A.UCICID
							,A.RefCustomerId as CustomerID
							,A.CustomerName
							,A.TaggingAlt_Key
							,B.ParameterName as TaggingLevel
							,A.DistributionAlt_Key
							,C.ParameterName as DistributionModel
							,A.CollateralID
							,A.CollateralCode
							,A.SecurityAlt_Key as CollateralTypeAlt_Key
							,E.CollateralTypeDescription
							,A.CollateralSubTypeAlt_Key
							,F.CollateralSubTypeDescription
							,A.OwnerTypeAlt_Key as CollateralOwnerTypeAlt_Key
							,G.CollOwnerDescription
							,A.CollateralOwnerShipTypeAlt_Key
							,H.ParameterName as CollateralOwnershipType
							,A.SecurityChargeTypeAlt_Key as ChargeTypeAlt_Key
							,I.CollChargeDescription
							,A.ChargeNatureAlt_Key
							,J.SecurityChargeTypeName
							,A.ShareAvailabletoBankAlt_Key
							,D.ParameterName as ShareAvailabletoBank
							,A.CollateralShareamount
							--,A.TotalCollateralvalueatcustomerlevel
							,(Case When A.TaggingAlt_Key=1 Then T1.TotalCollateralValue
									When A.TaggingAlt_Key=2 Then T2.TotalCollateralValue End)TotalCollateralvalueatcustomerlevel
								,A.Security_RefNo as OldCollateralID
							--,A.TotCollateralsUCICCustAcc
							,A.IfPercentagevalue_or_Absolutevalue
							
							,isnull(A.AuthorisationStatus, 'A') AuthorisationStatus
							,A.CollateralValueatSanctioninRs  
							,A.CollateralValueasonNPAdateinRs 
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
							,ISNULL(A.ApprovedByFirstLevel,A.CreatedBy) as ModAppByFirst
							,ISNULL(A.DateApprovedFirstLevel,A.DateCreated) as ModAppDateFirst
                     FROM DBO.AdvSecurityDetail_Mod A
					 Inner Join (Select ParameterAlt_Key,ParameterName,'TaggingLevel' as Tablename 
						  from DimParameter where DimParameterName='DimRatingType'
						  and ParameterName not in ('Guarantor')
						  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)B
						  ON A.TaggingAlt_Key=B.ParameterAlt_Key
						  Inner Join (Select ParameterAlt_Key,ParameterName,'DistributionModel' as Tablename 
						  from DimParameter where DimParameterName='Collateral'
						  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)C
						  ON A.DistributionAlt_Key=C.ParameterAlt_Key
						  Inner Join (Select ParameterAlt_Key,ParameterName,'ShareAvailabletoBank' as Tablename 
						  from DimParameter where DimParameterName='CollateralBank'
						  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)D
						  ON A.ShareAvailabletoBankAlt_Key=D.ParameterAlt_Key
						  inner join DimCollateralType E
						  ON A.SecurityAlt_Key=E.CollateralTypeAltKey
						  AND E.EffectiveFromTimeKey<=@Timekey And E.EffectiveToTimeKey>=@TimeKey
						  inner join DimCollateralSubType F
						  ON A.CollateralSubTypeAlt_Key=F.CollateralSubTypeAltKey 
						  And F.EffectiveFromTimeKey<=@Timekey And F.EffectiveToTimeKey>=@TimeKey
						  Inner join DimCollateralOwnerType G
						  ON A.OwnerTypeAlt_Key=G.CollateralOwnerTypeAltKey
						  And G.EffectiveFromTimeKey<=@Timekey And G.EffectiveToTimeKey>=@TimeKey
						  Inner Join (Select ParameterAlt_Key,ParameterName,'CollateralOwnershipType' as Tablename 
						  from DimParameter where DimParameterName='CollateralOwnershipType'
						  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)H
						  ON A.CollateralOwnerShipTypeAlt_Key=H.ParameterAlt_Key
						  Inner join DimCollateralChargeType I
						  ON A.SecurityChargeTypeAlt_Key=I.CollateralChargeTypeAltKey
						  And I.EffectiveFromTimeKey<=@Timekey And I.EffectiveToTimeKey>=@TimeKey
						  Inner Join DimSecurityChargeType J
						  On A.ChargeNatureAlt_Key=J.SecurityChargeTypeAlt_Key
						  And J.EffectiveFromTimeKey<=@Timekey And J.EffectiveToTimeKey>=@TimeKey
						  AND SecurityChargeTypeGroup='COLLATERAL'
						  Left Join #Tag1 T1 ON T1.CollateralID=A.CollateralID
						  Left Join #Tag2 T2 ON T2.CollateralID=A.CollateralID
						 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
        --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                           AND A.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
  FROM DBO.AdvSecurityDetail_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
    AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')
                         GROUP BY CollateralID
                     )
                 ) A 
      
                 
   GROUP BY	
							A.AccountID
							,A.UCICID
							,A.CustomerID
							,A.CustomerName
							,A.TaggingAlt_Key
							,A.TaggingLevel
							,A.DistributionAlt_Key
							,A.DistributionModel
							,A.CollateralID
							,A.CollateralCode
							,A.CollateralTypeAlt_Key
							,A.CollateralTypeDescription
							,A.CollateralSubTypeAlt_Key
							,A.CollateralSubTypeDescription
							,A.CollateralOwnerTypeAlt_Key
							,A.CollOwnerDescription
							,A.CollateralOwnerShipTypeAlt_Key
							,A. CollateralOwnershipType
							,A.ChargeTypeAlt_Key
							,A.CollChargeDescription
							,A.ChargeNatureAlt_Key
							,A.SecurityChargeTypeName
							,A.ShareAvailabletoBankAlt_Key
							,A.ShareAvailabletoBank
							,A.CollateralShareamount
							,A.TotalCollateralvalueatcustomerlevel
								,A.OldCollateralID
							--,A.TotCollateralsUCICCustAcc
							,A.IfPercentagevalue_or_Absolutevalue
							,A.AuthorisationStatus 
							 ,A.CollateralValueatSanctioninRs  
							,A.CollateralValueasonNPAdateinRs,
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
							 A.ModAppByFirst,
							A.ModAppDateFirst;

					--     Drop Table 		 #temp101

					

                 SELECT *
				 INTO #temp101
				 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY CollateralID) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'Collateral' TableName, 
                            *,len(AuthorisationStatus) as AuthorisationStatuslen
                     FROM
                     (
                         SELECT *
                         FROM #temp A
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner

				 order by DateCreated desc  --updated by vinit
				-- order by DataPointOwner.AuthorisationStatuslen desc --uncooment by vinit


				 ------------------------------------------------------------------------
				 Update #temp101
										SET TotalCollateralvalueatcustomerlevel=NULL,
										TotalCount=NULL
			-----------------------------------------------------------------------------------------
			--select * into #temp1021 from #temp101

			--Select '#temp1021',* from #temp1021
			--Start Customer
				
					Select  ROW_NUMBER() OVER(ORDER BY  CONVERT(VARCHAR(50),CustomerID) ) RecentRownumber,* INTO #temp103 from #temp101 
					Where TaggingAlt_Key=1 and AuthorisationStatus in('A')

					
					--Select '#temp101',*from #temp101
					--   Select '#temp103',* from #temp103

			       
					Select @Count=Count(*) from #temp103 
					
				 
				
				 
				 SET @I=1
				 SET @LatestColletralSum=0
				 SET @CustomerIDPre=''
				 SET @CustomerID=''
				 SET @LatestColletralCount=0
			
				 While(@I<=@Count)
					BEGIN
					      
							Select @CollateralID=CollateralID,@CustomerID =CustomerID  from #temp103 where RecentRownumber=@I 
							order By CONVERT(VARCHAR(50),CustomerID)
           
							   IF (@I=1)
							      BEGIN
									SET @CustomerIDPre=@CustomerID
								   END
					     
						    
							 
							 IF (@CustomerIDPre<> @CustomerID)
									BEGIN
									
										Update #temp103
										SET TotalCollateralvalueatcustomerlevel=@LatestColletralSum,
										TotalCount=@LatestColletralCount where  CustomerID =@CustomerIDPre and TaggingAlt_Key=1
										Update #temp101
										SET TotalCollateralvalueatcustomerlevel=@LatestColletralSum,
										TotalCount=@LatestColletralCount where  CustomerID =@CustomerIDPre and TaggingAlt_Key=1
										SET @LatestColletral1=0
										SET @LatestColletralSum=0
										SET @LatestColletralCount=0
										 SET @CustomerIDPre=@CustomerID
									END


									 IF (@CustomerIDPre= @CustomerID)
										 BEGIN
										
										Select @LatestColletral1=ISNULL(CurrentValue,0)
										from Curdat.AdvSecurityValueDetail A
										INNER JOIN Curdat.AdvSecurityDetail  B ON A.CollateralID=B.CollateralID Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey And A.CollateralID=@CollateralID
										And ValuationDate=(select Max(ValuationDate)ValuationDate from Curdat.AdvSecurityValueDetail where EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey
										And CollateralID=@CollateralID)
										AND B.RefCustomerId=@CustomerID

								 SET    @LatestColletralSum=@LatestColletralSum+@LatestColletral1
								 SET    @LatestColletralCount=@LatestColletralCount+1
								
								 --Print '@LatestColletral1'
								 --Print @LatestColletral1
								 -- Print '@@LatestColletralSum'
								 --Print @LatestColletralSum
								 
									SET  @I=@I+1
									SET @LatestColletral1=0
									END
				   END
			
			            Update #temp103
						SET TotalCollateralvalueatcustomerlevel=@LatestColletralSum,
						 TotalCount=@LatestColletralCount where  CustomerID =@CustomerIDPre and TaggingAlt_Key=1
					

				       Update #temp101
										SET TotalCollateralvalueatcustomerlevel=@LatestColletralSum,
										TotalCount=@LatestColletralCount where  CustomerID =@CustomerIDPre and TaggingAlt_Key=1

					
     ---END
							--Start  ACccount
				
					Select  ROW_NUMBER() OVER(ORDER BY  CONVERT(VARCHAR(50),CustomerID) ) RecentRownumber,* INTO #temp104 from #temp101 
					Where TaggingAlt_Key=2 and AuthorisationStatus in('A')
 

					--Select '#temp101',* from #temp101
					--		Select '#temp104',* from #temp104
			       
					Select @Count=Count(*) from #temp104
					
				
				 
				 SET @I=1
				 SET @LatestColletralSum=0
				 SET @CustomerIDPre=''
				 SET @CustomerID=''
				 SET @LatestColletralCount=0
				 SET @LatestColletral1=0
				 --PRINT @Cou1nt
				 While(@I<=@Count)
					BEGIN
					      
							Select @CollateralID=CollateralID,@CustomerID =AccountID  from #temp104 where RecentRownumber=@I 
							order By CONVERT(VARCHAR(50),CustomerID)
                               
							   IF (@I=1)
							      BEGIN
									SET @CustomerIDPre=@CustomerID
								   END
					     
						    
							 
							 IF (@CustomerIDPre<> @CustomerID)
									BEGIN
									
										Update #temp104
										SET TotalCollateralvalueatcustomerlevel=@LatestColletralSum,
										TotalCount=@LatestColletralCount where  AccountID =@CustomerIDPre and TaggingAlt_Key=2
										 Update #temp101
						                 SET TotalCollateralvalueatcustomerlevel=@LatestColletralSum,
						                 TotalCount=@LatestColletralCount where  AccountID =@CustomerIDPre and TaggingAlt_Key=2  
										SET @LatestColletral1=0
										SET @LatestColletralSum=0
										SET @LatestColletralCount=0
										 SET @CustomerIDPre=@CustomerID
									END


									 IF (@CustomerIDPre= @CustomerID)
										 BEGIN
										
										Select @LatestColletral1=ISNULL(CurrentValue,0)
										from Curdat.AdvSecurityValueDetail A
										INNER JOIN Curdat.AdvSecurityDetail  B ON A.CollateralID=B.CollateralID Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey And A.CollateralID=@CollateralID
										And ValuationDate=(select Max(ValuationDate)ValuationDate from Curdat.AdvSecurityValueDetail where EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey
										And CollateralID=@CollateralID)
										AND B.RefSystemAcId=@CustomerID

								 SET    @LatestColletralSum=@LatestColletralSum+@LatestColletral1
								 SET  @LatestColletralCount=@LatestColletralCount+1
								 
								 Print  'Account'
								 PRINT '@CollateralID'
								 PRINT @CollateralID
								 Print '@LatestColletral1'
								 Print @LatestColletral1
								  Print '@@LatestColletralSum'
								 Print @LatestColletralSum
								 
									SET  @I=@I+1
									SET @LatestColletral1=0
									
									END
				   END
			
			            Update #temp104
						SET TotalCollateralvalueatcustomerlevel=@LatestColletralSum,
						 TotalCount=@LatestColletralCount where  AccountID =@CustomerIDPre and TaggingAlt_Key=2

						    Update #temp101
						SET TotalCollateralvalueatcustomerlevel=@LatestColletralSum,
						 TotalCount=@LatestColletralCount where  AccountID =@CustomerIDPre and TaggingAlt_Key=2
					
				    --Select '#temp101',*from #temp101
					--Select '#temp103',* from #temp103
					--Select '#temp104',* from #temp104

						--Select '#temp104',* from #temp104
     ---END

	 	--Start  UCIC
				
					Select  ROW_NUMBER() OVER(ORDER BY  CONVERT(VARCHAR(50),CustomerID) ) RecentRownumber,* INTO #temp105 from #temp101 
					Where TaggingAlt_Key=4 and AuthorisationStatus in('A')


					--Print '#temp101'
					--   Select '#temp101',* from #temp101
					--Print '#temp105'
					--   Select '#temp105',* from #temp105

			       
					Select @Count=Count(*) from #temp105
					--Select * from #temp101
				 --   Select * from #temp103
				
				 
				 SET @I=1
				 SET @LatestColletralSum=0
				 SET @CustomerIDPre=''
				 SET @CustomerID=''
				 SET @LatestColletralCount=0
				 SET @LatestColletral1=0
				 PRINT @Count
				 While(@I<=@Count)
					BEGIN
					      
							Select @CollateralID=CollateralID,@CustomerID =UCICID  from #temp105 where RecentRownumber=@I 
							order By CONVERT(VARCHAR(50),CustomerID)
                               
							   IF (@I=1)
							      BEGIN
									SET @CustomerIDPre=@CustomerID
								   END
					     
						    
							 
							 IF (@CustomerIDPre<> @CustomerID)
									BEGIN
									
										Update #temp105
										SET TotalCollateralvalueatcustomerlevel=@LatestColletralSum,
										TotalCount=@LatestColletralCount where  UCICID =@CustomerIDPre  and TaggingAlt_Key=4
										Update #temp101
										SET TotalCollateralvalueatcustomerlevel=@LatestColletralSum,
										TotalCount=@LatestColletralCount where  UCICID =@CustomerIDPre  and TaggingAlt_Key=4
										SET @LatestColletral1=0
										SET @LatestColletralSum=0
										SET @LatestColletralCount=0
										 SET @CustomerIDPre=@CustomerID
									END


									 IF (@CustomerIDPre= @CustomerID)
										 BEGIN
										
										Select @LatestColletral1=ISNULL(CurrentValue,0)
										from Curdat.AdvSecurityValueDetail A
										INNER JOIN Curdat.AdvSecurityDetail  B ON A.CollateralID=B.CollateralID Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey And A.CollateralID=@CollateralID
										And ValuationDate=(select Max(ValuationDate)ValuationDate from Curdat.AdvSecurityValueDetail where EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey
										And CollateralID=@CollateralID)
										AND B.UCICID=@CustomerID

								 SET    @LatestColletralSum=@LatestColletralSum+@LatestColletral1
								 SET    @LatestColletralCount=@LatestColletralCount+1
								
								 --Print '@LatestColletral1'
								 --Print @LatestColletral1
								 -- Print '@@LatestColletralSum'
								 --Print @LatestColletralSum
								 
									SET  @I=@I+1
									SET @LatestColletral1=0
									END
				   END
			
			            Update #temp105
						SET TotalCollateralvalueatcustomerlevel=@LatestColletralSum,
						 TotalCount=@LatestColletralCount where  UCICID =@CustomerIDPre and TaggingAlt_Key=4

						 Update #temp101
										SET TotalCollateralvalueatcustomerlevel=@LatestColletralSum,
										TotalCount=@LatestColletralCount where  UCICID =@CustomerIDPre  and TaggingAlt_Key=4

						--     Update #tmp
						--SET #tmp.TotalCollateralvalueatcustomerlevel=#temp105.TotalCollateralvalueatcustomerlevel,
						-- #tmp.TotalCount=#temp105.TotalCount 
						-- From #tmp INNER JOIN  #tmp104 ON #tmp.CustomerID=#temp105.CustomerID where #tmp.TaggingAlt_Key=4

						 --Select * from #temp105
     ---END
					  
					  ----Select * from #temp103
					  ----UNION
					  ----Select * from #temp104
					  ----UNION
					  ---- Select * from #temp105
					  --  ROW_NUMBER() OVER(ORDER BY  CONVERT(VARCHAR(50),RecentRownumber))  RowsNum,

					--  Select ROW_NUMBER() OVER(ORDER BY  CONVERT(VARCHAR(50),RecentRownumber))  RowsNum,X.* INTO #temp1061  From 
					--  (
					--    Select  * from #temp103
					--  UNION ALL
					--  Select * from #temp104
					-- UNION ALL
					--   Select * from #temp105
					--) X

					--Select '#temp101',* from #temp101
					
					--   Select  * from #temp101
     --            WHERE Rownumber BETWEEN @PageFrom AND @PageTo
				 --order by AuthorisationStatuslen desc, DateCreated desc
IF (ISNULL(@UCIF_ID,'')<>'' AND ISNULL(@Collateral,'')='' AND ISNULL(@CustomerID1,'')='' AND ISNULL(@AccountID,'')='')
		BEGIN
		--SElect *  INTO #temp181  From(
		  Select ROW_NUMBER() OVER( ORDER BY (select 1)) ROWID,A.*
		 INTO #temp181 from #temp101 A 
		
		 WHERE 
		   ISNULL(UCICID,'')=@UCIF_ID
		 
		 Select * from #temp181 A
		 where A.ROWID BETWEEN @PageFrom AND @PageTo 
	END

IF (ISNULL(@UCIF_ID,'')='' AND ISNULL(@Collateral,'')<>'' AND ISNULL(@CustomerID1,'')='' AND ISNULL(@AccountID,'')='')
		BEGIN
		PRINT 'Sac2'
		--SElect *  INTO #temp181  From(
		  Select ROW_NUMBER() OVER( ORDER BY (select 1)) ROWID,A.* 
		 INTO #temp183 from #temp101 A 
		  
		 WHERE 
		   ISNULL(A.CollateralID,'')=@Collateral
		 
		 Select * from #temp183 A
		 where A.ROWID BETWEEN @PageFrom AND @PageTo 
	END

	IF (ISNULL(@UCIF_ID,'')='' AND ISNULL(@Collateral,'')='' AND ISNULL(@CustomerID1,'')='' AND ISNULL(@AccountID,'')<>'')
		BEGIN
		PRINT 'Sac2'
		--SElect *  INTO #temp181  From(
		  Select ROW_NUMBER() OVER( ORDER BY (select 1)) ROWID,A.* 
		 INTO #temp187 from #temp101 A 
		  
		 WHERE 
		   ISNULL(A.AccountID,'')=@AccountID
		 
		 Select * from #temp187 A
		 where A.ROWID BETWEEN @PageFrom AND @PageTo 
	END

IF (ISNULL(@UCIF_ID,'')='' AND ISNULL(@Collateral,'')='' AND ISNULL(@CustomerID1,'')<>'' AND ISNULL(@AccountID,'')='')
		BEGIN
		PRINT 'Sac2'
		--SElect *  INTO #temp181  From(
		  Select ROW_NUMBER() OVER( ORDER BY (select 1)) ROWID,A.* 
		 INTO #temp188 from #temp101 A 
		  
		 WHERE 
		   ISNULL(A.CustomerID,'')=@CustomerID1
		 
		 Select * from #temp188 A
		 where A.ROWID BETWEEN @PageFrom AND @PageTo 
	END

	IF (ISNULL(@UCIF_ID,'')='' AND ISNULL(@Collateral,'')='' AND ISNULL(@CustomerID1,'')='' AND ISNULL(@AccountID,'')='')
		BEGIN
		  Select ROW_NUMBER() OVER( ORDER BY CrModDate desc) RowORD,A.* INTO #temp186
		  from #temp101 A 
		  
		

		
		  Select * from #temp186 A
		 WHERE A.RowORD BETWEEN @PageFrom AND @PageTo

	

	END


             END;
             ELSE

			 /*  IT IS Used For GRID Search which are Pending for Authorization    */
			 IF (@OperationFlag in (16,17))

             BEGIN
			IF OBJECT_ID('TempDB..#temp16') IS NOT NULL DROP TABLE #temp16;   
			IF OBJECT_ID('TempDB..#temp102') IS NOT NULL DROP TABLE #temp102;
			IF OBJECT_ID('TempDB..#temp106') IS NOT NULL DROP TABLE #temp106;
			IF OBJECT_ID('TempDB..#temp107') IS NOT NULL DROP TABLE #temp107;
			IF OBJECT_ID('TempDB..#temp108') IS NOT NULL DROP TABLE #temp108;
			IF OBJECT_ID('TempDB..#temp1091') IS NOT NULL DROP TABLE #temp1091;

			IF OBJECT_ID('TempDB..#temp184') IS NOT NULL DROP TABLE #temp184;
			IF OBJECT_ID('TempDB..#temp185') IS NOT NULL DROP TABLE #temp185;
			IF OBJECT_ID('TempDB..#temp191') IS NOT NULL DROP TABLE #temp191;

			IF OBJECT_ID('TempDB..#temp189') IS NOT NULL DROP TABLE #temp189;
			IF OBJECT_ID('TempDB..#temp190') IS NOT NULL DROP TABLE #temp190;


                 SELECT
							A.AccountID
							,A.UCICID
							,A.CustomerID
							,A.CustomerName
							,A.TaggingAlt_Key
							,A.TaggingLevel
							,A.DistributionAlt_Key
							,A.DistributionModel
							,A.CollateralID
							,A.CollateralCode
							,A.CollateralTypeAlt_Key
							,A.CollateralTypeDescription
							,A.CollateralSubTypeAlt_Key
							,A.CollateralSubTypeDescription
							,A.CollateralOwnerTypeAlt_Key
							,A.CollOwnerDescription
							,A.CollateralOwnerShipTypeAlt_Key
							,A. CollateralOwnershipType
							,A.ChargeTypeAlt_Key
							,A.CollChargeDescription
							,A.ChargeNatureAlt_Key
							,A.SecurityChargeTypeName
							,A.ShareAvailabletoBankAlt_Key
							,A.ShareAvailabletoBank
							,A.CollateralShareamount
							,A.TotalCollateralvalueatcustomerlevel
							,A.OldCollateralID
							--,A.TotCollateralsUCICCustAcc
							,A.IfPercentagevalue_or_Absolutevalue
							,A.AuthorisationStatus
							 ,A.CollateralValueatSanctioninRs  
							,A.CollateralValueasonNPAdateinRs,
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
			                A.ModAppByFirst,
							A.ModAppDateFirst
			                 INTO #temp16
                 FROM 
                 (
                     SELECT 
							A.RefSystemAcId as AccountID
							,A.UCICID
							,A.RefCustomerId as CustomerID
							,A.CustomerName
							,A.TaggingAlt_Key
							,B.ParameterName as TaggingLevel
							,A.DistributionAlt_Key
							,C.ParameterName as DistributionModel
							,A.CollateralID
							,A.CollateralCode
							,A.SecurityAlt_Key as CollateralTypeAlt_Key
							,E.CollateralTypeDescription
							,A.CollateralSubTypeAlt_Key
							,F.CollateralSubTypeDescription
							,A.OwnerTypeAlt_Key as CollateralOwnerTypeAlt_Key
							,G.CollOwnerDescription
							,A.CollateralOwnerShipTypeAlt_Key
							,H.ParameterName as CollateralOwnershipType
							,A.SecurityChargeTypeAlt_Key as ChargeTypeAlt_Key
							,I.CollChargeDescription
							,A.ChargeNatureAlt_Key
							,J.SecurityChargeTypeName
							,A.ShareAvailabletoBankAlt_Key
							,D.ParameterName as ShareAvailabletoBank
							,A.CollateralShareamount
							--,A.TotalCollateralvalueatcustomerlevel
							,(Case When A.TaggingAlt_Key=1 Then T1.TotalCollateralValue
									When A.TaggingAlt_Key=2 Then T2.TotalCollateralValue End)TotalCollateralvalueatcustomerlevel
							,A.Security_RefNo as OldCollateralID
							--,A.TotCollateralsUCICCustAcc
							,A.IfPercentagevalue_or_Absolutevalue
							,isnull(A.AuthorisationStatus, 'A') AuthorisationStatus
							 ,A.CollateralValueatSanctioninRs  
							,A.CollateralValueasonNPAdateinRs
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
							,ISNULL(A.ApprovedByFirstLevel,A.CreatedBy) as ModAppByFirst
							,ISNULL(A.DateApprovedFirstLevel,A.DateCreated) as ModAppDateFirst
                     FROM DBO.AdvSecurityDetail_Mod A
					 Inner Join (Select ParameterAlt_Key,ParameterName,'TaggingLevel' as Tablename 
						  from DimParameter where DimParameterName='DimRatingType'
						  and ParameterName not in ('Guarantor')
						  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)B
						  ON A.TaggingAlt_Key=B.ParameterAlt_Key
						  Inner Join (Select ParameterAlt_Key,ParameterName,'DistributionModel' as Tablename 
						  from DimParameter where DimParameterName='Collateral'
						  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)C
						  ON A.DistributionAlt_Key=C.ParameterAlt_Key
						  Inner Join (Select ParameterAlt_Key,ParameterName,'ShareAvailabletoBank' as Tablename 
						  from DimParameter where DimParameterName='CollateralBank'
						  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)D
						  ON A.ShareAvailabletoBankAlt_Key=D.ParameterAlt_Key
						  inner join DimCollateralType E
						  ON A.SecurityAlt_Key=E.CollateralTypeAltKey
						  AND E.EffectiveFromTimeKey<=@Timekey And E.EffectiveToTimeKey>=@TimeKey
						  inner join DimCollateralSubType F
						  ON A.CollateralSubTypeAlt_Key=F.CollateralSubTypeAltKey 
						  And F.EffectiveFromTimeKey<=@Timekey And F.EffectiveToTimeKey>=@TimeKey
						  Inner join DimCollateralOwnerType G
						  ON A.OwnerTypeAlt_Key=G.CollateralOwnerTypeAltKey
						  And G.EffectiveFromTimeKey<=@Timekey And G.EffectiveToTimeKey>=@TimeKey
						  Inner Join (Select ParameterAlt_Key,ParameterName,'CollateralOwnershipType' as Tablename 
						  from DimParameter where DimParameterName='CollateralOwnershipType'
						  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)H
						  ON A.CollateralOwnerShipTypeAlt_Key=H.ParameterAlt_Key
						  Inner join DimCollateralChargeType I
						  ON A.SecurityChargeTypeAlt_Key=I.CollateralChargeTypeAltKey
						  And I.EffectiveFromTimeKey<=@Timekey And I.EffectiveToTimeKey>=@TimeKey
						  Inner Join DimSecurityChargeType J
						  On A.ChargeNatureAlt_Key=J.SecurityChargeTypeAlt_Key
						  And J.EffectiveFromTimeKey<=@Timekey And J.EffectiveToTimeKey>=@TimeKey
						  AND SecurityChargeTypeGroup='COLLATERAL'
						  Left Join #Tag1 T1 ON T1.CollateralID=A.CollateralID
						  Left Join #Tag2 T2 ON T2.CollateralID=A.CollateralID
						 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
       AND A.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM DBO.AdvSecurityDetail_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')
                         GROUP BY CollateralID
                     )
                 ) A 
                      

      GROUP BY 
							A.AccountID
							,A.UCICID
							,A.CustomerID 
							,A.CustomerName
							,A.TaggingAlt_Key
							,A.TaggingLevel
							,A.DistributionAlt_Key
							,A.DistributionModel
							,A.CollateralID
							,A.CollateralCode
							,A.CollateralTypeAlt_Key
							,A.CollateralTypeDescription
							,A.CollateralSubTypeAlt_Key
							,A.CollateralSubTypeDescription
							,A.CollateralOwnerTypeAlt_Key
							,A.CollOwnerDescription
							,A.CollateralOwnerShipTypeAlt_Key
							,A. CollateralOwnershipType
							,A.ChargeTypeAlt_Key
							,A.CollChargeDescription
							,A.ChargeNatureAlt_Key
							,A.SecurityChargeTypeName
							,A.ShareAvailabletoBankAlt_Key
							,A.ShareAvailabletoBank
							,A.CollateralShareamount
							,A.TotalCollateralvalueatcustomerlevel
								,A.OldCollateralID 
							--,A.TotCollateralsUCICCustAcc
							,A.IfPercentagevalue_or_Absolutevalue
							,A.AuthorisationStatus
							 ,A.CollateralValueatSanctioninRs  
							,A.CollateralValueasonNPAdateinRs,
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
							 A.ModAppByFirst,
							A.ModAppDateFirst

                 SELECT *
				 INTO #temp102
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY CollateralID) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'Collateral' TableName, 
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
				 ----------------------------------------------------------------

				 --Select '#temp102',* from #temp102
				 --Select '#temp16',* from #temp16
				
				 Update #temp102
										SET TotalCollateralvalueatcustomerlevel=NULL,
										TotalCount=NULL
					--------------------------------------------------
							--Start Customer
				
					Select  ROW_NUMBER() OVER(ORDER BY  CONVERT(VARCHAR(50),CustomerID) ) RecentRownumber,* INTO #temp106 from #temp102
					Where TaggingAlt_Key=1  and AuthorisationStatus in('A')




			       
					Select @Count=Count(*) from #temp106 
					--Select * from #temp101
				 --   Select * from #temp103
				
				 
				 SET @I=1
				 SET @LatestColletralSum=0
				 SET @CustomerIDPre=''
				 SET @CustomerID=''
				 SET @LatestColletralCount=0
			
				 While(@I<=@Count)
					BEGIN
					      
							Select @CollateralID=CollateralID,@CustomerID =CustomerID  from #temp106 where RecentRownumber=@I 
							order By CONVERT(VARCHAR(50),CustomerID)
                               
							   IF (@I=1)
							      BEGIN
									SET @CustomerIDPre=@CustomerID
								   END
					     
						    
							 
							 IF (@CustomerIDPre<> @CustomerID)
									BEGIN
									
										Update #temp106
										SET TotalCollateralvalueatcustomerlevel=@LatestColletralSum,
										TotalCount=@LatestColletralCount where  CustomerID =@CustomerIDPre and TaggingAlt_Key=1
										  Update #temp102
						                SET TotalCollateralvalueatcustomerlevel=@LatestColletralSum,
						                TotalCount=@LatestColletralCount where  CustomerID =@CustomerIDPre and TaggingAlt_Key=1
										SET @LatestColletral1=0
										SET @LatestColletralSum=0
										SET @LatestColletralCount=0
										 SET @CustomerIDPre=@CustomerID
									END


									 IF (@CustomerIDPre= @CustomerID)
										 BEGIN
										
										Select @LatestColletral1=ISNULL(CurrentValue,0)
										from Curdat.AdvSecurityValueDetail A
										INNER JOIN Curdat.AdvSecurityDetail  B ON A.CollateralID=B.CollateralID Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey And A.CollateralID=@CollateralID
										And ValuationDate=(select Max(ValuationDate)ValuationDate from Curdat.AdvSecurityValueDetail where EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey
										And CollateralID=@CollateralID)
										AND B.RefCustomerId=@CustomerID

								 SET    @LatestColletralSum=@LatestColletralSum+@LatestColletral1
								 SET    @LatestColletralCount=@LatestColletralCount+1
								
								 --Print '@LatestColletral1'
								 --Print @LatestColletral1
								 -- Print '@@LatestColletralSum'
								 --Print @LatestColletralSum
								 
									SET  @I=@I+1
									SET @LatestColletral1=0
									END
				   END
			
			            Update #temp106
						SET TotalCollateralvalueatcustomerlevel=@LatestColletralSum,
						 TotalCount=@LatestColletralCount where  CustomerID =@CustomerIDPre and TaggingAlt_Key=1

						 		  Update #temp102
						                SET TotalCollateralvalueatcustomerlevel=@LatestColletralSum,
						                TotalCount=@LatestColletralCount where  CustomerID =@CustomerIDPre and TaggingAlt_Key=1
     ---END
							--Start  ACccount
				
					Select  ROW_NUMBER() OVER(ORDER BY  CONVERT(VARCHAR(50),CustomerID) ) RecentRownumber,* INTO #temp107 from #temp102
					Where TaggingAlt_Key=2 and AuthorisationStatus in('A')



					--Select '#temp102',* from #temp102
					--		Select '#temp107',* from #temp107
			       
					Select @Count=Count(*) from #temp107
					
				
				 
				 SET @I=1
				 SET @LatestColletralSum=0
				 SET @CustomerIDPre=''
				 SET @CustomerID=''
				 SET @LatestColletralCount=0
				 SET @LatestColletral1=0
				 --PRINT @Cou1nt
				 While(@I<=@Count)
					BEGIN
					      
							Select @CollateralID=CollateralID,@CustomerID =AccountID  from #temp107 where RecentRownumber=@I 
							order By CONVERT(VARCHAR(50),CustomerID)
                               
							   IF (@I=1)
							      BEGIN
									SET @CustomerIDPre=@CustomerID
								   END
					     
						    
							 
							 IF (@CustomerIDPre<> @CustomerID)
									BEGIN
									
										Update #temp107
										SET TotalCollateralvalueatcustomerlevel=@LatestColletralSum,
										TotalCount=@LatestColletralCount where  AccountID =@CustomerIDPre and TaggingAlt_Key=2
										 Update #temp102
						                SET TotalCollateralvalueatcustomerlevel=@LatestColletralSum,
						             TotalCount=@LatestColletralCount where  AccountID =@CustomerIDPre and TaggingAlt_Key=2
										SET @LatestColletral1=0
										SET @LatestColletralSum=0
										SET @LatestColletralCount=0
										 SET @CustomerIDPre=@CustomerID
									END


									 IF (@CustomerIDPre= @CustomerID)
										 BEGIN
										
										Select @LatestColletral1=ISNULL(CurrentValue,0)
										from Curdat.AdvSecurityValueDetail A
										INNER JOIN Curdat.AdvSecurityDetail  B ON A.CollateralID=B.CollateralID Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey And A.CollateralID=@CollateralID
										And ValuationDate=(select Max(ValuationDate)ValuationDate from Curdat.AdvSecurityValueDetail where EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey
										And CollateralID=@CollateralID)
										AND B.RefSystemAcId=@CustomerID

								 SET   @LatestColletralSum=@LatestColletralSum+@LatestColletral1
								 SET    @LatestColletralCount=@LatestColletralCount+1
								
								 --Print '@LatestColletral1'
								 --Print @LatestColletral1
								 -- Print '@@LatestColletralSum'
								 --Print @LatestColletralSum
								 
									SET  @I=@I+1
									SET @LatestColletral1=0
									END
				   END
			
			            Update #temp107
						SET TotalCollateralvalueatcustomerlevel=@LatestColletralSum,
						 TotalCount=@LatestColletralCount where  AccountID =@CustomerIDPre and TaggingAlt_Key=2

						  Update #temp102
						  SET TotalCollateralvalueatcustomerlevel=@LatestColletralSum,
						    TotalCount=@LatestColletralCount where  AccountID =@CustomerIDPre and TaggingAlt_Key=2

					--Select '#temp107',* from #temp107
     ---END

	 	--Start  UCIC
				
					Select  ROW_NUMBER() OVER(ORDER BY  CONVERT(VARCHAR(50),CustomerID) ) RecentRownumber,* INTO #temp108 from #temp102 
					Where TaggingAlt_Key=4 and AuthorisationStatus in('A')




			       
					Select @Count=Count(*) from #temp108
					--Select * from #temp101
				 --   Select * from #temp103
				
				 
				 SET @I=1
				 SET @LatestColletralSum=0
				 SET @CustomerIDPre=''
				 SET @CustomerID=''
				 SET @LatestColletralCount=0
				 SET @LatestColletral1=0
				 PRINT @Count
				 While(@I<=@Count)
					BEGIN
					      
							Select @CollateralID=CollateralID,@CustomerID =UCICID  from #temp108 where RecentRownumber=@I 
							order By CONVERT(VARCHAR(50),CustomerID)
                               
							   IF (@I=1)
							      BEGIN
									SET @CustomerIDPre=@CustomerID
								   END
					     
						    
							 
							 IF (@CustomerIDPre<> @CustomerID)
									BEGIN
									
										Update #temp108
										SET TotalCollateralvalueatcustomerlevel=@LatestColletralSum,
										TotalCount=@LatestColletralCount where  UCICID =@CustomerIDPre and TaggingAlt_Key=4
										Update #temp102
						                SET TotalCollateralvalueatcustomerlevel=@LatestColletralSum,
						                TotalCount=@LatestColletralCount where  UCICID =@CustomerIDPre and TaggingAlt_Key=4
										SET @LatestColletral1=0
										SET @LatestColletralSum=0
										SET @LatestColletralCount=0
										 SET @CustomerIDPre=@CustomerID
									END


									 IF (@CustomerIDPre= @CustomerID)
										 BEGIN
										
										Select @LatestColletral1=ISNULL(CurrentValue,0)
										from Curdat.AdvSecurityValueDetail A
										INNER JOIN Curdat.AdvSecurityDetail  B ON A.CollateralID=B.CollateralID Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey And A.CollateralID=@CollateralID
										And ValuationDate=(select Max(ValuationDate)ValuationDate from Curdat.AdvSecurityValueDetail where EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey
										And CollateralID=@CollateralID)
										AND B.UCICID=@CustomerID

								 SET    @LatestColletralSum=@LatestColletralSum+@LatestColletral1
								 SET  @LatestColletralCount=@LatestColletralCount+1
								
								 --Print '@LatestColletral1'
								 --Print @LatestColletral1
								 -- Print '@@LatestColletralSum'
								 --Print @LatestColletralSum
								 
									SET  @I=@I+1
									SET @LatestColletral1=0
									END
				   END
			
			            Update #temp108
						SET TotalCollateralvalueatcustomerlevel=@LatestColletralSum,
						 TotalCount=@LatestColletralCount where  UCICID =@CustomerIDPre and TaggingAlt_Key=4

						 Update #temp102
						SET TotalCollateralvalueatcustomerlevel=@LatestColletralSum,
						 TotalCount=@LatestColletralCount where  UCICID =@CustomerIDPre and TaggingAlt_Key=4

						 --Select * from #temp105
     ---END
					  
					  ----Select * from #temp103
					  ----UNION
					  ----Select * from #temp104
					  ----UNION
					  ---- Select * from #temp105
					  --  ROW_NUMBER() OVER(ORDER BY  CONVERT(VARCHAR(50),RecentRownumber))  RowsNum,

					--  Select ROW_NUMBER() OVER(ORDER BY  CONVERT(VARCHAR(50),RecentRownumber))  RowsNum,X.* INTO #temp1091  From 
					--  (
					--    Select  * from #temp106
					--  UNION ALL
					--  Select * from #temp107
					-- UNION ALL
					--   Select * from #temp108
					--) X

					
					--   Select  * from #temp1091
     --            WHERE RowsNum BETWEEN @PageFrom AND @PageTo
				 --order by AuthorisationStatuslen desc, DateCreated desc

				 --Select  * from #temp102
     --            WHERE Rownumber BETWEEN @PageFrom AND @PageTo
				 --order by AuthorisationStatus desc, DateCreated desc

IF (ISNULL(@UCIF_ID,'')<>'' AND ISNULL(@Collateral,'')='' AND ISNULL(@CustomerID1,'')='' AND ISNULL(@AccountID,'')='')
		BEGIN
		--SElect *  INTO #temp181  From(
		  Select ROW_NUMBER() OVER( ORDER BY (select 1)) ROWID,A.*
		 INTO #temp184 from #temp102 A 
		
		 WHERE 
		   ISNULL(UCICID,'')=@UCIF_ID
		 
		 Select * from #temp184 A
		 where A.ROWID BETWEEN @PageFrom AND @PageTo 
	END

IF (ISNULL(@UCIF_ID,'')='' AND ISNULL(@Collateral,'')<>'' AND ISNULL(@CustomerID1,'')='' AND ISNULL(@AccountID,'')='')
		BEGIN
		PRINT 'Sac2'
		--SElect *  INTO #temp181  From(
		  Select ROW_NUMBER() OVER( ORDER BY (select 1)) ROWID,A.* 
		 INTO #temp185 from #temp102 A 
		  
		 WHERE 
		   ISNULL(A.CollateralID,'')=@Collateral
		 
		 Select * from #temp185 A
		 where A.ROWID BETWEEN @PageFrom AND @PageTo 
	END

		IF (ISNULL(@UCIF_ID,'')='' AND ISNULL(@Collateral,'')='' AND ISNULL(@CustomerID1,'')='' AND ISNULL(@AccountID,'')<>'')
		BEGIN
		PRINT 'Sac2'
		--SElect *  INTO #temp181  From(
		  Select ROW_NUMBER() OVER( ORDER BY (select 1)) ROWID,A.* 
		 INTO #temp189 from #temp101 A 
		  
		 WHERE 
		   ISNULL(A.AccountID,'')=@AccountID
		 
		 Select * from #temp189 A
		 where A.ROWID BETWEEN @PageFrom AND @PageTo 
	END

IF (ISNULL(@UCIF_ID,'')='' AND ISNULL(@Collateral,'')='' AND ISNULL(@CustomerID1,'')<>'' AND ISNULL(@AccountID,'')='')
		BEGIN
		PRINT 'Sac2'
		--SElect *  INTO #temp181  From(
		  Select ROW_NUMBER() OVER( ORDER BY (select 1)) ROWID,A.* 
		 INTO #temp190 from #temp101 A 
		  
		 WHERE 
		   ISNULL(A.CustomerID,'')=@CustomerID1
		 
		 Select * from #temp190 A
		 where A.ROWID BETWEEN @PageFrom AND @PageTo 
	END

	IF (ISNULL(@UCIF_ID,'')='' AND ISNULL(@Collateral,'')='' AND ISNULL(@CustomerID1,'')='' AND ISNULL(@AccountID,'')='')
		BEGIN
		  Select ROW_NUMBER() OVER( ORDER BY CrModDate desc) RowORD,A.* INTO #temp191
		  from #temp102 A 
		  
		

		
		  Select * from #temp191 A
		 WHERE A.RowORD BETWEEN @PageFrom AND @PageTo

	

	END
					------------------------------------------------------------------------
     
   END;
  ElSE

  IF(@OperationFlag  in (20))

             BEGIN
			 IF OBJECT_ID('TempDB..#temp120') IS NOT NULL DROP TABLE  #temp120;
             IF OBJECT_ID('TempDB..#temp121') IS NOT NULL DROP TABLE  #temp121;    
             IF OBJECT_ID('TempDB..#temp122') IS NOT NULL DROP TABLE  #temp122;  
			 
			  IF OBJECT_ID('TempDB..#temp1061') IS NOT NULL DROP TABLE  #temp1061;
             IF OBJECT_ID('TempDB..#temp1071') IS NOT NULL DROP TABLE  #temp1071;    
             IF OBJECT_ID('TempDB..#temp1081') IS NOT NULL DROP TABLE  #temp1081; 


			   IF OBJECT_ID('TempDB..#temp1841') IS NOT NULL DROP TABLE  #temp1841;
             IF OBJECT_ID('TempDB..#temp1851') IS NOT NULL DROP TABLE  #temp1851;    
             IF OBJECT_ID('TempDB..#temp1871') IS NOT NULL DROP TABLE  #temp1871; 

			 IF OBJECT_ID('TempDB..#temp192') IS NOT NULL DROP TABLE #temp192;    
             IF OBJECT_ID('TempDB..#temp193') IS NOT NULL DROP TABLE  #temp193; 
				SELECT 
							A.AccountID
							,A.UCICID
							,A.CustomerID
							,A.CustomerName
							,A.TaggingAlt_Key
							,A.TaggingLevel
							,A.DistributionAlt_Key
							,A.DistributionModel
							,A.CollateralID
							,A.CollateralCode
							,A.CollateralTypeAlt_Key
							,A.CollateralTypeDescription
							,A.CollateralSubTypeAlt_Key
							,A.CollateralSubTypeDescription
							,A.CollateralOwnerTypeAlt_Key
							,A.CollOwnerDescription
							,A.CollateralOwnerShipTypeAlt_Key
							,A. CollateralOwnershipType
							,A.ChargeTypeAlt_Key
							,A.CollChargeDescription
							,A.ChargeNatureAlt_Key
							,A.SecurityChargeTypeName
							,A.ShareAvailabletoBankAlt_Key
							,A.ShareAvailabletoBank
							,A.CollateralShareamount
							,A.TotalCollateralvalueatcustomerlevel
							,A.OldCollateralID
							--,A.TotCollateralsUCICCustAcc
							,A.IfPercentagevalue_or_Absolutevalue
							,A.AuthorisationStatus
							 ,A.CollateralValueatSanctioninRs  
							,A.CollateralValueasonNPAdateinRs,
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
							A.ModAppByFirst,
							A.ModAppDateFirst
                 INTO #temp120
                 FROM 
                 (
                     SELECT 
							A.RefSystemAcId as AccountID
							,A.UCICID
							,A.RefCustomerId as CustomerID
							,A.CustomerName
							,A.TaggingAlt_Key
							,B.ParameterName as TaggingLevel
							,A.DistributionAlt_Key
							,C.ParameterName as DistributionModel
							,A.CollateralID
							,A.CollateralCode
							,A.SecurityAlt_Key as CollateralTypeAlt_Key
							,E.CollateralTypeDescription
							,A.CollateralSubTypeAlt_Key
							,F.CollateralSubTypeDescription
							,A.OwnerTypeAlt_Key as CollateralOwnerTypeAlt_Key
							,G.CollOwnerDescription
							,A.CollateralOwnerShipTypeAlt_Key
							,H.ParameterName as CollateralOwnershipType
							,A.SecurityChargeTypeAlt_Key as ChargeTypeAlt_Key
							,I.CollChargeDescription
							,A.ChargeNatureAlt_Key
							,J.SecurityChargeTypeName
							,A.ShareAvailabletoBankAlt_Key
							,D.ParameterName as ShareAvailabletoBank
							,A.CollateralShareamount
							--,A.TotalCollateralvalueatcustomerlevel
							,(Case When A.TaggingAlt_Key=1 Then T1.TotalCollateralValue
									When A.TaggingAlt_Key=2 Then T2.TotalCollateralValue End)TotalCollateralvalueatcustomerlevel
										,A.Security_RefNo as OldCollateralID
							--,A.TotCollateralsUCICCustAcc
							,A.IfPercentagevalue_or_Absolutevalue
							,isnull(A.AuthorisationStatus, 'A') AuthorisationStatus
							 ,A.CollateralValueatSanctioninRs  
							,A.CollateralValueasonNPAdateinRs
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
							,ISNULL(A.ApprovedByFirstLevel,A.CreatedBy) as ModAppByFirst
							,ISNULL(A.DateApprovedFirstLevel,A.DateCreated) as ModAppDateFirst
                     FROM Dbo.AdvSecurityDetail_Mod A
					 Inner Join (Select ParameterAlt_Key,ParameterName,'TaggingLevel' as Tablename 
						  from DimParameter where DimParameterName='DimRatingType'
						  and ParameterName not in ('Guarantor')
						  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)B
						  ON A.TaggingAlt_Key=B.ParameterAlt_Key
						  Inner Join (Select ParameterAlt_Key,ParameterName,'DistributionModel' as Tablename 
						  from DimParameter where DimParameterName='Collateral'
						  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)C
						  ON A.DistributionAlt_Key=C.ParameterAlt_Key
						  Inner Join (Select ParameterAlt_Key,ParameterName,'ShareAvailabletoBank' as Tablename 
						  from DimParameter where DimParameterName='CollateralBank'
						  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)D
						  ON A.ShareAvailabletoBankAlt_Key=D.ParameterAlt_Key
						  inner join DimCollateralType E
						  ON A.SecurityAlt_Key=E.CollateralTypeAltKey
						  AND E.EffectiveFromTimeKey<=@Timekey And E.EffectiveToTimeKey>=@TimeKey
						  inner join DimCollateralSubType F
						  ON A.CollateralSubTypeAlt_Key=F.CollateralSubTypeAltKey 
						  And F.EffectiveFromTimeKey<=@Timekey And F.EffectiveToTimeKey>=@TimeKey
						  Inner join DimCollateralOwnerType G
						  ON A.OwnerTypeAlt_Key=G.CollateralOwnerTypeAltKey
						 And G.EffectiveFromTimeKey<=@Timekey And G.EffectiveToTimeKey>=@TimeKey
						  Inner Join (Select ParameterAlt_Key,ParameterName,'CollateralOwnershipType' as Tablename 
						  from DimParameter where DimParameterName='CollateralOwnershipType'
						  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)H
						  ON A.CollateralOwnerShipTypeAlt_Key=H.ParameterAlt_Key
						  Inner join DimCollateralChargeType I
						  ON A.SecurityChargeTypeAlt_Key=I.CollateralChargeTypeAltKey
						  And I.EffectiveFromTimeKey<=@Timekey And I.EffectiveToTimeKey>=@TimeKey
						  Inner Join DimSecurityChargeType J
						  On A.ChargeNatureAlt_Key=J.SecurityChargeTypeAlt_Key
						  And J.EffectiveFromTimeKey<=@Timekey And J.EffectiveToTimeKey>=@TimeKey
						  AND SecurityChargeTypeGroup='COLLATERAL'
						  Left Join #Tag1 T1 ON T1.CollateralID=A.CollateralID
						  Left Join #Tag2 T2 ON T2.CollateralID=A.CollateralID
						 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                           AND A.EntityKey IN
                     (
                      SELECT MAX(EntityKey)
                         FROM DBO.AdvSecurityDetail_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('1A')
                         GROUP BY CollateralID
                     )
                 ) A 
                      
                
                 GROUP BY 
							A.AccountID
							,A.UCICID
							,A.CustomerID
							,A.CustomerName
							,A.TaggingAlt_Key
							,A.TaggingLevel
							,A.DistributionAlt_Key
							,A.DistributionModel
							,A.CollateralID
							,A.CollateralCode
							,A.CollateralTypeAlt_Key
							,A.CollateralTypeDescription
							,A.CollateralSubTypeAlt_Key
							,A.CollateralSubTypeDescription
							,A.CollateralOwnerTypeAlt_Key
							,A.CollOwnerDescription
							,A.CollateralOwnerShipTypeAlt_Key
							,A. CollateralOwnershipType
							,A.ChargeTypeAlt_Key
							,A.CollChargeDescription
							,A.ChargeNatureAlt_Key
							,A.SecurityChargeTypeName
							,A.ShareAvailabletoBankAlt_Key
							,A.ShareAvailabletoBank
							,A.CollateralShareamount
							,A.TotalCollateralvalueatcustomerlevel
								,A.OldCollateralID
							--,A.TotCollateralsUCICCustAcc
							,A.IfPercentagevalue_or_Absolutevalue
							,A.AuthorisationStatus
							 ,A.CollateralValueatSanctioninRs  
							,A.CollateralValueasonNPAdateinRs,
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
							 A.ModAppByFirst,
							A.ModAppDateFirst


							
                 SELECT *
				 INTO #tmp121
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY CollateralID) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'Collateral' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp120 A
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner

			
					--Start Customer
				
					Select  ROW_NUMBER() OVER(ORDER BY  CONVERT(VARCHAR(50),CustomerID) ) RecentRownumber,* INTO #temp1061 
					from #tmp121
					Where TaggingAlt_Key=1  and AuthorisationStatus in('A')




			       
					Select @Count=Count(*) from #temp1061 
					--Select * from #temp101
				 --   Select * from #temp103
				
				 
				 SET @I=1
				 SET @LatestColletralSum=0
				 SET @CustomerIDPre=''
				 SET @CustomerID=''
				 SET @LatestColletralCount=0
			
				 While(@I<=@Count)
					BEGIN
					      
							Select @CollateralID=CollateralID,@CustomerID =CustomerID  from #temp1061 where RecentRownumber=@I 
							order By CONVERT(VARCHAR(50),CustomerID)
                               
							   IF (@I=1)
							      BEGIN
									SET @CustomerIDPre=@CustomerID
								   END
					     
						    
							 
							 IF (@CustomerIDPre<> @CustomerID)
									BEGIN
									
										Update #temp1061
										SET TotalCollateralvalueatcustomerlevel=@LatestColletralSum,
										TotalCount=@LatestColletralCount where  CustomerID =@CustomerIDPre and TaggingAlt_Key=1
										  Update #tmp121
						                SET TotalCollateralvalueatcustomerlevel=@LatestColletralSum,
						                TotalCount=@LatestColletralCount where  CustomerID =@CustomerIDPre and TaggingAlt_Key=1
										SET @LatestColletral1=0
										SET @LatestColletralSum=0
										SET @LatestColletralCount=0
										 SET @CustomerIDPre=@CustomerID
									END


									 IF (@CustomerIDPre= @CustomerID)
										 BEGIN
										
										Select @LatestColletral1=ISNULL(CurrentValue,0)
										from Curdat.AdvSecurityValueDetail A
										INNER JOIN Curdat.AdvSecurityDetail  B ON A.CollateralID=B.CollateralID Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey And A.CollateralID=@CollateralID
										And ValuationDate=(select Max(ValuationDate)ValuationDate from Curdat.AdvSecurityValueDetail where EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey
										And CollateralID=@CollateralID)
										AND B.RefCustomerId=@CustomerID

								 SET    @LatestColletralSum=@LatestColletralSum+@LatestColletral1
								 SET    @LatestColletralCount=@LatestColletralCount+1
								
								 --Print '@LatestColletral1'
								 --Print @LatestColletral1
								 -- Print '@@LatestColletralSum'
								 --Print @LatestColletralSum
								 
									SET  @I=@I+1
									SET @LatestColletral1=0
									END
				   END
			
			            Update #temp1061
						SET TotalCollateralvalueatcustomerlevel=@LatestColletralSum,
						 TotalCount=@LatestColletralCount where  CustomerID =@CustomerIDPre and TaggingAlt_Key=1

						 		  Update #tmp121
						                SET TotalCollateralvalueatcustomerlevel=@LatestColletralSum,
						                TotalCount=@LatestColletralCount where  CustomerID =@CustomerIDPre and TaggingAlt_Key=1
     ---END
							--Start  ACccount
				
					Select  ROW_NUMBER() OVER(ORDER BY  CONVERT(VARCHAR(50),CustomerID) ) RecentRownumber,* INTO #temp1071 from #tmp121
					Where TaggingAlt_Key=2 and AuthorisationStatus in('A')



					--Select '#temp102',* from #temp102
					--		Select '#temp107',* from #temp107
			       
					Select @Count=Count(*) from #temp1071
					
				
				 
				 SET @I=1
				 SET @LatestColletralSum=0
				 SET @CustomerIDPre=''
				 SET @CustomerID=''
				 SET @LatestColletralCount=0
				 SET @LatestColletral1=0
				 --PRINT @Cou1nt
				 While(@I<=@Count)
					BEGIN
					      
							Select @CollateralID=CollateralID,@CustomerID =AccountID  from #temp1071 where RecentRownumber=@I 
							order By CONVERT(VARCHAR(50),CustomerID)
                               
							   IF (@I=1)
							      BEGIN
									SET @CustomerIDPre=@CustomerID
								   END
					     
						    
							 
							 IF (@CustomerIDPre<> @CustomerID)
									BEGIN
									
										Update #temp1071
										SET TotalCollateralvalueatcustomerlevel=@LatestColletralSum,
										TotalCount=@LatestColletralCount where  AccountID =@CustomerIDPre and TaggingAlt_Key=2
										 Update #tmp121
						                SET TotalCollateralvalueatcustomerlevel=@LatestColletralSum,
						             TotalCount=@LatestColletralCount where  AccountID =@CustomerIDPre and TaggingAlt_Key=2
										SET @LatestColletral1=0
										SET @LatestColletralSum=0
										SET @LatestColletralCount=0
										 SET @CustomerIDPre=@CustomerID
									END


									 IF (@CustomerIDPre= @CustomerID)
										 BEGIN
										
										Select @LatestColletral1=ISNULL(CurrentValue,0)
										from Curdat.AdvSecurityValueDetail A
										INNER JOIN Curdat.AdvSecurityDetail  B ON A.CollateralID=B.CollateralID Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey And A.CollateralID=@CollateralID
										And ValuationDate=(select Max(ValuationDate)ValuationDate from Curdat.AdvSecurityValueDetail where EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey
										And CollateralID=@CollateralID)
										AND B.RefSystemAcId=@CustomerID

								 SET   @LatestColletralSum=@LatestColletralSum+@LatestColletral1
								 SET    @LatestColletralCount=@LatestColletralCount+1
								
								 --Print '@LatestColletral1'
								 --Print @LatestColletral1
								 -- Print '@@LatestColletralSum'
								 --Print @LatestColletralSum
								 
									SET  @I=@I+1
									SET @LatestColletral1=0
									END
				   END
			
			            Update #temp1071
						SET TotalCollateralvalueatcustomerlevel=@LatestColletralSum,
						 TotalCount=@LatestColletralCount where  AccountID =@CustomerIDPre and TaggingAlt_Key=2

						  Update #tmp121
						  SET TotalCollateralvalueatcustomerlevel=@LatestColletralSum,
						    TotalCount=@LatestColletralCount where  AccountID =@CustomerIDPre and TaggingAlt_Key=2

					--Select '#temp107',* from #temp107
     ---END

	 	--Start  UCIC
				
					Select  ROW_NUMBER() OVER(ORDER BY  CONVERT(VARCHAR(50),CustomerID) ) RecentRownumber,* INTO #temp1081 from #tmp121 
					Where TaggingAlt_Key=4 and AuthorisationStatus in('A')




			       
					Select @Count=Count(*) from #temp1081
					--Select * from #temp101
				 --   Select * from #temp103
				
				 
				 SET @I=1
				 SET @LatestColletralSum=0
				 SET @CustomerIDPre=''
				 SET @CustomerID=''
				 SET @LatestColletralCount=0
				 SET @LatestColletral1=0
				 PRINT @Count
				 While(@I<=@Count)
					BEGIN
					      
							Select @CollateralID=CollateralID,@CustomerID =UCICID  from #temp108 where RecentRownumber=@I 
							order By CONVERT(VARCHAR(50),CustomerID)
                               
							   IF (@I=1)
							      BEGIN
									SET @CustomerIDPre=@CustomerID
								   END
					     
						    
							 
							 IF (@CustomerIDPre<> @CustomerID)
									BEGIN
									
										Update #temp1081
										SET TotalCollateralvalueatcustomerlevel=@LatestColletralSum,
										TotalCount=@LatestColletralCount where  UCICID =@CustomerIDPre and TaggingAlt_Key=4
										Update #tmp121
						                SET TotalCollateralvalueatcustomerlevel=@LatestColletralSum,
						                TotalCount=@LatestColletralCount where  UCICID =@CustomerIDPre and TaggingAlt_Key=4
										SET @LatestColletral1=0
										SET @LatestColletralSum=0
										SET @LatestColletralCount=0
										 SET @CustomerIDPre=@CustomerID
									END


									 IF (@CustomerIDPre= @CustomerID)
										 BEGIN
										
										Select @LatestColletral1=ISNULL(CurrentValue,0)
										from Curdat.AdvSecurityValueDetail A
										INNER JOIN Curdat.AdvSecurityDetail  B ON A.CollateralID=B.CollateralID Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey And A.CollateralID=@CollateralID
										And ValuationDate=(select Max(ValuationDate)ValuationDate from Curdat.AdvSecurityValueDetail where EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey
										And CollateralID=@CollateralID)
										AND B.UCICID=@CustomerID

								 SET    @LatestColletralSum=@LatestColletralSum+@LatestColletral1
								 SET  @LatestColletralCount=@LatestColletralCount+1
								
								 --Print '@LatestColletral1'
								 --Print @LatestColletral1
								 -- Print '@@LatestColletralSum'
								 --Print @LatestColletralSum
								 
									SET  @I=@I+1
									SET @LatestColletral1=0
									END
				   END
			
			            Update #temp1081
						SET TotalCollateralvalueatcustomerlevel=@LatestColletralSum,
						 TotalCount=@LatestColletralCount where  UCICID =@CustomerIDPre and TaggingAlt_Key=4

						 Update #tmp121
						SET TotalCollateralvalueatcustomerlevel=@LatestColletralSum,
						 TotalCount=@LatestColletralCount where  UCICID =@CustomerIDPre and TaggingAlt_Key=4

						 --Select * from #temp105
     ---END
					  
					  ----Select * from #temp103
					  ----UNION
					  ----Select * from #temp104
					  ----UNION
					  ---- Select * from #temp105
					  --  ROW_NUMBER() OVER(ORDER BY  CONVERT(VARCHAR(50),RecentRownumber))  RowsNum,

					--  Select ROW_NUMBER() OVER(ORDER BY  CONVERT(VARCHAR(50),RecentRownumber))  RowsNum,X.* INTO #temp1091  From 
					--  (
					--    Select  * from #temp106
					--  UNION ALL
					--  Select * from #temp107
					-- UNION ALL
					--   Select * from #temp108
					--) X

					
					--   Select  * from #temp1091
     --            WHERE RowsNum BETWEEN @PageFrom AND @PageTo
				 --order by AuthorisationStatuslen desc, DateCreated desc

				 --Select  * from #temp102
     --            WHERE Rownumber BETWEEN @PageFrom AND @PageTo
				 --order by AuthorisationStatus desc, DateCreated desc

IF (ISNULL(@UCIF_ID,'')<>'' AND ISNULL(@Collateral,'')='' AND ISNULL(@CustomerID1,'')='' AND ISNULL(@AccountID,'')='')
		BEGIN
		--SElect *  INTO #temp181  From(
		  Select ROW_NUMBER() OVER( ORDER BY (select 1)) ROWID,A.*
		 INTO #temp1841 from #tmp121 A 
		
		 WHERE 
		   ISNULL(UCICID,'')=@UCIF_ID
		 
		 Select * from #temp1841 A
		 where A.ROWID BETWEEN @PageFrom AND @PageTo 
	END

IF (ISNULL(@UCIF_ID,'')='' AND ISNULL(@Collateral,'')<>'' AND ISNULL(@CustomerID1,'')='' AND ISNULL(@AccountID,'')='')
		BEGIN
		PRINT 'Sac2'
		--SElect *  INTO #temp181  From(
		  Select ROW_NUMBER() OVER( ORDER BY (select 1)) ROWID,A.* 
		 INTO #temp1851 from #tmp121 A 
		  
		 WHERE 
		   ISNULL(A.CollateralID,'')=@Collateral
		 
		 Select * from #temp1851 A
		 where A.ROWID BETWEEN @PageFrom AND @PageTo 
	END

	IF (ISNULL(@UCIF_ID,'')='' AND ISNULL(@Collateral,'')='' AND ISNULL(@CustomerID1,'')='' AND ISNULL(@AccountID,'')<>'')
		BEGIN
		PRINT 'Sac2'
		--SElect *  INTO #temp181  From(
		  Select ROW_NUMBER() OVER( ORDER BY (select 1)) ROWID,A.* 
		 INTO #temp192 from #temp101 A 
		  
		 WHERE 
		   ISNULL(A.AccountID,'')=@AccountID
		 
		 Select * from #temp192 A
		 where A.ROWID BETWEEN @PageFrom AND @PageTo 
	END

IF (ISNULL(@UCIF_ID,'')='' AND ISNULL(@Collateral,'')='' AND ISNULL(@CustomerID1,'')<>'' AND ISNULL(@AccountID,'')='')
		BEGIN
		PRINT 'Sac2'
		--SElect *  INTO #temp181  From(
		  Select ROW_NUMBER() OVER( ORDER BY (select 1)) ROWID,A.* 
		 INTO #temp193 from #temp101 A 
		  
		 WHERE 
		   ISNULL(A.CustomerID,'')=@CustomerID1
		 
		 Select * from #temp193 A
		 where A.ROWID BETWEEN @PageFrom AND @PageTo 
	END

	IF (ISNULL(@UCIF_ID,'')='' AND ISNULL(@Collateral,'')='' AND ISNULL(@CustomerID1,'')='' AND ISNULL(@AccountID,'')='')
		BEGIN
		  Select ROW_NUMBER() OVER( ORDER BY CrModDate desc) RowORD,A.* INTO #temp1871
		  from #tmp121 A 
		  
		

		
		  Select * from #temp1871 A
		 WHERE A.RowORD BETWEEN @PageFrom AND @PageTo

	

	END
					------------------------------------------------------------------------
     

				--Select * from #temp122	
    --             WHERE RecentRownumber BETWEEN @PageFrom AND @PageTo




				
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