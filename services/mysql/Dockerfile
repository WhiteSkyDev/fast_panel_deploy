FROM mysql:latest

COPY init/ /docker-entrypoint-initdb.d/
RUN chmod -R 777 /docker-entrypoint-initdb.d/
