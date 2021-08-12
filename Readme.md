# JuliaWorkshop

A series of notebooks present Julia capabilities.

### Contents
------------

The notebooks showcase:
* Functions
* Parallelization
* GPU acceleration

Parallelization notebook can be accessed using:

``` julia
JuliaWorkshop.notebook("Parallelization")
```

Parallelization notebook can be executed as a Julia script using:

``` julia
JuliaWorkshop.notebookscript("Parallelization")
```

Parallelization notebook can be processed to generate html, markdown, latex, and script versions using:

``` julia
JuliaWorkshop.process_notebook("Parallelization")
```

## Getting Started
------------------

First, if you have not already done so, add the following to ~./bash_profile in your home directory:

``` bash
    export ftp_proxy=http://proxyout.lanl.gov:8080
    export rsync_proxy=http://proxyout.lanl.gov:8080
    export http_proxy=http://proxyout.lanl.gov:8080
    export https_proxy=http://proxyout.lanl.gov:8080
    export no_proxy=.lanl.gov
    export ALL_PROXY=proxyout.lanl.gov:8080
```

Download and install [the latest version of Julia](https://julialang.org/downloads/).
The current stable version is Julia 1.6.2.

### Linux installation

``` bash
    wget https://julialang-s3.julialang.org/bin/linux/x64/1.6/julia-1.6.2-linux-x86_64.tar.gz
    tar xvzf julia-1.6.2-linux-x86_64.tar.gz
```

The julia executable is `julia-1.6.2/bin/julia` which will open the Julia REPL.
You can add in your PATH `julia-1.6.2/bin` or link `julia-1.6.2/bin/julia` to your default `bin` folder in your PATH.

### Mac OS X installation

After downloading and executing, the julia executable is `/Applications/Julia-1.6.app/Contents/Resources/julia/bin/julia`.

You can add in your PATH:

``` bash
    export PATH="/Applications/Julia-1.6.app/Contents/Resources/julia/bin:$PATH"
```

### Windows installation

### Julia REPL

Julia REPL looks like this:

![](images/julia_REPL.png)

### Julia + GIT

Julia uses git for package management. Add in the `.gitconfig` file in your home directory:

```
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

```
git config --global url."https://".insteadOf git://
git config --global url."http://".insteadOf git://
git config --global url."git@gitlab.com:".insteadOf https://gitlab.com/
git config --global url."git@github.com:".insteadOf https://github.com/
```

To resolve "Private key location for 'git@github.com'" julia message, execute:

```
ssh-add ~/.ssh/id_rsa
```
