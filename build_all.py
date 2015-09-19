import os, subprocess

for dirname in os.listdir(os.getcwd()):
    if os.path.isdir(dirname) and not dirname.startswith('.'):
        conda_build = ['conda', 'build', dirname]
        subprocess.call(conda_build)

