:: Install Hyper-V host from custom WIM
::
:: Vision MS
:: Van Donley
:: 11/06/2018
::
:: Assume OS disk is going to be disk 0. Use DiskPart-Partitions.txt script
:: to prepare the disk for the image. Write out log file for troubleshooting.
::
@echo off
::
echo Preparing disk
diskpart /s DiskPart-Partitions.txt > DiskPart_Log.txt
::
:: Display the log and wait for input
echo ---------------------
echo Check DiskPart log for errors
echo ---------------------
type DiskPart_Log.txt | more
pause
::
::  Get the list of volumes for the driveletter of the WIM files
:LISTVOLUMES
echo ---------------------
diskpart /s DiskPart-ListVolumes.txt
echo ---------------------
echo Pick the drive letter with the WIM files from above
set /p answer=Enter selection - letter only:  
:: Test the path to the WIM files
:TESTPATH
if exist "%answer%:\HyperV_Template\Windows.wim" (
    cls
    echo WIM file not found, try another drive
    goto LISTVOLUMES 
)
:: Install the WIM files
mkdir W:\ScratchDir
dism /apply-image /imagefile:%answer%:\HyperV_Template\Windows.wim /index:1 /applydir:W:\ /ScratchDir:W:\ScratchDir
dism /apply-image /imagefile:%answer%:\HyperV_Template\SystemReserved.wim /index:1 /applydir:S:\ /ScratchDir:W:\ScratchDir
:: Make it bootable
W:\Windows\System32\bcdboot W:\Windows /s S:
:: Setup recovery partition
mkdir R:\Recovery\WindowsRE
xcopy /h W:\Windows\System32\Recovery\WinRE.wim R:\Recovery\WindowsRE\
W:\Windows\System32\reagentc /setreimage /path R:\Recovery\WindowsRE /target W:\Windows
pause
