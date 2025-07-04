# WebStack-Guns 导航网站管理文档

## 系统概述
- **项目名称**: WebStack-Guns 导航网站
- **技术栈**: Java Spring Boot + MySQL
- **端口**: 8000
- **管理后台**: http://your-ip:8000/admin

### Spring Boot 技术栈说明

**Spring Boot** 是基于Spring框架的快速开发框架，具有以下特点：

#### 1. 核心特性
- **自动配置**: 根据项目依赖自动配置Spring应用
- **嵌入式服务器**: 内置Tomcat服务器，无需外部部署
- **起步依赖**: 简化Maven/Gradle依赖管理
- **生产就绪**: 内置监控、健康检查等生产环境功能

#### 2. WebStack-Guns 使用的技术组件
```yaml
核心框架:
- Spring Boot 2.0.1: Web应用框架
- Spring MVC: Web层控制器
- MyBatis-Plus: 数据库ORM框架
- Apache Shiro: 安全认证框架

数据层:
- MySQL: 关系型数据库
- Druid: 数据库连接池
- EhCache: 二级缓存

模板引擎:
- Beetl: 模板引擎（类似Thymeleaf）

其他组件:
- Swagger: API文档生成
- JWT: Token认证
- Kaptcha: 验证码生成
```

#### 3. 配置文件结构
```yaml
# application.yml 主要配置
server:
  port: 8000           # 服务端口
  address: 0.0.0.0     # 监听地址（重要：允许外部访问）

spring:
  profiles:
    active: local      # 激活的配置环境
  datasource:          # 数据库配置
    url: jdbc:mysql://localhost/guns
    username: root
    password: root
```

#### 4. 项目启动流程
1. **JVM启动**: `java -jar target/Webstack-Guns-1.0.jar`
2. **Spring容器初始化**: 加载Bean定义和自动配置
3. **Tomcat服务器启动**: 监听8000端口
4. **数据库连接池初始化**: 连接MySQL数据库
5. **应用就绪**: 开始处理HTTP请求

#### 5. 与传统Java Web项目的区别
```
传统方式:
- 需要外部Tomcat服务器
- 复杂的XML配置
- 手动管理依赖版本
- 部署复杂(WAR包)

Spring Boot方式:
- 内嵌Tomcat服务器
- 约定优于配置
- 自动依赖管理
- 简单部署(JAR包)
```

## 完整部署流程

### 1. 环境准备
```bash
# 更新系统
sudo apt update && sudo apt upgrade -y

# 安装Java 8 (WebStack-Guns需要Java 8)
sudo apt install openjdk-8-jdk -y

# 验证Java版本
java -version

# 安装MySQL
sudo apt install mysql-server -y

# 启动MySQL服务
sudo systemctl start mysql
sudo systemctl enable mysql
```

### 2. MySQL配置
```bash
# 设置MySQL root密码为 root
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root';"
sudo mysql -e "FLUSH PRIVILEGES;"

# 测试连接
mysql -u root -proot -e "SELECT 1;"

# 创建数据库
mysql -u root -proot -e "CREATE DATABASE IF NOT EXISTS guns DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;"
```

### 3. 获取WebStack-Guns源码
```bash
# 创建目录
mkdir -p /home/ubuntu/apps/navigation
cd /home/ubuntu/apps/navigation

# 从GitHub克隆代码 (需要替换为实际的项目地址)
git clone https://github.com/jsnjfz/WebStack-Guns.git
cd WebStack-Guns

# 或者下载预编译的JAR文件到以下目录结构
# WebStack-Guns/
# ├── target/Webstack-Guns-1.0.jar
# ├── WebStack-Guns/sql/guns.sql
# └── CLAUDE.md
```

### 4. 数据库初始化
```bash
# 导入初始数据 (如果有guns.sql文件)
mysql -u root -proot guns < WebStack-Guns/sql/guns.sql

# 如果没有guns.sql文件，手动创建基础表
mysql -u root -proot guns << 'EOF'
-- 创建分类表
CREATE TABLE IF NOT EXISTS category (
  id int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  parent_id int(11) NOT NULL DEFAULT 0,
  sort int(11) NOT NULL DEFAULT 0,
  title varchar(50) NOT NULL,
  icon varchar(20) NOT NULL,
  levels int(11) DEFAULT NULL,
  create_time timestamp NULL DEFAULT NULL,
  update_time timestamp NULL DEFAULT NULL,
  PRIMARY KEY (id)
);

-- 创建网站表
CREATE TABLE IF NOT EXISTS site (
  id int unsigned NOT NULL AUTO_INCREMENT,
  category_id int NOT NULL,
  title varchar(50) NOT NULL,
  thumb varchar(100) NOT NULL,
  description varchar(300) NOT NULL,
  url varchar(100) NOT NULL,
  create_time timestamp NULL DEFAULT NULL,
  update_time timestamp NULL DEFAULT NULL,
  PRIMARY KEY (id)
);

-- 创建用户表 (基础版本)
CREATE TABLE IF NOT EXISTS sys_user (
  id int unsigned NOT NULL AUTO_INCREMENT,
  account varchar(45) NOT NULL,
  password varchar(45) NOT NULL,
  name varchar(45) DEFAULT NULL,
  PRIMARY KEY (id)
);

-- 插入默认管理员
INSERT IGNORE INTO sys_user (id, account, password, name) VALUES 
(1, 'admin', 'ecfadcde9305f8891bcfe5a1e28c253e', 'Administrator');

-- 创建示例分类
INSERT IGNORE INTO category (id, parent_id, sort, title, icon, levels, create_time) VALUES 
(47, 0, 1, '常用工具', 'fa-wrench', 1, NOW());
EOF
```

### 5. 防火墙配置
```bash
# 开放8000端口
sudo iptables -I INPUT -p tcp --dport 8000 -j ACCEPT

# 保存防火墙规则 (Ubuntu)
sudo netfilter-persistent save

# 或者使用ufw
sudo ufw allow 8000
```

### 6. 启动应用
```bash
# 进入项目目录
cd /home/ubuntu/apps/navigation/WebStack-Guns

# 后台启动应用
nohup java -jar target/Webstack-Guns-1.0.jar > app.log 2>&1 &

# 检查启动状态
ps aux | grep java
ss -tlnp | grep 8000

# 查看启动日志
tail -f app.log
```

### 7. 验证部署
```bash
# 测试本地访问
curl -I http://localhost:8000

# 检查数据库连接
mysql -u root -proot -e "SELECT COUNT(*) FROM guns.category;"
```

### 8. 创建自启动服务 (可选)
```bash
# 创建systemd服务文件
sudo tee /etc/systemd/system/webstack-guns.service > /dev/null << 'EOF'
[Unit]
Description=WebStack-Guns Navigation Website
After=network.target mysql.service

[Service]
Type=forking
User=ubuntu
WorkingDirectory=/home/ubuntu/apps/navigation/WebStack-Guns
ExecStart=/usr/bin/java -jar target/Webstack-Guns-1.0.jar
ExecStop=/bin/kill -TERM $MAINPID
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# 重新加载systemd
sudo systemctl daemon-reload

# 启用开机自启
sudo systemctl enable webstack-guns

# 启动服务
sudo systemctl start webstack-guns

# 检查服务状态
sudo systemctl status webstack-guns
```

### 9. 初始设置和示例数据
访问 http://your-ip:8000/admin，使用默认账户登录：
- 用户名: admin
- 密码: 111111

#### 添加示例数据
```bash
# 添加示例分类和网站 (与当前网站一致)
mysql -u root -proot guns << 'EOF'
-- 添加分类
INSERT INTO category (id, parent_id, sort, title, icon, levels, create_time) VALUES 
(47, 0, 1, '常用工具', 'fa-wrench', 1, NOW())
ON DUPLICATE KEY UPDATE title=VALUES(title);

-- 添加示例网站
INSERT INTO site (category_id, title, thumb, description, url, create_time) VALUES
(47, 'Milanote', 'https://www.google.com/s2/favicons?domain=milanote.com&sz=64', '可视化笔记和创意整理工具', 'https://milanote.com', NOW()),
(47, 'Claude', 'https://www.google.com/s2/favicons?domain=claude.ai&sz=64', 'Anthropic的AI助手', 'https://claude.ai', NOW()),
(47, 'YouTube', 'https://www.google.com/s2/favicons?domain=www.youtube.com&sz=64', '全球最大视频分享平台', 'https://www.youtube.com', NOW()),
(47, 'Poe', 'https://www.google.com/s2/favicons?domain=poe.com&sz=64', 'AI聊天机器人平台', 'https://poe.com', NOW()),
(47, 'Gemini', 'https://www.google.com/s2/favicons?domain=gemini.google.com&sz=64', 'Google AI助手', 'https://gemini.google.com', NOW());
EOF
```

#### 首次登录后建议：
1. 修改管理员密码
2. 检查favicon显示是否正常
3. 根据需要添加更多分类和网站
4. 配置域名和SSL（如需要）

### 10. 域名和反向代理设置 (可选)

#### 使用Nginx Proxy Manager
如果要配置域名访问，可以安装Nginx Proxy Manager：

```bash
# 安装Docker和Docker Compose
sudo apt install docker.io docker-compose -y

# 创建NPM配置目录
mkdir -p ~/nginx-proxy-manager
cd ~/nginx-proxy-manager

# 创建docker-compose.yml
cat > docker-compose.yml << 'EOF'
version: '3'
services:
  app:
    image: 'jc21/nginx-proxy-manager:latest'
    restart: unless-stopped
    ports:
      - '80:80'
      - '443:443'
      - '8090:81'
    environment:
      DB_MYSQL_HOST: "db"
      DB_MYSQL_PORT: 3306
      DB_MYSQL_USER: "npm"
      DB_MYSQL_PASSWORD: "npm"
      DB_MYSQL_NAME: "npm"
    volumes:
      - ./data:/data
      - ./letsencrypt:/etc/letsencrypt
  db:
    image: 'jc21/mariadb-aria:latest'
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: 'npm'
      MYSQL_DATABASE: 'npm'
      MYSQL_USER: 'npm'
      MYSQL_PASSWORD: 'npm'
    volumes:
      - ./data/mysql:/var/lib/mysql
EOF

# 启动NPM
docker-compose up -d
```

访问 http://your-ip:8090 配置反向代理：
- 默认账户: admin@example.com / changeme
- 添加代理主机，转发到 localhost:8000

## 快速部署检查清单

### 部署完成后必须验证的项目：

#### ✅ 基础服务检查
```bash
# 1. Java版本检查
java -version  # 应该显示Java 8

# 2. MySQL服务检查
sudo systemctl status mysql  # 应该显示active (running)

# 3. 数据库连接检查
mysql -u root -proot -e "SELECT 1;"  # 应该返回1

# 4. 数据库表检查
mysql -u root -proot -e "SHOW TABLES IN guns;"  # 应该显示category, site, sys_user等表

# 5. 应用进程检查
ps aux | grep java  # 应该显示Webstack-Guns进程

# 6. 端口监听检查
ss -tlnp | grep 8000  # 应该显示Java进程监听8000端口
```

#### ✅ 网站功能检查
```bash
# 7. HTTP响应检查
curl -I http://localhost:8000  # 应该返回200 OK

# 8. 管理后台检查
curl -I http://localhost:8000/admin  # 应该返回200 OK

# 9. 网站数据检查
mysql -u root -proot -e "SELECT COUNT(*) FROM guns.site;"  # 应该显示网站数量

# 10. Favicon URL检查
mysql -u root -proot -e "SELECT title, thumb FROM guns.site LIMIT 3;"  # 应该显示Google API的favicon URL
```

#### ✅ 访问测试
1. **前端访问**: http://your-ip:8000 - 应该显示导航网站首页
2. **管理后台**: http://your-ip:8000/admin - 应该显示登录页面
3. **登录测试**: 使用 admin/111111 登录管理后台
4. **Favicon显示**: 网站图标应该正常显示，不应该出现404错误

#### ✅ 常见问题排查
如果遇到问题，按以下顺序检查：

1. **应用无法启动**
```bash
# 检查Java版本和JAR文件
java -version
ls -la target/Webstack-Guns-1.0.jar

# 查看启动日志
tail -f app.log
```

2. **无法访问网站**
```bash
# 检查防火墙
sudo iptables -L INPUT -n | grep 8000
sudo ufw status

# 检查端口占用
netstat -tlnp | grep 8000
```

3. **数据库连接失败**
```bash
# 检查MySQL服务
sudo systemctl status mysql

# 重置MySQL密码
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root'; FLUSH PRIVILEGES;"
```

4. **Favicon不显示**
   - 按照"Favicon显示问题解决方案"章节的步骤操作
   - 确保已修改模板文件并重启应用
   - 清除浏览器缓存

## 数据库信息
- **数据库名**: guns
- **用户**: root
- **密码**: root
- **主机**: localhost:3306

### 核心表结构

#### 1. 分类表 (category)
```sql
CREATE TABLE `category` (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) NOT NULL DEFAULT 0,
  `sort` int(11) NOT NULL DEFAULT 0,
  `title` varchar(50) NOT NULL,
  `icon` varchar(20) NOT NULL,
  `levels` int(11) DEFAULT NULL,
  `create_time` timestamp NULL DEFAULT NULL,
  `update_time` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
);
```

#### 2. 网站表 (site)
```sql
CREATE TABLE `site` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `category_id` int NOT NULL,
  `title` varchar(50) NOT NULL,
  `thumb` varchar(100) NOT NULL,
  `description` varchar(300) NOT NULL,
  `url` varchar(100) NOT NULL,
  `create_time` timestamp NULL DEFAULT NULL,
  `update_time` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
);
```

#### 3. 管理员表 (sys_user)
```sql
-- 默认管理员
username: admin
password: 111111 (MD5: ecfadcde9305f8891bcfe5a1e28c253e)
```

## 常用管理操作

### 查看统计信息
```bash
# 查看网站总数
mysql -u root -proot -e "SELECT COUNT(*) as total_sites FROM guns.site;"

# 查看分类统计
mysql -u root -proot -e "SELECT c.title as category, COUNT(s.id) as count FROM guns.category c LEFT JOIN guns.site s ON c.id = s.category_id GROUP BY c.id, c.title ORDER BY count DESC;"
```

### 网站管理
```bash
# 添加网站
mysql -u root -proot -e "INSERT INTO guns.site (category_id, title, thumb, description, url, create_time) VALUES (1, '网站标题', '图标URL', '网站描述', 'https://example.com', NOW());"

# 删除网站
mysql -u root -proot -e "DELETE FROM guns.site WHERE id = 网站ID;"

# 清空所有网站
mysql -u root -proot -e "DELETE FROM guns.site;"

# 批量删除（保留每个分类前N个）
mysql -u root -proot -e "DELETE FROM guns.site WHERE id NOT IN (SELECT * FROM (SELECT id FROM guns.site s1 WHERE (SELECT COUNT(*) FROM guns.site s2 WHERE s2.category_id = s1.category_id AND s2.id <= s1.id) <= 3) t);"
```

### 分类管理
```bash
# 查看所有分类
mysql -u root -proot -e "SELECT * FROM guns.category ORDER BY sort;"

# 添加分类
mysql -u root -proot -e "INSERT INTO guns.category (parent_id, sort, title, icon, levels, create_time) VALUES (0, 排序号, '分类名称', 'fa-icon', 1, NOW());"

# 删除分类及其网站
mysql -u root -proot -e "DELETE FROM guns.site WHERE category_id = 分类ID; DELETE FROM guns.category WHERE id = 分类ID;"
```

### 用户管理
```bash
# 修改管理员密码
mysql -u root -proot -e "UPDATE guns.sys_user SET password=MD5('新密码') WHERE account='admin';"

# 查看管理员信息
mysql -u root -proot -e "SELECT account, password FROM guns.sys_user WHERE account='admin';"
```

## 系统配置

### 应用启动
```bash
# 启动应用
cd /home/ubuntu/apps/navigation/WebStack-Guns
nohup java -jar target/Webstack-Guns-1.0.jar > app.log 2>&1 &

# 检查运行状态
ps aux | grep java
ss -tlnp | grep 8000

# 查看日志
tail -f app.log
```

### Spring Boot 应用管理

#### 启动流程详解
```bash
# 1. 进入项目目录
cd /home/ubuntu/apps/navigation/WebStack-Guns

# 2. 启动应用（后台运行）
nohup java -jar target/Webstack-Guns-1.0.jar > app.log 2>&1 &

# 3. 查看启动日志
tail -f app.log

# 成功启动的标志：
# - "Tomcat started on port(s): 8000 (http)"
# - "Started WebstackGunsApplication in X.XXX seconds"
# - "Application is success!"
```

#### 应用状态检查
```bash
# 检查Java进程
ps aux | grep java | grep Webstack-Guns

# 检查端口监听
ss -tlnp | grep 8000

# 检查内存使用
ps -p $(pgrep -f Webstack-Guns) -o pid,ppid,cmd,%mem,%cpu

# 测试应用响应
curl -I http://localhost:8000
```

#### 应用重启
```bash
# 方法1：使用进程ID
kill $(ps aux | grep 'java -jar target/Webstack-Guns' | grep -v grep | awk '{print $2}')
sleep 3
nohup java -jar target/Webstack-Guns-1.0.jar > app.log 2>&1 &

# 方法2：使用pkill
pkill -f "Webstack-Guns-1.0.jar"
sleep 3
nohup java -jar target/Webstack-Guns-1.0.jar > app.log 2>&1 &
```

#### 日志管理
```bash
# 查看实时日志
tail -f app.log

# 查看最近50行日志
tail -50 app.log

# 查看启动相关日志
grep -A 5 -B 5 "Started WebstackGunsApplication" app.log

# 查看错误日志
grep -i error app.log

# 日志轮转（防止文件过大）
mv app.log app.log.$(date +%Y%m%d)
touch app.log
```

### 防火墙配置
```bash
# 开放8000端口
sudo iptables -I INPUT -p tcp --dport 8000 -j ACCEPT

# 查看防火墙规则
sudo iptables -L INPUT -n
```

### Nginx 代理配置
- **Nginx Proxy Manager**: 端口 8090
- **域名配置**: 通过代理管理器转发到 localhost:8000
- **SSL**: 支持 Let's Encrypt 自动证书

## 数据备份与恢复

### 备份
```bash
# 备份整个数据库
mysqldump -u root -proot guns > backup_$(date +%Y%m%d).sql

# 只备份网站数据
mysqldump -u root -proot guns site category > sites_backup_$(date +%Y%m%d).sql
```

### 恢复
```bash
# 恢复数据库
mysql -u root -proot guns < backup_file.sql

# 恢复原始数据
mysql -u root -proot guns < WebStack-Guns/sql/guns.sql
```

## 常见问题解决

### 1. 应用无法访问
```bash
# 检查服务状态
ps aux | grep java
ss -tlnp | grep 8000

# 检查防火墙
sudo iptables -L INPUT -n | grep 8000

# 重启应用
kill $(ps aux | grep 'java -jar target/Webstack-Guns' | grep -v grep | awk '{print $2}')
nohup java -jar target/Webstack-Guns-1.0.jar > app.log 2>&1 &
```

### 2. 数据库连接问题
```bash
# 检查MySQL服务
sudo systemctl status mysql

# 测试连接
mysql -u root -proot -e "SELECT 1;"

# 重置用户权限
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root'; FLUSH PRIVILEGES;"
```

### 3. 500错误
```bash
# 检查应用日志
tail -f app.log

# 检查数据库表
mysql -u root -proot -e "SHOW TABLES IN guns;"

# 重新导入数据
mysql -u root -proot guns < WebStack-Guns/sql/guns.sql
```

### 4. 外部访问问题 (ERR_EMPTY_RESPONSE)

#### 问题现象
- 手机可以访问，电脑浏览器显示 "未发送任何数据" (ERR_EMPTY_RESPONSE)
- 本地访问正常，外部访问失败

#### 问题原因
Spring Boot默认配置可能只监听本地回环接口，需要明确指定监听所有网络接口。

#### 解决步骤
1. **修改配置文件**
```bash
# 编辑 src/main/resources/application.yml
vi src/main/resources/application.yml

# 在server配置中添加address配置
server:
  port: 8000
  address: 0.0.0.0  # 新增此行，允许外部访问
```

2. **重启应用**
```bash
# 停止当前进程
kill $(ps aux | grep 'java -jar target/Webstack-Guns' | grep -v grep | awk '{print $2}')

# 重新启动
nohup java -jar target/Webstack-Guns-1.0.jar > app.log 2>&1 &
```

3. **验证修复结果**
```bash
# 检查端口监听（应该显示0.0.0.0:8000）
ss -tlnp | grep 8000

# 测试外部访问
curl -I http://$(hostname -I | awk '{print $1}'):8000
```

#### 技术原理
- **0.0.0.0**: 监听所有网络接口（IPv4）
- **127.0.0.1**: 只监听本地回环接口
- **server.address**: Spring Boot服务器绑定地址配置

#### 相关配置说明
```yaml
# 不同监听配置的效果
server:
  address: 0.0.0.0      # 允许所有外部访问
  address: 127.0.0.1    # 只允许本地访问
  # 不配置address      # 依赖系统默认（可能导致外部访问问题）
```

## 目录结构
```
/home/ubuntu/apps/navigation/WebStack-Guns/
├── target/
│   └── Webstack-Guns-1.0.jar    # 应用主程序
├── WebStack-Guns/
│   └── sql/
│       └── guns.sql              # 数据库初始化文件
├── app.log                       # 应用日志
└── CLAUDE.md                     # 本文档
```

## 访问地址
- **前端**: http://your-ip:8000
- **管理后台**: http://your-ip:8000/admin
- **代理管理**: http://your-ip:8090

## 默认账户
- **WebStack-Guns 管理员**: admin / 111111
- **Nginx Proxy Manager**: admin@example.com / changeme

## 导航网站结构设计和添加方法

### 添加分类的方法

#### 1. 通过管理后台添加
1. 访问 http://your-ip:8000/admin
2. 登录后台 (admin/111111)
3. 进入"分类管理"页面
4. 点击"添加分类"按钮
5. 填写分类信息（名称、图标、排序等）

#### 2. 通过SQL命令添加
```sql
-- 添加单个分类
INSERT INTO guns.category (parent_id, sort, title, icon, levels, create_time) VALUES 
(0, 排序号, '分类名称', 'fa-icon-name', 1, NOW());

-- 查看所有分类
SELECT id, title, sort FROM guns.category ORDER BY sort;
```

### 添加网站的方法

#### 1. 通过管理后台添加
1. 进入"网站管理"页面
2. 点击"添加网站"按钮
3. 选择分类
4. 填写网站信息（标题、描述、URL、图标等）

#### 2. 通过SQL命令添加
```sql
-- 先查看分类ID
SELECT id, title FROM guns.category ORDER BY sort;

-- 添加单个网站
INSERT INTO guns.site (category_id, title, thumb, description, url, create_time) VALUES 
(分类ID, '网站名称', '图标URL', '网站描述', '网站URL', NOW());

-- 批量添加多个网站
INSERT INTO guns.site (category_id, title, thumb, description, url, create_time) VALUES
(分类ID, '网站1', '图标1', '描述1', 'URL1', NOW()),
(分类ID, '网站2', '图标2', '描述2', 'URL2', NOW()),
(分类ID, '网站3', '图标3', '描述3', 'URL3', NOW());
```

### 常用图标类名参考 (FontAwesome)

```text
fa-robot          # AI/智能工具
fa-search         # 搜索引擎
fa-users          # 社交媒体
fa-code           # 开发工具
fa-paint-brush    # 设计素材
fa-briefcase      # 在线办公
fa-graduation-cap # 学习教育
fa-gamepad        # 娱乐休闲
fa-shopping-cart  # 购物电商
fa-newspaper      # 新闻资讯
fa-wrench         # 实用工具
fa-cloud          # 云服务
fa-video          # 影音娱乐
fa-money          # 金融理财
fa-heartbeat      # 健康医疗
fa-home           # 首页/门户
fa-book           # 文档/知识
fa-camera         # 图片/摄影
fa-music          # 音乐
fa-plane          # 旅游
fa-cutlery        # 美食
fa-car            # 汽车
fa-building       # 企业/商务
```

### 批量导入数据的方法

#### 1. 准备SQL文件
创建包含分类和网站数据的SQL文件，例如 `my_sites.sql`

#### 2. 导入数据
```bash
# 导入SQL文件
mysql -u root -proot guns < my_sites.sql

# 或者直接执行SQL命令
mysql -u root -proot -e "你的SQL命令"
```

#### 3. 验证导入结果
```bash
# 查看分类数量
mysql -u root -proot -e "SELECT COUNT(*) as total_categories FROM guns.category;"

# 查看网站数量
mysql -u root -proot -e "SELECT COUNT(*) as total_sites FROM guns.site;"

# 查看各分类的网站数量
mysql -u root -proot -e "SELECT c.title, COUNT(s.id) as count FROM guns.category c LEFT JOIN guns.site s ON c.id = s.category_id GROUP BY c.id, c.title ORDER BY count DESC;"
```

### 网站图标获取方法

#### 1. 使用Google Favicon API（推荐）
```text
https://www.google.com/s2/favicons?domain=${domain}&sz=${size}
例如：https://www.google.com/s2/favicons?domain=youtube.com&sz=32
```
- domain: 网站域名（不包含https://）
- sz: 图标大小，如16、32、64、128等
- 如果找不到指定大小，会返回默认16x16的PNG图标
- 优势：自动获取、PNG格式、跨浏览器兼容

#### 2. 使用网站默认图标
```text
https://网站域名/favicon.ico
例如：https://www.google.com/favicon.ico
```

#### 3. 使用图标库
- Font Awesome 图标
- 自定义上传图标
- 使用网站截图服务

#### 4. 本地图标存储
将图标文件放在 `static/img/` 目录下，然后使用相对路径

## Favicon显示问题解决方案

### 问题现象
- 浏览器能打开网站但favicon不显示
- 浏览器开发者工具显示favicon路径错误，如：`/kaptcha/https://www.google.com/s2/favicons?domain=xxx.com&sz=64`
- 出现kaptcha相关的404错误

### 问题原因
WebStack-Guns系统的KaptchaController原本用于处理验证码图片，但其路由配置会拦截所有`/kaptcha/{pictureId}`的请求。当模板使用`<img src="/kaptcha/${site.thumb}">`格式时，系统会错误地将Google favicon URL当作本地图片ID处理。

### 解决步骤

#### 1. 修改前端模板文件
```bash
# 编辑主要内容模板
vi src/main/webapp/WEB-INF/view/common/_content.html
```

将第10行：
```html
<img src="/kaptcha/${site.thumb}" class="img-circle" width="40">
```

改为：
```html
<img src="${site.thumb}" class="img-circle" width="40">
```

#### 2. 修改管理后台JavaScript
```bash
# 编辑网站管理JS文件
vi src/main/webapp/static/modular/system/site/site.js
```

将第25行：
```javascript
var str = '<img src=' + Feng.ctxPath + '/kaptcha/' + value + ' style=width:40px;height: 40px>';
```

改为：
```javascript
var str = '<img src="' + value + '" style="width:40px;height: 40px;">';
```

#### 3. 更新编译后的文件（热更新方式）
```bash
# 更新target目录中的编译文件
cp src/main/webapp/WEB-INF/view/common/_content.html target/classes/WEB-INF/view/common/_content.html
cp src/main/webapp/static/modular/system/site/site.js target/classes/static/modular/system/site/site.js

# 更新运行中的JAR文件（无需重新编译）
jar -uf target/Webstack-Guns-1.0.jar -C target/classes WEB-INF/view/common/_content.html
jar -uf target/Webstack-Guns-1.0.jar -C target/classes static/modular/system/site/site.js
```

**重要说明：为什么不需要重新编译Java代码？**

我们使用的是**JAR热更新技术**，原理如下：

1. **Spring Boot JAR结构**：
```
Webstack-Guns-1.0.jar
├── BOOT-INF/
│   ├── classes/           # 编译后的文件和资源
│   │   ├── WEB-INF/view/  # 模板文件（我们要修改的）
│   │   └── static/        # 静态资源（我们要修改的）
│   └── lib/               # 依赖库
└── META-INF/
```

2. **修改范围**：
   - ✅ 只修改**模板文件**（.html）和**静态资源**（.js）
   - ❌ **不修改Java代码**（.class文件）
   - ✅ 保持所有业务逻辑不变（登录、数据库、认证等）

3. **`jar -uf` 命令作用**：
   - 直接更新JAR文件中的特定文件
   - 无需重新编译整个项目
   - 保持原有功能完整性
   - 风险最小，影响范围最小

4. **与重新编译的对比**：
```bash
# ❌ 重新编译方式（我们没用）
mvn clean package  # 可能导致编译错误、依赖冲突

# ✅ 热更新方式（我们使用的）
jar -uf target/Webstack-Guns-1.0.jar -C target/classes 文件路径
# 优势：只更新资源文件，保持Java代码不变
```

这就是为什么修复favicon后，登录功能依然完全正常！

#### 4. 重启应用
```bash
# 找到并杀死当前进程
kill $(ps aux | grep 'java -jar target/Webstack-Guns' | grep -v grep | awk '{print $2}')

# 重新启动
nohup java -jar target/Webstack-Guns-1.0.jar > app.log 2>&1 &
```

#### 5. 批量更新favicon为Google API格式
```bash
# 创建批量更新脚本
cat > update_favicons_google.sh << 'EOF'
#!/bin/bash
mysql -u root -proot -N -e "SELECT id, url FROM guns.site;" | while read -r id url; do
    domain=$(echo "$url" | sed 's|https\?://||' | sed 's|/.*||')
    google_favicon="https://www.google.com/s2/favicons?domain=$domain&sz=64"
    echo "更新favicon为: $google_favicon"
    mysql -u root -proot -e "UPDATE guns.site SET thumb='$google_favicon' WHERE id=$id;"
done
EOF

# 执行脚本
chmod +x update_favicons_google.sh
./update_favicons_google.sh
```

### 技术原理

#### KaptchaController的作用
- `/kaptcha/` 端点原本用于验证码生成和图片文件服务
- `/{pictureId}` 路由会将任何路径参数当作本地文件ID处理
- 当favicon URL为完整HTTP地址时，系统会错误地尝试在本地文件系统中查找该URL

#### 模板引擎处理
- WebStack-Guns使用Beetl模板引擎
- `${site.thumb}` 变量包含完整的favicon URL
- 添加`/kaptcha/`前缀会导致路径冲突

#### 解决方案核心
1. **去除路径前缀**：直接使用数据库中的完整URL
2. **更新编译文件**：确保运行时使用正确的模板
3. **统一favicon格式**：使用Google API确保图标可用性

### 验证修复结果
```bash
# 检查数据库中的favicon URL
mysql -u root -proot -e "SELECT id, title, thumb FROM guns.site LIMIT 5;"

# 检查应用日志
tail -f app.log

# 验证网站访问
curl -I http://localhost:8000
```

### 常见问题
1. **浏览器缓存**：清除浏览器缓存或使用无痕模式测试
2. **文件权限**：确保JAR文件有写入权限
3. **进程检查**：确认旧进程已完全停止再启动新进程

### 管理技巧

#### 1. 分类排序
通过修改 `sort` 字段调整分类显示顺序

#### 2. 网站排序
网站会按照添加时间或ID自动排序

#### 3. 批量操作
使用SQL命令可以快速批量添加、修改或删除数据

#### 4. 数据备份
定期备份数据库，防止数据丢失

---
*此文档由 Claude 创建，用于快速理解和管理 WebStack-Guns 导航网站系统*