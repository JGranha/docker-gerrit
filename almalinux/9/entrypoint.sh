#!/bin/bash -e

export JAVA_OPTS='--add-opens java.base/java.net=ALL-UNNAMED --add-opens java.base/java.lang.invoke=ALL-UNNAMED'

if [ ! -d /var/gerrit/git/All-Projects.git ] || [ "$1" == "init" ]
then
  echo "Initializing Gerrit site ..."
  mkdir -p /var/gerrit/etc
  git config -f /var/gerrit/etc/gerrit.config --add container.javaOptions "-Djava.security.egd=file:/dev/./urandom"
  git config -f /var/gerrit/etc/gerrit.config --add container.javaOptions "--add-opens java.base/java.net=ALL-UNNAMED"
  git config -f /var/gerrit/etc/gerrit.config --add container.javaOptions "--add-opens java.base/java.lang.invoke=ALL-UNNAMED"
  git config -f /var/gerrit/etc/gerrit.config --add container.javaOptions "-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005"
  git config -f /var/gerrit/etc/gerrit.config --add plugins.allowRemoteAdmin "true"
  git config -f /var/gerrit/etc/gerrit.config --add plugin.metrics-reporter-prometheus.prometheusBearerToken "token"
  if [ -n "$AUTH_MODE" ];  then
    git config -f /var/gerrit/etc/gerrit.config --add auth.type ${AUTH_MODE}
  fi
  if [ -n "$SERVER_ID" ];  then
    git config -f /var/gerrit/etc/gerrit.config --add gerrit.serverId ${SERVER_ID}
  fi
  if [ -n "$INSTANCE_ID" ];  then
    git config -f /var/gerrit/etc/gerrit.config --add gerrit.instanceId "${INSTANCE_ID}"
  fi
  java $JAVA_OPTS -jar /gerrit.war init --batch --no-auto-start --install-all-plugins --dev -d /var/gerrit
  sleep 10
  java $JAVA_OPTS -jar /var/gerrit/bin/gerrit.war reindex -d /var/gerrit
fi

git config -f /var/gerrit/etc/gerrit.config gerrit.canonicalWebUrl "${CANONICAL_WEB_URL:-http://$HOSTNAME/}"
if [ ${HTTPD_LISTEN_URL} ];
then
  git config -f /var/gerrit/etc/gerrit.config httpd.listenUrl ${HTTPD_LISTEN_URL}
fi

if [ "$1" != "init" ]
then
  echo "Running Gerrit ..."
  exec /var/gerrit/bin/gerrit.sh run
fi
