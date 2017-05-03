#
# copied from ljfranklin/deployments

FROM alpine:latest

RUN apk update && \
    apk --no-cache add \
    ca-certificates wget bash git openssh perl \
    # needed to render bosh templates
    ruby ruby-dev python \
    # needed to run Google CPI packaging scripts
    make alpine-sdk

RUN wget -q -O /usr/local/bin/jq https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 && \
    chmod +x /usr/local/bin/jq

# the Google CPI Go blob are dynamically linked against glibc
RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub && \
  wget -q -O /tmp/glibc.apk https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.23-r3/glibc-2.23-r3.apk && \
  apk add /tmp/glibc.apk && \
  rm -rf /tmp/glibc.apk

# Install Google Cloud CLI
RUN wget -q -O /tmp/gcloud.tar.gz https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-153.0.0-linux-x86_64.tar.gz && \
  tar -C /tmp/ -xzvf /tmp/gcloud.tar.gz && \
  /tmp/google-cloud-sdk/install.sh --usage-reporting false --path-update false --command-completion false -q

RUN echo source /tmp/google-cloud-sdk/path.bash.inc > /root/.bashrc

RUN gem install json --no-rdoc --no-ri # json is not a default gem in alpine
