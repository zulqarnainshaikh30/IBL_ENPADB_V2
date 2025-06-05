SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[gltallyoutput]
as

SELECT BranchCode,GLCODE,SUM(BALANCE)BALANCE
INTO #BALANCESHEET
FROM AdvAcBasicDetail A 
inNER JOIN AdvAcBalanceDetail B 
ON A.AccountEntityId = B.AccountEntityId 
INNER JOIN DIMGL C ON A.GLAlt_Key = C.GLAlt_Key AND C.EffectiveToTimeKey = 49999
WHERE  A.EffectiveToTimeKey = 49999 and B.EffectiveToTimeKey = 49999
GROUP BY BranchCode,GLCODE



select *,DIFF = (srcamount - crismacbalance) from (
SELECT A.DT AS Date,a.sol_ID as BranchCode,GL_SUB_HEAD_CODE as GlCode,d_amt as [Debit Amount],c_amt as [Credit Amount],(case when d_amt < c_amt then ISNULL(c_amt,0) - ISNULL(d_amt,0) else ISNULL(d_amt,0) - ISNULL(c_amt,0) END)SrcAmount,ISNULL(b.BALANCE,0) as CrisMacBalance
FROM DWH_sTG.DWH.gsh a LEFT JOIN #BALANCESHEET B ON A.GL_SUB_HEAD_CODE = B.GLCode AND A.sol_id = B.BranchCode
where a.sol_Id = '0071' and (c_amt > 0 or d_amt > 0 or BALANCE > 0))x
order by GlCode
GO