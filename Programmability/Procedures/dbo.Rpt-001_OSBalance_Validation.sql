SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


create  PROC [dbo].[Rpt-001_OSBalance_Validation]
@TimeKey INT
,@Cost INT
AS

--DECLARE @Timekey INT =25841 ,@Cost INT=1
---select * from SysDayMatrix where date='2020-08-31'
--set @Cost=1
-------------------------------------------TEMP BRANCH------------------------------------
IF(OBJECT_ID('tempdb..#TempBranch') IS NOT NULL)
DROP TABLE #TempBranch

	SELECT       ROW_NUMBER() OVER (ORDER BY Branchcode) AS SrNo
				,DimBranch.BranchCode                    AS BranchCode
				,DimBranch.BranchName                    AS BranchName
				,DimBranch.BranchZone                    AS BranchZone
				,DimBranch.BranchRegion                  AS BranchRegion
				,DimBranch.BranchDistrictName            AS BranchDistrictName
				,DimBranch.BranchStateName               AS BranchStateName
				,DimBranch.BranchZoneAlt_Key             AS ZoneAlt_Key
				,DimBranch.BranchRegionAlt_Key           AS RegionAlt_Key
				,DimBranch.BranchStateAlt_Key            AS StateAlt_Key 
				,DimBranch.BranchDistrictAlt_Key         AS DistrictAlt_Key
				
	INTO  #TempBranch
	FROM Dimbranch

WHERE 
(Dimbranch.EffectiveFromTimeKey<=@TimeKey AND DimBranch.EffectiveToTimeKey>=@TimeKey)



select DP.ProductCode  ProductCode  
      ,CUSTOMERACID   AccountNo
	  ,case when ACBD.AssetClass='STD'  
	        then DP.AssetGLCode_STD 
			else DP.SuspendedAssetGLCode_NPA end  as 'Principal GL Code'  
			  
	  --,ACBAL.PrincipalBalance as 'Principal Amount'
	  ,case when ACBD.AssetClass='STD' 
	        then ACBAL.PrincipalBalance else 0 end as 'Principal Amount'

--,NULL as 'Principal GL-wise Total'
,case when ACBD.AssetClass='STD'
      then   DP.InterestReceivableGLCode_STD 
	  else   DP.SuspendedInterestReceivableGLCode_NPA end as 'Interest GL Number'

,DP.InterestIncome_STD as 'Interest Amount'

--,NULL as 'Interest GL-wise Total'
,NULL as 'Gross Balance'

from curdat.advacbasicdetail  ACBD 
inner join dbo.AdvAcBalanceDetail  ACBAL ON ACBD.AccountEntityId=ACBAL.AccountEntityId
inner join dbo.DimProduct p on p.ProductAlt_Key=ACBD.ProductAlt_Key
Inner join  dimglproduct_au   DP  ON DP.ProductCode=p.ProductCode


GO