-- creating a table with 


Use SCPN_ThumbsPlus_Photos
drop view if exists view_WR_PathInfo_UDFInfo
create view view_WR_PathInfo_UDFInfo
as(
SELECT 
	wrPI.idThumb,
		uf.idThumbUDF,
	wrPI.idPath,
	wrPI.pathInfo,
	wrPI.parkCode,
	wrPI.siteName,
	wrPI.Date,
		uf.uf_ParkCode, 
		uf.uf_Ecosite,
		uf.uf_TripDescription,
		uf.uf_Caption,
		uf.uf_PhotoNotes,
		uf.uf_PhotoYear,
		uf.uf_PhotoDate,
	wrPI.filePath,
	wrPI.fileName,
	wrPI.photoNumber
FROM view_WR_Extracted_FilePathInfo wrPI
Left JOIN UserFields uf ON wrPI.idThumb = uf.idThumbUDF) --10,594


select * from view_WR_PathInfo_UDFInfo
where idThumb like idThumbUDF --9267


use SCPN_ThumbsPlus_Photos
select idThumbUDF from UserFields -- 17,379 


select * from view_WR_Extracted_FilePathInfo --10,549


select distinct 
	wrPI.idThumb,
		uf.idThumbUDF
from view_WR_Extracted_FilePathInfo wrPI
inner join UserFields uf ON wrPI.idThumb = uf.idThumbUDF

															 --9,267 
															-- 10,549 - 9,267 = 
																			   -- 1,282 photos without UserField Information


create view view_INNERJOIN_WR_PathInfo_UDFInfo
as(
SELECT 
	wrPI.idThumb,
		uf.idThumbUDF,
	wrPI.idPath,
	wrPI.pathInfo,
	wrPI.parkCode,
	wrPI.siteName,
	wrPI.Date,
		uf.uf_ParkCode, 
		uf.uf_Ecosite,
		uf.uf_TripDescription,
		uf.uf_Caption,
		uf.uf_PhotoNotes,
		uf.uf_PhotoYear,
		uf.uf_PhotoDate,
	wrPI.filePath,
	wrPI.fileName,
	wrPI.photoNumber
FROM view_WR_Extracted_FilePathInfo wrPI
inner JOIN UserFields uf ON wrPI.idThumb = uf.idThumbUDF) --9267





select 
	wrPI.idThumb,
		uf.idThumbUDF
from view_WR_Extracted_FilePathInfo wrPI
left join UserFields uf ON wrPI.idThumb = uf.idThumbUDF
where uf.idThumbUDF is null                 --1,327  ???
																--45 udf difference? NEVERMIND :) make sure to not be dyslexic

select * from view_WR_PathInfo_UDFInfo where idThumbUDF is Null  --1327


select * from view_WR_Extracted_FilePathInfo --10,594
