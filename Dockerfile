# Install Operating system and dependencies
FROM ubuntu:22.04

# Necessary packages in order to serve my application
RUN apt-get update
RUN apt-get install -y python3 fuse

# Copy files to container and build
RUN mkdir /app
COPY . /app
WORKDIR /app

# Record the exposed port
EXPOSE 8080

# make server startup script executable and start the web server
RUN chown -R $(id -u):$(id -g) /app
RUN chmod +x /app/server/server.sh

ENTRYPOINT [ "/app/server/server.sh"]
