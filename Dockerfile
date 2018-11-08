FROM alpine:3.8

RUN apk --update --no-cache add jq curl bash unzip && \
    curl -L -O https://github.com/ericchiang/pup/releases/download/v0.4.0/pup_v0.4.0_linux_amd64.zip && \
    unzip -j -d /bin/ pup_v0.4.0_linux_amd64.zip && \
    rm pup_v0.4.0_linux_amd64.zip && \
    apk del unzip && \
    mkdir /crawler
VOLUME ['/crawler']

ENV CRAWLER_DIR=/crawler \
    WAIT_TIME=1
COPY ./crawler.sh /

ENTRYPOINT ["bash", "/crawler.sh"]
