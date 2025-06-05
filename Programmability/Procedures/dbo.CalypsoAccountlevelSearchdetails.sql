SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROC [dbo].[CalypsoAccountlevelSearchdetails]
			
				@AccountID varchar(30)=''

AS
	BEGIN

Declare @Timekey int
SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')

select A.InvID as AccountId
	  ,'' FacilityType
	  ,'' as Segment
	  ,B.BookValueINR as BalancaOutstanding
	  ,B.MTMValueINR as POS
	  ,B.Interest_DividendDueAmount
	  ,B.TotalProvison as NPAProvision
	  ,'OtherCalypsoAccLevelMOCDetail' as TableName
 from  CalypsoAccountLevelMOC D
inner join dbo.InvestmentBasicDetail A
on D.accountid=A.InvID
AND A.EffectiveFromTimeKey<=@Timekey
AND A.EffectiveToTimeKey>=@Timekey
inner join dbo.InvestmentFinancialDetail B
ON A.InvEntityId=B.InvEntityId
AND B.EffectiveFromTimeKey<=@Timekey
AND B.EffectiveToTimeKey>=@Timekey
Where A.EffectiveFromTimeKey<=@Timekey
AND A.EffectiveToTimeKey>=@Timekey
AND A.InvID=@AccountID

UNION

select A.CustomerACID as AccountId
	  ,''
	  ,'' as Segment
	  ,A.MTMIncomeAmt as BalancaOutstanding
	  ,A.POS as POS
	  ,A.DueAmtReceivable
	  ,A.TotalProvison as NPAProvision
	  ,'OtherAccLevelMOCDetail' as TableName
 from  CalypsoAccountLevelMOC D
inner join curdat.DerivativeDetail A
on D.accountid=A.DerivativeRefNo
AND A.EffectiveFromTimeKey<=@Timekey
AND A.EffectiveToTimeKey>=@Timekey
Where A.EffectiveFromTimeKey<=@Timekey
AND A.EffectiveToTimeKey>=@Timekey
AND A.CustomerACID=@AccountID


END






GO