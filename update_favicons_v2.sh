#!/bin/bash

# 获取所有网站数据
mysql -u root -proot -N -e "SELECT id, url FROM guns.site;" | while read -r id url; do
    # 提取域名
    domain=$(echo "$url" | sed 's|https\?://||' | sed 's|/.*||')
    
    echo "处理网站: $domain"
    
    # 直接使用Google API，设置较大尺寸
    google_favicon="https://www.google.com/s2/favicons?domain=$domain&sz=64"
    echo "更新favicon为: $google_favicon"
    mysql -u root -proot -e "UPDATE guns.site SET thumb='$google_favicon' WHERE id=$id;"
done

echo "Favicon更新完成"