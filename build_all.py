#!/usr/bin/env python
from __future__ import print_function, division
import os, re, six, sys, inspect, subprocess

packages = ('astyle', 'fftw', 'eigen', 'gpi-framework', 'gpi-core-nodes')

# cli options
class parseargs():
    def __init__(self):
        self.dry_run = ('--dry-run' in sys.argv)
        #   Show the assembled commands.

        self.force_upload = ('--force-upload' in sys.argv) or ('-f' in sys.argv)
        #   Force upload even if the file already exists on anaconda.org.

        self.use_channel = ('--channel' in sys.argv) or ('-c' in sys.argv)
        #   Use the specified channel: -c <channel>

        self.auto_upload = ('--auto-upload' in sys.argv) or ('-u' in sys.argv)
        #   Upload each file on a successful build (uses anaconda client).

        self.skip_built = ('--skip-built' in sys.argv) or ('-s' in sys.argv)
        #   Don't try to build the package if the tarball already exists.

        self.target_package = ('--package' in sys.argv) or ('-p' in sys.argv)
        #   Specify a package to build, (ignores the rest of the list).

        self.py_ver = 35 # (default)
        if ('--py27' in sys.argv) or ('-2' in sys.argv):
            self.py_ver = 27
        #   Choose the version of python 2.7 or 3.5.

        if ('--help' in sys.argv) or ('-h' in sys.argv):
        #   This help.
            (print(self.help()), sys.exit(0))

    def help(self):
        lines = [re.sub(r'[\'()#]|self\.| in sys\.argv|^.*sys\.exit.*$','',l)
                for l in inspect.getsourcelines(self.__init__)[0]]
        lines[0] = 'usage '+sys.argv[0]+' [options]\n'
        return ''.join(lines)

    def channel(self):
        if self.use_channel:
            m = re.search(r'(-c|--channel)\s+(\w+)\s*', ' '.join(sys.argv))
            if m: return m.group(2)

    def package(self):
        if self.target_package:
            m = re.search(r'(-p|--package)\s+([\w-]+)\s*', ' '.join(sys.argv))
            if m: return m.group(2)

a = parseargs()
os.environ['CONDA_PY'] = str(a.py_ver)

if a.target_package:
    if a.package() in packages:
        packages = [a.package()]
    else:
        print(a.package(), ' is not a valid package name, abort.')
        sys.exit(1)

for dirname in packages:
    print(dirname)
    if os.path.isdir(dirname) and not dirname.startswith('.'):

        if dirname == 'astyle' and a.py_ver == 35 and sys.platform == 'linux':
            print('Astyle needs to be built with python2.7 on Linux, skipping...')
            continue

        ## ASSEMBLE COMMANDS
        # BUILD COMMAND
        conda_build = ['conda', 'build', dirname,
                       '--python {}'.format(a.py_ver/10.), '--no-anaconda-upload']
        if a.use_channel:
            conda_build.append('-c '+a.channel())
        build_command = ' '.join(conda_build)

        # UPLOAD COMMAND
        # split out the upload from the build so we have more control
        pkgname = subprocess.Popen(build_command + ' --output', shell=True,
                stdout=subprocess.PIPE).stdout.read().strip()
        pkgname = pkgname.decode('ascii') # required by py3
        anaconda_upload = ['anaconda', 'upload', pkgname]

        if a.skip_built:
            if os.path.isfile(pkgname):
                print('\t', dirname, ' is already built, skipping...')
                continue

        # build deps will require the gpi channel to be in the env
        if a.use_channel:
            anaconda_upload.append('-c '+a.channel())
        if a.force_upload:
            anaconda_upload.append('--force')
        upload_command = ' '.join(anaconda_upload)

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
