Begin:
:: Shutdown_Suncoast.bat - deployed with 7.3.1 Version 110 Released August 4, 2015
:: Shutdown_Suncoast.bat - deployed with 6.3.3
:: Stops the databases, services, clears protrace files, clears progress temp files, and ::oves admsvr.lock
:: This is intended to be run prior to rebooting a server.   
:: 09-27-10 SFF
:: 05-03-12 MM
:: 06-12-12 MM - added ::oval of admsvr.lock
@Echo off
::
:: Generate date/time stamp
SET HOUR=%time:~0,2%
SET dtStamp9=%date:~-4%_%date:~4,2%_%date:~7,2%-0%time:~1,1%%time:~3,2%%time:~6,2% 
SET dtStamp24=%date:~-4%_%date:~4,2%_%date:~7,2%-%time:~0,2%%time:~3,2%%time:~6,2%
:: Get correct format if the first character is a 0 in time
if "%HOUR:~0,1%" == " " (SET dtStamp=%dtStamp9%) else (SET dtStamp=%dtStamp24%)
::
:: ** Set Variables **
:: --------------------
set drive=d
set dlc=d:\sun\dlc64
set path=d:\sun\dlc64\bin;%path%
set trainpath=\sun\suncoast\db\training
set prodpath=\sun\suncoast\db\production
set protracepath=\sun\suncoast
set prod_log=Production-%dtStamp%.log
set fdb_log=FDB-%dtStamp%.log
::
:: Create a folder for the logs if it doesn't already exist
set RebootLogDir="C:\SC_RebootLogs"
IF not exist %RebootLogDir% MKDIR %RebootLogDir%
set RebootLogFile=%RebootLogDir%\SC_Reboot_Log-%dtStamp%.txt
::
:: ** Start log file **
:: -------------------
ECHO ********************** >>%RebootLogFile%
ECHO Starting Reboot - %date% - %time%  >>%RebootLogFile%
ECHO . >> %RebootLogFile%
:: ------------------------------
ECHO ** Stop Solutions Services ** >>%RebootLogFile%
:: ------------------------------
Net stop "SolutionsService" >>%RebootLogFile%
Net stop "SolutionsService-training" >>%RebootLogFile%
Net stop "MDPortal" >>%RebootLogFile%
Net stop "SolutionsEnterpriseServiceHost" >>%RebootLogFile%
:: ------------------------------
ECHO . >>%RebootLogFile%
ECHO ** Stop Databases ** >>%RebootLogFile%
:: --------------------
%drive%:
::
ECHO --Production >>%RebootLogFile%
cd %prodpath%
START /wait proshut -by production >>%RebootLogFile%
START /wait proshut -by fdb >>%RebootLogFile%
ECHO . >>%RebootLogFile%
ECHO --Training >>%RebootLogFile%
cd %trainpath%
START /wait proshut -by training >>%RebootLogFile%
START /wait proshut -by fdb >>%RebootLogFile%
ECHO . >>%RebootLogFile%
::
ECHO ** Stop Progress Services default is 64-bit ** >>%RebootLogFile%
:: ----------------------------
Net stop "AdminService11.6(64-bit)" >>%RebootLogFile%
::
ECHO . >>%RebootLogFile%
ECHO ** Clear Protrace Files ** >>%RebootLogFile%
:: --------------------------
%drive%:
cd %protracepath%
erase protrace* >>%RebootLogFile%
ECHO . >>%RebootLogFile%
ECHO ** Clear admsvr.lock file ** >>%RebootLogFile%
:: --------------------------
%drive%:
cd \
cd \sun\oemgmt\config
erase admsvr.lock >>%RebootLogFile%
ECHO . >>%RebootLogFile%
ECHO ** CLEAR C:\TEMP ** >>%RebootLogFile%
:: ----------------
c:
cd \
cd \temp
erase lib* >>%RebootLogFile%
erase dbi* >>%RebootLogFile%
erase rcda* >>%RebootLogFile%
erase srta* >>%RebootLogFile%
erase trans*.log >>%RebootLogFile%
ECHO . >>%RebootLogFile%
ECHO Backup & Trim the Current DB Logs >>%RebootLogFile%
:: ---------------------------------
%drive%:
cd %prodpath%
copy production.lg %prod_log%
copy fdb.lg        %fdb_log%
START /wait prolog production >>%RebootLogFile%
START /wait prolog fdb >>%RebootLogFile%
::
ECHO . >>%RebootLogFile%
ECHO ** Shutdown Process Completed ** >>%RebootLogFile%
ECHO . >>%RebootLogFile%
ECHO . >>%RebootLogFile%
EXIT