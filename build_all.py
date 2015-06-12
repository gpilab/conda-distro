#!/usr/bin/env python
from __future__ import print_function, division
from six.moves import input
import os, subprocess

py_ver = int(input("Enter Python ver as a two-digit number (e.g. 27, or 35): "))
os.environ['CONDA_PY'] = str(py_ver)

while True:
    upload_pkgs = input("Upload the packages as they are built ([y]/n)?: ")
    if upload_pkgs.lower() in ('n', 'no'):
        upload_pkgs = '--no-anaconda-upload'
        break
    elif upload_pkgs.lower() in ('y', 'yes', ''):
        upload_pkgs = ''
	# Since there isn't a way to force this thru the cli we have to make
	# sure its set.
	subprocess.call('conda config --set anaconda_upload yes', shell=True)
        break
    else:
        print("Invalid input, please enter 'y' or 'n'.")

for dirname in ('astyle', 'fftw', 'eigen', 'gpi-framework', 'gpi-core-nodes'):
    print(dirname)
    if os.path.isdir(dirname) and not dirname.startswith('.'):
        conda_build = ['conda', 'build', dirname,
                       '--python {}'.format(py_ver/10.), upload_pkgs]
        build_command = ' '.join(conda_build)
        print(build_command)
        print(subprocess.call(build_command, shell=True))
