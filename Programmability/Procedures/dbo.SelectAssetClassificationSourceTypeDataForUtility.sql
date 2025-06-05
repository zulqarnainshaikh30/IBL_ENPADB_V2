SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


  --Select SubAssetClassCode, * from UTKS_STGDB..LMS_ACCOUNT_STG
  --where CustomerAcID='1385140000006242'
  --W1,


  --Select SourceAssetClass, * from AdvAcBalanceDetail
  --where RefSystemAcId='1385140000006242'



--  9297193	1385140000006242	UTKS	1385	B0	B0
--4445796	1165120000006060	UTKS	1165	B0	B0
--4402485	1199120000006174	UTKS	1199	B0	B0
--2146452	1325120000006022	UTKS	1325	B0	B0
--2023447	1353060000002523	UTKS	1353	B0	B0

CREATE PROCEDURE [dbo].[SelectAssetClassificationSourceTypeDataForUtility] 
@SourceType varchar(50)
AS
BEGIN





 Declare @TimeKey as Int =(Select distinct TimeKey from Automate_Advances where EXT_FLG='Y')
 Declare @Date as Date =(Select distinct Date from Automate_Advances where EXT_FLG='Y')
 Declare @PreviousDate AS Date =(Select Date from Automate_Advances Where Timekey=@TimeKey-1)

 

    IF (@SourceType ='LMS')
	BEGIN
	  		------------LMS
			PRINT 'LMS'
		
			
			Select 
			'LMSAssetClassification' AS TableName,
			
			Convert (varchar (50),A.DateofData) AS [Date of Data],
			
			A.SourceSystemName [Source System] ,
			
			A.CustomerID [Customer ID] , 
			
			A.AccountID [Account ID],
			
			'UTKS' [Bank ID],
			
			A.BranchCode SOL_ID,
			
			A.AssetClass as [ Asset Class Code],
			
			A.AssetSubClass as [Revised Sub Asset Class Code],
			
			Convert (varchar (50),A.NPADate) [NPA Date],
			A.DPD DPD,
			
			(CASE WHEN A.FinalAssetClassAlt_Key > 1 THEN REPLACE(isnull(A.NPAReason,A.DegReason),',','') END)
			    FREE_TEXT_1,
				
			'' FREE_TEXT_2,
			
			'' FREE_TEXT_3
			
			 from			ReverseFeedData A
			 LEFT JOIN      AdvAcBalanceDetail B
			 ON             A.AccountID=B.RefSystemAcId
			 AND            B.EffectiveFromTimeKey <= @TimeKey AND B.EffectiveToTimeKey >= @TimeKey
			 WHERE          A.SourceSystemName='LMS'

     END


-------------------------------------------------------------------------------------------------------------------------
	
	
				IF (@SourceType ='BRNET')
		BEGIN

		    Select 
			'BRNETAssetClassification' AS TableName,
			
			Convert (varchar (50),A.DateofData) AS [Date of Data],
			
			A.SourceSystemName [Source System] ,
			
			A.CustomerID [Customer ID] ,
			
			A.AccountID [Account ID],
			
			'UTKS' [Bank ID],
			
			A.BranchCode SOL_ID,
			
			A.AssetClass as [ Asset Class Code],
			
			A.AssetSubClass as [Revised Sub Asset Class Code],
			
			Convert (varchar (50),A.NPADate) [NPA Date],
			
			A.DPD DPD,
			
			(CASE WHEN A.FinalAssetClassAlt_Key > 1 THEN REPLACE(isnull(A.NPAReason,A.DegReason),',','') END)
			FREE_TEXT_1,
			
			'' FREE_TEXT_2,
			
			'' FREE_TEXT_3
		
				
			 from			ReverseFeedData A
			 LEFT JOIN      AdvAcBalanceDetail B
			 ON             A.AccountID=B.RefSystemAcId
			 AND            B.EffectiveFromTimeKey <= @TimeKey AND B.EffectiveToTimeKey >= @TimeKey
			 WHERE          A.SourceSystemName='BRNET'
			
		END		

		
		   

		IF (@SourceType ='PISMO')
		BEGIN
		    
			
			Select 'PISMOAssetClassification' AS TableName,
			
			Convert (varchar (50),A.DateofData) AS [Date of Data],
			
			A.SourceSystemName [Source System] ,
			
			A.CustomerID [Customer ID] ,
			
			A.AccountID [Account ID],
			
			'UTKS' [Bank ID],
			
			A.BranchCode SOL_ID,
			
			A.AssetClass as [ Asset Class Code],
			
			A.AssetSubClass as [Revised Sub Asset Class Code],
			
			Convert (varchar (50),A.NPADate) [NPA Date],
			A.DPD DPD,
			
			(CASE WHEN A.FinalAssetClassAlt_Key > 1 THEN REPLACE(isnull(A.NPAReason,A.DegReason),',','') END)
			  FREE_TEXT_1,
			  
			'' FREE_TEXT_2,
			
			'' FREE_TEXT_3
		
			
			 from			ReverseFeedData A
			 LEFT JOIN      AdvAcBalanceDetail B
			 ON             A.AccountID=B.RefSystemAcId
			 AND            B.EffectiveFromTimeKey <= @TimeKey AND B.EffectiveToTimeKey >= @TimeKey
			 WHERE          A.SourceSystemName='PISMO'

		 END		

        



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




--ELSE
--	BEGIN
--		RAISERROR('ACL Failed',16,1);
--	END

END
GO