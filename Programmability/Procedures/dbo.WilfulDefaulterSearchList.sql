SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROC [dbo].[WilfulDefaulterSearchList]
--Declare
												
												--@PageNo         INT         = 1, 
													--@PageSize       INT         = 10, 
							
													
													--@PageNo         INT         = 1, 
													--@PageSize       INT         = 10, 
													@OperationFlag  INT         = 1
AS
     
	 BEGIN

SET NOCOUNT ON;
Declare @TimeKey as Int
	SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')
					

BEGIN TRY

/*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */

			IF(@OperationFlag not in ( 16,17,20))
             BEGIN
			 IF OBJECT_ID('TempDB..#temp') IS NOT NULL
                 DROP TABLE  #temp;

                 SELECT		Z.ReportedByAlt_Key,
							Z.CategoryofBankFIAlt_Key,
							Z.ReportingBankFIAlt_Key,
							Z.ReportingBranchAlt_Key,
							Z.StateUTofBranchAlt_Key,
							Z.CustomerID,
							Z.PartyName,
							Z.PAN,
							Z.ReportingSerialNo,
							Z.RegisteredOfficeAddress,
							Z.OSAmountinlacs,
							Z.WillfulDefaultDate,
							Z.SuitFiledorNotAlt_Key,
							Z.OtherBanksFIInvolvedAlt_Key,
							Z.NameofOtherBanksFIAlt_Key,
							Z.CustomerTypeAlt_Key,
							Z.AuthorisationStatus, 
                            Z.EffectiveFromTimeKey, 
                            Z.EffectiveToTimeKey, 
                            Z.CreatedBy, 
                            Z.DateCreated, 
                            Z.ApprovedBy, 
                            Z.DateApproved, 
                            Z.ModifiedBy, 
                            Z.DateModified,
							Z.CrModBy,
							Z.CrModDate,
							Z.CrAppBy,
							Z.CrAppDate,
							Z.ModAppBy,
							Z.ModAppDate
						
                 INTO #temp
                 FROM 
                 (
                     SELECT 
							
							A.ReportedByAlt_Key,
							B.ParameterName As ReportedBy,
							A.CategoryofBankFIAlt_Key,
							J.ParameterName as CategoryofBankFI,
							A.ReportingBankFIAlt_Key,
							C.BankName as ReportedBank,
							A.ReportingBranchAlt_Key,
							D.BranchName as ReportingBranch,
							A.StateUTofBranchAlt_Key,
							E.StateName as StateUTofBranch,
							A.CustomerID,
							A.PartyName,
							A.PAN,
							A.ReportingSerialNo,
							A.RegisteredOfficeAddress,
							A.OSAmountinlacs,
							A.WillfulDefaultDate,
							A.SuitFiledorNotAlt_Key,
							F.ParameterName AS SuitFiledornot,
							A.OtherBanksFIInvolvedAlt_Key,
							G.ParameterName AS OtherbanksFIinvolved,
							A.NameofOtherBanksFIAlt_Key,
							H.BranchName AS NameofOtherBanksFI,
							A.CustomerTypeAlt_Key,
							I.ParameterName AS  CustomerType,
							isnull(A.AuthorisationStatus, 'A') AuthorisationStatus,
                            A.EffectiveFromTimeKey ,
                            A.EffectiveToTimeKey ,
                            A.CreatedBy,
                            A.DateCreated,
                            A.ApprovedBy, 
                            A.DateApproved ,
                            A.ModifiedBy,
                            A.DateModified,
							IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy,
							IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
							
                     FROM WillfulDefaulters A
					 Inner Join (Select ParameterAlt_Key,ParameterName,'Reportedby' as Tablename 
						  from DimParameter where DimParameterName='Reportedby'
						  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)B
						  ON A.ReportedByAlt_Key=B.ParameterAlt_Key
					-------------
					Inner Join  DimBank C
							ON C.BankAlt_Key=A.ReportedByAlt_Key
							AND C.EffectiveFromTimeKey<=@TimeKey And C.EffectiveToTimeKey>=@TimeKey
					
					--------
						  Inner Join  DimBranch D
						   ON A.ReportingBranchAlt_Key=D.BranchAlt_Key
						   AND D.EffectiveFromTimeKey<=@TimeKey And D.EffectiveToTimeKey>=@TimeKey
						 
					--------
						 Inner Join  DIMSTATE E
						 On E.STATEAlt_Key=A.StateUTofBranchAlt_Key
						 AND E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey
					
					-------
						Inner Join ( Select ParameterAlt_Key,ParameterName,'SuitFiledornot' as Tablename 
						from  DimParameter where DimParameterName='SuitFiledornot'
						    AND EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey)F
							oN F.ParameterAlt_Key= A.StateUTofBranchAlt_Key
					--------------
					Inner Join ( Select ParameterAlt_Key,ParameterName,'OtherbanksFIinvolved' as Tablename 
			from DimParameter where DimParameterName ='DimYesNo'
							AND EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey) G
							ON G.ParameterAlt_Key=A.OtherBanksFIInvolvedAlt_Key
					---------
					Inner Join  DimBranch H
						ON H.BranchAlt_Key=A.NameofOtherBanksFIAlt_Key 
						AND H.EffectiveFromTimeKey<=@TimeKey And H.EffectiveToTimeKey>=@TimeKey
					------
				  inner join(Select ParameterAlt_Key,ParameterName,'CustomerType' as Tablename 
				from DimParameter where DimParameterName='CustomerType'
						And	EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey) I
						ON I.ParameterAlt_Key=A.CustomerTypeAlt_Key
						-------
				 inner join(Select ParameterAlt_Key	,ParameterName	,'CategoryofBankFI' as Tablename 
			from DimParameter where DimParameterName='CategoryofBankFI' 
							And	 EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey) J
						On J.ParameterAlt_Key=A.CategoryofBankFIAlt_Key

		 UNION

					SELECT  A.ReportedByAlt_Key,
							B.ParameterName As ReportedBy,
							A.CategoryofBankFIAlt_Key,
							J.ParameterName as CategoryofBankFI,
							A.ReportingBankFIAlt_Key,
							C.BankName as ReportedBank,
							A.ReportingBranchAlt_Key,
							D.BranchName as ReportingBranch,
							A.StateUTofBranchAlt_Key,
							E.StateName as StateUTofBranch,
							A.CustomerID,
							A.PartyName,
							A.PAN,
							A.ReportingSerialNo,
							A.RegisteredOfficeAddress,
							A.OSAmountinlacs,
							A.WillfulDefaultDate,
							A.SuitFiledorNotAlt_Key,
							F.ParameterName AS SuitFiledornot,
							A.OtherBanksFIInvolvedAlt_Key,
							G.ParameterName AS OtherbanksFIinvolved,
							A.NameofOtherBanksFIAlt_Key,
							H.BranchName AS NameofOtherBanksFI,
							A.CustomerTypeAlt_Key,
							I.ParameterName AS  CustomerType,
							isnull(A.AuthorisationStatus, 'A') AuthorisationStatus,
                            A.EffectiveFromTimeKey ,
                            A.EffectiveToTimeKey ,
                            A.CreatedBy,
                            A.DateCreated,
                            A.ApprovedBy, 
                            A.DateApproved,
                            A.ModifiedBy,
                            A.DateModified,
							IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy,
							IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
							
                     FROM WillfulDefaulters_mod A
										 Inner Join (Select ParameterAlt_Key,ParameterName,'Reportedby' as Tablename 
						  from DimParameter where DimParameterName='Reportedby'
						  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)B
						  ON A.ReportedByAlt_Key=B.ParameterAlt_Key
					-------------
					Inner Join  DimBank C
							ON C.BankAlt_Key=A.ReportedByAlt_Key
							AND C.EffectiveFromTimeKey<=@TimeKey And C.EffectiveToTimeKey>=@TimeKey
					
					--------
						  Inner Join  DimBranch D
						   ON A.ReportingBranchAlt_Key=D.BranchAlt_Key
						   AND D.EffectiveFromTimeKey<=@TimeKey And D.EffectiveToTimeKey>=@TimeKey
						 
					--------
						 Inner Join  DIMSTATE E
						 On E.STATEAlt_Key=A.StateUTofBranchAlt_Key
						 AND E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey
					
					-------
						Inner Join ( Select ParameterAlt_Key,ParameterName,'SuitFiledornot' as Tablename 
						from  DimParameter where DimParameterName='SuitFiledornot'
						    AND EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey)F
							oN F.ParameterAlt_Key= A.StateUTofBranchAlt_Key
					--------------
					Inner Join ( Select ParameterAlt_Key,ParameterName,'OtherbanksFIinvolved' as Tablename 
			from DimParameter where DimParameterName ='DimYesNo'
							AND EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey) G
							ON G.ParameterAlt_Key=A.OtherBanksFIInvolvedAlt_Key
					---------
					Inner Join  DimBranch H
						ON H.BranchAlt_Key=A.NameofOtherBanksFIAlt_Key 
						AND H.EffectiveFromTimeKey<=@TimeKey And H.EffectiveToTimeKey>=@TimeKey
					------
				  inner join(Select ParameterAlt_Key,ParameterName,'CustomerType' as Tablename 
				from DimParameter where DimParameterName='CustomerType'
						And	EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey) I
						ON I.ParameterAlt_Key=A.CustomerTypeAlt_Key
						-------
				 inner join(Select ParameterAlt_Key	,ParameterName	,'CategoryofBankFI' as Tablename 
			from DimParameter where DimParameterName='CategoryofBankFI' 
							And	 EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey) J
						On J.ParameterAlt_Key=A.CategoryofBankFIAlt_Key   
				   
						   AND A.Entity_Key IN
                     (
                         SELECT MAX(Entity_Key)
                         FROM WillfulDefaulters_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')
                         GROUP BY CustomerID
                     )
					)   Z 
                      
          
                 GROUP BY	Z.ReportedByAlt_Key,
							Z.CategoryofBankFIAlt_Key,
							Z.ReportingBankFIAlt_Key,
							Z.ReportingBranchAlt_Key,
							Z.StateUTofBranchAlt_Key,
							Z.CustomerID,
							Z.PartyName,
							Z.PAN,
							Z.ReportingSerialNo,
							Z.RegisteredOfficeAddress,
							Z.OSAmountinlacs,
							Z.WillfulDefaultDate,
							Z.SuitFiledorNotAlt_Key,
							Z.OtherBanksFIInvolvedAlt_Key,
							Z.NameofOtherBanksFIAlt_Key,
							Z.CustomerTypeAlt_Key,
							Z.AuthorisationStatus, 
                            Z.EffectiveFromTimeKey, 
                            Z.EffectiveToTimeKey, 
                            Z.CreatedBy, 
                            Z.DateCreated, 
                            Z.ApprovedBy, 
                            Z.DateApproved, 
                            Z.ModifiedBy, 
                            Z.DateModified,
							Z.CrModBy,
							Z.CrModDate,
							Z.CrAppBy,
							Z.CrAppDate,
							Z.ModAppBy,
							Z.ModAppDate
						
                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY CustomerID) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'Customer' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp A
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
                 --      AND RowNumber <= (@PageNo * @PageSize);
             END;
             ELSE

			 /*  IT IS Used For GRID Search which are Pending for Authorization    */
			 IF (@OperationFlag in (16,17))

             BEGIN
			 IF OBJECT_ID('TempDB..#temp16') IS NOT NULL
                 DROP TABLE #temp16;
                               
				 SELECT		P.ReportedByAlt_Key,
							P.CategoryofBankFIAlt_Key,
							P.ReportingBankFIAlt_Key,
							P.ReportingBranchAlt_Key,
							P.StateUTofBranchAlt_Key,
							P.CustomerID,
							P.PartyName,
							P.PAN,
							P.ReportingSerialNo,
							P.RegisteredOfficeAddress,
							P.OSAmountinlacs,
							P.WillfulDefaultDate,
							P.SuitFiledorNotAlt_Key,
							P.OtherBanksFIInvolvedAlt_Key,
							P.NameofOtherBanksFIAlt_Key,
							P.CustomerTypeAlt_Key,
							P.AuthorisationStatus, 
                            P.EffectiveFromTimeKey, 
                            P.EffectiveToTimeKey, 
                            P.CreatedBy, 
                            P.DateCreated, 
                            P.ApprovedBy, 
                            P.DateApproved, 
                            P.ModifiedBy, 
                            P.DateModified,
							P.CrModBy,
							P.CrModDate,
							P.CrAppBy,
							P.CrAppDate,
							P.ModAppBy,
							P.ModAppDate
				 INTO #temp16
                 FROM 
                 (		


SELECT A.ReportedByAlt_Key,
							B.ParameterName As ReportedBy,
							A.CategoryofBankFIAlt_Key,
							J.ParameterName as CategoryofBankFI,
							A.ReportingBankFIAlt_Key,
							C.BankName as ReportedBank,
							A.ReportingBranchAlt_Key,
							D.BranchName as ReportingBranch,
							A.StateUTofBranchAlt_Key,
							E.StateName as StateUTofBranch,
							A.CustomerID,
							A.PartyName,
							A.PAN,
							A.ReportingSerialNo,
							A.RegisteredOfficeAddress,
							A.OSAmountinlacs,
							A.WillfulDefaultDate,
							A.SuitFiledorNotAlt_Key,
							F.ParameterName AS SuitFiledornot,
							A.OtherBanksFIInvolvedAlt_Key,
							G.ParameterName AS OtherbanksFIinvolved,
							A.NameofOtherBanksFIAlt_Key,
							H.BranchName AS NameofOtherBanksFI,
							A.CustomerTypeAlt_Key,
							I.ParameterName AS  CustomerType,
							isnull(A.AuthorisationStatus, 'A') AuthorisationStatus,
                            A.EffectiveFromTimeKey ,
                            A.EffectiveToTimeKey ,
                            A.CreatedBy,
                            A.DateCreated,
                            A.ApprovedBy, 
                            A.DateApproved,
                            A.ModifiedBy,
                            A.DateModified,
							IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy,
							IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
							
                     FROM WillfulDefaulters_mod A
										 Inner Join (Select ParameterAlt_Key,ParameterName,'Reportedby' as Tablename 
						  from DimParameter where DimParameterName='Reportedby'
						  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)B
						  ON A.ReportedByAlt_Key=B.ParameterAlt_Key
					-------------
					Inner Join  DimBank C
							ON C.BankAlt_Key=A.ReportedByAlt_Key
							AND C.EffectiveFromTimeKey<=@TimeKey And C.EffectiveToTimeKey>=@TimeKey
					
					--------
						  Inner Join  DimBranch D
						   ON A.ReportingBranchAlt_Key=D.BranchAlt_Key
						   AND D.EffectiveFromTimeKey<=@TimeKey And D.EffectiveToTimeKey>=@TimeKey
						 
					--------
						 Inner Join  DIMSTATE E
						 On E.STATEAlt_Key=A.StateUTofBranchAlt_Key
						 AND E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey
					
					-------
						Inner Join ( Select ParameterAlt_Key,ParameterName,'SuitFiledornot' as Tablename 
						from  DimParameter where DimParameterName='SuitFiledornot'
						    AND EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey)F
							oN F.ParameterAlt_Key= A.StateUTofBranchAlt_Key
					--------------
					Inner Join ( Select ParameterAlt_Key,ParameterName,'OtherbanksFIinvolved' as Tablename 
			from DimParameter where DimParameterName ='DimYesNo'
							AND EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey) G
							ON G.ParameterAlt_Key=A.OtherBanksFIInvolvedAlt_Key
					---------
					Inner Join  DimBranch H
						ON H.BranchAlt_Key=A.NameofOtherBanksFIAlt_Key 
						AND H.EffectiveFromTimeKey<=@TimeKey And H.EffectiveToTimeKey>=@TimeKey
					------
				  inner join(Select ParameterAlt_Key,ParameterName,'CustomerType' as Tablename 
				from DimParameter where DimParameterName='CustomerType'
						And	EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey) I
						ON I.ParameterAlt_Key=A.CustomerTypeAlt_Key
						-------
				 inner join(Select ParameterAlt_Key	,ParameterName	,'CategoryofBankFI' as Tablename 
			from DimParameter where DimParameterName='CategoryofBankFI' 
							And	 EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey) J
						On J.ParameterAlt_Key=A.CategoryofBankFIAlt_Key

						    AND A.Entity_Key IN
                     (
                         SELECT MAX(Entity_Key)
                         FROM WillfulDefaulters_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')
                         GROUP BY CustomerID
                     )
                 ) P
                      
                 
                 GROUP BY	P.ReportedByAlt_Key,
							P.CategoryofBankFIAlt_Key,
							P.ReportingBankFIAlt_Key,
							P.ReportingBranchAlt_Key,
							P.StateUTofBranchAlt_Key,
							P.CustomerID,
							P.PartyName,
							P.PAN,
							P.ReportingSerialNo,
							P.RegisteredOfficeAddress,
							P.OSAmountinlacs,
							P.WillfulDefaultDate,
							P.SuitFiledorNotAlt_Key,
							P.OtherBanksFIInvolvedAlt_Key,
							P.NameofOtherBanksFIAlt_Key,
							P.CustomerTypeAlt_Key,
							P.AuthorisationStatus, 
                            P.EffectiveFromTimeKey, 
                            P.EffectiveToTimeKey, 
                            P.CreatedBy, 
                            P.DateCreated, 
                            P.ApprovedBy, 
                            P.DateApproved, 
                            P.ModifiedBy, 
                            P.DateModified,
							P.CrModBy,
							P.CrModDate,
							P.CrAppBy,
							P.CrAppDate,
							P.ModAppBy,
							P.ModAppDate
						
                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY CustomerID) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'Customer' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp16 A
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
                 --      AND RowNumber <= (@PageNo * @PageSize)

   END;

    Else

   IF (@OperationFlag =20)
             BEGIN
			 IF OBJECT_ID('TempDB..#temp20') IS NOT NULL
                 DROP TABLE #temp20;
                 SELECT	A.ReportedByAlt_Key,
				 		A.CategoryofBankFIAlt_Key,
				 		A.ReportingBankFIAlt_Key,
				 		A.ReportingBranchAlt_Key,
				 		A.StateUTofBranchAlt_Key,
				 		A.CustomerID,
				 		A.PartyName,
				 		A.PAN,
				 		A.ReportingSerialNo,
				 		A.RegisteredOfficeAddress,
				 		A.OSAmountinlacs,
				 		A.WillfulDefaultDate,
				 		A.SuitFiledorNotAlt_Key,
				 		A.OtherBanksFIInvolvedAlt_Key,
				 		A.NameofOtherBanksFIAlt_Key,
				 		A.CustomerTypeAlt_Key,
				 		A.AuthorisationStatus, 
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
				 		A.ModAppDate				 
                 INTO #temp20
                 FROM 
                 (
                     SELECT A.ReportedByAlt_Key,
							B.ParameterName As ReportedBy,
							A.CategoryofBankFIAlt_Key,
							J.ParameterName as CategoryofBankFI,
							A.ReportingBankFIAlt_Key,
							C.BankName as ReportedBank,
							A.ReportingBranchAlt_Key,
							D.BranchName as ReportingBranch,
							A.StateUTofBranchAlt_Key,
							E.StateName as StateUTofBranch,
							A.CustomerID,
							A.PartyName,
							A.PAN,
							A.ReportingSerialNo,
							A.RegisteredOfficeAddress,
							A.OSAmountinlacs,
							A.WillfulDefaultDate,
							A.SuitFiledorNotAlt_Key,
							F.ParameterName AS SuitFiledornot,
							A.OtherBanksFIInvolvedAlt_Key,
							G.ParameterName AS OtherbanksFIinvolved,
							A.NameofOtherBanksFIAlt_Key,
							H.BranchName AS NameofOtherBanksFI,
							A.CustomerTypeAlt_Key,
							I.ParameterName AS  CustomerType,
							--isnull(A.AuthorisationStatus, 'A') 
							A.AuthorisationStatus,
                            A.EffectiveFromTimeKey ,
                            A.EffectiveToTimeKey ,
                            A.CreatedBy,
                            A.DateCreated,
                            A.ApprovedBy, 
                            A.DateApproved,
                            A.ModifiedBy,
                            A.DateModified,
							IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy,
							IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
							
                     FROM WillfulDefaulters_mod A
										 Inner Join (Select ParameterAlt_Key,ParameterName,'Reportedby' as Tablename 
						  from DimParameter where DimParameterName='Reportedby'
						  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)B
						  ON A.ReportedByAlt_Key=B.ParameterAlt_Key
					-------------
					Inner Join  DimBank C
							ON C.BankAlt_Key=A.ReportedByAlt_Key
							AND C.EffectiveFromTimeKey<=@TimeKey And C.EffectiveToTimeKey>=@TimeKey
					
					--------
						  Inner Join  DimBranch D
						   ON A.ReportingBranchAlt_Key=D.BranchAlt_Key
						   AND D.EffectiveFromTimeKey<=@TimeKey And D.EffectiveToTimeKey>=@TimeKey
						 
					--------
						 Inner Join  DIMSTATE E
						 On E.STATEAlt_Key=A.StateUTofBranchAlt_Key
						 AND E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey
					
					-------
						Inner Join ( Select ParameterAlt_Key,ParameterName,'SuitFiledornot' as Tablename 
						from  DimParameter where DimParameterName='SuitFiledornot'
						    AND EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey)F
							oN F.ParameterAlt_Key= A.StateUTofBranchAlt_Key
					--------------
					Inner Join ( Select ParameterAlt_Key,ParameterName,'OtherbanksFIinvolved' as Tablename 
			from DimParameter where DimParameterName ='DimYesNo'
							AND EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey) G
							ON G.ParameterAlt_Key=A.OtherBanksFIInvolvedAlt_Key
					---------
					Inner Join  DimBranch H
						ON H.BranchAlt_Key=A.NameofOtherBanksFIAlt_Key 
						AND H.EffectiveFromTimeKey<=@TimeKey And H.EffectiveToTimeKey>=@TimeKey
					------
				  inner join(Select ParameterAlt_Key,ParameterName,'CustomerType' as Tablename 
				from DimParameter where DimParameterName='CustomerType'
						And	EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey) I
						ON I.ParameterAlt_Key=A.CustomerTypeAlt_Key
						-------
				 inner join(Select ParameterAlt_Key	,ParameterName	,'CategoryofBankFI' as Tablename 
			from DimParameter where DimParameterName='CategoryofBankFI' 
							And	 EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey) J
						On J.ParameterAlt_Key=A.CategoryofBankFIAlt_Key
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           AND ISNULL(A.AuthorisationStatus, 'A') IN('1A')
                           AND A.Entity_Key IN
                     (
                         SELECT MAX(Entity_Key)
                         FROM WillfulDefaulters_mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND AuthorisationStatus IN('1A')
                         GROUP BY CustomerID
                     )
                 ) A 
                      
                 
                 GROUP BY A.ReportedByAlt_Key,
				 		A.CategoryofBankFIAlt_Key,
				 		A.ReportingBankFIAlt_Key,
				 		A.ReportingBranchAlt_Key,
				 		A.StateUTofBranchAlt_Key,
				 		A.CustomerID,
				 		A.PartyName,
				 		A.PAN,
				 		A.ReportingSerialNo,
				 		A.RegisteredOfficeAddress,
				 		A.OSAmountinlacs,
				 		A.WillfulDefaultDate,
				 		A.SuitFiledorNotAlt_Key,
				 		A.OtherBanksFIInvolvedAlt_Key,
				 		A.NameofOtherBanksFIAlt_Key,
				 		A.CustomerTypeAlt_Key,
				 		A.AuthorisationStatus, 
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
				 		A.ModAppDate
                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY CustomerID) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'Customer' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp20 A
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
                 --      AND RowNumber <= (@PageNo * @PageSize)

   END;


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