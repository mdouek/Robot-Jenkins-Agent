FROM jenkins/inbound-agent:4.6-1 as jnlp

FROM python:3.9.13-bullseye

USER root

RUN addgroup -g 1000 jenkins
RUN adduser -h /home/jenkins -u 1000 -G jenkins -D jenkins

RUN apt-get update
RUN apt-get install openjdk11-jre

COPY --from=jnlp /usr/local/bin/jenkins-agent /usr/local/bin/jenkins-agent
COPY --from=jnlp /usr/share/jenkins/agent.jar /usr/share/jenkins/agent.jar

COPY requirements.txt requirements.txt
RUN apt-get install gcc build-base linux-headers ca-certificates \
    libffi-dev libressl-dev libxslt-dev curl bash git git-lfs musl-locales \
    openssh-client openssl procps
RUN pip install -r requirements.txt

USER jenkins
RUN mkdir /home/jenkins/.jenkins && mkdir -p /home/jenkins/agent
VOLUME /home/jenkins/.jenkins
VOLUME /home/jenkins/agent
WORKDIR /home/jenkins 

ENTRYPOINT ["/usr/local/bin/jenkins-agent"]