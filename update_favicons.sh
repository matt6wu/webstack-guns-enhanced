#!/bin/bash

# 获取所有网站数据
mysql -u root -proot -N -e "SELECT id, url FROM guns.site;" | while read -r id url; do
    # 提取域名
    domain=$(echo "$url" | sed 's|https\?://||' | sed 's|/.*||')
    
    # 先尝试直接使用网站的favicon.ico
    favicon_url="https://$domain/favicon.ico"
    
    # 检查favicon是否可访问
    if curl -s -I "$favicon_url" | grep -q "200 OK\|image/"; then
        echo "使用直接favicon: $favicon_url"
        mysql -u root -proot -e "UPDATE guns.site SET thumb='$favicon_url' WHERE id=$id;"
    else
        # 回退到Google API
        google_favicon="https://www.google.com/s2/favicons?domain=$domain&sz=32"
        echo "使用Google API: $google_favicon"
        mysql -u root -proot -e "UPDATE guns.site SET thumb='$google_favicon' WHERE id=$id;"
    fi
done

echo "Favicon更新完成"