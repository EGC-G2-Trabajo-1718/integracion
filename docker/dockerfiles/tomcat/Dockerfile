FROM tomcat:7-jre8

RUN value=`cat conf/server.xml` && echo "${value//8080/80}" >| conf/server.xml
