@ECHO OFF


rem --------------------------------------------------------------
rem Überprüfen der Umgebung
rem --------------------------------------------------------------

ECHO .
IF "%JAVA_HOME%" == "" goto nojavahome
IF NOT EXIST %JAVA_HOME%\bin\java.exe goto nojavaexe

rem --------------------------------------------------------------
rem include all necessary jar files
rem --------------------------------------------------------------

ECHO Building Classpath

SET JARS=
FOR  %%i IN (.\lib\*.jar) DO call cpappend.cmd %%~fi
set JARS=%JARS%;.
ECHO USING: %JARS%


rem --------------------------------------------------------------
rem Setzen der benötigten Properties
rem --------------------------------------------------------------

rem --------------------------------------------------------------
rem Starten
rem --------------------------------------------------------------

pushd %CD%
REM cd.. 
if "%JARS%" == "" (
	%JAVA_HOME%\bin\java.exe %PROPERTIES% de.fhg.fokus.hss.main.HSSContainer %1 %2 %3 %4 %5 %6 %7 %8 %9
) else (
	%JAVA_HOME%\bin\java.exe %PROPERTIES% -cp %JARS% de.fhg.fokus.hss.main.HSSContainer %1 %2 %3 %4 %5 %6 %7 %8 %9
)
popd
goto fertig


rem --------------------------------------------------------------
rem Fehlermeldungen
rem --------------------------------------------------------------

:nojavahome
ECHO "JAVA_HOME" not set!
goto fertig
:nojavaexe
ECHO java.exe was not found. Please check JAVA_HOME
:fertig
pause