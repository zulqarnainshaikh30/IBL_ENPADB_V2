SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE Proc  [dbo].[SolutionGlobalParameter_History]
--declare 
@ParameterAlt_Key int=5
as

Declare @TimeKey as Int
	SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')

select 
'SolutionGlobalHistory' AS TableName
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
					 ,A.CreatedBy	
					 ,Convert(VARCHAR(20),A.DateCreated,103) DateCreated	
					 ,A.ApprovedBy	
					 ,Convert(VARCHAR(20),A.DateApproved,103) DateApproved	
					 ,A.ModifiedBy	
					 ,Convert(VARCHAR(20),A.DateModified,103) DateModified

					-- from SolutionGlobalParameter A
					--  Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Frequency' TableName
					--                    from DimParameter Where DimParameterName='Frequency' )B 
					--                     ON A.ParameterValueAlt_Key=B.ParameterAlt_key
					--Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Nature' TableName
					--                     from DimParameter Where DimParameterName='Nature' )C 
					--                     ON A.ParameterNatureAlt_Key=C.ParameterAlt_key
					--Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'ParameterStatus' TableName
					--                     from DimParameter Where DimParameterName='ParameterStatus' )D 
					--                     ON A.ParameterStatusAlt_Key=D.ParameterAlt_key
					--Where 


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

And A.ParameterAlt_key In (1,2,13) AND A.ParameterAlt_Key=@ParameterAlt_Key

		UNION ALL
select 
'SolutionGlobalHistory' AS TableName
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
					 ,A.CreatedBy	
					 ,Convert(VARCHAR(20),A.DateCreated,103) DateCreated	
					 ,A.ApprovedBy	
					 ,Convert(VARCHAR(20),A.DateApproved,103) DateApproved	
					 ,A.ModifiedBy	
					 ,Convert(VARCHAR(20),A.DateModified,103) DateModified
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
--AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
And A.ParameterAlt_key In (3,5,14,22,23,24,25,26,27,28,29,30,31,32)
AND A.ParameterAlt_Key=@ParameterAlt_Key

union all
select 
'SolutionGlobalHistory' AS TableName
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
					 ,A.CreatedBy	
					 ,Convert(VARCHAR(20),A.DateCreated,103) DateCreated	
					 ,A.ApprovedBy	
					 ,Convert(VARCHAR(20),A.DateApproved,103) DateApproved	
					 ,A.ModifiedBy	
					 ,Convert(VARCHAR(20),A.DateModified,103) DateModified
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
--AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
And A.ParameterAlt_key In (4,10,11,12)
AND A.ParameterAlt_Key=@ParameterAlt_Key

UNION ALL
select 
'SolutionGlobalHistory' AS TableName
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
					 ,A.CreatedBy	
					 ,Convert(VARCHAR(20),A.DateCreated,103) DateCreated	
					 ,A.ApprovedBy	
					 ,Convert(VARCHAR(20),A.DateApproved,103) DateApproved	
					 ,A.ModifiedBy	
					 ,Convert(VARCHAR(20),A.DateModified,103) DateModified
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
--AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
And A.ParameterAlt_key In (6)
AND A.ParameterAlt_Key=@ParameterAlt_Key


UNION ALL
select 
'SolutionGlobalHistory' AS TableName
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
					 ,A.CreatedBy	
					 ,Convert(VARCHAR(20),A.DateCreated,103) DateCreated	
					 ,A.ApprovedBy	
					 ,Convert(VARCHAR(20),A.DateApproved,103) DateApproved	
					 ,A.ModifiedBy	
					 ,Convert(VARCHAR(20),A.DateModified,103) DateModified
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
--AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
And A.ParameterAlt_key In (15)
AND A.ParameterAlt_Key=@ParameterAlt_Key

UNION ALL

select 
'SolutionGlobalHistory' AS TableName
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
					 ,A.CreatedBy	
					 ,Convert(VARCHAR(20),A.DateCreated,103) DateCreated	
					 ,A.ApprovedBy	
					 ,Convert(VARCHAR(20),A.DateApproved,103) DateApproved	
					 ,A.ModifiedBy	
					 ,Convert(VARCHAR(20),A.DateModified,103) DateModified
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
--AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
And A.ParameterAlt_key In (7)
AND A.ParameterAlt_Key=@ParameterAlt_Key

UNION ALL

select 
'SolutionGlobalHistory' AS TableName
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
					 ,A.CreatedBy	
					 ,Convert(VARCHAR(20),A.DateCreated,103) DateCreated	
					 ,A.ApprovedBy	
					 ,Convert(VARCHAR(20),A.DateApproved,103) DateApproved	
					 ,A.ModifiedBy	
					 ,Convert(VARCHAR(20),A.DateModified,103) DateModified
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
--AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
And A.ParameterAlt_key In (8)
AND A.ParameterAlt_Key=@ParameterAlt_Key

UNION ALL

select 
'SolutionGlobalHistory' AS TableName
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
					 ,A.CreatedBy	
					 ,Convert(VARCHAR(20),A.DateCreated,103) DateCreated	
					 ,A.ApprovedBy	
					 ,Convert(VARCHAR(20),A.DateApproved,103) DateApproved	
					 ,A.ModifiedBy	
					 ,Convert(VARCHAR(20),A.DateModified,103) DateModified
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
--AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
And A.ParameterAlt_key In (9)
AND A.ParameterAlt_Key=@ParameterAlt_Key

UNION ALL

select 
'SolutionGlobalHistory' AS TableName
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
					 ,A.CreatedBy	
					 ,Convert(VARCHAR(20),A.DateCreated,103) DateCreated	
					 ,A.ApprovedBy	
					 ,Convert(VARCHAR(20),A.DateApproved,103) DateApproved	
					 ,A.ModifiedBy	
					 ,Convert(VARCHAR(20),A.DateModified,103) DateModified
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
--AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
And A.ParameterAlt_key In (19)
AND A.ParameterAlt_Key=@ParameterAlt_Key

UNION ALL


select 
'SolutionGlobalHistory' AS TableName
					 ,A.ParameterAlt_Key
					 ,A.ParameterName
					 ,A.ParameterValueAlt_Key
					 ,C.ParameterName as ParameterValue
					 ,A.ParameterNatureAlt_Key
					 ,C.ParameterName as NatureName
					 ,Convert(VARCHAR(20),A.From_Date,103) From_Date
					 ,Convert(VARCHAR(20),A.To_Date,103) To_Date
					 ,A.ParameterStatusAlt_Key
					 ,D.ParameterName as StatusName
					 ,A.CreatedBy	
					 ,Convert(VARCHAR(20),A.DateCreated,103) DateCreated	
					 ,A.ApprovedBy	
					 ,Convert(VARCHAR(20),A.DateApproved,103) DateApproved	
					 ,A.ModifiedBy	
					 ,Convert(VARCHAR(20),A.DateModified,103) DateModified
					from SolutionGlobalParameter A
				Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'Nature' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Nature' )C ON A.ParameterNatureAlt_Key=C.ParameterAlt_key
Inner join (Select Parameter_Key,ParameterAlt_Key,ParameterName,'ParameterStatus' TableName
		from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='ParameterStatus' )D ON A.ParameterStatusAlt_Key=D.ParameterAlt_key
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
--AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
And A.ParameterAlt_key In (16,17,18)  ----,20,21
AND A.ParameterAlt_Key=@ParameterAlt_Key



UNION ALL
select 
'SolutionGlobalHistory' AS TableName
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
					 ,A.CreatedBy	
					 ,Convert(VARCHAR(20),A.DateCreated,103) DateCreated	
					 ,A.ApprovedBy	
					 ,Convert(VARCHAR(20),A.DateApproved,103) DateApproved	
					 ,A.ModifiedBy	
					 ,Convert(VARCHAR(20),A.DateModified,103) DateModified
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
--AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
And A.ParameterAlt_key Not In (1,2,13,3,5,14,22,23,24,25,26,27,28,29,30,31,32,4,10,11,12,6,15,7,8,9,19,16,17,18,20,21)
AND A.ParameterAlt_Key=@ParameterAlt_Key
GO