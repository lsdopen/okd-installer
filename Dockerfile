FROM alpine:3
RUN apk --no-cache add curl tar
ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
