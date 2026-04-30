FROM alpine:latest

# Baresip + Dependencies installieren
RUN apk add --no-cache \
    baresip \
    baresip-modules \
    ffmpeg \
    curl \
    jq

# Config Verzeichnis
RUN mkdir -p /etc/baresip /share/baresip

# Startup Script
COPY run.sh /
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
