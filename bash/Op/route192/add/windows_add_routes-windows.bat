
@echo off

ver | find "5.2." > NUL &&  goto win2003    
ver | find "6.0." > NUL &&  goto win2008   
ver | find "6.1." > NUL &&  goto win2008r2    
ver | find "6.2." > NUL &&  goto win2012

:win2003
route print "10.0.0.0" | find "10.0.0.0" > route_list

set gw=
for /F "tokens=1-5" %%a in ('type route_list') do (

    if not "%%c" == "" ( set gw=%%c )
)



if "%gw%" == "" ( echo "fail to get eth0 default gw" && goto error)




route print 192.168.0.0 | find "%gw%" > NUL

if not "%errorlevel%" == "0" (
    route -p add 192.168.0.0 mask 255.255.0.0 %gw% > NUL 2>&1

)


if not "%errorlevel%" == "0" ( echo "faild to add route 192.168.0.0/16" && goto error)
goto success

:win2008
route print -4 "10.0.0.0" | find "10.0.0.0" > route_list

set gw=
for /F "tokens=1-5" %%a in ('type route_list') do (

    if not "%%c" == "" ( set gw=%%c )
)



if "%gw%" == "" ( echo "fail to get eth0 default gw" && goto error)




route print -4 192.168.0.0 | find "%gw%" > NUL

if not "%errorlevel%" == "0" (
    route -p add 192.168.0.0 mask 255.255.0.0 %gw% > NUL 2>&1

)


if not "%errorlevel%" == "0" ( echo "faild to add route 192.168.0.0/16" && goto error)
goto success

:win2008r2
route print -4 "10.0.0.0" | find "10.0.0.0" > route_list

set gw=
for /F "tokens=1-5" %%a in ('type route_list') do (

    if not "%%c" == "" ( set gw=%%c )
)



if "%gw%" == "" ( echo "fail to get eth0 default gw" && goto error)




route print -4 192.168.0.0 | find "%gw%" > NUL

if not "%errorlevel%" == "0" (
    route -p add 192.168.0.0 mask 255.255.0.0 %gw% > NUL 2>&1

)


if not "%errorlevel%" == "0" ( echo "faild to add route 192.168.0.0/16" && goto error)
goto success

:win2012
route print -4 "10.0.0.0" | find "10.0.0.0" > route_list

set gw=
for /F "tokens=1-5" %%a in ('type route_list') do (

    if not "%%c" == "" ( set gw=%%c )
)



if "%gw%" == "" ( echo "fail to get eth0 default gw" && goto error)




route print -4 192.168.0.0 | find "%gw%" > NUL

if not "%errorlevel%" == "0" (
    route -p add 192.168.0.0 mask 255.255.0.0 %gw% > NUL 2>&1

)


if not "%errorlevel%" == "0" ( echo "faild to add route 192.168.0.0/16" && goto error)
goto success




:success
del route_list
echo "add 192.168.0.0/16 success !"
timeout 10

exit 0



:error
timeout 10

exit 1
