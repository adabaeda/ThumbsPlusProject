
library(RODBC) ###allows connection to db, excel, etc.
library (tidyverse) ###dplyr, tidyr, ggplot, stringr, and more
library(readxl) #upload a .xlxs
library(janitor)
library(here)


DMSandbox_ThumbsPlus <- odbcDriverConnect("driver=SQL Server; server=INPSCPNMS01\\DMSandbox, 50001; database=SCPN_ThumbsPlus_Photos; trusted_connection=yes;")
WR_PathandUDF <- sqlFetch(DMSandbox_ThumbsPlus, "view_WR_PathInfo_UDFInfo", stringsAsFactors = FALSE)
UF_Table <- sqlFetch(DMSandbox_ThumbsPlus, "UserFields", stringsAsFactors = FALSE)
#event <- sqlFetch(DMSandbox_ThumbsPlus, "tbl_Event", stringsAsFactors = FALSE)
close(DMSandbox_ThumbsPlus)

#-------------------------------------------------------------------------------
#removing columns that are always NA or contain no information (e.g., uf_estLocationAccuraryM = 0)

noNACols <- UF_Table %>% 
  remove_empty("cols") 

compare_df_cols(noNACols, UF_Table) %>%  view()

colsofInterest <- UF_Table %>% 
  remove_empty("cols") %>% 
  select(-uf_EstLocationAccuracyM)
names(colsofInterest) %>% view()


### ===========================================================================
#checking variables
noNACols %>% 
  select(uf_SiteID) %>% 
  filter(!is.na(uf_SiteID)) %>% distinct() %>% view()

noNACols %>% 
  select(uf_Ecosite) %>% 
  filter(!is.na(uf_Ecosite)) %>% distinct() %>% view()

noNACols %>% 
  select(uf_ParkCode)%>% 
  filter(!is.na(uf_ParkCode)) %>% distinct() %>% view()

noNACols %>% 
  select(uf_Photo_File_Name) %>% 
  filter(!is.na(uf_Photo_File_Name)) %>% view()

###==============================================================================             
# Check to see if there is any overlap between the values in TripDescription 
#and photonotes 

uf_CaptionValues <- noNACols %>% 
  select(uf_Caption) %>% 
  remove_empty("rows") %>% 
  distinct()
uf_PhotoNotesValues <- noNACols %>% 
  select(uf_PhotoNotes) %>% 
  remove_empty("rows") %>% 
  distinct() 
uf_TripDescriptionValues <- noNACols %>% 
  select(uf_TripDescription) %>% 
  remove_empty("rows") %>% 
  distinct()

noNACols %>% 
  select(uf_TripDescription, uf_PhotoNotes) %>% 
  filter(noNACols$uf_TripDescription %in% uf_PhotoNotesValues$uf_PhotoNotes) %>% view()

###==============================================================================


noNACols %>%
  select(idThumbUDF, uf_Copyright_Notice) %>%
  filter(!is.na(uf_Copyright_Notice)) %>% distinct() %>% view()

WR_PathandUDF %>% 
  select(fileName) %>% 
  distinct() %>% view()

noNACols %>%
  select(uf_PhotoNotes) %>%
  filter(!is.na(uf_PhotoNotes)) %>% distinct() %>% view()


duplicateFileNames <- WR_PathandUDF %>% 
  select(fileName) %>% 
  group_by(fileName) %>% tally() %>% 
  filter(!n == '1') %>% arrange(desc(n))

# write.table(duplicateFileNames, "DuplicatedWRPhotoNames.txt", sep = "\t",
#             col.names = TRUE)

EampleDupeFileName <- WR_PathandUDF %>% 
  select(idThumb,
         filePath,
         fileName) %>% 
  filter(fileName == 'DSC_0020.JPG') 

# write.table(EampleDupeFileName, "EampleDupeFileName.txt", sep = "\t",
#             col.names = TRUE)





























#investigating the 1282 difference
# WR_PathandUDF %>% 
#   filter(idThumb == idThumbUDF) %>% view() #9267 There are no mismatched idThumbUDFs
# 
# WR_PathandUDF %>% 
#   filter(is.na(idThumbUDF)) %>% view() #1327 null variables this matches the 9267 
# 
# turns out everything is okay!
