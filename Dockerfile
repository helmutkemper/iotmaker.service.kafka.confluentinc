#docker run --rm --name test -d golang:alpine3.12 tail -f /dev/null
#docker exec -it test sh
#unix:///var/run/docker.sock
#docker run --name delete -p 3000:3000 -v //var/run/docker.sock:/var/run/docker.sock delete:latest

FROM golang:alpine3.12 as builder

RUN mkdir /app
RUN chmod 700 /app

COPY . /app

# install git
RUN apk add --no-cache git

# install docker
# RUN apk add --update docker openrc
# RUN rc-update add docker boot

# make libraries folder from git project
RUN mkdir /go/src/github.com
RUN mkdir /go/src/github.com/docker

# change dir
WORKDIR /go/src/github.com/docker

RUN apk update && apk add --no-cache wget
RUN wget https://github.com/moby/moby/archive/v19.03.11.tar.gz
RUN tar -xzf v19.03.11.tar.gz && rm v19.03.11.tar.gz
RUN mv moby-19.03.11 docker

RUN go get godoc.org/golang.org/x/sys/windows; exit 0
RUN go get golang.org/x/crypto; exit 0
RUN go get golang.org/x/net; exit 0
RUN go get golang.org/x/text; exit 0
RUN go get github.com/opencontainers/go-digest; exit 0
RUN go get github.com/opencontainers/image-spec/specs-go/v1; exit 0
RUN go get github.com/containerd/containerd; exit 0
RUN go get google.golang.org/genproto/googleapis/rpc/status; exit 0
RUN go get github.com/golang/protobuf/proto; exit 0
RUN go get google.golang.org/grpc/codes; exit 0
RUN go get github.com/sirupsen/logrus; exit 0
RUN go get github.com/pkg/errors; exit 0
RUN go get github.com/gogo/protobuf/proto; exit 0
RUN go get github.com/docker/go-units; exit 0
RUN go get github.com/docker/distribution/reference; exit 0
RUN go get github.com/Microsoft/go-winio; exit 0
RUN go get github.com/helmutkemper/iotmaker.docker.util.whaleAquarium; exit 0
RUN go get github.com/helmutkemper/iotmaker.docker; exit 0

WORKDIR /
RUN find . -name vendor -type d -exec rm -rf {} +

# install moby project - end

# import golang packages to be used inside image "scratch"
ARG CGO_ENABLED=0
RUN go build -o /app/main /app/main.go

FROM scratch

COPY --from=builder /app .

VOLUME /var/run/docker.sock
# VOLUME /app/static/
EXPOSE 3000

CMD ["./main"]
