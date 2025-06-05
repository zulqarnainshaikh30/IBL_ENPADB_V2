SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author Triloki Kuamr>
-- Create date: <Create Date 03/04/2020>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Provision_Update]
@ProvisionAlt_Key int
,@Expression varchar(max)=''
,@FinalExpression VARCHAR(MAX)=''
--,@D2kTimestamp				INT	OUTPUT
,@Result					INT OUTPUT
,@UserId					VARCHAR(50)
,@OperationFlag				INT
AS
BEGIN
	


	SET NOCOUNT ON;

	Declare @Timekey int, @EffectiveFromTimeKey	int, @EffectiveToTimeKey	int

	 SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C') 

 SET @EffectiveFromTimeKey  = @TimeKey

	SET @EffectiveToTimeKey = 49999

  BEGIN TRY
	BEGIN TRAN


	IF (@OperationFlag=1)

	BEGIN

	IF NOT EXISTS(SELECT 1 FROM DimProvision_SegStd_Mod where BankCategoryID=@ProvisionAlt_Key 
	AND AuthorisationStatus IN ('NP','MP'))
	BEGIN
					INSERT INTO DimProvision_SegStd_Mod
								(
								Provision_Key
								,ProvisionAlt_Key
								,Segment
								,ProvisionRule
								,SecurityApplicable
								,ProductAlt_Key
								,BankCategoryID
								,ProvisionName
								,CategoryTypeAlt_Key
								,ProvisionShortNameEnum
								,ProvisionSecured
								,ProvisionUnSecured
								,LowerDPD
								,UpperDPD
								,AuthorisationStatus
								,EffectiveFromTimeKey
								,EffectiveToTimeKey
								,CreatedBy
								,DateCreated
								,ModifiedBy
								,DateModified
								,ApprovedBy
								,DateApproved
								,DB1_PROV
								,DB2_PROV
								,ProvProductCat
								,RBIProvisionSecured
								,RBIProvisionUnSecured
								,EffectiveFromDate
								,AdditionalBanksProvision
								,AdditionalprovisionRBINORMS
								,BusinessRuleAlt_Key
								,Expression
								,SystemFinalExpression
								,UserFinalExpression
								)

								SELECT 
								Provision_Key
								,ProvisionAlt_Key
								,Segment
								,ProvisionRule
								,SecurityApplicable
								,ProductAlt_Key
								,BankCategoryID
								,ProvisionName
								,CategoryTypeAlt_Key
								,ProvisionShortNameEnum
								,ProvisionSecured
								,ProvisionUnSecured
								,LowerDPD
								,UpperDPD
								,'MP' 
								,@Timekey AS EffectiveFromTimeKey
								,49999 EffectiveToTimeKey
								,@UserId  CreatedBy
								,GetDate()--DateCreated
								,NULL ModifiedBy
								,NULL DateModified
								,NULL ApprovedBy
								,NULL DateApproved
								,DB1_PROV
								,DB2_PROV
								,ProvProductCat
								,RBIProvisionSecured
								,RBIProvisionUnSecured
								,EffectiveFromDate
								,AdditionalBanksProvision
								,AdditionalprovisionRBINORMS
								,BusinessRuleAlt_Key
								,@Expression Expression
								,@FinalExpression SystemFinalExpression
								,UserFinalExpression

							From DimProvision_SegStd WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@TimeKey
							 and BankCategoryID=@ProvisionAlt_Key
							 
							 
							 Update DimProvision_SegStd SET AuthorisationStatus='MP'
							  WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@TimeKey
							 and BankCategoryID=@ProvisionAlt_Key
							

						END 
						ELSE
				BEGIN
						Update A set A.Expression=@Expression,A.SystemFinalExpression=@FinalExpression

					from DimProvision_SegStd_Mod A
					Where A.EffectiveFromTimeKey<=@Timekey AND A.EffectiveToTimeKey>=@TimeKey
					And A.BankCategoryID=@ProvisionAlt_Key 
					--AND B.AuthorisationStatus='NP'
					AND A.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM DimProvision_SegStd_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'A','RM')
                         GROUP BY BankCategoryID
                     )

		END
		END
	IF (@OperationFlag=16)

	BEGIN

	--IF EXISTS (SELECT 1 FROM DimProvision_SegStd WHERE EffectiveToTimeKey=49999 and BankCategoryID=@ProvisionAlt_Key)
	--					BEGIN
							
	--						Update DimProvision_SegStd Set EffectiveToTimeKey=@TimeKey-1
	--														,ModifiedBy				=@UserId
	--														,DateModified			=GETDATE()
	--								WHERE EffectiveToTimeKey=49999 and BankCategoryID=@ProvisionAlt_Key


	IF  EXISTS(SELECT 1 FROM DimProvision_SegStd where BankCategoryID=@ProvisionAlt_Key 
	AND AuthorisationStatus IN ('NP','MP','A'))
	BEGIN
		Update DimProvision_SegStd Set EffectiveToTimeKey=@TimeKey-1
										,ModifiedBy	=@UserId
										,DateModified=GETDATE()
										,AuthorisationStatus='A'
									WHERE EffectiveToTimeKey=49999 and BankCategoryID=@ProvisionAlt_Key
	
	
					INSERT INTO DimProvision_SegStd
								(
								Provision_Key
								,ProvisionAlt_Key
								,Segment
								,ProvisionRule
								,SecurityApplicable
								,ProductAlt_Key
								,BankCategoryID
								,ProvisionName
								,CategoryTypeAlt_Key
								,ProvisionShortNameEnum
								,ProvisionSecured
								,ProvisionUnSecured
								,LowerDPD
								,UpperDPD
								,AuthorisationStatus
								,EffectiveFromTimeKey
								,EffectiveToTimeKey
								,CreatedBy
								,DateCreated
								,ModifiedBy
								,DateModified
								,ApprovedBy
								,DateApproved
								,DB1_PROV
								,DB2_PROV
								,ProvProductCat
								,RBIProvisionSecured
								,RBIProvisionUnSecured
								,EffectiveFromDate
								,AdditionalBanksProvision
								,AdditionalprovisionRBINORMS
								,BusinessRuleAlt_Key
								,Expression
								,SystemFinalExpression
								,UserFinalExpression
								)

								Select 
								Provision_Key
								,ProvisionAlt_Key
								,Segment
								,ProvisionRule
								,SecurityApplicable
								,ProductAlt_Key
								,BankCategoryID
								,ProvisionName
								,CategoryTypeAlt_Key
								,ProvisionShortNameEnum
								,ProvisionSecured
								,ProvisionUnSecured
								,LowerDPD
								,UpperDPD
								,'A' AuthorisationStatus
								,@TimeKey EffectiveFromTimeKey
								,49999 EffectiveToTimeKey
								,@UserId  CreatedBy
								,GetDate() DateCreated
								,NULL ModifiedBy
								,NULL DateModified
								,NULL ApprovedBy
								,NULL DateApproved
								,DB1_PROV
								,DB2_PROV
								,ProvProductCat
								,RBIProvisionSecured
								,RBIProvisionUnSecured
								,EffectiveFromDate
								,AdditionalBanksProvision
								,AdditionalprovisionRBINORMS
								,BusinessRuleAlt_Key
								,Expression
								,SystemFinalExpression
								,UserFinalExpression

								From DimProvision_SegStd_Mod WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@TimeKey and BankCategoryID=@ProvisionAlt_Key
								AND AuthorisationStatus IN('MP','NP')


								Update DimProvision_SegStd_Mod SET AuthorisationStatus='A'
								WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@TimeKey and BankCategoryID=@ProvisionAlt_Key
								AND AuthorisationStatus IN('MP','NP')
END
--ELSE
--BEGIN

--					--Select * 
					
--					Update A set A.Expression=B.Expression,A.SystemFinalExpression=B.SystemFinalExpression

--					from DimProvision_SegStd A
--					Inner JOIN DimProvision_SegStd_Mod B ON A.BankCategoryID=B.BankCategoryID
--					AND B.EffectiveFromTimeKey<=@Timekey AND B.EffectiveToTimeKey>=@TimeKey
--					Where A.EffectiveFromTimeKey<=@Timekey AND A.EffectiveToTimeKey>=@TimeKey
--					And A.BankCategoryID=@ProvisionAlt_Key 
--					--AND B.AuthorisationStatus='NP'
--					AND A.EntityKey IN
--                     (
--                         SELECT MAX(EntityKey)
--                         FROM DimProvision_SegStd_Mod
--                         WHERE EffectiveFromTimeKey <= @TimeKey
--                               AND EffectiveToTimeKey >= @TimeKey
--                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP','A' ,'RM')
--                         GROUP BY BankCategoryID
--                     )


--								--------------------

--								--Update DimProvision_SegStd_Mod Set AuthorisationStatus='A'
--								--WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@TimeKey and BankCategoryID=@ProvisionAlt_Key
--								--AND AuthorisationStatus='NP'



							

--						--END 


		


--		END
		END
	COMMIT TRAN
	END TRY

	BEGIN CATCH

	SET @Result=-1
	RETURN @Result
	ROLLBACK TRAN
	END CATCH

END


GO