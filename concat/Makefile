#
# :author: PN
# :date: 2024-07-22
# :license: GPL 2.0 or greater
#
# ice-detain/concat/Makefile
#
#

all: \
	output/ice_detentions_fy11-24ytd.csv.gz
	
PHONY: all

# UWCHR 2024 lawsuit production data

output/ice_detentions_fy11-24ytd.csv.gz: \
	src/concat.R \
	../import/frozen/ICE_Detentions_FY2011_and_Prior_LESA-STU_FINAL-Redacted.csv.gz \
	../import/frozen/ICE_Detentions_FY2012_LESA-STU_FINAL-Redacted.csv.gz \
	../import/frozen/ICE_Detentions_FY2013_LESA-STU_FINAL-Redacted.csv.gz \
	../import/frozen/ICE_Detentions_FY2014_LESA-STU_FINAL-Redacted.csv.gz \
	../import/frozen/ICE_Detentions_FY2015_LESA-STU_FINAL-Redacted.csv.gz \
	../import/frozen/ICE_Detentions_FY2016_LESA-STU_FINAL-Redacted.csv.gz \
	../import/frozen/ICE_Detentions_FY2017_LESA-STU_FINAL-Redacted.csv.gz \
	../import/frozen/ICE_Detentions_FY2018_LESA-STU_FINAL-Redacted.csv.gz \
	../import/frozen/ICE_Detentions_FY2019_LESA-STU_FINAL-Redacted.csv.gz \
	../import/frozen/ICE_Detentions_FY2020_LESA-STU_FINAL-Redacted.csv.gz \
	../import/frozen/ICE_Detentions_FY2021_LESA-STU_FINAL-Redacted.csv.gz \
	../import/frozen/ICE_Detentions_FY2022_LESA-STU_FINAL-Redacted.csv.gz \
	../import/frozen/ICE_Detentions_FY2023_LESA-STU_FINAL-Redacted.csv.gz \
	../import/frozen/ICE_Detentions_FY2024_LESA-STU_FINAL-Redacted.csv.gz
	mkdir -p input output
	cd input/ && ln -sf ../../import/frozen/* . 
	Rscript $< \
		--log=output/concat.R.log \
		--output=$@

# End.