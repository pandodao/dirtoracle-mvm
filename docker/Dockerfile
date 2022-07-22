FROM golang:1.18 AS builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . ./

RUN make build-prod

FROM frolvlad/alpine-glibc:glibc-2.34

WORKDIR /app

COPY --from=builder /app/builds/doracle-mvm.prod doracle-mvm

EXPOSE 7121

ENTRYPOINT ["/app/doracle-mvm"]
