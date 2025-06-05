SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE  [dbo].[SP_ReversefeedInsert]
AS
		exec [dbo].[ReverseFeedDataInsertENBD]

		exec [dbo].[SP_ReverseFeedDataCountENBD]
GO