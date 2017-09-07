# gcloud-conda
# This image provides a dual environment with conda (Python 3) and gcloud installed
# It is ready to be configured for additional application code

FROM alpine:3.5
MAINTAINER Ryan Stauffer <ryan.stauffer@drivenbrands.com>

# Inspired by Dockerfiles
# google/cloud-sdk
# show0k/alpine-miniconda

# gcloud environment
ENV CLOUD_SDK_VERSION 169.0.0
ENV PATH /google-cloud-sdk/bin:$PATH

# Install packages
RUN apk --update --no-cache add \
    curl \
    python \
    py-crcmod \
    bash \
    libc6-compat \
    openssh-client \
    git \
    ca-certificates \
    bzip2 \
    unzip \
	sudo \
    libstdc++ \
    glib \
    libxext \
    libxrender


# Install gcloud
RUN curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-$CLOUD_SDK_VERSION-linux-x86_64.tar.gz && \
    tar xzf google-cloud-sdk-$CLOUD_SDK_VERSION-linux-x86_64.tar.gz && \
    rm google-cloud-sdk-$CLOUD_SDK_VERSION-linux-x86_64.tar.gz && \
    ln -s /lib /lib64 && \
    gcloud config set core/disable_usage_reporting true && \
    gcloud config set component_manager/disable_update_check true && \
    gcloud config set metrics/environment github_docker_image


# Install glibc

RUN curl "https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub" -o /etc/apk/keys/sgerrand.rsa.pub \
    && curl -L "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.23-r3/glibc-2.23-r3.apk" -o glibc.apk \
    && apk add glibc.apk \
    && curl -L "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.23-r3/glibc-bin-2.23-r3.apk" -o glibc-bin.apk \
    && apk add glibc-bin.apk \
    && /usr/glibc-compat/sbin/ldconfig /lib /usr/glibc/usr/lib \
    && rm -rf glibc*apk /var/cache/apk/*


# Configure Miniconda environment
ENV CONDA_DIR /opt/conda
ENV PATH $CONDA_DIR/bin:$PATH
ENV SHELL /bin/bash
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

# Miniconda Version and URIs
ENV MINICONDA_VER 4.3.21
ENV MINICONDA Miniconda3-$MINICONDA_VER-Linux-x86_64.sh
ENV MINICONDA_URI https://repo.continuum.io/miniconda/$MINICONDA
ENV MINICONDA_MD5_SUM c1c15d3baba15bf50293ae963abef853

# Install conda
RUN cd /tmp && \
    mkdir -p $CONDA_DIR && \
    curl -L $MINICONDA_URI  -o miniconda.sh && \
    echo "$MINICONDA_MD5_SUM  miniconda.sh" | md5sum -c - && \
    /bin/bash miniconda.sh -f -b -p $CONDA_DIR && \
    rm miniconda.sh && \
    $CONDA_DIR/bin/conda install --yes conda==$MINICONDA_VER

ENTRYPOINT [ "/bin/bash" ]
