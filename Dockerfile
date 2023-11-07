FROM debian:latest

RUN apt-get update

RUN apt-get install -y dropbear git make m4

RUN mkdir -p /opt/gitfiler

RUN mkdir -p /opt/bin

RUN git clone https://github.com/bng44270/gitfiler /opt/gitfiler

RUN make -C /opt/gitfiler clean

ENTRYPOINT ["make","-C","/opt/gitfiler"]
