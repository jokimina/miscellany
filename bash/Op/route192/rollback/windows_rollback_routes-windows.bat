
@echo off

route print -4 192.168.0.0 | find "192.168.0.0" > NUL
if "%errorlevel%" == "0" (
	route delete 192.168.0.0 mask 255.255.0.0 > NUL 2>&1
) else (
    echo "remove 192.168.0.0/16 success !"

)
if not "%errorlevel%" == "0" ( 
    echo "faild to remove route 192.168.0.0/16"

) else (
    echo "remove 192.168.0.0/16 success !"
)
