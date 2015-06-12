#!/usr/bin/env python
from __future__ import print_function, division
import os, re, sys, inspect, subprocess

# cli options
class parseargs():
    def __init__(self):
        self.dry_run = ('--dry-run' in sys.argv)
        # Show the assembled commands.

        self.force_upload = ('--force-upload' in sys.argv) or ('-f' in sys.argv)
        # Force upload even if the file already exists on anaconda.org.

        self.gpi_channel = ('--gpi-channel' in sys.argv) or ('-gpi' in sys.argv)
        # Use the gpi channel (by default the user channel is used).  This will
        # be used for uploads and build dependencies.

        self.auto_upload = ('--auto-upload' in sys.argv) or ('-u' in sys.argv)
        # Upload each file on a successful build (uses anaconda client).

        self.skip_built = ('--skip-built' in sys.argv) or ('-s' in sys.argv)
        # Don't try to build the package if the tarball already exists.

        self.py_ver = 35 # (default)
        if ('--py27' in sys.argv) or ('-2' in sys.argv):
            self.py_ver = 27
        # Choose the version of python 2.7 or 3.5.

        if ('--help' in sys.argv) or ('-h' in sys.argv):
        # This help.
            (print(self), sys.exit(0))

    def __str__(self):
        lines = inspect.getsourcelines(self.__init__)[0]
        lines = lines[1:]
        lines = [l.replace('self.', '') for l in lines]
        lines = [l.replace(' in sys.argv)', '') for l in lines]
        lines = [l.replace('(\'', '') for l in lines]
        lines = [l.replace('\'', '') for l in lines]
        lines = [l.replace('#', '\t') for l in lines]
        lines = [l for l in lines if not l.count('sys.exit')]
        lines.insert(0, 'usage '+sys.argv[0]+' [options]\n')
        return ''.join(lines)

a = parseargs()
os.environ['CONDA_PY'] = str(a.py_ver)

for dirname in ('astyle', 'fftw', 'eigen', 'gpi-framework', 'gpi-core-nodes'):
    print(dirname)
    if os.path.isdir(dirname) and not dirname.startswith('.'):

        ## ASSEMBLE COMMANDS
        # BUILD COMMAND
        conda_build = ['conda', 'build', dirname,
                       '--python {}'.format(a.py_ver/10.), '--no-anaconda-upload']
        build_command = ' '.join(conda_build)

        # UPLOAD COMMAND
        # split out the upload from the build so we have more control
        pkgname = subprocess.Popen(build_command + ' --output', shell=True,
                stdout=subprocess.PIPE).stdout.read().strip()
        anaconda_upload = ['anaconda', 'upload', pkgname]

        if a.gpi_channel: # this default to the USER channel
            anaconda_upload.append('-c gpi')
            # build deps will require the gpi channel to be in the env
            subprocess.call('conda config --add channels gpi', shell=True)
        if a.force_upload:
            anaconda_upload.append('--force')
        upload_command = ' '.join(anaconda_upload)

        if a.skip_built:
            if os.path.isfile(pkgname):
                print('\t', dirname, ' is already built, skipping...')
                continue

        ## EXECUTE COMMANDS
        # BUILD
        print(build_command)
        if not a.dry_run:
            subprocess.call(build_command, shell=True)

            if not os.path.isfile(pkgname):
                print('\n\nBuild FAILED for package: ', dirname)
                print('\tThe following file doesn\'t exist: ', pkgname, '\n\n')
                sys.exit(1)

        # UPLOAD
        if a.auto_upload:
            print(upload_command)
            if not a.dry_run:
                subprocess.call(upload_command, shell=True)
