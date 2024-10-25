# ---
# title: "Output dataset with additional analysis fields per stay"
# author:
# - "[Phil Neff](https://github.com/philneff)"
# date: 2024-02-27
# copyright: UWCHR, GPL 3.0
# ---

library(pacman)
p_load(argparse, logger, tidyverse, arrow, lubridate, zoo, digest)

parser <- ArgumentParser()
parser$add_argument("--input", default = "unique-stays/input/ice_detentions_fy12-24ytd.csv.gz")
parser$add_argument("--log", default = "unique-stays/output/unique-stays.R.log")
parser$add_argument("--output", default = "unique-stays/output/ice_detentions_fy12-24ytd.csv.gz")
args <- parser$parse_args()

# append log file
f = args$log
log_appender(appender_file(f))

print("Reading data")

df <- data.table::fread(file = args$input,
                        sep = '|')

data.table::setDF(df)

log_info("Total rows in: {nrow(df)}")

# skimr::skim(df)

max_date <- as.Date("2024-01-05")

pre_nrow <- nrow(df)

print("Calculation 1 (no group)")
# Calculate both absolute stay/placement lengths (with NA values for incomplete stays)
# and minimum stay/placement lengths based on release date of dataset
system.time({df <- df %>% 
  mutate(stay_length = difftime(stay_book_out_date_time,
            stay_book_in_date_time, unit='days'),
         placement_length = difftime(detention_book_out_date_time,
            detention_book_in_date_and_time, unit='days'),
         stay_length_min = difftime(replace_na(stay_book_out_date_time, max_date),
            stay_book_in_date_time, unit='days'),
         placement_length_min = difftime(replace_na(detention_book_out_date_time, max_date),
            detention_book_in_date_and_time, unit='days')
         )
    }
  )

stopifnot(pre_nrow == nrow(df))
pre_nrow <- nrow(df)

print("Calculation 2 (grouped by `anonymized_identifier`)")
# Count total of distinct stays and placements per ID
# Flag if currently detained at time of release of dataset
# Enumerate successive stays
system.time({df <- df %>% 
  filter(!is.na(anonymized_identifier)) %>% 
  group_by(anonymized_identifier) %>% 
  arrange(stay_book_in_date_time, detention_book_in_date_and_time) %>%
  mutate(total_stays = n_distinct(stay_book_in_date_time),
         total_placements = n(),
         current_stay = is.na(stay_book_out_date_time),
         current_placement = is.na(detention_book_out_date_time),
         stay_count = data.table::rleid(stay_book_in_date_time)) %>% 
  ungroup()
    }
  )

stopifnot(pre_nrow == nrow(df))
pre_nrow <- nrow(df)

print("Calculation 3 (grouped by `stayid`)")
# Enumerate successive placements per stay
# Capture first, last, and longest facility per stay
# Flag last and longest placement
system.time({df <- df %>% 
  group_by(stayid) %>% 
  arrange(stay_book_in_date_time, detention_book_in_date_and_time) %>%
  mutate(placement_count = data.table::rleid(recid),
         stay_placements = n(),
         first_facil = detention_facility_code[[1]], 
         last_facil = detention_facility_code[[length(detention_facility_code)]],
         longest_placement_facil = detention_facility_code[which.max(placement_length_min)],
         last_placement = placement_count == stay_placements,
         longest_placement = placement_length_min == max(placement_length_min)
         ) %>% 
  ungroup()})

stopifnot(pre_nrow == nrow(df))
pre_nrow <- nrow(df)

detloc_aor <- df %>% 
  distinct(detention_facility_code, area_of_responsibility) %>% 
  arrange(detention_facility_code, area_of_responsibility)

detloc_aor_list <- as.list(detloc_aor$detention_facility_code)

names(detloc_aor_list) <- detloc_aor$area_of_responsibility

log_info("Rows out: {nrow(df)}")

df$first_aor <- names(detloc_aor_list)[match(df$first_facil, detloc_aor_list)]
df$last_aor <- names(detloc_aor_list)[match(df$last_facil, detloc_aor_list)]
df$longest_aor <- names(detloc_aor_list)[match(df$longest_placement_facil, detloc_aor_list)]

print("Write out dataset")
# Write out dataset with additional analysis cols
system.time({write_delim(df, args$output, delim='|')})

# END.