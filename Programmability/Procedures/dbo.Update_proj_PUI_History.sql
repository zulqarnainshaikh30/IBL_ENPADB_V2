SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Exec Update_proj_PUI_SearchList @OperationFlag=1

CREATE PROC [dbo].[Update_proj_PUI_History]
--Declare
		@AccountID varchar(30)=''
     				
AS


	 BEGIN
	 Declare @TimeKey as Int
	SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')
                
               
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
                            ,cAST(A.DateCreated  AS DATE) DateCreated
                            ,A.ApprovedBy 
                            ,cAST(A.DateApproved  AS DATE) DateApproved
                            ,A.ModifiedBy 
                            ,cAST(A.DateModified AS DATE) DateModified
							,A.CrModBy
							,cAST(A.CrModDate  AS DATE) CrModDate
							,A.CrAppBy
							,cAST(A.CrAppDate  AS DATE) CrAppDate
							,A.ModAppBy
							,cAST(A.ModAppDate  AS DATE) ModAppDate
							,A.InitialExtenstion
							,A.ExtnReason_BCP
							,cAST(A.Npa_date  AS DATE) Npa_date
							,A.Npa_Reason
							,A.AssetClassAlt_Key
							,A.FirstLevelApprovedBy
							,A.DateApprovedFirstLevel
							,A.ActualDCCO_Achieved
							,A.ActualDCCO_Date
                 
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
								         when A.AssetClassSellerBookAlt_key is null then ''
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
							,A.FirstLevelApprovedBy
							,Convert(Varchar(20),A.FirstLevelDateApproved,103) DateApprovedFirstLevel
							,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
							,A.InitialExtenstion
							--,CASE WHEN A.InitialExtenstion=NULL THEN 'No' else A.InitialExtenstion end InitialExtenstion
							,A.ExtnReason_BCP
							,convert(varchar(10),C.NPA_DATE,103) Npa_date
							,C.DEFAULT_REASON   Npa_Reason
							,C.FinalAssetClassAlt_Key  AssetClassAlt_Key
							,A.ActualDCCO_Achieved
							,convert(varchar(10),A.ActualDCCO_Date,103) ActualDCCO_Date
                     FROM AdvAcPUIDetailSub A 
					 INNER JOIN  CURDAT.AdvAcBasicDetail B
					 ON          A.AccountID=B.CustomerACID AND  B.EffectiveFromTimeKey <= @TimeKey
                           AND B.EffectiveToTimeKey >= @TimeKey
					 LEFT JOIN  PRO.PUI_CAL C
					 ON          B.AccountEntityId=C.AccountEntityId AND  C.EffectiveFromTimeKey <= @TimeKey
                           AND C.EffectiveToTimeKey >= @TimeKey
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
						   AND AccountID = @AccountID
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
								         when A.AssetClassSellerBookAlt_key is null then ''
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
							,A.FirstLevelApprovedBy
							,Convert(Varchar(20),A.FirstLevelDateApproved,103) DateApprovedFirstLevel
							,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
							,A.InitialExtenstion
							--,CASE WHEN A.InitialExtenstion=NULL THEN 'No' else A.InitialExtenstion end InitialExtenstion
							,A.ExtnReason_BCP
							,convert(varchar(10),C.NPA_DATE,103) Npa_date
							,C.DEFAULT_REASON Npa_Reason
							,C.FinalAssetClassAlt_Key  AssetClassAlt_Key
							,A.ActualDCCO_Achieved
							,convert(varchar(10),A.ActualDCCO_Date,103) ActualDCCO_Date
                     FROM AdvAcPUIDetailSub_Mod A
					  INNER JOIN  CURDAT.AdvAcBasicDetail B
					 ON          A.AccountID=B.CustomerACID AND  B.EffectiveFromTimeKey <= @TimeKey
                           AND B.EffectiveToTimeKey >= @TimeKey
					 LEFT JOIN  PRO.PUI_CAL C
					 ON          B.AccountEntityId=C.AccountEntityId AND  C.EffectiveFromTimeKey <= @TimeKey
                           AND C.EffectiveToTimeKey >= @TimeKey
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
						   AND AccountID = @AccountID
                          -- AND ISNULL(a.AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A','FM')
						  AND ISNULL(a.AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')
                           --AND A.EntityKey IN
                     --(
                     --    SELECT MAX(EntityKey)
                     --    FROM AdvAcPUIDetailSub_Mod
                     --    WHERE EffectiveFromTimeKey <= @TimeKey
                     --          AND EffectiveToTimeKey >= @TimeKey
                     --          AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')
                     --    GROUP BY EntityKey
                     --)
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
							,A.FirstLevelApprovedBy
							,A.DateApprovedFirstLevel
							,A.ActualDCCO_Achieved
							,A.ActualDCCO_Date
                   order BY a.DateCreated desc  ,a.DateModified desc,a.CrModDate  DESC ,a.DateApproved desc 
    END
GO