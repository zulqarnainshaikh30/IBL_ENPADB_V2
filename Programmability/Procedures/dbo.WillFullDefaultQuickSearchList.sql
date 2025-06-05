SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROC [dbo].[WillFullDefaultQuickSearchList]

				     @ReportedBy VARCHAR(20)=''
					 ,@CustomerId VARCHAR(20)=''
					,@PartyName VARCHAR(20)=''
					,@PAN VARCHAR(12)=''
					,@OperationFlag INT

AS
	BEGIN

	Declare @Timekey INT
 SET @Timekey =(Select TimeKey from SysDataMatrix where CurrentStatus='C') 


	

		BEGIN
		print @Timekey

		
		 	IF ((@CustomerId ='') AND  (@PartyName='') AND (@PAN ='' )   AND (@operationflag not in(16,20)))
		BEGIN
		print '111'
			
				Select  @ReportedBy as ReportedBy
					   ,A.CustomerId
					   ,E.CustomerName
					   ,A.OSAmountinlacs as [OSAmountinlacs]
					   ,A.ReportingSerialNo as ReportingSerialNo
					   ,B.ParameterName  as SuitFiled
					   ,C.BranchName as OtherBankInvolved
					   ,D.ParameterName as CustomerType
					   , '' as Action
					   ,'WillfullDefault' as TableName
				 from WillfulDefaulters_mod A
				  Left Join (
					 Select ParameterAlt_Key,ParameterName,'SuitFiled' as Tablename 
						  from DimParameter where DimParameterName='DimSuitAction'
						  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)B
						  ON A.SuitFiledorNotAlt_Key=B.ParameterAlt_Key

					Left Join  DimBranch C
						ON C.BranchAlt_Key=A.NameofOtherBanksFIAlt_Key 
						AND C.EffectiveFromTimeKey<=@TimeKey And C.EffectiveToTimeKey>=@TimeKey

					Left Join (
					 Select ParameterAlt_Key,ParameterName,'SuitFiled' as Tablename 
						  from DimParameter where DimParameterName='CustomerType'
						  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)D
						  ON A.CustomerTypeAlt_Key=B.ParameterAlt_Key

				    Left Join CustomerBasicDetail E
					          ON A.CustomerId=E.CustomerId    And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey

				  Where A.EffectiveFromTimeKey <= @Timekey
					   AND A.EffectiveToTimeKey >= @Timekey		
				 	 
				
				 return;
		END

		IF @CustomerId =''
		   SET @CustomerId=NULL

		IF @PartyName =''
		   SET @PartyName=NULL

		IF @PAN =''
		   SET @PAN=NULL

		IF (@OperationFlag not in(16,20))
		


				BEGIN
				
					Select  @ReportedBy as ReportedBy
					   ,A.CustomerId
					   ,E.CustomerName
					   ,A.OSAmountinlacs as [OSAmountinlacs]
					   ,A.ReportingSerialNo as ReportingSerialNo
					   ,B.ParameterName  as SuitFiled
					   ,C.BranchName as OtherBankInvolved
					   ,D.ParameterName as CustomerType
					   , '' as Action
					   ,'WillfullDefault' as TableName
				 from WillfulDefaulters_mod A
				  Left Join (
					 Select ParameterAlt_Key,ParameterName,'SuitFiled' as Tablename 
						  from DimParameter where DimParameterName='DimSuitAction'
						  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)B
						  ON A.SuitFiledorNotAlt_Key=B.ParameterAlt_Key

					Left Join  DimBranch C
						ON C.BranchAlt_Key=A.NameofOtherBanksFIAlt_Key 
						AND C.EffectiveFromTimeKey<=@TimeKey And C.EffectiveToTimeKey>=@TimeKey

					Left Join (
					 Select ParameterAlt_Key,ParameterName,'SuitFiled' as Tablename 
						  from DimParameter where DimParameterName='CustomerType'
						  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)D
						  ON A.CustomerTypeAlt_Key=B.ParameterAlt_Key

				    Left Join CustomerBasicDetail E
					          ON A.CustomerId=E.CustomerId    And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey

				  Where A.EffectiveFromTimeKey <= @Timekey
					   AND A.EffectiveToTimeKey >= @Timekey				
					AND  (A.CustomerID=@CustomerId
								OR A.PartyName=@PartyName
								OR A.PAN=@PAN
								
								
						)
				END

		END

		IF (@OperationFlag in (16))
		BEGIN
					Select  @ReportedBy as ReportedBy
					   ,A.CustomerId
					   ,E.CustomerName
					   ,A.OSAmountinlacs as [OSAmountinlacs]
					   ,A.ReportingSerialNo as ReportingSerialNo
					   ,B.ParameterName  as SuitFiled
					   ,C.BranchName as OtherBankInvolved
					   ,D.ParameterName as CustomerType
					   , '' as Action
					   ,'WillfullDefault' as TableName
				 from WillfulDefaulters_mod A
				  Left Join (
					 Select ParameterAlt_Key,ParameterName,'SuitFiled' as Tablename 
						  from DimParameter where DimParameterName='DimSuitAction'
						  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)B
						  ON A.SuitFiledorNotAlt_Key=B.ParameterAlt_Key

					Left Join  DimBranch C
						ON C.BranchAlt_Key=A.NameofOtherBanksFIAlt_Key 
						AND C.EffectiveFromTimeKey<=@TimeKey And C.EffectiveToTimeKey>=@TimeKey

					Left Join (
					 Select ParameterAlt_Key,ParameterName,'SuitFiled' as Tablename 
						  from DimParameter where DimParameterName='CustomerType'
						  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)D
						  ON A.CustomerTypeAlt_Key=B.ParameterAlt_Key

				    Left Join CustomerBasicDetail E
					          ON A.CustomerId=E.CustomerId    And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey

				  Where A.EffectiveFromTimeKey <= @Timekey
					   AND A.EffectiveToTimeKey >= @Timekey				
				 	 
					   AND ISNULL(A.AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM') 
					    
					--AND  (A.AccountID=@ACID
					--OR B.RefCustomerId=@CustomerId
					--   OR B.CustomerName like '%' + @CustomerName+ '%'
					--   OR B.UCIF_ID=@UCICID)



		END

		IF (@OperationFlag in (20))
		BEGIN
					Select  @ReportedBy as ReportedBy
					   ,A.CustomerId
					   ,E.CustomerName
					   ,A.OSAmountinlacs as [OSAmountinlacs]
					   ,A.ReportingSerialNo as ReportingSerialNo
					   ,B.ParameterName  as SuitFiled
					   ,C.BranchName as OtherBankInvolved
					   ,D.ParameterName as CustomerType
					   , '' as Action
					   ,'WillfullDefault' as TableName
				 from WillfulDefaulters_mod A
				  Left Join (
					 Select ParameterAlt_Key,ParameterName,'SuitFiled' as Tablename 
						  from DimParameter where DimParameterName='DimSuitAction'
						  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)B
						  ON A.SuitFiledorNotAlt_Key=B.ParameterAlt_Key

					Left Join  DimBranch C
						ON C.BranchAlt_Key=A.NameofOtherBanksFIAlt_Key 
						AND C.EffectiveFromTimeKey<=@TimeKey And C.EffectiveToTimeKey>=@TimeKey

					Left Join (
					 Select ParameterAlt_Key,ParameterName,'SuitFiled' as Tablename 
						  from DimParameter where DimParameterName='CustomerType'
						  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)D
						  ON A.CustomerTypeAlt_Key=B.ParameterAlt_Key

				    Left Join CustomerBasicDetail E
					          ON A.CustomerId=E.CustomerId    And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey

				  Where A.EffectiveFromTimeKey <= @Timekey
					   AND A.EffectiveToTimeKey >= @Timekey			
				 	 
					   AND ISNULL(A.AuthorisationStatus, 'A') IN('1A')     
				 
					    
					--AND  (A.AccountID=@ACID
					--OR B.RefCustomerId=@CustomerId
					--   OR B.CustomerName like '%' + @CustomerName+ '%'
					--   OR B.UCIF_ID=@UCICID)

	END
	END














GO