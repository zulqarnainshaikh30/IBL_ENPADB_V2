SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE Proc [dbo].[State_Dropdown]
@Timekey Int
AS

--declare @Timekey int=25658
select 
StateAlt_Key	
,StateName,
'StateList' as TableName

from DimState  
where EffectiveFromTimeKey<=@Timekey and 	EffectiveToTimeKey>=@Timekey
order by StateName
GO