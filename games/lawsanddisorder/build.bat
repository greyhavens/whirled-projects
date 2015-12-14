::
:: build.bat
::
:: Builds and runs the game in the test environment

@echo off

::
:: Change this number to test with more or fewer players
::
set PLAYERS=1

set CP=..\dist\lib\ant-launcher.jar;..\dist\lib\ant.jar
set CLASS=org.apache.tools.ant.launch.Launcher
java -classpath %CP% %CLASS% -Dplayers=%PLAYERS% clean test
pause
