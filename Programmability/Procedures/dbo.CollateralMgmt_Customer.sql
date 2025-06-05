SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--exec CollateralMgmt_Customer @SearchType=N'4',@Cust_Ucic_Acid=N'22562119'
--go


--sp_helptext CollateralMgmt_Customer

-------------------------------------------------------------------------------------------



---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--  exec CollateralMgmt_Customer @CustomerId=N'19987800'
--go


--sp_helptext CollateralMgmt_Customer


--Select Top 10 REfcustomerID, * from [CurDat].[AdvAcBasicDetail]

--[CurDat].[CustomerBasicDetail


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



CREATE Proc [dbo].[CollateralMgmt_Customer]  --- Script Date: 3/26/2021 2:00:55 PM *****(Farahnaaz)
 @SearchType Int,
 @Cust_Ucic_Acid varchar(20)='',
 @Result					INT				=0 OUTPUT

As
BEGIN
			 --IF OBJECT_ID('TempDB..#temp') IS NOT NULL
    --             DROP TABLE  #temp;
	Declare @RowsRetrurn Int
	Declare @TimeKey as Int
	Declare @LatestColletralSum Decimal(18,2),@LatestColletralCount Int

	SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')

	IF (@SearchType=1)
	BEGIN

	
IF OBJECT_ID('TempDB..#tmp') IS NOT NULL Drop Table #tmp

	IF Not Exists(	Select		M.AccountID, 
					M.CustomerId,
					M.CustomerName, 
					M.EffectiveFromTimeKey,
					M.EffectiveToTimeKey, 
					'CustomerDetails' TableName
			
             FROM (
					Select	A.CustomerACID AS AccountID, 
							C.CustomerId,
							C.CustomerName, 
							A.EffectiveFromTimeKey,
							A.EffectiveToTimeKey 
				from [CurDat].[AdvAcBasicDetail] A
				Inner Join [CurDat].[CustomerBasicDetail] C
						on A.REfcustomerID=C.CustomerID) As M
						WHERE M.CustomerId=@Cust_Ucic_Acid)

				Begin

				Select ''As AccountID,'' As CustomerId,
					'' AS CustomerName, 
					'' AS EffectiveFromTimeKey,
					'' AS EffectiveToTimeKey,'CustomerDetails' TableName


				END
				Else
				Begin


				Select		M.AccountID, 
					M.CustomerId,
					M.CustomerName, 
					M.EffectiveFromTimeKey,
					M.EffectiveToTimeKey, 
					'CustomerDetails' TableName
			
             FROM (
					Select	A.CustomerACID AS AccountID, 
							C.CustomerId,
							C.CustomerName, 
							A.EffectiveFromTimeKey,
							A.EffectiveToTimeKey 
				from [CurDat].[AdvAcBasicDetail] A
				Inner Join [CurDat].[CustomerBasicDetail] C
						on A.REfcustomerID=C.CustomerID) As M
						WHERE M.CustomerId=@Cust_Ucic_Acid

				End

				Select CollateralID into #tmp from CollateralMgmt where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey And CustomerID=@Cust_Ucic_Acid

				Select @LatestColletralSum =SUM(TotalCollateralvalueatcustomerlevel)  from(
				Select (ISNULL(LatestCollateralValueinRs,0)) as TotalCollateralvalueatcustomerlevel
										from CollateralValueDetails A
										INNER JOIN CollateralMgmt  B ON A.CollateralID=B.CollateralID Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey 
										And A.CollateralID in (Select CollateralID from #tmp)
										AND B.CustomerID=@Cust_Ucic_Acid
					)X		
					
					Select @LatestColletralCount=Count(*) from #tmp


					Select @LatestColletralSum as LatestColletralSum,@LatestColletralCount as LatestColletralCount,'TotalSumColletral' as TableName
					SET @RowsRetrurn=@@ROWCOUNT

					if (@RowsRetrurn<=0)
					    BEGIN
				  
							SET @Result=-1
							RETURN @Result
					    END

	END

	IF (@SearchType=4)
	BEGIN
	print 'aaa'
		
IF OBJECT_ID('TempDB..#tmp2') IS NOT NULL Drop Table #tmp2	
		
	IF NOT EXISTS (	Select		M.UCIF_ID,
		           'UCICDetails' TableName,M.CustomerName 
		
			  FROM (
					Select	C.UCIF_ID ,C.CustomerName
				from [CurDat].[AdvAcBasicDetail] A
				Inner Join [CurDat].[CustomerBasicDetail] C
						on A.REfcustomerID=C.CustomerID) As M
						WHERE M.UCIF_ID=@Cust_Ucic_Acid)

						BEGIN

						Select 'NULL' as UCIC_ID,'UCICDetails' TableName,'' CustomerName

						END
						Else
						BEgin
						Select		M.UCIF_ID,
							'UCICDetails' TableName ,M.CustomerName
		
									FROM (
					Select	C.UCIF_ID ,C.CustomerName
				from [CurDat].[AdvAcBasicDetail] A
				Inner Join [CurDat].[CustomerBasicDetail] C
						on A.REfcustomerID=C.CustomerID) As M
						WHERE M.UCIF_ID=@Cust_Ucic_Acid

						END


Select CollateralID into #tmp2 from CollateralMgmt where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey And UCICID=@Cust_Ucic_Acid

				Select @LatestColletralSum =SUM(TotalCollateralvalueatcustomerlevel)  from(
				Select (ISNULL(LatestCollateralValueinRs,0)) as TotalCollateralvalueatcustomerlevel
										from CollateralValueDetails A
										INNER JOIN CollateralMgmt  B ON A.CollateralID=B.CollateralID Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey 
										And A.CollateralID in (Select CollateralID from #tmp2)
										AND B.UCICID=@Cust_Ucic_Acid
					)X		
					
					Select @LatestColletralCount=Count(*) from #tmp2


					Select @LatestColletralSum as LatestColletralSum,@LatestColletralCount as LatestColletralCount,'ColletralDetails2' as TableName

					SET @RowsRetrurn=@@ROWCOUNT

					if (@RowsRetrurn<=0)
					    BEGIN
				  
							SET @Result=-4
							--RETURN @Result;
					    END
						--Select @Result As result
	END

	IF (@SearchType=2)
	BEGIN

	IF OBJECT_ID('TempDB..#tmp1') IS NOT NULL Drop Table #tmp1	
	
			If Not Exists(	Select		M.AccountID,M.CustomerId, 
					        M.CustomerName, 
					        'AccountDetails' TableName
			
             FROM (
					Select	A.CustomerACID AS AccountID,C.CustomerId, 
							C.CustomerName
						from [CurDat].[AdvAcBasicDetail] A
				Inner Join [CurDat].[CustomerBasicDetail] C
						on A.REfcustomerID=C.CustomerID) As M
						WHERE M.AccountID=@Cust_Ucic_Acid)
			Begin

			Select '' As AccountID, 
					'' As CustomerId,
					 '' As CustomerName, 
					 'AccountDetails' TableName
			End
			Else
			Begin
			Select		M.AccountID, M.CustomerId,
					        M.CustomerName, 
					        'AccountDetails' TableName
			
             FROM (
					Select	A.CustomerACID AS AccountID, C.CustomerId,
							C.CustomerName
						from [CurDat].[AdvAcBasicDetail] A
				Inner Join [CurDat].[CustomerBasicDetail] C
						on A.REfcustomerID=C.CustomerID) As M
						WHERE M.AccountID=@Cust_Ucic_Acid
			End

			Select CollateralID into #tmp1 from CollateralMgmt where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey And AccountID=@Cust_Ucic_Acid

				Select @LatestColletralSum =SUM(TotalCollateralvalueatcustomerlevel)  from(
				Select (ISNULL(LatestCollateralValueinRs,0)) as TotalCollateralvalueatcustomerlevel
										from CollateralValueDetails A
										INNER JOIN CollateralMgmt  B ON A.CollateralID=B.CollateralID Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey 
										And A.CollateralID in (Select CollateralID from #tmp1)
										AND B.AccountID=@Cust_Ucic_Acid
					)X		
					
					Select @LatestColletralCount=Count(*) from #tmp1


					Select @LatestColletralSum as LatestColletralSum,@LatestColletralCount as LatestColletralCount,'ColletralDetails2' as TableName


					SET @RowsRetrurn=@@ROWCOUNT

					if (@RowsRetrurn<=0)
					    BEGIN
				  
							SET @Result=-2
							RETURN @Result
					    END
	END
						
END
GO