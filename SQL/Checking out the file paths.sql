
create view view_WaterResourcesFilepaths as
use SCPN_ThumbsPlus_Photos
SELECT Thumbnail.idThumb, Path.idPath, Path.name as filePath, Thumbnail.name as fileName
FROM Path INNER JOIN Thumbnail ON Path.idPath = Thumbnail.idPath
where Path.name like 'Active_Projects\IM\Monitoring\Water_Resources\field_resources\images\%'  AND Thumbnail.name NOT LIKE 'Thumbs.db'
 -- 10,594 photos

create view view_AllFilepaths as
SELECT Thumbnail.idThumb, Path.idPath, Path.name as filePath, Thumbnail.name as fileName
FROM Path INNER JOIN Thumbnail ON Path.idPath = Thumbnail.idPath

select * from view_AllFilepaths where idThumb = '23658'
  --where name like'Active_Projects\IM\Monitoring\Water_Resources\field_resources\images\BAND\Capulin\20081007'
  
  --select value from string_split()
  
