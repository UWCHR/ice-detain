# ---
# title: "Generate ICE detention headcounts"
# author:
# - "[Phil Neff](https://github.com/philneff)"
# date: 2024-02-13
# copyright: UWCHR, GPL 3.0
# ---

library(pacman)
p_load(argparse, logger, tidyverse, arrow, lubridate, zoo, digest)

options(dplyr.summarise.inform = FALSE)

parser <- ArgumentParser()
parser$add_argument("--input", default = "headcount/input/ice_detentions_fy11-24ytd.csv.gz")
parser$add_argument("--group", default = "detention_facility_code")
parser$add_argument("--log", default = "headcount/output/headcount.R.log")
parser$add_argument("--output", default = "headcount/output/headcount_fy11-24ytd.csv.gz")
args <- parser$parse_args()

# append log file
f = args$log
log_appender(appender_file(f))

col_types <- cols(
  "stay_book_in_date_time" = col_datetime(format =  "%Y-%m-%dT%H:%M:%SZ"),
  "detention_book_in_date_and_time" = col_datetime(format =  "%Y-%m-%dT%H:%M:%SZ"),
  "detention_book_out_date_time" = col_datetime(format =  "%Y-%m-%dT%H:%M:%SZ"),
  "stay_book_out_date_time" = col_datetime(format =  "%Y-%m-%dT%H:%M:%SZ"),
)

df <- read_delim(args$input, col_types = col_types)

# problems(df)

log_info("Total rows in: {nrow(df)}")

# skimr::skim(df)

timeline_start <- min(as.Date(df$detention_book_in_date_and_time), na.rm=TRUE)
timeline_end <- max(as.Date(df$detention_book_out_date_time), na.rm=TRUE)
timeline <- seq(timeline_start, timeline_end, by='day')

group_vars <- unlist(str_split(args$group, ", "))

for (i in length(group_vars)) {
  var <- group_vars[i]
  df[[var]] <- factor(df[[var]], levels = sort(unique(df[[var]])))
}


# Fill `detention_book_out_date_time` with date of release of data for minimum stay lengths

max_date <- max(df$detention_book_out_date_time, na.rm=TRUE)

df <- df %>% 
  mutate(detention_book_out_date_time = case_when(is.na(detention_book_out_date_time) ~ max_date,
                                                  TRUE ~ detention_book_out_date_time))

headcounter <- function(date, group_vars) {
  
  in_range <- df[df$detention_book_in_date_and_time <= date & df$detention_book_out_date_time >= date,]
  
  in_range %>% 
    group_by(across(all_of(group_vars))) %>% 
    summarize(n = n()) %>% 
    complete(fill = list(n = 0)) %>% 
    mutate(date=date)
  
  }

system.time({headcount <- lapply(timeline, headcounter, group_vars=group_vars)})

headcount_data <- map_dfr(headcount, bind_rows)

write_delim(headcount_data, args$output, delim='|')

# END.