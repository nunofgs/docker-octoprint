# OctoPrint

[![build status][travis-image]][travis-url]

This is a Dockerfile to set up [OctoPrint](http://octoprint.org/). It supports the following architectures automatically:

- x86
- arm32v6 (Raspberry Pi, etc.)

# Tags

- `1.3.11`, `latest` ([Dockerfile](https://github.com/nunofgs/docker-octoprint/blob/master/Dockerfile))
- `1.3.10` ([Dockerfile](https://github.com/nunofgs/docker-octoprint/blob/master/Dockerfile))
- `1.3.9` ([Dockerfile](https://github.com/nunofgs/docker-octoprint/blob/master/Dockerfile))
- `1.3.8` ([Dockerfile](https://github.com/nunofgs/docker-octoprint/blob/master/Dockerfile))
- `1.3.7` ([Dockerfile](https://github.com/nunofgs/docker-octoprint/blob/master/Dockerfile))
- `1.3.6` ([Dockerfile](https://github.com/nunofgs/docker-octoprint/blob/master/Dockerfile))
- `master` (_Automatically built daily from OctoPrint's `master` branch_)

# Tested devices

| Device              | Working? |
| ------------------- | -------- |
| Raspberry Pi 2b     | ✅        |
| Raspberry Pi 3b+    | ✅        |
| Raspberry Pi Zero W | ❌        |

# Usage

```shell
$ docker run \
  --device=/dev/video0 \
  -p 80:80 \
  -v /mnt/data:/data \
  nunofgs/octoprint
```

# Environment Variables

| Variable                 | Description                    | Default Value      |
| ------------------------ | ------------------------------ | ------------------ |
| CAMERA_DEV               | The camera device node         | `/dev/video0`      |
| MJPEG_STREAMER_AUTOSTART | Start the camera automatically | `true`             |
| STREAMER_FLAGS           | Flags to pass to mjpg_streamer | `-y -n -r 640x480` |

# CuraEngine integration

Cura engine integration was very outdated (using version `15.04.6`) and was removed.

It will return once OctoPrint [supports python3](https://github.com/foosel/OctoPrint/pull/1416#issuecomment-371878648) (needed for the newest versions of cura engine).

# Webcam integration

1. Bind the camera to the docker using --device=/dev/video0:/dev/videoX
2. Optionally, change `STREAMER_FLAGS` to your preferred settings (ex: `-y -n -r 1280x720 -f 10`)
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
