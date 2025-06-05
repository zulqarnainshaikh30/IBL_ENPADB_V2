SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO





CREATE PROCEDURE [dbo].[SysCrisMAcModuleMenu_mvc] --'addauth11' , 3652
@UserLoginID Varchar(20)='pwomake',
@TimeKey INT = 49999
AS
BEGIN
    Select @TimeKey=TimeKey from SysDayMatrix where Cast([Date] as date)=Cast(getdate() as date)
	Declare @DeptGrpCode int, @MenuID varchar(Max),@UserRoleAlt_Key SMALLINT, @PassWordChanged varchar(MAX)
	SET @PassWordChanged =  (Select PasswordChanged from DimUserInfo where UserLoginID = @UserLoginID AND EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey)
	PRINT 'A' 
	 (Select @DeptGrpCode= DeptGroupCode from DimUserInfo where UserLoginID = @UserLoginID AND EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey)
	PRINT @DeptGrpCode
	PRINT 'B'
	--SET @MenuID = (Select Menus from DimUserDeptGroup where DeptGroupId = @DeptGrpCode AND EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey)
	--Select Menus from DimUserDeptGroup where DeptGroupId = 7 --AND EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey
	Select @MenuID= Menus from DimUserDeptGroup where DeptGroupId = @DeptGrpCode AND EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey
	Print @MenuID
	PRINT 'C'
	SET @UserRoleAlt_Key = (Select UserRoleAlt_Key from DimUserInfo where UserLoginID = @UserLoginID AND EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey)
	PRINT @UserRoleAlt_Key
	--SET @UserRoleAlt_Key = 3
	PRINT 'D'

	IF (@PassWordChanged = 'Y')
	BEGIN
	Select  EntityKey, MenuTitleId,DataSeq, ISNULL(MenuId,0) MenuId ,ISNULL(ParentId,0) ParentId,MenuCaption, ISNULL(CAST(ActionName AS VARCHAR(MAX)),ReportUrl)  
	ActionName,Viewpath,ngController,
	BusFld,EnableMakerChecker,AuthLevel,NonAllowOperation,ISNULL(AccessLevel,'VIEWER')AccessLevel
		FROM SysCRisMacMenu M 
			LEFT JOIN SysReportDirectory R
				ON M.MenuId = R.ReportMenuId
		WHERE  visible=1  --and  MenuTitleId<>50 
		and MenuId IN
		(
			SELECT 	Split.a.value('.', 'VARCHAR(100)') AS MenuId  
			FROM  (
					SELECT CAST ('<M>' + REPLACE(@MenuID, ',', '</M><M>') + '</M>' AS XML) AS MenuId  
				  ) AS A CROSS APPLY MenuId.nodes ('/M') AS Split(a)   

		   UNION 

			SELECT ParentId AS MenuId   FROM SysCRisMacMenu WHERE  MenuId IN (SELECT 	Split.a.value('.', 'VARCHAR(100)') AS MenuId  
			FROM  (
					SELECT CAST ('<M>' + REPLACE(@MenuID, ',', '</M><M>') + '</M>' AS XML) AS MenuId  
				  ) AS A CROSS APPLY MenuId.nodes ('/M') AS Split(a)   )
		)
		AND (CASE WHEN @UserRoleAlt_Key = 1 AND M.MenuId<>0 THEN 1 
			  WHEN @UserRoleAlt_Key <> 1 AND M.MenuId NOT IN (105) THEN 1 END )= 1
			  --AND (CASE WHEN @UserRoleAlt_Key > 2 AND M.MenuId in (55,56,58,60,62,63,68) THEN 0 ELSE 1 
			  --END)= 1
		--AND ParentId = 0 
	--UNION
	--	SELECT  EntityKey, MenuTitleId,DataSeq, ISNULL(MenuId,0) MenuId ,ISNULL(ParentId,0) ParentId,
	--		MenuCaption,  ISNULL(CAST(ActionName AS VARCHAR(MAX)),ReportUrl)  
	--		ActionName,Viewpath,ngController,BusFld,EnableMakerChecker,
	--			NonAllowOperation,ISNULL(AccessLevel,'VIEWER')AccessLevel
	--	FROM SysCRisMacMenu M 
	--		LEFT JOIN SysReportDirectory R
	--		ON M.MenuId = R.ReportMenuId
	--	WHERE --DeptGroupCode='ALL' and 
	--	visible=1 --and  MenuTitleId<>50 
	--	--AND (CASE WHEN @UserRoleAlt_Key = 1 AND M.MenuId<>0 THEN 1 
	--	--		  WHEN @UserRoleAlt_Key <> 1 AND M.MenuId NOT IN (52,56,58,60,62,64,65,66,67,68,150,305) THEN 1 END )= 1
		
	ORDER BY MenuTitleID, DataSeq
	END
	ELSE 
	BEGIN
		Select EntityKey, MenuTitleId,DataSeq, ISNULL(MenuId,0) MenuId ,ISNULL(ParentId,0) ParentId,MenuCaption, ISNULL(CAST(ActionName AS VARCHAR(MAX)),ReportUrl)  
	ActionName,Viewpath,ngController,
	BusFld,EnableMakerChecker,AuthLevel,NonAllowOperation,ISNULL(AccessLevel,'VIEWER')AccessLevel
		FROM SysCRisMacMenu M 
			LEFT JOIN SysReportDirectory R
				ON M.MenuId = R.ReportMenuId
		WHERE MenuId=54
	END

END






GO