FROM debian:bookworm-slim
WORKDIR /tmp

#Copy the deb file from host to image context
COPY target/release/simeis.deb ./

# Install the application dependencies
RUN apt-get update
RUN apt-get install -y ./simeis.deb
RUN rm ./simeis.deb

EXPOSE 8080

CMD ["simeis-server"]