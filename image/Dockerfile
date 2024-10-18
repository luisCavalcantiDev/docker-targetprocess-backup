FROM debian:bullseye-slim

# Set maintainer (optional)
# LABEL maintainer="ewa@ai-traders.com"

# Install core dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl gnupg2 wget nano ca-certificates lsb-release && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install jq from GitHub
RUN wget --tries=3 --retry-connrefused --wait=3 --random-wait \
    https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 -O /usr/bin/jq && \
    chmod +x /usr/bin/jq

# Install Node.js 18.x from Nodesource
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/*

# Install tp-api globally
RUN npm install --global tp-api@1.2.2
ENV NODE_PATH=/usr/lib/node_modules

# Copy backup scripts and version file
COPY ./backup /opt/tp_backup
COPY version.txt /opt/tp_backup/version.txt

# Make sure scripts are executable
RUN chmod +x /opt/tp_backup/*.sh

# Set entry point and default command
ENTRYPOINT ["/bin/bash"]
CMD ["/opt/tp_backup/run.sh"]
