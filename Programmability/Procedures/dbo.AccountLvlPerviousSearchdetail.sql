SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



 -- exec AccountLvlPerviousSearchdetail @AccountID=N'171'
  
  
CREATE PROC [dbo].[AccountLvlPerviousSearchdetail]  
--Declare  
              
              
             @AccountID varchar(30)  =''  
AS  
       
  BEGIN  
  
SET NOCOUNT ON;  
Declare @TimeKey as Int  
   
 --SET @Timekey =(Select TimeKey from SysDataMatrix where CurrentStatus='C')   
  
 -- SET @Timekey =(Select LastMonthDateKey from SysDayMatrix where Timekey=@Timekey)  
 
 SET @Timekey =(Select Timekey from SysDataMatrix Where MOC_Initialised='Y' AND ISNULL(MOC_Frozen,'N')='N') 
  
 Declare @DateOfData  as DateTime  
 Set @DateOfData=  (select S.LastQtrDate from  SysdayMatrix S left Join SysDataMatrix M  
           on S.TimeKey=M.TimeKey  
           where CurrentStatus='C'  
          )  

		  declare @Facility varchar(max)
		  declare @UCIF_ID Varchar(30)
		  set @Facility=(select FacilityType from AdvAcBasicDetail where effectivefromtimekey<=@Timekey and CustomerAcID=@AccountID)
		  	  set @UCIF_ID=( select Distinct UCIF_ID from CustomerBasicDetail A
			                   INNER JOIN AdvAcBasicDetail B ON A.CustomerEntityId=B.CustomerEntityId
							    where   A.effectivefromtimekey<=@Timekey And A.EffectiveToTimeKey>=@Timekey And CustomerACID=@AccountID)


								


BEGIN  
  
  
 SELECT   
  
     A.AccountID  
    ,@Facility as FacilityType --Z.FacilityType  
	,@UCIF_ID as UCIF_ID
     ,A.POS  
     ,A.InterestReceivable , 
    --,'' as CustomerID  --Q.CustomerID  
    --,'' as CustomerName --Q.CustomerName  
    --,'' as UCIC--Q.UCIF_ID as UCIC  
     Z.segmentcode as Segment  
    ,A.POS as BalanceOSPOS  
    ,A.InterestReceivable as BalanceOSInterestReceivable  
    --,RestructureFlag as RestructureFlagAlt_Key
    --,Convert(Varchar(10),A.RestructureDate,103) as RestructureDate  
    ,A.FITLFlag as FITLFlag
    --,A.flagFITL as FITLFlag  
    ,A.DFVAmount  
    --,A.RePossessionFlag as RePossessionFlag
    --,Convert(Varchar(10),A.RePossessionDate,103) as 'RePossessionDate'  
    --,A.InherentWeaknessFlag as InherentWeaknessFlag
    --,Convert(Varchar(10),A.InherentWeaknessDate,103) as 'InherentWeaknessDate'  
    --,A.SARFAESIFlag as SARFAESIFlagAlt_key
    --,Convert(Varchar(10),A.SARFAESIDate,103) as 'SARFAESIDate'  
    --,A.UnusualBounceFlag as UnusualBounceFlag
    --            ,Convert(Varchar(10),A.UnusualBounceDate,103)as 'UnusualBounceDate'  
    --,A.UnclearedEffectsFlag as UnclearedEffectsFlag
    --,Convert(Varchar(10),A.UnclearedEffectsDate,103) as 'UnclearedEffectsDate'  
    --,A.AdditionalProvisionCustomerlevel  
    ,A.AdditionalProvisionAbsolute  
       ,A.FraudAccountFlag as FraudAccountFlag 
    ,Convert(Varchar(10),A.FraudDate,103) as FraudDate
	 ,A.FlgTwo as TwoFlag 
    ,Convert(Varchar(10),A.TwoDate,103) as TwoDate   
	,TwoAmount
       ,Convert(Varchar(10),@DateOfData ,103) as DateOfData  
    ,A.MOCReason  
    ,Convert(Varchar(10),A.MOCDate ,103) as MOCDate  
    ,A.MOCBy  
    ,D.MOCTypeName as MOCSource  
    ,C.ParameterName as MOCType  
    ,ScreenFlag  
    ,Isnull(A.AuthorisationStatus,'A') as  AuthorisationStatus  
                ,A.EffectiveFromTimeKey  
                ,A.EffectiveToTimeKey  
                ,A.CreatedBy  
                ,A.DateCreated as DateCreated  
          , ApprovedByFirstLevel as [Level1ApprovedBy]  
    , DateApprovedFirstLevel as [Level1DateApproved]  
                ,A.ApprovedBy as ApprovedBy  
                ,A.DateApproved  as DateApproved  
                ,A.ModifyBy  
                ,Convert(Varchar(10),A.DateModified ,103) as DateModified  
    ,IsNull(A.ModifyBy,A.CreatedBy)as CrModBy  
    ,Convert(Varchar(10),IsNull(A.DateModified,A.DateCreated),103) as CrModDate  
  FROM AccountLevelMOC_MOD A 
	 
    Left JOIN DimMOCType D ON  A.MOCSource=D.MOCTypeAlt_Key  
    LEFT Join (  
    Select  EffectiveFromTimeKey,EffectiveToTimeKey,ParameterAlt_Key,ParameterName,'MOCType' as Tablename   
    from DimParameter where DimParameterName='MOCType'  
    And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)C  
    ON C.ParameterAlt_Key=A.MOCTypeAlt_Key  
	Left join AdvAcBasicDetail Z on z.AccountEntityId=a.AccountEntityID                             ---------------Newly added on 18/01/2024 by kapil
    Where AccountID= @AccountID and A.AuthorisationStatus in('A') And A.EffectiveFromTimeKey=@TimeKey  
   
  
END  
   
  END 


GO