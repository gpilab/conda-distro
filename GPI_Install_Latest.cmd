@echo off

if [%1]==[] goto help
if "%1"=="\H" goto help
:: can use shift in for loop to set these as next improvement
set PYTHON_VER=3.7
set QT_VER=5.9
set MINICONDA_NAME=Miniconda3

:: check for available commands
WHERE curl >nul 2>nul
if %ERRORLEVEL% neq 0 (
	echo This script requires curl, but it wasn't found.
        echo Please install curl, then re-run this script.
	goto :eof
)

:: conda install location
set MINICONDA_PATH=%~f1
if not %MINICONDA_PATH:~-1%==\ SET MINICONDA_PATH=%MINICONDA_PATH%\
set CONDA=%MINICONDA_PATH%Scripts\conda.exe
for %%d in (%MINICONDA_PATH%..) do set PATHTOTHEPATH=%%~fd
@echo Install Path: %MINICONDA_PATH%
@echo Install Dir: %PATHTOTHEPATH%
@echo Conda Location: %CONDA%

if not exist %PATHTOTHEPATH% (
  @echo The parent path %PATHTOTHEPATH% doesn't exist.
  goto :eof
)
:: See if the directory is already in use
if exist %MINICONDA_PATH% (
  @echo "The supplied directory already exists, installation aborted."
  goto :eof
)
@echo Installing the GPI stack for python %PYTHON_VER% ...
:: Install MiniConda
cd %PATHTOTHEPATH%
set MINICONDA_WEB=https://repo.continuum.io/miniconda
set MINICONDA_SCRIPT=%MINICONDA_NAME%-latest-Windows-x86_64.exe
@echo %MINICONDA_SCRIPT%

:: make a tmp working dir
set TMPDIR=tmp_%RANDOM%
@echo Working in temporary directory %TMPDIR%
mkdir %TMPDIR%
cd %TMPDIR%

:: Run install script
@echo.
@echo "Downloading MiniConda..."
curl %MINICONDA_WEB%/%MINICONDA_SCRIPT% --output %MINICONDA_SCRIPT%
@echo.
@echo Installing MiniConda...
%MINICONDA_SCRIPT% /S /D=%MINICONDA_PATH%

@echo.
@echo Installing GPI and the gpi_core nodes...
:: add conda-forge channel
:: priority: conda-forge > defaults
%CONDA% config --add channels conda-forge

:: Set channel priority to strict per conda-forge recommendation
%CONDA% config --set channel_priority strict

:: Create the new env with gpi, allowing python and pyqt to be set explicitly
%CONDA% create -n gpi -y python=%PYTHON_VER% pyqt=%QT_VER% gpi_core

@echo Removing package files...
%CONDA% clean -tiply

:: Clean up the downloaded files
@echo Removing tmp files...
cd %PATHTOTHEPATH%
RMDIR /S /Q %TMPDIR%

if exist %MINICONDA_PATH%\envs\gpi\Scripts\gpi (
  @echo  ------------------------------------
  @echo ^|  GPI installation was successful!  ^|
  @echo  ------------------------------------
  @echo.
  @echo To launch GPI from PowerShell, configure conda as follows:
  @echo   1 - Open a new PowerShell window with elevated privileges by
  @echo         right clicking and choosing "Run as administrator"
  @echo       ^(Note: if you do not have admin privileges, you will
  @echo         need to use the older "Command Prompt" method.
  @echo         See below for instructions.^)
  @echo   2 - Run the following command:
  @echo         %HOMEPATH%^> set-executionpolicy remotesigned
  @echo   3 - Respond to the prompt with "Y" to confirm the changes
  @echo   4 - Run the following command
  @echo   	%HOMEPATH%^> conda init powershell
  @echo	  5 - You can now activate GPI as described below from any
  @echo		PowerShell window - admin privileges are not required.
  @echo.
  @echo To launch GPI using "Command Prompt" ^(cmd.exe^), setup requires 
  @echo   running one command in a Command Prompt window:
  @echo     %HOMEPATH%^> %CONDA% init
  @echo   ^(you may also run this as "conda init" in PowerShell^)
  @echo.
  @echo.
  @echo If configuration was successful you can run GPI by entering the
  @echo   following commands:
  @echo.
  @echo     ^(base^) %HOMEPATH%^> conda activate gpi
  @echo     ^(gpi^) %HOMEPATH%^> gpi
  @echo.
  @echo   in whichever shell you have conda configured. Note that "^(base^)"
  @echo   will appear in any new PowerShell terminal, but not in cmd.exe. 
  @echo.
) else (
  @echo  ----------------------------"
  @echo ^|  GPI installation FAILED!  ^|"
  @echo  ----------------------------"
  @echo removing %MINICONDA_PATH%
  RMDIR /S /Q %MINICONDA_PATH%
  @echo.
  @echo Scroll up to see if you can spot the error.
  @echo If you are unable to find the issue, copy the output of the
  @echo installation command and include in a new Issue on GitHub:
  @echo https://github.com/gpilab/conda-distro/issues
)
goto :eof

:help
@echo.
@echo       --------------------------------------------------------      
@echo.
@echo   Welcome to the GPI-MiniConda stack installer.  This script will   
@echo      install MiniConda (continuum.io) and the GPI (gpilab.com)      
@echo             application packages to a given directory.              
@echo.
@echo                          - - - - - - - - -                          
@echo.
@echo   (NOTE - Only the "\H" option is currently supported for CMD.EXE.
@echo   Install using the git-bash shell for specific version control.)
@echo.
@echo usage: %0 [options] [path]
@echo     \H             display this help
@echo.
@echo     Example ^(preferred location^): %0 %%HOMEPATH%%\gpi_stack
@echo.
@echo Alternatively, if you already have the conda package manager from a
@echo previous Anaconda or Miniconda installation, you can install GPI
@echo into a new Python 3.6+ environment with the following commands:
@echo.
@echo     %HOMEPATH%^> conda create -n gpi python=3.x
@echo     %HOMEPATH%^> conda activate gpi
@echo     %HOMEPATH%^> conda install -c conda-forge --strict-channel-priority gpi_core
@echo.
@echo Note that the --strict-channel-priority flag is not always required,
@echo but is now recommended in the conda-forge ecosystem ^(and will be the
@echo default if this script installs miniconda for you^). You can add    
@echo conda-forge and set strict priority for an existing install with:        
@echo.
@echo     %HOMEPATH%^> conda config --add channels conda-forge:
@echo     %HOMEPATH%^> conda config --set channel_priority strict
@echo.
@echo For more details see:
@echo     https://conda-forge.org/docs/user/tipsandtricks.html
goto :eof

