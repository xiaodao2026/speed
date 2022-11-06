@echo off
setlocal enabledelayedexpansion
rem 程序运行目录，绝对目录
cd C:\Users\aplomb\Desktop\gcore_speed
rem 你的CloudFlare注册账户邮箱
set auth_email=xxxxx@gmail.com
rem 你的CloudFlare账户key,位置在域名概述页面点击右下角获取api key。
set auth_key=xxxxxxxxxxxxxx
rem #修改为你的主域名
set zone_name=mcetf.eu.org
rem 自动更新的二级域名前缀,例如cloudflare的cdn用cl，gcore的cdn用gcore，后面是数字，程序会自动添加。
set record_name=gcore
rem 二级域名个数，例如配置5个，则域名分别是cl1、cl2、cl3、cl4、cl5.   后面的信息均不需要修改，让他自动运行就好了。
set record_count=5
set record_type=A

for /F %%I in ('.\curl\bin\curl.exe --silent http://4.ipw.cn') do set PUBLIC_IP=%%I
echo '请确认该机器没有通过代理，你的IP地址是：'%PUBLIC_IP%
echo '欢迎关注youtuber小道笔记：https://www.youtube.com/channel/UCfSvDIQ8D_Zz62oAd5mcDDg'

CloudflareST.exe -p 0
for /F %%I in ('.\curl\bin\curl.exe -X GET "https://api.cloudflare.com/client/v4/zones?name=%zone_name%" -H "X-Auth-Email: %auth_email%" -H "X-Auth-Key: %auth_key%" -H "Content-Type: application/json"') do set zone_identifier=%%I
echo zone_id:%zone_identifier:~18,32%

set /a n=0
for /f "tokens=1 delims=," %%i in (result.csv) do (
	if !n! neq 0 (
		for /F %%I in ('.\curl\bin\curl.exe -X GET "https://api.cloudflare.com/client/v4/zones/%zone_identifier:~18,32%/dns_records?name=%record_name%!record_count!.%zone_name%" -H "X-Auth-Email: %auth_email%" -H "X-Auth-Key: %auth_key%" -H "Content-Type: application/json"') do set record=%%I
		echo record_id:!record:~18,32!
		::echo "https://api.cloudflare.com/client/v4/zones/%zone_identifier:~18,32%/dns_records/!record:~18,32!" -H "X-Auth-Email: %auth_email%" -H "X-Auth-Key: %auth_key%" -H "Content-Type: application/json" --data "{\"type\":\"%record_type%\",\"name\":\"%record_name%!record_count!.%zone_name%\",\"content\":\"%%i\",\"ttl\":60,\"proxied\":false}"
		echo 更新DNS记录
		for /F %%I in ('.\curl\bin\curl.exe -X PUT "https://api.cloudflare.com/client/v4/zones/%zone_identifier:~18,32%/dns_records/!record:~18,32!" -H "X-Auth-Email: %auth_email%" -H "X-Auth-Key: %auth_key%" -H "Content-Type: application/json" --data "{\"type\":\"%record_type%\",\"name\":\"%record_name%!record_count!.%zone_name%\",\"content\":\"%%i\",\"ttl\":60,\"proxied\":false}"') do set result=%%I
		echo %record_name%!record_count!.%zone_name%域名地址更新为:%%i
    	echo 更新结果：!result:~-41,14!		
	    )
	set /a n+=1
	set /a record_count-=1
	if !record_count! LEQ 0 (
		goto :END
	)
)
:END
