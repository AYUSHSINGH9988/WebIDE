# ==========================================
# STAGE 1: Build the code and generate .jar
# ==========================================
# Using the most modern Maven+Java8 image to ensure updated SSL certificates
FROM maven:3.9.6-eclipse-temurin-8 AS builder
WORKDIR /workspace

# Clone the repository with all submodules
RUN git clone --recursive https://github.com/AYUSHSINGH9988/WebIDE.git .

# Compile the code and FORCE Maven to ignore SSL certificate validation for ancient dependencies
RUN cd backend && mvn clean package -DskipTests \
    -Dmaven.wagon.http.ssl.insecure=true \
    -Dmaven.wagon.http.ssl.allowall=true \
    -Dmaven.wagon.http.ssl.ignore.validity.dates=true

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
