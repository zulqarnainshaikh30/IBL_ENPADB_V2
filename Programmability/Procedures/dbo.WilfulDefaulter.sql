SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================  
-- Author:    <FARAHNAAZ>  
-- Create date:   <29/03/2021>  
-- Description:   
-- =============================================  
CREATE PROCEDURE [dbo].[WilfulDefaulter]  
	(	@ReportingBank Varchar(50)='',
		@CustomerID		Varchar (20)='',
		@PartyName		varchar(100)='',
		@PAN			varchar(10)=''
	)
		

AS

    Begin
		
		Declare @TimeKey as Int
			SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C') 
				
					 BEGIN
			 
                 SELECT 
						
						ReportingBankFIAlt_Key,
						B.BankName as ReportedBank,
						ReportingBranchAlt_Key,
						StateUTofBranchAlt_Key,
						CustomerID,
						PartyName,
						PAN,
						ReportingSerialNo,
						OSAmountinlacs,
						SuitFiledorNotAlt_Key,
						OtherBanksFIInvolvedAlt_Key,
						CustomerTypeAlt_Key --As CustomerType,
						
				From WillfulDefaulters A
				--Inner Join (Select ParameterAlt_Key,ParameterName,'Reportedby' as Tablename 
				--		  from DimParameter where DimParameterName='Reportedby'
				--		  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)B
				--		  ON A.ReportedByAlt_Key=B.ParameterAlt_Key
				Inner Join DimBank B
				ON B.BankAlt_Key=A.ReportedByAlt_Key
				AND B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey
				where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
				And  @ReportingBank = @ReportingBank
				OR @CustomerID	= @CustomerID	
				OR @PartyName	= @PartyName			  
				OR @PAN			= @PAN		
		
		End
	End
GO