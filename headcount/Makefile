#
# :author: PN
# :date: 2024-07-19
# :license: GPL 2.0 or greater
#
# ice-detain/headcount/Makefile
#
#

.PHONY: all

all: \
	output/headcount_fy12-24ytd.csv.gz

clean: 
	-rm -r output/*

output/headcount_fy12-24ytd.csv.gz: \
	src/headcount.R \
	../concat/output/ice_detentions_fy12-24ytd.csv.gz .
	mkdir -p output
	Rscript $< \
		--input=../concat/output/ice_detentions_fy12-24ytd.csv.gz \
		--group='detention_facility_code' \
		--log=output/headcount.R.log \
		--output=$@

# End.