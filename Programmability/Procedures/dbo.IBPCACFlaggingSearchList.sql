SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROC [dbo].[IBPCACFlaggingSearchList]


													    @OperationFlag  INT         = 1
														,@MenuID  INT
														,@AccountID varchar(50)   =''
AS
     
	 BEGIN

	 SET NOCOUNT ON;
     Declare @TimeKey as Int


	SET @Timekey=(select CAST(B.timekey as int)from SysDataMatrix A
			Inner Join SysDayMatrix B ON A.TimeKey=B.TimeKey
			 where A.CurrentStatus='C')










Select  A.SourceAlt_Key,
        Ds.SourceName,
		AccountID,
		A.CustomerID,
		A.CustomerName,
		A.AccountBalance,
		A.FlagAlt_Key,
		A.PoolID,
        A.PoolName,
        A.PoolType,
		A.POS,
		InterestReceivable,
		ExposureAmount,
	    Case when isnull(A.MaturityDate,'')='' then Null else convert(Varchar(10),MaturityDate,103) ENd MaturityDate
	   ,Case when isnull(A.IBPCMarkingDate,'')='' then Null else convert(Varchar(10),IBPCMarkingDate,103) ENd IBPCMarkingDate
	   , A.MaturityDate IPBCOutDate
	   ,'IBPCACFlaggingDetail' TableName


from IBPCFinalPoolDetail A Inner join DIMSOURCEDB ds on ds.SourceAlt_Key=A.SourceAlt_Key 
                        Where  A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           AND ISNULL(A.AuthorisationStatus,'A') ='A'
						   And AccountID=Case When isnull(@AccountID,'')='' then AccountID Else @AccountID END


						     select *,'IBPCAccountFlagging' AS tableName from MetaScreenFieldDetail where ScreenName='IBPCAccountFlagging' 
END




GO