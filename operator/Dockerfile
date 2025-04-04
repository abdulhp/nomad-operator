FROM golang:1.24.2-alpine3.21 as builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . ./
RUN go build


FROM alpine:3.21 as output
COPY --from=builder /app/operator /usr/local/bin/operator

CMD [ "operator" ]
