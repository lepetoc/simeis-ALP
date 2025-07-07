FROM debian:bookworm-slim
WORKDIR /tmp

#Copy the deb file from host to image context
COPY target/release ./

EXPOSE 8080

CMD ["simeis-server"]