SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE proc [dbo].[ProjectAuthority_PUI]
--@ProjectAuthId  INT
as

Declare @TimeKey as Int
SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')
--Declare @ProjectAuthId int=2
select ParameterAlt_Key	,ParameterName

,'ProjectAuthority' TableName

 from Dimparameter D
 where dimparametername='ProjectAuthority'
  and D.EffectiveFromTimeKey<=@Timekey And D.EffectiveToTimeKey>=@Timekey
  --And ParameterAlt_Key=@ProjectAuthId
GO