#
# :author: PN
# :date: 2024-07-19
# :license: GPL 2.0 or greater
#
# ice-detain/unique-stays/Makefile
#
#

.PHONY: all

all: \
	output/ice_unique_stays_fy11-24ytd.csv.gz

clean: 
		-rm -r output/*

output/ice_unique_stays_fy11-24ytd.csv.gz: \
	src/unique-stays.R \
	../concat/output/ice_detentions_fy11-24ytd.csv.gz
	mkdir -p input output
	cd input/ && ln -sf ../../concat/output/* . 
	Rscript $< \
		--input=input/ice_detentions_fy11-24ytd.csv.gz \
		--log=output/unique-stays.R.log \
		--unique_output=output/ice_unique_stays_fy11-24ytd.csv.gz \
		--full_output=output/ice_detentions_fy11-24ytd.csv.gz

# End.