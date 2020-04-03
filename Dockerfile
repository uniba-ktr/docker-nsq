FROM golang as build
ENV GOOS=linux
ENV CGO_ENABLED=1
ARG VERSION=master

WORKDIR ${GOPATH}/src/github.com/nsqio
RUN git clone --branch ${VERSION} https://github.com/nsqio/nsq
WORKDIR ${GOPATH}/src/github.com/nsqio/nsq
RUN make BLDDIR=/build all

FROM alpine
ARG VERSION=master
ARG BUILD_DATE
ARG VCS_REF
ARG VCS_URL

COPY --from=build /build/ /usr/local/bin/

RUN apk add -U --no-cache libc6-compat && \
    ln -s /lib/ld-linux-* /lib/ld-linux.so.3 && \
    ln -s /usr/local/bin/*nsq* / && \
    ln -s /usr/local/bin/*nsq* /bin/



EXPOSE 4150 4151 4160 4161 4170 4171
#ENTRYPOINT ["/usr/bin/nsqd"]
LABEL de.uniba.ktr.nsq.version=$VERSION \
      de.uniba.ktr.nsq.name="NSQ" \
      de.uniba.ktr.nsq.docker.cmd="docker run --name=nsq unibaktr/nsq" \
      de.uniba.ktr.nsq.vendor="Marcel Grossmann" \
      de.uniba.ktr.nsq.architecture=$TARGETPLATFORM \
      de.uniba.ktr.nsq.vcs-ref=$VCS_REF \
      de.uniba.ktr.nsq.vcs-url=$VCS_URL \
      de.uniba.ktr.nsq.build-date=$BUILD_DATE
