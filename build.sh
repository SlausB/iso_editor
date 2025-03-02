#!/bin/bash
clear
reset

set -e

./flexsdk/bin/amxmlc -load-config=./iso_editor.xml -warnings=false -output=iso_editor.swf -- ./src/Main.mxml
