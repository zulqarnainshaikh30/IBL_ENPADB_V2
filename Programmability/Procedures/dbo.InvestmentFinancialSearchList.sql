SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-----------------------------------------------------
--exec InvestmentFinancialSearchList @PAN=N'',@IssuerID=N'',@IssuerName=N''
--,@InvID=N'',@InstrumentTypeAlt_key=N'',@ISIN=NULL,@OperationFlag=1
--go
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

      CREATE PROC [dbo].[InvestmentFinancialSearchList]
--Declare                     
              @IssuerID                         Varchar (100)           = ''
             ,@IssuerName                       Varchar (100)           = ''
            , @Pan                                    Varchar (100)           = ''
             ,@InvID                            Varchar (100)           = ''
             ,@InstrumentTypeAlt_Key      Varchar (100)       = ''
             ,@ISIN                                   Varchar (100)       = ''
            --,@InvID                     Varchar (100)           = ''
            --,@InstrTypeAlt_key    Varchar (100)           = ''
            --,@ISIN                      varchar (100)           = ''
             ,@OperationFlag        INT                           = 1
            
                                                                              --@PageNo         INT         = 1,
                                                                              --@PageSize       INT         = 10,
                                                                              --@OperationFlag  INT         = 1
AS
     
       BEGIN

SET NOCOUNT ON;
Declare @TimeKey as Int
      SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')
      set @ISIN =case when @ISIN IS NULL THEN '' Else @ISIN END                     
SET DATEFORMAT DMY
BEGIN TRY

/*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */

                  IF(@OperationFlag not in (16,17,20))
             BEGIN
                   IF OBJECT_ID('TempDB..#temp') IS NOT NULL
                 DROP TABLE  #temp;
                 SELECT       A.EntityKey,
                            A.InvEntityId,
                                          A.BranchCode,
                                          A.SourceAlt_Key,
                                          A.SourceName,
                            A.RefInvID,
                            A.RefIssuerID,
                                          A.IssuerName,
                            A.HoldingNature,
                            A.CurrencyAlt_Key,
                                          A.CurrencyName,
                            A.CurrencyConvRate,
                            A.BookType,
                            A.BookValue,
                            A.BookValueINR,
                            A.MTMValue,
                            A.MTMValueINR,
                            A.EncumberedMTM,
                            A.AssetClass_AltKey,
                                          A.AssetClassName,
                            A.NPIDt,
                            A.TotalProvison,
							 A.InstrTypeAlt_Key,
                            A.InstrName,
							 A.ExposureType,
							   A.MaturityDt,
                            A.ReStructureDate,
							A.UcifId,
							A.Ref_Txn_Sys_Cust_ID,
							A.Issuer_Category_Code ,
                            A.GrpEntityOfBank,
                            A.AuthorisationStatus,
                            A.EffectiveFromTimeKey,
                            A.EffectiveToTimeKey,
                            A.CreatedBy,
                            A.DateCreated,
                            A.ModifiedBy,
                            A.DateModified,
                                          A.CrModBy,
                                           A.CrModDate,
                            A.ApprovedBy,
                            A.DateApproved,
                            A.DBTDate,
                            A.LatestBSDate,
                            A.Interest_DividendDueDate,
                            A.Interest_DividendDueAmount,
                            A.PartialRedumptionDueDate,
                            A.PartialRedumptionSettledY_N,
                                          pANnO,
                                          ISIN,
                                          InstrumentTypeAlt_Key,
                                          InstrumentTypeName
                                          ,InvestmentNature
                                          ,Sector
                                          ,a.Industry_AltKey
                                          ,IndustryName
                                          ,SecurityValue
                                          ,[DegradationFlag]
                                          ,[DegradationReason]
                                          ,DPD
                                          ,[UpgradationFlag]
                                          ,[UpgradationDate]
                                          ,A.changeFields
                 INTO #temp
                 FROM
                 (
                     SELECT
                             	A.EntityKey,
								A.InvEntityId,
                                          Y.BranchCode,
                                          Y.SourceAlt_Key,
                                          O.SourceName,
                            A.RefInvID,                                       
                            A.RefIssuerID,
                                          Y.IssuerName,
                            A.HoldingNature,
                            A.CurrencyAlt_Key,
                                          B.CurrencyName,
                            A.CurrencyConvRate,
                            A.BookType,
                            A.BookValue,
                            A.BookValueINR,
                            A.MTMValue,
                            A.MTMValueINR,
                            A.EncumberedMTM,
                            A.AssetClass_AltKey,
                                          C.AssetClassName,
                            convert(varchar(10),A.NPIDt, 103)  as NPIDt,
                            A.TotalProvison,
							 X.InstrTypeAlt_Key,
                            X.InstrName,
							 X.ExposureType,
							convert(varchar(10),X.MaturityDt,103)  as MaturityDt,
                            convert(varchar(10),X.ReStructureDate,103) as ReStructureDate,
							Y.UcifId,
							Y.Ref_Txn_Sys_Cust_ID,
							Y.Issuer_Category_Code,
                            Y.GrpEntityOfBank,
                           isnull(A.AuthorisationStatus, 'A') AuthorisationStatus,
                            A.EffectiveFromTimeKey,
                            A.EffectiveToTimeKey,
                            A.CreatedBy,
                            A.DateCreated,
                            A.ModifiedBy,
                            A.DateModified,
                                          IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy,
                                          IsNull(A.DateModified,A.DateCreated)as CrModDate,
                            A.ApprovedBy,
                            A.DateApproved,
                            --A.DBTDate,
                                          convert(varchar(10),A.DBTDate, 103)  as DBTDate,
                            --A.LatestBSDate,
                                          convert(varchar(10),A.LatestBSDate, 103)  as LatestBSDate,
                            --A.Interest_DividendDueDate,
                                          convert(varchar(10),A.Interest_DividendDueDate, 103)  as Interest_DividendDueDate,
                            A.Interest_DividendDueAmount,
                            --A.PartialRedumptionDueDate,
                                          convert(varchar(10),A.PartialRedumptionDueDate, 103)  as PartialRedumptionDueDate,
                            A.PartialRedumptionSettledY_N,
                                          pANnO,
                                          A.ISIN,
                                          InstrumentTypeAlt_Key,
                                          Z.InstrumentTypeName,
                                          InvestmentNature
                                          ,Sector
                                          ,x.Industry_AltKey
                                          ,IndustryName
                                          ,SecurityValue
                                          ,(case when FLGDEG = 'Y' then 'Yes' when FLGDEG = 'N' then 'No' end)[DegradationFlag]
                                          ,DEGREASON as [DegradationReason]
                                          ,DPD
                                          ,(case when FLGUPG = 'Y' then 'Yes' when FLGUPG = 'N' then 'No' end)[UpgradationFlag]
                                          --,UpgDate
                                          ,convert(varchar(10),A.UpgDate,103)  as [UpgradationDate]
                                          ,'' AS changeFields
                     FROM InvestmentFinancialDetail A
                             inner join dbo.investmentissuerdetail Y on A.RefIssuerID=Y.IssuerID 				 AND Y.EffectiveFromTimeKey <= @Timekey  AND Y.EffectiveToTimeKey >= @Timekey  -- Previosly it was Left Join & there is no condition of EffectiveFromTimeKey and EffectiveToTimeKey, chnages to handle issue Total Count is mismatch --Changed By Kapil Khot on 24 04 2024
                             inner join dbo.investmentbasicdetail X on A.RefInvID=X.InvID                        AND X.EffectiveFromTimeKey <= @Timekey  AND X.EffectiveToTimeKey >= @Timekey  -- Previosly it was Left Join & there is no condition of EffectiveFromTimeKey and EffectiveToTimeKey, chnages to handle issue Total Count is mismatch --Changed By Kapil Khot on 24 04 2024       
                             inner join Dimcurrency B on A.CurrencyAlt_Key=B.CurrencyAlt_Key					 AND b.EffectiveFromTimeKey <= @Timekey  AND b.EffectiveToTimeKey >= @Timekey  -- Previosly it was Left Join & there is no condition of EffectiveFromTimeKey and EffectiveToTimeKey, chnages to handle issue Total Count is mismatch --Changed By Kapil Khot on 24 04 2024
                             inner join DimAssetClass C on A.AssetClass_AltKey=C.AssetClassAlt_Key				 AND c.EffectiveFromTimeKey <= @Timekey  AND c.EffectiveToTimeKey >= @Timekey  -- Previosly it was Left Join & there is no condition of EffectiveFromTimeKey and EffectiveToTimeKey, chnages to handle issue Total Count is mismatch --Changed By Kapil Khot on 24 04 2024
                             inner join DimInstrumentType z on x.InstrTypeAlt_Key=z.InstrumentTypeAlt_Key		 AND z.EffectiveFromTimeKey <= @Timekey  AND z.EffectiveToTimeKey >= @Timekey  -- Previosly it was Left Join & there is no condition of EffectiveFromTimeKey and EffectiveToTimeKey, chnages to handle issue Total Count is mismatch --Changed By Kapil Khot on 24 04 2024
                             inner JOIN DimSourcedb O ON Y.SourceAlt_key = O.SourceAlt_key						 AND o.EffectiveFromTimeKey <= @Timekey  AND o.EffectiveToTimeKey >= @Timekey  -- Previosly it was Left Join & there is no condition of EffectiveFromTimeKey and EffectiveToTimeKey, chnages to handle issue Total Count is mismatch --Changed By Kapil Khot on 24 04 2024
                             left join dIMiNDUSTRY q on x.Industry_AltKey = Q.IndustryAlt_Key					 AND Q.EffectiveFromTimeKey <= @Timekey  AND Q.EffectiveToTimeKey >= @Timekey  -- Previosly there is no condition of EffectiveFromTimeKey and EffectiveToTimeKey, chnages to handle issue Total Count is mismatch --Changed By Kapil Khot on 24 04 2024
                               WHERE A.EffectiveFromTimeKey <= @TimeKey 
                           AND A.EffectiveToTimeKey >= @TimeKey
                           AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
                                       AND ISNULL(X.AuthorisationStatus, 'A') = 'A'
                     UNION
                     SELECT
                            A.EntityKey,
                            A.InvEntityId,
                                          Y.BranchCode,
                                          Y.SourceAlt_Key,
                                          O.SourceName,
                            A.RefInvID,
                            A.RefIssuerID,
                                          Y.IssuerName,
                            LTRIM(RTRIM(A.HoldingNature)) HoldingNature ,
                            A.CurrencyAlt_Key,
                                          B.CurrencyName,
                            A.CurrencyConvRate,
                            A.BookType,
                            A.BookValue,
                            A.BookValueINR,
                            A.MTMValue,
                            A.MTMValueINR,
                            A.EncumberedMTM,
                            A.AssetClass_AltKey,
                                          C.AssetClassName,
                                            convert(varchar(10),A.NPIDt, 103)  as NPIDt,
                            A.TotalProvison,
							 X.InstrTypeAlt_Key,
                            X.InstrName,
							 X.ExposureType,
							   convert(varchar(10),X.MaturityDt,103)  as MaturityDt,
                            convert(varchar(10),X.ReStructureDate,103) as ReStructureDate,
							Y.UcifId,
							Y.Ref_Txn_Sys_Cust_ID,
							Y.Issuer_Category_Code,
                            Y.GrpEntityOfBank,
                           isnull(A.AuthorisationStatus, 'A') AuthorisationStatus,
                            A.EffectiveFromTimeKey,
                            A.EffectiveToTimeKey,
                            A.CreatedBy,
                            A.DateCreated,
                            A.ModifiedBy,
                            A.DateModified,
                                          IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy,
                                          IsNull(A.DateModified,A.DateCreated)as CrModDate,
                            A.ApprovedBy,
          A.DateApproved,
                            --A.DBTDate,
                                          convert(varchar(10),A.DBTDate, 103)  as DBTDate,
                            --A.LatestBSDate,
                                          convert(varchar(10),A.LatestBSDate, 103)  as LatestBSDate,
                            --A.Interest_DividendDueDate,
                                          convert(varchar(10),A.Interest_DividendDueDate, 103)  as Interest_DividendDueDate,
                            A.Interest_DividendDueAmount,
                            --A.PartialRedumptionDueDate,
                                          convert(varchar(10),A.PartialRedumptionDueDate, 103)  as PartialRedumptionDueDate,
                            A.PartialRedumptionSettledY_N,
                                          pANnO,
                                          ISIN,
                                          InstrumentTypeAlt_Key,
                                          InstrumentTypeName,
                                          InvestmentNature
                                          ,Sector
                                          ,x.Industry_AltKey
                                          ,IndustryName
                                          ,SecurityValue
                                          ,(case when FLGDEG = 'Y' then 'Yes' when FLGDEG = 'N' then 'No' end)FLGDEG
                                          ,DEGREASON as [DegradationReason]
                                          ,DPD
                                          ,(case when FLGUPG = 'Y' then 'Yes' when FLGUPG = 'N' then 'No' end)FLGUPG
                                          --,UpgDate
                                          ,convert(varchar(10),convert(date,A.UpgDate), 103)  as UpgDate
                                          ,a.changeFields
                     FROM InvestmentFinancialDetail_Mod A
                               inner join investmentissuerdetail_Mod Y on A.RefIssuerID=Y.IssuerID				AND Y.EffectiveFromTimeKey <= @Timekey  AND Y.EffectiveToTimeKey >= @Timekey -- Previosly it was Left Join & there is no condition of EffectiveFromTimeKey and EffectiveToTimeKey, chnages to handle issue Total Count is mismatch --Changed By Kapil Khot on 24 04 2024
                               inner join investmentbasicdetail_Mod X on A.RefInvID=X.InvID                     AND X.EffectiveFromTimeKey <= @Timekey  AND X.EffectiveToTimeKey >= @Timekey -- Previosly it was Left Join & there is no condition of EffectiveFromTimeKey and EffectiveToTimeKey, chnages to handle issue Total Count is mismatch --Changed By Kapil Khot on 24 04 2024        
                               inner join Dimcurrency B on A.CurrencyAlt_Key=B.CurrencyAlt_Key					AND b.EffectiveFromTimeKey <= @Timekey  AND b.EffectiveToTimeKey >= @Timekey -- Previosly it was Left Join & there is no condition of EffectiveFromTimeKey and EffectiveToTimeKey, chnages to handle issue Total Count is mismatch --Changed By Kapil Khot on 24 04 2024
                               inner join DimAssetClass C on A.AssetClass_AltKey=C.AssetClassAlt_Key			AND c.EffectiveFromTimeKey <= @Timekey  AND c.EffectiveToTimeKey >= @Timekey-- Previosly it was Left Join & there is no condition of EffectiveFromTimeKey and EffectiveToTimeKey, chnages to handle issue Total Count is mismatch --Changed By Kapil Khot on 24 04 2024
                               inner join DimInstrumentType z on x.InstrTypeAlt_Key=z.InstrumentTypeAlt_Key		AND z.EffectiveFromTimeKey <= @Timekey  AND z.EffectiveToTimeKey >= @Timekey-- Previosly it was Left Join & there is no condition of EffectiveFromTimeKey and EffectiveToTimeKey, chnages to handle issue Total Count is mismatch --Changed By Kapil Khot on 24 04 2024
                               inner JOIN DimSourcedb O ON Y.SourceAlt_key = O.SourceAlt_key					AND o.EffectiveFromTimeKey <= @Timekey  AND o.EffectiveToTimeKey >= @Timekey-- Previosly it was Left Join & there is no condition of EffectiveFromTimeKey and EffectiveToTimeKey, chnages to handle issue Total Count is mismatch --Changed By Kapil Khot on 24 04 2024
                               left join dIMiNDUSTRY q on X.Industry_AltKey = Q.IndustryAlt_Key					AND Q.EffectiveFromTimeKey <= @Timekey  AND Q.EffectiveToTimeKey >= @Timekey-- Previosly there is no condition of EffectiveFromTimeKey and EffectiveToTimeKey, chnages to handle issue Total Count is mismatch --Changed By Kapil Khot on 24 04 2024
                               WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                          AND ISNULL(A.AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')
                           AND A.InvEntityId IN
                     (
                         SELECT MAX(InvEntityId)
                         FROM InvestmentFinancialDetail_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')
                                             AND ISNULL(X.AuthorisationStatus, 'A') = 'A'
                         GROUP BY EntityKey
                     )
                 ) A
                     
                 
                 GROUP BY A.EntityKey,
                            A.InvEntityId,
                            A.BranchCode,
                            A.SourceAlt_Key,
                            A.SourceName,
                            A.RefInvID,
                            A.RefIssuerID,
                                          A.IssuerName,
                            A.HoldingNature,
                            A.CurrencyAlt_Key,
                                          A.CurrencyName,
                            A.CurrencyConvRate,
                            A.BookType,
                            A.BookValue,
                            A.BookValueINR,
                            A.MTMValue,
                            A.MTMValueINR,
                            A.EncumberedMTM,
                            A.AssetClass_AltKey,
                                          A.AssetClassName,
                            A.NPIDt,
                            A.TotalProvison,
							 A.InstrTypeAlt_Key,
                            A.InstrName,
							 A.ExposureType,
							   A.MaturityDt,
                            A.ReStructureDate,
							A.UcifId,
							A.Ref_Txn_Sys_Cust_ID,
							A.Issuer_Category_Code ,
                            A.GrpEntityOfBank,
                            A.AuthorisationStatus,
                            A.EffectiveFromTimeKey,
                            A.EffectiveToTimeKey,
                            A.CreatedBy,
                            A.DateCreated,
                            A.ModifiedBy,
                            A.DateModified,
                                          A.CrModBy,
                                              A.CrModDate,
                            A.ApprovedBy,
                            A.DateApproved,
                            A.DBTDate,
                            A.LatestBSDate,
                            A.Interest_DividendDueDate,
                            A.Interest_DividendDueAmount,
                            A.PartialRedumptionDueDate,
                            A.PartialRedumptionSettledY_N,
                                          pANnO,
                                          ISIN,
                                          InstrumentTypeAlt_Key,
                                          InstrumentTypeName
                                          ,InvestmentNature
                                          ,Sector
                                          ,a.Industry_AltKey
                                          ,IndustryName
                                          ,SecurityValue
                                          ,[DegradationFlag]
                                          ,[DegradationReason]
                                          ,DPD
                                          ,[UpgradationFlag]
                                          ,[UpgradationDate]
                                          ,A.changeFields
                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY EntityKey) AS RowNumber,
                            COUNT(*) OVER() AS TotalCount,
                            'InvestmentFinanacialMaster' TableName,
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp A
                                     WHERE   (  ISNULL(RefInvID, '')                      LIKE '%'+@InvID+'%'
                         AND        ISNULL(rEFIssuerID, '')             LIKE '%'+@IssuerID+'%'
                                      AND       ISNULL(IssuerName, '')              LIKE '%'+@IssuerName+'%'
                                       AND            ISNULL(InstrumentTypeAlt_Key, '')   LIKE '%'+@InstrumentTypeAlt_Key+'%'
                                        AND           ISNULL(ISIN, '')                    LIKE '%'+@ISIN+'%'      
                                          AND         ISNULL(pANnO, '')                         LIKE '%'+@Pan+'%'       
                                          )
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
                 --      AND RowNumber <= (@PageNo * @PageSize);
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