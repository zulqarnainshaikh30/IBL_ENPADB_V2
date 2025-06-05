SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


		 -- exec AccountLvlPerviousSearchdetail @AccountID=N'22130328'
  --RPModuleDetailsHistory '22130328'
  
CREATE PROC [dbo].[RPModuleDetailsHistory]  
--Declare  
              
              
             @CustomerID varchar(20)  ='22120366'  
AS  
       
  BEGIN  
  
SET NOCOUNT ON;  
Declare @TimeKey as Int  
   
 SET @Timekey =(Select TimeKey from SysDataMatrix where CurrentStatus='C')   
  
  --SET @Timekey =(Select LastMonthDateKey from SysDayMatrix where Timekey=@Timekey)   
  
 Declare @DateOfData  as DateTime  
 Set @DateOfData=  (select S.LastQtrDate from  SysdayMatrix S left Join SysDataMatrix M  
           on S.TimeKey=M.TimeKey  
           where CurrentStatus='C'  
          )  

		  --declare @Facility varchar(max)
		  --set @Facility=(select FacilityType from PRO.accountcal_Hist where effectivefromtimekey=@Timekey and CustomerAcID=@AccountID)

BEGIN  
  
  
 SELECT   
  
     0+Row_Number()Over(order by (Select 1))  as SrNo
    ,A.PAN_No as [BorrowerPAN] --Z.FacilityType  
	,'RPHIstory' as TableName
     ,CBD.UCIF_ID  as [UCICID]
     ,A.CustomerID  
    --,'' as CustomerID  --Q.CustomerID  
    --,'' as CustomerName --Q.CustomerName  
    --,'' as UCIC--Q.UCIF_ID as UCIC  
    --,'' as Segment --Z.segmentcode as Segment  
    ,CBD.CustomerName as [BorrowerName]  
    ,D.ArrangementDescription as [BankingArrangement]  
    ,X.BankName as [NameOfLeadBank]
    ,I.ParameterName  as [BorrowerDefaultStatus]
    ,E.BucketName as [ExposureBucketing]
	,Convert(Varchar(10),A.ReviewExpiryDate,103) as [ReviewPeriodDeadline]
    --,A.flagFITL as FITLFlag  
    ,Convert(Varchar(10),A.RP_ApprovalDate,103) as [ApproveDateOfNature] 
    ,G.RPDescription as [NatureOfResolutionPlan]
    ,A.If_Other as [InCaseofOthersthenNatureofResolutionPlan] 
    --,NULL as [Days Passed RP Date] Runtime
    --,NULL as [Resolution Plan Implementation Deadline] Runtime
	,H.ParameterName as [ImplementationStatus]
	,Convert(Varchar(10),A.RP_ImplDate,103) as [ActualResolutionPlanImplementationDate]
	--, NULL as [Days Passed Resolution Implementation Date] Runtime
	--,NULL as [RP is Rectification then Risk Review Timeline] Runtime
    ,Z.ParameterName as [RevisedRPDeadLine]
	,IsBankExposure as  [WhetherYesBankExposure]
  
    --,ScreenFlag  
    ,Isnull(A.AuthorisationStatus,'A') as  AuthorisationStatus  
                ,A.EffectiveFromTimeKey  
                ,A.EffectiveToTimeKey  
                ,A.CreatedBy  
                ,A.DateCreated as DateCreated  
          , ApprovedByFirstLevel as [Level1ApprovedBy]  
    , DateApprovedFirstLevel as [Level1DateApproved]  
                ,A.ApprovedBy as ApprovedBy  
                ,A.DateApproved  as DateApproved  
                ,A.ModifiedBy  
                ,Convert(Varchar(10),A.DateModified ,103) as DateModified  
    ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy  
    ,Convert(Varchar(10),IsNull(A.DateModified,A.DateCreated),103) as CrModDate
	  
    FROM RP_Portfolio_Details A 
	left join curdat.CustomerBasicDetail CBD On CBD.CustomerId=A.CustomerID
	and CBD.EffectiveFromTimeKey<=@TimeKey And CBD.EffectiveToTimeKey>=@TimeKey

	 LEFT JOIN DimBankingArrangement D ON A.BankingArrangementAlt_Key=D.BankingArrangementAlt_Key
	 LEFT JOIN DimBankRP x ON a.LeadBankAlt_Key=X.BankRPAlt_Key
    LEFT JOIN (Select ParameterAlt_Key,ParameterName,'DefaultStatus' as Tablename 		
		from DimParameter where DimParameterName='BorrowerDefaultStatus'
		and EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) i
					ON A.DefaultStatusAlt_Key=I.PARAmeteralt_key	 
   LEFT JOIN DimExposureBucket E ON A.ExposureBucketAlt_Key=E.ExposureBucketAlt_Key
   LEFT JOIN (Select RPNatureAlt_Key,RPDescription,'DimResolutionPlanNature' as Tablename 
						from DimResolutionPlanNature
					Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) G
					ON A.RPNatureAlt_Key=G.RPNatureAlt_Key
	LEFT JOIN (		Select ParameterAlt_Key,ParameterName,'DimImplementationStatus' as Tablename 
		               from DimParameter where DimParameterName='ImplementationStatus'
		and EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) H
		ON A.RP_ImplStatusAlt_Key =H.ParameterAlt_Key 	
	LEFT JOIN (		Select ParameterAlt_Key,ParameterName,'StatusRevisedRPDeadline' as Tablename 
		               from DimParameter where DimParameterName='StatusRevisedRPDeadline'
		and EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) Z
		ON A.RevisedRPDeadline_Altkey =Z.ParameterAlt_Key 
    Where A.CustomerID= @CustomerID And A.EffectiveFromTimeKey=@TimeKey  
   
  
END  
   
  END  

GO