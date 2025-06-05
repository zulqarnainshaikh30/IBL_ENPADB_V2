SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--select * from SAMLRequestID
CREATE PROCEDURE [dbo].[SAMLRequestIDUpdate]  
	
	@SAMLFlag varchar(MAX)=NULL,
	@InResponseTo varchar(MAX) = NULL,
	@SAMLStatusCode int = NULL
AS
BEGIN
   BEGIN TRANSACTION	
	BEGIN TRY

	if @SAMLFlag = 'INSERT'
	--PRINT @SAMLFlag
	BEGIN
	    INSERT INTO [dbo].[SAMLRequestID]
           (
           [InResponseTo],
		   [SAMLStatusCode]        
		   )
     VALUES
           (
			@InResponseTo,
			@SAMLStatusCode			
			)
	END
	ELSE if @SAMLFlag = 'UPDATE'
	--PRINT @SAMLFlag
	BEGIN
	   UPDATE SAMLRequestID set SAMLStatusCode = @SAMLStatusCode where (InResponseTo)=@InResponseTo	
	END
	ELSE
	BEGIN
	--PRINT @SAMLFlag
		--Select @InResponseTo from SAMLRequestID
		if EXISTS(SELECT  1 FROM SAMLRequestID WHERE 									
										 ISNULL(InResponseTo,'')<>''
										 AND (InResponseTo)=@InResponseTo															
				 )
		BEGIN
			SELECT '1' CODE, 'Data Exist' Status
			Select distinct [SAMLStatusCode] from SAMLRequestID where (InResponseTo)=@InResponseTo	
		END
		ELSE
		BEGIN
			SELECT '0' CODE, 'Data Not Exist' Status
			Select '1' SAMLStatusCode

		END
	END
	  COMMIT TRANSACTION
	END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	select ERROR_MESSAGE()
END CATCH
END
GO