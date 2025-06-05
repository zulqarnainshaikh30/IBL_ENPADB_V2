SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROC [dbo].[DerivativeDetailSearchList]
--Declare
													
													--@PageNo         INT         = 1, 
													--@PageSize       INT         = 10, 
													@OperationFlag  INT         = 2,
													@AccountID Varchar(30)='',
													@CustomerID Varchar(30)=''
AS
     
	 BEGIN

SET NOCOUNT ON;
Declare @TimeKey as Int
	SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')
					

BEGIN TRY

/*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */
             IF (ISNULL(@AccountID,'')='' AND  ISNULL(@CustomerID,'')='') AND @OperationFlag IN(1,2)
			    BEGIN
				    IF OBJECT_ID('TempDB..#tempall') IS NOT NULL
                 DROP TABLE  #tempall;
                 SELECT		A.EntityKey,
                            A.DerivativeEntityID,
                            A.CustomerACID,
                            A.CustomerID,
                            A.CustomerName,
                            A.DerivativeRefNo,
                            A.Duedate,
                            A.DueAmt,
                            A.OsAmt,
                            A.POS,
							OverDueSinceDt,
							DueAmtReceivable,
							MTMIncomeAmt,
							CouponDate,
							CouponAmt,
							CouponOverDueSinceDt,
							OverdueCouponAmt,
							InstrumentName,
							FinalAssetClassAlt_Key,
							AssetclassName,
							NPIDt,
							FLGDEG,
							DEGREASON,
							DPD,
							FLGUPG,
							UpgDate,
                            A.AuthorisationStatus,
                            A.EffectiveFromTimeKey,
                            A.EffectiveToTimeKey,
                            A.CreatedBy,
                            A.DateCreated,
                            A.ModifiedBy,
                            A.DateModified,
							A.CrModBy
							,A.CrModDate,
                            A.ApprovedBy,
                            A.DateApproved,
							A.ChangeFields
							
                 INTO #tempall
                 FROM 
                 (
                     SELECT 
							A.EntityKey,
                            A.DerivativeEntityID,
                            A.CustomerACID,
                            A.CustomerID,
                            A.CustomerName,
                            A.DerivativeRefNo,
                            Convert(Varchar(10),A.Duedate,103) Duedate,
                            A.DueAmt,
                            A.OsAmt,
                            A.POS,
							Convert(Varchar(10),OverDueSinceDt,103) OverDueSinceDt,
							DueAmtReceivable,
							MTMIncomeAmt,

							Convert(Varchar(10),CouponDate,103) CouponDate,
							CouponAmt,
							Convert(Varchar(10),CouponOverDueSinceDt,103) CouponOverDueSinceDt,
							OverdueCouponAmt,
							InstrumentName,
							FinalAssetClassAlt_Key,
							AssetclassName,
							Convert(Varchar(10),NPIDt,103) NPIDt,
							FLGDEG,
							DEGREASON,
							DPD,
							FLGUPG,
							Convert(Varchar(10),UpgDate,103) UpgDate,
                            isnull(A.AuthorisationStatus, 'A') AuthorisationStatus,
                            A.EffectiveFromTimeKey,
                            A.EffectiveToTimeKey,
                            A.CreatedBy,
                            A.DateCreated,
                            A.ModifiedBy,
                            A.DateModified,
								IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
								,IsNull(A.DateModified,A.DateCreated)as CrModDate,
                            A.ApprovedBy,
                            A.DateApproved,
							A.ChangeFields
                    
                    FROM curdat.DerivativeDetail A 
					 INNER JOIN DimAssetClass B ON A.FinalAssetClassAlt_key = B.AssetClassAlt_Key
					 AND B.EffectiveFromTimeKey <= @TimeKey
                           AND B.EffectiveToTimeKey >= @TimeKey
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
						  
      --               UNION
      --               SELECT A.EntityKey,
      --                      A.DerivativeEntityID,
      --                      A.CustomerACID,
      --                      A.CustomerID,
      --                      A.CustomerName,
      --                      A.DerivativeRefNo,
      --                      Convert(Varchar(10),A.Duedate,103) Duedate,
      --                      A.DueAmt,
      --                      A.OsAmt,
      --                      A.POS,
						--	Convert(Varchar(10),OverDueSinceDt,103) OverDueSinceDt,
						--	DueAmtReceivable,
						--	MTMIncomeAmt,
						--	Convert(Varchar(10),CouponDate,103) CouponDate,
						--	CouponAmt,
						--	Convert(Varchar(10),CouponOverDueSinceDt,103) CouponOverDueSinceDt,
						--	OverdueCouponAmt,

      --                      isnull(A.AuthorisationStatus, 'A') AuthorisationStatus,
      --                      A.EffectiveFromTimeKey,
      --                      A.EffectiveToTimeKey,
      --                      A.CreatedBy,
      --                      A.DateCreated,
      --                      A.ModifiedBy,
      --                      A.DateModified,
						--	IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
						--		,IsNull(A.DateModified,A.DateCreated)as CrModDate,
      --                      A.ApprovedBy,
      --                      A.DateApproved,
						--	A.ChangeFields
      --               FROM DerivativeDetail_Mod A 
					 --WHERE A.EffectiveFromTimeKey <= @TimeKey
      --                     AND A.EffectiveToTimeKey >= @TimeKey
						  
      --                     AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')
      --                     AND A.EntityKey IN
      --               (
      --                   SELECT MAX(EntityKey)
      --                   FROM DerivativeDetail_Mod
      --                   WHERE EffectiveFromTimeKey <= @TimeKey
      --                         AND EffectiveToTimeKey >= @TimeKey
      --                         AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')
      --                   GROUP BY EntityKey
      --               )
                 ) A 
                      
                 
                 GROUP BY A.EntityKey,
                            A.DerivativeEntityID,
                            A.CustomerACID,
                            A.CustomerID,
                            A.CustomerName,
                            A.DerivativeRefNo,
                            A.Duedate,
                            A.DueAmt,
                            A.OsAmt,
                            A.POS,
							OverDueSinceDt,
							DueAmtReceivable,
							MTMIncomeAmt,
							CouponDate,
							CouponAmt,
							CouponOverDueSinceDt,
							OverdueCouponAmt,
							InstrumentName,
							FinalAssetClassAlt_Key,
							AssetclassName,
							NPIDt,
							FLGDEG,
							DEGREASON,
							DPD,
							FLGUPG,
							UpgDate,
                            A.AuthorisationStatus,
                            A.EffectiveFromTimeKey,
                            A.EffectiveToTimeKey,
                            A.CreatedBy,
                            A.DateCreated,
                            A.ModifiedBy,
                            A.DateModified,
							A.CrModBy
							,A.CrModDate,
                            A.ApprovedBy,
                            A.DateApproved,
							A.ChangeFields
                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY EntityKey) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'DerivativeMaster' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #tempall A
                         --WHERE CustomerACID= LIKE '%'+@BankShortName+'%'
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
                 --      AND RowNumber <= (@PageNo * @PageSize);
             END;
			

			IF(@OperationFlag not in (16,17,20))
             BEGIN
			 IF OBJECT_ID('TempDB..#temp') IS NOT NULL
                 DROP TABLE  #temp;
                 SELECT		A.EntityKey,
                            A.DerivativeEntityID,
                            A.CustomerACID,
                            A.CustomerID,
                            A.CustomerName,
                            A.DerivativeRefNo,
                            A.Duedate,
                            A.DueAmt,
                            A.OsAmt,
                            A.POS,
							OverDueSinceDt,
							DueAmtReceivable,
							MTMIncomeAmt,
							CouponDate,
							CouponAmt,
							CouponOverDueSinceDt,
							OverdueCouponAmt,
							InstrumentName,
							FinalAssetClassAlt_Key,
							AssetclassName,
							NPIDt,
							FLGDEG,
							DEGREASON,
							DPD,
							FLGUPG,
							UpgDate,
                            A.AuthorisationStatus,
                            A.EffectiveFromTimeKey,
                            A.EffectiveToTimeKey,
                            A.CreatedBy,
                            A.DateCreated,
                            A.ModifiedBy,
                            A.DateModified,
							A.CrModBy
							,A.CrModDate,
                            A.ApprovedBy,
                            A.DateApproved,
							A.ChangeFields
                 INTO #temp
                 FROM 
                 (
                     SELECT 
							A.EntityKey,
                            A.DerivativeEntityID,
                            A.CustomerACID,
                            A.CustomerID,
                            A.CustomerName,
                            A.DerivativeRefNo,
                            Convert(Varchar(10),A.Duedate,103) Duedate,
                            A.DueAmt,
                            A.OsAmt,
                            A.POS,
							Convert(Varchar(10),OverDueSinceDt,103) OverDueSinceDt,
							DueAmtReceivable,
							MTMIncomeAmt,
							Convert(Varchar(10),CouponDate,103) CouponDate,
							CouponAmt,
							Convert(Varchar(10),CouponOverDueSinceDt,103) CouponOverDueSinceDt,
							OverdueCouponAmt,
							InstrumentName,
							FinalAssetClassAlt_Key,
							AssetclassName,
							Convert(Varchar(10),NPIDt,103) NPIDt,
							FLGDEG,
							DEGREASON,
							DPD,
							FLGUPG,
							Convert(Varchar(10),UpgDate,103) UpgDate,
                            isnull(A.AuthorisationStatus, 'A') AuthorisationStatus,
                            A.EffectiveFromTimeKey,
                            A.EffectiveToTimeKey,
                            A.CreatedBy,
                            A.DateCreated,
                            A.ModifiedBy,
                            A.DateModified,
								IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
								,IsNull(A.DateModified,A.DateCreated)as CrModDate,
                            A.ApprovedBy,
                            A.DateApproved,
							A.ChangeFields
                            
							
                     FROM curdat.DerivativeDetail A 
					 INNER JOIN DimAssetClass B ON A.FinalAssetClassAlt_key = B.AssetClassAlt_Key
					 AND B.EffectiveFromTimeKey <= @TimeKey
                           AND B.EffectiveToTimeKey >= @TimeKey
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
						   AND (A.CustomerACID=@AccountID OR A.CustomerID=@CustomerID)
      --               UNION
      --               SELECT A.EntityKey,
      --                      A.DerivativeEntityID,
      --                      A.CustomerACID,
      --                      A.CustomerID,
      --                      A.CustomerName,
      --                      A.DerivativeRefNo,
      --                      Convert(Varchar(10),A.Duedate,103) Duedate,
      --                      A.DueAmt,
      --                      A.OsAmt,
      --                      A.POS,
						--	Convert(Varchar(10),OverDueSinceDt,103) OverDueSinceDt,
						--	DueAmtReceivable,
						--	MTMIncomeAmt,
						--	Convert(Varchar(10),CouponDate,103) CouponDate,
						--	CouponAmt,
						--	Convert(Varchar(10),CouponOverDueSinceDt,103) CouponOverDueSinceDt,
						--	OverdueCouponAmt,
      --                      isnull(A.AuthorisationStatus, 'A') AuthorisationStatus,
      --                      A.EffectiveFromTimeKey,
      --                      A.EffectiveToTimeKey,
      --                      A.CreatedBy,
      --                      A.DateCreated,
      --                      A.ModifiedBy,
      --                      A.DateModified,
						--	IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
						--		,IsNull(A.DateModified,A.DateCreated)as CrModDate,
      --                      A.ApprovedBy,
      --                      A.DateApproved,
						--	A.ChangeFields
      --             select *  FROM DerivativeDetail_Mod A 
					 --INNER JOIN DimAssetClass B ON A.FinalAssetClassAlt_key = B.AssetClassAlt_Key
					 --AND B.EffectiveFromTimeKey <= @TimeKey
      --                     AND B.EffectiveToTimeKey >= @TimeKey
					 --WHERE A.EffectiveFromTimeKey <= @TimeKey
      --                     AND A.EffectiveToTimeKey >= @TimeKey
						--   AND (A.CustomerACID=@AccountID OR A.CustomerID=@CustomerID)
      --                     AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')
      --                     AND A.EntityKey IN
      --               (
      --                   SELECT MAX(EntityKey)
      --                   FROM DerivativeDetail_Mod
      --                   WHERE EffectiveFromTimeKey <= @TimeKey
      --                         AND EffectiveToTimeKey >= @TimeKey
      --                         AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')
      --                   GROUP BY EntityKey
      --               )
                 ) A 
                      
                 
                 GROUP BY A.EntityKey,
                            A.DerivativeEntityID,
                            A.CustomerACID,
                            A.CustomerID,
                            A.CustomerName,
                            A.DerivativeRefNo,
                            A.Duedate,
                            A.DueAmt,
                            A.OsAmt,
                            A.POS,
							OverDueSinceDt,
							DueAmtReceivable,
							MTMIncomeAmt,
							CouponDate,
							CouponAmt,
							CouponOverDueSinceDt,
							OverdueCouponAmt,
							InstrumentName,
							FinalAssetClassAlt_Key,
							AssetclassName,
							NPIDt,
							FLGDEG,
							DEGREASON,
							DPD,
							FLGUPG,
							UpgDate,
                            A.AuthorisationStatus,
                            A.EffectiveFromTimeKey,
                            A.EffectiveToTimeKey,
                            A.CreatedBy,
                            A.DateCreated,
                            A.ModifiedBy,
                            A.DateModified,
							A.CrModBy
							,A.CrModDate,
                            A.ApprovedBy,
                            A.DateApproved,
							A.ChangeFields
                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY EntityKey) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'DerivativeMaster' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp A
                         --WHERE CustomerACID= LIKE '%'+@BankShortName+'%'
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
                 --      AND RowNumber <= (@PageNo * @PageSize);
             END;
 --            ELSE

	--		 /*  IT IS Used For GRID Search which are Pending for Authorization    */
	--		 IF (@OperationFlag in(16,17))

 --            BEGIN
	--		 IF OBJECT_ID('TempDB..#temp16') IS NOT NULL
 --                DROP TABLE #temp16;
 --                SELECT A.EntityKey,
 --                           A.DerivativeEntityID,
 --                           A.CustomerACID,
 --                           A.CustomerID,
 --                           A.CustomerName,
 --                           A.DerivativeRefNo,
 --                           Convert(Varchar(10),A.Duedate,103) Duedate,
 --                           A.DueAmt,
 --                           A.OsAmt,
 --                           A.POS,
	--						OverDueSinceDt,
	--						DueAmtReceivable,
	--						MTMIncomeAmt,
	--						CouponDate,
	--						CouponAmt,
	--						CouponOverDueSinceDt,
	--						OverdueCouponAmt,
 --                           A.AuthorisationStatus,
 --                           A.EffectiveFromTimeKey,
 --                           A.EffectiveToTimeKey,
 --                           A.CreatedBy,
 --                           A.DateCreated,
 --                           A.ModifiedBy,
 --                           A.DateModified,
	--						A.CrModBy
	--						,A.CrModDate,
 --                           A.ApprovedBy,
 --                           A.DateApproved,
	--						A.ChangeFields
 --                INTO #temp16
 --                FROM 
 --                (
 --                    SELECT A.EntityKey,
 --                           A.DerivativeEntityID,
 --                           A.CustomerACID,
 --                           A.CustomerID,
 --                           A.CustomerName,
 --                           A.DerivativeRefNo,
 --                           A.Duedate,
 --                           A.DueAmt,
 --         A.OsAmt,
 --                           A.POS,
	--						Convert(Varchar(10),OverDueSinceDt,103) OverDueSinceDt,
	--						DueAmtReceivable,
	--						MTMIncomeAmt,
	--						Convert(Varchar(10),CouponDate,103) CouponDate,
	--						CouponAmt,
	--						Convert(Varchar(10),CouponOverDueSinceDt,103) CouponOverDueSinceDt,
	--						OverdueCouponAmt,
 --                           isnull(A.AuthorisationStatus, 'A') AuthorisationStatus,
 --                           A.EffectiveFromTimeKey,
 --                           A.EffectiveToTimeKey,
 --                           A.CreatedBy,
 --                           A.DateCreated,
 --                           A.ModifiedBy,
 --                           A.DateModified,
	--							IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
	--							,IsNull(A.DateModified,A.DateCreated)as CrModDate,
 --                           A.ApprovedBy,
 --                           A.DateApproved,
	--						A.ChangeFields
							
 --                    FROM DerivativeDetail_Mod A 
	--				WHERE A.EffectiveFromTimeKey <= @TimeKey
 --                          AND A.EffectiveToTimeKey >= @TimeKey
 --                          AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')
						 
 --                          AND A.EntityKey IN
 --                    (
 --                        SELECT MAX(EntityKey)
 --                        FROM DerivativeDetail_Mod
 --                        WHERE EffectiveFromTimeKey <= @TimeKey
 --                              AND EffectiveToTimeKey >= @TimeKey
 --                              AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')
	--						    GROUP BY EntityKey
 --                    )
 --                ) A 
                      
                 
 --                GROUP BY A.EntityKey,
 --                           A.DerivativeEntityID,
 --                           A.CustomerACID,
 --                           A.CustomerID,
 --                           A.CustomerName,
 --                           A.DerivativeRefNo,
 --                           A.Duedate,
 --                           A.DueAmt,
 --                           A.OsAmt,
 --                           A.POS,
	--						OverDueSinceDt,
	--						DueAmtReceivable,
	--						MTMIncomeAmt,
	--						CouponDate,
	--						CouponAmt,
	--						CouponOverDueSinceDt,
	--						OverdueCouponAmt,
 --                           A.AuthorisationStatus,
 --                           A.EffectiveFromTimeKey,
 --                           A.EffectiveToTimeKey,
 --                           A.CreatedBy,
 --                           A.DateCreated,
 --                           A.ModifiedBy,
 --                           A.DateModified,
	--						A.CrModBy
	--						,A.CrModDate,
 --                           A.ApprovedBy,
 --                           A.DateApproved,
	--						A.ChangeFields

 --                SELECT *
 --                FROM
 --                (
 --                    SELECT ROW_NUMBER() OVER(ORDER BY EntityKey) AS RowNumber, 
 --                           COUNT(*) OVER() AS TotalCount, 
 --                           'DerivativeMaster' TableName, 
 --                           *
 --                    FROM
 --                    (
 --                        SELECT *
 --                        FROM #temp16 A
 --                        --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
 --                        --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
 --                    ) AS DataPointOwner
 --                ) AS DataPointOwner
 --                --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
 --                --      AND RowNumber <= (@PageNo * @PageSize)

 --  END;

 --  Else

 --  IF (@OperationFlag =20)
 --            BEGIN
	--		 IF OBJECT_ID('TempDB..#temp20') IS NOT NULL
 --                DROP TABLE #temp20;
 --                SELECT A.EntityKey,
 --                           A.DerivativeEntityID,
 --                           A.CustomerACID,
 --                           A.CustomerID,
 --                           A.CustomerName,
 --                           A.DerivativeRefNo,
 --                           Convert(Varchar(10),A.Duedate,103) Duedate,
 --                           A.DueAmt,
 --                           A.OsAmt,
 --                           A.POS,
	--						OverDueSinceDt,
	--						DueAmtReceivable,
	--						MTMIncomeAmt,
	--						CouponDate,
	--						CouponAmt,
	--						CouponOverDueSinceDt,
	--						OverdueCouponAmt,
 --                           A.AuthorisationStatus,
 --                           A.EffectiveFromTimeKey,
 --                           A.EffectiveToTimeKey,
 --                           A.CreatedBy,
 --                           A.DateCreated,
 --                           A.ModifiedBy,
 --      A.DateModified,
	--						A.CrModBy
	--						,A.CrModDate,
 --                           A.ApprovedBy,
 --                           A.DateApproved,
	--						A.ChangeFields
 --                INTO #temp20
 --                FROM 
 --                (
 --                    SELECT A.EntityKey,
 --                           A.DerivativeEntityID,
 --                           A.CustomerACID,
 --                           A.CustomerID,
 --                           A.CustomerName,
 --                           A.DerivativeRefNo,
 --                           A.Duedate,
 --                           A.DueAmt,
 --                           A.OsAmt,
 --                           A.POS,
	--						OverDueSinceDt,
	--						DueAmtReceivable,
	--						MTMIncomeAmt,
	--						CouponDate,
	--						CouponAmt,
	--						CouponOverDueSinceDt,
	--						OverdueCouponAmt,
 --                           A.AuthorisationStatus AuthorisationStatus,
 --                           A.EffectiveFromTimeKey,
 --                           A.EffectiveToTimeKey,
 --                           A.CreatedBy,
 --                           A.DateCreated,
 --                           A.ModifiedBy,
 --                           A.DateModified,
	--							IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
	--							,IsNull(A.DateModified,A.DateCreated)as CrModDate,
 --                           A.ApprovedBy,
 --                           A.DateApproved,
	--						A.ChangeFields
 --                    FROM DerivativeDetail_Mod A 
	--				WHERE A.EffectiveFromTimeKey <= @TimeKey
 --                          AND A.EffectiveToTimeKey >= @TimeKey
 --                          AND ISNULL(A.AuthorisationStatus, 'A') IN('1A')
						  
 --                          AND A.EntityKey IN
 --                    (
 --                        SELECT MAX(EntityKey)
 --                        FROM DerivativeDetail_Mod
 --                        WHERE EffectiveFromTimeKey <= @TimeKey
 --                              AND EffectiveToTimeKey >= @TimeKey
 --                              AND AuthorisationStatus IN('1A')
 --                        GROUP BY EntityKey
 --                    )
 --                ) A 
                      
                 
 --                GROUP BY A.EntityKey,
 --                           A.DerivativeEntityID,
 --                           A.CustomerACID,
 --                           A.CustomerID,
 --                           A.CustomerName,
 --                           A.DerivativeRefNo,
 --                           A.Duedate,
 --                           A.DueAmt,
 --                           A.OsAmt,
 --                           A.POS,
	--						OverDueSinceDt,
	--						DueAmtReceivable,
	--						MTMIncomeAmt,
	--						CouponDate,
	--						CouponAmt,
	--						CouponOverDueSinceDt,
	--						OverdueCouponAmt,
 --                           A.AuthorisationStatus,
 --                           A.EffectiveFromTimeKey,
 --                           A.EffectiveToTimeKey,
 --                           A.CreatedBy,
 --                           A.DateCreated,
 --                           A.ModifiedBy,
 --                           A.DateModified,
	--						A.CrModBy
	--						,A.CrModDate,
 --                           A.ApprovedBy,
 --                           A.DateApproved,
	--						A.ChangeFields
 --                SELECT *
 --                FROM
 --                (
 --                    SELECT ROW_NUMBER() OVER(ORDER BY EntityKey) AS RowNumber, 
 --                           COUNT(*) OVER() AS TotalCount, 
 --                           'DerivativeMaster' TableName, 
 --                           *
 --                    FROM
 --                    (
 --                        SELECT *
 --                        FROM #temp20 A
 --                        --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
 --                        --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
 --                    ) AS DataPointOwner
 --                ) AS DataPointOwner
 --                --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
 --                --      AND RowNumber <= (@PageNo * @PageSize)

 --  END;


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