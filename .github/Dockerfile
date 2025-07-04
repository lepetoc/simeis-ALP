FROM debian:bookworm-slim
WORKDIR /tmp

# Install the application dependencies
RUN curl https://github.com/lepetoc/simeis-ALP/releases/download/vchangelog-real/simeis-server_V0.deb -o simeis.deb
RUN apt install simeis.deb

EXPOSE 8080

# RUN useradd app
# USER app

CMD ["simeis"]