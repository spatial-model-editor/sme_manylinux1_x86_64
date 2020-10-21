# warning

This repo is no longer in use.

It relied on static linking `libstdc++` to create manylinux1-compatible c++17 wheels.

It turns out that this is a bad idea: https://github.com/spatial-model-editor/spatial-model-editor/issues/333

# ~~sme_manylinux1_x86_64~~

~~Docker container for compiling linux python wheels for [sme](https://pypi.org/project/sme/)~~

~~- Available from <https://hub.docker.com/repository/docker/lkeegan/sme_manylinux1_x86_64>~~

~~- Used by <https://github.com/spatial-model-editor/spatial-model-editor/blob/master/.travis.yml>~~

~~- Based on <https://quay.io/repository/pypa/manylinux1_x86_64>~~

~~- Also includes a more modern compiler (gcc 9.3.0)~~

~~To update:~~

~~docker build . -t lkeegan/sme_manylinux1_x86_64:tagname~~
~~docker push lkeegan/sme_manylinux1_x86_64:tagname~~

~~where `tagname` is today's date in the form `YYYY.MM.DD`~~
