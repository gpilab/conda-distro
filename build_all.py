#!/usr/bin/env python
from __future__ import print_function, division
import argparse, os, re, six, sys, inspect, subprocess

packages = ('astyle', 'fftw', 'eigen', 'qimage2ndarray', 'gpi-framework', 'gpi-core-nodes', 'gpi-docs')

###############################################################################
# CLI Options
###############################################################################
def add_args(parser):
    parser.add_argument("--dry-run",
                        help="Show the assembled commands.",
                        action='store_true')

    parser.add_argument("--force-upload",
                        help="Force upload even if the file already exists on anaconda.org",
                        action='store_true')

    parser.add_argument("--channel", "-c", nargs='?', default=[],
                        help="Add the specified channel when building.",
                        action='append')

    parser.add_argument("--upload-channel",
                        help="Upload to the specified channel.",
                        action='store')

    parser.add_argument("--upload-tag", default=[],
                        help="The anaconda.org <channel> i.e.: anaconda -c <channel>",
                        action='append')

    parser.add_argument("--auto-upload", "-u",
                        help="Upload each file on a successful build (uses anaconda client).",
                        action='store_true')

    parser.add_argument("--skip-built", "-s",
                        help="Don't try to build a package if the tarball already exists.",
                        action='store_true')

    parser.add_argument("--package", "-p",
                        help="Specify a package to build (default is all packages).",
                        action='append')

    parser.add_argument("--release-candidate", "-rc",
                        help="Add the _rc suffix to the build string, and add rc to the upload tags.",
                        action='append')

    parser.add_argument("--python-version", "-py", type=int,
                        help="Choose the version of python: 26, 27, 34, 35, 36. The default is 36.",
                        default=36)

    parser.add_argument("--numpy-version", "-np", type=int,
                        help="Choose the version of numpy: 26, 27, 34, 35, 36. The default is 36.",
                        default=36)

    parser.add_argument("--build-number", "-b", type=int,
                        help="Speficy a build number added to the build string e.g. py35_<buildnumber>.",
                        default=0)

###############################################################################
# MAIN
###############################################################################
if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    add_args(parser)
    args = parser.parse_args()

    if args.python_version in [26,27,34,35,36,37]:
        # os.environ['CONDA_PY'] = str(args.python_version)
        pass
    else:
        print(f"Invalid python version selected ({args.python_version}), aborting.")
        sys.exit(1)

    os.environ['PKG_BUILDNUM'] = str(args.build_number)

    # os.environ['PKG_BUILD_STRING'] = f"py{os.environ['CONDA_PY']}_{os.environ['PKG_BUILDNUM']}"

    # if args.release_candidate:
    #     os.environ['RELEASE_STRING'] = '_rc'
    #     os.environ['PKG_BUILD_STRING'] += os.environ['RELEASE_STRING']

    def validPackage(name):
        return name in packages

    # if the user has chosen a specific package(s) to build
    # validate all chosen packages
    for pkg in args.package:
        if not validPackage(pkg):
            print(args.package, ' is not a valid package name, abort.')
            sys.exit(1)

    # pass all chosen packages
    packages = args.package

    # build all packages in the list
    for dirname in packages:
        if os.path.isdir(dirname) and not dirname.startswith('.'):

            ## ASSEMBLE COMMANDS
            # BUILD COMMAND
            conda_build = ['conda', 'build', dirname]
            # conda_build += [f"--python {int(os.environ['CONDA_PY'])/10}"]
            conda_build += ['--no-anaconda-upload']
            conda_build += ['--override-channels']

            for ch in args.channel:
                conda_build.append(f"-c {ch}")
            build_command = ' '.join(conda_build)
            pkgnames = subprocess.Popen(build_command + ' --output', shell=True,
                                       stdout=subprocess.PIPE).stdout.read().strip()

            # split out the upload from the build so we have more control
            pkgnames = pkgnames.decode('ascii') # required by py3

            pkgnames = pkgnames.split()

            upload_commands = []
            for pkg in pkgnames:
                if args.skip_built:
                    if os.path.isfile(pkg):
                        print('\t', dirname, ' is already built, skipping...')
                        continue

                anaconda_upload = ['anaconda', 'upload', pkg]

                # build deps will require the gpi channel to be in the env
                anaconda_upload.append(f"-u {args.upload_channel}")
                for tag in args.upload_tag:
                    anaconda_upload.append(f"-l {tag}")
                if args.release_candidate:
                    anaconda_upload.append('-l rc')
                if args.force_upload:
                    anaconda_upload.append('--force')

                upload_commands.append(' '.join(anaconda_upload))

            ## EXECUTE COMMANDS
            # BUILD
            print(build_command)
            if not args.dry_run:
                subprocess.call(build_command, shell=True)

                for pkg in pkgnames:
                    if not os.path.isfile(pkg):
                        print('\n\nBuild FAILED for package: ', dirname)
                        print('\tThe following file doesn\'t exist: ', pkg, '\n\n')
                        continue

            # UPLOAD
            if args.auto_upload and not args.dry_run:
                for upload in upload_commands:
                    subprocess.call(upload, shell=True)

    print("Finished "+' '.join(sys.argv))
