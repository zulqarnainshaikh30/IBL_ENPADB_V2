SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE Proc [dbo].[District_Dropdown]
--Declare 
@Timekey Int=26959
,@StateAlt_Key int=1

AS

--declare @Timekey int,@StateAlt_Key int  =10  --varchar(50)='BIHAR'
set @Timekey =(Select Timekey from sysdatamatrix where CurrentStatus='C')
select 
DistrictAlt_Key	
,DistrictName
,'DistrictNameList' as TableName
from DimGeography 
where EffectiveFromTimeKey<=@Timekey and 	EffectiveToTimeKey>=@Timekey 
--and StateAlt_Key =@StateAlt_Key
AND (                                             ----------------Added by kapil 01/01/2024
(@StateAlt_Key = 0 AND 1 = 1)  
            OR
            (StateAlt_Key = @StateAlt_Key)
			)                                 ----------------Added by kapil 01/01/2024
order by DistrictName
GO