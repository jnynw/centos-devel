FROM centos:7

RUN yum update && yum -y upgrade && yum -y install gcc gcc-c++ make bzip2 wget

ENV GCC_VERSION 5.4.0
RUN set -x \
    && curl -fSL "http://ftpmirror.gnu.org/gcc/gcc-$GCC_VERSION/gcc-$GCC_VERSION.tar.bz2" -o gcc.tar.bz2 \
    && mkdir -p /usr/src/gcc \
    && tar -xjf gcc.tar.bz2 -C /usr/src/gcc --strip-components=1 \
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

ENV BOOST_VERSION 1.63.0
RUN curl -fSL "https://downloads.sourceforge.net/project/boost/boost/${BOOST_VERSION}/boost_${BOOST_VERSION//./_}.tar.bz2?r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Fboost%2Ffiles%2Fboost%2F${BOOST_VERSION}%2F&ts=$(date +%s)&use_mirror=nchc" -o boost.tar.bz2 \
    && dir="$(mktemp -d)" \
    && tar -xjf boost.tar.bz2 -C "$dir" --strip-components=1 \
    && rm boost.tar.bz2* \
    && cd "$dir" \
    && echo "using gcc : : /usr/local/bin/gcc ; " >> tools/build/src/user-config.jam \
    && ./bootstrap.sh --prefix=/usr/local \
    && (./b2 -a -j"$(nproc)" install || true) \
    && cd .. \
    && rm -rf "$dir"

ENV CMAKE_VERSION 3.7.2
RUN curl -fSL "https://cmake.org/files/v3.7/cmake-${CMAKE_VERSION}.tar.gz" -o cmake.tar.gz \
    && dir="$(mktemp -d)" \
    && tar -xzf cmake.tar.gz -C "$dir" --strip-components=1 \
    && rm cmake.tar.gz \
    && cd "$dir" \
    && ./configure \
    && make -j"$(nproc)" \
    && make install \
    && cd .. \
    && rm -rf "$dir"

RUN yum -y install openssl-devel zlib-devel libtool automake python-devel texinfo

ENV GDB_VERSION 7.12.1
RUN curl -fSL "http://ftpmirror.gnu.org/gdb/gdb-$GDB_VERSION.tar.gz" -o gdb.tar.gz \
    && dir="$(mktemp -d)" \
    && tar -xzf gdb.tar.gz -C "$dir" --strip-components=1 \
    && rm gdb.tar.gz \
    && cd "$dir" \
    && ./configure \
    && make -j"$(nproc)" \
    && make install \
    && cd .. \
    && rm -rf "$dir"
    
