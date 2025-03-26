/****** Script for SelectTopNRows command from SSMS  ******/

-- need to make sure userfield with  where name like 'Active_Projects\IM\Monitoring\Water_Resources\field_resources\images\%' AND fileName NOT LIKE 'Thumbs.db' filters is the same amount as
--
SELECT *
  FROM [SCPN_ThumbsPlus_Photos].[dbo].[view_WaterResources_FilePathInfo]

  with userfieldJoin 
  as
  (
  select
	uf.idThumbUDF,
	uf.uf_ParkCode,
	uf.uf_Ecosite,
	uf.uf_SiteID,
	uf_TripDescription,
	uf.uf_Caption,
	uf.uf_PhotoNotes,
	uf.uf_PhotoYear,
	uf_PhotoDate,
		wrPI.idThumb
  from UserFields uf
  inner join view_WaterResources_FilePathInfo wrPI ON uf.idThumbUDF = wrPI.idThumb
  
  select * from userfieldJoin
   where name like 'Active_Projects\IM\Monitoring\Water_Resources\field_resources\images\%' AND fileName NOT LIKE 'Thumbs.db' 