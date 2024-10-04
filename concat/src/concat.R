# ---
# title: "Concat ICE detention datasets"
# author:
# - "[Phil Neff](https://github.com/philneff)"
# date: 2024-02-13
# copyright: UWCHR, GPL 3.0
# ---

library(pacman)
p_load(argparse, logger, tidyverse, arrow, lubridate, zoo, digest)

parser <- ArgumentParser()
parser$add_argument("--log", default = "concat/output/panel.log")
parser$add_argument("--output", default = "concat/output/ice_detentions_fy11-24ytd.feather")
args <- parser$parse_args()

# append log file
f = args$log
# log_formatter(formatter_data_frame)
log_appender(appender_file(f))

input_dir <- here::here('concat/input')

filenames <- c(
              "ICE_Detentions_FY2011_and_Prior_LESA-STU_FINAL-Redacted.csv.gz",
              "ICE_Detentions_FY2012_LESA-STU_FINAL-Redacted.csv.gz",
              "ICE_Detentions_FY2013_LESA-STU_FINAL-Redacted.csv.gz",
              "ICE_Detentions_FY2014_LESA-STU_FINAL-Redacted.csv.gz",
              "ICE_Detentions_FY2015_LESA-STU_FINAL-Redacted.csv.gz",
              "ICE_Detentions_FY2016_LESA-STU_FINAL-Redacted.csv.gz",
              "ICE_Detentions_FY2017_LESA-STU_FINAL-Redacted.csv.gz",
              "ICE_Detentions_FY2018_LESA-STU_FINAL-Redacted.csv.gz",
              "ICE_Detentions_FY2019_LESA-STU_FINAL-Redacted.csv.gz",
              "ICE_Detentions_FY2020_LESA-STU_FINAL-Redacted.csv.gz",
              "ICE_Detentions_FY2021_LESA-STU_FINAL-Redacted.csv.gz",
              "ICE_Detentions_FY2022_LESA-STU_FINAL-Redacted.csv.gz",
              "ICE_Detentions_FY2023_LESA-STU_FINAL-Redacted.csv.gz",
              "ICE_Detentions_FY2024_LESA-STU_FINAL-Redacted.csv.gz"
              )

col_types <- cols(
  "Stay Book In Date Time" = col_datetime(format = "%m/%d/%Y %H:%M"),
  "Detention Book In Date And Time" = col_datetime(format = "%m/%d/%Y %H:%M"),
  "Detention Book Out Date Time" = col_datetime(format = "%m/%d/%Y %H:%M"),
  "Stay Book Out Date Time" = col_datetime(format = "%m/%d/%Y %H:%M"),
  "Birth Country PER" = col_character(),
  "Birth Country ERO" = col_character(),
  "Citizenship Country" = col_character(),
  "Race" = col_character(),
  "Ethnic" = col_character(),
  "Gender" = col_character(),
  "Birth Date" = col_character(),
  "Birth Year" = col_integer(),
  "Entry Date" = col_date(format = "%m/%d/%Y"),
  "Entry Status" = col_character(),
  "Most Serious Conviction (MSC) Criminal Charge Category" = col_character(),
  "MSC Charge" = col_character(),
  "MSC Charge Code" = col_character(),
  "MSC Conviction Date" = col_character(),
  "MSC Sentence Days" = col_integer(),
  "MSC Sentence Months" = col_integer(),
  "MSC Sentence Years" = col_integer(),
  "MSC Crime Class" = col_character(),
  "Case Threat Level" = col_character(),
  "Apprehension Threat Level" = col_character(),
  "Final Program" = col_character(),
  "Detention Facility Code" = col_character(),
  "Detention Facility" = col_character(),
  "Area of Responsibility" = col_character(),
  "Docket Control Office" = col_character(),
  "Detention Release Reason" = col_character(),
  "Stay Release Reason" = col_character(),
  "Alien File Number" = col_character(),
  "Anonymized Identifier" = col_character()
)

## Compact expansion of dataframe from list of filenames

print(paste("Reading input files from", input_dir))

df <- data.frame(filename = filenames) %>%
  reframe(read_delim(here::here(input_dir, filename),
                     delim='|',
                     skip=6,
                     col_types = col_types),
          .by=filename)

## Use this instead if you want `problems()` output for each input
## Few issues related to date parsing in `msc_conviction_date`

# df <- read_delim(here::here(input_dir, filenames[1]),
#                  delim='|',
#                  skip=6,
#                  col_types = col_types)
#
# p <- problems(df)
# print(p)
#
# log_info("{filenames[1]} rows in: {nrow(df)}")
#
# for (i in 2:length(filenames)) {
#   print(filenames[i])
#   df2 <- read_delim(here::here(input_dir, filenames[i]),
#                  delim='|',
#                  skip=6,
#                  col_types = col_types)
#
#   log_info("{filenames[i]} rows in: {nrow(df2)}")
#
#   p <- problems(df2)
#   print(p)
#
#   df <- rbind(df, df2)
#
# }

log_info("Total rows in: {nrow(df)}")

log_info("Column names in: {names(df)}")

print("Standardizing column names")

names(df) %<>% stringr::str_replace_all("\\s","_") %>% tolower

df <- df %>%
  mutate(rowid = row_number()) %>%
  group_by(filename) %>%
  mutate(file_rowid = row_number()) %>%
  ungroup()

print("Dropping records missing `anonymized_identifier`")

predrop <- nrow(df)

df <- df %>% 
  filter(!is.na(anonymized_identifier))

postdrop <- nrow(df)

log_info("Dropped {predrop - postdrop} records missing `anonymized_identifier`")

vdigest <- Vectorize(digest)

print("Generating record/stay hash ids")

df <- df %>% rowwise() %>% 
  unite(allCols, !c(filename, rowid, file_rowid), sep = "", remove = FALSE) %>% 
  unite(stayCols, c(anonymized_identifier, stay_book_in_date_time), sep = "", remove = FALSE) %>% 
  mutate(recid = vdigest(allCols),
         stayid = vdigest(stayCols)) %>%
  select(-c(allCols, stayCols))

# skimr::skim(df)

print("Dropping duplicate records")

predrop <- nrow(df)

df <- df %>%
  distinct(recid, .keep_all = TRUE)

postdrop <- nrow(df)

log_info("Dropped {predrop - postdrop} duplicate rows")

log_info("Column names out: {names(df)}")

log_info("Rows out: {nrow(df)}")

log_info("Output dir: {args$output}")

print(paste("Writing output to", here::here(args$output)))

write_delim(df, args$output, delim='|')

# END.