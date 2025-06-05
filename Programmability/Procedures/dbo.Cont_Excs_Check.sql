SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE proc [dbo].[Cont_Excs_Check]
as

	select acbd.CustomerACID,acbd.FacilityType,ProductCode,SchemeType,CurrentLimit,DrawingPower , Balance
	FROM DIMBRANCH DB
	INNER JOIN DBO.AdvAcBasicDetail ACBD  ON (ACBD.EffectiveFromTimeKey<=26203 AND ACBD.EffectiveToTimeKey>=26203)
											AND DB.EffectiveFromTimeKey<=26203 AND DB.EffectiveToTimeKey>=26203
											AND DB.BranchCode=ACBD.BranchCode
	INNER JOIN DBO.ADVACBALANCEDETAIL AB ON (AB.EffectiveFromTimeKey<=26203 AND AB.EffectiveToTimeKey>=26203)
											AND  AB.AccountEntityId=ACBD.AccountEntityId
	INNER   JOIN DBO.AdvFacCCDetail CC ON (CC.EffectiveFromTimeKey<=26203 AND CC.EffectiveToTimeKey>=26203)
											AND  CC.AccountEntityId=ACBD.AccountEntityId
	INNER JOIN DBO.AdvAcFinancialDetail AFD ON (AFD.EffectiveFromTimeKey<=26203 AND AFD.EffectiveToTimeKey>=26203)
											AND  AFD.AccountEntityId=ACBD.AccountEntityId
	inner join DimProduct p
		on p.EffectiveToTimeKey=49999 and p.ProductAlt_Key =acbd.ProductAlt_Key
	------WHERE  ISNULL(Balance,0)>ISNULL(DrawingPower,0) AND ISNULL(DrawingPower,0)>=0
	WHERE   ACBD.SourceAlt_Key =1 --- ONLY FOR FINALCE TO CHECK CC ACCOUNT CONT EXCESS DATE

	and acbd.CustomerACID in(
 select a.CustomerAcID from Pro.ContExcsSinceDtAccountCalBKUP a
	inner join AdvAcBasicDetail b
		on b.EffectiveToTimeKey=49999
		and a.EffectiveToTimeKey =49999
		and a.AccountEntityId =b.AccountEntityId
	where SourceAlt_Key =1
except
 select a.CustomerAcID from Pro.ContExcsSinceDtAccountCal a
 inner join AdvAcBasicDetail b
		on b.EffectiveToTimeKey=49999
		and a.EffectiveToTimeKey =49999
		and a.AccountEntityId =b.AccountEntityId
		where SourceAlt_Key =1
		)

select AcBuRevisedSegmentCode,ProductSubGroup,Segment,d.ProvisionSecured,ProvisionUnSecured,FinalAssetClassAlt_Key from pro.ACCOUNTCAL a
	LEFT join DimAcBuSegment  SEG
		ON SEG.AcBuSegmentCode = A.ActSegmentCode
		AND (SEG.EffectiveFromTimeKey<=26203 AND SEG.EffectiveToTimeKey>=26203)
	inner join DimProduct  c
		on c.EffectiveToTimeKey =49999
		and c.ProductAlt_Key =a.ProductAlt_Key
	inner join DimProvision_Seg d
		on d.EffectiveToTimeKey=49999
		and d.ProvisionAlt_Key=a.ProvisionAlt_Key
	-- AcBuRevisedSegmentCode IN('Agri-Retail','WCF','Agri-Wholesale','MC','SME','CIB','SCF','FIG')
group by AcBuRevisedSegmentCode,ProductSubGroup,Segment,d.ProvisionSecured,ProvisionUnSecured,FinalAssetClassAlt_Key
order by AcBuRevisedSegmentCode,ProductSubGroup,Segment,d.ProvisionSecured,ProvisionUnSecured,FinalAssetClassAlt_Key










--select * from pro.CUSTOMERCAL where UCIF_ID in ('ENBD004832730','ENBD001646250')
	SELECT INVID, FlgUpg,DPD,  UcifId UCIF_ID,A.EffectiveFromTimeKey,c.IssuerName,InitialAssetAlt_Key,FinalAssetClassAlt_Key,DPD,InitialNPIDt,NPIDt,flgdeg
			--,flgdeg
			---UPDATE A	set a.FinalAssetClassAlt_Key =3, InitialAssetAlt_Key=3,NPIDt ='2019-09-30', InitialNPIDt='2019-09-30',flgdeg='N'
			--update a
			--	set a.FinalAssetClassAlt_Key =2, InitialAssetAlt_Key=2,NPIDt ='2021-09-19', InitialNPIDt='2021-09-19', flgdeg='D'
			--,a.DEGREASON ='Manual NPA'
			--update  a  set  InitialAssetAlt_Key=6,FinalAssetClassAlt_Key=6,InitialNPIDt='2020-02-11',NPIDt='2020-02-11',flgupg='N'
			--------UPDATE A SET UpgDate =NULL,FLGUPG ='N'
		--update a
		--	set InitialAssetAlt_Key =1, InitialNPIDt =null, FLGDEG ='Y'
		FROM InvestmentFinancialDetail A 
				INNER JOIN InvestmentBasicDetail B
					ON A.InvEntityId =B.InvEntityId
					--AND A.EffectiveFromTimeKey>=26218--<=26223 AND A.EffectiveToTimeKey >=26223
					AND A.EffectiveFromTimeKey<=26223 AND A.EffectiveToTimeKey >=26223
					AND B.EffectiveFromTimeKey <=26223 AND B.EffectiveToTimeKey >=26223
				INNER JOIN InvestmentIssuerDetail C
					ON C.IssuerEntityId=B.IssuerEntityId
					AND C.EffectiveFromTimeKey <=26223 AND C.EffectiveToTimeKey >=26223
			WHERE ---ISNULL(FinalAssetClassAlt_Key,1)<>1 --AND INFI 
			 --dpd=0 and npidt is not null and
			 ----UcifId ='ENBD001643204'
			--	UCIFID IN('ENBD001646250','ENBD004832730')--,'ENBD001646250')

			  UcifId in('ENBD001643204','ENBD002980785','ENBD008827709','ENBD003034380','ENBD004832730','ENBD001646250')
			  --ORDER BY 1,2
			   








			   --SELECT * FrOM PRO.AclRunningProcessStatus ORDER BY ID

--UPDATE PRO.AclRunningProcessStatus SET Completed ='Y' WHERE ID>=23

UPDATE Automate_Advances SET EXT_FLG ='U' WHERE EXT_FLG ='Y'
UPDATE Automate_Advances SET EXT_FLG ='Y' WHERE Timekey =26205

EXEC PRO.InsertDataforAssetClassficationENBD_RESTR 26205,NULL,'N'
EXEC PRO.MAINPROECESSFORASSETCLASSFICATION_RESTR
----EXEC RestructureOutput

select distinct FinalAssetClassAlt_Key from pro.ACCOUNTCAL where FinalAssetClassAlt_Key is null
SELECT  AppliedProvPer,AppliedNormalProvPer,FinalProvPer,ProvReleasePer,RestrProvPer,PreRestructureNPA_Prov, 
CurrentNPA_Date,RestructureDt,* 
FROM RestrOutput WHERE CreatedDate ='2021-09-29' and Current_AssetClass is null
----AND (TypeOfRestructure LIKE '%MSME%' ) or
--and TypeOfRestructure LIKE '%COVID%'  
--AND Current_AssetClass='STD'
--and Pre_Restr_AssetClass ='STD'
--and RestrProvPer =0

AND PreRestructureNPA_Date IS not NULL
AND CurrentNPA_Date =RestructureDt

SELECT  AppliedProvPer,AppliedNormalProvPer,FinalProvPer,ProvReleasePer,RestrProvPer,  CurrentNPA_Date,RestructureDt,* FROM RestrOutput WHERE CreatedDate ='2021-09-22' 
--AND (TypeOfRestructure LIKE '%PRUDEN%' )--OR TypeOfRestructure LIKE '%IRAC%'  OR TypeOfRestructure LIKE '%OTHER%' )
--AND Current_AssetClass<>'STD'
--AND AppliedProvPer <>(AppliedNormalProvPer +FinalProvPer)
AND DPD_Breach_Date IS  NULL
AND (TypeOfRestructure LIKE '%PRUDEN%' OR TypeOfRestructure LIKE '%IRCA%'  OR TypeOfRestructure LIKE '%OTHER%')
			AND ( 
					(FacilityType NOT IN('CC','OD') AND  ISNULL(DPD_MaxFin,0)>0 )
				  OR( 
						(FacilityType IN('CC','OD') 
							AND (ISNULL(DPD_MaxFin,0)>=30 OR ISNULL(DPD_MaxNonFin,0)>=90)
						) 
					)
			)


SELECT SP_ExpiryExtendedDate,SP_ExpiryDate, CurrentNPA_Date,RestructureDt,* FROM RestrOutput WHERE CreatedDate ='2021-09-24' 
AND BALANCE<0


AND ZeroDPD_Date IS NOT NULL
AND SP_ExpiryExtendedDate IS NULL
AND DATEADD(YY,1,ZeroDPD_Date )>SP_ExpiryDate


SELECT  CurrentNPA_Date,RestructureDt,* FROM RestrOutput WHERE CreatedDate ='2021-09-22' 
--AND (TypeOfRestructure LIKE '%PRUDEN%' OR TypeOfRestructure LIKE '%IRAC%'  OR TypeOfRestructure LIKE '%OTHER%' )
AND (TypeOfRestructure LIKE '%covid%' OR TypeOfRestructure LIKE '%msme%')

AND Current_AssetClass<>'STD'
AND PreRestructureNPA_Date IS  NULL
--AND isnull(CurrentNPA_Date,'1900-01-01') <>isnull(PreRestructureNPA_Date,'1900-01-01')
AND isnull(CurrentNPA_Date,'1900-01-01') <>isnull(RestructureDt,'1900-01-01')

AND CurrentNPA_Date <RestructureDt




select * from RestrOutput where CreatedDate='2021-09-24' and
CustomerAcID in('809002735893','809002085981','609000728998','609000720057')

select * from RestrOutput where CreatedDate='2021-09-24' and
CustomerAcID in('809002013083','0007477350014732596','0005369077356537425','0007474500007207120')




-------UPDATE RESTR DBD BREACH DATE


select AddlProvPer,ProvReleasePer,FinalProvPer,  * from pro.AdvAcRestructureCal  where AccountEntityId in(1111759,4629051,5665407,1985842)


select * from pro.ACCOUNTCAL where CustomerAcID in (

'Z011QHG_01316401'
,'Z011L7G_01316401'
,'0007477800001364092'
,'0007476300005905975')













select  a.CustomerAcID, d.AcBuRevisedSegmentCode,c.ProductName,c.ProductCode, c.ProductSubGroup, F.CurrentValue CustomerSecurity
		,a.ApprRV,a.UsedRV,NetBalance,SecuredAmt, UnSecuredAmt,b.ProvisionSecured,b.ProvisionUnSecured
				,b.RBIProvisionSecured,b.RBIProvisionUnSecured	
		,TotalProvision *100/isnull(nullif( NetBalance,0),1)
		,AssetClass
--select a.*
from pro.ACCOUNTCAL a
	inner join DimProvision_Seg b
		on a.ProvisionAlt_Key =b.ProvisionAlt_Key
		and b.EffectiveToTimeKey=49999
	and CustomerAcID in('409000376144','609000747160')

	inner join DimProduct c
		on a.ProductAlt_Key=c.ProductAlt_Key
		and c.EffectiveToTimeKey=49999
	inner join DimAcBuSegment d
		on a.ActSegmentCode=d.AcBuSegmentCode
		and d.EffectiveToTimeKey=49999
	left join AdvSecurityDetail E	
		on e.CustomerEntityId =A.CustomerEntityID
		AND E.EffectiveToTimeKey=49999
	left join AdvSecurityValueDetail F	
		on e.SecurityEntityID =F.SecurityEntityID
		AND F.EffectiveToTimeKey=49999

where CustomerAcID in('409000376144','609000747160')
--where CustomerAcID in('809000416273','809001100487')






----select distinct a.*, Balance,DPD_Max DPD_on_28_Sep,(isnull(DPD_Max,0)+2) DPD_on_30_Sep,ReferencePeriod
----		,case when (isnull(DPD_Max,0)+2)>=ReferencePeriod then 'Y' ELSE 'N' END NPA_AS_ON_30_SEP
----from Manual_Upgrade a	
----	inner join pro.ACCOUNTCAL b
----		on a.[Account No]=b.CustomerAcID
----	inner join AdvAcBasicDetail c
----		on c.EffectiveToTimeKey =49999
----		and c.AccountEntityId =b.AccountEntityId
----	where VALID_UPTO='2099-12-31'






	select 
		A.CustomerACID,P.ProductCode,P.ProductName,P.ProductSubGroup
		,B.AcBuSegmentCode,B.AcBuRevisedSegmentCode
		,C.SourceShortNameEnum SourceName
		,aa.SecuredStatus Source_SecuredStatus
		,case when a.FlgSecured ='U' THEN 'UNSECURED' ELSE 'SECURED' END Final_Mapping
--select count(1)
------select distinct segmentcode
	from ENBD_TEMPDB.DBO.TempAdvAcBasicDetail a
	INNER JOIN ENBD_MISDB.PRO.ACCOUNTCAL AC
		ON AC.ACCOUNTENTITYID=A.ACCOUNTENTITYID
		AND ac.FinalAssetClassAlt_Key >1
	left join ENBD_STGDB.dbo.ACCOUNT_ALL_SOURCE_SYSTEM aa
		on aa.CustomerAcID=a.CustomerACID
	left JOIN ENBD_MISDB.dbo.DimAcBuSegment B
		ON (b.EffectiveFromTimeKey<=26205 and b.EffectiveToTimeKey>=26205)
		AND AC.ActSegmentCode=B.AcBuSegmentCode
	INNER JOIN ENBD_MISDB.dbo.DIMSOURCEDB C
		ON (C.EffectiveFromTimeKey<=26205 and C.EffectiveToTimeKey>=26205)
		AND C.SourceAlt_Key=A.SourceAlt_Key
	inner join ENBD_MISDB.dbo.dimproduct p
		on (C.EffectiveFromTimeKey<=26205 and C.EffectiveToTimeKey>=26205)
		AND a.productalt_key=p.productalt_key

WHERE A.SourceAlt_Key =1
AND B.AcBuSegmentCode IS NULL





--SELECT COUNT(1)
--FROM pro.AccountCal_Hist where EffectiveFromTimeKey=26206 
--	and (InitialAssetClassAlt_Key =1 AND FinalAssetClassAlt_Key >1)



	UPDATE A SET
		 A.InitialAssetClassAlt_Key =B.FinalAssetClassAlt_Key
		,A.FinalAssetClassAlt_Key =B.FinalAssetClassAlt_Key
		,A.InitialNpaDt =B.FinalNpaDt
		,A.FinalNpaDt =B.FinalNpaDt
	----SELECT COUNT(1)
	FROM PRO.ACCOUNTCAL A
	INNER JOIN pro.AccountCal_Hist B
		ON A.AccountEntityID =B.AccountEntityID
		AND B.EffectiveFromTimeKey=26206 
		and (B.InitialAssetClassAlt_Key =1 AND B.FinalAssetClassAlt_Key >1)
	WHERE A.InitialAssetClassAlt_Key =1



	UPDATE A SET
		A.SrcAssetClassAlt_Key =B.FinalAssetClassAlt_Key
		,A.SysAssetClassAlt_Key =B.FinalAssetClassAlt_Key
		,A.SrcNPA_Dt =B.FinalNpaDt
		,A.SysNPA_Dt =B.FinalNpaDt
	----SELECT COUNT(1)
	FROM PRO.CUSTOMERCAL A
	INNER JOIN (	SELECT DISTINCT CustomerEntityID,  
							MAX(FinalAssetClassAlt_Key) FinalAssetClassAlt_Key
							,MIN(FinalNpaDt) FinalNpaDt
						FROM pro.AccountCal_Hist B
						WHERE B.EffectiveFromTimeKey=26206 
						and (B.InitialAssetClassAlt_Key =1 AND B.FinalAssetClassAlt_Key >1)
						GROUP BY CustomerEntityID
				) B
		ON A.CustomerEntityID =B.CustomerEntityID
	WHERE A.SysAssetClassAlt_Key=1





		



		----select AccountEntityId from pro.ContExcsSinceDtAccountCal where EffectiveToTimeKey=49999
----EXCEPT
----select AccountEntityId from pro.ContExcsSinceDtAccountCalBKUP where EffectiveToTimeKey=49999
----EXCEPT
----select AccountEntityId from pro.ContExcsSinceDtAccountCal where EffectiveToTimeKey=49999

select D2K.CustomerAcID CustomerAcID_D2K,D2K.ContExcsSinceDt ContExcsSinceDt_D2K 
	,D2K.DrawingPower DrawingPower_D2K,D2K.SanctionAmt SanctionAmt_D2K,D2K.Balance Balance_D2K
	,ENBD.CustomerAcID CustomerAcID_ENBD,ENBD.ContExcsSinceDt ContExcsSinceDt_ENBD 
	,ENBD.DrawingPower DrawingPower_ENBD,ENBD.SanctionAmt SanctionAmt_ENBD,ENBD.Balance Balance_ENBD
from pro.ContExcsSinceDtAccountCalBKUP D2K
FULL JOIN pro.ContExcsSinceDtAccountCal ENBD
	ON D2K.CustomerAcID =ENBD.CustomerAcID
	AND ENBD.EffectiveToTimeKey =49999
	WHERE D2K.EffectiveToTimeKey=49999
	
	AND ( ISNULL(ENBD.CustomerAcID,'')<>ISNULL(D2K.CustomerAcID,'') 
			OR  ISNULL(ENBD.ContExcsSinceDt,'1900-01-01')<>ISNULL(D2K.ContExcsSinceDt,'1900-01-01') 
			 --OR  ISNULL(ENBD.DrawingPower,0)<>ISNULL(D2K.DrawingPower,0) 
			 --OR  ISNULL(ENBD.SanctionAmt,0)<>ISNULL(D2K.SanctionAmt,0) 
			 --OR  ISNULL(ENBD.Balance,0)<>ISNULL(D2K.Balance,0) 
		)



select b.CustomerAcID,b.InitialAssetClassAlt_Key,b.InitialNpaDt,b.FinalAssetClassAlt_Key,b.FinalNpaDt,b.DegReason 
from VISIONPLUS_ACL_ISSUE a
	INNER JOIN pro.AccountCal_Hist b
		on a.AccountEntityId=b.AccountEntityId
	where b.InitialAssetClassAlt_Key=1 and FinalAssetClassAlt_Key>1
order by 5





select a.*,DPD, 
	 cast(dd.Date as date ) ChargeOff_Y_PreDate
from NPA_Data_30092021 a
inner join (select MAX(effectivefromtimekey)effectivefromtimekey, refsystemacid 
from AdvFacCreditCardDetail
		group by refsystemacid)b
		on a.customeracid=b.RefSystemAcId
inner join AdvFacCreditCardDetail c
		on b.RefSystemAcId=c.RefSystemAcId
		and c.EffectiveFromTimeKey=b.effectivefromtimekey
left join SysDayMatrix  dd
	on dd.TimeKey =b.effectivefromtimekey




	--update InvestmentFinancialDetail set  INITIALNPIDT='2019-09-30',NPIDt='2019-09-30' where RefInvID='158091' and FinalAssetClassAlt_Key>1 and EffectiveFromTimeKey>=26218
--update InvestmentFinancialDetail set  INITIALNPIDT='2020-02-11',NPIDt='2020-02-11' where RefInvID='268652' and FinalAssetClassAlt_Key>1 and EffectiveFromTimeKey>=26218
--update InvestmentFinancialDetail set  INITIALNPIDT='2020-02-11',NPIDt='2020-02-11' where RefInvID='268640' and FinalAssetClassAlt_Key>1 and EffectiveFromTimeKey>=26218
--update InvestmentFinancialDetail set  INITIALNPIDT='2020-02-11',NPIDt='2020-02-11' where RefInvID='268651' and FinalAssetClassAlt_Key>1 and EffectiveFromTimeKey>=26218
--update InvestmentFinancialDetail set  INITIALNPIDT='2020-03-31',NPIDt='2020-03-31' where RefInvID='268642' and FinalAssetClassAlt_Key>1 and EffectiveFromTimeKey>=26218
--update InvestmentFinancialDetail set  INITIALNPIDT='2020-02-11',NPIDt='2020-02-11' where RefInvID='268639' and FinalAssetClassAlt_Key>1 and EffectiveFromTimeKey>=26218



select * from ReverseFeedData where 
DateofData='2021-07-27' AND
AccountID IN(
'0005239504505517485'
,'0005243736650445146'
,'0005243736760030515'
,'0005256118801651688'
,'0005369077255463574'
,'0005369077256493950'
,'0005369077351359999'
,'0007477250004312930'
,'0007477250013671037'
,'0007477350012328330'
,'0007477770001161998'
,'0007477770001544235'
,'0007477800001295676'
,'0007477800001751512'
,'0007478650000601385'
,'0007478800002456623'
,'0007478950006745511')
GO