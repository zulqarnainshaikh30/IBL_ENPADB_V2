SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

 

 

CREATE Proc [dbo].[StockStatementMasterdataDownLoad]

 

AS

 

  BEGIN

 

Declare @Timekey as Int=25999

 

Set @Timekey= (select Timekey from SysDataMatrix where currentstatus='C')

 

      BEGIN

      ---  Drop Down for asset Class----

--    Select ROW_NUMBER() over(order by (select 1)) as SrNo ,CIF,CustomerLimitSuffix,StockStamentDt as StockStatementDate,TableName from(

--       Select ROW_NUMBER() OVER(partition by cif,CustomerLimitSuffix  ORDER BY  cif,CustomerLimitSuffix) as Rownumber

--          ,CIF

--           ,CustomerLimitSuffix

--           ,convert(varchar(10),StockStamentDt,103) StockStamentDt

--           ,'StockStatementUpload' As TableName

--          from StockStatement

--          Where EffectiveFromTimeKey<=@Timekey

--          And EffectiveToTimeKey>=@Timekey

            

 

--) X Where X.Rownumber=1

     

select ROW_NUMBER() over(order by (select 1)) as SrNo,*

from (

      Select       distinct RefCustomerId as CIF,Limit_Suffix as CustomerLimitSuffix,

                  --CustomerACID as AccountID,

                   (CASE WHEN ISNULL(StockStamentDt,'') <> '' THEN              CONVERT (varchar(10), StockStamentDt, 103)

                                                                                ELSE CONVERT (varchar(10), B.StockStmtDt, 103)  END)as StockStatementDate ,'StockStatementUpload' As TableName

      from                       AdvacBasicDetail A

      LEFT JOIN ADVFACCCDETAIL B

      ON                          A.AccountEntityId = B.AccountEntityId

                  AND                    B.EffectiveFromTimeKey<=@Timekey

      And                         B.EffectiveToTimeKey>=@Timekey

                LEFT JOIN  StockStatement C

                 ON                                        A.RefCustomerId = C.CIF and A.Limit_Suffix = C.CustomerLimitSuffix

                AND                                      C.EffectiveFromTimeKey<=@Timekey

      And                         C.EffectiveToTimeKey>=@Timekey

      Where                   A.EffectiveFromTimeKey<=@Timekey

      And                         A.EffectiveToTimeKey>=@Timekey                         

                  AND                    A.LIMIT_SUFFIX IS NOT NULL

                  )x

            

END

      END
GO