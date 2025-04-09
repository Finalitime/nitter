FROM nimlang/nim:2.2.0-alpine-regular as nim
LABEL maintainer="setenforce@protonmail.com"

RUN apk --no-cache add libsass-dev pcre

WORKDIR /src/nitter

COPY nitter.nimble .
RUN nimble install -y --depsOnly

# Copy everything except your final nitter.conf
COPY . .
RUN nimble build -d:danger -d:lto -d:strip --mm:refc \
    && nimble scss \
    && nimble md

FROM alpine:latest
WORKDIR /src/
RUN apk --no-cache add pcre ca-certificates

COPY --from=nim /src/nitter/nitter ./nitter
COPY --from=nim /src/nitter/public ./public

# Copy your custom config LAST so it’s not overwritten
COPY nitter.conf ./nitter.conf

EXPOSE 8080
RUN adduser -h /src/ -D -s /bin/sh nitter
USER nitter

CMD ./nitter
