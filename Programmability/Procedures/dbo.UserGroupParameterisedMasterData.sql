SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[UserGroupParameterisedMasterData] 
	@timekey INT
AS
BEGIN
	PRINT 'START'
		Update SysCRisMacMenu Set Visible=1 where parentid in (10700) 
			SELECT CtrlName
					,FldName
					,FldCaption
					,FldDataType
					,FldLength
					,ErrorCheck
					,DataSeq
					,CriticalErrorType
					,MsgFlag
					,MsgDescription
					,ReportFieldNo
					,ScreenFieldNo
					,ViableForSCD2
				FROM metaUserFieldDetail WHERE FrmName ='frmUserGroup'
					  
				 Select  EntityKey, MenuTitleId,DataSeq, ISNULL(MenuId,0) MenuId ,ISNULL(ParentId,0) ParentId,MenuCaption, ActionName,ISNULL(BusFld,'') as BusFld,Cast(0 as bit) as IsChecked
				 ,ROW_NUMBER() over (order by MenuTitleID, DataSeq) as srno
				 ,Case when ISNULL(ParentId,0) IN (9999,0) then 'N' else 'Y' END as IsChild
					From SysCRisMacMenu WHERE Visible=1
					Order by MenuTitleID, DataSeq

  	Update SysCRisMacMenu Set Visible=0 where ParentId in (10700) 

	IF OBJECT_ID('Tempdb..#TempReturnDetails') IS NOT NULL
	DROP TABLE #TempReturnDetails

	Create table #TempReturnDetails
	(
	   ReturnId int
	  ,ReportId varchar(max)
	  ,ParentReturnId int

	)


	Insert into #TempReturnDetails
	(

	 ReturnId
	 ,ReportId
	 ,ParentReturnId



	)
	(

	 Select

	 ReturnAlt_Key
	 ,returnId + '-' + returnName
	 ,0
	 from DimReturnDirectory
	 UNION
	 Select
	 D.EntityKey
	 ,D.ReportId
	 ,DR.ReturnAlt_Key
	 from DynamicReportDirectory D
	 inner join ExcelTemplateDirectory ET
	 ON ET.ExcelId=D.ExcelId
	 inner join DimReturnDirectory DR ON DR.ReturnAlt_Key=ET.StateAlt_Key
	 AND ET.Scope='EBRExcelUpload'
	 AND D.ReportMenuId IS NOT NULL


	)

	Select 
	 ReturnId
	 ,ReportId
	 ,ParentReturnId


	from #TempReturnDetails
	order by ReturnId,ParentReturnId
	

	Select
	Distinct 
	 ExcelId
	,ReportId
	,0 as ParentReturnId
	from DynamicReportDirectory
	where ISNULL(Scope,'') <> 'EBRReportCreation'
	AND EffectiveToTimeKey=49999






END






GO