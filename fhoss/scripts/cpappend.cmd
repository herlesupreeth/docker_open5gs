IF "%JARS%"=="" goto first
set JARS=%JARS%;%1
goto fertig
:first
set JARS=%1
:fertig