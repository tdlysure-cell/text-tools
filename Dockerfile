# ===== 阶段1: 编译 usque =====
FROM golang:1.24-alpine AS builder

RUN apk add --no-cache git

WORKDIR /src
RUN git clone https://github.com/Diniboy1123/usque.git . && \
    CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o usque -ldflags="-s -w" .

# ===== 阶段2: 下载 sing-box =====
FROM alpine:3.19 AS fetcher

ARG SB_VER=1.13.5
RUN SB_DOMAIN="github.com" && \
    SB_PATH="SagerNet/sing-box/releases/download" && \
    wget -q "https://${SB_DOMAIN}/${SB_PATH}/v${SB_VER}/sing-box-${SB_VER}-linux-amd64.tar.gz" -O /tmp/sb.tar.gz && \
    tar xzf /tmp/sb.tar.gz -C /tmp && \
    mv /tmp/sing-box-${SB_VER}-linux-amd64/sing-box /tmp/engine && \
    chmod +x /tmp/engine

# ===== 阶段3: 运行镜像 =====
FROM alpine:3.19

RUN apk add --no-cache nginx ca-certificates libc6-compat && \
    mkdir -p /etc/engine /www /run/nginx

# 从构建阶段复制二进制
COPY --from=builder /src/usque /usr/local/bin/usque
COPY --from=fetcher /tmp/engine /usr/local/bin/engine

# 复制配置文件
COPY nginx.conf /etc/nginx/nginx.conf
COPY start.sh /start.sh
COPY index.html /www/index.html

RUN chmod +x /start.sh /usr/local/bin/usque /usr/local/bin/engine

EXPOSE 8080

CMD ["/start.sh"]
