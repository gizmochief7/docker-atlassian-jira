FROM jleight/atlassian-base:latest
MAINTAINER Jonathon Leight <jonathon.leight@jleight.com>

ENV APP_VERSION 6.4.7
ENV APP_BASEURL ${ATL_BASEURL}/jira/downloads/binary
ENV APP_PACKAGE atlassian-jira-${APP_VERSION}.tar.gz
ENV APP_URL     ${APP_BASEURL}/${APP_PACKAGE}
ENV APP_PROPS   atlassian-jira/WEB-INF/classes/jira-application.properties

RUN set -x \
  && curl -kL "${APP_URL}" | tar -xz -C "${ATL_HOME}" --strip-components=1 \
  && echo -e "\njira.home=${ATL_DATA}" >> "${ATL_HOME}/${APP_PROPS}"

ADD jira-service.sh /opt/jira-service.sh

EXPOSE 8080
CMD ["/opt/jira-service.sh"]
