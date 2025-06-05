SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

 

 

CREATE PROCEDURE [dbo].[InsertStockStatementETL]

AS

 

 

Declare @Timekey int = (select Timekey from Automate_Advances where Ext_flg = 'Y')

 

Delete from StockStatement where EffectiveFromTimeKey <= @Timekey and EffectiveToTimeKey >= @Timekey

 

 

INSERT INTO StockStatement(SrNo

,CIF

,CustomerLimitSuffix

,StockStamentDt

,AccountEntityID

,AuthorisationStatus

,EffectiveFromTimeKey

,EffectiveToTimeKey

,CreatedBy

,DateCreated

,ModifiedBy

,DateModified

,ApprovedBy

,DateApproved)

Select           distinct  ROW_NUMBER() OVER (PARTITION BY  RefCustomerId,Limit_Suffix ORDER BY RefCustomerId,Limit_Suffix) as Rnk,RefCustomerId as CIF,Limit_Suffix as CustomerLimitSuffix,                  

                 CONVERT (varchar(10), StockStmtDt, 103) as StockStatementDate ,A.AccountEntityId,'A',26560,49999,NULL,NULL,NULL,NULL,NULL,NULL

      from                       AdvacBasicDetail A

      LEFT JOIN ADVFACCCDETAIL B

      ON                          A.AccountEntityId = B.AccountEntityId

                  AND                    B.EffectiveFromTimeKey<=@Timekey

      And                         B.EffectiveToTimeKey>=@Timekey

      Where                   A.EffectiveFromTimeKey<=@Timekey

      And                         A.EffectiveToTimeKey>=@Timekey                         

                  AND                    A.LIMIT_SUFFIX IS NOT NULL

 
GO