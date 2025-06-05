SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--dbo.SelectUpgradeSourceTypeDataForUtility 'Finacle'
CREATE procedure [dbo].[SelectDegradeSourceTypeDataForUtility]
@SourceType varchar(50)
AS
BEGIN
Declare @TimeKey AS INT =(Select TimeKey from Automate_Advances where EXT_FLG='Y')
	 --Declare @TimeKey AS INT =26298

   IF (@SourceType ='LMS')
	BEGIN
	--------------Finacle
	
			Select 'LMSDegrade' AS TableName,A.DateofData AS [Date of Data],A.SourceSystemName [Source System] ,
			A.CustomerID [Customer ID] , 
			A.AccountID [Account ID],'UTKS' [Bank ID],A.BranchCode SOL_ID,
			AB.SourceAssetClass as [Current Sub - Asset Class Code],
			A.AssetSubClass as [Revised Sub Asset Class Code],
			A.NPADate [NPA Date],A.DPD DPD,
			(CASE WHEN A.FinalAssetClassAlt_Key > 1 THEN REPLACE(isnull(A.NPAReason,A.DegReason),',','') END)
			FREE_TEXT_1,
			'' FREE_TEXT_2,'' FREE_TEXT_3
			from ReverseFeedData A
			left join AdvAcBalanceDetail AB 
			on a.AccountID=ab.RefSystemAcId
			and ab.EffectiveFromTimeKey<=@TimeKey
			and ab.EffectiveToTimeKey>=@TimeKey
	--Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
	--And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
	 where A.SourceSystemName='LMS'
	 And A.AssetSubClass<>'STD'
	 AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
    END


  IF (@SourceType ='BRNET')
	BEGIN
	 --------------Ganaseva
	Select 'BRNETDegrade' AS TableName, A.DateofData AS [Date of Data],A.SourceSystemName [Source System] ,
			A.CustomerID [Customer ID] , 
			A.AccountID [Account ID],'UTKS' [Bank ID],A.BranchCode SOL_ID,
			AB.SourceAssetClass as [Current Sub - Asset Class Code],
			A.AssetSubClass as [Revised Sub Asset Class Code],
			A.NPADate [NPA Date],A.DPD DPD,
			(CASE WHEN A.FinalAssetClassAlt_Key > 1 THEN REPLACE(isnull(A.NPAReason,A.DegReason),',','') END)
			FREE_TEXT_1,
			'' FREE_TEXT_2,'' FREE_TEXT_3 
	from ReverseFeedData A
	left join AdvAcBalanceDetail AB 
			on a.AccountID=ab.RefSystemAcId
			and ab.EffectiveFromTimeKey<=@TimeKey
			and ab.EffectiveToTimeKey>=@TimeKey
	--Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
	--And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
	 where A.SourceSystemName='BRNET'
	 And A.AssetSubClass<>'STD'
	 AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
    END

	  IF (@SourceType ='PISMO')
	BEGIN
	  --------------MiFin
Select 'PISMODegrade' AS TableName, A.DateofData AS [Date of Data],A.SourceSystemName [Source System] ,
			A.CustomerID [Customer ID] , 
			A.AccountID [Account ID],'UTKS' [Bank ID],A.BranchCode SOL_ID,
			AB.SourceAssetClass as [Current Sub - Asset Class Code],
			A.AssetSubClass as [Revised Sub Asset Class Code],
			A.NPADate [NPA Date],A.DPD DPD,
			(CASE WHEN A.FinalAssetClassAlt_Key > 1 THEN REPLACE(isnull(A.NPAReason,A.DegReason),',','') END)
			FREE_TEXT_1,
			'' FREE_TEXT_2,'' FREE_TEXT_3 	from ReverseFeedData A
			left join AdvAcBalanceDetail AB 
			on a.AccountID=ab.RefSystemAcId
			and ab.EffectiveFromTimeKey<=@TimeKey
			and ab.EffectiveToTimeKey>=@TimeKey
	--Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
	--And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
	 where A.SourceSystemName='PISMO'
	 And A.AssetSubClass<>'STD'
	 AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
    END


	

-----------------------------------------------


--	IF (@SourceType ='TREASURY')
--		BEGIN
		    
--				IF OBJECT_ID('TempDB..#TREASURY') Is Not Null
--			Drop Table #TREASURY
			
--			Select 'TREASURYAssetClassification' AS TableName,A.DateofData AS [Date of Data],A.SourceSystemName [Source System] , A.CustomerID [Customer ID] , 
--			A.AccountID [Account ID],'UTKS' [Bank ID],A.BranchCode SOL_ID,E.SrcSysClassName as [Current Sub - Asset Class Code],
--			A.NPADate [NPA Date],A.DPD DPD,(CASE WHEN B.FinalAssetClassAlt_Key > 1 THEN REPLACE(isnull(B.NPA_Reason,B.DegReason),',','') END) FREE_TEXT_1,
--			'' FREE_TEXT_2,'' FREE_TEXT_3
--				 INto #TREASURY
--			 from			ReverseFeedData A
--Inner Join		Pro.accountCal B ON A.AccountID=B.CustomerAcid
--Left Join		DimProduct D On B.ProductAlt_Key=D.ProductAlt_Key And D.EffectiveToTimeKey=49999
--left Join		(select Distinct SourceAlt_Key,AssetClassAlt_Key,(CASE WHEN AssetClassAlt_Key = 1 THEN 'STD' ELSE SrcSysClassCode END)SrcSysClassName ,
--				 EffectiveFromTimeKey,EffectiveToTimeKey
--				 from DimAssetClassMapping) C ON C.AssetClassAlt_Key=B.FinalAssetClassAlt_Key 
--And				C.SourceAlt_Key=D.SourceAlt_Key
--And				C.EffectiveToTimeKey=49999
--LEFT Join		(select Distinct SourceAlt_Key,AssetClassAlt_Key,(CASE WHEN AssetClassAlt_Key = 1 THEN 'STD' ELSE SrcSysClassCode END)SrcSysClassName ,
--					EffectiveFromTimeKey,EffectiveToTimeKey
--					from DimAssetClassMapping) E 
--ON				E.AssetClassAlt_Key=B.InitialAssetClassAlt_Key 
--And				C.SourceAlt_Key=D.SourceAlt_Key
--And				C.EffectiveToTimeKey=49999
--Inner Join		Pro.CUSTOMERCAL PC ON PC.RefCustomerID=B.RefCustomerID
--where			A.SourceAlt_Key = 1 
--and				a.EffectiveFromTimeKey <=@TimeKey and a.EffectiveToTimeKey >=@TimeKey
--AND				(	(B.InitialAssetClassAlt_Key = 1 and B.FinalAssetClassAlt_Key > 1) 
--					OR (B.InitialAssetClassAlt_Key > 1 and B.FinalAssetClassAlt_Key = 1) 
--					OR (B.InitialAssetClassAlt_Key > 1 and B.FinalAssetClassAlt_Key > 1 and (B.InitialAssetClassAlt_Key != B.FinalAssetClassAlt_Key OR B.InitialNpaDt != B.FinalNpaDt))
--				)
--			and A.SourceSystemName='TREASURY'




--        END






END
GO