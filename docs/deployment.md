# 部署指南

本文覆盖友米 SCRM 复刻版从本地启动到单机生产部署的完整流程。所有示例都以 Linux + Nginx 为准，Windows 下命令的差异会单独标注。

> 这是一个学习型复刻项目。公网部署前请先阅读 [DISCLAIMER.md](../DISCLAIMER.md) 与 [SECURITY.md](../SECURITY.md)，并完成本文第 6 节的安全检查。

## 1. 本地开发

### 1.1 环境要求

| 依赖 | 版本 | 说明 |
| --- | --- | --- |
| JDK | 17 或更高 | 推荐 21 |
| Maven | 3.9+ | 后端构建 |
| Node.js | `^20.19.0` 或 `>=22.12.0` | Vite 8 要求 |
| pnpm | 8+ | 前端包管理 |
| Docker | 可选 | 运行 MySQL 与 Redis |

### 1.2 初始化环境变量

```bash
cp .env.example .env
```

至少修改以下值：

```dotenv
MYSQL_ROOT_PASSWORD=请替换
REDIS_PASSWORD=请替换
DB_PASSWORD=请替换          # 必须与 MYSQL_ROOT_PASSWORD 一致
JWT_SECRET=请替换为至少32位随机字符串
```

生成随机密钥：

```bash
openssl rand -base64 48
```

在当前终端导入变量。后端启动时依赖这些变量，未导入会因占位符无法解析而启动失败：

```bash
set -a && . ./.env && set +a
```

Windows PowerShell：

```powershell
Get-Content .env | Where-Object { $_ -match '^[^#].+=' } | ForEach-Object {
  $name, $value = $_ -split '=', 2
  [Environment]::SetEnvironmentVariable($name, $value, "Process")
}
```

### 1.3 启动 MySQL 与 Redis

```bash
docker compose up -d
docker compose ps
```

默认映射：

| 服务 | 容器 | 宿主机端口 |
| --- | --- | --- |
| MySQL 8 | `youmi-scrm-mysql` | 3308 |
| Redis 7 | `youmi-scrm-redis` | 6380 |

首次启动会自动执行 `sql/youmi_scrm.sql`，创建 `youmi_scrm` 数据库、系统表、业务表、演示账号和虚构业务数据。

初始化脚本**只在数据卷为空时执行一次**。修改 SQL 后若想重新初始化，需要先备份，再删除 `volumes/mysql` 后重新 `docker compose up -d`。这是破坏性操作，不要在有真实数据的环境执行。

### 1.4 启动后端

```bash
cd backend
mvn spring-boot:run
```

- 端口：<http://localhost:8001>
- 默认 profile：`dev`
- 接口文档：<http://localhost:8001/doc.html>

开发配置从环境变量读取数据库与 Redis：

| 变量 | 默认值 |
| --- | --- |
| `DB_HOST` | `localhost` |
| `DB_PORT` | `3308` |
| `DB_NAME` | `youmi_scrm` |
| `DB_USERNAME` | `root` |
| `DB_PASSWORD` | 无默认值，必须提供 |
| `REDIS_HOST` | `localhost` |
| `REDIS_PORT` | `6380` |
| `REDIS_DATABASE` | `0` |
| `REDIS_PASSWORD` | 无默认值，必须提供 |
| `JWT_SECRET` | 无默认值，必须提供 |

### 1.5 启动前端

另开终端：

```bash
cd frontend
pnpm install
pnpm dev
```

打开 <http://localhost:3001>。开发代理把 `/dev-api` 转发到 `http://localhost:8001`，配置见 `frontend/.env.development`。

### 1.6 默认账号

| 账号 | 密码 | 角色 |
| --- | --- | --- |
| `admin` | `123456` | 系统管理员 |
| `dept_member` | `123456` | 部门成员（仅本人数据） |

演示账号仅用于本地体验，公网环境必须修改或删除。

## 2. 生产构建

### 2.1 后端

```bash
cd backend
mvn clean package -DskipTests
```

产物：`backend/target/youlai-boot.jar`。

启动：

```bash
export SPRING_PROFILES_ACTIVE=prod
export SERVER_PORT=8001
export DB_HOST=127.0.0.1
export DB_PORT=3306
export DB_NAME=youmi_scrm
export DB_USERNAME=youmi
export DB_PASSWORD='<强密码>'
export REDIS_HOST=127.0.0.1
export REDIS_PORT=6379
export REDIS_DATABASE=0
export REDIS_PASSWORD='<强密码>'
export JWT_SECRET='<至少32位随机字符串>'

java -jar target/youlai-boot.jar
```

生产配置说明：

- `application-prod.yml` 的数据库默认端口是 3306、Redis 默认 6379，与 Docker 开发端口不同，部署时请显式传入。
- SQL 日志默认开启（`StdOutImpl`）。高流量环境建议关闭，避免日志膨胀。
- Knife4j / Swagger 默认关闭；如确需开放，应加 IP 白名单或 Basic Auth。
- Actuator 仅暴露 `health` 与 `info`，且不返回详细信息。

建议使用 systemd 管理进程：

```ini
# /etc/systemd/system/youmi-scrm.service
[Unit]
Description=Youmi SCRM Backend
After=network.target mysql.service redis.service

[Service]
User=youmi
WorkingDirectory=/opt/youmi-scrm
EnvironmentFile=/etc/youmi-scrm.env
ExecStart=/usr/bin/java -Xms512m -Xmx1g -jar /opt/youmi-scrm/youlai-boot.jar
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now youmi-scrm
sudo journalctl -u youmi-scrm -f
```

`/etc/youmi-scrm.env` 权限应为 `600`，不要提交到仓库。

### 2.2 前端

```bash
cd frontend
pnpm install --frozen-lockfile
pnpm build
```

产物在 `frontend/dist`。生产环境请求前缀为 `/prod-api`，由 Nginx 去掉前缀后转发到后端。

## 3. Nginx 单机示例

```nginx
server {
    listen 80;
    server_name scrm.example.com;

    root /var/www/youmi-scrm;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /prod-api/ {
        proxy_pass http://127.0.0.1:8001/;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        client_max_body_size 20m;
        proxy_read_timeout 60s;
    }

    location ~* \.(js|css|png|jpg|jpeg|svg|woff2?)$ {
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
}
```

注意：

- `proxy_pass` 末尾的 `/` 会去掉 `/prod-api` 前缀；若省略，后端会收到 `/prod-api/api/v1/...` 并返回 404。
- 前端使用 Hash 路由，`try_files` 的回退主要是为了直接访问根路径和静态资源。
- 启用 HTTPS 后，把 `listen 80` 换成 443 并配置证书；建议用 Certbot 或云厂商证书。

启用配置：

```bash
sudo nginx -t
sudo systemctl reload nginx
```

## 4. 数据库与缓存

### 4.1 初始化

- 开发：`sql/youmi_scrm.sql` 由 Docker 首次启动自动导入。
- 生产：用 root 或有 DDL 权限的账号手工导入：

```bash
mysql -h 127.0.0.1 -u root -p < sql/youmi_scrm.sql
```

### 4.2 最小权限账号

应用账号不应使用 root：

```sql
CREATE DATABASE IF NOT EXISTS youmi_scrm
  DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE USER 'youmi'@'%' IDENTIFIED BY '<强密码>';
GRANT SELECT, INSERT, UPDATE, DELETE ON youmi_scrm.* TO 'youmi'@'%';
FLUSH PRIVILEGES;
```

如果应用需要执行代码生成等 DDL 操作，再单独授予 `CREATE`、`ALTER`、`INDEX`，不要直接给 `ALL`。

### 4.3 Redis

- 必须设置密码，禁止无认证端口暴露公网。
- 生产建议单独实例或独立 DB，不要与通用 SCRM 共用同一个 DB。
- 内存策略建议 `noeviction` 或 `allkeys-lru`，并配置监控；验证码丢失只影响登录，令牌丢失会导致用户重新登录。

### 4.4 备份

```bash
mysqldump -h 127.0.0.1 -u root -p \
  --single-transaction --routines --triggers \
  youmi_scrm > backup_youmi_scrm_$(date +%F).sql

gzip backup_youmi_scrm_*.sql
```

建议：

- 每日全量 + binlog 增量；
- 备份文件加密后存到另一台机器或对象存储；
- 每季度做一次恢复演练。

恢复：

```bash
gunzip -c backup_youmi_scrm_2026-10-20.sql.gz | mysql -h 127.0.0.1 -u root -p youmi_scrm
```

## 5. 与通用 SCRM 同时部署

复刻版默认端口刻意与通用 SCRM 错开：

| 项目 | 通用 SCRM | 复刻版 |
| --- | --- | --- |
| 前端 | 3000 | 3001 |
| 后端 | 8000 | 8001 |
| MySQL | 3307 | 3308 |
| Redis | 6379 DB12 | 6380 DB0 |
| 数据库名 | `youlai_admin` | `youmi_scrm` |

同一台机器部署时：

- 两套 `docker compose` 的容器名、卷目录、端口不能冲突；
- 两个后端使用不同的 `JWT_SECRET`，避免令牌跨系统通用；
- Nginx 使用不同 `server_name` 或不同 `location` 前缀；
- 不要共用数据库和 Redis 库。

## 6. 上线检查清单

### 配置

- [ ] `.env` 未提交，权限为 `600`
- [ ] `JWT_SECRET` 已替换为随机值，且两套系统不同
- [ ] 数据库与 Redis 使用强密码，不对公网开放
- [ ] 应用使用最小权限数据库账号
- [ ] `SPRING_PROFILES_ACTIVE=prod`
- [ ] Knife4j、Actuator 未暴露公网
- [ ] 演示账号已修改密码或禁用

### 网络与证书

- [ ] 全站 HTTPS，HTTP 自动跳转
- [ ] 安全响应头（HSTS、X-Content-Type-Options、Referrer-Policy）
- [ ] 反向代理超时与上传大小符合业务
- [ ] 防火墙只开放 80/443

### 数据

- [ ] 已配置定时备份并验证可恢复
- [ ] 已确认演示数据已清理，或明确标注为演示环境
- [ ] 不存储真实客户隐私数据（本项目未做合规评估）

### 可观测性

- [ ] 后端日志落盘并轮转
- [ ] 监控 8001 健康检查、MySQL、Redis
- [ ] 配置磁盘与内存告警

## 7. 常见问题

### 后端启动报 `Could not resolve placeholder 'DB_PASSWORD'`

环境变量未导入。执行 `set -a && . ./.env && set +a` 后重启，或检查 systemd 的 `EnvironmentFile`。

### `docker compose up` 提示缺少 `MYSQL_ROOT_PASSWORD`

没有 `.env`，或变量为空。先 `cp .env.example .env` 并填写。

### 数据库表不存在 / 登录报错

初始化脚本只在空数据卷执行。检查 `volumes/mysql` 是否已有旧数据，或手工导入 `sql/youmi_scrm.sql`。

### 前端 404 或接口打到错误地址

- 开发：确认 `VITE_PROXY_TARGET=http://localhost:8001`。
- 生产：确认 Nginx 的 `proxy_pass` 末尾有 `/`，并且前端构建时 `VITE_API_BASE=/prod-api`。

### 登录提示验证码错误

- 验证码一次性使用，刷新页面会重新获取；
- Redis 未连接或密码错误时，验证码无法写入，查看后端日志；
- 系统时间偏差过大会影响 JWT 校验。

### 接口返回 401 / 403

- 401：令牌缺失、过期或签名不一致（两套系统混用了 Token）；
- 403：当前账号缺少接口权限码，检查角色与菜单授权。

### 表格中的 ID 或金额计算错误

后端把 `Long` 序列化为字符串。前端参与运算前使用 `Number(value)`，否则会出现字符串拼接或 `NaN`。

### 中文 CSV 在 Excel 中乱码

项目已写入 UTF-8 BOM。若自行扩展导出逻辑，保留 `\uFEFF` 前缀。

## 8. 升级与回滚

升级：

```bash
# 1. 备份数据库
# 2. 拉取代码并构建
cd frontend && pnpm install --frozen-lockfile && pnpm build
cd ../backend && mvn clean package -DskipTests
# 3. 执行增量 SQL（如有）
# 4. 重启后端，替换前端静态文件
```

回滚：

- 保留上一版本的 jar 与 `dist` 目录，回滚时替换并重启；
- 数据库变更需提前准备反向 SQL；
- 回滚后清理浏览器缓存或调整静态资源版本号。

## 9. 公开演示部署的额外提醒

如果要把项目部署成公开演示：

1. 修改所有默认密码，禁用不必要的账号；
2. 使用独立的演示数据库，禁止导入任何真实客户数据；
3. 关闭写操作或定期重置数据，避免被恶意灌入内容；
4. 在页面显著位置标注「演示环境 / 非官方项目」；
5. 遵守 [DISCLAIMER.md](../DISCLAIMER.md) 中的名称与商标约定。
