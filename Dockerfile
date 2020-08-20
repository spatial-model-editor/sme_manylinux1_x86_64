# manylinux1-based image for compiling Spatial Model Editor python wheels

FROM quay.io/pypa/manylinux1_x86_64:2020-08-12-ebd07dd as builder
MAINTAINER Liam Keegan "liam@keegan.ch"

ARG NPROCS=24
ARG BUILD_DIR=/opt/smelibs
ARG TMP_DIR=/opt/tmpwd

RUN yum install -q -y \
    flex \
    subversion \
    wget

RUN git clone -b releases/gcc-9.2.0 --depth=1 https://github.com/gcc-mirror/gcc.git \
    && cd gcc \
    && ./contrib/download_prerequisites

RUN mkdir -p $TMP_DIR && cd $TMP_DIR \
    && /gcc/configure \
        --prefix=/opt/gcc9 \
        --enable-languages=c++,fortran \
        --disable-multilib \
        --disable-gcov \
        --disable-libsanitizer \
        --disable-libquadmath \
        --disable-libquadmath-support \
        --enable-checking=release \
    && make -j$NPROCS \
    && make install-strip \
    && rm -rf $TMP_DIR

RUN /opt/python/cp38-cp38/bin/pip install \
    cmake==3.13.2.post1 \
    &&  ln -fs /opt/python/cp38-cp38/bin/cmake /usr/bin/cmake

ARG GMP_VERSION="6.1.2"
RUN export PATH=/opt/gcc9/bin:$PATH \
    && export LD_LIBRARY_PATH=/opt/gcc9/lib64:/opt/gcc9/lib:$LD_LIBRARY_PATH \
    && export CC=/opt/gcc9/bin/gcc \
    && export CXX=/opt/gcc9/bin/g++ \
    && echo $PATH \
    && gcc --version \
    && g++ --version \
    && mkdir -p $TMP_DIR && cd $TMP_DIR \
    && curl \
        https://gmplib.org/download/gmp/gmp-${GMP_VERSION}.tar.bz2 \
        --output gmp.tar.bz2 \
    && tar xjf gmp.tar.bz2 \
    && cd gmp-${GMP_VERSION} \
    && ./configure \
        --prefix=$BUILD_DIR \
        --disable-shared \
        --disable-assembly \
        --enable-static \
        --with-pic \
        --enable-cxx \
    && make -j$NPROCS \
    && make check \
    && make install \
    && rm -rf $TMP_DIR

ARG LIBEXPAT_VERSION="R_2_2_9"
RUN export PATH=/opt/gcc9/bin:$PATH \
    && export LD_LIBRARY_PATH=/opt/gcc9/lib64:/opt/gcc9/lib:$LD_LIBRARY_PATH \
    && export CC=/opt/gcc9/bin/gcc \
    && export CXX=/opt/gcc9/bin/g++ \
    && echo $PATH \
    && gcc --version \
    && g++ --version \
    && mkdir -p $TMP_DIR && cd $TMP_DIR \
    && git clone \
        -b $LIBEXPAT_VERSION \
        --depth=1 \
        https://github.com/libexpat/libexpat.git \
    && cd libexpat \
    && mkdir build \
    && cd build \
    && cmake \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=OFF \
        -DCMAKE_C_FLAGS="-fpic -fvisibility=hidden" \
        -DCMAKE_CXX_FLAGS="-fpic -fvisibility=hidden" \
        -DCMAKE_INSTALL_PREFIX=$BUILD_DIR \
        -DEXPAT_BUILD_DOCS=OFF \
        -DEXPAT_BUILD_EXAMPLES=OFF \
        -DEXPAT_BUILD_TOOLS=OFF \
        -DEXPAT_SHARED_LIBS=OFF \
        ../expat \
    && make -j$NPROCS \
    && make test \
    && make install \
    && rm -rf $TMP_DIR

ARG LIBTIFF_VERSION="v4.0.10"
RUN export PATH=/opt/gcc9/bin:$PATH \
    && export LD_LIBRARY_PATH=/opt/gcc9/lib64:/opt/gcc9/lib:$LD_LIBRARY_PATH \
    && export CC=/opt/gcc9/bin/gcc \
    && export CXX=/opt/gcc9/bin/g++ \
    && echo $PATH \
    && gcc --version \
    && g++ --version \
    && mkdir -p $TMP_DIR && cd $TMP_DIR \
    && git clone \
        -b $LIBTIFF_VERSION \
        --depth=1 \
        https://gitlab.com/libtiff/libtiff.git \
    && cd libtiff \
    && mkdir cmake-build \
    && cd cmake-build \
    && cmake \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=OFF \
        -DCMAKE_C_FLAGS="-fpic -fvisibility=hidden" \
        -DCMAKE_CXX_FLAGS="-fpic -fvisibility=hidden" \
        -DCMAKE_INSTALL_PREFIX=$BUILD_DIR \
        -Djpeg=OFF \
        -Djpeg12=OFF \
        -Djbig=OFF \
        -Dlzma=OFF \
        -Dpixarlog=OFF \
        -Dold-jpeg=OFF \
        -Dzstd=OFF \
        -Dmdi=OFF \
        -Dwebp=OFF \
        -Dzlib=OFF \
        .. \
    && make -j$NPROCS \
    && make test \
    && make install \
    && rm -rf $TMP_DIR

ARG LLVM_VERSION="10.0.1"
RUN export PATH=/opt/gcc9/bin:$PATH \
    && export LD_LIBRARY_PATH=/opt/gcc9/lib64:/opt/gcc9/lib:$LD_LIBRARY_PATH \
    && export CC=/opt/gcc9/bin/gcc \
    && export CXX=/opt/gcc9/bin/g++ \
    && echo $PATH \
    && gcc --version \
    && g++ --version \
    && mkdir -p $TMP_DIR && cd $TMP_DIR \
    && git clone \
        -b llvmorg-$LLVM_VERSION \
        --depth=1 \
        https://github.com/llvm/llvm-project.git \
    && cd llvm-project/llvm \
    && mkdir build \
    && cd build \
    && cmake \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=$BUILD_DIR \
        -DPYTHON_EXECUTABLE:FILEPATH=/opt/python/cp38-cp38/bin/python \
        -DLLVM_DEFAULT_TARGET_TRIPLE=x86_64-unknown-linux-gnu \
        -DLLVM_TARGETS_TO_BUILD="X86" \
        -DLLVM_BUILD_TOOLS=OFF \
        -DLLVM_INCLUDE_TOOLS=OFF \
        -DLLVM_BUILD_EXAMPLES=OFF \
        -DLLVM_INCLUDE_EXAMPLES=OFF \
        -DLLVM_BUILD_TESTS=OFF \
        -DLLVM_INCLUDE_TESTS=OFF \
        -DLLVM_INCLUDE_DOCS=OFF \
        -DLLVM_BUILD_UTILS=OFF \
        -DLLVM_INCLUDE_UTILS=OFF \
        -DLLVM_INCLUDE_GO_TESTS=OFF \
        -DLLVM_BUILD_BENCHMARKS=OFF \
        -DLLVM_INCLUDE_BENCHMARKS=OFF \
        -DLLVM_ENABLE_LIBPFM=OFF \
        -DLLVM_ENABLE_ZLIB=OFF \
        -DLLVM_ENABLE_DIA_SDK=OFF \
        -DLLVM_BUILD_INSTRUMENTED_COVERAGE=OFF \
        -DLLVM_ENABLE_BINDINGS=OFF \
        -DLLVM_ENABLE_RTTI=ON \
        -DLLVM_ENABLE_TERMINFO=OFF \
        -DLLVM_ENABLE_LIBXML2=OFF \
        -DLLVM_ENABLE_WARNINGS=OFF \
        .. \
    && make -j$NPROCS \
    && make install \
    && rm -rf $TMP_DIR

ARG TBB_VERSION="v2020.3"
RUN export PATH=/opt/gcc9/bin:$PATH \
    && export LD_LIBRARY_PATH=/opt/gcc9/lib64:/opt/gcc9/lib:$LD_LIBRARY_PATH \
    && export CC=/opt/gcc9/bin/gcc \
    && export CXX=/opt/gcc9/bin/g++ \
    && echo $PATH \
    && gcc --version \
    && g++ --version \
    && mkdir -p $TMP_DIR && cd $TMP_DIR \
    && git clone \
        -b $TBB_VERSION \
        --depth=1 \
        https://github.com/intel/tbb.git \
    && cd tbb \
    && make tbb \
        stdver=c++17 \
        extra_inc=big_iron.inc \
        -j$NPROCS \
    && mkdir -p $BUILD_DIR/lib \
    && cp build/*_release/*.a $BUILD_DIR/lib \
    && mkdir -p $BUILD_DIR/include \
    && cp -r include/tbb $BUILD_DIR/include/. \
    && rm -rf $TMP_DIR

ARG MUPARSER_VERSION="v2.2.6.1"
RUN export PATH=/opt/gcc9/bin:$PATH \
    && export LD_LIBRARY_PATH=/opt/gcc9/lib64:/opt/gcc9/lib:$LD_LIBRARY_PATH \
    && export CC=/opt/gcc9/bin/gcc \
    && export CXX=/opt/gcc9/bin/g++ \
    && echo $PATH \
    && gcc --version \
    && g++ --version \
    && mkdir -p $TMP_DIR && cd $TMP_DIR \
    && git clone \
        -b $MUPARSER_VERSION \
        --depth=1 \
        https://github.com/beltoforion/muparser.git \
    && cd muparser \
    && mkdir cmake-build \
    && cd cmake-build \
    && cmake \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=OFF \
        -DCMAKE_C_FLAGS="-fpic -fvisibility=hidden" \
        -DCMAKE_CXX_FLAGS="-fpic -fvisibility=hidden" \
        -DCMAKE_INSTALL_PREFIX=$BUILD_DIR \
        -DBUILD_TESTING=ON \
        -DENABLE_OPENMP=OFF \
        -DENABLE_SAMPLES=OFF \
        .. \
    && make -j$NPROCS \
    && make test \
    && make install \
    && rm -rf $TMP_DIR

ARG QT5_VERSION="v5.15.0"
RUN mkdir -p $TMP_DIR && cd $TMP_DIR \
    && git clone \
        https://code.qt.io/qt/qt5.git \
    && cd qt5 \
    && git checkout $QT5_VERSION \
    && git submodule update --init qtbase

# https://kate-editor.org/2014/12/22/qt-5-4-on-red-hat-enterprise-5/
RUN sed -i "s/#define QTESTLIB_USE_PERF_EVENTS/#undef QTESTLIB_USE_PERF_EVENTS/g" $TMP_DIR/qt5/qtbase/src/testlib/qbenchmark_p.h \
    && cat $TMP_DIR/qt5/qtbase/src/testlib/qbenchmark_p.h

RUN export PATH=/opt/gcc9/bin:$PATH \
    && export LD_LIBRARY_PATH=/opt/gcc9/lib64:/opt/gcc9/lib:$LD_LIBRARY_PATH \
    && export CC=/opt/gcc9/bin/gcc \
    && export CXX=/opt/gcc9/bin/g++ \
    && echo $PATH \
    && gcc --version \
    && g++ --version \
    && mkdir -p $TMP_DIR/build && cd $TMP_DIR/build \
    && ../qt5/qtbase/configure \
        -opensource \
        -confirm-license \
        -prefix $BUILD_DIR \
        -release \
        -static \
        -silent \
        -no-xcb \
        -sql-sqlite \
        -qt-zlib \
        -qt-libjpeg \
        -qt-libpng \
        -qt-pcre \
        -qt-harfbuzz \
        -no-zstd \
        -no-compile-examples \
        -nomake tests \
        -nomake examples \
        -no-opengl \
        -no-openssl \
        -no-sql-odbc \
        -no-icu \
        -no-feature-concurrent \
        -no-feature-xml \
        -feature-testlib \
    && make -j$NPROCS \
    && make install \
    && rm -rf $TMP_DIR

ARG FMT_VERSION="7.0.3"
RUN export PATH=/opt/gcc9/bin:$PATH \
    && export LD_LIBRARY_PATH=/opt/gcc9/lib64:/opt/gcc9/lib:$LD_LIBRARY_PATH \
    && export CC=/opt/gcc9/bin/gcc \
    && export CXX=/opt/gcc9/bin/g++ \
    && echo $PATH \
    && gcc --version \
    && g++ --version \
    && mkdir -p $TMP_DIR/build && cd $TMP_DIR/build \
    && git clone \
        -b $FMT_VERSION \
        --depth=1 \
        https://github.com/fmtlib/fmt.git \
    && cd fmt \
    && mkdir build \
    && cd build \
    && cmake \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=OFF \
        -DCMAKE_C_FLAGS="-fpic -fvisibility=hidden" \
        -DCMAKE_CXX_FLAGS="-fpic -fvisibility=hidden" \
        -DCMAKE_INSTALL_PREFIX=$BUILD_DIR \
        -DCMAKE_CXX_STANDARD=17 \
        -DFMT_DOC=OFF \
        .. \
    && make -j$NPROCS \
    && make test \
    && make install \
    && rm -rf $TMP_DIR

ARG SPDLOG_VERSION="v1.7.0"
RUN export PATH=/opt/gcc9/bin:$PATH \
    && export LD_LIBRARY_PATH=/opt/gcc9/lib64:/opt/gcc9/lib:$LD_LIBRARY_PATH \
    && export CC=/opt/gcc9/bin/gcc \
    && export CXX=/opt/gcc9/bin/g++ \
    && echo $PATH \
    && gcc --version \
    && g++ --version \
    && mkdir -p $TMP_DIR/build && cd $TMP_DIR/build \
    && git clone \
        -b $SPDLOG_VERSION \
        --depth=1 \
        https://github.com/gabime/spdlog.git \
    && cd spdlog \
    && mkdir cmake-build \
    && cd cmake-build \
    && cmake \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=OFF \
        -DCMAKE_C_FLAGS="-fpic -fvisibility=hidden" \
        -DCMAKE_CXX_FLAGS="-fpic -fvisibility=hidden" \
        -DCMAKE_INSTALL_PREFIX=$BUILD_DIR \
        -DSPDLOG_BUILD_TESTS=ON \
        -DSPDLOG_BUILD_EXAMPLE=OFF \
        -DSPDLOG_FMT_EXTERNAL=ON \
        -DSPDLOG_NO_THREAD_ID=ON \
        -DSPDLOG_NO_ATOMIC_LEVELS=ON \
        -DCMAKE_PREFIX_PATH=$BUILD_DIR \
        .. \
    && make -j$NPROCS \
    && make test \
    && make install \
    && rm -rf $TMP_DIR

ARG SYMENGINE_VERSION="v0.6.0"
RUN export PATH=/opt/gcc9/bin:$PATH \
    && export LD_LIBRARY_PATH=/opt/gcc9/lib64:/opt/gcc9/lib:$LD_LIBRARY_PATH \
    && export CC=/opt/gcc9/bin/gcc \
    && export CXX=/opt/gcc9/bin/g++ \
    && echo $PATH \
    && gcc --version \
    && g++ --version \
    && mkdir -p $TMP_DIR/build && cd $TMP_DIR/build \
    && git clone \
        -b $SYMENGINE_VERSION \
        --depth=1 \
        https://github.com/symengine/symengine.git \
    && cd symengine \
    && mkdir build \
    && cd build \
    && cmake \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=OFF \
        -DCMAKE_C_FLAGS="-fpic -fvisibility=hidden" \
        -DCMAKE_CXX_FLAGS="-fpic -fvisibility=hidden" \
        -DCMAKE_INSTALL_PREFIX=$BUILD_DIR \
        -DBUILD_BENCHMARKS=OFF \
        -DGMP_INCLUDE_DIR=$BUILD_DIR/include \
        -DGMP_LIBRARY=$BUILD_DIR/lib/libgmp.a \
        -DCMAKE_PREFIX_PATH=$BUILD_DIR \
        -DWITH_LLVM=ON \
        -DWITH_COTIRE=OFF \
        -DWITH_SYMENGINE_THREAD_SAFE=OFF \
        -DWITH_CPP14=ON \
        .. \
    && make -j$NPROCS \
    && make test \
    && make install \
    && rm -rf $TMP_DIR

ARG DUNE_COPASI_VERSION="allow_no_vtk_output"
RUN export PATH=/opt/gcc9/bin:$PATH \
    && export LD_LIBRARY_PATH=/opt/gcc9/lib64:/opt/gcc9/lib:$LD_LIBRARY_PATH \
    && export CC=/opt/gcc9/bin/gcc \
    && export CXX=/opt/gcc9/bin/g++ \
    && echo $PATH \
    && gcc --version \
    && g++ --version \
    && mkdir -p $TMP_DIR/build && cd $TMP_DIR/build \
    && echo 'CMAKE_FLAGS=" -G '"'"'Unix Makefiles'"'"'"' > opts.txt \
    && echo 'CMAKE_FLAGS+=" -DCMAKE_CXX_STANDARD=17 "' >> opts.txt \
    && echo 'CMAKE_FLAGS+=" -DCMAKE_BUILD_TYPE=Release "' >> opts.txt \
    && echo 'CMAKE_FLAGS+=" -DCMAKE_INSTALL_PREFIX='"$BUILD_DIR"' "' >> opts.txt \
    && echo 'CMAKE_FLAGS+=" -DGMPXX_INCLUDE_DIR:PATH='"$BUILD_DIR"'/include "' >> opts.txt \
    && echo 'CMAKE_FLAGS+=" -DGMPXX_LIB:FILEPATH='"$BUILD_DIR"'/lib/libgmpxx.a "' >> opts.txt \
    && echo 'CMAKE_FLAGS+=" -DGMP_LIB:FILEPATH='"$BUILD_DIR"'/lib/libgmp.a "' >> opts.txt \
    && echo 'CMAKE_FLAGS+=" -DCMAKE_PREFIX_PATH='"$BUILD_DIR"' "' >> opts.txt \
    && echo 'CMAKE_FLAGS+=" -Dfmt_ROOT='"$BUILD_DIR"' "' >> opts.txt \
    && echo 'CMAKE_FLAGS+=" -DDUNE_PYTHON_VIRTUALENV_SETUP=0 -DDUNE_PYTHON_ALLOW_GET_PIP=0 "' >> opts.txt \
    && echo 'CMAKE_FLAGS+=" -DCMAKE_DISABLE_FIND_PACKAGE_QuadMath=TRUE -DBUILD_TESTING=OFF "' >> opts.txt \
    && echo 'CMAKE_FLAGS+=" -DDUNE_USE_ONLY_STATIC_LIBS=ON -DF77=true"' >> opts.txt \
    && echo 'CMAKE_FLAGS+=" -DDUNE_COPASI_SD_EXECUTABLE=ON"' >> opts.txt \
    && echo 'CMAKE_FLAGS+=" -DDUNE_COPASI_MD_EXECUTABLE=ON"' >> opts.txt \
    && echo 'CMAKE_FLAGS+=" -DCMAKE_CXX_FLAGS='"'"'-fvisibility=hidden -fpic -static-libstdc++'"'"' "' >> opts.txt \
    && echo 'MAKE_FLAGS="-j4 VERBOSE=1"' >> opts.txt \
    && export DUNE_OPTIONS_FILE="opts.txt" \
    && export DUNECONTROL=./dune-common/bin/dunecontrol \
    && git clone \
        -b ${DUNE_COPASI_VERSION}  \
        --depth 1 \
        --recursive \
        https://gitlab.dune-project.org/copasi/dune-copasi.git \
    && bash dune-copasi/.ci/setup.sh \
    && rm -rf dune-testtools \
    && bash dune-copasi/.ci/build.sh \
    && $DUNECONTROL make install \
    && rm -rf $TMP_DIR

ARG LIBSBML_VERSION="development"
RUN export PATH=/opt/gcc9/bin:$PATH \
    && export LD_LIBRARY_PATH=/opt/gcc9/lib64:/opt/gcc9/lib:$LD_LIBRARY_PATH \
    && export CC=/opt/gcc9/bin/gcc \
    && export CXX=/opt/gcc9/bin/g++ \
    && echo $PATH \
    && gcc --version \
    && g++ --version \
    && mkdir -p $TMP_DIR/build && cd $TMP_DIR/build \
    && git clone \
        -b $LIBSBML_VERSION \
        --depth=1 \
        https://github.com/sbmlteam/libsbml.git \
    && cd libsbml \
    && mkdir build \
    && cd build \
    && cmake \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=OFF \
        -DCMAKE_C_FLAGS="-fpic -fvisibility=hidden" \
        -DCMAKE_CXX_FLAGS="-fpic -fvisibility=hidden" \
        -DCMAKE_INSTALL_PREFIX=$BUILD_DIR \
        -DENABLE_SPATIAL=ON \
        -DWITH_CPP_NAMESPACE=ON \
        -DLIBSBML_SKIP_SHARED_LIBRARY=ON \
        -DWITH_BZIP2=OFF \
        -DWITH_ZLIB=OFF \
        -DWITH_SWIG=OFF \
        -DWITH_LIBXML=OFF \
        -DWITH_EXPAT=ON \
        -DLIBEXPAT_INCLUDE_DIR=$BUILD_DIR/include \
        -DLIBEXPAT_LIBRARY=$BUILD_DIR/lib64/libexpat.a \
        .. \
    && make -j$NPROCS \
    && make install \
    && rm -rf $TMP_DIR

ARG OPENCV_VERSION="4.4.0"
RUN mkdir -p $TMP_DIR/build && cd $TMP_DIR/build \
    && git clone \
        -b $OPENCV_VERSION \
        --depth=1 \
        https://github.com/opencv/opencv.git

# patch for "‘CPU_COUNT’ was not declared in this scope" compilation error
RUN sed -i "s/CPU_COUNT(\&cpu_set)/1/g" $TMP_DIR/build/opencv/modules/core/src/parallel.cpp \
    && cat $TMP_DIR/build/opencv/modules/core/src/parallel.cpp

RUN export PATH=/opt/gcc9/bin:$PATH \
    && export LD_LIBRARY_PATH=/opt/gcc9/lib64:/opt/gcc9/lib:$LD_LIBRARY_PATH \
    && export CC=/opt/gcc9/bin/gcc \
    && export CXX=/opt/gcc9/bin/g++ \
    && echo $PATH \
    && gcc --version \
    && g++ --version \
    && cd $TMP_DIR/build/opencv \
    && mkdir build \
    && cd build \
    && cmake \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=OFF \
        -DCMAKE_C_FLAGS="-fpic -fvisibility=hidden" \
        -DCMAKE_CXX_FLAGS="-fpic -fvisibility=hidden" \
        -DCMAKE_INSTALL_PREFIX=$BUILD_DIR \
        -DCPU_DISPATCH="SSE4_1;SSE4_2;AVX;FP16;AVX2" \
        -DBUILD_opencv_apps=OFF \
        -DBUILD_opencv_calib3d=OFF \
        -DBUILD_opencv_core=ON \
        -DBUILD_opencv_dnn=OFF \
        -DBUILD_opencv_features2d=OFF \
        -DBUILD_opencv_flann=OFF \
        -DBUILD_opencv_gapi=OFF \
        -DBUILD_opencv_highgui=OFF \
        -DBUILD_opencv_imgcodecs=OFF \
        -DBUILD_opencv_imgproc=ON \
        -DBUILD_opencv_java_bindings_generator=OFF \
        -DBUILD_opencv_js=OFF \
        -DBUILD_opencv_ml=OFF \
        -DBUILD_opencv_objdetect=OFF \
        -DBUILD_opencv_photo=OFF \
        -DBUILD_opencv_python_bindings_generator=OFF \
        -DBUILD_opencv_python_tests=OFF \
        -DBUILD_opencv_stitching=OFF \
        -DBUILD_opencv_ts=OFF \
        -DBUILD_opencv_video=OFF \
        -DBUILD_opencv_videoio=OFF \
        -DBUILD_opencv_world=OFF \
        -DBUILD_CUDA_STUBS:BOOL=OFF \
        -DBUILD_DOCS:BOOL=OFF \
        -DBUILD_EXAMPLES:BOOL=OFF \
        -DBUILD_FAT_JAVA_LIB:BOOL=OFF \
        -DBUILD_IPP_IW:BOOL=OFF \
        -DBUILD_ITT:BOOL=OFF \
        -DBUILD_JASPER:BOOL=OFF \
        -DBUILD_JAVA:BOOL=OFF \
        -DBUILD_JPEG:BOOL=OFF \
        -DBUILD_OPENEXR:BOOL=OFF \
        -DBUILD_PACKAGE:BOOL=OFF \
        -DBUILD_PERF_TESTS:BOOL=OFF \
        -DBUILD_PNG:BOOL=OFF \
        -DBUILD_PROTOBUF:BOOL=OFF \
        -DBUILD_SHARED_LIBS:BOOL=OFF \
        -DBUILD_TBB:BOOL=OFF \
        -DBUILD_TESTS:BOOL=OFF \
        -DBUILD_TIFF:BOOL=OFF \
        -DBUILD_USE_SYMLINKS:BOOL=OFF \
        -DBUILD_WEBP:BOOL=OFF \
        -DBUILD_WITH_DEBUG_INFO:BOOL=OFF \
        -DBUILD_WITH_DYNAMIC_IPP:BOOL=OFF \
        -DBUILD_ZLIB:BOOL=ON \
        -DWITH_1394:BOOL=OFF \
        -DWITH_ADE:BOOL=OFF \
        -DWITH_ARAVIS:BOOL=OFF \
        -DWITH_CLP:BOOL=OFF \
        -DWITH_CUDA:BOOL=OFF \
        -DWITH_EIGEN:BOOL=OFF \
        -DWITH_FFMPEG:BOOL=OFF \
        -DWITH_FREETYPE:BOOL=OFF \
        -DWITH_GDAL:BOOL=OFF \
        -DWITH_GDCM:BOOL=OFF \
        -DWITH_GPHOTO2:BOOL=OFF \
        -DWITH_GSTREAMER:BOOL=OFF \
        -DWITH_GTK:BOOL=OFF \
        -DWITH_GTK_2_X:BOOL=OFF \
        -DWITH_HALIDE:BOOL=OFF \
        -DWITH_HPX:BOOL=OFF \
        -DWITH_IMGCODEC_HDR:BOOL=OFF \
        -DWITH_IMGCODEC_PFM:BOOL=OFF \
        -DWITH_IMGCODEC_PXM:BOOL=OFF \
        -DWITH_IMGCODEC_SUNRASTER:BOOL=OFF \
        -DWITH_INF_ENGINE:BOOL=OFF \
        -DWITH_IPP:BOOL=OFF \
        -DWITH_ITT:BOOL=OFF \
        -DWITH_JASPER:BOOL=OFF \
        -DWITH_JPEG:BOOL=OFF \
        -DWITH_LAPACK:BOOL=OFF \
        -DWITH_LIBREALSENSE:BOOL=OFF \
        -DWITH_MFX:BOOL=OFF \
        -DWITH_NGRAPH:BOOL=OFF \
        -DWITH_OPENCL:BOOL=OFF \
        -DWITH_OPENCLAMDBLAS:BOOL=OFF \
        -DWITH_OPENCLAMDFFT:BOOL=OFF \
        -DWITH_OPENCL_SVM:BOOL=OFF \
        -DWITH_OPENEXR:BOOL=OFF \
        -DWITH_OPENGL:BOOL=OFF \
        -DWITH_OPENJPEG:BOOL=OFF \
        -DWITH_OPENMP:BOOL=OFF \
        -DWITH_OPENNI:BOOL=OFF \
        -DWITH_OPENNI2:BOOL=OFF \
        -DWITH_OPENVX:BOOL=OFF \
        -DWITH_PLAIDML:BOOL=OFF \
        -DWITH_PNG:BOOL=OFF \
        -DWITH_PROTOBUF:BOOL=OFF \
        -DWITH_PTHREADS_PF:BOOL=OFF \
        -DWITH_PVAPI:BOOL=OFF \
        -DWITH_QT:BOOL=OFF \
        -DWITH_QUIRC:BOOL=OFF \
        -DWITH_TBB:BOOL=OFF \
        -DWITH_TIFF:BOOL=OFF \
        -DWITH_V4L:BOOL=OFF \
        -DWITH_VA:BOOL=OFF \
        -DWITH_VA_INTEL:BOOL=OFF \
        -DWITH_VTK:BOOL=OFF \
        -DWITH_VULKAN:BOOL=OFF \
        -DWITH_WEBP:BOOL=OFF \
        -DWITH_XIMEA:BOOL=OFF \
        -DWITH_XINE:BOOL=OFF \
        .. \
    && make -j$NPROCS \
    && make install \
    && rm -rf $TMP_DIR

FROM quay.io/pypa/manylinux1_x86_64:2020-08-12-ebd07dd
MAINTAINER Liam Keegan "liam@keegan.ch"

ARG BUILD_DIR=/opt/smelibs

# GCC 9
COPY --from=builder /opt/gcc9 /opt/gcc9
ENV CMAKE_PREFIX_PATH="$BUILD_DIR;$BUILD_DIR/lib64/cmake"
ENV CC=/opt/gcc9/bin/gcc
ENV CXX=/opt/gcc9/bin/g++
ENV LD_LIBRARY_PATH=/opt/gcc9/lib64:/opt/gcc9/lib:$LD_LIBRARY_PATH

# SME static libs
COPY --from=builder $BUILD_DIR $BUILD_DIR

# Remove Python 3.9 - still in beta
RUN rm -rf /opt/python/cp39-cp39

# Install cmake and ccache
RUN /opt/python/cp38-cp38/bin/pip install \
    cmake==3.13.2.post1 \
    && ln -fs /opt/python/cp38-cp38/bin/cmake /usr/bin/cmake \
    && yum install -q -y \
        ccache

# Setup ccache
ENV CCACHE_BASEDIR=/tmp
ENV CCACHE_DIR=/tmp/ccache
ENV CMAKE_CXX_COMPILER_LAUNCHER=ccache
