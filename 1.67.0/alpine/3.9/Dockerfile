FROM alpine:3.9
LABEL Description="Boost C++ libraries on Alpine Linux"

ARG BOOST_VERSION=1.67.0
ARG BOOST_CHECKSUM=8aa4e330c870ef50a896634c931adf468b21f8a69b77007e45c444151229f665
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
    && curl -L --retry 3 "https://dl.bintray.com/boostorg/release/${BOOST_VERSION}/source/boost_1_67_0.tar.gz" -o boost.tar.gz \
    && echo "${BOOST_CHECKSUM}  boost.tar.gz" | sha256sum -c \
    && tar -xzf boost.tar.gz --strip 1 \
    && ./bootstrap.sh \
    && ./b2 --without-python --prefix=/usr -j ${CONCURRENT_PROCESSES} link=shared runtime-link=shared install \
    && cd .. && rm -rf ${BOOST_DIR} \
    && apk del .build-dependencies \
    && rm -rf /var/cache/*

CMD ["sh"]
