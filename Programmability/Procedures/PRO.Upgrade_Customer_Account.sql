SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO





/*=========================================
 AUTHER : TRILOKI KHANNA
 CREATE DATE : 27-11-2019
 MODIFY DATE : 27-11-2019
 DESCRIPTION : FIRST UPGRADE TO CUSTOMER LEVEL  AFTER THAT ACCOUNT LEVEL
=============================================*/

CREATE  PROCEDURE   [PRO].[Upgrade_Customer_Account]--27303
@TIMEKEY INT
WITH RECOMPILE
AS
BEGIN
  SET NOCOUNT ON
   BEGIN TRY
 
 
/*=========================================
 AUTHOR : TRILOKI KHANNA
 CREATE DATE : 09-04-2021
 MODIFY DATE : 09-04-2021
 DESCRIPTION : Test Case Cover in This SP

RefCustomerID	TestCase
143	Reversefeed Upgradation
94	UPG-TL/DL - Ac Level: Eligible for Upgrade
96	UPG-Bills/ PC - Ac Level: Eligible for Upgradae
98	UPG-CC/OD: Eligible for Upgrade
95	UPG-TL/DL - Ac Level: Not Eligible for Upgrade
97	UPG-Bills/ PC - Ac Level: Not Eligible for Upgradae
99	UPG-CC/OD: Not Eligible for Upgrade
=============================================*/

/*check the customer when all account to cutomer dpdmax must be 0*/

DECLARE @PROCESSDATE DATE=(SELECT Date FROM SysDayMatrix WHERE TimeKey=@TIMEKEY)


UPDATE Pro.AccountCal SET FLGUPG='N'
UPDATE Pro.CustomerCal SET FLGUPG='N'


--exec [PRO].[RestructureProcess] @TIMEkEY,  'U'



	IF OBJECT_ID('TEMPDB..#Restructured_NCIF_Id') IS NOT NULL
	DROP TABLE #Restructured_NCIF_Id
	
  SELECT NPA.UcifEntityID
 	into #Restructured_NCIF_Id
	                FROM PRO.ACCOUNTCAL NPA
						INNER JOIN PRO.AdvAcRestructureCal RES
							ON RES.EffectiveFromTimeKey<=@TIMEKEY  AND RES.EffectiveToTimeKey>=@TIMEKEY
							AND NPA.EffectiveFromTimeKey<=@TIMEKEY  AND NPA.EffectiveToTimeKey>=@TIMEKEY
							AND RES.AccountEntityId=NPA.AccountEntityID --------  changed by satish as on date 22092022 as accountentityid was null
							AND NPA.FlgRestructure='Y'
						    INNER JOIN DimParameter PAR
							ON PAR.EffectiveFromTimeKey<=@TIMEKEY  AND PAR.EffectiveToTimeKey>=@TIMEKEY
							AND ParameterAlt_Key=RES.RestructureTypeAlt_Key
							AND DimParameterName='TypeofRestructuring'
                            AND ParameterShortNameEnum NOT IN('Natural Calamity')
							and (CASE WHEN ISNULL(NPA.FlgRestructure,'N')='Y' 
								THEN		
									( CASE  WHEN ISNULL(ParameterShortNameEnum,'') IN('Natural Calamity','Others_COMGT') AND ISNULL(NPA.DPD_Max,0)=0 --Natural Clamity/Change of Management
													THEN  'N' 
											WHEN ISNULL(ParameterShortNameEnum,'') IN( /*-------MSME Restructuring */
																						'MSME-Aug20-Extn-May21','MSME-Aug20','MSME-May21')
														 AND ISNULL(NPA.DPD_Max,0)=0 
														 AND ISNULL(RES.SP_ExpiryExtendedDate,RES.SP_ExpiryDate)<@PROCESSDATE
														
													THEN 'N'
											WHEN ISNULL(ParameterShortNameEnum,'') IN('DCCO') /*'DCCO'*/
																					--AND RES.ZeroDPD_Date IS NOT NULL	-- commented by satish as on date 19122022
																					AND ISNULL(NPA.DPD_Max,0)=0 
																					--AND DCCO_DATE IS NOT NULL /*COMMENTED BY ZAIN AS DCCO COLUMN IS NOT FOUND ON 20250408*/
																					AND TEN_PC_DATE IS NOT NULL
																					AND ISNULL(RES.SP_ExpiryExtendedDate,RES.SP_ExpiryDate)<@PROCESSDATE
													THEN 'N'
											when 	ISNULL(ParameterShortNameEnum,'') in /*Covid-19 OTR Personal Loan, Business Loand and Individual Business */
																						('PL-Aug20','Ind.Business-May21','SmallBusiness-May21','PL-May21','Ind.Business-Aug20-May21','SmallBusiness-Aug20-May21','PL-Aug20-May21')
														 AND ISNULL(NPA.DPD_Max,0)=0 and TEN_PC_DATE IS NOT NULL
														 AND ISNULL(RES.SP_ExpiryExtendedDate,RES.SP_ExpiryDate)<@PROCESSDATE
														 then 'N'

											WHEN  ISNULL(ParameterShortNameEnum,'') IN( /*Covid-19 Other than Personal Loan */
																						'Corporate-Aug20-Extn-May21','Corporate-Aug20'
																						/* Under Irac/Normal Restrucuture Under Irac */
																						,'Others','Others_Jun19')
														-- AND RES.ZeroDPD_Date IS NOT NULL   -- commented by satish as on date 19122022
														 AND ISNULL(NPA.DPD_Max,0)=0 and TEN_PC_DATE IS NOT NULL
														 AND ISNULL(RES.SP_ExpiryExtendedDate,RES.SP_ExpiryDate)<@PROCESSDATE
														 AND SecondRestrDate IS Not Null
														 AND  ((AggregateExposure  in('100 CR to Less than 500 CR') AND CreditRating1 in('AAA+','AAA','AAA-','AA+','AA','AA-','BBB+','BBB','BBB-'))
															          OR (AggregateExposure  in('Equal to or Greater than 500 CR') and  CreditRating1 in('AAA+','AAA','AAA-','AA+','AA','AA-','BBB+','BBB','BBB-') 
																				AND  CreditRating2 in('AAA+','AAA','AAA-','AA+','AA','AA-','BBB+','BBB','BBB-'))
																	 OR  (AggregateExposure  in('Less than 100 Cr') )
															  )
															  
													THEN 'N'
											
											ELSE 'Y'
										END) 	END)='Y'
          
  CREATE NONCLUSTERED INDEX idx_Restructured_NCIF_Id ON #Restructured_NCIF_Id(UcifEntityID)
	/*  ENDDDDDDDDDDDD*/

IF OBJECT_ID('TEMPDB..#TEMPTABLE') IS NOT NULL
      DROP TABLE #TEMPTABLE

SELECT A.UcifEntityID,TOTALCOUNT  INTO #TEMPTABLE FROM 
(
SELECT UcifEntityID,SUM(TOTALCOUNT)TOTALCOUNT 
FROM
(
			SELECT A.UcifEntityID,COUNT(1) TOTALCOUNT 
			FROM Pro.CustomerCal A 
			INNER JOIN Pro.AccountCal B 
			ON A.UCIF_ID=B.UCIF_ID 
			WHERE (A.FlgProcessing='N' ) AND A.UCIF_ID IS NOT NULL
			AND B.Asset_Norm NOT IN ('ALWYS_STD')  
			GROUP BY A.UcifEntityID
)X GROUP BY UcifEntityID
)
A INNER JOIN 
		(
				SELECT UcifEntityID,SUM(TOTALDPD_MAXCOUNT)TOTALDPD_MAXCOUNT FROM (
				SELECT A.UcifEntityID,COUNT(1) TOTALDPD_MAXCOUNT 
					FROM Pro.CustomerCal A INNER JOIN Pro.AccountCal B ON A.UCIF_ID=B.UCIF_ID
				WHERE ((B.DPD_INTSERVICE<=B.REFPERIODINTSERVICEUPG
				   and B.DPD_NOCREDIT <=B.REFPERIODNOCREDITUPG
				   and B.DPD_OVERDRAWN <=B.REFPERIODOVERDRAWNUPG
				   and B.DPD_OVERDUE<=B.REFPERIODOVERDUEUPG
				   OR B.Balance = 0)
				   and B.DPD_RENEWAL<=B.REFPERIODREVIEWUPG
				   and B.DPD_STOCKSTMT <=B.REFPERIODSTKSTATEMENTUPG) 
				   and B.InitialAssetClassAlt_Key not in(1)
					AND (A.FlgProcessing='N')
					AND B.Asset_Norm NOT IN ('ALWYS_NPA','ALWYS_STD')
					AND  ISNULL(A.MocStatusMark,'N')='N' 
					AND A.UCIF_ID IS NOT NULL
					AND ISNULL(B.UNSERVIEDINT,0)=0 
					AND  ISNULL(B.AccountStatus,'N')<>'Z'
				---AMAR  28032022 AS DISCUSSED WITH aSHISH SIR ON 24TH MAR'2022 -- ADDED FOR CHECK INTT OVERDUE AMOUNT FOR CCOD ACCOUNT FOR UPGRADE
				--AND ( (FacilityType IN('CC','OD') and isnull(IntOverdue,0)=0) OR (ISNULL(FacilityType,'') NOT IN('CC','OD')))
				GROUP BY A.UcifEntityID

		)Y GROUP BY UcifEntityID
) B ON A.UcifEntityID=B.UcifEntityID AND A.TOTALCOUNT=B.TOTALDPD_MAXCOUNT



	DELETE A
	FROM #TEMPTABLE A 
		INNER JOIN #Restructured_NCIF_Id B ON A.UcifEntityID=B.UcifEntityID
	

  /*------ UPGRADING CUSTOMER-----------*/
  
UPDATE A SET A.FlgUpg='U'
FROM Pro.CustomerCal A INNER JOIN #TEMPTABLE B ON A.UcifEntityID=B.UcifEntityID
 INNER JOIN DIMASSETCLASS C ON C.AssetClassAlt_Key=A.SYSASSETCLASSALT_KEY AND (C.EffectiveFromTimeKey<=@TIMEKEY AND C.EffectiveToTimeKey>=@TIMEKEY)
WHERE  (not(isnull(A.ASSET_NORM,'NORMAL')='ALWYS_NPA' ) AND  C.ASSETCLASSGROUP ='NPA' AND not(ISNULL(A.FLGDEG,'N')='Y')) AND (ISNULL(A.FlgProcessing,'N')='N')



UPDATE   Pro.CustomerCal SET SysNPA_Dt=NULL,
							 DbtDt=NULL,
							 LossDt=NULL,
							 ErosionDt=NULL,
							 FlgErosion='N',
							 SysAssetClassAlt_Key=1
							 ,FlgDeg='N'
WHERE FlgUpg='U'


/*--------MARKING UPGRADED ACCOUNT --------------*/

UPDATE B SET  B.UpgDate=@PROCESSDATE
             ,B.DegReason=NULL
			 ,B.FinalAssetClassAlt_Key=1
			 ,B.FlgDeg='N'
			 ,B.FinalNpaDt=null
             ,B.FlgUpg='U'
			 ,B.NPA_Reason=NULL
			 FROM Pro.CustomerCal A INNER JOIN Pro.AccountCal B ON A.RefCustomerID=B.RefCustomerID
WHERE  ISNULL(A.FlgUpg,'U')='U' AND (ISNULL(A.FlgProcessing,'N')='N')


UPDATE B SET  B.UpgDate=@PROCESSDATE
             ,B.DegReason=NULL
			 ,B.FinalAssetClassAlt_Key=1
			 ,B.FlgDeg='N'
			 ,B.FinalNpaDt=null
             ,B.FlgUpg='U'
		     ,B.NPA_Reason=NULL
			 FROM Pro.CustomerCal A INNER JOIN Pro.AccountCal B ON A.RefCustomerID=B.RefCustomerID
WHERE  ISNULL(A.FlgUpg,'U')='U' AND (ISNULL(A.FlgProcessing,'N')='N')

-------21022023 --- Sudesh --- Investment Upgrade Logic added---


UPDATE A SET  A.UpgDate=@PROCESSDATE
             ,A.DegReason=NULL
			 ,A.AssetClass_AltKey=1
			 ,A.FinalAssetClassAlt_Key=1
			 ,A.FlgDeg='N'
			 ,A.NPIDt=null
             ,A.FlgUpg='U'
			 FROM InvestmentFinancialDetail A
WHERE  ISNULL(A.FlgUpg,'U')='U' 
AND A.EffectiveFromTimeKey<=@timekey and A.EffectiveToTimeKey>=@timekey



-------21022023 --- Sudesh --- Derivative Upgrade Logic added---


UPDATE A SET  A.UpgDate=@PROCESSDATE
             ,A.DegReason=NULL
			 ,A.AssetClass_AltKey=1
			 ,A.FlgDeg='N'
			 ,A.NPIDt=null
             ,A.FlgUpg='U'
			 FROM  [CurDat].[DerivativeDetail] A
WHERE  ISNULL(A.FlgUpg,'U')='U' 
AND A.EffectiveFromTimeKey<=@timekey and A.EffectiveToTimeKey>=@timekey


/* 16-04-2021 AMAR  -- ADDED THIS CODE FOR  COMMING NEW ACCOUNT BECOMING NPA DUE TO 
	EXISTING NPA CUSTOMER  AND ALSO UPGRADEING */

UPDATE A
	 SET FLGUPG='N'
		,UpgDate=NULL
FROM Pro.AccountCal A WHERE InitialAssetClassAlt_Key =1 AND FinalAssetClassAlt_Key =1 AND FlgUpg='U'

UPDATE A set DegReason=NULL FROM Pro.CustomerCal A where SysAssetClassAlt_Key=1 and DegReason is not null

--SUDESH SIR CODE-----------------------------------------------------------------------------
  /* MERGING DATA FOR ALL SOURCES FOR FIND LOWEST ASSET CLASS AND MIN NPA DATE */

    IF OBJECT_ID('TEMPDB..#CTE_PERC') IS NOT NULL
    DROP TABLE #CTE_PERC

      SELECT * INTO
            #CTE_PERC
      FROM
            (           /* ADVANCE DATA */

                  SELECT UCIF_ID,MAX(ISNULL(SYSASSETCLASSALT_KEY,1)) SYSASSETCLASSALT_KEY ,MIN(SYSNPA_DT) SYSNPA_DT

                  ,'ADV' PercType

                  FROM Pro.CustomerCal A WHERE ( UCIF_ID IS NOT NULL and UCIF_ID<>'0' ) AND  ISNULL(SYSASSETCLASSALT_KEY,1)=1

                  GROUP BY  UCIF_ID

                  UNION

                  /* INVESTMENT DATA */

                  SELECT UcifId UCIF_ID,MAX(ISNULL(FinalAssetClassAlt_Key,1)) SYSASSETCLASSALT_KEY ,MIN(NPIDt) SYSNPA_DT

                  ,'INV' PercType

                  FROM InvestmentFinancialDetail A

                        INNER JOIN InvestmentBasicDetail B

                              ON A.InvEntityId =B.InvEntityId

                              AND A.EffectiveFromTimeKey =@TIMEKEY AND A.EffectiveToTimeKey =@TIMEKEY

                              AND B.EffectiveFromTimeKey =@TIMEKEY AND B.EffectiveToTimeKey =@TIMEKEY

                        INNER JOIN InvestmentIssuerDetail C

                              ON C.IssuerEntityId=B.IssuerEntityId

                              AND C.EffectiveFromTimeKey =@TIMEKEY AND C.EffectiveToTimeKey =@TIMEKEY

                  WHERE ISNULL(FinalAssetClassAlt_Key,1)=1

                  GROUP BY  UcifId

                  /* DERIVATIVE DATA */

                  UNION

                        SELECT UCIC_ID,MAX(ISNULL(FinalAssetClassAlt_Key,1)) SYSASSETCLASSALT_KEY ,MIN(NPIDt) SYSNPA_DT

                        ,'DER' PercType

                  FROM CurDat.DerivativeDetail A

                        WHERE  A.EffectiveFromTimeKey =@TIMEKEY AND A.EffectiveToTimeKey =@TIMEKEY

                              AND ISNULL(FinalAssetClassAlt_Key,1)=1

                  GROUP BY  UCIC_ID

            )A


      /*  FIND LOWEST ASSET CLASS AND IN NPA DATE IN AALL SOURCES */

      IF OBJECT_ID('TEMPDB..#TEMPTABLE_UCFIC1') IS NOT NULL

    DROP TABLE #TEMPTABLE_UCFIC1

      SELECT UCIF_ID, MAX(SYSASSETCLASSALT_KEY) SYSASSETCLASSALT_KEY, MIN(SYSNPA_DT)SYSNPA_DT

                  ,'XXX' PercType

            INTO #TEMPTABLE_UCFIC1

      FROM #CTE_PERC

            GROUP BY UCIF_ID

 
      UPDATE A

            SET A.PercType=B.PercType

      FROM #TEMPTABLE_UCFIC1 A

            INNER JOIN #CTE_PERC B

                  ON A.UCIF_ID =B.UCIF_ID

                  AND A.SYSASSETCLASSALT_KEY =B.SYSASSETCLASSALT_KEY

      DROP TABLE IF EXISTS #CTE_PERC

 

      /*  UPDATE LOWEST ASSET CLASS AND MIN NPA DATE IN - ADVANCE DATA */

      UPDATE A SET SysAssetClassAlt_Key=B.SYSASSETCLASSALT_KEY

                        ,A.SysNPA_Dt=B.SYSNPA_DT

                        ,A.DegReason=CASE WHEN A.SysAssetClassAlt_Key >1 AND B.SYSASSETCLASSALT_KEY =1

                                                THEN 

                                                      NULL

                                                ELSE  A.DegReason

                                          END

      FROM Pro.CustomerCal A

            INNER JOIN #TEMPTABLE_UCFIC1 B ON A.UCIF_ID =B.UCIF_ID

 

 

      /* UPDATE INVESTMENT DATA - LOWEST ASSET CLASS AND MIN NPA DATE */

      UPDATE A SET A.FinalAssetClassAlt_Key=D.SYSASSETCLASSALT_KEY

                   ,A.NPIDt=D.SYSNPA_DT 

                        ,A.DegReason=CASE WHEN A.FinalAssetClassAlt_Key >1 AND D.SYSASSETCLASSALT_KEY =1

                                                THEN 

                                                      NULL  

                                                            

                                                ELSE  A.DegReason

                                          END

       FROM InvestmentFinancialDetail A

                        INNER JOIN InvestmentBasicDetail B

                              ON A.InvEntityId =B.InvEntityId

                              AND A.EffectiveFromTimeKey =@TIMEKEY AND A.EffectiveToTimeKey =@TIMEKEY

                              AND B.EffectiveFromTimeKey =@TIMEKEY AND B.EffectiveToTimeKey =@TIMEKEY

                        INNER JOIN InvestmentIssuerDetail C

                              ON C.IssuerEntityId=B.IssuerEntityId

                              AND C.EffectiveFromTimeKey =@TIMEKEY AND C.EffectiveToTimeKey =@TIMEKEY

                        INNER JOIN #TEMPTABLE_UCFIC1 D ON D.UCIF_ID =C.UcifId

 

      /*  UPDATE   LOWEST ASSET CLASS AND MIN NPA DATE IN -  DERIVATIVE DATA */

      UPDATE A SET FinalAssetClassAlt_Key=B.SYSASSETCLASSALT_KEY

                        ,A.NPIDt=SYSNPA_DT

                        ,A.DegReason=CASE WHEN A.FinalAssetClassAlt_Key >1 AND B.SYSASSETCLASSALT_KEY =1

                                                THEN 

                                                      NULL

                                                ELSE  A.DegReason

                                          END

      FROM CurDat.DerivativeDetail A

            INNER JOIN #TEMPTABLE_UCFIC1 B ON A.UCIC_ID =B.UCIF_ID

            AND A.EffectiveFromTimeKey=@TIMEKEY AND A.EffectiveToTimeKey=@TIMEKEY

 

 

            update A SET FLGDEG='N',FLGUPG = 'U',UPGDATE = @PROCESSDATE

            FROM CurDat.DerivativeDetail A

            where  A.EffectiveFromTimeKey=@TIMEKEY AND A.EffectiveToTimeKey=@TIMEKEY

             and FinalAssetClassAlt_Key=1 and InitialAssetAlt_Key > 1

 

             update A SET AssetClass_AltKey=FinalAssetClassAlt_Key

             FROM CurDat.DerivativeDetail A

            where  A.EffectiveFromTimeKey=@TIMEKEY AND A.EffectiveToTimeKey=@TIMEKEY

             and FinalAssetClassAlt_Key=1 and InitialAssetAlt_Key > 1

 

             update A SET AssetClass_AltKey=FinalAssetClassAlt_Key

             FROM DBO.InvestmentFinancialDetail A

            where  A.EffectiveFromTimeKey=@TIMEKEY AND A.EffectiveToTimeKey=@TIMEKEY

             and FinalAssetClassAlt_Key=1 and InitialAssetAlt_Key > 1

 

             update A SET FLGDEG='N',FLGUPG = 'U',UPGDATE = @PROCESSDATE

            FROM InvestmentFinancialDetail A

            where  A.EffectiveFromTimeKey=@TIMEKEY AND A.EffectiveToTimeKey=@TIMEKEY

             and FinalAssetClassAlt_Key=1 and InitialAssetAlt_Key > 1


      DROP TABLE IF EXISTS #TEMPTABLE_UCFIC1

------------------------------------------------------------------------------------------------

    DROP TABLE #TEMPTABLE
	--DROP TABLE #TEMPTABLE1
IF OBJECT_ID('TEMPDB..#TEMPTABLERefCustomerID') IS NOT NULL
	DROP TABLE #TEMPTABLERefCustomerID


	
	
/* added by amar on 14102021 for check acl and dpd missmatch issue*/
		IF EXISTS(
					SELECT 1
					FROM Pro.AccountCal A   
					WHERE (ISNULL(A.Asset_Norm,'NORMAL')<>'ALWYS_STD') 
							and ISNULL(A.Balance,0)>0
							AND A.FinalAssetClassAlt_Key =1
						AND(
							   ISNULL((CASE WHEN A.IntNotServicedDt IS NOT NULL THEN DATEDIFF(DAY,A.IntNotServicedDt,@PROCESSDATE)  
											ELSE 0 END),0)>=A.REFPERIODINTSERVICE 
							OR ISNULL((CASE WHEN A.ContiExcessDt IS NOT NULL    THEN DATEDIFF(DAY,A.ContiExcessDt,  @PROCESSDATE) + 1					  ELSE 0 END),0)>=A.REFPERIODOVERDRAWN   
							OR ISNULL(CASE WHEN (DebitSinceDt IS NULL OR DATEDIFF(DAY,DebitSinceDt,@PROCESSDATE)>90)
													THEN (CASE WHEN  A.LastCrDate IS NOT NULL THEN DATEDIFF(DAY,A.LastCrDate,  @PROCESSDATE) ELSE		0 END)
											ELSE 0 END,0)>=A.REFPERIODNOCREDIT     
							OR ISNULL((CASE WHEN A.OverDueSinceDt IS NOT NULL   THEN  DATEDIFF(DAY,A.OverDueSinceDt,  @PROCESSDATE)  						  ELSE 0 END),0) >=A.REFPERIODOVERDUE      
							OR ISNULL((CASE WHEN A.StockStDt IS NOT NULL         THEN   DATEDIFF(DAY,A.StockStDt,@PROCESSDATE)      
											ELSE 0 END),0)>=A.REFPERIODSTKSTATEMENT
							OR ISNULL((CASE WHEN  A.ReviewDueDt IS NOT NULL      THEN DATEDIFF(DAY,A.ReviewDueDt, @PROCESSDATE)      
											ELSE			0 END),0)>=A.REFPERIODREVIEW         
					   )
		)
	BEGIN
		RAISERROR ('Missmatch in DPD and Asset Class, need to check....',16,1)
	END
	---- ADDED ON 17062024 Akshay 
	UPDATE PRO.ACCOUNTCAL
	SET NPA_Reason=NULL,DegReason=NULL
	WHERE FinalAssetClassAlt_Key=1

UPDATE PRO.ACLRUNNINGPROCESSSTATUS 
	SET COMPLETED='Y',ERRORDATE=NULL,ERRORDESCRIPTION=NULL,COUNT=ISNULL(COUNT,0)+1
	WHERE RUNNINGPROCESSNAME='Upgrade_Customer_Account'



 	------------Added for DashBoard 04-03-2021
	--Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='ASSET CLASSIFICATION'



----------------------Added by prashant----for validate the error data---------13122023----------------

   Drop table if exists ACCOUNTCAL_ErrorLog
   Drop table if exists CUSTOMERCAL_ErrorLog

    select * into ACCOUNTCAL_ErrorLog from Pro.AccountCal
	select * into CUSTOMERCAL_ErrorLog from Pro.CustomerCal

-------------------------------------------------------------------------------------------------------
	
	
/*CREATING TEMP TABLE FOR LIVE NPA DATE DATA ONLY TO COMPARE WITH PROVISION REDUCTION TABLE */

DROP TABLE IF EXISTS #ACCOUNTCAL_NPA
	SELECT A.CustomerAcID,A.FinalAssetClassAlt_Key INTO #ACCOUNTCAL_NPA FROM PRO.ACCOUNTCAL A 
	WHERE 
	A.FinalAssetClassAlt_Key>1 AND 
	A.EffectiveFromTimeKey<=@TIMEKEY AND A.EffectiveToTimeKey>=@TIMEKEY 

/*EXPIRING RECORDS IN REDUCTION TABLE WHERE CLASSIFICATION IS CHANGED*/


	UPDATE PR SET  PR.EffectiveToTimeKey=@TIMEKEY-1
	FROM #ACCOUNTCAL_NPA A INNER JOIN CURDAT.PROVISION_REDUCTION PR 
	ON 
		A.CustomerACID=PR.CustomerACID AND 
		ISNULL(A.FinalAssetClassAlt_Key,'')<>PR.NCIF_AssetClassAlt_Key
	WHERE PR.EffectiveFromTimeKey<=@TIMEKEY AND PR.EffectiveToTimeKey>=@TIMEKEY 




/*IF WE ARE TO RE-PROCESSING DUE TO ANY REASON THEN THE DATA LOADED IN HIST TABLE SHOULD BE DELETED SO THAT THERE WONT BE ANY DUPLICATES IN HIST TABLE*/
DELETE FROM PROVISION_REDUCTION_HIST
WHERE  EffectiveToTimeKey=@TIMEKEY-1

/*MAINTAINING HISTORY FOR EXPIRED PROVISION REDUCTION*/
INSERT INTO PROVISION_REDUCTION_HIST
SELECT * FROM CURDAT.PROVISION_REDUCTION
WHERE  EffectiveToTimeKey=@TIMEKEY-1





END TRY
BEGIN  CATCH

      UPDATE PRO.ACLRUNNINGPROCESSSTATUS 
      SET COMPLETED='N',ERRORDATE=GETDATE(),ERRORDESCRIPTION=ERROR_MESSAGE(),COUNT=ISNULL(COUNT,0)+1
      WHERE RUNNINGPROCESSNAME='Upgrade_Customer_Account'
END CATCH

SET NOCOUNT OFF
END
















GO