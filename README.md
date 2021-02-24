# Docker-Keycloak

Primarily focused on creating docker container that will run on arm64 architecture


## Build
### Docker buildx
Standard keycloak-server is not available for arm, so we must compile. 

Run with `sudo bash ./scripts/buildx.sh {VERSION} --tag {REGISTRY}/{IMAGE}:{TAG}`
Ex: `buildx_keycloak-docker.sh 12.0.3 --tag ahgraber/keycloak:latest --tag ahgraber/keycloak:12.0.3`


**May have to include following in docker build for keycloak behind nginx reverse proxy**
```
USER jboss
RUN sed -i -e 's/<web-context>auth<\/web-context>/<web-context>keycloak\/auth<\/web-context>/' /opt/jboss/keycloak/standalone/configuration/standalone.xml
RUN sed -i -e 's/<web-context>auth<\/web-context>/<web-context>keycloak\/auth<\/web-context>/' /opt/jboss/keycloak/standalone/configuration/standalone-ha.xml
```
*Ref*
* https://stackoverflow.com/questions/44624844/configure-reverse-proxy-for-keycloak-docker-with-custom-base-url
* https://www.mai1015.com/development/2019/05/05/docker-keycloak-proxy-behind-nginx/