# Julia Workshop Materials

A module capturing a series of notebooks and scripts presenting Julia's capabilities.

To install, execute in Julia REPL (if it does not work follow all the steps under `Julia and GIT` [below](#julia-and-git)):

``` julia
	ENV["PYTHON"] = ""
	import Pkg
	Pkg.add(url="https://gitlab.lanl.gov/julialang/juliaworkshop.jl", rev="master")
```

The official Julia documentation is available at [https://docs.julialang.org](https://docs.julialang.org).

The official Julia [discourse https://discourse.julialang.org](https://discourse.julialang.org) is an excellent resource for all kinds of questions and insights in addition to [Stack Overflow](https://stackoverflow.com/questions/tagged/julia).

In the Julia community, it is not recommended to push/pull requests, submit coding issues, or ask questions before you have checked for existing answers or insights at the [Julia discourse website](https://discourse.julialang.org).

## Contents
------------

The `JuliaWorkshop` module showcases how to code and perform machine-learning analyses in Julia.

The `JuliaWorkshop` module covers various topics which are organized into a series of Jupyter and Pluto notebooks:
* Functional programming
* Parallelization
* GPU acceleration
* Machine Learning

Specifically related to Machine Learning, we will cover a series of general, frequently-solved ML tasks such as:
* Classification
* Regression
* Blind source separation
* Feature extraction
* Anomaly Detection
* Spatiotemporal data analytics
* Filling data gaps

We will also present a series of real world ML examples related to:
* Jupiter red spot
* CO2 monitoring
* GeoThermal exploration
* Turbulence
* Europe Climate
* California Wildfires
* Contaminant transport (i.e., water unmixing)

## Notebooks

The `JuliaWorkshop` notebooks can be executed in Jupyter or in the Julia REPL.

For example, the `Parallelization` notebook can be accessed using:

``` julia
	JuliaWorkshop.notebook("Parallelization")
```

The `Parallelization` notebook can also be executed as a Julia script in the Julia REPL using:

``` julia
	JuliaWorkshop.notebookscript("Parallelization")
```

The script above generates a Julia file named `Parallelization.jl` which can be executed in the Julia REPL.

The `Parallelization` notebook can be processed to generate html, markdown, latex, and script versions using:

``` julia
	JuliaWorkshop.process_notebook("Parallelization")
```

To access all the workshop notebooks, execute:

``` julia
	JuliaWorkshop.notebooks()
```

## Getting Started
------------------

Download and install [the latest version of Julia](https://julialang.org/downloads).

Alternatively, you can use the Julia version manager [JuliaUp](https://github.com/JuliaLang/juliaup). This recommended way to manage julia upgrades.

Using tools such as `apt-get`, `brew` or `mac-ports` is not recommended.

### Julia REPL

Julia REPL looks like this:

![](images/julia_REPL.png)

### Julia and GIT

Julia uses GIT for package management.
GIT needs to be installed and configured as well.

### JuliaWorkshop materials

You can install `JuliaWorkshop` module:

``` julia
	ENV["PYTHON"] = ""
	import Pkg
	Pkg.add(url="https://github.com/SmartTensors/JuliaWorkshop.jl", rev="master")
```

### Jupyter Notebooks

Jupyter notebooks are in-browser interactive programming environments that we will use for this workshop.
The notebooks are run through IJulia.

To access the `JuliaWorkshop` notebooks, execute:

```julia
	JuliaWorkshop.notebooks()
```

When `JuliaWorkshop` is installed, it also installs IJulia.

To install IJulia separately, open a Julia REPL and run:

```julia
	ENV["PYTHON"] = ""
	import Pkg
	Pkg.add("IJulia")
```

To open a Jupyter Notebook session in your browser, run the following in a REPL:

```julia
	import IJulia
	IJulia.notebook()
```

The first time you run this, it will install `jupyter` using `conda`.
