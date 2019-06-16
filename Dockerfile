FROM homeassistant/home-assistant

# OpenCV installation to support TensorFlow
RUN apt-get update \
    && apt-get install -y \
        build-essential \
        cmake \
        git \
        wget \
        unzip \
        yasm \
        pkg-config \
        libswscale-dev \
        libtbb2 \
        libtbb-dev \
        libjpeg-dev \
        libpng-dev \
        libtiff-dev \
        libavformat-dev \
        libpq-dev \
        libv4l-dev \
        libhdf5-dev \
        libgstreamer-plugins-base1.0-dev

RUN pip install numpy

# Intel MKL
WORKDIR /usr/src
RUN wget https://github.com/intel/mkl-dnn/archive/v0.19.tar.gz \
&& tar xzvf v0.19.tar.gz
RUN cd mkl-dnn-0.19/scripts \
&& ./prepare_mkl.sh && cd .. \
&& mkdir -p build && cd build && cmake .. \
&& make && make install && rm -rf /usr/src/mkl-dnn-0.19

WORKDIR /
ENV OPENCV_VERSION="4.0.1"
RUN wget https://github.com/opencv/opencv_contrib/archive/${OPENCV_VERSION}.tar.gz \
&& tar xzvf ${OPENCV_VERSION}.tar.gz && rm -rf ${OPENCV_VERSION}.tar.gz

RUN wget https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip \
&& unzip ${OPENCV_VERSION}.zip
RUN mkdir /opencv-${OPENCV_VERSION}/cmake_binary \
&& cd /opencv-${OPENCV_VERSION}/cmake_binary \
&& cmake -DBUILD_TIFF=ON \
  -DBUILD_opencv_java=OFF \
  -DWITH_CUDA=OFF \
  -DWITH_OPENGL=ON \
  -DWITH_OPENCL=ON \
  -DWITH_IPP=ON \
  -DWITH_TBB=ON \
  -DWITH_EIGEN=ON \
  -DWITH_V4L=ON \
  -DWITH_QT=OFF \
  -DWITH_MKL=ON \
  -DMKL_USE_MULTITHREAD=ON \
  -DOPENCV_ENABLE_NONFREE=ON \
  -DENABLE_NEON=OFF \
  -DENABLE_VFPV3=OFF \
  -DOPENCV_EXTRA_MODULES_PATH=/opencv_contrib-${OPENCV_VERSION}/modules \
  -DBUILD_TESTS=OFF \
  -DBUILD_EXAMPLES=OFF \
  -DBUILD_PERF_TESTS=OFF \
  -DCMAKE_BUILD_TYPE=RELEASE \
  -DCMAKE_INSTALL_PREFIX=$(python3.7 -c "import sys; print(sys.prefix)") \
  -DPYTHON_EXECUTABLE=$(which python3.7) \
  -DPYTHON_INCLUDE_DIR=$(python3.7 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") \
  -DPYTHON_PACKAGES_PATH=$(python3.7 -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())") \
  .. \
&& make install \
&& rm /${OPENCV_VERSION}.zip \
&& rm -r /opencv-${OPENCV_VERSION}
RUN ln -s \
  /usr/local/python/cv2/python-3.7/cv2.cpython-37m-x86_64-linux-gnu.so \
  /usr/local/lib/python3.7/site-packages/cv2.so

WORKDIR /usr/src/app
RUN rm -rf /var/lib/apt/lists/*
