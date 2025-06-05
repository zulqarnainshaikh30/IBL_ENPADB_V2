SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



-----------------------------------------

CREATE proc [dbo].[GetAdhocCustomerDetails]

 --declare
 @UCIF_ID varchar(max)=''

as
--  exec GetAdhocCustomerDetails @UCIF_ID='55'

begin

Declare @Timekey int
 SET @Timekey =(Select TimeKey from SysDataMatrix where CurrentStatus='C') 



  --SET @Timekey =(Select LastMonthDateKey from SysDayMatrix where Timekey=@Timekey) 




	DROP Table IF Exists #tmp_1
	
	----IF ((@UCIF_ID ='' or (@UCIF_ID is null)))


	--begin
	select * into #tmp_1 from (
 select		A.UCIF_ID as UCICID,A.RefCustomerID as CustomerId,A.CustomerName ,'AdhocCustDetails' as TableName ,
 Row_Number()over (order by  A.refCustomerID  desc) RowNumber
 from		PRO.CustomerCal_Hist A
--inner join  PRO.CustomerCal_Hist B
--on          A.CustomerId = B.RefCustomerID
where       A.UCIF_ID=@UCIF_ID
AND A.EffectiveFromTimeKey<=@Timekey
AND A.EffectiveToTimeKey>=@Timekey
--end 
 )R 
					    Where RowNumber=1


						Select * from #tmp_1
end


--select * from AdhocACL_ChangeDetails


--select		
--A.UCIF_ID
--,A.CustomerId
--,B.CustomerName 
 
-- from		AdhocACL_ChangeDetails A
--inner join  PRO.CustomerCal_Hist B
--on          A.CustomerId = B.RefCustomerID
--where      A. UCIF_ID ='55'
--AND A.EffectiveFromTimeKey<=25992
--AND A.EffectiveToTimeKey>=49999









GO