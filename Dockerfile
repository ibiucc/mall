# FROM registry.cn-heyuan.aliyuncs.com/jiantao1/jiantao1:latest
FROM openjdk:8-jre-alpine

ARG JAR_FILE=mall.jar
USER root
#RUN sed -i 's#http://deb.debian.org#https://mirrors.tuna.tsinghua.edu.cn#g' /etc/apt/sources.list
# 设置时区 安装ps命令
ENV TZ=Asia/Shanghai
RUN set -eux; \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime; \
    echo $TZ > /etc/timezone; \
    apt-get update && apt-get install -y procps && apt-get install -y maven
# 复制 Maven 的配置文件到容器中
# COPY settings.xml /usr/share/maven/conf/settings.xml


# 新建应用目录
ARG HOME=/data/mall
RUN mkdir -p $HOME/config;mkdir $HOME/log;mkdir $HOME/bin;mkdir $HOME/h2db;mkdir $HOME/file;mkdir $HOME/code;ls -la $HOME
# build jar
ADD ./ $HOME/code/
WORKDIR $HOME/code
RUN set -eux;ls -la;mvn clean install -DskipTests && cp $HOME/code/target/$JAR_FILE $HOME  && \
    cp $HOME/code/file/* ../file/ && cp $HOME/code/h2db/* ../h2db/ && cp $HOME/code/boot.sh ../bin/

# 启动脚本
WORKDIR $HOME/bin
ENTRYPOINT sh boot.sh start

# 端口
EXPOSE 8081