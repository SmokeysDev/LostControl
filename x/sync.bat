@ECHO OFF

cd /d "E:\personal\wow addon_dev\LostControl"

robocopy "E:\personal\wow addon_dev\LostControl" "E:\personal\World of Warcraft\interface\addons\LostControl" *.* /E /XD .git x /PURGE
::robocopy "./" "./test/" *.lua *.txt /PURGE
