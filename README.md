# OctoPrint

[![build status][travis-image]][travis-url]

This is a Dockerfile to set up [OctoPrint](http://octoprint.org/). It supports the following architectures automatically:

- x86
- arm32v6 [<sup>1</sup>](#armv6-docker-bug)
- arm32v7
- arm64

Just run:

```sh
docker run nunofgs/octoprint
```

Now have a beer, you did it. 🍻

# Tags

- `1.3.12`, `1.3.12-debian`, `debian`, `latest` ([Dockerfile](https://github.com/nunofgs/docker-octoprint/blob/master/debian/Dockerfile))
- `1.3.12-alpine`, `alpine` ([Dockerfile](https://github.com/nunofgs/docker-octoprint/blob/master/alpine/Dockerfile))
- `1.3.11`, `1.3.11-debian` ([Dockerfile](https://github.com/nunofgs/docker-octoprint/blob/master/debian/Dockerfile))
- `1.3.11-alpine` ([Dockerfile](https://github.com/nunofgs/docker-octoprint/blob/master/alpine/Dockerfile))
- `1.3.10` ([Dockerfile](https://github.com/nunofgs/docker-octoprint/blob/master/debian/Dockerfile))
- `1.3.9` ([Dockerfile](https://github.com/nunofgs/docker-octoprint/blob/master/debian/Dockerfile))
- `1.3.8` ([Dockerfile](https://github.com/nunofgs/docker-octoprint/blob/master/debian/Dockerfile))
- `1.3.7` ([Dockerfile](https://github.com/nunofgs/docker-octoprint/blob/master/debian/Dockerfile))
- `1.3.6` ([Dockerfile](https://github.com/nunofgs/docker-octoprint/blob/master/debian/Dockerfile))
- `master-debian`, `master` (_Automatically built daily from OctoPrint's `master` branch_)
- `master-alpine` (_Automatically built daily from OctoPrint's `master` branch_)

# Tested devices

| Device              | Working? |
| ------------------- | -------- |
| Raspberry Pi 2b     | ✅       |
| Raspberry Pi 3b+    | ✅       |
| Raspberry Pi Zero W | ✅       |

Please let me know if you test any others, would love to increase the compatibility list!

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
| MJPEG_STREAMER_INPUT     | Flags to pass to mjpg_streamer | `-y -n -r 640x480` |

# CuraEngine integration

Cura engine integration was very outdated (using version `15.04.6`) and was removed.

It will return once OctoPrint [supports python3](https://github.com/foosel/OctoPrint/pull/1416#issuecomment-371878648) (needed for the newest versions of cura engine).

# Webcam integration

## USB Webcam

1. Bind the camera to the docker using --device=/dev/video0:/dev/videoX
2. Optionally, change `MJPEG_STREAMER_INPUT` to your preferred settings (ex: `input_uvc.so -y -n -r 1280x720 -f 10`)

## Raspberry Pi camera module

1. The camera module must be activated (sudo raspi-config -> interfacing -> Camera -> set it to YES)
2. Memory split must be at least 128mb, 256mb recommended. (sudo raspi-config -> Advanced Options -> Memory Split -> set it to 128 or 256)
3. You must allow access to device: /dev/vchiq
4. Change `MJPEG_STREAMER_INPUT` to use input_raspicam.so (ex: `input_raspicam.so -fps 25`)

<sup>* Raspberry PI camera support is only available in `arm/v6` and `arm/v7` builds at the moment.</sup>

## Octoprint configuration

Use the following settings in octoprint:

```yaml
webcam:
  stream: /webcam/?action=stream
  snapshot: http://127.0.0.1:8080/?action=snapshot
  ffmpeg: /usr/bin/ffmpeg
```

# Notes

## Distro variants

There are currently _alpine_ and _debian_ variants available of this image. At time of writing, here are their sizes:

| Variant         | Size      |
|-----------------|---------- |
| _1.3.11-alpine_ | **474MB** |
| _1.3.11-debian_ | **889MB** |

While SD cards are pretty cheap these days, a smaller image is always preferrable so feel free to submit PRs that reduce the image size without affecting functionality!

## ARMv6 Docker Bug

_ARM32v6_ devices such as the Raspberry Pi Zero (W) are unfortunately unable to pull this image directly using `docker pull nunofgs/octoprint` due to a bug in Docker ([moby/moby#37647](https://github.com/moby/moby/issues/37647), [moby/moby#34875](https://github.com/moby/moby/issues/34875)). There's a [PR open](https://github.com/moby/moby/pull/36121#issuecomment-515243647) to fix this but it might be some time until it hits a stable Docker release.

Until then, you can run this container by specifying the armv6 image hash. Example on [HypriotOS 1.11.0](https://blog.hypriot.com):

```sh
$ docker manifest inspect nunofgs/octoprint | grep -e "variant.*v6" -B 4

# copy sha256 hash of the v6 image you want to run.

$ docker run nunofgs/octoprint@sha256:dce9b67ccd25bb63c3024ab96c55428281d8c3955c95c7b5133807133863da29
```

## Toggle the camera on/off

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
