# JuliaWorkshop

A module capturing a series of notebooks and scripts presenting Julia capabilities.

To install, execute in Julia REPL (if it does not work follow all the steps under `Julia and GIT` [below](#julia-and-git)):

``` julia
    import Pkg; Pkg.add(url="https://gitlab.lanl.gov/julialang/juliaworkshop.jl", rev="master")
```

The official Julia documentation is available at [https://docs.julialang.org](https://docs.julialang.org).

The official Julia [discourse https://discourse.julialang.org](https://discourse.julialang.org) is an excellent resource for all kind of questions and insights in addition to [Stack Overflow](https://stackoverflow.com/questions/tagged/julia).

In the Julia community, it is not recommended to push pull requests, submit coding issues, or ask questions before you have checked for existing answers or insights at the [Julia discourse website](https://discourse.julialang.org).

For LANL specific Julia questions, you can e-mail to the LANL mailing list [julialang.lanl.gov](mailto:julialang.lanl.gov)

## Contents
------------

The `JuliaWorkshop` module showcases how to code and perform analyses in Julia.

The `JuliaWorkshop` module covers various topics which are organized into a series of Jupyter and Pluto notebooks:
* Functions
* Parallelization
* GPU acceleration

The notebooks can be executed in Jupyter or in the Julia REPL.

For example, the `Parallelization` notebook can be accessed using:

``` julia
JuliaWorkshop.notebook("Parallelization")
```

The `Parallelization` notebook can also be executed as a Julia script in the Julia REPL using:

``` julia
JuliaWorkshop.notebookscript("Parallelization")
```

The `Parallelization` notebook can be processed to generate html, markdown, latex, and script versions using:

``` julia
JuliaWorkshop.process_notebook("Parallelization")
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

### Julia REPL

Julia REPL looks like this:

![](images/julia_REPL.png)

### Julia and GIT

Julia uses GIT for package management.
GIT needs to be installed as well.
Add in the `.gitconfig` file in your home directory:

``` git
[url "git@github.com:"]
    insteadOf = https://github.com/
[url "git@gitlab.com:"]
    insteadOf = https://gitlab.com/
[url "https://"]
    insteadOf = git://
[url "http://"]
    insteadOf = git://
```

or execute:

``` bash
    git config --global url."https://".insteadOf git://
    git config --global url."http://".insteadOf git://
    git config --global url."git@gitlab.com:".insteadOf https://gitlab.com/
    git config --global url."git@github.com:".insteadOf https://github.com/
```

To resolve "Private key location for 'git@github.com'" julia message, execute:

``` bash
    ssh-add ~/.ssh/id_rsa
```

To make Julia and GIT work behind the LANL firewall execute:

``` bash
    export ftp_proxy=http://proxyout.lanl.gov:8080
    export rsync_proxy=http://proxyout.lanl.gov:8080
    export http_proxy=http://proxyout.lanl.gov:8080
    export https_proxy=http://proxyout.lanl.gov:8080
    export no_proxy=.lanl.gov
    export ALL_PROXY=proxyout.lanl.gov:8080
```

You can also do this in the Julia REPL:

```julia
    ENV["ftp_proxy"] =  "http://proxyout.lanl.gov:8080"
    ENV["rsync_proxy"] = "http://proxyout.lanl.gov:8080"
    ENV["http_proxy"] = "http://proxyout.lanl.gov:8080"
    ENV["https_proxy"] = "http://proxyout.lanl.gov:8080"
    ENV["no_proxy"] = ".lanl.gov"
```

Now you can install `JuliaWorkshop` module:

``` julia
    import Pkg; Pkg.add(url="https://gitlab.lanl.gov/julialang/juliaworkshop.jl", rev="master")
```