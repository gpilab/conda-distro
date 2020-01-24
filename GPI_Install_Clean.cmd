@echo off
setlocal

:: check for available commands
WHERE curl >nul 2>nul
if %ERRORLEVEL% neq 0 (
  @echo This script requires curl, but it wasn't found.
  @echo Please install curl, then re-run this script.
  goto :eof
)

:: conda install location
if [%1]==[] goto :defaultpath

if "%1"=="/H" goto :help
goto :userpath

:defaultpath
  set MINICONDA_PATH=%userprofile%\gpi_stack\
  goto :pathset

:userpath
  set MINICONDA_PATH=%~f1
  if not %MINICONDA_PATH:~-1%==\ SET MINICONDA_PATH=%MINICONDA_PATH%\

:pathset
set CONDA=%MINICONDA_PATH%Scripts\conda.exe
for %%d in (%MINICONDA_PATH%..) do set PATHTOTHEPATH=%%~fd

if not exist %PATHTOTHEPATH% (
  @echo The desired install directory, %PATHTOTHEPATH%, doesn't exist.
  goto :eof
)
:: See if the directory is already in use
if exist %MINICONDA_PATH% (
  @echo The directory to be created, %MINICONDA_PATH% already exists.
  @echo Installation aborted.
  goto :eof
)
@echo This script will install GPI into %MINICONDA_PATH%
:: Install MiniConda
cd %PATHTOTHEPATH%
set MINICONDA_WEB=https://repo.continuum.io/miniconda
set MINICONDA_SCRIPT=Miniconda3-latest-Windows-x86_64.exe
@echo %MINICONDA_SCRIPT%

:: make a tmp working dir
set TMPDIR=tmp_%RANDOM%
@echo Working in temporary directory %TMPDIR%
mkdir %TMPDIR%
cd %TMPDIR%

:: Run install script
curl %MINICONDA_WEB%/%MINICONDA_SCRIPT% --output %MINICONDA_SCRIPT%

@echo.
@echo Installing - this may take a few minutes...
%MINICONDA_SCRIPT% /AddToPath=0 /S /D=%MINICONDA_PATH%

set PATH=%MINICONDA_PATH%\bin;%PATH%
set PATH=%MINICONDA_PATH%\Scripts;%PATH%
set PATH=%MINICONDA_PATH%\Library\bin;%PATH%
set PATH=%MINICONDA_PATH%\Library\usr\bin;%PATH%
set PATH=%MINICONDA_PATH%\Library\mingw-w64\bin;%PATH%
set PATH=%MINICONDA_PATH%;%PATH%
%CONDA% config --system --add channels conda-forge
%CONDA% config --system --set channel_priority strict
%CONDA% create -y -n gpi
%CONDA% install -y -n gpi gpi_core python=3.7 pyqt=5.9

@echo "Cleaning Up..."
%CONDA% clean -tiply

:: Clean up the downloaded files
cd %PATHTOTHEPATH%
RMDIR /S /Q %TMPDIR%

set GPI_LAUNCHER=%MINICONDA_PATH%envs\gpi\Scripts\gpi.cmd
set GPI_SHORTCUT=%userprofile%\Desktop\gpi.lnk

if exist %GPI_LAUNCHER% (
  @echo  ------------------------------------
  @echo ^|  GPI installation was successful!  ^|
  @echo  ------------------------------------
  @echo.
  @echo Creating launch shortcut on Desktop - this will prompt for Administrator access.

  powershell -Command "start cmd -v RunAs -ArgumentList '/C mklink %GPI_SHORTCUT% %GPI_LAUNCHER%'"
) else (
  @echo  ----------------------------"
  @echo ^|  GPI installation FAILED!  ^|"
  @echo  ----------------------------"
  @echo removing %MINICONDA_PATH%
  RMDIR /S /Q %MINICONDA_PATH%
  @echo.
  goto :eof
)

TIMEOUT /T 1 /NOBREAK >NUL

if exist %GPI_SHORTCUT% (
  @echo Shortcut created successfully at %GPI_SHORTCUT%
) else (
  @echo Error - could not create shortcut for GPI.
  @echo Run GPI by executing %GPI_LAUNCHER%, or create a shortcut yourself.
)
goto :eof

:help
@echo.
@echo This script can be called with no argument (default install location)
@echo or with one argument, specifying the install location, e.g.:
@echo %userprofile%^> GPI_Install_Clean.cmd %userprofile%\gpi_stack
@echo (this is the default location)
goto :eof

