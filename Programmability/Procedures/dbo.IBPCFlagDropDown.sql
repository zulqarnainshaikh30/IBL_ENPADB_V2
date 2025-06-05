SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROC [dbo].[IBPCFlagDropDown]

AS
	BEGIN

Declare @Timekey Int,@CustomerACID  varchar (50)
--Set @Timekey =(Select TimeKey from SysDataMatrix where CurrentStatus='C')
Set @Timekey =(Select TimeKey from SysDayMatrix where Date=Cast(Getdate() as Date))
BEGIN

		Select	Distinct PoolID
					,PoolName
					,PoolType
					,Case when isnull(MaturityDate,'')='' then Null else convert(Varchar(10),MaturityDate,103) ENd MaturityDate
					--,MaturityDate
					,'PoolList' as TableName
		from		IBPCFinalPoolSummary A
		where A.EffectiveFromTimeKey<=@Timekey
		and	A.EffectiveToTimeKey>=@Timekey
		

END				

	END
GO