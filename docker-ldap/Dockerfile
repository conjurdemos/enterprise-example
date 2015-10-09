FROM ruby:2.0

MAINTAINER Jon Mason <jon@conjur.net>

ADD . /ldap

WORKDIR /ldap

RUN ["bundle", "install"]
RUN ["chmod", "+x", "bin/ldap-server"]

# Install Java
RUN ["apt-get", "update"]
RUN ["apt-get", "install", "-y", "openjdk-7-jre"]


EXPOSE 3897

ENV LDAP_PORT 3897

CMD ["bundle", "exec", "./bin/ldap-server"]
