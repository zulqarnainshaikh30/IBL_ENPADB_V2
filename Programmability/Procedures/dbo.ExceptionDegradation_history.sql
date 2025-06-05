SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE Proc [dbo].[ExceptionDegradation_history]
@AccountID varchar(30)
As
--Declare @AccountID varchar(30)='1002035020000138'
Declare @TimeKey as Int
	SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')

	IF OBJECT_ID('Tempdb..#FINAL') IS NOT NULL
	Drop Table #FINAL
select 'S' Flag,S.SourceName,AccountID AccountID,E.CustomerID,F.ParameterName as FlagDesciption,Date,E.Amount
,H.ParameterName as MarkingDescription,
A.CreatedBy,
A.DateCreated,
ApprovedByFirstLevel,
DateApprovedFirstLevel,
A.ApprovedBy,
A.DateApproved
--select *
INTO #FINAL
    FROM	ExceptionFinalStatusType E	
	left JOIN [dbo].[ExceptionalDegrationDetail_Mod] A ON E.ACID=A.AccountID
	            
	left join DIMSOURCEDB S on S.SourceAlt_Key=A.SourceAlt_Key 
	left join 		(select ParameterAlt_Key,ParameterName  from DimParameter A
		                   where		[DimParameterName] = 'UploadFLagType'
		                  --and          ParameterAlt_Key in (1,3,9,17,18,19)
		                     and			A.EffectiveFromTimeKey<=@Timekey
		                           and			A.EffectiveToTimeKey>=@Timekey
								   )F ON F.ParameterAlt_Key=A.FlagAlt_Key

   LEFT Join (Select ParameterAlt_Key,ParameterName,'DimYesNo' as Tablename 
						  from DimParameter where DimParameterName='DimYesNo'
						  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)H
						  ON H.ParameterAlt_Key=A.MarkingAlt_Key
	        
			WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
						   AND E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey
						   AND A.AccountID=@AccountID
                       
                           AND A.Entity_Key IN
                     (
                         SELECT MAX(Entity_Key)
                         FROM [dbo].[ExceptionalDegrationDetail_Mod]
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('A')
							   
                         GROUP BY AccountID,FlagAlt_Key
  
                     )
					 
  UNION ALL

select 'U' Flag,S.SourceName,E.ACID AccountID,B.RefCustomerId CustomerId,F.ParameterName as FlagDesciption,Date,E.Amount
,A.Action as MarkingDescription,
A.CreatedBy,	
A.DateCreated,
ApprovedByFirstLevel,
DateApprovedFirstLevel,
A.ApprovedBy,
A.DateApproved 
  --select *
  from ExceptionFinalStatusType E
  inner Join AccountFlaggingDetails_Mod A ON E.ACID=A.ACID
  Left JOIN curdat.AdvAcBasicDetail B On A.ACID=B.SystemACID
                                      AND B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey
									  AND E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey
  Left Join DIMSOURCEDB S ON S.SourceAlt_Key=B.SourceAlt_Key
                                      AND S.EffectiveToTimeKey=49999
left join 		(select ParameterAlt_Key,ParameterName  from DimParameter A
		                   where		[DimParameterName] = 'UploadFLagType'
		                  --and          ParameterAlt_Key in (1,3,9,17,18,19)
		                     and			A.EffectiveFromTimeKey<=@Timekey
		                           and			A.EffectiveToTimeKey>=@Timekey
								   )F ON F.ParameterAlt_Key=A.UploadTypeParameterAlt_Key


 	 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
						   AND A.ACID=@AccountID
                       
                           AND A.Entity_Key IN
                     (
                         SELECT MAX(Entity_Key)
                         FROM [dbo].[AccountFlaggingDetails_Mod]
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('A')
							   
                         GROUP BY acid,UploadTypeParameterAlt_Key
                     )
					 

					 select * from #Final where ApprovedByFirstLevel is not null
					  --select distinct Accountid,* from #Final

--Select  * from ExceptionalDegrationDetail_Mod where AccountID='1002035020000138'

--Select   * from AccountFlaggingDetails_Mod where acid='1002035020000138'

--Select * from ExceptionFinalStatusType where acid='1002035020000138'
GO