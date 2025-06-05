SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[SP_RFACLMismatchQuery]
AS 
DECLARE @Date date = '01/02/2022'
select			 *
from			ACL_NPA_DATA A
where			SourceName='Finacle'
				And (InitialAssetClassAlt_Key=1 And FinalAssetClassAlt_Key>1)
				and convert(date,process_Date,105) = @Date
		--		UNION
				select			*
from			ACL_UPG_DATA A
where			SourceName='Finacle'
				And (InitialAssetClassAlt_Key>1 And FinalAssetClassAlt_Key=1)
				and convert(date,process_Date,105) = @Date
			--	UNION
select * from ACL_NPA_DATA A
where SourceName='Finacle'
			 And InitialAssetClassAlt_Key>1 And FinalAssetClassAlt_Key>1 
			 ANd (A.InitialAssetClassAlt_Key<>A.FinalAssetClassAlt_Key OR A.InitialNpaDt<>A.FinalNpaDt)
			 and convert(date,process_Date,105) = @Date
GO