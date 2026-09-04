# ==========================================
# STAGE 1: Build the code and generate .jar
# ==========================================
# Use standard Debian-based Maven (better SSL certificates than Alpine)
FROM maven:3.8.6-eclipse-temurin-8 AS builder
WORKDIR /workspace

# Install git
RUN apt-get update && apt-get install -y git

# Clone the repository with all submodules
RUN git clone --recursive https://github.com/AYUSHSINGH9988/WebIDE.git .

# Compile the code and FORCE modern TLSv1.2 for Maven Central downloads
RUN cd backend && mvn clean package -DskipTests -Dhttps.protocols=TLSv1.2

# ==========================================
# STAGE 2: Setup the final runtime environment
# ==========================================
FROM eclipse-temurin:8-jdk-alpine

EXPOSE 8080

# Basic tools install karo
RUN set -ex && \
    if [ $(wget -qO- ipinfo.io/country) == CN ]; then echo "http://mirrors.aliyun.com/alpine/latest-stable/main/" > /etc/apk/repositories ;fi && \
    apk update && \
    apk add --no-cache zsh git openssh

# Install oh-my-zsh (modern https link)
RUN git clone --depth=1 https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh \
	&& cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc

ENV SHELL=/bin/zsh

WORKDIR /root

# Builder stage se successful bani hui .jar file aur lib copy karo
COPY --from=builder /workspace/backend/target/ide-backend.jar /root/ide-backend.jar
COPY --from=builder /workspace/backend/src/main/resources/lib /root/lib

# Original CMD
CMD ["java", "-jar", "ide-backend.jar", "--PTY_LIB_FOLDER=/root/lib"]
