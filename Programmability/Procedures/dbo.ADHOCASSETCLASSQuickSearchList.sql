SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



/****** Object:  StoredProcedure [dbo].[ADHOCASSETCLASSQuickSearchList]    Script Date: 11-12-2021 14:56:45 ******/



CREATE PROC [dbo].[ADHOCASSETCLASSQuickSearchList]
--declare
					@CustomerId VARCHAR(20)=''
					
				
					,@UCICID VARCHAR(12)=''
					,@OperationFlag INT=1

					,@newPage SMALLINT =1     
					,@pageSize INT = 30000 
					
AS
	BEGIN

	Declare @Timekey INT

DECLARE @PageFrom INT, @PageTo INT   
  
SET @PageFrom = (@pageSize*@newPage)-(@pageSize) +1  
SET @PageTo = @pageSize*@newPage  


	Set @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C') 


	IF  @OperationFlag  not in(16,20)
		BEGIN

				  
				  select distinct 
					   A.CUSTOMERid as CustomerId
					   ,A.CustomerName
					   ,A.UCIF_ID as UCICID

					   ,case when isnull(B.AuthorisationStatus,'') IN ('MP','NP')
					         then 'MP'
					         when isnull(B.AuthorisationStatus,'') IN ('1A')
							 Then '1A'
					         
							 when isnull(B.AuthorisationStatus,'') IN ('A')
							 Then 'A'
							 else 'No MOC Done' End 
							 As AuthorisationStatus 

						,case when isnull(B.AuthorisationStatus,'') IN ('MP','NP')
					         then '1st Approval Pending'

					         when isnull(B.AuthorisationStatus,'') IN ('1A')
							 Then '2nd Approval Pending'
							 
							 when isnull(B.AuthorisationStatus,'') IN ('A')
							 Then 'Authorised'
							 else 'No MOC Done' End 
							 As AuthorisationStatusDesc

					   ,'CustomerLevel' as TableName

					 --,Z.CreatedBy 
					 --,Z.DateCreated
						--	,Z.ApprovedBy
						--	,Z.DateApproved
						--	,Z.ModifyBy
						--	,Z.DateModified
						--	,Z.FirstLevelApprovedBy
						--	,Z.FirstLevelDateApproved

						   ,IsNull(B.ModifyBy,B.CreatedBy)as CrModBy
							,IsNull(B.DateModified,B.DateCreated)as CrModDate
							,ISNULL(B.FirstLevelApprovedBy,B.CreatedBy) as CrAppBy
							,ISNULL(B.FirstLevelDateApproved,B.DateCreated) as CrAppDate
							,ISNULL(B.FirstLevelApprovedBy,B.ModifyBy) as ModAppBy
							,ISNULL(B.FirstLevelDateApproved,B.DateModified) as ModAppDate
							 ,B.ChangeFields
							 ,b.EntityKey
				             from curdat.CustomerBasicDetail  A  
			Left JOIN AdhocACL_ChangeDetails_MOD B ON A.CUSTOMERid=B.CustomerID and B.EffectiveFromTimeKey<=@Timekey
					   AND B.EffectiveToTimeKey >= @Timekey AND B.AuthorisationStatus IN ('MP','NP','1A','A')
				 WHERE (--(A.CUSTOMERid=@CustomerId)   or  (A.UCIF_ID=@UCICID))AND  
				         A.EffectiveFromTimeKey <= @TimeKey
                               AND A.EffectiveToTimeKey >= @TimeKey
							   AND @OperationFlag NOT IN (16,17,20)
							   AND (
							   A.CUSTOMERid = CASE WHEN @CustomerID<>'' THEN @CustomerID ELSE A.CUSTOMERid END                    ----------------Newly added filter by kapil 04/01/2023
									AND (A.UCIF_ID LIKE CASE WHEN @UCICID<>'' THEN @UCICID ELSE A.UCIF_ID END))                 ----------------Newly added filter by kapil 04/01/2023
								
								)   

                                    order by b.EntityKey desc
			   END
	
	  IF (@OperationFlag in (16))

	    BEGIN
			Print 'b'



	             	select distinct A.CustomerID CustomerId,CH.CustomerName
					
					   ,A.UCIF_ID as UCICID
					   ,case when isnull(A.AuthorisationStatus,'') IN ('MP','NP')
					         then 'MP'
					         when isnull(A.AuthorisationStatus,'') IN ('1A')
							 Then '1A'
					         
							 when isnull(A.AuthorisationStatus,'') IN ('A')
							 Then 'A'
							 else 'No MOC Done' End As AuthorisationStatus 

						,case when isnull(A.AuthorisationStatus,'') IN ('MP','NP')
					         then '1st Approval Pending'
					         when isnull(A.AuthorisationStatus,'') IN ('1A')
							 Then '2nd Approval Pending'
					         
							 when isnull(A.AuthorisationStatus,'') IN ('A')
							 Then 'Authorised'
							 else 'No MOC Done' End As AuthorisationStatusDesc

					   ,'CustomerLevel' as TableName
					       ,IsNull(A.ModifyBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.FirstLevelApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.FirstLevelDateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.FirstLevelApprovedBy,A.ModifyBy) as ModAppBy
							,ISNULL(A.FirstLevelDateApproved,A.DateModified) as ModAppDate
							,A.FirstLevelApprovedBy
							,A.FirstLevelDateApproved
					        ,A.ChangeFields
							,A.EntityKey
				 from AdhocACL_ChangeDetails_MOD A 
				 LEFT JOIN curdat.CustomerBasicDetail CH
				ON A.CustomerID=CH.CustomerID 
				and CH.EffectiveFromTimeKey<=@Timekey
					   AND CH.EffectiveToTimeKey >= @Timekey
				 where A.EffectiveFromTimeKey<=@Timekey
					   AND A.EffectiveToTimeKey >= @Timekey
					AND ISNULL(A.AuthorisationStatus,'A') IN ('NP','MP')
					AND  ( A.CUSTOMERid = CASE WHEN @CustomerID<>'' THEN @CustomerID ELSE A.CUSTOMERid END                    ----------------Newly added filter by kapil 04/01/2023
									AND (A.UCIF_ID LIKE CASE WHEN @UCICID<>'' THEN @UCICID ELSE A.UCIF_ID END))  
									order by a.EntityKey desc
								         	
									

	       
		   END

		   
	  IF (@OperationFlag in (20))

	    BEGIN
			Print 'c'
	             	select distinct A.CustomerID CustomerId,CH.CustomerName
					
					   ,A.UCIF_ID as UCICID
					   ,case when isnull(A.AuthorisationStatus,'') IN ('MP','NP')
					         then 'MP'
					         when isnull(A.AuthorisationStatus,'') IN ('1A')
							 Then '1A'
					         
							 when isnull(A.AuthorisationStatus,'') IN ('A')
							 Then 'A'
							 else 'No MOC Done' End As AuthorisationStatus 

						,case when isnull(A.AuthorisationStatus,'') IN ('MP','NP')
					         then '1st Approval Pending'
					         when isnull(A.AuthorisationStatus,'') IN ('1A')
							 Then '2nd Approval Pending'
					         
							 when isnull(A.AuthorisationStatus,'') IN ('A')
							 Then 'Authorised'
							 else 'No MOC Done' End As AuthorisationStatusDesc

					   ,'CustomerLevel' as TableName
					      ,IsNull(A.ModifyBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.FirstLevelApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.FirstLevelDateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.FirstLevelApprovedBy,A.ModifyBy) as ModAppBy
							,ISNULL(A.FirstLevelDateApproved,A.DateModified) as ModAppDate
							,A.FirstLevelApprovedBy
							,A.FirstLevelDateApproved
					         ,A.ChangeFields
							 ,A.EntityKey
				 from AdhocACL_ChangeDetails_MOD A 
				 LEFT JOIN curdat.CustomerBasicDetail CH
				ON A.CustomerID=CH.CustomerID and CH.EffectiveFromTimeKey<=@Timekey
					   AND CH.EffectiveToTimeKey >= @Timekey
				 where A.EffectiveFromTimeKey<=@Timekey
					   AND A.EffectiveToTimeKey >= @Timekey
					AND ISNULL(A.AuthorisationStatus,'A') IN ('1A')
					AND  ( A.CUSTOMERid = CASE WHEN @CustomerID<>'' THEN @CustomerID ELSE A.CUSTOMERid END                    ----------------Newly added filter by kapil 04/01/2023
						AND (A.UCIF_ID LIKE CASE WHEN @UCICID<>'' THEN @UCICID ELSE A.UCIF_ID END))
	                      order by a.EntityKey desc
		   END

	END
GO