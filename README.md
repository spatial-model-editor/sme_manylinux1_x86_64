# sme_manylinux1_x86_64

Docker container for compiling linux python wheels for [sme](https://pypi.org/project/sme/)

- Available from <https://hub.docker.com/repository/docker/lkeegan/sme_manylinux1_x86_64>

- Used by <https://github.com/lkeegan/spatial-model-editor/blob/master/.travis.yml>

- Based on <https://quay.io/repository/pypa/manylinux1_x86_64>

- Also includes a more modern compiler (gcc 9.2.0)

To update:

```
docker build . -t lkeegan/sme_manylinux1_x86_64:tagname
docker push lkeegan/sme_manylinux1_x86_64:tagname
```

where `tagname` is today's date in the form `YYYY.MM.DD`