FROM debian:wheezy as builder

RUN apt-get update -y && apt-get install --no-install-recommends -y -q \
                         curl \
                         zip \
                         build-essential \
                         ca-certificates \
                         git mercurial bzr \
               && rm -rf /var/lib/apt/lists/*

ENV GOVERSION 1.9
RUN mkdir /goroot && mkdir /gopath
RUN curl https://storage.googleapis.com/golang/go${GOVERSION}.linux-amd64.tar.gz \
           | tar xvzf - -C /goroot --strip-components=1

ENV GOPATH /gopath
ENV GOROOT /goroot
ENV PATH $GOROOT/bin:$GOPATH/bin:$PATH

RUN go get github.com/mitchellh/gox

ENV SRC=${GOPATH}/src/github.com/arminc/clair-scanner
COPY . ${SRC}
WORKDIR ${SRC}
RUN make install
RUN make ensure
RUN make build

FROM alpine:latest
ENV GOPATH /gopath
ENV SRC=${GOPATH}/src/github.com/arminc/clair-scanner
COPY --from=builder ${SRC}/clair-scanner /usr/local/bin
