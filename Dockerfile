FROM python:2.7-alpine3.7 as build

ENV CURA_ENGINE_VERSION=15.04.6
ENV MJPG_STREAMER_VERSION=master
ENV OCTOPRINT_VERSION=1.3.6

RUN apk --no-cache add build-base
RUN apk --no-cache add cmake
RUN apk --no-cache add libexecinfo-dev
RUN apk --no-cache add libjpeg-turbo-dev
RUN apk --no-cache add linux-headers
RUN apk --no-cache add openssl

# Download packages.
RUN wget -qO- https://github.com/foosel/OctoPrint/archive/${OCTOPRINT_VERSION}.tar.gz | tar xz
RUN wget -qO- https://github.com/jacksonliam/mjpg-streamer/archive/${MJPG_STREAMER_VERSION}.tar.gz | tar xz
RUN wget -qO- https://github.com/Ultimaker/CuraEngine/archive/${CURA_ENGINE_VERSION}.tar.gz | tar xz

# Install CuraEngine.
WORKDIR /CuraEngine-${CURA_ENGINE_VERSION}
RUN mkdir build
RUN make

# Install mjpg-streamer.
WORKDIR /mjpg-streamer-${MJPG_STREAMER_VERSION}/mjpg-streamer-experimental
RUN make
RUN make install

# Install OctoPrint.
WORKDIR /OctoPrint-${OCTOPRINT_VERSION}
RUN pip install -r requirements.txt
RUN python setup.py install

FROM python:2.7-alpine3.7

COPY --from=build /usr/local/bin /usr/local/bin
COPY --from=build /usr/local/lib /usr/local/lib
COPY --from=build /CuraEngine-* /opt/cura-engine
COPY --from=build /mjpg-streamer-*/mjpg-streamer-experimental /opt/mjpg-streamer
COPY --from=build /OctoPrint-* /opt/octoprint

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
