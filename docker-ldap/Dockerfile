FROM ubuntu:14.04

MAINTAINER Jon Mason <jon@conjur.net>

# Install Java
RUN ["apt-get", "update"]
RUN ["apt-get", "install", "-y", "default-jre"]
RUN ["apt-get", "install", "-y", "ruby2.0"]

RUN ["gem", "install", "ladle", "-v", "0.2"]

ADD . /ldap

WORKDIR /ldap

RUN ["mkdir", "-p", "tmp"]

EXPOSE 3897

ENV LDAP_PORT 3897

CMD ["./bin/ldap-server"]
