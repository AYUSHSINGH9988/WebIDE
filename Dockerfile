# ==========================================
# STAGE 1: Build the code and generate .jar
# ==========================================
FROM maven:3.8-eclipse-temurin-8 AS builder
WORKDIR /workspace

# Pura source code container mein copy karo
COPY . .

# Backend folder mein ja kar code compile karo (jar file banao)
RUN cd backend && mvn clean package -DskipTests

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

# Install oh-my-zsh (git:// ko https:// se replace kar diya hai error se bachne ke liye)
RUN git clone --depth=1 https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh \
	&& cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc

ENV SHELL /bin/zsh

WORKDIR /root

# Puraani ADD command ki jagah 'builder' stage se bani hui nayi .jar file copy karo
COPY --from=builder /workspace/backend/target/ide-backend.jar /root/ide-backend.jar
COPY --from=builder /workspace/backend/src/main/resources/lib /root/lib

# Original CMD with arguments
CMD ["java", "-jar", "ide-backend.jar", "--PTY_LIB_FOLDER=/root/lib"]
