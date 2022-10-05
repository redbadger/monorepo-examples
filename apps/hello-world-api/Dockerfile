FROM rust:1.64-buster AS build

RUN apt-get update && apt-get install -y \
  cmake \
  clang \
  pkg-config \
  libssl-dev

WORKDIR /

COPY . .

RUN rustup component add rustfmt && \
  cargo fmt -- --check

RUN \
  cargo build \
  --release && \
  cargo test --release

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FROM debian:buster-slim

RUN apt-get update && apt-get install -y \
  openssl \
  tini \
  ;

RUN useradd svc

COPY --from=build /target/release/hello-world-api /

RUN chown -R svc /hello-world-api
USER svc

ENTRYPOINT ["/usr/bin/tini", "--"]

CMD ["/hello-world-api"]
