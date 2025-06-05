SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



--exec [AdhocAccountLevelSearchList] @OperationFlag=16, @UCIF_ID=N'9987801'
--go

CREATE PROC [dbo].[AdhocAccountLevelSearchList]

--Declare

												

												--@PageNo         INT         = 1, 

													--@PageSize       INT         = 10, 

							

													

													--@PageNo         INT         = 1, 

													--@PageSize       INT         = 10, 

													@OperationFlag  INT        ,

													@UCIF_ID	varchar(30)		,

													@TimeKey INT                =25992

													--@SourceSystem   varchar(20)   = ''

AS

    --25999 

	 BEGIN



SET NOCOUNT ON;



 

 SET @Timekey =(Select TimeKey from SysDataMatrix where CurrentStatus='C') 


 DROP TABLE IF EXISTS #CUSTOMERCAL_HIST

 SELECT * INTO #CUSTOMERCAL_HIST FROM PRO.CUSTOMERCAL_HIST 
              WHERE UCIF_ID=@UCIF_ID AND EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey
 
Declare @RecordinMAIN Int
Declare @RecordinMOD Int  	

SElect @RecordinMAIN= Count(1)  from [AdhocACL_ChangeDetails] E
		where  E.EffectiveFromTimeKey<=@TimeKey and E.EffectiveToTimeKey>=@TimeKey

	AND E.AuthorisationStatus in('A')

	and  E.UCIF_ID=@UCIF_ID

SElect @RecordinMOD= Count(1)  from [AdhocACL_ChangeDetails_MOD] E
		where  E.EffectiveFromTimeKey<=@TimeKey and E.EffectiveToTimeKey>=@TimeKey

	AND E.AuthorisationStatus in('MP')

	and  E.UCIF_ID=@UCIF_ID


	PRINT '@RecordinMAIN'
	PRINT @RecordinMAIN
	
	PRINT '@RecordinMOD'
	PRINT @RecordinMOD

BEGIN TRY

/*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */

BEGIN




IF @OperationFlag NOT IN (16,20)

IF(@RecordinMAIN=1 AND @RecordinMOD=0)

BEGIN

   	select *INTO #tmp21 from ( select

			  C.UCIF_ID  as UCICID_Existing
			 ,C.AssetClassAlt_Key as AssetClassAlt_Key_Existing
			,C.NPA_Date AS NPADate_Existing
			,L.ParameterName AS MOCReason_Existing
		   ,Row_Number()over (partition by C.UCIF_ID order by  C.UCIF_ID desc) RowNumber
			,D.AssetClassName as AssetClass_Existing
			,c.ChangeType
			--ChangeType
			
			--INTO #tmp


			from [dbo].[AdhocACL_ChangeDetails] C
	
			LEFT JOIN DimAssetClass D

					ON D.AssetClassAlt_Key=C.AssetClassAlt_Key

			LEFT Join (

						Select  ParameterAlt_Key,ParameterName,'ModeOfOperationMaster' as Tablename 
						from DimParameter where DimParameterName='DimMoRreason'
						And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)L
						ON L.ParameterAlt_Key=c.Reason

			Left join 	   
 
             DimParameter cd    ON cd.ParameterAlt_Key=c.ChangeType and cd.DimParameterName='MOCType'
			And  cd.EffectiveFromTimeKey<=@Timekey And cd.EffectiveToTimeKey>=@Timekey 
		
			where  C.EffectiveFromTimeKey<=@TimeKey and C.EffectiveToTimeKey>=@TimeKey

			AND C.AuthorisationStatus in('A')

			and  C.UCIF_ID=@UCIF_ID
			) C
			where RowNumber=1

			order by C.UCICID_Existing desc

			Select * from #tmp21

END

IF(@RecordinMAIN=1 AND @RecordinMOD=1)

BEGIN

BEGIN

   	select *INTO #tmp22 from ( select

			  C.UCIF_ID  as UCICID_Existing
			 ,C.AssetClassAlt_Key as AssetClassAlt_Key_Existing
			,C.NPA_Date AS NPADate_Existing
			,L.ParameterName AS MOCReason_Existing
		   ,Row_Number()over (partition by C.UCIF_ID order by  C.UCIF_ID desc) RowNumber
			,D.AssetClassName as AssetClass_Existing
			
			,F.AssetClassName as AssetClass_Modified
	 ,E.AssetClassAlt_Key as AssetClassAlt_Key_Modified
	 ,E.NPA_Date as NPADate_Modified --NPA_Date_Pos
	 ,M.ParameterName AS MOCReason_Modified
	 ,c.ChangeType
			--INTO #tmp


			from [dbo].[AdhocACL_ChangeDetails] C
	
			LEFT JOIN DimAssetClass D

					ON D.AssetClassAlt_Key=C.AssetClassAlt_Key
	
	LEFT JOIN AdhocACL_ChangeDetails_MOD E

		ON C.UCIF_ID=E.UCIF_ID

		
	LEFT JOIN DimAssetClass F

		ON E.AssetClassAlt_Key=F.AssetClassAlt_Key

			LEFT Join (

						Select  ParameterAlt_Key,ParameterName,'ModeOfOperationMaster' as Tablename 
						from DimParameter where DimParameterName='DimMoRreason'
						And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)L
						ON L.ParameterAlt_Key=c.Reason
		LEFT Join (

						Select  ParameterAlt_Key,ParameterName,'ModeOfOperationMaster' as Tablename 
						from DimParameter where DimParameterName='DimMoRreason'
						And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)M
						ON M.ParameterAlt_Key=E.Reason
							   
 
           Left join   DimParameter cd    ON cd.ParameterAlt_Key=c.ChangeType and cd.DimParameterName='MOCType'
			And  cd.EffectiveFromTimeKey<=@Timekey And cd.EffectiveToTimeKey>=@Timekey 

			where  C.EffectiveFromTimeKey<=@TimeKey and C.EffectiveToTimeKey>=@TimeKey

			AND C.AuthorisationStatus in('A')
			AND C.AuthorisationStatus in('MP')

			and  C.UCIF_ID=@UCIF_ID
			) C
			where RowNumber=1

			order by C.UCICID_Existing desc

			Select * from #tmp22

END

END


IF (@RecordinMOD=1 AND @OperationFlag=2)

BEGIN

PRINT 'MohitPRE'

		select *from  (select

	A. UCIF_ID as UCICID_Existing
	 ,A.SysAssetClassAlt_Key AssetClassAlt_Key_Existing
	 ,case when ( A.SysNPA_Dt='' or A.SysNPA_Dt='01/01/1900' or A.SysNPA_Dt='1900/01/01')
	                            then NULL ELSE A.SysNPA_Dt END  NPADate_Existing
	 ,A.DegReason Reason_Existing
	 ,L.ParameterName AS MOCReason_Existing
	 ,A.CustomerName
	 ,Row_Number()over (partition by A.UCIF_ID order by  A.UCIF_ID desc) RowNumber
	 
	 

	 ,B.AssetClassName AssetClass_Existing
	 ,F.AssetClassName as AssetClass_Modified
	 ,E.AssetClassAlt_Key as AssetClassAlt_Key_Modified
	 ,E.NPA_Date as NPADate_Modified --NPA_Date_Pos
	 ,E.Reason AS Reason_Modified
	 ,c.ChangeType
	 
	 
	 from #CUSTOMERCAL_HIST A
	 
	LEFT JOIN DimAssetClass B

		ON B.AssetClassAlt_Key=A.SysAssetClassAlt_Key

			
		LEFT JOIN AdhocACL_ChangeDetails C

		ON C.UCIF_ID=A.UCIF_ID

		
	LEFT JOIN DimAssetClass D

		ON D.AssetClassAlt_Key=C.AssetClassAlt_Key

		LEFT JOIN AdhocACL_ChangeDetails_MOD E

		ON E.UCIF_ID=A.UCIF_ID

		
	LEFT JOIN DimAssetClass F

		ON E.AssetClassAlt_Key=F.AssetClassAlt_Key

	LEFT Join (

						Select  ParameterAlt_Key,ParameterName,'ModeOfOperationMaster' as Tablename 
						from DimParameter where DimParameterName='DimMoRreason'
						And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)L
						ON L.ParameterAlt_Key=c.Reason
	--LEFT Join (

	--					Select  ParameterAlt_Key,ParameterName,'ModeOfOperationMaster' as Tablename 
	--					from DimParameter where DimParameterName='DimMoRreason'
	--					And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)M
	--					ON M.ParameterAlt_Key=E.Reason

	           Left join   DimParameter cd    ON cd.ParameterAlt_Key=c.ChangeType and cd.DimParameterName='MOCType'
			And  cd.EffectiveFromTimeKey<=@Timekey And cd.EffectiveToTimeKey>=@Timekey 
	
	 where A.EffectiveFromTimeKey<=@TimeKey and A.EffectiveToTimeKey>=@TimeKey
	 and A.UCIF_ID=@UCIF_ID
	 and E.AuthorisationStatus='MP'

	 	 )A
	 Where RowNumber=1
	 order by 	A.UCICID_Existing desc


	END
	ELSE IF (@RecordinMOD=0 AND @OperationFlag=2)
	BEGIN

PRINT 'MohitPOST'

		select *from  (select

	A. UCIF_ID as UCICID_Existing
	 ,A.SysAssetClassAlt_Key AssetClassAlt_Key_Existing
	 ,case when ( A.SysNPA_Dt='' or A.SysNPA_Dt='01/01/1900' or A.SysNPA_Dt='1900/01/01')
	                            then NULL ELSE A.SysNPA_Dt END  NPADate_Existing
	 ,A.DegReason Reason_Existing
	 ,L.ParameterName AS MOCReason_Existing
	 ,A.CustomerName
	 ,Row_Number()over (partition by A.UCIF_ID order by  A.UCIF_ID desc) RowNumber
	 
	 

	 ,B.AssetClassName AssetClass_Existing
	 ,c.ChangeType
	 --,F.AssetClassName as AssetClass_Modified
	 --,E.AssetClassAlt_Key as AssetClassAlt_Key_Modified
	 --,E.NPA_Date as NPADate_Modified --NPA_Date_Pos
	 --,E.Reason AS Reason_Modified
	 
	 
	 
	 from #CUSTOMERCAL_HIST A
	 
	LEFT JOIN DimAssetClass B

		ON B.AssetClassAlt_Key=A.SysAssetClassAlt_Key

			
		LEFT JOIN AdhocACL_ChangeDetails C

		ON C.UCIF_ID=A.UCIF_ID

		
	LEFT JOIN DimAssetClass D

		ON D.AssetClassAlt_Key=C.AssetClassAlt_Key

	--	LEFT JOIN AdhocACL_ChangeDetails_MOD E

	--	ON E.UCIF_ID=A.UCIF_ID

		
	--LEFT JOIN DimAssetClass F

	--	ON E.AssetClassAlt_Key=F.AssetClassAlt_Key

	LEFT Join (

						Select  ParameterAlt_Key,ParameterName,'ModeOfOperationMaster' as Tablename 
						from DimParameter where DimParameterName='DimMoRreason'
						And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)L
						ON L.ParameterAlt_Key=c.Reason
	--LEFT Join (

	--					Select  ParameterAlt_Key,ParameterName,'ModeOfOperationMaster' as Tablename 
	--					from DimParameter where DimParameterName='DimMoRreason'
	--					And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)M
	--					ON M.ParameterAlt_Key=E.Reason

	         Left join   DimParameter cd    ON cd.ParameterAlt_Key=c.ChangeType and cd.DimParameterName='MOCType'
			And  cd.EffectiveFromTimeKey<=@Timekey And cd.EffectiveToTimeKey>=@Timekey 
	
	 where A.EffectiveFromTimeKey<=@TimeKey and A.EffectiveToTimeKey>=@TimeKey
	 and A.UCIF_ID=@UCIF_ID
	 --and E.AuthorisationStatus='MP'

	 	 )A
	 Where RowNumber=1
	 order by 	A.UCICID_Existing desc


	END

if @OperationFlag  = '16'




--IF EXISTS(SELECT 1 FROM AdhocACL_ChangeDetails WHERE (AuthorisationStatus IN('NP','NP')))

BEGIN
	PRINT 'Sac1'

IF EXISTS(SElect  1 from [AdhocACL_ChangeDetails_Mod] E
where  E.EffectiveFromTimeKey<=@TimeKey and E.EffectiveToTimeKey>=@TimeKey

	AND E.AuthorisationStatus in('NP', 'MP', 'DP', 'RM')

	and  E.UCIF_ID=@UCIF_ID)
	 PRINT 'Sac1-1'

BEGIN 
    IF EXISTS(SElect  1 from [AdhocACL_ChangeDetails] E
		where  E.EffectiveFromTimeKey<=@TimeKey and E.EffectiveToTimeKey>=@TimeKey

	AND E.AuthorisationStatus in('A')

	and  E.UCIF_ID=@UCIF_ID)
	
	BEGIN

	PRINT 'Sac1-2'
			select *INTO #tmp from ( select

			  C.UCIF_ID  as UCICID_Existing
			 ,C.AssetClassAlt_Key as AssetClassAlt_Key_Existing
			,C.NPA_Date AS NPADate_Existing
			,C.Reason as Reason_Existing
			,L.ParameterName AS MOCReason_Existing
		   ,Row_Number()over (partition by C.UCIF_ID order by  C.UCIF_ID desc) RowNumber
			,D.AssetClassName as AssetClass_Existing
			,c.ChangeType
			
			--INTO #tmp


			from [dbo].[AdhocACL_ChangeDetails] C
	
			LEFT JOIN DimAssetClass D

				ON C.AssetClassAlt_Key=D.AssetClassAlt_Key 

				LEFT Join (

						Select  ParameterAlt_Key,ParameterName,'ModeOfOperationMaster' as Tablename 
						from DimParameter where DimParameterName='DimMoRreason'
						And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)L
						ON L.ParameterAlt_Key=c.Reason
		
		           Left join   DimParameter cd    ON cd.ParameterAlt_Key=c.ChangeType and cd.DimParameterName='MOCType'
			And  cd.EffectiveFromTimeKey<=@Timekey And cd.EffectiveToTimeKey>=@Timekey 
			where  C.EffectiveFromTimeKey<=@TimeKey and C.EffectiveToTimeKey>=@TimeKey

			AND C.AuthorisationStatus in('A','MP')

			and  C.UCIF_ID=@UCIF_ID
			) C


			where RowNumber=1

			order by C.UCICID_Existing desc

	   END


	  ELSE


	     BEGIN

		  PRINT 'Sac2'

	    select *INTO #tmp_1 from( select

			  C.UCIF_ID  as UCICID_Existing
			  ,c.CustomerName
			 ,C.SysAssetClassAlt_Key as AssetClassAlt_Key_Existing
			,case when ( C.SysNPA_Dt='' or C.SysNPA_Dt='01/01/1900' or C.SysNPA_Dt='1900/01/01')
	                            then NULL ELSE C.SysNPA_Dt END  NPADate_Existing


            ,Row_Number()over (partition by C.UCIF_ID order by  C.UCIF_ID desc) RowNumber
			,C.DegReason as Reason_Existing
			,D.AssetClassName as AssetClass_Existing
			--,NULL ChangeType
	
			--INTO #tmp_1


			from #CUSTOMERCAL_HIST C
	
			LEFT JOIN DimAssetClass D

				ON C.SysAssetClassAlt_Key=D.AssetClassAlt_Key 
		
			where  C.EffectiveFromTimeKey<=@TimeKey and C.EffectiveToTimeKey>=@TimeKey

			--AND C.AuthorisationStatus in('A')

			and  C.UCIF_ID=@UCIF_ID
			)C
			where RowNumber=1

			order by C.UCICID_Existing desc


	END

	          --Select '#tmp',* from #tmp
		
  
             select *into #tmp1 from ( select
              
              	  E.UCIF_ID  as UCICID_Modified
              	 ,E.AssetClassAlt_Key AS AssetClassAlt_Key_Modified
              	,E.NPA_Date AS NPADate_Modified
              	,E.Reason as  Reason_Modified

			,Row_Number()over (partition by E.UCIF_ID order by  E.UCIF_ID desc) RowNumber
              	,F.AssetClassName as AssetClass_Modified
				,IsNull(E.ModifyBy,E.CreatedBy)as CrModBy
							,IsNull(E.DateModified,E.DateCreated)as CrModDate
							,ISNULL(E.ApprovedBy,E.CreatedBy) as CrAppBy
							,ISNULL(E.DateApproved,E.DateCreated) as CrAppDate
							,ISNULL(E.ApprovedBy,E.ModifyBy) as ModAppBy
							,ISNULL(E.DateApproved,E.DateModified) as ModAppDate
							,ISNULL(E.FirstLevelApprovedBy,E.CreatedBy) as ModAppByFirst
							,ISNULL(E.FirstLevelDateApproved,E.DateCreated) as ModAppDateFirst
							,E.FirstLevelApprovedBy
							,E.ApprovedBy
							,E.ChangeType
							
					
			
              	
              
      	--into #tmp1
              	
              	from [dbo].[AdhocACL_ChangeDetails_Mod] E
              	
              	LEFT JOIN DimAssetClass f
              
              		ON E.AssetClassAlt_Key=F.AssetClassAlt_Key 
              
                         Left join   DimParameter cd    ON cd.ParameterAlt_Key=E.ChangeType and cd.DimParameterName='MOCType'
			And  cd.EffectiveFromTimeKey<=@Timekey And cd.EffectiveToTimeKey>=@Timekey 
              	where  E.EffectiveFromTimeKey<=@TimeKey and E.EffectiveToTimeKey>=@TimeKey
              
              	AND E.AuthorisationStatus in('NP', 'MP', 'DP', 'RM')
              
              	and  E.UCIF_ID=@UCIF_ID

				)E
			where RowNumber=1

			order by E.UCICID_Modified desc
				  Print 'B'
			--Select '#tmp',* from #tmp
              
              	--Select '#tmp1',* from #tmp1


IF OBJECT_ID('TempDB..#tmp') IS NOT NULL
 
	Select A.*,B.* from  #tmp1 B
	Left JOIN #tmp A ON A.UCICID_Existing=B.UCICID_Modified
Else
    	Select A.*,B.* from  #tmp1 B
	    Left JOIN #tmp_1 A ON A.UCICID_Existing=B.UCICID_Modified

END

END

if @OperationFlag  = '20'


--IF EXISTS(SELECT 1 FROM AdhocACL_ChangeDetails WHERE (AuthorisationStatus IN('NP','NP')))
BEGIN

            IF EXISTS(SElect  1 from [AdhocACL_ChangeDetails_Mod] I
            where  I.EffectiveFromTimeKey<=@TimeKey and I.EffectiveToTimeKey>=@TimeKey
            
            	AND I.AuthorisationStatus in('NP', 'MP', 'DP', 'RM','FM')
            
            	and  I.UCIF_ID=@UCIF_ID)

				PRINT 'Sac1'

BEGIN	
  

           IF EXISTS(SElect  1 from [AdhocACL_ChangeDetails] I 
          where  I.EffectiveFromTimeKey<=@TimeKey and I.EffectiveToTimeKey>=@TimeKey
         
         AND I.AuthorisationStatus in('A','MP')
         
         	and  I.UCIF_ID=@UCIF_ID)





      BEGIN
	      
               select * INTO #tmp2  from (    select
                
	                G.UCIF_ID  as UCICID_Existing
	               ,G.AssetClassAlt_Key AS AssetClassAlt_Key_Existing
	              ,G.NPA_Date AS NPADate_Existing
	              ,G.Reason AS  Reason_Existing
				  ,L.ParameterName AS MOCReason_Existing
				   ,Row_Number()over (partition by G.UCIF_ID order by  G.UCIF_ID desc) RowNumber
	              ,H.AssetClassName  as AssetClass_Existing
				  ,G.ChangeType
				 
	               
	              --INTO #tmp2
                
                
	              from [dbo].[AdhocACL_ChangeDetails] G
	              
	              LEFT JOIN DimAssetClass H
      
	              	ON G.AssetClassAlt_Key=H.AssetClassAlt_Key 

						LEFT Join (

						Select  ParameterAlt_Key,ParameterName,'ModeOfOperationMaster' as Tablename 
						from DimParameter where DimParameterName='DimMoRreason'
						And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)L
						ON L.ParameterAlt_Key=G.Reason
			 Left join   DimParameter cd    ON cd.ParameterAlt_Key=G.ChangeType and cd.DimParameterName='MOCType'
			And  cd.EffectiveFromTimeKey<=@Timekey And cd.EffectiveToTimeKey>=@Timekey 
	              	
	           where  G.EffectiveFromTimeKey<=@TimeKey and G.EffectiveToTimeKey>=@TimeKey
                
	              AND G.AuthorisationStatus in('1A','MP')
                
	              and  G.UCIF_ID=@UCIF_ID

				  )G
				  where RowNumber=1

			order by G.UCICID_Existing desc
                
	
	  END


	  ELSE


	 
	     BEGIN


	     select * INTO #tmp_2 from (

		 select

			  C.UCIF_ID  as UCICID_Existing
			  ,c.CustomerName
			 ,C.SysAssetClassAlt_Key as AssetClassAlt_Key_Existing
			,case when ( C.SysNPA_Dt='' or C.SysNPA_Dt='01/01/1900' or C.SysNPA_Dt='1900/01/01')
	                            then NULL ELSE C.SysNPA_Dt END  NPADate_Existing

								,Row_Number()over (partition by C.UCIF_ID order by  C.UCIF_ID desc) RowNumber
			,C.DegReason as Reason_Existing
			,D.AssetClassName as AssetClass_Existing
			--,NULL ChangeType
	 
			--INTO #tmp_2


			from #CUSTOMERCAL_HIST C
	
			LEFT JOIN DimAssetClass D

				ON C.SysAssetClassAlt_Key=D.AssetClassAlt_Key 
		
			where  C.EffectiveFromTimeKey<=@TimeKey and C.EffectiveToTimeKey>=@TimeKey

			--AND C.AuthorisationStatus in('A')

			and  C.UCIF_ID=@UCIF_ID

			)C
			where RowNumber=1

			order by C.UCICID_Existing desc



	END

	  
	   
       select * into #tmp3 from(   select
   
                 	  I.UCIF_ID  as UCICID_Modified
                 	 ,I.AssetClassAlt_Key as AssetClassAlt_Key_Modified
                 	,I.NPA_Date AS NPADate_Modified
                 	,I.Reason  as Reason_Modified
					,Row_Number()over (partition by I.UCIF_ID order by  I.UCIF_ID desc) RowNumber
                 	,J.AssetClassName  as  AssetClass_Modified
					,IsNull(I.ModifyBy,I.CreatedBy)as CrModBy
							,IsNull(I.DateModified,I.DateCreated)as CrModDate
							,ISNULL(I.ApprovedBy,I.CreatedBy) as CrAppBy
							,ISNULL(I.DateApproved,I.DateCreated) as CrAppDate
							,ISNULL(I.ApprovedBy,I.ModifyBy) as ModAppBy
							,ISNULL(I.DateApproved,I.DateModified) as ModAppDate
							,ISNULL(I.FirstLevelApprovedBy,I.CreatedBy) as ModAppByFirst
							,ISNULL(I.FirstLevelDateApproved,I.DateCreated) as ModAppDateFirst
							,I.FirstLevelApprovedBy
							,I.ApprovedBy
							,I.ChangeType
                 
                 	 --into #tmp3
                 	
                 	from [dbo].[AdhocACL_ChangeDetails_Mod] I
                 	
                 	LEFT JOIN DimAssetClass J
                 
                 		ON I.AssetClassAlt_Key=J.AssetClassAlt_Key 
                 
                            Left join   DimParameter cd    ON cd.ParameterAlt_Key=I.ChangeType and cd.DimParameterName='MOCType'
			And  cd.EffectiveFromTimeKey<=@Timekey And cd.EffectiveToTimeKey>=@Timekey 
                 	where  I.EffectiveFromTimeKey<=@TimeKey and I.EffectiveToTimeKey>=@TimeKey
                 
                 	AND I.AuthorisationStatus in('1A')
                 
                 	and  I.UCIF_ID=@UCIF_ID

					)I
			where RowNumber=1

			order by I.UCICID_Modified desc


--Select '#tmp_2',* from #tmp_2


--Select '#tmp3',* from #tmp3

IF OBJECT_ID('TempDB..#tmp2') IS NOT NULL
   

	Select C.*,D.* from  #tmp3 D
	Left JOIN #tmp2 C ON C.UCICID_Existing=D.UCICID_Modified

Else
    		Select C.*,D.* from  #tmp3 D
	       Left JOIN #tmp_2 C ON C.UCICID_Existing=D.UCICID_Modified


	END
	





END

END

   

   END TRY

	BEGIN CATCH

	

	INSERT INTO dbo.Error_Log

				SELECT ERROR_LINE() as ErrorLine,ERROR_MESSAGE()ErrorMessage,ERROR_NUMBER()ErrorNumber

				,ERROR_PROCEDURE()ErrorProcedure,ERROR_SEVERITY()ErrorSeverity,ERROR_STATE()ErrorState

				,GETDATE()



	SELECT ERROR_MESSAGE()

	--RETURN -1

   

	END CATCH



    END;

	





















	

	
























GO