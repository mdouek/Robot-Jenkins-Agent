FROM jenkins/inbound-agent:4.6-1-alpine as jnlp

FROM python:3.9.13-alpine3.16

USER root

RUN addgroup -g 1000 jenkins
RUN adduser -h /home/jenkins -u 1000 -G jenkins -D jenkins

RUN apk -U add openjdk11-jre

COPY --from=jnlp /usr/local/bin/jenkins-agent /usr/local/bin/jenkins-agent
COPY --from=jnlp /usr/share/jenkins/agent.jar /usr/share/jenkins/agent.jar

COPY requirements.txt requirements.txt
RUN apk add -U --no-cache gcc build-base linux-headers ca-certificates \
    libffi-dev libressl-dev libxslt-dev curl bash git git-lfs musl-locales \
    openssh-client openssl procps
RUN pip install -r requirements.txt

RUN wget "https://www.browserstack.com/browserstack-local/BrowserStackLocal-linux-x64.zip"
RUN unzip BrowserStackLocal-linux-x64.zip

USER jenkins
RUN mkdir /home/jenkins/.jenkins && mkdir -p /home/jenkins/agent
VOLUME /home/jenkins/.jenkins
VOLUME /home/jenkins/agent
WORKDIR /home/jenkins 

ENTRYPOINT ["/usr/local/bin/jenkins-agent"]