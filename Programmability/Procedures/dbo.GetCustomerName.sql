SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROC [dbo].[GetCustomerName]
@CustomerID INT  
AS
BEGIN
Select CustomerId,CustomerName from CustomerBasicDetail where CustomerId=@CustomerID
END

GO