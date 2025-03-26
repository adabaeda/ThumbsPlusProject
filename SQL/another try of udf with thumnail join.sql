
Use SCPN_ThumbsPlus_Photos

SELECT 
	wrPI.idThumb,
		uf.idThumbUDF,
	wrPI.idPath,
	wrPI.pathInfo,
	wrPI.parkCode,
	wrPI.siteName,
	wrPI.Date,
	wrPI.photoNumber,
		uf.uf_ParkCode, 
		uf.uf_Ecosite,
		uf.uf_TripDescription,
		uf.uf_Caption,
		uf.uf_PhotoNotes,
		uf.uf_PhotoDate
FROM view_WR_Extracted_FilePathInfo wrPI
INNER JOIN UserFields uf ON wrPI.idThumb = uf.idThumbUDF
where idThumbUDF = '23658'


use SCPN_ThumbsPlus_Photos
select idThumbUDF from UserFields -- 17,379 

select * from view_WR_Extracted_FilePathInfo --10,549

select 
	wrPI.idThumb,
		uf.idThumbUDF
from view_WaterResourcesFilepaths wrPI 
INNER JOIN UserFields uf ON wrPI.idThumb = uf.idThumbUDF --9,267 
															-- 10,549 - 9,267 = 
																			   -- 1,282 photos without UserField Information