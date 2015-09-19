# GPI Conda Packages and Dependencies
Conda packaging for serving on [Anaconda.org](http://Anaconda.org).

## Conda Build/Upload

To build a package place the build.sh and meta.yaml in a directory with your
packages name and execute:

    $ conda build <dir-name>

To install the local package:
    
    $ conda install --use-local <pkg-name | full-pkg-path> 

To push the package to Anaconda.org, first make sure you have the
'anaconda-client' installed, then enter:

    $ anaconda upload <full-pkg-path> 

To push to a channel use '-u' option:

    $ anaconda upload <full-pkg-path> -u gpi

## Conda Environments

To create an environment you must provide at least one package:

    $ conda create -n <name> <some-package-name>

To enter the environment:

    $ source activate <name>

To leave the environment:

    $ source deactivate

To delete the environment:

    $ conda remove -n <name>

To list environments:

    $ conda info -e

To clone the environment (also takes the -n option for specifying the env):

    $ conda env export > <name>.yml

To create the environment from an environment spec file:

    $ conda env create -f <name>.yml

## ~/.condarc
You can find a good exmaple at [https://github.com/conda/conda/blob/master/tests/condarc](https://github.com/conda/conda/blob/master/tests/condarc).

