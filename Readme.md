# Julia Workshop Materials

A module capturing a series of notebooks and scripts presenting Julia capabilities.

To install, execute in Julia REPL (if it does not work follow all the steps under `Julia and GIT` [below](#julia-and-git)):

``` julia
	ENV["PYTHON"] = ""
	import Pkg
	Pkg.add(url="https://gitlab.lanl.gov/julialang/juliaworkshop.jl", rev="master")
```

The official Julia documentation is available at [https://docs.julialang.org](https://docs.julialang.org).

The official Julia [discourse https://discourse.julialang.org](https://discourse.julialang.org) is an excellent resource for all kind of questions and insights in addition to [Stack Overflow](https://stackoverflow.com/questions/tagged/julia).

In the Julia community, it is not recommended to push pull requests, submit coding issues, or ask questions before you have checked for existing answers or insights at the [Julia discourse website](https://discourse.julialang.org).

For LANL specific Julia questions, you can e-mail to the LANL mailing list [julialang.lanl.gov](mailto:julialang.lanl.gov)

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
* Filling datagaps

We will also present a series of realworld ML examples related to:
* Jupiter redspot
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

Download and install [the latest version of Julia](https://julialang.org/downloads/).
The current stable version is Julia 1.6.2.

### Linux installation

``` bash
	wget https://julialang-s3.julialang.org/bin/linux/x64/1.6/julia-1.6.2-linux-x86_64.tar.gz
	tar xvzf julia-1.6.2-linux-x86_64.tar.gz
```

The julia executable is `julia-1.6.2/bin/julia` which will open the Julia REPL.
You can add in your PATH `julia-1.6.2/bin` or link `julia-1.6.2/bin/julia` to your default `bin` folder in your PATH.

Using `apt-get` is not recommended.

### Mac OS X installation

After downloading [the latest version of Julia](https://julialang.org/downloads/) and installing, the julia executable is `/Applications/Julia-1.6.app/Contents/Resources/julia/bin/julia`.

You can add in your PATH:

``` bash
	export PATH="/Applications/Julia-1.6.app/Contents/Resources/julia/bin:$PATH"
```

Using `brew` or `mac-ports` is not recommended.

### Windows installation

Download and install [the latest version of Julia](https://julialang.org/downloads/).
This will give you the Julia 1.6.2 program.
Opening this program will open a Julia REPL.

### Julia REPL

Julia REPL looks like this:

![](images/julia_REPL.png)

### Julia and GIT

Julia uses GIT for package management.
GIT needs to be installed and configured as well.

To make Julia and GIT work behind the LANL firewall execute:

``` bash
	export ALL_PROXY=proxyout.lanl.gov:8080
	export ftp_proxy=http://proxyout.lanl.gov:8080
	export rsync_proxy=http://proxyout.lanl.gov:8080
	export http_proxy=http://proxyout.lanl.gov:8080
	export https_proxy=http://proxyout.lanl.gov:8080
	export no_proxy=.lanl.gov
```

You can also do this in the Julia REPL:

```julia
	ENV["ALL_PROXY"] =  "http://proxyout.lanl.gov:8080"
	ENV["ftp_proxy"] =  "http://proxyout.lanl.gov:8080"
	ENV["rsync_proxy"] = "http://proxyout.lanl.gov:8080"
	ENV["http_proxy"] = "http://proxyout.lanl.gov:8080"
	ENV["https_proxy"] = "http://proxyout.lanl.gov:8080"
	ENV["no_proxy"] = ".lanl.gov"
```

Now, you can install `JuliaWorkshop` module:

``` julia
	ENV["PYTHON"] = ""
	import Pkg
	Pkg.add(url="https://gitlab.lanl.gov/julialang/juliaworkshop.jl", rev="master")
```

If you get "Private key location for 'git@github.com'" julia message, to resolve it execute:

``` bash
	ssh-add ~/.ssh/id_rsa
```

### Jupyter Notebooks

Jupyter notebooks are in-browser interactive programming environments that we will use for this workshop.
The notebooks are run through IJulia.

To access the `JuliaWorkshop` notebooks, execute:

``` julia
	JuliaWorkshop.notebooks()
```

When `JuliaWorkshop` is installed it also installs IJulia.

To install IJulia seperately, open a Julia REPL and run:

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
