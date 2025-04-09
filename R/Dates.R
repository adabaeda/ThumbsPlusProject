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


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
filterList <- ls(pattern = "^filterThese\\d")
filterThese <- NULL # the dataframe to fill

for (d in 1:length(filterList)) {
  filterThese <- bind_rows(filterThese, get(filterList[[d]])) %>% distinct() }
rm(list = ls(pattern = "^filterThese\\d")) 

filterThese <- filterThese %>% arrange(filePath)
write_tsv(filterThese, "filteredFiles.txt")
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

notNorm %>% 
  select(idPath, filePath) %>% 
  filter(idPath %in% noUDF$idPath) %>% distinct() %>% view() 



###==============================================================

# filteredData <- WR_PathandUDF %>% 
#   filter(!idThumb %in% filterThese$idThumb) 
# save(filteredData, file=here("filteredPathandUDF")) #s

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

colnames <- c("FileName",
              "filePath",
              "idThumb",
              "photoNumber",
              "Title",
              "Date_Created",
              "Access_Status",
              "Rights/Access_Restrictions",
              "Contact",
              "NPS_Unit",
              "Contributor",
              "Location",
              "Keywords/Tags",
              "Description",
              "Publisher",
              "Note/Comment",
              "Details/Contents")

SCPNtemplate <- data.frame(matrix(ncol = 17, nrow = 0))
colnames(SCPNtemplate) <- colnames


SCPNtemplate %>% 
  mutate(FileName = filteredData$fileName,
         filePath = filteredData$filePath,
         idThumb = filteredData$idThumb,
         photoNumber = filteredData$photoNumber,
         Title = paste0(filteredData$parkCode, filteredData$Date))



#----------------------------------------------------------------------

