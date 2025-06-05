SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE proc [dbo].[Proj_SubCategory_PUI]
@ProjectId  INT
as

Declare @TimeKey as Int
SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')
--Declare @ProjectId int=1
select ProjectCategorySubTypeAltKey
,ProjectCategorySubTypeDescription
,'ProjectCategorySubType' TableName

 from ProjectCategorySubType PC
  where PC.EffectiveFromTimeKey<=@Timekey And PC.EffectiveToTimeKey>=@Timekey
  And ProjectCategoryTypeAltKey=@ProjectId
GO