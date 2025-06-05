SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[IBPCDataUpload_Validate]
	@XMLDocument  XML=N''  
	,@ScreenName		   VARCHAR(50)=''
AS
BEGIN
   Print 'IBPCDataUpload_Validate'
   IF OBJECT_ID('Tempdb..#IBPCDataUpload') IS NOT NULL
DROP TABLE #IBPCDataUpload


SELECT 
 C.value('./Soldto				[1]','VARCHAR(50)'	)ParticipatingBank
,C.value('./CustID				[1]','VARCHAR(20)'	)CustomerId
,C.value('./AccountNumber					[1]','VARCHAR(30)'	)CustomerACID
,C.value('./Segment				[1]','VARCHAR(100)'	)REMARK
,C.value('./Customer				[1]','VARCHAR(100)'	)CUSTOMERNAME
,C.value('./IBPCSep19					[1]','VARCHAR(30)'	) [IBPC_Amount]

INTO #IBPCDataUpload
--FROM @XMLDocument.nodes('/DataSet/BondsUploadEntry') AS t(c)
FROM @XMLDocument.nodes('/Root/Sheet1') AS t(c)


Alter table #IBPCDataUpload
Add SrNo INT

Update
#IBPCDataUpload Set #IBPCDataUpload.SrNo=RowNo

from
(
  Select ROW_NUMBER() over (order by CustomerId) as RowNo,CustomerId from  #IBPCDataUpload
) D
where D.CustomerId=#IBPCDataUpload.CustomerId


CREATE TABLE #ErrorData
  (  
   srno INT
   --,Row_No  SMALLINT  
   ,CustomerId VARCHAR(50)  
   ,columnName VARCHAR(100)  
   ,errorData VARCHAR(100)  
   ,errorDescription varchar(max)
  )   

  --ISNUMERIC(T.Amount)
     insert into #ErrorData
  (
    srno,CustomerId,columnName,errorData,errorDescription
  )
  (

    Select
	
	srno,CustomerId,'CustomerId' columnName, ISNULL(CustomerId,'') errorData,
	
	'CustomerId should be a numeric'  errorDescription
	from #IBPCDataUpload
	where
	ISNUMERIC(CustomerId)=0 AND ISNULL(CustomerId,'') <> ''
  )

  ---------


     Insert into #ErrorData
  (
   srno,CustomerId,columnName,errorData,errorDescription

  )
  (
  Select

  srno,CustomerId,'Customer Id',CustomerId,'Customer Id  Allows max 8 digits value'
  from #IBPCDataUpload
  where LEN(ISNULL(CustomerId,''))  > 5 AND ISNULL(CustomerId,'') <> ''

  )


  ---------------
     insert into #ErrorData
  (
    srno,CustomerId,columnName,errorData,errorDescription
  )
  (

    Select
	
	srno,ParticipatingBank,'SoldTo' columnName, ISNULL(ParticipatingBank,'') errorData,
	
	'Sold to should be containing alphanumeric value'  errorDescription
	from #IBPCDataUpload
	where ParticipatingBank not like '%[0-9][a-zA-Z]%' and ParticipatingBank like '%()><.,?/[]{}*&^%$#@!%'
	
  )

  
  --------

  ---------

    Insert into #ErrorData
  (
   
    srno,CustomerId,columnName,errorData,errorDescription
  )
  (
  Select

  srno,CustomerACID,'Customer ACID',CustomerACID,'Customer ACCOUNT ID  Allows max 8 digits value'
  from #IBPCDataUpload
  where LEN(ISNULL(CustomerACID,''))  > 12  AND ISNULL(CustomerACID,'') <> '' 

	


  )


  ---

      
      Insert into #ErrorData
  (
   srno,CustomerId,columnName,errorData,errorDescription)
 
  (
  Select

  srno,REMARK,'Segment',REMARK,'Segment should be containing character value'
  from #IBPCDataUpload
  where ISNULL(REMARK,'') <> ''	and REMARK not like '%[a-zA-Z]%'

  )
  ----

    
      Insert into #ErrorData
  (
   srno,CustomerId,columnName,errorData,errorDescription

  )
  (
  Select

  srno,CUSTOMERNAME,'Customer Name',CUSTOMERNAME,'Customer Name should be containing alphanumeric value'
  from #IBPCDataUpload
  where ISNULL(CUSTOMERNAME,'') <> ''	and CUSTOMERNAME not like '%[a-zA-Z]%'

  )






  -----------



    
      Insert into #ErrorData
  (
   srno,CustomerId,columnName,errorData,errorDescription

  )
  (
  Select

  srno,[IBPC_Amount],'IBPC_Amount',[IBPC_Amount],'IBPC_Amount contains numeric values'
  from #IBPCDataUpload
  where ISNUMERIC([IBPC_Amount])=0  AND ISNULL([IBPC_Amount],'') <> ''	

  )



  ---------



  Select srno,CustomerId,columnName,errorData,errorDescription,'validationerror' as TableName from #ErrorData order by srno
END
GO