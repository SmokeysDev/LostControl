@ECHO OFF

cd /d "C:\Users\Matt\Documents\WoW addons\LostControl"

robocopy "C:\Users\Matt\Documents\WoW addons\LostControl" "G:\World of Warcraft\_retail_\interface\addons\LostControl" *.* /E /PURGE /XF .gitignore *.key* /XD .git nbproject x
::robocopy "./" "./test/" *.lua *.txt /PURGE
