# syntax=docker/dockerfile:1

FROM mysql:latest

ENV MYSQL_ROOT_PASSWORD=tutorial
ENV MYSQL_DATABASE=reflexion-coaching
ENV MYSQL_USER=user1
ENV MYSQL_PASSWORD=password

EXPOSE 3306 33060

