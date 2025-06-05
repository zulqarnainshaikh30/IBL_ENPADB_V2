SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

    
    
CREATE PROC [dbo].[InsertSyncReverseDataQuery]    
    
AS    
    
BEGIN    
    
 Declare @TimeKey AS INT =(Select TimeKey from Automate_Advances where EXT_FLG='Y')    
 Declare @Date as Date =(Select Date from Automate_Advances Where EXT_FLG='Y')    
 Declare @PreviousDate AS Date =(Select Date from Automate_Advances Where Timekey=@TimeKey-1)   
         
      
   IF OBJECT_ID('TempDB..#Total') Is Not Null    
   Drop Table #Total    
       
   Select A.CustomerAcID,DS.SourceName,A.FinalAssetClassAlt_Key,A.FinalNpaDt,A.UpgDate,B.SourceAssetClass,B.SourceNpaDate,    
   DA.AssetClassAlt_Key BankAssetClass    
     INto #Total    
    from Pro.ACCOUNTCAL A    
   Inner Join dbo.AdvAcBalanceDetail B ON A.AccountEntityID=B.AccountEntityID    
   ANd B.EffectiveFromTimeKey<=@Timekey ANd B.EffectiveToTimeKey>=@Timekey    
   Inner Join DIMSOURCEDB DS ON DS.SourceAlt_Key=A.SourceAlt_Key    
   ANd DS.EffectiveFromTimeKey<=@Timekey ANd DS.EffectiveToTimeKey>=@Timekey    
   Inner Join DimAssetClassMapping DA ON DA.SrcSysClassCode=B.SourceAssetClass And A.SourceAlt_Key=DA.SourceAlt_Key    
   ANd DA.EffectiveFromTimeKey<=@Timekey ANd DA.EffectiveToTimeKey>=@Timekey    
   WHERE     
   --NOT EXISTS(Select 1 from ExceptionFinalStatusType as X where X.ACID=A.CustomerAcID and X.StatusType='TWO' and    
   --X.EffectiveFromTimeKey<=@TimeKey and X.EffectiveToTimeKey>=@TimeKey) AND    
   NOT EXISTS(Select 1 from DimProduct as Y Where Y.ProductAlt_Key=A.ProductAlt_Key and Y.ProductCode='RBSNP' and     
   Y.EffectiveFromTimeKey<=@TimeKey and Y.EffectiveToTimeKey>=@TimeKey)    
       
   ---------------------    
   Delete From ReverseFeedDataInsertSync where ProcessDate=@Date    
   ---------------------------    

   Insert into ReverseFeedDataInsertSync    
    
  Select  @Date AS ProcessDate,Cast(Getdate() as Date) as RunDate,B.SourceName ,AccountID CustomerAcID,AssetClass as FinalAssetClassAlt_Key,NPADate FinalNpaDt,     
  A.UpgradeDate UpgradeDate from ReverseFeedData A    
  Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key    
  And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey    
   where     
   --B.SourceName='Finacle'    
   --And     
   A.AssetSubClass<>'STD'    
   AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey    
    
   UNION    
    
       
  Select  @Date AS ProcessDate,Cast(Getdate() as Date) as RunDate,B.SourceName ,AccountID CustomerAcID,AssetClass as FinalAssetClassAlt_Key,NPADate FinalNpaDt,    
  isnull(A.UpgradeDate,@Date) UpgradeDate from ReverseFeedData A    
  Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key    
  And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey    
   where     
   --B.SourceName='Finacle'    
   --And     
   A.AssetSubClass='STD'    
   AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey    
    
    
   ---------Added on 04/04/2022    
   UNION    
    
   Select  @Date AS ProcessDate,Cast(Getdate() as Date) as RunDate,A.SourceName, CustomerAcID,FinalAssetClassAlt_Key,FinalNpaDt,    
   A.UpgDate UpgradeDate    
   from #Total A    
   where A.BankAssetClass=1 And A.FinalAssetClassAlt_Key>1    
   AND NOT EXISTS (Select 1 from ReverseFeedDataInsertSync R where A.CustomerAcID=R.CustomerAcID  
   And R.ProcessDate=@PreviousDate  And A.BankAssetClass=R.FinalAssetClassAlt_Key And ISNULL(A.SourceNpaDate,'')=ISNULL(R.FinalNpaDt,'')  )
    
   ----------------    
   UNION    
    
   Select  @Date AS ProcessDate,Cast(Getdate() as Date) as RunDate,A.SourceName, CustomerAcID,FinalAssetClassAlt_Key,FinalNpaDt,A.UpgDate UpgradeDate    
   from #Total A    
   where A.BankAssetClass>1 And A.FinalAssetClassAlt_Key>1    
   And ISNULL(A.SourceNpaDate,'')<>ISNULL(A.FinalNpaDt,'')
   AND NOT EXISTS (Select 1 from ReverseFeedDataInsertSync R where A.CustomerAcID=R.CustomerAcID  
   And R.ProcessDate=@PreviousDate  And A.BankAssetClass=R.FinalAssetClassAlt_Key And ISNULL(A.SourceNpaDate,'')=ISNULL(R.FinalNpaDt,'')  )  
    
    
   UNION    
    
   Select  @Date AS ProcessDate,Cast(Getdate() as Date) as RunDate,A.SourceName, CustomerAcID,FinalAssetClassAlt_Key,FinalNpaDt,isnull(A.UpgDate,@Date) UpgradeDate    
   from #Total A    
   where A.BankAssetClass>1 And A.FinalAssetClassAlt_Key=1   
   AND NOT EXISTS (Select 1 from ReverseFeedDataInsertSync R where A.CustomerAcID=R.CustomerAcID  
   And R.ProcessDate=@PreviousDate  And A.BankAssetClass=R.FinalAssetClassAlt_Key  )    
  


   Update ReverseFeedDataInsertSync
   set FinalNpaDt=null
   where ProcessDate=@Date
   and FinalAssetClassAlt_Key=1

      Update ReverseFeedDataInsertSync
   set UpgradeDate=@Date
   where ProcessDate=@Date
   and FinalAssetClassAlt_Key=1
   and UpgradeDate is null

   ;WITH CTE  AS  
   (  
   SELECT *,ROW_NUMBER()OVER (PARTITION BY PROCESSDATE,SourceName,CUSTOMERACID,FinalAssetClassAlt_Key ORDER BY PROCESSDATE,CUSTOMERACID,finalnpadt desc)rn   
   FROM ReverseFeedDataInsertSync WHERE CAST(PROCESSDATE AS DATE)=CAST(@Date AS DATE)  
   )delete from cte where rn>1  
     
  
    
END 
GO