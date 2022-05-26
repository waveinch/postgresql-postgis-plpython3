FROM postgres:13

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

ENV POSTGIS_MAJOR 3
ENV POSTGIS_VERSION 3.2.1+dfsg-1.pgdg110+1

RUN apt-get update \
      && apt-cache showpkg postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR \
      && apt-get install -y --no-install-recommends \
           git python3 \
           python3-pip \
           postgresql-plpython3-13 \
           postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR=$POSTGIS_VERSION \
           postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR-scripts \
      && rm -rf /var/lib/apt/lists/*

RUN pip3 install requests


