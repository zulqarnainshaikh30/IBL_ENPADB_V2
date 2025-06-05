SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROC [dbo].[CollateralValueEnquireSearchTaggingList]

--Declare
													
													--@PageNo         INT         = 1, 
													--@PageSize       INT         = 10, 
													--@OperationFlag  INT         = 1  --,
													--,@CustomerID	Varchar(100)	= NULL
													 @TaggingId		Varchar(100)	='1'
													--,@UCICID		Varchar(12)	=	NULL
													,@Cust_AcID_UCIF  Varchar(100)	=''
AS
     
	 --BEGIN


SET NOCOUNT ON;
Declare @TimeKey as Int
	SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')
					

			 IF OBJECT_ID('TempDB..#temp') IS NOT NULL
                 DROP TABLE  #temp;
              
                     SELECT	  B.RefSystemAcId
					          ,B.UCICID
                             ,B.RefCustomerId

					        ,b.Security_RefNo    as CollateralID--A.CollateralID
							,B.CollateralValueatSanctioninRs as CollateralValueatSanctioninRs
							,B.CollateralValueasonNPAdateinRs as CollateralValueasonNPAdateinRs
							,A.CurrentValue as CollateralValueatthetimeoflastreviewinRs
							--,A.ValuationSourceNameAlt_Key
							--,B.SourceName
							,convert(varchar(20),A.ValuationDate,103) ValuationDate
							,A.CurrentValue as LatestCollateralValueinRs
							,A.ExpiryBusinessRule
							,A.Periodinmonth
							,convert(varchar(20),A.ValuationExpiryDate,103) ValueExpirationDate
							--,C.ParameterName AS DisplayCollateralFor
							,B.TaggingAlt_Key
							,isnull(A.AuthorisationStatus, 'A') AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified
							,(CASE WHEN B.TaggingAlt_Key=1 THEN B.RefCustomerId
							      WHEN B.TaggingAlt_Key=2 THEN B.RefSystemAcId
								  WHEN B.TaggingAlt_Key=4 THEN B.UCICID
								  END ) TaggingId
								  ,'CollateralSearchGridData' TableName
						INTO  #temp  
						
                     FROM Curdat.AdvSecurityDetail B
					 LEFT Join Curdat.AdvSecurityValueDetail A on  A.SecurityEntityID = B.SecurityEntityID
					-- Inner Join DimParameter C on  B.TaggingAlt_Key = C.ParameterAlt_Key  AND C.DimParameterName='DimRatingType'
					                              

					 WHERE B.EffectiveFromTimeKey <= @TimeKey
                           AND B.EffectiveToTimeKey >= @TimeKey
						   AND A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           AND ISNULL(A.AuthorisationStatus, 'A') = 'A'

						  -- AND @TaggingId=C.ParameterAlt_Key


						   AND (@TaggingId=1 AND B.RefCustomerId=@Cust_AcID_UCIF
						   OR   @TaggingId=2 AND B.RefSystemAcId=@Cust_AcID_UCIF
						   OR   @TaggingId=4 AND B.UCICID=@Cust_AcID_UCIF)
	
	

	Alter Table #temp
	Add Previouscollateralvalue   Decimal(16,2)

	Update #temp
	Set  Previouscollateralvalue =A.CurrentValue  

	                FROM Curdat.AdvSecurityDetail B
				   Inner join #temp ON B.RefSystemAcId=#temp.RefSystemAcId or b.RefCustomerId=#temp.RefCustomerId
					 LEFT Join Curdat.AdvSecurityValueDetail A on  A.SecurityEntityID = B.SecurityEntityID


					 WHERE B.EffectiveFromTimeKey <= @TimeKey-1
                           AND B.EffectiveToTimeKey >= @TimeKey-1
						   AND A.EffectiveFromTimeKey <= @TimeKey-1
                           AND A.EffectiveToTimeKey >= @TimeKey-1



						   AND (@TaggingId=1 AND B.RefCustomerId=@Cust_AcID_UCIF
						   OR   @TaggingId=2 AND B.RefSystemAcId=@Cust_AcID_UCIF
						   OR   @TaggingId=4 AND B.UCICID=@Cust_AcID_UCIF)
						   






	select *   from #temp 
	  
	

	--select * from CollateralValueDetails
	--select * from CollateralMgmt
	--select * from DimParameter where DimParameterName='DimRatingType' 





GO