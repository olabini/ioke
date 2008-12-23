@echo off
rem Environment Variable Prequisites:
rem
rem   IOKE_OPTS    (Optional) Default Ioke command line args.
rem
rem   JAVA_HOME     Must point at your Java Development Kit installation.
rem

rem ----- Save Environment Variables That May Change --------------------------

set _CLASSPATH=%CLASSPATH%
set _CP=%CP%
set _IOKE_CP=%IOKE_CP%
set IOKE_BAT_ERROR=0

rem ----- Verify and Set Required Environment Variables -----------------------

if not "%JAVA_HOME%" == "" goto gotJava

for %%P in (%PATH%) do if exist %%P\java.exe set JAVA_HOME=%%P..\
if not "%JAVA_HOME%" == "" goto gotJava

echo You must set JAVA_HOME to point at your JRE/JDK installation
set IOKE_BAT_ERROR=1
exit /b 1
:gotJava

set IOKE_HOME=%~dp0..

rem ----- Prepare Appropriate Java Execution Commands -------------------------

if not "%JAVA_COMMAND%" == "" goto gotCommand
set _JAVA_COMMAND=%JAVA_COMMAND%
set JAVA_COMMAND=java
:gotCommand

if not "%OS%" == "Windows_NT" goto noTitle
rem set _STARTJAVA=start "Ioke" "%JAVA_HOME%\bin\java"
set _STARTJAVA=%JAVA_HOME%\bin\%JAVA_COMMAND%
goto gotTitle
:noTitle
rem set _STARTJAVA=start "%JAVA_HOME%\bin\java"
set _STARTJAVA=%JAVA_HOME%\bin\%JAVA_COMMAND%
:gotTitle

rem ----- Set up the VM options
call "%~dp0_iokevmopts" %*
set _RUNJAVA="%JAVA_HOME%\bin\java"

rem ----- Set Up The Boot Classpath ----------------------------------------

for %%i in ("%IOKE_HOME%\lib\ioke*.jar") do @call :setiokecp %%i

rem ----- Set Up The System Classpath ----------------------------------------

for %%i in ("%IOKE_HOME%\lib\*.jar") do @call :setcp %%i

goto :EOF

rem setiokecp subroutine
:setiokecp
if not "%IOKE_CP%" == "" goto addiokecp
set IOKE_CP=%*
goto :EOF

:addiokecp
set IOKE_CP=%IOKE_CP%;%*
goto :EOF

rem setcp subroutine
:setcp
if not "%CP%" == "" goto add
set CP=%*
goto :EOF

:add
set CP=%CP%;%*
goto :EOF
