SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[BusinessSegmentdropdown]

as

Begin

Declare @TimeKey as int
set @TimeKey = (Select Timekey from sysdatamatrix where CurrentStatus='C')

select SourceAlt_key,Sourcename,'SourceSystem' TableName from DIMSOURCEDB where effectivefromtimekey<=@TimeKey and effectivetotimekey>=@Timekey



End
GO