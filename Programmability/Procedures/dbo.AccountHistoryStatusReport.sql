SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[AccountHistoryStatusReport]
AS
select	S.SourceName,B.Date as FromDate,C.Date as	ToDate,CustomerACID,D.AssetClassName,E.AssetClassName,
		OverDueSincedt,NPA_Reason,FinalNpaDt,DegReason,UpgDate
from Pro.accountcal_Hist A with (nolock) 
LEFT JOIN Automate_Advances B ON A.EffectiveFromTimeKey = B.Timekey
LEFT JOIN Automate_Advances C ON A.EffectiveToTimeKey = C.Timekey
LEFT JOIN DimAssetClass D ON A.InitialAssetClassAlt_Key = D.AssetClassAlt_Key
LEFT JOIN DimAssetClass E ON A.FinalAssetClassAlt_Key = E.AssetClassAlt_Key
Left join DIMSOURCEDB S On A.Sourcealt_key = S.SourceAlt_Key
where  CustomerAcID in('0005243736309153356','0007477770002478755','809001720388') 
order by  CustomerACID,A.EffectiveFromTimeKey,A.EffectiveToTimeKey
GO