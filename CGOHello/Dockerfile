FROM golang:1.21 as build
WORKDIR /src
COPY ./main.go .
RUN CGO_ENABLED=0 go build -a -installsuffix cgo -o /bin/hello ./main.go

FROM scratch
COPY --from=build /bin/hello /bin/hello
#COPY --from=0 /bin/hello /bin/hello
CMD ["/bin/hello"]