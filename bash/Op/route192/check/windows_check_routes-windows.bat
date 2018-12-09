@echo off
route print 192.168.0.0 | find "192.168.0.0" > NUL
if not "%errorlevel%" == "0" (
    echo "no"	) 
else (
    echo "yes"
)
