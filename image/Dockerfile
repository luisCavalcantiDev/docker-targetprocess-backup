FROM debian:7.8
MAINTAINER Ewa Czechowska <ewa@ai-traders.com>

RUN DEBIAN_FRONTEND=noninteractive && \
  apt-get update && \
  apt-get install -y curl && \
  curl -sL https://deb.nodesource.com/setup_0.12 | bash - && \
  apt-get install -y nodejs npm wget nano && \
  rm -rf /var/lib/apt/lists/*

COPY ./backup /opt/tp_backup
COPY version.txt /opt/tp_backup/version.txt
RUN cd /opt/tp_backup && npm install tp-api@1.0.6 &&\
  chmod +x /opt/tp_backup/*.sh

ENTRYPOINT ["/bin/bash", "-c"]
CMD ["/opt/tp_backup/run.sh"]
