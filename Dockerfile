FROM --platform=linux/arm64 ubuntu:20.04

RUN apt-get update && apt-get install -y gnucobol

COPY railway /railway
RUN chmod +x /railway

EXPOSE 8080

CMD ["/railway"]
