FROM rust:1.84 AS builder
WORKDIR /usr/src/web_server
COPY . .
RUN cargo install --path . --release

FROM debian:bullseye-slim
RUN apt-get update && apt-get install -y && rm -rf /var/lib/apt/lists/*
COPY --from=builder /usr/local/cargo/bin/web_server /usr/local/bin/web_server
EXPOSE 8000
CMD ["web_server"]

