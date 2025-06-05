SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE Procedure [dbo].[ExceptionalDegrationAccountMarkingValidation]
 @CustomerACID  varchar (50)=Null,
 @FlagAlt_Key varchar(5)=null,
 @MarkingAlt_Key int 
 As 
 begin
Declare @Timekey Int
Set @Timekey =(Select TimeKey from SysDataMatrix where CurrentStatus='C')

--10  add 20 remove

--Set @Timekey =(Select TimeKey from SysDayMatrix where Date=Cast(Getdate() as Date))

 IF @MarkingAlt_Key=20  ----addd
 BEGIN 
IF Not Exists(
			select AccountID from ExceptionalDegrationDetail_Mod  --select * from ExceptionalDegrationDetail_Mod
			where MarkingAlt_Key=@MarkingAlt_Key and EffectiveFromTimeKey<=@Timekey
			and	EffectiveToTimeKey>=@Timekey and  FlagAlt_Key=@FlagAlt_Key and AccountID=@CustomerACID
			And AuthorisationStatus in ('NP','MP','1A')

			UNION
			Select ACID from AccountFlaggingDetails_Mod
			where Action='Y' and  EffectiveFromTimeKey<=@Timekey
							and	EffectiveToTimeKey>=@Timekey
			and UploadTypeParameterAlt_Key=@FlagAlt_Key
			and Acid=@CustomerACID
			And AuthorisationStatus in ('NP','MP','1A')
)

Begin 

--Select 
--'' As SourceAlt_Key
--,''As CustomerID
--,''As ACID
--,'' As StatusType
--,'' As StatusDate
--,''As Amount
--,'CustExceptionFinalStatusType'as TableName

 Select 
 SourceAlt_Key
 ,CustomerID
 ,ACID
 ,StatusType
 --,D.ParameterName
 ,StatusDate
 ,Amount
 ,'YCustExceptionFinalStatusType'as TableName --select * 
 from ExceptionFinalStatusType E
 inner join DimParameter D on E.statustype=D.ParameterName And D.EffectiveToTimeKey=49999
 And D.DimParameterName='UploadFLagType'
 where ACID=@CustomerACID And D.ParameterAlt_Key=@FlagAlt_Key And E.EffectiveToTimeKey=49999

END
Else
Begin
Select 
 '' As SourceAlt_Key
 ,''As CustomerID
 ,''As ACID
 ,'' As StatusType
 ,'' As StatusDate
 ,''As Amount
 ,'YCustExceptionFinalStatusType'as TableName

 --Select 
 --SourceAlt_Key
 --,CustomerID
 --,ACID
 --,StatusType
 ----,D.ParameterName
 --,StatusDate
 --,Amount
 --,'CustExceptionFinalStatusType'as TableName
 --from ExceptionFinalStatusType E
 --inner join DimParameter D on E.statustype=D.ParameterName And D.EffectiveToTimeKey=49999
 --And D.DimParameterName='UploadFLagType'
 --where ACID=@CustomerACID And D.ParameterAlt_Key=@FlagAlt_Key
 --And E.EffectiveToTimeKey=49999

End

END

IF @MarkingAlt_Key=10---Remove 
BEGIN

IF Not Exists(
			    select AccountID from ExceptionalDegrationDetail_Mod 
			    where MarkingAlt_Key=@MarkingAlt_Key and EffectiveFromTimeKey<=@Timekey
				and	EffectiveToTimeKey>=@Timekey and  FlagAlt_Key=@FlagAlt_Key and AccountID=@CustomerACID
				And AuthorisationStatus in ('NP','MP','1A') 

				UNION

				Select ACID from AccountFlaggingDetails_Mod
				where Action='N'
				and EffectiveFromTimeKey<=@Timekey
				and	EffectiveToTimeKey>=@Timekey
				and UploadTypeParameterAlt_Key=@FlagAlt_Key
				and Acid=@CustomerACID
				And AuthorisationStatus in ('NP','MP','1A')
)
IF Not Exists(
			    select ACID from ExceptionFinalStatusType E
			    inner join DimParameter D on E.statustype=D.ParameterName 
				And D.EffectiveToTimeKey=49999
			    And D.DimParameterName='UploadFLagType'
			    where E.EffectiveFromTimeKey<=@Timekey
				and	E.EffectiveToTimeKey>=@Timekey and  D.ParameterAlt_Key=@FlagAlt_Key 
				and ACID=@CustomerACID
				And ISNULL(E.AuthorisationStatus,'A') in ('A')
)
Begin
 
 Select 
 '' As SourceAlt_Key
 ,''As CustomerID
 ,'' As ACID
 ,'' As StatusType
 ,'' As StatusDate
 ,''As Amount
 ,'YCustExceptionFinalStatusType'as TableName

END
Else
Begin
 Select 
 SourceAlt_Key
 ,CustomerID
 ,ACID
 ,StatusType
 ,StatusDate
 ,Amount
 ,'NCustExceptionFinalStatusType'as TableName
 from ExceptionFinalStatusType E
  inner join DimParameter D on E.statustype=D.ParameterName And D.EffectiveToTimeKey=49999
 And D.DimParameterName='UploadFLagType'
 where ACID=@CustomerACID And D.ParameterAlt_Key=@FlagAlt_Key
 And E.EffectiveToTimeKey=49999 
End

End

END
GO