SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO




----/*=========================================
---- AUTHER : TRILOKI KHANNA
---- CREATE DATE : 27-11-2019
---- MODIFY DATE : 27-11-2019
---- DESCRIPTION : UPDATE InvestmentDataProcessing
---- --EXEC [PRO].[InvestmentDerivativeProvisionCal] @TIMEKEY=26959
----=============================================*/


CREATE PROCEDURE [PRO].[InvestmentDerivativeProvisionCal]
@TIMEKEY INT = 26629
,@FlgMoc CHAR(1)='N'
WITH RECOMPILE
/*=========================================
-- AUTHOR : TRILOKI KHANNA
-- CREATE DATE : 09-04-2021
-- MODIFY DATE : 07-07-2022
-- DESCRIPTION : Test Case Cover in This SP

--=============================================*/
AS
BEGIN
  SET NOCOUNT ON
   BEGIN TRY
--DECLARE @TIMEKEY INT=@TimeKey
DECLARE @EXTDATE AS DATE

SELECT @EXTDATE  = DATE FROM SYSDAYMATRIX  WHERE TIMEKEY=@TimeKey

----/*----------------PROVISION ALT KEY ALL  ACCOUNTS--------------------------------*/
/*  INVESTMENT  */

            UPDATE A SET PROVISIONALT_KEY=0
            from InvestmentFinancialDetail  A
            where  (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
                     AND (ISNULL(A.FlgMoc,'N')=CASE WHEN @FlgMoc='Y'  THEN @FlgMoc  else ISNULL(A.FlgMoc,'N') END) -- AMAR ADDED CODE FOR moc


           
/* UPADTE PROVISION ALT KEY AS PER IRAC NORMS */
 UPDATE A SET A.ProvisionAlt_Key=D.ProvisionAlt_Key
            FROM InvestmentFinancialDetail A 
            INNER JOIN DimAssetClass C ON C.AssetClassAlt_Key=isnull(A.FinalAssetClassAlt_Key,1) 
                   AND (C.EffectiveFromTimeKey<=@TIMEKEY AND C.EffectiveToTimeKey>=@TIMEKEY)
                   INNER JOIN DimProvision_Seg d
                        ON D.EffectiveFromTimeKey <=@TIMEKEY AND D.EffectiveToTimeKey>=@TIMEKEY
                        AND c.AssetClassShortName=d.PROVISIONSHORTNAMEENUM
                  WHERE  C.ASSETCLASSGROUP='NPA'  AND
                   (A.EffectiveFromTimeKey<=@TIMEKEY AND A.EffectiveToTimeKey>=@TIMEKEY)
                    and d.SEGMENT='IRAC'
                     AND (ISNULL(A.FlgMoc,'N')=CASE WHEN @FlgMoc='Y'  THEN @FlgMoc  else ISNULL(A.FlgMoc,'N') END) -- AMAR ADDED CODE FOR moc



	/* UPDATE PROVISION ALT KY AS PER BANK'S PROVISION NORMS*/

	/*  PREPARE NPA_DAYS FROM NPA DATE */
	DROP TABLE IF EXISTS #AC_NPA_DAYS
	SELECT InvEntityId,DATEDIFF(DD,NPIDt,@EXTDATE)+1 NPA_DAYS
		INTO  #AC_NPA_DAYS
	FROM InvestmentFinancialDetail WHERE FinalAssetClassAlt_Key >1

	UPDATE A 
		SET A.ProvisionAlt_Key=P.ProvisionAlt_Key
	FROM InvestmentFinancialDetail A
            INNER JOIN DimAssetClass C ON C.AssetClassAlt_Key=isnull(A.FINALASSETCLASSALT_KEY,1)
                    AND (C.EffectiveFromTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey)
            inner JOIN DimProvision_Seg   P
				on (P.EffectiveFromTimeKey<=@TimeKey AND P.EffectiveToTimeKey>=@TimeKey)
                    AND P.ProvisionShortNameEnum=C.AssetClassShortName
					AND P.Segment='BANK'
            INNER JOIN #AC_NPA_DAYS NP
                    ON NP.InvEntityId=A.InvEntityId
                    AND NP.NPA_DAYS  BETWEEN P.LowerDPD AND   P.UpperDPD
            WHERE  C.AssetClassGroup='NPA' 

      
                  /*-- AMAR ADDED CODE FOR moc */
                    UPDATE A
                              SET A.AddlProvision=BookValueINR*ISNULL(AddlProvisionPer,0)/100
                    from InvestmentFinancialDetail a
                        where A.EFFECTIVEFROMTIMEKEY<=@TIMEKEY     AND A.EFFECTIVETOTIMEKEY>=@TIMEKEY
                        AND AddlProvisionPer>0 AND ISNULL(BookValueINR,0)>0
                        AND A.FLGmOC='Y'

                   UPDATE A 
                        SET TotalProvison =(CASE WHEN ISNULL(B.ASSETCLASSSHORTNAMEENUM,'STD')='LOS' 
                                                                        THEN BookValueINR
                                                            ELSE (ISNULL(A.BookValueINR,0) * ISNULL(C.PROVISIONUNSECURED,0)/100 )  
                                                             END)

                        FROM InvestmentFinancialDetail A  
                        INNER JOIN DIMASSETCLASS B ON B.EFFECTIVEFROMTIMEKEY<=@TIMEKEY
                                                                  AND B.EFFECTIVETOTIMEKEY>=@TIMEKEY      
                                                                  AND ISNULL(A.FinalAssetClassAlt_Key,1) =B.ASSETCLASSALT_KEY 
                        INNER JOIN DIMPROVISION_SEG C ON C.EFFECTIVEFROMTIMEKEY<=@TIMEKEY
                                                              AND C.EFFECTIVETOTIMEKEY>=@TIMEKEY      
                                                              AND ISNULL(A.PROVISIONALT_KEY,1) = C.PROVISIONALT_KEY 

                        WHERE  FinalAssetClassAlt_Key>1 AND A.EFFECTIVEFROMTIMEKEY<=@TIMEKEY     AND A.EFFECTIVETOTIMEKEY>=@TIMEKEY  
                                                 AND (ISNULL(A.FlgMoc,'N')=CASE WHEN @FlgMoc='Y'  THEN @FlgMoc  else ISNULL(A.FlgMoc,'N') END) -- AMAR ADDED CODE FOR moc



                   /* STD PROVISION ALTKEY */
                  UPDATE A SET A.ProvisionAlt_Key=D.ProvisionAlt_Key
                  FROM   InvestmentFinancialDetail A 
                  INNER JOIN DimAssetClass C ON C.AssetClassAlt_Key=isnull(A.FinalAssetClassAlt_Key,1) 
                         AND (C.EffectiveFromTimeKey<=@TIMEKEY AND C.EffectiveToTimeKey>=@TIMEKEY)
                         INNER JOIN DimProvision_SegSTD d
                              ON D.EffectiveFromTimeKey <=@TIMEKEY AND D.EffectiveToTimeKey>=@TIMEKEY
                                and d.ProvisionName='Other Portfolio' 
                  WHERE  C.ASSETCLASSGROUP='STD'  AND
                   (A.EffectiveFromTimeKey<=@TIMEKEY AND A.EffectiveToTimeKey>=@TIMEKEY)
                                       AND (ISNULL(A.FlgMoc,'N')=CASE WHEN @FlgMoc='Y'  THEN @FlgMoc  else ISNULL(A.FlgMoc,'N') END) -- AMAR ADDED CODE FOR moc



                  /* STD PROVISION Amount */
                   UPDATE A 
                        SET TotalProvison =(CASE WHEN ISNULL(B.ASSETCLASSSHORTNAMEENUM,'STD')='LOS' 
                                                                        THEN BookValueINR
                                                            ELSE (ISNULL(A.BookValueINR,0) * ISNULL(C.PROVISIONUNSECURED,0)/100 )  
                                                             END)

                        FROM  InvestmentFinancialDetail A  
                        INNER JOIN DIMASSETCLASS B ON B.EFFECTIVEFROMTIMEKEY<=@TIMEKEY
                                                                  AND B.EFFECTIVETOTIMEKEY>=@TIMEKEY      
                                                                  AND ISNULL(A.FinalAssetClassAlt_Key,1) =B.ASSETCLASSALT_KEY 
                        INNER JOIN DimProvision_SegStd C ON C.EFFECTIVEFROMTIMEKEY<=@TIMEKEY
                                                              AND C.EFFECTIVETOTIMEKEY>=@TIMEKEY      
                                                              AND ISNULL(A.PROVISIONALT_KEY,1) = C.PROVISIONALT_KEY 
                        WHERE  FinalAssetClassAlt_Key=1 AND A.EFFECTIVEFROMTIMEKEY<=@TIMEKEY     AND A.EFFECTIVETOTIMEKEY>=@TIMEKEY  
                                                  AND (ISNULL(A.FlgMoc,'N')=CASE WHEN @FlgMoc='Y'  THEN @FlgMoc  else ISNULL(A.FlgMoc,'N') END) -- AMAR ADDED CODE FOR moc

                   OPTION(RECOMPILE)
 
                  UPDATE A
                        SET TotalProvison=TotalProvison+ISNULL(AddlProvision,0)
                  FROM CurDat.InvestmentFinancialDetail A
                        WHERE A.EffectiveFromTimeKey<=@TIMEKEY AND A.EffectiveToTimeKey>=@TIMEKEY
                          AND (ISNULL(A.FlgMoc,'N')=CASE WHEN @FlgMoc='Y'  THEN @FlgMoc  else ISNULL(A.FlgMoc,'N') END) -- AMAR ADDED CODE FOR moc
                         AND ISNULL(AddlProvision,0)>0

                  UPDATE A 
                        SET TotalProvison=A.BookValueINR 
                  FROM CurDat.InvestmentFinancialDetail A
                  WHERE ISNULL(TotalProvison,0)>ISNULL(BookValueINR,0)
----/*----------------PROVISION ALT KEY ALL  ACCOUNTS--------------------------------*/
/* DERIVATIVE */
            UPDATE A SET PROVISIONALT_KEY=0
            FROM   [CurDat].[DerivativeDetail]  A
            where  (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
                           AND (ISNULL(A.FlgMoc,'N')=CASE WHEN @FlgMoc='Y'  THEN @FlgMoc  else ISNULL(A.FlgMoc,'N') END) -- AMAR ADDED CODE FOR moc


            /* NPA PROVISION ALTKEY */
            UPDATE A SET A.ProvisionAlt_Key=D.ProvisionAlt_Key
                  FROM   [CurDat].[DerivativeDetail] A 
            INNER JOIN DimAssetClass C ON C.AssetClassAlt_Key=isnull(A.FinalAssetClassAlt_Key,1) 
                   AND (C.EffectiveFromTimeKey<=@TIMEKEY AND C.EffectiveToTimeKey>=@TIMEKEY)
                   INNER JOIN DimProvision_Seg d
                        ON D.EffectiveFromTimeKey <=@TIMEKEY AND D.EffectiveToTimeKey>=@TIMEKEY
                        AND c.AssetClassShortName=d.PROVISIONSHORTNAMEENUM
            WHERE  C.ASSETCLASSGROUP='NPA'  AND
             (A.EffectiveFromTimeKey<=@TIMEKEY AND A.EffectiveToTimeKey>=@TIMEKEY)
              and d.SEGMENT='IRAC'
               AND (ISNULL(A.FlgMoc,'N')=CASE WHEN @FlgMoc='Y'  THEN @FlgMoc  else ISNULL(A.FlgMoc,'N') END) -- AMAR ADDED CODE FOR moc

                   /*-- AMAR ADDED CODE FOR moc */
                    UPDATE A
                              SET A.AddlProvision=MTMIncomeAmt*AddlProvisionPer/100
                    from CURDAT.[DerivativeDetail] a
                        where A.EFFECTIVEFROMTIMEKEY<=@TIMEKEY     AND A.EFFECTIVETOTIMEKEY>=@TIMEKEY
                        AND AddlProvisionPer>0 AND ISNULL(a.MTMIncomeAmt,0)>0
                        AND A.FLGmOC='Y'



            /* NPA PROVISION maount */
             UPDATE A 
                  SET TotalProvison =
--(CASE WHEN ISNULL(B.ASSETCLASSSHORTNAMEENUM,'STD')='LOS' 
--                                                                  THEN POS
--                                                      ELSE (ISNULL((CASE WHEN A.MTMIncomeAmt < 0 THEN 0 ELSE A.MTMIncomeAmt END),0) * ISNULL(C.PROVISIONUNSECURED,0)/100 )  
--                                                       END)
ISNULL((CASE WHEN ISNULL(A.MTMIncomeAmt,0) < 0 THEN 0 ELSE ISNULL(A.MTMIncomeAmt,0) END),0) * ISNULL(C.PROVISIONUNSECURED,0)/100 

                  FROM   [CurDat].[DerivativeDetail] A  
                  INNER JOIN DIMASSETCLASS B ON B.EFFECTIVEFROMTIMEKEY<=@TIMEKEY
                                                            AND B.EFFECTIVETOTIMEKEY>=@TIMEKEY      
                                                            AND ISNULL(A.FinalAssetClassAlt_Key,1) =B.ASSETCLASSALT_KEY 
                  INNER JOIN DIMPROVISION_SEG C ON C.EFFECTIVEFROMTIMEKEY<=@TIMEKEY
                                                        AND C.EFFECTIVETOTIMEKEY>=@TIMEKEY      
                                                        AND ISNULL(A.PROVISIONALT_KEY,1) = C.PROVISIONALT_KEY 

                  WHERE  FinalAssetClassAlt_Key>1 AND A.EFFECTIVEFROMTIMEKEY<=@TIMEKEY     AND A.EFFECTIVETOTIMEKEY>=@TIMEKEY  
                                                   AND (ISNULL(A.FlgMoc,'N')=CASE WHEN @FlgMoc='Y'  THEN @FlgMoc  else ISNULL(A.FlgMoc,'N') END) -- AMAR ADDED CODE FOR moc
 

             /* STD PROVISION ALTKEY */
            UPDATE A SET A.ProvisionAlt_Key=D.ProvisionAlt_Key
                  FROM   [CurDat].[DerivativeDetail] A 
            INNER JOIN DimAssetClass C ON C.AssetClassAlt_Key=isnull(A.FinalAssetClassAlt_Key,1) 
                   AND (C.EffectiveFromTimeKey<=@TIMEKEY AND C.EffectiveToTimeKey>=@TIMEKEY)
                   INNER JOIN DimProvision_SegSTD d
                        ON D.EffectiveFromTimeKey <=@TIMEKEY AND D.EffectiveToTimeKey>=@TIMEKEY
                          and d.ProvisionName='Other Portfolio' 
            WHERE  C.ASSETCLASSGROUP='STD'  AND
                  (A.EffectiveFromTimeKey<=@TIMEKEY AND A.EffectiveToTimeKey>=@TIMEKEY)
                   AND (ISNULL(A.FlgMoc,'N')=CASE WHEN @FlgMoc='Y'  THEN @FlgMoc  else ISNULL(A.FlgMoc,'N') END) -- AMAR ADDED CODE FOR moc



            /* STD PROVISION maount */
             UPDATE A 
                  SET TotalProvison =ISNULL((CASE WHEN ISNULL(A.MTMIncomeAmt,0) < 0 THEN 0 ELSE ISNULL(A.MTMIncomeAmt,0) END),0) * ISNULL(C.PROVISIONUNSECURED,0)/100 

                  FROM   [CurDat].[DerivativeDetail] A  
                  INNER JOIN DIMASSETCLASS B ON B.EFFECTIVEFROMTIMEKEY<=@TIMEKEY
                                                            AND B.EFFECTIVETOTIMEKEY>=@TIMEKEY      
                                                            AND ISNULL(A.FinalAssetClassAlt_Key,1) =B.ASSETCLASSALT_KEY 
                  INNER JOIN DimProvision_SegStd C ON C.EFFECTIVEFROMTIMEKEY<=@TIMEKEY
                                                        AND C.EFFECTIVETOTIMEKEY>=@TIMEKEY      
                                                        AND ISNULL(A.PROVISIONALT_KEY,1) = C.PROVISIONALT_KEY 
                  WHERE  FinalAssetClassAlt_Key=1 AND A.EFFECTIVEFROMTIMEKEY<=@TIMEKEY     AND A.EFFECTIVETOTIMEKEY>=@TIMEKEY  
                                                 AND (ISNULL(A.FlgMoc,'N')=CASE WHEN @FlgMoc='Y'  THEN @FlgMoc  else ISNULL(A.FlgMoc,'N') END) -- AMAR ADDED CODE FOR moc
 
            
            UPDATE A
                        SET TotalProvison=TotalProvison+AddlProvision
                  FROM CurDat.[DerivativeDetail] A
                        WHERE A.EffectiveFromTimeKey<=@TIMEKEY AND A.EffectiveToTimeKey>=@TIMEKEY
                          AND (ISNULL(A.FlgMoc,'N')=CASE WHEN @FlgMoc='Y'  THEN @FlgMoc  else ISNULL(A.FlgMoc,'N') END) -- AMAR ADDED CODE FOR moc
                         AND ISNULL(AddlProvision,0)>0

                  UPDATE A 
                        SET TotalProvison=A.MTMIncomeAmt 
                  FROM CurDat.[DerivativeDetail] A
                  WHERE ISNULL(TotalProvison,0)>ISNULL(MTMIncomeAmt,0)
            
            OPTION(RECOMPILE)


            UPDATE [CurDat].[DerivativeDetail] SET TotalProvison=0
            WHERE TotalProvison<0 AND EFFECTIVEFROMTIMEKEY<=@TIMEKEY    AND EFFECTIVETOTIMEKEY>=@TIMEKEY 

            --UPDATE [CurDat].[DerivativeDetail] SET TotalProvison=0
            --WHERE EFFECTIVEFROMTIMEKEY<=@TIMEKEY    AND EFFECTIVETOTIMEKEY>=@TIMEKEY AND DEGREASON LIKE '%PERCOLATION%' 
                  
            UPDATE InvestmentFinancialDetail set TotalProvison=0
            where Asset_Norm='ALWYS_STD' and EFFECTIVEFROMTIMEKEY<=@TIMEKEY     AND EFFECTIVETOTIMEKEY>=@TIMEKEY 
            
            
            UPDATE InvestmentFinancialDetail set TotalProvison=0
            where FinalAssetClassAlt_Key = 1  and EFFECTIVEFROMTIMEKEY<=@TIMEKEY     AND EFFECTIVETOTIMEKEY>=@TIMEKEY   

      --------------Added for DashBoard 04-03-2021
      Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='ASSET CLASSIFICATION'

      
END TRY
BEGIN  CATCH

      UPDATE PRO.ACLRUNNINGPROCESSSTATUS 
      SET COMPLETED='N',ERRORDATE=GETDATE(),ERRORDESCRIPTION=ERROR_MESSAGE(),COUNT=ISNULL(COUNT,0)+1
      WHERE RUNNINGPROCESSNAME='InvestmentDataProcessing'
END CATCH


SET NOCOUNT OFF
END




GO