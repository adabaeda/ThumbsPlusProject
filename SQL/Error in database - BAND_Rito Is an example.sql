USE [SCPN_ThumbsPlus_Photos]
GO

/****** Object:  View [dbo].[view_WaterResourcesFilepaths]    Script Date: 4/2/2025 5:21:28 PM ******/
--SET ANSI_NULLS ON
--GO

--SET QUOTED_IDENTIFIER ON
--GO


--create view [dbo].[view_WaterResourcesFilepaths] as

drop table if exists #WR_PATHNUMBEREDTEST
SELECT 
		Thumbnail.idThumb, 
		Path.idPath, 
		Path.name as filePath, 
		Thumbnail.name as fileName,
		rank() over (PARTITION BY Path.idPath ORDER BY Thumbnail.idThumb asc) as photoNumber
INTO #WR_PATHNUMBEREDTEST
FROM Path INNER JOIN Thumbnail ON Path.idPath = Thumbnail.idPath
where Path.name like 'Active_Projects\IM\Monitoring\Water_Resources\field_resources\images\%'  AND Thumbnail.name NOT LIKE 'Thumbs.db'
 -- 10,594 photos
GO


--select * from #WR_PATHNUMBEREDTEST
--where filePath like 'Active_Projects\IM\Monitoring\Water_Resources\field_resources\images\HUTR%'
--order by idPath asc

drop table if exists #Path_ExtractedInfoTest
with replaceChars 
as
(
	select *,
	replace(substring(
		filePath,
		CHARINDEX('\images\', filePath)+8,
		len(filePath)-CHARINDEX('\images\', filePath)

			),'\', '.') as pathInfo
	from #WR_PATHNUMBEREDTEST
)
select distinct * 
INTO #Path_ExtractedInfoTest
from 
(
	select idThumb, idPath, pathInfo, 
		PARSENAME(pathInfo, 3) as parkCode,
		PARSENAME(pathInfo, 2) as siteName,
		PARSENAME(pathInfo, 1) as Date,
		photoNumber,
		filePath,
		fileName

	from replaceChars
) column_info;
GO

select * from #Path_ExtractedInfoTest 
order by idThumb asc 


