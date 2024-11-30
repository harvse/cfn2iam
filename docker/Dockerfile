FROM alpine

RUN apk add bash jq aws-cli && \
    addgroup -g 1000 app && \
    adduser -G app -u 1000 app -D && \
    mkdir /var/app && \
    chown app:app /var/app

USER app

WORKDIR /var/app

COPY ./entrypoint.sh ./get-sources.sh /var/app/

RUN mkdir /var/app/schemas /var/app/cfn /var/app/iam && \
    /var/app/get-sources.sh && \
    rm /var/app/get-sources.sh

VOLUME ["/var/app/cfn", "/var/app/iam"]

ENTRYPOINT ["/var/app/entrypoint.sh"]