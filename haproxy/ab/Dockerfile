FROM alpine:latest

RUN apk update &&\
 apk add wget &&\
 mkdir /usr/src
WORKDIR /usr/src

RUN wget http://archive.apache.org/dist/httpd/httpd-2.4.37.tar.gz &&\
 tar xvfz httpd-*.tar.gz
WORKDIR /usr/src/httpd-2.4.37

RUN cp support/ab.c support/ab.c.old &&\
 wget https://raw.githubusercontent.com/fabianlee/blogcode/master/haproxy/ab.c -O support/ab.c &&\
 apk add build-base apr-dev apr apr-util apr-util-dev pcre pcre-dev &&\
 ./configure &&\
 make &&\
 cp support/ab /usr/sbin/ab

ENTRYPOINT ["/usr/sbin/ab"]
