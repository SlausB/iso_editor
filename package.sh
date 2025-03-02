#!/bin/bash
reset
clear

set -e

# sudo apt-get install -y libgtk2.0-0

adt -certificate -cn IsoEditor -ou Balcony -o DreamMind -validityPeriod 99 2048-RSA iso_editor.p12 fd

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    export PATH="$(pwd)/AIRSDK_Flex_Linux/bin:$PATH"
    echo "Packaging AIR ..."
    export AIR_NO_DEP_CHECK=true
    
    # will require AIR runtime installed on the system:
    #adt -package -tsa none -storetype pkcs12 -keystore iso_editor.p12 -storepass fd  pack/iso_editor.air application.xml -C pack .

    adt -package -tsa none -storetype pkcs12 -keystore iso_editor.p12 -storepass fd -target native pack/iso_editor.air application.xml -C pack .
    
    #strace -f -o adt_trace.log adt -package -tsa none -storetype pkcs12 -keystore iso_editor.p12 -storepass fd -target native pack/iso_editor.air application.xml -C pack .

elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    export PATH="$(pwd)/flex_with_air_on_top/bin:$PATH"
    echo "Packaging EXE ..."
    adt -package -tsa none -storetype pkcs12 -keystore iso_editor.p12 -storepass fd  -target bundle iso_editor_standalone application.xml iso_editor.swf
else
    echo "Unsupported OS: $OSTYPE"
fi

echo IsoEditor successfully bundled!
