FROM openjdk:8-jre-alpine

LABEL maintainer="S-Kazuki<contact@revoneo.com>"

COPY ./docker-entrypoint.sh /

ENV DYNAMODB_BUILD_DEPS=curl \
DYNAMODB_RUN_DEPS=bash \
DYNAMODB_VERSION=latest \
DYNAMODB_PORT=8000 \
JAVA_OPTS=

WORKDIR /var/dynamodb_local

VOLUME ["/dynamodb_local_db"]

RUN chmod +x /docker-entrypoint.sh \
&& apk add --update --no-cache --virtual .dynamodb-build-deps ${DYNAMODB_BUILD_DEPS} \
&& apk add --update --no-cache --virtual .dynamodb-run-deps ${DYNAMODB_RUN_DEPS} \
&& curl -sL -O https://s3-ap-northeast-1.amazonaws.com/dynamodb-local-tokyo/dynamodb_local_${DYNAMODB_VERSION}.tar.gz \
&& curl -sL -O https://s3-ap-northeast-1.amazonaws.com/dynamodb-local-tokyo/dynamodb_local_${DYNAMODB_VERSION}.tar.gz.sha256 \
&& sha256sum -c dynamodb_local_${DYNAMODB_VERSION}.tar.gz.sha256 \
&& tar zxvf dynamodb_local_${DYNAMODB_VERSION}.tar.gz \
&& rm dynamodb_local_${DYNAMODB_VERSION}.tar.gz dynamodb_local_${DYNAMODB_VERSION}.tar.gz.sha256 \
\
&& apk add tzdata \
&& TZ=${TZ:-Asia/Tokyo} \
&& cp /usr/share/zoneinfo/$TZ /etc/localtime \
&& echo $TZ> /etc/timezone \
&& apk del tzdata .dynamodb-build-deps \
&& rm -rf /var/cache/apk/*

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["--sharedDb", "-dbPath", "/dynamodb_local_db"]
