# ---
# title: "Generate ICE detention headcounts"
# author:
# - "[Phil Neff](https://github.com/philneff)"
# date: 2024-02-13
# copyright: UWCHR, GPL 3.0
# ---

library(pacman)
p_load(argparse, logger, tidyverse, arrow, lubridate, zoo, digest)

parser <- ArgumentParser()
parser$add_argument("--input", default = "headcount/input/ice_detentions_fy11-24ytd.feather")
parser$add_argument("--group", default = "detention_facility_code")
parser$add_argument("--log", default = "headcount/output/headcount.R.log")
parser$add_argument("--output", default = "headcount/output/headcount_fy11-24ytd.csv.gz")
args <- parser$parse_args()

# append log file
f = args$log
log_appender(appender_file(f))

df <- as.data.frame(read_feather(args$input))

# problems(df)

log_info("Total rows in: {nrow(df)}")

# skimr::skim(df)

min_date <- min(df$stay_book_in_date_time, na.rm=TRUE)
max_date <- max(df$stay_book_out_date_time, na.rm=TRUE)

timeline <- seq(min_date, max_date, by='day')

# Dataframe setup: these next two statements could be moved into `headcounter`
# if we want to be able to pass in arbitrary dataframe
df[[args$group]] <- factor(df[[args$group]], levels = sort(unique(df[[args$group]])))

# Fill `detention_book_out_date_time` with date of release of data for minimum stay lengths
df <- df %>% 
  mutate(detention_book_out_date_time = case_when(is.na(detention_book_out_date_time) ~ max_date,
                                                  TRUE ~ detention_book_out_date_time))

# Returns NAs if missing `detention_book_out_date_time`
headcounter <- function(date, var=var) {
  df[df$detention_book_in_date_and_time <= date & df$detention_book_out_date_time >= date,] %>% 
  count(.data[[var]]) %>% 
  complete(.data[[var]], fill = list(n = 0)) %>% 
  arrange(.data[[var]]) %>% 
  mutate(date=date)
  }

system.time({headcount <- lapply(timeline, headcounter, var=args$group)})

headcount_data <- map_dfr(headcount, bind_rows)

stopifnot(sum(is.na(headcount_data[[args$group]])) == 0)

write_delim(headcount_data, args$output, delim='|')

# END.