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
	output/ice_detentions_fy12-24ytd.csv.gz \
	output/headcount_fy12-24ytd.csv.gz


clean: 
	-rm -r output/*

output/ice_detentions_fy12-24ytd.csv.gz: \
	../unique-stays/output/ice_detentions_fy12-24ytd.csv.gz
	mkdir -p input output
	cd input/ && ln -sf ../../unique-stays/output/ice_detentions_fy12-24ytd.csv.gz .
	cd output/ && ln -sf ../input/ice_detentions_fy12-24ytd.csv.gz .

output/headcount_fy12-24ytd.csv.gz: \
	../headcount/output/headcount_fy12-24ytd.csv.gz
	mkdir -p input output
	cd input/ && ln -sf ../../headcount/output/headcount_fy12-24ytd.csv.gz .
	cd output/ && ln -sf ../input/headcount_fy12-24ytd.csv.gz .


# End.