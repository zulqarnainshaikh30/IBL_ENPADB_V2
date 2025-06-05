SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROC [dbo].[SMACustomerIDName]

--Declare
 
		 @ACCID VARCHAR(30)='ABCD1234'
		,@Flag  INT =1

AS

BEGIN

DECLARE @Timekey INT

SET @Timekey=(select TimeKey from SysDataMatrix where CurrentStatus='C')

		IF(@Flag=1)

		BEGIN
		print 'A'
			  IF NOT EXISTS
			  (
			  SELECT  A.CustomerACID
					 ,A.CustomerId
					 ,A.CustomerName
					 ,'AccountDetails' TableName
			  FROM DimSMA A 
			  --INNER JOIN curdat.CustomerBasicDetail B  
			  --ON A.CustomerId=B.CustomerId 
			  --AND B.EffectiveFromTimeKey <= @Timekey  
			  --AND  B.EffectiveToTimeKey >= @Timekey
			  WHERE A.CustomerACID=@ACCID
			  AND A.EffectiveFromTimeKey <= @Timekey  
			  AND  A.EffectiveToTimeKey >= @Timekey
			 )

			 BEGIN
			  select 'Account ID does not Exists' AS Error
			  ,'AccountDetails' TableName
			 END
			 else
			 begin
			  SELECT  A.CustomerACID
					 ,A.CustomerId
					 ,A.CustomerName
					 ,B.SourceName
					 ,B.SourceAlt_Key
					 ,'AccountDetails' TableName
			  FROM DimSMA A 
			  inner join DIMSOURCEDB b
			  on a.SourceAlt_Key=b.SourceAlt_Key
			  --INNER JOIN curdat.CustomerBasicDetail B  
			  --ON A.CustomerId=B.CustomerId 
			  --AND B.EffectiveFromTimeKey <= @Timekey  
			  --AND  B.EffectiveToTimeKey >= @Timekey
			  WHERE A.CustomerACID=@ACCID
			  AND A.EffectiveFromTimeKey <= @Timekey  
			  AND  A.EffectiveToTimeKey >= @Timekey
			 end
		END


	Else

		IF(@Flag=0)

		BEGIN
		
			  SELECT  A.CustomerACID
					 ,B.CustomerId
					 ,B.CustomerName
					 ,C.SourceName
					 ,C.SourceAlt_Key
					 ,'AccountDetails1' TableName
			  FROM curdat.AdvAcBasicDetail A 
			  INNER JOIN curdat.CustomerBasicDetail B 
			  ON A.RefCustomerId=B.CustomerId 
			  AND B.EffectiveFromTimeKey <= @Timekey  
			  AND  B.EffectiveToTimeKey >= @Timekey
			   Inner join DIMSOURCEDB C  
			  ON C.SourceAlt_Key=A.SourceAlt_Key
			  WHERE A.CustomerACID=@ACCID
			  AND A.EffectiveFromTimeKey <= @Timekey  
			  AND  A.EffectiveToTimeKey >= @Timekey
		
		END
END
 
GO