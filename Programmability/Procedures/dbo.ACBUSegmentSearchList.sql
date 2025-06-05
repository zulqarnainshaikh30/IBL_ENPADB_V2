SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--exec [ACBUSegmentSearchList] '','','',1
CREATE PROC [dbo].[ACBUSegmentSearchList]
--Declare
													 @SourceSystem					varchar(10)		= ''
													,@ACBUSegmentCode               varchar(10)		= ''
													,@ACBUSegmentDescription		varchar(100)	= ''
													,@OperationFlag					INT				= 1
AS
     
	 BEGIN

SET NOCOUNT ON;
Declare @TimeKey as Int
	SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')
				PRINT 	@Timekey

				
		 	IF ((@SourceSystem ='') AND  (@ACBUSegmentCode='') AND (@ACBUSegmentDescription ='' )  AND (@operationflag not in(16,20)))
		BEGIN
		print '111'
				 SELECT		SourceSystem
							,ACBUSegmentCode
							,ACBUSegmentDescription
							,AuthorisationStatus
							,EffectiveFromTimeKey
							,EffectiveToTimeKey
							,CreatedBy
							,DateCreated
							,ModifyBy
							,DateModified
							,ApprovedBy
							,DateApproved
							,D2Ktimestamp
							,Remarks
							,ACBUSegmentEntityID
                           INTO #TEMP55
							--select * from  curdat.Advacbasicdetail
                     FROM ACBUSegment A 
					
					   UNION

                     SELECT		
					        SourceSystem
							,ACBUSegmentCode
							,ACBUSegmentDescription
							,AuthorisationStatus
							,EffectiveFromTimeKey
							,EffectiveToTimeKey
							,CreatedBy
							,DateCreated
							,ModifyBy
							,DateModified
							,ApprovedBy
							,DateApproved
							,D2Ktimestamp
							,Remarks
							,ACBUSegmentEntityID
                     FROM	ACBUSegment_Mod A 
					 

					        SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY EntityKey) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'AccountBusinessSegmentMaster' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp55 A
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
                 --      AND RowNumber <= (@PageNo * @PageSize);
           
				 return;
		END
BEGIN TRY

			IF @SourceSystem =''
		   SET @SourceSystem=NULL

		IF @ACBUSegmentCode =''
		   SET @ACBUSegmentCode = NULL

		IF @ACBUSegmentDescription =''
		   SET @ACBUSegmentDescription=NULL

		

		   print '1'
/*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */

			IF(@OperationFlag not in (16,17,20))
             BEGIN
			 IF OBJECT_ID('TempDB..#temp') IS NOT NULL
                 DROP TABLE  #temp;
                 SELECT		
				          	SourceSystem
							,ACBUSegmentCode
							,ACBUSegmentDescription
							,AuthorisationStatus
							,EffectiveFromTimeKey
							,EffectiveToTimeKey
							,CreatedBy
							,DateCreated
							,ModifyBy
							,DateModified
							,ApprovedBy
							,DateApproved
							,D2Ktimestamp
							,Remarks
							,ACBUSegmentEntityID
                            
                 INTO #temp
                 FROM 
                 (
                    SELECT		SourceSystem
							,ACBUSegmentCode
							,ACBUSegmentDescription
							,AuthorisationStatus
							,EffectiveFromTimeKey
							,EffectiveToTimeKey
							,CreatedBy
							,DateCreated
							,ModifyBy
							,DateModified
							,ApprovedBy
							,DateApproved
							,D2Ktimestamp
							,Remarks
							,ACBUSegmentEntityID
                         
							--select * from  curdat.Advacbasicdetail
                     FROM ACBUSegment
						 
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
						   AND ((A.SourceSystem   = @SourceSystem)				
						   OR (ACBUSegmentCode =@ACBUSegmentCode)			
							OR (ACBUSegmentDescription like '%' + @ACBUSegmentDescription+ '%'))
                     UNION
                     SELECT		SourceSystem
							,ACBUSegmentCode
							,ACBUSegmentDescription
							,AuthorisationStatus
							,EffectiveFromTimeKey
							,EffectiveToTimeKey
							,CreatedBy
							,DateCreated
							,ModifyBy
							,DateModified
							,ApprovedBy
							,DateApproved
							,D2Ktimestamp
							,Remarks
							,ACBUSegmentEntityID
                         
							--select * from  curdat.Advacbasicdetail
                     FROM ACBUSegment_Mod
					 --inner join curdat.DerivativeDetail E on A.EntityKey=E.EntityKey
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
						    AND (
							(SourceSystem   = @SourceSystem)				
						   OR (ACBUSegmentCode =@ACBUSegmentCode)			
							OR (@ACBUSegmentDescription like '%' + @ACBUSegmentDescription+ '%')		
							
							)
                           AND A.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM ACBUSegment_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')							  
                         GROUP BY EntityKey
                     )
                 ) A
                      
                 
                 GROUP BY    
				           
                            --A.CustomerACID,
                            --A.CustomerID,
                            --A.CustomerName,
                            --A.DerivativeRefNo,
                            --A.Duedate,
                            --A.DueAmt,
                            --A.OsAmt,
                            --A.POS,
				 ---------------------------------
				          	SourceSystem
							,ACBUSegmentCode
							,ACBUSegmentDescription
							,AuthorisationStatus
							,EffectiveFromTimeKey
							,EffectiveToTimeKey
							,CreatedBy
							,DateCreated
							,ModifyBy
							,DateModified
							,ApprovedBy
							,DateApproved
							,D2Ktimestamp
							,Remarks
							,ACBUSegmentEntityID
                            

                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY EntityKey) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'InvestmentCodeMaster' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp A
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
                 --      AND RowNumber <= (@PageNo * @PageSize);
             END;
             ELSE

			 /*  IT IS Used For GRID Search which are Pending for Authorization    */
			 IF (@OperationFlag in(16,17))

             BEGIN
			 IF OBJECT_ID('TempDB..#temp16') IS NOT NULL
                 DROP TABLE #temp16;
                 SELECT     

				           
                            --A.CustomerACID,
                            --A.CustomerID,
                            --A.CustomerName,
                            --A.DerivativeRefNo,
                            --A.Duedate,
                            --A.DueAmt,
                            --A.OsAmt,
                            --A.POS,
				 ---------------------------------
				            SourceSystem
							,ACBUSegmentCode
							,ACBUSegmentDescription
							,AuthorisationStatus
							,EffectiveFromTimeKey
							,EffectiveToTimeKey
							,CreatedBy
							,DateCreated
							,ModifyBy
							,DateModified
							,ApprovedBy
							,DateApproved
							,D2Ktimestamp
							,Remarks
							,ACBUSegmentEntityID
                       
                            
                 INTO #temp16
                 FROM 
                 (
                     SELECT 
							SourceSystem
							,ACBUSegmentCode
							,ACBUSegmentDescription
							,AuthorisationStatus
							,EffectiveFromTimeKey
							,EffectiveToTimeKey
							,CreatedBy
							,DateCreated
							,ModifyBy
							,DateModified
							,ApprovedBy
							,DateApproved
							,D2Ktimestamp
							,Remarks
							,ACBUSegmentEntityID                            
                     FROM ACBUSegment_Mod A
					 --inner join curdat.DerivativeDetail E on A.EntityKey=E.EntityKey
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                           AND A.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM ACBUSegment_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')
							    GROUP BY EntityKey
                     )
                 ) A 
                      
                 
                 GROUP BY   

				            
                            --A.CustomerACID,
                            --A.CustomerID,
                            --A.CustomerName,
                            --A.DerivativeRefNo,
                            --A.Duedate,
                            --A.DueAmt,
                            --A.OsAmt,
                            --A.POS,
				 ---------------------------------
				             SourceSystem
							,ACBUSegmentCode
							,ACBUSegmentDescription
							,AuthorisationStatus
							,EffectiveFromTimeKey
							,EffectiveToTimeKey
							,CreatedBy
							,DateCreated
							,ModifyBy
							,DateModified
							,ApprovedBy
							,DateApproved
							,D2Ktimestamp
							,Remarks
							,ACBUSegmentEntityID 

                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY EntityKey) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'AccountBusinessSegmentMaster' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp16 A
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
                 --      AND RowNumber <= (@PageNo * @PageSize)

   END;

   Else

   IF (@OperationFlag =20)
             BEGIN
			 IF OBJECT_ID('TempDB..#temp20') IS NOT NULL
                 DROP TABLE #temp20;
                 SELECT      SourceSystem
							,ACBUSegmentCode
							,ACBUSegmentDescription
							,AuthorisationStatus
							,EffectiveFromTimeKey
							,EffectiveToTimeKey
							,CreatedBy
							,DateCreated
							,ModifyBy
							,DateModified
							,ApprovedBy
							,DateApproved
							,D2Ktimestamp
							,Remarks
							,ACBUSegmentEntityID 
                            
                           
                 INTO #temp20
                 FROM 
                 (
                     SELECT 

					       
                            --E.CustomerACID,
                            --E.CustomerID,
                            --E.CustomerName,
                            --E.DerivativeRefNo,
                            --E.Duedate,
                            --E.DueAmt,
                            --E.OsAmt,
                            --E.POS,
				 ---------------------------------
				             SourceSystem
							,ACBUSegmentCode
							,ACBUSegmentDescription
							,AuthorisationStatus
							,EffectiveFromTimeKey
							,EffectiveToTimeKey
							,CreatedBy
							,DateCreated
							,ModifyBy
							,DateModified
							,ApprovedBy
							,DateApproved
							,D2Ktimestamp
							,Remarks
							,ACBUSegmentEntityID    
                         
                     FROM ACBUSegment_Mod A
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           AND ISNULL(A.AuthorisationStatus, 'A') IN('1A')
                           AND A.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM ACBUSegment_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND AuthorisationStatus IN('1A')
                         GROUP BY EntityKey
                     )
                 ) A 
                      
                 
                 GROUP BY   
				          
                            --A.CustomerACID,
                            --A.CustomerID,
                            --A.CustomerName,
                            --A.DerivativeRefNo,
                            --A.Duedate,
                            --A.DueAmt,
                            --A.OsAmt,
                            --A.POS,
				 ---------------------------------
				           SourceSystem
							,ACBUSegmentCode
							,ACBUSegmentDescription
							,AuthorisationStatus
							,EffectiveFromTimeKey
							,EffectiveToTimeKey
							,CreatedBy
							,DateCreated
							,ModifyBy
							,DateModified
							,ApprovedBy
							,DateApproved
							,D2Ktimestamp
							,Remarks
							,ACBUSegmentEntityID  
                          
                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY EntityKey) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'AccountBusinessSegmentMaster' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp20 A
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
                 --      AND RowNumber <= (@PageNo * @PageSize)

   END;


   END TRY
	BEGIN CATCH
	
	INSERT INTO dbo.Error_Log
				SELECT ERROR_LINE() as ErrorLine,ERROR_MESSAGE()ErrorMessage,ERROR_NUMBER()ErrorNumber
				,ERROR_PROCEDURE()ErrorProcedure,ERROR_SEVERITY()ErrorSeverity,ERROR_STATE()ErrorState
				,GETDATE()

	SELECT ERROR_MESSAGE()
	--RETURN -1
   
	END CATCH


  
  
    END;
GO