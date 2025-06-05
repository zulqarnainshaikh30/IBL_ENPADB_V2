SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROC [dbo].[ExceptionalDegrationCustomerDropDown]

AS
	BEGIN

Declare @Timekey Int
Set @Timekey =(Select TimeKey from SysDataMatrix where CurrentStatus='C')
 

BEGIN
      --Declare  @Timekey  int =(Select TimeKey from Automate_Advances where EXT_FLG='Y')
		Select	     [CustomerACID]
					,[CustomerId]
				    ,[CustomerName]
		from		[CurDat].[AdvAcBasicDetail] A
		Inner Join	[CurDat].[CustomerBasicDetail] B On A.[CustomerEntityId]=B.[CustomerEntityId]	
		where		A.EffectiveFromTimeKey<=@Timekey
		and			A.EffectiveToTimeKey>=@Timekey
		and			B.EffectiveFromTimeKey<=@Timekey
		and			B.EffectiveToTimeKey>=@Timekey
END				

END
GO