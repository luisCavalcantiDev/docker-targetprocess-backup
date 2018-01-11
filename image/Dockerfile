FROM debian:stretch-slim
LABEL maintainer="ewa@ai-traders.com"

RUN apt-get update &&\
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends\
  curl gnupg2 wget nano ca-certificates &&\
  apt-get -y autoremove && apt-get -y autoclean && apt-get -y clean &&\
  rm -rf /tmp/* /var/tmp/* && rm -rf /var/lib/apt/lists/*

# using `curl -sL https://deb.nodesource.com/setup_9.x | bash -`
# does not show errors, so let's wget it
RUN wget -O /tmp/node-setup_9.x https://deb.nodesource.com/setup_9.x &&\
  chmod +x /tmp/node-setup_9.x &&\
  /tmp/node-setup_9.x &&\
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends\
  nodejs=9.4.0-1nodesource1 &&\
  apt-get -y autoremove && apt-get -y autoclean && apt-get -y clean &&\
  rm -rf /tmp/* /var/tmp/* && rm -rf /var/lib/apt/lists/*

COPY ./backup /opt/tp_backup
COPY version.txt /opt/tp_backup/version.txt
RUN cd /opt/tp_backup && npm install --global tp-api@1.2.2 &&\
  chmod +x /opt/tp_backup/*.sh

# in order to allow using tp-api from any path, for experimenting
ENV NODE_PATH=/usr/lib/node_modules

ENTRYPOINT ["/bin/bash", "-c"]
CMD ["/opt/tp_backup/run.sh"]
