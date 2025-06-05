SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[FacilityDetailSelectAux]
	 @CustomerEntityID INT=0
	,@TimeKey	INT=0
	,@OperationFlag TINYINT=0

AS
--declare @CustomerEntityID INT=123229
--	,@TimeKey	INT=4109
--	,@OperationFlag TINYINT=2
BEGIN
	SET NOCOUNT ON;

	/*-- CREATE TABP TABLE FOR SELECT THE DATA*/
	IF OBJECT_ID('Tempdb..#FacilityDetailSelectAux') IS NOT NULL
		DROP TABLE #FacilityDetailSelectAux

	CREATE TABLE #FacilityDetailSelectAux
				(
					CustomerEntityID					INT,
					CustomerID							varchar(20),
					AccountEntityID						int,
					CustomerAcId						varchar(30),
					FacilityType						varchar(10),
					BranchCode							varchar(50),
					BranchName							varchar(50)
				)
	
			/*--DECLARE VARIABLE FOR SET THE MAKER CHECKER FLAG TABLE WISE--*/
				--DECLARE @FacilityType varchar(10), @CustomerACID varchar(30), @CustomerID varchar(20)

				--SELECT @CustomerACID=CustomerAcId, @FacilityType=FacilityType, @CustomerID= RefCustomerId FROM AdvAcBasicDetail WHERE (EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey) AND CustomerEntityID=@CustomerEntityID AND ISNULL(AuthorisationStatus,'A')='A' 
				--	print 12

				INSERT INTO #FacilityDetailSelectAux (CustomerEntityId,CustomerID,AccountEntityID,CustomerAcId,FacilityType,BranchCode)
				SELECT CustomerEntityId,RefCustomerId,AccountEntityID,CustomerAcId,FacilityType ,BranchCode
				FROM AdvAcBasicDetail  WHERE (EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey) AND CustomerEntityID=@CustomerEntityID AND ISNULL(AuthorisationStatus,'A')='A' 
					UNION 
				SELECT CustomerEntityId,RefCustomerId,AccountEntityID,CustomerAcId,FacilityType,BranchCode 
				 FROM AdvAcBasicDetail_MOD WHERE (EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey) AND CustomerEntityID=@CustomerEntityID AND AuthorisationStatus IN('NP','MP','DP','RM')
			
			--select * from #FacilityDetailSelectAux

			if @OperationFlag=16				
				BEGIN
					
					DELETE A	
						FROM #FacilityDetailSelectAux A
						 LEFT JOIN	(
										 SELECT A.AccountEntityID FROM AdvAcBasicDetail_MOD A 
											INNER JOIN #FacilityDetailSelectAux B
												ON (EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey) 
												AND A.AccountEntityId=B.AccountEntityID
												AND AuthorisationStatus IN('NP','MP','DP','RM')
										 UNION SELECT A.AccountEntityID FROM AdvAcOtherDetail_MOD A 
											INNER JOIN #FacilityDetailSelectAux B
												ON (EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey) 
												AND A.AccountEntityId=B.AccountEntityID
												AND AuthorisationStatus IN('NP','MP','DP','RM')
											UNION SELECT A.AccountEntityID FROM AdvAcFinancialDetail_MOD A
												INNER JOIN #FacilityDetailSelectAux B
														ON (EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey) 
														AND A.AccountEntityId=B.AccountEntityID
														AND AuthorisationStatus IN('NP','MP','DP','RM')
											UNION SELECT A.AccountEntityID FROM AdvAcBalanceDetail_MOD A
													INNER JOIN #FacilityDetailSelectAux B
														ON (EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey) 
														AND A.AccountEntityId=B.AccountEntityID
														AND AuthorisationStatus IN('NP','MP','DP','RM')
									) B ON A.AccountEntityID=B.AccountEntityID
							 WHERE B.AccountEntityId IS NULL
				END

			    UPDATE A
				SET  A.BranchName=DB.BranchName
				FROM  #FacilityDetailSelectAux A
				INNER JOIN DimBranch  DB    ON  (DB.EffectiveFromTimeKey<=@TimeKey and DB.EffectiveToTimeKey>=@TimeKey) AND DB.BranchCode=A.BranchCode
				WHERE A.CustomerEntityID=@CustomerEntityID

			SELECT * FROM #FacilityDetailSelectAux

			select CONVERT(VARCHAR(10),CustomerSinceDt,103) from CURDAT.CustomerBasicDetail where CustomerEntityId=@CustomerEntityID
				


END
GO