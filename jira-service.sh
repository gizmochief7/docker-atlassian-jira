#!/bin/sh

SERVER_XML="${ATL_HOME}/conf/server.xml"
SERAPH_XML="${ATL_HOME}/atlassian-jira/WEB-INF/classes/seraph-config.xml"
CROWD_PROPS="${ATL_HOME}/atlassian-jira/WEB-INF/classes/crowd.properties"

# Remove any previous proxy configuration.
sed -E 's/ proxyName="[^"]*"//g' -i "${SERVER_XML}"
sed -E 's/ proxyPort="[^"]*"//g' -i "${SERVER_XML}"
sed -E 's/ path="[^"]*"//g' -i "${SERVER_XML}"

# Remove any previous authentication configuration.
perl -p0777e 's|(<!--[\s\n]*)?(<auth[^>]*>)([\s\n]*-->)?|<!-- $2 -->|gm' \
    -i "${SERAPH_XML}"

# Add new proxy configuration if environment variables are set.
if [ ! -z "${TC_PROXYNAME}" ]; then
  sed -E "s|<Connector|<Connector proxyName=\"${TC_PROXYNAME}\"|g" \
      -i "${SERVER_XML}"
fi
if [ ! -z "${TC_PROXYPORT}" ]; then
  sed -E "s|<Connector|<Connector proxyPort=\"${TC_PROXYPORT}\"|g" \
      -i "${SERVER_XML}"
fi
sed -E "s|<Context|<Context path=\"${TC_ROOTPATH}\"|g" \
    -i "${SERVER_XML}"

# Configure authentication based on environment variables.
JIRA_AUTH="${JIRA_AUTH:-JiraSeraphAuthenticator}"
sed -E "s|<!-- (<auth[^>]*${JIRA_AUTH}[^>]*>) -->|\1|g" \
    -i "${SERAPH_XML}"

# Set up Crowd SSO if using the Crowd SSO authenticator.
if [ "${JIRA_AUTH}" = "SSOSeraphAuthenticator" ]; then
    cat <<EOF > "${CROWD_PROPS}"
application.name            ${CROWD_APP_NAME}
application.password        ${CROWD_APP_PASS}
application.login.url       ${CROWD_BASE_URL}/console/
crowd.server.url            ${CROWD_BASE_URL}/services/
crowd.base.url              ${CROWD_BASE_URL}/
session.isauthenticated     session.isauthenticated
session.tokenkey            session.tokenkey
session.validationinterval  2
session.lastvalidation      session.lastvalidation
EOF
fi

exec "${ATL_HOME}/bin/start-jira.sh" -fg
