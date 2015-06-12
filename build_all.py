#!/usr/bin/env python
from __future__ import print_function, division
from six.moves import input
import os, sys, subprocess

# cli options
dry_run = '--dry-run' in sys.argv
force_upload = ('--force-upload' in sys.argv) or ('-f' in sys.argv)
gpi_channel = ('--gpi-channel' in sys.argv) or ('-gpi' in sys.argv)
auto_upload = ('--auto-upload' in sys.argv) or ('-u' in sys.argv)
skip_built = ('--skip-built' in sys.argv) or ('-s' in sys.argv)

py_ver = int(input("Enter Python ver as a two-digit number (e.g. 27, or 35): "))
os.environ['CONDA_PY'] = str(py_ver)

for dirname in ('astyle', 'fftw', 'eigen', 'gpi-framework', 'gpi-core-nodes'):
    print(dirname)
    if os.path.isdir(dirname) and not dirname.startswith('.'):

        ## ASSEMBLE COMMANDS
        # BUILD COMMAND
        conda_build = ['conda', 'build', dirname,
                       '--python {}'.format(py_ver/10.), '--no-anaconda-upload']
        build_command = ' '.join(conda_build)

        # UPLOAD COMMAND
        # split out the upload from the build so we have more control
        pkgname = subprocess.Popen(build_command + ' --output', shell=True,
                stdout=subprocess.PIPE).stdout.read().strip()
        anaconda_upload = ['anaconda', 'upload', pkgname]

        if gpi_channel: # this default to the USER channel
            anaconda_upload.append('-c gpi')
        if force_upload:
            anaconda_upload.append('--force')
        upload_command = ' '.join(anaconda_upload)

        if skip_built:
            if os.path.isfile(pkgname):
                continue

        ## EXECUTE COMMANDS
        # BUILD
        print(build_command)
        if not dry_run:
            subprocess.call(build_command, shell=True)

            if not os.path.isfile(pkgname):
                print('Build FAILED for package: ', dirname)
                print('\tThe following file doesn\'t exist: ', pkgname)
                sys.exit(1)

        # UPLOAD
        if auto_upload:
            print(upload_command)
            if not dry_run:
                subprocess.call(upload_command, shell=True)
