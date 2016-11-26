# OctoPrint for Raspberry Pi 2

This is a Dockerfile to set up [OctoPrint](http://octoprint.org/).

# Usage

```shell
$ docker run \
  --device=/dev/video0 \
  -p 80:80 \
  -v /mnt/data:/data \
  nunofgs/rpi-octoprint
```

# CuraEngine integration

CuraEngine is installed under:

```
/CuraEngine/CuraEngine
```

Please set it in the settings menu if you intend to use it.

# Webcam integration

1. Bind the camera to the docker using --device=/dev/video0:/dev/videoX
2. If camera supports only MJPEG formatting, please set STREAMER_FLAGS to "" or something else.
3. Use the following settings in octoprint:

```yaml
webcam:
  stream: /webcam/?action=stream
  snapshot: http://127.0.0.1:8080/?action=snapshot
  ffmpeg: /usr/bin/avconv
```

# Notes

This image uses `supervisord` in order to launch 3 processes: _haproxy_, _octoprint_ and _mjpeg-streamer_.

This means you can disable/enable the camera at will from within octoprint by editing your `config.yaml`:

```yaml
system:
  actions:
  - action: streamon
    command: supervisorctl start mjpeg-streamer
    confirm: false
    name: Start webcam
  - action: streamoff
    command: supervisorctl stop mjpeg-streamer
    confirm: false
    name: Stop webcam
```

# Credits

All credits go to https://bitbucket.org/a2z-team/docker-octoprint. I simply ported this to the raspberry pi 2.
