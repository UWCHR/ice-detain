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
	output/headcount_fy11-24ytd.csv.gz

clean: 
	-rm -r output/*

output/headcount_fy11-24ytd.csv.gz: \
	src/headcount.R \
	../unique-stays/output/ice_detentions_fy11-24ytd.feather
	mkdir -p input output
	cd input/ && ln -sf ../../unique-stays/output/ice_detentions_fy11-24ytd.feather . 
	Rscript $< \
		--input=input/ice_detentions_fy11-24ytd.feather \
		--group='detention_facility_code' \
		--log=output/headcount.R.log \
		--output=output/headcount_fy11-24ytd.csv.gz

# End.