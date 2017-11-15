FROM openjdk:alpine
MAINTAINER Colin Coleman cco@capraconsulting.no

ENV USER=user
ENV HOME=/home/$USER

RUN apk add --update \
    ca-certificates \
    ca-certificates wget \
    groff \
    python
    python-dev \
    py2-pip \
    bash && \
  pip install awscli-cwlogs && \
  pip install --upgrade awscli && \
  rm -rf /var/cache/apk/* && \
  rm -rf /var/cache/apk/* && \
  update-ca-certificates && \
  adduser -S $USER

COPY toRoot/*  $HOME/

## Create directory for holding application logs and configure permissions
## Configure permissions
RUN mkdir -p $HOME/logs && \
    chmod 755 $HOME/*.sh && \
    chown -R $USER $HOME

## Expose application port
EXPOSE 5050

USER $USER
WORKDIR /home/$USER
CMD ["./java -jar app.jar"]