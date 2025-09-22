# Parent image from debian distribution
FROM debian:stable-slim

# Upgrade system and package manager
RUN apt-get update -y 
RUN apt-get upgrade -y

# Install tools for C++
RUN apt-get install -y cmake ninja-build build-essential

# Copy source code here
COPY . MyProject

# Create building directory
RUN mkdir MyProject/build

# Configure and build
RUN cd MyProject/build && cmake -G "Ninja" .. -DHELLOWORD_WITH_TESTS=OFF && ninja && ninja install

# Clean to keep the image small
RUN rm -rf MyProject && apt-get purge -y cmake ninja-build

# Tada
CMD HelloWorld