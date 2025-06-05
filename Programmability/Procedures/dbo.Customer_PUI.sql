SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--exec Customer_PUI @AccountID=N'9987880000000002'
--go


CREATE Proc [dbo].[Customer_PUI]
@AccountID varchar(30)
As

--Declare @AccountID varchar(30)='1711212010245923'
Declare @TimeKey as Int
	SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')

	select 
	C.CustomerName as CustomerName
	,C.UCIF_ID   as UCIF_ID
	,C.CustomerId  as CustomerID
	,B.CustomerACID  As AccountID
	,'PUICustNameUCIC' TableName
	from CustomerBasicdetail C
	Inner join advacbasicdetail B ON   B.customerentityid=C.customerentityid
	where 
	C.EffectiveFromTimeKey<=@TimeKey and C.EffectiveToTimeKey>=@TimeKey and
	  B.EffectiveFromTimeKey<=@TimeKey and B.EffectiveToTimeKey>=@TimeKey and
	 CustomerACID=@AccountID
	

	
	--select * from CustomerBasicdetail where CustomerID='22120366'
	--select * from advacbasicdetail where customerentityid='605'
	--exec Customer_PUI @CustomerID='22120366'
GO