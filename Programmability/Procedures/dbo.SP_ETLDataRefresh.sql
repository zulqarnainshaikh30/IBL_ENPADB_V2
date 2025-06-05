SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[SP_ETLDataRefresh]
AS

Declare @Date date = (select Date from Automate_Advances where Ext_Flg = 'Y')

Declare @Timekey int = (select Timekey from Automate_Advances where Ext_Flg = 'Y')

delete from CustomerBasicDetail where EffectiveFromTimeKey = @Timekey

 update  CustomerBasicDetail  set EffectiveToTimeKey = 49999 where EffectiveToTimeKey = @Timekey-1

 delete from ADvacBasicDetail where EffectiveFromTimeKey = @Timekey

 update  ADvacBasicDetail  set EffectiveToTimeKey = 49999 where EffectiveToTimeKey = @Timekey-1

 delete from AcDailyTxnDetail where TxnDate = @Date

 delete from AdvAcBalanceDetail where EffectiveFromTimeKey = @Timekey

 update  AdvAcBalanceDetail  set EffectiveToTimeKey = 49999 where EffectiveToTimeKey = @Timekey-1

 delete from AdvAcFinancialDetail where EffectiveFromTimeKey = @Timekey

 update  AdvAcFinancialDetail  set EffectiveToTimeKey = 49999 where EffectiveToTimeKey = @Timekey-1

 delete from PRO.ContExcsSinceDtAccountCal where EffectiveFromTimeKey = @Timekey

 update  PRO.ContExcsSinceDtAccountCal  set EffectiveToTimeKey = 49999 where EffectiveToTimeKey = @Timekey-1

 delete from PRo.ContExcsSinceDtAccountCal_ENBD where EffectiveFromTimeKey = @Timekey

 update  PRo.ContExcsSinceDtAccountCal_ENBD  set EffectiveToTimeKey = 49999 where EffectiveToTimeKey = @Timekey-1

 delete from PRO.ContExcsSinceDtDebitAccountCal where EffectiveFromTimeKey = @Timekey

 update  PRO.ContExcsSinceDtDebitAccountCal  set EffectiveToTimeKey = 49999 where EffectiveToTimeKey = @Timekey-1

 delete from AdvAcOtherDetail where EffectiveFromTimeKey = @Timekey

 update  AdvAcOtherDetail  set EffectiveToTimeKey = 49999 where EffectiveToTimeKey = @Timekey-1

  delete from AdvAcOtherFinancialDetail where EffectiveFromTimeKey = @Timekey

 update  AdvAcOtherFinancialDetail  set EffectiveToTimeKey = 49999 where EffectiveToTimeKey = @Timekey-1

  delete from AdvAcRelations where EffectiveFromTimeKey = @Timekey

 update  AdvAcRelations  set EffectiveToTimeKey = 49999 where EffectiveToTimeKey = @Timekey-1

 delete from AdvFacCreditCardDetail where EffectiveFromTimeKey = @Timekey

 update  AdvFacCreditCardDetail  set EffectiveToTimeKey = 49999 where EffectiveToTimeKey = @Timekey-1

 delete from AdvCreditCardBalanceDetail where EffectiveFromTimeKey = @Timekey

 update  AdvCreditCardBalanceDetail  set EffectiveToTimeKey = 49999 where EffectiveToTimeKey = @Timekey-1

 --delete from AdvCustCommunicationDetail where EffectiveFromTimeKey = @Timekey

 --update  AdvCustCommunicationDetail  set EffectiveToTimeKey = 49999 where EffectiveToTimeKey = @Timekey-1

 delete from AdvCustNPADetail where EffectiveFromTimeKey = @Timekey

 update  AdvCustNPADetail  set EffectiveToTimeKey = 49999 where EffectiveToTimeKey = @Timekey-1

 delete from AdvCustOtherDetail where EffectiveFromTimeKey = @Timekey

 update  AdvCustOtherDetail  set EffectiveToTimeKey = 49999 where EffectiveToTimeKey = @Timekey-1

 delete from AdvCustRelationship where EffectiveFromTimeKey = @Timekey

 update  AdvCustRelationship  set EffectiveToTimeKey = 49999 where EffectiveToTimeKey = @Timekey-1

 delete from AdvFacBillDetail where EffectiveFromTimeKey = @Timekey

 update  AdvFacBillDetail  set EffectiveToTimeKey = 49999 where EffectiveToTimeKey = @Timekey-1

 delete from ADVFACCCDETAIL where EffectiveFromTimeKey = @Timekey

 update  AdvFacCCDetail  set EffectiveToTimeKey = 49999 where EffectiveToTimeKey = @Timekey-1

 delete from ADVFACDLDETAIL where EffectiveFromTimeKey = @Timekey

 update  ADVFACDLDETAIL  set EffectiveToTimeKey = 49999 where EffectiveToTimeKey = @Timekey-1

 delete from AdvFacPCDetail where EffectiveFromTimeKey = @Timekey

 update  AdvFacPCDetail  set EffectiveToTimeKey = 49999 where EffectiveToTimeKey = @Timekey-1

 delete from AdvSecurityDetail where EffectiveFromTimeKey = @Timekey

 update  AdvSecurityDetail  set EffectiveToTimeKey = 49999 where EffectiveToTimeKey = @Timekey-1

 delete from AdvSecurityValueDetail where EffectiveFromTimeKey = @Timekey

 update  AdvSecurityValueDetail  set EffectiveToTimeKey = 49999 where EffectiveToTimeKey = @Timekey-1

 delete from InvestmentBasicDetail	 where EffectiveFromTimeKey = @Timekey

 update  InvestmentBasicDetail  set EffectiveToTimeKey = 49999 where EffectiveToTimeKey = @Timekey-1

 delete from InvestmentIssuerDetail	 where EffectiveFromTimeKey = @Timekey

 update  InvestmentIssuerDetail  set EffectiveToTimeKey = 49999 where EffectiveToTimeKey = @Timekey-1

 delete from InvestmentFinancialDetail	 where EffectiveFromTimeKey = @Timekey

 update  InvestmentFinancialDetail  set EffectiveToTimeKey = 49999 where EffectiveToTimeKey = @Timekey-1

 delete from MIFINGOLDMASTER where DateofData = @Date

 delete from ReversefeedCalypso	 where EffectiveFromTimeKey = @Timekey

 update  ReversefeedCalypso  set EffectiveToTimeKey = 49999 where EffectiveToTimeKey = @Timekey-1

 
 
 



GO