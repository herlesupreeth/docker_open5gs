# Build Open Exposure separately from the Open5GS image.
FROM golang:1.23.10-bookworm AS builder

ARG NEF_REVISION=ae60c8db252bd4ddc429f7ff73cc5ad2cbb1a532
RUN git clone https://gitlab.eurecom.fr/open-exposure/nef/as-session-with-qos.git /src && \
    cd /src && git checkout "${NEF_REVISION}"
WORKDIR /src
RUN go mod download && \
    CGO_ENABLED=0 go build -mod=readonly \
      -ldflags "-X main.gitCommit=${NEF_REVISION}" \
      -o /as-sess-qos ./cmd/as-session-with-qos

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates gettext-base netcat-openbsd && \
    rm -rf /var/lib/apt/lists/*
COPY --from=builder /as-sess-qos /as-sess-qos
COPY --from=builder /src/LICENSE /usr/share/doc/open-exposure-nef/LICENSE
COPY openexposure_nef_init.sh /openexposure_nef_init.sh
EXPOSE 8080/tcp
CMD ["/openexposure_nef_init.sh"]
