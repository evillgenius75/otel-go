FROM golang:1.21 AS build
WORKDIR /go/src/app
COPY go.* ./
RUN go mod download
COPY . .
# RUN CGO_ENABLED=0 GOOS=linux go build -ldflags '-s' -o backend .
RUN CGO_ENABLED=0 GOOS=linux go build -a -ldflags '-extldflags "-static"' -tags timetzdata -mod=readonly -v -o /app .

FROM scratch
ENV GOTRACEBACK=single

WORKDIR /go/src/app
COPY --from=build /app .

# the tls certificates:
# NB: this pulls directly from the upstream image, which already has ca-certificates:
COPY --from=alpine:latest /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
ENTRYPOINT ["./app"]