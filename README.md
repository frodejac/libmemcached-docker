# libmemcached-docker
Containerized https://github.com/awesomized/libmemcached binaries. I had a need to run memaslap to from inside a Kubernetes cluster to do some load testing, so I made this Docker image.

Available on Docker Hub:
```
docker pull frodejacobsen/libmemcached-awesome
```

To see what binaries are available, run:
```bash
docker run --platform linux/amd64 --rm frodejacobsen/libmemcached-awesome ls /usr/local/bin
```
