SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create proc [dbo].[Buyout_Enquiry]
as

declare @Timekey int
 Set @Timekey=(select CAST(B.timekey as int)from SysDataMatrix A
Inner Join SysDayMatrix B ON A.TimeKey=B.TimeKey
 where A.CurrentStatus='C')

 SELECT  UniqueUploadID
     ,UploadedBy
    ,CONVERT(VARCHAR(10),DateofUpload,103) AS DateofUpload
  	,UploadType
	,ApprovedBy	 
	,DateApproved
	

	
   FROM ExcelUploadHistory
   WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
   and isnull(AuthorisationStatus,'A')='A'
   and UploadType ='Buyout Upload'
GO