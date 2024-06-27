FROM ubuntu:20.04

RUN apt-get update && apt-get install -y gnucobol net-tools netcat gcc

COPY . /

RUN gcc -c errno.c -o errno.o

RUN cobc -x -free -o railway railway.cbl errno.o

RUN chmod +x railway

EXPOSE 8080

USER root

CMD ["/railway"]
