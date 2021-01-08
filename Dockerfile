FROM alpine:3
RUN apk --no-cache add curl tar
ADD pxe /opt/pxe
ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
