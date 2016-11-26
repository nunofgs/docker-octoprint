FROM armhf/python:2.7-slim

ENV OCTOPRINT_VERSION=1.3.1
ENV CURA_ENGINE_VERSION=15.04.6

RUN set -xe \
	&& echo "Setup Temporary packages for compilation" \
	&& export PKGS='build-essential subversion libjpeg-dev zlib1g-dev libv4l-dev wget unzip git' \
	&& echo "Installing Dependencies" \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends libprotobuf9 libav-tools avrdude libjpeg62-turbo curl imagemagick psmisc haproxy supervisor \
	&& apt-get install -y ${PKGS} --no-install-recommends \
	&& echo "Download OctoPrint/CuraEngine/mjpg-streamer" \
	&& cd /tmp/ \
	&& wget https://github.com/foosel/OctoPrint/archive/${OCTOPRINT_VERSION}.tar.gz \
	&& wget https://github.com/Ultimaker/CuraEngine/archive/${CURA_ENGINE_VERSION}.tar.gz \
	&& wget http://sourceforge.net/code-snapshots/svn/m/mj/mjpg-streamer/code/mjpg-streamer-code-182.zip \
	&& echo "Installing mjpg-streamer" \
	&& unzip mjpg-streamer-code-182.zip \
	&& cd mjpg-streamer-code-182/mjpg-streamer \
	&& make \
	&& make install \
	&& cd ../.. \
	&& echo "Installing CuraEngine" \
	&& tar -zxf ${CURA_ENGINE_VERSION}.tar.gz \
	&& cd CuraEngine-${CURA_ENGINE_VERSION} \
	&& mkdir build \
	&& make \
	&& mv -f ./build /CuraEngine/ \
	&& cd .. \
	&& echo "Installing OctoPrint" \
	&& tar -zxf ${OCTOPRINT_VERSION}.tar.gz \
	&& mv -f OctoPrint-${OCTOPRINT_VERSION} /octoprint/ \
	&& cd /octoprint/ \
	&& echo "Install OctoPrint requirements" \
	&& pip install -r requirements.txt \
	&& pip install pillow \
	&& python setup.py install \
	&& echo "Cleaning Temporary Packages + Installation leftovers" \
	&& apt-get purge -y --auto-remove ${PKGS} \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -rf /tmp/* /var/tmp/*

VOLUME /data
WORKDIR /data

EXPOSE 80

COPY haproxy.cfg /etc/haproxy/haproxy.cfg
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

ENV CAMERA_DEV "/dev/video0"
ENV STREAMER_FLAGS "-y -n"

CMD ["/usr/bin/supervisord"]
