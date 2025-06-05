SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- [Cust_grid_PUI] '1714222715864042'
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE proc [dbo].[Cust_grid_PUI]
@AccountID Varchar(50)
as
Declare @Timekey Int
set @Timekey=(select Timekey from SysDataMatrix where CurrentStatus='C')

--SET @Timekey=25999
select
CustomerID
,UCIFID
,AccountID	
,CustomerName	
,ProjectCategoryAlt_Key	
,PC.ProjectCategoryDescription
,ProjectSubCategoryAlt_key
,PCS.ProjectCategorySubTypeDescription	
,ProjectOwnerShipAlt_Key
,PM.ParameterName  ProjectOwnerShipDescription
,ProjectAuthorityAlt_key
,DM.ParameterName   ProjectAuthorityDescription	
,convert(varchar(10),OriginalDCCO,103) OriginalDCCO
,OriginalProjectCost	
,OriginalDebt
,ProjectSubCatDescription 
,'UpdatePUI' TableName

   from AdvAcPUIDetailMain PUI

 inner join ProjectCategory PC            on PC.ProjectCategoryAltKey=PUI.ProjectCategoryAlt_Key
                                         and PUI.EffectiveFromTimeKey<=@Timekey and PUI.EffectiveToTimeKey>=@Timekey
										 and PC.EffectiveFromTimeKey<=@Timekey and PC.EffectiveToTimeKey>=@Timekey
  LEFT join ProjectCategorySubType PCS   on PCS.ProjectCategorySubTypeAltKey=PUI.ProjectSubCategoryAlt_key
                                             AND PC.ProjectCategoryAltKey=PCS.ProjectCategoryTypeAltKey
											 and PCS.EffectiveFromTimeKey<=@Timekey and PCS.EffectiveToTimeKey>=@Timekey

 LEFT join DimParameter DM                   on DM.ParameterAlt_Key=PUI.ProjectAuthorityAlt_key
                                             --AND PC.ProjectCategoryAltKey=PCS.ProjectCategoryTypeAltKey
											 and DM.EffectiveFromTimeKey<=@Timekey and DM.EffectiveToTimeKey>=@Timekey
											 AND DM.dimparametername='ProjectAuthority'

 LEFT join DimParameter PM                   on PM.ParameterAlt_Key=PUI.ProjectOwnerShipAlt_Key
                                             --AND PC.ProjectCategoryAltKey=PCS.ProjectCategoryTypeAltKey
											 and PM.EffectiveFromTimeKey<=@Timekey and PM.EffectiveToTimeKey>=@Timekey
											 AND PM.dimparametername='ProjectOwnership'


   where PUI.AccountID=@AccountID

  
GO