SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROC [dbo].[SelectSMAParameter]
--Declare
												@CustomerACID		 VARCHAR(16)
													--@PageNo         INT         = 1, 
													--@PageSize       INT         = 10, 
												--,@OperationFlag  INT         = 17

AS

	BEGIN

Declare @TimeKey as Int
	SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')

BEGIN TRY

	IF exists (select 1 from DimSMA where CUSTOMERACID=@CustomerACID and EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey and AuthorisationStatus<>'DP')

	BEGIN

Select * from
(
Select * from
(select 
D.SourceAlt_Key
,D.SourceName
,A.CustomerACID
,A.CustomerId
,A.CustomerName
,B.SMAParameterAlt_Key
,B.ParameterName 
,C.ParameterAlt_Key 
,C.ParameterName as Value
,'AccountDetails' TableName
,A.AuthorisationStatus
,A.CreatedBy
,A.DateCreated
,A.ModifiedBy
,A.DateModified
,A.ApprovedBy
,A.DateApproved
from DimSMA A
LEFT JOIN DIMSOURCEDB D
ON A.SourceAlt_Key=D.SourceAlt_Key
AND D.EffectiveFromTimeKey <= @TimeKey AND D.EffectiveToTimeKey >= @TimeKey
LEFT JOIN DimSMAParameter B
ON A.ParameterNameAlt_Key=B.SMAParameterAlt_Key
And B.SMAParameterAlt_Key In (1)
LEFT JOIN (Select Parameter_Key,ParameterAlt_Key,ParameterName,'value' TableName
from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
AND DimParameterName='Holidays' )C ON A.ValueAlt_Key=CAST(C.ParameterAlt_key as VARCHAR(100))
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
AND ISNULL(A.AuthorisationStatus, 'A') = 'A'


UNION ALL

select 
D.SourceAlt_Key
,D.SourceName
,A.CustomerACID
,A.CustomerId
,A.CustomerName
,B.SMAParameterAlt_Key
,B.ParameterName 
,C.ParameterAlt_Key 
,C.ParameterName as Value
,'AccountDetails' TableName
,A.AuthorisationStatus
,A.CreatedBy
,A.DateCreated
,A.ModifiedBy
,A.DateModified
,A.ApprovedBy
,A.DateApproved
from DimSMA A
LEFT JOIN DIMSOURCEDB D
ON A.SourceAlt_Key=D.SourceAlt_Key
AND D.EffectiveFromTimeKey <= @TimeKey AND D.EffectiveToTimeKey >= @TimeKey
LEFT JOIN DimSMAParameter B
ON A.ParameterNameAlt_Key=B.SMAParameterAlt_Key
And B.SMAParameterAlt_Key In (2)
LEFT JOIN (Select Parameter_Key,ParameterAlt_Key,ParameterName,'value1' TableName
from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
AND DimParameterName='Holidays' )C ON A.ValueAlt_Key=CAST(C.ParameterAlt_key as VARCHAR(100))
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
AND ISNULL(A.AuthorisationStatus, 'A') = 'A'


UNION ALL

select 
D.SourceAlt_Key
,D.SourceName
,A.CustomerACID
,A.CustomerId
,A.CustomerName
,B.SMAParameterAlt_Key
,B.ParameterName 
,C.ParameterAlt_Key 
,C.ParameterName as Value
,'AccountDetails' TableName
,A.AuthorisationStatus
,A.CreatedBy
,A.DateCreated
,A.ModifiedBy
,A.DateModified
,A.ApprovedBy
,A.DateApproved
from DimSMA A
LEFT JOIN DIMSOURCEDB D
ON A.SourceAlt_Key=D.SourceAlt_Key
AND D.EffectiveFromTimeKey <= @TimeKey AND D.EffectiveToTimeKey >= @TimeKey
LEFT JOIN DimSMAParameter B
ON A.ParameterNameAlt_Key=B.SMAParameterAlt_Key
And B.SMAParameterAlt_Key In (3)
LEFT JOIN (Select Parameter_Key,ParameterAlt_Key,ParameterName,'value2' TableName
from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
AND DimParameterName='Holidays' )C ON A.ValueAlt_Key=CAST(C.ParameterAlt_key as VARCHAR(100))
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
AND ISNULL(A.AuthorisationStatus, 'A') = 'A'


UNION ALL

select 
D.SourceAlt_Key
,D.SourceName
,A.CustomerACID
,A.CustomerId
,A.CustomerName
,B.SMAParameterAlt_Key
,B.ParameterName 
,C.ParameterAlt_Key 
,C.ParameterName as Value
,'AccountDetails' TableName
,A.AuthorisationStatus
,A.CreatedBy
,A.DateCreated
,A.ModifiedBy
,A.DateModified
,A.ApprovedBy
,A.DateApproved
from DimSMA A
LEFT JOIN DIMSOURCEDB D
ON A.SourceAlt_Key=D.SourceAlt_Key
AND D.EffectiveFromTimeKey <= @TimeKey AND D.EffectiveToTimeKey >= @TimeKey
LEFT JOIN DimSMAParameter B
ON A.ParameterNameAlt_Key=B.SMAParameterAlt_Key
And B.SMAParameterAlt_Key In (4)
LEFT JOIN (Select Parameter_Key,ParameterAlt_Key,ParameterName,'value3' TableName
from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
AND DimParameterName='Holidays' )C ON A.ValueAlt_Key=CAST(C.ParameterAlt_key as VARCHAR(100))
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
AND ISNULL(A.AuthorisationStatus, 'A') = 'A'


UNION ALL

select 
D.SourceAlt_Key
,D.SourceName
,A.CustomerACID
,A.CustomerId
,A.CustomerName
,B.SMAParameterAlt_Key
,B.ParameterName 
,C.ParameterAlt_Key 
,C.ParameterName as Value
,'AccountDetails' TableName
,A.AuthorisationStatus
,A.CreatedBy
,A.DateCreated
,A.ModifiedBy
,A.DateModified
,A.ApprovedBy
,A.DateApproved
from DimSMA A
LEFT JOIN DIMSOURCEDB D
ON A.SourceAlt_Key=D.SourceAlt_Key
AND D.EffectiveFromTimeKey <= @TimeKey AND D.EffectiveToTimeKey >= @TimeKey
LEFT JOIN DimSMAParameter B
ON A.ParameterNameAlt_Key=B.SMAParameterAlt_Key
And B.SMAParameterAlt_Key In (5)
LEFT JOIN (Select Parameter_Key,ParameterAlt_Key,ParameterName,'value4' TableName
from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
AND DimParameterName='Holidays' )C ON A.ValueAlt_Key=CAST(C.ParameterAlt_key as VARCHAR(100))
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
AND ISNULL(A.AuthorisationStatus, 'A') = 'A'


UNION ALL

select 
D.SourceAlt_Key
,D.SourceName
,A.CustomerACID
,A.CustomerId
,A.CustomerName
,B.SMAParameterAlt_Key
,B.ParameterName 
,C.ParameterAlt_Key 
,C.ParameterName as Value
,'AccountDetails' TableName
,A.AuthorisationStatus
,A.CreatedBy
,A.DateCreated
,A.ModifiedBy
,A.DateModified
,A.ApprovedBy
,A.DateApproved
from DimSMA A
LEFT JOIN DIMSOURCEDB D
ON A.SourceAlt_Key=D.SourceAlt_Key
AND D.EffectiveFromTimeKey <= @TimeKey AND D.EffectiveToTimeKey >= @TimeKey
LEFT JOIN DimSMAParameter B
ON A.ParameterNameAlt_Key=B.SMAParameterAlt_Key
And B.SMAParameterAlt_Key In (6)
LEFT JOIN (Select Parameter_Key,ParameterAlt_Key,ParameterName,'value5' TableName
from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
AND DimParameterName='Holidays' )C ON A.ValueAlt_Key=CAST(C.ParameterAlt_key as VARCHAR(100))
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
AND ISNULL(A.AuthorisationStatus, 'A') = 'A'


UNION ALL

select 
D.SourceAlt_Key
,D.SourceName
,A.CustomerACID
,A.CustomerId
,A.CustomerName
,B.SMAParameterAlt_Key
,B.ParameterName 
,C.ParameterAlt_Key 
,C.ParameterName as Value
,'AccountDetails' TableName
,A.AuthorisationStatus
,A.CreatedBy
,A.DateCreated
,A.ModifiedBy
,A.DateModified
,A.ApprovedBy
,A.DateApproved
from DimSMA A
LEFT JOIN DIMSOURCEDB D
ON A.SourceAlt_Key=D.SourceAlt_Key
AND D.EffectiveFromTimeKey <= @TimeKey AND D.EffectiveToTimeKey >= @TimeKey
LEFT JOIN DimSMAParameter B
ON A.ParameterNameAlt_Key=B.SMAParameterAlt_Key
And B.SMAParameterAlt_Key In (7)
LEFT JOIN (Select Parameter_Key,ParameterAlt_Key,ParameterName,'value6' TableName
from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
AND DimParameterName='Holidays' )C ON A.ValueAlt_Key=CAST(C.ParameterAlt_key as VARCHAR(100))
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
AND ISNULL(A.AuthorisationStatus, 'A') = 'A'


UNION ALL

select 
D.SourceAlt_Key
,D.SourceName
,A.CustomerACID
,A.CustomerId
,A.CustomerName
,B.SMAParameterAlt_Key
,B.ParameterName 
,C.ParameterAlt_Key 
,C.ParameterName as Value
,'AccountDetails' TableName
,A.AuthorisationStatus
,A.CreatedBy
,A.DateCreated
,A.ModifiedBy
,A.DateModified
,A.ApprovedBy
,A.DateApproved
from DimSMA A
LEFT JOIN DIMSOURCEDB D
ON A.SourceAlt_Key=D.SourceAlt_Key
AND D.EffectiveFromTimeKey <= @TimeKey AND D.EffectiveToTimeKey >= @TimeKey
LEFT JOIN DimSMAParameter B
ON A.ParameterNameAlt_Key=B.SMAParameterAlt_Key
And B.SMAParameterAlt_Key In (8)
LEFT JOIN (Select Parameter_Key,ParameterAlt_Key,ParameterName,'value7' TableName
from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
AND DimParameterName='Holidays' )C ON A.ValueAlt_Key=CAST(C.ParameterAlt_key as VARCHAR(100))
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
AND ISNULL(A.AuthorisationStatus, 'A') = 'A'


UNION ALL

select 
D.SourceAlt_Key
,D.SourceName
,A.CustomerACID
,A.CustomerId
,A.CustomerName
,B.SMAParameterAlt_Key
,B.ParameterName 
,C.ParameterAlt_Key 
,C.ParameterName as Value
,'AccountDetails' TableName
,A.AuthorisationStatus
,A.CreatedBy
,A.DateCreated
,A.ModifiedBy
,A.DateModified
,A.ApprovedBy
,A.DateApproved
from DimSMA A
LEFT JOIN DIMSOURCEDB D
ON A.SourceAlt_Key=D.SourceAlt_Key
AND D.EffectiveFromTimeKey <= @TimeKey AND D.EffectiveToTimeKey >= @TimeKey
LEFT JOIN DimSMAParameter B
ON A.ParameterNameAlt_Key=B.SMAParameterAlt_Key
And B.SMAParameterAlt_Key In (9)
LEFT JOIN (Select Parameter_Key,ParameterAlt_Key,ParameterName,'value8' TableName
from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
AND DimParameterName='Holidays' )C ON A.ValueAlt_Key=CAST(C.ParameterAlt_key as VARCHAR(100))
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
AND ISNULL(A.AuthorisationStatus, 'A') = 'A'

UNION ALL

select 
D.SourceAlt_Key
,D.SourceName
,A.CustomerACID
,A.CustomerId
,A.CustomerName
,B.SMAParameterAlt_Key
,B.ParameterName 
,C.ParameterAlt_Key 
,C.ParameterName as Value
,'AccountDetails' TableName
,A.AuthorisationStatus
,A.CreatedBy
,A.DateCreated
,A.ModifiedBy
,A.DateModified
,A.ApprovedBy
,A.DateApproved
from DimSMA A
LEFT JOIN DIMSOURCEDB D
ON A.SourceAlt_Key=D.SourceAlt_Key
AND D.EffectiveFromTimeKey <= @TimeKey AND D.EffectiveToTimeKey >= @TimeKey
LEFT JOIN DimSMAParameter B
ON A.ParameterNameAlt_Key=B.SMAParameterAlt_Key
And B.SMAParameterAlt_Key In (10)
LEFT JOIN (Select Parameter_Key,ParameterAlt_Key,ParameterName,'value9' TableName
from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
AND DimParameterName='Holidays' )C ON A.ValueAlt_Key=CAST(C.ParameterAlt_key as VARCHAR(100))
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
AND ISNULL(A.AuthorisationStatus, 'A') = 'A'


UNION ALL

select 
D.SourceAlt_Key
,D.SourceName
,A.CustomerACID
,A.CustomerId
,A.CustomerName
,B.SMAParameterAlt_Key
,B.ParameterName 
,C.ParameterAlt_Key 
,C.ParameterName as Value
,'AccountDetails' TableName
,A.AuthorisationStatus
,A.CreatedBy
,A.DateCreated
,A.ModifiedBy
,A.DateModified
,A.ApprovedBy
,A.DateApproved
from DimSMA A
LEFT JOIN DIMSOURCEDB D
ON A.SourceAlt_Key=D.SourceAlt_Key
AND D.EffectiveFromTimeKey <= @TimeKey AND D.EffectiveToTimeKey >= @TimeKey
LEFT JOIN DimSMAParameter B
ON A.ParameterNameAlt_Key=B.SMAParameterAlt_Key
And B.SMAParameterAlt_Key In (11)
LEFT JOIN (Select Parameter_Key,ParameterAlt_Key,ParameterName,'value10' TableName
from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
AND DimParameterName='Holidays' )C ON A.ValueAlt_Key=CAST(C.ParameterAlt_key as VARCHAR(100))
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
AND ISNULL(A.AuthorisationStatus, 'A') = 'A'


UNION ALL

select 
D.SourceAlt_Key
,D.SourceName
,A.CustomerACID
,A.CustomerId
,A.CustomerName
,B.SMAParameterAlt_Key
,B.ParameterName 
,C.ParameterAlt_Key 
,C.ParameterName as Value
,'AccountDetails' TableName
,A.AuthorisationStatus
,A.CreatedBy
,A.DateCreated
,A.ModifiedBy
,A.DateModified
,A.ApprovedBy
,A.DateApproved
from DimSMA A
LEFT JOIN DIMSOURCEDB D
ON A.SourceAlt_Key=D.SourceAlt_Key
AND D.EffectiveFromTimeKey <= @TimeKey AND D.EffectiveToTimeKey >= @TimeKey
LEFT JOIN DimSMAParameter B
ON A.ParameterNameAlt_Key=B.SMAParameterAlt_Key
And B.SMAParameterAlt_Key In (12)
LEFT JOIN (Select Parameter_Key,ParameterAlt_Key,ParameterName,'value11' TableName
from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
AND DimParameterName='Holidays' )C ON A.ValueAlt_Key=CAST(C.ParameterAlt_key as VARCHAR(100))
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
AND ISNULL(A.AuthorisationStatus, 'A') = 'A'


UNION ALL

select 
D.SourceAlt_Key
,D.SourceName
,A.CustomerACID
,A.CustomerId
,A.CustomerName
,B.SMAParameterAlt_Key
,B.ParameterName 
,C.ParameterAlt_Key 
,C.ParameterName as Value
,'AccountDetails' TableName
,A.AuthorisationStatus
,A.CreatedBy
,A.DateCreated
,A.ModifiedBy
,A.DateModified
,A.ApprovedBy
,A.DateApproved
from DimSMA A
LEFT JOIN DIMSOURCEDB D
ON A.SourceAlt_Key=D.SourceAlt_Key
AND D.EffectiveFromTimeKey <= @TimeKey AND D.EffectiveToTimeKey >= @TimeKey
LEFT JOIN DimSMAParameter B
ON A.ParameterNameAlt_Key=B.SMAParameterAlt_Key
And B.SMAParameterAlt_Key In (13)
LEFT JOIN (Select Parameter_Key,ParameterAlt_Key,ParameterName,'value12' TableName
from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
AND DimParameterName='Holidays' )C ON A.ValueAlt_Key=CAST(C.ParameterAlt_key as VARCHAR(100))
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
AND ISNULL(A.AuthorisationStatus, 'A') = 'A'


UNION ALL

select 
D.SourceAlt_Key
,D.SourceName
,A.CustomerACID
,A.CustomerId
,A.CustomerName
,B.SMAParameterAlt_Key
,B.ParameterName 
,C.ParameterAlt_Key 
,C.ParameterName as Value
,'AccountDetails' TableName
,A.AuthorisationStatus
,A.CreatedBy
,A.DateCreated
,A.ModifiedBy
,A.DateModified
,A.ApprovedBy
,A.DateApproved
from DimSMA A
LEFT JOIN DIMSOURCEDB D
ON A.SourceAlt_Key=D.SourceAlt_Key
AND D.EffectiveFromTimeKey <= @TimeKey AND D.EffectiveToTimeKey >= @TimeKey
LEFT JOIN DimSMAParameter B
ON A.ParameterNameAlt_Key=B.SMAParameterAlt_Key
And B.SMAParameterAlt_Key In (14)
LEFT JOIN (Select Parameter_Key,ParameterAlt_Key,ParameterName,'value13' TableName
from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
AND DimParameterName='Holidays' )C ON A.ValueAlt_Key=CAST(C.ParameterAlt_key as VARCHAR(100))
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
) A Where A.CustomerACID=@CustomerACID

UNION

Select * from
(
select 
D.SourceAlt_Key
,D.SourceName
,A.CustomerACID
,A.CustomerId
,A.CustomerName
,B.SMAParameterAlt_Key
,B.ParameterName 
,C.ParameterAlt_Key 
,C.ParameterName as Value
,'AccountDetails' TableName
,A.AuthorisationStatus
,A.CreatedBy
,A.DateCreated
,A.ModifiedBy
,A.DateModified
,A.ApprovedBy
,A.DateApproved
from DimSMA_Mod A
LEFT JOIN DIMSOURCEDB D
ON A.SourceAlt_Key=D.SourceAlt_Key
AND D.EffectiveFromTimeKey <= @TimeKey AND D.EffectiveToTimeKey >= @TimeKey
LEFT JOIN DimSMAParameter B
ON A.ParameterNameAlt_Key=B.SMAParameterAlt_Key
And B.SMAParameterAlt_Key In (1)
LEFT JOIN (Select Parameter_Key,ParameterAlt_Key,ParameterName,'value' TableName
from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
AND DimParameterName='Holidays' )C ON A.ValueAlt_Key=CAST(C.ParameterAlt_key as VARCHAR(100))
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
AND ISNULL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','1A')

UNION ALL

select 
D.SourceAlt_Key
,D.SourceName
,A.CustomerACID
,A.CustomerId
,A.CustomerName
,B.SMAParameterAlt_Key
,B.ParameterName 
,C.ParameterAlt_Key 
,C.ParameterName as Value
,'AccountDetails' TableName
,A.AuthorisationStatus
,A.CreatedBy
,A.DateCreated
,A.ModifiedBy
,A.DateModified
,A.ApprovedBy
,A.DateApproved
from DimSMA_Mod A
LEFT JOIN DIMSOURCEDB D
ON A.SourceAlt_Key=D.SourceAlt_Key
AND D.EffectiveFromTimeKey <= @TimeKey AND D.EffectiveToTimeKey >= @TimeKey
LEFT JOIN DimSMAParameter B
ON A.ParameterNameAlt_Key=B.SMAParameterAlt_Key
And B.SMAParameterAlt_Key In (2)
LEFT JOIN (Select Parameter_Key,ParameterAlt_Key,ParameterName,'value1' TableName
from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
AND DimParameterName='Holidays' )C ON A.ValueAlt_Key=CAST(C.ParameterAlt_key as VARCHAR(100))
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
AND ISNULL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','1A')

UNION ALL

select 
D.SourceAlt_Key
,D.SourceName
,A.CustomerACID
,A.CustomerId
,A.CustomerName
,B.SMAParameterAlt_Key
,B.ParameterName 
,C.ParameterAlt_Key 
,C.ParameterName as Value
,'AccountDetails' TableName
,A.AuthorisationStatus
,A.CreatedBy
,A.DateCreated
,A.ModifiedBy
,A.DateModified
,A.ApprovedBy
,A.DateApproved
from DimSMA_Mod A
LEFT JOIN DIMSOURCEDB D
ON A.SourceAlt_Key=D.SourceAlt_Key
AND D.EffectiveFromTimeKey <= @TimeKey AND D.EffectiveToTimeKey >= @TimeKey
LEFT JOIN DimSMAParameter B
ON A.ParameterNameAlt_Key=B.SMAParameterAlt_Key
And B.SMAParameterAlt_Key In (3)
LEFT JOIN (Select Parameter_Key,ParameterAlt_Key,ParameterName,'value2' TableName
from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
AND DimParameterName='Holidays' )C ON A.ValueAlt_Key=CAST(C.ParameterAlt_key as VARCHAR(100))
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
AND ISNULL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','1A')

UNION ALL

select 
D.SourceAlt_Key
,D.SourceName
,A.CustomerACID
,A.CustomerId
,A.CustomerName
,B.SMAParameterAlt_Key
,B.ParameterName 
,C.ParameterAlt_Key 
,C.ParameterName as Value
,'AccountDetails' TableName
,A.AuthorisationStatus
,A.CreatedBy
,A.DateCreated
,A.ModifiedBy
,A.DateModified
,A.ApprovedBy
,A.DateApproved
from DimSMA_Mod A
LEFT JOIN DIMSOURCEDB D
ON A.SourceAlt_Key=D.SourceAlt_Key
AND D.EffectiveFromTimeKey <= @TimeKey AND D.EffectiveToTimeKey >= @TimeKey
LEFT JOIN DimSMAParameter B
ON A.ParameterNameAlt_Key=B.SMAParameterAlt_Key
And B.SMAParameterAlt_Key In (4)
LEFT JOIN (Select Parameter_Key,ParameterAlt_Key,ParameterName,'value3' TableName
from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
AND DimParameterName='Holidays' )C ON A.ValueAlt_Key=CAST(C.ParameterAlt_key as VARCHAR(100))
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
AND ISNULL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','1A')

UNION ALL

select 
D.SourceAlt_Key
,D.SourceName
,A.CustomerACID
,A.CustomerId
,A.CustomerName
,B.SMAParameterAlt_Key
,B.ParameterName 
,C.ParameterAlt_Key 
,C.ParameterName as Value
,'AccountDetails' TableName
,A.AuthorisationStatus
,A.CreatedBy
,A.DateCreated
,A.ModifiedBy
,A.DateModified
,A.ApprovedBy
,A.DateApproved
from DimSMA_Mod A
LEFT JOIN DIMSOURCEDB D
ON A.SourceAlt_Key=D.SourceAlt_Key
AND D.EffectiveFromTimeKey <= @TimeKey AND D.EffectiveToTimeKey >= @TimeKey
LEFT JOIN DimSMAParameter B
ON A.ParameterNameAlt_Key=B.SMAParameterAlt_Key
And B.SMAParameterAlt_Key In (5)
LEFT JOIN (Select Parameter_Key,ParameterAlt_Key,ParameterName,'value4' TableName
from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
AND DimParameterName='Holidays' )C ON A.ValueAlt_Key=CAST(C.ParameterAlt_key as VARCHAR(100))
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
AND ISNULL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','1A')

UNION ALL

select 
D.SourceAlt_Key
,D.SourceName
,A.CustomerACID
,A.CustomerId
,A.CustomerName
,B.SMAParameterAlt_Key
,B.ParameterName 
,C.ParameterAlt_Key 
,C.ParameterName as Value
,'AccountDetails' TableName
,A.AuthorisationStatus
,A.CreatedBy
,A.DateCreated
,A.ModifiedBy
,A.DateModified
,A.ApprovedBy
,A.DateApproved
from DimSMA_Mod A
LEFT JOIN DIMSOURCEDB D
ON A.SourceAlt_Key=D.SourceAlt_Key
AND D.EffectiveFromTimeKey <= @TimeKey AND D.EffectiveToTimeKey >= @TimeKey
LEFT JOIN DimSMAParameter B
ON A.ParameterNameAlt_Key=B.SMAParameterAlt_Key
And B.SMAParameterAlt_Key In (6)
LEFT JOIN (Select Parameter_Key,ParameterAlt_Key,ParameterName,'value5' TableName
from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
AND DimParameterName='Holidays' )C ON A.ValueAlt_Key=CAST(C.ParameterAlt_key as VARCHAR(100))
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
AND ISNULL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','1A')

UNION ALL

select 
D.SourceAlt_Key
,D.SourceName
,A.CustomerACID
,A.CustomerId
,A.CustomerName
,B.SMAParameterAlt_Key
,B.ParameterName 
,C.ParameterAlt_Key 
,C.ParameterName as Value
,'AccountDetails' TableName
,A.AuthorisationStatus
,A.CreatedBy
,A.DateCreated
,A.ModifiedBy
,A.DateModified
,A.ApprovedBy
,A.DateApproved
from DimSMA_Mod A
LEFT JOIN DIMSOURCEDB D
ON A.SourceAlt_Key=D.SourceAlt_Key
AND D.EffectiveFromTimeKey <= @TimeKey AND D.EffectiveToTimeKey >= @TimeKey
LEFT JOIN DimSMAParameter B
ON A.ParameterNameAlt_Key=B.SMAParameterAlt_Key
And B.SMAParameterAlt_Key In (7)
LEFT JOIN (Select Parameter_Key,ParameterAlt_Key,ParameterName,'value6' TableName
from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
AND DimParameterName='Holidays' )C ON A.ValueAlt_Key=CAST(C.ParameterAlt_key as VARCHAR(100))
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
AND ISNULL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','1A')

UNION ALL

select 
D.SourceAlt_Key
,D.SourceName
,A.CustomerACID
,A.CustomerId
,A.CustomerName
,B.SMAParameterAlt_Key
,B.ParameterName 
,C.ParameterAlt_Key 
,C.ParameterName as Value
,'AccountDetails' TableName
,A.AuthorisationStatus
,A.CreatedBy
,A.DateCreated
,A.ModifiedBy
,A.DateModified
,A.ApprovedBy
,A.DateApproved
from DimSMA_Mod A
LEFT JOIN DIMSOURCEDB D
ON A.SourceAlt_Key=D.SourceAlt_Key
AND D.EffectiveFromTimeKey <= @TimeKey AND D.EffectiveToTimeKey >= @TimeKey
LEFT JOIN DimSMAParameter B
ON A.ParameterNameAlt_Key=B.SMAParameterAlt_Key
And B.SMAParameterAlt_Key In (8)
LEFT JOIN (Select Parameter_Key,ParameterAlt_Key,ParameterName,'value7' TableName
from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
AND DimParameterName='Holidays' )C ON A.ValueAlt_Key=CAST(C.ParameterAlt_key as VARCHAR(100))
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
AND ISNULL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','1A')

UNION ALL

select 
D.SourceAlt_Key
,D.SourceName
,A.CustomerACID
,A.CustomerId
,A.CustomerName
,B.SMAParameterAlt_Key
,B.ParameterName 
,C.ParameterAlt_Key 
,C.ParameterName as Value
,'AccountDetails' TableName
,A.AuthorisationStatus
,A.CreatedBy
,A.DateCreated
,A.ModifiedBy
,A.DateModified
,A.ApprovedBy
,A.DateApproved
from DimSMA_Mod A
LEFT JOIN DIMSOURCEDB D
ON A.SourceAlt_Key=D.SourceAlt_Key
AND D.EffectiveFromTimeKey <= @TimeKey AND D.EffectiveToTimeKey >= @TimeKey
LEFT JOIN DimSMAParameter B
ON A.ParameterNameAlt_Key=B.SMAParameterAlt_Key
And B.SMAParameterAlt_Key In (9)
LEFT JOIN (Select Parameter_Key,ParameterAlt_Key,ParameterName,'value8' TableName
from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
AND DimParameterName='Holidays' )C ON A.ValueAlt_Key=CAST(C.ParameterAlt_key as VARCHAR(100))
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
AND ISNULL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','1A')

UNION ALL

select 
D.SourceAlt_Key
,D.SourceName
,A.CustomerACID
,A.CustomerId
,A.CustomerName
,B.SMAParameterAlt_Key
,B.ParameterName 
,C.ParameterAlt_Key 
,C.ParameterName as Value
,'AccountDetails' TableName
,A.AuthorisationStatus
,A.CreatedBy
,A.DateCreated
,A.ModifiedBy
,A.DateModified
,A.ApprovedBy
,A.DateApproved
from DimSMA_Mod A
LEFT JOIN DIMSOURCEDB D
ON A.SourceAlt_Key=D.SourceAlt_Key
AND D.EffectiveFromTimeKey <= @TimeKey AND D.EffectiveToTimeKey >= @TimeKey
LEFT JOIN DimSMAParameter B
ON A.ParameterNameAlt_Key=B.SMAParameterAlt_Key
And B.SMAParameterAlt_Key In (10)
LEFT JOIN (Select Parameter_Key,ParameterAlt_Key,ParameterName,'value9' TableName
from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
AND DimParameterName='Holidays' )C ON A.ValueAlt_Key=CAST(C.ParameterAlt_key as VARCHAR(100))
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
AND ISNULL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','1A')

UNION ALL

select 
D.SourceAlt_Key
,D.SourceName
,A.CustomerACID
,A.CustomerId
,A.CustomerName
,B.SMAParameterAlt_Key
,B.ParameterName 
,C.ParameterAlt_Key 
,C.ParameterName as Value
,'AccountDetails' TableName
,A.AuthorisationStatus
,A.CreatedBy
,A.DateCreated
,A.ModifiedBy
,A.DateModified
,A.ApprovedBy
,A.DateApproved
from DimSMA_Mod A
LEFT JOIN DIMSOURCEDB D
ON A.SourceAlt_Key=D.SourceAlt_Key
AND D.EffectiveFromTimeKey <= @TimeKey AND D.EffectiveToTimeKey >= @TimeKey
LEFT JOIN DimSMAParameter B
ON A.ParameterNameAlt_Key=B.SMAParameterAlt_Key
And B.SMAParameterAlt_Key In (11)
LEFT JOIN (Select Parameter_Key,ParameterAlt_Key,ParameterName,'value10' TableName
from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
AND DimParameterName='Holidays' )C ON A.ValueAlt_Key=CAST(C.ParameterAlt_key as VARCHAR(100))
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
AND ISNULL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','1A')

UNION ALL

select 
D.SourceAlt_Key
,D.SourceName
,A.CustomerACID
,A.CustomerId
,A.CustomerName
,B.SMAParameterAlt_Key
,B.ParameterName 
,C.ParameterAlt_Key 
,C.ParameterName as Value
,'AccountDetails' TableName
,A.AuthorisationStatus
,A.CreatedBy
,A.DateCreated
,A.ModifiedBy
,A.DateModified
,A.ApprovedBy
,A.DateApproved
from DimSMA_Mod A
LEFT JOIN DIMSOURCEDB D
ON A.SourceAlt_Key=D.SourceAlt_Key
AND D.EffectiveFromTimeKey <= @TimeKey AND D.EffectiveToTimeKey >= @TimeKey
LEFT JOIN DimSMAParameter B
ON A.ParameterNameAlt_Key=B.SMAParameterAlt_Key
And B.SMAParameterAlt_Key In (12)
LEFT JOIN (Select Parameter_Key,ParameterAlt_Key,ParameterName,'value11' TableName
from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
AND DimParameterName='Holidays' )C ON A.ValueAlt_Key=CAST(C.ParameterAlt_key as VARCHAR(100))
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
AND ISNULL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','1A')

UNION ALL
select 
D.SourceAlt_Key
,D.SourceName
,A.CustomerACID
,A.CustomerId
,A.CustomerName
,B.SMAParameterAlt_Key
,B.ParameterName 
,C.ParameterAlt_Key 
,C.ParameterName as Value
,'AccountDetails' TableName
,A.AuthorisationStatus
,A.CreatedBy
,A.DateCreated
,A.ModifiedBy
,A.DateModified
,A.ApprovedBy
,A.DateApproved
from DimSMA_Mod A
LEFT JOIN DIMSOURCEDB D
ON A.SourceAlt_Key=D.SourceAlt_Key
AND D.EffectiveFromTimeKey <= @TimeKey AND D.EffectiveToTimeKey >= @TimeKey
LEFT JOIN DimSMAParameter B
ON A.ParameterNameAlt_Key=B.SMAParameterAlt_Key
And B.SMAParameterAlt_Key In (13)
LEFT JOIN (Select Parameter_Key,ParameterAlt_Key,ParameterName,'value12' TableName
from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
AND DimParameterName='Holidays' )C ON A.ValueAlt_Key=CAST(C.ParameterAlt_key as VARCHAR(100))
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
AND ISNULL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','1A')

UNION ALL
select 
D.SourceAlt_Key
,D.SourceName
,A.CustomerACID
,A.CustomerId
,A.CustomerName
,B.SMAParameterAlt_Key
,B.ParameterName 
,C.ParameterAlt_Key 
,C.ParameterName as Value
,'AccountDetails' TableName
,A.AuthorisationStatus
,A.CreatedBy
,A.DateCreated
,A.ModifiedBy
,A.DateModified
,A.ApprovedBy
,A.DateApproved
from DimSMA_Mod A
LEFT JOIN DIMSOURCEDB D
ON A.SourceAlt_Key=D.SourceAlt_Key
AND D.EffectiveFromTimeKey <= @TimeKey AND D.EffectiveToTimeKey >= @TimeKey
LEFT JOIN DimSMAParameter B
ON A.ParameterNameAlt_Key=B.SMAParameterAlt_Key
And B.SMAParameterAlt_Key In (14)
LEFT JOIN (Select Parameter_Key,ParameterAlt_Key,ParameterName,'value13' TableName
from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
AND DimParameterName='Holidays' )C ON A.ValueAlt_Key=CAST(C.ParameterAlt_key as VARCHAR(100))
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
AND ISNULL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','1A')
)B where B.CustomerACID=@CustomerACID

)C Where C.SMAParameterAlt_Key is not null
order by len(AuthorisationStatus) desc, DateCreated desc
END;
ELSE



---------

--	IF (@OperationFlag in (16,17))

BEGIN


Select * from
(
select 
D.SourceAlt_Key
,D.SourceName
,A.CustomerACID
,A.CustomerId
,A.CustomerName
,B.SMAParameterAlt_Key
,B.ParameterName 
,C.ParameterAlt_Key 
,C.ParameterName as Value
,'AccountDetails' TableName
,A.AuthorisationStatus
,A.CreatedBy
,A.DateCreated
,A.ModifiedBy
,A.DateModified
,A.ApprovedBy
,A.DateApproved
from DimSMA_Mod A
LEFT JOIN DIMSOURCEDB D
ON A.SourceAlt_Key=D.SourceAlt_Key
AND D.EffectiveFromTimeKey <= @TimeKey AND D.EffectiveToTimeKey >= @TimeKey
LEFT JOIN DimSMAParameter B
ON A.ParameterNameAlt_Key=B.SMAParameterAlt_Key
And B.SMAParameterAlt_Key In (1)
LEFT JOIN (Select Parameter_Key,ParameterAlt_Key,ParameterName,'value' TableName
from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
AND DimParameterName='Holidays' )C ON A.ValueAlt_Key=CAST(C.ParameterAlt_key as VARCHAR(100))
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
AND ISNULL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','1A')



UNION ALL

select 
D.SourceAlt_Key
,D.SourceName
,A.CustomerACID
,A.CustomerId
,A.CustomerName
,B.SMAParameterAlt_Key
,B.ParameterName 
,C.ParameterAlt_Key 
,C.ParameterName as Value
,'AccountDetails' TableName
,A.AuthorisationStatus
,A.CreatedBy
,A.DateCreated
,A.ModifiedBy
,A.DateModified
,A.ApprovedBy
,A.DateApproved
from DimSMA_Mod A
LEFT JOIN DIMSOURCEDB D
ON A.SourceAlt_Key=D.SourceAlt_Key
AND D.EffectiveFromTimeKey <= @TimeKey AND D.EffectiveToTimeKey >= @TimeKey
LEFT JOIN DimSMAParameter B
ON A.ParameterNameAlt_Key=B.SMAParameterAlt_Key
And B.SMAParameterAlt_Key In (2)
LEFT JOIN (Select Parameter_Key,ParameterAlt_Key,ParameterName,'value1' TableName
from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
AND DimParameterName='Holidays' )C ON A.ValueAlt_Key=CAST(C.ParameterAlt_key as VARCHAR(100))
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
AND ISNULL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','1A')



UNION ALL

select 
D.SourceAlt_Key
,D.SourceName
,A.CustomerACID
,A.CustomerId
,A.CustomerName
,B.SMAParameterAlt_Key
,B.ParameterName 
,C.ParameterAlt_Key 
,C.ParameterName as Value
,'AccountDetails' TableName
,A.AuthorisationStatus
,A.CreatedBy
,A.DateCreated
,A.ModifiedBy
,A.DateModified
,A.ApprovedBy
,A.DateApproved
from DimSMA_Mod A
LEFT JOIN DIMSOURCEDB D
ON A.SourceAlt_Key=D.SourceAlt_Key
AND D.EffectiveFromTimeKey <= @TimeKey AND D.EffectiveToTimeKey >= @TimeKey
LEFT JOIN DimSMAParameter B
ON A.ParameterNameAlt_Key=B.SMAParameterAlt_Key
And B.SMAParameterAlt_Key In (3)
LEFT JOIN (Select Parameter_Key,ParameterAlt_Key,ParameterName,'value2' TableName
from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
AND DimParameterName='Holidays' )C ON A.ValueAlt_Key=CAST(C.ParameterAlt_key as VARCHAR(100))
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
AND ISNULL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','1A')



UNION ALL

select 
D.SourceAlt_Key
,D.SourceName
,A.CustomerACID
,A.CustomerId
,A.CustomerName
,B.SMAParameterAlt_Key
,B.ParameterName 
,C.ParameterAlt_Key 
,C.ParameterName as Value
,'AccountDetails' TableName
,A.AuthorisationStatus
,A.CreatedBy
,A.DateCreated
,A.ModifiedBy
,A.DateModified
,A.ApprovedBy
,A.DateApproved
from DimSMA_Mod A
LEFT JOIN DIMSOURCEDB D
ON A.SourceAlt_Key=D.SourceAlt_Key
AND D.EffectiveFromTimeKey <= @TimeKey AND D.EffectiveToTimeKey >= @TimeKey
LEFT JOIN DimSMAParameter B
ON A.ParameterNameAlt_Key=B.SMAParameterAlt_Key
And B.SMAParameterAlt_Key In (4)
LEFT JOIN (Select Parameter_Key,ParameterAlt_Key,ParameterName,'value3' TableName
from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
AND DimParameterName='Holidays' )C ON A.ValueAlt_Key=CAST(C.ParameterAlt_key as VARCHAR(100))
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
AND ISNULL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','1A')



UNION ALL

select 
D.SourceAlt_Key
,D.SourceName
,A.CustomerACID
,A.CustomerId
,A.CustomerName
,B.SMAParameterAlt_Key
,B.ParameterName 
,C.ParameterAlt_Key 
,C.ParameterName as Value
,'AccountDetails' TableName
,A.AuthorisationStatus
,A.CreatedBy
,A.DateCreated
,A.ModifiedBy
,A.DateModified
,A.ApprovedBy
,A.DateApproved
from DimSMA_Mod A
LEFT JOIN DIMSOURCEDB D
ON A.SourceAlt_Key=D.SourceAlt_Key
AND D.EffectiveFromTimeKey <= @TimeKey AND D.EffectiveToTimeKey >= @TimeKey
LEFT JOIN DimSMAParameter B
ON A.ParameterNameAlt_Key=B.SMAParameterAlt_Key
And B.SMAParameterAlt_Key In (5)
LEFT JOIN (Select Parameter_Key,ParameterAlt_Key,ParameterName,'value4' TableName
from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
AND DimParameterName='Holidays' )C ON A.ValueAlt_Key=CAST(C.ParameterAlt_key as VARCHAR(100))
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
AND ISNULL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','1A')



UNION ALL

select 
D.SourceAlt_Key
,D.SourceName
,A.CustomerACID
,A.CustomerId
,A.CustomerName
,B.SMAParameterAlt_Key
,B.ParameterName 
,C.ParameterAlt_Key 
,C.ParameterName as Value
,'AccountDetails' TableName
,A.AuthorisationStatus
,A.CreatedBy
,A.DateCreated
,A.ModifiedBy
,A.DateModified
,A.ApprovedBy
,A.DateApproved
from DimSMA_Mod A
LEFT JOIN DIMSOURCEDB D
ON A.SourceAlt_Key=D.SourceAlt_Key
AND D.EffectiveFromTimeKey <= @TimeKey AND D.EffectiveToTimeKey >= @TimeKey
LEFT JOIN DimSMAParameter B
ON A.ParameterNameAlt_Key=B.SMAParameterAlt_Key
And B.SMAParameterAlt_Key In (6)
LEFT JOIN (Select Parameter_Key,ParameterAlt_Key,ParameterName,'value5' TableName
from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
AND DimParameterName='Holidays' )C ON A.ValueAlt_Key=CAST(C.ParameterAlt_key as VARCHAR(100))
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
AND ISNULL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','1A')



UNION ALL

select 
D.SourceAlt_Key
,D.SourceName
,A.CustomerACID
,A.CustomerId
,A.CustomerName
,B.SMAParameterAlt_Key
,B.ParameterName 
,C.ParameterAlt_Key 
,C.ParameterName as Value
,'AccountDetails' TableName
,A.AuthorisationStatus
,A.CreatedBy
,A.DateCreated
,A.ModifiedBy
,A.DateModified
,A.ApprovedBy
,A.DateApproved
from DimSMA_Mod A
LEFT JOIN DIMSOURCEDB D
ON A.SourceAlt_Key=D.SourceAlt_Key
AND D.EffectiveFromTimeKey <= @TimeKey AND D.EffectiveToTimeKey >= @TimeKey
LEFT JOIN DimSMAParameter B
ON A.ParameterNameAlt_Key=B.SMAParameterAlt_Key
And B.SMAParameterAlt_Key In (7)
LEFT JOIN (Select Parameter_Key,ParameterAlt_Key,ParameterName,'value6' TableName
from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
AND DimParameterName='Holidays' )C ON A.ValueAlt_Key=CAST(C.ParameterAlt_key as VARCHAR(100))
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
AND ISNULL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','1A')



UNION ALL

select 
D.SourceAlt_Key
,D.SourceName
,A.CustomerACID
,A.CustomerId
,A.CustomerName
,B.SMAParameterAlt_Key
,B.ParameterName 
,C.ParameterAlt_Key 
,C.ParameterName as Value
,'AccountDetails' TableName
,A.AuthorisationStatus
,A.CreatedBy
,A.DateCreated
,A.ModifiedBy
,A.DateModified
,A.ApprovedBy
,A.DateApproved
from DimSMA_Mod A
LEFT JOIN DIMSOURCEDB D
ON A.SourceAlt_Key=D.SourceAlt_Key
AND D.EffectiveFromTimeKey <= @TimeKey AND D.EffectiveToTimeKey >= @TimeKey
LEFT JOIN DimSMAParameter B
ON A.ParameterNameAlt_Key=B.SMAParameterAlt_Key
And B.SMAParameterAlt_Key In (8)
LEFT JOIN (Select Parameter_Key,ParameterAlt_Key,ParameterName,'value7' TableName
from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
AND DimParameterName='Holidays' )C ON A.ValueAlt_Key=CAST(C.ParameterAlt_key as VARCHAR(100))
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
AND ISNULL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','1A')



UNION ALL

select 
D.SourceAlt_Key
,D.SourceName
,A.CustomerACID
,A.CustomerId
,A.CustomerName
,B.SMAParameterAlt_Key
,B.ParameterName 
,C.ParameterAlt_Key 
,C.ParameterName as Value
,'AccountDetails' TableName
,A.AuthorisationStatus
,A.CreatedBy
,A.DateCreated
,A.ModifiedBy
,A.DateModified
,A.ApprovedBy
,A.DateApproved
from DimSMA_Mod A
LEFT JOIN DIMSOURCEDB D
ON A.SourceAlt_Key=D.SourceAlt_Key
AND D.EffectiveFromTimeKey <= @TimeKey AND D.EffectiveToTimeKey >= @TimeKey
LEFT JOIN DimSMAParameter B
ON A.ParameterNameAlt_Key=B.SMAParameterAlt_Key
And B.SMAParameterAlt_Key In (9)
LEFT JOIN (Select Parameter_Key,ParameterAlt_Key,ParameterName,'value8' TableName
from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
AND DimParameterName='Holidays' )C ON A.ValueAlt_Key=CAST(C.ParameterAlt_key as VARCHAR(100))
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
AND ISNULL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','1A')


UNION ALL

select 
D.SourceAlt_Key
,D.SourceName
,A.CustomerACID
,A.CustomerId
,A.CustomerName
,B.SMAParameterAlt_Key
,B.ParameterName 
,C.ParameterAlt_Key 
,C.ParameterName as Value
,'AccountDetails' TableName
,A.AuthorisationStatus
,A.CreatedBy
,A.DateCreated
,A.ModifiedBy
,A.DateModified
,A.ApprovedBy
,A.DateApproved
from DimSMA_Mod A
LEFT JOIN DIMSOURCEDB D
ON A.SourceAlt_Key=D.SourceAlt_Key
AND D.EffectiveFromTimeKey <= @TimeKey AND D.EffectiveToTimeKey >= @TimeKey
LEFT JOIN DimSMAParameter B
ON A.ParameterNameAlt_Key=B.SMAParameterAlt_Key
And B.SMAParameterAlt_Key In (10)
LEFT JOIN (Select Parameter_Key,ParameterAlt_Key,ParameterName,'value9' TableName
from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
AND DimParameterName='Holidays' )C ON A.ValueAlt_Key=CAST(C.ParameterAlt_key as VARCHAR(100))
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
AND ISNULL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','1A')


UNION ALL

select 
D.SourceAlt_Key
,D.SourceName
,A.CustomerACID
,A.CustomerId
,A.CustomerName
,B.SMAParameterAlt_Key
,B.ParameterName 
,C.ParameterAlt_Key 
,C.ParameterName as Value
,'AccountDetails' TableName
,A.AuthorisationStatus
,A.CreatedBy
,A.DateCreated
,A.ModifiedBy
,A.DateModified
,A.ApprovedBy
,A.DateApproved
from DimSMA_Mod A
LEFT JOIN DIMSOURCEDB D
ON A.SourceAlt_Key=D.SourceAlt_Key
AND D.EffectiveFromTimeKey <= @TimeKey AND D.EffectiveToTimeKey >= @TimeKey
LEFT JOIN DimSMAParameter B
ON A.ParameterNameAlt_Key=B.SMAParameterAlt_Key
And B.SMAParameterAlt_Key In (11)
LEFT JOIN (Select Parameter_Key,ParameterAlt_Key,ParameterName,'value10' TableName
from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
AND DimParameterName='Holidays' )C ON A.ValueAlt_Key=CAST(C.ParameterAlt_key as VARCHAR(100))
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
AND ISNULL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','1A')


UNION ALL

select 
D.SourceAlt_Key
,D.SourceName
,A.CustomerACID
,A.CustomerId
,A.CustomerName
,B.SMAParameterAlt_Key
,B.ParameterName 
,C.ParameterAlt_Key 
,C.ParameterName as Value
,'AccountDetails' TableName
,A.AuthorisationStatus
,A.CreatedBy
,A.DateCreated
,A.ModifiedBy
,A.DateModified
,A.ApprovedBy
,A.DateApproved
from DimSMA_Mod A
LEFT JOIN DIMSOURCEDB D
ON A.SourceAlt_Key=D.SourceAlt_Key
AND D.EffectiveFromTimeKey <= @TimeKey AND D.EffectiveToTimeKey >= @TimeKey
LEFT JOIN DimSMAParameter B
ON A.ParameterNameAlt_Key=B.SMAParameterAlt_Key
And B.SMAParameterAlt_Key In (12)
LEFT JOIN (Select Parameter_Key,ParameterAlt_Key,ParameterName,'value11' TableName
from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
AND DimParameterName='Holidays' )C ON A.ValueAlt_Key=CAST(C.ParameterAlt_key as VARCHAR(100))
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
AND ISNULL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','1A')



UNION ALL
select 
D.SourceAlt_Key
,D.SourceName
,A.CustomerACID
,A.CustomerId
,A.CustomerName
,B.SMAParameterAlt_Key
,B.ParameterName 
,C.ParameterAlt_Key 
,C.ParameterName as Value
,'AccountDetails' TableName
,A.AuthorisationStatus
,A.CreatedBy
,A.DateCreated
,A.ModifiedBy
,A.DateModified
,A.ApprovedBy
,A.DateApproved
from DimSMA_Mod A
LEFT JOIN DIMSOURCEDB D
ON A.SourceAlt_Key=D.SourceAlt_Key
AND D.EffectiveFromTimeKey <= @TimeKey AND D.EffectiveToTimeKey >= @TimeKey
LEFT JOIN DimSMAParameter B
ON A.ParameterNameAlt_Key=B.SMAParameterAlt_Key
And B.SMAParameterAlt_Key In (13)
LEFT JOIN (Select Parameter_Key,ParameterAlt_Key,ParameterName,'value12' TableName
from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
AND DimParameterName='Holidays' )C ON A.ValueAlt_Key=CAST(C.ParameterAlt_key as VARCHAR(100))
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
AND ISNULL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','1A')


UNION ALL


select 
D.SourceAlt_Key
,D.SourceName
,A.CustomerACID
,A.CustomerId
,A.CustomerName
,B.SMAParameterAlt_Key
,B.ParameterName 
,C.ParameterAlt_Key 
,C.ParameterName as Value
,'AccountDetails' TableName
,A.AuthorisationStatus
,A.CreatedBy
,A.DateCreated
,A.ModifiedBy
,A.DateModified
,A.ApprovedBy
,A.DateApproved
from DimSMA_Mod A
LEFT JOIN DIMSOURCEDB D
ON A.SourceAlt_Key=D.SourceAlt_Key
AND D.EffectiveFromTimeKey <= @TimeKey AND D.EffectiveToTimeKey >= @TimeKey
LEFT JOIN DimSMAParameter B
ON A.ParameterNameAlt_Key=B.SMAParameterAlt_Key
And B.SMAParameterAlt_Key In (14)
LEFT JOIN (Select Parameter_Key,ParameterAlt_Key,ParameterName,'value13' TableName
from DimParameter Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
AND DimParameterName='Holidays' )C ON A.ValueAlt_Key=CAST(C.ParameterAlt_key as VARCHAR(100))
Where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
AND ISNULL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','1A')


)A where A.CustomerACID=@CustomerACID
order by len(AuthorisationStatus) desc, DateCreated desc

END

END TRY


BEGIN CATCH

INSERT INTO dbo.Error_Log
			SELECT ERROR_LINE() as ErrorLine,ERROR_MESSAGE()ErrorMessage,ERROR_NUMBER()ErrorNumber
			,ERROR_PROCEDURE()ErrorProcedure,ERROR_SEVERITY()ErrorSeverity,ERROR_STATE()ErrorState
			,GETDATE()

SELECT ERROR_MESSAGE()
--RETURN -1
   
END CATCH


END
GO