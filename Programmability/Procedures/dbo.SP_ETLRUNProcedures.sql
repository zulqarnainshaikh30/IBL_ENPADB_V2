SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[SP_ETLRUNProcedures]
AS

--exec [UTKS_MISDB].dbo.[testtemptomain] 26959

exec [UTKS_STGDB].dbo.ProductAddition

exec [UTKS_TEMPDB].[ETL_TEMP].AdvAcBasicDetail_Temp
exec [UTKS_TEMPDB].[ETL_TEMP].CustomerBasicDetail_Temp
exec [UTKS_TEMPDB].[ETL_TEMP].AdvAcBalanceDetail_Temp

exec [UTKS_TEMPDB].[ETL_TEMP].AdvAcFinancialDetail_Temp
exec [UTKS_TEMPDB].[ETL_TEMP].AdvAcOtherFinancialDetail_Temp
exec [UTKS_TEMPDB].[ETL_TEMP].AdvAcOtherDetail_Temp

exec [UTKS_TEMPDB].[ETL_TEMP].AdvFacCCDetail_Temp
exec [UTKS_TEMPDB].[ETL_TEMP].AdvFacBillDetail_Temp
exec [UTKS_TEMPDB].[ETL_TEMP].AdvFacDLDetail_Temp

exec [UTKS_TEMPDB].[ETL_TEMP].AcDailyTxnDetail_Temp
exec [UTKS_TEMPDB].[ETL_TEMP].AdvCustNPADetail_Temp
exec [UTKS_TEMPDB].[ETL_TEMP].AdvCustOtherDetail_Temp

exec [UTKS_TEMPDB].[ETL_TEMP].AdvSecurityDetail_Temp
exec [UTKS_TEMPDB].[ETL_TEMP].AdvSecurityValueDetail_Temp
exec [UTKS_TEMPDB].[ETL_TEMP].TempAdvFacCreditCardDetail
exec [UTKS_TEMPDB].[ETL_TEMP].TempAdvCreditCardBalanceDetail
exec [UTKS_TEMPDB].[ETL_TEMP].TempBuyoutDetails

exec [UTKS_TEMPDB].[ETL_TEMP].InvestmentIssuerDetail_Temp
exec [UTKS_TEMPDB].[ETL_TEMP].InvestmentBasicDetail_Temp
exec [UTKS_TEMPDB].[ETL_TEMP].InvestmentFinancialDetail_Temp



exec [UTKS_TEMPDB].[ETL_TEMP].[AdvAcRelation_Temp]
exec [UTKS_TEMPDB].[ETL_TEMP].[AdvCustRelationShip_Temp]



-----------------------------TEMP TO MAIN ------------------------------


exec [UTKS_MISDB].[ETL_Main].AdvAcBasicDetail_Main
exec [UTKS_MISDB].[ETL_Main].CustomerBasicDetail_Main
exec [UTKS_MISDB].[ETL_Main].AdvAcBalanceDetail_Main

exec [UTKS_MISDB].[ETL_Main].AdvAcFinancialDetail_Main
exec [UTKS_MISDB].[ETL_Main].AdvAcFinancialOtherDetail_Main
exec [UTKS_MISDB].[ETL_Main].AdvAcOtherDetail_Main

exec [UTKS_MISDB].[ETL_Main].AdvFacCCDetail_Main
exec [UTKS_MISDB].[ETL_Main].AdvFacBillDetail_Main
exec [UTKS_MISDB].[ETL_Main].AdvFacDLDetail_Main

exec [UTKS_MISDB].[ETL_Main].AcDailyTxnDetail_Main
exec [UTKS_MISDB].[ETL_Main].AdvCustNPADetail_Main
exec [UTKS_MISDB].[ETL_Main].AdvCustOtherDetail_Main

exec [UTKS_MISDB].[ETL_Main].AdvSecurityDetail_Main
exec [UTKS_MISDB].[ETL_Main].AdvSecurityValueDetail_Main
exec [UTKS_MISDB].[ETL_Main].AdvFacCreditCardDetail_Main
exec [UTKS_MISDB].[ETL_Main].AdvCreditCardBalanceDetail_Main
exec [UTKS_MISDB].[ETL_Main].BuyoutDetails_Final

exec [UTKS_MISDB].[ETL_Main].InvestmentIssuerDetail_Main
exec [UTKS_MISDB].[ETL_Main].InvestmentBasicDetail_Main
exec [UTKS_MISDB].[ETL_Main].InvestmentFinancialDetail_Main

exec [UTKS_MISDB].[ETL_MAIN].[AdvAcRelation_Main]
exec [UTKS_MISDB].[ETL_MAIN].[AdvCustRelationShip_Main]

exec [UTKS_MISDB].dbo.[SP_InsertExceptionFinalStatusTypeETL]
GO