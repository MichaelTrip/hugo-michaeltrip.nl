### If you use this site


## Remove <noscript> and </noscript> tags from public

## How to build images for all archs

first, run the qemu multiarch image

```bash
sudo podman run --rm --privileged docker.io/multiarch/qemu-user-static --reset -p yes
```

after that, run the build

```bash
podman build -f Dockerfile --all-platforms -t michaeltrip/hugo-michaeltrip.nl
```

after that, push


