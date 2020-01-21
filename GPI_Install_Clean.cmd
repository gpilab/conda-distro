setlocal
@echo off

# Miniconda version is always 3 now.
MINICONDA_NAME=Miniconda3

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
%MINICONDA_SCRIPT% /AddToPath=0 /S /D=%MINICONDA_PATH%

@echo.
@echo Installing GPI and the gpi_core nodes...
%CONDA% config --system --add channels conda-forge
%CONDA% config --system --set --channel_priority strict
%CONDA% create -y -n gpi
%CONDA% install -y -n gpi gpi_core python=3.7 pyqt=5.9
echo "Removing package files..."
%CONDA% clean -n gpi -tiply

:: Clean up the downloaded files
@echo Removing temporary files...
cd %PATHTOTHEPATH%
RMDIR /S /Q %TMPDIR%

if exist %MINICONDA_PATH%\envs\gpi\Scripts\gpi (
  @echo  ------------------------------------
  @echo ^|  GPI installation was successful!  ^|
  @echo  ------------------------------------
  @echo.
  @echo Creating launch script "gpi_run" on Desktop.
  set GPI_DIR=%MINICONDA_PATH%/envs/gpi
  set GPI_RUNFILE=%HOMEPATH%/Desktop/gpi_run.cmd

  @echo @echo off > %GPI_RUNFILE%
  @echo setlocal >> %GPI_RUNFILE%
  @echo. >> %GPI_RUNFILE%
  @echo set PATH=%GPI_DIR%\bin;%%PATH%% >> %GPI_RUNFILE%
  @echo set PATH=%GPI_DIR%\Scripts;%%PATH%% >> %GPI_RUNFILE%
  @echo set PATH=%GPI_DIR%\Library\bin;%%PATH%% >> %GPI_RUNFILE%
  @echo set PATH=%GPI_DIR%\Library\usr\bin;%%PATH%% >> %GPI_RUNFILE%
  @echo set PATH=%GPI_DIR%\Library\mingw-w64\bin;%%PATH%% >> %GPI_RUNFILE%
  @echo set PATH=%GPI_DIR%;%%PATH%% >> %GPI_RUNFILE%
  @echo. >> %GPI_RUNFILE%
  @echo gpi >> %GPI_RUNFILE%
) else (
  @echo  ----------------------------"
  @echo ^|  GPI installation FAILED!  ^|"
  @echo  ----------------------------"
  @echo removing %MINICONDA_PATH%
  RMDIR /S /Q %MINICONDA_PATH%
  @echo.
)
