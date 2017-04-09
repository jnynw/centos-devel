FROM centos:7

ENV GCC_VERSION 5.4.0

RUN yum update && yum -y upgrade && yum -y install wget gcc make
RUN set -x \
    && curl -fSL "http://ftpmirror.gnu.org/gcc/gcc-$GCC_VERSION/gcc-$GCC_VERSION.tar.bz2" -o gcc.tar.bz2 \
    && mkdir -p /usr/src/gcc \
    && tar -xf gcc.tar.bz2 -C /usr/src/gcc --strip-components=1 \
    && rm gcc.tar.bz2* \
    && cd /usr/src/gcc \
    && ./contrib/download_prerequisites \
    && { rm *.tar.* || true; } \
    && dir="$(mktemp -d)" \
    && cd "$dir" \
    && /usr/src/gcc/configure \
       --disable-multilib \
       --enable-languages=c,c++ \
    && make -j"$(nproc)" \
    && make install-strip \
    && cd .. \
    && rm -rf "$dir"

RUN echo '/usr/local/lib64' > /etc/ld.so.conf.d/local-lib64.conf \
    && ldconfig -v

