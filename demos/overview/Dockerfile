FROM ubuntu:14.04

RUN apt-get update
RUN apt-get install -y openssh-server curl supervisor
RUN curl -L https://www.opscode.com/chef/install.sh | bash
RUN chef-solo --recipe-url https://github.com/conjur-cookbooks/conjur/releases/download/v0.4.3/conjur-v0.4.3.tar.gz -o conjur::install

RUN mkdir /var/run/sshd
COPY ./etc/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 22

CMD ["/usr/bin/supervisord"]