SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[getSqlFormatDate] (@asOnDate varchar(55) )                
RETURNS datetime AS                
BEGIN              
              
              
set @asOnDate =  replace(@asOnDate, ' ', '')              
set @asOnDate =  replace(@asOnDate, '-', '/')    
set @asOnDate =  replace(@asOnDate, '.', '/')                
Declare @Month as varchar(5)              
Declare @day as varchar(5)              
Declare @Year as varchar(5)              
Declare @loc1 as int              
Declare @loc2 as int              
              
set @loc1 = CHARINDEX('/', @asOnDate ,  0)              
set @loc2 = CHARINDEX('/', @asOnDate ,  @loc1 + 1)              
set @day = SUBSTRING(@asOnDate, 0 , @loc1)              
set @Month = SUBSTRING(@asOnDate, @loc1+1 , @loc2 - (@loc1+1))              
set @Year = SUBSTRING(@asOnDate,  @loc2 + 1, len(@asOnDate))              
if(len(@Year))= 2              
 begin              
  set @Year =  @Year + 2000              
 end               
set @asOnDate  = @Year + '-' + @Month + '-' + @day              
return @asOnDate              
END 

GO