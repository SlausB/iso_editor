@echo off
set PAUSE_ERRORS=1
call bat\SetupSDK.bat
call bat\SetupApplication.bat

echo .
echo Packaging...

call bat\PackagerExe.bat

echo Done.

::set AIR_TARGET=
::set AIR_TARGET=-captive-runtime
::set OPTIONS=-tsa none
::call bat\Packager.bat

pause