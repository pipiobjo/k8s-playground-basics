ARG GO_VERSION=1.18

## Stage 1
## Prepare dev environment for building service

FROM golang:${GO_VERSION}-alpine


RUN apk update && apk add --no-cache git ca-certificates tzdata && update-ca-certificates



RUN mkdir /gocache
ENV GOCACHE="/gocache" \
    CGO_ENABLED=0
RUN go install github.com/axw/gocov/gocov@v1.1.0  \
    && go install github.com/AlekSi/gocov-xml@v1.0.0 \
    && go install gotest.tools/gotestsum@v1.7.0 \
    && go install github.com/vakenbolt/go-test-report@v0.9.3 \
    &&  go install github.com/go-delve/delve/cmd/dlv@v1.8.3


ENV GO111MODULE="on" \
    CGO_ENABLED=0 \
    GOOS=linux \
    GOFLAGS="-mod=vendor"


ENTRYPOINT ["sh"]


ENV USER=serviceuser
ENV UID=10001

RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    "${USER}"
