ARG agent_version=3192.v713e3b_039fb_e-1
FROM jenkins/inbound-agent:${agent_version}-jdk11 as jnlp 

FROM python:3.10-bullseye

USER root

ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000

RUN groupadd -g ${gid} ${group}
RUN useradd -c "Jenkins user" -d /home/${user} -u ${uid} -g ${gid} -m ${user}

RUN apt-get update
RUN apt-get install -y openjdk-11-jre

COPY --from=jnlp /usr/local/bin/jenkins-agent /usr/local/bin/jenkins-agent
COPY --from=jnlp /usr/share/jenkins/agent.jar /usr/share/jenkins/agent.jar

RUN pip install --upgrade setuptools

COPY requirements.txt requirements.txt
RUN apt-get -y install gcc build-essential ca-certificates \
    libffi-dev  libxslt-dev curl bash git git-lfs  \
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