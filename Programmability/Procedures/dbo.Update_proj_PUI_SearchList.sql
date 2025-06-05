SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--Exec Update_proj_PUI_SearchList @OperationFlag=1
CREATE PROC [dbo].[Update_proj_PUI_SearchList]
--Declare
													
													--@PageNo         INT         = 1, 
													--@PageSize       INT         = 10, 
													@OperationFlag  INT         = 20,
													@MenuID	INT=24705
AS
     
	 BEGIN

SET NOCOUNT ON;
Declare @TimeKey as Int
	SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')


Declare @Authlevel InT
 
select @Authlevel=AuthLevel from SysCRisMacMenu  
 where MenuId=@MenuID
  --select * from 	SysCRisMacMenu where menucaption like '%PUI%'					

BEGIN TRY

/*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */

			IF(@OperationFlag not in (16,17,20))
             BEGIN
			 IF OBJECT_ID('TempDB..#temp') IS NOT NULL
                 DROP TABLE  #temp;
                 SELECT		 A.CustomerID
								   ,A.AccountID
                                   ,A.ChangeinProjectScope
								   --,A.ChangeinProjectScopeDESC
                                   ,A.FreshOriginalDCCO
                                   ,A.RevisedDCCO
                                   ,A.CourtCaseArbitration
								  -- ,A.CourtCaseArbitrationDESC
                                   ,A.ChangeinOwnerShip
								  -- ,A.ChangeinOwnerShipDESC
                                   ,A.CIOReferenceDate
                                   ,A.CIODCCO
								  -- ,A.CostOverRunDESC
                                   ,A.CostOverRun
                                   ,A.RevisedProjectCost
                                   ,A.RevisedDebt
                                   ,A.RevisedDebt_EquityRatio
                                   ,A.TakeOutFinance
								  -- ,A.TakeOutFinanceDESC
								    ,A.AssetClassSellerBook
                                   ,A.AssetClassSellerBookAlt_key
                                   ,A.NPADtClsSellBook
                                   ,A.Restructuring
								   --,A.RestructuringDESC
							,A.AuthorisationStatus 
                            ,A.EffectiveFromTimeKey 
                            ,A.EffectiveToTimeKey
                            ,A.CreatedBy 
                            ,A.DateCreated 
                            ,A.ApprovedBy 
                            ,A.DateApproved
                            ,A.ModifiedBy 
                            ,A.DateModified
							,A.CrModBy
							,A.CrModDate
							,A.CrAppBy
							,A.CrAppDate
							,A.ModAppBy
							,A.ModAppDate
							,A.InitialExtenstion
							,A.ExtnReason_BCP
							,A.Npa_date
							,A.Npa_Reason
							,A.AssetClassAlt_Key
							,A.ActualDCCO_Achieved
							,A.ActualDCCO_Date
							,A.RM_CreditOfficer
                 INTO #temp
                 FROM 
                 (
                     SELECT 
							        A.CustomerID
								   ,A.AccountID
                                   ,A.ChangeinProjectScope
								  -- ,case when A.ChangeinProjectScope=1 THEN 'Y' ELSE 'N' END AS ChangeinProjectScopeDESC
                                    ,convert(varchar(10),A.FreshOriginalDCCO ,103) FreshOriginalDCCO
                                   ,convert(varchar(10),A.RevisedDCCO ,103) RevisedDCCO 
                                   ,A.CourtCaseArbitration
								  -- ,case when A.CourtCaseArbitration=1 THEN 'Y' ELSE 'N' END AS CourtCaseArbitrationDESC
                                   ,A.ChangeinOwnerShip
								 --  ,case when A.ChangeinOwnerShip=1 THEN 'Y' ELSE 'N' END AS ChangeinOwnerShipDESC
                                   ,convert(varchar(10),A.CIOReferenceDate ,103) CIOReferenceDate
                                   ,convert(varchar(10),A.CIODCCO ,103) CIODCCO 
								  -- ,case when A.CostOverRun=1 THEN 'Y' ELSE 'N' END AS CostOverRunDESC
                                   ,A.CostOverRun
                                   ,A.RevisedProjectCost
                                   ,A.RevisedDebt
                                   ,A.RevisedDebt_EquityRatio
                                   ,A.TakeOutFinance
								  -- ,case when A.TakeOutFinance=1 THEN 'Y' ELSE 'N' END AS TakeOutFinanceDESC
								   ,case when A.AssetClassSellerBookAlt_key=1 then 'STD'
								         ELSE 'NPA' END AS AssetClassSellerBook
                                   ,A.AssetClassSellerBookAlt_key
                                   ,case when convert(varchar(10),A.NPADateSellerBook ,103) in ('01/01/1900','')then null
								     else convert(varchar(10),A.NPADateSellerBook ,103) end   NPADtClsSellBook 
                                  ,ISNULL(C.Restructuring,'N') Restructuring
								    --,case when C.Restructuring=1 THEN 'Y' ELSE 'N' END AS RestructuringDESC
							,isnull(A.AuthorisationStatus, 'A') AuthorisationStatus
                            ,A.EffectiveFromTimeKey 
                            ,A.EffectiveToTimeKey 
                            ,A.CreatedBy 
                            ,A.DateCreated
                            ,A.ApprovedBy 
                            ,A.DateApproved 
                            ,A.ModifiedBy 
                            ,A.DateModified
							,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.FirstLevelApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.FirstLevelDateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.FirstLevelApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.FirstLevelDateApproved,A.DateModified) as ModAppDate
							,A.InitialExtenstion
							--,CASE WHEN A.InitialExtenstion=NULL THEN 'No' else A.InitialExtenstion end InitialExtenstion
							,A.ExtnReason_BCP
							,convert(varchar(10),C.NPA_DATE,103) Npa_date
							,C.DEFAULT_REASON   Npa_Reason
							,C.FinalAssetClassAlt_Key  AssetClassAlt_Key
							,A.ActualDCCO_Achieved
							,convert(varchar(10),A.ActualDCCO_Date,103) ActualDCCO_Date
							,RM_CreditOfficer
                     FROM AdvAcPUIDetailSub A 
					 INNER JOIN  CURDAT.AdvAcBasicDetail B
					 ON          A.AccountID=B.CustomerACID AND  B.EffectiveFromTimeKey <= @TimeKey
                           AND B.EffectiveToTimeKey >= @TimeKey
					 LEFT JOIN  PRO.PUI_CAL C
					 ON          B.AccountEntityId=C.AccountEntityId AND  C.EffectiveFromTimeKey <= @TimeKey
                           AND C.EffectiveToTimeKey >= @TimeKey
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
                     UNION
                     SELECT   A.CustomerID
								   ,A.AccountID
                                   ,A.ChangeinProjectScope
								  -- ,case when A.ChangeinProjectScope=1 THEN 'Y' ELSE 'N' END AS ChangeinProjectScopeDESC
                                   --,A.FreshOriginalDCCO
								    ,convert(varchar(10),A.FreshOriginalDCCO ,103) FreshOriginalDCCO
                                   ,convert(varchar(10),A.RevisedDCCO ,103) RevisedDCCO 
                                   ,A.CourtCaseArbitration
								  -- ,case when A.CourtCaseArbitration=1 THEN 'Y' ELSE 'N' END AS CourtCaseArbitrationDESC
                                   ,A.ChangeinOwnerShip
								  -- ,case when A.ChangeinOwnerShip=1 THEN 'Y' ELSE 'N' END AS ChangeinOwnerShipDESC
                                   ,convert(varchar(10),A.CIOReferenceDate ,103) CIOReferenceDate
                                   ,convert(varchar(10),A.CIODCCO ,103) CIODCCO 
								 --  ,case when A.CostOverRun=1 THEN 'Y' ELSE 'N' END AS CostOverRunDESC
                                   ,A.CostOverRun
                                   ,A.RevisedProjectCost
                                   ,A.RevisedDebt
                                   ,A.RevisedDebt_EquityRatio
                                   ,A.TakeOutFinance
								   --,case when A.TakeOutFinance=1 THEN 'Y' ELSE 'N' END AS TakeOutFinanceDESC
								   ,case when A.AssetClassSellerBookAlt_key=1 then 'STD'
								         ELSE 'NPA' END AS AssetClassSellerBook
        ,A.AssetClassSellerBookAlt_key
                                   --,convert(varchar(10),A.NPADateSellerBook ,103) NPADateSellerBook 
								    ,case when convert(varchar(10),A.NPADateSellerBook ,103) in ('01/01/1900','')then null
								     else convert(varchar(10),A.NPADateSellerBook ,103) end   NPADtClsSellBook 
                                   ,ISNULL(C.Restructuring,'N') Restructuring
								    --,case when C.Restructuring=1 THEN 'Y' ELSE 'N' END AS RestructuringDESC,
							,isnull(A.AuthorisationStatus, 'A') AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified
							--,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							--,IsNull(A.DateModified,A.DateCreated)as CrModDate
							--,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							--,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							--,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							--,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
							,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.FirstLevelApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.FirstLevelDateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.FirstLevelApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.FirstLevelDateApproved,A.DateModified) as ModAppDate
							,A.InitialExtenstion
							--,CASE WHEN A.InitialExtenstion=NULL THEN 'No' else A.InitialExtenstion end InitialExtenstion
							,A.ExtnReason_BCP
							,convert(varchar(10),C.NPA_DATE,103) Npa_date
							,C.DEFAULT_REASON Npa_Reason
							,C.FinalAssetClassAlt_Key  AssetClassAlt_Key
							,A.ActualDCCO_Achieved
							,convert(varchar(10),A.ActualDCCO_Date,103) ActualDCCO_Date
							,RM_CreditOfficer
                     FROM AdvAcPUIDetailSub_Mod A
					  INNER JOIN  CURDAT.AdvAcBasicDetail B
					 ON          A.AccountID=B.CustomerACID AND  B.EffectiveFromTimeKey <= @TimeKey
                           AND B.EffectiveToTimeKey >= @TimeKey
					 LEFT JOIN  PRO.PUI_CAL C
					 ON          B.AccountEntityId=C.AccountEntityId AND  C.EffectiveFromTimeKey <= @TimeKey
                           AND C.EffectiveToTimeKey >= @TimeKey
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                           AND A.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM AdvAcPUIDetailSub_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')
                         GROUP BY EntityKey
                     )
                 ) A 
                      
                 
                 GROUP BY  A.CustomerID
								   ,A.AccountID
                                   ,A.ChangeinProjectScope
								  -- ,A.ChangeinProjectScopeDESC
                                   ,A.FreshOriginalDCCO
                                   ,A.RevisedDCCO
                                   ,A.CourtCaseArbitration
								  -- ,A.CourtCaseArbitrationDESC
                                   ,A.ChangeinOwnerShip
								  -- ,A.ChangeinOwnerShipDESC
                                   ,A.CIOReferenceDate
                                   ,A.CIODCCO
								  -- ,A.CostOverRunDESC
                                   ,A.CostOverRun
                                   ,A.RevisedProjectCost
                                   ,A.RevisedDebt
                                   ,A.RevisedDebt_EquityRatio
                                   ,A.TakeOutFinance
								  -- ,A.TakeOutFinanceDESC
								    ,A.AssetClassSellerBook
                                   ,A.AssetClassSellerBookAlt_key
                                   ,A.NPADtClsSellBook
                                   ,A.Restructuring
								   --,A.RestructuringDESC,
							,A.AuthorisationStatus, 
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
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate
							,A.InitialExtenstion
							,A.ExtnReason_BCP
							,A.Npa_date
							,A.Npa_Reason
							,A.AssetClassAlt_Key
							,A.ActualDCCO_Achieved
							,A.ActualDCCO_Date
							,A.RM_CreditOfficer;

                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY AssetClassSellerBookAlt_key) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'UpdatePUI' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp A
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner
             
             END;
             ELSE

			 /*  IT IS Used For GRID Search which are Pending for Authorization    */
			 IF (@OperationFlag in(16,17))

             BEGIN
			 IF OBJECT_ID('TempDB..#temp16') IS NOT NULL
                 DROP TABLE #temp16;
                 SELECT   A.CustomerID
								   ,A.AccountID
                                   ,A.ChangeinProjectScope
								  -- ,A.ChangeinProjectScopeDESC
                                   ,A.FreshOriginalDCCO
                                   ,A.RevisedDCCO
                                   ,A.CourtCaseArbitration
								  -- ,A.CourtCaseArbitrationDESC
                                   ,A.ChangeinOwnerShip
								  -- ,A.ChangeinOwnerShipDESC
                                   ,A.CIOReferenceDate
                                   ,A.CIODCCO
								   --,A.CostOverRunDESC
                                   ,A.CostOverRun
                                   ,A.RevisedProjectCost
                                   ,A.RevisedDebt
                                   ,A.RevisedDebt_EquityRatio
                                   ,A.TakeOutFinance
								  -- ,A.TakeOutFinanceDESC
								    ,A.AssetClassSellerBook
                                   ,A.AssetClassSellerBookAlt_key
                                   ,A.NPADtClsSellBook
                                   ,A.Restructuring
								  -- ,A.RestructuringDESC,
							,A.AuthorisationStatus, 
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
							,A.InitialExtenstion
							,A.ExtnReason_BCP
							,A.Npa_date
							,A.Npa_Reason
							,A.AssetClassAlt_Key
							,A.ActualDCCO_Achieved
							,A.ActualDCCO_Date
							,A.RM_CreditOfficer
                 INTO #temp16
                 FROM 
                 (
                     SELECT   A.CustomerID
								   ,A.AccountID
                                   ,A.ChangeinProjectScope
								 --  ,case when A.ChangeinProjectScope=1 THEN 'Y' ELSE 'N' END AS ChangeinProjectScopeDESC
                                     ,convert(varchar(10),A.FreshOriginalDCCO ,103) FreshOriginalDCCO
                                   ,convert(varchar(10),A.RevisedDCCO ,103) RevisedDCCO 
                           ,A.CourtCaseArbitration
								  -- ,case when A.CourtCaseArbitration=1 THEN 'Y' ELSE 'N' END AS CourtCaseArbitrationDESC
                                   ,A.ChangeinOwnerShip
								  -- ,case when A.ChangeinOwnerShip=1 THEN 'Y' ELSE 'N' END AS ChangeinOwnerShipDESC
                                   ,convert(varchar(10),A.CIOReferenceDate ,103) CIOReferenceDate
                                   ,convert(varchar(10),A.CIODCCO ,103) CIODCCO 
								 --  ,case when A.CostOverRun=1 THEN 'Y' ELSE 'N' END AS CostOverRunDESC
                                   ,A.CostOverRun
                                   ,A.RevisedProjectCost
                                   ,A.RevisedDebt
                                   ,A.RevisedDebt_EquityRatio
                                   ,A.TakeOutFinance
								 --  ,case when A.TakeOutFinance=1 THEN 'Y' ELSE 'N' END AS TakeOutFinanceDESC
								   ,case when A.AssetClassSellerBookAlt_key=1 then 'STD'
								         ELSE 'NPA' END AS AssetClassSellerBook
                                   ,A.AssetClassSellerBookAlt_key
                                   --,convert(varchar(10),A.NPADateSellerBook ,103) NPADateSellerBook 
								    ,case when convert(varchar(10),A.NPADateSellerBook ,103) in ('01/01/1900','')then null
								     else convert(varchar(10),A.NPADateSellerBook ,103) end   NPADtClsSellBook 
                                   ,ISNULL(C.Restructuring,'N') Restructuring
								   -- ,case when C.Restructuring=1 THEN 'Y' ELSE 'N' END AS RestructuringDESC,
							,isnull(A.AuthorisationStatus, 'A') AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified
							--,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							--,IsNull(A.DateModified,A.DateCreated)as CrModDate
							--,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							--,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							--,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							--,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
							,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.FirstLevelApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.FirstLevelDateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.FirstLevelApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.FirstLevelDateApproved,A.DateModified) as ModAppDate
							,A.InitialExtenstion
							--,CASE WHEN A.InitialExtenstion=NULL THEN 'No' else A.InitialExtenstion end InitialExtenstion
							,A.ExtnReason_BCP
							,convert(varchar(10),C.NPA_DATE,103) Npa_date
							,C.DEFAULT_REASON Npa_Reason
							,C.FinalAssetClassAlt_Key AssetClassAlt_Key
							,A.ActualDCCO_Achieved
							,convert(varchar(10),A.ActualDCCO_Date,103) ActualDCCO_Date
							,A.RM_CreditOfficer
                     FROM AdvAcPUIDetailSub_Mod A
					  INNER JOIN  CURDAT.AdvAcBasicDetail B
					 ON          A.AccountID=B.CustomerACID AND  B.EffectiveFromTimeKey <= @TimeKey
                           AND B.EffectiveToTimeKey >= @TimeKey
					 LEFT JOIN  PRO.PUI_CAL C
					 ON          B.AccountEntityId=C.AccountEntityId AND  C.EffectiveFromTimeKey <= @TimeKey
                           AND C.EffectiveToTimeKey >= @TimeKey
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                           AND A.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM AdvAcPUIDetailSub_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')
							    GROUP BY EntityKey
                     )
                 ) A 
                      
                 
                 GROUP BY   A.CustomerID
								   ,A.AccountID
                                   ,A.ChangeinProjectScope
								  -- ,A.ChangeinProjectScopeDESC
                        ,A.FreshOriginalDCCO
                                   ,A.RevisedDCCO
                                   ,A.CourtCaseArbitration
								   --,A.CourtCaseArbitrationDESC
                                   ,A.ChangeinOwnerShip
								  -- ,A.ChangeinOwnerShipDESC
                                   ,A.CIOReferenceDate
                                   ,A.CIODCCO
								  -- ,A.CostOverRunDESC
                                   ,A.CostOverRun
                                   ,A.RevisedProjectCost
                                   ,A.RevisedDebt
                                   ,A.RevisedDebt_EquityRatio
                                   ,A.TakeOutFinance
								  -- ,A.TakeOutFinanceDESC
								    ,A.AssetClassSellerBook
                                   ,A.AssetClassSellerBookAlt_key
                                   ,A.NPADtClsSellBook
                                   ,A.Restructuring
								 --  ,A.RestructuringDESC,
							,A.AuthorisationStatus, 
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
							,A.InitialExtenstion
							,A.ExtnReason_BCP
							,A.Npa_date
							,A.Npa_Reason
							,A.AssetClassAlt_Key
							,A.ActualDCCO_Achieved
							,A.ActualDCCO_Date
							,A.RM_CreditOfficer
                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY AssetClassSellerBookAlt_key) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'UpdatePUI' TableName, 
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
			 PRINT 'Sac'
			 IF OBJECT_ID('TempDB..#temp20') IS NOT NULL
                 DROP TABLE #temp20;
                 SELECT    A.CustomerID
								   ,A.AccountID
                                   ,A.ChangeinProjectScope
								 --  ,A.ChangeinProjectScopeDESC
                                   ,A.FreshOriginalDCCO
                                   ,A.RevisedDCCO
                                   ,A.CourtCaseArbitration
								  -- ,A.CourtCaseArbitrationDESC
                                   ,A.ChangeinOwnerShip
								  -- ,A.ChangeinOwnerShipDESC
                                   ,A.CIOReferenceDate
                                   ,A.CIODCCO
								   --,A.CostOverRunDESC
                                   ,A.CostOverRun
                                   ,A.RevisedProjectCost
                                   ,A.RevisedDebt
                                   ,A.RevisedDebt_EquityRatio
                                   ,A.TakeOutFinance
								  -- ,A.TakeOutFinanceDESC
								    ,A.AssetClassSellerBook
                                   ,A.AssetClassSellerBookAlt_key
                                   ,A.NPADtClsSellBook
                                   ,A.Restructuring
								   --,A.RestructuringDESC,
							,A.AuthorisationStatus, 
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
							,A.InitialExtenstion
							,A.ExtnReason_BCP
							,A.Npa_date
							,A.Npa_Reason
							,A.AssetClassAlt_Key
							,A.ActualDCCO_Achieved
							,A.ActualDCCO_Date
							,A.RM_CreditOfficer
                 INTO #temp20
                 FROM 
                 (
                     SELECT  A.CustomerID
								   ,A.AccountID
                                   ,A.ChangeinProjectScope
								  -- ,case when A.ChangeinProjectScope=1 THEN 'Y' ELSE 'N' END AS ChangeinProjectScopeDESC
                                   --,A.FreshOriginalDCCO
                                     ,convert(varchar(10),A.FreshOriginalDCCO ,103) FreshOriginalDCCO
                                   ,convert(varchar(10),A.RevisedDCCO ,103) RevisedDCCO 
                                   ,A.CourtCaseArbitration
								  -- ,case when A.CourtCaseArbitration=1 THEN 'Y' ELSE 'N' END AS CourtCaseArbitrationDESC
                                   ,A.ChangeinOwnerShip
								  -- ,case when A.ChangeinOwnerShip=1 THEN 'Y' ELSE 'N' END AS ChangeinOwnerShipDESC
                                   ,convert(varchar(10),A.CIOReferenceDate ,103) CIOReferenceDate
                                   ,convert(varchar(10),A.CIODCCO ,103) CIODCCO 
								 --  ,case when A.CostOverRun=1 THEN 'Y' ELSE 'N' END AS CostOverRunDESC
                                   ,A.CostOverRun
                                   ,A.RevisedProjectCost
                                   ,A.RevisedDebt
                                   ,A.RevisedDebt_EquityRatio
                                   ,A.TakeOutFinance
								  -- ,case when A.TakeOutFinance=1 THEN 'Y' ELSE 'N' END AS TakeOutFinanceDESC
								   ,case when A.AssetClassSellerBookAlt_key=1 then 'STD'
								         ELSE 'NPA' END AS AssetClassSellerBook
                                   ,A.AssetClassSellerBookAlt_key
                                   --,convert(varchar(10),A.NPADateSellerBook ,103) NPADateSellerBook 
								    ,case when convert(varchar(10),A.NPADateSellerBook ,103) in ('01/01/1900','')then null
								     else convert(varchar(10),A.NPADateSellerBook ,103) end   NPADtClsSellBook 
                                   ,ISNULL(C.Restructuring,'N') Restructuring
								   -- ,case when C.Restructuring=1 THEN 'Y' ELSE 'N' END AS RestructuringDESC,
							,A.AuthorisationStatus AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified
							--,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							--,IsNull(A.DateModified,A.DateCreated)as CrModDate
							--,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							--,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							--,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							--,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
							,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.FirstLevelApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.FirstLevelDateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.FirstLevelApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.FirstLevelDateApproved,A.DateModified) as ModAppDate
							,A.InitialExtenstion
							--,CASE WHEN A.InitialExtenstion=NULL THEN 'No' else A.InitialExtenstion end InitialExtenstion
							,A.ExtnReason_BCP
							,convert(varchar(10),C.NPA_DATE,103)Npa_date
							,C.DEFAULT_REASON Npa_Reason
							,C.FinalAssetClassAlt_Key AssetClassAlt_Key
							,A.ActualDCCO_Achieved
							,convert(varchar(10),A.ActualDCCO_Date,103) ActualDCCO_Date
							,A.RM_CreditOfficer
                     FROM AdvAcPUIDetailSub_Mod A
					  INNER JOIN  CURDAT.AdvAcBasicDetail B
					 ON          A.AccountID=B.CustomerACID AND  B.EffectiveFromTimeKey <= @TimeKey
                           AND B.EffectiveToTimeKey >= @TimeKey
					 LEFT JOIN  PRO.PUI_CAL C
					 ON          B.AccountEntityId=C.AccountEntityId AND  C.EffectiveFromTimeKey <= @TimeKey
                           AND C.EffectiveToTimeKey >= @TimeKey
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           AND ISNULL(A.AuthorisationStatus, 'A') IN('1A')
                           AND A.EntityKey IN
                     (
                      SELECT MAX(EntityKey)
                         FROM AdvAcPUIDetailSub_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('1A')
							    GROUP BY EntityKey
                     )
                 ) A 
                      
                 
                 GROUP BY    A.CustomerID
								   ,A.AccountID
                                   ,A.ChangeinProjectScope
								  -- ,A.ChangeinProjectScopeDESC
                                   ,A.FreshOriginalDCCO
                                   ,A.RevisedDCCO
                                   ,A.CourtCaseArbitration
								   --,A.CourtCaseArbitrationDESC
                                   ,A.ChangeinOwnerShip
								 --  ,A.ChangeinOwnerShipDESC
                                   ,A.CIOReferenceDate
                                   ,A.CIODCCO
								  -- ,A.CostOverRunDESC
                                   ,A.CostOverRun
                                   ,A.RevisedProjectCost
                                   ,A.RevisedDebt
                                   ,A.RevisedDebt_EquityRatio
                                   ,A.TakeOutFinance
								  -- ,A.TakeOutFinanceDESC
								    ,A.AssetClassSellerBook
                                   ,A.AssetClassSellerBookAlt_key
                                   ,A.NPADtClsSellBook
                                   ,A.Restructuring
								   --,A.RestructuringDESC,
							,A.AuthorisationStatus, 
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
							,A.InitialExtenstion
							,A.ExtnReason_BCP
							,A.Npa_date
							,A.Npa_Reason
							,A.AssetClassAlt_Key
							,A.ActualDCCO_Achieved
							,A.ActualDCCO_Date
							,A.RM_CreditOfficer
                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY AssetClassSellerBookAlt_key) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'UpdatePUI' TableName, 
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

	select *,'PUIUpdateProjectStatus' AS tableName from MetaScreenFieldDetail where ScreenName='UpdateProjectStatusPUI'
  
  
    END;

GO