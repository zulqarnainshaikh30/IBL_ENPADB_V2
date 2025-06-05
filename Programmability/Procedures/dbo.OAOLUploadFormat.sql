SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[OAOLUploadFormat]
@MenuID INT
as 
begin

 
  select  ColumnName  from [DimUploadTempMaster] where MenuId=@MenuID  --,'TblUploadMaster' AS TableName
  order by EntityKey asc
 
  select top 1 SheetName,'TblUploadSheet' AS TableName from  [DimUploadTempMaster] where MenuId=@MenuID
 
  select * from SysSolutionParameter


end

GO