# ===== 阶段1: 提取 sing-box =====
FROM ghcr.io/sagernet/sing-box:v1.10.1 AS sing-box

# ===== 阶段2: 运行镜像 =====
FROM alpine:3.19

RUN apk add --no-cache nginx ca-certificates libc6-compat tzdata && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    mkdir -p /etc/engine /www /run/nginx

# 从构建阶段复制 sing-box 二进制
COPY --from=sing-box /usr/local/bin/sing-box /usr/local/bin/engine

# 验证 sing-box 可以运行
RUN /usr/local/bin/engine version

# 复制 nginx 配置和网站文件
COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html /www/index.html
COPY start.sh /start.sh

RUN chmod +x /start.sh

# 暴露端口，使用 PORT 环境变量或默认 8080 (ClawCloud Run 默认 8080 或 80，我们默认 80 并在里面使用 nginx 监听)
# 注意 nginx.conf 中配置的 listen 为 80
EXPOSE 80

CMD ["/start.sh"]
