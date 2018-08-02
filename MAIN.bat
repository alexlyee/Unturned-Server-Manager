REM                     Yes I understand this program is free, free to copy and all.
REM                      I hope you (as an awesome person) can keep my name on the product for it ^.^
REM                       Feel free to make any modifications and submit them to me!! I'd love to credit you for helping out in the patch notes! And in the program! :)
REM                        My project resources are at https://github.com/alexlyee/Unturned-Server-Manager

@echo off
cls
echo.
echo  // Requesting admin...
REM                                              Get admin \/
IF '%PROCESSOR_ARCHITECTURE%' EQU 'amd64' (
   >nul 2>&1 "%SYSTEMROOT%\SysWOW64\icacls.exe" "%SYSTEMROOT%\SysWOW64\config"
 ) ELSE (
   >nul 2>&1 "%SYSTEMROOT%\system32\icacls.exe" "%SYSTEMROOT%\system32\config"
)
if '%errorlevel%' NEQ '0' ( goto UACPrompt ) else ( goto gotAdmin )
:UACPrompt
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
set params = %*:"=""
echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params%", "", "runas", 3 >> "%temp%\getadmin.vbs"
"%temp%\getadmin.vbs"
del "%temp%\getadmin.vbs"
exit /B
:gotAdmin
pushd "%CD%"
CD /D "%~dp0"
echo.
echo  // // Intilizing...
REM                                              Start Section \/
REM                           1#.2#.3# - 1> Major changes, you need to reinstall.
REM                                      2> Significant changes, need to redo filesystem.
REM                                      3> Minor changes, nothing needed.
														set VMajor=2
														set VMiddle=8
														set VMinor=11
set V=%VMajor%.%VMiddle%.%VMinor%
title Untured Server Manager! V%V%
setlocal EnableDelayedExpansion EnableExtensions
REM                                              Get Time \/
echo.
echo  // Catching time...
For /F "tokens=1,2,3,4 delims=:,. " %%A in ('echo %time%') do (
  set "Hour24=%%A"
  set "Min=%%B"
  set "Sec=%%C"
  set "MSec=%%D"
)
For /F "tokens=1,2,3,4 delims=/ " %%A in ('Date /t') do (
  Set "DayW=%%A"
  Set "Day=%%B"
  Set "Month=%%C"
  Set "Year=%%D"
)
set "Hour12=%Hour24%"
if %Hour12% geq 12 (
  set AMPM=PM
  set /a "Hour12-=12"
) else set "AMPM=AM"
if /I {%Hour12%}=={0} (set "Hour12=12")
REM                                              Update Checker. \/
echo.
echo  // Searching for git install...
WHERE git >Nul
IF %ERRORLEVEL% NEQ 0 goto :InstallGIT
echo.
echo  // Looking for program update online... 
>nul git init
>nul git remote add master https://github.com/alexlyee/Unturned-Server-Manager
for /f %%a in ('git pull --allow-unrelated-histories -f https://github.com/alexlyee/Unturned-Server-Manager master ^| findstr "Updating"') do set update=%%a
if /I NOT {%update%}=={} (goto :UpdateProgram)
echo .. All updated^!
echo.
echo  // Reading filesystem for updates...
REM												 File need update? \/
set /p Vfile=<"%CD%\MAIN_res\V.txt"
for /f "tokens=1,2,3 delims=." %%A in ("%Vfile%") do (set "VfileMajor=%%A" & set "VfileMiddle=%%B" & set "VfileMinor=%%C")
if not "%VfileMajor%"=="%VMajor%" (set "MajorUpdate=true")
if not "%VfileMiddle%"=="%VMiddle%" (set "MiddleUpdate=true")
if not "%VfileMinor%"=="%VMinor%" (set "MinorUpdate=true")
REM                                              START \/
:start
echo.
echo  // // // Starting...
REM Capturing starting time.
set t0=%time: =0%
echo.
echo  // Searching for Unturned...
REM                                              Ensure Unturned isn't running \/
set count=0
goto :findtask
:locatedtask
del search.txt
set /a count=%count% + 1
if NOT %count%==1 (goto :locatedtaskskip)
echo.
echo  Unturned is running currently.
echo  1 // View plots and graphs on your server. -- maybe i'll get this done, maybe i wont
echo  2 // All unturned tasks will be shutdown forcefully.
echo  Otherwise, it will return to the start and reprocess.
echo.
set /p "choice= - "
if /I {%choice%}=={1} (goto :monitor)
if /I NOT {%choice%}=={2} (goto :start)
:locatedtaskskip
echo Unturned task found^! Try %count%
taskkill /IM Unturned.exe /F
:findtask
tasklist /FI "IMAGENAME eq Unturned.exe" /FO CSV > search.txt 
ping 192.0.2.2 -n 1 -w 10 > nul
for %%A in (search.txt) do (
	if /I NOT {%%~zA}=={64} (
		goto :locatedtask
	)
)
if %count%==0 (
	echo  .. No Unturned Tasks Found!
) else (
	echo  .. No More Unturned Tasks Found!
)
del search.txt
echo.
echo  // Are directories ready for the program?
REM                                              Detect if files need refresh... \/
if NOT EXIST "%CD%\MAIN_res\V.txt" (
	echo.
	echo  Building program filesystem... [Filesystem not done]
	echo  ...... This will compile the necessary files in this current directory for the program to function.
	echo.
	set "build=true"
	goto :build
)
echo  .. Yep
REM                                              Analyze auto... \/
echo.
echo  // Finding set automations...
set autocount=0
for /F "delims=" %%A in ('dir /b "%CD%\MAIN_res\auto"') do (
	set /a "autocount=!autocount! + 1"
	set "auto!autocount!=%%A"
	for /F "tokens=1 delims=." %%B in ('dir /b "%CD%\MAIN_res\auto\%%A"') do (
		set "auto!autocount!.type=%%B"
	)
)
REM                                              Analyze plugins... \/
echo.
echo  // Finding set plugins...
if EXIST  "%CD%\MAIN_res\plugins\plugins.txt" (
	set /p plugins=<"%CD%\MAIN_res\plugins\plugins.txt"
	if /I {!plugins!}=={} (del "%CD%\MAIN_res\plugins\plugins.txt")
)
set count=0
if EXIST  "%CD%\MAIN_res\plugins\plugins.txt" (
	for /F "usebackq tokens=*" %%A in ("%CD%\MAIN_res\plugins\plugins.txt") do (
		set /a "count=!count! + 1"
		set "plugincount=!count!"
		set "plugin!count!=%%A"
	)
)
if NOT EXIST "%CD%\MAIN_res\plugins\plugins.txt" (set plugincount=0)
echo.
echo  // Is the system up-to-date^?
REM                                              Detect if files need refresh... \/
if /I {%MajorUpdate%}=={true} (
	echo.
	echo  Building program filesystem... [Updating] [Major Update]
	echo  ...... This will compile the necessary files in this current directory for the program to function.
	echo.
	goto :build
)
if /I {%MiddleUpdate%}=={true} (
	echo.
	echo  Building program filesystem... [Updating]
	echo  ...... This will compile the necessary files in this current directory for the program to function.
	echo.
	goto :build
)
if /I {%MinorUpdate%}=={true} (
	del /Q "%CD%\MAIN_res\V.txt"
	echo %V%>"%CD%\MAIN_res\V.txt"
)
set /p Dfile=<"%CD%\MAIN_res\Directory.txt"
if /I NOT "%Dfile%"=="%~dp0" (
	echo.
	echo  Building program filesystem... [Change in directory]
	echo  ...... This will compile the necessary files in this current directory for the program to function.
	echo.
	goto :build
)
echo  .. Yep
echo.
echo  // Applying variables...
set /p serverusername=<"%CD%\MAIN_res\username.txt"
set /p serverpassword=<"%CD%\MAIN_res\password.txt"
echo.
echo  // Checking for SteamCMD...
REM                                              Install steamcmd if needed. \/
if not {%SteamCMD%}=={true} (if EXIST "%CD%\steamcmd\steamcmd.exe" (goto :SkipSteamCMD))
REM This will install and manage SteamCMD, which grabs updates for your game without the Steam client.
cls
echo.
echo  The program will now // Install SteamCMD.
echo  ...... This will install and manage SteamCMD, which grabs updates for your game without the Steam client.
echo.
echo  Press any key to continue.
pause>nul
:FixSteamCMD
echo.
echo  Downloading SteamCMD...
cscript //nologo "%CD%\MAIN_res\steamcmd.vbs"
echo.
echo  Extracting SteamCMD...
cscript //nologo "%CD%\MAIN_res\extract.vbs"
echo.
echo  Deleting download...
>NUL del /f /q "%CD%\MAIN_res\downloads\current.zip"
echo.
echo  Moving SteamCMD to "%CD%\steamcmd"
mkdir "%CD%\steamcmd"
>nul robocopy /move /e "%CD%\MAIN_res\unzipped\current" "%CD%\steamcmd"
echo.
echo  Building SteamCMD filesystem... 
echo   // To view progress, open the "Building SteamCMD filesystem..." window.
>NUL start "Building SteamCMD filesystem..." /WAIT /MIN /HIGH "%CD%\steamcmd\steamcmd.exe" +exit
goto :SkipSteamLoginBroke
	:SteamLoginBroke
	echo.
	echo  I've opened up the error file, take a look. Close when you're done.
	notepad "%CD%\temp.txt"
	echo  I've noticed the most simple error is steam gaurd.
	echo  // Enter 1 if you want me to take you to the page to disable it!
	echo  // Enter 2 if you want to reset your username and password!
	echo  // Enter anything else to continue.
	set "choice="
	set /P "choice= - "
	if /I {%choice%}=={1} (start "" https://store.steampowered.com/twofactor/manage)
	if /I {%choice%}=={2} (goto :ResetSteamAccount)
	goto :SkipResetSteamAccount
	:ResetSteamAccount
	echo.
	echo  If you haven't yet, you may want to make a SEPERATE steam account for the server.
	echo  Use an email you would want to check for info on your server.
	echo  You will need to have one, make sure it has Unturned.
	echo.
	set /p "username= Enter your Steam username: "
	set /p "password= Enter your Steam password: "
	echo.
	echo  Applying...
	goto :SkipBuildPlugins
	:SkipResetSteamAccount
	del /Q "%CD%\temp.txt"
	echo  Sending you back to the login process...
	:SkipSteamLoginBroke
echo.
echo  Logging you in for the first time...
echo   // If it doesn't log you in right away:
echo      // Try to complete logging in, then enter "logout"
echo      // If you can login without entering anything but "login %serverusername% %serverpassword%", you're golden.
echo.
:RetrySteamCMD
>NUL start "" /WAIT /MIN "%CD%\steamcmd\steamcmd.exe" +login %serverusername% %serverpassword%
echo.
echo If that did not work, type N.
set "choice="
set /P "choice= - "
if /I {%choice%}=={N} (goto :RetrySteamCMD)
set "SteamCMD="
goto :start
:SkipSteamCMD
echo.
echo  // Attempting Steam Login...
>"%CD%\temp.txt" call "%CD%\steamcmd\steamcmd.exe" +login %serverusername% %serverpassword% +info +quit
for /f "skip=2 tokens=1,2,3" %%A in ('find "Email: " temp.txt') do (echo %%B>"%CD%\MAIN_res\email.txt")
for /f "skip=2 tokens=1,2" %%A in ('find "SteamID: " temp.txt') do (echo %%B>"%CD%\MAIN_res\steamid.txt")
if NOT EXIST "%CD%\MAIN_res\email.txt" goto :SteamLoginBroke
if NOT EXIST "%CD%\MAIN_res\steamid.txt" goto :SteamLoginBroke
del /Q "%CD%\temp.txt"
echo.
echo  // Checking for Unturned...
if not {%Unturned%}=={true} (if EXIST "%CD%\unturned" (goto :LS_SkipUnturned))
:LS_UnturnedInstall
cls
echo.
echo  The program will now // Deploy an Unturned server.
echo  ...... This will use SteamCMD to download and install an unturned gamefile. Overwriting any current Unturned server.
echo  ...... Ensure you are SUBSCRIBED to Unturned by logging in and pressing "Play".
echo.
echo  Press any key to continue.
pause>nul
REM This will use SteamCMD to download and install an unturned gamefile. Overwriting any current Unturned server.
echo.
echo  Installing Unturned through SteamCMD...
echo   // To view progress, open the "Installing Unturned through SteamCMD..." window.
start "Installing Unturned through SteamCMD..." /WAIT /MIN /HIGH "%CD%\steamcmd\steamcmd.exe" +login %serverusername% %serverpassword% +force_install_dir ..\unturned\ +app_update 304930 +exit
echo.
echo  Choose a type of server:
echo  Is it a "lanserver", "secureserver", or "insecureserver"^?
echo.
set /p "servertype2= "
echo %servertype2%>"%CD%\MAIN_res\server.txt"
mkdir "%CD%\unturned\Servers"
cls
echo.
echo  Use command shutdown once done loading.
echo   // Type the command "shutdown" into the server once it is done loading for the first time.
start "Use command shutdown once done loading." /D "%CD%\unturned" /MAX /HIGH /WAIT "%CD%\unturned\Unturned.exe" -nographics -batchmode +%servertype2%/ManagedServer
REM                                      setup server!
set "Unturned="
goto :start
:LS_SkipUnturned
REM Begin to use LS_ as the marker for before loadstart.
echo.
echo  // Finishing loading...
set /p servertype=<"%CD%\MAIN_res\server.txt"
set /p owneremail=<"%CD%\MAIN_res\email.txt"
set /p ownersteamid=<"%CD%\MAIN_res\steamid.txt"
@echo off
REM Processing time to initialize.
setlocal
set t=%time: =0%

set /a h=1%t0:~0,2%-100
set /a m=1%t0:~3,2%-100
set /a s=1%t0:~6,2%-100
set /a c=1%t0:~9,2%-100
set /a starttime = %h% * 360000 + %m% * 6000 + 100 * %s% + %c%

set /a h=1%t:~0,2%-100
set /a m=1%t:~3,2%-100
set /a s=1%t:~6,2%-100
set /a c=1%t:~9,2%-100
set /a endtime = %h% * 360000 + %m% * 6000 + 100 * %s% + %c%

set /a runtime = %endtime% - %starttime%
set runtime = %s%.%c%
REM converting to ms.
set /a runtime = %runtime% * 10
echo.
echo  // Done^!
cls
:skiploadstart
echo.
echo  Unturned Server Manager V%V%  //  Made by Alex Lindstrom (steam~ alexlyee)
echo                                 // took %runtime%ms to startup.
echo  Logged in to %owneremail% %ownersteamid%. Hosting server type %servertype%
echo.
if EXIST "%CD%\MAIN_res\Hide.txt" goto :SkipYMenuMessage
echo  Make sure you don't click inside of this program; whenever you select anything in CMD,
echo  it pauses the script^! Type Y to hide this message.
:SkipYMenuMessage
echo.
echo.
echo  1 // Extract the newest Rocket mod.
echo  ...... This will download and apply the newest Rocket mod file to Unturned.
echo.
echo  2 // Extract set Rocket plugins.
echo  ...... This will download and apply the newest Rocket plugins you've set. Or set the plugins.
echo.
echo  3 // Apply the latest Unturned update.
echo  ...... This will download and update Unturned to it's newest form.
echo.
echo         /\
echo         \/
echo.
echo  4 // Help me host.
echo  ...... This will help you in hosting Untured servers in any way possible.
echo.
echo  5 // Change settings.
echo  ...... This will let you change things like your steam username and password that the server uses.	
echo.
echo  6 // Start server.
echo  ...... Starts the server.
echo.
echo  7 // Fix SteamCMD.
echo  ...... Go through the SteamCMD initialization process once more.
echo.
echo  8 // Fix Unturned.
echo  ...... Go through the Unturned installation process once more.
echo.
echo    // Press enter to exit properly please.
echo.
echo  9 // Edit the automatic updater and/or server restart system. // NOT WORKING
echo  ...... This will enable the program to keep your mods updated and your server running with them. :^)
echo.
echo.
set "choice="
set /p "choice= - Pick: "
if /I {%choice%}=={} (goto :exit)
if /I {%choice%}=={1} (goto :1)
if /I {%choice%}=={2} (goto :2)
if /I {%choice%}=={3} (goto :3)
if /I {%choice%}=={4} (goto :4)
if /I {%choice%}=={5} (goto :5)
if /I {%choice%}=={6} (goto :6)
if /I {%choice%}=={7} (goto :7)
if /I {%choice%}=={8} (goto :8)
if /I {%choice%}=={9} (goto :9)
if /I {%choice%}=={Y} (echo Hide) >"%CD%\MAIN_res\Hide.txt"
goto :start
REM /////////////////////////////////////////////////////// functions below
:1
REM 100%!
REM This will download and apply the newest Rocket mod file to Unturned.
echo  If you see errors. Then it did not download correctly.
echo.
echo  Downloading the Rocket patch...
cscript //nologo "%CD%\MAIN_res\rocket.vbs"
echo.
echo  Unzipping the file...
cscript //nologo "%CD%\MAIN_res\extract.vbs"
echo.
echo  Deleting download...
del /f /q "%CD%\MAIN_res\downloads\current.zip"
echo.
echo  Applying Rocket to Unturned...
>nul robocopy /move /e "%CD%\MAIN_res\unzipped\current" "%CD%\unturned"
echo.
echo  Deleting unzipped folder...
>nul rmdir /S /Q "%CD%\MAIN_res\unzipped\current"
echo.
pause
goto :start
:2
REM This will download and apply the newest Rocket plugins you've set. Or set the plugins.
if EXIST "%CD%\MAIN_res\plugins\plugins.txt" (goto :2skip)
echo.
echo  You may still have other plugins, this will only manage the one's you want for you.
echo  You currently have no plugins to manage. If you would like to add some, type "Y".
echo.
set /P "choice= - "
if /I {%choice%}=={Y} (goto :21)
goto :start
:2skip
REM This will list all of the plugins.
echo.
echo  Scanning plugin list...
echo.
echo  Plugins: %plugincount%
for /l %%A in (1,1,%plugincount%) do (echo  // Plugin %%A - !plugin%%A!)
echo.
echo  You may still have other plugins, this will only manage the one's you want for you.
echo.
echo  1 - Change plugins to manage.
echo  2 - Update all plugins.
echo.
set /p "choice= "
if %choice%==1 (goto :21)
if %choice%==2 (goto :22)
goto :start
	:21
	REM This will relist all of the plugins
	echo.
	echo  Here you can add all the plugins you want.
	echo  Enter them all seperated by ONLY a comma.
	echo  Go to the rocket plugins page, and find all of the plugins.
	echo.
	echo  For EACH PLUGIN, look at the link, like: 
	echo  "https://hub.rocketmod.net/product/plugins/PLUGINNAME/"
	echo  Enter the "PLUGINNAME" part of the link as the plugin only^! Otherwise this won't work^!
	echo.
	echo  This will completely delete the list and them add them all back, so add all the plugins here!
	echo  If you want no plugins, type nothing.
	echo.
	set /p "plugins= "
	if EXIST "%CD%\MAIN_res\plugins\plugins.txt" (del "%CD%\MAIN_res\plugins\plugins.txt")
	set plugincount=0
	for %%A in ("%plugins:,=" "%") do (
		echo.
		echo  Adding %%A to memory...
		set "plugintemp=%%A"
		set "plugintemp=!plugintemp:"=!
		set /a "plugincount=!plugincount! + 1"
		set "plugin!plugincount!=!plugintemp!"
		echo  // Added !plugintemp!.
	)
	echo.
	echo    // Totaled %plugincount% plugin/s.
	for /l %%A in (1,1,%plugincount%) do (
		echo  // Adding !plugin%%A! to plugin list... #%%A
		if %%A==1 (
			echo !plugin%%A!>"%CD%\MAIN_res\plugins\plugins.txt"
		)
		if NOT %%A==1 (
			echo !plugin%%A!>>"%CD%\MAIN_res\plugins\plugins.txt"
		)
	)
	set count=0
	if %plugincount%==0 (goto :start)
	echo.
	echo    // Forming download scripts for each plugin...
		:21loop
		set /a "count=%count% + 1"
		for /l %%A in (1,1,%plugincount%) do (
			if %%A==%count% (
				set "tempplugin=!plugin%%A!"
			)
		)
		echo.
		echo  // Developing download script for %tempplugin%... %count%/%plugincount%.
		del /Q "%CD%\MAIN_res\plugins\%tempplugin%.vbs" >nul
		echo strFileURL="https://hub.rocketmod.net/product/%tempplugin%/latest.zip">"%CD%\MAIN_res\plugins\%tempplugin%.vbs"
		echo strHDLocation = "%CD%\MAIN_res\downloads\current.zip">>"%CD%\MAIN_res\plugins\%tempplugin%.vbs"
		echo Set objXMLHTTP = CreateObject("MSXML2.XMLHTTP")>>"%CD%\MAIN_res\plugins\%tempplugin%.vbs"
		echo objXMLHTTP.open "GET", strFileURL, false>>"%CD%\MAIN_res\plugins\%tempplugin%.vbs"
		echo objXMLHTTP.send()>>"%CD%\MAIN_res\plugins\%tempplugin%.vbs"
		echo If objXMLHTTP.Status = 200 Then>>"%CD%\MAIN_res\plugins\%tempplugin%.vbs"
		echo Set objADOStream = CreateObject("ADODB.Stream")>>"%CD%\MAIN_res\plugins\%tempplugin%.vbs"
		echo objADOStream.Open>>"%CD%\MAIN_res\plugins\%tempplugin%.vbs"
		echo objADOStream.Type = 1 >>"%CD%\MAIN_res\plugins\%tempplugin%.vbs"
		echo objADOStream.Write objXMLHTTP.ResponseBody>>"%CD%\MAIN_res\plugins\%tempplugin%.vbs"
		echo objADOStream.Position = 0 >>"%CD%\MAIN_res\plugins\%tempplugin%.vbs"
		echo Set objFSO = Createobject("Scripting.FileSystemObject")>>"%CD%\MAIN_res\plugins\%tempplugin%.vbs"
		echo If objFSO.Fileexists(strHDLocation) Then objFSO.DeleteFile(strHDLocation)>>"%CD%\MAIN_res\plugins\%tempplugin%.vbs"
		echo Set objFSO = Nothing>>"%CD%\MAIN_res\plugins\%tempplugin%.vbs"
		echo objADOStream.SaveToFile strHDLocation>>"%CD%\MAIN_res\plugins\%tempplugin%.vbs"
		echo objADOStream.Close>>"%CD%\MAIN_res\plugins\%tempplugin%.vbs"
		echo Set objADOStream = Nothing>>"%CD%\MAIN_res\plugins\%tempplugin%.vbs"
		echo End if>>"%CD%\MAIN_res\plugins\%tempplugin%.vbs"
		echo Set objXMLHTTP = Nothing>>"%CD%\MAIN_res\plugins\%tempplugin%.vbs"
		if NOT %count%==%plugincount% (goto :21loop)
		:21loopend
	echo.
	echo  Now that that's done, you can download the plugin/s.
	echo  If you would like to apply the plugins now, type "Y".
	echo.
	set /p "choice= "
	if /I {%choice%}=={Y} (goto :22)
	goto :start
	:22
	echo.
	echo  Scanning plugin list...
	echo.
	echo  Plugins: %plugincount%
	for /l %%A in (1,1,%plugincount%) do (
		echo  // Plugin %%A - !plugin%%A!
	)
	echo.
	echo.
	echo  Installing plugins...
	echo.
	set count=0
	:22loop
	set /a "count=%count% + 1"
	for /l %%A in (1,1,%plugincount%) do (
		if %%A==%count% (
			set "tempplugin=!plugin%%A!"
		)
	)
	echo      // Adding Plugin %count% - %tempplugin%
	echo     // Downloading package...
	cscript //nologo "%CD%\MAIN_res\plugins\%tempplugin%.vbs"
	echo    // Extracting file...
	cscript //nologo "%CD%\MAIN_res\extract.vbs"
	echo   // Applying plugin...
	>nul robocopy /move /e "%CD%\MAIN_res\unzipped\current" "%CD%\unturned\Servers\ManagedServer\Rocket\Plugins"
	echo  // Cleaning up remnence...
	>nul rmdir /S /Q "%CD%\MAIN_res\unzipped\current"
	if NOT %count%==%plugincount% (goto :22loop)
	:22loopend
	echo.
	echo  Done.
	echo  Take note you should start the server up and make sure all of the plugins are still compatible :D
	echo  Press any key to let me know you read that.
	pause>nul
	goto :start
	
:3
REM 100%!
REM This will download and update Unturned to it's newest form.
echo.
echo  Downloading and installing latest Unturned update.
echo   // To view progress, open the "Downloading and installing latest Unturned update..." window.
>NUL start "Downloading and installing latest Unturned update..." /WAIT /MIN /HIGH "%CD%\steamcmd\steamcmd.exe" +login %serverusername% %serverpassword% +force_install_dir ..\Unturned +app_update 304930 +exit
exit

:4
REM 50%!
REM This will help you in hosting Untured servers in any way possible.
for /f "tokens=2 delims=: " %%A in (
  'nslookup myip.opendns.com. resolver1.opendns.com 2^>NUL^|find "Address:"'
) Do set ExternalIP=%%A
for /f "tokens=2 delims=:" %%a in ('ipconfig^|find "IPv4 Address"') do (set InternalIP=%%a)
for /f "tokens=2 delims=:" %%a in ('ipconfig^|find "Default Gateway"') do (set DefaultGateway=%%a)
echo.
echo  Assuming this system is connected to a router, through a modem:
echo   - Make sure you have port forwarded the ports around your server (ex. 27015-27017)
echo   - Ensure your firewall is not blocking these, ports. Visit the advanced firewall control and open them up for all traffic.
echo   - Start by checking if you can connect to your server locally before you share it!
echo       - Do this by direct connecting to your server from another computer.
echo   - You should create a static lease to this computer on your network.
echo   - Although I've never found it useful, the DMZ zone may be of use if all else fails.
echo.
echo  If you're still having issues:
echo   - Check the modem, it is possible it is responsible for blocking traffic, 
echo       - you may want to simply connect this server directly to the modem.
echo   - Check the files, commands.dat should have a port and bind command in there.
echo   - If you can't connect from this computer, the problem is with this computer.
echo   - If you can connect from this subnet, but not outside it, the problem is most likely with the router.
echo.
echo  ExternalIP:  %ExternalIP%
echo  InternalIP: %InternalIP%
echo  Default Gateway: %DefaultGateway%
echo.
pause
goto :start

:5
REM 100%!
REM This will let you change things like your steam username and password that the server uses.	
echo.
echo  1 - Change steam username
echo  2 - Change steam password
echo  3 - Change server type
echo.
set "choice="
set /p "choice= - Pick: "
if /I {%choice%}=={} (goto :exit)
if /I {%choice%}=={1} (goto :51)
if /I {%choice%}=={2} (goto :52)
if /I {%choice%}=={3} (goto :53)
goto :start
:51
	echo.
	set /p "username= Enter your Steam username: "
	echo.
	echo  Applying...
	del "%CD%\MAIN_res\username.txt">nul
	echo !username!>"%CD%\MAIN_res\username.txt"
	goto :start
:52
	echo.
	set /p "password= Enter your Steam password: "
	echo.
	echo  Applying...
	del "%CD%\MAIN_res\username.txt">nul
	echo !password!>"%CD%\MAIN_res\username.txt"
	goto :start
:53
	echo.
	echo  Is it a "lanserver", "secureserver", or "insecureserver"^?
	echo.
	set /p "servertype2= "
	del "%CD%\MAIN_res\server.txt">nul
	echo %servertype2%>"%CD%\MAIN_res\server.txt"
	goto :start


:6
REM Starts the server.
goto :server


:7
REM Skips back to the Start of SteamCMD installation.
goto :FixSteamCMD

:8
REM Skips back to the start of Unturned installation.
echo.
goto :LS_UnturnedInstall


:9
REM This will enable the program to keep your mods updated and your server running with them.
echo.
echo  Welcome to my automatic task scheduler^!
echo  This will allow you to commit FUNCTIONS for ACTIVATORS.
echo  In essence, this means you can customize something that will activate a function. That you can also modify.
echo  Every activator and function are designed by me. But are made to be changed to your liking! :)
echo  A function triggered by an activator is called a task.
echo.
echo  It is a basic automator, I will expand on it in the future. The hard part is getting it working!
echo.
echo  1 // Create an activator
echo  2 // Create a function
echo  3 // Create a task
echo  4 // View, edit, and remove all
echo.
set "choice="
set /p "choice= - Enter option: "
if /I {%choice%}=={} (goto :start)
if /I {%choice%}=={1} (goto :81)
if /I {%choice%}=={2} (goto :82)
if /I {%choice%}=={3} (goto :83)
if /I {%choice%}=={4} (goto :84)
goto :start
	:91
	
	goto :start
	
	:92
	
	goto :start
	:93
	
	goto :start
	:94

	
	goto :start


REM sendemail function.
REM input to server function.
REM mobile mode. - designed for pop up use. make it fast, take all info on laptops battery.
REM allow for output of any variable through functions.
REM sendtext function.
REM this program can advertise.
REM onstartup server activations. and on exit.
REM all functions are activated through automation of tasks.
REM logging each line?
REM sifting each line. to variable.
REM self activated activator.

REM Start with activators, these are methods of initiating A function, it can be based on time, server start,
REM or a whole host of things!
REM Functions, are initiated by these activators, and make it automatic.
REM these functions are very customizable. But the limitations include:
REM - access to specific variables
REM - specific actions only; no creation of functions within functions.
REM - these functions commit actions, with one goal.
REM Together they are labeled, automations.
REM Showcase servers that advertise, let players play them instead of donating!

REM make a system for logging in through steam to use app.
REM also, you can choose to auto login (storing the password insecurely)
REM or you have to input it each time.
REM changing the steam account you are linked to (the one stored) will


:build
echo.
echo  / Generating folders...
mkdir "%CD%\MAIN_res\downloads">NUL
mkdir "%CD%\MAIN_res\plugins">NUL
mkdir "%CD%\MAIN_res\unzipped">NUL
mkdir "%CD%\MAIN_res\updater">NUL
mkdir "%CD%\MAIN_res\logs">NUL
mkdir "%CD%\MAIN_res\auto">NUL
mkdir "%CD%\MAIN_res\backups">NUL
echo.
echo  / Forming download and extract scripts...
echo strFileURL="https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip">"%CD%\MAIN_res\steamcmd.vbs"
echo strHDLocation = "%CD%\MAIN_res\downloads\current.zip">>"%CD%\MAIN_res\steamcmd.vbs"
echo Set objXMLHTTP = CreateObject("MSXML2.XMLHTTP")>>"%CD%\MAIN_res\steamcmd.vbs"
echo objXMLHTTP.open "GET", strFileURL, false>>"%CD%\MAIN_res\steamcmd.vbs"
echo objXMLHTTP.send()>>"%CD%\MAIN_res\steamcmd.vbs"
echo If objXMLHTTP.Status = 200 Then>>"%CD%\MAIN_res\steamcmd.vbs"
echo Set objADOStream = CreateObject("ADODB.Stream")>>"%CD%\MAIN_res\steamcmd.vbs"
echo objADOStream.Open>>"%CD%\MAIN_res\steamcmd.vbs"
echo objADOStream.Type = 1 >>"%CD%\MAIN_res\steamcmd.vbs"
echo objADOStream.Write objXMLHTTP.ResponseBody>>"%CD%\MAIN_res\steamcmd.vbs"
echo objADOStream.Position = 0 >>"%CD%\MAIN_res\steamcmd.vbs"
echo Set objFSO = Createobject("Scripting.FileSystemObject")>>"%CD%\MAIN_res\steamcmd.vbs"
echo If objFSO.Fileexists(strHDLocation) Then objFSO.DeleteFile(strHDLocation)>>"%CD%\MAIN_res\steamcmd.vbs"
echo Set objFSO = Nothing>>"%CD%\MAIN_res\steamcmd.vbs"
echo objADOStream.SaveToFile strHDLocation>>"%CD%\MAIN_res\steamcmd.vbs"
echo objADOStream.Close>>"%CD%\MAIN_res\steamcmd.vbs"
echo Set objADOStream = Nothing>>"%CD%\MAIN_res\steamcmd.vbs"
echo End if>>"%CD%\MAIN_res\steamcmd.vbs"
echo Set objXMLHTTP = Nothing>>"%CD%\MAIN_res\steamcmd.vbs"
REM  Github \/\/\/\/
echo strFileURL="https://github.com/git-for-windows/git/releases/download/v2.18.0.windows.1/Git-2.18.0-64-bit.exe">"%CD%\MAIN_res\git.vbs"
echo strHDLocation = "%CD%\MAIN_res\downloads\current.exe">>"%CD%\MAIN_res\git.vbs"
echo Set objXMLHTTP = CreateObject("MSXML2.XMLHTTP")>>"%CD%\MAIN_res\git.vbs"
echo objXMLHTTP.open "GET", strFileURL, false>>"%CD%\MAIN_res\git.vbs"
echo objXMLHTTP.send()>>"%CD%\MAIN_res\git.vbs"
echo If objXMLHTTP.Status = 200 Then>>"%CD%\MAIN_res\git.vbs"
echo Set objADOStream = CreateObject("ADODB.Stream")>>"%CD%\MAIN_res\git.vbs"
echo objADOStream.Open>>"%CD%\MAIN_res\git.vbs"
echo objADOStream.Type = 1 >>"%CD%\MAIN_res\git.vbs"
echo objADOStream.Write objXMLHTTP.ResponseBody>>"%CD%\MAIN_res\git.vbs"
echo objADOStream.Position = 0 >>"%CD%\MAIN_res\git.vbs"
echo Set objFSO = Createobject("Scripting.FileSystemObject")>>"%CD%\MAIN_res\git.vbs"
echo If objFSO.Fileexists(strHDLocation) Then objFSO.DeleteFile(strHDLocation)>>"%CD%\MAIN_res\git.vbs"
echo Set objFSO = Nothing>>"%CD%\MAIN_res\git.vbs"
echo objADOStream.SaveToFile strHDLocation>>"%CD%\MAIN_res\git.vbs"
echo objADOStream.Close>>"%CD%\MAIN_res\git.vbs"
echo Set objADOStream = Nothing>>"%CD%\MAIN_res\git.vbs"
echo End if>>"%CD%\MAIN_res\git.vbs"
echo Set objXMLHTTP = Nothing>>"%CD%\MAIN_res\git.vbs"
echo.
echo  // Creating shortcuts...
powershell "$s=(New-Object -COM WScript.Shell).CreateShortcut('%CD%\Rocket Website.lnk');$s.TargetPath='https://hub.rocketmod.net/';$s.Save()"
powershell "$s=(New-Object -COM WScript.Shell).CreateShortcut('%CD%\Server Files.lnk');$s.TargetPath='%CD%\unturned\Servers\ManagedServer';$s.Save()"
powershell "$s=(New-Object -COM WScript.Shell).CreateShortcut('%CD%\Server Manager.lnk');$s.WindowStyle=2;$s.TargetPath='%CD%\MAIN.bat';$s.IconLocation = '%CD%\MAIN_res\icon.ico';$s.Description ='Runs Server Manager Program';$s.WorkingDirectory ='%CD%';$s.Save()"
echo.
echo  / ...
echo strFileURL="https://ci.rocketmod.net/job/Rocket.Unturned/lastSuccessfulBuild/artifact/Rocket.Unturned/bin/Release/Rocket.zip">"%CD%\MAIN_res\rocket.vbs"
echo strHDLocation = "%CD%\MAIN_res\downloads\current.zip">>"%CD%\MAIN_res\rocket.vbs"
echo Set objXMLHTTP = CreateObject("MSXML2.XMLHTTP")>>"%CD%\MAIN_res\rocket.vbs"
echo objXMLHTTP.open "GET", strFileURL, false>>"%CD%\MAIN_res\rocket.vbs"
echo objXMLHTTP.send()>>"%CD%\MAIN_res\rocket.vbs"
echo If objXMLHTTP.Status = 200 Then>>"%CD%\MAIN_res\rocket.vbs"
echo Set objADOStream = CreateObject("ADODB.Stream")>>"%CD%\MAIN_res\rocket.vbs"
echo objADOStream.Open>>"%CD%\MAIN_res\rocket.vbs"
echo objADOStream.Type = 1 >>"%CD%\MAIN_res\rocket.vbs"
echo objADOStream.Write objXMLHTTP.ResponseBody>>"%CD%\MAIN_res\rocket.vbs"
echo objADOStream.Position = 0 >>"%CD%\MAIN_res\rocket.vbs"
echo Set objFSO = Createobject("Scripting.FileSystemObject")>>"%CD%\MAIN_res\rocket.vbs"
echo If objFSO.Fileexists(strHDLocation) Then objFSO.DeleteFile(strHDLocation)>>"%CD%\MAIN_res\rocket.vbs"
echo Set objFSO = Nothing>>"%CD%\MAIN_res\rocket.vbs"
echo objADOStream.SaveToFile strHDLocation>>"%CD%\MAIN_res\rocket.vbs"
echo objADOStream.Close>>"%CD%\MAIN_res\rocket.vbs"
echo Set objADOStream = Nothing>>"%CD%\MAIN_res\rocket.vbs"
echo End if>>"%CD%\MAIN_res\rocket.vbs"
echo Set objXMLHTTP = Nothing>>"%CD%\MAIN_res\rocket.vbs"
if exist "%CD%\MAIN_res\username.txt" (goto :skipBuildInput)
echo.
echo  If you haven't yet, you may want to make a SEPERATE steam account for the server.
echo  Use an email you would want to check for info on your server.
echo  You will need to have one, make sure it has Unturned.
echo.
set /p "username= Enter your Steam username: "
set /p "password= Enter your Steam password: "
:skipBuildInput
>"%CD%\MAIN_res\extract.vbs"  echo Set fso = CreateObject("Scripting.FileSystemObject")
>>"%CD%\MAIN_res\extract.vbs" echo If NOT fso.FolderExists("%CD%\MAIN_res\unzipped\current") Then
>>"%CD%\MAIN_res\extract.vbs" echo fso.CreateFolder("%CD%\MAIN_res\unzipped\current")
>>"%CD%\MAIN_res\extract.vbs" echo End If
>>"%CD%\MAIN_res\extract.vbs" echo set objShell = CreateObject("Shell.Application")
>>"%CD%\MAIN_res\extract.vbs" echo set FilesInZip=objShell.NameSpace("%CD%\MAIN_res\downloads\current.zip").items
>>"%CD%\MAIN_res\extract.vbs" echo objShell.NameSpace("%CD%\MAIN_res\unzipped\current").CopyHere(FilesInZip)
>>"%CD%\MAIN_res\extract.vbs" echo Set fso = Nothing
>>"%CD%\MAIN_res\extract.vbs" echo Set objShell = Nothing
echo strFileURL="https://raw.githubusercontent.com/alexly123/Unturned-Server-Manager/master/icon.ico">"%CD%\MAIN_res\updater\icon.vbs"
echo strHDLocation = "%CD%\MAIN_res\icon.ico">>"%CD%\MAIN_res\updater\icon.vbs"
echo Set objXMLHTTP = CreateObject("MSXML2.XMLHTTP")>>"%CD%\MAIN_res\updater\icon.vbs"
echo objXMLHTTP.open "GET", strFileURL, false>>"%CD%\MAIN_res\updater\icon.vbs"
echo objXMLHTTP.send()>>"%CD%\MAIN_res\updater\icon.vbs"
echo If objXMLHTTP.Status = 200 Then>>"%CD%\MAIN_res\updater\icon.vbs"
echo Set objADOStream = CreateObject("ADODB.Stream")>>"%CD%\MAIN_res\updater\icon.vbs"
echo objADOStream.Open>>"%CD%\MAIN_res\updater\icon.vbs"
echo objADOStream.Type = 1 >>"%CD%\MAIN_res\updater\icon.vbs"
echo objADOStream.Write objXMLHTTP.ResponseBody>>"%CD%\MAIN_res\updater\icon.vbs"
echo objADOStream.Position = 0 >>"%CD%\MAIN_res\updater\icon.vbs"
echo Set objFSO = Createobject("Scripting.FileSystemObject")>>"%CD%\MAIN_res\updater\icon.vbs"
echo If objFSO.Fileexists(strHDLocation) Then objFSO.DeleteFile(strHDLocation)>>"%CD%\MAIN_res\updater\icon.vbs"
echo Set objFSO = Nothing>>"%CD%\MAIN_res\updater\icon.vbs"
echo objADOStream.SaveToFile strHDLocation>>"%CD%\MAIN_res\updater\icon.vbs"
echo objADOStream.Close>>"%CD%\MAIN_res\updater\icon.vbs"
echo Set objADOStream = Nothing>>"%CD%\MAIN_res\updater\icon.vbs"
echo End if>>"%CD%\MAIN_res\updater\icon.vbs"
echo Set objXMLHTTP = Nothing>>"%CD%\MAIN_res\updater\icon.vbs"
if not exist "%CD%\MAIN_res\plugins\plugins.txt" (goto :SkipBuildPlugins)
echo.
echo  / Rebuilding plugin scripts...
set count=0
:StartBuildPlugins
set /a "count=%count% + 1"
for /l %%A in (1,1,%plugincount%) do (
	if %%A==%count% (
		set "tempplugin=!plugin%%A!"
	)
)
echo.
echo  // Developing download script for %tempplugin%... %count%/%plugincount%.
del /Q "%CD%\MAIN_res\plugins\%tempplugin%.vbs" >nul
echo strFileURL="https://hub.rocketmod.net/product/%tempplugin%/latest.zip">"%CD%\MAIN_res\plugins\%tempplugin%.vbs"
echo strHDLocation = "%CD%\MAIN_res\downloads\current.zip">>"%CD%\MAIN_res\plugins\%tempplugin%.vbs"
echo Set objXMLHTTP = CreateObject("MSXML2.XMLHTTP")>>"%CD%\MAIN_res\plugins\%tempplugin%.vbs"
echo objXMLHTTP.open "GET", strFileURL, false>>"%CD%\MAIN_res\plugins\%tempplugin%.vbs"
echo objXMLHTTP.send()>>"%CD%\MAIN_res\plugins\%tempplugin%.vbs"
echo If objXMLHTTP.Status = 200 Then>>"%CD%\MAIN_res\plugins\%tempplugin%.vbs"
echo Set objADOStream = CreateObject("ADODB.Stream")>>"%CD%\MAIN_res\plugins\%tempplugin%.vbs"
echo objADOStream.Open>>"%CD%\MAIN_res\plugins\%tempplugin%.vbs"
echo objADOStream.Type = 1 >>"%CD%\MAIN_res\plugins\%tempplugin%.vbs"
echo objADOStream.Write objXMLHTTP.ResponseBody>>"%CD%\MAIN_res\plugins\%tempplugin%.vbs"
echo objADOStream.Position = 0 >>"%CD%\MAIN_res\plugins\%tempplugin%.vbs"
echo Set objFSO = Createobject("Scripting.FileSystemObject")>>"%CD%\MAIN_res\plugins\%tempplugin%.vbs"
echo If objFSO.Fileexists(strHDLocation) Then objFSO.DeleteFile(strHDLocation)>>"%CD%\MAIN_res\plugins\%tempplugin%.vbs"
echo Set objFSO = Nothing>>"%CD%\MAIN_res\plugins\%tempplugin%.vbs"
echo objADOStream.SaveToFile strHDLocation>>"%CD%\MAIN_res\plugins\%tempplugin%.vbs"
echo objADOStream.Close>>"%CD%\MAIN_res\plugins\%tempplugin%.vbs"
echo Set objADOStream = Nothing>>"%CD%\MAIN_res\plugins\%tempplugin%.vbs"
echo End if>>"%CD%\MAIN_res\plugins\%tempplugin%.vbs"
echo Set objXMLHTTP = Nothing>>"%CD%\MAIN_res\plugins\%tempplugin%.vbs"
if NOT %count%==%plugincount% (goto :StartBuildPlugins)
:SkipBuildPlugins
echo.
echo  / Downloading icon...
cscript //nologo "%CD%\MAIN_res\updater\icon.vbs"
echo.
echo  / Adding program files...
echo %~dp0>"%CD%\MAIN_res\Directory.txt"
if not {%username%}=={} (echo %username%>"%CD%\MAIN_res\username.txt")
if not {%password%}=={} (echo %password%>"%CD%\MAIN_res\password.txt")
if exist "%CD%\MAIN_res\V.txt" (del "%CD%\MAIN_res\V.txt")
echo %V%>"%CD%\MAIN_res\V.txt"
echo.
echo Done. :)  -  Enter Y if you would like to see the github update page and close.
echo  Anything else to close.
set "choice="
set /p "choice= - Enter option: "
if /I {%choice%}=={Y} (start "" https://github.com/alexlyee/Unturned-Server-Manager/commits/master)
goto :exit




:exit
REM                                              Create log file. and proper exit. \/
set count=0
for /f "tokens=*" %%A in ('dir /b "%CD%\MAIN_res\logs"') do (
	set /a "count=!count! + 1"
	set "LogCount=!count!"
)
set "count=" & set /a "LogCount=%LogCount% + 1"
set "LogName=Log%LogCount%"
set /a "LogCount=%LogCount% - 1"
>"%CD%\MAIN_res\logs\%LogName%.log" echo -Log.Start
>>"%CD%\MAIN_res\logs\%LogName%.log" echo --Log.Dump.Start
for /f "tokens=*" %%A in ('set') do (
	>>"%CD%\MAIN_res\logs\%LogName%.log" echo %%A
)
>>"%CD%\MAIN_res\logs\%LogName%.log" echo --Log.Dump.End
>>"%CD%\MAIN_res\logs\%LogName%.log" echo --Log.DumpDynamics.Start
>>"%CD%\MAIN_res\logs\%LogName%.log" echo CD=%CD%
>>"%CD%\MAIN_res\logs\%LogName%.log" echo DATE=%DATE%
>>"%CD%\MAIN_res\logs\%LogName%.log" echo TIME=%TIME%
>>"%CD%\MAIN_res\logs\%LogName%.log" echo RANDOM=%RANDOM%
>>"%CD%\MAIN_res\logs\%LogName%.log" echo ERRORLEVEL=%ERRORLEVEL%
>>"%CD%\MAIN_res\logs\%LogName%.log" echo CMDEXTVERSION=%CMDEXTVERSION%
>>"%CD%\MAIN_res\logs\%LogName%.log" echo CMDCMDLINE=%CMDCMDLINE%
>>"%CD%\MAIN_res\logs\%LogName%.log" echo HIGHESTNUMANODENUMBER=%HIGHESTNUMANODENUMBER%
>>"%CD%\MAIN_res\logs\%LogName%.log" echo --Log.DumpDynamics.End
>>"%CD%\MAIN_res\logs\%LogName%.log" echo --Log.CustomNotes.Start
>>"%CD%\MAIN_res\logs\%LogName%.log" echo V%V%
>>"%CD%\MAIN_res\logs\%LogName%.log" echo --Log.CustomNotes.End
>>"%CD%\MAIN_res\logs\%LogName%.log" echo -Log.End
exit "WellDone"

REM GG!
:UpdateProgram
echo.
echo  .. Updating...
echo.
echo del /F /Q "%CD%\MAIN.bat">"%CD%\update.bat"
echo del /F /Q "%CD%\icon.ico">>"%CD%\update.bat"
echo del /F /Q "%CD%\README.md">>"%CD%\update.bat"
echo git init>>"%CD%\update.bat"
echo git remote add master https://github.com/alexlyee/Unturned-Server-Manager>>"%CD%\update.bat"
echo git pull --allow-unrelated-histories -f https://github.com/alexlyee/Unturned-Server-Manager master>>"%CD%\update.bat"
echo @echo off>>"%CD%\update.bat"
echo echo. & echo.>>"%CD%\update.bat"
echo  That should be it^! Take a look and see if that did it.>>"%CD%\update.bat"
echo pause>>"%CD%\update.bat"
echo del /F /Q "%CD%\update.bat">>"%CD%\update.bat"
echo  Update script built. Running it.
echo.
update.bat
REM the script will never get here.
goto :exit


:server
echo.
echo  -- Starting Server :) --
start "Use command shutdown once done loading." /D "%CD%\unturned" /MAX /HIGH /WAIT "%CD%\unturned\Unturned.exe" -nographics -batchmode +%servertype%/ManagedServer
echo.
goto :exit

:InstallGIT
echo.
echo  Installing Git.
echo  .. Git is used for updating this program automatically.
echo  .. Please install git on to the command line, you may need to restart for this to work!
echo  .. Press any key to exit. :)
start "" https://git-scm.com/download/win
pause >nul