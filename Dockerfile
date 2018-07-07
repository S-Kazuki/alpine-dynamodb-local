FROM openjdk:8-jre-slim

LABEL maintainer="S-Kazuki<contact@revoneo.com>"

COPY ./docker-entrypoint.sh /

ENV DYNAMODB_BUILD_DEPS="curl" \
DYNAMODB_VERSION=latest \
DYNAMODB_PORT=8000 \
JAVA_OPTS=

WORKDIR /var/dynamodb_local

VOLUME ["/dynamodb_local_db"]

RUN chmod +x /docker-entrypoint.sh \
&& apt-get update -y \
&& apt-get install -y ${DYNAMODB_BUILD_DEPS} \
&& curl -sL -O https://s3-ap-northeast-1.amazonaws.com/dynamodb-local-tokyo/dynamodb_local_${DYNAMODB_VERSION}.tar.gz \
&& curl -sL -O https://s3-ap-northeast-1.amazonaws.com/dynamodb-local-tokyo/dynamodb_local_${DYNAMODB_VERSION}.tar.gz.sha256 \
&& sha256sum -c dynamodb_local_${DYNAMODB_VERSION}.tar.gz.sha256 \
&& tar zxvf dynamodb_local_${DYNAMODB_VERSION}.tar.gz \
&& rm dynamodb_local_${DYNAMODB_VERSION}.tar.gz dynamodb_local_${DYNAMODB_VERSION}.tar.gz.sha256 \
&& rm -rf third_party_licenses *.txt \
\
&& TZ=${TZ:-Asia/Tokyo} \
&& cp /usr/share/zoneinfo/$TZ /etc/localtime \
&& echo $TZ> /etc/timezone \
&& apt-get remove -y ${DYNAMODB_BUILD_DEPS}

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["--sharedDb", "-dbPath", "/dynamodb_local_db"]
