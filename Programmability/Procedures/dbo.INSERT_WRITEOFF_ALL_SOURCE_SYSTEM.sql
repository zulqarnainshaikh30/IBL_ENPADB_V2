SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[INSERT_WRITEOFF_ALL_SOURCE_SYSTEM]
AS
BEGIN



	/*MAINTAIN WRITE OFF DATA IN AdvAcWODetail TABLE*/
	DECLARE @TimeKey INT = (SELECT TimeKey FROM IBL_ENPA_DB_V2..SysDataMatrix WHERE CurrentStatus='C' )
	DECLARE @Exec_Date DATE=(SELECT DATE FROM IBL_ENPA_DB_V2..SysDataMatrix WHERE TimeKey=@TimeKey )



		INSERT INTO CURDAT.ADVAdvAcWODetail(
				[EffectiveFromTimeKey],
				[EffectiveToTimeKey],
				Customer_CIF,
				[CustomerID],
				[CustomerACID],
				[WriteOffDt],
				[WO_PWO],
				[WriteOffAmt],
				CreatedBy,
				DateCreated)
		SELECT @TimeKey,
			   99999,
			   A.NCIF_Id,
			   A.CustomerID,
			   A.CustomerACID,
			   A.WriteOffDt,
			   'TWO',
			   A.WriteOffAmt,
			   'SSIS USER',
			   GETDATE()
		FROM IBL_ENPA_TEMPDB_V2.ETL_TEMP.AdvAcWODetail A

			UPDATE WO
	SET WO.EffectiveToTimeKey=@TimeKey-1,
		WO.ModifiedBy='SSIS USER',
		WO.DateModified=GETDATE()
	FROM IBL_ENPA_DB_V2.[CURDAT].[AdvAcWODetail] WO
	INNER JOIN IBL_ENPA_STGDB_V2.DBO.ACCOUNT_ALL_SOURCE_SYSTEM A ON WO.EffectiveFromTimeKey<=@TimeKey
										AND WO.EffectiveToTimeKey>=@TimeKey
										AND Wo.CustomerID=A.CustomerId
										AND WO.CustomerACID=A.CustomerACID
		WHERE ISNULL(A.IsTWO,'')='Y'
		--AND A.SrcSysAlt_Key=@SrcSysAlt_Key     ------Added on 19-07-2021
		AND (isnull([WriteOffDt],'1900-01-01')<>isnull(A.TWODate,'1900-01-01')
				OR isnull([WriteOffAmt],0)<>isnull(A.TWOAmount,0))
END
GO