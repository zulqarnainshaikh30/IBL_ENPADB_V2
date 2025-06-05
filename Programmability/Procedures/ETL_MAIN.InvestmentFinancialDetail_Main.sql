SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [ETL_MAIN].[InvestmentFinancialDetail_Main]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
DECLARE @VEFFECTIVETO INT SET @VEFFECTIVETO=(SELECT TIMEKEY-1 FROM UTKS_MISDB.DBO.AUTOMATE_ADVANCES WHERE EXT_FLG='Y')

------------For New Records
UPDATE A SET A.IsChanged='N'
----Select * 
from IBL_ENPA_TEMPDB_V2.DBO.TempInvestmentFinancialDetail A
Where Not Exists(Select 1 from DBO.InvestmentFinancialDetail B Where B.EffectiveToTimeKey=49999
And A.InvEntityId=B.InvEntityId) 

UPDATE O SET O.EffectiveToTimeKey=@vEffectiveto,
 O.DateModified=CONVERT(DATE,GETDATE(),103),
 O.ModifiedBy='SSISUSER'

FROM DBO.InvestmentFinancialDetail AS O
INNER JOIN IBL_ENPA_TEMPDB_V2.DBO.TempInvestmentFinancialDetail AS T
ON O.RefInvID=T.RefInvID

and O.EffectiveToTimeKey=49999
AND T.EffectiveToTimeKey=49999


WHERE 
(
  --O.Time_Key <> T.Time_Key 
 ISNULL(O.HoldingNature,0) <> ISNULL(T.HoldingNature ,0)
OR ISNULL(O.CurrencyAlt_Key,0) <> ISNULL(T.CurrencyAlt_Key ,0)
OR ISNULL(O.CurrencyConvRate,0) <> ISNULL(T.CurrencyConvRate,0) 
--OR ISNULL(O.BookType,0) <> ISNULL(T.BookType,0) 
OR ISNULL(O.BookValue,0) <> ISNULL(T.BookValue,0) 
OR ISNULL(O.BookValueINR,0) <> ISNULL(T.BookValueINR,0) 
OR ISNULL(O.MTMValue,0) <> ISNULL(T.MTMValue,0)
OR ISNULL(O.MTMValueINR,0) <> ISNULL(T.MTMValueINR,0) 
OR ISNULL(O.EncumberedMTM,0) <> ISNULL(T.EncumberedMTM,0) 
OR ISNULL(O.AssetClass_AltKey,0) <> ISNULL(T.AssetClass_AltKey ,0)
OR ISNULL(O.NPIDt,'1990-01-01') <> ISNULL(T.NPIDt,'1990-01-01') 
OR ISNULL(O.TotalProvison,0) <> ISNULL(T.TotalProvison ,0)
OR ISNULL(O.DBTDate,'1990-01-01')	 <> ISNULL(T.DBTDate,'1990-01-01')				
OR ISNULL(O.LatestBSDate,'1990-01-01') <> ISNULL(T.LatestBSDate,'1990-01-01')	
OR ISNULL(O.Interest_DividendDueDate,'1990-01-01') <> ISNULL(T.Interest_DividendDueDate,'1990-01-01')	
OR ISNULL(O.Interest_DividendDueAmount,0) <> ISNULL(T.Interest_DividendDueAmount,0)
OR ISNULL(O.PartialRedumptionDueDate,'1990-01-01') <> ISNULL(T.PartialRedumptionDueDate,'1990-01-01')	
OR ISNULL(O.PartialRedumptionSettledY_N,0) <> ISNULL(T.PartialRedumptionSettledY_N,0)
OR ISNULL(O.FLGDEG,0) <> ISNULL(T.FLGDEG,0) 
OR ISNULL(O.DEGREASON,0) <>  ISNULL(T.DEGREASON,0) 
OR ISNULL(O.DPD,0) <> ISNULL(T.DPD,0)
OR ISNULL(O.FLGUPG,0) <> ISNULL(T.FLGUPG,0)
OR ISNULL(O.UpgDate,'1990-01-01') <> ISNULL(T.UpgDate,'1990-01-01')	
OR ISNULL(O.PROVISIONALT_KEY,0) <>  ISNULL(O.PROVISIONALT_KEY,0)
OR ISNULL(O.InitialAssetAlt_Key,0) <> ISNULL(O.InitialAssetAlt_Key,0)
OR ISNULL(O.InitialNPIDt,'1990-01-01') <> ISNULL(T.InitialNPIDt,'1990-01-01')	
OR ISNULL(O.RefIssuerID,0) <> ISNULL(T.RefIssuerID,0)
OR ISNULL(O.DPD_Maturity,0) <> ISNULL(T.DPD_Maturity,0)
OR ISNULL(O.DPD_DivOverdue,0) <> ISNULL(T.DPD_DivOverdue,0)
OR ISNULL(O.FinalAssetClassAlt_Key,0) <> ISNULL(T.FinalAssetClassAlt_Key,0)
OR ISNULL(O.PartialRedumptionDPD,0) <> ISNULL(T.PartialRedumptionDPD,0)
--OR ISNULL(O.Asset_Norm,0) <> ISNULL(T.Asset_Norm,0)
--OR ISNULL(O.ISIN,0) <> ISNULL(T.ISIN,0)
--OR ISNULL(O.AssetClass,0) <> ISNULL(T.AssetClass,0)
--OR ISNULL(O.GL_Code,0) <>  ISNULL(T.GL_Code,0)
--OR ISNULL(O.GL_Description,0) <> ISNULL(T.GL_Description,0)
--OR ISNULL(O.OVERDUE_AMOUNT,0) <> ISNULL(T.OVERDUE_AMOUNT,0)
OR ISNULL(O.FlgSMA,'N') <> ISNULL(T.FlgSMA,'N')
OR ISNULL(O.SMA_Dt,'1900-01-01') <> ISNULL(T.SMA_Dt,'1900-01-01') 
OR ISNULL(O.SMA_Class,'') <> ISNULL(T.SMA_Class,'')
OR ISNULL(O.SMA_Reason,'') <> ISNULL(T.SMA_Reason,'')
)




----------For Changes Records
UPDATE A SET A.IsChanged='C'
----Select * 
from IBL_ENPA_TEMPDB_V2.DBO.TempInvestmentFinancialDetail A
INNER JOIN DBO.InvestmentFinancialDetail B 
ON  A.InvEntityId=B.InvEntityId
Where B.EffectiveToTimeKey= @vEffectiveto

-------------------------------------------------------------------------------------------------------------

-----Expire the records
UPDATE AA
SET 
 EffectiveToTimeKey = @vEffectiveto,
 AA.DateModified=CONVERT(DATE,GETDATE(),103),
 ModifiedBy='SSISUSER' 
FROM DBO.InvestmentFinancialDetail AA
WHERE AA.EffectiveToTimeKey = 49999
AND NOT EXISTS (SELECT 1 FROM IBL_ENPA_TEMPDB_V2.DBO.TempInvestmentFinancialDetail BB
    WHERE  AA.InvEntityId=BB.InvEntityId
    AND BB.EffectiveToTimeKey =49999
    )

--INSERT INTO DBO.InvestmentFinancialDetail
--     (	
--       --[Time_Key]
--      --[Inv_Key]
--	  InvEntityId
--      ,[HoldingNature]
--      ,[CurrencyAlt_Key]
--      ,[CurrencyConvRate]
--      ,[BookType]
--      ,[BookValue]
--      ,[BookValueINR]
--      ,[MTMValue]
--      ,[MTMValueINR]
--      ,[EncumberedMTM]
--      ,[AssetClass_AltKey]
--      ,[NPIDt]
--      ,[TotalProvison]
--      ,[AuthorisationStatus]
--      ,[EffectiveFromTimeKey]
--      ,[EffectiveToTimeKey]
--      ,[CreatedBy]
--      ,[DateCreated]
--      ,[ModifiedBy]
--      ,[DateModified]
--      ,[ApprovedBy]
--      ,[DateApproved]
--		   )
--SELECT
				
	   
--       --[Time_Key]
--      --[Inv_Key]
--	  InvEntityId
--      ,[HoldingNature]
--      ,[CurrencyAlt_Key]
--      ,[CurrencyConvRate]
--      ,[BookType]
--      ,[BookValue]
--      ,[BookValueINR]
--      ,[MTMValue]
--      ,[MTMValueINR]
--      ,[EncumberedMTM]
--      ,[AssetClass_AltKey]
--      ,[NPIDt]
--      ,[TotalProvison]
--      ,[AuthorisationStatus]
--      ,[EffectiveFromTimeKey]
--      ,[EffectiveToTimeKey]
--      ,[CreatedBy]
--      ,[DateCreated]
--      ,[ModifiedBy]
--      ,[DateModified]
--      ,[ApprovedBy]
--      ,[DateApproved]
--		   FROM IBL_ENPA_TEMPDB_V2.dbo.TempInvestmentFinancialDetail T Where ISNULL(T.IsChanged,'U') IN ('N','C')

insert into dbo.InvestmentFinancialDetail
(
 EntityKey
,InvEntityId
,ISIN
,RefInvID
,HoldingNature
,CurrencyAlt_Key
,CurrencyConvRate
,BookType
,BookValue
,BookValueINR
,MTMValue
,MTMValueINR
,EncumberedMTM
,AssetClass_AltKey
,NPIDt
,TotalProvison
,AuthorisationStatus
,EffectiveFromTimeKey
,EffectiveToTimeKey
,CreatedBy
,DateCreated
,ModifiedBy
,DateModified
,ApprovedBy
,DateApproved
,DBTDate
,LatestBSDate
,Interest_DividendDueDate
,Interest_DividendDueAmount
,PartialRedumptionDueDate
,PartialRedumptionSettledY_N
,FLGDEG
,DEGREASON
,DPD
,FLGUPG
,UpgDate
,PROVISIONALT_KEY
,InitialAssetAlt_Key
,InitialNPIDt
,RefIssuerID
,DPD_Maturity
,DPD_DivOverdue
,FinalAssetClassAlt_Key
,PartialRedumptionDPD
,Asset_Norm
,AssetClass
,GL_Code
,GL_Description
,OVERDUE_AMOUNT
,FlgSMA
,SMA_Dt
,SMA_Class
,SMA_Reason
,AddlProvision
,AddlProvisionPer
,MocBy
,MOC_Date
,FlgMoc
,MOC_Reason
)
select 
	EntityKey
,InvEntityId
,ISIN
,RefInvID
,HoldingNature
,CurrencyAlt_Key
,CurrencyConvRate
,NULL BookType
,BookValue
,BookValueINR
,MTMValue
,MTMValueINR
,EncumberedMTM
,AssetClass_AltKey
,NPIDt
,TotalProvison
,T.AuthorisationStatus
,T.EffectiveFromTimeKey
,T.EffectiveToTimeKey
,T.CreatedBy
,T.DateCreated
,T.ModifiedBy
,T.DateModified
,T.ApprovedBy
,T.DateApproved
,DBTDate
,LatestBSDate
,Interest_DividendDueDate
,Interest_DividendDueAmount
,PartialRedumptionDueDate
,PartialRedumptionSettledY_N
,FLGDEG
,DEGREASON
,DPD
,FLGUPG
,UpgDate
,PROVISIONALT_KEY
,InitialAssetAlt_Key
,InitialNPIDt
,RefIssuerID
,DPD_Maturity
,DPD_DivOverdue
,FinalAssetClassAlt_Key
,PartialRedumptionDPD
,null Asset_Norm
,T.InitialAssetAlt_Key as AssetClass
,null GL_Code
,null GL_Description
,null OVERDUE_AMOUNT
,null FlgSMA
,null SMA_Dt
,null SMA_Class
,null SMA_Reason
,null AddlProvision
,null AddlProvisionPer
,null MocBy
,null MOC_Date
,null FlgMoc
,null MOC_Reason
 FROM IBL_ENPA_TEMPDB_V2.dbo.TempInvestmentFinancialDetail T
 left join DimAssetClass DA
 on DA.AssetClassAlt_Key=T.AssetClass_AltKey
 Where ISNULL(T.IsChanged,'U') IN ('N','C')
 and InvEntityId IS NOT NULL


-- update O
-- set  
-- O.FLGDEG = T.FLGDEG
--,O.DEGREASON = T.DEGREASON
--,O.DPD = T.DPD
--,O.FLGUPG = T.FLGUPG
--,O.UpgDate = T.UpgDate
--,O.PROVISIONALT_KEY = T.PROVISIONALT_KEY
--,O.InitialAssetAlt_Key = T.InitialAssetAlt_Key
--,O.InitialNPIDt = T.InitialNPIDt
--,O.RefIssuerID = T.RefIssuerID
--,O.DPD_Maturity = T.DPD_Maturity
--,O.DPD_DivOverdue = T.DPD_DivOverdue
--,O.FinalAssetClassAlt_Key = T.FinalAssetClassAlt_Key
--FROM		dbo.InvestmentFinancialDetail O
--INNER JOIN	dbo.InvestmentFinancialDetail T
--on	O.InvEntityId=T.InvEntityId
--and O.EffectiveToTimeKey=49999
--AND T.EffectivefromTimeKey=@VEFFECTIVETO

END





GO