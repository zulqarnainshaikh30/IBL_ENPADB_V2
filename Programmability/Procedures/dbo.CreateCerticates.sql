SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Verifies if master key,certificate SYMMETRIC keys exists else create one>
-- =============================================
create PROCEDURE [dbo].[CreateCerticates]
	
AS
BEGIN
	BEGIN TRY
	   Declare @Steps int=0;
	   if not exists(select 1 from sys.symmetric_keys where name like '%DatabaseMasterKey%')
	   BEGIN
	        Print 1
	      SET  @Steps=@Steps+1
			CREATE MASTER KEY ENCRYPTION 
			BY PASSWORD = 'D2k@DBA@admin@365';
	   END

	    if not exists(select 1 from sys.certificates where name='DBACert')
	   BEGIN
	   Print 2
	      SET  @Steps=@Steps+1
			CREATE CERTIFICATE DBACert
			ENCRYPTION BY PASSWORD = 'DBA@365'
			WITH SUBJECT = 'Column Encryption',
			EXPIRY_DATE = '12/31/2099';
	   END

	   if not exists(select 1 from sys.symmetric_keys where name ='DBA_Key')
	   BEGIN
	   Print 3
	      SET  @Steps=@Steps+1
			CREATE SYMMETRIC KEY DBA_Key
			WITH ALGORITHM = AES_256
			ENCRYPTION BY CERTIFICATE DBACert;
	   END

	   IF @Steps > 0
	   BEGIN
	       Print 'Master Key,Certificate,SYMMETRIC Created'
	   END
	   ELSE
	   BEGIN
	       Print 'Master Key,Certificate,SYMMETRIC Already Exists'
	   END

	END TRY
	BEGIN CATCH
	    Print 'error in certificate creation'
		Print ERROR_LINE()
		Print ERROR_MESSAGE()
	END CATCH

END
GO