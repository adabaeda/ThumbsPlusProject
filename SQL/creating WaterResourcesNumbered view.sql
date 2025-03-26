/****** Script for SelectTopNRows command from SSMS  ******/
drop view if exists  [view_numberedPhotos]
use SCPN_ThumbsPlus_Photos;
go
create view [view_numberedPhotos] as 

SELECT  [idThumb]
      ,[idPath]
      ,[name] as filePath
      ,[fileName]
	  ,rank() over (PARTITION BY idPath ORDER BY fileName) as photoNumber
	  
  FROM [SCPN_ThumbsPlus_Photos].[dbo].[view_ThumbsFilePath]
  where name like 'Active_Projects\IM\Monitoring\Water_Resources\field_resources\images\%' AND fileName NOT LIKE 'Thumbs.db' --10,594 photos




  --where name like'Active_Projects\IM\Monitoring\Water_Resources\field_resources\images\BAND\Capulin\20081007'
  
  --select value from string_split()
  