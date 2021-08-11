# JuliaWorkshop

A series of notebooks present Julia capabilities.

### Contents
------------

The notebooks showcase:
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


    export ftp_proxy=http://proxyout.lanl.gov:8080
    export rsync_proxy=http://proxyout.lanl.gov:8080
    export http_proxy=http://proxyout.lanl.gov:8080
    export https_proxy=http://proxyout.lanl.gov:8080
    export no_proxy=.lanl.gov
    export ALL_PROXY=proxyout.lanl.gov:8080


If you have Administrative access, you can download [the latest version of Julia](https://julialang.org/downloads/). The current stable version is Julia 1.6.2.

Otherwise, send a request to AskIT@lanl.gov

After installing, you should have the "Julia-1.6" program installed. This program will open the Julia REPL, you should see something like this:

![](images/julia_REPL.png)

You can also open the REPL by typing `julia` in your terminal. If this does not work, you can add Julia to your path. For example, on my mac when I open the "Julia-1.6" progam, it opens a terminal and runs the following command 

    $ exec '/Applications/Julia-1.6.app/Contents/Resources/julia/bin/julia'

I added Julia to my path with the following line in my ~/.bash_profile

    export PATH="/Applications/Julia-1.6.app/Contents/Resources/julia/bin:$PATH"

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
