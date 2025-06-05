SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROC [dbo].[GetIBPCAccountValidation]
@CustomerACID  varchar (50)
--,@Flag Int
AS
	BEGIN

Declare @Timekey Int
Set @Timekey =(Select TimeKey from SysDataMatrix where CurrentStatus='C')

--Set @Timekey =(Select TimeKey from SysDayMatrix where Date=Cast(Getdate() as Date))
BEGIN

--IF(@Flag=1)
	--BEGIN
		select * from
		(
		--Select	A.AccountID as CustomerACID
		--			,A.[CustomerId]
		--		    ,B.[CustomerName]
		--			,ACC.SourceAlt_Key
		--			,ds.SourceName
		--			,PoolID
		--			,PoolName
		--			,POS
		--			,InterestReceivable
		--			,(Select top(1) BalanceOutstanding from IBPCPoolSummary S
		--			where S.PoolId=A.PoolId and S.EffectiveFromTimeKey<=@Timekey and S.EffectiveToTimeKey>=@Timekey) as BalanceOS
		--			,'CustIBPCFlaggingDetails'as TableName
		--from		IBPCACFlaggingDetail A
		--left join [CurDat].[AdvAcBasicDetail] ACC on ACC.CustomerACID=A.AccountID
		--and			ACC.EffectiveFromTimeKey<=@Timekey
		--and			ACC.EffectiveToTimeKey>=@Timekey
		--left Join	[CurDat].[CustomerBasicDetail] B On ACC.[CustomerEntityId]=B.[CustomerEntityId]
		--and			B.EffectiveFromTimeKey<=@Timekey
		--and			B.EffectiveToTimeKey>=@Timekey	
		--Inner join DIMSOURCEDB ds on ds.SourceAlt_Key=ACC.SourceAlt_Key
		--where		[CustomerACID] = @CustomerACID
		--and			A.EffectiveFromTimeKey<=@Timekey
		--and			A.EffectiveToTimeKey>=@Timekey
		--And IsNull(A.AuthorisationStatus,'A')='A'

		--UNION

		Select	ACC.[CustomerACID]
					,ACC.RefCustomerId  [CustomerId]
				    ,B.[CustomerName]
					,ACC.SourceAlt_Key
					,ds.SourceName
					,PoolID
					,PoolName
					,AB.PrincipalBalance POS
					--,AB.InterestReceivable
					,FD.INT_RECEIVABLE_ADV InterestReceivable
					,AB.Balance  AccountBalance
					,ExposureAmount
					,(Select top(1) BalanceOutstanding from IBPCPoolSummary_Mod S
					where S.PoolId=A.PoolId and S.EffectiveFromTimeKey<=@Timekey and S.EffectiveToTimeKey>=@Timekey) as BalanceOS
					,'CustIBPCFlaggingDetails'as TableName
		from		IBPCACFlaggingDetail_Mod A
		Inner join [CurDat].[AdvAcBasicDetail] ACC on ACC.CustomerACID=A.AccountID
		and			ACC.EffectiveFromTimeKey<=@Timekey
		and			ACC.EffectiveToTimeKey>=@Timekey
		Inner join [CurDat].[AdvAcBalanceDetail] AB on AB.AccountEntityId=ACC.AccountEntityId
		and			AB.EffectiveFromTimeKey<=@Timekey
		and			AB.EffectiveToTimeKey>=@Timekey
		Inner join [DBO].[AdvAcOtherFinancialDetail] FD on FD.AccountEntityId=ACC.AccountEntityId
		and			FD.EffectiveFromTimeKey<=@Timekey
		Inner Join	[CurDat].[CustomerBasicDetail] B On ACC.[CustomerEntityId]=B.[CustomerEntityId]
		and			B.EffectiveFromTimeKey<=@Timekey
		and			B.EffectiveToTimeKey>=@Timekey	
		Inner join DIMSOURCEDB ds on ds.SourceAlt_Key=ACC.SourceAlt_Key
		where		[CustomerACID] = @CustomerACID
		and			A.EffectiveFromTimeKey<=@Timekey
		and			A.EffectiveToTimeKey>=@Timekey
		And IsNull(A.AuthorisationStatus,'A') in('NP','MP','1A')--)dt
	--END

	--   union
	----If(@Flag=2)
	----BEGIN
	--	--Select * from (
	--	Select	A.AccountID as CustomerACID
	--				,A.[CustomerId]
	--			    ,B.[CustomerName]
	--				,ACC.SourceAlt_Key
	--				,ds.SourceName
	--				,PoolID
	--				,PoolName
	--				,POS
	--				,InterestReceivable
	--				,(Select top(1) BalanceOutstanding from IBPCPoolSummary S
	--				where S.PoolId=A.PoolId and S.EffectiveFromTimeKey<=@Timekey and S.EffectiveToTimeKey>=@Timekey) as BalanceOS
	--				,'CustIBPCPoolDetails'as TableName
	--	from		IBPCPoolDetail A
	--	left join [CurDat].[AdvAcBasicDetail] ACC on ACC.CustomerACID=A.AccountID
	--	and			ACC.EffectiveFromTimeKey<=@Timekey
	--	and			ACC.EffectiveToTimeKey>=@Timekey
	--	left Join	[CurDat].[CustomerBasicDetail] B On ACC.[CustomerEntityId]=B.[CustomerEntityId]
	--	and			B.EffectiveFromTimeKey<=@Timekey
	--	and			B.EffectiveToTimeKey>=@Timekey	
	--	Inner join DIMSOURCEDB ds on ds.SourceAlt_Key=ACC.SourceAlt_Key
	--	where		[CustomerACID] = @CustomerACID
	--	and			A.EffectiveFromTimeKey<=@Timekey
	--	and			A.EffectiveToTimeKey>=@Timekey
	--	And IsNull(A.AuthorisationStatus,'A')='A'
		UNION

		Select	ACC.[CustomerACID]
					,ACC.RefCustomerId [CustomerId]
				    ,[CustomerName]
					,ACC.SourceAlt_Key
					,ds.SourceName
					,PoolID
					,PoolName
					,AB.PrincipalBalance  POS
					--,AB.InterestReceivable
					,FD.INT_RECEIVABLE_ADV InterestReceivable
					,AB.Balance as AccountBalance
					,IBPCExposureAmt
					,(Select top(1) BalanceOutstanding from IBPCPoolSummary_Mod S
					where S.PoolId=A.PoolId and S.EffectiveFromTimeKey<=@Timekey and S.EffectiveToTimeKey>=@Timekey) as BalanceOS
					,'CustIBPCPoolDetails'as TableName
		from		IBPCPoolDetail_Mod A
		Inner join [CurDat].[AdvAcBasicDetail] ACC on ACC.CustomerACID=A.AccountID
		and			ACC.EffectiveFromTimeKey<=@Timekey
		and			ACC.EffectiveToTimeKey>=@Timekey
		Inner join [CurDat].[AdvAcBalanceDetail] AB on AB.AccountEntityId=ACC.AccountEntityId
		and			AB.EffectiveFromTimeKey<=@Timekey
		and			AB.EffectiveToTimeKey>=@Timekey
		Inner join [DBO].[AdvAcOtherFinancialDetail] FD on FD.AccountEntityId=ACC.AccountEntityId
		and			FD.EffectiveFromTimeKey<=@Timekey
		Inner Join	[CurDat].[CustomerBasicDetail] B On ACC.[CustomerEntityId]=B.[CustomerEntityId]
		and			B.EffectiveFromTimeKey<=@Timekey
		and			B.EffectiveToTimeKey>=@Timekey	
		Inner join DIMSOURCEDB ds on ds.SourceAlt_Key=ACC.SourceAlt_Key
		where		[CustomerACID] = @CustomerACID
		and			A.EffectiveFromTimeKey<=@Timekey
		and			A.EffectiveToTimeKey>=@Timekey
		And IsNull(A.AuthorisationStatus,'A') in('NP','MP','1A')
		
		--UNION

		--Select	ACC.[CustomerACID]
		--			,ACC.RefCustomerId [CustomerId]
		--		    ,[CustomerName]
		--			,ACC.SourceAlt_Key
		--			,ds.SourceName
		--			,NULL PoolID
		--			,NULL PoolName
		--			,AB.PrincipalBalance  POS
		--			,AB.InterestReceivable
		--			,AB.Balance as AccountBalance
		--			,NUll IBPCExposureAmt
		--			,AB.Balance as BalanceOS
		--			,'CustPoolDetails'as TableName
		--from		[CurDat].[AdvAcBasicDetail] ACC
		
		--Inner join [CurDat].[AdvAcBalanceDetail] AB on AB.AccountEntityId=ACC.AccountEntityId
		--and			AB.EffectiveFromTimeKey<=@Timekey
		--and			AB.EffectiveToTimeKey>=@Timekey
		--Inner Join	[CurDat].[CustomerBasicDetail] B On ACC.[CustomerEntityId]=B.[CustomerEntityId]
		--and			B.EffectiveFromTimeKey<=@Timekey
		--and			B.EffectiveToTimeKey>=@Timekey	
		--Inner join DIMSOURCEDB ds on ds.SourceAlt_Key=ACC.SourceAlt_Key
		--where		[CustomerACID] = @CustomerACID
		--and			ACC.EffectiveFromTimeKey<=@Timekey
		--and			ACC.EffectiveToTimeKey>=@Timekey
		

		
		)dt
	--END


	--IF(@Flag=3)
	--BEGIN
		Select	[CustomerACID]
					,[CustomerId]
				    ,[CustomerName]
					,A.SourceAlt_Key
					,ds.SourceName
					,AB.PrincipalBalance  POS
					--,AB.InterestReceivable
					,FD.INT_RECEIVABLE_ADV InterestReceivable
					,AB.Balance as AccountBalance
					,'CustDetails'as TableName
		from		[CurDat].[AdvAcBasicDetail] A
		Inner Join	[CurDat].[CustomerBasicDetail] B On A.[CustomerEntityId]=B.[CustomerEntityId]	
		Inner join DIMSOURCEDB ds on ds.SourceAlt_Key=A.SourceAlt_Key
		Inner join [CurDat].[AdvAcBalanceDetail] AB on AB.AccountEntityId=A.AccountEntityId
		and			AB.EffectiveFromTimeKey<=@Timekey
		and			AB.EffectiveToTimeKey>=@Timekey
		Inner join [DBO].[AdvAcOtherFinancialDetail] FD on FD.AccountEntityId=A.AccountEntityId
		and			FD.EffectiveFromTimeKey<=@Timekey
		and			FD.EffectiveToTimeKey>=@Timekey
		where		[CustomerACID] = @CustomerACID
		and			A.EffectiveFromTimeKey<=@Timekey
		and			A.EffectiveToTimeKey>=@Timekey
		and			B.EffectiveFromTimeKey<=@Timekey
		and			B.EffectiveToTimeKey>=@Timekey
		And			AB.AssetClassAlt_Key=1
	--END


END				

	END
GO