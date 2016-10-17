@ECHO OFF

cd /d "C:\Users\Matt\Documents\WoW addons\LostControl"

robocopy "C:\Users\Matt\Documents\WoW addons\LostControl" "G:\World of Warcraft\interface\addons\LostControl" *.* /E /XD .git x /PURGE
::robocopy "./" "./test/" *.lua *.txt /PURGE
