#
# :author: PN
# :date: 2024-07-19
# :license: GPL 2.0 or greater
#
# ice-detain/export/Makefile
#
#

.PHONY: all

all: \
	output/ice_detentions_fy11-24ytd.feather \
	output/ice_unique_stays_fy11-24ytd.feather \
	output/headcount_fy11-24ytd.csv.gz


clean: 
	-rm -r output/*

output/ice_detentions_fy11-24ytd.feather: \
	../unique-stays/output/ice_detentions_fy11-24ytd.feather
	mkdir -p input output
	cd input/ && ln -sf ../../unique-stays/output/ice_detentions_fy11-24ytd.feather .

output/ice_unique_stays_fy11-24ytd.feather: \
	../unique-stays/output/ice_unique_stays_fy11-24ytd.feather
	mkdir -p input output
	cd input/ && ln -sf ../../unique-stays/output/ice_unique_stays_fy11-24ytd.feather .

output/headcount_fy11-24ytd.csv.gz: \
	../headcount/output/headcount_fy11-24ytd.csv.gz
	mkdir -p input output
	cd input/ && ln -sf ../../headcount/output/headcount_fy11-24ytd.csv.gz .


# End.