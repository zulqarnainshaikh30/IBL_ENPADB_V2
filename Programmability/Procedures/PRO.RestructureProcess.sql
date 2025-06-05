﻿SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
  
   -----exec RestructureProcess 26571
CREATE PROC [PRO].[RestructureProcess]  
@TIMEKEY  INT=26571,
@Flag char(1)=''----U for Upgrade, H for Hist

WITH RECOMPILE  
AS   
  

IF @Flag='U'
BEGIN

BEGIN TRY  
BEGIN TRAN  
--		DECLARE @TIMEKEY  INT=26571
DECLARE @Processingdate date =(select Date from SysDayMatrix where timekey=@TIMEKEY)  
  

			DELETE IBL_ENPA_STGDB.[dbo].[Procedure_Audit]   
			WHERE [SP_Name]='AssetClassRestrProcess' AND [EXT_DATE]=@Processingdate AND ISNULL([Audit_Flg],0)=0  
  
			INSERT INTO IBL_ENPA_STGDB.[dbo].[Procedure_Audit]  
					   ([EXT_DATE] ,[Timekey] ,[SP_Name],Start_Date_Time )  
			SELECT @Processingdate,@TimeKey,'AssetClassRestrProcess',GETDATE()  
  
  
			TRUNCATE TABLE  PRO.AdvAcRestructureCal-- where EffectiveFromTimeKey=@TIMEKEY  
  
			INSERT INTO PRO.AdvAcRestructureCal              
			 (              
			   AccountEntityId           
			   ,NCIF_ID  
			   ,AssetClassAlt_KeyOnInvocation              
			   ,PreRestructureAssetClassAlt_Key              
			   ,PreRestructureNPA_Date              
			   ,ProvPerOnRestrucure              
			   ,RestructureTypeAlt_Key              
			   ,COVID_OTR_CatgAlt_Key              
			   ,RestructureDt              
			   ,SP_ExpiryDate              
			   ,RestructurePOS              
			   ,DPD_AsOnRestructure              
			   ,RestructureFailureDate              
			   ,DPD_30_90_Breach_Date              
			   ,ZeroDPD_Date              
			   ,SP_ExpiryExtendedDate              
			   ,Res_POS_to_CurrentPOS_Per              
			   ,CurrentDPD              
			   ,TotalDPD              
			   ,VDPD              
			   ,AddlProvPer              
			   ,ProvReleasePer              
			   ,UpgradeDate              
			   ,SurvPeriodEndDate              
			   ,PreDegProvPer              
			   ,NonFinDPD              
			   ,InitialAssetClassAlt_Key              
			   ,FinalAssetClassAlt_Key              
			   ,RestructureProvision              
			   ,SecuredProvision              
			   ,UnSecuredProvision              
			   ,FlgDeg              
			   ,FlgUpg              
			   ,DegDate              
			   --,RestructureStage              
			   ,EffectiveFromTimeKey              
			   ,EffectiveToTimeKey       
			   ,TEN_PC_DATE  
			   ,SecondRestrDate  
			   ,AggregateExposure  
			   ,CreditRating1  
			   ,CreditRating2  
			 )              
			SELECT               
				RefSystemAcId      
			   ,UCIF_ID  NCIF_Id
			   ,NULL AssetClassAlt_KeyOnInvocation              
			   ,NULL PreRestructureAssetClassAlt_Key              
			   ,NULL PreRestructureNPA_Date              
			   ,NULL ProvPerOnRestrucure              
			   ,RestructureTypeAlt_Key             
			   ,NULL COVID_OTR_CatgAlt_Key              
			   ,RestructureDt              
			   ,DATEADD(YY,1,(CASE WHEN ISNULL(RepaymentStartDate,'1900-01-01')>=ISNULL(IntRepayStartDate,'1900-01-01')               
				THEN RepaymentStartDate ELSE  RepaymentStartDate END)              
				 )  SP_ExpiryDate              
			   ,RestructurePOS              
			   ,0 DPD_AsOnRestructure              
			   ,NULL RestructureFailureDate              
			   ,NULL DPD_30_90_Breach_Date              
			   ,NULL ZeroDPD_Date              
			   ,NULL SP_ExpiryExtendedDate              
			   ,0 Res_POS_to_CurrentPOS_Per              
			   ,0 CurrentDPD              
			   ,0 TotalDPD              
			   ,0 VDPD              
			   ,0 AddlProvPer              
			   ,0 ProvReleasePer              
			   ,NULL UpgradeDate              
			   ,NULL SurvPeriodEndDate              
			   ,NULL PreDegProvPer              
			   ,0 NonFinDPD              
			   ,b.InitialAssetClassAlt_Key              
			   ,B.FinalAssetClassAlt_Key 
			   ,0 RestructureProvision              
			   ,0 SecuredProvision              
			   ,0 UnSecuredProvision              
			   ,'N' FlgDeg              
			   ,'N' FlgUpg              
			   ,NULL DegDate              
			  --- ,RestructureStage              
			   ,@Timekey EffectiveFromTimeKey              
			   ,@Timekey EffectiveToTimeKey     
			   ,TEN_PC_DATE  
			  ,CAST(null as date) SecondRestrDate  
			  ,null AggregateExposure  
			  ,null CreditRating1  
			  ,null CreditRating2  
			 FROM AdvAcRestructureDetail a  
			 INNER JOIN PRO.ACCOUNTCAL b  
			  ON b.EffectiveFromTimeKey<=@TIMEKEY and b.EffectiveToTimeKey>=@TIMEKEY  
			  AND b.CustomerACID =a.RefSystemAcId  
			 WHERE a.EffectiveFromTimeKey<=@TimeKey and a.EffectiveToTimeKey>=@Timekey              
 
		  UPDATE A              
			   SET A.SP_ExpiryDate=B.SP_ExpiryDate  
					,A.Res_POS_to_CurrentPOS_Per=B.Res_POS_to_CurrentPOS_Per  
					,A.SP_ExpiryExtendedDate=B.SP_ExpiryExtendedDate  
					,A.TEN_PC_DATE=B.TEN_PC_DATE  
					,A.DPD_30_90_Breach_Date=B.DPD_30_90_Breach_Date  
					,A.ZeroDPD_Date=B.ZeroDPD_Date  
				FROM PRO.AdvAcRestructureCal  A  
			   INNER JOIN PRO.AdvAcRestructureCal_Hist B  
				ON A.AccountEntityId=b.AccountEntityId
			   and B.EffectiveFromTimeKey<=@TimeKey-1 AND B.EffectiveToTimeKey>=@Timekey-1              
  
  

			  Update A set a.SecondRestrDate=b.SecondRestrDate,  
						   a.AggregateExposure=b.AggregateExposure,  
				  a.CreditRating1=b.CreditRating1,  
				  a.CreditRating2=b.CreditRating2  
			  from PRO.AdvAcRestructureCal a inner join  [RestructureGapData] b  
			  on a.NCIF_ID=b.NCIF_ID  
			  where b.EffectiveFromTimeKey<=@TimeKey and b.EffectiveToTimeKey>=@Timekey       
			----------------Update Total OS, Total POS,CrntQtrAssetClass----------------              
			--Select * FROM AdvAcRestructureDetail              
			 Update A SET               
				 A.CurrentPOS=b.PrincOutStd               
				,A.CurrentTOS=Balance              
				,A.FinalAssetClassAlt_Key=b.FinalAssetClassAlt_Key
				,A.FinalNpaDt=b.FinalNpaDt
				,CurrentDPD=B.DPD_Max            
				,a.SP_ExpiryDate =case when A.SP_ExpiryDate is null then dateadd(yy,1,a.RestructureDt) else a.SP_ExpiryDate end              
			 FROM PRO.AdvAcRestructureCal A              
			  INNER JOIN PRO.ACCOUNTCAL B ON A.AccountEntityId=B.AccountEntityID
			 WHERE b.EffectiveFromTimeKey<=@TimeKey And b.EffectiveToTimeKey>=@TimeKey              
            

			-----------select * from AdvAcReStructureDetail where RefSystemAcId ='727001244829'

			;WITH CTE_NCIF	
			AS
			(
				SELECT b.UCIF_ID NCIF_Id
					,MAX(SP_ExpiryDate) SP_ExpiryDate
				FROM PRO.AdvAcRestructureCal A
					INNER JOIN PRO.ACCOUNTCAL B
						on A.AccountEntityId=B.AccountEntityID
				WHERE (A.EffectiveFromTimeKey=@TimeKey AND A.EffectiveToTimeKey=@TimeKey)
					AND (B.EffectiveFromTimeKey=@TimeKey AND B.EffectiveToTimeKey=@TimeKey)
				GROUP BY b.UCIF_ID
			)


			UPDATE a
				set a.SP_ExpiryDate=C.SP_ExpiryDate
			FROM PRO.AdvAcRestructureCal A
					INNER JOIN PRO.ACCOUNTCAL B
						on A.AccountEntityId=B.AccountEntityID
					INNER JOIN CTE_NCIF C
						ON C.NCIF_Id=B.UCIF_ID
				WHERE (A.EffectiveFromTimeKey=@TimeKey AND A.EffectiveToTimeKey=@TimeKey)
					AND (B.EffectiveFromTimeKey=@TimeKey AND B.EffectiveToTimeKey=@TimeKey)

			/* PREPARE ENCIF LEVEL MAX DPD */
			DROP TABLE IF EXISTS #RESTR_NCIF_DPD
			;WITH CTE_RESTR_NCIF_ID
				AS	(
						SELECT B.UCIF_ID NCIF_Id FROM PRO.AdvAcRestructureCal A
						INNER JOIN PRO.ACCOUNTCAL B
							ON B.EffectiveFromTimeKey <=@timekey AND B.EffectiveToTimeKey>=@timekey
							AND A.AccountEntityId=B.AccountEntityID
						GROUP BY B.UCIF_ID
					),
				CTE_RESTR_NCIF_DPD
				AS(
						SELECT B.UCIF_ID,MAX(DPD_Max)  MaxDPD
						FROM CTE_RESTR_NCIF_ID A
						INNER JOIN PRO.ACCOUNTCAL B
							ON B.EffectiveFromTimeKey <=@timekey AND B.EffectiveToTimeKey>=@timekey
							AND A.NCIF_Id=B.UCIF_ID
						GROUP BY B.UCIF_ID
				)

			SELECT B.CustomerAcid,A.MaxDPD 
				INTO #RESTR_NCIF_DPD
			FROM CTE_RESTR_NCIF_DPD A
				INNER JOIN  PRO.ACCOUNTCAL B
					ON B.EffectiveFromTimeKey <=@timekey AND B.EffectiveToTimeKey>=@timekey
					AND A.UCIF_ID=B.UCIF_ID


			 Update A SET               
 				 CurrentDPD=B.MaxDPD              
			 FROM PRO.AdvAcRestructureCal A              
			  INNER JOIN #RESTR_NCIF_DPD B ON A.Customeracid=B.Customeracid              
			 WHERE A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey              



			 UPDATE a   
			  SET  DPD_30_90_Breach_Date=@Processingdate  
				,ZeroDPD_Date=null  
				,SP_ExpiryExtendedDate =NULL   
			 from PRO.AdvAcRestructureCal a  
			  INNER JOIN #RESTR_NCIF_DPD b  
					ON a.Customeracid =b.Customeracid  
			  INNER JOIN DimParameter D ON D.EffectiveFromTimeKey <=@timekey AND D.EffectiveToTimeKey>=@timekey   
				   AND D.ParameterAlt_Key=A.RestructureTypeAlt_Key  
				   AND D.DimParameterName='TypeofRestructuring'   
			 WHERE ( (isnull(ParameterShortNameEnum,'') NOT IN('SME-Aug20-Extn-May21','MSME-Aug20','MSME-May21','Natural Calamity','Others_COMGT') and b.MaxDPD >0)    
				 OR (ParameterShortNameEnum IN('SME-Aug20-Extn-May21','MSME-Aug20','MSME-May21') and MaxDPD >30) )  
				 AND DPD_30_90_Breach_Date IS NULL  
				 and ISNULL(SP_ExpiryExtendedDate,SP_ExpiryDate)>@Processingdate
      
			 UPDATE a   
				SET  A.ZeroDPD_Date=@Processingdate  
					 ,A.DPD_30_90_Breach_Date = NULL  
				----,A.SP_ExpiryExtendedDate =case when DATEADD(YY,1,@Processingdate)   
			 FROM PRO.AdvAcRestructureCal A  
			  INNER JOIN #RESTR_NCIF_DPD B  
				  ON A.Customeracid =B.Customeracid
			  INNER JOIN DimParameter D ON D.EffectiveFromTimeKey <=@timekey AND D.EffectiveToTimeKey>=@timekey   
				  AND D.ParameterAlt_Key=A.RestructureTypeAlt_Key  
				  AND D.DimParameterName='TypeofRestructuring'   
			 WHERE ISNULL(b.MaxDPD,0) =0  
			   AND DPD_30_90_Breach_Date IS NOT NULL  
			   AND A.ZeroDPD_Date IS NULL                ------Added on 24092021 AS discusion with Amar sir and triloki sir  
  

			 UPDATE a   SET
				 A.SP_ExpiryExtendedDate=DATEADD(YY,1,ZeroDPD_Date)  

			 FROM PRO.AdvAcRestructureCal A  

			 WHERE   --b.NCIF_AssetClassAlt_Key>1 AND b.MaxDPD =0  
					A.ZeroDPD_Date IS NOT NULL                ------Added on 24092021 AS discusion with Amar sir and triloki sir  
	
  

  
			   UPDATE PRO.AdvAcRestructureCal SET SP_ExpiryExtendedDate=null WHERE  SP_ExpiryExtendedDate IS NOT NULL AND   
			   SP_ExpiryExtendedDate<SP_ExpiryDate  
  
			   UPDATE PRO.AdvAcRestructureCal SET DPD_30_90_Breach_Date=null WHERE  DPD_30_90_Breach_Date IS NOT NULL AND   
			   DPD_30_90_Breach_Date<ZeroDPD_Date  
  
			   UPDATE PRO.AdvAcRestructureCal SET ZeroDPD_Date=null WHERE  ZeroDPD_Date IS NOT NULL AND   
			   DPD_30_90_Breach_Date>ZeroDPD_Date  

  
			COMMIT TRAN  
			   UPDATE IBL_ENPA_STGDB.[dbo].[Procedure_Audit] SET End_Date_Time=GETDATE(),[Audit_Flg]=1   
			   WHERE [SP_Name]='AssetClassRestrProcess' AND [EXT_DATE]=@Processingdate AND ISNULL([Audit_Flg],0)=0  
  
			END TRY  
			BEGIN CATCH  
			  DECLARE  
				  @ErMessage NVARCHAR(2048),  
				  @ErSeverity INT,  
				  @ErState INT  
   
			  SELECT  @ErMessage = ERROR_MESSAGE(),  
				 @ErSeverity = ERROR_SEVERITY(),  
				 @ErState = ERROR_STATE()  
  
     
			  UPDATE IBL_ENPA_STGDB.[dbo].[Procedure_Audit] SET ERROR_MESSAGE=@ErMessage    
			  WHERE [SP_Name]='AssetClassRestrProcess' AND [EXT_DATE]=@Processingdate AND ISNULL([Audit_Flg],0)=0  
  
			  RAISERROR (@ErMessage,  
				  @ErSeverity,  
				  @ErState )  
			  ROLLBACK TRAN  
			END CATCH  
  
	END
IF @Flag='I'
	BEGIN
			/* UPDATE FINAL ASSET CLASS IN [AdvAcRestructureCal] TABLE AFTER UPGRADE PROCESS */
		Update A SET             
				   A.FinalAssetClassAlt_Key=b.FinalAssetClassAlt_Key
				  ,A.FinalNpaDt=b.FinalNpaDt
			FROM PRO.AdvAcRestructureCal A            
				INNER JOIN PRO.ACCOUNTCAL B ON A.AccountEntityId=B.AccountEntityId
					 WHERE A.EffectiveFromTimeKey<=@TimeKey And A.EffectiveToTimeKey>=@TimeKey   

		/*	insert data in AdvAcRestructureCal_hist table after upg praces*/
		DELETE PRO.AdvAcRestructureCal_Hist WHERE EffectiveFromTimeKey=@TIMEKEY
		INSERT INTO PRO.AdvAcRestructureCal_Hist
				(AccountEntityId
				,NCIF_ID
				,AssetClassAlt_KeyOnInvocation
				,PreRestructureAssetClassAlt_Key
				,PreRestructureNPA_Date
				,ProvPerOnRestrucure
				,RestructureTypeAlt_Key
				,COVID_OTR_CatgAlt_Key
				,RestructureDt
				,SP_ExpiryDate
				,DPD_AsOnRestructure
				,RestructureFailureDate
				,DPD_30_90_Breach_Date
				,ZeroDPD_Date
				,SP_ExpiryExtendedDate
				,CurrentPOS
				,CurrentTOS
				,RestructurePOS
				,Res_POS_to_CurrentPOS_Per
				,CurrentDPD
				,TotalDPD
				,VDPD
				,AddlProvPer
				,ProvReleasePer
				,AppliedNormalProvPer
				,FinalProvPer
				,PreDegProvPer
				,UpgradeDate
				,SurvPeriodEndDate
				,DegDurSP_PeriodProvPer
				,NonFinDPD
				,InitialAssetClassAlt_Key
				,FinalAssetClassAlt_Key
				,RestructureProvision
				,SecuredProvision
				,UnSecuredProvision
				,FlgDeg
				,FlgUpg
				,DegDate
				,RC_Pending
				,FinalNpaDt
				,RestructureStage
				,EffectiveFromTimeKey
				,EffectiveToTimeKey
				--,AdditionalPOS
				,TEN_PC_DATE
				,SecondRestrDate
				,AggregateExposure
				,CreditRating1
				,CreditRating2
		)
		select AccountEntityId
				,NCIF_ID
				,AssetClassAlt_KeyOnInvocation
				,PreRestructureAssetClassAlt_Key
				,PreRestructureNPA_Date
				,ProvPerOnRestrucure
				,RestructureTypeAlt_Key
				,COVID_OTR_CatgAlt_Key
				,RestructureDt
				,SP_ExpiryDate
				,DPD_AsOnRestructure
				,RestructureFailureDate
				,DPD_30_90_Breach_Date
				,ZeroDPD_Date
				,SP_ExpiryExtendedDate
				,CurrentPOS
				,CurrentTOS
				,RestructurePOS
				,Res_POS_to_CurrentPOS_Per
				,CurrentDPD
				,TotalDPD
				,VDPD
				,AddlProvPer
				,ProvReleasePer
				,AppliedNormalProvPer
				,FinalProvPer
				,PreDegProvPer
				,UpgradeDate
				,SurvPeriodEndDate
				,DegDurSP_PeriodProvPer
				,NonFinDPD
				,InitialAssetClassAlt_Key
				,FinalAssetClassAlt_Key
				,RestructureProvision
				,SecuredProvision
				,UnSecuredProvision
				,FlgDeg
				,FlgUpg
				,DegDate
				,RC_Pending
				,FinalNpaDt
				,RestructureStage
				,@TimeKey EffectiveFromTimeKey
				,@TimeKey EffectiveToTimeKey
				--,AdditionalPOS
				,TEN_PC_DATE
				,SecondRestrDate
				,AggregateExposure
				,CreditRating1
				,CreditRating2
			from PRO.AdvAcRestructureCal
		/* END - 17062023 - for restructure deployment */


	END
GO