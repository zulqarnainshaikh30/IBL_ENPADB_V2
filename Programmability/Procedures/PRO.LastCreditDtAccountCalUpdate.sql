SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO







/*==============================================
 AUTHER : TRILOKI SHANKER KHANNA
 CREATE DATE : 05-03-2021
 MODIFY DATE : 05-03-2021
 DESCRIPTION : INSERT DATA PRO.LastCreditDtAccountCal
 --EXEC PRO.LastCreditDtAccountCalUpdate
 
 ================================================*/

CREATE PROCEDURE [PRO].[LastCreditDtAccountCalUpdate]
AS
BEGIN


Declare @Date as Date =(Select Date from dbo.Automate_Advances where EXT_FLG='Y')
Declare @EffectiveFrom as Int =(Select Timekey from dbo.Automate_Advances where EXT_FLG='Y')
Declare @TimeKey as Int =(Select Timekey from dbo.Automate_Advances where EXT_FLG='Y')

IF OBJECT_ID('TempDB..#CREDIT') IS NOT NULL
DROP TABLE #CREDIT


SELECT * into #CREDIT FROM (
SELECT CustomerAcID,AccountEntityId,TxnDate,SUM(TxnAmount)TxnAmount 
FROM DBO.AcDailyTxnDetail 

Where TxnDate=@Date And
  TxnSubType='RECOVERY'  
and AccountEntityId>0
and TrueCredit = 'Y'
GROUP BY CustomerAcID,AccountEntityId,TxnDate
)A


IF OBJECT_ID('TempDB..#ACCOUNTBAL') IS NOT NULL
DROP TABLE #ACCOUNTBAL

Select A.AccountEntityId,C.CustomerAcID,A.Balance

Into #ACCOUNTBAL
 from Dbo.AdvAcBalanceDetail A
Inner Join #CREDIT C ON A.AccountEntityId=C.AccountEntityId
where A.EffectiveFromTimeKey<=@TimeKey and A.EffectiveToTimeKey>=@TimeKey
and a.balance>=0



INSERT PRO.LastCreditDtAccountCal(CustomerAcID,AccountEntityId,LastCrDate,LasttoLastCrDate,CreditAmt,DebitAmt,Status,Credit_Flg,Acc_SrNo,EffectiveFromTimeKey,EffectiveToTimeKey)


------New

SELECT Credit.CustomerAcID,Credit.AccountEntityId,Credit.TxnDate LastCrDate,NULL LasttoLastCrDate,Credit.TxnAmount CreditAmt,NULL DebitAmt,
'C' Status,'C' CREDIT_FLG,1 Acc_Sr_No, @EffectiveFrom EffectiveFromTimeKey,49999 EffectiveToTimeKey
FROM PRO.LastCreditDtAccountCal CR

RIGHT JOIN #CREDIT Credit ON Credit.AccountEntityId=CR.AccountEntityId AND CR.Status='C' 
WHERE  CR.CustomerAcID IS NULL

------------Old
UNION


SELECT CR.CustomerAcID,CR.AccountEntityId,Credit.TxnDate LastCrDate,CR.LastCrDate LasttoLastCrDate,Credit.TxnAmount CreditAmt,CR.DebitAmt DebitAmt,
'C' Status,'C' CREDIT_FLG,MAXSr.Acc_SrNo+1 Acc_SrNo, @EffectiveFrom EffectiveFromTimeKey,49999 EffectiveToTimeKey
FROM PRO.LastCreditDtAccountCal CR

INNER JOIN #CREDIT Credit ON CR.AccountEntityId=Credit.AccountEntityId

INNER JOIN (SELECT AccountEntityId,CustomerAcID,MAX(ISNULL(Acc_SrNo,0)) Acc_SrNo
            FROM  PRO.LastCreditDtAccountCal
            GROUP BY AccountEntityId,CustomerAcID) MAXSr ON MAXSr.AccountEntityId=Cr.AccountEntityId
           
WHERE Status='C' 

--------------------------------------------------------------------


---------Previous record Expire


IF OBJECT_ID('TempDB..#AccountCount') IS NOT NULL
DROP TABLE #AccountCount

Select CustomerAcID,AccountEntityId,Count(*)Cnt into #AccountCount from PRO.LastCreditDtAccountCal Where Status='C'
 GROUP BY CustomerAcID,AccountEntityId
 HAVING Count(*)>1


UPDATE Cr SET Status='E' ,EffectiveToTimeKey=@TimeKey-1
FROM PRO.LastCreditDtAccountCal CR
INNER JOIN (SELECT CustomerAcID,AccountEntityId,MIN(Acc_SrNo) Acc_SrNo 
            FROM PRO.LastCreditDtAccountCal
            WHERE Status='C'
            GROUP BY CustomerAcID,AccountEntityId
            )MINCr ON Cr.AccountEntityId=MINCr.AccountEntityId
                                         AND Cr.Acc_SrNo=MINCr.Acc_SrNo 
INNER JOIN #AccountCount A ON A.AccountEntityId=CR.AccountEntityId
Where CR.EffectiveFromTimeKey<>@EffectiveFrom

END














GO