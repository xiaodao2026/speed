#!/bin/bash
export LANG=zh_CN.UTF-8
auth_email="xxxx@gmail.com"    #你的CloudFlare注册账户邮箱
auth_key="xxxxxxxxxxxxxxx"   #你的CloudFlare账户key,位置在域名概述页面点击右下角获取api key。
zone_name="xxxx.com"     #你的主域名
record_name="cl"    #自动更新的二级域名前缀,例如cloudflare的cdn用cl，gcore的cdn用gcore，后面是数字，程序会自动添加。二级域名需要已经在域名管理网站配置完成，视频教程可以参考：https://www.youtube.com/channel/UCfSvDIQ8D_Zz62oAd5mcDDg
record_count=5 #二级域名个数，例如配置5个，则域名分别是cl1、cl2、cl3、cl4、cl5.   后面的信息均不需要修改，让他自动运行就好了。

echo
echo '你的IP地址是'$(curl 4.ipw.cn)',请确认为本机未经过代理的地址'
echo '小道笔记：https://www.youtube.com/channel/UCfSvDIQ8D_Zz62oAd5mcDDg'
./CloudflareST

record_type="A"     
#获取zone_id、record_id
zone_identifier=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$zone_name" -H "X-Auth-Email: $auth_email" -H "X-Auth-Key: $auth_key" -H "Content-Type: application/json" | grep -Po '(?<="id":")[^"]*' | head -1 )
#echo $zone_identifier

sed -n '2,20p' result.csv | while read line
do
    #echo $record_name$record_count'.'$zone_name
    record_identifier=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records?name=$record_name$record_count"'.'"$zone_name" -H "X-Auth-Email: $auth_email" -H "X-Auth-Key: $auth_key" -H "Content-Type: application/json" | grep -Po '(?<="id":")[^"]*' | head -1 )
    #echo $record_identifier
    #更新DNS记录
    update=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records/$record_identifier" -H "X-Auth-Email: $auth_email" -H "X-Auth-Key: $auth_key" -H "Content-Type: application/json" --data "{\"type\":\"$record_type\",\"name\":\"$record_name$record_count.$zone_name\",\"content\":\"${line%%,*}\",\"ttl\":60,\"proxied\":false}")
    #反馈更新情况
    if [[ "$update" != "${update%success*}" ]] && [[ "$(echo $update | grep "\"success\":true")" != "" ]]; then
      echo $record_name$record_count'.'$zone_name'更新为:'${line%%,*}'....成功'
    else
      echo $record_name$record_count'.'$zone_name'更新失败:'$update
    fi

    record_count=$(($record_count-1))    #二级域名序号递减
    echo $record_count
    if [ $record_count -eq 0 ]; then
        break
    fi

done
