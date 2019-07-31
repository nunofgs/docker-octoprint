# Intermediate build container.
FROM python:2.7-alpine3.10 as build

ARG TARGETPLATFORM
ARG VERSION

RUN apk --no-cache add build-base
RUN apk --no-cache add cmake
RUN apk --no-cache add libjpeg-turbo-dev
RUN apk --no-cache add linux-headers
RUN apk --no-cache add openssl
RUN [[ "${TARGETPLATFORM:6}" != "arm64" ]] && apk --no-cache add raspberrypi-dev || true

# Download packages
RUN wget -qO- https://github.com/foosel/OctoPrint/archive/${VERSION}.tar.gz | tar xz
RUN wget -qO- https://github.com/jacksonliam/mjpg-streamer/archive/master.tar.gz | tar xz

# Install mjpg-streamer
WORKDIR /mjpg-streamer-master/mjpg-streamer-experimental
RUN make
RUN make install

# Install OctoPrint
WORKDIR /OctoPrint-${VERSION}
RUN pip install -r requirements.txt
RUN python setup.py install

# Build final image
FROM python:2.7-alpine3.10

COPY --from=build /usr/local/bin /usr/local/bin
COPY --from=build /usr/local/lib /usr/local/lib
COPY --from=build /mjpg-streamer-*/mjpg-streamer-experimental /opt/mjpg-streamer
COPY --from=build /OctoPrint-* /opt/octoprint

RUN apk --no-cache add build-base ffmpeg haproxy libjpeg openssh-client supervisor v4l-utils

VOLUME /data
WORKDIR /data

COPY haproxy.cfg /etc/haproxy/haproxy.cfg
COPY supervisord.conf /etc/supervisor/supervisord.conf
COPY start-mjpg-streamer /usr/local/bin/start-mjpg-streamer

ENV CAMERA_DEV /dev/video0
ENV MJPEG_STREAMER_AUTOSTART true
ENV MJPEG_STREAMER_INPUT -y -n -r 640x480
ENV PIP_USER true
ENV PYTHONUSERBASE /data/plugins

EXPOSE 80

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
