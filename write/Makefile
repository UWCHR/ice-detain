#
# Authors:     PN
# Maintainers: PN
# Copyright:   2024, UWCHR, GPL v2 or later
# ============================================
# ice-detain/write/Makefile

.PHONY: clean all

all: \
	output/index.html

clean:
	rm -r output/*

output/index.html: \
		note/index.Rmd \
		../export/output/ice_detentions_fy12-24ytd.csv.gz \
		../export/output/headcount_fy12-24ytd.csv.gz
	mkdir -p input output
	cd input && ln -sf ../../export/output/*.csv.gz .
	Rscript -e "rmarkdown::render('note/index.Rmd', 'html_document')"
	mv note/index.html output/

# done.
