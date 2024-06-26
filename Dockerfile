FROM opensourcecobol/opensource-cobol

WORKDIR /app

COPY railway.cbl .

EXPOSE 8080

CMD ["cobcrun", "railway"]
