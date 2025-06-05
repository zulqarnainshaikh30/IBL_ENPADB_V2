SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--IF OBJECT_ID('TempDB..#tmp') IS NOT NULL

CREATE PROC [dbo].[AccountLevelQuickSearchList]

					@ACID varchar(30)=''
					,@CustomerId VARCHAR(20)=''
					,@CustomerName VARCHAR(20)=''
					,@UCICID VARCHAR(12)=''
					,@OperationFlag INT

					,@newPage SMALLINT =1     
					,@pageSize INT = 30000

AS
	BEGIN

	Declare @Timekey INT

	DECLARE @PageFrom INT, @PageTo INT   
  
SET @PageFrom = (@pageSize*@newPage)-(@pageSize) +1  
SET @PageTo = @pageSize*@newPage 

 --SET @Timekey =(Select TimeKey from SysDataMatrix where CurrentStatus='C') 

 -- SET @Timekey =(Select LastMonthDateKey from SysDayMatrix where Timekey=@Timekey) 

   DECLARE @CustomerEntityID INT=0

 	Declare @ExtDate Date
 
	SET @Timekey =(Select Timekey from SysDataMatrix Where ISNULL(MOC_Initialised,'N')='Y' AND ISNULL(MOC_Frozen,'N')='N') 
	
	SET @ExtDate=(Select Distinct ExtDate from SysDataMatrix Where ISNULL(MOC_Initialised,'N')='Y' AND ISNULL(MOC_Frozen,'N')='N') 
	
		   SET  @CustomerEntityID =(SELECT CustomerEntityID  FROM   CustomerBasicDetail A
												WHERE CustomerId=@CustomerId  
												AND A.EffectiveFromTimeKey<=@Timekey AND A.EffectiveToTimeKey >= @Timekey
					                    )

										PRINT '@CustomerEntityID'
										
										PRINT @CustomerEntityID
		
		--print @Timekey

		--DROP TABLE IF EXISTS #TEmp
		--select A.AccountID,AuthorisationStatus into #Temp from Accountlevelmoc_mod A
		--inner join(
		--select max(EntityKey) EntityKey,AccountID 
		--                                 from Accountlevelmoc_mod
		--                                 where EffectiveFromTimeKey<=@Timekey and EffectiveToTimeKey>=@Timekey
		--								 group by AccountID)B on B.EntityKey=A.EntityKey
										 
--Select '#TEmp', * from #TEmp
		
		 		IF ((@ACID ='' OR @ACID IS NULL) ) 
	  
	  begin

		 if (@operationflag not in(16,20))

		BEGIN
		print '111A'
	 PRINT 'SWAPNA'

	 IF OBJECT_ID('TempDB..#tmp2') IS NOT NULL DROP Table #tmp2

			 select * INTO #tmp2  from ( select distinct C.CustomerACID as ACID
					   ,T.CustomerId RefCustomerId
					   ,T.CustomerName
					   ,T.UCIF_ID as UCICID
					   ,case when isnull(A.AuthorisationStatus,'') IN ('MP','NP')
					         then 'Pending'
					         when isnull(A.AuthorisationStatus,'') IN ('1A')
							 Then '2nd Approval Pending'
					         
							 when isnull(A.AuthorisationStatus,'') IN ('A')
							 Then 'Authorised'
							 else 'No MOC Done' End As AuthorisationStatus 
					,Convert(Varchar(10),@ExtDate,103) As MOCMonthEndDate
					,A.CustomerEntityID
					,'AccountLevel' as TableName
					,Row_Number()over (order by (select 1)) RowNumber 
					  -- ,A.MOC_Reason_Remark                                               ----------------------------added by kapl 24/11/2023 as per requirement

				 from MOC_ChangeDetails A
				  --inner join Customerlevelmoc_mod B ON B.CustomerID=A.RefCustomerID
				 INNER  JOIN CustomerBasicDetail  T  ON T.CustomerEntityId=A.CustomerEntityID 
				 AND  T.EffectiveFromTimeKey<=@Timekey
					   AND T.EffectiveToTimeKey >= @Timekey 
				 INNER JOIN AdvAcBasicDetail C ON C.AccountEntityId=A.AccountEntityID  
				 AND  C.EffectiveFromTimeKey<=@Timekey
					   AND C.EffectiveToTimeKey >= @Timekey 
				 where A.EffectiveFromTimeKey <=@Timekey
					   AND A.EffectiveToTimeKey >= @Timekey 
					   AND A.AuthorisationStatus='A'
		 	           AND  A.AccountEntityID NOT IN (SELECT AccountEntityID FROM AccountLevelMOC_Mod 
					                                   WHERE AuthorisationStatus IN ('MP','NP','1A')
													   AND EffectiveFromTimeKey<=@Timekey
					                                   AND EffectiveToTimeKey >= @Timekey )
						--OR A.CustomerEntityID=@CustomerEntityID

					 	             UNION

				     	
		select distinct A.AccountID as ACID,
		                    T.CustomerID RefCustomerId
					   ,T.CustomerName
					   ,T.UCIF_ID as UCICID
					   ,case when isnull(A.AuthorisationStatus,'') IN ('MP','NP')
					         then 'Pending'
					         when isnull(A.AuthorisationStatus,'') IN ('1A')
							 Then '2nd Approval Pending'
					         
							 when isnull(A.AuthorisationStatus,'') IN ('A')
							 Then 'Authorised'
							 else 'No MOC Done' End As AuthorisationStatus 
						,Convert(Varchar(10),@ExtDate,103) As MOCMonthEndDate
						,0 as CustomerEntityID
					   ,'AccountLevel' as TableName
					   ,Row_Number()over (order by (select 1)) RowNumber 
					 --  ,A.MOC_Reason_Remark                                               ----------------------------added by kapl 24/11/2023 as per requirement
				 from AccountLevelMOC_Mod A
				  --inner join Customerlevelmoc_mod B ON B.CustomerID=A.RefCustomerID
				  INNER JOIN   AdvAcBasicDetail C ON C.AccountEntityId=A.AccountEntityID  
				 AND  C.EffectiveFromTimeKey<=@Timekey
					   AND C.EffectiveToTimeKey >= @Timekey 
				 INNER JOIN CustomerBasicDetail  T  ON T.CustomerEntityId=C.CustomerEntityID AND                                                   
				 T.EffectiveFromTimeKey<=@Timekey
					   AND T.EffectiveToTimeKey >= @Timekey 

			 --LEFT JOIN #TEmp C on C.CustomerEntityID=A.CustomerEntityID
				 where A.EffectiveFromTimeKey<=@Timekey
					   AND A.EffectiveToTimeKey >= @Timekey 
					  AND A.AuthorisationStatus IN ('MP','NP','1A','R')
) E

  --Select '#tmp2',* from #tmp2

IF @CustomerEntityID<>0
   BEGIN
   Print 'A1'
      Select * from #tmp2
	  Where CustomerEntityID=@CustomerEntityID
   END


   IF @CustomerEntityID IS NULL
   BEGIN
      Select * from #tmp2
	
   END

		END



		IF (@OperationFlag in (16))
		BEGIN

		PRINT 'SWAPNA 1'
				select * from (
				select A.AccountID as ACID
					   ,C.CustomerId RefCustomerId
					   ,C.CustomerName
					   ,C.UCIF_ID as UCICID
					    ,case when isnull(A.AuthorisationStatus,'') IN ('MP','NP')
					         then 'Pending'
					         when isnull(A.AuthorisationStatus,'') IN ('1A')
							 Then '2nd Approval Pending'
					         
							 when isnull(A.AuthorisationStatus,'') IN ('A')
							 Then 'Authorised'
							 else 'No MOC Done' End As AuthorisationStatus 
						,Convert(Varchar(10),@ExtDate,103) As MOCMonthEndDate
					   ,'AccountLevel' as TableName
					    ,Row_Number()over (order by (select 1)) RowNumber 
						--,A.MOC_Reason_Remark                             ----------------------------added by kapl 24/11/2023 as per requirement
				 from Accountlevelmoc_mod A
				   --     inner join Pro.accountcal_Hist C ON C.CustomerAcID=A.AccountID
						 --inner join Pro.customercal_hist B
						 INNER JOIN AdvAcBasicDetail B

						                 ON A.AccountEntityID=B.AccountEntityId
						                 AND B.EffectiveFromTimeKey <= @Timekey
						                 AND B.EffectiveToTimeKey >= @Timekey
						INNER JOIN CustomerBasicDetail C
						 ON B.CustomerEntityId=C.CustomerEntityId
						                 AND C.EffectiveFromTimeKey <= @Timekey
						                 AND C.EffectiveToTimeKey >= @Timekey
				 Where A.EffectiveFromTimeKey <= @Timekey
					   AND A.EffectiveToTimeKey >= @Timekey
					    AND ISNULL(A.AuthorisationStatus, 'A') IN ('MP','NP','DP','RM')
						AND ISNULL(A.ScreenFlag,'S') NOT IN('U')
				
			

		
					--OR C.CustomerId=@CustomerId
					--   OR C.CustomerName like '%' + @CustomerName+ '%'
					--   OR C.UCIF_ID=@UCICID)
					 ) A
					    WHERE RowNumber BETWEEN @PageFrom AND @PageTo
						order by 	RowNumber 



		END

		IF (@OperationFlag in (20))
		BEGIN

	PRINT 'SWAPNA 2'


		select * from (
				select A.AccountID as ACID
					   ,C.CustomerId RefCustomerId
					   ,C.CustomerName
					   ,C.UCIF_ID as UCICID
					   ,case when isnull(A.AuthorisationStatus,'') IN ('MP','NP')
					         then 'Pending'
					         when isnull(A.AuthorisationStatus,'') IN ('1A')
							 Then '2nd Approval Pending'
					         
							 when isnull(A.AuthorisationStatus,'') IN ('A')
							 Then 'Authorised'
							 else 'No MOC Done' End As AuthorisationStatus
							,Convert(Varchar(10),@ExtDate,103) As MOCMonthEndDate
					   ,'AccountLevel' as TableName
					    ,Row_Number()over (order by (select 1)) RowNumber 
						--,A.MOC_Reason_Remark                             ----------------------------added by kapl 24/11/2023 as per requirement
				from Accountlevelmoc_mod A
				   --     inner join Pro.accountcal_Hist C ON C.CustomerAcID=A.AccountID
						 --inner join Pro.customercal_hist B
						 --                ON C.RefCustomerID=B.Refcustomerid
						 --                AND B.EffectiveFromTimeKey <= @Timekey
						 --                AND B.EffectiveToTimeKey >= @Timekey
					 INNER JOIN AdvAcBasicDetail B

						                 ON A.AccountEntityID=B.AccountEntityId
						                 AND B.EffectiveFromTimeKey <= @Timekey
						                 AND B.EffectiveToTimeKey >= @Timekey
						INNER JOIN CustomerBasicDetail C
						 ON B.CustomerEntityId=C.CustomerEntityId
						                 AND C.EffectiveFromTimeKey <= @Timekey
						                 AND C.EffectiveToTimeKey >= @Timekey
				 Where A.EffectiveFromTimeKey <= @Timekey
					   AND A.EffectiveToTimeKey >= @Timekey
					    AND ISNULL(A.AuthorisationStatus, 'A') IN ('1A')
						AND ISNULL(A.ScreenFlag,'S') NOT IN('U')
					--AND  (A.AccountID=@ACID
					--OR B.RefCustomerId=@CustomerId
					--   OR B.CustomerName like '%' + @CustomerName+ '%'
					--   OR B.UCIF_ID=@UCICID)
					 ) A
					    WHERE RowNumber BETWEEN @PageFrom AND @PageTo
						order by 	RowNumber
	END
	END
ELSE
  BEGIN
               DECLARE @AccountEntityID INT
	   SET  @AccountEntityID =(SELECT AccountEntityId  FROM  AdvAcBasicDetail A
												WHERE CustomerACID=@ACID 
												AND A.EffectiveFromTimeKey<=@Timekey
					                    AND A.EffectiveToTimeKey >= @Timekey)

	
	   

	    if (@operationflag not in(16,20)) AND (@ACID<>'' OR @ACID<>NULL)
		    
		Begin
		   IF EXISTS (SELECT 1 FROM MOC_ChangeDetails WHERE AccountEntityID =@AccountEntityID 
		                                               AND EffectiveFromTimeKey<=@Timekey
					                    AND EffectiveToTimeKey >= @Timekey  AND AuthorisationStatus='A')

		BEGIN
		print '111b'
		PRINT  'bb'
PRINT 'SWAPNA b'
		select distinct C.CustomerACID as ACID
					   ,T.CustomerId RefCustomerId
					   ,T.CustomerName
					   ,T.UCIF_ID as UCICID
					    ,case when isnull(A.AuthorisationStatus,'') IN ('MP','NP')
					         then 'Pending'
					         when isnull(A.AuthorisationStatus,'') IN ('1A')
							 Then '2nd Approval Pending'
					         
							 when isnull(A.AuthorisationStatus,'') IN ('A')
							 Then 'Authorised'
							 else 'No MOC Done' End As AuthorisationStatus 
						,Convert(Varchar(10),@ExtDate,103) As MOCMonthEndDate
					   ,'AccountLevel' as TableName
					   ,Row_Number()over (order by (select 1)) RowNumber 
					  -- ,A.MOC_Reason_Remark                    ----------------------------added by kapl 24/11/2023 as per requirement
				 from MOC_ChangeDetails A
				  --inner join Customerlevelmoc_mod B ON B.CustomerID=A.RefCustomerID
				 INNER  JOIN CustomerBasicDetail  T  ON T.CustomerEntityId=A.CustomerEntityID 
				 AND  T.EffectiveFromTimeKey<=@Timekey
					   AND T.EffectiveToTimeKey >= @Timekey 
				 INNER JOIN AdvAcBasicDetail C ON C.AccountEntityId=A.AccountEntityID  
				 AND  C.EffectiveFromTimeKey<=@Timekey
					   AND C.EffectiveToTimeKey >= @Timekey 
				 where A.EffectiveFromTimeKey <=@Timekey
					   AND A.EffectiveToTimeKey >= @Timekey 
					   AND A.AuthorisationStatus='A'
		 	    AND A.AccountEntityID=@AccountEntityID
END	
		
 ELSE IF EXISTS (SELECT 1 FROM AccountLevelMOC_Mod WHERE AccountEntityID =@AccountEntityID  AND EffectiveFromTimeKey<=@Timekey
					                    AND EffectiveToTimeKey >= @Timekey  AND AuthorisationStatus IN ('MP','NP','1A'))
BEGIN     	
PRINT 'SWAPNA 4'
            select A.AccountID as ACID
					   ,C.CustomerId RefCustomerId
					   ,C.CustomerName
					   ,C.UCIF_ID as UCICID
					   ,case when isnull(A.AuthorisationStatus,'') IN ('MP','NP')
					         then 'Pending'
					         when isnull(A.AuthorisationStatus,'') IN ('1A')
							 Then '2nd Approval Pending'
					         
							 when isnull(A.AuthorisationStatus,'') IN ('A')
							 Then 'Authorised'
							 else 'No MOC Done' End As AuthorisationStatus 
						,Convert(Varchar(10),@ExtDate,103) As MOCMonthEndDate
					   ,'AccountLevel' as TableName
					    ,Row_Number()over (order by (select 1)) RowNumber 
						--, A.MOC_Reason_Remark                                              ----------------------------added by kapl 24/11/2023 as per requirement
				 from Accountlevelmoc_mod A
				   --     inner join Pro.accountcal_Hist C ON C.CustomerAcID=A.AccountID
						 --inner join Pro.customercal_hist B
						 INNER JOIN AdvAcBasicDetail B

						                 ON A.AccountEntityID=B.AccountEntityId
						                 AND B.EffectiveFromTimeKey <= @Timekey
						                 AND B.EffectiveToTimeKey >= @Timekey
						INNER JOIN CustomerBasicDetail C
						 ON B.CustomerEntityId=C.CustomerEntityId
						                 AND C.EffectiveFromTimeKey <= @Timekey
						                 AND C.EffectiveToTimeKey >= @Timekey
				 Where A.EffectiveFromTimeKey <= @Timekey
					   AND A.EffectiveToTimeKey >= @Timekey
					    AND ISNULL(A.AuthorisationStatus, 'A') IN ('MP','NP','1A')
						AND ISNULL(A.ScreenFlag,'S') NOT IN('U')
						AND A.AccountEntityID=@AccountEntityID

END
ELSE 
BEGIN
PRINT 'AKSHAY3'
select distinct    B.CustomerACID  ACID
                       , C.CustomerID RefCustomerId
					   ,C.CustomerName
					   ,C.UCIF_ID as UCICID

					   ,'No MOC Done' AuthorisationStatus 
					   ,'AccountLevel' as TableName
					   ,Convert(Varchar(10),@ExtDate,103) As MOCMonthEndDate
				 from  AdvAcBasicDetail B
						INNER JOIN CustomerBasicDetail C
						 ON B.CustomerEntityId=C.CustomerEntityId
						   AND C.EffectiveFromTimeKey <= @Timekey
						                 AND C.EffectiveToTimeKey >= @Timekey  
				 where     B.EffectiveFromTimeKey<=@Timekey
					   AND B.EffectiveToTimeKey >= @Timekey 
					AND    B.AccountEntityId=@AccountEntityID

END


 END

 END
END
GO