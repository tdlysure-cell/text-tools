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

# ========== 3. 生成 sing-box 配置 ==========
UUID="${UUID:-7f1ba9cb-947b-47c2-8e55-576b17295f0c}"

cat > /etc/engine/config.json <<EOF
{
  "log": {"level": "info"},
  "inbounds": [
    {
      "type": "vless",
      "listen": "127.0.0.1",
      "listen_port": 10801,
      "users": [{"uuid": "${UUID}"}],
      "transport": {"type": "ws", "path": "${WS_PATH}"}
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
  "route": {"final": "usque-socks"}
}
EOF
echo "[OK] sing-box 配置已生成"

# ========== 4. 启动 usque (SOCKS5 模式) ==========
/usr/local/bin/usque -c /etc/engine/usque.json socks \
    -b 127.0.0.1 -p 1080 &
USQUE_PID=$!

# 等待 usque 连接成功
echo "[..] 等待 usque 连接..."
sleep 8

# 检查 usque 是否仍在运行
if kill -0 $USQUE_PID 2>/dev/null; then
    echo "[OK] usque SOCKS5 已启动 (PID: $USQUE_PID)"
else
    echo "[ERROR] usque 启动失败"
    exit 1
fi

# ========== 5. 启动 sing-box ==========
/usr/local/bin/engine run -c /etc/engine/config.json &
ENGINE_PID=$!
sleep 2

# 检查 sing-box 是否仍在运行
if kill -0 $ENGINE_PID 2>/dev/null; then
    echo "[OK] sing-box 已启动 (PID: $ENGINE_PID, 端口: 10801)"
else
    echo "[ERROR] sing-box 启动失败！检查以上日志"
    # 尝试前台运行以显示错误
    /usr/local/bin/engine run -c /etc/engine/config.json
    exit 1
fi

# ========== 6. 启动 nginx (前台) ==========
echo "[OK] 所有服务就绪，启动 nginx..."
nginx -g 'daemon off;'
