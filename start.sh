#!/bin/sh

# ========== 1. 写入 usque 配置 ==========
if [ -n "$USQUE_CONFIG" ]; then
    echo "$USQUE_CONFIG" > /etc/engine/usque.json
    echo "[OK] usque 配置已写入"
else
    echo "[ERROR] USQUE_CONFIG 环境变量未设置"
    exit 1
fi

# ========== 2. 动态替换 nginx 中的 WS 路径 ==========
WS_PATH="${WS_PATH:-/x3k9m7q}"
sed -i "s|/x3k9m7q|${WS_PATH}|g" /etc/nginx/nginx.conf
echo "[OK] WS 路径设为 ${WS_PATH}"

# ========== 3. 启动 dnsmasq 本地 DNS 缓存 ==========
cat > /etc/dnsmasq.conf <<EOF
# 使用原始备用的官方内网 DNS 作为上游 (如 Docker 的 127.0.0.11 或 云提供商的 VPC DNS)
resolv-file=/etc/resolv.conf.bak
# 大缓存：10000 条记录
cache-size=10000
# 最小缓存 TTL：600 秒（即使上游返回短 TTL 也至少缓存 10 分钟）
min-cache-ttl=600
# 负面缓存（解析失败也强制缓存 60 秒，专治死链广告域名重复查询）
neg-ttl=60
# 并发 DNS 查询限制（防雪崩）
dns-forward-max=300
# 不使用 hosts 文件
no-hosts
# 前台运行（我们自己后台化）
keep-in-foreground
# 监听地址
listen-address=127.0.0.1
bind-interfaces
EOF

# 先备份原始 resolv.conf，然后指向 dnsmasq
cp /etc/resolv.conf /etc/resolv.conf.bak
dnsmasq &
DNSMASQ_PID=$!
sleep 1

if kill -0 $DNSMASQ_PID 2>/dev/null; then
    # 将系统 DNS 指向本地 dnsmasq
    echo "nameserver 127.0.0.1" > /etc/resolv.conf
    echo "[OK] dnsmasq DNS 缓存已启动 (PID: $DNSMASQ_PID, 缓存: 10000条, min-TTL: 600s)"
else
    echo "[WARN] dnsmasq 启动失败，使用默认 DNS"
    cp /etc/resolv.conf.bak /etc/resolv.conf
fi

# ========== 4. 生成 sing-box 配置 ==========
UUID="${UUID:-7f1ba9cb-947b-47c2-8e55-576b17295f0c}"

cat > /etc/engine/config.json <<EOF
{
  "log": {"level": "warn"},
  "dns": {
    "servers": [
      {
        "tag": "dns-direct",
        "address": "8.8.8.8",
        "detour": "direct"
      }
    ],
    "strategy": "prefer_ipv4"
  },
  "inbounds": [
    {
      "type": "vless",
      "listen": "127.0.0.1",
      "listen_port": 10801,
      "users": [{"uuid": "${UUID}"}],
      "transport": {"type": "ws", "path": "${WS_PATH}"},
      "sniff": true
    }
  ],
  "outbounds": [
    {
      "tag": "usque-socks",
      "type": "socks",
      "server": "127.0.0.1",
      "server_port": 1080
    },
    {"tag": "direct", "type": "direct"}
  ],
  "route": {
    "final": "usque-socks"
  }
}
EOF
echo "[OK] sing-box 配置已生成 (route级域名预解析 + dnsmasq缓存)"

# ========== 5. 启动 usque (SOCKS5 模式, 不指定 -d 使用系统 DNS → dnsmasq) ==========
/usr/local/bin/usque -c /etc/engine/usque.json socks \
    -b 127.0.0.1 -p 1080 &
USQUE_PID=$!

echo "[..] 等待 usque 连接..."
sleep 8

if kill -0 $USQUE_PID 2>/dev/null; then
    echo "[OK] usque SOCKS5 已启动 (PID: $USQUE_PID)"
else
    echo "[ERROR] usque 启动失败"
    exit 1
fi

# ========== 6. 启动 sing-box ==========
/usr/local/bin/engine run -c /etc/engine/config.json &
ENGINE_PID=$!
sleep 2

if kill -0 $ENGINE_PID 2>/dev/null; then
    echo "[OK] sing-box 已启动 (PID: $ENGINE_PID, 端口: 10801)"
else
    echo "[ERROR] sing-box 启动失败！"
    /usr/local/bin/engine run -c /etc/engine/config.json
    exit 1
fi

# ========== 7. 启动 nginx (前台) ==========
echo "[OK] 所有服务就绪，启动 nginx..."
nginx -g 'daemon off;'
