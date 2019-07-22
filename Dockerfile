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
  ffmpeg \
  git \
  haproxy \
  imagemagick \
  v4l-utils \
  libjpeg-dev \
  libjpeg62-turbo \
  libprotobuf-dev \
  libv4l-dev \
  openssh-client \
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
COPY supervisord.conf /etc/supervisor/supervisord.conf

ENV CAMERA_DEV /dev/video0
ENV MJPEG_STREAMER_AUTOSTART true
ENV PIP_USER true
ENV PYTHONUSERBASE /data/plugins
ENV STREAMER_FLAGS -y -n -r 640x480

EXPOSE 80

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
