FROM phusion/baseimage:0.9.18

RUN apt-get update && \
  apt-get install -y software-properties-common && \
  apt-add-repository -y ppa:ansible/ansible && \
  apt-get update && \
  apt-get install -y ansible python-pip curl unzip jq vim

RUN pip install boto

# Install Summon and the Conjur provider for summon
WORKDIR /tmp
RUN curl -o summon.tgz -sSL https://github.com/conjurinc/summon/releases/download/v0.4.0/summon_v0.4.0_linux_amd64.tar.gz
RUN tar -xf summon.tgz
RUN mv summon /usr/local/bin

RUN curl -o summon-conjur.zip -sSL https://github.com/conjurinc/summon-conjur/releases/download/v0.1.4/summon-conjur_v0.1.4_linux-amd64.zip
RUN unzip summon-conjur.zip
RUN mkdir -p /usr/local/lib/summon
RUN mv summon-conjur /usr/local/lib/summon

# Install the Conjur CLI
RUN curl -o conjur.deb -sSL https://github.com/conjurinc/cli-ruby/releases/download/v5.2.3/conjur_5.2.3-1_amd64.deb
RUN dpkg -i conjur.deb
RUN rm conjur.deb

ENV TERM     xterm
ENV CONJURRC /etc/conjur/conjur.conf
ENV POLICY   prod/ansible/v1

WORKDIR /src

# Enable a service to keep the container running.
RUN rm /etc/service/sshd/down
