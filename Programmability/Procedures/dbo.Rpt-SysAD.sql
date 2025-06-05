SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



CREATE PROCedure [dbo].[Rpt-SysAD]  
@UserName AS varchar(max)  
 
AS  
DECLARE @Flag AS CHAR(5)

	SET @Flag = (SELECT dbo.ADflag() )
    
	IF @Flag='Y' 
	BEGIN
	
Declare @Select varchar(max)  
Declare @Select1 varchar(max)  
Declare @LDAP varchar(max)  
Declare @CN varchar(max)  
Declare @parameter varchar(max)  
Declare @parameter1 varchar(max)  
Declare @Str varchar(max)  
Declare @userlocationcode varchar(max)

set @Select='Select * from openquery(MISLVB,'  
set @Select1='''select Department from '  
set @LDAP='''''LDAP://192.168.1.1'''''  
set @CN='where sAMAccountName='  
set @parameter='''''' + @username + ''''''  
set @parameter1='''' + ')'  
  
set @Str=@Select+@Select1+@LDAP+@CN+@parameter+@parameter1  
set @userlocationcode=@Str
exec(@Str) 
END
ELSE IF @Flag<>'Y'
BEGIN
select NULL AS Department
END



GO