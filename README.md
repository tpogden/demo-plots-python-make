# Demo: Automate Scientific Plots with Python and Make

This is a demo project to go with the blogpost [Automate Scientific Plots
with Python and Make][bp].

## Reports

- [paper.pdf][paper_pdf]
- [slides.pdf][slides_pdf]

[paper_pdf]: releases/download/v1.0/paper.pdf
[slides_pdf]: releases/download/v1.0/slides.pdf

## How to Create the Reports 

First set up a Python environment with Numpy, Pandas and Matplotlib. I recommend
Conda, in which case the following commands will create and activate an
environment.

```sh
conda env create -f environment.yml
conda activate demo-plots-python-make
```

Now you can produce the paper and slides from source with

```sh
make
```

### Note

For the LaTeX rendering, you will need a working TeX installation with
`pdflatex` in your `PATH`. This is not included in the Conda environment.

## Data Source

https://www.kaggle.com/hmavrodiev/london-bike-sharing-dataset/data

Powered by TfL Open Data (see [data/raw/LICENSE](data/raw/LICENSE)).

[bp]: https://ogden.eu/automate-scientific-plots-with-python-make
