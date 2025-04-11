# Checking out dates and incomplete filepaths

library(RODBC) ###allows connection to db, excel, etc.
library (tidyverse) ###dplyr, tidyr, ggplot, stringr, and more
library(readxl) #upload a .xlxs
library(janitor)
library(here)


DMSandbox_ThumbsPlus <- odbcDriverConnect("driver=SQL Server; server=INPSCPNMS01\\DMSandbox, 50001; database=SCPN_ThumbsPlus_Photos; trusted_connection=yes;")
WR_PathandUDF <- sqlFetch(DMSandbox_ThumbsPlus, "view_WR_PathInfo_UDFInfo", stringsAsFactors = FALSE) %>% 
  arrange(filePath)
# UF_Table <- sqlFetch(DMSandbox_ThumbsPlus, "UserFields", stringsAsFactors = FALSE)
#event <- sqlFetch(DMSandbox_ThumbsPlus, "tbl_Event", stringsAsFactors = FALSE)
close(DMSandbox_ThumbsPlus)

notNorm <- WR_PathandUDF %>% #these are the obs that exhibit filepaths that are not in the normal format
  select(idThumb, idThumbUDF, idPath, parkCode, siteName, Date, filePath, fileName) %>% 
  filter(is.na(parkCode)) %>% 
  arrange(idThumbUDF) %>% distinct()

noUDF <- WR_PathandUDF %>% 
  select(idThumb, idThumbUDF, idPath, parkCode, siteName, Date, filePath, fileName) %>% 
  filter(is.na(idThumbUDF)) %>% 
  arrange(idThumb) %>% distinct() 

noUDF %>% select(idThumbUDF, idPath, parkCode, siteName, Date, filePath) %>% distinct() %>% view()

notNorm %>% #many obvs  have no UDF and not normal filepaths. 
  filter(!idThumb %in% noUDF$idThumb) %>% select(idThumb, parkCode, siteName, filePath) %>% distinct() %>%  view()

# filtering out the files that have weird filepaths or obviously errors

filterThese1 <- WR_PathandUDF %>% 
  filter(str_detect(filePath, "HUTR$$")) 

filterThese2 <- WR_PathandUDF %>% 
  filter(str_detect(filePath, "DSCN2276.zip$"))

filterThese3 <- WR_PathandUDF %>% 
  filter(str_detect(filePath, "Rito$"))

filterThese4 <- WR_PathandUDF %>% 
  filter(str_detect(filePath, "Canyon de Chelly$"))

filterThese5 <- WR_PathandUDF %>% 
  filter(str_detect(filePath, "LakePowell$"))

filterThese6 <- WR_PathandUDF %>% 
  filter(str_detect(filePath, "GRCA_MEVE_BAND_Photos.zip$"))

filterThese7 <- WR_PathandUDF %>% 
  filter(str_detect(filePath, "HUTR_Historical_Photo_Points$"))

filterThese8 <- WR_PathandUDF %>% 
  filter(str_detect(filePath, "Original$"))

filterThese9 <- WR_PathandUDF %>% 
  filter(str_detect(filePath, "Mancos$"))

filterThese10 <- WR_PathandUDF %>% 
  filter(str_detect(pathInfo, "MEVE.Mancos.20180329.20180328"))

filterThese11 <- WR_PathandUDF %>% 
  filter(str_detect(pathInfo, "MEVE.Mancos.20180329.20180328"))

filterThese12  <- WR_PathandUDF %>% 
  filter(str_detect(pathInfo, "20191103_survey"))

filterThese13  <- WR_PathandUDF %>% 
  filter(str_detect(pathInfo, "Canyon del Muerto$"))

filterThese14  <- WR_PathandUDF %>% 
  filter(str_detect(Date, "random"))

filterThese15  <- WR_PathandUDF %>% 
  filter(str_detect(Date, "Many Cherry Spring"))

filterThese16  <- WR_PathandUDF %>% 
  filter(str_detect(Date, "Twin Trail Spring$"))

filterThese17  <- WR_PathandUDF %>% 
  filter(str_detect(Date, "Wild Cherry Spring$"))

filterThese18  <- WR_PathandUDF %>% 
  filter(str_detect(Date, "GRCA$"))

filterThese19  <- WR_PathandUDF %>% 
  filter(str_detect(Date, "GCT Unknown Camera"))


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
filterList <- ls(pattern = "^filterThese\\d")
filterThese <- NULL # the dataframe to fill

for (d in 1:length(filterList)) {
  filterThese <- bind_rows(filterThese, get(filterList[[d]])) %>% distinct() }
rm(list = ls(pattern = "^filterThese\\d")) 

filterThese <- filterThese %>% arrange(Date)
write_tsv(filterThese, "filteredFiles.txt")
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

notNorm %>% 
  select(idPath, filePath) %>% 
  filter(idPath %in% noUDF$idPath) %>% distinct() %>% view() 



###==============================================================

filteredData <- WR_PathandUDF %>%
  filter(!idThumb %in% filterThese$idThumb)
save(filteredData, file=here("filteredPathandUDF")) #s

###==============================================================


#---uncomment to upload to sql
# DMSandbox_ThumbsPlus <- odbcDriverConnect("driver=SQL Server; server=INPSCPNMS01\\DMSandbox, 50001; 
#                                           database=SCPN_ThumbsPlus_Photos; trusted_connection=yes;")
# 
# sqlSave(DMSandbox_ThumbsPlus, dat =filteredData, tablename = "working_FilteredidThumbandUDF", append = T, verbose = T, rownames = F, fast =F, nastring=NULL)
# 
# 
# close(DMSandbox_ThumbsPlus)


###==============================================================

load(here("filteredPathandUDF"))

filteredPathandUDF <- filteredData
#----------------------------------------------------------------------
##Coalescing uf_PhotoYear and Date(Extracted from filepath info)------------------------

filteredPathandUDF %>% 
  select(uf_PhotoYear, uf_PhotoDate, Date) %>% 
  filter(is.na(uf_PhotoDate)) %>% 
  arrange(Date) %>% distinct() %>% view()

filteredPathandUDF %>% 
  filter(is.na(idThumbUDF)) %>% 
  select(Date) %>% distinct() %>% view()

## Looking at Duf_PhotoDate## Looking at Dates
filteredPathandUDF %>% 
  select(uf_PhotoYear, Date) %>% 
  arrange(uf_PhotoYear) %>% 
  distinct() %>% view()


WR_Dates <- filteredPathandUDF %>% 
  select(idThumb, pathInfo, Date, uf_PhotoYear, uf_PhotoDate) %>% distinct()


### Fixing blank uf_photoyear and uf_photdate from filepath CHCU_Photos_20151109


DateFixes <- filteredData %>% 
mutate(DateFix = ifelse(Date == "20100525_Labeled", "20100525",
                  ifelse(Date == "meveman01_20180328", "20180328",
                      ifelse(Date == "PETR_2014Dec10_PhotoPoints", "20141210", 
                             ifelse(Date == "CHCU_Photos_20151109", "20151109", 
                                    ifelse(Date == "20080915Petroglyph", "20080915",
                                           ifelse(Date == "Scanned Photos_1998-2003", "1998-2003",
                                                  ifelse(Date == "Hades Lake 07-28-10", "20100728",
                                                         ifelse(Date == "Final", "20110611",
                                                                ifelse(Date == "Wellhouse_20140722", "20170722",
                                                                       ifelse(Date == "PETR_2014Jan15_PhotoPoints", "20140115",
                                                                              ifelse(Date == "20080815Petr_geomorph", "20080815",
                                                                                     ifelse(Date == "07-28-10", "20100728",
                                                                                            ifelse(Date == "08-01", "20100801",
                                                                                                   ifelse(Date == "2010Jul14", "20100714",
                                                                    Date)))))))))))))))

DateFixes %>% 
  select(uf_PhotoYear, DateFix) %>% 
  arrange(uf_PhotoYear) %>% 
  distinct() %>% view()

WRDatesFixed <- filteredData %>% 
  left_join(DateFixes) %>% 
  select(-Date) %>% 
  rename(Date = "DateFix") 

WRWorking_Clean <- WRDatesFixed %>% 
  select(idThumb,
         idThumbUDF, 
         idPath,
         pathInfo,
         parkCode,
         siteName,
         Date,
         uf_ParkCode,
         uf_Ecosite,
         uf_TripDescription,
         uf_Caption,
         uf_PhotoNotes,
         uf_PhotoYear,
         uf_PhotoDate,
         filePath,
         fileName,
         photoNumber)

save(WRWorking_Clean, file=here("WRWorking_Clean")) #s





