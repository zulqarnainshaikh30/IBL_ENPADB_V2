SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO




-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--USE YES_MISDB  
--exec CollateralDetail_DownloadData @TimeKey=25994,@UserLoginId=N'mischecker',@ExcelUploadId=N'12',@UploadType=N'Colletral Detail Upload'  
--go  
  
  
  
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  
  
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  
  
  
CREATE PROCEDURE [dbo].[BuyOutUpload_DownloadData]  
 @Timekey INT  
 ,@UserLoginId VARCHAR(100)  
 ,@ExcelUploadId INT  
 ,@UploadType VARCHAR(50)  
 --,@Page SMALLINT =1       
 --   ,@perPage INT = 30000     
AS  
  
----DECLARE @Timekey INT=49999  
---- ,@UserLoginId VARCHAR(100)='FNASUPERADMIN'  
---- ,@ExcelUploadId INT=4  
---- ,@UploadType VARCHAR(50)='Interest reversal'  
  
BEGIN  
  SET NOCOUNT ON;  
  
  Select @Timekey=Max(Timekey) from dbo.SysDayMatrix    
    where  Date=cast(getdate() as Date)  
        PRINT @Timekey    
  
  --DECLARE @PageFrom INT, @PageTo INT     
    
  --SET @PageFrom = (@perPage*@Page)-(@perPage) +1    
  --SET @PageTo = @perPage*@Page    
  
IF (@UploadType='Buyout Upload')  
  
BEGIN  
    
  --SELECT * FROM(  
  SELECT 'Details' as TableName, 
  UploadID, 
  SlNo as [Sr. No.],
--,CDateofData
Convert(Varchar(10),ReportDate,103)ReportDate,
CustomerAcID,
SchemeCode,
NPA_ClassSeller,
Convert(Varchar(10),NPA_DateSeller,103)NPA_DateSeller ,
DPD_Seller,
PeakDPD,
Convert(Varchar(10),PeakDPD_Date,103) PeakDPD_Date
   FROM BuyoutUploadDetails_Mod  
  WHERE UploadId=@ExcelUploadId  
  AND EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey    
  
  
    
  
 
  
    
  
   
  
END  
  
  
  
END  
  

GO