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
RUN wget https://github.com/mikefarah/yq/releases/download/v4.34.1/yq_linux_386 -O /usr/bin/yq && chmod +x /usr/bin/yq

ENTRYPOINT [ "/bin/bash", "mthread.sh" ]