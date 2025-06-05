SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROC [dbo].[ExceptionalDegrationSearchList]
--declare												
--@PageNo         INT         = 1, 
--@PageSize       INT         = 10, 
  @OperationFlag  INT         = 20
 ,@AccountID varchar(30)=NULL--'9987880000000003'
 --9987880000000003
AS
BEGIN

SET NOCOUNT ON;
Declare @TimeKey as Int
	SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')  

BEGIN TRY 
  IF OBJECT_ID('TempDB..#Reminder') IS NOT NULL
  Drop Table #Reminder
  
  Select *
  into #Reminder from
  (
  Select B.ParameterAlt_Key FlagAlt_Key,A.ACID AccountID 
  from [dbo].ExceptionFinalStatusType A INNER JOIN   DimParameter B
  ON   A.StatusType=B.ParameterName
  AND   B.EffectiveFromTimeKey <= @TimeKey
  AND B.EffectiveToTimeKey >= @TimeKey
  where A.EffectiveFromTimeKey <= @TimeKey
  AND A.EffectiveToTimeKey >= @TimeKey
  And ISNULL(A.AuthorisationStatus,'A')  ='A'    
  AND B.DimParameterName='UploadFLagType'  

  Union 

   Select FlagAlt_Key,AccountID 
   from [dbo].[ExceptionalDegrationDetail_mod]
   where EffectiveFromTimeKey <= @TimeKey
   AND EffectiveToTimeKey >= @TimeKey
   And ISNULL(AuthorisationStatus,'A') in ('NP' ,'MP','1A')   

--  union

--  Select   UploadTypeParameterAlt_Key as FlagAlt_Key,ACID

--from [dbo].AccountFlaggingDetails
--where EffectiveFromTimeKey <= @TimeKey
-- AND EffectiveToTimeKey >= @TimeKey
--  And ISNULL(AuthorisationStatus,'A')  ='A'                          
--union 

--Select UploadTypeParameterAlt_Key as FlagAlt_Key,ACID

--from [dbo].AccountFlaggingDetails_Mod
--where EffectiveFromTimeKey <= @TimeKey
-- AND EffectiveToTimeKey >= @TimeKey
--  And ISNULL(AuthorisationStatus,'A') in ('NP' ,'MP','1A') 



)
A
--Select * from #Reminder

IF OBJECT_ID('TempDB..#ReminderReport') IS NOT NULL
Drop Table #ReminderReport

Create Table #ReminderReport( AccountID varchar(30),FlagAlt_Key Int )

Insert Into #ReminderReport(FlagAlt_Key,AccountID)


Select A.Businesscolvalues1 as FlagAlt_Key,A.AccountID From (
SELECT AccountID,Split.a.value('.', 'VARCHAR(8000)') AS Businesscolvalues1  
                            FROM  (SELECT 
                                            CAST ('<M>' + REPLACE(FlagAlt_Key, ',', '</M><M>') + '</M>' AS XML) AS Businesscolvalues1,
                                                                                        AccountID
                                            from #Reminder
                                    ) AS A CROSS APPLY Businesscolvalues1.nodes ('/M') AS Split(a)
                                                 
)A Where A.Businesscolvalues1<>''

--Select * from #ReminderReport1

IF OBJECT_ID('TempDB..#ReminderReport1') IS NOT NULL
Drop Table #ReminderReport1


Select A.*,B.ParameterName as FlagName Into #ReminderReport1  from #ReminderReport A
Inner Join DimParameter B ON A.FlagAlt_Key=B.parameterAlt_Key
Where B.[DimParameterName]='UploadFLagType'



--IF OBJECT_ID('TempDB..#Secondary') IS NOT NULL
--Drop Table #Secondary

--Select * Into #Secondary From (
--Select A.AccountID,A.REPORTIDSLIST as FlagName From (
--SELECT SS.AccountID,
--                STUFF((SELECT ',' + US.FlagName 
--                        FROM #ReminderReport1 US
--                        WHERE US.AccountID = SS.AccountID 
--                        FOR XML PATH('')), 1, 1, '') [REPORTIDSLIST]
--                FROM #ReminderReport1 SS 
--                GROUP BY SS.AccountID
--                )A
--        )A


/*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */

  IF (@Accountid ='' or (@Accountid is null)) 
		  Begin



			IF(@OperationFlag not in ( 16,17,20))
             BEGIN

print 'AKSHAY'

			 IF OBJECT_ID('TempDB..#temp') IS NOT NULL
                 DROP TABLE  #temp;
                 SELECT		A.DegrationAlt_Key,
							A.SourceName,
							A.SourceAlt_Key,
							A.AccountID,
							A.RefCustomerId AS CustomerID,
							A.FlagAlt_Key,
							A.FlagName,
							A.Date,
							A.Marking,
							A.MarkingAlt_Key,
							Amount,
							A.AuthorisationStatus, 
							A.AuthorisationStatus_1,
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified,
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate,
							A.changeFields
							--,A.ApprovedByFirstLevel
							--,A.DateApprovedFirstLevel
                 INTO #temp
                 FROM 
                 (
    
               
						  SELECT 
							A.DegrationAlt_Key,
							B.SourceName,
							C.SourceAlt_Key,
							D.ACID AccountID,
							D.CustomerID RefCustomerId,
							--case when s.FlagName='TWO' then 1 else 9 end as FlagAlt_Key,
                            --case when D.StatusType='TWO' then 1 else 9 end as FlagAlt_Key,
							S.FlagAlt_Key,
							--S.FlagName,
							D.StatusType FlagName,
							--Convert(Varchar(20),A.Date,103) Date,
							Convert(Varchar(20),D.StatusDate,103) Date,
							H.ParameterName as Marking,
							A.MarkingAlt_Key,
							D.Amount,
							isnull(D.AuthorisationStatus, 'A') as AuthorisationStatus, 
							 CASE WHEN  ISNULL(D.AuthorisationStatus,'A')='A' THEN 'Authorized'
								  WHEN  ISNULL(D.AuthorisationStatus,'A')='R' THEN 'Rejected'
								  WHEN  ISNULL(D.AuthorisationStatus,'A')='1A' THEN '1Authorized'
								  WHEN  ISNULL(D.AuthorisationStatus,'A') IN ('NP','MP') THEN 'Pending' ELSE NULL END AS AuthorisationStatus_1,
                            D.EffectiveFromTimeKey, 
                            D.EffectiveToTimeKey, 
                            D.CreatedBy, 
                            Convert(Varchar(20),D.DateCreated,103) DateCreated, 
                            D.ApprovedBy, 
                            Convert(Varchar(20),D.DateApproved,103) DateApproved, 
                            D.ModifyBy    ModifiedBy,
                            Convert(Varchar(20),D.DateModified,103) DateModified,
							IsNull(A.ModifiedBy,D.CreatedBy)as CrModBy

							,IsNull(D.DateModified,A.DateCreated)as CrModDate
							,ISNULL(D.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(D.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(D.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(D.DateApproved,A.DateModified) as ModAppDate
							, '' as changeFields
							--,A.ApprovedByFirstLevel
							--,A.DateApprovedFirstLevel

                     FROM	ExceptionFinalStatusType D
					 LEFT join   [dbo].[ExceptionalDegrationDetail_Mod] A
					 ON      A.AccountID=D.ACID 
					 AND A.EffectiveFromTimeKey <= @TimeKey AND A.EffectiveToTimeKey >= @TimeKey  
					 LEFT JOIn #ReminderReport1 S ON S.AccountID=D.ACID
					 --AND A.FlagAlt_Key = S.FlagAlt_Key
					 AND    D.StatusType=S.FlagName
					  LEFT Join (Select ParameterAlt_Key,ParameterName,'DimYesNo' as Tablename 
						  from DimParameter where DimParameterName='DimYesNo'
						  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)H
						  ON H.ParameterAlt_Key=A.MarkingAlt_Key
						  inner join AdvAcBasicDetail C
						  ON D.ACID=C.CustomerACID
						  AND C.EffectiveFromTimeKey <= @TimeKey AND C.EffectiveToTimeKey >= @TimeKey
						  left join  [dbo].[DIMSOURCEDB] B on C.SourceAlt_Key=B.SourceAlt_Key
					  WHERE  D.EffectiveFromTimeKey <= @TimeKey
                           AND D.EffectiveToTimeKey >= @TimeKey
                           AND ISNULL(D.AuthorisationStatus, 'A') = 'A'
					        --AND A.AuthorisationStatus NOT IN ('NP','MP','1A')
						   --AND A.AccountID=@AccountID
                     UNION
                     SELECT A.DegrationAlt_Key,
							B.SourceName,
							C.SourceAlt_Key,
							A.AccountID,
							C.RefCustomerId,
							A.FlagAlt_Key,
							S.FlagName,
							Convert(Varchar(20),A.Date,103) Date,
							H.ParameterName as Marking,
							A.MarkingAlt_Key,
							Amount,
							isnull(A.AuthorisationStatus, 'A') as AuthorisationStatus, 
							CASE WHEN   A.AuthorisationStatus='A' THEN 'Authorized'
								  WHEN  A.AuthorisationStatus='R' THEN 'Rejected'
								  WHEN  A.AuthorisationStatus='1A' THEN '1Authorized'
								  WHEN  A.AuthorisationStatus IN ('NP','MP') THEN 'Pending' ELSE NULL END AS AuthorisationStatus_1,
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            Convert(Varchar(20),A.DateCreated,103) DateCreated, 
                            A.ApprovedBy, 
                            Convert(Varchar(20),A.DateApproved,103) DateApproved, 
                            A.ModifiedBy, 
                            Convert(Varchar(20),A.DateModified,103) DateModified,
							IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy

							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedByFirstLevel,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApprovedFirstLevel,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedByFirstLevel,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApprovedFirstLevel,A.DateModified) as ModAppDate
							,a.ChangeFields
							--,A.ApprovedByFirstLevel
							--,A.DateApprovedFirstLevel

                     FROM		[dbo].[ExceptionalDegrationDetail_Mod] A
					 LEFT JOIn #ReminderReport1 S ON S.AccountID=A.AccountID
					 AND A.FlagAlt_Key = S.FlagAlt_Key
					 LEFT Join (Select ParameterAlt_Key,ParameterName,'DimYesNo' as Tablename 
						  from DimParameter where DimParameterName='DimYesNo'
						  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)H
						  ON H.ParameterAlt_Key=A.MarkingAlt_Key
						  inner join dbo.AdvAcBasicDetail C
						  ON A.AccountID=C.CustomerACID
						  AND C.EffectiveFromTimeKey <= @TimeKey
                           AND C.EffectiveToTimeKey >= @TimeKey
						    left join  [dbo].[DIMSOURCEDB] B on C.SourceAlt_Key=B.SourceAlt_Key
					
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
						   --AND A.AccountID=@AccountID
                       --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                           AND A.Entity_Key IN
                     (
                         SELECT MAX(Entity_Key)
                         FROM [dbo].[ExceptionalDegrationDetail_Mod]
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')
                         GROUP BY AccountID,FlagAlt_Key
                     )

					 -- UNION
      --               SELECT NULL AS DegrationAlt_Key,
						--	B.SourceName,
						--	C.SourceAlt_Key,
						--	A.ACID AccountID,
						--	C.RefCustomerId,
						--	A.UploadTypeParameterAlt_Key FlagAlt_Key,
						--	S.FlagName,
						--	Convert(Varchar(20),A.Date,103) Date,
						--	H.ParameterName as Marking,
						--	H.ParameterAlt_Key MarkingAlt_Key,
						--	Amount,
						--	isnull(A.AuthorisationStatus, 'A') as AuthorisationStatus, 
      --                      A.EffectiveFromTimeKey, 
      --                      A.EffectiveToTimeKey, 
      --                      A.CreatedBy, 
      --                      Convert(Varchar(20),A.DateCreated,103) DateCreated, 
      --                      A.ApprovedBy, 
      --                      Convert(Varchar(20),A.DateApproved,103) DateApproved, 
      --                      A.ModifyBy  ModifiedBy, 
      --                      Convert(Varchar(20),A.DateModified,103) DateModified,
						--	IsNull(A.ModifyBy,A.CreatedBy)as CrModBy

						--	,IsNull(A.DateModified,A.DateCreated)as CrModDate
						--	,ISNULL(A.ApprovedByFirstLevel,A.CreatedBy) as CrAppBy
						--	,ISNULL(A.DateApprovedFirstLevel,A.DateCreated) as CrAppDate
						--	,ISNULL(A.ApprovedByFirstLevel,A.ModifyBy) as ModAppBy
						--	,ISNULL(A.DateApprovedFirstLevel,A.DateModified) as ModAppDate
						--	--,A.ApprovedByFirstLevel
						--	--,A.DateApprovedFirstLevel

      --               FROM		[dbo].AccountFlaggingDetails_Mod A
					 --LEFT JOIn #ReminderReport1 S ON S.AccountID=A.ACID
					 --AND A.UploadTypeParameterAlt_Key = S.FlagAlt_Key
					 --LEFT Join (Select ParameterAlt_Key,ParameterName,'DimYesNo' as Tablename 
						--  from DimParameter where DimParameterName='DimYesNo'
						--  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)H
						--  ON H.ParameterAlt_Key=CASE WHEN A.Action='N' then 10 else 20 end
						--  inner join dbo.AdvAcBasicDetail C
						--  ON A.Acid=C.CustomerACID
						--  AND C.EffectiveFromTimeKey <= @TimeKey
      --                     AND C.EffectiveToTimeKey >= @TimeKey
						--    left join  [dbo].[DIMSOURCEDB] B on C.SourceAlt_Key=B.SourceAlt_Key
					
					 --WHERE A.EffectiveFromTimeKey <= @TimeKey
      --                     AND A.EffectiveToTimeKey >= @TimeKey
						--   --AND A.AccountID=@AccountID
      --                 --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
      --                     AND A.Entity_Key IN
      --               (
      --                   SELECT MAX(Entity_Key)
      --                   FROM [dbo].AccountFlaggingDetails_Mod
      --                   WHERE EffectiveFromTimeKey <= @TimeKey
      --                         AND EffectiveToTimeKey >= @TimeKey
      --                         AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')
      --                   GROUP BY ACID,UploadTypeParameterAlt_Key
      --               )


                 )A 
                      
                 
                 GROUP BY A.DegrationAlt_Key,
							A.SourceName,
							A.SourceAlt_Key,
							A.AccountID,
							A.RefCustomerId,
							A.FlagAlt_Key,
							A.FlagName,
							A.Date,
							A.Marking,
							A.MarkingAlt_Key,
							Amount,
							A.AuthorisationStatus,
							A.AuthorisationStatus_1, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified,
							A.crModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate,
							A.changeFields
							--A.ApprovedByFirstLevel,
							--A.DateApprovedFirstLevel
							;

					

                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY DegrationAlt_Key) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'ExceptionalDegrationDetail' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM  #temp A
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner
				 order by RowNumber desc --updated by vinit


                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
                 --      AND RowNumber <= (@PageNo * @PageSize);
             END;

------------------------------------------------------------------------------
			 --IF (@OperationFlag in (1))

			 --BEGIN
			 -- IF NOT EXISTS (select 1 from #temp where AccountID=@AccountID)
			 -- BEGIN 
			 --    select C.SourceSystemAlt_Key ,CustomerID,SourceName ,'CustomerSourceDetails' TableName

				-- from curdat.AdvAcBasicDetail A
				-- inner join curdat.CustomerBasicDetail C On C.CustomerEntityId=A.CustomerEntityId
				-- inner join DIMSOURCEDB  S oN S.SourceAlt_Key=C.SourceSystemAlt_Key
				-- where CustomerACID=@AccountID
				--AND  A.EffectiveFromTimeKey <= @TimeKey      AND A.EffectiveToTimeKey >= @TimeKey
				--AND  C.EffectiveFromTimeKey <= @TimeKey      AND C.EffectiveToTimeKey >= @TimeKey

				-- --select * from CustomerBasicDetail
				-- --select * from AdvAcBasicDetail
			 -- END 

			 --END
--------------------------------------------------------------------------------------

             ELSE

			 /*  IT IS Used For GRID Search which are Pending for Authorization    */
			 IF (@OperationFlag in (16,17))

             BEGIN
			 IF OBJECT_ID('TempDB..#temp16') IS NOT NULL
                 DROP TABLE #temp16;
                 SELECT A.DegrationAlt_Key,
							A.SourceName,
							A.SourceAlt_Key,
							A.AccountID,
							A.RefCustomerId  AS CustomerID,
							A.FlagAlt_Key,
							A.FlagName,
							A.Date,
							A.Marking,
							A.MarkingAlt_Key,
							Amount,
							A.AuthorisationStatus, 
							A.AuthorisationStatus_1,
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified,
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate,
							A.changeFields
							--A.ApprovedByFirstLevel,
							--A.DateApprovedFirstLevel
							,A.Entity_Key----
                 INTO #temp16
                 FROM 
                 (
                     SELECT A.DegrationAlt_Key,
							B.SourceName,
							C.SourceAlt_Key,
							A.AccountID,
							C.RefCustomerId,
							S.FlagAlt_Key,
							S.FlagName,
							Convert(Varchar(20),A.Date,103) Date,
							H.ParameterName as Marking,
							A.MarkingAlt_Key,
							Amount,
							isnull(A.AuthorisationStatus, 'A') AuthorisationStatus, 
							CASE WHEN   A.AuthorisationStatus='A' THEN 'Authorized'
								  WHEN  A.AuthorisationStatus='R' THEN 'Rejected'
								  WHEN  A.AuthorisationStatus='1A' THEN '1Authorized'
								  WHEN  A.AuthorisationStatus IN ('NP','MP') THEN 'Pending' ELSE NULL END AS AuthorisationStatus_1,
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            Convert(Varchar(20),A.DateCreated,103) DateCreated, 
                        A.ApprovedBy, 
                            Convert(Varchar(20),A.DateApproved,103) DateApproved, 
                            A.ModifiedBy, 
                            Convert(Varchar(20),A.DateModified,103) DateModified,
							IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy

							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedByFirstLevel,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApprovedFirstLevel,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedByFirstLevel,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApprovedFirstLevel,A.DateModified) as ModAppDate
							,a.ChangeFields
							--,A.ApprovedByFirstLevel
							--,A.DateApprovedFirstLevel
							,A.Entity_Key----
--select *
                     FROM ExceptionalDegrationDetail_Mod A
					 LEFT JOIn #ReminderReport1 S ON S.AccountID=A.AccountID and S.FlagAlt_Key=A.FlagAlt_Key
					 LEFT Join (Select ParameterAlt_Key,ParameterName,'DimYesNo' as Tablename 
						  from DimParameter where DimParameterName='DimYesNo'
						  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)H
						  ON H.ParameterAlt_Key=A.MarkingAlt_Key
						  inner join AdvAcBasicDetail C
						  ON A.AccountID=C.CustomerACID
						  AND C.EffectiveFromTimeKey <= @TimeKey AND C.EffectiveToTimeKey >= @TimeKey
						  left join  [dbo].[DIMSOURCEDB] B on C.SourceAlt_Key=B.SourceAlt_Key
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
						  -- AND A.AccountID=@AccountID
                           --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                           AND A.Entity_Key IN
                     (
                         SELECT MAX(Entity_Key)
                         FROM ExceptionalDegrationDetail_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')
                         GROUP BY AccountID,FlagAlt_Key
                     )

					 --  UNION
      --               SELECT NULL AS DegrationAlt_Key,
						--	B.SourceName,
						--	C.SourceAlt_Key,
						--	A.ACID AccountID,
						--	C.RefCustomerId,
						--	A.UploadTypeParameterAlt_Key FlagAlt_Key,
						--	S.FlagName,
						--	Convert(Varchar(20),A.Date,103) Date,
						--	H.ParameterName as Marking,
						--	H.ParameterAlt_Key MarkingAlt_Key,
						--	Amount,
						--	isnull(A.AuthorisationStatus, 'A') as AuthorisationStatus, 
      --                      A.EffectiveFromTimeKey, 
      --                      A.EffectiveToTimeKey, 
      --                      A.CreatedBy, 
      --                      Convert(Varchar(20),A.DateCreated,103) DateCreated, 
      --                      A.ApprovedBy, 
      --                      Convert(Varchar(20),A.DateApproved,103) DateApproved, 
      --                      A.ModifyBy ModifiedBy, 
      --                      Convert(Varchar(20),A.DateModified,103) DateModified,
						--	IsNull(A.ModifyBy,A.CreatedBy)as CrModBy

						--	,IsNull(A.DateModified,A.DateCreated)as CrModDate
						--	,ISNULL(A.ApprovedByFirstLevel,A.CreatedBy) as CrAppBy
						--	,ISNULL(A.DateApprovedFirstLevel,A.DateCreated) as CrAppDate
						--	,ISNULL(A.ApprovedByFirstLevel,A.ModifyBy) as ModAppBy
						--	,ISNULL(A.DateApprovedFirstLevel,A.DateModified) as ModAppDate
						--	--,A.ApprovedByFirstLevel
						--	--,A.DateApprovedFirstLevel

      --               FROM		[dbo].AccountFlaggingDetails_Mod A
					 --left JOIn #ReminderReport1 S ON S.AccountID=A.ACID
					 --AND A.UploadTypeParameterAlt_Key = S.FlagAlt_Key
					 --left Join (Select ParameterAlt_Key,ParameterName,'DimYesNo' as Tablename 
						--  from DimParameter where DimParameterName='DimYesNo'
						--  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)H
						--  ON H.ParameterAlt_Key=CASE WHEN A.Action='N' then 10 else 20 end
						--  inner join AdvAcBasicDetail C
						--  ON A.Acid=C.CustomerACID
						--  AND C.EffectiveFromTimeKey <= @TimeKey
      --                     AND C.EffectiveToTimeKey >= @TimeKey
						--    left join  [dbo].[DIMSOURCEDB] B on C.SourceAlt_Key=B.SourceAlt_Key
					
					 --WHERE A.EffectiveFromTimeKey <= @TimeKey
      --                     AND A.EffectiveToTimeKey >= @TimeKey
						--   --AND A.AccountID=@AccountID
      --                 --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
      --                     AND A.Entity_Key IN
      --               (
      --                   SELECT MAX(Entity_Key)
      --                   FROM [dbo].AccountFlaggingDetails_Mod
      --                   WHERE EffectiveFromTimeKey <= @TimeKey
      --                         AND EffectiveToTimeKey >= @TimeKey
      --                         AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')
      --                   GROUP BY ACID,UploadTypeParameterAlt_Key
      --               )






                 ) A 
                      
                 
                 GROUP BY A.DegrationAlt_Key,
							A.SourceName,
							A.SourceAlt_Key,
							A.AccountID,
							A.RefCustomerID,
							A.FlagAlt_Key,
							A.FlagName,
							A.Date,
							A.Marking,
							A.MarkingAlt_Key,
							Amount,
							A.AuthorisationStatus,
							A.AuthorisationStatus_1, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified,
							A.crModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate,
							A.ChangeFields
							--A.ApprovedByFirstLevel,
							--A.DateApprovedFirstLevel;
							,A.Entity_Key----

                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY DegrationAlt_Key) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'ExceptionalDegrationDetail' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp16 A
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner
				 order by Entity_Key desc --updated by kapil

                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
                 --      AND RowNumber <= (@PageNo * @PageSize)

   END

   ELSE
    IF (@OperationFlag in (20))

             BEGIN
			 IF OBJECT_ID('TemrefpDB..#temp20') IS NOT NULL
                 DROP TABLE #temp20;
                 SELECT A.DegrationAlt_Key,
							A.SourceName,
							A.SourceAlt_Key,
							A.AccountID,
							A.RefCustomerId AS CustomerID,
							A.FlagAlt_Key,
							A.FlagName,
							A.Date,
							A.Marking,
							A.MarkingAlt_Key,
							Amount,
							A.AuthorisationStatus, 
							A.AuthorisationStatus_1,
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified,
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate,
							A.changeFields
							--A.ApprovedByFirstLevel,
							--A.DateApprovedFirstLevel
                 INTO #temp20
                 FROM 
                 (
                     SELECT A.DegrationAlt_Key,
							B.SourceName,
							C.SourceAlt_Key,
							A.AccountID,
							C.RefCustomerId,
							S.FlagAlt_Key,
							S.FlagName,
							Convert(Varchar(20),A.Date,103) Date,
							H.ParameterName as Marking,
							A.MarkingAlt_Key,
							Amount,
							isnull(A.AuthorisationStatus, 'A') AuthorisationStatus, 
							CASE WHEN   A.AuthorisationStatus='A' THEN 'Authorized'
								  WHEN  A.AuthorisationStatus='R' THEN 'Rejected'
								  WHEN  A.AuthorisationStatus='1A' THEN '1Authorized'
								  WHEN  A.AuthorisationStatus IN ('NP','MP') THEN 'Pending' ELSE NULL END AS AuthorisationStatus_1,
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            Convert(Varchar(20),A.DateCreated,103) DateCreated, 
                            A.ApprovedBy, 
                            Convert(Varchar(20),A.DateApproved,103) DateApproved, 
                            A.ModifiedBy, 
                            Convert(Varchar(20),A.DateModified,103) DateModified,
							IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy

							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedByFirstLevel,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApprovedFirstLevel,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedByFirstLevel,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApprovedFirstLevel,A.DateModified) as ModAppDate
							,a.ChangeFields
							--,A.ApprovedByFirstLevel
							--,A.DateApprovedFirstLevel

                     FROM ExceptionalDegrationDetail_Mod A
					 left JOIn #ReminderReport1  S ON S.AccountID=A.AccountID  and S.FlagAlt_Key=A.FlagAlt_Key
					 left Join (Select ParameterAlt_Key,ParameterName,'DimYesNo' as Tablename 
						  from DimParameter where DimParameterName='DimYesNo'
						  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)H
						  ON H.ParameterAlt_Key=A.MarkingAlt_Key
						  left join AdvAcBasicDetail C
						  ON A.AccountID=C.CustomerACID
						  AND C.EffectiveFromTimeKey <= @TimeKey
                           AND C.EffectiveToTimeKey >= @TimeKey
						   left join  [dbo].[DIMSOURCEDB] B on C.SourceAlt_Key=B.SourceAlt_Key
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
						   --AND A.AccountID=@AccountID
                           --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                           AND A.Entity_Key IN
                     (
                         SELECT MAX(Entity_Key)
                         FROM ExceptionalDegrationDetail_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('1A')
                         GROUP BY AccountID,FlagAlt_Key
                     )
					 --  UNION
      --               SELECT NULL AS DegrationAlt_Key,
						--	B.SourceName,
						--	C.SourceAlt_Key,
						--	A.ACID AccountID,
						--	C.RefCustomerId,
						--	A.UploadTypeParameterAlt_Key FlagAlt_Key,
						--	S.FlagName,
						--	Convert(Varchar(20),A.Date,103) Date,
						--	H.ParameterName as Marking,
						--	H.ParameterAlt_Key MarkingAlt_Key,
						--	Amount,
						--	isnull(A.AuthorisationStatus, 'A') as AuthorisationStatus, 
      --                      A.EffectiveFromTimeKey, 
      --                      A.EffectiveToTimeKey, 
      --                      A.CreatedBy, 
      --                      Convert(Varchar(20),A.DateCreated,103) DateCreated, 
      --                      A.ApprovedBy, 
      --                      Convert(Varchar(20),A.DateApproved,103) DateApproved, 
      --                      A.ModifyBy ModifiedBy, 
      --                      Convert(Varchar(20),A.DateModified,103) DateModified,
						--	IsNull(A.ModifyBy,A.CreatedBy)as CrModBy

						--	,IsNull(A.DateModified,A.DateCreated)as CrModDate
						--	,ISNULL(A.ApprovedByFirstLevel,A.CreatedBy) as CrAppBy
						--	,ISNULL(A.DateApprovedFirstLevel,A.DateCreated) as CrAppDate
						--	,ISNULL(A.ApprovedByFirstLevel,A.ModifyBy) as ModAppBy
						--	,ISNULL(A.DateApprovedFirstLevel,A.DateModified) as ModAppDate
						--	--,A.ApprovedByFirstLevel
						--	--,A.DateApprovedFirstLevel

      --               FROM		[dbo].AccountFlaggingDetails_Mod A
					 --left JOIn #ReminderReport1 S ON S.AccountID=A.ACID
					 --AND A.UploadTypeParameterAlt_Key = S.FlagAlt_Key
					 --left Join (Select ParameterAlt_Key,ParameterName,'DimYesNo' as Tablename 
						--  from DimParameter where DimParameterName='DimYesNo'
						--  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)H
						--  ON H.ParameterAlt_Key=CASE WHEN A.Action='N' then 10 else 20 end
						--  inner join AdvAcBasicDetail C
						--  ON A.Acid=C.CustomerACID
						--  AND C.EffectiveFromTimeKey <= @TimeKey
      --                     AND C.EffectiveToTimeKey >= @TimeKey
						--    left join  [dbo].[DIMSOURCEDB] B on C.SourceAlt_Key=B.SourceAlt_Key
					
					 --WHERE A.EffectiveFromTimeKey <= @TimeKey
      --                     AND A.EffectiveToTimeKey >= @TimeKey
						--   --AND A.AccountID=@AccountID
      --                 --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
      --                     AND A.Entity_Key IN
      --               (
      --                   SELECT MAX(Entity_Key)
      --                   FROM [dbo].AccountFlaggingDetails_Mod
      --                   WHERE EffectiveFromTimeKey <= @TimeKey
      --                         AND EffectiveToTimeKey >= @TimeKey
      --                         AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')
      --                   GROUP BY ACID,UploadTypeParameterAlt_Key
      --               )
                 ) A 
                      
                 
                 GROUP BY A.DegrationAlt_Key,
							A.SourceName,
							A.SourceAlt_Key,
							A.AccountID,
							A.RefCustomerId,
							A.FlagAlt_Key,
							A.FlagName,
							A.Date,
							A.Marking,
							A.MarkingAlt_Key,
							Amount,
							A.AuthorisationStatus, 
							A.AuthorisationStatus_1,
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified,
							A.crModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate,
							A.ChangeFields
							--A.ApprovedByFirstLevel,
							--A.DateApprovedFirstLevel;
                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY DegrationAlt_Key) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'ExceptionalDegrationDetail' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp20 A
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner
				 --order by DateCreated desc --updated by vinit

   END
End

ELSE
    BEGIN     

			IF(@OperationFlag not in ( 16,17,20))
             BEGIN

print 'AKSHAY'

			 IF OBJECT_ID('TempDB..#temp30') IS NOT NULL
                 DROP TABLE  #temp30;
                 SELECT		A.DegrationAlt_Key,
							A.SourceName,
							A.SourceAlt_Key,
							A.AccountID,
							A.RefCustomerId AS CustomerID,
							A.FlagAlt_Key,
							A.FlagName,
							A.Date,
							A.Marking,
							A.MarkingAlt_Key,
							Amount,
							A.AuthorisationStatus, 
							A.AuthorisationStatus_1,
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified,
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate,
							A.changeFields
							--,A.ApprovedByFirstLevel
							--,A.DateApprovedFirstLevel
                 INTO #temp30
                 FROM 
                 (
    
               
						  SELECT 
							A.DegrationAlt_Key,
							B.SourceName,
							C.SourceAlt_Key,
							D.ACID AccountID,
							D.CustomerID RefCustomerId,
							--case when s.FlagName='TWO' then 1 else 9 end as FlagAlt_Key,
                            --case when D.StatusType='TWO' then 1 else 9 end as FlagAlt_Key,
							S.FlagAlt_Key,
							--S.FlagName,
							D.StatusType FlagName,
							--Convert(Varchar(20),A.Date,103) Date,
							Convert(Varchar(20),D.StatusDate,103) Date,
							H.ParameterName as Marking,
							A.MarkingAlt_Key,
							D.Amount,
							isnull(D.AuthorisationStatus, 'A') as AuthorisationStatus, 
							CASE WHEN   ISNULL(D.AuthorisationStatus,'A')='A' THEN 'Authorized'
								  WHEN  ISNULL(D.AuthorisationStatus,'A')='R' THEN 'Rejected'
								  WHEN  ISNULL(D.AuthorisationStatus,'A')='1A' THEN '1Authorized'
								  WHEN  ISNULL(D.AuthorisationStatus,'A') IN ('NP','MP') THEN 'Pending' ELSE NULL END AS AuthorisationStatus_1,
                            D.EffectiveFromTimeKey, 
                            D.EffectiveToTimeKey, 
                            D.CreatedBy, 
                            Convert(Varchar(20),D.DateCreated,103) DateCreated, 
                            D.ApprovedBy, 
                            Convert(Varchar(20),D.DateApproved,103) DateApproved, 
                            D.ModifyBy    ModifiedBy,
                            Convert(Varchar(20),D.DateModified,103) DateModified,
							IsNull(A.ModifiedBy,D.CreatedBy)as CrModBy

							,IsNull(D.DateModified,A.DateCreated)as CrModDate
							,ISNULL(D.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(D.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(D.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(D.DateApproved,A.DateModified) as ModAppDate
							,a.changeFields
							--,A.ApprovedByFirstLevel
							--,A.DateApprovedFirstLevel

                     FROM	ExceptionFinalStatusType D
					 left join   [dbo].[ExceptionalDegrationDetail_Mod] A
					 ON      A.AccountID=D.ACID 
					 AND A.EffectiveFromTimeKey <= @TimeKey AND A.EffectiveToTimeKey >= @TimeKey  
					 LEFT JOIn #ReminderReport1 S ON S.AccountID=D.ACID
					 --AND A.FlagAlt_Key = S.FlagAlt_Key
					 AND    D.StatusType=S.FlagName
					  LEFT Join (Select ParameterAlt_Key,ParameterName,'DimYesNo' as Tablename 
						  from DimParameter where DimParameterName='DimYesNo'
						  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)H
						  ON H.ParameterAlt_Key=A.MarkingAlt_Key
						  inner join AdvAcBasicDetail C
						  ON D.ACID=C.CustomerACID
						  AND C.EffectiveFromTimeKey <= @TimeKey AND C.EffectiveToTimeKey >= @TimeKey
						  left join  [dbo].[DIMSOURCEDB] B on C.SourceAlt_Key=B.SourceAlt_Key
					  WHERE  D.EffectiveFromTimeKey <= @TimeKey
                           AND D.EffectiveToTimeKey >= @TimeKey
                           AND ISNULL(D.AuthorisationStatus, 'A') = 'A'
					       AND D.ACID=@AccountID
						   --AND A.AuthorisationStatus NOT IN ('NP','MP','1A')
						   --AND A.AccountID=@AccountID
                     UNION
                     SELECT A.DegrationAlt_Key,
							B.SourceName,
							C.SourceAlt_Key,
							A.AccountID,
							C.RefCustomerId,
							A.FlagAlt_Key,
							S.FlagName,
							Convert(Varchar(20),A.Date,103) Date,
							H.ParameterName as Marking,
							A.MarkingAlt_Key,
							Amount,
							isnull(A.AuthorisationStatus, 'A') as AuthorisationStatus, 
							CASE WHEN   A.AuthorisationStatus='A' THEN 'Authorized'
								  WHEN  A.AuthorisationStatus='R' THEN 'Rejected'
								  WHEN  A.AuthorisationStatus='1A' THEN '1Authorized'
								  WHEN  A.AuthorisationStatus IN ('NP','MP') THEN 'Pending' ELSE NULL END AS AuthorisationStatus_1,
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            Convert(Varchar(20),A.DateCreated,103) DateCreated, 
                            A.ApprovedBy, 
                            Convert(Varchar(20),A.DateApproved,103) DateApproved, 
                            A.ModifiedBy, 
                            Convert(Varchar(20),A.DateModified,103) DateModified,
							IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy

							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedByFirstLevel,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApprovedFirstLevel,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedByFirstLevel,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApprovedFirstLevel,A.DateModified) as ModAppDate
							,a.changeFields
							--,A.ApprovedByFirstLevel
							--,A.DateApprovedFirstLevel

                     FROM		[dbo].[ExceptionalDegrationDetail_Mod] A
					 LEFT JOIn #ReminderReport1 S ON S.AccountID=A.AccountID
					 AND A.FlagAlt_Key = S.FlagAlt_Key
					 LEFT Join (Select ParameterAlt_Key,ParameterName,'DimYesNo' as Tablename 
						  from DimParameter where DimParameterName='DimYesNo'
						  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)H
						  ON H.ParameterAlt_Key=A.MarkingAlt_Key
						  inner join AdvAcBasicDetail C
						  ON A.AccountID=C.CustomerACID
						  AND C.EffectiveFromTimeKey <= @TimeKey
                           AND C.EffectiveToTimeKey >= @TimeKey
						    left join  [dbo].[DIMSOURCEDB] B on C.SourceAlt_Key=B.SourceAlt_Key
					
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
						   AND A.AccountID=@AccountID
						   --AND A.AccountID=@AccountID
                       --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                           AND A.Entity_Key IN
                     (
                         SELECT MAX(Entity_Key)
                         FROM [dbo].[ExceptionalDegrationDetail_Mod]
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')
                         GROUP BY AccountID,FlagAlt_Key
                     )

				


                 )A 
                      
                 
                 GROUP BY A.DegrationAlt_Key,
							A.SourceName,
							A.SourceAlt_Key,
							A.AccountID,
							A.RefCustomerId,
							A.FlagAlt_Key,
							A.FlagName,
							A.Date,
							A.Marking,
							A.MarkingAlt_Key,
							Amount,
							A.AuthorisationStatus, 
							A.AuthorisationStatus_1,
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified,
							A.crModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate,
							A.changeFields
							--A.ApprovedByFirstLevel,
							--A.DateApprovedFirstLevel
							;

					

                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY DegrationAlt_Key) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'ExceptionalDegrationDetail' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM  #temp30 A
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner
				 --order by DateCreated desc --updated by vinit
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
                 --      AND RowNumber <= (@PageNo * @PageSize);
             END;

------------------------------------------------------------------------------
			 IF (@OperationFlag in (1))

			 BEGIN
			  IF NOT EXISTS (select 1 from #temp30 where AccountID=@AccountID)
			  BEGIN 
			     select C.SourceSystemAlt_Key ,CustomerID,SourceName ,'CustomerSourceDetails' TableName

				 from AdvAcBasicDetail A
				 inner join CustomerBasicDetail C On C.CustomerEntityId=A.CustomerEntityId
				 inner join DIMSOURCEDB  S oN S.SourceAlt_Key=C.SourceSystemAlt_Key
				 where CustomerACID=@AccountID
				AND  A.EffectiveFromTimeKey <= @TimeKey      AND A.EffectiveToTimeKey >= @TimeKey
				AND  C.EffectiveFromTimeKey <= @TimeKey      AND C.EffectiveToTimeKey >= @TimeKey

				 --select * from CustomerBasicDetail
				 --select * from AdvAcBasicDetail
			  END 

			 END
--------------------------------------------------------------------------------------

             ELSE

			 /*  IT IS Used For GRID Search which are Pending for Authorization    */
			 IF (@OperationFlag in (16,17))
			
             BEGIN
			  print 'Kaps'
			 IF OBJECT_ID('TempDB..#temp161') IS NOT NULL
                 DROP TABLE #temp161;
                 SELECT A.DegrationAlt_Key,
							A.SourceName,
							A.SourceAlt_Key,
							A.AccountID,
							A.RefCustomerId  AS CustomerID,
							A.FlagAlt_Key,
							A.FlagName,
							A.Date,
							A.Marking,
							A.MarkingAlt_Key,
							Amount,
							A.AuthorisationStatus, 
							A.AuthorisationStatus_1,
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified,
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate,
							A.changeFields
							--A.ApprovedByFirstLevel,
							--A.DateApprovedFirstLevel
		                 INTO #temp161
                 FROM 
                 (
                     SELECT A.DegrationAlt_Key,
							B.SourceName,
							C.SourceAlt_Key,
							A.AccountID,
							C.RefCustomerId,
							S.FlagAlt_Key,
							S.FlagName,
							Convert(Varchar(20),A.Date,103) Date,
							H.ParameterName as Marking,
							A.MarkingAlt_Key,
							Amount,
							isnull(A.AuthorisationStatus, 'A') AuthorisationStatus, 
							CASE WHEN   A.AuthorisationStatus='A' THEN 'Authorized'
								  WHEN  A.AuthorisationStatus='R' THEN 'Rejected'
								  WHEN  A.AuthorisationStatus='1A' THEN '1Authorized'
								  WHEN  A.AuthorisationStatus IN ('NP','MP') THEN 'Pending' ELSE NULL END AS AuthorisationStatus_1,
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            Convert(Varchar(20),A.DateCreated,103) DateCreated, 
                        A.ApprovedBy, 
                            Convert(Varchar(20),A.DateApproved,103) DateApproved, 
                            A.ModifiedBy, 
                            Convert(Varchar(20),A.DateModified,103) DateModified,
						IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy

							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedByFirstLevel,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApprovedFirstLevel,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedByFirstLevel,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApprovedFirstLevel,A.DateModified) as ModAppDate
							,a.changeFields
							--,A.ApprovedByFirstLevel
							--,A.DateApprovedFirstLevel
							

                     FROM ExceptionalDegrationDetail_Mod A
					 LEFT JOIn #ReminderReport1 S ON S.AccountID=A.AccountID and S.FlagAlt_Key=A.FlagAlt_Key
					 LEFT Join (Select ParameterAlt_Key,ParameterName,'DimYesNo' as Tablename 
						  from DimParameter where DimParameterName='DimYesNo'
						  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)H
						  ON H.ParameterAlt_Key=A.MarkingAlt_Key
						  inner join AdvAcBasicDetail C
						  ON A.AccountID=C.CustomerACID
						  AND C.EffectiveFromTimeKey <= @TimeKey AND C.EffectiveToTimeKey >= @TimeKey
						  left join  [dbo].[DIMSOURCEDB] B on C.SourceAlt_Key=B.SourceAlt_Key
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
						  AND A.AccountID=@AccountID
                           --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                           AND A.Entity_Key IN
                     (
                         SELECT MAX(Entity_Key)
                         FROM ExceptionalDegrationDetail_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')
                         GROUP BY AccountID,FlagAlt_Key
                     )

       ) A 
                      
                 
                 GROUP BY A.DegrationAlt_Key,
							A.SourceName,
							A.SourceAlt_Key,
							A.AccountID,
							A.RefCustomerID,
							A.FlagAlt_Key,
							A.FlagName,
							A.Date,
							A.Marking,
							A.MarkingAlt_Key,
							Amount,
							A.AuthorisationStatus, 
							A.AuthorisationStatus_1,
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified,
							A.crModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate,
							A.ChangeFields
							--A.ApprovedByFirstLevel,
							--A.DateApprovedFirstLevel;
							

                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY DegrationAlt_Key) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'ExceptionalDegrationDetail' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp161 A
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner
				-- order by Entity_Key desc --updated by vinit
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
                 --      AND RowNumber <= (@PageNo * @PageSize)

   END

   ELSE
    IF (@OperationFlag in (20))

             BEGIN
			 IF OBJECT_ID('TemrefpDB..#temp201') IS NOT NULL
                 DROP TABLE #temp201;
                 SELECT A.DegrationAlt_Key,
							A.SourceName,
							A.SourceAlt_Key,
							A.AccountID,
							A.RefCustomerId AS CustomerID,
							A.FlagAlt_Key,
							A.FlagName,
							A.Date,
							A.Marking,
							A.MarkingAlt_Key,
							Amount,
							A.AuthorisationStatus, 
							A.AuthorisationStatus_1,
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified,
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate,
							A.changeFields
							--A.ApprovedByFirstLevel,
							--A.DateApprovedFirstLevel
                 INTO #temp201
                 FROM 
                 (
                     SELECT A.DegrationAlt_Key,
							B.SourceName,
							C.SourceAlt_Key,
							A.AccountID,
							C.RefCustomerId,
							S.FlagAlt_Key,
							S.FlagName,
							Convert(Varchar(20),A.Date,103) Date,
							H.ParameterName as Marking,
							A.MarkingAlt_Key,
							Amount,
							isnull(A.AuthorisationStatus, 'A') AuthorisationStatus, 
							CASE WHEN   A.AuthorisationStatus='A' THEN 'Authorized'
								  WHEN  A.AuthorisationStatus='R' THEN 'Rejected'
								  WHEN  A.AuthorisationStatus='1A' THEN '1Authorized'
								  WHEN  A.AuthorisationStatus IN ('NP','MP') THEN 'Pending' ELSE NULL END AS AuthorisationStatus_1,
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            Convert(Varchar(20),A.DateCreated,103) DateCreated, 
                            A.ApprovedBy, 
                            Convert(Varchar(20),A.DateApproved,103) DateApproved, 
                            A.ModifiedBy, 
                            Convert(Varchar(20),A.DateModified,103) DateModified,
							IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy

							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedByFirstLevel,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApprovedFirstLevel,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedByFirstLevel,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApprovedFirstLevel,A.DateModified) as ModAppDate
							,a.changeFields
							--,A.ApprovedByFirstLevel
							--,A.DateApprovedFirstLevel

                     FROM ExceptionalDegrationDetail_Mod A
					 left JOIn #ReminderReport1  S ON S.AccountID=A.AccountID  and S.FlagAlt_Key=A.FlagAlt_Key
					 left Join (Select ParameterAlt_Key,ParameterName,'DimYesNo' as Tablename 
						  from DimParameter where DimParameterName='DimYesNo'
						  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)H
						  ON H.ParameterAlt_Key=A.MarkingAlt_Key
						  left join AdvAcBasicDetail C
						  ON A.AccountID=C.CustomerACID
						  AND C.EffectiveFromTimeKey <= @TimeKey
                           AND C.EffectiveToTimeKey >= @TimeKey
						   left join  [dbo].[DIMSOURCEDB] B on C.SourceAlt_Key=B.SourceAlt_Key
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
						   AND A.AccountID=@AccountID
                           --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                           AND A.Entity_Key IN
                     (
                         SELECT MAX(Entity_Key)
                         FROM ExceptionalDegrationDetail_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('1A')
                         GROUP BY AccountID,FlagAlt_Key
                     )

                 ) A 
                      
                 
                 GROUP BY A.DegrationAlt_Key,
							A.SourceName,
							A.SourceAlt_Key,
							A.AccountID,
							A.RefCustomerId,
							A.FlagAlt_Key,
							A.FlagName,
							A.Date,
							A.Marking,
							A.MarkingAlt_Key,
							Amount,
							A.AuthorisationStatus, 
							A.AuthorisationStatus_1,
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified,
							A.crModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate,
							A.ChangeFields
							--A.ApprovedByFirstLevel,
							--A.DateApprovedFirstLevel;
                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY DegrationAlt_Key) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'ExceptionalDegrationDetail' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp201 A
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner
				 --order by DateCreated desc --updated by vinit

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

select *,'ExceptionDegradation' AS tableName from MetaScreenFieldDetail where ScreenName='ExceptionDegradationAssets'
  
    END;




GO