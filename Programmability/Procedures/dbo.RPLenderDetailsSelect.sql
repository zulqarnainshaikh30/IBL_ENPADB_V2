SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--RP_Lender_Details
CREATE PROC [dbo].[RPLenderDetailsSelect] 
							
								@CustomerID VARCHAR(20)=''

AS
	BEGIN	

		Declare @TimeKey Int

			SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C') 
			
			 SELECT A.CustomerID
				   ,B.BankName ReportingLenderName
				   ,(case when convert(DATE,A.InDefaultDate)='' then NULL else Convert(VARCHAR(20),InDefaultDate,103) End) InDefaultDate
				   ,(case when convert(DATE,A.OutOfDefaultDate)='' then NULL else Convert(VARCHAR(20),OutOfDefaultDate,103) End) OutOfDefaultDate
				   ,A.DefaultStatus
				   ,'LenderGridData' as TableName
				   from RP_Lender_Details A
				   Inner Join DimBankRP B ON A.ReportingLenderAlt_Key=B.BankRPAlt_Key
				   And B.EffectiveFromTimeKey<=@Timekey And B.EffectiveToTimeKey>=@TimeKey
				   where A.CustomerID=@CustomerID
				   And A.EffectiveFromTimeKey<=@Timekey And A.EffectiveToTimeKey>=@TimeKey


	END


--exec RPLenderDetailsSelect @CustomerID=1




GO