SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


--IF OBJECT_ID('TempDB..#tmp') IS NOT NULL

CREATE PROC [dbo].[CalypsoAccountLevelQuickSearchList]

					@ACID varchar(30)='20517'
					,@CustomerId VARCHAR(20)=''
					,@CustomerName VARCHAR(20)=''
					,@UCICID VARCHAR(12)=''
					,@OperationFlag INT = 2

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

   DECLARE @InvestmentCustomerEntityID INT=0

   DECLARE @DerivativeCustomerEntityID INT=0

 	Declare @ExtDate Date
 
	SET @Timekey =(Select Timekey from SysDataMatrix Where ISNULL(MOC_Initialised,'N')='Y' AND ISNULL(MOC_Frozen,'N')='N') 
	
	SET @ExtDate=(Select Distinct ExtDate from SysDataMatrix Where ISNULL(MOC_Initialised,'N')='Y' AND ISNULL(MOC_Frozen,'N')='N') 
	
		   SET  @InvestmentCustomerEntityID =(SELECT IssuerEntityId  
									FROM   InvestmentBasicDetail A
												WHERE RefIssuerID=@CustomerId  
												AND A.EffectiveFromTimeKey<=@Timekey 
												AND A.EffectiveToTimeKey >= @Timekey
					                    )

										PRINT '@InvestmentCustomerEntityID'
										
										PRINT @InvestmentCustomerEntityID

										SET  @DerivativeCustomerEntityID =(SELECT DerivativeEntityID  
									FROM   curdat.DerivativeDetail A
												WHERE DerivativeRefNo=@CustomerId  
												AND A.EffectiveFromTimeKey<=@Timekey 
												AND A.EffectiveToTimeKey >= @Timekey
					                    )

										PRINT '@DerivativeCustomerEntityID'
										
										PRINT @DerivativeCustomerEntityID
		
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
		print '111'
	 PRINT 'SWAPNA'

	 IF OBJECT_ID('TempDB..#tmp2') IS NOT NULL 
	 
	 DROP Table #tmp2

			 select * 
			 INTO #tmp2  
			 from ( select distinct C.InvID as ACID
					   ,T.IssuerID RefCustomerId
					   ,T.IssuerName as CustomerName
					   ,T.UcifId as UCICID
					     ,case when isnull(A.AuthorisationStatus,'') IN ('MP','NP')
					         then '1st Approval Pending'
					         when isnull(A.AuthorisationStatus,'') IN ('1A')
							 Then '2nd Approval Pending'
							 when isnull(A.AuthorisationStatus,'') IN ('A')
							 Then 'Authorised'
							 else 'No MOC Done' End As AuthorisationStatus 
					,Convert(Varchar(10),@ExtDate,103) As MOCMonthEndDate
					,A.CustomerEntityID
					   ,'CalypsoAccountLevel' as TableName
					   ,Row_Number()over (order by (select 1)) RowNumber 
				 from CalypsoInvMOC_ChangeDetails A
				  --inner join Customerlevelmoc_mod B ON B.CustomerID=A.RefCustomerID
				 INNER  JOIN InvestmentIssuerDetail  T  ON T.IssuerEntityID=A.CustomerEntityid
				 AND  T.EffectiveFromTimeKey<=@Timekey
					   AND T.EffectiveToTimeKey >= @Timekey 
				 INNER JOIN InvestmentBasicDetail C ON C.InvEntityId=A.AccountEntityID  
				 AND  C.EffectiveFromTimeKey<=@Timekey
					   AND C.EffectiveToTimeKey >= @Timekey 
				 where A.EffectiveFromTimeKey <=@Timekey
					   AND A.EffectiveToTimeKey >= @Timekey 
					   AND A.AuthorisationStatus='A'
		 	           --AND  A.AccountEntityID NOT IN (SELECT AccountEntityID FROM CalypsoAccountLevelMOC_Mod 
					          --                         WHERE AuthorisationStatus IN ('MP','NP','1A')
													  -- AND EffectiveFromTimeKey<=@Timekey
					          --                         AND EffectiveToTimeKey >= @Timekey )
						--OR A.CustomerEntityID=@CustomerEntityID
						--and c.INVID=@ACID
					 	             UNION

				     	
		select distinct T.DerivativeRefNo as ACID,
		                    T.CustomerID RefCustomerId
					   ,T.CustomerName
					   ,T.UCIC_ID as UCICID
					   ,case when isnull(A.AuthorisationStatus,'') IN ('MP','NP')
					         then '1st Approval Pending'
					         when isnull(A.AuthorisationStatus,'') IN ('1A')
							 Then '2nd Approval Pending'
					         
							 when isnull(A.AuthorisationStatus,'') IN ('A')
							 Then 'Authorised'
							 else 'No MOC Done' End As AuthorisationStatus 
						,Convert(Varchar(10),@ExtDate,103) As MOCMonthEndDate
						,0 as CustomerEntityID
					   ,'CalypsoAccountLevel' as TableName
					   ,Row_Number()over (order by (select 1)) RowNumber 
				 from CalypsoDervMOC_ChangeDetails A
				
				 INNER JOIN curdat.DerivativeDetail  T  
				 ON A.AccountEntityID=T.DerivativeEntityID AND                                                   
				 T.EffectiveFromTimeKey<=@Timekey
					   AND T.EffectiveToTimeKey >= @Timekey 

				 where A.EffectiveFromTimeKey<=@Timekey
					   AND A.EffectiveToTimeKey >= @Timekey 
					  AND A.AuthorisationStatus='A'
		 	           --AND  A.AccountEntityID NOT IN (SELECT AccountEntityID FROM CalypsoAccountLevelMOC_Mod 
					          --                         WHERE AuthorisationStatus IN ('MP','NP','1A')
													  -- AND EffectiveFromTimeKey<=@Timekey
					          --                         AND EffectiveToTimeKey >= @Timekey )
					 -- and T.DerivativeRefNo=@ACID

					  UNION

					  select distinct C.InvID as ACID
					   ,T.IssuerID RefCustomerId
					   ,T.IssuerName as CustomerName
					   ,T.UcifId as UCICID
					     ,case when isnull(A.AuthorisationStatus,'') IN ('MP','NP')
					         then '1st Approval Pending'
					         when isnull(A.AuthorisationStatus,'') IN ('1A')
							 Then '2nd Approval Pending'
							 when isnull(A.AuthorisationStatus,'') IN ('A')
							 Then 'Authorised'
							 else 'No MOC Done' End As AuthorisationStatus 
					,Convert(Varchar(10),@ExtDate,103) As MOCMonthEndDate
					,0 as CustomerEntityID
					   ,'CalypsoAccountLevel' as TableName
					   ,Row_Number()over (order by (select 1)) RowNumber 
				 from CalypsoAccountLevelMOC_Mod A
				  --inner join Customerlevelmoc_mod B ON B.CustomerID=A.RefCustomerID
				 
				 INNER JOIN InvestmentBasicDetail C 
				 ON C.InvEntityId=A.AccountEntityID  
				 AND A.AccountID = C.InvID
				 AND  C.EffectiveFromTimeKey<=@Timekey
					   AND C.EffectiveToTimeKey >= @Timekey 
					   INNER  JOIN InvestmentIssuerDetail  T  ON T.IssuerEntityID=C.IssuerEntityId
				 AND  T.EffectiveFromTimeKey<=@Timekey
					   AND T.EffectiveToTimeKey >= @Timekey 
				 where A.EffectiveFromTimeKey <=@Timekey
					   AND A.EffectiveToTimeKey >= @Timekey 
					 AND A.AuthorisationStatus IN ('MP','NP','1A') AND A.ScreenFlag <> 'U'
						--OR A.CustomerEntityID=@CustomerEntityID
					--	and c.INVID=@ACID
					 	             UNION

				     	
		select distinct T.DerivativeRefNo as ACID,
		                    T.CustomerID RefCustomerId
					   ,T.CustomerName
					   ,T.UCIC_ID as UCICID
					   ,case when isnull(A.AuthorisationStatus,'') IN ('MP','NP')
					         then '1st Approval Pending'
					         when isnull(A.AuthorisationStatus,'') IN ('1A')
							 Then '2nd Approval Pending'
					         
							 when isnull(A.AuthorisationStatus,'') IN ('A')
							 Then 'Authorised'
							 else 'No MOC Done' End As AuthorisationStatus 
						,Convert(Varchar(10),@ExtDate,103) As MOCMonthEndDate
						,0 as CustomerEntityID
					   ,'CalypsoAccountLevel' as TableName
					   ,Row_Number()over (order by (select 1)) RowNumber 
				 from CalypsoAccountLevelMOC_Mod A
				
				 INNER JOIN curdat.DerivativeDetail  T  
				 ON A.AccountEntityID=T.DerivativeEntityID AND                                                   
				 T.EffectiveFromTimeKey<=@Timekey
					   AND T.EffectiveToTimeKey >= @Timekey 
					   AND A.AccountID = T.DerivativeRefNo
				 where A.EffectiveFromTimeKey<=@Timekey
					   AND A.EffectiveToTimeKey >= @Timekey 
					  AND A.AuthorisationStatus IN ('MP','NP','1A') AND A.ScreenFlag <> 'U'
		 	          
					 -- and T.DerivativeRefNo=@ACID
) E

  --Select '#tmp2',* from #tmp2

IF @InvestmentCustomerEntityID<>0
   BEGIN
      Select * from #tmp2
	  Where CustomerEntityID=@InvestmentCustomerEntityID
   END
   Else  IF @DerivativeCustomerEntityID<>0
   BEGIN
      Select * from #tmp2
	  Where CustomerEntityID=@DerivativeCustomerEntityID
   END

   IF (@InvestmentCustomerEntityID  IS NULL AND @DerivativeCustomerEntityID IS NULL)
   BEGIN
      Select * from #tmp2
	
   END

		END



		IF (@OperationFlag in (16))
		BEGIN

		PRINT 'SWAPNA 1'
				--select * from (
				select  A.AccountID as ACID
					   ,C.IssuerID RefCustomerId
					   ,C.IssuerName as CustomerName
					   ,C.UcifId as UCICID
					   ,case when isnull(A.AuthorisationStatus,'') IN ('FM','MP','NP')
					         then '1st Approval Pending'
					         when isnull(A.AuthorisationStatus,'') IN ('1A')
							 Then '2nd Approval Pending'
					         
							 when isnull(A.AuthorisationStatus,'') IN ('A','R')
							 Then 'Authorised'
							 else 'No MOC Done' End As AuthorisationStatus  
						,Convert(Varchar(10),@ExtDate,103) As MOCMonthEndDate
					   ,'CalypsoAccountLevel' as TableName
					    ,Row_Number()over (order by (select 1)) RowNumber 
				 from CalypsoAccountLevelMOC_Mod A
			
						 INNER JOIN InvestmentBasicDetail B

						                 ON A.AccountID=B.InvId
						                 AND B.EffectiveFromTimeKey <= @Timekey
						                 AND B.EffectiveToTimeKey >= @Timekey
						INNER JOIN InvestmentIssuerDetail C
						 ON B.IssuerEntityid=C.IssuerEntityid
						                 AND C.EffectiveFromTimeKey <= @Timekey
						                 AND C.EffectiveToTimeKey >= @Timekey
				 Where A.EffectiveFromTimeKey <= @Timekey
					   AND A.EffectiveToTimeKey >= @Timekey
					     AND A.AuthorisationStatus IN ('MP','NP','DP','RM') AND A.ScreenFlag <> 'U'
					  AND A.MOC_TypeFlag='ACCT'
						--and A.AccountID=@ACID
				UNION
				select A.AccountID as ACID
					   ,B.CustomerId RefCustomerId
					   ,B.CustomerName
					   ,B.UCIC_ID as UCICID
					    ,case when isnull(A.AuthorisationStatus,'') IN ('FM','MP','NP')
					         then '1st Approval Pending'
					         when isnull(A.AuthorisationStatus,'') IN ('1A')
							 Then '2nd Approval Pending'
					         
							 when isnull(A.AuthorisationStatus,'') IN ('A','R')
							 Then 'Authorised'
							 else 'No MOC Done' End As AuthorisationStatus 
						,Convert(Varchar(10),@ExtDate,103) As MOCMonthEndDate
					   ,'CalypsoAccountLevel' as TableName
					    ,Row_Number()over (order by (select 1)) RowNumber 
				 from CalypsoAccountLevelMOC_Mod A
				   --     inner join Pro.accountcal_Hist C ON C.CustomerAcID=A.AccountID
						 --inner join Pro.customercal_hist B
						 INNER JOIN curdat.DerivativeDetail B

						                 ON A.AccountID=B.DerivativeRefNo
						                 AND B.EffectiveFromTimeKey <= @Timekey
						                 AND B.EffectiveToTimeKey >= @Timekey
						
				 Where A.EffectiveFromTimeKey <= @Timekey
					   AND A.EffectiveToTimeKey >= @Timekey
					   AND A.AuthorisationStatus IN ('MP','NP','DP','RM') AND A.ScreenFlag <> 'U'
				         

			           --and A.AccountID=@ACID

		
					--OR C.CustomerId=@CustomerId
					--   OR C.CustomerName like '%' + @CustomerName+ '%'
					--   OR C.UCIF_ID=@UCICID)
					-- ) A
					   



		END

		IF (@OperationFlag in (20))
		BEGIN

	PRINT 'SWAPNA 2'


		--select * from (
				select A.AccountID as ACID
					   ,C.IssuerID RefCustomerId
					   ,C.IssuerName as CustomerName
					   ,C.UcifId as UCICID
					    ,case when isnull(A.AuthorisationStatus,'') IN ('FM','MP','NP')
					         then '1st Approval Pending'
					         when isnull(A.AuthorisationStatus,'') IN ('1A')
							 Then '2nd Approval Pending'
					         
							 when isnull(A.AuthorisationStatus,'') IN ('A','R')
							 Then 'Authorised'
							 else 'No MOC Done' End As AuthorisationStatus 
							,Convert(Varchar(10),@ExtDate,103) As MOCMonthEndDate
					   ,'CalypsoAccountLevel' as TableName
					    ,Row_Number()over (order by (select 1)) RowNumber 
				from CalypsoAccountlevelmoc_mod A
				   INNER JOIN InvestmentBasicDetail B
						                 ON A.AccountID=B.InvId
						                 AND B.EffectiveFromTimeKey <= @Timekey
						                 AND B.EffectiveToTimeKey >= @Timekey
						INNER JOIN InvestmentIssuerDetail C
						 ON B.IssuerEntityId=C.IssuerEntityId
						                 AND C.EffectiveFromTimeKey <= @Timekey
						                 AND C.EffectiveToTimeKey >= @Timekey
				 Where A.EffectiveFromTimeKey <= @Timekey
					   AND A.EffectiveToTimeKey >= @Timekey
					     AND A.AuthorisationStatus IN ('1A') AND A.ScreenFlag <> 'U'
					  AND A.MOC_TypeFlag='ACCT'
						--and A.AccountID=@ACID
						UNION

						select A.AccountID as ACID
					   ,C.CustomerId RefCustomerId
					   ,C.CustomerName
					   ,C.UCIC_ID as UCICID
					   ,case when isnull(A.AuthorisationStatus,'') IN ('FM','MP','NP')
					         then '1st Approval Pending'
					         when isnull(A.AuthorisationStatus,'') IN ('1A')
							 Then '2nd Approval Pending'
					         
							 when isnull(A.AuthorisationStatus,'') IN ('A','R')
							 Then 'Authorised'
							 else 'No MOC Done' End As AuthorisationStatus 
							,Convert(Varchar(10),@ExtDate,103) As MOCMonthEndDate
					   ,'CalypsoAccountLevel' as TableName
					    ,Row_Number()over (order by (select 1)) RowNumber 
				from CalypsoAccountlevelmoc_mod A
				  
					 INNER JOIN Curdat.DerivativeDetail C

						                 ON A.AccountID=C.DerivativeRefNo
						                 AND C.EffectiveFromTimeKey <= @Timekey
						                 AND C.EffectiveToTimeKey >= @Timekey
						
				 Where A.EffectiveFromTimeKey <= @Timekey
					   AND A.EffectiveToTimeKey >= @Timekey
					   AND A.AuthorisationStatus IN ('1A') AND A.ScreenFlag <> 'U'
				--and A.AccountID=@ACID
					--AND  (A.AccountID=@ACID
					--OR B.RefCustomerId=@CustomerId
					--   OR B.CustomerName like '%' + @CustomerName+ '%'
					--   OR B.UCIF_ID=@UCICID)
					-- ) A
					 --  and RowNumber BETWEEN @PageFrom AND @PageTo
						--order by 	RowNumber
	END
	END
ELSE
  BEGIN
               DECLARE @InvestmentAccountEntityID INT
	   SET  @InvestmentAccountEntityID =(
	   
	   SELECT invEntityid  FROM  InvestmentBasicDetail A
												WHERE InvID=@ACID 
												AND A.EffectiveFromTimeKey<=@Timekey
					                    AND A.EffectiveToTimeKey >= @Timekey										
										)

	
	     DECLARE @DerivativeAccountEntityID INT
	   SET  @DerivativeAccountEntityID =(
	   
	
										SELECT DerivativeEntityID  FROM  curdat.DerivativeDetail A
												WHERE DerivativeRefNO=@ACID 
												AND A.EffectiveFromTimeKey<=@Timekey
					                    AND A.EffectiveToTimeKey >= @Timekey
										)

	    if (@operationflag not in(16,20)) AND (@ACID<>'' OR @ACID<>NULL)
		    
		Begin
		   IF EXISTS (SELECT 1 FROM CalypsoInvMOC_ChangeDetails WHERE AccountEntityID =@InvestmentAccountEntityID 
		                                               AND EffectiveFromTimeKey<=@Timekey
					                    AND EffectiveToTimeKey >= @Timekey  AND AuthorisationStatus='A' 
										UNION SELECT 1 FROM CalypsoDervMOC_ChangeDetails WHERE AccountEntityID =@DerivativeAccountEntityID 
		                                               AND EffectiveFromTimeKey<=@Timekey
					                    AND EffectiveToTimeKey >= @Timekey  AND AuthorisationStatus='A')

		BEGIN
		print '111'
		PRINT  '45'
PRINT 'SWAPNA 3'
		select distinct C.InvID as ACID
					   ,T.IssuerID RefCustomerId
					   ,T.IssuerName as CustomerName
					   ,T.UcifId as UCICID
					    ,case when isnull(A.AuthorisationStatus,'') IN ('MP','NP')
					         then '1st Approval Pending'
					         when isnull(A.AuthorisationStatus,'') IN ('1A')
							 Then '2nd Approval Pending'
					         
							 when isnull(A.AuthorisationStatus,'') IN ('A')
							 Then 'Authorised'
							 else 'No MOC Done' End As AuthorisationStatus 
						,Convert(Varchar(10),@ExtDate,103) As MOCMonthEndDate
					   ,'CalypsoAccountLevel' as TableName
					   ,Row_Number()over (order by (select 1)) RowNumber 
				 from CalypsoInvMOC_ChangeDetails A
				  --inner join Customerlevelmoc_mod B ON B.CustomerID=A.RefCustomerID
				 INNER  JOIN InvestmentIssuerDetail  T  ON T.IssuerEntityId=A.CustomerEntityID 
				 AND  T.EffectiveFromTimeKey<=@Timekey
					   AND T.EffectiveToTimeKey >= @Timekey 
				 INNER JOIN InvestmentBasicDetail C ON C.InvEntityId=A.AccountEntityID  
				 AND  C.EffectiveFromTimeKey<=@Timekey
					   AND C.EffectiveToTimeKey >= @Timekey 
				 where A.EffectiveFromTimeKey <=@Timekey
					   AND A.EffectiveToTimeKey >= @Timekey 
					   AND A.AuthorisationStatus='A'
		 	    AND A.AccountEntityID=@InvestmentAccountEntityID
				and C.iNVID=@ACID
				UNION
				select distinct C.DerivativeRefNo as ACID
					   ,C.CustomerId RefCustomerId
					   ,C.CustomerName
					   ,C.UCIC_ID as UCICID
					    ,case when isnull(A.AuthorisationStatus,'') IN ('MP','NP')
					         then '1st Approval Pending'
					         when isnull(A.AuthorisationStatus,'') IN ('1A')
							 Then '2nd Approval Pending'
					         
							 when isnull(A.AuthorisationStatus,'') IN ('A')
							 Then 'Authorised'
							 else 'No MOC Done' End As AuthorisationStatus 
						,Convert(Varchar(10),@ExtDate,103) As MOCMonthEndDate
					   ,'CalypsoAccountLevel' as TableName
					   ,Row_Number()over (order by (select 1)) RowNumber 
				 from CalypsoDervMOC_ChangeDetails A
				 INNER JOIN curdat.DerivativeDetail C ON C.DerivativeEntityID=A.AccountEntityID  
				 AND  C.EffectiveFromTimeKey<=@Timekey
					   AND C.EffectiveToTimeKey >= @Timekey 
				 where A.EffectiveFromTimeKey <=@Timekey
					   AND A.EffectiveToTimeKey >= @Timekey 
					   AND A.AuthorisationStatus='A'
		 	    AND A.AccountEntityID=@DerivativeAccountEntityID
				and C.DerivativeRefNo=@ACID
END	
		
 ELSE IF EXISTS (SELECT 1 FROM CalypsoAccountLevelMOC_Mod WHERE AccountEntityID =@InvestmentAccountEntityID  AND EffectiveFromTimeKey<=@Timekey
					                    AND EffectiveToTimeKey >= @Timekey  AND AuthorisationStatus IN ('MP','NP','1A')
										UNION
										SELECT 1 FROM CalypsoAccountLevelMOC_Mod WHERE AccountEntityID =@DerivativeAccountEntityID  AND EffectiveFromTimeKey<=@Timekey
					                    AND EffectiveToTimeKey >= @Timekey  AND AuthorisationStatus IN ('MP','NP','1A'))
BEGIN     	
PRINT 'SWAPNA 4'
            select A.AccountID as ACID
					   ,C.IssuerID RefCustomerId
					   ,C.IssuerName as CustomerName
					   ,C.UcifId as UCICID
					   ,case when isnull(A.AuthorisationStatus,'') IN ('MP','NP')
					         then '1st Approval Pending'
					         when isnull(A.AuthorisationStatus,'') IN ('1A')
							 Then '2nd Approval Pending'
					         
							 when isnull(A.AuthorisationStatus,'') IN ('A')
							 Then 'Authorised'
							 else 'No MOC Done' End As AuthorisationStatus 
						,Convert(Varchar(10),@ExtDate,103) As MOCMonthEndDate
					   ,'CalypsoAccountLevel' as TableName
					    ,Row_Number()over (order by (select 1)) RowNumber 
				 from CalypsoAccountlevelmoc_mod A
				   --     inner join Pro.accountcal_Hist C ON C.CustomerAcID=A.AccountID
						 --inner join Pro.customercal_hist B
						 INNER JOIN InvestmentBasicDetail B

						                 ON A.AccountID=B.InvId
						                 AND B.EffectiveFromTimeKey <= @Timekey
						                 AND B.EffectiveToTimeKey >= @Timekey
						INNER JOIN InvestmentIssuerDetail C
						 ON B.IssuerEntityId=C.IssuerEntityId
						                 AND C.EffectiveFromTimeKey <= @Timekey
						                 AND C.EffectiveToTimeKey >= @Timekey
				 Where A.EffectiveFromTimeKey <= @Timekey
					   AND A.EffectiveToTimeKey >= @Timekey
					    AND ISNULL(A.AuthorisationStatus, 'A') IN ('MP','NP','1A')
						AND ISNULL(A.ScreenFlag,'S') NOT IN('U')
					AND A.AccountEntityID=@InvestmentAccountEntityID
						AND A.AccountID =@ACID
				UNION

				
            select A.AccountID as ACID
					   ,B.CustomerId RefCustomerId
					   ,B.CustomerName
					   ,B.UCIC_ID as UCICID
					   ,case when isnull(A.AuthorisationStatus,'') IN ('MP','NP')
					         then '1st Approval Pending'
					         when isnull(A.AuthorisationStatus,'') IN ('1A')
							 Then '2nd Approval Pending'
					         
							 when isnull(A.AuthorisationStatus,'') IN ('A')
							 Then 'Authorised'
							 else 'No MOC Done' End As AuthorisationStatus 
						,Convert(Varchar(10),@ExtDate,103) As MOCMonthEndDate
					   ,'CalypsoAccountLevel' as TableName
					    ,Row_Number()over (order by (select 1)) RowNumber 
				 from CalypsoAccountLevelMOC_Mod A
				   --     inner join Pro.accountcal_Hist C ON C.CustomerAcID=A.AccountID
						 --inner join Pro.customercal_hist B
						 INNER JOIN curdat.DerivativeDetail B

						                 ON A.AccountID=B.DerivativeRefNo
						                 AND B.EffectiveFromTimeKey <= @Timekey
						                 AND B.EffectiveToTimeKey >= @Timekey
						
				 Where A.EffectiveFromTimeKey <= @Timekey
					   AND A.EffectiveToTimeKey >= @Timekey
					    AND ISNULL(A.AuthorisationStatus, 'A') IN ('MP','NP','1A')
						AND ISNULL(A.ScreenFlag,'S') NOT IN('U')
						AND A.AccountEntityID=@DerivativeAccountEntityID
						AND A.AccountID =@ACID
END
ELSE 
BEGIN
PRINT 'AKSHAY3'
select distinct    B.InvID  ACID
                       , C.IssuerID RefCustomerId
					   ,C.IssuerName CustomerName
					   ,C.UcifId as UCICID

					 --  ,'No MOC Done' AuthorisationStatus 

					 ,case when isnull(B.AuthorisationStatus,'') IN ('MP','NP')
					         then '1st Approval Pending'
					         when isnull(B.AuthorisationStatus,'') IN ('1A')
							 Then '2nd Approval Pending'
					         
							 when isnull(B.AuthorisationStatus,'') IN ('A')
							 Then 'Authorised'
							 else 'No MOC Done' End As AuthorisationStatus 
					   ,'CalypsoAccountLevel' as TableName
					   ,Convert(Varchar(10),@ExtDate,103) As MOCMonthEndDate
				 from  InvestmentBasicDetail B
						INNER JOIN InvestmentIssuerDetail C
						 ON B.IssuerEntityId=C.IssuerEntityId
						   AND C.EffectiveFromTimeKey <= @Timekey
						                 AND C.EffectiveToTimeKey >= @Timekey  
				 where     B.EffectiveFromTimeKey<=@Timekey
					   AND B.EffectiveToTimeKey >= @Timekey 
					--AND    B.InvEntityId=@AccountEntityID
					AND b.InvID =@ACID
UNION
select distinct    B.DerivativeRefNo  ACID
                       , B.CustomerID RefCustomerId
					   ,B.CustomerName
					   ,B.UCIC_ID as UCICID
					   --,'No MOC Done' AuthorisationStatus 
					    ,case when isnull(B.AuthorisationStatus,'') IN ('MP','NP')
					         then '1st Approval Pending'
					         when isnull(B.AuthorisationStatus,'') IN ('1A')
							 Then '2nd Approval Pending'
					         
							 when isnull(B.AuthorisationStatus,'') IN ('A')
							 Then 'Authorised'
							 else 'No MOC Done' End As AuthorisationStatus 
					   ,'CalypsoAccountLevel' as TableName
					   ,Convert(Varchar(10),@ExtDate,103) As MOCMonthEndDate
				 from  curdat.DerivativeDetail B
				 where     B.EffectiveFromTimeKey<=@Timekey
					   AND B.EffectiveToTimeKey >= @Timekey 
					--AND    B.DerivativeEntityID=@AccountEntityID
					AND B.DerivativeRefNo  =@ACID

END


 END

 END
END
GO