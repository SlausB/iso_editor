:: @echo off
setlocal EnableDelayedExpansion

:: Define a helper function to exit execution on error
set "trap=if %%errorlevel%% neq 0 exit /b %%errorlevel%%"

mkdir build 2>nul
call .\flexair\bin\amxmlc -load-config="iso_editor.xml" -warnings=false -output="build/iso_editor.swf" ./src/Main.mxml

set PATH=%CD%\flexair\bin;%PATH%

echo Generate certificate (only needed once)
REM certificate generated 12 years ago is still seems to be working, but now it just doesn't work (insta quits without any errors) - on Linux it shows network timeout errors (seems Adobe server refuses to process request due to sanctioning Russia):
REM adt -certificate -cn IsoEditor -ou Balcony -o DreamMind -validityPeriod 99 2048-RSA iso_editor.p12 fd

echo Package EXE with captive runtime
mkdir build 2>nul
adt -package -tsa none -storetype pkcs12 -keystore iso_editor.p12 -storepass fd -target bundle bundle application.xml build/iso_editor.swf & %trap%

echo IsoEditor successfully bundled!
pause

REM runs just built iso_editor
call .\flexair\bin\adl application.xml & %trap%