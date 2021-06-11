@ECHO OFF
SET root=%~dp0
%root%\tool\dartaotruntime.exe %root%\lib\FILENAME.aot %*
