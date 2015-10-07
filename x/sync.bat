@ECHO OFF

cd /d "D:\WoW Addons\LostControl"

robocopy "D:\WoW Addons\LostControl" "C:\World of Warcraft\interface\addons\LostControl" *.* /E /XD .git x /PURGE
::robocopy "./" "./test/" *.lua *.txt /PURGE
