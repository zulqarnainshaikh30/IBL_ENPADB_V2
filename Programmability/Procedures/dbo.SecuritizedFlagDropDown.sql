SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROC [dbo].[SecuritizedFlagDropDown]

AS
	BEGIN

Declare @Timekey Int,@CustomerACID  varchar (50)
--Set @Timekey =(Select TimeKey from SysDataMatrix where CurrentStatus='C')
Set @Timekey =(select CAST(B.timekey as int)from SysDataMatrix A
			Inner Join SysDayMatrix B ON A.TimeKey=B.TimeKey
			 where A.CurrentStatus='C')
BEGIN

		Select	Distinct PoolID
					,PoolName
					,SecuritisationType
					,Case when isnull(MaturityDate,'')='' then Null else convert(Varchar(10),MaturityDate,103) ENd MaturityDate
					,'PoolList' as TableName
		from		SecuritizedFinalACSummary A
		where A.EffectiveFromTimeKey<=@Timekey
		and	A.EffectiveToTimeKey>=@Timekey
		

END				

	END
GO