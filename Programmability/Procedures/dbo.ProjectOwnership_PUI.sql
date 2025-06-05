SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE proc [dbo].[ProjectOwnership_PUI]
--@ProjectownId  INT
as

Declare @TimeKey as Int
SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')
--Declare @ProjectownId int=1
select ParameterAlt_Key	,ParameterName

,'ProjectOwnership' TableName

 from Dimparameter D
 where dimparametername='ProjectOwnership'
  and D.EffectiveFromTimeKey<=@Timekey And D.EffectiveToTimeKey>=@Timekey
  --And ParameterAlt_Key=@ProjectownId
GO