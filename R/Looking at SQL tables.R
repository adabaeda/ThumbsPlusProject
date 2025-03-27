
library(RODBC) ###allows connection to db, excel, etc.
library (tidyverse) ###dplyr, tidyr, ggplot, stringr, and more
library(readxl) #upload a .xlxs
library(taxize)
library(here)


DMSandbox_ThumbsPlus <- odbcDriverConnect("driver=SQL Server; server=INPSCPNMS01\\DMSandbox, 50001; database=SCPN_ThumbsPlus_Photos; trusted_connection=yes;")
WR_PathandUDF <- sqlFetch(DMSandbox_ThumbsPlus, "view_WR_PathInfo_UDFInfo", stringsAsFactors = FALSE)
innerJoinPathUDF <- sqlFetch(DMSandbox_ThumbsPlus, "view_INNERJOIN_WR_PathInfo_UDFInfo", stringsAsFactors = FALSE)
#event <- sqlFetch(DMSandbox_ThumbsPlus, "tbl_Event", stringsAsFactors = FALSE)
close(DMSandbox_ThumbsPlus)

WR_nullUDFcode <- WR_PathandUDF %>% 
  filter(is.na(idThumbUDF)) %>% view()

#investigating the 1282 difference
WR_PathandUDF %>% 
  filter(idThumb == idThumbUDF) %>% view() #9267 There are no mismatched idThumbUDFs

WR_PathandUDF %>% 
  filter(is.na(idThumbUDF)) %>% view() #1327 null variables this matches the 9267 


