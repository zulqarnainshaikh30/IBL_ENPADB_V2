SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [ETL_MAIN].[DERVCANCEL_SOURCESYSTEM_Main]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @Timekey int = (SELECT TIMEKEY FROM UTKS_MISDB.DBO.AUTOMATE_ADVANCES WHERE EXT_FLG='Y')
	DECLARE @VEFFECTIVETO INT SET @VEFFECTIVETO=(SELECT TIMEKEY-1 FROM UTKS_MISDB.DBO.AUTOMATE_ADVANCES WHERE EXT_FLG='Y')

------------For New Records
--UPDATE A SET A.IsChanged='N'
------Select * 
--from UTKS_TEMPDB.DBO.TEMPDERVCANCEL_SOURCESYSTEM A
--Where Not Exists(Select 1 from cURDAT.DerivativeDetail B Where B.EffectiveToTimeKey=49999
--And A.DerivativeRefNo=B.DerivativeRefNo) -- And A.SourceAlt_Key=B.SourceAlt_Key)



--UPDATE O SET O.EffectiveToTimeKey=@vEffectiveto,
-- O.DateModified=CONVERT(DATE,GETDATE(),103),
-- O.ModifiedBy='SSISUSER'

--FROM CurDat.DerivativeDetail AS O
--INNER JOIN UTKS_TEMPDB.DBO.TEMPDERVCANCEL_SOURCESYSTEM AS T
--ON O.DerivativeRefNo=T.DerivativeRefNo

--and O.EffectiveToTimeKey=49999
--AND T.EffectiveToTimeKey=49999

--WHERE
--( 
-- isnull(O.CustomerACID,0) <> isnull(T.[AcID],0) 
--OR isnull(O.CustomerID,0) <> isnull(T.[CustID] ,0)
--OR isnull(O.CustomerName,0) <> isnull(T.CustomerName,0) 
--OR isnull(O.DerivativeRefNo,0) <> isnull(T.DerivativeRefNo,0) 
--OR isnull(O.Duedate,'1990-01-01') <> isnull(T.Duedate,'1990-01-01') 
--OR isnull(O.DueAmt,0) <> isnull(T.DueAmt,0) 
--OR isnull(O.OsAmt,0) <> isnull(T.[Os_Amt],0) 
--OR isnull(O.POS,0) <> isnull(T.POS,0) 

--)



------------For Changes Records
--UPDATE A SET A.IsChanged='C'
------Select * 
--from UTKS_TEMPDB.DBO.TEMPDERVCANCEL_SOURCESYSTEM A
--INNER JOIN CurDat.DerivativeDetail B 
--ON  A.DerivativeRefNo=B.DerivativeRefNo
--Where B.EffectiveToTimeKey= @vEffectiveto

---------------------------------------------------------------------------------------------------------------

---------Expire the records
--UPDATE AA
--SET 
-- EffectiveToTimeKey = @vEffectiveto,
-- DateModified=CONVERT(DATE,GETDATE(),103),
-- ModifiedBy='SSISUSER' 
--FROM CurDat.DerivativeDetail AA
--WHERE AA.EffectiveToTimeKey = 49999
--AND NOT EXISTS (SELECT 1 FROM UTKS_TEMPDB.DBO.TEMPDERVCANCEL_SOURCESYSTEM BB
--    WHERE  AA.DerivativeRefNo=BB.DerivativeRefNo
--    AND BB.EffectiveToTimeKey =49999
--    )

	

UPDATE O 
SET O.EffectiveToTimeKey=@vEffectiveto,
 O.DateModified=CONVERT(DATE,GETDATE(),103),
 O.ModifiedBy='SSISUSER'
FROM CurDat.DerivativeDetail AS O
where O.EffectiveToTimeKey=49999

INSERT INTO curdat.DerivativeDetail
			(
			[DateofData] 
	       ,[SourceSystem] 
	       ,[BranchCode] 
	       ,[UCIC_ID] 
	       ,CustomerID
	       ,[CustomerName] 
	       ,CustomerACID 
	      ,[DerivativeRefNo] 
	      ,[Duedate]  
	      ,[DueAmt] 
	      ,OsAmt 
	      ,[POS] 
		  ,MTMIncomeAmt
		,CouponDate
		,CouponAmt
		,CouponOverDueSinceDt
		,OverdueCouponAmt
		,InstrumentName
		,OverdueSinceDt   
		 ,[AuthorisationStatus] 
         ,[EffectiveFromTimeKey] 
	     ,[EffectiveToTimeKey] 
	     ,[CreatedBy] 
	     ,[DateCreated]
	     ,[ModifiedBy] 
	     ,[DateModified] 
	     ,[ApprovedBy] 
	     ,[DateApproved]
		 ,DerivativeEntityID
			
		)

SELECT		
               [DateofData] 
	         ,[SourceSystem] 
	         ,[BranchCode] 
	         ,[UCIC_ID] 
	         , [CustID]                                                                                
	         ,[CustomerName] 
	         ,[AcID] 
	         ,[DerivativeRefNo] 
	        ,[Duedate]  
	        ,[DueAmt] 
	        ,[Os_Amt] 
	        ,[POS]  
			,MTMIncomeAmt
		,CouponDate
		,CouponAmt
		,CouponOverDueSinceDt
		,OverdueCouponAmt
		,InstrumentName
		,OverdueSinceDt 
	       , AuthorisationStatus
		 , EffectiveFromTimeKey
			, EffectiveToTimeKey
			, CreatedBy
			, DateCreated
			, ModifiedBy
			, DateModified
			, ApprovedBy
			, DateApproved
			,DerivativeEntityID
		  FROM UTKS_TEMPDB.dbo.TEMPDERVCANCEL_SOURCESYSTEM T 
		  Where DerivativeEntityID is not NULL

		  
---------------------------Carry Forward DPD accounts for future--------22062022---------

INSERT INTO curdat.DerivativeDetail
			(
			[DateofData] 
	       ,[SourceSystem] 
	       ,[BranchCode] 
	       ,[UCIC_ID] 
	       ,CustomerID
	       ,[CustomerName] 
	       ,CustomerACID 
	      ,[DerivativeRefNo] 
	      ,[Duedate]  
	      ,[DueAmt] 
	      ,OsAmt 
	      ,[POS] 
		  ,MTMIncomeAmt
		,CouponDate
		,CouponAmt
		,CouponOverDueSinceDt
		,OverdueCouponAmt
		,InstrumentName
		,OverdueSinceDt   
		 ,[AuthorisationStatus] 
         ,[EffectiveFromTimeKey] 
	     ,[EffectiveToTimeKey] 
	     ,[CreatedBy] 
	     ,[DateCreated]
	     ,[ModifiedBy] 
	     ,[DateModified] 
	     ,[ApprovedBy] 
	     ,[DateApproved]
		 ,DerivativeEntityID
			
		)

		

SELECT		
               A.[DateofData] 
	         ,A.[SourceSystem] 
	         ,A.[BranchCode] 
	         ,A.[UCIC_ID] 
	         ,A.CustomerID                                                                                
	         ,A.[CustomerName] 
	         ,A.CustomerACID 
	         ,A.[DerivativeRefNo] 
	        ,A.[Duedate]  
	        ,A.[DueAmt] 
	        ,A.OsAmt 
	        ,A.[POS]  
			,A.MTMIncomeAmt
		,A.CouponDate
		,A.CouponAmt
		,A.CouponOverDueSinceDt
		,A.OverdueCouponAmt
		,A.InstrumentName
		,A.OverdueSinceDt 
	     ,A.AuthorisationStatus
		 , @Timekey
			, 49999
			, A.CreatedBy
			, A.DateCreated
			, A.ModifiedBy
			, A.DateModified
			, A.ApprovedBy
			, A.DateApproved
			,A.DerivativeEntityID
FROM CurDat.DerivativeDetail A 
LEFT JOIN CurDat.DerivativeDetail B 
ON A.DerivativeEntityid = B.DerivativeEntityid
and B.EffectivefromTimekey <= @Timekey and B.EffectiveTotimekey >= @Timekey
where A.DPD > 0 and A.EffectivetoTimekey = @Timekey-1 and B.DerivativeEntityid is NULL

END


GO