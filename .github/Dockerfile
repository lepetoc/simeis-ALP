FROM debian:bookworm-slim
WORKDIR /tmp

# Install the application dependencies
RUN apt update && \
    apt-get install -y curl && \
    curl -L https://github.com/lepetoc/simeis-ALP/releases/download/vchangelog-real/simeis-server_V0.deb -o simeis.deb && \
    dpkg -i ./simeis.deb && \
    rm simeis.deb && \
    apt-get remove -y curl && \
    apt-get autoremove -y && \
    apt-get clean

EXPOSE 8080

CMD ["simeis-server"]