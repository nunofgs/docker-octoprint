ARG arch

# Intermediate build container.
FROM python:2.7-alpine3.10 as build

ARG version

RUN apk --no-cache add build-base
RUN apk --no-cache add cmake
RUN apk --no-cache add libjpeg-turbo-dev
RUN apk --no-cache add linux-headers
RUN apk --no-cache add openssl

# Download packages
RUN wget -qO- https://github.com/foosel/OctoPrint/archive/${version}.tar.gz | tar xz
RUN wget -qO- https://github.com/jacksonliam/mjpg-streamer/archive/master.tar.gz | tar xz

# Install mjpg-streamer
WORKDIR /mjpg-streamer-master/mjpg-streamer-experimental
RUN make
RUN make install

# Install OctoPrint
WORKDIR /OctoPrint-${version}
RUN pip install -r requirements.txt
RUN python setup.py install

FROM python:2.7-alpine3.10

COPY --from=build /usr/local/bin /usr/local/bin
COPY --from=build /usr/local/lib /usr/local/lib
COPY --from=build /mjpg-streamer-*/mjpg-streamer-experimental /opt/mjpg-streamer
COPY --from=build /OctoPrint-* /opt/octoprint

RUN apk --no-cache add build-base ffmpeg haproxy libjpeg openssh-client v4l-utils && \
  pip install supervisor

VOLUME /data
WORKDIR /data

COPY haproxy.cfg /etc/haproxy/haproxy.cfg
COPY supervisord.conf /etc/supervisor/supervisord.conf

ENV CAMERA_DEV /dev/video0
ENV MJPEG_STREAMER_AUTOSTART true
ENV PIP_USER true
ENV PYTHONUSERBASE /data/plugins
ENV STREAMER_FLAGS -y -n -r 640x480

EXPOSE 80

CMD ["/usr/local/bin/python", "/usr/local/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
