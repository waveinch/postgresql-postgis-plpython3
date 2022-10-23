FROM postgres:13

ENV POSTGIS_MAJOR 3
ENV POSTGIS_VERSION 3.3.1+dfsg-1.pgdg110+1

MAINTAINER Andrea Minetti (andrea@wavein.ch)

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
           postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR=$POSTGIS_VERSION \
           postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR-scripts \
           build-essential  \
           libreadline-dev  \
           zlib1g-dev  \
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

# # DEBUGGER SOURCE
# RUN cd /usr/src/postgres/contrib \
#     && git clone https://github.com/ng-galien/pldebugger.git \
#     && cd pldebugger \
#     && git checkout $PLUGIN_BRANCH \
#     && make clean  \
#     && make USE_PGXS=1  \
#     && make USE_PGXS=1 install

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

# CONFIG
#COPY *.sql /docker-entrypoint-initdb.d/
COPY *.sh /docker-entrypoint-initdb.d/
RUN chmod a+r /docker-entrypoint-initdb.d/*
