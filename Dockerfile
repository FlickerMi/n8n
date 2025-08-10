FROM docker.n8n.io/n8nio/n8n:1.104.2

USER root

# 安装中文字体、Chromium 与常见 Puppeteer 依赖
RUN apk add --no-cache \
    fontconfig \
    noto-fonts-cjk \
    noto-fonts-emoji \
    ttf-freefont \
    ttf-liberation \
    wqy-zenhei \
    ca-certificates \
    tzdata \
    chromium \
    nss \
    glib \
    freetype \
    harfbuzz \
    udev

# Puppeteer 使用系统 Chromium
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

# 刷新字体缓存（即使失败也不影响构建）
RUN fc-cache -f -v || true && \
    fc-list | grep -Ei "noto|cjk|emoji" || true

# 安装自定义 n8n 节点（持久位置）
RUN mkdir -p /opt/n8n-custom-nodes && \
    cd /opt/n8n-custom-nodes && \
    npm install n8n-nodes-puppeteer && \
    chown -R node:node /opt/n8n-custom-nodes

USER node

