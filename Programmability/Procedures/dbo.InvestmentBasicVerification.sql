SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
/****** Object:  StoredProcedure [dbo].[InvestmentBasicVerification]    Script Date: 9/24/2021 8:20:04 PM ******/
--DROP PROCEDURE [dbo].[InvestmentBasicVerification]
--GO
--/****** Object:  StoredProcedure [dbo].[InvestmentBasicVerification]    Script Date: 9/24/2021 8:20:04 PM ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--exec [InvestmentbasicVerification] '2001' 
CREATE procedure [dbo].[InvestmentBasicVerification]

@InvID varchar(30)=''

AS
BEGIN

SET NOCOUNT ON;
	Declare @TimeKey as Int
	SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')

			IF NOT EXISTS(	SELECT		1 
							FROM		[CurDat].[InvestmentBasicDetail] A 
							LEFT JOIN	[CurDat].[InvestmentIssuerDetail] B ON A.RefIssuerID = B.IssuerID
							WHERE		(A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)  
							AND			A.InvID=@InvID
							AND			ISNULL(A.AuthorisationStatus, 'A') = 'A'
						)
							BEGIN
												SELECT A.*,IssuerID,IssuerName,InstrumentTypeName,IndustryName
												into #temp1
												FROM [CurDat].[InvestmentBasicDetail] A 	
												LEFT JOIN	[CurDat].[InvestmentIssuerDetail] B ON A.RefIssuerID = B.IssuerID											
												LEFT JOIN	DImInstrumentType C On A.InstrTypeAlt_Key = C.InstrumentTypeAlt_Key
												LEFT JOIN	DImIndustry D On A.Industry_AltKey = D.IndustryAlt_Key
												WHERE (A.EffectiveFromTimeKey<=@TimeKey 
												AND A.EffectiveToTimeKey>=@TimeKey)  
												AND A.InvId=@InvID 
												AND ISNULL(A.AuthorisationStatus, 'A') = 'A'

												SELECT 
												(SELECT ROW_NUMBER() OVER(ORDER BY InvEntityID) AS RowNumber), 
														COUNT(*) OVER() AS TotalCount, 
														'InvestmentCodeMaster' TableName, 
														*
												FROM #temp1
												END
												
												ELSE
												BEGIN
												SELECT		A.*,IssuerID,IssuerName,InstrumentTypeName,IndustryName into #temp
												FROM		[CurDat].[InvestmentBasicDetail] A 	
												LEFT JOIN	[CurDat].[InvestmentIssuerDetail] B ON A.RefIssuerID = B.IssuerID		
												LEFT JOIN	DImInstrumentType C On A.InstrTypeAlt_Key = C.InstrumentTypeAlt_Key
												LEFT JOIN	DImIndustry D On A.Industry_AltKey = D.IndustryAlt_Key									
												WHERE		(A.EffectiveFromTimeKey<=@TimeKey 
												AND			A.EffectiveToTimeKey>=@TimeKey)  
												AND			A.InvId=@InvID 
												AND			ISNULL(A.AuthorisationStatus, 'A') = 'A'

												SELECT 
												(SELECT ROW_NUMBER() OVER(ORDER BY InvEntityID) AS RowNumber), 
														COUNT(*) OVER() AS TotalCount, 
														'InvestmentCodeMaster' TableName, 
														*
												FROM #temp

												 END

												 END
GO