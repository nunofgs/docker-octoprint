# OctoPrint

[![build status][travis-image]][travis-url]

This is a Dockerfile to set up [OctoPrint](http://octoprint.org/). It supports the following architectures automatically:

- x86
- arm32v6 (Raspberry Pi, etc.)

# Tags

- `1.3.6`, `latest` ([Dockerfile](https://github.com/nunofgs/docker-octoprint/blob/master/Dockerfile))
- `master` (_Automatically built daily from OctoPrint's `master` branch_)

# Usage

```shell
$ docker run \
  --device=/dev/video0 \
  -p 80:80 \
  -v /mnt/data:/data \
  nunofgs/octoprint
```

# CuraEngine integration

Cura engine integration was very outdated (using version `15.04.6`) and was removed.

It will return once OctoPrint [supports python3](https://github.com/foosel/OctoPrint/pull/1416#issuecomment-371878648) (needed for the newest versions of cura engine).

# Webcam integration

1. Bind the camera to the docker using --device=/dev/video0:/dev/videoX
2. If camera supports only MJPEG formatting, please set STREAMER_FLAGS to "" or something else.
3. Use the following settings in octoprint:

```yaml
webcam:
  stream: /webcam/?action=stream
  snapshot: http://127.0.0.1:8080/?action=snapshot
  ffmpeg: /usr/bin/ffmpeg
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

Original credits go to https://bitbucket.org/a2z-team/docker-octoprint. I initially ported this to the raspberry pi 2 and later moved to a multiarch image.

## License

MIT

[travis-image]: https://img.shields.io/travis/nunofgs/docker-octoprint.svg?style=flat-square
[travis-url]: https://travis-ci.org/nunofgs/docker-octoprint
