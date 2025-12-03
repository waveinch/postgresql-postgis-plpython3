FROM postgres:16-bullseye

ENV POSTGIS_MAJOR 3

MAINTAINER Andrea Minetti (andrea.minetti@wsl.ch)

# ENV PLV8_VERSION=3.0.0

# RUN apt-get -y update 
# RUN apt-get -y install postgresql-server-dev-13
# RUN apt-get -y install python python2
# RUN apt-get -y install gcc make g++
# RUN apt-get -y install pkg-config
# RUN apt-get -y install libc++-dev
# RUN apt-get -y install libc++abi-dev 
# RUN apt-get -y install libglib2.0-dev
# RUN apt-get -y install libtinfo5
    
# RUN apt-get -y install curl git \ 
#     && mkdir -p /plv8build \
#     && cd plv8build \
#     && curl -o plv8.tar.gz -L https://github.com/plv8/plv8/archive/v${PLV8_VERSION}.tar.gz \
#     && tar -xvzf plv8.tar.gz \
#     && cd plv8-${PLV8_VERSION} && make  && make  install \
#     && rm -rf /plv8build  \
#     && rm -rf /var/lib/apt/lists/*

# RUN apt-get -y autoremove && apt-get clean



ENV PG_LIB=postgresql-server-dev-${PG_MAJOR}
ENV PG_BRANCH=REL_${PG_MAJOR}_STABLE
ENV PLUGIN_BRANCH=print-vars-${PG_MAJOR}

RUN apt-get update \
      && apt-cache showpkg postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR \
      && apt-get install -y --no-install-recommends \
           git python3 \
           python3-pip \
           postgresql-plpython3-$PG_MAJOR \
           postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR \
           postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR-scripts \
           build-essential  \
           libreadline-dev  \
           zlib1g-dev  \
           icu-devtools \
           libicu-dev \
           pkg-config \
           clang-13 \
           llvm-13 \
           bison  \
           libkrb5-dev  \
           flex  \
           $PG_LIB \
      && rm -rf /var/lib/apt/lists/*

# POSTGRES SOURCE
RUN cd /usr/src/ \
    && git clone https://github.com/postgres/postgres.git \
    && cd postgres \
    && git checkout $PG_BRANCH \
    && ./configure



RUN cd /usr/src/postgres/contrib \
    && git clone https://github.com/vibhorkum/pg_background.git \
    && cd pg_background \
    && make \
    && make install

# CLEANUP
RUN rm -r /usr/src/postgres \
    && apt --yes remove --purge  \
        git build-essential  \
        libreadline-dev  \
        zlib1g-dev bison  \
        libkrb5-dev flex  \
        $PG_PG_LIB \
    && apt --yes autoremove  \
    && apt --yes clean

# Python modules
RUN pip3 install requests



# Oracle FDW

# Latest version
ARG ORACLE_CLIENT_URL=https://download.oracle.com/otn_software/linux/instantclient/instantclient-basiclite-linuxx64.zip
#ARG ORACLE_SQLPLUS_URL=https://download.oracle.com/otn_software/linux/instantclient/instantclient-sqlplus-linuxx64.zip
ARG ORACLE_SDK_URL=https://download.oracle.com/otn_software/linux/instantclient/instantclient-sdk-linuxx64.zip

# Version specific setup
#ARG ORACLE_CLIENT_VERSION=18.5.0.0.0
#ARG ORACLE_CLIENT_PATH=185000
#ARG ORACLE_CLIENT_VERSION=19.8.0.0.0
#ARG ORACLE_CLIENT_PATH=19800
#ARG ORACLE_CLIENT_URL=https://download.oracle.com/otn_software/linux/instantclient/${ORACLE_CLIENT_PATH}/instantclient-basic-linux.x64-${ORACLE_CLIENT_VERSION}dbru.zip
#ARG ORACLE_SQLPLUS_URL=https://download.oracle.com/otn_software/linux/instantclient/${ORACLE_CLIENT_PATH}/instantclient-sqlplus-linux.x64-${ORACLE_CLIENT_VERSION}dbru.zip
#ARG ORACLE_SDK_URL=https://download.oracle.com/otn_software/linux/instantclient/${ORACLE_CLIENT_PATH}/instantclient-sdk-linux.x64-${ORACLE_CLIENT_VERSION}dbru.zip

ENV ORACLE_HOME=/usr/lib/oracle/client

RUN apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates wget unzip; \
    # instant client
    wget -O instant_client.zip ${ORACLE_CLIENT_URL}; \
    unzip instant_client.zip; \
    # sqlplus
    #wget -O sqlplus.zip ${ORACLE_SQLPLUS_URL}; \
    #unzip sqlplus.zip; \
    # sdk
    wget -O sdk.zip ${ORACLE_SDK_URL}; \
    unzip sdk.zip; \
    # install
    mkdir -p ${ORACLE_HOME}; \
    mv instantclient*/* ${ORACLE_HOME}; \
    rm -r instantclient*; \
    rm instant_client.zip sdk.zip; \
    #rm instant_client.zip sqlplus.zip sdk.zip; \
    # required runtime libs: libaio
    apt-get install -y --no-install-recommends libaio1; \
    apt-get purge -y --auto-remove

ENV PATH $PATH:${ORACLE_HOME}


ARG ORACLE_FDW_VERSION=2_6_0
ARG ORACLE_FDW_URL=https://github.com/laurenz/oracle_fdw/archive/ORACLE_FDW_${ORACLE_FDW_VERSION}.tar.gz
ARG SOURCE_FILES=tmp/oracle_fdw

    # oracle_fdw
RUN mkdir -p ${SOURCE_FILES}; \
    wget -O - ${ORACLE_FDW_URL} | tar -zx --strip-components=1 -C ${SOURCE_FILES}; \
    cd ${SOURCE_FILES}; \
    # install
    apt-get install -y --no-install-recommends make gcc; \
    make; \
    make install; \
    echo ${ORACLE_HOME} > /etc/ld.so.conf.d/oracle_instantclient.conf; \
    ldconfig; \
    # cleanup
    apt-get purge -y --auto-remove gcc make

RUN wget https://cdn.proj.org/ch_swisstopo_CHENyx06a.tif -P /usr/share/proj