SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE Procedure [dbo].[MenuTree]
As

If OBJECT_ID('Tempdb..#Detail') IS NOT NULL 
Drop Table #Detail

Create Table #Detail
(
SrNo Int Identity(1,1),
MenuId	int,
ParentId	int,
MenuCaption	nvarchar(600),
Parent Bit
)


If OBJECT_ID('Tempdb..#ParentID') IS NOT NULL 
Drop Table #ParentID

Create Table #ParentID
(
ID Int Identity(1,1),
MenuId	int,

)

INSERT INTO #ParentID
Select MenuId from SysCRisMacMenu where ParentId in (0,9999)
Order By MenuId ASC

Declare @Count Int,@I Int,@MenuId Int

SET @I=1

Select  @Count=Count(*) from #ParentID

While(@I<=@Count)
	BEGIN
	      Select @MenuId=MenuId from #ParentID where ID=@I
	      INSERT INTO #Detail
		  Select MenuId,ParentId,MenuCaption,1 from SysCRisMacMenu where MenuId=@MenuId
		  INSERT INTO #Detail
		  Select MenuId,ParentId,MenuCaption,0 from SysCRisMacMenu where ParentId=@MenuId
		  SET @I=@I+1
	END

	Select * from #Detail
	
GO