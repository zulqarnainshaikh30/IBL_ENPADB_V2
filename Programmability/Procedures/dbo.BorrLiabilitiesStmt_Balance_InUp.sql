SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		<HAMID>
-- Create date: <19 JULY 2018>
-- Description:	<TO INSERT  A DATA IN BALANCEDETAIL TABLE WHILE ISERTING A DATA LIABILITES TABLE>
-- =============================================
--BorrLiabilitiesStmt
--BorrBalanceDetail
CREATE PROC 	[dbo].[BorrLiabilitiesStmt_Balance_InUp]	
--DECLARE
		  @AuthMode					CHAR(1)
		, @OperationFlag			INT
		, @TimeKey					INT
		, @BaseColumnValue			VARCHAR(50) = NULL
		, @Remark					VARCHAR(200)=NULL
		, @MenuID					INT = 640
		, @EffectiveFromTimeKey		INT =0
		, @EffectiveToTimeKey		INT = 0
		, @CreateModifyApprovedBy	VARCHAR(20) ='D2KAMAR'
		, @D2Ktimestamp				INT =0 OUTPUT
		, @Result INT =1 OUTPUT
AS
BEGIN
		DECLARE @BorrEntityID INT
		 
		IF  ISNULL(@AuthMode,'N')='N' 
		BEGIN
			
			--FOR FINDING THE BaseColumn Value
			SELECT @BorrEntityID= MAX(EntityID) FROM BorrLiabilitiesStmt
			WHERE 
			ISNULL(AuthorisationStatus,'A')='A'
			AND (CASE WHEN @OperationFlag =1 AND EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey
						 THEN 1 
					  WHEN  ISNULL(@BaseColumnValue,'')<>'' AND EntityID = CAST(@BaseColumnValue AS INT)
					  THEN 1
					END)= 1

			DECLARE @Balance DECIMAL(18,2)=0
			
			--For Finding the Amount of BaseColumn Value 
			SELECT @Balance= ISNULL(BorrowingAmt,0) FROM BorrLiabilitiesStmt
			WHERE EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey
			AND ISNULL(AuthorisationStatus,'A')='A'
			AND (CASE WHEN @OperationFlag =1 THEN 1 
					  WHEN  ISNULL(@BaseColumnValue,'')<>'' AND EntityID = @BaseColumnValue
					  THEN 1
					END)= 1
			--FOR CASH CREDIT, OD AND On Maturity
			IF EXISTS(SELECT 1 FROM BorrLiabilitiesStmt WHERE 
			EffectiveFromTimeKey <= @Timekey AND EffectiveToTimeKey >= @Timekey 
			AND EntityID = @BorrEntityID
			AND (FacilityType = 25  OR InttRateFreqAlt_Key = 5)) --FacilityType = 25 FOR CC OD OR InttRateFreqAlt_Key = 5 FOR On Maturity
			BEGIN
				IF EXISTS (SELECT 1 FROM BorrBalanceDetail
				WHERE EffectiveFromTimeKey <= @Timekey AND EffectiveToTimeKey >= @Timekey
				AND BorrEntityID = @BorrEntityID)
				BEGIN
					PRINT 'Already Exists'
				END
				ELSE
				BEGIN
					PRINT 'INSERTING A DATA'
					EXEC [dbo].[BorrBalanceDetailInUp] 
							@BorrEntityID				=  @BorrEntityID 
							,@BorrBalanceEntityID		= NULL
							,@Balance	           		=  @Balance
							,@Remark					= @Remark
							,@MenuID					= @MenuID
							,@OperationFlag				= @OperationFlag
							,@AuthMode					= @AuthMode
							,@EffectiveFromTimeKey		= @EffectiveFromTimeKey
							,@EffectiveToTimeKey		= @EffectiveToTimeKey
							,@TimeKey					= @TimeKey
							,@CrModApBy					= @CreateModifyApprovedBy
							,@D2Ktimestamp				= @D2Ktimestamp	OUTPUT
							,@Result					= @Result		OUTPUT
				END
			END

			--FOR OTHER THEN CASH CREDIT, OD AND On Maturity
			IF NOT EXISTS(SELECT 1 FROM BorrLiabilitiesStmt WHERE 
			EffectiveFromTimeKey <= @Timekey AND EffectiveToTimeKey >= @Timekey 
			AND EntityID = @BorrEntityID
			AND (FacilityType = 25  OR InttRateFreqAlt_Key = 5))
			BEGIN
				PRINT 'FOR OTHER THAN CASH CREDIT, OD AND On Maturity'
				SELECT @Balance= ISNULL(BorrowingAmt,0) FROM BorrLiabilitiesStmt
				WHERE EffectiveFromTimeKey <= @Timekey AND EffectiveToTimeKey >= @Timekey
				AND EntityID = CAST(@BaseColumnValue AS INT)
				AND ISNULL(AuthorisationStatus,'A')='A'

				IF NOT EXISTS(SELECT 1 FROM BorrBalanceDetail
							WHERE EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey
							AND BorrEntityID= CAST(@BorrEntityID AS INT)
							AND ISNULL(AuthorisationStatus,'A') = 'A'
							AND Balance =@Balance)
							BEGIN
									PRINT 'INSERTING A DATA'
									EXEC [dbo].[BorrBalanceDetailInUp] 
									@BorrEntityID				=  @BorrEntityID 
									,@BorrBalanceEntityID		= NULL
									,@Balance	           		=  @Balance
									,@Remark					= @Remark
									,@MenuID					= @MenuID
									,@OperationFlag				= @OperationFlag
									,@AuthMode					= @AuthMode
									,@EffectiveFromTimeKey		= @EffectiveFromTimeKey
									,@EffectiveToTimeKey		= @EffectiveToTimeKey
									,@TimeKey					= @TimeKey
									,@CrModApBy					= @CreateModifyApprovedBy
									,@D2Ktimestamp				= @D2Ktimestamp	OUTPUT
									,@Result					= @Result		OUTPUT
							END

					
			END

			--FOR EXPIRING THE RECORD AS PER LIQUIDATION DATE
			IF EXISTS(SELECT 1 FROM BorrLiabilitiesStmt 
					WHERE EffectiveFromTimeKey < = @TimeKey AND EffectiveToTimeKey >= @TimeKey
					AND ISNULL(AuthorisationStatus,'A')='A'
					AND EntityID = CAST(@BaseColumnValue AS INT)
					AND ISNULL(LiquidationDate,'')<>'' )
					BEGIN
						

						--FOR FINDING A EXPIRE TIMEKEY ON THE BASIS ON LIQUIDATIONDATE
						DECLARE @ExpTimekey INT
							SELECT @ExpTimekey = mtx.TimeKey
							FROM BorrLiabilitiesStmt stmt
							INNER JOIN SysDayMatrix  mtx
								ON stmt.LiquidationDate = mtx.Date
								AND EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey
								AND ISNULL(AuthorisationStatus,'A')='A'
								AND EntityID = CAST(@BaseColumnValue AS INT)
								AND ISNULL(LiquidationDate,'')<>''
						
							--FOR EXPIRING THE RECORD FROM BorrLiabilitiesStmt TABLE 
							UPDATE BorrLiabilitiesStmt 
							SET EffectiveToTimeKey = @ExpTimekey
							WHERE EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey
								AND ISNULL(AuthorisationStatus,'A')='A'
								AND EntityID = CAST(@BaseColumnValue AS INT)

							--FOR EXPIRING THE RECORD FROM BorrBalanceDetail MAIN TABLE 
							UPDATE BorrBalanceDetail
							SET EffectiveToTimeKey = @ExpTimekey
							WHERE EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey
								AND ISNULL(AuthorisationStatus,'A')='A'
								AND BorrEntityID = CAST(@BaseColumnValue AS INT)
							
							
							--FOR EXPIRING THE RECORD FROM BorrBalanceDetail MOD TABLE 
							UPDATE A
							SET AuthorisationStatus = 'A'
							FROM BorrBalanceDetail_Mod A
							INNER JOIN 
							(
								SELECT  BorrEntityID, MAX(EntityKey) EntityKey 
								FROM BorrBalanceDetail_Mod
								WHERE EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey
								AND BorrEntityID = @BorrEntityID
								AND AuthorisationStatus IN  ('NP','MP','DP','RM')
								GROUP BY BorrEntityID
							)B ON A.EntityKey = B.EntityKey
					END
		END
		IF ISNULL(@AuthMode,'N')='Y' AND ISNULL(@OperationFlag,0)=16
		BEGIN
			--FOR FINDING THE BaseColumn Value
			SELECT @BorrEntityID= MAX(EntityID) FROM BorrLiabilitiesStmt
			WHERE 
			ISNULL(AuthorisationStatus,'A')='A'
			AND (CASE --WHEN @OperationFlag =1 AND EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey
						-- THEN 1 
							WHEN  ISNULL(@BaseColumnValue,'')<>'' AND EntityID = CAST(@BaseColumnValue AS INT)
					  THEN 1
					END)= 1
			
			DECLARE @BorrEntityIDYN	CHAR(1)
				IF EXISTS(SELECT 1 FROM BorrLiabilitiesStmt
					  WHERE EffectiveFromTimeKey <= @Timekey AND EffectiveToTimeKey >= @Timekey	
						AND EntityID = @BaseColumnValue)
				BEGIN
						SET @BorrEntityIDYN = 'Y'
				END
				ELSE
				BEGIN
					SET @BorrEntityIDYN = 'N'
				END


				DROP TABLE IF EXISTS #BorrLiabilitiesStmt
				SELECT A.* INTO #BorrLiabilitiesStmt FROM BorrLiabilitiesStmt A
				INNER JOIN 
				(
					SELECT  EntityID, MAX(EntityKey) EntityKey FROM BorrLiabilitiesStmt
					WHERE 
					--EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey AND 
					EntityID = CAST(@BaseColumnValue AS INT)
					GROUP BY EntityID
				)B ON A.EntityKey = B.EntityKey;
				--SELECT @BorrEntityIDYN,@BaseColumnValue;
				--SELECT * FROM #BorrLiabilitiesStmt


				MERGE BorrBalanceDetail T
				USING #BorrLiabilitiesStmt S
					ON  T.EffectiveFromTimeKey <= @TImekey
					AND T.EffectiveToTimeKey   >= @Timekey
					AND T.BorrEntityID = CAST(@BaseColumnValue AS INT)
				
				WHEN MATCHED AND (T.EffectiveFromTimeKey = @Timekey )
					THEN 

					UPDATE 
					--WHEN MATECHED WITH TIMEKEY  AND EXISTS IN MAIN TABLE THEN UPDATING A AMOUNT
					SET Balance				= CASE	WHEN ISNULL(@BorrEntityIDYN,'N')='Y'
															THEN  S.BorrowingAmt ELSE T.Balance END
						
						
					--WHEN MATECHED WITH TIMEKEY  AND  NOT EXISTS IN MAIN TABLE 
							, EffectiveToTimeKey	=  CASE	WHEN ISNULL(@BorrEntityIDYN,'N')='N'
															THEN @Timekey -1 ELSE S.EffectiveToTimeKey END
						
				--INSERTING A NEW RECORD
				WHEN NOT MATCHED
					THEN
							INSERT	(
									BorrEntityID
									,Balance
									,EffectiveFromTimeKey
									,EffectiveToTimeKey
									,AuthorisationStatus
									,CreatedBy
									,DateCreated
									,ModifiedBy
									,DateModified
									,ApprovedBy
									,DateApproved
								)
								VALUES
								(
									 S.EntityID
									,S.BorrowingAmt
									,S.EffectiveFromTimeKey
									,S.EffectiveToTimeKey
									,S.AuthorisationStatus
									,S.CreatedBy
									,S.DateCreated
									,S.ModifiedBy
									,S.DateModified
									,S.ApprovedBy
									,S.DateApproved
								);

		END
		
END
GO