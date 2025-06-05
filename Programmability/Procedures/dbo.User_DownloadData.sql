SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[User_DownloadData]  
 @Timekey INT  
 ,@UserLoginId VARCHAR(100)  
 ,@ExcelUploadId INT  
 ,@UploadType VARCHAR(50)  
 --,@Page SMALLINT =1       
 --   ,@perPage INT = 30000     
AS  
  
----DECLARE @Timekey INT=49999  
---- ,@UserLoginId VARCHAR(100)='FNASUPERADMIN'  
---- ,@ExcelUploadId INT=4  
---- ,@UploadType VARCHAR(50)='Interest reversal'  
  
BEGIN  
  SET NOCOUNT ON;  
  
  Select @Timekey=Max(Timekey) from dbo.SysDayMatrix    
    where  Date=cast(getdate() as Date)  
        PRINT @Timekey    
  
  --DECLARE @PageFrom INT, @PageTo INT     
    
  --SET @PageFrom = (@perPage*@Page)-(@perPage) +1    
  --SET @PageTo = @perPage*@Page    
  
IF (@UploadType='User Upload')  
  
BEGIN  
    
  --SELECT * FROM(  
  SELECT 'Details' as TableName, 
 UploadID,
						UserLoginID,
						UserName,
						RoleDescription as UserRole,
						--UserRoleAlt_Key,
						C.DeptGroupCode as DepartmentName,
						MobileNo,
						Email_ID,
						Extension,
						IsChecker,
						IsChecker2,
						Activate,
						Designation,
						(CASE WHEN ISNULL(ActionAU,'') <> '' and ACTIONAU = 'A' THEN 'ADD' 
							 WHEN  ISNULL(ActionAU,'') <> '' and ACTIONAU = 'U' THEN 'UPDATE'
							 ELSE '' END)Action

   FROM DimUserInfo_Mod A 
   Left Join DimUserDeptGroup C On A.DeptGroupCode=C.DeptGroupId
   and C.EffectiveFromTimeKey<=@Timekey AND C.EffectiveToTimeKey>=@Timekey   
   LEFT JOIN DimUserRole D ON A.UserRoleAlt_Key = D.UserRoleAlt_Key
  WHERE UploadId=@ExcelUploadId  
  AND A.EffectiveFromTimeKey<=@Timekey AND A.EffectiveToTimeKey>=@Timekey    
  
  
    
  
 
  
    
  
   
  
END  
  
  
  
END  


GO