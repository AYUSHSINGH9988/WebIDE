# ==========================================
# STAGE 1: Build the code and generate .jar
# ==========================================
# Standard Maven image (Git is already pre-installed in this!)
FROM maven:3.6.3-jdk-8 AS builder
WORKDIR /workspace

# Seedha clone karo (No apt-get needed, so no 404 error!)
RUN git clone --recursive https://github.com/AYUSHSINGH9988/WebIDE.git .

# Compile the code
RUN cd backend && mvn clean package -DskipTests

# ==========================================
# STAGE 2: Setup the final runtime environment
# ==========================================
FROM eclipse-temurin:8-jdk-alpine

EXPOSE 8080

# Basic tools install karo for the terminal
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
