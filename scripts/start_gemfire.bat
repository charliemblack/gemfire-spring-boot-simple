@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

PUSHD %~dp0..
IF NOT DEFINED APP_HOME SET APP_HOME=%CD%
POPD

set DEFAULT_LOCATOR_MEMORY="128m"

set DEFAULT_SERVER_MEMORY="1g"

set DEFAULT_JVM_OPTS=--mcast-port=0

set LOCATORS=localhost[10334]

set COMMON_LOCATOR_ITEMS=--initial-heap=%DEFAULT_LOCATOR_MEMORY%
set COMMON_LOCATOR_ITEMS=%COMMON_LOCATOR_ITEMS% --max-heap=%DEFAULT_LOCATOR_MEMORY%
set COMMON_LOCATOR_ITEMS=%COMMON_LOCATOR_ITEMS% --locators=%LOCATORS%
set COMMON_LOCATOR_ITEMS=%COMMON_LOCATOR_ITEMS% %DEFAULT_JVM_OPTS%

mkdir %APP_HOME%\data\locator1

call gfsh -e "start locator --name=locator1 --dir=%APP_HOME%/data/locator1 --port=10334 %COMMON_LOCATOR_ITEMS%"  -e "configure pdx --read-serialized=true --disk-store=DEFAULT"

mkdir %APP_HOME%\data\server1
mkdir %APP_HOME%\data\server2

set COMMON_SERVER_ITEMS=--J=-Xmx%DEFAULT_SERVER_MEMORY% --J=-Xms%DEFAULT_SERVER_MEMORY%
set COMMON_SERVER_ITEMS=%COMMON_SERVER_ITEMS% %DEFAULT_JVM_OPTS%
set COMMON_SERVER_ITEMS=%COMMON_SERVER_ITEMS% --server-port=0
set COMMON_SERVER_ITEMS=%COMMON_SERVER_ITEMS% --rebalance

start "startingGemFireServer" /min  cmd /c gfsh -e "connect --locator=%LOCATORS%" -e "start server --name=server1 --dir=%APP_HOME%/data/server1  %COMMON_SERVER_ITEMS%"
start "startingGemFireServer" /min  cmd /c gfsh -e "connect --locator=%LOCATORS%" -e "start server --name=server2 --dir=%APP_HOME%/data/server2  %COMMON_SERVER_ITEMS%"

:LOOP
tasklist /v | find /i "STARTINGGEMFIRESERVER" >nul 2>&1
IF ERRORLEVEL 1 (
  GOTO CONTINUE
) ELSE (
  ECHO GemFire is starting
  Timeout /T 5 /Nobreak
  GOTO LOOP
)

:CONTINUE