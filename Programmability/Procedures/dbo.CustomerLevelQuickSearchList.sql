SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO




--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--USE [USFB_ENPADB]
--GO
--/****** Object:  StoredProcedure [dbo].[CustomerLevelQuickSearchList]    Script Date: 18-11-2021 13:33:01 ******/
--DROP PROCEDURE [dbo].[CustomerLevelQuickSearchList]
--GO
--/****** Object:  StoredProcedure [dbo].[CustomerLevelQuickSearchList]    Script Date: 18-11-2021 13:33:01 ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO
--exec CustomerLevelQuickSearchList @CustomerId=N'22552793',@CustomerName=N'',@UCICID=N'',@OperationFlag=2,@newPage=1,@pageSize=1000
--go

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------




---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------




CREATE PROC [dbo].[CustomerLevelQuickSearchList]
--declare
					@CustomerId VARCHAR(20)=''
					,@CustomerName VARCHAR(100)=''
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

	Declare @ExtDate Date
	SET @Timekey =(Select Timekey from SysDataMatrix Where ISNULL(MOC_Initialised,'N')='Y' AND ISNULL(MOC_Frozen,'N')='N') 

	SET @ExtDate=(Select Distinct ExtDate from SysDataMatrix Where ISNULL(MOC_Initialised,'N')='Y' AND ISNULL(MOC_Frozen,'N')='N') 
	
		print @Timekey
		---select customerid and auth status
	--	Drop Table  IF Exists #Temp

	
	--	select A.CustomerID,AuthorisationStatus into #Temp 
	--	from Customerlevelmoc_mod  A
	--	inner join(
	
	--SELECT MAX(Entity_Key) Entity_Key,CustomerID
 --                                        FROM Customerlevelmoc_mod
 --                                         WHERE EffectiveFromTimeKey <= @Timekey
 --                                             AND EffectiveToTimeKey >= @Timekey --AND ISNULL(ScreenFlag,'U') NOT IN('U','')
                             
 --                                     GROUP BY CustomerID) B on B.Entity_Key=A.Entity_Key 

	----Select '#Temp',* from #Temp
	IF (@CustomerId ='' OR @CustomerId IS NULL) 
	  
	  begin

		 if (@operationflag not in(16,20))
		BEGIN
		print '111'
		PRINT'54'


		--		DROP TABLE IF EXISTS #TEmp

		--select A.CustomerEntityID,AuthorisationStatus into #Temp from CustomerLevelMOC_Mod A
		--inner join(
		--select max(Entity_Key) EntityKey,CustomerEntityID 
		--                                 from CustomerLevelMOC_Mod
		--                                 where EffectiveFromTimeKey<=@Timekey and EffectiveToTimeKey>=@Timekey
		--								 group by CustomerEntityID)B on B.EntityKey=A.Entity_Key
										 
		select distinct T.CustomerID CustomerId
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
					   ,'CustomerLevel' as TableName
				 from MOC_ChangeDetails A
				  --inner join Customerlevelmoc_mod B ON B.CustomerID=A.RefCustomerID
				 INNER  JOIN CustomerBasicDetail  T  ON T.CustomerEntityId=A.CustomerEntityID AND  T.EffectiveFromTimeKey<=@Timekey
					   AND T.EffectiveToTimeKey >= @Timekey 
				 where A.EffectiveFromTimeKey<=@Timekey
					   AND A.EffectiveToTimeKey >= @Timekey
					   AND A.MOCType_Flag='CUST'
					   AND A.AuthorisationStatus='A'
					   AND  A.CustomerEntityID NOT IN (SELECT CustomerEntityId FROM CustomerLevelMOC_Mod 
					                                   WHERE AuthorisationStatus IN ('MP','NP','1A')
													   AND EffectiveFromTimeKey<=@Timekey
					                                   AND EffectiveToTimeKey >= @Timekey )
					 -- AND ISNULL(ScreenFlag,'U') NOT IN('U','')
				
	             UNION

				     	
		select distinct T.CustomerID CustomerId
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
					   ,'CustomerLevel' as TableName
				 from CustomerLevelMOC_Mod A
				  --inner join Customerlevelmoc_mod B ON B.CustomerID=A.RefCustomerID
				 INNER JOIN CustomerBasicDetail  T  ON T.CustomerEntityId=A.CustomerEntityID AND                                                   
				 T.EffectiveFromTimeKey<=@Timekey
					   AND T.EffectiveToTimeKey >= @Timekey 

			 --LEFT JOIN #TEmp C on C.CustomerEntityID=A.CustomerEntityID
				 where A.EffectiveFromTimeKey<=@Timekey
					   AND A.EffectiveToTimeKey >= @Timekey 
					  AND A.AuthorisationStatus IN ('MP','NP','1A')
					AND A.MOCType_Flag='CUST'
				
			--	select * from (
			--select distinct 
			--		   B.CustomerId
			--		   ,B.CustomerName
			--		   ,B.UCIF_ID as UCICID
			--		    ,case when C.AuthorisationStatus IN ('FM','MP','NP')
			--		         then 'Pending'
			--				 when C.AuthorisationStatus IN ('A','R')
			--				 Then 'Authorise'
			--				 else 'No MOC Done ' End As AuthorisationStatus 
			--		   ,'CustomerLevel' as TableName
			--		   ,Row_Number()over (order by (select 1)) RowNumber 
			--	 from MOC_ChangeDetails A
			--			 --inner join Pro.customercal_hist B ON A.CustomerEntityId=B.CustomerEntityId 
			--			 inner join CURDAT.CustomerBasicDetail B ON A.CustomerEntityId=B.CustomerEntityId 
			--			 AND B.EffectiveFromTimeKey <= @Timekey AND B.EffectiveToTimeKey >= @Timekey
			--			 --INNER JOIN Accountlevelmoc_mod C ON C.AccountID=A.CustomerAcID
			--			 LEFT JOIN #TEmp C on C.CustomerEntityID=A.CustomerEntityID
		 	


			--	 Where A.EffectiveFromTimeKey <= @Timekey
			--		   AND A.EffectiveToTimeKey >= @Timekey
			--		   --and C.EffectiveFromTimeKey <= @Timekey
			--		   --AND c.EffectiveToTimeKey >= @Timekey
			--		   ) A




	
	
END


		IF (@OperationFlag in (16))
		BEGIN
			print '113'
				     	
		select distinct T.CustomerID CustomerId
					   ,T.CustomerName
					   ,T.UCIF_ID as UCICID
					   ,case when isnull(A.AuthorisationStatus,'') IN ('FM','MP','NP')
					         then 'Pending'
					         when isnull(A.AuthorisationStatus,'') IN ('1A')
							 Then '2nd Approval Pending'
					         
							 when isnull(A.AuthorisationStatus,'') IN ('A','R')
							 Then 'Authorised'
							 else 'No MOC Done' End As AuthorisationStatus 
							 ,Convert(Varchar(10),@ExtDate,103) As MOCMonthEndDate
					   ,'CustomerLevel' as TableName
				 from CustomerLevelMOC_Mod A
				  --inner join Customerlevelmoc_mod B ON B.CustomerID=A.RefCustomerID
				 INNER JOIN CustomerBasicDetail  T  ON T.CustomerEntityId=A.CustomerEntityID AND  T.EffectiveFromTimeKey<=@Timekey
					   AND T.EffectiveToTimeKey >= @Timekey 
				 where A.EffectiveFromTimeKey<=@Timekey
					   AND A.EffectiveToTimeKey >= @Timekey 
					  AND A.AuthorisationStatus IN ('MP','NP','DP','RM')
					  AND A.MOCType_Flag='CUST'
		END

		IF (@OperationFlag in (20))
		BEGIN
			print '114'
					     	
		select distinct T.CustomerID CustomerId
					   ,T.CustomerName
					   ,T.UCIF_ID as UCICID
					   ,case when isnull(A.AuthorisationStatus,'') IN ('FM','MP','NP')
					         then 'Pending'
					         when isnull(A.AuthorisationStatus,'') IN ('1A')
							 Then '2nd Approval Pending'
					         
							 when isnull(A.AuthorisationStatus,'') IN ('A','R')
							 Then 'Authorised'
							 else 'No MOC Done' End As AuthorisationStatus 
							 ,Convert(Varchar(10),@ExtDate,103) As MOCMonthEndDate
					   ,'CustomerLevel' as TableName
				 from CustomerLevelMOC_Mod A
				  --inner join Customerlevelmoc_mod B ON B.CustomerID=A.RefCustomerID
				 INNER JOIN CustomerBasicDetail  T  ON T.CustomerEntityId=A.CustomerEntityID AND  T.EffectiveFromTimeKey<=@Timekey
					   AND T.EffectiveToTimeKey >= @Timekey 
				 where A.EffectiveFromTimeKey<=@Timekey
					   AND A.EffectiveToTimeKey >= @Timekey 
					  AND A.AuthorisationStatus IN ('1A')
					  AND A.MOCType_Flag='CUST'
		END

	END


 ELSE
       Begin
	   DECLARE @CustomerEntityID INT
	   SET  @CustomerEntityID =(SELECT CustomerEntityID  FROM   CURDAT.CustomerBasicDetail A
												WHERE CustomerId=@CustomerId  AND A.EffectiveFromTimeKey<=@Timekey
					                    AND A.EffectiveToTimeKey >= @Timekey)

	
	   PRINT 'Sac1'

	    if (@operationflag not in(16,20)) AND(@CustomerId<>'' OR @CustomerId<>NULL)
		Begin
		   IF EXISTS (SELECT 1 FROM MOC_ChangeDetails WHERE CustomerEntityID =@CustomerEntityID  AND EffectiveFromTimeKey<=@Timekey
					                    AND EffectiveToTimeKey >= @Timekey  AND AuthorisationStatus='A')

		BEGIN
		print '111'
		PRINT  '45'
		select distinct T.CustomerID CustomerId
					   ,T.CustomerName
					   ,T.UCIF_ID as UCICID
					   ,case when isnull(A.AuthorisationStatus,'') IN ('FM','MP','NP')
					         then 'Pending'
					         when isnull(A.AuthorisationStatus,'') IN ('1A')
							 Then '2nd Approval Pending'
					         
							 when isnull(A.AuthorisationStatus,'') IN ('A','R')
							 Then 'Authorised'
							 else 'No MOC Done' End As AuthorisationStatus 
							 ,Convert(Varchar(10),@ExtDate,103) As MOCMonthEndDate
					   ,'CustomerLevel' as TableName
				 from MOC_ChangeDetails A
				  --inner join Customerlevelmoc_mod B ON B.CustomerID=A.RefCustomerID
				 INNER  JOIN CustomerBasicDetail  T  ON T.CustomerEntityId=A.CustomerEntityID
				 AND  T.EffectiveFromTimeKey<=@Timekey
					   AND T.EffectiveToTimeKey >= @Timekey 
				 where A.EffectiveFromTimeKey<=@Timekey
					   AND A.EffectiveToTimeKey >= @Timekey 
					   AND A.AuthorisationStatus='A'
					   AND A.MOCType_Flag='CUST'
					   AND T.CustomerId=@CustomerId
					 --  AND ISNULL(ScreenFlag,'U') NOT IN('U','')
			END	
		
 ELSE IF EXISTS (SELECT 1 FROM CustomerLevelMOC_Mod WHERE CustomerEntityID =@CustomerEntityID  AND EffectiveFromTimeKey<=@Timekey
					                    AND EffectiveToTimeKey >= @Timekey  AND AuthorisationStatus IN ('MP','NP','1A'))
BEGIN     	

 PRINT 'Sac2'
		select distinct T.CustomerID CustomerId
					   ,T.CustomerName
					   ,T.UCIF_ID as UCICID
					   ,case when isnull(A.AuthorisationStatus,'') IN ('FM','MP','NP')
					         then 'Pending'
					         when isnull(A.AuthorisationStatus,'') IN ('1A')
							 Then '2nd Approval Pending'
					         
							 when isnull(A.AuthorisationStatus,'') IN ('A','R')
							 Then 'Authorised'
							 else 'No MOC Done' End As AuthorisationStatus 
							 ,Convert(Varchar(10),@ExtDate,103) As MOCMonthEndDate
					   ,'CustomerLevel' as TableName
				 from CustomerLevelMOC_Mod A
				  --inner join Customerlevelmoc_mod B ON B.CustomerID=A.RefCustomerID
				 INNER JOIN CustomerBasicDetail  T  ON T.CustomerEntityId=A.CustomerEntityID 
				 AND  T.EffectiveFromTimeKey<=@Timekey
					   AND T.EffectiveToTimeKey >= @Timekey 
				 where A.EffectiveFromTimeKey<=@Timekey
					   AND A.EffectiveToTimeKey >= @Timekey 
					  AND A.AuthorisationStatus IN ('MP','NP','1A')
					  AND A.MOCType_Flag='CUST'
					AND A.CustomerId=@CustomerId

END
ELSE 
BEGIN


 PRINT 'Sac3'
select distinct T.CustomerID CustomerId
					   ,T.CustomerName
					   ,T.UCIF_ID as UCICID
					   ,'No MOC Done' AuthorisationStatus 
					   ,'CustomerLevel' as TableName
					   	   ,Convert(Varchar(10),@ExtDate,103) As MOCMonthEndDate 
				 from CustomerBasicDetail  T  
				 where T.EffectiveFromTimeKey<=@Timekey
					   AND T.EffectiveToTimeKey >= @Timekey 
					AND T.CustomerId=@CustomerId

END
	END
END
END
GO