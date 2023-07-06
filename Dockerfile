FROM kdb-insights-core:0.41.1

WORKDIR /opt/kx/app

COPY src ./src
COPY mthread.sh runSeveral.sh ./
COPY flush ./flush

ENV QBIN=/opt/kx/kdb/l64/q

ENV RESULTDIR=/appdir/results
ENV LOGDIR=/appdir/logs
ENV THREADNR=1
ENV COMPRESS=""

ENV MEMUSAGETYPE=ratio
ENV MEMUSAGEVALUE=0.6
ENV RANDOMREADFILESIZETYPE=ratio
ENV RANDOMREADFILESIZEVALUE=3
ENV DBSIZE=full

ENV FLUSH=/opt/kx/app/flush/directmount.sh

RUN echo "/data" > ./partitions

RUN yum install -y wget
RUN wget https://github.com/mikefarah/yq/releases/download/v4.34.1/yq_linux_386 -O /usr/bin/yq && chmod +x /usr/bin/yq

ENTRYPOINT [ "/bin/bash", "mthread.sh" ]