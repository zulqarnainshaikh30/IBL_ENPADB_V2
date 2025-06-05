SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[ExpireRecords]
AS
--26211
delete from curdat.AdvAcBasicDetail where EffectiveFromTimeKey = 26299 --done
 update AdvAcBasicDetail  set EffectiveToTimekey = 49999 
where EffectiveToTimeKey = 26298



delete from curdat.AdvAcBalanceDetail where EffectiveFromTimeKey = 26299 --done
 update AdvAcBalanceDetail  set EffectiveToTimekey = 49999 
where EffectiveToTimeKey = 26298


delete from curdat.AdvAcFinancialDetail where EffectiveFromTimeKey = 26299 --done
 update AdvAcFinancialDetail  set EffectiveToTimekey = 49999 
where EffectiveToTimeKey = 26298


delete from curdat.AdvCustNPADetail where EffectiveFromTimeKey = 26299 --done
 update AdvCustNPADetail  set EffectiveToTimekey = 49999 
where EffectiveToTimeKey = 26298


delete from curdat.CustomerBasicDetail where EffectiveFromTimeKey = 26299 --done
 update CustomerBasicDetail  set EffectiveToTimekey = 49999 
where EffectiveToTimeKey = 26298


delete from curdat.AdvCustOtherDetail where EffectiveFromTimeKey = 26299 --done
 update AdvCustOtherDetail  set EffectiveToTimekey = 49999 
where EffectiveToTimeKey = 26298


delete from curdat.AdvAcOtherDetail where EffectiveFromTimeKey = 26299 --Done
 update AdvAcOtherDetail  set EffectiveToTimekey = 49999 
where EffectiveToTimeKey = 26298



delete from AdvAcOtherFinancialDetail where EffectiveFromTimeKey = 26299
 update AdvAcOtherFinancialDetail  set EffectiveToTimekey = 49999 
where EffectiveToTimeKey = 26298


delete from curdat.ADVFACCCDETAIL where EffectiveFromTimeKey = 26299
 update ADVFACCCDETAIL  set EffectiveToTimekey = 49999 
where EffectiveToTimeKey = 26298
delete from curdat.AdvFacBillDetail where EffectiveFromTimeKey = 26299
 update AdvFacBillDetail  set EffectiveToTimekey = 49999 
where EffectiveToTimeKey = 26298
delete from curdat.ADVFACDLDETAIL where EffectiveFromTimeKey = 26299
 update ADVFACDLDETAIL  set EffectiveToTimekey = 49999 
where EffectiveToTimeKey = 26298
delete from curdat.AdvFacPCDetail where EffectiveFromTimeKey = 26299
 update AdvFacPCDetail  set EffectiveToTimekey = 49999 
where EffectiveToTimeKey = 26298

delete from curdat.AdvNFAcBasicDetail where EffectiveFromTimeKey = 26299
 update AdvFacPCDetail  set EffectiveToTimekey = 49999 
where EffectiveToTimeKey = 26298

delete from curdat.AdvNFAcFinancialDetail where EffectiveFromTimeKey = 26299
 update AdvFacPCDetail  set EffectiveToTimekey = 49999 
where EffectiveToTimeKey = 26298

delete from curdat.AdvFacNFDetail where EffectiveFromTimeKey = 26299
 update AdvFacPCDetail  set EffectiveToTimekey = 49999 
where EffectiveToTimeKey = 26298


delete from AcDailyTxnDetail where cast(TxnDate as date) = '01/01/2022'
 

delete from AdvSecurityDetail where EffectiveFromTimeKey = 26299
 update AdvSecurityDetail  set EffectiveToTimekey = 49999 
where EffectiveToTimeKey = 26298


delete from AdvSecurityValueDetail where EffectiveFromTimeKey = 26299
 update AdvSecurityValueDetail  set EffectiveToTimekey = 49999 
where EffectiveToTimeKey = 26298


delete from InvestmentIssuerDetail where EffectiveFromTimeKey = 26299
 update InvestmentIssuerDetail  set EffectiveToTimekey = 49999 
where EffectiveToTimeKey = 26298


delete from InvestmentIssuerDetail where EffectiveFromTimeKey = 26299
 update InvestmentIssuerDetail  set EffectiveToTimekey = 49999 
where EffectiveToTimeKey = 26298


delete from InvestmentBasicDetail where EffectiveFromTimeKey = 26299
 update InvestmentBasicDetail  set EffectiveToTimekey = 49999 
where EffectiveToTimeKey = 26298


delete from InvestmentFinancialDetail where EffectiveFromTimeKey = 26299
 update InvestmentFinancialDetail  set EffectiveToTimekey = 49999 
where EffectiveToTimeKey = 26298

delete from Curdat.DerivativeDetail where EffectiveFromTimeKey = 26299
 update Curdat.DerivativeDetail  set EffectiveToTimekey = 49999 
where EffectiveToTimeKey = 26298


delete from AdvFacCreditCardDetail where EffectiveFromTimeKey = 26299
 update AdvFacCreditCardDetail  set EffectiveToTimekey = 49999 
where EffectiveToTimeKey = 26298


delete from AdvCreditCardBalanceDetail where EffectiveFromTimeKey = 26299
 update AdvCreditCardBalanceDetail  set EffectiveToTimekey = 49999 
where EffectiveToTimeKey = 26298

 
 
delete from PRO.ContExcsSinceDtAccountCal where EffectiveFromTimeKey = 26299
 update PRO.ContExcsSinceDtAccountCal  set EffectiveToTimekey = 49999 
where EffectiveToTimeKey = 26298


delete from Curdat.AdvAcWODetail where EffectiveFromTimeKey = 26299
 update Curdat.AdvAcWODetail  set EffectiveToTimekey = 49999 
where EffectiveToTimeKey = 26298


delete from MetagridAccountMaster where EffectiveFromTimeKey = 26299
 update MetagridAccountMaster  set EffectiveToTimekey = 49999 
where EffectiveToTimeKey = 26298


delete from metagridcustomermaster where EffectiveFromTimeKey = 26299
 update metagridcustomermaster  set EffectiveToTimekey = 49999 
where EffectiveToTimeKey = 26298


delete from metagridSecurity where EffectiveFromTimeKey = 26299
 update metagridSecurity  set EffectiveToTimekey = 49999 
where EffectiveToTimeKey = 26298



GO