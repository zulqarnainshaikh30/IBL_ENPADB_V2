SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


 
create PROCEDURE [dbo].[Rpt-Disbursement Date Selection]
      @TimeKey AS INT 
AS

--DECLARE  @TimeKey AS INT=26959 

SELECT DISTINCT
--FORMAT( FirstDtOfDisb,'yyyy-MM-dd') FirstDtOfDisb 

-------- comment by pradeep on 05092024 due to need in data format------------
----CONVERT(VARCHAR(15), FirstDtOfDisb,103) FirstDtOfDisb ,
(FORMAT(CAST(FirstDtOfDisb AS DATE),'dd-MM-yyyy'))	AS FirstDtOfDisb

,FirstDtOfDisb			AS DISB_DATE
FROM  PRO.AccountCal_Hist
--WHERE	EffectiveFromTimeKey<=@TimeKey
--		AND EffectiveToTimeKey>=@TimeKey

 order by DISB_DATE desc
GO