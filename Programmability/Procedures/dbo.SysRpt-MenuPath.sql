SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROC [dbo].[SysRpt-MenuPath]
@ReportName Varchar(MAX),
@TimeKey INT

WITH RECOMPILE
AS 
BEGIN
DECLARE  @Menuid INT,@Parentid int,@Isfirstgrp char(1),@ThirdGroup CHAR(1)
SET @Menuid=(
             SELECT TOP(1)ReportMenuid 
			 FROM [dbo].[SysReportDirectory]
             WHERE ReportRdlFullName=@ReportName
             AND EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey
            )

SET @Parentid=(SELECT top (1)ParentId FROM SysCRisMacMenu WHERE MenuId=@Menuid AND Visible=1)

sELECT @Isfirstgrp='Y' FROM SysCRisMacMenu M
WHERE M.MenuId IS NULL AND M.ParentId IS NULL AND MenuTitleId=@Parentid AND Visible=1

sELECT @ThirdGroup=ThirdGroup FROM SysCRisMacMenu M
WHERE MenuId=@Menuid AND Visible=1

IF(ISNULL(@ThirdGroup,'')='Y' AND ISNULL(@Isfirstgrp,'')<>'Y')
BEGIN
SElect REPLACE('Menu Path: '+ISNULL(M.MenuCaption+' / ','')+ISNULL(Main.CAP,''),'&','') Path1 from  SysCRisMacMenu M
INNER JOIN(
SELECT F.ParentId,ISNULL(F.MenuCaption+' / ','')+ISNULL(SEC.SECCAP+' / ','')+ISNULL(SEC.THRIDCAP,'') CAP
FROM   SysCRisMacMenu F
INNER JOIN (
SELECT S.ParentId,S.MenuCaption SECCAP,THR.THRIDCAP
FROM   SysCRisMacMenu S
INNER JOIN (SELECT ParentId,MenuCaption THRIDCAP
				FROM   SysCRisMacMenu 
				WHERE Menuid=@Menuid AND Visible=1
				)	THR ON THR.ParentId=S.MenuId
				) SEC ON SEC.ParentId=F.MenuId
) Main on Main.ParentId=m.MenuTitleId
WHERE M.MenuId IS NULL AND M.ParentId IS NULL AND Visible=1
END
ELSE IF (ISNULL(@ThirdGroup,'')<>'Y' AND ISNULL(@Isfirstgrp,'')<>'Y')
BEGIN
SELECT REPLACE('Menu Path: '+ISNULL(M.MenuCaption+' / ','')+ISNULL(MAIN.CAP,''),'&','') Path1 FROM SysCRisMacMenu M
INNER JOIN(
SELECT S.ParentId,ISNULL(S.MenuCaption+' / ','')+ISNULL(THR.THRIDCAP,'') CAP
FROM (SELECT ParentId,MenuCaption THRIDCAP
				FROM   SysCRisMacMenu 
				WHERE Menuid=@Menuid AND Visible=1
				)	THR
left JOIN  SysCRisMacMenu S ON THR.ParentId=S.MenuId
) MAIN ON MAIN.ParentId=M.MenuTitleId
WHERE M.MenuId IS NULL AND M.ParentId IS NULL AND Visible=1
END

ELSE IF (ISNULL(@Isfirstgrp,'')='Y' AND ISNULL(@ThirdGroup,'')<>'Y')
BEGIN
SELECT REPLACE('Menu Path: '+ISNULL(S.MenuCaption+' / ','')+ISNULL(THR.THRIDCAP,''),'&','') Path1
FROM (SELECT ParentId,MenuCaption THRIDCAP
				FROM   SysCRisMacMenu 
				WHERE Menuid=@Menuid AND Visible=1
				)	THR
left JOIN  SysCRisMacMenu S ON THR.ParentId=S.MenuTitleId
                              AND S.MenuId IS NULL AND S.ParentId IS NULL AND Visible=1
END


END


GO