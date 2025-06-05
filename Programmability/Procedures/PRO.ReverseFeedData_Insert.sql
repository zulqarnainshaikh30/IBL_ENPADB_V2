SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO









/*==============================================
AUTHER : Triloki Khanna
CREATE DATE : 27-12-2019
MODIFY DATE : 27-12-2019
DESCRIPTION : INSERT DATA FOR ReverseFeedData ID
EXEC PRO.ReverseFeedData_Insert




================================================*/



CREATE PROCEDURE [PRO].[ReverseFeedData_Insert]
AS
BEGIN




DECLARE @vEffectivefrom Int SET @vEffectiveFrom=(SELECT TimeKey FROM [dbo].Automate_Advances WHERE EXT_FLG='Y')
DECLARE @TimeKey Int SET @TimeKey=(SELECT TimeKey FROM [dbo].Automate_Advances WHERE EXT_FLG='Y')
DECLARE @DATE AS DATE =(SELECT Date FROM [dbo].Automate_Advances WHERE EXT_FLG='Y')
Declare @vEffectiveto INT Set @vEffectiveto= (select Timekey-1 FROM [dbo].Automate_Advances WHERE EXT_FLG='Y')
--DELETE FROM ReverseFeedData
-- if EXISTS ( select 1 from ReverseFeedData where [EffectiveFromTimeKey]= @Timekey)
-- begin
-- print 'NO NEDD TO INSERT DATA'
-- end
--else
--begin



DELETE FROM ReverseFeedData WHERE EffectiveFromTimeKey=@TIMEKEY and EffectiveToTimeKey=@TIMEKEY




IF OBJECT_ID ('TEMPDB..#ReverseFeedData') IS NOT NULL
DROP TABLE #ReverseFeedData




CREATE TABLE #ReverseFeedData (
[DateofData] [date] NULL,
[BranchCode] [varchar](20) NULL,
[CustomerID] [varchar](30) NULL,
[AccountID] [varchar](30) NULL,
[AssetClass] [varchar](20) NULL,
[AssetSubClass] [varchar](20) NULL,
[NPADate] [date] NULL,
[NPAReason] [varchar](max) NULL,
[LoanSeries] [smallint] NULL,
[LoanRefNo] [smallint] NULL,
[FundID] [varchar](40) NULL,
[NPAStatus] [varchar](10) NULL,
[LoanRating] [varchar](10) NULL,
[OrgNPAStatus] [varchar](10) NULL,
[OrgLoanRating] [varchar](10) NULL,
[SourceAlt_Key] [int] NULL,
[SourceSystemName] [varchar](30) NULL,
[EffectiveFromTimeKey] [int] NULL,
[EffectiveToTimeKey] [int] NULL
)




INSERT INTO #ReverseFeedData
(
DateofData
,BranchCode
,CustomerID
,AccountID
,AssetClass
,AssetSubClass
,NPADate
,NPAReason
,LoanSeries
,LoanRefNo
,FundID
,NPAStatus
,LoanRating
,OrgNPAStatus
,OrgLoanRating
,SourceAlt_Key
,SourceSystemName
,EffectiveFromTimeKey
,EffectiveToTimeKey
)




SELECT
@DATE AS DateofData
,A.BRANCHCODE AS BranchCode
,B.RefCustomerID AS CustomerID
,A.CustomerAcID AS AccountID
,CASE WHEN A.FinalAssetClassAlt_Key =1 THEN 'STD'
WHEN A.FinalAssetClassAlt_Key =2 THEN 'NPA'
WHEN A.FinalAssetClassAlt_Key =3 THEN 'NPA'
WHEN A.FinalAssetClassAlt_Key =4 THEN 'NPA'
WHEN A.FinalAssetClassAlt_Key =5 THEN 'NPA'
WHEN A.FinalAssetClassAlt_Key =6 THEN 'NPA' END AS AssetClass
,CASE WHEN A.FinalAssetClassAlt_Key =1 THEN 'STD'
WHEN A.FinalAssetClassAlt_Key =2 THEN 'SUB'
WHEN A.FinalAssetClassAlt_Key =3 THEN 'DB1'
WHEN A.FinalAssetClassAlt_Key =4 THEN 'DB2'
WHEN A.FinalAssetClassAlt_Key =5 THEN 'DB3'
WHEN A.FinalAssetClassAlt_Key =6 THEN 'LOS' END AS AssetSubClass
,A.FinalNpaDt AS NPADate
,A.NPA_Reason AS NPAReason
,B.LoanSeries AS LoanSeries
,B.LoanRefNo AS LoanRefNo
,B.SecuritizationCode AS FundID
,CASE WHEN D.SourceName='BR.NET' THEN
CASE WHEN FINALASSETCLASSALT_KEY='1' AND DPD_Max BETWEEN 1 AND 30 THEN 'STD01'--'SMA1'
WHEN FINALASSETCLASSALT_KEY='1' AND DPD_Max BETWEEN 31 AND 60 THEN 'STD02'--'SMA2'
WHEN FINALASSETCLASSALT_KEY='1' AND DPD_Max BETWEEN 61 AND 90 THEN 'STD03'-- 'SMA3'
WHEN FINALASSETCLASSALT_KEY='1' THEN '1'--STD
WHEN FINALASSETCLASSALT_KEY='2' THEN 'SSA1'--'SSD'
WHEN FINALASSETCLASSALT_KEY='3' THEN 'DBF1'
WHEN FINALASSETCLASSALT_KEY='4' THEN 'DBF2'
WHEN FINALASSETCLASSALT_KEY='5' THEN 'DBF3'
WHEN FINALASSETCLASSALT_KEY='6' THEN 'LOA' END END AS NPAStatus



,CASE WHEN D.SourceName='PROFILE' THEN
--CASE WHEN FINALASSETCLASSALT_KEY='1' AND DPD_Max BETWEEN 1 AND 30 THEN '1'
--WHEN FINALASSETCLASSALT_KEY='1' AND DPD_Max BETWEEN 31 AND 60 THEN '2'
--WHEN FINALASSETCLASSALT_KEY='1' AND DPD_Max BETWEEN 61 AND 90 THEN '3'



CASE WHEN FINALASSETCLASSALT_KEY='1' AND DPD_Max BETWEEN 1 AND 15 THEN '0'
WHEN FINALASSETCLASSALT_KEY='1' AND DPD_Max BETWEEN 16 AND 30 THEN '1'
WHEN FINALASSETCLASSALT_KEY='1' AND DPD_Max BETWEEN 31 AND 60 THEN '2'
WHEN FINALASSETCLASSALT_KEY='1' AND DPD_Max BETWEEN 61 AND 90 THEN '3'
WHEN FINALASSETCLASSALT_KEY='1' THEN '0'
WHEN FINALASSETCLASSALT_KEY='2' THEN '4'
WHEN FINALASSETCLASSALT_KEY='3' THEN '5'
WHEN FINALASSETCLASSALT_KEY='4' THEN '6'
WHEN FINALASSETCLASSALT_KEY='5' THEN '7'
WHEN FINALASSETCLASSALT_KEY='6' THEN '8' END END AS LoanRating



,CASE WHEN D.SourceName='BR.NET' THEN AccountStatus END AS OrgNPAStatus
,CASE WHEN D.SourceName='PROFILE' THEN AccountStatus END AS OrgLoanRating
,A.SourceAlt_Key AS SourceAlt_Key
,D.SourceName AS SourceSystemName
,A.EffectiveFromTimeKey
,A.EffectiveToTimeKey AS EffectiveToTimeKey

FROM PRO.ACCOUNTCAL A INNER JOIN CURDAT.AdvAcBasicDetail B ON A.AccountEntityID=B.AccountEntityID
AND A.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND A.EFFECTIVETOTIMEKEY>=@TIMEKEY
AND B.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND B.EFFECTIVETOTIMEKEY>=@TIMEKEY
Inner JOIN DIMASSETCLASS C ON C.ASSETCLASSALT_KEY=A.FINALASSETCLASSALT_KEY AND C.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND C.EFFECTIVETOTIMEKEY>=@TIMEKEY
Inner JOIN DimSourceDB D ON A.SourceAlt_Key=D.SourceAlt_Key AND D.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND D.EFFECTIVETOTIMEKEY>=@TIMEKEY



--WHERE D.SourceShortNameEnum='PROFILE' AND ( (A.AccountStatus IN ('0','1','2','3') AND A.FinalAssetClassAlt_Key>1 AND A.BALANCE>=0)
--or (A.AccountStatus not IN ('0','1','2','3') AND A.FinalAssetClassAlt_Key=1 AND A.BALANCE>=0 )
--or PrvAssetClassAlt_Key<>FinalAssetClassAlt_Key )
--AND A.BALANCE>=0




WHERE D.SourceShortNameEnum='PROFILE' AND PrvAssetClassAlt_Key<>FinalAssetClassAlt_Key AND A.BALANCE>=0



UNION ALL
SELECT
@DATE AS DateofData
--,A.BRANCHCODE AS BranchCode --Change logic as per bank mail dated 21/01/2020 Branch code should be 3 digits Triloki Khanna
--,RIGHT(A.BRANCHCODE,3) AS BRANCHCODE
,A.OriginalBranchcode AS BRANCHCODE
,B.RefCustomerID AS CustomerID
,A.CustomerAcID AS AccountID
,CASE WHEN A.FinalAssetClassAlt_Key =1 THEN 'STD'
WHEN A.FinalAssetClassAlt_Key =2 THEN 'NPA'
WHEN A.FinalAssetClassAlt_Key =3 THEN 'NPA'
WHEN A.FinalAssetClassAlt_Key =4 THEN 'NPA'
WHEN A.FinalAssetClassAlt_Key =5 THEN 'NPA'
WHEN A.FinalAssetClassAlt_Key =6 THEN 'NPA' END AS AssetClass
,CASE WHEN A.FinalAssetClassAlt_Key =1 THEN 'STD'
WHEN A.FinalAssetClassAlt_Key =2 THEN 'SUB'
WHEN A.FinalAssetClassAlt_Key =3 THEN 'DB1'
WHEN A.FinalAssetClassAlt_Key =4 THEN 'DB2'
WHEN A.FinalAssetClassAlt_Key =5 THEN 'DB3'
WHEN A.FinalAssetClassAlt_Key =6 THEN 'LOS' END AS AssetSubClass
,A.FinalNpaDt AS NPADate
,A.NPA_Reason AS NPAReason
,B.LoanSeries AS LoanSeries
,B.LoanRefNo AS LoanRefNo
,B.SecuritizationCode AS FundID
--,CASE WHEN D.SourceName='BR.NET' THEN
-- CASE WHEN FINALASSETCLASSALT_KEY='1' AND DPD_Max BETWEEN 1 AND 30 THEN 'SMA1'
-- WHEN FINALASSETCLASSALT_KEY='1' AND DPD_Max BETWEEN 31 AND 60 THEN 'SMA2'
-- WHEN FINALASSETCLASSALT_KEY='1' AND DPD_Max BETWEEN 61 AND 90 THEN 'SMA3'
-- WHEN FINALASSETCLASSALT_KEY='1' THEN 'STD'
-- WHEN FINALASSETCLASSALT_KEY='2' THEN 'SSD'
-- WHEN FINALASSETCLASSALT_KEY='3' THEN 'DBF1'
-- WHEN FINALASSETCLASSALT_KEY='4' THEN 'DBF2'
-- WHEN FINALASSETCLASSALT_KEY='5' THEN 'DBF3'
-- WHEN FINALASSETCLASSALT_KEY='6' THEN 'LOA' END END AS NPAStatus



--,CASE WHEN D.SourceName='PROFILE' THEN
-- CASE WHEN FINALASSETCLASSALT_KEY='1' AND DPD_Max BETWEEN 1 AND 30 THEN '1'
-- WHEN FINALASSETCLASSALT_KEY='1' AND DPD_Max BETWEEN 31 AND 60 THEN '2'
-- WHEN FINALASSETCLASSALT_KEY='1' AND DPD_Max BETWEEN 61 AND 90 THEN '3'
-- WHEN FINALASSETCLASSALT_KEY='1' THEN '0'
-- WHEN FINALASSETCLASSALT_KEY='2' THEN '4'
-- WHEN FINALASSETCLASSALT_KEY='3' THEN '5'
-- WHEN FINALASSETCLASSALT_KEY='4' THEN '6'
-- WHEN FINALASSETCLASSALT_KEY='5' THEN '7'
-- WHEN FINALASSETCLASSALT_KEY='6' THEN '8' END END AS LoanRating
,CASE WHEN D.SourceName='BR.NET' THEN
CASE WHEN FINALASSETCLASSALT_KEY='1' AND DPD_Max BETWEEN 1 AND 30 THEN 'STD01'--'SMA1'
WHEN FINALASSETCLASSALT_KEY='1' AND DPD_Max BETWEEN 31 AND 60 THEN 'STD02'--'SMA2'
WHEN FINALASSETCLASSALT_KEY='1' AND DPD_Max BETWEEN 61 AND 90 THEN 'STD03'-- 'SMA3'
WHEN FINALASSETCLASSALT_KEY='1' THEN '1'--STD
WHEN FINALASSETCLASSALT_KEY='2' THEN 'SSA1'--'SSD'
WHEN FINALASSETCLASSALT_KEY='3' THEN 'DBF1'
WHEN FINALASSETCLASSALT_KEY='4' THEN 'DBF2'
WHEN FINALASSETCLASSALT_KEY='5' THEN 'DBF3'
WHEN FINALASSETCLASSALT_KEY='6' THEN 'LOA' END END AS NPAStatus



,CASE WHEN D.SourceName='PROFILE' THEN
--CASE WHEN FINALASSETCLASSALT_KEY='1' AND DPD_Max BETWEEN 1 AND 30 THEN '1'
--WHEN FINALASSETCLASSALT_KEY='1' AND DPD_Max BETWEEN 31 AND 60 THEN '2'
--WHEN FINALASSETCLASSALT_KEY='1' AND DPD_Max BETWEEN 61 AND 90 THEN '3'
CASE WHEN FINALASSETCLASSALT_KEY='1' AND DPD_Max BETWEEN 1 AND 15 THEN '0'
WHEN FINALASSETCLASSALT_KEY='1' AND DPD_Max BETWEEN 16 AND 30 THEN '1'
WHEN FINALASSETCLASSALT_KEY='1' AND DPD_Max BETWEEN 31 AND 60 THEN '2'
WHEN FINALASSETCLASSALT_KEY='1' AND DPD_Max BETWEEN 61 AND 90 THEN '3'
WHEN FINALASSETCLASSALT_KEY='1' THEN '0'
WHEN FINALASSETCLASSALT_KEY='2' THEN '4'
WHEN FINALASSETCLASSALT_KEY='3' THEN '5'
WHEN FINALASSETCLASSALT_KEY='4' THEN '6'
WHEN FINALASSETCLASSALT_KEY='5' THEN '7'
WHEN FINALASSETCLASSALT_KEY='6' THEN '8' END END AS LoanRating



,CASE WHEN D.SourceName='BR.NET' THEN AccountStatus END AS OrgNPAStatus
,CASE WHEN D.SourceName='PROFILE' THEN AccountStatus END AS OrgLoanRating
,A.SourceAlt_Key AS SourceAlt_Key
,D.SourceName AS SourceSystemName
,A.EffectiveFromTimeKey
,A.EffectiveToTimeKey AS EffectiveToTimeKey

FROM PRO.ACCOUNTCAL A INNER JOIN CURDAT.AdvAcBasicDetail B ON A.AccountEntityID=B.AccountEntityID
AND A.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND A.EFFECTIVETOTIMEKEY>=@TIMEKEY
AND B.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND B.EFFECTIVETOTIMEKEY>=@TIMEKEY
Inner JOIN DIMASSETCLASS C ON C.ASSETCLASSALT_KEY=A.FINALASSETCLASSALT_KEY AND C.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND C.EFFECTIVETOTIMEKEY>=@TIMEKEY
Inner JOIN DimSourceDB D ON A.SourceAlt_Key=D.SourceAlt_Key AND D.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND D.EFFECTIVETOTIMEKEY>=@TIMEKEY



--WHERE D.SourceShortNameEnum='BR.NET' AND ( (A.AccountStatus IN ('STD') AND A.FinalAssetClassAlt_Key>1 AND A.BALANCE>=0)
--or (A.AccountStatus not IN ('STD') AND A.FinalAssetClassAlt_Key=1 AND A.BALANCE>=0 )
--or PrvAssetClassAlt_Key<>FinalAssetClassAlt_Key )



WHERE D.SourceShortNameEnum='BR.NET' AND A.BALANCE>=0 and PrvAssetClassAlt_Key<>FinalAssetClassAlt_Key







INSERT INTO ReverseFeedData



(
DateofData
,BranchCode
,CustomerID
,AccountID
,AssetClass
,AssetSubClass
,NPADate
,NPAReason
,LoanSeries
,LoanRefNo
,FundID
,NPAStatus
,LoanRating
,OrgNPAStatus
,OrgLoanRating
,SourceAlt_Key
,SourceSystemName
,EffectiveFromTimeKey
,EffectiveToTimeKey
)
SELECT




A.DateofData
,A.BranchCode
,A.CustomerID
,A.AccountID
,A.AssetClass
,A.AssetSubClass
,A.NPADate
,A.NPAReason
,A.LoanSeries
,A.LoanRefNo
,A.FundID
,A.NPAStatus
,A.LoanRating
,A.OrgNPAStatus
,A.OrgLoanRating
,A.SourceAlt_Key
,A.SourceSystemName
,A.EffectiveFromTimeKey
,A.EffectiveToTimeKey
FROM #ReverseFeedData A



-- LEFT JOIN ReverseFeedData B ON A.AccountID=B.AccountID
-- AND B.EFFECTIVETOTimekey=49999



--WHERE
-- (
-- CASE WHEN B.AccountID IS NULL THEN 1 WHEN B.AccountID IS NOT NULL AND A.AssetSubClass<>B.AssetSubClass
-- OR ISNULL(A.NPADate,'1900-01-01') <> ISNULL(B.NPADate,'1900-01-01')

-- THEN 1 END )=1




-- UPDATE AA
--SET
-- EffectiveToTimeKey = @vEffectiveto

--FROM ReverseFeedData AA
--LEFT JOIN #ReverseFeedData B ON AA.AccountID=B.AccountID AND B.EffectiveToTimeKey =49999
--WHERE AA.EffectiveToTimeKey = 49999
--and B.AccountID is null




-- UPDATE AA
--SET
-- EffectiveToTimeKey = @vEffectiveto

--FROM ReverseFeedData AA
--WHERE AA.EffectiveToTimeKey = 49999 AND AA.EffectiveFROMTimeKey<@TIMEKEY
--AND EXISTS (SELECT 1 FROM #ReverseFeedData BB



-- WHERE AA.AccountID=BB.AccountID
-- AND BB.EffectiveToTimeKey =49999
-- AND AA.AssetSubClass<>BB.AssetSubClass
-- OR ISNULL(AA.NPADate,'1900-01-01') <> ISNULL(BB.NPADate,'1900-01-01')
-- )

--END



--delete A from
--(select ROW_NUMBER() over (partition by
--AccountEntityId
--order by AccountEntityId ) duplicate , AccountEntityId
-- from CURDAT.AdvAcBalanceDetail WHERE EffectiveToTimeKey=49999 ) A
--where duplicate > 1



--delete A from
--(select ROW_NUMBER() over (partition by
--AccountEntityId
--order by AccountEntityId ) duplicate , AccountEntityId
-- from CURDAT.AdvAcFinancialDetail WHERE EffectiveToTimeKey=49999 ) A
--where duplicate > 1



--delete A from
--(select ROW_NUMBER() over (partition by
--AccountEntityId
--order by AccountEntityId ) duplicate , AccountEntityId
-- from CURDAT.AdvAcCal WHERE EffectiveToTimeKey=49999 ) A
--where duplicate > 1



--delete A from
--(select ROW_NUMBER() over (partition by
--CustomerEntityId,BranchCode
--order by CustomerEntityId,BranchCode ) duplicate , CustomerEntityId,BranchCode
-- from CURDAT.AdvCustFinancialDetail WHERE EffectiveToTimeKey=49999 ) A
--where duplicate > 1



--delete A from
--(select ROW_NUMBER() over (partition by
--CustomerEntityId,BranchCode
--order by CustomerEntityId,BranchCode ) duplicate , CustomerEntityId,BranchCode
-- from CURDAT.AdvCustNonFinancialDetail WHERE EffectiveToTimeKey=49999 ) A
--where duplicate > 1




--update a set InttRate=b.Pref_InttRate
-- from CURDAT.AdvAcFinancialDetail a
--inner join CURDAT.AdvAcBasicDetail b
--on a.AccountEntityId=b.AccountEntityId
--where a.EffectiveToTimeKey=49999
--and b.EffectiveToTimeKey=49999




END
GO