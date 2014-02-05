@ECHO OFF

cd /d "E:\personal\WoW\addon_dev\LostControl\"

robocopy "E:\personal\WoW\addon_dev\LostControl" "E:\personal\WoW\interface\addons\LostControl" *.lua *.txt *.xml /PURGE
::robocopy "./" "./test/" *.lua *.txt /PURGE
