FROM postgres

RUN apt-get update && \
    apt-get install curl -y && \
    apt-get install unzip -y && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install

COPY src/cpln-entrypoint.sh /usr/local/bin/cpln-entrypoint.sh
RUN chmod a+x /usr/local/bin/cpln-entrypoint.sh

ENTRYPOINT ["cpln-entrypoint.sh", "postgres"]