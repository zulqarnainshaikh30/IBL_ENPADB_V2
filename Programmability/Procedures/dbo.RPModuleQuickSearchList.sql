SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--[RPModuleQuickSearchList]  'AP00007193','',2,1,1000

CREATE PROC [dbo].[RPModuleQuickSearchList]
--declare
					@CustomerId VARCHAR(20)='60'
					--,@CustomerName VARCHAR(100)=''
					,@UCICID VARCHAR(12)=''
					,@OperationFlag INT=2

					,@newPage SMALLINT =1     
					,@pageSize INT = 30000 
					
AS
	BEGIN

	Declare @Timekey INT

DECLARE @PageFrom INT, @PageTo INT   
  
SET @PageFrom = (@pageSize*@newPage)-(@pageSize) +1  
SET @PageTo = @pageSize*@newPage  


	Set @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C') 
	 --SET @Timekey =(Select LastMonthDateKey from SysDayMatrix where Timekey=@Timekey) 
		
		print @Timekey
		---select customerid and auth status
		Drop Table  IF Exists #Temp

		select A.CustomerID,AuthorisationStatus into #Temp 
		from RP_Portfolio_Details_MOD  A
		inner join(
		SELECT MAX(EntityKey) Entity_Key,CustomerID
                                         FROM RP_Portfolio_Details_MOD
                                          WHERE EffectiveFromTimeKey <= @Timekey
                                              AND EffectiveToTimeKey >= @Timekey --AND ISNULL(ScreenFlag,'U') NOT IN('U','')
											  AND AuthorisationStatus in ('NP','MP','1A')
                                      GROUP BY CustomerID) B on B.Entity_Key=A.EntityKey 

  --AND  (@CustomerName='')

		 	IF ((ISNULL(@CustomerId,'') ='')  AND (ISNULL(@UCICID,'') ='' ) AND (@operationflag not in(16,20)))
		BEGIN
		print '111'
		
			DROP TABLE IF EXISTS #tmp
		

		Select  Row_Number()over (order by  CustomerId desc) RowNumber,* into #tmp from (
		select distinct A.CustomerID 
					   ,B.CustomerName
					   ,B.UCIF_ID as UCICID
					   ,A.ExposureBucketAlt_Key
					   ,Case when (T.AuthorisationStatus) IN ('A','R') Then A.ReferenceDate
					   Else NULL END ReferenceDate
					     ,case when isnull(T.AuthorisationStatus,'A') IN ('FM','MP','NP')
					         then 'Pending'
					         when isnull(T.AuthorisationStatus,'A') IN ('1A')
							 Then '2nd Approval Pending'
					         
							 when isnull(T.AuthorisationStatus,'A') IN ('A','R')
							 Then 'Authorised'
							 else 'No RP Done' End As AuthorisationStatus 
					   ,'CustomerLevel' as TableName

					 
					    
				 from RP_Portfolio_Details A
				 Left Join Curdat.CustomerBasicDetail B ON A.CustomerID =B.CustomerId
				 --Left Join DimExposureBucket C ON A.ExposureBucketAlt_Key=C.ExposureBucketAlt_Key
				  left JOIN #Temp  T  ON T.CustomerID=A.CustomerID
				 --Left Join Curdat.CustomerBasicDetail B On A.RefCustomerId =B.CustomerId
				  --inner join Customerlevelmoc_mod B ON B.CustomerID=A.RefCustomerID
			
				 where A.EffectiveFromTimeKey<=@Timekey
					   AND A.EffectiveToTimeKey >= @Timekey
					   --AND isnull(T.AuthorisationStatus,'A') ='A'
					   AND ISNULL(IsActive,'N')='Y'

                   UNION

				   select distinct A.CustomerID 
					   ,B.CustomerName
					   ,B.UCIF_ID as UCICID
					   ,A.ExposureBucketAlt_Key
					   ,Case when (T.AuthorisationStatus) IN ('A','R') Then A.ReferenceDate
					   Else NULL END ReferenceDate
					     ,case when isnull(T.AuthorisationStatus,'A') IN ('FM','MP','NP')
					         then 'Pending'
					         when isnull(T.AuthorisationStatus,'A') IN ('1A')
							 Then '2nd Approval Pending'
					         
							 when isnull(T.AuthorisationStatus,'A') IN ('A','R')
							 Then 'Authorised'
							 else 'No RP Done' End As AuthorisationStatus 
					   ,'CustomerLevel' as TableName

					 
					    
				 from RP_Portfolio_Details_Mod A
				 Left Join Curdat.CustomerBasicDetail B ON A.CustomerID =B.CustomerId
				 --Left Join DimExposureBucket C ON A.ExposureBucketAlt_Key=C.ExposureBucketAlt_Key
				  left JOIN #Temp  T  ON T.CustomerID=A.CustomerID
				 --Left Join Curdat.CustomerBasicDetail B On A.RefCustomerId =B.CustomerId
				  --inner join Customerlevelmoc_mod B ON B.CustomerID=A.RefCustomerID
			
				 where A.EffectiveFromTimeKey<=@Timekey
					   AND A.EffectiveToTimeKey >= @Timekey
					  -- AND isnull(T.AuthorisationStatus,'A') in('MP','NP','1A')
					  AND ISNULL(IsActive,'N')='Y'
					 --  AND ISNULL(ScreenFlag,'U') NOT IN('U','')
					)	X
					order by 	X.CustomerId desc
					
				Select '#tmp',* from #tmp
			
				 --Select * from #tmp
				 --WHERE RowNumber BETWEEN @PageFrom AND @PageTo
				 Print 'sac1'
				 return;
				  Print 'sac2'
		END
	

		IF @CustomerId =''
		   SET @CustomerId=NULL

		
		IF @UCICID =''
		   SET @UCICID=NULL

		   print '1'
		   
		  

		IF (@OperationFlag not in(16,20) )
		BEGIN
				print '112'


					DROP TABLE IF EXISTS #tmp4
		Declare @RecordCount Int=0 

		Select  Row_Number()over (order by  CustomerId desc) RowNumber,* into #tmp4 from (
		select distinct A.CustomerID 
					   ,A.CustomerName
					   ,A.UCIC_ID as UCICID
					    ,A.ExposureBucketAlt_Key
					   ,Case when (T.AuthorisationStatus) IN ('A','R') Then A.ReferenceDate
					   Else NULL END ReferenceDate
					     ,case when isnull(T.AuthorisationStatus,'A') IN ('FM','MP','NP')
					         then 'Pending'
					         when isnull(T.AuthorisationStatus,'A') IN ('1A')
							 Then '2nd Approval Pending'
					         
							 when isnull(T.AuthorisationStatus,'A') IN ('A','R')
							 Then 'Authorised'
							 else 'No RP Done' End As AuthorisationStatus 
					   ,'CustomerLevel' as TableName
					 
					    
				 from RP_Portfolio_Details A
				 	 --Left Join DimExposureBucket C ON A.ExposureBucketAlt_Key=C.ExposureBucketAlt_Key
				  left JOIN #Temp  T  ON T.CustomerID=A.CustomerID
				 --Left Join Curdat.CustomerBasicDetail B On A.RefCustomerId =B.CustomerId
				  --inner join Customerlevelmoc_mod B ON B.CustomerID=A.RefCustomerID
			
				 where A.EffectiveFromTimeKey<=@Timekey
					   AND A.EffectiveToTimeKey >= @Timekey
					     AND ISNULL(IsActive,'N')='Y'
					    AND  (A.CustomerID=@CustomerId)
					    
					   or  (A.UCIC_ID=@UCICID)

					   UNION

					   select distinct A.CustomerID 
					   ,A.CustomerName
					   ,A.UCIC_ID as UCICID
					    ,A.ExposureBucketAlt_Key
					   ,Case when (T.AuthorisationStatus) IN ('A','R') Then A.ReferenceDate
					   Else NULL END ReferenceDate
					     ,case when isnull(T.AuthorisationStatus,'A') IN ('FM','MP','NP')
					         then 'Pending'
					         when isnull(T.AuthorisationStatus,'A') IN ('1A')
							 Then '2nd Approval Pending'
					         
							 when isnull(T.AuthorisationStatus,'A') IN ('A','R')
							 Then 'Authorised'
							 else 'No RP Done' End As AuthorisationStatus 
					   ,'CustomerLevel' as TableName
					 
					    
				 from RP_Portfolio_Details_Mod A
				 	 --Left Join DimExposureBucket C ON A.ExposureBucketAlt_Key=C.ExposureBucketAlt_Key
				  left JOIN #Temp  T  ON T.CustomerID=A.CustomerID
				 --Left Join Curdat.CustomerBasicDetail B On A.RefCustomerId =B.CustomerId
				  --inner join Customerlevelmoc_mod B ON B.CustomerID=A.RefCustomerID
			
				 where A.EffectiveFromTimeKey<=@Timekey
					   AND A.EffectiveToTimeKey >= @Timekey

					     AND ISNULL(IsActive,'N')='Y'
					    AND  (A.CustomerID=@CustomerId)
					    
					   or  (A.UCIC_ID=@UCICID)
					 --  AND ISNULL(ScreenFlag,'U') NOT IN('U','')
					)	X
					order by 	X.CustomerId desc
					
					Select @RecordCount=Count(*) from #tmp4

					IF @RecordCount>0
						BEGIN
				   PRINT '@RecordCountGreater'
				   PRINT @RecordCount
						 Select * from #tmp4
						 WHERE RowNumber BETWEEN @PageFrom AND @PageTo
                   
				     END

					 IF @RecordCount<=0
						BEGIN
				  PRINT '@RecordCountLess'
				   PRINT @RecordCount
						
                   
				     
				DROP TABLE IF EXISTS #tmp1

		select Row_Number()over (order by  CustomerId desc) RowNumber,* into #tmp1 from (
				select distinct A.CustomerId CustomerID
					   ,A.CustomerName
					   ,A.UCIF_ID as UCICID
					   ,NULL as ExposureBucketAlt_Key
					   ,'CustomerLevel' as TableName
					 
					    
				 from Curdat.CustomerBasicDetail  A
				 Left Join Curdat.AdvCustRelationship B On A.CustomerId =B.RefCustomerId

				 --Left join Customerlevelmoc_mod B ON B.CustomerID=A.RefCustomerID
				  
				  Where A.EffectiveFromTimeKey <= @Timekey
					   AND A.EffectiveToTimeKey >= @Timekey
					       --AND ISNULL(A.ScreenFlag,'U') NOT IN('U','')
					  AND  (A.CustomerID=@CustomerId)
					    --OR ( B.CustomerName like '%' + @CustomerName+ '%')
					   or  (A.UCIF_ID=@UCICID)
					   )R 
					    
						
						order by CustomerId desc  
						Print 'RPModule'
	   	 --Select '##tmp1', * from #tmp1
				Select * from #tmp1
				 WHERE RowNumber BETWEEN @PageFrom AND @PageTo
			END

		END

		IF (@OperationFlag in (16))
		BEGIN
			print '113'
			DROP TABLE IF EXISTS #tmp2

		select Row_Number()over (order by  CustomerId desc) RowNumber,* into #tmp2 from (
				select A.CustomerID
					   ,A.CustomerName
					   ,A.UCIC_ID as UCICID
					    ,AuthorisationStatus
					   ,'CustomerLevel' as TableName 
					  
				 from RP_Portfolio_Details_mod A 
				 
		
				
				
					    
						Where A.EffectiveFromTimeKey <= @Timekey
					   AND A.EffectiveToTimeKey >= @Timekey
					   --AND ISNULL(A.AuthorisationStatus, 'A') IN ('NP', 'MP', 'DP', 'RM')
					    AND ISNULL(IsActive,'N')='Y'
					   --AND  (A.CustomerId=@CustomerId)
					   --OR (A.CustomerName like '%' + @CustomerName+ '%')
					   --OR (B.UCIF_ID=@UCICID)
					    )R 
					  
						order by 	CustomerId desc 

				Select * from #tmp2
				 WHERE RowNumber BETWEEN @PageFrom AND @PageTo

		END

		IF (@OperationFlag in (20))
		BEGIN
			print '114'

				DROP TABLE IF EXISTS #tmp3
		select   Row_Number()over (order by  CustomerId desc) RowNumber,* into #tmp3 from (
				select A.CustomerID
					   ,A.CustomerName
					   ,A.UCIC_ID as UCICID
					    ,AuthorisationStatus
					   ,'CustomerLevel' as TableName 
					  
				 from RP_Portfolio_Details_mod A 
				 
		
				
				
					    
						Where A.EffectiveFromTimeKey <= @Timekey
					   AND A.EffectiveToTimeKey >= @Timekey
					  -- AND ISNULL(A.AuthorisationStatus, 'A') IN ('1A')
					       AND ISNULL(IsActive,'N')='Y'  
					   --AND  (A.CustomerId=@CustomerId)
					   --OR (A.CustomerName like '%' + @CustomerName+ '%')
					   --OR (B.UCIF_ID=@UCICID)
					   )R 
					    
				       order by 	CustomerId desc 

				Select * from #tmp3
				 WHERE RowNumber BETWEEN @PageFrom AND @PageTo

		END

	END


GO