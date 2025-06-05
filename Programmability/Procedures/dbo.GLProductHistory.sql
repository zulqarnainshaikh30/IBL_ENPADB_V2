SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROC [dbo].[GLProductHistory]

				@ProductCode varchar(30)
AS
	BEGIN
				
				Select 		A.GLProductAlt_Key,
							B.ProductCode,
							B.ProductName,
							C.SourceName,
							C.SourceAlt_Key,
							AssetGLCode_STD,
							AssetGLCode_NPA,
							InterestSuspenseNormal,
							InterestReceivableNormal,
							InterestIncomeNormal,
							SuspendedInterestNormal,
							InterestSuspensePenal,
							InterestReceivablePenal,
							InterestIncomePenal,
							SuspendedInterestPenal,
							Prov_Dr_GL,
							Prov_Cr_GL,
							A.CreatedBy, 
                            Convert(Varchar(20),A.DateCreated,103) DateCreated,
							A.ApprovedBy, 
							Convert(Varchar(20),A.DateApproved,103) DateApproved,
							A.ModifiedBy, 
							Convert(Varchar(20),A.DateModified,103) DateModified
                     FROM Dimglproduct_AU A
					 Inner Join DimProduct B
					 ON A.ProductCode = B.ProductCode
					 Inner Join DIMSOURCEDB C
					 ON A.SourceAlt_key=C.SourceAlt_Key					 
					 WHERE A.ProductCode=@ProductCode
	END
GO