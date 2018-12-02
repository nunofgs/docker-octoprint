ARG arch

# Intermediate build container with arm support.
FROM hypriot/qemu-register as qemu
FROM $arch/python:2.7-slim as build

COPY --from=qemu /qemu-arm /usr/bin/qemu-arm-static

ARG version

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
  avrdude \
  build-essential \
  cmake \
  git \
  haproxy \
  imagemagick \
  libav-tools \
  libjpeg-dev \
  libjpeg62-turbo \
  libprotobuf-dev \
  libv4l-dev \
  psmisc \
  supervisor \
  unzip \
  wget \
  zlib1g-dev

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

VOLUME /data
WORKDIR /data

COPY haproxy.cfg /etc/haproxy/haproxy.cfg
COPY pip.conf /root/.pip/pip.conf
COPY supervisord.conf /etc/supervisor/supervisord.conf

ENV CAMERA_DEV /dev/video0
ENV STREAMER_FLAGS -y -n

EXPOSE 80

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
