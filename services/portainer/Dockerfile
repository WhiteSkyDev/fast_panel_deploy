FROM portainer/portainer-ce:lts

COPY --chmod=755 healthcheck /healthcheck

HEALTHCHECK --interval=30s --timeout=10s --retries=3 --start-period=30s \
  CMD ["/healthcheck"]