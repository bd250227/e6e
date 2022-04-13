# Stage #1: Build all essential binaries
#===========================================================#
FROM golang:1.17 AS builder
WORKDIR /workspace/
COPY go.* ./ 
RUN go mod download
COPY . .

# Build prod binary ( Linker flags - omit debug symbols for a small build size )
RUN GOARCH=amd64 GOOS=linux CGO_ENABLED=0\
    go build -ldflags="-w -s" -o bin/main

# Build test binary
RUN GOARCH=amd64 GOOS=linux CGO_ENABLED=0\
    go test -c -coverpkg='e6e/...' -o bin/e6e.test -tags testrunmain e6e

# Stage #2A: Install the test binary in a production-like image
#===========================================================#
FROM alpine:3.12.1 AS e2e
EXPOSE 8001
WORKDIR /go/bin
RUN apk add --no-cache ca-certificates
COPY --from=builder /workspace/bin/e6e.test /go/bin/e6e.test
CMD [ "/go/bin/e6e.test", "-port=8001", "-test.coverprofile=/tmp/coverage.out" ]

# Stage #2B: Install the production binary in a production image
#===========================================================#
FROM alpine:3.12.1 AS prd
EXPOSE 8000
WORKDIR /go/bin
RUN apk add --no-cache ca-certificates
COPY --from=builder /workspace/bin/main /go/bin/app
CMD [ "/go/bin/app", "-port=8000" ]
