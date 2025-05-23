FROM kdb-insights-core:4.1.6

WORKDIR /opt/kx/app

COPY src ./src
COPY mthread.sh runSeveral.sh common.sh version.yaml  ./
COPY flush ./flush
COPY config/env ./config/env

ENV QBIN=/opt/kx/kdb/l64/q

RUN source ./config/env
RUN echo "/data" > ./partitions

RUN yum upgrade -y && yum install -y wget sysstat nc dmidecode numactl

ENTRYPOINT [ "/bin/bash", "mthread.sh" ]