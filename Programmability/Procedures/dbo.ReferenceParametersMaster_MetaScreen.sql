SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[ReferenceParametersMaster_MetaScreen]        
as      
Begin      
      
SELECT *, 'ReferenceParametersMaster' AS TableName FROM MetaScreenFieldDetail WHERE ScreenName='ReferenceParametersMaster'      
END 
GO