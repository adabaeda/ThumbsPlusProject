use SCPN_ThumbsPlus_Photos


declare @pathString varchar(200)
set @pathString = (select filePath from view_WaterResourcesNumberedPhotos wr where wr.idThumb = '172623')

--select value from string_split(@pathString, '\')
select CHARINDEX('\images\', @pathString) as Position


													--10,594 photos
create view view_WaterResources_FilePathInfo as 
with replaceChars 
as
(
	select *,
	replace(substring(
		filePath,
		CHARINDEX('\images\', filePath)+8,
		len(filePath)-CHARINDEX('\images\', filePath)

			),'\', '.') as pathInfo
	from view_WaterResourcesNumberedPhotos
)
select distinct * 
from 
(
	select idThumb, idPath, pathInfo, 
		PARSENAME(pathInfo, 3) as parkCode,
		PARSENAME(pathInfo, 2) as siteName,
		PARSENAME(pathInfo, 1) as Date,
		photoNumber,
		filePath

	from replaceChars
) column_info;

use SCPN_ThumbsPlus_Photos
select * from view_WaterResources_FilePathInfo
--where name like'Active_Projects\IM\Monitoring\Water_Resources\field_resources\images\BAND\Capulin\20081007'
  
--select value from string_split()