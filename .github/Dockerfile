FROM debian:bookworm-slim
WORKDIR /tmp

#Waiting for the .deb to be compiled and copy it
COPY target/release ./
# Install the application dependencies
RUN dpkg -i ./simeis.deb && \
    rm simeis.deb

EXPOSE 8080

CMD ["simeis-server"]
