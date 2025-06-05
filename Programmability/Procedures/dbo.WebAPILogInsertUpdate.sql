SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--select * from [WebAPILog]
CREATE PROCEDURE [dbo].[WebAPILogInsertUpdate]  
	
	
	@Status varchar(50)=NULL,
	@Port varchar(20)=NULL,
	@Url varchar(MAX)=NULL,
	@Response varchar(max)=NULL,
	@ServerName varchar(50)=NULL,
	@API varchar(50)=NULL,
	@ResponseType varchar(50)=NULL ,
    @IP Varchar(50)=NULL,
	@Device varchar(50)=NULL,
	@Param varchar(max)=NULL,
	@Token varchar(MAX)=NULL,
	@loginID varchar(MAX)=NULL
AS
BEGIN
   BEGIN TRANSACTION	
	BEGIN TRY
	    INSERT INTO [dbo].[WebAPILog]
           (
           [ResponseType]
           ,[IP]
           ,[Device]
           ,[API]
           ,[Response]
           ,[Status]
           ,[Port]
		   ,[Url]
		   ,[ServerName]
		   ,[Param]
		   ,[Token]
		   )
     VALUES
           (
			@ResponseType,
			@IP,
			@Device,
			@API,
			@Response, 
			@Status, 
			@Port,
			@Url,
			@ServerName,
			@Param,
			@Token

			)

		Update DimUserInfo set LastRequestTime =GETDATE() where UserLoginID=@loginID		--set last request time for particular user

	  COMMIT TRANSACTION
	END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	select ERROR_MESSAGE()
END CATCH
END
GO