FROM docker.n8n.io/n8nio/n8n:1.104.2

USER root

# 安装中文字体、Chromium 与常见 Puppeteer 依赖
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      fontconfig \
      fonts-noto-cjk \
      fonts-noto-color-emoji \
      tzdata \
      chromium \
      ca-certificates \
      # 常见无头 Chrome 依赖（按需精简）
      libnss3 libxss1 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 \
      libxcursor1 libxdamage1 libxext6 libxfixes3 libxrandr2 \
      libgbm1 libatk1.0-0 libatk-bridge2.0-0 \
      libpango-1.0-0 libharfbuzz0b libfreetype6 \
      udev && \
    rm -rf /var/lib/apt/lists/*

# Puppeteer 使用系统 Chromium
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

# 刷新字体缓存（即使失败也不影响构建）
RUN fc-cache -f -v || true && \
    fc-list | grep -Ei "noto|cjk|emoji" || true

# 安装自定义 n8n 节点（持久位置）
RUN mkdir -p /opt/n8n-custom-nodes && \
    cd /opt/n8n-custom-nodes && \
    npm install --omit=dev n8n-nodes-puppeteer && \
    chown -R node:node /opt/n8n-custom-nodes

# （可选）显式告诉 n8n 自定义节点目录
ENV N8N_CUSTOM_EXTENSIONS=/opt/n8n-custom-nodes

USER node
# 不写 ENTRYPOINT -> 继承上游 entrypoint 与 CMD

ENTRYPOINT ["/docker-custom-entrypoint.sh"]
