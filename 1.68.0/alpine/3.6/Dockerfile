FROM alpine:3.6
LABEL Description="Boost C++ libraries on Alpine Linux"

ARG BOOST_VERSION=1.68.0
ARG BOOST_CHECKSUM=da3411ea45622579d419bfda66f45cd0f8c32a181d84adfa936f5688388995cf
ARG BOOST_DIR=boost
ARG CONCURRENT_PROCESSES=1
ENV BOOST_VERSION ${BOOST_VERSION}

RUN mkdir -p ${BOOST_DIR} \
    && apk --no-cache add --virtual .build-dependencies \
    build-base \
    linux-headers \
    curl \
    tar \
    && cd ${BOOST_DIR} \
    && curl -L --retry 3 "https://dl.bintray.com/boostorg/release/${BOOST_VERSION}/source/boost_1_68_0.tar.gz" -o boost.tar.gz \
    && echo "${BOOST_CHECKSUM}  boost.tar.gz" | sha256sum -c \
    && tar -xzf boost.tar.gz --strip 1 \
    && ./bootstrap.sh \
    && ./b2 --without-python --prefix=/usr -j ${CONCURRENT_PROCESSES} link=shared runtime-link=shared install \
    && cd .. && rm -rf ${BOOST_DIR} \
    && apk del .build-dependencies \
    && rm -rf /var/cache/*

CMD ["sh"]
