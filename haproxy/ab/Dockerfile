FROM alpine:latest

RUN apk update &&\
 apk add wget &&\
 mkdir /usr/src
WORKDIR /usr/src

RUN wget http://apache.mirrors.pair.com/httpd/httpd-2.4.33.tar.gz &&\
 tar xvfz httpd-2.4.33.tar.gz
WORKDIR /usr/src/httpd-2.4.33

RUN cp support/ab.c support/ab.c.old &&\
 wget https://raw.githubusercontent.com/fabianlee/blogcode/master/haproxy/ab.c -O support/ab.c &&\
 apk add build-base apr-dev apr apr-util apr-util-dev pcre pcre-dev &&\
 ./configure &&\
 make &&\
 cp support/ab /usr/sbin/ab

ENTRYPOINT ["/usr/sbin/ab"]
