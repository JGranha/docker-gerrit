FROM almalinux:9.4
MAINTAINER Gerrit Code Review Community

# Add Gerrit packages repository
RUN rpm -i https://gerritforge.com/gerritforge-repo-1-4.noarch.rpm

ADD entrypoint.sh /

# Install OS pre-prequisites, OpenJDK and Gerrit in two subsequent transactions
# (pre-trans Gerrit script needs to have access to the Java command)
RUN yum -y install initscripts && \
    yum -y install java-17-openjdk && \
    yum -y install gerrit-3.10.0-1 && \
    /entrypoint.sh init && \
    rm -f /var/gerrit/etc/{ssh,secure}* && rm -Rf /var/gerrit/{static,index,logs,data,index,cache,git,db,tmp}/* && chown -R gerrit:gerrit /var/gerrit && \
    yum -y clean all

# Enable LEGACY security policies by default (for TLS 1.0/1.1 compatibility)
RUN update-crypto-policies --set LEGACY

USER gerrit

ENV CANONICAL_WEB_URL=
ENV HTTPD_LISTEN_URL=
ENV SERVER_ID=
ENV INSTANCE_ID=
ENV AUTH_MODE=

# Allow incoming traffic
EXPOSE 29418 8080 5005

VOLUME ["/var/gerrit/git", "/var/gerrit/index", "/var/gerrit/cache", "/var/gerrit/db", "/var/gerrit/etc", "/var/gerrit/plugins", "/var/gerrit/lib", "/var/gerrit/logs", "/var/gerrit/data", "/var/gerrit/db"]

ENTRYPOINT ["/entrypoint.sh"]
