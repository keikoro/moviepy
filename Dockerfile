FROM python:3.8 as base
LABEL description="Run moviepy in a Docker container"
LABEL version="1.0"

# install basic libraries + fonts used for testing
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
 && apt-get -y install --no-install-recommends \
 ffmpeg \
 fonts-liberation \
 imagemagick \
 locales \
 tzdata \
 vim \
 && apt-get clean \
 && apt-get autoremove -y \
 && rm -rf /var/lib/apt/lists/*

# system config
FROM base AS config
ARG DEBIAN_FRONTEND=noninteractive
ARG LOCALE=C.UTF-8
ARG TZ=Etc/UTC
ENV LC_ALL $LOCALE
ENV TZ $TZ
RUN locale-gen $LOCALE \
 && /usr/sbin/update-locale LANG=$LOCALE \
 && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
 && echo $TZ > /etc/timezone

# copy all (not ignored) dirs/files to image + install Python packages
FROM config AS prep_python
ARG APP_DIR_CONTAINER=/usr/src/moviepy/
COPY . $APP_DIR_CONTAINER
WORKDIR $APP_DIR_CONTAINER
RUN pip install .[optional]

# modify ImageMagick root policy file so that TextClip works correctly
RUN sed -i 's/none/read,write/g' /etc/ImageMagick-6/policy.xml

FROM prep_python AS final
