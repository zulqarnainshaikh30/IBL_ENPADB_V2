SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [PRO].[ContExcsSinceDtDebit]  
AS  
  
Declare @Date as Date =(Select Date from dbo.Automate_Advances where EXT_FLG='Y')  
Declare @EffectiveFrom as Int =(Select Timekey from dbo.Automate_Advances where EXT_FLG='Y')  
Declare @TimeKey as Int =(Select Timekey from dbo.Automate_Advances where EXT_FLG='Y')  
  

update 
Pro.ContExcsSinceDtDebitAccountCal 
set EffectiveToTimekey = @Timekey - 1   
where 
EffectiveToTimeKey = 49999  
  


IF OBJECT_ID('TEMPDB..#ContExcsSinceDtDebitAccountCal') IS NOT NULL  
DROP TABLE #ContExcsSinceDtDebitAccountCal  


  
SELECT C.CustomerAcID INTO #ContExcsSinceDtDebitAccountCal  FROM DBO.AdvAcBalanceDetail  A  
INNER JOIN [dbo].[AdvAcBasicDetail] B ON A.AccountEntityId=B.AccountEntityId  
INNER JOIN UTKS_STGDB..LMS_ACCOUNT_STG C ON C.CustomerAcID=B.CustomerACID  
WHERE  A.EffectiveFromTimeKey<=@TimeKey and A.EffectiveToTimeKey>=@TimeKey  
AND  B.EffectiveFromTimeKey<=@TimeKey and B.EffectiveToTimeKey>=@TimeKey  
AND C.DebitSinceDate IS NOT NULL  
EXCEPT  
   SELECT CustomerAcID FROM Pro.ContExcsSinceDtDebitAccountCal where Effectivetotimekey=49999  
  
    ALTER TABLE  #ContExcsSinceDtDebitAccountCal  ADD DebitSinceDate  DATE  
  
update a set DebitSinceDate=C.DebitSinceDate  
from #ContExcsSinceDtDebitAccountCal a  
INNER JOIN UTKS_STGDB..LMS_ACCOUNT_STG C   
on a.CustomerAcID=C.CustomerAcID  
  




INSERT INTO Pro.ContExcsSinceDtDebitAccountCal  
(  
 CustomerAcID  
,AccountEntityId  
,SanctionAmt  
,SanctionDt  
,Balance  
,DrawingPower  
,ContExcsSinceDebitDt  
,EffectiveFromTimeKey  
,EffectiveToTimeKey  
)  


  
SELECT   
 A.CustomerAcID AS CustomerAcID  
,A.AccountEntityId AS AccountEntityId  
,A.OriginalLimit AS SanctionAmt  
,A.OriginalLimitDt  AS  SanctionDt  
,B.Balance  Balance  
,A.ORIGINALLIMIT  AS DrawingPower  
,DebitSinceDate AS ContExcsSinceDebitDt --@DATE  
,@TimeKey AS EffectiveFromTimeKey  
,49999 AS  EffectiveToTimeKey  
FROM #ContExcsSinceDtDebitAccountCal D INNER JOIN  
DBO.AdvAcBasicDetail   A ON D.CustomerAcID=A.CustomerAcID  
INNER JOIN [dbo].AdvAcBalanceDetail B ON A.AccountEntityId=B.AccountEntityId  
WHERE  A.EffectiveFromTimeKey<=@TimeKey and A.EffectiveToTimeKey>=@TimeKey  
AND  B.EffectiveFromTimeKey<=@TimeKey and B.EffectiveToTimeKey>=@TimeKey  
  
  


DROP TABLE #ContExcsSinceDtDebitAccountCal  
  
DELETE FROM Pro.ContExcsSinceDtDebitAccountCal where EffectiveToTimeKey < EffectiveFromTimeKey  
--END  
GO