
FROM rockylinux:9.2
ENTRYPOINT ["/entrypoint.sh"]

RUN yum install epel-release -y
RUN yum install curl procps vim unzip lbzip2 -y --allowerasing
RUN yum install python3 dnsutils postgresql python-pip python-psycopg2 -y
RUN pip install psycopg

RUN useradd -m pgedge -s /bin/bash

RUN mkdir -p /opt/pgedge && chown pgedge. /opt/pgedge
ENV PATH /opt/pgedge/pgedge:${PATH}

COPY fake-systemctl /usr/local/bin/systemctl
COPY entrypoint.sh /

