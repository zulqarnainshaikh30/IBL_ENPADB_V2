SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


-- =============================================
-- Author:		<Madhur Nagar>
-- Create date: <03/05/2011>
-- Description:	<Calculation of Govt. Guar Amount from Ac to Customer Depends on parameter>
-- =============================================

CREATE FUNCTION [dbo].[getGovGurAmt](@CustomerEntityID int,@timekey smallint)
RETURNS Decimal
 
AS
BEGIN
	--Declare Part
		Declare @GovGurAmt decimal(14,0),@Strclientname varchar(6),@GovtGuarantee varchar(8)
	
	--Find out Client Name
	Select @Strclientname= ParameterValue from SysSolutionParameter where ParameterName='ClientName' AND EffectiveFromTimeKey<=@timekey AND EffectiveToTimeKey>=@timekey
	
	--Find out Security parameter
	Select @GovtGuarantee= ParameterValue from SysSolutionParameter where ParameterName='GovtGuarantee' AND EffectiveFromTimeKey<=@timekey AND EffectiveToTimeKey>=@timekey
	
	--Set Default value to Zero
	SELECT @GovGurAmt=0
	
--In CUSTFULL sum of Govt guar amt of all Acc where Govt Guar available
--In CUSTAPP sum of govt. guar amt to the extebd of OS Bal  where Govt Guar available

	--Govt. Guar. amount at account level Directly updated at Customer level without any logic
	
	IF @GovtGuarantee='CUSTFULL'
		BEGIN
			SELECT @GovGurAmt= SUM(GovGurAmt) 
			FROM AdvAcOtherDetail 
				INNER JOIN AdvAcCal 
					ON AdvAcCal.AccountEntityID=AdvAcOtherDetail.AccountEntityId 
				INNER JOIN DimAcSplCategory AS DimAcSplCategory1 
					ON AdvAcOtherDetail.SplCatg1Alt_Key =DimAcSplCategory1.SplCatAlt_Key 
				INNER JOIN  DimAcSplCategory AS DimAcSplCategory2 
					ON	AdvAcOtherDetail.SplCatg2Alt_Key =DimAcSplCategory2.SplCatAlt_Key
			WHERE (AdvAcOtherDetail.EffectiveFromTimeKey <=@timekey And AdvAcOtherDetail.EffectiveToTimeKey>=@timekey) 
				And (AdvAcCal.EffectiveFromTimeKey<=@Timekey AND AdvAcCal.EffectiveToTimeKey>=@Timekey)
				and (DimAcSplCategory1.SplCatShortNameEnum IN ('STGOVT GUA','CENGOV GUA') Or DimAcSplCategory2.SplCatShortNameEnum IN ('STGOVT GUA','CENGOV GUA') ) 
				And AdvAcCal.CustomerEntityID=@CustomerEntityID
		END
	--Govt. Guar. Amount at Account level compare with bal OS which is less will be updated sum of as customer level
	ELSE IF  @GovtGuarantee='CUSTAPP'
		BEGIN
			WITH CTE_GovtGuar (Customer_Key,Ac_Key,GovGurAmt)
			AS
			(
				SELECT @CustomerEntityID,AdvAcCal.AccountEntityID
					,CASE WHEN ISNULL(AdvAcOtherDetail.GovGurAmt,0)>ISNULL(AdvAcBalanceDetail.Balance,0) THEN 
						ISNULL(AdvAcBalanceDetail.Balance,0) 
					 ELSE 
						ISNULL(AdvAcOtherDetail.GovGurAmt,0) 
					 END AS GovGurAmt  
				FROM AdvAcOtherDetail 
					INNER JOIN AdvAcCal 
						ON AdvAcCal.AccountEntityID=AdvAcOtherDetail.AccountEntityID 
					INNER JOIN AdvAcBalanceDetail 
						ON AdvAcCal.AccountEntityID=AdvAcBalanceDetail.AccountEntityID 
					INNER JOIN DimAcSplCategory AS DimAcSplCategory1 
						ON AdvAcOtherDetail.SplCatg1ALt_Key =DimAcSplCategory1.SplCatAlt_Key 
					INNER JOIN  DimAcSplCategory AS DimAcSplCategory2 
						ON AdvAcOtherDetail.SplCatg2Alt_Key =DimAcSplCategory2.SplCatAlt_Key
				WHERE (AdvAcBalanceDetail.EffectiveFromTimeKey<=@timekey AND AdvAcBalanceDetail.EffectiveToTimeKey>=@timekey) 
				 And  (AdvAcOtherDetail.EffectiveFromTimeKey <=@timekey And AdvAcOtherDetail.EffectiveToTimeKey>=@timekey) 
					And AdvAcCal.EffectiveFromTimeKey<=@timekey And AdvAcCal.EffectiveToTimeKey>=@timekey
					and (DimAcSplCategory1.SplCatShortNameEnum IN ('STGOVT GUA','CENGOV GUA') Or DimAcSplCategory2.SplCatShortNameEnum IN ('STGOVT GUA','CENGOV GUA') )
					And AdvAcCal.CustomerEntityID=@CustomerEntityID
			 )
			 
			SELECT @GovGurAmt=SUM (CTE_GovtGuar.GovGurAmt) from  CTE_GovtGuar 
		END
RETURN @GovGurAmt
END

GO