###################################################################################
## Multistage docker build for creating a smallest possible docker container
###################################################################################


## Stage 1
## Prepare dev environment for building service
ARG BASE_IMAGE
# has to be lower case to allow usage in stage names
ARG build_mode

FROM ${BASE_IMAGE} AS base



## Stage 2
## Downloading required modules and building go service in separate build environment

FROM base as build-common

ARG COMPONENT_PATH
ARG SERVICE_VERSION

ENV APP_NAME="main" \
    APP_PATH="/app" \
    APP_PORT=8080 \
    APP_HEALTH_PORT=8081

ENV APP_BUILD_NAME="${APP_NAME}"

COPY ../ ${APP_PATH}
EXPOSE ${APP_PORT}
EXPOSE ${APP_HEALTH_PORT}

WORKDIR ${APP_PATH}/${COMPONENT_PATH}
RUN go mod tidy && go mod download && go mod vendor


FROM build-common as build-debug

ARG SERVICE_VERSION


## Build



# Here `-N` will disable optimization and `-l` disable inlining
# for all parameters check https://pkg.go.dev/cmd/compile
# or go tool compile -help
# CGO_ENABLED=0 go build -gcflags "all=-N -l"
RUN CGO_ENABLED=0 go build -gcflags="all=-N -l" -ldflags="-X pipiobjo.com/library/buildinfo.Version=${SERVICE_VERSION}" -mod vendor cmd/main.go && chmod +x ${APP_BUILD_NAME}



FROM build-common as build-runtime

ARG SERVICE_VERSION
## Build

#RUN (([ ! -d "${APP_PATH}/vendor" ] && go mod tidy && go mod download && go mod vendor) || true)
#RUN  go mod tidy && go mod download && go mod vendor
# Here `-N` will disable optimization and `-l` disable inlining
RUN go build -ldflags=" -s -w -X pipiobjo.com/library/buildinfo.Version=${SERVICE_VERSION}" -mod vendor cmd/main.go \
    && chmod +x ${APP_BUILD_NAME}




FROM build-common as build-release
ARG SERVICE_VERSION

## Build

#RUN (([ ! -d "${APP_PATH}/vendor" ] && go mod tidy && go mod download && go mod vendor) || true)
#RUN  go mod tidy && go mod download && go mod vendor
# Here `-N` will disable optimization and `-l` disable inlining
RUN go build -ldflags=" -s -w -X pipiobjo.com/library/buildinfo.Version=${SERVICE_VERSION}" -mod vendor cmd/main.go \
    && chmod +x ${APP_BUILD_NAME}


# Run Tests in separate layer
FROM build-${build_mode} as test

RUN echo "0" > /EXIT_STATUS_FILE; \
    gotestsum --jsonfile /test-report.json --junitfile /junit-report.xml -- -coverpkg=./... -coverprofile=/coverage.txt -covermode count ./... || echo $? > /EXIT_STATUS_FILE; \
    gocov convert /coverage.txt > /coverage.json; \
    gocov-xml < /coverage.json > /coverage.xml; \
    go tool cover -html /coverage.txt -o /coverage.html; \
    go-test-report -o /test-report.html < /test-report.json


# collect the test-results, everything from this stage is exported to generate test reports
FROM scratch AS test-results
COPY --from=test /EXIT_STATUS_FILE /
COPY --from=test /junit-report.xml /
COPY --from=test /coverage.xml /
COPY --from=test /coverage.html /
COPY --from=test /test-report.html /
COPY --from=test /test-report.json /




FROM scratch AS service-common

ENV APP_BUILD_PATH="/app" \
    APP_BUILD_NAME="main"

WORKDIR ${APP_BUILD_PATH}

COPY --from=base /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=base /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=base /etc/passwd /etc/passwd
COPY --from=base /etc/group /etc/group




## Stage 3
## Assemble final service container from an empty scratch image

FROM service-common AS service-debug

ENV APP_BUILD_PATH="/app" \
    APP_BUILD_NAME="main"

ARG COMPONENT_PATH

COPY --from="base" "/go/bin/dlv" "/app/dlv"
COPY --chown=${USER}:${USER} --from="build-debug" "${APP_BUILD_PATH}/$COMPONENT_PATH/${APP_BUILD_NAME}" "${APP_BUILD_PATH}/"
EXPOSE ${APP_PORT} ${APP_HEALTH_PORT} ${DEBUG_PORT}

USER ${USER}:${USER}

ENV CGO_ENABLED=0

WORKDIR ${APP_BUILD_PATH}
ENTRYPOINT ["/app/dlv", "--continue", "--listen=:5082", "--headless=true", "--api-version=2", "--accept-multiclient", "--check-go-version", "--log", "--allow-non-terminal-interactive", "--log-output=debugger,debuglineerr,gdbwire,lldbout,rpc", "exec", "/app/main"]

FROM service-common AS service-runtime

ENV APP_BUILD_PATH="/app" \
    APP_BUILD_NAME="main"

WORKDIR ${APP_BUILD_PATH}

ARG COMPONENT_PATH

COPY --from="build-runtime" "${APP_BUILD_PATH}/$COMPONENT_PATH/${APP_BUILD_NAME}" "${APP_BUILD_PATH}/"


EXPOSE ${APP_PORT} ${DEBUG_PORT}

USER ${USER}:${USER}
ENTRYPOINT ["/app/main"]


FROM service-common AS service-release


ENV APP_BUILD_PATH="/app" \
    APP_BUILD_NAME="main"

WORKDIR ${APP_BUILD_PATH}

ARG COMPONENT_PATH

COPY --from="build-release" "${APP_BUILD_PATH}/$COMPONENT_PATH/${APP_BUILD_NAME}" "${APP_BUILD_PATH}/"


EXPOSE ${APP_PORT} ${APP_HEALTH_PORT} ${DEBUG_PORT}

USER ${USER}:${USER}

ENTRYPOINT ["/app/main"]


FROM service-${build_mode} as service