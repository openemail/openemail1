FROM solr:7-alpine
LABEL maintainer "Chinthaka Desahpriya <chinthaka@cybergate.lk>"

USER root
COPY docker-entrypoint.sh /

RUN apk --no-cache add su-exec curl tzdata \
  && chmod +x /docker-entrypoint.sh \
  && /docker-entrypoint.sh --bootstrap

ENTRYPOINT ["/docker-entrypoint.sh"]
