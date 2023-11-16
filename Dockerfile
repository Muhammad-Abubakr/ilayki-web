# Install Operating system and dependencies
FROM ubuntu:22.04

RUN apt-get update 
RUN apt-get install -y curl git wget unzip libgconf-2-4 gdb libstdc++6 libglu1-mesa fonts-droid-fallback lib32stdc++6 python3
RUN apt-get clean 

#Copy files to container and build
RUN mkdir /app/
COPY . /app/
WORKDIR /app/

# Clone Flutter
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter

# Set flutter environment path
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Run flutter doctor
RUN flutter doctor

# Flutter upgrade
RUN flutter clean
RUN flutter config --enable-web 
RUN flutter create .

# building Flutter
RUN flutter pub get
RUN flutter build web

# Record the exposed port
EXPOSE 8080

# change to build dir and run server
RUN cd build/web
RUN python -m http.server 8080

