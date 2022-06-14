FROM alpine:3.14.6 as builder

ENV NGINX_VERSION 1.21.4
ENV NGINX_RTMP_VERSION 1.2.2
ENV FFMPEG_VERSION 4.4

# Install Utils
RUN	apk update && \
	apk add	--no-cache \
		git	\
		gcc	\
		binutils \
		gmp	\
		isl	\
		libgomp	\
		libatomic\
		libgcc \
		openssl	\
		pkgconf	\
		pkgconfig \
		mpc1 \
		libstdc++ \
		ca-certificates	\
		libssh2	\
		expat \
		pcre \
		musl-dev \
		libc-dev \
		pcre-dev \
		zlib-dev \
		openssl-dev \
		curl \
		make


RUN	cd /tmp/ &&	\
	curl --remote-name http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && \
	git clone https://github.com/arut/nginx-rtmp-module.git -b v${NGINX_RTMP_VERSION}

RUN	cd /tmp	&& \
	tar xzf nginx-${NGINX_VERSION}.tar.gz && \
	rm nginx-${NGINX_VERSION}.tar.gz && \
	cd nginx-${NGINX_VERSION} && \
	./configure	\
	  --prefix=/usr/local/nginx	\
	  --with-http_ssl_module \
	  --add-module=../nginx-rtmp-module	&& \
	make &&	\
	make install

FROM alpine:3.14.6 as build-ffmpeg

ENV FFMPEG_VERSION 3.4.11
ENV PREFIX /usr/local
ENV MAKEFLAGS "-j4"

# FFmpeg build dependencies.
RUN apk add --update \
  build-base \
  coreutils \
  freetype-dev \
  lame-dev \
  libogg-dev \
  libass \
  libass-dev \
  libvpx-dev \
  libvorbis-dev \
  libwebp-dev \
  libtheora-dev \
  openssl-dev \
  opus-dev \
  pkgconf \
  pkgconfig \
  rtmpdump-dev \
  wget \
  x264-dev \
  x265-dev \
  yasm

RUN echo http://dl-cdn.alpinelinux.org/alpine/edge/community >> /etc/apk/repositories
RUN apk add --update fdk-aac-dev

# Get FFmpeg source.
RUN cd /tmp/ && \
  wget http://ffmpeg.org/releases/ffmpeg-4.4.tar.gz && \
  tar zxf ffmpeg-4.4.tar.gz && rm ffmpeg-4.4.tar.gz

# Compile ffmpeg.
RUN cd /tmp/ffmpeg-4.4 && \
  ./configure \
  --prefix=${PREFIX} \
  --enable-version3 \
  --enable-gpl \
  --enable-nonfree \
  --enable-small \
  --enable-libmp3lame \
  --enable-libx264 \
  --enable-libx265 \
  --enable-libvpx \
  --enable-libtheora \
  --enable-libvorbis \
  --enable-libopus \
  --enable-libfdk-aac \
  --enable-libass \
  --enable-libwebp \
  --enable-postproc \
  --enable-avresample \
  --enable-libfreetype \
  --enable-openssl \
  --disable-debug \
  --disable-doc \
  --disable-ffplay \
  --extra-libs="-lpthread -lm" && \
  make && make install && make distclean


FROM alpine:3.14.6
RUN     apk update && \
        apk add \
		openssl \
		libstdc++ \
		ca-certificates	\
		pcre \
		gettext	\
		lame \
		libogg \
		curl \
		libass \
		libvpx \
		libvorbis \
		libwebp	\
		libtheora \
		opus \
		rtmpdump \
		x264-dev \
		x265-dev\
        gcc                     


COPY --from=builder /usr/local/nginx /usr/local/nginx
COPY --from=build-ffmpeg /usr/local /usr/local
COPY --from=build-ffmpeg /usr/lib/libfdk-aac.so.2 /usr/lib/libfdk-aac.so.2

RUN rm /usr/local/nginx/conf/nginx.conf

ADD run.sh /

EXPOSE 1935
EXPOSE 8080

CMD sh /run.sh
