# Stage #1: Build all essential binaries
#===========================================================#
FROM golang:1.17 AS builder
WORKDIR /workspace/
COPY go.* ./ 
RUN go mod download
COPY . .

# Build prod binary ( Linker flags - omit debug symbols for a small build size )
RUN GOARCH=amd64 GOOS=linux CGO_ENABLED=0\
    go build -ldflags="-w -s" -o bin/ftr ./cmd

# Stage #2: Install the production binary in a production image
#===========================================================#
FROM alpine:3.12.1 AS prd
EXPOSE 8000
WORKDIR /go/bin
RUN apk add --no-cache ca-certificates
COPY --from=builder /workspace/bin/ftr /go/bin/ftr
CMD [ "/go/bin/ftr" ]