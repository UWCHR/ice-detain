# ICE immigration detention data

This repository processes and analyzes U.S. Immigration and Customs Enforcement (ICE) data released pursuant to FOIA requests by the University of Washington Center for Human Rights.

The datasets analyzed here were released by ICE's Enforcement and Removal Operations (ERO) Law Enforcement Systems and Analysis Division (LESA); the datasets represent person-by-person, facility-by-facility detention history records from 2011-10-01 through 2024-01-04.

## FOIA request

> We are seeking person-by-person, facility-by-facility detention history records from the ERO LESA Statistical Tracking Unit of all people in immigration detention nationwide from 10/1/2011 to date, in XLS, XLSX, or CSV spreadsheet format; including but not limited to the following fields and including any related definitions, legends, or codebooks: - Unique subject identifier: Non-personally identifiable sequence number or other designation to identify records relating to the same subject. (Such information was previously released pursuant to FOIA 2015-ICFO-95379.) - Detention Stay Book In Date - Book In Date And Time - Book Out Date And Time - Detention Stay Book Out Date - Birth Country - Citizenship Country - Race - Ethnicity - Gender - Age at Book In - Entry Date - Entry Status - LPR Yes No - Most Serious Criminal Conviction (MSCC) - MSCC Code - MSCC Conviction Date - MSCC Sentence Days - MSCC Sentence Months - MSCC Sentence Years - Aggravated Felon - Aggravated Felon Type - Rc Threat Level - Apprehension COL - 287(g) Arrest - Border Patrol Arrest or Arresting Agency - Book In After Detainer - Apprehension Program - Initial Detention Facility Code - Initial Detention Facility - History Detention Facility Code - History Detention Facility - Order of Detention - History Book In DCO - History Book Out Date And Time - History Release Reason - Detainer Prepare Date - Detainer Prior to Bookin Date (Yes/No) - Detainer Threat Level - Detainer Detention Facility - Detainer Detention Facility Code.
> We are not providing third party consent forms for all those whose data would be included and therefore understand that as a result, personally-identifiable information will be redacted to protect their privacy. However, the FOIA requires that all segregable information be provided to requesters, and personally-identifiable information is segregable from the remainder of this information. Such information was previously released pursuant to FOIA 2015-ICFO-95379 and FOIA 2019-ICFO-10844.

## Respository description

### Data

Large data files are excluded from this repository; data associated with this repository can be obtained here: https://drive.google.com/drive/folders/1Guhtpv80sh2FJ90-t1GyCtNzSa0Jsvzr?usp=drive_link

To execute tasks in this repository, first download the data files linked above and ensure they are stored in the indicated directory within the Git repository: original, untransformed datasets are stored in `import/input/`; compressed, CSV-formatted files are stored in `import/frozen/`.

Final datasets with minimal cleaning and standardization are stored/generated in `export/output/`. Users interested in reviewing the final datasets without executing the code contained in this repository can find export datasets as of Oct. 15, 2024 at the following link: https://drive.google.com/drive/folders/1OQLU7IzhbodsrD2wZm-5fV57UIsnOW4x?usp=drive_link

### Structure

This project uses "Principled Data Processing" techniques and tools developed by [@HRDAG](https://github.com/HRDAG); see for example ["The Task Is A Quantum of Workflow."](https://hrdag.org/2016/06/14/the-task-is-a-quantum-of-workflow/)

- `import/`: Convenience task for file import; original Excel files in `input/` are saved as compressed csv files in `frozen/`.
- `concat/`: Concatenates individual input files, standardizes column names, drops records missing `anonymized_identifier`, and trivial number of duplicated records, logging stats to `output/concat.log`; adds hash record and stay identifiers, and record sequence.
- `unique-stays/`: Performs various calculations per placement, individual, and stay and adds relevant fields to facilitate calculations which require unique stay records (e.g. Average Length of Stay).
- `headcount/`: Calculates daily detention headcount by given characteristic, e.g. per facility, by gender/nationality. Slow when applied to full dataset, could likely be optimized/improved.
- `export/`: Convenience task, final datasets in `output/`.
- `share/`: Resources potentially used by multiple tasks but not created or transformed in this repo.
- `write/` - Generates descriptive notebooks for publication.
- `docs/` - Descriptive notebooks published at: https://uwchr.github.io/ice-detain/

## Data description

Each row represents an individual detention placement record per person per facility. Consecutive records represent successive detention placements in an overall detention stay of one or more placements. Individual people can experience one or more detention stay. In some cases, an individual's `stay_book_in_date_time` does not coincide with the `detention_book_in_date_and_time` of the individual's first detention placement; this is most common in records from the earlier period of the data (FY2011 and prior). Records with missing `stay_book_out_date_time` and `detention_release_reason`/`stay_release_reason` values represent individuals whose detention stays were ongoing at the time the dataset was generated.

This dataset lacks information regarding detention facility characteristics such as precise location (other than ICE `area_of_responsibility`) or facility type which may be relevant for detailed analysis.

### Original data fields

Data was released without any data dictionary or field definitions; therefore we have had to infer significance of some values.

- `stay_book_in_date_time`: Detention stay start date
- `detention_book_in_date_and_time`: Detention placement start date (per facility)
- `detention_book_out_date_time`: Detention placement end date; missing values represent current placement at time of release of data
- `stay_book_out_date_time`: Detention stay end date, missing values represent current stay at time of release of data
- `birth_country_per`: Individual's country of birth, unclear how different from `birth_country_ero`
- `birth_country_ero`: Individual's country of birth, unclear how different from `birth_country_per`
- `citizenship_country`: Individual's country of citizenship
- `race`: Individual's race (Largely missing)
- `ethnic`: Individual's ethnicity (Largely missing)
- `gender`: Individual's gender
- `birth_date`: Redacted
- `birth_year`: Individual year of birth
- `entry_date`: Individual's entry date
- `entry_status`: Individual's entry status
- `most_serious_conviction_(msc)_criminal_charge_category`: Most serious conviction category
- `msc_charge`: Most serious conviction charge
- `msc_charge_code`: Most serious conviction charge code
- `msc_conviction_date`: Most serious conviction date
- `msc_sentence_days`: Most serious conviction sentence length (days)
- `msc_sentence_months`: Most serious conviction sentence length (months)
- `msc_sentence_years`: Most serious conviction sentence length (years)
- `msc_crime_class`: Most serious conviction crime class
- `case_threat_level`: Redacted
- `apprehension_threat_level`: Redacted
- `final_program`: Appears to represent DHS division responsible for decision to detain
- `detention_facility_code`: Detention facility code
- `detention_facility`: Detention facility full title
- `area_of_responsibility`: ICE field office responsible for detention facility
- `docket_control_office`: ICE docket control office
- `detention_release_reason`: Missing values indiciate ongoing detention
- `stay_release_reason`: Missing values indiciate ongoing detention
- `alien_file_number`: Redacted
- `anonymized_identifier`: Anonymized unique individual identifier

### Additional analysis fields

- `filename`: Original data filename
- `recid`: Unique record identifier based on original data fields
- `stayid`: Unique stay identifier based on `anonymized_identifier` and `stay_book_in_date_time`
- `rowseq`: Record sequence across input files
- `file_rowseq`: Record sequece within input file
- `stay_length`: Length of stay (missing for ongoing stays)
- `placement_length`: Length of placement (missing for ongoing placement)
- `stay_length_min`: Minimum length of stay (as of 2024-01-15, date of release of dataset)
- `placement_length_min`: Minimum length of placement (as of 2024-01-15, date of release of dataset)
- `total_stays`: Total completed/ongoing detention stays per individual
- `total_placements`: Total completed/ongoing detention placements per individual
- `current_stay`: Does row relate to a current detention stay?
- `stay_count`: Consecutive identifier per stay per person
- `placement_count`: Consecutive identifier per placement per person
- `stay_placements`: Consecutive identifier per placement per stay per person
- `first_facil`: Stay book-in facility
- `last_facil`: Stay book-out facility
- `longest_placement_facil`: Longest placement facility per stay

## Acknowledgements

UWCHR is grateful to [Prof. David Hausman](https://www.david-hausman.com/) and the ACLU of California for obtaining and sharing a previous verison of this dataset; and to [Prof. Abraham Flaxman](https://globalhealth.washington.edu/faculty/abraham-flaxman) for assistance in analyzing a previous version of this dataset.

## To-do

- [ ] Bring in ICE detention facility characteristics and related notes, analyze how many facilities here are represented
- [ ] Test whether possible to generate headcount as vector of detention dates and record/individual hash values so that we can easily join in other characteristics: would this be too cumbersome?
- [ ] Instead of generating separate dataset in `unique_stays`, flag final placement per stay in full dataset for simple filtering.
- [x] Create `docs/` and associated tasks
- [x] Create `stayid` key value for record blocs representing unique stays (combination of `anonymized_identifier`, `stay_book_in_date_time`).
