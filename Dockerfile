FROM kdb-insights-core:4.1.6

WORKDIR /opt/kx/app

COPY src ./src
COPY nano.sh multiproc.sh common.sh version.txt  ./
COPY flush ./flush
COPY config/env ./config/env

ENV QBIN=/opt/kx/kdb/l64/q

RUN source ./config/env
RUN echo "/data" > ./partitions

RUN yum upgrade -y && yum install -y wget sysstat nc dmidecode numactl hwloc

ENTRYPOINT [ "/bin/bash", "nano.sh" ]