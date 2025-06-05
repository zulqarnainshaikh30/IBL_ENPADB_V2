SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



create PROC[dbo].[Rpt-056]
     @FromDate   AS VARCHAR(15)
	,@ToDate     AS VARCHAR(15) 
	,@Cost AS FLOAT
as

--Declare 
-- @FromDate   AS VARCHAR(15)='23/10/2023'
--,@ToDate     AS VARCHAR(15)='23/10/2023'
--,@Cost AS FLOAT=1


DECLARE	@From1		DATE=(SELECT Rdate FROM dbo.DateConvert(@FromDate))
DECLARE @To1		DATE=(SELECT Rdate FROM dbo.DateConvert(@ToDate))

DECLARE @ProcessDate DATE=(SELECT DATE FROM Automate_Advances WHERE [DATE]=@From1)
DECLARE @ProcessDate1 DATE=(SELECT DATE FROM Automate_Advances WHERE [DATE]=@To1)


DECLARE @FromTimeKey INT=(SELECT TimeKey FROM Automate_Advances WHERE [DATE]=@From1)
DECLARE @ToTimeKey INT=(SELECT TimeKey FROM Automate_Advances WHERE [DATE]=@To1)


----DECLARE @Flag AS CHAR(5)
----DECLARE @Department AS VARCHAR(10)
----DECLARE @AuthenFlag AS CHAR(5)
----DECLARE @Code AS VARCHAR(10)

----SET @AuthenFlag = (SELECT dbo.AuthenticationFlag())
----SET @Flag = (SELECT dbo.ADflag())
----	IF @Flag='Y' 
----	BEGIN
----			SET @Department = (LEFT(@MisLocation,2))
----			SET @Code = (RIGHT(@MisLocation,3))
----	END

----	ELSE IF @Flag='SQL'
----	BEGIN
----			IF @AuthenFlag = 'Y'
----				BEGIN
----     SET @Department = (SELECT TOP(1)UserLocation FROM DimUserInfo WHERE UserLoginID = @UserName	AND EffectiveToTimeKey=49999)            
----     SET @Code = (SELECT TOP(1)UserLocationCode FROM DimUserInfo WHERE UserLoginID = @UserName		AND EffectiveToTimeKey=49999) 
----				END
				
----			ELSE IF @AuthenFlag = 'N'
----			    BEGIN
----					SET @Department = 'RO'
----					SET @Code       = '07'
----			    END
----	END



----IF(OBJECT_ID('tempdb..#TempBranch') is not null)
----DROP TABLE #TempBranch

----	SELECT       ROW_NUMBER() OVER (ORDER BY (cast(Branchcode as varchar(20) ) )) AS SrNo



----				,cast(DimBranch.BranchCode  as varchar(20)) AS BranchCode
----				,DimBranch.BranchName                    AS BranchName
----				,DimBranch.BranchZone                    AS BranchZone
----				,DimBranch.BranchRegion                  AS BranchRegion
----				,DimBranch.BranchDistrictName            AS BranchDistrictName
----				,DimBranch.BranchStateName               AS BranchStateName
----				,DimBranch.BranchZoneAlt_Key             AS ZoneAlt_Key
----				,DimBranch.BranchRegionAlt_Key           AS RegionAlt_Key
----				,DimBranch.BranchStateAlt_Key            AS StateAlt_Key
----				,DimBranch.BranchDistrictAlt_Key         AS DistrictAlt_Key
			
----	INTO  #TempBranch
----	FROM Dimbranch

----WHERE 
----(Dimbranch.EffectiveFromTimeKey<=@TimeKey AND DimBranch.EffectiveToTimeKey>=@TimeKey)
----AND 
----  	(
----  		(@AdminValue = '0')
  
----	OR   (
----			CASE WHEN  @AdminValue <> '0'
----				 THEN (CASE WHEN @Flag = 'N' OR @Department = 'HO' AND @AdminValue <> '0'
----					        THEN (CASE WHEN @DynamicGrp = 'ZO' THEN cast(BranchZoneAlt_Key as varchar(20))
----	   						           WHEN @DynamicGrp = 'RO' THEN cast(BranchRegionAlt_Key  as varchar(20))
----	   							       WHEN @DynamicGrp = 'BO' THEN cast(DimBranch.BranchCode as varchar(20))
----	   							       WHEN @DynamicGrp = 'ST' THEN cast(BranchStateAlt_Key as varchar(20))
----	   							       WHEN @DynamicGrp = 'DS' THEN cast(BranchDistrictAlt_Key as varchar(20))
----	   						      END) 
----						    END)
----				 END )IN(SELECT * FROM dbo.Split(@AdminValue,','))          
----    OR
	      
----	      ((
----	         CASE WHEN @AdminValue <> '0'
----	              THEN (CASE WHEN @Flag <> 'N' AND @Department <> 'HO' AND @AdminValue <> '0' 
----				             THEN (CASE WHEN @DynamicGrp = 'ZO' THEN DimBranch.BranchZoneAlt_Key 
----	   									WHEN @DynamicGrp = 'RO' THEN DimBranch.BranchRegionAlt_Key 
----	   									WHEN @DynamicGrp = 'BO' THEN DimBranch.BranchCode
----	   									WHEN @DynamicGrp = 'ST' THEN DimBranch.BranchStateAlt_Key
----	   									WHEN @DynamicGrp = 'DS' THEN DimBranch.BranchDistrictAlt_Key
----	   		    				   END) 
----	       	            END)
----	              END)IN(SELECT * FROM dbo.Split(@AdminValue,','))

----	AND ( CASE WHEN @AdminValue <> '0'
----	                THEN (CASE WHEN @Department = 'ZO' THEN DimBranch.BranchZoneAlt_Key 
----					           WHEN @Department = 'RO' THEN DimBranch.BranchRegionAlt_Key
----					           WHEN @Department = 'BO' THEN DimBranch.BranchCode	
----					      END)
----					END ) = @Code) 
     
----	)

----OPTION(RECOMPILE)

----	CREATE UNIQUE CLUSTERED INDEX INX_SrNo ON #TempBranch(SrNo)
	
----    CREATE NONCLUSTERED INDEX INX_BranchCode ON #TempBranch(BranchCode)
----																		INCLUDE	( 
----																				  BranchName
----																				 ,BranchZone
----																				 ,BranchRegion
----																				 ,BranchDistrictName
----																				 ,ZoneAlt_Key
----																				 ,RegionAlt_Key
----																				 ,StateAlt_Key
----																				 ,DistrictAlt_Key
																	 
----																				 )

--------------------------------========================================================================================


select distinct
------TB.BranchName, 
------	  TB.BranchRegion, BranchZone  ,     TB.BranchCode 
------	  ------,TB.BranchName-------ADDED AFTER 15TH OCTOBER 2020
	  
------	  ,CASE WHEN @SubDynamicGrp IN ('ST','SLW') 
------         THEN TB.BranchStateName
------		 WHEN @SubDynamicGrp IN ('SUW')
------		 THEN st.StateName
------		 WHEN @SubDynamicGrp IN ('DS','DLW')
------		 THEN TB.BranchDistrictName
------		 WHEN @SubDynamicGrp IN ('DUW')
------		 THEN DS.DistrictName
------		 when @DynamicGrp in('ST') and @SubDynamicGrp IN ('BLW','BUW')
------		 THEN st.StateName
------		 when @DynamicGrp in('DS') and @SubDynamicGrp IN ('BLW','BUW')
------		 THEN DS.DistrictName
------		 END STATEDISTRICT , 
		                         
------  CASE WHEN  @SubDynamicGrp ='BANK' THEN '1'               
------       WHEN @SubDynamicGrp = 'ZO'   THEN CAST(TB.ZoneAlt_Key  AS Varchar(20))
------       WHEN @SubDynamicGrp = 'RO'   THEN CAST(TB.RegionAlt_Key AS Varchar(20))
------	   WHEN @SubDynamicGrp = 'BO'   THEN CAST(TB.BranchCode  AS Varchar(20))
------	   WHEN @SubDynamicGrp IN ('ST','SLW') THEN CAST(TB.StateAlt_Key  AS Varchar(20)) 
------	   WHEN @SubDynamicGrp IN ('SUW') THEN CAST(ACBD.StateAlt_Key  AS Varchar(20)) 
------	   WHEN @SubDynamicGrp IN ('DS','DLW') THEN CAST(TB.DistrictAlt_Key  AS Varchar(20)) 
------	   WHEN @SubDynamicGrp IN ('DUW') THEN CAST(ACBD.DistrictAlt_Key  AS Varchar(20)) 
------  END AS DynamicGrp,
------  CASE WHEN @SubDynamicGrp ='BANK' THEN '1'
------       WHEN @SubDynamicGrp = 'ZO'   THEN CAST(TB.ZoneAlt_Key  AS Varchar(20))
------       WHEN @SubDynamicGrp = 'RO'   THEN CAST(TB.RegionAlt_Key AS Varchar(20))
------	   WHEN @SubDynamicGrp = 'BO'   THEN CAST(TB.BranchCode  AS Varchar(20))
------	   WHEN @SubDynamicGrp IN ('ST','SLW') THEN CAST(TB.StateAlt_Key  AS Varchar(20)) 
------	   WHEN @SubDynamicGrp IN ('SUW') THEN CAST(ACBD.StateAlt_Key  AS Varchar(20)) 
------	   WHEN @SubDynamicGrp IN ('DS','DLW') THEN CAST(TB.DistrictAlt_Key  AS Varchar(20)) 
------	   WHEN @SubDynamicGrp IN ('DUW') THEN CAST(ACBD.DistrictAlt_Key  AS Varchar(20)) 
------  END AS SubDynamicGrp

DB.Branchcode
,BranchName
--,ROW_NUMBER()over(order by ACBD.CustomerACID) as [S.NO]
,AdhocACL_ChangeDetails.CustomerId
,CustomerBasicDetail.CustomerName
,ACBD.CustomerACID as ACID
,isnull(prevAssetClass.AssetClassShortNameEnum,'NA') as OldClassification

,isnull(currentAssetClass.AssetClassShortNameEnum,'') as NewClassification 
----,Case 
----when FinalAssetClassAlt_Key=1 and SMA_Class='STD' then 'A0'
----when FinalAssetClassAlt_Key=1 and SMA_Class='SMA_0' then 'S0'
----when FinalAssetClassAlt_Key=1 and SMA_Class='SMA_1' then 'S1'
----when FinalAssetClassAlt_Key=1 and SMA_Class='SMA_2' then 'S2'
----when FinalAssetClassAlt_Key=1 and SMA_Class='SMA_3' then 'S3'
----when FinalAssetClassAlt_Key=2 and DATEDIFF(day,FinalNpaDt,@To1) <=91 then 'B0'
----when FinalAssetClassAlt_Key=2 and DATEDIFF(day,FinalNpaDt,@To1) between 91 and 183 then 'B1'
----when FinalAssetClassAlt_Key=2 and DATEDIFF(day,FinalNpaDt,@To1) between 183 and 274 then 'B2'
----when FinalAssetClassAlt_Key=2 and DATEDIFF(day,FinalNpaDt,@To1) >=273 then 'B3'
----when finalassetclassalt_key=3 then 'C1'
----when finalassetclassalt_key=4 then 'C2'
----when FinalAssetClassAlt_Key=5 then 'C3'
----when FinalAssetClassAlt_Key=6 then 'D0'
----end NewClassification

,CONVERT(VARCHAR(10),MOC_Dt,103) as MOCDate

----,DimParameter.ParameterName as MOCReason

--, AcCalHist.MOCReason as MOCReason
,DP.ParameterName		 as MOCReason

----,AdhocACL_ChangeDetails.ChangeType 

,DP1.ParameterName		AS ChangeType
 
,AcCalHist.Balance as OutstandingBalance


,CONVERT(VARCHAR(10),AdhocACL_ChangeDetails.DateCreated,103)				AS	DateCreated
,AdhocACL_ChangeDetails.CreatedBy
,AdhocACL_ChangeDetails.FirstLevelApprovedBy
,CONVERT(VARCHAR(10),AdhocACL_ChangeDetails.FirstLevelDateApproved,103)		AS	FirstLevelDateApproved
,ISNULL(CONVERT(VARCHAR(10),AdhocACL_ChangeDetails.PrevNPA_Date,103),'NA')				AS	PrevNPA_Date
,ISNULL(CONVERT(VARCHAR(10),AdhocACL_ChangeDetails.NPA_Date,103),'NA')					AS	NPA_Date
		
,CONVERT(VARCHAR(10),AdhocACL_ChangeDetails.DateApproved,103)								AS 'SECOND LEVEL DATE'
,AdhocACL_ChangeDetails.ApprovedBy														AS 'SECOND LEVEL BY'
,SourceName
,AcCalHist.UCIF_ID

from AdvAcBasicDetail ACBD
--inner join AdvAcBasicDetail ACBD				on ACBD.BranchCode=tb.BranchCode
--												and ACBD.EffectiveFromTimeKey <= @ToTimeKey AND ACBD.EffectiveToTimeKey >= @FromTimeKey
--												AND TB.EffectiveFromTimeKey <= @ToTimeKey AND TB.EffectiveToTimeKey >= @FromTimeKey

inner join  AdhocACL_ChangeDetails				on AdhocACL_ChangeDetails.CustomerEntityId = ACBD.CustomerEntityId
												and ACBD.EffectiveFromTimeKey <= @ToTimeKey AND ACBD.EffectiveToTimeKey >= @FromTimeKey
												and AdhocACL_ChangeDetails.EffectiveFromTimeKey <= @ToTimeKey 
												AND AdhocACL_ChangeDetails.EffectiveToTimeKey >= @FromTimeKey

--inner join  AdhocACL_ChangeDetails_Mod Adhocmod				on Adhocmod.CustomerEntityId = ACBD.CustomerEntityId
--												and Adhocmod.EffectiveFromTimeKey <= @ToTimeKey 
--												AND Adhocmod.EffectiveToTimeKey >= @FromTimeKey

inner join  pro.AccountCal_Hist AcCalHist		on AcCalHist.AccountEntityID = ACBD.AccountEntityId
												and AcCalHist.EffectiveFromTimeKey <= @ToTimeKey 
												AND AcCalHist.EffectiveToTimeKey >= @FromTimeKey


inner join CustomerBasicDetail					on CustomerBasicDetail.CustomerEntityId=AdhocACL_ChangeDetails.CustomerEntityId
												and CustomerBasicDetail.EffectiveFromTimeKey <= @ToTimeKey 
												AND CustomerBasicDetail.EffectiveToTimeKey >= @FromTimeKey

left join DimAssetClass prevAssetClass			on prevAssetClass.AssetClassAlt_Key=AdhocACL_ChangeDetails.PrevAssetClassAlt_Key
												and prevAssetClass.EffectiveFromTimeKey <= @ToTimeKey 
												AND prevAssetClass.EffectiveToTimeKey >= @FromTimeKey

left join DimAssetClass currentAssetClass		on currentAssetClass.AssetClassAlt_Key=AdhocACL_ChangeDetails.AssetClassAlt_Key
												and currentAssetClass.EffectiveFromTimeKey <= @ToTimeKey 
												AND currentAssetClass.EffectiveToTimeKey >= @FromTimeKey

LEFT JOIN DimState ST							ON (ST.EffectiveFromTimeKey <= @ToTimeKey AND ST.EffectiveToTimeKey >= @FromTimeKey)
												AND ST.StateAlt_Key=ACBD.StateAlt_Key

LEFT JOIN DimGeography DS						ON (DS.EffectiveFromTimeKey <= @ToTimeKey AND DS.EffectiveToTimeKey >= @FromTimeKey)
												AND DS.DistrictAlt_Key=ACBD.DistrictAlt_Key

--inner join DimParameter							on DimParameter.ParameterAlt_Key=convert(varchar(5),AdhocACL_ChangeDetails.Reason)
--												and DimParameter.ParameterAlt_Key=convert(varchar(5),Adhocmod.Reason)
--												and DimParameter.EffectiveFromTimeKey <= @ToTimeKey
--												AND DimParameter.EffectiveToTimeKey >= @FromTimeKey

LEFT JOIN DIMSOURCEDB DSE						ON (DSE.EffectiveFromTimeKey <= @ToTimeKey AND DSE.EffectiveToTimeKey >= @FromTimeKey)
												AND DSE.SourceAlt_Key=AcCalHist.SourceAlt_Key

left join DimParameter	DP						on DP.ParameterAlt_Key=AdhocACL_ChangeDetails.Reason
												and DP.EffectiveFromTimeKey <= @ToTimeKey 
												AND DP.EffectiveToTimeKey >= @FromTimeKey
												AND DimParameterName	= 'DimMOCReason'

left join DimParameter	DP1						on DP1.ParameterAlt_Key=AdhocACL_ChangeDetails.ChangeType
												and DP1.EffectiveFromTimeKey <= @ToTimeKey 
												AND DP1.EffectiveToTimeKey >= @FromTimeKey
												AND DP1.DimParameterName='MOCType'

left join DimBranch	DB							ON  ACBD.BranchCode=DB.BranchCode
												AND DB.EffectiveFromTimeKey <= @ToTimeKey AND DB.EffectiveToTimeKey >= @FromTimeKey
order by ACBD.CustomerACID


GO