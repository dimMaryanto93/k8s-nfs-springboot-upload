ARG JDK_VERSION=11-oraclelinux8
ARG JDK_VENDOR=openjdk
FROM ${JDK_VENDOR}:${JDK_VERSION}

LABEL maintener="Dimas Maryanto <software.dimas_m@icloud.com>"
LABEL   app.framework.name="spring-boot"
        app.framework.version="2.5.2"
        app.sdk.version="${JDK_VERSION}"
        app.sdk.name="${JDK_VENDOR}"

# Created user
RUN groupadd www-data && \
adduser -r -g www-data www-data

# Create folder & give access to read and write
ENV FILE_UPLOAD_STORED=/var/lib/spring-boot/data
RUN mkdir -p ${FILE_UPLOAD_STORED} && \
chown www-data:www-data ${FILE_UPLOAD_STORED}/* && \
chmod -R 777 ${FILE_UPLOAD_STORED}/

WORKDIR /usr/local/share/applications
USER www-data

ENV APPLICATION_PORT=8080
ENV FLYWAY_ENABLED=true

ARG JAR_FILE="springboot-k8s-nfs-0.0.1-SNAPSHOT.jar"
COPY --chown=www-data:www-data target/${JAR_FILE} spring-boot.jar

ENTRYPOINT ["java", "-jar", "-Djava.security.egd=file:/dev/./urandom", "spring-boot.jar"]

CMD ["--server.port=${APPLICATION_PORT}"]

EXPOSE ${APPLICATION_PORT}/tcp

HEALTHCHECK --interval=5m --timeout=3s \
  CMD curl -f http://localhost:${APPLICATION_PORT}/actuator/health || exit 1

VOLUME ${FILE_UPLOAD_STORED}/
