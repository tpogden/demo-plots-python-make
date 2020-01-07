
.DEFAULT_GOAL := all

# Plots -----------------------------------------------------------------------

PLOTS_DIR = src/plots/
PLOTS_FLAGS = --tex --start 2015-01-04 --end 2017-01-03

PLOTS_PY = $(wildcard $(PLOTS_DIR)plot_*.py)
PLOTS_PDF = $(PLOTS_PY:.py=.pdf)
PLOTS_PNG = $(PLOTS_PY:.py=.png)

$(PLOTS_DIR)%.pdf: $(PLOTS_DIR)%.py 
	python $< --pdf $(PLOTS_FLAGS)

$(PLOTS_DIR)%.png: $(PLOTS_DIR)%.py 
	python $< --png $(PLOTS_FLAGS)

plots_pdf: $(PLOTS_PDF)
plots_png: $(PLOTS_PNG)
plots: plots_pdf plots_png

# Tables ----------------------------------------------------------------------

TABLES_DIR = src/tables/

TABLES_PY = $(wildcard $(TABLES_DIR)table_*.py)
TABLES_TEX = $(TABLES_PY:.py=.tex)

$(TABLES_DIR)%.tex: $(TABLES_DIR)%.py 
	python $< $(PLOTS_FLAGS)

tables_tex: $(TABLES_TEX)
tables: tables_tex

# Reports ---------------------------------------------------------------------

REPORTS_DIR = reports/
FIGS_DIR = $(REPORTS_DIR)/figs/

# Take the pdfs in PLOTS_PDF and change the path from PLOTS_DIR to FIGS_DIR
REPORT_FIGS_PDF = $(patsubst $(PLOTS_DIR)%, $(FIGS_DIR)%, $(PLOTS_PDF))

# Take the .tex in TABLES_TEX and change the path from PLOTS_DIR to FIGS_DIR
REPORT_TABLES_TEX = $(patsubst $(TABLES_DIR)%, $(FIGS_DIR)%, $(TABLES_TEX))

# Copy figures	
$(FIGS_DIR)%.pdf: $(PLOTS_DIR)%.pdf
	cp -f $< $(FIGS_DIR)

# Copy tables
$(FIGS_DIR)%.tex: $(TABLES_DIR)%.tex
	cp -f $< $(FIGS_DIR)

report_figs_pdf: $(REPORT_FIGS_PDF) plots_pdf
report_tables_tex: $(REPORT_TABLES_TEX) tables_tex

report_figs: report_figs_pdf report_tables_tex

REPORTS_TEX = $(wildcard $(REPORTS_DIR)*.tex)
REPORTS_PDF = $(REPORTS_TEX:.tex=.pdf)

$(REPORTS_DIR)%.pdf: $(REPORTS_DIR)%.tex
	pushd $(REPORTS_DIR); pdflatex $(<F); popd 

paper_pdf: $(REPORTS_DIR)paper.pdf
slides_pdf: $(REPORTS_DIR)slides.pdf

reports_pdf: report_figs $(REPORTS_PDF) 

# All -------------------------------------------------------------------------

.PHONY : all
all: reports_pdf 

# Clean -----------------------------------------------------------------------

clean_plots:
	rm -rf src/plots/plot_*.png
	rm -rf src/plots/plot_*.pdf

clean_tables:
	rm -rf src/tables/table_*.tex

clean_reports:
	rm -rf reports/figs/plot_*.pdf
	rm -rf reports/*.pdf

.PHONY: clean
clean: clean_plots clean_reports