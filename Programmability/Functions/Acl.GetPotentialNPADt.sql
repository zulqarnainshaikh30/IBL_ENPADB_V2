SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--===============================================================================================
-- Created by       : Shivendra Kumar Yadav
-- Created Date     : 08-08-2013
-- Description      : To find Potantial NPA Date.
-- Form/Report Name : 
--===============================================================================================
--===============================================================================================
--===============================  ALTER HISTORY ================================================
--===============================================================================================
--       Name             Date                    Reason                       Change
-- 1.  
-- 2.  
-- 3.  
--===============================================================================================
/*
  Hard Coded Fields Description: 
                                  Feild Name              Value             Significance
                               1. 
                               2. 
                               3. 

*/

CREATE FUNCTION [Acl].[GetPotentialNPADt]
										 (
										   @TimeKey SmallInt
										 )
RETURNS date
AS
BEGIN
        Declare @PotentialNPADt Date
    
		IF EXISTS (SELECT 1 FROM SysDataMatrix A WHERE A.TimeKey = A.Qtr_key)    /* If the prcessing date is qtr end date than potantialnpadate will be next qtr end date */
		SELECT @PotentialNPADt = DataEffectiveToDate
		FROM SysDataMatrix
		WHERE TimeKey = (SELECT MIN(TimeKey) FROM SysDataMatrix A
						 WHERE A.TimeKey = A.Qtr_key AND A.TimeKey > @TimeKey)
		ELSE                                                                     /* If the prcessing date is within qtr date than potantialnpadate will be qtr end date */
		SELECT @PotentialNPADt = B.DataEffectiveToDate
		FROM SysDataMatrix A
		INNER JOIN SysDataMatrix B ON A.Qtr_key = B.TimeKey
		WHERE A.TimeKey = @TimeKey

		RETURN @PotentialNPADt
END

GO