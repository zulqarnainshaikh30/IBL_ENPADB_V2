SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

         

/*======================         

AUTHER : SANJEEV KUMAR SHARAMA         

alter DATE : 06-03-2017         

MODIFY DATE : 06-03-2017         

DESCRIPTION : UPDATE unServisedIntt AccountWise 

--exec [PRO].[UpdateunServisedIntt_AccountWise]  25267       

=======================================*/         

          

CREATE PROCEDURE [PRO].[UpdateunServisedIntt_AccountWise]           

@TimeKey int           

WITH RECOMPILE         

AS         

 BEGIN           

 BEGIN TRY           

     DECLARE @ProcessingDate DATE         

       set @ProcessingDate = (select Date From SysDayMatrix Where Timekey = @TimeKey)         

          

----- Update Net Balance Calculate Amount In AdvacCal Table in NetBalance column           

          

            

--Update A            

--Set unServisedIntt = 0           

--From pro.AccountCal A         

 

 

           

--UPDATE A            

--SET A.unServisedIntt = (CASE WHEN isnull(A.InterestOverdue,0)+ISNULL(A.OtherOverdue,0)>  A.Balance     

--                          THEN A.Balance      

--                        ELSE isnull(A.InterestOverdue,0)+ISNULL(A.OtherOverdue,0) END )    

                           

--From pro.AccountCal A          

 

       

        

--UPDATE A         

--Set unServisedIntt = CASE When  DemandAmt> A.Balance THEN A.Balance ELSE DemandAmt END         

--From pro.AccountCal A                 

--Inner join (select CustomerACID,  sum(BalanceDemand) as DemandAmt from AdvAcCCDemandDetail          

--                                             where BalanceDemand > 0 and  DemandType = 'INTEREST'        

--                                             and DemandDate between  '2015-07-01' and  @ProcessingDate       

--                                             Group by CustomerACID

--                                             ) B          

--    On A.CustomerACID = B.CustomerACID          

--where  A.Balance>0        

        

            

          

 END TRY           

            

 BEGIN CATCH           

       SELECT 'Procedure Name :'+ERROR_PROCEDURE()+'Error Message :'+ERROR_MESSAGE()          

 END CATCH           

            

END

 

GO