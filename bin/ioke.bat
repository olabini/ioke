@echo off
rem ---------------------------------------------------------------------------
rem ioke.bat - Start Script for Ioke
rem
rem for info on environment variables, see internal batch script _iokevars.bat
rem this script blatantly stolen from JRuby

setlocal

IF EXIST "%~dp0_iokevars.bat" (set FULL_PATH=%~dp0) ELSE (set FULL_PATH=%~dp$PATH:0)

call "%FULL_PATH%_iokevars.bat" %*

if %IOKE_BAT_ERROR%==0 "%_STARTJAVA%" %_VM_OPTS% -Xbootclasspath/a:"%IOKE_CP%" -classpath "%CP%;%CLASSPATH%" -Dioke.home="%IOKE_HOME%" -Dioke.lib="%IOKE_HOME%\lib" -Dioke.script=ioke.bat ioke.lang.Main %_IOKE_OPTS%"
set E=%ERRORLEVEL%

call "%FULL_PATH%_iokecleanup"

endlocal & cmd /d /c exit /b %E%
