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
	input/ice_detentions_fy11-24ytd.csv.gz \
	output/headcount_fy11-24ytd.csv.gz

clean: 
	-rm -r output/*

input/ice_detentions_fy11-24ytd.csv.gz: \
	../concat/output/ice_detentions_fy11-24ytd.csv.gz .
	mkdir -p input
	cd input/ && ln -sf ../../import/output/ice_detentions_fy11-24ytd.csv.gz .

output/headcount_fy11-24ytd.csv.gz: \
	src/headcount.R \
	input/ice_detentions_fy11-24ytd.csv.gz
	mkdir -p output
	cd input/ && ln -sf ../../concat/output/ice_detentions_fy11-24ytd.csv.gz . 
	Rscript $< \
		--input=input/ice_detentions_fy11-24ytd.csv.gz \
		--group='detention_facility_code' \
		--log=output/headcount.R.log \
		--output=$@

# End.