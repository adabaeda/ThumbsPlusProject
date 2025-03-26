/****** Script for SelectTopNRows command from SSMS  ******/
drop view if exists  [view_WRnumberedPhotos]
use SCPN_ThumbsPlus_Photos;
go
create view [view_WRnumberedPhotos] as 

SELECT  [idThumb]
      ,[idPath]
      ,[filePath]
      ,[fileName]
	  ,rank() over (PARTITION BY idPath ORDER BY fileName) as photoNumber
	  
  FROM [SCPN_ThumbsPlus_Photos].[dbo].[view_WaterResourcesFilepaths]
	--10,594 photos

select * from view_WRnumberedPhotos

  --where name like'Active_Projects\IM\Monitoring\Water_Resources\field_resources\images\BAND\Capulin\20081007'
  
  --select value from string_split()
  