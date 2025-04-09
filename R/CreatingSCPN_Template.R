
library(RODBC) ###allows connection to db, excel, etc.
library (tidyverse) ###dplyr, tidyr, ggplot, stringr, and more
library(readxl) #upload a .xlxs
library(janitor)
library(here)


DMSandbox_ThumbsPlus <- odbcDriverConnect("driver=SQL Server; server=INPSCPNMS01\\DMSandbox, 50001; database=SCPN_ThumbsPlus_Photos; trusted_connection=yes;")
WR_PathandUDF <- sqlFetch(DMSandbox_ThumbsPlus, "view_WR_PathInfo_UDFInfo", stringsAsFactors = FALSE)
# UF_Table <- sqlFetch(DMSandbox_ThumbsPlus, "UserFields", stringsAsFactors = FALSE)
#event <- sqlFetch(DMSandbox_ThumbsPlus, "tbl_Event", stringsAsFactors = FALSE)
close(DMSandbox_ThumbsPlus)


##Coalescing uf_PhotoYear and Date(Extracted from filepath info)------------------------

WR_PathandUDF %>% 
  select(uf_PhotoYear, uf_PhotoDate, Date) %>% 
  filter(is.na(uf_PhotoDate)) %>% distinct() %>% view()



## Looking at Dates
WR_PathandUDF %>% 
  select(uf_PhotoYear, Date) %>% 
  filter(is.na(uf_PhotoYear)) %>% 
  distinct() %>% view()


WR_Dates <- WR_PathandUDF %>% 
  select(idThumb, pathInfo, Date, uf_PhotoYear, uf_PhotoDate) %>% distinct()


### Fixing blank uf_photoyear and uf_photdate from filepath CHCU_Photos_20151109

WR_CHCUFIX <- WR_Dates %>% 
  mutate(uf_PhotoYearfix = ifelse(Date == "CHCU_Photos_20151109", "2015", uf_PhotoYear),
         uf_PhotoDatefix = ifelse(Date == "CHCU_Photos_20151109", "2015Sep09", uf_PhotoDate))

WR_CHCUFIX$uf_PhotoDate <- coalesce(WR_CHCUFIX$uf_PhotoDate, WR_CHCUFIX$uf_PhotoDatefix)

WR_Dates <- WR_Dates %>% 
  mutate(uf_PhotoYear = coalesce(WR_CHCUFIX$uf_PhotoYearfix),
         uf_PhotoDate = coalesce(WR_CHCUFIX$uf_PhotoDatefix))

### Check dates 
WR_Dates %>% 
  select(uf_PhotoYear, uf_PhotoDate, Date) %>% 
  filter(is.na(uf_PhotoYear)) %>% 
  filter(!str_detect(Date, "\\d{8}")) %>% 
  distinct() %>% view()

### Correcting "Date" Rows so that we can further extract the info
WR_Dates_ToCorrect <- WR_PathandUDF %>% 
  select(uf_PhotoYear, uf_PhotoDate, Date, filePath) %>% 
  filter(is.na(uf_PhotoYear)) %>% 
  filter(!str_detect(Date, "\\d{8}")) %>% 
  distinct()

WR_DateCol_Fixed <- WR_Dates %>% 
  mutate(DateFix = ifelse(Date == "CHCU_Photos_20151109", "2015", uf_PhotoYear),
         uf_PhotoDatefix = ifelse(Date == "CHCU_Photos_20151109", "2015Sep09", uf_PhotoDate)))

WR_PathandUDF %>% 
  select(idThumb, idThumbUDF) %>% 
  filter(is.na(idThumbUDF))  %>% distinct() %>% view()


###============================================================== Creating Template


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

SCPNtemplate <- data.frame(matrix(ncol = 17, nrow = 10279))
colnames(SCPNtemplate) <- colnames


SCPNtemplate %>% 
  mutate(FileName = filteredData$fileName,
         filePath = filteredData$filePath,
         idThumb = filteredData$idThumb,
         photoNumber = filteredData$photoNumber,
         Title = "Working",
         Date_Created = "uf_PhotoDate(look over) OR Date",
         Access_Status = "Public access",
         `Rights/Access_Restrictions` = "Public domain",
         Contact = "cntper=David Rakestraw|cntorg=SCPN|cntpos=Hydrologic Technician|cntaddr=930 Switzer Canyon,Flagstaff, AZ 86001|cntemail=drakestraw@nps.gov",
         AltContact = "cntper=Stacy Stumpf|cntorg=SCPN|cntpos=Aquatic Ecologist|cntaddr=930 Switzer Canyon,Flagstaff, AZ 86001|cntemail=sstumpf@nps.gov",
         NPS_Unit = "Wait/SQL",
         Contributor = "SCPN Field Staff",
         Description = filteredData$uf_TripDescription) %>% view()

#------------------------------------------------------------ creating Title
#bind Park, Date, trip description

tripDescriptions <- filteredData %>% 
  select(uf_TripDescription) %>% 
  remove_empty("rows") %>% 
  mutate(uf_TripDescription = tolower(uf_TripDescription)) %>% 
  distinct() 

#10279 - 8630 = 1649 no description
#1013 have no UDF info
#636 have udf info but no description

#no descriptions:
udfInfoNoDescr <- filteredData %>% 
  select(pathInfo, idThumbUDF, uf_TripDescription, photoNumber) %>% 
  filter(is.na(filteredData$uf_TripDescription),
         !is.na(filteredData$idThumbUDF)) %>% distinct()

filteredData %>% 
  filter(idThumb %in% udfInfoNoDescr$idThumb) %>% view()
#---------------------------------------------------------
tripDescriptions <- filteredData %>% 
  select(uf_TripDescription) %>% 
  remove_empty("rows") %>% 
  mutate(uf_TripDescription = tolower(uf_TripDescription)) %>% 
  distinct() 

# fixes1 <- tripDescriptions %>% 
#   mutate(uf_TripDescriptionFIX = ifelse(uf_TripDescription == "aquatic invertebrates", "aquatic macroinvertebrates", 
#                                  ifelse(uf_TripDescription == "aquatic macroinvertebrate", "aquatic macroinvertebrates",
#                                         ifelse(uf_TripDescription == "aquatic macronivertebrates", "aquatic macroinvertebrates",
#                                                ifelse(uf_TripDescription == "aquatic macronivertebrates", "aquatic macroinvertebrates",
#                                                       ifelse(uf_TripDescription == "aquatic macroinvertebrates ", "aquatic macroinvertebrates",
#                                                              ifelse(uf_TripDescription == "aquatic macorinvertebrates", "aquatic macroinvertebrates",
#                                                                     ifelse(uf_TripDescription == "aquatic macroinverterbrates", "aquatic macroinvertebrates",
#                                                                            ifelse(uf_TripDescription == "macroinvertebrate sampling", "aquatic macroinvertebrates",
#                                  
#                                  uf_TripDescription))))))))) %>% 
#   select(uf_TripDescription) %>% distinct()
# 
# fixes2 <- fixes1 %>% 
#   mutate(uf_TripDescription = ifelse(uf_TripDescription == "aquatic macroinvertbrates ", "aquatic macroinvertebrates",
#                                  ifelse(uf_TripDescription == "aquatic macroinvertebrate/water quality", "aquatic macroinvertebrates/water quality",
#                                         ifelse(uf_TripDescription == "aquatic macroinvertebrates/water qulity", "aquatic macroinvertebrates/water quality",
#                                                ifelse(uf_TripDescription == "water quality monitoring", "water quality",
#                                                       ifelse(uf_TripDescription == "water quality ", "water quality",
#                                                              ifelse(uf_TripDescription == "water quality, aquatic macroinvertebrates", "aquatic macroinvertebrates/water quality",
#                                                                     ifelse(uf_TripDescription == "aquatic macroinvertebrates, water quality", "aquatic macroinvertebrates/water quality",
#                                                                            ifelse(uf_TripDescription == "aquatic macroinverterbrates ", "aquatic macroinvertebrates",
#                                                                                   ifelse(uf_TripDescription == "aquatic macronivertebrates ", "aquatic macroinvertebrates",
#                                                                                     uf_TripDescription)))))))))) %>% 
#   select(uf_TripDescription) %>% distinct()
# 
# 
# fixes3 <- fixes2 %>% 
#   mutate(uf_TripDescription = ifelse(uf_TripDescription == "photo of sampling reach at transect 1", "aquatic macroinvertebrates",
#                                  ifelse(uf_TripDescription == "aquatic macroinvertebrates, water quality monitoring", "aquatic macroinvertebrates/water quality",
#                                         ifelse(uf_TripDescription == "aquatic macroinverterbrate/water quality", "aquatic macroinvertebrates/water quality",
#                                                ifelse(uf_TripDescription == "aquatic macroinvertebrates/waterquality", "aquatic macroinvertebrates/water quality",
#                                                       ifelse(uf_TripDescription == "aquatic macroionvertebrates/water quality", "aquatic macroinvertebrates/water quality",
#                                                              ifelse(uf_TripDescription == "aquatic macroinvertebrate ", "aquatic macroinvertebrates",
#                                                                     ifelse(uf_TripDescription == "water quality/aquatic macroinvertebrates", "aquatic macroinvertebrates/water quality",
#                                                                            ifelse(uf_TripDescription == "water quality bacteria trip", "water quality/bacteria",
#                                                                                   ifelse(uf_TripDescription == "water quality, bacteria trip", "water quality/bacteria",
#                                                                                          ifelse(uf_TripDescription == "water quality bacteria sampling", "water quality/bacteria",
#                                                                                                 ifelse(uf_TripDescription == "water quality monitoring ", "water quality",
#                                                                     uf_TripDescription)))))))))))) %>% 
#   select(uf_TripDescription) %>% distinct()
# 
# fixes3 %>% select(uf_TripDescription) %>% distinct() %>% view()
# 
# fixes4 <- fixes3 %>% 
#   mutate(uf_TripDescription = ifelse(uf_TripDescription == "august 28", "hydrology", 
#                                      ifelse(uf_TripDescription == "intensive bateria sampling", "intensive bacteria monitoring",
#                                             ifelse(uf_TripDescription == "bacteria monitoring trip", "bateria sampling",
#                                                           ifelse(uf_TripDescription == "intefrated riparian / groundwater", "integrated riparian / groundwater",
#                                                                  ifelse(uf_TripDescription == "hydro", "hydrology",
#                                                                         ifelse(uf_TripDescription == "integrated riparian ", "integrated riparian", 
#                                                                                ifelse(uf_TripDescription == "springs recon ", "springs recon",
#                                                                         uf_TripDescription)))))))) %>% 
#   (uf_TripDescription) %>% distinct()
  


descFixes <- tripDescriptions %>% 
  mutate(uf_TripDescriptionFIX = ifelse(uf_TripDescription == "aquatic invertebrates", "aquatic macroinvertebrates", 
                                        ifelse(uf_TripDescription == "aquatic macroinvertebrate", "aquatic macroinvertebrates",
                                               ifelse(uf_TripDescription == "aquatic macronivertebrates", "aquatic macroinvertebrates",
                                                      ifelse(uf_TripDescription == "aquatic macronivertebrates", "aquatic macroinvertebrates",
                                                             ifelse(uf_TripDescription == "aquatic macroinvertebrates ", "aquatic macroinvertebrates",
                                                                    ifelse(uf_TripDescription == "aquatic macorinvertebrates", "aquatic macroinvertebrates",
                                                                           ifelse(uf_TripDescription == "aquatic macroinverterbrates", "aquatic macroinvertebrates",
                                                                                  ifelse(uf_TripDescription == "macroinvertebrate sampling", "aquatic macroinvertebrates",
                                                                                          ifelse(uf_TripDescription == "aquatic macroinvertbrates ", "aquatic macroinvertebrates",
                                                                                                 
                                     ifelse(uf_TripDescription == "aquatic macroinvertebrate/water quality", "aquatic macroinvertebrates/water quality",
                                            ifelse(uf_TripDescription == "aquatic macroinvertebrates/water qulity", "aquatic macroinvertebrates/water quality",
                                                   ifelse(uf_TripDescription == "water quality monitoring", "water quality",
                                                          ifelse(uf_TripDescription == "water quality ", "water quality",
                                                                 ifelse(uf_TripDescription == "water quality, aquatic macroinvertebrates", "aquatic macroinvertebrates/water quality",
                                                                        ifelse(uf_TripDescription == "aquatic macroinvertebrates, water quality", "aquatic macroinvertebrates/water quality",
                                                                               ifelse(uf_TripDescription == "aquatic macroinverterbrates ", "aquatic macroinvertebrates",
                                                                                      ifelse(uf_TripDescription == "aquatic macronivertebrates ", "aquatic macroinvertebrates",
                                                                                             

                              ifelse(uf_TripDescription == "photo of sampling reach at transect 1", "aquatic macroinvertebrates",
                                     ifelse(uf_TripDescription == "aquatic macroinvertebrates, water quality monitoring", "aquatic macroinvertebrates/water quality",
                                            ifelse(uf_TripDescription == "aquatic macroinverterbrate/water quality", "aquatic macroinvertebrates/water quality",
                                                   ifelse(uf_TripDescription == "aquatic macroinvertebrates/waterquality", "aquatic macroinvertebrates/water quality",
                                                          ifelse(uf_TripDescription == "aquatic macroionvertebrates/water quality", "aquatic macroinvertebrates/water quality",
                                                                 ifelse(uf_TripDescription == "aquatic macroinvertebrate ", "aquatic macroinvertebrates",
                                                                        ifelse(uf_TripDescription == "water quality/aquatic macroinvertebrates", "aquatic macroinvertebrates/water quality",
                                                                               ifelse(uf_TripDescription == "water quality bacteria trip", "water quality/bacteria",
                                                                                      ifelse(uf_TripDescription == "water quality, bacteria trip", "water quality/bacteria",
                                                                                             ifelse(uf_TripDescription == "water quality bacteria sampling", "water quality/bacteria",
                                                                                                    ifelse(uf_TripDescription == "water quality monitoring ", "water quality",
                                                                                                           
                                                                                                          
                              ifelse(uf_TripDescription == "august 28", "hydrology", 
                                     ifelse(uf_TripDescription == "intensive bateria sampling", "intensive bacteria monitoring",
                                            ifelse(uf_TripDescription == "bacteria monitoring trip", "bateria sampling",
                                                   ifelse(uf_TripDescription == "intefrated riparian / groundwater", "integrated riparian / groundwater",
                                                          ifelse(uf_TripDescription == "hydro", "hydrology",
                                                                 ifelse(uf_TripDescription == "integrated riparian ", "integrated riparian", 
                                                                        ifelse(uf_TripDescription == "springs recon ", "springs recon",
                                                                               ifelse(uf_TripDescription == (str_detect(descFixes$uf_TripDescription, "annual repeat photo trip")), "TEST", 
                                                                                      uf_TripDescription))))))))))))))))))))))))))))))))))))) %>% 
  select(uf_TripDescription, uf_TripDescriptionFIX) 


descFixes <- descFixes %>% 
  mutate(uf_TripDescriptionFIX = ifelse(uf_TripDescription == (str_detect(descFixes$uf_TripDescription, "annual repeat photo trip")), "TEST", uf_TripDescription))

descFixes %>% 
  select(uf_TripDescriptionFIX) %>% distinct() %>% view()
