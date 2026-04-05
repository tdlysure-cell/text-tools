#!/bin/sh
set -e

# ========== 1. 动态替换 nginx 中的 WS 路径 ==========
WS_PATH="${WS_PATH:-/x3k9m7q}"
sed -i "s|/x3k9m7q|${WS_PATH}|g" /etc/nginx/nginx.conf
echo "[OK] WS 路径设为 ${WS_PATH}"

# ========== 2. 生成极简版 sing-box VLESS 纯净直连配置 ==========
UUID="${UUID:-7f1ba9cb-947b-47c2-8e55-576b17295f0c}"

cat > /etc/engine/config.json <<EOF
{
  "log": {
    "level": "warn"
  },
  "dns": {
    "servers": [
      {
        "tag": "local-dns",
        "address": "local",
        "detour": "direct"
      }
    ],
    "strategy": "ipv4_only"
  },
  "inbounds": [
    {
      "type": "vless",
      "listen": "127.0.0.1",
      "listen_port": 10801,
      "users": [
        {
          "uuid": "${UUID}"
        }
      ],
      "transport": {
        "type": "ws",
        "path": "${WS_PATH}"
      },
      "sniff": true,
      "sniff_override_destination": true
    }
  ],
  "outbounds": [
    {
      "tag": "direct",
      "type": "direct"
    },
    {
      "tag": "block",
      "type": "block"
    }
  ],
  "route": {
    "rules": [
      {
        "protocol": "dns",
        "outbound": "direct"
      }
    ],
    "final": "direct"
  }
}
EOF
echo "[OK] sing-box 纯纯的 VLESS 直连配置已生成！"

# ========== 3. 启动 sing-box ==========
/usr/local/bin/engine run -c /etc/engine/config.json &
ENGINE_PID=$!
sleep 2

# 检查 sing-box 是否存活
if kill -0 $ENGINE_PID 2>/dev/null; then
    echo "[OK] sing-box 已启动 (PID: $ENGINE_PID, 端口: 10801)"
else
    echo "[ERROR] sing-box 启动失败！检查配置。"
    /usr/local/bin/engine run -c /etc/engine/config.json
    exit 1
fi

# ========== 4. 启动 nginx (前台运行维持容器生命) ==========
echo "[OK] 服务器准备就绪，极速 VLESS 直连就位。启动 nginx..."
exec nginx -g 'daemon off;'
