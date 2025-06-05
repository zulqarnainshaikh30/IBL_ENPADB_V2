SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================  
-- Author:    <FARAHNAAZ>  
-- Create date:   <29/03/2021>  
-- Description:   <All DropDown Select Query for WillfullDefaulterDropDown>
-- =============================================  
CREATE PROCEDURE [dbo].[WilfulDefaulterDropDown]  
	

AS

    Begin
		
		Declare @TimeKey as Int
			SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C') 
				
			  Select BankAlt_Key
					,BankName
					,'ReportedBank' as Tablename 
					from DimBank where --BankName='Reported Bank'
					 EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey
		
	

			Select	 ParameterAlt_Key
					,ParameterName
					,'ReportedBy' as Tablename 
			from DimParameter where DimParameterName='Reportedby'
							And	 EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey


			
			Select ParameterAlt_Key
					,ParameterName
					,'CategoryofBankFI' as Tablename 
			from DimParameter where DimParameterName='CategoryofBankFI' 
							And	 EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey


			--Select ParameterAlt_Key
			--		,ParameterName
			--		,'ReportedBank' as Tablename 
			--from DimParameter where DimParameterName='ReportedBank'
			--					 EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey

			--Select * from DimBranch

			Select	 BranchAlt_Key
					,BranchName
					,'ReportingBranch' as Tablename 
			from DimBranch where --BankName='Reportingbranch '
								 EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey
		

		--------------- SELECT * FROM DIMSTATE
		
			Select	 STATEAlt_Key
					,STATEName
					,'StateUTofBranch' as Tablename 
			from DIMSTATE where 
							EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey

							
			Select ParameterAlt_Key
					,ParameterName
					,'SuitFiledornot' as Tablename 
			from  DimParameter where --DimParameterName='Suit'
						EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey



			Select ParameterAlt_Key
						,ParameterName
								,'OtherbanksFIinvolved' as Tablename 
			from DimParameter where DimParameterName ='DimYesNo'
							AND EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey

		Select BranchAlt_Key
						,BranchName
								,'NameofotherbanksFI' as Tablename 
				from DimBranch WHERE --DimParameterName=''
							EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey

			
		Select ParameterAlt_Key
						,ParameterName
								,'CustomerType' as Tablename 
				from DimParameter where DimParameterName='CustomerType'
						And	EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey

		
				
				Select ParameterAlt_Key,ParameterName,'DirectorType' as Tablename 
									from DimParameter where DimParameterName='DirectorType'

		
End


								
GO