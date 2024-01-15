ARG BUILD_FROM
# hadolint ignore=DL3006
FROM ${BUILD_FROM}

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Copy Bouncer
RUN mkdir -p /tmp/crowdsec-bouncer
COPY crowdsec-bouncer/ /tmp/crowdsec-bouncer/
RUN ls -la /tmp/crowdsec-bouncer

RUN \
    apk add --no-cache --virtual .build-dependencies \
        build-base=0.5-r3 \
        lua5.1-dev=5.1.5-r13 \
    \
    && apk add --no-cache --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing \
        crowdsec=1.5.5-r0 \
    && apk add --no-cache \
        lua5.1=5.1.5-r13  \
        luarocks=3.9.2-r1 \
        gettext=0.22.3-r0\
        nginx-mod-http-lua=1.24.0-r14 \
    \
    && ln -s /usr/bin/luarocks-5.1 /usr/bin/luarocks \
    \
    && /tmp/crowdsec-bouncer/install.sh \
    && cd /var/lib/nginx \
    && ln -s /usr/lib/nginx/modules ./ \
    && apk del --purge .build-dependencies \
    && rm -f -r \
        /tmp/crowdsec-bouncer 

# Build arguments
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_DESCRIPTION
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_VERSION

# Labels
LABEL \
    io.hass.name="${BUILD_NAME}" \
    io.hass.description="${BUILD_DESCRIPTION}" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="Franck Nijhof <frenck@addons.community>" \
    org.opencontainers.image.title="${BUILD_NAME}" \
    org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
    org.opencontainers.image.vendor="Home Assistant Community Add-ons" \
    org.opencontainers.image.authors="Franck Nijhof <frenck@addons.community>" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.url="https://addons.community" \
    org.opencontainers.image.source="https://github.com/${BUILD_REPOSITORY}" \
    org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}
