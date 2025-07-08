
FROM ubuntu:latest

WORKDIR /app

COPY backend.sh .

RUN apt-get update && apt-get install -y xinetd

COPY xinetd.conf /etc/xinetd.conf
COPY servidor-service1 /etc/xinetd.d/servidor-service1

RUN chmod +x /etc/xinetd.d/servidor-service1

EXPOSE 9999

CMD ["/usr/sbin/xinetd", "-dontfork"]
