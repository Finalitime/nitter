FROM nimlang/nim:2.2.0-alpine-regular as builder
LABEL maintainer="setenforce@protonmail.com"

RUN apk --no-cache add libsass-dev pcre

WORKDIR /app

COPY nitter.nimble .
RUN nimble install -y --depsOnly

COPY . .
RUN nimble build -d:danger -d:lto -d:strip --mm:refc \
    && nimble scss \
    && nimble md

FROM alpine:latest
WORKDIR /app
RUN apk --no-cache add pcre ca-certificates

COPY --from=builder /app/nitter ./nitter
COPY --from=builder /app/public ./public
COPY nitter.conf ./nitter.conf
CMD ./nitter -c ./nitter.conf

EXPOSE 8080
RUN adduser -h /app -D -s /bin/sh nitter
USER nitter

CMD ./nitter
