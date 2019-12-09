
# Plots -----------------------------------------------------------------------

# TODO: encode that the json file is an input 

PLOTS_DIR = src/plots/
PLOTS_FLAGS = --tex

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

# Reports ---------------------------------------------------------------------

FIGS_DIR = reports/figs/

# Take the pdfs in PLOTS_PDF and change the path from PLOTS_DIR to FIGS_DIR
REPORT_FIGS_PDF = $(patsubst $(PLOTS_DIR)%, $(FIGS_DIR)%, $(PLOTS_PDF))

# Copy figures	
$(FIGS_DIR)%.pdf: $(PLOTS_DIR)%.pdf
	cp -f $< $(FIGS_DIR)

report_figs_pdf: $(REPORT_FIGS_PDF)

# All -------------------------------------------------------------------------

all: report_figs_pdf plots

# Clean -----------------------------------------------------------------------

clean: clean_plots clean_reports

clean_plots:
	rm -rf src/plots/plot_*.png
	rm -rf src/plots/plot_*.pdf

clean_reports:
	rm -rf report/figs/plot_*.pdf