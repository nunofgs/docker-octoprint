ARG arch

# Intermediate build container with arm support.
FROM hypriot/qemu-register as qemu
FROM $arch/python:2.7-alpine3.7 as build

COPY --from=qemu /qemu-arm /usr/bin/qemu-arm-static

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

FROM $arch/python:2.7-alpine3.7

COPY --from=build /usr/local/bin /usr/local/bin
COPY --from=build /usr/local/lib /usr/local/lib
COPY --from=build /mjpg-streamer-*/mjpg-streamer-experimental /opt/mjpg-streamer
COPY --from=build /OctoPrint-* /opt/octoprint
COPY --from=qemu /qemu-arm /usr/bin/qemu-arm-static

RUN apk --no-cache add ffmpeg haproxy libjpeg && \
  pip install supervisor

VOLUME /data
WORKDIR /data

EXPOSE 80

COPY haproxy.cfg /etc/haproxy/haproxy.cfg
COPY supervisord.conf /etc/supervisor/supervisord.conf

ENV CAMERA_DEV /dev/video0
ENV STREAMER_FLAGS -y -n

CMD ["/usr/local/bin/python", "/usr/local/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
