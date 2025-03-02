Refer the ATF Tools user guide at- http://www.adobe.com/devnet/archive/flashruntimes/articles/atf-users-guide.html page.
For more information about the ATF file format, refer- http://www.adobe.com/devnet/archive/flashruntimes/articles/atf-file-format.html page.


To run ATFViewer on MAC:
    
    Perform the following steps as a one time setup on your machine:
    1.  Download QT SDK from http://download.qt.io/official_releases/qt/5.7/5.7.0/qt-opensource-mac-x64-clang-5.7.0.dmg.
    2.  Run the downloaded dmg file and install to /usr/local/Qt5.7.0/ location. 

 
To run ATFViewer on Windows:

    Perform the following steps as a one time setup on your machine:
    1.  Download QT SDK from https://download.qt.io/archive/qt/5.7/5.7.0/qt-opensource-windows-x86-msvc2015-5.7.0.exe.
    2.  Run the downloaded exe file &  install to C:\QT.
    3.  Once the installation is complete, copy the following dll files located at C:\Qt\Qt5.7.0\5.7\msvc2015\bin
        - Qt5Widgets.dll
	- Qt5Gui.dll
	- Qt5Core.dll 
	to the folder <AIR SDK>\atftools\.