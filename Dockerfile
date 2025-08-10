FROM docker.n8n.io/n8nio/n8n

USER root

# Install Chrome dependencies and Chrome
RUN apk add --no-cache \
    chromium \
    nss \
    glib \
    freetype \
    freetype-dev \
    harfbuzz \
    ca-certificates \
    ttf-freefont \
    udev \
    ttf-liberation \
    font-noto-emoji \
    wqy-zenhei \ 
    font-noto-cjk \
    fontconfig \
    tzdata


# Tell Puppeteer to use installed Chrome instead of downloading it
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

# Ensure font cache is updated
RUN fc-cache -fv && \
    fc-list | grep -i "wqy\|noto"  # Verify Chinese font installation

# Install n8n-nodes-puppeteer in a permanent location
RUN mkdir -p /opt/n8n-custom-nodes && \
    cd /opt/n8n-custom-nodes && \
    npm install n8n-nodes-puppeteer && \
    chown -R node:node /opt/n8n-custom-nodes

# Copy our custom entrypoint
COPY docker-custom-entrypoint.sh /docker-custom-entrypoint.sh
RUN apk add --no-cache dos2unix && \  
    dos2unix /docker-custom-entrypoint.sh && \  
    chmod +x /docker-custom-entrypoint.sh && \
    chown node:node /docker-custom-entrypoint.sh && \
    apk del dos2unix  

USER node

ENTRYPOINT ["/docker-custom-entrypoint.sh"]
