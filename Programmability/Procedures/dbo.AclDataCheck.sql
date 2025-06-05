SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create proc [dbo].[AclDataCheck]
as
------/* ACL PROCESS STEP ERROR */
------DECLARE 26267 Int =(select TimeKey from Automate_Advances where EXT_FLG='Y')
------DECLARE @Date date=(select Date from Automate_Advances where EXT_FLG='Y')
------DECLARE @CNT1 INT =0
------select * from pro.ACCOUNTCAL

/* ACL TOTAL NO OF ACCOUNT */
	select COUNT(1) from pro.ACCOUNTCAL  where EffectiveFromTimeKey=26282
	select count(1) from pro.AccountCal_Hist  where EffectiveFromTimeKey<=26282 and EffectiveToTimeKey>=26282
	

/* TOTAL NO OF NPA ACCOUNT  */
	select count(1) from pro.ACCOUNTCAL(NOLOCK) where FinalAssetClassAlt_Key>1 AND EffectiveFromTimeKey=26282
	select count(1) from pro.AccountCal_Hist  where EffectiveFromTimeKey<=26282 and EffectiveToTimeKey>=26282 and FinalAssetClassAlt_Key>1
	select COUNT(1) from ACL_NPA_DATA where Process_Date='15-12-2021' and FinalAssetClassAlt_Key >1 


/* TOTAL NO OF ACCOUNT DEGRADE */
		select count(1) from pro.ACCOUNTCAL(NOLOCK)  where FinalAssetClassAlt_Key>1 and InitialAssetClassAlt_Key=1 
		select count(1) from pro.AccountCal_Hist  where EffectiveFromTimeKey<=26282 and EffectiveToTimeKey>=26282  and FinalAssetClassAlt_Key>1 and InitialAssetClassAlt_Key=1 
		select COUNT(1) from ReverseFeedData where  DateofData='2021-12-15' and AssetClass >1 


/* TOTAL NO OF ACCOUNT UPGRADE */
		select count(1) from pro.ACCOUNTCAL(NOLOCK)  where FinalAssetClassAlt_Key=1 and InitialAssetClassAlt_Key>1
		select count(1) from pro.AccountCal_Hist  where EffectiveFromTimeKey<=26282 and EffectiveToTimeKey>=26282  and FinalAssetClassAlt_Key=1 and InitialAssetClassAlt_Key>1 
		select COUNT(1) from ReverseFeedData where DateofData='2021-12-15' and AssetClass =1 


/* TOTAL NO OF CUSTOMERS */
		select count(1) from pro.CUSTOMERCAL
		select count(1) from pro.CUSTOMERCAL_Hist WHERE  EffectiveFromTimeKey<=26282 and EffectiveToTimeKey>=26282


/* TOTAL NO OF CUSTOMERS NPA	*/
		select count(1) from pro.CUSTOMERCAL  where SysAssetClassAlt_Key>1
		select count(1) from pro.CUSTOMERCAL_Hist  where EffectiveFromTimeKey<=26282 and EffectiveToTimeKey>=26282 
		and SysAssetClassAlt_Key>1


/* TOTAL NO OF CUSTOMERS DEGRADE	*/
		select count(1) from pro.CUSTOMERCAL  where SysAssetClassAlt_Key>1 and SrcAssetClassAlt_Key=1
		select count(1) from pro.CUSTOMERCAL_Hist  where EffectiveFromTimeKey<=26282 and EffectiveToTimeKey>=26282
		and SysAssetClassAlt_Key>1 and SrcAssetClassAlt_Key=1


/* TOTAL NO OF CUSTOMERS UPGRADE*/
		select count(1) from pro.CUSTOMERCAL  where SysAssetClassAlt_Key=1 and SrcAssetClassAlt_Key>1
		select count(1) from pro.CUSTOMERCAL_Hist  where EffectiveFromTimeKey<=26282 and EffectiveToTimeKey>=26282
		and SysAssetClassAlt_Key=1 and SrcAssetClassAlt_Key>1
 
GO