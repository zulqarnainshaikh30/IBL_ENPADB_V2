SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[GetVisionPlusData]
AS
BEGIN
--Declare @TimeKey AS INT =26090--(Select TimeKey from Automate_Advances where EXT_FLG='Y')
Declare @TimeKey AS INT =(Select TimeKey from Automate_Advances where EXT_FLG='Y')
--------------VisionPlus

Select * from (

Select 'VisionPlusDataList' as TableName, AccountID ,CONVERT(varchar,NPADate,103) as NPADate,'Degrade' [Type] from ReverseFeedData A
Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
 where B.SourceName='VisionPlus'
 And A.AssetSubClass<>'STD'
 AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey

 UNION 

 Select 'VisionPlusDataList' as TableName, AccountID ,'       ' as NPADate,'Upgrade' [Type] from ReverseFeedData A
Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
 where B.SourceName='VisionPlus'
 And A.AssetSubClass='STD'
 AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
 )T
 Order by 4,2 
END
GO