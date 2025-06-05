SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO






CREATE PROCEDURE [dbo].[LastLoginBranchSelectUpdate] 
    @BranchCode		VARCHAR(20),
    @Type			VARCHAR(10),
	@userLoginId	VARCHAR(20)
AS
BEGIN
		DECLARE @Maxkey INT ,
		 @TimeKeyCurrent INT
			SET @TimeKeyCurrent = (select TimeKey from sysdaymatrix where date=convert(date,getdate(),103))
		IF	@Type = 'Login'
		BEGIN
			
			SELECT @Maxkey= MAX(EntityKey) FROM UserLoginHistory WHERE UserID =@userLoginId and BranchCode is not null

			SELECT BranchCode FROM UserLoginHistory WHERE EntityKey = @Maxkey

		END
		ELSE IF @Type = 'Logout'
		BEGIN
			
			SELECT @Maxkey= MAX(EntityKey) FROM UserLoginHistory WHERE UserID =@userLoginId
			
			UPDATE UserLoginHistory SET BranchCode = @BranchCode WHERE EntityKey = @Maxkey

			SELECT BranchCode FROM UserLoginHistory WHERE EntityKey = @Maxkey

				
			Update DimUserInfo Set UserLogged=0 where (EffectiveFromTimeKey<=@TimeKeyCurrent AND EffectiveToTimeKey>=@TimeKeyCurrent)
			AND UserLoginID=@userLoginId

		END

		ELSE IF @Type = 'SessionEnd'  
  BEGIN  
     
  IF(OBJECT_ID('tempdb..#TempUserTable') IS NOT NULL)  
  BEGIN  
   DROP TABLE #TempUserTable  
  END  
    
  CREATE TABLE #TempUserTable(UserId VARCHAR(MAX))  
  INSERT INTO #TempUserTable  SELECT Split.a.value('.', 'VARCHAR(100)') AS UserId  
  FROM  (SELECT CAST ('<M>' + REPLACE(@userLoginId, ',', '</M><M>') + '</M>' AS XML) AS UserId)  
  AS A CROSS APPLY UserId.nodes ('/M') AS Split(a)   
    
  
  --SET @TimeKey_Current = (select TimeKey from sysdaymatrix where date=convert(date,getdate(),103))  
    
  Update DimUserInfo Set UserLogged=0   
  where (EffectiveFromTimeKey<=@TimeKeyCurrent AND EffectiveToTimeKey>=@TimeKeyCurrent)  
  AND UserLoginID in  ( SELECT UserId FROM #TempUserTable WHERE UserId IS NOT NULL and UserId <> '')  
  
  --Update DimUserInfo Set UserLogged=0   
  --where (EffectiveFromTimeKey<=@TimeKey_Current AND EffectiveToTimeKey>=@TimeKey_Current)  
  --AND UserLoginID in  ( select value from  string_split  (@userLoginId,@CommaSeperate))  
  
  END  
END



















GO