SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



--/*
--CREATE BY	           : KALIK DEV
--CREATE DATE	       : 02/04/2024
--DISCRIPTION	       : Investment Portfolio ACL
--*/

CREATE PROC [dbo].[Rpt-054] 
	@TimeKey int
	,@Cost float
	
  AS


--DECLARE 
--	@Timekey int=27032
--   ,@Cost float=1

   
SET NOCOUNT ON 

  DECLARE @PrevTimekey AS INT = (SELECT TimeKey FROM SysDayMatrix WHERE TimeKey=(@Timekey-1))

  DECLARE @PrevDate AS DATE = (SELECT DATE FROM SysDayMatrix WHERE TimeKey=@PrevTimekey)

  --DECLARE @Timekey_date AS date = (SELECT Date FROM SysDayMatrix WHERE TimeKey=@Timekey)

  
DECLARE @Date AS DATE=(SELECT DATE FROM Automate_Advances WHERE TimeKey=@TimeKey)
DECLARE @ProcessDate DATE=(SELECT DATE FROM Automate_Advances WHERE Timekey=@TimeKey)



  SELECT
			DS.SourceName																		AS	[Source Sytem]
			,CONVERT( VARCHAR(20),@ProcessDate,103)   											AS	DateOfData
			,Ref_Txn_Sys_Cust_ID																AS	Ref_Txn_Sys_Cust_ID					
			,IID.IssuerID																		AS	IssuerID
			,IID.IssuerName																		AS	IssuerName
			,InvID																				AS	InvID
			,InstrName																			AS	InstrName
			,CurrencyName																		AS	CurrencyName
			,InvestmentNature																	AS	InvestmentNature
			,CONVERT(VARCHAR(20),MaturityDt,103)   												AS	MaturityDt
			,IFD.HoldingNature																	AS	HoldingNature
			,BookValue																			AS	BookValue
			,MTMValue																			AS	MTMValue
			,CONVERT(VARCHAR(20),IFD.NPIDt,103) 												AS	NPIDt
			,TotalProvison																		AS	TotalProvison
			,IFD.DPD																			AS	[DPD Current Day's DPD]
			--,IFD1.DPD																			AS	[Previous Day's DPD]
			--,(IFD.DPD-IFD1.DPD)																	AS	DPD_Difference		
			,''																					AS	[Trade Outstanding]
			,''																					AS	[Overdue Coupon Amount]
			,''																					AS	[Interest / Coupon Overdue Date]
			
			,OVERDUE_AMOUNT																		AS	OVERDUE_AMOUNT
			,''																					AS	[Overdue Since Date]
			,CONVERT(VARCHAR(20),PartialRedumptionDueDate,103) 									AS	PartialRedumptionDueDate
			,FLGDEG																				AS	FLGDEG
			,IFD.DegReason																		AS	[Degrade Reason]
			,FLGUPG																				AS	FLGUPG
			,CONVERT(VARCHAR(20),UpgDate,103) 													AS	UpgDate
			--,DA.AssetClassName																	AS	AssetClass 
			,case 
            when FinalAssetClassAlt_Key=1 and IFD.SMA_Class is null  then 'A0'
            when FinalAssetClassAlt_Key=1 and IFD.SMA_Class='SMA_0' then 'S0'
			when FinalAssetClassAlt_Key=1 and IFD.SMA_Class='SMA_1' then 'S1'
			when FinalAssetClassAlt_Key=1 and IFD.SMA_Class='SMA_2' then 'S2'
			when FinalAssetClassAlt_Key=1 and IFD.SMA_Class='SMA_3' then 'S3'
			when FinalAssetClassAlt_Key=2 and DATEDIFF(day,NPIDt,@Date) <=91 then 'B0'
			when FinalAssetClassAlt_Key=2 and DATEDIFF(day,NPIDt,@Date) between 91 and 183 then 'B1'
			when FinalAssetClassAlt_Key=2 and DATEDIFF(day,NPIDt,@Date) between 183 and 274 then 'B2'
			when FinalAssetClassAlt_Key=2 and DATEDIFF(day,NPIDt,@Date) >=273 then 'B3'
			when finalassetclassalt_key=3 then 'C1'
			when finalassetclassalt_key=4 then 'C2'
			when FinalAssetClassAlt_Key=5 then 'C3'
			when FinalAssetClassAlt_Key=6 then 'D0'
			end  FinalAssetName
			

 FROM dbo.InvestmentBasicDetail		IBD
 
	JOIN dbo.InvestmentFinancialDetail	IFD						ON IBD.InvEntityId=IFD.InvEntityId
																	AND IFD.EffectiveFromTimeKey<=@Timekey 
																	AND IFD.EffectiveToTimeKey>=@Timekey
																	AND IBD.EffectiveFromTimeKey<=@Timekey 
																	AND IBD.EffectiveToTimeKey>=@Timekey

	--LEFT  JOIN dbo.InvestmentFinancialDetail	IFD1					ON IFD.InvEntityId=IFD1.InvEntityId
	--																	AND IFD1.EffectiveFromTimeKey<=@PrevTimekey 
	--																	AND IFD1.EffectiveToTimeKey>=@PrevTimekey
	 
	INNER JOIN  dbo.InvestmentIssuerDetail	IID						ON IID.IssuerID=IBD.RefIssuerID
																		AND IID.EffectiveFromTimeKey<=@Timekey 
																		AND IID.EffectiveToTimeKey>=@Timekey
	
	
	LEFT JOIN DIMASSETCLASS	DA			ON IFD.FinalAssetClassAlt_Key=DA.AssetClassAlt_Key			--FOR   ASSET CLASS
											AND DA.EffectiveFromTimeKey<=@Timekey 
											AND DA.EffectiveToTimeKey>=@Timekey
											
	--LEFT JOIN DIMASSETCLASS	DA1			ON IFD.InitialAssetAlt_Key=DA1.AssetClassAlt_Key			-- FOR INITIAL ASSET CLASS  
	--										AND DA1.EffectiveFromTimeKey<=@Timekey 
	--										AND DA1.EffectiveToTimeKey>=@Timekey
	
	LEFT JOIN DIMSOURCEDB		DS			ON DS.SourceAlt_Key=IID.SourceAlt_Key
											AND DS.EffectiveFromTimeKey<=@Timekey 
											AND DS.EffectiveToTimeKey>=@Timekey

	
	LEFT JOIN DimCurrency		DC			ON DC.CurrencyAlt_Key=IFD.CurrencyAlt_Key
											AND DS.EffectiveFromTimeKey<=@Timekey 
											AND DS.EffectiveToTimeKey>=@Timekey
GO