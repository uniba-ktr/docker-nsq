ARG IMAGE_TARGET=debian:stretch-slim
ARG BUILD_BASE

# first image to download qemu and make it executable
FROM ${BUILD_BASE} AS qemu
ARG QEMU=x86_64
ARG QEMU_VERSION=v2.11.0
ADD https://github.com/multiarch/qemu-user-static/releases/download/${QEMU_VERSION}/qemu-${QEMU}-static /qemu-${QEMU}-static
RUN chmod +x /qemu-${QEMU}-static

# second image to be deployed on dockerhub
FROM ${IMAGE_TARGET}
ARG QEMU=x86_64
COPY --from=qemu /qemu-${QEMU}-static /usr/bin/qemu-${QEMU}-static
ARG ARCH=amd64
ARG NSQ_ARCH=amd64
ARG VERSION=master
ARG BUILD_DATE
ARG VCS_REF
ARG VCS_URL
ENV DEBIAN_FRONTEND noninteractive

COPY --from=qemu /build/nsqd-linux-${NSQ_ARCH} /usr/local/bin/nsqd
COPY --from=qemu /build/nsqlookupd-linux-${NSQ_ARCH} /usr/local/bin/nsqlookupd
COPY --from=qemu /build/nsqadmin-linux-${NSQ_ARCH} /usr/local/bin/nsqadmin
COPY --from=qemu /build/nsq_to_nsq-linux-${NSQ_ARCH} /usr/local/bin/nsq_to_nsq
COPY --from=qemu /build/nsq_to_file-linux-${NSQ_ARCH} /usr/local/bin/nsq_to_file
COPY --from=qemu /build/nsq_to_http-linux-${NSQ_ARCH} /usr/local/bin/nsq_to_http
COPY --from=qemu /build/nsq_tail-linux-${NSQ_ARCH} /usr/local/bin/nsq_tail
COPY --from=qemu /build/nsq_stat-linux-${NSQ_ARCH} /usr/local/bin/nsq_stat
COPY --from=qemu /build/to_nsq-linux-${NSQ_ARCH} /usr/local/bin/to_nsq

RUN apk add -U --no-cache libc6-compat && \
    ln -s /usr/local/bin/*nsq* / && \
    ln -s /usr/local/bin/*nsq* /bin/

EXPOSE 4150 4151 4160 4161 4170 4171
#ENTRYPOINT ["/usr/bin/nsqd"]
LABEL de.uniba.ktr.nsq.version=$VERSION \
      de.uniba.ktr.nsq.name="NSQ" \
      de.uniba.ktr.nsq.docker.cmd="docker run --name=nsq unibaktr/nsq" \
      de.uniba.ktr.nsq.vendor="Marcel Grossmann" \
      de.uniba.ktr.nsq.architecture=$ARCH \
      de.uniba.ktr.nsq.vcs-ref=$VCS_REF \
      de.uniba.ktr.nsq.vcs-url=$VCS_URL \
      de.uniba.ktr.nsq.build-date=$BUILD_DATE
