SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROC [dbo].[SelectSolutionGlobalParameter]

							@operationFlag Int=2

AS

BEGIN

Declare @TimeKey as Int
	SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')

Declare @SystemDate Date
			SET @SystemDate =(Select CAST(B.Date as Date)Date1 from SysDataMatrix A
			Inner Join SysDayMatrix B ON A.TimeKey=B.TimeKey
			 where A.CurrentStatus='C')
					

BEGIN TRY

/*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */


			IF(@OperationFlag not in(16,20))
             BEGIN
			 IF OBJECT_ID('TempDB..#temp') IS NOT NULL
                 DROP TABLE  #temp;
                 SELECT 
							 Convert(VARCHAR(20),@SystemDate,103) as ProcessDate
							,A.ParameterAlt_Key
							,A.ParameterName
							,A.ParameterValueAlt_Key
							,A.ParameterValue
							,A.ParameterNatureAlt_Key
							,A.NatureName
							--,A.From_Date
							,A.From_Date
							--,A.To_Date
							,A.To_Date
							,A.ParameterStatusAlt_Key
							,A.StatusName
							,A.AuthorisationStatus
                            ,A.EffectiveFromTimeKey
                            ,A.EffectiveToTimeKey
                            ,A.CreatedBy
                            ,A.DateCreated
                            ,A.ApprovedBy
                            ,A.DateApproved 
                            ,A.ModifiedBy
                            ,A.DateModified
							,A.CrModBy
							,A.CrModDate
							,A.CrAppBy
							,A.CrAppDate
							,A.ModAppBy
							,A.ModAppDate
                 INTO #temp
                 FROM 
				 ( 
                Select * from
				(select * from
				 (
                     Select 
					 Convert(VARCHAR(20),@SystemDate,103) as ProcessDate
					 ,A.EntityKey
					 ,A.ParameterAlt_Key
					 ,A.ParameterName
					 ,A.ParameterValueAlt_Key
					 ,B.ParameterName as ParameterValue
					 ,A.ParameterNatureAlt_Key
					 ,C.ParameterName as NatureName
					 ,Convert(VARCHAR(20),A.From_Date,103) From_Date
					 ,Convert(VARCHAR(20),A.To_Date,103) To_Date
					,A.ParameterStatusAlt_Key
					 ,D.ParameterName as StatusName
					 ,isnull(AuthorisationStatus, 'A') AuthorisationStatus
					 ,EffectiveFromTimeKey
					 ,EffectiveToTimeKey 
					 ,CreatedBy
					 ,DateCreated
					 ,ApprovedBy
					 ,DateApproved 
					 ,ModifiedBy 
					 ,DateModified
					 ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate 
					from SolutionGlobalParameter A
					Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Frequency' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Frequency' )B ON A.ParameterValueAlt_Key=B.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Nature' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Nature' )C ON A.ParameterNatureAlt_Key=C.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'ParameterStatus' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='ParameterStatus' )D ON A.ParameterStatusAlt_Key=D.ParameterAlt_key
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
And A.ParameterAlt_key In (1,2,13)

UNION ALL

Select 
				      Convert(VARCHAR(20),@SystemDate,103) as ProcessDate
					 ,A.EntityKey
					 ,A.ParameterAlt_Key
					 ,A.ParameterName
					 ,A.ParameterValueAlt_Key
					 ,B.ParameterName as ParameterValue
					 ,A.ParameterNatureAlt_Key
					 ,C.ParameterName as NatureName
					 ,Convert(VARCHAR(20),A.From_Date,103) From_Date
					,Convert(VARCHAR(20),A.To_Date,103) To_Date
					,A.ParameterStatusAlt_Key
					 ,D.ParameterName as StatusName
					 ,isnull(AuthorisationStatus, 'A') AuthorisationStatus
					 ,EffectiveFromTimeKey
					 ,EffectiveToTimeKey 
					 ,CreatedBy
					 ,DateCreated
					 ,ApprovedBy
					 ,DateApproved 
					 ,ModifiedBy 
					 ,DateModified 
					 ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
 from SolutionGlobalParameter A
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Holidays' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Holidays' )B ON A.ParameterValueAlt_Key=B.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Nature' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Nature' )C ON A.ParameterNatureAlt_Key=C.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'ParameterStatus' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='ParameterStatus' )D ON A.ParameterStatusAlt_Key=D.ParameterAlt_key
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
And A.ParameterAlt_key In (3,5,14,22,23,24,25,26,27,28,29,30,31,32)

UNION ALL

Select 
Convert(VARCHAR(20),@SystemDate,103) as ProcessDate
,A.EntityKey
,A.ParameterAlt_Key
					 ,A.ParameterName
					 ,A.ParameterValueAlt_Key
					 ,B.ParameterName as ParameterValue
					 ,A.ParameterNatureAlt_Key
					 ,C.ParameterName as NatureName
					 ,Convert(VARCHAR(20),A.From_Date,103) From_Date
					 ,Convert(VARCHAR(20),A.To_Date,103) To_Date
					,A.ParameterStatusAlt_Key
					 ,D.ParameterName as StatusName
					 ,isnull(AuthorisationStatus, 'A') AuthorisationStatus
					 ,EffectiveFromTimeKey
					 ,EffectiveToTimeKey 
					 ,CreatedBy
					 ,DateCreated
					 ,ApprovedBy
					 ,DateApproved 
					 ,ModifiedBy 
					 ,DateModified 
					 ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate

 from SolutionGlobalParameter A
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'System' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='System' )B ON A.ParameterValueAlt_Key=B.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Nature' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Nature' )C ON A.ParameterNatureAlt_Key=C.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'ParameterStatus' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='ParameterStatus' )D ON A.ParameterStatusAlt_Key=D.ParameterAlt_key
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
And A.ParameterAlt_key In (4,10,11,12)

UNION ALL

Select 
Convert(VARCHAR(20),@SystemDate,103) as ProcessDate
,A.EntityKey
,A.ParameterAlt_Key
					 ,A.ParameterName
					 ,A.ParameterValueAlt_Key
					 ,B.ParameterName as ParameterValue
					 ,A.ParameterNatureAlt_Key
					 ,C.ParameterName as NatureName
					 ,Convert(VARCHAR(20),A.From_Date,103) From_Date
					 ,Convert(VARCHAR(20),A.To_Date,103) To_Date
					,A.ParameterStatusAlt_Key
					 ,D.ParameterName as StatusName
					 ,isnull(AuthorisationStatus, 'A') AuthorisationStatus
					 ,EffectiveFromTimeKey
					 ,EffectiveToTimeKey 
					 ,CreatedBy
					 ,DateCreated
					 ,ApprovedBy
					 ,DateApproved 
					 ,ModifiedBy 
					 ,DateModified 
					 ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate

 from SolutionGlobalParameter A
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Status' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Status' )B ON A.ParameterValueAlt_Key=B.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Nature' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Nature' )C ON A.ParameterNatureAlt_Key=C.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'ParameterStatus' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='ParameterStatus' )D ON A.ParameterStatusAlt_Key=D.ParameterAlt_key
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
And A.ParameterAlt_key In (6)

UNION ALL

Select 
Convert(VARCHAR(20),@SystemDate,103) as ProcessDate
,A.EntityKey
,A.ParameterAlt_Key
					 ,A.ParameterName
					 ,A.ParameterValueAlt_Key
					 ,B.ParameterName as ParameterValue
					 ,A.ParameterNatureAlt_Key
					 ,C.ParameterName as NatureName
					 ,Convert(VARCHAR(20),A.From_Date,103) From_Date
					 ,Convert(VARCHAR(20),A.To_Date,103) To_Date
					 ,A.ParameterStatusAlt_Key
					 ,D.ParameterName as StatusName
					 ,isnull(AuthorisationStatus, 'A') AuthorisationStatus
					 ,EffectiveFromTimeKey
					 ,EffectiveToTimeKey 
					 ,CreatedBy
					 ,DateCreated
					 ,ApprovedBy
					 ,DateApproved 
					 ,ModifiedBy 
					 ,DateModified 
					,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
 from SolutionGlobalParameter A
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Model' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Model' )B ON A.ParameterValueAlt_Key=B.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Nature' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Nature' )C ON A.ParameterNatureAlt_Key=C.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'ParameterStatus' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='ParameterStatus' )D ON A.ParameterStatusAlt_Key=D.ParameterAlt_key
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
And A.ParameterAlt_key In (15)

UNION ALL

Select 
Convert(VARCHAR(20),@SystemDate,103) as ProcessDate
,A.EntityKey
,A.ParameterAlt_Key
					 ,A.ParameterName
					 ,A.ParameterValueAlt_Key
					 ,B.ParameterName as ParameterValue
					 ,A.ParameterNatureAlt_Key
					 ,C.ParameterName as NatureName
					 ,Convert(VARCHAR(20),A.From_Date,103) From_Date
					 ,Convert(VARCHAR(20),A.To_Date,103) To_Date
					,A.ParameterStatusAlt_Key
					 ,D.ParameterName as StatusName
					 ,isnull(AuthorisationStatus, 'A') AuthorisationStatus
					 ,EffectiveFromTimeKey
					 ,EffectiveToTimeKey 
					 ,CreatedBy
					 ,DateCreated
					 ,ApprovedBy
					 ,DateApproved 
					 ,ModifiedBy 
					 ,DateModified 
					 ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
 from SolutionGlobalParameter A
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'CumulativeDefinePeriod' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='CumulativeDefinePeriod' )B ON A.ParameterValueAlt_Key=B.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Nature' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Nature' )C ON A.ParameterNatureAlt_Key=C.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'ParameterStatus' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='ParameterStatus' )D ON A.ParameterStatusAlt_Key=D.ParameterAlt_key
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
And A.ParameterAlt_key In (7)

UNION ALL

Select 
Convert(VARCHAR(20),@SystemDate,103) as ProcessDate
,A.EntityKey
,A.ParameterAlt_Key
					 ,A.ParameterName
					 ,A.ParameterValueAlt_Key
					 ,B.ParameterName as ParameterValue
					 ,A.ParameterNatureAlt_Key
					 ,C.ParameterName as NatureName
					 ,Convert(VARCHAR(20),A.From_Date,103) From_Date
					 ,Convert(VARCHAR(20),A.To_Date,103) To_Date
					 ,A.ParameterStatusAlt_Key
					 ,D.ParameterName as StatusName
					 ,isnull(AuthorisationStatus, 'A') AuthorisationStatus
					 ,EffectiveFromTimeKey
					 ,EffectiveToTimeKey 
					 ,CreatedBy
					 ,DateCreated
					 ,ApprovedBy
					 ,DateApproved 
					 ,ModifiedBy 
					 ,DateModified 
					 ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
 from SolutionGlobalParameter A
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'CumulativeDefineDays' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='CumulativeDefineDays' )B ON A.ParameterValueAlt_Key=B.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Nature' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Nature' )C ON A.ParameterNatureAlt_Key=C.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'ParameterStatus' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='ParameterStatus' )D ON A.ParameterStatusAlt_Key=D.ParameterAlt_key
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
And A.ParameterAlt_key In (8)

UNION ALL

Select 
Convert(VARCHAR(20),@SystemDate,103) as ProcessDate
,A.EntityKey
,A.ParameterAlt_Key
					 ,A.ParameterName
					 ,A.ParameterValueAlt_Key
					 ,B.ParameterName as ParameterValue
					 ,A.ParameterNatureAlt_Key
					 ,C.ParameterName as NatureName
					 ,Convert(VARCHAR(20),A.From_Date,103) From_Date
					 ,Convert(VARCHAR(20),A.To_Date,103) To_Date
					,A.ParameterStatusAlt_Key
					 ,D.ParameterName as StatusName
					 ,isnull(AuthorisationStatus, 'A') AuthorisationStatus
					 ,EffectiveFromTimeKey
					 ,EffectiveToTimeKey 
					 ,CreatedBy
					 ,DateCreated
					 ,ApprovedBy
					 ,DateApproved 
					 ,ModifiedBy 
					 ,DateModified 
					 ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
 from SolutionGlobalParameter A
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'CumulativeDefineInterestServiced' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='CumulativeDefineInterestServiced' )B ON A.ParameterValueAlt_Key=B.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Nature' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Nature' )C ON A.ParameterNatureAlt_Key=C.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'ParameterStatus' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='ParameterStatus' )D ON A.ParameterStatusAlt_Key=D.ParameterAlt_key
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
And A.ParameterAlt_key In (9)

UNION ALL

Select 
Convert(VARCHAR(20),@SystemDate,103) as ProcessDate
,A.EntityKey
,A.ParameterAlt_Key
					 ,A.ParameterName
					 ,A.ParameterValueAlt_Key
					 ,B.ParameterName as ParameterValue
					 ,A.ParameterNatureAlt_Key
					 ,C.ParameterName as NatureName
					 ,Convert(VARCHAR(20),A.From_Date,103) From_Date
					 ,Convert(VARCHAR(20),A.To_Date,103) To_Date
					,A.ParameterStatusAlt_Key
					 ,D.ParameterName as StatusName
					 ,isnull(AuthorisationStatus, 'A') AuthorisationStatus
					 ,EffectiveFromTimeKey
					 ,EffectiveToTimeKey 
					 ,CreatedBy
					 ,DateCreated
					 ,ApprovedBy
					 ,DateApproved 
					 ,ModifiedBy 
					 ,DateModified 
					 ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
 from SolutionGlobalParameter A
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'securityvalue' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='securityvalue' )B ON A.ParameterValueAlt_Key=B.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Nature' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Nature' )C ON A.ParameterNatureAlt_Key=C.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'ParameterStatus' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='ParameterStatus' )D ON A.ParameterStatusAlt_Key=D.ParameterAlt_key
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
And A.ParameterAlt_key In (19)

UNION ALL


Select 
Convert(VARCHAR(20),@SystemDate,103) as ProcessDate
					 ,A.EntityKey
					 ,A.ParameterAlt_Key
					 ,A.ParameterName
					 ,A.ParameterValueAlt_Key
					 ,Convert(Varchar(20),A.ParameterValueAlt_Key) as ParameterValue
					 ,A.ParameterNatureAlt_Key
					 ,C.ParameterName as NatureName
					 ,Convert(VARCHAR(20),A.From_Date,103) From_Date
					 ,Convert(VARCHAR(20),A.To_Date,103) To_Date
					,A.ParameterStatusAlt_Key
					 ,D.ParameterName as StatusName
					 ,isnull(AuthorisationStatus, 'A') AuthorisationStatus
					 ,EffectiveFromTimeKey
					 ,EffectiveToTimeKey 
					 ,CreatedBy
					 ,DateCreated
					 ,ApprovedBy
					 ,DateApproved 
					 ,ModifiedBy 
					 ,DateModified 
					 ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
					from SolutionGlobalParameter A
				Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Nature' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Nature' )C ON A.ParameterNatureAlt_Key=C.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'ParameterStatus' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='ParameterStatus' )D ON A.ParameterStatusAlt_Key=D.ParameterAlt_key
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
And A.ParameterAlt_key In (16,17,18)  ----,20,21



UNION ALL
Select 
Convert(VARCHAR(20),@SystemDate,103) as ProcessDate
,A.EntityKey
,A.ParameterAlt_Key
					 ,A.ParameterName
					 ,A.ParameterValueAlt_Key
					 ,B.ParameterName as ParameterValue
					 ,A.ParameterNatureAlt_Key
					 ,C.ParameterName as NatureName
					 ,Convert(VARCHAR(20),A.From_Date,103) From_Date
					 ,Convert(VARCHAR(20),A.To_Date,103) To_Date
					 ,A.ParameterStatusAlt_Key
					 ,D.ParameterName as StatusName
					 ,isnull(AuthorisationStatus, 'A') AuthorisationStatus
					 ,EffectiveFromTimeKey
					 ,EffectiveToTimeKey 
					 ,CreatedBy
					 ,DateCreated
					 ,ApprovedBy
					 ,DateApproved 
					 ,ModifiedBy 
					 ,DateModified 
					 ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
 from SolutionGlobalParameter A
 Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'securityvalue' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='securityvalue' )B ON A.ParameterValueAlt_Key=B.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Nature' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Nature' )C ON A.ParameterNatureAlt_Key=C.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'ParameterStatus' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='ParameterStatus' )D ON A.ParameterStatusAlt_Key=D.ParameterAlt_key
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
And A.ParameterAlt_key Not In (1,2,13,3,5,14,22,23,24,25,26,27,28,29,30,31,32,4,10,11,12,6,15,7,8,9,19,16,17,18,20,21)
)A

UNION

select * from
(
Select 
Convert(VARCHAR(20),@SystemDate,103) as ProcessDate
,A.EntityKey
,A.ParameterAlt_Key
					 ,A.ParameterName
					 ,A.ParameterValueAlt_Key
					 ,B.ParameterName as ParameterValue
					 ,A.ParameterNatureAlt_Key
					 ,C.ParameterName as NatureName
					 ,Convert(VARCHAR(20),A.From_Date,103) From_Date
					 ,Convert(VARCHAR(20),A.To_Date,103) To_Date
					,A.ParameterStatusAlt_Key
					 ,D.ParameterName as StatusName
					 ,isnull(AuthorisationStatus, 'A') AuthorisationStatus
					 ,EffectiveFromTimeKey
					 ,EffectiveToTimeKey 
					 ,CreatedBy
					 ,DateCreated
					 ,ApprovedBy
					 ,DateApproved 
					 ,ModifiedBy 
					 ,DateModified 
					 ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
 from SolutionGlobalParameter_Mod A
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Frequency' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Frequency' )B ON A.ParameterValueAlt_Key=B.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Nature' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Nature' )C ON A.ParameterNatureAlt_Key=C.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'ParameterStatus' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='ParameterStatus' )D ON A.ParameterStatusAlt_Key=D.ParameterAlt_key
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
And A.ParameterAlt_key In (1,2,13)
--------

UNION ALL

Select 
Convert(VARCHAR(20),@SystemDate,103) as ProcessDate
,A.EntityKey
,A.ParameterAlt_Key
					 ,A.ParameterName
					 ,A.ParameterValueAlt_Key
					 ,B.ParameterName as ParameterValue
					 ,A.ParameterNatureAlt_Key
					 ,C.ParameterName as NatureName
					 ,Convert(VARCHAR(20),A.From_Date,103) From_Date
					 ,Convert(VARCHAR(20),A.To_Date,103) To_Date
					,A.ParameterStatusAlt_Key
					 ,D.ParameterName as StatusName
					 ,isnull(AuthorisationStatus, 'A') AuthorisationStatus
					 ,EffectiveFromTimeKey
					 ,EffectiveToTimeKey 
					 ,CreatedBy
					 ,DateCreated
					 ,ApprovedBy
					 ,DateApproved 
					 ,ModifiedBy 
					 ,DateModified 
					 ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
 from SolutionGlobalParameter_Mod A
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Holidays' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Holidays' )B ON A.ParameterValueAlt_Key=B.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Nature' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Nature' )C ON A.ParameterNatureAlt_Key=C.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'ParameterStatus' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='ParameterStatus' )D ON A.ParameterStatusAlt_Key=D.ParameterAlt_key
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
And A.ParameterAlt_key In (3,5,14,22,23,24,25,26,27,28,29,30,31,32)
--------
UNION ALL
 

Select 
Convert(VARCHAR(20),@SystemDate,103) as ProcessDate
,A.EntityKey
,A.ParameterAlt_Key
					 ,A.ParameterName
					 ,A.ParameterValueAlt_Key
					 ,B.ParameterName as ParameterValue
					 ,A.ParameterNatureAlt_Key
					 ,C.ParameterName as NatureName
					 ,Convert(VARCHAR(20),A.From_Date,103) From_Date
					 ,Convert(VARCHAR(20),A.To_Date,103) To_Date
					 ,A.ParameterStatusAlt_Key
					 ,D.ParameterName as StatusName
					 ,isnull(AuthorisationStatus, 'A') AuthorisationStatus
					 ,EffectiveFromTimeKey
					 ,EffectiveToTimeKey 
					 ,CreatedBy
					 ,DateCreated
					 ,ApprovedBy
					 ,DateApproved 
					 ,ModifiedBy 
					 ,DateModified 
					 ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
 from SolutionGlobalParameter_Mod A
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'System' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='System' )B ON A.ParameterValueAlt_Key=B.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Nature' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Nature' )C ON A.ParameterNatureAlt_Key=C.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'ParameterStatus' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='ParameterStatus' )D ON A.ParameterStatusAlt_Key=D.ParameterAlt_key
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
And A.ParameterAlt_key In (4,10,11,12)
--------

UNION ALL


Select 
Convert(VARCHAR(20),@SystemDate,103) as ProcessDate
,A.EntityKey
,A.ParameterAlt_Key
					 ,A.ParameterName
					 ,A.ParameterValueAlt_Key
					 ,B.ParameterName as ParameterValue
					 ,A.ParameterNatureAlt_Key
					 ,C.ParameterName as NatureName
					 ,Convert(VARCHAR(20),A.From_Date,103) From_Date
					 ,Convert(VARCHAR(20),A.To_Date,103) To_Date
					 ,A.ParameterStatusAlt_Key
					 ,D.ParameterName as StatusName
					 ,isnull(AuthorisationStatus, 'A') AuthorisationStatus
					 ,EffectiveFromTimeKey
					 ,EffectiveToTimeKey 
					 ,CreatedBy
					 ,DateCreated
					 ,ApprovedBy
					 ,DateApproved 
					 ,ModifiedBy 
					 ,DateModified 
					 ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
 from SolutionGlobalParameter_Mod A
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Status' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Status' )B ON A.ParameterValueAlt_Key=B.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Nature' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Nature' )C ON A.ParameterNatureAlt_Key=C.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'ParameterStatus' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='ParameterStatus' )D ON A.ParameterStatusAlt_Key=D.ParameterAlt_key
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
And A.ParameterAlt_key In (6)
--------

UNION ALL

Select 
Convert(VARCHAR(20),@SystemDate,103) as ProcessDate
,A.EntityKey
,A.ParameterAlt_Key
					 ,A.ParameterName
					 ,A.ParameterValueAlt_Key
					 ,B.ParameterName as ParameterValue
					 ,A.ParameterNatureAlt_Key
					 ,C.ParameterName as NatureName
					 ,Convert(VARCHAR(20),A.From_Date,103) From_Date
					 ,Convert(VARCHAR(20),A.To_Date,103) To_Date
					 ,A.ParameterStatusAlt_Key
					 ,D.ParameterName as StatusName
					 ,isnull(AuthorisationStatus, 'A') AuthorisationStatus
					 ,EffectiveFromTimeKey
					 ,EffectiveToTimeKey 
					 ,CreatedBy
					 ,DateCreated
					 ,ApprovedBy
					 ,DateApproved 
					 ,ModifiedBy 
					 ,DateModified 
					 ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
 from SolutionGlobalParameter_Mod A
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Model' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Model' )B ON A.ParameterValueAlt_Key=B.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Nature' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Nature' )C ON A.ParameterNatureAlt_Key=C.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'ParameterStatus' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='ParameterStatus' )D ON A.ParameterStatusAlt_Key=D.ParameterAlt_key
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
And A.ParameterAlt_key In (15)
--------

UNION ALL

Select 
Convert(VARCHAR(20),@SystemDate,103) as ProcessDate
,A.EntityKey
,A.ParameterAlt_Key
					 ,A.ParameterName
					 ,A.ParameterValueAlt_Key
					 ,B.ParameterName as ParameterValue
					 ,A.ParameterNatureAlt_Key
					 ,C.ParameterName as NatureName
					 ,Convert(VARCHAR(20),A.From_Date,103) From_Date
					 ,Convert(VARCHAR(20),A.To_Date,103) To_Date
					 ,A.ParameterStatusAlt_Key
					 ,D.ParameterName as StatusName
					 ,isnull(AuthorisationStatus, 'A') AuthorisationStatus
					 ,EffectiveFromTimeKey
					 ,EffectiveToTimeKey 
					 ,CreatedBy
					 ,DateCreated
					 ,ApprovedBy
					 ,DateApproved 
					 ,ModifiedBy 
					 ,DateModified 
					 ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
 from SolutionGlobalParameter_Mod A
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'CumulativeDefinePeriod' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='CumulativeDefinePeriod' )B ON A.ParameterValueAlt_Key=B.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Nature' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Nature' )C ON A.ParameterNatureAlt_Key=C.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'ParameterStatus' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='ParameterStatus' )D ON A.ParameterStatusAlt_Key=D.ParameterAlt_key
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
And A.ParameterAlt_key In (7)
--------

UNION ALL


Select 
Convert(VARCHAR(20),@SystemDate,103) as ProcessDate
,A.EntityKey
,A.ParameterAlt_Key
					 ,A.ParameterName
					 ,A.ParameterValueAlt_Key
					 ,B.ParameterName as ParameterValue
					 ,A.ParameterNatureAlt_Key
					 ,C.ParameterName as NatureName
					 ,Convert(VARCHAR(20),A.From_Date,103) From_Date
					 ,Convert(VARCHAR(20),A.To_Date,103) To_Date
					 ,A.ParameterStatusAlt_Key
					 ,D.ParameterName as StatusName
					 ,isnull(AuthorisationStatus, 'A') AuthorisationStatus
					 ,EffectiveFromTimeKey
					 ,EffectiveToTimeKey 
					 ,CreatedBy
					 ,DateCreated
					 ,ApprovedBy
					 ,DateApproved 
					 ,ModifiedBy 
					 ,DateModified 
					 ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
 from SolutionGlobalParameter_Mod A
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'CumulativeDefineDays' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='CumulativeDefineDays' )B ON A.ParameterValueAlt_Key=B.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Nature' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Nature' )C ON A.ParameterNatureAlt_Key=C.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'ParameterStatus' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='ParameterStatus' )D ON A.ParameterStatusAlt_Key=D.ParameterAlt_key
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
And A.ParameterAlt_key In (8)
--------

UNION ALL

Select 
Convert(VARCHAR(20),@SystemDate,103) as ProcessDate
,A.EntityKey
,A.ParameterAlt_Key
					 ,A.ParameterName
					 ,A.ParameterValueAlt_Key
					 ,B.ParameterName as ParameterValue
					 ,A.ParameterNatureAlt_Key
					 ,C.ParameterName as NatureName
					 ,Convert(VARCHAR(20),A.From_Date,103) From_Date
					 ,Convert(VARCHAR(20),A.To_Date,103) To_Date
					 ,A.ParameterStatusAlt_Key
					 ,D.ParameterName as StatusName
					 ,isnull(AuthorisationStatus, 'A') AuthorisationStatus
					 ,EffectiveFromTimeKey
					 ,EffectiveToTimeKey 
					 ,CreatedBy
					 ,DateCreated
					 ,ApprovedBy
					 ,DateApproved 
					 ,ModifiedBy 
					 ,DateModified 
					 ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
 from SolutionGlobalParameter_Mod A
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'CumulativeDefineInterestServiced' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='CumulativeDefineInterestServiced' )B ON A.ParameterValueAlt_Key=B.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Nature' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Nature' )C ON A.ParameterNatureAlt_Key=C.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'ParameterStatus' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='ParameterStatus' )D ON A.ParameterStatusAlt_Key=D.ParameterAlt_key
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
And A.ParameterAlt_key In (9)
--------

UNION ALL

Select 
Convert(VARCHAR(20),@SystemDate,103) as ProcessDate
,A.EntityKey
,A.ParameterAlt_Key
					 ,A.ParameterName
					 ,A.ParameterValueAlt_Key
					 ,B.ParameterName as ParameterValue
					 ,A.ParameterNatureAlt_Key
					 ,C.ParameterName as NatureName
					 ,Convert(VARCHAR(20),A.From_Date,103) From_Date
					 ,Convert(VARCHAR(20),A.To_Date,103) To_Date
					 ,A.ParameterStatusAlt_Key
					 ,D.ParameterName as StatusName
					 ,isnull(AuthorisationStatus, 'A') AuthorisationStatus
					 ,EffectiveFromTimeKey
					 ,EffectiveToTimeKey 
					 ,CreatedBy
					 ,DateCreated
					 ,ApprovedBy
					 ,DateApproved 
					 ,ModifiedBy 
					 ,DateModified 
					 ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
 from SolutionGlobalParameter_Mod A
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'securityvalue' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='securityvalue' )B ON A.ParameterValueAlt_Key=B.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Nature' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Nature' )C ON A.ParameterNatureAlt_Key=C.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'ParameterStatus' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='ParameterStatus' )D ON A.ParameterStatusAlt_Key=D.ParameterAlt_key
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
And A.ParameterAlt_key In (19)
--------

UNION ALL

Select Convert(VARCHAR(20),@SystemDate,103) as ProcessDate
					 ,A.EntityKey
					 ,A.ParameterAlt_Key
					 ,A.ParameterName
					 ,A.ParameterValueAlt_Key
					 ,Convert(Varchar(20),A.ParameterValueAlt_Key) as ParameterValue
					 ,A.ParameterNatureAlt_Key
					 ,C.ParameterName as NatureName
					 ,Convert(VARCHAR(20),A.From_Date,103) From_Date
					 ,Convert(VARCHAR(20),A.To_Date,103) To_Date
					,A.ParameterStatusAlt_Key
					 ,D.ParameterName as StatusName
					 ,isnull(AuthorisationStatus, 'A') AuthorisationStatus
					 ,EffectiveFromTimeKey
					 ,EffectiveToTimeKey 
					 ,CreatedBy
					 ,DateCreated
					 ,ApprovedBy
					 ,DateApproved 
					 ,ModifiedBy 
					 ,DateModified 
					 ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
					from SolutionGlobalParameter_Mod A
				Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Nature' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Nature' )C ON A.ParameterNatureAlt_Key=C.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'ParameterStatus' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='ParameterStatus' )D ON A.ParameterStatusAlt_Key=D.ParameterAlt_key
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
And A.ParameterAlt_key In (16,17,18)---,20,21

UNION ALL


Select 
					Convert(VARCHAR(20),@SystemDate,103) as ProcessDate
					,A.EntityKey
					,A.ParameterAlt_Key
					 ,A.ParameterName
					 ,A.ParameterValueAlt_Key
					 ,B.ParameterName as ParameterValue
					 ,A.ParameterNatureAlt_Key
					 ,C.ParameterName as NatureName
					 ,Convert(VARCHAR(20),A.From_Date,103) From_Date
					 ,Convert(VARCHAR(20),A.To_Date,103) To_Date
					,A.ParameterStatusAlt_Key
					 ,D.ParameterName as StatusName
					 ,isnull(AuthorisationStatus, 'A') AuthorisationStatus
					 ,EffectiveFromTimeKey
					 ,EffectiveToTimeKey 
					 ,CreatedBy
					 ,DateCreated
					 ,ApprovedBy
					 ,DateApproved 
					 ,ModifiedBy 
					 ,DateModified 
					 ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
 from SolutionGlobalParameter_Mod A
 Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'securityvalue' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='securityvalue' )B ON A.ParameterValueAlt_Key=B.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Nature' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Nature' )C ON A.ParameterNatureAlt_Key=C.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'ParameterStatus' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='ParameterStatus' )D ON A.ParameterStatusAlt_Key=D.ParameterAlt_key
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
And A.ParameterAlt_key Not In (1,2,13,3,5,14,22,23,24,25,26,27,28,29,30,31,32,4,10,11,12,6,15,7,8,9,19,16,17,18,20,21)      
)B
where B.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM SolutionGlobalParameter_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')
                         GROUP BY ParameterAlt_Key
                     )
                 ) A 
                      
                 
                 GROUP BY   ProcessDate
							,A.EntityKey
							,A.ParameterAlt_Key
							,A.ParameterName
							,A.ParameterValueAlt_Key
							,A.ParameterValue
							,A.NatureName
							,A.ParameterNatureAlt_Key
							,A.From_Date
							,A.To_Date
							,A.StatusName
							,A.ParameterStatusAlt_Key
				 			,A.AuthorisationStatus 
                            ,A.EffectiveFromTimeKey
                            ,A.EffectiveToTimeKey
                            ,A.CreatedBy
                            ,A.DateCreated
                            ,A.ApprovedBy
                            ,A.DateApproved 
                            ,A.ModifiedBy
                            ,A.DateModified
							,A.CrModBy
							,A.CrModDate
							,A.CrAppBy
							,A.CrAppDate
							,A.ModAppBy
							,A.ModAppDate
						
                 --SELECT *
                 --FROM
                 --(
                 --    SELECT ROW_NUMBER() OVER(ORDER BY ParameterAlt_Key) AS RowNumber, 
                 --           COUNT(*) OVER() AS TotalCount, 
                 --           'SolutionGlobalParameterMaster' TableName, 
                 --           *
                 --    FROM
                 --    (
                 --        SELECT *
                 --        FROM SolutionGlobalParameter_Mod A
                 ----        --WHERE ISNULL(ArrangementDescription, '') LIKE '%'+@ArrangementDescription+'%'
							   
							   
                 --    ) AS DataPointOwner
                 --) AS DataPointOwner
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
                 --      AND RowNumber <= (@PageNo * @PageSize);
				 ) A 
             --END;

			  SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY ParameterAlt_Key) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'SolutionGlobalParameterMaster' TableName, 
                            *,
							
								(Case 
								When ParameterAlt_Key=3	THEN 1
								When ParameterAlt_Key=4	THEN 2
								When ParameterAlt_Key=5	THEN 3
								When ParameterAlt_Key=12	THEN 4
								When ParameterAlt_Key=6	THEN 5
								When ParameterAlt_Key=13	THEN 6
								When ParameterAlt_Key=7	THEN 7
								When ParameterAlt_Key=8	THEN 8
								When ParameterAlt_Key=9	THEN 9
								When ParameterAlt_Key=10	THEN 10
								When ParameterAlt_Key=14	THEN 11
								When ParameterAlt_Key=11	THEN 12
								When ParameterAlt_Key=16	THEN 13
								When ParameterAlt_Key=17	THEN 14
								When ParameterAlt_Key=18	THEN 15
								When ParameterAlt_Key=15	THEN 16
								When ParameterAlt_Key=22	THEN 17
								When ParameterAlt_Key=23	THEN 18
								When ParameterAlt_Key=24	THEN 19
								When ParameterAlt_Key=25	THEN 20
								When ParameterAlt_Key=32	THEN 21
								When ParameterAlt_Key=27	THEN 22
								When ParameterAlt_Key=28	THEN 23
								When ParameterAlt_Key=26	THEN 24
								When ParameterAlt_Key=29	THEN 25
								When ParameterAlt_Key=30	THEN 26
								When ParameterAlt_Key=19	THEN 27
								When ParameterAlt_Key=31	THEN 28
								When ParameterAlt_Key=1	THEN 29
								When ParameterAlt_Key=2	THEN 30
								END) AS Srno
                     FROM
                     (
                         SELECT *
                         FROM #temp A
                 --        --WHERE ISNULL(ArrangementDescription, '') LIKE '%'+@ArrangementDescription+'%'
							   
							   
                     ) AS DataPointOwner
                 ) AS DataPointOwner
				 --order by ParameterNatureAlt_Key desc,ParameterStatusAlt_Key asc,DateModified desc
				 Order by Srno
--             

			 END

			 ELSE
--			 /*  IT IS Used For GRID Search which are Pending for Authorization    */

						IF(@operationFlag in (16))
             BEGIN
			 IF OBJECT_ID('TempDB..#temp16') IS NOT NULL
                 DROP TABLE #temp16;
                 SELECT Convert(VARCHAR(20),@SystemDate,103) as ProcessDate
					,A.EntityKey
					 ,A.ParameterAlt_Key
					 ,A.ParameterName
					 ,A.ParameterValueAlt_Key
					 ,A.ParameterValue
					 ,A.ParameterNatureAlt_Key
					 ,A.NatureName
					 ,A.From_Date
					 ,A.To_Date
					 ,A.ParameterStatusAlt_Key
					 ,A.StatusName
					 ,isnull(AuthorisationStatus, 'A') AuthorisationStatus
					 ,EffectiveFromTimeKey
					 ,EffectiveToTimeKey 
					 ,CreatedBy
					 ,DateCreated
					 ,ApprovedBy
					 ,DateApproved 
					 ,ModifiedBy 
					 ,DateModified 
					 ,A.CrModBy
					 ,A.CrModDate
					 ,A.CrAppBy
					 ,A.CrAppDate
					 ,A.ModAppBy
					 ,A.ModAppDate

                 INTO #temp16
                 FROM 
                 (
                     

select * from
(
Select				Convert(VARCHAR(20),@SystemDate,103) as ProcessDate
					 ,A.EntityKey
					 ,A.ParameterAlt_Key
					 ,A.ParameterName
					 ,A.ParameterValueAlt_Key
					 ,B.ParameterName as ParameterValue
					 ,A.ParameterNatureAlt_Key
					 ,C.ParameterName as NatureName
					 ,Convert(VARCHAR(20),A.From_Date,103) From_Date
					 ,Convert(VARCHAR(20),A.To_Date,103) To_Date
					 ,A.ParameterStatusAlt_Key
					 ,D.ParameterName as StatusName
					 ,isnull(AuthorisationStatus, 'A') AuthorisationStatus
					 ,EffectiveFromTimeKey
					 ,EffectiveToTimeKey 
					 ,CreatedBy
					 ,DateCreated
					 ,ApprovedBy
					 ,DateApproved 
					 ,ModifiedBy 
					 ,DateModified
					 ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate 
 from SolutionGlobalParameter_Mod A
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Frequency' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Frequency' )B ON A.ParameterValueAlt_Key=B.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Nature' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Nature' )C ON A.ParameterNatureAlt_Key=C.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'ParameterStatus' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='ParameterStatus' )D ON A.ParameterStatusAlt_Key=D.ParameterAlt_key
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
And A.ParameterAlt_key In (1,2,13)
--------

UNION ALL

Select 
Convert(VARCHAR(20),@SystemDate,103) as ProcessDate
,A.EntityKey
,A.ParameterAlt_Key
					 ,A.ParameterName
					 ,A.ParameterValueAlt_Key
					 ,B.ParameterName as ParameterValue
					 ,A.ParameterNatureAlt_Key
					 ,C.ParameterName as NatureName
					 ,Convert(VARCHAR(20),A.From_Date,103) From_Date
					 ,Convert(VARCHAR(20),A.To_Date,103) To_Date
					 ,A.ParameterStatusAlt_Key
					 ,D.ParameterName as StatusName
					 ,isnull(AuthorisationStatus, 'A') AuthorisationStatus
					 ,EffectiveFromTimeKey
					 ,EffectiveToTimeKey 
					 ,CreatedBy
					 ,DateCreated
					 ,ApprovedBy
					 ,DateApproved 
					 ,ModifiedBy 
					 ,DateModified 
					 ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
 from SolutionGlobalParameter_Mod A
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Holidays' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Holidays' )B ON A.ParameterValueAlt_Key=B.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Nature' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Nature' )C ON A.ParameterNatureAlt_Key=C.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'ParameterStatus' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='ParameterStatus' )D ON A.ParameterStatusAlt_Key=D.ParameterAlt_key
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
And A.ParameterAlt_key In (3,5,14,22,23,24,25,26,27,28,29,30,31,32)
--------
UNION ALL
 

Select 
Convert(VARCHAR(20),@SystemDate,103) as ProcessDate
,A.EntityKey
,A.ParameterAlt_Key
					 ,A.ParameterName
					 ,A.ParameterValueAlt_Key
					 ,B.ParameterName as ParameterValue
					 ,A.ParameterNatureAlt_Key
					 ,C.ParameterName as NatureName
					 ,Convert(VARCHAR(20),A.From_Date,103) From_Date
					 ,Convert(VARCHAR(20),A.To_Date,103) To_Date
					 ,A.ParameterStatusAlt_Key
					 ,D.ParameterName as StatusName
					 ,isnull(AuthorisationStatus, 'A') AuthorisationStatus
					 ,EffectiveFromTimeKey
					 ,EffectiveToTimeKey 
					 ,CreatedBy
					 ,DateCreated
					 ,ApprovedBy
					 ,DateApproved 
					 ,ModifiedBy 
					 ,DateModified 
					 ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
 from SolutionGlobalParameter_Mod A
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'System' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='System' )B ON A.ParameterValueAlt_Key=B.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Nature' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Nature' )C ON A.ParameterNatureAlt_Key=C.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'ParameterStatus' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='ParameterStatus' )D ON A.ParameterStatusAlt_Key=D.ParameterAlt_key
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
And A.ParameterAlt_key In (4,10,11,12)
--------

UNION ALL


Select
Convert(VARCHAR(20),@SystemDate,103) as ProcessDate 
,A.EntityKey
,A.ParameterAlt_Key
					 ,A.ParameterName
					 ,A.ParameterValueAlt_Key
					 ,B.ParameterName as ParameterValue
					 ,A.ParameterNatureAlt_Key
					 ,C.ParameterName as NatureName
					 ,Convert(VARCHAR(20),A.From_Date,103) From_Date
					 ,Convert(VARCHAR(20),A.To_Date,103) To_Date
					 ,A.ParameterStatusAlt_Key
					 ,D.ParameterName as StatusName
					 ,isnull(AuthorisationStatus, 'A') AuthorisationStatus
					 ,EffectiveFromTimeKey
					 ,EffectiveToTimeKey 
					 ,CreatedBy
					 ,DateCreated
					 ,ApprovedBy
					 ,DateApproved 
					 ,ModifiedBy 
					 ,DateModified 
					 ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
 from SolutionGlobalParameter_Mod A
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Status' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Status' )B ON A.ParameterValueAlt_Key=B.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Nature' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Nature' )C ON A.ParameterNatureAlt_Key=C.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'ParameterStatus' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='ParameterStatus' )D ON A.ParameterStatusAlt_Key=D.ParameterAlt_key
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
And A.ParameterAlt_key In (6)
--------

UNION ALL

Select 
Convert(VARCHAR(20),@SystemDate,103) as ProcessDate
,A.EntityKey
,A.ParameterAlt_Key
					 ,A.ParameterName
					 ,A.ParameterValueAlt_Key
					 ,B.ParameterName as ParameterValue
					 ,A.ParameterNatureAlt_Key
					 ,C.ParameterName as NatureName
					 ,Convert(VARCHAR(20),A.From_Date,103) From_Date
					 ,Convert(VARCHAR(20),A.To_Date,103) To_Date
					 ,A.ParameterStatusAlt_Key
					 ,D.ParameterName as StatusName
					 ,isnull(AuthorisationStatus, 'A') AuthorisationStatus
					 ,EffectiveFromTimeKey
					 ,EffectiveToTimeKey 
					 ,CreatedBy
					 ,DateCreated
					 ,ApprovedBy
					 ,DateApproved 
					 ,ModifiedBy 
					 ,DateModified 
					 ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
 from SolutionGlobalParameter_Mod A
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Model' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Model' )B ON A.ParameterValueAlt_Key=B.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Nature' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Nature' )C ON A.ParameterNatureAlt_Key=C.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'ParameterStatus' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='ParameterStatus' )D ON A.ParameterStatusAlt_Key=D.ParameterAlt_key
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
And A.ParameterAlt_key In (15)
--------

UNION ALL

Select 
Convert(VARCHAR(20),@SystemDate,103) as ProcessDate
,A.EntityKey
,A.ParameterAlt_Key
					 ,A.ParameterName
					 ,A.ParameterValueAlt_Key
					 ,B.ParameterName as ParameterValue
					 ,A.ParameterNatureAlt_Key
					 ,C.ParameterName as NatureName
					 ,Convert(VARCHAR(20),A.From_Date,103) From_Date
					 ,Convert(VARCHAR(20),A.To_Date,103) To_Date
					 ,A.ParameterStatusAlt_Key
					 ,D.ParameterName as StatusName
					 ,isnull(AuthorisationStatus, 'A') AuthorisationStatus
					 ,EffectiveFromTimeKey
					 ,EffectiveToTimeKey 
					 ,CreatedBy
					 ,DateCreated
					 ,ApprovedBy
					 ,DateApproved 
					 ,ModifiedBy 
					 ,DateModified 
					 ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
 from SolutionGlobalParameter_Mod A
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'CumulativeDefinePeriod' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='CumulativeDefinePeriod' )B ON A.ParameterValueAlt_Key=B.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Nature' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Nature' )C ON A.ParameterNatureAlt_Key=C.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'ParameterStatus' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='ParameterStatus' )D ON A.ParameterStatusAlt_Key=D.ParameterAlt_key
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
And A.ParameterAlt_key In (7)
--------

UNION ALL


Select 
Convert(VARCHAR(20),@SystemDate,103) as ProcessDate
,A.EntityKey
,A.ParameterAlt_Key
					 ,A.ParameterName
					 ,A.ParameterValueAlt_Key
					 ,B.ParameterName as ParameterValue
					 ,A.ParameterNatureAlt_Key
					 ,C.ParameterName as NatureName
					 ,Convert(VARCHAR(20),A.From_Date,103) From_Date
					 ,Convert(VARCHAR(20),A.To_Date,103) To_Date
					 ,A.ParameterStatusAlt_Key
					 ,D.ParameterName as StatusName
					 ,isnull(AuthorisationStatus, 'A') AuthorisationStatus
					 ,EffectiveFromTimeKey
					 ,EffectiveToTimeKey 
					 ,CreatedBy
					 ,DateCreated
					 ,ApprovedBy
					 ,DateApproved 
					 ,ModifiedBy 
					 ,DateModified 
					 ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
 from SolutionGlobalParameter_Mod A
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'CumulativeDefineDays' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='CumulativeDefineDays' )B ON A.ParameterValueAlt_Key=B.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Nature' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Nature' )C ON A.ParameterNatureAlt_Key=C.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'ParameterStatus' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='ParameterStatus' )D ON A.ParameterStatusAlt_Key=D.ParameterAlt_key
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
And A.ParameterAlt_key In (8)
--------

UNION ALL

Select 
Convert(VARCHAR(20),@SystemDate,103) as ProcessDate
,A.EntityKey
,A.ParameterAlt_Key
					 ,A.ParameterName
					 ,A.ParameterValueAlt_Key
					 ,B.ParameterName as ParameterValue
					 ,A.ParameterNatureAlt_Key
					 ,C.ParameterName as NatureName
					 ,Convert(VARCHAR(20),A.From_Date,103) From_Date
					 ,Convert(VARCHAR(20),A.To_Date,103) To_Date
					 ,A.ParameterStatusAlt_Key
					 ,D.ParameterName as StatusName
					 ,isnull(AuthorisationStatus, 'A') AuthorisationStatus
					 ,EffectiveFromTimeKey
					 ,EffectiveToTimeKey 
					 ,CreatedBy
					 ,DateCreated
					 ,ApprovedBy
					 ,DateApproved 
					 ,ModifiedBy 
					 ,DateModified
					 ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate 
 from SolutionGlobalParameter_Mod A
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'CumulativeDefineInterestServiced' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='CumulativeDefineInterestServiced' )B ON A.ParameterValueAlt_Key=B.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Nature' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Nature' )C ON A.ParameterNatureAlt_Key=C.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'ParameterStatus' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='ParameterStatus' )D ON A.ParameterStatusAlt_Key=D.ParameterAlt_key
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
And A.ParameterAlt_key In (9)
--------

UNION ALL

Select 
Convert(VARCHAR(20),@SystemDate,103) as ProcessDate
,A.EntityKey
,A.ParameterAlt_Key
					 ,A.ParameterName
					 ,A.ParameterValueAlt_Key
					 ,B.ParameterName as ParameterValue
					 ,A.ParameterNatureAlt_Key
					 ,C.ParameterName as NatureName
					 ,Convert(VARCHAR(20),A.From_Date,103) From_Date
					 ,Convert(VARCHAR(20),A.To_Date,103) To_Date
					 ,A.ParameterStatusAlt_Key
					 ,D.ParameterName as StatusName
					 ,isnull(AuthorisationStatus, 'A') AuthorisationStatus
					 ,EffectiveFromTimeKey
					 ,EffectiveToTimeKey 
					 ,CreatedBy
					 ,DateCreated
					 ,ApprovedBy
					 ,DateApproved 
					 ,ModifiedBy 
					 ,DateModified 
					 ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
 from SolutionGlobalParameter_Mod A
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'securityvalue' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='securityvalue' )B ON A.ParameterValueAlt_Key=B.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Nature' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Nature' )C ON A.ParameterNatureAlt_Key=C.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'ParameterStatus' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='ParameterStatus' )D ON A.ParameterStatusAlt_Key=D.ParameterAlt_key
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
And A.ParameterAlt_key In (19)
--------

UNION ALL

Select 
					 Convert(VARCHAR(20),@SystemDate,103) as ProcessDate
					 ,A.EntityKey
					 ,A.ParameterAlt_Key
					 ,A.ParameterName
					 ,A.ParameterValueAlt_Key
					 ,Convert(Varchar(20),A.ParameterValueAlt_Key) as ParameterValue
					 ,A.ParameterNatureAlt_Key
					 ,C.ParameterName as NatureName
					 ,Convert(VARCHAR(20),A.From_Date,103) From_Date
					 ,Convert(VARCHAR(20),A.To_Date,103) To_Date
					,A.ParameterStatusAlt_Key
					 ,D.ParameterName as StatusName
					 ,isnull(AuthorisationStatus, 'A') AuthorisationStatus
					 ,EffectiveFromTimeKey
					 ,EffectiveToTimeKey 
					 ,CreatedBy
					 ,DateCreated
					 ,ApprovedBy
					 ,DateApproved 
					 ,ModifiedBy 
					 ,DateModified 
					 ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
					from SolutionGlobalParameter_Mod A
				Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Nature' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Nature' )C ON A.ParameterNatureAlt_Key=C.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'ParameterStatus' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='ParameterStatus' )D ON A.ParameterStatusAlt_Key=D.ParameterAlt_key
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
And A.ParameterAlt_key In (16,17,18)	---,20,21

UNION ALL


Select 
					Convert(VARCHAR(20),@SystemDate,103) as ProcessDate
					,A.EntityKey
					,A.ParameterAlt_Key
					 ,A.ParameterName
					 ,A.ParameterValueAlt_Key
					 ,B.ParameterName as ParameterValue
					 ,A.ParameterNatureAlt_Key
					 ,C.ParameterName as NatureName
					 ,Convert(VARCHAR(20),A.From_Date,103) From_Date
					 ,Convert(VARCHAR(20),A.To_Date,103) To_Date
					 ,A.ParameterStatusAlt_Key
					 ,D.ParameterName as StatusName
					 ,isnull(AuthorisationStatus, 'A') AuthorisationStatus
					 ,EffectiveFromTimeKey
					 ,EffectiveToTimeKey 
					 ,CreatedBy
					 ,DateCreated
					 ,ApprovedBy
					 ,DateApproved 
					 ,ModifiedBy 
					 ,DateModified 
					 ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
 from SolutionGlobalParameter_Mod A
 Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'securityvalue' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='securityvalue' )B ON A.ParameterValueAlt_Key=B.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Nature' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Nature' )C ON A.ParameterNatureAlt_Key=C.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'ParameterStatus' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='ParameterStatus' )D ON A.ParameterStatusAlt_Key=D.ParameterAlt_key
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
And A.ParameterAlt_key Not In (1,2,13,3,5,14,22,23,24,25,26,27,28,29,30,31,32,4,10,11,12,6,15,7,8,9,19,16,17,18,20,21)      
)B
where B.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM SolutionGlobalParameter_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')
                         GROUP BY ParameterAlt_Key
                     )
                 ) A 
                      
                 
                 GROUP BY   ProcessDate
							,A.EntityKey
							,A.ParameterAlt_Key
							,A.ParameterName
							,A.ParameterValueAlt_Key
							,A.ParameterValue
							,A.NatureName
							,A.ParameterNatureAlt_Key
							,A.From_Date
							,A.To_Date
							,A.StatusName
							,A.ParameterStatusAlt_Key
				 			,A.AuthorisationStatus 
                            ,A.EffectiveFromTimeKey
                            ,A.EffectiveToTimeKey
                            ,A.CreatedBy
                            ,A.DateCreated
                            ,A.ApprovedBy
                            ,A.DateApproved 
                            ,A.ModifiedBy
                            ,A.DateModified
							,A.CrModBy
							,A.CrModDate
							,A.CrAppBy
							,A.CrAppDate
							,A.ModAppBy
							,A.ModAppDate
						
                 --SELECT *
                 --FROM
                 --(
                 --    SELECT ROW_NUMBER() OVER(ORDER BY ParameterAlt_Key) AS RowNumber, 
                 --           COUNT(*) OVER() AS TotalCount, 
                 --           'SolutionGlobalParameterMaster' TableName, 
                 --           *
                 --    FROM
                 --    (
                 --        SELECT *
                 --        FROM SolutionGlobalParameter_Mod A
                 ----        --WHERE ISNULL(ArrangementDescription, '') LIKE '%'+@ArrangementDescription+'%'
							   
							   
                 --    ) AS DataPointOwner
                 --) AS DataPointOwner
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
                 --      AND RowNumber <= (@PageNo * @PageSize);
				 --) A
             

			  SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY ParameterAlt_Key) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'SolutionGlobalParameterMaster' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp16 A
                 --        --WHERE ISNULL(ArrangementDescription, '') LIKE '%'+@ArrangementDescription+'%'
							   
							   
                     ) AS DataPointOwner
                 ) AS DataPointOwner
				 order by ParameterNatureAlt_Key desc,ParameterStatusAlt_Key asc,DateModified desc

				 END;

	ELSE
--			 /*  IT IS Used For GRID Search which are Pending for Authorization    */

						IF(@operationFlag in (20))
             BEGIN
			 IF OBJECT_ID('TempDB..#temp20') IS NOT NULL
                 DROP TABLE #temp20;
                 SELECT Convert(VARCHAR(20),@SystemDate,103) as ProcessDate
					,A.EntityKey
					 ,A.ParameterAlt_Key
					 ,A.ParameterName
					 ,A.ParameterValueAlt_Key
					 ,A.ParameterValue
					 ,A.ParameterNatureAlt_Key
					 ,A.NatureName
					 ,A.From_Date
					 ,A.To_Date
					 ,A.ParameterStatusAlt_Key
					 ,A.StatusName
					 --,isnull(AuthorisationStatus, 'A') 
					 ,A.AuthorisationStatus
					 ,EffectiveFromTimeKey
					 ,EffectiveToTimeKey 
					 ,CreatedBy
					 ,DateCreated
					 ,ApprovedBy
					 ,DateApproved 
					 ,ModifiedBy 
					 ,DateModified 
					 ,A.CrModBy
					 ,A.CrModDate
					 ,A.CrAppBy
					 ,A.CrAppDate
					 ,A.ModAppBy
					 ,A.ModAppDate

                 INTO #temp20
                 FROM 
                 (
                     

select * from
(
Select				Convert(VARCHAR(20),@SystemDate,103) as ProcessDate
					 ,A.EntityKey
					 ,A.ParameterAlt_Key
					 ,A.ParameterName
					 ,A.ParameterValueAlt_Key
					 ,B.ParameterName as ParameterValue
					 ,A.ParameterNatureAlt_Key
					 ,C.ParameterName as NatureName
					 ,Convert(VARCHAR(20),A.From_Date,103) From_Date
					 ,Convert(VARCHAR(20),A.To_Date,103) To_Date
					 ,A.ParameterStatusAlt_Key
					 ,D.ParameterName as StatusName
					 --,isnull(AuthorisationStatus, 'A') 
					 ,A.AuthorisationStatus
					 ,EffectiveFromTimeKey
					 ,EffectiveToTimeKey 
					 ,CreatedBy
					 ,DateCreated
					 ,ApprovedBy
					 ,DateApproved 
					 ,ModifiedBy 
					 ,DateModified
					 ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate 
 from SolutionGlobalParameter_Mod A
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Frequency' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Frequency' )B ON A.ParameterValueAlt_Key=B.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Nature' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Nature' )C ON A.ParameterNatureAlt_Key=C.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'ParameterStatus' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='ParameterStatus' )D ON A.ParameterStatusAlt_Key=D.ParameterAlt_key
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
And A.ParameterAlt_key In (1,2,13)
--------

UNION ALL

Select 
Convert(VARCHAR(20),@SystemDate,103) as ProcessDate
,A.EntityKey
,A.ParameterAlt_Key
					 ,A.ParameterName
					 ,A.ParameterValueAlt_Key
					 ,B.ParameterName as ParameterValue
					 ,A.ParameterNatureAlt_Key
					 ,C.ParameterName as NatureName
					 ,Convert(VARCHAR(20),A.From_Date,103) From_Date
					 ,Convert(VARCHAR(20),A.To_Date,103) To_Date
					 ,A.ParameterStatusAlt_Key
					 ,D.ParameterName as StatusName
					 --,isnull(AuthorisationStatus, 'A') 
					 ,A.AuthorisationStatus
					 ,EffectiveFromTimeKey
					 ,EffectiveToTimeKey 
					 ,CreatedBy
					 ,DateCreated
					 ,ApprovedBy
					 ,DateApproved 
					 ,ModifiedBy 
					 ,DateModified 
					 ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
 from SolutionGlobalParameter_Mod A
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Holidays' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Holidays' )B ON A.ParameterValueAlt_Key=B.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Nature' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Nature' )C ON A.ParameterNatureAlt_Key=C.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'ParameterStatus' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='ParameterStatus' )D ON A.ParameterStatusAlt_Key=D.ParameterAlt_key
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
And A.ParameterAlt_key In (3,5,14,22,23,24,25,26,27,28,29,30,31,32)
--------
UNION ALL
 

Select 
Convert(VARCHAR(20),@SystemDate,103) as ProcessDate
,A.EntityKey
,A.ParameterAlt_Key
					 ,A.ParameterName
					 ,A.ParameterValueAlt_Key
					 ,B.ParameterName as ParameterValue
					 ,A.ParameterNatureAlt_Key
					 ,C.ParameterName as NatureName
					 ,Convert(VARCHAR(20),A.From_Date,103) From_Date
					 ,Convert(VARCHAR(20),A.To_Date,103) To_Date
					 ,A.ParameterStatusAlt_Key
					 ,D.ParameterName as StatusName
					 --,isnull(AuthorisationStatus, 'A') 
					 ,A.AuthorisationStatus
					 ,EffectiveFromTimeKey
					 ,EffectiveToTimeKey 
					 ,CreatedBy
					 ,DateCreated
					 ,ApprovedBy
					 ,DateApproved 
					 ,ModifiedBy 
					 ,DateModified 
					 ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
 from SolutionGlobalParameter_Mod A
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'System' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='System' )B ON A.ParameterValueAlt_Key=B.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Nature' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Nature' )C ON A.ParameterNatureAlt_Key=C.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'ParameterStatus' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='ParameterStatus' )D ON A.ParameterStatusAlt_Key=D.ParameterAlt_key
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
And A.ParameterAlt_key In (4,10,11,12)
--------

UNION ALL


Select
Convert(VARCHAR(20),@SystemDate,103) as ProcessDate 
,A.EntityKey
,A.ParameterAlt_Key
					 ,A.ParameterName
					 ,A.ParameterValueAlt_Key
					 ,B.ParameterName as ParameterValue
					 ,A.ParameterNatureAlt_Key
					 ,C.ParameterName as NatureName
					 ,Convert(VARCHAR(20),A.From_Date,103) From_Date
					 ,Convert(VARCHAR(20),A.To_Date,103) To_Date
					 ,A.ParameterStatusAlt_Key
					 ,D.ParameterName as StatusName
					 --,isnull(AuthorisationStatus, 'A') 
					 ,A.AuthorisationStatus
					 ,EffectiveFromTimeKey
					 ,EffectiveToTimeKey 
					 ,CreatedBy
					 ,DateCreated
					 ,ApprovedBy
					 ,DateApproved 
					 ,ModifiedBy 
					 ,DateModified 
					 ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
 from SolutionGlobalParameter_Mod A
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Status' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Status' )B ON A.ParameterValueAlt_Key=B.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Nature' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Nature' )C ON A.ParameterNatureAlt_Key=C.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'ParameterStatus' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='ParameterStatus' )D ON A.ParameterStatusAlt_Key=D.ParameterAlt_key
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
And A.ParameterAlt_key In (6)
--------

UNION ALL

Select 
Convert(VARCHAR(20),@SystemDate,103) as ProcessDate
,A.EntityKey
,A.ParameterAlt_Key
					 ,A.ParameterName
					 ,A.ParameterValueAlt_Key
					 ,B.ParameterName as ParameterValue
					 ,A.ParameterNatureAlt_Key
					 ,C.ParameterName as NatureName
					 ,Convert(VARCHAR(20),A.From_Date,103) From_Date
					 ,Convert(VARCHAR(20),A.To_Date,103) To_Date
					 ,A.ParameterStatusAlt_Key
					 ,D.ParameterName as StatusName
					 --,isnull(AuthorisationStatus, 'A') 
					 ,A.AuthorisationStatus
					 ,EffectiveFromTimeKey
					 ,EffectiveToTimeKey 
					 ,CreatedBy
					 ,DateCreated
					 ,ApprovedBy
					 ,DateApproved 
					 ,ModifiedBy 
					 ,DateModified 
					 ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
 from SolutionGlobalParameter_Mod A
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Model' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Model' )B ON A.ParameterValueAlt_Key=B.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Nature' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Nature' )C ON A.ParameterNatureAlt_Key=C.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'ParameterStatus' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='ParameterStatus' )D ON A.ParameterStatusAlt_Key=D.ParameterAlt_key
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
And A.ParameterAlt_key In (15)
--------

UNION ALL

Select 
Convert(VARCHAR(20),@SystemDate,103) as ProcessDate
,A.EntityKey
,A.ParameterAlt_Key
					 ,A.ParameterName
					 ,A.ParameterValueAlt_Key
					 ,B.ParameterName as ParameterValue
					 ,A.ParameterNatureAlt_Key
					 ,C.ParameterName as NatureName
					 ,Convert(VARCHAR(20),A.From_Date,103) From_Date
					 ,Convert(VARCHAR(20),A.To_Date,103) To_Date
					 ,A.ParameterStatusAlt_Key
					 ,D.ParameterName as StatusName
					 --,isnull(AuthorisationStatus, 'A') 
					 ,A.AuthorisationStatus
					 ,EffectiveFromTimeKey
					 ,EffectiveToTimeKey 
					 ,CreatedBy
					 ,DateCreated
					 ,ApprovedBy
					 ,DateApproved 
					 ,ModifiedBy 
					 ,DateModified 
					 ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
 from SolutionGlobalParameter_Mod A
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'CumulativeDefinePeriod' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='CumulativeDefinePeriod' )B ON A.ParameterValueAlt_Key=B.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Nature' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Nature' )C ON A.ParameterNatureAlt_Key=C.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'ParameterStatus' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='ParameterStatus' )D ON A.ParameterStatusAlt_Key=D.ParameterAlt_key
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
And A.ParameterAlt_key In (7)
--------

UNION ALL


Select 
Convert(VARCHAR(20),@SystemDate,103) as ProcessDate
,A.EntityKey
,A.ParameterAlt_Key
					 ,A.ParameterName
					 ,A.ParameterValueAlt_Key
					 ,B.ParameterName as ParameterValue
					 ,A.ParameterNatureAlt_Key
					 ,C.ParameterName as NatureName
					 ,Convert(VARCHAR(20),A.From_Date,103) From_Date
					 ,Convert(VARCHAR(20),A.To_Date,103) To_Date
					 ,A.ParameterStatusAlt_Key
					 ,D.ParameterName as StatusName
					 --,isnull(AuthorisationStatus, 'A') 
					 ,A.AuthorisationStatus
					 ,EffectiveFromTimeKey
					 ,EffectiveToTimeKey 
					 ,CreatedBy
					 ,DateCreated
					 ,ApprovedBy
					 ,DateApproved 
					 ,ModifiedBy 
					 ,DateModified 
					 ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
 from SolutionGlobalParameter_Mod A
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'CumulativeDefineDays' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='CumulativeDefineDays' )B ON A.ParameterValueAlt_Key=B.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Nature' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Nature' )C ON A.ParameterNatureAlt_Key=C.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'ParameterStatus' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='ParameterStatus' )D ON A.ParameterStatusAlt_Key=D.ParameterAlt_key
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
And A.ParameterAlt_key In (8)
--------

UNION ALL

Select 
Convert(VARCHAR(20),@SystemDate,103) as ProcessDate
,A.EntityKey
,A.ParameterAlt_Key
					 ,A.ParameterName
					 ,A.ParameterValueAlt_Key
					 ,B.ParameterName as ParameterValue
					 ,A.ParameterNatureAlt_Key
					 ,C.ParameterName as NatureName
					 ,Convert(VARCHAR(20),A.From_Date,103) From_Date
					 ,Convert(VARCHAR(20),A.To_Date,103) To_Date
					 ,A.ParameterStatusAlt_Key
					 ,D.ParameterName as StatusName
					 --,isnull(AuthorisationStatus, 'A') 
					 ,A.AuthorisationStatus
					 ,EffectiveFromTimeKey
					 ,EffectiveToTimeKey 
					 ,CreatedBy
					 ,DateCreated
					 ,ApprovedBy
					 ,DateApproved 
					 ,ModifiedBy 
					 ,DateModified
					 ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate 
 from SolutionGlobalParameter_Mod A
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'CumulativeDefineInterestServiced' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='CumulativeDefineInterestServiced' )B ON A.ParameterValueAlt_Key=B.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Nature' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Nature' )C ON A.ParameterNatureAlt_Key=C.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'ParameterStatus' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='ParameterStatus' )D ON A.ParameterStatusAlt_Key=D.ParameterAlt_key
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
And A.ParameterAlt_key In (9)
--------

UNION ALL

Select 
Convert(VARCHAR(20),@SystemDate,103) as ProcessDate
,A.EntityKey
,A.ParameterAlt_Key
					 ,A.ParameterName
					 ,A.ParameterValueAlt_Key
					 ,B.ParameterName as ParameterValue
					 ,A.ParameterNatureAlt_Key
					 ,C.ParameterName as NatureName
					 ,Convert(VARCHAR(20),A.From_Date,103) From_Date
					 ,Convert(VARCHAR(20),A.To_Date,103) To_Date
					 ,A.ParameterStatusAlt_Key
					 ,D.ParameterName as StatusName
					 --,isnull(AuthorisationStatus, 'A') 
					 ,A.AuthorisationStatus
					 ,EffectiveFromTimeKey
					 ,EffectiveToTimeKey 
					 ,CreatedBy
					 ,DateCreated
					 ,ApprovedBy
					 ,DateApproved 
					 ,ModifiedBy 
					 ,DateModified 
					 ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
 from SolutionGlobalParameter_Mod A
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'securityvalue' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='securityvalue' )B ON A.ParameterValueAlt_Key=B.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Nature' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Nature' )C ON A.ParameterNatureAlt_Key=C.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'ParameterStatus' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='ParameterStatus' )D ON A.ParameterStatusAlt_Key=D.ParameterAlt_key
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
And A.ParameterAlt_key In (19)
--------

UNION ALL

Select 
					 Convert(VARCHAR(20),@SystemDate,103) as ProcessDate
					 ,A.EntityKey
					 ,A.ParameterAlt_Key
					 ,A.ParameterName
					 ,A.ParameterValueAlt_Key
					 ,Convert(Varchar(20),A.ParameterValueAlt_Key) as ParameterValue
					 ,A.ParameterNatureAlt_Key
					 ,C.ParameterName as NatureName
					 ,Convert(VARCHAR(20),A.From_Date,103) From_Date
					 ,Convert(VARCHAR(20),A.To_Date,103) To_Date
					,A.ParameterStatusAlt_Key
					 ,D.ParameterName as StatusName
					 --,isnull(AuthorisationStatus, 'A') 
					 ,A.AuthorisationStatus
					 ,EffectiveFromTimeKey
					 ,EffectiveToTimeKey 
					 ,CreatedBy
					 ,DateCreated
					 ,ApprovedBy
					 ,DateApproved 
					 ,ModifiedBy 
					 ,DateModified 
					 ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
					from SolutionGlobalParameter_Mod A
				Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Nature' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Nature' )C ON A.ParameterNatureAlt_Key=C.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'ParameterStatus' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='ParameterStatus' )D ON A.ParameterStatusAlt_Key=D.ParameterAlt_key
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
AND ISNULL(A.AuthorisationStatus, 'A') = '1A'
And A.ParameterAlt_key In (16,17,18)	---,20,21

UNION ALL


Select 
					Convert(VARCHAR(20),@SystemDate,103) as ProcessDate
					,A.EntityKey
					,A.ParameterAlt_Key
					 ,A.ParameterName
					 ,A.ParameterValueAlt_Key
					 ,B.ParameterName as ParameterValue
					 ,A.ParameterNatureAlt_Key
					 ,C.ParameterName as NatureName
					 ,Convert(VARCHAR(20),A.From_Date,103) From_Date
					 ,Convert(VARCHAR(20),A.To_Date,103) To_Date
					 ,A.ParameterStatusAlt_Key
					 ,D.ParameterName as StatusName
					 --,isnull(AuthorisationStatus, 'A') 
					 ,A.AuthorisationStatus
					 ,EffectiveFromTimeKey
					 ,EffectiveToTimeKey 
					 ,CreatedBy
					 ,DateCreated
					 ,ApprovedBy
					 ,DateApproved 
					 ,ModifiedBy 
					 ,DateModified 
					 ,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
 from SolutionGlobalParameter_Mod A
 Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'securityvalue' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='securityvalue' )B ON A.ParameterValueAlt_Key=B.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Nature' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Nature' )C ON A.ParameterNatureAlt_Key=C.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'ParameterStatus' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='ParameterStatus' )D ON A.ParameterStatusAlt_Key=D.ParameterAlt_key
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
And A.ParameterAlt_key Not In (1,2,13,3,5,14,22,23,24,25,26,27,28,29,30,31,32,4,10,11,12,6,15,7,8,9,19,16,17,18,20,21)      
)B
where B.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM SolutionGlobalParameter_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('1A')
                         GROUP BY ParameterAlt_Key
                     )
                 ) A 
                      
                 
                 GROUP BY   ProcessDate
							,A.EntityKey
							,A.ParameterAlt_Key
							,A.ParameterName
							,A.ParameterValueAlt_Key
							,A.ParameterValue
							,A.NatureName
							,A.ParameterNatureAlt_Key
							,A.From_Date
							,A.To_Date
							,A.StatusName
							,A.ParameterStatusAlt_Key
				 			,A.AuthorisationStatus 
                            ,A.EffectiveFromTimeKey
                            ,A.EffectiveToTimeKey
                            ,A.CreatedBy
                            ,A.DateCreated
                            ,A.ApprovedBy
                            ,A.DateApproved 
                            ,A.ModifiedBy
                            ,A.DateModified
							,A.CrModBy
							,A.CrModDate
							,A.CrAppBy
							,A.CrAppDate
							,A.ModAppBy
							,A.ModAppDate
						
                 --SELECT *
                 --FROM
                 --(
                 --    SELECT ROW_NUMBER() OVER(ORDER BY ParameterAlt_Key) AS RowNumber, 
                 --           COUNT(*) OVER() AS TotalCount, 
                 --           'SolutionGlobalParameterMaster' TableName, 
                 --           *
                 --    FROM
                 --    (
                 --        SELECT *
                 --        FROM SolutionGlobalParameter_Mod A
                 ----        --WHERE ISNULL(ArrangementDescription, '') LIKE '%'+@ArrangementDescription+'%'
							   
							   
                 --    ) AS DataPointOwner
                 --) AS DataPointOwner
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
                 --      AND RowNumber <= (@PageNo * @PageSize);
				 --) A
             

			  SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY ParameterAlt_Key) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'SolutionGlobalParameterMaster' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp20 A
                 --        --WHERE ISNULL(ArrangementDescription, '') LIKE '%'+@ArrangementDescription+'%'
							   
							   
                     ) AS DataPointOwner
                 ) AS DataPointOwner
				 order by ParameterNatureAlt_Key desc,ParameterStatusAlt_Key asc,DateModified desc

				 END;

	END TRY
	BEGIN CATCH
	
	INSERT INTO dbo.Error_Log
				SELECT ERROR_LINE() as ErrorLine,ERROR_MESSAGE()ErrorMessage,ERROR_NUMBER()ErrorNumber
				,ERROR_PROCEDURE()ErrorProcedure,ERROR_SEVERITY()ErrorSeverity,ERROR_STATE()ErrorState
				,GETDATE()

	SELECT ERROR_MESSAGE()
	--RETURN -1
   
	END CATCH


     END;
GO