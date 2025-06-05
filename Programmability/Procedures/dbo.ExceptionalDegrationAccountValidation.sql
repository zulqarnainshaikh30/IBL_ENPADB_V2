SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROC [dbo].[ExceptionalDegrationAccountValidation]
@CustomerACID  varchar (50)
,@FlagAlt_Key varchar(5)
AS
	BEGIN

Declare @Timekey Int
Set @Timekey =(Select TimeKey from SysDataMatrix where CurrentStatus='C')

Set @Timekey =(Select TimeKey from SysDayMatrix where Date=Cast(Getdate() as Date))
BEGIN

--IF(@Flag=1)
	--BEGIN
		select * from
		(

		Select		A.SourceAlt_Key
					,AccountID
					,CustomerID
					,Date
					,MarkingAlt_Key
					,Amount
					,'CustExceptionalDegrationDetails'as TableName
		from		ExceptionalDegrationDetail_Mod A
				Inner join DIMSOURCEDB ds on ds.SourceAlt_Key=A.SourceAlt_Key
		where		AccountID = @CustomerACID
					AND FlagAlt_Key=@FlagAlt_Key
		and			A.EffectiveFromTimeKey<=@Timekey
		and			A.EffectiveToTimeKey>=@Timekey
		And IsNull(A.AuthorisationStatus,'A') in('NP','MP')--)dt
		
			UNION

		Select	
		B.SourceAlt_Key
		,ACID
		,B.RefCustomerId
		,Date
		,UploadTypeParameterAlt_Key
		,Amount
		,'CustAccountFlaggingDetails'as TableName
		from		AccountFlaggingDetails_Mod A
		inner join curdat.advacbasicdetail B
					ON A.ACID=B.CustomerACID
		Inner Join (Select ParameterAlt_Key,ParameterName,'UploadFlagType' as Tablename 
						  from DimParameter where DimParameterName='UploadFlagType'
						  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)H
						  ON H.ParameterAlt_Key=A.UploadTypeParameterAlt_Key
				where		ACID = @CustomerACID
		and			A.EffectiveFromTimeKey<=@Timekey
		and			A.EffectiveToTimeKey>=@Timekey
		And IsNull(A.AuthorisationStatus,'A') in('NP','MP'))dt


		if not exists( select AccountID from ExceptionalDegrationDetail_Mod A
						inner join AccountFlaggingDetails_Mod B
						on A.AccountID=B.ACID
						and FlagAlt_Key='Y'
						)

						IF (@FlagAlt_Key='Y')
						Begin

							Select 
							SourceAlt_Key
							,CustomerID
							,ACID
							,StatusType
							,StatusDate
							,Amount
							,'CustExceptionFinalStatusType'as TableName
							from ExceptionFinalStatusType
							where ACID=@CustomerACID
						 
						 END

						 if not exists( select AccountID from ExceptionalDegrationDetail_Mod A
						inner join AccountFlaggingDetails_Mod B
						on A.AccountID=B.ACID
						and FlagAlt_Key='Y'
						)

						IF (@FlagAlt_Key='N')
						Begin

							Select 
							SourceAlt_Key
							,CustomerID
							,ACID
							,StatusType
							,StatusDate
							,Amount
							,'CustExceptionFinalStatusType1'as TableName
							from ExceptionFinalStatusType
							where ACID=@CustomerACID
						 
						 END
	--END


	

END				

	END
GO