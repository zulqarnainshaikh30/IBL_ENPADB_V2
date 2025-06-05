SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

    
    
CREATE PROC [dbo].[InsertSyncReverseDataQuery_Customer]    
    
AS    
    
BEGIN    
    
 Declare @TimeKey AS INT =(Select TimeKey from Automate_Advances where EXT_FLG='Y')    
 Declare @Date as Date =(Select Date from Automate_Advances Where EXT_FLG='Y')    
 Declare @PreviousDate AS Date =(Select Date from Automate_Advances Where Timekey=@TimeKey-1)   
         
      
   IF OBJECT_ID('TempDB..#Total') Is Not Null    
   Drop Table #Total    
       
   Select A.RefCustomerID as CustomerID,DS.SourceName,A.SysAssetClassAlt_Key FinalAssetClassAlt_Key,A.SysNPA_Dt FinalNpaDt,
   (CASE WHEN B.SourceAssetClass IS NULL AND B.SourceNpaDate IS NULL AND DS.SourceAlt_Key=6 THEN 'STD' ELSE B.SourceAssetClass END)SourceAssetClass,
   (CASE WHEN B.SourceAssetClass IN('A0','S0','S1','S2') AND B.SourceNpaDate IS NOT NULL THEN NULL ELSE B.SourceNpaDate end)SourceNpaDate,
   DA.AssetClassAlt_Key BankAssetClass,Z.UpgDate AS UpgradeDate
     INto #Total    
    from Pro.CUSTOMERCAL A    
   Inner Join CURDAT.AdvAcBalanceDetail B ON A.RefCustomerID=B.RefCustomerID    
   ANd B.EffectiveFromTimeKey<=@Timekey ANd B.EffectiveToTimeKey>=@Timekey    
   Inner Join DIMSOURCEDB DS ON DS.SourceAlt_Key=A.SourceAlt_Key    
   ANd DS.EffectiveFromTimeKey<=@Timekey ANd DS.EffectiveToTimeKey>=@Timekey    
   Inner Join DimAssetClassMapping DA ON DA.AssetClassShortName=B.SourceAssetClass And A.SourceAlt_Key=DA.SourceAlt_Key    
   ANd DA.EffectiveFromTimeKey<=@Timekey ANd DA.EffectiveToTimeKey>=@Timekey    
   LEFT JOIN PRO.ACCOUNTCAL Z ON A.CustomerEntityID=Z.CustomerEntityID AND
   Z.EffectiveFromTimeKey<=@Timekey ANd Z.EffectiveToTimeKey>=@Timekey 
   WHERE  
   A.EffectiveFromTimeKey<=@TimeKey and A.EffectiveToTimeKey>=@TimeKey
   --NOT EXISTS(Select 1 from ExceptionFinalStatusType as X where X.ACID=A.CustomerAcID and X.StatusType='TWO' and    
   --X.EffectiveFromTimeKey<=@TimeKey and X.EffectiveToTimeKey>=@TimeKey) AND    
   AND NOT EXISTS(Select 1 from DimProduct as Y Where Y.ProductAlt_Key=Z.ProductAlt_Key and Y.ProductCode='RBSNP' and     
   Y.EffectiveFromTimeKey<=@TimeKey and Y.EffectiveToTimeKey>=@TimeKey)    
       
   ---------------------    
   Delete From ReverseFeedDataInsertSync_Customer where ProcessDate=@Date    
   ---------------------------    
    
   Insert into ReverseFeedDataInsertSync_Customer    
   Select  @Date AS ProcessDate,Cast(Getdate() as Date) as RunDate,B.SourceName , CustomerID, MAX(AssetClass) as FinalAssetClassAlt_Key,
  NPADate FinalNpaDt  , A.UpgradeDate 
  from ReverseFeedData A    
  Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key    
  And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey    
   where     
   --B.SourceName='Finacle'    
   --And     
   --A.AssetSubClass<>'STD'    
   A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey    
   GROUP BY CustomerID,NPADate ,B.SourceName,a.UpgradeDate
    
  -- UNION    
    
       
  --Select  @Date AS ProcessDate,Cast(Getdate() as Date) as RunDate,B.SourceName ,AccountID CustomerAcID,AssetClass as FinalAssetClassAlt_Key,NPADate FinalNpaDt,    
  --isnull(A.UpgradeDate,@Date) UpgradeDate from ReverseFeedData A    
  --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key    
  --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey    
  -- where     
  -- --B.SourceName='Finacle'    
  -- --And     
  -- A.AssetSubClass='STD'    
  -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey    
    
    
   ---------Added on 04/04/2022    
   UNION    
    
   Select  @Date AS ProcessDate,Cast(Getdate() as Date) as RunDate,A.SourceName, CustomerID,FinalAssetClassAlt_Key,FinalNpaDt   
    ,'' UpgradeDate  
   from #Total A    
   where A.BankAssetClass=1 And A.FinalAssetClassAlt_Key>1    
   AND NOT EXISTS (Select 1 from ReverseFeedDataInsertSync_Customer R where A.CustomerID=R.CustomerID  
   And R.ProcessDate=@PreviousDate  And A.BankAssetClass=R.FinalAssetClassAlt_Key And ISNULL(A.SourceNpaDate,'')=ISNULL(R.FinalNpaDt,'')  )
    
   ----------------    
   UNION    
    
   Select @Date AS ProcessDate,Cast(Getdate() as Date) as RunDate,A.SourceName, CustomerID,FinalAssetClassAlt_Key,FinalNpaDt   
   , '' UpgradeDate  
   from #Total A    
   where A.BankAssetClass>1 And A.FinalAssetClassAlt_Key>1    
   --And ISNULL(A.SourceNpaDate,'')<>ISNULL(A.FinalNpaDt,'')
   And (ISNULL(A.SourceNpaDate,'')<>ISNULL(A.FinalNpaDt,'') or (A.BankAssetClass<> A.FinalAssetClassAlt_Key ))
   AND NOT EXISTS (Select 1 from ReverseFeedDataInsertSync_Customer R where A.CustomerID=R.CustomerID  
   And R.ProcessDate=@PreviousDate  And A.BankAssetClass=R.FinalAssetClassAlt_Key And ISNULL(A.SourceNpaDate,'')=ISNULL(R.FinalNpaDt,'')  )  
    
    
   UNION    
    
   Select  @Date AS ProcessDate,Cast(Getdate() as Date) as RunDate,A.SourceName, CustomerID,FinalAssetClassAlt_Key,FinalNpaDt
   ,UpgradeDate  
   from #Total A    
   where A.BankAssetClass>1 And A.FinalAssetClassAlt_Key=1   
   AND NOT EXISTS (Select 1 from ReverseFeedDataInsertSync_Customer R where A.CustomerID=R.CustomerID  
   And R.ProcessDate=@PreviousDate  And A.BankAssetClass=R.FinalAssetClassAlt_Key  )    
  
   ;WITH CTE  AS  
   (  
   SELECT *,ROW_NUMBER()OVER (PARTITION BY PROCESSDATE,SourceName,CUSTOMERID,FinalAssetClassAlt_Key ORDER BY PROCESSDATE,CUSTOMERID,finalnpadt desc)rn   
   FROM ReverseFeedDataInsertSync_Customer WHERE CAST(PROCESSDATE AS DATE)=CAST(@Date AS DATE)  
   )delete from cte where rn>1  
     
  
 Exec  [dbo].[Customer_ReRf_Recor]
    
END 
GO