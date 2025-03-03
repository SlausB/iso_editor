# IsoEditor
For now tested only on Windows (Adobe Flash too also works only on Windows anyway). To build and pack, run `build.bat` which should put executable and dependencies (AIR) in dir `bundle` which can be redistributed without the need to install anything (including Adobe AIR Runtime).

## Flex
Dir `flexair` obtained by downloading Flex from https://www.apache.org/dyn/closer.lua/flex/4.16.1/binaries/apache-flex-sdk-4.16.1-bin.zip and then AIRSDK_Flex_Windows being unpacked right on top of flex merging files.  
*libRuntime*.arm-air.a files was removed from `flexair` due to being too big to upload to github and they shouldn't be needed anyway (concludes from their names).
