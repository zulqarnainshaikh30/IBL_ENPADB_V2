SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

 CREATE Procedure [dbo].[ExceptionalDegrationAccountFlagVaildation]
 @CustomerACID varchar (50)=Null,
 @FlagAlt_Key varchar(5)=Null
 As
 Begin

Declare @Timekey Int 
Set @Timekey =(select TimeKey from SYSdatamatrix where  currentstatus='C' ) --26936

--Set @Timekey =(Select TimeKey from SysDayMatrix where Date=Cast(Getdate() as Date))

IF Not Exists(Select A.SourceAlt_Key,AccountID
					,CustomerID
					,Date
					,MarkingAlt_Key
					,Amount
					,'CustExceptionalDegrationDetails'as TableName --select *
					from ExceptionalDegrationDetail_Mod A
						 Inner join DIMSOURCEDB ds on ds.SourceAlt_Key=A.SourceAlt_Key
					where AccountID = @CustomerACID 
					AND FlagAlt_Key=@FlagAlt_Key
					and A.EffectiveFromTimeKey<=@Timekey
					and A.EffectiveToTimeKey>=@Timekey
					And IsNull(A.AuthorisationStatus,'A') in('NP','MP'))

		Begin 
		Select		''as SourceAlt_Key,
					'' As AccountID
					,'' AS CustomerID
					,'' AS Date
					,''As MarkingAlt_Key
					,'' AS Amount
					,''as TableName,'' As ValidationPending
 
		END
		
		Else
		Begin

		Select		A.SourceAlt_Key
					,AccountID
					,CustomerID
					,Date
					,MarkingAlt_Key
					,Amount
					,'CustExceptionalDegrationDetails'as TableName,'Y' As ValidationPending
		from		ExceptionalDegrationDetail_Mod A
				Inner join DIMSOURCEDB ds on ds.SourceAlt_Key=A.SourceAlt_Key
		where		AccountID = @CustomerACID
					AND FlagAlt_Key=@FlagAlt_Key
		and			A.EffectiveFromTimeKey<=@Timekey
		and			A.EffectiveToTimeKey>=@Timekey
		And IsNull(A.AuthorisationStatus,'A') in('NP','MP')


		END
	
	IF NOT exists(
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
		And IsNull(A.AuthorisationStatus,'A') in('NP','MP'))
		Begin

		Select	
		''As SourceAlt_Key
		,'' As ACID
		,'' As RefCustomerId
		,'' As Date
		,''As UploadTypeParameterAlt_Key
		,''As Amount
		,''as TableName,'' As ValidationPending


		END
		Else
		Begin
			Select	
			B.SourceAlt_Key
			,ACID
			,B.RefCustomerId
			,Date
			,UploadTypeParameterAlt_Key
			,Amount
			,'CustAccountFlaggingDetails'as TableName,'Y' As ValidationPending
			from	AccountFlaggingDetails_Mod A
			inner join curdat.advacbasicdetail B
					ON A.ACID=B.CustomerACID
		Inner Join (Select ParameterAlt_Key,ParameterName,'UploadFlagType' as Tablename 
						  from DimParameter where DimParameterName='UploadFlagType'
						  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)H
						  ON H.ParameterAlt_Key=A.UploadTypeParameterAlt_Key
				where		ACID = @CustomerACID
		and			A.EffectiveFromTimeKey<=@Timekey
		and			A.EffectiveToTimeKey>=@Timekey
		And IsNull(A.AuthorisationStatus,'A') in('NP','MP')


		End

		End
GO