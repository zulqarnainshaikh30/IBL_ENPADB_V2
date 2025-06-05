SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROC [dbo].[SysBRZDataSelect_Moc_mvc]   
	@Condition  NVARCHAR(1000)= '',          
	--@Code   INT=0,
	@Code   VARCHAR(10)='',
	@Top INT=0
	                      
AS          
BEGIN    
SET NOCOUNT ON 
IF @Top=0 
BEGIN
	SET @Top=99999
END
--DECLARE @AllowLogin CHAR(1)  
--SET @AllowLogin='Y'   
DECLARE @AllowMakerChecker CHAR(1)  
SET @AllowMakerChecker ='Y'

-- For MOC
DECLARE
@MOC_TimeKey SMALLINT,
@HO_MOC_Frozen CHAR(1)='N'
SELECT @MOC_TimeKey=MAX(TimeKey) FROM sysdatamatrix WHERE IsClosingDay ='Y' 
SELECT @HO_MOC_Frozen=MOC_Frozen From sysdatamatrix WHERE TimeKey=@MOC_TimeKey
--Y
--3377
--N
--1
PRINT @AllowMakerChecker  
PRINT @MOC_TimeKey
PRINT @HO_MOC_Frozen
PRINT @Top
PRINT @Code



IF @Condition = 'BranchCode'          
 BEGIN          
 print'Banu'
   SELECT  TOP (@Top)             
		ISNULL(BranchZoneAlt_Key,0) AS ZoneAltKey,           
        BranchZone As ZoneName,           
        ISNULL(BranchRegionAlt_Key,0) AS RegionAltKey,           
        BranchRegion AS RegionName,           
        dbo.DimBranch.BranchCode ,           
		dbo.DimBranch.BranchName + ' ['+ dbo.DimBranch.BranchCode +']' as BranchName,
        dbo.Dimbranch.BranchBusinessCategory, 
		dbo.DimBranch.BranchCode2 ,
		dbo.DimBranch.AllowPreDisb,       
        ISNULL(BranchDistrictAlt_Key,0) AS DistrictAlt_Key,        
        'N' AS MOCLock,   
        '00'AS MnthFreez, 
        'N' AS Mechanize,           
        ISNULL(BranchDistrictName, 'N')AS DistrictName,  
        dbo.DimBranch.BranchCode + '_' + BranchRegion + '_' + BranchZone AS ShowValue,           
        ISNULL(BranchStateAlt_Key,0) AS StateAltKey,           
        BranchStateName AS StateName,   
        dbo.DimBranch.Branch_Key AS BranchKey,    
        ISNULL(BranchAreaCategoryAlt_Key,0)  AS AreaAltKey,
        dbo.dimbranch.BranchType AS BranchType, 
        DimBranch.EffectiveFromTimeKey,
        DimBranch.EffectiveToTimeKey
		,NULL PrevLevelMoc	-- ,ISNULL(FactBranch.UnderAudit,'N') AS		PrevLevelMoc
		,NULL CurrLevelMoc	-- ,ISNULL(FactBranch.BO_MOC_Frozen,'N') AS	CurrLevelMoc

   FROM dbo.DimBranch
    --  	LEFT OUTER JOIN FactBranch 
				--ON FactBranch.BranchCode =DimBranch.BranchCode 
				--AND FactBranch.TimeKey=@MOC_TimeKey
	  
   WHERE dbo.DimBranch.BranchCode=@Code  
   ----AND  ISNULL(DimBranch.AllowLogin,'N')=@AllowLogin         
   --AND ISNULL(DimBranch.AllowMakerChecker,'N')=@AllowMakerChecker  
   ORDER BY           
     dbo.DimBranch.BranchName            
 END          
ELSE IF @Condition = 'RegionCode'          
 BEGIN    
 PRINT 'Malsa'      
   SELECT TOP (@Top)              
		ISNULL(BranchZoneAlt_Key,0) AS ZoneAltKey,           
        BranchZone As ZoneName,           
        ISNULL(BranchRegionAlt_Key,0) AS RegionAltKey,           
        BranchRegion AS RegionName,           
        dbo.DimBranch.BranchCode ,           
        dbo.DimBranch.BranchName + ' ['+ dbo.DimBranch.BranchCode +']' as BranchName,
        dbo.Dimbranch.BranchBusinessCategory, 
		dbo.DimBranch.BranchCode2 ,
		dbo.DimBranch.AllowPreDisb,       
        ISNULL(BranchDistrictAlt_Key,0) AS DistrictAlt_Key,   
        'N' AS MOCLock,
        '00'AS MnthFreez,
        'N' AS Mechanize,           
        ISNULL(BranchDistrictName, 'N')AS DistrictName, 
        dbo.DimBranch.BranchCode + '_' + BranchRegion + '_' + BranchZone AS ShowValue,           
        ISNULL(BranchStateAlt_Key,0) AS StateAltKey,           
        BranchStateName As StateName, 
        dbo.DimBranch.Branch_Key AS BranchKey, 
        ISNULL(BranchAreaCategoryAlt_Key,0)  AS AreaAltKey,
        dbo.dimbranch.BranchType AS BranchType, 
        DimBranch.EffectiveFromTimeKey,
        DimBranch.EffectiveToTimeKey
	,NULL AS PrevLevelMoc --	,ISNULL(FactBranch.BO_MOC_Frozen,'N') AS PrevLevelMoc
	,NULL AS CurrLevelMoc --	,ISNULL(FactBranch.RO_MOC_Frozen,'N') AS CurrLevelMoc 

   FROM dbo.DimBranch
   --LEFT OUTER JOIN FactBranch 
			--	ON FactBranch.BranchCode =DimBranch.BranchCode 
			--	AND FactBranch.TimeKey=@MOC_TimeKey 

  WHERE BranchRegionAlt_Key=@Code  
  -- AND ISNULL(DimBranch.AllowMakerChecker,'N')=@AllowMakerChecker  
   ORDER BY           
     dbo.DimBranch.BranchName              
 END          
ELSE IF @Condition = 'ZoneCode'          
 BEGIN          
   SELECT TOP (@Top)             
        ISNULL(BranchZoneAlt_Key,0) AS ZoneAltKey,           
        BranchZone As ZoneName,           
        ISNULL(BranchRegionAlt_Key,0) AS RegionAltKey,           
        BranchRegion AS RegionName,           
        dbo.DimBranch.BranchCode ,           
        dbo.DimBranch.BranchName + ' ['+ dbo.DimBranch.BranchCode +']' as BranchName,
        dbo.Dimbranch.BranchBusinessCategory, 
		dbo.DimBranch.BranchCode2 ,
		dbo.DimBranch.AllowPreDisb,       
        ISNULL(BranchDistrictAlt_Key,0) AS DistrictAlt_Key,
        'N' AS MOCLock,             
        '00'AS MnthFreez,       
        'N' AS Mechanize,           
        ISNULL(BranchDistrictName, 'N')AS DistrictName,            
        dbo.DimBranch.BranchCode + '_' + BranchRegion + '_' + BranchZone AS ShowValue,           
        ISNULL(BranchStateAlt_Key,0) AS StateAltKey,           
        BranchStateName As StateName, 
        dbo.DimBranch.Branch_Key AS BranchKey, 
        ISNULL(BranchAreaCategoryAlt_Key,0)  AS AreaAltKey,
        dbo.dimbranch.BranchType AS BranchType,
        DimBranch.EffectiveFromTimeKey,
        DimBranch.EffectiveToTimeKey
	,NULL AS PrevLevelMoc --	,ISNULL(FactBranch.RO_MOC_Frozen,'N') AS PrevLevelMoc
	,NULL AS CurrLevelMoc --	,ISNULL(FactBranch.ZO_MOC_Frozen,'N') AS CurrLevelMoc

    FROM dbo.DimBranch	
	--LEFT OUTER JOIN FactBranch 
	--			ON FactBranch.BranchCode =DimBranch.BranchCode 
	--			AND FactBranch.TimeKey=@MOC_TimeKey 
	
 WHERE BranchZoneAlt_Key=@Code  
	---- AND  ISNULL(DimBranch.AllowLogin,'N')=@AllowLogin       
	--	AND ISNULL(DimBranch.AllowMakerChecker,'N')=@AllowMakerChecker  
   ORDER BY           
     dbo.DimBranch.BranchName     
 END          
Else IF @Condition = '' OR   @Condition = 'BANK'  OR   @Condition = '0'       
 BEGIN   
	IF @Top=99999
		BEGIN
			   SELECT        
					ISNULL(BranchZoneAlt_Key,0) AS ZoneAltKey,           
					BranchZone As ZoneName,           
					ISNULL(BranchRegionAlt_Key,0) AS RegionAltKey,           
					BranchRegion AS RegionName,           
					dbo.DimBranch.BranchCode ,           
					dbo.DimBranch.BranchName + ' ['+ dbo.DimBranch.BranchCode +']' as BranchName,
					dbo.Dimbranch.BranchBusinessCategory, 
					dbo.DimBranch.BranchCode2 ,
					dbo.DimBranch.AllowPreDisb,       
					ISNULL(BranchDistrictAlt_Key,0) AS DistrictAlt_Key,
					'N' AS MOCLock,               
					'00'AS MnthFreez,              
					'N' AS Mechanize,      
					ISNULL(BranchDistrictName, 'N')AS DistrictName,            
					dbo.DimBranch.BranchCode + '_' + BranchRegion + '_' + BranchZone AS ShowValue,           
					ISNULL(BranchStateAlt_Key,0) AS StateAltKey,           
					BranchStateName As StateName, 
					dbo.DimBranch.Branch_Key AS BranchKey, 
					ISNULL(BranchAreaCategoryAlt_Key,0)  AS AreaAltKey,
					dbo.dimbranch.BranchType AS BranchType,
					DimBranch.EffectiveFromTimeKey,
					DimBranch.EffectiveToTimeKey
					,NULL AS PrevLevelMoc --,ISNULL(FactBranch.ZO_MOC_Frozen,'N') AS PrevLevelMoc
					,NULL AS CurrLevelMoc --,ISNULL(@HO_MOC_Frozen,'N') AS CurrLevelMoc
		
			   FROM DimBranch
				  --LEFT OUTER JOIN FactBranch 
						--	ON FactBranch.BranchCode =DimBranch.BranchCode 
						--	AND FactBranch.TimeKey=@MOC_TimeKey 

					--WHERE --ISNULL(DimBranch.AllowLogin,'N')=@AllowLogin  
					--ISNULL(DimBranch.AllowMakerChecker,'N')=@AllowMakerChecker  
			   ORDER BY           
				 DimBranch.BranchName            
		END
	ELSE
		BEGIN
		PRINT'MArtya'
				
				SELECT TOP (@Top)             
					ISNULL(BranchZoneAlt_Key,0) AS ZoneAltKey,           
					BranchZone As ZoneName,           
					ISNULL(BranchRegionAlt_Key,0) AS RegionAltKey,           
					BranchRegion AS RegionName,           
					dbo.DimBranch.BranchCode ,           
					dbo.DimBranch.BranchName + '['+ dbo.DimBranch.BranchCode +']' as BranchName,
					dbo.Dimbranch.BranchBusinessCategory, 
					dbo.DimBranch.BranchCode2 ,
					dbo.DimBranch.AllowPreDisb,       
					ISNULL(BranchDistrictAlt_Key,0) AS DistrictAlt_Key,
					'N' AS MOCLock,               
					'00'AS MnthFreez,              
					'N' AS Mechanize,      
					ISNULL(BranchDistrictName, 'N')AS DistrictName,            
					dbo.DimBranch.BranchCode + '_' + BranchRegion + '_' + BranchZone AS ShowValue,           
					ISNULL(BranchStateAlt_Key,0) AS StateAltKey,           
					BranchStateName As StateName, 
					dbo.DimBranch.Branch_Key AS BranchKey, 
					ISNULL(BranchAreaCategoryAlt_Key,0)  AS AreaAltKey,
					dbo.dimbranch.BranchType AS BranchType,
					DimBranch.EffectiveFromTimeKey,
					DimBranch.EffectiveToTimeKey
					,NULL AS PrevLevelMoc --,ISNULL(FactBranch.ZO_MOC_Frozen,'N') AS PrevLevelMoc
					,NULL AS CurrLevelMoc --,ISNULL(@HO_MOC_Frozen,'N') AS CurrLevelMoc
		
			   FROM DimBranch
				  --LEFT OUTER JOIN FactBranch 
						--	ON FactBranch.BranchCode =DimBranch.BranchCode 
						--	AND FactBranch.TimeKey=@MOC_TimeKey 

					--WHERE --ISNULL(DimBranch.AllowLogin,'N')=@AllowLogin  
					--ISNULL(DimBranch.AllowMakerChecker,'N')=@AllowMakerChecker  
			   ORDER BY           
				 DimBranch.BranchName         
		END
 END     
 
 Else IF @Condition = '' OR   @Condition = 'HICode'  OR   @Condition = '0'       
 BEGIN          
   SELECT TOP (@Top)              
        ISNULL(BranchZoneAlt_Key,0) AS ZoneAltKey,           
        BranchZone As ZoneName,           
        ISNULL(BranchRegionAlt_Key,0) AS RegionAltKey,           
        BranchRegion AS RegionName,           
        dbo.DimBranch.BranchCode ,           
        dbo.DimBranch.BranchName + ' ['+ dbo.DimBranch.BranchCode +']' as BranchName,
        dbo.Dimbranch.BranchBusinessCategory, 
		dbo.DimBranch.BranchCode2 ,
		dbo.DimBranch.AllowPreDisb,       
        ISNULL(BranchDistrictAlt_Key,0) AS DistrictAlt_Key, 
        'N' AS MOCLock,                  
        '00'AS MnthFreez,        
        'N' AS Mechanize,      
        ISNULL(BranchDistrictName, 'N')AS DistrictName,            
        dbo.DimBranch.BranchCode + '_' + BranchRegion + '_' + BranchZone AS ShowValue,           
        ISNULL(BranchStateAlt_Key,0) AS StateAltKey,           
        BranchStateName As StateName, 
        dbo.DimBranch.Branch_Key AS BranchKey, 
        ISNULL(BranchAreaCategoryAlt_Key,0)  AS AreaAltKey,
        dbo.dimbranch.BranchType AS BranchType,
        DimBranch.EffectiveFromTimeKey,
        DimBranch.EffectiveToTimeKey
   FROM DimBranch		
	--WHERE 
 --      ISNULL(DimBranch.AllowMakerChecker,'N')=@AllowMakerChecker  
    ORDER BY           
    DimBranch.BranchName            
   
    SELECT InspCentreAlt_Key,BranchName AS RIName FROM DimBranch WHERE BranchType='RI' order by BranchName 
 END     
 ELSE IF @Condition = 'RICode'          
 BEGIN          
   SELECT TOP (@Top)             
        ISNULL(BranchZoneAlt_Key,0) AS ZoneAltKey,           
        BranchZone As ZoneName,           
        ISNULL(BranchRegionAlt_Key,0) AS RegionAltKey,           
        BranchRegion AS RegionName,           
        dbo.DimBranch.BranchCode ,           
        dbo.DimBranch.BranchName + ' ['+ dbo.DimBranch.BranchCode +']' as BranchName,
        dbo.Dimbranch.BranchBusinessCategory, 
		dbo.DimBranch.BranchCode2 ,
		dbo.DimBranch.AllowPreDisb,       
        ISNULL(BranchDistrictAlt_Key,0) AS DistrictAlt_Key,           
        'N' AS MOCLock,          
        '00'AS MnthFreez,           
        'N' AS Mechanize,           
        ISNULL(BranchDistrictName, 'N')AS DistrictName,            
        dbo.DimBranch.BranchCode + '_' + BranchRegion + '_' + BranchZone AS ShowValue,           
        ISNULL(BranchStateAlt_Key,0) AS StateAltKey,           
        BranchStateName As StateName, 
        dbo.DimBranch.Branch_Key AS BranchKey, 
        ISNULL(BranchAreaCategoryAlt_Key,0)  AS AreaAltKey,
        dbo.dimbranch.BranchType AS BranchType,
        DimBranch.EffectiveFromTimeKey,
        DimBranch.EffectiveToTimeKey

   FROM dbo.DimBranch
	-- WHERE dbo.DimBranch.InspCentreAlt_Key=@Code  
	----AND  ISNULL(dbo.DimBranch.AllowLogin,'N')=@AllowLogin          
	--AND ISNULL(DimBranch.AllowMakerChecker,'N')=@AllowMakerChecker  
   ORDER BY           
     dbo.DimBranch.BranchName    
  
  SELECT InspCentreAlt_Key,BranchName AS RIName FROM DimBranch where BranchCode=@Code 
             
 END          
 
 IF @Top<>1
 BEGIN
		Declare @DataEffectiveToDate Date
		SET @DataEffectiveToDate=(SELECT MonthTable.DataEffectiveToDate FROM 
											(
													SELECT MAX(DataEffectiveToDate)as DataEffectiveToDate,[Month]
													,Year
													FROM SysDataMatrix
													WHERE CurrentStatus='C' GROUP BY [Month],Year
														--where CurrentStatus in ('C','U') group by [Month],Year
											) AS MonthTable)
	  --- DimYear
		SELECT
			DISTINCT YEAR AS Code,
			YEAR AS Description
		FROM SysDataMatrix
		WHERE CurrentStatus  IN('C','U')
		ORDER BY Code Desc
	
  
	  IF @Condition = 'RICode'  OR @Condition = 'HICode'   
	   BEGIN
			SELECT DISTINCT	CASE WHEN MONTH(MonthLastDate)<=9 THEN
				'0'+CAST(Month(MonthLastDate) AS VARCHAR)
			ELSE
				CAST(Month(MonthLastDate) AS VARCHAR)
			END
			+CAST(Year(MonthLastDate) AS VARCHAR)  AS Code,
			Year,Month AS Description,MonthLastDate, MonthFirstDate,
			Convert(varchar(12), MonthLastDate, 103) AS 'MonthCaption', 
			MAX(TimeKey) AS TimeKey,
			MIN(DataEffectiveFromTimeKey) AS EffectiveFromTimeKey,currentstatus
			FROM SysDataMatrix
			WHERE DataEffectiveToDate =@DataEffectiveToDate
			GROUP BY Year,MonthLastDate, MonthFirstDate,Month,CurrentStatus
			ORDER BY MonthLastDate Desc
  
	   END
	 ELSE      
	   BEGIN 
			SELECT DISTINCT	CASE WHEN MONTH(MonthLastDate)<=9 THEN
				'0'+CAST(Month(MonthLastDate) AS VARCHAR)
			ELSE
				CAST(month(MonthLastDate) AS VARCHAR)
			END
			+CAST(Year(MonthLastDate) AS VARCHAR)  AS Code,
			 Year,Month AS Description, MonthLastDate, MonthFirstDate,
			 Convert(VARCHAR(12), MonthLastDate, 103) AS 'MonthCaption', 
			 MAX(Timekey) AS Timekey, MIN(DataEffectiveFromTimeKey) AS EffectiveFromTimeKey,currentstatus
			 FROM SysDataMatrix
			-- WHERE CurrentStatus = 'C' 
			 where (currentstatus = 'U' or currentstatus = 'C')
			 --AND DataEffectiveToDate =@DataEffectiveToDate
			 AND DataEffectiveToDate IN (
										select MonthTable.DataEffectiveToDate from 
												(
														SELECT max(DataEffectiveToDate)as DataEffectiveToDate,[Month]
														,Year
														FROM SysDataMatrix
														where CurrentStatus in ('C','U') group by [Month],Year
												) as MonthTable
									)
			-- GROUP BY Year,MonthLastDate, monthfirstdate,Month,currentstatus
			 GROUP BY YEAR,currentstatus,MonthLastDate,monthfirstdate,Month,currentstatus
			 ORDER BY MonthLastDate Desc
  
	  End

	 --- DimDate
	 	SELECT		
		 CASE WHEN MONTH(DataEffectiveToDate)<=9 THEN
						'0'+CAST(month(DataEffectiveToDate) AS VARCHAR)
					ELSE
						CAST(month(DataEffectiveToDate) AS VARCHAR)
					END+cast(Year(DataEffectiveToDate) AS VARCHAR)  AS MonthYear,
		  DataEffectiveFromTimeKey AS Code,
		  CONVERT(VARCHAR(10),GETDATE(),103) AS Description,
		  --CONVERT(VARCHAR(10),DataEffectiveToDate,103) AS Description,
		  DataEffectiveToDate,
		  CurrentStatus,
		  Month AS [Month],
		  TimeKey,
		  Year 
		  ,ISNULL(Month_Key,0) As MonthEndTimeKey
     FROM SysDataMatrix
	 WHERE DataEffectiveFromTimeKey IS NOT NULL -- DATENAME LIKE '%Friday%'
     AND (currentstatus = 'U' or currentstatus = 'C')--AND 
	 ORDER BY DataEffectiveToDate Desc
        
	 	-- SELECT TimeKey,    
			--	[Month],
			--	[Year]
		 --FROM SysDataMatrix 

	Select ParameterName, ParameterValue from SysSolutionParameter Where ParameterName IN('TierValue','RegionCap','AllowHigherLevelAuth')
	
 END
   
END   





GO