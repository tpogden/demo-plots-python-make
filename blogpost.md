
A common task of scientific projects is creating plots and tables to visualise
data and adding these plots and tables to some output documents, for example a
paper, thesis or slide deck. In a typical workflow, we might have some input
data which is processed by Python scripts and output in image files. These
images are then referenced in a TeX file to be rendered as a PDF.

When you start working on projects like this, all of these steps will be manual.
What happens then if the data is updated? You have to re-run the scripts,
remembering and subtelties of the environment in which they will run
successfully. Then you manually save the plots into a folder. Then you manually
copy them into another folder to be referenced from the TeX file. Then you
manually re-run the TeX renderer. Many manual steps means many possibilities for
errors and many places for reproducibility to be broken if you forget to
document the steps exactly. This is where someone comes to you six months later
because they can't reproduce the output and you say 'Oh, I forgot to say this
package has to be in the environment.' or 'Oh, I forgot to say you need [x]
added to the PYTHONPATH environment variable for that to work.' And that someone
is most likely to be yourself.

We solve this by writing the steps down exactly in code. And the most well-used
tool for this kind of thing is `make`. You might think of `make` as a tool for
building code, but really it just expresses dependencies of files so it is
perfect for automating our tasks.

<aside>
This is not a guide to make. The internet will help you with that, or the man
doc.
</aside>

I'm going to illustrate how I typically do this kind of thing with a demo
project with a `Makefile` and I'll go through the steps here. The demo project
is on Github, including the rendered outputs.

The data is from London Bikeshare dataset on Kaggle, but it's just for demo
purposes.

## Automating Plots

The plots we're going to produce in this project are written as Python scripts
using `matplotlib`. We'll put all plot scripts in a `src/plots` folder. In there,
every plot script is prefixed with `plot_`. In our demo project we have

```
src/plots/
    +--plot_daily_journeys.py
    +--plot_trips_vs_temp.py
```

One thing I would highly recommend is to have _one_ script for every _one_ plot
you want to show in the final outputs. Even if the script is exactly the same
apart from a parameter or two. This often means a lot of repeat code, which you
would usually want to avoid by abstraction. Resist the urge! In data
visualisation you want to tailor each plot precisely, even if it's just
something like the location of a legend or some axis ticks. One script, one
plot.

The plot scripts all get boilerplate code at the top to parse arguments we pass
in at the command line. 

```py
parser = argparse.ArgumentParser(description="Plotting script.")
parser.add_argument('--pdf', default=False, action="store_true",
    help="Output PDF file.")
parser.add_argument('--png', default=False, action="store_true",
    help="Output PNG file.")
parser.add_argument("--show", default=False, action="store_true",
    help="Show plot in GUI.")
opts, unknown = parser.parse_known_args()
print('opts:', opts)
```

and some matching boilerplate at the bottom to output based on those arguments.

```py
# Get the filename of this script without extension.
path_no_ext = os.path.splitext(sys.argv[0])[0]
if opts.pdf:
    plt.savefig(path_no_ext + '.pdf')
if opts.png:
    plt.savefig(path_no_ext + '.png')
if opts.show:
    plt.show()
```

So for example `plot_daily_journeys.py --pdf --show` will both write the output
plot to `plot_daily_journeys.pdf` and show the plot in a GUI window for you to
check.

Now, we'll look at how we automate this in the `Makefile`. First we set the 
plots directory as a variable.

```makefile
PLOTS_DIR = src/plots/
```

Next, we specify all of the plot scripts are of the form `plot_*.py`, and that
the matching outputs are `plot_*.png` for PNG files and `plot_*.pdf` for PDFs.

<aside>
When I'm working on a plot I'll prefix it `WIP_plot_[...].py` so it doesn't get
picked up by the `make` jobs, and also separates them in the folder.
</aside>

```makefile
PLOTS_PY = $(wildcard $(PLOTS_DIR)plot_*.py)
PLOTS_PDF = $(PLOTS_PY:.py=.pdf)
PLOTS_PNG = $(PLOTS_PY:.py=.png)
```

Now we need to tell `make` the recipe that turns `.py` files in to `.png` and 
`.pdf` files.

```makefile
$(PLOTS_DIR)%.pdf: $(PLOTS_DIR)%.py 
	python $< --pdf $(PLOTS_FLAGS)

$(PLOTS_DIR)%.png: $(PLOTS_DIR)%.py 
	python $< --png $(PLOTS_FLAGS)
```

The variable `PLOTS_FLAGS` contains any extra flags we want to pass to every
plotting script. We'll look at that later.

<aside>
Here `$<` is a `make` [automatic variable][makeav] that takes the name of the
first prerequisite, in this case the python script.
</aside>

Now we add make recipes to produce all the plots.
```makefile
plots_pdf: $(PLOTS_PDF)
plots_png: $(PLOTS_PNG)

plots: plots_pdf plots_png
```
such that e.g. `make plots_pdf` will output all of the plot PDFs and `make
plots` will output all formats.  Note that make understands dependecies, and
so if you update only one script, only that one will be re-run.

## Outputting reports

You'll usually have a separate folder for the documents you want to output, here
we're going to have two outputs: a paper and a slide deck, both to be produced
using LaTeX. I put the source for these in `reports`. I want the plots to be
copied into a subfolder here, to make referencing them self-contained. So first
we copy the PDF plots (I want vector graphics)

```makefile
FIGS_DIR = reports/figs/

# Take the pdfs in PLOTS_PDF and change the path from PLOTS_DIR to FIGS_DIR
REPORT_FIGS_PDF = $(patsubst $(PLOTS_DIR)%, $(FIGS_DIR)%, $(PLOTS_PDF))

# Copy figures	
$(FIGS_DIR)%.pdf: $(PLOTS_DIR)%.pdf
	cp -f $< $(FIGS_DIR)

report_figs_pdf: $(REPORT_FIGS_PDF) TODO: want plots_pdf here?
```

so after running `report_figs_pdf` we should have the following structure:

```
reports/
    +--paper.tex
    +--slides.tex
    figs/
        +--plot_daily_journeys.pdf
        +--plot_trips_vs_temp.pdf
```

Now we make the reports, where .tex files are turned into .pdf files as above

```makefile
REPORTS_TEX = $(wildcard $(REPORTS_DIR)*.tex)
REPORTS_PDF = $(REPORTS_TEX:.tex=.pdf)

$(REPORTS_DIR)%.pdf: $(REPORTS_DIR)%.tex
	pushd $(REPORTS_DIR); pdflatex $(<F); popd 

paper_pdf: $(REPORTS_DIR)paper.pdf
slides_pdf: $(REPORTS_DIR)slides.pdf

reports_pdf: $(REPORTS_PDF)
```

## Flags

Another extremely useful thing in using make for plots in this way is that you 
can add parameters you want to be consistent across all plots as additional
arguments to be passed. 

In this project for example, I may wish to filter for bike journeys between
a given start and end date. But if I do that, I want the filtering to be
consistent across my plots. So I added these flags to the parser in each 
script.

```py
parser.add_argument("--start", default='2015-01-04', help="Start date.",
    type=str)
parser.add_argument("--end", default='2017-01-03', help="End date.",
    type=str)
[...]
START_DATE = opts.start
END_DATE = opts.end
```

Now if I want to filter on all plots I can set

```makefile
PLOTS_FLAGS = --start 2015-01-04 --end 2017-01-03 --tex
```

Notice how I also have a `--tex` flag? I want to render the plot text in TeX 
for production, but it is time-consuming when I'm iterating on the plots. By
adding a switch on each scrip tI can easily turn TeX on and off to save time.
```py
if opts.tex:
    import matplotlib
    matplotlib.rcParams['text.usetex'] = True
```

## Tables

I recommend automating table output in the same way. Did you know Pandas can
output to LaTeX format with [`DataFrame.to_latex`][tolatex]?

This has some big advantages over manually producing tables:
- Avoid digit transcription errors
- Improve scientific reproducibility (Where is that number from? Follow the code.) 
- Quickly do things like adjust the number of decimal places you want to output,
    or adjust parameters of the analysis like the start and end date.

[makeav]: https://www.gnu.org/software/make/manual/html_node/Automatic-Variables.html

[tolatex]: https://pandas.pydata.org/pandas-docs/stable/reference/api/pandas.DataFrame.to_latex.html