SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


-- [Cust_grid_PUI] '1714222715864042'
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE proc [dbo].[Fraud_View_History]
@AccountID Varchar(50)

as
BEGIN

--declare @ProcessDate Datetime
--declare @ProcessDateold Datetime


--Set @ProcessDate =(select DataEffectiveFromDate from SysDataMatrix where CurrentStatus='C')
DECLARE @Timekey int
		
  SET @Timekey =(Select TimeKey from SysDataMatrix where CurrentStatus='C') 

--SET @ProcessDateold=@ProcessDate-15


		BEGIN

					Select	
						Distinct 	 RefCustomerACID
							 ,'FraudHistory' as TableName
							,RefCustomerID
							,D.ParameterName as RFA_ReportingByBank
							,RFA_DateReportingByBank
							,E.ParameterName as RFA_OtherBankAltKey
							,RFA_OtherBankDate
							,FraudOccuranceDate
							,FraudDeclarationDate
							,FraudNature
							,FraudArea
							,CurrentAssetClassAltKey
							,F.ParameterName as ProvPref
							,(CASE WHEN cast(A.NPADateBeforeFraud as date) = '01/01/1900' THEN '' ELSE Convert(Varchar(10),A.NPADateBeforeFraud,103) END) as NPA_DateAtFraud
							,AssetClassAtFraudAltKey
							,A.NameofBank
							,A.AuthorisationStatus
							,A.EffectiveFromTimeKey
							,A.EffectiveToTimeKey
							,A.CreatedBy
							,convert(varchar(20),A.DateCreated,103) DateCreated
							,A.ModifiedBy
							,convert(varchar(20),A.DateModified,103) DateModified
							,A.ApprovedBy
							,convert(varchar(20),A.DateApproved,103) DateApproved
							,A.FirstLevelApprovedBy
							,convert(varchar(20),A.FirstLevelDateApproved,103) FirstLevelDateApproved
							,A.FraudAccounts_ChangeFields
							,A.screenFlag
					FROM Fraud_Details_Mod A
					inner join sysdaymatrix S1 ON S1.Timekey=A.EffectiveFromTimekey
					inner join sysdaymatrix S2 ON S2.Timekey=A.EffectiveToTimekey
					LEFT JOIN 
			(Select ParameterAlt_Key
		,CASE WHEN ParameterName='NO' THEN 'N' else 'Y' END ParameterName
		,'RFA_Reported_By_Bank' as Tablename 
		from DimParameter where DimParameterName='DimYesNo'
		And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)D 
		ON A.RFA_ReportingByBank = D.ParameterAlt_Key
		LEFT JOIN (Select BankRPAlt_Key as ParameterAlt_Key
		,BankName as ParameterName
		,'Name_of_Other_Banks_Reporting_RFA' as Tablename 
		from DimBankRP where 
		 EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		 )E ON A.RFA_OtherBankAltKey = E.ParameterAlt_Key
		LEFT JOIN  (
		 Select ParameterAlt_Key
		,ParameterName
		,'Provision_Proference' as Tablename 
		from DimParameter where DimParameterName='DimProvisionPreference'
		And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		)F ON A.ProvPref = F.ParameterAlt_Key
	--	WHERE  A.EffectiveFromTimeKey<=@Timekey AND A.EffectiveToTimeKey>=@Timekey   --commented to show only approved records
    --	AND	 A.RefCustomerACID=@AccountID
			WHERE	 A.RefCustomerACID=@AccountID
					AND ISNULL(A.AuthorisationStatus,'A')='A'
					--And Convert(date,A.Actual_Write_Off_Date)>=  Convert(Date,@ProcessDateold)
					--and Convert(date,A.Actual_Write_Off_Date)<=  Convert(Date,@ProcessDate)

		END

	END

GO