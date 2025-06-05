SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


-- =============================================
-- Author:		<Shailesh Naik>
-- Create date: <12/07/14>
-- Description:	<for checking Data exist or not>
-- =============================================
CREATE FUNCTION [dbo].[XBRLDataExtractedChecking]
(
		@ReportId varchar(20),
		@TimeKey INT,
		@ReportingStatus char(2)
)
RETURNS 
@Result TABLE 
(
	Flag Char(2)
	,TableName varchar(100)
)
AS
BEGIN
    DECLARE @FlagValue char(2)='Y'
	IF EXISTS(		Select 1 from XBRLInstanceDocument WHERE TimeKey=@TimeKey AND ReportId=@reportId AND DelSta='UNKNOWN'
						AND (CASE 
								  WHEN @ReportingStatus ='P' AND ReportStatus in('P','F','RF') AND FrozenStatus='Y' THEN 1 
								  --check if final or revised final is frozen and Reporting Status Selected in Provisional
								  WHEN @ReportingStatus IN ('F') AND ReportStatus IN ('F','RF') AND FrozenStatus='Y'  THEN 1
								  WHEN @ReportingStatus IN ('RF') AND ReportStatus IN ('RF') AND FrozenStatus='Y' THEN 1
								 

								  --- if reporting status is selected as Final or revised final
								  
							 END
							 )=1
	               )
					BEGIN
							SET @FlagValue='F'--- already freezed
					END

		IF @ReportId='NRDCSR'
		BEGIN
		     
			 IF EXISTS (Select 1 From XBRL.RBI_118_NRD_CSR_Mod
			                    WHERE TimeKey=@TimeKey AND AuthorisationStatus IN ('NP','MP')
								AND ReportStatus=@ReportingStatus
								AND RecordStatus='C'
					   )
			 BEGIN
			           SET @FlagValue='Y'
			 END
			 ELSE 
			 BEGIN
			           SET @FlagValue='N'
			 END
		END

		IF @ReportId='RLE'
		BEGIN
		          IF EXISTS (Select 1 From XBRL.RBI_24_DSBO_IV_A_Mod
			                    WHERE TimeKey=@TimeKey AND AuthorisationStatus IN ('NP','MP')
								AND ReportStatus=@ReportingStatus
								AND RecordStatus='C'
					   )
			 BEGIN
			           SET @FlagValue='Y'
			 END
			 ELSE 
			 BEGIN
			           SET @FlagValue='N'
			 END
		END

		IF @ReportId='ROP'
		BEGIN
		          IF EXISTS (Select 1 From XBRL.RBI_26_DSBO_VI_Mod
			                    WHERE TimeKey=@TimeKey AND AuthorisationStatus IN ('NP','MP')
								AND ReportStatus=@ReportingStatus
								AND RecordStatus='C'
					   )
			 BEGIN
			           SET @FlagValue='Y'
			 END
			 ELSE 
			 BEGIN
			           SET @FlagValue='N'
			 END
		END


		Insert Into @Result Values(@FlagValue,'Xbrldataextracted')


		
	
	RETURN 
END

GO