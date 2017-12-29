FROM node:9

VOLUME [ "/app" ]

WORKDIR /bin

COPY start.sh .

RUN [ "chmod", "755", "start.sh" ]

EXPOSE 80

CMD start.sh
