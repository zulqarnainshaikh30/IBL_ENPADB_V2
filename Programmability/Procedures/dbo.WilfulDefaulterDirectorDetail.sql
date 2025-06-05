SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================  
-- Author:    <FARAHNAAZ>  
-- Create date:   <1/04/2021>  
-- Description:   < SP for [WilfulDefaulterDirectorDetail]>
-- =============================================  
CREATE PROCEDURE [dbo].[WilfulDefaulterDirectorDetail]

--Declare 
					@DirectoreName			Varchar(100) ='',
					@Pan					Varchar(10)='',
					@Din					Numeric(8,2),
					@DirectorType			varchar(50)=''

AS
			
    Begin
		
		Declare @TimeKey as Int
			SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C') 
				
					 BEGIN
			 
                 SELECT A.Entity_Key,
						A.DirectorName,
						A.PAN,
						A.DIN,
						A.DirectorTypeAlt_Key,
						B.DimParameterName as DirectoryType,
						A.AuthorisationStatus.
						A.EffectiveFromTimeKey,
						A.EffectiveToTimeKey.
						A.CreatedBy,
						A.DateCreated,
						A.ModifiedBy,
						A.DateModified,
						A.ApprovedBy,
						A.DateApproved 

				From WillfulDirectorDetail A
				Inner Join (Select ParameterAlt_Key,ParameterName,'DirectorType' as Tablename 
						  from DimParameter where DimParameterName='DirectorType'
						  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)B
						  ON A.DirectorTypeAlt_Key=B.ParameterAlt_Key
						  And 	@DirectoreName	=	@DirectoreName		
							Or	@Pan			=	@Pan				
							Or	@Din			=	@Din				
							Or	@DirectorType	=	@DirectorType		



		
				--Inner Join DimBank B
				--ON B.BankAlt_Key=A.ReportedByAlt_Key
				--AND B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey
				--where A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey
				--And  @ReportingBank = @ReportingBank
				--OR @CustomerID	= @CustomerID	
				--OR @PartyName	= @PartyName			  
				--OR @PAN			= @PAN		
		
		End
	End
GO