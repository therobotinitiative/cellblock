FROM mariadb:12.1.2-ubi10

ARG UID
ARG GID

USER root
# Match host user UID:GID (1000:1000 is typical)
RUN usermod -u $UID mysql && \
    groupmod -g $GID mysql

# Ensure /run/mariadb exists and belongs to mysql
RUN mkdir -p /run/mariadb && \
    chown -R mysql:mysql /run/mariadb

# IMPORTANT: remove pre-initialized database so that
# official entrypoint runs DB + user creation
RUN rm -rf /var/lib/mysql/* && \
    chown -R mysql:mysql /var/lib/mysql

# Allow remote connections
RUN mkdir -p /etc/my.cnf.d && \
    printf "[mysqld]\nbind-address=0.0.0.0\n" > /etc/my.cnf.d/network.cnf

USER mysql
EXPOSE 3306
