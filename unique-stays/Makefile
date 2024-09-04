#
# :author: PN
# :date: 2024-07-19
# :license: GPL 2.0 or greater
#
# ice-detain/unique-stays/Makefile
#
#

all: \
	output/ice_unique_stays_fy11-24ytd.feather

clean: 
		-rm -r output/*

PHONY: all

output/ice_unique_stays_fy11-24ytd.feather: \
	src/unique-stays.R \
	../concat/output/ice_detentions_fy11-24ytd.feather
	mkdir -p input output
	cd input/ && ln -sf ../../concat/output/* . 
	Rscript $< \
		--input=input/ice_detentions_fy11-24ytd.feather \
		--log=output/unique-stays.R.log \
		--unique_output=output/ice_unique_stays_fy11-24ytd.feather \
		--full_output=output/ice_detentions_fy11-24ytd.feather

# End.